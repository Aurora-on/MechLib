import Mathlib
import MechLib.Mechanics.MomentumImpulse

namespace MechLib
namespace Mechanics
namespace SystemDynamics

open Units SI

noncomputable section

/-- 1D 质点模型：质量、位置、速度。 -/
structure Particle1D where
  m : Mass
  x : Length
  v : Speed

abbrev MassLength := Quantity (SI.massDim + SI.lengthDim)

/-- 质点的“质量-位置矩” `m x`。 -/
def massWeightedPosition (p : Particle1D) : MassLength := p.m * p.x

/-- 质点系总质量。 -/
def totalMass : List Particle1D → Mass
  | [] => 0
  | p :: ps => p.m + totalMass ps

/-- 质点系总动量（1D）。 -/
def totalMomentum : List Particle1D → Momentum
  | [] => 0
  | p :: ps => p.m * p.v + totalMomentum ps

/-- 质点系总“质量-位置矩”。 -/
def totalMassWeightedPosition : List Particle1D → MassLength
  | [] => 0
  | p :: ps => massWeightedPosition p + totalMassWeightedPosition ps

theorem mass_length_sub_mass_eq_length :
    (SI.massDim + SI.lengthDim) - SI.massDim = SI.lengthDim := by
  native_decide

theorem mass_two_sub_mass_eq_mass :
    (SI.massDim + SI.massDim) - SI.massDim = SI.massDim := by
  native_decide

/-- 质心位置定义：`R = (Σ m_i x_i) / (Σ m_i)`。 -/
def centerOfMassPosition (ps : List Particle1D) : Length :=
  if _h : (totalMass ps).val = 0 then
    0
  else
    Quantity.cast (totalMassWeightedPosition ps / totalMass ps) mass_length_sub_mass_eq_length

/-- 质心速度定义：`V = (Σ p_i)/(Σ m_i)`。 -/
def centerOfMassVelocity (ps : List Particle1D) : Speed :=
  if _h : (totalMass ps).val = 0 then
    0
  else
    Quantity.cast (totalMomentum ps / totalMass ps) SI.momentum_sub_mass_eq_speed

/-- 两体系统的约化质量 `μ = m1 m2 / (m1 + m2)`。 -/
def reducedMass (m1 m2 : Mass) : Mass :=
  Quantity.cast ((m1 * m2) / (m1 + m2)) mass_two_sub_mass_eq_mass

/-- 两体质心速度。 -/
def centerVelocity2 (m1 m2 : Mass) (v1 v2 : Speed) : Speed :=
  Quantity.cast ((m1 * v1 + m2 * v2) / (m1 + m2)) SI.momentum_sub_mass_eq_speed

/-- 两体相对速度 `v_rel = v2 - v1`。 -/
def relativeVelocity2 (v1 v2 : Speed) : Speed := v2 - v1

/-- 两体总动能（直接表达）。 -/
def totalKineticEnergy2 (m1 m2 : Mass) (v1 v2 : Speed) : Energy :=
  WorkEnergy.kineticEnergy1D m1 v1 + WorkEnergy.kineticEnergy1D m2 v2

/-- 两体总动能（质心+相对运动分解表达）。 -/
def decomposedKineticEnergy2 (m1 m2 : Mass) (v1 v2 : Speed) : Energy :=
  WorkEnergy.kineticEnergy1D (m1 + m2) (centerVelocity2 m1 m2 v1 v2)
    + WorkEnergy.kineticEnergy1D (reducedMass m1 m2) (relativeVelocity2 v1 v2)

theorem totalMass_nil : totalMass [] = 0 := rfl

theorem totalMomentum_nil : totalMomentum [] = 0 := rfl

theorem totalMass_cons (p : Particle1D) (ps : List Particle1D) :
    totalMass (p :: ps) = p.m + totalMass ps := rfl

theorem totalMomentum_cons (p : Particle1D) (ps : List Particle1D) :
    totalMomentum (p :: ps) = p.m * p.v + totalMomentum ps := rfl

/-- 单质点系统中，非零质量时质心位置就是该质点位置。 -/
theorem centerOfMassPosition_singleton (p : Particle1D) (h : p.m.val ≠ 0) :
    centerOfMassPosition [p] = p.x := by
  ext
  simp [centerOfMassPosition, totalMass, totalMassWeightedPosition, massWeightedPosition,
    Quantity.cast_val, h]

/-- 单质点系统中，非零质量时质心速度就是该质点速度。 -/
theorem centerOfMassVelocity_singleton (p : Particle1D) (h : p.m.val ≠ 0) :
    centerOfMassVelocity [p] = p.v := by
  ext
  simp [centerOfMassVelocity, totalMass, totalMomentum, Quantity.cast_val, h]

