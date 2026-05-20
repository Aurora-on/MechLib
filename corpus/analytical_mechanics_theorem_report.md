# MechLib 分析力学定理报告

本报告覆盖两层分析力学声明：

- 旧核心层：`MechLib.Mechanics.AnalyticalMechanics`
- 课程层 wrapper/interface：`MechLib.Analytical.*`

统计口径：只把 Lean 中以 `theorem`/`lemma` 声明的内容列为“定理”。`def ... : Prop`、`structure`、`abbrev` 等作为 schema/interface，不计入 verified theorem。

## 总览

| 类别 | 数量 | 说明 |
|---|---:|---|
| verified theorem | 18 | 已由 Lean 编译验证 |
| schema/interface | 若干 | 用于建模、检索、规划，不作为证明阶段 theorem |
| axiom/sorry/admit | 0 | 本报告范围内未引入 |

## 旧核心层 verified theorem

| 定理名称 | 中文简介 | 当前状态 | 来源 |
|---|---|---|---|
| `MechLib.Mechanics.AnalyticalMechanics.momentum_two_sub_mass_eq_energy` | 证明 `2 * momentumDim - massDim = energyDim`，用于把 `p² / m` cast 成能量维度。 | verified | `MechLib/Mechanics/AnalyticalMechanics.lean` |
| `MechLib.Mechanics.AnalyticalMechanics.lagrangian1D_eq` | 展开一维拉格朗日量定义：`L = T - V`。 | verified | `MechLib/Mechanics/AnalyticalMechanics.lean` |
| `MechLib.Mechanics.AnalyticalMechanics.canonicalMomentum1D_eq` | 展开一维正则动量定义：`p = m v`。 | verified | `MechLib/Mechanics/AnalyticalMechanics.lean` |
| `MechLib.Mechanics.AnalyticalMechanics.hamiltonianXV_eq` | 展开速度形式 Hamiltonian：`H(x,v) = T + V`。 | verified | `MechLib/Mechanics/AnalyticalMechanics.lean` |
| `MechLib.Mechanics.AnalyticalMechanics.hamiltonianXP_eq` | 展开动量形式 Hamiltonian：`H(x,p) = p²/(2m) + V`。 | verified | `MechLib/Mechanics/AnalyticalMechanics.lean` |
| `MechLib.Mechanics.AnalyticalMechanics.hamiltonianXP_of_canonicalMomentum` | 在 `p = m v` 且 `m ≠ 0` 时，证明动量形式 Hamiltonian 与速度形式 Hamiltonian 相等。 | verified | `MechLib/Mechanics/AnalyticalMechanics.lean` |
| `MechLib.Mechanics.AnalyticalMechanics.eulerLagrange_iff_newton` | 证明一维保守系统中 Euler-Lagrange 形式等价于 Newton 形式 `m a = -dV/dx`。 | verified | `MechLib/Mechanics/AnalyticalMechanics.lean` |
| `MechLib.Mechanics.AnalyticalMechanics.canonicalEquations1D_eq` | 展开一维 Hamilton 正则方程接口：`qdot = ∂H/∂p` 且 `pdot = -∂H/∂q`。 | verified | `MechLib/Mechanics/AnalyticalMechanics.lean` |
| `MechLib.Mechanics.AnalyticalMechanics.cyclic_coordinate_implies_momentum_conserved` | 若坐标为循环坐标且 `pDot = dL/dq`，则对应广义动量守恒。 | verified | `MechLib/Mechanics/AnalyticalMechanics.lean` |
| `MechLib.Mechanics.AnalyticalMechanics.poissonBracket1D_antisymm` | 证明一维 Poisson bracket 反对称性：交换两个函数后取负号。 | verified | `MechLib/Mechanics/AnalyticalMechanics.lean` |
| `MechLib.Mechanics.AnalyticalMechanics.lagrangeMultiplierEquation1D_eq` | 展开一维 Lagrange 乘子方程接口：`EL = λ ∂C/∂q`。 | verified | `MechLib/Mechanics/AnalyticalMechanics.lean` |

## 课程层 verified theorem / wrapper theorem

