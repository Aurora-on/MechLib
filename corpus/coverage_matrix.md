# Theoretical Mechanics Coverage Matrix

- schema_version: `coverage-matrix-v1`
- source_module: `MechLib.Spec.Coverage`

## Foundation / 基础

| id | zh_name | en_name | status | trust_level | module_path | verified_decls | schema_decls |
| --- | --- | --- | --- | --- | --- | --- | --- |
| foundation.dimensions | 量纲 | dimensions | `verified` | `core` | `MechLib.Foundation.Dim` | MechLib.Units.Dim.ext<br>MechLib.Units.Dim.basis_apply_same<br>MechLib.Units.Dim.basis_apply_ne |  |
| foundation.quantity | 带量纲标量 | quantity | `verified` | `core` | `MechLib.Foundation.Quantity` | MechLib.Units.Quantity.cast_val<br>MechLib.Units.Quantity.inUnits_self<br>MechLib.Units.Quantity.inUnits_trans<br>MechLib.Units.Quantity.inUnits_injective |  |
| foundation.vector_quantity | 带量纲向量 | vector quantity | `verified` | `core` | `MechLib.Foundation.VecQuantity` | MechLib.Units.VecQuantity.cast_val<br>MechLib.Units.VecQuantity.dot_val<br>MechLib.Systems.Verified.CentralForce.cross_self_zero |  |
| foundation.si_units | SI 单位 | SI units | `verified` | `core` | `MechLib.Foundation.SI` | MechLib.SI.speed_time_eq_length<br>MechLib.SI.force_time_eq_momentum<br>MechLib.SI.mass_two_speed_eq_energy<br>MechLib.SI.conversionFactor_comp<br>MechLib.SI.conversionFactor_mul_swap |  |
| foundation.geometry | 几何对象 | geometry | `todo` | `interface` | `MechLib.Foundation.Geometry` |  |  |
| foundation.reference_frame | 参考系 | reference frame | `todo` | `interface` | `MechLib.Foundation.ReferenceFrame` |  | MechLib.Mechanics.Kinematics.TransportTheoremRelation |
| foundation.coordinate_system | 坐标系 | coordinate system | `todo` | `interface` | `MechLib.Foundation.CoordinateSystem` |  |  |

## Statics / 静力学

| id | zh_name | en_name | status | trust_level | module_path | verified_decls | schema_decls |
| --- | --- | --- | --- | --- | --- | --- | --- |
| statics.force_system | 力系 | force system | `todo` | `interface` | `MechLib.Statics.ForceSystem` |  |  |
| statics.moment | 力矩 | moment | `verified` | `core` | `MechLib.Statics.Moment` | MechLib.RigidBody.Verified.Rotation.torque_def<br>MechLib.Systems.Verified.CentralForce.hookeCentralForce_torque_zero |  |
| statics.couple | 力偶 | couple | `todo` | `interface` | `MechLib.Statics.Couple` |  |  |
| statics.equilibrium | 平衡 | equilibrium | `todo` | `interface` | `MechLib.Statics.Equilibrium` |  |  |
| statics.constraint_force | 约束力 | constraint force | `todo` | `interface` | `MechLib.Statics.ConstraintForce` |  |  |
| statics.friction | 摩擦 | friction | `todo` | `interface` | `MechLib.Statics.Friction` |  |  |
| statics.truss | 桁架 | truss | `todo` | `example` | `MechLib.Statics.Truss` |  |  |

## Kinematics / 运动学

