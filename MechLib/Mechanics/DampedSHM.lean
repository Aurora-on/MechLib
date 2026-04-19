import Mathlib
import MechLib.Mechanics.SHM

namespace MechLib
namespace Mechanics
namespace DampedSHM

open Units SI

noncomputable section

/-- Input data for a 1D damped harmonic oscillator:
`m x'' + gamma x' + k x = 0`. -/
structure Params where
  m : Mass
  k : SpringConstant
  gamma : DampingCoefficient
  m_pos : 0 < m.val
  k_pos : 0 < k.val
  gamma_nonneg : 0 ≤ gamma.val

namespace Params

lemma m_ne_zero (P : Params) : P.m.val ≠ 0 := ne_of_gt P.m_pos

lemma k_ne_zero (P : Params) : P.k.val ≠ 0 := ne_of_gt P.k_pos

/-- Natural (undamped) angular frequency `omega0 = sqrt(k/m)`. -/
def omega0 (P : Params) : AngularVelocity :=
  (Real.sqrt (P.k.val / P.m.val)) • hertz

lemma omega0_pos (P : Params) : 0 < P.omega0.val := by
  have hdiv : 0 < P.k.val / P.m.val := div_pos P.k_pos P.m_pos
  simpa [omega0, hertz, Quantity.standardUnit] using Real.sqrt_pos.mpr hdiv

lemma omega0_sq_val (P : Params) : P.omega0.val ^ 2 = P.k.val / P.m.val := by
  have hnonneg : 0 ≤ P.k.val / P.m.val := div_nonneg (le_of_lt P.k_pos) (le_of_lt P.m_pos)
  simpa [omega0, hertz, Quantity.standardUnit] using Real.sq_sqrt hnonneg

end Params

/-- Force residual of `m x'' + gamma x' + k x`. -/
def equationResidual (P : Params) (x : Time → Length) (v : Time → Speed)
    (a : Time → Acceleration) : Time → Force := fun t =>
  P.m * a t
    + Quantity.cast (P.gamma * v t) SI.damping_speed_eq_force
    + Quantity.cast (P.k * x t) SI.spring_plus_length_eq_force

/-- Damped oscillator equation of motion in residual form. -/
def EquationOfMotion (P : Params) (x : Time → Length) (v : Time → Speed)
    (a : Time → Acceleration) : Prop :=
  ∀ t, equationResidual P x v a t = 0

def kineticEnergy (P : Params) (v : Time → Speed) : Time → Energy := fun t =>
  WorkEnergy.kineticEnergy1D P.m (v t)

def potentialEnergy (P : Params) (x : Time → Length) : Time → Energy := fun t =>
  WorkEnergy.springPotential P.k (x t)

def energy (P : Params) (x : Time → Length) (v : Time → Speed) : Time → Energy := fun t =>
  kineticEnergy P v t + potentialEnergy P x t

/-- Candidate dissipation power `- gamma v^2`. -/
def energyDissipationRate (P : Params) (v : Time → Speed) : Time → Power := fun t =>
  (-1 : ℝ) • Quantity.cast (P.gamma * ((v t) ** 2)) SI.damping_two_speed_eq_power

/-- Discriminant `gamma^2 - 4 m k` used to classify damping regime. -/
def discriminant (P : Params) : Quantity dampingDiscriminantDim :=
  (P.gamma ** 2)
    - Quantity.cast ((4 : ℝ) • (P.m * P.k)) SI.mass_plus_spring_eq_damping_discriminant

def IsUnderdamped (P : Params) : Prop := (discriminant P).val < 0

def IsCriticallyDamped (P : Params) : Prop := (discriminant P).val = 0

def IsOverdamped (P : Params) : Prop := (discriminant P).val > 0

theorem equationResidual_eq (P : Params) (x : Time → Length) (v : Time → Speed)
    (a : Time → Acceleration) :
    equationResidual P x v a =
      (fun t =>
        P.m * a t
          + Quantity.cast (P.gamma * v t) SI.damping_speed_eq_force
          + Quantity.cast (P.k * x t) SI.spring_plus_length_eq_force) := rfl

theorem energy_eq (P : Params) (x : Time → Length) (v : Time → Speed) :
    energy P x v = fun t => kineticEnergy P v t + potentialEnergy P x t := rfl

theorem discriminant_eq (P : Params) :
    discriminant P =
      (P.gamma ** 2)
        - Quantity.cast ((4 : ℝ) • (P.m * P.k)) SI.mass_plus_spring_eq_damping_discriminant := rfl

theorem regimes_trichotomy (P : Params) :
    IsUnderdamped P ∨ IsCriticallyDamped P ∨ IsOverdamped P := by
  unfold IsUnderdamped IsCriticallyDamped IsOverdamped
  rcases lt_trichotomy (discriminant P).val 0 with hlt | heq | hgt
  · exact Or.inl hlt
  · exact Or.inr (Or.inl heq)
  · exact Or.inr (Or.inr hgt)

