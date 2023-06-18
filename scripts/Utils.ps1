function New-ExtensionArchive {
    [CmdletBinding()]
    param (
        [String]$PathInstalledExtensions,
        [String]$PathArchivedExtensions
    )

    [System.Collections.ArrayList]$extensions_list = @()
    $extensions_installed = Get-ChildItem -LiteralPath $PathInstalledExtensions
    foreach ($ext_inst in $extensions_installed) {
        if ($ext_inst.Name -ne "extensions.json") {
            $extension_name = $($ext_inst.Name).Substring(0, $($ext_inst.Name).lastIndexOf('-'))
            $extension_version = $ext_inst.Name.Split('-')[-1]
            $extension_hashtable = [ordered]@{
                "uid"     = $extension_name;
                "version" = $extension_version 
            };
            [void]$extensions_list.Add($extension_hashtable)
    
            Compress-Archive -Path $ext_inst.FullName -DestinationPath "$PathArchivedExtensions/$($ext_inst.Name).zip"
        }
    }
    
    $extensions_list
}

function Set-ExtensionsJson {
    [CmdletBinding()]
    param (
        [System.Collections.ArrayList]$Extensions,
        [String]$Path
    )

    $extensionsHashtable = @{"extensions" = $Extensions }
    $extensionsJson = $( $extensionsHashtable | ConvertTo-Json)
    $extensionsJson | Set-Content $Path
    $extensionsJsonPath = (Get-Item $Path).FullName

    $extensionsJsonPath
}

function Set-ApplicationsJson {
    [CmdletBinding()]
    param (
        [String]$Path
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

    $applicationsJsonPath
}

function New-ReleaseVersion {
    [CmdletBinding()]
    param (
        [Parameter()]
        [String]
        $PathApplicationsJson,
        [Parameter()]
        [String]
        $PathReleaseVersion
    )

    $applicationHashTable = (Get-Content -LiteralPath $PathApplicationsJson | ConvertFrom-Json)
    $currentReleaseVersionHashtable = (Get-Content -LiteralPath $PathReleaseVersion | ConvertFrom-Json)
    if ($currentReleaseVersionHashtable.appVersion -eq $applicationHashTable.applications.version) {
        $iteration = $currentReleaseVersionHashtable.iteration
        $nextIteration = $iteration + 1
    }
    else {
        $nextIteration = 0
    }
    
    $newReleaseVersionHashtable = @{
        "appVersion" = $applicationHashTable.applications.version;
        "interation" = $nextIteration
    }
    $newReleaseVersionJson = $( $newReleaseVersionHashtable | ConvertTo-Json)
    $newReleaseVersionJson | Set-Content $PathReleaseVersion
    
    $newReleaseVersion = "$($newReleaseVersionHashtable.appVersion)-$($newReleaseVersionHashtable.interation)"
    $newReleaseVersion
}
