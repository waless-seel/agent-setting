# バックログ

別セッションで対応する保留タスク一覧。

---

## ルール管理・CLAUDE.md 構造化

- [x] **`~/.claude/CLAUDE.md` と `rules/` ディレクトリの構造設計・初期ファイル作成**
  - scope/domain 設計に基づき `~/.claude/rules/git.md`、`~/.claude/rules/shell.md` 等を作成
  - aggregate-reviews で抽出されたルール（確信度「高」）を各ファイルに追記
  - 参照: aggregate-2026-03-09.md セクション B
  - 対応: commit `1377b58` (2026-03-09)

## スキル改善

- [x] **`commit` スキルに自動コミット内容チェック機能を追加**
  - コミット前にステージ対象ファイルの内容をテキスト提示する手順を明示
  - 参照: aggregate-2026-03-09.md セクション E
  - 対応: commit `cdef494` (2026-03-09)

- [x] **`create-git-wiki` SKILL.md（377行）のスリム化検討**
  - スクリプト化できるロジックを読んで確認
  - 参照: aggregate-2026-03-09.md セクション F
  - 対応: commit `c28f560` (2026-03-09)

- [x] **`review-thinking` SKILL.md テンプレート外出し検討**
  - thinking.md の雛形をファイルに分離してトークン削減できるか検証
  - 参照: aggregate-2026-03-09.md セクション F
  - 却下: create-git-wiki と異なり Claude が構造ガイドを動的に読んで生成するためトークン節約効果が薄い。運用パターンも未確立で判断時期尚早。

## Codex 対応

- [ ] **Claude Code スキルの Codex 移植**
  - 概要: `src/skills/` の各スキルを Codex のスキル形式（`~/.codex/skills/` 以下）に変換・配布
  - 事前確認: Codex のグローバルスキルパスとフォーマット（YAML/Markdown）を公式ドキュメントで確認
  - 対象スキル候補: commit / safety-scan / review-thinking / aggregate-reviews
  - setup.ps1 / setup.sh に `Install-CodexSkills` 関数を追加

## aggregate-reviews 改善

- [x] **却下ルールの再登場抑止の仕組みを検討**
  - 今回は手動処理で運用し、パターンが見えてから自動化方式を決める
  - 参照: このセッションの設計議論
  - 対応: commit `c69419e` (2026-03-09) — `rejected-rules.md` による却下履歴管理を SKILL.md に実装

- [x] **`aggregate-reviews` でスキル改善提案を agent-setting に自動反映**
  - 背景: `review-thinking` の Step 9 でスキル改善が承認されると
    `~/.claude/skills/` (インストール先) を直接編集するが、
    ソースである agent-setting リポジトリへの反映は手動になっている
  - 実装方針案:
    - 各 reviews/{slug}/thinking.md の「review-thinking スキルへの改善提案」
      「その他設定・スキルへの改善提案」セクションを aggregate-reviews が収集
    - 未反映の提案を一覧化し、ユーザー確認後に agent-setting の該当 SKILL.md を編集
    - review-thinking の Step 9 では `~/.claude/skills/` への直接編集をやめ、
      agent-setting 経由に一本化することも検討
  - 参照: UnityIndexer セッションレビュー 2026-03-15
  - 対応: commit `7604706` (2026-04-25)
    - aggregate-reviews SKILL.md Step 5-3 に thinking.md 反映状況更新ステップを追加
    - session-reviews 内の stale 未反映エントリを反映済みにバックフィル（4件）
