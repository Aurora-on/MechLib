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
namespace Quantity

open MechLib.Spec
open MechLib.Units
open MechLib.SI

noncomputable section

/-! Course-layer module for `foundation.quantity`.

Spec topic id: `foundation.quantity`. -/
/-- Course-layer alias for dimensioned scalar quantities. -/
abbrev ScalarQuantity := MechLib.Units.Quantity

/-- A scalar quantity together with a human-facing role in a model. -/
structure NamedQuantity where
  role : String
  dim : MechLib.Units.Dim
  value : ScalarQuantity dim

/-- Scalar residual in a fixed physical dimension. -/
def QuantityResidual {d : MechLib.Units.Dim} (lhs rhs : ScalarQuantity d) : Prop :=
  lhs = rhs

/-- Exported module metadata for this course-layer wrapper. -/
def moduleMetadata : ModuleMetadata :=
  {
    modulePath := "MechLib.Foundation.Quantity",
    topicId := "foundation.quantity",
    status := .verified,
    trustLevel := .core,
    conceptIds := [],
    lawSchemaIds := [],
    problemSchemaIds := [],
    exampleProblems := ["Convert scalar quantities between units"],
    notes := ["Wrapper for MechLib.Units.Quantity."]
  }

#check ScalarQuantity
#check moduleMetadata

end
end Quantity
end Foundation
end MechLib
