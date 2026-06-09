# Community Plugins — ThinkFlywheel 扩展机制

> 方法论、分析框架、实验性技能 — 不污染 `.claude/` 基石文件，按需加载，会话级生效。

## 为什么需要插件

ThinkFlywheel 的 `vault/.claude/` 是**基石**：

- `rules/` — 铁律、权限矩阵、写作规范（永久生效，版本控制）
- `skills/` — 12 个核心技能（覆盖日常任务-知识-记忆-治理循环）
- `memory/` — Transparent Memory 四件套（Hook 自动注入）

但研究性工作需要**临时的方法论注入**。比如：
- 用"第一性原理"分析一个新产品方向
- 用"系统综述"方法梳理某个领域的文献
- 用"SWOT"框架评估一个决策选项

这些方法论不是每天用，也不是对所有人有用。它们不该常驻在 `.claude/rules/` 里占用上下文窗口。它们应该是**插件** — 装了就生效，不装就零开销。

## 插件 vs 核心规则/技能

| | 核心 (`.claude/`) | 插件 (`.claude-plugins/`) |
|---|---|---|
| **加载方式** | 自动加载（Claude Code 启动时） | 手动激活（用户显式请求） |
| **生效范围** | 永久，所有会话 | 当前会话，结束时自动卸载 |
| **维护者** | ThinkFlywheel 上游 | 用户/社区 |
| **版本控制** | Git 追踪 | 实例本地管理 |
| **更新方式** | 上游发布新版本 | 手动复制/删除 |
| **数量约束** | 固定（铁律不可增删） | 自由（但建议同时启用 ≤ 3 个） |

## 目录约定

每个插件是一个独立子目录，最少包含 `manifest.md`，可选 `rules.md` 和 `skill.md`：

```
community-plugins/
├── README.md                     ← 本文件
├── first-principles/             ← 插件示例
│   ├── manifest.md               ← 必选：插件自描述
│   ├── rules.md                  ← 可选：追加的行为规则
│   └── skill.md                  ← 可选：自定义技能定义
└── your-plugin/
    ├── manifest.md
    ├── rules.md
    └── skill.md
```

### manifest.md — 插件自描述

```yaml
---
name: my-plugin                # 目录名 = 插件名
description: 一句话描述
version: 0.1.0
provides:                      # 本插件提供什么
  - rules                      #   行为规则（追加到会话上下文）
  - skill                      #   可调用技能（/xxx 命令）
requires: []                   # 依赖的其他插件名，无依赖则为空数组
conflicts: []                  # 冲突的插件名
token_budget: 500              # 本插件 rules 预估会占用的 token 数
---
```

### rules.md — 追加行为规则

插件被激活时，rules.md 的内容注入到当前会话的上下文中。应该极短（≤ 15 条规则），只写本方法论特有的约束。**不要重复铁律或核心规则** — 那些已经在上下文里了。

### skill.md — 自定义技能

格式与 `vault/.claude/skills/*/SKILL.md` 完全一致（frontmatter + Behavior 定义）。插件技能不会被 Claude Code 自动发现（因为不在 `.claude/skills/` 路径下），需要用户显式调用或通过 manifest 声明的技能名触发。

## 安装与使用

### 安装（从模板仓库复制到运行实例）

```bash
# 从 ThinkFlywheel 仓库复制插件到你的 vault 实例
cp -r community-plugins/first-principles/ \
     /path/to/YourVault/.claude-plugins/
```

### 激活

在 Claude Code 会话中用短名加载（`vault/.claude/rules/custom-plugins.md` 提供发现规则）：

```
"加载 first-principles，然后分析 X"
```

Claude 会自动：定位 `.claude-plugins/first-principles/` → 读取 manifest → 注入 rules → 注册 skill。会话结束时插件影响自动消失。

也支持完整路径（短名规则未加载时作为 fallback）：

```
"加载 .claude-plugins/first-principles/"
```

### 列出已安装

```
"列出插件"
```

Claude 列出 `.claude-plugins/` 下所有已安装插件的名字和描述。

### 卸载

```bash
rm -rf /path/to/YourVault/.claude-plugins/first-principles/
```

没有其他清理步骤。插件不修改任何核心文件。

### 临时启用/禁用

不需要卸载。不加载就是禁用。插件没有"已安装但未启用"的状态 — 加载是会话级的，不加载就零影响。

## 创建新插件

最小插件只需一个文件：

```bash
mkdir -p .claude-plugins/my-methodology
```

**`manifest.md`**（最少内容）：
```markdown
---
name: my-methodology
description: 我的分析框架
version: 0.1.0
provides: [rules]
---
```

**`rules.md`**（插件生效时追加到上下文的行为规则，≤ 500 字）：
```markdown
# My Methodology Rules
1. ...
2. ...
```

更完整的插件可以加 `skill.md`（定义 `/xxx` 命令）和 `templates/`（专用模板）。

### 社区贡献

如果你做了有用的插件，欢迎 PR 到 `community-plugins/` 目录。要求：
- manifest.md 完整填写所有字段
- rules.md ≤ 500 字（保持上下文窗口节约）
- skill.md 遵循与核心技能一致的格式
- 在 manifest 中估算 `token_budget`

## 最佳实践

1. **一个插件只做一件事** — "研究方法论 + 项目管理 + 日记模板"拆成 3 个插件，不要揉在一起
2. **rules 极短** — 每条规则一句话。用户不需要在读规则上消耗 token
3. **不重复核心规则** — 默认核心铁律已经生效，插件只需写额外约束
4. **同时启用 ≤ 3 个** — 超过 3 个方法论同时注入会导致上下文碎片化
5. **先用手动模式** — 不要急着写 hook 自动加载。手动加载 2 周，感受真正需要自动化的摩擦点
