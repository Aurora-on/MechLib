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
import MechLib.Analytical.Constraints

set_option linter.dupNamespace false
set_option linter.unusedVariables false

namespace MechLib
namespace Analytical
namespace LagrangeEquation

open MechLib.Spec
open MechLib.Units
open MechLib.SI
open _root_.MechLib.Analytical.GeneralizedCoordinates

noncomputable section

/-! Course-layer module for `analytical.lagrange_equation`.

Spec topic id: `analytical.lagrange_equation`. -/
/-- Lagrangian function for a generalized-coordinate chart. -/
abbrev Lagrangian (spec : CoordSpec) : Type :=
  GCoord spec → GVel spec → ℝ → MechLib.SI.Energy

/-- A generalized Lagrangian system with derivative providers as schema data.

The derivative providers make the API useful for modeling and retrieval without
claiming a fully verified variational derivation for arbitrary `n`. -/
structure LagrangianSystem where
  coordSpec : CoordSpec
  lagrangian : Lagrangian coordSpec
  dLdq : GCoord coordSpec → GVel coordSpec → ℝ → GeneralizedForceVector coordSpec
  dLdqDot : GCoord coordSpec → GVel coordSpec → ℝ → GeneralizedMomentumVector coordSpec
  timeDerivDldqDot : GCoord coordSpec → GVel coordSpec → ℝ → GeneralizedForceVector coordSpec

/-- Euler-Lagrange residual with optional nonconservative generalized forces. -/
def EulerLagrangeResidual
    (system : LagrangianSystem)
    (q : ℝ → GCoord system.coordSpec)
    (qdot : ℝ → GVel system.coordSpec)
    (Q : ℝ → GeneralizedForceVector system.coordSpec) : Prop :=
  ∀ t i,
    system.timeDerivDldqDot (q t) (qdot t) t i
      - system.dLdq (q t) (qdot t) t i = Q t i

/-- Homogeneous Euler-Lagrange residual for conservative generalized systems. -/
def EulerLagrangeResidualFree
    (system : LagrangianSystem)
    (q : ℝ → GCoord system.coordSpec)
    (qdot : ℝ → GVel system.coordSpec) : Prop :=
  EulerLagrangeResidual system q qdot (fun _ _ => 0)

/-- Generalized momentum read from a Lagrangian system's derivative provider. -/
def GeneralizedMomentumOf
    (system : LagrangianSystem)
    (q : GCoord system.coordSpec) (qdot : GVel system.coordSpec) (t : ℝ)
    (i : Fin system.coordSpec.dof) : GeneralizedMomentum system.coordSpec i :=
  system.dLdqDot q qdot t i

/-- 一维拉格朗日量：`L = T - V`。 -/
def lagrangian1D
    (m : MechLib.SI.Mass) (V : MechLib.SI.Length → MechLib.SI.Energy)
    (x : MechLib.SI.Length) (v : MechLib.SI.Speed) : MechLib.SI.Energy :=
  MechLib.Mechanics.WorkEnergy.kineticEnergy1D m v - V x

/-- 一维欧拉-拉格朗日残量（势函数导数以 `dVdx` 给出）。 -/
def eulerLagrangeResidual1D
    (m : MechLib.SI.Mass) (dVdx : MechLib.SI.Length → MechLib.SI.Force)
    (x : MechLib.Mechanics.Kinematics.ScalarTrajectory)
    (a : MechLib.Mechanics.Kinematics.ScalarAccelerationField) :
    ℝ → MechLib.SI.Force := fun t => m * a t + dVdx (x t)

/-- 一维欧拉-拉格朗日方程 `d/dt(∂L/∂v) - ∂L/∂x = 0` 的实现接口。 -/
def SatisfiesEulerLagrange1D
    (m : MechLib.SI.Mass) (dVdx : MechLib.SI.Length → MechLib.SI.Force)
    (x : MechLib.Mechanics.Kinematics.ScalarTrajectory)
    (a : MechLib.Mechanics.Kinematics.ScalarAccelerationField) : Prop :=
  ∀ t, eulerLagrangeResidual1D m dVdx x a t = 0

/-- 一维牛顿形式 `m a = -dV/dx`。 -/
def SatisfiesNewtonForm1D
    (m : MechLib.SI.Mass) (dVdx : MechLib.SI.Length → MechLib.SI.Force)
    (x : MechLib.Mechanics.Kinematics.ScalarTrajectory)
    (a : MechLib.Mechanics.Kinematics.ScalarAccelerationField) : Prop :=
  ∀ t, MechLib.Mechanics.Dynamics.secondLaw m (a t) = -dVdx (x t)

/-- Euler-Lagrange schema re-exported through the course-layer namespace. -/
def LagrangeEquationSchema
    (m : MechLib.SI.Mass) (dVdx : MechLib.SI.Length → MechLib.SI.Force)
    (x : MechLib.Mechanics.Kinematics.ScalarTrajectory)
    (a : MechLib.Mechanics.Kinematics.ScalarAccelerationField) : Prop :=
  SatisfiesEulerLagrange1D m dVdx x a

/-- 一维拉格朗日量展开式。 -/
theorem lagrangian1D_eq
    (m : MechLib.SI.Mass) (V : MechLib.SI.Length → MechLib.SI.Energy)
    (x : MechLib.SI.Length) (v : MechLib.SI.Speed) :
    lagrangian1D m V x v = MechLib.Mechanics.WorkEnergy.kineticEnergy1D m v - V x := rfl

