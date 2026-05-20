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

set_option linter.dupNamespace false
set_option linter.unusedVariables false

namespace MechLib
namespace Systems
namespace RollingDisk

open MechLib.Spec
open MechLib.Units
open MechLib.SI
open _root_.MechLib.Analytical.GeneralizedCoordinates

noncomputable section

/-! Course-layer module for `systems.rolling_disk`.

Spec topic id: `systems.rolling_disk`. -/
/-- Rolling disk parameters. -/
structure Params where
  mass : MechLib.SI.Mass
  radius : MechLib.SI.Length
  inertiaAboutAxis : MechLib.SI.MomentOfInertia

/-- Rolling disk state. -/
structure RollingDiskState where
  centerVelocity : MechLib.SI.Speed
  angularVelocity : MechLib.SI.AngularVelocity
  radius : MechLib.SI.Length

/-- Generalized coordinates `(x, y, phi)` for planar rolling disk planning. -/
def generalizedCoordinates : CoordSpec :=
  {
    dof := 3,
    coordName := fun i =>
      if i = 0 then "x" else if i = 1 then "y" else "phi",
    coordDim := fun i => if i = 2 then (0 : Dim) else MechLib.SI.lengthDim
  }

/-- No-slip rolling residual at the scalar-value level: `v = omega r`. -/
def RollingNoSlipResidual (state : RollingDiskState) : Prop :=
  state.centerVelocity.val = state.angularVelocity.val * state.radius.val

/-- No-slip constraint schema for value-level generalized speeds. -/
def noSlipConstraint (radius xDot phiDot : ℝ) : Prop :=
  xDot = radius * phiDot

/-- Nonholonomic rolling constraint schema in Pfaff-style velocity form. -/
def nonholonomicConstraintSchema (radius xDot yDot phiDot heading : ℝ) : Prop :=
  xDot = radius * phiDot * Real.cos heading
    ∧ yDot = radius * phiDot * Real.sin heading

/-- Scalar rolling kinetic energy `T = 1/2 m v² + 1/2 I ω²`. -/
def rollingKineticEnergy (params : Params) (centerSpeed angularVelocity : ℝ) : ℝ :=
  (1 / 2 : ℝ) * params.mass.val * centerSpeed ^ 2
    + (1 / 2 : ℝ) * params.inertiaAboutAxis.val * angularVelocity ^ 2

example (state : RollingDiskState) :
    RollingNoSlipResidual state = (state.centerVelocity.val = state.angularVelocity.val * state.radius.val) := rfl

/-- Exported module metadata for this course-layer wrapper. -/
def moduleMetadata : ModuleMetadata :=
  {
    modulePath := "MechLib.Systems.RollingDisk",
    topicId := "systems.rolling_disk",
    status := .interface,
    trustLevel := .example,
    conceptIds := ["concept.constraints", "concept.kinetic_energy"],
    lawSchemaIds := [],
    problemSchemaIds := ["problem.systems.rolling_disk_no_slip"],
    exampleProblems := ["Rolling disk no-slip constraint"],
    notes := ["schema: no-slip and nonholonomic constraints; rolling kinetic energy."]
  }

#check Params
#check moduleMetadata

end
end RollingDisk
end Systems
end MechLib
