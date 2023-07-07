. $PSScriptRoot/Utils.ps1

$hasUpdatedExtensions = Confirm-UpdatedExtensions `
    -PathInstalledExtensions "C:\Users\runneradmin\.vscode\extensions" `
    -PathExtensionsJson "$PSScriptRoot\..\extensions.json"

if ($hasUpdatedExtensions) {
    [System.Collections.ArrayList]$extensionList = New-ExtensionArchive `
        -PathInstalledExtensions "C:\Users\runneradmin\.vscode\extensions" `
        -PathArchivedExtensions ".\vscode\extensions"
    
    # Save extension versions as json to file
    Set-ExtensionsJson `
        -Extensions $extensionList `
        -Path "./extensions.json" | Out-Null
        
    # Save vscode version as json to file
    Set-ApplicationsJson `
        -Path "./applications.json" | Out-Null

    # Create release version file
    New-ReleaseVersion `
        -PathApplicationsJson "./applications.json" `
        -PathReleaseVersion "./release_version.json" `
        -HasUpdatedExtensions $hasUpdatedExtensions
        
    Compress-Archive `
        -Path "vscode" `
        -DestinationPath "./vscode_with_extensions.zip"
}
else {
    # Create release version file
    New-ReleaseVersion `
        -PathApplicationsJson "./applications.json" `
        -PathReleaseVersion "./release_version.json" `
        -HasUpdatedExtensions $hasUpdatedExtensions
}