# 增强模式：planning-with-files + agentmemory

> ThinkFlywheel 管理**人的**记忆。planning-with-files 管理 **Agent 的工作**记忆。agentmemory 管理 **Agent 的长期**记忆。三者组合形成完整的"人-AI 协作记忆栈"。

---

## 1. 两个增强技能简介

### planning-with-files

Manus 风格的文件化规划。核心思想：**上下文窗口 = RAM（易失、有限），文件系统 = 磁盘（持久、无限）。重要信息写入磁盘。**

三文件模式：
| 文件 | 用途 | 更新时机 |
|------|------|---------|
| `task_plan.md` | Phase 拆分、进度、决策记录 | 每完成一个 phase |
| `findings.md` | 研究发现、探索结果 | 有任何发现时立即写 |
| `progress.md` | 会话日志、测试结果 | 整个会话中持续追加 |

关键特性：
- **Phase 追踪**：把复杂任务拆成 phase，标记 `in_progress` / `complete`
- **3-Strike 错误恢复**：失败 3 次自动升级给用户，不重复相同错误
- **会话恢复**：`/clear` 后 `session-catchup.py` 自动恢复上次进度
- **Plan 防篡改**：SHA-256 哈希验证，防止外部内容注入 plan 文件

### agentmemory

Claude Code 的持久化记忆 MCP 插件。记录每一次会话的观察、决策和代码变更。

核心能力：
| 命令 | 用途 |
|------|------|
| `memory_recall` | 语义搜索过去会话的观察和决策 |
| `handoff` | 恢复最近一次会话的上下文 |
| `recap` | 按日期汇总最近的会话内容 |
| `session-history` | 列出历史会话概览 |
| `commit-context` | 追溯某行代码/文件的变更来源（哪个会话、什么任务） |
| `memory_save` | 显式保存洞察、决策、模式到长期记忆 |

---

## 2. 三系统如何协同

### 记忆分工

```
                    ┌──────────────────────┐
                    │    "我该做什么？"       │
                    │    ThinkFlywheel       │
                    │    /task /briefing     │
                    │    (人的工作生活管理)    │
                    └──────────┬───────────┘
                               │ 定义任务目标
                               v
                    ┌──────────────────────┐
                    │    "怎么一步步做？"     │
                    │   planning-with-files │
                    │   task_plan.md        │
                    │   (Agent 的执行规划)    │
                    └──────────┬───────────┘
                               │ 执行中产生发现
                               v
                    ┌──────────────────────┐
                    │   "上次怎么做的？"      │
                    │   agentmemory         │
                    │   memory_recall       │
                    │   (Agent 的长期记忆)    │
                    └──────────┬───────────┘
                               │ 回忆过去经验
                               v
                    ┌──────────────────────┐
                    │   "我记住了什么？"      │
                    │   ThinkFlywheel FSRS  │
                    │   /review             │
                    │   (人类长期记忆)        │
                    └──────────────────────┘
```

### 协同点 1：任务执行闭环

这是最核心的协同模式——一个 ThinkFlywheel 任务从创建到完成的完整流程：

```
1. /task 写 Q2 复盘报告
   → ThinkFlywheel 创建任务笔记，自动填充原始材料堆

2. 任务比较复杂，启动 planning-with-files：
   → 创建 task_plan.md:
      Phase 1: 收集 Q2 各项目数据
      Phase 2: 分析关键指标
      Phase 3: 撰写复盘报告
      Phase 4: 提取经验教训

3. AI 按 phase 逐步执行
   → progress.md 记录每个 phase 的操作和结果
   → findings.md 记录数据分析中的发现
   → 遇到错误按 3-strike 协议处理

4. 全部 phase 完成后
   → /retro 写 Q2 复盘报告
   → ThinkFlywheel 归档任务 + 提取 insight/atomic 卡片
   → agentmemory memory_save 保存 AI 的发现（下次类似任务会召回）
```

### 协同点 2：双重会话恢复

当 `/clear` 或重启 Claude Code 后：

```
agentmemory handoff
  → 恢复："上次我们正在做 Q2 复盘报告，Phase 2 完成了数据分析，
          发现了 3 个关键指标偏离预期"

planning-with-files session-catchup
  → 恢复：task_plan.md 显示 Phase 3 (撰写报告) 是当前 phase
          findings.md 有已收集的数据
          progress.md 有之前的操作日志

两者互补：
- agentmemory 恢复对话语义（"我们在聊什么"）
- planning-with-files 恢复执行状态（"做到哪一步了"）
```

### 协同点 3：双向知识沉淀

```
人的经验 → ThinkFlywheel:
  /retro 分析"问题与吐槽"
  → insight: "跨团队依赖是 Q2 最大的进度风险"
  → FSRS-6 调度复习
  → 下次 Q3 立项时，/briefing 会提醒这个教训

Agent 的经验 → agentmemory:
  memory_save:
    content: "处理复盘类任务时，应该先收集所有项目数据再做分析，
             不要边收集边写——上次 Q2 复盘时发现数据不全导致重写"
    type: pattern
    concepts: retro, project-review, data-collection
  → 下次用户创建复盘任务时，memory_recall 自动召回这个建议
```

