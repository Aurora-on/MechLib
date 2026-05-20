# Mechanics Declaration Migration Report

## Scope

本报告记录 `MechLib.Mechanics.*` 中 theorem/lemma 声明迁移到新课程层地址的结果。

本轮目标是“证明声明迁移”，不是删除旧 API。旧 `MechLib.Mechanics.*` 文件仍保留 def/structure/schema 和 compatibility `abbrev`，以避免破坏已有 import；但旧目录不再作为 theorem/lemma 的主声明位置。

## New Proof Locations

非分析力学部分的 theorem/lemma 统一迁移到课程层 `Verified` 模块：

| Old Mechanics module | New theorem module | Count |
| --- | --- | ---: |
| `MechLib.Mechanics.Kinematics` | `MechLib.Kinematics.Verified.Kinematics` | 24 |
| `MechLib.Mechanics.Dynamics` | `MechLib.Dynamics.Verified.Dynamics` | 4 |
| `MechLib.Mechanics.WorkEnergy` | `MechLib.Dynamics.Verified.WorkEnergy` | 7 |
| `MechLib.Mechanics.MomentumImpulse` | `MechLib.Dynamics.Verified.MomentumImpulse` | 3 |
| `MechLib.Mechanics.SystemDynamics` | `MechLib.Dynamics.Verified.SystemDynamics` | 14 |
| `MechLib.Mechanics.Rotation` | `MechLib.RigidBody.Verified.Rotation` | 7 |
| `MechLib.Mechanics.SHM` | `MechLib.Systems.Verified.SHM` | 7 |
| `MechLib.Mechanics.DampedSHM` | `MechLib.Systems.Verified.DampedSHM` | 21 |
| `MechLib.Mechanics.CentralForce` | `MechLib.Systems.Verified.CentralForce` | 15 |

这些新文件已被对应聚合入口 import：

- `MechLib/Kinematics.lean`
- `MechLib/Dynamics.lean`
- `MechLib/RigidBody.lean`
- `MechLib/Systems.lean`

## Analytical Mechanics

分析力学部分已在前一轮迁移到语义更具体的新课程层文件：

| Old declaration group | New home |
| --- | --- |
| 1D Lagrangian / Euler-Lagrange bridge | `MechLib.Analytical.LagrangeEquation` |
| canonical momentum / Hamiltonian / canonical equations | `MechLib.Analytical.Hamiltonian` |
| cyclic coordinate conservation | `MechLib.Analytical.ConservationLaw` |
| Poisson bracket | `MechLib.Analytical.PoissonBracket` |
| Lagrange multiplier constraint bridge | `MechLib.Analytical.Constraints` |

`MechLib.Mechanics.AnalyticalMechanics` 现在作为兼容层保留旧名称。

## Compatibility Rule

旧 `MechLib.Mechanics.*` 中原 theorem/lemma 对应名称现在是 compatibility `abbrev`，用于保留旧代码的证明项可用性。新 theorem corpus、Spec/Coverage metadata、manual overrides 和 retrieval smoke test 均指向新课程层 theorem 地址。

由于旧 `Mechanics` 文件仍承载若干 def/structure/schema 实现，新 `Verified` theorem 需要 import 这些旧实现层模块；旧层不能反向 import 新 `Verified` theorem，否则会形成 import cycle。因此旧证明名称保留为 compatibility `abbrev` proof term，而不是 theorem/lemma 声明。

示例：

| Compatibility name | Retrieval-facing theorem |
| --- | --- |
| `MechLib.Mechanics.Kinematics.constant_speed_relation` | `MechLib.Kinematics.Verified.Kinematics.constant_speed_relation` |
| `MechLib.Mechanics.Dynamics.newton_second_law` | `MechLib.Dynamics.Verified.Dynamics.newton_second_law` |
| `MechLib.Mechanics.WorkEnergy.work_energy_theorem_core` | `MechLib.Dynamics.Verified.WorkEnergy.work_energy_theorem_core` |
| `MechLib.Mechanics.Rotation.parallel_axis_theorem` | `MechLib.RigidBody.Verified.Rotation.parallel_axis_theorem` |
| `MechLib.Mechanics.SHM.period_frequency_relation` | `MechLib.Systems.Verified.SHM.period_frequency_relation` |

## Remaining Old Mechanics Content

旧 `Mechanics` 目录仍包含：

- core `def` / `structure` objects used by existing wrappers;
- residual/schema interfaces such as transport theorem, angular-momentum theorem interfaces, variable-mass balance, and central-force equation schemas;
- compatibility `abbrev` proof names.

这些不是本轮的 theorem/lemma 迁移对象。若后续希望完全移除 `Mechanics` 作为实现层，需要单独做 def/structure 级别的 dependency inversion。

## Verification

已执行：

```bash
lake build
python3 tools/export_coverage_matrix.py
python3 tools/export_coverage_matrix.py --check
python3 tools/export_spec_corpus.py
python3 tools/export_llm_corpus.py --out corpus/theorem_corpus.jsonl --alias-out corpus/alias_map.jsonl --report-out corpus/export_report.json
python3 tools/link_theorems_to_spec.py
python3 tools/check_no_new_axioms.py
rg -n "^\\s*(?:@\\[[^\\]]+\\]\\s*)?(theorem|lemma)\\s+" MechLib/Mechanics
```

结果：

- `lake build` 通过。
- `MechLib/Mechanics` 下无 theorem/lemma 声明残留。
- `theorem_corpus.jsonl` 共 243 行，`rg` baseline diff 为 0。
- retrieval smoke test 为 10/10。
- Spec alignment 为 243/243 matched，55 条 needs review，150 条 callable。
- axiom/sorry audit 当前 0，新增 0。
