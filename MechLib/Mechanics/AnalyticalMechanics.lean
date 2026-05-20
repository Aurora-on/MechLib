import MechLib.Analytical.LagrangeEquation
import MechLib.Analytical.Hamiltonian
import MechLib.Analytical.PoissonBracket
import MechLib.Analytical.ConservationLaw
import MechLib.Analytical.Constraints

/-!
Compatibility namespace for analytical-mechanics declarations that now live in
the course-layer `MechLib.Analytical.*` modules.

New code should import and use the course-layer modules directly.
-/

namespace MechLib
namespace Mechanics
namespace AnalyticalMechanics

open Units SI

noncomputable section

abbrev momentum_two_sub_mass_eq_energy :
    (2 : ℕ) • SI.momentumDim - SI.massDim = SI.energyDim :=
  MechLib.Analytical.Hamiltonian.momentum_two_sub_mass_eq_energy

abbrev lagrangian1D := MechLib.Analytical.LagrangeEquation.lagrangian1D
abbrev canonicalMomentum1D := MechLib.Analytical.Hamiltonian.canonicalMomentum1D
abbrev hamiltonianXV := MechLib.Analytical.Hamiltonian.hamiltonianXV
abbrev hamiltonianXP := MechLib.Analytical.Hamiltonian.hamiltonianXP
abbrev eulerLagrangeResidual1D := MechLib.Analytical.LagrangeEquation.eulerLagrangeResidual1D
abbrev SatisfiesEulerLagrange1D := MechLib.Analytical.LagrangeEquation.SatisfiesEulerLagrange1D
abbrev SatisfiesNewtonForm1D := MechLib.Analytical.LagrangeEquation.SatisfiesNewtonForm1D
abbrev CanonicalEquations1D := MechLib.Analytical.Hamiltonian.CanonicalEquations1D
abbrev IsCyclicCoordinate := MechLib.Analytical.ConservationLaw.IsCyclicCoordinate1D
abbrev MomentumConserved := MechLib.Analytical.ConservationLaw.MomentumConserved1D
abbrev actionFunctional1D := MechLib.Analytical.LagrangeEquation.actionFunctional1D
abbrev stationaryAction1D := MechLib.Analytical.LagrangeEquation.stationaryAction1D
abbrev legendreRegular1D := MechLib.Analytical.Hamiltonian.legendreRegular1D
abbrev PhaseFunction1D := MechLib.Analytical.PoissonBracket.PhaseFunction1D
abbrev poissonBracket1D := MechLib.Analytical.PoissonBracket.poissonBracket1D
abbrev lagrangeMultiplierEquation1D :=
  MechLib.Analytical.Constraints.lagrangeMultiplierEquation1D

abbrev lagrangian1D_eq (m : Mass) (V : Length → Energy) (x : Length) (v : Speed) :
    lagrangian1D m V x v = Mechanics.WorkEnergy.kineticEnergy1D m v - V x :=
  MechLib.Analytical.LagrangeEquation.lagrangian1D_eq m V x v

abbrev canonicalMomentum1D_eq (m : Mass) (v : Speed) :
    canonicalMomentum1D m v = m * v :=
  MechLib.Analytical.Hamiltonian.canonicalMomentum1D_eq m v

abbrev hamiltonianXV_eq (m : Mass) (V : Length → Energy) (x : Length) (v : Speed) :
    hamiltonianXV m V x v = Mechanics.WorkEnergy.kineticEnergy1D m v + V x :=
  MechLib.Analytical.Hamiltonian.hamiltonianXV_eq m V x v

abbrev hamiltonianXP_eq (m : Mass) (V : Length → Energy) (x : Length) (p : Momentum) :
    hamiltonianXP m V x p =
      Quantity.cast ((p ** 2) / ((2 : ℝ) • m)) momentum_two_sub_mass_eq_energy + V x := by
  exact MechLib.Analytical.Hamiltonian.hamiltonianXP_eq m V x p

abbrev hamiltonianXP_of_canonicalMomentum
    (m : Mass) (V : Length → Energy) (x : Length) (v : Speed) (h : m.val ≠ 0) :
    hamiltonianXP m V x (canonicalMomentum1D m v) = hamiltonianXV m V x v :=
  MechLib.Analytical.Hamiltonian.hamiltonianXP_of_canonicalMomentum m V x v h

abbrev eulerLagrange_iff_newton
    (m : Mass) (dVdx : Length → Force)
    (x : Kinematics.ScalarTrajectory) (a : Kinematics.ScalarAccelerationField) :
    SatisfiesEulerLagrange1D m dVdx x a ↔ SatisfiesNewtonForm1D m dVdx x a :=
  MechLib.Analytical.LagrangeEquation.eulerLagrange_iff_newton m dVdx x a

abbrev canonicalEquations1D_eq
    (dHdp : Length → Momentum → Speed)
    (dHdx : Length → Momentum → Force)
    (x : Kinematics.ScalarTrajectory) (p : ℝ → Momentum)
    (xDot : Kinematics.ScalarVelocityField) (pDot : ℝ → Force) :
    CanonicalEquations1D dHdp dHdx x p xDot pDot =
      (∀ t, xDot t = dHdp (x t) (p t) ∧ pDot t = -dHdx (x t) (p t)) :=
  MechLib.Analytical.Hamiltonian.canonicalEquations1D_eq dHdp dHdx x p xDot pDot

abbrev cyclic_coordinate_implies_momentum_conserved
    (dLdq : ℝ → Force) (pDot : ℝ → Force)
    (hEq : ∀ t, pDot t = dLdq t) (hCyclic : IsCyclicCoordinate dLdq) :
    MomentumConserved pDot :=
  MechLib.Analytical.ConservationLaw.cyclic_coordinate_implies_momentum_conserved
    dLdq pDot hEq hCyclic

abbrev poissonBracket1D_antisymm
    (dFdx dFdp dGdx dGdp : PhaseFunction1D) :
    poissonBracket1D dFdx dFdp dGdx dGdp
      = fun x p => -poissonBracket1D dGdx dGdp dFdx dFdp x p :=
  MechLib.Analytical.PoissonBracket.poissonBracket1D_antisymm dFdx dFdp dGdx dGdp

abbrev lagrangeMultiplierEquation1D_eq
    (EL : ℝ → Force) (lam : ℝ → Dimensionless) (dCdq : ℝ → Force) :
    lagrangeMultiplierEquation1D EL lam dCdq =
      (∀ t, EL t = (lam t).val • dCdq t) :=
  MechLib.Analytical.Constraints.lagrangeMultiplierEquation1D_eq EL lam dCdq

end
end AnalyticalMechanics
end Mechanics
end MechLib
