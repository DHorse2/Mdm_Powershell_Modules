
# Chocolatey
if (!(Get-Command choco -ErrorAction SilentlyContinue)) {
    Write-Host "Chocolatey not found. Installing Chocolatey..."
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
} else {
    Write-Verbose "Chocolatey is already installed."
}

# winget -update

# python 
# pip is up to date
Write-Verbose "Updating pip..." -ForegroundColor Cyan
python -m ensurepip
python -m pip install --upgrade pip
# Virtualenv
Write-Verbose "Installing virtualenv..." -ForegroundColor Cyan
python -m pip install --user virtualenv
    
