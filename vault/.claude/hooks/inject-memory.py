"""
UserPromptSubmit Hook: Inject transparent memory key facts into context.
Reads profile.yaml, constraints.yaml, agent-log.md.
Injects a condensed summary before the agent processes user input.

Does NOT replace Obsidian CLI search — that's the agent's job.
Only injects facts the agent shouldn't have to re-learn every session.

Injection principles:
1. Quality-gated: profile entries with confidence field → conf >= 0.8 OR last_confirmed != null
2. Identity claims and priorities included regardless (factual, not inferential)
3. All active constraints always injected (highest value-per-token)
4. Recent 5 agent-log lessons injected
5. Sanity cap: total injection ≤ 3000 tokens (bug guard, not budget control)
"""
import sys, json, os
from pathlib import Path

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

# ——— token budgeting ———
# Rough estimator: CJK chars ≈ 1.5 tokens, ASCII words ≈ 1 token, whitespace ≈ 0
# We're conservative: CJK char → 2 tokens, everything else → 0.25 tokens per char
# This overestimates slightly, which is safe for a sanity cap.
def estimate_tokens(text):
    """Rough token count. Overestimates CJK, safe for sanity cap."""
    cjk = sum(1 for c in text if '一' <= c <= '鿿' or '　' <= c <= '〿')
    other = len(text) - cjk
    return int(cjk * 2 + other * 0.25)

SANITY_CAP = 3000


def safe_read(path):
    """Read file, return '' if missing."""
    try:
        return path.read_text(encoding='utf-8')
    except Exception:
        return ''


def field_val(line, key):
    """Extract value after 'key:' from a stripped line. Returns None if key not found."""
    s = line.strip()
    if s.startswith(key + ':'):
        return s.split(':', 1)[1].strip()
    # Also match pattern like '- key: value'
    if s.startswith('- ' + key + ':'):
        return s.split(':', 1)[1].strip()
    return None


