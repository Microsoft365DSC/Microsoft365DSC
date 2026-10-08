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
    -DscResource 'TeamsTenantDialPlan' -GenericStubModule $GenericStubPath

Describe -Name $Global:DscHelper.DescribeHeader -Fixture {
    InModuleScope -ModuleName $Global:DscHelper.ModuleName -ScriptBlock {
        Invoke-Command -ScriptBlock $Global:DscHelper.InitializeScript -NoNewScope

        BeforeAll {
            $secpasswd = ConvertTo-SecureString ((New-Guid).ToString()) -AsPlainText -Force
            $Credential = New-Object System.Management.Automation.PSCredential ('tenantadmin@onmicrosoft.com', $secpasswd)

            $Global:PartialExportFileName = 'c:\TestPath'

            Mock -ModuleName M365DSCUtil -CommandName Confirm-M365DSCDependencies -MockWith {
            }

            Mock -CommandName Save-M365DSCPartialExport -MockWith {
            }

            Mock -CommandName New-M365DSCConnection -ModuleName '_Shared' -MockWith {
                return 'Credentials'
            }

            Mock -CommandName Set-CsTenantDialPlan -MockWith {
            }

            Mock -CommandName Remove-CsTenantDialPlan -MockWith {
            }

            Mock -CommandName New-CsTenantDialPlan -MockWith {
            }

            Mock -CommandName Get-CsTenantDialPlan -MockWith {
                return @{
                    Identity           = 'Test'
                    Description        = 'TestDescription'
                    NormalizationRules = @(
                        @{
                            Pattern             = '^00(\d+)$'
                            Description         = 'None'
                            Name                = 'TestNotExisting'
                            Translation         = '+$1'
                            Priority            = 0
                            IsInternalExtension = $False
                        },
                        @{
                            Pattern             = '^00(\d+)$'
                            Description         = 'None'
                            Name                = 'TestNotExisting2'
                            Translation         = '+$1'
                            Priority            = 0
                            IsInternalExtension = $False
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
        Context -Name "The dial plan doesn't exist" -Fixture {
            BeforeAll {
                $testParams = @{
                    Identity   = 'TestPlan'
                    Ensure     = 'Present'
                    Credential = $Credential
                }

                Mock -CommandName Get-CsTenantDialPlan -MockWith {
                    return $null
                }
            }

            It 'Should return false from the Test method' {
                [boolean] $result = (New-M365DSCResourceInstance -ResourceName 'TeamsTenantDialPlan' -Property $testParams).Test()
                $result | Should -Be $false
            }

            It 'Should return False for the Ensure property from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'TeamsTenantDialPlan' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }

            It 'Create the dial plan Set method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsTenantDialPlan' -Property $testParams).Set()
                Should -Invoke -CommandName New-CsTenantDialPlan -Exactly 1
            }
        }

        Context -Name 'The dial plan exists but is NOT in the Desired State' -Fixture {
            BeforeAll {
                $testParams = @{
                    Identity           = 'Test'
                    Description        = 'TestDescription'
                    Ensure             = 'Present'
                    NormalizationRules = @([MSFT_TeamsVoiceNormalizationRule] @{
                            Pattern             = '^01(\d+)$' # Drift
                            Description         = 'None'
                            Identity            = 'TestNotExisting'
                            Translation         = '+$1'
                            Priority            = 0
                            IsInternalExtension = $False
                        };
                    )
                    Credential         = $Credential
                }
            }

            It 'Should return false from the Test method' {
                [boolean] $result = (New-M365DSCResourceInstance -ResourceName 'TeamsTenantDialPlan' -Property $testParams).Test()
                $result | Should -Be $false
            }

            It 'Should return True for the Ensure property from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'TeamsTenantDialPlan' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Updates in the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsTenantDialPlan' -Property $testParams).Set()
                Should -Invoke -CommandName Set-CsTenantDialPlan -Exactly 2
            }
        }

        Context -Name 'The dial plan exists and IS in the Desired State' -Fixture {
            BeforeAll {
                $testParams = @{
                    Identity           = 'Test'
                    Description        = 'TestDescription'
                    Ensure             = 'Present'
                    NormalizationRules = @([MSFT_TeamsVoiceNormalizationRule] @{
                            Pattern             = '^00(\d+)$'
                            Description         = 'None'
                            Identity            = 'TestNotExisting'
                            Translation         = '+$1'
                            Priority            = 0
                            IsInternalExtension = $False
                        };
                        [MSFT_TeamsVoiceNormalizationRule] @{
                            Pattern             = '^00(\d+)$'
                            Description         = 'None'
                            Identity            = 'TestNotExisting2'
                            Translation         = '+$1'
                            Priority            = 0
                            IsInternalExtension = $False
                        })
                    Credential         = $Credential
                }
            }

            It 'Should return true from the Test method' {
                [boolean] $result = (New-M365DSCResourceInstance -ResourceName 'TeamsTenantDialPlan' -Property $testParams).Test()
                $result | Should -Be $true
            }

            It 'Should return True for the Ensure property from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'TeamsTenantDialPlan' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }
        }

        Context -Name 'The dial plan exists but it SHOULD NOT' -Fixture {
            BeforeAll {
                $testParams = @{
                    Identity    = 'Test'
                    Description = 'TestDescription'
                    Ensure      = 'Absent'
                    Credential  = $Credential
                }
            }

            It 'Should return false from the Test method' {
                [boolean] $result = (New-M365DSCResourceInstance -ResourceName 'TeamsTenantDialPlan' -Property $testParams).Test()
                $result | Should -Be $false
            }

            It 'Should return True for the Ensure property from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'TeamsTenantDialPlan' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }


            It 'Remove the dial plan in the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsTenantDialPlan' -Property $testParams).Set()
                Should -Invoke -CommandName Remove-CsTenantDialPlan -Exactly 1
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
                $result = Invoke-M365DSCResourceMethod -ResourceName 'TeamsTenantDialPlan' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
