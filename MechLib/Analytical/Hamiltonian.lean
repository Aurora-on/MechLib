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
import MechLib.Analytical.LagrangeEquation

set_option linter.dupNamespace false
set_option linter.unusedVariables false

namespace MechLib
namespace Analytical
namespace Hamiltonian

open MechLib.Spec
open MechLib.Units
open MechLib.SI
open _root_.MechLib.Analytical.GeneralizedCoordinates

noncomputable section

/-! Course-layer module for `analytical.hamiltonian`.

Spec topic id: `analytical.hamiltonian`. -/
/-- Hamiltonian function for a generalized-coordinate chart. -/
abbrev Hamiltonian (spec : CoordSpec) : Type :=
  GCoord spec → GeneralizedMomentumVector spec → ℝ → MechLib.SI.Energy

/-- Hamiltonian system with derivative providers for canonical equations. -/
structure HamiltonianSystem where
  coordSpec : CoordSpec
  hamiltonian : Hamiltonian coordSpec
  dHdP : GCoord coordSpec → GeneralizedMomentumVector coordSpec → ℝ → GVel coordSpec
  dHdQ : GCoord coordSpec → GeneralizedMomentumVector coordSpec → ℝ → GeneralizedForceVector coordSpec

/-- Hamilton canonical-equation residual for general finite-dimensional systems. -/
def CanonicalEquationResidual
    (system : HamiltonianSystem)
    (q : ℝ → GCoord system.coordSpec)
    (p : ℝ → GeneralizedMomentumVector system.coordSpec)
    (qdot : ℝ → GVel system.coordSpec)
    (pdot : ℝ → GeneralizedForceVector system.coordSpec) : Prop :=
  ∀ t i,
    qdot t i = system.dHdP (q t) (p t) t i
      ∧ pdot t i = -system.dHdQ (q t) (p t) t i

theorem momentum_two_sub_mass_eq_energy :
    (2 : ℕ) • MechLib.SI.momentumDim - MechLib.SI.massDim = MechLib.SI.energyDim := by
  native_decide

/-- 一维正则动量定义：`p = m v`。 -/
def canonicalMomentum1D (m : MechLib.SI.Mass) (v : MechLib.SI.Speed) : MechLib.SI.Momentum :=
  m * v

/-- 以 `(x, v)` 表示的哈密顿量：`H = T + V`。 -/
def hamiltonianXV
    (m : MechLib.SI.Mass) (V : MechLib.SI.Length → MechLib.SI.Energy)
    (x : MechLib.SI.Length) (v : MechLib.SI.Speed) : MechLib.SI.Energy :=
  MechLib.Mechanics.WorkEnergy.kineticEnergy1D m v + V x

/-- 以 `(x, p)` 表示的哈密顿量：`H = p^2/(2m) + V`。 -/
def hamiltonianXP
    (m : MechLib.SI.Mass) (V : MechLib.SI.Length → MechLib.SI.Energy)
    (x : MechLib.SI.Length) (p : MechLib.SI.Momentum) : MechLib.SI.Energy :=
  MechLib.Units.Quantity.cast ((p ** 2) / ((2 : ℝ) • m)) momentum_two_sub_mass_eq_energy + V x

/-- 一自由度哈密顿方程组接口。 -/
def CanonicalEquations1D
    (dHdp : MechLib.SI.Length → MechLib.SI.Momentum → MechLib.SI.Speed)
    (dHdx : MechLib.SI.Length → MechLib.SI.Momentum → MechLib.SI.Force)
    (x : MechLib.Mechanics.Kinematics.ScalarTrajectory) (p : ℝ → MechLib.SI.Momentum)
    (xDot : MechLib.Mechanics.Kinematics.ScalarVelocityField)
    (pDot : ℝ → MechLib.SI.Force) : Prop :=
  ∀ t, xDot t = dHdp (x t) (p t) ∧ pDot t = -dHdx (x t) (p t)

/-- Legendre 变换正则性（1D 接口：`v -> p(v)` 注入）。 -/
def legendreRegular1D (pOfV : MechLib.SI.Speed → MechLib.SI.Momentum) : Prop :=
  Function.Injective (fun v => (pOfV v).val)

theorem canonicalMomentum1D_eq (m : MechLib.SI.Mass) (v : MechLib.SI.Speed) :
    canonicalMomentum1D m v = m * v := rfl

theorem hamiltonianXV_eq
    (m : MechLib.SI.Mass) (V : MechLib.SI.Length → MechLib.SI.Energy)
    (x : MechLib.SI.Length) (v : MechLib.SI.Speed) :
    hamiltonianXV m V x v = MechLib.Mechanics.WorkEnergy.kineticEnergy1D m v + V x := rfl

