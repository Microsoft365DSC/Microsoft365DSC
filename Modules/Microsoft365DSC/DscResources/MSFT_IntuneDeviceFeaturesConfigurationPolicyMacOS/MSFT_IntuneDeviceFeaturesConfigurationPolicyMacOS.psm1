using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class IntuneDeviceFeaturesConfigurationPolicyMacOS : M365DSCResourceBase
{
    [DscProperty()]
    [System.ComponentModel.Description('Whether to show admin host information on the login window.')]
    [System.Nullable[System.Boolean]] $AdminShowHostInfo

    [DscProperty()]
    [System.ComponentModel.Description('An array of AirPrint printers that should always be shown. This collection can contain a maximum of 500 elements.')]
    [MSFT_MicrosoftGraphAirPrintDestination[]] $AirPrintDestinations

    [DscProperty()]
    [System.ComponentModel.Description('Gets or sets a list that maps apps to their associated domains. Application identifiers must be unique. This collection can contain a maximum of 500 elements.')]
    [MSFT_MicrosoftGraphMacOSAssociatedDomainsItem[]] $AppAssociatedDomains

    [DscProperty()]
    [System.ComponentModel.Description('Represents the assignment to the Intune policy.')]
    [MSFT_DeviceManagementConfigurationPolicyAssignments[]] $Assignments

    [DscProperty()]
    [System.ComponentModel.Description('DEPRECATED: use appAssociatedDomains instead. Gets or sets a list that maps apps to their associated domains. The key should match the app''s ID, and the value should be a string in the form of ''service:domain'' where domain is a fully qualified hostname (e.g. webcredentials:example.com). This collection can contain a maximum of 500 elements.')]
    [MSFT_MicrosoftGraphKeyValuePair2[]] $AssociatedDomains

    [DscProperty()]
    [System.ComponentModel.Description('Whether to show the name and password dialog or a list of users on the login window.')]
    [System.Nullable[System.Boolean]] $AuthorizedUsersListHidden

    [DscProperty()]
    [System.ComponentModel.Description('Whether to hide admin users in the authorized users list on the login window.')]
    [System.Nullable[System.Boolean]] $AuthorizedUsersListHideAdminUsers

    [DscProperty()]
    [System.ComponentModel.Description('Whether to show only network and system users in the authorized users list on the login window.')]
    [System.Nullable[System.Boolean]] $AuthorizedUsersListHideLocalUsers

    [DscProperty()]
    [System.ComponentModel.Description('Whether to hide mobile users in the authorized users list on the login window.')]
    [System.Nullable[System.Boolean]] $AuthorizedUsersListHideMobileAccounts

    [DscProperty()]
    [System.ComponentModel.Description('Whether to show network users in the authorized users list on the login window.')]
    [System.Nullable[System.Boolean]] $AuthorizedUsersListIncludeNetworkUsers

    [DscProperty()]
    [System.ComponentModel.Description('Whether to show other users in the authorized users list on the login window.')]
    [System.Nullable[System.Boolean]] $AuthorizedUsersListShowOtherManagedUsers

    [DscProperty()]
    [System.ComponentModel.Description('List of applications, files, folders, and other items to launch when the user logs in. This collection can contain a maximum of 500 elements.')]
    [MSFT_MicrosoftGraphMacOSLaunchItem[]] $AutoLaunchItems

    [DscProperty()]
    [System.ComponentModel.Description('Whether the Other user will disregard use of the console special user name.')]
    [System.Nullable[System.Boolean]] $ConsoleAccessDisabled

    [DscProperty()]
    [System.ComponentModel.Description('Prevents content caches from purging content to free up disk space for other apps.')]
    [System.Nullable[System.Boolean]] $ContentCachingBlockDeletion

    [DscProperty()]
    [System.ComponentModel.Description('A list of custom IP ranges content caches will use to listen for clients. This collection can contain a maximum of 500 elements.')]
    [MSFT_MicrosoftGraphIpRange2[]] $ContentCachingClientListenRanges

    [DscProperty()]
    [System.ComponentModel.Description('Determines the method in which content caching servers will listen for clients. Possible values are: notConfigured, clientsInLocalNetwork, clientsWithSamePublicIpAddress, clientsInCustomLocalNetworks, clientsInCustomLocalNetworksWithFallback.')]
    [ValidateSet('notConfigured', 'clientsInLocalNetwork', 'clientsWithSamePublicIpAddress', 'clientsInCustomLocalNetworks', 'clientsInCustomLocalNetworksWithFallback')]
    [System.String] $ContentCachingClientPolicy

    [DscProperty()]
    [System.ComponentModel.Description('The path to the directory used to store cached content. The value must be (or end with) /Library/Application Support/Apple/AssetCache/Data')]
    [System.String] $ContentCachingDataPath

    [DscProperty()]
    [System.ComponentModel.Description('Disables internet connection sharing.')]
    [System.Nullable[System.Boolean]] $ContentCachingDisableConnectionSharing

    [DscProperty()]
    [System.ComponentModel.Description('Enables content caching and prevents it from being disabled by the user.')]
    [System.Nullable[System.Boolean]] $ContentCachingEnabled

    [DscProperty()]
    [System.ComponentModel.Description('Forces internet connection sharing. contentCachingDisableConnectionSharing overrides this setting.')]
    [System.Nullable[System.Boolean]] $ContentCachingForceConnectionSharing

    [DscProperty()]
    [System.ComponentModel.Description('Prevent the device from sleeping if content caching is enabled.')]
    [System.Nullable[System.Boolean]] $ContentCachingKeepAwake

    [DscProperty()]
    [System.ComponentModel.Description('Enables logging of IP addresses and ports of clients that request cached content.')]
    [System.Nullable[System.Boolean]] $ContentCachingLogClientIdentities

    [DscProperty()]
    [System.ComponentModel.Description('The maximum number of bytes of disk space that will be used for the content cache. A value of 0 (default) indicates unlimited disk space.')]
    [System.Nullable[System.Int64]] $ContentCachingMaxSizeBytes

    [DscProperty()]
    [System.ComponentModel.Description('A list of IP addresses representing parent content caches.')]
    [System.String[]] $ContentCachingParents

    [DscProperty()]
    [System.ComponentModel.Description('Determines the method in which content caching servers will select parents if multiple are present. Possible values are: notConfigured, roundRobin, firstAvailable, urlPathHash, random, stickyAvailable.')]
    [ValidateSet('notConfigured', 'roundRobin', 'firstAvailable', 'urlPathHash', 'random', 'stickyAvailable')]
    [System.String] $ContentCachingParentSelectionPolicy

    [DscProperty()]
    [System.ComponentModel.Description('A list of custom IP ranges content caches will use to query for content from peers caches. This collection can contain a maximum of 500 elements.')]
    [MSFT_MicrosoftGraphIpRange2[]] $ContentCachingPeerFilterRanges

    [DscProperty()]
    [System.ComponentModel.Description('A list of custom IP ranges content caches will use to listen for peer caches. This collection can contain a maximum of 500 elements.')]
    [MSFT_MicrosoftGraphIpRange2[]] $ContentCachingPeerListenRanges

    [DscProperty()]
    [System.ComponentModel.Description('Determines the method in which content caches peer with other caches. Possible values are: notConfigured, peersInLocalNetwork, peersWithSamePublicIpAddress, peersInCustomLocalNetworks.')]
    [ValidateSet('notConfigured', 'peersInLocalNetwork', 'peersWithSamePublicIpAddress', 'peersInCustomLocalNetworks')]
    [System.String] $ContentCachingPeerPolicy

    [DscProperty()]
    [System.ComponentModel.Description('Sets the port used for content caching. If the value is 0, a random available port will be selected. Valid values 0 to 65535')]
    [System.Nullable[System.Int32]] $ContentCachingPort

    [DscProperty()]
    [System.ComponentModel.Description('A list of custom IP ranges that Apple''s content caching service should use to match clients to content caches. This collection can contain a maximum of 500 elements.')]
    [MSFT_MicrosoftGraphIpRange2[]] $ContentCachingPublicRanges

    [DscProperty()]
    [System.ComponentModel.Description('Display content caching alerts as system notifications.')]
    [System.Nullable[System.Boolean]] $ContentCachingShowAlerts

    [DscProperty()]
    [System.ComponentModel.Description('Determines what type of content is allowed to be cached by Apple''s content caching service. Possible values are: notConfigured, userContentOnly, sharedContentOnly.')]
    [ValidateSet('notConfigured', 'userContentOnly', 'sharedContentOnly')]
    [System.String] $ContentCachingType

    [DscProperty()]
    [System.ComponentModel.Description('Admin provided description of the Device Configuration.')]
    [System.String] $Description

    [DscProperty(Key)]
    [System.ComponentModel.Description('Admin provided name of the device configuration.')]
    [System.String] $DisplayName

    [DscProperty()]
    [System.ComponentModel.Description('The unique identifier for an entity. Read-only.')]
    [System.String] $Id

    [DscProperty()]
    [System.ComponentModel.Description('Custom text to be displayed on the login window.')]
    [System.String] $LoginWindowText

    [DscProperty()]
    [System.ComponentModel.Description('Whether the Log Out menu item on the login window will be disabled while the user is logged in.')]
    [System.Nullable[System.Boolean]] $LogOutDisabledWhileLoggedIn

    [DscProperty()]
    [System.ComponentModel.Description('Gets or sets a single sign-on extension profile.')]
    [MSFT_MicrosoftGraphMacOSSingleSignOnExtension] $MacOSSingleSignOnExtension

    [DscProperty()]
    [System.ComponentModel.Description('Whether the Power Off menu item on the login window will be disabled while the user is logged in.')]
    [System.Nullable[System.Boolean]] $PowerOffDisabledWhileLoggedIn

    [DscProperty()]
    [System.ComponentModel.Description('Whether to hide the Restart button item on the login window.')]
    [System.Nullable[System.Boolean]] $RestartDisabled

    [DscProperty()]
    [System.ComponentModel.Description('Whether the Restart menu item on the login window will be disabled while the user is logged in.')]
    [System.Nullable[System.Boolean]] $RestartDisabledWhileLoggedIn

    [DscProperty()]
    [System.ComponentModel.Description('List of Scope Tags for this Entity instance.')]
    [System.String[]] $RoleScopeTagIds

    [DscProperty()]
    [System.ComponentModel.Description('Whether to disable the immediate screen lock functions.')]
    [System.Nullable[System.Boolean]] $ScreenLockDisableImmediate

    [DscProperty()]
    [System.ComponentModel.Description('Whether to hide the Shut Down button item on the login window.')]
    [System.Nullable[System.Boolean]] $ShutDownDisabled

    [DscProperty()]
    [System.ComponentModel.Description('Whether the Shut Down menu item on the login window will be disabled while the user is logged in.')]
    [System.Nullable[System.Boolean]] $ShutDownDisabledWhileLoggedIn

    [DscProperty()]
    [System.ComponentModel.Description('Gets or sets a single sign-on extension profile. Deprecated: use MacOSSingleSignOnExtension instead.')]
    [MSFT_MicrosoftGraphSingleSignOnExtension] $SingleSignOnExtension

    [DscProperty()]
    [System.ComponentModel.Description('Whether to hide the Sleep menu item on the login window.')]
    [System.Nullable[System.Boolean]] $SleepDisabled

    [DscProperty()]
    [System.ComponentModel.Description('Specify if the policy should exist.')]
    [ValidateSet('Present', 'Absent')]
    [System.String] $Ensure

    [DscProperty()]
    [System.ComponentModel.Description('Credentials of the Intune Admin')]
    [System.Management.Automation.PSCredential] $Credential

    [DscProperty()]
    [System.ComponentModel.Description('Id of the Entra ID application to authenticate with.')]
    [System.String] $ApplicationId

    [DscProperty()]
    [System.ComponentModel.Description('Id of the Entra ID tenant used for authentication.')]
    [System.String] $TenantId

    [DscProperty()]
    [System.ComponentModel.Description('Secret of the Entra ID application to authenticate with.')]
    [System.Management.Automation.PSCredential] $ApplicationSecret

    [DscProperty()]
    [System.ComponentModel.Description('Thumbprint of the Entra ID application''s authentication certificate to use for authentication.')]
    [System.String] $CertificateThumbprint

    [DscProperty()]
    [System.ComponentModel.Description('Username can be made up to anything but password will be used for CertificatePassword')]
    [System.Management.Automation.PSCredential] $CertificatePassword

    [DscProperty()]
    [System.ComponentModel.Description('Path to certificate used in service principal usually a PFX file.')]
    [System.String] $CertificatePath

    [DscProperty()]
    [System.ComponentModel.Description('Managed ID being used for authentication.')]
    [System.Nullable[System.Boolean]] $ManagedIdentity

    [DscProperty()]
    [System.ComponentModel.Description('Access token used for authentication.')]
    [System.String[]] $AccessTokens

    # Export-only. Not part of the resource schema.
    [System.String] $Filter

    [IntuneDeviceFeaturesConfigurationPolicyMacOS] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [IntuneDeviceFeaturesConfigurationPolicyMacOS]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of Intune Device Features Configuration Policy for macOS {$($this.Id)}"

        try
        {
            $null = $this.Connect('MicrosoftGraph')

            #Ensure the proper dependencies are installed in the current environment.
            Confirm-M365DSCDependencies

            #region Telemetry
            $this.AddTelemetry('Get')
            #endregion

            $nullResult = $this.GetBoundParameters()
            $nullResult.Ensure = 'Absent'

            if (-not $this.ExportedInstance -or $this.ExportedInstance.Id -ne $this.Id)
            {
                $getValue = $null
                if (-not [System.String]::IsNullOrEmpty($this.Id))
                {
                    $getValue = Get-MgBetaDeviceManagementDeviceConfiguration -DeviceConfigurationId $this.Id `
                        -ErrorAction SilentlyContinue
                }

                if ($null -eq $getValue -and -not [System.String]::IsNullOrEmpty($this.DisplayName))
                {
                    $getValue = Get-MgBetaDeviceManagementDeviceConfiguration -All `
                        -Filter "DisplayName eq '$($this.DisplayName -replace "'", "''")' and isof('microsoft.graph.macOSDeviceFeaturesConfiguration')" `
                        -ErrorAction SilentlyContinue | Select-Object -First 1
                }
            }
            else
            {
                $getValue = $this.ExportedInstance
            }

            if ($null -eq $getValue)
            {
                Write-Verbose -Message "No Intune Device Features Configuration Policy for macOS with Id {$($this.Id)} was found"
                return $this.AsResult($nullResult)
            }

            Write-Verbose -Message "Found Intune Device Features Configuration Policy for macOS with Id {$($this.Id)}"

            $complexAirPrintDestinations = @()
            foreach ($currentAirPrintDestinations in $getValue.airPrintDestinations)
            {
                $myAirPrintDestinations = [ordered]@{}
                $myAirPrintDestinations.Add('ForceTls', $currentAirPrintDestinations.forceTls)
                $myAirPrintDestinations.Add('IpAddress', $currentAirPrintDestinations.ipAddress)
                $myAirPrintDestinations.Add('Port', $currentAirPrintDestinations.port)
                $myAirPrintDestinations.Add('ResourcePath', $currentAirPrintDestinations.resourcePath)
                if ($myAirPrintDestinations.values.Where({ $null -ne $_ }).Count -gt 0)
                {
                    $complexAirPrintDestinations += $myAirPrintDestinations
                }
            }

            $complexAppAssociatedDomains = @()
            foreach ($currentAppAssociatedDomains in $getValue.appAssociatedDomains)
            {
                $myAppAssociatedDomains = [ordered]@{}
                $myAppAssociatedDomains.Add('ApplicationIdentifier', $currentAppAssociatedDomains.applicationIdentifier)
                $myAppAssociatedDomains.Add('DirectDownloadsEnabled', $currentAppAssociatedDomains.directDownloadsEnabled)
                $myAppAssociatedDomains.Add('Domains', [Array]$currentAppAssociatedDomains.domains)
                if ($myAppAssociatedDomains.values.Where({ $null -ne $_ }).Count -gt 0)
                {
                    $complexAppAssociatedDomains += $myAppAssociatedDomains
                }
            }

            $complexAssociatedDomains = @()
            foreach ($currentAssociatedDomains in $getValue.associatedDomains)
            {
                $myAssociatedDomains = [ordered]@{}
                $myAssociatedDomains.Add('Name', $currentAssociatedDomains.name)
                $myAssociatedDomains.Add('Value', $currentAssociatedDomains.value)
                if ($myAssociatedDomains.values.Where({ $null -ne $_ }).Count -gt 0)
                {
                    $complexAssociatedDomains += $myAssociatedDomains
                }
            }

            $complexAutoLaunchItems = @()
            foreach ($currentAutoLaunchItems in $getValue.autoLaunchItems)
            {
                $myAutoLaunchItems = [ordered]@{}
                $myAutoLaunchItems.Add('Hide', $currentAutoLaunchItems.hide)
                $myAutoLaunchItems.Add('Path', $currentAutoLaunchItems.path)
                if ($myAutoLaunchItems.values.Where({ $null -ne $_ }).Count -gt 0)
                {
                    $complexAutoLaunchItems += $myAutoLaunchItems
                }
            }

            $complexContentCachingClientListenRanges = @()
            foreach ($currentContentCachingClientListenRanges in $getValue.contentCachingClientListenRanges)
            {
                $myContentCachingClientListenRanges = [ordered]@{}
                $myContentCachingClientListenRanges.Add('LowerAddress', $currentContentCachingClientListenRanges.lowerAddress)
                if ($null -ne $currentContentCachingClientListenRanges.'@odata.type')
                {
                    $myContentCachingClientListenRanges.Add('ODataType', $currentContentCachingClientListenRanges.'@odata.type')
                }
                $myContentCachingClientListenRanges.Add('UpperAddress', $currentContentCachingClientListenRanges.upperAddress)
                if ($myContentCachingClientListenRanges.values.Where({ $null -ne $_ }).Count -gt 0)
                {
                    $complexContentCachingClientListenRanges += $myContentCachingClientListenRanges
                }
            }

            $complexContentCachingPeerFilterRanges = @()
            foreach ($currentContentCachingPeerFilterRanges in $getValue.contentCachingPeerFilterRanges)
            {
                $myContentCachingPeerFilterRanges = [ordered]@{}
                $myContentCachingPeerFilterRanges.Add('LowerAddress', $currentContentCachingPeerFilterRanges.lowerAddress)
                if ($null -ne $currentContentCachingPeerFilterRanges.'@odata.type')
                {
                    $myContentCachingPeerFilterRanges.Add('ODataType', $currentContentCachingPeerFilterRanges.'@odata.type')
                }
                $myContentCachingPeerFilterRanges.Add('UpperAddress', $currentContentCachingPeerFilterRanges.upperAddress)
                if ($myContentCachingPeerFilterRanges.values.Where({ $null -ne $_ }).Count -gt 0)
                {
                    $complexContentCachingPeerFilterRanges += $myContentCachingPeerFilterRanges
                }
            }

            $complexContentCachingPeerListenRanges = @()
            foreach ($currentContentCachingPeerListenRanges in $getValue.contentCachingPeerListenRanges)
            {
                $myContentCachingPeerListenRanges = [ordered]@{}
                $myContentCachingPeerListenRanges.Add('LowerAddress', $currentContentCachingPeerListenRanges.lowerAddress)
                if ($null -ne $currentContentCachingPeerListenRanges.'@odata.type')
                {
                    $myContentCachingPeerListenRanges.Add('ODataType', $currentContentCachingPeerListenRanges.'@odata.type')
                }
                $myContentCachingPeerListenRanges.Add('UpperAddress', $currentContentCachingPeerListenRanges.upperAddress)
                if ($myContentCachingPeerListenRanges.values.Where({ $null -ne $_ }).Count -gt 0)
                {
                    $complexContentCachingPeerListenRanges += $myContentCachingPeerListenRanges
                }
            }

            $complexContentCachingPublicRanges = @()
            foreach ($currentContentCachingPublicRanges in $getValue.contentCachingPublicRanges)
            {
                $myContentCachingPublicRanges = [ordered]@{}
                $myContentCachingPublicRanges.Add('LowerAddress', $currentContentCachingPublicRanges.lowerAddress)
                if ($null -ne $currentContentCachingPublicRanges.'@odata.type')
                {
                    $myContentCachingPublicRanges.Add('ODataType', $currentContentCachingPublicRanges.'@odata.type')
                }
                $myContentCachingPublicRanges.Add('UpperAddress', $currentContentCachingPublicRanges.upperAddress)
                if ($myContentCachingPublicRanges.values.Where({ $null -ne $_ }).Count -gt 0)
                {
                    $complexContentCachingPublicRanges += $myContentCachingPublicRanges
                }
            }

            $complexMacOSSingleSignOnExtension = [ordered]@{}
            $complexMacOSSingleSignOnExtension.Add('ActiveDirectorySiteCode', $getValue.macOSSingleSignOnExtension.activeDirectorySiteCode)
            $complexMacOSSingleSignOnExtension.Add('BlockActiveDirectorySiteAutoDiscovery', $getValue.macOSSingleSignOnExtension.blockActiveDirectorySiteAutoDiscovery)
            $complexMacOSSingleSignOnExtension.Add('BlockAutomaticLogin', $getValue.macOSSingleSignOnExtension.blockAutomaticLogin)
            $complexMacOSSingleSignOnExtension.Add('BundleIdAccessControlList', [Array]$getValue.macOSSingleSignOnExtension.bundleIdAccessControlList)
            $complexMacOSSingleSignOnExtension.Add('CacheName', $getValue.macOSSingleSignOnExtension.cacheName)
            $complexConfigurations = @()
            foreach ($currentConfigurations in $getValue.macOSSingleSignOnExtension.configurations)
            {
                $myConfigurations = [ordered]@{}
                $myConfigurations.Add('Key', $currentConfigurations.key)
                if ($null -ne $currentConfigurations.'@odata.type')
                {
                    $myConfigurations.Add('ODataType', $currentConfigurations.'@odata.type')
                }
                $myConfigurations.Add('Value', $currentConfigurations.value)
                if ($myConfigurations.values.Where({ $null -ne $_ }).Count -gt 0)
                {
                    $complexConfigurations += $myConfigurations
                }
            }
            $complexMacOSSingleSignOnExtension.Add('Configurations', $complexConfigurations)
            $complexMacOSSingleSignOnExtension.Add('CredentialBundleIdAccessControlList', [Array]$getValue.macOSSingleSignOnExtension.credentialBundleIdAccessControlList)
            $complexMacOSSingleSignOnExtension.Add('CredentialsCacheMonitored', $getValue.macOSSingleSignOnExtension.credentialsCacheMonitored)
            $complexMacOSSingleSignOnExtension.Add('DomainRealms', [Array]$getValue.macOSSingleSignOnExtension.domainRealms)
            $complexMacOSSingleSignOnExtension.Add('Domains', [Array]$getValue.macOSSingleSignOnExtension.domains)
            $complexMacOSSingleSignOnExtension.Add('EnableSharedDeviceMode', $getValue.macOSSingleSignOnExtension.enableSharedDeviceMode)
            $complexMacOSSingleSignOnExtension.Add('ExtensionIdentifier', $getValue.macOSSingleSignOnExtension.extensionIdentifier)
            $complexMacOSSingleSignOnExtension.Add('IsDefaultRealm', $getValue.macOSSingleSignOnExtension.isDefaultRealm)
            $complexMacOSSingleSignOnExtension.Add('KerberosAppsInBundleIdACLIncluded', $getValue.macOSSingleSignOnExtension.kerberosAppsInBundleIdACLIncluded)
            $complexMacOSSingleSignOnExtension.Add('ManagedAppsInBundleIdACLIncluded', $getValue.macOSSingleSignOnExtension.managedAppsInBundleIdACLIncluded)
            $complexMacOSSingleSignOnExtension.Add('ModeCredentialUsed', $getValue.macOSSingleSignOnExtension.modeCredentialUsed)
            if ($null -ne $getValue.macOSSingleSignOnExtension.'@odata.type')
            {
                $complexMacOSSingleSignOnExtension.Add('ODataType', $getValue.macOSSingleSignOnExtension.'@odata.type')
            }
            $complexMacOSSingleSignOnExtension.Add('PasswordBlockModification', $getValue.macOSSingleSignOnExtension.passwordBlockModification)
            $complexMacOSSingleSignOnExtension.Add('PasswordChangeUrl', $getValue.macOSSingleSignOnExtension.passwordChangeUrl)
            $complexMacOSSingleSignOnExtension.Add('PasswordEnableLocalSync', $getValue.macOSSingleSignOnExtension.passwordEnableLocalSync)
            $complexMacOSSingleSignOnExtension.Add('PasswordExpirationDays', $getValue.macOSSingleSignOnExtension.passwordExpirationDays)
            $complexMacOSSingleSignOnExtension.Add('PasswordExpirationNotificationDays', $getValue.macOSSingleSignOnExtension.passwordExpirationNotificationDays)
            $complexMacOSSingleSignOnExtension.Add('PasswordMinimumAgeDays', $getValue.macOSSingleSignOnExtension.passwordMinimumAgeDays)
            $complexMacOSSingleSignOnExtension.Add('PasswordMinimumLength', $getValue.macOSSingleSignOnExtension.passwordMinimumLength)
            $complexMacOSSingleSignOnExtension.Add('PasswordPreviousPasswordBlockCount', $getValue.macOSSingleSignOnExtension.passwordPreviousPasswordBlockCount)
            $complexMacOSSingleSignOnExtension.Add('PasswordRequireActiveDirectoryComplexity', $getValue.macOSSingleSignOnExtension.passwordRequireActiveDirectoryComplexity)
            $complexMacOSSingleSignOnExtension.Add('PasswordRequirementsDescription', $getValue.macOSSingleSignOnExtension.passwordRequirementsDescription)
            $complexMacOSSingleSignOnExtension.Add('PreferredKDCs', [Array]($getValue.macOSSingleSignOnExtension.preferredKDCs | Select-Object -Unique))
            $complexMacOSSingleSignOnExtension.Add('Realm', $getValue.macOSSingleSignOnExtension.realm)
            $complexMacOSSingleSignOnExtension.Add('RequireUserPresence', $getValue.macOSSingleSignOnExtension.requireUserPresence)
            $complexMacOSSingleSignOnExtension.Add('SignInHelpText', $getValue.macOSSingleSignOnExtension.signInHelpText)
            $complexMacOSSingleSignOnExtension.Add('TeamIdentifier', $getValue.macOSSingleSignOnExtension.teamIdentifier)
            $complexMacOSSingleSignOnExtension.Add('TlsForLDAPRequired', $getValue.macOSSingleSignOnExtension.tlsForLDAPRequired)
            $complexMacOSSingleSignOnExtension.Add('UrlPrefixes', [Array]$getValue.macOSSingleSignOnExtension.urlPrefixes)
            $complexMacOSSingleSignOnExtension.Add('UsernameLabelCustom', $getValue.macOSSingleSignOnExtension.usernameLabelCustom)
            $complexMacOSSingleSignOnExtension.Add('UserPrincipalName', $getValue.macOSSingleSignOnExtension.userPrincipalName)
            $complexMacOSSingleSignOnExtension.Add('UserSetupDelayed', $getValue.macOSSingleSignOnExtension.userSetupDelayed)
            if ($complexMacOSSingleSignOnExtension.values.Where({ $null -ne $_ }).Count -eq 0)
            {
                $complexMacOSSingleSignOnExtension = $null
            }

            $complexSingleSignOnExtension = [ordered]@{}
            $complexSingleSignOnExtension.Add('ActiveDirectorySiteCode', $getValue.singleSignOnExtension.activeDirectorySiteCode)
            $complexSingleSignOnExtension.Add('BlockActiveDirectorySiteAutoDiscovery', $getValue.singleSignOnExtension.blockActiveDirectorySiteAutoDiscovery)
            $complexSingleSignOnExtension.Add('BlockAutomaticLogin', $getValue.singleSignOnExtension.blockAutomaticLogin)
            $complexSingleSignOnExtension.Add('CacheName', $getValue.singleSignOnExtension.cacheName)
            $complexConfigurations = @()
            foreach ($currentConfigurations in $getValue.singleSignOnExtension.configurations)
            {
                $myConfigurations = [ordered]@{}
                $myConfigurations.Add('Key', $currentConfigurations.key)
                if ($null -ne $currentConfigurations.'@odata.type')
                {
                    $myConfigurations.Add('ODataType', $currentConfigurations.'@odata.type')
                }
                $myConfigurations.Add('Value', $currentConfigurations.value)
                if ($myConfigurations.values.Where({ $null -ne $_ }).Count -gt 0)
                {
                    $complexConfigurations += $myConfigurations
                }
            }
            $complexSingleSignOnExtension.Add('Configurations', $complexConfigurations)
            $complexSingleSignOnExtension.Add('CredentialBundleIdAccessControlList', [Array]$getValue.singleSignOnExtension.credentialBundleIdAccessControlList)
            $complexSingleSignOnExtension.Add('DomainRealms', [Array]$getValue.singleSignOnExtension.domainRealms)
            $complexSingleSignOnExtension.Add('Domains', [Array]$getValue.singleSignOnExtension.domains)
            $complexSingleSignOnExtension.Add('ExtensionIdentifier', $getValue.singleSignOnExtension.extensionIdentifier)
            $complexSingleSignOnExtension.Add('IsDefaultRealm', $getValue.singleSignOnExtension.isDefaultRealm)
            if ($null -ne $getValue.singleSignOnExtension.'@odata.type')
            {
                $complexSingleSignOnExtension.Add('ODataType', $getValue.singleSignOnExtension.'@odata.type')
            }
            $complexSingleSignOnExtension.Add('PasswordBlockModification', $getValue.singleSignOnExtension.passwordBlockModification)
            $complexSingleSignOnExtension.Add('PasswordChangeUrl', $getValue.singleSignOnExtension.passwordChangeUrl)
            $complexSingleSignOnExtension.Add('PasswordEnableLocalSync', $getValue.singleSignOnExtension.passwordEnableLocalSync)
            $complexSingleSignOnExtension.Add('PasswordExpirationDays', $getValue.singleSignOnExtension.passwordExpirationDays)
            $complexSingleSignOnExtension.Add('PasswordExpirationNotificationDays', $getValue.singleSignOnExtension.passwordExpirationNotificationDays)
            $complexSingleSignOnExtension.Add('PasswordMinimumAgeDays', $getValue.singleSignOnExtension.passwordMinimumAgeDays)
            $complexSingleSignOnExtension.Add('PasswordMinimumLength', $getValue.singleSignOnExtension.passwordMinimumLength)
            $complexSingleSignOnExtension.Add('PasswordPreviousPasswordBlockCount', $getValue.singleSignOnExtension.passwordPreviousPasswordBlockCount)
            $complexSingleSignOnExtension.Add('PasswordRequireActiveDirectoryComplexity', $getValue.singleSignOnExtension.passwordRequireActiveDirectoryComplexity)
            $complexSingleSignOnExtension.Add('PasswordRequirementsDescription', $getValue.singleSignOnExtension.passwordRequirementsDescription)
            $complexSingleSignOnExtension.Add('Realm', $getValue.singleSignOnExtension.realm)
            $complexSingleSignOnExtension.Add('RequireUserPresence', $getValue.singleSignOnExtension.requireUserPresence)
            $complexSingleSignOnExtension.Add('TeamIdentifier', $getValue.singleSignOnExtension.teamIdentifier)
            $complexSingleSignOnExtension.Add('UrlPrefixes', [Array]$getValue.singleSignOnExtension.urlPrefixes)
            $complexSingleSignOnExtension.Add('UserPrincipalName', $getValue.singleSignOnExtension.userPrincipalName)
            if ($complexSingleSignOnExtension.values.Where({ $null -ne $_ }).Count -eq 0)
            {
                $complexSingleSignOnExtension = $null
            }

            $result = @{
                AdminShowHostInfo                        = $getValue.adminShowHostInfo
                AirPrintDestinations                     = [Array]$complexAirPrintDestinations
                AppAssociatedDomains                     = [Array]$complexAppAssociatedDomains
                AssociatedDomains                        = [Array]$complexAssociatedDomains
                AuthorizedUsersListHidden                = $getValue.authorizedUsersListHidden
                AuthorizedUsersListHideAdminUsers        = $getValue.authorizedUsersListHideAdminUsers
                AuthorizedUsersListHideLocalUsers        = $getValue.authorizedUsersListHideLocalUsers
                AuthorizedUsersListHideMobileAccounts    = $getValue.authorizedUsersListHideMobileAccounts
                AuthorizedUsersListIncludeNetworkUsers   = $getValue.authorizedUsersListIncludeNetworkUsers
                AuthorizedUsersListShowOtherManagedUsers = $getValue.authorizedUsersListShowOtherManagedUsers
                AutoLaunchItems                          = [Array]$complexAutoLaunchItems
                ConsoleAccessDisabled                    = $getValue.consoleAccessDisabled
                ContentCachingBlockDeletion              = $getValue.contentCachingBlockDeletion
                ContentCachingClientListenRanges         = [Array]$complexContentCachingClientListenRanges
                ContentCachingClientPolicy               = $getValue.contentCachingClientPolicy
                ContentCachingDataPath                   = $getValue.contentCachingDataPath
                ContentCachingDisableConnectionSharing   = $getValue.contentCachingDisableConnectionSharing
                ContentCachingEnabled                    = $getValue.contentCachingEnabled
                ContentCachingForceConnectionSharing     = $getValue.contentCachingForceConnectionSharing
                ContentCachingKeepAwake                  = $getValue.contentCachingKeepAwake
                ContentCachingLogClientIdentities        = $getValue.contentCachingLogClientIdentities
                ContentCachingMaxSizeBytes               = $getValue.contentCachingMaxSizeBytes
                ContentCachingParents                    = $getValue.contentCachingParents
                ContentCachingParentSelectionPolicy      = $getValue.contentCachingParentSelectionPolicy
                ContentCachingPeerFilterRanges           = [Array]$complexContentCachingPeerFilterRanges
                ContentCachingPeerListenRanges           = [Array]$complexContentCachingPeerListenRanges
                ContentCachingPeerPolicy                 = $getValue.contentCachingPeerPolicy
                ContentCachingPort                       = $getValue.contentCachingPort
                ContentCachingPublicRanges               = [Array]$complexContentCachingPublicRanges
                ContentCachingShowAlerts                 = $getValue.contentCachingShowAlerts
                ContentCachingType                       = $getValue.contentCachingType
                Description                              = $getValue.Description
                DisplayName                              = $getValue.DisplayName
                Id                                       = $getValue.Id
                LoginWindowText                          = $getValue.loginWindowText
                LogOutDisabledWhileLoggedIn              = $getValue.logOutDisabledWhileLoggedIn
                MacOSSingleSignOnExtension               = $complexMacOSSingleSignOnExtension
                PowerOffDisabledWhileLoggedIn            = $getValue.powerOffDisabledWhileLoggedIn
                RestartDisabled                          = $getValue.restartDisabled
                RestartDisabledWhileLoggedIn             = $getValue.restartDisabledWhileLoggedIn
                RoleScopeTagIds                          = Resolve-M365DSCIntuneRoleScopeTagNames -CurrentValues $getValue.RoleScopeTagIds -DesiredValues $this.RoleScopeTagIds
                ScreenLockDisableImmediate               = $getValue.screenLockDisableImmediate
                ShutDownDisabled                         = $getValue.shutDownDisabled
                ShutDownDisabledWhileLoggedIn            = $getValue.shutDownDisabledWhileLoggedIn
                SingleSignOnExtension                    = $complexSingleSignOnExtension
                SleepDisabled                            = $getValue.sleepDisabled
                Ensure                                   = 'Present'
                Credential                               = $this.Credential
                ApplicationId                            = $this.ApplicationId
                TenantId                                 = $this.TenantId
                ApplicationSecret                        = $this.ApplicationSecret
                CertificateThumbprint                    = $this.CertificateThumbprint
                CertificatePassword                      = $this.CertificatePassword
                CertificatePath                          = $this.CertificatePath
                ManagedIdentity                          = $this.ManagedIdentity
                AccessTokens                             = $this.AccessTokens
            }

            $assignmentsValues = Get-M365DSCIntuneExpandedAssignments -Instance $getValue
            if ($null -eq $assignmentsValues)
            {
                $assignmentsValues = Get-MgBetaDeviceManagementDeviceConfigurationAssignment -DeviceConfigurationId $getValue.Id -ErrorAction SilentlyContinue
            }
            $assignmentResult = @()
            if ($null -ne $assignmentsValues -and $assignmentsValues.Count -gt 0)
            {
                $assignmentResult += ConvertFrom-IntunePolicyAssignment `
                    -IncludeDeviceFilter:$true `
                    -Assignments $assignmentsValues
            }
            $result.Add('Assignments', $assignmentResult)

            return $this.AsResult($result)
        }
        catch
        {
            $this.LogError($_, 'Error retrieving data:')

            throw
        }
    }

    [void] Set()
    {
        if ($this.RequiresPowerShellCore())
        {
            $null = $this.InvokeInPowerShellCore('Set')
            return
        }

        Write-Verbose -Message "Setting configuration of Intune Device Features Configuration Policy for macOS {$($this.Id)}"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        try
        {
            $null = $this.Connect('MicrosoftGraph')

            $currentInstance = $this.Get().ToHashtable()

            $boundParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()

            if ($boundParameters.ContainsKey('RoleScopeTagIds'))
            {
                $boundParameters.RoleScopeTagIds = Resolve-M365DSCIntuneRoleScopeTagIds -RoleScopeTagIds $this.RoleScopeTagIds
            }

            $boundParameters = Rename-M365DSCCimInstanceParameter -Properties $boundParameters
            $boundParameters.Remove('Id') | Out-Null
            $boundParameters.Remove('Assignments') | Out-Null
            $boundParameters.Add('@odata.type', '#microsoft.graph.macOSDeviceFeaturesConfiguration')

            foreach ($extensionProperty in @('macOSSingleSignOnExtension', 'singleSignOnExtension'))
            {
                $extension = $boundParameters.$extensionProperty
                if ($null -ne $extension -and [System.String]::IsNullOrEmpty($extension['@odata.type']))
                {
                    $boundParameters.Remove($extensionProperty) | Out-Null
                }
            }

            $kerberosProperties = @('activeDirectorySiteCode', 'blockActiveDirectorySiteAutoDiscovery', 'blockAutomaticLogin', 'cacheName',
                'credentialBundleIdAccessControlList', 'domainRealms', 'domains', 'isDefaultRealm', 'passwordBlockModification',
                'passwordChangeUrl', 'passwordEnableLocalSync', 'passwordExpirationDays', 'passwordExpirationNotificationDays',
                'passwordMinimumAgeDays', 'passwordMinimumLength', 'passwordPreviousPasswordBlockCount',
                'passwordRequireActiveDirectoryComplexity', 'passwordRequirementsDescription', 'realm', 'requireUserPresence',
                'userPrincipalName')
            $this.RemoveForeignSubtypeProperties($boundParameters, @{
                    '#microsoft.graph.macOSAzureAdSingleSignOnExtension'    = @('bundleIdAccessControlList', 'configurations', 'enableSharedDeviceMode')
                    '#microsoft.graph.macOSCredentialSingleSignOnExtension' = @('configurations', 'domains', 'extensionIdentifier', 'realm', 'teamIdentifier')
                    '#microsoft.graph.macOSRedirectSingleSignOnExtension'   = @('configurations', 'extensionIdentifier', 'teamIdentifier', 'urlPrefixes')
                    '#microsoft.graph.macOSKerberosSingleSignOnExtension'   = $kerberosProperties + @('credentialsCacheMonitored',
                        'kerberosAppsInBundleIdACLIncluded', 'managedAppsInBundleIdACLIncluded', 'modeCredentialUsed', 'preferredKDCs',
                        'signInHelpText', 'tlsForLDAPRequired', 'usernameLabelCustom', 'userSetupDelayed')
                    '#microsoft.graph.credentialSingleSignOnExtension'      = @('configurations', 'domains', 'extensionIdentifier', 'realm', 'teamIdentifier')
                    '#microsoft.graph.redirectSingleSignOnExtension'        = @('configurations', 'extensionIdentifier', 'teamIdentifier', 'urlPrefixes')
                    '#microsoft.graph.kerberosSingleSignOnExtension'        = $kerberosProperties
                })

            if ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
            {
                Write-Verbose -Message "Creating new Intune Device Features Configuration Policy for macOS {$($this.Id)}"

                $createParameters = $boundParameters
                $createdInstance = New-MgBetaDeviceManagementDeviceConfiguration -BodyParameter $createParameters

                $assignmentsHash = ConvertTo-IntunePolicyAssignment -IncludeDeviceFilter:$true -Assignments $this.Assignments
                if ($createdInstance.Id)
                {
                    Update-DeviceConfigurationPolicyAssignment `
                        -DeviceConfigurationPolicyId $createdInstance.Id `
                        -Targets $assignmentsHash `
                        -Repository 'deviceManagement/deviceConfigurations'
                }
            }
            elseif ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Present')
            {
                Write-Verbose -Message "Updating Intune Device Features Configuration Policy for macOS {$($this.Id)}"

                $updateParameters = $boundParameters
                Update-MgBetaDeviceManagementDeviceConfiguration -DeviceConfigurationId $currentInstance.Id -BodyParameter $updateParameters | Out-Null

                $assignmentsHash = ConvertTo-IntunePolicyAssignment -IncludeDeviceFilter:$true -Assignments $this.Assignments
                if ($currentInstance.Id)
                {
                    Update-DeviceConfigurationPolicyAssignment `
                        -DeviceConfigurationPolicyId $currentInstance.Id `
                        -Targets $assignmentsHash `
                        -Repository 'deviceManagement/deviceConfigurations'
                }
            }
            elseif ($this.Ensure -eq 'Absent' -and $currentInstance.Ensure -eq 'Present')
            {
                Write-Verbose -Message "Removing Intune Device Features Configuration Policy for macOS {$($this.Id)}"
                Remove-MgBetaDeviceManagementDeviceConfiguration -DeviceConfigurationId $currentInstance.Id | Out-Null
            }
        }
        catch
        {
            $this.LogError($_, 'Error updating data:')

            throw
        }
    }

    [bool] Test()
    {
        return ([M365DSCResourceBase] $this).Test()
    }

    [string] Export()
    {
        if ($this.RequiresPowerShellCore())
        {
            return [string] $this.InvokeInPowerShellCore('Export')
        }

        $ConnectionMode = $this.Connect('MicrosoftGraph')

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Export')

        try
        {
            [array] $exportedInstances = Get-M365DSCExportCachedCollection -Collection 'deviceConfigurations' `
                -ODataType 'microsoft.graph.macOSDeviceFeaturesConfiguration' `
                -Filter $this.Filter

            $dscContent = [System.Text.StringBuilder]::new()
            $i = 1

            if ($exportedInstances.Length -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }

            foreach ($exportedInstance in $exportedInstances)
            {
                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }

                Write-M365DSCHost -Message "    |---[$i/$($exportedInstances.Count)] $($exportedInstance.DisplayName)" -DeferWrite

                $Params = @{
                    Id                    = $exportedInstance.Id
                    DisplayName           = $exportedInstance.DisplayName
                    Credential            = $this.Credential
                    ApplicationId         = $this.ApplicationId
                    TenantId              = $this.TenantId
                    ApplicationSecret     = $this.ApplicationSecret
                    CertificateThumbprint = $this.CertificateThumbprint
                    CertificatePassword   = $this.CertificatePassword
                    CertificatePath       = $this.CertificatePath
                    ManagedIdentity       = $this.ManagedIdentity
                    AccessTokens          = $this.AccessTokens
                }

                $this.ExportedInstance = $exportedInstance
                $Results = $this.GetForExport($Params)

                if ($null -ne $Results.AirPrintDestinations)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.AirPrintDestinations `
                        -CIMInstanceName 'MSFT_MicrosoftGraphAirPrintDestination'
                    if (-not [System.String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.AirPrintDestinations = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('AirPrintDestinations') | Out-Null
                    }
                }

                if ($null -ne $Results.AppAssociatedDomains)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.AppAssociatedDomains `
                        -CIMInstanceName 'MSFT_MicrosoftGraphMacOSAssociatedDomainsItem'
                    if (-not [System.String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.AppAssociatedDomains = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('AppAssociatedDomains') | Out-Null
                    }
                }

                if ($null -ne $Results.Assignments)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.Assignments `
                        -CIMInstanceName 'MSFT_DeviceManagementConfigurationPolicyAssignments'
                    if (-not [System.String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.Assignments = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('Assignments') | Out-Null
                    }
                }

                if ($null -ne $Results.AssociatedDomains)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.AssociatedDomains `
                        -CIMInstanceName 'MSFT_MicrosoftGraphKeyValuePair2'
                    if (-not [System.String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.AssociatedDomains = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('AssociatedDomains') | Out-Null
                    }
                }

                if ($null -ne $Results.AutoLaunchItems)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.AutoLaunchItems `
                        -CIMInstanceName 'MSFT_MicrosoftGraphMacOSLaunchItem'
                    if (-not [System.String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.AutoLaunchItems = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('AutoLaunchItems') | Out-Null
                    }
                }

                if ($null -ne $Results.ContentCachingClientListenRanges)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.ContentCachingClientListenRanges `
                        -CIMInstanceName 'MSFT_MicrosoftGraphIpRange2'
                    if (-not [System.String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.ContentCachingClientListenRanges = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('ContentCachingClientListenRanges') | Out-Null
                    }
                }

                if ($null -ne $Results.ContentCachingPeerFilterRanges)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.ContentCachingPeerFilterRanges `
                        -CIMInstanceName 'MSFT_MicrosoftGraphIpRange2'
                    if (-not [System.String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.ContentCachingPeerFilterRanges = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('ContentCachingPeerFilterRanges') | Out-Null
                    }
                }

                if ($null -ne $Results.ContentCachingPeerListenRanges)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.ContentCachingPeerListenRanges `
                        -CIMInstanceName 'MSFT_MicrosoftGraphIpRange2'
                    if (-not [System.String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.ContentCachingPeerListenRanges = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('ContentCachingPeerListenRanges') | Out-Null
                    }
                }

                if ($null -ne $Results.ContentCachingPublicRanges)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.ContentCachingPublicRanges `
                        -CIMInstanceName 'MSFT_MicrosoftGraphIpRange2'
                    if (-not [System.String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.ContentCachingPublicRanges = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('ContentCachingPublicRanges') | Out-Null
                    }
                }

                if ($null -ne $Results.MacOSSingleSignOnExtension)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.MacOSSingleSignOnExtension `
                        -CIMInstanceName 'MSFT_MicrosoftGraphMacOSSingleSignOnExtension'
                    if (-not [System.String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.MacOSSingleSignOnExtension = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('MacOSSingleSignOnExtension') | Out-Null
                    }
                }

                if ($null -ne $Results.SingleSignOnExtension)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.SingleSignOnExtension `
                        -CIMInstanceName 'MSFT_MicrosoftGraphSingleSignOnExtension'
                    if (-not [System.String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.SingleSignOnExtension = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('SingleSignOnExtension') | Out-Null
                    }
                }
                $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                    -ConnectionMode $ConnectionMode `
                    -ModulePath $this.GetModulePath() `
                    -Results $Results `
                    -Credential $this.Credential `
                    -NoEscape @('AirPrintDestinations', 'AppAssociatedDomains', 'Assignments', 'AssociatedDomains', 'AutoLaunchItems', 'ContentCachingClientListenRanges', 'ContentCachingPeerFilterRanges', 'ContentCachingPeerListenRanges', 'ContentCachingPublicRanges', 'MacOSSingleSignOnExtension', 'SingleSignOnExtension')
                [void]$dscContent.Append($currentDSCBlock)
                Save-M365DSCPartialExport -Content $currentDSCBlock `
                    -FileName $Global:PartialExportFileName

                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
                $i++
            }

            return $dscContent.ToString()
        }
        catch
        {
            Write-M365DSCHost -Message $Global:M365DSCEmojiRedX

            $this.LogError($_, 'Error during Export:')

            throw
        }
    }

    hidden [IntuneDeviceFeaturesConfigurationPolicyMacOS] AsResult([System.Object] $Values)
    {
        if ($Values -is [IntuneDeviceFeaturesConfigurationPolicyMacOS])
        {
            return $Values
        }

        $result = [IntuneDeviceFeaturesConfigurationPolicyMacOS]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}

