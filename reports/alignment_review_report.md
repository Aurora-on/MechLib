# Spec-Declaration Alignment Review Report

## 任务范围

本轮只复查 `decl_corpus_enriched.jsonl` 中 `needs_review = true` 的 Spec-declaration alignment。未修改 Lean theorem/proof 文件，未修改 pipeline，未建立 benchmark。

## 复查结果

| 指标 | 复查前 | 复查后 |
| --- | ---: | ---: |
| total declarations | 243 | 243 |
| matched declarations | 243 | 243 |
| needs review | 55 | 3 |
| callable by LLM | 150 | 199 |
| average alignment score | 0.748642 | 0.884280 |

复查前的 55 条 `needs_review` 全部是 verified theorem/lemma，主要原因是自动匹配分数低于阈值，不是 schema 被错误放入 proof whitelist。

## 手工 Override

本轮在 `tools/export_overrides.yaml` 增加了 `Alignment review phase 1` 分组，共 55 条手工 override。

### Kinematics

补充了 20 条 `MechLib.Kinematics.Verified.Kinematics.*` 映射：

- 点运动 rewrite：`displacement_eq_sub`, `position_from_displacement`, `hasVelocity_linear_combination`, `hasAcceleration_linear_combination`
- 相对运动 rewrite/lemma：`trajectory_reconstruction`, `relative_trajectory_trans`, `relative_velocity_trans`, `relative_acceleration_trans`, `hasVelocity_relative`, `hasAcceleration_relative`, `vec_relative_trajectory_trans`, `vec_relative_velocity_trans`, `hasVecVelocity_relative`, `hasVecAcceleration_relative`
- 约束相关 lemma：`linear_constraint_velocity`, `linear_constraint_acceleration`, `rope_constraint_velocity`, `pfaffConstraint1D_linear_combination`
- 刚体约束相关 lemma：`rigid_pair_velocity_equal`, `rigid_pair_vec_velocity_equal`

主要修正方向：

- 点运动映射到 `kinematics.point_motion`
- 相对运动映射到 `kinematics.relative_motion`
- 约束关系映射到 `analytical.constraints`
- 刚体相对约束映射到 `kinematics.rigid_body_motion`

### Dynamics

补充了 9 条 `MechLib.Dynamics.Verified.*` 映射：

- `work_def` 映射到 `dynamics.work_energy`
- `momentum_conservation_inelastic` 映射到 `dynamics.collision`
- `totalMomentum_nil`, `totalMomentum_cons` 映射到 `dynamics.momentum`
- 质心和系统动力学相关 theorem 映射到 `dynamics.system_dynamics`
- `variableMassMomentumBalance_eq` 映射到 `dynamics.variable_mass`

### RigidBody

补充了 3 条 `MechLib.RigidBody.Verified.Rotation.*` 映射：

- `parallel_axis_theorem` 映射到 `rigidbody.inertia`
- `rigidBodyKineticDecomposition_eq` 映射到 `rigidbody.plane_motion_dynamics`
- `momentOfMomentumTheoremSystem_eq` 映射到 `dynamics.angular_momentum`

### Systems

补充了 23 条 `MechLib.Systems.Verified.*` 映射：

- SHM：`initialPosition_eq`, `amplitudeFromInitial_nonneg`, `turningPoint_def`
- DampedSHM：正性 helper、固有频率、阻尼分类、无阻尼退化、能量耗散和闭式解接口相关 theorem
- CentralForce：中心力、径向方程、Kepler 第二定律、反平方轨道分类
- CentralForce 内部有限维索引 helper：`fin_induction_three_one`, `fin_induction_three_two`, `fin_induction_two_one`

## callable_by_llm 修正

阶段 1 中以下 helper-only 声明曾被显式保持为 `callable_by_llm = false`：

- `MechLib.Systems.Verified.DampedSHM.m_ne_zero`
- `MechLib.Systems.Verified.DampedSHM.k_ne_zero`
- `MechLib.Systems.Verified.DampedSHM.omega0_pos`
- `MechLib.Systems.Verified.CentralForce.fin_induction_three_one`
- `MechLib.Systems.Verified.CentralForce.fin_induction_three_two`
- `MechLib.Systems.Verified.CentralForce.fin_induction_two_one`

2026-05-16 复核后，阻尼振子正性/非零 helper 被重新标记为 `side_condition` 并允许 LLM 调用，因为它们可以帮助 E 阶段处理真实物理参数的正性与分母非零条件。`fin_induction_*` 仍保持不可调用和 `needs_review = true`，因为它们是内部有限维索引 helper，不是课程语义 theorem。

## 仍需 Review 的声明

