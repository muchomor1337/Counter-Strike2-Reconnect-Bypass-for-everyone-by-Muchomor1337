$ErrorActionPreference = "Stop"

$SteamPath = "D:\steam\steam.exe"
$RuleName = "BlockSteamTemp"

$host.UI.RawUI.WindowTitle = "Reconnect Bypass - Muchomor1337"

try {
    $host.UI.RawUI.BackgroundColor = "Black"
    $host.UI.RawUI.ForegroundColor = "White"

    $size = $host.UI.RawUI.WindowSize
    $size.Width = 72
    $size.Height = 22
    $host.UI.RawUI.WindowSize = $size

    $buffer = $host.UI.RawUI.BufferSize
    $buffer.Width = 72
    if ($buffer.Height -lt 300) { $buffer.Height = 300 }
    $host.UI.RawUI.BufferSize = $buffer
} catch {}

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

Add-Type @"
using System.Runtime.InteropServices;

public static class KeyboardState
{
    [DllImport("user32.dll")]
    public static extern short GetAsyncKeyState(int vKey);
}
"@

function Draw-UI {
    param([bool]$Offline)

    Clear-Host

    Write-Host ""
    Write-Host "  ╔══════════════════════════════════════════════════════════════════╗" -ForegroundColor DarkGray
    Write-Host "  ║                                                                  ║" -ForegroundColor DarkGray
    Write-Host "  ║              " -NoNewline -ForegroundColor DarkGray
    Write-Host "RECONNECT BYPASS" -NoNewline -ForegroundColor Cyan
    Write-Host "                                     ║" -ForegroundColor DarkGray
    Write-Host "  ║              " -NoNewline -ForegroundColor DarkGray
    Write-Host "by Muchomor1337" -NoNewline -ForegroundColor DarkGray
    Write-Host "                                    ║" -ForegroundColor DarkGray
    Write-Host "  ║                                                                  ║" -ForegroundColor DarkGray
    Write-Host "  ╠══════════════════════════════════════════════════════════════════╣" -ForegroundColor DarkGray
    Write-Host "  ║                                                                  ║" -ForegroundColor DarkGray

    if ($Offline) {
        Write-Host "  ║              STATUS: " -NoNewline -ForegroundColor DarkGray
        Write-Host "STEAM OFFLINE" -NoNewline -ForegroundColor Red
        Write-Host "                                  ║" -ForegroundColor DarkGray
        Write-Host "  ║              Firewall block: " -NoNewline -ForegroundColor DarkGray
        Write-Host "ENABLED" -NoNewline -ForegroundColor Red
        Write-Host "                                ║" -ForegroundColor DarkGray
    }
    else {
        Write-Host "  ║              STATUS: " -NoNewline -ForegroundColor DarkGray
        Write-Host "STEAM ONLINE" -NoNewline -ForegroundColor Green
        Write-Host "                                   ║" -ForegroundColor DarkGray
        Write-Host "  ║              Firewall block: " -NoNewline -ForegroundColor DarkGray
        Write-Host "DISABLED" -NoNewline -ForegroundColor Green
        Write-Host "                               ║" -ForegroundColor DarkGray
    }

    Write-Host "  ║                                                                  ║" -ForegroundColor DarkGray
    Write-Host "  ╠══════════════════════════════════════════════════════════════════╣" -ForegroundColor DarkGray
    Write-Host "  ║                                                                  ║" -ForegroundColor DarkGray
    Write-Host "  ║              " -NoNewline -ForegroundColor DarkGray
    Write-Host "[ F5 ]" -NoNewline -ForegroundColor Yellow
    Write-Host "  Toggle reconnect                                 ║" -ForegroundColor DarkGray
    Write-Host "  ║              " -NoNewline -ForegroundColor DarkGray
    Write-Host "[ F6 ]" -NoNewline -ForegroundColor Yellow
    Write-Host "  Exit                                             ║" -ForegroundColor DarkGray
    Write-Host "  ║                                                                  ║" -ForegroundColor DarkGray
    Write-Host "  ╚══════════════════════════════════════════════════════════════════╝" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "                     Running in background..." -ForegroundColor DarkGray
}

