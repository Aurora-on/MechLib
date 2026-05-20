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
import MechLib.Statics.ForceSystem

set_option linter.dupNamespace false
set_option linter.unusedVariables false

namespace MechLib
namespace Statics
namespace Truss

open MechLib.Spec
open MechLib.Units
open MechLib.SI

noncomputable section

/-! Course-layer module for `statics.truss`.

Spec topic id: `statics.truss`. -/
/-- Truss member between two joints with an axial force unknown. -/
structure TrussMember where
  startJoint : String
  endJoint : String
  axialForce : MechLib.SI.Force

/-- Joint equilibrium schema for truss modeling. -/
def JointEquilibriumSchema (incidentForces : List (MechLib.SI.VecForce 3)) : Prop :=
  incidentForces ≠ []

/-- Typed truss joint with externally applied forces and unknown member forces. -/
structure TrussJoint where
  name : String
  externalForces : List (MechLib.SI.VecForce 3)
  memberForces : List (MechLib.SI.VecForce 3)

/-- Truss joint equilibrium residual using the typed resultant force helper. -/
def TrussJointEquilibrium (joint : TrussJoint) : Prop :=
  ForceSystem.sumForces (joint.externalForces ++ joint.memberForces) = 0

theorem trussJointEquilibrium_iff (joint : TrussJoint) :
    TrussJointEquilibrium joint
      ↔ ForceSystem.sumForces (joint.externalForces ++ joint.memberForces) = 0 :=
  Iff.rfl

/-- Exported module metadata for this course-layer wrapper. -/
def moduleMetadata : ModuleMetadata :=
  {
    modulePath := "MechLib.Statics.Truss",
    topicId := "statics.truss",
    status := .interface,
    trustLevel := .example,
    conceptIds := ["concept.force_system"],
    lawSchemaIds := ["law.statics.planar_force_system_equilibrium"],
    problemSchemaIds := ["problem.statics.planar_equilibrium"],
    exampleProblems := ["Method of joints for a planar truss"],
    notes := ["Typed API: TrussJoint, TrussJointEquilibrium; planar truss problem-template schema."]
  }

#check TrussMember
#check TrussJointEquilibrium
#check moduleMetadata

end
end Truss
end Statics
end MechLib
