---
title: github__100-hours-a-week__KTB4-6th-AI overview
domain: code-knowledge
---

# github__100-hours-a-week__KTB4-6th-AI

**188 facts** extracted from 19 files.
Graph: 60 nodes, 10 edges.

## Module Structure

| Module | Facts | Components | Interfaces |
|--------|-------|------------|------------|
| src | 51 | 37 | 1 |
| pyproject.toml | 7 | 0 | 0 |

## Dependencies

(No cross-module dependencies detected)

## Interfaces

Types: HTTP(4)

## Key Dependency Paths

- GET /healthz (src/meety_ai/app.py): GET /healthz
- SpeakerInterval (src/meety_ai/diarization/router.py): SpeakerInterval
- main (src/meety_ai/app.py): main
- main (src/meety_ai/diarization/modal_app.py): main

---

## AI Architecture Narrative


# Codebase 概览

## 项目概述

**KTB4-6th-AI** 是 Meety 产品的 AI 服务仓库，负责实时会议转写、问答（聊天机器人）、会议摘要和沟通分析。项目基于 Python 3.12，拆分为两个可以独立部署的 ASGI 应用：**实时 AI（Live）** 与 **分析 AI（Analysis）**。实时 AI 通过 WebSocket 接收会议音频，经 ffmpeg 解码后交给 Speechmatics 做流式转写；分析 AI 通过 HTTP 提供会议摘要和说话人分离等离线能力。

核心能力：
- 🎙️ **实时会议转写**：通过 WebSocket 接收浏览器音频流，实时返回转写文本（ADR-0001）
- 🔊 **实时音频解码**：用 ffmpeg 子进程把音频流转成 STT 所需的 PCM 格式（ADR-0006 / 0007）
- 🗣️ **流式语音识别**：对接 Speechmatics 实时 STT（ADR-0005）
- 💬 **会议问答机器人**：基于 WebSocket 的 Backend ↔ AI 对话通道（ADR-0002）
- 📝 **会议摘要**：用 LLM Chain 对转写文本生成结构化摘要
- 👥 **说话人分离（Diarization）**：部署在 Modal 上的 GPU 推理，并通过 HTTP 路由对外暴露
- 📊 **沟通分析**：Backend 调用分析 AI 时统一返回 HTTP 200（ADR-0003）

## 技术栈

| 维度 | 技术 |
|------|------|
| 语言 | **Python** 3.12.13（`.python-version` 固定版本） |
| 包管理 | **uv**（`pyproject.toml` + `uv.lock`，`uv sync --locked`） |
| Web 框架 | **FastAPI**（⚠️ 推断自 `router.py` 结构和 uvicorn factory 模式） |
| ASGI 服务器 | **Uvicorn**（`--factory` 模式，Live 用 8000 端口，Analysis 用 8001 端口） |
| 实时通信 | **WebSocket**（转写、聊天机器人） |
| STT | **Speechmatics** 实时 API（ADR-0005） |
| 音频解码 | **ffmpeg** 子进程（ADR-0007） |
| 说话人分离 | **Modal** Serverless GPU（`diarization/modal_app.py`） |
| LLM 编排 | ⚠️ LangChain 类 Chain（推断自 `summary/chain.py`） |
| 配置 | ⚠️ pydantic-settings（推断自 `settings.py` 与 `.env.example`） |
| 测试 | **pytest** |
| 代码规范 | **Ruff**（lint + format） |
| 容器化 | **Docker**（`Dockerfile`、`.dockerignore`） |
| CI/CD | **GitHub Actions**（`.github/workflows/cicd.yml`） |

## 目录结构与模块职责

