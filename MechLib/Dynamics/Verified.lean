import Mathlib
import MechLib.Mechanics.Dynamics
import MechLib.Mechanics.WorkEnergy
import MechLib.Mechanics.MomentumImpulse
import MechLib.Mechanics.SystemDynamics

/-!
Verified theorem declarations migrated from `MechLib.Mechanics.*`.

The old `MechLib.Mechanics.*` names are compatibility abbreviations; these
course-layer declarations are the retrieval-facing theorem locations.
-/

namespace MechLib
namespace Dynamics
namespace Verified

open Units SI
open MechLib.Mechanics

noncomputable section

namespace Dynamics
open MechLib.Mechanics.Dynamics

/-- Migrated from `MechLib.Mechanics.Dynamics.newton_second_law`. -/
@[simp] theorem newton_second_law (m : Mass) (a : Acceleration) : F_of m a = m * a := by
  simpa using MechLib.Mechanics.Dynamics.newton_second_law m a

/-- Migrated from `MechLib.Mechanics.Dynamics.secondLawVec_eq`. -/
@[simp] theorem secondLawVec_eq {n : ℕ} (m : Mass) (a : VecAcceleration n) :
    secondLawVec m a = m * a := by
  simpa using MechLib.Mechanics.Dynamics.secondLawVec_eq m a

/-- Migrated from `MechLib.Mechanics.Dynamics.momentum_change_const_mass`. -/
theorem momentum_change_const_mass (m : Mass) (v₂ v₁ : Speed) :
    momentum m v₂ - momentum m v₁ = m * (v₂ - v₁)
 := by
  simpa using MechLib.Mechanics.Dynamics.momentum_change_const_mass m v₂ v₁

/-- Migrated from `MechLib.Mechanics.Dynamics.force_from_velocity_rate_const_mass`. -/
theorem force_from_velocity_rate_const_mass (m : Mass) (dvdt : Acceleration) :
    secondLaw m dvdt = m * dvdt
 := by
  simpa using MechLib.Mechanics.Dynamics.force_from_velocity_rate_const_mass m dvdt

end Dynamics

namespace WorkEnergy
open MechLib.Mechanics.WorkEnergy

/-- Migrated from `MechLib.Mechanics.WorkEnergy.hooke_force_eq`. -/
theorem hooke_force_eq (k : SpringConstant) (x : Length) :
    hookeForce k x = Quantity.cast (-(k * x)) SI.spring_plus_length_eq_force
 := by
  simpa using MechLib.Mechanics.WorkEnergy.hooke_force_eq k x

/-- Migrated from `MechLib.Mechanics.WorkEnergy.kineticEnergy_change_formula`. -/
theorem kineticEnergy_change_formula (m : Mass) (v2 v1 : Speed) :
    kineticEnergy1D m v2 - kineticEnergy1D m v1 =
      (1 / 2 : ℝ) • Quantity.cast (m * ((v2 ** 2) - (v1 ** 2))) SI.mass_two_speed_eq_energy
 := by
  simpa using MechLib.Mechanics.WorkEnergy.kineticEnergy_change_formula m v2 v1

/-- Migrated from `MechLib.Mechanics.WorkEnergy.work_def`. -/
theorem work_def {n : ℕ} (F : VecForce n) (s : VecLength n) : work F s = F ⬝ᵥ s
 := by
  simpa using MechLib.Mechanics.WorkEnergy.work_def F s

/-- Migrated from `MechLib.Mechanics.WorkEnergy.force_length_eq_energy`. -/
theorem force_length_eq_energy : SI.forceDim + SI.lengthDim = SI.energyDim
 := by
  simpa using MechLib.Mechanics.WorkEnergy.force_length_eq_energy

/-- Migrated from `MechLib.Mechanics.WorkEnergy.work1D_def`. -/
theorem work1D_def (F : Force) (dx : Length) :
    work1D F dx = Quantity.cast (F * dx) force_length_eq_energy
 := by
  simpa using MechLib.Mechanics.WorkEnergy.work1D_def F dx