| id | zh_name | en_name | status | trust_level | module_path | verified_decls | schema_decls |
| --- | --- | --- | --- | --- | --- | --- | --- |
| kinematics.point_motion | 点的运动 | point motion | `verified` | `core` | `MechLib.Kinematics.PointMotion` | MechLib.Kinematics.Verified.Kinematics.displacement_eq_sub<br>MechLib.Kinematics.Verified.Kinematics.constant_speed_relation<br>MechLib.Kinematics.Verified.Kinematics.velocity_increment<br>MechLib.Kinematics.Verified.Kinematics.displacement_forms_equiv |  |
| kinematics.coordinate_motion | 坐标运动 | coordinate motion | `todo` | `interface` | `MechLib.Kinematics.CoordinateMotion` |  |  |
| kinematics.relative_motion | 相对运动 | relative motion | `verified` | `derived` | `MechLib.Kinematics.RelativeMotion` | MechLib.Kinematics.Verified.Kinematics.relative_trajectory_trans<br>MechLib.Kinematics.Verified.Kinematics.relative_velocity_trans<br>MechLib.Kinematics.Verified.Kinematics.relative_acceleration_trans<br>MechLib.Kinematics.Verified.Kinematics.hasVelocity_relative |  |
| kinematics.rigid_body_motion | 刚体运动 | rigid body motion | `schema` | `interface` | `MechLib.Kinematics.RigidBodyMotion` | MechLib.Kinematics.Verified.Kinematics.rigid_pair_velocity_equal<br>MechLib.Kinematics.Verified.Kinematics.rigid_pair_vec_velocity_equal | MechLib.Mechanics.Kinematics.TransportTheoremRelation |
| kinematics.planar_motion | 平面运动 | planar motion | `todo` | `interface` | `MechLib.Kinematics.PlanarMotion` |  |  |
| kinematics.fixed_axis_rotation | 定轴转动 | fixed-axis rotation | `schema` | `interface` | `MechLib.Kinematics.FixedAxisRotation` | MechLib.RigidBody.Verified.Rotation.rotationalKineticEnergy_eq | MechLib.Mechanics.Rotation.EulerEquationsPrincipal |

## Dynamics / 动力学

| id | zh_name | en_name | status | trust_level | module_path | verified_decls | schema_decls |
| --- | --- | --- | --- | --- | --- | --- | --- |
| dynamics.newton_law | 牛顿定律 | Newton law | `verified` | `core` | `MechLib.Dynamics.NewtonLaw` | MechLib.Dynamics.Verified.Dynamics.newton_second_law<br>MechLib.Dynamics.Verified.Dynamics.secondLawVec_eq<br>MechLib.Dynamics.Verified.Dynamics.force_from_velocity_rate_const_mass |  |
| dynamics.particle_dynamics | 质点动力学 | particle dynamics | `schema` | `interface` | `MechLib.Dynamics.ParticleDynamics` | MechLib.Dynamics.Verified.Dynamics.newton_second_law |  |
| dynamics.system_dynamics | 质点系动力学 | system dynamics | `verified` | `derived` | `MechLib.Dynamics.SystemDynamics` | MechLib.Dynamics.Verified.SystemDynamics.totalMass_cons<br>MechLib.Dynamics.Verified.SystemDynamics.centerOfMassVelocity_singleton<br>MechLib.Dynamics.Verified.SystemDynamics.totalMomentum_two_eq_totalMass_mul_centerVelocity<br>MechLib.Dynamics.Verified.SystemDynamics.twoBody_kineticEnergy_decomposition | MechLib.Mechanics.SystemDynamics.CenterOfMassTheorem |
| dynamics.momentum | 动量 | momentum | `verified` | `core` | `MechLib.Dynamics.Momentum` | MechLib.Dynamics.Verified.Dynamics.momentum_change_const_mass |  |
| dynamics.angular_momentum | 角动量 | angular momentum | `schema` | `interface` | `MechLib.Dynamics.AngularMomentum` | MechLib.RigidBody.Verified.Rotation.torque_def<br>MechLib.Systems.Verified.CentralForce.hookeCentralForce_isCentral | MechLib.Mechanics.Rotation.AngularMomentumTheoremParticle<br>MechLib.Mechanics.Rotation.MomentOfMomentumTheoremSystem |
| dynamics.work_energy | 功和能 | work-energy | `verified` | `core` | `MechLib.Dynamics.WorkEnergy` | MechLib.Dynamics.Verified.WorkEnergy.work_def<br>MechLib.Dynamics.Verified.WorkEnergy.kineticEnergy_change_formula<br>MechLib.Dynamics.Verified.WorkEnergy.work_energy_theorem_core<br>MechLib.Dynamics.Verified.WorkEnergy.conservative_nonconservative_split |  |
| dynamics.impulse | 冲量 | impulse | `verified` | `core` | `MechLib.Dynamics.Impulse` | MechLib.Dynamics.Verified.MomentumImpulse.impulse_def<br>MechLib.Dynamics.Verified.MomentumImpulse.impulse_momentum_theorem |  |
| dynamics.collision | 碰撞 | collision | `verified` | `derived` | `MechLib.Dynamics.Collision` | MechLib.Dynamics.Verified.MomentumImpulse.momentum_conservation_inelastic |  |
| dynamics.non_inertial_frame | 非惯性系 | non-inertial frame | `schema` | `interface` | `MechLib.Dynamics.NonInertialFrame` |  | MechLib.Mechanics.Kinematics.TransportTheoremRelation |
| dynamics.variable_mass | 变质量 | variable mass | `schema` | `interface` | `MechLib.Dynamics.VariableMass` | MechLib.Dynamics.Verified.SystemDynamics.variableMassMomentumBalance_eq | MechLib.Mechanics.SystemDynamics.VariableMassMomentumBalance |

