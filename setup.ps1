# agent-setting セットアップスクリプト
# このリポジトリのエージェント設定をユーザーの ~/.claude に適用する

#Requires -Version 5.1
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectClaudeDir = Join-Path $ScriptDir 'src'
$UserClaudeDir = Join-Path $HOME '.claude'
$CodexDir = Join-Path $HOME '.codex'

function Write-Info  { param($msg) Write-Host "[INFO] $msg" -ForegroundColor Green }
function Write-Warn  { param($msg) Write-Host "[WARN] $msg" -ForegroundColor Yellow }

function Install-Skills {
    $src = Join-Path $ProjectClaudeDir 'skills'
    $dst = Join-Path $UserClaudeDir 'skills'

    if (-not (Test-Path $src)) { return }

    New-Item -ItemType Directory -Force -Path $dst | Out-Null

    foreach ($skillDir in Get-ChildItem -Path $src -Directory) {
        $target = Join-Path $dst $skillDir.Name
        if (Test-Path $target) {
            Write-Warn "スキル '$($skillDir.Name)' は既に存在します。上書きします..."
            Remove-Item -Recurse -Force $target
        } else {
            Write-Info "スキル '$($skillDir.Name)' をインストールします..."
        }
        Copy-Item -Recurse -Path $skillDir.FullName -Destination $dst
        Write-Info "  -> $target"
    }
}

function Install-Commands {
    $src = Join-Path $ProjectClaudeDir 'commands'
    $dst = Join-Path $UserClaudeDir 'commands'

    if (-not (Test-Path $src)) { return }

    New-Item -ItemType Directory -Force -Path $dst | Out-Null

    foreach ($file in Get-ChildItem -Path $src -Filter '*.md') {
        Write-Info "コマンド '$($file.Name)' をインストールします..."
        Copy-Item -Force -Path $file.FullName -Destination $dst
        Write-Info "  -> $(Join-Path $dst $file.Name)"
    }
}

function Install-Agents {
    $src = Join-Path $ProjectClaudeDir 'agents'
    $dst = Join-Path $UserClaudeDir 'agents'

    if (-not (Test-Path $src)) { return }

    New-Item -ItemType Directory -Force -Path $dst | Out-Null

    foreach ($file in Get-ChildItem -Path $src -Filter '*.md') {
        Write-Info "エージェント '$($file.Name)' をインストールします..."
        Copy-Item -Force -Path $file.FullName -Destination $dst
        Write-Info "  -> $(Join-Path $dst $file.Name)"
    }
}

function Install-Settings {
    $src = Join-Path $ProjectClaudeDir 'settings.json'
    $dst = Join-Path $UserClaudeDir 'settings.json'

    if (-not (Test-Path $src)) { return }

    if (Test-Path $dst) {
        Write-Warn "settings.json は既に存在するためスキップします: $dst"
        Write-Warn "手動でマージしてください: $src"
    } else {
        Write-Info "settings.json をコピーします..."
        Copy-Item -Path $src -Destination $dst
        Write-Info "  -> $dst"
    }
}

function Install-ReviewConfig {
    $configPath = Join-Path $UserClaudeDir 'review-thinking.config'

    if (Test-Path $configPath) {
        Write-Warn "review-thinking.config は既に存在します: $configPath"

        # agent-setting-path が未設定の場合は追記する
        $content = Get-Content -Path $configPath
        if (-not ($content -match '^agent-setting-path:')) {
            Write-Host ""
            Write-Host "aggregate-reviews スキルのために agent-setting リポジトリのパスを設定します。"
            Write-Host "（空のままEnterでスキップ）"
            $agentPathInput = Read-Host "agent-setting リポジトリのパス [デフォルト: $ScriptDir]"

            if ([string]::IsNullOrWhiteSpace($agentPathInput)) {
                $agentPathInput = $ScriptDir
            }

            "`nagent-setting-path: $agentPathInput" | Add-Content -Path $configPath
            Write-Info "agent-setting-path を追記しました: $agentPathInput"
        } else {
            Write-Warn "agent-setting-path は既に設定済みです。上書きする場合は手動で編集してください"
        }

        return
    }

    Write-Host ""
    Write-Host "review-thinking スキルのレビュー蓄積先を設定します。"
    Write-Host "複数プロジェクトのレビューをまとめて保存するフォルダを指定してください。"
    Write-Host "（空のままEnterでデフォルト ~/session-reviews を使用）"
    $destInput = Read-Host "reviews 蓄積先フォルダ [デフォルト: ~/session-reviews]"

    if ([string]::IsNullOrWhiteSpace($destInput)) {
        $destInput = "~/session-reviews"
    }

    $destExpanded = $destInput -replace '^~', $HOME
    New-Item -ItemType Directory -Force -Path $destExpanded | Out-Null

    Write-Host ""
    Write-Host "aggregate-reviews スキルのために agent-setting リポジトリのパスを設定します。"
    Write-Host "（空のままEnterでスキップ）"
    $agentPathInput = Read-Host "agent-setting リポジトリのパス [デフォルト: $ScriptDir]"

    if ([string]::IsNullOrWhiteSpace($agentPathInput)) {
        $agentPathInput = $ScriptDir
    }

    @"
# review-thinking グローバル設定
# このファイルは ~/.claude/review-thinking.config に配置され、全プロジェクト共通で参照される
# プロジェクト内の .claude/review-thinking.config があればそちらが優先される
dest: $destInput
agent-setting-path: $agentPathInput
"@ | Set-Content -Path $configPath -Encoding UTF8

    Write-Info "review-thinking.config を作成しました: $configPath"
    Write-Info "蓄積先: $destInput"
    Write-Info "agent-setting パス: $agentPathInput"
}

