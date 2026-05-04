---
name: aggregate-reviews
description: >
  session-reviews に蓄積されたレビューを横断分析し、ルール・スキル・スクリプトへの
  改善提案レポートを生成するスキル。定期的に集積リポジトリで実行する。
  /aggregate-reviews で呼び出す。
---

# aggregate-reviews スキル

蓄積されたセッションレビューを横断分析し、自己学習・自己最適化を推進するレポートを生成する。

## Step 1: 設定解決

```bash
cat ~/.claude/review-thinking.config
```

取得すべきキー:
- `dest:` — レビュー蓄積先ディレクトリ（`~/session-reviews` 等）
- `agent-setting-path:` — agent-setting リポジトリの絶対パス

**`~` は絶対パスに展開して使用する。**

いずれかのキーが欠損している場合は、以下を案内して停止する:
> 「`~/.claude/review-thinking.config` に `dest:` または `agent-setting-path:` が設定されていません。
>  agent-setting リポジトリで `bash setup.sh` を再実行してください。」

`agent-setting-path` の妥当性確認:
```bash
ls {agent-setting-path}/claude/skills/
```
失敗する場合は「パスが正しくない可能性があります。`agent-setting-path:` を確認してください」と案内して停止。

## Step 2: スクリプト実行

```bash
bash ~/.claude/scripts/aggregate-reviews.sh --dest {dest}
```

出力を保持して Step 3 へ渡す。

- 終了コード 1 の場合（dest 未存在またはレビュー0件）→ エラーメッセージを表示して停止。

## Step 3: LLM 分析

スクリプト出力を元に以下を分析する（スクリプトが代替できない判断のみ）:

### A. タグ・アウトカム傾向
`===META-SUMMARY===` の REVIEW 行から:
- タグの出現頻度集計（上位5つ）
- outcome の内訳（success / partial / failed）
- プロジェクト別件数
- 「〇〇フェーズ」など文脈的な解釈

### B. ルール成熟度（CLAUDE.md 追記草案）

まず `{dest}/rejected-rules.md` を確認する（ファイルが存在する場合）。
存在する場合はその内容を読み込み、以下のルール提案から**意味的に一致するものを除外**する（完全一致不要、同じ意図・内容であれば除外）。

`===RULES-START:*===` ブロックを横断して:
- 複数セッションで同じパターンが登場するルール → **CLAUDE.md 追記草案**を生成
- 確信度「高」のルール → 即時昇格候補
- 確信度「中」以下 → 「要観察」として記録

草案フォーマット:
```
# 追記草案（{agent-setting-path}/CLAUDE.md）
- {ルール内容}（根拠: {slug1}, {slug2}）
```

### C. 未反映改善提案
`===PROPOSALS-RT-START:*===` および `===PROPOSALS-OTHER-START:*===` ブロックから:
- `反映状況` が `未反映` のもの → 対象ファイル別に集約
- 重複・類似提案は統合して1件として扱う

### D. 繰り返し判断パターン
`===DECISIONS-START:*===` ブロックから:
- 情報源が「推測」かつ同種のアクション → スクリプト化・事前チェック化候補
- 繰り返し発生しているエラーパターン → ルール化候補

### E. スキル・スクリプト改善提案
C の未反映提案 + D のパターンを統合して:
- 既存スキル・スクリプトへの改修提案
- 新規スキル・スクリプトの追加提案（繰り返しパターンから）

### F. トークン最適化提案
`{agent-setting-path}/claude/skills/` 配下の全 SKILL.md を確認:
```bash
wc -l {agent-setting-path}/claude/skills/*/SKILL.md
```
- 行数が多い SKILL.md → スクリプト化できる決定的ロジックの特定
- SKILL.md 内に `if`/条件分岐/ループ相当の記述 → スクリプト移行候補として提示

## Step 4: レポート生成

出力先: `{dest}/aggregate-{YYYY-MM-DD}.md`

