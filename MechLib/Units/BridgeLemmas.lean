import MechLib.SI

/-!
Proof-friendly bridge lemmas for common dimensional casts.

These lemmas are intentionally value-level `@[simp]` facts.  They do not
rewrite physical laws; they only expose the numeric carrier after a
dimension-preserving `Quantity.cast`.
-/

namespace MechLib
namespace Units
namespace BridgeLemmas

noncomputable section

@[simp] theorem speed_time_to_length_val (v : SI.Speed) (t : SI.Time) :
    (Quantity.cast (v * t) SI.speed_time_eq_length).val = v.val * t.val := by
  simp

@[simp] theorem acceleration_time_to_speed_val (a : SI.Acceleration) (t : SI.Time) :
    (Quantity.cast (a * t) SI.acceleration_time_eq_speed).val = a.val * t.val := by
  simp

@[simp] theorem acceleration_time_sq_to_length_val (a : SI.Acceleration) (t : SI.Time) :
    (Quantity.cast (a * (t ** 2)) SI.acceleration_two_time_eq_length).val =
      a.val * t.val ^ 2 := by
  simp

@[simp] theorem mass_acceleration_to_force_val (m : SI.Mass) (a : SI.Acceleration) :
    (Quantity.cast (m * a) SI.mass_acceleration_eq_force).val = m.val * a.val := by
  simp

@[simp] theorem force_time_to_momentum_val (F : SI.Force) (t : SI.Time) :
    (Quantity.cast (F * t) SI.force_time_eq_momentum).val = F.val * t.val := by
  simp

@[simp] theorem force_length_to_energy_val (F : SI.Force) (x : SI.Length) :
    (Quantity.cast (F * x) SI.force_plus_length_eq_energy).val = F.val * x.val := by
  simp

@[simp] theorem power_time_to_energy_val (P : SI.Power) (t : SI.Time) :
    (Quantity.cast (P * t) SI.power_time_eq_energy).val = P.val * t.val := by
  simp

@[simp] theorem momentOfInertia_angularAcceleration_to_torque_val
    (I : SI.MomentOfInertia) (alpha : SI.AngularAcceleration) :
    (Quantity.cast (I * alpha) SI.moi_plus_angularAcceleration_eq_torque).val =
      I.val * alpha.val := by
  simp

@[simp] theorem angularVelocity_angularMomentum_to_torque_val
    (omega : SI.AngularVelocity) (L : SI.AngularMomentum) :
    (Quantity.cast (omega * L) SI.angularVelocity_plus_angularMomentum_eq_torque).val =
      omega.val * L.val := by
  simp

example (v : SI.Speed) (t : SI.Time) :
    (Quantity.cast (v * t) SI.speed_time_eq_length).val = v.val * t.val := by
  simp

example (F : SI.Force) (t : SI.Time) :
    (Quantity.cast (F * t) SI.force_time_eq_momentum).val = F.val * t.val := by
  simp

end
end BridgeLemmas
end Units
end MechLib
