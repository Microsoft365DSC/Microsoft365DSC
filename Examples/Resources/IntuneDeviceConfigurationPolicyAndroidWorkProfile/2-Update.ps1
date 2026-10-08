<#
This example creates a new General Device Configuration Policy for Android WorkProfile .
#>

Configuration Example
{
    param
    (
        [Parameter()]
        [System.String]
        $ApplicationId,

        [Parameter()]
        [System.String]
        $TenantId,

        [Parameter()]
        [System.String]
        $CertificateThumbprint
    )

    Import-DscResource -ModuleName Microsoft365DSC

    Node localhost
    {
        IntuneDeviceConfigurationPolicyAndroidWorkProfile "IntuneDeviceConfigurationPolicyAndroidWorkProfile-Example"
        {
            DisplayName                                               = 'Android Work Profile - Device Restrictions - Standard'
            Description                                               = "Work profile restrictions for personally owned Android phones"
            RoleScopeTagIds                                           = @("0")
            AllowedGoogleAccountDomains                               = @("contoso.com")
            BlockUnifiedPasswordForWorkProfile                        = $true
            PasswordBlockFaceUnlock                                   = $true
            PasswordBlockFingerprintUnlock                            = $false
            PasswordBlockIrisUnlock                                   = $true
            PasswordBlockTrustAgents                                  = $true # Updated Property
            PasswordExpirationDays                                    = 365
            PasswordMinimumLength                                     = 6
            PasswordMinutesOfInactivityBeforeScreenTimeout            = 15
            PasswordPreviousPasswordBlockCount                        = 5
            PasswordSignInFailureCountBeforeFactoryReset              = 10
            PasswordRequiredType                                      = "atLeastNumeric"
            RequiredPasswordComplexity                                = "medium"
            SecurityRequireVerifyApps                                 = $true
            VpnAlwaysOnPackageIdentifier                              = "com.microsoft.scmx"
            VpnEnableAlwaysOnLockdownMode                             = $false
            WorkProfileAccountUse                                     = "allowAllExceptGoogleAccounts"
            WorkProfileAllowAppInstallsFromUnknownSources             = $false
            WorkProfileAllowWidgets                                   = $true
            WorkProfileBlockAddingAccounts                            = $false
            WorkProfileBlockCamera                                    = $false
            WorkProfileBlockCrossProfileCallerId                      = $false
            WorkProfileBlockCrossProfileContactsSearch                = $false
            WorkProfileBlockCrossProfileCopyPaste                     = $true
            WorkProfileBlockNotificationsWhileDeviceLocked            = $true
            WorkProfileBlockPersonalAppInstallsFromUnknownSources     = $true
            WorkProfileBlockScreenCapture                             = $true
            WorkProfileBluetoothEnableContactSharing                  = $false
            WorkProfileDataSharingType                                = "allowPersonalToWork"
            WorkProfileDefaultAppPermissionPolicy                     = "prompt"
            WorkProfilePasswordBlockFaceUnlock                        = $true
            WorkProfilePasswordBlockFingerprintUnlock                 = $false
            WorkProfilePasswordBlockIrisUnlock                        = $true
            WorkProfilePasswordBlockTrustAgents                       = $false
            WorkProfilePasswordExpirationDays                         = 365
            WorkProfilePasswordMinimumLength                          = 8
            WorkProfilePasswordMinLetterCharacters                    = 2
            WorkProfilePasswordMinLowerCaseCharacters                 = 1
            WorkProfilePasswordMinNonLetterCharacters                 = 2
            WorkProfilePasswordMinNumericCharacters                   = 1
            WorkProfilePasswordMinSymbolCharacters                    = 1
            WorkProfilePasswordMinUpperCaseCharacters                 = 1
            WorkProfilePasswordMinutesOfInactivityBeforeScreenTimeout = 15
            WorkProfilePasswordPreviousPasswordBlockCount             = 5
            WorkProfilePasswordRequiredType                           = "alphanumericWithSymbols"
            WorkProfilePasswordSignInFailureCountBeforeFactoryReset   = 10
            WorkProfileRequirePassword                                = $true
            WorkProfileRequiredPasswordComplexity                     = "high"
            Assignments                                               = @(
                MSFT_DeviceManagementConfigurationPolicyAssignments{
                    dataType                                   = "#microsoft.graph.allLicensedUsersAssignmentTarget"
                    deviceAndAppManagementAssignmentFilterType = "none"
                }
                MSFT_DeviceManagementConfigurationPolicyAssignments{
                    dataType                                   = "#microsoft.graph.exclusionGroupAssignmentTarget"
                    deviceAndAppManagementAssignmentFilterType = "none"
                    groupDisplayName                           = "Intune Excluded Users"
                }
            )
            Ensure                                                    = "Present"
            ApplicationId                                             = $ApplicationId;
            TenantId                                                  = $TenantId;
            CertificateThumbprint                                     = $CertificateThumbprint;
        }
    }
}
