# Team Wiki Router

## 产品域路由

| 域 | 入口 | 核心职责 | 路由关键词 |
|---|---|---|---|
| 会议语音智能处理 | [[code/github__100-hours-a-week__KTB4-6th-AI/index]] | **188 facts** extracted from 19 files. Graph: 60 nodes, 10 edges. | 会议录音, 语音转写, STT, 说话人分离, speaker diarization, 会议摘要 |

## 路由规则

1. **按组件名匹配** → 路由关键词列对应域
2. **跨仓库依赖问题** → 查 graph-index.json 的 DEPENDS_ON 边
3. **接口/API 问题** → 优先匹配有 interfaces.md 的仓库
4. **调用链/排障** → 查对应仓库的 dependency-paths.md
5. **模块职责概述** → 查 overview.md 或 modules/*.md
