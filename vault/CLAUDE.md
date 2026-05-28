# CLAUDE.md — ThinkFlywheel Bridge

> ThinkFlywheel (知行飞轮) 个人工作与生活复利引擎。
>
> 此目录为 Obsidian vault，由 Claude Code 作为 AI Agent 操作。
> 所有内容为 Markdown 文件 + YAML frontmatter。
>
> 操作规则由 `.claude/rules/` 自动加载至 ground truth 层（铁律、权限、写作标签、工作流、卡片类型、目录结构、Obsidian CLI 强制规则）。
> AGENTS.md 为跨工具兼容保留（Codex 原生支持），SCHEMA.md 为按需参考的完整结构文档。

## 技能路由

| 用户意图 | 技能 |
|---------|------|
| "新任务/要做X/task" | 读取 `.claude/skills/task/SKILL.md` |
| "今天/早上/简报/briefing" | 读取 `.claude/skills/briefing/SKILL.md` |
| "目标/项目/规划/project" | 读取 `.claude/skills/project/SKILL.md` |
| "流程/SOP/常做的事/flow" | 读取 `.claude/skills/flow/SKILL.md` |
| "处理/读一下/分析/ingest" | 读取 `.claude/skills/ingest/SKILL.md` |
| "做笔记/记下来/整理/note" | 读取 `.claude/skills/note/SKILL.md` |
| "查询/搜索/找/query" | 读取 `.claude/skills/query/SKILL.md` |
| "复习/review" | 读取 `.claude/skills/review/SKILL.md` |
| "完成/做完了/复盘/retro" | 读取 `.claude/skills/retro/SKILL.md` |
| "决策/选择/决定/decide" | 读取 `.claude/skills/decide/SKILL.md` |
| "体检/检查/健康/health" | 读取 `.claude/skills/health/SKILL.md` |
| "会议/处理会议/会议纪要/转录/meeting" | 读取 `.claude/skills/meeting/SKILL.md` |

## FSRS Engine

间隔重复引擎: `.obsidian/scripts/fsrs_engine.py`
- 纯 Python stdlib，无外部依赖
- 状态文件: `.obsidian/review_state.json`
- 目标卡片: 所有 `Cards/atomics/` 下 `type/atomic` 标签的卡片
- 复习触发: 用户调用 `/review` 或 `/briefing` 自动检测到期卡片
- 评级: Again(1) / Hard(2) / Good(3) / Easy(4)
- CLI: `python .obsidian/scripts/fsrs_engine.py .obsidian/review_state.json <command> [args]`
