# MechLib

MechLib 是一个基于 Lean 4 的经典力学语义库，面向工科本科理论力学、分析力学和典型力学系统建模。它的目标不是只收集公式，而是把课程概念、带量纲物理量、verified theorem、schema metadata 和可检索 corpus 组织成一个可供自动形式化系统使用的知识库。

MechLib 的核心特色之一是 typed physical quantities。库中的公开物理 API 优先使用 `MechLib.SI` 类型别名、`MechLib.Units.Quantity` 和 `MechLib.Units.VecQuantity`，使 `Length`、`Mass`、`Force`、`Energy` 等物理量在 Lean 类型层面保留量纲信息。裸 `ℝ` 主要用于无量纲系数、索引、坐标图数值、`.val` 投影、metadata 或明确标记的 temporary fallback。

MechLib 目前是研究型语义库。它已经包含一批经过 Lean 检查的 theorem/lemma、课程层 API、Spec 层、coverage matrix、corpus exporter 和 Spec-declaration alignment；但它没有声称已经 fully proved 全部本科理论力学。复杂内容会以 schema、residual、interface 或 problem template 的形式保留，用于建模、检索和规划，而不是伪装成 verified theorem。

## 当前实现概览

当前仓库已经具备以下内容：

- `Units / SI / Quantity / VecQuantity`：量纲、标量物理量、向量物理量、SI 类型别名与 bridge lemmas。
- 课程层模块：`Foundation`、`Statics`、`Kinematics`、`Dynamics`、`RigidBody`、`Analytical`、`Systems`。
- `Spec` 层：`DeclStatus`、`TrustLevel`、`ConceptSpec`、`LawSchema`、`ProblemSchema`、`CoverageTopic`、`ModuleMetadata`。
- coverage matrix：本科理论力学主题覆盖矩阵。
- theorem corpus：Lean theorem/lemma 的可检索 JSONL。
- Spec-declaration alignment：theorem 与 topic/concept/law/problem schema 的映射。
- proof hints：导出器为 theorem rows 保留 `proof_hints` 字段。
- proof-friendly examples：展示 typed proof pattern 的 Lean 示例。

当前已生成 corpus/report 文件中的统计如下：

| 项目 | 当前数量 |
| --- | ---: |
| `corpus/theorem_corpus.jsonl` | 310 theorem/lemma rows |
| `corpus/decl_corpus_enriched.jsonl` | 310 enriched declaration rows |
| `corpus/alias_map.jsonl` | 4 aliases |
| `corpus/concept_corpus.jsonl` | 9 concepts |
| `corpus/law_schema_corpus.jsonl` | 10 law schemas |
| `corpus/problem_schema_corpus.jsonl` | 12 problem schemas |
| `corpus/module_metadata_corpus.jsonl` | 53 module metadata rows |

Coverage matrix 当前状态：

- 7 个章节；
- 53 个 topic；
- status 分布：`verified = 21`, `schema = 19`, `todo = 13`；
- trust 分布：`core = 12`, `derived = 9`, `interface = 24`, `example = 8`；
- 中英文 alias 覆盖率：100%。

Spec-declaration alignment 当前状态：

- matched declarations: 310 / 310；
- unmatched declarations: 0；
- needs review: 3；
- callable by LLM: 301；
- average alignment score: 0.968129。

安全审计当前状态：

- `axiom` / `constant` / `opaque` / `sorry` / `admit` 当前出现次数：0；
- `check_no_new_axioms.py` 报告 `pass_no_new_uncontrolled_unsafe_decl = true`。

这些数字来自当前仓库中的 `corpus/*.json(l)` 与 `reports/*.md`。如果新增 theorem 或 example 后需要更新 corpus，请重新运行导出命令。

## 目录结构

