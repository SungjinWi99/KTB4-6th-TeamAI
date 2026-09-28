# KTB4 6팀 공용 AI 스킬

Claude Code와 Codex에서 같은 팀 스킬을 쓰기 위한 저장소입니다. AI 도구를 열 때마다 최신 스킬을 받아오고, 팀 스킬 사용 횟수를 하루 한 번 `stats` 브랜치에 기록합니다.

## 설치 (macOS, 한 번만)

저장소 접근 권한(Collaborator)과 GitHub 로그인(`gh auth login` 등)이 필요합니다.

```sh
git clone https://github.com/SungjinWi99/KTB4-6th-TeamAI.git ~/.team-skills
sh ~/.team-skills/bin/install.sh
```

- Claude Code(`~/.claude/settings.json`)와 Codex(`~/.codex/hooks.json`)에 훅을 등록합니다.
- Codex는 `/hooks`에서 새 훅을 신뢰(trust)해야 동작합니다.
- AI 도구를 새로 열면 팀 스킬이 보입니다.

## 쓰기

| 하고 싶은 것 | 방법 |
|---|---|
| 팀 스킬 쓰기 | 평소처럼. Claude Code는 `/스킬이름`, Codex는 `$스킬이름` |
| 내 스킬 공유, 팀 스킬 수정 | `/share-skill` (Codex는 `$share-skill`) → PR이 열림 → 리뷰 후 머지 |
| 지금 바로 최신화 | `sh ~/.team-skills/bin/sync.sh` |
| 사용 통계 보기 | `sh ~/.team-skills/bin/digest.sh` (기본 7일, `digest.sh 30`처럼 일수 지정) |

- 팀 스킬은 `~/.claude/skills`, `~/.agents/skills`에 링크로 들어갑니다. **같은 이름의 개인 스킬이 있으면 개인 스킬이 우선**합니다.
- 팀 스킬을 고치려면 `~/.team-skills`에서 직접 커밋하지 말고 `/share-skill`로 PR을 올리세요.

## 기록되는 것

스킬을 쓴 시각, 도구(claude/codex), 팀 스킬 이름, 세션 ID만 기록합니다. 프롬프트나 코드는 기록하지 않습니다. 같은 세션에서 같은 스킬은 한 번으로 셉니다.

## 제거

`~/.claude/settings.json`, `~/.codex/hooks.json`에서 `.team-skills/bin`이 들어간 훅을 지우고, `~/.claude/skills`, `~/.agents/skills`에서 `~/.team-skills`를 가리키는 링크와 `~/.team-skills` 폴더를 지웁니다.
