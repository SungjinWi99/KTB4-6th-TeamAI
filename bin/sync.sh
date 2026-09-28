#!/bin/sh
# 세션 시작 훅에서 백그라운드로 실행된다.
# 팀 스킬을 받아 각 에이전트의 스킬 폴더에 링크하고, 하루 한 번 사용 기록을 stats 브랜치에 보고한다.
DIR=$(cd "$(dirname "$0")/.." && pwd)

git -C "$DIR" pull -q --ff-only 2>/dev/null

# Claude Code는 ~/.claude/skills, Codex는 ~/.agents/skills를 읽는다.
for target in "$HOME/.claude/skills" "$HOME/.agents/skills"; do
  mkdir -p "$target"
  for s in "$DIR"/skills/*/; do
    link="$target/$(basename "$s")"
    [ -e "$link" ] && [ ! -L "$link" ] && continue # 같은 이름의 개인 스킬이 우선한다
    ln -sfn "${s%/}" "$link"
  done
  # 팀 저장소에서 삭제된 스킬의 링크를 정리한다 (다른 링크는 건드리지 않는다)
  for l in "$target"/*; do
    [ -L "$l" ] && [ ! -e "$l" ] && case "$(readlink "$l")" in "$DIR"/*) rm "$l" ;; esac
  done
done

# 하루 한 번만 보고한다. 기록이 없으면 커밋하지 않는다.
today=$(date +%F)
[ "$(cat "$DIR/.reported" 2>/dev/null)" = "$today" ] && exit 0
[ -s "$DIR/.usage.tsv" ] || exit 0
S="$DIR/.stats"
[ -d "$S/.git" ] || git clone -q --branch stats --single-branch "$(git -C "$DIR" remote get-url origin)" "$S" || exit 0
git -C "$S" pull -q --rebase || exit 0
# 보고 중에 새로 쌓이는 기록을 잃지 않도록 먼저 옮겨둔다
mv "$DIR/.usage.tsv" "$DIR/.usage.sending"
user=$(cat "$DIR/.user")
cat "$DIR/.usage.sending" >>"$S/$user.tsv"
git -C "$S" add "$user.tsv"
if git -C "$S" commit -qm "stats: $user $today" &&
  { git -C "$S" push -q || { git -C "$S" pull -q --rebase && git -C "$S" push -q; }; }; then
  rm "$DIR/.usage.sending"
  echo "$today" >"$DIR/.reported"
else
  git -C "$S" reset -q --hard "@{u}"
  cat "$DIR/.usage.sending" >>"$DIR/.usage.tsv" && rm "$DIR/.usage.sending"
fi
