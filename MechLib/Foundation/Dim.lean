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
namespace Dim

open MechLib.Spec
open MechLib.Units
open MechLib.SI

noncomputable section

/-! Course-layer module for `foundation.dimensions`.

Spec topic id: `foundation.dimensions`. -/
/-- Course-layer alias for the dimension algebra. -/
abbrev Dimension := MechLib.Units.Dim

/-- Dimension equality target used by modeling and unit-consistency checks. -/
def DimensionBridge (d1 d2 : Dimension) : Prop := d1 = d2

/-- Dimension bridge is definitionally dimension equality. -/
theorem dimensionBridge_eq (d1 d2 : Dimension) :
    DimensionBridge d1 d2 = (d1 = d2) := rfl

/-- Exported module metadata for this course-layer wrapper. -/
def moduleMetadata : ModuleMetadata :=
  {
    modulePath := "MechLib.Foundation.Dim",
    topicId := "foundation.dimensions",
    status := .verified,
    trustLevel := .core,
    conceptIds := [],
    lawSchemaIds := [],
    problemSchemaIds := [],
    exampleProblems := ["Check a derived quantity dimension"],
    notes := ["Wrapper for MechLib.Units.Dim."]
  }

#check Dimension
#check moduleMetadata

end
end Dim
end Foundation
end MechLib