class MSFT_MicrosoftGraphAirPrintDestination
{
    [DscProperty()]
    [System.ComponentModel.Description('If true AirPrint connections are secured by Transport Layer Security (TLS). Default is false. Available in iOS 11.0 and later.')]
    [System.Nullable[System.Boolean]] $ForceTls

    [DscProperty()]
    [System.ComponentModel.Description('The IP Address of the AirPrint destination.')]
    [System.String] $IpAddress

    [DscProperty()]
    [System.ComponentModel.Description('The listening port of the AirPrint destination. If this key is not specified AirPrint will use the default port. Available in iOS 11.0 and later.')]
    [System.Nullable[System.Int32]] $Port

    [DscProperty()]
    [System.ComponentModel.Description('The Resource Path associated with the printer. This corresponds to the rp parameter of the ipps.tcp Bonjour record. For example: printers/CanonMG5300series, printers/XeroxPhaser7600, ipp/print, EpsonIPPPrinter.')]
    [System.String] $ResourcePath
}

class MSFT_MicrosoftGraphMacOSAssociatedDomainsItem
{
    [DscProperty()]
    [System.ComponentModel.Description('The application identifier of the app to associate domains with.')]
    [System.String] $ApplicationIdentifier

    [DscProperty()]
    [System.ComponentModel.Description('Determines whether data should be downloaded directly or via a CDN.')]
    [System.Nullable[System.Boolean]] $DirectDownloadsEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The list of domains to associate.')]
    [System.String[]] $Domains
}

