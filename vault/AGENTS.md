---
title: ThinkFlywheel Agent Rules
version: 1.0
tags:
  - type/schema
updated: 2026-05-22
---

# AGENTS.md — AI Agent 操作规则

> 本文件定义 AI Agent（Claude Code）在此 vault 中的行为边界。
> Agent 每次会话启动时自动读取 SCHEMA.md + 本文件。
>
> 核心原则: **AI 做广度，人做深度。AI 扫描、提议、格式化；人判断、决定、创造。**

---

## 1. 五条铁律（FATAL — 违反即失败）

### 铁律 1: 知识写入必须双提议
创建或修改 `type/atomic`、`type/concept`、`type/insight` 卡片时，必须先向用户提议，获得确认后才能写入。**绝不在未经确认的情况下创建知识卡片。**
- 例外: `type/reading`、`type/moc`、`type/review` 可由 AI 自主创建
- 例外: `type/task` 和 `type/project` 由 /task 和 /project 命令触发时直接写入

### 铁律 2: 绝不删除卡片，只归档
任何情况下不删除 vault 中的文件。完成任务/项目时标记 `status: archived`，知识卡片过时时标记 `status: superseded`。**数据不丢失，状态可回溯。**

### 铁律 3: 绝不重组文件结构
不移动用户手动放置的文件，不重命名用户创建的目录。MOC 和 index 通过 wikilink 组织，不依赖物理位置。

### 铁律 4: 溯源链不可断
- `Cards/reading/` 必须 `source` 回链 Sources 文件
- `Cards/atomics/` 必须 `source` 回链其来源的 reading、insight 或 task
- 闭环每一张知识卡片都能追溯源头

### 铁律 5: SCHEMA 变更走审批
修改 SCHEMA.md 或 AGENTS.md 前，必须:
1. 说明变更内容和理由
2. 展示 before/after diff
3. 获得用户确认后才能执行

---

## 2. 分层自主权

| 级别 | 操作范围 | 示例 |
|------|---------|------|
| **AI 自主** | 无需确认，直接执行 | 更新 index.md、追加 log.md、更新 MOC、生成 daily briefing、生成 health report、移动 Sources(已处理)、更新 task 状态/下一步行动、更新 project 进度脉搏 |
| **AI 提议+人确认** | 生成提议，用户确认后写入 | 创建 atomic/concept/insight 卡片、添加 wikilink、/retro 提取洞察、修改 SCHEMA.md |
| **仅人操作** | AI 不主动触发 | 设定任务优先级、定义项目目标、做决策、删除文件 |

---

## 3. 标准操作流程

### 3.1 会话启动
每次对话开始时:
1. 读取 SCHEMA.md 了解 vault 结构
2. 读取 index.md 了解内容全貌
3. 读取 log.md 最后 5 条了解最近操作
4. 检查 `Daily/` 是否有今天的简报

### 3.2 写入前检查（知识类卡片）
在提议创建知识卡片前:
1. 搜索 vault 中是否已有类似卡片（去重）
2. 检查是否存在矛盾信息（标记冲突）
3. 准备 wikilink 提议（链接到已有相关卡片）

### 3.3 任务操作
- 创建任务时，先查询 vault 中相关知识自动填充"原始材料堆"
- 更新任务状态时，同步更新 frontmatter 的 `updated` 字段
- 任务归档时，提醒用户做 /retro

### 3.4 索引维护
- `index.md`: 每次创建/修改卡片后更新
- `log.md`: 每次操作后追加一行 `## [YYYY-MM-DD] {operation} | {target}`
- MOC: 检测到新卡片时自动添加到对应 domain 的 MOC

### 3.5 源材料处理
- 新文件出现在 `Sources/inbox/` 时，提醒用户可用 /ingest
- /ingest 完成后，将源文件移至 `Sources/processed/`

---

## 4. 写作规范

### 卡片内容
- 标题用 `#` 一级标题，内容简洁
- 原子卡片: 单一概念，300 字以内，自包含（脱离上下文也能理解）
- 概念卡片: 定义 + 要点 + 示例 + 相关卡片链接
- 洞察卡片: 触发情境 + 教训/模式 + 反模式（如果适用）+ 适用范围
- 任务笔记: 必须包含 4 要素（最终目标、原始材料堆、下一步行动、问题与吐槽）

### Frontmatter
- 所有卡片必须有完整的四维标签（type + domain + status + mastery）
- `updated` 字段在每次修改时更新为当前日期
- `related_tasks` 和 `related_cards` 用 wikilink 格式: `[[Task Name]]`

### 语言
- 与用户对话的语言保持一致
- 卡片内容用中文（用户母语）
- 文件名、标签、目录名用英文（CLI 兼容）

---

## 5. 技能调用指南

AI 应根据用户意图自动识别并执行对应技能:

| 用户意图 | 对应技能 | AI 行为 |
|---------|---------|--------|
| "新任务/创建任务/做X" | `/task` | 按 4 要素模板创建任务笔记 |
| "今天/早上/晨报" | `/briefing` | 扫描活跃任务+到期复习+项目健康→输出简报 |
| "目标/项目/规划" | `/project` | 创建项目章程，查询历史类似项目 |
| "处理/读一下/分析这篇" | `/ingest` | 读取来源→摘要→提取→双提议 |
| "做笔记/记下来/整理" | `/note` | 从对话中提取知识→双提议 |
| "查询/搜索/找" | `/query` | 读 index→搜索→综合回答 |
| "复习/今天学什么" | `/review` | 调用 fsrs_engine.py 取到期卡片→交互式复习 |
| "完成/做完了/复盘" | `/retro` | 分析问题和吐槽→提取洞察→归档→更新项目 |
| "体检/检查/健康" | `/health` | 跨层扫描→生成健康报告 |
| "决策/选择/决定" | `/decide` | 查询历史类似决策→结构化决策记录 |

---

## 6. 边界情况处理

### 信息不足
- 创建任务时如果目标不明确: 提问澄清，不猜测
- 提议知识卡片时如果概念模糊: 先标记 `status: draft`，注明不确定的部分

### 冲突检测
- 新知识卡片与已有卡片矛盾时: 标记冲突，在两张卡片中互链，记录发现日期
- 不同来源有不同结论时: 在概念卡片中记录不同观点，不强行统一

### 规模控制
- 单个 MOC 超过 30 个链接时: 提议拆分为子 MOC
- atomic 卡片超过 200 张时: 建议审视哪些该合并或归档
- Daily 文件保留最近 14 天，超过的 AI 建议清理（人确认）

### 离线时
- 所有技能在 Claude Code 对话中可直接执行
- FSRS 引擎通过 Python CLI 独立运行
