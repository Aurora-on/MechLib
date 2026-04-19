import Mathlib
import MechLib.Mechanics.SystemDynamics

namespace MechLib
namespace Mechanics
namespace AnalyticalMechanics

open Units SI

noncomputable section

theorem momentum_two_sub_mass_eq_energy :
    (2 : ℕ) • SI.momentumDim - SI.massDim = SI.energyDim := by
  native_decide

/-- 一维拉格朗日量：`L = T - V`。 -/
def lagrangian1D (m : Mass) (V : Length → Energy) (x : Length) (v : Speed) : Energy :=
  WorkEnergy.kineticEnergy1D m v - V x

/-- 一维正则动量定义：`p = m v`。 -/
def canonicalMomentum1D (m : Mass) (v : Speed) : Momentum := m * v

/-- 以 `(x, v)` 表示的哈密顿量：`H = T + V`。 -/
def hamiltonianXV (m : Mass) (V : Length → Energy) (x : Length) (v : Speed) : Energy :=
  WorkEnergy.kineticEnergy1D m v + V x

/-- 以 `(x, p)` 表示的哈密顿量：`H = p^2/(2m) + V`。 -/
def hamiltonianXP (m : Mass) (V : Length → Energy) (x : Length) (p : Momentum) : Energy :=
  Quantity.cast ((p ** 2) / ((2 : ℝ) • m)) momentum_two_sub_mass_eq_energy + V x

/-- 一维欧拉-拉格朗日残量（势函数导数以 `dVdx` 给出）。 -/
def eulerLagrangeResidual1D
    (m : Mass) (dVdx : Length → Force)
    (x : Kinematics.ScalarTrajectory) (a : Kinematics.ScalarAccelerationField) :
    ℝ → Force := fun t => m * a t + dVdx (x t)

/-- 一维欧拉-拉格朗日方程 `d/dt(∂L/∂v) - ∂L/∂x = 0` 的实现接口。 -/
def SatisfiesEulerLagrange1D
    (m : Mass) (dVdx : Length → Force)
    (x : Kinematics.ScalarTrajectory) (a : Kinematics.ScalarAccelerationField) : Prop :=
  ∀ t, eulerLagrangeResidual1D m dVdx x a t = 0

/-- 一维牛顿形式 `m a = -dV/dx`。 -/
def SatisfiesNewtonForm1D
    (m : Mass) (dVdx : Length → Force)
    (x : Kinematics.ScalarTrajectory) (a : Kinematics.ScalarAccelerationField) : Prop :=
  ∀ t, Dynamics.secondLaw m (a t) = -dVdx (x t)

/-- 一自由度哈密顿方程组接口。 -/
def CanonicalEquations1D
    (dHdp : Length → Momentum → Speed)
    (dHdx : Length → Momentum → Force)
    (x : Kinematics.ScalarTrajectory) (p : ℝ → Momentum)
    (xDot : Kinematics.ScalarVelocityField) (pDot : ℝ → Force) : Prop :=
  ∀ t, xDot t = dHdp (x t) (p t) ∧ pDot t = -dHdx (x t) (p t)

/-- 判定广义坐标为循环坐标（`∂L/∂q = 0`）。 -/
def IsCyclicCoordinate (dLdq : ℝ → Force) : Prop := ∀ t, dLdq t = 0

/-- 广义动量守恒判定（以 `ṗ = 0` 表示）。 -/
def MomentumConserved (pDot : ℝ → Force) : Prop := ∀ t, pDot t = 0

theorem lagrangian1D_eq (m : Mass) (V : Length → Energy) (x : Length) (v : Speed) :
    lagrangian1D m V x v = WorkEnergy.kineticEnergy1D m v - V x := rfl

theorem canonicalMomentum1D_eq (m : Mass) (v : Speed) :
    canonicalMomentum1D m v = m * v := rfl

theorem hamiltonianXV_eq (m : Mass) (V : Length → Energy) (x : Length) (v : Speed) :
    hamiltonianXV m V x v = WorkEnergy.kineticEnergy1D m v + V x := rfl

theorem hamiltonianXP_eq (m : Mass) (V : Length → Energy) (x : Length) (p : Momentum) :
    hamiltonianXP m V x p =
      Quantity.cast ((p ** 2) / ((2 : ℝ) • m)) momentum_two_sub_mass_eq_energy + V x := rfl

/-- 在 `p = m v` 且 `m ≠ 0` 下，`H(x,p)` 与 `H(x,v)` 两种表达等价。 -/
theorem hamiltonianXP_of_canonicalMomentum
    (m : Mass) (V : Length → Energy) (x : Length) (v : Speed) (h : m.val ≠ 0) :
    hamiltonianXP m V x (canonicalMomentum1D m v) = hamiltonianXV m V x v := by
  ext
  have hm2 : (2 : ℝ) * m.val ≠ 0 := mul_ne_zero two_ne_zero h
  simp [hamiltonianXP, hamiltonianXV, canonicalMomentum1D,
    WorkEnergy.kineticEnergy1D, Quantity.cast_val]
  field_simp [h, hm2]

