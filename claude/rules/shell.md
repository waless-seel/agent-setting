# シェルスクリプト ルール

- `grep` にパターン変数を渡すときは必ず `-e` フラグを使う（パターンが `-` 始まりの場合に対処）
- `settings.json` 等の JSON をスクリプトからマージするときは `python3` を使う（`jq` より可搬性が高い）
- `pwsh` で関数名を付ける前に `Get-Alias <name>` で組み込みエイリアス衝突を確認する（`gm` が `Get-Member` と衝突した教訓）
- Windows PowerShell スクリプトは `pwsh`（7+）を前提とする（`powershell.exe` 5.1 は UTF-8 BOM 問題があり `✓` 等の文字でパースエラーが発生する）
- Windows でファイルリンクを作成するときは、シンボリックリンクより先にハードリンクを検討する（管理者権限不要）
- `setup.sh` / `setup.bat` から `pwsh` を呼ぶときは `-NoProfile` を必ず付ける（フレッシュ環境でプロファイルエラーが連鎖するのを防ぐ）
- `mise` の正規パスは `mise doctor` の `dirs:` セクションで確認する（`%APPDATA%\mise` と推測して誤るケースがある）
