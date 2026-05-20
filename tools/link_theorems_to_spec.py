#!/usr/bin/env python3
"""
Align theorem/lemma declarations with MechLib Spec metadata.

This script is a corpus post-processor. It does not inspect or modify Lean
proof files. The output corpora are intended for retrieval and LLM planning;
`callable_by_llm` is only enabled for verified declarations in proof-safe trust
tiers with nonempty imports.
"""

from __future__ import annotations

import argparse
import collections
import json
import re
from pathlib import Path
from typing import Any, Iterable


STATUS_VALUES = {"verified", "schema", "alias", "experimental", "todo"}
TRUST_VALUES = {"core", "derived", "interface", "example"}
CALLABLE_TRUST = {"core", "derived"}
NEEDS_REVIEW_THRESHOLD = 0.50
CALLABLE_THRESHOLD = 0.55


def read_jsonl(path: Path) -> list[dict[str, Any]]:
    if not path.exists():
        raise FileNotFoundError(f"missing input JSONL: {path}")
    rows: list[dict[str, Any]] = []
    with path.open(encoding="utf-8") as f:
        for line_no, line in enumerate(f, 1):
            if not line.strip():
                continue
            row = json.loads(line)
            if not isinstance(row, dict):
                raise ValueError(f"{path}:{line_no} is not a JSON object")
            rows.append(row)
    return rows


def write_jsonl(path: Path, rows: Iterable[dict[str, Any]]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", encoding="utf-8", newline="\n") as f:
        for row in rows:
            f.write(json.dumps(row, ensure_ascii=False, sort_keys=True) + "\n")


def write_json(path: Path, value: Any) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(value, ensure_ascii=False, indent=2, sort_keys=True) + "\n", encoding="utf-8")


def scalar_yaml(value: str) -> Any:
    value = value.strip()
    if value in {"true", "True"}:
        return True
    if value in {"false", "False"}:
        return False
    if value in {"null", "None", "~"}:
        return None
    if value.startswith("[") and value.endswith("]"):
        inner = value[1:-1].strip()
        if not inner:
            return []
        return [scalar_yaml(part.strip()) for part in inner.split(",")]
    if (value.startswith('"') and value.endswith('"')) or (value.startswith("'") and value.endswith("'")):
        return value[1:-1]
    return value


def parse_simple_yaml(text: str) -> dict[str, dict[str, Any]]:
    data: dict[str, dict[str, Any]] = {}
    current_decl: str | None = None
    current_list_key: str | None = None
    for raw in text.splitlines():
        line = raw.rstrip()
        stripped = line.strip()
        if not stripped or stripped.startswith("#"):
            continue
        indent = len(line) - len(line.lstrip(" "))
        if indent == 0 and stripped.endswith(":"):
            current_decl = stripped[:-1]
            data[current_decl] = {}
            current_list_key = None
            continue
        if current_decl is None:
            raise ValueError(f"invalid override YAML line without declaration: {raw}")
        if indent == 2 and ":" in stripped:
            key, value = stripped.split(":", 1)
            key = key.strip()
            value = value.strip()
            if value == "":
                data[current_decl][key] = []
                current_list_key = key
            else:
                data[current_decl][key] = scalar_yaml(value)
                current_list_key = None
            continue
        if indent >= 4 and stripped.startswith("- "):
            if current_list_key is None:
                raise ValueError(f"list item without list key in override YAML: {raw}")
            data[current_decl].setdefault(current_list_key, []).append(scalar_yaml(stripped[2:]))
            continue
        raise ValueError(f"unsupported override YAML line: {raw}")
    return data


def load_overrides(path: Path) -> dict[str, dict[str, Any]]:
    if not path.exists():
        return {}
    text = path.read_text(encoding="utf-8")
    try:
        import yaml  # type: ignore

        loaded = yaml.safe_load(text) or {}
        if not isinstance(loaded, dict):
            raise ValueError("override file must be a mapping")
        return {str(k): dict(v or {}) for k, v in loaded.items()}
    except ModuleNotFoundError:
        return parse_simple_yaml(text)


