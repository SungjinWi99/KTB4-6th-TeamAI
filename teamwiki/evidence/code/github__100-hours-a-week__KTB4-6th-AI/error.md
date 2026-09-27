---
title: github__100-hours-a-week__KTB4-6th-AI error
domain: code-knowledge
source:
  - src/meety_ai/diarization/modal_app.py
  - src/meety_ai/log_context.py
  - src/meety_ai/diarization/router.py
  - src/meety_ai/diarization/schemas.py
  - src/meety_ai/recording/decoder.py
  - src/meety_ai/recording/router.py
  - src/meety_ai/recording/session.py
  - src/meety_ai/recording/stt_client.py
  - src/meety_ai/summary/router.py
---

# Error

- `ValueError` ← src/meety_ai/diarization/modal_app.py:94 [INFERRED]
  ```
  raise ValueError("https URL이 아닙니다.")
  ```
- `ValueError` ← src/meety_ai/log_context.py:33 [INFERRED]
  ```
  raise ValueError("request_id는 영문·숫자·점·밑줄·하이픈으로 된 1~128자여야 합니다.")
  ```
- `HTTPException` ← src/meety_ai/diarization/router.py:48 [INFERRED]
  ```
  raise HTTPException(
  ```
- `ValueError` ← src/meety_ai/diarization/router.py:66 [INFERRED]
  ```
  raise ValueError("알 수 없는 status")
  ```
- `ValueError` ← src/meety_ai/diarization/schemas.py:17 [INFERRED]
  ```
  raise ValueError("startedAtMs는 endedAtMs보다 클 수 없습니다.")
  ```
- `AudioDecodeError` ← src/meety_ai/recording/decoder.py:8 [EXTRACTED]
  ```
  class AudioDecodeError(Exception):
  ```
- `RuntimeError` ← src/meety_ai/recording/decoder.py:47 [INFERRED]
  ```
  raise RuntimeError("start()를 먼저 호출해야 합니다.")
  ```
- `SessionProtocolError` ← src/meety_ai/recording/router.py:111 [INFERRED]
  ```
  raise SessionProtocolError("message_too_large", "메시지가 너무 큽니다.")
  ```
- `SessionProtocolError` ← src/meety_ai/recording/session.py:38 [EXTRACTED]
  ```
  class SessionProtocolError(Exception):
  ```
- `STTProviderError` ← src/meety_ai/recording/stt_client.py:17 [EXTRACTED]
  ```
  class STTProviderError(Exception):
  ```
- `HTTPException` ← src/meety_ai/summary/router.py:32 [INFERRED]
  ```
  raise HTTPException(
  ```