/-- Migrated from `MechLib.Mechanics.WorkEnergy.work_energy_theorem_core`. -/
theorem work_energy_theorem_core (Wnet K2 K1 : Energy) (h : Wnet = K2 - K1) :
    K2 = K1 + Wnet
 := by
  simpa using MechLib.Mechanics.WorkEnergy.work_energy_theorem_core Wnet K2 K1 h

/-- Migrated from `MechLib.Mechanics.WorkEnergy.conservative_nonconservative_split`. -/
theorem conservative_nonconservative_split
    (K2 K1 U2 U1 Wnet Wcons Wnoncons : Energy)
    (hNet : Wnet = K2 - K1)
    (hCons : Wcons = -(U2 - U1))
    (hDecomp : Wnet = Wcons + Wnoncons) :
    (K2 + U2) - (K1 + U1) = Wnoncons
 := by
  simpa using MechLib.Mechanics.WorkEnergy.conservative_nonconservative_split K2 K1 U2 U1 Wnet Wcons Wnoncons hNet hCons hDecomp

end WorkEnergy

namespace MomentumImpulse
open MechLib.Mechanics.MomentumImpulse

/-- Migrated from `MechLib.Mechanics.MomentumImpulse.impulse_momentum_theorem`. -/
theorem impulse_momentum_theorem (p2 p1 : Momentum) (F : Force) (dt : Time)
    (h : p2 - p1 = impulse F dt) : p2 = p1 + impulse F dt
 := by
  simpa using MechLib.Mechanics.MomentumImpulse.impulse_momentum_theorem p2 p1 F dt h

/-- Migrated from `MechLib.Mechanics.MomentumImpulse.momentum_conservation_inelastic`. -/
theorem momentum_conservation_inelastic (m1 m2 : Mass) (v1 v2 : Speed)
    (h : (m1 + m2).val ≠ 0) :
    (m1 + m2) * postCollisionSpeedInelastic m1 m2 v1 v2 = m1 * v1 + m2 * v2
 := by
  simpa using MechLib.Mechanics.MomentumImpulse.momentum_conservation_inelastic m1 m2 v1 v2 h

/-- Migrated from `MechLib.Mechanics.MomentumImpulse.impulse_def`. -/
theorem impulse_def (F : Force) (dt : Time) :
    impulse F dt = Quantity.cast (F * dt) SI.force_time_eq_momentum
 := by
  simpa using MechLib.Mechanics.MomentumImpulse.impulse_def F dt

end MomentumImpulse

namespace SystemDynamics
open MechLib.Mechanics.SystemDynamics

/-- Migrated from `MechLib.Mechanics.SystemDynamics.mass_length_sub_mass_eq_length`. -/
theorem mass_length_sub_mass_eq_length :
    (SI.massDim + SI.lengthDim) - SI.massDim = SI.lengthDim
 := by
  simpa using MechLib.Mechanics.SystemDynamics.mass_length_sub_mass_eq_length

/-- Migrated from `MechLib.Mechanics.SystemDynamics.mass_two_sub_mass_eq_mass`. -/
theorem mass_two_sub_mass_eq_mass :
    (SI.massDim + SI.massDim) - SI.massDim = SI.massDim
 := by
  simpa using MechLib.Mechanics.SystemDynamics.mass_two_sub_mass_eq_mass

/-- Migrated from `MechLib.Mechanics.SystemDynamics.totalMass_nil`. -/
theorem totalMass_nil : totalMass [] = 0
 := by
  simpa using MechLib.Mechanics.SystemDynamics.totalMass_nil

/-- Migrated from `MechLib.Mechanics.SystemDynamics.totalMomentum_nil`. -/
theorem totalMomentum_nil : totalMomentum [] = 0
 := by
  simpa using MechLib.Mechanics.SystemDynamics.totalMomentum_nil

/-- Migrated from `MechLib.Mechanics.SystemDynamics.totalMass_cons`. -/
theorem totalMass_cons (p : Particle1D) (ps : List Particle1D) :
    totalMass (p :: ps) = p.m + totalMass ps
 := by
  simpa using MechLib.Mechanics.SystemDynamics.totalMass_cons p ps

