# 開発ガイド

## 環境セットアップ

### 必要なもの

- [Claude Code](https://claude.ai/code) — スキル実行環境
- Git
- Python 3（セットアップスクリプトのJSONマージ・safety-scanに使用）
- Python 3 または Node.js（ローカルwikiプレビュー用）

### セットアップ手順

```bash
# リポジトリをクローン
git clone https://github.com/waless-seel/agent-setting.git
cd agent-setting

# セットアップ（スキル・スクリプト・フックを ~/.claude にインストール）
bash setup.sh          # Linux / macOS / WSL
# または
pwsh setup.ps1         # Windows PowerShell
```

セットアップ後、Claude Codeを開くとスキルが自動認識されます:

```bash
claude .
```

### setup.sh の処理内容

| 処理 | 説明 |
|------|------|
| `install_skills` | `claude/skills/` → `~/.claude/skills/` にコピー |
| `install_settings` | `claude/settings.json` → `~/.claude/settings.json` にコピー（既存があればスキップ） |
| `install_review_config` | `~/.claude/review-thinking.config` を対話式に生成 |
| `install_safety_scan` | `scripts/safety-scan.sh` → `~/.claude/scripts/` にインストール |
| `install_copy_review_hook` | `scripts/copy-review.sh` → `~/.claude/scripts/` + settings.json にフック登録 |

## スキルの追加方法

新しいスキルを追加するには、以下の手順に従います:

### 1. ディレクトリ作成

```bash
mkdir -p claude/skills/{your-skill-name}
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
| ワークフロー | TodoWriteで管理し、各ステップが明確 |
| 出力 | 何が生成されるかを明示する |
| まとめメッセージ | 完了後にユーザーへの報告フォーマットを定義 |

### 4. コミット

`commit` スキルを使うと便利です:

```
/commit
```

または手動で:

```bash
git add claude/skills/{your-skill-name}/
git commit -m "feat(skill): add {your-skill-name} skill"
git push
```

## 既存スキルの改善

スキルを改善する場合は、SKILL.mdを直接編集してコミットします:

```bash
# スキルを編集
$EDITOR claude/skills/review-thinking/SKILL.md

# commitスキルで自動コミット
# → Claude Code内で /commit を実行
```

## gitignoreのルール

`.gitignore` では以下を除外しています:

```gitignore
# 認証・セッション情報（マシン固有・秘密情報）
.claude/auth.json
.claude/.credentials
.claude/settings.json     # MCPパスがマシン依存
.claude/.session
.claude/settings.local.json

# 自動生成キャッシュ
.claude/cache/
.claude/tmp/

# セッションレビュー（ローカル蓄積のみ）
reviews/
```

**コミットすべきもの:** `claude/skills/`、`scripts/`、`setup.sh`、`setup.ps1`

**コミットしてはいけないもの:** `.claude/auth.json`、`.claude/settings.json`（MCPパスがマシン依存）

## ローカルwikiのプレビュー

```bash
bash wiki/serve.sh
# → http://localhost:3000
```

wikiを更新した場合は、Claude Code内で再実行:

```
/create-git-wiki
```

## プルリクエスト

1. フォークまたはブランチを作成
2. スキルを追加・改善
3. PRを作成（タイトル: `feat(skill): add {skill-name}` または `improve(skill): update {skill-name}`）
