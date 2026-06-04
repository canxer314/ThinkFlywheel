# Obsidian CLI 强制规则

所有对 vault 文件的创建、读取、修改、移动、删除、属性变更必须通过 `obsidian` CLI 执行。禁止使用 Write/Edit/Bash 工具直接操作 `.md` 文件。

> 需要 Obsidian 桌面端 ≥ 1.12（正式版从 1.12.4 起）保持运行。CLI 通过 IPC 通信，第一个命令会自动启动 Obsidian。
> Windows 用户注意：CLI 依赖 `Obsidian.com` 终端重定向器（随安装器自动注册到 PATH），直接调用 `Obsidian.exe` 会导致 IPC 失败（退出码 127）。
> 如果 `obsidian <command>` 多次失败，尝试通过 `obsidian help` 确认当前版本行为。

## 全局约定

- `file=<name>` 按文件名解析（类似 wikilink），`path=<path>` 是精确路径（`folder/note.md`）
- 大部分命令省略 `file`/`path` 时默认操作当前活动文件
- 含空格的值用引号包裹：`name="My Note"`
- 多行内容：`\n` 表示换行，`\t` 表示 tab
- 多 vault 环境：用 `vault=<name>` 指定目标 vault，或在 vault 目录下执行命令

---

## ⚠️ PowerShell 转义陷阱（重要）

> 此节仅对 Windows + PowerShell 环境生效。Bash / zsh / WSL 用户不受此限制。

### 核心规则

**PowerShell 双引号字符串中，`\` 不是转义字符——转义字符是反引号 `` ` ``。**
Bash 习惯的 `\"` 在 PowerShell 中会**截断字符串**并**保留字面反斜杠**：

```powershell
# ❌ 错误：Bash 习惯的转义（PowerShell 下会截断文件）
obsidian create content="project: \"[[水膜灵智能体开发]]\""
# 实际写入文件: project: \[[水膜灵智能体开发]]\
# 同时: 字符串在第一个 `"` 截断，后续内容被当作新参数 → 文件被截断

# ✅ 正确：反引号转义
obsidian create content="project: `"[[水膜灵智能体开发]]`""

# ✅ 正确：双引号转义（连写两个 `"`）
obsidian create content="project: ""[[水膜灵智能体开发]]"""

# ✅✅ 简单场景：单引号字符串（零转义）
obsidian create content='project: "[[水膜灵智能体开发]]"'

# ✅✅✅ 复杂内容（YAML + wikilink + 中文 + 多行）：PowerShell here-string
$content = @'
---
type: task
project: "[[水膜灵智能体开发]]"
related_cards:
  - "[[水膜灵AI智能体项目推进 — 2026-06-01]]"
---
'@
obsidian create content=$content
```

### 决策表

| 内容特征 | 推荐方式 |
|----------|---------|
| 短单行 + 无 `"` | `content="..."` 直接写 |
| 短单行 + 含 `"` | 单引号 `'...'` 或反引号 `` `" `` |
| 多行 + 无 `"` | `content="...\n..."`（`\n` 嵌入） |
| 多行 + 含 `[[wikilink]]` 或 YAML `"..."` | **here-string `@'...'@`** |
| 超长内容（>7KB CJK） | `obsidian eval` + Node `fs.readFileSync` |

### 症状自检

写入后发现以下任一情况 → 检查是否为 PowerShell 转义问题：

| 症状 | 原因 |
|------|------|
| 字段值带残留 `\` 反斜杠（如 `project: \[[...]]\`） | `\"` 的 `\` 字面保留 |
| 文件只有几行就结尾，丢失大量内容 | 字符串在第一个 `"` 截断 |
| 字段值出现随机拼接的乱码 | 多个被截断的 token 被 CLI 串接 |
| YAML 解析报错（Obsidian 看不到 tags） | wikilink 被破坏 |

### 铁律：写后必须验证

`obsidian create` / `obsidian append` 返回成功**不等于**内容正确。每次写入后必须：

```powershell
# 1. 检查行数（与预期对比）
(Get-Content path="...").Count

# 2. 抽样验证关键字段
obsidian read path="..." | Select-String -Pattern "expected_pattern"

# 3. 完整内容核对（关键文件）
obsidian read path="..."
```

如果行数异常（远少于预期）→ 立刻 `overwrite` 修复，不要带病提交。

---

## 核心操作

### 创建文件
```bash
obsidian create name="文件名" content="内容"
obsidian create path="folder/文件名.md" content="内容" template=模板名
```
- `overwrite`：覆盖已存在的同名文件
- `open`：创建后打开文件（默认静默创建，不打开）
- `newtab`：在新标签页打开（需配合 `open`）