```
KTB4-6th-AI/
├── src/meety_ai/
│   ├── __init__.py
│   │
│   ├── ┌─ 应用入口（两个独立服务）──────────────────────────┐
│   ├── │ app.py                    # 公共 App 构建逻辑（中间件/日志等）│
│   ├── │ live.py                   # create_live_app：实时 AI（8000）  │
│   ├── │ analysis.py               # create_analysis_app：分析 AI（8001）│
│   ├── └─────────────────────────────────────────────────────┘
│   │
│   ├── ┌─ 基础设施 ────────────────────────────────────────┐
│   ├── │ settings.py               # 环境变量 / 配置加载            │
│   ├── │ logging.py                # 日志初始化与格式                │
│   ├── │ log_context.py            # 请求/会话级日志上下文（contextvars）│
│   ├── └─────────────────────────────────────────────────────┘
│   │
│   ├── ┌─ 实时录音与转写（Live）────────────────────────────┐
│   ├── │ recording/
│   ├── │   ├── router.py           # WebSocket 路由入口              │
│   ├── │   ├── session.py          # 单场会议录音会话生命周期        │
│   ├── │   ├── decoder.py          # ffmpeg 子进程音频解码           │
│   ├── │   ├── stt_client.py       # Speechmatics 实时 STT 客户端    │
│   ├── │   ├── transcript.py       # 转写片段模型与聚合              │
│   ├── │   └── schemas.py          # WS 消息 / 事件模式              │
│   ├── └─────────────────────────────────────────────────────┘
│   │
│   ├── ┌─ 会议摘要（Analysis）──────────────────────────────┐
│   ├── │ summary/
│   ├── │   ├── router.py           # 摘要 HTTP 接口                  │
│   ├── │   ├── chain.py            # LLM 摘要链                      │
│   ├── │   └── schemas.py          # 请求 / 响应模式                 │
│   ├── └─────────────────────────────────────────────────────┘
│   │
│   ├── ┌─ 说话人分离（Analysis）────────────────────────────┐
│   ├── │ diarization/
│   ├── │   ├── router.py           # 说话人分离 HTTP 接口            │
│   ├── │   ├── modal_app.py        # Modal GPU 推理应用定义          │
│   ├── │   └── schemas.py          # 请求 / 响应模式                 │
│   ├── └─────────────────────────────────────────────────────┘
│
├── tests/                          # pytest 测试（按模块一一对应）
├── docs/
│   ├── adr/                        # 架构决策记录 0001–0007
│   └── agents/                     # AI Agent 工作指引（domain / issue-tracker）
├── .github/                        # CI/CD、PR/Issue 模板
├── CONTEXT.md                      # 领域术语表
├── AGENTS.md / CLAUDE.md           # Agent 协作指引
├── Dockerfile
├── pyproject.toml / uv.lock
└── .env.example
```

## 数据与配置

```
项目根/
├── .python-version       # 固定 Python 3.12.13
├── pyproject.toml        # 依赖、Ruff、pytest 配置
├── uv.lock               # 锁定依赖版本（CI 使用 --locked）
├── .env.example          # 环境变量模板（STT / LLM / Modal 密钥等）
├── .env                  # 本地实际配置（gitignore）
├── Dockerfile            # 容器镜像构建
├── .venv/                # uv sync 生成的虚拟环境
└── .github/workflows/
    └── cicd.yml          # 测试 → 构建 → 部署流水线
```

- ⚠️ 仓库内看不到持久化数据目录；转写和会话状态应该保存在进程内存中，结果回传给 Backend 由其持久化。

## 核心数据流

### 1. 实时会议转写（Live AI）
```
Backend 建立 WebSocket 连接（/recording 类路由）
    │
    ├─ 1. recording/router.py 接受连接 → 创建 RecordingSession
    │   └─ 在 log_context 中绑定会议 / 会话 ID
    ├─ 2. 收到音频二进制帧 → decoder.py
    │   └─ 写入 ffmpeg 子进程 stdin → 从 stdout 读取 PCM
    ├─ 3. PCM 块 → stt_client.py → Speechmatics 实时 API
    ├─ 4. 收到 partial / final 结果 → transcript.py 聚合
    ├─ 5. 按 schemas.py 序列化 → 通过 WebSocket 推送回 Backend
    └─ ✅ 连接关闭 → 关闭 ffmpeg / STT 连接并释放会话
```

