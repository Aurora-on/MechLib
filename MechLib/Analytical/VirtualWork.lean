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
import MechLib.Analytical.GeneralizedCoordinates

set_option linter.dupNamespace false
set_option linter.unusedVariables false

namespace MechLib
namespace Analytical
namespace VirtualWork

open MechLib.Spec
open MechLib.Units
open MechLib.SI
open _root_.MechLib.Analytical.GeneralizedCoordinates
open BigOperators

noncomputable section

/-! Course-layer module for `analytical.virtual_work`.

Spec topic id: `analytical.virtual_work`. -/
/-- Virtual displacement in a generalized-coordinate chart. -/
structure VirtualDisplacement (spec : CoordSpec) where
  delta : GCoord spec
  admissible : Prop

/-- Generalized virtual work `δW = Σᵢ Qᵢ δqᵢ`, represented as an SI energy. -/
def VirtualWorkValue {spec : CoordSpec}
    (Q : GeneralizedForceVector spec) (dq : VirtualDisplacement spec) : MechLib.SI.Energy :=
  ⟨∑ i, (Q i).val * (dq.delta i).val⟩

/-- Virtual-work residual comparing the computed generalized virtual work with an expected energy. -/
def VirtualWorkResidual {spec : CoordSpec}
    (Q : GeneralizedForceVector spec) (dq : VirtualDisplacement spec)
    (work : MechLib.SI.Energy) : Prop :=
  work = VirtualWorkValue Q dq

/-- Ideal constraint-force schema: admissible virtual displacements do no work. -/
def IdealConstraintVirtualWork {spec : CoordSpec}
    (constraintForce : GeneralizedForceVector spec) (dq : VirtualDisplacement spec) : Prop :=
  dq.admissible → VirtualWorkValue constraintForce dq = 0

theorem virtualWorkResidual_eq {spec : CoordSpec}
    (Q : GeneralizedForceVector spec) (dq : VirtualDisplacement spec)
    (work : MechLib.SI.Energy) :
    VirtualWorkResidual Q dq work = (work = VirtualWorkValue Q dq) := rfl

/-- Exported module metadata for this course-layer wrapper. -/
def moduleMetadata : ModuleMetadata :=
  {
    modulePath := "MechLib.Analytical.VirtualWork",
    topicId := "analytical.virtual_work",
    status := .interface,
    trustLevel := .interface,
    conceptIds := ["concept.virtual_displacement"],
    lawSchemaIds := ["law.analytical.virtual_work_principle"],
    problemSchemaIds := ["problem.statics.planar_equilibrium"],
    exampleProblems := ["Eliminate ideal constraint forces"],
    notes := ["Objects: VirtualDisplacement, VirtualWorkValue, VirtualWorkResidual, IdealConstraintVirtualWork."]
  }

#check VirtualDisplacement
#check moduleMetadata

end
end VirtualWork
end Analytical
end MechLib
