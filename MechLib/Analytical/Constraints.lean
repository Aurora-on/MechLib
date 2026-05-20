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
namespace Constraints

open MechLib.Spec
open MechLib.Units
open MechLib.SI
open _root_.MechLib.Analytical.GeneralizedCoordinates

noncomputable section

/-! Course-layer module for `analytical.constraints`.

Spec topic id: `analytical.constraints`. -/
/-- Holonomic constraint residual `C(q,t)=0`. -/
structure HolonomicConstraint (spec : CoordSpec) where
  name : String
  residual : GCoord spec → ℝ → ℝ

/-- Constraint satisfaction schema. -/
def HolonomicConstraintSatisfied {spec : CoordSpec}
    (C : HolonomicConstraint spec) (q : ℝ → GCoord spec) : Prop :=
  ∀ t, C.residual (q t) t = 0

/-- Compatibility name for holonomic constraint satisfaction. -/
abbrev ConstraintSatisfied {spec : CoordSpec} :=
  @HolonomicConstraintSatisfied spec

/-- Nonholonomic constraint schema in Pfaff-style scalar residual form. -/
structure NonHolonomicConstraint (spec : CoordSpec) where
  name : String
  residual : GCoord spec → GVel spec → ℝ → ℝ

/-- Nonholonomic constraint satisfaction schema. -/
def NonHolonomicConstraintSatisfied {spec : CoordSpec}
    (C : NonHolonomicConstraint spec) (q : ℝ → GCoord spec) (qdot : ℝ → GVel spec) : Prop :=
  ∀ t, C.residual (q t) (qdot t) t = 0

/-- Fixed-coordinate holonomic constraint `qᵢ = value`. -/
def fixedCoordinateConstraint (spec : CoordSpec) (i : Fin spec.dof)
    (value : Quantity (spec.coordDim i)) : HolonomicConstraint spec :=
  {
    name := "fixed coordinate",
    residual := fun q _ => (q i).val - value.val
  }

theorem fixedCoordinateConstraint_satisfied_iff
    (spec : CoordSpec) (i : Fin spec.dof) (value : Quantity (spec.coordDim i))
    (q : ℝ → GCoord spec) :
    HolonomicConstraintSatisfied (fixedCoordinateConstraint spec i value) q
      ↔ ∀ t, (q t i).val = value.val := by
  constructor
  · intro h t
    have hzero := h t
    dsimp [fixedCoordinateConstraint] at hzero
    linarith
  · intro h t
    dsimp [fixedCoordinateConstraint]
    simp [h t]

/-- 约束乘子法接口（1D）：`EL = λ ∂C/∂q`。 -/
def lagrangeMultiplierEquation1D
    (EL : ℝ → MechLib.SI.Force)
    (lam : ℝ → MechLib.SI.Dimensionless)
    (dCdq : ℝ → MechLib.SI.Force) : Prop :=
  ∀ t, EL t = (lam t).val • dCdq t

theorem lagrangeMultiplierEquation1D_eq
    (EL : ℝ → MechLib.SI.Force)
    (lam : ℝ → MechLib.SI.Dimensionless)
    (dCdq : ℝ → MechLib.SI.Force) :
    lagrangeMultiplierEquation1D EL lam dCdq =
      (∀ t, EL t = (lam t).val • dCdq t) := rfl

/-- Exported module metadata for this course-layer wrapper. -/
def moduleMetadata : ModuleMetadata :=
  {
    modulePath := "MechLib.Analytical.Constraints",
    topicId := "analytical.constraints",
    status := .schema,
    trustLevel := .interface,
    conceptIds := ["concept.constraints"],
    lawSchemaIds := ["law.analytical.virtual_work_principle"],
    problemSchemaIds := ["problem.systems.atwood_constraint_modeling"],
    exampleProblems := ["Holonomic rope-length constraint"],
    notes := ["Objects: HolonomicConstraint, NonHolonomicConstraint, ConstraintSatisfied."]
  }

#check HolonomicConstraint
#check moduleMetadata

end
end Constraints
end Analytical
end MechLib