def listify(value: Any) -> list[str]:
    if value is None:
        return []
    if isinstance(value, list):
        return [str(v) for v in value]
    return [str(value)]


def load_specs(
    coverage_path: Path,
    concept_path: Path,
    law_path: Path,
    problem_path: Path,
) -> tuple[dict[str, dict[str, Any]], dict[str, set[str]]]:
    coverage = json.loads(coverage_path.read_text(encoding="utf-8"))
    spec_rows: dict[str, dict[str, Any]] = {}
    groups: dict[str, set[str]] = {
        "coverage": set(),
        "concept": set(),
        "law": set(),
        "problem": set(),
    }
    for chapter in coverage.get("chapters", []):
        for topic in chapter.get("topics", []):
            spec_rows[topic["id"]] = topic
            groups["coverage"].add(topic["id"])
    for row in read_jsonl(concept_path):
        spec_rows[row["id"]] = row
        groups["concept"].add(row["id"])
    for row in read_jsonl(law_path):
        spec_rows[row["id"]] = row
        groups["law"].add(row["id"])
    for row in read_jsonl(problem_path):
        spec_rows[row["id"]] = row
        groups["problem"].add(row["id"])
    return spec_rows, groups


def normalize_text(row: dict[str, Any]) -> str:
    parts = [
        row.get("fq_name", ""),
        row.get("short_name", ""),
        row.get("module", ""),
        row.get("namespace", ""),
        row.get("statement", ""),
        " ".join(row.get("tags") or []),
        row.get("summary_en", ""),
        row.get("retrieval_text", ""),
    ]
    return "\n".join(str(p) for p in parts).lower()


