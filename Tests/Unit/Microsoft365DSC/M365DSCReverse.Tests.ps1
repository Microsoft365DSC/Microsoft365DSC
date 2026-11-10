BeforeAll {
    Import-Module "$PSScriptRoot/../../../Modules/Microsoft365DSC/Modules/M365DSCDllLoader.psm1" -Force -Global
    Initialize-M365DSCDllLoader
    Import-Module "$PSScriptRoot/../../../Modules/Microsoft365DSC/Microsoft365DSC.psd1" -Global -WarningAction SilentlyContinue

    $Script:Password = ConvertTo-SecureString -String 'Pass@word1' -AsPlainText -Force
    $Script:Credential = [System.Management.Automation.PSCredential]::new('admin@contoso.onmicrosoft.com', $Script:Password)
    $Script:TenantGuid = '11111111-2222-3333-4444-555555555555'
    $Script:ApplicationGuid = '66666666-7777-8888-9999-000000000000'
}

Describe 'Start-M365DSCConfigurationExtract' {
    BeforeEach {
        $Script:OutputPath = Join-Path -Path $TestDrive -ChildPath ([System.Guid]::NewGuid().ToString())
        $null = New-Item -Path $Script:OutputPath -ItemType Directory
        $Script:LocationBefore = (Get-Location).Path

        Mock -ModuleName M365DSCReverse -CommandName Test-M365DSCModuleValidity
        Mock -ModuleName M365DSCReverse -CommandName Confirm-M365DSCDependencies
        Mock -ModuleName M365DSCReverse -CommandName Register-M365DSCExportCollectionConsumers
        Mock -ModuleName M365DSCReverse -CommandName Complete-M365DSCExportCollectionConsumer
        Mock -ModuleName M365DSCReverse -CommandName Get-M365DSCAllResources -MockWith {
            [System.String[]] @('AADGroup', 'AADUser')
        }
        Mock -ModuleName M365DSCReverse -CommandName Get-M365DSCResourcesDictionary -MockWith {
            [System.Collections.Concurrent.ConcurrentDictionary[System.String, System.Object]]::new()
        }
        Mock -ModuleName M365DSCReverse -CommandName Set-M365DSCResourcesDictionary
        Mock -ModuleName M365DSCReverse -CommandName Send-M365DSCPushNotification
        Mock -ModuleName M365DSCReverse -CommandName Write-M365DSCHost
        Mock -ModuleName M365DSCReverse -CommandName New-M365DSCConnection -MockWith { throw 'No tenant connection in unit tests' }
        Mock -ModuleName M365DSCReverse -CommandName Get-M365DSCResourceDefinition -MockWith { $null }
        Mock -ModuleName M365DSCReverse -CommandName Invoke-RestMethod -MockWith { throw 'No network in unit tests' }
        if (Get-Command -Name Get-DscLocalConfigurationManager -ErrorAction SilentlyContinue)
        {
            Mock -ModuleName M365DSCReverse -CommandName Get-DscLocalConfigurationManager -MockWith { [PSCustomObject]@{ CertificateID = $null } }
        }
        Mock -ModuleName M365DSCReverse -CommandName Get-M365DSCComponentsWithMostSecureAuthenticationType -MockWith {
            foreach ($resource in $Resources)
            {
                [PSCustomObject]@{ Resource = $resource; AuthMethod = $AuthenticationMethod[0] }
            }
        }
    }

    AfterEach {
        Set-Location -Path $Script:LocationBefore
    }

    It 'returns early and restores the location when no selected resource is supported' {
        Mock -ModuleName M365DSCReverse -CommandName Get-M365DSCComponentsWithMostSecureAuthenticationType -MockWith { @() }

        Start-M365DSCConfigurationExtract -Components @('AADUser') -Credential $Script:Credential `
            -Path $Script:OutputPath -WarningAction SilentlyContinue

        (Get-Location).Path | Should -Be $Script:LocationBefore
        Test-Path -Path (Join-Path -Path $Script:OutputPath -ChildPath 'M365TenantConfig.ps1') | Should -BeFalse
        Should -Invoke -ModuleName M365DSCReverse -CommandName Confirm-M365DSCDependencies -Times 0 -Exactly
    }

    It 'returns early when the remaining resources are excluded or unsupported' {
        Mock -ModuleName M365DSCReverse -CommandName Get-M365DSCComponentsWithMostSecureAuthenticationType -MockWith {
            [PSCustomObject]@{ Resource = 'AADGroup'; AuthMethod = $AuthenticationMethod[0] }
        }

        Start-M365DSCConfigurationExtract -Components @('AADUser', 'AADGroup') -ExcludeComponents @('AADGroup') `
            -Credential $Script:Credential -Path $Script:OutputPath -WarningAction SilentlyContinue

        Test-Path -Path (Join-Path -Path $Script:OutputPath -ChildPath 'M365TenantConfig.ps1') | Should -BeFalse
        Should -Invoke -ModuleName M365DSCReverse -CommandName Confirm-M365DSCDependencies -Times 0 -Exactly
    }

    It 'restores the location when the extract throws' {
        Mock -ModuleName M365DSCReverse -CommandName Get-M365DSCComponentsWithMostSecureAuthenticationType -MockWith { throw 'auth lookup failed' }

        { Start-M365DSCConfigurationExtract -Components @('AADUser') -Credential $Script:Credential -Path $Script:OutputPath } |
            Should -Throw -ExpectedMessage 'auth lookup failed'

        (Get-Location).Path | Should -Be $Script:LocationBefore
    }

    It 'generates a parsable script for Credential combined with CertificatePath' {
        Start-M365DSCConfigurationExtract -Components @('AADUser') -Credential $Script:Credential `
            -ApplicationId $Script:ApplicationGuid -TenantId $Script:TenantGuid `
            -CertificatePath 'C:\cert.pfx' -CertificatePassword $Script:Credential `
            -Path $Script:OutputPath -WarningAction SilentlyContinue

        $content = Get-Content -Path (Join-Path -Path $Script:OutputPath -ChildPath 'M365TenantConfig.ps1') -Raw

        # The script param block holds both credentials, separated by a comma.
        $scriptParamBlock = $content.Substring(0, $content.IndexOf('Configuration M365TenantConfig'))
        $parseErrors = $null
        $null = [System.Management.Automation.Language.Parser]::ParseInput($scriptParamBlock, [ref]$null, [ref]$parseErrors)
        $parseErrors | Should -BeNullOrEmpty
        $scriptParamBlock | Should -Match '\$Credential,\r\n\r\n    \[Parameter\(\)\]'

        # Each prompt lands in the block of its own credential.
        $certificateBlock = [System.Text.RegularExpressions.Regex]::Match($content, '(?s)if \(\$null -eq \$CertificatePassword\)\r\n    \{(.*?)\}').Groups[1].Value
        $credentialBlock = [System.Text.RegularExpressions.Regex]::Match($content, '(?s)if \(\$null -eq \$Credential\)\r\n    \{(.*?)\}').Groups[1].Value
        $certificateBlock | Should -Match '\$CredsCertificatePassword = Get-Credential'
        $certificateBlock | Should -Not -Match '\$CredsCredential'
        $credentialBlock | Should -Match '\$CredsCredential = Get-Credential'
        $credentialBlock | Should -Not -Match '\$CredsCertificatePassword'
        $content | Should -Match 'M365TenantConfig -ConfigurationData \.\\ConfigurationData\.psd1 -Credential \$CredsCredential -CertificatePassword \$CredsCertificatePassword$'
    }

    It 'declares and prompts for the Credential once when a TenantId is passed with it' {
        Start-M365DSCConfigurationExtract -Components @('AADUser') -Credential $Script:Credential `
            -TenantId $Script:TenantGuid -Path $Script:OutputPath -WarningAction SilentlyContinue

        $content = Get-Content -Path (Join-Path -Path $Script:OutputPath -ChildPath 'M365TenantConfig.ps1') -Raw

        ([System.Text.RegularExpressions.Regex]::Matches($content, '(?m)^        \$Credential\r?$')).Count | Should -Be 1
        ([System.Text.RegularExpressions.Regex]::Matches($content, 'if \(\$null -eq \$Credential\)')).Count | Should -Be 1
        ([System.Text.RegularExpressions.Regex]::Matches($content, '\$CredsCredential = Get-Credential')).Count | Should -Be 1
    }

    Context 'with an exported resource' {
        BeforeEach {
            Mock -ModuleName M365DSCReverse -CommandName Get-M365DSCResourceDefinition -MockWith {
                [PSCustomObject]@{ Name = $ResourceName }
            }
            Mock -ModuleName M365DSCReverse -CommandName Test-M365DSCResourceProperty -MockWith { $false }
            Mock -ModuleName M365DSCReverse -CommandName Invoke-M365DSCResourceMethod -MockWith {
                "        AADUser 'Test'`r`n        {`r`n            UserPrincipalName = 'john@contoso.com'`r`n        }`r`n"
            }
        }

        It 'warns when a filter is passed for a resource without a Filter property' {
            Start-M365DSCConfigurationExtract -Components @('AADUser') -Credential $Script:Credential `
                -Filters @{ AADUser = "DisplayName eq 'John'" } -Path $Script:OutputPath -WarningAction SilentlyContinue

            Should -Invoke -ModuleName M365DSCReverse -CommandName Write-M365DSCHost -Times 1 -Exactly -ParameterFilter {
                $Message -like "*You specified a filter for resource {AADUser} but it doesn't support filters*"
            }
            Should -Invoke -ModuleName M365DSCReverse -CommandName Invoke-M365DSCResourceMethod -Times 1 -Exactly -ParameterFilter {
                -not $Parameters.ContainsKey('Filter')
            }
        }

        It 'writes the configuration even when the validation fails' {
            Mock -ModuleName M365DSCReverse -CommandName Get-M365DSCConfigurationConflict -MockWith { throw 'validation broke' }

            { Start-M365DSCConfigurationExtract -Components @('AADUser') -Credential $Script:Credential `
                    -Validate -Path $Script:OutputPath -WarningAction SilentlyContinue } | Should -Not -Throw

            $content = Get-Content -Path (Join-Path -Path $Script:OutputPath -ChildPath 'M365TenantConfig.ps1') -Raw
            $content | Should -Match "AADUser 'Test'"
            Test-Path -Path (Join-Path -Path $Script:OutputPath -ChildPath 'ConfigurationData.psd1') | Should -BeTrue
        }
    }
}
