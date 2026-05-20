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
namespace Gyroscope

open MechLib.Spec
open MechLib.Units
open MechLib.SI

noncomputable section

/-! Course-layer module for `rigidbody.gyroscope`.

Spec topic id: `rigidbody.gyroscope`. -/
/-- Gyroscope state for precession planning. -/
structure GyroscopeState where
  spinAngularMomentum : MechLib.SI.VecAngularMomentum 3
  externalMoment : MechLib.SI.VecTorque 3
  precessionRate : MechLib.SI.AngularVelocity

/-- Gyroscopic precession schema placeholder. -/
def GyroscopePrecessionSchema (state : GyroscopeState) : Prop :=
  ∀ i, state.externalMoment.val i = state.precessionRate.val * state.spinAngularMomentum.val i

/-- Typed precession moment `M = Ω L` in the aligned-axis approximation. -/
def GyroscopicPrecessionMoment
    (precessionRate : MechLib.SI.AngularVelocity)
    (spinAngularMomentum : MechLib.SI.VecAngularMomentum 3) : MechLib.SI.VecTorque 3 :=
  MechLib.Units.VecQuantity.cast
    (precessionRate * spinAngularMomentum)
    MechLib.SI.angularVelocity_plus_angularMomentum_eq_torque

/-- Typed gyroscopic approximation residual. -/
def GyroscopicApproximation (state : GyroscopeState) : Prop :=
  state.externalMoment =
    GyroscopicPrecessionMoment state.precessionRate state.spinAngularMomentum

theorem gyroscopicApproximation_iff (state : GyroscopeState) :
    GyroscopicApproximation state
      ↔ state.externalMoment =
        GyroscopicPrecessionMoment state.precessionRate state.spinAngularMomentum :=
  Iff.rfl

/-- Exported module metadata for this course-layer wrapper. -/
def moduleMetadata : ModuleMetadata :=
  {
    modulePath := "MechLib.RigidBody.Gyroscope",
    topicId := "rigidbody.gyroscope",
    status := .interface,
    trustLevel := .example,
    conceptIds := ["concept.moment"],
    lawSchemaIds := ["law.dynamics.angular_momentum_conservation"],
    problemSchemaIds := [],
    exampleProblems := ["Gyroscope precession model"],
    notes := ["Typed API: GyroscopeState, GyroscopicPrecessionMoment, GyroscopicApproximation; value-level GyroscopePrecessionSchema retained as schema."]
  }

#check GyroscopeState
#check GyroscopicApproximation
#check moduleMetadata

end
end Gyroscope
end RigidBody
end MechLib
