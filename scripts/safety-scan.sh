#!/usr/bin/env bash
# safety-scan.sh
# 第1パス: シークレット・APIキー・.gitignore漏れの候補を検出する
#
# 使い方: bash safety-scan.sh [repo|staged]
#   repo   (デフォルト) git ls-files 対象でリポジトリ全体をスキャン
#   staged git diff --cached 対象でステージ済みのみをスキャン
#
# インストール先: ~/.claude/scripts/safety-scan.sh
#
# 出力形式:
#   FOUND:file:line:content        シークレット候補
#   GITIGNORE_RISK:file            追跡すべきでないファイル
#
# 終了コード: 0=候補なし, 1=候補あり

set -euo pipefail

MODE="${1:-repo}"

# --- シークレット候補パターン（大文字小文字不問） ---
SECRET_PATTERNS=(
  'API[_-]?KEY\s*[=:]\s*["\x27]?\S{8,}'
  'SECRET[_-]?KEY\s*[=:]\s*["\x27]?\S{8,}'
  'ACCESS[_-]?KEY\s*[=:]\s*["\x27]?\S{8,}'
  'PRIVATE[_-]?KEY\s*[=:]\s*["\x27]?\S{8,}'
  'PASSWORD\s*[=:]\s*["\x27]?\S{4,}'
  'TOKEN\s*[=:]\s*["\x27]?\S{10,}'
  'AWS_SECRET_ACCESS_KEY'
  'GITHUB_TOKEN\s*[=:]'
  'DATABASE_URL\s*[=:]\s*["\x27]?\S+'
  '-----BEGIN .* PRIVATE KEY-----'
)

# --- .gitignore 漏れチェック: 追跡されているとNGなパターン ---
GITIGNORE_RISK_PATTERNS=(
  '\.env$'
  '\.env\.'
  '\.key$'
  '\.pem$'
  '\.p12$'
  '\.pfx$'
  '\.sqlite$'
  '\.db$'
)

FOUND_ANY=0

# バイナリファイルを除外するヘルパー
is_text_file() {
  local file="$1"
  # file コマンドがあれば使う、なければ git check-attr で判定
  if command -v file &>/dev/null; then
    file --mime-encoding "$file" 2>/dev/null | grep -qv 'binary'
  else
    # git がバイナリと判断するファイルは -diff 属性を持つ
    git check-attr diff "$file" 2>/dev/null | grep -qv 'unset\|binary'
  fi
}

# シークレットパターンスキャン（repo モード）
scan_repo_secrets() {
  local files
  files=$(git ls-files 2>/dev/null) || return 0

  while IFS= read -r file; do
    [[ -f "$file" ]] || continue
    is_text_file "$file" || continue

    for pattern in "${SECRET_PATTERNS[@]}"; do
      # grep -n で行番号付き出力、-i で大文字小文字不問
      while IFS= read -r match; do
        local lineno content
        lineno="${match%%:*}"
        content="${match#*:}"
        echo "FOUND:${file}:${lineno}:${content}"
        FOUND_ANY=1
      done < <(grep -inP -e "$pattern" "$file" 2>/dev/null || true)
    done
  done <<< "$files"
}

# シークレットパターンスキャン（staged モード）
scan_staged_secrets() {
  local diff_output
  diff_output=$(git diff --cached -U0 2>/dev/null) || return 0

  local current_file=""
  local line_offset=0

  while IFS= read -r line; do
    # ファイル名の行
    if [[ "$line" =~ ^\+\+\+\ b/(.+)$ ]]; then
      current_file="${BASH_REMATCH[1]}"
      line_offset=0
      continue
    fi
    # hunk ヘッダから追加先行番号を取得
    if [[ "$line" =~ ^@@.*\+([0-9]+) ]]; then
      line_offset="${BASH_REMATCH[1]}"
      continue
    fi
    # 追加行のみチェック（+ で始まり ++ でない）
    if [[ "$line" =~ ^\+[^\+] ]]; then
      local content="${line:1}"
      for pattern in "${SECRET_PATTERNS[@]}"; do
        if echo "$content" | grep -iqP -e "$pattern" 2>/dev/null; then
          echo "FOUND:${current_file}:${line_offset}:${content}"
          FOUND_ANY=1
        fi
      done
      (( line_offset++ )) || true
    elif [[ ! "$line" =~ ^- ]]; then
      # コンテキスト行（変更なし）は行番号だけ進める
      (( line_offset++ )) || true
    fi
  done <<< "$diff_output"
}

# .gitignore リスクファイルチェック（repo / staged 共通）
scan_gitignore_risk() {
  local files
  if [[ "$MODE" == "staged" ]]; then
    files=$(git diff --cached --name-only 2>/dev/null) || return 0
  else
    files=$(git ls-files 2>/dev/null) || return 0
  fi

  while IFS= read -r file; do
    for pattern in "${GITIGNORE_RISK_PATTERNS[@]}"; do
      if echo "$file" | grep -qP "$pattern" 2>/dev/null; then
        echo "GITIGNORE_RISK:${file}"
        FOUND_ANY=1
        break
      fi
    done
  done <<< "$files"
}

# メイン
case "$MODE" in
  staged)
    scan_staged_secrets
    scan_gitignore_risk
    ;;
  repo|*)
    scan_repo_secrets
    scan_gitignore_risk
    ;;
esac

exit "$FOUND_ANY"
