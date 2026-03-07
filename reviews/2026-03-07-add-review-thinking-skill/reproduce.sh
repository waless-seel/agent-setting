#!/bin/bash
# ============================================================
# [REVIEW-META]
# title: review-thinkingスキルの実装
# date: 2026-03-07
# goal: Create review-thinking skill that records session thinking, decisions, and actions as thinking.md and reproduce script
# tags: [skill-creation, file-write, claude-skills, documentation, plan-execution]
# outcome: success
# ============================================================
#
# 使い方: bash reproduce.sh
# ※ [要手動判断] マークのステップはコメントを参照して手動で実施すること

set -e

# --- 設定 ---
PROJECT_DIR="${PROJECT_DIR:-$(pwd)}"
SKILL_DIR="$PROJECT_DIR/.claude/skills/review-thinking"

# --- Step 1: 既存スキル構造の確認 ---
# [背景] 新スキルを既存スキルと一貫したスタイルで作成するため、先に構造を把握する
# [結果] .claude/skills/create-git-wiki/SKILL.md の形式・フロントマター・ワークフロー記述スタイルを確認
ls "$PROJECT_DIR/.claude/skills/"
cat "$PROJECT_DIR/.claude/skills/create-git-wiki/SKILL.md"

# --- Step 2: [要手動判断] review-thinking/SKILL.md の作成 ---
# [背景] プランドキュメントの設計をSKILL.md形式（フロントマター + ワークフロー記述）に変換する作業は
#        LLMの判断・解釈が必要。コマンドとして表現できない。
# [手順]
#   1. プランドキュメント（review-thinking-plan.md 等）を参照する
#   2. 以下のフロントマター形式で SKILL.md の先頭を作成する:
#      ---
#      name: review-thinking
#      description: >
#        Claude Codeセッションの思考・判断・実行を振り返り、再現可能な形に記録するスキル。...
#      ---
#   3. ワークフローセクション（Step 1〜Step 8）をプランに基づいて記述する
# [判断基準] 生成されたSKILL.mdが .claude/skills/{name}/SKILL.md に配置され、
#            利用可能スキル一覧に表示されれば成功
mkdir -p "$SKILL_DIR"
echo "SKILL.md の内容は手動で作成、またはClaude Codeに依頼してください"
echo "配置先: $SKILL_DIR/SKILL.md"

# --- Step 3: reviewsディレクトリの作成 ---
# [背景] レビューファイルの保存先を用意する
# [結果] reviews/2026-03-07-add-review-thinking-skill/ ディレクトリが作成される
REVIEW_DIR="$PROJECT_DIR/reviews/2026-03-07-add-review-thinking-skill"
mkdir -p "$REVIEW_DIR"
echo "レビューディレクトリ作成: $REVIEW_DIR"

# --- Step 4: [要手動判断] thinking.md の作成 ---
# [背景] セッションの思考プロセス・判断根拠・実行アクションは会話コンテキストから
#        LLMが整理・記述する必要がある。自動化不可。
# [手順]
#   1. セッションの会話ログを振り返る
#   2. thinking.md テンプレートに従い以下を記述:
#      - セッションの目標・背景
#      - 思考プロセスの流れ（narrative）
#      - 主要な判断ポイント（判断テーブル）
#      - 実行したアクション（自動化分類付き）
#      - エラーと対処
#      - 学習・知見
# [判断基準] 後から読んでセッションの判断プロセスが再現できるか
echo "thinking.md は Claude Code のセッションレビューで生成されます"
echo "配置先: $REVIEW_DIR/thinking.md"

# --- Step 5: [要手動判断] reproduce.sh の作成 ---
# [背景] このファイル自体がその成果物。再帰的な説明となる。
# [手順] SKILL.md の Step 5 に従い、セッションのアクションを再現スクリプトとして記述する
echo "reproduce.sh は Claude Code のセッションレビューで生成されます"
echo "配置先: $REVIEW_DIR/reproduce.sh"

# --- Step 6: 完了確認 ---
# [背景] 生成されたファイルを確認する
# [結果] reviews/ ディレクトリ内にファイルが存在することを確認
echo ""
echo "=== 生成ファイル確認 ==="
ls -la "$REVIEW_DIR/"
echo ""
echo "=== スキル確認 ==="
ls -la "$SKILL_DIR/"
