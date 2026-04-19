# MechLib

`MechLib` 是一个基于 Lean 4 的经典力学形式化语义库。它以 SI 量纲系统为底层，
用带量纲的标量/向量类型表达物理量，并在此之上组织常见力学公式、课程级定理以及后续扩展接口。

这个仓库明确参考了两类上游代码：

- `F:\AI4Mechanics\coding\Lean4PHYS\PHYSlib`
- `F:\AI4Mechanics\PhysLean-master\PhysLean`

但 `MechLib` 不是对其中任一项目的直接镜像，也不直接依赖这些力学模块编译。
当前代码直接依赖的是 `mathlib`；对参考项目的吸收主要体现在：

- `Lean4PHYS/PHYSlib` 的轻量 SI 单位系统、`Scalar d` 风格 API、入门力学公式命名方式
- `PhysLean` 的 classical mechanics 主题划分与问题意识，尤其是简谐振动、阻尼振动、分析力学、刚体与中心力

从当前实现看，`MechLib` 走的是一条比 `PhysLean` 更轻、更“课程定理库”的路线：

- 底层采用 `Dim = BaseDim -> Q` 的简单量纲表示
- 物理量直接实现为 `Quantity d` / `VecQuantity d n`
- 需要跨量纲重写时，用 `Quantity.cast` / `VecQuantity.cast` 配合维度恒等式完成
- 高阶主题中，部分模块提供的是“形式化接口（Prop / residual / equation schema）”，而不是完整解析解理论

---

## 与参考项目的关系

### 1. 与 `Lean4PHYS/PHYSlib` 的关系

`PHYSlib` 的核心思路是：

- 先定义通用 `UnitsSystem`
- 在 `Foundations.SI` 中实例化 SI 量纲
- 在 `Mechanics` 中给出较轻量的公式库

`MechLib` 保留了这种“先单位制、后力学模块”的组织方式，但做了两点简化：

- 不再保留 `UnitsSystem` 抽象层，而是直接固定到 7 个 SI 基本量纲
- 不再用 `Formal` graded ring 作为主要用户接口，而是直接用 `Quantity` / `VecQuantity` 做 typed arithmetic

`MechLib.Compat.PHYSlib` 则提供了一层有限兼容桥接，方便把旧风格名称逐步迁移到新库。
需要注意：这层兼容目前是“迁移辅助层”，不是完整的 drop-in 替代。

### 2. 与 `PhysLean` 的关系

`PhysLean` 的 classical mechanics 部分更偏理论化、几何化、变分法驱动，例如：

- `ClassicalMechanics.EulerLagrange`
- `ClassicalMechanics.HamiltonsEquations`
- `ClassicalMechanics.HarmonicOscillator.Basic`
- `ClassicalMechanics.RigidBody.Basic`

`MechLib` 在主题覆盖上明显受其启发，但当前实现策略不同：

- 不引入 `PhysLean` 那套流形/变分 calculus 基础设施
- 主要面向 typed formula、结构定理和可直接调用的 API
- 把 1D/3D 课程力学常见对象优先落成简单、稳定的接口

另外，参考代码的现状也值得说明：

- `PhysLean.ClassicalMechanics.Basic` 目前仍是 stub
- `PhysLean.ClassicalMechanics.DampedHarmonicOscillator.Basic` 主要还是 placeholder

因此，`MechLib.Mechanics.DampedSHM` 事实上已经补上了一块参考项目里尚未完整落地的 typed 内容。

---

## 当前代码结构

```text
MechLib/
├─ MechLib.lean
├─ MechLib/
│  ├─ Units/
│  │  ├─ Dim.lean
│  │  ├─ Quantity.lean
│  │  └─ VecQuantity.lean
│  ├─ SI.lean
│  ├─ Mechanics/
│  │  ├─ Kinematics.lean
│  │  ├─ Dynamics.lean
│  │  ├─ SystemDynamics.lean
│  │  ├─ WorkEnergy.lean
│  │  ├─ MomentumImpulse.lean
│  │  ├─ Rotation.lean
│  │  ├─ CentralForce.lean
│  │  ├─ AnalyticalMechanics.lean
│  │  ├─ SHM.lean
│  │  └─ DampedSHM.lean
│  └─ Compat/
│     └─ PHYSlib.lean
├─ tools/
│  └─ export_llm_corpus.py
├─ theorem_corpus.jsonl
├─ alias_map.jsonl
├─ export_report.json
├─ lakefile.toml
└─ lean-toolchain
```

`MechLib.lean` 是顶层聚合入口，直接导入全部主要模块。

---

## 核心设计

### 1. 量纲层

- `MechLib.Units.Dim`
  - `BaseDim` 定义 7 个 SI 基本量纲：`length`, `mass`, `time`, `current`, `temperature`, `amount`, `intensity`
  - `Dim := BaseDim -> Q`

这里采用“量纲是有理指数映射”的设计，因此支持诸如平方根、倒数、平方等常见维度运算。

