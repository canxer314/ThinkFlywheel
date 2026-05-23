# Vault 架构与目录

## 四层飞轮

这不是上下堆叠，是飞轮。完成任务→产生知识→进入记忆→新任务浮现→更好执行。复利循环。

| 层 | 目录 | 所有权 | 说明 |
|----|------|--------|------|
| L1 Memory | `Cards/atomics/` + `.obsidian/scripts/fsrs_engine.py` | AI 执行，人验证 | FSRS-6 间隔重复，确保知识进入大脑 |
| L2 Knowledge | `Cards/` + `Sources/` | AI 编译维护，人验证 | LLM Wiki 编译层：概念、洞察、阅读摘要 |
| L3 Task | `Tasks/` + `Projects/` + `Decisions/` | 人主导，AI 辅助 | 防弹笔记法任务管理 + 简化 PMO |
| L4 Governance | `MOCs/` + `Reviews/` + `Daily/` | AI 自主扫描 + 人决策 | 跨系统健康检查 + 索引 + 简报 |

## 目录结构

```
Vault/
├── SCHEMA.md                 # 本文件 — 系统宪法
├── AGENTS.md                 # Agent 操作规则
├── CLAUDE.md                 # Claude Code 桥接配置
├── index.md                  # 内容索引（AI 维护）
├── log.md                    # 时间线日志（AI 追加）
│
├── Tasks/                    # 防弹任务笔记 — 系统枢纽
│   ├── active/               # 进行中：每任务一个笔记
│   ├── waiting/              # 阻塞 / 等待外部输入
│   └── archived/             # 已完成（知识提取源）
│
├── Cards/                    # 知识卡片 — LLM Wiki
│   ├── atomics/              # type/atomic：最小可复用单元 → 喂 SR
│   ├── concepts/             # type/concept：定义、模型、框架
│   ├── health-reports/       # /health 生成的健康报告
│   ├── insights/             # type/insight：教训、模式、反模式
│   └── reading/              # type/reading：已处理来源摘要
│
├── Projects/                 # 多任务目标（个人 PMO）
│   ├── active/               # 活跃目标区域
│   └── archived/             # 已完成 / 放弃的目标
│
├── Decisions/                # 决策日志 DEC-YYYY-NNN.md
├── MOCs/                     # 内容地图（AI 维护索引）
├── Reviews/                  # 定期回顾
│   ├── weekly/               # 周报
│   ├── monthly/              # 月报
│   └── retro/                # 每任务复盘（/retro 自动生成）
├── Daily/                    # 每日简报（自动生成，临时性）
├── Sources/                  # 原始材料（不可变）
│   ├── inbox/                # 新入，未处理
│   └── processed/            # /ingest 后移至此
├── Templates/                # 各类型卡片模板
└── Attachments/              # 图片、PDF、文件
```

## MOC 索引

每个领域至少维护一张 MOC：

| MOC 文件 | domain 覆盖 |
|----------|------------|
| `MOC-Work.md` | `domain/work` |
| `MOC-Life.md` | `domain/life` |
| `MOC-Learning.md` | `domain/learning` |
| `MOC-Health.md` | `domain/health` |
| `MOC-Finance.md` | `domain/finance` |
| `MOC-Reading.md` | 所有 `type/reading` 卡片 |

MOC 由 AI 自主维护，内容为 `[[wikilink]]` 列表 + 一句话摘要，按 mastery 或 status 分组。