class MSFT_DeviceManagementConfigurationPolicyAssignments
{
    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('The type of the target assignment.')]
    [ValidateSet('#microsoft.graph.cloudPcManagementGroupAssignmentTarget', '#microsoft.graph.groupAssignmentTarget', '#microsoft.graph.allLicensedUsersAssignmentTarget', '#microsoft.graph.allDevicesAssignmentTarget', '#microsoft.graph.exclusionGroupAssignmentTarget', '#microsoft.graph.configurationManagerCollectionAssignmentTarget')]
    [System.String] $dataType

    [DscProperty()]
    [System.ComponentModel.Description('The type of filter of the target assignment i.e. Exclude or Include. Possible values are:none, include, exclude.')]
    [ValidateSet('none', 'include', 'exclude')]
    [System.String] $deviceAndAppManagementAssignmentFilterType

    [DscProperty()]
    [System.ComponentModel.Description('The Id of the filter for the target assignment.')]
    [System.String] $deviceAndAppManagementAssignmentFilterId

    [DscProperty()]
    [System.ComponentModel.Description('The display name of the filter for the target assignment.')]
    [System.String] $deviceAndAppManagementAssignmentFilterDisplayName

    [DscProperty()]
    [System.ComponentModel.Description('The group Id that is the target of the assignment.')]
    [System.String] $groupId

    [DscProperty()]
    [System.ComponentModel.Description('The group Display Name that is the target of the assignment.')]
    [System.String] $groupDisplayName

    [DscProperty()]
    [System.ComponentModel.Description('The collection Id that is the target of the assignment.(ConfigMgr)')]
    [System.String] $collectionId
}

