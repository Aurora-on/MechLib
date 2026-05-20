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
namespace SmallOscillations

open MechLib.Spec
open MechLib.Units
open MechLib.SI
open _root_.MechLib.Analytical.GeneralizedCoordinates

noncomputable section

/-! Course-layer module for `analytical.small_oscillations`.

Spec topic id: `analytical.small_oscillations`. -/
/-- Small-oscillation system `M qddot + K q = 0` around an equilibrium. -/
structure SmallOscillationSystem where
  dof : ℕ
  massMatrix : Matrix (Fin dof) (Fin dof) ℝ
  stiffnessMatrix : Matrix (Fin dof) (Fin dof) ℝ
  equilibrium : Fin dof → ℝ

/-- Linearized small-oscillation residual `M qddot + K q = 0`. -/
structure SmallOscillationResidual where
  dof : ℕ
  massMatrix : Matrix (Fin dof) (Fin dof) ℝ
  stiffnessMatrix : Matrix (Fin dof) (Fin dof) ℝ
  displacement : ℝ → Fin dof → ℝ

/-- Small-oscillation equation schema marker. -/
def SmallOscillationEquation (r : SmallOscillationResidual) : Prop :=
  ∃ acceleration : ℝ → Fin r.dof → ℝ,
    ∀ t i,
      (r.massMatrix.mulVec (acceleration t)) i
        + (r.stiffnessMatrix.mulVec (r.displacement t)) i = 0

/-- Normal-mode eigencondition `K v = ω² M v` with a nonzero mode shape. -/
def NormalModeCondition
    (system : SmallOscillationSystem) (omegaSq : ℝ) (mode : Fin system.dof → ℝ) : Prop :=
  (∃ i, mode i ≠ 0)
    ∧ ∀ i,
      (system.stiffnessMatrix.mulVec mode) i
        = omegaSq * (system.massMatrix.mulVec mode) i

/-- Convert a small-oscillation system and displacement into an equation residual. -/
def residualOfSystem (system : SmallOscillationSystem)
    (displacement : ℝ → Fin system.dof → ℝ) : SmallOscillationResidual :=
  {
    dof := system.dof,
    massMatrix := system.massMatrix,
    stiffnessMatrix := system.stiffnessMatrix,
    displacement := displacement
  }

/-- Two-degree-of-freedom coupled-oscillator schema placeholder with explicit matrices. -/
def twoDOFCoupledOscillatorSchema : SmallOscillationSystem :=
  {
    dof := 2,
    massMatrix := 1,
    stiffnessMatrix := 1,
    equilibrium := fun _ => 0
  }

example : NormalModeCondition twoDOFCoupledOscillatorSchema 1 (fun _ => 1) := by
  constructor
  · exact ⟨⟨0, by decide⟩, by norm_num⟩
  · intro i
    simp [twoDOFCoupledOscillatorSchema, Matrix.mulVec]

/-- Exported module metadata for this course-layer wrapper. -/
def moduleMetadata : ModuleMetadata :=
  {
    modulePath := "MechLib.Analytical.SmallOscillations",
    topicId := "analytical.small_oscillations",
    status := .interface,
    trustLevel := .interface,
    conceptIds := ["concept.lagrangian", "concept.kinetic_energy", "concept.potential_energy"],
    lawSchemaIds := ["law.analytical.small_oscillation_equation"],
    problemSchemaIds := ["problem.systems.coupled_oscillator_normal_modes"],
    exampleProblems := ["Normal-mode setup for coupled oscillator"],
    notes := ["Objects: SmallOscillationSystem, SmallOscillationResidual, SmallOscillationEquation, NormalModeCondition."]
  }

#check SmallOscillationSystem
#check moduleMetadata

end
end SmallOscillations
end Analytical
end MechLib
