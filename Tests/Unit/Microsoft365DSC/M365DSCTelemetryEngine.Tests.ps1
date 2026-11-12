BeforeAll {
    $Script:TelemetryModule = $null
    $Script:DefinedStubs = @()
    if (-not (Test-Path -Path 'Function:\Get-M365DSCTelemetryConnectionParameter'))
    {
        New-Item -Path 'Function:\global:Get-M365DSCTelemetryConnectionParameter' -Value { } | Out-Null
        $Script:DefinedStubs += 'Get-M365DSCTelemetryConnectionParameter'
    }
    if ($null -eq (Get-Module -Name 'Microsoft365DSC'))
    {
        $Script:TelemetryModule = Import-Module "$PSScriptRoot/../../../Modules/Microsoft365DSC/Modules/M365DSCTelemetryEngine.psm1" -PassThru
    }

    $Script:OriginalTelemetryState = InModuleScope -ModuleName M365DSCTelemetryEngine -ScriptBlock {
        @{
            TelemetryEnabled        = $Script:TelemetryEnabled
            OSInfo                  = $Script:M365DSCOSInfo
            CurrentPrincipalIsAdmin = $Script:M365DSCCurrentPrincipalIsAdmin
        }
    }

    function New-TelemetryData
    {
        param ([System.Collections.Hashtable] $Values)

        $data = [System.Collections.Generic.Dictionary[[System.String], [System.Object]]]::new()
        foreach ($key in $Values.Keys)
        {
            $data.Add($key, $Values[$key])
        }
        return , $data
    }
}

AfterAll {
    InModuleScope -ModuleName M365DSCTelemetryEngine -Parameters @{ State = $Script:OriginalTelemetryState } -ScriptBlock {
        param ($State)
        $Script:TelemetryEnabled = $State.TelemetryEnabled
        $Script:M365DSCOSInfo = $State.OSInfo
        $Script:M365DSCCurrentPrincipalIsAdmin = $State.CurrentPrincipalIsAdmin
    }
    if ($null -ne $Script:TelemetryModule)
    {
        Remove-Module -ModuleInfo $Script:TelemetryModule -Force -ErrorAction SilentlyContinue
    }
    foreach ($stubName in $Script:DefinedStubs)
    {
        Remove-Item -Path "Function:\global:$stubName" -ErrorAction SilentlyContinue
    }
    Remove-Variable -Name 'M365DSCTelemetryTestEvent' -Scope Global -ErrorAction SilentlyContinue
}

Describe 'Add-M365DSCTelemetryEvent' {
    BeforeAll {
        Mock -ModuleName M365DSCTelemetryEngine -CommandName Get-M365DSCTelemetryConnectionParameter -MockWith {
            return @{ TenantId = 'contoso.onmicrosoft.com' }
        }
        Mock -ModuleName M365DSCTelemetryEngine -CommandName Get-M365DSCApplicationInsightsTelemetryClient -MockWith {
            $client = [PSCustomObject]@{}
            $client | Add-Member -MemberType ScriptMethod -Name TrackEvent -Value {
                param ($Type, $Data, $Metrics)
                $Global:M365DSCTelemetryTestEvent = @{ Type = $Type; Data = $Data }
            }
            return $client
        }

        InModuleScope -ModuleName M365DSCTelemetryEngine -ScriptBlock {
            $Script:M365DSCOSInfo = 'TestOS'
            $Script:M365DSCCurrentPrincipalIsAdmin = $false
        }
    }

    BeforeEach {
        $Global:M365DSCTelemetryTestEvent = $null
    }

    Context 'When telemetry is enabled' {
        BeforeAll {
            InModuleScope -ModuleName M365DSCTelemetryEngine -ScriptBlock { $Script:TelemetryEnabled = $true }
        }

        It 'Should map resource <Resource> to workload <Workload>' -ForEach @(
            @{ Resource = 'MSFT_AADGroup'; Workload = 'Azure Active Directory' }
            @{ Resource = 'MSFT_DefenderSubscriptionPlan'; Workload = 'Defender' }
            @{ Resource = 'MSFT_IntuneDeviceCategory'; Workload = 'Intune' }
            @{ Resource = 'MSFT_EXOAcceptedDomain'; Workload = 'Exchange Online' }
            @{ Resource = 'MSFT_ADOOrganizationOwner'; Workload = 'Azure DevOps' }
            @{ Resource = 'MSFT_SentinelSetting'; Workload = 'Sentinel' }
            @{ Resource = 'MSFT_SHSpaceGroup'; Workload = 'Services Hub' }
            @{ Resource = 'SPOTenantSettings'; Workload = 'SharePoint Online' }
        ) {
            Add-M365DSCTelemetryEvent -Data (New-TelemetryData -Values @{ Resource = $Resource })

            $Global:M365DSCTelemetryTestEvent.Data['Workload'] | Should -Be $Workload
        }

        It 'Should replace the raw TenantId with the Tenant value' {
            Add-M365DSCTelemetryEvent -Data (New-TelemetryData -Values @{
                    Resource          = 'MSFT_AADGroup'
                    TenantId          = 'contoso.onmicrosoft.com'
                    PSBoundParameters = @{ TenantId = 'contoso.onmicrosoft.com' }
                })

            $Global:M365DSCTelemetryTestEvent.Data.ContainsKey('TenantId') | Should -BeFalse
            $Global:M365DSCTelemetryTestEvent.Data.ContainsKey('PSBoundParameters') | Should -BeFalse
            $Global:M365DSCTelemetryTestEvent.Data['Tenant'] | Should -Be 'contoso.onmicrosoft.com'
        }

        It 'Should record Windows Terminal as the PowerShell agent' -Skip:($Host.Name -ne 'ConsoleHost') {
            $originalSession = $env:WT_SESSION
            try
            {
                $env:WT_SESSION = 'test-session'
                Add-M365DSCTelemetryEvent -Data (New-TelemetryData -Values @{ Resource = 'MSFT_AADGroup' })
            }
            finally
            {
                $env:WT_SESSION = $originalSession
            }

            $Global:M365DSCTelemetryTestEvent.Data['PowerShellAgent'] | Should -Be 'Windows Terminal'
        }
    }
}
