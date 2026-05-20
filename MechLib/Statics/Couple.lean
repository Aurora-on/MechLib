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
namespace Couple

open MechLib.Spec
open MechLib.Units
open MechLib.SI

noncomputable section

/-! Course-layer module for `statics.couple`.

Spec topic id: `statics.couple`. -/
/-- A force couple represented by two equal-and-opposite force applications. -/
structure Couple where
  firstPoint : MechLib.SI.VecLength 3
  secondPoint : MechLib.SI.VecLength 3
  force : MechLib.SI.VecForce 3

/-- Couple equivalence residual for origin-independent moment modeling. -/
def CoupleMomentSchema (couple : Couple) (moment : MechLib.SI.VecTorque 3) : Prop :=
  moment = MechLib.Mechanics.Rotation.torque (couple.secondPoint - couple.firstPoint) couple.force

/-- Couple-moment schema unfolds to the torque of the separation vector and one force. -/
theorem coupleMomentSchema_eq (couple : Couple) (moment : MechLib.SI.VecTorque 3) :
    CoupleMomentSchema couple moment =
      (moment = MechLib.Mechanics.Rotation.torque (couple.secondPoint - couple.firstPoint) couple.force) := rfl

/-- Exported module metadata for this course-layer wrapper. -/
def moduleMetadata : ModuleMetadata :=
  {
    modulePath := "MechLib.Statics.Couple",
    topicId := "statics.couple",
    status := .interface,
    trustLevel := .interface,
    conceptIds := ["concept.moment"],
    lawSchemaIds := ["law.statics.planar_force_system_equilibrium"],
    problemSchemaIds := ["problem.statics.planar_equilibrium"],
    exampleProblems := ["Replace equal and opposite forces by a couple"],
    notes := ["Schema for force couples."]
  }

#check Couple
#check moduleMetadata

end
end Couple
end Statics
end MechLib