## RigidBody / 刚体

| id | zh_name | en_name | status | trust_level | module_path | verified_decls | schema_decls |
| --- | --- | --- | --- | --- | --- | --- | --- |
| rigidbody.inertia | 转动惯量 | inertia | `verified` | `core` | `MechLib.RigidBody.Inertia` | MechLib.RigidBody.Verified.Rotation.parallel_axis_theorem<br>MechLib.RigidBody.Verified.Rotation.rotationalKineticEnergy_eq | MechLib.Mechanics.Rotation.InertiaTensor |
| rigidbody.fixed_axis_dynamics | 定轴转动动力学 | fixed-axis dynamics | `schema` | `interface` | `MechLib.RigidBody.FixedAxisDynamics` | MechLib.RigidBody.Verified.Rotation.torque_def |  |
| rigidbody.plane_motion_dynamics | 平面运动动力学 | plane motion dynamics | `todo` | `interface` | `MechLib.RigidBody.PlaneMotionDynamics` |  |  |
| rigidbody.euler_equations | 欧拉方程 | Euler equations | `schema` | `interface` | `MechLib.RigidBody.EulerEquations` | MechLib.RigidBody.Verified.Rotation.rigidBodyKineticDecomposition_eq | MechLib.Mechanics.Rotation.EulerEquationsPrincipal |
| rigidbody.gyroscope | 陀螺 | gyroscope | `todo` | `example` | `MechLib.RigidBody.Gyroscope` |  |  |

## Analytical / 分析力学

