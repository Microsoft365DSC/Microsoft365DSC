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
    -DscResource 'IntuneDeviceCompliancePolicyiOs' -GenericStubModule $GenericStubPath
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

            Mock -CommandName Update-MgBetaDeviceManagementDeviceCompliancePolicy -MockWith {
            }

            Mock -CommandName New-MgBetaDeviceManagementDeviceCompliancePolicy -MockWith {
            }

            Mock -CommandName Remove-MgBetaDeviceManagementDeviceCompliancePolicy -MockWith {
            }

            Mock -CommandName Get-M365DSCExportCachedCollection -MockWith {
                return Get-MgBetaDeviceManagementDeviceCompliancePolicy
            }
            Mock -CommandName Get-MgBetaDeviceManagementDeviceCompliancePolicy -MockWith {
                return @{
                    DisplayName          = 'Test iOS Device Compliance Policy'
                    Description          = 'Test iOS Device Compliance Policy Description'
                    Id                   = '9c4e2ed7-706e-4874-a826-0c2778352d45'
                    PasscodeBlockSimple                         = $True
                    PasscodeExpirationDays                      = 365
                    PasscodeMinimumLength                       = 6
                    PasscodeMinutesOfInactivityBeforeLock       = 5
                    PasscodePreviousPasscodeBlockCount          = 3
                    PasscodeMinimumCharacterSetCount            = 2
                    PasscodeRequiredType                        = 'numeric'
                    PasscodeRequired                            = $True
                    OsMinimumVersion                            = 10
                    OsMaximumVersion                            = 12
                    SecurityBlockJailbrokenDevices              = $True
                    DeviceThreatProtectionEnabled               = $True
                    DeviceThreatProtectionRequiredSecurityLevel = 'medium'
                    ManagedEmailProfileRequired                 = $True
                    RoleScopeTagIds                             = '0'
                    '@odata.type'                               = '#microsoft.graph.iosCompliancePolicy'
                }
            }

            Mock -CommandName Get-MgBetaDeviceManagementDeviceCompliancePolicyAssignment -MockWith {
                return @()
            }
            Mock -CommandName Update-DeviceConfigurationPolicyAssignment -MockWith {
            }
            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstances =$null
            $Script:ExportMode = $false
        }

        # Test contexts
        Context -Name "When the iOS Device Compliance Policy doesn't already exist" -Fixture {
            BeforeAll {
                $testParams = @{
                    DisplayName                                 = 'Test iOS Device Compliance Policy'
                    Description                                 = 'Test iOS Device Compliance Policy Description'
                    PasscodeBlockSimple                         = $True
                    PasscodeExpirationDays                      = 365
                    PasscodeMinimumLength                       = 6
                    PasscodeMinutesOfInactivityBeforeLock       = 5
                    PasscodePreviousPasscodeBlockCount          = 3
                    PasscodeMinimumCharacterSetCount            = 2
                    PasscodeRequiredType                        = 'numeric'
                    PasscodeRequired                            = $True
                    OsMinimumVersion                            = 10
                    OsMaximumVersion                            = 12
                    SecurityBlockJailbrokenDevices              = $True
                    DeviceThreatProtectionEnabled               = $True
                    DeviceThreatProtectionRequiredSecurityLevel = 'medium'
                    ManagedEmailProfileRequired                 = $True
                    Ensure                                      = 'Present'
                    Credential                                  = $Credential
                }

                Mock -CommandName Get-MgBetaDeviceManagementDeviceCompliancePolicy -MockWith {
                    return $null
                }
            }

            It 'Should return absent from the Get method' {
                    ((New-M365DSCResourceInstance -ResourceName 'IntuneDeviceCompliancePolicyiOs' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceCompliancePolicyiOs' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should create the iOS Device Compliance Policy from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceCompliancePolicyiOs' -Property $testParams).Set()
                Should -Invoke -CommandName 'New-MgBetaDeviceManagementDeviceCompliancePolicy' -Exactly 1
            }
        }

        Context -Name 'When the iOS Device Compliance Policy already exists and is NOT in the Desired State' -Fixture {
            BeforeAll {
                $testParams = @{
                    DisplayName                                 = 'Test iOS Device Compliance Policy'
                    Description                                 = 'Test iOS Device Compliance Policy Description'
                    PasscodeBlockSimple                         = $True
                    PasscodeExpirationDays                      = 365
                    PasscodeMinimumLength                       = 6
                    PasscodeMinutesOfInactivityBeforeLock       = 5
                    PasscodePreviousPasscodeBlockCount          = 3
                    PasscodeMinimumCharacterSetCount            = 2
                    PasscodeRequiredType                        = 'numeric'
                    PasscodeRequired                            = $True
                    OsMinimumVersion                            = 11 # Updated property
                    OsMaximumVersion                            = 12
                    SecurityBlockJailbrokenDevices              = $True
                    DeviceThreatProtectionEnabled               = $True
                    DeviceThreatProtectionRequiredSecurityLevel = 'medium'
                    ManagedEmailProfileRequired                 = $True
                    Ensure                                      = 'Present'
                    Credential                                  = $Credential
                }
            }

            It 'Should return Present from the Get method' {
                    ((New-M365DSCResourceInstance -ResourceName 'IntuneDeviceCompliancePolicyiOs' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceCompliancePolicyiOs' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should update the iOS Device Compliance Policy from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceCompliancePolicyiOs' -Property $testParams).Set()
                Should -Invoke -CommandName Update-MgBetaDeviceManagementDeviceCompliancePolicy -Exactly 1
            }
        }

        Context -Name 'When the policy already exists and IS in the Desired State' -Fixture {
            BeforeAll {
                $testParams = @{
                    DisplayName                                 = 'Test iOS Device Compliance Policy'
                    Description                                 = 'Test iOS Device Compliance Policy Description'
                    PasscodeBlockSimple                         = $True
                    PasscodeExpirationDays                      = 365
                    PasscodeMinimumLength                       = 6
                    PasscodeMinutesOfInactivityBeforeLock       = 5
                    PasscodePreviousPasscodeBlockCount          = 3
                    PasscodeMinimumCharacterSetCount            = 2
                    PasscodeRequiredType                        = 'numeric'
                    PasscodeRequired                            = $True
                    OsMinimumVersion                            = 10
                    OsMaximumVersion                            = 12
                    SecurityBlockJailbrokenDevices              = $True
                    DeviceThreatProtectionEnabled               = $True
                    DeviceThreatProtectionRequiredSecurityLevel = 'medium'
                    ManagedEmailProfileRequired                 = $True
                    Ensure                                      = 'Present'
                    Credential                                  = $Credential
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceCompliancePolicyiOs' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name 'When the policy exists and it SHOULD NOT' -Fixture {
            BeforeAll {
                $testParams = @{
                    DisplayName                                 = 'Test iOS Device Compliance Policy'
                    Description                                 = 'Test iOS Device Compliance Policy Description'
                    PasscodeBlockSimple                         = $True
                    PasscodeExpirationDays                      = 365
                    PasscodeMinimumLength                       = 6
                    PasscodeMinutesOfInactivityBeforeLock       = 5
                    PasscodePreviousPasscodeBlockCount          = 3
                    PasscodeMinimumCharacterSetCount            = 2
                    PasscodeRequiredType                        = 'numeric'
                    PasscodeRequired                            = $True
                    OsMinimumVersion                            = 10
                    OsMaximumVersion                            = 12
                    SecurityBlockJailbrokenDevices              = $True
                    DeviceThreatProtectionEnabled               = $True
                    DeviceThreatProtectionRequiredSecurityLevel = 'medium'
                    ManagedEmailProfileRequired                 = $True
                    Ensure                                      = 'Absent'
                    Credential                                  = $Credential
                }
            }

            It 'Should return Present from the Get method' {
                    ((New-M365DSCResourceInstance -ResourceName 'IntuneDeviceCompliancePolicyiOs' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceCompliancePolicyiOs' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should remove the iOS Device Compliance Policy from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceCompliancePolicyiOs' -Property $testParams).Set()
                Should -Invoke -CommandName Remove-MgBetaDeviceManagementDeviceCompliancePolicy -Exactly 1
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
                $result = Invoke-M365DSCResourceMethod -ResourceName 'IntuneDeviceCompliancePolicyiOs' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
