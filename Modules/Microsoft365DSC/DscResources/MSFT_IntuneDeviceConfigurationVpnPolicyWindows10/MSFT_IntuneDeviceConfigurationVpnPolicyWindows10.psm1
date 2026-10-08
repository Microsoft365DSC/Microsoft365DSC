using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class IntuneDeviceConfigurationVpnPolicyWindows10 : M365DSCResourceBase
{
    [DscProperty()]
    [System.ComponentModel.Description('Associated Apps. This collection can contain a maximum of 10000 elements.')]
    [MSFT_MicrosoftGraphwindows10AssociatedApps[]] $AssociatedApps

    [DscProperty()]
    [System.ComponentModel.Description('Authentication method. Possible values are: certificate, usernameAndPassword, customEapXml, derivedCredential.')]
    [ValidateSet('certificate', 'usernameAndPassword', 'customEapXml', 'derivedCredential')]
    [System.String] $AuthenticationMethod

    [DscProperty()]
    [System.ComponentModel.Description('Connection type. Possible values are: pulseSecure, f5EdgeClient, dellSonicWallMobileConnect, checkPointCapsuleVpn, automatic, ikEv2, l2tp, pptp, citrix, paloAltoGlobalProtect, ciscoAnyConnect, unknownFutureValue, microsoftTunnel.')]
    [ValidateSet('pulseSecure', 'f5EdgeClient', 'dellSonicWallMobileConnect', 'checkPointCapsuleVpn', 'automatic', 'ikEv2', 'l2tp', 'pptp', 'citrix', 'paloAltoGlobalProtect', 'ciscoAnyConnect', 'unknownFutureValue', 'microsoftTunnel')]
    [System.String] $ConnectionType

    [DscProperty()]
    [System.ComponentModel.Description('Cryptography Suite security settings for IKEv2 VPN in Windows10 and above')]
    [MSFT_MicrosoftGraphcryptographySuite] $CryptographySuite

    [DscProperty()]
    [System.ComponentModel.Description('DNS rules. This collection can contain a maximum of 1000 elements.')]
    [MSFT_MicrosoftGraphvpnDnsRule[]] $DnsRules

    [DscProperty()]
    [System.ComponentModel.Description('Specify DNS suffixes to add to the DNS search list to properly route short names.')]
    [System.String[]] $DnsSuffixes

    [DscProperty()]
    [System.ComponentModel.Description('Extensible Authentication Protocol (EAP) XML, Base64 encoded.')]
    [System.String] $EapXml

    [DscProperty()]
    [System.ComponentModel.Description('Enable Always On mode.')]
    [System.Nullable[System.Boolean]] $EnableAlwaysOn

    [DscProperty()]
    [System.ComponentModel.Description('Enable conditional access.')]
    [System.Nullable[System.Boolean]] $EnableConditionalAccess

    [DscProperty()]
    [System.ComponentModel.Description('Enable device tunnel.')]
    [System.Nullable[System.Boolean]] $EnableDeviceTunnel

    [DscProperty()]
    [System.ComponentModel.Description('Enable IP address registration with internal DNS.')]
    [System.Nullable[System.Boolean]] $EnableDnsRegistration

    [DscProperty()]
    [System.ComponentModel.Description('Enable single sign-on (SSO) with alternate certificate.')]
    [System.Nullable[System.Boolean]] $EnableSingleSignOnWithAlternateCertificate

    [DscProperty()]
    [System.ComponentModel.Description('Enable split tunneling.')]
    [System.Nullable[System.Boolean]] $EnableSplitTunneling

    [DscProperty()]
    [System.ComponentModel.Description('ID of the Microsoft Tunnel site associated with the VPN profile.')]
    [System.String] $MicrosoftTunnelSiteId

    [DscProperty()]
    [System.ComponentModel.Description('Only associated Apps can use connection (per-app VPN).')]
    [System.Nullable[System.Boolean]] $OnlyAssociatedAppsCanUseConnection

    [DscProperty()]
    [System.ComponentModel.Description('Profile target type. Possible values are: user, device, autoPilotDevice.')]
    [ValidateSet('user', 'device', 'autoPilotDevice')]
    [System.String] $ProfileTarget

    [DscProperty()]
    [System.ComponentModel.Description('Proxy Server.')]
    [MSFT_MicrosoftGraphwindows10VpnProxyServer] $ProxyServer

    [DscProperty()]
    [System.ComponentModel.Description('Remember user credentials.')]
    [System.Nullable[System.Boolean]] $RememberUserCredentials

    [DscProperty()]
    [System.ComponentModel.Description('Routes (optional for third-party providers). This collection can contain a maximum of 1000 elements.')]
    [MSFT_MicrosoftGraphvpnRoute[]] $Routes

    [DscProperty()]
    [System.ComponentModel.Description('Single sign-on Extended Key Usage (EKU).')]
    [MSFT_MicrosoftGraphextendedKeyUsage] $SingleSignOnEku

    [DscProperty()]
    [System.ComponentModel.Description('Single sign-on issuer hash.')]
    [System.String] $SingleSignOnIssuerHash

    [DscProperty()]
    [System.ComponentModel.Description('Traffic rules. This collection can contain a maximum of 1000 elements.')]
    [MSFT_MicrosoftGraphvpnTrafficRule[]] $TrafficRules

    [DscProperty()]
    [System.ComponentModel.Description('Trusted Network Domains')]
    [System.String[]] $TrustedNetworkDomains

    [DscProperty()]
    [System.ComponentModel.Description('Windows Information Protection (WIP) domain to associate with this connection.')]
    [System.String] $WindowsInformationProtectionDomain

    [DscProperty()]
    [System.ComponentModel.Description('Connection name displayed to the user.')]
    [System.String] $ConnectionName

    [DscProperty()]
    [System.ComponentModel.Description('Custom XML commands that configure the VPN connection, Base64 encoded.')]
    [System.String] $CustomXml

    [DscProperty()]
    [System.ComponentModel.Description('List of VPN Servers on the network. Make sure end users can access these network locations. This collection can contain a maximum of 500 elements.')]
    [MSFT_MicrosoftGraphvpnServer[]] $Servers

    [DscProperty()]
    [System.ComponentModel.Description('Admin provided description of the Device Configuration.')]
    [System.String] $Description

    [DscProperty()]
    [System.ComponentModel.Description('The device mode applicability rule for this Policy.')]
    [MSFT_DeviceManagementApplicabilityRuleDeviceMode] $DeviceManagementApplicabilityRuleDeviceMode

    [DscProperty()]
    [System.ComponentModel.Description('The OS edition applicability for this Policy.')]
    [MSFT_DeviceManagementApplicabilityRuleOsEdition] $DeviceManagementApplicabilityRuleOsEdition

    [DscProperty()]
    [System.ComponentModel.Description('The OS version applicability rule for this Policy.')]
    [MSFT_DeviceManagementApplicabilityRuleOsVersion] $DeviceManagementApplicabilityRuleOsVersion

    [DscProperty(Key)]
    [System.ComponentModel.Description('Admin provided name of the device configuration.')]
    [System.String] $DisplayName

    [DscProperty()]
    [System.ComponentModel.Description('The unique identifier for an entity. Read-only.')]
    [System.String] $Id

    [DscProperty()]
    [System.ComponentModel.Description('List of Scope Tags for this Entity instance.')]
    [System.String[]] $RoleScopeTagIds

    [DscProperty()]
    [System.ComponentModel.Description('Represents the assignment to the Intune policy.')]
    [MSFT_DeviceManagementConfigurationPolicyAssignments[]] $Assignments

    [DscProperty()]
    [System.ComponentModel.Description('Present ensures the policy exists, absent ensures it is removed.')]
    [ValidateSet('Present', 'Absent')]
    [System.String] $Ensure

    [DscProperty()]
    [System.ComponentModel.Description('Credentials of the Admin')]
    [System.Management.Automation.PSCredential] $Credential

    [DscProperty()]
    [System.ComponentModel.Description('Id of the Azure Active Directory application to authenticate with.')]
    [System.String] $ApplicationId

    [DscProperty()]
    [System.ComponentModel.Description('Id of the Azure Active Directory tenant used for authentication.')]
    [System.String] $TenantId

    [DscProperty()]
    [System.ComponentModel.Description('Secret of the Azure Active Directory tenant used for authentication.')]
    [System.Management.Automation.PSCredential] $ApplicationSecret

    [DscProperty()]
    [System.ComponentModel.Description('Thumbprint of the Azure Active Directory application''s authentication certificate to use for authentication.')]
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

    [IntuneDeviceConfigurationVpnPolicyWindows10] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [IntuneDeviceConfigurationVpnPolicyWindows10]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of the Intune Device Configuration Vpn Policy for Windows10 with Id {$($this.Id)} and DisplayName {$($this.DisplayName)}"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.DisplayName -ne $this.DisplayName)
            {
                $null = $this.Connect('MicrosoftGraph')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullResult = $this.GetBoundParameters()
                $nullResult.Ensure = 'Absent'

                $getValue = $null
                #region resource generator code
                if (-not [string]::IsNullOrEmpty($this.Id))
                {
                    $getValue = Get-MgBetaDeviceManagementDeviceConfiguration -All -Filter "Id eq '$($this.Id)'" -ErrorAction SilentlyContinue
                }

                if ($null -eq $getValue)
                {
                    Write-Verbose -Message "Could not find an Intune Device Configuration Vpn Policy for Windows10 with Id {$($this.Id)}"

                    if (-not [string]::IsNullOrEmpty($this.DisplayName))
                    {
                        $getValue = Get-MgBetaDeviceManagementDeviceConfiguration `
                            -All `
                            -Filter "DisplayName eq '$($this.DisplayName -replace "'", "''")' and isof('microsoft.graph.windows10VpnConfiguration')" `
                            -ErrorAction SilentlyContinue
                    }
                }
                #endregion
                if ($null -eq $getValue)
                {
                    Write-Verbose -Message "Could not find an Intune Device Configuration Vpn Policy for Windows10 with DisplayName {$($this.DisplayName)}"
                    return $this.AsResult($nullResult)
                }
            }
            else
            {
                $getValue = $this.ExportedInstance
            }
            $resolvedId = $getValue.Id
            Write-Verbose -Message "An Intune Device Configuration Vpn Policy for Windows10 with Id {$($resolvedId)} and DisplayName {$($this.DisplayName)} was found."

            #region resource generator code
            $complexAssociatedApps = @()
            foreach ($currentassociatedApps in $getValue.associatedApps)
            {
                $myassociatedApps = [ordered]@{}
                if ($null -ne $currentassociatedApps.appType)
                {
                    $myassociatedApps.Add('AppType', $currentassociatedApps.appType)
                }
                $myassociatedApps.Add('Identifier', $currentassociatedApps.identifier)
                if ($myassociatedApps.values.Where({ $null -ne $_ }).Count -gt 0)
                {
                    $complexAssociatedApps += $myassociatedApps
                }
            }

            $complexCryptographySuite = [ordered]@{}
            if ($null -ne $getValue.cryptographySuite.authenticationTransformConstants)
            {
                $complexCryptographySuite.Add('AuthenticationTransformConstants', $getValue.cryptographySuite.authenticationTransformConstants)
            }
            if ($null -ne $getValue.cryptographySuite.cipherTransformConstants)
            {
                $complexCryptographySuite.Add('CipherTransformConstants', $getValue.cryptographySuite.cipherTransformConstants)
            }
            if ($null -ne $getValue.cryptographySuite.dhGroup)
            {
                $complexCryptographySuite.Add('DhGroup', $getValue.cryptographySuite.dhGroup)
            }
            if ($null -ne $getValue.cryptographySuite.encryptionMethod)
            {
                $complexCryptographySuite.Add('EncryptionMethod', $getValue.cryptographySuite.encryptionMethod)
            }
            if ($null -ne $getValue.cryptographySuite.integrityCheckMethod)
            {
                $complexCryptographySuite.Add('IntegrityCheckMethod', $getValue.cryptographySuite.integrityCheckMethod)
            }
            if ($null -ne $getValue.cryptographySuite.pfsGroup)
            {
                $complexCryptographySuite.Add('PfsGroup', $getValue.cryptographySuite.pfsGroup)
            }
            if ($complexCryptographySuite.values.Where({ $null -ne $_ }).Count -eq 0)
            {
                $complexCryptographySuite = $null
            }

            $complexDnsRules = @()
            foreach ($currentdnsRules in $getValue.dnsRules)
            {
                $mydnsRules = [ordered]@{}
                $mydnsRules.Add('AutoTrigger', $currentdnsRules.autoTrigger)
                $mydnsRules.Add('Name', $currentdnsRules.name)
                $mydnsRules.Add('Persistent', $currentdnsRules.persistent)
                $mydnsRules.Add('ProxyServerUri', $currentdnsRules.proxyServerUri)
                $mydnsRules.Add('Servers', $currentdnsRules.servers)
                if ($mydnsRules.values.Where({ $null -ne $_ }).Count -gt 0)
                {
                    $complexDnsRules += $mydnsRules
                }
            }

            $complexProxyServer = [ordered]@{}
            $complexProxyServer.Add('BypassProxyServerForLocalAddress', $getValue.proxyServer.bypassProxyServerForLocalAddress)
            $complexProxyServer.Add('Address', $getValue.proxyServer.address)
            $complexProxyServer.Add('AutomaticConfigurationScriptUrl', $getValue.proxyServer.automaticConfigurationScriptUrl)
            $complexProxyServer.Add('Port', $getValue.proxyServer.port)
            $complexProxyServer.Add('AutomaticallyDetectProxySettings', $getValue.proxyServer.automaticallyDetectProxySettings)
            if ($null -ne $getValue.proxyServer.'@odata.type')
            {
                $complexProxyServer.Add('odataType', $getValue.proxyServer.'@odata.type')
            }
            if ($complexProxyServer.values.Where({ $null -ne $_ }).Count -eq 0)
            {
                $complexProxyServer = $null
            }

            $complexRoutes = @()
            foreach ($currentroutes in $getValue.routes)
            {
                $myroutes = [ordered]@{}
                $myroutes.Add('DestinationPrefix', $currentroutes.destinationPrefix)
                $myroutes.Add('PrefixSize', $currentroutes.prefixSize)
                if ($myroutes.values.Where({ $null -ne $_ }).Count -gt 0)
                {
                    $complexRoutes += $myroutes
                }
            }

            $complexSingleSignOnEku = [ordered]@{}
            $complexSingleSignOnEku.Add('Name', $getValue.singleSignOnEku.name)
            $complexSingleSignOnEku.Add('ObjectIdentifier', $getValue.singleSignOnEku.objectIdentifier)
            if ($complexSingleSignOnEku.values.Where({ $null -ne $_ }).Count -eq 0)
            {
                $complexSingleSignOnEku = $null
            }

            $complexTrafficRules = @()
            foreach ($currenttrafficRules in $getValue.trafficRules)
            {
                $mytrafficRules = [ordered]@{}
                $mytrafficRules.Add('AppId', $currenttrafficRules.appId)
                if ($null -ne $currenttrafficRules.appType)
                {
                    $mytrafficRules.Add('AppType', $currenttrafficRules.appType)
                }
                $mytrafficRules.Add('Claims', $currenttrafficRules.claims)
                $complexLocalAddressRanges = @()
                foreach ($currentLocalAddressRanges in $currenttrafficRules.localAddressRanges)
                {
                    $myLocalAddressRanges = [ordered]@{}
                    $myLocalAddressRanges.Add('LowerAddress', $currentLocalAddressRanges.lowerAddress)
                    $myLocalAddressRanges.Add('UpperAddress', $currentLocalAddressRanges.upperAddress)
                    $myLocalAddressRanges.Add('CidrAddress', $currentLocalAddressRanges.cidrAddress)
                    if ($null -ne $currentLocalAddressRanges.'@odata.type')
                    {
                        $myLocalAddressRanges.Add('odataType', $currentLocalAddressRanges.'@odata.type')
                    }
                    if ($myLocalAddressRanges.values.Where({ $null -ne $_ }).Count -gt 0)
                    {
                        $complexLocalAddressRanges += $myLocalAddressRanges
                    }
                }
                $mytrafficRules.Add('LocalAddressRanges', $complexLocalAddressRanges)
                $complexLocalPortRanges = @()
                foreach ($currentLocalPortRanges in $currenttrafficRules.localPortRanges)
                {
                    $myLocalPortRanges = [ordered]@{}
                    $myLocalPortRanges.Add('LowerNumber', $currentLocalPortRanges.lowerNumber)
                    $myLocalPortRanges.Add('UpperNumber', $currentLocalPortRanges.upperNumber)
                    if ($myLocalPortRanges.values.Where({ $null -ne $_ }).Count -gt 0)
                    {
                        $complexLocalPortRanges += $myLocalPortRanges
                    }
                }
                $mytrafficRules.Add('LocalPortRanges', $complexLocalPortRanges)
                $mytrafficRules.Add('Name', $currenttrafficRules.name)
                $mytrafficRules.Add('Protocols', $currenttrafficRules.protocols)
                $complexRemoteAddressRanges = @()
                foreach ($currentRemoteAddressRanges in $currenttrafficRules.remoteAddressRanges)
                {
                    $myRemoteAddressRanges = [ordered]@{}
                    $myRemoteAddressRanges.Add('LowerAddress', $currentRemoteAddressRanges.lowerAddress)
                    $myRemoteAddressRanges.Add('UpperAddress', $currentRemoteAddressRanges.upperAddress)
                    $myRemoteAddressRanges.Add('CidrAddress', $currentRemoteAddressRanges.cidrAddress)
                    if ($null -ne $currentRemoteAddressRanges.'@odata.type')
                    {
                        $myRemoteAddressRanges.Add('odataType', $currentRemoteAddressRanges.'@odata.type')
                    }
                    if ($myRemoteAddressRanges.values.Where({ $null -ne $_ }).Count -gt 0)
                    {
                        $complexRemoteAddressRanges += $myRemoteAddressRanges
                    }
                }
                $mytrafficRules.Add('RemoteAddressRanges', $complexRemoteAddressRanges)
                $complexRemotePortRanges = @()
                foreach ($currentRemotePortRanges in $currenttrafficRules.remotePortRanges)
                {
                    $myRemotePortRanges = [ordered]@{}
                    $myRemotePortRanges.Add('LowerNumber', $currentRemotePortRanges.lowerNumber)
                    $myRemotePortRanges.Add('UpperNumber', $currentRemotePortRanges.upperNumber)
                    if ($myRemotePortRanges.values.Where({ $null -ne $_ }).Count -gt 0)
                    {
                        $complexRemotePortRanges += $myRemotePortRanges
                    }
                }
                $mytrafficRules.Add('RemotePortRanges', $complexRemotePortRanges)
                if ($null -ne $currenttrafficRules.routingPolicyType)
                {
                    $mytrafficRules.Add('RoutingPolicyType', $currenttrafficRules.routingPolicyType)
                }
                if ($null -ne $currenttrafficRules.vpnTrafficDirection)
                {
                    $mytrafficRules.Add('VpnTrafficDirection', $currenttrafficRules.vpnTrafficDirection)
                }
                if ($mytrafficRules.values.Where({ $null -ne $_ }).Count -gt 0)
                {
                    $complexTrafficRules += $mytrafficRules
                }
            }

            $complexServers = @()
            foreach ($currentservers in $getValue.servers)
            {
                $myservers = [ordered]@{}
                $myservers.Add('Address', $currentservers.address)
                $myservers.Add('Description', $currentservers.description)
                $myservers.Add('IsDefaultServer', $currentservers.isDefaultServer)
                if ($myservers.values.Where({ $null -ne $_ }).Count -gt 0)
                {
                    $complexServers += $myservers
                }
            }

            $complexDeviceManagementApplicabilityRuleDeviceMode = [ordered]@{}
            $complexDeviceManagementApplicabilityRuleDeviceMode.Add('DeviceMode', $getValue.DeviceManagementApplicabilityRuleDeviceMode.DeviceMode)
            $complexDeviceManagementApplicabilityRuleDeviceMode.Add('Name', $getValue.DeviceManagementApplicabilityRuleDeviceMode.Name)
            $complexDeviceManagementApplicabilityRuleDeviceMode.Add('RuleType', $getValue.DeviceManagementApplicabilityRuleDeviceMode.RuleType)
            if ($complexDeviceManagementApplicabilityRuleDeviceMode.values.Where({ $null -ne $_ }).Count -eq 0)
            {
                $complexDeviceManagementApplicabilityRuleDeviceMode = $null
            }

            $complexDeviceManagementApplicabilityRuleOsEdition = [ordered]@{}
            $complexDeviceManagementApplicabilityRuleOsEdition.Add('Name', $getValue.DeviceManagementApplicabilityRuleOSEdition.Name)
            $complexDeviceManagementApplicabilityRuleOsEdition.Add('OsEditionTypes', [string[]]$getValue.DeviceManagementApplicabilityRuleOSEdition.OsEditionTypes)
            $complexDeviceManagementApplicabilityRuleOsEdition.Add('RuleType', $getValue.DeviceManagementApplicabilityRuleOSEdition.RuleType)
            if ($complexDeviceManagementApplicabilityRuleOsEdition.values.Where({ $null -ne $_ }).Count -eq 0)
            {
                $complexDeviceManagementApplicabilityRuleOsEdition = $null
            }

            $complexDeviceManagementApplicabilityRuleOsVersion = [ordered]@{}
            $complexDeviceManagementApplicabilityRuleOsVersion.Add('MaxOSVersion', $getValue.DeviceManagementApplicabilityRuleOSVersion.MaxOSVersion)
            $complexDeviceManagementApplicabilityRuleOsVersion.Add('MinOSVersion', $getValue.DeviceManagementApplicabilityRuleOSVersion.MinOSVersion)
            $complexDeviceManagementApplicabilityRuleOsVersion.Add('Name', $getValue.DeviceManagementApplicabilityRuleOSVersion.Name)
            $complexDeviceManagementApplicabilityRuleOsVersion.Add('RuleType', $getValue.DeviceManagementApplicabilityRuleOSVersion.RuleType)
            if ($complexDeviceManagementApplicabilityRuleOsVersion.values.Where({ $null -ne $_ }).Count -eq 0)
            {
                $complexDeviceManagementApplicabilityRuleOsVersion = $null
            }
            #endregion

            $results = @{
                #region resource generator code
                AssociatedApps                              = $complexAssociatedApps
                AuthenticationMethod                        = $getValue.authenticationMethod
                ConnectionType                              = $getValue.connectionType
                CryptographySuite                           = $complexCryptographySuite
                DnsRules                                    = $complexDnsRules
                DnsSuffixes                                 = $getValue.dnsSuffixes
                EapXml                                      = $getValue.eapXml
                EnableAlwaysOn                              = $getValue.enableAlwaysOn
                EnableConditionalAccess                     = $getValue.enableConditionalAccess
                EnableDeviceTunnel                          = $getValue.enableDeviceTunnel
                EnableDnsRegistration                       = $getValue.enableDnsRegistration
                EnableSingleSignOnWithAlternateCertificate  = $getValue.enableSingleSignOnWithAlternateCertificate
                EnableSplitTunneling                        = $getValue.enableSplitTunneling
                MicrosoftTunnelSiteId                       = $getValue.microsoftTunnelSiteId
                OnlyAssociatedAppsCanUseConnection          = $getValue.onlyAssociatedAppsCanUseConnection
                ProfileTarget                               = $getValue.profileTarget
                ProxyServer                                 = $complexProxyServer
                RememberUserCredentials                     = $getValue.rememberUserCredentials
                Routes                                      = $complexRoutes
                SingleSignOnEku                             = $complexSingleSignOnEku
                SingleSignOnIssuerHash                      = $getValue.singleSignOnIssuerHash
                TrafficRules                                = $complexTrafficRules
                TrustedNetworkDomains                       = $getValue.trustedNetworkDomains
                WindowsInformationProtectionDomain          = $getValue.windowsInformationProtectionDomain
                ConnectionName                              = $getValue.connectionName
                CustomXml                                   = $getValue.customXml
                Servers                                     = $complexServers
                Description                                 = $getValue.Description
                DeviceManagementApplicabilityRuleDeviceMode = $complexDeviceManagementApplicabilityRuleDeviceMode
                DeviceManagementApplicabilityRuleOsEdition  = $complexDeviceManagementApplicabilityRuleOsEdition
                DeviceManagementApplicabilityRuleOsVersion  = $complexDeviceManagementApplicabilityRuleOsVersion
                DisplayName                                 = $getValue.DisplayName
                Id                                          = $getValue.Id
                RoleScopeTagIds                             = Resolve-M365DSCIntuneRoleScopeTagNames -CurrentValues $getValue.RoleScopeTagIds -DesiredValues $this.RoleScopeTagIds
                Ensure                                      = 'Present'
                Credential                                  = $this.Credential
                ApplicationId                               = $this.ApplicationId
                TenantId                                    = $this.TenantId
                ApplicationSecret                           = $this.ApplicationSecret
                CertificateThumbprint                       = $this.CertificateThumbprint
                CertificatePath                             = $this.CertificatePath
                CertificatePassword                         = $this.CertificatePassword
                ManagedIdentity                             = $this.ManagedIdentity
                AccessTokens                                = $this.AccessTokens
                #endregion
            }

            $assignmentsValues = Get-M365DSCIntuneExpandedAssignments -Instance $getValue
            if ($null -eq $assignmentsValues)
            {
                $assignmentsValues = Get-MgBetaDeviceManagementDeviceConfigurationAssignment -DeviceConfigurationId $resolvedId
            }
            $assignmentResult = @()
            if ($assignmentsValues.Count -gt 0)
            {
                $assignmentResult += ConvertFrom-IntunePolicyAssignment `
                    -IncludeDeviceFilter:$true `
                    -Assignments ($assignmentsValues)
            }
            $results.Add('Assignments', $assignmentResult)

            return $this.AsResult($results)
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

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $currentInstance = $this.Get().ToHashtable()
        $boundParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()

        if ($boundParameters.ContainsKey('RoleScopeTagIds'))
        {
            $boundParameters.RoleScopeTagIds = Resolve-M365DSCIntuneRoleScopeTagIds -RoleScopeTagIds $this.RoleScopeTagIds
        }

        $keyToRename = @{
            'odataType' = '@odata.type'
        }
        $boundParameters = Rename-M365DSCCimInstanceParameter -Properties $boundParameters -KeyMapping $keyToRename

        if ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Creating an Intune Device Configuration Vpn Policy for Windows10 with DisplayName {$($this.DisplayName)}"
            $createParameters = $boundParameters
            $createParameters.Remove('Assignments') | Out-Null

            $createParameters.Remove('Id') | Out-Null

            #region resource generator code
            $createParameters.Add('@odata.type', '#microsoft.graph.windows10VpnConfiguration')
            $policy = New-MgBetaDeviceManagementDeviceConfiguration -BodyParameter $createParameters
            $assignmentsHash = ConvertTo-IntunePolicyAssignment -IncludeDeviceFilter:$true -Assignments $this.Assignments

            if ($policy.id)
            {
                Update-DeviceConfigurationPolicyAssignment -DeviceConfigurationPolicyId $policy.id `
                    -Targets $assignmentsHash `
                    -Repository 'deviceManagement/deviceConfigurations'
            }
            #endregion
        }
        elseif ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Updating the Intune Device Configuration Vpn Policy for Windows10 with Id {$($currentInstance.Id)}"
            $updateParameters = $boundParameters
            $updateParameters.Remove('Assignments') | Out-Null

            $updateParameters.Remove('Id') | Out-Null

            #region resource generator code
            $updateParameters.Add('@odata.type', '#microsoft.graph.windows10VpnConfiguration')
            Update-MgBetaDeviceManagementDeviceConfiguration `
                -DeviceConfigurationId $currentInstance.Id `
                -BodyParameter $updateParameters
            $assignmentsHash = ConvertTo-IntunePolicyAssignment -IncludeDeviceFilter:$true -Assignments $this.Assignments
            Update-DeviceConfigurationPolicyAssignment `
                -DeviceConfigurationPolicyId $currentInstance.id `
                -Targets $assignmentsHash `
                -Repository 'deviceManagement/deviceConfigurations'
            #endregion
        }
        elseif ($this.Ensure -eq 'Absent' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Removing the Intune Device Configuration Vpn Policy for Windows10 with Id {$($currentInstance.Id)}"
            #region resource generator code
            Remove-MgBetaDeviceManagementDeviceConfiguration -DeviceConfigurationId $currentInstance.Id
            #endregion
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
            #region resource generator code
            [array]$getValue = Get-M365DSCExportCachedCollection -Collection 'deviceConfigurations' `
                -ODataType 'microsoft.graph.windows10VpnConfiguration' `
                -Filter $this.Filter
            #endregion

            $i = 1
            $dscContent = [System.Text.StringBuilder]::new()
            if ($getValue.Length -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }
            foreach ($config in $getValue)
            {
                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }

                $displayedKey = $config.Id
                if (-not [String]::IsNullOrEmpty($config.displayName))
                {
                    $displayedKey = $config.displayName
                }
                Write-M365DSCHost -Message "    |---[$i/$($getValue.Count)] $displayedKey" -DeferWrite
                $params = @{
                    Id                    = $config.Id
                    DisplayName           = $config.DisplayName
                    Ensure                = 'Present'
                    Credential            = $this.Credential
                    ApplicationId         = $this.ApplicationId
                    TenantId              = $this.TenantId
                    ApplicationSecret     = $this.ApplicationSecret
                    CertificateThumbprint = $this.CertificateThumbprint
                    CertificatePath       = $this.CertificatePath
                    CertificatePassword   = $this.CertificatePassword
                    ManagedIdentity       = $this.ManagedIdentity
                    AccessTokens          = $this.AccessTokens
                }

                $this.ExportedInstance = $config
                $Results = $this.GetForExport($Params)
                $rawResults = $Results.Clone()

                if ($null -ne $Results.AssociatedApps)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.AssociatedApps `
                        -CIMInstanceName 'MicrosoftGraphwindows10AssociatedApps'
                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.AssociatedApps = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('AssociatedApps') | Out-Null
                    }
                }
                if ($null -ne $Results.CryptographySuite)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.CryptographySuite `
                        -CIMInstanceName 'MicrosoftGraphcryptographySuite'
                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.CryptographySuite = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('CryptographySuite') | Out-Null
                    }
                }
                if ($null -ne $Results.DnsRules)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.DnsRules `
                        -CIMInstanceName 'MicrosoftGraphvpnDnsRule'
                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.DnsRules = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('DnsRules') | Out-Null
                    }
                }
                if ($null -ne $Results.ProxyServer)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.ProxyServer `
                        -CIMInstanceName 'MicrosoftGraphwindows10VpnProxyServer'
                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.ProxyServer = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('ProxyServer') | Out-Null
                    }
                }
                if ($null -ne $Results.Routes)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.Routes `
                        -CIMInstanceName 'MicrosoftGraphvpnRoute'
                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.Routes = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('Routes') | Out-Null
                    }
                }
                if ($null -ne $Results.SingleSignOnEku)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.SingleSignOnEku `
                        -CIMInstanceName 'MicrosoftGraphextendedKeyUsage'
                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.SingleSignOnEku = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('SingleSignOnEku') | Out-Null
                    }
                }
                if ($null -ne $Results.TrafficRules)
                {
                    $complexMapping = @(
                        @{
                            Name            = 'TrafficRules'
                            CimInstanceName = 'MicrosoftGraphVpnTrafficRule'
                            IsRequired      = $False
                        }
                        @{
                            Name            = 'LocalAddressRanges'
                            CimInstanceName = 'MicrosoftGraphIPv4Range'
                            IsRequired      = $False
                        }
                        @{
                            Name            = 'LocalPortRanges'
                            CimInstanceName = 'MicrosoftGraphNumberRange'
                            IsRequired      = $False
                        }
                        @{
                            Name            = 'RemoteAddressRanges'
                            CimInstanceName = 'MicrosoftGraphIPv4Range'
                            IsRequired      = $False
                        }
                        @{
                            Name            = 'RemotePortRanges'
                            CimInstanceName = 'MicrosoftGraphNumberRange'
                            IsRequired      = $False
                        }
                    )
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.TrafficRules `
                        -CIMInstanceName 'MicrosoftGraphvpnTrafficRule' `
                        -ComplexTypeMapping $complexMapping

                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.TrafficRules = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('TrafficRules') | Out-Null
                    }
                }
                if ($null -ne $Results.Servers)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.Servers `
                        -CIMInstanceName 'MicrosoftGraphvpnServer'
                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.Servers = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('Servers') | Out-Null
                    }
                }
                if ($null -ne $Results.DeviceManagementApplicabilityRuleDeviceMode)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.DeviceManagementApplicabilityRuleDeviceMode `
                        -CIMInstanceName 'DeviceManagementApplicabilityRuleDeviceMode'
                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.DeviceManagementApplicabilityRuleDeviceMode = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('DeviceManagementApplicabilityRuleDeviceMode') | Out-Null
                    }
                }
                if ($null -ne $Results.DeviceManagementApplicabilityRuleOsEdition)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.DeviceManagementApplicabilityRuleOsEdition `
                        -CIMInstanceName 'DeviceManagementApplicabilityRuleOsEdition'
                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.DeviceManagementApplicabilityRuleOsEdition = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('DeviceManagementApplicabilityRuleOsEdition') | Out-Null
                    }
                }
                if ($null -ne $Results.DeviceManagementApplicabilityRuleOsVersion)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.DeviceManagementApplicabilityRuleOsVersion `
                        -CIMInstanceName 'DeviceManagementApplicabilityRuleOsVersion'
                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.DeviceManagementApplicabilityRuleOsVersion = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('DeviceManagementApplicabilityRuleOsVersion') | Out-Null
                    }
                }
                if ($Results.Assignments)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString -ComplexObject $Results.Assignments -CIMInstanceName DeviceManagementConfigurationPolicyAssignments
                    if ($complexTypeStringResult)
                    {
                        $Results.Assignments = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('Assignments') | Out-Null
                    }
                }
                $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                    -ConnectionMode $ConnectionMode `
                    -ModulePath $this.GetModulePath() `
                    -Results $Results `
                    -Credential $this.Credential `
                    -NoEscape @('AssociatedApps', 'CryptographySuite', 'DnsRules', 'ProxyServer', 'Routes',
                    'SingleSignOnEku', 'TrafficRules', 'Servers', 'DeviceManagementApplicabilityRuleDeviceMode',
                    'DeviceManagementApplicabilityRuleOsEdition',
                    'DeviceManagementApplicabilityRuleOsVersion', 'Assignments') `
                    -RawResults $rawResults

                [void]$dscContent.Append($currentDSCBlock)
                Save-M365DSCPartialExport -Content $currentDSCBlock `
                    -FileName $Global:PartialExportFileName
                $i++
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            return $dscContent.ToString()
        }
        catch
        {
            if ($_.Exception -like '*401*' -or $_.ErrorDetails.Message -like "*`"ErrorCode`":`"Forbidden`"*" -or `
                    $_.Exception -like '*Request not applicable to target tenant*')
            {
                Write-M365DSCHost -Message "`r`n    $($Global:M365DSCEmojiYellowCircle) The current tenant is not registered for Intune."
            }
            else
            {
                $this.LogError($_, 'Error during Export:')

                throw
            }
        }

        # Every code path must return in a method with a declared return type.
        return ''
    }

    hidden [IntuneDeviceConfigurationVpnPolicyWindows10] AsResult([System.Object] $Values)
    {
        if ($Values -is [IntuneDeviceConfigurationVpnPolicyWindows10])
        {
            return $Values
        }

        $result = [IntuneDeviceConfigurationVpnPolicyWindows10]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}

class MSFT_MicrosoftGraphwindows10AssociatedApps
{
    [DscProperty()]
    [System.ComponentModel.Description('Application type. Possible values are: desktop, universal.')]
    [ValidateSet('desktop', 'universal')]
    [System.String] $AppType

    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('Identifier.')]
    [System.String] $Identifier
}

class MSFT_MicrosoftGraphcryptographySuite
{
    [DscProperty()]
    [System.ComponentModel.Description('Authentication Transform Constants. Possible values are: md5_96, sha1_96, sha_256_128, aes128Gcm, aes192Gcm, aes256Gcm.')]
    [ValidateSet('md5_96', 'sha1_96', 'sha_256_128', 'aes128Gcm', 'aes192Gcm', 'aes256Gcm')]
    [System.String] $AuthenticationTransformConstants

    [DscProperty()]
    [System.ComponentModel.Description('Cipher Transform Constants. Possible values are: aes256, des, tripleDes, aes128, aes128Gcm, aes256Gcm, aes192, aes192Gcm, chaCha20Poly1305.')]
    [ValidateSet('aes256', 'des', 'tripleDes', 'aes128', 'aes128Gcm', 'aes256Gcm', 'aes192', 'aes192Gcm', 'chaCha20Poly1305')]
    [System.String] $CipherTransformConstants

    [DscProperty()]
    [System.ComponentModel.Description('Diffie Hellman Group. Possible values are: group1, group2, group14, ecp256, ecp384, group24.')]
    [ValidateSet('group1', 'group2', 'group14', 'ecp256', 'ecp384', 'group24')]
    [System.String] $DhGroup

    [DscProperty()]
    [System.ComponentModel.Description('Encryption Method. Possible values are: aes256, des, tripleDes, aes128, aes128Gcm, aes256Gcm, aes192, aes192Gcm, chaCha20Poly1305.')]
    [ValidateSet('aes256', 'des', 'tripleDes', 'aes128', 'aes128Gcm', 'aes256Gcm', 'aes192', 'aes192Gcm', 'chaCha20Poly1305')]
    [System.String] $EncryptionMethod

    [DscProperty()]
    [System.ComponentModel.Description('Integrity Check Method. Possible values are: sha2_256, sha1_96, sha1_160, sha2_384, sha2_512, md5.')]
    [ValidateSet('sha2_256', 'sha1_96', 'sha1_160', 'sha2_384', 'sha2_512', 'md5')]
    [System.String] $IntegrityCheckMethod

    [DscProperty()]
    [System.ComponentModel.Description('Perfect Forward Secrecy Group. Possible values are: pfs1, pfs2, pfs2048, ecp256, ecp384, pfsMM, pfs24.')]
    [ValidateSet('pfs1', 'pfs2', 'pfs2048', 'ecp256', 'ecp384', 'pfsMM', 'pfs24')]
    [System.String] $PfsGroup
}

class MSFT_MicrosoftGraphvpnDnsRule
{
    [DscProperty()]
    [System.ComponentModel.Description('Automatically connect to the VPN when the device connects to this domain: Default False.')]
    [System.Nullable[System.Boolean]] $AutoTrigger

    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('Name.')]
    [System.String] $Name

    [DscProperty()]
    [System.ComponentModel.Description('Keep this rule active even when the VPN is not connected: Default False')]
    [System.Nullable[System.Boolean]] $Persistent

    [DscProperty()]
    [System.ComponentModel.Description('Proxy Server Uri.')]
    [System.String] $ProxyServerUri

    [DscProperty()]
    [System.ComponentModel.Description('Servers.')]
    [System.String[]] $Servers
}

class MSFT_MicrosoftGraphwindows10VpnProxyServer
{
    [DscProperty()]
    [System.ComponentModel.Description('Bypass proxy server for local address.')]
    [System.Nullable[System.Boolean]] $BypassProxyServerForLocalAddress

    [DscProperty()]
    [System.ComponentModel.Description('Address.')]
    [System.String] $Address

    [DscProperty()]
    [System.ComponentModel.Description('Proxy''s automatic configuration script url.')]
    [System.String] $AutomaticConfigurationScriptUrl

    [DscProperty()]
    [System.ComponentModel.Description('Port. Valid values 0 to 65535')]
    [System.Nullable[System.UInt32]] $Port

    [DscProperty()]
    [System.ComponentModel.Description('Automatically detect proxy settings.')]
    [System.Nullable[System.Boolean]] $AutomaticallyDetectProxySettings

    [DscProperty()]
    [System.ComponentModel.Description('The type of the entity.')]
    [ValidateSet('#microsoft.graph.windows10VpnProxyServer', '#microsoft.graph.windows81VpnProxyServer')]
    [System.String] $odataType
}

class MSFT_MicrosoftGraphvpnRoute
{
    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('Destination prefix (IPv4/v6 address).')]
    [System.String] $DestinationPrefix

    [DscProperty()]
    [System.ComponentModel.Description('Prefix size. (1-32). Valid values 1 to 32')]
    [System.Nullable[System.UInt32]] $PrefixSize
}

class MSFT_MicrosoftGraphextendedKeyUsage
{
    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('Extended Key Usage Name')]
    [System.String] $Name

    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('Extended Key Usage Object Identifier')]
    [System.String] $ObjectIdentifier
}

class MSFT_MicrosoftGraphvpnTrafficRule
{
    [DscProperty()]
    [System.ComponentModel.Description('App identifier, if this traffic rule is triggered by an app.')]
    [System.String] $AppId

    [DscProperty()]
    [System.ComponentModel.Description('App type, if this traffic rule is triggered by an app. Possible values are: none, desktop, universal.')]
    [ValidateSet('none', 'desktop', 'universal')]
    [System.String] $AppType

    [DscProperty()]
    [System.ComponentModel.Description('Claims associated with this traffic rule.')]
    [System.String] $Claims

    [DscProperty()]
    [System.ComponentModel.Description('Local address range. This collection can contain a maximum of 500 elements.')]
    [MSFT_MicrosoftGraphIPv4Range[]] $LocalAddressRanges

    [DscProperty()]
    [System.ComponentModel.Description('Local port range can be set only when protocol is either TCP or UDP (6 or 17). This collection can contain a maximum of 500 elements.')]
    [MSFT_MicrosoftGraphNumberRange[]] $LocalPortRanges

    [DscProperty()]
    [System.ComponentModel.Description('Name.')]
    [System.String] $Name

    [DscProperty()]
    [System.ComponentModel.Description('Protocols (0-255). Valid values 0 to 255')]
    [System.Nullable[System.UInt32]] $Protocols

    [DscProperty()]
    [System.ComponentModel.Description('Remote address range. This collection can contain a maximum of 500 elements.')]
    [MSFT_MicrosoftGraphIPv4Range[]] $RemoteAddressRanges

    [DscProperty()]
    [System.ComponentModel.Description('Remote port range can be set only when protocol is either TCP or UDP (6 or 17). This collection can contain a maximum of 500 elements.')]
    [MSFT_MicrosoftGraphNumberRange[]] $RemotePortRanges

    [DscProperty()]
    [System.ComponentModel.Description('When app triggered, indicates whether to enable split tunneling along this route. Possible values are: none, splitTunnel, forceTunnel.')]
    [ValidateSet('none', 'splitTunnel', 'forceTunnel')]
    [System.String] $RoutingPolicyType

    [DscProperty()]
    [System.ComponentModel.Description('Specify whether the rule applies to inbound traffic or outbound traffic. Possible values are: outbound, inbound, unknownFutureValue.')]
    [ValidateSet('outbound', 'inbound', 'unknownFutureValue')]
    [System.String] $VpnTrafficDirection
}

class MSFT_MicrosoftGraphvpnServer
{
    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('Address (IP address, FQDN or URL)')]
    [System.String] $address

    [DscProperty()]
    [System.ComponentModel.Description('Description.')]
    [System.String] $description

    [DscProperty()]
    [System.ComponentModel.Description('Default server.')]
    [System.Nullable[System.Boolean]] $isDefaultServer
}

class MSFT_DeviceManagementApplicabilityRuleDeviceMode
{
    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('Name for object')]
    [System.String] $Name

    [DscProperty()]
    [System.ComponentModel.Description('Applicability rule for device mode')]
    [ValidateSet('standardConfiguration', 'sModeConfiguration')]
    [System.String] $DeviceMode

    [DscProperty()]
    [System.ComponentModel.Description('Applicability Rule type')]
    [ValidateSet('include', 'exclude')]
    [System.String] $RuleType
}

class MSFT_DeviceManagementApplicabilityRuleOsEdition
{
    [DscProperty()]
    [System.ComponentModel.Description('Name for object')]
    [System.String] $Name

    [DscProperty()]
    [System.ComponentModel.Description('Applicability rule OS edition type')]
    [System.String[]] $OsEditionTypes

    [DscProperty()]
    [System.ComponentModel.Description('Applicability Rule type')]
    [ValidateSet('include', 'exclude')]
    [System.String] $RuleType
}

class MSFT_DeviceManagementApplicabilityRuleOsVersion
{
    [DscProperty()]
    [System.ComponentModel.Description('Name for object')]
    [System.String] $Name

    [DscProperty()]
    [System.ComponentModel.Description('Min OS version for Applicability Rule')]
    [System.String] $MinOSVersion

    [DscProperty()]
    [System.ComponentModel.Description('Max OS version for Applicability Rule')]
    [System.String] $MaxOSVersion

    [DscProperty()]
    [System.ComponentModel.Description('Applicability Rule type')]
    [ValidateSet('include', 'exclude')]
    [System.String] $RuleType
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

class MSFT_MicrosoftGraphIPv4Range
{
    [DscProperty()]
    [System.ComponentModel.Description('Lower address.')]
    [System.String] $LowerAddress

    [DscProperty()]
    [System.ComponentModel.Description('Upper address.')]
    [System.String] $UpperAddress

    [DscProperty()]
    [System.ComponentModel.Description('IPv4 address in CIDR notation. Not nullable.')]
    [System.String] $CidrAddress

    [DscProperty()]
    [System.ComponentModel.Description('The type of the entity.')]
    [ValidateSet('#microsoft.graph.iPv4CidrRange', '#microsoft.graph.iPv6CidrRange', '#microsoft.graph.iPv4Range', '#microsoft.graph.iPv6Range')]
    [System.String] $odataType
}

class MSFT_MicrosoftGraphNumberRange
{
    [DscProperty()]
    [System.ComponentModel.Description('Lower number.')]
    [System.Nullable[System.UInt32]] $LowerNumber

    [DscProperty()]
    [System.ComponentModel.Description('Upper number.')]
    [System.Nullable[System.UInt32]] $UpperNumber
}
