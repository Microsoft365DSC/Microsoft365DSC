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
    -DscResource 'AADNetworkAccessForwardingProfile' -GenericStubModule $GenericStubPath
Describe -Name $Global:DscHelper.DescribeHeader -Fixture {
    InModuleScope -ModuleName $Global:DscHelper.ModuleName -ScriptBlock {
        Invoke-Command -ScriptBlock $Global:DscHelper.InitializeScript -NoNewScope
        BeforeAll {

            $secpasswd = ConvertTo-SecureString (New-Guid | Out-String) -AsPlainText -Force
            $Credential = New-Object System.Management.Automation.PSCredential ('tenantadmin@onmicrosoft.com', $secpasswd)

            Mock -ModuleName M365DSCUtil -CommandName Confirm-M365DSCDependencies -MockWith {
            }

            Mock -CommandName Get-PSSession -MockWith {
            }

            Mock -CommandName Remove-PSSession -MockWith {
            }

            Mock -CommandName Update-MgBetaNetworkAccessForwardingProfile -MockWith {
            }

            Mock -CommandName Get-MgBetaNetworkAccessForwardingProfile -MockWith {
                return @{
                    Name  = 'Microsoft 365 traffic forwarding profile'
                    Id    = '58847306-0ae2-4f65-91ee-d6587e9bebda'
                    State = 'enabled'
                }
            }

            Mock -CommandName Get-MgBetaNetworkAccessForwardingProfilePolicy -MockWith {
                return @(
                    @{
                        Policy = @{
                            Name = 'Custom Bypass'
                        }
                        Id = '58847306-0ae2-4f65-91ee-d6587e9bebda'
                        State        = 'enabled'
                    },
                    @{
                        Policy = @{
                            Name = 'Default Bypass'
                        }
                        Id = '12345678-1234-1234-1234-123456789012'
                        State        = 'enabled'
                    }
                )
            }

            Mock -CommandName Update-MgBetaNetworkAccessForwardingProfilePolicy -MockWith {
            }

            Mock -CommandName New-M365DSCConnection -ModuleName '_Shared' -MockWith {
                return 'Credentials'
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstances = $null
            $Script:ExportMode = $false
        }
        # Test contexts
        Context -Name 'The AADNetworkAccessForwardingProfile Exists and Values are already in the desired state' -Fixture {
            BeforeAll {
                $testParams = @{
                    Name       = 'Microsoft 365 traffic forwarding profile'
                    Id         = '58847306-0ae2-4f65-91ee-d6587e9bebda'
                    State      = 'enabled'
                    Policies   = @(
                        [MSFT_MicrosoftGraphNetworkaccessPolicyLink] @{
                            Name         = 'Custom Bypass'
                            PolicyLinkId = '58847306-0ae2-4f65-91ee-d6587e9bebda'
                            State        = 'enabled'
                        }
                        [MSFT_MicrosoftGraphNetworkaccessPolicyLink] @{
                            Name         = 'Default Bypass'
                            PolicyLinkId = '12345678-1234-1234-1234-123456789012'
                            State        = 'enabled'
                        }
                    )
                    Credential = $Credential

                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADNetworkAccessForwardingProfile' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name 'The AADNetworkAccessForwardingProfile exists and values are NOT in the desired state' -Fixture {
            BeforeAll {
                $testParams = @{
                    Name       = 'Microsoft 365 traffic forwarding profile'
                    Id         = '58847306-0ae2-4f65-91ee-d6587e9bebda'
                    State      = 'disabled'
                    Policies   = @(
                        [MSFT_MicrosoftGraphNetworkaccessPolicyLink] @{
                            Name         = 'Custom Bypass'
                            PolicyLinkId = '58847306-0ae2-4f65-91ee-d6587e9bebda'
                            State        = 'enabled'
                        }
                        [MSFT_MicrosoftGraphNetworkaccessPolicyLink] @{
                            Name         = 'Default Bypass'
                            PolicyLinkId = '12345678-1234-1234-1234-123456789012'
                            State        = 'disabled'
                        }
                    )
                    Credential = $Credential
                }
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADNetworkAccessForwardingProfile' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set Update-MgBetaNetworkAccessForwardingProfile method' {
                (New-M365DSCResourceInstance -ResourceName 'AADNetworkAccessForwardingProfile' -Property $testParams).Set()
                Should -Invoke -CommandName Update-MgBetaNetworkAccessForwardingProfile -Exactly 1
            }

            It 'Should call the Set Update-MgBetaNetworkAccessForwardingProfilePolicy method' {
                (New-M365DSCResourceInstance -ResourceName 'AADNetworkAccessForwardingProfile' -Property $testParams).Set()
                Should -Invoke -CommandName Update-MgBetaNetworkAccessForwardingProfilePolicy -Exactly 2
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
                $result = Invoke-M365DSCResourceMethod -ResourceName 'AADNetworkAccessForwardingProfile' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