def module_route(module: str) -> tuple[list[str], list[str], list[str], list[str]]:
    routes: list[tuple[str, list[str], list[str], list[str], list[str]]] = [
        ("MechLib.Units.Dim", ["foundation.dimensions"], [], [], []),
        ("MechLib.Units.Quantity", ["foundation.quantity"], [], [], []),
        ("MechLib.Units.VecQuantity", ["foundation.vector_quantity"], [], [], []),
        ("MechLib.Units.BridgeLemmas", ["foundation.dimensions", "foundation.quantity", "foundation.si_units"], [], [], []),
        ("MechLib.SI", ["foundation.si_units", "foundation.dimensions", "foundation.quantity"], [], [], []),
        ("MechLib.Mechanics.Kinematics", ["kinematics.point_motion", "kinematics.relative_motion"], [], [], ["problem.kinematics.uniform_acceleration_point_motion"]),
        ("MechLib.Mechanics.Dynamics", ["dynamics.newton_law", "dynamics.particle_dynamics"], ["concept.force_system"], ["law.dynamics.newton_second_law"], ["problem.dynamics.particle_dynamics"]),
        ("MechLib.Mechanics.WorkEnergy", ["dynamics.work_energy"], ["concept.kinetic_energy"], ["law.dynamics.work_energy_theorem"], ["problem.dynamics.work_energy_find_speed"]),
        ("MechLib.Mechanics.SystemDynamics", ["dynamics.system_dynamics", "dynamics.momentum"], [], [], ["problem.dynamics.particle_dynamics"]),
        ("MechLib.Mechanics.MomentumImpulse", ["dynamics.impulse", "dynamics.momentum"], [], [], ["problem.dynamics.particle_dynamics"]),
        ("MechLib.Mechanics.Rotation", ["rigidbody.fixed_axis_dynamics", "dynamics.angular_momentum", "statics.moment"], ["concept.moment"], ["law.dynamics.angular_momentum_conservation"], ["problem.systems.central_force_angular_momentum"]),
        ("MechLib.Mechanics.AnalyticalMechanics", ["analytical.lagrange_equation", "analytical.hamiltonian"], ["concept.generalized_coordinates", "concept.lagrangian"], ["law.analytical.euler_lagrange_equation"], ["problem.systems.pendulum_lagrangian"]),
        ("MechLib.Analytical.LagrangeEquation", ["analytical.lagrange_equation"], ["concept.generalized_coordinates", "concept.lagrangian"], ["law.analytical.euler_lagrange_equation"], ["problem.systems.pendulum_lagrangian"]),
        ("MechLib.Analytical.Hamiltonian", ["analytical.hamiltonian", "analytical.lagrange_equation"], ["concept.generalized_coordinates", "concept.lagrangian"], ["law.analytical.hamilton_canonical_equations"], ["problem.systems.pendulum_lagrangian"]),
        ("MechLib.Analytical.PoissonBracket", ["analytical.poisson_bracket", "analytical.hamiltonian"], [], ["law.analytical.hamilton_canonical_equations"], []),
        ("MechLib.Analytical.ConservationLaw", ["analytical.conservation_law", "analytical.lagrange_equation"], ["concept.cyclic_coordinate"], ["law.analytical.cyclic_coordinate_conservation"], ["problem.systems.central_force_angular_momentum"]),
        ("MechLib.Analytical.Constraints", ["analytical.constraints"], ["concept.constraints"], [], ["problem.systems.atwood_constraint_modeling"]),
        ("MechLib.Mechanics.SHM", ["systems.harmonic_oscillator", "analytical.small_oscillations"], [], ["law.analytical.small_oscillation_equation"], ["problem.systems.coupled_oscillator_normal_modes"]),
        ("MechLib.Mechanics.DampedSHM", ["systems.damped_oscillator", "systems.harmonic_oscillator"], [], ["law.analytical.small_oscillation_equation"], ["problem.systems.coupled_oscillator_normal_modes"]),
        ("MechLib.Mechanics.CentralForce", ["systems.central_force", "dynamics.angular_momentum"], ["concept.moment"], ["law.dynamics.angular_momentum_conservation"], ["problem.systems.central_force_angular_momentum"]),
        ("MechLib.Compat.PHYSlib", ["foundation.si_units"], [], [], []),
    ]
    for prefix, specs, concepts, laws, problems in routes:
        if module == prefix or module.startswith(prefix + "."):
            return specs, concepts, laws, problems
    return [], [], [], []