### 2. 会议摘要（Analysis AI）
```
Backend 发送 HTTP 请求（转写全文）
    │
    ├─ 1. summary/router.py 校验请求模式
    ├─ 2. chain.py 构造 Prompt → 调用 LLM
    │   └─ 解析为结构化摘要（schemas.py）
    ├─ 3. 成功或业务失败都返回 HTTP 200，结果状态放在响应体里（ADR-0003）
    └─ ✅ 返回摘要 JSON
```

### 3. 说话人分离（Analysis AI → Modal）
```
Backend 发送 HTTP 请求（音频引用）
    │
    ├─ 1. diarization/router.py 接收请求
    ├─ 2. 远程调用 modal_app.py 中定义的 GPU 函数
    │   └─ 在 Modal 上执行说话人分离模型推理
    ├─ 3. 返回说话人时间片段 → schemas.py
    └─ ✅ 返回 HTTP 200 + 分离结果
```

### 4. 会议问答机器人（Live AI）
```
Backend 建立聊天 WebSocket（ADR-0002）
    │
    ├─ 1. 接收用户问题 + 会议上下文
    ├─ 2. 调用 LLM 流式生成回答
    └─ ✅ 逐段推送回答 token
```
⚠️ 源码树中没有独立的 chatbot 模块，这条流程可能还在 ADR 设计阶段，尚未实现。

## 关键接口与抽象

```python
# 应用工厂（uvicorn --factory）
def create_live_app() -> FastAPI: ...
def create_analysis_app() -> FastAPI: ...
```

```python
# recording/session.py —— 单场会议的实时转写会话（⚠️ 推断签名）
class RecordingSession:
    async def start(self) -> None: ...
    async def feed_audio(self, chunk: bytes) -> None: ...
    async def close(self) -> None: ...
```

```python
# recording/decoder.py —— ffmpeg 子进程解码器（⚠️ 推断签名）
class AudioDecoder:
    async def write(self, data: bytes) -> None: ...
    async def read_pcm(self) -> AsyncIterator[bytes]: ...
    async def close(self) -> None: ...
```

```python
# recording/stt_client.py —— Speechmatics 实时客户端（⚠️ 推断签名）
class SpeechmaticsClient:
    async def connect(self) -> None: ...
    async def send_audio(self, pcm: bytes) -> None: ...
    def results(self) -> AsyncIterator[TranscriptSegment]: ...
```

```python
# summary/chain.py —— 摘要链（⚠️ 推断签名）
async def summarize(transcript: SummaryRequest) -> SummaryResponse: ...
```

实现说明：各模块都采用 `router.py`（接入层）+ `schemas.py`（Pydantic 模型）+ 业务实现文件的三层结构。每个抽象目前只有一个实现，代码里没有额外的 Provider 抽象层。

## 配置系统

- **加载来源**：环境变量 > `.env` 文件 > `settings.py` 中的默认值（⚠️ 按 pydantic-settings 的惯例推断）
- **服务区分**：没有使用运行时 scope 检测，而是通过不同的 factory 入口（`live:create_live_app` / `analysis:create_analysis_app`）决定挂载哪些路由（ADR-0004 部署边界）
- **关键配置示例**（⚠️ 推断自 `.env.example` 的用途）：

```dotenv
SPEECHMATICS_API_KEY=...
SPEECHMATICS_LANGUAGE=ko
LLM_API_KEY=...
MODAL_TOKEN_ID=...
MODAL_TOKEN_SECRET=...
LOG_LEVEL=INFO
```

## 性能与可靠性

| 设计点 | 实现 | 说明 |
|--------|------|------|
| 服务隔离 | Live / Analysis 两个独立进程 | 长连接实时负载与批量 LLM 负载互不影响（ADR-0004） |
| 音频解码 | ffmpeg 子进程 | 利用成熟编解码器，崩溃时不会拖垮主进程（ADR-0007） |
| 解码位置 | AI 服务端解码 | 统一 STT 输入格式，Backend 只负责透传（ADR-0006） |
| GPU 弹性 | Modal Serverless | 说话人分离按需扩缩容，空闲时成本为零 |
| 错误语义 | 统一 HTTP 200 + 响应体状态 | 简化 Backend 调用方的错误处理（ADR-0003） |
| 可观测性 | `log_context.py` 会话级上下文 | 并发 WebSocket 会话的日志可以按会议追踪 |
| 访问日志 | `--no-access-log` | 由自定义日志代替 uvicorn 访问日志，减少噪声 |
| 超时 / 重连 | ⚠️ 未知 | STT 断线重连策略需要查看 `stt_client.py` 确认 |

