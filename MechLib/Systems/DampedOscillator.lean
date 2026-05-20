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
namespace DampedOscillator

open MechLib.Spec
open MechLib.Units
open MechLib.SI

noncomputable section

/-! Course-layer module for `systems.damped_oscillator`.

Spec topic id: `systems.damped_oscillator`. -/
/-- Course-layer alias for damped oscillator parameters. -/
abbrev DampedParams := MechLib.Mechanics.DampedSHM.Params

/-- Damped oscillator model with initial data label. -/
structure DampedOscillatorModel where
  params : DampedParams
  initialDataLabel : String

/-- Damped oscillator equation schema re-exported from the verified mechanics module. -/
def DampedEquationSchema
    (model : DampedOscillatorModel)
    (x : MechLib.SI.Time → MechLib.SI.Length)
    (v : MechLib.SI.Time → MechLib.SI.Speed)
    (a : MechLib.SI.Time → MechLib.SI.Acceleration) : Prop :=
  MechLib.Mechanics.DampedSHM.EquationOfMotion model.params x v a

/-- Course-layer wrapper for the damped-oscillator regime trichotomy. -/
theorem dampedRegimes_course_form (model : DampedOscillatorModel) :
    MechLib.Mechanics.DampedSHM.IsUnderdamped model.params
      ∨ MechLib.Mechanics.DampedSHM.IsCriticallyDamped model.params
      ∨ MechLib.Mechanics.DampedSHM.IsOverdamped model.params := by
  simpa using MechLib.Mechanics.DampedSHM.regimes_trichotomy model.params

/-- Exported module metadata for this course-layer wrapper. -/
def moduleMetadata : ModuleMetadata :=
  {
    modulePath := "MechLib.Systems.DampedOscillator",
    topicId := "systems.damped_oscillator",
    status := .verified,
    trustLevel := .derived,
    conceptIds := ["concept.kinetic_energy", "concept.potential_energy"],
    lawSchemaIds := ["law.analytical.small_oscillation_equation"],
    problemSchemaIds := ["problem.systems.coupled_oscillator_normal_modes"],
    exampleProblems := ["Damped oscillator regime classification"],
    notes := ["Wrapper for Mechanics.DampedSHM.", "Physlib reference: Physlib.ClassicalMechanics.HarmonicOscillator"]
  }

#check DampedParams
#check moduleMetadata

end
end DampedOscillator
end Systems
end MechLib
