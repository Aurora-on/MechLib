#!/usr/bin/env python3
"""
Export MechLib theorem/lemma corpus for LLM RAG usage.

Outputs:
  - theorem_corpus.jsonl
  - alias_map.jsonl
  - export_report.json
"""

from __future__ import annotations

import argparse
import json
import random
import re
import subprocess
from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Dict, Iterable, List, Optional, Sequence, Tuple


MECH_MODULES = {
    "Kinematics",
    "Dynamics",
    "WorkEnergy",
    "MomentumImpulse",
    "Rotation",
    "SHM",
    "DampedSHM",
    "CentralForce",
    "SystemDynamics",
    "AnalyticalMechanics",
}

OPEN_MECHANICS_PREFIXES = {
    "Kinematics",
    "Dynamics",
    "WorkEnergy",
    "MomentumImpulse",
    "Rotation",
    "SHM",
    "DampedSHM",
    "CentralForce",
    "SystemDynamics",
    "AnalyticalMechanics",
}

ALIAS_HEURISTIC_TARGETS = {
    "secondLaw": "MechLib.Dynamics.Verified.Dynamics.newton_second_law",
    "F_of": "MechLib.Dynamics.Verified.Dynamics.newton_second_law",
    "displacement_end_x_init_x": "MechLib.Kinematics.Verified.Kinematics.displacement_eq_sub",
    "displacement_delta_t_const_v": "MechLib.Kinematics.Verified.Kinematics.constant_speed_relation",
}


@dataclass
class TheoremItem:
    id: str
    kind: str
    fq_name: str
    short_name: str
    namespace: str
    module: str
    statement: str
    attrs: List[str]
    source_path: str
    source_line: int
    tags: List[str]
    summary_en: str
    proof_hints: List[str]
    retrieval_text: str

    def to_json(self) -> Dict[str, Any]:
        return {
            "id": self.id,
            "kind": self.kind,
            "fq_name": self.fq_name,
            "short_name": self.short_name,
            "namespace": self.namespace,
            "module": self.module,
            "statement": self.statement,
            "attrs": self.attrs,
            "source_path": self.source_path,
            "source_line": self.source_line,
            "tags": self.tags,
            "summary_en": self.summary_en,
            "proof_hints": self.proof_hints,
            "retrieval_text": self.retrieval_text,
        }


@dataclass
class AliasItem:
    alias_name: str
    alias_fq_name: str
    alias_to_fq_name: str
    source_path: str
    source_line: int

    def to_json(self) -> Dict[str, Any]:
        return {
            "alias_name": self.alias_name,
            "alias_fq_name": self.alias_fq_name,
            "alias_to_fq_name": self.alias_to_fq_name,
            "source_path": self.source_path,
            "source_line": self.source_line,
        }


def normalize_ws(text: str) -> str:
    return re.sub(r"\s+", " ", text).strip()


def clean_docstring(raw: str) -> str:
    text = raw
    text = text.replace("/--", "")
    text = text.replace("-/", "")
    text = re.sub(r"^\s*--\s?", "", text, flags=re.M)
    return normalize_ws(text)


def is_mostly_english(text: str) -> bool:
    if not text:
        return False
    letters = [ch for ch in text if ch.isalpha()]
    if not letters:
        return False
    ascii_letters = [ch for ch in letters if "a" <= ch.lower() <= "z"]
    ratio = len(ascii_letters) / len(letters)
    return ratio >= 0.75 and len(ascii_letters) >= 8


def extract_attrs(attr_block: str) -> List[str]:
    attrs: List[str] = []
    for inner in re.findall(r"@\[(.*?)\]", attr_block, flags=re.S):
        for token in re.split(r"[, \n\t]+", inner.strip()):
            token = token.strip()
            if not token:
                continue
            # Keep lightweight attribute-like identifiers.
            if re.fullmatch(r"[A-Za-z_][A-Za-z0-9_']*", token):
                attrs.append(token)
    # Stable unique while preserving order.
    seen = set()
    uniq: List[str] = []
    for a in attrs:
        if a in seen:
            continue
        seen.add(a)
        uniq.append(a)
    return uniq


