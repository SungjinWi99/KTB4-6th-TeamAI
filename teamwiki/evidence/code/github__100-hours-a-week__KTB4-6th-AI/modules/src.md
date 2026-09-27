---
title: github__100-hours-a-week__KTB4-6th-AI — src module
domain: code-knowledge
source: [src/]
---

# src

**51 facts** (interface: 1, error: 11, config: 2, component: 37)

## Core components

- `GET /healthz` ← src/meety_ai/app.py:39
- `LogContextMiddleware` ← src/meety_ai/log_context.py:41
- `Settings` ← src/meety_ai/settings.py:9
- `LiveSettings` ← src/meety_ai/settings.py:42
- `AnalysisSettings` ← src/meety_ai/settings.py:48
- `SpeakerInterval` ← src/meety_ai/diarization/router.py:25
- `DiarizationSegment` ← src/meety_ai/diarization/schemas.py:8
- `DiarizationRequest` ← src/meety_ai/diarization/schemas.py:21
- `AttributedSegment` ← src/meety_ai/diarization/schemas.py:29
- `DiarizationResponse` ← src/meety_ai/diarization/schemas.py:34
- `AudioDecoder` ← src/meety_ai/recording/decoder.py:12
- `Message` ← src/meety_ai/recording/schemas.py:10
- `SessionStartPayload` ← src/meety_ai/recording/schemas.py:26
- `SessionStart` ← src/meety_ai/recording/schemas.py:30
- `SessionReadyPayload` ← src/meety_ai/recording/schemas.py:38
- `SessionReady` ← src/meety_ai/recording/schemas.py:46
- `TranscriptCommittedPayload` ← src/meety_ai/recording/schemas.py:54
- `TranscriptCommitted` ← src/meety_ai/recording/schemas.py:62
- `AudioMetaPayload` ← src/meety_ai/recording/schemas.py:69
- `AudioMeta` ← src/meety_ai/recording/schemas.py:73

## Config

- `MODAL_TOKEN_ID` ← src/meety_ai/analysis.py
- `MODAL_TOKEN_SECRET` ← src/meety_ai/analysis.py

## Errors

- `ValueError` ← src/meety_ai/diarization/modal_app.py
- `ValueError` ← src/meety_ai/log_context.py
- `HTTPException` ← src/meety_ai/diarization/router.py
- `ValueError` ← src/meety_ai/diarization/router.py
- `ValueError` ← src/meety_ai/diarization/schemas.py
- `AudioDecodeError` ← src/meety_ai/recording/decoder.py
- `RuntimeError` ← src/meety_ai/recording/decoder.py
- `SessionProtocolError` ← src/meety_ai/recording/router.py
- `SessionProtocolError` ← src/meety_ai/recording/session.py
- `STTProviderError` ← src/meety_ai/recording/stt_client.py
