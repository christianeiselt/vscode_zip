. $PSScriptRoot/Utils.ps1

[System.Collections.ArrayList]$extensionList = New-ExtensionArchive `
-PathInstalledExtensions "C:\Users\runneradmin\.vscode\extensions" `
-PathArchivedExtensions "./vscode/extensions"

Write-Host $extensionList.exensions

# Save extension versions as json to file
Set-ExtensionsJson `
-Extensions $extensionList `
-Path "./extensions.json" | Out-Null

Get-ChildItem .
Get-Item extensions.json
$extensionJson = Get-Item extensions.json
$extensionJson.FullName

# Save vscode version as json to file
Set-ApplicationsJson `
-Path "./applications.json" | Out-Null

# Create release version file
New-ReleaseVersion `
-PathApplicationsJson "./applications.json" `
-PathReleaseVersion "./release_version.json"
