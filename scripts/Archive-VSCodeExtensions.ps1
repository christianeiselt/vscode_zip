. $PSScriptRoot/Utils.ps1

if (Test-Path "./vscode/extensions")
{
    Write-Host "Path is available"
}
else {
    New-Item -ItemType Directory -Name "extensions"
}

[System.Collections.ArrayList]$extensionList = New-ExtensionArchive
-PathInstalledExtensions "C:\Users\runneradmin\.vscode\extensions"
-PathArchivedExtensions "./vscode/extensions" | Out-Null

# Save extension versions as json to file
Set-ExtensionsJson -Extensions $extensionList -Path "./extensions.json" | Out-Null

# Save vscode version as json to file
Set-ApplicationsJson -Path "./applications.json" | Out-Null

# Create release version file
New-ReleaseVersion -PathApplicationsJson "./applications.json" -PathReleaseVersion "./release_version.json"