function Install-GlobalClaudeMd {
    $src = Join-Path $ProjectClaudeDir 'CLAUDE.md'
    $dst = Join-Path $UserClaudeDir 'CLAUDE.md'

    if (-not (Test-Path $src)) {
        Write-Warn "CLAUDE.md が見つかりません: $src"
        return
    }

    Copy-Item -Force -Path $src -Destination $dst
    Write-Info "CLAUDE.md をインストールしました: $dst"

    $agentsSrc = Join-Path $ProjectClaudeDir 'AGENTS.md'
    if (Test-Path $agentsSrc) {
        Copy-Item -Force -Path $agentsSrc -Destination (Join-Path $UserClaudeDir 'AGENTS.md')
        Write-Info "AGENTS.md をインストールしました: $(Join-Path $UserClaudeDir 'AGENTS.md')"
    }
}

function Install-Knowledge {
    $src = Join-Path $ProjectClaudeDir 'knowledge'

    if (-not (Test-Path $src)) { return }

    foreach ($dst in @((Join-Path $UserClaudeDir 'knowledge'), (Join-Path $CodexDir 'knowledge'))) {
        New-Item -ItemType Directory -Force -Path $dst | Out-Null
        foreach ($file in Get-ChildItem -Path $src -Filter '*.md') {
            Copy-Item -Force -Path $file.FullName -Destination $dst
            Write-Info "ナレッジ '$($file.Name)' をインストールしました -> $(Join-Path $dst $file.Name)"
        }
    }
}