/-- 一维保守系统中，欧拉-拉格朗日形式与牛顿形式等价。 -/
theorem eulerLagrange_iff_newton
    (m : MechLib.SI.Mass) (dVdx : MechLib.SI.Length → MechLib.SI.Force)
    (x : MechLib.Mechanics.Kinematics.ScalarTrajectory)
    (a : MechLib.Mechanics.Kinematics.ScalarAccelerationField) :
    SatisfiesEulerLagrange1D m dVdx x a ↔ SatisfiesNewtonForm1D m dVdx x a := by
  constructor
  · intro hEL t
    have hval : (m * a t).val + (dVdx (x t)).val = 0 := by
      simpa [SatisfiesEulerLagrange1D, eulerLagrangeResidual1D] using
        congrArg MechLib.Units.Quantity.val (hEL t)
    ext
    have : (m * a t).val = -(dVdx (x t)).val := by linarith [hval]
    simpa [SatisfiesNewtonForm1D, MechLib.Mechanics.Dynamics.secondLaw] using this
  · intro hN t
    have hval : (m * a t).val = -(dVdx (x t)).val := by
      simpa [SatisfiesNewtonForm1D, MechLib.Mechanics.Dynamics.secondLaw] using
        congrArg MechLib.Units.Quantity.val (hN t)
    ext
    have hsum : (m * a t).val + (dVdx (x t)).val = 0 := by linarith [hval]
    simpa [SatisfiesEulerLagrange1D, eulerLagrangeResidual1D] using hsum

/-- 作用量泛函（1D 接口）。 -/
def actionFunctional1D
    (L : MechLib.SI.Length → MechLib.SI.Speed → MechLib.SI.Energy)
    (q : ℝ → MechLib.SI.Length) (qDot : ℝ → MechLib.SI.Speed)
    (t0 t1 : ℝ) : ℝ :=
  ∫ t in Set.uIcc t0 t1, (L (q t) (qDot t)).val

/-- 驻定作用接口：对任意变分方向，`ε=0` 处的一阶变分为零。 -/
def stationaryAction1D
    (S : (ℝ → MechLib.SI.Length) → ℝ) (q : ℝ → MechLib.SI.Length) : Prop :=
  ∀ η : ℝ → MechLib.SI.Length,
    HasDerivAt (fun (ε : ℝ) => S (fun t => q t + ε • η t)) 0 0

/-- Value-level simple-pendulum Lagrangian used as a modeling example. -/
def pendulumLagrangianValue (mass length gravity theta thetaDot : ℝ) : ℝ :=
  (1 / 2 : ℝ) * mass * length ^ 2 * thetaDot ^ 2
    - mass * gravity * length * (1 - Real.cos theta)

/-- Course-layer bridge from Euler-Lagrange form to the existing Newton-form equivalence. -/
theorem eulerLagrange_iff_newton_course_form
    (m : MechLib.SI.Mass) (dVdx : MechLib.SI.Length → MechLib.SI.Force)
    (x : MechLib.Mechanics.Kinematics.ScalarTrajectory)
    (a : MechLib.Mechanics.Kinematics.ScalarAccelerationField) :
    LagrangeEquationSchema m dVdx x a
      ↔ SatisfiesNewtonForm1D m dVdx x a := by
  simpa [LagrangeEquationSchema] using eulerLagrange_iff_newton m dVdx x a

example (m : MechLib.SI.Mass) (V : MechLib.SI.Length → MechLib.SI.Energy)
    (x : MechLib.SI.Length) (v : MechLib.SI.Speed) :
    lagrangian1D m V x v = MechLib.Mechanics.WorkEnergy.kineticEnergy1D m v - V x := rfl

example (mass length gravity theta thetaDot : ℝ) :
    pendulumLagrangianValue mass length gravity theta thetaDot =
      (1 / 2 : ℝ) * mass * length ^ 2 * thetaDot ^ 2
        - mass * gravity * length * (1 - Real.cos theta) := rfl

example
    (m : MechLib.SI.Mass) (dVdx : MechLib.SI.Length → MechLib.SI.Force)
    (x : MechLib.Mechanics.Kinematics.ScalarTrajectory)
    (a : MechLib.Mechanics.Kinematics.ScalarAccelerationField) :
    LagrangeEquationSchema m dVdx x a
      ↔ SatisfiesNewtonForm1D m dVdx x a :=
  eulerLagrange_iff_newton_course_form m dVdx x a

/-- Exported module metadata for this course-layer wrapper. -/
def moduleMetadata : ModuleMetadata :=
  {
    modulePath := "MechLib.Analytical.LagrangeEquation",
    topicId := "analytical.lagrange_equation",
    status := .verified,
    trustLevel := .derived,
    conceptIds := ["concept.lagrangian", "concept.generalized_coordinates"],
    lawSchemaIds := ["law.analytical.euler_lagrange_equation"],
    problemSchemaIds := ["problem.systems.pendulum_lagrangian"],
    exampleProblems := ["Single-pendulum Lagrangian modeling"],
    notes := [
      "Objects: Lagrangian, LagrangianSystem, EulerLagrangeResidual, EulerLagrangeResidualFree, GeneralizedMomentumOf.",
      "1D bridge: eulerLagrange_iff_newton_course_form.",
      "Physlib reference: Physlib.ClassicalMechanics.EulerLagrange"
    ]
  }

#check EulerLagrangeResidual
#check moduleMetadata

end
end LagrangeEquation
end Analytical
end MechLib
