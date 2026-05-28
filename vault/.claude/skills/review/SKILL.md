---
name: review
description: FSRS-6 间隔重复。调用 fsrs_engine.py 获取到期卡片，交互式复习。将知识从 AI 上下文窗口推入人脑长期记忆。当用户说"复习"、"review"、"今天复习什么"、"spaced repetition"时触发。
invocation: user
arguments:
  - name: limit
    description: 每次复习卡片数上限，默认 10
    required: false
  - name: mode
    description: 复习模式 'recall'（自由回忆，默认）或 'qa'（问答对模式）
    required: false
---

# /review Command

FSRS-6 间隔重复。调用 `fsrs_engine.py`（knowledge-mgmt 同款引擎），交互式复习 `Cards/atomics/` 中的原子卡片。

## 核心理念

knowledge-mgmt 作者的核心洞察：**"一份编译精美但从未被记住的 wiki 是浪费。"**

`/review` 是 ThinkFlywheel 的"记忆层"——将知识从 vault 推入你的大脑。这与 `/note` 形成闭环：/note 存入 vault，/review 存入大脑。

## Behavior

### Step 1: 扫描新卡片

每次调用时，先检查 `Cards/atomics/` 中是否有新卡片未注册到 FSRS：

```bash
python .obsidian/scripts/fsrs_engine.py .obsidian/review_state.json bulk_register
```

读取 stdin 中的新卡片 JSON（按需生成）来注册。更实用的方式：

1. 扫描 `Cards/atomics/` 中所有 `type/atomic` 卡片
2. 与 `review_state.json` 中的 `known_card_ids` 对比
3. 未注册的卡片: 用 `register` 命令注册，根据 `mastery` frontmatter 设置初始参数

### Step 2: 获取到期卡片

```bash
python .obsidian/scripts/fsrs_engine.py .obsidian/review_state.json due --limit {limit}
```

根据返回的 JSON 列表，按顺序逐一复习。

### Step 3: 交互式复习

对每张到期卡片，向用户展示：

#### Recall 模式（默认）
```
🧠 复习 [{n}/{total}]

📋 卡片: {title}
❓ 你还记得这张卡片的核心内容吗？

{等待用户回忆}

▶ 展开查看答案
{卡片完整内容}

你回忆得怎么样？
[1] 完全忘了 (Again)
[2] 记得一点 (Hard)
[3] 基本记得 (Good)
[4] 非常熟悉 (Easy)
```

#### QA 模式（适用于有 Q&A 格式的原子卡片）
```
🧠 复习 [{n}/{total}]

❓ Q: {卡片中的问题}

{等待用户回答}

▶ 展开查看答案
A: {卡片中的答案}

你的答案准确度？
[1] 完全错误 (Again)
[2] 部分正确 (Hard)
[3] 基本正确 (Good)
[4] 完全正确 (Easy)
```

### Step 4: 提交评级

用户选择后，调用 FSRS 引擎记录：

```bash
python .obsidian/scripts/fsrs_engine.py .obsidian/review_state.json record --id {card_id} --rating {1-4}
```

引擎根据 FSRS-6 算法重新计算卡片的 stability 和 difficulty，调度下次复习。

### Step 5: 批量复习直到完成

重复 Step 3-4，直到今日到期卡片全部复习完或用户喊停。

### Step 6: 展示统计 + 更新

复习结束后展示：

```
📊 今日复习完成
- 复习: {n} 张
- Again: {a} | Hard: {h} | Good: {g} | Easy: {e}
- 下次到期: {next_due_date} ({remaining} 张)

💪 连续复习天数: {streak}
📈 总体掌握率: {avg_retention * 100}%
```

更新操作（AI 自主）：
- 更新 `index.md` 中对应卡片的 mastery 状态（如果有变化）
- 追加 `log.md`: `## [YYYY-MM-DD] review | {n} cards reviewed | retention: {rate}`

---

## FSRS 引擎 CLI 速查

```bash
# 获取到期卡片（混合新卡和复习卡）
python fsrs_engine.py <state> due --limit 20 --new_limit 10

# 注册单张卡片
python fsrs_engine.py <state> register --id "card-id" --title "Title" --content "Content"

# 记录复习结果
python fsrs_engine.py <state> record --id "card-id" --rating 3

# 查看统计
python fsrs_engine.py <state> stats
```

---

## 与其他技能的集成

| 集成点 | 说明 |
|--------|------|
| `/briefing` | 每日简报自动检测到期复习卡片，交叉引用活跃任务 |
| `/retro` | 复盘提取的 insight 和 atomic 卡片自动注册进 FSRS |
| `/note` | 双提议确认的新 atomic 卡片自动注册进 FSRS |
| `/health` | 健康检查报告 SR 积压和掌握率 |

---

## 特殊情况

- **0 张到期卡片**: "今天没有到期复习。最近一张在 {date}。要提前复习吗？"
- **新卡片积压过多** (> 30 张未开始): 建议用户做一次"批量初始化复习"，快速过一遍
- **连续 3 天未复习**: 在 /briefing 中提醒，/health 中标记
- **某张卡片连续 Again 5 次以上**: 建议改进卡片内容（可能写得太难或太模糊）

## 🚫 不要做什么（反模式）

| # | 反模式 | 为什么不要做 | 正确做法 |
|---|--------|-------------|---------|
| 1 | **替用户自评卡片掌握程度** | 记忆是主观的——AI 无法判断用户是否真正记住 | 等待用户给出 Again/Hard/Good/Easy 评级，不跳过、不预设 |
| 2 | **复习时跳过用户评级直接提交** | FSRS 参数依赖准确的自评数据 | 必须等用户明确选择 [1]-[4] 后才提交 |
| 3 | **对非 atomic 卡片执行复习** | FSRS 引擎只处理 type/atomic 卡片 | Step 1 扫描时只注册 type/atomic + Cards/atomics/ 下的卡片 |
| 4 | **在 /briefing 中替用户复习** | /briefing 是视图不是执行工具 | /briefing 只显示到期卡片列表，不提交评级 |
| 5 | **将 review_state.json 纳入 git** | 二进制状态文件不应版本控制，且可能含个人记忆数据 | 确保 review_state.json 在 .gitignore 中 |