function Install-CodexSkills {
    $src = Join-Path $ProjectClaudeDir 'skills'
    $dst = Join-Path $CodexDir 'skills'

    if (-not (Test-Path $src)) { return }

    New-Item -ItemType Directory -Force -Path $dst | Out-Null

    foreach ($skillDir in Get-ChildItem -Path $src -Directory) {
        $name = $skillDir.Name
        $target = Join-Path $dst $name

        if (Test-Path $target) {
            Write-Warn "Codex スキル '$name' は既に存在します。上書きします..."
            Remove-Item -Recurse -Force $target
        } else {
            Write-Info "Codex スキル '$name' をインストールします..."
        }
        Copy-Item -Recurse -Path $skillDir.FullName -Destination $dst

        # SKILL.md 内の ~/.claude/skills/ を ~/.codex/skills/ に書き換え
        $skillMd = Join-Path $target 'SKILL.md'
        if (Test-Path $skillMd) {
            (Get-Content $skillMd -Raw) `
                -replace '~/\.claude/skills/', '~/.codex/skills/' |
                Set-Content $skillMd -NoNewline
        }

        Write-Info "  -> $target"
    }
}

function Install-CodexConfig {
    New-Item -ItemType Directory -Force -Path $CodexDir | Out-Null

    $agentsSrc = Join-Path $ProjectClaudeDir 'AGENTS.md'
    if (Test-Path $agentsSrc) {
        Copy-Item -Force -Path $agentsSrc -Destination (Join-Path $CodexDir 'AGENTS.md')
        Write-Info "Codex: AGENTS.md をインストールしました: $(Join-Path $CodexDir 'AGENTS.md')"
    }

    $configSrc = Join-Path $ProjectClaudeDir 'codex\config.toml'
    if (-not (Test-Path $configSrc)) { return }

    $configDst = Join-Path $CodexDir 'config.toml'
    Copy-Item -Force -Path $configSrc -Destination $configDst
    Write-Info "Codex: config.toml をインストールしました: $configDst"
}

function Install-CodexHooks {
    $src = Join-Path $ProjectClaudeDir 'codex\hooks.json'
    if (-not (Test-Path $src)) { return }

    New-Item -ItemType Directory -Force -Path $CodexDir | Out-Null
    $dst = Join-Path $CodexDir 'hooks.json'

    $pyScript = @'
import sys, json, os

src_path = sys.argv[1]
dst_path = sys.argv[2]

with open(src_path, 'r', encoding='utf-8') as f:
    src = json.load(f)

if os.path.exists(dst_path):
    with open(dst_path, 'r', encoding='utf-8') as f:
        dst = json.load(f)
else:
    dst = {}

for event, handlers in src.get("hooks", {}).items():
    dst.setdefault("hooks", {}).setdefault(event, [])
    existing_cmds = {h.get("command") for h in dst["hooks"][event]}
    for h in handlers:
        if h.get("command") not in existing_cmds:
            dst["hooks"][event].append(h)

with open(dst_path, 'w', encoding='utf-8') as f:
    json.dump(dst, f, indent=2, ensure_ascii=False)
    f.write('\n')

print(f"[INFO] Codex hooks をインストールしました: {dst_path}", file=sys.stderr)
'@

    $pyScript | python3 - $src $dst
    Write-Info "Codex: フック登録完了"
}

function Install-CopyReviewHook {
    $scriptsDst = Join-Path $UserClaudeDir 'scripts'
    $scriptSrc  = Join-Path $ProjectClaudeDir 'skills\review-thinking\scripts\copy-review.sh'
    $settingsFile = Join-Path $UserClaudeDir 'settings.json'

    # スクリプトをコピー
    New-Item -ItemType Directory -Force -Path $scriptsDst | Out-Null
    Copy-Item -Force -Path $scriptSrc -Destination (Join-Path $scriptsDst 'copy-review.sh')
    Write-Info "copy-review.sh をインストールしました: $scriptsDst\copy-review.sh"

    # settings.json にフックを追加（python3 で安全にマージ）
    $pyScript = @'
import sys, json, os

settings_path = sys.argv[1]
hook_command = "bash ~/.claude/scripts/copy-review.sh"

if os.path.exists(settings_path):
    with open(settings_path, 'r', encoding='utf-8') as f:
        settings = json.load(f)
else:
    settings = {}

hooks = settings.setdefault("hooks", {})
post_tool_use = hooks.setdefault("PostToolUse", [])

for entry in post_tool_use:
    for h in entry.get("hooks", []):
        if h.get("command") == hook_command:
            print("[WARN] copy-review フックは既に登録済みです", file=sys.stderr)
            sys.exit(0)

post_tool_use.append({
    "matcher": "Write",
    "hooks": [{"type": "command", "command": hook_command}]
})

with open(settings_path, 'w', encoding='utf-8') as f:
    json.dump(settings, f, indent=2, ensure_ascii=False)
    f.write('\n')

print(f"[INFO] copy-review フックを登録しました: {settings_path}", file=sys.stderr)
'@

    $pyScript | python3 - $settingsFile
    Write-Info "フック登録完了"
}

# メイン処理
Write-Host '================================================' -ForegroundColor Cyan
Write-Host ' agent-setting セットアップ' -ForegroundColor Cyan
Write-Host '================================================' -ForegroundColor Cyan
Write-Host ''
Write-Info "インストール先: $UserClaudeDir"
Write-Host ''

New-Item -ItemType Directory -Force -Path $UserClaudeDir | Out-Null

Install-Skills
Install-GlobalClaudeMd
Install-Knowledge
Install-Commands
Install-Agents
Install-Settings
Install-ReviewConfig
Install-CopyReviewHook
Install-CodexSkills
Install-CodexConfig
Install-CodexHooks

Write-Host ''
Write-Info 'セットアップ完了！'
Write-Host ''
Write-Host "インストールされた内容を確認するには:"
Write-Host "  Get-ChildItem $UserClaudeDir\skills\"
Write-Host "  Get-ChildItem $CodexDir\"
