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
    -DscResource 'SCRetentionComplianceRule' -GenericStubModule $GenericStubPath
Describe -Name $Global:DscHelper.DescribeHeader -Fixture {
    InModuleScope -ModuleName $Global:DscHelper.ModuleName -ScriptBlock {
        Invoke-Command -ScriptBlock $Global:DscHelper.InitializeScript -NoNewScope

        BeforeAll {
            $secpasswd = ConvertTo-SecureString (New-Guid | Out-String) -AsPlainText -Force
            $Credential = New-Object System.Management.Automation.PSCredential ('tenantadmin@onmicrosoft.com', $secpasswd)

            Mock -ModuleName M365DSCUtil -CommandName Confirm-M365DSCDependencies -MockWith {
            }

            Mock -CommandName New-M365DSCConnection -ModuleName '_Shared' -MockWith {
                return 'Credentials'
            }

            Mock -CommandName Import-PSSession -MockWith {
            }

            Mock -CommandName New-PSSession -MockWith {
            }

            Mock -CommandName Remove-RetentionComplianceRule -MockWith {
            }

            Mock -CommandName New-RetentionComplianceRule -MockWith {
                return @{

                }
            }

            Mock -CommandName Start-Sleep -MockWith {
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstances =$null
            $Script:ExportMode = $false
        }

        # Test contexts
        Context -Name "Rule doesn't already exist" -Fixture {
            BeforeAll {
                $testParams = @{
                    Ensure                    = 'Present'
                    Credential                = $Credential
                    Comment                   = 'This is a Demo Rule'
                    RetentionComplianceAction = 'Keep'
                    RetentionDuration         = 'Unlimited'
                    Name                      = 'TestRule'
                    Policy                    = 'TestPolicy'
                }

                Mock -CommandName Get-RetentionComplianceRule -MockWith {
                    return $null
                }
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'SCRetentionComplianceRule' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should return Absent from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'SCRetentionComplianceRule' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'SCRetentionComplianceRule' -Property $testParams).Set()
            }
        }

        Context -Name 'Rule already exists' -Fixture {
            BeforeAll {
                $testParams = @{
                    Ensure                    = 'Present'
                    Credential                = $Credential
                    Comment                   = 'This is a Demo Rule'
                    RetentionComplianceAction = 'Keep'
                    RetentionDuration         = 'Unlimited'
                    Name                      = 'TestRule'
                    Policy                    = 'TestPolicy'
                }

                Mock -CommandName Get-RetentionCompliancePolicy -MockWith {
                    return @{
                        Name = 'TestPolicy'
                    }
                }

                Mock -CommandName Get-RetentionComplianceRule -MockWith {
                    return @{
                        Name                      = 'TestRule'
                        Comment                   = 'This is a Demo Rule'
                        RetentionComplianceAction = 'Keep'
                        RetentionDuration         = 'Unlimited'
                    }
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'SCRetentionComplianceRule' -Property $testParams).Test() | Should -Be $true
            }

            It 'Should recreate from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'SCRetentionComplianceRule' -Property $testParams).Set()
            }

            It 'Should return Present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'SCRetentionComplianceRule' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }
        }

        Context -Name 'Rule should not exist' -Fixture {
            BeforeAll {
                $testParams = @{
                    Ensure                    = 'Absent'
                    Credential                = $Credential
                    Comment                   = 'This is a Demo Rule'
                    RetentionComplianceAction = 'Keep'
                    RetentionDuration         = 'Unlimited'
                    Name                      = 'TestRule'
                    Policy                    = 'TestPolicy'
                }

                Mock -CommandName Get-RetentionCompliancePolicy -MockWith {
                    return @{
                        Name = 'TestPolicy'
                    }
                }

                Mock -CommandName Get-RetentionComplianceRule -MockWith {
                    return @{
                        Name = 'TestRule'
                    }
                }
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'SCRetentionComplianceRule' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should delete from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'SCRetentionComplianceRule' -Property $testParams).Set()
                Should -Invoke -CommandName 'Remove-RetentionComplianceRule' -Exactly 1 -ParameterFilter { $Confirm -eq $false -and -not $ForceDeletion }
                Should -Invoke -CommandName 'Remove-RetentionComplianceRule' -Exactly 1 -ParameterFilter { $Confirm -eq $false -and $ForceDeletion }
            }

            It 'Should return Present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'SCRetentionComplianceRule' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }
        }

        Context -Name 'The rule is created but the deployment of its policy fails' -Fixture {
            BeforeAll {
                $testParams = @{
                    Ensure                    = 'Present'
                    Credential                = $Credential
                    Name                      = 'TestRule'
                    Policy                    = 'TestPolicy'
                    RetentionComplianceAction = 'Keep'
                    RetentionDuration         = '365'
                }

                Mock -CommandName Get-RetentionComplianceRule -MockWith {
                    return $null
                }

                Mock -CommandName Get-RetentionCompliancePolicy -MockWith {
                    return @{
                        Name = 'TestPolicy'
                    }
                }

                Mock -CommandName New-RetentionComplianceRule -MockWith {
                    throw "Policy 'x' failed to be deployed. To fix this issue, please retry the policy operation after some time."
                }
            }

            It 'Should warn instead of throwing from the Set method' {
                { (New-M365DSCResourceInstance -ResourceName 'SCRetentionComplianceRule' -Property $testParams).Set() } | Should -Not -Throw
                Should -Invoke -CommandName 'New-RetentionComplianceRule' -Exactly 1
            }
        }

        Context -Name 'ReverseDSC Tests' -Fixture {
            BeforeAll {
                $Global:CurrentModeIsExport = $true
                $Global:PartialExportFileName = "$(New-Guid).partial.ps1"
                $testParams = @{
                    Credential = $Credential
                }

                Mock -CommandName Get-RetentionCompliancePolicy -MockWith {
                    return @{
                        Name = 'TestPolicy'
                    }
                }

                Mock -CommandName Get-RetentionComplianceRule -MockWith {
                    return @{
                        Name                      = 'TestRule'
                        Comment                   = 'This is a Demo Rule'
                        Policy                    = 'TestPolicy'
                        RetentionComplianceAction = 'Keep'
                        RetentionDuration         = 'Unlimited'
                    }
                }
            }

            It 'Should Reverse Engineer resource from the Export method' {
                $result = Invoke-M365DSCResourceMethod -ResourceName 'SCRetentionComplianceRule' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
