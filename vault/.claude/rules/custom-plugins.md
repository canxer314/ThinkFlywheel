# 自定义插件 — 发现与加载

`.claude-plugins/` 是用户自维护的扩展目录。与 `.claude/rules/` 和 `.claude/skills/` 不同，此目录中的文件不被自动加载——用户必须显式激活。

## 目录结构

```
.claude-plugins/
├── {plugin-name}/
│   ├── manifest.md       # 必选：name / description / version / provides / token_budget
│   ├── rules.md          # 可选：追加到会话上下文的规则（≤ 500 字）
│   └── skill.md          # 可选：可调用技能定义（格式同 .claude/skills/*/SKILL.md）
```

## 发现

**列出已安装插件**：当用户说"列出插件"、"有什么插件"、"可用插件"时：
1. Glob `.claude-plugins/*/manifest.md`
2. 读取每个 manifest 的 `name` + `description` 字段
3. 列表输出，标注每个插件提供什么（rules / skill）

**模糊匹配**：当用户说"加载 [name]"时，name 不区分大小写，`-` 和 `_` 等效。如多个匹配，列出候选项让用户确认。

## 加载

当用户说"加载 [plugin-name]"、"启用 [plugin-name]"、"load [plugin-name]"时：

1. **定位**：Glob `.claude-plugins/{plugin-name}/manifest.md`
2. **读取 manifest**：确认 name / description / provides / token_budget
3. **注入 rules**（如 provides 包含 rules）：读取 `rules.md`，追加到当前会话上下文
4. **注册 skill**（如 provides 包含 skill）：读取 `skill.md`，注册为当前会话可用命令
5. **确认**：向用户输出 "✅ 已加载 [plugin-name]：{description}（+{token_budget} tokens）"

如无匹配插件 → 列出已安装插件供选择。

## 卸载

插件没有卸载命令。它是会话级的——会话结束，注入的 rules 和 skill 自动失效。如需永久移除，删除 `.claude-plugins/{plugin-name}/` 目录。

## 加载多个插件

可以同时加载多个插件。顺序加载，互不干扰。建议同时启用 ≤ 3 个（避免上下文碎片化）。

当用户说"加载 [A] 和 [B]"或分两次说"加载 A""加载 B"时，依次执行加载流程。

## 与 Playground 的协作

常见模式：加载插件 → 启动 playground 研究会话 → 在 playground 中用插件方法论工作 → 结论回写 vault。

```
"加载 first-principles，然后在 .playground/ 里研究 Q3 产品方向"
```
