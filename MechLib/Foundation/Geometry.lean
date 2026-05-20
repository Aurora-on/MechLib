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
namespace Geometry

open MechLib.Spec
open MechLib.Units
open MechLib.SI

noncomputable section

/-! Course-layer module for `foundation.geometry`.

Spec topic id: `foundation.geometry`. -/
/-- Three-dimensional point represented by a length vector. -/
abbrev Point3 := MechLib.SI.VecLength 3

/-- Directed segment between two points. -/
structure DirectedSegment where
  tail : Point3
  head : Point3

/-- Distance residual represented at the value level. -/
def DistanceResidual (distance : MechLib.SI.Length) (value : ℝ) : Prop :=
  distance.val = value

/-- Exported module metadata for this course-layer wrapper. -/
def moduleMetadata : ModuleMetadata :=
  {
    modulePath := "MechLib.Foundation.Geometry",
    topicId := "foundation.geometry",
    status := .todo,
    trustLevel := .interface,
    conceptIds := [],
    lawSchemaIds := [],
    problemSchemaIds := [],
    exampleProblems := ["Encode distances and angles in a diagram"],
    notes := ["Minimal geometry schema for mechanics diagrams."]
  }

#check Point3
#check moduleMetadata

end
end Geometry
end Foundation
end MechLib
