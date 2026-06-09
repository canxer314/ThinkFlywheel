<#
.SYNOPSIS
    ThinkFlywheel 安装脚本 — 从模板仓库创建 vault 实例

.DESCRIPTION
    将 vault/ 模板复制到目标目录，创建扩展目录骨架，
    验证前置条件，输出下一步指引。

.PARAMETER TargetPath
    目标目录的绝对路径（必填）

.PARAMETER Force
    将已存在的目标目录移动到带时间戳的备份目录（而非永久删除），然后安装

.PARAMETER Update
    仅更新 .claude/ 基石文件，不触碰用户数据

.PARAMETER WithPlugins
    从 community-plugins/ 预安装的插件名列表

.PARAMETER InitGit
    在目标目录初始化 Git 仓库并做首次提交

.PARAMETER SkipVerify
    跳过前置条件验证

.EXAMPLE
    .\install.ps1 -TargetPath "C:\Obsidian\MyVault"

.EXAMPLE
    .\install.ps1 -TargetPath "C:\Obsidian\MyVault" -WithPlugins first-principles -InitGit

.EXAMPLE
    .\install.ps1 -TargetPath "C:\Obsidian\MyVault" -Update
#>

param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$TargetPath,

    [Parameter()]
    [switch]$Force,

    [Parameter()]
    [switch]$Update,

    [Parameter()]
    [string[]]$WithPlugins,

    [Parameter()]
    [switch]$InitGit,

    [Parameter()]
    [switch]$SkipVerify
)

$ErrorActionPreference = 'Stop'
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$VaultSource = Join-Path $ScriptDir 'vault'
$PluginsSource = Join-Path $ScriptDir 'community-plugins'

# ── colors ──
function Write-Step  { Write-Host "`n==> " -NoNewline -ForegroundColor Cyan; Write-Host $args }
function Write-OK    { Write-Host "  [OK] " -NoNewline -ForegroundColor Green; Write-Host $args }
function Write-Warn  { Write-Host "  [WARN] " -NoNewline -ForegroundColor Yellow; Write-Host $args }
function Write-ErrorMsg { Write-Host "  [ERROR] " -NoNewline -ForegroundColor Red; Write-Host $args }
function Write-Next  { Write-Host "  -> " -NoNewline -ForegroundColor Magenta; Write-Host $args }

# ── Step 0: validate params ──
Write-Step "参数校验"

if (-not [System.IO.Path]::IsPathRooted($TargetPath)) {
    Write-ErrorMsg "TargetPath 必须是绝对路径，收到: $TargetPath"
    exit 1
}

if ($Force -and $Update) {
    Write-ErrorMsg "-Force 和 -Update 互斥，不能同时使用"
    exit 1
}

if (-not (Test-Path $VaultSource)) {
    Write-ErrorMsg "模板目录不存在: $VaultSource"
    Write-ErrorMsg "请在 ThinkFlywheel 仓库根目录运行此脚本"
    exit 1
}

Write-OK "参数校验通过"

# ── Step 1: target directory check ──
Write-Step "目标目录检查"

$targetExists = Test-Path $TargetPath
$targetNonEmpty = $targetExists -and @(Get-ChildItem $TargetPath -ErrorAction SilentlyContinue).Count -gt 0

if ($Update) {
    if (-not $targetExists) {
        Write-ErrorMsg "Update 模式需要目标目录已存在: $TargetPath"
        exit 1
    }
    Write-OK "Update 模式：仅更新 .claude/ 基石文件"
}
elseif ($targetNonEmpty -and -not $Force) {
    Write-ErrorMsg "目标目录已存在且非空: $TargetPath"
    Write-ErrorMsg "使用 -Force 强制覆盖，或 -Update 仅更新 .claude/"
    exit 1
}
elseif ($targetNonEmpty -and $Force) {
    Write-Warn "目标目录已存在且非空: $TargetPath"
    Write-Warn "内容将被移动到备份目录（不会被永久删除）"

    $backupDir = $TargetPath + '.backup-' + (Get-Date -Format 'yyyyMMdd-HHmmss')
    Move-Item $TargetPath $backupDir
    Write-OK "已备份到: $backupDir"
    Write-OK "确认不再需要后手动删除: Remove-Item -Recurse '$backupDir'"
}
else {
    Write-OK "目标目录: $TargetPath"
}