def module_from_path(file_path: Path, root_path: Path) -> str:
    rel = file_path.relative_to(root_path)
    root_name = root_path.name
    parts = [root_name] + list(rel.with_suffix("").parts)
    return ".".join(parts)


def tag_from_module(module: str) -> str:
    if module.startswith("MechLib.Units"):
        return "Units"
    if module == "MechLib.SI":
        return "SI"
    if module.startswith("MechLib.Compat"):
        return "Compat"
    if module.startswith("MechLib.Mechanics."):
        leaf = module.split(".")[-1]
        if leaf in MECH_MODULES:
            return leaf
        return "Mechanics"
    return "General"


def build_retrieval_text(
    fq_name: str,
    statement: str,
    tags: Sequence[str],
    summary_en: str,
) -> str:
    tag_text = ", ".join(tags)
    return f"{fq_name}\n{statement}\nTags: {tag_text}\n{summary_en}".strip()


def extract_prop_from_statement(statement: str, kind: str, short_name: str) -> str:
    # Input is already normalized to one line.
    prefix = f"{kind} {short_name}"
    idx = statement.find(prefix)
    if idx == -1:
        return ""
    start = idx + len(prefix)
    depth_paren = 0
    depth_brace = 0
    depth_bracket = 0
    for i in range(start, len(statement)):
        ch = statement[i]
        if ch == "(":
            depth_paren += 1
        elif ch == ")":
            depth_paren = max(depth_paren - 1, 0)
        elif ch == "{":
            depth_brace += 1
        elif ch == "}":
            depth_brace = max(depth_brace - 1, 0)
        elif ch == "[":
            depth_bracket += 1
        elif ch == "]":
            depth_bracket = max(depth_bracket - 1, 0)
        elif ch == ":" and depth_paren == 0 and depth_brace == 0 and depth_bracket == 0:
            return statement[i + 1 :].strip()
    return ""


def make_summary_en(
    kind: str,
    fq_name: str,
    short_name: str,
    statement: str,
    docstring: str,
) -> str:
    if docstring and is_mostly_english(docstring):
        text = docstring.rstrip(".")
        return f"{kind} {fq_name}: {text}."

    name = short_name.lower()
    if "newton_second_law" in name:
        return f"{kind} {fq_name}: states Newton's second law in the library interface."
    if "_conservation_" in name or "conservation" in name:
        return f"{kind} {fq_name}: formalizes a conservation relation."
    if name.endswith("_eq"):
        return f"{kind} {fq_name}: provides an explicit equality form."
    if name.endswith("_def"):
        return f"{kind} {fq_name}: unfolds a definition-level identity."
    if "trichotomy" in name:
        return f"{kind} {fq_name}: states a trichotomy classification."

    prop = extract_prop_from_statement(statement, kind, short_name)
    if prop:
        prop = prop.strip().rstrip(".")
        if len(prop) > 180:
            prop = prop[:177].rstrip() + "..."
        return f"{kind} {fq_name}: states that {prop}."
    return f"{kind} {fq_name}: provides a reusable formal statement."


def infer_proof_hints(fq_name: str, short_name: str, attrs: Sequence[str]) -> List[str]:
    short = short_name.lower()
    attr_set = set(attrs)
    if "simp" in attr_set:
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


def to_rel_path(path: Path, base: Path) -> str:
    try:
        return path.relative_to(base).as_posix()
    except ValueError:
        return path.as_posix()


