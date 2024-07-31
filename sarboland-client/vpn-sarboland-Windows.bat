# Define the SSH connection parameters
$ssh_user = "laptop"
$ssh_host = "154.16.16.128"
$ssh_port = "9011"
$ssh_password = "laptop"

# Define the usage function
function Show-Usage {
    Write-Output "Usage: .\vpn-sarboland-Windows.batK [-u user] [-H host] [-p port] [-P password]"
    Write-Output "  -u user         The SSH user name. Default: $ssh_user"
    Write-Output "  -H host         The SSH host name or IP address. Default: $ssh_host"
    Write-Output "  -p port         The SSH port number. Default: $ssh_port"
    Write-Output "  -P password     The SSH password."
}

# Parse the command-line options
param (
    [string]$u,
    [string]$H,
    [string]$p,
    [string]$P
)

if ($u) { $ssh_user = $u }
if ($H) { $ssh_host = $H }
if ($p) { $ssh_port = $p }
if ($P) { $ssh_password = $P }

# Check and install requirements
function Install-Requirements {
    if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
        Write-Output "Installing Chocolatey..."
        Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
    }
    if (-not (Get-Command plink -ErrorAction SilentlyContinue)) {
        Write-Output "Installing PuTTY..."
        choco install putty -y
    }
    if (-not (Get-Command sshuttle -ErrorAction SilentlyContinue)) {
        Write-Output "Installing sshuttle..."
        choco install sshuttle -y
    }
}

# Install requirements
Install-Requirements

# Define the VPN functions
function Start-VPN {
    Stop-VPN
    Write-Output "Starting VPN..."
    Start-Process -NoNewWindow plink -ArgumentList "-ssh -pw $ssh_password -L 1080:127.0.0.1:1080 -P $ssh_port $ssh_user@$ssh_host -N"
}

function Stop-VPN {
    Write-Output "Stopping VPN..."
    Stop-Process -Name plink -Force -ErrorAction SilentlyContinue
}

# Turn off any existing VPN connections
Stop-VPN

# Turn on the VPN
Start-VPN

# Wait for user input before closing the VPN connection
while ($true) {
    Write-Output "Choose an option below:"
    $choice = Read-Host "[q]Turn Off     [r]Restart VPN"
    switch ($choice) {
        'q' {
            Write-Output "Turning off VPN..."
            Stop-VPN
            exit
        }
        'r' {
            Write-Output "Restarting VPN..."
            Stop-VPN
            Start-VPN
        }
        default {
            Write-Output "Invalid choice. Please try again."
        }
    }
}

# Call the function when the terminal is closed
trap {
    Stop-VPN
} Finally {
    Write-Output "Exiting script..."
}
