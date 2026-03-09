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
  - 対応: (2026-03-09)

- [ ] **`create-git-wiki` SKILL.md（377行）のスリム化検討**
  - スクリプト化できるロジックを読んで確認
  - 参照: aggregate-2026-03-09.md セクション F

- [ ] **`review-thinking` SKILL.md テンプレート外出し検討**
  - thinking.md の雛形をファイルに分離してトークン削減できるか検証
  - 参照: aggregate-2026-03-09.md セクション F

## aggregate-reviews 改善

- [ ] **却下ルールの再登場抑止の仕組みを検討**
  - 今回は手動処理で運用し、パターンが見えてから自動化方式を決める
  - 参照: このセッションの設計議論
