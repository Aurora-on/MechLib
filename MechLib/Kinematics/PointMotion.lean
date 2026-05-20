import MechLib.Spec.ModuleMetadata
import MechLib.Units.Dim
import MechLib.Units.Quantity
import MechLib.Units.VecQuantity
import MechLib.SI
import MechLib.Mechanics.Kinematics
import MechLib.Mechanics.Dynamics
import MechLib.Mechanics.SystemDynamics
import MechLib.Mechanics.WorkEnergy
import MechLib.Mechanics.MomentumImpulse
import MechLib.Mechanics.Rotation
import MechLib.Mechanics.CentralForce
import MechLib.Mechanics.SHM
import MechLib.Mechanics.DampedSHM

set_option linter.dupNamespace false
set_option linter.unusedVariables false

namespace MechLib
namespace Kinematics
namespace PointMotion

open MechLib.Spec
open MechLib.Units
open MechLib.SI

noncomputable section

/-! Course-layer module for `kinematics.point_motion`.

Spec topic id: `kinematics.point_motion`. -/
/-- Course-layer alias for scalar trajectories. -/
abbrev ScalarTrajectory := MechLib.Mechanics.Kinematics.ScalarTrajectory

/-- Course-layer alias for point velocity fields. -/
abbrev ScalarVelocityField := MechLib.Mechanics.Kinematics.ScalarVelocityField

/-- Course-layer alias for position. -/
abbrev Position := MechLib.SI.Length

/-- Course-layer alias for displacement. -/
abbrev Displacement := MechLib.SI.Length

/-- Course-layer alias for velocity. -/
abbrev Velocity := MechLib.SI.Speed

/-- Course-layer alias for acceleration. -/
abbrev Acceleration := MechLib.SI.Acceleration

/-- Point-motion state at one instant. -/
structure PointMotionState where
  position : Position
  velocity : Velocity
  acceleration : Acceleration

/-- Uniform-acceleration motion data. -/
structure UniformAccelerationMotion where
  initialPosition : Position
  initialVelocity : Velocity
  acceleration : Acceleration

/-- Velocity at elapsed time for uniform acceleration. -/
def velocityAt (motion : UniformAccelerationMotion) (t : MechLib.SI.Time) : Velocity :=
  MechLib.Mechanics.Kinematics.velocityConstAccel motion.initialVelocity motion.acceleration t

/-- Position at elapsed time for uniform acceleration. -/
def positionAt (motion : UniformAccelerationMotion) (t : MechLib.SI.Time) : Position :=
  MechLib.Mechanics.Kinematics.positionConstAccel
    motion.initialPosition motion.initialVelocity motion.acceleration t

/-- Point-motion schema connecting position, velocity, and acceleration fields. -/
def PointKinematicsSchema
    (x : ScalarTrajectory) (v : ScalarVelocityField)
    (a : MechLib.Mechanics.Kinematics.ScalarAccelerationField) : Prop :=
  MechLib.Mechanics.Kinematics.HasVelocity x v
    ∧ MechLib.Mechanics.Kinematics.HasAcceleration v a

/-- Course-layer predicate: the velocity field `v` is the time derivative of
the position trajectory `x`, using the value-level derivative chart already
verified in `MechLib.Mechanics.Kinematics.HasVelocity`. -/
def VelocityDerivativeRelation (x : ScalarTrajectory) (v : ScalarVelocityField) : Prop :=
  MechLib.Mechanics.Kinematics.HasVelocity x v

/-- Course-layer predicate: the acceleration field `a` is the time derivative of
the velocity field `v`, using the value-level derivative chart already verified
in `MechLib.Mechanics.Kinematics.HasAcceleration`. -/
def AccelerationDerivativeRelation (v : ScalarVelocityField)
    (a : MechLib.Mechanics.Kinematics.ScalarAccelerationField) : Prop :=
  MechLib.Mechanics.Kinematics.HasAcceleration v a

