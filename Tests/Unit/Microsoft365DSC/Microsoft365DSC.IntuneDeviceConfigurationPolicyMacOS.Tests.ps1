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
    -DscResource 'IntuneDeviceConfigurationPolicyMacOS' -GenericStubModule $GenericStubPath
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

            Mock -CommandName Update-MgBetaDeviceManagementDeviceConfiguration -MockWith {
            }

            Mock -CommandName New-MgBetaDeviceManagementDeviceConfiguration -MockWith {
            }

            Mock -CommandName Remove-MgBetaDeviceManagementDeviceConfiguration -MockWith {
            }

            Mock -CommandName New-M365DSCConnection -ModuleName '_Shared' -MockWith {
                return 'Credentials'
            }

            Mock -CommandName Get-M365DSCExportCachedCollection -MockWith {
                return Get-MgBetaDeviceManagementDeviceConfiguration
            }
            Mock -CommandName Get-MgBetaDeviceManagementDeviceConfiguration -MockWith {
                return @{
                    '@odata.type' = '#microsoft.graph.macosGeneralDeviceConfiguration'
                    TouchIdTimeoutInHours                           = 25
                    AirDropBlocked                                  = $True
                    ClassroomAppForceUnpromptedScreenObservation    = $True
                    KeychainBlockCloudSync                          = $True
                    AppleWatchBlockAutoUnlock                       = $True
                    ScreenCaptureBlocked                            = $True
                    MultiplayerGamingBlocked                        = $True
                    WallpaperModificationBlocked                    = $True
                    CameraBlocked                                   = $True
                    ICloudBlockActivityContinuation                 = $True
                    SpotlightBlockInternetResults                   = $True
                    SafariBlockAutofill                             = $True
                    PasswordBlockAutoFill                           = $True
                    PasswordRequiredType                            = 'deviceDefault'
                    PasswordMaximumAttemptCount                     = 25
                    ClassroomForceAutomaticallyJoinClasses          = $True
                    ICloudPrivateRelayBlocked                       = $True
                    PasswordBlockModification                       = $True
                    ICloudBlockCalendar                             = $True
                    ICloudBlockAddressBook                          = $True
                    SoftwareUpdatesEnforcedDelayInDays              = 25
                    ICloudBlockReminders                            = $True
                    PasswordBlockSimple                             = $True
                    PasswordBlockAirDropSharing                     = $True
                    ICloudBlockBookmarks                            = $True
                    PasswordRequired                                = $True
                    KeyboardBlockDictation                          = $True
                    SoftwareUpdateMajorOSDeferredInstallDelayInDays = 25
                    ContentCachingBlocked                           = $True
                    ICloudDesktopAndDocumentsBlocked                = $True
                    UpdateDelayPolicy                               = 'delayMajorOsUpdateVisibility'
                    PasswordPreviousPasswordBlockCount              = 25
                    ActivationLockWhenSupervisedAllowed             = $True
                    AddingGameCenterFriendsBlocked                  = $True
                    PasswordMinimumLength                           = 25
                    EraseContentAndSettingsBlocked                  = $True
                    ICloudBlockNotes                                = $True
                    ICloudBlockPhotoLibrary                         = $True
                    ICloudBlockMail                                 = $True
                    PasswordMinutesOfInactivityBeforeScreenTimeout  = 25
                    PasswordExpirationDays                          = 25
                    PasswordBlockFingerprintUnlock                  = $True
                    PasswordBlockProximityRequests                  = $True
                    SoftwareUpdateNonOSDeferredInstallDelayInDays   = 25
                    ITunesBlockMusicService                         = $True
                    DefinitionLookupBlocked                         = $True
                    ClassroomForceRequestPermissionToLeaveClasses   = $True
                    ClassroomAppBlockRemoteScreenObservation        = $True
                    SoftwareUpdateMinorOSDeferredInstallDelayInDays = 25
                    ITunesBlockFileSharing                          = $True
                    GameCenterBlocked                               = $True
                    ICloudBlockDocumentSync                         = $True
                    PasswordMinimumCharacterSetCount                = 25
                    PasswordMinutesOfInactivityBeforeLock           = 25
                    ClassroomForceUnpromptedAppAndDeviceLock        = $True
                    PasswordMinutesUntilFailedLoginReset            = 25
                    Description                                     = 'FakeStringValue'
                    DisplayName                                     = 'FakeStringValue'
                    Id                                              = 'FakeStringValue'
                }
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
        Context -Name 'The IntuneDeviceConfigurationPolicyMacOS should exist but it DOES NOT' -Fixture {
            BeforeAll {
                $testParams = @{
                    TouchIdTimeoutInHours                           = 25
                    Description                                     = 'FakeStringValue'
                    AirDropBlocked                                  = $True
                    ClassroomAppForceUnpromptedScreenObservation    = $True
                    KeychainBlockCloudSync                          = $True
                    DisplayName                                     = 'FakeStringValue'
                    AppleWatchBlockAutoUnlock                       = $True
                    ScreenCaptureBlocked                            = $True
                    MultiplayerGamingBlocked                        = $True
                    WallpaperModificationBlocked                    = $True
                    CameraBlocked                                   = $True
                    ICloudBlockActivityContinuation                 = $True
                    SpotlightBlockInternetResults                   = $True
                    SafariBlockAutofill                             = $True
                    PasswordBlockAutoFill                           = $True
                    PasswordRequiredType                            = 'deviceDefault'
                    PasswordMaximumAttemptCount                     = 25
                    ClassroomForceAutomaticallyJoinClasses          = $True
                    ICloudPrivateRelayBlocked                       = $True
                    PasswordBlockModification                       = $True
                    ICloudBlockCalendar                             = $True
                    ICloudBlockAddressBook                          = $True
                    SoftwareUpdatesEnforcedDelayInDays              = 25
                    ICloudBlockReminders                            = $True
                    PasswordBlockSimple                             = $True
                    PasswordBlockAirDropSharing                     = $True
                    ICloudBlockBookmarks                            = $True
                    PasswordRequired                                = $True
                    KeyboardBlockDictation                          = $True
                    SoftwareUpdateMajorOSDeferredInstallDelayInDays = 25
                    ContentCachingBlocked                           = $True
                    ICloudDesktopAndDocumentsBlocked                = $True
                    UpdateDelayPolicy                               = 'delayMajorOsUpdateVisibility'
                    PasswordPreviousPasswordBlockCount              = 25
                    ActivationLockWhenSupervisedAllowed             = $True
                    AddingGameCenterFriendsBlocked                  = $True
                    Id                                              = 'FakeStringValue'
                    PasswordMinimumLength                           = 25
                    EraseContentAndSettingsBlocked                  = $True
                    ICloudBlockNotes                                = $True
                    ICloudBlockPhotoLibrary                         = $True
                    ICloudBlockMail                                 = $True
                    PasswordMinutesOfInactivityBeforeScreenTimeout  = 25
                    PasswordExpirationDays                          = 25
                    PasswordBlockFingerprintUnlock                  = $True
                    PasswordBlockProximityRequests                  = $True
                    SoftwareUpdateNonOSDeferredInstallDelayInDays   = 25
                    ITunesBlockMusicService                         = $True
                    DefinitionLookupBlocked                         = $True
                    ClassroomForceRequestPermissionToLeaveClasses   = $True
                    ClassroomAppBlockRemoteScreenObservation        = $True
                    SoftwareUpdateMinorOSDeferredInstallDelayInDays = 25
                    ITunesBlockFileSharing                          = $True
                    GameCenterBlocked                               = $True
                    ICloudBlockDocumentSync                         = $True
                    PasswordMinimumCharacterSetCount                = 25
                    PasswordMinutesOfInactivityBeforeLock           = 25
                    ClassroomForceUnpromptedAppAndDeviceLock        = $True
                    PasswordMinutesUntilFailedLoginReset            = 25
                    Ensure                                          = 'Present'
                    Credential                                      = $Credential
                }

                Mock -CommandName Get-MgBetaDeviceManagementDeviceConfiguration -MockWith {
                    return $null
                }
            }
            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneDeviceConfigurationPolicyMacOS' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }
            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceConfigurationPolicyMacOS' -Property $testParams).Test() | Should -Be $false
            }
            It 'Should Create the group from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceConfigurationPolicyMacOS' -Property $testParams).Set()
                Should -Invoke -CommandName 'New-MgBetaDeviceManagementDeviceConfiguration' -Exactly 1
            }
        }

        Context -Name 'The IntuneDeviceConfigurationPolicyMacOS exists but it SHOULD NOT' -Fixture {
            BeforeAll {
                $testParams = @{
                    TouchIdTimeoutInHours                           = 25
                    Description                                     = 'FakeStringValue'
                    AirDropBlocked                                  = $True
                    ClassroomAppForceUnpromptedScreenObservation    = $True
                    KeychainBlockCloudSync                          = $True
                    DisplayName                                     = 'FakeStringValue'
                    AppleWatchBlockAutoUnlock                       = $True
                    ScreenCaptureBlocked                            = $True
                    MultiplayerGamingBlocked                        = $True
                    WallpaperModificationBlocked                    = $True
                    CameraBlocked                                   = $True
                    ICloudBlockActivityContinuation                 = $True
                    SpotlightBlockInternetResults                   = $True
                    SafariBlockAutofill                             = $True
                    PasswordBlockAutoFill                           = $True
                    CompliantAppListType                            = 'appsNotInListCompliant'
                    PasswordMaximumAttemptCount                     = 25
                    ClassroomForceAutomaticallyJoinClasses          = $True
                    ICloudPrivateRelayBlocked                       = $True
                    PasswordBlockModification                       = $True
                    ICloudBlockCalendar                             = $True
                    ICloudBlockAddressBook                          = $True
                    SoftwareUpdatesEnforcedDelayInDays              = 25
                    ICloudBlockReminders                            = $True
                    PasswordBlockSimple                             = $True
                    PasswordBlockAirDropSharing                     = $True
                    ICloudBlockBookmarks                            = $True
                    PasswordRequired                                = $True
                    KeyboardBlockDictation                          = $True
                    SoftwareUpdateMajorOSDeferredInstallDelayInDays = 25
                    ContentCachingBlocked                           = $True
                    ICloudDesktopAndDocumentsBlocked                = $True
                    UpdateDelayPolicy                               = 'delayMajorOsUpdateVisibility'
                    PasswordPreviousPasswordBlockCount              = 25
                    ActivationLockWhenSupervisedAllowed             = $True
                    AddingGameCenterFriendsBlocked                  = $True
                    Id                                              = 'FakeStringValue'
                    PasswordMinimumLength                           = 25
                    EraseContentAndSettingsBlocked                  = $True
                    ICloudBlockNotes                                = $True
                    ICloudBlockPhotoLibrary                         = $True
                    ICloudBlockMail                                 = $True
                    PasswordMinutesOfInactivityBeforeScreenTimeout  = 25
                    PasswordExpirationDays                          = 25
                    PasswordBlockFingerprintUnlock                  = $True
                    PasswordBlockProximityRequests                  = $True
                    SoftwareUpdateNonOSDeferredInstallDelayInDays   = 25
                    ITunesBlockMusicService                         = $True
                    DefinitionLookupBlocked                         = $True
                    ClassroomForceRequestPermissionToLeaveClasses   = $True
                    ClassroomAppBlockRemoteScreenObservation        = $True
                    SoftwareUpdateMinorOSDeferredInstallDelayInDays = 25
                    ITunesBlockFileSharing                          = $True
                    PasswordRequiredType                            = 'deviceDefault'
                    GameCenterBlocked                               = $True
                    ICloudBlockDocumentSync                         = $True
                    PasswordMinimumCharacterSetCount                = 25
                    PasswordMinutesOfInactivityBeforeLock           = 25
                    ClassroomForceUnpromptedAppAndDeviceLock        = $True
                    PasswordMinutesUntilFailedLoginReset            = 25
                    Ensure                                          = 'Absent'
                    Credential                                      = $Credential
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneDeviceConfigurationPolicyMacOS' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceConfigurationPolicyMacOS' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should Remove the group from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceConfigurationPolicyMacOS' -Property $testParams).Set()
                Should -Invoke -CommandName Remove-MgBetaDeviceManagementDeviceConfiguration -Exactly 1

            }
        }
        Context -Name 'The IntuneDeviceConfigurationPolicyMacOS Exists and Values are already in the desired state' -Fixture {
            BeforeAll {
                $testParams = @{
                    TouchIdTimeoutInHours                           = 25
                    Description                                     = 'FakeStringValue'
                    AirDropBlocked                                  = $True
                    ClassroomAppForceUnpromptedScreenObservation    = $True
                    KeychainBlockCloudSync                          = $True
                    DisplayName                                     = 'FakeStringValue'
                    AppleWatchBlockAutoUnlock                       = $True
                    ScreenCaptureBlocked                            = $True
                    MultiplayerGamingBlocked                        = $True
                    WallpaperModificationBlocked                    = $True
                    CameraBlocked                                   = $True
                    ICloudBlockActivityContinuation                 = $True
                    SpotlightBlockInternetResults                   = $True
                    SafariBlockAutofill                             = $True
                    PasswordBlockAutoFill                           = $True
                    PasswordRequiredType                            = 'deviceDefault'
                    PasswordMaximumAttemptCount                     = 25
                    ClassroomForceAutomaticallyJoinClasses          = $True
                    ICloudPrivateRelayBlocked                       = $True
                    PasswordBlockModification                       = $True
                    ICloudBlockCalendar                             = $True
                    ICloudBlockAddressBook                          = $True
                    SoftwareUpdatesEnforcedDelayInDays              = 25
                    ICloudBlockReminders                            = $True
                    PasswordBlockSimple                             = $True
                    PasswordBlockAirDropSharing                     = $True
                    ICloudBlockBookmarks                            = $True
                    PasswordRequired                                = $True
                    KeyboardBlockDictation                          = $True
                    SoftwareUpdateMajorOSDeferredInstallDelayInDays = 25
                    ContentCachingBlocked                           = $True
                    ICloudDesktopAndDocumentsBlocked                = $True
                    UpdateDelayPolicy                               = 'delayMajorOsUpdateVisibility'
                    PasswordPreviousPasswordBlockCount              = 25
                    ActivationLockWhenSupervisedAllowed             = $True
                    AddingGameCenterFriendsBlocked                  = $True
                    Id                                              = 'FakeStringValue'
                    PasswordMinimumLength                           = 25
                    EraseContentAndSettingsBlocked                  = $True
                    ICloudBlockNotes                                = $True
                    ICloudBlockPhotoLibrary                         = $True
                    ICloudBlockMail                                 = $True
                    PasswordMinutesOfInactivityBeforeScreenTimeout  = 25
                    PasswordExpirationDays                          = 25
                    PasswordBlockFingerprintUnlock                  = $True
                    PasswordBlockProximityRequests                  = $True
                    SoftwareUpdateNonOSDeferredInstallDelayInDays   = 25
                    ITunesBlockMusicService                         = $True
                    DefinitionLookupBlocked                         = $True
                    ClassroomForceRequestPermissionToLeaveClasses   = $True
                    ClassroomAppBlockRemoteScreenObservation        = $True
                    SoftwareUpdateMinorOSDeferredInstallDelayInDays = 25
                    ITunesBlockFileSharing                          = $True
                    GameCenterBlocked                               = $True
                    ICloudBlockDocumentSync                         = $True
                    PasswordMinimumCharacterSetCount                = 25
                    PasswordMinutesOfInactivityBeforeLock           = 25
                    ClassroomForceUnpromptedAppAndDeviceLock        = $True
                    PasswordMinutesUntilFailedLoginReset            = 25
                    Ensure                                          = 'Present'
                    Credential                                      = $Credential
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneDeviceConfigurationPolicyMacOS' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceConfigurationPolicyMacOS' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name 'The IntuneDeviceConfigurationPolicyMacOS exists and values are NOT in the desired state' -Fixture {
            BeforeAll {
                $testParams = @{
                    TouchIdTimeoutInHours                           = 7 # Updated property
                    Description                                     = 'FakeStringValue'
                    AirDropBlocked                                  = $True
                    ClassroomAppForceUnpromptedScreenObservation    = $True
                    KeychainBlockCloudSync                          = $True
                    DisplayName                                     = 'FakeStringValue'
                    AppleWatchBlockAutoUnlock                       = $True
                    ScreenCaptureBlocked                            = $True
                    MultiplayerGamingBlocked                        = $True
                    WallpaperModificationBlocked                    = $True
                    CameraBlocked                                   = $True
                    ICloudBlockActivityContinuation                 = $True
                    SpotlightBlockInternetResults                   = $True
                    SafariBlockAutofill                             = $True
                    PasswordBlockAutoFill                           = $True
                    PasswordRequiredType                            = 'deviceDefault'
                    PasswordMaximumAttemptCount                     = 25
                    ClassroomForceAutomaticallyJoinClasses          = $True
                    ICloudPrivateRelayBlocked                       = $True
                    PasswordBlockModification                       = $True
                    ICloudBlockCalendar                             = $True
                    ICloudBlockAddressBook                          = $True
                    SoftwareUpdatesEnforcedDelayInDays              = 25
                    ICloudBlockReminders                            = $True
                    PasswordBlockSimple                             = $True
                    PasswordBlockAirDropSharing                     = $True
                    ICloudBlockBookmarks                            = $True
                    PasswordRequired                                = $True
                    KeyboardBlockDictation                          = $True
                    SoftwareUpdateMajorOSDeferredInstallDelayInDays = 25
                    ContentCachingBlocked                           = $True
                    ICloudDesktopAndDocumentsBlocked                = $True
                    UpdateDelayPolicy                               = 'delayMajorOsUpdateVisibility'
                    PasswordPreviousPasswordBlockCount              = 25
                    ActivationLockWhenSupervisedAllowed             = $False # Updated property
                    AddingGameCenterFriendsBlocked                  = $True
                    Id                                              = 'FakeStringValue'
                    PasswordMinimumLength                           = 25
                    EraseContentAndSettingsBlocked                  = $True
                    ICloudBlockNotes                                = $True
                    ICloudBlockPhotoLibrary                         = $True
                    ICloudBlockMail                                 = $True
                    PasswordMinutesOfInactivityBeforeScreenTimeout  = 25
                    PasswordExpirationDays                          = 25
                    PasswordBlockFingerprintUnlock                  = $True
                    PasswordBlockProximityRequests                  = $True
                    SoftwareUpdateNonOSDeferredInstallDelayInDays   = 25
                    ITunesBlockMusicService                         = $True
                    DefinitionLookupBlocked                         = $True
                    ClassroomForceRequestPermissionToLeaveClasses   = $True
                    ClassroomAppBlockRemoteScreenObservation        = $True
                    SoftwareUpdateMinorOSDeferredInstallDelayInDays = 25
                    ITunesBlockFileSharing                          = $True
                    GameCenterBlocked                               = $True
                    ICloudBlockDocumentSync                         = $True
                    PasswordMinimumCharacterSetCount                = 25
                    PasswordMinutesOfInactivityBeforeLock           = 25
                    ClassroomForceUnpromptedAppAndDeviceLock        = $True
                    PasswordMinutesUntilFailedLoginReset            = 25
                    Ensure                                          = 'Present'
                    Credential                                      = $Credential
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneDeviceConfigurationPolicyMacOS' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceConfigurationPolicyMacOS' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceConfigurationPolicyMacOS' -Property $testParams).Set()
                Should -Invoke -CommandName Update-MgBetaDeviceManagementDeviceConfiguration -Exactly 1
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
                $result = Invoke-M365DSCResourceMethod -ResourceName 'IntuneDeviceConfigurationPolicyMacOS' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