class MSFT_MicrosoftGraphKeyValuePair2
{
    [DscProperty()]
    [System.ComponentModel.Description('Name for this key-value pair')]
    [System.String] $Name

    [DscProperty()]
    [System.ComponentModel.Description('Value for this key-value pair')]
    [System.String] $Value
}

class MSFT_MicrosoftGraphMacOSLaunchItem
{
    [DscProperty()]
    [System.ComponentModel.Description('Whether or not to hide the item from the Users and Groups List.')]
    [System.Nullable[System.Boolean]] $Hide

    [DscProperty()]
    [System.ComponentModel.Description('Path to the launch item.')]
    [System.String] $Path
}

class MSFT_MicrosoftGraphIpRange2
{
    [DscProperty()]
    [System.ComponentModel.Description('Lower address.')]
    [System.String] $LowerAddress

    [DscProperty()]
    [System.ComponentModel.Description('The type of the entity.')]
    [ValidateSet('#microsoft.graph.iPv4Range', '#microsoft.graph.iPv6Range')]
    [System.String] $ODataType

    [DscProperty()]
    [System.ComponentModel.Description('Upper address.')]
    [System.String] $UpperAddress
}

class MSFT_MicrosoftGraphKeyTypedValuePair
{
    [DscProperty()]
    [System.ComponentModel.Description('The string key of the key-value pair.')]
    [System.String] $Key

