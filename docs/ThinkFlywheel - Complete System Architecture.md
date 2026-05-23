---
ThinkFlywheel (知行飞轮): Complete System Architecture

1. System Name and Core Philosophy

Name: ThinkFlywheel (知行飞轮)

Core Philosophy: Every task you complete should make every future task easier. Knowledge without action is dead; action without knowledge is blind; both without memory are wasted. This is not a knowledge
management system or a task manager -- it is a personal compound interest engine for your cognition.

Three design axioms:
1. Action feeds knowledge, knowledge feeds action -- the bidirectional flow is the system's heartbeat
2. Memory is the bridge -- spaced repetition ensures knowledge survives past the task that created it
3. AI does breadth, human does depth -- AI scans, proposes, formats; human judges, decides, creates

---
2. Layered Architecture

+===================================================================+
|  L4: GOVERNANCE LAYER                                             |
|  /health (cross-system lint) + /query (vault-wide search)         |
|  AI scans for: broken links, orphans, progress-health gaps,       |
|  knowledge-action disconnects, contradiction detection            |
+===================================================================+
        |                        |                        |
        v                        v                        v
+-------------------+  +-------------------+  +-------------------+
| L3: TASK LAYER    |  | L2: KNOWLEDGE     |  | L1: MEMORY LAYER  |
| (防弹笔记法)       |  | (LLM Wiki)        |  | (FSRS-6 SR)       |
|                   |  |                   |  |                   |
| Bulletproof Notes |  | Atomic Cards      |  | Spaced Repetition|
| /task /project    |  | /note /ingest     |  | /review           |
| /retro /decide    |  | SCHEMA.md         |  | fsrs_engine.py    |
| /briefing         |  |                   |  |                   |
|                   |  |                   |  |                   |
| "What to do"      |  | "What I know"     |  | "What I remember" |
+-------------------+  +-------------------+  +-------------------+
        ^                        ^                        ^
        |                        |                        |
        +------------------------+------------------------+
                All data flows through Obsidian Vault
                as plain Markdown files under Git

Key insight: This is NOT a stack where higher layers are more important. It is a flywheel where each layer strengthens the others. A task completed generates knowledge (/retro -> /note); knowledge enters
the memory layer (/review); memorized knowledge surfaces during new tasks (/briefing); better-executed tasks generate better knowledge. This is the compound interest engine.

Where the 4 domains integrate:

┌────────────────────────┬────────────────┬────────────────────────────────────────────────────────────────────────────────────────────────────┐
│         Domain         │ Primary Layer  │                                         Integration Points                                         │
├────────────────────────┼────────────────┼────────────────────────────────────────────────────────────────────────────────────────────────────┤
│ 防弹笔记法             │ L3 (Task)      │ 4-element template as universal task container; "问题与吐槽" feeds L2 knowledge extraction         │
├────────────────────────┼────────────────┼────────────────────────────────────────────────────────────────────────────────────────────────────┤
│ LLM Wiki               │ L2 (Knowledge) │ Compilation pattern: AI maintains Cards/, index.md, log.md; /ingest processes raw sources          │
├────────────────────────┼────────────────┼────────────────────────────────────────────────────────────────────────────────────────────────────┤
│ FSRS/Atomic Notes      │ L1 (Memory)    │ fsrs_engine.py from knowledge-mgmt; /review using FSRS-6; SR cards from task insights              │
├────────────────────────┼────────────────┼────────────────────────────────────────────────────────────────────────────────────────────────────┤
│ Agent-PMO (simplified) │ L3+L4          │ /project replaces /initiate+/plan+/monitor as a single personal skill; /health adapts /lint+/query │
└────────────────────────┴────────────────┴────────────────────────────────────────────────────────────────────────────────────────────────────┘

---
3. Core Data Model

3.1 Folder Structure

