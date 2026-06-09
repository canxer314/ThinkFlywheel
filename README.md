# ThinkFlywheel · 知行飞轮

> 个人认知复利引擎 —— 每次完成任务，都让未来的任务更简单。

ThinkFlywheel 是一套运行在 Obsidian + Claude Code 上的个人工作与生活管理系统。它融合了四种方法论：

| 方法论 | 解决的问题 |
|--------|-----------|
| **防弹笔记法** (Esor) | 任务不丢、执行不卡、问题不遗忘 |
| **Atomic Notes + FSRS-6** | 学过的知识能记住、能复用 |
| **LLM Wiki** (Karpathy) | AI 帮你编译、索引、交叉引用所有知识 |
| **简化 PMO** | 多任务目标的进度可视、风险可追踪 |

**核心洞见**：大多数人的任务系统、知识库、记忆系统是三个孤岛。知无法指导行，行无法沉淀知。ThinkFlywheel 把它们连成一个飞轮：完成任务 → 产生知识 → 进入记忆 → 新任务浮现 → 更好执行。复利循环。

---

## 文档导航

| 你想做什么 | 去看 |
|-----------|------|
| 从头搭起来 | [快速开始](#快速开始) → [上手指南](docs/getting-started.md) |
| 5 分钟看完整流程 | [5 分钟走一遍](#5-分钟走一遍) |
| 某个技能怎么用 | [技能参考](docs/skills.md) |
| 看真实使用案例 | [工作流示例](docs/workflow-examples.md) |
| 出问题了 | [故障排查](docs/troubleshooting.md) |
| 想改系统配置 | [定制指南](docs/customization.md) |
| 理解架构设计 | [完整架构文档（含深度分析）](docs/ThinkFlywheel%20-%20Complete%20System%20Architecture.md) |
| 搭配增强技能 | [增强模式：planning-with-files + agentmemory](docs/integrations.md) |
| 看版本更新记录 | [CHANGELOG](CHANGELOG.md) |

---

## 快速开始

### 前置条件

1. **Obsidian ≥1.12** — [下载安装](https://obsidian.md)
2. **Claude Code** — [安装 Claude Code](https://docs.anthropic.com/en/docs/claude-code)
3. **Python 3.8+** — FSRS-6 间隔重复引擎需要（纯标准库，无外部依赖）

### 安装

```bash
# 1. 克隆仓库
git clone <your-repo-url> thinkflywheel
cd thinkflywheel

# 2. 运行安装脚本（将 vault/ 复制到你的工作目录）
#    Windows:
.\install.ps1 -TargetPath "C:\Obsidian\MyVault" -InitGit

#    macOS / Linux:
./install.sh -t ~/Obsidian/MyVault --init-git

# 3. 按脚本输出的指引：打开 Obsidian → 安装 obsidian-skills → 启动 Claude Code
```

### 2 分钟试跑

```bash
# 1. 进入安装目录, 验证 CLI 可用（需 Obsidian 运行中）
cd "C:\Obsidian\MyVault"    # 替换为你的目标目录
obsidian help                # 应显示 100+ 可用命令

# 2. 启动 Claude Code
claude

# 3. Claude Code 启动后自动加载 .claude/rules/ 中的操作规则。验证：
"系统里定义了哪些卡片类型？"
# 预期: Claude 列举 10 种卡片类型

# 4. 创建第一个防弹任务笔记
/task 整理本周工作优先级
# 预期: 在 Tasks/active/ 下创建带 4 要素的笔记, AI 自动从 vault 搜索相关知识填入材料堆

# 5. 生成今日上下文简报
/briefing
# 预期: 生成 Daily/YYYY-MM-DD.md, 包含活跃任务 + 到期复习 + 项目健康

# 6. 快速系统体检
/health quick
# 预期: 多维度健康报告, 综合评分（初期有很多"警告"是正常的）
```

> 详细设置步骤和故障排除见 [上手指南](docs/getting-started.md)。

---

## 5 分钟走一遍

用一个具体任务"整理本周工作优先级"展示核心飞轮：

```
Step 1: 创建任务
> /task 整理本周工作优先级
→ Tasks/active/ 下创建带 4 要素（目标/材料/行动/吐槽）的笔记

Step 2: 执行完成后告诉 Claude
> 本周工作优先级整理完了, 下周重点是 Q2 OKR 复盘
→ 任务状态更新为 done

Step 3: 复盘, 提取知识（关键桥接！）
> /retro 整理本周工作优先级
→ AI 分析"问题与吐槽", 双提议 insight/atomic 卡片, 你选择接受

Step 4: 复习知识卡片
> /review
→ 刚接受的 atomic 卡片进入复习队列, 自评 1-4 分, FSRS-6 自动调度

Step 5: 看飞轮效果
> /briefing
→ 活跃任务 + 到期复习（交叉引用关联任务）+ 项目健康, 一页全貌
```

> 这个循环重复得越多, 系统价值越大。更多场景见 [工作流示例](docs/workflow-examples.md)。

---

## 系统架构

```
+==========================================================+
| L4: GOVERNANCE     /health  /decide  /briefing            |
| AI 扫描：断链、孤儿卡片、知识-行动断层、领域失衡           |
+==========================================================+
    |                    |                    |
    v                    v                    v
+----------------+ +----------------+ +----------------+
| L3: TASK       | | L2: KNOWLEDGE  | | L1: MEMORY     |
| 防弹笔记法      | | LLM Wiki       | | FSRS-6 间隔重复|
| /task /project | | /note /ingest  | | /review        |
| /flow /meeting | | /query         | |                |
| /retro         | |                | |                |
| "要做什么"      | | "我知道什么"    | | "我记住什么"    |
+----------------+ +----------------+ +----------------+
    |                    |                    |
    +--------------------+--------------------+
                         |
                         v
              +--------------------------+
              | L0: AGENT CONTEXT        |
              | Transparent Memory + MCP |
              | profile / constraints    |
              | agent-log / sessions     |
              | "Agent 对你的已知事实"    |
              +--------------------------+

四层通过 Markdown 文件 + YAML frontmatter + Hooks 双向流动，Git 版本控制。
```

**这不是上下堆叠，是飞轮。** 任务完成产生洞察 (/retro)，洞察进入记忆 (/review)，记忆浮现于晨报 (/briefing)，晨报指导新任务——每一圈都让下一圈更轻松。

---

## 核心工作流

```
早晨 /briefing  →  看今日任务 + 到期复习卡片 + 触发流程
   ↓
执行 /task      →  做事，/flow 提供 SOP，/meeting 记录会议
   ↓
完成 /retro     →  提取教训为原子卡片，回写 Flow 经验
   ↓
复习 /review    →  卡片进入 FSRS-6 间隔重复
   ↓
回到 /briefing  →  复习过的知识出现在新任务的晨报中
```

### 关键融合点

| 融合点 | 技能 | 发生了什么 |
|--------|------|-----------|
| **晨间融合** | `/briefing` | 活跃任务 + 到期复习卡片 + 项目健康 + 历史预警 → 一页上下文 |
| **任务创建融合** | `/task` | AI 自动搜索 vault 中相关知识填入"原始材料堆"，让你不空白起步 |
| **完成融合** | `/retro` | "问题与吐槽"中的痛点自动提取为原子卡片，痛苦变资产 |
| **阅读融合** | `/ingest` | 文章处理完后，知识点自动链接到相关活跃任务 |

---

## 12 个技能

### 每日节奏：什么时候用哪个

```
早晨刚坐下   → /briefing   每天唯一必跑
开始做一件事 → /task       新任务、新想法、别人交代的事
开了一个会议 → /meeting    记录会议纪要、行动项、决议
建立标准流程 → /flow       固化 SOP/检查清单/流程模板
读了一篇文章 → /ingest     处理成阅读摘要 + 提取知识点
对话中学到了 → /note       双提议提取, 存为卡片
做完了一件事 → /retro      复盘 + 提取知识（关键桥接）
晚上空闲     → /review     5-10 分钟复习到期卡片
需要找东西   → /query      多策略搜索 vault
做重要选择   → /decide     结构化记录 + 未来复查
周末         → /health     全面体检
```

> 详细用法见 [技能参考](docs/skills.md)。

### 执行组

| 技能 | 触发词 | 什么时候用 | 功能 |
|------|--------|-----------|------|
| `/task` | "new task" "创建任务" "要做X" | 开始任何新工作, 想到要做的事 | 创建防弹 4 要素任务笔记 |
| `/project` | "project" "goal" "目标" "新项目" | 多任务协同, 想追踪整体进度 | 里程碑 + 进度脉搏 + 风险日志 |
| `/flow` | "flow" "流程" "SOP" "常做的事" | 建立可复用的标准操作流程 | 固化 SOP/检查清单，关联 task |
| `/meeting` | "meeting" "会议" "转录" | 开完会需要记录和跟进 | 结构化会议纪要 + 行动项追踪 |
| `/briefing` | "briefing" "今天" "晨报" "早上好" | 每天第一次打开 Claude Code | 生成每日上下文简报 |

### 知识组

| 技能 | 触发词 | 什么时候用 | 功能 |
|------|--------|-----------|------|
| `/ingest` | "ingest" "read this" "处理" "读一下" | 读了好文章想留下笔记 | 处理原始材料 → 摘要 → 触发知识提取 |
| `/note` | "note" "做笔记" "存笔记" "拆卡片" | 对话中学到东西, 值得保留 | 双提议机制：wikilinks + 原子卡片 |
| `/query` | "query" "find" "搜索" "找" | 想查 vault 里记录过的知识 | 多策略搜索, 综合回答带 wikilink 引用 |

### 记忆组

| 技能 | 触发词 | 什么时候用 | 功能 |
|------|--------|-----------|------|
| `/review` | "review" "复习" "今天复习什么" | 每天一次, vault 里有卡片后 | FSRS-6 间隔重复, 评级调度 |
| `/retro` | "retro" "done" "完成" "复盘" | 任务完成或放弃时 | 复盘 + 自动知识提取（核心桥接） |

### 治理组

| 技能 | 触发词 | 什么时候用 | 功能 |
|------|--------|-----------|------|
| `/health` | "health" "check" "体检" "lint" | quick 随时, full 每周 | 跨系统健康检查, 综合评分 |
| `/decide` | "decide" "decision" "决策" "决定" | 做重要选择, 在两个选项中纠结 | 结构化决策 + FSRS 复查提醒 |

---

## 卡片类型

系统中所有内容以 10 种卡片形式存在：

| 卡片类型 | 存储位置 | 示例 |
|---------|---------|------|
| **Task** | `Tasks/active/` | "Q3 OKR 制定" |
| **Project** | `Projects/active/` | "学会 Rust" |
| **Flow** | `Flows/{domain}/` | "周报撰写流程" |
| **Atomic** | `Cards/atomics/` | "SBI 反馈模型" (进入 SR) |
| **Concept** | `Cards/concepts/` | "决策矩阵" |
| **Insight** | `Cards/insights/` | "周末部署更容易出错" |
| **Reading** | `Cards/reading/` | "某篇文章的阅读摘要" |
| **Decision** | `Decisions/` | "DEC-2026-001: 选 React 还是 Vue" |
| **MOC** | `MOCs/` | 按领域聚合的内容地图 |
| **Review** | `Reviews/` | 周报、月报、任务复盘 |

每张卡片携带 4 维标签：`type` + `domain` + `status` + `mastery`。

---

## AI 权限分级

ThinkFlywheel 采用三级自主权，避免 AI 过度操作：

| 级别 | 范围 | 示例 |
|------|------|------|
| **AI 自主** | 无需确认 | 更新索引、追加日志、生成简报、更新项目进度脉搏 |
| **AI 提议 + 人确认** | 双提议机制 | 创建原子/概念/洞察卡片、添加 wikilink |
| **仅人操作** | AI 不触发 | 设定任务优先级、定义项目目标、做决策 |

**关键原则**：AI 做广度（扫描、提议、格式化），人做深度（判断、决定、创造）。

---

## Transparent Memory — Agent 已知事实层

为了不让 AI 每次都从空白开始，ThinkFlywheel 引入了 **Transparent Memory (TM)**——Agent 在每次对话中自动携带的、关于你的最小化真相集。

### TM 的四份文件

| 文件 | 内容 | 谁维护 | 注入时机 |
|------|------|--------|---------|
| `profile.yaml` | 用户画像：角色、偏好、决策模式、当前优先事项 | 你审核，Agent 提议 | 每条消息前 |
| `constraints.yaml` | 全局约束：Agent 在任何建议中必须遵守的硬边界 | 你定义，Agent 只读 | 每条消息前 |
| `agent-log.md` | Agent 犯过的错和学到的教训，防止重复犯错 | Agent 自动写入 | 每条消息前 |
| `commitments.yaml` | Agent 未完成的承诺和待办 | Agent 自动写入，你定期清理 | 每条消息前 |

### 三级 Hook 自动化

```
会话启动  →  UserPromptSubmit Hook  →  注入 TM 四件套到 Agent 上下文
会话退出  →  Stop Hook              →  写会话骨架 + 标记 pending_review
上下文压缩 →  PreCompact Hook        →  记录压缩元数据，防止信息丢失
下次简报  →  /briefing Step 0       →  读取骨架 + MCP 召回 + 检测冲突 + 提议 TM 更新
```

### 冲突解决

当 TM 与其他信息源矛盾时，优先级：**你当场说的话 > Obsidian vault > TM > AgentMemory MCP**

### 为什么 TM 不是 Rules/Skills

三者解决问题的维度不同，不可互相替代：

| | Rules | Skills | TM |
|--|-------|--------|-----|
| **认识论地位** | 命令（"应该怎么做"） | 流程（"步骤是什么"） | 信念（"什么是真的"） |
| **生长机制** | 人编写，不写不长 | 人编写，不写不长 | Agent 观察→推断→提议，被动生长 |
| **信任模型** | 二进制：100% 正确 | 二进制：100% 正确 | 概率化：confidence ≥ 0.8 才注入 |
| **错误后果** | 灾难性（删文件） | 流程崩溃 | 软偏差（建议略偏） |
| **更新延迟** | 天到周 | 天到周 | 1 个会话 |

**Rules 不能替代 TM**：你不能把"用户偏好结构化分析"写成 rule——那不是行为指令，是关于世界的事实。Agent 用 rule 限制操作空间，用 TM 调整推理路径。

**TM 不能替代 Rules**：绝对命令（"不删文件"）必须是 rule，不能靠 Agent 推断。Rules 是你的意志，TM 是你的镜子。

---

## 增强模式：planning-with-files + agentmemory

ThinkFlywheel 的 10 个技能管理的是**人的工作和生活**。搭配以下两个 Claude Code 生态技能，覆盖范围从"人脑"扩展到"AI Agent 大脑"，形成完整的**人-AI 协作记忆栈**：

| 技能 | 解决的问题 | 记忆类型 |
|------|-----------|---------|
| **planning-with-files** | 复杂多步骤任务怎么不跑偏？AI 的执行进度放哪？ | Agent 工作内存 — phase 追踪、发现记录、3-strike 错误恢复 |
| **agentmemory** | 会话间上下文怎么不丢失？`/clear` 后怎么恢复？上次做了什么？ | Agent 长期记忆 — 会话历史、提交溯源、语义召回 |

### 四系统记忆分工

```
┌──────────────────────────────────────────────┐
│ ThinkFlywheel (人脑外挂)                      │
│ /task /project /note /retro /review          │
│ "我知道什么、我在做什么、我记住了什么"          │
│ 存储: Obsidian vault (Markdown + Git)        │
├──────────────────────────────────────────────┤
│ Transparent Memory (Agent 已知事实层)          │
│ profile.yaml / constraints.yaml / agent-log  │
│ "用户是谁、边界在哪、犯过什么错"                │
│ 存储: vault/.claude/memory/ (Git 版本控制)    │
├──────────────────────────────────────────────┤
│ planning-with-files (Agent 工作内存)          │
│ task_plan.md / findings.md / progress.md     │
│ "这一步做完了、下一步做什么、发现了什么"        │
│ 存储: .planning/ 目录                        │
├──────────────────────────────────────────────┤
│ agentmemory (Agent 长期记忆)                  │
│ session-history / memory_recall / handoff    │
│ "上次我们聊过这个、这个决定是怎么来的"          │
│ 存储: MCP plugin 持久化                       │
└──────────────────────────────────────────────┘
```

**关键协同**：

- **任务执行闭环**: ThinkFlywheel `/task` 定义"要做什么" → planning-with-files `task_plan.md` 拆成 phase 追踪"怎么做" → 完成后 `/retro` 把经验提取回 ThinkFlywheel
- **双重会话恢复**: `/clear` 后 agentmemory `handoff` 恢复对话上下文 + planning-with-files `session-catchup` 恢复执行进度——两套恢复互补
- **双向知识沉淀**: `/retro` 把**人的经验**提取为 FSRS 卡片；agentmemory `memory_save` 把 **AI 的发现**保存为长期观察 → 下次类似任务自动召回
- **代码溯源**: agentmemory `commit-context` 追溯每一行代码是哪个会话、哪个 ThinkFlywheel 任务的产物

> 详细配置和用法见 [增强模式指南](docs/integrations.md)。

---

## 目录结构

```
vault/
├── SCHEMA.md              # 系统宪法 — 类型、标签、命名规范、权限矩阵
├── AGENTS.md              # AI Agent 行为规则（跨工具兼容）
├── CLAUDE.md              # Claude Code 桥接配置
├── index.md               # 内容索引（AI 自动维护）
├── log.md                 # 时间线日志（AI 自动追加）
├── .claude/
│   ├── hooks/             # 自动化 Hook 脚本（UserPromptSubmit / Stop / PreCompact）
│   ├── skills/            # 12 个技能的 SKILL.md 定义
│   ├── memory/            # Transparent Memory — Agent 已知事实层
│   │   ├── profile.yaml       # 用户画像
│   │   ├── constraints.yaml   # 全局约束
│   │   ├── agent-log.md       # Agent 错误日志
│   │   ├── commitments.yaml   # Agent 未完成承诺
│   │   └── sessions/          # 会话摘要（Stop Hook 自动写入）
│   └── rules/             # 操作规则（自动加载至 ground truth 层）
│       ├── iron-laws.md       # 5 条铁律
│       ├── autonomy.md        # 权限矩阵
│       ├── writing.md         # 写作与标签规范
│       ├── workflows.md       # 标准操作流程
│       ├── card-types.md      # 卡片类型与命名
│       ├── structure.md       # 四层架构与目录
│       ├── obsidian-cli.md    # Obsidian CLI 强制规则
│       ├── execute-env.md     # 运行环境
│       ├── toolcalling.md     # 工具调用规则
│       └── no-post-hoc-reasoning.md  # 推理诚实性规则
├── Draft/                  # 闪念收件箱 — 未分类的原始念头
├── Tasks/                 # 防弹任务笔记
│   ├── active/            # 进行中
│   ├── waiting/           # 阻塞中
│   └── archived/          # 已完成
├── Flows/                 # 永久型任务笔记（SOP/流程库）
│   ├── work/              # 工作类流程
│   ├── life/              # 生活类流程
│   └── learning/          # 学习类流程
├── Cards/                 # 知识卡片
│   ├── atomics/           # SR 原子卡片
│   ├── concepts/          # 概念定义
│   ├── insights/          # 教训和模式
│   └── reading/           # 阅读摘要
├── Projects/              # 多任务目标
├── Decisions/             # 决策日志
├── MOCs/                  # 内容地图
├── Reviews/               # 周期回顾
├── Daily/                 # 每日简报
├── Sources/               # 原始材料
│   ├── inbox/             # 待处理
│   └── processed/         # 已处理
├── Templates/             # 卡片模板
└── .obsidian/scripts/     # FSRS-6 引擎
```

---

## 五条铁律

系统为 AI Agent 设定了 5 条不可违背的规则：

1. **知识写入必须双提议** — 创建知识卡片前必须先提议、获得确认
2. **绝不删除，只归档** — 状态标记为 `archived` 或 `superseded`，数据不丢失
3. **绝不重组文件结构** — 不移动用户手动放置的文件
4. **溯源链不可断** — 每张知识卡片必须能追溯到来源
5. **SCHEMA 变更走审批** — 修改系统宪法前必须说明理由 + 展示 diff + 获得确认

---

## 与现有系统的区别

ThinkFlywheel 不是另一个知识管理工具或任务管理器。它是**生活编译器**：

| | knowledge-mgmt | agent-pmo | ThinkFlywheel |
|--|--------------|-----------|---------------|
| 范围 | 仅知识 | 仅项目 | 行动 + 知识 + 记忆 + 治理 |
| 任务层 | 无 | 企业 PMO | 防弹笔记法 4 要素 |
| 间隔重复 | 有 | 无 | FSRS-6（联通任务层） |
| 每日整合 | 单独的 /review | 无 | /briefing 融合全部三层 |
| 完成流程 | 无 | /close 只生成摘要 | /retro 自动提取原子卡片 |
| 生活覆盖 | 知识领域 | 无 | 7 个生活领域 |
| 技能数 | 8 | 15 | 12 |

---

## 实践路线图

> 每阶段的详细 checklists 和成功标准见 [上手指南](docs/getting-started.md#5-phase-by-phase-采用指南)。

| 阶段 | 时间 | 构建内容 |
|------|------|---------|
| **Phase 0** | 已完成 | vault 结构、SCHEMA.md、AGENTS.md、模板、FSRS 引擎 |
| **Phase 1** | 第 1-2 周 | 只用 /task 和 /briefing，建立肌肉记忆 |
| **Phase 2** | 第 3-4 周 | 引入 /note、/ingest、/query，构建卡片库 |
| **Phase 3** | 第 5-6 周 | 启用 /review，建立每日复习习惯 |
| **Phase 4** | 第 7-8 周 | 引入 /project、/retro、/decide，系统"点亮" |
| **Phase 5** | 第 9-12 周 | /health 治理 + 基于实际使用调优 |

---

## 常见问题

**Q: 必须用 Obsidian 吗？**
是的。Obsidian ≥1.12 是必需依赖——它不仅是 Markdown 浏览器和编辑器，其 CLI 是 vault 文件操作的强制通道（自动更新 wikilink、校验 frontmatter）。FSRS 引擎通过 Python CLI 独立运行。

**Q: 数据安全吗？**
所有数据以纯 Markdown 文件存储在本地，用 Git 做版本控制。没有云同步依赖（除非你自己配置）。

**Q: 我能只用其中几个技能吗？**
可以。四组技能（执行、知识、记忆、治理）相互独立，你可以按自己的节奏逐步采用。推荐从 `/task` 和 `/briefing` 开始。

**Q: 有更详细的使用指南吗？**
每个技能怎么用、什么时候用、常见坑 → [技能参考](docs/skills.md)。真实场景的端到端示例 → [工作流示例](docs/workflow-examples.md)。

**Q: 出错了怎么办？**
先跑 `/health quick`——它能自动发现大多数问题。还不行的话, 按症状查 [故障排查](docs/troubleshooting.md)。

**Q: 怎么知道系统在健康运转？**
运行 `/health quick` 会扫描链接健康、任务僵死、复习积压、领域平衡等 6 个维度，给出综合评分和修复建议。


## License

MIT — see LICENSE. Fork 随便改。