/-- 两体质心速度满足 `P = M V_cm`。 -/
theorem totalMomentum_two_eq_totalMass_mul_centerVelocity
    (m1 m2 : Mass) (v1 v2 : Speed) (h : (m1 + m2).val ≠ 0) :
    m1 * v1 + m2 * v2 = (m1 + m2) * centerVelocity2 m1 m2 v1 v2 := by
  have hM : m1.val + m2.val ≠ 0 := by simpa using h
  ext
  calc
    (m1 * v1 + m2 * v2).val
        = m1.val * v1.val + m2.val * v2.val := by simp
    _ = (m1.val + m2.val) * ((m1.val * v1.val + m2.val * v2.val) / (m1.val + m2.val)) := by
      symm
      exact mul_div_cancel₀ (m1.val * v1.val + m2.val * v2.val) hM
    _ = ((m1 + m2) * centerVelocity2 m1 m2 v1 v2).val := by
      simp [centerVelocity2, Quantity.cast_val]

/-- 约化质量具有对称性。 -/
theorem reducedMass_symm (m1 m2 : Mass) : reducedMass m1 m2 = reducedMass m2 m1 := by
  ext
  simp [reducedMass, Quantity.cast_val, add_comm, mul_comm]

/-- 两体动能可分解为“质心动能 + 相对运动动能”。 -/
theorem twoBody_kineticEnergy_decomposition
    (m1 m2 : Mass) (v1 v2 : Speed) (h : (m1 + m2).val ≠ 0) :
    totalKineticEnergy2 m1 m2 v1 v2 = decomposedKineticEnergy2 m1 m2 v1 v2 := by
  ext
  have hM : m1.val + m2.val ≠ 0 := by simpa using h
  simp [totalKineticEnergy2, decomposedKineticEnergy2, WorkEnergy.kineticEnergy1D,
    centerVelocity2, relativeVelocity2, reducedMass, Quantity.cast_val]
  field_simp [hM]
  ring

example (p : Particle1D) (h : p.m.val ≠ 0) : centerOfMassPosition [p] = p.x :=
  centerOfMassPosition_singleton p h

example (m1 m2 : Mass) : reducedMass m1 m2 = reducedMass m2 m1 :=
  reducedMass_symm m1 m2

example (m1 m2 : Mass) (v1 v2 : Speed) (h : (m1 + m2).val ≠ 0) :
    totalKineticEnergy2 m1 m2 v1 v2 = decomposedKineticEnergy2 m1 m2 v1 v2 :=
  twoBody_kineticEnergy_decomposition m1 m2 v1 v2 h

/-- 质点系质心定理接口：`M R¨ = ΣF_ext`。 -/
def CenterOfMassTheorem
    (M : Mass) (Rddot : ℝ → Acceleration) (Fext : ℝ → Force) : Prop :=
  ∀ t, M * Rddot t = Fext t

/-- 变质量系统动量平衡接口：`ṗ = F_ext + F_flux`。 -/
def VariableMassMomentumBalance
    (pDot : ℝ → Force) (Fext : ℝ → Force) (Fflux : ℝ → Force) : Prop :=
  ∀ t, pDot t = Fext t + Fflux t

/-- 系统关于动点/定点原点的动量矩平衡接口。 -/
def SystemMomentBalanceAboutOrigin
    (LdotO : ℝ → VecTorque 3) (MextO : ℝ → VecTorque 3) : Prop :=
  ∀ t, LdotO t = MextO t

theorem centerOfMassTheorem_eq (M : Mass) (Rddot : ℝ → Acceleration) (Fext : ℝ → Force) :
    CenterOfMassTheorem M Rddot Fext = (∀ t, M * Rddot t = Fext t) := rfl

theorem variableMassMomentumBalance_eq
    (pDot : ℝ → Force) (Fext Fflux : ℝ → Force) :
    VariableMassMomentumBalance pDot Fext Fflux = (∀ t, pDot t = Fext t + Fflux t) := rfl

theorem systemMomentBalanceAboutOrigin_eq
    (LdotO MextO : ℝ → VecTorque 3) :
    SystemMomentBalanceAboutOrigin LdotO MextO = (∀ t, LdotO t = MextO t) := rfl

-- DONE[MECH_SYS_01]: added center-of-mass theorem formal interface.
-- DONE[MECH_SYS_02]: added variable-mass momentum-balance formal interface.
-- DONE[MECH_SYS_03]: added system moment-balance-about-origin formal interface.

end
end SystemDynamics
end Mechanics
end MechLib
