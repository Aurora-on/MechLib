import MechLib.Spec.Status

namespace MechLib
namespace Spec
namespace Coverage

open Lean

/-- One course topic in the theoretical-mechanics coverage matrix. -/
structure CoverageTopic where
  id : String
  zhName : String
  enName : String
  modulePath : String
  status : DeclStatus
  trustLevel : TrustLevel
  prerequisites : List String
  keyConcepts : List String
  laws : List String
  problemTemplates : List String
  verifiedDecls : List String
  schemaDecls : List String
  examples : List String
  aliasesZh : List String
  aliasesEn : List String
deriving Repr

/-- One textbook chapter area in the coverage matrix. -/
structure CoverageChapter where
  id : String
  zhName : String
  enName : String
  topics : List CoverageTopic
deriving Repr

def CoverageTopic.toJson (t : CoverageTopic) : Json :=
  Json.mkObj [
    ("id", Json.str t.id),
    ("zh_name", Json.str t.zhName),
    ("en_name", Json.str t.enName),
    ("module_path", Json.str t.modulePath),
    ("status", Json.str t.status.toString),
    ("trust_level", Json.str t.trustLevel.toString),
    ("prerequisites", stringListJson t.prerequisites),
    ("key_concepts", stringListJson t.keyConcepts),
    ("laws", stringListJson t.laws),
    ("problem_templates", stringListJson t.problemTemplates),
    ("verified_decls", stringListJson t.verifiedDecls),
    ("schema_decls", stringListJson t.schemaDecls),
    ("examples", stringListJson t.examples),
    ("aliases_zh", stringListJson t.aliasesZh),
    ("aliases_en", stringListJson t.aliasesEn)
  ]

def CoverageChapter.toJson (c : CoverageChapter) : Json :=
  Json.mkObj [
    ("id", Json.str c.id),
    ("zh_name", Json.str c.zhName),
    ("en_name", Json.str c.enName),
    ("topics", Json.arr (c.topics.map CoverageTopic.toJson).toArray)
  ]

private def topic
    (id zhName enName modulePath : String)
    (status : DeclStatus)
    (trustLevel : TrustLevel)
    (prerequisites keyConcepts laws problemTemplates verifiedDecls schemaDecls examples aliasesZh aliasesEn :
      List String) : CoverageTopic :=
  {
    id := id
    zhName := zhName
    enName := enName
    modulePath := modulePath
    status := status
    trustLevel := trustLevel
    prerequisites := prerequisites
    keyConcepts := keyConcepts
    laws := laws
    problemTemplates := problemTemplates
    verifiedDecls := verifiedDecls
    schemaDecls := schemaDecls
    examples := examples
    aliasesZh := aliasesZh
    aliasesEn := aliasesEn
  }

private def foundationTopics : List CoverageTopic := [
  topic "foundation.dimensions" "量纲" "dimensions" "MechLib.Foundation.Dim"
    .verified .core
    [] ["BaseDim", "Dim", "basis dimension", "dimension equality"]
    ["dimension exponent algebra"]
    ["check dimensional consistency", "derive target quantity dimension"]
    ["MechLib.Units.Dim.ext", "MechLib.Units.Dim.basis_apply_same", "MechLib.Units.Dim.basis_apply_ne"]
    []
    ["verify speed*time has length dimension"]
    ["量纲", "基本量纲", "导出量纲"] ["dimension", "base dimension", "derived dimension"],
  topic "foundation.quantity" "带量纲标量" "quantity" "MechLib.Foundation.Quantity"
    .verified .core
    ["foundation.dimensions"] ["Quantity", "typed scalar", "unit value", "dimension cast"]
    ["same-dimension addition", "dimensioned multiplication", "unit conversion"]
    ["compute scalar value in units", "cast equivalent dimensions"]
    ["MechLib.Units.Quantity.cast_val", "MechLib.Units.Quantity.inUnits_self", "MechLib.Units.Quantity.inUnits_trans", "MechLib.Units.Quantity.inUnits_injective"]
    []
    ["read a force in newtons", "convert between two units of the same dimension"]
    ["物理量", "带量纲量", "标量物理量"] ["quantity", "dimensioned scalar", "physical scalar"],
  topic "foundation.vector_quantity" "带量纲向量" "vector quantity" "MechLib.Foundation.VecQuantity"
    .verified .core
    ["foundation.dimensions", "foundation.quantity"] ["VecQuantity", "dot product", "cross product", "component value"]
    ["vector addition", "dot-product dimension", "cross-product dimension"]
    ["work as force dot displacement", "torque as radius cross force"]
    ["MechLib.Units.VecQuantity.cast_val", "MechLib.Units.VecQuantity.dot_val", "MechLib.Systems.Verified.CentralForce.cross_self_zero"]
    []
    ["show r cross r is zero", "compute one-dimensional vector work"]
    ["带量纲向量", "矢量物理量"] ["vector quantity", "dimensioned vector"],
  topic "foundation.si_units" "SI 单位" "SI units" "MechLib.Foundation.SI"
    .verified .core
    ["foundation.dimensions", "foundation.quantity"] ["SI base unit", "derived SI unit", "unit conversion", "dimension bridge theorem"]
    ["SI derived-dimension equalities", "conversion-factor composition", "conversion-factor inverse law"]
    ["convert a quantity into chosen units", "derive a formula dimension from SI base dimensions"]
    ["MechLib.SI.speed_time_eq_length", "MechLib.SI.force_time_eq_momentum", "MechLib.SI.mass_two_speed_eq_energy", "MechLib.SI.conversionFactor_comp", "MechLib.SI.conversionFactor_mul_swap"]
    []
    ["read acceleration in meters per second squared", "check that force times time is momentum"]
    ["SI单位", "国际单位制", "基本单位", "导出单位"] ["SI units", "International System of Units", "base unit", "derived unit"],
  topic "foundation.geometry" "几何对象" "geometry" "MechLib.Foundation.Geometry"
    .todo .interface
    ["foundation.vector_quantity"] ["point", "directed segment", "distance", "angle"]
    ["distance residual", "diagram geometry constraints"]
    ["encode a mechanics diagram", "state a geometric distance relation"]
    []
    []
    ["represent a lever arm as a directed segment"]
    ["几何", "点", "线段", "距离", "角度"] ["geometry", "point", "segment", "distance", "angle"],
  topic "foundation.reference_frame" "参考系" "reference frame" "MechLib.Foundation.ReferenceFrame"
    .todo .interface
    ["foundation.vector_quantity"] ["inertial frame", "non-inertial frame", "frame transform"]
    ["transport theorem", "relative derivative relation"]
    ["model a rotating frame", "state inertial vs relative acceleration"]
    []
    ["MechLib.Mechanics.Kinematics.TransportTheoremRelation"]
    ["rotating-frame derivative planning problem"]
    ["参考系", "惯性系", "非惯性系"] ["reference frame", "inertial frame", "non-inertial frame"],
  topic "foundation.coordinate_system" "坐标系" "coordinate system" "MechLib.Foundation.CoordinateSystem"
    .todo .interface
    ["foundation.reference_frame"] ["Cartesian coordinates", "polar coordinates", "generalized coordinates"]
    ["coordinate representation", "basis component mapping"]
    ["choose coordinates for constrained motion", "translate diagram variables into coordinates"]
    []
    []
    ["plan polar-coordinate modeling for central-force motion"]
    ["坐标系", "直角坐标", "极坐标", "广义坐标"] ["coordinate system", "Cartesian coordinates", "polar coordinates", "generalized coordinates"]
]

