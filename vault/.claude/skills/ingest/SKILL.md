---
name: ingest
description: 处理原始材料到 LLM Wiki。读取来源→生成结构化摘要→标记与现有知识的矛盾→触发 /note 双提议提取。当用户说"ingest"、"process"、"read this"、"处理"、"阅读"、"读一下"、"分析这篇"时触发。
invocation: user
arguments:
  - name: source
    description: 源文件路径（Sources/inbox/中的文件）或 URL
    required: true
  - name: mode
    description: 处理深度 'quick'（快速摘要，5分钟）或 'deep'（深度分析，含交叉引用）。默认 'quick'
    required: false
---

# /ingest Command

处理原始材料，整合进 LLM Wiki。融合了 Karpathy 的编译模式（读一次，整合进 wiki）和 knowledge-mgmt 的 /read 流程。

## 核心理念

> 文章的关键知识整合进已有体系：新概念→原子卡片，矛盾→标记，关联→活跃任务。

## Behavior

### Step 1: 读取来源

根据 source 类型：

- **本地文件** (`Sources/inbox/xxx.md`): 直接读取文件内容
- **URL**: 使用 WebFetch 获取内容并转为 markdown
- **PDF/图片**: 先读取文本，再查看图片获取额外上下文

读取后先向用户展示内容概览（标题、作者、日期、主题），确认处理方向。

### Step 2: 分析内容（quick vs deep）

#### Quick 模式
1. 提取核心论点（1-3 句话）
2. 提取关键论据和数据
3. 一句话说明：这对我为什么重要？

#### Deep 模式
在 quick 基础上增加：
1. 与 vault 中已有知识的交叉引用——搜索相关卡片
2. 矛盾标记：新信息是否与已有卡片冲突？
3. 适用边界：这个知识在什么条件下成立？什么条件下不成立？
4. 行动关联：这个知识与哪些活跃任务相关？
5. **【MCP 补充】跨会话未记录讨论**：`memory_smart_search` 用核心主题词搜索 → 找历史上讨论过但未写成 card 的相关内容。MCP 发现与 vault 交叉引用结果互补——vault 覆盖已结构化的知识，MCP 覆盖"提过但没写下来"的碎片。仅在 deep 模式执行，不阻塞主流程。

### Step 3: 矛盾检测（deep 模式，双通道）

搜索 vault 中 domain 相关的卡片 + MCP 跨会话历史：

**Vault 通道**：
1. 关键词搜索 Cards/ 中标题和内容
2. 如果发现立场不同或结论相反的已有卡片，生成矛盾报告：
   ```
   ⚠️ 发现与已有知识的冲突:
   - 本文声称: [新信息的主张]
   - 已有卡片 [[X]] 认为: [已有卡片的主张]
   - 建议: 创建对比卡片 / 标注其中一方为 superseded / 保留两种观点
   ```

**【MCP 通道】跨会话矛盾召回**：
- `memory_smart_search` 用矛盾关键词搜索 → 找历史上是否讨论过类似的矛盾但未解决
- 如果 MCP 发现有人提过类似质疑但 vault 没有记录 → 标注 "历史讨论中曾有人质疑过类似结论，但未形成 card"
- 两者互补：vault 覆盖结构化矛盾，MCP 覆盖"提过一嘴但没深究"的讨论碎片

### Step 4: 生成阅读摘要卡片

无论 quick 还是 deep，在 `Cards/reading/` 创建阅读摘要卡片：

```markdown
---
type: reading
domain: {推断的领域}
status: processed
created: YYYY-MM-DD
updated: YYYY-MM-DD
source: [[Sources/processed/{filename}]]
related_tasks: [{关联的活跃任务}]
related_cards: [{交叉引用到的已有卡片}]
---

# {标题} — 阅读摘要

## 来源
- 标题: {title}
- 作者: {author}
- 日期: {date}
- 链接: {url}

## 核心论点
{1-3 句话}

## 关键论据
{论据列表}

## 与我何干
{为什么对我重要}

## 与已有知识的关联
{deep 模式: 交叉引用结果}

## 矛盾标记
{deep 模式: 冲突发现}

## 提取的原子卡片
{/note 提取的原子卡片列表 — 由下一步双提议填充}
```

