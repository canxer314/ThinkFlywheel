# Playground — 研究中间态工作区

> 临时脚本、过程性知识、未定论分析的工作空间。推理在这里推进，只有结论进入 vault。

## 问题

ThinkFlywheel 的 vault 是知识的**正式记录**。每张卡片经过双提议确认，每条 insight 经过复盘提取。这是好事——它保证了 vault 的信噪比。

但这种严谨性不适合研究的**中间态**：

- 你正在分析一个复杂问题，产生了 3 个互相矛盾的草稿推理
- 你写了一个临时 Python 脚本来验证某个假设
- 你从 5 篇论文中提取了原始数据，还没综合
- 你有一个直觉但还没想清楚怎么表达

这些中间产物不该进入 vault——它们会稀释知识密度。但也不能丢掉——它们是推理的中间步骤，丢了就断了溯源链。

## 方案

`.playground/` 是 vault 旁的一个**隐藏工作区**（Obsidian 不可见），专门承载研究过程的中间产物。

```
YourVault/
├── .claude/                   ← 基石规则和技能
├── .claude-plugins/           ← 按需加载的方法论插件
├── .playground/               ← 研究中间态工作区（本目录）
│   ├── README.md              ← 本文件（约定说明）
│   ├── active/                ← 当前活跃的研究会话
│   │   └── q3-product-direction/
│   │       ├── context.md     ← 从 vault 拉取的相关材料
│   │       ├── working/       ← 中间分析、草稿、脚本
│   │       │   ├── market-data.csv
│   │       │   ├── analyze.py
│   │       │   └── draft-reasoning.md
│   │       └── conclusions.md ← 最终结论（待回写 vault）
│   └── archived/              ← 已完成的研究会话
├── Tasks/                     ← vault 正式内容
├── Cards/                     ← vault 正式内容
└── ...
```

### 关键属性

| 属性 | 说明 |
|------|------|
| **Obsidian 不可见** | `.playground/` 是隐藏目录，Obsidian 文件浏览器不会显示，`obsidian search` 默认不索引 |
| **Git 忽略** | 应在 `.gitignore` 中加入 `.playground/`，不进入版本控制 |
| **会话级生命周期** | 一个研究任务一个子目录，完成后归档或删除 |
| **单向数据流** | 从 vault 读取材料 → 在 playground 工作 → 只有结论回写到 vault（通过 `/note` 双提议） |
| **不存在于模板仓库** | `.playground/` 是实例级目录，不从 ThinkFlywheel 模板仓库复制 |

## 生命周期

```
┌─────────────────────────────────────────────────────┐
│ 1. CREATE                                            │
│    用户说"开始研究 X"                                  │
│    → 创建 .playground/active/{session-name}/         │
│    → 从 vault 搜索相关知识 → 写入 context.md           │
├─────────────────────────────────────────────────────┤
│ 2. WORK                                              │
│    所有分析和推理在 playground 内进行                   │
│    → 脚本放 working/                                 │
│    → 草稿分析放 working/                             │
│    → 临时数据放 working/                             │
│    → 不修改 vault（除非用户主动触发 /note 或 /task）    │
├─────────────────────────────────────────────────────┤
│ 3. CONCLUDE                                          │
│    结论成形 → 写入 conclusions.md                     │
│    → 用户审核                                         │
│    → 核心洞察通过 /note 双提议回写到 vault             │
│    → 相关任务通过 /task 创建                          │
├─────────────────────────────────────────────────────┤
│ 4. ARCHIVE                                            │
│    会话完成 → 移动到 .playground/archived/            │
│    → 保留 N 天（推荐 30 天）后手动删除                 │
│    → 或用户确认后直接删除                              │
└─────────────────────────────────────────────────────┘
```

## context.md 格式

每次创建研究会话时，AI 自动生成 `context.md`，包含从 vault 拉取的相关材料**引用**（不是复制）：

```markdown
---
session: q3-product-direction
created: 2026-06-09
status: active
---

# Context: Q3 产品方向研究

## 活跃任务
- [[Q2 OKR 复盘报告]] — 涉及产品方向讨论
- [[用户反馈整理]] — 包含 Q1-Q2 用户需求数据

## 相关知识卡片
- [[产品-market-fit 判断框架]] (type/concept) — 评估框架
- [[过早扩展的教训]] (type/insight) — 历史教训
- [[竞争对手分析 2026Q1]] (type/reading) — 市场数据

## 历史决策
- [[DEC-2026-003: Q2 重点投入 A 功能还是 B 平台]]
- [[DEC-2026-001: 选 React 还是 Vue]]

## 可用流程
- [[产品方向评估流程]] (type/flow) — 如有匹配流程

## 已加载插件
- first-principles (方法论)
```

**关键原则**：context.md 存的是 **wikilink 引用**，不是全文复制。引用的卡片内容通过 `obsidian read` 按需获取。这样 playground 不会产生 vault 内容的冗余副本。

## 与现有目录的分工

| 目录 | 存什么 | 不存什么 |
|------|--------|---------|
| `.playground/` | 中间推理、临时脚本、未定论分析 | 正式知识卡片、最终结论 |
| `Draft/` | 一句话原始念头（未加工捕获） | 展开的分析、脚本、数据 |
| `.planning/` | planning-with-files 的阶段追踪 | 研究分析产物本身 |
| `Sources/inbox/` | 未处理的原始材料 | 已处理的分析 |
| `Cards/` | 正式知识卡片（双提议确认后） | 中间态草稿 |

**Draft vs Playground**：Draft 是"哦我有个想法"的一行字。Playground 是"让我花 3 小时把这个想法拆开来验证"的工作空间。Draft 可能会被 triage 为 Playground 会话的起点，但二者不重叠。

**`.planning/` vs Playground**：`.planning/` 追踪**执行进度**（Phase 1 done, Phase 2 in progress）。Playground 存放**分析产物**（数据、脚本、推理草稿）。一个研究任务可能同时使用两者：`.planning/` 管"做到哪了"，`.playground/` 管"做出来了什么中间结果"。

## 清理策略

```
推荐：研究会话归档后保留 30 天，之后手动删除
激进：结论回写到 vault 后立即删除整个会话目录
保守：永久保留在 archived/（为溯源链保留推理过程）
```

默认建议**保留 30 天**。给"这个结论后来看对不对"一个复查窗口。30 天后 `/health` 可以提醒清理过期 playground 会话。

## 常见问题

**Q: 为什么不用 Obsidian 的一个普通文件夹？**
因为 playground 内容不是正式知识。它会出现在搜索结果中，降低信噪比。隐藏目录保证它不会污染 vault 的知识检索。

**Q: 如果我在 playground 里写了个有用的脚本怎么办？**
脚本不是知识卡片，不需要进 vault。放在 playground 的 archived 里随时可找回，或者移到 vault 外的专用脚本目录。

**Q: 会不会积累很多 playground 会话？**
`/health full` 可以加一项检查：扫描 `.playground/active/` 下 N 天未修改的会话并提醒清理。这是远期优化，先用手动管理。