KEYWORD_RULES: list[tuple[str, list[str], list[str], list[str], list[str], float]] = [
    (r"newton|secondlawvec|force_from_velocity_rate_const_mass|\bf_of\b", ["dynamics.newton_law", "dynamics.particle_dynamics"], ["concept.force_system"], ["law.dynamics.newton_second_law"], ["problem.dynamics.particle_dynamics"], 0.42),
    (r"work_energy|workenergy|kineticenergy|work1d|work_def|kinetic", ["dynamics.work_energy"], ["concept.kinetic_energy"], ["law.dynamics.work_energy_theorem"], ["problem.dynamics.work_energy_find_speed"], 0.42),
    (r"potentialenergy|potential|conservative", ["dynamics.work_energy"], ["concept.potential_energy"], ["law.dynamics.work_energy_theorem"], ["problem.dynamics.work_energy_find_speed"], 0.32),
    (r"impulse", ["dynamics.impulse", "dynamics.momentum"], [], [], ["problem.dynamics.particle_dynamics"], 0.40),
    (r"angularmomentum|momentofmomentum|torque", ["dynamics.angular_momentum", "statics.moment"], ["concept.moment"], ["law.dynamics.angular_momentum_conservation"], ["problem.systems.central_force_angular_momentum"], 0.42),
    (r"lagrangian|eulerlagrange|lagrange", ["analytical.lagrange_equation", "analytical.generalized_coordinates"], ["concept.lagrangian", "concept.generalized_coordinates"], ["law.analytical.euler_lagrange_equation"], ["problem.systems.pendulum_lagrangian"], 0.45),
    (r"hamiltonian|canonical", ["analytical.hamiltonian", "analytical.lagrange_equation"], ["concept.generalized_coordinates", "concept.lagrangian"], ["law.analytical.hamilton_canonical_equations"], ["problem.systems.pendulum_lagrangian"], 0.45),
    (r"poisson", ["analytical.poisson_bracket", "analytical.hamiltonian"], [], ["law.analytical.hamilton_canonical_equations"], [], 0.50),
    (r"cyclic", ["analytical.conservation_law", "analytical.lagrange_equation"], ["concept.cyclic_coordinate"], ["law.analytical.cyclic_coordinate_conservation", "law.analytical.euler_lagrange_equation"], [], 0.42),
    (r"period|frequency|amplitude|turningpoint|shm", ["systems.harmonic_oscillator"], [], ["law.analytical.small_oscillation_equation"], ["problem.systems.coupled_oscillator_normal_modes"], 0.40),
    (r"damp|qualityfactor|relaxationtime|discriminant|underdamped|overdamped|criticalclosedform", ["systems.damped_oscillator"], [], ["law.analytical.small_oscillation_equation"], ["problem.systems.coupled_oscillator_normal_modes"], 0.45),
    (r"central|orbit|kepler|effectivepotential|radial|inversesquare", ["systems.central_force", "dynamics.angular_momentum"], ["concept.moment"], ["law.dynamics.angular_momentum_conservation"], ["problem.systems.central_force_angular_momentum"], 0.45),
    (r"pendulum|smallangle", ["systems.pendulum", "analytical.lagrange_equation"], ["concept.lagrangian"], ["law.analytical.euler_lagrange_equation"], ["problem.systems.pendulum_lagrangian"], 0.45),
    (r"normalmode|stiffness|massmatrix", ["systems.coupled_oscillator", "analytical.small_oscillations"], ["concept.lagrangian"], ["law.analytical.small_oscillation_equation"], ["problem.systems.coupled_oscillator_normal_modes"], 0.45),
    (r"quantity\.cast|vecquantity\.cast|dim|dimension|conversionfactor", ["foundation.dimensions", "foundation.quantity"], [], [], [], 0.50),
    (r"velocity|acceleration|displacement|trajectory", ["kinematics.point_motion"], [], [], ["problem.kinematics.uniform_acceleration_point_motion"], 0.34),
    (r"relative", ["kinematics.relative_motion"], [], [], ["problem.kinematics.composite_point_motion"], 0.38),
    (r"rotational|rigidbody|inertia|momentofinertia", ["rigidbody.fixed_axis_dynamics", "rigidbody.inertia"], [], [], [], 0.38),
    (r"center|centermass|totalmomentum|variablemass", ["dynamics.system_dynamics", "dynamics.momentum"], [], [], ["problem.dynamics.particle_dynamics"], 0.36),
]


TYPE_RULES: list[tuple[tuple[str, ...], list[str], float]] = [
    (("mass", "force", "acceleration"), ["dynamics.newton_law"], 0.22),
    (("work", "kineticenergy"), ["dynamics.work_energy"], 0.22),
    (("momentum", "impulse"), ["dynamics.momentum", "dynamics.impulse"], 0.22),
    (("angularmomentum", "torque"), ["dynamics.angular_momentum"], 0.22),
    (("lagrangian",), ["analytical.lagrange_equation"], 0.22),
    (("generalizedcoordinate", "generalizedmomentum"), ["analytical.lagrange_equation", "analytical.hamiltonian"], 0.22),
    (("quantity.cast", "vecquantity.cast", "dim"), ["foundation.dimensions"], 0.20),
    (("speed", "velocity", "acceleration", "displacement"), ["kinematics.point_motion"], 0.20),
]