    [DscProperty()]
    [System.ComponentModel.Description('The type of the entity.')]
    [ValidateSet('#microsoft.graph.keyBooleanValuePair', '#microsoft.graph.keyIntegerValuePair', '#microsoft.graph.keyRealValuePair', '#microsoft.graph.keyStringValuePair')]
    [System.String] $ODataType

    [DscProperty()]
    [System.ComponentModel.Description('The Boolean value of the key-value pair.')]
    [System.Nullable[System.Boolean]] $Value
}

class MSFT_MicrosoftGraphMacOSSingleSignOnExtension
{
    [DscProperty()]
    [System.ComponentModel.Description('Gets or sets the Active Directory site.')]
    [System.String] $ActiveDirectorySiteCode

    [DscProperty()]
    [System.ComponentModel.Description('Enables or disables whether the Kerberos extension can automatically determine its site name.')]
    [System.Nullable[System.Boolean]] $BlockActiveDirectorySiteAutoDiscovery

    [DscProperty()]
    [System.ComponentModel.Description('Enables or disables Keychain usage.')]
    [System.Nullable[System.Boolean]] $BlockAutomaticLogin

    [DscProperty()]
    [System.ComponentModel.Description('An optional list of additional bundle IDs allowed to use the AAD extension for single sign-on.')]
    [System.String[]] $BundleIdAccessControlList

