#!/usr/bin/env bash
# agent-setting セットアップスクリプト
# このリポジトリのエージェント設定をユーザーの ~/.claude に適用する

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_CLAUDE_DIR="$SCRIPT_DIR/.claude"
USER_CLAUDE_DIR="$HOME/.claude"

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

    cp -r "$skill_dir" "$dst/"
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

main() {
  echo "================================================"
  echo " agent-setting セットアップ"
  echo "================================================"
  echo ""
  info "インストール先: $USER_CLAUDE_DIR"
  echo ""

  mkdir -p "$USER_CLAUDE_DIR"

  install_skills
  install_commands
  install_agents
  install_settings

  echo ""
  info "セットアップ完了！"
  echo ""
  echo "インストールされた内容を確認するには:"
  echo "  ls $USER_CLAUDE_DIR/skills/"
}

main "$@"