/-- Migrated from `MechLib.Mechanics.SystemDynamics.totalMomentum_cons`. -/
theorem totalMomentum_cons (p : Particle1D) (ps : List Particle1D) :
    totalMomentum (p :: ps) = p.m * p.v + totalMomentum ps
 := by
  simpa using MechLib.Mechanics.SystemDynamics.totalMomentum_cons p ps

/-- Migrated from `MechLib.Mechanics.SystemDynamics.centerOfMassPosition_singleton`. -/
theorem centerOfMassPosition_singleton (p : Particle1D) (h : p.m.val ≠ 0) :
    centerOfMassPosition [p] = p.x
 := by
  simpa using MechLib.Mechanics.SystemDynamics.centerOfMassPosition_singleton p h

/-- Migrated from `MechLib.Mechanics.SystemDynamics.centerOfMassVelocity_singleton`. -/
theorem centerOfMassVelocity_singleton (p : Particle1D) (h : p.m.val ≠ 0) :
    centerOfMassVelocity [p] = p.v
 := by
  simpa using MechLib.Mechanics.SystemDynamics.centerOfMassVelocity_singleton p h

/-- Migrated from `MechLib.Mechanics.SystemDynamics.totalMomentum_two_eq_totalMass_mul_centerVelocity`. -/
theorem totalMomentum_two_eq_totalMass_mul_centerVelocity
    (m1 m2 : Mass) (v1 v2 : Speed) (h : (m1 + m2).val ≠ 0) :
    m1 * v1 + m2 * v2 = (m1 + m2) * centerVelocity2 m1 m2 v1 v2
 := by
  simpa using MechLib.Mechanics.SystemDynamics.totalMomentum_two_eq_totalMass_mul_centerVelocity m1 m2 v1 v2 h

/-- Migrated from `MechLib.Mechanics.SystemDynamics.reducedMass_symm`. -/
theorem reducedMass_symm (m1 m2 : Mass) : reducedMass m1 m2 = reducedMass m2 m1
 := by
  simpa using MechLib.Mechanics.SystemDynamics.reducedMass_symm m1 m2

/-- Migrated from `MechLib.Mechanics.SystemDynamics.twoBody_kineticEnergy_decomposition`. -/
theorem twoBody_kineticEnergy_decomposition
    (m1 m2 : Mass) (v1 v2 : Speed) (h : (m1 + m2).val ≠ 0) :
    totalKineticEnergy2 m1 m2 v1 v2 = decomposedKineticEnergy2 m1 m2 v1 v2
 := by
  simpa using MechLib.Mechanics.SystemDynamics.twoBody_kineticEnergy_decomposition m1 m2 v1 v2 h

/-- Migrated from `MechLib.Mechanics.SystemDynamics.centerOfMassTheorem_eq`. -/
theorem centerOfMassTheorem_eq (M : Mass) (Rddot : ℝ → Acceleration) (Fext : ℝ → Force) :
    CenterOfMassTheorem M Rddot Fext = (∀ t, M * Rddot t = Fext t)
 := by
  simpa using MechLib.Mechanics.SystemDynamics.centerOfMassTheorem_eq M Rddot Fext

/-- Migrated from `MechLib.Mechanics.SystemDynamics.variableMassMomentumBalance_eq`. -/
theorem variableMassMomentumBalance_eq
    (pDot : ℝ → Force) (Fext Fflux : ℝ → Force) :
    VariableMassMomentumBalance pDot Fext Fflux = (∀ t, pDot t = Fext t + Fflux t)
 := by
  simpa using MechLib.Mechanics.SystemDynamics.variableMassMomentumBalance_eq pDot Fext Fflux

/-- Migrated from `MechLib.Mechanics.SystemDynamics.systemMomentBalanceAboutOrigin_eq`. -/
theorem systemMomentBalanceAboutOrigin_eq
    (LdotO MextO : ℝ → VecTorque 3) :
    SystemMomentBalanceAboutOrigin LdotO MextO = (∀ t, LdotO t = MextO t)
 := by
  simpa using MechLib.Mechanics.SystemDynamics.systemMomentBalanceAboutOrigin_eq LdotO MextO

end SystemDynamics

end
end Verified
end Dynamics
end MechLib
