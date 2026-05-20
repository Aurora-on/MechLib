import Mathlib
import MechLib.Mechanics.Dynamics

namespace MechLib
namespace Mechanics
namespace WorkEnergy

open Units SI

noncomputable section

def work {n : ℕ} (F : VecForce n) (s : VecLength n) : Energy := F ⬝ᵥ s

def kineticEnergy {n : ℕ} (m : Mass) (v : VecSpeed n) : Energy :=
  (1 / 2 : ℝ) • Quantity.cast (m * (v ⬝ᵥ v)) SI.mass_speed_sq_eq_energy

def kineticEnergy1D (m : Mass) (v : Speed) : Energy :=
  (1 / 2 : ℝ) • Quantity.cast (m * (v ** 2)) SI.mass_two_speed_eq_energy

def springPotential (k : SpringConstant) (x : Length) : Energy :=
  (1 / 2 : ℝ) • Quantity.cast (k * (x ** 2)) SI.spring_plus_two_length_eq_energy

def hookeForce (k : SpringConstant) (x : Length) : Force :=
  Quantity.cast (-(k * x)) SI.spring_plus_length_eq_force

/-- 胡克定律力的定义展开：`F = -k x`（含量纲转换）。 -/
abbrev hooke_force_eq (k : SpringConstant) (x : Length) :
    hookeForce k x = Quantity.cast (-(k * x)) SI.spring_plus_length_eq_force := rfl

/-- 一维动能变化公式：`K2 - K1 = 1/2 m (v2^2 - v1^2)`。 -/
abbrev kineticEnergy_change_formula (m : Mass) (v2 v1 : Speed) :
    kineticEnergy1D m v2 - kineticEnergy1D m v1 =
      (1 / 2 : ℝ) • Quantity.cast (m * ((v2 ** 2) - (v1 ** 2))) SI.mass_two_speed_eq_energy := by
  ext
  simp [kineticEnergy1D, Quantity.cast_val]
  ring

/-- 功的定义展开：`W = F · s`。 -/
abbrev work_def {n : ℕ} (F : VecForce n) (s : VecLength n) : work F s = F ⬝ᵥ s := rfl

abbrev force_length_eq_energy : SI.forceDim + SI.lengthDim = SI.energyDim := by native_decide

/-- 一维功表达 `W = F Δx`。 -/
def work1D (F : Force) (dx : Length) : Energy :=
  Quantity.cast (F * dx) force_length_eq_energy

/-- 一维功表达展开。 -/
abbrev work1D_def (F : Force) (dx : Length) :
    work1D F dx = Quantity.cast (F * dx) force_length_eq_energy := rfl

/-- 功-能定理（主干形式）：若 `W_net = K2 - K1`，则 `K2 = K1 + W_net`。 -/
abbrev work_energy_theorem_core (Wnet K2 K1 : Energy) (h : Wnet = K2 - K1) :
    K2 = K1 + Wnet := by
  have hval : Wnet.val = K2.val - K1.val := by
    simpa using congrArg Quantity.val h
  have hsum : K2.val = K1.val + Wnet.val := by
    linarith [hval]
  ext
  simpa using hsum

/-- 保守/非保守分解：`W_net = W_cons + W_noncons` 与 `W_cons = -ΔU` 蕴含
`Δ(K+U) = W_noncons`。 -/
abbrev conservative_nonconservative_split
    (K2 K1 U2 U1 Wnet Wcons Wnoncons : Energy)
    (hNet : Wnet = K2 - K1)
    (hCons : Wcons = -(U2 - U1))
    (hDecomp : Wnet = Wcons + Wnoncons) :
    (K2 + U2) - (K1 + U1) = Wnoncons := by
  have hNetVal : Wnet.val = K2.val - K1.val := by
    simpa using congrArg Quantity.val hNet
  have hConsVal : Wcons.val = -(U2.val - U1.val) := by
    simpa using congrArg Quantity.val hCons
  have hDecompVal : Wnet.val = Wcons.val + Wnoncons.val := by
    simpa using congrArg Quantity.val hDecomp
  have hTarget : (K2.val + U2.val) - (K1.val + U1.val) = Wnoncons.val := by
    linarith [hNetVal, hConsVal, hDecompVal]
  ext
  simpa using hTarget

example :
    (work (F := (VecQuantity.oneD (d := forceDim) 10))
      (s := (VecQuantity.oneD (d := lengthDim) 5))).val = 50 := by
  simp [work, VecQuantity.dot, VecQuantity.oneD]
  norm_num

example (m : Mass) (v2 v1 : Speed) :
    kineticEnergy1D m v2 - kineticEnergy1D m v1 =
      (1 / 2 : ℝ) • Quantity.cast (m * ((v2 ** 2) - (v1 ** 2))) SI.mass_two_speed_eq_energy :=
  kineticEnergy_change_formula m v2 v1

example (k : SpringConstant) (x : Length) :
    hookeForce k x = Quantity.cast (-(k * x)) SI.spring_plus_length_eq_force := rfl

example (Wnet K2 K1 : Energy) (h : Wnet = K2 - K1) :
    K2 = K1 + Wnet :=
  work_energy_theorem_core Wnet K2 K1 h

-- DONE[MECH_WE_01]: formalized canonical work-energy theorem core form
--   `W_net = K2 - K1 -> K2 = K1 + W_net`, with explicit `work1D` API.
-- DONE[MECH_WE_02]: formalized conservative/non-conservative split theorem
--   `Δ(K+U) = W_noncons` from `W_net = ΔK`, `W_cons = -ΔU`, and work decomposition.

end
end WorkEnergy
end Mechanics
end MechLib
