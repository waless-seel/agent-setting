# 開発ガイド

## 環境セットアップ

### 必要なもの

- [Claude Code](https://claude.ai/code) — スキル実行環境
- Git
- Python 3 または Node.js（ローカルwikiプレビュー用）

### セットアップ手順

```bash
# リポジトリをクローン
git clone https://github.com/waless-seel/agent-setting.git
cd agent-setting

# Claude Codeで開く
claude .
```

Claude Codeを開くと、`.claude/skills/` 内のスキルが自動的に認識されます。

## スキルの追加方法

新しいスキルを追加するには、以下の手順に従います:

### 1. ディレクトリ作成

```bash
mkdir -p .claude/skills/{your-skill-name}
```

### 2. SKILL.mdを作成

```markdown
---
name: your-skill-name
description: スキルの説明。Claude Codeがいつこのスキルを使うかを判断するための文章。
             トリガー条件・使用例を具体的に書く。
---

# your-skill-name

スキルの概要説明。

## ワークフロー

Todoリストを作成して、以下の各タスクを順番に実行すること。

### 1. 最初のステップ

...

### 2. 次のステップ

...
```

### 3. スキルの品質基準

| 項目 | 基準 |
|------|------|
| `description` | 具体的なトリガー条件・使用例を含む（50〜200文字推奨） |
| ワークフロー | Todoリストで管理し、各ステップが明確 |
| 出力 | 何が生成されるかを明示する |
| まとめメッセージ | 完了後にユーザーへの報告フォーマットを定義 |

### 4. コミット

```bash
git add .claude/skills/{your-skill-name}/
git commit -m "feat: add {your-skill-name} skill"
git push
```

## 既存スキルの改善

スキルを改善する場合は、SKILL.mdを直接編集してコミットします。

```bash
# スキルを編集
$EDITOR .claude/skills/create-git-wiki/SKILL.md

# 変更をコミット
git add .claude/skills/create-git-wiki/SKILL.md
git commit -m "improve: update create-git-wiki workflow"
```

## gitignoreのルール

`.gitignore` では以下を除外しています:

```gitignore
# 認証・セッション情報（マシン固有・秘密情報）
.claude/auth.json
.claude/.credentials
.claude/settings.json
.claude/.session

# 自動生成キャッシュ
.claude/cache/
.claude/tmp/
```

**コミットすべきもの:** `.claude/skills/`、`.claude/CLAUDE.md`

**コミットしてはいけないもの:** `auth.json`、`settings.json`（MCPパスがマシン依存）

## プルリクエスト

1. フォークまたはブランチを作成
2. スキルを追加・改善
3. PRを作成（タイトル: `feat: add {skill-name}` または `improve: update {skill-name}`）

## ローカルwikiのプレビュー

```bash
bash wiki/serve.sh
# → http://localhost:3000
```

wikiを更新した場合:

```bash
# wikiを再生成
claude . # Claude Codeでcreate-git-wikiスキルを再実行

# または手動でMarkdownを編集してプレビュー
bash wiki/serve.sh
```
