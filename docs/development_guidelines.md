# 开发规范

本文档给出 MechLib 后续开发的约束和建议。目标是保持库的三个核心性质：带量纲、分层、可检索。

## 1. 量纲优先

公开物理 API 应优先使用：

- `MechLib.SI` 类型别名；
- `MechLib.Units.Quantity`；
- `MechLib.Units.VecQuantity`。

不要在课程层重新定义核心物理量类型，例如：

- `Length`
- `Mass`
- `Time`
- `Force`
- `Energy`
- `Momentum`
- `Torque`

如果缺少某个物理量类型，应优先在 `MechLib.SI` 或合适的基础模块中新增 typed alias 和 bridge lemma。只有在量纲表达暂不确定时，才允许保留 clearly documented temporary fallback。

允许使用裸 `ℝ` 的场景：

- 无量纲系数；
- 数学索引；
- 矩阵下标或矩阵元素；
- `.val` 投影后的数值层；
- 坐标图值；
- metadata；
- 局部数学 helper；
- 明确标记为 temporary fallback 的 value-level wrapper。

## 2. Theorem 放置规则

新增 theorem/lemma 应放在对应课程 Lean 模块中：

- 运动学 theorem：`MechLib/Kinematics/*` 或 `MechLib/Kinematics/Verified.lean`
- 动力学 theorem：`MechLib/Dynamics/*` 或 `MechLib/Dynamics/Verified.lean`
- 刚体 theorem：`MechLib/RigidBody/*` 或 `MechLib/RigidBody/Verified.lean`
- 分析力学 theorem：`MechLib/Analytical/*`
- 系统 theorem：`MechLib/Systems/*` 或 `MechLib/Systems/Verified.lean`

`MechLib/Mechanics/*` 当前主要作为兼容实现层，不应作为新增 retrieval-facing theorem 的首选位置。

允许新增 theorem 的情况：

- 定义展开即可证明，例如 `by rfl`；
- 简单 bridge lemma，可用 `simp`、`simpa`、`rw`、`exact`、`linarith`、`ring` 等短 proof 完成；
- 直接复用已有 verified theorem；
- 对 proof automation 或 retrieval 明显有帮助的稳定命题。

禁止新增 theorem 的情况：

- 需要 `axiom`；
- 需要不受控 `sorry` 或 `admit`；
- 只是为了让 coverage 看起来完整；
- 实际只是 schema、假设性规律或未验证复杂结论。

## 3. Spec 层规则

`MechLib/Spec/*` 用于 metadata 和 planning-level semantics。

Spec 层可以包含：

- `DeclStatus`
- `TrustLevel`
- `ConceptSpec`
- `LawSchema`
- `ProblemSchema`
- `CoverageTopic`
- `ModuleMetadata`
- JSON/corpus source-of-truth helper definitions

Spec 层不应包含：

- fake theorem；
- 未证明物理定律 theorem；
- `axiom`；
- 不受控 `sorry`。

复杂内容应表达为：

- concept schema；
- law schema；
- problem schema；
- residual definition；
- metadata；
- module catalog entry。

## 4. Verified / Schema 分层

分层规则：

- `verified`：Lean 已检查 theorem/lemma 或稳定定义。
- `schema`：建模和检索用接口，不进入 proof whitelist。
- `alias`：名称或术语映射。
- `experimental`：实验性 API，默认不进入 proving。
- `todo`：课程覆盖占位或待建模内容。

pipeline proving 阶段只能使用 verified/core 或 verified/derived declaration。schema 可以用于 planning，但不能当作 theorem。

## 5. Metadata 与 Alignment

新增 theorem 后应检查：

1. 是否出现在 `corpus/theorem_corpus.jsonl`；
2. 是否有合理 `required_imports`；
3. 是否有 `proof_hints`；
4. 是否能通过 `tools/link_theorems_to_spec.py` 映射到合理 Spec；
5. 是否需要在 `tools/export_overrides.yaml` 中补人工 override。

新增 schema/module 后应检查：

1. 是否更新对应 `ModuleMetadata`；
2. 是否更新 coverage topic；
3. 是否进入正确 corpus；
4. 是否没有被标记为 `callable_by_llm = true`。

## 6. Proof-Friendly 风格

推荐 proof pattern：

```lean
  have hVal : ... := by
    simpa [...] using congrArg Quantity.val h
  have hAlg : ... := by
    linarith [hVal]
  ext
  simpa using hAlg
```

常用 tactic：

- `rfl`
- `simp`
- `simpa`
- `rw`
- `exact`
- `ext`
- `ring`
- `linarith`
- `norm_num`

谨慎添加 `@[simp]`。只给方向明确、不会造成循环重写的 verified theorem 添加 simp 属性。schema/interface 不能添加 proof automation 属性。

## 7. 新模块 Checklist

新增课程模块时至少包含：

- module docstring；
- namespace；
- 必要 imports；
- 一个核心 `structure`、`abbrev` 或 `def`；
- 至少一个有语义的 formula/residual/schema；
- 一个 `moduleMetadata`；
- 至少一个 `#check` 或 checked `example`；
- coverage/spec topic 关联；
- status 与 trust level；
- 如果已有 theorem 可对应，应通过 wrapper theorem 或 alignment metadata 挂接。

## 8. 导出与检查流程

常规检查：

```bash
lake build
rg -n "^\\s*(axiom|constant|opaque)\\b|\\b(sorry|admit)\\b" MechLib tools || true
python3 tools/check_no_new_axioms.py
```

更新 coverage：

```bash
python3 tools/export_coverage_matrix.py
python3 tools/export_coverage_matrix.py --check
```

更新 Spec corpus：

```bash
python3 tools/export_spec_corpus.py
```

更新 theorem corpus：

```bash
python3 tools/export_llm_corpus.py \
  --out corpus/theorem_corpus.jsonl \
  --alias-out corpus/alias_map.jsonl \
  --report-out corpus/export_report.json
```

更新 alignment：

```bash
python3 tools/link_theorems_to_spec.py
```

量纲审计：

```bash
python3 tools/audit_dimension_usage.py
```

Python 脚本检查：

```bash
python3 -m py_compile \
  tools/export_coverage_matrix.py \
  tools/export_spec_corpus.py \
  tools/export_llm_corpus.py \
  tools/link_theorems_to_spec.py \
  tools/audit_dimension_usage.py \
  tools/check_no_new_axioms.py
```

## 9. 文档规则

README 与 docs 应遵守：

- 中文优先；
- 不声称所有理论力学 theorem 已 fully proved；
- 不声称 pipeline 已完整实现；
- 明确区分 current implementation 与 future work；
- 路径、命令、统计必须以当前仓库实际文件为准；
- 新增重大模块后同步更新 README 或相关 docs。
