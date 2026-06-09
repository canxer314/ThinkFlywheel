"""
PreCompact Hook: Save session checkpoint before context compaction.
Compaction is LLM-driven summarization — inherently lossy.
This hook mechanically preserves compaction metadata so the Agent
knows context was lost and can recover from disk if needed.

Mechanical responsibilities:
1. Parse stdin JSON for session/compaction metadata (resilient)
2. Track compaction count → write .pre-compact-state.json
3. Append compaction record → log.md

Does NOT call LLM or read vault content — pure mechanical state tracking.
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
STATE_FILE = MEMORY_DIR / '.pre-compact-state.json'
LOG_PATH = VAULT_DIR / 'log.md'


def parse_stdin():
    """Parse hook input JSON. Returns dict with defaults if empty/invalid."""
    try:
        raw = sys.stdin.read()
        if not raw or not raw.strip():
            return {'session_id': 'unknown', 'reason': 'no_stdin'}
        return json.loads(raw)
    except Exception:
        return {'session_id': 'unknown', 'reason': 'parse_error'}


def now_iso():
    """Current timestamp in ISO format."""
    return datetime.now(timezone.utc).isoformat()


def now_local_str():
    """Current local time as YYYY-MM-DD HH:MM."""
    return datetime.now().strftime('%Y-%m-%d %H:%M')


def read_existing_state():
    """Read existing pre-compact state, return defaults if missing."""
    try:
        if STATE_FILE.exists():
            return json.loads(STATE_FILE.read_text(encoding='utf-8'))
    except Exception:
        pass
    return {'compaction_count': 0, 'compactions': []}


def write_checkpoint(meta, existing):
    """Write updated pre-compact state with incremented compaction count."""
    count = existing.get('compaction_count', 0) + 1
    compactions = existing.get('compactions', [])
    compactions.append({
        'count': count,
        'timestamp': now_iso(),
        'reason': meta.get('reason', 'unknown'),
        'session_id': meta.get('session_id', 'unknown')[:16]
    })
    # Keep last 10 records to bound file size
    if len(compactions) > 10:
        compactions = compactions[-10:]

    state = {
        'session_id': meta.get('session_id', 'unknown'),
        'compaction_count': count,
        'last_compaction': now_iso(),
        'compactions': compactions
    }
    try:
        STATE_FILE.write_text(
            json.dumps(state, indent=2, ensure_ascii=False),
            encoding='utf-8'
        )
    except Exception:
        pass


def append_log(meta):
    """Append compaction record to log.md."""
    local_str = now_local_str()
    session_id = meta.get('session_id', '')[:8]
    count = read_existing_state().get('compaction_count', 0) + 1
    entry = (
        f"[{local_str}] pre-compact #{count} | "
        f"{session_id} | "
        f"reason={meta.get('reason', 'unknown')}\n"
    )

    try:
        if LOG_PATH.exists():
            current = LOG_PATH.read_text(encoding='utf-8')
            if current.startswith('---'):
                end_idx = current.find('---', 3)
                if end_idx != -1:
                    end_idx += 3
                    if end_idx < len(current) and current[end_idx] == '\n':
                        end_idx += 1
                    new_content = current[:end_idx] + '\n' + entry + current[end_idx:]
                else:
                    new_content = current + entry
            else:
                new_content = entry + current
            LOG_PATH.write_text(new_content, encoding='utf-8')
    except Exception:
        pass


def main():
    meta = parse_stdin()

    existing = read_existing_state()
    write_checkpoint(meta, existing)
    append_log(meta)


if __name__ == '__main__':
    main()
