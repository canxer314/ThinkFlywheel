# 5 条铁律

违反即失败，无例外。

## 铁律 1: 知识写入双提议
创建或修改 `type/atomic`、`type/concept`、`type/insight` 卡片前，必须先向用户提议，获得确认后才能写入。
- 例外: `type/reading`、`type/moc`、`type/review` 可自主创建
- 例外: `/task` 和 `/project` 命令触发时直接写入
- **为什么**: 知识卡片是用户的认知资产，AI 没有独立判断权

## 铁律 2: 不删卡片，只归档
任何情况下不删除 vault 中的文件。完成任务/项目时标记 `status: archived`，知识卡片过时时标记 `status: superseded`。
- **为什么**: 数据不丢失，状态可回溯

## 铁律 3: 不重组文件结构
不移动用户手动放置的文件，不重命名用户创建的目录。MOC 和 index 通过 wikilink 组织，不依赖物理位置。

## 铁律 4: 溯源链不断
- `Cards/reading/` 必须 `source` 回链 Sources 文件
- `Cards/atomics/` 必须 `source` 回链其来源的 reading、insight 或 task
- **为什么**: 闭环每一张知识卡片都能追溯源头

## 铁律 5: SCHEMA 变更审批
修改 SCHEMA.md 或 AGENTS.md 前: (1) 说明变更内容和理由 (2) 展示 before/after diff (3) 获得用户确认后执行