### 协同点 4：代码溯源链

当你（或 AI）修改了 vault 中的文件后：

```bash
# 追溯某个文件的变更历史
agentmemory commit-context vault/Cards/insights/Q2跨团队依赖问题.md

→ 输出：
  Commit: a1b2c3d (2026-05-23)
  Session: "Q2 OKR 复盘 — 提取经验教训"
  Task: /retro Q2 OKR 复盘报告
  Context: 用户完成了 Q2 OKR 复盘，从'问题与吐槽'中提取了 3 张 insight 卡片
```

这让你在任何时候都能回答"这段知识是怎么来的"——ThinkFlywheel 铁律 4（溯源链不可断）在代码层面得以实现。

---

## 3. 典型工作流：增强模式下的日常

```
08:00  /briefing                     ThinkFlywheel: 今日任务 + 复习
       "Q2 复盘报告 due in 2 天"

09:00  claude                       启动 Claude Code
       agentmemory handoff          恢复上次上下文
       planning-with-files          读取 task_plan.md (Phase 3/4)

09:05  继续执行 Phase 3              planning-with-files 追踪进度
       遇到问题 → findings.md        记录发现
       修复错误 → progress.md        记录操作

14:00  /ingest                      读了一篇关于复盘方法论的文章
       触发 /note 双提议             提取 2 张 atomic 卡片
       agentmemory memory_save      保存："复盘类文章中最有价值的是…"

17:00  Phase 4 完成                  planning-with-files: 所有 phase ✓
       /retro Q2 复盘报告            ThinkFlywheel: 归档 + 提取 insight
       agentmemory memory_save      保存复用模式供下次参考

20:00  /review                      复习今天提取的卡片
       /health quick                快速体检

周末   agentmemory recap            回顾本周所有会话
       /health full                 ThinkFlywheel 全面体检
```

---

## 4. 配置指南

### planning-with-files

已内置在仓库的 `.claude/skills/planning-with-files/` 中，hook 自动激活。

**启动一个 planning session**：

```bash
# 在 vault 目录下（或项目根目录），创建 isolated plan
${CLAUDE_PLUGIN_ROOT}/scripts/init-session.sh "我的任务名"
```

**手动使用**（如果 hook 未自动触发）：
```
请为"[任务名]"创建 planning-with-files 的 task_plan.md
```

AI 会创建包含 phase 拆分的 task_plan.md 并开始追踪。

**恢复上次进度**：
```bash
python ${CLAUDE_PLUGIN_ROOT}/scripts/session-catchup.py "$(pwd)"
```

### agentmemory

agentmemory 是 Claude Code MCP 插件，需要安装配置。

**安装**：
```bash
claude plugins install agentmemory
```

**验证**：
```
列出最近的 agent 会话
```

如果正常，Claude 会调用 `memory_sessions` 并返回会话列表。

**日常使用**：
- 新会话开始时说 `恢复上次上下文` → 触发 handoff
- `本周做了什么` → 触发 recap
- `记得这个` → 触发 memory_save
- `这个文件是谁改的` → 触发 commit-context

---

## 5. 什么时候用增强模式

| 场景 | 只用 ThinkFlywheel | + planning-with-files | + agentmemory |
|------|-------------------|----------------------|---------------|
| 日常小事（回复邮件） | `/task` 足够 | 不需要 | 不需要 |
| 中等任务（写周报） | `/task` + `/retro` | 可选（如果步骤多） | 不需要 |
| 复杂任务（Q2 复盘） | `/task` + `/retro` | **推荐**（phase 多，跨多天） | **推荐**（下次类似任务需要上下文） |
| 跨会话项目（学 Rust） | `/project` | **强烈推荐**（持久追踪） | **强烈推荐**（每周 resume 不丢上下文） |
| 多人协作项目 | `/project` + `/decide` | **必需** | **必需**（追溯每次变更的决策来源） |

**简单原则**：任务超过 5 个步骤或跨天执行 → 启用 planning-with-files。跨 3 个以上会话 → 启用 agentmemory。

---

## 6. 常见问题

**Q: planning-with-files 和 ThinkFlywheel 的 /task 不重复吗？**

不重复。`/task` 描述**要做什么**（目标、材料、行动、吐槽），面向人的理解。planning-with-files 描述 **AI 怎么做**（phase 拆分、技术决策、错误日志），面向 AI 的执行。前者在 Obsidian vault 里，后者在项目目录 `.planning/` 下。

**Q: agentmemory 和 ThinkFlywheel 的 FSRS 不重复吗？**

不重复。FSRS-6 管理**人**的长期记忆（"SBI 反馈框架我记住了吗"）。agentmemory 管理 **AI** 的长期记忆（"上次那个 bug 是怎么修的"）。一个推入人脑，一个存放在 MCP 持久化层。

**Q: 三个系统会不会太复杂？**

按需渐进采用：
- 先用 ThinkFlywheel 核心 10 技能（Phase 1-3）
- 复杂任务多了 → 加 planning-with-files（Phase 4-5 自然引入）
- 会话多了，经常 `/clear` → 加 agentmemory

不是一开始就要三系统全开。
