#!/bin/sh
# 한 번만 실행한다 (다시 실행해도 안전). 사용자 이름 저장, Claude Code·Codex 훅 등록, 첫 동기화.
set -e
DIR=$(cd "$(dirname "$0")/.." && pwd)

if [ ! -s "$DIR/.user" ]; then
  u=$(gh api user --jq .login 2>/dev/null || git config user.name || whoami)
  printf '%s\n' "$u" | tr -c 'A-Za-z0-9_.\n-' '_' >"$DIR/.user"
fi

python3 - "$DIR" <<'EOF'
import json, os, sys

d = sys.argv[1]
sync = f'sh "{d}/bin/sync.sh" >/dev/null 2>&1 &'
track = lambda tool: f'sh "{d}/bin/track.sh" {tool} >/dev/null 2>&1'
configs = {
    "~/.claude/settings.json": {
        "SessionStart": [("startup", sync)],
        "UserPromptSubmit": [(None, track("claude"))],
        "PostToolUse": [("Skill", track("claude"))],
    },
    "~/.codex/hooks.json": {
        "SessionStart": [("startup", sync)],
        "UserPromptSubmit": [(None, track("codex"))],
        "PostToolUse": [("Bash", track("codex"))],
    },
}
for path, events in configs.items():
    path = os.path.expanduser(path)
    os.makedirs(os.path.dirname(path), exist_ok=True)
    cfg = json.load(open(path)) if os.path.exists(path) else {}
    hooks = cfg.setdefault("hooks", {})
    # 예전에 등록한 우리 훅을 지우고 다시 넣는다
    for name in list(hooks):
        hooks[name] = [g for g in hooks[name] if not any(f"{d}/bin/" in h.get("command", "") for h in g.get("hooks", []))]
        if not hooks[name]:
            del hooks[name]
    for name, entries in events.items():
        for matcher, cmd in entries:
            group = {"hooks": [{"type": "command", "command": cmd}]}
            if matcher:
                group["matcher"] = matcher
            hooks.setdefault(name, []).append(group)
    json.dump(cfg, open(path, "w"), indent=2, ensure_ascii=False)
    print("훅 등록:", path)
EOF

sh "$DIR/bin/sync.sh"
echo "완료. 사용자: $(cat "$DIR/.user")"
echo "Codex를 쓴다면 Codex에서 /hooks 를 열고 새 훅을 신뢰(trust)해 주세요."
echo "AI 도구를 새로 열면 팀 스킬이 보입니다."
