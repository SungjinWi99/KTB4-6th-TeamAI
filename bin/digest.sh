#!/bin/sh
# 최근 N일(기본 7일) 팀 스킬 사용 요약. 같은 세션에서 같은 스킬은 한 번만 센다.
# 사용: digest.sh [일수]
DIR=$(cd "$(dirname "$0")/.." && pwd)
S="$DIR/.stats"
days=${1:-7}
[ -d "$S/.git" ] || git clone -q --branch stats --single-branch "$(git -C "$DIR" remote get-url origin)" "$S" || exit 1
git -C "$S" pull -q --rebase
since=$(date -u -v-"${days}"d +%F 2>/dev/null || date -u -d "$days days ago" +%F)
set -- "$S"/*.tsv
[ -e "$1" ] || { echo "아직 기록이 없습니다."; exit 0; }
awk -F'\t' -v since="$since" -v days="$days" '
  FNR == 1 { u = FILENAME; sub(/.*\//, "", u); sub(/\.tsv$/, "", u) }
  substr($1, 1, 10) >= since {
    k = ($4 == "-") ? NR : $4 SUBSEP $3
    if (seen[u, k]++) next
    skill[$3]++; user[u]++; tool[$2]++; n++
  }
  function show(title, a,   x, cmd) {
    print "\n" title
    cmd = "sort -t\"\t\" -k2 -rn"
    for (x in a) printf "  %s\t%d\n", x, a[x] | cmd
    close(cmd)
  }
  END {
    printf "최근 %d일 팀 스킬 사용: %d회 (%s 이후)\n", days, n, since
    if (!n) exit
    show("스킬별", skill); show("사람별", user); show("도구별", tool)
  }' "$@"
