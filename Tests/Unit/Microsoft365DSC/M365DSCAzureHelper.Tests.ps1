BeforeAll {
    Import-Module "$PSScriptRoot/../../../Modules/Microsoft365DSC/Modules/M365DSCDllLoader.psm1" -Force -Global
    Initialize-M365DSCDllLoader
    Import-Module "$PSScriptRoot/../../../Modules/Microsoft365DSC/Microsoft365DSC.psd1" -Global

    if (-not (Test-Path -Path 'Function:\Get-MSCloudLoginConnectionProfile'))
    {
        Import-Module -Name "$PSScriptRoot/../Stubs/Generic.psm1" -Function 'Get-MSCloudLoginConnectionProfile' -Global -WarningAction SilentlyContinue
    }
    if (-not (Test-Path -Path 'Function:\Invoke-AzRestMethod'))
    {
        Import-Module -Name "$PSScriptRoot/../Stubs/Microsoft365.psm1" -Function 'Invoke-AzRestMethod' -Global -WarningAction SilentlyContinue
    }
}

Describe 'Azure Billing helpers' {
    BeforeAll {
        Mock -ModuleName M365DSCAzureHelper -CommandName Get-MSCloudLoginConnectionProfile -MockWith {
            return @{ ManagementUrl = 'https://management.azure.com/' }
        }
    }

    Context 'When the request succeeds' {
        BeforeAll {
            Mock -ModuleName M365DSCAzureHelper -CommandName Invoke-AzRestMethod -MockWith {
                return [PSCustomObject]@{ StatusCode = 200; Content = '{"value":[{"name":"account1"}]}' }
            }
        }

        It 'Should return the parsed response' {
            (Get-M365DSCAzureBillingAccount).value[0].name | Should -Be 'account1'
        }

        It 'Should list billing accounts with the includeAll query parameter' {
            $null = Get-M365DSCAzureBillingAccount

            Should -Invoke -ModuleName M365DSCAzureHelper -CommandName Invoke-AzRestMethod -Exactly 1 -ParameterFilter {
                $Method -eq 'GET' -and $Uri -eq 'https://management.azure.com/providers/Microsoft.Billing/billingAccounts?api-version=2024-04-01&includeAll=true'
            }
        }

        It 'Should list all role definitions when no role definition id is given' {
            $null = Get-M365DSCAzureBillingAccountsRoleDefinition -BillingAccountId 'account1'

            Should -Invoke -ModuleName M365DSCAzureHelper -CommandName Invoke-AzRestMethod -Exactly 1 -ParameterFilter {
                $Uri -eq "https://management.azure.com/providers/Microsoft.Billing/billingAccounts/account1/billingRoleDefinitions?api-version=2024-04-01"
            }
        }

        It 'Should get a single role definition when a role definition id is given' {
            $null = Get-M365DSCAzureBillingAccountsRoleDefinition -BillingAccountId 'account1' -RoleDefinitionId 'role1'

            Should -Invoke -ModuleName M365DSCAzureHelper -CommandName Invoke-AzRestMethod -Exactly 1 -ParameterFilter {
                $Uri -eq "https://management.azure.com/providers/Microsoft.Billing/billingAccounts/account1/billingRoleDefinitions/role1?api-version=2024-04-01"
            }
        }

        It 'Should send the body as JSON' {
            $null = New-M365DSCAzureBillingAccountsRoleAssignment -BillingAccountId 'account1' -Body @{ principalId = 'principal1' }

            Should -Invoke -ModuleName M365DSCAzureHelper -CommandName Invoke-AzRestMethod -Exactly 1 -ParameterFilter {
                $Method -eq 'POST' -and ($Payload | ConvertFrom-Json).principalId -eq 'principal1'
            }
        }
    }

    Context 'When the response has no content' {
        BeforeAll {
            Mock -ModuleName M365DSCAzureHelper -CommandName Invoke-AzRestMethod -MockWith {
                return [PSCustomObject]@{ StatusCode = 204; Content = '' }
            }
        }

        It 'Should return nothing' {
            Remove-M365DSCAzureBillingAccountsRoleAssignment -BillingAccountId 'account1' -AssignmentId 'assignment1' |
                Should -BeNullOrEmpty
        }
    }

    Context 'When the response is an HTTP error with an Azure error body' {
        BeforeAll {
            Mock -ModuleName M365DSCAzureHelper -CommandName Invoke-AzRestMethod -MockWith {
                return [PSCustomObject]@{
                    StatusCode = 403
                    Content    = '{"error":{"code":"AuthorizationFailed","message":"No access to the billing account."}}'
                }
            }
        }

        It 'Should throw with the status code and the error message' {
            { Get-M365DSCAzureBillingAccountsAssociatedTenant -BillingAccountId 'account1' } |
                Should -Throw -ExpectedMessage '*(403 Forbidden): AuthorizationFailed No access to the billing account.'
        }

        It 'Should throw an error that is classified as an access error' {
            $errorRecord = $null
            try
            {
                Get-M365DSCAzureBillingAccountsAssociatedTenant -BillingAccountId 'account1'
            }
            catch
            {
                $errorRecord = $_
            }

            Test-M365DSCAccessError -ErrorRecord $errorRecord | Should -BeTrue
            Test-M365DSCTransientError -ErrorRecord $errorRecord | Should -BeFalse
        }
    }

    Context 'When the response is an HTTP error with a plain text body' {
        BeforeAll {
            Mock -ModuleName M365DSCAzureHelper -CommandName Invoke-AzRestMethod -MockWith {
                return [PSCustomObject]@{ StatusCode = 502; Content = 'Bad Gateway' }
            }
        }

        It 'Should throw with the raw content' {
            { Get-M365DSCAzureBillingAccount } | Should -Throw -ExpectedMessage '*(502 BadGateway): Bad Gateway'
        }

        It 'Should keep the bare status code when it has no known name' {
            Mock -ModuleName M365DSCAzureHelper -CommandName Invoke-AzRestMethod -MockWith {
                return [PSCustomObject]@{ StatusCode = 499; Content = 'Unknown' }
            }

            { Get-M365DSCAzureBillingAccount } | Should -Throw -ExpectedMessage '*(499): Unknown'
        }
    }
}
