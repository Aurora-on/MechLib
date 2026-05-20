import Mathlib
import MechLib.Mechanics.Rotation

/-!
Verified theorem declarations migrated from `MechLib.Mechanics.*`.

The old `MechLib.Mechanics.*` names are compatibility abbreviations; these
course-layer declarations are the retrieval-facing theorem locations.
-/

namespace MechLib
namespace RigidBody
namespace Verified

open Units SI
open MechLib.Mechanics

noncomputable section

namespace Rotation
open MechLib.Mechanics.Rotation

/-- Migrated from `MechLib.Mechanics.Rotation.rotationalKineticEnergy_eq`. -/
theorem rotationalKineticEnergy_eq (I : MomentOfInertia) (omega : AngularVelocity) :
    rotationalKineticEnergy I omega
      = (1 / 2 : ℝ) • Quantity.cast (I * (omega ** 2)) SI.moi_plus_omega_sq_eq_energy
 := by
  simpa using MechLib.Mechanics.Rotation.rotationalKineticEnergy_eq I omega

/-- Migrated from `MechLib.Mechanics.Rotation.parallel_axis_theorem`. -/
theorem parallel_axis_theorem (Icm : MomentOfInertia) (m : Mass) (d : Length) :
    parallelAxis Icm m d = Icm + m * (d ** 2)
 := by
  simpa using MechLib.Mechanics.Rotation.parallel_axis_theorem Icm m d

/-- Migrated from `MechLib.Mechanics.Rotation.torque_def`. -/
theorem torque_def (r : VecLength 3) (F : VecForce 3) :
    torque r F = VecQuantity.cast (r ×ᵥ F) SI.length_plus_force_eq_torque
 := by
  simpa using MechLib.Mechanics.Rotation.torque_def r F

/-- Migrated from `MechLib.Mechanics.Rotation.zero_add_zero_dim_eq_zero`. -/
theorem zero_add_zero_dim_eq_zero : ((0 : Dim) + (0 : Dim)) = (0 : Dim)
 := by
  simpa using MechLib.Mechanics.Rotation.zero_add_zero_dim_eq_zero

/-- Migrated from `MechLib.Mechanics.Rotation.rigidBodyKineticDecomposition_eq`. -/
theorem rigidBodyKineticDecomposition_eq (T Ttrans Trot : Energy) :
    RigidBodyKineticDecomposition T Ttrans Trot = (T = Ttrans + Trot)
 := by
  simpa using MechLib.Mechanics.Rotation.rigidBodyKineticDecomposition_eq T Ttrans Trot

/-- Migrated from `MechLib.Mechanics.Rotation.angularMomentumTheoremParticle_eq`. -/
theorem angularMomentumTheoremParticle_eq (Ldot τ : ℝ → VecTorque 3) :
    AngularMomentumTheoremParticle Ldot τ = (∀ t, Ldot t = τ t)
 := by
  simpa using MechLib.Mechanics.Rotation.angularMomentumTheoremParticle_eq Ldot τ

/-- Migrated from `MechLib.Mechanics.Rotation.momentOfMomentumTheoremSystem_eq`. -/
theorem momentOfMomentumTheoremSystem_eq (LdotO MextO : ℝ → VecTorque 3) :
    MomentOfMomentumTheoremSystem LdotO MextO = (∀ t, LdotO t = MextO t)
 := by
  simpa using MechLib.Mechanics.Rotation.momentOfMomentumTheoremSystem_eq LdotO MextO

end Rotation

end
end Verified
end RigidBody
end MechLib
