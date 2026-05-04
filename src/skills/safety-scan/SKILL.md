---
name: safety-scan
description: >
  リポジトリまたはステージ済みファイルを対象に、シークレット・APIキー・.gitignore漏れを
  スクリプト＋LLM文脈分析でチェックするスキル。
  /safety-scan と呼ぶか、「コミットしていいか確認して」「シークレットが混入していないか確認」
  「危険なファイルないか確認」「安全チェックして」などと言われたときに使う。
  /safety-scan staged でステージ済みのみをチェック（コミット直前推奨）。
---

# safety-scan スキル

## Step 1: モード判定

ユーザーの指示から動作モードを決定する：
- 引数なし / `repo` / 「リポジトリ全体」→ `repo` モード
- `staged` / 「ステージ済み」/ 「コミット前」→ `staged` モード

## Step 2: 第1パス（スクリプト実行）

以下のコマンドを Bash ツールで実行し、出力を取得する：

```bash
# repo モードの場合
bash ~/.claude/scripts/safety-scan.sh repo

# staged モードの場合
bash ~/.claude/scripts/safety-scan.sh staged
```

- 終了コード 0 = 候補なし → Step 4 へ（OK レポート）
- 終了コード 1 = 候補あり → Step 3 へ

出力形式：
- `FOUND:file:line:content` — シークレット候補行
- `GITIGNORE_RISK:file` — 追跡すべきでないファイル

## Step 3: 第2パス（LLM 文脈判断）

`FOUND:` 行ごとに、該当ファイルの前後5行を Read ツールで取得し、以下の観点で判断する：

**誤検知（無視してよい）の判断基準：**
- プレースホルダー：`your_key_here`、`xxx`、`<YOUR_TOKEN>`、`test_`、`dummy`、`example` 等
- 環境変数からの取得：`os.environ.get(...)`, `process.env.XXX`, `$ENV_VAR` 等
- コメント・ドキュメント内の説明文
- テストコードのモック値（ファイルパスが `test/`, `spec/`, `__tests__/` 等）

**本物のシークレットと判断する基準：**
- ランダムな文字列が実際に値として代入されている
- Base64 エンコードされた長い文字列
- `sk-`, `ghp_`, `AKIA`, `ya29.` などのサービス固有プレフィックス
- PEM 形式のキーブロック（`-----BEGIN ... KEY-----`）

## Step 4: 結果レポート

以下の形式でレポートを出力する：

### 候補がない場合

```
✅ 問題は検出されませんでした。
スキャン対象: [repo|staged] モード
```

### 候補がある場合

**CRITICAL**（本物のシークレットと判断）:
```
🚨 CRITICAL: シークレットが検出されました

- ファイル: path/to/file.env（12行目）
  内容: API_KEY=sk-live-abcdef123456...
  対処: このファイルを .gitignore に追加し、git rm --cached で追跡を解除してください。
        シークレットは直ちにローテーション（無効化・再発行）してください。
```

**WARNING**（.gitignore リスク）:
```
⚠️ WARNING: 追跡すべきでないファイルが git 管理下にあります

- .env （機密情報を含む可能性があります）
  対処: .gitignore に追加し、git rm --cached .env で追跡解除を推奨します。
```

## Step 5: 修正支援（ユーザーが希望する場合のみ）

**必ずユーザーに確認してから実行すること。**

- `.gitignore` への追記:
  ```bash
  echo ".env" >> .gitignore
  ```
- ステージ解除:
  ```bash
  git restore --staged {file}
  ```
- 追跡解除（履歴から削除はしない）:
  ```bash
  git rm --cached {file}
  ```

> ⚠️ シークレットが既にコミット済みの場合は、`git filter-repo` や GitHub の Secret Scanning で
> 履歴から除去する必要がある旨を伝え、対処法を案内すること。
