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
namespace Statics
namespace Equilibrium

open MechLib.Spec
open MechLib.Units
open MechLib.SI

noncomputable section

/-! Course-layer module for `statics.equilibrium`.

Spec topic id: `statics.equilibrium`. -/
/-- Static equilibrium residuals for force and moment balance. -/
structure EquilibriumResidual where
  forceResidual : MechLib.SI.VecForce 3
  momentResidual : MechLib.SI.VecTorque 3

/-- Static equilibrium holds when both residuals vanish. -/
def IsInEquilibrium (r : EquilibriumResidual) : Prop :=
  r.forceResidual = 0 ∧ r.momentResidual = 0

/-- Plane force-system equilibrium in course form. -/
def PlaneEquilibrium
    (resultant : MechLib.SI.VecForce 3) (moment : MechLib.SI.VecTorque 3) : Prop :=
  resultant = 0 ∧ moment = 0

/-- Spatial equilibrium uses the same resultant force and moment balance at the typed vector level. -/
def SpatialEquilibrium
    (resultant : MechLib.SI.VecForce 3) (moment : MechLib.SI.VecTorque 3) : Prop :=
  resultant = 0 ∧ moment = 0

/-- Planar equilibrium reduced to two force components and one out-of-plane moment. -/
def PlaneEquilibriumScalarComponents
    (Fx Fy : MechLib.SI.Force) (Mz : MechLib.SI.Torque) : Prop :=
  Fx.val = 0 ∧ Fy.val = 0 ∧ Mz.val = 0

/-- Static equilibrium is exactly zero force residual plus zero moment residual. -/
theorem isInEquilibrium_iff (r : EquilibriumResidual) :
    IsInEquilibrium r ↔ r.forceResidual = 0 ∧ r.momentResidual = 0 :=
  Iff.rfl

/-- Plane equilibrium is exactly zero resultant force and zero resultant moment. -/
theorem planeEquilibrium_iff
    (resultant : MechLib.SI.VecForce 3) (moment : MechLib.SI.VecTorque 3) :
    PlaneEquilibrium resultant moment ↔ resultant = 0 ∧ moment = 0 :=
  Iff.rfl

/-- Spatial equilibrium is exactly zero resultant force and zero resultant moment. -/
theorem spatialEquilibrium_iff
    (resultant : MechLib.SI.VecForce 3) (moment : MechLib.SI.VecTorque 3) :
    SpatialEquilibrium resultant moment ↔ resultant = 0 ∧ moment = 0 :=
  Iff.rfl

/-- Planar component equilibrium expands to zero x-force, zero y-force, and zero moment. -/
theorem planeEquilibriumScalarComponents_iff
    (Fx Fy : MechLib.SI.Force) (Mz : MechLib.SI.Torque) :
    PlaneEquilibriumScalarComponents Fx Fy Mz ↔ Fx.val = 0 ∧ Fy.val = 0 ∧ Mz.val = 0 :=
  Iff.rfl

/-- Exported module metadata for this course-layer wrapper. -/
def moduleMetadata : ModuleMetadata :=
  {
    modulePath := "MechLib.Statics.Equilibrium",
    topicId := "statics.equilibrium",
    status := .interface,
    trustLevel := .interface,
    conceptIds := ["concept.force_system", "concept.moment"],
    lawSchemaIds := ["law.statics.planar_force_system_equilibrium"],
    problemSchemaIds := ["problem.statics.planar_equilibrium"],
    exampleProblems := ["Solve planar support reactions"],
    notes := ["Typed API: PlaneEquilibrium, SpatialEquilibrium; static equilibrium residual schema."]
  }

#check EquilibriumResidual
#check PlaneEquilibrium
#check PlaneEquilibriumScalarComponents
#check planeEquilibriumScalarComponents_iff
#check moduleMetadata

end
end Equilibrium
end Statics
end MechLib
