#!/usr/bin/env python3
"""
Export the theoretical-mechanics course coverage matrix from Lean.

Source of truth:
  MechLib.Spec.Coverage.coverageMatrixJson

Outputs:
  corpus/coverage_matrix.json
  corpus/coverage_matrix.md
"""

from __future__ import annotations

import argparse
import json
import subprocess
import tempfile
from pathlib import Path
from typing import Any


STATUS_VALUES = {"verified", "schema", "alias", "experimental", "todo"}
TRUST_VALUES = {"core", "derived", "interface", "example"}
REQUIRED_TOPIC_FIELDS = {
    "id",
    "zh_name",
    "en_name",
    "module_path",
    "status",
    "trust_level",
    "prerequisites",
    "key_concepts",
    "laws",
    "problem_templates",
    "verified_decls",
    "schema_decls",
    "examples",
    "aliases_zh",
    "aliases_en",
}
LIST_FIELDS = {
    "prerequisites",
    "key_concepts",
    "laws",
    "problem_templates",
    "verified_decls",
    "schema_decls",
    "examples",
    "aliases_zh",
    "aliases_en",
}


def run_lean_export(repo_root: Path) -> dict[str, Any]:
    build_proc = subprocess.run(
        ["lake", "build", "MechLib.Spec.Coverage"],
        cwd=repo_root,
        check=False,
        capture_output=True,
        text=True,
        encoding="utf-8",
        errors="replace",
    )
    if build_proc.returncode != 0:
        raise RuntimeError(
            "Lean coverage module build failed\n"
            f"stdout:\n{build_proc.stdout}\n"
            f"stderr:\n{build_proc.stderr}"
        )

    code = """import MechLib.Spec.Coverage
#eval IO.println MechLib.Spec.Coverage.coverageMatrixJson.compress
"""
    with tempfile.NamedTemporaryFile("w", encoding="utf-8", suffix=".lean", delete=False) as tmp:
        tmp.write(code)
        tmp_path = Path(tmp.name)

    try:
        proc = subprocess.run(
            ["lake", "env", "lean", str(tmp_path)],
            cwd=repo_root,
            check=False,
            capture_output=True,
            text=True,
            encoding="utf-8",
            errors="replace",
        )
    finally:
        tmp_path.unlink(missing_ok=True)

    if proc.returncode != 0:
        raise RuntimeError(
            "Lean coverage export failed\n"
            f"stdout:\n{proc.stdout}\n"
            f"stderr:\n{proc.stderr}"
        )

    lines = [line.strip() for line in proc.stdout.splitlines() if line.strip()]
    if not lines:
        raise RuntimeError("Lean coverage export produced no JSON output")

    raw_json = next((line for line in reversed(lines) if line.startswith("{")), lines[-1])
    try:
        data = json.loads(raw_json)
    except json.JSONDecodeError as exc:
        raise RuntimeError(f"Failed to parse Lean JSON output: {raw_json}") from exc
    if not isinstance(data, dict):
        raise RuntimeError("Coverage matrix root must be a JSON object")
    return data


def _require_list(value: Any, path: str) -> list[Any]:
    if not isinstance(value, list):
        raise ValueError(f"{path} must be a list")
    return value


def validate_matrix(data: dict[str, Any]) -> None:
    chapters = _require_list(data.get("chapters"), "chapters")
    if not chapters:
        raise ValueError("coverage matrix must contain at least one chapter")

    seen_topic_ids: set[str] = set()
    for chapter_index, chapter in enumerate(chapters):
        if not isinstance(chapter, dict):
            raise ValueError(f"chapters[{chapter_index}] must be an object")
        chapter_id = str(chapter.get("id") or "")
        topics = _require_list(chapter.get("topics"), f"chapter {chapter_id}.topics")
        if len(topics) < 5:
            raise ValueError(f"chapter {chapter_id} has {len(topics)} topics; expected at least 5")

        for topic_index, topic in enumerate(topics):
            if not isinstance(topic, dict):
                raise ValueError(f"chapter {chapter_id}.topics[{topic_index}] must be an object")
            missing = sorted(REQUIRED_TOPIC_FIELDS - set(topic))
            if missing:
                raise ValueError(f"topic {chapter_id}[{topic_index}] missing fields: {missing}")

            topic_id = str(topic["id"])
            if not topic_id:
                raise ValueError(f"chapter {chapter_id}.topics[{topic_index}] has empty id")
            if topic_id in seen_topic_ids:
                raise ValueError(f"duplicate topic id: {topic_id}")
            seen_topic_ids.add(topic_id)

            status = topic["status"]
            trust_level = topic["trust_level"]
            if status not in STATUS_VALUES:
                raise ValueError(f"topic {topic_id} has invalid status: {status}")
            if trust_level not in TRUST_VALUES:
                raise ValueError(f"topic {topic_id} has invalid trust_level: {trust_level}")

            for field in LIST_FIELDS:
                values = _require_list(topic[field], f"topic {topic_id}.{field}")
                if not all(isinstance(item, str) for item in values):
                    raise ValueError(f"topic {topic_id}.{field} must contain only strings")

            verified = set(topic["verified_decls"])
            schema = set(topic["schema_decls"])
            overlap = sorted(verified.intersection(schema))
            if overlap:
                raise ValueError(f"topic {topic_id} mixes verified/schema declarations: {overlap}")

            if status == "verified" and not verified:
                raise ValueError(f"topic {topic_id} is verified but has no verified_decls")
            if status == "schema" and not (schema or verified):
                raise ValueError(f"topic {topic_id} is schema but has no schema_decls or verified_decls")


