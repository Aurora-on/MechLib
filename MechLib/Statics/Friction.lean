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
namespace Friction

open MechLib.Spec
open MechLib.Units
open MechLib.SI

noncomputable section

/-! Course-layer module for `statics.friction`.

Spec topic id: `statics.friction`. -/
/-- Coulomb friction parameters and force components. -/
structure CoulombFriction where
  coefficient : MechLib.SI.Dimensionless
  normalForce : MechLib.SI.Force
  tangentialForce : MechLib.SI.Force

/-- Limiting-friction inequality schema. -/
def FrictionConeSchema (f : CoulombFriction) : Prop :=
  |f.tangentialForce.val| ≤ f.coefficient.val * |f.normalForce.val|

/-- Static friction is within the Coulomb cone. -/
def IsAdmissibleStaticFriction := FrictionConeSchema

/-- Kinetic Coulomb-friction magnitude law, stated as a typed scalar relation. -/
def KineticFrictionLaw
    (coefficient : MechLib.SI.Dimensionless)
    (normalForce frictionMagnitude : MechLib.SI.Force) : Prop :=
  frictionMagnitude.val = coefficient.val * |normalForce.val|

/-- Static friction bound in scalar magnitude form. -/
def StaticFrictionBound
    (coefficient : MechLib.SI.Dimensionless)
    (normalForce frictionMagnitude : MechLib.SI.Force) : Prop :=
  |frictionMagnitude.val| ≤ coefficient.val * |normalForce.val|

/-- Limiting static friction equality at impending slip. -/
def StaticFrictionLimitingLaw
    (coefficient : MechLib.SI.Dimensionless)
    (normalForce frictionMagnitude : MechLib.SI.Force) : Prop :=
  |frictionMagnitude.val| = coefficient.val * |normalForce.val|

/-- Capstan / belt-friction equality schema for impending slip. -/
def CapstanTensionRatio
    (coefficient wrapAngle : MechLib.SI.Dimensionless)
    (tightSide slackSide : MechLib.SI.Force) : Prop :=
  tightSide.val = slackSide.val * Real.exp (coefficient.val * wrapAngle.val)

/-- Capstan / belt-friction admissible upper bound. -/
def CapstanTensionBound
    (coefficient wrapAngle : MechLib.SI.Dimensionless)
    (tightSide slackSide : MechLib.SI.Force) : Prop :=
  tightSide.val ≤ slackSide.val * Real.exp (coefficient.val * wrapAngle.val)

theorem frictionConeSchema_iff (f : CoulombFriction) :
    FrictionConeSchema f ↔ |f.tangentialForce.val| ≤ f.coefficient.val * |f.normalForce.val| :=
  Iff.rfl

/-- Extract the scalar equality from the kinetic friction law. -/
theorem kineticFrictionLaw_to_value_equation
    {coefficient : MechLib.SI.Dimensionless}
    {normalForce frictionMagnitude : MechLib.SI.Force}
    (h : KineticFrictionLaw coefficient normalForce frictionMagnitude) :
    frictionMagnitude.val = coefficient.val * |normalForce.val| :=
  h

/-- Extract the scalar inequality from the static friction bound. -/
theorem staticFrictionBound_to_value_inequality
    {coefficient : MechLib.SI.Dimensionless}
    {normalForce frictionMagnitude : MechLib.SI.Force}
    (h : StaticFrictionBound coefficient normalForce frictionMagnitude) :
    |frictionMagnitude.val| ≤ coefficient.val * |normalForce.val| :=
  h

/-- Extract the scalar equality from the limiting static friction law. -/
theorem staticFrictionLimitingLaw_to_value_equation
    {coefficient : MechLib.SI.Dimensionless}
    {normalForce frictionMagnitude : MechLib.SI.Force}
    (h : StaticFrictionLimitingLaw coefficient normalForce frictionMagnitude) :
    |frictionMagnitude.val| = coefficient.val * |normalForce.val| :=
  h

/-- Extract the scalar equality from the capstan tension-ratio schema. -/
theorem capstanTensionRatio_to_value_equation
    {coefficient wrapAngle : MechLib.SI.Dimensionless}
    {tightSide slackSide : MechLib.SI.Force}
    (h : CapstanTensionRatio coefficient wrapAngle tightSide slackSide) :
    tightSide.val = slackSide.val * Real.exp (coefficient.val * wrapAngle.val) :=
  h

/-- Extract the scalar inequality from the capstan tension-bound schema. -/
theorem capstanTensionBound_to_value_inequality
    {coefficient wrapAngle : MechLib.SI.Dimensionless}
    {tightSide slackSide : MechLib.SI.Force}
    (h : CapstanTensionBound coefficient wrapAngle tightSide slackSide) :
    tightSide.val ≤ slackSide.val * Real.exp (coefficient.val * wrapAngle.val) :=
  h

/-- Exported module metadata for this course-layer wrapper. -/
def moduleMetadata : ModuleMetadata :=
  {
    modulePath := "MechLib.Statics.Friction",
    topicId := "statics.friction",
    status := .interface,
    trustLevel := .interface,
    conceptIds := ["concept.force_system"],
    lawSchemaIds := ["law.statics.planar_force_system_equilibrium"],
    problemSchemaIds := ["problem.statics.planar_equilibrium"],
    exampleProblems := ["Block on rough incline", "Capstan belt-friction inequality"],
    notes := ["Typed API: Dimensionless coefficient, Force-valued normal/tangential components; Coulomb and capstan friction interfaces."]
  }

#check CoulombFriction
#check FrictionConeSchema
#check KineticFrictionLaw
#check kineticFrictionLaw_to_value_equation
#check StaticFrictionBound
#check staticFrictionBound_to_value_inequality
#check CapstanTensionRatio
#check capstanTensionRatio_to_value_equation
#check moduleMetadata

end
end Friction
end Statics
end MechLib
