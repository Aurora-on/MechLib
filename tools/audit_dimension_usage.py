#!/usr/bin/env python3
"""Audit dimension-system usage in MechLib.

This script is a reporting tool. It does not rewrite Lean files and it does
not treat every `ℝ` occurrence as an error. The goal is to preserve the
dimensioned `Quantity` / `VecQuantity` / `SI` design by making untyped public
physics surfaces visible for later migration.
"""

from __future__ import annotations

import argparse
import collections
import json
import re
from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Iterable


CORE_IMPORTS = [
    "MechLib.Units.Dim",
    "MechLib.Units.Quantity",
    "MechLib.Units.VecQuantity",
    "MechLib.SI",
]

CORE_FILES = [
    "MechLib/Units/Dim.lean",
    "MechLib/Units/Quantity.lean",
    "MechLib/Units/VecQuantity.lean",
    "MechLib/SI.lean",
]

COURSE_DIRS = [
    "MechLib/Foundation",
    "MechLib/Statics",
    "MechLib/Kinematics",
    "MechLib/Dynamics",
    "MechLib/RigidBody",
    "MechLib/Analytical",
    "MechLib/Systems",
]

PHYSICAL_ALIAS_NAMES = {
    "Length",
    "Mass",
    "Time",
    "Speed",
    "Acceleration",
    "Momentum",
    "Force",
    "Energy",
    "Power",
    "Torque",
    "AngularVelocity",
    "AngularAcceleration",
    "MomentOfInertia",
    "SpringConstant",
    "Frequency",
    "DampingCoefficient",
    "Dimensionless",
    "PhysAngle",
}

CANONICAL_ALIAS_FILE = Path("MechLib/SI.lean")
WRAPPER_ALIAS_FILES = {Path("MechLib/Foundation/SI.lean")}
COMPAT_ALIAS_FILES = {Path("MechLib/Compat/PHYSlib.lean")}

REAL_TOKEN = "ℝ"
DECL_RE = re.compile(r"^\s*(?:noncomputable\s+)?(def|abbrev|structure|inductive|theorem|lemma|example)\b")
ALIAS_RE = re.compile(r"^\s*abbrev\s+([A-Za-z0-9_']+)\s*(?::[^:=]+)?\s*:=\s*(.+?)\s*$")
TASK55_BASELINE_UNTYPED_COURSE_API_COUNT = 30
KNOWN_TEMPORARY_FALLBACK_NAMES = {
    "kineticEnergyValue",
    "potentialEnergyValue",
    "lagrangianValue",
    "effectivePotentialScalar",
    "quadraticFormValue",
}


@dataclass(frozen=True)
class RealOccurrence:
    path: str
    line: int
    text: str
    classification: str
    reason: str
    severity: str

    def to_json(self) -> dict[str, Any]:
        return {
            "path": self.path,
            "line": self.line,
            "text": self.text,
            "classification": self.classification,
            "reason": self.reason,
            "severity": self.severity,
        }


def rel(path: Path, root: Path) -> str:
    try:
        return path.relative_to(root).as_posix()
    except ValueError:
        return path.as_posix()


def read_text(path: Path) -> str:
    return path.read_text(encoding="utf-8", errors="replace")


def iter_lean_files(repo_root: Path, roots: Iterable[str]) -> list[Path]:
    files: list[Path] = []
    for item in roots:
        root = repo_root / item
        if root.is_file():
            files.append(root)
        elif root.exists():
            files.extend(sorted(root.rglob("*.lean")))
    return sorted(set(files))


def previous_noncomment_line(lines: list[str], idx: int) -> str:
    for j in range(idx - 1, -1, -1):
        stripped = lines[j].strip()
        if not stripped or stripped.startswith("--"):
            continue
        return stripped
    return ""


def is_public_decl_line(line: str, previous: str) -> bool:
    if DECL_RE.match(line):
        return True
    if line.strip().startswith("|"):
        return False
    if previous.startswith("structure ") or previous.endswith(" where"):
        return ":" in line and REAL_TOKEN in line
    return False


