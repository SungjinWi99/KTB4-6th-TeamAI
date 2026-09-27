## 🤖 AI 快速理解要点

| 维度 | 说明 |
|------|------|
| 核心职责 | 项目元数据、依赖与工具链配置 |
| 架构层级 | 构建/配置层（非运行时代码） |
| 上游组件 | 无（模块依赖为空） |
| 下游组件 | `src/meety_ai` 包及其所有子模块 |
| 代码入口 | `pyproject.toml`（根目录） |
| 核心机制 | PEP 517/518/621 声明式配置 |
| 数据流向 | 配置 → 构建后端/安装器 → 运行环境 |
| 技术栈 | Python 打包、ASGI Web 服务（推断） |

## 架构设计

```
                    ┌──────────────────────────────┐
                    │        pyproject.toml        │
                    ├──────────────────────────────┤
                    │ [project]                    │ ← 名称/版本/描述
                    │   dependencies               │ ← 运行时依赖
                    │   optional-deps / dev groups │ ← 开发依赖
                    ├──────────────────────────────┤
                    │ [build-system]               │ ← 构建后端
                    ├──────────────────────────────┤
                    │ [tool.*]                     │ ← lint/test/format
                    └──────┬───────────┬───────────┘
                           │           │
             安装/构建     │           │ 工具读取
                           ▼           ▼
        ┌──────────────────────┐   ┌────────────────────────┐
        │ 构建后端 / 安装器    │   │ Linter / Formatter /   │
        │ (pip / uv 等)        │   │ Test Runner            │
        └──────────┬───────────┘   └────────────────────────┘
                   │ 生成可安装包 + 解析依赖
                   ▼
        ┌──────────────────────────────────────────────┐
        │ src/meety_ai (运行时包)                      │
        │  ├─ app.py            main / GET /healthz     │
        │  └─ diarization/                             │
        │       └─ router.py    SpeakerInterval         │
        └──────────────────────────────────────────────┘
```

**核心子模块说明**

| 配置段 | 作用 | 下游影响 |
|--------|------|----------|
| `[project]` 元数据 | 声明包名、版本、描述、Python 版本约束 | 包的标识及发布信息 |
| `[project].dependencies` | 运行时依赖（Web 框架、ASGI 服务器、说话人分离/音频相关库，推断） | 决定 `app.py` 与 `diarization` 是否能导入 |
| 开发依赖（extras / dependency-groups） | 测试、lint、格式化工具 | 仅在开发/CI 环境安装 |
| `[build-system]` | 指定构建后端与 `requires` | `pip install` / `uv build` 的行为 |
| `[tool.*]` | 各工具配置（如 ruff / pytest / black 等，具体以文件为准） | 统一代码风格与测试发现规则 |
| src 布局包发现 | 将 `src/meety_ai` 映射为可导入包 | `import meety_ai` 能否成功 |
| `[project.scripts]`（如有） | 将 `main` 暴露为命令行入口 | 服务启动方式 |

## 接口设计

本模块是静态配置，本身不提供运行时 API。下表列出两类对外接口：它作为配置被外部工具读取的接口，以及由它打包出来的服务所暴露的接口。

| 接口名 | 方法 | 路径 | 说明 |
|--------|------|------|------|
| 安装项目 | CLI | `pip install .` / `uv sync` | 按 `[build-system]` 构建，安装运行时依赖 |
| 安装开发依赖 | CLI | `pip install -e ".[dev]"` / `uv sync --dev` | 安装 lint/test/format 工具（extra/group 名以文件为准） |
| 构建分发包 | CLI | `python -m build` / `uv build` | 生成 sdist 与 wheel |
| 代码检查/格式化 | CLI | lint / format 命令 | 读取 `[tool.*]` 配置 |
| 运行测试 | CLI | 测试命令（如 `pytest`） | 读取测试相关的 `[tool.*]` 配置 |
| 健康检查 | GET | `/healthz` | 由 `src/meety_ai/app.py:39` 提供 |
| 服务入口 | — | `main`（`src/meety_ai/app.py`） | 启动应用，可能通过 scripts 注册为命令 |
| 说话人分离路由 | — | `diarization/router.py` | 其中 `SpeakerInterval` 模型位于 `router.py:25` |

## 核心流程

**1. 环境构建流程**
1. 开发者或 CI 执行安装命令（`pip install .` / `uv sync`）。
2. 安装器读取 `[build-system]`，先装好构建后端需要的依赖。
3. 构建后端解析 `[project]` 元数据，并从 `src/` 中发现 `meety_ai` 包。
4. 解析 `[project].dependencies` 并安装运行时依赖。
5. 若指定了开发 extra 或依赖组，再额外安装 lint/test/format 工具。
6. 若声明了 `[project.scripts]`，注册控制台入口，指向 `main`。

**2. 服务启动流程（依赖于本配置）**
1. 通过 `main`、ASGI 服务器或注册好的命令启动 `meety_ai.app`。
2. `app.py` 导入运行时依赖；这些依赖必须已在 `dependencies` 中声明。
3. 挂载 `diarization.router`，注册说话人分离相关的路由和 `SpeakerInterval` 模型。
4. 暴露 `GET /healthz` 供存活探测使用。

**3. 质量保障流程**
1. 开发者或 CI 调用 linter/formatter，它们读取 `[tool.*]` 中的规则。
2. 测试运行器按 `[tool.*]` 的配置发现并执行测试。
3. 检查全部通过后，执行构建命令产出 wheel/sdist，用于部署。

**4. 依赖变更流程**
1. 修改 `pyproject.toml` 中的依赖声明。
2. 重新执行 sync/install；如使用锁文件则同时更新锁文件。
3. 重新运行测试，验证 `app.py` 与 `diarization` 模块兼容新依赖。