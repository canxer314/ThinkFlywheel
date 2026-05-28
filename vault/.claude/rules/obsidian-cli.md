# Obsidian CLI 强制规则

所有对 vault 文件的创建、读取、修改、移动、删除、属性变更必须通过 `obsidian` CLI 执行。禁止使用 Write/Edit/Bash 工具直接操作 `.md` 文件。

> 需要 Obsidian 桌面端 ≥ 1.12（正式版从 1.12.4 起）保持运行。CLI 通过 IPC 通信，第一个命令会自动启动 Obsidian。
> Windows 用户注意：CLI 依赖 `Obsidian.com` 终端重定向器（随安装器自动注册到 PATH），直接调用 `Obsidian.exe` 会导致 IPC 失败（退出码 127）。

## 操作映射

### 创建文件
```bash
obsidian create name="文件名" content="内容"
obsidian create path="folder/文件名.md" content="内容" template=模板名
```
- `overwrite` 标志：覆盖已存在的同名文件
- `open` 标志：创建后打开文件；不加则不打开（默认即静默创建）
- `newtab` 标志：在新标签页打开（需配合 `open`）

### 读取文件
```bash
obsidian read file="文件名"
obsidian read path="folder/文件名.md"
obsidian read                    # 读取当前活动文件
```
- 默认返回文件完整内容（含 frontmatter）

### 编辑文件（替换/修改内容）
由于 CLI 没有原地编辑命令，采用两阶段操作：
```bash
# 1. 读取当前内容
obsidian read file="文件名"
# 2. 在内存中修改内容后，覆盖写入
obsidian create name="文件名" content="修改后的完整内容" overwrite
```
- 必须包含完整内容，不只是修改的部分

### 追加内容
```bash
obsidian append file="文件名" content="追加的内容"
obsidian append path="folder/文件名.md" content="追加的内容"
```
- 自动在文件末尾换行后追加
- `inline` 标志：不换行追加

### 前置内容（在 frontmatter 之后）
```bash
obsidian prepend file="文件名" content="前置的内容"
obsidian prepend path="folder/文件名.md" content="前置的内容"
```
- `inline` 标志：不换行前置

### 移动 / 重命名
```bash
obsidian move file="文件名" to="目标目录/"
obsidian move file="旧名" to="新目录/新名.md"  # 同时移动+重命名
obsidian rename file="文件名" name="新名称"
```
- **自动更新所有内部链接**（需在 Settings → Files & Links 中开启）

### 删除
```bash
obsidian delete file="文件名"           # 进回收站（默认）
obsidian delete file="文件名" permanent  # 永久删除
```

### 属性（Frontmatter）操作
```bash
obsidian property:set file="文件名" name=属性名 value=值 type=text|list|number|checkbox|date|datetime
obsidian property:set path="folder/文件.md" name=属性名 value=值 type=text
obsidian property:read file="文件名" name=属性名
obsidian property:remove file="文件名" name=属性名
obsidian properties file="文件名"        # 列出文件所有属性
obsidian properties active              # 列出当前活动文件属性
```
- 属性值通过 Obsidian 内部 API 校验类型
- list 类型的 `value=` 分隔方式官方文档未明确说明，建议通过 `obsidian help property:set` 确认当前版本行为
- `property:set` / `property:read` / `property:remove` 默认操作当前活动文件，可用 `file` 或 `path` 指定目标
- `properties`（无参数）列出整个 vault 所有属性的统计，**不是**当前文件；需加 `active` flag 或 `file=` 才能查看特定文件属性

### 搜索
```bash
obsidian search query="关键词" limit=20
obsidian search query="关键词" format=json
obsidian search query="关键词" path="folder/"  # 限定目录
obsidian search:context query="关键词"          # 带匹配行上下文（grep 风格）
```
- `case` 标志：区分大小写
- `total` 标志：只返回匹配数量

### 每日笔记
```bash
obsidian daily                          # 打开今天日记
obsidian daily:path                     # 获取日记文件路径（即使文件不存在）
obsidian daily:read                     # 读取今天日记
obsidian daily:append content="内容"    # 追加到日记
obsidian daily:prepend content="内容"   # 前置到日记（frontmatter 之后）
```
- `daily:append` 和 `daily:prepend` 支持 `inline` 标志（不换行）和 `open` 标志（操作后打开文件）
- `daily` 支持 `paneType=tab|split|window` 控制打开方式

### 查询链接
```bash
obsidian backlinks file="文件名"        # 反向链接
obsidian links file="文件名"            # 外向链接
obsidian unresolved                    # 断链（有指向但目标不存在）
obsidian orphans                       # 孤儿文件（无入链）
obsidian deadends                      # 死胡同文件（无出链）
```

### 标签
```bash
obsidian tags counts                   # 所有标签及计数
obsidian tags file="文件名"             # 文件标签
obsidian tag name="标签名"              # 单个标签基本信息
obsidian tag name="标签名" total        # 返回出现次数
obsidian tag name="标签名" verbose      # 包含文件列表及各文件出现次数
```

### 任务
```bash
obsidian tasks todo                    # 所有未完成任务
obsidian tasks daily                   # 日记任务
obsidian task file="文件名" line=行号 done     # 标记完成
obsidian task file="文件名" line=行号 toggle   # 切换状态
obsidian task ref="文件名.md:行号" toggle      # 用 ref 替代 file+line
obsidian task daily line=3 done               # 操作日记任务
```

### 模板
```bash
obsidian templates                     # 列出可用模板
obsidian template:read name=模板名      # 读取模板内容
obsidian template:insert name=模板名    # 插入模板到当前活动文件
```
- `template:read` 支持 `resolve` 标志解析 `{{date}}`、`{{time}}`、`{{title}}` 变量
- 创建文件时套用模板推荐用 `obsidian create ... template=模板名`

### 批量 / 索引操作（例外）
以下操作可保留直接文件访问，因为 CLI 逐文件 IPC 太慢：
- index.md 重建
- MOC 批量更新
- log.md 追加（单行可用 `obsidian append`，批量可用 Write）
```

## 边界处理

- **Obsidian 未运行**：第一个 CLI 命令会自动启动 Obsidian。等待 3-5 秒后重试命令。
- **Windows 终端重定向器**：确保 PATH 中的 `obsidian` 指向 `Obsidian.com`（非 `Obsidian.exe`），后者是 GUI 应用无法正确处理终端 I/O。用 `where obsidian` 检查。
- **多 vault**：如果终端不在 vault 目录内，用 `vault=<name>` 指定：`obsidian vault="ThinkFlywheel" read file="SCHEMA"`
- **特殊字符**：文件名含空格或特殊字符时用 `file="..."` 或 `path="..."` 引号包裹。
- **多行内容**：使用 `\n` 表示换行，`\t` 表示 tab：`content="---\ntype: type/task\n---\n# 标题"`