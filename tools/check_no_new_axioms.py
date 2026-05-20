#!/usr/bin/env python3
"""Audit MechLib for unsafe declarations and report new occurrences."""

from __future__ import annotations

import argparse
import json
import re
import subprocess
from datetime import datetime, timezone
from pathlib import Path
from typing import Iterable


DECL_WORDS = ["axi" + "om", "const" + "ant", "opa" + "que"]
PROOF_GAP_WORDS = ["sor" + "ry", "ad" + "mit"]
PATTERN = re.compile(
    r"^\s*(" + "|".join(DECL_WORDS) + r")\b|\b(" + "|".join(PROOF_GAP_WORDS) + r")\b"
)
DEFAULT_ROOTS = ["MechLib", "tools"]


def iter_files(roots: Iterable[Path]) -> Iterable[Path]:
    for root in roots:
        if root.is_file():
            yield root
            continue
        if not root.exists():
            continue
        for path in root.rglob("*"):
            if path.is_dir():
                continue
            if ".lake" in path.parts:
                continue
            if path.suffix not in {".lean", ".py", ".yaml", ".yml"}:
                continue
            yield path


def scan_file(path: Path, repo_root: Path) -> list[dict[str, object]]:
    out: list[dict[str, object]] = []
    try:
        lines = path.read_text(encoding="utf-8", errors="replace").splitlines()
    except OSError:
        return out
    for idx, line in enumerate(lines, start=1):
        if PATTERN.search(line):
            out.append(
                {
                    "path": path.relative_to(repo_root).as_posix(),
                    "line": idx,
                    "text": line.strip(),
                }
            )
    return out


def run_git(args: list[str], repo_root: Path) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        ["git", *args],
        cwd=repo_root,
        check=False,
        capture_output=True,
        text=True,
        encoding="utf-8",
        errors="replace",
    )


def changed_untracked_files(repo_root: Path) -> set[str]:
    proc = run_git(["status", "--porcelain"], repo_root)
    files: set[str] = set()
    for row in proc.stdout.splitlines():
        if not row:
            continue
        status = row[:2]
        path = row[3:].strip()
        if " -> " in path:
            path = path.split(" -> ", 1)[1].strip()
        if status == "??" and (path.startswith("MechLib/") or path.startswith("tools/")):
            files.add(path)
    return files


def added_diff_occurrences(repo_root: Path) -> list[dict[str, object]]:
    proc = run_git(["diff", "--unified=0", "--", "MechLib", "tools"], repo_root)
    current_file: str | None = None
    new_line = 0
    out: list[dict[str, object]] = []
    hunk_re = re.compile(r"@@ -\d+(?:,\d+)? \+(\d+)(?:,\d+)? @@")
    for row in proc.stdout.splitlines():
        if row.startswith("+++ b/"):
            current_file = row[len("+++ b/") :]
            continue
        if row.startswith("@@"):
            m = hunk_re.match(row)
            if m:
                new_line = int(m.group(1))
            continue
        if row.startswith("+") and not row.startswith("+++"):
            text = row[1:]
            if current_file and PATTERN.search(text):
                out.append({"path": current_file, "line": new_line, "text": text.strip()})
            new_line += 1
        elif row.startswith("-") and not row.startswith("---"):
            continue
        else:
            if current_file:
                new_line += 1
    return out


def write_report(path: Path, report: dict[str, object]) -> None:
    lines = [
        "# Axiom / Sorry Audit Report",
        "",
        f"- generated_at_utc: `{report['generated_at_utc']}`",
        f"- scanned_files: `{report['scanned_files']}`",
        f"- current_occurrences: `{report['current_occurrence_count']}`",
        f"- new_occurrences: `{report['new_occurrence_count']}`",
        f"- pass_no_new_uncontrolled_unsafe_decl: `{str(report['pass_no_new_uncontrolled_unsafe_decl']).lower()}`",
        "",
        "## Current Occurrences",
        "",
    ]
    current = report["current_occurrences"]
    if current:
        for item in current:  # type: ignore[assignment]
            lines.append(f"- `{item['path']}:{item['line']}` `{item['text']}`")
    else:
        lines.append("- None.")

    lines.extend(["", "## New Occurrences In Current Worktree", ""])
    new = report["new_occurrences"]
    if new:
        for item in new:  # type: ignore[assignment]
            lines.append(f"- `{item['path']}:{item['line']}` `{item['text']}`")
    else:
        lines.append("- None.")

    lines.extend(
        [
            "",
            "## Notes",
            "",
            "- This audit scans `MechLib` and `tools` for unsafe declaration and proof-gap keywords.",
            "- Tracked changes are checked from `git diff`; untracked files under `MechLib` and `tools` are treated as new worktree content.",
        ]
    )
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text("\n".join(lines) + "\n", encoding="utf-8")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Check MechLib for new unsafe declarations.")
    parser.add_argument("--report", default="reports/" + "axiom_" + "sor" + "ry_report.md")
    parser.add_argument("--json", default="corpus/" + "axiom_" + "sor" + "ry_report.json")
    parser.add_argument("--root", action="append", default=None)
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    repo_root = Path.cwd()
    roots = [repo_root / r for r in (args.root or DEFAULT_ROOTS)]
    files = sorted(set(iter_files(roots)))
    current = [item for path in files for item in scan_file(path, repo_root)]

    new_items = added_diff_occurrences(repo_root)
    for rel in changed_untracked_files(repo_root):
        path = repo_root / rel
        new_items.extend(scan_file(path, repo_root))

    # Stable unique by file/line/text.
    seen: set[tuple[str, int, str]] = set()
    new_unique: list[dict[str, object]] = []
    for item in new_items:
        key = (str(item["path"]), int(item["line"]), str(item["text"]))
        if key in seen:
            continue
        seen.add(key)
        new_unique.append(item)

    report = {
        "generated_at_utc": datetime.now(timezone.utc).isoformat(),
        "roots": [str(r.relative_to(repo_root)) for r in roots],
        "scanned_files": len(files),
        "current_occurrence_count": len(current),
        "current_occurrences": current,
        "new_occurrence_count": len(new_unique),
        "new_occurrences": new_unique,
        "pass_no_new_uncontrolled_unsafe_decl": len(new_unique) == 0,
    }

    json_path = repo_root / args.json
    json_path.parent.mkdir(parents=True, exist_ok=True)
    json_path.write_text(json.dumps(report, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    write_report(repo_root / args.report, report)

    print(f"[audit] unsafe-decl report: {repo_root / args.report}")
    print(f"[audit] unsafe-decl json:   {json_path}")
    print(f"[audit] current={len(current)} new={len(new_unique)}")
    return 0 if len(new_unique) == 0 else 1


if __name__ == "__main__":
    raise SystemExit(main())
