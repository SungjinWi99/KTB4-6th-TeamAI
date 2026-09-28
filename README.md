# KTB4 6팀 AI 스킬·플러그인·MCP

[AIManager](https://github.com/SungjinWi99/AIManager)로 관리하는 6팀 공용 저장소입니다. 여기에 모인 스킬·MCP·플러그인이 팀원 모두의 Claude Code와 Codex에 자동으로 들어갑니다.

## 참여하기 (한 번만)

1. GitHub 초대 메일(또는 [초대 페이지](https://github.com/SungjinWi99/KTB4-6th-TeamAI/invitations))을 수락합니다.
2. 아래 문장을 **Claude Code나 Codex에 그대로 보냅니다.**

```text
AIManager를 설치하고 우리 팀에 참여시켜줘. 방법은 https://github.com/SungjinWi99/AIManager 를 읽고 따라 해. 팀 저장소는 https://github.com/SungjinWi99/KTB4-6th-TeamAI.git
```

3. Codex를 쓴다면 Codex에서 `/hooks`를 열고 AIManager 훅 3개를 신뢰(trust)합니다.
4. AI 도구를 새로 열면 팀 스킬이 보입니다.

<details>
<summary>명령줄로 직접 설치하기</summary>

```sh
git clone https://github.com/SungjinWi99/AIManager.git ~/.aimanager/tool
python3 ~/.aimanager/tool/aimanager.py init https://github.com/SungjinWi99/KTB4-6th-TeamAI.git
```

</details>

## 쓰기

AI 도구에 말로 요청하면 됩니다.

| 하고 싶은 것 | 이렇게 말하세요 |
|---|---|
| 내 스킬을 팀에 공유 | "`my-skill` 스킬 팀에 공유해줘" |
| 팀 스킬 고치기 | "팀 `adr` 스킬에서 ○○ 부분 고쳐서 올려줘" |
| 팀 MCP·플러그인 추가 | "○○ MCP를 팀 MCP로 추가해줘" |
| 사용 통계 | "이번 주 팀 스킬 사용 통계 보여줘" |

공유와 수정은 PR로 올라오고, 리뷰 후 머지되면 다음에 AI 도구를 열 때 모두에게 적용됩니다.

## 지금 있는 팀 스킬

| 스킬 | 하는 일 |
|---|---|
| `adr` | 기술 선택을 함께 결정하고 `docs/adr/`에 ADR로 기록 |
| `domain-modeling` | 대화 중 도메인 용어를 정리해 `CONTEXT.md`에 기록 |
| `grilling` | 계획·설계를 질문으로 끝까지 검증 |
| `grill-with-docs` | `grilling` + `domain-modeling`: 검증하면서 용어집과 ADR까지 정리 |

## 구성

- `skills/` 팀 스킬
- `mcp/mcp.json` 팀 MCP 서버
- `aimanager.json` 팀 플러그인·npm 도구
- `stats` 브랜치 팀 스킬 사용 기록 (시각·도구·스킬 이름·세션 ID만, 프롬프트와 코드는 기록하지 않음)
- `THIRD_PARTY_NOTICES.md` 외부 스킬 출처와 라이선스
