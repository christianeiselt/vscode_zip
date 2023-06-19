function New-ExtensionArchive {
    [CmdletBinding()]
    param (
        [ValidateNotNullOrEmpty()]
        [String]
        $PathInstalledExtensions,
        [ValidateNotNullOrEmpty()]
        [String]
        $PathArchivedExtensions
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
    
    return $extensions_list
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
        $nextIteration = $iteration + 1
    }
    else {
        $nextIteration = 0
    }
    
    $newReleaseVersionHashtable = @{
        "appVersion" = $applicationHashTable.applications.version;
        "interation" = "$nextIteration"
    }
    $newReleaseVersionJson = $( $newReleaseVersionHashtable | ConvertTo-Json)
    $newReleaseVersionJson | Set-Content $PathReleaseVersion
    $newReleaseVersion = "$($newReleaseVersionHashtable.appVersion)-$($newReleaseVersionHashtable.interation)"
    
    return $newReleaseVersion
}
