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
namespace WorkEnergy

open MechLib.Spec
open MechLib.Units
open MechLib.SI

noncomputable section

/-! Course-layer module for `dynamics.work_energy`.

Spec topic id: `dynamics.work_energy`. -/
/-- Work-energy balance schema using existing energy quantities. -/
def WorkEnergyBalance (Wnet K2 K1 : MechLib.SI.Energy) : Prop :=
  Wnet = K2 - K1

/-- Typed work by a force through a displacement. -/
def Work {n : ℕ} (F : MechLib.SI.VecForce n) (s : MechLib.SI.VecLength n) : MechLib.SI.Energy :=
  MechLib.Mechanics.WorkEnergy.work F s

/-- Typed one-dimensional kinetic energy. -/
def KineticEnergy1D (m : MechLib.SI.Mass) (v : MechLib.SI.Speed) : MechLib.SI.Energy :=
  MechLib.Mechanics.WorkEnergy.kineticEnergy1D m v

/-- Typed rotational kinetic energy `1/2 I omega^2`. -/
def RotationalKineticEnergy
    (I : MechLib.SI.MomentOfInertia) (omega : MechLib.SI.AngularVelocity) : MechLib.SI.Energy :=
  MechLib.Mechanics.Rotation.rotationalKineticEnergy I omega

/-- Torque multiplied by a dimensionless angular displacement has energy dimension. -/
theorem torque_angle_eq_energy :
    MechLib.SI.torqueDim + (0 : MechLib.Units.Dim) = MechLib.SI.energyDim := by
  native_decide

/-- Work of a constant torque through a dimensionless angular displacement. -/
def ConstantTorqueWork
    (tau : MechLib.SI.Torque) (theta : MechLib.SI.PhysAngle) : MechLib.SI.Energy :=
  MechLib.Units.Quantity.cast (tau * theta) torque_angle_eq_energy

/-- Work-energy balance expands to the canonical net-work relation. -/
theorem workEnergyBalance_course_form (Wnet K2 K1 : MechLib.SI.Energy) :
    WorkEnergyBalance Wnet K2 K1 = (Wnet = K2 - K1) := rfl

/-- Existing verified work-energy theorem is available through the course layer. -/
theorem work_energy_theorem_core_verified
    (Wnet K2 K1 : MechLib.SI.Energy) (h : WorkEnergyBalance Wnet K2 K1) :
    K2 = K1 + Wnet := by
  exact MechLib.Mechanics.WorkEnergy.work_energy_theorem_core Wnet K2 K1 h

/-- Course-layer wrapper for the verified kinetic-energy change formula. -/
theorem kineticEnergy_change_formula_verified (m : MechLib.SI.Mass) (v2 v1 : MechLib.SI.Speed) :
    KineticEnergy1D m v2 - KineticEnergy1D m v1 =
      (1 / 2 : ℝ) •
        MechLib.Units.Quantity.cast (m * ((v2 ** 2) - (v1 ** 2)))
          MechLib.SI.mass_two_speed_eq_energy := by
  simpa [KineticEnergy1D] using
    MechLib.Mechanics.WorkEnergy.kineticEnergy_change_formula m v2 v1

/-- Rotational kinetic energy unfolds to the typed `1/2 I omega^2` formula. -/
theorem rotationalKineticEnergy_to_value_equation
    (I : MechLib.SI.MomentOfInertia) (omega : MechLib.SI.AngularVelocity) :
    (RotationalKineticEnergy I omega).val = (1 / 2 : ℝ) * I.val * omega.val ^ 2 := by
  simp [RotationalKineticEnergy, MechLib.Mechanics.Rotation.rotationalKineticEnergy]
  ring

/-- Constant torque work unfolds to the scalar product `tau * theta`. -/
theorem constantTorqueWork_to_value_equation
    (tau : MechLib.SI.Torque) (theta : MechLib.SI.PhysAngle) :
    (ConstantTorqueWork tau theta).val = tau.val * theta.val := by
  simp [ConstantTorqueWork]

example {n : ℕ} (F : MechLib.SI.VecForce n) (s : MechLib.SI.VecLength n) :
    Work F s = MechLib.Mechanics.WorkEnergy.work F s := rfl

/-- Exported module metadata for this course-layer wrapper. -/
def moduleMetadata : ModuleMetadata :=
  {
    modulePath := "MechLib.Dynamics.WorkEnergy",
    topicId := "dynamics.work_energy",
    status := .verified,
    trustLevel := .core,
    conceptIds := ["concept.kinetic_energy", "concept.potential_energy"],
    lawSchemaIds := ["law.dynamics.work_energy_theorem"],
    problemSchemaIds := ["problem.dynamics.work_energy_find_speed"],
    exampleProblems := ["Use work-energy theorem to find speed"],
    notes := ["Typed API: Work, KineticEnergy1D, WorkEnergyBalance; wrapper for Mechanics.WorkEnergy."]
  }

#check WorkEnergyBalance
#check KineticEnergy1D
#check RotationalKineticEnergy
#check rotationalKineticEnergy_to_value_equation
#check ConstantTorqueWork
#check constantTorqueWork_to_value_equation
#check moduleMetadata

end
end WorkEnergy
end Dynamics
end MechLib
