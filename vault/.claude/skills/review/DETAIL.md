# /review 设计哲学与参考

> 此文件包含 SKILL.md 中移出的教育性内容和参考资料。
> Agent 不需要每次加载——仅在需要理解设计意图或查阅 CLI 用法时读取。

## 核心理念

knowledge-mgmt 作者的核心洞察：**"一份编译精美但从未被记住的 wiki 是浪费。"**

`/review` 是 ThinkFlywheel 的"记忆层"——将知识从 vault 推入你的大脑。这与 `/note` 形成闭环：/note 存入 vault，/review 存入大脑。

## FSRS 引擎 CLI 速查

```bash
# 获取到期卡片（混合新卡和复习卡）
python fsrs_engine.py <state> due --limit 20 --new_limit 10

# 注册单张卡片
python fsrs_engine.py <state> register --id "card-id" --title "Title" --content "Content"

# 记录复习结果
python fsrs_engine.py <state> record --id "card-id" --rating 3

# 查看统计
python fsrs_engine.py <state> stats
```

## 与其他技能的集成

| 集成点 | 说明 |
|--------|------|
| `/briefing` | 每日简报自动检测到期复习卡片，交叉引用活跃任务 |
| `/retro` | 复盘提取的 insight 和 atomic 卡片自动注册进 FSRS |
| `/note` | 双提议确认的新 atomic 卡片自动注册进 FSRS |
| `/health` | 健康检查报告 SR 积压和掌握率 |