### 读取文件
```bash
obsidian read file="文件名"
obsidian read path="folder/文件名.md"
obsidian read                    # 读取当前活动文件
```
- 默认返回文件完整内容（含 frontmatter）

### 打开文件
```bash
obsidian open file="文件名"
obsidian open path="folder/文件名.md"
obsidian open file="文件名" newtab  # 在新标签页打开
```

### 编辑文件（替换/修改内容）
由于 CLI 没有原地编辑命令，采用两阶段操作：
```bash
# 1. 读取当前内容
obsidian read file="文件名"
# 2. 在内存中修改内容后，覆盖写入
obsidian create name="文件名" content="修改后的完整内容" overwrite
```
- 必须包含完整内容，不只是修改的部分
- ⚠️ **写后必须验证**：见上方"PowerShell 转义陷阱 → 铁律：写后必须验证"

### 追加内容
```bash
obsidian append file="文件名" content="追加的内容"
obsidian append path="folder/文件名.md" content="追加的内容"
```
- 自动在文件末尾换行后追加
- `inline`：不换行追加

### 前置内容（在 frontmatter 之后）
```bash
obsidian prepend file="文件名" content="前置的内容"
obsidian prepend path="folder/文件名.md" content="前置的内容"
```
- `inline`：不换行前置

### 移动 / 重命名
```bash
obsidian move file="文件名" to="目标目录/"
obsidian move file="旧名" to="新目录/新名.md"        # 同时移动+重命名
obsidian move path="folder/旧名.md" to="新名.md"     # 原地重命名
obsidian rename file="文件名" name="新名称"           # 纯重命名
```
- `move` 改变路径（可同时重命名），`rename` 仅改变文件名
- 链接自动更新依赖 Obsidian Settings → Files & Links 中的配置，非 CLI 行为

### 删除
```bash
obsidian delete file="文件名"           # 进回收站（默认）
obsidian delete file="文件名" permanent  # 永久删除
```

### 文件/目录信息
```bash
obsidian file file="文件名"             # 查看文件信息
obsidian file path="folder/note.md"
obsidian files                          # 列出 vault 中所有文件
obsidian files folder="Cards"           # 限定目录
obsidian files ext="md"                 # 限定扩展名
obsidian files total                    # 仅返回文件数量
obsidian folder path="Cards"            # 查看目录信息（注意：path 不能以 / 结尾）
obsidian folder path="Cards" info=files     # 仅文件数
obsidian folder path="Cards" info=folders   # 仅子目录数
obsidian folder path="Cards" info=size      # 仅大小
obsidian folders                        # 列出所有目录
obsidian folders folder="Cards"         # 限定父目录
obsidian folders total                  # 仅返回目录数量
```

---

## 属性（Frontmatter）操作

```bash
# 设置属性
obsidian property:set file="文件名" name=属性名 value=值 type=text|list|number|checkbox|date|datetime
obsidian property:set path="folder/文件.md" name=属性名 value=值 type=text

# 读取属性
obsidian property:read file="文件名" name=属性名

# 删除属性
obsidian property:remove file="文件名" name=属性名

# 列出属性
obsidian properties file="文件名"              # 列出文件所有属性
obsidian properties active                    # 当前活动文件属性
obsidian properties                           # 全 vault 属性统计
obsidian properties name="tags"               # 某属性的出现次数
obsidian properties counts                    # 包含出现次数
obsidian properties sort=count                # 按次数排序（默认按名称）
obsidian properties format=yaml               # 输出格式：yaml（默认）| json | tsv
```
- 属性值通过 Obsidian 内部 API 校验类型
- list 类型的 `value=` 分隔方式官方文档未明确说明，建议通过 `obsidian help property:set` 确认当前版本行为
- `property:set` / `property:read` / `property:remove` 默认操作当前活动文件，可用 `file` 或 `path` 指定目标

---

## 搜索

```bash
obsidian search query="关键词"                  # 全文搜索，默认 text 格式
obsidian search query="关键词" limit=20         # 限制结果数
obsidian search query="关键词" format=json      # JSON 格式输出
obsidian search query="关键词" format=text      # 文本格式（默认）
obsidian search query="关键词" path="folder/"   # 限定目录
obsidian search query="关键词" total            # 仅返回匹配数量
obsidian search query="关键词" case             # 区分大小写
obsidian search:context query="关键词"          # 带匹配行上下文（grep 风格）
obsidian search:context query="关键词" format=json
obsidian search:open query="关键词"             # 在 Obsidian 中打开搜索面板
```

---

## 链接查询