```text
MechLib/
├─ lakefile.toml
├─ lean-toolchain
├─ MechLib.lean
├─ MechLib/
│  ├─ Units/                 量纲、标量物理量、向量物理量、bridge lemmas
│  ├─ SI.lean                SI 类型别名、单位、维度等式
│  ├─ Mechanics/             兼容实现层，保留旧 API 和部分基础定义
│  ├─ Foundation/            量纲、物理量、参考系、坐标系、几何基础
│  ├─ Statics/               力系、力矩、力偶、平衡、约束、摩擦、桁架
│  ├─ Kinematics/            点运动、坐标运动、相对运动、刚体运动、定轴转动
│  ├─ Dynamics/              牛顿定律、质点动力学、动量、冲量、功-能、碰撞等
│  ├─ RigidBody/             惯量、定轴动力学、平面运动、Euler 方程、陀螺 schema
│  ├─ Analytical/            广义坐标、约束、虚功、Lagrange、Hamilton、Poisson、小振动
│  ├─ Systems/               单摆、物理摆、中心力、Atwood 机、耦合振子等系统案例
│  ├─ Spec/                  coverage、concept、law schema、problem schema、module catalog
│  ├─ Examples/              proof-friendly checked examples
│  └─ Compat/PHYSlib.lean    PHYSlib 风格兼容名称
├─ tools/                    exporter、alignment、审计脚本
├─ corpus/                   已生成的 JSON/JSONL/Markdown 语料
├─ docs/                     使用说明和项目边界文档
└─ reports/                  人类可读审计与迁移报告
```

顶层导入：

```lean
import MechLib
```

## Verified / Schema / Example / Alignment

MechLib 严格区分以下层次：

| 层次 | 含义 | 是否可作为 proof fact |
| --- | --- | --- |
| verified theorem/lemma | 已通过 Lean kernel 检查的 theorem 或 lemma。 | 可以，前提是 `status = verified` 且 trust/whitelist 允许。 |
| schema/residual/interface | 概念接口、规律 schema、残量方程或题型接口。 | 不可以，只用于建模、检索和规划。 |
| example | checked example、smoke test 或展示样例。 | 可作为局部示范，不等价于通用 theorem。 |
| alignment metadata | theorem 与 Spec topic/concept/law/problem schema 的映射。 | 不可以，它只是检索和约束生成元数据。 |

`concept_corpus.jsonl`、`law_schema_corpus.jsonl` 和 `problem_schema_corpus.jsonl` 不是 proof corpus。后续 pipeline 的 proving 阶段应只使用 verified/core 或 verified/derived declaration，具体以 `decl_corpus_enriched.jsonl` 中的 `status`、`trust_level`、`callable_by_llm` 和 required imports 为准。

## 量纲系统

核心量纲模块包括：

- `MechLib.Units.Dim`
- `MechLib.Units.Quantity`
- `MechLib.Units.VecQuantity`
- `MechLib.SI`
- `MechLib.Units.BridgeLemmas`

常见 typed 物理对象包括：

- `Length`, `Mass`, `Time`, `Speed`, `Acceleration`
- `Force`, `Momentum`, `Energy`, `Power`
- `Torque`, `AngularMomentum`, `MomentOfInertia`
- `VecLength n`, `VecForce n`, `VecTorque n`

示例：

```lean
import MechLib

#check MechLib.SI.Length
#check MechLib.SI.Force
#check MechLib.Units.Quantity.cast
#check MechLib.Units.VecQuantity.cast
#check MechLib.SI.speed_time_eq_length
```

量纲审计报告位于：

- `reports/dimension_audit_report.md`
- `corpus/dimension_audit_report.json`

当前审计显示核心量纲模块仍存在并被顶层导入；课程层仍有若干 `ℝ` fallback 和 review candidates，详见限制文档。

## 课程层与旧 Mechanics 层

`MechLib.Mechanics.*` 是较早的实现层和兼容层。当前 retrieval-facing 的 theorem/lemma 主位置逐步迁移到课程层，例如：

- `MechLib.Kinematics.Verified`
- `MechLib.Dynamics.Verified`
- `MechLib.RigidBody.Verified`
- `MechLib.Systems.Verified`
- `MechLib.Analytical.*`

