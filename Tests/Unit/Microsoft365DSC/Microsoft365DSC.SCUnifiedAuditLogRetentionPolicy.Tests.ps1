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
    -DscResource "SCUnifiedAuditLogRetentionPolicy" -GenericStubModule $GenericStubPath
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

            Mock -CommandName Set-UnifiedAuditLogRetentionPolicy -MockWith {
            }

            Mock -CommandName New-UnifiedAuditLogRetentionPolicy -MockWith {
            }

            Mock -CommandName Remove-UnifiedAuditLogRetentionPolicy -MockWith {
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
        Context -Name "The SCUnifiedAuditLogRetentionPolicy should exist but it DOES NOT" -Fixture {
            BeforeAll {
                $testParams = @{
                    Name = "Test Policy"
                    Priority = 42
                    RetentionDuration = "SevenDays"
                    Ensure = "Present"
                    Credential = $Credential;
                }

                Mock -CommandName Get-UnifiedAuditLogRetentionPolicy -MockWith {
                    return $null
                }
            }
            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'SCUnifiedAuditLogRetentionPolicy' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }
            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'SCUnifiedAuditLogRetentionPolicy' -Property $testParams).Test() | Should -Be $false
            }
            It 'Should Create the Unified Audit Log Retention Policy from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'SCUnifiedAuditLogRetentionPolicy' -Property $testParams).Set()
                Should -Invoke -CommandName New-UnifiedAuditLogRetentionPolicy -Exactly 1
            }
        }

        Context -Name "The SCUnifiedAuditLogRetentionPolicy exists but it SHOULD NOT" -Fixture {
            BeforeAll {
                $testParams = @{
                    Name = "Test Policy"
                    Priority = 42
                    RetentionDuration = "SevenDays"
                    Ensure = "Absent"
                    Credential = $Credential;
                }

                Mock -CommandName Get-UnifiedAuditLogRetentionPolicy -MockWith {
                    return @{
                        Identity = "TestIdentity"
                        Priority = $testParams.Priority
                        Name = $testParams.Name
                        RetentionDuration = $testParams.RetentionDuration
                    }
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'SCUnifiedAuditLogRetentionPolicy' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'SCUnifiedAuditLogRetentionPolicy' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should Remove the group from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'SCUnifiedAuditLogRetentionPolicy' -Property $testParams).Set()
                Should -Invoke -CommandName Remove-UnifiedAuditLogRetentionPolicy -Exactly 1 -ParameterFilter { $Identity -eq 'Test Policy' -and -not $ForceDeletion }
                Should -Invoke -CommandName Remove-UnifiedAuditLogRetentionPolicy -Exactly 1 -ParameterFilter { $Identity -eq 'Test Policy' -and $ForceDeletion }
            }
        }
        Context -Name "The SCUnifiedAuditLogRetentionPolicy Exists and Values are already in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    Name = "Test Policy"
                    Priority = 42
                    RetentionDuration = "SevenDays"
                    Ensure = 'Present'
                    Credential = $Credential;
                }

                Mock -CommandName Get-UnifiedAuditLogRetentionPolicy -MockWith {
                    return @{
                        Name = "Test Policy"
                        Priority = 42
                        RetentionDuration = "SevenDays"
                    }
                }
            }


            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'SCUnifiedAuditLogRetentionPolicy' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name "The SCUnifiedAuditLogRetentionPolicy exists and values are NOT in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    Name = "Test Policy"
                    Priority = 42
                    RetentionDuration = "SevenDays"
                    Description = "FakeStringValueDrift"
                    Ensure = 'Present'
                    Credential = $Credential;
                }

                Mock -CommandName Get-UnifiedAuditLogRetentionPolicy -MockWith {
                    return @{
                        Identity = "TestIdentity"
                        Name = $testParams.Name
                        Priority              = $testParams.Priority
                        RetentionDuration     = $testParams.RetentionDuration
                        Description           = $testParams.RetentionDescription + "#Drift"
                    }
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'SCUnifiedAuditLogRetentionPolicy' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'SCUnifiedAuditLogRetentionPolicy' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'SCUnifiedAuditLogRetentionPolicy' -Property $testParams).Set()
                Should -Invoke -CommandName Set-UnifiedAuditLogRetentionPolicy -Exactly 1 -ParameterFilter { $Identity -eq 'Test Policy' }
            }
        }

        Context -Name 'ReverseDSC Tests' -Fixture {
            BeforeAll {
                $Global:CurrentModeIsExport = $true
                $Global:PartialExportFileName = "$(New-Guid).partial.ps1"
                $testParams = @{
                    Credential = $Credential
                }

                Mock -CommandName Get-UnifiedAuditLogRetentionPolicy -MockWith {
                    return @{
                        Priority              = 3
                        Name                  = "FakeStringValue"
                        Description           = "FakeStringValue"
                        RetentionDuration     = "SevenDays"
                        Identity              = "FakeIdentity"
                    }
                }
            }
            It 'Should Reverse Engineer resource from the Export method' {
                $result = Invoke-M365DSCResourceMethod -ResourceName 'SCUnifiedAuditLogRetentionPolicy' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }

        Context -Name 'Does not return resources that are pending deletion' -Fixture {
            BeforeAll {
                $testParams = @{
                    Name = "Test Policy"
                    Priority = 42
                    RetentionDuration = "SevenDays"
                    Ensure = 'Present'
                    Credential = $Credential;
                }

                Mock -CommandName Get-UnifiedAuditLogRetentionPolicy -MockWith {
                    return @{
                        Name = "Test Policy"
                        Priority = 42
                        RetentionDuration = "SevenDays"
                        Mode = "PendingDeletion"
                    }
                }
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'SCUnifiedAuditLogRetentionPolicy' -Property $testParams).Test() | Should -Be $false
                (New-M365DSCResourceInstance -ResourceName 'SCUnifiedAuditLogRetentionPolicy' -Property $testParams).Set()
                Should -Invoke -CommandName Remove-UnifiedAuditLogRetentionPolicy -Exactly 1 -ParameterFilter { $Identity -eq 'Test Policy' -and $ForceDeletion }
                Should -Invoke -CommandName New-UnifiedAuditLogRetentionPolicy -Exactly 1
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
