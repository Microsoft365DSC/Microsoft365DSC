using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class IntuneFirewallPolicyWindows10 : M365DSCResourceBase
{
    [DscProperty()]
    [System.ComponentModel.Description('Policy description')]
    [System.String] $Description

    [DscProperty(Key)]
    [System.ComponentModel.Description('Policy name')]
    [System.String] $DisplayName

    [DscProperty()]
    [System.ComponentModel.Description('List of Scope Tags for this Entity instance.')]
    [System.String[]] $RoleScopeTagIds

    [DscProperty()]
    [System.ComponentModel.Description('The unique identifier for an entity. Read-only.')]
    [System.String] $Id

    [DscProperty()]
    [System.ComponentModel.Description('Certificate revocation list verification (0: Disables CRL checking, 1: Specifies that CRL checking is attempted and that certificate validation fails only if the certificate is revoked. Other failures that are encountered during CRL checking (such as the revocation URL being unreachable) do not cause certificate validation to fail., 2: Means that checking is required and that certificate validation fails if any error is encountered during CRL processing)')]
    [ValidateSet('0', '1', '2')]
    [System.String] $CRLcheck

    [DscProperty()]
    [System.ComponentModel.Description('Disable Stateful Ftp (false: Stateful FTP enabled, true: Stateful FTP disabled)')]
    [ValidateSet('false', 'true')]
    [System.String] $DisableStatefulFtp

    [DscProperty()]
    [System.ComponentModel.Description('Enable Packet Queue (0: Indicates that all queuing is to be disabled, 1: Specifies that inbound encrypted packets are to be queued, 2: Specifies that packets are to be queued after decryption is performed for forwarding)')]
    [ValidateSet('0', '1', '2')]
    [System.Int32[]] $EnablePacketQueue

    [DscProperty()]
    [System.ComponentModel.Description('IPsec Exceptions (0: FW_GLOBAL_CONFIG_IPSEC_EXEMPT_NONE:  No IPsec exemptions., 1: FW_GLOBAL_CONFIG_IPSEC_EXEMPT_NEIGHBOR_DISC:  Exempt neighbor discover IPv6 ICMP type-codes from IPsec., 2: FW_GLOBAL_CONFIG_IPSEC_EXEMPT_ICMP:  Exempt ICMP from IPsec., 4: FW_GLOBAL_CONFIG_IPSEC_EXEMPT_ROUTER_DISC:  Exempt router discover IPv6 ICMP type-codes from IPsec., 8: FW_GLOBAL_CONFIG_IPSEC_EXEMPT_DHCP:  Exempt both IPv4 and IPv6 DHCP traffic from IPsec.)')]
    [ValidateSet('0', '1', '2', '4', '8')]
    [System.Int32[]] $IPsecExempt

    [DscProperty()]
    [System.ComponentModel.Description('Opportunistically Match Auth Set Per KM (false: FALSE, true: TRUE)')]
    [ValidateSet('false', 'true')]
    [System.String] $OpportunisticallyMatchAuthSetPerKM

    [DscProperty()]
    [System.ComponentModel.Description('Preshared Key Encoding (0: FW_GLOBAL_CONFIG_PRESHARED_KEY_ENCODING_NONE:  Preshared key is not encoded. Instead, it is kept in its wide-character format. This symbolic constant has a value of 0., 1: FW_GLOBAL_CONFIG_PRESHARED_KEY_ENCODING_UTF_8:  Encode the preshared key using UTF-8. This symbolic constant has a value of 1.)')]
    [ValidateSet('0', '1')]
    [System.String] $PresharedKeyEncoding

    [DscProperty()]
    [System.ComponentModel.Description('Security association idle time')]
    [ValidateRange(300, 3600)]
    [System.Nullable[System.Int32]] $SaIdleTime

    [DscProperty()]
    [System.ComponentModel.Description('Enable Domain Network Firewall (false: Disable Firewall, true: Enable Firewall)')]
    [ValidateSet('false', 'true')]
    [System.String] $DomainProfile_EnableFirewall

    [DscProperty()]
    [System.ComponentModel.Description('Disable Unicast Responses To Multicast Broadcast (false: Unicast Responses Not Blocked, true: Unicast Responses Blocked)')]
    [ValidateSet('false', 'true')]
    [System.String] $DomainProfile_DisableUnicastResponsesToMulticastBroadcast

    [DscProperty()]
    [System.ComponentModel.Description('Enable Log Ignored Rules (false: Disable Logging Of Ignored Rules, true: Enable Logging Of Ignored Rules)')]
    [ValidateSet('false', 'true')]
    [System.String] $DomainProfile_EnableLogIgnoredRules

    [DscProperty()]
    [System.ComponentModel.Description('Global Ports Allow User Pref Merge (false: GlobalPortsAllowUserPrefMerge Off, true: GlobalPortsAllowUserPrefMerge On)')]
    [ValidateSet('false', 'true')]
    [System.String] $DomainProfile_GlobalPortsAllowUserPrefMerge

    [DscProperty()]
    [System.ComponentModel.Description('Default Inbound Action for Domain Profile (0: Allow Inbound By Default, 1: Block Inbound By Default)')]
    [ValidateSet('0', '1')]
    [System.String] $DomainProfile_DefaultInboundAction

    [DscProperty()]
    [System.ComponentModel.Description('Disable Stealth Mode Ipsec Secured Packet Exemption (false: FALSE, true: TRUE)')]
    [ValidateSet('false', 'true')]
    [System.String] $DomainProfile_DisableStealthModeIpsecSecuredPacketExemption

    [DscProperty()]
    [System.ComponentModel.Description('Allow Local Policy Merge (false: AllowLocalPolicyMerge Off, true: AllowLocalPolicyMerge On)')]
    [ValidateSet('false', 'true')]
    [System.String] $DomainProfile_AllowLocalPolicyMerge

    [DscProperty()]
    [System.ComponentModel.Description('Enable Log Success Connections (false: Disable Logging Of Successful Connections, true: Enable Logging Of Successful Connections)')]
    [ValidateSet('false', 'true')]
    [System.String] $DomainProfile_EnableLogSuccessConnections

    [DscProperty()]
    [System.ComponentModel.Description('Allow Local Ipsec Policy Merge (false: AllowLocalIpsecPolicyMerge Off, true: AllowLocalIpsecPolicyMerge On)')]
    [ValidateSet('false', 'true')]
    [System.String] $DomainProfile_AllowLocalIpsecPolicyMerge

    [DscProperty()]
    [System.ComponentModel.Description('Log File Path')]
    [ValidateLength(0, 87516)]
    [System.String] $DomainProfile_LogFilePath

    [DscProperty()]
    [System.ComponentModel.Description('Disable Stealth Mode (false: Use Stealth Mode, true: Disable Stealth Mode)')]
    [ValidateSet('false', 'true')]
    [System.String] $DomainProfile_DisableStealthMode

    [DscProperty()]
    [System.ComponentModel.Description('Auth Apps Allow User Pref Merge (false: AuthAppsAllowUserPrefMerge Off, true: AuthAppsAllowUserPrefMerge On)')]
    [ValidateSet('false', 'true')]
    [System.String] $DomainProfile_AuthAppsAllowUserPrefMerge

    [DscProperty()]
    [System.ComponentModel.Description('Enable Log Dropped Packets (false: Disable Logging Of Dropped Packets, true: Enable Logging Of Dropped Packets)')]
    [ValidateSet('false', 'true')]
    [System.String] $DomainProfile_EnableLogDroppedPackets

    [DscProperty()]
    [System.ComponentModel.Description('Shielded (false: Shielding Off, true: Shielding On)')]
    [ValidateSet('false', 'true')]
    [System.String] $DomainProfile_Shielded

    [DscProperty()]
    [System.ComponentModel.Description('Default Outbound Action (0: Allow Outbound By Default, 1: Block Outbound By Default)')]
    [ValidateSet('0', '1')]
    [System.String] $DomainProfile_DefaultOutboundAction

    [DscProperty()]
    [System.ComponentModel.Description('Disable Inbound Notifications (false: Firewall May Display Notification, true: Firewall Must Not Display Notification)')]
    [ValidateSet('false', 'true')]
    [System.String] $DomainProfile_DisableInboundNotifications

    [DscProperty()]
    [System.ComponentModel.Description('Log Max File Size')]
    [ValidateRange(0, 4294967295)]
    [System.Nullable[System.Int32]] $DomainProfile_LogMaxFileSize

    [DscProperty()]
    [System.ComponentModel.Description('Enable Private Network Firewall (false: Disable Firewall, true: Enable Firewall)')]
    [ValidateSet('false', 'true')]
    [System.String] $PrivateProfile_EnableFirewall

    [DscProperty()]
    [System.ComponentModel.Description('Allow Local Ipsec Policy Merge (false: AllowLocalIpsecPolicyMerge Off, true: AllowLocalIpsecPolicyMerge On)')]
    [ValidateSet('false', 'true')]
    [System.String] $PrivateProfile_AllowLocalIpsecPolicyMerge

    [DscProperty()]
    [System.ComponentModel.Description('Disable Stealth Mode Ipsec Secured Packet Exemption (false: FALSE, true: TRUE)')]
    [ValidateSet('false', 'true')]
    [System.String] $PrivateProfile_DisableStealthModeIpsecSecuredPacketExemption

    [DscProperty()]
    [System.ComponentModel.Description('Disable Inbound Notifications (false: Firewall May Display Notification, true: Firewall Must Not Display Notification)')]
    [ValidateSet('false', 'true')]
    [System.String] $PrivateProfile_DisableInboundNotifications

    [DscProperty()]
    [System.ComponentModel.Description('Shielded (false: Shielding Off, true: Shielding On)')]
    [ValidateSet('false', 'true')]
    [System.String] $PrivateProfile_Shielded

    [DscProperty()]
    [System.ComponentModel.Description('Allow Local Policy Merge (false: AllowLocalPolicyMerge Off, true: AllowLocalPolicyMerge On)')]
    [ValidateSet('false', 'true')]
    [System.String] $PrivateProfile_AllowLocalPolicyMerge

    [DscProperty()]
    [System.ComponentModel.Description('Default Outbound Action (0: Allow Outbound By Default, 1: Block Outbound By Default)')]
    [ValidateSet('0', '1')]
    [System.String] $PrivateProfile_DefaultOutboundAction

    [DscProperty()]
    [System.ComponentModel.Description('Auth Apps Allow User Pref Merge (false: AuthAppsAllowUserPrefMerge Off, true: AuthAppsAllowUserPrefMerge On)')]
    [ValidateSet('false', 'true')]
    [System.String] $PrivateProfile_AuthAppsAllowUserPrefMerge

    [DscProperty()]
    [System.ComponentModel.Description('Enable Log Ignored Rules (false: Disable Logging Of Ignored Rules, true: Enable Logging Of Ignored Rules)')]
    [ValidateSet('false', 'true')]
    [System.String] $PrivateProfile_EnableLogIgnoredRules

    [DscProperty()]
    [System.ComponentModel.Description('Log Max File Size')]
    [ValidateRange(0, 4294967295)]
    [System.Nullable[System.Int32]] $PrivateProfile_LogMaxFileSize

    [DscProperty()]
    [System.ComponentModel.Description('Default Inbound Action for Private Profile (0: Allow Inbound By Default, 1: Block Inbound By Default)')]
    [ValidateSet('0', '1')]
    [System.String] $PrivateProfile_DefaultInboundAction

    [DscProperty()]
    [System.ComponentModel.Description('Disable Unicast Responses To Multicast Broadcast (false: Unicast Responses Not Blocked, true: Unicast Responses Blocked)')]
    [ValidateSet('false', 'true')]
    [System.String] $PrivateProfile_DisableUnicastResponsesToMulticastBroadcast

    [DscProperty()]
    [System.ComponentModel.Description('Log File Path')]
    [ValidateLength(0, 87516)]
    [System.String] $PrivateProfile_LogFilePath

    [DscProperty()]
    [System.ComponentModel.Description('Disable Stealth Mode (false: Use Stealth Mode, true: Disable Stealth Mode)')]
    [ValidateSet('false', 'true')]
    [System.String] $PrivateProfile_DisableStealthMode

    [DscProperty()]
    [System.ComponentModel.Description('Enable Log Success Connections (false: Disable Logging Of Successful Connections, true: Enable Logging Of Successful Connections)')]
    [ValidateSet('false', 'true')]
    [System.String] $PrivateProfile_EnableLogSuccessConnections

    [DscProperty()]
    [System.ComponentModel.Description('Global Ports Allow User Pref Merge (false: GlobalPortsAllowUserPrefMerge Off, true: GlobalPortsAllowUserPrefMerge On)')]
    [ValidateSet('false', 'true')]
    [System.String] $PrivateProfile_GlobalPortsAllowUserPrefMerge

    [DscProperty()]
    [System.ComponentModel.Description('Enable Log Dropped Packets (false: Disable Logging Of Dropped Packets, true: Enable Logging Of Dropped Packets)')]
    [ValidateSet('false', 'true')]
    [System.String] $PrivateProfile_EnableLogDroppedPackets

    [DscProperty()]
    [System.ComponentModel.Description('Enable Public Network Firewall (false: Disable Firewall, true: Enable Firewall)')]
    [ValidateSet('false', 'true')]
    [System.String] $PublicProfile_EnableFirewall

    [DscProperty()]
    [System.ComponentModel.Description('Default Outbound Action (0: Allow Outbound By Default, 1: Block Outbound By Default)')]
    [ValidateSet('0', '1')]
    [System.String] $PublicProfile_DefaultOutboundAction

    [DscProperty()]
    [System.ComponentModel.Description('Disable Inbound Notifications (false: Firewall May Display Notification, true: Firewall Must Not Display Notification)')]
    [ValidateSet('false', 'true')]
    [System.String] $PublicProfile_DisableInboundNotifications

    [DscProperty()]
    [System.ComponentModel.Description('Disable Stealth Mode Ipsec Secured Packet Exemption (false: FALSE, true: TRUE)')]
    [ValidateSet('false', 'true')]
    [System.String] $PublicProfile_DisableStealthModeIpsecSecuredPacketExemption

    [DscProperty()]
    [System.ComponentModel.Description('Shielded (false: Shielding Off, true: Shielding On)')]
    [ValidateSet('false', 'true')]
    [System.String] $PublicProfile_Shielded

    [DscProperty()]
    [System.ComponentModel.Description('Allow Local Policy Merge (false: AllowLocalPolicyMerge Off, true: AllowLocalPolicyMerge On)')]
    [ValidateSet('false', 'true')]
    [System.String] $PublicProfile_AllowLocalPolicyMerge

    [DscProperty()]
    [System.ComponentModel.Description('Auth Apps Allow User Pref Merge (false: AuthAppsAllowUserPrefMerge Off, true: AuthAppsAllowUserPrefMerge On)')]
    [ValidateSet('false', 'true')]
    [System.String] $PublicProfile_AuthAppsAllowUserPrefMerge

    [DscProperty()]
    [System.ComponentModel.Description('Log File Path')]
    [ValidateLength(0, 87516)]
    [System.String] $PublicProfile_LogFilePath

    [DscProperty()]
    [System.ComponentModel.Description('Default Inbound Action for Public Profile (0: Allow Inbound By Default, 1: Block Inbound By Default)')]
    [ValidateSet('0', '1')]
    [System.String] $PublicProfile_DefaultInboundAction

    [DscProperty()]
    [System.ComponentModel.Description('Disable Unicast Responses To Multicast Broadcast (false: Unicast Responses Not Blocked, true: Unicast Responses Blocked)')]
    [ValidateSet('false', 'true')]
    [System.String] $PublicProfile_DisableUnicastResponsesToMulticastBroadcast

    [DscProperty()]
    [System.ComponentModel.Description('Global Ports Allow User Pref Merge (false: GlobalPortsAllowUserPrefMerge Off, true: GlobalPortsAllowUserPrefMerge On)')]
    [ValidateSet('false', 'true')]
    [System.String] $PublicProfile_GlobalPortsAllowUserPrefMerge

    [DscProperty()]
    [System.ComponentModel.Description('Enable Log Success Connections (false: Disable Logging Of Successful Connections, true: Enable Logging Of Successful Connections)')]
    [ValidateSet('false', 'true')]
    [System.String] $PublicProfile_EnableLogSuccessConnections

    [DscProperty()]
    [System.ComponentModel.Description('Allow Local Ipsec Policy Merge (false: AllowLocalIpsecPolicyMerge Off, true: AllowLocalIpsecPolicyMerge On)')]
    [ValidateSet('false', 'true')]
    [System.String] $PublicProfile_AllowLocalIpsecPolicyMerge

    [DscProperty()]
    [System.ComponentModel.Description('Enable Log Dropped Packets (false: Disable Logging Of Dropped Packets, true: Enable Logging Of Dropped Packets)')]
    [ValidateSet('false', 'true')]
    [System.String] $PublicProfile_EnableLogDroppedPackets

    [DscProperty()]
    [System.ComponentModel.Description('Enable Log Ignored Rules (false: Disable Logging Of Ignored Rules, true: Enable Logging Of Ignored Rules)')]
    [ValidateSet('false', 'true')]
    [System.String] $PublicProfile_EnableLogIgnoredRules

    [DscProperty()]
    [System.ComponentModel.Description('Log Max File Size')]
    [ValidateRange(0, 4294967295)]
    [System.Nullable[System.Int32]] $PublicProfile_LogMaxFileSize

    [DscProperty()]
    [System.ComponentModel.Description('Disable Stealth Mode (false: Use Stealth Mode, true: Disable Stealth Mode)')]
    [ValidateSet('false', 'true')]
    [System.String] $PublicProfile_DisableStealthMode

    [DscProperty()]
    [System.ComponentModel.Description('Object Access Audit Filtering Platform Connection (0: Off/None, 1: Success, 2: Failure, 3: Success+Failure)')]
    [ValidateSet('0', '1', '2', '3')]
    [System.String] $ObjectAccess_AuditFilteringPlatformConnection

    [DscProperty()]
    [System.ComponentModel.Description('Object Access Audit Filtering Platform Packet Drop (0: Off/None, 1: Success, 2: Failure, 3: Success+Failure)')]
    [ValidateSet('0', '1', '2', '3')]
    [System.String] $ObjectAccess_AuditFilteringPlatformPacketDrop

    [DscProperty()]
    [System.ComponentModel.Description('Allowed Tls Authentication Endpoints')]
    [ValidateLength(0, 87516)]
    [System.String[]] $AllowedTlsAuthenticationEndpoints

    [DscProperty()]
    [System.ComponentModel.Description('Configured Tls Authentication Network Name')]
    [ValidateLength(0, 87516)]
    [System.String] $ConfiguredTlsAuthenticationNetworkName

    [DscProperty()]
    [System.ComponentModel.Description('Hyper-V: Target (wsl: WSL)')]
    [ValidateSet('wsl')]
    [System.String] $Target

    [DscProperty()]
    [System.ComponentModel.Description('Hyper-V: Enable Domain Network Firewall (false: Disable Firewall, true: Enable Firewall)')]
    [ValidateSet('false', 'true')]
    [System.String] $HyperVVMSettings_DomainProfile_EnableFirewall

    [DscProperty()]
    [System.ComponentModel.Description('Hyper-V: Allow Local Policy Merge (false: AllowLocalPolicyMerge Off, true: AllowLocalPolicyMerge On)')]
    [ValidateSet('false', 'true')]
    [System.String] $HyperVVMSettings_DomainProfile_AllowLocalPolicyMerge

    [DscProperty()]
    [System.ComponentModel.Description('Hyper-V: Default Inbound Action (0: Allow Inbound By Default, 1: Block Inbound By Default)')]
    [ValidateSet('0', '1')]
    [System.String] $HyperVVMSettings_DomainProfile_DefaultInboundAction

    [DscProperty()]
    [System.ComponentModel.Description('Hyper-V: Default Outbound Action (0: Allow Outbound By Default, 1: Block Outbound By Default)')]
    [ValidateSet('0', '1')]
    [System.String] $HyperVVMSettings_DomainProfile_DefaultOutboundAction

    [DscProperty()]
    [System.ComponentModel.Description('Hyper-V: Enable Loopback (false: Disable loopback, true: Enable loopback)')]
    [ValidateSet('false', 'true')]
    [System.String] $EnableLoopback

    [DscProperty()]
    [System.ComponentModel.Description('Hyper-V: Enable Public Network Firewall (false: Disable Hyper-V Firewall, true: Enable Hyper-V Firewall)')]
    [ValidateSet('false', 'true')]
    [System.String] $HyperVVMSettings_PublicProfile_EnableFirewall

    [DscProperty()]
    [System.ComponentModel.Description('Hyper-V: Default Inbound Action (0: Allow Inbound By Default, 1: Block Inbound By Default)')]
    [ValidateSet('0', '1')]
    [System.String] $HyperVVMSettings_PublicProfile_DefaultInboundAction

    [DscProperty()]
    [System.ComponentModel.Description('Hyper-V: Default Outbound Action (0: Allow Outbound By Default, 1: Block Outbound By Default)')]
    [ValidateSet('0', '1')]
    [System.String] $HyperVVMSettings_PublicProfile_DefaultOutboundAction

    [DscProperty()]
    [System.ComponentModel.Description('Hyper-V: Allow Local Policy Merge (false: AllowLocalPolicyMerge Off, true: AllowLocalPolicyMerge On)')]
    [ValidateSet('false', 'true')]
    [System.String] $HyperVVMSettings_PublicProfile_AllowLocalPolicyMerge

    [DscProperty()]
    [System.ComponentModel.Description('Hyper-V: Enable Private Network Firewall (false: Disable Firewall, true: Enable Firewall)')]
    [ValidateSet('false', 'true')]
    [System.String] $HyperVVMSettings_PrivateProfile_EnableFirewall

    [DscProperty()]
    [System.ComponentModel.Description('Hyper-V: Default Outbound Action (0: Allow Outbound By Default, 1: Block Outbound By Default)')]
    [ValidateSet('0', '1')]
    [System.String] $HyperVVMSettings_PrivateProfile_DefaultOutboundAction

    [DscProperty()]
    [System.ComponentModel.Description('Hyper-V: Default Inbound Action (0: Allow Inbound By Default, 1: Block Inbound By Default)')]
    [ValidateSet('0', '1')]
    [System.String] $HyperVVMSettings_PrivateProfile_DefaultInboundAction

    [DscProperty()]
    [System.ComponentModel.Description('Hyper-V: Allow Local Policy Merge (false: AllowLocalPolicyMerge Off, true: AllowLocalPolicyMerge On)')]
    [ValidateSet('false', 'true')]
    [System.String] $HyperVVMSettings_PrivateProfile_AllowLocalPolicyMerge

    [DscProperty()]
    [System.ComponentModel.Description('Hyper-V: Allow Host Policy Merge (false: AllowHostPolicyMerge Off, true: AllowHostPolicyMerge On)')]
    [ValidateSet('false', 'true')]
    [System.String] $AllowHostPolicyMerge

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

    [IntuneFirewallPolicyWindows10] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [IntuneFirewallPolicyWindows10]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of the Intune Firewall Policy for Windows10 with Id {$($this.Id)} and Name {$($this.DisplayName)}."

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.Name -ne $this.DisplayName)
            {
                $null = $this.Connect('MicrosoftGraph')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullResult = $this.GetBoundParameters()
                $nullResult.Ensure = 'Absent'

                $getValue = $null
                #region resource generator code
                if (-not [System.String]::IsNullOrEmpty($this.Id))
                {
                    $getValue = Get-MgBetaDeviceManagementConfigurationPolicy -DeviceManagementConfigurationPolicyId $this.Id -ErrorAction SilentlyContinue `
                        -ExpandProperty 'settings($expand=settingDefinitions)'
                    $settings = $getValue.settings
                }

                if ($null -eq $getValue)
                {
                    Write-Verbose -Message "Could not find an Intune Firewall Policy for Windows10 with Id {$($this.Id)}"

                    if (-not [System.String]::IsNullOrEmpty($this.DisplayName))
                    {
                        $getValue = Get-MgBetaDeviceManagementConfigurationPolicy `
                            -All `
                            -Filter "Name eq '$($this.DisplayName -replace "'", "''")'" `
                            -ErrorAction SilentlyContinue

                        if ($getValue.Length -gt 1)
                        {
                            throw "Duplicate Intune Firewall Policy for Windows10 named $($this.DisplayName) exist in tenant"
                        }
                    }
                }
                #endregion
                if ($null -eq $getValue)
                {
                    Write-Verbose -Message "Could not find an Intune Firewall Policy for Windows10 with Name {$($this.DisplayName)}."
                    return $this.AsResult($nullResult)
                }
            }
            else
            {
                $getValue = $this.ExportedInstance
                $settings = $getValue.settings
            }
            $resolvedId = $getValue.Id
            Write-Verbose -Message "An Intune Firewall Policy for Windows10 with Id {$($resolvedId)} and Name {$($this.DisplayName)} was found"

            # Retrieve policy specific settings
            if ($null -eq $settings)
            {
                [array]$settings = Get-MgBetaDeviceManagementConfigurationPolicySetting `
                    -All `
                    -DeviceManagementConfigurationPolicyId $resolvedId `
                    -ExpandProperty 'settingDefinitions' `
                    -ErrorAction Stop
            }
            $settingTemplates = Get-M365DSCCachedSettingCatalogTemplate -TemplateId $getValue.TemplateReference.TemplateId
            if ($null -eq $settingTemplates)
            {
                $settingTemplates = [System.Object[]] @(Get-MgBetaDeviceManagementConfigurationPolicyTemplateSettingTemplate `
                        -DeviceManagementConfigurationPolicyTemplateId $getValue.TemplateReference.TemplateId `
                        -ExpandProperty 'settingDefinitions' `
                        -All `
                        -ErrorAction Stop)
                Set-M365DSCCachedSettingCatalogTemplate -TemplateId $getValue.TemplateReference.TemplateId -Templates $settingTemplates
            }
            [array]$settingDefinitions = $settingTemplates.SettingDefinitions

            $policySettings = @{}
            $policySettings = Export-IntuneSettingCatalogPolicySettings -Settings $settings -ReturnHashtable $policySettings -AllSettingDefinitions $settingDefinitions

            $results = @{
                #region resource generator code
                Description           = $getValue.Description
                DisplayName           = $getValue.Name
                RoleScopeTagIds       = Resolve-M365DSCIntuneRoleScopeTagNames -CurrentValues $getValue.RoleScopeTagIds -DesiredValues $this.RoleScopeTagIds
                Id                    = $getValue.Id
                Ensure                = 'Present'
                Credential            = $this.Credential
                ApplicationId         = $this.ApplicationId
                TenantId              = $this.TenantId
                ApplicationSecret     = $this.ApplicationSecret
                CertificateThumbprint = $this.CertificateThumbprint
                CertificatePath       = $this.CertificatePath
                CertificatePassword   = $this.CertificatePassword
                ManagedIdentity       = $this.ManagedIdentity
                #endregion
            }
            $results += $policySettings

            $assignmentsValues = Get-M365DSCIntuneExpandedAssignments -Instance $getValue
            if ($null -eq $assignmentsValues)
            {
                $assignmentsValues = Get-MgBetaDeviceManagementConfigurationPolicyAssignment -DeviceManagementConfigurationPolicyId $resolvedId
            }
            $assignmentResult = @()
            if ($assignmentsValues.Count -gt 0)
            {
                $assignmentResult += ConvertFrom-IntunePolicyAssignment -Assignments $assignmentsValues -IncludeDeviceFilter $true
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

        $resolvedRoleScopeTagIds = $this.RoleScopeTagIds
        if ($boundParameters.ContainsKey('RoleScopeTagIds'))
        {
            $resolvedRoleScopeTagIds = Resolve-M365DSCIntuneRoleScopeTagIds -RoleScopeTagIds $this.RoleScopeTagIds
        }

        $templateReferenceId = '6078910e-d808-4a9f-a51d-1b8a7bacb7c0_1'
        $platforms = 'windows10'
        $technologies = 'mdm,microsoftSense'

        if ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Creating an Intune Firewall Policy for Windows10 with Name {$($this.DisplayName)}"
            $boundParameters.Remove('Assignments') | Out-Null

            $settings = Get-IntuneSettingCatalogPolicySetting `
                -DSCParams ([System.Collections.Hashtable]$boundParameters) `
                -TemplateId $templateReferenceId

            $createParameters = @{
                name              = $this.DisplayName
                description       = $this.Description
                templateReference = @{ templateId = $templateReferenceId }
                platforms         = $platforms
                technologies      = $technologies
                settings          = $settings
                roleScopeTagIds   = $resolvedRoleScopeTagIds
            }

            #region resource generator code
            $policy = New-MgBetaDeviceManagementConfigurationPolicy -BodyParameter $createParameters

            if ($policy.Id)
            {
                $assignmentsHash = ConvertTo-IntunePolicyAssignment -IncludeDeviceFilter:$true -Assignments $this.Assignments
                Update-DeviceConfigurationPolicyAssignment `
                    -DeviceConfigurationPolicyId $policy.Id `
                    -Targets $assignmentsHash `
                    -Repository 'deviceManagement/configurationPolicies'
            }
            #endregion
        }
        elseif ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Updating the Intune Firewall Policy for Windows10 with Id {$($currentInstance.Id)}"
            $boundParameters.Remove('Assignments') | Out-Null

            $settings = Get-IntuneSettingCatalogPolicySetting `
                -DSCParams ([System.Collections.Hashtable]$boundParameters) `
                -TemplateId $templateReferenceId

            Update-IntuneDeviceConfigurationPolicy `
                -DeviceConfigurationPolicyId $currentInstance.Id `
                -Name $this.DisplayName `
                -Description $this.Description `
                -TemplateReferenceId $templateReferenceId `
                -Platforms $platforms `
                -Technologies $technologies `
                -Settings $settings `
                -RoleScopeTagIds $resolvedRoleScopeTagIds

            #region resource generator code
            $assignmentsHash = ConvertTo-IntunePolicyAssignment -IncludeDeviceFilter:$true -Assignments $this.Assignments
            Update-DeviceConfigurationPolicyAssignment `
                -DeviceConfigurationPolicyId $currentInstance.Id `
                -Targets $assignmentsHash `
                -Repository 'deviceManagement/configurationPolicies'
            #endregion
        }
        elseif ($this.Ensure -eq 'Absent' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Removing the Intune Firewall Policy for Windows10 with Id {$($currentInstance.Id)}"
            #region resource generator code
            Remove-MgBetaDeviceManagementConfigurationPolicy -DeviceManagementConfigurationPolicyId $currentInstance.Id
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
            $policyTemplateID = '6078910e-d808-4a9f-a51d-1b8a7bacb7c0_1'
            $baseFilter = "templateReference/templateId eq '$policyTemplateID'"
            $mergedFilter = $baseFilter
            if (-not [System.String]::IsNullOrEmpty($this.Filter))
            {
                $mergedFilter = "($($this.Filter)) and ($baseFilter)"
            }
            [array]$getValue = Get-M365DSCExportCachedConfigurationPolicies `
                -TemplateId $policyTemplateID `
                -Filter $mergedFilter
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
                $displayedKey = $config.Id
                if (-not [String]::IsNullOrEmpty($config.displayName))
                {
                    $displayedKey = $config.displayName
                }
                elseif (-not [string]::IsNullOrEmpty($config.name))
                {
                    $displayedKey = $config.name
                }
                Write-M365DSCHost -Message "    |---[$i/$($getValue.Count)] $displayedKey" -DeferWrite
                $params = @{
                    Id                    = $config.Id
                    DisplayName           = $config.Name
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
                    -NoEscape @('Assignments') `
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
            $this.LogError($_, 'Error during Export:')

            throw
        }
    }

    [System.Collections.Hashtable] GetCompareParameters()
    {
        return $this.GetSettingsCatalogCompareParameters()
    }

    hidden [IntuneFirewallPolicyWindows10] AsResult([System.Object] $Values)
    {
        if ($Values -is [IntuneFirewallPolicyWindows10])
        {
            return $Values
        }

        $result = [IntuneFirewallPolicyWindows10]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
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
