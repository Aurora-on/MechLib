import Mathlib
import MechLib.Mechanics.Rotation

namespace MechLib
namespace Mechanics
namespace SHM

open Units SI

noncomputable section

def phase (omega : AngularVelocity) (phi : PhysAngle) (t : Time) : Dimensionless :=
  Quantity.cast (omega * t) SI.angular_velocity_time_eq_dimensionless + phi

def position (A : Length) (omega : AngularVelocity) (phi : PhysAngle) (t : Time) : Length :=
  (Real.cos (phase omega phi t).val) • A

def velocity (A : Length) (omega : AngularVelocity) (phi : PhysAngle) (t : Time) : Speed :=
  (-Real.sin (phase omega phi t).val) • Quantity.cast (A * omega) SI.length_plus_angular_velocity_eq_speed

def acceleration (A : Length) (omega : AngularVelocity) (phi : PhysAngle) (t : Time) : Acceleration :=
  (-1 : ℝ) • Quantity.cast ((omega ** 2) * position A omega phi t) SI.omega_sq_plus_length_eq_acceleration

def period (omega : AngularVelocity) : Time :=
  (((2 * Real.pi) / omega.val) : ℝ) • second

def totalEnergy (m : Mass) (k : SpringConstant) (x : Length) (v : Speed) : Energy :=
  WorkEnergy.kineticEnergy1D m v + WorkEnergy.springPotential k x

/-- 由参数 `(A, ω, φ)` 诱导的初始位移 `x(0)`。 -/
def initialPosition (A : Length) (omega : AngularVelocity) (phi : PhysAngle) : Length :=
  position A omega phi 0

/-- 由参数 `(A, ω, φ)` 诱导的初始速度 `v(0)`。 -/
def initialVelocity (A : Length) (omega : AngularVelocity) (phi : PhysAngle) : Speed :=
  velocity A omega phi 0

/-- 从初值 `(x0, v0, ω)` 恢复振幅的常用表达。 -/
def amplitudeFromInitial (omega : AngularVelocity) (x0 : Length) (v0 : Speed) : Length :=
  (Real.sqrt (x0.val ^ 2 + (v0.val / omega.val) ^ 2)) • meter

abbrev acceleration_eq_neg_omega_sq_mul_pos
    (A : Length) (omega : AngularVelocity) (phi : PhysAngle) (t : Time) :
    acceleration A omega phi t =
      (-1 : ℝ) • Quantity.cast ((omega ** 2) * position A omega phi t) SI.omega_sq_plus_length_eq_acceleration :=
  rfl

abbrev period_frequency_relation (omega : AngularVelocity) (h : omega.val ≠ 0) :
    Quantity.cast (period omega * omega) SI.time_plus_angular_velocity_eq_dimensionless =
      (((2 : ℝ) * Real.pi : ℝ) : Dimensionless) := by
  ext
  simp [period, Quantity.cast_val, Quantity.val_ofReal]
  field_simp [h]

abbrev totalEnergy_eq (m : Mass) (k : SpringConstant) (x : Length) (v : Speed) :
    totalEnergy m k x v = WorkEnergy.kineticEnergy1D m v + WorkEnergy.springPotential k x := rfl

abbrev initialPosition_eq (A : Length) (omega : AngularVelocity) (phi : PhysAngle) :
    initialPosition A omega phi = (Real.cos phi.val) • A := by
  ext
  simp [initialPosition, position, phase, Quantity.cast_val]

abbrev initialVelocity_eq (A : Length) (omega : AngularVelocity) (phi : PhysAngle) :
    initialVelocity A omega phi
      = (-Real.sin phi.val) • Quantity.cast (A * omega) SI.length_plus_angular_velocity_eq_speed := by
  ext
  simp [initialVelocity, velocity, phase, Quantity.cast_val]

abbrev amplitudeFromInitial_nonneg (omega : AngularVelocity) (x0 : Length) (v0 : Speed) :
    0 ≤ (amplitudeFromInitial omega x0 v0).val := by
  simp [amplitudeFromInitial, meter, Quantity.standardUnit]

example : (period ((1 : ℝ) • hertz)).val = (2 : ℝ) * Real.pi := by
  simp [period, hertz, Quantity.standardUnit]

example (A : Length) (omega : AngularVelocity) (phi : PhysAngle) (t : Time) :
    acceleration A omega phi t =
      (-1 : ℝ) • Quantity.cast ((omega ** 2) * position A omega phi t) SI.omega_sq_plus_length_eq_acceleration :=
  acceleration_eq_neg_omega_sq_mul_pos A omega phi t

example (m : Mass) (k : SpringConstant) (x : Length) (v : Speed) :
    totalEnergy m k x v = WorkEnergy.kineticEnergy1D m v + WorkEnergy.springPotential k x := rfl

example (A : Length) (omega : AngularVelocity) (phi : PhysAngle) :
    initialPosition A omega phi = (Real.cos phi.val) • A :=
  initialPosition_eq A omega phi

/-- SHM 方程接口（给定位移与加速度场）。 -/
def SHMEquation (omega : AngularVelocity) (x : Time → Length) (a : Time → Acceleration) : Prop :=
  ∀ t, a t = (-1 : ℝ) • Quantity.cast ((omega ** 2) * x t) SI.omega_sq_plus_length_eq_acceleration

/-- 两解在初值上的一致性。 -/
def SameInitialState
    (x1 x2 : Time → Length) (v1 v2 : Time → Speed) : Prop :=
  x1 0 = x2 0 ∧ v1 0 = v2 0

/-- “由初值唯一确定解”的形式化接口。 -/
def UniqueByInitialState (omega : AngularVelocity) : Prop :=
  ∀ (x1 x2 : Time → Length) (v1 v2 : Time → Speed) (a1 a2 : Time → Acceleration),
    SHMEquation omega x1 a1 →
    SHMEquation omega x2 a2 →
    SameInitialState x1 x2 v1 v2 →
    x1 = x2 ∧ v1 = v2

/-- Turning point 条件接口：速度为零。 -/
def TurningPoint (A : Length) (omega : AngularVelocity) (phi : PhysAngle) (t : Time) : Prop :=
  velocity A omega phi t = 0

/-- Turning point 候选时刻族（`n ∈ ℤ`）。 -/
def turningTimeCandidate (omega : AngularVelocity) (phi : PhysAngle) (n : ℤ) : Time :=
  (((n : ℝ) * Real.pi - phi.val) / omega.val) • second

abbrev turningPoint_def (A : Length) (omega : AngularVelocity) (phi : PhysAngle) (t : Time) :
    TurningPoint A omega phi t = (velocity A omega phi t = 0) := rfl

-- DONE[MECH_SHM_01]: added uniqueness-by-initial-state formal interface (`UniqueByInitialState`).
-- DONE[MECH_SHM_02]: added turning-point formal interfaces (`TurningPoint`, `turningTimeCandidate`).
-- DONE[MECH_SHM_03]: added initial-condition conversion APIs
--   (`initialPosition`, `initialVelocity`, `amplitudeFromInitial`) with core lemmas.

end
end SHM
end Mechanics
end MechLib
