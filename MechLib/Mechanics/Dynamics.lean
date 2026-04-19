import Mathlib
import MechLib.Mechanics.Kinematics

namespace MechLib
namespace Mechanics
namespace Dynamics

open Units SI

def secondLaw (m : Mass) (a : Acceleration) : Force := m * a

abbrev F_of (m : Mass) (a : Acceleration) : Force := secondLaw m a

/-- 牛顿第二定律的别名展开：`F = m a`。 -/
@[simp] theorem newton_second_law (m : Mass) (a : Acceleration) : F_of m a = m * a := rfl

def momentum (m : Mass) (v : Speed) : Momentum := m * v

def secondLawVec {n : ℕ} (m : Mass) (a : VecAcceleration n) : VecForce n := m * a

/-- 牛顿第二定律的向量形式展开。 -/
@[simp] theorem secondLawVec_eq {n : ℕ} (m : Mass) (a : VecAcceleration n) :
    secondLawVec m a = m * a := rfl

/-- 质量恒定时的动量变化公式：`Δp = m Δv`。 -/
theorem momentum_change_const_mass (m : Mass) (v₂ v₁ : Speed) :
    momentum m v₂ - momentum m v₁ = m * (v₂ - v₁) := by
  ext
  simp [momentum]
  ring

/-- 质量恒定时，由速度变化率得到受力表达 `F = m dv/dt`。 -/
theorem force_from_velocity_rate_const_mass (m : Mass) (dvdt : Acceleration) :
    secondLaw m dvdt = m * dvdt := rfl

example : (secondLaw ((2 : ℝ) • kilogram) ((3 : ℝ) • meter / (second ** 2))).val = 6 := by
  norm_num [secondLaw, kilogram, meter, second, Quantity.standardUnit]

example (m : Mass) (a : Acceleration) : F_of m a = m * a := by
  exact newton_second_law m a

example (m : Mass) (a : VecAcceleration 3) :
    secondLawVec m a = m * a := rfl

end Dynamics
end Mechanics
end MechLib
