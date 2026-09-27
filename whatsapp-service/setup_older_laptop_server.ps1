# VALIXIS 24/7 Home Server Setup Script for Older Laptop
# Configures power settings, firewall, and auto-start so the WhatsApp bot runs forever.

$ErrorActionPreference = "Continue"

Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "   VALIXIS 24/7 WHATSAPP SERVER SETUP (OLDER LAPTOP)        " -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan

# 1. Hardware & Power Plan Configuration (Clamshell / Never Sleep)
Write-Host "`n[1/4] Configuring Power & Sleep Settings..." -ForegroundColor White
try {
    # Set Lid Close Action to 'Do Nothing' when plugged into power
    powercfg -setacvalueindex SCHEME_CURRENT 4f971e80-e3ea-4dac-83d7-a32e3e57c30f 5ca83367-6e45-459f-a27b-476b1d01c936 0
    powercfg -SetActive SCHEME_CURRENT

    # Disable Sleep and Hibernate on AC power
    powercfg -change -standby-timeout-ac 0
    powercfg -change -hibernate-timeout-ac 0
    Write-Host "  [OK] Laptop will NEVER sleep or hibernate when plugged in." -ForegroundColor Green
    Write-Host "  [OK] You can close the laptop lid and tuck it away safely." -ForegroundColor Green
} catch {
    Write-Host "  [Warning] Could not set all powercfg values: $_" -ForegroundColor Yellow
}

# 2. Windows Firewall Configuration
Write-Host "`n[2/4] Configuring Windows Firewall for Port 3001..." -ForegroundColor White
try {
    netsh advfirewall firewall delete rule name="VALIXIS WhatsApp Port 3001" | Out-Null
    netsh advfirewall firewall add rule name="VALIXIS WhatsApp Port 3001" dir=in action=allow protocol=TCP localport=3001 | Out-Null
    Write-Host "  [OK] Port 3001 opened for incoming network requests." -ForegroundColor Green
} catch {
    Write-Host "  [Warning] Could not configure firewall: $_" -ForegroundColor Yellow
}

# 3. Configure Boot Auto-Start for WhatsApp Service
Write-Host "`n[3/4] Configuring Automatic Boot & Auto-Restart..." -ForegroundColor White
$ServiceDir = $PSScriptRoot
$StartupBatch = "$ServiceDir\start_service_hidden.vbs"

# Create a VBScript launcher to run node server.js completely silently in the background
$VbsContent = @"
Set WshShell = CreateObject("WScript.Shell")
WshShell.CurrentDirectory = "$ServiceDir"
WshShell.Run "node server.js", 0, False
"@
Set-Content -Path $StartupBatch -Value $VbsContent -Encoding Ascii

# Register in Windows Task Scheduler on System Boot
$Action = New-ScheduledTaskAction -Execute "wscript.exe" -Argument "`"$StartupBatch`""
$Trigger = New-ScheduledTaskTrigger -AtStartup
$Settings = New-ScheduledTaskSettingsSet `
    -AllowStartIfOnBatteries `
    -DontStopIfGoingOnBatteries `
    -ExecutionTimeLimit (New-TimeSpan -Days 365) `
    -RestartCount 5 `
    -RestartInterval (New-TimeSpan -Minutes 1)

try {
    Unregister-ScheduledTask -TaskName "VALIXIS_WhatsApp_247_Server" -Confirm:$false -ErrorAction SilentlyContinue
    Register-ScheduledTask `
        -TaskName "VALIXIS_WhatsApp_247_Server" `
        -Action $Action `
        -Trigger $Trigger `
        -Settings $Settings `
        -Description "VALIXIS WhatsApp 24/7 Background Microservice" `
        -User "SYSTEM" `
        -Force | Out-Null
    Write-Host "  [OK] Auto-Start registered under SYSTEM account (runs without user login!)." -ForegroundColor Green
} catch {
    # Fallback to Task Scheduler at user logon
    $TriggerLogon = New-ScheduledTaskTrigger -AtLogOn
    Register-ScheduledTask `
        -TaskName "VALIXIS_WhatsApp_247_Server" `
        -Action $Action `
        -Trigger $TriggerLogon `
        -Settings $Settings `
        -Description "VALIXIS WhatsApp 24/7 Background Microservice" `
        -Force | Out-Null
    Write-Host "  [OK] Auto-Start registered at User Logon." -ForegroundColor Green
}

# 4. Display Network IP & Connection Info
Write-Host "`n[4/4] Detecting Local Network IP Address..." -ForegroundColor White
$LocalIP = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.InterfaceAlias -notlike "*Loopback*" -and $_.IPAddress -notlike "169.254*" } | Select-Object -First 1).IPAddress

Write-Host "`n============================================================" -ForegroundColor Cyan
Write-Host "  SETUP COMPLETE! YOUR OLDER LAPTOP IS NOW A 24/7 SERVER!    " -ForegroundColor Green
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "Local Service URL:  http://$LocalIP`:3001" -ForegroundColor Yellow
Write-Host "`nTo connect your main laptop or swarm to this server:" -ForegroundColor White
Write-Host "1. On your main laptop, add this line to your PORTAL/.env file:" -ForegroundColor White
Write-Host "   WHATSAPP_SERVICE_URL=http://$LocalIP`:3001" -ForegroundColor Cyan
Write-Host "`n2. Scan the WhatsApp QR code once by running in this directory:" -ForegroundColor White
Write-Host "   node server.js" -ForegroundColor Cyan
Write-Host "   (Once authenticated, session persists forever in .wwebjs_auth)" -ForegroundColor White
Write-Host "============================================================" -ForegroundColor Cyan
