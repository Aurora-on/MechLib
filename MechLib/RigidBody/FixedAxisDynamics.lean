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
namespace FixedAxisDynamics

open MechLib.Spec
open MechLib.Units
open MechLib.SI

noncomputable section

/-! Course-layer module for `rigidbody.fixed_axis_dynamics`.

Spec topic id: `rigidbody.fixed_axis_dynamics`. -/
/-- Typed fixed-axis torque `tau = I alpha`. -/
def FixedAxisTorque
    (I : MechLib.SI.MomentOfInertia) (alpha : MechLib.SI.AngularAcceleration) :
    MechLib.SI.Torque :=
  MechLib.Units.Quantity.cast (I * alpha) MechLib.SI.moi_plus_angularAcceleration_eq_torque

/-- Fixed-axis dynamics residual `tau = I alpha`. -/
def FixedAxisDynamicsResidual
    (tau : MechLib.SI.Torque) (I : MechLib.SI.MomentOfInertia)
    (alpha : MechLib.SI.AngularAcceleration) : Prop :=
  tau = FixedAxisTorque I alpha

theorem fixedAxisDynamicsResidual_iff
    (tau : MechLib.SI.Torque) (I : MechLib.SI.MomentOfInertia)
    (alpha : MechLib.SI.AngularAcceleration) :
    FixedAxisDynamicsResidual tau I alpha ↔ tau = FixedAxisTorque I alpha :=
  Iff.rfl

/-- Fixed-axis torque expands to the scalar value equation `tau = I alpha`. -/
theorem fixedAxisTorque_to_value_equation
    (I : MechLib.SI.MomentOfInertia) (alpha : MechLib.SI.AngularAcceleration) :
    (FixedAxisTorque I alpha).val = I.val * alpha.val := by
  simp [FixedAxisTorque]

/-- Extract the scalar equation from the fixed-axis dynamics residual. -/
theorem fixedAxisDynamicsResidual_to_value_equation
    {tau : MechLib.SI.Torque} {I : MechLib.SI.MomentOfInertia}
    {alpha : MechLib.SI.AngularAcceleration}
    (h : FixedAxisDynamicsResidual tau I alpha) :
    tau.val = I.val * alpha.val := by
  simpa [FixedAxisDynamicsResidual, FixedAxisTorque] using congrArg MechLib.Units.Quantity.val h

/-- Exported module metadata for this course-layer wrapper. -/
def moduleMetadata : ModuleMetadata :=
  {
    modulePath := "MechLib.RigidBody.FixedAxisDynamics",
    topicId := "rigidbody.fixed_axis_dynamics",
    status := .schema,
    trustLevel := .interface,
    conceptIds := ["concept.moment"],
    lawSchemaIds := ["law.dynamics.angular_momentum_conservation"],
    problemSchemaIds := [],
    exampleProblems := ["Pulley or disk about a fixed axle"],
    notes := ["Typed API: FixedAxisTorque and FixedAxisDynamicsResidual use Torque, MomentOfInertia, AngularAcceleration."]
  }

#check FixedAxisDynamicsResidual
#check FixedAxisTorque
#check fixedAxisTorque_to_value_equation
#check fixedAxisDynamicsResidual_to_value_equation
#check moduleMetadata

end
end FixedAxisDynamics
end RigidBody
end MechLib