# ── Step 2: prerequisite check ──
if (-not $SkipVerify) {
    Write-Step "前置条件验证"

    # Obsidian CLI
    try {
        $obsidianHelp = obsidian help 2>&1 | Out-String
        if ($LASTEXITCODE -eq 0) {
            Write-OK "Obsidian CLI 可用"
        } else {
            Write-Warn "Obsidian CLI 不可用 — 请安装 Obsidian ≥1.12 并在 Settings 中启用 CLI"
        }
    } catch {
        Write-Warn "Obsidian CLI 未找到 — 请确认 Obsidian 已安装且 CLI 已启用"
    }

    # Python
    try {
        $pyVer = python --version 2>&1 | Out-String
        if ($LASTEXITCODE -eq 0 -and $pyVer -match '(\d+)\.(\d+)') {
            $major = [int]$Matches[1]
            $minor = [int]$Matches[2]
            if ($major -gt 3 -or ($major -eq 3 -and $minor -ge 8)) {
                Write-OK "Python $($major).$($minor) (≥ 3.8)"
            } else {
                Write-Warn "Python $($major).$($minor) — 需要 ≥ 3.8 (FSRS 引擎)"
            }
        } else {
            Write-Warn "Python 不可用 — FSRS 间隔重复引擎需要 Python 3.8+"
        }
    } catch {
        Write-Warn "Python 未找到 — FSRS 间隔重复引擎需要 Python 3.8+"
    }

    # Claude Code
    try {
        $claudeVer = claude --version 2>&1 | Out-String
        if ($LASTEXITCODE -eq 0) {
            Write-OK "Claude Code 可用"
        } else {
            Write-Warn "Claude Code 不可用 — 请安装 Claude Code CLI"
        }
    } catch {
        Write-Warn "Claude Code 未找到 — 请安装 Claude Code CLI"
    }
}
else {
    Write-Step "前置条件验证 (已跳过)"
}

