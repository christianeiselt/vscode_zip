function New-ExtensionArchive {
    [CmdletBinding()]
    param (
        [ValidateNotNullOrEmpty()]
        [String]
        $PathInstalledExtensions,
        [ValidateNotNullOrEmpty()]
        [String]
        $PathArchivedExtensions,
        [ValidateNotNullOrEmpty()]
        [String]
        $PathExtensionsJson
    )

    [System.Collections.HashTable]$currentExtensions = (Get-Content -LiteralPath $PathExtensionsJson | ConvertFrom-Json)
    [System.Collections.ArrayList]$extensions_installed_list = @()
    $extensions_installed = Get-ChildItem -LiteralPath $PathInstalledExtensions
    $extensionsUpdated = 0
    foreach ($extension in $extensions_installed) {
        if ($extension.Name -ne "extensions.json") {
            $extension_name = $($extension.Name).Substring(0, $($extension.Name).lastIndexOf('-'))
            $extension_version = $extension.Name.Split('-')[-1]
            $extension_hashtable = [ordered]@{
                "uid"     = $extension_name;
                "version" = $extension_version 
            };
            [void]$extensions_installed_list.Add($extension_hashtable)
    
            Compress-Archive -Path $extension.FullName -DestinationPath "$PathArchivedExtensions/$($extension.Name).zip"

            foreach ($currentExtension in $currentExtensions.extensions) {
                if ($currentExtension.uid -eq $extension_name -and $currentExtension.version -eq $extension_version) {
                    $extensionsUdated += 1
                }                
            }
        }
    }
    
    if ($extensionsUpdated -gt 0) {
        return $extensions_installed_list
    }
    else {
        return @()
    }
}

function Set-ExtensionsJson {
    [CmdletBinding()]
    param (
        [ValidateNotNullOrEmpty()]
        [System.Collections.ArrayList]
        $Extensions,
        [ValidateNotNullOrEmpty()]
        [String]
        $Path
    )

    $extensionsHashtable = @{"extensions" = $Extensions }
    $extensionsJson = $( $extensionsHashtable | ConvertTo-Json)
    $extensionsJson | Set-Content $Path
    $extensionsJsonPath = (Get-Item $Path).FullName

    return $extensionsJsonPath
}

function Set-ApplicationsJson {
    [CmdletBinding()]
    param (
        [ValidateNotNullOrEmpty()]
        [String]
        $Path
    )

    $vscodeBasename = (Get-Item "vscode\VSCode-win32-x64-*.zip").BaseName
    $vscodeVersion = "$($vscodeBasename.Split('-')[-1])"
    [System.Collections.ArrayList]$applicationsList = @(
        [ordered]@{
            "version" = "$vscodeVersion";
            "uid"     = "VSCode-win32-x64"
        }
    )
        
    $applicationsHashtable = @{"applications" = $applicationsList }
    $applicationsJson = $( $applicationsHashtable | ConvertTo-Json)
    $applicationsJson | Set-Content $Path
    $applicationsJsonPath = (Get-Item $Path).FullName

    return $applicationsJsonPath
}

function New-ReleaseVersion {
    [CmdletBinding()]
    param (
        [ValidateNotNullOrEmpty()]
        [String]
        $PathApplicationsJson,
        [ValidateNotNullOrEmpty()]
        [String]
        $PathReleaseVersion
    )

    $applicationHashTable = (Get-Content -LiteralPath $PathApplicationsJson | ConvertFrom-Json)
    $currentReleaseVersionHashtable = (Get-Content -LiteralPath $PathReleaseVersion | ConvertFrom-Json)
    if ($currentReleaseVersionHashtable.appVersion -eq $applicationHashTable.applications.version) {
        $iteration = $currentReleaseVersionHashtable.iteration
        $iteration = $iteration -as [Int]
        $nextIteration = $iteration + 1
    }
    else {
        $nextIteration = 0
    }
    
    $newReleaseVersionHashtable = @{
        "appVersion" = $applicationHashTable.applications.version;
        "iteration"  = "$nextIteration"
    }
    $newReleaseVersionJson = $( $newReleaseVersionHashtable | ConvertTo-Json)
    $newReleaseVersionJson | Set-Content $PathReleaseVersion
    $newReleaseVersion = "$($newReleaseVersionHashtable.appVersion)-$($newReleaseVersionHashtable.iteration)"
    
    return $newReleaseVersion
}