private def staticsTopics : List CoverageTopic := [
  topic "statics.force_system" "力系" "force system" "MechLib.Statics.ForceSystem"
    .todo .interface
    ["foundation.vector_quantity"] ["force", "resultant", "line of action", "free body diagram"]
    ["resultant force", "force transmissibility"]
    ["reduce a coplanar force system", "draw a free-body diagram"]
    [] [] ["beam with multiple applied loads"]
    ["力系", "主矢", "合力"] ["force system", "resultant force", "free-body diagram"],
  topic "statics.moment" "力矩" "moment" "MechLib.Statics.Moment"
    .verified .core
    ["foundation.vector_quantity", "statics.force_system"] ["moment", "torque", "moment arm"]
    ["moment equals radius cross force"]
    ["compute moment about a point", "check zero moment for central force"]
    ["MechLib.RigidBody.Verified.Rotation.torque_def", "MechLib.Systems.Verified.CentralForce.hookeCentralForce_torque_zero"]
    []
    ["compute torque from r and F"]
    ["力矩", "转矩", "力臂"] ["moment", "torque", "moment arm"],
  topic "statics.couple" "力偶" "couple" "MechLib.Statics.Couple"
    .todo .interface
    ["statics.moment"] ["couple", "free vector moment", "couple equivalence"]
    ["couple moment independence of origin"]
    ["replace a force pair by a couple"]
    [] [] ["two equal and opposite forces on a rigid body"]
    ["力偶", "力偶矩"] ["couple", "couple moment"],
  topic "statics.equilibrium" "平衡" "equilibrium" "MechLib.Statics.Equilibrium"
    .todo .interface
    ["statics.force_system", "statics.moment"] ["static equilibrium", "force balance", "moment balance"]
    ["sum of forces is zero", "sum of moments is zero"]
    ["solve support reactions", "test a rigid body for equilibrium"]
    [] [] ["simply supported beam reaction forces"]
    ["平衡", "静力平衡", "受力平衡"] ["equilibrium", "static equilibrium", "force balance"],
  topic "statics.constraint_force" "约束力" "constraint force" "MechLib.Statics.ConstraintForce"
    .todo .interface
    ["statics.equilibrium"] ["normal force", "tension", "support reaction", "ideal constraint"]
    ["ideal constraint work condition", "reaction-force balance"]
    ["solve string tension", "solve pin support reactions"]
    [] [] ["block supported by a cable and wall"]
    ["约束力", "支持力", "张力", "反力"] ["constraint force", "normal force", "tension", "reaction force"],
  topic "statics.friction" "摩擦" "friction" "MechLib.Statics.Friction"
    .todo .interface
    ["statics.constraint_force"] ["static friction", "kinetic friction", "friction cone", "coefficient of friction"]
    ["Coulomb friction inequality", "limiting friction law"]
    ["block on rough incline", "ladder with friction"]
    [] [] ["rough incline impending motion"]
    ["摩擦", "静摩擦", "动摩擦", "摩擦角"] ["friction", "static friction", "kinetic friction", "friction angle"],
  topic "statics.truss" "桁架" "truss" "MechLib.Statics.Truss"
    .todo .example
    ["statics.equilibrium"] ["two-force member", "joint equilibrium", "method of joints", "method of sections"]
    ["joint force balance", "zero-force member criterion"]
    ["solve a planar truss by joints", "cut a truss section"]
    [] [] ["three-bar triangular truss"]
    ["桁架", "二力杆", "节点法", "截面法"] ["truss", "two-force member", "method of joints", "method of sections"]
]

