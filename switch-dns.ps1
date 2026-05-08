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

# Change if your adapter has a different name
$interface = "Wi-Fi"
# $interface = "Ethernet"

# Custom DNS servers
$customDNS = @(
    "194.242.2.2",   # Mullvad
    "1.0.0.1"        # Cloudflare secondary
)

# ---------- FUNCTIONS ----------

function Show-CurrentDNS {

    Write-Host ""
    Write-Host "Current DNS:" -ForegroundColor Cyan

    $dns = Get-DnsClientServerAddress `
        -InterfaceAlias $interface `
        -AddressFamily IPv4

    if ($dns.ServerAddresses) {
        $dns.ServerAddresses | ForEach-Object {
            Write-Host " - $_"
        }
    }
    else {
        Write-Host " - Automatic (DHCP)"
    }

    Write-Host ""
}

function Set-AutomaticDNS {

    Write-Host ""
    Write-Host "Switching to Automatic DNS..." `
        -ForegroundColor Yellow

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

    Set-DnsClientServerAddress `
        -InterfaceAlias $interface `
        -ServerAddresses $customDNS

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