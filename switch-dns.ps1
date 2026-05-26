# ==========================================
# Simple DNS Switcher
# Windows 10/11
# ==========================================

# ---------- AUTO ELEVATION ----------
$principal = New-Object Security.Principal.WindowsPrincipal `
    ([Security.Principal.WindowsIdentity]::GetCurrent())

$adminRole = [Security.Principal.WindowsBuiltInRole]::Administrator

if (-not $principal.IsInRole($adminRole)) {

    Write-Host "Requesting administrator privileges..." -ForegroundColor Yellow

    Start-Process powershell `
        -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" `
        -Verb RunAs

    exit
}

# ---------- CONFIG ----------

# Change adapter name if needed
$interface = "Wi-Fi"
# $interface = "Ethernet"

# ---------- CUSTOM DNS ----------

# IPv4 DNS
$customDNSv4 = @(
    "194.242.2.2",   # Mullvad
    "1.0.0.1"        # Cloudflare
)

# IPv6 DNS
$customDNSv6 = @(
    "2a07:e340::2",      # Mullvad IPv6
    "2606:4700:4700::1001" # Cloudflare IPv6
)

# ---------- FUNCTIONS ----------

function Show-CurrentDNS {

    Write-Host ""
    Write-Host "Current DNS Configuration" `
        -ForegroundColor Cyan

    # IPv4
    Write-Host ""
    Write-Host "IPv4 DNS:" `
        -ForegroundColor Yellow

    $dns4 = Get-DnsClientServerAddress `
        -InterfaceAlias $interface `
        -AddressFamily IPv4

    if ($dns4.ServerAddresses) {
        $dns4.ServerAddresses | ForEach-Object {
            Write-Host " - $_"
        }
    }
    else {
        Write-Host " - Automatic (DHCP)"
    }

    # IPv6
    Write-Host ""
    Write-Host "IPv6 DNS:" `
        -ForegroundColor Yellow

    $dns6 = Get-DnsClientServerAddress `
        -InterfaceAlias $interface `
        -AddressFamily IPv6

    if ($dns6.ServerAddresses) {
        $dns6.ServerAddresses | ForEach-Object {
            Write-Host " - $_"
        }
    }
    else {
        Write-Host " - Automatic"
    }

    Write-Host ""
}

function Set-AutomaticDNS {

    Write-Host ""
    Write-Host "Switching to Automatic DNS..." `
        -ForegroundColor Yellow

    # Reset IPv4 + IPv6
    Set-DnsClientServerAddress `
        -InterfaceAlias $interface `
        -ResetServerAddresses

    ipconfig /flushdns | Out-Null

    Write-Host "Done."
}

function Set-CustomDNS {

    Write-Host ""
    Write-Host "Switching to Custom DNS..." `
        -ForegroundColor Green

    # Apply IPv4 + IPv6 DNS together
    Set-DnsClientServerAddress `
        -InterfaceAlias $interface `
        -ServerAddresses ($customDNSv4 + $customDNSv6)

    ipconfig /flushdns | Out-Null

    Write-Host "Done."
}

# Main Menu
while ($true) {

    Write-Host ""
    Write-Host "DNS Switcher"
    Write-Host "============"
    Write-Host "1. Automatic DNS"
    Write-Host "2. Custom DNS"
    Write-Host "3. Exit"
    Write-Host ""

    Show-CurrentDNS

    $choice = Read-Host "Choose option"

    switch ($choice) {

        "1" {Set-AutomaticDNS}
        "2" {Set-CustomDNS}
        "3" {
            Write-Host ""
            Write-Host "Exiting..."
            return
        }
        default {
            Write-Host ""
            Write-Host "Invalid option." `
                -ForegroundColor Red
        }
    }
}