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
namespace NonInertialFrame

open MechLib.Spec
open MechLib.Units
open MechLib.SI

noncomputable section

/-! Course-layer module for `dynamics.non_inertial_frame`.

Spec topic id: `dynamics.non_inertial_frame`. -/
/-- Effective inertial force in a non-inertial frame. -/
structure InertialForceTerm where
  name : String
  force : MechLib.SI.VecForce 3

/-- Non-inertial force balance schema. -/
def NonInertialForceBalance (realForces inertialForces effectiveResult : MechLib.SI.VecForce 3) : Prop :=
  effectiveResult = realForces + inertialForces

/-- Exported module metadata for this course-layer wrapper. -/
def moduleMetadata : ModuleMetadata :=
  {
    modulePath := "MechLib.Dynamics.NonInertialFrame",
    topicId := "dynamics.non_inertial_frame",
    status := .schema,
    trustLevel := .interface,
    conceptIds := [],
    lawSchemaIds := [],
    problemSchemaIds := ["problem.kinematics.composite_point_motion"],
    exampleProblems := ["Rotating-frame effective force planning"],
    notes := ["Non-inertial dynamics schema."]
  }

#check InertialForceTerm
#check moduleMetadata

end
end NonInertialFrame
end Dynamics
end MechLib
