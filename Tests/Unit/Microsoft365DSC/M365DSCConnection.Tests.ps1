BeforeAll {
    Import-Module "$PSScriptRoot/../../../Modules/Microsoft365DSC/Modules/M365DSCConnection.psm1" -Force
    $Script:UtilModule = $null
    if ($null -eq (Get-Module -Name 'Microsoft365DSC'))
    {
        $Script:UtilModule = Import-Module "$PSScriptRoot/../../../Modules/Microsoft365DSC/Modules/M365DSCUtil.psm1" -DisableNameChecking -PassThru
    }

    function global:Test-IsM365DSCRequiredModulesLoaded
    {
        return $true
    }

    function global:Add-M365DSCTelemetryEvent
    {
        param ($Data, $Type)
    }

    function global:Register-M365DSCPnPIdentityClientResolver
    {
        param ($ModuleBase)
    }

    function global:Connect-M365Tenant
    {
        [CmdletBinding()]
        param ($Workload, $EnableSearchOnlySession, $ApplicationId, $TenantId, $CertificateThumbprint, $ApplicationSecret, $AccessTokens, $Url, $SubscriptionId)
    }

    $Script:SpThumbprint = @{
        ApplicationId         = '11111111-1111-1111-1111-111111111111'
        TenantId              = 'contoso.onmicrosoft.com'
        CertificateThumbprint = 'ABCDEF0123456789'
    }
    $Script:SpSecret = @{
        ApplicationId     = '11111111-1111-1111-1111-111111111111'
        TenantId          = 'contoso.onmicrosoft.com'
        ApplicationSecret = 'secret'
    }
    $Script:AzureError = 'The provided account 11111111-1111-1111-1111-111111111111 does not have access to subscription ID "22222222-2222-2222-2222-222222222222"'
}

