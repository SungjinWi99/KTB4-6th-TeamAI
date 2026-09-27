# src 组件设计文档（meety_ai）

## 🤖 AI 快速理解要点

| 项目 | 说明 |
|------|------|
| 核心职责 | 实时录音转写、说话人分离、会议摘要 |
| 架构层级 | AI 服务层（FastAPI 应用） |
| 上游组件 | 前端/后端客户端（WS/HTTP） |
| 下游组件 | 外部 STT 服务、Modal 分离服务 |
| 代码入口 | `src/meety_ai/app.py` |
| 核心机制 | 会话消息协议 + 片段说话人归属 |
| 数据流向 | 音频→解码→STT→分离→摘要 |
| 技术栈 | Python/FastAPI/Pydantic/Modal |

## 架构设计

```
                ┌──────────────────────────────────────────┐
  Client ──────▶│ app.py (FastAPI)  GET /healthz           │
  (WS / HTTP)   │   └─ LogContextMiddleware (请求日志上下文) │
                └───────┬───────────────┬──────────────┬───┘
                        │               │              │
          ┌─────────────▼───┐  ┌────────▼────────┐  ┌──▼──────────────┐
          │ recording/      │  │ diarization/    │  │ analysis.py     │
          │  router.py      │  │  router.py      │  │  会议分析/摘要   │
          │  session.py     │  │  schemas.py     │  └──┬──────────────┘
          │  decoder.py     │  │  modal_app.py   │     │ MODAL_TOKEN_*
          │  schemas.py     │  └────────┬────────┘     │
          │  stt_client.py  │           │              │
          └───────┬─────────┘           ▼              ▼
                  │               ┌────────────────────────┐
                  ▼               │ Modal (GPU 说话人分离)  │
          ┌──────────────┐        └────────────────────────┘
          │ 外部 STT 服务 │
          └──────────────┘
                settings.py: Settings / LiveSettings / AnalysisSettings（全局配置）
```

### 核心子模块

| 子模块 | 关键组件 | 说明 |
|--------|----------|------|
| `app.py` | `GET /healthz`, `main` | 应用入口，挂载路由与中间件 |
| `log_context.py` | `LogContextMiddleware` | 为每个请求注入日志上下文 |
| `settings.py` | `Settings`, `LiveSettings`, `AnalysisSettings` | 实时录音参数与分析参数的配置 |
| `recording/decoder.py` | `AudioDecoder`, `AudioDecodeError` | 解码实时音频块，解码失败时抛出 `AudioDecodeError` |
| `recording/schemas.py` | `Message`, `SessionStart`, `SessionReady`, `AudioMeta`, `TranscriptCommitted` | 实时会话消息协议 |
| `recording/session.py` | 会话状态机, `SessionProtocolError` | 管理会话生命周期，校验消息顺序 |
| `recording/stt_client.py` | `STTProviderError` | 对接外部 STT 服务 |
| `diarization/router.py` | `SpeakerInterval`, `HTTPException` | 分离接口，将转写片段按时间区间归属到说话人 |
| `diarization/schemas.py` | `DiarizationRequest/Response/Segment`, `AttributedSegment` | 分离接口的请求/响应模型 |
| `diarization/modal_app.py` | `main` | 部署在 Modal 上的说话人分离应用 |
| `analysis.py` | — | 会议内容分析与摘要，依赖 Modal 凭证 |

## 接口设计

| 接口名 | 方法 | 路径 | 说明 |
|--------|------|------|------|
| 健康检查 | GET | `/healthz` | 存活探针（`app.py:39`） |
| 实时录音会话 | WebSocket | 由 recording/router 定义 | 流程为 SessionStart → SessionReady → AudioMeta/音频 → TranscriptCommitted |
| 说话人分离 | POST | 由 diarization/router 定义 | 输入 `DiarizationRequest`，返回带说话人归属的 `DiarizationResponse` |
| 会议摘要 | POST | 由 analysis 定义 | 返回会议分析与摘要结果 |

> 注：代码提取结果中只有 `/healthz` 带明确路径，其余接口的具体路径以各 router 源码为准。

### 配置项

| 配置 | 来源 | 说明 |
|------|------|------|
| `MODAL_TOKEN_ID` / `MODAL_TOKEN_SECRET` | 环境变量 | Modal 服务鉴权 |
| `LiveSettings` | `settings.py:42` | 实时录音与 STT 参数 |
| `AnalysisSettings` | `settings.py:48` | 分离与摘要参数 |

### 错误类型

| 异常 | 位置 | 触发场景 |
|------|------|----------|
| `SessionProtocolError` | recording/session, router | 消息顺序或格式违反会话协议 |
| `AudioDecodeError` | recording/decoder | 音频块无法解码 |
| `STTProviderError` | recording/stt_client | 外部 STT 调用失败 |
| `HTTPException` | diarization/router | 分离请求非法，或下游调用失败 |
| `ValueError` | diarization/schemas, modal_app, log_context | 参数校验失败 |

## 核心流程

### 1. 实时录音转写
1. 客户端建立会话连接，发送 `SessionStart`（`SessionStartPayload`）。
2. `session.py` 校验协议并初始化会话，回复 `SessionReady`。
3. 客户端发送 `AudioMeta` 声明音频格式，然后持续推送音频块。
4. `AudioDecoder` 解码音频块，失败时抛出 `AudioDecodeError`。
5. `stt_client` 把解码后的音频送往外部 STT，异常时抛出 `STTProviderError`。
6. STT 结果确定后，下发 `TranscriptCommitted`（`TranscriptCommittedPayload`）。
7. 如果协议顺序出错，抛出 `SessionProtocolError` 并终止会话。

### 2. 说话人分离
1. 客户端提交 `DiarizationRequest`，内容为音频和转写片段。
2. `schemas.py` 校验输入，非法时抛出 `ValueError`，再转为 `HTTPException`。
3. router 调用 Modal 上部署的 `modal_app`，得到说话人时间区间（`SpeakerInterval`）。
4. 将每个转写片段与说话人区间按时间重叠匹配，生成 `AttributedSegment`。
5. 返回 `DiarizationResponse`。

### 3. 会议分析与摘要
1. 接收带说话人归属的转写内容。
2. `analysis.py` 读取 `AnalysisSettings` 和 Modal 凭证，调用分析与摘要能力。
3. 返回结构化的摘要结果。

### 4. 横切关注
- 所有 HTTP 请求都会经过 `LogContextMiddleware`，由它注入请求级日志上下文。
- `/healthz` 用于部署时的存活检查。