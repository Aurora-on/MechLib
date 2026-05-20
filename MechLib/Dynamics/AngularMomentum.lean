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
namespace Dynamics
namespace AngularMomentum

open MechLib.Spec
open MechLib.Units
open MechLib.SI

noncomputable section

/-! Course-layer module for `dynamics.angular_momentum`.

Spec topic id: `dynamics.angular_momentum`. -/
/-- Angular momentum relation using the existing rotation API. -/
def AngularMomentumLaw (r : MechLib.SI.VecLength 3) (p : MechLib.SI.VecMomentum 3) (L : MechLib.SI.VecAngularMomentum 3) : Prop :=
  L = MechLib.Mechanics.Rotation.angularMomentum r p

/-- Angular-momentum schema expands to the existing rotation API. -/
theorem angularMomentumLaw_course_form
    (r : MechLib.SI.VecLength 3) (p : MechLib.SI.VecMomentum 3) (L : MechLib.SI.VecAngularMomentum 3) :
    AngularMomentumLaw r p L = (L = MechLib.Mechanics.Rotation.angularMomentum r p) := rfl

/-- Exported module metadata for this course-layer wrapper. -/
def moduleMetadata : ModuleMetadata :=
  {
    modulePath := "MechLib.Dynamics.AngularMomentum",
    topicId := "dynamics.angular_momentum",
    status := .schema,
    trustLevel := .interface,
    conceptIds := ["concept.moment"],
    lawSchemaIds := ["law.dynamics.angular_momentum_conservation"],
    problemSchemaIds := ["problem.systems.central_force_angular_momentum"],
    exampleProblems := ["Central-force angular momentum planning"],
    notes := ["Wrapper for angular momentum interfaces."]
  }

#check AngularMomentumLaw
#check moduleMetadata

end
end AngularMomentum
end Dynamics
end MechLib