```markdown
# aggregate-reviews レポート: {date}

## サマリー
- 分析対象: {N} 件（{dest}）
- 期間: {最古date} 〜 {最新date}
- プロジェクト: {プロジェクト一覧}

## A. タグ・アウトカム傾向
（頻度集計・解釈）

## B. CLAUDE.md 追記草案（ルール昇格候補）
（草案。Step 5 で承認時に実際に追記）

## C. 未反映改善提案
（対象ファイル別に集約）

## D. 繰り返し判断パターン
（スクリプト化・ルール化候補）

## E. スキル・スクリプト改善提案（既存改修 + 新規追加）
（具体的な改修内容）

## F. トークン最適化提案（スクリプト化候補 / SKILL.md 肥大化チェック）
（SKILL.md 行数一覧 + スクリプト移行候補）

## G. アクションリスト
- [ ] [HIGH] CLAUDE.md へ {ルール} を追記
- [ ] [HIGH] {未反映提案} を {対象ファイル} に反映
- [ ] [MED]  {スキル} の {ロジック} をスクリプト化
- [ ] [LOW]  新規スキル {名前} を検討
```

## Step 5: アクション確認（影響小→大の順）

### 5-1: CLAUDE.md への追記（ルール恒久化）

B で生成した草案をユーザーに提示:
> 「以下のルールを `{agent-setting-path}/CLAUDE.md` に追記しますか？
>   {草案内容}」

承認時: `{agent-setting-path}/CLAUDE.md` を Edit ツールで追記。

**却下時:**
`{dest}/rejected-rules.md` に以下を追記する:
```
- **ルール**: {ルール内容}
  - 却下日: {YYYY-MM-DD}
  - 理由: {ユーザーの却下理由（口頭で述べた場合はそのまま記録。ない場合は「理由未記載」）}
  - 根拠セッション: {slug1}, {slug2}
```
ファイルが存在しない場合はヘッダ付きで新規作成する:
```markdown
# 却下済みルール

aggregate-reviews が提案しても CLAUDE.md に追記しないと判断したルール。
次回以降の集計でこれらと意味的に同じ提案は除外する。

---
```

### 5-2: スクリプト化の実施

F で特定したスクリプト移行候補をユーザーに提示:
> 「`{SKILL.md パス}` の以下のロジックをスクリプト化しますか？
>   {対象ロジック}」

承認時: `{agent-setting-path}/scripts/` にスクリプトを新規作成 し、SKILL.md の該当記述をスクリプト呼び出しに置き換え。

### 5-3: 既存スキル・スクリプトの改修

C・E の未反映提案をユーザーに1件ずつ提示:
> 「`{対象ファイル}` を以下の内容で改修しますか？
>   {改修内容}」

承認時:
- 対象ファイルを `{agent-setting-path}/claude/skills/{skill-name}/SKILL.md` に解決して Edit ツールで修正する
  - `{agent-setting-path}` は Step 1 で取得済みの値を使用する
- 編集後、インストール先に同期する:
  ```bash
  cp {agent-setting-path}/claude/skills/{skill}/SKILL.md ~/.claude/skills/{skill}/SKILL.md
  ```
- 提案元の `{dest}/{slug}/thinking.md` を Edit し、当該提案行の `反映状況` セルを `反映済み（{YYYY-MM-DD}）` に更新する

### 5-4: 新規スキル・スクリプトの追加

E の新規追加提案をユーザーに提示:
> 「`{スキル名}` スキルを新規追加しますか？
>   概要: {概要}」

承認時: 実装する（単純なものは即時、複雑なものは「別セッションで実装」を案内）。

### 5-5: 新リポジトリ提案

繰り返しパターンから新リポジトリが有効と判断した場合、情報提示のみ:
> 「`{リポジトリ名}` リポジトリの作成を検討してください。
>   理由: {理由}」

実際の作成はユーザー判断。提案のみで完了。
