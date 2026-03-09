---
name: commit
description: >
  現在のgitの変更を分析し、適切なコミットメッセージを自動生成してコミットするスキル。
  /commit と呼び出すか、「コミットして」「git commit」「変更をコミット」「コミットメッセージを作って」
  などと言われたときに使うこと。ステージング済み・未ステージの変更も含めて一括処理する。
---

# commit

現在の変更を把握し、Conventional Commits 形式で適切なコミットメッセージを生成してコミットする。

## ワークフロー

以下を **並列で** 実行して状況を把握する:

```bash
git status
git diff HEAD
git log --oneline -10
```

### 1. 変更の把握

- `git status` でステージ済み・未ステージ・未追跡ファイルを確認
- `git diff HEAD` で実際の差分を確認
- `git log --oneline -10` でこのリポジトリのコミットスタイルを把握

### 2. コミットメッセージの生成

変更の種類に応じて Conventional Commits 形式でメッセージを作る:

| タイプ | 使う場面 |
|--------|---------|
| `feat` | 新機能の追加 |
| `fix` | バグ修正 |
| `docs` | ドキュメントのみの変更 |
| `style` | コードの動作に影響しない整形・フォーマット |
| `refactor` | バグ修正でも機能追加でもないコード変更 |
| `test` | テストの追加・修正 |
| `chore` | ビルドプロセス・ツール・設定の変更 |
| `ci` | CI/CD設定の変更 |

**メッセージ構成:**
```
{type}({scope}): {概要}

{詳細（必要な場合のみ）}
```

- 概要は英語または日本語（リポジトリの既存スタイルに合わせる）
- 概要は50文字以内が望ましい
- 変更が複数のタイプにまたがる場合は最も主要なものを選ぶ

**メッセージ例:**
```
feat(skill): add commit skill for automated git commits
fix(auth): handle null user session on login
docs: update README with setup instructions
chore: add .gitignore for node_modules
```

### 3. ステージングとコミット

```bash
# 関連ファイルを追加（ワイルドカードより個別指定を優先）
git add {ファイル1} {ファイル2} ...
```

`git add` 実行後、**コミット前に以下をテキストで提示する**:

```
コミット対象ファイル:
  - {ファイル1}
  - {ファイル2}
  ...
コミットメッセージ: {type}({scope}): {概要}
```

ユーザーが明示的に中止しない限り、そのままコミットへ進む。

```bash
# コミット（HEREDOCで改行を保持）
git commit -m "$(cat <<'EOF'
{type}({scope}): {概要}

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>
EOF
)"

# 成功確認
git status
```

### 4. 完了報告

コミット後に以下を日本語で報告する:

```
コミット完了:
  ハッシュ: {git rev-parse --short HEAD の出力}
  メッセージ: {コミットメッセージ}
  変更ファイル数: {件数}
```

## 注意事項

- `.env` / シークレット / 認証情報を含むファイルは絶対にコミットしない。見つけたらユーザーに警告する
- `git add -A` や `git add .` は使わず、変更ファイルを個別に指定する
- pre-commit フックが失敗したら原因を修正してから新規コミットを作る（--amend や --no-verify は使わない）
- 変更がない場合は「コミットする変更がありません」と報告して終了する
- プッシュは明示的に指示された場合のみ行う