def parse_theorems(root_path: Path, repo_root: Path) -> List[Dict[str, Any]]:
    items: List[Dict[str, Any]] = []
    theorem_re = re.compile(
        r"^\s*(?:(@\[[^\]]*\])\s*)?(theorem|lemma)\s+([A-Za-z0-9_'\u00C0-\uFFFF]+)\b"
    )
    namespace_re = re.compile(r"^\s*namespace\s+([A-Za-z0-9_.']+)\s*$")
    section_re = re.compile(r"^\s*(?:noncomputable\s+)?section(?:\s+[A-Za-z0-9_.']+)?\s*$")
    end_re = re.compile(r"^\s*end(?:\s+([A-Za-z0-9_.']+))?\s*$")

    for file_path in sorted(root_path.rglob("*.lean")):
        rel_parts = file_path.relative_to(repo_root).parts
        if any(p in {".lake", ".pipeline1_tmp"} for p in rel_parts):
            continue

        text = file_path.read_text(encoding="utf-8", errors="replace")
        lines = text.splitlines()
        n = len(lines)
        i = 0

        ns_parts: List[str] = []
        stack: List[Tuple[str, str, int]] = []
        pending_doc: Optional[Tuple[str, int]] = None
        pending_attrs: List[str] = []

        while i < n:
            line = lines[i]
            stripped = line.strip()

            # Docstring block.
            if "/--" in stripped:
                j = i
                doc_lines = [line]
                while "-/" not in lines[j] and j + 1 < n:
                    j += 1
                    doc_lines.append(lines[j])
                pending_doc = (clean_docstring("\n".join(doc_lines)), i + 1)
                i = j + 1
                continue

            # Theorem/Lemma declaration, including inline attribute forms like:
            #   @[simp] theorem ...
            m_thm = theorem_re.match(line)
            if m_thm:
                inline_attr_block = m_thm.group(1) or ""
                kind = m_thm.group(2)
                short_name = m_thm.group(3)
                inline_attrs = extract_attrs(inline_attr_block) if inline_attr_block else []
                j = i
                decl_lines = [line]
                while ":=" not in decl_lines[-1] and j + 1 < n:
                    j += 1
                    decl_lines.append(lines[j])
                joined = "\n".join(decl_lines)
                if ":=" not in joined:
                    # Fallback; should not happen in this codebase.
                    i = j + 1
                    pending_doc = None
                    pending_attrs = []
                    continue

                statement_raw = joined.split(":=", 1)[0].rstrip()
                # Remove inline attribute prefix from statement text.
                statement_raw = re.sub(r"^\s*@\[[^\]]*\]\s*", "", statement_raw, count=1)
                statement = normalize_ws(statement_raw)
                namespace = ".".join(ns_parts)
                fq_name = f"{namespace}.{short_name}" if namespace else short_name
                module = module_from_path(file_path, root_path)
                tag = tag_from_module(module)
                docstring = pending_doc[0] if pending_doc else ""
                summary_en = make_summary_en(kind, fq_name, short_name, statement, docstring)
                attrs = sorted(set(pending_attrs + inline_attrs))
                proof_hints = infer_proof_hints(fq_name, short_name, attrs)
                retrieval_text = build_retrieval_text(fq_name, statement, [tag], summary_en)

                items.append(
                    {
                        "id": f"mechlib::{fq_name}",
                        "kind": kind,
                        "fq_name": fq_name,
                        "short_name": short_name,
                        "namespace": namespace,
                        "module": module,
                        "statement": statement,
                        "attrs": attrs,
                        "source_path": to_rel_path(file_path, repo_root),
                        "source_line": i + 1,
                        "tags": [tag],
                        "summary_en": summary_en,
                        "proof_hints": proof_hints,
                        "retrieval_text": retrieval_text,
                    }
                )

                pending_doc = None
                pending_attrs = []
                i = j + 1
                continue

            # Attribute block.
            if stripped.startswith("@["):
                j = i
                attr_lines = [line]
                while "]" not in lines[j] and j + 1 < n:
                    j += 1
                    attr_lines.append(lines[j])
                pending_attrs.extend(extract_attrs("\n".join(attr_lines)))
                i = j + 1
                continue

            # Namespace open.
            m_ns = namespace_re.match(line)
            if m_ns:
                name = m_ns.group(1)
                add_parts = name.split(".")
                ns_parts.extend(add_parts)
                stack.append(("namespace", name, len(add_parts)))
                i += 1
                continue

            # Section open.
            if section_re.match(line):
                stack.append(("section", "", 0))
                i += 1
                continue

            # End.
            m_end = end_re.match(line)
            if m_end:
                end_name = m_end.group(1)
                if end_name:
                    while stack:
                        typ, name, added = stack.pop()
                        if typ == "namespace" and added > 0:
                            ns_parts = ns_parts[:-added]
                            if name == end_name or name.split(".")[-1] == end_name:
                                break
                else:
                    if stack:
                        typ, _name, added = stack.pop()
                        if typ == "namespace" and added > 0:
                            ns_parts = ns_parts[:-added]
                i += 1
                continue

            # Any non-empty, non-comment code line breaks pending docs/attrs attachment.
            if stripped and not stripped.startswith("--"):
                pending_doc = None
                pending_attrs = []

            i += 1

    return items


