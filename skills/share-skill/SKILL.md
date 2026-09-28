---
name: share-skill
description: 내 스킬(새 스킬 또는 팀 스킬 수정본)을 KTB4 6팀 공용 스킬 저장소에 PR로 올린다. "이 스킬 팀에 공유해줘", "팀 스킬 수정 올려줘" 같은 요청에 사용한다.
disable-model-invocation: true
---

# share-skill

사용자가 고른 스킬 폴더를 팀 저장소(`~/.team-skills`)에 PR로 올린다. 머지되면 팀원들의 다음 세션부터 적용된다.

## 1. 올릴 폴더를 정확히 정한다

- 사용자가 경로를 주면 그 경로를 쓴다.
- 이름만 주면 `~/.claude/skills/<이름>`, `~/.agents/skills/<이름>` 순으로 찾는다. 후보가 여러 개거나 없으면 묻는다.
- 경로가 `~/.team-skills/skills/` 안을 가리키면(링크 포함) 팀 스킬을 직접 고친 것이다. 이 경우 수정 PR로 올리고, PR을 만든 뒤 `git -C ~/.team-skills checkout -- skills/<이름>`으로 원래 상태로 되돌린다. 되돌리지 않으면 다음 동기화가 멈춘다.

## 2. 올리기 전에 확인한다

폴더 전체를 읽고 다음이 있으면 사용자에게 알리고 어떻게 할지 묻는다.

- 비밀값(API 키, 토큰), 개인 절대 경로, 개인만 쓰는 도구나 위키에 대한 의존
- 외부 출처의 내용. 출처와 라이선스가 있으면 `THIRD_PARTY_NOTICES.md`에 추가한다.

## 3. PR을 만든다

`<이름>`과 `<원본 경로>`를 채워 실행한다.

```sh
T=~/.team-skills
git -C "$T" fetch -q origin
W=$(mktemp -d)/share
git -C "$T" worktree add -q -b "share/<이름>-$(date +%Y%m%d%H%M)" "$W" origin/main
mkdir -p "$W/skills/<이름>"
rsync -a --delete --exclude .DS_Store "<원본 경로>/" "$W/skills/<이름>/"
git -C "$W" add -A
git -C "$W" commit -m "feat(skills): <이름> 추가"   # 수정이면 "fix(skills): <이름> 수정"
git -C "$W" push -q -u origin HEAD
(cd "$W" && gh pr create --fill)
git -C "$T" worktree remove "$W"
```

`gh`가 없으면 push 결과에 나온 PR 생성 링크를 사용자에게 준다.

## 4. 마무리

PR 링크를 알려준다. 리뷰와 머지는 사람이 하며, 머지 후 각자 AI 도구를 새로 열면 적용된다고 안내한다.