## 架构决策与权衡

- **为什么用 WebSocket 而不是 HTTP 轮询 / SSE 做实时转写**：音频上行和转写下行都是持续的双向流，WebSocket 用一条连接就能完成（ADR-0001）。
- **为什么把 Live 和 Analysis 分开部署，而不是做成一个服务**：两者的资源画像（长连接 vs. 重计算 LLM）和扩缩容节奏不同，分开后可以独立伸缩和发布（ADR-0004）。
- **为什么选择 Speechmatics 而不是自建 Whisper 等方案**：它原生支持实时流式转写，韩语质量和延迟都满足要求，也省去了自建 GPU 流式推理的运维负担（ADR-0005）。
- **为什么用 ffmpeg 子进程而不是 Python 解码库**：ffmpeg 格式支持最全、稳定性最好；子进程方式隔离了原生崩溃，也避免了 GIL 争用（ADR-0007）。
- **为什么分析接口统一返回 HTTP 200**：业务失败（如 LLM 输出无法解析）不同于传输失败，放进响应体可以让 Backend 统一处理（ADR-0003）。

## 已知限制与演进方向

- ⚠️ **会话状态只在进程内**：Live 服务是有状态的长连接，水平扩展需要粘性会话，实例重启会中断正在进行的会议。
- ⚠️ **聊天机器人尚未落地**：ADR-0002 已定义通道，但源码中还没有对应模块。
- ⚠️ **沟通分析能力有限**：目前只看到 summary 和 diarization，README 提到的"沟通分析"可能还在规划中。
- **强依赖外部服务**：Speechmatics 和 Modal 都是单一供应商，没有降级或备用方案。
- **每个会话一个 ffmpeg 进程**：并发会议数量较多时，进程开销会成为瓶颈，可以考虑进程池或在客户端统一编码格式。

## 测试覆盖

| 测试层级 | 测试文件 | 覆盖模块 |
|----------|----------|----------|
| 单元测试 | `test_recording_decoder.py` | ffmpeg 解码器 |
| 单元测试 | `test_stt_client.py` | Speechmatics 客户端 |
| 单元测试 | `test_recording_session.py` | 录音会话生命周期 |
| 模式测试 | `test_recording_schemas.py` / `test_summary_schemas.py` | Pydantic 模型 |
| 单元测试 | `test_summary_chain.py` | 摘要链 |
| 路由测试 | `test_recording_router.py` / `test_summary_router.py` / `test_diarization_router.py` | WebSocket / HTTP 接口 |
| 公共夹具 | `conftest.py` | 共享 fixture |
| **合计** | 9 个测试文件 + conftest | 用例数、覆盖率：⚠️ 上下文中没有数据（未配置覆盖率报告） |

执行命令：`uv run pytest` / `uv run ruff check .` / `uv run ruff format --check .`

## 备注

- ✅ Python 3.12.13、uv、uvicorn 双服务启动方式、端口 8000/8001、pytest 与 Ruff 的验证命令（来自 README）
- ✅ 实时转写 WebSocket、聊天机器人 WebSocket、HTTP 200 语义、部署边界、Speechmatics、解码位置和 ffmpeg 子进程（来自 ADR 0001–0007 的标题）
- ✅ 项目定位：实时转写、问答、会议摘要、沟通分析（来自 README）
- ⚠️ FastAPI、pydantic-settings、LangChain、各类接口签名、配置项名称，都是根据文件命名和常见惯例推断的
- ⚠️ 聊天机器人与沟通分析的实现状态、STT 重连策略、测试用例数和覆盖率，需要阅读源码才能确认