```bash
# 反向链接（谁链接了我）
obsidian backlinks file="文件名"
obsidian backlinks counts               # 包含链接计数
obsidian backlinks total                # 仅返回数量
obsidian backlinks format=json          # 输出格式：tsv（默认）| json | csv

# 外向链接（我链接了谁）
obsidian links file="文件名"
obsidian links file="文件名" total      # 仅返回数量

# 断链（有指向但目标不存在）
obsidian unresolved
obsidian unresolved total               # 仅返回数量
obsidian unresolved counts              # 包含链接计数
obsidian unresolved verbose             # 包含源文件列表
obsidian unresolved format=json         # 输出格式：tsv（默认）| json | csv

# 孤儿文件（无入链）
obsidian orphans
obsidian orphans total                  # 仅返回数量
obsidian orphans all                    # 包含非 Markdown 文件

# 死胡同文件（无出链）
obsidian deadends
obsidian deadends total                 # 仅返回数量
obsidian deadends all                   # 包含非 Markdown 文件
```

---

## 标签

```bash
# 全 vault 标签（复数）
obsidian tags                           # 标签列表（默认 tsv 格式）
obsidian tags format=json               # 输出格式：tsv（默认）| json | csv
obsidian tags file="文件名"             # 某文件的标签
obsidian tags active                    # 当前活动文件的标签

# 单个标签详情（单数）
obsidian tag name="标签名"              # 基本信息
obsidian tag name="标签名" total        # 返回出现次数
obsidian tag name="标签名" verbose      # 包含文件列表及各文件出现次数
```

---

## 任务

```bash
# 列出任务（复数）
obsidian tasks todo                     # 所有未完成任务（默认 text 格式）
obsidian tasks done                     # 已完成任务
obsidian tasks file="文件名"            # 某文件的任务
obsidian tasks status="x"              # 按状态字符筛选
obsidian tasks total                    # 仅返回任务数量
obsidian tasks active                   # 当前活动文件的任务

# 操作单个任务（单数）
obsidian task file="文件名" line=行号 done      # 标记完成
obsidian task file="文件名" line=行号 todo      # 标记为未完成
obsidian task file="文件名" line=行号 status="x"  # 设置自定义状态字符
obsidian task ref="文件名.md:行号" toggle       # 用 ref 替代 file+line
obsidian task daily line=3 done                # 操作日记任务
```

---

## 模板

```bash
obsidian templates                      # 列出可用模板
obsidian template:read name=模板名      # 读取模板内容
obsidian template:read name=模板名 resolve  # 解析 {{date}}、{{time}}、{{title}} 变量
obsidian template:read name=模板名 resolve title="自定义标题"  # 指定 title 变量值
obsidian template:insert name=模板名    # 插入模板到当前活动文件
```
- 创建文件时套用模板推荐用 `obsidian create ... template=模板名`

---

## 其他实用命令

```bash
# 命令
obsidian commands                       # 列出所有可用命令
obsidian commands filter="editor"       # 按 ID 前缀筛选
obsidian command id="command-id"        # 执行指定命令

# Vault 信息
obsidian vault                          # 当前 vault 基本信息
obsidian reload                         # 重新加载 vault
obsidian restart                        # 重启 Obsidian
```

---

## 批量 / 索引操作（例外）

以下操作可保留直接文件访问，因为 CLI 逐文件 IPC 太慢：
- index.md 重建
- MOC 批量更新
- log.md 追加（单行可用 `obsidian append`，批量可用 Write）

---

## 边界处理

- **Obsidian 未运行**：第一个 CLI 命令会自动启动 Obsidian。等待 3-5 秒后重试命令。
- **Windows 终端重定向器**：确保 PATH 中的 `obsidian` 指向 `Obsidian.com`（非 `Obsidian.exe`），后者是 GUI 应用无法正确处理终端 I/O。用 `where obsidian` 检查。
- **多 vault**：如果终端不在 vault 目录内，用 `vault=<name>` 指定：`obsidian vault="ThinkFlywheel" read file="SCHEMA"`
- **全局 vault 选项**：`vault=<name>` 可加在任何命令上，格式为 `obsidian vault="MyVault" search query="test"`
- **特殊字符**：文件名含空格或特殊字符时用 `file="..."` 或 `path="..."` 引号包裹。
- **多行内容**：简单情况用 `\n` 表示换行、`\t` 表示 tab（例：`content="---\ntype: type/task\n---\n# 标题"`）；复杂 YAML + wikilink 内容**必须用 PowerShell here-string**（见 ⚠️ PowerShell 转义陷阱 节）
- **active file 默认**：大部分命令省略 `file`/`path` 时默认操作 Obsidian 当前活动文件；若需明确指定文件，始终使用 `file=` 或 `path=`