旧 `Mechanics` 名称在必要时保留为兼容 API。相关迁移报告：

- `reports/mechanics_migration_report.md`

新增 theorem 时，应优先放到对应课程 Lean 模块，而不是继续扩展旧 `Mechanics` theorem API。Spec 文件只放 metadata、schema 或 corpus source of truth，不放 fake theorem。

## 展示样例

最终展示样例位于：

- `MechLib/Examples/FinalTheoremDemos.lean`
- `docs/final_theorem_demos.md`

当前包含 3 组 fully checked Lean theorem。它们用于展示证明风格，alignment 中标记为 `trust_level = example` 且 `callable_by_llm = false`；proof whitelist 的首选入口是课程层 verified/core 或 verified/derived extractor theorem。

1. `uniformAccelerationDisplacement_byCalculation`
   展示匀加速运动位移公式如何通过 typed quantity、`Quantity.cast`、`.val` 投影和 `ring` 证明。

2. `workEnergyBalance_byValueAlgebra` 与 `impulseMomentum_byValueAlgebra`
   展示动能定理核心代数形式与冲量-动量形式如何通过 `.val`、`linarith`、`ext` 证明。

3. `eulerLagrangeNewtonBridge_byResidualAlgebra`
   展示 1D Euler-Lagrange residual 与 Newton form 如何通过展开定义和残量代数建立等价。

这些样例是 verified theorem，不依赖 schema 作为 proof fact。一般 n 自由度 Euler-Lagrange 到 Newton/Hamiltonian 的完整桥接仍是 future work。

近期新增的 proof-whitelist 友好 extractor theorem 包括：

- `MechLib.Dynamics.NewtonLaw.NewtonSecondLaw.to_value_equation`
- `MechLib.Dynamics.NewtonLaw.forceBalance1D_to_value_equation`
- `MechLib.Kinematics.PointMotion.constantAccelerationVelocityRelation_to_value_equation`
- `MechLib.Statics.Friction.kineticFrictionLaw_to_value_equation`
- `MechLib.RigidBody.FixedAxisDynamics.fixedAxisDynamicsResidual_to_value_equation`
- `MechLib.Dynamics.WorkEnergy.rotationalKineticEnergy_to_value_equation`
- `MechLib.Statics.ConstraintForce.idealRopeUniformTension_to_value_equation`
- `MechLib.Statics.ConstraintForce.noSlipPulleyVelocityRelation_to_value_equation`
- `MechLib.Statics.Friction.capstanTensionRatio_to_value_equation`
- `MechLib.RigidBody.Inertia.pointMassMomentOfInertia_to_value_equation`
- `MechLib.RigidBody.PlaneMotionDynamics.planeMotionKineticEnergy_to_value_equation`
- `MechLib.Dynamics.SystemDynamics.centerOfMassDisplacement2_to_value_equation`
- `MechLib.Kinematics.RelativeMotion.relativeDisplacementValueRelation_to_value_equation`
- `MechLib.Kinematics.CoordinateMotion.forceComponentsFromAngle_to_value_equations`
- `MechLib.Kinematics.PointMotion.velocity_value_eq_deriv_of_position_value`
- `MechLib.Kinematics.PointMotion.acceleration_value_eq_deriv_of_velocity_value`
- `MechLib.Kinematics.PointMotion.component_velocity_value_eq_deriv_of_position_component_value`
- `MechLib.Kinematics.PointMotion.component_acceleration_value_eq_deriv_of_velocity_component_value`
- `MechLib.Kinematics.PointMotion.acceleration_value_eq_second_deriv_of_position_value`
- `MechLib.Kinematics.FixedAxisRotation.angular_velocity_value_eq_deriv_of_angle_value`
- `MechLib.Kinematics.FixedAxisRotation.angular_acceleration_value_eq_deriv_of_omega_value`
- `MechLib.Kinematics.CoordinateMotion.forceMagnitude2D_to_value_equation`
- `MechLib.Kinematics.CoordinateMotion.parametric_curve_speed_squared`
- `MechLib.Kinematics.CoordinateMotion.arc_length_speed_relation`

