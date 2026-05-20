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
namespace CoordinateSystem

open MechLib.Spec
open MechLib.Units
open MechLib.SI

noncomputable section

/-! Course-layer module for `foundation.coordinate_system`.

Spec topic id: `foundation.coordinate_system`. -/
/-- Coordinate chart from coordinates into physical position. -/
structure CoordinateSystem where
  name : String
  dimension : ℕ
  position : (Fin dimension → ℝ) → MechLib.SI.VecLength 3

/-- Coordinate description of a motion. -/
structure CoordinateMotion (chart : CoordinateSystem) where
  coordinates : ℝ → Fin chart.dimension → ℝ

/-- A coordinate motion realizes a vector trajectory through its chart. -/
def CoordinateRealization
    (chart : CoordinateSystem) (motion : CoordinateMotion chart)
    (trajectory : MechLib.Mechanics.Kinematics.VecTrajectory 3) : Prop :=
  ∀ t, trajectory t = chart.position (motion.coordinates t)

/-- Exported module metadata for this course-layer wrapper. -/
def moduleMetadata : ModuleMetadata :=
  {
    modulePath := "MechLib.Foundation.CoordinateSystem",
    topicId := "foundation.coordinate_system",
    status := .interface,
    trustLevel := .interface,
    conceptIds := ["concept.generalized_coordinates"],
    lawSchemaIds := [],
    problemSchemaIds := ["problem.systems.pendulum_lagrangian"],
    exampleProblems := ["Choose Cartesian, polar, or generalized coordinates"],
    notes := ["Interface for coordinate charts."]
  }

#check CoordinateSystem
#check moduleMetadata

end
end CoordinateSystem
end Foundation
end MechLib
