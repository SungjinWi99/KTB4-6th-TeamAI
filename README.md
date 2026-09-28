# KTB4 6팀 공용 AI 스킬·플러그인·MCP

[AIManager](https://github.com/SungjinWi99/AIManager)로 관리하는 팀 데이터 저장소입니다 (비공개).

## 설치 (한 번만)

저장소 Collaborator 초대 수락과 GitHub 로그인(`gh auth login`)이 필요합니다.

```sh
git clone https://github.com/SungjinWi99/AIManager.git ~/.aimanager/tool
python3 ~/.aimanager/tool/aimanager.py init https://github.com/SungjinWi99/KTB4-6th-TeamAI.git
```

Codex를 쓰면 Codex의 `/hooks`에서 AIManager 훅을 신뢰(trust)해 주세요. AI 도구를 새로 열면 팀 스킬이 보입니다.

## 쓰기

AI에게 말로 요청하면 됩니다: "이 스킬 팀에 공유해줘", "팀 MCP에 ○○ 추가해줘", "팀 스킬 사용 통계 보여줘".
명령은 [AIManager README](https://github.com/SungjinWi99/AIManager#명령)를 보세요.

## 구성

- `skills/` 팀 스킬: `adr`, `domain-modeling`, `grilling`, `grill-with-docs`
- `mcp/mcp.json` 팀 MCP 서버
- `aimanager.json` 팀 플러그인·npm 도구 선언
- `stats` 브랜치 팀 스킬 사용 기록
- `THIRD_PARTY_NOTICES.md` 외부 스킬 출처와 라이선스