def canonicalize_rhs_token(token: str) -> List[str]:
    cands: List[str] = [token]
    if token.startswith("MechLib."):
        return cands

    if "." in token:
        head = token.split(".", 1)[0]
        tail = token.split(".", 1)[1]
        if head in OPEN_MECHANICS_PREFIXES:
            cands.append(f"MechLib.Mechanics.{head}.{tail}")
        elif head == "SI":
            cands.append(f"MechLib.SI.{tail}")
    return cands


def pick_preferred(cands: Sequence[str]) -> Optional[str]:
    if not cands:
        return None
    scored = sorted(
        cands,
        key=lambda x: (
            1 if x.startswith("MechLib.Compat.") else 0,
            len(x),
            x,
        ),
    )
    return scored[0]


def resolve_alias_target(
    alias_name: str,
    rhs_token: str,
    theorem_by_fq: Dict[str, Dict[str, Any]],
    theorem_by_short: Dict[str, List[str]],
) -> Optional[str]:
    # Hard rules for key PHYSlib-facing symbols.
    if alias_name in ALIAS_HEURISTIC_TARGETS:
        tgt = ALIAS_HEURISTIC_TARGETS[alias_name]
        if tgt in theorem_by_fq:
            return tgt

    for cand in canonicalize_rhs_token(rhs_token):
        if cand in theorem_by_fq:
            return cand

    rhs_short = rhs_token.split(".")[-1]
    direct = theorem_by_short.get(rhs_short, [])
    picked = pick_preferred(direct)
    if picked:
        return picked

    for suffix in ("_eq", "_def"):
        cands = theorem_by_short.get(rhs_short + suffix, [])
        picked = pick_preferred(cands)
        if picked:
            return picked

    return None


