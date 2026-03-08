# agent-setting

> Claude Code用のAIエージェント設定・カスタムスキル集

## 概要

このリポジトリは、[Claude Code](https://claude.ai/code)をより効率的に使うための設定ファイルとカスタムスキルを管理しています。

**解決する問題:**
- Claude Codeのカスタムスキルをチーム・個人間で共有・再利用できない
- 複雑な繰り返し作業をスキルとして定義し、自動化したい
- `claude/` ディレクトリの設定をバージョン管理・共有したい

**主な特徴:**
- カスタムスキルをMarkdown形式で定義・管理
- gitで設定をバージョン管理・共有
- `setup.sh` / `setup.ps1` でワンコマンドインストール
- セキュリティスキャン・レビュー蓄積の自動化フック

## 収録スキル

| スキル | 説明 |
|--------|------|
| [commit](modules/commit.md) | git変更を分析してConventional Commits形式でコミット自動化 |
| [create-git-wiki](modules/create-git-wiki.md) | gitリポジトリをAI分析してDocsify形式のwikiを自動生成 |
| [review-thinking](modules/review-thinking.md) | セッションの思考・判断を振り返り、再現可能なレビューを記録 |
| [safety-scan](modules/safety-scan.md) | シークレット・APIキー・.gitignore漏れをスキャン |

## クイックスタート

```bash
# リポジトリをクローン
git clone https://github.com/waless-seel/agent-setting.git
cd agent-setting

# セットアップ（スキル・スクリプトを ~/.claude にインストール）
bash setup.sh          # Linux / macOS / WSL
# または
pwsh setup.ps1         # Windows PowerShell
```

セットアップ後、Claude Codeでスキルを呼び出す:

```
# 例: gitコミット自動化
/commit

# 例: wikiを生成
/create-git-wiki

# 例: シークレットスキャン
/safety-scan

# 例: セッションレビュー記録
/review-thinking
```

## ドキュメント

- [アーキテクチャ概要](overview.md)
- [スキル詳細](modules/)
  - [commit](modules/commit.md)
  - [create-git-wiki](modules/create-git-wiki.md)
  - [review-thinking](modules/review-thinking.md)
  - [safety-scan](modules/safety-scan.md)
  - [スクリプト（hooks）](modules/scripts.md)
- [開発ガイド](contributing.md)
- [変更履歴](changelog.md)
