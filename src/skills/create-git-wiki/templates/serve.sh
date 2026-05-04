#!/bin/bash
# wiki ローカルプレビューサーバー
# 使い方: bash wiki/serve.sh

PORT=${1:-3000}

echo "Wiki を起動しています..."
echo "ブラウザで http://localhost:${PORT} を開いてください"
echo "停止するには Ctrl+C を押してください"
echo ""

cd "$(dirname "$0")"

if command -v python3 &>/dev/null; then
  python3 -m http.server "$PORT"
elif command -v python &>/dev/null; then
  python -m SimpleHTTPServer "$PORT"
elif command -v npx &>/dev/null; then
  npx serve . -p "$PORT"
else
  echo "エラー: python3 / python / npx のいずれかが必要です"
  exit 1
fi