def parse_aliases(
    compat_path: Path,
    repo_root: Path,
    theorem_by_fq: Dict[str, Dict[str, Any]],
    theorem_by_short: Dict[str, List[str]],
) -> Tuple[List[AliasItem], List[Dict[str, Any]]]:
    if not compat_path.exists():
        return [], []

    text = compat_path.read_text(encoding="utf-8", errors="replace")
    lines = text.splitlines()
    namespace_re = re.compile(r"^\s*namespace\s+([A-Za-z0-9_.']+)\s*$")
    section_re = re.compile(r"^\s*(?:noncomputable\s+)?section(?:\s+[A-Za-z0-9_.']+)?\s*$")
    end_re = re.compile(r"^\s*end(?:\s+([A-Za-z0-9_.']+))?\s*$")
    abbrev_re = re.compile(r"^\s*abbrev\s+([A-Za-z0-9_'.]+)\s*:=\s*(.+?)\s*$")

    ns_parts: List[str] = []
    stack: List[Tuple[str, str, int]] = []

    resolved: List[AliasItem] = []
    unresolved: List[Dict[str, Any]] = []

    for idx, line in enumerate(lines):
        m_ns = namespace_re.match(line)
        if m_ns:
            name = m_ns.group(1)
            add_parts = name.split(".")
            ns_parts.extend(add_parts)
            stack.append(("namespace", name, len(add_parts)))
            continue

        if section_re.match(line):
            stack.append(("section", "", 0))
            continue

        m_end = end_re.match(line)
        if m_end:
            end_name = m_end.group(1)
            if end_name:
                while stack:
                    typ, name, added = stack.pop()
                    if typ == "namespace" and added > 0:
                        ns_parts = ns_parts[:-added]
                        if name == end_name or name.split(".")[-1] == end_name:
                            break
            else:
                if stack:
                    typ, _name, added = stack.pop()
                    if typ == "namespace" and added > 0:
                        ns_parts = ns_parts[:-added]
            continue

        m_ab = abbrev_re.match(line)
        if not m_ab:
            continue
        alias_name = m_ab.group(1)
        rhs_expr = m_ab.group(2)
        rhs_expr = rhs_expr.split("--", 1)[0].strip()
        if not rhs_expr:
            continue
        rhs_token = rhs_expr.split()[0]

        namespace = ".".join(ns_parts)
        alias_fq = f"{namespace}.{alias_name}" if namespace else alias_name
        target = resolve_alias_target(alias_name, rhs_token, theorem_by_fq, theorem_by_short)

        if target is None:
            unresolved.append(
                {
                    "alias_name": alias_name,
                    "alias_fq_name": alias_fq,
                    "rhs_token": rhs_token,
                    "source_path": to_rel_path(compat_path, repo_root),
                    "source_line": idx + 1,
                }
            )
            continue

        resolved.append(
            AliasItem(
                alias_name=alias_name,
                alias_fq_name=alias_fq,
                alias_to_fq_name=target,
                source_path=to_rel_path(compat_path, repo_root),
                source_line=idx + 1,
            )
        )

    # Deduplicate by alias_fq_name; keep first deterministic occurrence.
    dedup: Dict[str, AliasItem] = {}
    for a in resolved:
        dedup.setdefault(a.alias_fq_name, a)

    return list(dedup.values()), unresolved


def write_jsonl(path: Path, rows: Iterable[Dict[str, Any]]) -> None:
    with path.open("w", encoding="utf-8", newline="\n") as f:
        for row in rows:
            f.write(json.dumps(row, ensure_ascii=False) + "\n")


def build_theorem_indices(
    items: Sequence[Dict[str, Any]],
) -> Tuple[Dict[str, Dict[str, Any]], Dict[str, List[str]]]:
    by_fq: Dict[str, Dict[str, Any]] = {}
    by_short: Dict[str, List[str]] = {}
    for it in items:
        by_fq[it["fq_name"]] = it
        by_short.setdefault(it["short_name"], []).append(it["fq_name"])
    return by_fq, by_short


