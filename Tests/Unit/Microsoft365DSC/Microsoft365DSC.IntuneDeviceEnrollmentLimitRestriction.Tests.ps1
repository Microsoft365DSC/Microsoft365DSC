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
    -DscResource 'IntuneDeviceEnrollmentLimitRestriction' -GenericStubModule $GenericStubPath

Describe -Name $Global:DscHelper.DescribeHeader -Fixture {
    InModuleScope -ModuleName $Global:DscHelper.ModuleName -ScriptBlock {
        Invoke-Command -ScriptBlock $Global:DscHelper.InitializeScript -NoNewScope

        BeforeAll {
            $secpasswd = ConvertTo-SecureString ((New-Guid).ToString()) -AsPlainText -Force
            $Credential = New-Object System.Management.Automation.PSCredential ('tenantadmin@onmicrosoft.com', $secpasswd)

            Mock -ModuleName M365DSCUtil -CommandName Confirm-M365DSCDependencies -MockWith {
            }

            Mock -CommandName New-M365DSCConnection -ModuleName '_Shared' -MockWith {
                return 'Credentials'
            }

            Mock -CommandName Update-MgBetaDeviceManagementDeviceEnrollmentConfiguration -MockWith {
            }

            Mock -CommandName New-MgBetaDeviceManagementDeviceEnrollmentConfiguration -MockWith {
            }

            Mock -CommandName Remove-MgBetaDeviceManagementDeviceEnrollmentConfiguration -MockWith {
            }

            Mock -CommandName Update-DeviceConfigurationPolicyAssignment -MockWith {
            }

             Mock -CommandName Get-M365DSCExportCachedCollection -MockWith {
                 return Get-MgBetaDeviceManagementDeviceEnrollmentConfiguration
             }
             Mock -CommandName Get-MgBetaDeviceManagementDeviceEnrollmentConfiguration -MockWith {
                return @{
                    '@odata.type' = '#microsoft.graph.deviceEnrollmentLimitConfiguration'
                    Limit         = 15
                    Id                   = '12345-12345-12345-12345-12345_Limit'
                    Priority             = 1
                    DisplayName          = 'My DSC Restriction'
                }
            }

            Mock -CommandName Invoke-M365DSCGraphRequest -MockWith {
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstances =$null
            $Script:ExportMode = $false
        }

        # Test contexts
        Context -Name "When the restriction doesn't already exist" -Fixture {
            BeforeAll {
                $testParams = @{
                    Id          = '12345-12345-12345-12345-12345_Limit'
                    DisplayName = 'My DSC Restriction'
                    Ensure      = 'Present'
                    Credential  = $Credential
                    Priority    = 1
                    Limit       = 15
                }

                Mock -CommandName Get-MgBetaDeviceManagementDeviceEnrollmentConfiguration -MockWith {
                    return $null
                }

                Mock -CommandName New-MgBetaDeviceManagementDeviceEnrollmentConfiguration -MockWith {
                    return @{
                        '@odata.type' = '#microsoft.graph.deviceEnrollmentLimitConfiguration'
                        Limit         = 15
                        Id                   = '12345-12345-12345-12345-12345_Limit'
                        Priority             = 1
                        DisplayName          = 'My DSC Restriction';
                    }
                }
            }

            It 'Should return absent from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneDeviceEnrollmentLimitRestriction' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceEnrollmentLimitRestriction' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should create the restriction from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceEnrollmentLimitRestriction' -Property $testParams).Set()
                Should -Invoke -CommandName 'New-MgBetaDeviceManagementDeviceEnrollmentConfiguration' -Exactly 1
            }
        }

        Context -Name 'When the restriction already exists and is NOT in the Desired State' -Fixture {
            BeforeAll {
                $testParams = @{
                    Id          = '12345-12345-12345-12345-12345_Limit'
                    DisplayName = 'My DSC Restriction'
                    Ensure      = 'Present'
                    Credential  = $Credential
                    Limit       = 12 # Updated property
                    Priority    = 1
                }
            }

            It 'Should return Present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneDeviceEnrollmentLimitRestriction' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceEnrollmentLimitRestriction' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should update the restriction from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceEnrollmentLimitRestriction' -Property $testParams).Set()
                Should -Invoke -CommandName Update-MgBetaDeviceManagementDeviceEnrollmentConfiguration -Exactly 1
            }
        }

        Context -Name 'When the restriction already exists and IS in the Desired State' -Fixture {
            BeforeAll {
                $testParams = @{
                    Id          = '12345-12345-12345-12345-12345_Limit'
                    DisplayName = 'My DSC Restriction'
                    Ensure      = 'Present'
                    Credential  = $Credential
                    Limit       = 15
                    Priority    = 1
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceEnrollmentLimitRestriction' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name 'When the restriction exists and it SHOULD NOT' -Fixture {
            BeforeAll {
                $testParams = @{
                    DisplayName = 'My DSC Restriction'
                    Ensure      = 'Absent'
                    Credential  = $Credential
                    Id          = '12345-12345-12345-12345-12345_Limit'
                    Priority    = 1
                    Limit       = 15
                }
            }

            It 'Should return Present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneDeviceEnrollmentLimitRestriction' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceEnrollmentLimitRestriction' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should remove the restriction from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceEnrollmentLimitRestriction' -Property $testParams).Set()
                Should -Invoke -CommandName Remove-MgBetaDeviceManagementDeviceEnrollmentConfiguration -Exactly 1
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
                $result = Invoke-M365DSCResourceMethod -ResourceName 'IntuneDeviceEnrollmentLimitRestriction' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
