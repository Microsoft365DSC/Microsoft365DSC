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
    -DscResource 'IntuneAppProtectionPolicyiOS' -GenericStubModule $GenericStubPath

Describe -Name $Global:DscHelper.DescribeHeader -Fixture {
    InModuleScope -ModuleName $Global:DscHelper.ModuleName -ScriptBlock {
        Invoke-Command -ScriptBlock $Global:DscHelper.InitializeScript -NoNewScope

        BeforeAll {
            $secpasswd = ConvertTo-SecureString ((New-Guid).ToString()) -AsPlainText -Force
            $Credential = New-Object System.Management.Automation.PSCredential ('tenantadmin@onmicrosoft.com', $secpasswd)

            Mock -ModuleName M365DSCUtil -CommandName Confirm-M365DSCDependencies -MockWith {
            }

            Mock -CommandName Get-MSCloudLoginConnectionProfile -MockWith {
            }

            Mock -CommandName New-M365DSCConnection -ModuleName '_Shared' -MockWith {
                return 'Credentials'
            }

            Mock -CommandName New-MgBetaDeviceAppManagementiosManagedAppProtection -MockWith {
                return @{
                    id = '12345-12345-12345-12345-12345'
                }
            }

            Mock -CommandName Update-DeviceConfigurationPolicyAssignment -MockWith {
            }

            Mock -CommandName Update-MgBetaDeviceAppManagementiosManagedAppProtection -MockWith {
            }

            Mock -CommandName Remove-MgBetaDeviceAppManagementiosManagedAppProtection -MockWith {
            }

            Mock -CommandName Get-MgGroup -MockWith {
                return @(
                    @{
                        id = '3eacc231-d77b-4efb-bb5f-310f68bd6198'
                        DisplayName = 'MyExcludedGroup'
                    },
                    @{
                        id = '6ee86c9f-2b3c-471d-ad38-ff4673ed723e'
                        DisplayName = 'MyAssignedGroup'
                    }
                )
            }

            Mock -CommandName Get-MgBetaDeviceAppManagementiosManagedAppProtection -MockWith {
                return @{
                    '@odata.type'                                  = '#microsoft.graph.iosManagedAppProtection'
                    AllowedDataIngestionLocations                  = @("oneDriveForBusiness","sharePoint","camera");
                    AllowedOutboundClipboardSharingExceptionLength = 0;
                    AllowWidgetContentSync                         = $True;
                    AppActionIfDeviceComplianceRequired            = "wipe";
                    AppActionIfIosDeviceModelNotAllowed            = "block";
                    AppActionIfUnableToAuthenticateUser            = "block";
                    AppGroupType                                   = "selectedPublicApps";
                    BlockDataIngestionIntoOrganizationDocuments    = $True;
                    CustomBrowserProtocol                          = "access://open?url=http";
                    CustomDialerAppProtocol                        = "skype";
                    DialerRestrictionLevel                         = "allApps";
                    DisableProtectionOfManagedOutboundOpenInData   = $False;
                    ExemptedUniversalLinks                         = @("http://facetime.apple.com","http://maps.apple.com","https://facetime.apple.com","https://maps.apple.com");
                    FilterOpenInToOnlyManagedApps                  = $False;
                    GenmojiConfigurationState                      = "blocked";
                    ManagedUniversalLinks                          = @("http://*.appsplatform.us/*","http://*.onedrive.com/*","http://*.powerapps.cn/*");
                    MaximumAllowedDeviceThreatLevel                = "low";
                    MaximumRequiredOsVersion                       = "1";
                    MaximumWarningOsVersion                        = "1";
                    MaximumWipeOsVersion                           = "1";
                    MessagingRedirectAppUrlScheme                  = "https://www.fakesite.com";
                    MobileThreatDefenseRemediationAction           = "block";
                    NotificationRestriction                        = "blockOrganizationalData";
                    PreviousPinBlockCount                          = 0;
                    ProtectedMessagingRedirectAppType              = "anyApp";
                    ProtectInboundDataFromUnknownSources           = $False;
                    PurviewContentEvaluationRequired               = "requiredWhenOnline";
                    ScreenCaptureConfigurationState                = "blocked";
                    ThirdPartyKeyboardsBlocked                     = $True;
                    WritingToolsConfigurationState                 = "blocked";
                    AllowedDataStorageLocations                    = @('sharePoint')
                    AllowedInboundDataTransferSources              = 'managedApps'
                    AllowedOutboundClipboardSharingLevel           = 'managedAppsWithPasteIn'
                    AllowedOutboundDataTransferDestinations        = 'managedApps'
                    AppDataEncryptionType                          = 'whenDeviceLocked'
                    ContactSyncBlocked                             = $False
                    DataBackupBlocked                              = $False
                    Description                                    = ''
                    DeviceComplianceRequired                       = $True
                    DisplayName                                    = 'DSC Policy'
                    FaceIdBlocked                                  = $False
                    FingerprintBlocked                             = $False
                    ManagedBrowser                                 = 'microsoftEdge'
                    MinimumRequiredAppVersion                      = '0.2'
                    MinimumRequiredOsVersion                       = '0.2'
                    MinimumRequiredSdkVersion                      = '0.1'
                    MinimumWarningAppVersion                       = '0.1'
                    MinimumWarningOsVersion                        = '0.1'
                    ManagedBrowserToOpenLinksRequired              = $True
                    MaximumPinRetries                              = 5
                    MinimumPinLength                               = 4
                    OrganizationalCredentialsRequired              = $False
                    PeriodBeforePinReset                           = 'P90D'
                    PeriodOfflineBeforeAccessCheck                 = 'PT12H'
                    PeriodOfflineBeforeWipeIsEnforced              = 'P90D'
                    GracePeriodToBlockAppsDuringOffClockHours      = 'PT1H'
                    PeriodOnlineBeforeAccessCheck                  = 'PT30M'
                    PinCharacterSet                                = 'alphanumericAndSymbol'
                    PinRequired                                    = $True
                    DisableAppPinIfDevicePinIsSet                  = $False
                    PrintBlocked                                   = $False
                    SaveAsBlocked                                  = $True
                    SimplePinBlocked                               = $False
                    id                                             = '12345-12345-12345-12345-12345'
                    TargetedAppManagementLevels                    = 'unmanaged'
                }
            }

            Mock -CommandName Get-MgBetaDeviceAppManagementiosManagedAppProtectionApp -MockWith {
                return @(
                    @{
                        id                  = 'com.cisco.jabberimintune.ios.ios'
                        mobileAppIdentifier = @{
                            '@odata.type' = '#microsoft.graph.iosMobileAppIdentifier'
                            bundleId      = 'com.cisco.jabberimintune.ios'
                        }
                    },
                    @{
                        id                  = 'com.pervasent.boardpapers.ios.ios'
                        mobileAppIdentifier = @{
                            '@odata.type' = '#microsoft.graph.iosMobileAppIdentifier'
                            bundleId      = 'com.pervasent.boardpapers.ios'
                        }
                    },
                    @{
                        id                  = 'com.sharefile.mobile.intune.ios.ios'
                        mobileAppIdentifier = @{
                            '@odata.type' = '#microsoft.graph.iosMobileAppIdentifier'
                            bundleId      = 'com.sharefile.mobile.intune.ios'
                        }
                    }
                )
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
                                        '@odata.type' = '#microsoft.graph.iosMobileAppIdentifier'
                                        bundleId = 'com.cisco.jabberimintune.ios'
                                    }
                                }
                                @{
                                    appGroups = 'none'
                                    appIdentifier = @{
                                        '@odata.type' = '#microsoft.graph.iosMobileAppIdentifier'
                                        bundleId = 'com.pervasent.boardpapers.ios'
                                    }
                                }
                                @{
                                    appGroups = 'none'
                                    appIdentifier = @{
                                        '@odata.type' = '#microsoft.graph.iosMobileAppIdentifier'
                                        bundleId = 'com.sharefile.mobile.intune.ios'
                                    }
                                }
                            )
                        }
                    }
                )
            }

            Mock -CommandName Get-MgBetaDeviceAppManagementiOSManagedAppProtectionAssignment -MockWith {
                return @(
                    @{
                        target = @{
                            '@odata.type' = '#microsoft.graph.groupAssignmentTarget'
                            groupId       = '6ee86c9f-2b3c-471d-ad38-ff4673ed723e'
                        }
                        source = 'direct'
                    },
                    @{
                        target = @{
                            '@odata.type' = '#microsoft.graph.exclusionGroupAssignmentTarget'
                            groupId       = '3eacc231-d77b-4efb-bb5f-310f68bd6198'
                        }
                        source = 'direct'
                    }
                )
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
                $testParams = @{
                    AllowedDataIngestionLocations                  = @("oneDriveForBusiness","sharePoint","camera");
                    AllowedOutboundClipboardSharingExceptionLength = 0;
                    AllowWidgetContentSync                         = $True;
                    AppActionIfDeviceComplianceRequired            = "wipe";
                    AppActionIfIosDeviceModelNotAllowed            = "block";
                    AppActionIfUnableToAuthenticateUser            = "block";
                    AppGroupType                                   = "selectedPublicApps";
                    BlockDataIngestionIntoOrganizationDocuments    = $True;
                    CustomBrowserProtocol                          = "access://open?url=http";
                    CustomDialerAppProtocol                        = "skype";
                    DialerRestrictionLevel                         = "allApps";
                    DisableProtectionOfManagedOutboundOpenInData   = $False;
                    ExemptedUniversalLinks                         = @("http://facetime.apple.com","http://maps.apple.com","https://facetime.apple.com","https://maps.apple.com");
                    FilterOpenInToOnlyManagedApps                  = $False;
                    GenmojiConfigurationState                      = "blocked";
                    ManagedUniversalLinks                          = @("http://*.appsplatform.us/*","http://*.onedrive.com/*","http://*.powerapps.cn/*");
                    MaximumAllowedDeviceThreatLevel                = "low";
                    MaximumRequiredOsVersion                       = "1";
                    MaximumWarningOsVersion                        = "1";
                    MaximumWipeOsVersion                           = "1";
                    MessagingRedirectAppUrlScheme                  = "https://www.fakesite.com";
                    MobileThreatDefenseRemediationAction           = "block";
                    NotificationRestriction                        = "blockOrganizationalData";
                    PreviousPinBlockCount                          = 0;
                    ProtectedMessagingRedirectAppType              = "anyApp";
                    ProtectInboundDataFromUnknownSources           = $False;
                    PurviewContentEvaluationRequired               = "requiredWhenOnline";
                    ScreenCaptureConfigurationState                = "blocked";
                    ThirdPartyKeyboardsBlocked                     = $True;
                    WritingToolsConfigurationState                 = "blocked";
                    AllowedDataStorageLocations                    = @('sharePoint')
                    AllowedInboundDataTransferSources              = 'managedApps'
                    AllowedOutboundClipboardSharingLevel           = 'managedAppsWithPasteIn'
                    AllowedOutboundDataTransferDestinations        = 'managedApps'
                    AppDataEncryptionType                          = 'whenDeviceLocked'
                    Apps                                           = @('com.cisco.jabberimintune.ios', 'com.pervasent.boardpapers.ios', 'com.sharefile.mobile.intune.ios')
                    Assignments                                    = @(
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
                    ContactSyncBlocked                             = $False
                    DataBackupBlocked                              = $False
                    Description                                    = ''
                    DeviceComplianceRequired                       = $True
                    DisplayName                                    = 'DSC Policy'
                    Ensure                                         = 'Present'
                    FaceIdBlocked                                  = $False
                    FingerprintBlocked                             = $False
                    Credential                                     = $Credential
                    ManagedBrowser                                 = 'microsoftEdge'
                    MinimumRequiredAppVersion                      = '0.2'
                    MinimumRequiredOsVersion                       = '0.2'
                    MinimumRequiredSdkVersion                      = '0.1'
                    MinimumWarningAppVersion                       = '0.1'
                    MinimumWarningOsVersion                        = '0.1'
                    ManagedBrowserToOpenLinksRequired              = $True
                    MaximumPinRetries                              = 5
                    MinimumPinLength                               = 4
                    OrganizationalCredentialsRequired              = $False
                    PeriodBeforePinReset                           = 'P90D'
                    PeriodOfflineBeforeAccessCheck                 = 'PT12H'
                    PeriodOfflineBeforeWipeIsEnforced              = 'P90D'
                    PeriodOnlineBeforeAccessCheck                  = 'PT30M'
                    PinCharacterSet                                = 'alphanumericAndSymbol'
                    PinRequired                                    = $True
                    DisableAppPinIfDevicePinIsSet                  = $False
                    PrintBlocked                                   = $False
                    SaveAsBlocked                                  = $True
                    SimplePinBlocked                               = $False
                    Id                                             = '12345-12345-12345-12345-12345'
                    TargetedAppManagementLevels                    = @('unmanaged')
                }
                Mock -CommandName Get-MgBetaDeviceAppManagementiosManagedAppProtection -MockWith {
                    return $null
                }
            }

            It 'Should return absent from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneAppProtectionPolicyiOS' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneAppProtectionPolicyiOS' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should create the Policy from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneAppProtectionPolicyiOS' -Property $testParams).Set()
                Should -Invoke -CommandName 'New-MgBetaDeviceAppManagementiosManagedAppProtection' -Exactly 1
            }
        }

        Context -Name 'When the policy already exists and is NOT in the Desired State' -Fixture {
            BeforeAll {
                $testParams = @{
                    AllowedDataIngestionLocations                  = @("oneDriveForBusiness","sharePoint","camera");
                    AllowedOutboundClipboardSharingExceptionLength = 0;
                    AllowWidgetContentSync                         = $True;
                    AppActionIfDeviceComplianceRequired            = "wipe";
                    AppActionIfIosDeviceModelNotAllowed            = "block";
                    AppActionIfUnableToAuthenticateUser            = "block";
                    AppGroupType                                   = "selectedPublicApps";
                    BlockDataIngestionIntoOrganizationDocuments    = $True;
                    CustomBrowserProtocol                          = "access://open?url=http";
                    CustomDialerAppProtocol                        = "skype";
                    DialerRestrictionLevel                         = "allApps";
                    DisableProtectionOfManagedOutboundOpenInData   = $False;
                    ExemptedUniversalLinks                         = @("http://facetime.apple.com","http://maps.apple.com","https://facetime.apple.com","https://maps.apple.com");
                    FilterOpenInToOnlyManagedApps                  = $False;
                    GenmojiConfigurationState                      = "notBlocked"; #Drift
                    ManagedUniversalLinks                          = @("http://*.appsplatform.us/*","http://*.onedrive.com/*","http://*.powerapps.cn/*");
                    MaximumAllowedDeviceThreatLevel                = "low";
                    MaximumRequiredOsVersion                       = "1";
                    MaximumWarningOsVersion                        = "1";
                    MaximumWipeOsVersion                           = "1";
                    MessagingRedirectAppUrlScheme                  = "https://www.fakesite.com";
                    MobileThreatDefenseRemediationAction           = "block";
                    NotificationRestriction                        = "blockOrganizationalData";
                    PreviousPinBlockCount                          = 0;
                    ProtectedMessagingRedirectAppType              = "anyApp";
                    ProtectInboundDataFromUnknownSources           = $False;
                    PurviewContentEvaluationRequired               = "requiredWhenOnline";
                    ScreenCaptureConfigurationState                = "notBlocked"; #Drift
                    ThirdPartyKeyboardsBlocked                     = $True;
                    WritingToolsConfigurationState                 = "notBlocked"; #Drift
                    AllowedDataStorageLocations                    = @('sharePoint')
                    AllowedInboundDataTransferSources              = 'managedApps'
                    AllowedOutboundClipboardSharingLevel           = 'managedAppsWithPasteIn'
                    AllowedOutboundDataTransferDestinations        = 'managedApps'
                    AppDataEncryptionType                          = 'whenDeviceLocked'
                    Apps                                           = @('com.cisco.jabberimintune.ios', 'com.pervasent.boardpapers.ios', 'com.sharefile.mobile.intune.ios')
                    Assignments                                    = @(
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
                    ContactSyncBlocked                             = $False
                    DataBackupBlocked                              = $False
                    Description                                    = ''
                    DeviceComplianceRequired                       = $True
                    DisplayName                                    = 'DSC Policy'
                    Ensure                                         = 'Present'
                    FaceIdBlocked                                  = $False
                    FingerprintBlocked                             = $False
                    Credential                                     = $Credential
                    ManagedBrowser                                 = 'microsoftEdge'
                    MinimumRequiredAppVersion                      = '0.2'
                    MinimumRequiredOsVersion                       = '0.2'
                    MinimumRequiredSdkVersion                      = '0.1'
                    MinimumWarningAppVersion                       = '0.1'
                    MinimumWarningOsVersion                        = '0.1'
                    ManagedBrowserToOpenLinksRequired              = $False; #Drift
                    MaximumPinRetries                              = 5
                    MinimumPinLength                               = 4
                    OrganizationalCredentialsRequired              = $False
                    PeriodBeforePinReset                           = 'P90D'
                    PeriodOfflineBeforeAccessCheck                 = 'PT12H'
                    PeriodOfflineBeforeWipeIsEnforced              = 'P90D'
                    PeriodOnlineBeforeAccessCheck                  = 'PT30M'
                    PinCharacterSet                                = 'alphanumericAndSymbol'
                    PinRequired                                    = $True
                    DisableAppPinIfDevicePinIsSet                  = $False
                    PrintBlocked                                   = $False
                    SaveAsBlocked                                  = $True
                    SimplePinBlocked                               = $False
                    Id                                             = '12345-12345-12345-12345-12345'
                    TargetedAppManagementLevels                    = @('unmanaged')
                }
            }

            It 'Should return Present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneAppProtectionPolicyiOS' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneAppProtectionPolicyiOS' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should update the App Configuration Policy from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneAppProtectionPolicyiOS' -Property $testParams).Set()
                Should -Invoke -CommandName Update-MgBetaDeviceAppManagementiosManagedAppProtection -Exactly 1
            }
        }

        Context -Name 'When the policy already exists and IS in the Desired State' -Fixture {
            BeforeAll {
                $testParams = @{
                    AllowedDataIngestionLocations                  = @("oneDriveForBusiness","sharePoint","camera");
                    AllowedOutboundClipboardSharingExceptionLength = 0;
                    AllowWidgetContentSync                         = $True;
                    AppActionIfDeviceComplianceRequired            = "wipe";
                    AppActionIfIosDeviceModelNotAllowed            = "block";
                    AppActionIfUnableToAuthenticateUser            = "block";
                    AppGroupType                                   = "selectedPublicApps";
                    BlockDataIngestionIntoOrganizationDocuments    = $True;
                    CustomBrowserProtocol                          = "access://open?url=http";
                    CustomDialerAppProtocol                        = "skype";
                    DialerRestrictionLevel                         = "allApps";
                    DisableProtectionOfManagedOutboundOpenInData   = $False;
                    ExemptedUniversalLinks                         = @("http://facetime.apple.com","http://maps.apple.com","https://facetime.apple.com","https://maps.apple.com");
                    FilterOpenInToOnlyManagedApps                  = $False;
                    GenmojiConfigurationState                      = "blocked";
                    ManagedUniversalLinks                          = @("http://*.appsplatform.us/*","http://*.onedrive.com/*","http://*.powerapps.cn/*");
                    MaximumAllowedDeviceThreatLevel                = "low";
                    MaximumRequiredOsVersion                       = "1";
                    MaximumWarningOsVersion                        = "1";
                    MaximumWipeOsVersion                           = "1";
                    MessagingRedirectAppUrlScheme                  = "https://www.fakesite.com";
                    MobileThreatDefenseRemediationAction           = "block";
                    NotificationRestriction                        = "blockOrganizationalData";
                    PreviousPinBlockCount                          = 0;
                    ProtectedMessagingRedirectAppType              = "anyApp";
                    ProtectInboundDataFromUnknownSources           = $False;
                    PurviewContentEvaluationRequired               = "requiredWhenOnline";
                    ScreenCaptureConfigurationState                = "blocked";
                    ThirdPartyKeyboardsBlocked                     = $True;
                    WritingToolsConfigurationState                 = "blocked";
                    AllowedDataStorageLocations                    = @('sharePoint')
                    AllowedInboundDataTransferSources              = 'managedApps'
                    AllowedOutboundClipboardSharingLevel           = 'managedAppsWithPasteIn'
                    AllowedOutboundDataTransferDestinations        = 'managedApps'
                    AppDataEncryptionType                          = 'whenDeviceLocked'
                    Apps                                           = @('com.cisco.jabberimintune.ios', 'com.pervasent.boardpapers.ios', 'com.sharefile.mobile.intune.ios')
                    ContactSyncBlocked                             = $False
                    DataBackupBlocked                              = $False
                    Description                                    = ''
                    DeviceComplianceRequired                       = $True
                    DisplayName                                    = 'DSC Policy'
                    Ensure                                         = 'Present'
                    FaceIdBlocked                                  = $False
                    FingerprintBlocked                             = $False
                    Credential                                     = $Credential
                    ManagedBrowser                                 = 'microsoftEdge'
                    MinimumRequiredAppVersion                      = '0.2'
                    MinimumRequiredOsVersion                       = '0.2'
                    MinimumRequiredSdkVersion                      = '0.1'
                    MinimumWarningAppVersion                       = '0.1'
                    MinimumWarningOsVersion                        = '0.1'
                    ManagedBrowserToOpenLinksRequired              = $True
                    MaximumPinRetries                              = 5
                    MinimumPinLength                               = 4
                    OrganizationalCredentialsRequired              = $False
                    PeriodBeforePinReset                           = 'P90D'
                    PeriodOfflineBeforeAccessCheck                 = 'PT12H'
                    PeriodOfflineBeforeWipeIsEnforced              = 'P90D'
                    GracePeriodToBlockAppsDuringOffClockHours      = 'PT1H'
                    PeriodOnlineBeforeAccessCheck                  = 'PT30M'
                    PinCharacterSet                                = 'alphanumericAndSymbol'
                    PinRequired                                    = $True
                    DisableAppPinIfDevicePinIsSet                  = $False
                    PrintBlocked                                   = $False
                    SaveAsBlocked                                  = $True
                    SimplePinBlocked                               = $False
                    Id                                             = '12345-12345-12345-12345-12345'
                    TargetedAppManagementLevels                    = @('unmanaged')
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneAppProtectionPolicyiOS' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name 'When the policy exists and it SHOULD NOT' -Fixture {
            BeforeAll {
                $testParams = @{
                    AllowedDataIngestionLocations                  = @("oneDriveForBusiness","sharePoint","camera");
                    AllowedOutboundClipboardSharingExceptionLength = 0;
                    AllowWidgetContentSync                         = $True;
                    AppActionIfDeviceComplianceRequired            = "wipe";
                    AppActionIfIosDeviceModelNotAllowed            = "block";
                    AppActionIfUnableToAuthenticateUser            = "block";
                    AppGroupType                                   = "selectedPublicApps";
                    BlockDataIngestionIntoOrganizationDocuments    = $True;
                    CustomBrowserProtocol                          = "access://open?url=http";
                    CustomDialerAppProtocol                        = "skype";
                    DialerRestrictionLevel                         = "allApps";
                    DisableProtectionOfManagedOutboundOpenInData   = $False;
                    ExemptedUniversalLinks                         = @("http://facetime.apple.com","http://maps.apple.com","https://facetime.apple.com","https://maps.apple.com");
                    FilterOpenInToOnlyManagedApps                  = $False;
                    GenmojiConfigurationState                      = "blocked";
                    ManagedUniversalLinks                          = @("http://*.appsplatform.us/*","http://*.onedrive.com/*","http://*.powerapps.cn/*");
                    MaximumAllowedDeviceThreatLevel                = "low";
                    MaximumRequiredOsVersion                       = "1";
                    MaximumWarningOsVersion                        = "1";
                    MaximumWipeOsVersion                           = "1";
                    MessagingRedirectAppUrlScheme                  = "https://www.fakesite.com";
                    MobileThreatDefenseRemediationAction           = "block";
                    NotificationRestriction                        = "blockOrganizationalData";
                    PreviousPinBlockCount                          = 0;
                    ProtectedMessagingRedirectAppType              = "anyApp";
                    ProtectInboundDataFromUnknownSources           = $False;
                    PurviewContentEvaluationRequired               = "requiredWhenOnline";
                    ScreenCaptureConfigurationState                = "blocked";
                    ThirdPartyKeyboardsBlocked                     = $True;
                    WritingToolsConfigurationState                 = "blocked";
                    AllowedDataStorageLocations                    = @('sharePoint')
                    AllowedInboundDataTransferSources              = 'managedApps'
                    AllowedOutboundClipboardSharingLevel           = 'managedAppsWithPasteIn'
                    AllowedOutboundDataTransferDestinations        = 'managedApps'
                    AppDataEncryptionType                          = 'whenDeviceLocked'
                    Apps                                           = @('com.cisco.jabberimintune.ios', 'com.pervasent.boardpapers.ios', 'com.sharefile.mobile.intune.ios')
                    Assignments                                    = @(
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
                    ContactSyncBlocked                             = $False
                    DataBackupBlocked                              = $False
                    Description                                    = ''
                    DeviceComplianceRequired                       = $True
                    DisplayName                                    = 'DSC Policy'
                    Ensure                                         = 'Absent'
                    FaceIdBlocked                                  = $False
                    FingerprintBlocked                             = $False
                    Credential                                     = $Credential
                    ManagedBrowser                                 = 'microsoftEdge'
                    MinimumRequiredAppVersion                      = '0.2'
                    MinimumRequiredOsVersion                       = '0.2'
                    MinimumRequiredSdkVersion                      = '0.1'
                    MinimumWarningAppVersion                       = '0.1'
                    MinimumWarningOsVersion                        = '0.1'
                    ManagedBrowserToOpenLinksRequired              = $True
                    MaximumPinRetries                              = 5
                    MinimumPinLength                               = 4
                    OrganizationalCredentialsRequired              = $False
                    PeriodBeforePinReset                           = 'P90D'
                    PeriodOfflineBeforeAccessCheck                 = 'PT12H'
                    PeriodOfflineBeforeWipeIsEnforced              = 'P90D'
                    PeriodOnlineBeforeAccessCheck                  = 'PT30M'
                    PinCharacterSet                                = 'alphanumericAndSymbol'
                    PinRequired                                    = $True
                    DisableAppPinIfDevicePinIsSet                  = $False
                    PrintBlocked                                   = $False
                    SaveAsBlocked                                  = $True
                    SimplePinBlocked                               = $False
                    Id                                             = '12345-12345-12345-12345-12345'
                    TargetedAppManagementLevels                    = @('unmanaged')
                }
            }

            It 'Should return Present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneAppProtectionPolicyiOS' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneAppProtectionPolicyiOS' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should remove the App Configuration Policy from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneAppProtectionPolicyiOS' -Property $testParams).Set()
                Should -Invoke -CommandName Remove-MgBetaDeviceAppManagementiosManagedAppProtection -Exactly 1
            }
        }

        Context -Name 'When the policy exists and AllowedIosDeviceModels lists several device models' -Fixture {
            BeforeAll {
                $testParams = @{
                    DisplayName                 = 'DSC Policy'
                    Id                          = '12345-12345-12345-12345-12345'
                    Ensure                      = 'Present'
                    Credential                  = $Credential
                    AppGroupType                = 'selectedPublicApps'
                    Apps                        = @('com.cisco.jabberimintune.ios', 'com.pervasent.boardpapers.ios', 'com.sharefile.mobile.intune.ios')
                    TargetedAppManagementLevels = @('unmanaged')
                    AllowedIosDeviceModels      = @('iPhone10,1', 'iPhone11,2')
                }

                Mock -CommandName Get-MgBetaDeviceAppManagementiosManagedAppProtection -MockWith {
                    return @{
                        id                          = '12345-12345-12345-12345-12345'
                        DisplayName                 = 'DSC Policy'
                        AppGroupType                = 'selectedPublicApps'
                        TargetedAppManagementLevels = 'unmanaged'
                        AllowedIosDeviceModels      = 'iPhone10,1;iPhone11,2'
                    }
                }
            }

            It 'Should return one entry per device model from the Get method' {
                $result = ((New-M365DSCResourceInstance -ResourceName 'IntuneAppProtectionPolicyiOS' -Property $testParams).Get().ToHashtable()).AllowedIosDeviceModels
                $result.Count | Should -Be 2
                $result[0] | Should -Be 'iPhone10,1'
                $result[1] | Should -Be 'iPhone11,2'
            }

            It 'Should send a semicolon separated string to the update cmdlet from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneAppProtectionPolicyiOS' -Property $testParams).Set()
                Should -Invoke -CommandName Update-MgBetaDeviceAppManagementiosManagedAppProtection -Exactly 1 -ParameterFilter {
                    $BodyParameter.AllowedIosDeviceModels -is [System.String] -and
                    $BodyParameter.AllowedIosDeviceModels -eq 'iPhone10,1;iPhone11,2'
                }
            }
        }

        Context -Name 'When the policy exists without a value for AllowedIosDeviceModels' -Fixture {
            BeforeAll {
                $testParams = @{
                    DisplayName                 = 'DSC Policy'
                    Id                          = '12345-12345-12345-12345-12345'
                    Ensure                      = 'Present'
                    Credential                  = $Credential
                    AppGroupType                = 'selectedPublicApps'
                    Apps                        = @('com.cisco.jabberimintune.ios', 'com.pervasent.boardpapers.ios', 'com.sharefile.mobile.intune.ios')
                    TargetedAppManagementLevels = @('unmanaged')
                }

                Mock -CommandName Get-MgBetaDeviceAppManagementiosManagedAppProtection -MockWith {
                    return @{
                        id                          = '12345-12345-12345-12345-12345'
                        DisplayName                 = 'DSC Policy'
                        AppGroupType                = 'selectedPublicApps'
                        TargetedAppManagementLevels = 'unmanaged'
                        AllowedIosDeviceModels      = $null
                    }
                }
            }

            It 'Should return no device model from the Get method' {
                $result = ((New-M365DSCResourceInstance -ResourceName 'IntuneAppProtectionPolicyiOS' -Property $testParams).Get().ToHashtable()).AllowedIosDeviceModels
                $result.Count | Should -Be 0
            }

            It 'Should not add AllowedIosDeviceModels to the body of the update cmdlet from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneAppProtectionPolicyiOS' -Property $testParams).Set()
                Should -Invoke -CommandName Update-MgBetaDeviceAppManagementiosManagedAppProtection -Exactly 1 -ParameterFilter {
                    -not $BodyParameter.ContainsKey('AllowedIosDeviceModels')
                }
            }
        }

        Context -Name "When the policy doesn't exist and AllowedIosDeviceModels lists several device models" -Fixture {
            BeforeAll {
                $testParams = @{
                    DisplayName                 = 'DSC Policy'
                    Ensure                      = 'Present'
                    Credential                  = $Credential
                    AppGroupType                = 'selectedPublicApps'
                    Apps                        = @('com.cisco.jabberimintune.ios', 'com.pervasent.boardpapers.ios', 'com.sharefile.mobile.intune.ios')
                    TargetedAppManagementLevels = @('unmanaged')
                    AllowedIosDeviceModels      = @('iPhone10,1', 'iPhone11,2')
                }

                Mock -CommandName Get-MgBetaDeviceAppManagementiosManagedAppProtection -MockWith {
                    return $null
                }
            }

            It 'Should send a semicolon separated string to the create cmdlet from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneAppProtectionPolicyiOS' -Property $testParams).Set()
                Should -Invoke -CommandName New-MgBetaDeviceAppManagementiosManagedAppProtection -Exactly 1 -ParameterFilter {
                    $BodyParameter.AllowedIosDeviceModels -is [System.String] -and
                    $BodyParameter.AllowedIosDeviceModels -eq 'iPhone10,1;iPhone11,2'
                }
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
                $result = Invoke-M365DSCResourceMethod -ResourceName 'IntuneAppProtectionPolicyiOS' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
