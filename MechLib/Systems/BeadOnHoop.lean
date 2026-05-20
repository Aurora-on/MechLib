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
namespace BeadOnHoop

open MechLib.Spec
open MechLib.Units
open MechLib.SI
open _root_.MechLib.Analytical.GeneralizedCoordinates

noncomputable section

/-! Course-layer module for `systems.bead_on_hoop`.

Spec topic id: `systems.bead_on_hoop`. -/
/-- Bead-on-hoop model parameters. -/
structure BeadOnHoopParams where
  mass : MechLib.SI.Mass
  hoopRadius : MechLib.SI.Length
  gravity : MechLib.SI.Acceleration
  rotationRate : MechLib.SI.AngularVelocity

/-- Preferred short name for the public bead-on-hoop parameter record. -/
abbrev Params := BeadOnHoopParams

/-- Single angle coordinate on the hoop. -/
def angleCoordSpec : CoordSpec :=
  {
    dof := 1,
    coordName := fun _ => "theta",
    coordDim := fun _ => (0 : Dim)
  }

/-- Hoop constraint residual: the bead radial distance is fixed to the hoop radius. -/
def HoopConstraintResidual
    (params : Params) (radialDistance : ℝ → MechLib.SI.Length)
    (theta : ℝ → MechLib.SI.PhysAngle) : Prop :=
  (∀ t, radialDistance t = params.hoopRadius) ∧ 0 < params.mass.val

/-- Rotating-hoop effective potential at scalar value level. -/
def effectivePotential (params : Params) (theta : ℝ) : ℝ :=
  params.mass.val * params.gravity.val * params.hoopRadius.val * (1 - Real.cos theta)
    - (1 / 2 : ℝ) * params.mass.val * params.rotationRate.val ^ 2
      * params.hoopRadius.val ^ 2 * (Real.sin theta) ^ 2

/-- Equilibrium schema `dVeff/dθ = 0`. -/
def equilibriumCondition (dVdtheta : ℝ → ℝ) (theta0 : ℝ) : Prop :=
  dVdtheta theta0 = 0

/-- Stability schema `d²Veff/dθ² > 0`. -/
def stabilityCondition (d2Vdtheta2 : ℝ → ℝ) (theta0 : ℝ) : Prop :=
  0 < d2Vdtheta2 theta0

example (params : Params) (theta : ℝ) :
    effectivePotential params theta =
      params.mass.val * params.gravity.val * params.hoopRadius.val * (1 - Real.cos theta)
        - (1 / 2 : ℝ) * params.mass.val * params.rotationRate.val ^ 2
          * params.hoopRadius.val ^ 2 * (Real.sin theta) ^ 2 := rfl

/-- Exported module metadata for this course-layer wrapper. -/
def moduleMetadata : ModuleMetadata :=
  {
    modulePath := "MechLib.Systems.BeadOnHoop",
    topicId := "systems.bead_on_hoop",
    status := .schema,
    trustLevel := .example,
    conceptIds := ["concept.constraints", "concept.lagrangian"],
    lawSchemaIds := ["law.analytical.euler_lagrange_equation"],
    problemSchemaIds := ["problem.systems.bead_on_hoop_equilibrium"],
    exampleProblems := ["Bead constrained on a hoop"],
    notes := ["schema: hoop constraint, effective potential, equilibrium and stability conditions."]
  }

#check Params
#check moduleMetadata

end
end BeadOnHoop
end Systems
end MechLib
