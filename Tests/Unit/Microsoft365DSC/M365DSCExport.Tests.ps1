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
