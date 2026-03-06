# 変更履歴

## [Unreleased]

## 2025-03-07

### Added
- `docs:` wiki/ ディレクトリを追加（create-git-wikiスキルで生成）
  - Docsify形式のwikiサイト
  - GitHub Pages / Netlify / Vercel デプロイ設定

---

## 2025年（初期開発）

### sync
**コミット:** `7136da2`

設定の同期。

---

### feat: create-git-wiki スキル追加
**コミット:** `a389ff6` （PR #1 `9d31aa6` でマージ）

`.claude/skills/create-git-wiki/SKILL.md` を追加。

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
