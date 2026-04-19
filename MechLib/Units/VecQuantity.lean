import Mathlib
import MechLib.Units.Quantity

namespace MechLib
namespace Units

open BigOperators

noncomputable section

/-- Vector-valued quantity in `n` dimensions, carrying dimension `d`. -/
@[ext]
structure VecQuantity (d : Dim) (n : ℕ) where
  val : Fin n → ℝ

namespace VecQuantity

instance {d : Dim} {n : ℕ} : Zero (VecQuantity d n) where
  zero := ⟨fun _ => 0⟩

instance {d : Dim} {n : ℕ} : Add (VecQuantity d n) where
  add v w := ⟨fun i => v.val i + w.val i⟩

instance {d : Dim} {n : ℕ} : Sub (VecQuantity d n) where
  sub v w := ⟨fun i => v.val i - w.val i⟩

instance {d : Dim} {n : ℕ} : Neg (VecQuantity d n) where
  neg v := ⟨fun i => -v.val i⟩

instance {d : Dim} {n : ℕ} : SMul ℝ (VecQuantity d n) where
  smul c v := ⟨fun i => c * v.val i⟩

@[simp] theorem val_zero {d : Dim} {n : ℕ} : (0 : VecQuantity d n).val = fun _ => 0 := rfl
@[simp] theorem val_add {d : Dim} {n : ℕ} (v w : VecQuantity d n) :
    (v + w).val = fun i => v.val i + w.val i := rfl
@[simp] theorem val_sub {d : Dim} {n : ℕ} (v w : VecQuantity d n) :
    (v - w).val = fun i => v.val i - w.val i := rfl
@[simp] theorem val_neg {d : Dim} {n : ℕ} (v : VecQuantity d n) :
    (-v).val = fun i => -v.val i := rfl
@[simp] theorem val_smul {d : Dim} {n : ℕ} (c : ℝ) (v : VecQuantity d n) :
    (c • v).val = fun i => c * v.val i := rfl

def cast {d d' : Dim} {n : ℕ} (v : VecQuantity d n) (h : d = d') : VecQuantity d' n := by
  cases h
  exact v

@[simp]
theorem cast_val {d d' : Dim} {n : ℕ} (v : VecQuantity d n) (h : d = d') :
    (cast v h).val = v.val := by
  cases h
  rfl

instance {d₁ d₂ : Dim} {n : ℕ} :
    HMul (Quantity d₁) (VecQuantity d₂ n) (VecQuantity (d₁ + d₂) n) where
  hMul q v := ⟨fun i => q.val * v.val i⟩

instance {d₁ d₂ : Dim} {n : ℕ} :
    HMul (VecQuantity d₁ n) (Quantity d₂) (VecQuantity (d₁ + d₂) n) where
  hMul v q := ⟨fun i => q.val * v.val i⟩

@[simp] theorem val_qmul_vec {d₁ d₂ : Dim} {n : ℕ} (q : Quantity d₁) (v : VecQuantity d₂ n) :
    (q * v).val = fun i => q.val * v.val i := rfl

@[simp] theorem val_vecmul_q {d₁ d₂ : Dim} {n : ℕ} (v : VecQuantity d₁ n) (q : Quantity d₂) :
    (v * q).val = fun i => q.val * v.val i := rfl

def dot {d₁ d₂ : Dim} {n : ℕ} (v : VecQuantity d₁ n) (w : VecQuantity d₂ n) :
    Quantity (d₁ + d₂) := ⟨∑ i, v.val i * w.val i⟩

infixl:75 " ⬝ᵥ " => dot

@[simp] theorem dot_val {d₁ d₂ : Dim} {n : ℕ} (v : VecQuantity d₁ n) (w : VecQuantity d₂ n) :
    (v ⬝ᵥ w).val = ∑ i, v.val i * w.val i := rfl

def cross {d₁ d₂ : Dim} (u : VecQuantity d₁ 3) (v : VecQuantity d₂ 3) :
    VecQuantity (d₁ + d₂) 3 :=
  ⟨fun i =>
    Fin.cases
      (u.val 1 * v.val 2 - u.val 2 * v.val 1)
      (fun j =>
        Fin.cases
          (u.val 2 * v.val 0 - u.val 0 * v.val 2)
          (fun _ => u.val 0 * v.val 1 - u.val 1 * v.val 0)
          j)
      i⟩

infixl:70 " ×ᵥ " => cross

def const {d : Dim} {n : ℕ} (x : ℝ) : VecQuantity d n := ⟨fun _ => x⟩
def oneD {d : Dim} (x : ℝ) : VecQuantity d 1 := ⟨fun _ => x⟩

end VecQuantity

end
end Units
end MechLib
