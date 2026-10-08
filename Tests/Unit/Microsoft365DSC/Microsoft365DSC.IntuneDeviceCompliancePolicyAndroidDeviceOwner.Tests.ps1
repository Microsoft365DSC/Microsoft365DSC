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
    -DscResource 'IntuneDeviceCompliancePolicyAndroidDeviceOwner' -GenericStubModule $GenericStubPath

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
                    DisplayName          = 'Test Android Device Owner Device Compliance Policy'
                    Description          = 'Test Android Device Owner Device Compliance Policy Description'
                    Id                   = '9c4e2ed7-706e-4874-a826-0c2778352d46'
                    ScheduledActionsForRule =@(
                        @{
                            ruleName = ''
                            scheduledActionConfigurations = @(
                                @{
                                    actionType = 'block'
                                    gracePeriodHours = 0
                                    notificationTemplateId = '00000000-0000-0000-0000-000000000000'
                                    notificationMessageCCList = @()
                                },
                                @{
                                    actionType = 'pushNotification'
                                    gracePeriodHours = 0
                                    notificationTemplateId = '00000000-0000-0000-0000-000000000000'
                                    notificationMessageCCList = @()
                                },
                                @{
                                    actionType = 'remoteLock'
                                    gracePeriodHours = 0
                                    notificationTemplateId = '00000000-0000-0000-0000-000000000000'
                                    notificationMessageCCList = @()
                                },
                                @{
                                    actionType = 'Notification'
                                    gracePeriodHours = 0
                                    notificationTemplateId = '00000000-0000-0000-0000-000000000001'
                                    notificationMessageCCList = @('00000000-0000-0000-0000-000000000001','00000000-0000-0000-0000-000000000002')
                                }
                            )
                            }
                        )
                    '@odata.type'                                      = '#microsoft.graph.androidDeviceOwnerCompliancePolicy'
                    PasswordMinimumLetterCharacters                    = 1
                    PasswordMinimumLowerCaseCharacters                 = 1
                    PasswordMinimumNonLetterCharacters                 = 1
                    PasswordMinimumNumericCharacters                   = 1
                    PasswordMinimumSymbolCharacters                    = 1
                    PasswordMinimumUpperCaseCharacters                 = 1
                    RequireNoPendingSystemUpdates                      = $true
                    DeviceThreatProtectionEnabled                      = $True
                    DeviceThreatProtectionRequiredSecurityLevel        = 'Unavailable'
                    AdvancedThreatProtectionRequiredSecurityLevel      = 'Unavailable'
                    SecurityRequireSafetyNetAttestationBasicIntegrity  = $True
                    SecurityRequireSafetyNetAttestationCertifiedDevice = $True
                    OsMinimumVersion                                   = 7
                    OsMaximumVersion                                   = 11
                    PasswordRequired                                   = $True
                    PasswordMinimumLength                              = 6
                    PasswordRequiredType                               = 'DeviceDefault'
                    PasswordMinutesOfInactivityBeforeLock              = 5
                    PasswordExpirationDays                             = 365
                    PasswordPreviousPasswordCountToBlock               = 10
                    StorageRequireEncryption                           = $True
                    SecurityRequireIntuneAppIntegrity                  = $True
                    RoleScopeTagIds                                    = '0'
                    minAndroidSecurityPatchLevel                       = '2024-01-24'
                    securityRequiredAndroidSafetyNetEvaluationType     = 'hardwareBacked'
                }
            }

            Mock -CommandName Get-MgBetaDeviceManagementNotificationMessageTemplate -MockWith {
                return @(
                    @{
                        Id = '00000000-0000-0000-0000-000000000001'
                        DisplayName = 'Test Template 1'
                    }
                )
            }

            Mock -CommandName Get-MgGroup -MockWith {
                return @(
                    @{
                        Id = '00000000-0000-0000-0000-000000000001'
                        DisplayName = 'Test Group 1'
                    }
                    @{
                        Id = '00000000-0000-0000-0000-000000000002'
                        DisplayName = 'Test Group 2'
                    }
                )
            }

            Mock -ModuleName M365DSCIntuneUtil -CommandName Get-MgGroup -MockWith {
                return @(
                    @{
                        Id = '00000000-0000-0000-0000-000000000001'
                        DisplayName = 'Test Group 1'
                    }
                    @{
                        Id = '00000000-0000-0000-0000-000000000002'
                        DisplayName = 'Test Group 2'
                    }
                )
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
        Context -Name "When the Android Device Owner Device Compliance Policy doesn't already exist" -Fixture {
            BeforeAll {
                $testParams = @{
                    DisplayName                                        = 'Test Android Device Owner Device Compliance Policy'
                    Description                                        = 'Test Android Device Owner Device Compliance Policy Description'
                    PasswordMinimumLetterCharacters                    = 1
                    PasswordMinimumLowerCaseCharacters                 = 1
                    PasswordMinimumNonLetterCharacters                 = 1
                    PasswordMinimumNumericCharacters                   = 1
                    PasswordMinimumSymbolCharacters                    = 1
                    PasswordMinimumUpperCaseCharacters                 = 1
                    RequireNoPendingSystemUpdates                      = $true
                    DeviceThreatProtectionEnabled                      = $True
                    DeviceThreatProtectionRequiredSecurityLevel        = 'Unavailable'
                    AdvancedThreatProtectionRequiredSecurityLevel      = 'Unavailable'
                    SecurityRequireSafetyNetAttestationBasicIntegrity  = $True
                    SecurityRequireSafetyNetAttestationCertifiedDevice = $True
                    OsMinimumVersion                                   = 7
                    OsMaximumVersion                                   = 11
                    PasswordRequired                                   = $True
                    PasswordMinimumLength                              = 6
                    PasswordRequiredType                               = 'DeviceDefault'
                    PasswordMinutesOfInactivityBeforeLock              = 5
                    PasswordExpirationDays                             = 365
                    PasswordPreviousPasswordCountToBlock               = 10
                    StorageRequireEncryption                           = $True
                    SecurityRequireIntuneAppIntegrity                  = $True
                    MinAndroidSecurityPatchLevel                       = '2024-01-24'
                    SecurityRequiredAndroidSafetyNetEvaluationType     = 'hardwareBacked'
                    Ensure                                             = 'Present'
                    Credential                                         = $Credential
                    ScheduledActionsForRule = @(
                        ([MSFT_ScheduledActionConfigurations] @{
                            actionType = 'block'
                            gracePeriodHours = 0
                        })
                        ([MSFT_ScheduledActionConfigurations] @{
                            actionType = 'pushNotification'
                            gracePeriodHours = 0
                        })
                        ([MSFT_ScheduledActionConfigurations] @{
                            actionType = 'remoteLock'
                            gracePeriodHours = 0
                        })
                        ([MSFT_ScheduledActionConfigurations] @{
                            actionType = 'Notification'
                            gracePeriodHours = 0
                            notificationTemplateId = 'Test Template 1'
                            notificationMessageCCList = @('Test Group 1','Test Group 2')
                        })
                    )
                }

                Mock -CommandName Get-MgBetaDeviceManagementDeviceCompliancePolicy -MockWith {
                    return $null
                }
            }

            It 'Should return absent from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneDeviceCompliancePolicyAndroidDeviceOwner' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceCompliancePolicyAndroidDeviceOwner' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should create the Android Device Compliance Policy from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceCompliancePolicyAndroidDeviceOwner' -Property $testParams).Set()
                Should -Invoke -CommandName 'New-MgBetaDeviceManagementDeviceCompliancePolicy' -Exactly 1
            }
        }

        Context -Name 'When the Android Device Owner Device Compliance Policy already exists and is NOT in the Desired State' -Fixture {
            BeforeAll {
                $testParams = @{
                    DisplayName                                        = 'Test Android Device Owner Device Compliance Policy'
                    Description                                        = 'Test Android Device Owner Device Compliance Policy Description'
                    PasswordMinimumLetterCharacters                    = 1
                    PasswordMinimumLowerCaseCharacters                 = 1
                    PasswordMinimumNonLetterCharacters                 = 1
                    PasswordMinimumNumericCharacters                   = 1
                    PasswordMinimumSymbolCharacters                    = 1
                    PasswordMinimumUpperCaseCharacters                 = 1
                    RequireNoPendingSystemUpdates                      = $true
                    DeviceThreatProtectionEnabled                      = $True
                    DeviceThreatProtectionRequiredSecurityLevel        = 'Unavailable'
                    AdvancedThreatProtectionRequiredSecurityLevel      = 'Unavailable'
                    SecurityRequireSafetyNetAttestationBasicIntegrity  = $True
                    SecurityRequireSafetyNetAttestationCertifiedDevice = $True
                    OsMinimumVersion                                   = 7
                    OsMaximumVersion                                   = 11
                    PasswordRequired                                   = $True
                    PasswordMinimumLength                              = 6
                    PasswordRequiredType                               = 'DeviceDefault'
                    PasswordMinutesOfInactivityBeforeLock              = 5
                    PasswordExpirationDays                             = 365
                    PasswordPreviousPasswordCountToBlock               = 10
                    StorageRequireEncryption                           = $True
                    SecurityRequireIntuneAppIntegrity                  = $True
                    minAndroidSecurityPatchLevel                       = '2024-01-24'
                    securityRequiredAndroidSafetyNetEvaluationType     = 'hardwareBacked'
                    Ensure                                             = 'Present'
                    Credential                                         = $Credential
                    ScheduledActionsForRule = @(
                        ([MSFT_ScheduledActionConfigurations] @{
                            actionType = 'block'
                            gracePeriodHours = 1 # Updated property
                        })
                        ([MSFT_ScheduledActionConfigurations] @{
                            actionType = 'pushNotification'
                            gracePeriodHours = 0
                        })
                        ([MSFT_ScheduledActionConfigurations] @{
                            actionType = 'remoteLock'
                            gracePeriodHours = 0
                        })
                        ([MSFT_ScheduledActionConfigurations] @{
                            actionType = 'Notification'
                            gracePeriodHours = 0
                            notificationTemplateId = 'Test Template 1'
                            notificationMessageCCList = @('Test Group 1','Test Group 2')
                        })
                    )
                }
            }

            It 'Should return Present from the Get method' {
                    ((New-M365DSCResourceInstance -ResourceName 'IntuneDeviceCompliancePolicyAndroidDeviceOwner' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceCompliancePolicyAndroidDeviceOwner' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should update the Android Device Owner Device Compliance Policy from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceCompliancePolicyAndroidDeviceOwner' -Property $testParams).Set()
                Should -Invoke -CommandName Update-MgBetaDeviceManagementDeviceCompliancePolicy -Exactly 1
            }
        }

        Context -Name 'When the policy already exists and IS in the Desired State' -Fixture {
            BeforeAll {
                $testParams = @{
                    DisplayName                                        = 'Test Android Device Owner Device Compliance Policy'
                    Description                                        = 'Test Android Device Owner Device Compliance Policy Description'
                    PasswordMinimumLetterCharacters                    = 1
                    PasswordMinimumLowerCaseCharacters                 = 1
                    PasswordMinimumNonLetterCharacters                 = 1
                    PasswordMinimumNumericCharacters                   = 1
                    PasswordMinimumSymbolCharacters                    = 1
                    PasswordMinimumUpperCaseCharacters                 = 1
                    RequireNoPendingSystemUpdates                      = $true
                    DeviceThreatProtectionEnabled                      = $True
                    DeviceThreatProtectionRequiredSecurityLevel        = 'Unavailable'
                    AdvancedThreatProtectionRequiredSecurityLevel      = 'Unavailable'
                    SecurityRequireSafetyNetAttestationBasicIntegrity  = $True
                    SecurityRequireSafetyNetAttestationCertifiedDevice = $True
                    OsMinimumVersion                                   = 7
                    OsMaximumVersion                                   = 11
                    PasswordRequired                                   = $True
                    PasswordMinimumLength                              = 6
                    PasswordRequiredType                               = 'DeviceDefault'
                    PasswordMinutesOfInactivityBeforeLock              = 5
                    PasswordExpirationDays                             = 365
                    PasswordPreviousPasswordCountToBlock               = 10
                    StorageRequireEncryption                           = $True
                    SecurityRequireIntuneAppIntegrity                  = $True
                    Ensure                                             = 'Present'
                    minAndroidSecurityPatchLevel                       = '2024-01-24'
                    securityRequiredAndroidSafetyNetEvaluationType     = 'hardwareBacked'
                    Credential                                         = $Credential
                    ScheduledActionsForRule = @(
                        ([MSFT_ScheduledActionConfigurations] @{
                            actionType = 'block'
                            gracePeriodHours = 0
                        })
                        ([MSFT_ScheduledActionConfigurations] @{
                            actionType = 'pushNotification'
                            gracePeriodHours = 0
                        })
                        ([MSFT_ScheduledActionConfigurations] @{
                            actionType = 'remoteLock'
                            gracePeriodHours = 0
                        })
                        ([MSFT_ScheduledActionConfigurations] @{
                            actionType = 'Notification'
                            gracePeriodHours = 0
                            notificationTemplateId = 'Test Template 1'
                            notificationMessageCCList = @('Test Group 1','Test Group 2')
                        })
                    )
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceCompliancePolicyAndroidDeviceOwner' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name 'When the policy exists and it SHOULD NOT' -Fixture {
            BeforeAll {
                $testParams = @{
                    DisplayName = 'Test Android Device Owner Device Compliance Policy'
                    Ensure      = 'Absent'
                    Credential  = $Credential
                }
            }

            It 'Should return Present from the Get method' {
                    ((New-M365DSCResourceInstance -ResourceName 'IntuneDeviceCompliancePolicyAndroidDeviceOwner' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceCompliancePolicyAndroidDeviceOwner' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should remove the Android Device Owner Device Compliance Policy from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceCompliancePolicyAndroidDeviceOwner' -Property $testParams).Set()
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
                $result = Invoke-M365DSCResourceMethod -ResourceName 'IntuneDeviceCompliancePolicyAndroidDeviceOwner' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