def render_markdown(data: dict[str, Any]) -> str:
    lines: list[str] = [
        "# Theoretical Mechanics Coverage Matrix",
        "",
        f"- schema_version: `{data.get('schema_version', '')}`",
        f"- source_module: `{data.get('source_module', '')}`",
        "",
    ]
    for chapter in data["chapters"]:
        chapter_title = f"{chapter.get('en_name', '')} / {chapter.get('zh_name', '')}"
        lines.extend(
            [
                f"## {chapter_title}",
                "",
                "| id | zh_name | en_name | status | trust_level | module_path | verified_decls | schema_decls |",
                "| --- | --- | --- | --- | --- | --- | --- | --- |",
            ]
        )
        for topic in chapter["topics"]:
            verified = "<br>".join(topic["verified_decls"]) if topic["verified_decls"] else ""
            schema = "<br>".join(topic["schema_decls"]) if topic["schema_decls"] else ""
            lines.append(
                "| {id} | {zh} | {en} | `{status}` | `{trust}` | `{module}` | {verified} | {schema} |".format(
                    id=topic["id"],
                    zh=topic["zh_name"],
                    en=topic["en_name"],
                    status=topic["status"],
                    trust=topic["trust_level"],
                    module=topic["module_path"],
                    verified=verified,
                    schema=schema,
                )
            )
        lines.append("")
    return "\n".join(lines).rstrip() + "\n"


def write_outputs(data: dict[str, Any], json_path: Path, md_path: Path) -> None:
    json_path.parent.mkdir(parents=True, exist_ok=True)
    md_path.parent.mkdir(parents=True, exist_ok=True)
    json_text = json.dumps(data, ensure_ascii=False, indent=2) + "\n"
    md_text = render_markdown(data)
    json_path.write_text(json_text, encoding="utf-8", newline="\n")
    md_path.write_text(md_text, encoding="utf-8", newline="\n")


def check_outputs(data: dict[str, Any], json_path: Path, md_path: Path) -> None:
    expected_json = json.dumps(data, ensure_ascii=False, indent=2) + "\n"
    expected_md = render_markdown(data)
    if not json_path.exists():
        raise FileNotFoundError(f"missing generated JSON: {json_path}")
    if not md_path.exists():
        raise FileNotFoundError(f"missing generated Markdown: {md_path}")
    if json_path.read_text(encoding="utf-8") != expected_json:
        raise RuntimeError(f"{json_path} is stale; rerun tools/export_coverage_matrix.py")
    if md_path.read_text(encoding="utf-8") != expected_md:
        raise RuntimeError(f"{md_path} is stale; rerun tools/export_coverage_matrix.py")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Export MechLib theoretical-mechanics coverage matrix.")
    parser.add_argument("--json-out", default="corpus/coverage_matrix.json")
    parser.add_argument("--md-out", default="corpus/coverage_matrix.md")
    parser.add_argument("--check", action="store_true", help="Validate generated files are up to date")
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    repo_root = Path.cwd()
    json_path = (repo_root / args.json_out).resolve()
    md_path = (repo_root / args.md_out).resolve()

    data = run_lean_export(repo_root)
    validate_matrix(data)

    if args.check:
        check_outputs(data, json_path, md_path)
        print(f"[check] coverage matrix is up to date: {json_path}")
        print(f"[check] coverage markdown is up to date: {md_path}")
    else:
        write_outputs(data, json_path, md_path)
        topic_count = sum(len(chapter["topics"]) for chapter in data["chapters"])
        print(f"[export] coverage matrix: {json_path} ({topic_count} topics)")
        print(f"[export] coverage markdown: {md_path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
