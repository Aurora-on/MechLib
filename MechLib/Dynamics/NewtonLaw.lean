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
namespace NewtonLaw

open MechLib.Spec
open MechLib.Units
open MechLib.SI

noncomputable section

/-! Course-layer module for `dynamics.newton_law`.

Spec topic id: `dynamics.newton_law`. -/
/-- Newton second-law relation for a scalar particle model. -/
def NewtonSecondLaw (m : MechLib.SI.Mass) (a : MechLib.SI.Acceleration) (F : MechLib.SI.Force) : Prop :=
  F = MechLib.Mechanics.Dynamics.secondLaw m a

/-- Newton second-law relation stated at value level. -/
def NewtonSecondLawValueRelation
    (F : MechLib.SI.Force) (m : MechLib.SI.Mass) (a : MechLib.SI.Acceleration) : Prop :=
  F.val = m.val * a.val

/-- One-dimensional force balance written directly as the scalar equation `F = ma`. -/
def ForceBalance1D
    (Fnet : MechLib.SI.Force) (m : MechLib.SI.Mass) (a : MechLib.SI.Acceleration) : Prop :=
  Fnet.val = m.val * a.val

/-- Static one-dimensional force balance, used for zero-acceleration components. -/
def StaticForceBalance1D (Fnet : MechLib.SI.Force) : Prop :=
  Fnet.val = 0

/-- Constant-velocity one-dimensional force balance, stated as zero resultant force. -/
def ConstantVelocityForceBalance (Fnet : MechLib.SI.Force) : Prop :=
  Fnet.val = 0

/-- Weight force magnitude relation, stated at value level. -/
def WeightForceRelation
    (W : MechLib.SI.Force) (m : MechLib.SI.Mass) (g : MechLib.SI.Acceleration) : Prop :=
  W.val = m.val * g.val

/-- Modeling relation equating two one-dimensional force quantities. -/
def ForceEqualityRelation (F₁ F₂ : MechLib.SI.Force) : Prop :=
  F₁ = F₂

/-- Modeling relation for a one-dimensional signed force difference. -/
def ForceDifferenceRelation
    (Fnet Fpos Fneg : MechLib.SI.Force) : Prop :=
  Fnet.val = Fpos.val - Fneg.val

/-- Modeling relation for a two-term one-dimensional resultant force. -/
def ForceSum2Relation
    (Fnet F₁ F₂ : MechLib.SI.Force) : Prop :=
  Fnet.val = F₁.val + F₂.val

/-- Modeling relation for a three-term one-dimensional resultant force. -/
def ForceSum3Relation
    (Fnet F₁ F₂ F₃ : MechLib.SI.Force) : Prop :=
  Fnet.val = F₁.val + F₂.val + F₃.val

/-- Course-layer Newton law expands to the existing `secondLaw` definition. -/
theorem newtonSecondLaw_course_form
    (m : MechLib.SI.Mass) (a : MechLib.SI.Acceleration) (F : MechLib.SI.Force) :
    NewtonSecondLaw m a F = (F = MechLib.Mechanics.Dynamics.secondLaw m a) := rfl

/-- Existing verified Newton law is available through the course-layer module. -/
theorem newton_second_law_verified (m : MechLib.SI.Mass) (a : MechLib.SI.Acceleration) :
    MechLib.Mechanics.Dynamics.F_of m a = m * a := by
  exact MechLib.Mechanics.Dynamics.newton_second_law m a

namespace NewtonSecondLaw

/-- Extract the value-level equation from the typed Newton-second-law predicate. -/
theorem to_value_equation
    {m : MechLib.SI.Mass} {a : MechLib.SI.Acceleration} {F : MechLib.SI.Force}
    (h : NewtonSecondLaw m a F) :
    F.val = m.val * a.val := by
  simpa [NewtonSecondLaw, MechLib.Mechanics.Dynamics.secondLaw] using congrArg MechLib.Units.Quantity.val h

end NewtonSecondLaw

/-- Value-level Newton relation is definitionally the scalar equation `F.val = m.val * a.val`. -/
theorem newtonSecondLawValueRelation_iff
    (F : MechLib.SI.Force) (m : MechLib.SI.Mass) (a : MechLib.SI.Acceleration) :
    NewtonSecondLawValueRelation F m a ↔ F.val = m.val * a.val :=
  Iff.rfl

