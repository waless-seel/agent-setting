@AGENTS.md

## スキル・設定管理
- スキルは `src/skills/` に置き、setup.sh でインストールする（`.claude/skills/` はプロジェクトローカルとして重複読み込みされるため）
- グローバル設定は `~/.claude/<name>.config` に置き、setup.sh でインタラクティブに生成する

- AskUserQuestion の選択肢は最大4件（API制限）。5件以上の場合はスクリプトでリストを生成し `fzf` に渡してユーザーに選ばせる
