# CLAUDE.md — ThinkFlywheel Bridge

> ThinkFlywheel (知行飞轮) 个人工作与生活复利引擎。
>
> 此文件是 Claude Code 的桥接配置。Agent 每次会话自动加载。
> 核心约束在 SCHEMA.md 和 AGENTS.md 中，本文件只做路由。

## Vault Context

此目录是一个 Obsidian vault，由 Claude Code 作为 AI Agent 操作。
所有内容为 Markdown 文件 + YAML frontmatter。

## 启动流程

每次会话开始，Claude Code 应:
1. 读取 `SCHEMA.md` 了解 vault 结构和规则
2. 读取 `AGENTS.md` 了解行为边界
3. 读取 `index.md` 了解内容全貌
4. 读取 `log.md` 最后 5 条，了解最近操作

## 技能路由

用户意图 → 对应技能:
- 任务相关 ("新任务"/"task"/"要做X") → 读取 `.claude/skills/task/SKILL.md`
- 晨报 ("今天"/"早上"/"briefing") → 读取 `.claude/skills/briefing/SKILL.md`
- 项目 ("目标"/"project") → 读取 `.claude/skills/project/SKILL.md`
- 阅读 ("处理"/"读一下"/"ingest") → 读取 `.claude/skills/ingest/SKILL.md`
- 笔记 ("做笔记"/"记下来"/"note") → 读取 `.claude/skills/note/SKILL.md`
- 查询 ("找"/"搜索"/"query") → 读取 `.claude/skills/query/SKILL.md`
- 复习 ("复习"/"review") → 读取 `.claude/skills/review/SKILL.md`
- 复盘 ("完成"/"done"/"retro") → 读取 `.claude/skills/retro/SKILL.md`
- 决策 ("决策"/"决定"/"decide") → 读取 `.claude/skills/decide/SKILL.md`
- 体检 ("体检"/"health"/"lint") → 读取 `.claude/skills/health/SKILL.md`

## FSRS Engine

间隔重复引擎: `.obsidian/scripts/fsrs_engine.py`
- 纯 Python stdlib，无外部依赖
- 状态文件: `.obsidian/review_state.json`
- CLI 调用: `python .obsidian/scripts/fsrs_engine.py .obsidian/review_state.json <command> [args]`
