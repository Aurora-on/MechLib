import Mathlib
import MechLib.SI

namespace MechLib
namespace Mechanics
namespace Kinematics

open Units SI

noncomputable section

/-- 一维位置轨迹 `x(t)`（时间参数取 `ℝ`，按秒计）。 -/
abbrev ScalarTrajectory := ℝ → Length

/-- 一维速度场 `v(t)`。 -/
abbrev ScalarVelocityField := ℝ → Speed

/-- 一维加速度场 `a(t)`。 -/
abbrev ScalarAccelerationField := ℝ → Acceleration

/-- 向量位置轨迹。 -/
abbrev VecTrajectory (n : ℕ) := ℝ → VecLength n

/-- 向量速度场。 -/
abbrev VecVelocityField (n : ℕ) := ℝ → VecSpeed n

/-- 向量加速度场。 -/
abbrev VecAccelerationField (n : ℕ) := ℝ → VecAcceleration n

/-- 速度是位置对时间的一阶导数（标量版）。 -/
def HasVelocity (x : ScalarTrajectory) (v : ScalarVelocityField) : Prop :=
  ∀ t : ℝ, HasDerivAt (fun τ => (x τ).val) (v t).val t

/-- 加速度是速度对时间的一阶导数（标量版）。 -/
def HasAcceleration (v : ScalarVelocityField) (a : ScalarAccelerationField) : Prop :=
  ∀ t : ℝ, HasDerivAt (fun τ => (v τ).val) (a t).val t

/-- 速度是位置对时间的一阶导数（向量版，按分量定义）。 -/
def HasVecVelocity {n : ℕ} (x : VecTrajectory n) (v : VecVelocityField n) : Prop :=
  ∀ t : ℝ, ∀ i : Fin n, HasDerivAt (fun τ => (x τ).val i) ((v t).val i) t

/-- 加速度是速度对时间的一阶导数（向量版，按分量定义）。 -/
def HasVecAcceleration {n : ℕ} (v : VecVelocityField n) (a : VecAccelerationField n) : Prop :=
  ∀ t : ℝ, ∀ i : Fin n, HasDerivAt (fun τ => (v τ).val i) ((a t).val i) t

def displacement (x2 x1 : Length) : Length := x2 - x1

def averageVelocity (dx : Length) (dt : Time) : Speed := dx / dt

def velocityConstAccel (v0 : Speed) (a : Acceleration) (t : Time) : Speed :=
  v0 + Quantity.cast (a * t) SI.acceleration_time_eq_speed

def positionConstAccel (x0 : Length) (v0 : Speed) (a : Acceleration) (t : Time) : Length :=
  x0
    + Quantity.cast (v0 * t) SI.speed_time_eq_length
    + (1 / 2 : ℝ) • Quantity.cast (a * (t ** 2)) SI.acceleration_two_time_eq_length

def displacementConstAccelForm2 (v0 v : Speed) (t : Time) : Length :=
  Quantity.cast (((v + v0) / (2 : ℝ)) * t) SI.speed_time_eq_length

/-- `B` 相对 `A` 的位置轨迹。 -/
def relativeTrajectory (xB xA : ScalarTrajectory) : ScalarTrajectory := fun t => xB t - xA t

/-- `B` 相对 `A` 的速度场。 -/
def relativeVelocity (vB vA : ScalarVelocityField) : ScalarVelocityField := fun t => vB t - vA t

/-- `B` 相对 `A` 的加速度场。 -/
def relativeAcceleration (aB aA : ScalarAccelerationField) : ScalarAccelerationField := fun t => aB t - aA t

/-- 向量版相对位置轨迹。 -/
def vecRelativeTrajectory {n : ℕ} (xB xA : VecTrajectory n) : VecTrajectory n := fun t => xB t - xA t

/-- 向量版相对速度场。 -/
def vecRelativeVelocity {n : ℕ} (vB vA : VecVelocityField n) : VecVelocityField n := fun t => vB t - vA t

/-- 向量版相对加速度场。 -/
def vecRelativeAcceleration {n : ℕ} (aB aA : VecAccelerationField n) : VecAccelerationField n :=
  fun t => aB t - aA t