def extract_profile_facts(profile_text):
    """
    Extract profile facts with quality gating.
    - Entries WITH confidence field: only inject if conf >= 0.8 OR last_confirmed != null
    - Entries WITHOUT confidence field (identity, priorities): inject with note marker
    Returns list of lines, or empty list if nothing passes.

    Profile YAML structure (indent levels):
      indent=0: profile:
      indent=2: identity: / preferences: / decision_patterns: / current_priorities:
      indent=4: sub-keys within a section (role:, communication:, - pattern:, etc.)
      indent=6: fields within a preference sub-key (style:, confidence:, etc.)
    """
    if not profile_text.strip():
        return []

    lines = profile_text.split('\n')
    facts = ['## Profile (source: transparent memory)']

    in_profile = False

    # ——— identity section (indent=2, no confidence field → inject) ———
    in_section = False
    for line in lines:
        s = line.strip()
        indent = len(line) - len(line.lstrip())
        if indent == 0 and s.startswith('profile:'):
            in_profile = True
            continue
        if not in_profile:
            continue
        # Detect section boundaries at indent=2
        if indent == 2 and s.startswith('identity:'):
            in_section = True
            continue
        if indent == 2 and ':' in s and not s.startswith('identity:'):
            in_section = False  # moved to next section
        if in_section and indent >= 4 and 'role:' in s:
            facts.append(f"  {s}")
        if in_section and indent >= 4 and s.startswith('note:'):
            facts.append(f"  ⚠️ {s}")

    # ——— preferences section (indent=2, sub-keys at indent=4, fields at indent=6) ———
    in_section = False
    current_parent = None    # e.g. "communication", "analysis"
    current_conf = None
    current_confirmed = None
    current_style = None

    def flush_pref():
        """Decide whether current preference passes the gate and add it."""
        nonlocal current_parent, current_conf, current_confirmed, current_style
        if current_style and current_parent:
            passes = False
            if current_conf is not None:
                passes = current_conf >= 0.8 or (current_confirmed is not None and current_confirmed != '')
            else:
                passes = True  # no confidence field → treat as declarative
            if passes:
                facts.append(f"  [{current_parent}] {current_style}")
        current_parent = None
        current_conf = None
        current_confirmed = None
        current_style = None

    for line in lines:
        s = line.strip()
        indent = len(line) - len(line.lstrip())
        if indent == 2 and s.startswith('preferences:'):
            in_section = True
            continue
        if in_section and indent == 2 and ':' in s and not s.startswith('preferences:'):
            flush_pref()
            in_section = False
            continue
        if not in_section:
            continue

        # Preference sub-key at indent=4 (e.g. "communication:", "analysis:")
        if indent == 4 and ':' in s and not s.startswith('-'):
            flush_pref()
            current_parent = s.split(':')[0].strip()
            continue

        # Fields within a preference sub-key at indent=6
        if indent == 6 and 'style:' in s:
            current_style = s
        if 'confidence:' in s:
            try:
                current_conf = float(s.split(':', 1)[1].strip())
            except (ValueError, TypeError):
                pass
        if 'last_confirmed:' in s:
            val = s.split(':', 1)[1].strip()
            if val and val != 'null':
                current_confirmed = val
    flush_pref()  # last one

    # ——— decision_patterns section (list items at indent=4, fields at indent=6) ———
    in_section = False
    current_pat = None
    current_conf = None
    current_confirmed = None

    def flush_pat():
        nonlocal current_pat, current_conf, current_confirmed
        if current_pat:
            passes = False
            if current_conf is not None:
                passes = current_conf >= 0.8 or (current_confirmed is not None and current_confirmed != '')
            else:
                passes = True
            if passes:
                facts.append(f"  {current_pat}")
        current_pat = None
        current_conf = None
        current_confirmed = None

    for line in lines:
        s = line.strip()
        indent = len(line) - len(line.lstrip())
        if indent == 2 and s.startswith('decision_patterns:'):
            in_section = True
            continue
        if in_section and indent == 2 and ':' in s and not s.startswith('decision_patterns:'):
            flush_pat()
            in_section = False
            continue
        if not in_section:
            continue

        if indent == 4 and s.startswith('- pattern:'):
            flush_pat()
            current_pat = s
            continue

        if 'confidence:' in s:
            try:
                current_conf = float(s.split(':', 1)[1].strip())
            except (ValueError, TypeError):
                pass
        if 'last_confirmed:' in s:
            val = s.split(':', 1)[1].strip()
            if val and val != 'null':
                current_confirmed = val
    flush_pat()

    # ——— current_priorities section (indent=2, list items at indent=4, no confidence) ———
    in_section = False
    for line in lines:
        s = line.strip()
        indent = len(line) - len(line.lstrip())
        if indent == 2 and s.startswith('current_priorities:'):
            in_section = True
            continue
        if in_section and indent == 2 and ':' in s and not s.startswith('current_priorities:'):
            in_section = False
        if in_section and indent == 4 and s.startswith('- '):
            facts.append(f"  priority: {s[2:]}")
        if in_section and indent >= 4 and s.startswith('note:'):
            facts.append(f"  ⚠️ {s}")

    return '\n'.join(facts) if len(facts) > 1 else ''


def extract_active_constraints(constraints_text):
    """
    Extract ALL active constraints. No per-constraint token limit.
    Constraints are the highest-value injection — they prevent concrete errors.
    """
    if not constraints_text.strip():
        return ''

    lines = constraints_text.split('\n')
    constraints = ['## Active Constraints (source: transparent memory, DO NOT VIOLATE)']

    in_constraint = False
    current = {}
    for line in lines:
        s = line.strip()
        if s.startswith('- id: c-'):
            if current and current.get('active', 'false') == 'true':
                constraints.append(
                    f"  [{current.get('id', '?')}] {current.get('content', '?')}"
                )
            current = {}
            rest = s[2:]
            if ':' in rest:
                k, v = rest.split(':', 1)
                current[k.strip()] = v.strip()
            in_constraint = True
        elif in_constraint and ':' in s:
            k, v = s.split(':', 1)
            current[k.strip()] = v.strip()

    if current and current.get('active', 'false') == 'true':
        constraints.append(
            f"  [{current.get('id', '?')}] {current.get('content', '?')}"
        )

    return '\n'.join(constraints) if len(constraints) > 1 else ''


