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
    -DscResource 'IntuneAppProtectionPolicyAndroid' -GenericStubModule $GenericStubPath

Describe -Name $Global:DscHelper.DescribeHeader -Fixture {
    InModuleScope -ModuleName $Global:DscHelper.ModuleName -ScriptBlock {
        Invoke-Command -ScriptBlock $Global:DscHelper.InitializeScript -NoNewScope

        BeforeAll {
            $secpasswd = ConvertTo-SecureString ((New-Guid).ToString()) -AsPlainText -Force
            $Credential = New-Object System.Management.Automation.PSCredential ('tenantadmin@onmicrosoft.com', $secpasswd)

            function Get-DefaultTestParams
            {
                param (
                    [string]$description
                )
                return @{
                    AllowedAndroidDeviceManufacturers                 = 'Samsung;Google'
                    AllowedAndroidDeviceModels                        = @('Model1', 'Model2')
                    AllowedOutboundClipboardSharingExceptionLength    = 4
                    AllowedDataIngestionLocations                     = @('OneDrive', 'SharePoint')
                    AppActionIfAccountIsClockedOut                    = 'warn'
                    AppActionIfAndroidDeviceManufacturerNotAllowed    = 'block'
                    AppActionIfAndroidDeviceModelNotAllowed           = 'block'
                    AppActionIfAndroidSafetyNetAppsVerificationFailed = 'warn'
                    AppActionIfAndroidSafetyNetDeviceAttestationFailed = 'block'
                    AppActionIfDeviceComplianceRequired               = 'block'
                    AppActionIfDeviceLockNotSet                       = 'block'
                    AppActionIfDevicePasscodeComplexityLessThanHigh   = 'warn'
                    AppActionIfDevicePasscodeComplexityLessThanLow    = 'block'
                    AppActionIfDevicePasscodeComplexityLessThanMedium = 'warn'
                    AppActionIfMaximumPinRetriesExceeded              = 'wipe'
                    AppActionIfSamsungKnoxAttestationRequired         = 'warn'
                    AppActionIfUnableToAuthenticateUser               = 'block'
                    ApprovedKeyboards                                 = @('fake|string')
                    BiometricAuthenticationBlocked                    = $True
                    BlockAfterCompanyPortalUpdateDeferralInDays       = 7
                    BlockDataIngestionIntoOrganizationDocuments       = $False
                    ConnectToVpnOnLaunch                              = $True
                    CustomDialerAppDisplayName                        = 'MyDialerApp'
                    CustomDialerAppPackageId                          = 'com.example.dialer'
                    DeviceLockRequired                                = $True
                    DialerRestrictionLevel                            = 'managedApps'
                    ExemptedAppPackages                               = @('fake|string')
                    FingerprintAndBiometricEnabled                    = $True
                    GracePeriodToBlockAppsDuringOffClockHours         = 'PT1H'
                    KeyboardsRestricted                               = $True
                    MaximumAllowedDeviceThreatLevel                   = 'medium'
                    MaximumRequiredOsVersion                          = '15.0'
                    MaximumWarningOsVersion                           = '15.0'
                    MaximumWipeOsVersion                              = '16.0'
                    MessagingRedirectAppDisplayName                   = 'MessageApp'
                    MessagingRedirectAppPackageId                     = 'com.example.messageapp'
                    MinimumWipeAppVersion                             = '1.0'
                    MinimumWipeCompanyPortalVersion                   = '5.0.5333.0'
                    MinimumWipeOsVersion                              = '1.1'
                    MinimumWipePatchVersion                           = '2023-01-01'
                    MobileThreatDefensePartnerPriority                = 'defenderOverThirdPartyPartner'
                    MobileThreatDefenseRemediationAction              = 'block'
                    NotificationRestriction                           = 'block'
                    PinRequiredInsteadOfBiometricTimeout              = 'PT30M'
                    PreviousPinBlockCount                             = 4
                    ProtectedMessagingRedirectAppType                 = 'specificApps'
                    PurviewContentEvaluationRequired                  = 'requiredWhenOnline'
                    RequiredAndroidSafetyNetAppsVerificationType      = 'enabled'
                    RequiredAndroidSafetyNetDeviceAttestationType     = 'basicIntegrity'
                    RequiredAndroidSafetyNetEvaluationType            = 'hardwareBacked'
                    TargetedAppManagementLevels                       = 'mdm'
                    WarnAfterCompanyPortalUpdateDeferralInDays        = 14
                    WipeAfterCompanyPortalUpdateDeferralInDays        = 90
                    AllowedDataStorageLocations                     = @('sharePoint')
                    AllowedInboundDataTransferSources               = 'managedApps'
                    AllowedOutboundClipboardSharingLevel            = 'managedAppsWithPasteIn'
                    AllowedOutboundDataTransferDestinations         = 'managedApps'
                    AppGroupType                                    = 'selectedPublicApps'
                    Apps                                            = @('com.cisco.im.intune', 'com.penlink.penpoint', 'com.slack.intune')
                    Assignments                                     = @(
                        [MSFT_DeviceManagementConfigurationPolicyAssignments] @{
                            groupId  = '6ee86c9f-2b3c-471d-ad38-ff4673ed723e'
                            dataType = '#microsoft.graph.groupAssignmentTarget'
                            deviceAndAppManagementAssignmentFilterType = 'none'
                        }
                        [MSFT_DeviceManagementConfigurationPolicyAssignments] @{
                            groupId  = '3eacc231-d77b-4efb-bb5f-310f68bd6198'
                            dataType = '#microsoft.graph.exclusionGroupAssignmentTarget'
                            deviceAndAppManagementAssignmentFilterType = 'none'
                        }
                    )
                    ContactSyncBlocked                              = $False
                    DataBackupBlocked                               = $False
                    Description                                     = 'DSC Policy'
                    DeviceComplianceRequired                        = $True
                    DisableAppEncryptionIfDeviceEncryptionIsEnabled = $True
                    EncryptAppData                                  = $True
                    DisplayName                                     = 'DSC Policy'
                    Ensure                                          = 'Present'
                    FingerprintBlocked                              = $False
                    Credential                                      = $Credential
                    ManagedBrowserToOpenLinksRequired               = $True
                    MaximumPinRetries                               = 5
                    MinimumPinLength                                = 4
                    OrganizationalCredentialsRequired               = $False
                    PeriodBeforePinReset                            = 'P60D'
                    PeriodOfflineBeforeAccessCheck                  = 'PT12H'
                    PeriodOfflineBeforeWipeIsEnforced               = 'P90D'
                    PeriodOnlineBeforeAccessCheck                   = 'PT30M'
                    PinCharacterSet                                 = 'alphanumericAndSymbol'
                    PinRequired                                     = $True
                    DisableAppPinIfDevicePinIsSet                   = $False
                    PrintBlocked                                    = $False
                    RequireClass3Biometrics                         = $False
                    RequirePinAfterBiometricChange                  = $False
                    SaveAsBlocked                                   = $True
                    SimplePinBlocked                                = $False
                    ScreenCaptureBlocked                            = $False
                    ManagedBrowser                                  = 'microsoftEdge'
                    MinimumRequiredAppVersion                       = '1.2'
                    MinimumRequiredCompanyPortalVersion             = '5.0.5484.0'
                    MinimumRequiredOsVersion                        = '1.1'
                    MinimumRequiredPatchVersion                     = '2020-07-13'
                    MinimumWarningAppVersion                        = '1.5'
                    MinimumWarningCompanyPortalVersion              = '5.0.5545.0'
                    MinimumWarningOsVersion                         = '1.5'
                    MinimumWarningPatchVersion                      = '2021-07-13'
                    CustomBrowserPackageId                          = ''
                    CustomBrowserDisplayName                        = ''
                    id                                              = '12345-12345-12345-12345-12345'
                }

            }

            function Get-DefaultReturnObj
            {
                param (
                    [string]$description
                )
                return @{
                    AllowedAndroidDeviceManufacturers                 = 'Samsung;Google'
                    AllowedAndroidDeviceModels                        = @('Model1', 'Model2')
                    AllowedOutboundClipboardSharingExceptionLength    = 4
                    AllowedDataIngestionLocations                     = @('OneDrive', 'SharePoint')
                    AppActionIfAccountIsClockedOut                    = 'warn'
                    AppActionIfAndroidDeviceManufacturerNotAllowed    = 'block'
                    AppActionIfAndroidDeviceModelNotAllowed           = 'block'
                    AppActionIfAndroidSafetyNetAppsVerificationFailed = 'warn'
                    AppActionIfAndroidSafetyNetDeviceAttestationFailed = 'block'
                    AppActionIfDeviceComplianceRequired               = 'block'
                    AppActionIfDeviceLockNotSet                       = 'block'
                    AppActionIfDevicePasscodeComplexityLessThanHigh   = 'warn'
                    AppActionIfDevicePasscodeComplexityLessThanLow    = 'block'
                    AppActionIfDevicePasscodeComplexityLessThanMedium = 'warn'
                    AppActionIfMaximumPinRetriesExceeded              = 'wipe'
                    AppActionIfSamsungKnoxAttestationRequired         = 'warn'
                    AppActionIfUnableToAuthenticateUser               = 'block'
                    ApprovedKeyboards                                 = @(
                        [pscustomobject]@{
                            name  = 'fake'
                            value = 'string'
                        }
                    )
                    BiometricAuthenticationBlocked                    = $True
                    BlockAfterCompanyPortalUpdateDeferralInDays       = 7
                    BlockDataIngestionIntoOrganizationDocuments       = $False
                    ConnectToVpnOnLaunch                              = $True
                    CustomDialerAppDisplayName                        = 'MyDialerApp'
                    CustomDialerAppPackageId                          = 'com.example.dialer'
                    DeviceLockRequired                                = $True
                    DialerRestrictionLevel                            = 'managedApps'
                    ExemptedAppPackages                               = @(
                            [pscustomobject]@{
                            name  = 'fake'
                            value = 'string'
                            }
                    )
                    FingerprintAndBiometricEnabled                    = $True
                    GracePeriodToBlockAppsDuringOffClockHours         = 'PT1H'
                    KeyboardsRestricted                               = $True
                    MaximumAllowedDeviceThreatLevel                   = 'medium'
                    MaximumRequiredOsVersion                          = '15.0'
                    MaximumWarningOsVersion                           = '15.0'
                    MaximumWipeOsVersion                              = '16.0'
                    MessagingRedirectAppDisplayName                   = 'MessageApp'
                    MessagingRedirectAppPackageId                     = 'com.example.messageapp'
                    MinimumWipeAppVersion                             = '1.0'
                    MinimumWipeCompanyPortalVersion                   = '5.0.5333.0'
                    MinimumWipeOsVersion                              = '1.1'
                    MinimumWipePatchVersion                           = '2023-01-01'
                    MobileThreatDefensePartnerPriority                = 'defenderOverThirdPartyPartner'
                    MobileThreatDefenseRemediationAction              = 'block'
                    NotificationRestriction                           = 'block'
                    PinRequiredInsteadOfBiometricTimeout              = 'PT30M'
                    PreviousPinBlockCount                             = 4
                    ProtectedMessagingRedirectAppType                 = 'specificApps'
                    PurviewContentEvaluationRequired                  = 'requiredWhenOnline'
                    RequiredAndroidSafetyNetAppsVerificationType      = 'enabled'
                    RequiredAndroidSafetyNetDeviceAttestationType     = 'basicIntegrity'
                    RequiredAndroidSafetyNetEvaluationType            = 'hardwareBacked'
                    TargetedAppManagementLevels                       = 'mdm'
                    WarnAfterCompanyPortalUpdateDeferralInDays        = 14
                    WipeAfterCompanyPortalUpdateDeferralInDays        = 90
                    displayName                                     = 'DSC Policy'
                    id                                              = '12345-12345-12345-12345-12345'
                    '@odata.type'                                   = '#microsoft.graph.androidManagedAppProtection'
                    AllowedDataStorageLocations                     = @('sharePoint')
                    AllowedInboundDataTransferSources               = 'managedApps'
                    AllowedOutboundClipboardSharingLevel            = 'managedAppsWithPasteIn'
                    AllowedOutboundDataTransferDestinations         = 'managedApps'
                    AppGroupType                                    = 'selectedPublicApps'
                    ContactSyncBlocked                              = $False
                    DataBackupBlocked                               = $False
                    Description                                     = 'DSC Policy'
                    DeviceComplianceRequired                        = $True
                    DisableAppEncryptionIfDeviceEncryptionIsEnabled = $true
                    EncryptAppData                                  = $True
                    FingerprintBlocked                              = $False
                    ManagedBrowserToOpenLinksRequired               = $True
                    MaximumPinRetries                               = 5
                    MinimumPinLength                                = 4
                    OrganizationalCredentialsRequired               = $False
                    PeriodBeforePinReset                            = 'P60D'
                    PeriodOfflineBeforeAccessCheck                  = 'PT12H'
                    PeriodOfflineBeforeWipeIsEnforced               = 'P90D'
                    PeriodOnlineBeforeAccessCheck                   = 'PT30M'
                    PinCharacterSet                                 = 'alphanumericAndSymbol'
                    PinRequired                                     = $True
                    DisableAppPinIfDevicePinIsSet                   = $False
                    PrintBlocked                                    = $False
                    RequireClass3Biometrics                         = $False
                    RequirePinAfterBiometricChange                  = $False
                    SaveAsBlocked                                   = $True
                    SimplePinBlocked                                = $False
                    ScreenCaptureBlocked                            = $False
                    ManagedBrowser                                  = 'microsoftEdge'
                    MinimumRequiredAppVersion                       = '1.2'
                    MinimumRequiredCompanyPortalVersion             = '5.0.5484.0'
                    MinimumRequiredOsVersion                        = '1.1'
                    MinimumRequiredPatchVersion                     = '2020-07-13'
                    MinimumWarningAppVersion                        = '1.5'
                    MinimumWarningCompanyPortalVersion              = '5.0.5545.0'
                    MinimumWarningOsVersion                         = '1.5'
                    MinimumWarningPatchVersion                      = '2021-07-13'
                    IsAssigned                                      = $True
                    CustomBrowserPackageId                          = ''
                    CustomBrowserDisplayName                        = ''
                }
            }

            Mock -CommandName Update-DeviceConfigurationPolicyAssignment -MockWith {
            }

            Mock -CommandName Get-MgBetaDeviceAppManagementManagedAppStatus -MockWith {
                return @(
                    @{
                        '@odata.type' = '#microsoft.graph.managedAppStatusRaw'
                        id = 'managedAppList'
                        displayName = 'Managed App collection for Tenant'
                        content = @{
                            '@odata.type' = '#microsoft.graph.managedAppList'
                            appList = @(
                                @{
                                    appGroups = 'none'
                                    appIdentifier = @{
                                        '@odata.type' = '#microsoft.graph.androidMobileAppIdentifier'
                                        bundleId = 'com.cisco.im.intune'
                                    }
                                }
                                @{
                                    appGroups = 'none'
                                    appIdentifier = @{
                                        '@odata.type' = '#microsoft.graph.androidMobileAppIdentifier'
                                        bundleId = 'com.penlink.penpoint'
                                    }
                                }
                                @{
                                    appGroups = 'none'
                                    appIdentifier = @{
                                        '@odata.type' = '#microsoft.graph.androidMobileAppIdentifier'
                                        bundleId = 'com.slack.intune'
                                    }
                                }
                            )
                        }
                    }
                )
            }

            Mock -CommandName Get-MgBetaDeviceAppManagementAndroidManagedAppProtectionApp -MockWith {
                [pscustomobject]@{
                    id                  = 'com.cisco.im.intune.android'
                    mobileAppIdentifier = @{
                        '@odata.type' = '#microsoft.graph.androidMobileAppIdentifier'
                        'packageid'   = 'com.cisco.im.intune'
                    }
                },
                [pscustomobject]@{
                    id                  = 'com.penlink.penpoint.android'
                    mobileAppIdentifier = @{
                        '@odata.type' = '#microsoft.graph.androidMobileAppIdentifier'
                        packageid   = 'com.penlink.penpoint'
                    }
                },
                [pscustomobject]@{
                    id                  = 'com.slack.intune.android'
                    mobileAppIdentifier = @{
                        '@odata.type' = '#microsoft.graph.androidMobileAppIdentifier'
                        packageid   = 'com.slack.intune'
                    }
                }
            }

            Mock -CommandName Get-MgBetaDeviceAppManagementAndroidManagedAppProtectionAssignment -MockWith {
                return @(
                    @{
                        id     = '6ee86c9f-2b3c-471d-ad38-ff4673ed723e'
                        target = @{
                            '@odata.type' = '#microsoft.graph.groupAssignmentTarget'
                            groupId       = '6ee86c9f-2b3c-471d-ad38-ff4673ed723e'
                        }
                        source = 'direct'
                    },
                    @{
                        id     = '3eacc231-d77b-4efb-bb5f-310f68bd6198'
                        target = @{
                            '@odata.type' = '#microsoft.graph.exclusionGroupAssignmentTarget'
                            groupId       = '3eacc231-d77b-4efb-bb5f-310f68bd6198'
                        }
                        source = 'direct'
                    }
                )
            }

            Mock -ModuleName M365DSCUtil -CommandName Confirm-M365DSCDependencies -MockWith {
            }

            Mock -CommandName New-M365DSCConnection -ModuleName '_Shared' -MockWith {
                return 'Credentials'
            }

            Mock -CommandName New-MgBetaDeviceAppManagementAndroidManagedAppProtection -MockWith {
            }

            Mock -CommandName Update-MgBetaDeviceAppManagementAndroidManagedAppProtection -MockWith {
            }

            Mock -CommandName Invoke-MgBetaTargetDeviceAppManagementTargetedManagedAppConfigurationApp -MockWith {
            }

            Mock -CommandName Set-MgBetaDeviceAppManagementTargetedManagedAppConfiguration -MockWith {
            }

            Mock -CommandName Remove-MgBetaDeviceAppManagementAndroidManagedAppProtection -MockWith {
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
        Context -Name "When the Policy doesn't already exist" -Fixture {
            BeforeAll {
                $testParams = Get-DefaultTestParams
                $Global:Count = 0
                Mock -CommandName Get-MgBetaDeviceAppManagementAndroidManagedAppProtection -MockWith {
                    if ($Global:Count -le 1)
                    {
                        $Global:Count++
                        return $null
                    }
                    else
                    {
                        return Get-DefaultReturnObj
                    }
                }
                Mock -CommandName New-MgBetaDeviceAppManagementAndroidManagedAppProtection -MockWith {
                    return Get-DefaultReturnObj
                }
            }

            It 'Should return absent from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneAppProtectionPolicyAndroid' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }

            It 'Should return false from the Test method' {
                $Global:Count = 0
                (New-M365DSCResourceInstance -ResourceName 'IntuneAppProtectionPolicyAndroid' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should create the Policy from the Set method' {
                $Global:Count = 0
                (New-M365DSCResourceInstance -ResourceName 'IntuneAppProtectionPolicyAndroid' -Property $testParams).Set()
                Should -Invoke -CommandName 'New-MgBetaDeviceAppManagementAndroidManagedAppProtection' -Exactly 1
            }
        }

        Context -Name 'When the policy already exists and is NOT in the Desired State' -Fixture {
            BeforeAll {
                $testParams = Get-DefaultTestParams
                $testParams.FingerprintBlocked = $true #Drift


                Mock -CommandName Get-MgBetaDeviceAppManagementAndroidManagedAppProtection -MockWith {
                    return Get-DefaultReturnObj
                }
            }

            It 'Should return Present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneAppProtectionPolicyAndroid' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneAppProtectionPolicyAndroid' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should update the App Configuration Policy from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneAppProtectionPolicyAndroid' -Property $testParams).Set()
                Should -Invoke -CommandName Update-MgBetaDeviceAppManagementAndroidManagedAppProtection -Exactly 1
            }
        }

        Context -Name 'When the policy already exists and IS in the Desired State' -Fixture {
            BeforeAll {
                $testParams = Get-DefaultTestParams

                Mock -CommandName Get-MgBetaDeviceAppManagementAndroidManagedAppProtection -MockWith {
                    return Get-DefaultReturnObj
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneAppProtectionPolicyAndroid' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name 'When the policy exists and it SHOULD NOT' -Fixture {
            BeforeAll {
                $testParams = Get-DefaultTestParams
                $testParams.Ensure = 'Absent'

                Mock -CommandName Get-MgBetaDeviceAppManagementAndroidManagedAppProtection -MockWith {
                    return Get-DefaultReturnObj
                }
            }

            It 'Should return Present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneAppProtectionPolicyAndroid' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneAppProtectionPolicyAndroid' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should remove the App Configuration Policy from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneAppProtectionPolicyAndroid' -Property $testParams).Set()
                Should -Invoke -CommandName Remove-MgBetaDeviceAppManagementAndroidManagedAppProtection -Exactly 1
            }
        }

        Context -Name 'ReverseDSC Tests' -Fixture {
            BeforeAll {
                $Global:CurrentModeIsExport = $true
                $Global:PartialExportFileName = "$(New-Guid).partial.ps1"
                $testParams = @{
                    Credential = $Credential
                }

                Mock -CommandName Get-MgBetaDeviceAppManagementAndroidManagedAppProtection -MockWith {
                    return Get-DefaultReturnObj
                }
            }

            It 'Should Reverse Engineer resource from the Export method' {
                $result = Invoke-M365DSCResourceMethod -ResourceName 'IntuneAppProtectionPolicyAndroid' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
