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
namespace Impulse

open MechLib.Spec
open MechLib.Units
open MechLib.SI

noncomputable section

/-! Course-layer module for `dynamics.impulse`.

Spec topic id: `dynamics.impulse`. -/
/-- Impulse-momentum schema over a time interval. -/
def ImpulseMomentumLaw (J deltaP : MechLib.SI.Momentum) : Prop :=
  J = deltaP

/-- Impulse-momentum schema expands to equality of impulse and momentum change. -/
theorem impulseMomentumLaw_course_form (J deltaP : MechLib.SI.Momentum) :
    ImpulseMomentumLaw J deltaP = (J = deltaP) := rfl

/-- Existing verified impulse definition is available through the course layer. -/
theorem impulse_def_verified (F : MechLib.SI.Force) (dt : MechLib.SI.Time) :
    MechLib.Mechanics.MomentumImpulse.impulse F dt =
      MechLib.Units.Quantity.cast (F * dt) MechLib.SI.force_time_eq_momentum := by
  simpa using MechLib.Mechanics.MomentumImpulse.impulse_def F dt

/-- Exported module metadata for this course-layer wrapper. -/
def moduleMetadata : ModuleMetadata :=
  {
    modulePath := "MechLib.Dynamics.Impulse",
    topicId := "dynamics.impulse",
    status := .verified,
    trustLevel := .core,
    conceptIds := [],
    lawSchemaIds := [],
    problemSchemaIds := ["problem.dynamics.particle_dynamics"],
    exampleProblems := ["Impulse-momentum calculation"],
    notes := ["Wrapper for Mechanics.MomentumImpulse."]
  }

#check ImpulseMomentumLaw
#check moduleMetadata

end
end Impulse
end Dynamics
end MechLib
