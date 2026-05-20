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
namespace ParticleDynamics

open MechLib.Spec
open MechLib.Units
open MechLib.SI

noncomputable section

/-! Course-layer module for `dynamics.particle_dynamics`.

Spec topic id: `dynamics.particle_dynamics`. -/
/-- Particle dynamics residual for force balance. -/
def ParticleDynamicsResidual (applied massTimesAcceleration : MechLib.SI.VecForce 3) : Prop :=
  applied = massTimesAcceleration

/-- Particle model with mass and trajectory. -/
structure ParticleModel where
  mass : MechLib.SI.Mass
  position : MechLib.Mechanics.Kinematics.VecTrajectory 3

/-- Exported module metadata for this course-layer wrapper. -/
def moduleMetadata : ModuleMetadata :=
  {
    modulePath := "MechLib.Dynamics.ParticleDynamics",
    topicId := "dynamics.particle_dynamics",
    status := .schema,
    trustLevel := .interface,
    conceptIds := ["concept.force_system"],
    lawSchemaIds := ["law.dynamics.newton_second_law"],
    problemSchemaIds := ["problem.dynamics.particle_dynamics"],
    exampleProblems := ["Particle free-body equation solving"],
    notes := ["Particle dynamics residual schema."]
  }

#check ParticleDynamicsResidual
#check moduleMetadata

end
end ParticleDynamics
end Dynamics
end MechLib
