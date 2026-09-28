#!/bin/sh
# 훅 입력(JSON)에서 팀 스킬 사용을 찾아 .usage.tsv에 한 줄씩 기록한다.
# 팀 스킬 이름만 기록하며 프롬프트나 명령 원문은 저장하지 않는다. 아무것도 출력하지 않는다.
# 사용: track.sh <claude|codex>  (stdin: 훅 JSON)
DIR=$(cd "$(dirname "$0")/.." && pwd)
in=$(cat)
sid=$(printf '%s' "$in" | grep -o '"session_id" *: *"[^"]*"' | head -1 | sed 's/.*"\([^"]*\)"$/\1/')
names=$({
  # Claude Code Skill 도구: "skill": "adr"
  printf '%s' "$in" | grep -o '"skill" *: *"[^"]*"' | sed 's/.*"\([^"]*\)"$/\1/'
  # 셸로 SKILL.md를 읽은 경우 (Codex)
  printf '%s' "$in" | grep -o 'skills/[A-Za-z0-9_-]*/SKILL\.md' | cut -d/ -f2
  # 프롬프트 맨 앞의 /스킬 (Claude Code), 프롬프트 안의 $스킬 (Codex)
  printf '%s' "$in" | grep -o '"prompt" *: *"/[A-Za-z0-9_-]*' | sed 's/.*\///'
  printf '%s' "$in" | grep -o '\$[A-Za-z0-9_-]*' | cut -c2-
} | sort -u)
for n in $names; do
  [ -f "$DIR/skills/$n/SKILL.md" ] || continue # 팀 스킬만 센다
  printf '%s\t%s\t%s\t%s\n' "$(date -u +%FT%TZ)" "$1" "$n" "${sid:--}" >>"$DIR/.usage.tsv"
done
exit 0