| id | zh_name | en_name | status | trust_level | module_path | verified_decls | schema_decls |
| --- | --- | --- | --- | --- | --- | --- | --- |
| analytical.generalized_coordinates | 广义坐标 | generalized coordinates | `schema` | `interface` | `MechLib.Analytical.GeneralizedCoordinates` |  | MechLib.Analytical.GeneralizedCoordinates.CoordSpec<br>MechLib.Analytical.GeneralizedCoordinates.GCoord<br>MechLib.Analytical.GeneralizedCoordinates.GVel<br>MechLib.Analytical.GeneralizedCoordinates.GeneralizedForce<br>MechLib.Analytical.GeneralizedCoordinates.GeneralizedMomentum |
| analytical.constraints | 约束 | constraints | `schema` | `interface` | `MechLib.Analytical.Constraints` | MechLib.Kinematics.Verified.Kinematics.linear_constraint_velocity<br>MechLib.Kinematics.Verified.Kinematics.linear_constraint_acceleration<br>MechLib.Kinematics.Verified.Kinematics.pfaffConstraint1D_linear_combination | MechLib.Analytical.Constraints.HolonomicConstraint<br>MechLib.Analytical.Constraints.NonHolonomicConstraint<br>MechLib.Analytical.Constraints.HolonomicConstraintSatisfied<br>MechLib.Mechanics.Kinematics.PfaffConstraint1D |
| analytical.virtual_work | 虚功 | virtual work | `schema` | `interface` | `MechLib.Analytical.VirtualWork` |  | MechLib.Analytical.VirtualWork.VirtualDisplacement<br>MechLib.Analytical.VirtualWork.VirtualWorkResidual<br>MechLib.Analytical.VirtualWork.IdealConstraintVirtualWork |
| analytical.dalembert_principle | 达朗贝尔原理 | d'Alembert principle | `schema` | `interface` | `MechLib.Analytical.DAlembert` |  | MechLib.Analytical.DAlembert.InertialGeneralizedForce<br>MechLib.Analytical.DAlembert.DAlembertResidual |
| analytical.lagrange_equation | 拉格朗日方程 | Lagrange equation | `verified` | `derived` | `MechLib.Analytical.LagrangeEquation` | MechLib.Analytical.LagrangeEquation.lagrangian1D_eq<br>MechLib.Analytical.LagrangeEquation.eulerLagrange_iff_newton<br>MechLib.Analytical.LagrangeEquation.eulerLagrange_iff_newton_course_form | MechLib.Analytical.LagrangeEquation.LagrangianSystem<br>MechLib.Analytical.LagrangeEquation.EulerLagrangeResidual<br>MechLib.Analytical.LagrangeEquation.GeneralizedMomentumOf<br>MechLib.Analytical.LagrangeEquation.SatisfiesEulerLagrange1D<br>MechLib.Analytical.LagrangeEquation.eulerLagrangeResidual1D |
| analytical.hamiltonian | 哈密顿量 | Hamiltonian | `verified` | `derived` | `MechLib.Analytical.Hamiltonian` | MechLib.Analytical.Hamiltonian.canonicalMomentum1D_eq<br>MechLib.Analytical.Hamiltonian.hamiltonianXV_eq<br>MechLib.Analytical.Hamiltonian.hamiltonianXP_eq<br>MechLib.Analytical.Hamiltonian.hamiltonianXP_of_canonicalMomentum | MechLib.Analytical.Hamiltonian.HamiltonianSystem<br>MechLib.Analytical.Hamiltonian.CanonicalEquationResidual<br>MechLib.Analytical.Hamiltonian.CanonicalEquations1D<br>MechLib.Analytical.Hamiltonian.legendreRegular1D |
| analytical.poisson_bracket | 泊松括号 | Poisson bracket | `verified` | `derived` | `MechLib.Analytical.PoissonBracket` | MechLib.Analytical.PoissonBracket.poissonBracket1D_antisymm<br>MechLib.Analytical.PoissonBracket.poissonBracket1D_antisymm_course_form | MechLib.Analytical.PoissonBracket.PoissonBracket<br>MechLib.Analytical.PoissonBracket.PoissonBracketResidualN<br>MechLib.Analytical.PoissonBracket.poissonBracket1D<br>MechLib.Analytical.PoissonBracket.PhaseFunction1D |
| analytical.conservation_law | 守恒律 | conservation law | `verified` | `derived` | `MechLib.Analytical.ConservationLaw` | MechLib.Analytical.ConservationLaw.cyclic_coordinate_implies_momentum_conserved<br>MechLib.Analytical.ConservationLaw.cyclic_coordinate_implies_momentum_conserved_1d<br>MechLib.Dynamics.Verified.WorkEnergy.conservative_nonconservative_split | MechLib.Analytical.ConservationLaw.IsCyclicCoordinate<br>MechLib.Analytical.ConservationLaw.GeneralizedMomentumConserved<br>MechLib.Analytical.ConservationLaw.CyclicCoordinateConservation<br>MechLib.Analytical.ConservationLaw.IsCyclicCoordinate1D<br>MechLib.Analytical.ConservationLaw.MomentumConserved1D |
| analytical.small_oscillations | 小振动 | small oscillations | `schema` | `interface` | `MechLib.Analytical.SmallOscillations` |  | MechLib.Analytical.SmallOscillations.SmallOscillationSystem<br>MechLib.Analytical.SmallOscillations.SmallOscillationEquation<br>MechLib.Analytical.SmallOscillations.NormalModeCondition |

## Systems / 代表系统

