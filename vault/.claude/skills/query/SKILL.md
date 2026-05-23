---
name: query
description: 搜索 vault 知识。读 index.md → 关键词搜索 → 读取命中卡片 → 综合回答带 wikilink 引用。好的回答可保存为新卡片。当用户说"查询"、"query"、"搜索"、"找"、"find"、"search"时触发。
invocation: user
arguments:
  - name: question
    description: 要查询的问题或关键词
    required: true
  - name: domain
    description: 限定搜索领域 work|life|learning|health|finance|relationship|tech
    required: false
---

# /query Command

Vault 知识检索。不是 grep 后丢给你一堆文件名——而是综合多张卡片的内容，给出有 wikilink 引用的结构化回答。

## 核心理念

Karpathy 的 LLM Wiki 洞察：**好的回答可以存回 wiki 成为新页面**。一次查询不只是消费知识，也可能产生知识。

## Behavior

### Step 1: 读取索引导航

首先读取 `index.md` 了解 vault 内容全貌。如果 `domain` 参数指定了领域，同时读取对应 MOC（如 `MOCs/MOC-Work.md`）。

### Step 2: 多策略搜索

按以下优先级搜索：

1. **精确匹配**: 搜索 `Cards/` 中标题包含关键词的卡片（最高相关性）
2. **标签过滤**: 搜索 frontmatter 中 `domain/` 匹配 + 内容包含关键词
3. **内容搜索**: 全文搜索 vault 中包含关键词的段落
4. **关联扩展**: 对于搜索到的卡片，检查其 `related_cards` 和 `related_tasks`，一路追踪 2 跳深度

### Step 3: 读取和综合

读取搜索命中的卡片（最多 10 张），综合为结构化回答：

```markdown
## 查询: {question}

### 直接相关
| 卡片 | 摘要 |
|------|------|
| [[Card A]] | 一句话描述... |
| [[Card B]] | 一句话描述... |

### 综合回答
{基于以上卡片的综合叙述，带 [[wikilinks]] 引用}

### 相关任务
{如果有活跃任务与此查询相关}

### 关联探索
{2 跳范围内的相关卡片——这些可能也相关}
```

### Step 4: 判断是否值得保存

如果查询结果满足以下任一条件，询问用户是否保存为卡片：

- 综合了 3 张以上卡片的新分析
- 发现了跨卡片的新连接或模式
- 用户明确表示"这个有用，记下来"

如果用户同意，触发 `/note` 流程写入。这是 Karpathy 说的：**"A comparison you asked for, an analysis, a connection you discovered — these are valuable and shouldn't disappear into chat history."**

### Step 5: 更新日志

- 追加 `log.md`: `## [YYYY-MM-DD] query | {question} | {hit_count} cards found`

---

## 查询类型和策略

| 查询类型 | 示例 | 搜索策略 |
|---------|------|---------|
| 概念查询 | "什么是SBI反馈框架" | 精确标题匹配 → 内容搜索 |
| 关联查询 | "X和Y有什么关系" | 搜索两张卡片 + wikilink 路径追踪 |
| 历史查询 | "我上次处理类似问题是怎么做的" | 搜索 Tasks/archived/ + Decisions/ |
| 教训查询 | "这种类型的任务有什么坑" | 搜索 type/insight + domain 匹配 |
| 领域全览 | "我对金融知道些什么" | 读对应 MOC → 列出所有卡片 |
| 决策上下文 | "我之前做这个决定时考虑了哪些因素" | 搜索 Decisions/ + 关联任务 |
