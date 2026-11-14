BeforeAll {
    Import-Module "$PSScriptRoot/../../../Modules/Microsoft365DSC/Modules/M365DSCDllLoader.psm1" -Force -Global
    Initialize-M365DSCDllLoader
    Import-Module "$PSScriptRoot/../../../Modules/Microsoft365DSC/Microsoft365DSC.psd1" -Global

    if (-not (Test-Path -Path 'Function:\Invoke-MgGraphRequest'))
    {
        Import-Module -Name "$PSScriptRoot/../Stubs/Microsoft365.psm1" -Function 'Invoke-MgGraphRequest' -Global -WarningAction SilentlyContinue
    }
    if (-not (Test-Path -Path 'Function:\Get-MSCloudLoginConnectionProfile'))
    {
        Import-Module -Name "$PSScriptRoot/../Stubs/Generic.psm1" -Function 'Get-MSCloudLoginConnectionProfile' -Global -WarningAction SilentlyContinue
    }

    $Script:TestCredential = [System.Management.Automation.PSCredential]::new(
        'admin@contoso.com',
        (ConvertTo-SecureString -String 'Pass@word1' -AsPlainText -Force)
    )
}

Describe 'M365DSCTenantInfo' {
    BeforeEach {
        Mock -ModuleName M365DSCTenantInfo -CommandName New-M365DSCConnection -MockWith { 'Credentials' }
        Mock -ModuleName M365DSCTenantInfo -CommandName New-M365DSCLogEntry
        Mock -ModuleName M365DSCTenantInfo -CommandName Get-MSCloudLoginConnectionProfile -MockWith {
            @{ EnvironmentName = 'AzureCloud' }
        }
        Mock -ModuleName M365DSCTenantInfo -CommandName Invoke-MgGraphRequest -ParameterFilter { $Uri -eq 'beta/domains' } -MockWith {
            @{
                '@odata.context' = 'https://graph.microsoft.com/beta/$metadata#domains'
                value            = @(
                    @{ id = 'contoso.com'; isInitial = $false; isDefault = $true }
                    @{ id = 'contoso.mail.onmicrosoft.com'; isInitial = $false; isDefault = $false }
                    @{ id = 'contoso.onmicrosoft.com'; isInitial = $true; isDefault = $false }
                )
            }
        }
    }

    Context 'Get-M365TenantName' {
        It 'returns the prefix of the initial onmicrosoft or onsovcloud domain from the Graph response' {
            Get-M365TenantName -Credential $Script:TestCredential | Should -Be 'contoso'

            Mock -ModuleName M365DSCTenantInfo -CommandName Invoke-MgGraphRequest -ParameterFilter { $Uri -eq 'beta/domains' } -MockWith {
                @{ value = @(@{ id = 'fabrikam.onmicrosoft.us'; isInitial = $true }) }
            }
            Get-M365TenantName -Credential $Script:TestCredential | Should -Be 'fabrikam'

            Mock -ModuleName M365DSCTenantInfo -CommandName Invoke-MgGraphRequest -ParameterFilter { $Uri -eq 'beta/domains' } -MockWith {
                @{ value = @(@{ id = 'tailspin.onsovcloud.de'; isInitial = $true }) }
            }
            Get-M365TenantName -Credential $Script:TestCredential | Should -Be 'tailspin'

            Mock -ModuleName M365DSCTenantInfo -CommandName Invoke-MgGraphRequest -ParameterFilter { $Uri -eq 'beta/domains' } -MockWith {
                @{ value = @(@{ id = 'wingtip.partner.onmschina.cn'; isInitial = $true }) }
            }
            Get-M365TenantName -Credential $Script:TestCredential | Should -Be 'wingtip'
        }

        It 'throws a clear error when no initial domain exists' {
            Mock -ModuleName M365DSCTenantInfo -CommandName Invoke-MgGraphRequest -ParameterFilter { $Uri -eq 'beta/domains' } -MockWith {
                @{ value = @(@{ id = 'contoso.com'; isInitial = $true }) }
            }
            { Get-M365TenantName -Credential $Script:TestCredential } | Should -Throw -ExpectedMessage '*initial onmicrosoft domain*'
        }
    }

    Context 'Get-SPOAdministrationUrl' {
        It 'returns the admin URL without setting global variables' {
            $global:AdminUrl = 'https://stale-admin.sharepoint.com'
            try
            {
                Get-SPOAdministrationUrl -Credential $Script:TestCredential | Should -Be 'https://contoso-admin.sharepoint.com'
                $global:AdminUrl | Should -Be 'https://stale-admin.sharepoint.com'
            }
            finally
            {
                Remove-Variable -Name AdminUrl -Scope Global -ErrorAction SilentlyContinue
            }
        }
    }

    Context 'Get-M365DSCAPIEndpoint' {
        BeforeEach {
            Mock -ModuleName M365DSCTenantInfo -CommandName Invoke-RestMethod
        }

        It 'returns <Expected> for the Azure management URL <ManagementUrl>' -ForEach @(
            @{ ManagementUrl = 'https://management.azure.com/'; Expected = 'https://management.azure.com' }
            @{ ManagementUrl = 'https://management.usgovcloudapi.net/'; Expected = 'https://management.usgovcloudapi.net' }
            @{ ManagementUrl = 'https://management.chinacloudapi.cn/'; Expected = 'https://management.chinacloudapi.cn' }
            @{ ManagementUrl = 'https://management.azure.com'; Expected = 'https://management.azure.com' }
        ) {
            Mock -ModuleName M365DSCTenantInfo -CommandName Get-MSCloudLoginConnectionProfile -ParameterFilter { $Workload -eq 'Azure' } -MockWith {
                @{ ManagementUrl = $ManagementUrl }
            }.GetNewClosure()

            (Get-M365DSCAPIEndpoint -TenantId 'contoso.onmicrosoft.com').AzureManagement | Should -Be $Expected
            Should -Invoke -ModuleName M365DSCTenantInfo -CommandName Invoke-RestMethod -Exactly -Times 0
        }

        It 'throws when the Azure connection profile has no management URL' {
            Mock -ModuleName M365DSCTenantInfo -CommandName Get-MSCloudLoginConnectionProfile -ParameterFilter { $Workload -eq 'Azure' } -MockWith {
                @{ ManagementUrl = $null }
            }

            { Get-M365DSCAPIEndpoint -TenantId 'contoso.onmicrosoft.com' } | Should -Throw -ExpectedMessage '*Connect to the Azure workload first*'
        }
    }

    Context 'Get-M365DSCTenantDomain' {
        It 'logs the missing permission when Graph answers with an HTTP 403 error' {
            Mock -ModuleName M365DSCTenantInfo -CommandName Invoke-MgGraphRequest -ParameterFilter { $Uri -eq '/beta/organization' } -MockWith {
                $exception = [System.Exception]::new('Response status code does not indicate success: Forbidden (Forbidden).')
                $record = [System.Management.Automation.ErrorRecord]::new($exception, 'Forbidden', 'PermissionDenied', $null)
                $record.ErrorDetails = '{"error":{"code":"Authorization_RequestDenied","message":"Insufficient privileges to complete the operation."}}'
                throw $record
            }

            { Get-M365DSCTenantDomain -TenantId 'contoso.onmicrosoft.com' -ManagedIdentity } |
                Should -Throw -ExpectedMessage '*Missing Organization.Read.All permission*'
            Should -Invoke -ModuleName M365DSCTenantInfo -CommandName New-M365DSCLogEntry -Exactly -Times 1 -ParameterFilter {
                $Message -like '*Organization.Read.All*' -and $null -eq $Credential
            }
        }

        It 'rethrows other errors unchanged' {
            Mock -ModuleName M365DSCTenantInfo -CommandName Invoke-MgGraphRequest -ParameterFilter { $Uri -eq '/beta/organization' } -MockWith {
                throw 'Response status code does not indicate success: ServiceUnavailable'
            }

            { Get-M365DSCTenantDomain -TenantId 'contoso.onmicrosoft.com' -ManagedIdentity } |
                Should -Throw -ExpectedMessage '*ServiceUnavailable*'
            Should -Invoke -ModuleName M365DSCTenantInfo -CommandName New-M365DSCLogEntry -Exactly -Times 0
        }
    }
}