Vault/
├── SCHEMA.md                # System constitution (types, tags, rules)
├── AGENTS.md                # Agent operational rules
├── index.md                 # Content-oriented index (AI-maintained)
├── log.md                   # Chronological log (AI-appended)
│
├── Tasks/                   # BULLETPROOF TASK NOTES -- the hub
│   ├── active/              # In-progress: one note per task
│   ├── waiting/             # Blocked / waiting on external input
│   └── archived/            # Completed tasks (source for knowledge extraction)
│
├── Cards/                   # KNOWLEDGE CARDS -- the wiki
│   ├── concepts/            # type/concept: definitions, models, frameworks
│   ├── insights/            # type/insight: lessons, patterns, anti-patterns
│   ├── atomics/             # type/atomic: the smallest reusable units (feed SR)
│   └── reading/             # type/reading: processed source summaries
│
├── Projects/                # MULTI-TASK GOALS (personal PMO)
│   ├── active/              # Active goal areas (1 file per goal)
│   └── archived/            # Completed goal areas
│
├── Decisions/               # DECISION LOGS
│   └── DEC-{YYYY}-{NNN}.md  # Structured decision records
│
├── MOCs/                    # MAPS OF CONTENT (AI-maintained indexes)
│   └── MOC-{domain}.md      # Per-domain aggregation
│
├── Reviews/                 # PERIODIC REVIEWS
│   ├── weekly/              # Weekly summaries
│   ├── monthly/             # Monthly retrospectives
│   └── retro/               # Per-task retrospectives (auto-generated)
│
├── Daily/                   # DAILY BRIEFINGS (auto-generated, ephemeral)
│   └── YYYY-MM-DD.md        # Today's context briefing
│
├── Sources/                 # RAW SOURCE MATERIALS (immutable)
│   ├── inbox/               # New, unprocessed
│   └── processed/           # Moved here after /ingest
│
├── Templates/               # Card templates for each type
└── Attachments/             # Images, PDFs, files