# ── Step 3: copy vault template ──
if (-not $Update) {
    Write-Step "复制 vault/ 模板"

    # Files to skip within .obsidian/ (user-specific Obsidian config per .gitignore)
    $obsidianSkip = @(
        'workspace.json',
        'workspace-mobile.json',
        'hotkeys.json',
        'app.json',
        'appearance.json',
        'community-plugins.json',
        'core-plugins.json',
        'core-plugins-migration.json',
        'plugins',
        'themes'
    )

    New-Item -ItemType Directory -Force -Path $TargetPath | Out-Null

    # Copy everything from vault/, handling .obsidian/ specially
    $allItems = Get-ChildItem $VaultSource -Force
    $copied = 0
    $skipped = 0

    foreach ($item in $allItems) {
        $name = $item.Name

        # Skip .trash/ entirely
        if ($name -eq '.trash') {
            $skipped++
            continue
        }

        # Handle .obsidian/ specially: copy but exclude user-specific configs
        if ($name -eq '.obsidian') {
            $destObsidian = Join-Path $TargetPath '.obsidian'
            New-Item -ItemType Directory -Force -Path $destObsidian | Out-Null

            $obsItems = Get-ChildItem $item.FullName -Force
            foreach ($obsItem in $obsItems) {
                $obsName = $obsItem.Name
                $obsShouldSkip = $false
                foreach ($skip in $obsidianSkip) {
                    if ($obsName -eq $skip -or $obsName -like "$skip*") {
                        $obsShouldSkip = $true
                        $skipped++
                        break
                    }
                }
                if (-not $obsShouldSkip) {
                    Copy-Item -Path $obsItem.FullName -Destination $destObsidian -Recurse -Force
                }
            }
            $copied++
            continue
        }

        $dest = Join-Path $TargetPath $name
        Copy-Item -Path $item.FullName -Destination $dest -Recurse -Force
        $copied++
    }

    Write-OK "已复制 $copied 项，跳过 $skipped 项 (用户特定配置)"

    # Handle settings.local.json -> .example
    $localSettings = Join-Path $TargetPath '.claude\settings.local.json'
    $localExample  = Join-Path $TargetPath '.claude\settings.local.json.example'
    if (Test-Path $localSettings) {
        Rename-Item $localSettings 'settings.local.json.example'
        Write-OK "settings.local.json → .example (按需启用)"
    }

    Write-OK "vault/ 模板复制完成"
}
else {
    # Update mode: only update .claude/
    Write-Step "更新 .claude/ 基石文件"

    $sourceClaude = Join-Path $VaultSource '.claude'
    $targetClaude = Join-Path $TargetPath '.claude'

    if (-not (Test-Path $sourceClaude)) {
        Write-ErrorMsg "源 .claude/ 不存在: $sourceClaude"
        exit 1
    }

    # Backup existing settings.local.json if present
    $localBackup = $null
    $existingLocal = Join-Path $targetClaude 'settings.local.json'
    if (Test-Path $existingLocal) {
        $localBackup = $existingLocal + '.backup'
        Copy-Item $existingLocal $localBackup -Force
        Write-OK "已备份 settings.local.json"
    }

    # Remove old .claude/ (keep memory/ if it exists — user's TM data)
    $memoryBackup = $null
    $existingMemory = Join-Path $targetClaude 'memory'
    if (Test-Path $existingMemory) {
        $memoryBackup = Join-Path ([System.IO.Path]::GetTempPath()) 'tf-memory-backup'
        Copy-Item $existingMemory $memoryBackup -Recurse -Force
        Write-OK "已备份 memory/ (TM 数据)"
    }

    Remove-Item $targetClaude -Recurse -Force -ErrorAction SilentlyContinue
    Copy-Item $sourceClaude $targetClaude -Recurse -Force

    # Restore memory/
    if ($memoryBackup -and (Test-Path $memoryBackup)) {
        Remove-Item (Join-Path $targetClaude 'memory') -Recurse -Force -ErrorAction SilentlyContinue
        Copy-Item $memoryBackup (Join-Path $targetClaude 'memory') -Recurse -Force
        Remove-Item $memoryBackup -Recurse -Force -ErrorAction SilentlyContinue
        Write-OK "已恢复 TM 数据 (memory/)"
    }

    # Restore settings.local.json
    if ($localBackup -and (Test-Path $localBackup)) {
        Copy-Item $localBackup $existingLocal -Force
        Remove-Item $localBackup -Force
        Write-OK "已恢复 settings.local.json"
    }

    # Still convert new settings.local.json to .example if it was newly copied
    $newLocalSettings = Join-Path $targetClaude 'settings.local.json'
    $newLocalExample  = Join-Path $targetClaude 'settings.local.json.example'
    if ($localBackup) {
        # User had a local settings — keep it
    } elseif (Test-Path $newLocalSettings) {
        Rename-Item $newLocalSettings 'settings.local.json.example'
        Write-OK "settings.local.json → .example (按需启用)"
    }

    Write-OK ".claude/ 基石文件已更新"
}

# ── Step 4: create extension directory skeletons ──
Write-Step "创建扩展目录骨架"

# .claude-plugins/
$pluginsDir = Join-Path $TargetPath '.claude-plugins'
if (-not (Test-Path $pluginsDir)) {
    New-Item -ItemType Directory -Force -Path $pluginsDir | Out-Null
}
$pluginsReadme = Join-Path $pluginsDir 'README.md'
if (-not (Test-Path $pluginsReadme)) {
    @'
# 自定义插件

此目录用于存放按需加载的方法论插件和实验性技能。
每个插件是一个子目录，最少包含 manifest.md。

## 安装插件
从 ThinkFlywheel 仓库的 community-plugins/ 复制到此目录。

## 使用
在 Claude Code 中说 "加载 <plugin-name>" 激活插件（会话级生效）。

## 约定
见 ThinkFlywheel 仓库 community-plugins/README.md
'@ | Out-File -FilePath $pluginsReadme -Encoding UTF8
    Write-OK ".claude-plugins/ 骨架已创建"
} else {
    Write-OK ".claude-plugins/ 已存在"
}

# .playground/
$playgroundDir = Join-Path $TargetPath '.playground'
$playgroundActive = Join-Path $playgroundDir 'active'
$playgroundArchived = Join-Path $playgroundDir 'archived'
foreach ($d in @($playgroundDir, $playgroundActive, $playgroundArchived)) {
    if (-not (Test-Path $d)) {
        New-Item -ItemType Directory -Force -Path $d | Out-Null
    }
}
$playgroundReadme = Join-Path $playgroundDir 'README.md'
if (-not (Test-Path $playgroundReadme)) {
    @'
# Playground — 研究中间态工作区

- `active/` — 当前进行中的研究会话
- `archived/` — 已完成的研究会话

会话结束时将结论通过 /note 双提议回写到 vault。
中间产物不进入 vault — 保持知识库信噪比。

详见 ThinkFlywheel 仓库 docs/playground.md
'@ | Out-File -FilePath $playgroundReadme -Encoding UTF8
    Write-OK ".playground/ 骨架已创建"
} else {
    Write-OK ".playground/ 已存在"
}

