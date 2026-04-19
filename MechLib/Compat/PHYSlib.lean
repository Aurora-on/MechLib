import Mathlib
import MechLib.Mechanics.SHM

namespace MechLib
namespace Compat
namespace PHYSlib

open Units

abbrev Dimensions := Dim
abbrev Scalar := Quantity
abbrev StandardUnit := Quantity.standardUnit

namespace SI

open MechLib.SI
open MechLib.Mechanics

noncomputable section

abbrev length_unit : Dimensions := lengthDim
abbrev mass_unit : Dimensions := massDim
abbrev time_unit : Dimensions := timeDim
abbrev speed_unit : Dimensions := speedDim
abbrev acceleration_unit : Dimensions := accelerationDim
abbrev force_unit : Dimensions := forceDim
abbrev momentum_unit : Dimensions := momentumDim
abbrev energy_unit : Dimensions := energyDim
abbrev frequency_unit : Dimensions := frequencyDim

abbrev Length := MechLib.SI.Length
abbrev Mass := MechLib.SI.Mass
abbrev Time := MechLib.SI.Time
abbrev Speed := MechLib.SI.Speed
abbrev Acceleration := MechLib.SI.Acceleration
abbrev Force := MechLib.SI.Force
abbrev Momentum := MechLib.SI.Momentum
abbrev Energy := MechLib.SI.Energy
abbrev PhysAngle := MechLib.SI.PhysAngle

abbrev meter := MechLib.SI.meter
abbrev kilogram := MechLib.SI.kilogram
abbrev second := MechLib.SI.second
abbrev newton := MechLib.SI.newton
abbrev joule := MechLib.SI.joule
abbrev hertz := MechLib.SI.hertz
abbrev c := MechLib.SI.c
abbrev g := MechLib.SI.g

abbrev displacement_end_x_init_x := Kinematics.displacement
abbrev displacement_delta_t_const_v := Kinematics.averageVelocity
abbrev secondLaw := Dynamics.secondLaw
abbrev F_of := Dynamics.F_of

@[simp]
theorem newton_second_law (m : Mass) (a : Acceleration) : F_of m a = m * a := by
  exact Dynamics.newton_second_law m a

theorem Scalar_val_inj {d : Dimensions} {q1 q2 : Scalar d} :
    q1.val = q2.val ↔ q1 = q2 := by
  constructor
  . intro h
    ext
    exact h
  . intro h
    simp [h]

example : ((2 : ℝ) : Scalar (0 : Dimensions)).val = 2 := by rfl

example : ((3 : ℝ) • meter).val = 3 := by
  norm_num [meter, StandardUnit]

example : Quantity.inUnits newton ((6 : ℝ) • newton) = 6 := by
  norm_num [Quantity.inUnits, newton, StandardUnit]

example : F_of ((2 : ℝ) • kilogram) ((3 : ℝ) • meter / (second ** 2)) = (6 : ℝ) • newton := by
  ext
  norm_num [F_of, secondLaw, kilogram, meter, second, newton, StandardUnit]

example (x2 x1 : Length) : displacement_end_x_init_x x2 x1 = x2 - x1 := rfl

example (m : Mass) (a : Acceleration) : secondLaw m a = m * a := rfl

example (m : Mass) (v2 v1 : Speed) :
    Dynamics.momentum m v2 - Dynamics.momentum m v1 = m * (v2 - v1) := by
  simpa using Dynamics.momentum_change_const_mass m v2 v1

example (k : MechLib.SI.SpringConstant) (x : Length) :
    WorkEnergy.hookeForce k x = Quantity.cast (-(k * x)) MechLib.SI.spring_plus_length_eq_force := rfl

example (I : MechLib.SI.MomentOfInertia) (omega : MechLib.SI.AngularVelocity) :
    Rotation.rotationalKineticEnergy I omega
      = (1 / 2 : ℝ) • Quantity.cast (I * (omega ** 2)) MechLib.SI.moi_plus_omega_sq_eq_energy := rfl

example (A : Length) (omega : MechLib.SI.AngularVelocity) (phi : PhysAngle) (t : Time) :
    SHM.acceleration A omega phi t =
      (-1 : ℝ) • Quantity.cast ((omega ** 2) * SHM.position A omega phi t)
        MechLib.SI.omega_sq_plus_length_eq_acceleration := by
  simpa using SHM.acceleration_eq_neg_omega_sq_mul_pos A omega phi t

example : (MechLib.SI.kilo meter).val = 1000 := by
  norm_num [MechLib.SI.kilo, meter, StandardUnit]

end
end SI

end PHYSlib
end Compat
end MechLib
