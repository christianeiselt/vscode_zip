$AdditionalExtensions = (Get-Content ./package-lock.json | ConvertFrom-Json).extensions.uid

if (!(Test-Path "$env:ProgramFiles\Microsoft VS Code\bin\code.cmd")) {
    Write-Host "`nDownloading latest Visual Studio Code (64-Bit)..." -ForegroundColor Yellow
    Remove-Item -Force "$env:TEMP\vscode-stable.exe" -ErrorAction SilentlyContinue
    Invoke-WebRequest -Uri "https://vscode-update.azurewebsites.net/latest/win32-x64/stable" -OutFile "$env:TEMP\vscode-stable.exe"

    Write-Host "`nInstalling Visual Studio Code (64-Bit)..." -ForegroundColor Yellow
    Start-Process -Wait "$env:TEMP\vscode-stable.exe" -ArgumentList /silent, /mergetasks=!runcode
}
else {
    Write-Host "`nVisual Studio Code (64-Bit) is already installed." -ForegroundColor Yellow
}

$extensions = @("ms-vscode.PowerShell") + $AdditionalExtensions
foreach ($extension in $extensions) {
    Write-Host "`nInstalling extension $extension..." -ForegroundColor Yellow
    & $codeCmdPath --install-extension $extension
}