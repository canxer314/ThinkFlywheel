---
name: retro
description: 任务/项目复盘 + 自动知识提取。分析"问题与吐槽"→提取洞察→双提议→归档→更新项目。这是 ThinkFlywheel 的关键桥接技能——将行动转化为知识。当用户说"复盘"、"retro"、"完成"、"done"、"做完了"、"close"时触发。
invocation: user
arguments:
  - name: target
    description: 要复盘的任务名称（可选，不提供则从最近更新的 done 状态任务中选择）
    required: false
  - name: type
    description: 复盘类型 'task'（默认）或 'project'
    required: false
---

# /retro Command

任务/项目复盘的**关键桥接技能**——将行动转化为知识。这是 knowledge-mgmt 和 agent-pmo 都不具备的核心能力。

## 核心理念

防弹笔记法最深刻的洞察：**"问题与吐槽"不是抱怨垃圾桶，是知识原材料**。你在任务中遇到的每一个摩擦、每一次困惑、每一个意外——这些都是比书本更有价值的经验数据。`/retro` 就是把这些原材料提炼为知识卡片的工厂。

knowledge-mgmt 有 `/note` 但没有"任务完成"触发点。agent-pmo 有 `/close` 但没有知识提取。`/retro` 填补了这个空白。

## Behavior

### Step 1: 确认复盘对象

- 如果用户指定了任务名: 直接定位
- 如果用户说"done"/"完成"/"做完了": 查找最近更新的 `status: done` 或 `status: doing` 任务
- 如果用户说"project retro": 定位项目笔记
- 如果有多个候选: 让用户选择

### Step 2: 读取原始材料

读取任务笔记中的：

1. **最终目标**: 最初设定的成功标准是什么？
2. **问题与吐槽**: 这是核心数据——每条都按日期记录了实际遇到的摩擦
3. **下一步行动**: 哪些完成了？哪些卡住了？哪些根本没开始？为什么？
4. **原始材料堆**: 哪些参考资料真正有用？哪些是噪音？

### Step 3: 模式分析

AI 分析"问题与吐槽"中的内容，寻找模式：

**问题分类**：
- **沟通问题**: "等反馈等了3天" → 模式: 依赖方响应慢
- **范围问题**: "需求又变了" → 模式: 项目范围不稳定
- **知识问题**: "不知道怎么用这个 API" → 模式: 技能缺口
- **流程问题**: "审批走了两遍" → 模式: 流程冗余
- **工具问题**: "XX 工具又崩了" → 模式: 工具不可靠
- **认知问题**: "一开始想复杂了" → 模式: 过度设计倾向

**跨任务模式检测**：
搜索 vault 中 domain 相同的历史任务，检查"问题与吐槽"中是否有相似的模式。如果有，标记为**"重复出现的模式"**——这是最有价值的 insight。

### Step 4: 生成复盘摘要

在 `Reviews/retro/{Task Name} — Retro.md` 创建复盘笔记：

```markdown
---
type: review
domain: {domain}
status: final
created: YYYY-MM-DD
updated: YYYY-MM-DD
source: [[Tasks/active/{Task Name}]]
related_tasks: []
related_cards: []
---

# {Task Name} — 任务复盘

## 原始目标
{回顾最初设定的最终目标}

## 实际结果
{实际发生了什么}

## 差距分析
| 预期 | 实际 | 差距原因 |
|------|------|---------|
| ... | ... | ... |

## 关键教训
{从"问题与吐槽"中提炼的模式}

## 重复出现的模式 ⚠️
{如果有跨任务重复的问题模式}

## 提取的知识卡片
{/retro 自动提取的 insight + atomic 卡片列表}

## 下一步
**Start Doing**: {应该开始做的事}
**Stop Doing**: {应该停止做的事}
**Continue Doing**: {应该继续做的事}
```

### Step 5: 提取知识卡片（自动触发 /note 双提议）

复盘中的关键教训自动触发知识提取：

向用户展示提议:

```
📋 从这次任务中可以提取以下知识卡片：

🔗 已有卡片可关联:
- [[Card A]] — 这次任务验证了它的核心观点
- [[Card B]] — 这次任务提供了一个反例

🆕 建议新建卡片:
| # | 类型 | 标题 | 来源 |
|---|------|------|------|
| 1 | insight | "X类任务的范围管理陷阱" | 问题与吐槽 Day 3, Day 5 |
| 2 | atomic | "Y工具的正确使用方式" | 问题与吐槽 Day 2 |
| 3 | insight | "避免Z类型过度设计" | 差异分析 |

接受哪些？（全部/1,2/1 3/skip）
```

### Step 6: 归档和更新（AI 自主）

1. 用户确认知识提取后:
   - 创建被接受的 insight + atomic 卡片
   - 新 atomic 卡片自动注册到 FSRS (`fsrs_engine.py register`)
   - 新卡片 frontmatter 中 `source` 回链到复盘笔记
2. 任务笔记: `status` 改为 `archived`，移至 `Tasks/archived/`
3. 更新关联项目:
   - 从项目的 "Linked Tasks" 中移除或标记为已完成
   - 将教训添加到项目的 "Risk Log"
   - 重新计算项目 Progress Pulse
4. 更新索引:
   - `index.md`: 从 "Active Tasks" 移到（可选保留在底部"最近完成"）
   - `log.md`: `## [YYYY-MM-DD] retro | {Task Name} | {n} insights extracted`
5. 向用户报告: "🎉 {Task Name} 已完成归档。提取了 {n} 张知识卡片，其中 {m} 张已进入 FSRS 复习队列。"

---

## 特殊情况

- **任务没有"问题与吐槽"**: 复盘更有价值——"为什么这次这么顺利？" 提取可复制的成功模式
- **任务中途放弃**: 复盘更有价值——"放弃是对的决策还是逃避？" 提取决策判断标准
- **任务关联了活跃项目**: 检查是否影响项目里程碑
- **同一个项目中多个任务暴露出相同模式**: 升级为项目级风险
