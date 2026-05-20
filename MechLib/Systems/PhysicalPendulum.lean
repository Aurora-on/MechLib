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
namespace PhysicalPendulum

open MechLib.Spec
open MechLib.Units
open MechLib.SI
open _root_.MechLib.Analytical.GeneralizedCoordinates

noncomputable section

/-! Course-layer module for `systems.physical_pendulum`.

Spec topic id: `systems.physical_pendulum`. -/
/-- Physical pendulum parameters. -/
structure PhysicalPendulumParams where
  mass : MechLib.SI.Mass
  centerDistance : MechLib.SI.Length
  gravity : MechLib.SI.Acceleration
  inertiaAboutPivot : MechLib.SI.MomentOfInertia

/-- Preferred short name for the public physical-pendulum parameter record. -/
abbrev Params := PhysicalPendulumParams

/-- Physical-pendulum generalized coordinate: body angle about the pivot. -/
def angleCoordSpec : CoordSpec :=
  {
    dof := 1,
    coordName := fun _ => "theta",
    coordDim := fun _ => (0 : Dim)
  }

/-- Moment of inertia about the pivot. -/
def momentOfInertia (params : Params) : MechLib.SI.MomentOfInertia :=
  params.inertiaAboutPivot

/-- Scalar kinetic energy `T = 1/2 I θdot^2`. -/
def kineticEnergy (params : Params) (thetaDot : ℝ) : ℝ :=
  (1 / 2 : ℝ) * params.inertiaAboutPivot.val * thetaDot ^ 2

/-- Scalar potential energy `V = m g d (1 - cos θ)`. -/
def potentialEnergy (params : Params) (theta : ℝ) : ℝ :=
  params.mass.val * params.gravity.val * params.centerDistance.val * (1 - Real.cos theta)

/-- Scalar Lagrangian `L = T - V`. -/
def lagrangian (params : Params) (theta thetaDot : ℝ) : ℝ :=
  kineticEnergy params thetaDot - potentialEnergy params theta

/-- Small-angle physical-pendulum residual at the scalar-value level. -/
def PhysicalPendulumResidual (params : Params) (theta thetaDDot : ℝ → ℝ) : Prop :=
  ∀ t,
    params.inertiaAboutPivot.val * thetaDDot t
      + params.mass.val * params.gravity.val * params.centerDistance.val * theta t = 0

/-- Alias for the small-angle physical-pendulum equation schema. -/
abbrev smallAngleEquation := PhysicalPendulumResidual

/-- Physical-pendulum period schema `T^2 = 4π² I/(m g d)`. -/
def physical_pendulum_period (params : Params) (period : ℝ) : Prop :=
  0 < period
    ∧ period ^ 2 =
      ((4 : ℝ) * Real.pi ^ 2 * params.inertiaAboutPivot.val)
        / (params.mass.val * params.gravity.val * params.centerDistance.val)

example (params : Params) (theta thetaDot : ℝ) :
    lagrangian params theta thetaDot =
      (1 / 2 : ℝ) * params.inertiaAboutPivot.val * thetaDot ^ 2
        - params.mass.val * params.gravity.val * params.centerDistance.val * (1 - Real.cos theta) := rfl

/-- Exported module metadata for this course-layer wrapper. -/
def moduleMetadata : ModuleMetadata :=
  {
    modulePath := "MechLib.Systems.PhysicalPendulum",
    topicId := "systems.physical_pendulum",
    status := .schema,
    trustLevel := .interface,
    conceptIds := ["concept.lagrangian", "concept.moment"],
    lawSchemaIds := ["law.analytical.euler_lagrange_equation"],
    problemSchemaIds := ["problem.systems.physical_pendulum_period"],
    exampleProblems := ["Physical pendulum about a pivot"],
    notes := ["schema: small-angle equation and period relation."]
  }

#check Params
#check moduleMetadata

end
end PhysicalPendulum
end Systems
end MechLib