3.2 Card Types (6 core, intentionally fewer than knowledge-mgmt's 8)

┌──────────┬─────────────────┬──────────────────┬─────────────────────────────────┬────────────────────────┐
│   Type   │ Frontmatter Tag │    Directory     │             Purpose             │    Template Source     │
├──────────┼─────────────────┼──────────────────┼─────────────────────────────────┼────────────────────────┤
│ Task     │ type/task       │ Tasks/active/    │ Bulletproof 4-element task note │ New (防弹模板)         │
├──────────┼─────────────────┼──────────────────┼─────────────────────────────────┼────────────────────────┤
│ Project  │ type/project    │ Projects/active/ │ Multi-task goal canvas          │ Simplified PMO         │
├──────────┼─────────────────┼──────────────────┼─────────────────────────────────┼────────────────────────┤
│ Atomic   │ type/atomic     │ Cards/atomics/   │ Knowledge unit for SR           │ knowledge-mgmt adapted │
├──────────┼─────────────────┼──────────────────┼─────────────────────────────────┼────────────────────────┤
│ Concept  │ type/concept    │ Cards/concepts/  │ Explanatory knowledge           │ knowledge-mgmt         │
├──────────┼─────────────────┼──────────────────┼─────────────────────────────────┼────────────────────────┤
│ Insight  │ type/insight    │ Cards/insights/  │ Lesson, pattern, anti-pattern   │ New (教训卡)           │
├──────────┼─────────────────┼──────────────────┼─────────────────────────────────┼────────────────────────┤
│ Decision │ type/decision   │ Decisions/       │ Structured decision record      │ New                    │
├──────────┼─────────────────┼──────────────────┼─────────────────────────────────┼────────────────────────┤
│ MOC      │ type/moc        │ MOCs/            │ Map of Content index            │ knowledge-mgmt         │
├──────────┼─────────────────┼──────────────────┼─────────────────────────────────┼────────────────────────┤
│ Review   │ type/review     │ Reviews/         │ Period/task retrospective       │ New                    │
├──────────┼─────────────────┼──────────────────┼─────────────────────────────────┼────────────────────────┤
│ Reading  │ type/reading    │ Cards/reading/   │ Processed source summary        │ knowledge-mgmt adapted │
└──────────┴─────────────────┴──────────────────┴─────────────────────────────────┴────────────────────────┘

3.3 Four-Dimension Tag System

Every card carries these 4 tag dimensions:

type/{card-type}        # What kind of card
domain/{life-area}      # work | life | learning | health | finance | relationship | tech
status/{flow-state}     # Task: todo | doing | waiting | done | archived
                        # Project: active | paused | completed | abandoned
                        # Atomic: new | learning | reviewing | mastered
mastery/{level}         # For atomic cards: 0-new | 1-familiar | 2-comfortable | 3-mastered

3.4 Frontmatter Standard (all cards):

---
type: task
domain: work
status: doing
created: 2026-05-22
updated: 2026-05-22
due: 2026-06-01
mastery: null
source: null
related_tasks: []
related_cards: []
---

---
4. Skill Set: Claude Code Slash Commands

4.1 Overview: 10 skills in 3 groups

EXECUTION GROUP (what you do):
    /task       — Create and manage bulletproof task notes
    /project    — Manage multi-task goals (simplified PMO)
    /briefing   — Generate daily context briefing

KNOWLEDGE GROUP (what you know):
    /ingest     — Process raw source material into wiki
    /note       — Extract atomic cards + wikilinks from dialogue (dual-proposal)
    /query      — Search vault for knowledge, context, history

MEMORY GROUP (what you remember):
    /review     — FSRS-6 spaced repetition
    /retro      — Task retrospective + auto-extraction into knowledge

GOVERNANCE GROUP (system health):
    /health     — Cross-system lint: links, orphans, contradictions, progress
    /decide     — Create structured decision records with vault context

4.2 Detailed Skill Specifications

/task -- Bulletproof Task Note Manager

Trigger: "new task", "create task", "start task", "任务", "新建任务"

Input: Task description (required), Domain (default: work)

Behavior:
1. AI creates Tasks/active/{Task Name}.md with the 4-element template pre-populated:
    - 最终目标 (Ultimate Goal): AI drafts based on task description -- user refines
    - 原始材料堆 (Raw Materials): AI runs /query internally to find related vault content, populates initial references
    - 下一步行动 (Next Actions): AI proposes 2-3 concrete first steps
    - 问题与吐槽 (Issues & Rants): Empty, ready to capture friction
2. AI updates index.md and relevant MOCs
3. Returns the created note content

Key design choice: This is the reverse of knowledge-mgmt's approach. There, /note is the only write channel. Here, /task also writes directly because tasks are NOT knowledge -- they are action containers.
The dual-proposal filtering happens at /retro time when tasks are completed, not at task creation time.

/briefing -- Daily Morning Context

Trigger: "briefing", "morning", "today", "晨报", "今天", "早上好"

Input: None

Behavior:
1. Scan Tasks/active/ for all in-progress tasks
2. Call fsrs_engine.py stats to get due review cards
3. Cross-reference: which due cards are related to which active tasks (via related_cards frontmatter)
4. Check Projects/active/ for goal-level health warnings
5. Generate a structured briefing markdown:
## Today's Context - 2026-05-22

### Active Tasks (priority-ordered)
- [HIGH] Task A -- Next: review draft
- [MEDIUM] Task B -- Next: schedule meeting

### Due Review Cards (cross-referenced to active tasks)
- "SBI Feedback Framework" --> relevant to: Task B
- "Data Viz 3 Principles" --> relevant to: (no active task)

### Project Health
- Goal X: on track (3/5 tasks active, 2 completed this week)
- Goal Y: attention needed (0 active tasks, last updated 12 days ago)

### Historical Warning
- Last time you worked on "API integration" tasks, 3 of 4 had scope creep. Watch for it.
6. Write briefing to Daily/YYYY-MM-DD.md

Why this matters: This is the key "fusion point" where all 3 layers converge into one actionable morning view. It solves the problem all 10 reports identified: review is disconnected from tasks, and tasks
are disconnected from knowledge.

/note -- Knowledge Extraction (Dual-Proposal)

Trigger: "note", "做笔记", "存笔记", "原子笔记"

Input: Scope (all conversation / last discussion / manual selection)

Behavior: Largely REUSED from knowledge-mgmt's /note with modifications:
1. Scan dialogue for knowledge-worthy content
2. Present 研究摘要 (research summary) -- a narrative card
3. Present 双提议 (Dual-Proposal):
    - Proposal 1: Wikilinks to existing Cards (AI suggests, user confirms each)
    - Proposal 2: Atomic Cards to create (AI suggests, user selects which)
4. Execute confirmed writes to Cards/
5. Update MOC indexes
6. If task context exists, add related_tasks: [[task-name]] to created cards

Key modification from knowledge-mgmt: Added automatic related_tasks tagging. When /note is called during a task session, created cards automatically link back to the task. This is the "task anchor" that
knowledge-mgmt is missing.

/review -- Spaced Repetition

Trigger: "review", "复习", "今天复习什么"

Behavior: REUSED directly from knowledge-mgmt's /review:
1. Scan for new type/atomic cards
2. Register them in review_state.json
3. Query fsrs_engine.py for due cards
4. Present cards as Q&A pairs, user self-rates (0-3)
5. Submit ratings back to engine for scheduling

Status: This is the most mature component. The fsrs_engine.py is battle-tested. Minimal adaptation needed.

/project -- Personal Goal Manager (Simplified from agent-pmo)

Trigger: "project", "goal", "目标", "项目"

Input: Goal description, Domain

Behavior: This replaces agent-pmo's 15 skills with ONE skill for personal use:
1. Creates Projects/active/{Project Name}.md with a simplified charter:
## Goal Statement
[One sentence: what success looks like]

## Motivation
[Why this matters now]

## Key Milestones
- [ ] M1: ... (target: YYYY-MM-DD)
- [ ] M2: ...

## Linked Tasks
(List of [[task-names]], AI-populated via backlinks)

## Risk Log
(Accumulated from task "问题与吐槽" entries)

## Progress Pulse
(AI-generated weekly: on-track / at-risk / stalled)
2. AI queries vault for related historical projects/insights, populates initial context
3. Weekly: AI scans linked tasks, updates Progress Pulse
4. Monthly: triggers /retro for this project domain

What was stripped from agent-pmo: /prospect, /bid, /presales, /contract, /change, /acceptance, /payment, /meeting, /work-item (too enterprise). What remains: project charter, milestone tracking, risk log,
progress monitoring -- condensed into one skill.

/retro -- Task/Project Retrospective with Auto-Extraction

Trigger: "retro", "done", "完成", "复盘", "close"

Input: Task or Project name

Behavior: This is the CRITICAL bridge skill -- where task execution feeds knowledge.
1. Read the task/project note, especially "问题与吐槽"
2. AI analyzes: repeated patterns, lessons learned, unexpected outcomes
3. Automatically triggers /note flow with pre-extracted insights:
    - "From this task, I suggest these atomic cards..."
    - User confirms/edits
4. If the task was under a project, updates project's Risk Log
5. Moves task to Tasks/archived/, updates status
6. Writes a retrospective summary to Reviews/retro/
7. Key insight cards enter FSRS-6 review queue

Why this exists: This fills the GAP that both knowledge-mgmt and agent-pmo have. knowledge-mgmt has NOTE but no TASK completion trigger. agent-pmo has /close but NO knowledge extraction. This skill
bridges them.

/query -- Vault Search

Trigger: "query", "find", "search", "查询", "搜索"

Behavior: Similar to knowledge-mgmt's /query:
1. Read index.md first for broad navigation
2. Search vault for relevant cards, tasks, decisions, projects
3. Synthesize answer with [[wikilinks]] as citations
4. Good answers can be saved as new cards (triggers /note flow)

/ingest -- Source Processing

Trigger: "ingest", "process", "read this", "处理", "阅读"

Input: Source file path or URL

Behavior: Simplified from knowledge-mgmt's /read + /insights:
1. Read source material
2. Generate structured summary
3. Flag contradictions with existing vault knowledge
4. Trigger /note flow for knowledge extraction
5. Move source to Sources/processed/
6. Update index.md and log.md

/health -- Cross-System Health Check

Trigger: "health", "check", "体检", "lint"

Behavior: Extends knowledge-mgmt's /lint with cross-system checks:
1. Link health: broken wikilinks, orphan cards, empty MOC sections (from knowledge-mgmt)
2. Knowledge-action disconnect: Cards with type/atomic marked mastery/3-mastered but never referenced by any task
3. Task staleness: Active tasks with no update in 14+ days
4. Project drift: Projects where linked tasks' statuses contradict the progress pulse
5. Domain balance: Over-concentration in one domain (e.g., 80% work, 0% health)
6. SR health: Review backlog size, overdue count, average retention per domain
7. Generates report at Cards/health-reports/

Why this is different from knowledge-mgmt /lint: It does not just check internal wiki consistency. It checks coherence BETWEEN layers -- the "cross-system lint" that DeepSeek-CC identified.

/decide -- Decision Logger

Trigger: "decide", "decision", "决策"

Input: Decision description

Behavior:
1. Creates Decisions/DEC-{YYYY}-{NNN}.md
2. AI pre-populates context: queries vault for related knowledge, past similar decisions
3. Template:
## Decision: [description]

**Date**: YYYY-MM-DD
**Context**: [AI-populated from vault]

**Options Considered**:
- Option A: ... (pros/cons)
- Option B: ...

**Choice**: [option]
**Rationale**: [why this one]
**Expected Outcome**: [what success looks like]

**Review Checkpoint**: [date, auto-added to FSRS]
4. Decision review checkpoints enter the SR queue (review actual vs expected outcomes)

---
5. The "Fusion Points": Exactly How 4 Domains Combine

Fusion Point 1: Task Creation (/task)

防弹笔记法 provides: 4-element template as the container
LLM Wiki provides:    Auto-query of vault for related knowledge → fills "原始材料堆"
knowledge-mgmt:       Related atomic cards linked automatically
Result:               You never start a task from a blank page

Fusion Point 2: Daily Briefing (/briefing)

防弹笔记法 provides:  Active task list with next actions
FSRS-6 provides:      Due review cards with topics
LLM Wiki provides:    Cross-reference: which cards are relevant to which tasks
Agent-PMO (simplified): Project health pulse warnings
Result:               One page shows you what to DO, what to REVIEW, and what to WATCH

Fusion Point 3: Task Completion (/retro)

防弹笔记法 provides:  "问题与吐槽" as raw material (friction, pain, lessons)
LLM Wiki provides:    Cross-reference: has this pattern appeared before?
knowledge-mgmt:       /note dual-proposal: extract atomic cards from lessons
FSRS-6:               New cards enter review queue
Result:               Pain becomes asset. Each completed task strengthens your knowledge base.

Fusion Point 4: Source Processing (/ingest)

LLM Wiki provides:    Compilation pattern: read once, integrate into wiki
knowledge-mgmt:       /read → /note pipeline adapted
FSRS-6:               Key concepts extracted as atomic cards
防弹笔记法:            New knowledge auto-linked to relevant active tasks
Result:               Reading feeds actions, not just curiosity

Fusion Point 5: Decision Making (/decide)

Agent-PMO provides:   Structured decision records (adapted from /change)
LLM Wiki provides:    Historical context from vault
FSRS-6 provides:      Decision review reminders at checkpoints
Result:               Decision quality tracked over time. You learn your own biases.

Fusion Point 6: Health Check (/health)

knowledge-mgmt:       Link health, tag compliance, clipping stock from /lint
LLM Wiki provides:    Contradiction detection between cards
Agent-PMO provides:   Progress-vs-plan deviation
防弹笔记法:            Task staleness detection
Result:               System-level visibility. Not just "is my wiki healthy?" but "is my life system coherent?"

---
6. Key Design Decisions (Where 10 Reports Disagreed)

Decision 1: System Scope -- 6 task types, not 15 skills

All 10 reports agreed: agent-pmo's 15 skills are too many for personal use. The disagreement was whether to keep 4, 6, or 8 skills.

Decision: 10 skills total in 4 groups. Rationale:
- 4 would lose the project layer entirely (many reports argued to keep some PMO)
- 8 would be closer to enterprise but still excessive
- 10 gives us: execution (3) + knowledge (3) + memory (2) + governance (2) -- each group is optional and adoptable independently

Decision 2: Starting Point -- Bulletproof Notes First

Disagreement: infrastructure-first (DeepSeek) vs. Bulletproof-first (Claude, Kimi, ChatGPT)

Decision: Bulletproof Notes first (Phase 1 is 2 weeks of ONLY /task). Rationale:
- The user already has LLM analysis but NO practice with the system
- Bulletproof notes produce immediate value (you get things done)
- Knowledge systems need content to be useful -- tasks generate that content
- This follows Esor's own philosophy: "Don't design the perfect system first. Start doing."

Decision 3: AI Autonomy -- Dual-Proposal with Reduced Friction

Disagreement: full auto (Karpathy) vs mandatory confirmation (knowledge-mgmt) vs middle ground

Decision: Tiered autonomy. Three levels based on risk:
- AI autonomous: MOC updates, index updates, log append, Clipping move, health report generation, daily briefing generation, project progress pulse updates
- AI proposes, human confirms: Atomic card creation, wikilink additions to existing cards, retro card extraction (dual-proposal preserved)
- Human only: Task priority ordering, project goal setting, decision making, schema changes

This is MORE autonomous than knowledge-mgmt (adds autonomous MOC, index, log, and briefing) but LESS autonomous than Karpathy's vision (human still gates all knowledge writes).

Decision 4: The Spaced Repetition Gap -- Must Include

Disagreement: Some reports wanted SR integrated, others thought wiki queries could replace it.

Decision: FSRS-6 is NON-NEGOTIABLE. Rationale:
- Both Karpathy's wiki and agent-pmo have NO SR -- this is a genuine gap
- knowledge-mgmt's author explicitly argues: "A beautifully compiled but never-remembered wiki is wasted"
- SR is what makes the system a "personal asset" rather than an "AI asset" -- it pushes knowledge into YOUR brain
- ChatGPT's report identified this as the core "knowledge -> long-term memory" missing link

Decision 5: Folder Structure -- English with Chinese Namespaces

Disagreement: agent-pmo uses Chinese directories; knowledge-mgmt uses English.

Decision: English directory names with Chinese display names via Obsidian aliases. Rationale:
- English names work better with CLI tools and scripts
- Chinese names work better for human browsing (Obsidian aliases bridge this)
- This is the same approach knowledge-mgmt uses (with the exception of its "已研究" directory)

Decision 6: /task as Additional Write Channel

Disagreement: knowledge-mgmt mandates /note as the ONLY write channel. Some reports suggested /task should also write.

Decision: /task writes task notes directly; knowledge cards still go through /note dual-proposal. Rationale:
- Tasks are action containers, not knowledge -- they don't need the same quality gate
- Requiring dual-proposal for task creation adds friction that defeats the purpose (防弹笔记 is about speed and momentum)
- The quality gate applies at /retro time -- when tasks complete and insights are extracted

---
7. Implementation Roadmap

Phase 0: Foundation (Day 0-3)

What to build:
1. Create Obsidian vault with folder structure from Section 3.1
2. Copy fsrs_engine.py from knowledge-mgmt/review/scripts/ into the new vault's .obsidian/scripts/
3. Write SCHEMA.md (card types, tag system, naming conventions, permissions)
4. Write AGENTS.md (agent rules: when to write, when to propose, when to be silent)
5. Create all 6 card templates in Templates/ as Obsidian templates
6. Set up index.md and log.md as empty files (AI will populate)
7. Create .claude/rules/ files (iron-laws, autonomy, writing, workflows, card-types, structure, obsidian-cli) for automatic ground-truth rule loading
8. Install kepano/obsidian-skills in Claude Code for correct Obsidian CLI syntax and OFM format support

Verification: AI automatically follows operational rules without manual file reads; can correctly identify card types and directory conventions.

Phase 1: Bulletproof Notes (Week 1-2)

What to build: /task and /briefing skills

What to do: Use the system for 2 weeks with ONLY these two skills. Create task notes for everything. Write daily briefings. Build the muscle memory of "task = one note, 4 elements."

Success metric: At the end of each day, you know exactly what tomorrow's first action is.

Phase 2: Knowledge Pipeline (Week 3-4)

What to build: /note, /ingest, /query skills

What to do: Start processing source materials. After completing Phase 1 tasks, manually run /note to extract insights. Begin building the card library.

Success metric: 30+ atomic cards in vault, at least 5 generated from completed tasks.

Phase 3: Memory Layer (Week 5-6)

What to build: /review skill (integrate fsrs_engine.py)

What to do: Start daily review habit. Cross-reference review cards with active tasks in /briefing.

Success metric: 5-10 minute daily review habit established. Review cards appearing in morning briefing.

Phase 4: Project Layer + Bidirectional Flow (Week 7-8)

What to build: /project, /retro, /decide skills

What to do: This is where the system "lights up." Create project notes for multi-task goals. Use /retro to close tasks with knowledge extraction. Log decisions.

Success metric: One complete task lifecycle: create task -> execute -> retro extract knowledge -> review knowledge -> knowledge surfaces in new task.

Phase 5: Governance + Refinement (Week 9-12)

What to build: /health skill

What to do: Start weekly health checks. Refine SCHEMA.md based on real usage. Personalize templates. Tune FSRS parameters.

Success metric: Weekly health check identifies at least one actionable improvement.

---
8. How This Differs From and Improves Upon Existing Systems

vs knowledge-mgmt:

┌─────────────────────┬──────────────────────────────────────┬─────────────────────────────────────────────────────┐
│       Aspect        │            knowledge-mgmt            │                    ThinkFlywheel                    │
├─────────────────────┼──────────────────────────────────────┼─────────────────────────────────────────────────────┤
│ Scope               │ Knowledge only                       │ Knowledge + Task + Project + Life                   │
├─────────────────────┼──────────────────────────────────────┼─────────────────────────────────────────────────────┤
│ Task layer          │ None                                 │ Bulletproof 4-element template as hub               │
├─────────────────────┼──────────────────────────────────────┼─────────────────────────────────────────────────────┤
│ Write channel       │ /note only                           │ /task for action containers, /note for knowledge    │
├─────────────────────┼──────────────────────────────────────┼─────────────────────────────────────────────────────┤
│ Daily integration   │ Separate /review call                │ /briefing merges tasks + review + projects          │
├─────────────────────┼──────────────────────────────────────┼─────────────────────────────────────────────────────┤
│ Completion workflow │ None (knowledge has no "completion") │ /retro closes tasks AND extracts knowledge          │
├─────────────────────┼──────────────────────────────────────┼─────────────────────────────────────────────────────┤
│ Project tracking    │ None                                 │ Simplified /project                                 │
├─────────────────────┼──────────────────────────────────────┼─────────────────────────────────────────────────────┤
│ Life coverage       │ Knowledge domains only               │ work, life, learning, health, finance, relationship │
├─────────────────────┼──────────────────────────────────────┼─────────────────────────────────────────────────────┤
│ Card types          │ 8 (all knowledge-focused)            │ 6 + task/project/decision/review types              │
└─────────────────────┴──────────────────────────────────────┴─────────────────────────────────────────────────────┘

vs agent-pmo:

┌──────────────────────┬───────────────────────────────────────┬─────────────────────────────────────────────────────────────────┐
│        Aspect        │               agent-pmo               │                          ThinkFlywheel                          │
├──────────────────────┼───────────────────────────────────────┼─────────────────────────────────────────────────────────────────┤
│ Skill count          │ 15 skills                             │ 10 skills                                                       │
├──────────────────────┼───────────────────────────────────────┼─────────────────────────────────────────────────────────────────┤
│ Target user          │ Enterprise PM/Pre-sales               │ Individual (work + life)                                        │
├──────────────────────┼───────────────────────────────────────┼─────────────────────────────────────────────────────────────────┤
│ Spaced repetition    │ None (removed it)                     │ FSRS-6 core feature                                             │
├──────────────────────┼───────────────────────────────────────┼─────────────────────────────────────────────────────────────────┤
│ Knowledge extraction │ /close generates project summary only │ /retro extracts atomic cards from task friction                 │
├──────────────────────┼───────────────────────────────────────┼─────────────────────────────────────────────────────────────────┤
│ Morning workflow     │ None                                  │ /briefing daily context                                         │
├──────────────────────┼───────────────────────────────────────┼─────────────────────────────────────────────────────────────────┤
│ Decision tracking    │ Implicit in /change                   │ Explicit /decide with FSRS review checkpoints                   │
├──────────────────────┼───────────────────────────────────────┼─────────────────────────────────────────────────────────────────┤
│ Directory language   │ Chinese                               │ English with Obsidian Chinese aliases                           │
├──────────────────────┼───────────────────────────────────────┼─────────────────────────────────────────────────────────────────┤
│ Life management      │ Not covered                           │ domain/life, domain/health, domain/finance, domain/relationship │
└──────────────────────┴───────────────────────────────────────┴─────────────────────────────────────────────────────────────────┘

The core improvement:

knowledge-mgmt is a knowledge compiler -- it processes sources into cards, but has no connection to action.

agent-pmo is a project compiler -- it tracks projects through stages, but has no memory or personal life dimension.

ThinkFlywheel is a life compiler -- it compiles your actions, knowledge, decisions, and projects into a single coherent system where everything strengthens everything else. The fundamental gap both
predecessors share (disconnect between knowledge and action) is addressed at the architectural level through the bidirectional flow between /task and /note via /retro.