def classify_real_line(path: str, line: str, previous: str) -> tuple[str, str, str]:
    stripped = line.strip()
    lower = stripped.lower()
    path_lower = path.lower()
    fallback_hit = any(name in stripped or name in previous for name in KNOWN_TEMPORARY_FALLBACK_NAMES)

    if fallback_hit:
        return (
            "temporary_untyped_fallback",
            "explicit compatibility value-level wrapper retained beside a typed public API",
            "fallback",
        )

    if path.startswith("MechLib/Units/") or path == "MechLib/SI.lean":
        return ("core_dimension_infrastructure", "core Quantity/VecQuantity/SI numeric carrier or scale factor", "allowed")

    if "moduleMetadata" in stripped or "notes :=" in stripped:
        return ("metadata", "metadata text or module metadata", "allowed")

    if "Matrix" in stripped or "Fin " in stripped or "Fin." in stripped or "massMatrix" in stripped or "stiffnessMatrix" in stripped:
        return ("matrix_or_index_value", "matrix entries, finite indices, or linear algebra chart values", "allowed")

    if "(0 : Dim)" in stripped or "Dimensionless" in stripped or "dimensionless" in lower:
        return ("dimensionless", "explicitly dimensionless value", "allowed")

    if ".val" in stripped:
        if re.search(r"\b(kineticEnergy|potentialEnergy|lagrangian|effectivePotential|angularMomentum|period|accelerationFormula)\b", stripped):
            return (
                "temporary_value_level_physics",
                "public physics formula uses .val and returns or accepts raw Real values; candidate for typed Quantity migration",
                "review",
            )
        return ("value_projection", "explicit Quantity/VecQuantity .val extraction", "allowed")

    if re.search(r"\b(coefficient|ratio|factor|scale|multiplier|omegaSq|frequencySquared)\b", lower):
        return ("dimensionless_or_parameter", "coefficient/ratio/frequency-squared schema parameter", "allowed")

    if re.search(r"\b(theta|angle|sin|cos|tan|phase)\b", lower):
        return ("angle_chart_value", "angle or trigonometric coordinate chart value", "allowed")

    if re.search(r"\b(time|trajectory|t\s*:|∀ t|\\s*t\\b)\b", lower) or "ℝ →" in stripped:
        if "MechLib.SI." in stripped or "Quantity" in stripped or "VecQuantity" in stripped or "GCoord" in stripped or "GVel" in stripped:
            return ("time_parameter_with_typed_output", "Real is the mathematical time parameter for typed trajectories", "allowed")

    if re.search(r"\b(q|qdot|qddot|x1|x2|radius|raddot|centerSpeed|angularVelocity)\b", stripped):
        return (
            "coordinate_chart_or_temporary_untyped",
            "coordinate chart value or temporary untyped fallback; should be documented or migrated when exposed as physics API",
            "review",
        )

    if is_public_decl_line(stripped, previous):
        return (
            "public_real_api_review",
            "public declaration exposes raw Real; confirm dimensionless/chart semantics or migrate to SI Quantity/VecQuantity",
            "review",
        )

    return ("math_helper_or_local_value", "local mathematical helper, scalar literal, or proof-level value", "allowed")


def audit_core(repo_root: Path) -> dict[str, Any]:
    top_path = repo_root / "MechLib.lean"
    top_text = read_text(top_path) if top_path.exists() else ""
    files = []
    for file in CORE_FILES:
        path = repo_root / file
        files.append({"path": file, "exists": path.exists()})
    imports = []
    for imp in CORE_IMPORTS:
        imports.append(
            {
                "import": imp,
                "present_in_MechLib_lean": f"import {imp}" in top_text,
            }
        )
    return {
        "required_files": files,
        "required_imports": imports,
        "all_core_files_present": all(row["exists"] for row in files),
        "all_core_imports_present": all(row["present_in_MechLib_lean"] for row in imports),
    }


def audit_aliases(repo_root: Path) -> dict[str, Any]:
    rows: list[dict[str, Any]] = []
    for file_path in iter_lean_files(repo_root, ["MechLib"]):
        rel_path = Path(rel(file_path, repo_root))
        for line_no, line in enumerate(read_text(file_path).splitlines(), start=1):
            m = ALIAS_RE.match(line)
            if not m:
                continue
            name = m.group(1)
            if name not in PHYSICAL_ALIAS_NAMES:
                continue
            rhs = m.group(2).strip()
            if rel_path == CANONICAL_ALIAS_FILE:
                classification = "canonical_si_alias"
                severity = "allowed"
            elif rel_path in WRAPPER_ALIAS_FILES and rhs.startswith("MechLib.SI."):
                classification = "course_layer_forwarding_alias"
                severity = "allowed"
            elif rel_path in COMPAT_ALIAS_FILES and rhs.startswith("MechLib.SI."):
                classification = "compat_forwarding_alias"
                severity = "allowed"
            else:
                classification = "possible_duplicate_physical_alias"
                severity = "review"
            rows.append(
                {
                    "name": name,
                    "path": rel_path.as_posix(),
                    "line": line_no,
                    "rhs": rhs,
                    "classification": classification,
                    "severity": severity,
                }
            )
    return {
        "aliases": rows,
        "canonical_count": sum(row["classification"] == "canonical_si_alias" for row in rows),
        "forwarding_wrapper_count": sum(row["classification"] == "course_layer_forwarding_alias" for row in rows),
        "compat_forwarding_count": sum(row["classification"] == "compat_forwarding_alias" for row in rows),
        "review_count": sum(row["severity"] == "review" for row in rows),
    }