### 2. 标量与向量物理量

- `MechLib.Units.Quantity`
  - `Quantity d`：携带量纲 `d` 的标量
  - 提供 `+`, `-`, `•`, `*`, `/`, `**`, `inv`
  - 提供 `Quantity.cast`、`Quantity.standardUnit`、`Quantity.inUnits`

- `MechLib.Units.VecQuantity`
  - `VecQuantity d n`：携带量纲 `d` 的 `n` 维向量
  - 提供 `+`, `-`, `•`
  - 提供数量乘向量、`dot`、`cross`
  - 提供 `VecQuantity.cast`

### 3. SI 层

`MechLib.SI` 在 typed quantity 之上定义：

- 常用维度别名
  - `speedDim`, `forceDim`, `energyDim`, `angularMomentumDim` 等
- 常用量类型
  - `Length`, `Mass`, `Time`, `Speed`, `Force`, `Energy`, `SpringConstant` 等
- 向量量类型
  - `VecLength n`, `VecSpeed n`, `VecForce n`, `VecTorque n` 等
- SI 单位与前缀
  - `meter`, `kilogram`, `second`, `newton`, `joule`, `hertz`
  - `kilo`, `milli`, `micro`, `mega` 等
- 常数
  - `c`, `g`
- 维度桥接定理
  - `speed_time_eq_length`
  - `force_time_eq_momentum`
  - `spring_plus_two_length_eq_energy`
  - `moi_plus_omega_sq_eq_energy`
  - 等等
- 单位选择与换算接口
  - `UnitChoices`
  - `conversionFactor`

这部分是整个库的关键“typed rewrite glue”。

---

## 模块概览

| 模块 | 当前内容 | 代表性 API |
| --- | --- | --- |
| `Units.Dim` | 7 基本量纲与基础维度操作 | `Dim.length`, `Dim.mass`, `Dim.time` |
| `Units.Quantity` | 标量物理量与单位数值读取 | `Quantity.cast`, `Quantity.inUnits` |
| `Units.VecQuantity` | 向量物理量、点乘、叉乘 | `VecQuantity.dot`, `VecQuantity.cross` |
| `SI` | SI 类型别名、单位、常数、维度桥接 | `meter`, `newton`, `speed_time_eq_length` |
| `Mechanics.Kinematics` | 标量/向量运动学、相对运动、约束关系、Frenet 与 Pfaff 接口 | `velocityConstAccel`, `positionConstAccel`, `displacement_forms_equiv` |
| `Mechanics.Dynamics` | 牛顿第二定律、动量、向量形式 | `secondLaw`, `momentum`, `momentum_change_const_mass` |
| `Mechanics.WorkEnergy` | 功、动能、弹簧势能、功能定理 | `work`, `kineticEnergy1D`, `work_energy_theorem_core` |
| `Mechanics.MomentumImpulse` | 冲量、非弹性碰撞、动量守恒 | `impulse`, `postCollisionSpeedInelastic`, `momentum_conservation_inelastic` |
| `Mechanics.SystemDynamics` | 质点系、质心、约化质量、双体动能分解、系统级平衡接口 | `centerOfMassPosition`, `reducedMass`, `twoBody_kineticEnergy_decomposition` |
| `Mechanics.Rotation` | 力矩、角动量、转动动能、平行轴定理、刚体/旋转参考系接口 | `torque`, `angularMomentum`, `EulerEquationsPrincipal` |
| `Mechanics.SHM` | 简谐振动位置/速度/加速度、周期、初值转换、唯一性/转折点接口 | `position`, `velocity`, `period_frequency_relation`, `amplitudeFromInitial` |
| `Mechanics.DampedSHM` | 阻尼振子参数、判别式分类、`Q`、阻尼比、驰豫时间、零阻尼退化、能量耗散接口 | `Params`, `discriminant`, `qualityFactor`, `equationOfMotion_gamma_zero_iff` |
| `Mechanics.AnalyticalMechanics` | 1D 拉格朗日/哈密顿形式、EL/Newton 等价、作用量、Poisson 括号、约束乘子接口 | `lagrangian1D`, `hamiltonianXP`, `eulerLagrange_iff_newton`, `poissonBracket1D` |
| `Mechanics.CentralForce` | 中心力判定、Hooke 中心力、有效势、反平方势、Binet/Kepler/轨道分类接口 | `IsCentralForcePair`, `effectivePotential`, `BinetEquation`, `classifyInverseSquareOrbit` |
| `Compat.PHYSlib` | 向旧命名风格提供有限桥接 | `Dimensions`, `Scalar`, `F_of`, `newton_second_law` |

---

## 当前实现的几个特点

### 1. `SHM` 与 `DampedSHM` 是本库相对完整的主题块

这两块不仅有公式定义，也有一定数量的结构定理。

例如 `DampedSHM` 已包含：

