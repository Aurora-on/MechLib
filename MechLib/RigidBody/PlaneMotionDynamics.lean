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
namespace RigidBody
namespace PlaneMotionDynamics

open MechLib.Spec
open MechLib.Units
open MechLib.SI

noncomputable section

/-! Course-layer module for `rigidbody.plane_motion_dynamics`.

Spec topic id: `rigidbody.plane_motion_dynamics`. -/
/-- Plane-motion kinetic-energy decomposition. -/
structure PlaneMotionEnergy where
  translational : MechLib.SI.Energy
  rotational : MechLib.SI.Energy
  total : MechLib.SI.Energy

/-- Typed plane-motion kinetic energy `T = 1/2 m v_G^2 + 1/2 I_G omega^2`. -/
def PlaneMotionKineticEnergy
    (m : MechLib.SI.Mass) (vG : MechLib.SI.Speed)
    (I : MechLib.SI.MomentOfInertia) (omega : MechLib.SI.AngularVelocity) :
    MechLib.SI.Energy :=
  MechLib.Mechanics.WorkEnergy.kineticEnergy1D m vG
    + MechLib.Mechanics.Rotation.rotationalKineticEnergy I omega

/-- Translational part of rigid-body plane-motion kinetic energy. -/
def TranslationalKineticEnergy
    (m : MechLib.SI.Mass) (vG : MechLib.SI.Speed) : MechLib.SI.Energy :=
  MechLib.Mechanics.WorkEnergy.kineticEnergy1D m vG

/-- Rotational part of rigid-body plane-motion kinetic energy. -/
def RotationalKineticEnergyAboutCenter
    (I : MechLib.SI.MomentOfInertia) (omega : MechLib.SI.AngularVelocity) :
    MechLib.SI.Energy :=
  MechLib.Mechanics.Rotation.rotationalKineticEnergy I omega

/-- Plane-motion energy residual. -/
def PlaneMotionEnergyResidual (e : PlaneMotionEnergy) : Prop :=
  e.total = e.translational + e.rotational

/-- Plane-motion energy residual expands to translational plus rotational energy. -/
theorem planeMotionEnergyResidual_course_form (e : PlaneMotionEnergy) :
    PlaneMotionEnergyResidual e = (e.total = e.translational + e.rotational) := rfl

theorem planeMotionKineticEnergy_eq
    (m : MechLib.SI.Mass) (vG : MechLib.SI.Speed)
    (I : MechLib.SI.MomentOfInertia) (omega : MechLib.SI.AngularVelocity) :
    PlaneMotionKineticEnergy m vG I omega =
      MechLib.Mechanics.WorkEnergy.kineticEnergy1D m vG
        + MechLib.Mechanics.Rotation.rotationalKineticEnergy I omega := rfl

/-- Plane-motion kinetic energy expands to translational plus rotational value terms. -/
theorem planeMotionKineticEnergy_to_value_equation
    (m : MechLib.SI.Mass) (vG : MechLib.SI.Speed)
    (I : MechLib.SI.MomentOfInertia) (omega : MechLib.SI.AngularVelocity) :
    (PlaneMotionKineticEnergy m vG I omega).val =
      (1 / 2 : ℝ) * m.val * vG.val ^ 2 + (1 / 2 : ℝ) * I.val * omega.val ^ 2 := by
  simp [PlaneMotionKineticEnergy, MechLib.Mechanics.WorkEnergy.kineticEnergy1D,
    MechLib.Mechanics.Rotation.rotationalKineticEnergy]
  ring

/-- Extract the typed total-energy equation from the plane-motion energy residual. -/
theorem planeMotionEnergyResidual_to_value_equation
    {e : PlaneMotionEnergy} (h : PlaneMotionEnergyResidual e) :
    e.total.val = e.translational.val + e.rotational.val := by
  simpa [PlaneMotionEnergyResidual] using congrArg MechLib.Units.Quantity.val h

/-- Exported module metadata for this course-layer wrapper. -/
def moduleMetadata : ModuleMetadata :=
  {
    modulePath := "MechLib.RigidBody.PlaneMotionDynamics",
    topicId := "rigidbody.plane_motion_dynamics",
    status := .interface,
    trustLevel := .interface,
    conceptIds := ["concept.kinetic_energy"],
    lawSchemaIds := [],
    problemSchemaIds := [],
    exampleProblems := ["Rolling body plane motion planning", "Rigid-body kinetic-energy decomposition"],
    notes := ["Typed API: TranslationalKineticEnergy, RotationalKineticEnergyAboutCenter, PlaneMotionKineticEnergy and PlaneMotionEnergyResidual use Energy, Mass, Speed, MomentOfInertia, AngularVelocity."]
  }

#check PlaneMotionEnergy
#check PlaneMotionKineticEnergy
#check planeMotionKineticEnergy_to_value_equation
#check moduleMetadata

end
end PlaneMotionDynamics
end RigidBody
end MechLib
