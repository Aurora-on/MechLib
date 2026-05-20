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
namespace Pendulum

open MechLib.Spec
open MechLib.Units
open MechLib.SI
open _root_.MechLib.Analytical.GeneralizedCoordinates

noncomputable section

/-! Course-layer module for `systems.pendulum`.

Spec topic id: `systems.pendulum`. -/
/-- Simple pendulum parameters. -/
structure PendulumParams where
  mass : MechLib.SI.Mass
  length : MechLib.SI.Length
  gravity : MechLib.SI.Acceleration

/-- Preferred short name for the public system parameter record. -/
abbrev Params := PendulumParams

/-- One generalized coordinate: the pendulum angle `theta`. -/
def angleCoordSpec : CoordSpec :=
  {
    dof := 1,
    coordName := fun _ => "theta",
    coordDim := fun _ => (0 : Dim)
  }

/-- Compatibility value-level kinetic energy `T = 1/2 m l^2 θdot^2`.

temporary_untyped_fallback: use `kineticEnergy` for the typed public API. -/
def kineticEnergyValue (params : Params) (thetaDot : ℝ) : ℝ :=
  (1 / 2 : ℝ) * params.mass.val * params.length.val ^ 2 * thetaDot ^ 2

/-- Typed kinetic energy `T = 1/2 m l^2 θdot^2`. -/
def kineticEnergy (params : Params) (thetaDot : MechLib.SI.AngularVelocity) : MechLib.SI.Energy :=
  ⟨kineticEnergyValue params thetaDot.val⟩

/-- Compatibility value-level potential energy `V = m g l (1 - cos θ)`.

temporary_untyped_fallback: use `potentialEnergy` for the typed public API. -/
def potentialEnergyValue (params : Params) (theta : ℝ) : ℝ :=
  params.mass.val * params.gravity.val * params.length.val * (1 - Real.cos theta)

/-- Typed potential energy `V = m g l (1 - cos θ)`. -/
def potentialEnergy (params : Params) (theta : MechLib.SI.PhysAngle) : MechLib.SI.Energy :=
  ⟨potentialEnergyValue params theta.val⟩

/-- Compatibility value-level Lagrangian `L = T - V`.

temporary_untyped_fallback: use `lagrangian` for the typed public API. -/
def lagrangianValue (params : Params) (theta thetaDot : ℝ) : ℝ :=
  kineticEnergyValue params thetaDot - potentialEnergyValue params theta

/-- Typed Lagrangian `L = T - V`. -/
def lagrangian
    (params : Params) (theta : MechLib.SI.PhysAngle)
    (thetaDot : MechLib.SI.AngularVelocity) : MechLib.SI.Energy :=
  kineticEnergy params thetaDot - potentialEnergy params theta

/-- Full simple-pendulum equation residual `θ¨ + (g/l) sin θ = 0` with typed angle and angular acceleration. -/
def equationResidual
    (params : Params) (theta : MechLib.SI.Time → MechLib.SI.PhysAngle)
    (thetaDDot : MechLib.SI.Time → MechLib.SI.AngularAcceleration) : Prop :=
  ∀ t, (thetaDDot t).val + (params.gravity.val / params.length.val) * Real.sin ((theta t).val) = 0

/-- Equation-of-motion schema for the simple pendulum. -/
abbrev EquationOfMotion := equationResidual

/-- Small-angle simple-pendulum residual `θ¨ + (g/l) θ = 0` with typed angle and angular acceleration. -/
def PendulumEquationResidual
    (params : Params) (theta : MechLib.SI.Time → MechLib.SI.PhysAngle)
    (thetaDDot : MechLib.SI.Time → MechLib.SI.AngularAcceleration) : Prop :=
  ∀ t, (thetaDDot t).val + (params.gravity.val / params.length.val) * (theta t).val = 0

/-- Small-angle approximation schema `sin θ ≈ θ`, represented as exact equality for planning. -/
def smallAngleApprox (theta : MechLib.SI.Time → MechLib.SI.PhysAngle) : Prop :=
  ∀ t, Real.sin ((theta t).val) = (theta t).val

/-- Under the small-angle schema, the nonlinear residual reduces to SHM form. -/
theorem smallAngle_to_SHM
    (params : Params) (theta : MechLib.SI.Time → MechLib.SI.PhysAngle)
    (thetaDDot : MechLib.SI.Time → MechLib.SI.AngularAcceleration)
    (hEq : EquationOfMotion params theta thetaDDot)
    (hSmall : smallAngleApprox theta) :
    PendulumEquationResidual params theta thetaDDot := by
  intro t
  simpa [EquationOfMotion, equationResidual, PendulumEquationResidual, hSmall t] using hEq t

/-- Worked example: the compatibility Lagrangian expands to `T - V`. -/
example (params : Params) (theta thetaDot : ℝ) :
    lagrangianValue params theta thetaDot =
      (1 / 2 : ℝ) * params.mass.val * params.length.val ^ 2 * thetaDot ^ 2
        - params.mass.val * params.gravity.val * params.length.val * (1 - Real.cos theta) := by
  rfl

/-- Exported module metadata for this course-layer wrapper. -/
def moduleMetadata : ModuleMetadata :=
  {
    modulePath := "MechLib.Systems.Pendulum",
    topicId := "systems.pendulum",
    status := .schema,
    trustLevel := .interface,
    conceptIds := ["concept.lagrangian", "concept.generalized_coordinates"],
    lawSchemaIds := ["law.analytical.euler_lagrange_equation"],
    problemSchemaIds := ["problem.systems.pendulum_lagrangian"],
    exampleProblems := ["Simple pendulum Lagrangian modeling"],
    notes := ["typed API: Params, kineticEnergy, potentialEnergy, lagrangian, equationResidual; temporary_untyped_fallback: kineticEnergyValue, potentialEnergyValue, lagrangianValue; verified: smallAngle_to_SHM under small-angle schema."]
  }

#check Params
#check kineticEnergy
#check lagrangian
#check moduleMetadata

end
end Pendulum
end Systems
end MechLib