### Step 5: 触发 /note 双提议

摘要卡片创建后，**自动进入 /note 的 Step 3 流程**：

向用户展示：
1. 对话中哪些概念已有对应卡片（wikilink 提议）
2. 哪些知识点值得创建为新的原子卡片（atomic 提议）

用户确认后写入。

### Step 6: 清理和更新（AI 自主）

1. 如果源文件在 `Sources/inbox/`，移至 `Sources/processed/`
2. 更新 `index.md` 的 "Reading Summaries" 节
3. 更新对应 domain 的 MOC
4. 追加 `log.md`: `## [YYYY-MM-DD] ingest | {title} | {mode}`
5. 如果发现与活跃任务的关联，更新任务笔记的"原始材料堆"

---

## 与其他技能的关系

> /ingest → /note 双提议 → /review FSRS复习。活跃任务通过 related_tasks 自动关联。

---

## 特殊情况

- **来源内容很少** (< 500 字): 直接做 quick 摘要，不触发 /note 双提议（不值得提取原子卡片）
- **来源是纯数据/表格**: 不做论点分析，转换为结构化摘要
- **来源与已有卡片高度重复**: 不创建新摘要，更新已有卡片的 `related_cards` 和 `source`，告知用户
- **来源质量低**: 如实告知用户，建议不处理或做简单标记

## 失败处理

| 场景 | 处理 |
|------|------|
| **URL 无法访问（WebFetch 失败/超时）** | 告知用户"无法访问该 URL"，建议手动复制内容到 Sources/inbox/ 后重试 |
| **本地文件不存在** | 告知用户文件路径无效，检查 Sources/inbox/ 目录 |
| **PDF/图片内容无法识别** | 提取文件名和元信息，标注"⚠️ 无法解析内容，建议手动转换后重新摄入" |
| **Sources/inbox/ 目录不存在** | 创建目录；如创建失败，告知用户"vault 目录结构异常，建议运行 /health" |
| **deep 模式交叉引用搜索返回空** | 标注"未找到与已有知识的直接关联"，不编造关联 |
| **/note 双提议被用户全部拒绝** | 保持阅读摘要卡片，不删除；card 的"提取的原子卡片"节留空 |
| **AgentMemory MCP 不可用** | 跳过 MCP 通道，仅用 vault 做交叉引用和矛盾检测；在摘要中标注"ℹ️ MCP 不可用，未记录讨论可能遗漏" |

## 🚫 不要做什么（反模式）

| # | 反模式 | 为什么不要做 | 正确做法 |
|---|--------|-------------|---------|
| 1 | **未读来源就直接创建摘要** | 摘要必须基于原文事实，不能臆造 | Step 1 必须先读取/获取完整来源内容 |
| 2 | **deep 模式跳过 contradiction check** | 矛盾检测是 deep 模式的核心价值——错过矛盾就是错过学习机会 | Step 3 必须搜索 domain 相关卡片进行比较 |
| 3 | **对低质量来源强行提取知识** | 垃圾进垃圾出——低质量来源不值得进入知识库 | 如实告知用户质量评估，建议跳过 |
| 4 | **跳过 /note 双提议直接写 atomic 卡片** | 违反铁律 1——知识写入必须经过用户确认 | Step 5 必须走 /note 双提议流程 |
| 5 | **deep 模式下只用 vault 做交叉引用** | vault 只覆盖已写入的卡片——很多讨论碎片从未被提取为卡片 | deep 模式 Step 2 和 Step 3 应双通道（vault + MCP），MCP 不可用时才降级 |
