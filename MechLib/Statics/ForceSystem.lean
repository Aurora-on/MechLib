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
namespace Statics
namespace ForceSystem

open MechLib.Spec
open MechLib.Units
open MechLib.SI

noncomputable section

/-! Course-layer module for `statics.force_system`.

Spec topic id: `statics.force_system`. -/
/-- A finite force system with application points. -/
structure ForceSystem where
  forces : List (MechLib.SI.VecForce 3)
  applicationPoints : List (MechLib.SI.VecLength 3)

/-- One applied force with its point of application. -/
structure ForceApplication where
  point : MechLib.SI.VecLength 3
  force : MechLib.SI.VecForce 3

/-- Sum a list of force vectors. -/
def sumForces : List (MechLib.SI.VecForce 3) → MechLib.SI.VecForce 3
  | [] => 0
  | F :: Fs => F + sumForces Fs

/-- Resultant force of a finite force system. -/
def ResultantForce (system : ForceSystem) : MechLib.SI.VecForce 3 :=
  sumForces system.forces

/-- Moment about the origin from one force application. -/
def MomentAboutOrigin (app : ForceApplication) : MechLib.SI.VecTorque 3 :=
  MechLib.Mechanics.Rotation.torque app.point app.force

/-- Sum moments of paired application points and forces, ignoring malformed tails. -/
def sumMomentsAboutOrigin :
    List (MechLib.SI.VecLength 3) → List (MechLib.SI.VecForce 3) → MechLib.SI.VecTorque 3
  | p :: ps, F :: Fs => MechLib.Mechanics.Rotation.torque p F + sumMomentsAboutOrigin ps Fs
  | _, _ => 0

/-- Resultant moment about the origin for a force system. -/
def ResultantMomentAboutOrigin (system : ForceSystem) : MechLib.SI.VecTorque 3 :=
  sumMomentsAboutOrigin system.applicationPoints system.forces

/-- Equivalent force systems share resultant force and moment about the origin. -/
def EquivalentForceSystem (a b : ForceSystem) : Prop :=
  ResultantForce a = ResultantForce b
    ∧ ResultantMomentAboutOrigin a = ResultantMomentAboutOrigin b

/-- Resultant-force schema supplied by a modeler or solver. -/
def ResultantForceSchema (system : ForceSystem) (resultant : MechLib.SI.VecForce 3) : Prop :=
  system.forces.length = system.applicationPoints.length ∧ (system.forces = [] → resultant = 0)

/-- The force-system schema records one application point for each force. -/
theorem resultantForceSchema_length (system : ForceSystem) (resultant : MechLib.SI.VecForce 3)
    (h : ResultantForceSchema system resultant) :
    system.forces.length = system.applicationPoints.length :=
  h.1

@[simp] theorem sumForces_nil : sumForces [] = (0 : MechLib.SI.VecForce 3) := rfl

@[simp] theorem resultantForce_empty (points : List (MechLib.SI.VecLength 3)) :
    ResultantForce { forces := [], applicationPoints := points } = 0 := rfl

theorem equivalentForceSystem_iff (a b : ForceSystem) :
    EquivalentForceSystem a b
      ↔ ResultantForce a = ResultantForce b
        ∧ ResultantMomentAboutOrigin a = ResultantMomentAboutOrigin b :=
  Iff.rfl

/-- Exported module metadata for this course-layer wrapper. -/
def moduleMetadata : ModuleMetadata :=
  {
    modulePath := "MechLib.Statics.ForceSystem",
    topicId := "statics.force_system",
    status := .interface,
    trustLevel := .interface,
    conceptIds := ["concept.force_system"],
    lawSchemaIds := ["law.statics.planar_force_system_equilibrium"],
    problemSchemaIds := ["problem.statics.planar_equilibrium"],
    exampleProblems := ["Free-body diagram with applied forces"],
    notes := ["Typed API: ForceApplication, ResultantForce, ResultantMomentAboutOrigin, EquivalentForceSystem; schema for collections of applied forces."]
  }

#check ForceSystem
#check ResultantForce
#check moduleMetadata

end
end ForceSystem
end Statics
end MechLib