def run_rg_baseline(root_path: Path, repo_root: Path) -> Dict[str, Any]:
    cmd = [
        "rg",
        "-n",
        r"^\s*(?:@\[[^]]+\]\s*)?(theorem|lemma)\s+",
        str(root_path),
        "-g",
        "*.lean",
    ]
    try:
        proc = subprocess.run(
            cmd,
            check=False,
            capture_output=True,
            text=True,
            encoding="utf-8",
            errors="replace",
        )
    except FileNotFoundError:
        return {
            "available": False,
            "count": None,
            "items": [],
            "cmd": cmd,
            "stderr": "rg not found",
        }
    if proc.returncode not in (0, 1):
        return {
            "available": True,
            "count": None,
            "items": [],
            "cmd": cmd,
            "stderr": proc.stderr.strip(),
        }

    theorem_re = re.compile(
        r"^\s*(?:@\[[^]]+\]\s*)?(theorem|lemma)\s+([A-Za-z0-9_'\u00C0-\uFFFF]+)\b"
    )
    line_re = re.compile(r"^(.*):([0-9]+):(.*)$")
    items: List[Dict[str, Any]] = []
    for row in proc.stdout.splitlines():
        # path:line:text (Windows drive path contains ':', so parse with regex)
        m_line = line_re.match(row)
        if not m_line:
            continue
        pth, line_s, text = m_line.group(1), m_line.group(2), m_line.group(3)
        m = theorem_re.match(text)
        if not m:
            continue
        items.append(
            {
                "source_path": to_rel_path(Path(pth), repo_root),
                "source_line": int(line_s),
                "short_name": m.group(2),
            }
        )
    return {
        "available": True,
        "count": len(items),
        "items": items,
        "cmd": cmd,
        "stderr": proc.stderr.strip(),
    }


def tokenize(text: str) -> List[str]:
    return re.findall(r"[A-Za-z0-9_.]+", text.lower())


def rewrite_query(query: str, aliases: Sequence[AliasItem]) -> Tuple[str, List[str]]:
    rewritten = query
    applied: List[str] = []
    for a in sorted(aliases, key=lambda x: len(x.alias_name), reverse=True):
        patt = rf"\b{re.escape(a.alias_name)}\b"
        if re.search(patt, rewritten):
            rewritten = re.sub(patt, f"{a.alias_to_fq_name} {a.alias_name}", rewritten)
            applied.append(a.alias_name)
    return rewritten, applied


def retrieval_topk(
    query: str,
    corpus: Sequence[Dict[str, Any]],
    k: int = 5,
) -> List[Dict[str, Any]]:
    q_tokens = set(tokenize(query))
    q_lower = query.lower()
    ranked: List[Tuple[int, str, Dict[str, Any]]] = []
    for it in corpus:
        c_tokens = set(tokenize(it["retrieval_text"]))
        score = len(q_tokens.intersection(c_tokens))
        short_name = it["short_name"].lower()
        if short_name in q_lower:
            score += 100
        split_parts = [p for p in short_name.split("_") if len(p) >= 3]
        if split_parts and all(p in q_lower for p in split_parts[: min(4, len(split_parts))]):
            score += 25
        if any(tag.lower() in q_lower for tag in it.get("tags", [])):
            score += 5
        ranked.append((score, it["fq_name"], it))
    ranked.sort(key=lambda x: (-x[0], x[1]))
    return [x[2] for x in ranked[:k]]