private def kinematicsTopics : List CoverageTopic := [
  topic "kinematics.point_motion" "点的运动" "point motion" "MechLib.Kinematics.PointMotion"
    .verified .core
    ["foundation.quantity"] ["trajectory", "velocity", "acceleration", "constant acceleration"]
    ["velocity is derivative of position", "constant-acceleration update"]
    ["constant-speed displacement", "constant-acceleration displacement"]
    ["MechLib.Kinematics.Verified.Kinematics.displacement_eq_sub", "MechLib.Kinematics.Verified.Kinematics.constant_speed_relation", "MechLib.Kinematics.Verified.Kinematics.velocity_increment", "MechLib.Kinematics.Verified.Kinematics.displacement_forms_equiv"]
    []
    ["particle moving with constant acceleration"]
    ["点运动", "速度", "加速度"] ["point motion", "velocity", "acceleration"],
  topic "kinematics.coordinate_motion" "坐标运动" "coordinate motion" "MechLib.Kinematics.CoordinateMotion"
    .todo .interface
    ["foundation.coordinate_system", "kinematics.point_motion"] ["component motion", "Cartesian components", "polar components"]
    ["component-wise kinematics", "coordinate-dependent velocity decomposition"]
    ["derive polar acceleration", "decompose planar velocity"]
    [] [] ["projectile described in Cartesian coordinates"]
    ["坐标运动", "分量运动"] ["coordinate motion", "component motion"],
  topic "kinematics.relative_motion" "相对运动" "relative motion" "MechLib.Kinematics.RelativeMotion"
    .verified .derived
    ["kinematics.point_motion"] ["relative trajectory", "relative velocity", "relative acceleration"]
    ["relative position transitivity", "relative velocity transitivity"]
    ["three-body relative velocity", "rigid distance velocity equality"]
    ["MechLib.Kinematics.Verified.Kinematics.relative_trajectory_trans", "MechLib.Kinematics.Verified.Kinematics.relative_velocity_trans", "MechLib.Kinematics.Verified.Kinematics.relative_acceleration_trans", "MechLib.Kinematics.Verified.Kinematics.hasVelocity_relative"]
    []
    ["relative velocity between two vehicles"]
    ["相对运动", "相对速度", "相对加速度"] ["relative motion", "relative velocity", "relative acceleration"],
  topic "kinematics.rigid_body_motion" "刚体运动" "rigid body motion" "MechLib.Kinematics.RigidBodyMotion"
    .schema .interface
    ["kinematics.relative_motion"] ["rigid constraint", "rigid pair", "body frame"]
    ["rigid distance implies equal constrained velocity along fixed separation"]
    ["rigid link velocity relation", "rigid body velocity field planning"]
    ["MechLib.Kinematics.Verified.Kinematics.rigid_pair_velocity_equal", "MechLib.Kinematics.Verified.Kinematics.rigid_pair_vec_velocity_equal"]
    ["MechLib.Mechanics.Kinematics.TransportTheoremRelation"]
    ["two points connected by a rigid rod"]
    ["刚体运动", "刚体约束"] ["rigid body motion", "rigid constraint"],
  topic "kinematics.planar_motion" "平面运动" "planar motion" "MechLib.Kinematics.PlanarMotion"
    .todo .interface
    ["kinematics.rigid_body_motion"] ["instantaneous center", "plane motion", "translation plus rotation"]
    ["planar rigid-body velocity composition"]
    ["find instantaneous center", "relate velocities on a rolling body"]
    [] [] ["sliding rod planar motion"]
    ["平面运动", "瞬心", "平面刚体"] ["planar motion", "instantaneous center", "plane rigid body"],
  topic "kinematics.fixed_axis_rotation" "定轴转动" "fixed-axis rotation" "MechLib.Kinematics.FixedAxisRotation"
    .schema .interface
    ["kinematics.rigid_body_motion"] ["angular velocity", "angular acceleration", "rotation angle"]
    ["fixed-axis angular kinematics", "rotational kinetic relation"]
    ["wheel spinning with angular acceleration", "pulley fixed-axis motion"]
    ["MechLib.RigidBody.Verified.Rotation.rotationalKineticEnergy_eq"]
    ["MechLib.Mechanics.Rotation.EulerEquationsPrincipal"]
    ["fixed pulley angular speed"]
    ["定轴转动", "角速度", "角加速度"] ["fixed-axis rotation", "angular velocity", "angular acceleration"]
]

