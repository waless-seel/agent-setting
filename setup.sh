#!/usr/bin/env bash
# agent-setting セットアップスクリプト
# このリポジトリのエージェント設定をユーザーの ~/.claude に適用する

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_CLAUDE_DIR="$SCRIPT_DIR/src"
USER_CLAUDE_DIR="$HOME/.claude"
CODEX_DIR="$HOME/.codex"

# カラー出力
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

info()    { echo -e "${GREEN}[INFO]${NC} $*"; }
warn()    { echo -e "${YELLOW}[WARN]${NC} $*"; }
error()   { echo -e "${RED}[ERROR]${NC} $*" >&2; }

# スキルをコピーする
install_skills() {
  local src="$PROJECT_CLAUDE_DIR/skills"
  local dst="$USER_CLAUDE_DIR/skills"

  if [[ ! -d "$src" ]]; then
    warn "skills ディレクトリが見つかりません: $src"
    return 0
  fi

  mkdir -p "$dst"

  for skill_dir in "$src"/*/; do
    local skill_name
    skill_name="$(basename "$skill_dir")"
    local target="$dst/$skill_name"

    if [[ -d "$target" ]]; then
      warn "スキル '$skill_name' は既に存在します。上書きします..."
    else
      info "スキル '$skill_name' をインストールします..."
    fi

    cp -r "${skill_dir%/}" "$dst/"
    info "  -> $target"
  done
}

# commands をコピーする
install_commands() {
  local src="$PROJECT_CLAUDE_DIR/commands"
  local dst="$USER_CLAUDE_DIR/commands"

  if [[ ! -d "$src" ]]; then
    return 0
  fi

  mkdir -p "$dst"

  for cmd_file in "$src"/*.md; do
    [[ -f "$cmd_file" ]] || continue
    local cmd_name
    cmd_name="$(basename "$cmd_file")"
    info "コマンド '$cmd_name' をインストールします..."
    cp "$cmd_file" "$dst/$cmd_name"
    info "  -> $dst/$cmd_name"
  done
}

# agents をコピーする
install_agents() {
  local src="$PROJECT_CLAUDE_DIR/agents"
  local dst="$USER_CLAUDE_DIR/agents"

  if [[ ! -d "$src" ]]; then
    return 0
  fi

  mkdir -p "$dst"

  for agent_file in "$src"/*.md; do
    [[ -f "$agent_file" ]] || continue
    local agent_name
    agent_name="$(basename "$agent_file")"
    info "エージェント '$agent_name' をインストールします..."
    cp "$agent_file" "$dst/$agent_name"
    info "  -> $dst/$agent_name"
  done
}

# settings.json をマージする（ユーザーのものを上書きしない）
install_settings() {
  local src="$PROJECT_CLAUDE_DIR/settings.json"
  local dst="$USER_CLAUDE_DIR/settings.json"

  if [[ ! -f "$src" ]]; then
    return 0
  fi

  if [[ -f "$dst" ]]; then
    warn "settings.json は既に存在するためスキップします: $dst"
    warn "手動でマージしてください: $src"
  else
    info "settings.json をコピーします..."
    cp "$src" "$dst"
    info "  -> $dst"
  fi
}

# src/CLAUDE.md を ~/.claude/CLAUDE.md にインストール
# src/AGENTS.md を ~/.claude/AGENTS.md にもコピー
install_global_claude_md() {
  local src="$PROJECT_CLAUDE_DIR/CLAUDE.md"
  local dst="$USER_CLAUDE_DIR/CLAUDE.md"

  if [[ ! -f "$src" ]]; then
    warn "CLAUDE.md が見つかりません: $src"
    return 0
  fi

  cp "$src" "$dst"
  info "CLAUDE.md をインストールしました: $dst"

  local agents_src="$PROJECT_CLAUDE_DIR/AGENTS.md"
  if [[ -f "$agents_src" ]]; then
    cp "$agents_src" "$USER_CLAUDE_DIR/AGENTS.md"
    info "AGENTS.md をインストールしました: $USER_CLAUDE_DIR/AGENTS.md"
  fi
}

# src/knowledge/*.md を ~/.claude/knowledge/ と ~/.codex/knowledge/ にインストール
install_knowledge() {
  local src="$PROJECT_CLAUDE_DIR/knowledge"

  if [[ ! -d "$src" ]]; then
    return 0
  fi

  for dst in "$USER_CLAUDE_DIR/knowledge" "$CODEX_DIR/knowledge"; do
    mkdir -p "$dst"
    for file in "$src"/*.md; do
      [[ -f "$file" ]] || continue
      local name
      name="$(basename "$file")"
      cp "$file" "$dst/$name"
      info "ナレッジ '$name' をインストールしました -> $dst/$name"
    done
  done
}

# src/AGENTS.md と src/codex/config.toml を ~/.codex/ にインストール
install_codex_config() {
  local agents_src="$PROJECT_CLAUDE_DIR/AGENTS.md"
  local config_src="$PROJECT_CLAUDE_DIR/codex/config.toml"

  mkdir -p "$CODEX_DIR"

  if [[ -f "$agents_src" ]]; then
    cp "$agents_src" "$CODEX_DIR/AGENTS.md"
    info "Codex: AGENTS.md をインストールしました: $CODEX_DIR/AGENTS.md"
  fi

  if [[ ! -f "$config_src" ]]; then
    return 0
  fi

  cp "$config_src" "$CODEX_DIR/config.toml"
  info "Codex: config.toml をインストールしました: $CODEX_DIR/config.toml"
}

# src/codex/hooks.json を ~/.codex/hooks.json にマージ
install_codex_hooks() {
  local src="$PROJECT_CLAUDE_DIR/codex/hooks.json"
  local dst="$CODEX_DIR/hooks.json"

  if [[ ! -f "$src" ]]; then
    return 0
  fi

  mkdir -p "$CODEX_DIR"

  python3 - "$src" "$dst" << 'PYEOF'
import sys, json, os

src_path = sys.argv[1]
dst_path = sys.argv[2]

with open(src_path, 'r', encoding='utf-8') as f:
    src = json.load(f)

if os.path.exists(dst_path):
    with open(dst_path, 'r', encoding='utf-8') as f:
        dst = json.load(f)
else:
    dst = {}

for event, handlers in src.get("hooks", {}).items():
    dst.setdefault("hooks", {}).setdefault(event, [])
    existing_cmds = {h.get("command") for h in dst["hooks"][event]}
    for h in handlers:
        if h.get("command") not in existing_cmds:
            dst["hooks"][event].append(h)

with open(dst_path, 'w', encoding='utf-8') as f:
    json.dump(dst, f, indent=2, ensure_ascii=False)
    f.write('\n')

print(f"[INFO] Codex hooks をインストールしました: {dst_path}", file=sys.stderr)
PYEOF
}

# copy-review.sh をインストールし、~/.claude/settings.json にフックを登録する
install_copy_review_hook() {
  local scripts_dst="$USER_CLAUDE_DIR/scripts"
  local script_src="$PROJECT_CLAUDE_DIR/skills/review-thinking/scripts/copy-review.sh"
  local settings_file="$USER_CLAUDE_DIR/settings.json"

  # スクリプトをコピー
  mkdir -p "$scripts_dst"
  cp "$script_src" "$scripts_dst/copy-review.sh"
  chmod +x "$scripts_dst/copy-review.sh"
  info "copy-review.sh をインストールしました: $scripts_dst/copy-review.sh"

  # settings.json にフックを追加（python3 で安全にマージ）
  python3 - "$settings_file" << 'PYEOF'
import sys, json, os

settings_path = sys.argv[1]
hook_command = "bash ~/.claude/scripts/copy-review.sh"

# 既存の settings.json を読み込む（なければ空オブジェクト）
if os.path.exists(settings_path):
    with open(settings_path, 'r', encoding='utf-8') as f:
        settings = json.load(f)
else:
    settings = {}

hooks = settings.setdefault("hooks", {})
post_tool_use = hooks.setdefault("PostToolUse", [])

# 既に同じコマンドが登録されていればスキップ
for entry in post_tool_use:
    for h in entry.get("hooks", []):
        if h.get("command") == hook_command:
            print(f"[WARN] copy-review フックは既に登録済みです", file=sys.stderr)
            sys.exit(0)

# Write フックを追加
post_tool_use.append({
    "matcher": "Write",
    "hooks": [{"type": "command", "command": hook_command}]
})

with open(settings_path, 'w', encoding='utf-8') as f:
    json.dump(settings, f, indent=2, ensure_ascii=False)
    f.write('\n')

print(f"[INFO] copy-review フックを登録しました: {settings_path}", file=sys.stderr)
PYEOF

  info "フック登録完了"
}

# review-thinking のグローバル設定を生成する
install_review_config() {
  local config_path="$USER_CLAUDE_DIR/review-thinking.config"

  if [[ -f "$config_path" ]]; then
    warn "review-thinking.config は既に存在します: $config_path"

    # agent-setting-path が未設定の場合は追記する
    if ! grep -q '^agent-setting-path:' "$config_path"; then
      echo ""
      echo "aggregate-reviews スキルのために agent-setting リポジトリのパスを設定します。"
      echo "（空のままEnterでスキップ）"
      read -r -p "agent-setting リポジトリのパス [デフォルト: ${SCRIPT_DIR}]: " agent_path_input

      if [[ -z "$agent_path_input" ]]; then
        agent_path_input="$SCRIPT_DIR"
      fi

      echo "agent-setting-path: ${agent_path_input}" >> "$config_path"
      info "agent-setting-path を追記しました: $agent_path_input"
    else
      warn "agent-setting-path は既に設定済みです。上書きする場合は手動で編集してください"
    fi

    return 0
  fi

  echo ""
  echo "review-thinking スキルのレビュー蓄積先を設定します。"
  echo "複数プロジェクトのレビューをまとめて保存するフォルダを指定してください。"
  echo "（空のままEnterでスキップ）"
  read -r -p "reviews 蓄積先フォルダ [デフォルト: ~/session-reviews]: " dest_input

  if [[ -z "$dest_input" ]]; then
    dest_input="$HOME/session-reviews"
  fi

  # ~ を展開してフォルダを作成
  local dest_expanded="${dest_input/#\~/$HOME}"
  mkdir -p "$dest_expanded"

  echo ""
  echo "aggregate-reviews スキルのために agent-setting リポジトリのパスを設定します。"
  echo "（空のままEnterでスキップ）"
  read -r -p "agent-setting リポジトリのパス [デフォルト: ${SCRIPT_DIR}]: " agent_path_input

  if [[ -z "$agent_path_input" ]]; then
    agent_path_input="$SCRIPT_DIR"
  fi

  cat > "$config_path" << EOF
# review-thinking グローバル設定
# このファイルは ~/.claude/review-thinking.config に配置され、全プロジェクト共通で参照される
# プロジェクト内の .claude/review-thinking.config があればそちらが優先される
dest: ${dest_input}
agent-setting-path: ${agent_path_input}
EOF

  info "review-thinking.config を作成しました: $config_path"
  info "蓄積先: $dest_input"
  info "agent-setting パス: $agent_path_input"
}

main() {
  echo "================================================"
  echo " agent-setting セットアップ"
  echo "================================================"
  echo ""
  info "インストール先: $USER_CLAUDE_DIR"
  echo ""

  mkdir -p "$USER_CLAUDE_DIR"

  install_skills
  install_global_claude_md
  install_knowledge
  install_commands
  install_agents
  install_settings
  install_review_config
  install_copy_review_hook
  install_codex_config
  install_codex_hooks

  echo ""
  info "セットアップ完了！"
  echo ""
  echo "インストールされた内容を確認するには:"
  echo "  ls $USER_CLAUDE_DIR/skills/"
  echo "  ls $CODEX_DIR/"
}

main "$@"
