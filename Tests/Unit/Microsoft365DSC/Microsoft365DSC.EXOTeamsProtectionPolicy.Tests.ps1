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
    -DscResource 'EXOTeamsProtectionPolicy' -GenericStubModule $GenericStubPath

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

            Mock -CommandName Set-TeamsProtectionPolicy -MockWith {
            }

            Mock -CommandName New-TeamsProtectionPolicy -MockWith {
            }

            Mock -CommandName Get-TeamsProtectionPolicy -MockWith {
                return @{
                    AdminDisplayName                 = "Contoso Administrator"
                    HighConfidencePhishQuarantineTag = "DefaultFullAccessPolicy"
                    MalwareQuarantineTag             = "AdminOnlyAccessPolicy"
                    ZapEnabled                       = $true
                }
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstances =$null
            $Script:ExportMode = $false
        }

        # Test contexts
        Context -Name "When the policy doesn't already exist" -Fixture {
            BeforeAll {
                $testParams = @{
                    IsSingleInstance                 = "Yes"
                    AdminDisplayName                 = "Contoso Administrator"
                    HighConfidencePhishQuarantineTag = "DefaultFullAccessPolicy"
                    MalwareQuarantineTag             = "AdminOnlyAccessPolicy"
                    ZapEnabled                       = $true
                    Credential                       = $Credential
                }

                Mock -CommandName Get-TeamsProtectionPolicy -MockWith {
                    return $null
                }
            }

            It 'Should return absent from the Get method' {
                $result = ((New-M365DSCResourceInstance -ResourceName 'EXOTeamsProtectionPolicy' -Property $testParams).Get().ToHashtable())
                $result.AdminDisplayName | Should -BeNullOrEmpty
                $result.HighConfidencePhishQuarantineTag | Should -BeNullOrEmpty
                $result.MalwareQuarantineTag | Should -BeNullOrEmpty
                $result.ZapEnabled | Should -BeNullOrEmpty
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOTeamsProtectionPolicy' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should create the policy from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOTeamsProtectionPolicy' -Property $testParams).Set()
                Should -Invoke -CommandName 'New-TeamsProtectionPolicy' -Exactly 1
                Should -Invoke -CommandName 'Set-TeamsProtectionPolicy' -Exactly 1
            }
        }

        Context -Name 'When the policy already exists and IS in the Desired State' -Fixture {
            BeforeAll {
                $testParams = @{
                    IsSingleInstance                 = "Yes"
                    AdminDisplayName                 = "Contoso Administrator"
                    HighConfidencePhishQuarantineTag = "DefaultFullAccessPolicy"
                    MalwareQuarantineTag             = "AdminOnlyAccessPolicy"
                    ZapEnabled                       = $true
                    Credential                       = $Credential
                }
            }

            It 'Should return absent from the Get method' {
                $result = ((New-M365DSCResourceInstance -ResourceName 'EXOTeamsProtectionPolicy' -Property $testParams).Get().ToHashtable())
                $result.AdminDisplayName | Should -Be $testParams.AdminDisplayName
                $result.HighConfidencePhishQuarantineTag | Should -Be $testParams.HighConfidencePhishQuarantineTag
                $result.MalwareQuarantineTag | Should -Be $testParams.MalwareQuarantineTag
                $result.ZapEnabled | Should -Be $testParams.ZapEnabled
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOTeamsProtectionPolicy' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name 'When the policy already exists and is NOT in the Desired State' -Fixture {
            BeforeAll {
                $testParams = @{
                    IsSingleInstance                 = "Yes"
                    AdminDisplayName                 = "Contoso Administrator"
                    HighConfidencePhishQuarantineTag = "DefaultFullAccessPolicy"
                    MalwareQuarantineTag             = "AdminOnlyAccessPolicy"
                    ZapEnabled                       = $true
                    Credential                       = $Credential
                }

                Mock -CommandName Get-TeamsProtectionPolicy -MockWith {
                    return @{
                        AdminDisplayName                 = ""
                        HighConfidencePhishQuarantineTag = "AdminOnlyAccessPolicy"
                        MalwareQuarantineTag             = "AdminOnlyAccessPolicy"
                        ZapEnabled                       = $false
                    }
                }
            }

            It 'Should return absent from the Get method' {
                $result = ((New-M365DSCResourceInstance -ResourceName 'EXOTeamsProtectionPolicy' -Property $testParams).Get().ToHashtable())
                $result.AdminDisplayName | Should -BeNullOrEmpty
                $result.HighConfidencePhishQuarantineTag | Should -Be "AdminOnlyAccessPolicy"
                $result.MalwareQuarantineTag | Should -Be "AdminOnlyAccessPolicy"
                $result.ZapEnabled | Should -Be $false
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOTeamsProtectionPolicy' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should create the policy from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOTeamsProtectionPolicy' -Property $testParams).Set()
                Should -Invoke -CommandName 'Set-TeamsProtectionPolicy' -Exactly 1
            }
        }

        Context -Name 'ReverseDSC Tests' -Fixture {
            BeforeAll {
                $testParams = @{
                    Credential = $Credential
                }
            }

            It 'Should Reverse Engineer resource from the Export method' {
                $result = Invoke-M365DSCResourceMethod -ResourceName 'EXOTeamsProtectionPolicy' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