# ── Step 5: install plugins (optional) ──
if ($WithPlugins -and $WithPlugins.Count -gt 0) {
    Write-Step "安装插件"

    if (-not (Test-Path $PluginsSource)) {
        Write-Warn "community-plugins/ 目录不存在，跳过插件安装"
    } else {
        foreach ($pluginName in $WithPlugins) {
            $sourcePlugin = Join-Path $PluginsSource $pluginName
            $targetPlugin = Join-Path $pluginsDir $pluginName

            if (-not (Test-Path $sourcePlugin)) {
                Write-ErrorMsg "插件 '$pluginName' 在 community-plugins/ 中未找到"
                Write-ErrorMsg "可用插件: $((Get-ChildItem $PluginsSource -Directory | ForEach-Object { $_.Name }) -join ', ')"
                continue
            }

            if (Test-Path $targetPlugin) {
                Write-Warn "'$pluginName' 已安装，跳过 (先删除 $targetPlugin 再重试)"
                continue
            }

            Copy-Item $sourcePlugin $targetPlugin -Recurse -Force
            Write-OK "已安装插件: $pluginName"
        }
    }
}

# ── Step 6: git init (optional) ──
if ($InitGit) {
    Write-Step "初始化 Git 仓库"

    Push-Location $TargetPath
    try {
        git init 2>&1 | Out-Null
        if ($LASTEXITCODE -ne 0) {
            Write-Warn "git init 失败 — 请手动初始化"
        } else {
            # Create .gitignore for instance-specific files
            @'
# ThinkFlywheel instance — user-specific files
/.trash/
.obsidian/workspace*.json
.obsidian/hotkeys.json
.obsidian/app.json
.obsidian/appearance.json
.obsidian/community-plugins.json
.obsidian/core-plugins*.json
.playground/
.claude-plugins/
'@ | Out-File -FilePath '.gitignore' -Encoding UTF8

            git add -A 2>&1 | Out-Null
            git commit -m 'init: ThinkFlywheel vault instance' 2>&1 | Out-Null
            if ($LASTEXITCODE -eq 0) {
                Write-OK "Git 仓库已初始化并完成首次提交"
            } else {
                Write-Warn "git commit 失败 — 请手动完成首次提交"
            }
        }
    } finally {
        Pop-Location
    }
}

# ── Step 7: print next steps ──
Write-Host ''
Write-Host '══════════════════════════════════════════' -ForegroundColor Cyan
Write-Host '  ThinkFlywheel 安装完成！' -ForegroundColor Green
Write-Host '══════════════════════════════════════════' -ForegroundColor Cyan
Write-Host ''

Write-Next "用 Obsidian 打开此目录作为 vault"
Write-Host "    Obsidian → Open folder as vault → 选择 '$TargetPath'"
Write-Host '    然后 Settings → CLI → Enable CLI'
Write-Host ''

Write-Next "安装 obsidian-skills (在 Claude Code 中执行一次)"
Write-Host ('    cd "' + $TargetPath + '"')
Write-Host '    claude'
Write-Host '    /plugin marketplace add kepano/obsidian-skills'
Write-Host '    /plugin install obsidian@obsidian-skills'
Write-Host '    /reload-plugins'
Write-Host ''

Write-Next "启动 Claude Code"
Write-Host ('    cd "' + $TargetPath + '"')
Write-Host '    claude'
Write-Host ''

Write-Next "验证系统就绪"
Write-Host '    在 Claude Code 中说: "系统里定义了哪些卡片类型？"'
Write-Host '    预期: Claude 列举 10 种卡片类型'
Write-Host ''

Write-Host "详细上手指南: docs/getting-started.md" -ForegroundColor DarkGray
Write-Host "插件使用指南: community-plugins/README.md" -ForegroundColor DarkGray
Write-Host "Playground 约定: docs/playground.md" -ForegroundColor DarkGray
