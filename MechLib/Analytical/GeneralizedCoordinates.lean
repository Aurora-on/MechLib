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
namespace Analytical
namespace GeneralizedCoordinates

open MechLib.Spec
open MechLib.Units
open MechLib.SI

noncomputable section

/-! Course-layer module for `analytical.generalized_coordinates`.

Spec topic id: `analytical.generalized_coordinates`. -/
/-- Specification of a finite generalized-coordinate chart.

Each coordinate may carry its own physical dimension, which is needed for
mixed coordinates such as a translation plus an angle. -/
structure CoordSpec where
  dof : ℕ
  coordName : Fin dof → String
  coordDim : Fin dof → Dim

/-- Generalized coordinate vector with per-coordinate dimensions. -/
abbrev GCoord (spec : CoordSpec) : Type :=
  (i : Fin spec.dof) → Quantity (spec.coordDim i)

/-- Generalized velocity vector with per-coordinate dimensions divided by time. -/
abbrev GVel (spec : CoordSpec) : Type :=
  (i : Fin spec.dof) → Quantity (spec.coordDim i - MechLib.SI.timeDim)

/-- Generalized acceleration vector with per-coordinate dimensions divided by time squared. -/
abbrev GAccel (spec : CoordSpec) : Type :=
  (i : Fin spec.dof) → Quantity (spec.coordDim i - (2 : ℕ) • MechLib.SI.timeDim)

/-- Generalized force conjugate to coordinate `i`, with dimension energy divided by `qᵢ`. -/
abbrev GeneralizedForce (spec : CoordSpec) (i : Fin spec.dof) : Type :=
  Quantity (MechLib.SI.energyDim - spec.coordDim i)

/-- Vector of generalized forces. -/
abbrev GeneralizedForceVector (spec : CoordSpec) : Type :=
  (i : Fin spec.dof) → GeneralizedForce spec i

/-- Generalized momentum conjugate to coordinate `i`, with dimension energy divided by `qdotᵢ`. -/
abbrev GeneralizedMomentum (spec : CoordSpec) (i : Fin spec.dof) : Type :=
  Quantity (MechLib.SI.energyDim - (spec.coordDim i - MechLib.SI.timeDim))

/-- Vector of generalized momenta. -/
abbrev GeneralizedMomentumVector (spec : CoordSpec) : Type :=
  (i : Fin spec.dof) → GeneralizedMomentum spec i

/-- Zero generalized-coordinate vector for a given chart. -/
def zeroCoord (spec : CoordSpec) : GCoord spec :=
  fun _ => 0

/-- Zero generalized-velocity vector for a given chart. -/
def zeroVel (spec : CoordSpec) : GVel spec :=
  fun _ => 0

/-- A coordinate chart is named if each coordinate has a nonempty exported name. -/
def CoordSpecWellFormed (spec : CoordSpec) : Prop :=
  ∀ i, (spec.coordName i).length > 0

/-- Standard one-dimensional length coordinate. -/
def oneDimLengthSpec : CoordSpec :=
  {
    dof := 1,
    coordName := fun _ => "x",
    coordDim := fun _ => MechLib.SI.lengthDim
  }

/-- Standard one-dimensional angle coordinate. -/
def oneDimAngleSpec : CoordSpec :=
  {
    dof := 1,
    coordName := fun _ => "theta",
    coordDim := fun _ => (0 : Dim)
  }

/-- Finite set of generalized coordinates. -/
structure GeneralizedCoordinateSystem where
  dof : ℕ
  coordinateNames : Fin dof → String
  coordinates : ℝ → Fin dof → ℝ

/-- Compatibility view from the older scalar coordinate-system record to `CoordSpec`. -/
def GeneralizedCoordinateSystem.toCoordSpec (system : GeneralizedCoordinateSystem) : CoordSpec :=
  {
    dof := system.dof,
    coordName := system.coordinateNames,
    coordDim := fun _ => (0 : Dim)
  }

/-- A coordinate system is usable for retrieval/planning when every coordinate is named. -/
def GeneralizedCoordinateSystemWellFormed (system : GeneralizedCoordinateSystem) : Prop :=
  CoordSpecWellFormed system.toCoordSpec

/-- The compatibility well-formedness predicate unfolds to nonempty coordinate names. -/
theorem generalizedCoordinateSystemWellFormed_iff (system : GeneralizedCoordinateSystem) :
    GeneralizedCoordinateSystemWellFormed system ↔ ∀ i, (system.coordinateNames i).length > 0 := by
  rfl

example : CoordSpecWellFormed oneDimLengthSpec := by
  intro i
  fin_cases i
  decide

/-- Exported module metadata for this course-layer wrapper. -/
def moduleMetadata : ModuleMetadata :=
  {
    modulePath := "MechLib.Analytical.GeneralizedCoordinates",
    topicId := "analytical.generalized_coordinates",
    status := .interface,
    trustLevel := .interface,
    conceptIds := ["concept.generalized_coordinates"],
    lawSchemaIds := ["law.analytical.euler_lagrange_equation"],
    problemSchemaIds := ["problem.systems.pendulum_lagrangian"],
    exampleProblems := ["Choose independent generalized coordinates"],
    notes := ["Objects: CoordSpec, GCoord, GVel, GAccel, GeneralizedForce, GeneralizedMomentum."]
  }

#check CoordSpec
#check moduleMetadata

end
end GeneralizedCoordinates
end Analytical
end MechLib