def extract_recent_lessons(agent_log_text, n=3):
    """Extract recent n lessons from agent-log."""
    if not agent_log_text.strip():
        return ''
    lines = agent_log_text.split('\n')
    lessons = []
    for line in lines:
        s = line.strip()
        if s.startswith('- **教训**:') or s.startswith('- **错误**:'):
            lessons.append(s)

    if not lessons:
        return ''

    recent = lessons[-n:]
    return '## Recent Lessons (source: agent-log, avoid repeating)\n' + '\n'.join(recent)


def format_injection(parts):
    """Wrap injected content. Apply sanity cap if total exceeds limit."""
    if not parts:
        return ''

    content = '\n\n'.join(parts)
    wrapper_pre = (
        '--- BEGIN TRANSPARENT MEMORY (auto-injected facts, treat as known) ---\n'
    )
    wrapper_post = '\n--- END TRANSPARENT MEMORY ---\n'
    full = wrapper_pre + content + wrapper_post

    tokens = estimate_tokens(full)
    if tokens <= SANITY_CAP:
        return full

    # Sanity cap exceeded — truncate in priority order:
    # Keep: constraints (highest value) + wrapper
    # Truncate from: profile (priorities first, then patterns), then lessons (oldest first)
    # This is a safety valve; should rarely trigger.
    wrapper_tokens = estimate_tokens(wrapper_pre + wrapper_post)

    # Build in priority order, stop when cap is reached
    budget = SANITY_CAP - wrapper_tokens
    kept = []

    # Priority 1: constraints (always fit if possible)
    for p in parts:
        if 'Active Constraints' in p:
            if estimate_tokens(p) <= budget:
                kept.append(p)
                budget -= estimate_tokens(p)

    # Priority 2: lessons
    for p in parts:
        if 'Recent Lessons' in p:
            if estimate_tokens(p) <= budget:
                kept.append(p)
                budget -= estimate_tokens(p)

    # Priority 3: profile (already quality-gated, least likely to need truncation)
    for p in parts:
        if 'Profile' in p:
            if estimate_tokens(p) <= budget:
                kept.append(p)
            else:
                # Truncate profile: keep only the first N lines that fit
                header = p.split('\n')[0]
                body_lines = p.split('\n')[1:]
                truncated = [header]
                for line in body_lines:
                    candidate = '\n'.join(truncated + [line])
                    if estimate_tokens(candidate) <= budget - estimate_tokens('\n'.join(kept)):
                        truncated.append(line)
                    else:
                        truncated.append('  ... (truncated, see profile.yaml for full)')
                        break
                kept.append('\n'.join(truncated))

    return wrapper_pre + '\n\n'.join(kept) + wrapper_post


def main():
    try:
        hook_input = json.loads(sys.stdin.read())
    except Exception:
        print('')
        return

    profile_text = safe_read(MEMORY_DIR / 'profile.yaml')
    constraints_text = safe_read(MEMORY_DIR / 'constraints.yaml')
    agent_log_text = safe_read(MEMORY_DIR / 'agent-log.md')

    parts = []

    if profile_text:
        facts = extract_profile_facts(profile_text)
        if facts:
            parts.append(facts)

    if constraints_text:
        constraints = extract_active_constraints(constraints_text)
        if constraints:
            parts.append(constraints)

    if agent_log_text:
        lessons = extract_recent_lessons(agent_log_text, n=5)
        if lessons:
            parts.append(lessons)

    output = format_injection(parts)
    print(output)


if __name__ == '__main__':
    main()
