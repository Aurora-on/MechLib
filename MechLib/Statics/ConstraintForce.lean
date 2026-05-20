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
namespace Statics
namespace ConstraintForce

open MechLib.Spec
open MechLib.Units
open MechLib.SI

noncomputable section

/-! Course-layer module for `statics.constraint_force`.

Spec topic id: `statics.constraint_force`. -/
/-- Constraint force with a role label and force vector. -/
structure ConstraintForce where
  role : String
  force : MechLib.SI.VecForce 3
  ideal : Bool

/-- Ideal constraint work schema for virtual displacement planning. -/
def IdealConstraintWork (reaction : ConstraintForce) (virtualDisplacement : MechLib.SI.VecLength 3) : Prop :=
  reaction.ideal = true → (reaction.force ⬝ᵥ virtualDisplacement) = 0

/-- Ideal rope segment interface for massless/frictionless rope modeling. -/
structure IdealRopeSegment where
  tensionA : MechLib.SI.Force
  tensionB : MechLib.SI.Force
  massless : Bool
  frictionless : Bool

/-- Under the ideal-rope assumptions, the two endpoint tensions have equal magnitude. -/
def IdealRopeUniformTension (rope : IdealRopeSegment) : Prop :=
  rope.massless = true ∧ rope.frictionless = true → rope.tensionA = rope.tensionB

/-- Ideal pulley constraint for opposite signed accelerations along one rope. -/
def IdealPulleySharedAcceleration
    (a1 a2 : MechLib.SI.Acceleration) : Prop :=
  a1.val + a2.val = 0

/-- No-slip pulley kinematics, relating linear speed to angular speed by `v = r omega`. -/
def NoSlipPulleyVelocityRelation
    (linearSpeed : MechLib.SI.Speed) (radius : MechLib.SI.Length)
    (omega : MechLib.SI.AngularVelocity) : Prop :=
  linearSpeed.val = radius.val * omega.val

/-- No-slip pulley kinematics, relating tangential acceleration to angular acceleration. -/
def NoSlipPulleyAccelerationRelation
    (tangentialAcceleration : MechLib.SI.Acceleration) (radius : MechLib.SI.Length)
    (alpha : MechLib.SI.AngularAcceleration) : Prop :=
  tangentialAcceleration.val = radius.val * alpha.val

/-- Extract the endpoint tension equality from the ideal-rope schema. -/
theorem idealRopeUniformTension_to_value_equation
    {rope : IdealRopeSegment} (h : IdealRopeUniformTension rope)
    (hm : rope.massless = true) (hf : rope.frictionless = true) :
    rope.tensionA.val = rope.tensionB.val := by
  exact congrArg MechLib.Units.Quantity.val (h ⟨hm, hf⟩)

/-- Extract the acceleration relation from the ideal-pulley schema. -/
theorem idealPulleySharedAcceleration_to_value_equation
    {a1 a2 : MechLib.SI.Acceleration} (h : IdealPulleySharedAcceleration a1 a2) :
    a1.val + a2.val = 0 :=
  h

/-- Extract the no-slip velocity relation for a pulley. -/
theorem noSlipPulleyVelocityRelation_to_value_equation
    {linearSpeed : MechLib.SI.Speed} {radius : MechLib.SI.Length}
    {omega : MechLib.SI.AngularVelocity}
    (h : NoSlipPulleyVelocityRelation linearSpeed radius omega) :
    linearSpeed.val = radius.val * omega.val :=
  h

/-- Extract the no-slip tangential-acceleration relation for a pulley. -/
theorem noSlipPulleyAccelerationRelation_to_value_equation
    {tangentialAcceleration : MechLib.SI.Acceleration} {radius : MechLib.SI.Length}
    {alpha : MechLib.SI.AngularAcceleration}
    (h : NoSlipPulleyAccelerationRelation tangentialAcceleration radius alpha) :
    tangentialAcceleration.val = radius.val * alpha.val :=
  h

/-- Exported module metadata for this course-layer wrapper. -/
def moduleMetadata : ModuleMetadata :=
  {
    modulePath := "MechLib.Statics.ConstraintForce",
    topicId := "statics.constraint_force",
    status := .interface,
    trustLevel := .interface,
    conceptIds := ["concept.constraints"],
    lawSchemaIds := ["law.analytical.virtual_work_principle"],
    problemSchemaIds := ["problem.statics.planar_equilibrium"],
    exampleProblems := ["Solve normal force or cable tension", "Ideal rope and pulley constraint planning"],
    notes := ["Schema for support reactions, ideal constraints, ideal rope tension, and no-slip pulley kinematics."]
  }

#check ConstraintForce
#check IdealRopeSegment
#check IdealRopeUniformTension
#check idealRopeUniformTension_to_value_equation
#check IdealPulleySharedAcceleration
#check NoSlipPulleyVelocityRelation
#check moduleMetadata

end
end ConstraintForce
end Statics
end MechLib
