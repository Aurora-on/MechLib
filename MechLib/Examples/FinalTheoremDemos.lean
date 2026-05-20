import MechLib.Mechanics.Kinematics
import MechLib.Mechanics.WorkEnergy
import MechLib.Mechanics.MomentumImpulse
import MechLib.Analytical.LagrangeEquation

/-!
Final checked theorem demos for presentation and project documentation.

The examples in this file show how MechLib proves small mechanics facts:
unfold typed definitions, move to `.val` when needed, use algebraic tactics, and
return to typed equalities by extensionality.  They do not introduce new physics
laws, axioms, or schema-only proof facts.
-/

namespace MechLib
namespace Examples
namespace FinalTheoremDemos

open MechLib.Units
open MechLib.SI
open MechLib.Mechanics

noncomputable section

/-! ## Demo 1: typed kinematics by definition unfolding -/

/-- Typed constant-acceleration displacement formula.

This proof mirrors the library style: use the velocity hypothesis to get a
value-level equation, unfold the typed displacement expression, and finish the
real arithmetic with `ring`. -/
theorem uniformAccelerationDisplacement_byCalculation
    (v v0 : Speed) (a : Acceleration) (t : Time)
    (hv : v = Mechanics.Kinematics.velocityConstAccel v0 a t) :
    Quantity.cast (v0 * t) SI.speed_time_eq_length
      + (1 / 2 : ℝ) •
        Quantity.cast (a * (t ** 2)) SI.acceleration_two_time_eq_length
        = Mechanics.Kinematics.displacementConstAccelForm2 v0 v t := by
  have hvVal : v.val = v0.val + (a * t).val := by
    simpa [Mechanics.Kinematics.velocityConstAccel, Quantity.cast_val]
      using congrArg Quantity.val hv
  ext
  simp [Mechanics.Kinematics.displacementConstAccelForm2, Quantity.cast_val, hvVal]
  ring

/-- Minimal typed bridge proof for `Speed × Time -> Length`. -/
theorem speedTimeCastValue_bySimp (v : Speed) (t : Time) :
    (Quantity.cast (v * t) SI.speed_time_eq_length).val = v.val * t.val := by
  simp

/-! ## Demo 2: core dynamics by definitions and value algebra -/

/-- Newton's second law is definitional in the core API. -/
theorem newtonSecondLaw_byDefinition (m : Mass) (a : Acceleration) :
    Mechanics.Dynamics.F_of m a = m * a := by
  rfl

/-- Work-energy balance proved by extracting typed quantities to real values. -/
theorem workEnergyBalance_byValueAlgebra
    (Wnet K2 K1 : Energy) (h : Wnet = K2 - K1) :
    K2 = K1 + Wnet := by
  have hVal : Wnet.val = K2.val - K1.val := by
    simpa using congrArg Quantity.val h
  have hSum : K2.val = K1.val + Wnet.val := by
    linarith [hVal]
  ext
  simpa using hSum

/-- Impulse-momentum theorem proved by the same value-level pattern. -/
theorem impulseMomentum_byValueAlgebra (p2 p1 : Momentum) (F : Force) (dt : Time)
    (h : p2 - p1 = Mechanics.MomentumImpulse.impulse F dt) :
    p2 = p1 + Mechanics.MomentumImpulse.impulse F dt := by
  have hVal : p2.val - p1.val = (Mechanics.MomentumImpulse.impulse F dt).val := by
    simpa using congrArg Quantity.val h
  have hSum : p2.val = p1.val + (Mechanics.MomentumImpulse.impulse F dt).val := by
    linarith [hVal]
  ext
  simpa using hSum

/-! ## Demo 3: dynamics to analytical mechanics bridge by residual expansion -/

/-- 1D Euler-Lagrange residual form is equivalent to the Newton-form equation.

This proof expands both residual definitions and uses real linear arithmetic on
the underlying typed force values.
-/
theorem eulerLagrangeNewtonBridge_byResidualAlgebra
    (m : Mass) (dVdx : Length → Force)
    (x : Mechanics.Kinematics.ScalarTrajectory)
    (a : Mechanics.Kinematics.ScalarAccelerationField) :
    Analytical.LagrangeEquation.LagrangeEquationSchema m dVdx x a
      ↔ Analytical.LagrangeEquation.SatisfiesNewtonForm1D m dVdx x a := by
  constructor
  · intro hEL t
    have hEL' :
        Analytical.LagrangeEquation.SatisfiesEulerLagrange1D m dVdx x a := by
      simpa [Analytical.LagrangeEquation.LagrangeEquationSchema] using hEL
    have hVal : (m * a t).val + (dVdx (x t)).val = 0 := by
      simpa [Analytical.LagrangeEquation.SatisfiesEulerLagrange1D,
        Analytical.LagrangeEquation.eulerLagrangeResidual1D]
        using congrArg Quantity.val (hEL' t)
    ext
    have hForce : (m * a t).val = -(dVdx (x t)).val := by
      linarith [hVal]
    simpa [Analytical.LagrangeEquation.SatisfiesNewtonForm1D,
      Mechanics.Dynamics.secondLaw] using hForce
  · intro hNewton t
    have hVal : (m * a t).val = -(dVdx (x t)).val := by
      simpa [Analytical.LagrangeEquation.SatisfiesNewtonForm1D,
        Mechanics.Dynamics.secondLaw]
        using congrArg Quantity.val (hNewton t)
    ext
    have hResidual : (m * a t).val + (dVdx (x t)).val = 0 := by
      linarith [hVal]
    simpa [Analytical.LagrangeEquation.LagrangeEquationSchema,
      Analytical.LagrangeEquation.SatisfiesEulerLagrange1D,
      Analytical.LagrangeEquation.eulerLagrangeResidual1D] using hResidual

#check uniformAccelerationDisplacement_byCalculation
#check speedTimeCastValue_bySimp
#check newtonSecondLaw_byDefinition
#check workEnergyBalance_byValueAlgebra
#check impulseMomentum_byValueAlgebra
#check eulerLagrangeNewtonBridge_byResidualAlgebra

end
end FinalTheoremDemos
end Examples
end MechLib