复查后仍保留 3 条 `needs_review = true`：

| Declaration | primary_spec_id | callable_by_llm | 原因 |
| --- | --- | --- | --- |
| `MechLib.Systems.Verified.CentralForce.fin_induction_three_one` | `foundation.vector_quantity` | false | 有限维索引 helper，不是课程语义 theorem。 |
| `MechLib.Systems.Verified.CentralForce.fin_induction_three_two` | `foundation.vector_quantity` | false | 有限维索引 helper，不是课程语义 theorem。 |
| `MechLib.Systems.Verified.CentralForce.fin_induction_two_one` | `foundation.vector_quantity` | false | 有限维索引 helper，不是课程语义 theorem。 |

这些声明暂挂到 `foundation.vector_quantity`，用于来源追踪。后续如果新增 `foundation.fin_helpers` 或 `foundation.index_helpers` topic，可再移除 review 标记。

## 安全性检查

本轮检查结果：

- schema/interface/todo 没有进入 proof whitelist。
- 所有 `callable_by_llm = true` 的声明均满足：
  - `status = verified`
  - `trust_level ∈ {core, derived}`
  - `required_imports` 非空
- override 文件没有重复 declaration key。

## 执行命令

```bash
python3 tools/link_theorems_to_spec.py
python3 -m py_compile tools/link_theorems_to_spec.py
lake build
rg -n "^\\s*(axiom|constant|opaque)\\b|\\b(sorry|admit)\\b" MechLib tools || true
```

## 后续建议

- 将 `fin_induction_*` helper 迁移到更合适的 helper topic 后，再取消 `needs_review`。
- 对剩余 proof helper 可考虑新增 `premise_role = helper` 的专门检索降权规则。
- 后续新增 theorem 时，优先同步 `tools/export_overrides.yaml`，避免新 theorem 仅靠 keyword/module heuristic 低置信匹配。

## 后续同步更新：P0 Extractor 与展示样例降级

2026-05-15 重新导出后，课程层新增了一批可真实证明的 extractor theorem，并将 `FinalTheoremDemos` 中的展示 theorem 从 proof callable 集合中降级为 example：

- total declarations: 281
- matched declarations: 281
- needs review: 3
- callable by LLM: 230
- average alignment score: 0.895587

新增的 proof-whitelist 友好 extractor 包括：

- `MechLib.Dynamics.NewtonLaw.NewtonSecondLaw.to_value_equation`
- `MechLib.Dynamics.NewtonLaw.forceBalance1D_to_value_equation`
- `MechLib.Dynamics.NewtonLaw.forceSum2Relation_to_value_equation`
- `MechLib.Kinematics.PointMotion.constantAccelerationVelocityRelation_to_value_equation`
- `MechLib.Kinematics.PointMotion.componentVelocityDerivativeRelation_of_hasVecVelocity`
- `MechLib.Statics.Friction.kineticFrictionLaw_to_value_equation`
- `MechLib.RigidBody.FixedAxisDynamics.fixedAxisDynamicsResidual_to_value_equation`
- `MechLib.Dynamics.WorkEnergy.rotationalKineticEnergy_to_value_equation`

`FinalTheoremDemos` 中的展示 theorem 仍然是 Lean verified theorem，但现在标记为 `trust_level = example`、`callable_by_llm = false`。它们用于说明 proof pattern，不再作为 proof whitelist 的首选事实。

## 后续同步更新：P1 typed schema extractors

2026-05-15 继续补强 P1 后，新增了绳/滑轮/capstan、惯量、刚体平面动能、质心位移、相对位移和二维分解相关的 typed schema extractor：

- total declarations: 299
- matched declarations: 299
- needs review: 3
- callable by LLM: 248
- average alignment score: 0.901873

新增的 P1 extractor 包括：

- `MechLib.Statics.ConstraintForce.idealRopeUniformTension_to_value_equation`
- `MechLib.Statics.ConstraintForce.idealPulleySharedAcceleration_to_value_equation`
- `MechLib.Statics.ConstraintForce.noSlipPulleyVelocityRelation_to_value_equation`
- `MechLib.Statics.ConstraintForce.noSlipPulleyAccelerationRelation_to_value_equation`
- `MechLib.Statics.Friction.capstanTensionRatio_to_value_equation`
- `MechLib.Statics.Friction.capstanTensionBound_to_value_inequality`
- `MechLib.RigidBody.Inertia.pointMassMomentOfInertia_to_value_equation`
- `MechLib.RigidBody.Inertia.slenderRodMomentOfInertiaCenter_to_value_equation`
- `MechLib.RigidBody.PlaneMotionDynamics.planeMotionKineticEnergy_to_value_equation`
- `MechLib.Dynamics.SystemDynamics.centerOfMassDisplacement2_to_value_equation`
- `MechLib.Kinematics.RelativeMotion.relativeDisplacementValueRelation_to_value_equation`
- `MechLib.Kinematics.CoordinateMotion.forceComponentsFromAngle_to_value_equations`

