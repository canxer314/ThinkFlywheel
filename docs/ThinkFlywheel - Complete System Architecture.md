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

Who it's for:
- Individual knowledge workers (developers, researchers, PMs, founders) juggling multiple domains
- People who've tried Obsidian/Tana/Notion for PKM but found "knowing ≠ doing"
- Willing to invest 8-12 weeks of progressive adoption rather than one-shot deployment
- Comfortable with terminal, Git, and basic Python

---

2. Layered Architecture

+===================================================================+
|  L4: GOVERNANCE LAYER                                             |
|  /health (cross-system lint) + /decide (decision logging)         |
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
| /retro /flow      |  | /query            |  | fsrs_engine.py    |
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
├── Inbox/                   # Fleeting thought capture -- unclassified raw ideas, awaiting triage
│
├── Tasks/                   # BULLETPROOF TASK NOTES -- the hub
│   ├── active/              # In-progress: one note per task
│   ├── waiting/             # Blocked / waiting on external input
│   └── archived/            # Completed tasks (source for knowledge extraction)
│
├── Flows/                   # PERMANENT TASK NOTES (SOP/process library)
│   ├── work/                # Work-related processes
│   ├── life/                # Life-related processes
│   └── learning/            # Learning-related processes
│
├── Cards/                   # KNOWLEDGE CARDS -- the wiki
│   ├── concepts/            # type/concept: definitions, models, frameworks
│   ├── insights/            # type/insight: lessons, patterns, anti-patterns
│   ├── atomics/             # type/atomic: the smallest reusable units (feed SR)
│   ├── reading/             # type/reading: processed source summaries
│   └── health-reports/      # /health generated reports
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

3.2 Card Types (10 types)

┌──────────┬─────────────────┬──────────────────┬─────────────────────────────────┬────────────────────────┐
│   Type   │ Frontmatter Tag │    Directory     │             Purpose             │    Template Source     │
├──────────┼─────────────────┼──────────────────┼─────────────────────────────────┼────────────────────────┤
│ Task     │ type/task       │ Tasks/active/    │ Bulletproof 4-element task note │ New (防弹模板)         │
├──────────┼─────────────────┼──────────────────┼─────────────────────────────────┼────────────────────────┤
│ Project  │ type/project    │ Projects/active/ │ Multi-task goal canvas          │ Simplified PMO         │
├──────────┼─────────────────┼──────────────────┼─────────────────────────────────┼────────────────────────┤
│ Flow     │ type/flow       │ Flows/{domain}/  │ Permanent SOP, never closes     │ New (永久型任务)        │
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

3.3 Card Lifecycles

| Type     | Lifecycle States                                              |
|----------|---------------------------------------------------------------|
| task     | todo → doing → waiting → done → archived                     |
| project  | active → paused → completed → abandoned                       |
| flow     | active → deprecated (never "done")                            |
| atomic   | new → learning → reviewing → mastered                         |
| concept  | draft → stable → superseded                                   |
| insight  | draft → stable → superseded                                   |
| decision | pending → made → reviewed → overturned                        |
| moc      | active → stale                                                |
| reading  | processed → extracted                                         |
| review   | draft → final                                                |

3.4 Four-Dimension Tag System

Every card carries these 4 tag dimensions:

type/{card-type}        # What kind of card
domain/{life-area}      # work | life | learning | health | finance | relationship | tech
status/{flow-state}     # See lifecycle table above
mastery/{level}         # For atomic cards: 0-new | 1-familiar | 2-comfortable | 3-mastered

3.5 Frontmatter Standard (all cards):

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

4.1 Overview: 12 skills in 4 groups

EXECUTION GROUP (what you do):
    /task       — Create and manage bulletproof task notes
    /project    — Manage multi-task goals (simplified PMO)
    /flow       — Create permanent SOP/process notes
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

TOOLING GROUP (platform integration):
    /meeting    — Meeting transcription → structured minutes + action tracking

