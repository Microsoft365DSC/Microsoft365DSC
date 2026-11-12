BeforeAll {
    Import-Module "$PSScriptRoot/../../../Modules/Microsoft365DSC/Modules/M365DSCDllLoader.psm1" -Force -Global
    Initialize-M365DSCDllLoader
    Import-Module "$PSScriptRoot/../../../Modules/Microsoft365DSC/Microsoft365DSC.psd1" -Global

    if (-not (Test-Path -Path 'Function:\Get-MSCloudLoginConnectionProfile'))
    {
        Import-Module -Name "$PSScriptRoot/../Stubs/Generic.psm1" -Function 'Get-MSCloudLoginConnectionProfile' -Global -WarningAction SilentlyContinue
    }
}

Describe 'Invoke-M365DSCServicesHubWebRequest' {
    BeforeAll {
        Mock -ModuleName M365DSCServicesHubHelper -CommandName Get-MSCloudLoginConnectionProfile -MockWith {
            return @{ AccessToken = 'Bearer token' }
        }
    }

    Context 'When the service returns an HTTP error' {
        BeforeAll {
            Mock -ModuleName M365DSCServicesHubHelper -CommandName Invoke-WebRequest -MockWith {
                $record = [System.Management.Automation.ErrorRecord]::new(
                    [System.Exception]::new('Response status code does not indicate success: 400 (Bad Request).'),
                    'WebCmdletWebResponseException',
                    [System.Management.Automation.ErrorCategory]::InvalidOperation,
                    $null)
                $record.ErrorDetails = [System.Management.Automation.ErrorDetails]::new('{"message":"Invalid space"}')
                throw $record
            }
        }

        It 'Should throw the status and the response body' {
            { Invoke-M365DSCServicesHubWebRequest -Uri 'https://example.com/api' } |
                Should -Throw -ExpectedMessage '*400 (Bad Request).*{"message":"Invalid space"}'
        }
    }

    Context 'When the request fails without a response' {
        BeforeAll {
            Mock -ModuleName M365DSCServicesHubHelper -CommandName Invoke-WebRequest -MockWith {
                throw [System.Net.Http.HttpRequestException]::new('No such host is known.')
            }
        }

        It 'Should rethrow the original error' {
            { Invoke-M365DSCServicesHubWebRequest -Uri 'https://example.com/api' } |
                Should -Throw -ExpectedMessage 'No such host is known.'
        }
    }

    Context 'When the request succeeds' {
        BeforeAll {
            Mock -ModuleName M365DSCServicesHubHelper -CommandName Invoke-WebRequest -MockWith {
                return [PSCustomObject]@{ Content = '{"id":"space1"}' }
            }
        }

        It 'Should return the parsed content' {
            (Invoke-M365DSCServicesHubWebRequest -Uri 'https://example.com/api').id | Should -Be 'space1'
        }
    }
}