def audit_real_usage(repo_root: Path) -> dict[str, Any]:
    occurrences: list[RealOccurrence] = []
    files = iter_lean_files(repo_root, COURSE_DIRS)
    for file_path in files:
        rel_path = rel(file_path, repo_root)
        lines = read_text(file_path).splitlines()
        for idx, line in enumerate(lines):
            if REAL_TOKEN not in line:
                continue
            previous = previous_noncomment_line(lines, idx)
            classification, reason, severity = classify_real_line(rel_path, line, previous)
            occurrences.append(
                RealOccurrence(
                    path=rel_path,
                    line=idx + 1,
                    text=line.strip(),
                    classification=classification,
                    reason=reason,
                    severity=severity,
                )
            )

    by_class = collections.Counter(item.classification for item in occurrences)
    by_file_review = collections.Counter(item.path for item in occurrences if item.severity == "review")
    by_file_fallback = collections.Counter(item.path for item in occurrences if item.severity == "fallback")
    review_count = sum(item.severity == "review" for item in occurrences)
    fallback_count = sum(item.severity == "fallback" for item in occurrences)
    return {
        "files_scanned": len(files),
        "real_occurrence_count": len(occurrences),
        "allowed_count": sum(item.severity == "allowed" for item in occurrences),
        "fallback_count": fallback_count,
        "review_count": review_count,
        "untyped_course_api_count": review_count,
        "task55_baseline_untyped_course_api_count": TASK55_BASELINE_UNTYPED_COURSE_API_COUNT,
        "fixed_since_task55_count": max(0, TASK55_BASELINE_UNTYPED_COURSE_API_COUNT - review_count),
        "classification_distribution": dict(sorted(by_class.items())),
        "review_by_file": dict(sorted(by_file_review.items())),
        "fallback_by_file": dict(sorted(by_file_fallback.items())),
        "review_items": [item.to_json() for item in occurrences if item.severity == "review"],
        "fallback_items": [item.to_json() for item in occurrences if item.severity == "fallback"],
    }


def audit_exporter(repo_root: Path, theorem_corpus: Path) -> dict[str, Any]:
    path = theorem_corpus if theorem_corpus.is_absolute() else repo_root / theorem_corpus
    module_counts: dict[str, int] = {}
    unit_si_rows: list[dict[str, Any]] = []
    if path.exists():
        with path.open("r", encoding="utf-8", errors="replace") as f:
            for raw in f:
                if not raw.strip():
                    continue
                row = json.loads(raw)
                module = str(row.get("module") or "")
                if module.startswith("MechLib.Units") or module == "MechLib.SI":
                    module_counts[module] = module_counts.get(module, 0) + 1
                    if len(unit_si_rows) < 20:
                        unit_si_rows.append(
                            {
                                "fq_name": row.get("fq_name"),
                                "module": module,
                                "source_path": row.get("source_path"),
                                "source_line": row.get("source_line"),
                            }
                        )
    total = sum(module_counts.values())
    return {
        "theorem_corpus": rel(path, repo_root),
        "theorem_corpus_exists": path.exists(),
        "units_si_decl_count": total,
        "module_counts": dict(sorted(module_counts.items())),
        "sample_units_si_decls": unit_si_rows,
        "exports_dimension_theorems": total > 0,
    }