function Show-Overlay {
    param([bool]$Offline)

    $form = New-Object System.Windows.Forms.Form
    $form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::None
    $form.ShowInTaskbar = $false
    $form.TopMost = $true
    $form.StartPosition = [System.Windows.Forms.FormStartPosition]::Manual
    $form.Size = New-Object System.Drawing.Size(430, 92)
    $form.BackColor = [System.Drawing.Color]::Black
    $form.Opacity = 0.94

    $label = New-Object System.Windows.Forms.Label
    $label.Dock = [System.Windows.Forms.DockStyle]::Fill
    $label.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
    $label.Font = New-Object System.Drawing.Font("Segoe UI", 20, [System.Drawing.FontStyle]::Bold)
    $label.ForeColor = [System.Drawing.Color]::White
    $label.BackColor = [System.Drawing.Color]::Black

    if ($Offline) {
        $label.Text = "RECONNECT ENABLED`r`nSTEAM OFFLINE"
    }
    else {
        $label.Text = "RECONNECT DISABLED`r`nSTEAM ONLINE"
    }

    $form.Controls.Add($label)

    $screen = [System.Windows.Forms.Screen]::FromPoint([System.Windows.Forms.Cursor]::Position)
    $area = $screen.WorkingArea
    $x = $area.Left + [int](($area.Width - $form.Width) / 2)
    $y = $area.Top + 40
    $form.Location = New-Object System.Drawing.Point($x, $y)

    $form.Show()
    $form.BringToFront()

    $sw = [Diagnostics.Stopwatch]::StartNew()
    while ($sw.ElapsedMilliseconds -lt 1100) {
        [System.Windows.Forms.Application]::DoEvents()
        Start-Sleep -Milliseconds 15
    }

    $form.Close()
    $form.Dispose()
}

if (-not (Test-Path -LiteralPath $SteamPath)) {
    [System.Windows.Forms.MessageBox]::Show(
        "Steam not found:`n$SteamPath",
        "Reconnect Error",
        [System.Windows.Forms.MessageBoxButtons]::OK,
        [System.Windows.Forms.MessageBoxIcon]::Error
    ) | Out-Null
    exit
}

$rule = Get-NetFirewallRule -DisplayName $RuleName -ErrorAction SilentlyContinue

if (-not $rule) {
    New-NetFirewallRule `
        -DisplayName $RuleName `
        -Direction Outbound `
        -Program $SteamPath `
        -Action Block `
        -Enabled False | Out-Null
}

Disable-NetFirewallRule -DisplayName $RuleName -ErrorAction SilentlyContinue | Out-Null

$Offline = $false
Draw-UI $Offline

$VK_F5 = 0x74
$VK_F6 = 0x75

$lastF5 = $false
$lastF6 = $false
$running = $true

while ($running) {
    $f5 = (([KeyboardState]::GetAsyncKeyState($VK_F5) -band 0x8000) -ne 0)
    $f6 = (([KeyboardState]::GetAsyncKeyState($VK_F6) -band 0x8000) -ne 0)

    if ($f5 -and -not $lastF5) {
        if ($Offline) {
            Disable-NetFirewallRule -DisplayName $RuleName | Out-Null
            $Offline = $false
        }
        else {
            Enable-NetFirewallRule -DisplayName $RuleName | Out-Null
            $Offline = $true
        }

        Draw-UI $Offline
        Show-Overlay $Offline
    }

    if ($f6 -and -not $lastF6) {
        $running = $false
    }

    $lastF5 = $f5
    $lastF6 = $f6

    [System.Windows.Forms.Application]::DoEvents()
    Start-Sleep -Milliseconds 20
}

Disable-NetFirewallRule -DisplayName $RuleName -ErrorAction SilentlyContinue | Out-Null
