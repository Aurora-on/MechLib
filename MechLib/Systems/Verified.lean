import Mathlib
import MechLib.Mechanics.Kinematics
import MechLib.Mechanics.WorkEnergy
import MechLib.Mechanics.Rotation
import MechLib.Mechanics.SHM
import MechLib.Mechanics.DampedSHM
import MechLib.Mechanics.CentralForce

/-!
Verified theorem declarations migrated from `MechLib.Mechanics.*`.

The old `MechLib.Mechanics.*` names are compatibility abbreviations; these
course-layer declarations are the retrieval-facing theorem locations.
-/

namespace MechLib
namespace Systems
namespace Verified

open Units SI
open MechLib.Mechanics

noncomputable section

namespace SHM
open MechLib.Mechanics.SHM

/-- Migrated from `MechLib.Mechanics.SHM.acceleration_eq_neg_omega_sq_mul_pos`. -/
theorem acceleration_eq_neg_omega_sq_mul_pos
    (A : Length) (omega : AngularVelocity) (phi : PhysAngle) (t : Time) :
    acceleration A omega phi t =
      (-1 : ℝ) • Quantity.cast ((omega ** 2) * position A omega phi t) SI.omega_sq_plus_length_eq_acceleration
 := by
  simpa using MechLib.Mechanics.SHM.acceleration_eq_neg_omega_sq_mul_pos A omega phi t

/-- Migrated from `MechLib.Mechanics.SHM.period_frequency_relation`. -/
theorem period_frequency_relation (omega : AngularVelocity) (h : omega.val ≠ 0) :
    Quantity.cast (period omega * omega) SI.time_plus_angular_velocity_eq_dimensionless =
      (((2 : ℝ) * Real.pi : ℝ) : Dimensionless)
 := by
  simpa using MechLib.Mechanics.SHM.period_frequency_relation omega h

/-- Migrated from `MechLib.Mechanics.SHM.totalEnergy_eq`. -/
theorem totalEnergy_eq (m : Mass) (k : SpringConstant) (x : Length) (v : Speed) :
    totalEnergy m k x v = WorkEnergy.kineticEnergy1D m v + WorkEnergy.springPotential k x
 := by
  simpa using MechLib.Mechanics.SHM.totalEnergy_eq m k x v

/-- Migrated from `MechLib.Mechanics.SHM.initialPosition_eq`. -/
theorem initialPosition_eq (A : Length) (omega : AngularVelocity) (phi : PhysAngle) :
    initialPosition A omega phi = (Real.cos phi.val) • A
 := by
  simpa using MechLib.Mechanics.SHM.initialPosition_eq A omega phi

/-- Migrated from `MechLib.Mechanics.SHM.initialVelocity_eq`. -/
theorem initialVelocity_eq (A : Length) (omega : AngularVelocity) (phi : PhysAngle) :
    initialVelocity A omega phi
      = (-Real.sin phi.val) • Quantity.cast (A * omega) SI.length_plus_angular_velocity_eq_speed
 := by
  simpa using MechLib.Mechanics.SHM.initialVelocity_eq A omega phi

/-- Migrated from `MechLib.Mechanics.SHM.amplitudeFromInitial_nonneg`. -/
theorem amplitudeFromInitial_nonneg (omega : AngularVelocity) (x0 : Length) (v0 : Speed) :
    0 ≤ (amplitudeFromInitial omega x0 v0).val
 := by
  simpa using MechLib.Mechanics.SHM.amplitudeFromInitial_nonneg omega x0 v0

/-- Migrated from `MechLib.Mechanics.SHM.turningPoint_def`. -/
theorem turningPoint_def (A : Length) (omega : AngularVelocity) (phi : PhysAngle) (t : Time) :
    TurningPoint A omega phi t = (velocity A omega phi t = 0)
 := by
  simpa using MechLib.Mechanics.SHM.turningPoint_def A omega phi t

end SHM

namespace DampedSHM
open MechLib.Mechanics.DampedSHM

/-- Migrated from `MechLib.Mechanics.DampedSHM.m_ne_zero`. -/
theorem m_ne_zero (P : Params) : P.m.val ≠ 0
 := by
  simpa using MechLib.Mechanics.DampedSHM.Params.m_ne_zero P

/-- Migrated from `MechLib.Mechanics.DampedSHM.k_ne_zero`. -/
theorem k_ne_zero (P : Params) : P.k.val ≠ 0
 := by
  simpa using MechLib.Mechanics.DampedSHM.Params.k_ne_zero P

/-- Migrated from `MechLib.Mechanics.DampedSHM.omega0_pos`. -/
theorem omega0_pos (P : Params) : 0 < P.omega0.val
 := by
  simpa using MechLib.Mechanics.DampedSHM.Params.omega0_pos P