/-- One-dimensional force balance is definitionally the scalar Newton equation. -/
theorem forceBalance1D_iff_newtonValue
    (Fnet : MechLib.SI.Force) (m : MechLib.SI.Mass) (a : MechLib.SI.Acceleration) :
    ForceBalance1D Fnet m a ↔ NewtonSecondLawValueRelation Fnet m a :=
  Iff.rfl

/-- Extract the scalar equation from the one-dimensional force-balance predicate. -/
theorem forceBalance1D_to_value_equation
    {Fnet : MechLib.SI.Force} {m : MechLib.SI.Mass} {a : MechLib.SI.Acceleration}
    (h : ForceBalance1D Fnet m a) :
    Fnet.val = m.val * a.val :=
  h

/-- Static balance expands to zero net force. -/
theorem staticForceBalance1D_to_value_equation
    {Fnet : MechLib.SI.Force} (h : StaticForceBalance1D Fnet) :
    Fnet.val = 0 :=
  h

/-- Constant-velocity balance expands to zero net force. -/
theorem constantVelocityForceBalance_to_value_equation
    {Fnet : MechLib.SI.Force} (h : ConstantVelocityForceBalance Fnet) :
    Fnet.val = 0 :=
  h

/-- Extract the scalar equation from the weight-force relation. -/
theorem weightForceRelation_to_value_equation
    {W : MechLib.SI.Force} {m : MechLib.SI.Mass} {g : MechLib.SI.Acceleration}
    (h : WeightForceRelation W m g) :
    W.val = m.val * g.val :=
  h

/-- Extract equality of force values from a typed force equality. -/
theorem forceEqualityRelation_to_value_equation
    {F₁ F₂ : MechLib.SI.Force} (h : ForceEqualityRelation F₁ F₂) :
    F₁.val = F₂.val := by
  simpa [ForceEqualityRelation] using congrArg MechLib.Units.Quantity.val h

/-- Extract the scalar equation from a signed two-force difference relation. -/
theorem forceDifferenceRelation_to_value_equation
    {Fnet Fpos Fneg : MechLib.SI.Force} (h : ForceDifferenceRelation Fnet Fpos Fneg) :
    Fnet.val = Fpos.val - Fneg.val :=
  h

/-- Extract the scalar equation from a two-term resultant-force relation. -/
theorem forceSum2Relation_to_value_equation
    {Fnet F₁ F₂ : MechLib.SI.Force} (h : ForceSum2Relation Fnet F₁ F₂) :
    Fnet.val = F₁.val + F₂.val :=
  h

/-- Extract the scalar equation from a three-term resultant-force relation. -/
theorem forceSum3Relation_to_value_equation
    {Fnet F₁ F₂ F₃ : MechLib.SI.Force} (h : ForceSum3Relation Fnet F₁ F₂ F₃) :
    Fnet.val = F₁.val + F₂.val + F₃.val :=
  h

/-- Exported module metadata for this course-layer wrapper. -/
def moduleMetadata : ModuleMetadata :=
  {
    modulePath := "MechLib.Dynamics.NewtonLaw",
    topicId := "dynamics.newton_law",
    status := .verified,
    trustLevel := .core,
    conceptIds := ["concept.force_system"],
    lawSchemaIds := ["law.dynamics.newton_second_law"],
    problemSchemaIds := ["problem.dynamics.particle_dynamics"],
    exampleProblems := ["Apply F = ma"],
    notes := ["Wrapper for Mechanics.Dynamics.secondLaw."]
  }

#check NewtonSecondLaw
#check NewtonSecondLawValueRelation
#check NewtonSecondLaw.to_value_equation
#check ForceBalance1D
#check forceBalance1D_to_value_equation
#check WeightForceRelation
#check weightForceRelation_to_value_equation
#check ForceEqualityRelation
#check ForceDifferenceRelation
#check ForceSum2Relation
#check ForceSum3Relation
#check moduleMetadata

end
end NewtonLaw
end Dynamics
end MechLib