def valid_ids(ids: Iterable[str], spec_rows: dict[str, dict[str, Any]]) -> list[str]:
    seen: set[str] = set()
    out: list[str] = []
    for spec_id in ids:
        if spec_id in spec_rows and spec_id not in seen:
            seen.add(spec_id)
            out.append(spec_id)
    return out


def add_score(scores: dict[str, float], spec_ids: Iterable[str], amount: float, spec_rows: dict[str, dict[str, Any]]) -> None:
    for spec_id in valid_ids(spec_ids, spec_rows):
        scores[spec_id] = min(1.0, scores.get(spec_id, 0.0) + amount)


def infer_premise_role(row: dict[str, Any], law_ids: list[str]) -> list[str]:
    short = str(row.get("short_name", "")).lower()
    module = str(row.get("module", ""))
    roles: list[str] = []
    if short.endswith("_def") or "_def" in short:
        roles.append("definition")
    if "iff" in short:
        roles.append("equivalence")
    if short.endswith("_eq") or "_eq_" in short or "=" in str(row.get("statement", "")):
        roles.append("rewrite")
    if module.startswith("MechLib.Units") or module == "MechLib.SI":
        roles.append("dimension_bridge")
    if law_ids:
        roles.append("law")
    if short.startswith("fin_induction") or short.endswith("_ne_zero") or short.endswith("_pos"):
        roles.append("helper")
    return stable_unique(roles or ["lemma"])


def infer_proof_hints(row: dict[str, Any]) -> list[str]:
    fq_name = row.get("fq_name", "")
    short = str(row.get("short_name", "")).lower()
    attrs = set(row.get("attrs") or [])
    if "simp" in attrs:
        return [f"simp [{fq_name}]"]
    if "iff" in short:
        return [f"rw [{fq_name}]", "constructor"]
    if short.endswith("_eq") or "_eq_" in short:
        return [f"rw [{fq_name}]", f"simp [{fq_name}]"]
    if short.endswith("_def") or "_def" in short:
        return [f"simp [{fq_name}]"]
    if short.endswith("_nonneg") or short.endswith("_pos") or short.endswith("_ne_zero"):
        return [f"have h := {fq_name}", "positivity"]
    return [f"exact {fq_name}"]


def stable_unique(values: Iterable[str]) -> list[str]:
    seen: set[str] = set()
    out: list[str] = []
    for value in values:
        if value and value not in seen:
            seen.add(value)
            out.append(value)
    return out


def build_retrieval_text(row: dict[str, Any], primary: str | None, secondary: list[str], concepts: list[str], laws: list[str], problems: list[str]) -> str:
    base = str(row.get("retrieval_text") or "").strip()
    aligned = [
        f"Primary Spec: {primary or '<unmatched>'}",
        f"Secondary Specs: {', '.join(secondary)}",
        f"Concept Specs: {', '.join(concepts)}",
        f"Law Schemas: {', '.join(laws)}",
        f"Problem Schemas: {', '.join(problems)}",
    ]
    return (base + "\n" + "\n".join(aligned)).strip()


