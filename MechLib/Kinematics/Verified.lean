import Mathlib
import MechLib.Mechanics.Kinematics

/-!
Verified theorem declarations migrated from `MechLib.Mechanics.*`.

The old `MechLib.Mechanics.*` names are compatibility abbreviations; these
course-layer declarations are the retrieval-facing theorem locations.
-/

namespace MechLib
namespace Kinematics
namespace Verified

open Units SI
open MechLib.Mechanics

noncomputable section

namespace Kinematics
open MechLib.Mechanics.Kinematics

/-- Migrated from `MechLib.Mechanics.Kinematics.displacement_eq_sub`. -/
theorem displacement_eq_sub (x2 x1 : Length) : displacement x2 x1 = x2 - x1
 := by
  simpa using MechLib.Mechanics.Kinematics.displacement_eq_sub x2 x1

/-- Migrated from `MechLib.Mechanics.Kinematics.position_from_displacement`. -/
theorem position_from_displacement (x2 x1 dx : Length) (h : dx = displacement x2 x1) :
    x2 = x1 + dx
 := by
  simpa using MechLib.Mechanics.Kinematics.position_from_displacement x2 x1 dx h

/-- Migrated from `MechLib.Mechanics.Kinematics.constant_speed_relation`. -/
theorem constant_speed_relation (x2 x1 : Length) (v : Speed) (t : Time)
    (h : displacement x2 x1 = Quantity.cast (v * t) SI.speed_time_eq_length) :
    x2 = x1 + Quantity.cast (v * t) SI.speed_time_eq_length
 := by
  simpa using MechLib.Mechanics.Kinematics.constant_speed_relation x2 x1 v t h

/-- Migrated from `MechLib.Mechanics.Kinematics.velocity_increment`. -/
theorem velocity_increment (v v0 : Speed) (a : Acceleration) (t : Time)
    (h : v = velocityConstAccel v0 a t) :
    v - v0 = Quantity.cast (a * t) SI.acceleration_time_eq_speed
 := by
  simpa using MechLib.Mechanics.Kinematics.velocity_increment v v0 a t h

/-- Migrated from `MechLib.Mechanics.Kinematics.displacement_forms_equiv`. -/
theorem displacement_forms_equiv (v v0 : Speed) (a : Acceleration) (t : Time)
    (hv : v = velocityConstAccel v0 a t) :
    Quantity.cast (v0 * t) SI.speed_time_eq_length
      + (1 / 2 : ℝ) • Quantity.cast (a * (t ** 2)) SI.acceleration_two_time_eq_length
        = displacementConstAccelForm2 v0 v t
 := by
  simpa using MechLib.Mechanics.Kinematics.displacement_forms_equiv v v0 a t hv

/-- Migrated from `MechLib.Mechanics.Kinematics.trajectory_reconstruction`. -/
theorem trajectory_reconstruction (xB xA : ScalarTrajectory) :
    xB = fun t => xA t + relativeTrajectory xB xA t
 := by
  simpa using MechLib.Mechanics.Kinematics.trajectory_reconstruction xB xA

/-- Migrated from `MechLib.Mechanics.Kinematics.relative_trajectory_trans`. -/
theorem relative_trajectory_trans (xA xB xC : ScalarTrajectory) :
    relativeTrajectory xC xA = fun t => relativeTrajectory xC xB t + relativeTrajectory xB xA t
 := by
  simpa using MechLib.Mechanics.Kinematics.relative_trajectory_trans xA xB xC

/-- Migrated from `MechLib.Mechanics.Kinematics.relative_velocity_trans`. -/
theorem relative_velocity_trans (vA vB vC : ScalarVelocityField) :
    relativeVelocity vC vA = fun t => relativeVelocity vC vB t + relativeVelocity vB vA t
 := by
  simpa using MechLib.Mechanics.Kinematics.relative_velocity_trans vA vB vC

/-- Migrated from `MechLib.Mechanics.Kinematics.relative_acceleration_trans`. -/
theorem relative_acceleration_trans (aA aB aC : ScalarAccelerationField) :
    relativeAcceleration aC aA =
      fun t => relativeAcceleration aC aB t + relativeAcceleration aB aA t
 := by
  simpa using MechLib.Mechanics.Kinematics.relative_acceleration_trans aA aB aC

