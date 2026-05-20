import Mathlib
import MechLib.Mechanics.MomentumImpulse

namespace MechLib
namespace Mechanics
namespace Rotation

open Units SI

noncomputable section

def torque (r : VecLength 3) (F : VecForce 3) : VecTorque 3 :=
  VecQuantity.cast (r ×ᵥ F) SI.length_plus_force_eq_torque

def angularMomentum (r : VecLength 3) (p : VecMomentum 3) : VecAngularMomentum 3 :=
  VecQuantity.cast (r ×ᵥ p) SI.length_plus_momentum_eq_angularMomentum

def rotationalKineticEnergy (I : MomentOfInertia) (omega : AngularVelocity) : Energy :=
  (1 / 2 : ℝ) • Quantity.cast (I * (omega ** 2)) SI.moi_plus_omega_sq_eq_energy

def parallelAxis (Icm : MomentOfInertia) (m : Mass) (d : Length) : MomentOfInertia :=
  Icm + m * (d ** 2)

/-- 转动动能公式展开：`E_rot = 1/2 I ω^2`。 -/
abbrev rotationalKineticEnergy_eq (I : MomentOfInertia) (omega : AngularVelocity) :
    rotationalKineticEnergy I omega
      = (1 / 2 : ℝ) • Quantity.cast (I * (omega ** 2)) SI.moi_plus_omega_sq_eq_energy := rfl

/-- 平行轴定理公式展开：`I = I_cm + m d^2`。 -/
abbrev parallel_axis_theorem (Icm : MomentOfInertia) (m : Mass) (d : Length) :
    parallelAxis Icm m d = Icm + m * (d ** 2) := rfl

/-- 力矩定义展开：`τ = r × F`（含量纲转换）。 -/
abbrev torque_def (r : VecLength 3) (F : VecForce 3) :
    torque r F = VecQuantity.cast (r ×ᵥ F) SI.length_plus_force_eq_torque := rfl

/-- 惯量张量（接口：采用 `3x3` 实矩阵表示）。 -/
abbrev InertiaTensor := Matrix (Fin 3) (Fin 3) ℝ

abbrev zero_add_zero_dim_eq_zero : ((0 : Dim) + (0 : Dim)) = (0 : Dim) := by
  native_decide

/-- 刚体主轴系下欧拉方程接口。 -/
def EulerEquationsPrincipal
    (I1 I2 I3 : ℝ)
    (ω1 ω2 ω3 τ1 τ2 τ3 : ℝ → ℝ) : Prop :=
  (∀ t, I1 * (deriv ω1 t) + (I3 - I2) * ω2 t * ω3 t = τ1 t)
    ∧ (∀ t, I2 * (deriv ω2 t) + (I1 - I3) * ω3 t * ω1 t = τ2 t)
    ∧ (∀ t, I3 * (deriv ω3 t) + (I2 - I1) * ω1 t * ω2 t = τ3 t)

/-- 刚体总动能分解接口：`T = T_trans + T_rot`。 -/
def RigidBodyKineticDecomposition
    (T Ttrans Trot : Energy) : Prop :=
  T = Ttrans + Trot

/-- 旋转参考系输运律接口（角动量版）。 -/
def AngularMomentumTransport
    (dLInertial dLRelative : ℝ → VecQuantity (0 : Dim) 3)
    (omega : ℝ → VecQuantity (0 : Dim) 3)
    (L : ℝ → VecQuantity (0 : Dim) 3) : Prop :=
  ∀ t, dLInertial t = dLRelative t + VecQuantity.cast (omega t ×ᵥ L t) zero_add_zero_dim_eq_zero

/-- 质点形式角动量定理接口。 -/
def AngularMomentumTheoremParticle
    (Ldot : ℝ → VecTorque 3) (τ : ℝ → VecTorque 3) : Prop :=
  ∀ t, Ldot t = τ t

/-- 系统关于点 `O` 的动量矩定理接口。 -/
def MomentOfMomentumTheoremSystem
    (LdotO MextO : ℝ → VecTorque 3) : Prop :=
  ∀ t, LdotO t = MextO t

abbrev rigidBodyKineticDecomposition_eq (T Ttrans Trot : Energy) :
    RigidBodyKineticDecomposition T Ttrans Trot = (T = Ttrans + Trot) := rfl

abbrev angularMomentumTheoremParticle_eq (Ldot τ : ℝ → VecTorque 3) :
    AngularMomentumTheoremParticle Ldot τ = (∀ t, Ldot t = τ t) := rfl

abbrev momentOfMomentumTheoremSystem_eq (LdotO MextO : ℝ → VecTorque 3) :
    MomentOfMomentumTheoremSystem LdotO MextO = (∀ t, LdotO t = MextO t) := rfl

example : (rotationalKineticEnergy ((2 : ℝ) • momentOfInertiaUnit) ((3 : ℝ) • hertz)).val = 9 := by
  norm_num [rotationalKineticEnergy, momentOfInertiaUnit, hertz, kilogram, meter,
    Quantity.standardUnit, Quantity.cast_val]

example (Icm : MomentOfInertia) (m : Mass) (d : Length) :
    parallelAxis Icm m d = Icm + m * (d ** 2) := rfl

example (r : VecLength 3) (F : VecForce 3) :
    torque r F = VecQuantity.cast (r ×ᵥ F) SI.length_plus_force_eq_torque := rfl

-- DONE[MECH_RB_01]: added inertia-tensor formal interface (`InertiaTensor`).
-- DONE[MECH_RB_02]: added principal-axis Euler-equation interface (`EulerEquationsPrincipal`).
-- DONE[MECH_RB_03]: added rigid-body kinetic decomposition interface (`RigidBodyKineticDecomposition`).
-- DONE[MECH_RB_04]: added rotating-frame transport interface (`AngularMomentumTransport`).
-- DONE[MECH_AM_01]: added particle angular-momentum theorem interface (`AngularMomentumTheoremParticle`).
-- DONE[MECH_MM_01]: added system moment-of-momentum theorem interface (`MomentOfMomentumTheoremSystem`).

end
end Rotation
end Mechanics
end MechLib