/-- Migrated from `MechLib.Mechanics.DampedSHM.omega0_sq_val`. -/
theorem omega0_sq_val (P : Params) : P.omega0.val ^ 2 = P.k.val / P.m.val
 := by
  simpa using MechLib.Mechanics.DampedSHM.Params.omega0_sq_val P

/-- Migrated from `MechLib.Mechanics.DampedSHM.equationResidual_eq`. -/
theorem equationResidual_eq (P : Params) (x : Time → Length) (v : Time → Speed)
    (a : Time → Acceleration) :
    equationResidual P x v a =
      (fun t =>
        P.m * a t
          + Quantity.cast (P.gamma * v t) SI.damping_speed_eq_force
          + Quantity.cast (P.k * x t) SI.spring_plus_length_eq_force)
 := by
  simpa using MechLib.Mechanics.DampedSHM.equationResidual_eq P x v a

/-- Migrated from `MechLib.Mechanics.DampedSHM.energy_eq`. -/
theorem energy_eq (P : Params) (x : Time → Length) (v : Time → Speed) :
    energy P x v = fun t => kineticEnergy P v t + potentialEnergy P x t
 := by
  simpa using MechLib.Mechanics.DampedSHM.energy_eq P x v

/-- Migrated from `MechLib.Mechanics.DampedSHM.discriminant_eq`. -/
theorem discriminant_eq (P : Params) :
    discriminant P =
      (P.gamma ** 2)
        - Quantity.cast ((4 : ℝ) • (P.m * P.k)) SI.mass_plus_spring_eq_damping_discriminant
 := by
  simpa using MechLib.Mechanics.DampedSHM.discriminant_eq P

/-- Migrated from `MechLib.Mechanics.DampedSHM.regimes_trichotomy`. -/
theorem regimes_trichotomy (P : Params) :
    IsUnderdamped P ∨ IsCriticallyDamped P ∨ IsOverdamped P
 := by
  simpa using MechLib.Mechanics.DampedSHM.regimes_trichotomy P

/-- Migrated from `MechLib.Mechanics.DampedSHM.underdamped_not_overdamped`. -/
theorem underdamped_not_overdamped (P : Params) :
    IsUnderdamped P → ¬ IsOverdamped P
 := by
  simpa using MechLib.Mechanics.DampedSHM.underdamped_not_overdamped P

/-- Migrated from `MechLib.Mechanics.DampedSHM.undamped_is_underdamped`. -/
theorem undamped_is_underdamped (P : Params) (hgamma : P.gamma = 0) :
    IsUnderdamped P
 := by
  simpa using MechLib.Mechanics.DampedSHM.undamped_is_underdamped P hgamma

/-- Migrated from `MechLib.Mechanics.DampedSHM.damping_sub_mass_eq_frequency`. -/
theorem damping_sub_mass_eq_frequency : SI.dampingDim - SI.massDim = SI.frequencyDim
 := by
  simpa using MechLib.Mechanics.DampedSHM.damping_sub_mass_eq_frequency

/-- Migrated from `MechLib.Mechanics.DampedSHM.mass_sub_damping_eq_time`. -/
theorem mass_sub_damping_eq_time : SI.massDim - SI.dampingDim = SI.timeDim
 := by
  simpa using MechLib.Mechanics.DampedSHM.mass_sub_damping_eq_time

/-- Migrated from `MechLib.Mechanics.DampedSHM.zero_add_zero_eq_zero`. -/
theorem zero_add_zero_eq_zero : ((0 : Dim) + (0 : Dim)) = (0 : Dim)
 := by
  simpa using MechLib.Mechanics.DampedSHM.zero_add_zero_eq_zero

/-- Migrated from `MechLib.Mechanics.DampedSHM.qualityFactor_mul_dampingRatio`. -/
theorem qualityFactor_mul_dampingRatio (P : Params) (hgamma : P.gamma.val ≠ 0) :
    Quantity.cast (qualityFactor P * dampingRatio P) zero_add_zero_eq_zero
      = (((1 / 2 : ℝ)) : Dimensionless)
 := by
  simpa using MechLib.Mechanics.DampedSHM.qualityFactor_mul_dampingRatio P hgamma

/-- Migrated from `MechLib.Mechanics.DampedSHM.relaxationTime_mul_dampingRate`. -/
theorem relaxationTime_mul_dampingRate (P : Params) (hgamma : P.gamma.val ≠ 0) :
    Quantity.cast (relaxationTime P * dampingRate P) SI.time_plus_angular_velocity_eq_dimensionless
      = (((1 / 2 : ℝ)) : Dimensionless)
 := by
  simpa using MechLib.Mechanics.DampedSHM.relaxationTime_mul_dampingRate P hgamma