    [DscProperty()]
    [System.ComponentModel.Description('Gets or sets the Generic Security Services name of the Kerberos cache to use for this profile.')]
    [System.String] $CacheName

    [DscProperty()]
    [System.ComponentModel.Description('Gets or sets a list of typed key-value pairs used to configure Credential-type profiles. This collection can contain a maximum of 500 elements.')]
    [MSFT_MicrosoftGraphKeyTypedValuePair[]] $Configurations

    [DscProperty()]
    [System.ComponentModel.Description('Gets or sets a list of app Bundle IDs allowed to access the Kerberos Ticket Granting Ticket.')]
    [System.String[]] $CredentialBundleIdAccessControlList

    [DscProperty()]
    [System.ComponentModel.Description('When set to True, the credential is requested on the next matching Kerberos challenge or network state change. When the credential is expired or missing, a new credential is created. Available for devices running macOS versions 12 and later.')]
    [System.Nullable[System.Boolean]] $CredentialsCacheMonitored

    [DscProperty()]
    [System.ComponentModel.Description('Gets or sets a list of realms for custom domain-realm mapping. Realms are case sensitive.')]
    [System.String[]] $DomainRealms

    [DscProperty()]
    [System.ComponentModel.Description('Gets or sets a list of hosts or domain names for which the app extension performs SSO.')]
    [System.String[]] $Domains

