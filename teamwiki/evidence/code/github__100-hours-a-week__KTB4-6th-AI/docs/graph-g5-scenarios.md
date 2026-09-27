# 核心业务场景序列图
<!-- search-anchor: 流程, 场景, 序列图, sequence, 业务流, 完整流程 -->

> 依据说明：提供的调用链只有静态 import 路径，可确认的入口只有 `GET /healthz`、`SpeakerInterval`（diarization/router.py）、`app.py:main` 和 `diarization/modal_app.py:main`。下面三个业务场景对应架构文档中的"录音 / 分离 / 摘要"三项能力。图中的交互细节是根据架构文档推断的，没有逐行核对源码。4 个 HTTP 接口的具体路径文档里没写，所以图中用 `POST /recording/*` 这类占位路径代替。可识别的真实场景有 4 个，不补虚构场景。

## 场景 1: 实时录音与语音转写

```mermaid
sequenceDiagram
    autonumber
    participant Client as 客户端/前端
    participant MW as 请求日志上下文中间件
    participant Router as HTTP 路由(录音)
    participant Rec as 实时录音模块<br/>(音频解码+会话管理)
    participant Cfg as 配置管理(实时参数)
    participant STT as 外部 STT 服务

    Client->>MW: POST /recording/* (音频流/分片)
    MW->>MW: 生成 request_id，注入日志上下文
    MW->>Router: 转发请求
    Router->>Rec: 调用录音处理(会话ID, 音频块)
    Rec->>Cfg: 读取实时参数(采样率/分片时长等)
    Cfg-->>Rec: 参数
    alt 会话不存在
        Rec->>Rec: 新建会话
    else 会话已存在
        Rec->>Rec: 追加到现有会话缓冲
    end
    Rec->>Rec: 音频解码/重采样
    Rec->>STT: HTTP/流式 发送音频
    STT-->>Rec: 转写片段(文本+时间戳)
    Rec-->>Router: 转写结果/会话状态
    Router-->>Client: 200 响应
```

关键决策：会话管理在录音模块内部完成。同一会话的多个音频分片按会话 ID 聚合，解码之后才发给 STT，所以 STT 服务本身不需要保存状态。采样率、分片时长等实时参数由配置模块统一管理，不在代码里写死。STT 调用失败属于外部依赖错误，需要在这一层转换成 HTTP 错误码返回（src 模块中有 11 条 error 类 fact 支持这一点）。

## 场景 2: 说话人分离（转写片段 → 说话人归属）

```mermaid
sequenceDiagram
    autonumber
    participant Client as 客户端/前端
    participant MW as 请求日志上下文中间件
    participant Router as diarization/router.py
    participant DClient as 说话人分离客户端
    participant Cfg as 配置管理
    participant Modal as Modal 远程服务<br/>(diarization/modal_app.py)

    Client->>MW: POST /diarization/* (音频引用 + 转写片段)
    MW->>Router: 注入 request_id 后转发
    Router->>DClient: 发起分离请求
    DClient->>Cfg: 读取 Modal 应用/函数配置
    Cfg-->>DClient: 配置
    DClient->>Modal: Modal 远程调用(音频)
    Modal->>Modal: 说话人分离模型推理
    Modal-->>DClient: List[SpeakerInterval(speaker, start, end)]
    DClient->>DClient: 按时间重叠把转写片段对齐到 SpeakerInterval
    DClient-->>Router: 带说话人标签的片段
    Router-->>Client: 200 响应(SpeakerInterval 列表/标注结果)
```

关键决策：分离模型需要 GPU，所以单独部署在 Modal 上（`modal_app.py` 有自己的 `main` 入口），主应用只作为客户端发起远程调用，两边可以分别部署和扩缩容。`SpeakerInterval` 是两侧之间的数据契约，对外暴露。片段和说话人的对应关系在客户端一侧用时间区间重叠来计算，Modal 端只负责输出说话人区间。

## 场景 3: 会议分析与摘要生成

```mermaid
sequenceDiagram
    autonumber
    participant Client as 客户端/前端
    participant MW as 请求日志上下文中间件
    participant Router as HTTP 路由(摘要)
    participant Analysis as 会议分析+摘要生成
    participant Cfg as 配置管理(分析参数)
    participant LLM as 外部 LLM API

    Client->>MW: POST /summary/* (带说话人标签的转写)
    MW->>Router: 注入 request_id 后转发
    Router->>Analysis: 调用分析(会议记录)
    Analysis->>Cfg: 读取分析参数(模型/提示词/长度限制)
    Cfg-->>Analysis: 参数
    Analysis->>Analysis: 按说话人整理发言、构造 prompt
    Analysis->>LLM: HTTP API 请求
    LLM-->>Analysis: 分析/摘要文本
    Analysis->>Analysis: 解析并校验输出结构
    Analysis-->>Router: 摘要结果
    Router-->>Client: 200 响应(摘要)
```

关键决策：摘要以场景 2 的输出（带说话人的转写）为输入，所以三个能力组成 录音 → 分离 → 摘要 这条流水线。每个环节都有自己的独立接口，客户端可以按阶段分别调用和重试。模型、提示词等分析参数与实时参数分开配置，调整摘要策略不会影响录音链路。

## 场景 4: 健康检查

```mermaid
sequenceDiagram
    autonumber
    participant Probe as 负载均衡/K8s 探针
    participant MW as 请求日志上下文中间件
    participant App as app.py (GET /healthz)

    Probe->>MW: GET /healthz
    MW->>App: 转发
    App-->>Probe: 200 OK
```

关键决策：`/healthz` 在 `app.py:39` 中直接定义，不经过业务层，也不调用外部服务，只用于判断进程是否存活。它不检查 STT、Modal、LLM 这些依赖是否可用，如果需要检查依赖就绪状态，得另加 readiness 接口。

我只拿到了你提供的摘要，没能读到源码：本机搜索仓库的命令需要权限批准，这一步没有执行。如果你给我本地仓库路径，我可以把场景 1–3 中的占位路径和函数名换成真实名称。