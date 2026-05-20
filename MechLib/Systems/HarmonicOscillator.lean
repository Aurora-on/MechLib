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
namespace Systems
namespace HarmonicOscillator

open MechLib.Spec
open MechLib.Units
open MechLib.SI

noncomputable section

/-! Course-layer module for `systems.harmonic_oscillator`.

Spec topic id: `systems.harmonic_oscillator`. -/
/-- Course-layer alias for SHM equation schema. -/
abbrev SHMEquation := MechLib.Mechanics.SHM.SHMEquation

/-- Harmonic oscillator state. -/
structure HarmonicOscillatorState where
  position : MechLib.SI.Length
  velocity : MechLib.SI.Speed
  omega : MechLib.SI.AngularVelocity

/-- Harmonic oscillator equation schema using the existing SHM interface. -/
def HarmonicOscillatorEquation
    (omega : MechLib.SI.AngularVelocity)
    (x : MechLib.SI.Time → MechLib.SI.Length)
    (a : MechLib.SI.Time → MechLib.SI.Acceleration) : Prop :=
  SHMEquation omega x a

/-- Course-layer wrapper for the existing period-frequency theorem. -/
theorem periodFrequency_course_form
    (omega : MechLib.SI.AngularVelocity) (h : omega.val ≠ 0) :
    MechLib.Units.Quantity.cast
        (MechLib.Mechanics.SHM.period omega * omega)
        MechLib.SI.time_plus_angular_velocity_eq_dimensionless
      = (((2 : ℝ) * Real.pi : ℝ) : MechLib.SI.Dimensionless) := by
  simpa using MechLib.Mechanics.SHM.period_frequency_relation omega h

/-- Exported module metadata for this course-layer wrapper. -/
def moduleMetadata : ModuleMetadata :=
  {
    modulePath := "MechLib.Systems.HarmonicOscillator",
    topicId := "systems.harmonic_oscillator",
    status := .verified,
    trustLevel := .core,
    conceptIds := ["concept.kinetic_energy", "concept.potential_energy"],
    lawSchemaIds := ["law.analytical.small_oscillation_equation"],
    problemSchemaIds := ["problem.systems.coupled_oscillator_normal_modes"],
    exampleProblems := ["Mass-spring oscillator"],
    notes := ["Wrapper for Mechanics.SHM.", "Physlib reference: Physlib.ClassicalMechanics.HarmonicOscillator"]
  }

#check SHMEquation
#check moduleMetadata

end
end HarmonicOscillator
end Systems
end MechLib
