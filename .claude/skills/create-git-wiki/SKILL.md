---
name: create-git-wiki
description: gitリポジトリのコードベースをAIで分析し、Docsify形式のwikiを自動生成するスキル。複数のMarkdownファイルで構成されたwebページとして、ローカルまたはGitHub Pages / Netlify / Vercelでホスト可能。deepwikiにインスパイアされた包括的なドキュメント生成。
---

# create-git-wiki

gitリポジトリのコードベースを分析し、deepwikiにインスパイアされた包括的なwikiをDocsify形式で自動生成する。
生成したwikiはローカルサーバーでプレビューでき、GitHub Pages・Netlify・Vercelへのデプロイにも対応する。

## 出力構成

```
wiki/
├── index.html              # Docsify エントリポイント（ビルド不要）
├── .nojekyll               # GitHub Pages の Jekyll 無効化
├── README.md               # ホームページ（プロジェクト概要・クイックスタート）
├── _sidebar.md             # サイドバーナビゲーション定義
├── overview.md             # アーキテクチャ概要・技術スタック・データフロー
├── modules/                # モジュール・コンポーネント別詳細ドキュメント
│   └── {module-name}.md
├── api.md                  # API仕様・インターフェース（該当する場合）
├── contributing.md         # 開発環境セットアップ・コントリビュートガイド
├── changelog.md            # git historyから生成した変更履歴
├── serve.sh                # ローカルプレビュー用サーバースクリプト
├── netlify.toml            # Netlify デプロイ設定
└── vercel.json             # Vercel デプロイ設定

.github/
└── workflows/
    └── deploy-wiki.yml     # GitHub Pages 自動デプロイワークフロー
```

## ワークフロー

Todoリストを作成して、以下の各タスクを順番に実行すること。

### 1. リポジトリ分析

以下のファイルを優先的に読み込み、プロジェクトを把握する:

- `README.md` / `README.rst` — プロジェクト概要・目的
- `package.json` / `pyproject.toml` / `Cargo.toml` / `go.mod` / `Gemfile` — 技術スタック・依存関係
- ソースコードのエントリポイント（`src/`, `app/`, `lib/`, `cmd/` 等）
- 設定ファイル（`.env.example`, `docker-compose.yml`, `Makefile` 等）
- `git log --oneline -50` — 変更履歴・開発の流れ

把握すべき内容:
- プロジェクトの目的・ユースケース
- 技術スタック・フレームワーク
- ディレクトリ構成・モジュール分割
- 主要なクラス・関数・API
- セットアップ手順

### 2. Wiki構成設計

分析結果に基づいてwikiのページ構成を決定する。

**標準ページ構成:**

| ページ | 内容 | 省略条件 |
|--------|------|----------|
| `README.md` | ホーム・概要・クイックスタート | 省略不可 |
| `overview.md` | アーキテクチャ・技術スタック・設計思想 | 省略不可 |
| `modules/{name}.md` | 各モジュール・コンポーネントの詳細 | モジュールが1つなら単一ファイル |
| `api.md` | APIエンドポイント・インターフェース仕様 | APIがない場合は省略 |
| `contributing.md` | 開発環境・テスト・コントリビュート方法 | 省略不可 |
| `changelog.md` | git historyから生成した変更履歴 | git logが取得できない場合は省略 |

mermaidダイアグラムの活用指針:
- アーキテクチャ図 → `graph TD` または `graph LR`
- データフロー → `sequenceDiagram`
- ER図 → `erDiagram`
- クラス図 → `classDiagram`

### 3. Markdownコンテンツ生成

各ページをコードベース分析に基づいて生成する。

**コンテンツの品質基準（deepwikiスタイル）:**
- 単なるコードの羅列ではなく、**なぜそう設計されているか**を説明する
- mermaid.jsでアーキテクチャ・フロー図を積極的に使用する
- コードスニペットには言語指定のシンタックスハイライトを付ける
- 各ページは独立して読めるようにする（コンテキストを補足する）
- 日本語または英語（リポジトリのREADMEに合わせる）

**`README.md`（ホームページ）の構成例:**
```markdown
# {プロジェクト名}

> {一行サマリー}

## 概要

{プロジェクトの目的・解決する問題・主要な特徴}

## クイックスタート

\`\`\`bash
{最小限のセットアップコマンド}
\`\`\`

## ドキュメント

- [アーキテクチャ概要](overview.md)
- [モジュール詳細](modules/)
- [API仕様](api.md)
- [開発ガイド](contributing.md)
```

**`overview.md`（アーキテクチャ）の構成例:**
```markdown
# アーキテクチャ概要

## システム構成

\`\`\`mermaid
graph TD
    A[クライアント] --> B[APIゲートウェイ]
    B --> C[サービス層]
    C --> D[データ層]
\`\`\`

## 技術スタック

| レイヤー | 技術 | 理由 |
|--------|------|------|
| ...    | ...  | ...  |

## データフロー

\`\`\`mermaid
sequenceDiagram
    ...
\`\`\`
```

**`_sidebar.md`（ナビゲーション）の構成例:**
```markdown
- [ホーム](/)
- **ガイド**
  - [アーキテクチャ概要](overview.md)
  - [モジュール](modules/)
    - [{モジュール名}](modules/{name}.md)
  - [API仕様](api.md)
- **開発**
  - [コントリビュートガイド](contributing.md)
  - [変更履歴](changelog.md)
```

### 4. Docsify セットアップ

`wiki/index.html` を生成する。リポジトリ名・URLは実際の値を設定すること。

