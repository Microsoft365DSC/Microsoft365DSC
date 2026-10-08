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
    -DscResource "AADAuthenticationMethodPolicyExternal" -GenericStubModule $GenericStubPath
Describe -Name $Global:DscHelper.DescribeHeader -Fixture {
    InModuleScope -ModuleName $Global:DscHelper.ModuleName -ScriptBlock {
        Invoke-Command -ScriptBlock $Global:DscHelper.InitializeScript -NoNewScope
        BeforeAll {

            $secpasswd = ConvertTo-SecureString (New-Guid | Out-String) -AsPlainText -Force
            $Credential = New-Object System.Management.Automation.PSCredential ('tenantadmin@onmicrosoft.com', $secpasswd)

            Mock -ModuleName M365DSCUtil -CommandName Confirm-M365DSCDependencies -MockWith {
            }

            Mock -CommandName Get-MSCloudLoginConnectionProfile -MockWith {
            }

            Mock -CommandName New-MgBetaPolicyAuthenticationMethodPolicyAuthenticationMethodConfiguration -MockWith {
            }

            Mock -CommandName Update-MgBetaPolicyAuthenticationMethodPolicyAuthenticationMethodConfiguration -MockWith {
            }

            Mock -CommandName Remove-MgBetaPolicyAuthenticationMethodPolicyAuthenticationMethodConfiguration -MockWith {
            }

            $scriptBlock = {
                return @{
                    authenticationMethodConfigurations = @{
                        IncludeTargets = @(
                            @{
                                TargetType = 'group'
                                Id         = 'Fakegroup'
                            }
                        )
                        ExcludeTargets = @(
                            @{
                                TargetType = "group"
                                Id = "00000000-0000-0000-0000-000000000000"
                            }
                        )
                        OpenIdConnectSetting  = @{
                            discoveryUrl = 'https://graph.microsoft.com/'
                            clientId = '00000000-0000-0000-0000-000000000001'
                        }
                        DisplayName = "ExternalOath"
                        AppId  = "00000000-0000-0000-0000-000000000002"
                        State = "enabled"
                        '@odata.type' = "#microsoft.graph.externalAuthenticationMethodConfiguration"
                    }
                }
            }

            Mock -CommandName Invoke-M365DSCGraphRequest -MockWith $scriptBlock
            Mock -CommandName Get-MgBetaPolicyAuthenticationMethodPolicy -MockWith $scriptBlock

            Mock -CommandName Get-MgGroup -ModuleName M365DSCUtil -MockWith {
                return @{
                    Id = "00000000-0000-0000-0000-000000000000"
                    DisplayName = "Fakegroup"
                }
            }

            Mock -CommandName New-M365DSCConnection -ModuleName '_Shared' -MockWith {
                return "Credentials"
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstances =$null
            $Script:ExportMode = $false
        }
        # Test contexts
        Context -Name "The AADAuthenticationMethodPolicyExternal should exist but it DOES NOT" -Fixture {
            BeforeAll {
                $testParams = @{
                    ExcludeTargets = @(
                        ([MSFT_AADAuthenticationMethodPolicyExternalExcludeTarget] @{
                            TargetType = "group"
                            Id = "Fakegroup"
                        })
                    )
                    IncludeTargets        = @(
                        ([MSFT_AADAuthenticationMethodPolicyExternalIncludeTarget] @{
                            TargetType = 'group'
                            Id         = 'Fakegroup'
                        })
                    )
                    OpenIdConnectSetting  = ([MSFT_AADAuthenticationMethodPolicyExternalOpenIdConnectSetting] @{
                        discoveryUrl = 'https://graph.microsoft.com/'
                        clientId = '00000000-0000-0000-0000-000000000001'
                    });
                    DisplayName = "ExternalOath"
                    State  = "enabled"
                    Ensure = "Present"
                    AppId  = "00000000-0000-0000-0000-000000000002"
                    Credential = $Credential;
                }

                Mock -CommandName Invoke-M365DSCGraphRequest -MockWith {
                    return $null
                }

                Mock -CommandName Get-MgBetaPolicyAuthenticationMethodPolicy -MockWith {
                    return $null
                }
            }
            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'AADAuthenticationMethodPolicyExternal' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }
            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADAuthenticationMethodPolicyExternal' -Property $testParams).Test() | Should -Be $false
            }
            It 'Should Create the group from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'AADAuthenticationMethodPolicyExternal' -Property $testParams).Set()
                Should -Invoke -CommandName New-MgBetaPolicyAuthenticationMethodPolicyAuthenticationMethodConfiguration -Exactly 1
            }
        }

        Context -Name "The AADAuthenticationMethodPolicyExternal exists but it SHOULD NOT" -Fixture {
            BeforeAll {
                $testParams = @{
                    ExcludeTargets = @(
                        ([MSFT_AADAuthenticationMethodPolicyExternalExcludeTarget] @{
                            TargetType = "group"
                            Id = "Fakegroup"
                        })
                    )
                    IncludeTargets        = @(
                        ([MSFT_AADAuthenticationMethodPolicyExternalIncludeTarget] @{
                            TargetType = 'group'
                            Id         = 'Fakegroup'
                        })
                    )
                    OpenIdConnectSetting  = ([MSFT_AADAuthenticationMethodPolicyExternalOpenIdConnectSetting] @{
                        discoveryUrl = 'https://graph.microsoft.com/'
                        clientId = '00000000-0000-0000-0000-000000000001'
                    });
                    DisplayName = "ExternalOath"
                    State  = "enabled"
                    Ensure = "Absent"
                    AppId  = "00000000-0000-0000-0000-000000000002"
                    Credential = $Credential;
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'AADAuthenticationMethodPolicyExternal' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADAuthenticationMethodPolicyExternal' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should Remove the group from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'AADAuthenticationMethodPolicyExternal' -Property $testParams).Set()
                Should -Invoke -CommandName Remove-MgBetaPolicyAuthenticationMethodPolicyAuthenticationMethodConfiguration -Exactly 1
            }
        }
        Context -Name "The AADAuthenticationMethodPolicyExternal Exists and Values are already in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    ExcludeTargets = @(
                        ([MSFT_AADAuthenticationMethodPolicyExternalExcludeTarget] @{
                            TargetType = "group"
                            Id = "Fakegroup"
                        })
                    )
                    IncludeTargets        = @(
                        ([MSFT_AADAuthenticationMethodPolicyExternalIncludeTarget] @{
                            TargetType = 'group'
                            Id         = 'Fakegroup'
                        })
                    )
                    OpenIdConnectSetting  = ([MSFT_AADAuthenticationMethodPolicyExternalOpenIdConnectSetting] @{
                        discoveryUrl = 'https://graph.microsoft.com/'
                        clientId = '00000000-0000-0000-0000-000000000001'
                    });
                    DisplayName = "ExternalOath"
                    State  = "enabled"
                    Ensure = "Present"
                    AppId  = "00000000-0000-0000-0000-000000000002"
                    Credential = $Credential;
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADAuthenticationMethodPolicyExternal' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name "The AADAuthenticationMethodPolicyExternal exists and values are NOT in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    ExcludeTargets = @(
                        ([MSFT_AADAuthenticationMethodPolicyExternalExcludeTarget] @{
                            TargetType = "group"
                            Id = "Fakegroup"
                        })
                    )
                    IncludeTargets        = @(
                        ([MSFT_AADAuthenticationMethodPolicyExternalIncludeTarget] @{
                            TargetType = 'group'
                            Id         = 'Fakegroup'
                        })
                    )
                    OpenIdConnectSetting  = ([MSFT_AADAuthenticationMethodPolicyExternalOpenIdConnectSetting] @{
                        discoveryUrl = 'https://microsoft.com/' # Drift
                        clientId = '00000000-0000-0000-0000-000000000001'
                    });
                    DisplayName = "ExternalOath"
                    State  = "enabled"
                    Ensure = "Present"
                    AppId  = "00000000-0000-0000-0000-000000000003"
                    Credential = $Credential;
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'AADAuthenticationMethodPolicyExternal' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADAuthenticationMethodPolicyExternal' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'AADAuthenticationMethodPolicyExternal' -Property $testParams).Set()
                Should -Invoke -CommandName Update-MgBetaPolicyAuthenticationMethodPolicyAuthenticationMethodConfiguration -Exactly 1
            }
        }

        Context -Name 'ReverseDSC Tests' -Fixture {
            BeforeAll {
                $Global:CurrentModeIsExport = $true
                $Global:PartialExportFileName = "$(New-Guid).partial.ps1"
                $testParams = @{
                    Credential = $Credential
                }
            }
            It 'Should Reverse Engineer resource from the Export method' {
                $result = Invoke-M365DSCResourceMethod -ResourceName 'AADAuthenticationMethodPolicyExternal' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
