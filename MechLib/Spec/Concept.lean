import MechLib.Spec.Status

namespace MechLib
namespace Spec

open Lean

/-- Concept-level metadata for theoretical-mechanics modeling and retrieval. -/
structure ConceptSpec where
  id : String
  zhName : String
  enName : String
  description : String
  aliasesZh : List String
  aliasesEn : List String
  tags : List String
  prerequisites : List String
  relatedLaws : List String
  relatedProblemSchemas : List String
deriving Repr

namespace ConceptSpec

def toJson (c : ConceptSpec) : Json :=
  Json.mkObj [
    ("id", Json.str c.id),
    ("zh_name", Json.str c.zhName),
    ("en_name", Json.str c.enName),
    ("description", Json.str c.description),
    ("aliases_zh", stringListJson c.aliasesZh),
    ("aliases_en", stringListJson c.aliasesEn),
    ("tags", stringListJson c.tags),
    ("prerequisites", stringListJson c.prerequisites),
    ("related_laws", stringListJson c.relatedLaws),
    ("related_problem_schemas", stringListJson c.relatedProblemSchemas)
  ]

end ConceptSpec

namespace Concept

def conceptSpecs : List ConceptSpec := [
  {
    id := "concept.force_system",
    zhName := "力系",
    enName := "force system",
    description := "A collection of forces acting on a body or system, tracked for resultant force, resultant moment, and equilibrium modeling.",
    aliasesZh := ["力系", "受力系统", "外力系", "合力系统"],
    aliasesEn := ["force system", "system of forces", "resultant-force model"],
    tags := ["Statics", "Dynamics", "ForceSystem", "Modeling"],
    prerequisites := ["foundation.vector_quantity"],
    relatedLaws := ["law.statics.planar_force_system_equilibrium", "law.dynamics.newton_second_law"],
    relatedProblemSchemas := ["problem.statics.planar_equilibrium", "problem.dynamics.particle_dynamics"]
  },
  {
    id := "concept.moment",
    zhName := "力矩",
    enName := "moment",
    description := "The rotational effect of a force about a point or axis, represented in MechLib by torque-style vector quantities.",
    aliasesZh := ["力矩", "转矩", "力对点之矩", "力对轴之矩"],
    aliasesEn := ["moment", "torque", "moment of force"],
    tags := ["Statics", "RigidBody", "Rotation", "AngularMomentum"],
    prerequisites := ["concept.force_system"],
    relatedLaws := ["law.statics.planar_force_system_equilibrium", "law.dynamics.angular_momentum_conservation"],
    relatedProblemSchemas := ["problem.statics.planar_equilibrium", "problem.systems.central_force_angular_momentum"]
  },
  {
    id := "concept.generalized_coordinates",
    zhName := "广义坐标",
    enName := "generalized coordinates",
    description := "Independent configuration variables chosen to describe the degrees of freedom of a constrained mechanical system.",
    aliasesZh := ["广义坐标", "独立坐标", "构型变量"],
    aliasesEn := ["generalized coordinates", "configuration coordinates", "independent coordinates"],
    tags := ["Analytical", "Constraints", "Lagrangian"],
    prerequisites := ["foundation.coordinate_system"],
    relatedLaws := ["law.analytical.euler_lagrange_equation", "law.analytical.hamilton_canonical_equations"],
    relatedProblemSchemas := ["problem.systems.pendulum_lagrangian", "problem.systems.coupled_oscillator_normal_modes"]
  },
  {
    id := "concept.virtual_displacement",
    zhName := "虚位移",
    enName := "virtual displacement",
    description := "An infinitesimal admissible displacement compatible with constraints at a fixed time, used in virtual work and d'Alembert modeling.",
    aliasesZh := ["虚位移", "可能位移", "约束相容位移"],
    aliasesEn := ["virtual displacement", "admissible displacement", "constraint-compatible displacement"],
    tags := ["Analytical", "VirtualWork", "Constraints", "Statics"],
    prerequisites := ["concept.constraints"],
    relatedLaws := ["law.analytical.virtual_work_principle", "law.analytical.dalembert_principle"],
    relatedProblemSchemas := ["problem.statics.planar_equilibrium", "problem.systems.atwood_constraint_modeling"]
  },
  {
    id := "concept.lagrangian",
    zhName := "拉格朗日量",
    enName := "Lagrangian",
    description := "The scalar function L = T - V used to derive equations of motion through Euler-Lagrange equations.",
    aliasesZh := ["拉格朗日量", "拉氏量", "L函数"],
    aliasesEn := ["Lagrangian", "Lagrange function", "kinetic-minus-potential energy"],
    tags := ["Analytical", "Lagrangian", "Energy", "EulerLagrange"],
    prerequisites := ["concept.kinetic_energy", "concept.potential_energy", "concept.generalized_coordinates"],
    relatedLaws := ["law.analytical.euler_lagrange_equation"],
    relatedProblemSchemas := ["problem.systems.pendulum_lagrangian", "problem.systems.coupled_oscillator_normal_modes"]
  },
  {
    id := "concept.cyclic_coordinate",
    zhName := "循环坐标",
    enName := "cyclic coordinate",
    description := "A generalized coordinate that does not appear explicitly in the Lagrangian, yielding a conserved conjugate momentum in the standard schema.",
    aliasesZh := ["循环坐标", "可遗坐标", "忽略坐标"],
    aliasesEn := ["cyclic coordinate", "ignorable coordinate", "absent generalized coordinate"],
    tags := ["Analytical", "ConservationLaw", "Lagrangian"],
    prerequisites := ["concept.generalized_coordinates", "concept.lagrangian"],
    relatedLaws := ["law.analytical.euler_lagrange_equation"],
    relatedProblemSchemas := ["problem.systems.central_force_angular_momentum"]
  },
  {
    id := "concept.constraints",
    zhName := "约束",
    enName := "constraints",
    description := "Restrictions on admissible configurations or velocities, including holonomic constraints and Pfaff-form nonholonomic schemas.",
    aliasesZh := ["约束", "运动约束", "几何约束", "速度约束"],
    aliasesEn := ["constraint", "mechanical constraint", "holonomic constraint", "nonholonomic constraint"],
    tags := ["Kinematics", "Analytical", "Modeling"],
    prerequisites := ["foundation.coordinate_system"],
    relatedLaws := ["law.analytical.virtual_work_principle", "law.analytical.dalembert_principle"],
    relatedProblemSchemas := ["problem.systems.atwood_constraint_modeling", "problem.systems.pendulum_lagrangian"]
  },
  {
    id := "concept.kinetic_energy",
    zhName := "动能",
    enName := "kinetic energy",
    description := "Energy associated with motion, represented in current MechLib by scalar and vector kinetic-energy definitions.",
    aliasesZh := ["动能", "运动能量"],
    aliasesEn := ["kinetic energy", "energy of motion"],
    tags := ["Dynamics", "WorkEnergy", "Analytical"],
    prerequisites := ["foundation.quantity", "kinematics.point_motion"],
    relatedLaws := ["law.dynamics.work_energy_theorem", "law.analytical.euler_lagrange_equation"],
    relatedProblemSchemas := ["problem.dynamics.work_energy_find_speed", "problem.systems.pendulum_lagrangian"]
  },
  {
    id := "concept.potential_energy",
    zhName := "势能",
    enName := "potential energy",
    description := "Energy associated with configuration for conservative interactions, used with kinetic energy to form mechanical energy and Lagrangians.",
    aliasesZh := ["势能", "位能", "保守势能"],
    aliasesEn := ["potential energy", "configuration energy", "conservative potential"],
    tags := ["Dynamics", "WorkEnergy", "Analytical"],
    prerequisites := ["foundation.quantity", "concept.generalized_coordinates"],
    relatedLaws := ["law.dynamics.work_energy_theorem", "law.analytical.euler_lagrange_equation"],
    relatedProblemSchemas := ["problem.systems.pendulum_lagrangian", "problem.systems.coupled_oscillator_normal_modes"]
  }
]

def conceptSpecsJson : Json :=
  Json.arr (conceptSpecs.map ConceptSpec.toJson).toArray

end Concept
end Spec
end MechLib
