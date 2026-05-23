---
name: project
description: 管理多任务目标（简化 PMO）。创建项目章程、里程碑跟踪、进度脉搏、风险汇总。将 agent-pmo 的 15 个技能浓缩为 1 个个人用技能。当用户说"project"、"goal"、"目标"、"项目"、"规划"、"新项目"时触发。
invocation: user
arguments:
  - name: title
    description: 项目/目标名称
    required: true
  - name: domain
    description: 生活领域，默认 work
    required: false
---

# /project Command

管理多任务目标。将 agent-pmo 的 15 个企业级技能（/prospect → /bid → /presales → /initiate → /plan → /contract → /meeting → /change → /acceptance → /payment → /close）浓缩为 1 个个人用技能。

## 核心理念

agent-pmo 的核心设计值得保留——状态机、里程碑聚合、风险汇总——但企业流程（售前、投标、合同、验收、回款）对于个人工作生活完全不需要。我们保留骨头，去皮的肉。

## Behavior

### Step 1: 创建项目章程

在 `Projects/active/{Project Name}.md` 创建项目笔记：

```markdown
---
type: project
domain: {domain}
status: active
created: YYYY-MM-DD
updated: YYYY-MM-DD
related_tasks: []
related_cards: []
---

# {Project Name}

## Goal Statement
{一句话: 成功的定义}

## Motivation
{为什么这件事现在重要}

## Key Milestones
- [ ] M1: {milestone} (target: YYYY-MM-DD)
- [ ] M2: {milestone} (target: YYYY-MM-DD)
- [ ] M3: {milestone} (target: YYYY-MM-DD)

## Linked Tasks
{AI 后续自动从 Tasks/ 中收集链接}

## Risk Log
{从关联任务的"问题与吐槽"中汇总}

## Progress Pulse
{AI 每周自动更新}
**Last updated**: YYYY-MM-DD
**Status**: on-track
```

### Step 2: 查询历史上下文

在创建项目时，自动搜索 vault 积累的经验：

1. 搜索 `Tasks/archived/` 中 domain 相同的历史任务——有什么教训？
2. 搜索 `Cards/insights/` 中匹配的教训卡片——有什么模式要注意？
3. 搜索 `Decisions/` 中相关的决策——之前类似的决策结果如何？
4. 填充到项目笔记的初始风险评估中

### Step 3: 关联任务（双向链接）

项目创建后，当用户用 `/task` 创建与此项目相关的任务时：

1. 用户在任务描述中提及项目名，或 task domain 与项目 domain 匹配 → AI 自动提议关联
2. 关联建立后，任务 frontmatter 添加 `related_tasks: [[Project Name]]`
3. 项目笔记的 "Linked Tasks" 节自动更新

### Step 4: 月度复盘触发（AI 自主）

每月（月初或用户首次打开 /briefing 时检测），AI 检查项目是否需要月度复盘：

1. 检查项目 `updated` 日期是否跨月
2. 如果跨月且本月尚未生成月报，提示用户：
   - 汇总关联任务的本月完成情况和"问题与吐槽"
   - 建议 "这个项目上个月完成了 {n} 个任务，有 {m} 条新的问题记录。要做月度复盘吗？"
3. 如果用户同意，自动触发 `/retro` 流程（以 project 复盘模式）

### Step 5: 进度脉搏（AI 自主，每周触发）

每周或用户说"项目进度"/"project status"时：

1. 扫描所有关联任务的 status：
   - `done` → 已完成
   - `doing` → 活跃
   - `waiting` → 阻塞中 ⚠️
   - `todo` → 未开始
2. 检查里程碑日期是否逾期
3. 计算进度脉搏：
   - **on-track 🟢**: 任务按计划推进，里程碑无逾期
   - **at-risk ⚠️**: 有阻塞任务，或里程碑可能逾期
   - **stalled 🔴**: 14 天以上无关联任务活动
4. 更新项目 frontmatter 的 Progress Pulse

### Step 5: 里程碑-Checkpoint

当用户完成一个里程碑时：

1. 标记 milestone 为 [x]
2. 扫描关联任务的"问题与吐槽"，汇总为该里程碑的 mini-retro
3. 检查: 基于目前已完成的里程碑，最终目标需要调整吗？
4. 如果有调整 → 记录到 "Risk Log"

### Step 6: 项目完成

当所有里程碑完成或用户说"项目完成"/"project done"：

1. 标记 `status: completed`
2. 生成项目终期复盘（调用 /retro 流程）
3. 将所有关联任务的课程提取为 insight 卡片
4. 移动到 `Projects/archived/`
5. 更新 `index.md`

---

## 与 agent-pmo 的对比

| agent-pmo 技能 | ThinkFlywheel 处理 |
|---------------|-------------------|
| /prospect, /bid | 删除——企业销售流程，个人不需要 |
| /presales | 删除——售前方案，个人不需要 |
| /initiate | 合并到 /project Step 1 |
| /plan | 合并到 /project 的 Milestones |
| /contract | 删除——企业合同管理 |
| /meeting | 删除——太轻量，/task 可覆盖 |
| /change | 合并到 /project 的 Risk Log |
| /acceptance, /payment | 删除——企业验收回款 |
| /close | 合并到 /project Step 6 |
| /monitor | 合并到 /project Step 4 (Progress Pulse) |
| /work-item | 合并到 /task（/task 本身就是 work-item） |
