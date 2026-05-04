# Global Agent Instructions

## General

- Respond and write documentation in Japanese
- Prefer code/scripts over prompts; use CLI/shell scripts before MCP or prompt engineering
- Use mise for runtime management, task runners, and environment variables in projects

## Backlog Management

- During a session, append off-topic tasks/improvements to `BACKLOG.md`
- Format: `- [ ] **Title**\n  - summary, background, reference`
- Handle them in a separate session; do not interrupt current work

## Git

- Before `git commit`, show staged files as text for confirmation
- Never commit inside a git hook — leave modified files for the next sync (avoids infinite loops)

## Shell Scripting

- Always pass pattern variables to `grep` with `-e` flag (handles patterns starting with `-`)
- Use `python3` to merge JSON files like `settings.json` (more portable than `jq`)
- On Windows, check `Get-Alias <name>` before naming PowerShell functions (e.g. `gm` conflicts with `Get-Member`)
- Use `pwsh` (7+) for PowerShell scripts; avoid `powershell.exe` 5.1 (UTF-8 BOM issues)
- Prefer hardlinks over symlinks on Windows (no admin rights required)
- Always pass `-NoProfile` when calling `pwsh` from `setup.sh`/`setup.bat`
- Verify mise paths via `mise doctor` `dirs:` section rather than guessing

## Hooks

- Test a PostToolUse hook standalone: `echo '{"tool_name":"Write","tool_input":{"file_path":"x"}}' | bash script.sh`
- Hooks registered in the same session won't fire until the session is restarted

---

> For detailed rules, see `rules/` in this config directory:
> - `rules/git.md` — Git workflow rules
> - `rules/shell.md` — Shell/PowerShell best practices
> - `rules/hook.md` — Hook testing and lifecycle notes