def align_one(
    row: dict[str, Any],
    override: dict[str, Any],
    spec_rows: dict[str, dict[str, Any]],
    groups: dict[str, set[str]],
) -> tuple[dict[str, Any], set[str]]:
    scores: dict[str, float] = {}
    methods: set[str] = set()
    concepts: list[str] = []
    laws: list[str] = []
    problems: list[str] = []

    module_specs, module_concepts, module_laws, module_problems = module_route(str(row.get("module", "")))
    if module_specs:
        add_score(scores, module_specs, 0.42, spec_rows)
        concepts.extend(valid_ids(module_concepts, spec_rows))
        laws.extend(valid_ids(module_laws, spec_rows))
        problems.extend(valid_ids(module_problems, spec_rows))
        methods.add("module")

    text = normalize_text(row)
    for pattern, spec_ids, concept_ids, law_ids, problem_ids, weight in KEYWORD_RULES:
        if re.search(pattern, text):
            add_score(scores, spec_ids, weight, spec_rows)
            concepts.extend(valid_ids(concept_ids, spec_rows))
            laws.extend(valid_ids(law_ids, spec_rows))
            problems.extend(valid_ids(problem_ids, spec_rows))
            methods.add("keyword")

    statement_text = str(row.get("statement", "")).lower()
    compact_statement = re.sub(r"[^a-z0-9_.]+", "", statement_text)
    for tokens, spec_ids, weight in TYPE_RULES:
        if all(token.lower() in compact_statement for token in tokens):
            add_score(scores, spec_ids, weight, spec_rows)
            methods.add("type_signature")

    override_primary = override.get("primary_spec_id")
    if override_primary:
        add_score(scores, [str(override_primary)], 1.0, spec_rows)
        methods.add("override")

    secondary_from_override = listify(override.get("secondary_spec_ids"))
    concepts.extend(valid_ids(listify(override.get("concept_ids")), spec_rows))
    laws.extend(valid_ids(listify(override.get("law_schema_ids")), spec_rows))
    problems.extend(valid_ids(listify(override.get("problem_schema_ids")), spec_rows))

    for law_id in laws:
        add_score(scores, [law_id], 0.20, spec_rows)
    for problem_id in problems:
        add_score(scores, [problem_id], 0.12, spec_rows)
    for concept_id in concepts:
        add_score(scores, [concept_id], 0.10, spec_rows)
    add_score(scores, secondary_from_override, 0.65, spec_rows)

    score_order = {spec_id: idx for idx, spec_id in enumerate(scores)}
    ranked = sorted(scores.items(), key=lambda item: (-item[1], score_order[item[0]], item[0]))
    primary = str(override_primary) if override_primary in spec_rows else (ranked[0][0] if ranked else None)
    secondary_candidates = [spec_id for spec_id, score in ranked if spec_id != primary and score >= 0.20]
    secondary = stable_unique(valid_ids(secondary_from_override, spec_rows) + secondary_candidates)[:10]
    concepts = stable_unique(valid_ids(concepts, spec_rows))
    laws = stable_unique(valid_ids(laws, spec_rows))
    problems = stable_unique(valid_ids(problems, spec_rows))

    if primary in groups["concept"] and primary not in concepts:
        concepts.insert(0, primary)
    if primary in groups["law"] and primary not in laws:
        laws.insert(0, primary)
    if primary in groups["problem"] and primary not in problems:
        problems.insert(0, primary)

    alignment_score = scores.get(primary, 0.0) if primary else 0.0
    status = str(override.get("status") or row.get("status") or "verified")
    if status not in STATUS_VALUES:
        raise ValueError(f"{row.get('fq_name')} has invalid status override: {status}")
    trust_level = str(override.get("trust_level") or row.get("trust_level") or ("derived" if primary else "interface"))
    if trust_level not in TRUST_VALUES:
        raise ValueError(f"{row.get('fq_name')} has invalid trust_level override: {trust_level}")

    needs_review = bool(override.get("needs_review", False)) or primary is None or alignment_score < NEEDS_REVIEW_THRESHOLD
    required_imports = stable_unique(listify(override.get("required_imports")) or [str(row.get("module") or "MechLib")])
    dependencies = stable_unique(listify(override.get("dependencies")))
    premise_role = stable_unique(listify(override.get("premise_role")) or infer_premise_role(row, laws))
    proof_hints = stable_unique(
        listify(override.get("proof_hints"))
        or listify(row.get("proof_hints"))
        or infer_proof_hints(row)
    )

    requested_callable = override.get("callable_by_llm")
    if requested_callable is None:
        callable_by_llm = status == "verified" and trust_level in CALLABLE_TRUST and bool(required_imports) and not needs_review and alignment_score >= CALLABLE_THRESHOLD
    else:
        callable_by_llm = bool(requested_callable)
        if not (status == "verified" and trust_level in CALLABLE_TRUST and bool(required_imports)):
            callable_by_llm = False

    method = "+".join(sorted(methods)) if methods else "unmatched"
    enriched = {
        **row,
        "fq_name": row.get("fq_name", ""),
        "short_name": row.get("short_name", ""),
        "module": row.get("module", ""),
        "namespace": row.get("namespace", ""),
        "kind": row.get("kind", ""),
        "statement": row.get("statement", ""),
        "attrs": row.get("attrs") or [],
        "source_path": row.get("source_path", ""),
        "source_line": row.get("source_line"),
        "status": status,
        "trust_level": trust_level,
        "callable_by_llm": callable_by_llm,
        "primary_spec_id": primary,
        "secondary_spec_ids": secondary,
        "concept_ids": concepts,
        "law_schema_ids": laws,
        "problem_schema_ids": problems,
        "premise_role": premise_role,
        "required_imports": required_imports,
        "dependencies": dependencies,
        "proof_hints": proof_hints,
        "retrieval_text": build_retrieval_text(row, primary, secondary, concepts, laws, problems),
        "alignment_method": method,
        "alignment_score": round(alignment_score, 3),
        "needs_review": needs_review,
    }
    return enriched, methods


