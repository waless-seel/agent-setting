# agent-setting

AI コーディングエージェントのカスタムスキル・フック・スクリプトをバージョン管理し、任意のマシンにワンコマンドでインストールできる設定管理リポジトリです。

`src/` を共通ソースとして **Claude Code**（`~/.claude/`）と **Codex CLI**（`~/.codex/`）の両方に対応しています。

[English README](README.md)

## スキル一覧

| スキル | トリガー例 | 概要 |
|--------|-----------|------|
| `commit` | `/commit`, 「コミットして」 | git変更を分析してConventional Commits形式でコミット自動化 |
| `create-git-wiki` | 「wikiを生成して」 | gitリポジトリをAI分析してDocsify形式のwikiを自動生成 |
| `review-thinking` | `/review-thinking` | セッションの思考・判断を振り返り、再現可能なレビューを記録 |
| `safety-scan` | `/safety-scan`, 「シークレット確認」 | シークレット・APIキー・.gitignore漏れをスキャン |

## クイックスタート

```bash
git clone https://github.com/waless-seel/agent-setting.git
cd agent-setting

# Linux / macOS / WSL
bash setup.sh

# Windows PowerShell
pwsh setup.ps1
```

セットアップ後、Claude Code でスキルを呼び出す:

```
/commit
/create-git-wiki
/safety-scan
/review-thinking
```

## ドキュメント

[Wiki](https://waless-seel.github.io/agent-setting/) に詳細なアーキテクチャ・スキル説明・開発ガイドがあります。
