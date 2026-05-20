# Theorem Callable Audit 2026-05-16

## 审计目标

本次审计复查最近几轮新增和调整的 MechLib theorem，重点确认：

1. 新增 theorem 不是 fake theorem。
2. schema/residual 没有被伪装成无条件物理定律。
3. 适合作为 proof search 事实的 verified/core 或 verified/derived theorem 尽量进入 `callable_by_llm = true`。
4. 展示 example 和内部证明 helper 不进入 proof whitelist。

## 当前统计

- theorem corpus rows: 310
- enriched declarations: 310
- matched declarations: 310 / 310
- needs review: 3
- callable by LLM: 301
- average alignment score: 0.968129

## 合理性结论

最近补充的 theorem 主要是 extractor / bridge / rewrite theorem。它们的共同特点是：

- 结论只从显式 hypothesis 中抽取 Lean 可用的值级等式、导数关系或量纲投影；
- 未把复杂物理规律无条件写成 theorem；
- 需要微积分事实时，仍要求 `HasDerivAt` 或已有 derivative relation 作为前提；
- 需要物理模型关系时，仍要求显式 relation hypothesis 作为前提；
- proof 都由 Lean kernel 检查通过，没有 `axiom`、`sorry`、`admit`。

因此这些 theorem 可以进入 proof whitelist，供 LLM-guided proof search 作为 verified extractor 使用。

## 新增闭式导数与曲线 bridge

合理并已设为 callable 的代表声明：

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

这些 theorem 不声称自动求导。它们要求题目或前序阶段提供闭式函数导数 `HasDerivAt`，再通过 `HasDerivAt.unique` 或显式 relation 抽取速度、加速度、角速度、角加速度和曲线速度关系。

## 本次提升为 callable 的历史 verified theorem

本次将一批原本因自动匹配分数偏低而未进入 whitelist 的 verified/derived theorem 提升为 callable：

- `MechLib.Units.VecQuantity.*` 的 `.val` 投影 bridge；
- `MechLib.Foundation.Dim.dimensionBridge_eq`；
- 匀速、匀加速、向量匀加速等运动学 rewrite；
- `WorkEnergy` 中 Hooke 力、动能变化、功定义和量纲 bridge；
- 刚体转动动能展开；
- SHM 和 DampedSHM 中闭式/残量/正性 side-condition helper；
- CentralForce 中中心力、势能和向量恒等式 bridge。

这些声明均满足：

- `status = verified`
- `trust_level in {core, derived}`
- `required_imports` 非空
- `needs_review = false`

## 保留不可调用的声明

仍不可调用的声明共 9 条：

- `MechLib.Examples.FinalTheoremDemos.*` 中 6 个 theorem：这些是展示 proof pattern 的 example，保留 `trust_level = example`。
- `MechLib.Systems.Verified.CentralForce.fin_induction_three_one`
- `MechLib.Systems.Verified.CentralForce.fin_induction_three_two`
- `MechLib.Systems.Verified.CentralForce.fin_induction_two_one`

`fin_induction_*` 是内部有限维索引 helper，不是课程语义 theorem，因此保留 `needs_review = true` 和 `callable_by_llm = false`。

## 验证命令

```bash
lake build
python3 tools/link_theorems_to_spec.py
python3 tools/check_no_new_axioms.py
python3 -m py_compile tools/export_coverage_matrix.py tools/export_spec_corpus.py tools/export_llm_corpus.py tools/link_theorems_to_spec.py tools/audit_dimension_usage.py tools/check_no_new_axioms.py
rg -n "^\\s*(axiom|constant|opaque)\\b|\\b(sorry|admit)\\b" MechLib tools || true
```