    [DscProperty()]
    [System.ComponentModel.Description('Enables or disables shared device mode.')]
    [System.Nullable[System.Boolean]] $EnableSharedDeviceMode

    [DscProperty()]
    [System.ComponentModel.Description('Gets or sets the bundle ID of the app extension that performs SSO for the specified URLs.')]
    [System.String] $ExtensionIdentifier

    [DscProperty()]
    [System.ComponentModel.Description('When true, this profile''s realm will be selected as the default. Necessary if multiple Kerberos-type profiles are configured.')]
    [System.Nullable[System.Boolean]] $IsDefaultRealm

    [DscProperty()]
    [System.ComponentModel.Description('When set to True, the Kerberos extension allows any apps entered with the app bundle ID, managed apps, and standard Kerberos utilities, such as TicketViewer and klist, to access and use the credential. Available for devices running macOS versions 12 and later.')]
    [System.Nullable[System.Boolean]] $KerberosAppsInBundleIdACLIncluded

    [DscProperty()]
    [System.ComponentModel.Description('When set to True, the Kerberos extension allows managed apps, and any apps entered with the app bundle ID to access the credential. When set to False, the Kerberos extension allows all apps to access the credential. Available for devices running iOS and iPadOS versions 14 and later.')]
    [System.Nullable[System.Boolean]] $ManagedAppsInBundleIdACLIncluded

    [DscProperty()]
    [System.ComponentModel.Description('Select how other processes use the Kerberos Extension credential.')]
    [System.String] $ModeCredentialUsed

    [DscProperty()]
    [System.ComponentModel.Description('The type of the entity.')]
    [ValidateSet('#microsoft.graph.macOSAzureAdSingleSignOnExtension', '#microsoft.graph.macOSCredentialSingleSignOnExtension', '#microsoft.graph.macOSKerberosSingleSignOnExtension', '#microsoft.graph.macOSRedirectSingleSignOnExtension')]
    [System.String] $ODataType

    [DscProperty()]
    [System.ComponentModel.Description('Enables or disables password changes.')]
    [System.Nullable[System.Boolean]] $PasswordBlockModification

    [DscProperty()]
    [System.ComponentModel.Description('Gets or sets the URL that the user will be sent to when they initiate a password change.')]
    [System.String] $PasswordChangeUrl

    [DscProperty()]
    [System.ComponentModel.Description('Enables or disables password syncing. This won''t affect users logged in with a mobile account on macOS.')]
    [System.Nullable[System.Boolean]] $PasswordEnableLocalSync

    [DscProperty()]
    [System.ComponentModel.Description('Overrides the default password expiration in days. For most domains, this value is calculated automatically.')]
    [System.Nullable[System.Int32]] $PasswordExpirationDays

    [DscProperty()]
    [System.ComponentModel.Description('Gets or sets the number of days until the user is notified that their password will expire (default is 15).')]
    [System.Nullable[System.Int32]] $PasswordExpirationNotificationDays

    [DscProperty()]
    [System.ComponentModel.Description('Gets or sets the minimum number of days until a user can change their password again.')]
    [System.Nullable[System.Int32]] $PasswordMinimumAgeDays

    [DscProperty()]
    [System.ComponentModel.Description('Gets or sets the minimum length of a password.')]
    [System.Nullable[System.Int32]] $PasswordMinimumLength

