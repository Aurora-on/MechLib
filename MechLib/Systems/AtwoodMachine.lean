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
namespace Systems
namespace AtwoodMachine

open MechLib.Spec
open MechLib.Units
open MechLib.SI
open _root_.MechLib.Analytical.GeneralizedCoordinates

noncomputable section

/-! Course-layer module for `systems.atwood_machine`.

Spec topic id: `systems.atwood_machine`. -/
/-- Atwood machine parameters. -/
structure AtwoodMachineParams where
  m1 : MechLib.SI.Mass
  m2 : MechLib.SI.Mass
  gravity : MechLib.SI.Acceleration

/-- Preferred short name for the public Atwood-machine parameter record. -/
abbrev Params := AtwoodMachineParams

/-- Reduced coordinate chart using one rope coordinate. -/
def reducedCoordSpec : CoordSpec :=
  {
    dof := 1,
    coordName := fun _ => "q",
    coordDim := fun _ => MechLib.SI.lengthDim
  }

/-- Rope-length constraint schema for an Atwood machine. -/
def AtwoodConstraint (x1 x2 : MechLib.Mechanics.Kinematics.ScalarTrajectory) (L : MechLib.SI.Length) : Prop :=
  ∀ t, x1 t + x2 t = L

/-- Reduced-coordinate rope constraint `x1 = q`, `x2 = L - q`. -/
def reducedConstraint
    (q x1 x2 : MechLib.Mechanics.Kinematics.ScalarTrajectory) (L : MechLib.SI.Length) : Prop :=
  ∀ t, x1 t = q t ∧ x2 t = L - q t

/-- Scalar kinetic energy `T = 1/2 (m1 + m2) qdot²`. -/
def kineticEnergy (params : Params) (qDot : ℝ) : ℝ :=
  (1 / 2 : ℝ) * (params.m1.val + params.m2.val) * qDot ^ 2

/-- Scalar potential energy for a signed reduced coordinate. -/
def potentialEnergy (params : Params) (q : ℝ) : ℝ :=
  (params.m1.val - params.m2.val) * params.gravity.val * q

/-- Scalar Lagrangian for the ideal Atwood machine. -/
def lagrangian (params : Params) (q qDot : ℝ) : ℝ :=
  kineticEnergy params qDot - potentialEnergy params q

/-- Reduced equation residual `(m1 + m2) qddot - (m2 - m1) g = 0`. -/
def equationResidual (params : Params) (qDDot : ℝ → ℝ) : Prop :=
  ∀ t,
    (params.m1.val + params.m2.val) * qDDot t
      - (params.m2.val - params.m1.val) * params.gravity.val = 0

/-- Acceleration formula schema for the ideal Atwood machine. -/
def accelerationFormula (params : Params) (a : ℝ) : Prop :=
  (params.m1.val + params.m2.val) ≠ 0
    ∧ a = (params.m2.val - params.m1.val) * params.gravity.val
      / (params.m1.val + params.m2.val)

example (params : Params) (q qDot : ℝ) :
    lagrangian params q qDot =
      (1 / 2 : ℝ) * (params.m1.val + params.m2.val) * qDot ^ 2
        - (params.m1.val - params.m2.val) * params.gravity.val * q := rfl

/-- Exported module metadata for this course-layer wrapper. -/
def moduleMetadata : ModuleMetadata :=
  {
    modulePath := "MechLib.Systems.AtwoodMachine",
    topicId := "systems.atwood_machine",
    status := .schema,
    trustLevel := .example,
    conceptIds := ["concept.constraints"],
    lawSchemaIds := ["law.dynamics.newton_second_law"],
    problemSchemaIds := ["problem.systems.atwood_constraint_modeling"],
    exampleProblems := ["Atwood machine rope constraint"],
    notes := ["schema: reduced coordinate, rope constraint, Lagrangian, acceleration formula."]
  }

#check AtwoodMachineParams
#check moduleMetadata

end
end AtwoodMachine
end Systems
end MechLib
