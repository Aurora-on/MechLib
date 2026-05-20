import Mathlib
import MechLib.Units.VecQuantity

namespace MechLib
namespace SI

open Units
noncomputable section

abbrev lengthDim : Dim := Dim.length
abbrev massDim : Dim := Dim.mass
abbrev timeDim : Dim := Dim.time
abbrev currentDim : Dim := Dim.current
abbrev temperatureDim : Dim := Dim.temperature
abbrev amountDim : Dim := Dim.amount
abbrev intensityDim : Dim := Dim.intensity

abbrev speedDim : Dim := lengthDim - timeDim
abbrev accelerationDim : Dim := lengthDim - (2 : ℕ) • timeDim
abbrev momentumDim : Dim := massDim + speedDim
abbrev forceDim : Dim := massDim + accelerationDim
abbrev energyDim : Dim := forceDim + lengthDim
abbrev powerDim : Dim := energyDim - timeDim
abbrev pressureDim : Dim := forceDim - (2 : ℕ) • lengthDim
abbrev frequencyDim : Dim := -timeDim
abbrev springConstantDim : Dim := forceDim - lengthDim
abbrev dampingDim : Dim := massDim - timeDim
abbrev angularVelocityDim : Dim := frequencyDim
abbrev angularAccelerationDim : Dim := angularVelocityDim - timeDim
abbrev angularVelocitySquaredDim : Dim := (2 : ℕ) • angularVelocityDim
abbrev momentOfInertiaDim : Dim := massDim + (2 : ℕ) • lengthDim
abbrev torqueDim : Dim := forceDim + lengthDim
abbrev angularMomentumDim : Dim := momentumDim + lengthDim
abbrev dampingDiscriminantDim : Dim := (2 : ℕ) • dampingDim

abbrev Dimensionless := Quantity (0 : Dim)
abbrev PhysAngle := Dimensionless

abbrev Length := Quantity lengthDim
abbrev Mass := Quantity massDim
abbrev Time := Quantity timeDim
abbrev Current := Quantity currentDim
abbrev Temperature := Quantity temperatureDim
abbrev Amount := Quantity amountDim
abbrev Intensity := Quantity intensityDim

abbrev Speed := Quantity speedDim
abbrev Acceleration := Quantity accelerationDim
abbrev Momentum := Quantity momentumDim
abbrev Force := Quantity forceDim
abbrev Energy := Quantity energyDim
abbrev Power := Quantity powerDim
abbrev Pressure := Quantity pressureDim
abbrev Frequency := Quantity frequencyDim
abbrev SpringConstant := Quantity springConstantDim
abbrev DampingCoefficient := Quantity dampingDim
abbrev AngularVelocity := Quantity angularVelocityDim
abbrev AngularAcceleration := Quantity angularAccelerationDim
abbrev AngularVelocitySquared := Quantity angularVelocitySquaredDim
abbrev MomentOfInertia := Quantity momentOfInertiaDim
abbrev Torque := Quantity torqueDim
abbrev AngularMomentum := Quantity angularMomentumDim

abbrev VecLength (n : ℕ) := VecQuantity lengthDim n
abbrev VecSpeed (n : ℕ) := VecQuantity speedDim n
abbrev VecAcceleration (n : ℕ) := VecQuantity accelerationDim n
abbrev VecForce (n : ℕ) := VecQuantity forceDim n
abbrev VecMomentum (n : ℕ) := VecQuantity momentumDim n
abbrev VecTorque (n : ℕ) := VecQuantity torqueDim n
abbrev VecAngularMomentum (n : ℕ) := VecQuantity angularMomentumDim n

abbrev radian : PhysAngle := Quantity.standardUnit _
abbrev meter : Length := Quantity.standardUnit _
abbrev kilogram : Mass := Quantity.standardUnit _
abbrev second : Time := Quantity.standardUnit _
abbrev ampere : Current := Quantity.standardUnit _
abbrev kelvin : Temperature := Quantity.standardUnit _
abbrev mole : Amount := Quantity.standardUnit _
abbrev candela : Intensity := Quantity.standardUnit _

abbrev minute : Time := (60 : ℝ) • second
abbrev hour : Time := (60 : ℝ) • minute
abbrev day : Time := (24 : ℝ) • hour
abbrev week : Time := (7 : ℝ) • day
abbrev year : Time := (365 : ℝ) • day

