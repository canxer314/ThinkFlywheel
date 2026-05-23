# 上手指南

> 读完这份指南，你会拥有一个可运行的 ThinkFlywheel 系统，知道每天怎么用它。

---

## 1. 前置条件

### Obsidian ≥1.12.7

下载安装 [Obsidian](https://obsidian.md)。启动后点击 "Open folder as vault"，选择本仓库的 `vault/` 目录。

**必须启用 CLI**：Settings → CLI → Enable CLI。启用后在终端运行 `obsidian help` 确认 CLI 已注册（应显示 100+ 命令）。Obsidian 桌面端需保持运行——CLI 通过 IPC 通信。

**推荐插件**（可选但建议安装）：
- **Dataview** — MOC 和健康报告利用 frontmatter 生成动态表格时会用到

**验证**：
- Obsidian 左侧文件列表应显示 `SCHEMA.md`、`Tasks/`、`Cards/` 等目录
- 终端运行 `obsidian help` 应显示可用命令列表

### Claude Code

安装 Claude Code（[官方文档](https://docs.anthropic.com/en/docs/claude-code)），确保能在终端中直接运行：

```bash
claude --version
```

**验证**：进入 `vault/` 目录，启动 `claude`，输入 `read SCHEMA.md`。Claude 应该能读取并总结 vault 的结构。

### obsidian-skills

在 Claude Code 中安装 obsidian-skills 插件，教会 Claude 正确的 Obsidian CLI 语法和 OFM 格式：

```bash
cd vault
claude
# 在 Claude Code 会话中执行：
/plugin marketplace add kepano/obsidian-skills
/plugin install obsidian@obsidian-skills
/reload-plugins
```

安装后在会话中可通过 `/plugin list` 确认 `obsidian:obsidian-cli` 和 `obsidian:obsidian-markdown` 已加载。

### Python 3.8+

FSRS-6 间隔重复引擎需要 Python，无需安装任何第三方包：

```bash
python --version   # 或 python3 --version
```

**验证**：

```bash
cd vault
python .obsidian/scripts/fsrs_engine.py .obsidian/review_state.json stats
```

应输出 `{"total_cards": 0, ...}`（空 vault，卡片数为 0 是正常的）。

### Git（推荐）

所有数据以 Markdown 文件存储，Git 做版本控制：

```bash
git init
git add -A && git commit -m "init: ThinkFlywheel vault"
```

---

## 2. 安装

```bash
# 1. 克隆仓库
git clone <your-repo-url> thinkflywheel
cd thinkflywheel

# 2. 用 Obsidian 打开 vault/ 目录作为 vault（需启用 CLI）

# 3. 安装 obsidian-skills（在 Claude Code 中执行一次）
#    /plugin marketplace add kepano/obsidian-skills
#    /plugin install obsidian@obsidian-skills
#    /reload-plugins

# 4. 进入 vault 目录启动 Claude Code
cd vault
claude
```

---

## 3. 首次启动：验证一切就绪

Claude Code 启动后自动加载 `vault/.claude/rules/` 中的操作规则（铁律、权限矩阵、卡片类型、写作规范、目录结构、工作流）。`SCHEMA.md` 和 `AGENTS.md` 作为参考文档按需查询。测试以下命令确认系统正常：

| 命令 | 预期结果 |
|------|---------|
| `SCHEMA.md 里定义了哪些卡片类型？` | Claude 列举 9 种类型 |
| `ls vault/Templates/` | 看到 9 个 .md 模板文件 |
| `python .obsidian/scripts/fsrs_engine.py .obsidian/review_state.json stats` | 输出 JSON，total_cards 为 0 |

如果以上都正常，系统已就绪。

---

## 4. 第一个 10 分钟

### 第 0-2 分钟：创建第一个任务

```
/task 熟悉 ThinkFlywheel 系统
```

Claude 在 `Tasks/active/熟悉 ThinkFlywheel 系统.md` 创建任务笔记，自动预填 4 要素：
- **最终目标**：AI 根据任务名推断
- **原始材料堆**：AI 从 vault 中搜索相关内容填入
- **下一步行动**：AI 提议 2-3 个具体动作
- **问题与吐槽**：空白，等待你在执行中记录摩擦

去 Obsidian 看一眼这个文件，了解任务笔记长什么样。

### 第 2-5 分钟：看一下晨报

```
/briefing
```

由于 vault 里只有刚创建的一个任务，简报会很"瘦"——只有 1 个活跃任务，没有复习卡片，没有历史预警。**这是正常的。** 随着使用积累，简报会越来越有价值。

### 第 5-7 分钟：完成这个任务并复盘

告诉 Claude：

```
ThinkFlywheel 系统我已经初步了解了，这个任务完成了
```

然后运行：

```
/retro 熟悉 ThinkFlywheel 系统
```

Claude 分析"问题与吐槽"（这次可能是空的或很少），然后**双提议**——向你提议要创建的知识卡片。这是关键流程：接受其中 1-2 个提议，你会看到 `Cards/insights/` 里出现新文件。

### 第 7-9 分钟：复习

```
/review
```

如果你在上一步接受了 atomic 卡片，这里会看到它出现在复习队列中。给自己打分（1=忘了 2=有点难 3=还行 4=太简单），FSRS-6 会自动安排下次复习时间。

### 第 9-10 分钟：体检

```
/health quick
```

扫描 6 个维度：链接健康、任务僵死、知识-行动断层、领域平衡、SR 积压、矛盾检测。初期肯定有很多"警告"——正常现象。关键是**知道系统在监控什么**。

---

## 5. Phase-by-Phase 采用指南

### Phase 1（第 1-2 周）：建立肌肉记忆

**只用 `/task` 和 `/briefing`**。把任何要做的事都变成任务笔记。每天早上跑一次晨报。

- [ ] 每天至少创建 1 个任务笔记
- [ ] 每天早上跑 `/briefing`
- [ ] 累计 10+ 活跃任务
- [ ] 晨报开始让你清楚"今天第一件事做什么"

**Phase 1 成功的标志**：每天关上 Claude Code 时，你知道明天第一件事是什么。

### Phase 2（第 3-4 周）：构建知识库

**引入 `/note`、`/ingest`、`/query`**。开始处理文章、提取知识卡片、搜索你的 vault。

- [ ] 处理 3-5 篇文章（用 `/ingest`）
- [ ] 从中提取 10+ 原子卡片
- [ ] 从已完成任务的复盘中提取 5+ 洞察卡片
- [ ] `/query` 能搜到你之前记录但自己已经忘了的东西

**Phase 2 成功的标志**：`/query` 返回你自己记录过的知识，而你差点忘了。

### Phase 3（第 5-6 周）：建立记忆层

**引入 `/review`**。每天花 5-10 分钟复习到期的原子卡片。

- [ ] 建立每日复习习惯（建议晚上）
- [ ] 30+ 原子卡片在 FSRS 中流转
- [ ] 复习卡片开始出现在晨报中，标注关联的活跃任务

**Phase 3 成功的标志**：晨报中出现"复习卡片 → 关联任务"的映射，知识开始指导行动。

### Phase 4（第 7-8 周）：系统"点亮"

**引入 `/project`、`/retro`、`/decide`**。项目管理 + 复盘知识提取 + 结构化决策。

- [ ] 创建 2-3 个项目笔记，管理多任务目标
- [ ] 每次完成任务都跑 `/retro`
- [ ] 完成一个完整的飞轮循环：任务 → 复盘 → 知识提取 → 复习 → 在新任务中浮现

**Phase 4 成功的标志**：一次复盘产出的 insight，直接指导了下一个相关任务的执行。

### Phase 5（第 9-12 周）：治理和调优

**引入 `/health`**。每周做一次系统体检，根据实际数据调整配置。

- [ ] 每周日晚跑 `/health full`
- [ ] 根据健康报告修复断链、清理僵死任务
- [ ] 调整 FSRS 参数以匹配你的记忆曲线
- [ ] 定制模板以匹配你的工作流

**Phase 5 成功的标志**：系统开始"自愈"——你不需要刻意维护，`/health` 告诉你该修什么。

---

## 6. 每日例行流程

```
早晨  /briefing      →  看今日任务 + 到期复习 + 项目健康，选最重要的事开始
白天  /task          →  有新任务就创建，有进展就更新
      /ingest        →  读到好文章就处理
      /note          →  对话中学到东西就提取
傍晚  /retro         →  完成的任务做复盘，提取知识
      /review        →  复习到期的原子卡片（5-10分钟）
周末  /health full   →  全面体检，修复问题，调整配置
```

不是每项每天都要做。**只有 `/briefing` 建议每天都跑**，其他技能随活动量自然触发。

---

## 7. 验证清单

逐项打勾，确保系统运转正常：

- [ ] Obsidian 打开 vault 显示完整目录结构
- [ ] `obsidian help` 在终端可执行，显示 100+ 命令
- [ ] obsidian-skills 已安装（Claude Code 中 `/plugin list` 确认）
- [ ] Claude Code 在 vault 目录启动，自动加载 .claude/rules/ 中的操作规则
- [ ] `/task` 在 `Tasks/active/` 中创建带完整 frontmatter 的笔记
- [ ] `/briefing` 生成 `Daily/YYYY-MM-DD.md`
- [ ] `/retro` 分析任务并双提议知识卡片
- [ ] `/review` 能拉取到期卡片并记录评分
- [ ] `/health quick` 输出多维度健康报告
- [ ] FSRS 引擎可独立运行：`python .obsidian/scripts/fsrs_engine.py .obsidian/review_state.json stats`
- [ ] Git 已初始化，第一次提交完成

某项不通过？→ [troubleshooting.md](troubleshooting.md)

---

## 8. 下一步

- 想知道每个技能的详细用法 → [skills.md](skills.md)
- 想看真实使用案例 → [workflow-examples.md](workflow-examples.md)
- 遇到问题 → [troubleshooting.md](troubleshooting.md)
- 想改配置 → [customization.md](customization.md)
- 想理解架构设计 → [ThinkFlywheel - Complete System Architecture.md](ThinkFlywheel%20-%20Complete%20System%20Architecture.md)
