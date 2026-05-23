# 故障排查

> 遇到问题时，先跑 `/health quick`——它能自动发现大部分常见问题。
> 健康分低于 50 时，优先处理红色项。还不行？按症状查找下文。

---

## 1. Claude Code 相关问题

### Claude 不认识 /task、/briefing 等命令

**原因**：不在 vault 目录中启动，或技能文件缺失。

**修复**：
```bash
cd vault
claude
```
确认 `vault/.claude/skills/` 下有 10 个技能目录。如果技能确实存在但 Claude 不识别，重启 Claude Code 试试。

### Claude 不自动读取 SCHEMA.md / AGENTS.md

**原因**：`vault/CLAUDE.md` 桥接配置可能损坏或不存在。

**修复**：确认 `vault/CLAUDE.md` 存在且包含启动流程说明（读取 SCHEMA.md → AGENTS.md → index.md → log.md）。文件内容正确的话，重新启动 Claude Code。

### Claude 把文件创建到了错误目录

**原因**：SCHEMA.md 未被正确读取，导致 Claude 不知道目录规范。

**修复**：明确告诉 Claude：`先读取 SCHEMA.md 和 AGENTS.md，然后重新执行刚才的操作。`

### Claude 未经确认就创建了知识卡片

**原因**：AGENTS.md 中的双提议规则未被遵守。

**修复**：提醒 Claude：`按照 AGENTS.md 铁律 1，知识类卡片必须先提议、获确认后才能写入。` 如果是 Claude 误判了卡片类型（把 insight 当 reading 处理了），手动纠正即可。

---

## 2. FSRS 引擎相关问题

### /review 显示 0 张到期卡片，但你有原子卡片

**原因**：原子卡片创建后未注册到 FSRS。新卡片需要显式注册。

**修复**：运行 `/review` — 它首次调用时会自动扫描 `Cards/atomics/` 并注册新卡片。或者手动注册：

```bash
python .obsidian/scripts/fsrs_engine.py .obsidian/review_state.json register \
  --id "卡片文件名" --title "卡片标题" --content "卡片内容摘要"
```

### python: command not found

**原因**：Python 未安装或不在 PATH 中。某些系统上命令是 `python3`。

**修复**：
```bash
# 试试 python3
python3 --version
# 如果都没有，安装 Python 3.8+：https://python.org
```

### review_state.json 不存在

**原因**：首次运行，状态文件尚未创建。

**修复**：FSRS 引擎会在首次 `register` 或 `record` 操作时自动创建。也可以手动创建一个空的：

```bash
echo "{}" > .obsidian/review_state.json
```

然后让 `/review` 重新扫描注册卡片。

### 引擎报错 No such file or directory

**原因**：工作目录不对。FSRS 引擎使用相对于 vault 根目录的路径。

**修复**：始终在 vault 目录下运行 FSRS 命令：
```bash
cd vault
python .obsidian/scripts/fsrs_engine.py .obsidian/review_state.json <command>
```

### 复习卡片太多了，应付不过来

**原因**：跳过了太多次 `/review`，积压了。

**修复**：不要试图一次清完。每天 `/review --limit 5`，直到追平。FSRS-6 能妥善处理积压——算法会根据实际间隔调整下次复习时间，不需要"补课"。

---

## 3. 文件相关问题

### Claude 说创建了文件，但文件不存在

**原因**：Claude Code 的沙箱权限可能限制了文件写入。

**修复**：检查 `.claude/settings.local.json` 中的权限设置。确认 vault 目录有写入权限。用 `ls Tasks/active/` 验证。

### 文件权限被拒绝

**原因**：Windows 上可能有其他程序锁定了文件。

**修复**：关闭 Obsidian（极少情况下它会锁定正在编辑的文件），重试。如果有 Git 操作冲突，先用 `git status` 了解当前状态。

### 文件在 Obsidian 中不显示

**原因**：Obsidian 缓存未刷新。

