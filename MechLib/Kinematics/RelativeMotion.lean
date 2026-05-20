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
namespace RelativeMotion

open MechLib.Spec
open MechLib.Units
open MechLib.SI

noncomputable section

/-! Course-layer module for `kinematics.relative_motion`.

Spec topic id: `kinematics.relative_motion`. -/
/-- Course-layer alias for relative scalar trajectory. -/
abbrev relativeTrajectory := MechLib.Mechanics.Kinematics.relativeTrajectory

/-- Course-layer alias for scalar relative velocity. -/
abbrev relativeVelocity := MechLib.Mechanics.Kinematics.relativeVelocity

/-- Course-layer alias for scalar relative acceleration. -/
abbrev relativeAcceleration := MechLib.Mechanics.Kinematics.relativeAcceleration

/-- Relative-motion decomposition schema for transport planning. -/
def RelativeMotionSchema (absolute relative transport : MechLib.Mechanics.Kinematics.VecVelocityField 3) : Prop :=
  ∀ t, absolute t = relative t + transport t

/-- One-dimensional relative displacement relation `dx_rel = dx_B - dx_A`. -/
def RelativeDisplacementValueRelation
    (dxRel dxB dxA : MechLib.SI.Length) : Prop :=
  dxRel.val = dxB.val - dxA.val

/-- One-dimensional relative acceleration relation `a_rel = a_B - a_A`. -/
def RelativeAccelerationValueRelation
    (aRel aB aA : MechLib.SI.Acceleration) : Prop :=
  aRel.val = aB.val - aA.val

/-- Course-layer wrapper for the verified relative-velocity chain rule. -/
theorem relative_velocity_trans_course_form
    (vA vB vC : MechLib.Mechanics.Kinematics.ScalarVelocityField) :
    relativeVelocity vC vA =
      fun t => relativeVelocity vC vB t + relativeVelocity vB vA t := by
  simpa [relativeVelocity] using
    MechLib.Mechanics.Kinematics.relative_velocity_trans vA vB vC

/-- Extract the scalar equation from the relative displacement relation. -/
theorem relativeDisplacementValueRelation_to_value_equation
    {dxRel dxB dxA : MechLib.SI.Length}
    (h : RelativeDisplacementValueRelation dxRel dxB dxA) :
    dxRel.val = dxB.val - dxA.val :=
  h

/-- Extract the scalar equation from the relative acceleration relation. -/
theorem relativeAccelerationValueRelation_to_value_equation
    {aRel aB aA : MechLib.SI.Acceleration}
    (h : RelativeAccelerationValueRelation aRel aB aA) :
    aRel.val = aB.val - aA.val :=
  h

/-- Exported module metadata for this course-layer wrapper. -/
def moduleMetadata : ModuleMetadata :=
  {
    modulePath := "MechLib.Kinematics.RelativeMotion",
    topicId := "kinematics.relative_motion",
    status := .verified,
    trustLevel := .derived,
    conceptIds := [],
    lawSchemaIds := [],
    problemSchemaIds := ["problem.kinematics.composite_point_motion"],
    exampleProblems := ["Three-body relative velocity chain", "Two-body relative displacement relation"],
    notes := ["Typed API: relativeTrajectory, relativeVelocity, relativeAcceleration, RelativeDisplacementValueRelation; wrapper for relative-motion verified declarations."]
  }

#check relativeTrajectory
#check relativeVelocity
#check RelativeDisplacementValueRelation
#check relativeDisplacementValueRelation_to_value_equation
#check moduleMetadata

end
end RelativeMotion
end Kinematics
end MechLib