def build_report(data: dict[str, Any]) -> str:
    real = data["course_layer_real_usage"]
    alias = data["physical_aliases"]
    core = data["core_dimension_modules"]
    exporter = data["exporter_dimension_decls"]
    review_items = real["review_items"]
    fallback_items = real["fallback_items"]

    lines = [
        "# MechLib Dimension Usage Audit",
        "",
        f"- generated_at_utc: `{data['generated_at_utc']}`",
        f"- core files present: `{core['all_core_files_present']}`",
        f"- core imports present in `MechLib.lean`: `{core['all_core_imports_present']}`",
        f"- course-layer files scanned: `{real['files_scanned']}`",
        f"- raw `ℝ` occurrences in course layer: `{real['real_occurrence_count']}`",
        f"- allowed/classified occurrences: `{real['allowed_count']}`",
        f"- temporary fallback occurrences: `{real['fallback_count']}`",
        f"- untyped course API review candidates: `{real['untyped_course_api_count']}`",
        f"- task 5.5 baseline untyped count: `{real['task55_baseline_untyped_course_api_count']}`",
        f"- fixed since task 5.5: `{real['fixed_since_task55_count']}`",
        f"- duplicate physical alias review count: `{alias['review_count']}`",
        f"- exported Units/SI theorem rows: `{exporter['units_si_decl_count']}`",
        "",
        "## Global Principle",
        "",
        "MechLib's core feature is the dimensioned physical quantity system. Public physics APIs should prefer `MechLib.SI` aliases, `Quantity`, and `VecQuantity`; raw `ℝ` should be limited to dimensionless coefficients, mathematical indices, chart coordinates, `.val` projections, metadata, or explicitly documented temporary untyped fallbacks.",
        "",
        "## Core Dimension Modules",
        "",
    ]
    for row in core["required_files"]:
        lines.append(f"- `{row['path']}`: exists = `{row['exists']}`")
    lines.append("")
    for row in core["required_imports"]:
        lines.append(f"- `import {row['import']}` in `MechLib.lean`: `{row['present_in_MechLib_lean']}`")

    lines.extend(["", "## Physical Type Alias Audit", ""])
    lines.append(f"- canonical SI aliases: `{alias['canonical_count']}`")
    lines.append(f"- forwarding wrapper aliases: `{alias['forwarding_wrapper_count']}`")
    lines.append(f"- compat forwarding aliases: `{alias['compat_forwarding_count']}`")
    lines.append(f"- review aliases: `{alias['review_count']}`")
    review_aliases = [row for row in alias["aliases"] if row["severity"] == "review"]
    if review_aliases:
        lines.extend(["", "| Alias | File | Line | RHS |", "| --- | --- | ---: | --- |"])
        for row in review_aliases:
            lines.append(f"| `{row['name']}` | `{row['path']}` | {row['line']} | `{row['rhs']}` |")
    else:
        lines.append("")
        lines.append("No suspicious duplicate physical aliases were found.")

    lines.extend(["", "## Course-Layer `ℝ` Classification", ""])
    lines.extend(["| Classification | Count |", "| --- | ---: |"])
    for key, count in real["classification_distribution"].items():
        lines.append(f"| `{key}` | {count} |")

    lines.extend(["", "## Typed Migration Highlights", ""])
    for item in data["typed_migration_highlights"]:
        lines.append(f"- {item}")

    lines.extend(["", "## Temporary Untyped Fallbacks", ""])
    if fallback_items:
        lines.extend(["| File | Line | Code | Reason |", "| --- | ---: | --- | --- |"])
        for row in fallback_items:
            code = str(row["text"]).replace("|", "\\|")
            lines.append(f"| `{row['path']}` | {row['line']} | `{code}` | {row['reason']} |")
    else:
        lines.append("No explicit temporary untyped fallbacks were found.")

    lines.extend(["", "## Review Candidates By File", ""])
    if real["review_by_file"]:
        lines.extend(["| File | Count |", "| --- | ---: |"])
        for path, count in real["review_by_file"].items():
            lines.append(f"| `{path}` | {count} |")
    else:
        lines.append("No review candidates were found.")

    lines.extend(["", "## Review Candidate Details", ""])
    if review_items:
        lines.extend(["| File | Line | Classification | Code |", "| --- | ---: | --- | --- |"])
        for row in review_items[:120]:
            code = str(row["text"]).replace("|", "\\|")
            lines.append(f"| `{row['path']}` | {row['line']} | `{row['classification']}` | `{code}` |")
        if len(review_items) > 120:
            lines.append(f"| ... | ... | ... | {len(review_items) - 120} additional rows omitted from Markdown; see JSON report. |")
    else:
        lines.append("No review candidates were found.")

    lines.extend(["", "## Exporter Check", ""])
    lines.append(f"- theorem corpus: `{exporter['theorem_corpus']}`")
    lines.append(f"- exists: `{exporter['theorem_corpus_exists']}`")
    lines.append(f"- exports dimension theorem rows: `{exporter['exports_dimension_theorems']}`")
    lines.extend(["", "| Module | Rows |", "| --- | ---: |"])
    for module, count in exporter["module_counts"].items():
        lines.append(f"| `{module}` | {count} |")

    lines.extend(["", "## Recommendations", ""])
    for item in data["recommendations"]:
        lines.append(f"- {item}")
    lines.append("")
    return "\n".join(lines)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Audit MechLib dimension-system usage.")
    parser.add_argument("--json-out", default="corpus/dimension_audit_report.json")
    parser.add_argument("--md-out", default="reports/dimension_audit_report.md")
    parser.add_argument("--theorem-corpus", default="corpus/theorem_corpus.jsonl")
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    repo_root = Path.cwd()

    data: dict[str, Any] = {
        "generated_at_utc": datetime.now(timezone.utc).isoformat(),
        "repo_root": str(repo_root),
        "policy": {
            "core_feature": "dimensioned physical quantities",
            "preferred_public_api": ["MechLib.SI aliases", "MechLib.Units.Quantity", "MechLib.Units.VecQuantity"],
            "allowed_raw_real_uses": [
                "dimensionless coefficient",
                "scalar multiplier",
                "matrix index or matrix entry",
                "vector component after explicit .val extraction",
                "metadata",
                "mathematical helper lemma",
                "explicit dimensionless variable",
                "coordinate chart value with documented semantics",
                "temporary untyped fallback marked for review",
            ],
        },
        "core_dimension_modules": audit_core(repo_root),
        "physical_aliases": audit_aliases(repo_root),
        "course_layer_real_usage": audit_real_usage(repo_root),
        "exporter_dimension_decls": audit_exporter(repo_root, Path(args.theorem_corpus)),
        "typed_migration_highlights": [
            "Pendulum: `kineticEnergy`, `potentialEnergy`, `lagrangian`, `equationResidual`, and `smallAngle_to_SHM` now use `Energy`, `PhysAngle`, `AngularVelocity`, `AngularAcceleration`, and `Time`; value-level wrappers are retained as `...Value` fallbacks.",
            "CentralForce: `PolarState`, `kineticEnergyPolar`, `angularMomentum`, `effectivePotential`, circular-orbit conditions, and angular-momentum conservation now use `Length`, `Speed`, `AngularVelocity`, `Energy`, `AngularMomentum`, `Force`, `SpringConstant`, and `Time`; `effectivePotentialScalar` remains as a fallback.",
            "CoupledOscillator: mass and stiffness matrices now use `Mass` and `SpringConstant`; coordinates and velocities use `Length` and `Speed`; the Lagrangian returns `Energy`; normal-mode residual uses `AngularVelocitySquared`; `quadraticFormValue` remains as a scalar matrix helper.",
            "SI: added `AngularAcceleration` and `AngularVelocitySquared` aliases plus bridge lemmas for acceleration and spring-constant dimensions.",
        ],
        "recommendations": [
            "Keep `MechLib.Units.Dim`, `Quantity`, `VecQuantity`, and `MechLib.SI` imported by the top-level `MechLib.lean` entry.",
            "Do not add parallel `Length`, `Mass`, `Force`, `Energy`, or similar type aliases outside `MechLib.SI`; course modules may forward to `MechLib.SI` only when needed for ergonomics.",
            "Prioritize typed `MechLib.SI.Energy`, `Length`, `Mass`, `Force`, `Speed`, and `VecQuantity` signatures for new public physics APIs.",
            "When a system schema remains value-level, document whether each raw `ℝ` is a dimensionless coordinate, a chart value, a `.val` projection, or a temporary untyped fallback.",
            "Keep Units/SI theorem and bridge lemma rows in theorem and enriched declaration corpora for retrieval and statement generation.",
        ],
    }

    json_path = (repo_root / args.json_out).resolve()
    md_path = (repo_root / args.md_out).resolve()
    json_path.parent.mkdir(parents=True, exist_ok=True)
    md_path.parent.mkdir(parents=True, exist_ok=True)
    json_path.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    md_path.write_text(build_report(data), encoding="utf-8")

    real = data["course_layer_real_usage"]
    exporter = data["exporter_dimension_decls"]
    print(f"[audit] dimension report json: {json_path}")
    print(f"[audit] dimension report md:   {md_path}")
    print(
        "[audit] core_imports={core} units_si_exported={exported} real_review={review}".format(
            core=data["core_dimension_modules"]["all_core_imports_present"],
            exported=exporter["exports_dimension_theorems"],
            review=real["review_count"],
        )
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
