import MechLib.Foundation
import MechLib.Statics
import MechLib.Kinematics
import MechLib.Dynamics
import MechLib.RigidBody
import MechLib.Analytical
import MechLib.Systems

namespace MechLib
namespace Spec
namespace ModuleCatalog

open Lean

/-- All course-layer module metadata records. -/
def moduleMetadata : List ModuleMetadata := [
  MechLib.Foundation.Dim.moduleMetadata,
  MechLib.Foundation.Quantity.moduleMetadata,
  MechLib.Foundation.VecQuantity.moduleMetadata,
  MechLib.Foundation.SI.moduleMetadata,
  MechLib.Foundation.ReferenceFrame.moduleMetadata,
  MechLib.Foundation.CoordinateSystem.moduleMetadata,
  MechLib.Foundation.Geometry.moduleMetadata,
  MechLib.Statics.ForceSystem.moduleMetadata,
  MechLib.Statics.Moment.moduleMetadata,
  MechLib.Statics.Couple.moduleMetadata,
  MechLib.Statics.Equilibrium.moduleMetadata,
  MechLib.Statics.ConstraintForce.moduleMetadata,
  MechLib.Statics.Friction.moduleMetadata,
  MechLib.Statics.Truss.moduleMetadata,
  MechLib.Kinematics.PointMotion.moduleMetadata,
  MechLib.Kinematics.CoordinateMotion.moduleMetadata,
  MechLib.Kinematics.RelativeMotion.moduleMetadata,
  MechLib.Kinematics.RigidBodyMotion.moduleMetadata,
  MechLib.Kinematics.PlanarMotion.moduleMetadata,
  MechLib.Kinematics.FixedAxisRotation.moduleMetadata,
  MechLib.Dynamics.NewtonLaw.moduleMetadata,
  MechLib.Dynamics.ParticleDynamics.moduleMetadata,
  MechLib.Dynamics.SystemDynamics.moduleMetadata,
  MechLib.Dynamics.Momentum.moduleMetadata,
  MechLib.Dynamics.AngularMomentum.moduleMetadata,
  MechLib.Dynamics.WorkEnergy.moduleMetadata,
  MechLib.Dynamics.Impulse.moduleMetadata,
  MechLib.Dynamics.Collision.moduleMetadata,
  MechLib.Dynamics.NonInertialFrame.moduleMetadata,
  MechLib.Dynamics.VariableMass.moduleMetadata,
  MechLib.RigidBody.Inertia.moduleMetadata,
  MechLib.RigidBody.FixedAxisDynamics.moduleMetadata,
  MechLib.RigidBody.PlaneMotionDynamics.moduleMetadata,
  MechLib.RigidBody.EulerEquations.moduleMetadata,
  MechLib.RigidBody.Gyroscope.moduleMetadata,
  MechLib.Analytical.GeneralizedCoordinates.moduleMetadata,
  MechLib.Analytical.Constraints.moduleMetadata,
  MechLib.Analytical.VirtualWork.moduleMetadata,
  MechLib.Analytical.DAlembert.moduleMetadata,
  MechLib.Analytical.LagrangeEquation.moduleMetadata,
  MechLib.Analytical.Hamiltonian.moduleMetadata,
  MechLib.Analytical.PoissonBracket.moduleMetadata,
  MechLib.Analytical.ConservationLaw.moduleMetadata,
  MechLib.Analytical.SmallOscillations.moduleMetadata,
  MechLib.Systems.HarmonicOscillator.moduleMetadata,
  MechLib.Systems.DampedOscillator.moduleMetadata,
  MechLib.Systems.Pendulum.moduleMetadata,
  MechLib.Systems.PhysicalPendulum.moduleMetadata,
  MechLib.Systems.CentralForce.moduleMetadata,
  MechLib.Systems.AtwoodMachine.moduleMetadata,
  MechLib.Systems.CoupledOscillator.moduleMetadata,
  MechLib.Systems.RollingDisk.moduleMetadata,
  MechLib.Systems.BeadOnHoop.moduleMetadata
]

/-- JSON export for course-layer module metadata. -/
def moduleMetadataJson : Json :=
  Json.arr (moduleMetadata.map ModuleMetadata.toJson).toArray

end ModuleCatalog
end Spec
end MechLib
