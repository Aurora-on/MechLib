# MechLib Solver Test（重排版）

## 1. 文档目的
- 用 Lean4Phys（LeanPhysBench）中的 5 道经典力学题，验证 MechLib 现有定理能否直接求解。
- 给出清晰、可复现、可阅读的代码与说明。

## 2. 数据与复现
- 数据集：`F:\AI4Mechanics\coding\Lean4PHYS\LeanPhysBench\LeanPhysBench_v0.json`
- 题目 ID：
  - `university_mechanics_Mechanics_1_University`
  - `university_mechanics_Mechanics_12_University`
  - `university_mechanics_Mechanics_59_University`
  - `university_mechanics_Mechanics_60_University`
  - `university_mechanics_Mechanics_67_University`
- 复现命令：

```bash
lake env lean .tmp_solver.lean
```

## 3. 结果总览

| 题号 | 物理主题 | 主用定理（MechLib） | 结论 |
|---|---|---|---|
| 1 | 平均速度 | `Kinematics.averageVelocity` | `v_avg = -12875/3024 ≈ -4.2586 m/s` |
| 12 | 位移 | `Kinematics.displacement` | `Δx = 15 m` |
| 59 | 牛顿第二定律 | `Dynamics.newton_second_law` | `a = 0.5 m/s^2` |
| 60 | 匀减速 + 牛顿第二定律 | `Dynamics.secondLaw` + 量纲 `cast` | `F = -0.9 N` |
| 67 | 加速度反推受力 | `Dynamics.secondLaw` + 量纲 `cast` | `F = 300 N` |

## 4. 公共辅助定理（题 60、67）

```lean
theorem two_speed_sub_length_eq_acceleration :
    (2 : Nat) • SI.speedDim - SI.lengthDim = SI.accelerationDim := by
  native_decide

theorem speed_sub_time_eq_acceleration :
    SI.speedDim - SI.timeDim = SI.accelerationDim := by
  native_decide
```

说明：
1. `two_speed_sub_length_eq_acceleration`：把 `(v^2)/s` 的量纲转换成加速度量纲。
2. `speed_sub_time_eq_acceleration`：把 `(m/s)/s` 转成 `m/s^2` 的量纲。
3. `native_decide`：让 Lean 自动完成量纲恒等式证明。

---

## 5. 题 1：海鸟返巢平均速度（Mechanics_1）

题目关键信息：
- 位移：`5150 km`（返巢方向取负）。
- 时间：`14 day`。
- 求：平均速度（m/s）。

### 代码
```lean
def dx1 : Length := (-5150 : Real) • (kilo meter)
def dt1 : Time := (14 : Real) • day

example :
    (Kinematics.averageVelocity dx1 dt1).val = (-(12875 / 3024 : Real)) := by
  norm_num [dx1, dt1, Kinematics.averageVelocity, kilo, meter, day, hour, minute, second,
    Quantity.standardUnit]
```

### 逐行说明
1. `dx1`：将题目中的 `5150 km` 写成长度量；符号取负表示“回巢”方向。
2. `dt1`：将 `14 day` 写成时间量。
3. `Kinematics.averageVelocity dx1 dt1`：调用平均速度定义 `v = dx / dt`。
4. `.val`：取物理量底层数值。
5. `norm_num [...]`：展开 `kilo/day/hour/minute/second` 并做数值化简。

---

## 6. 题 12：猎豹位移（Mechanics_12）

题目关键信息：
- `x(t) = 20 m + (5.0 m/s^2)t^2`
- 求 `t=1s` 到 `t=2s` 位移。

### 代码
```lean
def cheetahX (t : Time) : Length :=
  (20 : Real) • meter +
    Quantity.cast (((5 : Real) • meter / (second ** 2)) * (t ** 2))
      SI.acceleration_two_time_eq_length

example :
    Kinematics.displacement (cheetahX ((2 : Real) • second))
      (cheetahX ((1 : Real) • second)) = (15 : Real) • meter := by
  rw [Kinematics.displacement_eq_sub]
  ext
  norm_num [cheetahX, meter, second, Quantity.standardUnit, Quantity.cast_val]
```