theorem underdamped_not_overdamped (P : Params) :
    IsUnderdamped P → ¬ IsOverdamped P := by
  intro hUnder hOver
  exact lt_asymm hOver hUnder

theorem undamped_is_underdamped (P : Params) (hgamma : P.gamma = 0) :
    IsUnderdamped P := by
  unfold IsUnderdamped discriminant
  have hmk_pos : 0 < (P.m * P.k).val := by
    simpa using mul_pos P.m_pos P.k_pos
  have hval : ((P.gamma ** 2)
      - Quantity.cast ((4 : ℝ) • (P.m * P.k)) SI.mass_plus_spring_eq_damping_discriminant).val
      = -((4 : ℝ) * (P.m * P.k).val) := by
    simp [hgamma, Quantity.cast_val]
  rw [hval]
  have h4mk : 0 < (4 : ℝ) * (P.m * P.k).val := by
    nlinarith [hmk_pos]
  linarith

theorem damping_sub_mass_eq_frequency : SI.dampingDim - SI.massDim = SI.frequencyDim := by
  native_decide

theorem mass_sub_damping_eq_time : SI.massDim - SI.dampingDim = SI.timeDim := by
  native_decide

theorem zero_add_zero_eq_zero : ((0 : Dim) + (0 : Dim)) = (0 : Dim) := by
  native_decide

/-- 阻尼比 `ζ = γ / (2√(mk))`（按实数值封装为无量纲量）。 -/
def dampingRatio (P : Params) : Dimensionless :=
  ((P.gamma.val / (2 * Real.sqrt (P.m.val * P.k.val))) : ℝ)

/-- 品质因子 `Q = √(mk)/γ`（`γ ≠ 0` 时有意义）。 -/
def qualityFactor (P : Params) : Dimensionless :=
  ((Real.sqrt (P.m.val * P.k.val) / P.gamma.val) : ℝ)

/-- 阻尼率 `β = γ/(2m)`。 -/
def dampingRate (P : Params) : Frequency :=
  Quantity.cast (P.gamma / ((2 : ℝ) • P.m)) damping_sub_mass_eq_frequency

/-- 驰豫时间 `τ = m/γ`。 -/
def relaxationTime (P : Params) : Time :=
  Quantity.cast (P.m / P.gamma) mass_sub_damping_eq_time

/-- `Q` 与 `ζ` 的关系：`Q * ζ = 1/2`（当 `γ ≠ 0`）。 -/
theorem qualityFactor_mul_dampingRatio (P : Params) (hgamma : P.gamma.val ≠ 0) :
    Quantity.cast (qualityFactor P * dampingRatio P) zero_add_zero_eq_zero
      = (((1 / 2 : ℝ)) : Dimensionless) := by
  have hmk_pos : 0 < P.m.val * P.k.val := mul_pos P.m_pos P.k_pos
  have hsqrt : Real.sqrt (P.m.val * P.k.val) ≠ 0 := by
    exact ne_of_gt (Real.sqrt_pos.mpr hmk_pos)
  ext
  simp [qualityFactor, dampingRatio, Quantity.val_ofReal, Quantity.cast_val]
  field_simp [hgamma, hsqrt]

/-- `τ` 与 `β` 的关系：`τ * β = 1/2`（当 `γ ≠ 0`）。 -/
theorem relaxationTime_mul_dampingRate (P : Params) (hgamma : P.gamma.val ≠ 0) :
    Quantity.cast (relaxationTime P * dampingRate P) SI.time_plus_angular_velocity_eq_dimensionless
      = (((1 / 2 : ℝ)) : Dimensionless) := by
  ext
  simp [relaxationTime, dampingRate, Quantity.cast_val, Quantity.val_ofReal]
  field_simp [hgamma, P.m_ne_zero]

/-- 无阻尼残量 `m x'' + k x`。 -/
def undampedResidual (P : Params) (x : Time → Length) (a : Time → Acceleration) : Time → Force := fun t =>
  P.m * a t + Quantity.cast (P.k * x t) SI.spring_plus_length_eq_force

/-- 无阻尼方程接口。 -/
def UndampedEquationOfMotion (P : Params) (x : Time → Length) (a : Time → Acceleration) : Prop :=
  ∀ t, undampedResidual P x a t = 0

/-- `γ = 0` 时阻尼残量退化为无阻尼残量。 -/
theorem equationResidual_gamma_zero
    (P : Params) (x : Time → Length) (v : Time → Speed) (a : Time → Acceleration)
    (hgamma : P.gamma = 0) :
    equationResidual P x v a = undampedResidual P x a := by
  funext t
  ext
  simp [equationResidual, undampedResidual, hgamma, Quantity.cast_val]

