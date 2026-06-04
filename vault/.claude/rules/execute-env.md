## 运行环境（必读，优先级最高）

- **Shell**：默认使用 PowerShell 7（pwsh.exe），已通过 `CLAUDE_CODE_USE_POWERSHELL_TOOL=1` 启用原生工具
- **语法**：所有 Bash tool 调用使用 PowerShell 语法（Get-ChildItem、ForEach-Object、$_ 等）
- **编码**：每次会话开始前执行以下命令确保 UTF-8 一致性
```powershell
  chcp 65001 | Out-Null
  [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
  [Console]::InputEncoding  = [System.Text.Encoding]::UTF8
```
- **例外**：仅以下情况回退 Git Bash
  - 需要 POSIX 工具链（grep / sed / awk / find）且无 PowerShell 等效替代
  - 明确标注 `# git-bash-only` 的脚本块
- **Obsidian CLI 超长内容**：`content=` 参数超过 ~7 KB（CJK）时，改用 `obsidian eval` + Node `fs.readFileSync` 写入，绕开 CLI argv 的 8 KB chunk boundary bug
- **禁止**：在 PowerShell 上下文中混用 Bash 语法（`$(...)` 命令替换除外，PowerShell 兼容此语法）