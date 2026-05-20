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
namespace Moment

open MechLib.Spec
open MechLib.Units
open MechLib.SI

noncomputable section

/-! Course-layer module for `statics.moment`.

Spec topic id: `statics.moment`. -/
/-- Course-layer alias for torque/moment vectors. -/
abbrev Moment := MechLib.SI.VecTorque 3

/-- Moment law schema reusing the verified torque definition API. -/
def MomentLaw (r : MechLib.SI.VecLength 3) (F : MechLib.SI.VecForce 3) (M : Moment) : Prop :=
  M = MechLib.Mechanics.Rotation.torque r F

/-- Moment-law schema expands to the existing verified torque definition API. -/
theorem momentLaw_eq (r : MechLib.SI.VecLength 3) (F : MechLib.SI.VecForce 3) (M : Moment) :
    MomentLaw r F M = (M = MechLib.Mechanics.Rotation.torque r F) := rfl

/-- Exported module metadata for this course-layer wrapper. -/
def moduleMetadata : ModuleMetadata :=
  {
    modulePath := "MechLib.Statics.Moment",
    topicId := "statics.moment",
    status := .verified,
    trustLevel := .core,
    conceptIds := ["concept.moment"],
    lawSchemaIds := ["law.dynamics.angular_momentum_conservation"],
    problemSchemaIds := ["problem.statics.planar_equilibrium"],
    exampleProblems := ["Compute a moment about a point"],
    notes := ["Wrapper for Mechanics.Rotation.torque."]
  }

#check Moment
#check moduleMetadata

end
end Moment
end Statics
end MechLib
