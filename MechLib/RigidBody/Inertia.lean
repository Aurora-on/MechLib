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
namespace Inertia

open MechLib.Spec
open MechLib.Units
open MechLib.SI

noncomputable section

/-! Course-layer module for `rigidbody.inertia`.

Spec topic id: `rigidbody.inertia`. -/
/-- Course-layer alias for inertia tensors. -/
abbrev InertiaTensor := MechLib.Mechanics.Rotation.InertiaTensor

/-- Principal moments of inertia. -/
structure PrincipalMoments where
  I1 : MechLib.SI.MomentOfInertia
  I2 : MechLib.SI.MomentOfInertia
  I3 : MechLib.SI.MomentOfInertia

/-- Principal moments are physically admissible when their scalar values are nonnegative. -/
def PrincipalMomentsAdmissible (I : PrincipalMoments) : Prop :=
  0 ≤ I.I1.val ∧ 0 ≤ I.I2.val ∧ 0 ≤ I.I3.val

/-- Moment of inertia of a point mass at distance `r` from the axis. -/
def PointMassMomentOfInertia
    (m : MechLib.SI.Mass) (r : MechLib.SI.Length) : MechLib.SI.MomentOfInertia :=
  m * (r ** 2)

/-- Center moment of inertia of a slender rod, `I = (1/12) m L^2`. -/
def SlenderRodMomentOfInertiaCenter
    (m : MechLib.SI.Mass) (L : MechLib.SI.Length) : MechLib.SI.MomentOfInertia :=
  (1 / 12 : ℝ) • (m * (L ** 2))

/-- Radius-of-gyration relation `I = m k^2`, stated as a typed scalar residual. -/
def RadiusOfGyrationRelation
    (I : MechLib.SI.MomentOfInertia) (m : MechLib.SI.Mass) (k : MechLib.SI.Length) : Prop :=
  I.val = m.val * k.val ^ 2

/-- Course-level parallel-axis theorem schema. -/
def ParallelAxisTheorem
    (I Icm : MechLib.SI.MomentOfInertia) (m : MechLib.SI.Mass) (d : MechLib.SI.Length) :
    Prop :=
  I = MechLib.Mechanics.Rotation.parallelAxis Icm m d

/-- Existing verified parallel-axis API is visible through the course-layer module. -/
theorem parallel_axis_theorem_verified
    (Icm : MechLib.SI.MomentOfInertia) (m : MechLib.SI.Mass) (d : MechLib.SI.Length) :
    MechLib.Mechanics.Rotation.parallelAxis Icm m d = Icm + m * (d ** 2) := by
  simpa using MechLib.Mechanics.Rotation.parallel_axis_theorem Icm m d

theorem parallelAxisTheorem_iff
    (I Icm : MechLib.SI.MomentOfInertia) (m : MechLib.SI.Mass) (d : MechLib.SI.Length) :
    ParallelAxisTheorem I Icm m d
      ↔ I = MechLib.Mechanics.Rotation.parallelAxis Icm m d :=
  Iff.rfl

/-- Point-mass inertia unfolds to `m r^2` at value level. -/
theorem pointMassMomentOfInertia_to_value_equation
    (m : MechLib.SI.Mass) (r : MechLib.SI.Length) :
    (PointMassMomentOfInertia m r).val = m.val * r.val ^ 2 := by
  simp [PointMassMomentOfInertia]

/-- Slender-rod center inertia unfolds to `(1/12) m L^2` at value level. -/
theorem slenderRodMomentOfInertiaCenter_to_value_equation
    (m : MechLib.SI.Mass) (L : MechLib.SI.Length) :
    (SlenderRodMomentOfInertiaCenter m L).val = (1 / 12 : ℝ) * m.val * L.val ^ 2 := by
  simp [SlenderRodMomentOfInertiaCenter]
  ring

/-- Extract the scalar equation from the radius-of-gyration relation. -/
theorem radiusOfGyrationRelation_to_value_equation
    {I : MechLib.SI.MomentOfInertia} {m : MechLib.SI.Mass} {k : MechLib.SI.Length}
    (h : RadiusOfGyrationRelation I m k) :
    I.val = m.val * k.val ^ 2 :=
  h

/-- Exported module metadata for this course-layer wrapper. -/
def moduleMetadata : ModuleMetadata :=
  {
    modulePath := "MechLib.RigidBody.Inertia",
    topicId := "rigidbody.inertia",
    status := .verified,
    trustLevel := .core,
    conceptIds := [],
    lawSchemaIds := [],
    problemSchemaIds := [],
    exampleProblems := ["Parallel-axis inertia calculation", "Point-mass or slender-rod inertia calculation"],
    notes := ["Typed API: PrincipalMoments, PointMassMomentOfInertia, SlenderRodMomentOfInertiaCenter, ParallelAxisTheorem; wrapper for Mechanics.Rotation inertia API.", "Physlib reference: Physlib.ClassicalMechanics.RigidBody.Basic"]
  }

#check InertiaTensor
#check ParallelAxisTheorem
#check PointMassMomentOfInertia
#check pointMassMomentOfInertia_to_value_equation
#check SlenderRodMomentOfInertiaCenter
#check moduleMetadata

end
end Inertia
end RigidBody
end MechLib
