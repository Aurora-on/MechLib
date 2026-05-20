#!/usr/bin/env python3
"""
Export MechLib Spec-layer corpora for planning and retrieval.

The Spec layer is metadata only. These corpora are not proof inputs.
"""

from __future__ import annotations

import argparse
import collections
import json
import subprocess
import tempfile
from pathlib import Path
from typing import Any, Iterable


MARKERS = {
    "concepts": "__MECHLIB_CONCEPTS__",
    "laws": "__MECHLIB_LAWS__",
    "problems": "__MECHLIB_PROBLEMS__",
    "coverage": "__MECHLIB_COVERAGE__",
    "modules": "__MECHLIB_MODULES__",
}

STATUS_VALUES = {"verified", "schema", "alias", "experimental", "todo"}
MODULE_STATUS_VALUES = {"verified", "schema", "interface", "experimental", "todo"}
TRUST_VALUES = {"core", "derived", "interface", "example"}

REQUIRED_COVERAGE_TOPICS = {
    "foundation.dimensions",
    "foundation.quantity",
    "foundation.vector_quantity",
    "foundation.si_units",
    "foundation.reference_frame",
    "foundation.coordinate_system",
    "foundation.geometry",
    "statics.force_system",
    "statics.moment",
    "statics.couple",
    "statics.equilibrium",
    "statics.constraint_force",
    "statics.friction",
    "statics.truss",
    "kinematics.point_motion",
    "kinematics.coordinate_motion",
    "kinematics.relative_motion",
    "kinematics.rigid_body_motion",
    "kinematics.planar_motion",
    "kinematics.fixed_axis_rotation",
    "dynamics.newton_law",
    "dynamics.particle_dynamics",
    "dynamics.system_dynamics",
    "dynamics.momentum",
    "dynamics.angular_momentum",
    "dynamics.work_energy",
    "dynamics.impulse",
    "dynamics.collision",
    "dynamics.non_inertial_frame",
    "dynamics.variable_mass",
    "rigidbody.inertia",
    "rigidbody.fixed_axis_dynamics",
    "rigidbody.plane_motion_dynamics",
    "rigidbody.euler_equations",
    "rigidbody.gyroscope",
    "analytical.generalized_coordinates",
    "analytical.constraints",
    "analytical.virtual_work",
    "analytical.dalembert_principle",
    "analytical.lagrange_equation",
    "analytical.hamiltonian",
    "analytical.poisson_bracket",
    "analytical.conservation_law",
    "analytical.small_oscillations",
    "systems.harmonic_oscillator",
    "systems.damped_oscillator",
    "systems.pendulum",
    "systems.physical_pendulum",
    "systems.central_force",
    "systems.atwood_machine",
    "systems.coupled_oscillator",
    "systems.rolling_disk",
    "systems.bead_on_hoop",
}

REQUIRED_CONCEPT_IDS = {
    "concept.force_system",
    "concept.moment",
    "concept.generalized_coordinates",
    "concept.virtual_displacement",
    "concept.lagrangian",
    "concept.cyclic_coordinate",
    "concept.constraints",
    "concept.kinetic_energy",
    "concept.potential_energy",
}

REQUIRED_LAW_IDS = {
    "law.statics.planar_force_system_equilibrium",
    "law.dynamics.newton_second_law",
    "law.dynamics.work_energy_theorem",
    "law.analytical.virtual_work_principle",
    "law.analytical.dalembert_principle",
    "law.analytical.euler_lagrange_equation",
    "law.analytical.hamilton_canonical_equations",
    "law.dynamics.angular_momentum_conservation",
    "law.analytical.small_oscillation_equation",
}

REQUIRED_PROBLEM_IDS = {
    "problem.statics.planar_equilibrium",
    "problem.kinematics.uniform_acceleration_point_motion",
    "problem.dynamics.particle_dynamics",
    "problem.dynamics.work_energy_find_speed",
    "problem.systems.pendulum_lagrangian",
    "problem.systems.central_force_angular_momentum",
    "problem.systems.coupled_oscillator_normal_modes",
    "problem.systems.atwood_constraint_modeling",
}

CONCEPT_FIELDS = {
    "id",
    "zh_name",
    "en_name",
    "description",
    "aliases_zh",
    "aliases_en",
    "tags",
    "prerequisites",
    "related_laws",
    "related_problem_schemas",
}

LAW_FIELDS = {
    "id",
    "zh_name",
    "en_name",
    "statement_text",
    "formal_prop_name",
    "status",
    "prerequisites",
    "used_for",
    "verified_decls",
    "schema_decls",
}

PROBLEM_FIELDS = {
    "id",
    "topic",
    "input_objects",
    "target_objects",
    "modeling_steps",
    "candidate_laws",
    "expected_lean_objects",
    "verified_decls",
    "schema_decls",
}

