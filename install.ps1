# ==========================================
# 🎬 NITRATE — Windows 1-Line PowerShell Installer
# ==========================================

$ErrorActionPreference = "Stop"

Clear-Host

Write-Host @"
  ╔══════════════════════════════════════════════════════════════╗
  ║                                                              ║
  ║     🎬  N I T R A T E  —  C I N E M A  S T R E A M E R       ║
  ║        Direct-to-GPU 4K HDR & Lossless Master Audio          ║
  ║                                                              ║
  ╚══════════════════════════════════════════════════════════════╝
"@ -ForegroundColor Cyan

Write-Host "`nStarting Windows zero-friction setup...`n" -ForegroundColor White

# 1. Check / Install MPV on Windows
Write-Host "▶ Checking video player (mpv)..." -ForegroundColor Cyan
if (Get-Command mpv -ErrorAction SilentlyContinue) {
    Write-Host "  ✓ mpv is already installed!" -ForegroundColor Green
} else {
    Write-Host "  mpv not found. Installing via winget..." -ForegroundColor Yellow
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        winget install --id shinchiro.mpv --accept-package-agreements --accept-source-agreements
    } elseif (Get-Command scoop -ErrorAction SilentlyContinue) {
        scoop install mpv
    } elseif (Get-Command choco -ErrorAction SilentlyContinue) {
        choco install mpv -y
    } else {
        Write-Host "  Please install mpv from https://mpv.io or install winget/scoop." -ForegroundColor Red
    }
}

# 2. Automated MPV Configuration on Windows (%APPDATA%\mpv\mpv.conf)
Write-Host "`n▶ Configuring optimal MPV video & audio engine..." -ForegroundColor Cyan
$MpvDir = Join-Path $env:APPDATA "mpv"
$MpvConf = Join-Path $MpvDir "mpv.conf"
New-Item -ItemType Directory -Force -Path $MpvDir | Out-Null

if (-not (Test-Path $MpvConf)) {
    @"
# Studio-grade GPU video rendering (libplacebo / Direct3D11)
vo=gpu-next
hwdec=auto-safe
gpu-api=d3d11

# High-speed Debrid network buffering
cache=yes
demuxer-max-bytes=512MiB
network-timeout=60

# Audio & Subtitle Defaults (English first)
alang=en,eng
slang=en,eng
subs-with-matching-audio=no

# UI
force-window=immediate
script-opts=osc-layout=bottombar
"@ | Out-File -FilePath $MpvConf -Encoding utf8
    Write-Host "  ✓ Created optimal mpv.conf in $MpvConf" -ForegroundColor Green
} else {
    Write-Host "  ✓ Existing mpv.conf preserved" -ForegroundColor DarkGray
}

# 3. Install Nitrate Binary & Batch Wrapper
Write-Host "`n▶ Installing nitrate..." -ForegroundColor Cyan
$InstallDir = Join-Path $env:USERPROFILE ".local\bin"
New-Item -ItemType Directory -Force -Path $InstallDir | Out-Null

$PyScript = Join-Path $InstallDir "nitrate.py"
$BatScript = Join-Path $InstallDir "nitrate.cmd"

# Download Python script
$RepoUrl = "https://raw.githubusercontent.com/Manteh/nitrate/main/bin/nitrate"
Invoke-WebRequest -Uri $RepoUrl -OutFile $PyScript

# Create CMD wrapper for instant execution
@"
@echo off
python "%~dp0nitrate.py" %*
"@ | Out-File -FilePath $BatScript -Encoding ascii

Write-Host "  ✓ Installed executable to $BatScript" -ForegroundColor Green

# Add to User PATH if missing
$UserPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($UserPath -notlike "*$InstallDir*") {
    [Environment]::SetEnvironmentVariable("Path", "$UserPath;$InstallDir", "User")
    $env:Path = "$env:Path;$InstallDir"
    Write-Host "  ✓ Added $InstallDir to your Windows User PATH" -ForegroundColor Green
}

# 4. Interactive Debrid Setup
Write-Host "`n▶ Debrid Account Setup (Instant 4K Streaming without VPN)" -ForegroundColor Cyan
$ConfigDir = Join-Path $env:APPDATA "nitrate"
$ConfigFile = Join-Path $ConfigDir "config.json"
New-Item -ItemType Directory -Force -Path $ConfigDir | Out-Null

Write-Host "  A Debrid service (~`$3/mo) gives you 100% ISP safety (no VPN needed)" -ForegroundColor DarkGray
Write-Host "  and instant 1.5s playback on 80GB 4K REMUXes with zero buffering.`n" -ForegroundColor DarkGray

Write-Host "  Select your Debrid provider:" -ForegroundColor White
Write-Host "    [1] TorBox (Recommended) ──► https://torbox.app/settings" -ForegroundColor Cyan
Write-Host "    [2] Real-Debrid           ──► https://real-debrid.com/apitoken" -ForegroundColor Cyan
Write-Host "    [3] Free P2P mode (No Debrid / Direct torrenting)" -ForegroundColor Cyan

$Provider = Read-Host "`n  Choose option [1-3] (Default: 1)"
if ([string]::IsNullOrWhiteSpace($Provider)) { $Provider = "1" }

if ($Provider -eq "1") {
    Write-Host "`n  ➔ Get your TorBox API key at: https://torbox.app/settings" -ForegroundColor Yellow
    $Key = Read-Host "  Paste your TorBox API Key"
    if ($Key) {
        @{ torbox_key = $Key.Trim() } | ConvertTo-Json | Out-File -FilePath $ConfigFile -Encoding utf8
        Write-Host "  ✓ TorBox key saved!" -ForegroundColor Green
    }
} elseif ($Provider -eq "2") {
    Write-Host "`n  ➔ Get your Real-Debrid API key at: https://real-debrid.com/apitoken" -ForegroundColor Yellow
    $Key = Read-Host "  Paste your Real-Debrid API Key"
    if ($Key) {
        @{ rd_api_key = $Key.Trim() } | ConvertTo-Json | Out-File -FilePath $ConfigFile -Encoding utf8
        Write-Host "  ✓ Real-Debrid key saved!" -ForegroundColor Green
    }
} else {
    Write-Host "  ✓ Free P2P mode enabled. You can configure anytime via: nitrate --config" -ForegroundColor DarkGray
}

Write-Host "`n══════════════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host "  🎉 Nitrate is ready! Zero extra setup required." -ForegroundColor Green
Write-Host "══════════════════════════════════════════════════════════════`n" -ForegroundColor Green

Write-Host "  Try running in PowerShell / Terminal:" -ForegroundColor White
Write-Host "    nitrate `"Mindhunter`"" -ForegroundColor Cyan
Write-Host "    nitrate `"Dune: Part Two`"" -ForegroundColor Cyan
Write-Host "    nitrate`n" -ForegroundColor Cyan