## 构建与检查

构建主库：

```bash
lake build
```

检查指定文件：

```bash
lake env lean MechLib/Examples/FinalTheoremDemos.lean
lake env lean MechLib/Spec/Coverage.lean
lake env lean MechLib/Analytical/LagrangeEquation.lean
```

安全扫描：

```bash
rg -n "^\\s*(axiom|constant|opaque)\\b|\\b(sorry|admit)\\b" MechLib tools || true
python3 tools/check_no_new_axioms.py
```

Python 脚本语法检查：

```bash
python3 -m py_compile \
  tools/export_coverage_matrix.py \
  tools/export_spec_corpus.py \
  tools/export_llm_corpus.py \
  tools/link_theorems_to_spec.py \
  tools/audit_dimension_usage.py \
  tools/check_no_new_axioms.py
```

## 导出命令

Coverage matrix：

```bash
python3 tools/export_coverage_matrix.py
python3 tools/export_coverage_matrix.py --check
```

Spec corpus：

```bash
python3 tools/export_spec_corpus.py
```

Theorem corpus 与 proof hints：

```bash
python3 tools/export_llm_corpus.py \
  --out corpus/theorem_corpus.jsonl \
  --alias-out corpus/alias_map.jsonl \
  --report-out corpus/export_report.json
```

Spec-declaration alignment：

```bash
python3 tools/link_theorems_to_spec.py
```

量纲使用审计：

```bash
python3 tools/audit_dimension_usage.py
```

axiom / sorry 审计：

```bash
python3 tools/check_no_new_axioms.py
```

## 当前边界

MechLib 当前不声称完成以下内容：

- 不声称本科理论力学所有 theorem 都已 fully proved。
- 不声称所有 schema/residual 都已经提升为 verified theorem。
- 不声称下游 pipeline 的 generation/proving workflow 已在本仓库完整实现。
- 不声称所有系统层模型都已经完全 typed 且完全验证。
- 不把 schema corpus 当作 proof corpus。

更详细的当前限制见：

- `docs/current_limitations.md`

## 开发规范

核心规则：

1. 公开物理 API 优先使用 `Quantity`、`VecQuantity` 和 `MechLib.SI` 类型别名。
2. 不要在课程层重新定义 `Length`、`Mass`、`Force`、`Energy` 等核心物理量类型。
3. theorem 放课程 Lean 模块；Spec 只放 metadata/schema。
4. verified theorem、schema、alias、experimental、todo 必须严格分层。
5. 不引入 `axiom`。
6. 不新增不受控 `sorry` 或 `admit`。
7. 不把复杂未证明内容写成 fake theorem。
8. 新增 theorem 后同步考虑 exporter、proof hints 和 alignment。
9. 新增 schema 后确保它只进入 schema/problem/concept corpus，不进入 proof whitelist。
10. 除非有明确迁移任务，不破坏旧 API 兼容性。

详细开发规范见：

- `docs/development_guidelines.md`

## 与未来 pipeline 的关系

MechLib 已经导出后续 pipeline 可使用的数据形态，包括 coverage matrix、theorem corpus、Spec corpus、module metadata、Spec-declaration alignment 和 enriched declaration corpus。这些产物支持未来从题目文本匹配到课程 topic、concept/law/problem schema，再反查 verified theorem 的检索流程。

需要明确的是：本仓库当前主要提供 Lean 语义库和导出产物，不声称 pipeline 的所有 generation、retrieval orchestration、benchmark 和 proof-agent workflow 已在这里完成。

## 重要报告

- `reports/mechanics_migration_report.md`
- `reports/alignment_review_report.md`
- `reports/dimension_audit_report.md`
- `reports/axiom_sorry_report.md`
- `corpus/spec_export_report.json`
- `corpus/spec_alignment_report.json`
- `corpus/export_report.json`
- `corpus/dimension_audit_report.json`