abbrev hertz : Frequency := Quantity.standardUnit _
abbrev newton : Force := Quantity.standardUnit _
abbrev joule : Energy := Quantity.standardUnit _
abbrev watt : Power := Quantity.standardUnit _
abbrev pascal : Pressure := Quantity.standardUnit _
abbrev dampingCoefficientUnit : DampingCoefficient := kilogram / second
abbrev momentOfInertiaUnit : MomentOfInertia := kilogram * (meter ** 2)

abbrev deca {d : Dim} (q : Quantity d) : Quantity d := (10 : ℝ) • q
abbrev hecto {d : Dim} (q : Quantity d) : Quantity d := ((10 : ℝ) ^ 2) • q
abbrev kilo {d : Dim} (q : Quantity d) : Quantity d := ((10 : ℝ) ^ 3) • q
abbrev mega {d : Dim} (q : Quantity d) : Quantity d := ((10 : ℝ) ^ 6) • q
abbrev giga {d : Dim} (q : Quantity d) : Quantity d := ((10 : ℝ) ^ 9) • q
abbrev tera {d : Dim} (q : Quantity d) : Quantity d := ((10 : ℝ) ^ 12) • q
abbrev peta {d : Dim} (q : Quantity d) : Quantity d := ((10 : ℝ) ^ 15) • q
abbrev exa {d : Dim} (q : Quantity d) : Quantity d := ((10 : ℝ) ^ 18) • q

abbrev deci {d : Dim} (q : Quantity d) : Quantity d := q / (10 : ℝ)
abbrev centi {d : Dim} (q : Quantity d) : Quantity d := q / ((10 : ℝ) ^ 2)
abbrev milli {d : Dim} (q : Quantity d) : Quantity d := q / ((10 : ℝ) ^ 3)
abbrev micro {d : Dim} (q : Quantity d) : Quantity d := q / ((10 : ℝ) ^ 6)
abbrev nano {d : Dim} (q : Quantity d) : Quantity d := q / ((10 : ℝ) ^ 9)
abbrev pico {d : Dim} (q : Quantity d) : Quantity d := q / ((10 : ℝ) ^ 12)
abbrev femto {d : Dim} (q : Quantity d) : Quantity d := q / ((10 : ℝ) ^ 15)
abbrev atto {d : Dim} (q : Quantity d) : Quantity d := q / ((10 : ℝ) ^ 18)

abbrev c : Speed := (299792458 : ℝ) • meter / second
abbrev g : Acceleration := (9.80665 : ℝ) • meter / (second ** 2)

theorem speed_time_eq_length : speedDim + timeDim = lengthDim := by native_decide

theorem acceleration_time_eq_speed : accelerationDim + timeDim = speedDim := by native_decide

theorem mass_acceleration_eq_force : massDim + accelerationDim = forceDim := by native_decide

theorem damping_speed_eq_force : dampingDim + speedDim = forceDim := by native_decide

theorem damping_two_speed_eq_power : dampingDim + (2 : ℕ) • speedDim = powerDim := by
  native_decide

theorem length_plus_angular_velocity_eq_speed : lengthDim + angularVelocityDim = speedDim := by native_decide

theorem acceleration_two_time_eq_length : accelerationDim + (2 : ℕ) • timeDim = lengthDim := by native_decide

theorem angular_velocity_time_eq_dimensionless : angularVelocityDim + timeDim = (0 : Dim) := by native_decide

theorem time_plus_angular_velocity_eq_dimensionless : timeDim + angularVelocityDim = (0 : Dim) := by native_decide

theorem omega_sq_plus_length_eq_acceleration :
    (2 : ℕ) • angularVelocityDim + lengthDim = accelerationDim := by native_decide

theorem angularVelocitySquared_plus_length_eq_acceleration :
    angularVelocitySquaredDim + lengthDim = accelerationDim := by native_decide

theorem length_plus_angularAcceleration_eq_acceleration :
    lengthDim + angularAccelerationDim = accelerationDim := by native_decide

theorem momentum_sub_mass_eq_speed : momentumDim - massDim = speedDim := by native_decide

theorem force_time_eq_momentum : forceDim + timeDim = momentumDim := by native_decide

theorem force_plus_length_eq_energy : forceDim + lengthDim = energyDim := by native_decide

theorem power_time_eq_energy : powerDim + timeDim = energyDim := by native_decide

theorem length_plus_force_eq_torque : lengthDim + forceDim = torqueDim := by native_decide

theorem length_plus_momentum_eq_angularMomentum : lengthDim + momentumDim = angularMomentumDim := by native_decide

theorem angularVelocity_plus_angularMomentum_eq_torque :
    angularVelocityDim + angularMomentumDim = torqueDim := by native_decide

