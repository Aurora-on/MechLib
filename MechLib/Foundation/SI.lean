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
namespace SI

open MechLib.Spec
open MechLib.Units
open MechLib.SI

noncomputable section

/-! Course-layer module for `foundation.si_units`.

Spec topic id: `foundation.si_units`. -/
/-- Course-layer alias for SI length. -/
abbrev Length := MechLib.SI.Length

/-- Course-layer alias for SI force. -/
abbrev Force := MechLib.SI.Force

/-- A selected SI unit for a physical role. -/
structure SIUnitChoice where
  role : String
  dim : MechLib.Units.Dim
  unit : MechLib.Units.Quantity dim

/-- A unit choice is usable for reading numeric values when its unit is nonzero. -/
def SIUnitUsable (choice : SIUnitChoice) : Prop :=
  choice.unit.val ≠ 0

/-- Exported module metadata for this course-layer wrapper. -/
def moduleMetadata : ModuleMetadata :=
  {
    modulePath := "MechLib.Foundation.SI",
    topicId := "foundation.si_units",
    status := .verified,
    trustLevel := .core,
    conceptIds := [],
    lawSchemaIds := [],
    problemSchemaIds := [],
    exampleProblems := ["Check SI unit consistency"],
    notes := ["Wrapper for MechLib.SI."]
  }

#check Length
#check moduleMetadata

end
end SI
end Foundation
end MechLib