def run_retrieval_smoke_test(
    corpus: Sequence[Dict[str, Any]],
    aliases: Sequence[AliasItem],
) -> Dict[str, Any]:
    queries = [
        {
            "id": "q1_kinematics_constant_speed",
            "query": "constant speed displacement relation dx = v * t constant_speed_relation",
            "expect_any": ["MechLib.Kinematics.Verified.Kinematics.constant_speed_relation"],
            "category": "Kinematics",
        },
        {
            "id": "q2_kinematics_relative_velocity",
            "query": "relative velocity transitivity among three bodies relative_velocity_trans",
            "expect_any": ["MechLib.Kinematics.Verified.Kinematics.relative_velocity_trans"],
            "category": "Kinematics",
        },
        {
            "id": "q3_dynamics_alias_secondlaw",
            "query": "PHYSlib secondLaw relation force mass acceleration",
            "expect_any": ["MechLib.Dynamics.Verified.Dynamics.newton_second_law"],
            "category": "Dynamics",
        },
        {
            "id": "q4_dynamics_momentum_change",
            "query": "momentum change for constant mass momentum_change_const_mass",
            "expect_any": ["MechLib.Dynamics.Verified.Dynamics.momentum_change_const_mass"],
            "category": "Dynamics",
        },
        {
            "id": "q5_workenergy_core",
            "query": "work energy theorem net work equals kinetic energy change work_energy_theorem_core",
            "expect_any": ["MechLib.Dynamics.Verified.WorkEnergy.work_energy_theorem_core"],
            "category": "WorkEnergy",
        },
        {
            "id": "q6_workenergy_split",
            "query": "split conservative and nonconservative work conservative_nonconservative_split",
            "expect_any": ["MechLib.Dynamics.Verified.WorkEnergy.conservative_nonconservative_split"],
            "category": "WorkEnergy",
        },
        {
            "id": "q7_rotation_parallel_axis",
            "query": "parallel axis theorem for moment of inertia parallel_axis_theorem",
            "expect_any": ["MechLib.RigidBody.Verified.Rotation.parallel_axis_theorem"],
            "category": "Rotation",
        },
        {
            "id": "q8_rotation_kinetic",
            "query": "rotational kinetic energy equality formula rotationalKineticEnergy_eq",
            "expect_any": ["MechLib.RigidBody.Verified.Rotation.rotationalKineticEnergy_eq"],
            "category": "Rotation",
        },
        {
            "id": "q9_shm_period_frequency",
            "query": "period frequency relation in simple harmonic motion period_frequency_relation",
            "expect_any": ["MechLib.Systems.Verified.SHM.period_frequency_relation"],
            "category": "SHM",
        },
        {
            "id": "q10_kinematics_alias_displacement",
            "query": "PHYSlib displacement_end_x_init_x",
            "expect_any": ["MechLib.Kinematics.Verified.Kinematics.displacement_eq_sub"],
            "category": "Kinematics",
        },
    ]

    results: List[Dict[str, Any]] = []
    pass_count = 0

    for q in queries:
        rewritten, applied_aliases = rewrite_query(q["query"], aliases)
        top5 = retrieval_topk(rewritten, corpus, k=5)
        top5_names = [r["fq_name"] for r in top5]
        ok = any(any(exp in got for got in top5_names) for exp in q["expect_any"])
        if ok:
            pass_count += 1
        results.append(
            {
                "id": q["id"],
                "category": q["category"],
                "query": q["query"],
                "rewritten_query": rewritten,
                "applied_aliases": applied_aliases,
                "expect_any": q["expect_any"],
                "top5": top5_names,
                "pass": ok,
            }
        )

    return {
        "total": len(queries),
        "passed": pass_count,
        "failed": len(queries) - pass_count,
        "results": results,
    }


def sample_for_manual_check(items: Sequence[Dict[str, Any]], n: int = 20) -> List[Dict[str, Any]]:
    rng = random.Random(20260329)
    if len(items) <= n:
        chosen = list(items)
    else:
        chosen = [items[i] for i in sorted(rng.sample(range(len(items)), n))]
    return [
        {
            "fq_name": it["fq_name"],
            "statement": it["statement"],
            "source_path": it["source_path"],
            "source_line": it["source_line"],
        }
        for it in chosen
    ]