| 定理名称 | 中文简介 | 当前状态 | 来源 |
|---|---|---|---|
| `MechLib.Analytical.GeneralizedCoordinates.generalizedCoordinateSystemWellFormed_iff` | 证明旧的 `GeneralizedCoordinateSystemWellFormed` 等价于每个广义坐标名称非空。 | verified | `MechLib/Analytical/GeneralizedCoordinates.lean` |
| `MechLib.Analytical.Constraints.fixedCoordinateConstraint_satisfied_iff` | 对固定坐标约束 `qᵢ = value`，证明约束满足等价于该坐标值恒等于目标值。 | verified | `MechLib/Analytical/Constraints.lean` |
| `MechLib.Analytical.VirtualWork.virtualWorkResidual_eq` | 展开虚功 residual：给定广义力和虚位移，`work = VirtualWorkValue Q δq`。 | verified | `MechLib/Analytical/VirtualWork.lean` |
| `MechLib.Analytical.LagrangeEquation.eulerLagrange_iff_newton_course_form` | 课程层 wrapper：复用旧核心 theorem，给出一维 Euler-Lagrange 与 Newton 形式等价。 | verified | `MechLib/Analytical/LagrangeEquation.lean` |
| `MechLib.Analytical.Hamiltonian.hamiltonianSchema_eq` | 展开课程层 Hamiltonian schema，等价于旧的一维 `CanonicalEquations1D` 接口。 | verified | `MechLib/Analytical/Hamiltonian.lean` |
| `MechLib.Analytical.PoissonBracket.poissonBracket1D_antisymm_course_form` | 课程层 wrapper：复用旧核心 theorem，暴露一维 Poisson bracket 反对称性。 | verified | `MechLib/Analytical/PoissonBracket.lean` |
| `MechLib.Analytical.ConservationLaw.cyclic_coordinate_implies_momentum_conserved_1d` | 课程层 wrapper：复用旧核心 theorem，表达一维循环坐标推出动量守恒。 | verified | `MechLib/Analytical/ConservationLaw.lean` |

## Schema / Interface 声明说明

以下内容是分析力学核心 API 的建模层，不是 theorem：

| 声明 | 中文简介 | 当前状态 |
|---|---|---|
| `CoordSpec`, `GCoord`, `GVel`, `GAccel` | 多自由度广义坐标、速度、加速度，允许不同坐标有不同量纲。 | schema/interface |
| `GeneralizedForce`, `GeneralizedMomentum` | 与每个广义坐标共轭的广义力、广义动量类型。 | schema/interface |
| `HolonomicConstraint`, `NonHolonomicConstraint` | 完整约束与非完整约束 residual schema。 | schema/interface |
| `VirtualDisplacement`, `VirtualWorkValue`, `VirtualWorkResidual` | 虚位移、虚功值和虚功 residual。 | schema/interface |
| `DAlembertResidual` | d'Alembert 原理的广义力虚功 residual。 | schema/interface |
| `LagrangianSystem`, `EulerLagrangeResidual` | 一般 `n` 自由度 Lagrangian 系统和 Euler-Lagrange residual。 | schema/interface |
| `HamiltonianSystem`, `CanonicalEquationResidual` | 一般 `n` 自由度 Hamiltonian 系统和正则方程 residual。 | schema/interface |
| `PoissonBracket`, `PoissonBracketResidualN` | 有限维相空间 Poisson bracket schema。 | schema/interface |
| `IsCyclicCoordinate`, `CyclicCoordinateConservation` | 一般系统的循环坐标和对应守恒律 schema。 | schema/interface |
| `SmallOscillationSystem`, `NormalModeCondition` | 小振动系统与正则模条件。 | schema/interface |

## 备注

- 一般 `n` 自由度 Euler-Lagrange / Hamilton / 小振动内容当前是 residual/schema，不伪装成 proved theorem。
- 证明阶段应优先使用 `verified` theorem；schema/interface 主要用于建模、检索和规划。
- `corpus/decl_corpus_enriched.jsonl` 已能反查这些 verified theorem 到对应 Spec topic / LawSchema。