theorem spring_plus_length_eq_force : springConstantDim + lengthDim = forceDim := by native_decide

theorem spring_plus_two_length_eq_energy : springConstantDim + (2 : ℕ) • lengthDim = energyDim := by native_decide

theorem mass_plus_two_omega_eq_spring :
    massDim + (2 : ℕ) • angularVelocityDim = springConstantDim := by
  native_decide

theorem mass_plus_angularVelocitySquared_eq_spring :
    massDim + angularVelocitySquaredDim = springConstantDim := by
  native_decide

theorem mass_plus_spring_eq_damping_discriminant :
    massDim + springConstantDim = dampingDiscriminantDim := by
  native_decide

theorem mass_speed_sq_eq_energy : massDim + (speedDim + speedDim) = energyDim := by native_decide

theorem mass_two_speed_eq_energy : massDim + (2 : ℕ) • speedDim = energyDim := by native_decide

theorem moi_plus_omega_sq_eq_energy :
    momentOfInertiaDim + (2 : ℕ) • angularVelocityDim = energyDim := by native_decide

theorem moi_plus_angularAcceleration_eq_torque :
    momentOfInertiaDim + angularAccelerationDim = torqueDim := by native_decide

/-- 可配置单位选择层：为每个维度给出一个缩放因子。 -/
structure UnitChoices where
  dimScale : Dim → ℝ
  dimScale_ne_zero : ∀ d, dimScale d ≠ 0

namespace UnitChoices

/-- 在给定单位选择下，维度 `d` 的基准单位。 -/
def unit (U : UnitChoices) (d : Dim) : Quantity d :=
  (U.dimScale d) • Quantity.standardUnit d

@[simp] theorem unit_val (U : UnitChoices) (d : Dim) :
    (U.unit d).val = U.dimScale d := by
  simp [unit]

theorem unit_ne_zero (U : UnitChoices) (d : Dim) : (U.unit d).val ≠ 0 := by
  simpa [unit] using U.dimScale_ne_zero d

/-- 按单位选择 `U` 读取量 `q` 的数值。 -/
def inChoice (U : UnitChoices) {d : Dim} (q : Quantity d) : ℝ :=
  Quantity.inUnits (U.unit d) q

@[simp] theorem inChoice_def (U : UnitChoices) {d : Dim} (q : Quantity d) :
    inChoice U q = Quantity.inUnits (U.unit d) q := rfl

theorem inChoice_eq_val_div_scale (U : UnitChoices) {d : Dim} (q : Quantity d) :
    inChoice U q = q.val / U.dimScale d := by
  simp [inChoice, unit]

theorem inChoice_self (U : UnitChoices) (d : Dim) :
    inChoice U (U.unit d) = 1 := by
  exact Quantity.inUnits_self (U.unit d) (U.unit_ne_zero d)

end UnitChoices

/-- 从单位 `uFrom` 到单位 `uTo` 的换算因子。 -/
def conversionFactor {d : Dim} (uFrom uTo : Quantity d) : ℝ :=
  Quantity.inUnits uTo uFrom

@[simp] theorem conversionFactor_def {d : Dim} (uFrom uTo : Quantity d) :
    conversionFactor uFrom uTo = Quantity.inUnits uTo uFrom := rfl

/-- SI 层换算因子复合律：`u1→u3 = (u1→u2) * (u2→u3)`。 -/
theorem conversionFactor_comp {d : Dim} (u1 u2 u3 : Quantity d) (h2 : u2.val ≠ 0) :
    conversionFactor u1 u3 = conversionFactor u1 u2 * conversionFactor u2 u3 := by
  simpa [conversionFactor, mul_comm, mul_left_comm, mul_assoc] using
    (Quantity.inUnits_trans (u1 := u3) (u2 := u2) (q := u1) h2)

/-- SI 层换算因子互逆律：`(u1→u2) * (u2→u1) = 1`。 -/
theorem conversionFactor_mul_swap {d : Dim} (u1 u2 : Quantity d)
    (h1 : u1.val ≠ 0) (h2 : u2.val ≠ 0) :
    conversionFactor u1 u2 * conversionFactor u2 u1 = 1 := by
  simpa [conversionFactor] using Quantity.inUnits_mul_symm (u1 := u2) (u2 := u1) h2 h1

-- DONE[MECH_UNITS_01]: added `UnitChoices/dimScale` layer with `unit` and `inChoice`.
-- DONE[MECH_UNITS_02]: added SI-level conversion APIs and composition/inverse theorems.

end
end SI
end MechLib
