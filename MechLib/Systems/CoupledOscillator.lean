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
import MechLib.Analytical.SmallOscillations

set_option linter.dupNamespace false
set_option linter.unusedVariables false

namespace MechLib
namespace Systems
namespace CoupledOscillator

open MechLib.Spec
open MechLib.Units
open MechLib.SI
open _root_.MechLib.Analytical.GeneralizedCoordinates

noncomputable section

/-! Course-layer module for `systems.coupled_oscillator`.

Spec topic id: `systems.coupled_oscillator`. -/
/-- Coupled oscillator matrices for normal-mode planning. -/
structure CoupledOscillatorModel where
  dof : ℕ
  massMatrix : Matrix (Fin dof) (Fin dof) MechLib.SI.Mass
  stiffnessMatrix : Matrix (Fin dof) (Fin dof) MechLib.SI.SpringConstant

/-- Two generalized coordinates for a benchmark two-oscillator system. -/
def twoCoordSpec : CoordSpec :=
  {
    dof := 2,
    coordName := fun i => if i = 0 then "x1" else "x2",
    coordDim := fun _ => MechLib.SI.lengthDim
  }

/-- Scalar vector-like coordinates for the two-oscillator benchmark. -/
structure TwoCoordinates where
  x1 : MechLib.SI.Length
  x2 : MechLib.SI.Length

/-- Compatibility scalar quadratic form helper `vᵀ A v`.

temporary_untyped_fallback: kept for matrix-algebra planning and old examples. -/
def quadraticFormValue {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ) (v : Fin n → ℝ) : ℝ :=
  ∑ i : Fin n, v i * (A.mulVec v) i

/-- Kinetic energy `T = 1/2 qdotᵀ M qdot`. -/
def kineticEnergy
    (model : CoupledOscillatorModel) (qdot : Fin model.dof → MechLib.SI.Speed) :
    MechLib.SI.Energy :=
  ⟨(1 / 2 : ℝ) *
    (∑ i : Fin model.dof, (qdot i).val *
      (∑ j : Fin model.dof, (model.massMatrix i j).val * (qdot j).val))⟩

/-- Potential energy `V = 1/2 qᵀ K q`. -/
def potentialEnergy
    (model : CoupledOscillatorModel) (q : Fin model.dof → MechLib.SI.Length) :
    MechLib.SI.Energy :=
  ⟨(1 / 2 : ℝ) *
    (∑ i : Fin model.dof, (q i).val *
      (∑ j : Fin model.dof, (model.stiffnessMatrix i j).val * (q j).val))⟩

/-- Lagrangian `L = T - V` for the linear coupled oscillator. -/
def lagrangian (model : CoupledOscillatorModel)
    (q : Fin model.dof → MechLib.SI.Length)
    (qdot : Fin model.dof → MechLib.SI.Speed) : MechLib.SI.Energy :=
  kineticEnergy model qdot - potentialEnergy model q

/-- Linear equation residual `M qddot + K q = 0`. -/
def linearEquationResidual
    (model : CoupledOscillatorModel)
    (q : MechLib.SI.Time → Fin model.dof → MechLib.SI.Length)
    (qDDot : MechLib.SI.Time → Fin model.dof → MechLib.SI.Acceleration) : Prop :=
  ∀ t i,
    (∑ j : Fin model.dof, (model.massMatrix i j).val * (qDDot t j).val)
      + (∑ j : Fin model.dof, (model.stiffnessMatrix i j).val * (q t j).val) = 0

/-- Normal-mode residual `K v = omega^2 M v` for a nonzero mode shape. -/
def NormalModeResidual
    (model : CoupledOscillatorModel) (frequencySquared : MechLib.SI.AngularVelocitySquared) : Prop :=
  ∃ mode : Fin model.dof → MechLib.SI.Length,
    (∃ i, (mode i).val ≠ 0)
      ∧ ∀ i,
        (∑ j : Fin model.dof, (model.stiffnessMatrix i j).val * (mode j).val)
          = frequencySquared.val *
            (∑ j : Fin model.dof, (model.massMatrix i j).val * (mode j).val)

/-- Alias requested by the benchmark interface. -/
abbrev normalModeCondition := NormalModeResidual

/-- Unit stiffness `kg s⁻²`, typed as a spring constant. -/
def unitStiffness : MechLib.SI.SpringConstant :=
  MechLib.Units.Quantity.cast
    (MechLib.SI.kilogram * (MechLib.SI.hertz ** 2))
    MechLib.SI.mass_plus_two_omega_eq_spring

/-- Unit angular-frequency square `s⁻²`. -/
def unitFrequencySquared : MechLib.SI.AngularVelocitySquared :=
  MechLib.SI.hertz ** 2

/-- Worked symbolic example: unit mass/stiffness matrices have unit frequency mode. -/
def identityTwoOscillator : CoupledOscillatorModel :=
  {
    dof := 2,
    massMatrix := fun _ _ => MechLib.SI.kilogram,
    stiffnessMatrix := fun _ _ => unitStiffness
  }

example : NormalModeResidual identityTwoOscillator unitFrequencySquared := by
  refine ⟨fun _ => MechLib.SI.meter, ?_⟩
  constructor
  · exact ⟨⟨0, by decide⟩, by norm_num [MechLib.SI.meter]⟩
  · intro i
    simp [identityTwoOscillator, unitStiffness, unitFrequencySquared, MechLib.SI.meter,
      MechLib.SI.kilogram, MechLib.SI.hertz]

/-- Exported module metadata for this course-layer wrapper. -/
def moduleMetadata : ModuleMetadata :=
  {
    modulePath := "MechLib.Systems.CoupledOscillator",
    topicId := "systems.coupled_oscillator",
    status := .schema,
    trustLevel := .interface,
    conceptIds := ["concept.lagrangian", "concept.kinetic_energy", "concept.potential_energy"],
    lawSchemaIds := ["law.analytical.small_oscillation_equation"],
    problemSchemaIds := ["problem.systems.coupled_oscillator_normal_modes"],
    exampleProblems := ["Coupled oscillator normal modes"],
    notes := ["typed API: Mass matrix, SpringConstant stiffness matrix, Length coordinates, Speed velocities, Energy Lagrangian, AngularVelocitySquared normal modes; temporary_untyped_fallback: quadraticFormValue for scalar matrix planning; worked unit-matrix example verified."]
  }

#check CoupledOscillatorModel
#check kineticEnergy
#check normalModeCondition
#check moduleMetadata

end
end CoupledOscillator
end Systems
end MechLib
