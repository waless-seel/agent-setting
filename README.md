# agent-setting

A configuration management repository for Claude Code — version-controls custom skills, hooks, and scripts, and installs them on any machine with a single command.

[日本語版 README](README.ja.md)

## Skills

| Skill | Trigger examples | Description |
|-------|-----------------|-------------|
| `commit` | `/commit`, "commit this" | Analyzes git changes and automates commits in Conventional Commits format |
| `create-git-wiki` | "generate a wiki" | AI-analyzes a git repository and auto-generates a Docsify wiki |
| `review-thinking` | `/review-thinking` | Reflects on session reasoning and records reproducible reviews |
| `safety-scan` | `/safety-scan`, "check for secrets" | Scans for secrets, API keys, and .gitignore leaks |

## Quick Start

```bash
git clone https://github.com/waless-seel/agent-setting.git
cd agent-setting

# Linux / macOS / WSL
bash setup.sh

# Windows PowerShell
pwsh setup.ps1
```

After setup, invoke skills in Claude Code:

```
/commit
/create-git-wiki
/safety-scan
/review-thinking
```

## Documentation

Full architecture, skill reference, and development guide are available in the [Wiki](https://waless-seel.github.io/agent-setting/).
