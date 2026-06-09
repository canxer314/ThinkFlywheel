# Changelog

ThinkFlywheel（知行飞轮）个人认知复利引擎的版本演进记录。遵循 [Keep a Changelog](https://keepachangelog.com/) 格式。

---

## [0.5.0] — 2026-06-09 · Extension System & Install

> **主题**: 系统可以动态扩展了——方法论插件按需加载，研究过程有独立工作区，安装一键完成。

### Added
- **插件扩展机制**: `community-plugins/` 目录作为可选插件源，每个插件自包含 manifest.md + rules.md + skill.md
  - 示例插件 `first-principles`: 第一性原理分析（8 条推理规则 + `/first-principles` 技能）
  - `vault/.claude/rules/custom-plugins.md` — 插件发现与加载规则（短名映射、列出、加载、卸载）
  - 插件会话级生效，不加载零开销，不污染 `.claude/` 基石
- **Playground 研究中间态工作区**: `.playground/active/` + `.playground/archived/` 目录约定
  - 单向数据流：从 vault 读取材料引用 → playground 内推理 → 仅结论通过 `/note` 双提议回写 vault
  - Obsidian 不可见（`.playground/` 隐藏目录），保持 vault 信噪比
  - 与 `Draft/`（闪念捕获）和 `.planning/`（执行追踪）明确分工
- **安装脚本** `install.ps1` + `install.sh`: 一键从模板仓库创建 vault 实例
  - 复制 vault/ 模板（跳过用户特定 `.obsidian/` 配置文件）
  - 创建 `.claude-plugins/` 和 `.playground/` 骨架
  - `-Update` 模式：仅更新 `.claude/` 基石，保留 TM 数据 + 用户插件 + 用户数据
  - `-WithPlugins` 按需预装插件 + `-InitGit` 初始化版本控制
  - 前置条件验证（Obsidian CLI / Python 3.8+ / Claude Code）

### Changed
- `docs/customization.md`: 新增 §3b（使用社区插件）和 §3c（使用 Playground 进行研究性工作）
- `docs/getting-started.md`: §2 安装步骤从手动改为运行安装脚本，补充完整参数表
- `README.md`: 快速开始节简化为 clone → install → 打开 Obsidian → 启动 Claude Code
- 卡片类型数统一为 10（修复 getting-started.md 中遗留的 "9 种" 引用）

---

## [0.4.0] — 2026-06-09 · Transparent Memory

> **主题**: Agent 不再每次从零开始认识你。

### Added
- **Transparent Memory 系统**: `vault/.claude/memory/` 下四份文件——profile.yaml（用户画像）、constraints.yaml（全局约束）、agent-log.md（Agent 错误日志）、commitments.yaml（未完成承诺）
- **UserPromptSubmit Hook** (`inject-memory.py`): 每条消息前自动注入 TM 事实，含 quality gating（confidence ≥ 0.8 或已确认）+ 3000 token sanity cap
- **Stop Hook** (`stop-maintain.py`): 会话结束时写会话骨架 + 标记 `pending_review` 状态 + 过期承诺检测
- **PreCompact Hook** (`pre-compact-save.py`): 上下文压缩时记录元数据，防止信息丢失
- **AgentMemory MCP 集成**: 6 个技能（/briefing /query /retro /meeting /decide /ingest）通过 `memory_smart_search` 做跨会话召回
- **/briefing Step 0**: 处理上轮会话待审——MCP 召回 + 冲突检测 + agent-log 写入 + TM 更新提议
- 3 个新 rules: `execute-env.md`（运行环境）、`toolcalling.md`（工具调用规则）、`no-post-hoc-reasoning.md`（推理诚实性）

### Changed
- SKILL.md 文件精简约 9%（教育性内容拆分到 DETAIL.md）
- README: 10→12 技能、9→10 卡片类型、补充 TM 系统说明、更新目录结构和架构图
- docs: skills.md 补充 /flow 和 /meeting、integrations.md 四系统记忆栈

### Removed
- `/estimation` skill（未使用）
- `vault/Draft/.gitkeep`

---

## [0.3.0] — 2026-06-04 · Rules & CLI

> **主题**: 规则硬化，CLI 操作零歧义。

### Added
- **PowerShell 转义陷阱指南** (`obsidian-cli.md`): 决策表 + 症状诊断 + 强制写后验证规则
- `settings.json` 纳入版本控制（Hook 配置）

### Changed
- Draft 卡片类型移除（11→10），同步更新 architecture docs、card-types rules、writing rules
- YAML 多值字段改为标准列表格式
- 完整架构文档合并深度分析

### Removed
- 5 个废弃的 project-level skill 文件（功能已迁移至系统 skill 插件）

---

## [0.2.0] — 2026-05-28 · Skill Hardening

> **主题**: 12 个技能全部加上反模式黑名单和失败处理。

### Added
- `/meeting` skill: 结构化会议纪要 + 行动项/决议/风险追踪
- 全部 12 个 SKILL.md: 反模式黑名单（"🚫 不要做什么"）+ 失败处理表（场景→处理）
- Darwin skill 优化验证结果（12 skills, 0 reverts）

### Fixed
- `/briefing` Step 2b 交互矛盾修正
- `/query` dim3 + dim9 失败模式处理

---

## [0.1.0] — 2026-05-26 · Three-Layer Architecture

> **主题**: Esor 三层任务架构完整落地。

### Added
- `type:flow` 卡片类型: 永久型任务笔记（SOP/流程/检查清单），补完三层架构第三层
- `Flows/` 目录结构（work/life/learning）
- 模板更新适配 flow

### Changed
- LLM Wiki 参考文档路径调整

---

## [0.0.1] — 2026-05-23 · Foundation

> **主题**: 飞轮引擎点火。Vault 结构、10 技能、规则体系、文档框架一次性交付。

### Added
- **四层飞轮架构**: L1 Memory (FSRS-6) / L2 Knowledge (LLM Wiki) / L3 Task (防弹笔记法) / L4 Governance
- **10 个初始技能**: /task /project /briefing /ingest /note /query /review /retro /health /decide
- **规则体系**: 5 条铁律 + 权限矩阵 + 写作规范 + 卡片类型 + 目录结构 + 工作流 + Obsidian CLI 规则
- **FSRS-6 引擎**: 纯 Python stdlib，间隔重复调度
- **10 种卡片类型**: task / project / atomic / concept / insight / reading / decision / moc / review（flow 在 0.1.0 加入）
- **模板系统**: 每种卡片类型的 frontmatter + 内容模板
- **文档**: README、SCHEMA.md、AGENTS.md、CLAUDE.md、上手指南、技能参考、工作流示例、故障排查、定制指南、LLM Wiki 说明
- **增强模式文档**: planning-with-files + agentmemory 集成指南
- **规则加载架构**: `.claude/rules/` 作为 ground truth 层自动加载
