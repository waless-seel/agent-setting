# tackle-backlog

`BACKLOG.md` に蓄積された未対応タスクを、選択 → プラン設計 → 実装 → 完了マークまで一貫して進めるスキル。

## 概要

開発中に「今は手を止めたくないが後で対応したいタスク」を `BACKLOG.md` に蓄積し、別セッションで `/tackle-backlog` を呼ぶことで計画的に消化できます。

```mermaid
graph TD
    A[/tackle-backlog 呼び出し] --> B[BACKLOG.md 読み込み]
    B --> C{未完了タスクあり？}
    C -->|なし| D[終了]
    C -->|あり| E[タスク一覧表示]
    E --> F{引数あり？}
    F -->|あり| G[指定番号のタスクを選択]
    F -->|なし| H[AskUserQuestion で選択]
    G --> I[タスク分析 → EnterPlanMode]
    H --> I
    I --> J[プラン承認 → 実装]
    J --> K[BACKLOG.md 更新: -[ ] → -[x]]
    K --> L[/commit でコミット]
```

## ワークフロー

### Step 1: タスク一覧表示

`BACKLOG.md` を読み込み、`- [ ]` の未完了タスクを番号付きで列挙します。完了済み（`- [x]`）はスキップ。

### Step 2: タスク選択

- `/tackle-backlog 2` のように引数あり → 直接その番号を選択
- 引数なし → `AskUserQuestion` でユーザーに番号を尋ねる

### Step 3: プランモード

選択タスクの参照先ファイルを Read し、`EnterPlanMode` で実装プランを設計。

### Step 4: 実装

プラン承認後に実装を実行。

### Step 5: 完了処理

`BACKLOG.md` の `- [ ]` を `- [x]` に変更し、完了コミットハッシュと日付を追記。`/commit` を呼んでコミット。

## 使用例

```bash
# 未完了タスクをリスト表示して選ぶ
/tackle-backlog

# 直接タスク2を実行
/tackle-backlog 2
```

## BACKLOG.md フォーマット

```markdown
- [ ] **タスクタイトル**
  - 概要・背景
  - 参照: path/to/file.md

# 完了後
- [x] **タスクタイトル**
  - 概要・背景
  - 対応: commit `abc1234` (2026-03-09)
```

## 注意事項

- `BACKLOG.md` がリポジトリルートにない場合はユーザーに確認して終了
- 実装中に別タスク・改善案が出てきたら BACKLOG.md に追記し、現タスクを中断しない
