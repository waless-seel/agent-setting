#!/usr/bin/env bash
# aggregate-reviews.sh
# session-reviews に蓄積されたレビューの [REVIEW-META] を集積し、
# thinking.md の各セクションを抽出して構造化出力する
#
# 使い方:
#   bash aggregate-reviews.sh --dest DIR [--since YYYY-MM-DD] [--project NAME]
#                              [--sections meta,rules,proposals,decisions]
#
# インストール先: ~/.claude/scripts/aggregate-reviews.sh
#
# 出力形式:
#   ===AGGREGATE-START===
#   generated: YYYY-MM-DD
#   review_count: N
#   dest: /path/to/dest
#
#   ===META-SUMMARY===
#   REVIEW:slug|date:...|outcome:...|project:...|tags:...
#
#   ===RULES-START:slug===
#   ...
#   ===RULES-END===
#
#   ===PROPOSALS-RT-START:slug===
#   ...
#   ===PROPOSALS-RT-END===
#
#   ===PROPOSALS-OTHER-START:slug===
#   ...
#   ===PROPOSALS-OTHER-END===
#
#   ===DECISIONS-START:slug===
#   ...
#   ===DECISIONS-END===
#
#   ===AGGREGATE-END===
#
# 終了コード: 0=正常, 1=dest未存在またはレビュー0件

set -euo pipefail

DEST=""
SINCE=""
PROJECT_FILTER=""
SECTIONS="meta,rules,proposals,decisions"

# --- 引数解析 ---
while [[ $# -gt 0 ]]; do
  case "$1" in
    --dest)     DEST="$2";           shift 2 ;;
    --since)    SINCE="$2";          shift 2 ;;
    --project)  PROJECT_FILTER="$2"; shift 2 ;;
    --sections) SECTIONS="$2";       shift 2 ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
done

if [[ -z "$DEST" ]]; then
  echo "Error: --dest is required" >&2
  exit 1
fi

# ~ を展開
DEST="${DEST/#\~/$HOME}"

if [[ ! -d "$DEST" ]]; then
  echo "Error: dest directory not found: $DEST" >&2
  exit 1
fi

# --- セクション有効チェック ---
has_section() {
  echo "$SECTIONS" | grep -qE "(^|,)$1(,|$)"
}

# --- REVIEW-META から1フィールドを取得 ---
get_meta_field() {
  local file="$1" field="$2"
  awk -v f="$field" '
    /\[REVIEW-META\]/ { in_meta=1; next }
    in_meta && /^#[[:space:]]*=+/ { exit }
    in_meta {
      if (sub("^#[[:space:]]*" f ":[[:space:]]*", "")) { print; exit }
    }
  ' "$file"
}

# --- thinking.md のセクションを次の ## まで抽出 ---
extract_section() {
  local file="$1" header="$2"
  awk -v hdr="$header" '
    $0 == hdr { found=1; next }
    /^## / && found { exit }
    found { print }
  ' "$file"
}

# --- レビュー収集 ---
REVIEW_COUNT=0
declare -a slugs=()
declare -a dates=()
declare -a outcomes=()
declare -a projects=()
declare -a tags=()
declare -a dirs=()

while IFS= read -r reproduce_file; do
  [[ -f "$reproduce_file" ]] || continue

  local_dir="$(dirname "$reproduce_file")"
  slug="$(basename "$local_dir")"

  rev_date="$(get_meta_field "$reproduce_file" "date")"
  rev_outcome="$(get_meta_field "$reproduce_file" "outcome")"
  rev_project="$(get_meta_field "$reproduce_file" "project")"
  rev_tags="$(get_meta_field "$reproduce_file" "tags")"

  # --since フィルタ（date が空の場合はスキップしない）
  if [[ -n "$SINCE" && -n "$rev_date" && "$rev_date" < "$SINCE" ]]; then
    continue
  fi

  # --project フィルタ
  if [[ -n "$PROJECT_FILTER" && "$rev_project" != "$PROJECT_FILTER" ]]; then
    continue
  fi

  slugs+=("$slug")
  dates+=("$rev_date")
  outcomes+=("$rev_outcome")
  projects+=("$rev_project")
  tags+=("$rev_tags")
  dirs+=("$local_dir")
  REVIEW_COUNT=$((REVIEW_COUNT + 1))

done < <(find "$DEST" -maxdepth 2 -name "reproduce.*" | sort)

if [[ $REVIEW_COUNT -eq 0 ]]; then
  echo "Error: no reviews found in $DEST" >&2
  exit 1
fi

# --- 出力 ---
GENERATED_DATE="$(date '+%Y-%m-%d')"

echo "===AGGREGATE-START==="
echo "generated: $GENERATED_DATE"
echo "review_count: $REVIEW_COUNT"
echo "dest: $DEST"
echo ""

if has_section "meta"; then
  echo "===META-SUMMARY==="
  for i in "${!slugs[@]}"; do
    echo "REVIEW:${slugs[$i]}|date:${dates[$i]}|outcome:${outcomes[$i]}|project:${projects[$i]}|tags:${tags[$i]}"
  done
  echo ""
fi

for i in "${!slugs[@]}"; do
  slug="${slugs[$i]}"
  local_dir="${dirs[$i]}"
  thinking_file="$local_dir/thinking.md"

  [[ -f "$thinking_file" ]] || continue

  if has_section "rules"; then
    echo "===RULES-START:${slug}==="
    extract_section "$thinking_file" "## 抽出したルール"
    echo "===RULES-END==="
    echo ""
  fi

  if has_section "proposals"; then
    echo "===PROPOSALS-RT-START:${slug}==="
    extract_section "$thinking_file" "## review-thinking スキルへの改善提案"
    echo "===PROPOSALS-RT-END==="
    echo ""

    echo "===PROPOSALS-OTHER-START:${slug}==="
    extract_section "$thinking_file" "## その他設定・スキルへの改善提案"
    echo "===PROPOSALS-OTHER-END==="
    echo ""
  fi

  if has_section "decisions"; then
    echo "===DECISIONS-START:${slug}==="
    extract_section "$thinking_file" "## 意思決定ログ"
    echo "===DECISIONS-END==="
    echo ""
  fi

done

echo "===AGGREGATE-END==="

exit 0