4.2 Skill Dependency Graph

                    /briefing (晨报) ← daily anchor, the only mandatory daily run
                   /    |    \
                  v     v     v
              /task   /review   /project
             (执行)   (复习)    (追踪)
                |       ^         |
                v       |         v
             /retro → /note ← /decide
             (复盘)   (知识)   (决策)
                |       |
                v       v
             /ingest  /query
             (处理)   (搜索)

            /health (体检) ← weekend governance
            /flow (永久型SOP) ← reusable experience library
            /meeting (会议纪要) ← structured meeting processing

4.3 Daily Rhythm

Morning → /briefing    (唯一每天必跑)
Day    → /task         (有新任务就创建)
       → /ingest       (读到好文章就处理)
       → /note         (对话中学到东西就提取)
Evening→ /retro        (完成任务做复盘)
       → /review       (5-10 分钟复习到期卡片)
Weekend→ /health full  (全面体检)

4.4 Skill Complexity & Engineering Maturity

| Skill      | Complexity | Steps | Failure Scenarios | Anti-Patterns |
|------------|-----------|-------|-------------------|---------------|
| /task      | Moderate  | 5     | 6                 | 6             |
| /briefing  | Complex   | 6     | ✓                 | ✓             |
| /retro     | Complex   | 6     | 6                 | 5             |
| /review    | Simple    | 5     | ✓                 | ✓             |
| /note      | Moderate  | —     | ✓                 | ✓             |
| /ingest    | Moderate  | —     | ✓                 | ✓             |
| /query     | Moderate  | 4     | ✓                 | ✓             |
| /project   | Moderate  | —     | ✓                 | ✓             |
| /health    | Complex   | 10    | ✓                 | ✓             |
| /decide    | Moderate  | —     | ✓                 | ✓             |
| /flow      | Moderate  | 4     | 5                 | 3             |
| /meeting   | Moderate  | —     | ✓                 | ✓             |

Every SKILL.md follows a uniform engineering template:
- Gate check (e.g. /task Step 0: four-filter pre-flight)
- Step-by-step pipeline with explicit inputs/outputs per step
- Failure handling table (5-6 boundary scenarios with recovery actions)
- Anti-pattern blacklist (common LLM mistakes with "why" + "correct approach")

4.5 Detailed Skill Specifications

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

Gate check (Step 0): Before creating, AI validates against Esor's four filters:
1. Action commitment: is the user really investing time in this?
2. Concrete deliverable: what verifiable output at completion?
3. Multi-step: does it need 2+ steps? (single-step actions → just do it)
4. Information integration: does it require pulling from multiple sources?

If the idea fails these filters but is worth keeping → write to Inbox/ instead, for later triage.

/briefing -- Daily Morning Context

Trigger: "briefing", "morning", "today", "晨报", "今天", "早上好"

Input: None