/-- Migrated from `MechLib.Mechanics.Kinematics.hasVelocity_relative`. -/
theorem hasVelocity_relative
    (xA xB : ScalarTrajectory) (vA vB : ScalarVelocityField)
    (hA : HasVelocity xA vA) (hB : HasVelocity xB vB) :
    HasVelocity (relativeTrajectory xB xA) (relativeVelocity vB vA)
 := by
  simpa using MechLib.Mechanics.Kinematics.hasVelocity_relative xA xB vA vB hA hB

/-- Migrated from `MechLib.Mechanics.Kinematics.hasAcceleration_relative`. -/
theorem hasAcceleration_relative
    (vA vB : ScalarVelocityField) (aA aB : ScalarAccelerationField)
    (hA : HasAcceleration vA aA) (hB : HasAcceleration vB aB) :
    HasAcceleration (relativeVelocity vB vA) (relativeAcceleration aB aA)
 := by
  simpa using MechLib.Mechanics.Kinematics.hasAcceleration_relative vA vB aA aB hA hB

/-- Migrated from `MechLib.Mechanics.Kinematics.hasVelocity_linear_combination`. -/
theorem hasVelocity_linear_combination
    (x1 x2 : ScalarTrajectory) (v1 v2 : ScalarVelocityField) (c1 c2 : ℝ)
    (h1 : HasVelocity x1 v1) (h2 : HasVelocity x2 v2) :
    HasVelocity (fun t => c1 • x1 t + c2 • x2 t) (fun t => c1 • v1 t + c2 • v2 t)
 := by
  simpa using MechLib.Mechanics.Kinematics.hasVelocity_linear_combination x1 x2 v1 v2 c1 c2 h1 h2

/-- Migrated from `MechLib.Mechanics.Kinematics.hasAcceleration_linear_combination`. -/
theorem hasAcceleration_linear_combination
    (v1 v2 : ScalarVelocityField) (a1 a2 : ScalarAccelerationField) (c1 c2 : ℝ)
    (h1 : HasAcceleration v1 a1) (h2 : HasAcceleration v2 a2) :
    HasAcceleration (fun t => c1 • v1 t + c2 • v2 t) (fun t => c1 • a1 t + c2 • a2 t)
 := by
  simpa using MechLib.Mechanics.Kinematics.hasAcceleration_linear_combination v1 v2 a1 a2 c1 c2 h1 h2

/-- Migrated from `MechLib.Mechanics.Kinematics.linear_constraint_velocity`. -/
theorem linear_constraint_velocity
    (x1 x2 : ScalarTrajectory) (v1 v2 : ScalarVelocityField)
    (c1 c2 : ℝ) (L : Length)
    (hConstraint : ∀ t, c1 • x1 t + c2 • x2 t = L)
    (h1 : HasVelocity x1 v1) (h2 : HasVelocity x2 v2) :
    ∀ t, c1 • v1 t + c2 • v2 t = 0
 := by
  simpa using MechLib.Mechanics.Kinematics.linear_constraint_velocity x1 x2 v1 v2 c1 c2 L hConstraint h1 h2

/-- Migrated from `MechLib.Mechanics.Kinematics.linear_constraint_acceleration`. -/
theorem linear_constraint_acceleration
    (v1 v2 : ScalarVelocityField) (a1 a2 : ScalarAccelerationField)
    (c1 c2 : ℝ) (V : Speed)
    (hConstraint : ∀ t, c1 • v1 t + c2 • v2 t = V)
    (h1 : HasAcceleration v1 a1) (h2 : HasAcceleration v2 a2) :
    ∀ t, c1 • a1 t + c2 • a2 t = 0
 := by
  simpa using MechLib.Mechanics.Kinematics.linear_constraint_acceleration v1 v2 a1 a2 c1 c2 V hConstraint h1 h2

/-- Migrated from `MechLib.Mechanics.Kinematics.rope_constraint_velocity`. -/
theorem rope_constraint_velocity
    (x1 x2 : ScalarTrajectory) (v1 v2 : ScalarVelocityField) (L : Length)
    (hConstraint : ∀ t, x1 t + x2 t = L)
    (h1 : HasVelocity x1 v1) (h2 : HasVelocity x2 v2) :
    ∀ t, v1 t + v2 t = 0
 := by
  simpa using MechLib.Mechanics.Kinematics.rope_constraint_velocity x1 x2 v1 v2 L hConstraint h1 h2

