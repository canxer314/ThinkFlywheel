---
title: ThinkFlywheel Schema
version: 1.1
tags:
  - type/schema
updated: 2026-05-22
---

# SCHEMA.md — ThinkFlywheel Vault Schema

> ThinkFlywheel (知行飞轮) 是个人工作与生活的复利引擎。
> 它融合了防弹笔记法(Esor)、Atomic Notes + Spaced Repetition、
> AI 驱动项目管理、Karpathy LLM Wiki 四种方法论。
>
> 本文件是系统宪法。Agent 操作 vault 前自动读取。

---

## 1. 四层架构

| 层 | 目录 | 所有权 | 说明 |
|----|------|--------|------|
| L1 Memory | `Cards/atomics/` + `.obsidian/scripts/fsrs_engine.py` | AI 执行，人验证 | FSRS-6 间隔重复，确保知识进入大脑 |
| L2 Knowledge | `Cards/` + `Sources/` | AI 编译维护，人验证 | LLM Wiki 编译层：概念、洞察、阅读摘要 |
| L3 Task | `Tasks/` + `Projects/` + `Flows/` + `Decisions/` | 人主导，AI 辅助 | 防弹笔记法三层任务管理(暂时性+专案+永久型) + 决策 |
| L4 Governance | `MOCs/` + `Reviews/` + `Daily/` | AI 自主扫描 + 人决策 | 跨系统健康检查 + 索引 + 简报 |

**关键哲学**: 这不是上下堆叠，是飞轮。完成任务→产生知识→进入记忆→新任务浮现→更好执行。复利循环。

---

## 2. 目录结构规范

```
Vault/
├── SCHEMA.md                 # 本文件 — 系统宪法
├── AGENTS.md                 # Agent 操作规则
├── CLAUDE.md                 # Claude Code 桥接配置
├── index.md                  # 内容索引（AI 维护）
├── log.md                    # 时间线日志（AI 追加）
│
├── Tasks/                    # 暂时性任务笔记 — 系统枢纽
│   ├── active/               # 进行中：每任务一个笔记
│   ├── waiting/              # 阻塞 / 等待外部输入
│   └── archived/             # 已完成（知识提取源）
│
├── Flows/                    # 🆕 永久型任务笔记(SOP/流程库)
│   ├── work/                 # 工作类流程
│   ├── life/                 # 生活类流程
│   └── learning/             # 学习类流程
│
├── Cards/                    # 知识卡片 — LLM Wiki
│   ├── atomics/              # type/atomic：最小可复用单元 → 喂 SR
│   ├── concepts/             # type/concept：定义、模型、框架
│   ├── health-reports/       # /health 生成的健康报告
│   ├── insights/             # type/insight：教训、模式、反模式
│   └── reading/              # type/reading：已处理来源摘要
│
├── Projects/                 # 多任务目标（个人 PMO）
│   ├── active/               # 活跃目标区域
│   └── archived/             # 已完成 / 放弃的目标
│
├── Decisions/                # 决策日志 DEC-YYYY-NNN.md
├── MOCs/                     # 内容地图（AI 维护索引）
├── Reviews/                  # 定期回顾
│   ├── weekly/               # 周报
│   ├── monthly/              # 月报
│   └── retro/                # 每任务复盘（/retro 自动生成）
├── Daily/                    # 每日简报（自动生成，临时性）
├── Sources/                  # 原始材料（不可变）
│   ├── inbox/                # 新入，未处理
│   └── processed/            # /ingest 后移至此
├── Templates/                # 各类型卡片模板
└── Attachments/              # 图片、PDF、文件
```

---

## 3. 卡片类型定义（10 种）

| type 标签 | 存储位置 | 说明 | 模板 |
|-----------|----------|------|------|
| `type/task` | `Tasks/active/` | 防弹 4 要素任务笔记（暂时性） | `Templates/task.md` |
| `type/project` | `Projects/active/` | 多任务目标画布（专案鸟瞰地图） | `Templates/project.md` |
| `type/flow` | `Flows/{domain}/` | 永久型任务笔记(SOP/流程/检查清单) — 反复执行、永不关闭 | `Templates/flow.md` |
| `type/atomic` | `Cards/atomics/` | SR 知识单元 — 最小可复用卡片 | `Templates/atomic.md` |
| `type/concept` | `Cards/concepts/` | 解释性知识：定义、模型、框架 | `Templates/concept.md` |
| `type/insight` | `Cards/insights/` | 教训、模式、反模式 | `Templates/insight.md` |
| `type/reading` | `Cards/reading/` | 已处理来源的结构化摘要 | `Templates/reading.md` |
| `type/decision` | `Decisions/` | 结构化决策记录 DEC-YYYY-NNN | `Templates/decision.md` |
| `type/moc` | `MOCs/` | 按领域聚合的内容地图索引 | `Templates/moc.md` |
| `type/review` | `Reviews/` | 周期/任务复盘 | `Templates/review.md` |

