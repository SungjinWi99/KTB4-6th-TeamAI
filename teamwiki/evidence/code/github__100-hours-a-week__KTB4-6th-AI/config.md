---
title: github__100-hours-a-week__KTB4-6th-AI config
domain: code-knowledge
source:
  - src/meety_ai/analysis.py
  - pyproject.toml
---

# Config

- `MODAL_TOKEN_ID` ← src/meety_ai/analysis.py:20 [EXTRACTED]
  ```
  os.environ["MODAL_TOKEN_ID"] = settings.modal_token_id
  ```
- `MODAL_TOKEN_SECRET` ← src/meety_ai/analysis.py:21 [EXTRACTED]
  ```
  os.environ["MODAL_TOKEN_SECRET"] = settings.modal_token_secret.get_secret_value()
  ```
- `project` ← pyproject.toml:1 [EXTRACTED]
  ```
  [project]
  ```
- `dependency-groups` ← pyproject.toml:17 [EXTRACTED]
  ```
  [dependency-groups]
  ```
- `build-system` ← pyproject.toml:24 [EXTRACTED]
  ```
  [build-system]
  ```
- `tool.hatch.build.targets.wheel` ← pyproject.toml:28 [EXTRACTED]
  ```
  [tool.hatch.build.targets.wheel]
  ```
- `tool.pytest.ini_options` ← pyproject.toml:31 [EXTRACTED]
  ```
  [tool.pytest.ini_options]
  ```
- `tool.ruff` ← pyproject.toml:35 [EXTRACTED]
  ```
  [tool.ruff]
  ```
- `tool.ruff.lint` ← pyproject.toml:39 [EXTRACTED]
  ```
  [tool.ruff.lint]
  ```