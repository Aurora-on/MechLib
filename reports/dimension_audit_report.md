# MechLib Dimension Usage Audit

- generated_at_utc: `2026-05-15T09:57:16.463575+00:00`
- core files present: `True`
- core imports present in `MechLib.lean`: `True`
- course-layer files scanned: `57`
- raw `ℝ` occurrences in course layer: `187`
- allowed/classified occurrences: `154`
- temporary fallback occurrences: `8`
- untyped course API review candidates: `25`
- task 5.5 baseline untyped count: `30`
- fixed since task 5.5: `5`
- duplicate physical alias review count: `1`
- exported Units/SI theorem rows: `84`

## Global Principle

MechLib's core feature is the dimensioned physical quantity system. Public physics APIs should prefer `MechLib.SI` aliases, `Quantity`, and `VecQuantity`; raw `ℝ` should be limited to dimensionless coefficients, mathematical indices, chart coordinates, `.val` projections, metadata, or explicitly documented temporary untyped fallbacks.

## Core Dimension Modules

- `MechLib/Units/Dim.lean`: exists = `True`
- `MechLib/Units/Quantity.lean`: exists = `True`
- `MechLib/Units/VecQuantity.lean`: exists = `True`
- `MechLib/SI.lean`: exists = `True`

- `import MechLib.Units.Dim` in `MechLib.lean`: `True`
- `import MechLib.Units.Quantity` in `MechLib.lean`: `True`
- `import MechLib.Units.VecQuantity` in `MechLib.lean`: `True`
- `import MechLib.SI` in `MechLib.lean`: `True`

## Physical Type Alias Audit

- canonical SI aliases: `18`
- forwarding wrapper aliases: `2`
- compat forwarding aliases: `9`
- review aliases: `1`

| Alias | File | Line | RHS |
| --- | --- | ---: | --- |
| `Acceleration` | `MechLib/Kinematics/PointMotion.lean` | 48 | `MechLib.SI.Acceleration` |

## Course-Layer `ℝ` Classification

| Classification | Count |
| --- | ---: |
| `angle_chart_value` | 10 |
| `coordinate_chart_or_temporary_untyped` | 9 |
| `dimensionless` | 6 |
| `math_helper_or_local_value` | 41 |
| `matrix_or_index_value` | 16 |
| `public_real_api_review` | 16 |
| `temporary_untyped_fallback` | 8 |
| `time_parameter_with_typed_output` | 63 |
| `value_projection` | 18 |

## Typed Migration Highlights

- Pendulum: `kineticEnergy`, `potentialEnergy`, `lagrangian`, `equationResidual`, and `smallAngle_to_SHM` now use `Energy`, `PhysAngle`, `AngularVelocity`, `AngularAcceleration`, and `Time`; value-level wrappers are retained as `...Value` fallbacks.
- CentralForce: `PolarState`, `kineticEnergyPolar`, `angularMomentum`, `effectivePotential`, circular-orbit conditions, and angular-momentum conservation now use `Length`, `Speed`, `AngularVelocity`, `Energy`, `AngularMomentum`, `Force`, `SpringConstant`, and `Time`; `effectivePotentialScalar` remains as a fallback.
- CoupledOscillator: mass and stiffness matrices now use `Mass` and `SpringConstant`; coordinates and velocities use `Length` and `Speed`; the Lagrangian returns `Energy`; normal-mode residual uses `AngularVelocitySquared`; `quadraticFormValue` remains as a scalar matrix helper.
- SI: added `AngularAcceleration` and `AngularVelocitySquared` aliases plus bridge lemmas for acceleration and spring-constant dimensions.

## Temporary Untyped Fallbacks