```html
<!DOCTYPE html>
<html lang="ja">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>{リポジトリ名} Wiki</title>
  <link rel="icon" href="https://docsify.js.org/_media/favicon.ico">
  <link rel="stylesheet" href="//cdn.jsdelivr.net/npm/docsify@4/lib/themes/vue.css">
  <style>
    :root {
      --theme-color: #42b983;
    }
    .sidebar-nav li > a {
      font-weight: normal;
    }
    .sidebar-nav > ul > li > a {
      font-weight: bold;
    }
  </style>
</head>
<body>
  <div id="app">Loading...</div>
  <script>
    window.$docsify = {
      name: '{リポジトリ名}',
      repo: '{GitHubリポジトリURL（わかる場合）}',
      homepage: 'README.md',
      loadSidebar: true,
      subMaxLevel: 3,
      auto2top: true,
      search: {
        maxAge: 86400000,
        paths: 'auto',
        placeholder: '検索...',
        noData: '結果なし',
        depth: 6,
      },
      copyCode: {
        buttonText: 'コピー',
        errorText: 'エラー',
        successText: 'コピーしました',
      },
      mermaidConfig: {
        querySelector: '.mermaid',
      },
    }
  </script>
  <!-- Docsify core -->
  <script src="//cdn.jsdelivr.net/npm/docsify@4/lib/docsify.min.js"></script>
  <!-- Plugins -->
  <script src="//cdn.jsdelivr.net/npm/docsify@4/lib/plugins/search.min.js"></script>
  <script src="//cdn.jsdelivr.net/npm/docsify-copy-code@2/dist/docsify-copy-code.min.js"></script>
  <!-- Mermaid -->
  <script src="//cdn.jsdelivr.net/npm/mermaid/dist/mermaid.min.js"></script>
  <script src="//cdn.jsdelivr.net/npm/docsify-mermaid@latest/dist/docsify-mermaid.js"></script>
  <script>mermaid.initialize({ startOnLoad: false });</script>
</body>
</html>
```

`wiki/.nojekyll` を生成する（空ファイルで可）。

### 5. ローカルサーバースクリプト

`wiki/serve.sh` を生成する:

```bash
#!/bin/bash
# wiki ローカルプレビューサーバー
# 使い方: bash wiki/serve.sh

PORT=${1:-3000}

echo "Wiki を起動しています..."
echo "ブラウザで http://localhost:${PORT} を開いてください"
echo "停止するには Ctrl+C を押してください"
echo ""

cd "$(dirname "$0")"

if command -v python3 &>/dev/null; then
  python3 -m http.server "$PORT"
elif command -v python &>/dev/null; then
  python -m SimpleHTTPServer "$PORT"
elif command -v npx &>/dev/null; then
  npx serve . -p "$PORT"
else
  echo "エラー: python3 / python / npx のいずれかが必要です"
  exit 1
fi
```

`chmod +x wiki/serve.sh` を実行して実行権限を付与する。

### 6. 外部ホスティング設定

#### GitHub Pages（`.github/workflows/deploy-wiki.yml`）

```yaml
name: Deploy Wiki to GitHub Pages

on:
  push:
    branches: [main, master]
    paths:
      - 'wiki/**'
  workflow_dispatch:

permissions:
  contents: write

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Deploy to GitHub Pages
        uses: peaceiris/actions-gh-pages@v4
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          publish_dir: ./wiki
          publish_branch: gh-pages
          force_orphan: true
```

**GitHub Pages 有効化の案内（スキル完了後にユーザーへ伝える）:**
- リポジトリの Settings → Pages → Source を `gh-pages` ブランチに設定

#### Netlify（`wiki/netlify.toml`）

```toml
[build]
  publish = "."

[[headers]]
  for = "/*"
  [headers.values]
    Cache-Control = "public, max-age=3600"
```

#### Vercel（`wiki/vercel.json`）

```json
{
  "outputDirectory": ".",
  "trailingSlash": true,
  "headers": [
    {
      "source": "/(.*)",
      "headers": [
        { "key": "Cache-Control", "value": "public, max-age=3600" }
      ]
    }
  ]
}
```

### 7. コミット＆プッシュ

生成した全ファイルをステージングしてコミットし、ブランチにプッシュする。

コミットメッセージ例:
```
docs: add Docsify wiki generated by create-git-wiki skill

- wiki/ directory with Docsify setup
- GitHub Pages / Netlify / Vercel deployment config
- Architecture diagrams with mermaid.js
```

## ローカル検証手順

ファイル生成後、以下を実行してwikiが正しく動作するか確認する:

```bash
bash wiki/serve.sh
```

ブラウザで `http://localhost:3000` を開き、以下を確認:
- [ ] サイドバーが表示される
- [ ] ホームページ（README.md）が表示される
- [ ] 各ページのリンクが機能する
- [ ] mermaid図が正しくレンダリングされる
- [ ] 検索機能が動作する

## まとめメッセージ

スキル完了後、以下のフォーマットでユーザーに報告する:

```
## Wiki 生成完了！

### 生成したページ
- {生成したページの一覧と簡単な説明}

### ローカルプレビュー
\`\`\`bash
bash wiki/serve.sh
\`\`\`
→ http://localhost:3000 をブラウザで開く

### 外部ホスティング

**GitHub Pages:**
1. リポジトリの Settings → Pages → Source → `gh-pages` ブランチを選択
2. mainブランチにpushすると自動デプロイされます
3. URL: `https://{username}.github.io/{repo-name}/`

**Netlify:**
- [Netlify Drop](https://app.netlify.com/drop) に `wiki/` フォルダをドラッグ&ドロップ
- または `netlify deploy --dir=wiki` コマンドを使用

**Vercel:**
\`\`\`bash
npx vercel wiki/
\`\`\`

### 注意事項
- wikiファイルを更新するたびに `git push` するとGitHub Pagesに自動デプロイされます
- ローカルのmermaid図はDocsifyがCDN経由でレンダリングするため、インターネット接続が必要です
```