Behavior:
1. Scan Tasks/active/ for all in-progress tasks
2. Call fsrs_engine.py stats to get due review cards
3. Cross-reference: which due cards are related to which active tasks (via related_cards frontmatter)
4. Check Projects/active/ for goal-level health warnings
5. Generate a structured briefing markdown with sections:
   - Today's Focus (1-3 most important items)
   - Active Tasks (priority-ordered)
   - Due Review Cards (cross-referenced to active tasks)
   - Project Health
   - Historical Warnings (similar past tasks' pitfalls)
   - Inbox Count (unprocessed fleeting thoughts)
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
2. Register them in review_state.json via fsrs_engine.py bulk_register
3. Query fsrs_engine.py due for scheduled cards (mixed new/review, default 50/50)
4. Present cards, user self-rates (1=Again, 2=Hard, 3=Good, 4=Easy)
5. Submit ratings back to engine via fsrs_engine.py record for scheduling

Status: This is the most mature component. The fsrs_engine.py is battle-tested. Minimal adaptation needed.

/retro -- Task/Project Retrospective with 3-Way Reflux (三向回流)

Trigger: "retro", "done", "完成", "复盘", "close"

Input: Task or Project name

Behavior: This is the CRITICAL bridge skill -- where task execution feeds knowledge.
1. Read the task/project note, especially "问题与吐槽"
2. AI analyzes: repeated patterns, lessons learned, unexpected outcomes
3. Cross-task pattern detection: search same-domain historical tasks for recurring friction
4. Three-way knowledge distribution (三向回流):
    - Path 1: Universal methods → Cards/atomics/ + Cards/insights/ (atomic cards via /note dual-proposal)
    - Path 2: Process-level experience → Write back to Flows/{domain}/ (update steps/pitfalls, increment version)
    - Path 3: Project-level insight → Write back to Projects/active/ (update experience zone)
5. Moves task to Tasks/archived/, updates status
6. Writes a retrospective summary to Reviews/retro/

Why this exists: This fills the GAP that both knowledge-mgmt and agent-pmo have. knowledge-mgmt has NOTE but no TASK completion trigger. agent-pmo has /close but NO knowledge extraction. This skill
bridges them. The 3-way reflux solves the core defect of almost all task systems: experience stays trapped inside individual tasks, never reusable across tasks.

/query -- Vault Search

Trigger: "query", "find", "search", "查询", "搜索"

Behavior: Similar to knowledge-mgmt's /query:
1. Read index.md first for broad navigation
2. Search vault for relevant cards, tasks, decisions, projects
3. Synthesize answer with [[wikilinks]] as citations
4. Good answers can be saved as new cards (triggers /note flow)

Search strategies (by priority):
1. Exact title match → 2. Tag filtering (domain + keyword) → 3. Full-text search → 4. Link expansion (follow wikilinks 2 hops)

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

Processing depths:
- quick (default): core thesis + key evidence + "so what"
- deep: quick + vault cross-reference + contradiction detection + active task linkage

/project -- Personal Goal Manager (Simplified from agent-pmo)

Trigger: "project", "goal", "目标", "项目"

Input: Goal description, Domain

Behavior: This replaces agent-pmo's 15 skills with ONE skill for personal use:
1. Creates Projects/active/{Project Name}.md with: Goal Statement, Motivation, Key Milestones, Linked Tasks, Risk Log, Progress Pulse
2. AI queries vault for related historical projects/insights
3. Weekly: AI scans linked tasks, updates Progress Pulse (🟢 on-track / ⚠️ at-risk / 🔴 stalled)
4. Tasks auto-linked via domain matching or manual project field

/flow -- Permanent SOP/Process Notes

Trigger: "flow", "流程", "SOP", "建立流程"

Input: Process name, Domain, Trigger condition (optional)

Behavior:
1. Creates Flows/{domain}/{Name}.md — a permanent template, never archived
2. If historical similar tasks exist, extracts common steps/pitfalls as initial content
3. Trigger conditions (weekly-fri, monthly-1, on-demand) activate via /briefing
4. Experience回流 from /retro: each completed task using this flow feeds back improvements

Key distinction from task: Flow has no "done" state. It's the meta-task — "how to do this kind of thing."

/health -- Cross-System Health Check

Trigger: "health", "check", "体检", "lint"

Behavior: Extends knowledge-mgmt's /lint with cross-system checks:
quick mode (6 checks): broken links, stale tasks (14+ days), review backlog, project anomalies, orphan cards, empty MOC sections
full mode (+4 checks): knowledge-action disconnect, domain balance (7 domains), contradiction detection, traceability completeness

Scoring dimensions (100 points total):
Link health (20) + Task vitality (20) + Knowledge-action alignment (20) + Memory retention (15) + Domain balance (10) + Traceability (10) + Structural integrity (5)

/decide -- Decision Logger

Trigger: "decide", "decision", "决策"

Input: Decision description

Behavior:
1. Creates Decisions/DEC-{YYYY}-{NNN}.md
2. AI pre-populates context: queries vault for related knowledge, past similar decisions
3. Template includes: Context, Options (pros/cons/risks/worst-case), Choice + Rationale + Key assumptions, Expected outcome
4. Decision review checkpoints enter FSRS queue (30 days later)
5. On review: compare actual vs expected outcomes; overturned decisions → create insight card

/meeting -- Meeting Processing

Trigger: "meeting", "会议", "会议纪要", "转录"

Behavior:
1. Process meeting transcript/notes
2. Create structured minutes in Cards/reading/ with subtype: meeting
3. Extract: decisions, action items (→ /task), risks, follow-ups

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

Decision 1: System Scope — 12 skills, not 15

All 10 reports agreed: agent-pmo's 15 skills are too many for personal use. The disagreement was whether to keep 4, 6, or 8 skills.

Decision: 12 skills total in 4 groups + tooling. Rationale:
- 4 would lose the project layer entirely (many reports argued to keep some PMO)
- 8 would be closer to enterprise but still excessive
- 12 gives us: execution (4) + knowledge (3) + memory (2) + governance (2) + tooling (1) — each group is optional and adoptable independently

Decision 2: Starting Point — Bulletproof Notes First

Disagreement: infrastructure-first (DeepSeek) vs. Bulletproof-first (Claude, Kimi, ChatGPT)

Decision: Bulletproof Notes first (Phase 1 is 2 weeks of ONLY /task). Rationale:
- The user already has LLM analysis but NO practice with the system
- Bulletproof notes produce immediate value (you get things done)
- Knowledge systems need content to be useful -- tasks generate that content
- This follows Esor's own philosophy: "Don't design the perfect system first. Start doing."

Decision 3: AI Autonomy — Dual-Proposal with Reduced Friction

Disagreement: full auto (Karpathy) vs mandatory confirmation (knowledge-mgmt) vs middle ground

Decision: Tiered autonomy. Three levels based on risk:
- AI autonomous: MOC updates, index updates, log append, Clipping move, health report generation, daily briefing generation, project progress pulse updates, inbox capture
- AI proposes, human confirms: Atomic card creation, wikilink additions to existing cards, retro card extraction (dual-proposal preserved)
- Human only: Task priority ordering, project goal setting, decision making, schema changes

This is MORE autonomous than knowledge-mgmt (adds autonomous MOC, index, log, and briefing) but LESS autonomous than Karpathy's vision (human still gates all knowledge writes).

Decision 4: The Spaced Repetition Gap — Must Include

Disagreement: Some reports wanted SR integrated, others thought wiki queries could replace it.

Decision: FSRS-6 is NON-NEGOTIABLE. Rationale:
- Both Karpathy's wiki and agent-pmo have NO SR -- this is a genuine gap
- knowledge-mgmt's author explicitly argues: "A beautifully compiled but never-remembered wiki is wasted"
- SR is what makes the system a "personal asset" rather than an "AI asset" -- it pushes knowledge into YOUR brain
- ChatGPT's report identified this as the core "knowledge -> long-term memory" missing link

Decision 5: Folder Structure — English with Chinese Namespaces

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

Decision 7: Fleeting Thought Capture — Inbox without Automation

Disagreement: GTD-style universal inbox vs. direct-to-task vs. no inbox at all.

Decision: Add Inbox/ directory as a lightweight capture zone with no dedicated skill. Rationale:
- Some thoughts are too vague for /task (fail the four-filter gate check) or /note (unverified, unprocessed)
- Writing directly to Inbox/ keeps capture friction near zero — user just speaks the thought
- Triage is manual, on the user's own schedule: convert to /task, /note, or discard
- No automation, no new command — just a directory, a template, and a convention

---
7. Implementation Roadmap

Phase 0: Foundation (Day 0-3)

What to build:
1. Create Obsidian vault with folder structure from Section 3.1
2. Copy fsrs_engine.py from knowledge-mgmt/review/scripts/ into the new vault's .obsidian/scripts/
3. Write SCHEMA.md (card types, tag system, naming conventions, permissions)
4. Write AGENTS.md (agent rules: when to write, when to propose, when to be silent)
5. Create all card templates in Templates/ as Obsidian templates
6. Set up index.md and log.md as empty files (AI will populate)
7. Create .claude/rules/ files (iron-laws, autonomy, writing, workflows, card-types, structure, obsidian-cli, toolcalling, execute-env) for automatic ground-truth rule loading
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

What to build: /project, /retro, /decide, /flow skills

What to do: This is where the system "lights up." Create project notes for multi-task goals. Use /retro to close tasks with knowledge extraction. Log decisions. Build permanent SOPs with /flow.

Success metric: One complete task lifecycle: create task -> execute -> retro extract knowledge -> review knowledge -> knowledge surfaces in new task.

Phase 5: Governance + Refinement (Week 9-12)

What to build: /health skill

What to do: Start weekly health checks. Refine SCHEMA.md based on real usage. Personalize templates. Tune FSRS parameters.

Success metric: Weekly health check identifies at least one actionable improvement.

---
8. Five Iron Laws

These are non-negotiable constraints for AI agents operating on the vault. Violation = failure.

| # | Law                          | Constraint                                                               | Rationale                                                   |
|---|------------------------------|--------------------------------------------------------------------------|-------------------------------------------------------------|
| 1 | 知识写入双提议                | atomic/concept/insight creation requires human confirmation              | Knowledge is a cognitive asset; AI has no independent judgment |
| 2 | 不删卡片，只归档              | Mark status archived/superseded, never delete files                      | Data is never lost; state is always traceable               |
| 3 | 不重组文件结构                | Never move user-placed files; organize via wikilinks, not physical paths | MOC and wikilinks are the organization layer               |
| 4 | 溯源链不断                    | reading→source and atomic→source must always be populated                | Every card traces back to its origin                        |
| 5 | SCHEMA 变更审批               | Show diff + rationale + get confirmation before modifying the constitution | Safe evolution gate for the system                          |

---
9. Technical Stack Deep Dive

9.1 Obsidian — Why It's a Mandatory Dependency

Obsidian provides the foundational platform, not just an editor:

CLI (≥ 1.12): 100+ commands via IPC for vault file operations
├── create/read/append/delete/move (auto-syncs wikilinks)
├── property:set/read/remove (YAML frontmatter operations)
├── search/search:context (full-text search)
├── backlinks/links/unresolved/orphans (link graph queries)
└── tasks/tags (structured queries)

Obsidian Flavored Markdown (OFM):
├── [[wikilink]]   → bidirectional links are the core organization primitive
├── ![[embed]]     → embed other cards inline
├── > [!callout]   → structured callout blocks
└── ---frontmatter → YAML metadata drives all queries and indexes

Critical constraint: ALL vault file operations (create/read/modify/move/delete) MUST go through the obsidian CLI. Direct file access via Write/Edit/Bash on .md files is forbidden. This ensures wikilink synchronization and frontmatter validation by Obsidian's internal API.

Plugin ecosystem:
├── Dataview    → dynamic tables in MOCs and health reports from frontmatter
└── Web Clipper → web page capture into Sources/inbox/

9.2 FSRS-6 Spaced Repetition Engine

vault/.obsidian/scripts/fsrs_engine.py (629 lines, pure Python stdlib — zero external dependencies):

Commands:
├── due           → fetch due cards (mixed new/review, default 50/50 ratio)
├── record        → record rating (Again/Hard/Good/Easy) and update state
├── register      → register a single new card
├── bulk_register → batch register from stdin JSON (/review scans vault)
├── record_session→ log a review session summary
├── retire        → remove card from review pool (keep in state)
└── stats         → print statistics (by_state, due_today, rating_distribution, etc.)

Core algorithm:
├── 21 default parameters (w[0]..w[20]) — FSRS-6 official defaults
├── Power-law forgetting curve: R(t,S) = (1 + factor × t/S)^(-w20)
│   factor = 0.9^(-1/w20) - 1
├── Difficulty update (mean-reverting with linear damping):
│   D' = D + delta_D × (10-D)/9, then D'' = w[7]×D₀(4) + (1-w[7])×D'
├── Stability after success (with hard_penalty for rating=2, easy_bonus for rating=4):
│   S' = S × (e^w[8] × (11-D)^w[9] × S^(-w[10]) × (e^(w[11]×(1-R))-1) × penalty × bonus + 1)
├── Stability after forgetting (post-lapse, never exceeds previous stability):
│   S' = w[11] × D^(-w[12]) × ((S+1)^w[13]-1) × e^(w[14]×(1-R))
├── next_interval: invert forgetting curve to find t where R(t,S) = target_retention
└── Atomic write: tempfile.mkstemp + os.replace (no partial writes)

State file: .obsidian/review_state.json (JSON)
├── cards: { id: { title, content_snippet, state, difficulty, stability, due_date, reps, lapses, review_log[] } }
├── params: { w[], target_retention, max_interval_days }
├── scan_history: { last_scan, known_card_ids[] }
└── session_history[]

9.3 Claude Code as AI Runtime

All ThinkFlywheel AI behavior runs through Claude Code slash commands. Each skill = one SKILL.md:
- Invocation (trigger words)
- Parameter schema (YAML frontmatter)
- Behavioral specification (step-by-step pipeline)
- Failure handling table (scenarios → recovery actions)
- Anti-pattern blacklist (# → anti-pattern → why → correct approach)

The 9 rule files in vault/.claude/rules/ auto-load as ground truth at session start. The AI doesn't need to manually read them — they are always in context.

9.4 Technology Choices Summary

| Component         | Technology                   | Rationale                                            |
|-------------------|------------------------------|------------------------------------------------------|
| Data format       | Markdown + YAML frontmatter  | Human-readable, Git-diffable, AI-parseable           |
| Version control   | Git                          | Full history, traceable, rollback                    |
| Search            | Obsidian CLI + index.md      | Dual track: CLI for precision, index.md for navigation |
| Spaced repetition | FSRS-6                       | 30%+ more accurate than SM-2; open standard          |
| Scripting         | Python 3.8+ stdlib           | Zero external deps, cross-platform                   |
| Shell             | PowerShell 7 (Win) / Bash    | Platform-adaptive                                     |

---
10. Engineering Design Patterns & Conventions

10.1 Core Principles

1. "AI does breadth, human does depth" — AI scans, proposes, formats, indexes; human judges, decides, creates. The theoretical foundation of the 3-tier autonomy model.

2. Files as database — No SQL/NoSQL. All data stored as Markdown files, organized via wikilinks, structured via YAML frontmatter. Git provides version history.

3. "Don't delete, just archive" — Iron Law 2 ensures information is never lost. This reduces the blast radius of AI errors — worst case is creating extra cards, not destroying data.

4. Dual-proposal mechanism — "Show first, confirm before write" for all knowledge cards. AI does the breadth work of scanning and proposing; human does the depth work of selecting.

5. Tasks are not knowledge — /task writes directly (no dual-proposal needed) because tasks are action containers, not cognitive assets. The quality gate is deferred to /retro.

6. Progressive adoption — 5 phases over 8-12 weeks. Start with /task + /briefing, add one skill per phase. Not "install and use everything day one."

10.2 Traceability Chain

Sources/inbox → /ingest → Cards/reading/ (type/reading)
                                ↓ /note extract
                         Cards/atomics/ (type/atomic)

Tasks/active/ → /retro → Cards/insights/ (type/insight)
                              ↓ /note extract
                         Cards/atomics/ (type/atomic)

- reading.source → backlinks to Sources file
- atomic.source → backlinks to its origin reading, insight, or task
- Combined with agentmemory commit-context, even the git history traces back to the session and task that produced each change

10.3 Index Consistency

Every write operation synchronously updates:
- index.md — content-oriented catalog
- log.md — chronological append-only record
- Relevant MOC — domain-level aggregation

This prevents state drift across multiple AI operations and sessions.

---
11. Integration Layer: Three-System Memory Architecture

11.1 Memory Division

┌─────────────────────────────────────┐
│ ThinkFlywheel — Human external brain │
│ "What I know, do, and remember"      │
│ Storage: Obsidian vault (MD + Git)   │
├─────────────────────────────────────┤
│ planning-with-files — Agent RAM     │
│ "What step am I on, what's next"    │
│ Storage: .planning/ directory        │
├─────────────────────────────────────┤
│ agentmemory — Agent long-term memory│
│ "What did we discuss last time"     │
│ Storage: MCP plugin persistence      │
└─────────────────────────────────────┘

11.2 Four Collaboration Points

1. Task execution loop:
   /task defines "what to do" → planning-with-files task_plan.md breaks into phases
   → on completion, /retro extracts knowledge back into ThinkFlywheel

2. Dual session recovery (after /clear or restart):
   agentmemory handoff recovers conversation semantics ("what were we talking about")
   + planning-with-files session-catchup recovers execution state ("what step were we on")

3. Bidirectional knowledge deposit:
   Human experience → ThinkFlywheel FSRS (pushed into human brain)
   Agent experience → agentmemory memory_save (recalled for future similar tasks)

4. Code provenance:
   agentmemory commit-context traces every file change back to a specific session and ThinkFlywheel task

11.3 When to Enable Each Layer

| Scenario            | ThinkFlywheel only | + planning-with-files  | + agentmemory       |
|---------------------|-------------------|------------------------|---------------------|
| Trivial (reply email) | /task enough      | Not needed             | Not needed          |
| Medium (weekly report)| /task + /retro    | Optional (if steps > 5)| Not needed          |
| Complex (Q2 review)   | /task + /retro    | Recommended (multi-day) | Recommended        |
| Cross-session project | /project          | Strongly recommended   | Strongly recommended|
| Multi-person project  | /project + /decide| Required               | Required            |

Rule of thumb: task with >5 steps or spanning days → enable planning-with-files. Across >3 sessions → enable agentmemory.

---
12. Strengths, Risks & Current Limitations

12.1 Core Strengths

- True bidirectional flow: Most systems have "knowledge → query" as a one-way street. ThinkFlywheel's action→knowledge→memory→new-action flywheel is a closed loop.
- High design maturity: Every skill has complete failure handling tables + anti-pattern blacklists + gate checks.
- Irreversible operation protection: Iron Laws (no-delete, dual-proposal, SCHEMA approval) form multiple safety nets.
- Universal but not vague: Covers 7 life domains with concrete, executable skills for each.
- Pure file architecture: No cloud dependency, no proprietary database. Data fully under user control.
- Consistent skill engineering: Every SKILL.md follows the same template (gates → pipeline → failures → anti-patterns).

12.2 Risks

| Risk                    | Severity | Mitigation                                                              |
|-------------------------|----------|-------------------------------------------------------------------------|
| Obsidian hard dependency| High     | Obsidian is mature, CLI stable since 1.12; but direction change = major refactor |
| Claude Code dependency  | Medium   | Skills are Claude Code slash commands; migrating to other agents requires rewrite |
| Learning curve          | Med-High | 12 skills + 11 card types + 9 rules; phased adoption roadmap mitigates |
| Initial "emptiness"     | Low      | /briefing and /query have limited value with empty vault; ROI grows with use |
| Windows CLI edge cases  | Low      | obsidian-cli.md handles Obsidian.com vs Obsidian.exe, 8KB chunk boundary bug, CJK encoding |
| No multi-user support   | Low      | Designed for single-user; Git provides version history but no merge conflict resolution |

12.3 Current Limitations

- No automated tests: Zero unit/integration/E2E tests. Skill correctness depends entirely on LLM following SKILL.md specifications.
- No CI/CD: Skill optimization relies on manual /darwin-skill evaluation; no pre-commit hooks or automated checks.
- Fixed FSRS parameters: Uses FSRS-6 defaults; no auto-tuning (though review_state.json can be manually edited).
- No mobile: Fully dependent on Obsidian Desktop + Claude Code CLI. Mobile view-only via Obsidian Mobile, no AI operations possible.
- Skills as Markdown specs, not executable code: Behavioral consistency depends on LLM comprehension.

---
13. Target User Profile

Ideal user:
- Technical background: comfortable with terminal, Git, basic Python
- Knowledge worker: handles multiple tasks, projects, continuous learning
- Systems thinker: willing to invest upfront for long-term compound returns
- Existing or willing Obsidian user: already has PKM habits

Not ideal for:
- Pure executors (only 1-2 repetitive tasks)
- Unwilling to spend 5 min/day on /briefing and /review
- High distrust of AI operating on files
- Need team-collaborative task management
- Prefer "works out of the box" over progressive building

---
14. How This Differs From and Improves Upon Existing Systems

14.1 vs knowledge-mgmt

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
│ Card types          │ 8 (all knowledge-focused)            │ 10 (incl. task, project, inbox, flow, decision)     │
└─────────────────────┴──────────────────────────────────────┴─────────────────────────────────────────────────────┘

14.2 vs agent-pmo

┌──────────────────────┬───────────────────────────────────────┬─────────────────────────────────────────────────────────────────┐
│        Aspect        │               agent-pmo               │                          ThinkFlywheel                          │
├──────────────────────┼───────────────────────────────────────┼─────────────────────────────────────────────────────────────────┤
│ Skill count          │ 15 skills                             │ 12 skills                                                       │
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

14.3 vs Broader Alternatives

| Dimension             | ThinkFlywheel     | Obsidian PKM bare | Notion/Tana     | RemNote/Anki   | Enterprise PMO  |
|-----------------------|-------------------|-------------------|-----------------|----------------|-----------------|
| Task management       | 防弹笔记法 4 要素  | None built-in     | Database+views  | None           | Enterprise PMO  |
| Knowledge management  | LLM-compiled Wiki | Manual wikilinks  | Database        | Cards + SR     | None            |
| Spaced repetition     | FSRS-6 (linked to tasks) | None         | None            | SM-2/FSRS      | None            |
| Daily fusion          | /briefing 3-in-1  | Manual            | Manual          | Review only    | None            |
| Completion loop       | /retro auto-extract| None              | Manual archive  | None           | /close = summary |
| AI autonomy           | 3-tier graded     | None              | AI writing aid  | None           | None            |
| Life coverage         | 7 domains         | Ad hoc            | Ad hoc          | Knowledge only | Work only       |
| Data ownership        | Local Markdown+Git| Local             | Cloud           | Cloud+local    | Cloud           |
| Learning curve        | 8-12 weeks phased | Low               | Medium          | Low            | High            |
| Skill count           | 12                | Unlimited         | Unlimited       | 1 (review)     | 15+             |

The core improvement:

knowledge-mgmt is a knowledge compiler — it processes sources into cards, but has no connection to action.

agent-pmo is a project compiler — it tracks projects through stages, but has no memory or personal life dimension.

ThinkFlywheel is a life compiler — it compiles your actions, knowledge, decisions, and projects into a single coherent system where everything strengthens everything else. The fundamental gap both
predecessors share (disconnect between knowledge and action) is addressed at the architectural level through the bidirectional flow between /task and /note via /retro.

The three core fusion points that make this possible:
1. Morning fusion (/briefing) — pulls task, knowledge, and memory layers into one actionable view
2. Completion fusion (/retro) — converts action friction into reusable knowledge via 3-way回流
3. Creation fusion (/task) — surfaces old knowledge automatically when creating new tasks
