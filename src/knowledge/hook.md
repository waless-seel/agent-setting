# Claude Code フック ルール

- PostToolUse フックの単体テスト: `echo '{"tool_name":"Write","tool_input":{"file_path":"x"}}' | bash script.sh`
- フック登録後は同一セッション内では未発火 → セッション再起動が必要
