import Mathlib
import MechLib.Mechanics.WorkEnergy

namespace MechLib
namespace Mechanics
namespace MomentumImpulse

open Units SI

noncomputable section

def impulse (F : Force) (dt : Time) : Momentum :=
  Quantity.cast (F * dt) SI.force_time_eq_momentum

def postCollisionSpeedInelastic (m1 m2 : Mass) (v1 v2 : Speed) : Speed :=
  Quantity.cast ((m1 * v1 + m2 * v2) / (m1 + m2)) SI.momentum_sub_mass_eq_speed

/-- 冲量-动量定理：若 `p2 - p1 = I`，则 `p2 = p1 + I`。 -/
theorem impulse_momentum_theorem (p2 p1 : Momentum) (F : Force) (dt : Time)
    (h : p2 - p1 = impulse F dt) : p2 = p1 + impulse F dt := by
  have hval : p2.val - p1.val = (impulse F dt).val := by
    simpa using congrArg Quantity.val h
  have hsum : p2.val = p1.val + (impulse F dt).val := by
    linarith [hval]
  ext
  simpa using hsum

/-- 完全非弹性碰撞中总动量守恒（利用碰后公共速度定义）。 -/
theorem momentum_conservation_inelastic (m1 m2 : Mass) (v1 v2 : Speed)
    (h : (m1 + m2).val ≠ 0) :
    (m1 + m2) * postCollisionSpeedInelastic m1 m2 v1 v2 = m1 * v1 + m2 * v2 := by
  have h0 : m1.val + m2.val ≠ 0 := by
    simpa using h
  ext
  calc
    ((m1 + m2) * postCollisionSpeedInelastic m1 m2 v1 v2).val
        = (m1.val + m2.val) * ((m1.val * v1.val + m2.val * v2.val) / (m1.val + m2.val)) := by
          simp [postCollisionSpeedInelastic, Quantity.cast_val]
    _ = m1.val * v1.val + m2.val * v2.val := by
      exact mul_div_cancel₀ (m1.val * v1.val + m2.val * v2.val) h0
    _ = (m1 * v1 + m2 * v2).val := by
      simp

/-- 冲量定义的展开式：`I = F Δt`（含量纲转换）。 -/
theorem impulse_def (F : Force) (dt : Time) :
    impulse F dt = Quantity.cast (F * dt) SI.force_time_eq_momentum := rfl

example : (impulse ((4 : ℝ) • newton) ((3 : ℝ) • second)).val = 12 := by
  norm_num [impulse, newton, second, Quantity.standardUnit, Quantity.cast_val]

example (p2 p1 : Momentum) (F : Force) (dt : Time)
    (h : p2 - p1 = impulse F dt) :
    p2 = p1 + impulse F dt :=
  impulse_momentum_theorem p2 p1 F dt h

example (m1 m2 : Mass) (v1 v2 : Speed) (h : (m1 + m2).val ≠ 0) :
    (m1 + m2) * postCollisionSpeedInelastic m1 m2 v1 v2 = m1 * v1 + m2 * v2 :=
  momentum_conservation_inelastic m1 m2 v1 v2 h

end
end MomentumImpulse
end Mechanics
end MechLib
