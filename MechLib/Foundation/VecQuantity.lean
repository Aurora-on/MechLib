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
namespace VecQuantity

open MechLib.Spec
open MechLib.Units
open MechLib.SI

noncomputable section

/-! Course-layer module for `foundation.vector_quantity`.

Spec topic id: `foundation.vector_quantity`. -/
/-- Course-layer alias for dimensioned vector quantities. -/
abbrev VectorQuantity := MechLib.Units.VecQuantity

/-- Vector quantity tagged by its modeling role. -/
structure NamedVectorQuantity where
  role : String
  dim : MechLib.Units.Dim
  components : VectorQuantity dim 3

/-- Vector residual in a fixed physical dimension. -/
def VectorResidual {d : MechLib.Units.Dim} {n : ℕ}
    (lhs rhs : VectorQuantity d n) : Prop :=
  lhs = rhs

/-- Exported module metadata for this course-layer wrapper. -/
def moduleMetadata : ModuleMetadata :=
  {
    modulePath := "MechLib.Foundation.VecQuantity",
    topicId := "foundation.vector_quantity",
    status := .verified,
    trustLevel := .core,
    conceptIds := [],
    lawSchemaIds := [],
    problemSchemaIds := [],
    exampleProblems := ["Represent force and displacement vectors"],
    notes := ["Wrapper for MechLib.Units.VecQuantity."]
  }

#check VectorQuantity
#check moduleMetadata

end
end VecQuantity
end Foundation
end MechLib