/-- Migrated from `MechLib.Mechanics.DampedSHM.equationResidual_gamma_zero`. -/
theorem equationResidual_gamma_zero
    (P : Params) (x : Time → Length) (v : Time → Speed) (a : Time → Acceleration)
    (hgamma : P.gamma = 0) :
    equationResidual P x v a = undampedResidual P x a
 := by
  simpa using MechLib.Mechanics.DampedSHM.equationResidual_gamma_zero P x v a hgamma

/-- Migrated from `MechLib.Mechanics.DampedSHM.equationOfMotion_gamma_zero_iff`. -/
theorem equationOfMotion_gamma_zero_iff
    (P : Params) (x : Time → Length) (v : Time → Speed) (a : Time → Acceleration)
    (hgamma : P.gamma = 0) :
    EquationOfMotion P x v a ↔ UndampedEquationOfMotion P x a
 := by
  simpa using MechLib.Mechanics.DampedSHM.equationOfMotion_gamma_zero_iff P x v a hgamma

/-- Migrated from `MechLib.Mechanics.DampedSHM.energyDissipationLaw_eq`. -/
theorem energyDissipationLaw_eq
    (P : Params) (x : Time → Length) (v : Time → Speed) (dEdt : Time → Power) :
    EnergyDissipationLaw P x v dEdt = (∀ t, dEdt t = energyDissipationRate P v t)
 := by
  simpa using MechLib.Mechanics.DampedSHM.energyDissipationLaw_eq P x v dEdt

/-- Migrated from `MechLib.Mechanics.DampedSHM.underdampedClosedForm_eq`. -/
theorem underdampedClosedForm_eq
    (P : Params) (x : Time → Length) (v : Time → Speed) (a : Time → Acceleration) :
    IsUnderdampedClosedForm P x v a = (IsUnderdamped P ∧ EquationOfMotion P x v a)
 := by
  simpa using MechLib.Mechanics.DampedSHM.underdampedClosedForm_eq P x v a

/-- Migrated from `MechLib.Mechanics.DampedSHM.criticalClosedForm_eq`. -/
theorem criticalClosedForm_eq
    (P : Params) (x : Time → Length) (v : Time → Speed) (a : Time → Acceleration) :
    IsCriticalClosedForm P x v a = (IsCriticallyDamped P ∧ EquationOfMotion P x v a)
 := by
  simpa using MechLib.Mechanics.DampedSHM.criticalClosedForm_eq P x v a

/-- Migrated from `MechLib.Mechanics.DampedSHM.overdampedClosedForm_eq`. -/
theorem overdampedClosedForm_eq
    (P : Params) (x : Time → Length) (v : Time → Speed) (a : Time → Acceleration) :
    IsOverdampedClosedForm P x v a = (IsOverdamped P ∧ EquationOfMotion P x v a)
 := by
  simpa using MechLib.Mechanics.DampedSHM.overdampedClosedForm_eq P x v a

end DampedSHM

namespace CentralForce
open MechLib.Mechanics.CentralForce

/-- Migrated from `MechLib.Mechanics.CentralForce.fin_induction_three_one`. -/
@[simp] theorem fin_induction_three_one {A : Type} (a : A) (f : (i : Fin 2) → A → A) :
    Fin.induction (motive := fun _ : Fin 3 => A) a f (1 : Fin 3) = f 0 a := by
  simpa using MechLib.Mechanics.CentralForce.fin_induction_three_one a f

/-- Migrated from `MechLib.Mechanics.CentralForce.fin_induction_three_two`. -/
@[simp] theorem fin_induction_three_two {A : Type} (a : A) (f : (i : Fin 2) → A → A) :
    Fin.induction (motive := fun _ : Fin 3 => A) a f (2 : Fin 3) = f 1 (f 0 a) := by
  simpa using MechLib.Mechanics.CentralForce.fin_induction_three_two a f

/-- Migrated from `MechLib.Mechanics.CentralForce.fin_induction_two_one`. -/
@[simp] theorem fin_induction_two_one {A : Type} (a : A) (f : (i : Fin 1) → A → A) :
    Fin.induction (motive := fun _ : Fin 2 => A) a f (1 : Fin 2) = f 0 a := by
  simpa using MechLib.Mechanics.CentralForce.fin_induction_two_one a f

/-- Migrated from `MechLib.Mechanics.CentralForce.cross_self_zero`. -/
theorem cross_self_zero {d : Dim} (u : VecQuantity d 3) : u ×ᵥ u = 0
 := by
  simpa using MechLib.Mechanics.CentralForce.cross_self_zero u

