[CmdletBinding()]
param(
)
$M365DSCTestFolder = Join-Path -Path $PSScriptRoot `
    -ChildPath '..\..\Unit' `
    -Resolve
$CmdletModule = (Join-Path -Path $M365DSCTestFolder `
        -ChildPath '\Stubs\Microsoft365.psm1' `
        -Resolve)
$GenericStubPath = (Join-Path -Path $M365DSCTestFolder `
        -ChildPath '\Stubs\Generic.psm1' `
        -Resolve)
Import-Module -Name (Join-Path -Path $M365DSCTestFolder `
        -ChildPath '\UnitTestHelper.psm1' `
        -Resolve)

$Global:DscHelper = New-M365DscUnitTestHelper -StubModule $CmdletModule `
    -DscResource 'AADGroup' -GenericStubModule $GenericStubPath

Describe -Name 'Invoke-M365DSCGraphRequest' -Fixture {
    InModuleScope -ModuleName 'M365DSCUtil' -ScriptBlock {

        Context -Name 'URI normalization' -Fixture {
            It 'Should strip the host from an absolute URL and keep the beta segment' {
                ConvertTo-M365DSCGraphRelativeUri -Uri 'https://graph.microsoft.com/beta/identityProtection/policy' |
                    Should -Be '/beta/identityProtection/policy'
            }

            It 'Should leave an already relative URI untouched' {
                ConvertTo-M365DSCGraphRelativeUri -Uri '/beta/directory/federationConfigurations' |
                    Should -Be '/beta/directory/federationConfigurations'
            }

            It 'Should add the leading slash to a bare relative path' {
                ConvertTo-M365DSCGraphRelativeUri -Uri 'beta/privilegedAccess/aadGroups/resources' |
                    Should -Be '/beta/privilegedAccess/aadGroups/resources'
            }

            It 'Should preserve the query string' {
                ConvertTo-M365DSCGraphRelativeUri -Uri "https://graph.microsoft.com/beta/groups?`$select=id" |
                    Should -Be '/beta/groups?$select=id'
            }

            It 'Should keep a v1.0 segment' {
                ConvertTo-M365DSCGraphRelativeUri -Uri 'https://graph.microsoft.com/v1.0/organization' |
                    Should -Be '/v1.0/organization'
            }
        }

        Context -Name 'Graph SDK dispatch path' -Fixture {
            BeforeAll {
                Mock -CommandName Get-M365DSCMgxRequestCommand -MockWith { return $null }
            }

            It 'Should normalize an absolute URI before calling the SDK' {
                Mock -CommandName Invoke-MgGraphRequest -MockWith { return @{ value = @() } }

                $null = Invoke-M365DSCGraphRequest -Method 'GET' -Uri 'https://graph.microsoft.com/beta/identityProtection/policy'

                Should -Invoke -CommandName Invoke-MgGraphRequest -Exactly 1 -ParameterFilter {
                    $Uri -eq '/beta/identityProtection/policy'
                }
            }

            It 'Should pass ContentType through to the SDK' {
                Mock -CommandName Invoke-MgGraphRequest -MockWith { return $null }

                $null = Invoke-M365DSCGraphRequest -Method 'PUT' -Uri '/beta/applications/1/logo' `
                    -Body ([System.Byte[]] @(1, 2, 3)) -ContentType 'image/*'

                Should -Invoke -CommandName Invoke-MgGraphRequest -Exactly 1 -ParameterFilter {
                    $ContentType -eq 'image/*'
                }
            }

            It 'Should follow @odata.nextLink and merge every page when -All is used' {
                Mock -CommandName Invoke-MgGraphRequest -MockWith {
                    if ($Uri -like '*skiptoken*')
                    {
                        return @{ value = @(@{ id = 'three' }) }
                    }

                    return @{
                        '@odata.context'  = 'ctx'
                        '@odata.nextLink' = 'https://graph.microsoft.com/beta/groups?$skiptoken=abc'
                        value             = @(@{ id = 'one' }, @{ id = 'two' })
                    }
                }

                $result = Invoke-M365DSCGraphRequest -Method 'GET' -Uri '/beta/groups' -All

                Should -Invoke -CommandName Invoke-MgGraphRequest -Exactly 2
                $result.value.Count | Should -Be 3
                $result.value[2].id | Should -Be 'three'
                $result.'@odata.context' | Should -Be 'ctx'
                $result.ContainsKey('@odata.nextLink') | Should -Be $false
            }

            It 'Should return the raw response when -All is not used' {
                Mock -CommandName Invoke-MgGraphRequest -MockWith {
                    return @{
                        '@odata.nextLink' = 'https://graph.microsoft.com/beta/groups?$skiptoken=abc'
                        value             = @(@{ id = 'one' })
                    }
                }

                $result = Invoke-M365DSCGraphRequest -Method 'GET' -Uri '/beta/groups'

                Should -Invoke -CommandName Invoke-MgGraphRequest -Exactly 1
                $result.value.Count | Should -Be 1
            }
        }

        Context -Name 'Mgx dispatch path' -Fixture {
            BeforeAll {
                function Invoke-MgxRequestStub
                {
                    [CmdletBinding()]
                    param
                    (
                        [Parameter()] [System.String] $Method,
                        [Parameter()] [System.String] $Uri,
                        [Parameter()] [System.String] $ApiVersion,
                        [Parameter()] [System.Object] $Body,
                        [Parameter()] [System.Collections.IDictionary] $Headers
                    )

                    $Script:LastMgxCall = @{
                        Method     = $Method
                        Uri        = $Uri
                        ApiVersion = $ApiVersion
                        Body       = $Body
                    }

                    return @{ value = @() }
                }

                Mock -CommandName Get-M365DSCMgxRequestCommand -MockWith {
                    return (Get-Command -Name 'Invoke-MgxRequestStub')
                }
            }

            It 'Should split the beta segment into ApiVersion and strip it from the URI' {
                $null = Invoke-M365DSCGraphRequest -Method 'GET' -Uri 'https://graph.microsoft.com/beta/identityProtection/policy'

                $Script:LastMgxCall.ApiVersion | Should -Be 'beta'
                $Script:LastMgxCall.Uri | Should -Be '/identityProtection/policy'
            }

            It 'Should resolve v1.0 for a v1.0 route' {
                $null = Invoke-M365DSCGraphRequest -Method 'GET' -Uri '/v1.0/organization'

                $Script:LastMgxCall.ApiVersion | Should -Be 'v1.0'
                $Script:LastMgxCall.Uri | Should -Be '/organization'
            }

            It 'Should serialize a hashtable body to JSON' {
                $null = Invoke-M365DSCGraphRequest -Method 'PATCH' -Uri '/beta/identityProtection/policy' `
                    -Body @{ isEnabled = $true }

                $Script:LastMgxCall.Body | Should -Match '"isEnabled"'
            }

            It 'Should leave a string body untouched' {
                $null = Invoke-M365DSCGraphRequest -Method 'PATCH' -Uri '/beta/identityProtection/policy' `
                    -Body '{"isEnabled":true}'

                $Script:LastMgxCall.Body | Should -Be '{"isEnabled":true}'
            }

            It 'Should fall back to the SDK when ContentType is supplied' {
                Mock -CommandName Invoke-MgGraphRequest -MockWith { return $null }

                $null = Invoke-M365DSCGraphRequest -Method 'PUT' -Uri '/beta/applications/1/logo' -ContentType 'image/*'

                Should -Invoke -CommandName Invoke-MgGraphRequest -Exactly 1
            }
        }
    }
}
