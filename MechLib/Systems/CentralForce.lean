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
namespace CentralForce

open MechLib.Spec
open MechLib.Units
open MechLib.SI
open _root_.MechLib.Analytical.GeneralizedCoordinates

noncomputable section

/-! Course-layer module for `systems.central_force`.

Spec topic id: `systems.central_force`. -/
/-- Course-layer alias for the single-point central-force predicate. -/
abbrev IsCentralForce := MechLib.Mechanics.CentralForce.IsCentralForcePair

/-- Central-force model with potential label. -/
structure CentralForceModel where
  forceLawName : String
  potentialEnergy : MechLib.SI.Length → MechLib.SI.Energy

/-- Polar coordinates for a planar central-force problem. -/
structure PolarState where
  radius : MechLib.SI.Length
  theta : MechLib.SI.PhysAngle
  radiusDot : MechLib.SI.Speed
  thetaDot : MechLib.SI.AngularVelocity

/-- Polar-coordinate chart `(r, theta)`. -/
def polarCoordSpec : CoordSpec :=
  {
    dof := 2,
    coordName := fun i => if i = 0 then "r" else "theta",
    coordDim := fun i => if i = 0 then MechLib.SI.lengthDim else (0 : Dim)
  }

/-- Typed polar kinetic energy `T = 1/2 m (rDot² + r² thetaDot²)`. -/
def kineticEnergyPolar (mass : MechLib.SI.Mass) (s : PolarState) : MechLib.SI.Energy :=
  ⟨(1 / 2 : ℝ) * mass.val * (s.radiusDot.val ^ 2 + s.radius.val ^ 2 * s.thetaDot.val ^ 2)⟩

/-- Scalar potential-energy reader for a central-force model. -/
def potentialEnergy (model : CentralForceModel) (radius : MechLib.SI.Length) : MechLib.SI.Energy :=
  model.potentialEnergy radius

/-- Typed angular momentum `l = m r² thetaDot`. -/
def angularMomentum (mass : MechLib.SI.Mass) (s : PolarState) : MechLib.SI.AngularMomentum :=
  ⟨mass.val * s.radius.val ^ 2 * s.thetaDot.val⟩

/-- Compatibility value-level effective potential `Ueff = U + l²/(2 m r²)`.

temporary_untyped_fallback: use `effectivePotential` for the typed public API. -/
def effectivePotentialScalar (U : ℝ → ℝ) (mass angularMomentum radius : ℝ) : ℝ :=
  U radius + angularMomentum ^ 2 / ((2 : ℝ) * mass * radius ^ 2)

/-- Typed effective potential `Ueff = U + l²/(2 m r²)`. -/
def effectivePotential
    (U : MechLib.SI.Length → MechLib.SI.Energy) (mass : MechLib.SI.Mass)
    (L : MechLib.SI.AngularMomentum) (radius : MechLib.SI.Length) : MechLib.SI.Energy :=
  ⟨(U radius).val + L.val ^ 2 / ((2 : ℝ) * mass.val * radius.val ^ 2)⟩

/-- Central-force law schema re-exported through the system namespace. -/
def CentralForceLaw (r : MechLib.SI.VecLength 3) (F : MechLib.SI.VecForce 3) : Prop :=
  IsCentralForce r F

/-- Circular orbit schema: the radial derivative of the effective potential vanishes. -/
def circularOrbitCondition (dUeffdr : MechLib.SI.Length → MechLib.SI.Force)
    (radius : MechLib.SI.Length) : Prop :=
  0 < radius.val ∧ dUeffdr radius = 0

/-- Stable circular orbit schema: circular orbit plus positive second derivative. -/
def stableCircularOrbitCondition
    (dUeffdr : MechLib.SI.Length → MechLib.SI.Force)
    (d2Ueffdr2 : MechLib.SI.Length → MechLib.SI.SpringConstant)
    (radius : MechLib.SI.Length) : Prop :=
  circularOrbitCondition dUeffdr radius ∧ 0 < (d2Ueffdr2 radius).val

/-- Angular-momentum conservation schema for central-force motion. -/
def angularMomentum_conserved (L : MechLib.SI.Time → MechLib.SI.AngularMomentum) : Prop :=
  ∃ c : MechLib.SI.AngularMomentum, ∀ t, L t = c

/-- Course-layer wrapper for the existing Hooke central-force torque theorem. -/
theorem hookeCentralForce_torque_zero_course_form
    (k : MechLib.SI.SpringConstant) (r : MechLib.SI.VecLength 3) :
    MechLib.Mechanics.Rotation.torque r (MechLib.Mechanics.CentralForce.hookeCentralForce k r) = 0 := by
  simpa using MechLib.Mechanics.CentralForce.hookeCentralForce_torque_zero k r

/-- Worked example: Hooke central force has zero torque, so it fits central-force planning. -/
example (k : MechLib.SI.SpringConstant) (r : MechLib.SI.VecLength 3) :
    CentralForceLaw r (MechLib.Mechanics.CentralForce.hookeCentralForce k r) := by
  simpa [CentralForceLaw, IsCentralForce] using
    MechLib.Mechanics.CentralForce.hookeCentralForce_torque_zero k r

/-- Exported module metadata for this course-layer wrapper. -/
def moduleMetadata : ModuleMetadata :=
  {
    modulePath := "MechLib.Systems.CentralForce",
    topicId := "systems.central_force",
    status := .verified,
    trustLevel := .derived,
    conceptIds := ["concept.moment"],
    lawSchemaIds := ["law.dynamics.angular_momentum_conservation"],
    problemSchemaIds := ["problem.systems.central_force_angular_momentum"],
    exampleProblems := ["Central force angular-momentum conservation"],
    notes := ["typed API: PolarState, kineticEnergyPolar, angularMomentum, effectivePotential, circularOrbitCondition, angularMomentum_conserved; temporary_untyped_fallback: effectivePotentialScalar; verified: Hooke central-force torque wrapper."]
  }

#check IsCentralForce
#check effectivePotential
#check angularMomentum_conserved
#check moduleMetadata

end
end CentralForce
end Systems
end MechLib