### 写入通道

| 卡片类型 | 写入通道 | 确认机制 |
|----------|---------|---------|
| `type/task` | `/task` 直接写入 | 无需双提议（行动容器，非知识） |
| `type/project` | `/project` 直接写入 | 无需双提议（目标定义，人主导） |
| `type/flow` | `/flow` 直接写入 + `/retro` 触发迭代 | 无需双提议（流程模板，非知识） |
| `type/atomic` | `/note` 或 `/retro` 双提议 | **必须人工确认** |
| `type/concept` | `/note` 或 `/ingest` 双提议 | **必须人工确认** |
| `type/insight` | `/note` 或 `/retro` 双提议 | **必须人工确认** |
| `type/reading` | `/ingest` 自动生成 | AI 自主（来源处理的自然产物） |
| `type/decision` | `/decide` 交互式创建 | **必须人工确认** |
| `type/moc` | AI 自主维护 | AI 自主（纯索引，无新知识） |
| `type/review` | `/retro` 自动生成 | AI 自主（复盘的结构化记录） |

---

## 4. 四维标签体系

每张卡片携带以下 frontmatter 标签：

```
type/{card-type}        # 卡片类型（必填）
domain/{life-area}      # 生活领域（必填）
status/{flow-state}     # 流转状态（必填）
mastery/{level}         # 掌握程度（atomic 卡片必填，其他可选）
```

### domain 取值

| 值 | 含义 |
|----|------|
| `work` | 职业工作 |
| `life` | 日常生活 |
| `learning` | 学习成长 |
| `health` | 身心健康 |
| `finance` | 财务管理 |
| `relationship` | 人际关系 |
| `tech` | 技术积累 |

### status 取值（按卡片类型）

| 卡片类型 | 可用 status |
|----------|------------|
| task | `todo` `doing` `waiting` `done` `archived` |
| project | `active` `paused` `completed` `abandoned` |
| flow | `active` `deprecated` |
| atomic | `new` `learning` `reviewing` `mastered` |
| concept/insight | `draft` `stable` `superseded` |
| decision | `pending` `made` `reviewed` `overturned` |
| moc | `active` `stale` |
| reading | `processed` `extracted` |
| review | `draft` `final` |

### mastery 取值（atomic 卡片专用）

| 值 | 含义 | FSRS 影响 |
|----|------|----------|
| `0-new` | 初次接触 | 初始难度 = D₀ |
| `1-familiar` | 有点熟悉 | 初始稳定性 x1.3 |
| `2-comfortable` | 基本掌握 | 初始稳定性 x1.5 |
| `3-mastered` | 完全掌握 | 初始稳定性 x2.0，降低复习频率 |

---

## 5. 通用 Frontmatter 规范

所有卡片必须包含：

```yaml
---
type: {card-type}
domain: {life-area}
status: {flow-state}
created: YYYY-MM-DD
updated: YYYY-MM-DD
mastery: {level or null}
source: [[source-card]] or null
related_tasks: [task-1, task-2] or []
related_cards: [card-1, card-2] or []
---
```

### 字段说明

| 字段 | 必填 | 说明 |
|------|------|------|
| `type` | 是 | 卡片类型标签 |
| `domain` | 是 | 生活领域标签 |
| `status` | 是 | 流转状态标签 |
| `created` | 是 | 创建日期 |
| `updated` | 是 | 最后更新日期（AI 自动维护） |
| `mastery` | atomic 必填 | 掌握程度 |
| `source` | reading/atomic 必填 | 溯源链接：reading 回链 Sources，atomic 回链 reading 或 task |
| `related_tasks` | 可选 | 关联任务列表 |
| `related_cards` | 可选 | 关联卡片列表 |

### 溯源链（继承自 knowledge-mgmt）

```
Sources/inbox → /ingest → Cards/reading/ (type/reading)
                                    ↓ /note 提取
                             Cards/atomics/ (type/atomic)

Tasks/active/ → /retro → Cards/insights/ (type/insight)
                              ↓ /note 提取
                         Cards/atomics/ (type/atomic)

Tasks/active/ → /retro → 回写 Flows/{domain}/ (type/flow) — 流程级经验
                              → 更新 Projects/active/ (type/project) — 专案级洞察
```

---

## 6. 权限矩阵