/-- Migrated from `MechLib.Mechanics.Kinematics.rigid_pair_velocity_equal`. -/
theorem rigid_pair_velocity_equal
    (xA xB : ScalarTrajectory) (vA vB : ScalarVelocityField) (Δ : Length)
    (hConstraint : ∀ t, relativeTrajectory xB xA t = Δ)
    (hA : HasVelocity xA vA) (hB : HasVelocity xB vB) :
    ∀ t, vB t = vA t
 := by
  simpa using MechLib.Mechanics.Kinematics.rigid_pair_velocity_equal xA xB vA vB Δ hConstraint hA hB

/-- Migrated from `MechLib.Mechanics.Kinematics.vec_velocity_const_accel_eq`. -/
theorem vec_velocity_const_accel_eq {n : ℕ} (v0 : VecSpeed n) (a : VecAcceleration n) (t : Time) :
    vecVelocityConstAccel v0 a t = v0 + VecQuantity.cast (a * t) SI.acceleration_time_eq_speed
 := by
  simpa using MechLib.Mechanics.Kinematics.vec_velocity_const_accel_eq v0 a t

/-- Migrated from `MechLib.Mechanics.Kinematics.vec_relative_trajectory_trans`. -/
theorem vec_relative_trajectory_trans {n : ℕ} (xA xB xC : VecTrajectory n) :
    vecRelativeTrajectory xC xA =
      fun t => vecRelativeTrajectory xC xB t + vecRelativeTrajectory xB xA t
 := by
  simpa using MechLib.Mechanics.Kinematics.vec_relative_trajectory_trans xA xB xC

/-- Migrated from `MechLib.Mechanics.Kinematics.vec_relative_velocity_trans`. -/
theorem vec_relative_velocity_trans {n : ℕ} (vA vB vC : VecVelocityField n) :
    vecRelativeVelocity vC vA =
      fun t => vecRelativeVelocity vC vB t + vecRelativeVelocity vB vA t
 := by
  simpa using MechLib.Mechanics.Kinematics.vec_relative_velocity_trans vA vB vC

/-- Migrated from `MechLib.Mechanics.Kinematics.hasVecVelocity_relative`. -/
theorem hasVecVelocity_relative {n : ℕ}
    (xA xB : VecTrajectory n) (vA vB : VecVelocityField n)
    (hA : HasVecVelocity xA vA) (hB : HasVecVelocity xB vB) :
    HasVecVelocity (vecRelativeTrajectory xB xA) (vecRelativeVelocity vB vA)
 := by
  simpa using MechLib.Mechanics.Kinematics.hasVecVelocity_relative xA xB vA vB hA hB

/-- Migrated from `MechLib.Mechanics.Kinematics.hasVecAcceleration_relative`. -/
theorem hasVecAcceleration_relative {n : ℕ}
    (vA vB : VecVelocityField n) (aA aB : VecAccelerationField n)
    (hA : HasVecAcceleration vA aA) (hB : HasVecAcceleration vB aB) :
    HasVecAcceleration (vecRelativeVelocity vB vA) (vecRelativeAcceleration aB aA)
 := by
  simpa using MechLib.Mechanics.Kinematics.hasVecAcceleration_relative vA vB aA aB hA hB

/-- Migrated from `MechLib.Mechanics.Kinematics.rigid_pair_vec_velocity_equal`. -/
theorem rigid_pair_vec_velocity_equal {n : ℕ}
    (xA xB : VecTrajectory n) (vA vB : VecVelocityField n) (r : VecLength n)
    (hConstraint : ∀ t, vecRelativeTrajectory xB xA t = r)
    (hA : HasVecVelocity xA vA) (hB : HasVecVelocity xB vB) :
    ∀ t, vB t = vA t
 := by
  simpa using MechLib.Mechanics.Kinematics.rigid_pair_vec_velocity_equal xA xB vA vB r hConstraint hA hB

/-- Migrated from `MechLib.Mechanics.Kinematics.pfaffConstraint1D_linear_combination`. -/
theorem pfaffConstraint1D_linear_combination
    (a1 b1 a2 b2 : ℝ → ℝ) (v : ScalarVelocityField)
    (h1 : PfaffConstraint1D a1 b1 v) (h2 : PfaffConstraint1D a2 b2 v)
    (c1 c2 : ℝ) :
    PfaffConstraint1D (fun t => c1 * a1 t + c2 * a2 t) (fun t => c1 * b1 t + c2 * b2 t) v
 := by
  simpa using MechLib.Mechanics.Kinematics.pfaffConstraint1D_linear_combination a1 b1 a2 b2 v h1 h2 c1 c2

end Kinematics

end
end Verified
end Kinematics
end MechLib