/-- Migrated from `MechLib.Mechanics.CentralForce.angularMomentum_two_sub_mass_two_length_eq_energy`. -/
theorem angularMomentum_two_sub_mass_two_length_eq_energy :
    (2 : ℕ) • SI.angularMomentumDim - (SI.massDim + (2 : ℕ) • SI.lengthDim) = SI.energyDim
 := by
  simpa using MechLib.Mechanics.CentralForce.angularMomentum_two_sub_mass_two_length_eq_energy

/-- Migrated from `MechLib.Mechanics.CentralForce.energy_plus_length_sub_length_eq_energy`. -/
theorem energy_plus_length_sub_length_eq_energy :
    (SI.energyDim + SI.lengthDim) - SI.lengthDim = SI.energyDim
 := by
  simpa using MechLib.Mechanics.CentralForce.energy_plus_length_sub_length_eq_energy

/-- Migrated from `MechLib.Mechanics.CentralForce.hookeCentralForce_eq`. -/
theorem hookeCentralForce_eq (k : SpringConstant) (r : VecLength 3) :
    hookeCentralForce k r = VecQuantity.cast ((-k) * r) SI.spring_plus_length_eq_force
 := by
  simpa using MechLib.Mechanics.CentralForce.hookeCentralForce_eq k r

/-- Migrated from `MechLib.Mechanics.CentralForce.hookeCentralForce_torque_zero`. -/
theorem hookeCentralForce_torque_zero (k : SpringConstant) (r : VecLength 3) :
    Rotation.torque r (hookeCentralForce k r) = 0
 := by
  simpa using MechLib.Mechanics.CentralForce.hookeCentralForce_torque_zero k r

/-- Migrated from `MechLib.Mechanics.CentralForce.hookeCentralForce_isCentral`. -/
theorem hookeCentralForce_isCentral (k : SpringConstant) (r : VecLength 3) :
    IsCentralForcePair r (hookeCentralForce k r)
 := by
  simpa using MechLib.Mechanics.CentralForce.hookeCentralForce_isCentral k r

/-- Migrated from `MechLib.Mechanics.CentralForce.centrifugalPotentialTerm_eq`. -/
theorem centrifugalPotentialTerm_eq (L : AngularMomentum) (m : Mass) (r : Length) :
    centrifugalPotentialTerm L m r =
      Quantity.cast ((L ** 2) / (((2 : ℝ) • m) * (r ** 2)))
        angularMomentum_two_sub_mass_two_length_eq_energy
 := by
  simpa using MechLib.Mechanics.CentralForce.centrifugalPotentialTerm_eq L m r

/-- Migrated from `MechLib.Mechanics.CentralForce.effectivePotential_eq`. -/
theorem effectivePotential_eq (U : Length → Energy) (L : AngularMomentum) (m : Mass) (r : Length) :
    effectivePotential U L m r = U r + centrifugalPotentialTerm L m r
 := by
  simpa using MechLib.Mechanics.CentralForce.effectivePotential_eq U L m r

/-- Migrated from `MechLib.Mechanics.CentralForce.inverseSquarePotential_eq`. -/
theorem inverseSquarePotential_eq (μ : GravParameter) (r : Length) :
    inverseSquarePotential μ r = Quantity.cast (-(μ / r)) energy_plus_length_sub_length_eq_energy
 := by
  simpa using MechLib.Mechanics.CentralForce.inverseSquarePotential_eq μ r

/-- Migrated from `MechLib.Mechanics.CentralForce.radialEquation_eq`. -/
theorem radialEquation_eq
    (m : Mass)
    (r : Kinematics.ScalarTrajectory)
    (aR : Kinematics.ScalarAccelerationField)
    (dUeffdr : Length → Force) :
    RadialEquation m r aR dUeffdr = (∀ t, m * aR t = -dUeffdr (r t))
 := by
  simpa using MechLib.Mechanics.CentralForce.radialEquation_eq m r aR dUeffdr

/-- Migrated from `MechLib.Mechanics.CentralForce.keplerSecondLaw_eq`. -/
theorem keplerSecondLaw_eq (arealVelocity : ℝ → ℝ) :
    KeplerSecondLaw arealVelocity = (∃ c : ℝ, ∀ t, arealVelocity t = c)
 := by
  simpa using MechLib.Mechanics.CentralForce.keplerSecondLaw_eq arealVelocity

/-- Migrated from `MechLib.Mechanics.CentralForce.classifyInverseSquareOrbit_trichotomy`. -/
theorem classifyInverseSquareOrbit_trichotomy (E : Energy) :
    classifyInverseSquareOrbit E = OrbitClass.ellipse
      ∨ classifyInverseSquareOrbit E = OrbitClass.parabola
      ∨ classifyInverseSquareOrbit E = OrbitClass.hyperbola
 := by
  simpa using MechLib.Mechanics.CentralForce.classifyInverseSquareOrbit_trichotomy E

end CentralForce

end
end Verified
end Systems
end MechLib
