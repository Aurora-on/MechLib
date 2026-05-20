import MechLib.Spec.Status

namespace MechLib
namespace Spec

open Lean

/-- Law-level schema metadata for retrieval, modeling, and planning. -/
structure LawSchema where
  id : String
  zhName : String
  enName : String
  statementText : String
  formalPropName : Option String
  status : DeclStatus
  prerequisites : List String
  usedFor : List String
  verifiedDecls : List String
  schemaDecls : List String
deriving Repr

namespace LawSchema

def toJson (s : LawSchema) : Json :=
  Json.mkObj [
    ("id", Json.str s.id),
    ("zh_name", Json.str s.zhName),
    ("en_name", Json.str s.enName),
    ("statement_text", Json.str s.statementText),
    ("formal_prop_name", optionStringJson s.formalPropName),
    ("status", Json.str s.status.toString),
    ("prerequisites", stringListJson s.prerequisites),
    ("used_for", stringListJson s.usedFor),
    ("verified_decls", stringListJson s.verifiedDecls),
    ("schema_decls", stringListJson s.schemaDecls)
  ]

def lawSchemas : List LawSchema := [
  {
    id := "law.statics.planar_force_system_equilibrium",
    zhName := "平面力系平衡",
    enName := "planar force-system equilibrium",
    statementText := "For a rigid body in planar static equilibrium, the independent force-balance equations and a moment-balance equation vanish.",
    formalPropName := none,
    status := .schema,
    prerequisites := ["concept.force_system", "concept.moment", "statics.equilibrium"],
    usedFor := ["support reaction solving", "free-body equilibrium", "beam and frame statics"],
    verifiedDecls := ["MechLib.RigidBody.Verified.Rotation.torque_def"],
    schemaDecls := []
  },
  {
    id := "law.dynamics.newton_second_law",
    zhName := "牛顿第二定律",
    enName := "Newton's second law",
    statementText := "The net force on a constant-mass particle is mass times acceleration.",
    formalPropName := some "MechLib.Dynamics.Verified.Dynamics.newton_second_law",
    status := .verified,
    prerequisites := ["foundation.quantity", "kinematics.point_motion"],
    usedFor := ["particle dynamics", "force analysis", "acceleration constraints"],
    verifiedDecls := ["MechLib.Dynamics.Verified.Dynamics.newton_second_law", "MechLib.Dynamics.Verified.Dynamics.secondLawVec_eq"],
    schemaDecls := []
  },
  {
    id := "law.dynamics.work_energy_theorem",
    zhName := "动能定理",
    enName := "work-energy theorem",
    statementText := "The net work done on a body equals the change in kinetic energy.",
    formalPropName := some "MechLib.Dynamics.Verified.WorkEnergy.work_energy_theorem_core",
    status := .verified,
    prerequisites := ["concept.force_system", "dynamics.work_energy"],
    usedFor := ["energy methods", "speed from work", "mechanical-energy balance"],
    verifiedDecls := ["MechLib.Dynamics.Verified.WorkEnergy.work_energy_theorem_core", "MechLib.Dynamics.Verified.WorkEnergy.kineticEnergy_change_formula"],
    schemaDecls := []
  },
  {
    id := "law.analytical.virtual_work_principle",
    zhName := "虚位移原理",
    enName := "principle of virtual work",
    statementText := "For ideal constraints in static equilibrium, the total virtual work of active forces vanishes for every admissible virtual displacement.",
    formalPropName := none,
    status := .schema,
    prerequisites := ["concept.virtual_displacement", "statics.equilibrium", "analytical.constraints"],
    usedFor := ["constraint-force elimination", "statics by virtual work", "generalized-force modeling"],
    verifiedDecls := [],
    schemaDecls := []
  },
  {
    id := "law.analytical.dalembert_principle",
    zhName := "达朗贝尔原理",
    enName := "d'Alembert principle",
    statementText := "Dynamics can be written as a virtual-work equilibrium by adding inertial forces to the applied-force system.",
    formalPropName := none,
    status := .schema,
    prerequisites := ["concept.virtual_displacement", "law.dynamics.newton_second_law"],
    usedFor := ["dynamic virtual work", "constraint-force elimination in dynamics", "Lagrange-equation derivation"],
    verifiedDecls := ["MechLib.Dynamics.Verified.Dynamics.newton_second_law"],
    schemaDecls := []
  },
  {
    id := "law.analytical.euler_lagrange_equation",
    zhName := "Euler-Lagrange 方程",
    enName := "Euler-Lagrange equation",
    statementText := "A trajectory satisfies d/dt(partial L / partial qdot) - partial L / partial q = 0 for each generalized coordinate.",
    formalPropName := some "MechLib.Analytical.LagrangeEquation.SatisfiesEulerLagrange1D",
    status := .schema,
    prerequisites := ["concept.generalized_coordinates", "concept.lagrangian", "analytical.constraints"],
    usedFor := ["Lagrangian modeling", "constrained dynamics", "small-oscillation equations"],
    verifiedDecls := ["MechLib.Analytical.LagrangeEquation.eulerLagrange_iff_newton"],
    schemaDecls := ["MechLib.Analytical.LagrangeEquation.SatisfiesEulerLagrange1D", "MechLib.Analytical.LagrangeEquation.eulerLagrangeResidual1D"]
  },
  {
    id := "law.analytical.hamilton_canonical_equations",
    zhName := "Hamilton 正则方程",
    enName := "Hamilton canonical equations",
    statementText := "Canonical coordinates satisfy qdot = partial H / partial p and pdot = -partial H / partial q.",
    formalPropName := some "MechLib.Analytical.Hamiltonian.CanonicalEquations1D",
    status := .schema,
    prerequisites := ["concept.generalized_coordinates", "concept.lagrangian"],
    usedFor := ["Hamiltonian modeling", "phase-space equations", "canonical dynamics planning"],
    verifiedDecls := ["MechLib.Analytical.Hamiltonian.canonicalEquations1D_eq"],
    schemaDecls := ["MechLib.Analytical.Hamiltonian.CanonicalEquations1D"]
  },
  {
    id := "law.analytical.cyclic_coordinate_conservation",
    zhName := "循环坐标守恒律",
    enName := "cyclic-coordinate conservation law",
    statementText := "If a generalized coordinate is cyclic, the conjugate generalized momentum is conserved.",
    formalPropName := some "MechLib.Analytical.ConservationLaw.CyclicCoordinateConservation",
    status := .schema,
    prerequisites := ["concept.cyclic_coordinate", "analytical.lagrange_equation", "analytical.conservation_law"],
    usedFor := ["identify conserved generalized momentum", "reduce Lagrangian systems", "central-force and symmetry planning"],
    verifiedDecls := ["MechLib.Analytical.ConservationLaw.cyclic_coordinate_implies_momentum_conserved"],
    schemaDecls := [
      "MechLib.Analytical.ConservationLaw.IsCyclicCoordinate",
      "MechLib.Analytical.ConservationLaw.GeneralizedMomentumConserved",
      "MechLib.Analytical.ConservationLaw.CyclicCoordinateConservation"
    ]
  },
  {
    id := "law.dynamics.angular_momentum_conservation",
    zhName := "角动量守恒",
    enName := "angular momentum conservation",
    statementText := "If the external torque about a point vanishes, the angular momentum about that point is conserved.",
    formalPropName := some "MechLib.Mechanics.Rotation.AngularMomentumTheoremParticle",
    status := .schema,
    prerequisites := ["concept.moment", "dynamics.angular_momentum"],
    usedFor := ["central-force modeling", "rigid-body angular-momentum balance", "orbit planning"],
    verifiedDecls := ["MechLib.Systems.Verified.CentralForce.hookeCentralForce_torque_zero", "MechLib.Systems.Verified.CentralForce.hookeCentralForce_isCentral"],
    schemaDecls := ["MechLib.Mechanics.Rotation.AngularMomentumTheoremParticle", "MechLib.Mechanics.Rotation.MomentOfMomentumTheoremSystem"]
  },
  {
    id := "law.analytical.small_oscillation_equation",
    zhName := "小振动方程",
    enName := "small-oscillation equation",
    statementText := "Near a stable equilibrium, the linearized coordinates satisfy a mass-matrix and stiffness-matrix oscillator equation.",
    formalPropName := none,
    status := .schema,
    prerequisites := ["concept.lagrangian", "concept.kinetic_energy", "concept.potential_energy"],
    usedFor := ["normal-mode analysis", "coupled oscillator modeling", "linearized stability"],
    verifiedDecls := ["MechLib.Systems.Verified.SHM.acceleration_eq_neg_omega_sq_mul_pos"],
    schemaDecls := ["MechLib.Mechanics.SHM.SHMEquation"]
  }
]

def lawSchemasJson : Json :=
  Json.arr (lawSchemas.map LawSchema.toJson).toArray

end LawSchema
end Spec
end MechLib