private def dynamicsTopics : List CoverageTopic := [
  topic "dynamics.newton_law" "牛顿定律" "Newton law" "MechLib.Dynamics.NewtonLaw"
    .verified .core
    ["foundation.quantity", "kinematics.point_motion"] ["force", "mass", "acceleration", "Newton second law"]
    ["F = m a", "vector Newton second law"]
    ["force from known acceleration", "mass under several forces"]
    ["MechLib.Dynamics.Verified.Dynamics.newton_second_law", "MechLib.Dynamics.Verified.Dynamics.secondLawVec_eq", "MechLib.Dynamics.Verified.Dynamics.force_from_velocity_rate_const_mass"]
    []
    ["block accelerated by a constant force"]
    ["牛顿定律", "牛顿第二定律"] ["Newton law", "Newton's second law"],
  topic "dynamics.particle_dynamics" "质点动力学" "particle dynamics" "MechLib.Dynamics.ParticleDynamics"
    .schema .interface
    ["dynamics.newton_law"] ["particle", "free-body equation", "constraint force"]
    ["particle force balance", "normal/tension/friction modeling"]
    ["block on incline", "particle on circular track"]
    ["MechLib.Dynamics.Verified.Dynamics.newton_second_law"]
    []
    ["single particle under gravity and tension"]
    ["质点动力学", "受力分析"] ["particle dynamics", "free-body equation"],
  topic "dynamics.system_dynamics" "质点系动力学" "system dynamics" "MechLib.Dynamics.SystemDynamics"
    .verified .derived
    ["dynamics.particle_dynamics"] ["system of particles", "center of mass", "total momentum"]
    ["center-of-mass theorem", "two-body kinetic decomposition"]
    ["two-body center of mass", "system momentum balance"]
    ["MechLib.Dynamics.Verified.SystemDynamics.totalMass_cons", "MechLib.Dynamics.Verified.SystemDynamics.centerOfMassVelocity_singleton", "MechLib.Dynamics.Verified.SystemDynamics.totalMomentum_two_eq_totalMass_mul_centerVelocity", "MechLib.Dynamics.Verified.SystemDynamics.twoBody_kineticEnergy_decomposition"]
    ["MechLib.Mechanics.SystemDynamics.CenterOfMassTheorem"]
    ["two masses connected by an internal force"]
    ["质点系", "质心", "系统动力学"] ["system dynamics", "center of mass", "particle system"],
  topic "dynamics.momentum" "动量" "momentum" "MechLib.Dynamics.Momentum"
    .verified .core
    ["dynamics.newton_law"] ["linear momentum", "constant mass momentum", "momentum change"]
    ["p = m v", "Delta p = m Delta v"]
    ["compute momentum change", "relate force to velocity rate"]
    ["MechLib.Dynamics.Verified.Dynamics.momentum_change_const_mass"]
    []
    ["speed change of a constant-mass particle"]
    ["动量", "线动量"] ["momentum", "linear momentum"],
  topic "dynamics.angular_momentum" "角动量" "angular momentum" "MechLib.Dynamics.AngularMomentum"
    .schema .interface
    ["foundation.vector_quantity", "dynamics.momentum"] ["angular momentum", "moment of momentum", "torque"]
    ["L = r cross p", "angular momentum theorem"]
    ["central force torque test", "moment of momentum balance"]
    ["MechLib.RigidBody.Verified.Rotation.torque_def", "MechLib.Systems.Verified.CentralForce.hookeCentralForce_isCentral"]
    ["MechLib.Mechanics.Rotation.AngularMomentumTheoremParticle", "MechLib.Mechanics.Rotation.MomentOfMomentumTheoremSystem"]
    ["particle moving under central force"]
    ["角动量", "动量矩"] ["angular momentum", "moment of momentum"],
  topic "dynamics.work_energy" "功和能" "work-energy" "MechLib.Dynamics.WorkEnergy"
    .verified .core
    ["foundation.vector_quantity", "dynamics.newton_law"] ["work", "kinetic energy", "potential energy", "mechanical energy"]
    ["work-energy theorem", "conservative/nonconservative split"]
    ["net work and kinetic energy change", "spring potential energy"]
    ["MechLib.Dynamics.Verified.WorkEnergy.work_def", "MechLib.Dynamics.Verified.WorkEnergy.kineticEnergy_change_formula", "MechLib.Dynamics.Verified.WorkEnergy.work_energy_theorem_core", "MechLib.Dynamics.Verified.WorkEnergy.conservative_nonconservative_split"]
    []
    ["block pushed by a constant force", "spring compression energy"]
    ["功", "动能", "势能", "机械能"] ["work", "kinetic energy", "potential energy", "mechanical energy"],
  topic "dynamics.impulse" "冲量" "impulse" "MechLib.Dynamics.Impulse"
    .verified .core
    ["dynamics.momentum"] ["impulse", "time interval", "momentum increment"]
    ["impulse equals force times time", "impulse-momentum theorem"]
    ["constant force impulse", "impact momentum update"]
    ["MechLib.Dynamics.Verified.MomentumImpulse.impulse_def", "MechLib.Dynamics.Verified.MomentumImpulse.impulse_momentum_theorem"]
    []
    ["hammer impact with known average force"]
    ["冲量", "冲量定理"] ["impulse", "impulse-momentum theorem"],
  topic "dynamics.collision" "碰撞" "collision" "MechLib.Dynamics.Collision"
    .verified .derived
    ["dynamics.momentum", "dynamics.impulse"] ["inelastic collision", "common final speed", "momentum conservation"]
    ["perfectly inelastic momentum conservation"]
    ["two carts stick together", "one-dimensional impact"]
    ["MechLib.Dynamics.Verified.MomentumImpulse.momentum_conservation_inelastic"]
    []
    ["perfectly inelastic collision of two masses"]
    ["碰撞", "完全非弹性碰撞"] ["collision", "inelastic collision"],
  topic "dynamics.non_inertial_frame" "非惯性系" "non-inertial frame" "MechLib.Dynamics.NonInertialFrame"
    .schema .interface
    ["foundation.reference_frame", "dynamics.newton_law"] ["fictitious force", "Coriolis term", "centrifugal term", "Euler term"]
    ["transport theorem", "non-inertial force balance"]
    ["bead in rotating frame", "block on rotating disk"]
    []
    ["MechLib.Mechanics.Kinematics.TransportTheoremRelation"]
    ["particle observed in a rotating frame"]
    ["非惯性系", "惯性力", "科氏力", "离心力"] ["non-inertial frame", "fictitious force", "Coriolis force", "centrifugal force"],
  topic "dynamics.variable_mass" "变质量" "variable mass" "MechLib.Dynamics.VariableMass"
    .schema .interface
    ["dynamics.momentum", "dynamics.system_dynamics"] ["variable mass", "mass flux", "rocket equation"]
    ["momentum balance with flux"]
    ["rocket acceleration", "sand leaking cart"]
    ["MechLib.Dynamics.Verified.SystemDynamics.variableMassMomentumBalance_eq"]
    ["MechLib.Mechanics.SystemDynamics.VariableMassMomentumBalance"]
    ["rocket with exhaust velocity"]
    ["变质量", "火箭方程"] ["variable mass", "rocket equation"]
]

