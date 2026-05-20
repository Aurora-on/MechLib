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
namespace PlanarMotion

open MechLib.Spec
open MechLib.Units
open MechLib.SI

noncomputable section

/-! Course-layer module for `kinematics.planar_motion`.

Spec topic id: `kinematics.planar_motion`. -/
/-- Planar pose with two translations and one rotation angle. -/
structure PlanarPose where
  x : MechLib.SI.Length
  y : MechLib.SI.Length
  theta : MechLib.SI.PhysAngle

/-- Planar velocity-state schema. -/
structure PlanarVelocityState where
  vx : MechLib.SI.Speed
  vy : MechLib.SI.Speed
  omega : MechLib.SI.AngularVelocity

/-- Planar velocity residual compares two planar velocity states componentwise. -/
def PlanarVelocityResidual (actual expected : PlanarVelocityState) : Prop :=
  actual.vx = expected.vx ∧ actual.vy = expected.vy ∧ actual.omega = expected.omega

/-- Exported module metadata for this course-layer wrapper. -/
def moduleMetadata : ModuleMetadata :=
  {
    modulePath := "MechLib.Kinematics.PlanarMotion",
    topicId := "kinematics.planar_motion",
    status := .interface,
    trustLevel := .interface,
    conceptIds := [],
    lawSchemaIds := [],
    problemSchemaIds := ["problem.kinematics.composite_point_motion"],
    exampleProblems := ["Planar rigid-body velocity center planning"],
    notes := ["Planar motion schema."]
  }

#check PlanarPose
#check moduleMetadata

end
end PlanarMotion
end Kinematics
end MechLib
