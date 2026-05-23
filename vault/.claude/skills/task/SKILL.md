---
name: task
description: 创建和管理防弹笔记法任务笔记。每个任务一个核心笔记，包含最终目标、原始材料堆、下一步行动、问题与吐槽四要素。当用户说"new task"、"create task"、"start task"、"新任务"、"task"、"创建任务"、"新建任务"、"要做X"、"任务"时触发。
invocation: user
arguments:
  - name: title
    description: 任务名称，简洁可操作
    required: true
  - name: domain
    description: 生活领域 work|life|learning|health|finance|relationship|tech，默认 work
    required: false
---

# /task Command

创建和管理防弹笔记法（Esor's Bulletproof Thinking）任务笔记。这是 ThinkFlywheel 系统枢纽 —— 所有行动始于任务笔记，所有知识最终追溯到任务笔记。

## 核心理念

任务笔记不是为了记录而记录，而是为了**更高效地完成任务和实现目标**。它像"防弹衣"一样保护注意力和执行力。

## Behavior

### Step 1: 接收任务描述

从用户输入中提取：
- **任务标题**: 简洁、可操作（如 "Q2 OKR 制定"、"修复登录超时 Bug"、"健身房恢复训练"）
- **domain**: 推断或使用用户指定的领域
- **due**: 如果用户提到截止日期，填入 frontmatter

### Step 2: 查询 Vault 相关知识

在创建任务笔记**之前**，自动扫描 vault 填充"原始材料堆"：

1. 搜索 `Cards/` 中 domain 匹配的卡片
2. 搜索 `Projects/` 中可能相关的活跃项目
3. 搜索 `Tasks/archived/` 中标题或内容相似的历史任务
4. 搜索 `Decisions/` 中可能影响此任务的决策
5. 如果发现相关内容，提取关键信息作为原始材料

### Step 3: 分析和规划

基于查询结果，AI 内部构建任务上下文：

- **这是全新领域还是有经验可循？** 如果 vault 中有相关卡片，在原始材料堆中列出
- **这个任务属于哪个项目？** 如果发现关联的活跃项目，标记 `related_tasks`
- **第一步应该做什么？** 基于最终目标，提出 2-3 个具体的下一步行动
- **有什么历史教训？** 如果历史类似任务有问题与吐槽，在材料堆中警告

### Step 4: 创建任务笔记

在 `Tasks/active/{Task Title}.md` 创建笔记，使用 `Templates/task.md` 模板，AI 预填：

```markdown
---
type: task
domain: {domain}
status: todo
created: YYYY-MM-DD
updated: YYYY-MM-DD
due: YYYY-MM-DD or null
mastery: null
source: null
related_tasks: [[project-name]] or []
related_cards: [[card-1]], [[card-2]] or []
---

# {Task Title}

## 最终目标
> AI 根据任务描述草拟的一句话成功标准。用户修改确认。

{AI 草拟的目标描述}

## 原始材料堆
> AI 从 vault 中查询到的相关知识和参考资料

{AI 从 vault 中查询到的相关内容列表，带 [[wikilinks]]}

## 下一步行动
> 接下来要做的 2-3 个具体动作

- [ ] {AI 提议的第一步}
- [ ] {AI 提议的第二步}
- [ ] {AI 提议的第三步（可选）}

## 问题与吐槽
> 执行过程中遇到的摩擦、困惑、意外。这是知识提取的原材料
```

### Step 5: 更新索引

任务创建后，AI 自主执行：
1. 更新 `index.md` 的 "Active Tasks" 节
2. 追加 `log.md`: `## [YYYY-MM-DD] create task | {Task Title}`
3. 如果关联了项目，更新项目笔记的 "Linked Tasks" 节
4. 如果关联了领域 MOC，更新 MOC

### Step 6: 输出确认

向用户展示创建的任务笔记摘要：
- 任务标题和领域
- 最终目标（请用户确认或修改）
- 下一步行动列表
- Vault 中查找到的相关材料数量

**重要**: 任务笔记直接写入，不需要双提议确认。任务不是知识，是行动容器。质量门控在 `/retro` 时——任务完成提取洞察时才需要确认。

---

## 更新已有任务

当用户说"更新任务"/"task update"/"任务进度"时：

1. 读取已有任务笔记
2. 根据用户描述更新"下一步行动"的勾选状态
3. 如果用户描述了新问题/摩擦，追加到"问题与吐槽"（带日期标记）
4. 更新 frontmatter 的 `updated` 字段
5. 如果任务关联了项目，检查是否需要更新项目进度脉搏

---

## 任务状态流转

```
todo → doing → waiting → done → archived
  ↑                ↓
  └──── 恢复 ──────┘
```

- `todo`: 已创建，尚未开始
- `doing`: 正在执行（用户说"开始做X"时切换）
- `waiting`: 阻塞中，等待外部输入（记录阻塞原因到"问题与吐槽"）
- `done`: 已完成，等待复盘
- `archived`: 已复盘（/retro 后自动切换）
