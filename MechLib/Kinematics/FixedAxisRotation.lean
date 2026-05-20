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
namespace FixedAxisRotation

open MechLib.Spec
open MechLib.Units
open MechLib.SI

noncomputable section

/-! Course-layer module for `kinematics.fixed_axis_rotation`.

Spec topic id: `kinematics.fixed_axis_rotation`. -/
/-- Fixed-axis rotational kinematic state. -/
structure FixedAxisRotationState where
  angle : MechLib.SI.PhysAngle
  angularVelocity : MechLib.SI.AngularVelocity
  angularAcceleration : MechLib.SI.AngularAcceleration

/-- Angular position as a function of chart time. -/
abbrev AngularPositionField := ℝ → MechLib.SI.PhysAngle

/-- Angular velocity as a function of chart time. -/
abbrev AngularVelocityField := ℝ → MechLib.SI.AngularVelocity

/-- Angular acceleration as a function of chart time. -/
abbrev AngularAccelerationField := ℝ → MechLib.SI.AngularAcceleration

/-- Angular velocity is the derivative of angular position at value level. -/
def HasAngularVelocity (theta : AngularPositionField) (omega : AngularVelocityField) : Prop :=
  ∀ t, HasDerivAt (fun τ => (theta τ).val) (omega t).val t

/-- Angular acceleration is the derivative of angular velocity at value level. -/
def HasAngularAcceleration (omega : AngularVelocityField) (alpha : AngularAccelerationField) : Prop :=
  ∀ t, HasDerivAt (fun τ => (omega τ).val) (alpha t).val t

/-- Angular displacement for fixed-axis motion. -/
def angularDisplacement (final initial : MechLib.SI.PhysAngle) : MechLib.SI.PhysAngle :=
  final - initial

/-- Fixed-axis rotation residual with supplied angular acceleration. -/
def FixedAxisRotationResidual (state : ℝ → FixedAxisRotationState) : Prop :=
  ∀ t, HasDerivAt (fun τ => (state τ).angularVelocity.val) (state t).angularAcceleration.val t

theorem angularDisplacement_eq (final initial : MechLib.SI.PhysAngle) :
    angularDisplacement final initial = final - initial := rfl

/-- If angular position has closed-form value `f`, then angular velocity has
value `f'` whenever `f'` is the derivative of `f`. -/
theorem angular_velocity_value_eq_deriv_of_angle_value
    {theta : AngularPositionField} {omega : AngularVelocityField}
    {f f' : ℝ → ℝ}
    (hθ : ∀ t, (theta t).val = f t)
    (hf : ∀ t, HasDerivAt f (f' t) t)
    (hω : HasAngularVelocity theta omega) :
    ∀ t, (omega t).val = f' t := by
  intro t
  have hfun : (fun τ => (theta τ).val) = f := by
    funext τ
    exact hθ τ
  have hω' : HasDerivAt f (omega t).val t := by
    simpa [hfun] using hω t
  exact hω'.unique (hf t)

/-- If angular velocity has closed-form value `f`, then angular acceleration
has value `f'` whenever `f'` is the derivative of `f`. -/
theorem angular_acceleration_value_eq_deriv_of_omega_value
    {omega : AngularVelocityField} {alpha : AngularAccelerationField}
    {f f' : ℝ → ℝ}
    (hωf : ∀ t, (omega t).val = f t)
    (hf : ∀ t, HasDerivAt f (f' t) t)
    (hα : HasAngularAcceleration omega alpha) :
    ∀ t, (alpha t).val = f' t := by
  intro t
  have hfun : (fun τ => (omega τ).val) = f := by
    funext τ
    exact hωf τ
  have hα' : HasDerivAt f (alpha t).val t := by
    simpa [hfun] using hα t
  exact hα'.unique (hf t)

/-- Exported module metadata for this course-layer wrapper. -/
def moduleMetadata : ModuleMetadata :=
  {
    modulePath := "MechLib.Kinematics.FixedAxisRotation",
    topicId := "kinematics.fixed_axis_rotation",
    status := .schema,
    trustLevel := .interface,
    conceptIds := ["concept.moment"],
    lawSchemaIds := [],
    problemSchemaIds := [],
    exampleProblems := ["Rotation about a fixed axis"],
    notes := ["Typed API: PhysAngle, AngularVelocity, AngularAcceleration, AngularPositionField; derivative residual uses Real chart time."]
  }

#check FixedAxisRotationState
#check AngularPositionField
#check HasAngularVelocity
#check angular_velocity_value_eq_deriv_of_angle_value
#check angular_acceleration_value_eq_deriv_of_omega_value
#check angularDisplacement
#check moduleMetadata

end
end FixedAxisRotation
end Kinematics
end MechLib
