#!/usr/bin/env bash
# copy-review.sh
# Claude Code PostToolUse フック: reviews/ にファイルが書かれたら dest にコピーする
#
# インストール先: ~/.claude/scripts/copy-review.sh
# フック設定 (~/.claude/settings.json):
#   "PostToolUse": [{ "matcher": "Write", "hooks": [{ "type": "command", "command": "bash ~/.claude/scripts/copy-review.sh" }] }]

set -euo pipefail

# stdin から JSON を読み込む
input=$(cat)

# file_path を抽出 (python3 で JSON パース)
file_path=$(echo "$input" | python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    # Windows バックスラッシュをスラッシュに正規化
    path = d.get('tool_input', {}).get('file_path', '')
    print(path.replace('\\\\', '/'))
except Exception:
    print('')
" 2>/dev/null)

# reviews/<slug>/ 直下のファイルでなければ終了
if ! echo "$file_path" | grep -qE '/reviews/[^/]+/reproduce\.[^/]+$'; then
  exit 0
fi

slug_dir=$(dirname "$file_path")           # .../reviews/<slug>
reviews_dir=$(dirname "$slug_dir")         # .../reviews
project_root=$(dirname "$reviews_dir")     # プロジェクトルート

# コピー先を設定ファイルから解決（プロジェクト設定 > グローバル設定）
dest=""
for config in \
  "$project_root/.claude/review-thinking.config" \
  "$HOME/.claude/review-thinking.config"; do
  if [[ -f "$config" ]]; then
    dest=$(grep '^dest:' "$config" 2>/dev/null | sed 's/dest: *//' | sed 's/#.*//' | xargs)
    [[ -n "$dest" ]] && break
  fi
done

# dest が未設定ならスキップ
if [[ -z "$dest" ]]; then
  exit 0
fi

# ~ を展開
dest="${dest/#\~/$HOME}"

slug=$(basename "$slug_dir")
mkdir -p "$dest"
cp -r "$slug_dir" "$dest/$slug"

echo "[copy-review] $slug → $dest/" >&2
