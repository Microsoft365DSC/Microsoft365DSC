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
    -DscResource 'AADGSAWebContentFilteringPolicy' -GenericStubModule $GenericStubPath
Describe -Name $Global:DscHelper.DescribeHeader -Fixture {
    InModuleScope -ModuleName $Global:DscHelper.ModuleName -ScriptBlock {
        Invoke-Command -ScriptBlock $Global:DscHelper.InitializeScript -NoNewScope
        BeforeAll {
            $secpasswd = ConvertTo-SecureString (New-Guid | Out-String) -AsPlainText -Force
            $Credential = New-Object System.Management.Automation.PSCredential ('tenantadmin@mydomain.com', $secpasswd)

            Mock -ModuleName M365DSCUtil -CommandName Confirm-M365DSCDependencies -MockWith {
            }

            Mock -CommandName New-M365DSCConnection -ModuleName '_Shared' -MockWith {
                return 'Credentials'
            }

            Mock -CommandName Add-M365DSCTelemetryEvent -ModuleName '_Shared' -MockWith {
            }

            Mock -CommandName New-MgBetaNetworkAccessWebFilteringPolicy -MockWith { return @{ Id = 'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee' } }
            Mock -CommandName Update-MgBetaNetworkAccessWebFilteringPolicy -MockWith {}
            Mock -CommandName Remove-MgBetaNetworkAccessWebFilteringPolicy -MockWith {}
            Mock -CommandName Get-MgBetaNetworkAccessWebFilteringPolicyRule -MockWith {}
            Mock -CommandName New-MgBetaNetworkAccessWebFilteringPolicyRule -MockWith {}
            Mock -CommandName Update-MgBetaNetworkAccessWebFilteringPolicyRule -MockWith {}
            Mock -CommandName Remove-MgBetaNetworkAccessWebFilteringPolicyRule -MockWith {}
            Mock -CommandName Get-MgBetaNetworkAccessWebFilteringPolicy -MockWith {
                return @{
                    Name        = 'Block social media websites'
                    Id          = 'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee'
                    Description = 'Policy to block access to social media categories'
                    Settings    = @{
                        DefaultAction = @{
                            '@odata.type' = '#microsoft.graph.networkaccess.webFilteringActionAllow'
                        }
                    }
                }
            }

            Mock -CommandName Write-M365DSCHost -MockWith {}

            Mock -CommandName Save-M365DSCPartialExport -MockWith {}

            Mock -CommandName New-M365DSCLogEntry -ModuleName '_Shared' -MockWith {}
        }

        Context -Name 'The instance should exist but it DOES NOT' -Fixture {
            BeforeAll {
                $testParams = @{
                    Name          = 'Block social media websites'
                    Description   = 'Policy to block access to social media categories'
                    DefaultAction = 'allow'
                    Ensure        = 'Present'
                    Credential    = $Credential
                }

                Mock -CommandName Get-MgBetaNetworkAccessWebFilteringPolicy -MockWith {
                    return $null
                }
            }

            It 'Should return Absent from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'AADGSAWebContentFilteringPolicy' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADGSAWebContentFilteringPolicy' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should create a new instance from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'AADGSAWebContentFilteringPolicy' -Property $testParams).Set()
                Should -Invoke -CommandName New-MgBetaNetworkAccessWebFilteringPolicy -Exactly 1
            }
        }

        Context -Name 'The instance exists but it SHOULD NOT' -Fixture {
            BeforeAll {
                $testParams = @{
                    Name          = 'Block social media websites'
                    Description   = 'Policy to block access to social media categories'
                    DefaultAction = 'allow'
                    Ensure        = 'Absent'
                    Credential    = $Credential
                }
            }

            It 'Should return Present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'AADGSAWebContentFilteringPolicy' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADGSAWebContentFilteringPolicy' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should remove the instance from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'AADGSAWebContentFilteringPolicy' -Property $testParams).Set()
                Should -Invoke -CommandName Remove-MgBetaNetworkAccessWebFilteringPolicy -Exactly 1
            }
        }

        Context -Name 'The instance exists and values are in the desired state' -Fixture {
            BeforeAll {
                $testParams = @{
                    Name          = 'Block social media websites'
                    Description   = 'Policy to block access to social media categories'
                    DefaultAction = 'allow'
                    Ensure        = 'Present'
                    Credential    = $Credential
                }
            }

            It 'Should return Present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'AADGSAWebContentFilteringPolicy' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADGSAWebContentFilteringPolicy' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name 'The instance exists and values are NOT in the desired state' -Fixture {
            BeforeAll {
                $testParams = @{
                    Name          = 'Block social media websites'
                    Description   = 'Policy to block access to social media categories'
                    DefaultAction = 'block'
                    Ensure        = 'Present'
                    Credential    = $Credential
                }
            }

            It 'Should return Present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'AADGSAWebContentFilteringPolicy' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADGSAWebContentFilteringPolicy' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should update the instance from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'AADGSAWebContentFilteringPolicy' -Property $testParams).Set()
                Should -Invoke -CommandName Update-MgBetaNetworkAccessWebFilteringPolicy -Exactly 1
            }
        }

        Context -Name 'The instance exists and Rules are NOT in the desired state' -Fixture {
            BeforeAll {
                $testParams = @{
                    Name          = 'Block social media websites'
                    Description   = 'Policy to block access to social media categories'
                    DefaultAction = 'allow'
                    Ensure        = 'Present'
                    Credential    = $Credential
                    Rules         = @(
                        [MSFT_AADGSAWebContentFilteringPolicyRule] @{
                            Name              = 'Block Facebook'
                            Priority          = [System.UInt32] 100
                            Description       = 'Block access to social networking'
                            Action            = 'block'
                            Status            = 'enabled'
                            HttpRequestMethod = 'get'
                            SessionType       = 'user'
                            Destinations      = @(
                                [MSFT_AADGSAWebContentFilteringPolicyRuleDestination] @{
                                    Type   = 'webFilteringWebCategoryDestination'
                                    Values = @('SocialNetworking')
                                }
                            )
                        }
                    )
                }

                Mock -CommandName Get-MgBetaNetworkAccessWebFilteringPolicy -MockWith {
                    return @{
                        Name        = 'Block social media websites'
                        Id          = 'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee'
                        Description = 'Policy to block access to social media categories'
                        Settings    = @{
                            DefaultAction = @{
                                '@odata.type' = '#microsoft.graph.networkaccess.webFilteringActionAllow'
                            }
                        }
                        PolicyRules = @(
                            @{
                                Id       = 'existing-rule-id'
                                Name     = 'Block a stale category'
                                Priority = 200
                                Action   = @{
                                    '@odata.type' = '#microsoft.graph.networkaccess.webFilteringActionBlock'
                                }
                                Settings           = @{ Status = 'enabled' }
                                MatchingConditions = @{
                                    Destinations = @{
                                        HttpRequestMethod = 'get'
                                        Targets           = @(
                                            @{
                                                '@odata.type' = '#microsoft.graph.networkaccess.webFilteringWebCategoryDestination'
                                                Values        = @('Gambling')
                                            }
                                        )
                                    }
                                    Sources = @{ SessionType = 'user' }
                                }
                            }
                        )
                    }
                }
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADGSAWebContentFilteringPolicy' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should create the new rule and remove the stale rule from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'AADGSAWebContentFilteringPolicy' -Property $testParams).Set()
                Should -Invoke -CommandName New-MgBetaNetworkAccessWebFilteringPolicyRule -Exactly 1
                Should -Invoke -CommandName Remove-MgBetaNetworkAccessWebFilteringPolicyRule -Exactly 1
            }

            It 'Should always send matchingConditions, even when destinations would be empty' {
                (New-M365DSCResourceInstance -ResourceName 'AADGSAWebContentFilteringPolicy' -Property $testParams).Set()
                Should -Invoke -CommandName New-MgBetaNetworkAccessWebFilteringPolicyRule -ParameterFilter {
                    $BodyParameter.name -eq 'Block Facebook' -and
                    $BodyParameter.ContainsKey('matchingConditions') -and
                    $BodyParameter.matchingConditions.destinations.targets.Count -eq 1
                }
            }
        }

        Context -Name 'ReverseDSC Tests' -Fixture {
            BeforeAll {
                $Global:CurrentModeIsExport = $true
                $Global:PartialExportFileName = "$(New-Guid).partial.ps1"
                $testParams = @{
                    Credential = $Credential
                }

                Mock -CommandName Get-MgBetaNetworkAccessWebFilteringPolicy -MockWith {
                    return @(
                        @{
                            Name        = 'Block social media websites'
                            Id          = 'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee'
                            Description = 'Policy to block access to social media categories'
                            Settings    = @{
                                DefaultAction = @{
                                    '@odata.type' = '#microsoft.graph.networkaccess.webFilteringActionAllow'
                                }
                            }
                            PolicyRules = @(
                                @{
                                    Id       = 'e0cf2cb9-29cf-4e3e-b73f-0f521b2a095c'
                                    Name     = 'Block Facebook'
                                    Priority = 100
                                    Action   = @{
                                        '@odata.type' = '#microsoft.graph.networkaccess.webFilteringActionBlock'
                                    }
                                    Settings           = @{ Status = 'enabled' }
                                    MatchingConditions = @{
                                        Destinations = @{
                                            HttpRequestMethod = 'get'
                                            Targets           = @(
                                                @{
                                                    '@odata.type' = '#microsoft.graph.networkaccess.webFilteringWebCategoryDestination'
                                                    Values        = @('SocialNetworking')
                                                }
                                            )
                                        }
                                        Sources = @{ SessionType = 'user' }
                                    }
                                }
                            )
                        }
                    )
                }
            }

            It 'Should reverse engineer resource from the Export method' {
                $result = Invoke-M365DSCResourceMethod -ResourceName 'AADGSAWebContentFilteringPolicy' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}
