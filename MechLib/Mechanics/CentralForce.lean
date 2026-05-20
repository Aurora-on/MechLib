import Mathlib
import MechLib.Mechanics.Rotation

namespace MechLib
namespace Mechanics
namespace CentralForce

open Units SI

noncomputable section

/-- 中心力判定（单点版）：相对原点力矩为零。 -/
def IsCentralForcePair (r : VecLength 3) (F : VecForce 3) : Prop :=
  Rotation.torque r F = 0

/-- 胡克型中心力场（向量形式）：`F = -k r`。 -/
def hookeCentralForce (k : SpringConstant) (r : VecLength 3) : VecForce 3 :=
  VecQuantity.cast ((-k) * r) SI.spring_plus_length_eq_force

abbrev fin_induction_three_one {A : Type} (a : A) (f : (i : Fin 2) → A → A) :
    Fin.induction (motive := fun _ : Fin 3 => A) a f (1 : Fin 3) = f 0 a := rfl

abbrev fin_induction_three_two {A : Type} (a : A) (f : (i : Fin 2) → A → A) :
    Fin.induction (motive := fun _ : Fin 3 => A) a f (2 : Fin 3) = f 1 (f 0 a) := rfl

abbrev fin_induction_two_one {A : Type} (a : A) (f : (i : Fin 1) → A → A) :
    Fin.induction (motive := fun _ : Fin 2 => A) a f (1 : Fin 2) = f 0 a := rfl

/-- 同一向量叉乘自身为零（`VecQuantity` 3D 版）。 -/
abbrev cross_self_zero {d : Dim} (u : VecQuantity d 3) : u ×ᵥ u = 0 := by
  ext i
  fin_cases i <;>
    simp [VecQuantity.cross, Fin.cases, fin_induction_three_one, fin_induction_three_two,
      fin_induction_two_one]
  all_goals ring

abbrev angularMomentum_two_sub_mass_two_length_eq_energy :
    (2 : ℕ) • SI.angularMomentumDim - (SI.massDim + (2 : ℕ) • SI.lengthDim) = SI.energyDim := by
  native_decide

abbrev GravParameter := Quantity (SI.energyDim + SI.lengthDim)

abbrev energy_plus_length_sub_length_eq_energy :
    (SI.energyDim + SI.lengthDim) - SI.lengthDim = SI.energyDim := by
  native_decide

/-- 中心势中的“离心项” `L^2/(2mr^2)`。 -/
def centrifugalPotentialTerm (L : AngularMomentum) (m : Mass) (r : Length) : Energy :=
  Quantity.cast ((L ** 2) / (((2 : ℝ) • m) * (r ** 2)))
    angularMomentum_two_sub_mass_two_length_eq_energy

/-- 有效势 `U_eff = U + L^2/(2mr^2)`。 -/
def effectivePotential (U : Length → Energy) (L : AngularMomentum) (m : Mass) (r : Length) : Energy :=
  U r + centrifugalPotentialTerm L m r

/-- 反平方势（势函数表达）：`U(r) = -μ/r`。 -/
def inverseSquarePotential (μ : GravParameter) (r : Length) : Energy :=
  Quantity.cast (-(μ / r)) energy_plus_length_sub_length_eq_energy

/-- 中心力径向方程接口：`m r¨ = -dU_eff/dr`。 -/
def RadialEquation
    (m : Mass)
    (r : Kinematics.ScalarTrajectory)
    (aR : Kinematics.ScalarAccelerationField)
    (dUeffdr : Length → Force) : Prop :=
  ∀ t, m * aR t = -dUeffdr (r t)

abbrev hookeCentralForce_eq (k : SpringConstant) (r : VecLength 3) :
    hookeCentralForce k r = VecQuantity.cast ((-k) * r) SI.spring_plus_length_eq_force := rfl

/-- 胡克型中心力 `F = -k r` 的力矩恒为零。 -/
abbrev hookeCentralForce_torque_zero (k : SpringConstant) (r : VecLength 3) :
    Rotation.torque r (hookeCentralForce k r) = 0 := by
  unfold Rotation.torque hookeCentralForce
  ext i
  fin_cases i <;>
    simp [VecQuantity.cross, VecQuantity.cast_val, VecQuantity.val_qmul_vec, Fin.cases,
      fin_induction_three_one, fin_induction_three_two, fin_induction_two_one]
  all_goals ring

abbrev hookeCentralForce_isCentral (k : SpringConstant) (r : VecLength 3) :
    IsCentralForcePair r (hookeCentralForce k r) := by
  simpa [IsCentralForcePair] using hookeCentralForce_torque_zero k r

