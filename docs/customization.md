# 定制指南

> ThinkFlywheel 被设计为可修改的。SCHEMA.md 定义数据模型, AGENTS.md 定义 AI 行为。两者分离是故意的——改数据模型动 SCHEMA, 改行为动 AGENTS。
>
> **重要原则**：先用默认配置至少 2 周。你需要知道默认系统"什么感觉", 才知道该改什么。

---

## 1. 修改卡片模板

模板文件在 `vault/Templates/` 下, 每个卡片类型一个 `.md` 文件。

### 示例：给任务模板加一个"预估时间"字段

1. 编辑 `vault/Templates/task.md`, 在 frontmatter 中加一行：
   ```yaml
   estimated_hours: null
   ```
   在模板正文中加一节：
   ```markdown
   ## 预估时间
   {hours} 小时
   ```

2. 更新 `vault/SCHEMA.md` 的 §5 通用 Frontmatter 规范, 在字段表中加入 `estimated_hours`。

3. 告诉 Claude：`我已更新 task 模板, 请更新 SCHEMA.md 文档记录新字段, 并更新 AGENTS.md 让你知道在创建任务时提示填写预估时间。`

### 示例：添加新卡片类型（如 type/recipe）

1. 创建 `vault/Templates/recipe.md`（frontmatter + 内容模板）
2. 更新 SCHEMA.md：在卡片类型表中加一行, 定义 status 取值, 分配写入通道
3. 如果新类型需要新领域, 创建对应 MOC（如 `MOC-Cooking.md`）
4. 决定哪个技能负责创建它（扩展已有技能或创建新技能——见下文"添加新技能"）
5. 更新 AGENTS.md 的写入规则

---

## 2. 调整 FSRS-6 参数

参数在 `vault/.obsidian/scripts/fsrs_engine.py` 的 `DEFAULT_W` 列表中（约第 30 行）。

### 常见调整

**想降低复习频率（记得好, 不需要那么多复习）**：
```python
DEFAULT_TARGET_RETENTION = 0.85  # 从 0.9 降到 0.85
```

**想提高复习频率（忘得快, 需要更多复习）**：
```python
DEFAULT_TARGET_RETENTION = 0.95  # 从 0.9 升到 0.95
```

**想拉长最大间隔（卡片可以隔更久才复习）**：
```python
DEFAULT_MAX_INTERVAL = 730  # 从 365 天改为 730 天
```

**Good 评级后间隔太短**：
增大 w[2]（`S₀(Good)` 初始稳定性）：
```python
3.5000,   # w2: S₀(Good) — 从 2.3065 调大
```

**警告**：FSRS-6 的 21 个参数深度耦合。一次只改一个, 用 2 周, 看 `/health full` 的 SR 数据（保留率、平均间隔）再决定下一步。不要"调参癖"。

---

## 3. 添加新技能

以添加 `/journal`（日记）为例：

### Step 1: 创建技能定义文件

```bash
mkdir -p vault/.claude/skills/journal
```

创建 `vault/.claude/skills/journal/SKILL.md`, 仿照已有技能文件（如 `/task` 的 SKILL.md）的格式：

```markdown
---
name: journal
description: 每日日记。记录当天关键事件、情绪状态、收获和反思。
invocation: user
arguments:
  - name: date
    description: 日记日期, 默认今天
    required: false
---

# /journal Command

## Behavior

### Step 1: 询问今日关键事件
...
```

### Step 2: 注册路由

在 `vault/CLAUDE.md` 的技能路由节加一行：
```markdown
- 日记 ("日记"/"journal") → 读取 `.claude/skills/journal/SKILL.md`
```

### Step 3: 更新 AGENTS.md

在 AGENTS.md §5 技能调用指南的表中加入：
```markdown
| "日记/今天发生了什么" | `/journal` | 按模板创建日记条目 |
```

### Step 4: （可选）创建模板

`vault/Templates/journal.md` — 如果日记有固定结构。

### Step 5: （可选）更新 SCHEMA.md

如果日记是新卡片类型, 在 SCHEMA.md 中定义 type、status、写入通道。

### 最小可行技能

至少要：frontmatter（name + description + 触发词）+ 一段 Behavior 描述。3 步就能用。

---

## 4. 自定义 /briefing 输出

简报结构定义在 `vault/.claude/skills/briefing/SKILL.md` 的 Step 6 中。

### 常见定制

**添加"本周目标进度"板块**：
在 Step 6 的模板中, "项目健康"后面加：
```markdown
## 🎯 本周目标进度
{从 Projects/active/ 读取 progress pulse 汇总}
```

**移除"历史预警"板块**（如果你觉得初期数据量不够, 干扰阅读）：
删除或注释掉简报模板中的"历史预警"部分。

**加天气/日历**：
在 Behavior 的 Step 1 之前加一个 Step 0：获取外部数据。需要 Claude Code 有对应工具的权限。

**修改后**, 重启 Claude Code 或开新对话使技能文件变更生效。

---

## 5. 修改领域标签

默认 7 个领域：work / life / learning / health / finance / relationship / tech。

### 添加新领域（如 creative）

1. SCHEMA.md §4 的 domain 表中加一行
2. 创建对应 MOC 模板：`vault/MOCs/MOC-Creative.md`
3. 各模板的默认 domain 可选择性更新

### 移除领域

不要移除——标记为 deprecated 但保留已有卡片。铁律 2：不删除, 只归档。

---

## 6. Claude Code 行为调优

`vault/AGENTS.md` §2 分层自主权控制 AI 的胆量。

### 让 AI 更自主

把某些操作从"AI 提议+人确认"移到"AI 自主"。例如：
- 让 AI 自主创建 insight 卡片（谨慎——知识卡片不经确认会有噪音）

### 让 AI 更保守

把某些操作移到"仅人操作"。例如：
- 不想 AI 自动更新 MOC（希望自己控制索引结构）

### 改索引维护频率

AGENTS.md §3.4 写的是"每次创建/修改卡片后更新"。如果你觉得太频繁：
```
每天结束时批量更新 index.md 和 MOC, 而不是每次操作后立即更新
```

---

## 7. 集成外部工具

### Obsidian 插件

- **Dataview**（强烈推荐）：查询 frontmatter 数据生成动态表格和列表
- **Templater**：比 Obsidian 原生模板更强大, 支持日期计算、文件创建等
- **Obsidian Web Clipper**：浏览器插件, 一键剪藏网页到 Sources/inbox/

### 搜索引擎

Karpathy 推荐 [qmd](https://github.com/tobi/qmd)：本地 markdown 搜索引擎, BM25 + 向量搜索 + LLM 重排。vault 超过几百张卡片后可能有用。

### Git Hooks

在 `.git/hooks/pre-commit` 中加验证：
```bash
#!/bin/bash
# 检查所有 .md 文件 frontmatter 完整性
python .obsidian/scripts/validate_frontmatter.py vault/
```

---

## 8. 分享你的定制

ThinkFlywheel 是 MIT 许可。如果你做了有用的技能、模板或工作流改进, 欢迎 PR 贡献回来。