MODULE_FIELDS = {
    "module_path",
    "topic_id",
    "status",
    "trust_level",
    "concept_ids",
    "law_schema_ids",
    "problem_schema_ids",
    "example_problems",
    "notes",
}


def run_lean_export(repo_root: Path) -> dict[str, Any]:
    build = subprocess.run(
        ["lake", "build", "MechLib"],
        cwd=repo_root,
        check=False,
        capture_output=True,
        text=True,
        encoding="utf-8",
        errors="replace",
    )
    if build.returncode != 0:
        raise RuntimeError(
            "Lean build failed before Spec export\n"
            f"stdout:\n{build.stdout}\n"
            f"stderr:\n{build.stderr}"
        )

    code = """
import MechLib
#eval IO.println ("__MECHLIB_CONCEPTS__" ++ MechLib.Spec.Concept.conceptSpecsJson.compress)
#eval IO.println ("__MECHLIB_LAWS__" ++ MechLib.Spec.LawSchema.lawSchemasJson.compress)
#eval IO.println ("__MECHLIB_PROBLEMS__" ++ MechLib.Spec.ProblemSchema.problemSchemasJson.compress)
#eval IO.println ("__MECHLIB_COVERAGE__" ++ MechLib.Spec.Coverage.coverageMatrixJson.compress)
#eval IO.println ("__MECHLIB_MODULES__" ++ MechLib.Spec.ModuleCatalog.moduleMetadataJson.compress)
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
            "Lean Spec export failed\n"
            f"stdout:\n{proc.stdout}\n"
            f"stderr:\n{proc.stderr}"
        )

    out: dict[str, Any] = {}
    for raw in proc.stdout.splitlines():
        line = raw.strip()
        for key, marker in MARKERS.items():
            if line.startswith(marker):
                out[key] = json.loads(line[len(marker) :])
    missing = sorted(set(MARKERS) - set(out))
    if missing:
        raise RuntimeError(f"Lean Spec export missed sections: {missing}")
    return out


def require_fields(row: dict[str, Any], fields: set[str], collection: str) -> None:
    missing = sorted(fields - set(row))
    if missing:
        raise ValueError(f"{collection} row {row.get('id', '<unknown>')} missing fields: {missing}")


def require_list(row: dict[str, Any], field: str, collection: str) -> None:
    value = row.get(field)
    if not isinstance(value, list) or not all(isinstance(item, str) for item in value):
        raise ValueError(f"{collection} row {row.get('id', '<unknown>')}.{field} must be a list of strings")


def validate_decl_split(row: dict[str, Any], collection: str) -> None:
    verified = set(row.get("verified_decls") or [])
    schema = set(row.get("schema_decls") or [])
    overlap = sorted(verified.intersection(schema))
    if overlap:
        raise ValueError(f"{collection} row {row.get('id', '<unknown>')} mixes verified/schema decls: {overlap}")


def validate_export(data: dict[str, Any]) -> dict[str, Any]:
    concepts = data["concepts"]
    laws = data["laws"]
    problems = data["problems"]
    coverage = data["coverage"]
    modules = data["modules"]

    if not all(isinstance(x, dict) for x in concepts):
        raise ValueError("concepts must be a list of objects")
    if not all(isinstance(x, dict) for x in laws):
        raise ValueError("laws must be a list of objects")
    if not all(isinstance(x, dict) for x in problems):
        raise ValueError("problems must be a list of objects")
    if not all(isinstance(x, dict) for x in modules):
        raise ValueError("modules must be a list of objects")

    for row in concepts:
        require_fields(row, CONCEPT_FIELDS, "concept")
        for field in ("aliases_zh", "aliases_en", "tags", "prerequisites", "related_laws", "related_problem_schemas"):
            require_list(row, field, "concept")

    for row in laws:
        require_fields(row, LAW_FIELDS, "law")
        if row["status"] not in STATUS_VALUES:
            raise ValueError(f"law row {row['id']} has invalid status: {row['status']}")
        for field in ("prerequisites", "used_for", "verified_decls", "schema_decls"):
            require_list(row, field, "law")
        validate_decl_split(row, "law")

    for row in problems:
        require_fields(row, PROBLEM_FIELDS, "problem")
        for field in (
            "input_objects",
            "target_objects",
            "modeling_steps",
            "candidate_laws",
            "expected_lean_objects",
            "verified_decls",
            "schema_decls",
        ):
            require_list(row, field, "problem")
        validate_decl_split(row, "problem")

    for row in modules:
        require_fields(row, MODULE_FIELDS, "module")
        if row["status"] not in MODULE_STATUS_VALUES:
            raise ValueError(f"module row {row.get('module_path', '<unknown>')} has invalid status: {row['status']}")
        if row["trust_level"] not in TRUST_VALUES:
            raise ValueError(f"module row {row.get('module_path', '<unknown>')} has invalid trust_level: {row['trust_level']}")
        for field in ("concept_ids", "law_schema_ids", "problem_schema_ids", "example_problems", "notes"):
            require_list(row, field, "module")

    chapters = coverage.get("chapters")
    if not isinstance(chapters, list):
        raise ValueError("coverage.chapters must be a list")
    topics = [topic for chapter in chapters for topic in chapter.get("topics", [])]
    topic_ids = {topic.get("id") for topic in topics}
    missing_topics = sorted(REQUIRED_COVERAGE_TOPICS - topic_ids)
    if missing_topics:
        raise ValueError(f"coverage matrix missing required topics: {missing_topics}")
    for topic in topics:
        if topic.get("status") not in STATUS_VALUES:
            raise ValueError(f"coverage topic {topic.get('id')} has invalid status")
        if topic.get("trust_level") not in TRUST_VALUES:
            raise ValueError(f"coverage topic {topic.get('id')} has invalid trust_level")
        validate_decl_split(topic, "coverage")

    alias_both_count = sum(bool(topic.get("aliases_zh")) and bool(topic.get("aliases_en")) for topic in topics)
    alias_coverage_ratio = alias_both_count / max(1, len(topics))
    if alias_coverage_ratio < 0.8:
        raise ValueError(f"coverage alias ratio too low: {alias_coverage_ratio:.3f}")

    for required, ids, collection in [
        (REQUIRED_CONCEPT_IDS, {row["id"] for row in concepts}, "concept"),
        (REQUIRED_LAW_IDS, {row["id"] for row in laws}, "law"),
        (REQUIRED_PROBLEM_IDS, {row["id"] for row in problems}, "problem"),
    ]:
        missing = sorted(required - ids)
        if missing:
            raise ValueError(f"{collection} corpus missing required rows: {missing}")

    status_counts = collections.Counter(topic["status"] for topic in topics)
    trust_counts = collections.Counter(topic["trust_level"] for topic in topics)
    law_status_counts = collections.Counter(row["status"] for row in laws)
    module_status_counts = collections.Counter(row["status"] for row in modules)

    return {
        "coverage": {
            "chapter_count": len(chapters),
            "topic_count": len(topics),
            "status_distribution": dict(sorted(status_counts.items())),
            "trust_distribution": dict(sorted(trust_counts.items())),
            "alias_both_count": alias_both_count,
            "alias_coverage_ratio": round(alias_coverage_ratio, 6),
        },
        "spec": {
            "concept_count": len(concepts),
            "law_count": len(laws),
            "problem_schema_count": len(problems),
            "module_metadata_count": len(modules),
            "law_status_distribution": dict(sorted(law_status_counts.items())),
            "module_status_distribution": dict(sorted(module_status_counts.items())),
        },
        "proof_safety": {
            "schema_corpus_for_planning_only": True,
            "proving_requires_verified_decl_corpus": True,
        },
    }


def write_jsonl(path: Path, rows: Iterable[dict[str, Any]]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", encoding="utf-8", newline="\n") as f:
        for row in rows:
            f.write(json.dumps(row, ensure_ascii=False) + "\n")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Export MechLib Spec-layer corpora.")
    parser.add_argument("--out-dir", default="corpus")
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    repo_root = Path.cwd()
    out_dir = (repo_root / args.out_dir).resolve()

    data = run_lean_export(repo_root)
    report = validate_export(data)

    write_jsonl(out_dir / "concept_corpus.jsonl", data["concepts"])
    write_jsonl(out_dir / "law_schema_corpus.jsonl", data["laws"])
    write_jsonl(out_dir / "problem_schema_corpus.jsonl", data["problems"])
    write_jsonl(out_dir / "module_metadata_corpus.jsonl", data["modules"])
    (out_dir / "spec_export_report.json").write_text(
        json.dumps(report, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )

    print(f"[export] concept corpus: {out_dir / 'concept_corpus.jsonl'} ({len(data['concepts'])} rows)")
    print(f"[export] law schema corpus: {out_dir / 'law_schema_corpus.jsonl'} ({len(data['laws'])} rows)")
    print(f"[export] problem schema corpus: {out_dir / 'problem_schema_corpus.jsonl'} ({len(data['problems'])} rows)")
    print(f"[export] module metadata corpus: {out_dir / 'module_metadata_corpus.jsonl'} ({len(data['modules'])} rows)")
    print(f"[export] report: {out_dir / 'spec_export_report.json'}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
