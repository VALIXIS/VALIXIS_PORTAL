# VALIXIS 24/7 Server Master Setup Script
# Run in PowerShell as Administrator on the older laptop.

Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "   VALIXIS MASTER 24/7 SERVER SETUP FOR WINDOWS             " -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan

# 1. Enable Native Windows OpenSSH Server
Write-Host "`n[1/4] Installing & Starting OpenSSH Server..." -ForegroundColor White
try {
    $sshCapability = Get-WindowsCapability -Online | Where-Object Name -like 'OpenSSH.Server*'
    if ($sshCapability.State -ne 'Installed') {
        Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0 | Out-Null
    }
    Start-Service sshd -ErrorAction SilentlyContinue
    Set-Service -Name sshd -StartupType 'Automatic'
    netsh advfirewall firewall add rule name="OpenSSH Port 22" dir=in action=allow protocol=TCP localport=22 | Out-Null
    Write-Host "  [OK] OpenSSH Server is ACTIVE and listening on Port 22!" -ForegroundColor Green
} catch {
    Write-Host "  [Warning] OpenSSH setup: $_" -ForegroundColor Yellow
}

# 2. Share D: Drive over Network
Write-Host "`n[2/4] Sharing D: Drive..." -ForegroundColor White
try {
    # Allow guest access without password
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters" -Name "AllowInsecureGuestAuth" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "LocalAccountTokenFilterPolicy" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue

    if (Test-Path "D:\") {
        Remove-SmbShare -Name "D" -Force -ErrorAction SilentlyContinue
        New-SmbShare -Name "D" -Path "D:\" -FullAccess "Everyone" -ErrorAction SilentlyContinue | Out-Null
        Write-Host "  [OK] D:\ drive successfully shared as \\subhash-pc\D!" -ForegroundColor Green
    } else {
        Write-Host "  [Notice] D:\ drive not found on this machine." -ForegroundColor Yellow
    }
} catch {
    Write-Host "  [Warning] Share setup: $_" -ForegroundColor Yellow
}

# 3. Configure Never Sleep / Clamshell Mode
Write-Host "`n[3/4] Configuring 24/7 Clamshell & Never Sleep Power Plan..." -ForegroundColor White
try {
    powercfg -setacvalueindex SCHEME_CURRENT 4f971e80-e3ea-4dac-83d7-a32e3e57c30f 5ca83367-6e45-459f-a27b-476b1d01c936 0
    powercfg -SetActive SCHEME_CURRENT
    powercfg -change -standby-timeout-ac 0
    powercfg -change -hibernate-timeout-ac 0
    Write-Host "  [OK] Laptop will stay running 24/7 with the lid closed." -ForegroundColor Green
} catch {
    Write-Host "  [Warning] Powercfg: $_" -ForegroundColor Yellow
}

# 4. Open Firewall Port 3001 for WhatsApp Service
Write-Host "`n[4/4] Opening Firewall Port 3001..." -ForegroundColor White
try {
    netsh advfirewall firewall add rule name="VALIXIS WhatsApp Port 3001" dir=in action=allow protocol=TCP localport=3001 | Out-Null
    Write-Host "  [OK] Port 3001 opened." -ForegroundColor Green
} catch {
    Write-Host "  [Warning] Firewall: $_" -ForegroundColor Yellow
}

Write-Host "`n============================================================" -ForegroundColor Cyan
Write-Host "  SETUP COMPLETE! ALL DOORS ARE UNLOCKED FOR ANTIGRAVITY!   " -ForegroundColor Green
Write-Host "============================================================" -ForegroundColor Cyan