abbrev centrifugalPotentialTerm_eq (L : AngularMomentum) (m : Mass) (r : Length) :
    centrifugalPotentialTerm L m r =
      Quantity.cast ((L ** 2) / (((2 : ℝ) • m) * (r ** 2)))
        angularMomentum_two_sub_mass_two_length_eq_energy := rfl

abbrev effectivePotential_eq (U : Length → Energy) (L : AngularMomentum) (m : Mass) (r : Length) :
    effectivePotential U L m r = U r + centrifugalPotentialTerm L m r := rfl

abbrev inverseSquarePotential_eq (μ : GravParameter) (r : Length) :
    inverseSquarePotential μ r = Quantity.cast (-(μ / r)) energy_plus_length_sub_length_eq_energy := rfl

abbrev radialEquation_eq
    (m : Mass)
    (r : Kinematics.ScalarTrajectory)
    (aR : Kinematics.ScalarAccelerationField)
    (dUeffdr : Length → Force) :
    RadialEquation m r aR dUeffdr = (∀ t, m * aR t = -dUeffdr (r t)) := rfl

/-- Binet 方程接口（以 `u(θ)=1/r` 表示）。 -/
def BinetEquation
    (u : ℝ → ℝ) (θ : ℝ) (μ : ℝ) (hForce : ℝ → ℝ) : Prop :=
  deriv (deriv u) θ + u θ = -(hForce θ) / (μ ^ 2 * (u θ) ^ 2)

/-- 开普勒第二定律接口：面积速度常量。 -/
def KeplerSecondLaw (arealVelocity : ℝ → ℝ) : Prop :=
  ∃ c : ℝ, ∀ t, arealVelocity t = c

/-- 由有效势判断束缚轨道的接口（存在局部极小与能量阈值）。 -/
def BoundOrbitCriterion
    (Ueff : ℝ → ℝ) (E : ℝ) : Prop :=
  ∃ r0 : ℝ, IsLocalMin Ueff r0 ∧ E > Ueff r0

/-- 反平方中心力下的轨道类型。 -/
inductive OrbitClass where
  | ellipse
  | parabola
  | hyperbola
deriving DecidableEq, Repr

/-- 反平方势的能量判据分类（接口版）。 -/
def classifyInverseSquareOrbit (E : Energy) : OrbitClass :=
  if E.val < 0 then OrbitClass.ellipse
  else if E.val = 0 then OrbitClass.parabola
  else OrbitClass.hyperbola

abbrev keplerSecondLaw_eq (arealVelocity : ℝ → ℝ) :
    KeplerSecondLaw arealVelocity = (∃ c : ℝ, ∀ t, arealVelocity t = c) := rfl

abbrev classifyInverseSquareOrbit_trichotomy (E : Energy) :
    classifyInverseSquareOrbit E = OrbitClass.ellipse
      ∨ classifyInverseSquareOrbit E = OrbitClass.parabola
      ∨ classifyInverseSquareOrbit E = OrbitClass.hyperbola := by
  unfold classifyInverseSquareOrbit
  by_cases hlt : E.val < 0
  · simp [hlt]
  · simp [hlt]
    by_cases heq : E.val = 0
    · simp [heq]
    · simp [heq]

example (r : VecLength 3) (F : VecForce 3) :
    IsCentralForcePair r F = (Rotation.torque r F = 0) := rfl

example (U : Length → Energy) (L : AngularMomentum) (m : Mass) (r : Length) :
    effectivePotential U L m r = U r + centrifugalPotentialTerm L m r := rfl

example (μ : GravParameter) (r : Length) :
    inverseSquarePotential μ r = Quantity.cast (-(μ / r)) energy_plus_length_sub_length_eq_energy := rfl

example (E : Energy) :
    classifyInverseSquareOrbit E = OrbitClass.ellipse
      ∨ classifyInverseSquareOrbit E = OrbitClass.parabola
      ∨ classifyInverseSquareOrbit E = OrbitClass.hyperbola :=
  classifyInverseSquareOrbit_trichotomy E

-- DONE[MECH_CF_01]: added Binet-equation formal interface (`BinetEquation`).
-- DONE[MECH_CF_02]: added Kepler second-law formal interface (`KeplerSecondLaw`).
-- DONE[MECH_CF_03]: added effective-potential bound-orbit criterion interface (`BoundOrbitCriterion`).
-- DONE[MECH_CF_04]: added inverse-square orbit classification API (`OrbitClass`, `classifyInverseSquareOrbit`).
-- DONE[MECH_CF_05]: proved rigorously in `VecQuantity` model that
--   Hooke central force `F = -k r` implies zero torque (`hookeCentralForce_torque_zero`).

end
end CentralForce
end Mechanics
end MechLib
