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

$CurrentScriptPath = $PSCommandPath.Split('\')
$CurrentScriptName = $CurrentScriptPath[$CurrentScriptPath.Length -1]
$ResourceName      = $CurrentScriptName.Split('.')[1]
$Global:DscHelper = New-M365DscUnitTestHelper -StubModule $CmdletModule `
    -DscResource $ResourceName -GenericStubModule $GenericStubPath

Describe -Name $Global:DscHelper.DescribeHeader -Fixture {
    InModuleScope -ModuleName $Global:DscHelper.ModuleName -ScriptBlock {
        Invoke-Command -ScriptBlock $Global:DscHelper.InitializeScript -NoNewScope
        BeforeAll {

            $secpasswd = ConvertTo-SecureString (New-Guid | Out-String) -AsPlainText -Force
            $Credential = New-Object System.Management.Automation.PSCredential ('tenantadmin@onmicrosoft.com', $secpasswd)

            Mock -ModuleName M365DSCUtil -CommandName Confirm-M365DSCDependencies -MockWith {
            }

            Mock -CommandName New-M365DSCConnection -ModuleName '_Shared' -MockWith {
                return "Credentials"
            }

            Mock -CommandName New-MgBetaNetworkAccessFilteringProfile -MockWith{}
            Mock -CommandName Remove-MgBetaNetworkAccessFilteringProfile -MockWith{}
            Mock -CommandName Get-MgBetaNetworkAccessFilteringPolicy -MockWith{
                return @(
                    @{
                        id   = '12345-12345-12345-12345-12346'
                        name = 'MyTopPolicy'
                    }
                )
            }

            Mock -CommandName Get-MgBetaNetworkAccessFilteringProfilePolicy -MockWith {
                return @(
                    @{
                        Policy = @{
                            id = '12345-12345-12345-12345-12345'
                            name = 'MyTopPolicy'
                        }
                        priority = 200
                        loggingState = 'enabled'
                        State = 'enabled'
                    }
                )
            }

            Mock -CommandName Get-MgBetaNetworkAccessFilteringProfile -MockWith {
                return @{
                    Id          = '22222-22222-22222-22222-22222'
                    Name        = 'My Profile'
                    Description = 'Description of profile'
                    State       = 'enabled'
                    Priority    = 120
                    Policies    = @(
                        @{
                            Id                   = '11111-22222-33333-44444-55556'
                            State                = 'enabled'
                            priority     = 200
                            loggingState = 'enabled'
                        }
                    )
                }
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstances =$null
            $Script:ExportMode = $false
        }
        # Test contexts
        Context -Name "The instance should exist but it DOES NOT" -Fixture {
            BeforeAll {
                $testParams = @{
                    Description           = "Description of profile";
                    Name                  = "My Profile";
                    Policies              = @(
                        ([MSFT_AADFilteringProfilePolicyLink] @{
                            Priority = 200
                            LoggingState = 'enabled'
                            PolicyName = 'MyTopPolicy'
                            State = 'enabled'
                        })
                    );
                    Priority              = 120;
                    State                 = "enabled";
                    Ensure              = 'Present'
                    Credential          = $Credential;
                }

                Mock -CommandName Get-MgBetaNetworkAccessFilteringProfile -MockWith {
                    return $null
                }
            }
            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'AADFilteringProfile' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }
            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADFilteringProfile' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should create a new instance from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'AADFilteringProfile' -Property $testParams).Set()
                Should -Invoke -CommandName New-MgBetaNetworkAccessFilteringProfile -Exactly 1
            }

            It 'Should throw from the Set method when a linked policy does not exist' {
                Mock -CommandName Get-MgBetaNetworkAccessFilteringPolicy -MockWith {
                    return @()
                }

                { (New-M365DSCResourceInstance -ResourceName 'AADFilteringProfile' -Property $testParams).Set() } | Should -Throw '*Could not find filtering policy {MyTopPolicy}*'
                Should -Invoke -CommandName New-MgBetaNetworkAccessFilteringProfile -Exactly 0
            }
        }

        Context -Name "The instance exists but it SHOULD NOT" -Fixture {
            BeforeAll {
                $testParams = @{
                    Description           = "Description of profile";
                    Name                  = "My Profile";
                    Policies              = @(
                        ([MSFT_AADFilteringProfilePolicyLink] @{
                            Priority = 200
                            LoggingState = 'enabled'
                            PolicyName = 'MyTopPolicy'
                            State = 'enabled'
                        })
                    );
                    Priority              = 120;
                    State                 = "enabled";
                    Ensure              = 'Absent'
                    Credential          = $Credential;
                }
            }
            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'AADFilteringProfile' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }
            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADFilteringProfile' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should remove the instance from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'AADFilteringProfile' -Property $testParams).Set()
                Should -Invoke -CommandName Remove-MgBetaNetworkAccessFilteringProfile -Exactly 1
            }
        }

        Context -Name "The instance exists and values are already in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    Description           = "Description of profile";
                    Name                  = "My Profile";
                    Policies              = @(
                        ([MSFT_AADFilteringProfilePolicyLink] @{
                            Priority = 200
                            LoggingState = 'enabled'
                            PolicyName = 'MyTopPolicy'
                            State = 'enabled'
                        })
                    );
                    Priority              = 120;
                    State                 = "enabled";
                    Ensure              = 'Present'
                    Credential          = $Credential;
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADFilteringProfile' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name "The instance exists and values are NOT in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    Description           = "Description of profile";
                    Name                  = "My Profile";
                    Policies              = @(
                        ([MSFT_AADFilteringProfilePolicyLink] @{
                            Priority = 200
                            LoggingState = 'enabled'
                            PolicyName = 'MyTopPolicy'
                            State = 'enabled'
                        })
                    );
                    Priority              = 122; # Drift
                    State                 = "enabled";
                    Ensure              = 'Present'
                    Credential          = $Credential;
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'AADFilteringProfile' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADFilteringProfile' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'AADFilteringProfile' -Property $testParams).Set()
                Should -Invoke -CommandName Remove-MgBetaNetworkAccessFilteringProfile -Exactly 1
                Should -Invoke -CommandName New-MgBetaNetworkAccessFilteringProfile -Exactly 1
            }
        }

        Context -Name 'ReverseDSC Tests' -Fixture {
            BeforeAll {
                $Global:CurrentModeIsExport = $true
                $Global:PartialExportFileName = "$(New-Guid).partial.ps1"
                $testParams = @{
                    Credential  = $Credential;
                }
            }
            It 'Should Reverse Engineer resource from the Export method' {
                $result = Invoke-M365DSCResourceMethod -ResourceName 'AADFilteringProfile' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