def validate_outputs(theorems: list[dict[str, Any]], enriched: list[dict[str, Any]]) -> None:
    if len(theorems) != len(enriched):
        raise ValueError(f"enriched row count mismatch: {len(enriched)} != {len(theorems)}")
    for row in enriched:
        verified = set(row.get("verified_decls") or [])
        schema = set(row.get("schema_decls") or [])
        if verified.intersection(schema):
            raise ValueError(f"{row['fq_name']} mixes verified/schema decls")
        if row["callable_by_llm"]:
            if row["status"] != "verified":
                raise ValueError(f"{row['fq_name']} is callable but not verified")
            if row["trust_level"] not in CALLABLE_TRUST:
                raise ValueError(f"{row['fq_name']} is callable with unsafe trust level")
            if not row["required_imports"]:
                raise ValueError(f"{row['fq_name']} is callable without imports")


def build_indices(
    enriched: list[dict[str, Any]],
    spec_rows: dict[str, dict[str, Any]],
) -> tuple[dict[str, list[str]], dict[str, dict[str, Any]]]:
    spec_to_decl: dict[str, list[str]] = {spec_id: [] for spec_id in sorted(spec_rows)}
    decl_to_spec: dict[str, dict[str, Any]] = {}
    for row in enriched:
        fq_name = row["fq_name"]
        related = stable_unique(
            [row.get("primary_spec_id")]
            + listify(row.get("secondary_spec_ids"))
            + listify(row.get("concept_ids"))
            + listify(row.get("law_schema_ids"))
            + listify(row.get("problem_schema_ids"))
        )
        for spec_id in related:
            if spec_id in spec_to_decl:
                spec_to_decl[spec_id].append(fq_name)
        decl_to_spec[fq_name] = {
            "primary_spec_id": row.get("primary_spec_id"),
            "secondary_spec_ids": row.get("secondary_spec_ids") or [],
            "concept_ids": row.get("concept_ids") or [],
            "law_schema_ids": row.get("law_schema_ids") or [],
            "problem_schema_ids": row.get("problem_schema_ids") or [],
            "status": row.get("status"),
            "trust_level": row.get("trust_level"),
            "callable_by_llm": row.get("callable_by_llm"),
            "alignment_method": row.get("alignment_method"),
            "alignment_score": row.get("alignment_score"),
            "needs_review": row.get("needs_review"),
        }
    for spec_id in spec_to_decl:
        spec_to_decl[spec_id] = sorted(set(spec_to_decl[spec_id]))
    return spec_to_decl, decl_to_spec