| File | Line | Code | Reason |
| --- | ---: | --- | --- |
| `MechLib/Systems/CentralForce.lean` | 72 | `def effectivePotentialScalar (U : ℝ → ℝ) (mass angularMomentum radius : ℝ) : ℝ :=` | explicit compatibility value-level wrapper retained beside a typed public API |
| `MechLib/Systems/CentralForce.lean` | 73 | `U radius + angularMomentum ^ 2 / ((2 : ℝ) * mass * radius ^ 2)` | explicit compatibility value-level wrapper retained beside a typed public API |
| `MechLib/Systems/CoupledOscillator.lean` | 57 | `def quadraticFormValue {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ) (v : Fin n → ℝ) : ℝ :=` | explicit compatibility value-level wrapper retained beside a typed public API |
| `MechLib/Systems/Pendulum.lean` | 54 | `def kineticEnergyValue (params : Params) (thetaDot : ℝ) : ℝ :=` | explicit compatibility value-level wrapper retained beside a typed public API |
| `MechLib/Systems/Pendulum.lean` | 55 | `(1 / 2 : ℝ) * params.mass.val * params.length.val ^ 2 * thetaDot ^ 2` | explicit compatibility value-level wrapper retained beside a typed public API |
| `MechLib/Systems/Pendulum.lean` | 64 | `def potentialEnergyValue (params : Params) (theta : ℝ) : ℝ :=` | explicit compatibility value-level wrapper retained beside a typed public API |
| `MechLib/Systems/Pendulum.lean` | 74 | `def lagrangianValue (params : Params) (theta thetaDot : ℝ) : ℝ :=` | explicit compatibility value-level wrapper retained beside a typed public API |
| `MechLib/Systems/Pendulum.lean` | 115 | `(1 / 2 : ℝ) * params.mass.val * params.length.val ^ 2 * thetaDot ^ 2` | explicit compatibility value-level wrapper retained beside a typed public API |

## Review Candidates By File

| File | Count |
| --- | ---: |
| `MechLib/Analytical/ConservationLaw.lean` | 2 |
| `MechLib/Analytical/LagrangeEquation.lean` | 2 |
| `MechLib/Analytical/PoissonBracket.lean` | 1 |
| `MechLib/Dynamics/Verified.lean` | 1 |
| `MechLib/Foundation/Geometry.lean` | 1 |
| `MechLib/Kinematics/FixedAxisRotation.lean` | 1 |
| `MechLib/Kinematics/Verified.lean` | 1 |
| `MechLib/RigidBody/Verified.lean` | 2 |
| `MechLib/Systems/AtwoodMachine.lean` | 6 |
| `MechLib/Systems/BeadOnHoop.lean` | 2 |
| `MechLib/Systems/PhysicalPendulum.lean` | 2 |
| `MechLib/Systems/RollingDisk.lean` | 3 |
| `MechLib/Systems/Verified.lean` | 1 |

## Review Candidate Details