private def rigidBodyTopics : List CoverageTopic := [
  topic "rigidbody.inertia" "转动惯量" "inertia" "MechLib.RigidBody.Inertia"
    .verified .core
    ["foundation.quantity"] ["moment of inertia", "inertia tensor", "parallel axis theorem"]
    ["parallel-axis relation", "rotational kinetic energy"]
    ["compute inertia about shifted axis", "use inertia tensor interface"]
    ["MechLib.RigidBody.Verified.Rotation.parallel_axis_theorem", "MechLib.RigidBody.Verified.Rotation.rotationalKineticEnergy_eq"]
    ["MechLib.Mechanics.Rotation.InertiaTensor"]
    ["rigid body rotating about a displaced axis"]
    ["转动惯量", "惯量张量", "平行轴定理"] ["moment of inertia", "inertia tensor", "parallel axis theorem"],
  topic "rigidbody.fixed_axis_dynamics" "定轴转动动力学" "fixed-axis dynamics" "MechLib.RigidBody.FixedAxisDynamics"
    .schema .interface
    ["rigidbody.inertia", "kinematics.fixed_axis_rotation"] ["torque equation", "angular acceleration", "rotational work"]
    ["sum torque equals I alpha", "fixed-axis energy relation"]
    ["pulley with hanging mass", "flywheel under torque"]
    ["MechLib.RigidBody.Verified.Rotation.torque_def"]
    []
    ["fixed-axis pulley dynamics"]
    ["定轴动力学", "转动方程"] ["fixed-axis dynamics", "rotational equation"],
  topic "rigidbody.plane_motion_dynamics" "平面运动动力学" "plane motion dynamics" "MechLib.RigidBody.PlaneMotionDynamics"
    .todo .interface
    ["rigidbody.inertia", "kinematics.planar_motion"] ["mass center motion", "rotation about center", "rolling constraint"]
    ["plane rigid-body Newton-Euler equations"]
    ["rolling cylinder down incline", "sliding and rotating disk"]
    [] [] ["rolling disk with friction"]
    ["平面运动动力学", "质心运动"] ["plane motion dynamics", "center-of-mass motion"],
  topic "rigidbody.euler_equations" "欧拉方程" "Euler equations" "MechLib.RigidBody.EulerEquations"
    .schema .interface
    ["rigidbody.inertia"] ["principal axes", "Euler equations", "body angular velocity"]
    ["principal-axis Euler equations"]
    ["torque-free rigid body", "rigid body with principal moments"]
    ["MechLib.RigidBody.Verified.Rotation.rigidBodyKineticDecomposition_eq"]
    ["MechLib.Mechanics.Rotation.EulerEquationsPrincipal"]
    ["torque-free asymmetric top"]
    ["欧拉方程", "主轴"] ["Euler equations", "principal axes"],
  topic "rigidbody.gyroscope" "陀螺" "gyroscope" "MechLib.RigidBody.Gyroscope"
    .todo .example
    ["rigidbody.euler_equations", "dynamics.angular_momentum"] ["precession", "nutation", "spin", "gyroscopic moment"]
    ["steady precession balance", "gyroscopic angular momentum relation"]
    ["symmetric top precession", "gyroscope under gravity"]
    [] [] ["heavy symmetric top steady precession"]
    ["陀螺", "进动", "章动"] ["gyroscope", "precession", "nutation"]
]