/-- Component-level position-to-velocity derivative relation for vector trajectories. -/
def ComponentVelocityDerivativeRelation {n : ℕ}
    (x : MechLib.Mechanics.Kinematics.VecTrajectory n)
    (v : MechLib.Mechanics.Kinematics.VecVelocityField n) (i : Fin n) : Prop :=
  ∀ t : ℝ, HasDerivAt (fun τ => (x τ).val i) ((v t).val i) t

/-- Component-level velocity-to-acceleration derivative relation for vector trajectories. -/
def ComponentAccelerationDerivativeRelation {n : ℕ}
    (v : MechLib.Mechanics.Kinematics.VecVelocityField n)
    (a : MechLib.Mechanics.Kinematics.VecAccelerationField n) (i : Fin n) : Prop :=
  ∀ t : ℝ, HasDerivAt (fun τ => (v τ).val i) ((a t).val i) t

/-- `VelocityDerivativeRelation` is exactly the core `HasVelocity` predicate. -/
theorem velocityDerivativeRelation_iff_hasVelocity
    (x : ScalarTrajectory) (v : ScalarVelocityField) :
    VelocityDerivativeRelation x v ↔ MechLib.Mechanics.Kinematics.HasVelocity x v := by
  rfl

/-- Eliminate the course-layer velocity-derivative predicate at a time point. -/
theorem velocityDerivativeRelation_apply
    (x : ScalarTrajectory) (v : ScalarVelocityField)
    (h : VelocityDerivativeRelation x v) (t : ℝ) :
    HasDerivAt (fun τ => (x τ).val) (v t).val t := by
  exact h t

/-- `AccelerationDerivativeRelation` is exactly the core `HasAcceleration` predicate. -/
theorem accelerationDerivativeRelation_iff_hasAcceleration
    (v : ScalarVelocityField) (a : MechLib.Mechanics.Kinematics.ScalarAccelerationField) :
    AccelerationDerivativeRelation v a ↔ MechLib.Mechanics.Kinematics.HasAcceleration v a := by
  rfl

/-- Eliminate the course-layer acceleration-derivative predicate at a time point. -/
theorem accelerationDerivativeRelation_apply
    (v : ScalarVelocityField) (a : MechLib.Mechanics.Kinematics.ScalarAccelerationField)
    (h : AccelerationDerivativeRelation v a) (t : ℝ) :
    HasDerivAt (fun τ => (v τ).val) (a t).val t := by
  exact h t

/-- A vector velocity derivative gives the derivative of each chosen component. -/
theorem componentVelocityDerivativeRelation_of_hasVecVelocity {n : ℕ}
    (x : MechLib.Mechanics.Kinematics.VecTrajectory n)
    (v : MechLib.Mechanics.Kinematics.VecVelocityField n) (i : Fin n)
    (h : MechLib.Mechanics.Kinematics.HasVecVelocity x v) :
    ComponentVelocityDerivativeRelation x v i := by
  intro t
  exact h t i

/-- A vector acceleration derivative gives the derivative of each chosen component. -/
theorem componentAccelerationDerivativeRelation_of_hasVecAcceleration {n : ℕ}
    (v : MechLib.Mechanics.Kinematics.VecVelocityField n)
    (a : MechLib.Mechanics.Kinematics.VecAccelerationField n) (i : Fin n)
    (h : MechLib.Mechanics.Kinematics.HasVecAcceleration v a) :
    ComponentAccelerationDerivativeRelation v a i := by
  intro t
  exact h t i

/-- If a typed position trajectory has closed-form value `f` and `f'` is its
derivative, then the typed velocity field has value `f'`.