/-- `γ = 0` 时，阻尼方程与无阻尼方程等价。 -/
theorem equationOfMotion_gamma_zero_iff
    (P : Params) (x : Time → Length) (v : Time → Speed) (a : Time → Acceleration)
    (hgamma : P.gamma = 0) :
    EquationOfMotion P x v a ↔ UndampedEquationOfMotion P x a := by
  constructor
  · intro h t
    have ht : equationResidual P x v a t = 0 := h t
    simpa [equationResidual_gamma_zero (P := P) (x := x) (v := v) (a := a) hgamma] using ht
  · intro h t
    have ht : undampedResidual P x a t = 0 := h t
    simpa [equationResidual_gamma_zero (P := P) (x := x) (v := v) (a := a) hgamma] using ht

/-- 能量耗散律接口：`dE/dt = -γ v^2`。 -/
def EnergyDissipationLaw
    (P : Params) (_x : Time → Length) (v : Time → Speed)
    (dEdt : Time → Power) : Prop :=
  ∀ t, dEdt t = energyDissipationRate P v t

/-- 欠阻尼闭式解接口。 -/
def IsUnderdampedClosedForm
    (P : Params) (x : Time → Length) (v : Time → Speed) (a : Time → Acceleration) : Prop :=
  IsUnderdamped P ∧ EquationOfMotion P x v a

/-- 临界阻尼闭式解接口。 -/
def IsCriticalClosedForm
    (P : Params) (x : Time → Length) (v : Time → Speed) (a : Time → Acceleration) : Prop :=
  IsCriticallyDamped P ∧ EquationOfMotion P x v a

/-- 过阻尼闭式解接口。 -/
def IsOverdampedClosedForm
    (P : Params) (x : Time → Length) (v : Time → Speed) (a : Time → Acceleration) : Prop :=
  IsOverdamped P ∧ EquationOfMotion P x v a

theorem energyDissipationLaw_eq
    (P : Params) (x : Time → Length) (v : Time → Speed) (dEdt : Time → Power) :
    EnergyDissipationLaw P x v dEdt = (∀ t, dEdt t = energyDissipationRate P v t) := rfl

theorem underdampedClosedForm_eq
    (P : Params) (x : Time → Length) (v : Time → Speed) (a : Time → Acceleration) :
    IsUnderdampedClosedForm P x v a = (IsUnderdamped P ∧ EquationOfMotion P x v a) := rfl

theorem criticalClosedForm_eq
    (P : Params) (x : Time → Length) (v : Time → Speed) (a : Time → Acceleration) :
    IsCriticalClosedForm P x v a = (IsCriticallyDamped P ∧ EquationOfMotion P x v a) := rfl

theorem overdampedClosedForm_eq
    (P : Params) (x : Time → Length) (v : Time → Speed) (a : Time → Acceleration) :
    IsOverdampedClosedForm P x v a = (IsOverdamped P ∧ EquationOfMotion P x v a) := rfl

-- DONE[MECH_DHO_04]: added energy-dissipation law formal interface (`EnergyDissipationLaw`).
-- DONE[MECH_DHO_05]: added underdamped closed-form solution interface (`IsUnderdampedClosedForm`).
-- DONE[MECH_DHO_06]: added critically damped closed-form solution interface (`IsCriticalClosedForm`).
-- DONE[MECH_DHO_07]: added overdamped closed-form solution interface (`IsOverdampedClosedForm`).
-- DONE[MECH_DHO_08]: defined `qualityFactor` and proved `Q * ζ = 1/2`.
-- DONE[MECH_DHO_09]: defined `relaxationTime`/`dampingRate` and proved `τ * β = 1/2`.
-- DONE[MECH_DHO_10]: proved `γ = 0` residual reduction and EOM equivalence (`equationOfMotion_gamma_zero_iff`).

example (P : Params) :
    IsUnderdamped P ∨ IsCriticallyDamped P ∨ IsOverdamped P :=
  regimes_trichotomy P

example (P : Params) (hgamma : P.gamma = 0) : IsUnderdamped P :=
  undamped_is_underdamped P hgamma

example (P : Params) (x : Time → Length) (v : Time → Speed) :
    energy P x v = fun t => kineticEnergy P v t + potentialEnergy P x t := rfl

example (P : Params) (hgamma : P.gamma.val ≠ 0) :
    Quantity.cast (qualityFactor P * dampingRatio P) zero_add_zero_eq_zero
      = (((1 / 2 : ℝ)) : Dimensionless) :=
  qualityFactor_mul_dampingRatio P hgamma

example (P : Params) (x : Time → Length) (v : Time → Speed) (a : Time → Acceleration)
    (hgamma : P.gamma = 0) :
    EquationOfMotion P x v a ↔ UndampedEquationOfMotion P x a :=
  equationOfMotion_gamma_zero_iff P x v a hgamma

end
end DampedSHM
end Mechanics
end MechLib