private def analyticalTopics : List CoverageTopic := [
  topic "analytical.generalized_coordinates" "广义坐标" "generalized coordinates" "MechLib.Analytical.GeneralizedCoordinates"
    .schema .interface
    ["foundation.coordinate_system"] ["CoordSpec", "GCoord", "GVel", "generalized force", "generalized momentum", "degree of freedom", "configuration space"]
    ["coordinate chart for constrained systems"]
    ["choose generalized coordinate for pendulum", "model bead on hoop"]
    []
    ["MechLib.Analytical.GeneralizedCoordinates.CoordSpec", "MechLib.Analytical.GeneralizedCoordinates.GCoord", "MechLib.Analytical.GeneralizedCoordinates.GVel", "MechLib.Analytical.GeneralizedCoordinates.GeneralizedForce", "MechLib.Analytical.GeneralizedCoordinates.GeneralizedMomentum"]
    ["single pendulum with angle coordinate"]
    ["广义坐标", "自由度", "构型空间"] ["generalized coordinate", "degree of freedom", "configuration space"],
  topic "analytical.constraints" "约束" "constraints" "MechLib.Analytical.Constraints"
    .schema .interface
    ["analytical.generalized_coordinates"] ["holonomic constraint", "nonholonomic constraint", "Pfaff form"]
    ["linear constraint derivative", "Pfaff constraint linear closure"]
    ["derive velocity relation from rope length", "combine Pfaff constraints"]
    ["MechLib.Kinematics.Verified.Kinematics.linear_constraint_velocity", "MechLib.Kinematics.Verified.Kinematics.linear_constraint_acceleration", "MechLib.Kinematics.Verified.Kinematics.pfaffConstraint1D_linear_combination"]
    ["MechLib.Analytical.Constraints.HolonomicConstraint", "MechLib.Analytical.Constraints.NonHolonomicConstraint", "MechLib.Analytical.Constraints.HolonomicConstraintSatisfied", "MechLib.Mechanics.Kinematics.PfaffConstraint1D"]
    ["rope constraint between two masses"]
    ["约束", "完整约束", "非完整约束"] ["constraint", "holonomic constraint", "nonholonomic constraint"],
  topic "analytical.virtual_work" "虚功" "virtual work" "MechLib.Analytical.VirtualWork"
    .schema .interface
    ["statics.constraint_force", "analytical.constraints"] ["VirtualDisplacement", "VirtualWorkValue", "VirtualWorkResidual", "ideal constraint"]
    ["principle of virtual work"]
    ["static equilibrium by virtual work", "constraint reaction elimination"]
    [] ["MechLib.Analytical.VirtualWork.VirtualDisplacement", "MechLib.Analytical.VirtualWork.VirtualWorkResidual", "MechLib.Analytical.VirtualWork.IdealConstraintVirtualWork"] ["virtual work for pulley system"]
    ["虚功", "虚位移"] ["virtual work", "virtual displacement"],
  topic "analytical.dalembert_principle" "达朗贝尔原理" "d'Alembert principle" "MechLib.Analytical.DAlembert"
    .schema .interface
    ["dynamics.newton_law", "analytical.virtual_work"] ["InertialGeneralizedForce", "DAlembertResidual", "dynamic equilibrium", "generalized inertia force"]
    ["d'Alembert principle", "dynamic virtual work"]
    ["derive equation by d'Alembert principle", "convert dynamics to virtual work"]
    [] ["MechLib.Analytical.DAlembert.InertialGeneralizedForce", "MechLib.Analytical.DAlembert.DAlembertResidual"] ["mass on moving wedge"]
    ["达朗贝尔原理", "惯性力"] ["d'Alembert principle", "inertial force"],
  topic "analytical.lagrange_equation" "拉格朗日方程" "Lagrange equation" "MechLib.Analytical.LagrangeEquation"
    .verified .derived
    ["analytical.generalized_coordinates", "analytical.constraints"] ["Lagrangian", "LagrangianSystem", "EulerLagrangeResidual", "generalized momentum", "generalized force"]
    ["Euler-Lagrange equation", "Newton form equivalence in 1D"]
    ["derive oscillator equation from L = T - V", "conservative one-dimensional system"]
    ["MechLib.Analytical.LagrangeEquation.lagrangian1D_eq", "MechLib.Analytical.LagrangeEquation.eulerLagrange_iff_newton", "MechLib.Analytical.LagrangeEquation.eulerLagrange_iff_newton_course_form"]
    ["MechLib.Analytical.LagrangeEquation.LagrangianSystem", "MechLib.Analytical.LagrangeEquation.EulerLagrangeResidual", "MechLib.Analytical.LagrangeEquation.GeneralizedMomentumOf", "MechLib.Analytical.LagrangeEquation.SatisfiesEulerLagrange1D", "MechLib.Analytical.LagrangeEquation.eulerLagrangeResidual1D"]
    ["mass-spring Lagrange equation"]
    ["拉格朗日方程", "欧拉-拉格朗日方程"] ["Lagrange equation", "Euler-Lagrange equation"],
  topic "analytical.hamiltonian" "哈密顿量" "Hamiltonian" "MechLib.Analytical.Hamiltonian"
    .verified .derived
    ["analytical.lagrange_equation"] ["Hamiltonian", "HamiltonianSystem", "canonical momentum", "canonical equations", "Legendre regularity"]
    ["Hamiltonian energy form", "canonical equations"]
    ["convert from velocity to momentum", "write Hamiltonian for 1D potential"]
    ["MechLib.Analytical.Hamiltonian.canonicalMomentum1D_eq", "MechLib.Analytical.Hamiltonian.hamiltonianXV_eq", "MechLib.Analytical.Hamiltonian.hamiltonianXP_eq", "MechLib.Analytical.Hamiltonian.hamiltonianXP_of_canonicalMomentum"]
    ["MechLib.Analytical.Hamiltonian.HamiltonianSystem", "MechLib.Analytical.Hamiltonian.CanonicalEquationResidual", "MechLib.Analytical.Hamiltonian.CanonicalEquations1D", "MechLib.Analytical.Hamiltonian.legendreRegular1D"]
    ["one-dimensional conservative Hamiltonian"]
    ["哈密顿量", "正则动量", "正则方程"] ["Hamiltonian", "canonical momentum", "canonical equations"],
  topic "analytical.poisson_bracket" "泊松括号" "Poisson bracket" "MechLib.Analytical.PoissonBracket"
    .verified .derived
    ["analytical.hamiltonian"] ["PhaseFunction", "PhaseGradient", "Poisson bracket", "antisymmetry"]
    ["Poisson bracket antisymmetry"]
    ["show bracket changes sign under argument swap"]
    ["MechLib.Analytical.PoissonBracket.poissonBracket1D_antisymm", "MechLib.Analytical.PoissonBracket.poissonBracket1D_antisymm_course_form"]
    ["MechLib.Analytical.PoissonBracket.PoissonBracket", "MechLib.Analytical.PoissonBracket.PoissonBracketResidualN", "MechLib.Analytical.PoissonBracket.poissonBracket1D", "MechLib.Analytical.PoissonBracket.PhaseFunction1D"]
    ["canonical phase-function bracket"]
    ["泊松括号", "相空间函数"] ["Poisson bracket", "phase function"],
  topic "analytical.conservation_law" "守恒律" "conservation law" "MechLib.Analytical.ConservationLaw"
    .verified .derived
    ["analytical.lagrange_equation"] ["cyclic coordinate", "generalized momentum conservation", "energy conservation"]
    ["cyclic coordinate implies conserved momentum", "cyclic-coordinate conservation law", "work-energy conservation split"]
    ["use cyclic coordinate to prove momentum conservation", "identify conserved mechanical energy"]
    ["MechLib.Analytical.ConservationLaw.cyclic_coordinate_implies_momentum_conserved", "MechLib.Analytical.ConservationLaw.cyclic_coordinate_implies_momentum_conserved_1d", "MechLib.Dynamics.Verified.WorkEnergy.conservative_nonconservative_split"]
    ["MechLib.Analytical.ConservationLaw.IsCyclicCoordinate", "MechLib.Analytical.ConservationLaw.GeneralizedMomentumConserved", "MechLib.Analytical.ConservationLaw.CyclicCoordinateConservation", "MechLib.Analytical.ConservationLaw.IsCyclicCoordinate1D", "MechLib.Analytical.ConservationLaw.MomentumConserved1D"]
    ["coordinate-independent Lagrangian gives conserved momentum"]
    ["守恒律", "循环坐标", "动量守恒"] ["conservation law", "cyclic coordinate", "momentum conservation"],
  topic "analytical.small_oscillations" "小振动" "small oscillations" "MechLib.Analytical.SmallOscillations"
    .schema .interface
    ["analytical.lagrange_equation", "systems.harmonic_oscillator"] ["SmallOscillationSystem", "equilibrium", "linearization", "mass matrix", "stiffness matrix", "normal modes"]
    ["linearized equation", "normal-mode eigenproblem"]
    ["small oscillations near equilibrium", "coupled oscillator normal modes"]
    [] ["MechLib.Analytical.SmallOscillations.SmallOscillationSystem", "MechLib.Analytical.SmallOscillations.SmallOscillationEquation", "MechLib.Analytical.SmallOscillations.NormalModeCondition"] ["two-mass two-spring normal modes"]
    ["小振动", "线性化", "固有频率", "正常模态"] ["small oscillations", "linearization", "natural frequency", "normal modes"]
]