| id | zh_name | en_name | status | trust_level | module_path | verified_decls | schema_decls |
| --- | --- | --- | --- | --- | --- | --- | --- |
| systems.harmonic_oscillator | 简谐振子 | harmonic oscillator | `verified` | `core` | `MechLib.Systems.HarmonicOscillator` | MechLib.Systems.Verified.SHM.acceleration_eq_neg_omega_sq_mul_pos<br>MechLib.Systems.Verified.SHM.period_frequency_relation<br>MechLib.Systems.Verified.SHM.initialPosition_eq<br>MechLib.Systems.Verified.SHM.initialVelocity_eq | MechLib.Mechanics.SHM.SHMEquation<br>MechLib.Mechanics.SHM.UniqueByInitialState |
| systems.damped_oscillator | 阻尼振子 | damped oscillator | `verified` | `derived` | `MechLib.Systems.DampedOscillator` | MechLib.Systems.Verified.DampedSHM.equationResidual_eq<br>MechLib.Systems.Verified.DampedSHM.regimes_trichotomy<br>MechLib.Systems.Verified.DampedSHM.qualityFactor_mul_dampingRatio<br>MechLib.Systems.Verified.DampedSHM.equationOfMotion_gamma_zero_iff | MechLib.Mechanics.DampedSHM.EquationOfMotion<br>MechLib.Mechanics.DampedSHM.EnergyDissipationLaw |
| systems.pendulum | 单摆 | pendulum | `schema` | `example` | `MechLib.Systems.Pendulum` | MechLib.Systems.Pendulum.smallAngle_to_SHM | MechLib.Systems.Pendulum.kineticEnergy<br>MechLib.Systems.Pendulum.potentialEnergy<br>MechLib.Systems.Pendulum.lagrangian<br>MechLib.Systems.Pendulum.equationResidual<br>MechLib.Systems.Pendulum.PendulumEquationResidual |
| systems.physical_pendulum | 复摆 | physical pendulum | `schema` | `example` | `MechLib.Systems.PhysicalPendulum` |  | MechLib.Systems.PhysicalPendulum.kineticEnergy<br>MechLib.Systems.PhysicalPendulum.potentialEnergy<br>MechLib.Systems.PhysicalPendulum.lagrangian<br>MechLib.Systems.PhysicalPendulum.smallAngleEquation<br>MechLib.Systems.PhysicalPendulum.physical_pendulum_period |
| systems.central_force | 中心力 | central force | `verified` | `derived` | `MechLib.Systems.CentralForce` | MechLib.Systems.Verified.CentralForce.hookeCentralForce_isCentral<br>MechLib.Systems.Verified.CentralForce.effectivePotential_eq<br>MechLib.Systems.Verified.CentralForce.inverseSquarePotential_eq<br>MechLib.Systems.Verified.CentralForce.classifyInverseSquareOrbit_trichotomy | MechLib.Systems.CentralForce.polarCoordSpec<br>MechLib.Systems.CentralForce.kineticEnergyPolar<br>MechLib.Systems.CentralForce.effectivePotentialScalar<br>MechLib.Systems.CentralForce.circularOrbitCondition<br>MechLib.Systems.CentralForce.stableCircularOrbitCondition<br>MechLib.Mechanics.CentralForce.RadialEquation<br>MechLib.Mechanics.CentralForce.BinetEquation<br>MechLib.Mechanics.CentralForce.KeplerSecondLaw |
| systems.atwood_machine | 阿特伍德机 | Atwood machine | `schema` | `example` | `MechLib.Systems.AtwoodMachine` |  | MechLib.Systems.AtwoodMachine.AtwoodConstraint<br>MechLib.Systems.AtwoodMachine.reducedConstraint<br>MechLib.Systems.AtwoodMachine.lagrangian<br>MechLib.Systems.AtwoodMachine.equationResidual<br>MechLib.Systems.AtwoodMachine.accelerationFormula |
| systems.coupled_oscillator | 耦合振子 | coupled oscillator | `schema` | `example` | `MechLib.Systems.CoupledOscillator` |  | MechLib.Systems.CoupledOscillator.CoupledOscillatorModel<br>MechLib.Systems.CoupledOscillator.kineticEnergy<br>MechLib.Systems.CoupledOscillator.potentialEnergy<br>MechLib.Systems.CoupledOscillator.lagrangian<br>MechLib.Systems.CoupledOscillator.linearEquationResidual<br>MechLib.Systems.CoupledOscillator.NormalModeResidual |
| systems.rolling_disk | 滚动圆盘 | rolling disk | `schema` | `example` | `MechLib.Systems.RollingDisk` |  | MechLib.Systems.RollingDisk.RollingNoSlipResidual<br>MechLib.Systems.RollingDisk.noSlipConstraint<br>MechLib.Systems.RollingDisk.nonholonomicConstraintSchema<br>MechLib.Systems.RollingDisk.rollingKineticEnergy |
| systems.bead_on_hoop | 圆环上珠子 | bead on hoop | `schema` | `example` | `MechLib.Systems.BeadOnHoop` |  | MechLib.Systems.BeadOnHoop.HoopConstraintResidual<br>MechLib.Systems.BeadOnHoop.effectivePotential<br>MechLib.Systems.BeadOnHoop.equilibriumCondition<br>MechLib.Systems.BeadOnHoop.stabilityCondition |
