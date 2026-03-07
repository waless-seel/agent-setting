# agent-setting セットアップスクリプト
# このリポジトリのエージェント設定をユーザーの ~/.claude に適用する

#Requires -Version 5.1
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectClaudeDir = Join-Path $ScriptDir '.claude'
$UserClaudeDir = Join-Path $HOME '.claude'

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

# メイン処理
Write-Host '================================================' -ForegroundColor Cyan
Write-Host ' agent-setting セットアップ' -ForegroundColor Cyan
Write-Host '================================================' -ForegroundColor Cyan
Write-Host ''
Write-Info "インストール先: $UserClaudeDir"
Write-Host ''

New-Item -ItemType Directory -Force -Path $UserClaudeDir | Out-Null

Install-Skills
Install-Commands
Install-Agents
Install-Settings

Write-Host ''
Write-Info 'セットアップ完了！'
Write-Host ''
Write-Host "インストールされた内容を確認するには:"
Write-Host "  Get-ChildItem $UserClaudeDir\skills\"