    [DscProperty()]
    [System.ComponentModel.Description('Gets or sets the number of previous passwords to block.')]
    [System.Nullable[System.Int32]] $PasswordPreviousPasswordBlockCount

    [DscProperty()]
    [System.ComponentModel.Description('Enables or disables whether passwords must meet Active Directory''s complexity requirements.')]
    [System.Nullable[System.Boolean]] $PasswordRequireActiveDirectoryComplexity

    [DscProperty()]
    [System.ComponentModel.Description('Gets or sets a description of the password complexity requirements.')]
    [System.String] $PasswordRequirementsDescription

    [DscProperty()]
    [System.ComponentModel.Description('Add creates an ordered list of preferred Key Distribution Centers (KDCs) to use for Kerberos traffic. This list is used when the servers are not discoverable using DNS. When the servers are discoverable, the list is used for both connectivity checks, and used first for Kerberos traffic. If the servers dont respond, then the device uses DNS discovery. Delete removes an existing list, and devices use DNS discovery. Available for devices running macOS versions 12 and later.')]
    [System.String[]] $PreferredKDCs

    [DscProperty()]
    [System.ComponentModel.Description('Gets or sets the case-sensitive realm name for this profile.')]
    [System.String] $Realm

    [DscProperty()]
    [System.ComponentModel.Description('Gets or sets whether to require authentication via Touch ID, Face ID, or a passcode to access the keychain entry.')]
    [System.Nullable[System.Boolean]] $RequireUserPresence

    [DscProperty()]
    [System.ComponentModel.Description('Text displayed to the user at the Kerberos sign in window. Available for devices running iOS and iPadOS versions 14 and later.')]
    [System.String] $SignInHelpText

    [DscProperty()]
    [System.ComponentModel.Description('Gets or sets the team ID of the app extension that performs SSO for the specified URLs.')]
    [System.String] $TeamIdentifier

    [DscProperty()]
    [System.ComponentModel.Description('When set to True, LDAP connections are required to use Transport Layer Security (TLS). Available for devices running macOS versions 11 and later.')]
    [System.Nullable[System.Boolean]] $TlsForLDAPRequired

    [DscProperty()]
    [System.ComponentModel.Description('One or more URL prefixes of identity providers on whose behalf the app extension performs single sign-on. URLs must begin with http:// or https://. All URL prefixes must be unique for all profiles.')]
    [System.String[]] $UrlPrefixes

    [DscProperty()]
    [System.ComponentModel.Description('This label replaces the user name shown in the Kerberos extension. You can enter a name to match the name of your company or organization. Available for devices running macOS versions 11 and later.')]
    [System.String] $UsernameLabelCustom

    [DscProperty()]
    [System.ComponentModel.Description('Gets or sets the principle user name to use for this profile. The realm name does not need to be included.')]
    [System.String] $UserPrincipalName

    [DscProperty()]
    [System.ComponentModel.Description('When set to True, the user isnt prompted to set up the Kerberos extension until the extension is enabled by the admin, or a Kerberos challenge is received. Available for devices running macOS versions 11 and later.')]
    [System.Nullable[System.Boolean]] $UserSetupDelayed
}

class MSFT_MicrosoftGraphSingleSignOnExtension
{
    [DscProperty()]
    [System.ComponentModel.Description('Gets or sets the Active Directory site.')]
    [System.String] $ActiveDirectorySiteCode

    [DscProperty()]
    [System.ComponentModel.Description('Enables or disables whether the Kerberos extension can automatically determine its site name.')]
    [System.Nullable[System.Boolean]] $BlockActiveDirectorySiteAutoDiscovery

    [DscProperty()]
    [System.ComponentModel.Description('Enables or disables Keychain usage.')]
    [System.Nullable[System.Boolean]] $BlockAutomaticLogin

    [DscProperty()]
    [System.ComponentModel.Description('Gets or sets the Generic Security Services name of the Kerberos cache to use for this profile.')]
    [System.String] $CacheName

    [DscProperty()]
    [System.ComponentModel.Description('Gets or sets a list of typed key-value pairs used to configure Credential-type profiles. This collection can contain a maximum of 500 elements.')]
    [MSFT_MicrosoftGraphKeyTypedValuePair[]] $Configurations

    [DscProperty()]
    [System.ComponentModel.Description('Gets or sets a list of app Bundle IDs allowed to access the Kerberos Ticket Granting Ticket.')]
    [System.String[]] $CredentialBundleIdAccessControlList

    [DscProperty()]
    [System.ComponentModel.Description('Gets or sets a list of realms for custom domain-realm mapping. Realms are case sensitive.')]
    [System.String[]] $DomainRealms

    [DscProperty()]
    [System.ComponentModel.Description('Gets or sets a list of hosts or domain names for which the app extension performs SSO.')]
    [System.String[]] $Domains

    [DscProperty()]
    [System.ComponentModel.Description('Gets or sets the bundle ID of the app extension that performs SSO for the specified URLs.')]
    [System.String] $ExtensionIdentifier

    [DscProperty()]
    [System.ComponentModel.Description('When true, this profile''s realm will be selected as the default. Necessary if multiple Kerberos-type profiles are configured.')]
    [System.Nullable[System.Boolean]] $IsDefaultRealm

    [DscProperty()]
    [System.ComponentModel.Description('The type of the entity.')]
    [ValidateSet('#microsoft.graph.credentialSingleSignOnExtension', '#microsoft.graph.iosSingleSignOnExtension', '#microsoft.graph.kerberosSingleSignOnExtension', '#microsoft.graph.macOSSingleSignOnExtension', '#microsoft.graph.redirectSingleSignOnExtension')]
    [System.String] $ODataType

    [DscProperty()]
    [System.ComponentModel.Description('Enables or disables password changes.')]
    [System.Nullable[System.Boolean]] $PasswordBlockModification

    [DscProperty()]
    [System.ComponentModel.Description('Gets or sets the URL that the user will be sent to when they initiate a password change.')]
    [System.String] $PasswordChangeUrl

    [DscProperty()]
    [System.ComponentModel.Description('Enables or disables password syncing. This won''t affect users logged in with a mobile account on macOS.')]
    [System.Nullable[System.Boolean]] $PasswordEnableLocalSync

    [DscProperty()]
    [System.ComponentModel.Description('Overrides the default password expiration in days. For most domains, this value is calculated automatically.')]
    [System.Nullable[System.Int32]] $PasswordExpirationDays

    [DscProperty()]
    [System.ComponentModel.Description('Gets or sets the number of days until the user is notified that their password will expire (default is 15).')]
    [System.Nullable[System.Int32]] $PasswordExpirationNotificationDays

    [DscProperty()]
    [System.ComponentModel.Description('Gets or sets the minimum number of days until a user can change their password again.')]
    [System.Nullable[System.Int32]] $PasswordMinimumAgeDays

    [DscProperty()]
    [System.ComponentModel.Description('Gets or sets the minimum length of a password.')]
    [System.Nullable[System.Int32]] $PasswordMinimumLength

    [DscProperty()]
    [System.ComponentModel.Description('Gets or sets the number of previous passwords to block.')]
    [System.Nullable[System.Int32]] $PasswordPreviousPasswordBlockCount

    [DscProperty()]
    [System.ComponentModel.Description('Enables or disables whether passwords must meet Active Directory''s complexity requirements.')]
    [System.Nullable[System.Boolean]] $PasswordRequireActiveDirectoryComplexity

    [DscProperty()]
    [System.ComponentModel.Description('Gets or sets a description of the password complexity requirements.')]
    [System.String] $PasswordRequirementsDescription

    [DscProperty()]
    [System.ComponentModel.Description('Gets or sets the case-sensitive realm name for this profile.')]
    [System.String] $Realm

    [DscProperty()]
    [System.ComponentModel.Description('Gets or sets whether to require authentication via Touch ID, Face ID, or a passcode to access the keychain entry.')]
    [System.Nullable[System.Boolean]] $RequireUserPresence

    [DscProperty()]
    [System.ComponentModel.Description('Gets or sets the team ID of the app extension that performs SSO for the specified URLs.')]
    [System.String] $TeamIdentifier

    [DscProperty()]
    [System.ComponentModel.Description('One or more URL prefixes of identity providers on whose behalf the app extension performs single sign-on. URLs must begin with http:// or https://. All URL prefixes must be unique for all profiles.')]
    [System.String[]] $UrlPrefixes

    [DscProperty()]
    [System.ComponentModel.Description('Gets or sets the principle user name to use for this profile. The realm name does not need to be included.')]
    [System.String] $UserPrincipalName
}
