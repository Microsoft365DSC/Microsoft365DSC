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
    -DscResource 'IntuneDeviceFeaturesConfigurationPolicyMacOS' -GenericStubModule $GenericStubPath
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

            Mock -CommandName New-MgBetaDeviceManagementDeviceConfiguration -MockWith {
            }

            Mock -CommandName Update-MgBetaDeviceManagementDeviceConfiguration -MockWith {
            }

            Mock -CommandName Remove-MgBetaDeviceManagementDeviceConfiguration -MockWith {
            }

            Mock -CommandName Get-MgBetaDeviceManagementDeviceConfiguration -MockWith {
                return @{
                    Assignments                              = @(
                        @{
                            dataType                                   = '#microsoft.graph.allDevicesAssignmentTarget'
                            deviceAndAppManagementAssignmentFilterType = 'none'
                        }
                    )
                    Description                              = 'FakeStringValue'
                    DisplayName                              = 'FakeStringValue'
                    Id                                       = 'FakeStringValue'
                    RoleScopeTagIds                          = @('FakeStringArrayValue1', 'FakeStringArrayValue2')
                    '@odata.type'                            = '#microsoft.graph.macOSDeviceFeaturesConfiguration'
                    adminShowHostInfo                        = $true
                    airPrintDestinations                     = @(
                        @{
                            forceTls     = $true
                            ipAddress    = 'FakeStringValue'
                            port         = 25
                            resourcePath = 'FakeStringValue'
                        }
                    )
                    appAssociatedDomains                     = @(
                        @{
                            applicationIdentifier  = 'FakeStringValue'
                            directDownloadsEnabled = $true
                            domains                = @('FakeStringArrayValue1', 'FakeStringArrayValue2')
                        }
                    )
                    associatedDomains                        = @(
                        @{
                            name  = 'FakeStringValue'
                            value = 'FakeStringValue'
                        }
                    )
                    authorizedUsersListHidden                = $true
                    authorizedUsersListHideAdminUsers        = $true
                    authorizedUsersListHideLocalUsers        = $true
                    authorizedUsersListHideMobileAccounts    = $true
                    authorizedUsersListIncludeNetworkUsers   = $true
                    authorizedUsersListShowOtherManagedUsers = $true
                    autoLaunchItems                          = @(
                        @{
                            hide = $true
                            path = 'FakeStringValue'
                        }
                    )
                    consoleAccessDisabled                    = $true
                    contentCachingBlockDeletion              = $true
                    contentCachingClientListenRanges         = @(
                        @{
                            lowerAddress  = 'FakeStringValue'
                            '@odata.type' = '#microsoft.graph.iPv4Range'
                            upperAddress  = 'FakeStringValue'
                        }
                    )
                    contentCachingClientPolicy               = 'notConfigured'
                    contentCachingDataPath                   = 'FakeStringValue'
                    contentCachingDisableConnectionSharing   = $true
                    contentCachingEnabled                    = $true
                    contentCachingForceConnectionSharing     = $true
                    contentCachingKeepAwake                  = $true
                    contentCachingLogClientIdentities        = $true
                    contentCachingMaxSizeBytes               = 25
                    contentCachingParents                    = @('FakeStringArrayValue1', 'FakeStringArrayValue2')
                    contentCachingParentSelectionPolicy      = 'notConfigured'
                    contentCachingPeerFilterRanges           = @(
                        @{
                            lowerAddress  = 'FakeStringValue'
                            '@odata.type' = '#microsoft.graph.iPv4Range'
                            upperAddress  = 'FakeStringValue'
                        }
                    )
                    contentCachingPeerListenRanges           = @(
                        @{
                            lowerAddress  = 'FakeStringValue'
                            '@odata.type' = '#microsoft.graph.iPv4Range'
                            upperAddress  = 'FakeStringValue'
                        }
                    )
                    contentCachingPeerPolicy                 = 'notConfigured'
                    contentCachingPort                       = 25
                    contentCachingPublicRanges               = @(
                        @{
                            lowerAddress  = 'FakeStringValue'
                            '@odata.type' = '#microsoft.graph.iPv4Range'
                            upperAddress  = 'FakeStringValue'
                        }
                    )
                    contentCachingShowAlerts                 = $true
                    contentCachingType                       = 'notConfigured'
                    loginWindowText                          = 'FakeStringValue'
                    logOutDisabledWhileLoggedIn              = $true
                    macOSSingleSignOnExtension               = @{
                        activeDirectorySiteCode                  = 'FakeStringValue'
                        blockActiveDirectorySiteAutoDiscovery    = $true
                        blockAutomaticLogin                      = $true
                        bundleIdAccessControlList                = @('FakeStringArrayValue1', 'FakeStringArrayValue2')
                        cacheName                                = 'FakeStringValue'
                        configurations                           = @{
                            key           = 'FakeStringValue'
                            '@odata.type' = '#microsoft.graph.keyBooleanValuePair'
                            value         = $true
                        }
                        credentialBundleIdAccessControlList      = @('FakeStringArrayValue1', 'FakeStringArrayValue2')
                        credentialsCacheMonitored                = $true
                        domainRealms                             = @('FakeStringArrayValue1', 'FakeStringArrayValue2')
                        domains                                  = @('FakeStringArrayValue1', 'FakeStringArrayValue2')
                        enableSharedDeviceMode                   = $true
                        extensionIdentifier                      = 'FakeStringValue'
                        isDefaultRealm                           = $true
                        kerberosAppsInBundleIdACLIncluded        = $true
                        managedAppsInBundleIdACLIncluded         = $true
                        modeCredentialUsed                       = 'FakeStringValue'
                        '@odata.type'                            = '#microsoft.graph.macOSAzureAdSingleSignOnExtension'
                        passwordBlockModification                = $true
                        passwordChangeUrl                        = 'FakeStringValue'
                        passwordEnableLocalSync                  = $true
                        passwordExpirationDays                   = 25
                        passwordExpirationNotificationDays       = 25
                        passwordMinimumAgeDays                   = 25
                        passwordMinimumLength                    = 25
                        passwordPreviousPasswordBlockCount       = 25
                        passwordRequireActiveDirectoryComplexity = $true
                        passwordRequirementsDescription          = 'FakeStringValue'
                        preferredKDCs                            = @('FakeStringArrayValue1', 'FakeStringArrayValue2', 'FakeStringArrayValue1', 'FakeStringArrayValue2')
                        realm                                    = 'FakeStringValue'
                        requireUserPresence                      = $true
                        signInHelpText                           = 'FakeStringValue'
                        teamIdentifier                           = 'FakeStringValue'
                        tlsForLDAPRequired                       = $true
                        urlPrefixes                              = @('FakeStringArrayValue1', 'FakeStringArrayValue2')
                        usernameLabelCustom                      = 'FakeStringValue'
                        userPrincipalName                        = 'FakeStringValue'
                        userSetupDelayed                         = $true
                    }
                    powerOffDisabledWhileLoggedIn            = $true
                    restartDisabled                          = $true
                    restartDisabledWhileLoggedIn             = $true
                    screenLockDisableImmediate               = $true
                    shutDownDisabled                         = $true
                    shutDownDisabledWhileLoggedIn            = $true
                    singleSignOnExtension                    = @{
                        activeDirectorySiteCode                  = 'FakeStringValue'
                        blockActiveDirectorySiteAutoDiscovery    = $true
                        blockAutomaticLogin                      = $true
                        cacheName                                = 'FakeStringValue'
                        configurations                           = @{
                            key           = 'FakeStringValue'
                            '@odata.type' = '#microsoft.graph.keyBooleanValuePair'
                            value         = $true
                        }
                        credentialBundleIdAccessControlList      = @('FakeStringArrayValue1', 'FakeStringArrayValue2')
                        domainRealms                             = @('FakeStringArrayValue1', 'FakeStringArrayValue2')
                        domains                                  = @('FakeStringArrayValue1', 'FakeStringArrayValue2')
                        extensionIdentifier                      = 'FakeStringValue'
                        isDefaultRealm                           = $true
                        '@odata.type'                            = '#microsoft.graph.credentialSingleSignOnExtension'
                        passwordBlockModification                = $true
                        passwordChangeUrl                        = 'FakeStringValue'
                        passwordEnableLocalSync                  = $true
                        passwordExpirationDays                   = 25
                        passwordExpirationNotificationDays       = 25
                        passwordMinimumAgeDays                   = 25
                        passwordMinimumLength                    = 25
                        passwordPreviousPasswordBlockCount       = 25
                        passwordRequireActiveDirectoryComplexity = $true
                        passwordRequirementsDescription          = 'FakeStringValue'
                        realm                                    = 'FakeStringValue'
                        requireUserPresence                      = $true
                        teamIdentifier                           = 'FakeStringValue'
                        urlPrefixes                              = @('FakeStringArrayValue1', 'FakeStringArrayValue2')
                        userPrincipalName                        = 'FakeStringValue'
                    }
                    sleepDisabled                            = $true
                }
            }

            Mock -CommandName Get-M365DSCExportCachedCollection -MockWith {
                return Get-MgBetaDeviceManagementDeviceConfiguration
            }
            Mock -CommandName Get-MgBetaDeviceManagementDeviceConfigurationAssignment -MockWith {
            }

            Mock -CommandName Update-DeviceConfigurationPolicyAssignment -MockWith {
            }

            Mock -CommandName Write-M365DSCHost -MockWith {
            }

            Mock -CommandName Save-M365DSCPartialExport -MockWith {
            }

            Mock -CommandName Update-M365DSCExportAuthenticationResults -MockWith {
                return @{}
            }

            Mock -CommandName Get-M365DSCExportContentForResource -MockWith {
                return "IntuneDeviceFeaturesConfigurationPolicyMacOS 'TestInstance' {}`r`n"
            }

            $Script:exportedInstance = $null
            $Script:exportedInstances = $null
            $Script:ExportMode = $false
        }

        # Test contexts
        Context -Name 'The instance should exist but it DOES NOT' -Fixture {
            BeforeAll {
                $testParams = @{
                    AdminShowHostInfo                        = $true
                    AirPrintDestinations                     = @{
                        ForceTls     = $true
                        IpAddress    = 'FakeStringValue'
                        Port         = 25
                        ResourcePath = 'FakeStringValue'
                    }
                    AppAssociatedDomains                     = @{
                        ApplicationIdentifier  = 'FakeStringValue'
                        DirectDownloadsEnabled = $true
                        Domains                = @('FakeStringArrayValue1', 'FakeStringArrayValue2')
                    }
                    AssociatedDomains                        = @{
                        Name  = 'FakeStringValue'
                        Value = 'FakeStringValue'
                    }
                    AuthorizedUsersListHidden                = $true
                    AuthorizedUsersListHideAdminUsers        = $true
                    AuthorizedUsersListHideLocalUsers        = $true
                    AuthorizedUsersListHideMobileAccounts    = $true
                    AuthorizedUsersListIncludeNetworkUsers   = $true
                    AuthorizedUsersListShowOtherManagedUsers = $true
                    AutoLaunchItems                          = @{
                        Hide = $true
                        Path = 'FakeStringValue'
                    }
                    ConsoleAccessDisabled                    = $true
                    ContentCachingBlockDeletion              = $true
                    ContentCachingClientListenRanges         = @{
                        LowerAddress = 'FakeStringValue'
                        ODataType    = '#microsoft.graph.iPv4Range'
                        UpperAddress = 'FakeStringValue'
                    }
                    ContentCachingClientPolicy               = 'notConfigured'
                    ContentCachingDataPath                   = 'FakeStringValue'
                    ContentCachingDisableConnectionSharing   = $true
                    ContentCachingEnabled                    = $true
                    ContentCachingForceConnectionSharing     = $true
                    ContentCachingKeepAwake                  = $true
                    ContentCachingLogClientIdentities        = $true
                    ContentCachingMaxSizeBytes               = 25
                    ContentCachingParents                    = @('FakeStringArrayValue1', 'FakeStringArrayValue2')
                    ContentCachingParentSelectionPolicy      = 'notConfigured'
                    ContentCachingPeerFilterRanges           = @{
                        LowerAddress = 'FakeStringValue'
                        ODataType    = '#microsoft.graph.iPv4Range'
                        UpperAddress = 'FakeStringValue'
                    }
                    ContentCachingPeerListenRanges           = @{
                        LowerAddress = 'FakeStringValue'
                        ODataType    = '#microsoft.graph.iPv4Range'
                        UpperAddress = 'FakeStringValue'
                    }
                    ContentCachingPeerPolicy                 = 'notConfigured'
                    ContentCachingPort                       = 25
                    ContentCachingPublicRanges               = @{
                        LowerAddress = 'FakeStringValue'
                        ODataType    = '#microsoft.graph.iPv4Range'
                        UpperAddress = 'FakeStringValue'
                    }
                    ContentCachingShowAlerts                 = $true
                    ContentCachingType                       = 'notConfigured'
                    Description                              = 'FakeStringValue'
                    DisplayName                              = 'FakeStringValue'
                    Id                                       = 'FakeStringValue'
                    LoginWindowText                          = 'FakeStringValue'
                    LogOutDisabledWhileLoggedIn              = $true
                    MacOSSingleSignOnExtension               = @{
                        ActiveDirectorySiteCode                  = 'FakeStringValue'
                        BlockActiveDirectorySiteAutoDiscovery    = $true
                        BlockAutomaticLogin                      = $true
                        BundleIdAccessControlList                = @('FakeStringArrayValue1', 'FakeStringArrayValue2')
                        CacheName                                = 'FakeStringValue'
                        Configurations                           = @{
                            Key       = 'FakeStringValue'
                            ODataType = '#microsoft.graph.keyBooleanValuePair'
                            Value     = $true
                        }
                        CredentialBundleIdAccessControlList      = @('FakeStringArrayValue1', 'FakeStringArrayValue2')
                        CredentialsCacheMonitored                = $true
                        DomainRealms                             = @('FakeStringArrayValue1', 'FakeStringArrayValue2')
                        Domains                                  = @('FakeStringArrayValue1', 'FakeStringArrayValue2')
                        EnableSharedDeviceMode                   = $true
                        ExtensionIdentifier                      = 'FakeStringValue'
                        IsDefaultRealm                           = $true
                        KerberosAppsInBundleIdACLIncluded        = $true
                        ManagedAppsInBundleIdACLIncluded         = $true
                        ModeCredentialUsed                       = 'FakeStringValue'
                        ODataType                                = '#microsoft.graph.macOSAzureAdSingleSignOnExtension'
                        PasswordBlockModification                = $true
                        PasswordChangeUrl                        = 'FakeStringValue'
                        PasswordEnableLocalSync                  = $true
                        PasswordExpirationDays                   = 25
                        PasswordExpirationNotificationDays       = 25
                        PasswordMinimumAgeDays                   = 25
                        PasswordMinimumLength                    = 25
                        PasswordPreviousPasswordBlockCount       = 25
                        PasswordRequireActiveDirectoryComplexity = $true
                        PasswordRequirementsDescription          = 'FakeStringValue'
                        PreferredKDCs                            = @('FakeStringArrayValue1', 'FakeStringArrayValue2')
                        Realm                                    = 'FakeStringValue'
                        RequireUserPresence                      = $true
                        SignInHelpText                           = 'FakeStringValue'
                        TeamIdentifier                           = 'FakeStringValue'
                        TlsForLDAPRequired                       = $true
                        UrlPrefixes                              = @('FakeStringArrayValue1', 'FakeStringArrayValue2')
                        UsernameLabelCustom                      = 'FakeStringValue'
                        UserPrincipalName                        = 'FakeStringValue'
                        UserSetupDelayed                         = $true
                    }
                    PowerOffDisabledWhileLoggedIn            = $true
                    RestartDisabled                          = $true
                    RestartDisabledWhileLoggedIn             = $true
                    RoleScopeTagIds                          = @('FakeStringArrayValue1', 'FakeStringArrayValue2')
                    ScreenLockDisableImmediate               = $true
                    ShutDownDisabled                         = $true
                    ShutDownDisabledWhileLoggedIn            = $true
                    SingleSignOnExtension                    = @{
                        ActiveDirectorySiteCode                  = 'FakeStringValue'
                        BlockActiveDirectorySiteAutoDiscovery    = $true
                        BlockAutomaticLogin                      = $true
                        CacheName                                = 'FakeStringValue'
                        Configurations                           = @{
                            Key       = 'FakeStringValue'
                            ODataType = '#microsoft.graph.keyBooleanValuePair'
                            Value     = $true
                        }
                        CredentialBundleIdAccessControlList      = @('FakeStringArrayValue1', 'FakeStringArrayValue2')
                        DomainRealms                             = @('FakeStringArrayValue1', 'FakeStringArrayValue2')
                        Domains                                  = @('FakeStringArrayValue1', 'FakeStringArrayValue2')
                        ExtensionIdentifier                      = 'FakeStringValue'
                        IsDefaultRealm                           = $true
                        ODataType                                = '#microsoft.graph.credentialSingleSignOnExtension'
                        PasswordBlockModification                = $true
                        PasswordChangeUrl                        = 'FakeStringValue'
                        PasswordEnableLocalSync                  = $true
                        PasswordExpirationDays                   = 25
                        PasswordExpirationNotificationDays       = 25
                        PasswordMinimumAgeDays                   = 25
                        PasswordMinimumLength                    = 25
                        PasswordPreviousPasswordBlockCount       = 25
                        PasswordRequireActiveDirectoryComplexity = $true
                        PasswordRequirementsDescription          = 'FakeStringValue'
                        Realm                                    = 'FakeStringValue'
                        RequireUserPresence                      = $true
                        TeamIdentifier                           = 'FakeStringValue'
                        UrlPrefixes                              = @('FakeStringArrayValue1', 'FakeStringArrayValue2')
                        UserPrincipalName                        = 'FakeStringValue'
                    }
                    SleepDisabled                            = $true
                    Ensure                                   = 'Present'
                    Credential                               = $Credential
                }

                Mock -CommandName Get-MgBetaDeviceManagementDeviceConfiguration -MockWith {
                    return $null
                }
            }

            It 'Should return Absent from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneDeviceFeaturesConfigurationPolicyMacOS' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
                Should -Invoke -CommandName 'Get-MgBetaDeviceManagementDeviceConfiguration'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceFeaturesConfigurationPolicyMacOS' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should create the instance from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceFeaturesConfigurationPolicyMacOS' -Property $testParams).Set()
                Should -Invoke -CommandName 'New-MgBetaDeviceManagementDeviceConfiguration' -Exactly 1
            }
        }

        Context -Name 'The instance exists but it SHOULD NOT' -Fixture {
            BeforeAll {
                $testParams = @{
                    DisplayName = 'FakeStringValue'
                    Ensure      = 'Absent'
                    Credential  = $Credential
                }
            }

            It 'Should return Present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneDeviceFeaturesConfigurationPolicyMacOS' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
                Should -Invoke -CommandName 'Get-MgBetaDeviceManagementDeviceConfiguration'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceFeaturesConfigurationPolicyMacOS' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should remove the instance from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceFeaturesConfigurationPolicyMacOS' -Property $testParams).Set()
                Should -Invoke -CommandName 'Remove-MgBetaDeviceManagementDeviceConfiguration' -Exactly 1
            }
        }

        Context -Name 'The instance exists and values are already in the desired state' -Fixture {
            BeforeAll {
                $testParams = @{
                    AdminShowHostInfo                        = $true
                    AirPrintDestinations                     = @{
                        ForceTls     = $true
                        IpAddress    = 'FakeStringValue'
                        Port         = 25
                        ResourcePath = 'FakeStringValue'
                    }
                    AppAssociatedDomains                     = @{
                        ApplicationIdentifier  = 'FakeStringValue'
                        DirectDownloadsEnabled = $true
                        Domains                = @('FakeStringArrayValue1', 'FakeStringArrayValue2')
                    }
                    AssociatedDomains                        = @{
                        Name  = 'FakeStringValue'
                        Value = 'FakeStringValue'
                    }
                    AuthorizedUsersListHidden                = $true
                    AuthorizedUsersListHideAdminUsers        = $true
                    AuthorizedUsersListHideLocalUsers        = $true
                    AuthorizedUsersListHideMobileAccounts    = $true
                    AuthorizedUsersListIncludeNetworkUsers   = $true
                    AuthorizedUsersListShowOtherManagedUsers = $true
                    AutoLaunchItems                          = @{
                        Hide = $true
                        Path = 'FakeStringValue'
                    }
                    ConsoleAccessDisabled                    = $true
                    ContentCachingBlockDeletion              = $true
                    ContentCachingClientListenRanges         = @{
                        LowerAddress = 'FakeStringValue'
                        ODataType    = '#microsoft.graph.iPv4Range'
                        UpperAddress = 'FakeStringValue'
                    }
                    ContentCachingClientPolicy               = 'notConfigured'
                    ContentCachingDataPath                   = 'FakeStringValue'
                    ContentCachingDisableConnectionSharing   = $true
                    ContentCachingEnabled                    = $true
                    ContentCachingForceConnectionSharing     = $true
                    ContentCachingKeepAwake                  = $true
                    ContentCachingLogClientIdentities        = $true
                    ContentCachingMaxSizeBytes               = 25
                    ContentCachingParents                    = @('FakeStringArrayValue1', 'FakeStringArrayValue2')
                    ContentCachingParentSelectionPolicy      = 'notConfigured'
                    ContentCachingPeerFilterRanges           = @{
                        LowerAddress = 'FakeStringValue'
                        ODataType    = '#microsoft.graph.iPv4Range'
                        UpperAddress = 'FakeStringValue'
                    }
                    ContentCachingPeerListenRanges           = @{
                        LowerAddress = 'FakeStringValue'
                        ODataType    = '#microsoft.graph.iPv4Range'
                        UpperAddress = 'FakeStringValue'
                    }
                    ContentCachingPeerPolicy                 = 'notConfigured'
                    ContentCachingPort                       = 25
                    ContentCachingPublicRanges               = @{
                        LowerAddress = 'FakeStringValue'
                        ODataType    = '#microsoft.graph.iPv4Range'
                        UpperAddress = 'FakeStringValue'
                    }
                    ContentCachingShowAlerts                 = $true
                    ContentCachingType                       = 'notConfigured'
                    Description                              = 'FakeStringValue'
                    DisplayName                              = 'FakeStringValue'
                    Id                                       = 'FakeStringValue'
                    LoginWindowText                          = 'FakeStringValue'
                    LogOutDisabledWhileLoggedIn              = $true
                    MacOSSingleSignOnExtension               = @{
                        ActiveDirectorySiteCode                  = 'FakeStringValue'
                        BlockActiveDirectorySiteAutoDiscovery    = $true
                        BlockAutomaticLogin                      = $true
                        BundleIdAccessControlList                = @('FakeStringArrayValue1', 'FakeStringArrayValue2')
                        CacheName                                = 'FakeStringValue'
                        Configurations                           = @{
                            Key       = 'FakeStringValue'
                            ODataType = '#microsoft.graph.keyBooleanValuePair'
                            Value     = $true
                        }
                        CredentialBundleIdAccessControlList      = @('FakeStringArrayValue1', 'FakeStringArrayValue2')
                        CredentialsCacheMonitored                = $true
                        DomainRealms                             = @('FakeStringArrayValue1', 'FakeStringArrayValue2')
                        Domains                                  = @('FakeStringArrayValue1', 'FakeStringArrayValue2')
                        EnableSharedDeviceMode                   = $true
                        ExtensionIdentifier                      = 'FakeStringValue'
                        IsDefaultRealm                           = $true
                        KerberosAppsInBundleIdACLIncluded        = $true
                        ManagedAppsInBundleIdACLIncluded         = $true
                        ModeCredentialUsed                       = 'FakeStringValue'
                        ODataType                                = '#microsoft.graph.macOSAzureAdSingleSignOnExtension'
                        PasswordBlockModification                = $true
                        PasswordChangeUrl                        = 'FakeStringValue'
                        PasswordEnableLocalSync                  = $true
                        PasswordExpirationDays                   = 25
                        PasswordExpirationNotificationDays       = 25
                        PasswordMinimumAgeDays                   = 25
                        PasswordMinimumLength                    = 25
                        PasswordPreviousPasswordBlockCount       = 25
                        PasswordRequireActiveDirectoryComplexity = $true
                        PasswordRequirementsDescription          = 'FakeStringValue'
                        PreferredKDCs                            = @('FakeStringArrayValue1', 'FakeStringArrayValue2')
                        Realm                                    = 'FakeStringValue'
                        RequireUserPresence                      = $true
                        SignInHelpText                           = 'FakeStringValue'
                        TeamIdentifier                           = 'FakeStringValue'
                        TlsForLDAPRequired                       = $true
                        UrlPrefixes                              = @('FakeStringArrayValue1', 'FakeStringArrayValue2')
                        UsernameLabelCustom                      = 'FakeStringValue'
                        UserPrincipalName                        = 'FakeStringValue'
                        UserSetupDelayed                         = $true
                    }
                    PowerOffDisabledWhileLoggedIn            = $true
                    RestartDisabled                          = $true
                    RestartDisabledWhileLoggedIn             = $true
                    RoleScopeTagIds                          = @('FakeStringArrayValue1', 'FakeStringArrayValue2')
                    ScreenLockDisableImmediate               = $true
                    ShutDownDisabled                         = $true
                    ShutDownDisabledWhileLoggedIn            = $true
                    SingleSignOnExtension                    = @{
                        ActiveDirectorySiteCode                  = 'FakeStringValue'
                        BlockActiveDirectorySiteAutoDiscovery    = $true
                        BlockAutomaticLogin                      = $true
                        CacheName                                = 'FakeStringValue'
                        Configurations                           = @{
                            Key       = 'FakeStringValue'
                            ODataType = '#microsoft.graph.keyBooleanValuePair'
                            Value     = $true
                        }
                        CredentialBundleIdAccessControlList      = @('FakeStringArrayValue1', 'FakeStringArrayValue2')
                        DomainRealms                             = @('FakeStringArrayValue1', 'FakeStringArrayValue2')
                        Domains                                  = @('FakeStringArrayValue1', 'FakeStringArrayValue2')
                        ExtensionIdentifier                      = 'FakeStringValue'
                        IsDefaultRealm                           = $true
                        ODataType                                = '#microsoft.graph.credentialSingleSignOnExtension'
                        PasswordBlockModification                = $true
                        PasswordChangeUrl                        = 'FakeStringValue'
                        PasswordEnableLocalSync                  = $true
                        PasswordExpirationDays                   = 25
                        PasswordExpirationNotificationDays       = 25
                        PasswordMinimumAgeDays                   = 25
                        PasswordMinimumLength                    = 25
                        PasswordPreviousPasswordBlockCount       = 25
                        PasswordRequireActiveDirectoryComplexity = $true
                        PasswordRequirementsDescription          = 'FakeStringValue'
                        Realm                                    = 'FakeStringValue'
                        RequireUserPresence                      = $true
                        TeamIdentifier                           = 'FakeStringValue'
                        UrlPrefixes                              = @('FakeStringArrayValue1', 'FakeStringArrayValue2')
                        UserPrincipalName                        = 'FakeStringValue'
                    }
                    SleepDisabled                            = $true
                    Ensure                                   = 'Present'
                    Credential                               = $Credential
                }
            }

            It 'Should return the expected values from the Get method' {
                $result = (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceFeaturesConfigurationPolicyMacOS' -Property $testParams).Get().ToHashtable()
                $result.Ensure | Should -Be 'Present'
                $result.AdminShowHostInfo | Should -Be $true
                $result.AuthorizedUsersListHidden | Should -Be $true
                $result.AuthorizedUsersListHideAdminUsers | Should -Be $true
                $result.AuthorizedUsersListHideLocalUsers | Should -Be $true
                $result.AuthorizedUsersListHideMobileAccounts | Should -Be $true
                $result.AuthorizedUsersListIncludeNetworkUsers | Should -Be $true
                $result.AuthorizedUsersListShowOtherManagedUsers | Should -Be $true
                $result.ConsoleAccessDisabled | Should -Be $true
                $result.ContentCachingBlockDeletion | Should -Be $true
                $result.ContentCachingClientPolicy | Should -Be 'notConfigured'
                $result.ContentCachingDataPath | Should -Be 'FakeStringValue'
                $result.ContentCachingDisableConnectionSharing | Should -Be $true
                $result.ContentCachingEnabled | Should -Be $true
                $result.ContentCachingForceConnectionSharing | Should -Be $true
                $result.ContentCachingKeepAwake | Should -Be $true
                $result.ContentCachingLogClientIdentities | Should -Be $true
                $result.ContentCachingMaxSizeBytes | Should -Be 25
                $result.ContentCachingParents | Should -Be @('FakeStringArrayValue1', 'FakeStringArrayValue2')
                $result.ContentCachingParentSelectionPolicy | Should -Be 'notConfigured'
                $result.ContentCachingPeerPolicy | Should -Be 'notConfigured'
                $result.ContentCachingPort | Should -Be 25
                $result.ContentCachingShowAlerts | Should -Be $true
                $result.ContentCachingType | Should -Be 'notConfigured'
                $result.Description | Should -Be 'FakeStringValue'
                $result.DisplayName | Should -Be 'FakeStringValue'
                $result.Id | Should -Be 'FakeStringValue'
                $result.LoginWindowText | Should -Be 'FakeStringValue'
                $result.LogOutDisabledWhileLoggedIn | Should -Be $true
                $result.PowerOffDisabledWhileLoggedIn | Should -Be $true
                $result.RestartDisabled | Should -Be $true
                $result.RestartDisabledWhileLoggedIn | Should -Be $true
                $result.RoleScopeTagIds | Should -Be @('FakeStringArrayValue1', 'FakeStringArrayValue2')
                $result.ScreenLockDisableImmediate | Should -Be $true
                $result.ShutDownDisabled | Should -Be $true
                $result.ShutDownDisabledWhileLoggedIn | Should -Be $true
                $result.SleepDisabled | Should -Be $true
                Should -Invoke -CommandName 'Get-MgBetaDeviceManagementDeviceConfiguration'
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceFeaturesConfigurationPolicyMacOS' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name 'The instance exists and values are NOT in the desired state' -Fixture {
            BeforeAll {
                $testParams = @{
                    AdminShowHostInfo                        = $true
                    AirPrintDestinations                     = @{
                        ForceTls     = $true
                        IpAddress    = 'FakeStringValue'
                        Port         = 25
                        ResourcePath = 'FakeStringValue'
                    }
                    AppAssociatedDomains                     = @{
                        ApplicationIdentifier  = 'FakeStringValue'
                        DirectDownloadsEnabled = $true
                        Domains                = @('FakeStringArrayValue1', 'FakeStringArrayValue2')
                    }
                    AssociatedDomains                        = @{
                        Name  = 'FakeStringValue'
                        Value = 'FakeStringValue'
                    }
                    AuthorizedUsersListHidden                = $true
                    AuthorizedUsersListHideAdminUsers        = $true
                    AuthorizedUsersListHideLocalUsers        = $true
                    AuthorizedUsersListHideMobileAccounts    = $true
                    AuthorizedUsersListIncludeNetworkUsers   = $true
                    AuthorizedUsersListShowOtherManagedUsers = $true
                    AutoLaunchItems                          = @{
                        Hide = $true
                        Path = 'FakeStringValue'
                    }
                    ConsoleAccessDisabled                    = $true
                    ContentCachingBlockDeletion              = $true
                    ContentCachingClientListenRanges         = @{
                        LowerAddress = 'FakeStringValue'
                        ODataType    = '#microsoft.graph.iPv4Range'
                        UpperAddress = 'FakeStringValue'
                    }
                    ContentCachingClientPolicy               = 'notConfigured'
                    ContentCachingDataPath                   = 'FakeStringValueDrift' # Updated property
                    ContentCachingDisableConnectionSharing   = $true
                    ContentCachingEnabled                    = $true
                    ContentCachingForceConnectionSharing     = $true
                    ContentCachingKeepAwake                  = $true
                    ContentCachingLogClientIdentities        = $true
                    ContentCachingMaxSizeBytes               = 25
                    ContentCachingParents                    = @('FakeStringArrayValue1', 'FakeStringArrayValue2')
                    ContentCachingParentSelectionPolicy      = 'notConfigured'
                    ContentCachingPeerFilterRanges           = @{
                        LowerAddress = 'FakeStringValue'
                        ODataType    = '#microsoft.graph.iPv4Range'
                        UpperAddress = 'FakeStringValue'
                    }
                    ContentCachingPeerListenRanges           = @{
                        LowerAddress = 'FakeStringValue'
                        ODataType    = '#microsoft.graph.iPv4Range'
                        UpperAddress = 'FakeStringValue'
                    }
                    ContentCachingPeerPolicy                 = 'notConfigured'
                    ContentCachingPort                       = 25
                    ContentCachingPublicRanges               = @{
                        LowerAddress = 'FakeStringValue'
                        ODataType    = '#microsoft.graph.iPv4Range'
                        UpperAddress = 'FakeStringValue'
                    }
                    ContentCachingShowAlerts                 = $true
                    ContentCachingType                       = 'notConfigured'
                    Description                              = 'FakeStringValue'
                    DisplayName                              = 'FakeStringValue'
                    Id                                       = 'FakeStringValue'
                    LoginWindowText                          = 'FakeStringValue'
                    LogOutDisabledWhileLoggedIn              = $true
                    MacOSSingleSignOnExtension               = @{
                        ActiveDirectorySiteCode                  = 'FakeStringValue'
                        BlockActiveDirectorySiteAutoDiscovery    = $true
                        BlockAutomaticLogin                      = $true
                        BundleIdAccessControlList                = @('FakeStringArrayValue1', 'FakeStringArrayValue2')
                        CacheName                                = 'FakeStringValue'
                        Configurations                           = @{
                            Key       = 'FakeStringValue'
                            ODataType = '#microsoft.graph.keyBooleanValuePair'
                            Value     = $true
                        }
                        CredentialBundleIdAccessControlList      = @('FakeStringArrayValue1', 'FakeStringArrayValue2')
                        CredentialsCacheMonitored                = $true
                        DomainRealms                             = @('FakeStringArrayValue1', 'FakeStringArrayValue2')
                        Domains                                  = @('FakeStringArrayValue1', 'FakeStringArrayValue2')
                        EnableSharedDeviceMode                   = $true
                        ExtensionIdentifier                      = 'FakeStringValue'
                        IsDefaultRealm                           = $true
                        KerberosAppsInBundleIdACLIncluded        = $true
                        ManagedAppsInBundleIdACLIncluded         = $true
                        ModeCredentialUsed                       = 'FakeStringValue'
                        ODataType                                = '#microsoft.graph.macOSAzureAdSingleSignOnExtension'
                        PasswordBlockModification                = $true
                        PasswordChangeUrl                        = 'FakeStringValue'
                        PasswordEnableLocalSync                  = $true
                        PasswordExpirationDays                   = 25
                        PasswordExpirationNotificationDays       = 25
                        PasswordMinimumAgeDays                   = 25
                        PasswordMinimumLength                    = 25
                        PasswordPreviousPasswordBlockCount       = 25
                        PasswordRequireActiveDirectoryComplexity = $true
                        PasswordRequirementsDescription          = 'FakeStringValue'
                        PreferredKDCs                            = @('FakeStringArrayValue1', 'FakeStringArrayValue2')
                        Realm                                    = 'FakeStringValue'
                        RequireUserPresence                      = $true
                        SignInHelpText                           = 'FakeStringValue'
                        TeamIdentifier                           = 'FakeStringValue'
                        TlsForLDAPRequired                       = $true
                        UrlPrefixes                              = @('FakeStringArrayValue1', 'FakeStringArrayValue2')
                        UsernameLabelCustom                      = 'FakeStringValue'
                        UserPrincipalName                        = 'FakeStringValue'
                        UserSetupDelayed                         = $true
                    }
                    PowerOffDisabledWhileLoggedIn            = $true
                    RestartDisabled                          = $true
                    RestartDisabledWhileLoggedIn             = $true
                    RoleScopeTagIds                          = @('FakeStringArrayValue1', 'FakeStringArrayValue2')
                    ScreenLockDisableImmediate               = $true
                    ShutDownDisabled                         = $true
                    ShutDownDisabledWhileLoggedIn            = $true
                    SingleSignOnExtension                    = @{
                        ActiveDirectorySiteCode                  = 'FakeStringValue'
                        BlockActiveDirectorySiteAutoDiscovery    = $true
                        BlockAutomaticLogin                      = $true
                        CacheName                                = 'FakeStringValue'
                        Configurations                           = @{
                            Key       = 'FakeStringValue'
                            ODataType = '#microsoft.graph.keyBooleanValuePair'
                            Value     = $true
                        }
                        CredentialBundleIdAccessControlList      = @('FakeStringArrayValue1', 'FakeStringArrayValue2')
                        DomainRealms                             = @('FakeStringArrayValue1', 'FakeStringArrayValue2')
                        Domains                                  = @('FakeStringArrayValue1', 'FakeStringArrayValue2')
                        ExtensionIdentifier                      = 'FakeStringValue'
                        IsDefaultRealm                           = $true
                        ODataType                                = '#microsoft.graph.credentialSingleSignOnExtension'
                        PasswordBlockModification                = $true
                        PasswordChangeUrl                        = 'FakeStringValue'
                        PasswordEnableLocalSync                  = $true
                        PasswordExpirationDays                   = 25
                        PasswordExpirationNotificationDays       = 25
                        PasswordMinimumAgeDays                   = 25
                        PasswordMinimumLength                    = 25
                        PasswordPreviousPasswordBlockCount       = 25
                        PasswordRequireActiveDirectoryComplexity = $true
                        PasswordRequirementsDescription          = 'FakeStringValue'
                        Realm                                    = 'FakeStringValue'
                        RequireUserPresence                      = $true
                        TeamIdentifier                           = 'FakeStringValue'
                        UrlPrefixes                              = @('FakeStringArrayValue1', 'FakeStringArrayValue2')
                        UserPrincipalName                        = 'FakeStringValue'
                    }
                    SleepDisabled                            = $true
                    Ensure                                   = 'Present'
                    Credential                               = $Credential
                }
            }

            It 'Should return Present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneDeviceFeaturesConfigurationPolicyMacOS' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
                Should -Invoke -CommandName 'Get-MgBetaDeviceManagementDeviceConfiguration'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceFeaturesConfigurationPolicyMacOS' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should update the instance from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceFeaturesConfigurationPolicyMacOS' -Property $testParams).Set()
                Should -Invoke -CommandName 'Update-MgBetaDeviceManagementDeviceConfiguration' -Exactly 1
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
                $result = Invoke-M365DSCResourceMethod -ResourceName 'IntuneDeviceFeaturesConfigurationPolicyMacOS' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
                Should -Invoke -CommandName 'Get-MgBetaDeviceManagementDeviceConfiguration'
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
