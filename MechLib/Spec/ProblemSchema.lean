import MechLib.Spec.Status

namespace MechLib
namespace Spec

open Lean

/-- Problem-template metadata for modeling and retrieval. -/
structure ProblemSchema where
  id : String
  topic : String
  inputObjects : List String
  targetObjects : List String
  modelingSteps : List String
  candidateLaws : List String
  expectedLeanObjects : List String
  verifiedDecls : List String
  schemaDecls : List String
deriving Repr

namespace ProblemSchema

def toJson (p : ProblemSchema) : Json :=
  Json.mkObj [
    ("id", Json.str p.id),
    ("topic", Json.str p.topic),
    ("input_objects", stringListJson p.inputObjects),
    ("target_objects", stringListJson p.targetObjects),
    ("modeling_steps", stringListJson p.modelingSteps),
    ("candidate_laws", stringListJson p.candidateLaws),
    ("expected_lean_objects", stringListJson p.expectedLeanObjects),
    ("verified_decls", stringListJson p.verifiedDecls),
    ("schema_decls", stringListJson p.schemaDecls)
  ]

def problemSchemas : List ProblemSchema := [
  {
    id := "problem.statics.planar_equilibrium",
    topic := "平面静力平衡",
    inputObjects := ["rigid body", "applied planar forces", "support geometry", "unknown reactions"],
    targetObjects := ["reaction forces", "reaction moments", "equilibrium equations"],
    modelingSteps := ["choose a free body", "resolve forces into planar components", "write force balance", "write moment balance", "solve unknown reactions"],
    candidateLaws := ["law.statics.planar_force_system_equilibrium"],
    expectedLeanObjects := ["MechLib.Spec.LawSchema", "MechLib.RigidBody.Verified.Rotation.torque_def"],
    verifiedDecls := ["MechLib.RigidBody.Verified.Rotation.torque_def"],
    schemaDecls := []
  },
  {
    id := "problem.kinematics.uniform_acceleration_point_motion",
    topic := "点的匀加速运动",
    inputObjects := ["initial position", "initial velocity", "constant acceleration", "elapsed time"],
    targetObjects := ["final velocity", "displacement", "final position"],
    modelingSteps := ["choose one-dimensional or vector coordinate", "apply constant-acceleration velocity update", "apply constant-acceleration displacement relation", "translate displacement into final position"],
    candidateLaws := ["kinematics.point_motion"],
    expectedLeanObjects := ["MechLib.Mechanics.Kinematics.velocityConstAccel", "MechLib.Mechanics.Kinematics.positionConstAccel"],
    verifiedDecls := ["MechLib.Kinematics.Verified.Kinematics.velocity_increment", "MechLib.Kinematics.Verified.Kinematics.displacement_forms_equiv", "MechLib.Kinematics.Verified.Kinematics.constant_speed_relation"],
    schemaDecls := []
  },
  {
    id := "problem.kinematics.composite_point_motion",
    topic := "点的复合运动",
    inputObjects := ["moving point", "reference frame motion", "relative trajectory", "time parameter"],
    targetObjects := ["absolute velocity", "relative velocity", "transport relation"],
    modelingSteps := ["identify fixed and moving frames", "split absolute and relative position", "differentiate the relative relation", "apply transport schema if the frame rotates"],
    candidateLaws := ["kinematics.relative_motion", "dynamics.non_inertial_frame"],
    expectedLeanObjects := ["MechLib.Kinematics.Verified.Kinematics.relative_velocity_trans", "MechLib.Mechanics.Kinematics.TransportTheoremRelation"],
    verifiedDecls := ["MechLib.Kinematics.Verified.Kinematics.relative_trajectory_trans", "MechLib.Kinematics.Verified.Kinematics.relative_velocity_trans", "MechLib.Kinematics.Verified.Kinematics.hasVelocity_relative"],
    schemaDecls := ["MechLib.Mechanics.Kinematics.TransportTheoremRelation"]
  },
  {
    id := "problem.dynamics.particle_dynamics",
    topic := "质点动力学",
    inputObjects := ["particle mass", "known forces", "constraint forces", "trajectory or acceleration target"],
    targetObjects := ["acceleration", "force relation", "unknown constraint force"],
    modelingSteps := ["draw the free-body diagram", "choose axes", "write Newton second-law equations", "add kinematic or constraint relations", "solve for targets"],
    candidateLaws := ["law.dynamics.newton_second_law"],
    expectedLeanObjects := ["MechLib.Dynamics.Verified.Dynamics.newton_second_law", "MechLib.Dynamics.Verified.Dynamics.secondLawVec_eq"],
    verifiedDecls := ["MechLib.Dynamics.Verified.Dynamics.newton_second_law", "MechLib.Dynamics.Verified.Dynamics.secondLawVec_eq"],
    schemaDecls := []
  },
  {
    id := "problem.dynamics.work_energy_find_speed",
    topic := "动能定理求速度",
    inputObjects := ["mass", "initial speed", "work or force-displacement data", "potential energy change"],
    targetObjects := ["final speed", "kinetic energy change", "mechanical-energy relation"],
    modelingSteps := ["identify net work", "write work-energy theorem", "substitute kinetic-energy expression", "solve scalar speed relation"],
    candidateLaws := ["law.dynamics.work_energy_theorem"],
    expectedLeanObjects := ["MechLib.Dynamics.Verified.WorkEnergy.work_energy_theorem_core", "MechLib.Mechanics.WorkEnergy.kineticEnergy1D"],
    verifiedDecls := ["MechLib.Dynamics.Verified.WorkEnergy.work_energy_theorem_core", "MechLib.Dynamics.Verified.WorkEnergy.kineticEnergy_change_formula"],
    schemaDecls := []
  },
  {
    id := "problem.systems.pendulum_lagrangian",
    topic := "单摆拉格朗日建模",
    inputObjects := ["pendulum length", "bob mass", "gravity", "angle coordinate"],
    targetObjects := ["Lagrangian", "Euler-Lagrange residual", "equation of motion"],
    modelingSteps := ["choose angle as generalized coordinate", "write kinetic energy", "write potential energy", "form L = T - V", "apply Euler-Lagrange schema"],
    candidateLaws := ["law.analytical.euler_lagrange_equation"],
    expectedLeanObjects := ["MechLib.Systems.Pendulum.Params", "MechLib.Systems.Pendulum.kineticEnergy", "MechLib.Systems.Pendulum.potentialEnergy", "MechLib.Systems.Pendulum.lagrangian", "MechLib.Systems.Pendulum.equationResidual"],
    verifiedDecls := ["MechLib.Analytical.LagrangeEquation.lagrangian1D_eq"],
    schemaDecls := ["MechLib.Systems.Pendulum.EquationOfMotion", "MechLib.Systems.Pendulum.smallAngleApprox", "MechLib.Systems.Pendulum.PendulumEquationResidual"]
  },
  {
    id := "problem.systems.physical_pendulum_period",
    topic := "复摆小角周期建模",
    inputObjects := ["mass", "pivot-to-center distance", "gravity", "moment of inertia about pivot", "small angle coordinate"],
    targetObjects := ["physical pendulum Lagrangian", "small-angle equation", "period relation"],
    modelingSteps := ["choose angle about pivot", "write rotational kinetic energy", "write gravitational potential energy", "form L = T - V", "linearize at small angle", "state period schema"],
    candidateLaws := ["law.analytical.euler_lagrange_equation", "law.analytical.small_oscillation_equation"],
    expectedLeanObjects := ["MechLib.Systems.PhysicalPendulum.Params", "MechLib.Systems.PhysicalPendulum.kineticEnergy", "MechLib.Systems.PhysicalPendulum.potentialEnergy", "MechLib.Systems.PhysicalPendulum.lagrangian", "MechLib.Systems.PhysicalPendulum.physical_pendulum_period"],
    verifiedDecls := [],
    schemaDecls := ["MechLib.Systems.PhysicalPendulum.smallAngleEquation", "MechLib.Systems.PhysicalPendulum.physical_pendulum_period"]
  },
  {
    id := "problem.systems.central_force_angular_momentum",
    topic := "中心力角动量守恒",
    inputObjects := ["position vector", "central force", "linear momentum", "torque relation"],
    targetObjects := ["zero torque", "angular-momentum balance", "conservation statement"],
    modelingSteps := ["state that force is central", "rewrite torque as r cross F", "show torque vanishes", "connect zero torque to angular-momentum theorem schema"],
    candidateLaws := ["dynamics.angular_momentum", "systems.central_force"],
    expectedLeanObjects := ["MechLib.Systems.CentralForce.polarCoordSpec", "MechLib.Systems.CentralForce.effectivePotentialScalar", "MechLib.Systems.CentralForce.circularOrbitCondition", "MechLib.Systems.Verified.CentralForce.hookeCentralForce_isCentral"],
    verifiedDecls := ["MechLib.Systems.CentralForce.hookeCentralForce_torque_zero_course_form", "MechLib.Systems.Verified.CentralForce.hookeCentralForce_torque_zero", "MechLib.Systems.Verified.CentralForce.hookeCentralForce_isCentral"],
    schemaDecls := ["MechLib.Systems.CentralForce.circularOrbitCondition", "MechLib.Systems.CentralForce.stableCircularOrbitCondition", "MechLib.Systems.CentralForce.angularMomentum_conserved"]
  },
  {
    id := "problem.systems.coupled_oscillator_normal_modes",
    topic := "耦合振子正则模",
    inputObjects := ["mass matrix or masses", "stiffness matrix or springs", "small-displacement coordinates", "equilibrium point"],
    targetObjects := ["normal frequencies", "normal mode shapes", "linearized equations"],
    modelingSteps := ["choose small generalized coordinates", "write quadratic kinetic and potential energies", "form linearized equations", "solve the normal-mode eigenproblem"],
    candidateLaws := ["law.analytical.small_oscillation_equation"],
    expectedLeanObjects := ["MechLib.Systems.CoupledOscillator.CoupledOscillatorModel", "MechLib.Systems.CoupledOscillator.CoupledOscillatorModel.massMatrix", "MechLib.Systems.CoupledOscillator.CoupledOscillatorModel.stiffnessMatrix", "MechLib.Systems.CoupledOscillator.NormalModeResidual"],
    verifiedDecls := ["MechLib.Systems.Verified.SHM.acceleration_eq_neg_omega_sq_mul_pos"],
    schemaDecls := ["MechLib.Systems.CoupledOscillator.linearEquationResidual", "MechLib.Systems.CoupledOscillator.NormalModeResidual"]
  },
  {
    id := "problem.systems.atwood_constraint_modeling",
    topic := "Atwood 机约束建模",
    inputObjects := ["two masses", "ideal string", "pulley geometry", "gravity"],
    targetObjects := ["acceleration relation", "tension", "equations of motion"],
    modelingSteps := ["assign coordinates to each mass", "write rope-length constraint", "differentiate to velocity and acceleration constraints", "apply Newton or Lagrange modeling"],
    candidateLaws := ["law.dynamics.newton_second_law", "analytical.constraints"],
    expectedLeanObjects := ["MechLib.Systems.AtwoodMachine.Params", "MechLib.Systems.AtwoodMachine.AtwoodConstraint", "MechLib.Systems.AtwoodMachine.lagrangian", "MechLib.Systems.AtwoodMachine.accelerationFormula"],
    verifiedDecls := ["MechLib.Kinematics.Verified.Kinematics.linear_constraint_velocity", "MechLib.Kinematics.Verified.Kinematics.linear_constraint_acceleration", "MechLib.Dynamics.Verified.Dynamics.newton_second_law"],
    schemaDecls := ["MechLib.Systems.AtwoodMachine.reducedConstraint", "MechLib.Systems.AtwoodMachine.equationResidual", "MechLib.Systems.AtwoodMachine.accelerationFormula"]
  },
  {
    id := "problem.systems.rolling_disk_no_slip",
    topic := "滚动圆盘无滑动约束建模",
    inputObjects := ["disk mass", "radius", "axial moment of inertia", "center speed", "angular speed", "heading"],
    targetObjects := ["no-slip constraint", "nonholonomic velocity constraint", "rolling kinetic energy"],
    modelingSteps := ["choose planar coordinates and rotation angle", "write no-slip speed relation", "write Pfaff-style nonholonomic constraint", "write translational plus rotational kinetic energy"],
    candidateLaws := ["analytical.constraints", "rigidbody.plane_motion_dynamics"],
    expectedLeanObjects := ["MechLib.Systems.RollingDisk.Params", "MechLib.Systems.RollingDisk.noSlipConstraint", "MechLib.Systems.RollingDisk.nonholonomicConstraintSchema", "MechLib.Systems.RollingDisk.rollingKineticEnergy"],
    verifiedDecls := [],
    schemaDecls := ["MechLib.Systems.RollingDisk.RollingNoSlipResidual", "MechLib.Systems.RollingDisk.noSlipConstraint", "MechLib.Systems.RollingDisk.nonholonomicConstraintSchema"]
  },
  {
    id := "problem.systems.bead_on_hoop_equilibrium",
    topic := "圆环上珠子平衡与稳定性",
    inputObjects := ["bead mass", "hoop radius", "gravity", "hoop rotation rate", "angle coordinate"],
    targetObjects := ["effective potential", "equilibrium angles", "stability condition"],
    modelingSteps := ["choose hoop angle coordinate", "write hoop constraint", "write rotating-frame effective potential", "solve first-derivative equilibrium condition", "test second-derivative stability condition"],
    candidateLaws := ["law.analytical.euler_lagrange_equation", "analytical.conservation_law"],
    expectedLeanObjects := ["MechLib.Systems.BeadOnHoop.Params", "MechLib.Systems.BeadOnHoop.effectivePotential", "MechLib.Systems.BeadOnHoop.equilibriumCondition", "MechLib.Systems.BeadOnHoop.stabilityCondition"],
    verifiedDecls := [],
    schemaDecls := ["MechLib.Systems.BeadOnHoop.HoopConstraintResidual", "MechLib.Systems.BeadOnHoop.equilibriumCondition", "MechLib.Systems.BeadOnHoop.stabilityCondition"]
  }
]

def problemSchemasJson : Json :=
  Json.arr (problemSchemas.map ProblemSchema.toJson).toArray

end ProblemSchema
end Spec
end MechLib
