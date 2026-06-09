"""
Stop Hook: Auto-maintain Transparent Memory at session end.
Fires when Claude Code exits. Writes session metadata, manages pending-review state.

Does NOT modify profile.yaml or constraints.yaml — those require user confirmation.
The LLM-level analysis (detecting assertions, corrections, constraint violations)
is deferred to the next session's /briefing, which reads .stop-state.json.

Mechanical responsibilities:
1. Parse stdin JSON for session metadata (resilient: works with empty/missing stdin)
2. Write session summary skeleton → memory/sessions/YYYY-MM-DD-HHmm.md
3. Append session-end record → log.md
4. Write state file → memory/.stop-state.json (pending_review=true)
5. Check commitments.yaml for overdue items → flag in skeleton
"""
import sys, json, os
from pathlib import Path
from datetime import datetime, timezone

# Force UTF-8 I/O — hooks may run under bash with non-UTF-8 locale
if hasattr(sys.stdout, 'reconfigure'):
    sys.stdout.reconfigure(encoding='utf-8')
if hasattr(sys.stdin, 'reconfigure'):
    sys.stdin.reconfigure(encoding='utf-8')

VAULT_DIR = Path(os.environ.get(
    'CLAUDE_CODE_PROJECT_DIR',
    os.environ.get('CLAUDE_PROJECT_DIR', '.')
))

MEMORY_DIR = VAULT_DIR / '.claude' / 'memory'
SESSIONS_DIR = MEMORY_DIR / 'sessions'
STATE_FILE = MEMORY_DIR / '.stop-state.json'
LOG_PATH = VAULT_DIR / 'log.md'


def safe_read(path):
    """Read file, return '' if missing."""
    try:
        return path.read_text(encoding='utf-8')
    except Exception:
        return ''


def ensure_dir(path):
    """Create directory if it doesn't exist."""
    try:
        path.mkdir(parents=True, exist_ok=True)
    except Exception:
        pass


def parse_stdin():
    """Parse hook input JSON from stdin. Returns dict with defaults if empty/invalid."""
    try:
        raw = sys.stdin.read()
        if not raw or not raw.strip():
            return {'session_id': 'unknown', 'stop_reason': 'no_stdin'}
        return json.loads(raw)
    except Exception:
        return {'session_id': 'unknown', 'stop_reason': 'parse_error'}


def now_iso():
    """Current timestamp in ISO format."""
    return datetime.now(timezone.utc).isoformat()


def now_local_str():
    """Current local time as YYYY-MM-DD HH:MM."""
    return datetime.now().strftime('%Y-%m-%d %H:%M')


def now_file_tag():
    """Current local time as YYYY-MM-DD-HHmm (safe for filenames)."""
    return datetime.now().strftime('%Y-%m-%d-%H%M')


def check_overdue_commitments():
    """Scan commitments.yaml for overdue items. Returns list of strings."""
    text = safe_read(MEMORY_DIR / 'commitments.yaml')
    if not text.strip():
        return []

    overdue = []
    now = datetime.now()
    in_commitment = False
    current = {}

    for line in text.split('\n'):
        s = line.strip()
        if not s or s.startswith('#'):
            continue
        if s.startswith('- id:') or s.startswith('- task:'):
            if current and current.get('due'):
                try:
                    due_date = datetime.fromisoformat(current['due'])
                    if due_date < now:
                        overdue.append(
                            f"- ⚠️ 过期承诺: [{current.get('id', current.get('task', '?'))}] "
                            f"{current.get('content', current.get('description', '?'))} "
                            f"(due: {current['due']})"
                        )
                except (ValueError, TypeError):
                    pass
            current = {}
            if ':' in s:
                k, v = s.split(':', 1)
                current[k.strip().lstrip('- ')] = v.strip()
            in_commitment = True
        elif in_commitment and ':' in s:
            k, v = s.split(':', 1)
            current[k.strip()] = v.strip()

    # Last item
    if current and current.get('due'):
        try:
            due_date = datetime.fromisoformat(current['due'])
            if due_date < now:
                overdue.append(
                    f"- ⚠️ 过期承诺: [{current.get('id', current.get('task', '?'))}] "
                    f"{current.get('content', current.get('description', '?'))} "
                    f"(due: {current['due']})"
                )
        except (ValueError, TypeError):
            pass

    return overdue


def write_session_skeleton(meta):
    """Write session summary skeleton to memory/sessions/YYYY-MM-DD-HHmm.md."""
    ensure_dir(SESSIONS_DIR)

    file_tag = now_file_tag()
    local_str = now_local_str()
    iso_str = now_iso()

    session_id = meta.get('session_id', 'unknown')
    stop_reason = meta.get('stop_reason', 'unknown')
    cwd = meta.get('cwd', '')
    transcript = meta.get('transcript_path', '')

    overdue = check_overdue_commitments()
    overdue_section = ''
    if overdue:
        overdue_section = '\n'.join(overdue)
    else:
        overdue_section = '（无过期承诺）'

    content = f"""---
type: session-summary
session_id: {session_id}
started: {iso_str}
ended: {iso_str}
stop_reason: {stop_reason}
status: pending-review
cwd: {cwd}
transcript: {transcript}
---

# Session {local_str}

## 元数据
- **开始:** {iso_str}
- **结束:** {iso_str}
- **退出原因:** {stop_reason}
- **工作目录:** {cwd}

## 待分析（下次 /briefing 填写）
- [ ] 关键决策
- [ ] 新建/修改的文件
- [ ] Agent 被纠正的情况
- [ ] 新用户 assertion
- [ ] 需更新的 TM 条目

## 过期承诺检查
{overdue_section}
"""

    filepath = SESSIONS_DIR / f'{file_tag}.md'
    try:
        filepath.write_text(content, encoding='utf-8')
        # Return vault-relative path (for portability across machines)
        return '.claude/memory/sessions/' + filepath.name
    except Exception:
        return None


def write_state_file(session_file):
    """Write .stop-state.json to signal pending review."""
    state = {
        'last_session_end': now_iso(),
        'last_session_file': session_file or '',
        'pending_review': True
    }
    try:
        STATE_FILE.write_text(json.dumps(state, indent=2, ensure_ascii=False), encoding='utf-8')
    except Exception:
        pass


def append_log(meta):
    """Append session-end record to log.md."""
    local_str = now_local_str()
    stop_reason = meta.get('stop_reason', 'unknown')
    session_id = meta.get('session_id', '')[:8]  # truncated for readability

    entry = f"[{local_str}] session-end | {session_id} | stop_reason={stop_reason}\n"

    try:
        if LOG_PATH.exists():
            current = LOG_PATH.read_text(encoding='utf-8')
            # Insert after frontmatter or at top
            if current.startswith('---'):
                # Find end of frontmatter
                end_idx = current.find('---', 3)
                if end_idx != -1:
                    end_idx += 3
                    # Skip trailing newline
                    if end_idx < len(current) and current[end_idx] == '\n':
                        end_idx += 1
                    new_content = current[:end_idx] + '\n' + entry + current[end_idx:]
                else:
                    new_content = current + entry
            else:
                new_content = entry + current
            LOG_PATH.write_text(new_content, encoding='utf-8')
        # If log.md doesn't exist, skip silently — it's optional
    except Exception:
        pass


def main():
    meta = parse_stdin()

    # Write session skeleton (always, even with default metadata)
    session_file = write_session_skeleton(meta)

    # Write state file for next /briefing
    write_state_file(session_file)

    # Append to log.md
    append_log(meta)


if __name__ == '__main__':
    main()