/-- 一维保守系统中，欧拉-拉格朗日形式与牛顿形式等价。 -/
theorem eulerLagrange_iff_newton
    (m : Mass) (dVdx : Length → Force)
    (x : Kinematics.ScalarTrajectory) (a : Kinematics.ScalarAccelerationField) :
    SatisfiesEulerLagrange1D m dVdx x a ↔ SatisfiesNewtonForm1D m dVdx x a := by
  constructor
  · intro hEL t
    have hval : (m * a t).val + (dVdx (x t)).val = 0 := by
      simpa [SatisfiesEulerLagrange1D, eulerLagrangeResidual1D] using congrArg Quantity.val (hEL t)
    ext
    have : (m * a t).val = -(dVdx (x t)).val := by linarith [hval]
    simpa [SatisfiesNewtonForm1D, Dynamics.secondLaw] using this
  · intro hN t
    have hval : (m * a t).val = -(dVdx (x t)).val := by
      simpa [SatisfiesNewtonForm1D, Dynamics.secondLaw] using congrArg Quantity.val (hN t)
    ext
    have hsum : (m * a t).val + (dVdx (x t)).val = 0 := by linarith [hval]
    simpa [SatisfiesEulerLagrange1D, eulerLagrangeResidual1D] using hsum

theorem canonicalEquations1D_eq
    (dHdp : Length → Momentum → Speed)
    (dHdx : Length → Momentum → Force)
    (x : Kinematics.ScalarTrajectory) (p : ℝ → Momentum)
    (xDot : Kinematics.ScalarVelocityField) (pDot : ℝ → Force) :
    CanonicalEquations1D dHdp dHdx x p xDot pDot =
      (∀ t, xDot t = dHdp (x t) (p t) ∧ pDot t = -dHdx (x t) (p t)) := rfl

/-- 循环坐标对应动量守恒（形式化接口版）。 -/
theorem cyclic_coordinate_implies_momentum_conserved
    (dLdq : ℝ → Force) (pDot : ℝ → Force)
    (hEq : ∀ t, pDot t = dLdq t) (hCyclic : IsCyclicCoordinate dLdq) :
    MomentumConserved pDot := by
  intro t
  rw [hEq t, hCyclic t]

example (m : Mass) (v : Speed) :
    canonicalMomentum1D m v = m * v := rfl

example (m : Mass) (V : Length → Energy) (x : Length) (p : Momentum) :
    hamiltonianXP m V x p =
      Quantity.cast ((p ** 2) / ((2 : ℝ) • m)) momentum_two_sub_mass_eq_energy + V x := rfl

example (dLdq pDot : ℝ → Force) (hEq : ∀ t, pDot t = dLdq t)
    (hCyclic : IsCyclicCoordinate dLdq) :
    MomentumConserved pDot :=
  cyclic_coordinate_implies_momentum_conserved dLdq pDot hEq hCyclic

/-- 作用量泛函（1D 接口）。 -/
def actionFunctional1D
    (L : Length → Speed → Energy)
    (q : ℝ → Length) (qDot : ℝ → Speed)
    (t0 t1 : ℝ) : ℝ :=
  ∫ t in Set.uIcc t0 t1, (L (q t) (qDot t)).val

/-- 驻定作用接口：对任意变分方向，`ε=0` 处的一阶变分为零。 -/
def stationaryAction1D
    (S : (ℝ → Length) → ℝ) (q : ℝ → Length) : Prop :=
  ∀ η : ℝ → Length, HasDerivAt (fun (ε : ℝ) => S (fun t => q t + ε • η t)) 0 0

/-- Legendre 变换正则性（1D 接口：`v -> p(v)` 注入）。 -/
def legendreRegular1D (pOfV : Speed → Momentum) : Prop :=
  Function.Injective (fun v => (pOfV v).val)

/-- 相空间标量函数接口。 -/
abbrev PhaseFunction1D := Length → Momentum → ℝ

/-- Poisson 括号（1D 接口，按偏导函数输入）。 -/
def poissonBracket1D
    (dFdx dFdp dGdx dGdp : PhaseFunction1D) : PhaseFunction1D :=
  fun x p => dFdx x p * dGdp x p - dFdp x p * dGdx x p

theorem poissonBracket1D_antisymm
    (dFdx dFdp dGdx dGdp : PhaseFunction1D) :
    poissonBracket1D dFdx dFdp dGdx dGdp
      = fun x p => -poissonBracket1D dGdx dGdp dFdx dFdp x p := by
  funext x p
  simp [poissonBracket1D]
  ring

/-- 约束乘子法接口（1D）：`EL = λ ∂C/∂q`。 -/
def lagrangeMultiplierEquation1D
    (EL : ℝ → Force) (lam : ℝ → Dimensionless) (dCdq : ℝ → Force) : Prop :=
  ∀ t, EL t = (lam t).val • dCdq t

theorem lagrangeMultiplierEquation1D_eq
    (EL : ℝ → Force) (lam : ℝ → Dimensionless) (dCdq : ℝ → Force) :
    lagrangeMultiplierEquation1D EL lam dCdq = (∀ t, EL t = (lam t).val • dCdq t) := rfl

-- DONE[MECH_AM_01]: added least-action formal interfaces (`actionFunctional1D`, `stationaryAction1D`).
-- DONE[MECH_AM_02]: added Legendre regularity interface (`legendreRegular1D`).
-- DONE[MECH_AM_03]: added Poisson-bracket interface and antisymmetry theorem (`poissonBracket1D_antisymm`).
-- DONE[MECH_AM_04]: added Lagrange-multiplier constrained equation interface.

end
end AnalyticalMechanics
end Mechanics
end MechLib