### 逐行说明
1. `cheetahX`：把题目给定的 `x(t)` 直接编码成函数。
2. `20 • meter`：位置函数中的常数项 `20 m`。
3. `((5 • meter)/(second**2))*(t**2)`：加速度项 `5t^2`。
4. `Quantity.cast ... acceleration_two_time_eq_length`：将 `a*t^2` 从量纲上转成长度。
5. `Kinematics.displacement ...`：调用位移定义 `x2 - x1`。
6. `rw [displacement_eq_sub]`：把位移公式展开。
7. `ext`：物理量相等转成数值相等。
8. `norm_num`：自动算出 `x(2)-x(1)=15`。

---

## 7. 题 59：40kg 箱子受 20N 力（Mechanics_59）

题目关键信息：
- `m = 40 kg`
- `F = 20 N`
- 求加速度

### 代码
```lean
example :
    Dynamics.F_of ((40 : Real) • kilogram)
      ((0.5 : Real) • meter / (second ** 2))
      = (20 : Real) • newton := by
  rw [Dynamics.newton_second_law]
  ext
  norm_num [newton, kilogram, meter, second, Quantity.standardUnit]
```

### 逐行说明
1. `F_of (40kg) (0.5m/s^2)`：按 `F = ma` 写入候选加速度。
2. `= 20N`：目标是验证该加速度对应 20N。
3. `rw [newton_second_law]`：将 `F_of` 展开为 `m * a`。
4. `ext`：转到底层数值。
5. `norm_num`：自动验算 `40 * 0.5 = 20`。

---

## 8. 题 60：番茄酱瓶摩擦力（Mechanics_60）

题目关键信息：
- `m = 0.45 kg`
- `v0 = 2.0 m/s, v = 0`
- `s = 1.0 m`
- 求摩擦力大小和方向

### 代码
```lean
def v0_60 : Speed := (2 : Real) • meter / second
def v_60 : Speed := 0
def d_60 : Length := (1 : Real) • meter

def a_60_raw : Quantity ((2 : Nat) • SI.speedDim - SI.lengthDim) :=
  (v_60 ** 2 - v0_60 ** 2) / ((2 : Real) • d_60)

def a_60 : Acceleration := Quantity.cast a_60_raw two_speed_sub_length_eq_acceleration
def F_60 : Force := Dynamics.secondLaw ((0.45 : Real) • kilogram) a_60

example : F_60 = (-0.9 : Real) • newton := by
  ext
  norm_num [F_60, Dynamics.secondLaw, a_60, a_60_raw, v_60, v0_60, d_60,
    newton, kilogram, meter, second, Quantity.standardUnit, Quantity.cast_val]
```

### 逐行说明
1. `v0_60`：初速度 `2 m/s`。
2. `v_60`：末速度 `0`（停止）。
3. `d_60`：位移 `1 m`。
4. `a_60_raw`：按 `a=(v^2-v0^2)/(2s)` 计算加速度，先保留原始量纲。
5. `a_60`：把原始量纲 cast 成标准加速度量纲。
6. `F_60`：使用牛顿第二定律 `F=ma`。
7. `example`：验证最终摩擦力 `-0.9 N`。
8. `ext + norm_num`：展开定义并完成数值计算。

物理解释：负号表示摩擦力方向与运动方向相反，大小为 `0.9 N`。

---

## 9. 题 67：冰帆船受风力（Mechanics_67）

题目关键信息：
- `4.0 s` 后速度到 `6.0 m/s`（初速 0）
- 总质量 `200 kg`
- 求恒定水平风力

### 代码
```lean
def a_67 : Acceleration :=
  Quantity.cast
    (((6 : Real) • meter / second) / ((4 : Real) • second))
    speed_sub_time_eq_acceleration

def F_67 : Force := Dynamics.secondLaw ((200 : Real) • kilogram) a_67

example : F_67 = (300 : Real) • newton := by
  ext
  norm_num [F_67, a_67, Dynamics.secondLaw, newton, kilogram, meter, second,
    Quantity.standardUnit, Quantity.cast_val]
```

### 逐行说明
1. `a_67`：由 `a = Δv/Δt = 6/4` 计算加速度。
2. `Quantity.cast ... speed_sub_time_eq_acceleration`：保证量纲为加速度。
3. `F_67`：代入 `F = m a`，质量 `200 kg`。
4. `example`：验证结果 `300 N`。
5. `ext + norm_num`：完成数值层证明。

---

## 10. 备注
- 本文示例全部使用 MechLib 主 API；未直接调用 PhysLib。
- 若需要，我可以再给一版“PhysLib 兼容层写法（`MechLib.Compat.PHYSlib`）”的同题对照文档。