| 操作 | AI 自主 | AI 提议+人确认 | 仅人操作 |
|------|--------|---------------|---------|
| 创建 task 笔记 | | | ✓ (/task 命令触发) |
| 更新 task 状态/下一步行动 | ✓ | | |
| 创建 project 笔记 | | | ✓ (/project 命令触发) |
| 更新 project 进度脉搏 | ✓ | | |
| 创建 flow 笔记 | | | ✓ (/flow 命令触发) |
| 更新 flow 内容/迭代日志 | ✓ | | |
| 创建/更新 atomic 卡片 | | ✓ | |
| 创建/更新 concept 卡片 | | ✓ | |
| 创建/更新 insight 卡片 | | ✓ | |
| 创建 reading 摘要 | ✓ | | |
| 创建 decision 记录 | | ✓ | |
| 更新 MOC 索引 | ✓ | | |
| 更新 index.md | ✓ | | |
| 追加 log.md | ✓ | | |
| 生成 daily briefing | ✓ | | |
| 生成 review/retro | ✓ | | |
| 生成 health report | ✓ | | |
| 移动 Sources (inbox→processed) | ✓ | | |
| 修改 SCHEMA.md | | ✓ | |
| 修改 AGENTS.md | | ✓ | |
| 删除任何卡片 | | ✓ | |
| 修改任务优先级 | | | ✓ |
| 设定项目目标 | | | ✓ |
| 做决策 | | | ✓ |

---

## 7. 命名规范

### 任务笔记
```
Tasks/active/{A-F-O-T Title}.md
```
- A-F-O-T 命名公式: 动词 + 对谁 + 成果 + 时地
- 例: "撰写给A客户的Q2销售分析报告(含3图表+1结论页),周三午前邮件发出"
- 完成归档后保留原名

### 永久型任务笔记(Flow)
```
Flows/{domain}/{Flow Name}.md
```
- 名词性命名 + "流程"/"SOP"/"清单"/"手册"
- 例: "周报撰写流程.md"、"客户谈判 SOP.md"、"新成员入职检查清单.md"

### 知识卡片
```
Cards/atomics/{Concept Name}.md
Cards/concepts/{Concept Name}.md
Cards/insights/{Pattern Description}.md
Cards/reading/{Source Title} — {Author} {YYYY-MM-DD}.md
```

### 项目文件
```
Projects/active/{Project Name}.md
```

### 决策记录
```
Decisions/DEC-{YYYY}-{NNN}.md
```
- NNN 为年度内序号，AI 自动分配

### 每日简报
```
Daily/YYYY-MM-DD.md
```

### 复盘记录
```
Reviews/retro/{Task Name} — Retro.md
Reviews/weekly/YYYY-W{NN}.md
Reviews/monthly/YYYY-MM.md
```

---

## 8. MOC 索引规范

每个领域至少维护一张 MOC：

| MOC 文件 | domain 覆盖 |
|----------|------------|
| `MOC-Work.md` | `domain/work` |
| `MOC-Life.md` | `domain/life` |
| `MOC-Learning.md` | `domain/learning` |
| `MOC-Health.md` | `domain/health` |
| `MOC-Finance.md` | `domain/finance` |
| `MOC-Reading.md` | 所有 `type/reading` 卡片 |

MOC 由 AI 自主维护，内容为 `[[wikilink]]` 列表 + 一句话摘要，按 mastery 或 status 分组。

---

## 9. FSRS-6 间隔重复

- 引擎路径: `.obsidian/scripts/fsrs_engine.py`
- 状态文件: `.obsidian/review_state.json`
- 目标卡片: 所有 `Cards/atomics/` 下 `type/atomic` 标签的卡片
- 复习触发: 用户调用 `/review` 或 `/briefing` 自动检测到期卡片
- 评级: Again(1) / Hard(2) / Good(3) / Easy(4)

---

## 10. 技能总览

| 组 | 技能 | 功能 |
|----|------|------|
| 执行 | `/task` | 创建和管理暂时性任务笔记 |
| 执行 | `/project` | 管理专案目标笔记（鸟瞰地图） |
| 执行 | `/flow` | 创建和管理永久型任务笔记（SOP/流程库） |
| 执行 | `/briefing` | 生成每日上下文简报 |
| 知识 | `/ingest` | 处理原始材料到 wiki |
| 知识 | `/note` | 双提议提取原子卡片和 wikilinks |
| 知识 | `/query` | 搜索 vault 知识 |
| 记忆 | `/review` | FSRS-6 间隔重复 |
| 记忆 | `/retro` | 任务复盘 + 三向经验回流 |
| 治理 | `/health` | 跨系统健康检查 |
| 治理 | `/decide` | 结构化决策记录 |
