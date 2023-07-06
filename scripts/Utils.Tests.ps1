BeforeAll {
    . $PSScriptRoot/Utils.ps1
}

Describe 'New-ExtensionArchive' {
    BeforeEach {
        if (!(Test-Path "installed")) {
            New-Item -ItemType Directory -Path "installed" 
        }
        if (!(Test-Path "archived")) {
            New-Item -ItemType Directory -Path "archived" 
        }
        $global:directory1 = New-Item -ItemType Directory -Path "installed" -Name "developer1.extension1-1.0.0"
        $global:file1 = New-Item -ItemType File -Path $directory1 -Name "file1.txt"
        $global:directory2 = New-Item -ItemType Directory -Path "installed" -Name "developer2.extension2-1.0.0"
        $global:file2 = New-Item -ItemType File -Path $directory2 -Name "file2.txt"
        $global:directory3 = New-Item -ItemType Directory -Path "installed" -Name "developer3.extension3-1.0.0"
        $global:file3 = New-Item -ItemType File -Path $directory3 -Name "file3.txt"
    }

    It 'Given Path, returns extensions list' {
        $expectedExtensionList = @(
            [ordered]@{"uid" = "developer1.extension1"; "version" = "1.0.0" },
            [ordered]@{"uid" = "developer2.extension2"; "version" = "1.0.0" },
            [ordered]@{"uid" = "developer3.extension3"; "version" = "1.0.0" }
        )

        $resultExtensionList = New-ExtensionArchive `
            -PathInstalledExtensions "installed" `
            -PathArchivedExtensions "archived"

        $resultExtensionList.Count | Should -Be $expectedExtensionList.Count
        $resultExtensionList[0].uid | Should -Be $expectedExtensionList[0].uid
        $resultExtensionList[0].version | Should -Be $expectedExtensionList[0].version
        $resultExtensionList[1].uid | Should -Be $expectedExtensionList[1].uid
        $resultExtensionList[1].version | Should -Be $expectedExtensionList[1].version
        $resultExtensionList[2].uid | Should -Be $expectedExtensionList[2].uid
        $resultExtensionList[2].version | Should -Be $expectedExtensionList[2].version
    }

    AfterEach {
        if (Test-Path "installed") {
            Remove-Item -Recurse -Path "installed"
        }
        if (Test-Path "archived") {
            Remove-Item -Recurse -Path "archived"
        }
    }
}

Describe 'Set-ExtensionsJson' {
    BeforeEach {
        $global:extensionsJsonPath = "extensionsTest.json"
        if (! (Test-Path $extensionsJsonPath)) {
            New-Item $extensionsJsonPath 
        }
    }
    
    It 'Given extensions list, creates extensionsTest.json and returns its path' {
        $extensionList = @(
            [ordered]@{"uid" = "developer1.extension1"; "version" = "1.0.0" },
            [ordered]@{"uid" = "developer2.extension2"; "version" = "1.0.0" },
            [ordered]@{"uid" = "developer3.extension3"; "version" = "1.0.0" }
        )
        $expectedPath = (Get-Item $extensionsJsonPath).FullName
        $resultPath = Set-ExtensionsJson -Extensions $extensionList -Path $extensionsJsonPath

        $resultPath | Should -Be $expectedPath
        Test-Path "extensionsTest.json" | Should -Be $True
    }

    AfterEach {
        if (Test-Path $extensionsJsonPath) {
            Remove-Item $extensionsJsonPath 
        }
    }
}

Describe 'Set-ApplicationsJson' {
    BeforeEach {
        $global:applicationsJsonPath = "applicationsTest.json"
        if (! (Test-Path $applicationsJsonPath)) {
            New-Item $applicationsJsonPath 
        }
        $global:applicationArchivePath = "vscode\VSCode-win32-x64-*.zip"
        if (! (Test-Path $applicationArchivePath)) {
            New-Item -ItemType Directory "vscode"
            New-Item "vscode\VSCode-win32-x64-1.0.0.zip"
        }
    }
    
    It 'Given applications list, creates applicationsTest.json and returns its path' {
        $expectedPath = (Get-Item $applicationsJsonPath).FullName
        $resultPath = Set-ApplicationsJson -Path $applicationsJsonPath

        $resultPath | Should -Be $expectedPath
        Test-Path "applicationsTest.json" | Should -Be $True
    }

    AfterEach {
        if (Test-Path $applicationsJsonPath) {
            Remove-Item $applicationsJsonPath 
            Remove-Item -Recurse "vscode"
        }
    }
}

