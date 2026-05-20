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
namespace Momentum

open MechLib.Spec
open MechLib.Units
open MechLib.SI

noncomputable section

/-! Course-layer module for `dynamics.momentum`.

Spec topic id: `dynamics.momentum`. -/
/-- Scalar linear momentum relation. -/
def MomentumLaw (m : MechLib.SI.Mass) (v : MechLib.SI.Speed) (p : MechLib.SI.Momentum) : Prop :=
  p = MechLib.Mechanics.Dynamics.momentum m v

/-- Momentum-law schema expands to the existing scalar momentum definition. -/
theorem momentumLaw_course_form
    (m : MechLib.SI.Mass) (v : MechLib.SI.Speed) (p : MechLib.SI.Momentum) :
    MomentumLaw m v p = (p = MechLib.Mechanics.Dynamics.momentum m v) := rfl

/-- Exported module metadata for this course-layer wrapper. -/
def moduleMetadata : ModuleMetadata :=
  {
    modulePath := "MechLib.Dynamics.Momentum",
    topicId := "dynamics.momentum",
    status := .verified,
    trustLevel := .core,
    conceptIds := [],
    lawSchemaIds := [],
    problemSchemaIds := ["problem.dynamics.particle_dynamics"],
    exampleProblems := ["Momentum balance for a particle"],
    notes := ["Wrapper for Mechanics.Dynamics.momentum."]
  }

#check MomentumLaw
#check moduleMetadata

end
end Momentum
end Dynamics
end MechLib
