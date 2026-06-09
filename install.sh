#!/usr/bin/env bash
#
# ThinkFlywheel 安装脚本 — 从模板仓库创建 vault 实例
#
# 用法:
#   ./install.sh -t ~/Obsidian/MyVault
#   ./install.sh -t ~/Obsidian/MyVault --with-plugins first-principles --init-git
#   ./install.sh -t ~/Obsidian/MyVault --update
#
set -euo pipefail

# ── helpers ──
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[0;33m'
CYAN='\033[0;36m'; MAGENTA='\033[0;35m'; NC='\033[0m'; BOLD='\033[1m'

step()  { echo -e "\n${CYAN}==>${NC} ${BOLD}$*${NC}"; }
ok()    { echo -e "  ${GREEN}[OK]${NC} $*"; }
warn()  { echo -e "  ${YELLOW}[WARN]${NC} $*"; }
err()   { echo -e "  ${RED}[ERROR]${NC} $*"; }
next()  { echo -e "  ${MAGENTA}->${NC} $*"; }

usage() {
    cat <<EOF
用法: $0 -t <target-path> [选项]

选项:
  -t, --target <path>     目标目录绝对路径 (必填)
  -f, --force             将已存在的目标目录移动到备份（而非删除）
  -u, --update            仅更新 .claude/ 基石文件
  -p, --with-plugins <..> 要预安装的插件名 (逗号分隔)
  -g, --init-git          初始化 Git 仓库
  -s, --skip-verify       跳过前置条件验证
  -h, --help              显示此帮助

示例:
  $0 -t ~/Obsidian/MyVault
  $0 -t ~/Obsidian/MyVault -p first-principles -g
  $0 -t ~/Obsidian/MyVault --update
EOF
    exit 0
}

# ── parse args ──
TARGET=""
FORCE=false
UPDATE=false
WITH_PLUGINS=""
INIT_GIT=false
SKIP_VERIFY=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        -t|--target)     TARGET="$2"; shift 2 ;;
        -f|--force)      FORCE=true; shift ;;
        -u|--update)     UPDATE=true; shift ;;
        -p|--with-plugins) WITH_PLUGINS="$2"; shift 2 ;;
        -g|--init-git)   INIT_GIT=true; shift ;;
        -s|--skip-verify) SKIP_VERIFY=true; shift ;;
        -h|--help)       usage ;;
        *) echo "未知参数: $1"; usage ;;
    esac
done

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
VAULT_SOURCE="$SCRIPT_DIR/vault"
PLUGINS_SOURCE="$SCRIPT_DIR/community-plugins"

# ── Step 0: validate ──
step "参数校验"

if [[ -z "$TARGET" ]]; then
    err "缺少 -t/--target 参数"
    usage
fi

