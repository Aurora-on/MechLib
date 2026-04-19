import Mathlib

namespace MechLib
namespace Units

/-- The seven SI base dimensions. -/
inductive BaseDim where
  | length
  | mass
  | time
  | current
  | temperature
  | amount
  | intensity
deriving DecidableEq, Repr, Fintype

/-- A dimension is an exponent map on the SI base dimensions. -/
abbrev Dim := BaseDim → ℚ
instance : DecidableEq Dim := by
  infer_instance

namespace Dim

@[ext]
theorem ext {d₁ d₂ : Dim} (h : ∀ b, d₁ b = d₂ b) : d₁ = d₂ := funext h

/-- Basis dimension. -/
def basis (b : BaseDim) : Dim := fun b' => if b' = b then 1 else 0

@[simp]
theorem basis_apply_same (b : BaseDim) : basis b b = 1 := by simp [basis]

@[simp]
theorem basis_apply_ne {b b' : BaseDim} (h : b' ≠ b) : basis b b' = 0 := by simp [basis, h]

def length : Dim := basis .length
def mass : Dim := basis .mass
def time : Dim := basis .time
def current : Dim := basis .current
def temperature : Dim := basis .temperature
def amount : Dim := basis .amount
def intensity : Dim := basis .intensity

@[simp] theorem length_length : length .length = 1 := by simp [length, basis]
@[simp] theorem mass_mass : mass .mass = 1 := by simp [mass, basis]
@[simp] theorem time_time : time .time = 1 := by simp [time, basis]
@[simp] theorem current_current : current .current = 1 := by simp [current, basis]
@[simp] theorem temperature_temperature : temperature .temperature = 1 := by simp [temperature, basis]
@[simp] theorem amount_amount : amount .amount = 1 := by simp [amount, basis]
@[simp] theorem intensity_intensity : intensity .intensity = 1 := by simp [intensity, basis]

end Dim

end Units
end MechLib