**修复**：在 Obsidian 中按 `Ctrl+R` 刷新文件列表。如果还是看不到，关闭并重新打开 Obsidian。

---

## 4. 索引同步问题

### index.md 或 MOC 内容过时

**原因**：Claude 某次操作跳过了索引更新步骤。

**修复**：
```
请更新 index.md 和所有 MOC，反映当前 vault 的完整状态。扫描所有文件，重建索引。
```

### 出现断链（wikilink 指向不存在的文件）

**原因**：手动在 Obsidian 中移动或重命名了文件。

**修复**：先跑 `/health quick` 找出所有断链。然后告诉 Claude：`逐一修复断链，重命名时要更新所有引用它的文件。`

**重要**：始终用 Claude Code 命令（`/task`、`/retro` 等）操作文件，不要手动在 Obsidian 中移动或重命名。这是 5 条铁律之一。

### MOC 某个领域是空的

**原因**：新卡片创建后 MOC 未更新。

**修复**：`请更新 MOC-{domain}.md，把该领域下所有卡片加进去。`

---

## 5. 常见用户错误

### 手动创建任务文件而不是用 /task

**后果**：没有 frontmatter、没有索引更新、没有 MOC 更新、没有自动填充原始材料堆。

**恢复**：告诉 Claude：`扫描 Tasks/active/，给缺少完整 frontmatter 的文件补全，更新 index.md 和相关 MOC。`

### 完成任务后不跑 /retro

**后果**：经验未提取，飞轮断裂。任务归档了但什么都没留下来。

**恢复**：`/health full` 会标记"已归档但未复盘的异常任务"。找到它们，逐个 `/retro`。即使任务已经归档，复盘仍然有价值。

### 连续几周不复习

**后果**：FSRS 积压，知识遗忘。

**恢复**：`/review --limit 5` 每天一次，直到追平。不要一次做 50 张卡片——效果差且会破坏 FSRS 的调度算法。

### 在 Obsidian 里手动移动文件

**后果**：wikilink 断裂，MOC 引用失效，index.md 过时。

**恢复**：如果只是移动了一两个文件，手动移回去。如果做了大量重组，告诉 Claude：`我手动移动了一些文件，请扫描所有 wikilink，修复所有断链，重建 index.md 和 MOC。`

---

## 6. 恢复流程

### 重建全部索引

```
请扫描 vault 中的每个文件，从头重建 index.md 和所有 MOC。不要跳过任何文件。
```

这会花费几分钟，但会修复所有索引相关的漂移。

### 重置 FSRS 状态

如果你确定要清空复习数据（保留卡片文件本身）：

```bash
rm .obsidian/review_state.json
```

然后运行 `/review`，它会重新扫描 `Cards/atomics/` 并注册所有卡片。所有卡片的复习历史会丢失，从"新卡片"重新开始。

### Git 恢复

如果某次操作导致了灾难性问题：

```bash
git log --oneline -10        # 查看最近提交
git diff <good-commit> HEAD  # 看改了什么
git checkout <good-commit> -- .  # 恢复到好的版本
```

这也是为什么推荐用 Git 管理 vault。

### 核选项：重新开始

```bash
# 删除 FSRS 状态和自动生成的索引
rm .obsidian/review_state.json
rm index.md log.md

# 让 Claude 重新初始化
```

告诉 Claude：`把这个 vault 当作全新 vault 处理，从现有文件中重建所有索引。注册 Cards/atomics/ 下所有卡片到 FSRS。`

你会丢失 FSRS 调度数据（复习历史），但所有内容（任务笔记、知识卡片、项目）完好无损。

---

## 7. 还是不行？

1. 确认你用的是最新版 Claude Code（`claude --version`）
2. 确认 Python 3.8+（`python --version`）
3. 检查 [getting-started.md](getting-started.md) 中的验证清单
4. 参考 [customization.md](customization.md) 了解哪些配置可以调整
5. 提 GitHub Issue，附上 `/health full` 的输出和你遇到的问题描述