This bridge lets downstream generators state closed-form trajectory data
separately from the typed derivative predicate. -/
theorem velocity_value_eq_deriv_of_position_value
    {x : ScalarTrajectory} {v : ScalarVelocityField}
    {f f' : ℝ → ℝ}
    (hx : ∀ t, (x t).val = f t)
    (hf : ∀ t, HasDerivAt f (f' t) t)
    (hv : VelocityDerivativeRelation x v) :
    ∀ t, (v t).val = f' t := by
  intro t
  have hfun : (fun τ => (x τ).val) = f := by
    funext τ
    exact hx τ
  have hv' : HasDerivAt f (v t).val t := by
    simpa [hfun] using velocityDerivativeRelation_apply x v hv t
  exact hv'.unique (hf t)

/-- If a typed velocity field has closed-form value `f` and `f'` is its
derivative, then the typed acceleration field has value `f'`. -/
theorem acceleration_value_eq_deriv_of_velocity_value
    {v : ScalarVelocityField} {a : MechLib.Mechanics.Kinematics.ScalarAccelerationField}
    {f f' : ℝ → ℝ}
    (hvf : ∀ t, (v t).val = f t)
    (hf : ∀ t, HasDerivAt f (f' t) t)
    (ha : AccelerationDerivativeRelation v a) :
    ∀ t, (a t).val = f' t := by
  intro t
  have hfun : (fun τ => (v τ).val) = f := by
    funext τ
    exact hvf τ
  have ha' : HasDerivAt f (a t).val t := by
    simpa [hfun] using accelerationDerivativeRelation_apply v a ha t
  exact ha'.unique (hf t)

/-- Component version of `velocity_value_eq_deriv_of_position_value`. -/
theorem component_velocity_value_eq_deriv_of_position_component_value {n : ℕ}
    {x : MechLib.Mechanics.Kinematics.VecTrajectory n}
    {v : MechLib.Mechanics.Kinematics.VecVelocityField n}
    {i : Fin n} {f f' : ℝ → ℝ}
    (hx : ∀ t, (x t).val i = f t)
    (hf : ∀ t, HasDerivAt f (f' t) t)
    (hv : ComponentVelocityDerivativeRelation x v i) :
    ∀ t, (v t).val i = f' t := by
  intro t
  have hfun : (fun τ => (x τ).val i) = f := by
    funext τ
    exact hx τ
  have hv' : HasDerivAt f ((v t).val i) t := by
    simpa [hfun] using hv t
  exact hv'.unique (hf t)

/-- Component version of `acceleration_value_eq_deriv_of_velocity_value`. -/
theorem component_acceleration_value_eq_deriv_of_velocity_component_value {n : ℕ}
    {v : MechLib.Mechanics.Kinematics.VecVelocityField n}
    {a : MechLib.Mechanics.Kinematics.VecAccelerationField n}
    {i : Fin n} {f f' : ℝ → ℝ}
    (hvf : ∀ t, (v t).val i = f t)
    (hf : ∀ t, HasDerivAt f (f' t) t)
    (ha : ComponentAccelerationDerivativeRelation v a i) :
    ∀ t, (a t).val i = f' t := by
  intro t
  have hfun : (fun τ => (v τ).val i) = f := by
    funext τ
    exact hvf τ
  have ha' : HasDerivAt f ((a t).val i) t := by
    simpa [hfun] using ha t
  exact ha'.unique (hf t)

/-- Second-derivative relation between typed position and acceleration fields.
It is intentionally defined through an intermediate velocity field so that
proof obligations can name a real typed velocity instead of inventing `x_ddot`
placeholders. -/
def SecondDerivativeRelation
    (x : ScalarTrajectory)
    (a : MechLib.Mechanics.Kinematics.ScalarAccelerationField) : Prop :=
  ∃ v : ScalarVelocityField,
    VelocityDerivativeRelation x v ∧ AccelerationDerivativeRelation v a

/-- Build a second-derivative relation from a velocity derivative and an
acceleration derivative. -/
theorem secondDerivativeRelation_of_velocity_acceleration
    {x : ScalarTrajectory} {v : ScalarVelocityField}
    {a : MechLib.Mechanics.Kinematics.ScalarAccelerationField}
    (hv : VelocityDerivativeRelation x v)
    (ha : AccelerationDerivativeRelation v a) :
    SecondDerivativeRelation x a :=
  ⟨v, hv, ha⟩

/-- If `x.val = f`, `f'` and `f''` are supplied, and the typed acceleration is
the second derivative of `x`, then the acceleration value is `f''`. -/
theorem acceleration_value_eq_second_deriv_of_position_value
    {x : ScalarTrajectory} {a : MechLib.Mechanics.Kinematics.ScalarAccelerationField}
    {f f' f'' : ℝ → ℝ}
    (hx : ∀ t, (x t).val = f t)
    (hf : ∀ t, HasDerivAt f (f' t) t)
    (hf' : ∀ t, HasDerivAt f' (f'' t) t)
    (h2 : SecondDerivativeRelation x a) :
    ∀ t, (a t).val = f'' t := by
  rcases h2 with ⟨v, hv, ha⟩
  have hvf : ∀ t, (v t).val = f' t :=
    velocity_value_eq_deriv_of_position_value hx hf hv
  exact acceleration_value_eq_deriv_of_velocity_value hvf hf' ha

/-- Average velocity over a displacement and elapsed time. -/
def AverageVelocityRelation (dx : Displacement) (dt : MechLib.SI.Time) (vAvg : Velocity) : Prop :=
  vAvg = MechLib.Mechanics.Kinematics.averageVelocity dx dt

/-- Average acceleration over a velocity change and elapsed time, stated at value level. -/
def AverageAccelerationRelation
    (v₂ v₁ : Velocity) (dt : MechLib.SI.Time) (aAvg : Acceleration) : Prop :=
  aAvg.val = (v₂.val - v₁.val) / dt.val

/-- Constant-acceleration velocity update, stated at value level. -/
def ConstantAccelerationVelocityRelation
    (v v₀ : Velocity) (a : Acceleration) (t : MechLib.SI.Time) : Prop :=
  v.val = v₀.val + a.val * t.val

/-- Constant-acceleration speed-squared relation, stated at value level. -/
def ConstantAccelerationSpeedSquaredRelation
    (v v₀ : Velocity) (a : Acceleration) (dx : Displacement) : Prop :=
  v.val ^ 2 = v₀.val ^ 2 + 2 * a.val * dx.val

/-- Centripetal-acceleration magnitude relation, stated at value level. -/
def CentripetalAccelerationRelation
    (aC : Acceleration) (v : Velocity) (r : Position) : Prop :=
  aC.val = v.val ^ 2 / r.val

/-- One-dimensional relative velocity relation, stated at value level. -/
def RelativeVelocityValueRelation
    (vRel vB vA : Velocity) : Prop :=
  vRel.val = vB.val - vA.val

/-- One-dimensional speed magnitude from signed velocity. -/
def SpeedMagnitude1DRelation (speed : Velocity) (vSigned : Velocity) : Prop :=
  speed.val = |vSigned.val|

/-- Extract the scalar equation from the average-velocity relation. -/
theorem averageVelocityRelation_to_value_equation
    {dx : Displacement} {dt : MechLib.SI.Time} {vAvg : Velocity}
    (h : AverageVelocityRelation dx dt vAvg) :
    vAvg.val = dx.val / dt.val := by
  simpa [AverageVelocityRelation, MechLib.Mechanics.Kinematics.averageVelocity] using
    congrArg MechLib.Units.Quantity.val h

/-- Extract the scalar equation from the average-acceleration relation. -/
theorem averageAccelerationRelation_to_value_equation
    {v₂ v₁ : Velocity} {dt : MechLib.SI.Time} {aAvg : Acceleration}
    (h : AverageAccelerationRelation v₂ v₁ dt aAvg) :
    aAvg.val = (v₂.val - v₁.val) / dt.val :=
  h

/-- Extract the scalar equation from the constant-acceleration velocity relation. -/
theorem constantAccelerationVelocityRelation_to_value_equation
    {v v₀ : Velocity} {a : Acceleration} {t : MechLib.SI.Time}
    (h : ConstantAccelerationVelocityRelation v v₀ a t) :
    v.val = v₀.val + a.val * t.val :=
  h

/-- Extract the scalar equation from the constant-acceleration speed-squared relation. -/
theorem constantAccelerationSpeedSquaredRelation_to_value_equation
    {v v₀ : Velocity} {a : Acceleration} {dx : Displacement}
    (h : ConstantAccelerationSpeedSquaredRelation v v₀ a dx) :
    v.val ^ 2 = v₀.val ^ 2 + 2 * a.val * dx.val :=
  h

/-- Extract the scalar equation from the centripetal-acceleration magnitude relation. -/
theorem centripetalAccelerationRelation_to_value_equation
    {aC : Acceleration} {v : Velocity} {r : Position}
    (h : CentripetalAccelerationRelation aC v r) :
    aC.val = v.val ^ 2 / r.val :=
  h

/-- Extract the scalar equation from the one-dimensional relative-velocity relation. -/
theorem relativeVelocityValueRelation_to_value_equation
    {vRel vB vA : Velocity} (h : RelativeVelocityValueRelation vRel vB vA) :
    vRel.val = vB.val - vA.val :=
  h

/-- Course-layer wrapper for the verified uniform-acceleration displacement equivalence. -/
theorem displacement_forms_equiv_course_form
    (v v0 : MechLib.SI.Speed) (a : MechLib.SI.Acceleration) (t : MechLib.SI.Time)
    (hv : v = MechLib.Mechanics.Kinematics.velocityConstAccel v0 a t) :
    MechLib.Units.Quantity.cast (v0 * t) MechLib.SI.speed_time_eq_length
      + (1 / 2 : ℝ) •
        MechLib.Units.Quantity.cast (a * (t ** 2)) MechLib.SI.acceleration_two_time_eq_length
        = MechLib.Mechanics.Kinematics.displacementConstAccelForm2 v0 v t := by
  simpa using MechLib.Mechanics.Kinematics.displacement_forms_equiv v v0 a t hv

example (v0 : MechLib.SI.Speed) (a : MechLib.SI.Acceleration) (t : MechLib.SI.Time) :
    velocityAt { initialPosition := 0, initialVelocity := v0, acceleration := a } t =
      v0 + MechLib.Units.Quantity.cast (a * t) MechLib.SI.acceleration_time_eq_speed := by
  rfl

/-- Exported module metadata for this course-layer wrapper. -/
def moduleMetadata : ModuleMetadata :=
  {
    modulePath := "MechLib.Kinematics.PointMotion",
    topicId := "kinematics.point_motion",
    status := .verified,
    trustLevel := .core,
    conceptIds := [],
    lawSchemaIds := [],
    problemSchemaIds := ["problem.kinematics.uniform_acceleration_point_motion"],
    exampleProblems := ["Point moving with constant acceleration"],
    notes := ["Typed API: Position, Displacement, Velocity, Acceleration, UniformAccelerationMotion; wrapper for Mechanics.Kinematics point-motion API."]
  }

#check ScalarTrajectory
#check VelocityDerivativeRelation
#check velocityDerivativeRelation_iff_hasVelocity
#check velocityDerivativeRelation_apply
#check AccelerationDerivativeRelation
#check accelerationDerivativeRelation_apply
#check ComponentVelocityDerivativeRelation
#check componentVelocityDerivativeRelation_of_hasVecVelocity
#check velocity_value_eq_deriv_of_position_value
#check acceleration_value_eq_deriv_of_velocity_value
#check component_velocity_value_eq_deriv_of_position_component_value
#check component_acceleration_value_eq_deriv_of_velocity_component_value
#check SecondDerivativeRelation
#check acceleration_value_eq_second_deriv_of_position_value
#check AverageVelocityRelation
#check AverageAccelerationRelation
#check ConstantAccelerationVelocityRelation
#check ConstantAccelerationSpeedSquaredRelation
#check CentripetalAccelerationRelation
#check RelativeVelocityValueRelation
#check SpeedMagnitude1DRelation
#check UniformAccelerationMotion
#check moduleMetadata

end
end PointMotion
end Kinematics
end MechLib
