# 卡片类型与命名

## 11 种卡片

| type 标签 | 存储位置 | 说明 | 模板 |
|-----------|----------|------|------|
| `type/inbox` | `Inbox/` | 闪念收件箱 — 未分类的原始念头，等待 triage | `Templates/inbox.md` |
| `type/task` | `Tasks/active/` | 暂时性任务笔记 — 防弹 4 要素 | `Templates/task.md` |
| `type/project` | `Projects/active/` | 专案目标笔记 — 鸟瞰地图 | `Templates/project.md` |
| `type/flow` | `Flows/{domain}/` | 永久型任务笔记 — SOP/流程/检查清单，永不关闭 | `Templates/flow.md` |
| `type/atomic` | `Cards/atomics/` | SR 知识单元 — 最小可复用卡片 | `Templates/atomic.md` |
| `type/concept` | `Cards/concepts/` | 解释性知识：定义、模型、框架 | `Templates/concept.md` |
| `type/insight` | `Cards/insights/` | 教训、模式、反模式 | `Templates/insight.md` |
| `type/reading` | `Cards/reading/` | 已处理来源的结构化摘要 | `Templates/reading.md` |
| `type/decision` | `Decisions/` | 结构化决策记录 DEC-YYYY-NNN | `Templates/decision.md` |
| `type/moc` | `MOCs/` | 按领域聚合的内容地图索引 | `Templates/moc.md` |
| `type/review` | `Reviews/` | 周期/任务复盘 | `Templates/review.md` |

## 写入通道

| 卡片类型 | 写入通道 | 确认机制 |
|----------|---------|---------|
| `type/inbox` | 用户对话中自然触发，AI 直接写入 | 无需双提议（原始念头，非知识） |
| `type/task` | `/task` 直接写入 | 无需双提议（行动容器，非知识） |
| `type/project` | `/project` 直接写入 | 无需双提议（目标定义，人主导） |
| `type/flow` | `/flow` 直接写入 + `/retro` 触发迭代 | 无需双提议（流程模板，非知识） |
| `type/atomic` | `/note` 或 `/retro` 双提议 | **必须人工确认** |
| `type/concept` | `/note` 或 `/ingest` 双提议 | **必须人工确认** |
| `type/insight` | `/note` 或 `/retro` 双提议 | **必须人工确认** |
| `type/reading` | `/ingest` 自动生成，`/meeting` 自动生成 | AI 自主（来源处理的自然产物） |
| `type/reading` + `subtype: meeting` | `/meeting` 自动生成 | AI 自主（会议纪要，含结构化行动/决议/风险追踪） |
| `type/decision` | `/decide` 交互式创建 | **必须人工确认** |
| `type/moc` | AI 自主维护 | AI 自主（纯索引，无新知识） |
| `type/review` | `/retro` 自动生成 | AI 自主（复盘的结构化记录） |

## 命名规范

| 卡片类型 | 路径格式 |
|---------|---------|
| 闪念 | `Inbox/{YYYY-MM-DD HHmm} {一句话摘要}.md` |
| 任务 | `Tasks/active/{A-F-O-T Title}.md` |
| 流程 | `Flows/{domain}/{Flow Name}.md` — 名词性 + "流程"/"SOP"/"清单" |
| 原子 | `Cards/atomics/{Concept Name}.md` |
| 概念 | `Cards/concepts/{Concept Name}.md` |
| 洞察 | `Cards/insights/{Pattern Description}.md` |
| 阅读 | `Cards/reading/{Source Title} — {Author} {YYYY-MM-DD}.md` |
| 会议纪要 | `Cards/reading/{会议主题} — {YYYY-MM-DD}.md` |
| 项目 | `Projects/active/{Project Name}.md` |
| 决策 | `Decisions/DEC-{YYYY}-{NNN}.md`（NNN 为年度内序号，AI 自动分配） |
| 简报 | `Daily/YYYY-MM-DD.md` |
| 复盘 | `Reviews/retro/{Task Name} — Retro.md` |
| 周报 | `Reviews/weekly/YYYY-W{NN}.md` |
| 月报 | `Reviews/monthly/YYYY-MM.md` |

任务文件名简洁、可操作（如 "Q2 OKR 制定.md"、"修复登录超时 Bug.md"），完成归档后保留原名。
