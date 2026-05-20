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
namespace Foundation
namespace ReferenceFrame

open MechLib.Spec
open MechLib.Units
open MechLib.SI

noncomputable section

/-! Course-layer module for `foundation.reference_frame`.

Spec topic id: `foundation.reference_frame`. -/
/-- Reference frame schema with origin trajectory and inertial flag. -/
structure ReferenceFrame where
  name : String
  isInertial : Bool
  origin : MechLib.Mechanics.Kinematics.VecTrajectory 3

/-- Relation schema between two frames. -/
structure FrameRelation where
  fromFrame : ReferenceFrame
  toFrame : ReferenceFrame
  relativeOrigin : MechLib.Mechanics.Kinematics.VecTrajectory 3
  angularVelocity : ℝ → MechLib.Units.VecQuantity (0 : MechLib.Units.Dim) 3

/-- Non-inertial correction residual placeholder. -/
def NonInertialResidual (absolute relative correction : MechLib.Mechanics.Kinematics.VecAccelerationField 3) : Prop :=
  ∀ t, absolute t = relative t + correction t

/-- Exported module metadata for this course-layer wrapper. -/
def moduleMetadata : ModuleMetadata :=
  {
    modulePath := "MechLib.Foundation.ReferenceFrame",
    topicId := "foundation.reference_frame",
    status := .interface,
    trustLevel := .interface,
    conceptIds := [],
    lawSchemaIds := [],
    problemSchemaIds := ["problem.kinematics.composite_point_motion"],
    exampleProblems := ["Rotating-frame transport planning"],
    notes := ["Interface for inertial and moving frames."]
  }

#check ReferenceFrame
#check moduleMetadata

end
end ReferenceFrame
end Foundation
end MechLib