if [[ "$TARGET" != /* ]]; then
    # macOS/Linux allow relative paths for home
    if [[ "$TARGET" != ~* ]]; then
        err "TargetPath 必须是绝对路径，收到: $TARGET"
        exit 1
    fi
    TARGET="${TARGET/#\~/$HOME}"
fi

if $FORCE && $UPDATE; then
    err "--force 和 --update 互斥，不能同时使用"
    exit 1
fi

if [[ ! -d "$VAULT_SOURCE" ]]; then
    err "模板目录不存在: $VAULT_SOURCE"
    err "请在 ThinkFlywheel 仓库根目录运行此脚本"
    exit 1
fi

ok "参数校验通过"

# ── Step 1: target directory check ──
step "目标目录检查"

if $UPDATE; then
    if [[ ! -d "$TARGET" ]]; then
        err "Update 模式需要目标目录已存在: $TARGET"
        exit 1
    fi
    ok "Update 模式：仅更新 .claude/ 基石文件"
elif [[ -d "$TARGET" ]] && [[ -n "$(ls -A "$TARGET" 2>/dev/null)" ]]; then
    if $FORCE; then
        warn "目标目录已存在且非空: $TARGET"
        warn "内容将被移动到备份目录（不会被永久删除）"
        backup_dir="${TARGET}.backup-$(date +%Y%m%d-%H%M%S)"
        mv "$TARGET" "$backup_dir"
        ok "已备份到: $backup_dir"
        ok "确认不再需要后手动删除: rm -rf '$backup_dir'"
    else
        err "目标目录已存在且非空: $TARGET"
        err "使用 --force 强制覆盖，或 --update 仅更新 .claude/"
        exit 1
    fi
else
    ok "目标目录: $TARGET"
fi

# ── Step 2: prerequisite check ──
if ! $SKIP_VERIFY; then
    step "前置条件验证"

    # Obsidian CLI
    if command -v obsidian &>/dev/null; then
        # obsidian help exits 0 when Obsidian is running and CLI is available
        if obsidian help &>/dev/null 2>&1; then
            ok "Obsidian CLI 可用"
        else
            warn "Obsidian CLI 不可用 — 请确认 Obsidian 正在运行且 CLI 已启用"
        fi
    else
        warn "Obsidian CLI 未找到 — 请安装 Obsidian ≥1.12 并在 Settings 中启用 CLI"
    fi

    # Python
    if command -v python3 &>/dev/null; then
        PYTHON=python3
    elif command -v python &>/dev/null; then
        PYTHON=python
    else
        PYTHON=""
    fi

    if [[ -n "$PYTHON" ]]; then
        py_ver=$("$PYTHON" --version 2>&1 | grep -oE '[0-9]+\.[0-9]+' | head -1)
        if [[ -n "$py_ver" ]]; then
            major=$(echo "$py_ver" | cut -d. -f1)
            minor=$(echo "$py_ver" | cut -d. -f2)
            if [[ "$major" -gt 3 ]] || [[ "$major" -eq 3 && "$minor" -ge 8 ]]; then
                ok "Python $py_ver (≥ 3.8)"
            else
                warn "Python $py_ver — 需要 ≥ 3.8 (FSRS 引擎)"
            fi
        fi
    else
        warn "Python 未找到 — FSRS 间隔重复引擎需要 Python 3.8+"
    fi

    # Claude Code
    if command -v claude &>/dev/null; then
        ok "Claude Code 可用"
    else
        warn "Claude Code 未找到 — 请安装 Claude Code CLI"
    fi
else
    step "前置条件验证 (已跳过)"
fi

# ── Step 3: copy vault template ──
if ! $UPDATE; then
    step "复制 vault/ 模板"

    mkdir -p "$TARGET"

    # Files to skip (user-specific Obsidian config)
    skip_names=(
        "workspace.json"
        "workspace-mobile.json"
        "hotkeys.json"
        "app.json"
        "appearance.json"
        "community-plugins.json"
        "core-plugins.json"
        "core-plugins-migration.json"
        "plugins"
        "themes"
        ".trash"
    )

    copied=0; skipped=0
    for item in "$VAULT_SOURCE"/* "$VAULT_SOURCE"/.[!.]* "$VAULT_SOURCE"/..?*; do
        [[ -e "$item" ]] || continue
        name="$(basename "$item")"

        should_skip=false
        for skip in "${skip_names[@]}"; do
            if [[ "$name" == "$skip" ]] || [[ "$name" == "$skip"* ]]; then
                should_skip=true
                break
            fi
        done

        # Skip .obsidian/plugins and .obsidian/themes specifically
        if [[ "$name" == ".obsidian" ]]; then
            # Copy .obsidian but exclude plugins/themes/user config
            mkdir -p "$TARGET/.obsidian"
            for obs_item in "$VAULT_SOURCE/.obsidian"/* "$VAULT_SOURCE/.obsidian"/.[!.]*; do
                [[ -e "$obs_item" ]] || continue
                obs_name="$(basename "$obs_item")"
                obs_skip=false
                for skip in "${skip_names[@]}"; do
                    if [[ "$obs_name" == "$skip" ]] || [[ "$obs_name" == "$skip"* ]]; then
                        obs_skip=true; break
                    fi
                done
                if ! $obs_skip; then
                    cp -R "$obs_item" "$TARGET/.obsidian/"
                fi
            done
            continue
        fi

        if $should_skip; then
            ((skipped++)) || true
            continue
        fi

        cp -R "$item" "$TARGET/"
        ((copied++)) || true
    done

    ok "已复制 $copied 项，跳过 $skipped 项 (用户特定配置)"

    # Handle settings.local.json -> .example
    local_settings="$TARGET/.claude/settings.local.json"
    local_example="$TARGET/.claude/settings.local.json.example"
    if [[ -f "$local_settings" ]]; then
        mv "$local_settings" "$local_example"
        ok "settings.local.json → .example (按需启用)"
    fi

    ok "vault/ 模板复制完成"
else
    # Update mode
    step "更新 .claude/ 基石文件"

    source_claude="$VAULT_SOURCE/.claude"
    target_claude="$TARGET/.claude"

    if [[ ! -d "$source_claude" ]]; then
        err "源 .claude/ 不存在: $source_claude"
        exit 1
    fi

    # Backup existing settings.local.json
    if [[ -f "$target_claude/settings.local.json" ]]; then
        cp "$target_claude/settings.local.json" "$target_claude/settings.local.json.backup"
        ok "已备份 settings.local.json"
    fi

    # Backup memory/
    memory_backup=""
    if [[ -d "$target_claude/memory" ]]; then
        memory_backup="$(mktemp -d)"
        cp -R "$target_claude/memory" "$memory_backup/"
        ok "已备份 memory/ (TM 数据)"
    fi

    # Replace .claude/
    rm -rf "$target_claude"
    cp -R "$source_claude" "$target_claude"

    # Restore memory/
    if [[ -n "$memory_backup" ]]; then
        rm -rf "$target_claude/memory"
        cp -R "$memory_backup/memory" "$target_claude/memory"
        rm -rf "$memory_backup"
        ok "已恢复 TM 数据 (memory/)"
    fi

    # Restore settings.local.json
    if [[ -f "$target_claude/settings.local.json.backup" ]]; then
        mv "$target_claude/settings.local.json.backup" "$target_claude/settings.local.json"
        ok "已恢复 settings.local.json"
    elif [[ -f "$target_claude/settings.local.json" ]]; then
        mv "$target_claude/settings.local.json" "$target_claude/settings.local.json.example"
        ok "settings.local.json → .example (按需启用)"
    fi

    ok ".claude/ 基石文件已更新"
fi

# ── Step 4: create extension directory skeletons ──
step "创建扩展目录骨架"

# .claude-plugins/
plugins_dir="$TARGET/.claude-plugins"
mkdir -p "$plugins_dir"
plugins_readme="$plugins_dir/README.md"
if [[ ! -f "$plugins_readme" ]]; then
    cat > "$plugins_readme" << 'PLUGINS_EOF'
# 自定义插件

此目录用于存放按需加载的方法论插件和实验性技能。
每个插件是一个子目录，最少包含 manifest.md。

## 安装插件
从 ThinkFlywheel 仓库的 community-plugins/ 复制到此目录。

## 使用
在 Claude Code 中说 "加载 <plugin-name>" 激活插件（会话级生效）。

## 约定
见 ThinkFlywheel 仓库 community-plugins/README.md
PLUGINS_EOF
    ok ".claude-plugins/ 骨架已创建"
else
    ok ".claude-plugins/ 已存在"
fi

# .playground/
playground_dir="$TARGET/.playground"
mkdir -p "$playground_dir/active" "$playground_dir/archived"
playground_readme="$playground_dir/README.md"
if [[ ! -f "$playground_readme" ]]; then
    cat > "$playground_readme" << 'PLAYGROUND_EOF'
# Playground — 研究中间态工作区

- `active/` — 当前进行中的研究会话
- `archived/` — 已完成的研究会话

会话结束时将结论通过 /note 双提议回写到 vault。
中间产物不进入 vault — 保持知识库信噪比。

详见 ThinkFlywheel 仓库 docs/playground.md
PLAYGROUND_EOF
    ok ".playground/ 骨架已创建"
else
    ok ".playground/ 已存在"
fi

# ── Step 5: install plugins ──
if [[ -n "$WITH_PLUGINS" ]]; then
    step "安装插件"

    if [[ ! -d "$PLUGINS_SOURCE" ]]; then
        warn "community-plugins/ 目录不存在，跳过插件安装"
    else
        IFS=',' read -ra plugin_array <<< "$WITH_PLUGINS"
        for plugin_name in "${plugin_array[@]}"; do
            plugin_name="$(echo "$plugin_name" | xargs)"  # trim whitespace
            source_plugin="$PLUGINS_SOURCE/$plugin_name"
            target_plugin="$plugins_dir/$plugin_name"

            if [[ ! -d "$source_plugin" ]]; then
                err "插件 '$plugin_name' 在 community-plugins/ 中未找到"
                avail=$(ls -d "$PLUGINS_SOURCE"/*/ 2>/dev/null | xargs -I{} basename {} | tr '\n' ', ')
                err "可用插件: ${avail%, }"
                continue
            fi

            if [[ -d "$target_plugin" ]]; then
                warn "'$plugin_name' 已安装，跳过 (先删除 $target_plugin 再重试)"
                continue
            fi

            cp -R "$source_plugin" "$target_plugin"
            ok "已安装插件: $plugin_name"
        done
    fi
fi

# ── Step 6: git init ──
if $INIT_GIT; then
    step "初始化 Git 仓库"

    pushd "$TARGET" > /dev/null
    if git init > /dev/null 2>&1; then
        cat > .gitignore << 'GITIGNORE_EOF'
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
GITIGNORE_EOF

        git add -A > /dev/null 2>&1
        if git commit -m 'init: ThinkFlywheel vault instance' > /dev/null 2>&1; then
            ok "Git 仓库已初始化并完成首次提交"
        else
            warn "git commit 失败 — 请手动完成首次提交"
        fi
    else
        warn "git init 失败 — 请手动初始化"
    fi
    popd > /dev/null
fi

# ── Step 7: print next steps ──
cat <<EOF

══════════════════════════════════════════
  ThinkFlywheel 安装完成！
══════════════════════════════════════════

$(next "用 Obsidian 打开此目录作为 vault")
    Obsidian → Open folder as vault → 选择 '$TARGET'
    然后 Settings → CLI → Enable CLI

$(next "安装 obsidian-skills (在 Claude Code 中执行一次)")
    cd "$TARGET"
    claude
    /plugin marketplace add kepano/obsidian-skills
    /plugin install obsidian@obsidian-skills
    /reload-plugins

$(next "启动 Claude Code")
    cd "$TARGET"
    claude

$(next "验证系统就绪")
    在 Claude Code 中说: "系统里定义了哪些卡片类型？"
    预期: Claude 列举 10 种卡片类型

详细上手指南: docs/getting-started.md
插件使用指南: community-plugins/README.md
Playground 约定: docs/playground.md
EOF
