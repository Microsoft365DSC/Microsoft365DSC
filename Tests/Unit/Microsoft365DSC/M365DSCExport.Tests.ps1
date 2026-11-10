BeforeAll {
    Import-Module "$PSScriptRoot/../../../Modules/Microsoft365DSC/Modules/M365DSCDllLoader.psm1" -Force -Global
    Initialize-M365DSCDllLoader
    Import-Module "$PSScriptRoot/../../../Modules/Microsoft365DSC/Microsoft365DSC.psd1" -Global -WarningAction SilentlyContinue
}

Describe 'Export-M365DSCConfiguration' {
    It 'accepts ThrottleLimit only together with Parallel' {
        $parameters = (Get-Command -Name Export-M365DSCConfiguration).Parameters
        @($parameters['ThrottleLimit'].ParameterSets.Keys) | Should -Be @('ExportParallel')
        $parameters['Parallel'].ParameterSets['ExportParallel'].IsMandatory | Should -BeTrue
    }

    It 'defaults ThrottleLimit to 5' {
        $parameter = (Get-Command -Name Export-M365DSCConfiguration).ScriptBlock.Ast.Body.ParamBlock.Parameters |
            Where-Object -FilterScript { $_.Name.VariablePath.UserPath -eq 'ThrottleLimit' }
        $parameter.DefaultValue.Value | Should -Be 5
    }

    It 'rejects a ThrottleLimit below 1' {
        { Export-M365DSCConfiguration -Parallel -ThrottleLimit 0 -Components 'AADGroup' } | Should -Throw -ExceptionType ([System.Management.Automation.ParameterBindingException])
    }

    It 'returns the failed resources with the statistics' {
        $statistics = (Get-Command -Name Start-M365DSCConfigurationExtract).ScriptBlock.Ast.FindAll({
                param($node)
                $node -is [System.Management.Automation.Language.HashtableAst] -and
                @($node.KeyValuePairs | ForEach-Object -Process { $_.Item1.Value }) -contains 'ExportDurationInSeconds'
            }, $true)

        $statistics.Count | Should -Be 1
        @($statistics[0].KeyValuePairs | ForEach-Object -Process { $_.Item1.Value }) | Should -Contain 'FailedResources'
    }

    It 'validates the auth parameters before setting up the export state' {
        Mock -ModuleName M365DSCExportUtil -CommandName Initialize-M365DSCExportCollectionCache
        Mock -ModuleName M365DSCExportUtil -CommandName New-M365DSCExportRelationSession

        { Export-M365DSCConfiguration -Components 'AADUser' -ApplicationId 'app' -TenantId 'contoso.onmicrosoft.com' `
                -CertificatePath 'C:\cert.pfx' -IncludeDependencies -WarningAction SilentlyContinue } |
            Should -Throw -ExpectedMessage 'You have to specify CertificatePassword when you specify CertificatePath'

        Should -Invoke -ModuleName M365DSCExportUtil -CommandName Initialize-M365DSCExportCollectionCache -Times 0 -Exactly
        Should -Invoke -ModuleName M365DSCExportUtil -CommandName New-M365DSCExportRelationSession -Times 0 -Exactly
    }

    Context 'when the extract fails' {
        BeforeEach {
            $Script:ProgressPreferenceBefore = $Global:ProgressPreference
            $Global:ProgressPreference = 'Continue'
            $Global:M365DSCExportInProgress = $false

            Mock -ModuleName M365DSCExportUtil -CommandName Confirm-M365DSCDependencies
            Mock -ModuleName M365DSCExportUtil -CommandName Confirm-M365DSCLoadedModule -MockWith { throw 'not loaded' }
            Mock -ModuleName M365DSCExportUtil -CommandName Get-M365DSCTenantNameFromParameterSet -MockWith { 'contoso.onmicrosoft.com' }
            Mock -ModuleName M365DSCExportUtil -CommandName Get-M365DSCTelemetryConnectionParameter -MockWith { @{ TenantId = 'contoso' } }
            Mock -ModuleName M365DSCExportUtil -CommandName Add-M365DSCTelemetryEvent
            Mock -ModuleName M365DSCExportUtil -CommandName Initialize-M365DSCResourcesDictionary
            Mock -ModuleName M365DSCExportUtil -CommandName Get-M365DSCResourceSettings
            Mock -ModuleName M365DSCExportUtil -CommandName Write-M365DSCHost
            Mock -ModuleName M365DSCExportUtil -CommandName Start-M365DSCConfigurationExtract -MockWith {
                if (-not $Global:M365DSCExportInProgress -or $Global:ProgressPreference -ne 'SilentlyContinue')
                {
                    throw 'export state was not set'
                }
                throw 'extract failed'
            }
        }

        AfterEach {
            $Global:ProgressPreference = $Script:ProgressPreferenceBefore
            $Global:M365DSCExportInProgress = $false
        }

        It 'resets the export session state' {
            $credential = [System.Management.Automation.PSCredential]::new('admin@contoso.onmicrosoft.com', (ConvertTo-SecureString -String 'Pass@word1' -AsPlainText -Force))

            { Export-M365DSCConfiguration -Components 'AADUser' -Credential $credential } | Should -Throw -ExpectedMessage 'extract failed'

            $Global:M365DSCExportInProgress | Should -BeFalse
            $Global:ProgressPreference | Should -Be 'Continue'
        }
    }
}

Describe 'Split-M365DSCConfiguration' {
    BeforeAll {
        Mock -ModuleName M365DSCExportUtil -CommandName Write-M365DSCHost

        $Script:SourceConfiguration = @(
            'param ('
            '    [Parameter()]'
            '    [System.Management.Automation.PSCredential]'
            '    $Credential'
            ')'
            ''
            'Configuration MyTenant'
            '{'
            '    param ('
            '        [Parameter()]'
            '        [System.Management.Automation.PSCredential]'
            '        $Credential'
            '    )'
            ''
            '    Node localhost'
            '    {'
            '        AADGroup "AADGroup-One"'
            '        {'
            '            DisplayName = "One"'
            '        }'
            '        AADGroup "AADGroup-Two"'
            '        {'
            '            DisplayName = "Two"'
            '        }'
            '        AADGroup "AADGroup-Three"'
            '        {'
            '            DisplayName = "Three"'
            '        }'
            '    }'
            '}'
            ''
            'MyTenant -ConfigurationData .\ConfigurationData.psd1 -Credential $CredsCredential'
        ) -join "`r`n"
    }

    It 'keeps the configuration name and launch arguments of the source file' {
        $sourcePath = Join-Path -Path $TestDrive -ChildPath 'MyTenant.ps1'
        $outputFolder = Join-Path -Path $TestDrive -ChildPath 'Split'
        $null = New-Item -Path $outputFolder -ItemType Directory -Force
        Set-Content -Path $sourcePath -Value $Script:SourceConfiguration -NoNewline -Encoding utf8

        Split-M365DSCConfiguration -Path $sourcePath -OutputFolder $outputFolder -MaxResources 2

        $files = @(Get-ChildItem -Path $outputFolder -Filter '*.ps1' | Sort-Object -Property Name)
        $files.Count | Should -Be 2
        foreach ($file in $files)
        {
            $content = Get-Content -Path $file.FullName -Raw
            $content | Should -Match 'Configuration MyTenant'
            $content.TrimEnd() | Should -Match 'MyTenant -ConfigurationData \.\\ConfigurationData\.psd1 -Credential \$CredsCredential$'
            $content | Should -Not -Match 'M365TenantConfig'
        }
        Get-Content -Path $files[0].FullName -Raw | Should -Match '(?s)\}\n\n        AADGroup "AADGroup-Two"'
    }

    It 'falls back to the configuration name when the source has no launch line' {
        $sourcePath = Join-Path -Path $TestDrive -ChildPath 'NoLaunch.ps1'
        $outputFolder = Join-Path -Path $TestDrive -ChildPath 'SplitNoLaunch'
        $null = New-Item -Path $outputFolder -ItemType Directory -Force
        $content = $Script:SourceConfiguration.Substring(0, $Script:SourceConfiguration.LastIndexOf('}') + 1)
        Set-Content -Path $sourcePath -Value $content -NoNewline -Encoding utf8

        Split-M365DSCConfiguration -Path $sourcePath -OutputFolder $outputFolder

        $result = Get-Content -Path (Join-Path -Path $outputFolder -ChildPath 'M365TenantConfig_1.ps1') -Raw
        $result.TrimEnd() | Should -Match 'MyTenant -ConfigurationData \.\\ConfigurationData\.psd1$'
    }
}

Describe 'Get-M365DSCWorkloadForResource' {
    It 'returns the VIVA workload for Viva resources' {
        Get-M365DSCWorkloadForResource -ResourceName 'VivaEngagementRoleMember' | Should -Be 'VIVA'
    }
}

Describe 'Telemetry context' {
    It 'applies the values resolved in another runspace' {
        $context = @{
            CurrentRolesResolved    = $true
            CurrentRoles            = @('Global Reader|/')
            OSInfo                  = 'Test OS'
            CurrentPrincipalIsAdmin = $false
            LCMInfo                 = $null
        }

        Set-M365DSCTelemetryContext -Context $context
        $result = Get-M365DSCTelemetryContext

        $result.CurrentRolesResolved | Should -BeTrue
        $result.CurrentRoles | Should -Be @('Global Reader|/')
        $result.OSInfo | Should -Be 'Test OS'
        $result.CurrentPrincipalIsAdmin | Should -BeFalse
    }
}

Describe 'Get-M365DSCResourceSetting' {
    It 'loads the settings of a resource on first use' {
        $settings = Get-M365DSCResourceSetting -ResourceName 'MSFT_AADGroup'
        $settings | Should -Not -BeNullOrEmpty
        $settings.permissions | Should -Not -BeNullOrEmpty
    }
}

Describe 'Export-M365DSCConfiguration dispatch' {
    BeforeAll {
        $password = ConvertTo-SecureString -String 'Pass@word1' -AsPlainText -Force
        $script:exportCredential = [System.Management.Automation.PSCredential]::new('admin@contoso.onmicrosoft.com', $password)
    }

    BeforeEach {
        $script:telemetryEvents = @()
        Mock -ModuleName 'M365DSCExportUtil' -CommandName Start-M365DSCConfigurationExtract -MockWith {}
        Mock -ModuleName 'M365DSCExportUtil' -CommandName Confirm-M365DSCDependencies -MockWith {}
        Mock -ModuleName 'M365DSCExportUtil' -CommandName Confirm-M365DSCLoadedModule -MockWith { throw 'not loaded' }
        Mock -ModuleName 'M365DSCExportUtil' -CommandName Get-M365DSCTenantNameFromParameterSet -MockWith { 'contoso.onmicrosoft.com' }
        Mock -ModuleName 'M365DSCExportUtil' -CommandName Get-M365DSCTelemetryConnectionParameter -MockWith { @{ Credential = $null } }
        Mock -ModuleName 'M365DSCExportUtil' -CommandName Add-M365DSCTelemetryEvent -MockWith {
            $script:telemetryEvents += @{ Type = $Type; Data = $Data }
        }
        Mock -ModuleName 'M365DSCExportUtil' -CommandName Initialize-M365DSCResourcesDictionary -MockWith {}
        Mock -ModuleName 'M365DSCExportUtil' -CommandName Get-M365DSCResourceSettings -MockWith { $null }
        Mock -ModuleName 'M365DSCExportUtil' -CommandName Write-M365DSCHost -MockWith {}
    }

    It 'passes Components and Mode in a single extract call' {
        Export-M365DSCConfiguration -Components 'AADGroup' -Mode 'Full' -Credential $script:exportCredential

        Should -Invoke -ModuleName 'M365DSCExportUtil' -CommandName Start-M365DSCConfigurationExtract -Times 1 -Exactly -ParameterFilter {
            $Components -contains 'AADGroup' -and $Mode -eq 'Full' -and -not $AllComponents -and $null -eq $Workloads
        }
    }

    It 'records whether Path and FileName were provided and the tenant name' {
        Export-M365DSCConfiguration -Components 'AADGroup' -Credential $script:exportCredential
        $initiated = $script:telemetryEvents | Where-Object -FilterScript { $_.Type -eq 'ExportInitiated' }
        $initiated.Data['Path'] | Should -BeFalse
        $initiated.Data['FileName'] | Should -BeFalse
        $completed = $script:telemetryEvents | Where-Object -FilterScript { $_.Type -eq 'ExportCompleted' }
        $completed.Data['Tenant'] | Should -Be 'contoso.onmicrosoft.com'

        $script:telemetryEvents = @()
        Export-M365DSCConfiguration -Components 'AADGroup' -Credential $script:exportCredential -Path 'TestDrive:\' -FileName 'Export.ps1'
        $initiated = $script:telemetryEvents | Where-Object -FilterScript { $_.Type -eq 'ExportInitiated' }
        $initiated.Data['Path'] | Should -BeTrue
        $initiated.Data['FileName'] | Should -BeTrue
    }
}

Describe 'Get-M365DSCExportContentForResource token replacement' {
    BeforeAll {
        $password = ConvertTo-SecureString -String 'Pass@word1' -AsPlainText -Force
        $script:contentCredential = [System.Management.Automation.PSCredential]::new('admin@contoso.onmicrosoft.com', $password)
    }

    BeforeEach {
        InModuleScope -ModuleName 'M365DSCExportUtil' {
            $Script:M365DSCMandatoryKeyCache = @{}
            Set-M365DSCStringReplacementMap -Clear
        }
        [Microsoft365DSC.Relations.ExportInstanceNames]::Reset()
        [Microsoft365DSC.Relations.ExportRelationSession]::Reset()
        Mock -ModuleName 'M365DSCExportUtil' -CommandName Get-M365DSCResourceMandatoryKey -MockWith { @('DisplayName') }
        Mock -ModuleName 'M365DSCExportUtil' -CommandName Get-DSCBlock -MockWith {
            "ABC-123 = 'x';`r`n            Owner = 'john@Contoso.onmicrosoft.com';`r`n            Endpoint = 'CONTOSO.onmicrosoft.com:443';`r`n            Tenant = 'abc-123';`r`n"
        }
    }

    AfterAll {
        InModuleScope -ModuleName 'M365DSCExportUtil' { Set-M365DSCStringReplacementMap -Clear }
    }

    It 'replaces the organization name regardless of casing and mapped tokens, including one at the start of the block' {
        Set-M365DSCStringReplacementMap -Map @{ 'abc-123' = 'TenantGuid' }

        $content = Get-M365DSCExportContentForResource -ResourceName 'AADGroup' -ConnectionMode 'Credentials' `
            -ModulePath 'AADGroup.psm1' -Results @{ DisplayName = 'Group1' } -Credential $script:contentCredential

        $content | Should -BeLike "*Owner = 'john@`$OrganizationName'*"
        $content | Should -BeLike "*Endpoint = '`$(`$OrganizationName):443'*"
        $content | Should -Not -BeLike '*onmicrosoft.com*'
        $content | Should -BeLike "*Tenant = '`$(`$ConfigurationData.NonNodeData.TenantGuid)'*"
        $content | Should -BeLike "*`$(`$ConfigurationData.NonNodeData.TenantGuid) = 'x'*"
        $content | Should -Not -BeLike '*abc-123*'
    }

    It 'leaves the content untouched when no organization name can be derived' {
        $content = Get-M365DSCExportContentForResource -ResourceName 'AADGroup' -ConnectionMode 'AccessTokens' `
            -ModulePath 'AADGroup.psm1' -Results @{ DisplayName = 'Group1' }

        $content | Should -BeLike "*Owner = 'john@Contoso.onmicrosoft.com'*"
    }
}