Describe 'New-ReleaseVersion' {
    BeforeEach {
        $releaseVersionHashtable = @{
            "appVersion" = "1.0.0";
            "iteration"  = "0"
        }
        $releaseVersionJson = $( $releaseVersionHashtable | ConvertTo-Json)
        $releaseVersionJson | Set-Content "release_version_test.json"
    }

    It 'Given version file path, same app version as in file, returns version with incremented iteration' {
        $applicationsHashtable = @{
            "applications" = @(

                [ordered]@{
                    "version" = "1.0.0";
                    "uid"     = "VSCode-win32-x64"
                }
            )
        }
        $applicationsJson = $( $applicationsHashtable | ConvertTo-Json)
        $applicationsJson | Set-Content "applications_test.json"
        $expectedReleaseVersion = "1.0.0-1"
        $resultReleaseVersion = New-ReleaseVersion -PathApplicationsJson "applications_test.json" -PathReleaseVersion "release_version_test.json"
        
        $resultReleaseVersion | Should -Be $expectedReleaseVersion
    }

    It 'Given version file path, new app version as in file, returns version with new appversion and iteration 0' {
        $applicationsHashtable = @{
            "applications" = @(

                [ordered]@{
                    "version" = "1.1.0";
                    "uid"     = "VSCode-win32-x64"
                }
            )
        }
        $applicationsJson = $( $applicationsHashtable | ConvertTo-Json)
        $applicationsJson | Set-Content "applications_test.json"
        $expectedReleaseVersion = "1.1.0-0"
        $resultReleaseVersion = New-ReleaseVersion -PathApplicationsJson "applications_test.json" -PathReleaseVersion "release_version_test.json"
        
        $resultReleaseVersion | Should -Be $expectedReleaseVersion
    }

    AfterEach {
        if (Test-Path "release_version_test.json") {
            Remove-Item "release_version_test.json"
        }
        if (Test-Path "applications_test.json") {
            Remove-Item "applications_test.json"
        } }
}

Describe 'Confirm-UpdatedExtensions' {
    BeforeEach {
        if (!(Test-Path "installed")) {
            New-Item -ItemType Directory -Path "installed" 
        }
        $global:directory1 = New-Item -ItemType Directory -Path "installed" -Name "developer1.extension1-1.1.0"
        $global:file1 = New-Item -ItemType File -Path $directory1 -Name "file1.txt"
        $global:directory2 = New-Item -ItemType Directory -Path "installed" -Name "developer2.extension2-1.0.0"
        $global:file2 = New-Item -ItemType File -Path $directory2 -Name "file2.txt"
        $global:directory3 = New-Item -ItemType Directory -Path "installed" -Name "developer3.extension3-1.0.0"
        $global:file3 = New-Item -ItemType File -Path $directory3 -Name "file3.txt"
    }

    It 'Given path of installed extensions, exensions.json with same versions - returns $False' {
        $extensionsTestJson = @{
            'extensions' = @(
                @{
                    'uid' = 'developer1.extension1';
                    'version' = '1.1.0'
                },
                @{
                    'uid' = 'developer2.extension2';
                    'version' = '1.0.0'
                },
                @{
                    'uid' = 'developer3.extension3';
                    'version' = '1.0.0'
                }
            )
        } | ConvertTo-Json
        $extensionsTestJsonPath = "$PSScriptRoot\..\extensionsTest.json"
        $extensionsTestJson | Set-Content $extensionsTestJsonPath

        $hasUpdatedExtensions = Confirm-UpdatedExtensions `
            -PathInstalledExtensions "installed" `
            -PathExtensionsJson "$extensionsTestJsonPath"
        $hasUpdatedExtensions | Should -Be $False
    }

    It 'Given path of installed extensions, exensions.json with older versions - returns $True' {
        $extensionsTestJson = @{
            'extensions' = @(
                @{
                    'uid' = 'developer1.extension1';
                    'version' = '1.0.0'
                },
                @{
                    'uid' = 'developer2.extension2';
                    'version' = '1.0.0'
                },
                @{
                    'uid' = 'developer3.extension3';
                    'version' = '1.0.0'
                }
            )
        } | ConvertTo-Json
        $extensionsTestJsonPath = "$PSScriptRoot\..\extensionsTest.json"
        $extensionsTestJson | Set-Content $extensionsTestJsonPath

        $hasUpdatedExtensions = Confirm-UpdatedExtensions `
            -PathInstalledExtensions "installed" `
            -PathExtensionsJson "$extensionsTestJsonPath"
        $hasUpdatedExtensions | Should -Be $True
    }

    AfterEach {
        if (Test-Path "installed") {
            Remove-Item -Recurse -Path "installed"
        }
    }
}

AfterAll {

}