/-- 位移函数与“终点减起点”定义等价。 -/
abbrev displacement_eq_sub (x2 x1 : Length) : displacement x2 x1 = x2 - x1 := rfl

/-- 若 `dx` 是从 `x1` 到 `x2` 的位移，则有位置更新关系 `x2 = x1 + dx`。 -/
abbrev position_from_displacement (x2 x1 dx : Length) (h : dx = displacement x2 x1) :
    x2 = x1 + dx := by
  have hval : dx.val = x2.val - x1.val := by
    simpa [displacement] using congrArg Quantity.val h
  ext
  simp [hval]

/-- 匀速条件下，若位移满足 `dx = v t`，则终点位置满足 `x2 = x1 + v t`。 -/
abbrev constant_speed_relation (x2 x1 : Length) (v : Speed) (t : Time)
    (h : displacement x2 x1 = Quantity.cast (v * t) SI.speed_time_eq_length) :
    x2 = x1 + Quantity.cast (v * t) SI.speed_time_eq_length := by
  have hval : x2.val - x1.val = (v * t).val := by
    simpa [displacement, Quantity.cast_val] using congrArg Quantity.val h
  have hsum : x2.val = x1.val + (v * t).val := by
    linarith [hval]
  ext
  simpa [Quantity.cast_val] using hsum

/-- 匀加速运动的速度增量公式：`v - v0 = a t`。 -/
abbrev velocity_increment (v v0 : Speed) (a : Acceleration) (t : Time)
    (h : v = velocityConstAccel v0 a t) :
    v - v0 = Quantity.cast (a * t) SI.acceleration_time_eq_speed := by
  have hval : v.val = v0.val + (a * t).val := by
    simpa [velocityConstAccel, Quantity.cast_val] using congrArg Quantity.val h
  have hdiff : v.val - v0.val = (a * t).val := by
    linarith [hval]
  ext
  simpa [Quantity.cast_val] using hdiff

