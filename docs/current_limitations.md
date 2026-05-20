# 当前边界与限制

本文档记录 MechLib 当前实现的边界，避免在论文、答辩或后续 pipeline 文档中过度表述。

## 1. 证明覆盖边界

MechLib 已经包含一批 Lean kernel 检查过的 theorem/lemma，但尚未 fully proved 全部工科本科理论力学内容。

当前已经较稳定的部分包括：

- 量纲与 SI bridge lemmas；
- 基础运动学公式和相对运动关系；
- 牛顿定律、动量、冲量、功-能等部分动力学 theorem；
- 部分刚体惯量与系统动力学 theorem；
- 一维 Euler-Lagrange residual 与 Newton form 的桥接；
- 部分典型系统的 verified 辅助 theorem。

当前仍主要以 schema、residual 或 interface 保留的内容包括：

- 一般静力学求解流程；
- 摩擦、桁架、复杂约束系统；
- 非惯性系与变质量系统的完整 theorem；
- 一般刚体 Euler equations 与陀螺近似；
- 一般 n 自由度 Euler-Lagrange / Hamiltonian 完整变分推导；
- 小振动的一般谱理论；
- 单摆、物理摆、Atwood 机、滚动圆盘、圆环珠子等复杂系统的完整解。

## 2. Schema 不是 Proof Corpus

`ConceptSpec`、`LawSchema`、`ProblemSchema` 和 coverage topic 的目标是语义建模、检索和规划。它们不是 Lean theorem。

证明阶段不能直接使用：

- `concept_corpus.jsonl`
- `law_schema_corpus.jsonl`
- `problem_schema_corpus.jsonl`
- coverage topic metadata

证明阶段应使用：

- `corpus/theorem_corpus.jsonl`
- `corpus/decl_corpus_enriched.jsonl`

并且需要检查 `status = verified`、`trust_level`、`callable_by_llm` 和 `required_imports`。

## 3. Alignment 当前状态

当前 `corpus/spec_alignment_report.json` 记录：

- total declarations: 310
- matched declarations: 310
- unmatched declarations: 0
- needs review: 3
- callable by LLM: 301

剩余 3 条 `needs_review` 是 `CentralForce` 证明中的有限维索引 helper，不是课程语义 theorem。它们被保留为 review 状态，避免误进入高价值 proof retrieval。当前不可调用声明只剩 6 个展示用 example theorem 和这 3 个内部索引 helper。

详细说明见：

- `reports/alignment_review_report.md`

## 4. 量纲与 Typed API 边界

MechLib 的公开物理 API 应优先使用 `MechLib.SI`、`Quantity` 和 `VecQuantity`。当前量纲审计显示：

- 核心量纲模块存在并被 `MechLib.lean` 顶层导入；
- theorem corpus 中包含 Units/SI 相关声明；
- 课程层仍有部分 raw `ℝ` 使用。
- 当前审计中 `public real API review candidates = 25`，`temporary fallback occurrences = 8`。

当前 raw `ℝ` 使用分为几类：

- 合理使用：无量纲系数、矩阵下标、矩阵元素、`.val` 投影、时间参数、局部数学 helper；
- temporary fallback：为了保留复杂系统 value-level wrapper；
- review candidate：后续应继续 typed migration。

详细审计见：

- `reports/dimension_audit_report.md`
- `corpus/dimension_audit_report.json`

## 5. Corpus 与源码同步边界

Lean 源码新增 theorem/example 后，已生成的 `corpus/*.jsonl` 不会自动更新。需要手动运行 exporter：

```bash
python3 tools/export_llm_corpus.py \
  --out corpus/theorem_corpus.jsonl \
  --alias-out corpus/alias_map.jsonl \
  --report-out corpus/export_report.json
python3 tools/link_theorems_to_spec.py
```

README 中的 corpus 统计以当前文件内容为准，而不是动态扫描结果。

## 6. Pipeline 边界

MechLib 当前提供面向 pipeline 的语义资产：

- coverage matrix；
- Spec corpus；
- theorem corpus；
- module metadata corpus；
- Spec-declaration alignment；
- proof hints；
- dimension audit report。

但本仓库不声称已经完整实现：

- 下游题目解析；
- subgoal-level retrieval orchestration；
- whitelist-constrained generation；
- proof-agent search loop；
- benchmark execution dashboard。

这些属于后续 pipeline integration 工作。

## 7. 当前建议

近期优先级建议：

1. 从 schema 中选择小而稳定的命题提升为 verified theorem。
2. 继续强化 typed formulation，减少 review-level raw `ℝ` API。
3. 为新增 theorem 同步补充 alignment override 和 proof hints。
4. 保持 schema corpus 与 proof corpus 的隔离。
5. 定期运行 axiom/sorry audit 与 dimension audit。