| File | Line | Classification | Code |
| --- | ---: | --- | --- |
| `MechLib/Analytical/ConservationLaw.lean` | 63 | `public_real_api_review` | `def ConservedScalar (quantity : ℝ → ℝ) : Prop :=` |
| `MechLib/Analytical/ConservationLaw.lean` | 81 | `public_real_api_review` | `example (quantity : ℝ → ℝ) :` |
| `MechLib/Analytical/LagrangeEquation.lean` | 70 | `coordinate_chart_or_temporary_untyped` | `(q : GCoord system.coordSpec) (qdot : GVel system.coordSpec) (t : ℝ)` |
| `MechLib/Analytical/LagrangeEquation.lean` | 147 | `coordinate_chart_or_temporary_untyped` | `HasDerivAt (fun (ε : ℝ) => S (fun t => q t + ε • η t)) 0 0` |
| `MechLib/Analytical/PoissonBracket.lean` | 52 | `public_real_api_review` | `abbrev PhaseFunction1D := MechLib.SI.Length → MechLib.SI.Momentum → ℝ` |
| `MechLib/Dynamics/Verified.lean` | 192 | `public_real_api_review` | `theorem centerOfMassTheorem_eq (M : Mass) (Rddot : ℝ → Acceleration) (Fext : ℝ → Force) :` |
| `MechLib/Foundation/Geometry.lean` | 41 | `public_real_api_review` | `def DistanceResidual (distance : MechLib.SI.Length) (value : ℝ) : Prop :=` |
| `MechLib/Kinematics/FixedAxisRotation.lean` | 60 | `public_real_api_review` | `def FixedAxisRotationResidual (state : ℝ → FixedAxisRotationState) : Prop :=` |
| `MechLib/Kinematics/Verified.lean` | 100 | `coordinate_chart_or_temporary_untyped` | `(x1 x2 : ScalarTrajectory) (v1 v2 : ScalarVelocityField) (c1 c2 : ℝ)` |
| `MechLib/RigidBody/Verified.lean` | 54 | `public_real_api_review` | `theorem angularMomentumTheoremParticle_eq (Ldot τ : ℝ → VecTorque 3) :` |
| `MechLib/RigidBody/Verified.lean` | 60 | `public_real_api_review` | `theorem momentOfMomentumTheoremSystem_eq (LdotO MextO : ℝ → VecTorque 3) :` |
| `MechLib/Systems/AtwoodMachine.lean` | 61 | `public_real_api_review` | `def kineticEnergy (params : Params) (qDot : ℝ) : ℝ :=` |
| `MechLib/Systems/AtwoodMachine.lean` | 65 | `coordinate_chart_or_temporary_untyped` | `def potentialEnergy (params : Params) (q : ℝ) : ℝ :=` |
| `MechLib/Systems/AtwoodMachine.lean` | 69 | `coordinate_chart_or_temporary_untyped` | `def lagrangian (params : Params) (q qDot : ℝ) : ℝ :=` |
| `MechLib/Systems/AtwoodMachine.lean` | 73 | `public_real_api_review` | `def equationResidual (params : Params) (qDDot : ℝ → ℝ) : Prop :=` |
| `MechLib/Systems/AtwoodMachine.lean` | 79 | `public_real_api_review` | `def accelerationFormula (params : Params) (a : ℝ) : Prop :=` |
| `MechLib/Systems/AtwoodMachine.lean` | 84 | `coordinate_chart_or_temporary_untyped` | `example (params : Params) (q qDot : ℝ) :` |
| `MechLib/Systems/BeadOnHoop.lean` | 65 | `public_real_api_review` | `def equilibriumCondition (dVdtheta : ℝ → ℝ) (theta0 : ℝ) : Prop :=` |
| `MechLib/Systems/BeadOnHoop.lean` | 69 | `public_real_api_review` | `def stabilityCondition (d2Vdtheta2 : ℝ → ℝ) (theta0 : ℝ) : Prop :=` |
| `MechLib/Systems/PhysicalPendulum.lean` | 57 | `public_real_api_review` | `def kineticEnergy (params : Params) (thetaDot : ℝ) : ℝ :=` |
| `MechLib/Systems/PhysicalPendulum.lean` | 78 | `public_real_api_review` | `def physical_pendulum_period (params : Params) (period : ℝ) : Prop :=` |
| `MechLib/Systems/RollingDisk.lean` | 60 | `coordinate_chart_or_temporary_untyped` | `def noSlipConstraint (radius xDot phiDot : ℝ) : Prop :=` |
| `MechLib/Systems/RollingDisk.lean` | 64 | `coordinate_chart_or_temporary_untyped` | `def nonholonomicConstraintSchema (radius xDot yDot phiDot heading : ℝ) : Prop :=` |
| `MechLib/Systems/RollingDisk.lean` | 69 | `coordinate_chart_or_temporary_untyped` | `def rollingKineticEnergy (params : Params) (centerSpeed angularVelocity : ℝ) : ℝ :=` |
| `MechLib/Systems/Verified.lean` | 301 | `public_real_api_review` | `theorem keplerSecondLaw_eq (arealVelocity : ℝ → ℝ) :` |

## Exporter Check

- theorem corpus: `corpus/theorem_corpus.jsonl`
- exists: `True`
- exports dimension theorem rows: `True`

| Module | Rows |
| --- | ---: |
| `MechLib.SI` | 36 |
| `MechLib.Units.BridgeLemmas` | 9 |
| `MechLib.Units.Dim` | 10 |
| `MechLib.Units.Quantity` | 20 |
| `MechLib.Units.VecQuantity` | 9 |

## Recommendations

- Keep `MechLib.Units.Dim`, `Quantity`, `VecQuantity`, and `MechLib.SI` imported by the top-level `MechLib.lean` entry.
- Do not add parallel `Length`, `Mass`, `Force`, `Energy`, or similar type aliases outside `MechLib.SI`; course modules may forward to `MechLib.SI` only when needed for ergonomics.
- Prioritize typed `MechLib.SI.Energy`, `Length`, `Mass`, `Force`, `Speed`, and `VecQuantity` signatures for new public physics APIs.
- When a system schema remains value-level, document whether each raw `ℝ` is a dimensionless coordinate, a chart value, a `.val` projection, or a temporary untyped fallback.
- Keep Units/SI theorem and bridge lemma rows in theorem and enriched declaration corpora for retrieval and statement generation.
