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
namespace Dynamics
namespace SystemDynamics

open MechLib.Spec
open MechLib.Units
open MechLib.SI

noncomputable section

/-! Course-layer module for `dynamics.system_dynamics`.

Spec topic id: `dynamics.system_dynamics`. -/
/-- Course-layer alias for a one-dimensional particle in system dynamics. -/
abbrev Particle := MechLib.Mechanics.SystemDynamics.Particle1D

/-- System dynamics model with external resultant force. -/
structure SystemDynamicsModel where
  particles : List Particle
  externalResultant : MechLib.SI.VecForce 3

/-- Center-of-mass balance schema re-exported through the course layer. -/
def CenterOfMassBalance
    (M : MechLib.SI.Mass) (Rddot : ℝ → MechLib.SI.Acceleration)
    (Fext : ℝ → MechLib.SI.Force) : Prop :=
  MechLib.Mechanics.SystemDynamics.CenterOfMassTheorem M Rddot Fext

/-- Two-body center-of-mass displacement relation:
`(m1 + m2) dR = m1 dx1 + m2 dx2`, stated at value level. -/
def CenterOfMassDisplacement2
    (m1 m2 : MechLib.SI.Mass)
    (dx1 dx2 dR : MechLib.SI.Length) : Prop :=
  (m1.val + m2.val) * dR.val = m1.val * dx1.val + m2.val * dx2.val

/-- Closed two-body center-of-mass displacement conservation relation. -/
def CenterOfMassDisplacementConservation2
    (m1 m2 : MechLib.SI.Mass) (dx1 dx2 : MechLib.SI.Length) : Prop :=
  m1.val * dx1.val + m2.val * dx2.val = 0

/-- Course-layer center-of-mass schema expands to the existing theorem interface. -/
theorem centerOfMassBalance_eq
    (M : MechLib.SI.Mass) (Rddot : ℝ → MechLib.SI.Acceleration)
    (Fext : ℝ → MechLib.SI.Force) :
    CenterOfMassBalance M Rddot Fext = (∀ t, M * Rddot t = Fext t) := by
  simpa [CenterOfMassBalance] using
    MechLib.Mechanics.SystemDynamics.centerOfMassTheorem_eq M Rddot Fext

/-- Course-layer wrapper for the verified two-body kinetic-energy decomposition. -/
theorem twoBody_kineticEnergy_decomposition_verified
    (m1 m2 : MechLib.SI.Mass) (v1 v2 : MechLib.SI.Speed)
    (h : (m1 + m2).val ≠ 0) :
    MechLib.Mechanics.SystemDynamics.totalKineticEnergy2 m1 m2 v1 v2 =
      MechLib.Mechanics.SystemDynamics.decomposedKineticEnergy2 m1 m2 v1 v2 := by
  simpa using
    MechLib.Mechanics.SystemDynamics.twoBody_kineticEnergy_decomposition m1 m2 v1 v2 h

/-- Extract the scalar equation from the two-body center-of-mass displacement relation. -/
theorem centerOfMassDisplacement2_to_value_equation
    {m1 m2 : MechLib.SI.Mass} {dx1 dx2 dR : MechLib.SI.Length}
    (h : CenterOfMassDisplacement2 m1 m2 dx1 dx2 dR) :
    (m1.val + m2.val) * dR.val = m1.val * dx1.val + m2.val * dx2.val :=
  h

/-- Extract the scalar equation from the closed two-body COM displacement conservation relation. -/
theorem centerOfMassDisplacementConservation2_to_value_equation
    {m1 m2 : MechLib.SI.Mass} {dx1 dx2 : MechLib.SI.Length}
    (h : CenterOfMassDisplacementConservation2 m1 m2 dx1 dx2) :
    m1.val * dx1.val + m2.val * dx2.val = 0 :=
  h

example (p : Particle) (h : p.m.val ≠ 0) :
    MechLib.Mechanics.SystemDynamics.centerOfMassPosition [p] = p.x :=
  MechLib.Mechanics.SystemDynamics.centerOfMassPosition_singleton p h

/-- Exported module metadata for this course-layer wrapper. -/
def moduleMetadata : ModuleMetadata :=
  {
    modulePath := "MechLib.Dynamics.SystemDynamics",
    topicId := "dynamics.system_dynamics",
    status := .verified,
    trustLevel := .derived,
    conceptIds := [],
    lawSchemaIds := [],
    problemSchemaIds := ["problem.dynamics.particle_dynamics"],
    exampleProblems := ["Center-of-mass theorem planning", "Two-body center-of-mass displacement relation"],
    notes := ["Typed API: Particle, SystemDynamicsModel, CenterOfMassBalance, CenterOfMassDisplacement2; wrappers for center-of-mass and two-body kinetic-energy decomposition."]
  }

#check Particle
#check CenterOfMassBalance
#check CenterOfMassDisplacement2
#check centerOfMassDisplacement2_to_value_equation
#check moduleMetadata

end
end SystemDynamics
end Dynamics
end MechLib
