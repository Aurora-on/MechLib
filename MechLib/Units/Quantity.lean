import Mathlib
import MechLib.Units.Dim

namespace MechLib
namespace Units

noncomputable section

/-- Scalar physical quantity with dimension `d`. -/
@[ext]
structure Quantity (d : Dim) where
  val : ℝ

namespace Quantity

instance {d : Dim} : Zero (Quantity d) where
  zero := ⟨0⟩

instance {d : Dim} : Add (Quantity d) where
  add q₁ q₂ := ⟨q₁.val + q₂.val⟩

instance {d : Dim} : Sub (Quantity d) where
  sub q₁ q₂ := ⟨q₁.val - q₂.val⟩

instance {d : Dim} : Neg (Quantity d) where
  neg q := ⟨-q.val⟩

instance {d : Dim} : SMul ℝ (Quantity d) where
  smul c q := ⟨c * q.val⟩

@[simp] theorem val_zero {d : Dim} : (0 : Quantity d).val = 0 := rfl
@[simp] theorem val_add {d : Dim} (q₁ q₂ : Quantity d) : (q₁ + q₂).val = q₁.val + q₂.val := rfl
@[simp] theorem val_sub {d : Dim} (q₁ q₂ : Quantity d) : (q₁ - q₂).val = q₁.val - q₂.val := rfl
@[simp] theorem val_neg {d : Dim} (q : Quantity d) : (-q).val = -q.val := rfl
@[simp] theorem val_smul {d : Dim} (c : ℝ) (q : Quantity d) : (c • q).val = c * q.val := rfl

instance {d₁ d₂ : Dim} : HMul (Quantity d₁) (Quantity d₂) (Quantity (d₁ + d₂)) where
  hMul q₁ q₂ := ⟨q₁.val * q₂.val⟩

instance {d₁ d₂ : Dim} : HDiv (Quantity d₁) (Quantity d₂) (Quantity (d₁ - d₂)) where
  hDiv q₁ q₂ := ⟨q₁.val / q₂.val⟩

instance {d : Dim} : HDiv (Quantity d) ℝ (Quantity d) where
  hDiv q r := ⟨q.val / r⟩

@[simp] theorem val_mul {d₁ d₂ : Dim} (q₁ : Quantity d₁) (q₂ : Quantity d₂) :
    (q₁ * q₂).val = q₁.val * q₂.val := rfl

@[simp] theorem val_div {d₁ d₂ : Dim} (q₁ : Quantity d₁) (q₂ : Quantity d₂) :
    (q₁ / q₂).val = q₁.val / q₂.val := rfl

@[simp] theorem val_div_real {d : Dim} (q : Quantity d) (r : ℝ) :
    (q / r).val = q.val / r := rfl

def pow {d : Dim} (q : Quantity d) (n : ℕ) : Quantity (n • d) := ⟨q.val ^ n⟩
infixr:80 " ** " => pow

@[simp] theorem val_pow {d : Dim} (q : Quantity d) (n : ℕ) : (q ** n).val = q.val ^ n := rfl

def inv {d : Dim} (q : Quantity d) : Quantity (-d) := ⟨q.val⁻¹⟩
@[simp] theorem val_inv {d : Dim} (q : Quantity d) : (inv q).val = q.val⁻¹ := rfl

def ofReal (r : ℝ) : Quantity (0 : Dim) := ⟨r⟩
instance : Coe ℝ (Quantity (0 : Dim)) where
  coe := ofReal
@[simp] theorem val_ofReal (r : ℝ) : (ofReal r).val = r := rfl

def cast {d d' : Dim} (q : Quantity d) (h : d = d') : Quantity d' := by
  cases h
  exact q

@[simp]
theorem cast_val {d d' : Dim} (q : Quantity d) (h : d = d') : (cast q h).val = q.val := by
  cases h
  rfl

/-- Unit element in any dimension (value = 1 in that unit). -/
def standardUnit (d : Dim) : Quantity d := ⟨1⟩

@[simp] theorem standardUnit_val (d : Dim) : (standardUnit d).val = 1 := rfl

/-- Numeric value of `q` measured in the chosen unit `unit`. -/
def inUnits {d : Dim} (unit q : Quantity d) : ℝ := q.val / unit.val
@[simp] theorem inUnits_def {d : Dim} (unit q : Quantity d) : inUnits unit q = q.val / unit.val := rfl

theorem inUnits_self {d : Dim} (unit : Quantity d) (h : unit.val ≠ 0) :
    inUnits unit unit = 1 := by
  simp [inUnits, h]

theorem inUnits_trans {d : Dim} (u1 u2 q : Quantity d) (h : u2.val ≠ 0) :
    inUnits u1 q = inUnits u1 u2 * inUnits u2 q := by
  unfold inUnits
  field_simp [h]

theorem inUnits_mul_symm {d : Dim} (u1 u2 : Quantity d) (h1 : u1.val ≠ 0) (h2 : u2.val ≠ 0) :
    inUnits u1 u2 * inUnits u2 u1 = 1 := by
  unfold inUnits
  field_simp [h1, h2]

theorem inUnits_inv_eq_swap {d : Dim} (u1 u2 : Quantity d) (h1 : u1.val ≠ 0) (h2 : u2.val ≠ 0) :
    (inUnits u1 u2)⁻¹ = inUnits u2 u1 := by
  unfold inUnits
  field_simp [h1, h2]

theorem inUnits_eq_smul_unit {d : Dim} (unit q : Quantity d) (h : unit.val ≠ 0) :
    q = (inUnits unit q) • unit := by
  ext
  simp [inUnits, h]

theorem inUnits_injective {d : Dim} (unit q₁ q₂ : Quantity d) (h : unit.val ≠ 0) :
    inUnits unit q₁ = inUnits unit q₂ ↔ q₁ = q₂ := by
  constructor
  · intro hEq
    ext
    have : q₁.val / unit.val = q₂.val / unit.val := hEq
    field_simp [h] at this
    exact this
  · intro hEq
    simp [hEq]

end Quantity

end
end Units
end MechLib