private def systemsTopics : List CoverageTopic := [
  topic "systems.harmonic_oscillator" "简谐振子" "harmonic oscillator" "MechLib.Systems.HarmonicOscillator"
    .verified .core
    ["dynamics.work_energy"] ["amplitude", "phase", "period", "SHM equation"]
    ["x'' = -omega^2 x", "period-frequency relation"]
    ["spring-mass oscillator", "infer amplitude from initial data"]
    ["MechLib.Systems.Verified.SHM.acceleration_eq_neg_omega_sq_mul_pos", "MechLib.Systems.Verified.SHM.period_frequency_relation", "MechLib.Systems.Verified.SHM.initialPosition_eq", "MechLib.Systems.Verified.SHM.initialVelocity_eq"]
    ["MechLib.Mechanics.SHM.SHMEquation", "MechLib.Mechanics.SHM.UniqueByInitialState"]
    ["undamped spring-mass oscillator"]
    ["简谐振子", "简谐运动"] ["harmonic oscillator", "simple harmonic motion"],
  topic "systems.damped_oscillator" "阻尼振子" "damped oscillator" "MechLib.Systems.DampedOscillator"
    .verified .derived
    ["systems.harmonic_oscillator"] ["damping coefficient", "damping ratio", "quality factor", "regime discriminant"]
    ["damped residual", "damping-regime trichotomy", "energy dissipation law"]
    ["classify damping regime", "compute damping ratio and quality factor"]
    ["MechLib.Systems.Verified.DampedSHM.equationResidual_eq", "MechLib.Systems.Verified.DampedSHM.regimes_trichotomy", "MechLib.Systems.Verified.DampedSHM.qualityFactor_mul_dampingRatio", "MechLib.Systems.Verified.DampedSHM.equationOfMotion_gamma_zero_iff"]
    ["MechLib.Mechanics.DampedSHM.EquationOfMotion", "MechLib.Mechanics.DampedSHM.EnergyDissipationLaw"]
    ["mass-spring-damper oscillator"]
    ["阻尼振子", "欠阻尼", "临界阻尼", "过阻尼"] ["damped oscillator", "underdamped", "critical damping", "overdamped"],
  topic "systems.pendulum" "单摆" "pendulum" "MechLib.Systems.Pendulum"
    .schema .example
    ["analytical.lagrange_equation", "systems.harmonic_oscillator"] ["Pendulum.Params", "angle coordinate", "kinetic energy", "potential energy", "Lagrangian", "small-angle approximation"]
    ["pendulum equation", "small-angle approximation", "small-angle reduction to SHM"]
    ["derive single pendulum equation", "period under small angle"]
    ["MechLib.Systems.Pendulum.smallAngle_to_SHM"]
    ["MechLib.Systems.Pendulum.kineticEnergy", "MechLib.Systems.Pendulum.potentialEnergy", "MechLib.Systems.Pendulum.lagrangian", "MechLib.Systems.Pendulum.equationResidual", "MechLib.Systems.Pendulum.PendulumEquationResidual"]
    ["simple pendulum released from rest"]
    ["单摆", "摆角", "小角近似"] ["pendulum", "simple pendulum", "small-angle approximation"],
  topic "systems.physical_pendulum" "复摆" "physical pendulum" "MechLib.Systems.PhysicalPendulum"
    .schema .example
    ["rigidbody.inertia", "systems.pendulum"] ["PhysicalPendulum.Params", "moment of inertia", "center of mass", "pivot point", "equivalent length"]
    ["physical pendulum equation", "small-angle period schema"]
    ["rigid body oscillating about pivot", "compound pendulum"]
    [] ["MechLib.Systems.PhysicalPendulum.kineticEnergy", "MechLib.Systems.PhysicalPendulum.potentialEnergy", "MechLib.Systems.PhysicalPendulum.lagrangian", "MechLib.Systems.PhysicalPendulum.smallAngleEquation", "MechLib.Systems.PhysicalPendulum.physical_pendulum_period"] ["rod pivoted at one end"]
    ["复摆", "物理摆"] ["physical pendulum", "compound pendulum"],
  topic "systems.central_force" "中心力" "central force" "MechLib.Systems.CentralForce"
    .verified .derived
    ["dynamics.angular_momentum", "analytical.conservation_law"] ["polar coordinates", "central force", "effective potential", "circular orbit", "orbit class"]
    ["zero torque for central Hooke force", "effective potential", "circular-orbit condition", "Kepler second-law interface"]
    ["classify inverse-square orbit", "derive radial equation"]
    ["MechLib.Systems.Verified.CentralForce.hookeCentralForce_isCentral", "MechLib.Systems.Verified.CentralForce.effectivePotential_eq", "MechLib.Systems.Verified.CentralForce.inverseSquarePotential_eq", "MechLib.Systems.Verified.CentralForce.classifyInverseSquareOrbit_trichotomy"]
    ["MechLib.Systems.CentralForce.polarCoordSpec", "MechLib.Systems.CentralForce.kineticEnergyPolar", "MechLib.Systems.CentralForce.effectivePotentialScalar", "MechLib.Systems.CentralForce.circularOrbitCondition", "MechLib.Systems.CentralForce.stableCircularOrbitCondition", "MechLib.Mechanics.CentralForce.RadialEquation", "MechLib.Mechanics.CentralForce.BinetEquation", "MechLib.Mechanics.CentralForce.KeplerSecondLaw"]
    ["planet in inverse-square potential"]
    ["中心力", "有效势", "轨道"] ["central force", "effective potential", "orbit"],
  topic "systems.atwood_machine" "阿特伍德机" "Atwood machine" "MechLib.Systems.AtwoodMachine"
    .schema .example
    ["dynamics.particle_dynamics", "analytical.constraints"] ["AtwoodMachine.Params", "pulley", "tension", "mass difference", "rope constraint", "reduced coordinate"]
    ["rope acceleration constraint", "Lagrangian residual", "acceleration formula schema"]
    ["solve acceleration and tension", "mass-pulley system"]
    [] ["MechLib.Systems.AtwoodMachine.AtwoodConstraint", "MechLib.Systems.AtwoodMachine.reducedConstraint", "MechLib.Systems.AtwoodMachine.lagrangian", "MechLib.Systems.AtwoodMachine.equationResidual", "MechLib.Systems.AtwoodMachine.accelerationFormula"] ["ideal Atwood machine with two masses"]
    ["阿特伍德机", "滑轮系统"] ["Atwood machine", "pulley system"],
  topic "systems.coupled_oscillator" "耦合振子" "coupled oscillator" "MechLib.Systems.CoupledOscillator"
    .schema .example
    ["analytical.small_oscillations", "systems.harmonic_oscillator"] ["two coordinates", "mass matrix", "stiffness matrix", "coupling spring", "normal coordinates", "normal modes"]
    ["coupled linear oscillator equations", "normal-mode decomposition", "identity normal-mode worked example"]
    ["two coupled masses", "symmetric and antisymmetric modes"]
    [] ["MechLib.Systems.CoupledOscillator.CoupledOscillatorModel", "MechLib.Systems.CoupledOscillator.kineticEnergy", "MechLib.Systems.CoupledOscillator.potentialEnergy", "MechLib.Systems.CoupledOscillator.lagrangian", "MechLib.Systems.CoupledOscillator.linearEquationResidual", "MechLib.Systems.CoupledOscillator.NormalModeResidual"] ["two equal masses coupled by springs"]
    ["耦合振子", "正常模态"] ["coupled oscillator", "normal modes"],
  topic "systems.rolling_disk" "滚动圆盘" "rolling disk" "MechLib.Systems.RollingDisk"
    .schema .example
    ["kinematics.planar_motion", "rigidbody.plane_motion_dynamics"] ["RollingDisk.Params", "rolling without slipping", "contact constraint", "disk inertia", "nonholonomic constraint"]
    ["rolling constraint v = R omega", "nonholonomic rolling constraint", "energy of rolling body"]
    ["disk rolling down an incline", "wheel rolling without slip"]
    [] ["MechLib.Systems.RollingDisk.RollingNoSlipResidual", "MechLib.Systems.RollingDisk.noSlipConstraint", "MechLib.Systems.RollingDisk.nonholonomicConstraintSchema", "MechLib.Systems.RollingDisk.rollingKineticEnergy"] ["solid disk rolling down rough incline"]
    ["滚动圆盘", "无滑动滚动"] ["rolling disk", "rolling without slipping"],
  topic "systems.bead_on_hoop" "圆环上珠子" "bead on hoop" "MechLib.Systems.BeadOnHoop"
    .schema .example
    ["analytical.constraints", "systems.pendulum"] ["BeadOnHoop.Params", "bead constraint", "hoop coordinate", "effective potential", "normal reaction"]
    ["constraint reaction on a circle", "effective-potential equilibrium", "stability condition schema"]
    ["bead sliding on vertical hoop", "rotating hoop bead equilibrium"]
    [] ["MechLib.Systems.BeadOnHoop.HoopConstraintResidual", "MechLib.Systems.BeadOnHoop.effectivePotential", "MechLib.Systems.BeadOnHoop.equilibriumCondition", "MechLib.Systems.BeadOnHoop.stabilityCondition"] ["bead on a rotating hoop"]
    ["圆环上珠子", "环上滑珠"] ["bead on hoop", "bead on a ring"]
]

def coverageChapters : List CoverageChapter := [
  { id := "foundation", zhName := "基础", enName := "Foundation", topics := foundationTopics },
  { id := "statics", zhName := "静力学", enName := "Statics", topics := staticsTopics },
  { id := "kinematics", zhName := "运动学", enName := "Kinematics", topics := kinematicsTopics },
  { id := "dynamics", zhName := "动力学", enName := "Dynamics", topics := dynamicsTopics },
  { id := "rigidbody", zhName := "刚体", enName := "RigidBody", topics := rigidBodyTopics },
  { id := "analytical", zhName := "分析力学", enName := "Analytical", topics := analyticalTopics },
  { id := "systems", zhName := "代表系统", enName := "Systems", topics := systemsTopics }
]

/-- JSON source of truth for the theoretical-mechanics coverage matrix. -/
def coverageMatrixJson : Json :=
  Json.mkObj [
    ("schema_version", Json.str "coverage-matrix-v1"),
    ("source_module", Json.str "MechLib.Spec.Coverage"),
    ("chapters", Json.arr (coverageChapters.map CoverageChapter.toJson).toArray)
  ]

end Coverage
end Spec
end MechLib
