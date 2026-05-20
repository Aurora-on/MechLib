# 最终定理展示样例

本文档说明 `MechLib/Examples/FinalTheoremDemos.lean` 中的 3 组最终展示样例。它们的目的不是再次黑箱调用已有 theorem，而是展示 MechLib 证明小型理论力学结论时的典型 proof pattern：

- 物理量保持 typed API，例如 `Speed`, `Acceleration`, `Time`, `Length`, `Force`, `Energy`。
- 必要时通过 `congrArg Quantity.val` 进入实数值层。
- 用 `simp` 展开安全的量纲 bridge 和 `.val` 投影。
- 用 `ring` 或 `linarith` 完成实数代数。
- 最后用 `ext` 回到 typed physical quantity 等式。

这些展示 theorem 已在 Spec-declaration alignment 中标记为 `status = verified`、`trust_level = example`、`callable_by_llm = false`。它们用于说明证明风格，不作为 proof whitelist 的首选事实。课程层中新增或保留的 extractor theorem，例如 `NewtonSecondLaw.to_value_equation`、`forceBalance1D_to_value_equation`、`constantAccelerationVelocityRelation_to_value_equation`、`fixedAxisDynamicsResidual_to_value_equation`，才是更稳定的 proof 检索入口。

## 样例 1：运动学 typed proof

课程内容：

- 匀加速直线运动的两种位移公式等价。
- `Speed × Time -> Length` 与 `Acceleration × Time² -> Length` 的量纲 bridge。

使用的 MechLib declarations：

- `MechLib.Mechanics.Kinematics.velocityConstAccel`
- `MechLib.Mechanics.Kinematics.displacementConstAccelForm2`
- `MechLib.Units.Quantity.cast`
- `MechLib.SI.speed_time_eq_length`
- `MechLib.SI.acceleration_two_time_eq_length`

verified 内容：

- `uniformAccelerationDisplacement_byCalculation` 是 fully checked theorem。
- `speedTimeCastValue_bySimp` 是 fully checked theorem。

schema 内容：

- 无。

证明策略：

1. 从假设 `hv : v = velocityConstAccel v0 a t` 取 `.val`，得到 `v.val = v0.val + (a * t).val`。
2. 对目标 typed `Length` 等式使用 `ext`，转成实数值等式。
3. 用 `simp [displacementConstAccelForm2, Quantity.cast_val, hvVal]` 展开定义和量纲 cast。
4. 用 `ring` 完成剩余代数。

项目价值：

- 该样例展示 MechLib 的量纲系统仍然参与 theorem statement，而 proof 只在需要时进入 `.val` 层。
- 证明过程是可复制的：typed statement、value projection、algebra tactic、typed equality。

## 样例 2：动力学 typed proof

课程内容：

- 牛顿第二定律。
- 功-能关系的核心代数形式。
- 冲量-动量定理。

使用的 MechLib declarations：

- `MechLib.Mechanics.Dynamics.F_of`
- `MechLib.Mechanics.Dynamics.secondLaw`
- `MechLib.Mechanics.MomentumImpulse.impulse`
- `Mass`, `Acceleration`, `Force`, `Energy`, `Momentum`, `Time`

verified 内容：

- `newtonSecondLaw_byDefinition` 是 definitional proof，使用 `rfl`。
- `workEnergyBalance_byValueAlgebra` 是 fully checked theorem。
- `impulseMomentum_byValueAlgebra` 是 fully checked theorem。

schema 内容：

- 无。

证明策略：

1. Newton 第二定律在核心 API 中是定义展开，直接 `rfl`。
2. 对 `Wnet = K2 - K1` 或 `p2 - p1 = impulse F dt` 使用 `congrArg Quantity.val`。
3. 用 `linarith` 把差分形式改写成更新形式。
4. 用 `ext` 把值层等式提升回 typed `Energy` 或 `Momentum` 等式。

项目价值：

- 展示 MechLib 中很多基础理论力学 theorem 不是靠自动魔法，而是靠 typed API 与简单实数代数配合。
- 这类 proof 对后续 LLM proof agent 友好：关键 tactic 是 `rfl`, `simp`, `linarith`, `ext`。

## 样例 3：动力学到分析力学桥接 proof

课程内容：

- 一维保守系统的 Euler-Lagrange residual。
- 牛顿形式 `ma = -dV/dx`。
- residual schema 与 verified bridge 的关系。

使用的 MechLib declarations：

- `MechLib.Analytical.LagrangeEquation.LagrangeEquationSchema`
- `MechLib.Analytical.LagrangeEquation.SatisfiesEulerLagrange1D`
- `MechLib.Analytical.LagrangeEquation.eulerLagrangeResidual1D`
- `MechLib.Analytical.LagrangeEquation.SatisfiesNewtonForm1D`
- `MechLib.Mechanics.Dynamics.secondLaw`
- `MechLib.Mechanics.Kinematics.ScalarTrajectory`
- `MechLib.Mechanics.Kinematics.ScalarAccelerationField`

verified 内容：

- `eulerLagrangeNewtonBridge_byResidualAlgebra` 是 fully checked theorem。

schema 内容：

- `LagrangeEquationSchema` 是课程层建模接口名，但本样例没有把 schema 当 proof fact 使用；证明中直接展开到 `SatisfiesEulerLagrange1D` 和 residual 定义。

证明策略：

1. 正向：从 Euler-Lagrange residual 等于零推出 `(m * a t).val + dVdx.val = 0`。
2. 用 `linarith` 得到 `(m * a t).val = -dVdx.val`。
3. 用 `secondLaw` 定义展开回到 Newton form。
4. 反向按相同步骤逆推 residual 为零。

NEW_LEMMA_REQUIRED：

- 当前 1D Euler-Lagrange 与 Newton form 桥接已经 fully proved，不需要新增 lemma。
- 一般 n 自由度 Euler-Lagrange 到 Newton/Hamiltonian 的完整桥接仍是后续工作，不能用 schema 伪装成 theorem。

项目价值：

- 展示 MechLib 可以把动力学方程和分析力学 residual 连接起来。
- 展示复杂分析力学内容在 schema 层命名，但 proof 阶段必须展开到 verified definitions/theorems。

## 检查命令

```bash
lake env lean MechLib/Examples/FinalTheoremDemos.lean
lake build
rg -n "^\\s*(axiom|constant|opaque)\\b|\\b(sorry|admit)\\b" MechLib tools || true
```
