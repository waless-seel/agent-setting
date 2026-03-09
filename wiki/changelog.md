# 変更履歴

## [Unreleased]

## 2026-03-09

### Added
- `feat(skill):` tackle-backlog スキルを追加
  - **コミット:** `8b7a7aa`
  - BACKLOG.md のタスクを選択・プラン設計・実装・完了マークまで一貫して進める

- `feat(skill):` aggregate-reviews スキルとスクリプトを追加
  - **コミット:** `eb6b9a5`
  - セッションレビューを横断分析して改善提案レポートを生成

### Improved
- `feat(skill):` commit スキルにステージ対象ファイル提示ステップを追加
  - **コミット:** `752de71`
  - コミット前にステージ対象ファイルをテキストで提示するよう明示

- `feat(skill):` create-git-wiki のテンプレートファイルを `templates/` に分離
  - SKILL.md を 377行 → 244行（-35%）にスリム化
  - `index.html` / `serve.sh` / `deploy-wiki.yml` / `netlify.toml` / `vercel.json` を外出し

### Docs
- `feat(setup):` CLAUDE.md を `claude/` に移動し `rules/` ディレクトリ構造を追加
  - **コミット:** `1377b58`

---

## 2026-03-08

### Fixed
- `fix(hook):` Windowsバックスラッシュパスでcopy-reviewフックが発火しない問題を修正
  - **コミット:** `584a363`
  - `copy-review.sh` でパスの `\` を `/` に正規化するよう修正

### Improved
- `improve(skill):` review-thinkingのStep1bに「推測→実測修正の記録」項目を追加
  - **コミット:** `84e9491`

### Added
- `feat(skill):` safety-scanスキル追加
  - **コミット:** `df90413`
  - リポジトリまたはステージ済みファイルのシークレット・APIキーをスキャン
  - スクリプト（`scripts/safety-scan.sh`）+ LLM文脈判断の2段階チェック

- `feat(setup):` copy-review.sh の PostToolUse フックを setup スクリプトに追加
  - **コミット:** `e59da48`

### Refactored
- `refactor:` スキルを `.claude/` から `claude/` に移動（クリーンな分離）
  - **コミット:** `e32c2ff`
  - `.claude/` はgitignoreされる設定ファイル向け、`claude/` は共有スキル向けに分離

---

## 2026-03-07

### Added
- `feat(skill):` review-thinkingスキル追加
  - **コミット:** `cb3bd68`
  - セッションの思考・判断を `thinking.md` + `reproduce.*` として記録
  - 構造化メタデータを埋め込み、将来の横断分析に対応

- セットアップスクリプト追加
  - **コミット:** `dabb254`
  - `setup.sh`（Linux/macOS/WSL）・`setup.ps1`（Windows）で `~/.claude` に一括インストール
  - スキル・settings.json・レビュー設定・フックを自動設定

### Improved
- `improve:` review-thinkingスキルに意思決定ログ・思考ブロックを追加
  - **コミット:** `06dd4b7`

---

## 2025-03-07

### Added
- `docs:` wiki/ ディレクトリを追加（create-git-wikiスキルで生成）
  - **コミット:** `bd99741`
  - Docsify形式のwikiサイト
  - GitHub Pages / Netlify / Vercel デプロイ設定

---

## 2025年（初期開発）

### feat: commit スキル追加
**コミット:** `617b49a`

`claude/skills/commit/SKILL.md` を追加。

**スキルの機能:**
- git変更を分析してConventional Commits形式でコミットメッセージを自動生成
- ステージング済み・未ステージ変更を一括処理
- シークレット混入チェック付き

---

### feat: create-git-wiki スキル追加
**コミット:** `a389ff6`（PR #1 `9d31aa6` でマージ）

`claude/skills/create-git-wiki/SKILL.md` を追加。

**スキルの機能:**
- gitリポジトリのコードベースをAI分析
- Docsify形式のwikiを自動生成
- GitHub Pages / Netlify / Vercel へのデプロイ設定を含む
- mermaid.jsによるアーキテクチャ図生成

---

### gitignoreにclaude関連を追加
**コミット:** `40ece37`

`.gitignore` にClaude Code関連ファイルの除外ルールを追加:
- `auth.json`、`.credentials` — 認証情報
- `settings.json`、`.session` — ローカル環境依存ファイル
- `cache/`、`tmp/` — 自動生成キャッシュ

---

### Initial commit
**コミット:** `9876ed8`

リポジトリ初期化。`README.md`（AIエージェント設定集）、`LICENSE` を追加。