def build_report(enriched: list[dict[str, Any]], method_sets: list[set[str]]) -> dict[str, Any]:
    total = len(enriched)
    matched = sum(1 for row in enriched if row.get("primary_spec_id"))
    scores = [float(row.get("alignment_score") or 0.0) for row in enriched]
    return {
        "total_decls": total,
        "matched_decls": matched,
        "unmatched_decls": total - matched,
        "needs_review_count": sum(1 for row in enriched if row.get("needs_review")),
        "matched_by_module": sum(1 for methods in method_sets if "module" in methods),
        "matched_by_keyword": sum(1 for methods in method_sets if "keyword" in methods),
        "matched_by_type_signature": sum(1 for methods in method_sets if "type_signature" in methods),
        "matched_by_override": sum(1 for methods in method_sets if "override" in methods),
        "callable_by_llm_count": sum(1 for row in enriched if row.get("callable_by_llm")),
        "schema_only_count": sum(1 for row in enriched if row.get("status") != "verified"),
        "average_alignment_score": round(sum(scores) / max(1, len(scores)), 6),
        "status_distribution": dict(sorted(collections.Counter(row.get("status") for row in enriched).items())),
        "trust_level_distribution": dict(sorted(collections.Counter(row.get("trust_level") for row in enriched).items())),
        "alignment_method_distribution": dict(sorted(collections.Counter(row.get("alignment_method") for row in enriched).items())),
    }


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Link MechLib theorem corpus declarations to Spec metadata.")
    parser.add_argument("--theorems", default="corpus/theorem_corpus.jsonl")
    parser.add_argument("--concepts", default="corpus/concept_corpus.jsonl")
    parser.add_argument("--laws", default="corpus/law_schema_corpus.jsonl")
    parser.add_argument("--problems", default="corpus/problem_schema_corpus.jsonl")
    parser.add_argument("--coverage", default="corpus/coverage_matrix.json")
    parser.add_argument("--overrides", default="tools/export_overrides.yaml")
    parser.add_argument("--enriched-out", default="corpus/decl_corpus_enriched.jsonl")
    parser.add_argument("--spec-to-decl-out", default="corpus/spec_to_decl_index.json")
    parser.add_argument("--decl-to-spec-out", default="corpus/decl_to_spec_index.json")
    parser.add_argument("--report-out", default="corpus/spec_alignment_report.json")
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    repo_root = Path.cwd()
    theorems = read_jsonl(repo_root / args.theorems)
    spec_rows, groups = load_specs(
        repo_root / args.coverage,
        repo_root / args.concepts,
        repo_root / args.laws,
        repo_root / args.problems,
    )
    overrides = load_overrides(repo_root / args.overrides)

    enriched: list[dict[str, Any]] = []
    method_sets: list[set[str]] = []
    for row in theorems:
        override = overrides.get(str(row.get("fq_name")), {})
        out, methods = align_one(row, override, spec_rows, groups)
        enriched.append(out)
        method_sets.append(methods)

    validate_outputs(theorems, enriched)
    spec_to_decl, decl_to_spec = build_indices(enriched, spec_rows)
    report = build_report(enriched, method_sets)

    write_jsonl(repo_root / args.enriched_out, enriched)
    write_json(repo_root / args.spec_to_decl_out, spec_to_decl)
    write_json(repo_root / args.decl_to_spec_out, decl_to_spec)
    write_json(repo_root / args.report_out, report)

    print(f"[export] enriched decl corpus: {repo_root / args.enriched_out} ({len(enriched)} rows)")
    print(f"[export] spec->decl index:     {repo_root / args.spec_to_decl_out} ({len(spec_to_decl)} specs)")
    print(f"[export] decl->spec index:     {repo_root / args.decl_to_spec_out} ({len(decl_to_spec)} decls)")
    print(f"[export] alignment report:     {repo_root / args.report_out}")
    print(
        "[check] matched={matched}/{total} needs_review={review} callable={callable}".format(
            matched=report["matched_decls"],
            total=report["total_decls"],
            review=report["needs_review_count"],
            callable=report["callable_by_llm_count"],
        )
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
