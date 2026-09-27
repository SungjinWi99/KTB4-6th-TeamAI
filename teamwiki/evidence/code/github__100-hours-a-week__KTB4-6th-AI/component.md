---
title: github__100-hours-a-week__KTB4-6th-AI component
domain: code-knowledge
source:
  - src/meety_ai/log_context.py
  - src/meety_ai/settings.py
  - src/meety_ai/diarization/router.py
  - src/meety_ai/diarization/schemas.py
  - src/meety_ai/recording/decoder.py
  - src/meety_ai/recording/schemas.py
  - src/meety_ai/recording/session.py
  - src/meety_ai/recording/stt_client.py
  - src/meety_ai/summary/schemas.py
---

# Component

- `LogContextMiddleware` ← src/meety_ai/log_context.py:41 [EXTRACTED]
  ```
  class LogContextMiddleware:
  ```
- `Settings` ← src/meety_ai/settings.py:9 [EXTRACTED]
  ```
  class Settings(BaseSettings):
  ```
- `LiveSettings` ← src/meety_ai/settings.py:42 [EXTRACTED]
  ```
  class LiveSettings(Settings):
  ```
- `AnalysisSettings` ← src/meety_ai/settings.py:48 [EXTRACTED]
  ```
  class AnalysisSettings(Settings):
  ```
- `SpeakerInterval` ← src/meety_ai/diarization/router.py:25 [EXTRACTED]
  ```
  class SpeakerInterval(TypedDict):
  ```
- `DiarizationSegment` ← src/meety_ai/diarization/schemas.py:8 [EXTRACTED]
  ```
  class DiarizationSegment(Message):
  ```
- `DiarizationRequest` ← src/meety_ai/diarization/schemas.py:21 [EXTRACTED]
  ```
  class DiarizationRequest(Message):
  ```
- `AttributedSegment` ← src/meety_ai/diarization/schemas.py:29 [EXTRACTED]
  ```
  class AttributedSegment(DiarizationSegment):
  ```
- `DiarizationResponse` ← src/meety_ai/diarization/schemas.py:34 [EXTRACTED]
  ```
  class DiarizationResponse(Message):
  ```
- `AudioDecoder` ← src/meety_ai/recording/decoder.py:12 [EXTRACTED]
  ```
  class AudioDecoder:
  ```
- `Message` ← src/meety_ai/recording/schemas.py:10 [EXTRACTED]
  ```
  class Message(BaseModel):
  ```
- `SessionStartPayload` ← src/meety_ai/recording/schemas.py:26 [EXTRACTED]
  ```
  class SessionStartPayload(Message):
  ```
- `SessionStart` ← src/meety_ai/recording/schemas.py:30 [EXTRACTED]
  ```
  class SessionStart(Message):
  ```
- `SessionReadyPayload` ← src/meety_ai/recording/schemas.py:38 [EXTRACTED]
  ```
  class SessionReadyPayload(Message):
  ```
- `SessionReady` ← src/meety_ai/recording/schemas.py:46 [EXTRACTED]
  ```
  class SessionReady(Message):
  ```
- `TranscriptCommittedPayload` ← src/meety_ai/recording/schemas.py:54 [EXTRACTED]
  ```
  class TranscriptCommittedPayload(Message):
  ```
- `TranscriptCommitted` ← src/meety_ai/recording/schemas.py:62 [EXTRACTED]
  ```
  class TranscriptCommitted(Message):
  ```
- `AudioMetaPayload` ← src/meety_ai/recording/schemas.py:69 [EXTRACTED]
  ```
  class AudioMetaPayload(Message):
  ```
- `AudioMeta` ← src/meety_ai/recording/schemas.py:73 [EXTRACTED]
  ```
  class AudioMeta(Message):
  ```
- `SessionPause` ← src/meety_ai/recording/schemas.py:78 [EXTRACTED]
  ```
  class SessionPause(Message):
  ```
- `SessionPausedPayload` ← src/meety_ai/recording/schemas.py:83 [EXTRACTED]
  ```
  class SessionPausedPayload(Message):
  ```
- `SessionPaused` ← src/meety_ai/recording/schemas.py:87 [EXTRACTED]
  ```
  class SessionPaused(Message):
  ```
- `SessionResume` ← src/meety_ai/recording/schemas.py:93 [EXTRACTED]
  ```
  class SessionResume(Message):
  ```
- `SessionResumedPayload` ← src/meety_ai/recording/schemas.py:98 [EXTRACTED]
  ```
  class SessionResumedPayload(Message):
  ```
- `SessionResumed` ← src/meety_ai/recording/schemas.py:102 [EXTRACTED]
  ```
  class SessionResumed(Message):
  ```
- `SessionStop` ← src/meety_ai/recording/schemas.py:108 [EXTRACTED]
  ```
  class SessionStop(Message):
  ```
- `SessionEndedPayload` ← src/meety_ai/recording/schemas.py:113 [EXTRACTED]
  ```
  class SessionEndedPayload(Message):
  ```
- `SessionEnded` ← src/meety_ai/recording/schemas.py:119 [EXTRACTED]
  ```
  class SessionEnded(Message):
  ```
- `SessionErrorPayload` ← src/meety_ai/recording/schemas.py:127 [EXTRACTED]
  ```
  class SessionErrorPayload(Message):
  ```
- `SessionError` ← src/meety_ai/recording/schemas.py:143 [EXTRACTED]
  ```
  class SessionError(Message):
  ```
- `SessionState` ← src/meety_ai/recording/session.py:31 [EXTRACTED]
  ```
  class SessionState(StrEnum):
  ```
- `RecordingSession` ← src/meety_ai/recording/session.py:46 [EXTRACTED]
  ```
  class RecordingSession:
  ```
- `SpeechmaticsClient` ← src/meety_ai/recording/stt_client.py:21 [EXTRACTED]
  ```
  class SpeechmaticsClient:
  ```
- `Message` ← src/meety_ai/summary/schemas.py:8 [EXTRACTED]
  ```
  class Message(BaseModel):
  ```
- `Speaker` ← src/meety_ai/summary/schemas.py:24 [EXTRACTED]
  ```
  class Speaker(Message):
  ```
- `TranscriptionSegment` ← src/meety_ai/summary/schemas.py:30 [EXTRACTED]
  ```
  class TranscriptionSegment(Message):
  ```
- `SummaryRequest` ← src/meety_ai/summary/schemas.py:40 [EXTRACTED]
  ```
  class SummaryRequest(Message):
  ```