theorem hamiltonianXP_eq
    (m : MechLib.SI.Mass) (V : MechLib.SI.Length → MechLib.SI.Energy)
    (x : MechLib.SI.Length) (p : MechLib.SI.Momentum) :
    hamiltonianXP m V x p =
      MechLib.Units.Quantity.cast ((p ** 2) / ((2 : ℝ) • m))
        momentum_two_sub_mass_eq_energy + V x := rfl

/-- 在 `p = m v` 且 `m ≠ 0` 下，`H(x,p)` 与 `H(x,v)` 两种表达等价。 -/
theorem hamiltonianXP_of_canonicalMomentum
    (m : MechLib.SI.Mass) (V : MechLib.SI.Length → MechLib.SI.Energy)
    (x : MechLib.SI.Length) (v : MechLib.SI.Speed) (h : m.val ≠ 0) :
    hamiltonianXP m V x (canonicalMomentum1D m v) = hamiltonianXV m V x v := by
  ext
  have hm2 : (2 : ℝ) * m.val ≠ 0 := mul_ne_zero two_ne_zero h
  simp [hamiltonianXP, hamiltonianXV, canonicalMomentum1D,
    MechLib.Mechanics.WorkEnergy.kineticEnergy1D, MechLib.Units.Quantity.cast_val]
  field_simp [h, hm2]

theorem canonicalEquations1D_eq
    (dHdp : MechLib.SI.Length → MechLib.SI.Momentum → MechLib.SI.Speed)
    (dHdx : MechLib.SI.Length → MechLib.SI.Momentum → MechLib.SI.Force)
    (x : MechLib.Mechanics.Kinematics.ScalarTrajectory) (p : ℝ → MechLib.SI.Momentum)
    (xDot : MechLib.Mechanics.Kinematics.ScalarVelocityField) (pDot : ℝ → MechLib.SI.Force) :
    CanonicalEquations1D dHdp dHdx x p xDot pDot =
      (∀ t, xDot t = dHdp (x t) (p t) ∧ pDot t = -dHdx (x t) (p t)) := rfl

/-- Hamiltonian schema re-exported through the course-layer namespace. -/
def HamiltonianSchema
    (dHdp : MechLib.SI.Length → MechLib.SI.Momentum → MechLib.SI.Speed)
    (dHdx : MechLib.SI.Length → MechLib.SI.Momentum → MechLib.SI.Force)
    (x : MechLib.Mechanics.Kinematics.ScalarTrajectory) (p : ℝ → MechLib.SI.Momentum)
    (xDot : MechLib.Mechanics.Kinematics.ScalarVelocityField) (pDot : ℝ → MechLib.SI.Force) : Prop :=
  CanonicalEquations1D dHdp dHdx x p xDot pDot

/-- Hamiltonian course schema expands to the existing canonical-equation interface. -/
theorem hamiltonianSchema_eq
    (dHdp : MechLib.SI.Length → MechLib.SI.Momentum → MechLib.SI.Speed)
    (dHdx : MechLib.SI.Length → MechLib.SI.Momentum → MechLib.SI.Force)
    (x : MechLib.Mechanics.Kinematics.ScalarTrajectory) (p : ℝ → MechLib.SI.Momentum)
    (xDot : MechLib.Mechanics.Kinematics.ScalarVelocityField) (pDot : ℝ → MechLib.SI.Force) :
    HamiltonianSchema dHdp dHdx x p xDot pDot =
      CanonicalEquations1D dHdp dHdx x p xDot pDot := rfl

example
    (dHdp : MechLib.SI.Length → MechLib.SI.Momentum → MechLib.SI.Speed)
    (dHdx : MechLib.SI.Length → MechLib.SI.Momentum → MechLib.SI.Force)
    (x : MechLib.Mechanics.Kinematics.ScalarTrajectory) (p : ℝ → MechLib.SI.Momentum)
    (xDot : MechLib.Mechanics.Kinematics.ScalarVelocityField) (pDot : ℝ → MechLib.SI.Force) :
    HamiltonianSchema dHdp dHdx x p xDot pDot =
      CanonicalEquations1D dHdp dHdx x p xDot pDot := rfl

/-- Exported module metadata for this course-layer wrapper. -/
def moduleMetadata : ModuleMetadata :=
  {
    modulePath := "MechLib.Analytical.Hamiltonian",
    topicId := "analytical.hamiltonian",
    status := .verified,
    trustLevel := .derived,
    conceptIds := ["concept.generalized_coordinates", "concept.lagrangian"],
    lawSchemaIds := ["law.analytical.hamilton_canonical_equations"],
    problemSchemaIds := ["problem.systems.pendulum_lagrangian"],
    exampleProblems := ["Canonical equation planning"],
    notes := [
      "Objects: Hamiltonian, HamiltonianSystem, CanonicalEquationResidual.",
      "Wrapper for Hamiltonian interfaces.",
      "Physlib reference: Physlib.ClassicalMechanics.HamiltonsEquations"
    ]
  }

#check HamiltonianSystem
#check moduleMetadata

end
end Hamiltonian
end Analytical
end MechLib