这些 theorem 只从显式 schema/predicate 假设中抽取值级等式或不等式，不声称无条件证明 capstan、理想绳、滑轮等物理定律；因此可以作为 proof search 中的 extractor 使用，但对应模型假设仍必须出现在 theorem statement 或 proof obligation 中。

## 后续同步更新：闭式导数与曲线/幅值 bridge extractors

2026-05-15 继续补通用运动学 bridge 后，新增了闭式位置/速度公式到速度/加速度、分量导数、角运动导数、参数曲线速度和二维力幅值相关的 verified extractor：

- total declarations: 310
- matched declarations: 310
- needs review: 3
- callable by LLM: 259
- average alignment score: 0.905355

新增的 proof-whitelist 友好 extractor 包括：

- `MechLib.Kinematics.PointMotion.velocity_value_eq_deriv_of_position_value`
- `MechLib.Kinematics.PointMotion.acceleration_value_eq_deriv_of_velocity_value`
- `MechLib.Kinematics.PointMotion.component_velocity_value_eq_deriv_of_position_component_value`
- `MechLib.Kinematics.PointMotion.component_acceleration_value_eq_deriv_of_velocity_component_value`
- `MechLib.Kinematics.PointMotion.secondDerivativeRelation_of_velocity_acceleration`
- `MechLib.Kinematics.PointMotion.acceleration_value_eq_second_deriv_of_position_value`
- `MechLib.Kinematics.FixedAxisRotation.angular_velocity_value_eq_deriv_of_angle_value`
- `MechLib.Kinematics.FixedAxisRotation.angular_acceleration_value_eq_deriv_of_omega_value`
- `MechLib.Kinematics.CoordinateMotion.forceMagnitude2D_to_value_equation`
- `MechLib.Kinematics.CoordinateMotion.parametric_curve_speed_squared`
- `MechLib.Kinematics.CoordinateMotion.arc_length_speed_relation`

这些 theorem 的作用是把题目中常见的闭式函数公式、坐标分量公式、角运动公式和幅值关系转换成 Lean 可检索、可回放的值级等式。它们不绕过微积分证明：导数信息仍通过 `HasDerivAt`、`VelocityDerivativeRelation`、`AccelerationDerivativeRelation`、`HasAngularVelocity`、`HasAngularAcceleration` 或显式 relation hypothesis 提供。

## 后续同步更新：callable whitelist 复核与扩展

2026-05-16 对最近几轮新增 theorem 和历史未 callable 的 verified/derived 声明做复核后，补充了人工 override，将安全的量纲 bridge、值级展开、运动学 rewrite、系统方程展开和正性 side-condition helper 纳入 proof whitelist。

- total declarations: 310
- matched declarations: 310
- needs review: 3
- callable by LLM: 301
- average alignment score: 0.968129

本轮提升为 callable 的声明主要包括：

- `MechLib.Units.VecQuantity.val_zero`, `val_add`, `val_sub`, `val_neg`, `val_smul`, `cast_val`, `val_qmul_vec`, `val_vecmul_q`, `dot_val`
- `MechLib.Foundation.Dim.dimensionBridge_eq`
- `MechLib.Kinematics.Verified.Kinematics.constant_speed_relation`, `velocity_increment`, `displacement_forms_equiv`, `vec_velocity_const_accel_eq`
- `MechLib.Dynamics.Verified.WorkEnergy.hooke_force_eq`, `kineticEnergy_change_formula`, `work1D_def`
- `MechLib.RigidBody.Verified.Rotation.rotationalKineticEnergy_eq`
- `MechLib.Systems.Verified.SHM.acceleration_eq_neg_omega_sq_mul_pos`, `initialVelocity_eq`
- `MechLib.Systems.Verified.DampedSHM.m_ne_zero`, `k_ne_zero`, `omega0_pos`, `equationResidual_eq`, `discriminant_eq`
- `MechLib.Systems.Verified.CentralForce.cross_self_zero`, `hookeCentralForce_eq`, `inverseSquarePotential_eq`

仍不可调用的声明只有两类：

- `FinalTheoremDemos` 中 6 个展示用 theorem，保留 `trust_level = example`、`callable_by_llm = false`；
- `CentralForce.fin_induction_*` 3 个内部索引 helper，保留 `needs_review = true`、`callable_by_llm = false`。
