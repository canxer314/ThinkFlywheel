---
name: health
description: 跨系统健康检查。不只是 wiki 链接是否断裂——而是检查知识-行动断层、任务僵死、领域平衡、SR 积压、矛盾检测。当用户说"health"、"check"、"体检"、"lint"、"检查"、"系统健康"时触发。
invocation: user
arguments:
  - name: scope
    description: 检查范围 'quick'（快速健康检查，默认）或 'full'（全系统深度检查）
    required: false
---

# /health Command

跨系统健康检查。这是 ThinkFlywheel 与 knowledge-mgmt `/lint` 的核心区别——`/lint` 只检查 wiki 内部一致性，`/health` 检查**各层之间的一致性**。

## 核心理念

一个系统可以用三种方式失败：
1. **内部失败**: wiki 内部链接断裂、卡片过时（knowledge-mgmt /lint 的领域）
2. **层间失败**: 知识库里有但脑子没记住、任务执行了但知识没提取（ThinkFlywheel 特有）
3. **整体失败**: 某个生活领域完全被忽视、系统偏向某类活动而忽略其他（ThinkFlywheel 特有）

`/health` 检查全部三种。

---

## Quick 模式（默认，每次约 30 秒扫描）

### 检查 1: 链接健康
- 搜索 vault 中所有 `[[wikilinks]]`
- 标记指向不存在文件或不存在标题的链接
- 严重级别: broken link → ERROR

### 检查 2: 任务僵死
- 扫描 `Tasks/active/` 中 `updated` 超过 14 天的任务
- 标注为 "僵死任务"
- 严重级别: > 14 天 → WARNING，> 30 天 → ERROR

### 检查 3: 复习积压
- 调用 `fsrs_engine.py stats` 检查 overdue 卡片数量
- 严重级别: > 10 张 overdue → WARNING，> 30 张 → ERROR

### 检查 4: 项目异常
- 扫描 `Projects/active/` 中 status 与关联任务状态矛盾的项目
- 例如: Progress Pulse 说 "on-track" 但 0 个关联任务 activity
- 严重级别: INFO

### 检查 5: 孤儿卡片
- 扫描 `Cards/` 中所有卡片，检查每张卡片的入站 wikilink 数量
- 入站链接 = 0 的卡片标记为"孤儿卡片"
- 排除: MOC 卡片、index.md、Daily 文件（这些天然入站链接少）
- 严重级别: > 5 张 orphan → WARNING，> 20 张 → ERROR

### 检查 6: 空 MOC 区间
- 扫描 `MOCs/` 中所有 MOC 文件
- 检查每个 MOC 中标记的分组（如"核心概念"、"学习中"等）是否有实际 wikilink 内容
- 空 section 标记为 INFO（建议填充或删除空 section）

---

## Full 模式（深度检查，建议每周一次）

### 检查 6: 同 Quick 模式

### 检查 7: 知识-行动断层（ThinkFlywheel 独有）
扫描 `Cards/atomics/` 中 `mastery/3-mastered` 的卡片：
- 哪些从未被任何任务的 `related_cards` 引用过？
- **含义**: 你"记住了"的知识从未在行动中使用过
- 严重级别: > 5 张 → WARNING

扫描 `Tasks/archived/` 中最近 30 天完成但**没有关联 /retro** 的任务：
- **含义**: 完成了任务但没有提取知识
- 严重级别: > 3 个 → WARNING

### 检查 8: 领域平衡
统计 vault 中所有卡片的 `domain` 分布：

```
📊 领域分布:
work         ████████████████████ 65%
learning     ██████ 20%
health       ██ 5%
finance      █ 3%
life         █ 2%
relationship ░ 0%
tech         ██ 5%
```

- 如果有 domain 占比为 0%（被完全忽视），标记为 WARNING
- 如果某个 domain 占比 > 50%，标记为 INFO（提醒但不一定是问题）

### 检查 9: 矛盾检测
- 搜索内容中立场相反或结论矛盾的卡片对
- 如果找到，检查是否已有 comparison 卡片记录此矛盾
- 严重级别: 未标记的矛盾 → INFO

### 检查 10: 溯源链完整性
- 检查 `Cards/atomics/` 中是否有 `source` 为 null 的卡片
- 检查 `Cards/reading/` 中是否有 `source` 为 null 的卡片
- 严重级别: 缺少溯源 → WARNING

---

## 健康报告输出

生成报告到 `Cards/health-reports/health-YYYY-MM-DD.md`：

```markdown
---
type: health-report
updated: YYYY-MM-DD
---

# ThinkFlywheel 健康报告 — YYYY-MM-DD

## 总分: {score}/100

| 维度 | 得分 | 状态 |
|------|------|------|
| 链接健康 | {}/20 | 🟢/⚠️/🔴 |
| 结构完整性 | {}/5 | 🟢/⚠️/🔴 |
| 任务活力 | {}/20 | 🟢/⚠️/🔴 |
| 知识-行动一致性 | {}/20 | 🟢/⚠️/🔴 |
| 记忆保持 | {}/15 | 🟢/⚠️/🔴 |
| 领域平衡 | {}/10 | 🟢/⚠️/🔴 |
| 溯源完整性 | {}/10 | 🟢/⚠️/🔴 |

## 发现
### 🔴 严重
- {具体问题 + 建议修复}

### ⚠️ 警告
- {具体问题 + 建议修复}

### ℹ️ 信息
- {观察}

## 趋势
{与上次报告的对比}
```

### 评分规则

| 维度 | 满分 | 扣分规则 |
|------|------|---------|
| 链接健康 | 20 | 每个 broken link -5，每个 orphan card -2 |
| 结构完整性 | 5 | 每个空 MOC section -1 |
| 任务活力 | 20 | 每个僵死任务(>14天) -5，每个(>30天) -10 |
| 知识-行动一致性 | 20 | 每个 mastered 未使用 -3，每个未复盘任务 -5 |
| 记忆保持 | 15 | overdue < 10: 满分，10-30: -5，> 30: -10 |
| 领域平衡 | 10 | 每个 0% 领域 -5 |
| 溯源完整性 | 10 | 每个无 source 卡片 -2 |

### 健康等级

| 得分 | 等级 |
|------|------|
| 90-100 | 🟢 优秀 — 系统运转良好 |
| 70-89 | 🟡 良好 — 有改进空间 |
| 50-69 | ⚠️ 需要关注 — 有系统性问题 |
| < 50 | 🔴 需要修复 — 系统部件可能失效 |

---

## AI 行为准则

- `/health` **只诊断，不自动修复**（除非问题有唯一确定解，如补充缺失的 frontmatter 字段）
- 修复建议必须经过用户确认
- 健康报告只保存最近 4 周，旧的自动清理
- 如果发现 broken link，**不要擅自删除链接**——标记并让用户决定是修复链接还是删除引用

---

## 与 knowledge-mgmt /lint 的区别

| | knowledge-mgmt /lint | ThinkFlywheel /health |
|--|---------------------|----------------------|
| 检查范围 | wiki 内部一致性（链接、标签、格式） | 跨层一致性（链接 + 知识-行动 + 领域 + 记忆） |
| 检查项数 | 16 项（5 类） | 8 项（含子项约 20 个检查点） |
| 生命周期 | 只检查知识层 | 检查任务层 + 知识层 + 记忆层 + 治理层 |
| 评分 | 无总分，逐项报告 | 有综合评分 + 维度分 + 趋势对比 |
| 修复权限 | AI 不自动修复 | AI 不自动修复（同） |