Describe 'New-M365DSCConnection' {
    BeforeEach {
        $Global:M365DSCExportInProgress = $true
        Reset-M365DSCConnectionFailureCache
        Mock -ModuleName M365DSCConnection -CommandName Test-IsM365DSCRequiredModulesLoaded -MockWith { $true }
        Mock -ModuleName M365DSCConnection -CommandName Add-M365DSCTelemetryEvent
        Mock -ModuleName M365DSCConnection -CommandName Connect-M365Tenant
        Mock -ModuleName M365DSCConnection -CommandName Register-M365DSCPnPIdentityClientResolver
    }

    AfterAll {
        $Global:M365DSCExportInProgress = $false
        Reset-M365DSCConnectionFailureCache
        Remove-Module -Name M365DSCConnection -Force -ErrorAction SilentlyContinue
        if ($null -ne $Script:UtilModule)
        {
            Remove-Module -ModuleInfo $Script:UtilModule -Force -ErrorAction SilentlyContinue
        }
    }

    Context 'Verbose output' {
        It 'masks the application secret' {
            $parameters = $Script:SpSecret.Clone()
            $parameters.ApplicationSecret = 'plain-secret-value'
            $verboseRecords = New-M365DSCConnection -Workload 'MicrosoftGraph' -InboundParameters $parameters -Verbose 4>&1 |
                Where-Object -FilterScript { $_ -is [System.Management.Automation.VerboseRecord] }
            ($verboseRecords.Message -join "`n") | Should -Not -BeLike '*plain-secret-value*'
            ($verboseRecords.Message -join "`n") | Should -BeLike '*ApplicationSecret*`*`*`**'
        }

        It 'masks access tokens' {
            $parameters = @{
                TenantId     = 'contoso.onmicrosoft.com'
                AccessTokens = @('plain-token-value')
            }
            $verboseRecords = New-M365DSCConnection -Workload 'MicrosoftGraph' -InboundParameters $parameters -Verbose 4>&1 |
                Where-Object -FilterScript { $_ -is [System.Management.Automation.VerboseRecord] }
            ($verboseRecords.Message -join "`n") | Should -Not -BeLike '*plain-token-value*'
        }
    }

    Context 'Successful connections' {
        It 'returns the connection mode for MicrosoftGraph' {
            New-M365DSCConnection -Workload 'MicrosoftGraph' -InboundParameters $Script:SpThumbprint.Clone() | Should -Be 'ServicePrincipalWithThumbprint'
            Should -Invoke -ModuleName M365DSCConnection -CommandName Connect-M365Tenant -Exactly -Times 1
        }

        It 'returns the connection mode for Azure' {
            New-M365DSCConnection -Workload 'Azure' -InboundParameters $Script:SpThumbprint.Clone() | Should -Be 'ServicePrincipalWithThumbprint'
        }
    }

    Context 'Connect-M365Tenant throws' {
        BeforeEach {
            Mock -ModuleName M365DSCConnection -CommandName Connect-M365Tenant -MockWith { throw $Script:AzureError } -ParameterFilter { $Workload -eq 'Azure' }
        }

        It 'rethrows the original message' {
            { New-M365DSCConnection -Workload 'Azure' -InboundParameters $Script:SpThumbprint.Clone() } |
                Should -Throw -ExpectedMessage '*does not have access to subscription ID*'
        }

        It 'short-circuits the second attempt without calling Connect-M365Tenant' {
            { New-M365DSCConnection -Workload 'Azure' -InboundParameters $Script:SpThumbprint.Clone() } | Should -Throw
            { New-M365DSCConnection -Workload 'Azure' -InboundParameters $Script:SpThumbprint.Clone() } |
                Should -Throw -ExpectedMessage '*failed earlier in this session: The provided account*'
            Should -Invoke -ModuleName M365DSCConnection -CommandName Connect-M365Tenant -Exactly -Times 1
        }

        It 'keys the failure per workload and connection mode' {
            { New-M365DSCConnection -Workload 'Azure' -InboundParameters $Script:SpThumbprint.Clone() } | Should -Throw
            New-M365DSCConnection -Workload 'MicrosoftGraph' -InboundParameters $Script:SpThumbprint.Clone() | Should -Be 'ServicePrincipalWithThumbprint'
            { New-M365DSCConnection -Workload 'Azure' -InboundParameters $Script:SpSecret.Clone() } |
                Should -Throw -ExpectedMessage '*does not have access to subscription ID*'
            Should -Invoke -ModuleName M365DSCConnection -CommandName Connect-M365Tenant -Exactly -Times 3
        }

        It 'attempts again after Reset-M365DSCConnectionFailureCache' {
            { New-M365DSCConnection -Workload 'Azure' -InboundParameters $Script:SpThumbprint.Clone() } | Should -Throw
            Reset-M365DSCConnectionFailureCache
            { New-M365DSCConnection -Workload 'Azure' -InboundParameters $Script:SpThumbprint.Clone() } |
                Should -Throw -ExpectedMessage '*does not have access to subscription ID*'
            Should -Invoke -ModuleName M365DSCConnection -CommandName Connect-M365Tenant -Exactly -Times 2
        }

        It 'does not memoize outside of an export' {
            $Global:M365DSCExportInProgress = $false
            { New-M365DSCConnection -Workload 'Azure' -InboundParameters $Script:SpThumbprint.Clone() } | Should -Throw
            { New-M365DSCConnection -Workload 'Azure' -InboundParameters $Script:SpThumbprint.Clone() } |
                Should -Throw -ExpectedMessage '*does not have access to subscription ID*'
            Should -Invoke -ModuleName M365DSCConnection -CommandName Connect-M365Tenant -Exactly -Times 2
        }

        It 'memoizes any workload' {
            Mock -ModuleName M365DSCConnection -CommandName Connect-M365Tenant -MockWith { throw 'AADSTS700016' } -ParameterFilter { $Workload -eq 'ExchangeOnline' }
            { New-M365DSCConnection -Workload 'ExchangeOnline' -InboundParameters $Script:SpThumbprint.Clone() } | Should -Throw -ExpectedMessage '*AADSTS700016*'
            { New-M365DSCConnection -Workload 'ExchangeOnline' -InboundParameters $Script:SpThumbprint.Clone() } |
                Should -Throw -ExpectedMessage '*failed earlier in this session: AADSTS700016*'
            Should -Invoke -ModuleName M365DSCConnection -CommandName Connect-M365Tenant -Exactly -Times 1
        }
    }
}
