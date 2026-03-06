# agent-setting

> Claude Code用のAIエージェント設定・カスタムスキル集

## 概要

このリポジトリは、[Claude Code](https://claude.ai/code)をより効率的に使うための設定ファイルとカスタムスキルを管理しています。

**解決する問題:**
- Claude Codeのカスタムスキルをチーム・個人間で共有・再利用できない
- 複雑な繰り返し作業をスキルとして定義し、自動化したい
- `.claude/` ディレクトリの設定をバージョン管理したい

**主な特徴:**
- カスタムスキルをMarkdown形式で定義・管理
- gitで設定をバージョン管理・共有
- スキルをリポジトリに追加するだけで即座に利用可能

## 収録スキル

| スキル | 説明 |
|--------|------|
| [create-git-wiki](modules/create-git-wiki.md) | gitリポジトリをAI分析してDocsify形式のwikiを自動生成 |

## クイックスタート

```bash
# リポジトリをクローン
git clone https://github.com/waless-seel/agent-setting.git
cd agent-setting

# Claude Codeで開く（スキルが自動認識される）
claude .
```

Claude Code内でスキルを呼び出す:

```
create-git-wikiスキルを実行してください
```

## ドキュメント

- [アーキテクチャ概要](overview.md)
- [スキル詳細](modules/create-git-wiki.md)
- [開発ガイド](contributing.md)
- [変更履歴](changelog.md)
