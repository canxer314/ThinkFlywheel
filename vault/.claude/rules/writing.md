# 写作与标签规范

## 卡片内容标准
- **atomic**: 单一概念，≤300 字，自包含（脱离上下文也能理解）
- **concept**: 定义 + 要点 + 示例 + 相关卡片链接
- **insight**: 触发情境 + 教训/模式 + 反模式（如适用）+ 适用范围
- **task**: 必须包含 4 要素 — 最终目标、原始材料堆、下一步行动、问题与吐槽

## 四维标签

每张卡片携带以下 frontmatter 标签：

```
type/{card-type}        # 卡片类型（必填）
domain/{life-area}      # 生活领域（必填）
status/{flow-state}     # 流转状态（必填）
mastery/{level}         # 掌握程度（atomic 卡片必填，其他可选）
```

### domain 取值

| 值 | 含义 |
|----|------|
| `work` | 职业工作 |
| `life` | 日常生活 |
| `learning` | 学习成长 |
| `health` | 身心健康 |
| `finance` | 财务管理 |
| `relationship` | 人际关系 |
| `tech` | 技术积累 |

### status 取值（按卡片类型）

| 卡片类型 | 可用 status |
|----------|------------|
| task | `todo` `doing` `waiting` `done` `archived` |
| project | `active` `paused` `completed` `abandoned` |
| atomic | `new` `learning` `reviewing` `mastered` |
| concept/insight | `draft` `stable` `superseded` |
| decision | `pending` `made` `reviewed` `overturned` |
| moc | `active` `stale` |
| reading | `processed` `extracted` |
| review | `draft` `final` |

### mastery 取值（atomic 卡片专用）

| 值 | 含义 | FSRS 影响 |
|----|------|----------|
| `0-new` | 初次接触 | 初始难度 = D₀ |
| `1-familiar` | 有点熟悉 | 初始稳定性 x1.3 |
| `2-comfortable` | 基本掌握 | 初始稳定性 x1.5 |
| `3-mastered` | 完全掌握 | 初始稳定性 x2.0，降低复习频率 |

## Frontmatter 规范

所有卡片必须包含：

```yaml
---
type: {card-type}
domain: {life-area}
status: {flow-state}
created: YYYY-MM-DD
updated: YYYY-MM-DD
mastery: {level or null}
source: [[source-card]] or null
related_tasks: [task-1, task-2] or []
related_cards: [card-1, card-2] or []
---
```

| 字段 | 必填 | 说明 |
|------|------|------|
| `type` | 是 | 卡片类型标签 |
| `domain` | 是 | 生活领域标签 |
| `status` | 是 | 流转状态标签 |
| `created` | 是 | 创建日期 |
| `updated` | 是 | 最后更新日期（AI 自动维护） |
| `mastery` | atomic 必填 | 掌握程度 |
| `source` | reading/atomic 必填 | 溯源链接：reading 回链 Sources，atomic 回链 reading 或 task |
| `related_tasks` | 可选 | 关联任务列表 |
| `related_cards` | 可选 | 关联卡片列表 |

## 溯源链

```
Sources/inbox → /ingest → Cards/reading/ (type/reading)
                                    ↓ /note 提取
                             Cards/atomics/ (type/atomic)

Tasks/active/ → /retro → Cards/insights/ (type/insight)
                              ↓ /note 提取
                         Cards/atomics/ (type/atomic)
```

- reading 的 `source` 回链 Sources 文件
- atomic 的 `source` 回链其来源 reading、insight 或 task

## 语言
对话用中文；文件名、标签、目录名用英文（CLI 兼容）