def build_report(
    root_path: Path,
    corpus: Sequence[Dict[str, Any]],
    aliases: Sequence[AliasItem],
    unresolved_aliases: Sequence[Dict[str, Any]],
    rg_info: Dict[str, Any],
    retrieval_smoke: Dict[str, Any],
) -> Dict[str, Any]:
    exported_keys = {
        (it["source_path"], int(it["source_line"]), it["short_name"])
        for it in corpus
    }

    rg_items = rg_info.get("items") or []
    baseline_keys = {
        (it["source_path"], int(it["source_line"]), it["short_name"])
        for it in rg_items
    }
    missing = sorted(list(baseline_keys - exported_keys))
    extra = sorted(list(exported_keys - baseline_keys))

    report: Dict[str, Any] = {
        "generated_at_utc": datetime.now(timezone.utc).isoformat(),
        "root": str(root_path),
        "counts": {
            "theorem_corpus": len(corpus),
            "alias_map": len(aliases),
            "unresolved_aliases": len(unresolved_aliases),
            "theorem_rows_with_proof_hints": sum(1 for it in corpus if it.get("proof_hints")),
        },
        "rg_baseline": {
            "available": rg_info.get("available", False),
            "count": rg_info.get("count"),
            "count_diff_export_minus_rg": None
            if rg_info.get("count") is None
            else len(corpus) - int(rg_info["count"]),
            "missing_from_export_count": len(missing),
            "extra_vs_rg_count": len(extra),
            "missing_from_export": [
                {"source_path": p, "source_line": ln, "short_name": nm}
                for (p, ln, nm) in missing
            ],
            "extra_vs_rg": [
                {"source_path": p, "source_line": ln, "short_name": nm}
                for (p, ln, nm) in extra
            ],
            "stderr": rg_info.get("stderr", ""),
        },
        "unresolved_aliases": list(unresolved_aliases),
        "manual_check_sample_20": sample_for_manual_check(corpus, n=20),
        "retrieval_smoke_test": retrieval_smoke,
    }
    return report


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Export MechLib theorem corpus for LLM RAG.")
    parser.add_argument("--root", default="MechLib", help="Root directory to scan (default: MechLib)")
    parser.add_argument("--out", default="theorem_corpus.jsonl", help="Output theorem corpus JSONL path")
    parser.add_argument("--alias-out", default="alias_map.jsonl", help="Output alias JSONL path")
    parser.add_argument("--report-out", default="export_report.json", help="Output report JSON path")
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    repo_root = Path.cwd()
    root_path = (repo_root / args.root).resolve()
    out_path = (repo_root / args.out).resolve()
    alias_out_path = (repo_root / args.alias_out).resolve()
    report_out_path = (repo_root / args.report_out).resolve()

    if not root_path.exists():
        raise FileNotFoundError(f"Scan root does not exist: {root_path}")

    corpus = parse_theorems(root_path, repo_root)
    corpus.sort(key=lambda x: (x["source_path"], int(x["source_line"]), x["fq_name"]))

    theorem_by_fq, theorem_by_short = build_theorem_indices(corpus)

    compat_path = root_path / "Compat" / "PHYSlib.lean"
    aliases, unresolved_aliases = parse_aliases(
        compat_path=compat_path,
        repo_root=repo_root,
        theorem_by_fq=theorem_by_fq,
        theorem_by_short=theorem_by_short,
    )
    aliases.sort(key=lambda x: (x.alias_fq_name, x.alias_name))

    rg_info = run_rg_baseline(root_path, repo_root)
    retrieval_smoke = run_retrieval_smoke_test(corpus, aliases)
    report = build_report(
        root_path=root_path,
        corpus=corpus,
        aliases=aliases,
        unresolved_aliases=unresolved_aliases,
        rg_info=rg_info,
        retrieval_smoke=retrieval_smoke,
    )

    write_jsonl(out_path, (TheoremItem(**it).to_json() for it in corpus))
    write_jsonl(alias_out_path, (a.to_json() for a in aliases))
    report_out_path.write_text(
        json.dumps(report, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )

    print(f"[export] theorem corpus: {out_path} ({len(corpus)} rows)")
    print(f"[export] alias map:     {alias_out_path} ({len(aliases)} rows)")
    print(f"[export] report:        {report_out_path}")
    if report["rg_baseline"]["count"] is not None:
        print(
            f"[check] rg baseline={report['rg_baseline']['count']} "
            f"diff={report['rg_baseline']['count_diff_export_minus_rg']} "
            f"missing={report['rg_baseline']['missing_from_export_count']}"
        )
    smoke = report["retrieval_smoke_test"]
    print(f"[check] retrieval smoke: {smoke['passed']}/{smoke['total']} passed")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
