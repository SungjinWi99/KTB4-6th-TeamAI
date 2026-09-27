# 数据流图
<!-- search-anchor: 调用链, 数据流, 请求路径, entry, flow, 入口, 链路 -->

## Dependency Paths

  Static import dependency paths (not runtime call traces).
  4 dependency path(s) traced from entry points (max depth 4).

## GET /healthz (src/meety_ai/app.py)

  - [service] `GET /healthz` ← src/meety_ai/app.py:39

## SpeakerInterval (src/meety_ai/diarization/router.py)

  - [entry] `SpeakerInterval` ← src/meety_ai/diarization/router.py:25

## main (src/meety_ai/app.py)

  - [service] `main` ← src/meety_ai/app.py:1

## main (src/meety_ai/diarization/modal_app.py)

  - [service] `main` ← src/meety_ai/diarization/modal_app.py:1

