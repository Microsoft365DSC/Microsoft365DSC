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
    -DscResource "AADActivityBasedTimeoutPolicy" -GenericStubModule $GenericStubPath
Describe -Name $Global:DscHelper.DescribeHeader -Fixture {
    InModuleScope -ModuleName $Global:DscHelper.ModuleName -ScriptBlock {
        Invoke-Command -ScriptBlock $Global:DscHelper.InitializeScript -NoNewScope
        BeforeAll {

            $secpasswd = ConvertTo-SecureString "f@kepassword1" -AsPlainText -Force
            $Credential = New-Object System.Management.Automation.PSCredential ('tenantadmin@onmicrosoft.com', $secpasswd)

            Mock -ModuleName M365DSCUtil -CommandName Confirm-M365DSCDependencies -MockWith {
            }

            Mock -CommandName Get-PSSession -MockWith {
            }

            Mock -CommandName Remove-PSSession -MockWith {
            }

            Mock -CommandName Update-MgBetaPolicyActivityBasedTimeoutPolicy -MockWith {
            }

            Mock -CommandName New-MgBetaPolicyActivityBasedTimeoutPolicy -MockWith {
            }

            Mock -CommandName Remove-MgBetaPolicyActivityBasedTimeoutPolicy -MockWith {
            }

            Mock -CommandName Get-MgBetaPolicyActivityBasedTimeoutPolicy -MockWith {
                return @{
                    DisplayName = "displayName-value"
                    AzurePortalTimeOut = "02:00:00"
                    DefaultTimeOut = "03:00:00"
                    Id = "000000-0000-0000-0000-000000000000"
                    Ensure = "Present"
                    Definition = @("{`"ActivityBasedTimeoutPolicy`":{`"Version`":1,`"ApplicationPolicies`":[{`"ApplicationId`":`"c44b4083-3bb0-49c1-b47d-974e53cbdf3c`",`"WebSessionIdleTimeout`":`"02:00:00`"},{`"ApplicationId`":`"default`",`"WebSessionIdleTimeout`":`"04:00:00`"}]}}");
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
        Context -Name "The AADActivityBasedTimeoutPolicy should exist but it DOES NOT" -Fixture {
            BeforeAll {
                $testParams = @{
                    DisplayName = "displayName-value"
                    AzurePortalTimeOut = "02:00:00"
                    DefaultTimeOut = "03:00:00"
                    Id = "000000-0000-0000-0000-000000000000"
                    Ensure = "Present"
                    Credential = $Credential;
                }

                Mock -CommandName Get-MgBetaPolicyActivityBasedTimeoutPolicy -MockWith {
                    return $null
                }
            }
            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'AADActivityBasedTimeoutPolicy' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }
            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADActivityBasedTimeoutPolicy' -Property $testParams).Test() | Should -Be $false
            }
            It 'Should Create the group from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'AADActivityBasedTimeoutPolicy' -Property $testParams).Set()
                Should -Invoke -CommandName New-MgBetaPolicyActivityBasedTimeoutPolicy -Exactly 1
            }
        }

        Context -Name "The AADActivityBasedTimeoutPolicy exists but it SHOULD NOT" -Fixture {
            BeforeAll {
                $testParams = @{
                    DisplayName = "displayName-value"
                    AzurePortalTimeOut = "02:00:00"
                    DefaultTimeOut = "03:00:00"
                    Id = "000000-0000-0000-0000-000000000000"
                    Ensure = "Absent"
                    Credential = $Credential;
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'AADActivityBasedTimeoutPolicy' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADActivityBasedTimeoutPolicy' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should Remove the group from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'AADActivityBasedTimeoutPolicy' -Property $testParams).Set()
                Should -Invoke -CommandName Remove-MgBetaPolicyActivityBasedTimeoutPolicy -Exactly 1
            }
        }
        Context -Name "The AADActivityBasedTimeoutPolicy Exists and Values are already in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    DisplayName = "displayName-value"
                    AzurePortalTimeOut = "02:00:00"
                    DefaultTimeOut = "04:00:00"
                    Id = "000000-0000-0000-0000-000000000000"
                    Ensure = "Present"
                    Credential = $Credential;
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADActivityBasedTimeoutPolicy' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name "The AADActivityBasedTimeoutPolicy exists and values are NOT in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    DisplayName = "displayName-value"
                    AzurePortalTimeOut = "02:00:00"
                    DefaultTimeOut = "03:00:00" # Drift
                    Id = "000000-0000-0000-0000-000000000000"
                    Ensure = "Present"
                    Credential = $Credential;
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'AADActivityBasedTimeoutPolicy' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADActivityBasedTimeoutPolicy' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'AADActivityBasedTimeoutPolicy' -Property $testParams).Set()
                Should -Invoke -CommandName Update-MgBetaPolicyActivityBasedTimeoutPolicy -Exactly 1
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
                $result = Invoke-M365DSCResourceMethod -ResourceName 'AADActivityBasedTimeoutPolicy' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
