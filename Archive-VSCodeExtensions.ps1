[System.Collections.ArrayList]$extensions_list = @()
# Archive each installed extension
$extensions_installed = Get-ChildItem "C:\Users\runneradmin\.vscode\extensions"
foreach ($ext_inst in $extensions_installed)
{
    if ($ext_inst.Name -ne "extensions.json")
    {
        Write-Host $ext_inst.FullName
        $extension_name = $($ext_inst.Name).Substring(0, $($ext_inst.Name).lastIndexOf('-'))
        $extension_version = $ext_inst.Name.Split('-')[-1]
        $extension_hashtable = @{
            "uid" = $extension_name;
            "version" = $extension_version };
        [void]$extensions_list.Add($extension_hashtable)

        Write-Host "Archiving version $extension_version of extension $extension_name ($($ext_inst.FullName))"
        Compress-Archive -Path $ext_inst.FullName -DestinationPath "./vscode/extensions/$($ext_inst.Name).zip"
    }
}

$vscode_basename = (Get-Item "vscode\VSCode-win32-x64-*.zip").BaseName
$vscode_version = "$($vscode_basename.Split('-')[-1])"
[System.Collections.Hashtable]$packages = [ordered]@{
    "applications" = @(
        @{
            "version" = "$vscode_version";
            "uid" = "VSCode-win32-x64"
        }
    );
    "extensions" = $extensions_list
}
$jsonRepresentation = $( $packages | ConvertTo-Json)
Write-Host $jsonRepresentation
$jsonRepresentation | Set-Content ".\packages.json"