- `Params`
- `omega0`
- `equationResidual` / `EquationOfMotion`
- `discriminant`
- `IsUnderdamped` / `IsCriticallyDamped` / `IsOverdamped`
- `dampingRatio`
- `qualityFactor`
- `dampingRate`
- `relaxationTime`
- `equationOfMotion_gamma_zero_iff`

其中：

- `qualityFactor_mul_dampingRatio`
- `relaxationTime_mul_dampingRate`

已经被证明为可直接复用的 typed theorem。

### 2. 高阶模块中有不少“接口定理/接口命题”

例如：

- `Rotation.EulerEquationsPrincipal`
- `Kinematics.TransportTheoremRelation`
- `AnalyticalMechanics.CanonicalEquations1D`
- `CentralForce.BinetEquation`
- `CentralForce.BoundOrbitCriterion`

这些对象的定位不是“已经完整求解的一套理论”，而是为后续正式化提供稳定语义接口。

### 3. `PhysLean` 风格主题被做了轻量重述

例如 `AnalyticalMechanics` 中给出了：

- `lagrangian1D`
- `canonicalMomentum1D`
- `hamiltonianXV`
- `hamiltonianXP`
- `eulerLagrange_iff_newton`
- `actionFunctional1D`
- `stationaryAction1D`

但这仍然不同于 `PhysLean` 中真正依赖变分 calculus 基础设施的那套发展。

---

## 构建

当前环境信息：

- Lean：`leanprover/lean4:v4.26.0`
- 直接依赖：`mathlib`

`lakefile.toml` 当前写的是本地路径依赖：

```toml
[[require]]
name = "mathlib"
path = "../../PhysLean-master/.lake/packages/mathlib"
```

如果你的目录布局不同，需要先修改这个路径。

构建命令：

```bash
lake build
```

或者只构建主库：

```bash
lake build MechLib
```

---

## 使用

```lean
import MechLib

open MechLib
open MechLib.Units
open MechLib.SI
open MechLib.Mechanics
```

### 示例 1：匀加速位移公式等价

```lean
import MechLib

open MechLib
open MechLib.Units
open MechLib.SI
open MechLib.Mechanics

example (v v0 : Speed) (a : Acceleration) (t : Time)
    (hv : v = Kinematics.velocityConstAccel v0 a t) :
    Quantity.cast (v0 * t) SI.speed_time_eq_length
      + (1 / 2 : ℝ) • Quantity.cast (a * (t ** 2)) SI.acceleration_two_time_eq_length
        = Kinematics.displacementConstAccelForm2 v0 v t := by
  simpa using Kinematics.displacement_forms_equiv v v0 a t hv
```

### 示例 2：双体动能分解

```lean
import MechLib

open MechLib
open MechLib.SI
open MechLib.Mechanics

example (m1 m2 : Mass) (v1 v2 : Speed) (h : (m1 + m2).val ≠ 0) :
    SystemDynamics.totalKineticEnergy2 m1 m2 v1 v2
      = SystemDynamics.decomposedKineticEnergy2 m1 m2 v1 v2 := by
  simpa using SystemDynamics.twoBody_kineticEnergy_decomposition m1 m2 v1 v2 h
```

### 示例 3：阻尼比与品质因子

```lean
import MechLib

open MechLib
open MechLib.SI
open MechLib.Mechanics

example (P : DampedSHM.Params) (hgamma : P.gamma.val ≠ 0) :
    Quantity.cast (DampedSHM.qualityFactor P * DampedSHM.dampingRatio P)
      DampedSHM.zero_add_zero_eq_zero = (((1 / 2 : ℝ) : Dimensionless)) := by
  simpa using DampedSHM.qualityFactor_mul_dampingRatio P hgamma
```

---

## 当前边界

这份 README 描述的是“当前已实现代码”，不是未来规划。按现状看，边界主要有：

- 仅覆盖 SI 体系
- `Quantity` / `VecQuantity` 的数值载体是 `ℝ`
- 运动学里时间参数统一取 `ℝ`
- 一部分高阶主题目前停留在接口层，而非完整解析解或深层几何化证明
- `Compat.PHYSlib` 目前是有限桥接层，不应理解为完整兼容层

如果你要把它当作“课程定理库 + 后续扩展骨架”，当前结构是闭合的；
如果目标是对齐 `PhysLean` 那种更强的变分/几何化 classical mechanics 体系，则还需要继续补充更深层的基础设施。

---

## LLM / RAG 导出工具

仓库包含一个把定理与兼容别名导出为检索语料的脚本：

- `tools/export_llm_corpus.py`

示例：

```bash
python tools/export_llm_corpus.py ^
  --root MechLib ^
  --out theorem_corpus.jsonl ^
  --alias-out alias_map.jsonl ^
  --report-out export_report.json
```

产物说明：

- `theorem_corpus.jsonl`：定理/引理语料
- `alias_map.jsonl`：兼容层别名到 canonical theorem 的映射
- `export_report.json`：导出统计与解析报告

