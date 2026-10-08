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
    -DscResource 'SCAppRetentionComplianceRule' -GenericStubModule $GenericStubPath
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

            Mock -CommandName Add-M365DSCTelemetryEvent -ModuleName '_Shared' -MockWith {
            }

            Mock -CommandName New-M365DSCLogEntry -ModuleName '_Shared' -MockWith {
            }

            Mock -CommandName Get-PSSession -MockWith {
            }

            Mock -CommandName Remove-PSSession -MockWith {
            }

            Mock -CommandName Start-Sleep -MockWith {
            }

            Mock -CommandName New-AppRetentionComplianceRule -MockWith {
            }

            Mock -CommandName Set-AppRetentionComplianceRule -MockWith {
            }

            Mock -CommandName Remove-AppRetentionComplianceRule -MockWith {
            }

            Mock -CommandName Get-AppRetentionCompliancePolicy -MockWith {
                return [PSCustomObject]@{
                    Name = 'Teams Channel Messages Retention'
                    Guid = 'f266901e-de1c-454a-b557-1fd61aa92576'
                }
            }

            $Script:NewRule = {
                return [PSCustomObject]@{
                    Name                         = 'Teams Channel Messages Retention Rule'
                    Policy                       = 'f266901e-de1c-454a-b557-1fd61aa92576'
                    Comment                      = 'Keeps channel messages for seven years'
                    RetentionDuration            = '2555'
                    RetentionDurationDisplayHint = 'Days'
                    RetentionComplianceAction    = 'KeepAndDelete'
                    ExpirationDateOption         = 'CreationAgeInDays'
                    Mode                         = 'Enforce'
                }
            }

            Mock -CommandName Get-AppRetentionComplianceRule -MockWith {
                return & $Script:NewRule
            }

            Mock -CommandName Write-M365DSCHost -MockWith {
            }

            Mock -CommandName Save-M365DSCPartialExport -MockWith {
            }

            Mock -CommandName Update-M365DSCExportAuthenticationResults -MockWith {
                return @{}
            }

            Mock -CommandName Get-M365DSCExportContentForResource -MockWith {
                return "SCAppRetentionComplianceRule 'TestInstance' {}`r`n"
            }

            $Script:exportedInstance = $null
            $Script:exportedInstances = $null
            $Script:ExportMode = $false
        }

        # Test contexts
        Context -Name 'The instance should exist but it DOES NOT' -Fixture {
            BeforeAll {
                $testParams = @{
                    Name                         = 'Teams Channel Messages Retention Rule'
                    Policy                       = 'Teams Channel Messages Retention'
                    Comment                      = 'Keeps channel messages for seven years'
                    RetentionDuration            = '2555'
                    RetentionDurationDisplayHint = 'Days'
                    RetentionComplianceAction    = 'KeepAndDelete'
                    ExpirationDateOption         = 'CreationAgeInDays'
                    Ensure                       = 'Present'
                    Credential                   = $Credential
                }

                Mock -CommandName Get-AppRetentionComplianceRule -MockWith {
                    return $null
                }
            }

            It 'Should return Absent from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'SCAppRetentionComplianceRule' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'SCAppRetentionComplianceRule' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should create the instance from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'SCAppRetentionComplianceRule' -Property $testParams).Set()
                Should -Invoke -CommandName 'New-AppRetentionComplianceRule' -Exactly 1 -ParameterFilter {
                    $Name -eq 'Teams Channel Messages Retention Rule' -and $Policy -eq 'Teams Channel Messages Retention'
                }
            }
        }

        Context -Name 'The instance exists but it SHOULD NOT' -Fixture {
            BeforeAll {
                $testParams = @{
                    Name       = 'Teams Channel Messages Retention Rule'
                    Policy     = 'Teams Channel Messages Retention'
                    Ensure     = 'Absent'
                    Credential = $Credential
                }
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'SCAppRetentionComplianceRule' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should remove the instance from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'SCAppRetentionComplianceRule' -Property $testParams).Set()
                Should -Invoke -CommandName 'Remove-AppRetentionComplianceRule' -Exactly 1
            }
        }

        Context -Name 'The instance exists and values are already in the desired state' -Fixture {
            BeforeAll {
                $testParams = @{
                    Name                         = 'Teams Channel Messages Retention Rule'
                    Policy                       = 'Teams Channel Messages Retention'
                    Comment                      = 'Keeps channel messages for seven years'
                    RetentionDuration            = '2555'
                    RetentionDurationDisplayHint = 'Days'
                    RetentionComplianceAction    = 'KeepAndDelete'
                    ExpirationDateOption         = 'CreationAgeInDays'
                    Ensure                       = 'Present'
                    Credential                   = $Credential
                }
            }

            It 'Should resolve the policy name from the Get method' {
                $result = (New-M365DSCResourceInstance -ResourceName 'SCAppRetentionComplianceRule' -Property $testParams).Get().ToHashtable()
                $result.Ensure | Should -Be 'Present'
                $result.Policy | Should -Be 'Teams Channel Messages Retention'
                $result.RetentionDuration | Should -Be '2555'
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'SCAppRetentionComplianceRule' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name 'The instance exists and values are NOT in the desired state' -Fixture {
            BeforeAll {
                $testParams = @{
                    Name                         = 'Teams Channel Messages Retention Rule'
                    Policy                       = 'Teams Channel Messages Retention'
                    Comment                      = 'Keeps channel messages for seven years'
                    RetentionDuration            = '3650'
                    RetentionDurationDisplayHint = 'Days'
                    RetentionComplianceAction    = 'KeepAndDelete'
                    ExpirationDateOption         = 'CreationAgeInDays'
                    Ensure                       = 'Present'
                    Credential                   = $Credential
                }
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'SCAppRetentionComplianceRule' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should update the instance without the policy from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'SCAppRetentionComplianceRule' -Property $testParams).Set()
                Should -Invoke -CommandName 'Set-AppRetentionComplianceRule' -Exactly 1 -ParameterFilter {
                    $Identity -eq 'Teams Channel Messages Retention Rule' -and
                    $RetentionDuration -eq '3650' -and
                    -not $PSBoundParameters.ContainsKey('Policy') -and
                    -not $PSBoundParameters.ContainsKey('Name')
                }
            }
        }

        Context -Name 'The instance should move to another policy' -Fixture {
            BeforeAll {
                $testParams = @{
                    Name       = 'Teams Channel Messages Retention Rule'
                    Policy     = 'Viva Engage Retention'
                    Ensure     = 'Present'
                    Credential = $Credential
                }
            }

            It 'Should throw from the Set method' {
                { (New-M365DSCResourceInstance -ResourceName 'SCAppRetentionComplianceRule' -Property $testParams).Set() } | Should -Throw '*cannot move from policy*'
                Should -Invoke -CommandName 'Set-AppRetentionComplianceRule' -Exactly 0
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

            It 'Should reverse engineer resource from the Export method' {
                $result = Invoke-M365DSCResourceMethod -ResourceName 'SCAppRetentionComplianceRule' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
                Should -Invoke -CommandName 'Get-AppRetentionComplianceRule'
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
