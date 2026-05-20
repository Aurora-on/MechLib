import MechLib.Units.BridgeLemmas
import MechLib.Kinematics.PointMotion
import MechLib.Dynamics.WorkEnergy
import MechLib.Analytical.LagrangeEquation

/-!
Small proof-friendly examples for tactic and LLM proof-agent smoke tests.

These examples intentionally use existing verified declarations and safe bridge
lemmas.  They do not introduce new physics laws.
-/

namespace MechLib
namespace Examples
namespace ProofFriendlyExamples

open MechLib.Units

noncomputable section

/-- Dimension bridge smoke test: `Speed × Time -> Length` reduces by `simp`. -/
example (v : SI.Speed) (t : SI.Time) :
    (Quantity.cast (v * t) SI.speed_time_eq_length).val = v.val * t.val := by
  simp

/-- Kinematics smoke test: use the course-layer wrapper for constant acceleration. -/
example
    (v v0 : SI.Speed) (a : SI.Acceleration) (t : SI.Time)
    (hv : v = Mechanics.Kinematics.velocityConstAccel v0 a t) :
    Quantity.cast (v0 * t) SI.speed_time_eq_length
      + (1 / 2 : ℝ) •
        Quantity.cast (a * (t ** 2)) SI.acceleration_two_time_eq_length
        = Mechanics.Kinematics.displacementConstAccelForm2 v0 v t := by
  simpa using
    Kinematics.PointMotion.displacement_forms_equiv_course_form v v0 a t hv

/-- Work-energy smoke test: reuse the verified kinetic-energy change wrapper. -/
example (m : SI.Mass) (v2 v1 : SI.Speed) :
    Dynamics.WorkEnergy.KineticEnergy1D m v2
        - Dynamics.WorkEnergy.KineticEnergy1D m v1 =
      (1 / 2 : ℝ) •
        Quantity.cast (m * ((v2 ** 2) - (v1 ** 2)))
          SI.mass_two_speed_eq_energy := by
  simpa using Dynamics.WorkEnergy.kineticEnergy_change_formula_verified m v2 v1

/-- Analytical mechanics smoke test: reuse the existing 1D EL/Newton bridge. -/
example
    (m : SI.Mass) (dVdx : SI.Length → SI.Force)
    (x : Mechanics.Kinematics.ScalarTrajectory)
    (a : Mechanics.Kinematics.ScalarAccelerationField) :
    Analytical.LagrangeEquation.LagrangeEquationSchema m dVdx x a
      ↔ Analytical.LagrangeEquation.SatisfiesNewtonForm1D m dVdx x a := by
  simpa using
    Analytical.LagrangeEquation.eulerLagrange_iff_newton_course_form m dVdx x a

end
end ProofFriendlyExamples
end Examples
end MechLib
