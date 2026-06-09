# Transparent Memory — README

## 这是什么？

Transparent Memory (TM) 是 ThinkFlywheel Agent 的"已知真相层"——Agent 在每次对话中自动携带的关于你的事实信息。

与 AgentMemory MCP 的区别：
- **TM = 精准、可编辑、可审计的真相**（存于 vault，你随时改）
- **AgentMemory MCP = 高覆盖、中精准的语义召回**（存于 MCP 插件，不透明）

## 文件说明

| 文件 | 内容 | 谁维护 |
|------|------|--------|
| `profile.yaml` | 你的画像：角色、偏好、决策模式、当前优先事项 | 你审核，Agent 提议更新 |
| `constraints.yaml` | 全局约束：Agent 在任何建议中必须遵守的边界 | 你定义，Agent 只读 |
| `agent-log.md` | Agent 犯过的错和学到的教训 | Agent 自动写入 |
| `commitments.yaml` | Agent 未完成的承诺 | Agent 自动写入 |
| `sessions/` | 每次会话的摘要 | Stop Hook 自动写入 |

## 如何使用

1. 在 Obsidian 中打开这些文件，随时查看 Agent"认为"关于你的事实
2. 如果 Agent 的信念不对——直接改 YAML/Markdown，保存即可
3. 下次对话时，UserPromptSubmit Hook 自动注入更新后的内容
4. 所有变更在 Git 中可追溯：`git log vault/.claude/memory/`

## 冲突解决规则

| 冲突 | 谁胜出 |
|------|--------|
| TM vs AgentMemory MCP | TM |
| Obsidian vault vs TM | vault (ground truth) |
| 你当场说的话 vs TM | 你说的话 |