/-- 匀加速位移两种常见表达式的等价性。 -/
abbrev displacement_forms_equiv (v v0 : Speed) (a : Acceleration) (t : Time)
    (hv : v = velocityConstAccel v0 a t) :
    Quantity.cast (v0 * t) SI.speed_time_eq_length
      + (1 / 2 : ℝ) • Quantity.cast (a * (t ** 2)) SI.acceleration_two_time_eq_length
        = displacementConstAccelForm2 v0 v t := by
  have hv' : v.val = v0.val + (a * t).val := by
    simpa [velocityConstAccel, Quantity.cast_val] using congrArg Quantity.val hv
  ext
  simp [displacementConstAccelForm2, Quantity.cast_val, hv']
  ring

/-- 绝对位置可分解为“参考系位置 + 相对位置”。 -/
abbrev trajectory_reconstruction (xB xA : ScalarTrajectory) :
    xB = fun t => xA t + relativeTrajectory xB xA t := by
  funext t
  ext
  simp [relativeTrajectory]

/-- 三个物体间的相对位移满足链式分解。 -/
abbrev relative_trajectory_trans (xA xB xC : ScalarTrajectory) :
    relativeTrajectory xC xA = fun t => relativeTrajectory xC xB t + relativeTrajectory xB xA t := by
  funext t
  ext
  simp [relativeTrajectory]

/-- 三个物体间的相对速度满足链式分解。 -/
abbrev relative_velocity_trans (vA vB vC : ScalarVelocityField) :
    relativeVelocity vC vA = fun t => relativeVelocity vC vB t + relativeVelocity vB vA t := by
  funext t
  ext
  simp [relativeVelocity]

/-- 三个物体间的相对加速度满足链式分解。 -/
abbrev relative_acceleration_trans (aA aB aC : ScalarAccelerationField) :
    relativeAcceleration aC aA =
      fun t => relativeAcceleration aC aB t + relativeAcceleration aB aA t := by
  funext t
  ext
  simp [relativeAcceleration]

/-- 若 `xA, xB` 可导，则相对位置 `xB - xA` 的导数为 `vB - vA`。 -/
abbrev hasVelocity_relative
    (xA xB : ScalarTrajectory) (vA vB : ScalarVelocityField)
    (hA : HasVelocity xA vA) (hB : HasVelocity xB vB) :
    HasVelocity (relativeTrajectory xB xA) (relativeVelocity vB vA) := by
  intro t
  simpa [relativeTrajectory, relativeVelocity] using (hB t).sub (hA t)

/-- 若 `vA, vB` 可导，则相对速度 `vB - vA` 的导数为 `aB - aA`。 -/
abbrev hasAcceleration_relative
    (vA vB : ScalarVelocityField) (aA aB : ScalarAccelerationField)
    (hA : HasAcceleration vA aA) (hB : HasAcceleration vB aB) :
    HasAcceleration (relativeVelocity vB vA) (relativeAcceleration aB aA) := by
  intro t
  simpa [relativeVelocity, relativeAcceleration] using (hB t).sub (hA t)

/-- 线性组合轨迹的导数等于对应速度场线性组合。 -/
abbrev hasVelocity_linear_combination
    (x1 x2 : ScalarTrajectory) (v1 v2 : ScalarVelocityField) (c1 c2 : ℝ)
    (h1 : HasVelocity x1 v1) (h2 : HasVelocity x2 v2) :
    HasVelocity (fun t => c1 • x1 t + c2 • x2 t) (fun t => c1 • v1 t + c2 • v2 t) := by
  intro t
  have h1' : HasDerivAt (fun τ => c1 * (x1 τ).val) (c1 * (v1 t).val) t := by
    simpa using (h1 t).const_mul c1
  have h2' : HasDerivAt (fun τ => c2 * (x2 τ).val) (c2 * (v2 t).val) t := by
    simpa using (h2 t).const_mul c2
  simpa using h1'.add h2'

/-- 线性组合速度场的导数等于对应加速度场线性组合。 -/
abbrev hasAcceleration_linear_combination
    (v1 v2 : ScalarVelocityField) (a1 a2 : ScalarAccelerationField) (c1 c2 : ℝ)
    (h1 : HasAcceleration v1 a1) (h2 : HasAcceleration v2 a2) :
    HasAcceleration (fun t => c1 • v1 t + c2 • v2 t) (fun t => c1 • a1 t + c2 • a2 t) := by
  intro t
  have h1' : HasDerivAt (fun τ => c1 * (v1 τ).val) (c1 * (a1 t).val) t := by
    simpa using (h1 t).const_mul c1
  have h2' : HasDerivAt (fun τ => c2 * (v2 τ).val) (c2 * (a2 t).val) t := by
    simpa using (h2 t).const_mul c2
  simpa using h1'.add h2'

/-- 两体满足线性位移约束 `c1 x1 + c2 x2 = 常数` 时，对应速度满足同系数线性约束。 -/
abbrev linear_constraint_velocity
    (x1 x2 : ScalarTrajectory) (v1 v2 : ScalarVelocityField)
    (c1 c2 : ℝ) (L : Length)
    (hConstraint : ∀ t, c1 • x1 t + c2 • x2 t = L)
    (h1 : HasVelocity x1 v1) (h2 : HasVelocity x2 v2) :
    ∀ t, c1 • v1 t + c2 • v2 t = 0 := by
  intro t
  have hDeriv : HasDerivAt
      (fun τ => (c1 • x1 τ + c2 • x2 τ).val)
      ((c1 • v1 t + c2 • v2 t).val) t := by
    simpa using (hasVelocity_linear_combination x1 x2 v1 v2 c1 c2 h1 h2 t)
  have hConst : HasDerivAt (fun τ => (c1 • x1 τ + c2 • x2 τ).val) 0 t := by
    have hEq : (fun τ => (c1 • x1 τ + c2 • x2 τ).val) = fun _ => L.val := by
      funext τ
      exact congrArg Quantity.val (hConstraint τ)
    rw [hEq]
    simpa using (hasDerivAt_const t L.val)
  have hZeroVal : (c1 • v1 t + c2 • v2 t).val = 0 := hDeriv.unique hConst
  ext
  simpa using hZeroVal

/-- 两体满足线性速度约束 `c1 v1 + c2 v2 = 常数` 时，对应加速度满足同系数线性约束。 -/
abbrev linear_constraint_acceleration
    (v1 v2 : ScalarVelocityField) (a1 a2 : ScalarAccelerationField)
    (c1 c2 : ℝ) (V : Speed)
    (hConstraint : ∀ t, c1 • v1 t + c2 • v2 t = V)
    (h1 : HasAcceleration v1 a1) (h2 : HasAcceleration v2 a2) :
    ∀ t, c1 • a1 t + c2 • a2 t = 0 := by
  intro t
  have hDeriv : HasDerivAt
      (fun τ => (c1 • v1 τ + c2 • v2 τ).val)
      ((c1 • a1 t + c2 • a2 t).val) t := by
    simpa using (hasAcceleration_linear_combination v1 v2 a1 a2 c1 c2 h1 h2 t)
  have hConst : HasDerivAt (fun τ => (c1 • v1 τ + c2 • v2 τ).val) 0 t := by
    have hEq : (fun τ => (c1 • v1 τ + c2 • v2 τ).val) = fun _ => V.val := by
      funext τ
      exact congrArg Quantity.val (hConstraint τ)
    rw [hEq]
    simpa using (hasDerivAt_const t V.val)
  have hZeroVal : (c1 • a1 t + c2 • a2 t).val = 0 := hDeriv.unique hConst
  ext
  simpa using hZeroVal

/-- 理想绳约束（`x1 + x2 = 常数`）推出速度关系 `v1 + v2 = 0`。 -/
abbrev rope_constraint_velocity
    (x1 x2 : ScalarTrajectory) (v1 v2 : ScalarVelocityField) (L : Length)
    (hConstraint : ∀ t, x1 t + x2 t = L)
    (h1 : HasVelocity x1 v1) (h2 : HasVelocity x2 v2) :
    ∀ t, v1 t + v2 t = 0 := by
  have hConstraint' : ∀ t, (1 : ℝ) • x1 t + (1 : ℝ) • x2 t = L := by
    intro t
    ext
    have hVal : (x1 t + x2 t).val = L.val := congrArg Quantity.val (hConstraint t)
    calc
      ((1 : ℝ) • x1 t + (1 : ℝ) • x2 t).val = (x1 t + x2 t).val := by
        simp [Quantity.val_smul]
      _ = L.val := hVal
  have hVel := linear_constraint_velocity x1 x2 v1 v2 (1 : ℝ) (1 : ℝ) L hConstraint' h1 h2
  intro t
  ext
  have hValEq :
      ((1 : ℝ) • v1 t + (1 : ℝ) • v2 t).val = (0 : Speed).val := by
    exact congrArg Quantity.val (hVel t)
  calc
    (v1 t + v2 t).val = ((1 : ℝ) • v1 t + (1 : ℝ) • v2 t).val := by
      simp [Quantity.val_smul]
    _ = (0 : Speed).val := hValEq

/-- 刚性间距约束 `xB - xA = 常数` 推出两体速度恒等。 -/
abbrev rigid_pair_velocity_equal
    (xA xB : ScalarTrajectory) (vA vB : ScalarVelocityField) (Δ : Length)
    (hConstraint : ∀ t, relativeTrajectory xB xA t = Δ)
    (hA : HasVelocity xA vA) (hB : HasVelocity xB vB) :
    ∀ t, vB t = vA t := by
  have hlin : ∀ t, (1 : ℝ) • xB t + (-1 : ℝ) • xA t = Δ := by
    intro t
    ext
    have hVal : (xB t).val - (xA t).val = Δ.val := by
      simpa [relativeTrajectory] using congrArg Quantity.val (hConstraint t)
    calc
      ((1 : ℝ) • xB t + (-1 : ℝ) • xA t).val = (xB t).val - (xA t).val := by
        calc
          ((1 : ℝ) • xB t + (-1 : ℝ) • xA t).val
              = (xB t).val + (-1 : ℝ) * (xA t).val := by
                simp [Quantity.val_smul]
          _ = (xB t).val - (xA t).val := by ring
      _ = Δ.val := hVal
  have hvel :=
    linear_constraint_velocity xB xA vB vA (1 : ℝ) (-1 : ℝ) Δ hlin hB hA
  intro t
  have hValEq :
      ((1 : ℝ) • vB t + (-1 : ℝ) • vA t).val = (0 : Speed).val := by
    exact congrArg Quantity.val (hvel t)
  have hDiff : (vB t).val - (vA t).val = 0 := by
    have hValEq' : (vB t).val + (-1 : ℝ) * (vA t).val = 0 := by
      simpa [Quantity.val_smul] using hValEq
    linarith [hValEq']
  ext
  linarith [hDiff]

def vecDisplacement {n : ℕ} (x2 x1 : VecLength n) : VecLength n := x2 - x1

def vecVelocityConstAccel {n : ℕ} (v0 : VecSpeed n) (a : VecAcceleration n) (t : Time) : VecSpeed n :=
  v0 + VecQuantity.cast (a * t) SI.acceleration_time_eq_speed

/-- 向量版匀加速速度更新定义的展开式。 -/
abbrev vec_velocity_const_accel_eq {n : ℕ} (v0 : VecSpeed n) (a : VecAcceleration n) (t : Time) :
    vecVelocityConstAccel v0 a t = v0 + VecQuantity.cast (a * t) SI.acceleration_time_eq_speed := rfl

/-- 向量版三体相对位移链式分解。 -/
abbrev vec_relative_trajectory_trans {n : ℕ} (xA xB xC : VecTrajectory n) :
    vecRelativeTrajectory xC xA =
      fun t => vecRelativeTrajectory xC xB t + vecRelativeTrajectory xB xA t := by
  funext t
  ext i
  simp [vecRelativeTrajectory]

/-- 向量版三体相对速度链式分解。 -/
abbrev vec_relative_velocity_trans {n : ℕ} (vA vB vC : VecVelocityField n) :
    vecRelativeVelocity vC vA =
      fun t => vecRelativeVelocity vC vB t + vecRelativeVelocity vB vA t := by
  funext t
  ext i
  simp [vecRelativeVelocity]

/-- 若向量轨迹可导，则其相对轨迹的导数为相对速度（按分量）。 -/
abbrev hasVecVelocity_relative {n : ℕ}
    (xA xB : VecTrajectory n) (vA vB : VecVelocityField n)
    (hA : HasVecVelocity xA vA) (hB : HasVecVelocity xB vB) :
    HasVecVelocity (vecRelativeTrajectory xB xA) (vecRelativeVelocity vB vA) := by
  intro t i
  simpa [vecRelativeTrajectory, vecRelativeVelocity] using (hB t i).sub (hA t i)

/-- 若向量速度场可导，则其相对速度导数为相对加速度（按分量）。 -/
abbrev hasVecAcceleration_relative {n : ℕ}
    (vA vB : VecVelocityField n) (aA aB : VecAccelerationField n)
    (hA : HasVecAcceleration vA aA) (hB : HasVecAcceleration vB aB) :
    HasVecAcceleration (vecRelativeVelocity vB vA) (vecRelativeAcceleration aB aA) := by
  intro t i
  simpa [vecRelativeVelocity, vecRelativeAcceleration] using (hB t i).sub (hA t i)

/-- 向量版刚性间距约束 `xB - xA = 常向量` 推出速度恒等。 -/
abbrev rigid_pair_vec_velocity_equal {n : ℕ}
    (xA xB : VecTrajectory n) (vA vB : VecVelocityField n) (r : VecLength n)
    (hConstraint : ∀ t, vecRelativeTrajectory xB xA t = r)
    (hA : HasVecVelocity xA vA) (hB : HasVecVelocity xB vB) :
    ∀ t, vB t = vA t := by
  intro t
  ext i
  have hRel : HasDerivAt
      (fun τ => (vecRelativeTrajectory xB xA τ).val i)
      ((vecRelativeVelocity vB vA t).val i) t := by
    simpa [vecRelativeTrajectory, vecRelativeVelocity] using (hB t i).sub (hA t i)
  have hConst : HasDerivAt (fun τ => (vecRelativeTrajectory xB xA τ).val i) 0 t := by
    have hEq : (fun τ => (vecRelativeTrajectory xB xA τ).val i) = fun _ => r.val i := by
      funext τ
      exact congrArg (fun q => q.val i) (hConstraint τ)
    rw [hEq]
    simpa using (hasDerivAt_const t (r.val i))
  have hZero : ((vecRelativeVelocity vB vA t).val i) = 0 := hRel.unique hConst
  have hDiff : (vB t).val i - (vA t).val i = 0 := by
    simpa [vecRelativeVelocity] using hZero
  linarith

example : (displacement ((10 : ℝ) • meter) ((4 : ℝ) • meter)).val = 6 := by
  norm_num [displacement, meter, Quantity.standardUnit]

example (x2 x1 dx : Length) (h : dx = displacement x2 x1) :
    x2 = x1 + dx := position_from_displacement x2 x1 dx h

example (a : VecAcceleration 3) (v0 : VecSpeed 3) (t : Time) :
    vecVelocityConstAccel v0 a t = v0 + VecQuantity.cast (a * t) SI.acceleration_time_eq_speed := rfl

example (xA xB xC : ScalarTrajectory) :
    relativeTrajectory xC xA = fun t => relativeTrajectory xC xB t + relativeTrajectory xB xA t :=
  relative_trajectory_trans xA xB xC

example (x1 x2 : ScalarTrajectory) (v1 v2 : ScalarVelocityField) (L : Length)
    (hConstraint : ∀ t, x1 t + x2 t = L)
    (h1 : HasVelocity x1 v1) (h2 : HasVelocity x2 v2) :
    ∀ t, v1 t + v2 t = 0 :=
  rope_constraint_velocity x1 x2 v1 v2 L hConstraint h1 h2

example {n : ℕ} (xA xB : VecTrajectory n) (vA vB : VecVelocityField n) (r : VecLength n)
    (hConstraint : ∀ t, vecRelativeTrajectory xB xA t = r)
    (hA : HasVecVelocity xA vA) (hB : HasVecVelocity xB vB) :
    ∀ t, vB t = vA t :=
  rigid_pair_vec_velocity_equal xA xB vA vB r hConstraint hA hB

/-- Frenet 标架接口（3D，按时间参数化）。 -/
structure FrenetFrameData where
  tangent : ℝ → VecQuantity (0 : Dim) 3
  normal : ℝ → VecQuantity (0 : Dim) 3
  binormal : ℝ → VecQuantity (0 : Dim) 3
  curvature : ℝ → Frequency

/-- 旋转参考系输运定理的接口形式。 -/
def TransportTheoremRelation {d : Dim}
    (dInertial dRelative : ℝ → VecQuantity (SI.angularVelocityDim + d) 3)
    (omega : ℝ → VecQuantity SI.angularVelocityDim 3)
    (A : ℝ → VecQuantity d 3) : Prop :=
  ∀ t, dInertial t = dRelative t + (omega t ×ᵥ A t)

/-- Pfaff 形式速度约束：`a(t) v(t) + b(t) = 0`（1D 接口版）。 -/
def PfaffConstraint1D (a b : ℝ → ℝ) (v : ScalarVelocityField) : Prop :=
  ∀ t, a t * (v t).val + b t = 0

/-- 两条 Pfaff 约束可按线性组合闭包。 -/
abbrev pfaffConstraint1D_linear_combination
    (a1 b1 a2 b2 : ℝ → ℝ) (v : ScalarVelocityField)
    (h1 : PfaffConstraint1D a1 b1 v) (h2 : PfaffConstraint1D a2 b2 v)
    (c1 c2 : ℝ) :
    PfaffConstraint1D (fun t => c1 * a1 t + c2 * a2 t) (fun t => c1 * b1 t + c2 * b2 t) v := by
  intro t
  have h1' : a1 t * (v t).val + b1 t = 0 := h1 t
  have h2' : a2 t * (v t).val + b2 t = 0 := h2 t
  have hcomb :
      (c1 * a1 t + c2 * a2 t) * (v t).val + (c1 * b1 t + c2 * b2 t)
        = c1 * (a1 t * (v t).val + b1 t) + c2 * (a2 t * (v t).val + b2 t) := by
    ring
  rw [hcomb]
  rw [h1', h2']
  ring

-- DONE[MECH_KIN_01]: added Frenet-frame formal interface (`FrenetFrameData`).
-- DONE[MECH_KIN_02]: added rotating-frame transport theorem interface (`TransportTheoremRelation`).
-- DONE[MECH_KIN_03]: added Pfaff-form nonholonomic constraint interface and linear-closure lemma.

end
end Kinematics
end Mechanics
end MechLib
