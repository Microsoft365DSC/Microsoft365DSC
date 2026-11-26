<#
This example is used to test new resources and showcase the usage of new resources being worked on.
It is not meant to use as a production baseline.
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
        IntuneDeviceFeaturesConfigurationPolicyMacOS 'IntuneDeviceFeaturesConfigurationPolicyMacOS-Example'
        {
            AdminShowHostInfo                        = $true;
            AirPrintDestinations                     = @(
                MSFT_MicrosoftGraphAirPrintDestination{
                    ForceTls     = $true
                    IpAddress    = "10.20.30.40"
                    Port         = 631
                    ResourcePath = "printers/Design-Colour-01"
                }
            );
            AppAssociatedDomains                     = @(
                MSFT_MicrosoftGraphMacOSAssociatedDomainsItem{
                    ApplicationIdentifier  = "com.contoso.intranet"
                    DirectDownloadsEnabled = $false
                    Domains                = @("webcredentials:intranet.contoso.com", "applinks:intranet.contoso.com")
                }
            );
            Assignments                              = @(
                MSFT_DeviceManagementConfigurationPolicyAssignments{
                    dataType                                   = "#microsoft.graph.allDevicesAssignmentTarget"
                    deviceAndAppManagementAssignmentFilterType = "none"
                }
                MSFT_DeviceManagementConfigurationPolicyAssignments{
                    dataType                                   = "#microsoft.graph.exclusionGroupAssignmentTarget"
                    deviceAndAppManagementAssignmentFilterType = "none"
                    groupDisplayName                           = "Intune Excluded Devices"
                }
            );
            AuthorizedUsersListHidden                = $false;
            AuthorizedUsersListHideAdminUsers        = $true;
            AuthorizedUsersListHideLocalUsers        = $false;
            AuthorizedUsersListHideMobileAccounts    = $false;
            AuthorizedUsersListIncludeNetworkUsers   = $true;
            AuthorizedUsersListShowOtherManagedUsers = $false;
            AutoLaunchItems                          = @(
                MSFT_MicrosoftGraphMacOSLaunchItem{
                    Hide = $true
                    Path = "/Applications/Microsoft Teams.app"
                }
            );
            ConsoleAccessDisabled                    = $true;
            ContentCachingBlockDeletion              = $false;
            ContentCachingClientListenRanges         = @(
                MSFT_MicrosoftGraphIpRange2{
                    LowerAddress = "10.20.0.1"
                    ODataType    = "#microsoft.graph.iPv4Range"
                    UpperAddress = "10.20.255.254"
                }
            );
            ContentCachingClientPolicy               = "clientsInLocalNetwork";
            ContentCachingDataPath                   = "/Volumes/CacheDisk/Library/Application Support/Apple/AssetCache/Data"; # Updated Property
            ContentCachingDisableConnectionSharing   = $false;
            ContentCachingEnabled                    = $true;
            ContentCachingForceConnectionSharing     = $false;
            ContentCachingKeepAwake                  = $true;
            ContentCachingLogClientIdentities        = $true;
            ContentCachingMaxSizeBytes               = 107374182400;
            ContentCachingParents                    = @("mac-cache-01.contoso.com", "mac-cache-02.contoso.com");
            ContentCachingParentSelectionPolicy      = "roundRobin";
            ContentCachingPeerFilterRanges           = @(
                MSFT_MicrosoftGraphIpRange2{
                    LowerAddress = "10.20.0.1"
                    ODataType    = "#microsoft.graph.iPv4Range"
                    UpperAddress = "10.20.255.254"
                }
            );
            ContentCachingPeerListenRanges           = @(
                MSFT_MicrosoftGraphIpRange2{
                    LowerAddress = "10.20.0.1"
                    ODataType    = "#microsoft.graph.iPv4Range"
                    UpperAddress = "10.20.255.254"
                }
            );
            ContentCachingPeerPolicy                 = "peersInLocalNetwork";
            ContentCachingPort                       = 49152;
            ContentCachingPublicRanges               = @(
                MSFT_MicrosoftGraphIpRange2{
                    LowerAddress = "10.20.0.1"
                    ODataType    = "#microsoft.graph.iPv4Range"
                    UpperAddress = "10.20.255.254"
                }
            );
            ContentCachingShowAlerts                 = $true;
            ContentCachingType                       = "userContentOnly";
            Description                              = "Login window branding and content caching for managed Macs";
            DisplayName                              = "macOS Device Features";
            LoginWindowText                          = "Property of Contoso. Unauthorized use is prohibited.";
            LogOutDisabledWhileLoggedIn              = $false;
            MacOSSingleSignOnExtension               = MSFT_MicrosoftGraphMacOSSingleSignOnExtension{
                ActiveDirectorySiteCode                  = "EMEA-ZRH"
                BlockActiveDirectorySiteAutoDiscovery    = $false
                BlockAutomaticLogin                      = $false
                CacheName                                = "CONTOSO.COM"
                CredentialBundleIdAccessControlList      = @("com.apple.Safari", "com.microsoft.edgemac")
                CredentialsCacheMonitored                = $true
                DomainRealms                             = @("contoso.com", "corp.contoso.com")
                Domains                                  = @("contoso.com", "corp.contoso.com")
                IsDefaultRealm                           = $true
                KerberosAppsInBundleIdACLIncluded        = $true
                ManagedAppsInBundleIdACLIncluded         = $true
                ModeCredentialUsed                       = "Password"
                ODataType                                = "#microsoft.graph.macOSKerberosSingleSignOnExtension"
                PasswordBlockModification                = $false
                PasswordChangeUrl                        = "https://passwordreset.contoso.com"
                PasswordEnableLocalSync                  = $true
                PasswordExpirationDays                   = 90
                PasswordExpirationNotificationDays       = 14
                PasswordMinimumAgeDays                   = 1
                PasswordMinimumLength                    = 12
                PasswordPreviousPasswordBlockCount       = 5
                PasswordRequireActiveDirectoryComplexity = $true
                PasswordRequirementsDescription          = "At least 12 characters, with an upper case letter, a lower case letter and a number"
                PreferredKDCs                            = @("kdc01.contoso.com", "kdc02.contoso.com")
                Realm                                    = "CONTOSO.COM"
                RequireUserPresence                      = $true
                SignInHelpText                           = "Sign in with your Contoso account"
                TlsForLDAPRequired                       = $true
                UsernameLabelCustom                      = "Contoso account"
                UserPrincipalName                        = "mac.admin@$TenantId"
                UserSetupDelayed                         = $false
            };
            PowerOffDisabledWhileLoggedIn            = $false;
            RestartDisabled                          = $false;
            RestartDisabledWhileLoggedIn             = $false;
            RoleScopeTagIds                          = @("0");
            ScreenLockDisableImmediate               = $false;
            ShutDownDisabled                         = $false;
            ShutDownDisabledWhileLoggedIn            = $false;
            SleepDisabled                            = $false;
            Ensure                                   = "Present";
            ApplicationId                            = $ApplicationId;
            TenantId                                 = $TenantId;
            CertificateThumbprint                    = $CertificateThumbprint;
        }
    }
}
