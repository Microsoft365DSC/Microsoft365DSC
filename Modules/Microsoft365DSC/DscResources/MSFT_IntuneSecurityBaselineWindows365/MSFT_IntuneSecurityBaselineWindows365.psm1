using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class IntuneSecurityBaselineWindows365 : M365DSCResourceBase
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
    [System.ComponentModel.Description('The device scope settings for the policy.')]
    [MSFT_MicrosoftGraphIntuneSettingsCatalogDeviceSettings_IntuneSecurityBaselineWindows365] $DeviceSettings

    [DscProperty()]
    [System.ComponentModel.Description('The user scope settings for the policy.')]
    [MSFT_MicrosoftGraphIntuneSettingsCatalogUserSettings_IntuneSecurityBaselineWindows365] $UserSettings

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

    [IntuneSecurityBaselineWindows365] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [IntuneSecurityBaselineWindows365]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of the Intune Security Baseline Windows365 with Id {$($this.Id)} and Name {$($this.DisplayName)}"

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
                    Write-Verbose -Message "Could not find an Intune Security Baseline Windows365 with Id {$($this.Id)}"

                    if (-not [System.String]::IsNullOrEmpty($this.DisplayName))
                    {
                        $getValue = Get-MgBetaDeviceManagementConfigurationPolicy `
                            -All `
                            -Filter "Name eq '$($this.DisplayName -replace "'", "''")'" `
                            -ErrorAction SilentlyContinue
                    }
                }
                #endregion
                if ($null -eq $getValue)
                {
                    Write-Verbose -Message "Could not find an Intune Security Baseline Windows365 with Name {$($this.DisplayName)}."
                    return $this.AsResult($nullResult)
                }
            }
            else
            {
                $getValue = $this.ExportedInstance
                $settings = $getValue.settings
            }
            $resolvedId = $getValue.Id
            Write-Verbose -Message "An Intune Security Baseline Windows365 with Id {$($resolvedId)} and Name {$($this.DisplayName)} was found"

            # Retrieve policy specific settings
            if ($null -eq $settings)
            {
                [array]$settings = Get-MgBetaDeviceManagementConfigurationPolicySetting `
                    -DeviceManagementConfigurationPolicyId $resolvedId `
                    -ExpandProperty 'settingDefinitions' `
                    -All `
                    -ErrorAction Stop
            }

            $policySettings = @{}
            $policySettings = Export-IntuneSettingCatalogPolicySettings -Settings $settings -ReturnHashtable $policySettings -ContainsDeviceAndUserSettings

            #region resource generator code
            $complexDeviceSettings = [ordered]@{}
            if ($null -ne $policySettings.DeviceSettings.cPL_Personalization_NoLockScreenCamera)
            {
                $complexDeviceSettings.Add('CPL_Personalization_NoLockScreenCamera', $policySettings.DeviceSettings.cPL_Personalization_NoLockScreenCamera)
            }
            if ($null -ne $policySettings.DeviceSettings.cPL_Personalization_NoLockScreenSlideshow)
            {
                $complexDeviceSettings.Add('CPL_Personalization_NoLockScreenSlideshow', $policySettings.DeviceSettings.cPL_Personalization_NoLockScreenSlideshow)
            }
            if ($null -ne $policySettings.DeviceSettings.pol_SecGuide_0201_LATFP)
            {
                $complexDeviceSettings.Add('Pol_SecGuide_0201_LATFP', $policySettings.DeviceSettings.pol_SecGuide_0201_LATFP)
            }
            if ($null -ne $policySettings.DeviceSettings.pol_SecGuide_0002_SMBv1_ClientDriver)
            {
                $complexDeviceSettings.Add('Pol_SecGuide_0002_SMBv1_ClientDriver', $policySettings.DeviceSettings.pol_SecGuide_0002_SMBv1_ClientDriver)
            }
            if ($null -ne $policySettings.DeviceSettings.pol_SecGuide_SMB1ClientDriver)
            {
                $complexDeviceSettings.Add('Pol_SecGuide_SMB1ClientDriver', $policySettings.DeviceSettings.pol_SecGuide_SMB1ClientDriver)
            }
            if ($null -ne $policySettings.DeviceSettings.pol_SecGuide_0001_SMBv1_Server)
            {
                $complexDeviceSettings.Add('Pol_SecGuide_0001_SMBv1_Server', $policySettings.DeviceSettings.pol_SecGuide_0001_SMBv1_Server)
            }
            if ($null -ne $policySettings.DeviceSettings.pol_SecGuide_0102_SEHOP)
            {
                $complexDeviceSettings.Add('Pol_SecGuide_0102_SEHOP', $policySettings.DeviceSettings.pol_SecGuide_0102_SEHOP)
            }
            if ($null -ne $policySettings.DeviceSettings.pol_SecGuide_0202_WDigestAuthn)
            {
                $complexDeviceSettings.Add('Pol_SecGuide_0202_WDigestAuthn', $policySettings.DeviceSettings.pol_SecGuide_0202_WDigestAuthn)
            }
            if ($null -ne $policySettings.DeviceSettings.pol_MSS_DisableIPSourceRoutingIPv6)
            {
                $complexDeviceSettings.Add('Pol_MSS_DisableIPSourceRoutingIPv6', $policySettings.DeviceSettings.pol_MSS_DisableIPSourceRoutingIPv6)
            }
            if ($null -ne $policySettings.DeviceSettings.disableIPSourceRoutingIPv6)
            {
                $complexDeviceSettings.Add('DisableIPSourceRoutingIPv6', $policySettings.DeviceSettings.disableIPSourceRoutingIPv6)
            }
            if ($null -ne $policySettings.DeviceSettings.pol_MSS_DisableIPSourceRouting)
            {
                $complexDeviceSettings.Add('Pol_MSS_DisableIPSourceRouting', $policySettings.DeviceSettings.pol_MSS_DisableIPSourceRouting)
            }
            if ($null -ne $policySettings.DeviceSettings.disableIPSourceRouting)
            {
                $complexDeviceSettings.Add('DisableIPSourceRouting', $policySettings.DeviceSettings.disableIPSourceRouting)
            }
            if ($null -ne $policySettings.DeviceSettings.pol_MSS_EnableICMPRedirect)
            {
                $complexDeviceSettings.Add('Pol_MSS_EnableICMPRedirect', $policySettings.DeviceSettings.pol_MSS_EnableICMPRedirect)
            }
            if ($null -ne $policySettings.DeviceSettings.pol_MSS_NoNameReleaseOnDemand)
            {
                $complexDeviceSettings.Add('Pol_MSS_NoNameReleaseOnDemand', $policySettings.DeviceSettings.pol_MSS_NoNameReleaseOnDemand)
            }
            if ($null -ne $policySettings.DeviceSettings.turn_Off_Multicast)
            {
                $complexDeviceSettings.Add('Turn_Off_Multicast', $policySettings.DeviceSettings.turn_Off_Multicast)
            }
            if ($null -ne $policySettings.DeviceSettings.nC_ShowSharedAccessUI)
            {
                $complexDeviceSettings.Add('NC_ShowSharedAccessUI', $policySettings.DeviceSettings.nC_ShowSharedAccessUI)
            }
            if ($null -ne $policySettings.DeviceSettings.hardeneduncpaths_Pol_HardenedPaths)
            {
                $complexDeviceSettings.Add('Hardeneduncpaths_Pol_HardenedPaths', $policySettings.DeviceSettings.hardeneduncpaths_Pol_HardenedPaths)
            }
            if ($null -ne $policySettings.DeviceSettings.pol_hardenedPaths)
            {
                $complexPol_hardenedpaths = @()
                foreach ($currentPol_hardenedpaths in $policySettings.DeviceSettings.pol_hardenedPaths)
                {
                    $myPol_hardenedpaths = [ordered]@{}
                    if ($null -ne $currentPol_hardenedpaths.Key)
                    {
                        $myPol_hardenedpaths.Add('Key', $currentPol_hardenedpaths.key)
                    }
                    if ($null -ne $currentPol_hardenedpaths.value)
                    {
                        $myPol_hardenedpaths.Add('Value', $currentPol_hardenedpaths.value)
                    }
                    if ($myPol_hardenedpaths.values.Where({ $null -ne $_ }).Count -gt 0)
                    {
                        $complexPol_hardenedpaths += $myPol_hardenedpaths
                    }
                }
                $complexDeviceSettings.Add('pol_hardenedPaths', $complexPol_hardenedpaths)
            }
            if ($null -ne $policySettings.DeviceSettings.wCM_BlockNonDomain)
            {
                $complexDeviceSettings.Add('WCM_BlockNonDomain', $policySettings.DeviceSettings.wCM_BlockNonDomain)
            }
            if ($null -ne $policySettings.DeviceSettings.allowEncryptionOracle)
            {
                $complexDeviceSettings.Add('AllowEncryptionOracle', $policySettings.DeviceSettings.allowEncryptionOracle)
            }
            if ($null -ne $policySettings.DeviceSettings.allowEncryptionOracleDrop)
            {
                $complexDeviceSettings.Add('AllowEncryptionOracleDrop', $policySettings.DeviceSettings.allowEncryptionOracleDrop)
            }
            if ($null -ne $policySettings.DeviceSettings.allowProtectedCreds)
            {
                $complexDeviceSettings.Add('AllowProtectedCreds', $policySettings.DeviceSettings.allowProtectedCreds)
            }
            if ($null -ne $policySettings.DeviceSettings.deviceInstall_Classes_Deny)
            {
                $complexDeviceSettings.Add('DeviceInstall_Classes_Deny', $policySettings.DeviceSettings.deviceInstall_Classes_Deny)
            }
            if ($null -ne $policySettings.DeviceSettings.deviceInstall_Classes_Deny_List)
            {
                $complexDeviceSettings.Add('DeviceInstall_Classes_Deny_List', $policySettings.DeviceSettings.deviceInstall_Classes_Deny_List)
            }
            if ($null -ne $policySettings.DeviceSettings.deviceInstall_Classes_Deny_Retroactive)
            {
                $complexDeviceSettings.Add('DeviceInstall_Classes_Deny_Retroactive', $policySettings.DeviceSettings.deviceInstall_Classes_Deny_Retroactive)
            }
            if ($null -ne $policySettings.DeviceSettings.pOL_DriverLoadPolicy_Name)
            {
                $complexDeviceSettings.Add('POL_DriverLoadPolicy_Name', $policySettings.DeviceSettings.pOL_DriverLoadPolicy_Name)
            }
            if ($null -ne $policySettings.DeviceSettings.selectDriverLoadPolicy)
            {
                $complexDeviceSettings.Add('SelectDriverLoadPolicy', $policySettings.DeviceSettings.selectDriverLoadPolicy)
            }
            if ($null -ne $policySettings.DeviceSettings.cSE_Registry)
            {
                $complexDeviceSettings.Add('CSE_Registry', $policySettings.DeviceSettings.cSE_Registry)
            }
            if ($null -ne $policySettings.DeviceSettings.cSE_NOBACKGROUND10)
            {
                $complexDeviceSettings.Add('CSE_NOBACKGROUND10', $policySettings.DeviceSettings.cSE_NOBACKGROUND10)
            }
            if ($null -ne $policySettings.DeviceSettings.cSE_NOCHANGES10)
            {
                $complexDeviceSettings.Add('CSE_NOCHANGES10', $policySettings.DeviceSettings.cSE_NOCHANGES10)
            }
            if ($null -ne $policySettings.DeviceSettings.disableWebPnPDownload_2)
            {
                $complexDeviceSettings.Add('DisableWebPnPDownload_2', $policySettings.DeviceSettings.disableWebPnPDownload_2)
            }
            if ($null -ne $policySettings.DeviceSettings.shellPreventWPWDownload_2)
            {
                $complexDeviceSettings.Add('ShellPreventWPWDownload_2', $policySettings.DeviceSettings.shellPreventWPWDownload_2)
            }
            if ($null -ne $policySettings.DeviceSettings.rA_Solicit)
            {
                $complexDeviceSettings.Add('RA_Solicit', $policySettings.DeviceSettings.rA_Solicit)
            }
            if ($null -ne $policySettings.DeviceSettings.rA_Solicit_ExpireUnits_List)
            {
                $complexDeviceSettings.Add('RA_Solicit_ExpireUnits_List', $policySettings.DeviceSettings.rA_Solicit_ExpireUnits_List)
            }
            if ($null -ne $policySettings.DeviceSettings.rA_Solicit_ExpireValue_Edt)
            {
                $complexDeviceSettings.Add('RA_Solicit_ExpireValue_Edt', $policySettings.DeviceSettings.rA_Solicit_ExpireValue_Edt)
            }
            if ($null -ne $policySettings.DeviceSettings.rA_Solicit_Control_List)
            {
                $complexDeviceSettings.Add('RA_Solicit_Control_List', $policySettings.DeviceSettings.rA_Solicit_Control_List)
            }
            if ($null -ne $policySettings.DeviceSettings.rA_Solicit_Mailto_List)
            {
                $complexDeviceSettings.Add('RA_Solicit_Mailto_List', $policySettings.DeviceSettings.rA_Solicit_Mailto_List)
            }
            if ($null -ne $policySettings.DeviceSettings.rpcRestrictRemoteClients)
            {
                $complexDeviceSettings.Add('RpcRestrictRemoteClients', $policySettings.DeviceSettings.rpcRestrictRemoteClients)
            }
            if ($null -ne $policySettings.DeviceSettings.rpcRestrictRemoteClientsList)
            {
                $complexDeviceSettings.Add('RpcRestrictRemoteClientsList', $policySettings.DeviceSettings.rpcRestrictRemoteClientsList)
            }
            if ($null -ne $policySettings.DeviceSettings.appxRuntimeMicrosoftAccountsOptional)
            {
                $complexDeviceSettings.Add('AppxRuntimeMicrosoftAccountsOptional', $policySettings.DeviceSettings.appxRuntimeMicrosoftAccountsOptional)
            }
            if ($null -ne $policySettings.DeviceSettings.noAutoplayfornonVolume)
            {
                $complexDeviceSettings.Add('NoAutoplayfornonVolume', $policySettings.DeviceSettings.noAutoplayfornonVolume)
            }
            if ($null -ne $policySettings.DeviceSettings.noAutorun)
            {
                $complexDeviceSettings.Add('NoAutorun', $policySettings.DeviceSettings.noAutorun)
            }
            if ($null -ne $policySettings.DeviceSettings.noAutorun_Dropdown)
            {
                $complexDeviceSettings.Add('NoAutorun_Dropdown', $policySettings.DeviceSettings.noAutorun_Dropdown)
            }
            if ($null -ne $policySettings.DeviceSettings.autorun)
            {
                $complexDeviceSettings.Add('Autorun', $policySettings.DeviceSettings.autorun)
            }
            if ($null -ne $policySettings.DeviceSettings.autorun_Box)
            {
                $complexDeviceSettings.Add('Autorun_Box', $policySettings.DeviceSettings.autorun_Box)
            }
            if ($null -ne $policySettings.DeviceSettings.enumerateAdministrators)
            {
                $complexDeviceSettings.Add('EnumerateAdministrators', $policySettings.DeviceSettings.enumerateAdministrators)
            }
            if ($null -ne $policySettings.DeviceSettings.channel_LogMaxSize_1)
            {
                $complexDeviceSettings.Add('Channel_LogMaxSize_1', $policySettings.DeviceSettings.channel_LogMaxSize_1)
            }
            if ($null -ne $policySettings.DeviceSettings.channel_LogMaxSize_1_Channel_LogMaxSize)
            {
                $complexDeviceSettings.Add('Channel_LogMaxSize_1_Channel_LogMaxSize', $policySettings.DeviceSettings.channel_LogMaxSize_1_Channel_LogMaxSize)
            }
            if ($null -ne $policySettings.DeviceSettings.channel_LogMaxSize_2)
            {
                $complexDeviceSettings.Add('Channel_LogMaxSize_2', $policySettings.DeviceSettings.channel_LogMaxSize_2)
            }
            if ($null -ne $policySettings.DeviceSettings.channel_LogMaxSize_2_Channel_LogMaxSize)
            {
                $complexDeviceSettings.Add('Channel_LogMaxSize_2_Channel_LogMaxSize', $policySettings.DeviceSettings.channel_LogMaxSize_2_Channel_LogMaxSize)
            }
            if ($null -ne $policySettings.DeviceSettings.channel_LogMaxSize_4)
            {
                $complexDeviceSettings.Add('Channel_LogMaxSize_4', $policySettings.DeviceSettings.channel_LogMaxSize_4)
            }
            if ($null -ne $policySettings.DeviceSettings.channel_LogMaxSize_4_Channel_LogMaxSize)
            {
                $complexDeviceSettings.Add('Channel_LogMaxSize_4_Channel_LogMaxSize', $policySettings.DeviceSettings.channel_LogMaxSize_4_Channel_LogMaxSize)
            }
            if ($null -ne $policySettings.DeviceSettings.enableSmartScreen)
            {
                $complexDeviceSettings.Add('EnableSmartScreen', $policySettings.DeviceSettings.enableSmartScreen)
            }
            if ($null -ne $policySettings.DeviceSettings.enableSmartScreenDropdown)
            {
                $complexDeviceSettings.Add('EnableSmartScreenDropdown', $policySettings.DeviceSettings.enableSmartScreenDropdown)
            }
            if ($null -ne $policySettings.DeviceSettings.noDataExecutionPrevention)
            {
                $complexDeviceSettings.Add('NoDataExecutionPrevention', $policySettings.DeviceSettings.noDataExecutionPrevention)
            }
            if ($null -ne $policySettings.DeviceSettings.noHeapTerminationOnCorruption)
            {
                $complexDeviceSettings.Add('NoHeapTerminationOnCorruption', $policySettings.DeviceSettings.noHeapTerminationOnCorruption)
            }
            if ($null -ne $policySettings.DeviceSettings.advanced_InvalidSignatureBlock)
            {
                $complexDeviceSettings.Add('Advanced_InvalidSignatureBlock', $policySettings.DeviceSettings.advanced_InvalidSignatureBlock)
            }
            if ($null -ne $policySettings.DeviceSettings.advanced_CertificateRevocation)
            {
                $complexDeviceSettings.Add('Advanced_CertificateRevocation', $policySettings.DeviceSettings.advanced_CertificateRevocation)
            }
            if ($null -ne $policySettings.DeviceSettings.advanced_DownloadSignatures)
            {
                $complexDeviceSettings.Add('Advanced_DownloadSignatures', $policySettings.DeviceSettings.advanced_DownloadSignatures)
            }
            if ($null -ne $policySettings.DeviceSettings.advanced_DisableEPMCompat)
            {
                $complexDeviceSettings.Add('Advanced_DisableEPMCompat', $policySettings.DeviceSettings.advanced_DisableEPMCompat)
            }
            if ($null -ne $policySettings.DeviceSettings.advanced_SetWinInetProtocols)
            {
                $complexDeviceSettings.Add('Advanced_SetWinInetProtocols', $policySettings.DeviceSettings.advanced_SetWinInetProtocols)
            }
            if ($null -ne $policySettings.DeviceSettings.advanced_WinInetProtocolOptions)
            {
                $complexDeviceSettings.Add('Advanced_WinInetProtocolOptions', $policySettings.DeviceSettings.advanced_WinInetProtocolOptions)
            }
            if ($null -ne $policySettings.DeviceSettings.advanced_EnableEnhancedProtectedMode64Bit)
            {
                $complexDeviceSettings.Add('Advanced_EnableEnhancedProtectedMode64Bit', $policySettings.DeviceSettings.advanced_EnableEnhancedProtectedMode64Bit)
            }
            if ($null -ne $policySettings.DeviceSettings.advanced_EnableEnhancedProtectedMode)
            {
                $complexDeviceSettings.Add('Advanced_EnableEnhancedProtectedMode', $policySettings.DeviceSettings.advanced_EnableEnhancedProtectedMode)
            }
            if ($null -ne $policySettings.DeviceSettings.noCertError)
            {
                $complexDeviceSettings.Add('NoCertError', $policySettings.DeviceSettings.noCertError)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_PolicyAccessDataSourcesAcrossDomains_1)
            {
                $complexDeviceSettings.Add('IZ_PolicyAccessDataSourcesAcrossDomains_1', $policySettings.DeviceSettings.iZ_PolicyAccessDataSourcesAcrossDomains_1)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_PolicyAccessDataSourcesAcrossDomains_1_IZ_Partname1406)
            {
                $complexDeviceSettings.Add('IZ_PolicyAccessDataSourcesAcrossDomains_1_IZ_Partname1406', $policySettings.DeviceSettings.iZ_PolicyAccessDataSourcesAcrossDomains_1_IZ_Partname1406)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_PolicyAllowPasteViaScript_1)
            {
                $complexDeviceSettings.Add('IZ_PolicyAllowPasteViaScript_1', $policySettings.DeviceSettings.iZ_PolicyAllowPasteViaScript_1)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_PolicyAllowPasteViaScript_1_IZ_Partname1407)
            {
                $complexDeviceSettings.Add('IZ_PolicyAllowPasteViaScript_1_IZ_Partname1407', $policySettings.DeviceSettings.iZ_PolicyAllowPasteViaScript_1_IZ_Partname1407)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_PolicyDropOrPasteFiles_1)
            {
                $complexDeviceSettings.Add('IZ_PolicyDropOrPasteFiles_1', $policySettings.DeviceSettings.iZ_PolicyDropOrPasteFiles_1)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_PolicyDropOrPasteFiles_1_IZ_Partname1802)
            {
                $complexDeviceSettings.Add('IZ_PolicyDropOrPasteFiles_1_IZ_Partname1802', $policySettings.DeviceSettings.iZ_PolicyDropOrPasteFiles_1_IZ_Partname1802)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_Policy_XAML_1)
            {
                $complexDeviceSettings.Add('IZ_Policy_XAML_1', $policySettings.DeviceSettings.iZ_Policy_XAML_1)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_Policy_XAML_1_IZ_Partname2402)
            {
                $complexDeviceSettings.Add('IZ_Policy_XAML_1_IZ_Partname2402', $policySettings.DeviceSettings.iZ_Policy_XAML_1_IZ_Partname2402)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_PolicyOnlyAllowApprovedDomainsToUseActiveXWithoutPrompt_Both_Internet)
            {
                $complexDeviceSettings.Add('IZ_PolicyOnlyAllowApprovedDomainsToUseActiveXWithoutPrompt_Both_Internet', $policySettings.DeviceSettings.iZ_PolicyOnlyAllowApprovedDomainsToUseActiveXWithoutPrompt_Both_Internet)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_PolicyOnlyAllowApprovedDomainsToUseActiveXWithoutPrompt_Both_Internet_IZ_Partname120b)
            {
                $complexDeviceSettings.Add('IZ_PolicyOnlyAllowApprovedDomainsToUseActiveXWithoutPrompt_Both_Internet_IZ_Partname120b', $policySettings.DeviceSettings.iZ_PolicyOnlyAllowApprovedDomainsToUseActiveXWithoutPrompt_Both_Internet_IZ_Partname120b)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_PolicyAllowTDCControl_Both_Internet)
            {
                $complexDeviceSettings.Add('IZ_PolicyAllowTDCControl_Both_Internet', $policySettings.DeviceSettings.iZ_PolicyAllowTDCControl_Both_Internet)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_PolicyAllowTDCControl_Both_Internet_IZ_Partname120c)
            {
                $complexDeviceSettings.Add('IZ_PolicyAllowTDCControl_Both_Internet_IZ_Partname120c', $policySettings.DeviceSettings.iZ_PolicyAllowTDCControl_Both_Internet_IZ_Partname120c)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_PolicyWindowsRestrictionsURLaction_1)
            {
                $complexDeviceSettings.Add('IZ_PolicyWindowsRestrictionsURLaction_1', $policySettings.DeviceSettings.iZ_PolicyWindowsRestrictionsURLaction_1)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_PolicyWindowsRestrictionsURLaction_1_IZ_Partname2102)
            {
                $complexDeviceSettings.Add('IZ_PolicyWindowsRestrictionsURLaction_1_IZ_Partname2102', $policySettings.DeviceSettings.iZ_PolicyWindowsRestrictionsURLaction_1_IZ_Partname2102)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_Policy_WebBrowserControl_1)
            {
                $complexDeviceSettings.Add('IZ_Policy_WebBrowserControl_1', $policySettings.DeviceSettings.iZ_Policy_WebBrowserControl_1)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_Policy_WebBrowserControl_1_IZ_Partname1206)
            {
                $complexDeviceSettings.Add('IZ_Policy_WebBrowserControl_1_IZ_Partname1206', $policySettings.DeviceSettings.iZ_Policy_WebBrowserControl_1_IZ_Partname1206)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_Policy_AllowScriptlets_1)
            {
                $complexDeviceSettings.Add('IZ_Policy_AllowScriptlets_1', $policySettings.DeviceSettings.iZ_Policy_AllowScriptlets_1)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_Policy_AllowScriptlets_1_IZ_Partname1209)
            {
                $complexDeviceSettings.Add('IZ_Policy_AllowScriptlets_1_IZ_Partname1209', $policySettings.DeviceSettings.iZ_Policy_AllowScriptlets_1_IZ_Partname1209)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_Policy_ScriptStatusBar_1)
            {
                $complexDeviceSettings.Add('IZ_Policy_ScriptStatusBar_1', $policySettings.DeviceSettings.iZ_Policy_ScriptStatusBar_1)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_Policy_ScriptStatusBar_1_IZ_Partname2103)
            {
                $complexDeviceSettings.Add('IZ_Policy_ScriptStatusBar_1_IZ_Partname2103', $policySettings.DeviceSettings.iZ_Policy_ScriptStatusBar_1_IZ_Partname2103)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_PolicyAllowVBScript_1)
            {
                $complexDeviceSettings.Add('IZ_PolicyAllowVBScript_1', $policySettings.DeviceSettings.iZ_PolicyAllowVBScript_1)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_PolicyAllowVBScript_1_IZ_Partname140C)
            {
                $complexDeviceSettings.Add('IZ_PolicyAllowVBScript_1_IZ_Partname140C', $policySettings.DeviceSettings.iZ_PolicyAllowVBScript_1_IZ_Partname140C)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_PolicyNotificationBarDownloadURLaction_1)
            {
                $complexDeviceSettings.Add('IZ_PolicyNotificationBarDownloadURLaction_1', $policySettings.DeviceSettings.iZ_PolicyNotificationBarDownloadURLaction_1)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_PolicyNotificationBarDownloadURLaction_1_IZ_Partname2200)
            {
                $complexDeviceSettings.Add('IZ_PolicyNotificationBarDownloadURLaction_1_IZ_Partname2200', $policySettings.DeviceSettings.iZ_PolicyNotificationBarDownloadURLaction_1_IZ_Partname2200)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_PolicyAntiMalwareCheckingOfActiveXControls_1)
            {
                $complexDeviceSettings.Add('IZ_PolicyAntiMalwareCheckingOfActiveXControls_1', $policySettings.DeviceSettings.iZ_PolicyAntiMalwareCheckingOfActiveXControls_1)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_PolicyAntiMalwareCheckingOfActiveXControls_1_IZ_Partname270C)
            {
                $complexDeviceSettings.Add('IZ_PolicyAntiMalwareCheckingOfActiveXControls_1_IZ_Partname270C', $policySettings.DeviceSettings.iZ_PolicyAntiMalwareCheckingOfActiveXControls_1_IZ_Partname270C)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_PolicyDownloadSignedActiveX_1)
            {
                $complexDeviceSettings.Add('IZ_PolicyDownloadSignedActiveX_1', $policySettings.DeviceSettings.iZ_PolicyDownloadSignedActiveX_1)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_PolicyDownloadSignedActiveX_1_IZ_Partname1001)
            {
                $complexDeviceSettings.Add('IZ_PolicyDownloadSignedActiveX_1_IZ_Partname1001', $policySettings.DeviceSettings.iZ_PolicyDownloadSignedActiveX_1_IZ_Partname1001)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_PolicyDownloadUnsignedActiveX_1)
            {
                $complexDeviceSettings.Add('IZ_PolicyDownloadUnsignedActiveX_1', $policySettings.DeviceSettings.iZ_PolicyDownloadUnsignedActiveX_1)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_PolicyDownloadUnsignedActiveX_1_IZ_Partname1004)
            {
                $complexDeviceSettings.Add('IZ_PolicyDownloadUnsignedActiveX_1_IZ_Partname1004', $policySettings.DeviceSettings.iZ_PolicyDownloadUnsignedActiveX_1_IZ_Partname1004)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_PolicyDragDropAcrossDomainsAcrossWindows_Both_Internet)
            {
                $complexDeviceSettings.Add('IZ_PolicyDragDropAcrossDomainsAcrossWindows_Both_Internet', $policySettings.DeviceSettings.iZ_PolicyDragDropAcrossDomainsAcrossWindows_Both_Internet)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_PolicyDragDropAcrossDomainsAcrossWindows_Both_Internet_IZ_Partname2709)
            {
                $complexDeviceSettings.Add('IZ_PolicyDragDropAcrossDomainsAcrossWindows_Both_Internet_IZ_Partname2709', $policySettings.DeviceSettings.iZ_PolicyDragDropAcrossDomainsAcrossWindows_Both_Internet_IZ_Partname2709)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_PolicyDragDropAcrossDomainsWithinWindow_Both_Internet)
            {
                $complexDeviceSettings.Add('IZ_PolicyDragDropAcrossDomainsWithinWindow_Both_Internet', $policySettings.DeviceSettings.iZ_PolicyDragDropAcrossDomainsWithinWindow_Both_Internet)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_PolicyDragDropAcrossDomainsWithinWindow_Both_Internet_IZ_Partname2708)
            {
                $complexDeviceSettings.Add('IZ_PolicyDragDropAcrossDomainsWithinWindow_Both_Internet_IZ_Partname2708', $policySettings.DeviceSettings.iZ_PolicyDragDropAcrossDomainsWithinWindow_Both_Internet_IZ_Partname2708)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_Policy_LocalPathForUpload_1)
            {
                $complexDeviceSettings.Add('IZ_Policy_LocalPathForUpload_1', $policySettings.DeviceSettings.iZ_Policy_LocalPathForUpload_1)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_Policy_LocalPathForUpload_1_IZ_Partname160A)
            {
                $complexDeviceSettings.Add('IZ_Policy_LocalPathForUpload_1_IZ_Partname160A', $policySettings.DeviceSettings.iZ_Policy_LocalPathForUpload_1_IZ_Partname160A)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_PolicyScriptActiveXNotMarkedSafe_1)
            {
                $complexDeviceSettings.Add('IZ_PolicyScriptActiveXNotMarkedSafe_1', $policySettings.DeviceSettings.iZ_PolicyScriptActiveXNotMarkedSafe_1)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_PolicyScriptActiveXNotMarkedSafe_1_IZ_Partname1201)
            {
                $complexDeviceSettings.Add('IZ_PolicyScriptActiveXNotMarkedSafe_1_IZ_Partname1201', $policySettings.DeviceSettings.iZ_PolicyScriptActiveXNotMarkedSafe_1_IZ_Partname1201)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_PolicyJavaPermissions_1)
            {
                $complexDeviceSettings.Add('IZ_PolicyJavaPermissions_1', $policySettings.DeviceSettings.iZ_PolicyJavaPermissions_1)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_PolicyJavaPermissions_1_IZ_Partname1C00)
            {
                $complexDeviceSettings.Add('IZ_PolicyJavaPermissions_1_IZ_Partname1C00', $policySettings.DeviceSettings.iZ_PolicyJavaPermissions_1_IZ_Partname1C00)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_PolicyLaunchAppsAndFilesInIFRAME_1)
            {
                $complexDeviceSettings.Add('IZ_PolicyLaunchAppsAndFilesInIFRAME_1', $policySettings.DeviceSettings.iZ_PolicyLaunchAppsAndFilesInIFRAME_1)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_PolicyLaunchAppsAndFilesInIFRAME_1_IZ_Partname1804)
            {
                $complexDeviceSettings.Add('IZ_PolicyLaunchAppsAndFilesInIFRAME_1_IZ_Partname1804', $policySettings.DeviceSettings.iZ_PolicyLaunchAppsAndFilesInIFRAME_1_IZ_Partname1804)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_PolicyLogon_1)
            {
                $complexDeviceSettings.Add('IZ_PolicyLogon_1', $policySettings.DeviceSettings.iZ_PolicyLogon_1)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_PolicyLogon_1_IZ_Partname1A00)
            {
                $complexDeviceSettings.Add('IZ_PolicyLogon_1_IZ_Partname1A00', $policySettings.DeviceSettings.iZ_PolicyLogon_1_IZ_Partname1A00)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_PolicyNavigateSubframesAcrossDomains_1)
            {
                $complexDeviceSettings.Add('IZ_PolicyNavigateSubframesAcrossDomains_1', $policySettings.DeviceSettings.iZ_PolicyNavigateSubframesAcrossDomains_1)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_PolicyNavigateSubframesAcrossDomains_1_IZ_Partname1607)
            {
                $complexDeviceSettings.Add('IZ_PolicyNavigateSubframesAcrossDomains_1_IZ_Partname1607', $policySettings.DeviceSettings.iZ_PolicyNavigateSubframesAcrossDomains_1_IZ_Partname1607)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_PolicyUnsignedFrameworkComponentsURLaction_1)
            {
                $complexDeviceSettings.Add('IZ_PolicyUnsignedFrameworkComponentsURLaction_1', $policySettings.DeviceSettings.iZ_PolicyUnsignedFrameworkComponentsURLaction_1)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_PolicyUnsignedFrameworkComponentsURLaction_1_IZ_Partname2004)
            {
                $complexDeviceSettings.Add('IZ_PolicyUnsignedFrameworkComponentsURLaction_1_IZ_Partname2004', $policySettings.DeviceSettings.iZ_PolicyUnsignedFrameworkComponentsURLaction_1_IZ_Partname2004)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_PolicySignedFrameworkComponentsURLaction_1)
            {
                $complexDeviceSettings.Add('IZ_PolicySignedFrameworkComponentsURLaction_1', $policySettings.DeviceSettings.iZ_PolicySignedFrameworkComponentsURLaction_1)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_PolicySignedFrameworkComponentsURLaction_1_IZ_Partname2001)
            {
                $complexDeviceSettings.Add('IZ_PolicySignedFrameworkComponentsURLaction_1_IZ_Partname2001', $policySettings.DeviceSettings.iZ_PolicySignedFrameworkComponentsURLaction_1_IZ_Partname2001)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_Policy_UnsafeFiles_1)
            {
                $complexDeviceSettings.Add('IZ_Policy_UnsafeFiles_1', $policySettings.DeviceSettings.iZ_Policy_UnsafeFiles_1)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_Policy_UnsafeFiles_1_IZ_Partname1806)
            {
                $complexDeviceSettings.Add('IZ_Policy_UnsafeFiles_1_IZ_Partname1806', $policySettings.DeviceSettings.iZ_Policy_UnsafeFiles_1_IZ_Partname1806)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_PolicyTurnOnXSSFilter_Both_Internet)
            {
                $complexDeviceSettings.Add('IZ_PolicyTurnOnXSSFilter_Both_Internet', $policySettings.DeviceSettings.iZ_PolicyTurnOnXSSFilter_Both_Internet)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_PolicyTurnOnXSSFilter_Both_Internet_IZ_Partname1409)
            {
                $complexDeviceSettings.Add('IZ_PolicyTurnOnXSSFilter_Both_Internet_IZ_Partname1409', $policySettings.DeviceSettings.iZ_PolicyTurnOnXSSFilter_Both_Internet_IZ_Partname1409)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_Policy_TurnOnProtectedMode_1)
            {
                $complexDeviceSettings.Add('IZ_Policy_TurnOnProtectedMode_1', $policySettings.DeviceSettings.iZ_Policy_TurnOnProtectedMode_1)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_Policy_TurnOnProtectedMode_1_IZ_Partname2500)
            {
                $complexDeviceSettings.Add('IZ_Policy_TurnOnProtectedMode_1_IZ_Partname2500', $policySettings.DeviceSettings.iZ_Policy_TurnOnProtectedMode_1_IZ_Partname2500)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_Policy_Phishing_1)
            {
                $complexDeviceSettings.Add('IZ_Policy_Phishing_1', $policySettings.DeviceSettings.iZ_Policy_Phishing_1)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_Policy_Phishing_1_IZ_Partname2301)
            {
                $complexDeviceSettings.Add('IZ_Policy_Phishing_1_IZ_Partname2301', $policySettings.DeviceSettings.iZ_Policy_Phishing_1_IZ_Partname2301)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_PolicyBlockPopupWindows_1)
            {
                $complexDeviceSettings.Add('IZ_PolicyBlockPopupWindows_1', $policySettings.DeviceSettings.iZ_PolicyBlockPopupWindows_1)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_PolicyBlockPopupWindows_1_IZ_Partname1809)
            {
                $complexDeviceSettings.Add('IZ_PolicyBlockPopupWindows_1_IZ_Partname1809', $policySettings.DeviceSettings.iZ_PolicyBlockPopupWindows_1_IZ_Partname1809)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_PolicyUserdataPersistence_1)
            {
                $complexDeviceSettings.Add('IZ_PolicyUserdataPersistence_1', $policySettings.DeviceSettings.iZ_PolicyUserdataPersistence_1)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_PolicyUserdataPersistence_1_IZ_Partname1606)
            {
                $complexDeviceSettings.Add('IZ_PolicyUserdataPersistence_1_IZ_Partname1606', $policySettings.DeviceSettings.iZ_PolicyUserdataPersistence_1_IZ_Partname1606)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_PolicyZoneElevationURLaction_1)
            {
                $complexDeviceSettings.Add('IZ_PolicyZoneElevationURLaction_1', $policySettings.DeviceSettings.iZ_PolicyZoneElevationURLaction_1)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_PolicyZoneElevationURLaction_1_IZ_Partname2101)
            {
                $complexDeviceSettings.Add('IZ_PolicyZoneElevationURLaction_1_IZ_Partname2101', $policySettings.DeviceSettings.iZ_PolicyZoneElevationURLaction_1_IZ_Partname2101)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_UNCAsIntranet)
            {
                $complexDeviceSettings.Add('IZ_UNCAsIntranet', $policySettings.DeviceSettings.iZ_UNCAsIntranet)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_PolicyAntiMalwareCheckingOfActiveXControls_3)
            {
                $complexDeviceSettings.Add('IZ_PolicyAntiMalwareCheckingOfActiveXControls_3', $policySettings.DeviceSettings.iZ_PolicyAntiMalwareCheckingOfActiveXControls_3)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_PolicyAntiMalwareCheckingOfActiveXControls_3_IZ_Partname270C)
            {
                $complexDeviceSettings.Add('IZ_PolicyAntiMalwareCheckingOfActiveXControls_3_IZ_Partname270C', $policySettings.DeviceSettings.iZ_PolicyAntiMalwareCheckingOfActiveXControls_3_IZ_Partname270C)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_PolicyScriptActiveXNotMarkedSafe_3)
            {
                $complexDeviceSettings.Add('IZ_PolicyScriptActiveXNotMarkedSafe_3', $policySettings.DeviceSettings.iZ_PolicyScriptActiveXNotMarkedSafe_3)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_PolicyScriptActiveXNotMarkedSafe_3_IZ_Partname1201)
            {
                $complexDeviceSettings.Add('IZ_PolicyScriptActiveXNotMarkedSafe_3_IZ_Partname1201', $policySettings.DeviceSettings.iZ_PolicyScriptActiveXNotMarkedSafe_3_IZ_Partname1201)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_PolicyJavaPermissions_3)
            {
                $complexDeviceSettings.Add('IZ_PolicyJavaPermissions_3', $policySettings.DeviceSettings.iZ_PolicyJavaPermissions_3)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_PolicyJavaPermissions_3_IZ_Partname1C00)
            {
                $complexDeviceSettings.Add('IZ_PolicyJavaPermissions_3_IZ_Partname1C00', $policySettings.DeviceSettings.iZ_PolicyJavaPermissions_3_IZ_Partname1C00)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_PolicyAntiMalwareCheckingOfActiveXControls_9)
            {
                $complexDeviceSettings.Add('IZ_PolicyAntiMalwareCheckingOfActiveXControls_9', $policySettings.DeviceSettings.iZ_PolicyAntiMalwareCheckingOfActiveXControls_9)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_PolicyAntiMalwareCheckingOfActiveXControls_9_IZ_Partname270C)
            {
                $complexDeviceSettings.Add('IZ_PolicyAntiMalwareCheckingOfActiveXControls_9_IZ_Partname270C', $policySettings.DeviceSettings.iZ_PolicyAntiMalwareCheckingOfActiveXControls_9_IZ_Partname270C)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_PolicyJavaPermissions_9)
            {
                $complexDeviceSettings.Add('IZ_PolicyJavaPermissions_9', $policySettings.DeviceSettings.iZ_PolicyJavaPermissions_9)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_PolicyJavaPermissions_9_IZ_Partname1C00)
            {
                $complexDeviceSettings.Add('IZ_PolicyJavaPermissions_9_IZ_Partname1C00', $policySettings.DeviceSettings.iZ_PolicyJavaPermissions_9_IZ_Partname1C00)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_Policy_Phishing_2)
            {
                $complexDeviceSettings.Add('IZ_Policy_Phishing_2', $policySettings.DeviceSettings.iZ_Policy_Phishing_2)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_Policy_Phishing_2_IZ_Partname2301)
            {
                $complexDeviceSettings.Add('IZ_Policy_Phishing_2_IZ_Partname2301', $policySettings.DeviceSettings.iZ_Policy_Phishing_2_IZ_Partname2301)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_PolicyJavaPermissions_4)
            {
                $complexDeviceSettings.Add('IZ_PolicyJavaPermissions_4', $policySettings.DeviceSettings.iZ_PolicyJavaPermissions_4)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_PolicyJavaPermissions_4_IZ_Partname1C00)
            {
                $complexDeviceSettings.Add('IZ_PolicyJavaPermissions_4_IZ_Partname1C00', $policySettings.DeviceSettings.iZ_PolicyJavaPermissions_4_IZ_Partname1C00)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_PolicyJavaPermissions_10)
            {
                $complexDeviceSettings.Add('IZ_PolicyJavaPermissions_10', $policySettings.DeviceSettings.iZ_PolicyJavaPermissions_10)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_PolicyJavaPermissions_10_IZ_Partname1C00)
            {
                $complexDeviceSettings.Add('IZ_PolicyJavaPermissions_10_IZ_Partname1C00', $policySettings.DeviceSettings.iZ_PolicyJavaPermissions_10_IZ_Partname1C00)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_PolicyJavaPermissions_8)
            {
                $complexDeviceSettings.Add('IZ_PolicyJavaPermissions_8', $policySettings.DeviceSettings.iZ_PolicyJavaPermissions_8)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_PolicyJavaPermissions_8_IZ_Partname1C00)
            {
                $complexDeviceSettings.Add('IZ_PolicyJavaPermissions_8_IZ_Partname1C00', $policySettings.DeviceSettings.iZ_PolicyJavaPermissions_8_IZ_Partname1C00)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_Policy_Phishing_8)
            {
                $complexDeviceSettings.Add('IZ_Policy_Phishing_8', $policySettings.DeviceSettings.iZ_Policy_Phishing_8)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_Policy_Phishing_8_IZ_Partname2301)
            {
                $complexDeviceSettings.Add('IZ_Policy_Phishing_8_IZ_Partname2301', $policySettings.DeviceSettings.iZ_Policy_Phishing_8_IZ_Partname2301)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_PolicyJavaPermissions_6)
            {
                $complexDeviceSettings.Add('IZ_PolicyJavaPermissions_6', $policySettings.DeviceSettings.iZ_PolicyJavaPermissions_6)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_PolicyJavaPermissions_6_IZ_Partname1C00)
            {
                $complexDeviceSettings.Add('IZ_PolicyJavaPermissions_6_IZ_Partname1C00', $policySettings.DeviceSettings.iZ_PolicyJavaPermissions_6_IZ_Partname1C00)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_PolicyAccessDataSourcesAcrossDomains_7)
            {
                $complexDeviceSettings.Add('IZ_PolicyAccessDataSourcesAcrossDomains_7', $policySettings.DeviceSettings.iZ_PolicyAccessDataSourcesAcrossDomains_7)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_PolicyAccessDataSourcesAcrossDomains_7_IZ_Partname1406)
            {
                $complexDeviceSettings.Add('IZ_PolicyAccessDataSourcesAcrossDomains_7_IZ_Partname1406', $policySettings.DeviceSettings.iZ_PolicyAccessDataSourcesAcrossDomains_7_IZ_Partname1406)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_PolicyActiveScripting_7)
            {
                $complexDeviceSettings.Add('IZ_PolicyActiveScripting_7', $policySettings.DeviceSettings.iZ_PolicyActiveScripting_7)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_Partname1400)
            {
                $complexDeviceSettings.Add('IZ_Partname1400', $policySettings.DeviceSettings.iZ_Partname1400)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_PolicyBinaryBehaviors_7)
            {
                $complexDeviceSettings.Add('IZ_PolicyBinaryBehaviors_7', $policySettings.DeviceSettings.iZ_PolicyBinaryBehaviors_7)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_Partname2000)
            {
                $complexDeviceSettings.Add('IZ_Partname2000', $policySettings.DeviceSettings.iZ_Partname2000)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_PolicyAllowPasteViaScript_7)
            {
                $complexDeviceSettings.Add('IZ_PolicyAllowPasteViaScript_7', $policySettings.DeviceSettings.iZ_PolicyAllowPasteViaScript_7)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_PolicyAllowPasteViaScript_7_IZ_Partname1407)
            {
                $complexDeviceSettings.Add('IZ_PolicyAllowPasteViaScript_7_IZ_Partname1407', $policySettings.DeviceSettings.iZ_PolicyAllowPasteViaScript_7_IZ_Partname1407)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_PolicyDropOrPasteFiles_7)
            {
                $complexDeviceSettings.Add('IZ_PolicyDropOrPasteFiles_7', $policySettings.DeviceSettings.iZ_PolicyDropOrPasteFiles_7)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_PolicyDropOrPasteFiles_7_IZ_Partname1802)
            {
                $complexDeviceSettings.Add('IZ_PolicyDropOrPasteFiles_7_IZ_Partname1802', $policySettings.DeviceSettings.iZ_PolicyDropOrPasteFiles_7_IZ_Partname1802)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_PolicyFileDownload_7)
            {
                $complexDeviceSettings.Add('IZ_PolicyFileDownload_7', $policySettings.DeviceSettings.iZ_PolicyFileDownload_7)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_Partname1803)
            {
                $complexDeviceSettings.Add('IZ_Partname1803', $policySettings.DeviceSettings.iZ_Partname1803)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_Policy_XAML_7)
            {
                $complexDeviceSettings.Add('IZ_Policy_XAML_7', $policySettings.DeviceSettings.iZ_Policy_XAML_7)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_Policy_XAML_7_IZ_Partname2402)
            {
                $complexDeviceSettings.Add('IZ_Policy_XAML_7_IZ_Partname2402', $policySettings.DeviceSettings.iZ_Policy_XAML_7_IZ_Partname2402)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_PolicyAllowMETAREFRESH_7)
            {
                $complexDeviceSettings.Add('IZ_PolicyAllowMETAREFRESH_7', $policySettings.DeviceSettings.iZ_PolicyAllowMETAREFRESH_7)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_Partname1608)
            {
                $complexDeviceSettings.Add('IZ_Partname1608', $policySettings.DeviceSettings.iZ_Partname1608)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_PolicyOnlyAllowApprovedDomainsToUseActiveXWithoutPrompt_Both_Restricted)
            {
                $complexDeviceSettings.Add('IZ_PolicyOnlyAllowApprovedDomainsToUseActiveXWithoutPrompt_Both_Restricted', $policySettings.DeviceSettings.iZ_PolicyOnlyAllowApprovedDomainsToUseActiveXWithoutPrompt_Both_Restricted)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_PolicyOnlyAllowApprovedDomainsToUseActiveXWithoutPrompt_Both_Restricted_IZ_Partname120b)
            {
                $complexDeviceSettings.Add('IZ_PolicyOnlyAllowApprovedDomainsToUseActiveXWithoutPrompt_Both_Restricted_IZ_Partname120b', $policySettings.DeviceSettings.iZ_PolicyOnlyAllowApprovedDomainsToUseActiveXWithoutPrompt_Both_Restricted_IZ_Partname120b)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_PolicyAllowTDCControl_Both_Restricted)
            {
                $complexDeviceSettings.Add('IZ_PolicyAllowTDCControl_Both_Restricted', $policySettings.DeviceSettings.iZ_PolicyAllowTDCControl_Both_Restricted)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_PolicyAllowTDCControl_Both_Restricted_IZ_Partname120c)
            {
                $complexDeviceSettings.Add('IZ_PolicyAllowTDCControl_Both_Restricted_IZ_Partname120c', $policySettings.DeviceSettings.iZ_PolicyAllowTDCControl_Both_Restricted_IZ_Partname120c)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_PolicyWindowsRestrictionsURLaction_7)
            {
                $complexDeviceSettings.Add('IZ_PolicyWindowsRestrictionsURLaction_7', $policySettings.DeviceSettings.iZ_PolicyWindowsRestrictionsURLaction_7)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_PolicyWindowsRestrictionsURLaction_7_IZ_Partname2102)
            {
                $complexDeviceSettings.Add('IZ_PolicyWindowsRestrictionsURLaction_7_IZ_Partname2102', $policySettings.DeviceSettings.iZ_PolicyWindowsRestrictionsURLaction_7_IZ_Partname2102)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_Policy_WebBrowserControl_7)
            {
                $complexDeviceSettings.Add('IZ_Policy_WebBrowserControl_7', $policySettings.DeviceSettings.iZ_Policy_WebBrowserControl_7)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_Policy_WebBrowserControl_7_IZ_Partname1206)
            {
                $complexDeviceSettings.Add('IZ_Policy_WebBrowserControl_7_IZ_Partname1206', $policySettings.DeviceSettings.iZ_Policy_WebBrowserControl_7_IZ_Partname1206)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_Policy_AllowScriptlets_7)
            {
                $complexDeviceSettings.Add('IZ_Policy_AllowScriptlets_7', $policySettings.DeviceSettings.iZ_Policy_AllowScriptlets_7)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_Policy_AllowScriptlets_7_IZ_Partname1209)
            {
                $complexDeviceSettings.Add('IZ_Policy_AllowScriptlets_7_IZ_Partname1209', $policySettings.DeviceSettings.iZ_Policy_AllowScriptlets_7_IZ_Partname1209)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_Policy_ScriptStatusBar_7)
            {
                $complexDeviceSettings.Add('IZ_Policy_ScriptStatusBar_7', $policySettings.DeviceSettings.iZ_Policy_ScriptStatusBar_7)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_Policy_ScriptStatusBar_7_IZ_Partname2103)
            {
                $complexDeviceSettings.Add('IZ_Policy_ScriptStatusBar_7_IZ_Partname2103', $policySettings.DeviceSettings.iZ_Policy_ScriptStatusBar_7_IZ_Partname2103)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_PolicyAllowVBScript_7)
            {
                $complexDeviceSettings.Add('IZ_PolicyAllowVBScript_7', $policySettings.DeviceSettings.iZ_PolicyAllowVBScript_7)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_PolicyAllowVBScript_7_IZ_Partname140C)
            {
                $complexDeviceSettings.Add('IZ_PolicyAllowVBScript_7_IZ_Partname140C', $policySettings.DeviceSettings.iZ_PolicyAllowVBScript_7_IZ_Partname140C)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_PolicyNotificationBarDownloadURLaction_7)
            {
                $complexDeviceSettings.Add('IZ_PolicyNotificationBarDownloadURLaction_7', $policySettings.DeviceSettings.iZ_PolicyNotificationBarDownloadURLaction_7)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_PolicyNotificationBarDownloadURLaction_7_IZ_Partname2200)
            {
                $complexDeviceSettings.Add('IZ_PolicyNotificationBarDownloadURLaction_7_IZ_Partname2200', $policySettings.DeviceSettings.iZ_PolicyNotificationBarDownloadURLaction_7_IZ_Partname2200)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_PolicyAntiMalwareCheckingOfActiveXControls_7)
            {
                $complexDeviceSettings.Add('IZ_PolicyAntiMalwareCheckingOfActiveXControls_7', $policySettings.DeviceSettings.iZ_PolicyAntiMalwareCheckingOfActiveXControls_7)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_PolicyAntiMalwareCheckingOfActiveXControls_7_IZ_Partname270C)
            {
                $complexDeviceSettings.Add('IZ_PolicyAntiMalwareCheckingOfActiveXControls_7_IZ_Partname270C', $policySettings.DeviceSettings.iZ_PolicyAntiMalwareCheckingOfActiveXControls_7_IZ_Partname270C)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_PolicyDownloadSignedActiveX_7)
            {
                $complexDeviceSettings.Add('IZ_PolicyDownloadSignedActiveX_7', $policySettings.DeviceSettings.iZ_PolicyDownloadSignedActiveX_7)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_PolicyDownloadSignedActiveX_7_IZ_Partname1001)
            {
                $complexDeviceSettings.Add('IZ_PolicyDownloadSignedActiveX_7_IZ_Partname1001', $policySettings.DeviceSettings.iZ_PolicyDownloadSignedActiveX_7_IZ_Partname1001)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_PolicyDownloadUnsignedActiveX_7)
            {
                $complexDeviceSettings.Add('IZ_PolicyDownloadUnsignedActiveX_7', $policySettings.DeviceSettings.iZ_PolicyDownloadUnsignedActiveX_7)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_PolicyDownloadUnsignedActiveX_7_IZ_Partname1004)
            {
                $complexDeviceSettings.Add('IZ_PolicyDownloadUnsignedActiveX_7_IZ_Partname1004', $policySettings.DeviceSettings.iZ_PolicyDownloadUnsignedActiveX_7_IZ_Partname1004)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_PolicyDragDropAcrossDomainsAcrossWindows_Both_Restricted)
            {
                $complexDeviceSettings.Add('IZ_PolicyDragDropAcrossDomainsAcrossWindows_Both_Restricted', $policySettings.DeviceSettings.iZ_PolicyDragDropAcrossDomainsAcrossWindows_Both_Restricted)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_PolicyDragDropAcrossDomainsAcrossWindows_Both_Restricted_IZ_Partname2709)
            {
                $complexDeviceSettings.Add('IZ_PolicyDragDropAcrossDomainsAcrossWindows_Both_Restricted_IZ_Partname2709', $policySettings.DeviceSettings.iZ_PolicyDragDropAcrossDomainsAcrossWindows_Both_Restricted_IZ_Partname2709)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_PolicyDragDropAcrossDomainsWithinWindow_Both_Restricted)
            {
                $complexDeviceSettings.Add('IZ_PolicyDragDropAcrossDomainsWithinWindow_Both_Restricted', $policySettings.DeviceSettings.iZ_PolicyDragDropAcrossDomainsWithinWindow_Both_Restricted)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_PolicyDragDropAcrossDomainsWithinWindow_Both_Restricted_IZ_Partname2708)
            {
                $complexDeviceSettings.Add('IZ_PolicyDragDropAcrossDomainsWithinWindow_Both_Restricted_IZ_Partname2708', $policySettings.DeviceSettings.iZ_PolicyDragDropAcrossDomainsWithinWindow_Both_Restricted_IZ_Partname2708)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_Policy_LocalPathForUpload_7)
            {
                $complexDeviceSettings.Add('IZ_Policy_LocalPathForUpload_7', $policySettings.DeviceSettings.iZ_Policy_LocalPathForUpload_7)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_Policy_LocalPathForUpload_7_IZ_Partname160A)
            {
                $complexDeviceSettings.Add('IZ_Policy_LocalPathForUpload_7_IZ_Partname160A', $policySettings.DeviceSettings.iZ_Policy_LocalPathForUpload_7_IZ_Partname160A)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_PolicyScriptActiveXNotMarkedSafe_7)
            {
                $complexDeviceSettings.Add('IZ_PolicyScriptActiveXNotMarkedSafe_7', $policySettings.DeviceSettings.iZ_PolicyScriptActiveXNotMarkedSafe_7)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_PolicyScriptActiveXNotMarkedSafe_7_IZ_Partname1201)
            {
                $complexDeviceSettings.Add('IZ_PolicyScriptActiveXNotMarkedSafe_7_IZ_Partname1201', $policySettings.DeviceSettings.iZ_PolicyScriptActiveXNotMarkedSafe_7_IZ_Partname1201)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_PolicyJavaPermissions_7)
            {
                $complexDeviceSettings.Add('IZ_PolicyJavaPermissions_7', $policySettings.DeviceSettings.iZ_PolicyJavaPermissions_7)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_PolicyJavaPermissions_7_IZ_Partname1C00)
            {
                $complexDeviceSettings.Add('IZ_PolicyJavaPermissions_7_IZ_Partname1C00', $policySettings.DeviceSettings.iZ_PolicyJavaPermissions_7_IZ_Partname1C00)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_PolicyLaunchAppsAndFilesInIFRAME_7)
            {
                $complexDeviceSettings.Add('IZ_PolicyLaunchAppsAndFilesInIFRAME_7', $policySettings.DeviceSettings.iZ_PolicyLaunchAppsAndFilesInIFRAME_7)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_PolicyLaunchAppsAndFilesInIFRAME_7_IZ_Partname1804)
            {
                $complexDeviceSettings.Add('IZ_PolicyLaunchAppsAndFilesInIFRAME_7_IZ_Partname1804', $policySettings.DeviceSettings.iZ_PolicyLaunchAppsAndFilesInIFRAME_7_IZ_Partname1804)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_PolicyLogon_7)
            {
                $complexDeviceSettings.Add('IZ_PolicyLogon_7', $policySettings.DeviceSettings.iZ_PolicyLogon_7)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_PolicyLogon_7_IZ_Partname1A00)
            {
                $complexDeviceSettings.Add('IZ_PolicyLogon_7_IZ_Partname1A00', $policySettings.DeviceSettings.iZ_PolicyLogon_7_IZ_Partname1A00)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_PolicyNavigateSubframesAcrossDomains_7)
            {
                $complexDeviceSettings.Add('IZ_PolicyNavigateSubframesAcrossDomains_7', $policySettings.DeviceSettings.iZ_PolicyNavigateSubframesAcrossDomains_7)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_PolicyNavigateSubframesAcrossDomains_7_IZ_Partname1607)
            {
                $complexDeviceSettings.Add('IZ_PolicyNavigateSubframesAcrossDomains_7_IZ_Partname1607', $policySettings.DeviceSettings.iZ_PolicyNavigateSubframesAcrossDomains_7_IZ_Partname1607)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_PolicyUnsignedFrameworkComponentsURLaction_7)
            {
                $complexDeviceSettings.Add('IZ_PolicyUnsignedFrameworkComponentsURLaction_7', $policySettings.DeviceSettings.iZ_PolicyUnsignedFrameworkComponentsURLaction_7)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_PolicyUnsignedFrameworkComponentsURLaction_7_IZ_Partname2004)
            {
                $complexDeviceSettings.Add('IZ_PolicyUnsignedFrameworkComponentsURLaction_7_IZ_Partname2004', $policySettings.DeviceSettings.iZ_PolicyUnsignedFrameworkComponentsURLaction_7_IZ_Partname2004)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_PolicySignedFrameworkComponentsURLaction_7)
            {
                $complexDeviceSettings.Add('IZ_PolicySignedFrameworkComponentsURLaction_7', $policySettings.DeviceSettings.iZ_PolicySignedFrameworkComponentsURLaction_7)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_PolicySignedFrameworkComponentsURLaction_7_IZ_Partname2001)
            {
                $complexDeviceSettings.Add('IZ_PolicySignedFrameworkComponentsURLaction_7_IZ_Partname2001', $policySettings.DeviceSettings.iZ_PolicySignedFrameworkComponentsURLaction_7_IZ_Partname2001)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_PolicyRunActiveXControls_7)
            {
                $complexDeviceSettings.Add('IZ_PolicyRunActiveXControls_7', $policySettings.DeviceSettings.iZ_PolicyRunActiveXControls_7)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_Partname1200)
            {
                $complexDeviceSettings.Add('IZ_Partname1200', $policySettings.DeviceSettings.iZ_Partname1200)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_PolicyScriptActiveXMarkedSafe_7)
            {
                $complexDeviceSettings.Add('IZ_PolicyScriptActiveXMarkedSafe_7', $policySettings.DeviceSettings.iZ_PolicyScriptActiveXMarkedSafe_7)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_Partname1405)
            {
                $complexDeviceSettings.Add('IZ_Partname1405', $policySettings.DeviceSettings.iZ_Partname1405)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_PolicyScriptingOfJavaApplets_7)
            {
                $complexDeviceSettings.Add('IZ_PolicyScriptingOfJavaApplets_7', $policySettings.DeviceSettings.iZ_PolicyScriptingOfJavaApplets_7)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_Partname1402)
            {
                $complexDeviceSettings.Add('IZ_Partname1402', $policySettings.DeviceSettings.iZ_Partname1402)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_Policy_UnsafeFiles_7)
            {
                $complexDeviceSettings.Add('IZ_Policy_UnsafeFiles_7', $policySettings.DeviceSettings.iZ_Policy_UnsafeFiles_7)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_Policy_UnsafeFiles_7_IZ_Partname1806)
            {
                $complexDeviceSettings.Add('IZ_Policy_UnsafeFiles_7_IZ_Partname1806', $policySettings.DeviceSettings.iZ_Policy_UnsafeFiles_7_IZ_Partname1806)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_PolicyTurnOnXSSFilter_Both_Restricted)
            {
                $complexDeviceSettings.Add('IZ_PolicyTurnOnXSSFilter_Both_Restricted', $policySettings.DeviceSettings.iZ_PolicyTurnOnXSSFilter_Both_Restricted)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_PolicyTurnOnXSSFilter_Both_Restricted_IZ_Partname1409)
            {
                $complexDeviceSettings.Add('IZ_PolicyTurnOnXSSFilter_Both_Restricted_IZ_Partname1409', $policySettings.DeviceSettings.iZ_PolicyTurnOnXSSFilter_Both_Restricted_IZ_Partname1409)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_Policy_TurnOnProtectedMode_7)
            {
                $complexDeviceSettings.Add('IZ_Policy_TurnOnProtectedMode_7', $policySettings.DeviceSettings.iZ_Policy_TurnOnProtectedMode_7)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_Policy_TurnOnProtectedMode_7_IZ_Partname2500)
            {
                $complexDeviceSettings.Add('IZ_Policy_TurnOnProtectedMode_7_IZ_Partname2500', $policySettings.DeviceSettings.iZ_Policy_TurnOnProtectedMode_7_IZ_Partname2500)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_Policy_Phishing_7)
            {
                $complexDeviceSettings.Add('IZ_Policy_Phishing_7', $policySettings.DeviceSettings.iZ_Policy_Phishing_7)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_Policy_Phishing_7_IZ_Partname2301)
            {
                $complexDeviceSettings.Add('IZ_Policy_Phishing_7_IZ_Partname2301', $policySettings.DeviceSettings.iZ_Policy_Phishing_7_IZ_Partname2301)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_PolicyBlockPopupWindows_7)
            {
                $complexDeviceSettings.Add('IZ_PolicyBlockPopupWindows_7', $policySettings.DeviceSettings.iZ_PolicyBlockPopupWindows_7)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_PolicyBlockPopupWindows_7_IZ_Partname1809)
            {
                $complexDeviceSettings.Add('IZ_PolicyBlockPopupWindows_7_IZ_Partname1809', $policySettings.DeviceSettings.iZ_PolicyBlockPopupWindows_7_IZ_Partname1809)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_PolicyUserdataPersistence_7)
            {
                $complexDeviceSettings.Add('IZ_PolicyUserdataPersistence_7', $policySettings.DeviceSettings.iZ_PolicyUserdataPersistence_7)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_PolicyUserdataPersistence_7_IZ_Partname1606)
            {
                $complexDeviceSettings.Add('IZ_PolicyUserdataPersistence_7_IZ_Partname1606', $policySettings.DeviceSettings.iZ_PolicyUserdataPersistence_7_IZ_Partname1606)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_PolicyZoneElevationURLaction_7)
            {
                $complexDeviceSettings.Add('IZ_PolicyZoneElevationURLaction_7', $policySettings.DeviceSettings.iZ_PolicyZoneElevationURLaction_7)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_PolicyZoneElevationURLaction_7_IZ_Partname2101)
            {
                $complexDeviceSettings.Add('IZ_PolicyZoneElevationURLaction_7_IZ_Partname2101', $policySettings.DeviceSettings.iZ_PolicyZoneElevationURLaction_7_IZ_Partname2101)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_PolicyAntiMalwareCheckingOfActiveXControls_5)
            {
                $complexDeviceSettings.Add('IZ_PolicyAntiMalwareCheckingOfActiveXControls_5', $policySettings.DeviceSettings.iZ_PolicyAntiMalwareCheckingOfActiveXControls_5)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_PolicyAntiMalwareCheckingOfActiveXControls_5_IZ_Partname270C)
            {
                $complexDeviceSettings.Add('IZ_PolicyAntiMalwareCheckingOfActiveXControls_5_IZ_Partname270C', $policySettings.DeviceSettings.iZ_PolicyAntiMalwareCheckingOfActiveXControls_5_IZ_Partname270C)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_PolicyScriptActiveXNotMarkedSafe_5)
            {
                $complexDeviceSettings.Add('IZ_PolicyScriptActiveXNotMarkedSafe_5', $policySettings.DeviceSettings.iZ_PolicyScriptActiveXNotMarkedSafe_5)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_PolicyScriptActiveXNotMarkedSafe_5_IZ_Partname1201)
            {
                $complexDeviceSettings.Add('IZ_PolicyScriptActiveXNotMarkedSafe_5_IZ_Partname1201', $policySettings.DeviceSettings.iZ_PolicyScriptActiveXNotMarkedSafe_5_IZ_Partname1201)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_PolicyJavaPermissions_5)
            {
                $complexDeviceSettings.Add('IZ_PolicyJavaPermissions_5', $policySettings.DeviceSettings.iZ_PolicyJavaPermissions_5)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_PolicyJavaPermissions_5_IZ_Partname1C00)
            {
                $complexDeviceSettings.Add('IZ_PolicyJavaPermissions_5_IZ_Partname1C00', $policySettings.DeviceSettings.iZ_PolicyJavaPermissions_5_IZ_Partname1C00)
            }
            if ($null -ne $policySettings.DeviceSettings.iZ_PolicyWarnCertMismatch)
            {
                $complexDeviceSettings.Add('IZ_PolicyWarnCertMismatch', $policySettings.DeviceSettings.iZ_PolicyWarnCertMismatch)
            }
            if ($null -ne $policySettings.DeviceSettings.disableSafetyFilterOverride)
            {
                $complexDeviceSettings.Add('DisableSafetyFilterOverride', $policySettings.DeviceSettings.disableSafetyFilterOverride)
            }
            if ($null -ne $policySettings.DeviceSettings.disableSafetyFilterOverrideForAppRepUnknown)
            {
                $complexDeviceSettings.Add('DisableSafetyFilterOverrideForAppRepUnknown', $policySettings.DeviceSettings.disableSafetyFilterOverrideForAppRepUnknown)
            }
            if ($null -ne $policySettings.DeviceSettings.disable_Managing_Safety_Filter_IE9)
            {
                $complexDeviceSettings.Add('Disable_Managing_Safety_Filter_IE9', $policySettings.DeviceSettings.disable_Managing_Safety_Filter_IE9)
            }
            if ($null -ne $policySettings.DeviceSettings.iE9SafetyFilterOptions)
            {
                $complexDeviceSettings.Add('IE9SafetyFilterOptions', $policySettings.DeviceSettings.iE9SafetyFilterOptions)
            }
            if ($null -ne $policySettings.DeviceSettings.disablePerUserActiveXInstall)
            {
                $complexDeviceSettings.Add('DisablePerUserActiveXInstall', $policySettings.DeviceSettings.disablePerUserActiveXInstall)
            }
            if ($null -ne $policySettings.DeviceSettings.verMgmtDisableRunThisTime)
            {
                $complexDeviceSettings.Add('VerMgmtDisableRunThisTime', $policySettings.DeviceSettings.verMgmtDisableRunThisTime)
            }
            if ($null -ne $policySettings.DeviceSettings.verMgmtDisable)
            {
                $complexDeviceSettings.Add('VerMgmtDisable', $policySettings.DeviceSettings.verMgmtDisable)
            }
            if ($null -ne $policySettings.DeviceSettings.advanced_EnableSSL3Fallback)
            {
                $complexDeviceSettings.Add('Advanced_EnableSSL3Fallback', $policySettings.DeviceSettings.advanced_EnableSSL3Fallback)
            }
            if ($null -ne $policySettings.DeviceSettings.advanced_EnableSSL3FallbackOptions)
            {
                $complexDeviceSettings.Add('Advanced_EnableSSL3FallbackOptions', $policySettings.DeviceSettings.advanced_EnableSSL3FallbackOptions)
            }
            if ($null -ne $policySettings.DeviceSettings.iESF_PolicyExplorerProcesses_5)
            {
                $complexDeviceSettings.Add('IESF_PolicyExplorerProcesses_5', $policySettings.DeviceSettings.iESF_PolicyExplorerProcesses_5)
            }
            if ($null -ne $policySettings.DeviceSettings.iESF_PolicyExplorerProcesses_6)
            {
                $complexDeviceSettings.Add('IESF_PolicyExplorerProcesses_6', $policySettings.DeviceSettings.iESF_PolicyExplorerProcesses_6)
            }
            if ($null -ne $policySettings.DeviceSettings.iESF_PolicyExplorerProcesses_3)
            {
                $complexDeviceSettings.Add('IESF_PolicyExplorerProcesses_3', $policySettings.DeviceSettings.iESF_PolicyExplorerProcesses_3)
            }
            if ($null -ne $policySettings.DeviceSettings.iESF_PolicyExplorerProcesses_10)
            {
                $complexDeviceSettings.Add('IESF_PolicyExplorerProcesses_10', $policySettings.DeviceSettings.iESF_PolicyExplorerProcesses_10)
            }
            if ($null -ne $policySettings.DeviceSettings.iESF_PolicyExplorerProcesses_9)
            {
                $complexDeviceSettings.Add('IESF_PolicyExplorerProcesses_9', $policySettings.DeviceSettings.iESF_PolicyExplorerProcesses_9)
            }
            if ($null -ne $policySettings.DeviceSettings.iESF_PolicyExplorerProcesses_11)
            {
                $complexDeviceSettings.Add('IESF_PolicyExplorerProcesses_11', $policySettings.DeviceSettings.iESF_PolicyExplorerProcesses_11)
            }
            if ($null -ne $policySettings.DeviceSettings.iESF_PolicyExplorerProcesses_12)
            {
                $complexDeviceSettings.Add('IESF_PolicyExplorerProcesses_12', $policySettings.DeviceSettings.iESF_PolicyExplorerProcesses_12)
            }
            if ($null -ne $policySettings.DeviceSettings.iESF_PolicyExplorerProcesses_8)
            {
                $complexDeviceSettings.Add('IESF_PolicyExplorerProcesses_8', $policySettings.DeviceSettings.iESF_PolicyExplorerProcesses_8)
            }
            if ($null -ne $policySettings.DeviceSettings.security_zones_map_edit)
            {
                $complexDeviceSettings.Add('Security_zones_map_edit', $policySettings.DeviceSettings.security_zones_map_edit)
            }
            if ($null -ne $policySettings.DeviceSettings.security_options_edit)
            {
                $complexDeviceSettings.Add('Security_options_edit', $policySettings.DeviceSettings.security_options_edit)
            }
            if ($null -ne $policySettings.DeviceSettings.security_HKLM_only)
            {
                $complexDeviceSettings.Add('Security_HKLM_only', $policySettings.DeviceSettings.security_HKLM_only)
            }
            if ($null -ne $policySettings.DeviceSettings.onlyUseAXISForActiveXInstall)
            {
                $complexDeviceSettings.Add('OnlyUseAXISForActiveXInstall', $policySettings.DeviceSettings.onlyUseAXISForActiveXInstall)
            }
            if ($null -ne $policySettings.DeviceSettings.addonManagement_RestrictCrashDetection)
            {
                $complexDeviceSettings.Add('AddonManagement_RestrictCrashDetection', $policySettings.DeviceSettings.addonManagement_RestrictCrashDetection)
            }
            if ($null -ne $policySettings.DeviceSettings.disable_Security_Settings_Check)
            {
                $complexDeviceSettings.Add('Disable_Security_Settings_Check', $policySettings.DeviceSettings.disable_Security_Settings_Check)
            }
            if ($null -ne $policySettings.DeviceSettings.disableBlockAtFirstSeen)
            {
                $complexDeviceSettings.Add('DisableBlockAtFirstSeen', $policySettings.DeviceSettings.disableBlockAtFirstSeen)
            }
            if ($null -ne $policySettings.DeviceSettings.realtimeProtection_DisableScanOnRealtimeEnable)
            {
                $complexDeviceSettings.Add('RealtimeProtection_DisableScanOnRealtimeEnable', $policySettings.DeviceSettings.realtimeProtection_DisableScanOnRealtimeEnable)
            }
            if ($null -ne $policySettings.DeviceSettings.scan_DisablePackedExeScanning)
            {
                $complexDeviceSettings.Add('Scan_DisablePackedExeScanning', $policySettings.DeviceSettings.scan_DisablePackedExeScanning)
            }
            if ($null -ne $policySettings.DeviceSettings.disableRoutinelyTakingAction)
            {
                $complexDeviceSettings.Add('DisableRoutinelyTakingAction', $policySettings.DeviceSettings.disableRoutinelyTakingAction)
            }
            if ($null -ne $policySettings.DeviceSettings.tS_CLIENT_DISABLE_PASSWORD_SAVING_2)
            {
                $complexDeviceSettings.Add('TS_CLIENT_DISABLE_PASSWORD_SAVING_2', $policySettings.DeviceSettings.tS_CLIENT_DISABLE_PASSWORD_SAVING_2)
            }
            if ($null -ne $policySettings.DeviceSettings.tS_CLIENT_DRIVE_M)
            {
                $complexDeviceSettings.Add('TS_CLIENT_DRIVE_M', $policySettings.DeviceSettings.tS_CLIENT_DRIVE_M)
            }
            if ($null -ne $policySettings.DeviceSettings.tS_PASSWORD)
            {
                $complexDeviceSettings.Add('TS_PASSWORD', $policySettings.DeviceSettings.tS_PASSWORD)
            }
            if ($null -ne $policySettings.DeviceSettings.tS_RPC_ENCRYPTION)
            {
                $complexDeviceSettings.Add('TS_RPC_ENCRYPTION', $policySettings.DeviceSettings.tS_RPC_ENCRYPTION)
            }
            if ($null -ne $policySettings.DeviceSettings.tS_ENCRYPTION_POLICY)
            {
                $complexDeviceSettings.Add('TS_ENCRYPTION_POLICY', $policySettings.DeviceSettings.tS_ENCRYPTION_POLICY)
            }
            if ($null -ne $policySettings.DeviceSettings.tS_ENCRYPTION_LEVEL)
            {
                $complexDeviceSettings.Add('TS_ENCRYPTION_LEVEL', $policySettings.DeviceSettings.tS_ENCRYPTION_LEVEL)
            }
            if ($null -ne $policySettings.DeviceSettings.disable_Downloading_of_Enclosures)
            {
                $complexDeviceSettings.Add('Disable_Downloading_of_Enclosures', $policySettings.DeviceSettings.disable_Downloading_of_Enclosures)
            }
            if ($null -ne $policySettings.DeviceSettings.automaticRestartSignOn)
            {
                $complexDeviceSettings.Add('AutomaticRestartSignOn', $policySettings.DeviceSettings.automaticRestartSignOn)
            }
            if ($null -ne $policySettings.DeviceSettings.enableScriptBlockLogging)
            {
                $complexDeviceSettings.Add('EnableScriptBlockLogging', $policySettings.DeviceSettings.enableScriptBlockLogging)
            }
            if ($null -ne $policySettings.DeviceSettings.enableScriptBlockInvocationLogging)
            {
                $complexDeviceSettings.Add('EnableScriptBlockInvocationLogging', $policySettings.DeviceSettings.enableScriptBlockInvocationLogging)
            }
            if ($null -ne $policySettings.DeviceSettings.allowBasic_2)
            {
                $complexDeviceSettings.Add('AllowBasic_2', $policySettings.DeviceSettings.allowBasic_2)
            }
            if ($null -ne $policySettings.DeviceSettings.allowUnencrypted_2)
            {
                $complexDeviceSettings.Add('AllowUnencrypted_2', $policySettings.DeviceSettings.allowUnencrypted_2)
            }
            if ($null -ne $policySettings.DeviceSettings.disallowDigest)
            {
                $complexDeviceSettings.Add('DisallowDigest', $policySettings.DeviceSettings.disallowDigest)
            }
            if ($null -ne $policySettings.DeviceSettings.allowBasic_1)
            {
                $complexDeviceSettings.Add('AllowBasic_1', $policySettings.DeviceSettings.allowBasic_1)
            }
            if ($null -ne $policySettings.DeviceSettings.allowUnencrypted_1)
            {
                $complexDeviceSettings.Add('AllowUnencrypted_1', $policySettings.DeviceSettings.allowUnencrypted_1)
            }
            if ($null -ne $policySettings.DeviceSettings.disableRunAs)
            {
                $complexDeviceSettings.Add('DisableRunAs', $policySettings.DeviceSettings.disableRunAs)
            }
            if ($null -ne $policySettings.DeviceSettings.accountLogon_AuditCredentialValidation)
            {
                $complexDeviceSettings.Add('AccountLogon_AuditCredentialValidation', $policySettings.DeviceSettings.accountLogon_AuditCredentialValidation)
            }
            if ($null -ne $policySettings.DeviceSettings.accountLogonLogoff_AuditAccountLockout)
            {
                $complexDeviceSettings.Add('AccountLogonLogoff_AuditAccountLockout', $policySettings.DeviceSettings.accountLogonLogoff_AuditAccountLockout)
            }
            if ($null -ne $policySettings.DeviceSettings.accountLogonLogoff_AuditGroupMembership)
            {
                $complexDeviceSettings.Add('AccountLogonLogoff_AuditGroupMembership', $policySettings.DeviceSettings.accountLogonLogoff_AuditGroupMembership)
            }
            if ($null -ne $policySettings.DeviceSettings.accountLogonLogoff_AuditLogon)
            {
                $complexDeviceSettings.Add('AccountLogonLogoff_AuditLogon', $policySettings.DeviceSettings.accountLogonLogoff_AuditLogon)
            }
            if ($null -ne $policySettings.DeviceSettings.policyChange_AuditAuthenticationPolicyChange)
            {
                $complexDeviceSettings.Add('PolicyChange_AuditAuthenticationPolicyChange', $policySettings.DeviceSettings.policyChange_AuditAuthenticationPolicyChange)
            }
            if ($null -ne $policySettings.DeviceSettings.policyChange_AuditPolicyChange)
            {
                $complexDeviceSettings.Add('PolicyChange_AuditPolicyChange', $policySettings.DeviceSettings.policyChange_AuditPolicyChange)
            }
            if ($null -ne $policySettings.DeviceSettings.objectAccess_AuditFileShare)
            {
                $complexDeviceSettings.Add('ObjectAccess_AuditFileShare', $policySettings.DeviceSettings.objectAccess_AuditFileShare)
            }
            if ($null -ne $policySettings.DeviceSettings.accountLogonLogoff_AuditOtherLogonLogoffEvents)
            {
                $complexDeviceSettings.Add('AccountLogonLogoff_AuditOtherLogonLogoffEvents', $policySettings.DeviceSettings.accountLogonLogoff_AuditOtherLogonLogoffEvents)
            }
            if ($null -ne $policySettings.DeviceSettings.accountManagement_AuditSecurityGroupManagement)
            {
                $complexDeviceSettings.Add('AccountManagement_AuditSecurityGroupManagement', $policySettings.DeviceSettings.accountManagement_AuditSecurityGroupManagement)
            }
            if ($null -ne $policySettings.DeviceSettings.system_AuditSecuritySystemExtension)
            {
                $complexDeviceSettings.Add('System_AuditSecuritySystemExtension', $policySettings.DeviceSettings.system_AuditSecuritySystemExtension)
            }
            if ($null -ne $policySettings.DeviceSettings.accountLogonLogoff_AuditSpecialLogon)
            {
                $complexDeviceSettings.Add('AccountLogonLogoff_AuditSpecialLogon', $policySettings.DeviceSettings.accountLogonLogoff_AuditSpecialLogon)
            }
            if ($null -ne $policySettings.DeviceSettings.accountManagement_AuditUserAccountManagement)
            {
                $complexDeviceSettings.Add('AccountManagement_AuditUserAccountManagement', $policySettings.DeviceSettings.accountManagement_AuditUserAccountManagement)
            }
            if ($null -ne $policySettings.DeviceSettings.detailedTracking_AuditPNPActivity)
            {
                $complexDeviceSettings.Add('DetailedTracking_AuditPNPActivity', $policySettings.DeviceSettings.detailedTracking_AuditPNPActivity)
            }
            if ($null -ne $policySettings.DeviceSettings.detailedTracking_AuditProcessCreation)
            {
                $complexDeviceSettings.Add('DetailedTracking_AuditProcessCreation', $policySettings.DeviceSettings.detailedTracking_AuditProcessCreation)
            }
            if ($null -ne $policySettings.DeviceSettings.objectAccess_AuditDetailedFileShare)
            {
                $complexDeviceSettings.Add('ObjectAccess_AuditDetailedFileShare', $policySettings.DeviceSettings.objectAccess_AuditDetailedFileShare)
            }
            if ($null -ne $policySettings.DeviceSettings.objectAccess_AuditOtherObjectAccessEvents)
            {
                $complexDeviceSettings.Add('ObjectAccess_AuditOtherObjectAccessEvents', $policySettings.DeviceSettings.objectAccess_AuditOtherObjectAccessEvents)
            }
            if ($null -ne $policySettings.DeviceSettings.objectAccess_AuditRemovableStorage)
            {
                $complexDeviceSettings.Add('ObjectAccess_AuditRemovableStorage', $policySettings.DeviceSettings.objectAccess_AuditRemovableStorage)
            }
            if ($null -ne $policySettings.DeviceSettings.policyChange_AuditMPSSVCRuleLevelPolicyChange)
            {
                $complexDeviceSettings.Add('PolicyChange_AuditMPSSVCRuleLevelPolicyChange', $policySettings.DeviceSettings.policyChange_AuditMPSSVCRuleLevelPolicyChange)
            }
            if ($null -ne $policySettings.DeviceSettings.policyChange_AuditOtherPolicyChangeEvents)
            {
                $complexDeviceSettings.Add('PolicyChange_AuditOtherPolicyChangeEvents', $policySettings.DeviceSettings.policyChange_AuditOtherPolicyChangeEvents)
            }
            if ($null -ne $policySettings.DeviceSettings.privilegeUse_AuditSensitivePrivilegeUse)
            {
                $complexDeviceSettings.Add('PrivilegeUse_AuditSensitivePrivilegeUse', $policySettings.DeviceSettings.privilegeUse_AuditSensitivePrivilegeUse)
            }
            if ($null -ne $policySettings.DeviceSettings.system_AuditOtherSystemEvents)
            {
                $complexDeviceSettings.Add('System_AuditOtherSystemEvents', $policySettings.DeviceSettings.system_AuditOtherSystemEvents)
            }
            if ($null -ne $policySettings.DeviceSettings.system_AuditSecurityStateChange)
            {
                $complexDeviceSettings.Add('System_AuditSecurityStateChange', $policySettings.DeviceSettings.system_AuditSecurityStateChange)
            }
            if ($null -ne $policySettings.DeviceSettings.system_AuditSystemIntegrity)
            {
                $complexDeviceSettings.Add('System_AuditSystemIntegrity', $policySettings.DeviceSettings.system_AuditSystemIntegrity)
            }
            if ($null -ne $policySettings.DeviceSettings.allowDirectMemoryAccess)
            {
                $complexDeviceSettings.Add('AllowDirectMemoryAccess', $policySettings.DeviceSettings.allowDirectMemoryAccess)
            }
            if ($null -ne $policySettings.DeviceSettings.allowArchiveScanning)
            {
                $complexDeviceSettings.Add('AllowArchiveScanning', $policySettings.DeviceSettings.allowArchiveScanning)
            }
            if ($null -ne $policySettings.DeviceSettings.allowBehaviorMonitoring)
            {
                $complexDeviceSettings.Add('AllowBehaviorMonitoring', $policySettings.DeviceSettings.allowBehaviorMonitoring)
            }
            if ($null -ne $policySettings.DeviceSettings.allowCloudProtection)
            {
                $complexDeviceSettings.Add('AllowCloudProtection', $policySettings.DeviceSettings.allowCloudProtection)
            }
            if ($null -ne $policySettings.DeviceSettings.allowFullScanRemovableDriveScanning)
            {
                $complexDeviceSettings.Add('AllowFullScanRemovableDriveScanning', $policySettings.DeviceSettings.allowFullScanRemovableDriveScanning)
            }
            if ($null -ne $policySettings.DeviceSettings.allowOnAccessProtection)
            {
                $complexDeviceSettings.Add('AllowOnAccessProtection', $policySettings.DeviceSettings.allowOnAccessProtection)
            }
            if ($null -ne $policySettings.DeviceSettings.allowRealtimeMonitoring)
            {
                $complexDeviceSettings.Add('AllowRealtimeMonitoring', $policySettings.DeviceSettings.allowRealtimeMonitoring)
            }
            if ($null -ne $policySettings.DeviceSettings.allowIOAVProtection)
            {
                $complexDeviceSettings.Add('AllowIOAVProtection', $policySettings.DeviceSettings.allowIOAVProtection)
            }
            if ($null -ne $policySettings.DeviceSettings.allowScriptScanning)
            {
                $complexDeviceSettings.Add('AllowScriptScanning', $policySettings.DeviceSettings.allowScriptScanning)
            }
            if ($null -ne $policySettings.DeviceSettings.blockExecutionOfPotentiallyObfuscatedScripts)
            {
                $complexDeviceSettings.Add('BlockExecutionOfPotentiallyObfuscatedScripts', $policySettings.DeviceSettings.blockExecutionOfPotentiallyObfuscatedScripts)
            }
            if ($null -ne $policySettings.DeviceSettings.blockExecutionOfPotentiallyObfuscatedScripts_ASROnlyPerRuleExclusions)
            {
                $complexDeviceSettings.Add('BlockExecutionOfPotentiallyObfuscatedScripts_ASROnlyPerRuleExclusions', $policySettings.DeviceSettings.blockExecutionOfPotentiallyObfuscatedScripts_ASROnlyPerRuleExclusions)
            }
            if ($null -ne $policySettings.DeviceSettings.blockWin32APICallsFromOfficeMacros)
            {
                $complexDeviceSettings.Add('BlockWin32APICallsFromOfficeMacros', $policySettings.DeviceSettings.blockWin32APICallsFromOfficeMacros)
            }
            if ($null -ne $policySettings.DeviceSettings.blockWin32APICallsFromOfficeMacros_ASROnlyPerRuleExclusions)
            {
                $complexDeviceSettings.Add('BlockWin32APICallsFromOfficeMacros_ASROnlyPerRuleExclusions', $policySettings.DeviceSettings.blockWin32APICallsFromOfficeMacros_ASROnlyPerRuleExclusions)
            }
            if ($null -ne $policySettings.DeviceSettings.blockExecutableFilesRunningUnlessTheyMeetPrevalenceAgeTrustedListCriterion)
            {
                $complexDeviceSettings.Add('BlockExecutableFilesRunningUnlessTheyMeetPrevalenceAgeTrustedListCriterion', $policySettings.DeviceSettings.blockExecutableFilesRunningUnlessTheyMeetPrevalenceAgeTrustedListCriterion)
            }
            if ($null -ne $policySettings.DeviceSettings.blockExecutableFilesRunningUnlessTheyMeetPrevalenceAgeTrustedListCriterion_ASROnlyPerRuleExclusions)
            {
                $complexDeviceSettings.Add('BlockExecutableFilesRunningUnlessTheyMeetPrevalenceAgeTrustedListCriterion_ASROnlyPerRuleExclusions', $policySettings.DeviceSettings.blockExecutableFilesRunningUnlessTheyMeetPrevalenceAgeTrustedListCriterion_ASROnlyPerRuleExclusions)
            }
            if ($null -ne $policySettings.DeviceSettings.blockOfficeCommunicationAppFromCreatingChildProcesses)
            {
                $complexDeviceSettings.Add('BlockOfficeCommunicationAppFromCreatingChildProcesses', $policySettings.DeviceSettings.blockOfficeCommunicationAppFromCreatingChildProcesses)
            }
            if ($null -ne $policySettings.DeviceSettings.blockOfficeCommunicationAppFromCreatingChildProcesses_ASROnlyPerRuleExclusions)
            {
                $complexDeviceSettings.Add('BlockOfficeCommunicationAppFromCreatingChildProcesses_ASROnlyPerRuleExclusions', $policySettings.DeviceSettings.blockOfficeCommunicationAppFromCreatingChildProcesses_ASROnlyPerRuleExclusions)
            }
            if ($null -ne $policySettings.DeviceSettings.blockAllOfficeApplicationsFromCreatingChildProcesses)
            {
                $complexDeviceSettings.Add('BlockAllOfficeApplicationsFromCreatingChildProcesses', $policySettings.DeviceSettings.blockAllOfficeApplicationsFromCreatingChildProcesses)
            }
            if ($null -ne $policySettings.DeviceSettings.blockAllOfficeApplicationsFromCreatingChildProcesses_ASROnlyPerRuleExclusions)
            {
                $complexDeviceSettings.Add('BlockAllOfficeApplicationsFromCreatingChildProcesses_ASROnlyPerRuleExclusions', $policySettings.DeviceSettings.blockAllOfficeApplicationsFromCreatingChildProcesses_ASROnlyPerRuleExclusions)
            }
            if ($null -ne $policySettings.DeviceSettings.blockAdobeReaderFromCreatingChildProcesses)
            {
                $complexDeviceSettings.Add('BlockAdobeReaderFromCreatingChildProcesses', $policySettings.DeviceSettings.blockAdobeReaderFromCreatingChildProcesses)
            }
            if ($null -ne $policySettings.DeviceSettings.blockAdobeReaderFromCreatingChildProcesses_ASROnlyPerRuleExclusions)
            {
                $complexDeviceSettings.Add('BlockAdobeReaderFromCreatingChildProcesses_ASROnlyPerRuleExclusions', $policySettings.DeviceSettings.blockAdobeReaderFromCreatingChildProcesses_ASROnlyPerRuleExclusions)
            }
            if ($null -ne $policySettings.DeviceSettings.blockCredentialStealingFromWindowsLocalSecurityAuthoritySubsystem)
            {
                $complexDeviceSettings.Add('BlockCredentialStealingFromWindowsLocalSecurityAuthoritySubsystem', $policySettings.DeviceSettings.blockCredentialStealingFromWindowsLocalSecurityAuthoritySubsystem)
            }
            if ($null -ne $policySettings.DeviceSettings.blockCredentialStealingFromWindowsLocalSecurityAuthoritySubsystem_ASROnlyPerRuleExclusions)
            {
                $complexDeviceSettings.Add('BlockCredentialStealingFromWindowsLocalSecurityAuthoritySubsystem_ASROnlyPerRuleExclusions', $policySettings.DeviceSettings.blockCredentialStealingFromWindowsLocalSecurityAuthoritySubsystem_ASROnlyPerRuleExclusions)
            }
            if ($null -ne $policySettings.DeviceSettings.blockJavaScriptOrVBScriptFromLaunchingDownloadedExecutableContent)
            {
                $complexDeviceSettings.Add('BlockJavaScriptOrVBScriptFromLaunchingDownloadedExecutableContent', $policySettings.DeviceSettings.blockJavaScriptOrVBScriptFromLaunchingDownloadedExecutableContent)
            }
            if ($null -ne $policySettings.DeviceSettings.blockJavaScriptOrVBScriptFromLaunchingDownloadedExecutableContent_ASROnlyPerRuleExclusions)
            {
                $complexDeviceSettings.Add('BlockJavaScriptOrVBScriptFromLaunchingDownloadedExecutableContent_ASROnlyPerRuleExclusions', $policySettings.DeviceSettings.blockJavaScriptOrVBScriptFromLaunchingDownloadedExecutableContent_ASROnlyPerRuleExclusions)
            }
            if ($null -ne $policySettings.DeviceSettings.blockWebshellCreationForServers)
            {
                $complexDeviceSettings.Add('BlockWebshellCreationForServers', $policySettings.DeviceSettings.blockWebshellCreationForServers)
            }
            if ($null -ne $policySettings.DeviceSettings.blockWebshellCreationForServers_ASROnlyPerRuleExclusions)
            {
                $complexDeviceSettings.Add('BlockWebshellCreationForServers_ASROnlyPerRuleExclusions', $policySettings.DeviceSettings.blockWebshellCreationForServers_ASROnlyPerRuleExclusions)
            }
            if ($null -ne $policySettings.DeviceSettings.blockUntrustedUnsignedProcessesThatRunFromUSB)
            {
                $complexDeviceSettings.Add('BlockUntrustedUnsignedProcessesThatRunFromUSB', $policySettings.DeviceSettings.blockUntrustedUnsignedProcessesThatRunFromUSB)
            }
            if ($null -ne $policySettings.DeviceSettings.blockUntrustedUnsignedProcessesThatRunFromUSB_ASROnlyPerRuleExclusions)
            {
                $complexDeviceSettings.Add('BlockUntrustedUnsignedProcessesThatRunFromUSB_ASROnlyPerRuleExclusions', $policySettings.DeviceSettings.blockUntrustedUnsignedProcessesThatRunFromUSB_ASROnlyPerRuleExclusions)
            }
            if ($null -ne $policySettings.DeviceSettings.blockPersistenceThroughWMIEventSubscription)
            {
                $complexDeviceSettings.Add('BlockPersistenceThroughWMIEventSubscription', $policySettings.DeviceSettings.blockPersistenceThroughWMIEventSubscription)
            }
            if ($null -ne $policySettings.DeviceSettings.blockUseOfCopiedOrImpersonatedSystemTools)
            {
                $complexDeviceSettings.Add('BlockUseOfCopiedOrImpersonatedSystemTools', $policySettings.DeviceSettings.blockUseOfCopiedOrImpersonatedSystemTools)
            }
            if ($null -ne $policySettings.DeviceSettings.blockUseOfCopiedOrImpersonatedSystemTools_ASROnlyPerRuleExclusions)
            {
                $complexDeviceSettings.Add('BlockUseOfCopiedOrImpersonatedSystemTools_ASROnlyPerRuleExclusions', $policySettings.DeviceSettings.blockUseOfCopiedOrImpersonatedSystemTools_ASROnlyPerRuleExclusions)
            }
            if ($null -ne $policySettings.DeviceSettings.blockAbuseOfExploitedVulnerableSignedDrivers)
            {
                $complexDeviceSettings.Add('BlockAbuseOfExploitedVulnerableSignedDrivers', $policySettings.DeviceSettings.blockAbuseOfExploitedVulnerableSignedDrivers)
            }
            if ($null -ne $policySettings.DeviceSettings.blockAbuseOfExploitedVulnerableSignedDrivers_ASROnlyPerRuleExclusions)
            {
                $complexDeviceSettings.Add('BlockAbuseOfExploitedVulnerableSignedDrivers_ASROnlyPerRuleExclusions', $policySettings.DeviceSettings.blockAbuseOfExploitedVulnerableSignedDrivers_ASROnlyPerRuleExclusions)
            }
            if ($null -ne $policySettings.DeviceSettings.blockProcessCreationsFromPSExecAndWMICommands)
            {
                $complexDeviceSettings.Add('BlockProcessCreationsFromPSExecAndWMICommands', $policySettings.DeviceSettings.blockProcessCreationsFromPSExecAndWMICommands)
            }
            if ($null -ne $policySettings.DeviceSettings.blockProcessCreationsFromPSExecAndWMICommands_ASROnlyPerRuleExclusions)
            {
                $complexDeviceSettings.Add('BlockProcessCreationsFromPSExecAndWMICommands_ASROnlyPerRuleExclusions', $policySettings.DeviceSettings.blockProcessCreationsFromPSExecAndWMICommands_ASROnlyPerRuleExclusions)
            }
            if ($null -ne $policySettings.DeviceSettings.blockOfficeApplicationsFromCreatingExecutableContent)
            {
                $complexDeviceSettings.Add('BlockOfficeApplicationsFromCreatingExecutableContent', $policySettings.DeviceSettings.blockOfficeApplicationsFromCreatingExecutableContent)
            }
            if ($null -ne $policySettings.DeviceSettings.blockOfficeApplicationsFromCreatingExecutableContent_ASROnlyPerRuleExclusions)
            {
                $complexDeviceSettings.Add('BlockOfficeApplicationsFromCreatingExecutableContent_ASROnlyPerRuleExclusions', $policySettings.DeviceSettings.blockOfficeApplicationsFromCreatingExecutableContent_ASROnlyPerRuleExclusions)
            }
            if ($null -ne $policySettings.DeviceSettings.blockOfficeApplicationsFromInjectingCodeIntoOtherProcesses)
            {
                $complexDeviceSettings.Add('BlockOfficeApplicationsFromInjectingCodeIntoOtherProcesses', $policySettings.DeviceSettings.blockOfficeApplicationsFromInjectingCodeIntoOtherProcesses)
            }
            if ($null -ne $policySettings.DeviceSettings.blockOfficeApplicationsFromInjectingCodeIntoOtherProcesses_ASROnlyPerRuleExclusions)
            {
                $complexDeviceSettings.Add('BlockOfficeApplicationsFromInjectingCodeIntoOtherProcesses_ASROnlyPerRuleExclusions', $policySettings.DeviceSettings.blockOfficeApplicationsFromInjectingCodeIntoOtherProcesses_ASROnlyPerRuleExclusions)
            }
            if ($null -ne $policySettings.DeviceSettings.blockRebootingMachineInSafeMode)
            {
                $complexDeviceSettings.Add('BlockRebootingMachineInSafeMode', $policySettings.DeviceSettings.blockRebootingMachineInSafeMode)
            }
            if ($null -ne $policySettings.DeviceSettings.blockRebootingMachineInSafeMode_ASROnlyPerRuleExclusions)
            {
                $complexDeviceSettings.Add('BlockRebootingMachineInSafeMode_ASROnlyPerRuleExclusions', $policySettings.DeviceSettings.blockRebootingMachineInSafeMode_ASROnlyPerRuleExclusions)
            }
            if ($null -ne $policySettings.DeviceSettings.useAdvancedProtectionAgainstRansomware)
            {
                $complexDeviceSettings.Add('UseAdvancedProtectionAgainstRansomware', $policySettings.DeviceSettings.useAdvancedProtectionAgainstRansomware)
            }
            if ($null -ne $policySettings.DeviceSettings.useAdvancedProtectionAgainstRansomware_ASROnlyPerRuleExclusions)
            {
                $complexDeviceSettings.Add('UseAdvancedProtectionAgainstRansomware_ASROnlyPerRuleExclusions', $policySettings.DeviceSettings.useAdvancedProtectionAgainstRansomware_ASROnlyPerRuleExclusions)
            }
            if ($null -ne $policySettings.DeviceSettings.blockExecutableContentFromEmailClientAndWebmail)
            {
                $complexDeviceSettings.Add('BlockExecutableContentFromEmailClientAndWebmail', $policySettings.DeviceSettings.blockExecutableContentFromEmailClientAndWebmail)
            }
            if ($null -ne $policySettings.DeviceSettings.blockExecutableContentFromEmailClientAndWebmail_ASROnlyPerRuleExclusions)
            {
                $complexDeviceSettings.Add('BlockExecutableContentFromEmailClientAndWebmail_ASROnlyPerRuleExclusions', $policySettings.DeviceSettings.blockExecutableContentFromEmailClientAndWebmail_ASROnlyPerRuleExclusions)
            }
            if ($null -ne $policySettings.DeviceSettings.cloudBlockLevel)
            {
                $complexDeviceSettings.Add('CloudBlockLevel', $policySettings.DeviceSettings.cloudBlockLevel)
            }
            if ($null -ne $policySettings.DeviceSettings.cloudExtendedTimeout)
            {
                $complexDeviceSettings.Add('CloudExtendedTimeout', $policySettings.DeviceSettings.cloudExtendedTimeout)
            }
            if ($null -ne $policySettings.DeviceSettings.disableLocalAdminMerge)
            {
                $complexDeviceSettings.Add('DisableLocalAdminMerge', $policySettings.DeviceSettings.disableLocalAdminMerge)
            }
            if ($null -ne $policySettings.DeviceSettings.enableFileHashComputation)
            {
                $complexDeviceSettings.Add('EnableFileHashComputation', $policySettings.DeviceSettings.enableFileHashComputation)
            }
            if ($null -ne $policySettings.DeviceSettings.enableNetworkProtection)
            {
                $complexDeviceSettings.Add('EnableNetworkProtection', $policySettings.DeviceSettings.enableNetworkProtection)
            }
            if ($null -ne $policySettings.DeviceSettings.hideExclusionsFromLocalAdmins)
            {
                $complexDeviceSettings.Add('HideExclusionsFromLocalAdmins', $policySettings.DeviceSettings.hideExclusionsFromLocalAdmins)
            }
            if ($null -ne $policySettings.DeviceSettings.pUAProtection)
            {
                $complexDeviceSettings.Add('PUAProtection', $policySettings.DeviceSettings.pUAProtection)
            }
            if ($null -ne $policySettings.DeviceSettings.realTimeScanDirection)
            {
                $complexDeviceSettings.Add('RealTimeScanDirection', $policySettings.DeviceSettings.realTimeScanDirection)
            }
            if ($null -ne $policySettings.DeviceSettings.submitSamplesConsent)
            {
                $complexDeviceSettings.Add('SubmitSamplesConsent', $policySettings.DeviceSettings.submitSamplesConsent)
            }
            if ($null -ne $policySettings.DeviceSettings.configureSystemGuardLaunch)
            {
                $complexDeviceSettings.Add('ConfigureSystemGuardLaunch', $policySettings.DeviceSettings.configureSystemGuardLaunch)
            }
            if ($null -ne $policySettings.DeviceSettings.lsaCfgFlags)
            {
                $complexDeviceSettings.Add('LsaCfgFlags', $policySettings.DeviceSettings.lsaCfgFlags)
            }
            if ($null -ne $policySettings.DeviceSettings.enableVirtualizationBasedSecurity)
            {
                $complexDeviceSettings.Add('EnableVirtualizationBasedSecurity', $policySettings.DeviceSettings.enableVirtualizationBasedSecurity)
            }
            if ($null -ne $policySettings.DeviceSettings.requirePlatformSecurityFeatures)
            {
                $complexDeviceSettings.Add('RequirePlatformSecurityFeatures', $policySettings.DeviceSettings.requirePlatformSecurityFeatures)
            }
            if ($null -ne $policySettings.DeviceSettings.devicePasswordEnabled)
            {
                $complexDeviceSettings.Add('DevicePasswordEnabled', $policySettings.DeviceSettings.devicePasswordEnabled)
            }
            if ($null -ne $policySettings.DeviceSettings.devicePasswordExpiration)
            {
                $complexDeviceSettings.Add('DevicePasswordExpiration', $policySettings.DeviceSettings.devicePasswordExpiration)
            }
            if ($null -ne $policySettings.DeviceSettings.minDevicePasswordLength)
            {
                $complexDeviceSettings.Add('MinDevicePasswordLength', $policySettings.DeviceSettings.minDevicePasswordLength)
            }
            if ($null -ne $policySettings.DeviceSettings.alphanumericDevicePasswordRequired)
            {
                $complexDeviceSettings.Add('AlphanumericDevicePasswordRequired', $policySettings.DeviceSettings.alphanumericDevicePasswordRequired)
            }
            if ($null -ne $policySettings.DeviceSettings.minDevicePasswordComplexCharacters)
            {
                $complexDeviceSettings.Add('MinDevicePasswordComplexCharacters', $policySettings.DeviceSettings.minDevicePasswordComplexCharacters)
            }
            if ($null -ne $policySettings.DeviceSettings.maxDevicePasswordFailedAttempts)
            {
                $complexDeviceSettings.Add('MaxDevicePasswordFailedAttempts', $policySettings.DeviceSettings.maxDevicePasswordFailedAttempts)
            }
            if ($null -ne $policySettings.DeviceSettings.minDevicePasswordComplexCharacters)
            {
                $complexDeviceSettings.Add('MinDevicePasswordComplexCharacters', $policySettings.DeviceSettings.minDevicePasswordComplexCharacters)
            }
            if ($null -ne $policySettings.DeviceSettings.maxInactivityTimeDeviceLock)
            {
                $complexDeviceSettings.Add('MaxInactivityTimeDeviceLock', $policySettings.DeviceSettings.maxInactivityTimeDeviceLock)
            }
            if ($null -ne $policySettings.DeviceSettings.devicePasswordHistory)
            {
                $complexDeviceSettings.Add('DevicePasswordHistory', $policySettings.DeviceSettings.devicePasswordHistory)
            }
            if ($null -ne $policySettings.DeviceSettings.allowSimpleDevicePassword)
            {
                $complexDeviceSettings.Add('AllowSimpleDevicePassword', $policySettings.DeviceSettings.allowSimpleDevicePassword)
            }
            if ($null -ne $policySettings.DeviceSettings.deviceEnumerationPolicy)
            {
                $complexDeviceSettings.Add('DeviceEnumerationPolicy', $policySettings.DeviceSettings.deviceEnumerationPolicy)
            }
            if ($null -ne $policySettings.DeviceSettings.enableInsecureGuestLogons)
            {
                $complexDeviceSettings.Add('EnableInsecureGuestLogons', $policySettings.DeviceSettings.enableInsecureGuestLogons)
            }
            if ($null -ne $policySettings.DeviceSettings.configureLsaProtectedProcess)
            {
                $complexDeviceSettings.Add('ConfigureLsaProtectedProcess', $policySettings.DeviceSettings.configureLsaProtectedProcess)
            }
            if ($null -ne $policySettings.DeviceSettings.allowGameDVR)
            {
                $complexDeviceSettings.Add('AllowGameDVR', $policySettings.DeviceSettings.allowGameDVR)
            }
            if ($null -ne $policySettings.DeviceSettings.mSIAllowUserControlOverInstall)
            {
                $complexDeviceSettings.Add('MSIAllowUserControlOverInstall', $policySettings.DeviceSettings.mSIAllowUserControlOverInstall)
            }
            if ($null -ne $policySettings.DeviceSettings.mSIAlwaysInstallWithElevatedPrivileges)
            {
                $complexDeviceSettings.Add('MSIAlwaysInstallWithElevatedPrivileges', $policySettings.DeviceSettings.mSIAlwaysInstallWithElevatedPrivileges)
            }
            if ($null -ne $policySettings.DeviceSettings.microsoftEdge_ContentSettings_DefaultPluginsSetting)
            {
                $complexDeviceSettings.Add('MicrosoftEdge_ContentSettings_DefaultPluginsSetting', $policySettings.DeviceSettings.microsoftEdge_ContentSettings_DefaultPluginsSetting)
            }
            if ($null -ne $policySettings.DeviceSettings.defaultPluginsSetting_DefaultPluginsSetting)
            {
                $complexDeviceSettings.Add('DefaultPluginsSetting_DefaultPluginsSetting', $policySettings.DeviceSettings.defaultPluginsSetting_DefaultPluginsSetting)
            }
            if ($null -ne $policySettings.DeviceSettings.edge_SSLVersionMin)
            {
                $complexDeviceSettings.Add('Edge_SSLVersionMin', $policySettings.DeviceSettings.edge_SSLVersionMin)
            }
            if ($null -ne $policySettings.DeviceSettings.sSLVersionMin_SSLVersionMin)
            {
                $complexDeviceSettings.Add('SSLVersionMin_SSLVersionMin', $policySettings.DeviceSettings.sSLVersionMin_SSLVersionMin)
            }
            if ($null -ne $policySettings.DeviceSettings.smartScreenEnabled)
            {
                $complexDeviceSettings.Add('SmartScreenEnabled', $policySettings.DeviceSettings.smartScreenEnabled)
            }
            if ($null -ne $policySettings.DeviceSettings.preventSmartScreenPromptOverride)
            {
                $complexDeviceSettings.Add('PreventSmartScreenPromptOverride', $policySettings.DeviceSettings.preventSmartScreenPromptOverride)
            }
            if ($null -ne $policySettings.DeviceSettings.letAppsActivateWithVoiceAboveLock)
            {
                $complexDeviceSettings.Add('LetAppsActivateWithVoiceAboveLock', $policySettings.DeviceSettings.letAppsActivateWithVoiceAboveLock)
            }
            if ($null -ne $policySettings.DeviceSettings.allowIndexingEncryptedStoresOrItems)
            {
                $complexDeviceSettings.Add('AllowIndexingEncryptedStoresOrItems', $policySettings.DeviceSettings.allowIndexingEncryptedStoresOrItems)
            }
            if ($null -ne $policySettings.DeviceSettings.enableSmartScreenInShell)
            {
                $complexDeviceSettings.Add('EnableSmartScreenInShell', $policySettings.DeviceSettings.enableSmartScreenInShell)
            }
            if ($null -ne $policySettings.DeviceSettings.notifyMalicious)
            {
                $complexDeviceSettings.Add('NotifyMalicious', $policySettings.DeviceSettings.notifyMalicious)
            }
            if ($null -ne $policySettings.DeviceSettings.notifyPasswordReuse)
            {
                $complexDeviceSettings.Add('NotifyPasswordReuse', $policySettings.DeviceSettings.notifyPasswordReuse)
            }
            if ($null -ne $policySettings.DeviceSettings.notifyUnsafeApp)
            {
                $complexDeviceSettings.Add('NotifyUnsafeApp', $policySettings.DeviceSettings.notifyUnsafeApp)
            }
            if ($null -ne $policySettings.DeviceSettings.serviceEnabled)
            {
                $complexDeviceSettings.Add('ServiceEnabled', $policySettings.DeviceSettings.serviceEnabled)
            }
            if ($null -ne $policySettings.DeviceSettings.preventOverrideForFilesInShell)
            {
                $complexDeviceSettings.Add('PreventOverrideForFilesInShell', $policySettings.DeviceSettings.preventOverrideForFilesInShell)
            }
            if ($null -ne $policySettings.DeviceSettings.accessFromNetwork)
            {
                $complexDeviceSettings.Add('AccessFromNetwork', $policySettings.DeviceSettings.accessFromNetwork)
            }
            if ($null -ne $policySettings.DeviceSettings.allowLocalLogOn)
            {
                $complexDeviceSettings.Add('AllowLocalLogOn', $policySettings.DeviceSettings.allowLocalLogOn)
            }
            if ($null -ne $policySettings.DeviceSettings.backupFilesAndDirectories)
            {
                $complexDeviceSettings.Add('BackupFilesAndDirectories', $policySettings.DeviceSettings.backupFilesAndDirectories)
            }
            if ($null -ne $policySettings.DeviceSettings.createGlobalObjects)
            {
                $complexDeviceSettings.Add('CreateGlobalObjects', $policySettings.DeviceSettings.createGlobalObjects)
            }
            if ($null -ne $policySettings.DeviceSettings.createPageFile)
            {
                $complexDeviceSettings.Add('CreatePageFile', $policySettings.DeviceSettings.createPageFile)
            }
            if ($null -ne $policySettings.DeviceSettings.debugPrograms)
            {
                $complexDeviceSettings.Add('DebugPrograms', $policySettings.DeviceSettings.debugPrograms)
            }
            if ($null -ne $policySettings.DeviceSettings.denyAccessFromNetwork)
            {
                $complexDeviceSettings.Add('DenyAccessFromNetwork', $policySettings.DeviceSettings.denyAccessFromNetwork)
            }
            if ($null -ne $policySettings.DeviceSettings.denyRemoteDesktopServicesLogOn)
            {
                $complexDeviceSettings.Add('DenyRemoteDesktopServicesLogOn', $policySettings.DeviceSettings.denyRemoteDesktopServicesLogOn)
            }
            if ($null -ne $policySettings.DeviceSettings.impersonateClient)
            {
                $complexDeviceSettings.Add('ImpersonateClient', $policySettings.DeviceSettings.impersonateClient)
            }
            if ($null -ne $policySettings.DeviceSettings.loadUnloadDeviceDrivers)
            {
                $complexDeviceSettings.Add('LoadUnloadDeviceDrivers', $policySettings.DeviceSettings.loadUnloadDeviceDrivers)
            }
            if ($null -ne $policySettings.DeviceSettings.manageAuditingAndSecurityLog)
            {
                $complexDeviceSettings.Add('ManageAuditingAndSecurityLog', $policySettings.DeviceSettings.manageAuditingAndSecurityLog)
            }
            if ($null -ne $policySettings.DeviceSettings.manageVolume)
            {
                $complexDeviceSettings.Add('ManageVolume', $policySettings.DeviceSettings.manageVolume)
            }
            if ($null -ne $policySettings.DeviceSettings.modifyFirmwareEnvironment)
            {
                $complexDeviceSettings.Add('ModifyFirmwareEnvironment', $policySettings.DeviceSettings.modifyFirmwareEnvironment)
            }
            if ($null -ne $policySettings.DeviceSettings.profileSingleProcess)
            {
                $complexDeviceSettings.Add('ProfileSingleProcess', $policySettings.DeviceSettings.profileSingleProcess)
            }
            if ($null -ne $policySettings.DeviceSettings.remoteShutdown)
            {
                $complexDeviceSettings.Add('RemoteShutdown', $policySettings.DeviceSettings.remoteShutdown)
            }
            if ($null -ne $policySettings.DeviceSettings.restoreFilesAndDirectories)
            {
                $complexDeviceSettings.Add('RestoreFilesAndDirectories', $policySettings.DeviceSettings.restoreFilesAndDirectories)
            }
            if ($null -ne $policySettings.DeviceSettings.takeOwnership)
            {
                $complexDeviceSettings.Add('TakeOwnership', $policySettings.DeviceSettings.takeOwnership)
            }
            if ($null -ne $policySettings.DeviceSettings.hypervisorEnforcedCodeIntegrity)
            {
                $complexDeviceSettings.Add('HypervisorEnforcedCodeIntegrity', $policySettings.DeviceSettings.hypervisorEnforcedCodeIntegrity)
            }
            if ($null -ne $policySettings.DeviceSettings.allowWindowsInkWorkspace)
            {
                $complexDeviceSettings.Add('AllowWindowsInkWorkspace', $policySettings.DeviceSettings.allowWindowsInkWorkspace)
            }
            if ($null -ne $policySettings.DeviceSettings.accounts_LimitLocalAccountUseOfBlankPasswordsToConsoleLogonOnly)
            {
                $complexDeviceSettings.Add('Accounts_LimitLocalAccountUseOfBlankPasswordsToConsoleLogonOnly', $policySettings.DeviceSettings.accounts_LimitLocalAccountUseOfBlankPasswordsToConsoleLogonOnly)
            }
            if ($null -ne $policySettings.DeviceSettings.interactiveLogon_MachineInactivityLimit)
            {
                $complexDeviceSettings.Add('InteractiveLogon_MachineInactivityLimit', $policySettings.DeviceSettings.interactiveLogon_MachineInactivityLimit)
            }
            if ($null -ne $policySettings.DeviceSettings.interactiveLogon_SmartCardRemovalBehavior)
            {
                $complexDeviceSettings.Add('InteractiveLogon_SmartCardRemovalBehavior', $policySettings.DeviceSettings.interactiveLogon_SmartCardRemovalBehavior)
            }
            if ($null -ne $policySettings.DeviceSettings.microsoftNetworkClient_DigitallySignCommunicationsAlways)
            {
                $complexDeviceSettings.Add('MicrosoftNetworkClient_DigitallySignCommunicationsAlways', $policySettings.DeviceSettings.microsoftNetworkClient_DigitallySignCommunicationsAlways)
            }
            if ($null -ne $policySettings.DeviceSettings.microsoftNetworkClient_SendUnencryptedPasswordToThirdPartySMBServers)
            {
                $complexDeviceSettings.Add('MicrosoftNetworkClient_SendUnencryptedPasswordToThirdPartySMBServers', $policySettings.DeviceSettings.microsoftNetworkClient_SendUnencryptedPasswordToThirdPartySMBServers)
            }
            if ($null -ne $policySettings.DeviceSettings.microsoftNetworkServer_DigitallySignCommunicationsAlways)
            {
                $complexDeviceSettings.Add('MicrosoftNetworkServer_DigitallySignCommunicationsAlways', $policySettings.DeviceSettings.microsoftNetworkServer_DigitallySignCommunicationsAlways)
            }
            if ($null -ne $policySettings.DeviceSettings.networkAccess_DoNotAllowAnonymousEnumerationOfSAMAccounts)
            {
                $complexDeviceSettings.Add('NetworkAccess_DoNotAllowAnonymousEnumerationOfSAMAccounts', $policySettings.DeviceSettings.networkAccess_DoNotAllowAnonymousEnumerationOfSAMAccounts)
            }
            if ($null -ne $policySettings.DeviceSettings.networkAccess_DoNotAllowAnonymousEnumerationOfSamAccountsAndShares)
            {
                $complexDeviceSettings.Add('NetworkAccess_DoNotAllowAnonymousEnumerationOfSamAccountsAndShares', $policySettings.DeviceSettings.networkAccess_DoNotAllowAnonymousEnumerationOfSamAccountsAndShares)
            }
            if ($null -ne $policySettings.DeviceSettings.networkAccess_RestrictAnonymousAccessToNamedPipesAndShares)
            {
                $complexDeviceSettings.Add('NetworkAccess_RestrictAnonymousAccessToNamedPipesAndShares', $policySettings.DeviceSettings.networkAccess_RestrictAnonymousAccessToNamedPipesAndShares)
            }
            if ($null -ne $policySettings.DeviceSettings.networkAccess_RestrictClientsAllowedToMakeRemoteCallsToSAM)
            {
                $complexDeviceSettings.Add('NetworkAccess_RestrictClientsAllowedToMakeRemoteCallsToSAM', $policySettings.DeviceSettings.networkAccess_RestrictClientsAllowedToMakeRemoteCallsToSAM)
            }
            if ($null -ne $policySettings.DeviceSettings.networkSecurity_DoNotStoreLANManagerHashValueOnNextPasswordChange)
            {
                $complexDeviceSettings.Add('NetworkSecurity_DoNotStoreLANManagerHashValueOnNextPasswordChange', $policySettings.DeviceSettings.networkSecurity_DoNotStoreLANManagerHashValueOnNextPasswordChange)
            }
            if ($null -ne $policySettings.DeviceSettings.networkSecurity_LANManagerAuthenticationLevel)
            {
                $complexDeviceSettings.Add('NetworkSecurity_LANManagerAuthenticationLevel', $policySettings.DeviceSettings.networkSecurity_LANManagerAuthenticationLevel)
            }
            if ($null -ne $policySettings.DeviceSettings.networkSecurity_MinimumSessionSecurityForNTLMSSPBasedClients)
            {
                $complexDeviceSettings.Add('NetworkSecurity_MinimumSessionSecurityForNTLMSSPBasedClients', $policySettings.DeviceSettings.networkSecurity_MinimumSessionSecurityForNTLMSSPBasedClients)
            }
            if ($null -ne $policySettings.DeviceSettings.networkSecurity_MinimumSessionSecurityForNTLMSSPBasedServers)
            {
                $complexDeviceSettings.Add('NetworkSecurity_MinimumSessionSecurityForNTLMSSPBasedServers', $policySettings.DeviceSettings.networkSecurity_MinimumSessionSecurityForNTLMSSPBasedServers)
            }
            if ($null -ne $policySettings.DeviceSettings.userAccountControl_BehaviorOfTheElevationPromptForAdministrators)
            {
                $complexDeviceSettings.Add('UserAccountControl_BehaviorOfTheElevationPromptForAdministrators', $policySettings.DeviceSettings.userAccountControl_BehaviorOfTheElevationPromptForAdministrators)
            }
            if ($null -ne $policySettings.DeviceSettings.userAccountControl_BehaviorOfTheElevationPromptForStandardUsers)
            {
                $complexDeviceSettings.Add('UserAccountControl_BehaviorOfTheElevationPromptForStandardUsers', $policySettings.DeviceSettings.userAccountControl_BehaviorOfTheElevationPromptForStandardUsers)
            }
            if ($null -ne $policySettings.DeviceSettings.userAccountControl_DetectApplicationInstallationsAndPromptForElevation)
            {
                $complexDeviceSettings.Add('UserAccountControl_DetectApplicationInstallationsAndPromptForElevation', $policySettings.DeviceSettings.userAccountControl_DetectApplicationInstallationsAndPromptForElevation)
            }
            if ($null -ne $policySettings.DeviceSettings.userAccountControl_OnlyElevateUIAccessApplicationsThatAreInstalledInSecureLocations)
            {
                $complexDeviceSettings.Add('UserAccountControl_OnlyElevateUIAccessApplicationsThatAreInstalledInSecureLocations', $policySettings.DeviceSettings.userAccountControl_OnlyElevateUIAccessApplicationsThatAreInstalledInSecureLocations)
            }
            if ($null -ne $policySettings.DeviceSettings.userAccountControl_RunAllAdministratorsInAdminApprovalMode)
            {
                $complexDeviceSettings.Add('UserAccountControl_RunAllAdministratorsInAdminApprovalMode', $policySettings.DeviceSettings.userAccountControl_RunAllAdministratorsInAdminApprovalMode)
            }
            if ($null -ne $policySettings.DeviceSettings.userAccountControl_UseAdminApprovalMode)
            {
                $complexDeviceSettings.Add('UserAccountControl_UseAdminApprovalMode', $policySettings.DeviceSettings.userAccountControl_UseAdminApprovalMode)
            }
            if ($null -ne $policySettings.DeviceSettings.userAccountControl_VirtualizeFileAndRegistryWriteFailuresToPerUserLocations)
            {
                $complexDeviceSettings.Add('UserAccountControl_VirtualizeFileAndRegistryWriteFailuresToPerUserLocations', $policySettings.DeviceSettings.userAccountControl_VirtualizeFileAndRegistryWriteFailuresToPerUserLocations)
            }
            if ($complexDeviceSettings.values.Where({ $null -ne $_ }).Count -eq 0)
            {
                $complexDeviceSettings = $null
            }
            $policySettings.Remove('DeviceSettings') | Out-Null

            $complexUserSettings = [ordered]@{}
            if ($null -ne $policySettings.UserSettings.noLockScreenToastNotification)
            {
                $complexUserSettings.Add('NoLockScreenToastNotification', $policySettings.UserSettings.noLockScreenToastNotification)
            }
            if ($null -ne $policySettings.UserSettings.restrictFormSuggestPW)
            {
                $complexUserSettings.Add('RestrictFormSuggestPW', $policySettings.UserSettings.restrictFormSuggestPW)
            }
            if ($null -ne $policySettings.UserSettings.chkBox_PasswordAsk)
            {
                $complexUserSettings.Add('ChkBox_PasswordAsk', $policySettings.UserSettings.chkBox_PasswordAsk)
            }
            if ($null -ne $policySettings.UserSettings.allowWindowsSpotlight)
            {
                $complexUserSettings.Add('AllowWindowsSpotlight', $policySettings.UserSettings.allowWindowsSpotlight)
            }
            if ($null -ne $policySettings.UserSettings.allowWindowsTips)
            {
                $complexUserSettings.Add('AllowWindowsTips', $policySettings.UserSettings.allowWindowsTips)
            }
            if ($null -ne $policySettings.UserSettings.allowTailoredExperiencesWithDiagnosticData)
            {
                $complexUserSettings.Add('AllowTailoredExperiencesWithDiagnosticData', $policySettings.UserSettings.allowTailoredExperiencesWithDiagnosticData)
            }
            if ($null -ne $policySettings.UserSettings.allowWindowsSpotlightOnActionCenter)
            {
                $complexUserSettings.Add('AllowWindowsSpotlightOnActionCenter', $policySettings.UserSettings.allowWindowsSpotlightOnActionCenter)
            }
            if ($null -ne $policySettings.UserSettings.allowWindowsConsumerFeatures)
            {
                $complexUserSettings.Add('AllowWindowsConsumerFeatures', $policySettings.UserSettings.allowWindowsConsumerFeatures)
            }
            if ($null -ne $policySettings.UserSettings.configureWindowsSpotlightOnLockScreen)
            {
                $complexUserSettings.Add('ConfigureWindowsSpotlightOnLockScreen', $policySettings.UserSettings.configureWindowsSpotlightOnLockScreen)
            }
            if ($null -ne $policySettings.UserSettings.allowWindowsSpotlightWindowsWelcomeExperience)
            {
                $complexUserSettings.Add('AllowWindowsSpotlightWindowsWelcomeExperience', $policySettings.UserSettings.allowWindowsSpotlightWindowsWelcomeExperience)
            }
            if ($null -ne $policySettings.UserSettings.allowThirdPartySuggestionsInWindowsSpotlight)
            {
                $complexUserSettings.Add('AllowThirdPartySuggestionsInWindowsSpotlight', $policySettings.UserSettings.allowThirdPartySuggestionsInWindowsSpotlight)
            }
            if ($null -ne $policySettings.UserSettings.microsoftEdge_ContentSettings_DefaultPluginsSetting)
            {
                $complexUserSettings.Add('MicrosoftEdge_ContentSettings_DefaultPluginsSetting', $policySettings.UserSettings.microsoftEdge_ContentSettings_DefaultPluginsSetting)
            }
            if ($null -ne $policySettings.UserSettings.defaultPluginsSetting_DefaultPluginsSetting)
            {
                $complexUserSettings.Add('DefaultPluginsSetting_DefaultPluginsSetting', $policySettings.UserSettings.defaultPluginsSetting_DefaultPluginsSetting)
            }
            if ($null -ne $policySettings.UserSettings.edge_SSLVersionMin)
            {
                $complexUserSettings.Add('Edge_SSLVersionMin', $policySettings.UserSettings.edge_SSLVersionMin)
            }
            if ($null -ne $policySettings.UserSettings.sSLVersionMin_SSLVersionMin)
            {
                $complexUserSettings.Add('SSLVersionMin_SSLVersionMin', $policySettings.UserSettings.sSLVersionMin_SSLVersionMin)
            }
            if ($complexUserSettings.values.Where({ $null -ne $_ }).Count -eq 0)
            {
                $complexUserSettings = $null
            }
            $policySettings.Remove('UserSettings') | Out-Null
            #endregion

            $results = @{
                #region resource generator code
                Description           = $getValue.Description
                DisplayName           = $getValue.Name
                RoleScopeTagIds       = Resolve-M365DSCIntuneRoleScopeTagNames -CurrentValues $getValue.RoleScopeTagIds -DesiredValues $this.RoleScopeTagIds
                Id                    = $getValue.Id
                DeviceSettings        = $complexDeviceSettings
                UserSettings          = $complexUserSettings
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

        Write-Verbose -Message "Setting configuration of the Intune Security Baseline Windows365 with Id {$($this.Id)} and Name {$($this.DisplayName)}"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $currentInstance = $this.Get().ToHashtable()
        $boundParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()

        $resolvedRoleScopeTagIds = $this.RoleScopeTagIds
        if ($boundParameters.ContainsKey('RoleScopeTagIds'))
        {
            $resolvedRoleScopeTagIds = Resolve-M365DSCIntuneRoleScopeTagIds -RoleScopeTagIds $this.RoleScopeTagIds
        }

        $templateReferenceId = 'b00e1a0f-19dd-41de-8243-e6733ca7b4ae_1'
        $platforms = 'windows10'
        $technologies = 'mdm'

        if ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Creating an Intune Security Baseline Windows365 with Name {$($this.DisplayName)}"
            $boundParameters.Remove('Assignments') | Out-Null

            $settings = Get-IntuneSettingCatalogPolicySetting `
                -DSCParams ([System.Collections.Hashtable]$boundParameters) `
                -TemplateId $templateReferenceId `
                -ContainsDeviceAndUserSettings

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
            Write-Verbose -Message "Updating the Intune Security Baseline Windows365 with Id {$($currentInstance.Id)}"
            $boundParameters.Remove('Assignments') | Out-Null

            $settings = Get-IntuneSettingCatalogPolicySetting `
                -DSCParams ([System.Collections.Hashtable]$boundParameters) `
                -TemplateId $templateReferenceId `
                -ContainsDeviceAndUserSettings

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
            Write-Verbose -Message "Removing the Intune Security Baseline Windows365 with Id {$($currentInstance.Id)}"
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
            $policyTemplateID = 'b00e1a0f-19dd-41de-8243-e6733ca7b4ae_1'
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

                if ($null -ne $Results.DeviceSettings)
                {
                    $complexMapping = @(
                        @{
                            Name            = 'DeviceSettings'
                            CimInstanceName = 'MicrosoftGraphIntuneSettingsCatalogDeviceSettings_IntuneSecurityBaselineWindows365'
                            IsRequired      = $False
                        }
                        @{
                            Name            = 'pol_hardenedpaths'
                            CimInstanceName = 'MicrosoftGraphIntuneSettingsCatalogpol_hardenedpaths'
                            IsRequired      = $False
                        }
                    )
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.DeviceSettings `
                        -CIMInstanceName 'MicrosoftGraphIntuneSettingsCatalogDeviceSettings_IntuneSecurityBaselineWindows365' `
                        -ComplexTypeMapping $complexMapping

                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.DeviceSettings = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('DeviceSettings') | Out-Null
                    }
                }
                if ($null -ne $Results.UserSettings)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.UserSettings `
                        -CIMInstanceName 'MicrosoftGraphIntuneSettingsCatalogUserSettings_IntuneSecurityBaselineWindows365'
                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.UserSettings = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('UserSettings') | Out-Null
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
                    -NoEscape @('DeviceSettings', 'UserSettings', 'Assignments') `
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

    hidden [IntuneSecurityBaselineWindows365] AsResult([System.Object] $Values)
    {
        if ($Values -is [IntuneSecurityBaselineWindows365])
        {
            return $Values
        }

        $result = [IntuneSecurityBaselineWindows365]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}

class MSFT_MicrosoftGraphIntuneSettingsCatalogDeviceSettings_IntuneSecurityBaselineWindows365
{
    [DscProperty()]
    [System.ComponentModel.Description('Prevent enabling lock screen camera (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $CPL_Personalization_NoLockScreenCamera

    [DscProperty()]
    [System.ComponentModel.Description('Prevent enabling lock screen slide show (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $CPL_Personalization_NoLockScreenSlideshow

    [DscProperty()]
    [System.ComponentModel.Description('Apply UAC restrictions to local accounts on network logons (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $Pol_SecGuide_0201_LATFP

    [DscProperty()]
    [System.ComponentModel.Description('Configure SMB v1 client driver (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $Pol_SecGuide_0002_SMBv1_ClientDriver

    [DscProperty()]
    [System.ComponentModel.Description('Configure MrxSmb10 driver - Depends on Pol_SecGuide_0002_SMBv1_ClientDriver (4: Disable driver (recommended), 3: Manual start (default for Win7/2008/2008R2/2012), 2: Automatic start (default for Win8.1/2012R2/newer))')]
    [ValidateSet('4', '3', '2')]
    [System.Nullable[System.Int32]] $Pol_SecGuide_SMB1ClientDriver

    [DscProperty()]
    [System.ComponentModel.Description('Configure SMB v1 server (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $Pol_SecGuide_0001_SMBv1_Server

    [DscProperty()]
    [System.ComponentModel.Description('Enable Structured Exception Handling Overwrite Protection (SEHOP) (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $Pol_SecGuide_0102_SEHOP

    [DscProperty()]
    [System.ComponentModel.Description('WDigest Authentication (disabling may require KB2871997) (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $Pol_SecGuide_0202_WDigestAuthn

    [DscProperty()]
    [System.ComponentModel.Description('MSS: (DisableIPSourceRouting IPv6) IP source routing protection level (protects against packet spoofing) (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $Pol_MSS_DisableIPSourceRoutingIPv6

    [DscProperty()]
    [System.ComponentModel.Description('DisableIPSourceRoutingIPv6 (Device) - Depends on Pol_MSS_DisableIPSourceRoutingIPv6 (0: No additional protection, source routed packets are allowed, 1: Medium, source routed packets ignored when IP forwarding is enabled, 2: Highest protection, source routing is completely disabled)')]
    [ValidateSet('0', '1', '2')]
    [System.Nullable[System.Int32]] $DisableIPSourceRoutingIPv6

    [DscProperty()]
    [System.ComponentModel.Description('MSS: (DisableIPSourceRouting) IP source routing protection level (protects against packet spoofing) (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $Pol_MSS_DisableIPSourceRouting

    [DscProperty()]
    [System.ComponentModel.Description('DisableIPSourceRouting (Device) - Depends on Pol_MSS_DisableIPSourceRouting (0: No additional protection, source routed packets are allowed, 1: Medium, source routed packets ignored when IP forwarding is enabled, 2: Highest protection, source routing is completely disabled)')]
    [ValidateSet('0', '1', '2')]
    [System.Nullable[System.Int32]] $DisableIPSourceRouting

    [DscProperty()]
    [System.ComponentModel.Description('MSS: (EnableICMPRedirect) Allow ICMP redirects to override OSPF generated routes (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $Pol_MSS_EnableICMPRedirect

    [DscProperty()]
    [System.ComponentModel.Description('MSS: (NoNameReleaseOnDemand) Allow the computer to ignore NetBIOS name release requests except from WINS servers (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $Pol_MSS_NoNameReleaseOnDemand

    [DscProperty()]
    [System.ComponentModel.Description('Turn off multicast name resolution (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $Turn_Off_Multicast

    [DscProperty()]
    [System.ComponentModel.Description('Prohibit use of Internet Connection Sharing on your DNS domain network (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $NC_ShowSharedAccessUI

    [DscProperty()]
    [System.ComponentModel.Description('Hardened UNC Paths (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $hardeneduncpaths_Pol_HardenedPaths

    [DscProperty()]
    [System.ComponentModel.Description('Hardened UNC Paths: (Device) - Depends on hardeneduncpaths_Pol_HardenedPaths')]
    [MSFT_MicrosoftGraphIntuneSettingsCatalogpol_hardenedpaths[]] $pol_hardenedpaths

    [DscProperty()]
    [System.ComponentModel.Description('Prohibit connection to non-domain networks when connected to domain authenticated network (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $WCM_BlockNonDomain

    [DscProperty()]
    [System.ComponentModel.Description('Encryption Oracle Remediation (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $AllowEncryptionOracle

    [DscProperty()]
    [System.ComponentModel.Description('Protection Level: (Device) - Depends on AllowEncryptionOracle (0: Force Updated Clients, 1: Mitigated, 2: Vulnerable)')]
    [ValidateSet('0', '1', '2')]
    [System.Nullable[System.Int32]] $AllowEncryptionOracleDrop

    [DscProperty()]
    [System.ComponentModel.Description('Remote host allows delegation of non-exportable credentials (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $AllowProtectedCreds

    [DscProperty()]
    [System.ComponentModel.Description('Prevent installation of devices using drivers that match these device setup classes (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $DeviceInstall_Classes_Deny

    [DscProperty()]
    [System.ComponentModel.Description('Prevented Classes - Depends on DeviceInstall_Classes_Deny')]
    [System.String[]] $DeviceInstall_Classes_Deny_List

    [DscProperty()]
    [System.ComponentModel.Description('Also apply to matching devices that are already installed. - Depends on DeviceInstall_Classes_Deny (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $DeviceInstall_Classes_Deny_Retroactive

    [DscProperty()]
    [System.ComponentModel.Description('Boot-Start Driver Initialization Policy (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $POL_DriverLoadPolicy_Name

    [DscProperty()]
    [System.ComponentModel.Description('Choose the boot-start drivers that can be initialized: - Depends on POL_DriverLoadPolicy_Name (8: Good only, 1: Good and unknown, 3: Good, unknown and bad but critical, 7: All)')]
    [ValidateSet('8', '1', '3', '7')]
    [System.Nullable[System.Int32]] $SelectDriverLoadPolicy

    [DscProperty()]
    [System.ComponentModel.Description('Configure registry policy processing (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $CSE_Registry

    [DscProperty()]
    [System.ComponentModel.Description('Do not apply during periodic background processing (Device) - Depends on CSE_Registry (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $CSE_NOBACKGROUND10

    [DscProperty()]
    [System.ComponentModel.Description('Process even if the Group Policy objects have not changed (Device) - Depends on CSE_Registry (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $CSE_NOCHANGES10

    [DscProperty()]
    [System.ComponentModel.Description('Turn off downloading of print drivers over HTTP (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $DisableWebPnPDownload_2

    [DscProperty()]
    [System.ComponentModel.Description('Turn off Internet download for Web publishing and online ordering wizards (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $ShellPreventWPWDownload_2

    [DscProperty()]
    [System.ComponentModel.Description('Configure Solicited Remote Assistance (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $RA_Solicit

    [DscProperty()]
    [System.ComponentModel.Description('Maximum ticket time (units): - Depends on RA_Solicit (0: Minutes, 1: Hours, 2: Days)')]
    [ValidateSet('0', '1', '2')]
    [System.Nullable[System.Int32]] $RA_Solicit_ExpireUnits_List

    [DscProperty()]
    [System.ComponentModel.Description('Maximum ticket time (value): - Depends on RA_Solicit')]
    [System.Nullable[System.Int32]] $RA_Solicit_ExpireValue_Edt

    [DscProperty()]
    [System.ComponentModel.Description('Permit remote control of this computer: - Depends on RA_Solicit (1: Allow helpers to remotely control the computer, 0: Allow helpers to only view the computer)')]
    [ValidateSet('1', '0')]
    [System.Nullable[System.Int32]] $RA_Solicit_Control_List

    [DscProperty()]
    [System.ComponentModel.Description('Method for sending email invitations: - Depends on RA_Solicit (0: Simple MAPI, 1: Mailto)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $RA_Solicit_Mailto_List

    [DscProperty()]
    [System.ComponentModel.Description('Restrict Unauthenticated RPC clients (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $RpcRestrictRemoteClients

    [DscProperty()]
    [System.ComponentModel.Description('RPC Runtime Unauthenticated Client Restriction to Apply: - Depends on RpcRestrictRemoteClients (0: None, 1: Authenticated, 2: Authenticated without exceptions)')]
    [ValidateSet('0', '1', '2')]
    [System.Nullable[System.Int32]] $RpcRestrictRemoteClientsList

    [DscProperty()]
    [System.ComponentModel.Description('Allow Microsoft accounts to be optional (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $AppxRuntimeMicrosoftAccountsOptional

    [DscProperty()]
    [System.ComponentModel.Description('Disallow Autoplay for non-volume devices (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $NoAutoplayfornonVolume

    [DscProperty()]
    [System.ComponentModel.Description('Set the default behavior for AutoRun (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $NoAutorun

    [DscProperty()]
    [System.ComponentModel.Description('Default AutoRun Behavior - Depends on NoAutorun (1: Do not execute any autorun commands, 2: Automatically execute autorun commands)')]
    [ValidateSet('1', '2')]
    [System.Nullable[System.Int32]] $NoAutorun_Dropdown

    [DscProperty()]
    [System.ComponentModel.Description('Turn off Autoplay (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $Autorun

    [DscProperty()]
    [System.ComponentModel.Description('Turn off Autoplay on: - Depends on Autorun (181: CD-ROM and removable media drives, 255: All drives)')]
    [ValidateSet('181', '255')]
    [System.Nullable[System.Int32]] $Autorun_Box

    [DscProperty()]
    [System.ComponentModel.Description('Enumerate administrator accounts on elevation (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $EnumerateAdministrators

    [DscProperty()]
    [System.ComponentModel.Description('Specify the maximum log file size (KB) (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $Channel_LogMaxSize_1

    [DscProperty()]
    [System.ComponentModel.Description('Maximum Log Size (KB) - Depends on Channel_LogMaxSize_1')]
    [System.Nullable[System.Int32]] $Channel_LogMaxSize_1_Channel_LogMaxSize

    [DscProperty()]
    [System.ComponentModel.Description('Specify the maximum log file size (KB) (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $Channel_LogMaxSize_2

    [DscProperty()]
    [System.ComponentModel.Description('Maximum Log Size (KB) - Depends on Channel_LogMaxSize_2')]
    [System.Nullable[System.Int32]] $Channel_LogMaxSize_2_Channel_LogMaxSize

    [DscProperty()]
    [System.ComponentModel.Description('Specify the maximum log file size (KB) (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $Channel_LogMaxSize_4

    [DscProperty()]
    [System.ComponentModel.Description('Maximum Log Size (KB) - Depends on Channel_LogMaxSize_4')]
    [System.Nullable[System.Int32]] $Channel_LogMaxSize_4_Channel_LogMaxSize

    [DscProperty()]
    [System.ComponentModel.Description('Configure Windows Defender SmartScreen (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $EnableSmartScreen

    [DscProperty()]
    [System.ComponentModel.Description('Pick one of the following settings: (Device) - Depends on EnableSmartScreen (block: Warn and prevent bypass, warn: Warn)')]
    [ValidateSet('block', 'warn')]
    [System.String] $EnableSmartScreenDropdown

    [DscProperty()]
    [System.ComponentModel.Description('Turn off Data Execution Prevention for Explorer (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $NoDataExecutionPrevention

    [DscProperty()]
    [System.ComponentModel.Description('Turn off heap termination on corruption (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $NoHeapTerminationOnCorruption

    [DscProperty()]
    [System.ComponentModel.Description('Allow software to run or install even if the signature is invalid (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $Advanced_InvalidSignatureBlock

    [DscProperty()]
    [System.ComponentModel.Description('Check for server certificate revocation (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $Advanced_CertificateRevocation

    [DscProperty()]
    [System.ComponentModel.Description('Check for signatures on downloaded programs (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $Advanced_DownloadSignatures

    [DscProperty()]
    [System.ComponentModel.Description('Do not allow ActiveX controls to run in Protected Mode when Enhanced Protected Mode is enabled (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $Advanced_DisableEPMCompat

    [DscProperty()]
    [System.ComponentModel.Description('Turn off encryption support (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $Advanced_SetWinInetProtocols

    [DscProperty()]
    [System.ComponentModel.Description('Secure Protocol combinations - Depends on Advanced_SetWinInetProtocols (0: Use no secure protocols, 8: Only use SSL 2.0, 32: Only use SSL 3.0, 40: Use SSL 2.0 and SSL 3.0, 128: Only use TLS 1.0, 136: Use SSL 2.0 and TLS 1.0, 160: Use SSL 3.0 and TLS 1.0, 168: Use SSL 2.0, SSL 3.0, and TLS 1.0, 512: Only use TLS 1.1, 520: Use SSL 2.0 and TLS 1.1, 544: Use SSL 3.0 and TLS 1.1, 552: Use SSL 2.0, SSL 3.0, and TLS 1.1, 640: Use TLS 1.0 and TLS 1.1, 648: Use SSL 2.0, TLS 1.0, and TLS 1.1, 672: Use SSL 3.0, TLS 1.0, and TLS 1.1, 680: Use SSL 2.0, SSL 3.0, TLS 1.0, and TLS 1.1, 2048: Only use TLS 1.2, 2056: Use SSL 2.0 and TLS 1.2, 2080: Use SSL 3.0 and TLS 1.2, 2088: Use SSL 2.0, SSL 3.0, and TLS 1.2, 2176: Use TLS 1.0 and TLS 1.2, 2184: Use SSL 2.0, TLS 1.0, and TLS 1.2, 2208: Use SSL 3.0, TLS 1.0, and TLS 1.2, 2216: Use SSL 2.0, SSL 3.0, TLS 1.0, and TLS 1.2, 2560: Use TLS 1.1 and TLS 1.2, 2568: Use SSL 2.0, TLS 1.1, and TLS 1.2, 2592: Use SSL 3.0, TLS 1.1, and TLS 1.2, 2600: Use SSL 2.0, SSL 3.0, TLS 1.1, and TLS 1.2, 2688: Use TLS 1.0, TLS 1.1, and TLS 1.2, 2696: Use SSL 2.0, TLS 1.0, TLS 1.1, and TLS 1.2, 2720: Use SSL 3.0, TLS 1.0, TLS 1.1, and TLS 1.2, 2728: Use SSL 2.0, SSL 3.0, TLS 1.0, TLS 1.1, and TLS 1.2, 8192: Only use TLS 1.3, 10240: Use TLS 1.2 and TLS 1.3, 10752: Use TLS 1.1, TLS 1.2, and TLS 1.3, 10880: Use TLS 1.0, TLS 1.1, TLS 1.2, and TLS 1.3, 10912: Use SSL 3.0, TLS 1.0, TLS 1.1, TLS 1.2, and TLS 1.3)')]
    [ValidateSet('0', '8', '32', '40', '128', '136', '160', '168', '512', '520', '544', '552', '640', '648', '672', '680', '2048', '2056', '2080', '2088', '2176', '2184', '2208', '2216', '2560', '2568', '2592', '2600', '2688', '2696', '2720', '2728', '8192', '10240', '10752', '10880', '10912')]
    [System.String] $Advanced_WinInetProtocolOptions

    [DscProperty()]
    [System.ComponentModel.Description('Turn on 64-bit tab processes when running in Enhanced Protected Mode on 64-bit versions of Windows (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $Advanced_EnableEnhancedProtectedMode64Bit

    [DscProperty()]
    [System.ComponentModel.Description('Turn on Enhanced Protected Mode (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $Advanced_EnableEnhancedProtectedMode

    [DscProperty()]
    [System.ComponentModel.Description('Prevent ignoring certificate errors (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $NoCertError

    [DscProperty()]
    [System.ComponentModel.Description('Access data sources across domains (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $IZ_PolicyAccessDataSourcesAcrossDomains_1

    [DscProperty()]
    [System.ComponentModel.Description('Access data sources across domains - Depends on IZ_PolicyAccessDataSourcesAcrossDomains_1 (0: Enable, 3: Disable, 1: Prompt)')]
    [ValidateSet('0', '3', '1')]
    [System.Nullable[System.Int32]] $IZ_PolicyAccessDataSourcesAcrossDomains_1_IZ_Partname1406

    [DscProperty()]
    [System.ComponentModel.Description('Allow cut, copy or paste operations from the clipboard via script (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $IZ_PolicyAllowPasteViaScript_1

    [DscProperty()]
    [System.ComponentModel.Description('Allow paste operations via script - Depends on IZ_PolicyAllowPasteViaScript_1 (0: Enable, 3: Disable, 1: Prompt)')]
    [ValidateSet('0', '3', '1')]
    [System.Nullable[System.Int32]] $IZ_PolicyAllowPasteViaScript_1_IZ_Partname1407

    [DscProperty()]
    [System.ComponentModel.Description('Allow drag and drop or copy and paste files (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $IZ_PolicyDropOrPasteFiles_1

    [DscProperty()]
    [System.ComponentModel.Description('Allow drag and drop or copy and paste files - Depends on IZ_PolicyDropOrPasteFiles_1 (0: Enable, 3: Disable, 1: Prompt)')]
    [ValidateSet('0', '3', '1')]
    [System.Nullable[System.Int32]] $IZ_PolicyDropOrPasteFiles_1_IZ_Partname1802

    [DscProperty()]
    [System.ComponentModel.Description('Allow loading of XAML files (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $IZ_Policy_XAML_1

    [DscProperty()]
    [System.ComponentModel.Description('XAML Files - Depends on IZ_Policy_XAML_1 (0: Enable, 3: Disable, 1: Prompt)')]
    [ValidateSet('0', '3', '1')]
    [System.Nullable[System.Int32]] $IZ_Policy_XAML_1_IZ_Partname2402

    [DscProperty()]
    [System.ComponentModel.Description('Allow only approved domains to use ActiveX controls without prompt (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $IZ_PolicyOnlyAllowApprovedDomainsToUseActiveXWithoutPrompt_Both_Internet

    [DscProperty()]
    [System.ComponentModel.Description('Only allow approved domains to use ActiveX controls without prompt - Depends on IZ_PolicyOnlyAllowApprovedDomainsToUseActiveXWithoutPrompt_Both_Internet (3: Enable, 0: Disable)')]
    [ValidateSet('3', '0')]
    [System.Nullable[System.Int32]] $IZ_PolicyOnlyAllowApprovedDomainsToUseActiveXWithoutPrompt_Both_Internet_IZ_Partname120b

    [DscProperty()]
    [System.ComponentModel.Description('Allow only approved domains to use the TDC ActiveX control (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $IZ_PolicyAllowTDCControl_Both_Internet

    [DscProperty()]
    [System.ComponentModel.Description('Only allow approved domains to use the TDC ActiveX control - Depends on IZ_PolicyAllowTDCControl_Both_Internet (3: Enable, 0: Disable)')]
    [ValidateSet('3', '0')]
    [System.Nullable[System.Int32]] $IZ_PolicyAllowTDCControl_Both_Internet_IZ_Partname120c

    [DscProperty()]
    [System.ComponentModel.Description('Allow script-initiated windows without size or position constraints (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $IZ_PolicyWindowsRestrictionsURLaction_1

    [DscProperty()]
    [System.ComponentModel.Description('Allow script-initiated windows without size or position constraints - Depends on IZ_PolicyWindowsRestrictionsURLaction_1 (0: Enable, 3: Disable)')]
    [ValidateSet('0', '3')]
    [System.Nullable[System.Int32]] $IZ_PolicyWindowsRestrictionsURLaction_1_IZ_Partname2102

    [DscProperty()]
    [System.ComponentModel.Description('Allow scripting of Internet Explorer WebBrowser controls (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $IZ_Policy_WebBrowserControl_1

    [DscProperty()]
    [System.ComponentModel.Description('Internet Explorer web browser control - Depends on IZ_Policy_WebBrowserControl_1 (0: Enable, 3: Disable)')]
    [ValidateSet('0', '3')]
    [System.Nullable[System.Int32]] $IZ_Policy_WebBrowserControl_1_IZ_Partname1206

    [DscProperty()]
    [System.ComponentModel.Description('Allow scriptlets (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $IZ_Policy_AllowScriptlets_1

    [DscProperty()]
    [System.ComponentModel.Description('Scriptlets - Depends on IZ_Policy_AllowScriptlets_1 (0: Enable, 3: Disable)')]
    [ValidateSet('0', '3')]
    [System.Nullable[System.Int32]] $IZ_Policy_AllowScriptlets_1_IZ_Partname1209

    [DscProperty()]
    [System.ComponentModel.Description('Allow updates to status bar via script (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $IZ_Policy_ScriptStatusBar_1

    [DscProperty()]
    [System.ComponentModel.Description('Status bar updates via script - Depends on IZ_Policy_ScriptStatusBar_1 (0: Enable, 3: Disable)')]
    [ValidateSet('0', '3')]
    [System.Nullable[System.Int32]] $IZ_Policy_ScriptStatusBar_1_IZ_Partname2103

    [DscProperty()]
    [System.ComponentModel.Description('Allow VBScript to run in Internet Explorer (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $IZ_PolicyAllowVBScript_1

    [DscProperty()]
    [System.ComponentModel.Description('Allow VBScript to run in Internet Explorer - Depends on IZ_PolicyAllowVBScript_1 (0: Enable, 3: Disable, 1: Prompt)')]
    [ValidateSet('0', '3', '1')]
    [System.Nullable[System.Int32]] $IZ_PolicyAllowVBScript_1_IZ_Partname140C

    [DscProperty()]
    [System.ComponentModel.Description('Automatic prompting for file downloads (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $IZ_PolicyNotificationBarDownloadURLaction_1

    [DscProperty()]
    [System.ComponentModel.Description('Automatic prompting for file downloads - Depends on IZ_PolicyNotificationBarDownloadURLaction_1 (0: Enable, 3: Disable)')]
    [ValidateSet('0', '3')]
    [System.Nullable[System.Int32]] $IZ_PolicyNotificationBarDownloadURLaction_1_IZ_Partname2200

    [DscProperty()]
    [System.ComponentModel.Description('Don''t run antimalware programs against ActiveX controls (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $IZ_PolicyAntiMalwareCheckingOfActiveXControls_1

    [DscProperty()]
    [System.ComponentModel.Description('Don''t run antimalware programs against ActiveX controls - Depends on IZ_PolicyAntiMalwareCheckingOfActiveXControls_1 (3: Enable, 0: Disable)')]
    [ValidateSet('3', '0')]
    [System.Nullable[System.Int32]] $IZ_PolicyAntiMalwareCheckingOfActiveXControls_1_IZ_Partname270C

    [DscProperty()]
    [System.ComponentModel.Description('Download signed ActiveX controls (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $IZ_PolicyDownloadSignedActiveX_1

    [DscProperty()]
    [System.ComponentModel.Description('Download signed ActiveX controls - Depends on IZ_PolicyDownloadSignedActiveX_1 (0: Enable, 3: Disable, 1: Prompt)')]
    [ValidateSet('0', '3', '1')]
    [System.Nullable[System.Int32]] $IZ_PolicyDownloadSignedActiveX_1_IZ_Partname1001

    [DscProperty()]
    [System.ComponentModel.Description('Download unsigned ActiveX controls (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $IZ_PolicyDownloadUnsignedActiveX_1

    [DscProperty()]
    [System.ComponentModel.Description('Download unsigned ActiveX controls - Depends on IZ_PolicyDownloadUnsignedActiveX_1 (0: Enable, 3: Disable, 1: Prompt)')]
    [ValidateSet('0', '3', '1')]
    [System.Nullable[System.Int32]] $IZ_PolicyDownloadUnsignedActiveX_1_IZ_Partname1004

    [DscProperty()]
    [System.ComponentModel.Description('Enable dragging of content from different domains across windows (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $IZ_PolicyDragDropAcrossDomainsAcrossWindows_Both_Internet

    [DscProperty()]
    [System.ComponentModel.Description('Enable dragging of content from different domains across windows - Depends on IZ_PolicyDragDropAcrossDomainsAcrossWindows_Both_Internet (0: Enable, 3: Disable)')]
    [ValidateSet('0', '3')]
    [System.Nullable[System.Int32]] $IZ_PolicyDragDropAcrossDomainsAcrossWindows_Both_Internet_IZ_Partname2709

    [DscProperty()]
    [System.ComponentModel.Description('Enable dragging of content from different domains within a window (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $IZ_PolicyDragDropAcrossDomainsWithinWindow_Both_Internet

    [DscProperty()]
    [System.ComponentModel.Description('Enable dragging of content from different domains within a window - Depends on IZ_PolicyDragDropAcrossDomainsWithinWindow_Both_Internet (0: Enable, 3: Disable)')]
    [ValidateSet('0', '3')]
    [System.Nullable[System.Int32]] $IZ_PolicyDragDropAcrossDomainsWithinWindow_Both_Internet_IZ_Partname2708

    [DscProperty()]
    [System.ComponentModel.Description('Include local path when user is uploading files to a server (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $IZ_Policy_LocalPathForUpload_1

    [DscProperty()]
    [System.ComponentModel.Description('Include local directory path when uploading files to a server - Depends on IZ_Policy_LocalPathForUpload_1 (0: Enable, 3: Disable)')]
    [ValidateSet('0', '3')]
    [System.Nullable[System.Int32]] $IZ_Policy_LocalPathForUpload_1_IZ_Partname160A

    [DscProperty()]
    [System.ComponentModel.Description('Initialize and script ActiveX controls not marked as safe (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $IZ_PolicyScriptActiveXNotMarkedSafe_1

    [DscProperty()]
    [System.ComponentModel.Description('Initialize and script ActiveX controls not marked as safe - Depends on IZ_PolicyScriptActiveXNotMarkedSafe_1 (0: Enable, 3: Disable, 1: Prompt)')]
    [ValidateSet('0', '3', '1')]
    [System.Nullable[System.Int32]] $IZ_PolicyScriptActiveXNotMarkedSafe_1_IZ_Partname1201

    [DscProperty()]
    [System.ComponentModel.Description('Java permissions (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $IZ_PolicyJavaPermissions_1

    [DscProperty()]
    [System.ComponentModel.Description('Java permissions - Depends on IZ_PolicyJavaPermissions_1 (65536: High safety, 131072: Medium safety, 196608: Low safety, 8388608: Custom, 0: Disable Java)')]
    [ValidateSet('65536', '131072', '196608', '8388608', '0')]
    [System.String] $IZ_PolicyJavaPermissions_1_IZ_Partname1C00

    [DscProperty()]
    [System.ComponentModel.Description('Launching applications and files in an IFRAME (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $IZ_PolicyLaunchAppsAndFilesInIFRAME_1

    [DscProperty()]
    [System.ComponentModel.Description('Launching applications and files in an IFRAME - Depends on IZ_PolicyLaunchAppsAndFilesInIFRAME_1 (0: Enable, 3: Disable, 1: Prompt)')]
    [ValidateSet('0', '3', '1')]
    [System.Nullable[System.Int32]] $IZ_PolicyLaunchAppsAndFilesInIFRAME_1_IZ_Partname1804

    [DscProperty()]
    [System.ComponentModel.Description('Logon options (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $IZ_PolicyLogon_1

    [DscProperty()]
    [System.ComponentModel.Description('Logon options - Depends on IZ_PolicyLogon_1 (196608: Anonymous logon, 131072: Automatic logon only in Intranet zone, 0: Automatic logon with current username and password, 65536: Prompt for user name and password)')]
    [ValidateSet('196608', '131072', '0', '65536')]
    [System.Nullable[System.Int32]] $IZ_PolicyLogon_1_IZ_Partname1A00

    [DscProperty()]
    [System.ComponentModel.Description('Navigate windows and frames across different domains (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $IZ_PolicyNavigateSubframesAcrossDomains_1

    [DscProperty()]
    [System.ComponentModel.Description('Navigate windows and frames across different domains - Depends on IZ_PolicyNavigateSubframesAcrossDomains_1 (0: Enable, 3: Disable, 1: Prompt)')]
    [ValidateSet('0', '3', '1')]
    [System.Nullable[System.Int32]] $IZ_PolicyNavigateSubframesAcrossDomains_1_IZ_Partname1607

    [DscProperty()]
    [System.ComponentModel.Description('Run .NET Framework-reliant components not signed with Authenticode (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $IZ_PolicyUnsignedFrameworkComponentsURLaction_1

    [DscProperty()]
    [System.ComponentModel.Description('Run .NET Framework-reliant components not signed with Authenticode - Depends on IZ_PolicyUnsignedFrameworkComponentsURLaction_1 (0: Enable, 3: Disable, 1: Prompt)')]
    [ValidateSet('0', '3', '1')]
    [System.Nullable[System.Int32]] $IZ_PolicyUnsignedFrameworkComponentsURLaction_1_IZ_Partname2004

    [DscProperty()]
    [System.ComponentModel.Description('Run .NET Framework-reliant components signed with Authenticode (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $IZ_PolicySignedFrameworkComponentsURLaction_1

    [DscProperty()]
    [System.ComponentModel.Description('Run .NET Framework-reliant components signed with Authenticode - Depends on IZ_PolicySignedFrameworkComponentsURLaction_1 (0: Enable, 3: Disable, 1: Prompt)')]
    [ValidateSet('0', '3', '1')]
    [System.Nullable[System.Int32]] $IZ_PolicySignedFrameworkComponentsURLaction_1_IZ_Partname2001

    [DscProperty()]
    [System.ComponentModel.Description('Show security warning for potentially unsafe files (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $IZ_Policy_UnsafeFiles_1

    [DscProperty()]
    [System.ComponentModel.Description('Launching programs and unsafe files - Depends on IZ_Policy_UnsafeFiles_1 (0: Enable, 3: Disable, 1: Prompt)')]
    [ValidateSet('0', '3', '1')]
    [System.Nullable[System.Int32]] $IZ_Policy_UnsafeFiles_1_IZ_Partname1806

    [DscProperty()]
    [System.ComponentModel.Description('Turn on Cross-Site Scripting Filter (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $IZ_PolicyTurnOnXSSFilter_Both_Internet

    [DscProperty()]
    [System.ComponentModel.Description('Turn on Cross-Site Scripting (XSS) Filter - Depends on IZ_PolicyTurnOnXSSFilter_Both_Internet (0: Enable, 3: Disable)')]
    [ValidateSet('0', '3')]
    [System.Nullable[System.Int32]] $IZ_PolicyTurnOnXSSFilter_Both_Internet_IZ_Partname1409

    [DscProperty()]
    [System.ComponentModel.Description('Turn on Protected Mode (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $IZ_Policy_TurnOnProtectedMode_1

    [DscProperty()]
    [System.ComponentModel.Description('Protected Mode - Depends on IZ_Policy_TurnOnProtectedMode_1 (0: Enable, 3: Disable)')]
    [ValidateSet('0', '3')]
    [System.Nullable[System.Int32]] $IZ_Policy_TurnOnProtectedMode_1_IZ_Partname2500

    [DscProperty()]
    [System.ComponentModel.Description('Turn on SmartScreen Filter scan (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $IZ_Policy_Phishing_1

    [DscProperty()]
    [System.ComponentModel.Description('Use SmartScreen Filter - Depends on IZ_Policy_Phishing_1 (0: Enable, 3: Disable)')]
    [ValidateSet('0', '3')]
    [System.Nullable[System.Int32]] $IZ_Policy_Phishing_1_IZ_Partname2301

    [DscProperty()]
    [System.ComponentModel.Description('Use Pop-up Blocker (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $IZ_PolicyBlockPopupWindows_1

    [DscProperty()]
    [System.ComponentModel.Description('Use Pop-up Blocker - Depends on IZ_PolicyBlockPopupWindows_1 (0: Enable, 3: Disable)')]
    [ValidateSet('0', '3')]
    [System.Nullable[System.Int32]] $IZ_PolicyBlockPopupWindows_1_IZ_Partname1809

    [DscProperty()]
    [System.ComponentModel.Description('Userdata persistence (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $IZ_PolicyUserdataPersistence_1

    [DscProperty()]
    [System.ComponentModel.Description('Userdata persistence - Depends on IZ_PolicyUserdataPersistence_1 (0: Enable, 3: Disable)')]
    [ValidateSet('0', '3')]
    [System.Nullable[System.Int32]] $IZ_PolicyUserdataPersistence_1_IZ_Partname1606

    [DscProperty()]
    [System.ComponentModel.Description('Web sites in less privileged Web content zones can navigate into this zone (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $IZ_PolicyZoneElevationURLaction_1

    [DscProperty()]
    [System.ComponentModel.Description('Web sites in less privileged Web content zones can navigate into this zone - Depends on IZ_PolicyZoneElevationURLaction_1 (0: Enable, 3: Disable, 1: Prompt)')]
    [ValidateSet('0', '3', '1')]
    [System.Nullable[System.Int32]] $IZ_PolicyZoneElevationURLaction_1_IZ_Partname2101

    [DscProperty()]
    [System.ComponentModel.Description('Intranet Sites: Include all network paths (UNCs) (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $IZ_UNCAsIntranet

    [DscProperty()]
    [System.ComponentModel.Description('Don''t run antimalware programs against ActiveX controls (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $IZ_PolicyAntiMalwareCheckingOfActiveXControls_3

    [DscProperty()]
    [System.ComponentModel.Description('Don''t run antimalware programs against ActiveX controls - Depends on IZ_PolicyAntiMalwareCheckingOfActiveXControls_3 (3: Enable, 0: Disable)')]
    [ValidateSet('3', '0')]
    [System.Nullable[System.Int32]] $IZ_PolicyAntiMalwareCheckingOfActiveXControls_3_IZ_Partname270C

    [DscProperty()]
    [System.ComponentModel.Description('Initialize and script ActiveX controls not marked as safe (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $IZ_PolicyScriptActiveXNotMarkedSafe_3

    [DscProperty()]
    [System.ComponentModel.Description('Initialize and script ActiveX controls not marked as safe - Depends on IZ_PolicyScriptActiveXNotMarkedSafe_3 (0: Enable, 3: Disable, 1: Prompt)')]
    [ValidateSet('0', '3', '1')]
    [System.Nullable[System.Int32]] $IZ_PolicyScriptActiveXNotMarkedSafe_3_IZ_Partname1201

    [DscProperty()]
    [System.ComponentModel.Description('Java permissions (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $IZ_PolicyJavaPermissions_3

    [DscProperty()]
    [System.ComponentModel.Description('Java permissions - Depends on IZ_PolicyJavaPermissions_3 (65536: High safety, 131072: Medium safety, 196608: Low safety, 8388608: Custom, 0: Disable Java)')]
    [ValidateSet('65536', '131072', '196608', '8388608', '0')]
    [System.String] $IZ_PolicyJavaPermissions_3_IZ_Partname1C00

    [DscProperty()]
    [System.ComponentModel.Description('Don''t run antimalware programs against ActiveX controls (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $IZ_PolicyAntiMalwareCheckingOfActiveXControls_9

    [DscProperty()]
    [System.ComponentModel.Description('Don''t run antimalware programs against ActiveX controls - Depends on IZ_PolicyAntiMalwareCheckingOfActiveXControls_9 (3: Enable, 0: Disable)')]
    [ValidateSet('3', '0')]
    [System.Nullable[System.Int32]] $IZ_PolicyAntiMalwareCheckingOfActiveXControls_9_IZ_Partname270C

    [DscProperty()]
    [System.ComponentModel.Description('Java permissions (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $IZ_PolicyJavaPermissions_9

    [DscProperty()]
    [System.ComponentModel.Description('Java permissions - Depends on IZ_PolicyJavaPermissions_9 (65536: High safety, 131072: Medium safety, 196608: Low safety, 8388608: Custom, 0: Disable Java)')]
    [ValidateSet('65536', '131072', '196608', '8388608', '0')]
    [System.String] $IZ_PolicyJavaPermissions_9_IZ_Partname1C00

    [DscProperty()]
    [System.ComponentModel.Description('Turn on SmartScreen Filter scan (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $IZ_Policy_Phishing_2

    [DscProperty()]
    [System.ComponentModel.Description('Use SmartScreen Filter - Depends on IZ_Policy_Phishing_2 (0: Enable, 3: Disable)')]
    [ValidateSet('0', '3')]
    [System.Nullable[System.Int32]] $IZ_Policy_Phishing_2_IZ_Partname2301

    [DscProperty()]
    [System.ComponentModel.Description('Java permissions (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $IZ_PolicyJavaPermissions_4

    [DscProperty()]
    [System.ComponentModel.Description('Java permissions - Depends on IZ_PolicyJavaPermissions_4 (65536: High safety, 131072: Medium safety, 196608: Low safety, 8388608: Custom, 0: Disable Java)')]
    [ValidateSet('65536', '131072', '196608', '8388608', '0')]
    [System.String] $IZ_PolicyJavaPermissions_4_IZ_Partname1C00

    [DscProperty()]
    [System.ComponentModel.Description('Java permissions (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $IZ_PolicyJavaPermissions_10

    [DscProperty()]
    [System.ComponentModel.Description('Java permissions - Depends on IZ_PolicyJavaPermissions_10 (65536: High safety, 131072: Medium safety, 196608: Low safety, 8388608: Custom, 0: Disable Java)')]
    [ValidateSet('65536', '131072', '196608', '8388608', '0')]
    [System.String] $IZ_PolicyJavaPermissions_10_IZ_Partname1C00

    [DscProperty()]
    [System.ComponentModel.Description('Java permissions (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $IZ_PolicyJavaPermissions_8

    [DscProperty()]
    [System.ComponentModel.Description('Java permissions - Depends on IZ_PolicyJavaPermissions_8 (65536: High safety, 131072: Medium safety, 196608: Low safety, 8388608: Custom, 0: Disable Java)')]
    [ValidateSet('65536', '131072', '196608', '8388608', '0')]
    [System.String] $IZ_PolicyJavaPermissions_8_IZ_Partname1C00

    [DscProperty()]
    [System.ComponentModel.Description('Turn on SmartScreen Filter scan (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $IZ_Policy_Phishing_8

    [DscProperty()]
    [System.ComponentModel.Description('Use SmartScreen Filter - Depends on IZ_Policy_Phishing_8 (0: Enable, 3: Disable)')]
    [ValidateSet('0', '3')]
    [System.Nullable[System.Int32]] $IZ_Policy_Phishing_8_IZ_Partname2301

    [DscProperty()]
    [System.ComponentModel.Description('Java permissions (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $IZ_PolicyJavaPermissions_6

    [DscProperty()]
    [System.ComponentModel.Description('Java permissions - Depends on IZ_PolicyJavaPermissions_6 (65536: High safety, 131072: Medium safety, 196608: Low safety, 8388608: Custom, 0: Disable Java)')]
    [ValidateSet('65536', '131072', '196608', '8388608', '0')]
    [System.String] $IZ_PolicyJavaPermissions_6_IZ_Partname1C00

    [DscProperty()]
    [System.ComponentModel.Description('Access data sources across domains (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $IZ_PolicyAccessDataSourcesAcrossDomains_7

    [DscProperty()]
    [System.ComponentModel.Description('Access data sources across domains - Depends on IZ_PolicyAccessDataSourcesAcrossDomains_7 (0: Enable, 3: Disable, 1: Prompt)')]
    [ValidateSet('0', '3', '1')]
    [System.Nullable[System.Int32]] $IZ_PolicyAccessDataSourcesAcrossDomains_7_IZ_Partname1406

    [DscProperty()]
    [System.ComponentModel.Description('Allow active scripting (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $IZ_PolicyActiveScripting_7

    [DscProperty()]
    [System.ComponentModel.Description('Allow active scripting - Depends on IZ_PolicyActiveScripting_7 (0: Enable, 3: Disable, 1: Prompt)')]
    [ValidateSet('0', '3', '1')]
    [System.Nullable[System.Int32]] $IZ_Partname1400

    [DscProperty()]
    [System.ComponentModel.Description('Allow binary and script behaviors (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $IZ_PolicyBinaryBehaviors_7

    [DscProperty()]
    [System.ComponentModel.Description('Allow Binary and Script Behaviors - Depends on IZ_PolicyBinaryBehaviors_7 (0: Enable, 65536: Administrator approved, 3: Disable)')]
    [ValidateSet('0', '65536', '3')]
    [System.Nullable[System.Int32]] $IZ_Partname2000

    [DscProperty()]
    [System.ComponentModel.Description('Allow cut, copy or paste operations from the clipboard via script (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $IZ_PolicyAllowPasteViaScript_7

    [DscProperty()]
    [System.ComponentModel.Description('Allow paste operations via script - Depends on IZ_PolicyAllowPasteViaScript_7 (0: Enable, 3: Disable, 1: Prompt)')]
    [ValidateSet('0', '3', '1')]
    [System.Nullable[System.Int32]] $IZ_PolicyAllowPasteViaScript_7_IZ_Partname1407

    [DscProperty()]
    [System.ComponentModel.Description('Allow drag and drop or copy and paste files (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $IZ_PolicyDropOrPasteFiles_7

    [DscProperty()]
    [System.ComponentModel.Description('Allow drag and drop or copy and paste files - Depends on IZ_PolicyDropOrPasteFiles_7 (0: Enable, 3: Disable, 1: Prompt)')]
    [ValidateSet('0', '3', '1')]
    [System.Nullable[System.Int32]] $IZ_PolicyDropOrPasteFiles_7_IZ_Partname1802

    [DscProperty()]
    [System.ComponentModel.Description('Allow file downloads (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $IZ_PolicyFileDownload_7

    [DscProperty()]
    [System.ComponentModel.Description('Allow file downloads - Depends on IZ_PolicyFileDownload_7 (0: Enable, 3: Disable)')]
    [ValidateSet('0', '3')]
    [System.Nullable[System.Int32]] $IZ_Partname1803

    [DscProperty()]
    [System.ComponentModel.Description('Allow loading of XAML files (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $IZ_Policy_XAML_7

    [DscProperty()]
    [System.ComponentModel.Description('XAML Files - Depends on IZ_Policy_XAML_7 (0: Enable, 3: Disable, 1: Prompt)')]
    [ValidateSet('0', '3', '1')]
    [System.Nullable[System.Int32]] $IZ_Policy_XAML_7_IZ_Partname2402

    [DscProperty()]
    [System.ComponentModel.Description('Allow META REFRESH (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $IZ_PolicyAllowMETAREFRESH_7

    [DscProperty()]
    [System.ComponentModel.Description('Allow META REFRESH - Depends on IZ_PolicyAllowMETAREFRESH_7 (0: Enable, 3: Disable)')]
    [ValidateSet('0', '3')]
    [System.Nullable[System.Int32]] $IZ_Partname1608

    [DscProperty()]
    [System.ComponentModel.Description('Allow only approved domains to use ActiveX controls without prompt (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $IZ_PolicyOnlyAllowApprovedDomainsToUseActiveXWithoutPrompt_Both_Restricted

    [DscProperty()]
    [System.ComponentModel.Description('Only allow approved domains to use ActiveX controls without prompt - Depends on IZ_PolicyOnlyAllowApprovedDomainsToUseActiveXWithoutPrompt_Both_Restricted (3: Enable, 0: Disable)')]
    [ValidateSet('3', '0')]
    [System.Nullable[System.Int32]] $IZ_PolicyOnlyAllowApprovedDomainsToUseActiveXWithoutPrompt_Both_Restricted_IZ_Partname120b

    [DscProperty()]
    [System.ComponentModel.Description('Allow only approved domains to use the TDC ActiveX control (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $IZ_PolicyAllowTDCControl_Both_Restricted

    [DscProperty()]
    [System.ComponentModel.Description('Only allow approved domains to use the TDC ActiveX control - Depends on IZ_PolicyAllowTDCControl_Both_Restricted (3: Enable, 0: Disable)')]
    [ValidateSet('3', '0')]
    [System.Nullable[System.Int32]] $IZ_PolicyAllowTDCControl_Both_Restricted_IZ_Partname120c

    [DscProperty()]
    [System.ComponentModel.Description('Allow script-initiated windows without size or position constraints (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $IZ_PolicyWindowsRestrictionsURLaction_7

    [DscProperty()]
    [System.ComponentModel.Description('Allow script-initiated windows without size or position constraints - Depends on IZ_PolicyWindowsRestrictionsURLaction_7 (0: Enable, 3: Disable)')]
    [ValidateSet('0', '3')]
    [System.Nullable[System.Int32]] $IZ_PolicyWindowsRestrictionsURLaction_7_IZ_Partname2102

    [DscProperty()]
    [System.ComponentModel.Description('Allow scripting of Internet Explorer WebBrowser controls (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $IZ_Policy_WebBrowserControl_7

    [DscProperty()]
    [System.ComponentModel.Description('Internet Explorer web browser control - Depends on IZ_Policy_WebBrowserControl_7 (0: Enable, 3: Disable)')]
    [ValidateSet('0', '3')]
    [System.Nullable[System.Int32]] $IZ_Policy_WebBrowserControl_7_IZ_Partname1206

    [DscProperty()]
    [System.ComponentModel.Description('Allow scriptlets (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $IZ_Policy_AllowScriptlets_7

    [DscProperty()]
    [System.ComponentModel.Description('Scriptlets - Depends on IZ_Policy_AllowScriptlets_7 (0: Enable, 3: Disable)')]
    [ValidateSet('0', '3')]
    [System.Nullable[System.Int32]] $IZ_Policy_AllowScriptlets_7_IZ_Partname1209

    [DscProperty()]
    [System.ComponentModel.Description('Allow updates to status bar via script (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $IZ_Policy_ScriptStatusBar_7

    [DscProperty()]
    [System.ComponentModel.Description('Status bar updates via script - Depends on IZ_Policy_ScriptStatusBar_7 (0: Enable, 3: Disable)')]
    [ValidateSet('0', '3')]
    [System.Nullable[System.Int32]] $IZ_Policy_ScriptStatusBar_7_IZ_Partname2103

    [DscProperty()]
    [System.ComponentModel.Description('Allow VBScript to run in Internet Explorer (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $IZ_PolicyAllowVBScript_7

    [DscProperty()]
    [System.ComponentModel.Description('Allow VBScript to run in Internet Explorer - Depends on IZ_PolicyAllowVBScript_7 (0: Enable, 3: Disable, 1: Prompt)')]
    [ValidateSet('0', '3', '1')]
    [System.Nullable[System.Int32]] $IZ_PolicyAllowVBScript_7_IZ_Partname140C

    [DscProperty()]
    [System.ComponentModel.Description('Automatic prompting for file downloads (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $IZ_PolicyNotificationBarDownloadURLaction_7

    [DscProperty()]
    [System.ComponentModel.Description('Automatic prompting for file downloads - Depends on IZ_PolicyNotificationBarDownloadURLaction_7 (0: Enable, 3: Disable)')]
    [ValidateSet('0', '3')]
    [System.Nullable[System.Int32]] $IZ_PolicyNotificationBarDownloadURLaction_7_IZ_Partname2200

    [DscProperty()]
    [System.ComponentModel.Description('Don''t run antimalware programs against ActiveX controls (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $IZ_PolicyAntiMalwareCheckingOfActiveXControls_7

    [DscProperty()]
    [System.ComponentModel.Description('Don''t run antimalware programs against ActiveX controls - Depends on IZ_PolicyAntiMalwareCheckingOfActiveXControls_7 (3: Enable, 0: Disable)')]
    [ValidateSet('3', '0')]
    [System.Nullable[System.Int32]] $IZ_PolicyAntiMalwareCheckingOfActiveXControls_7_IZ_Partname270C

    [DscProperty()]
    [System.ComponentModel.Description('Download signed ActiveX controls (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $IZ_PolicyDownloadSignedActiveX_7

    [DscProperty()]
    [System.ComponentModel.Description('Download signed ActiveX controls - Depends on IZ_PolicyDownloadSignedActiveX_7 (0: Enable, 3: Disable, 1: Prompt)')]
    [ValidateSet('0', '3', '1')]
    [System.Nullable[System.Int32]] $IZ_PolicyDownloadSignedActiveX_7_IZ_Partname1001

    [DscProperty()]
    [System.ComponentModel.Description('Download unsigned ActiveX controls (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $IZ_PolicyDownloadUnsignedActiveX_7

    [DscProperty()]
    [System.ComponentModel.Description('Download unsigned ActiveX controls - Depends on IZ_PolicyDownloadUnsignedActiveX_7 (0: Enable, 3: Disable, 1: Prompt)')]
    [ValidateSet('0', '3', '1')]
    [System.Nullable[System.Int32]] $IZ_PolicyDownloadUnsignedActiveX_7_IZ_Partname1004

    [DscProperty()]
    [System.ComponentModel.Description('Enable dragging of content from different domains across windows (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $IZ_PolicyDragDropAcrossDomainsAcrossWindows_Both_Restricted

    [DscProperty()]
    [System.ComponentModel.Description('Enable dragging of content from different domains across windows - Depends on IZ_PolicyDragDropAcrossDomainsAcrossWindows_Both_Restricted (0: Enable, 3: Disable)')]
    [ValidateSet('0', '3')]
    [System.Nullable[System.Int32]] $IZ_PolicyDragDropAcrossDomainsAcrossWindows_Both_Restricted_IZ_Partname2709

    [DscProperty()]
    [System.ComponentModel.Description('Enable dragging of content from different domains within a window (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $IZ_PolicyDragDropAcrossDomainsWithinWindow_Both_Restricted

    [DscProperty()]
    [System.ComponentModel.Description('Enable dragging of content from different domains within a window - Depends on IZ_PolicyDragDropAcrossDomainsWithinWindow_Both_Restricted (0: Enable, 3: Disable)')]
    [ValidateSet('0', '3')]
    [System.Nullable[System.Int32]] $IZ_PolicyDragDropAcrossDomainsWithinWindow_Both_Restricted_IZ_Partname2708

    [DscProperty()]
    [System.ComponentModel.Description('Include local path when user is uploading files to a server (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $IZ_Policy_LocalPathForUpload_7

    [DscProperty()]
    [System.ComponentModel.Description('Include local directory path when uploading files to a server - Depends on IZ_Policy_LocalPathForUpload_7 (0: Enable, 3: Disable)')]
    [ValidateSet('0', '3')]
    [System.Nullable[System.Int32]] $IZ_Policy_LocalPathForUpload_7_IZ_Partname160A

    [DscProperty()]
    [System.ComponentModel.Description('Initialize and script ActiveX controls not marked as safe (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $IZ_PolicyScriptActiveXNotMarkedSafe_7

    [DscProperty()]
    [System.ComponentModel.Description('Initialize and script ActiveX controls not marked as safe - Depends on IZ_PolicyScriptActiveXNotMarkedSafe_7 (0: Enable, 3: Disable, 1: Prompt)')]
    [ValidateSet('0', '3', '1')]
    [System.Nullable[System.Int32]] $IZ_PolicyScriptActiveXNotMarkedSafe_7_IZ_Partname1201

    [DscProperty()]
    [System.ComponentModel.Description('Java permissions (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $IZ_PolicyJavaPermissions_7

    [DscProperty()]
    [System.ComponentModel.Description('Java permissions - Depends on IZ_PolicyJavaPermissions_7 (65536: High safety, 131072: Medium safety, 196608: Low safety, 8388608: Custom, 0: Disable Java)')]
    [ValidateSet('65536', '131072', '196608', '8388608', '0')]
    [System.String] $IZ_PolicyJavaPermissions_7_IZ_Partname1C00

    [DscProperty()]
    [System.ComponentModel.Description('Launching applications and files in an IFRAME (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $IZ_PolicyLaunchAppsAndFilesInIFRAME_7

    [DscProperty()]
    [System.ComponentModel.Description('Launching applications and files in an IFRAME - Depends on IZ_PolicyLaunchAppsAndFilesInIFRAME_7 (0: Enable, 3: Disable, 1: Prompt)')]
    [ValidateSet('0', '3', '1')]
    [System.Nullable[System.Int32]] $IZ_PolicyLaunchAppsAndFilesInIFRAME_7_IZ_Partname1804

    [DscProperty()]
    [System.ComponentModel.Description('Logon options (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $IZ_PolicyLogon_7

    [DscProperty()]
    [System.ComponentModel.Description('Logon options - Depends on IZ_PolicyLogon_7 (196608: Anonymous logon, 131072: Automatic logon only in Intranet zone, 0: Automatic logon with current username and password, 65536: Prompt for user name and password)')]
    [ValidateSet('196608', '131072', '0', '65536')]
    [System.Nullable[System.Int32]] $IZ_PolicyLogon_7_IZ_Partname1A00

    [DscProperty()]
    [System.ComponentModel.Description('Navigate windows and frames across different domains (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $IZ_PolicyNavigateSubframesAcrossDomains_7

    [DscProperty()]
    [System.ComponentModel.Description('Navigate windows and frames across different domains - Depends on IZ_PolicyNavigateSubframesAcrossDomains_7 (0: Enable, 3: Disable, 1: Prompt)')]
    [ValidateSet('0', '3', '1')]
    [System.Nullable[System.Int32]] $IZ_PolicyNavigateSubframesAcrossDomains_7_IZ_Partname1607

    [DscProperty()]
    [System.ComponentModel.Description('Run .NET Framework-reliant components not signed with Authenticode (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $IZ_PolicyUnsignedFrameworkComponentsURLaction_7

    [DscProperty()]
    [System.ComponentModel.Description('Run .NET Framework-reliant components not signed with Authenticode - Depends on IZ_PolicyUnsignedFrameworkComponentsURLaction_7 (0: Enable, 3: Disable, 1: Prompt)')]
    [ValidateSet('0', '3', '1')]
    [System.Nullable[System.Int32]] $IZ_PolicyUnsignedFrameworkComponentsURLaction_7_IZ_Partname2004

    [DscProperty()]
    [System.ComponentModel.Description('Run .NET Framework-reliant components signed with Authenticode (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $IZ_PolicySignedFrameworkComponentsURLaction_7

    [DscProperty()]
    [System.ComponentModel.Description('Run .NET Framework-reliant components signed with Authenticode - Depends on IZ_PolicySignedFrameworkComponentsURLaction_7 (0: Enable, 3: Disable, 1: Prompt)')]
    [ValidateSet('0', '3', '1')]
    [System.Nullable[System.Int32]] $IZ_PolicySignedFrameworkComponentsURLaction_7_IZ_Partname2001

    [DscProperty()]
    [System.ComponentModel.Description('Run ActiveX controls and plugins (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $IZ_PolicyRunActiveXControls_7

    [DscProperty()]
    [System.ComponentModel.Description('Run ActiveX controls and plugins - Depends on IZ_PolicyRunActiveXControls_7 (65536: Administrator approved, 0: Enable, 3: Disable, 1: Prompt)')]
    [ValidateSet('65536', '0', '3', '1')]
    [System.Nullable[System.Int32]] $IZ_Partname1200

    [DscProperty()]
    [System.ComponentModel.Description('Script ActiveX controls marked safe for scripting (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $IZ_PolicyScriptActiveXMarkedSafe_7

    [DscProperty()]
    [System.ComponentModel.Description('Script ActiveX controls marked safe for scripting - Depends on IZ_PolicyScriptActiveXMarkedSafe_7 (0: Enable, 3: Disable, 1: Prompt)')]
    [ValidateSet('0', '3', '1')]
    [System.Nullable[System.Int32]] $IZ_Partname1405

    [DscProperty()]
    [System.ComponentModel.Description('Scripting of Java applets (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $IZ_PolicyScriptingOfJavaApplets_7

    [DscProperty()]
    [System.ComponentModel.Description('Scripting of Java applets - Depends on IZ_PolicyScriptingOfJavaApplets_7 (0: Enable, 3: Disable, 1: Prompt)')]
    [ValidateSet('0', '3', '1')]
    [System.Nullable[System.Int32]] $IZ_Partname1402

    [DscProperty()]
    [System.ComponentModel.Description('Show security warning for potentially unsafe files (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $IZ_Policy_UnsafeFiles_7

    [DscProperty()]
    [System.ComponentModel.Description('Launching programs and unsafe files - Depends on IZ_Policy_UnsafeFiles_7 (0: Enable, 3: Disable, 1: Prompt)')]
    [ValidateSet('0', '3', '1')]
    [System.Nullable[System.Int32]] $IZ_Policy_UnsafeFiles_7_IZ_Partname1806

    [DscProperty()]
    [System.ComponentModel.Description('Turn on Cross-Site Scripting Filter (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $IZ_PolicyTurnOnXSSFilter_Both_Restricted

    [DscProperty()]
    [System.ComponentModel.Description('Turn on Cross-Site Scripting (XSS) Filter - Depends on IZ_PolicyTurnOnXSSFilter_Both_Restricted (0: Enable, 3: Disable)')]
    [ValidateSet('0', '3')]
    [System.Nullable[System.Int32]] $IZ_PolicyTurnOnXSSFilter_Both_Restricted_IZ_Partname1409

    [DscProperty()]
    [System.ComponentModel.Description('Turn on Protected Mode (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $IZ_Policy_TurnOnProtectedMode_7

    [DscProperty()]
    [System.ComponentModel.Description('Protected Mode - Depends on IZ_Policy_TurnOnProtectedMode_7 (0: Enable, 3: Disable)')]
    [ValidateSet('0', '3')]
    [System.Nullable[System.Int32]] $IZ_Policy_TurnOnProtectedMode_7_IZ_Partname2500

    [DscProperty()]
    [System.ComponentModel.Description('Turn on SmartScreen Filter scan (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $IZ_Policy_Phishing_7

    [DscProperty()]
    [System.ComponentModel.Description('Use SmartScreen Filter - Depends on IZ_Policy_Phishing_7 (0: Enable, 3: Disable)')]
    [ValidateSet('0', '3')]
    [System.Nullable[System.Int32]] $IZ_Policy_Phishing_7_IZ_Partname2301

    [DscProperty()]
    [System.ComponentModel.Description('Use Pop-up Blocker (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $IZ_PolicyBlockPopupWindows_7

    [DscProperty()]
    [System.ComponentModel.Description('Use Pop-up Blocker - Depends on IZ_PolicyBlockPopupWindows_7 (0: Enable, 3: Disable)')]
    [ValidateSet('0', '3')]
    [System.Nullable[System.Int32]] $IZ_PolicyBlockPopupWindows_7_IZ_Partname1809

    [DscProperty()]
    [System.ComponentModel.Description('Userdata persistence (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $IZ_PolicyUserdataPersistence_7

    [DscProperty()]
    [System.ComponentModel.Description('Userdata persistence - Depends on IZ_PolicyUserdataPersistence_7 (0: Enable, 3: Disable)')]
    [ValidateSet('0', '3')]
    [System.Nullable[System.Int32]] $IZ_PolicyUserdataPersistence_7_IZ_Partname1606

    [DscProperty()]
    [System.ComponentModel.Description('Web sites in less privileged Web content zones can navigate into this zone (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $IZ_PolicyZoneElevationURLaction_7

    [DscProperty()]
    [System.ComponentModel.Description('Web sites in less privileged Web content zones can navigate into this zone - Depends on IZ_PolicyZoneElevationURLaction_7 (0: Enable, 3: Disable, 1: Prompt)')]
    [ValidateSet('0', '3', '1')]
    [System.String] $IZ_PolicyZoneElevationURLaction_7_IZ_Partname2101

    [DscProperty()]
    [System.ComponentModel.Description('Don''t run antimalware programs against ActiveX controls (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $IZ_PolicyAntiMalwareCheckingOfActiveXControls_5

    [DscProperty()]
    [System.ComponentModel.Description('Don''t run antimalware programs against ActiveX controls - Depends on IZ_PolicyAntiMalwareCheckingOfActiveXControls_5 (3: Enable, 0: Disable)')]
    [ValidateSet('3', '0')]
    [System.Nullable[System.Int32]] $IZ_PolicyAntiMalwareCheckingOfActiveXControls_5_IZ_Partname270C

    [DscProperty()]
    [System.ComponentModel.Description('Initialize and script ActiveX controls not marked as safe (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $IZ_PolicyScriptActiveXNotMarkedSafe_5

    [DscProperty()]
    [System.ComponentModel.Description('Initialize and script ActiveX controls not marked as safe - Depends on IZ_PolicyScriptActiveXNotMarkedSafe_5 (0: Enable, 3: Disable, 1: Prompt)')]
    [ValidateSet('0', '3', '1')]
    [System.Nullable[System.Int32]] $IZ_PolicyScriptActiveXNotMarkedSafe_5_IZ_Partname1201

    [DscProperty()]
    [System.ComponentModel.Description('Java permissions (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $IZ_PolicyJavaPermissions_5

    [DscProperty()]
    [System.ComponentModel.Description('Java permissions - Depends on IZ_PolicyJavaPermissions_5 (65536: High safety, 131072: Medium safety, 196608: Low safety, 8388608: Custom, 0: Disable Java)')]
    [ValidateSet('65536', '131072', '196608', '8388608', '0')]
    [System.String] $IZ_PolicyJavaPermissions_5_IZ_Partname1C00

    [DscProperty()]
    [System.ComponentModel.Description('Turn on certificate address mismatch warning (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $IZ_PolicyWarnCertMismatch

    [DscProperty()]
    [System.ComponentModel.Description('Prevent bypassing SmartScreen Filter warnings (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $DisableSafetyFilterOverride

    [DscProperty()]
    [System.ComponentModel.Description('Prevent bypassing SmartScreen Filter warnings about files that are not commonly downloaded from the Internet (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $DisableSafetyFilterOverrideForAppRepUnknown

    [DscProperty()]
    [System.ComponentModel.Description('Prevent managing SmartScreen Filter (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $Disable_Managing_Safety_Filter_IE9

    [DscProperty()]
    [System.ComponentModel.Description('Select SmartScreen Filter mode - Depends on Disable_Managing_Safety_Filter_IE9 (0: Off, 1: On)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $IE9SafetyFilterOptions

    [DscProperty()]
    [System.ComponentModel.Description('Prevent per-user installation of ActiveX controls (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $DisablePerUserActiveXInstall

    [DscProperty()]
    [System.ComponentModel.Description('Remove ''Run this time'' button for outdated ActiveX controls in Internet Explorer (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $VerMgmtDisableRunThisTime

    [DscProperty()]
    [System.ComponentModel.Description('Turn off blocking of outdated ActiveX controls for Internet Explorer (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $VerMgmtDisable

    [DscProperty()]
    [System.ComponentModel.Description('Allow fallback to SSL 3.0 (Internet Explorer) (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $Advanced_EnableSSL3Fallback

    [DscProperty()]
    [System.ComponentModel.Description('Allow insecure fallback for: - Depends on Advanced_EnableSSL3Fallback (0: No Sites, 1: Non-Protected Mode Sites, 3: All Sites)')]
    [ValidateSet('0', '1', '3')]
    [System.Nullable[System.Int32]] $Advanced_EnableSSL3FallbackOptions

    [DscProperty()]
    [System.ComponentModel.Description('Internet Explorer Processes (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $IESF_PolicyExplorerProcesses_5

    [DscProperty()]
    [System.ComponentModel.Description('Internet Explorer Processes (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $IESF_PolicyExplorerProcesses_6

    [DscProperty()]
    [System.ComponentModel.Description('Internet Explorer Processes (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $IESF_PolicyExplorerProcesses_3

    [DscProperty()]
    [System.ComponentModel.Description('Internet Explorer Processes (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $IESF_PolicyExplorerProcesses_10

    [DscProperty()]
    [System.ComponentModel.Description('Internet Explorer Processes (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $IESF_PolicyExplorerProcesses_9

    [DscProperty()]
    [System.ComponentModel.Description('Internet Explorer Processes (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $IESF_PolicyExplorerProcesses_11

    [DscProperty()]
    [System.ComponentModel.Description('Internet Explorer Processes (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $IESF_PolicyExplorerProcesses_12

    [DscProperty()]
    [System.ComponentModel.Description('Internet Explorer Processes (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $IESF_PolicyExplorerProcesses_8

    [DscProperty()]
    [System.ComponentModel.Description('Security Zones: Do not allow users to add/delete sites (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $Security_zones_map_edit

    [DscProperty()]
    [System.ComponentModel.Description('Security Zones: Do not allow users to change policies (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $Security_options_edit

    [DscProperty()]
    [System.ComponentModel.Description('Security Zones: Use only machine settings (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $Security_HKLM_only

    [DscProperty()]
    [System.ComponentModel.Description('Specify use of ActiveX Installer Service for installation of ActiveX controls (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $OnlyUseAXISForActiveXInstall

    [DscProperty()]
    [System.ComponentModel.Description('Turn off Crash Detection (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $AddonManagement_RestrictCrashDetection

    [DscProperty()]
    [System.ComponentModel.Description('Turn off the Security Settings Check feature (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $Disable_Security_Settings_Check

    [DscProperty()]
    [System.ComponentModel.Description('Configure the ''Block at First Sight'' feature (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $DisableBlockAtFirstSeen

    [DscProperty()]
    [System.ComponentModel.Description('Turn on process scanning whenever real-time protection is enabled (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $RealtimeProtection_DisableScanOnRealtimeEnable

    [DscProperty()]
    [System.ComponentModel.Description('Scan packed executables (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $Scan_DisablePackedExeScanning

    [DscProperty()]
    [System.ComponentModel.Description('Turn off routine remediation (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $DisableRoutinelyTakingAction

    [DscProperty()]
    [System.ComponentModel.Description('Do not allow passwords to be saved (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $TS_CLIENT_DISABLE_PASSWORD_SAVING_2

    [DscProperty()]
    [System.ComponentModel.Description('Do not allow drive redirection (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $TS_CLIENT_DRIVE_M

    [DscProperty()]
    [System.ComponentModel.Description('Always prompt for password upon connection (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $TS_PASSWORD

    [DscProperty()]
    [System.ComponentModel.Description('Require secure RPC communication (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $TS_RPC_ENCRYPTION

    [DscProperty()]
    [System.ComponentModel.Description('Set client connection encryption level (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $TS_ENCRYPTION_POLICY

    [DscProperty()]
    [System.ComponentModel.Description('Encryption Level - Depends on TS_ENCRYPTION_POLICY (1: Low Level, 2: Client Compatible, 3: High Level)')]
    [ValidateSet('1', '2', '3')]
    [System.Nullable[System.Int32]] $TS_ENCRYPTION_LEVEL

    [DscProperty()]
    [System.ComponentModel.Description('Prevent downloading of enclosures (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $Disable_Downloading_of_Enclosures

    [DscProperty()]
    [System.ComponentModel.Description('Sign-in and lock last interactive user automatically after a restart (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $AutomaticRestartSignOn

    [DscProperty()]
    [System.ComponentModel.Description('Turn on PowerShell Script Block Logging (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $EnableScriptBlockLogging

    [DscProperty()]
    [System.ComponentModel.Description('Log script block invocation start / stop events: - Depends on EnableScriptBlockLogging (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $EnableScriptBlockInvocationLogging

    [DscProperty()]
    [System.ComponentModel.Description('Allow Basic authentication (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $AllowBasic_2

    [DscProperty()]
    [System.ComponentModel.Description('Allow unencrypted traffic (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $AllowUnencrypted_2

    [DscProperty()]
    [System.ComponentModel.Description('Disallow Digest authentication (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $DisallowDigest

    [DscProperty()]
    [System.ComponentModel.Description('Allow Basic authentication (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $AllowBasic_1

    [DscProperty()]
    [System.ComponentModel.Description('Allow unencrypted traffic (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $AllowUnencrypted_1

    [DscProperty()]
    [System.ComponentModel.Description('Disallow WinRM from storing RunAs credentials (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $DisableRunAs

    [DscProperty()]
    [System.ComponentModel.Description('Account Logon Audit Credential Validation (0: Off/None, 1: Success, 2: Failure, 3: Success+Failure)')]
    [ValidateSet('0', '1', '2', '3')]
    [System.Nullable[System.Int32]] $AccountLogon_AuditCredentialValidation

    [DscProperty()]
    [System.ComponentModel.Description('Account Logon Logoff Audit Account Lockout (0: Off/None, 1: Success, 2: Failure, 3: Success+Failure)')]
    [ValidateSet('0', '1', '2', '3')]
    [System.Nullable[System.Int32]] $AccountLogonLogoff_AuditAccountLockout

    [DscProperty()]
    [System.ComponentModel.Description('Account Logon Logoff Audit Group Membership (0: Off/None, 1: Success, 2: Failure, 3: Success+Failure)')]
    [ValidateSet('0', '1', '2', '3')]
    [System.Nullable[System.Int32]] $AccountLogonLogoff_AuditGroupMembership

    [DscProperty()]
    [System.ComponentModel.Description('Account Logon Logoff Audit Logon (0: Off/None, 1: Success, 2: Failure, 3: Success+Failure)')]
    [ValidateSet('0', '1', '2', '3')]
    [System.Nullable[System.Int32]] $AccountLogonLogoff_AuditLogon

    [DscProperty()]
    [System.ComponentModel.Description('Audit Authentication Policy Change (0: Off/None, 1: Success, 2: Failure, 3: Success+Failure)')]
    [ValidateSet('0', '1', '2', '3')]
    [System.Nullable[System.Int32]] $PolicyChange_AuditAuthenticationPolicyChange

    [DscProperty()]
    [System.ComponentModel.Description('Audit Changes to Audit Policy (0: Off/None, 1: Success, 2: Failure, 3: Success+Failure)')]
    [ValidateSet('0', '1', '2', '3')]
    [System.Nullable[System.Int32]] $PolicyChange_AuditPolicyChange

    [DscProperty()]
    [System.ComponentModel.Description('Audit File Share Access (0: Off/None, 1: Success, 2: Failure, 3: Success+Failure)')]
    [ValidateSet('0', '1', '2', '3')]
    [System.Nullable[System.Int32]] $ObjectAccess_AuditFileShare

    [DscProperty()]
    [System.ComponentModel.Description('Audit Other Logon Logoff Events (0: Off/None, 1: Success, 2: Failure, 3: Success+Failure)')]
    [ValidateSet('0', '1', '2', '3')]
    [System.Nullable[System.Int32]] $AccountLogonLogoff_AuditOtherLogonLogoffEvents

    [DscProperty()]
    [System.ComponentModel.Description('Audit Security Group Management (0: Off/None, 1: Success, 2: Failure, 3: Success+Failure)')]
    [ValidateSet('0', '1', '2', '3')]
    [System.Nullable[System.Int32]] $AccountManagement_AuditSecurityGroupManagement

    [DscProperty()]
    [System.ComponentModel.Description('Audit Security System Extension (0: Off/None, 1: Success, 2: Failure, 3: Success+Failure)')]
    [ValidateSet('0', '1', '2', '3')]
    [System.Nullable[System.Int32]] $System_AuditSecuritySystemExtension

    [DscProperty()]
    [System.ComponentModel.Description('Audit Special Logon (0: Off/None, 1: Success, 2: Failure, 3: Success+Failure)')]
    [ValidateSet('0', '1', '2', '3')]
    [System.Nullable[System.Int32]] $AccountLogonLogoff_AuditSpecialLogon

    [DscProperty()]
    [System.ComponentModel.Description('Audit User Account Management (0: Off/None, 1: Success, 2: Failure, 3: Success+Failure)')]
    [ValidateSet('0', '1', '2', '3')]
    [System.Nullable[System.Int32]] $AccountManagement_AuditUserAccountManagement

    [DscProperty()]
    [System.ComponentModel.Description('Detailed Tracking Audit PNP Activity (0: Off/None, 1: Success, 2: Failure, 3: Success+Failure)')]
    [ValidateSet('0', '1', '2', '3')]
    [System.Nullable[System.Int32]] $DetailedTracking_AuditPNPActivity

    [DscProperty()]
    [System.ComponentModel.Description('Detailed Tracking Audit Process Creation (0: Off/None, 1: Success, 2: Failure, 3: Success+Failure)')]
    [ValidateSet('0', '1', '2', '3')]
    [System.Nullable[System.Int32]] $DetailedTracking_AuditProcessCreation

    [DscProperty()]
    [System.ComponentModel.Description('Object Access Audit Detailed File Share (0: Off/None, 1: Success, 2: Failure, 3: Success+Failure)')]
    [ValidateSet('0', '1', '2', '3')]
    [System.Nullable[System.Int32]] $ObjectAccess_AuditDetailedFileShare

    [DscProperty()]
    [System.ComponentModel.Description('Object Access Audit Other Object Access Events (0: Off/None, 1: Success, 2: Failure, 3: Success+Failure)')]
    [ValidateSet('0', '1', '2', '3')]
    [System.Nullable[System.Int32]] $ObjectAccess_AuditOtherObjectAccessEvents

    [DscProperty()]
    [System.ComponentModel.Description('Object Access Audit Removable Storage (0: Off/None, 1: Success, 2: Failure, 3: Success+Failure)')]
    [ValidateSet('0', '1', '2', '3')]
    [System.Nullable[System.Int32]] $ObjectAccess_AuditRemovableStorage

    [DscProperty()]
    [System.ComponentModel.Description('Policy Change Audit MPSSVC Rule Level Policy Change (0: Off/None, 1: Success, 2: Failure, 3: Success+Failure)')]
    [ValidateSet('0', '1', '2', '3')]
    [System.Nullable[System.Int32]] $PolicyChange_AuditMPSSVCRuleLevelPolicyChange

    [DscProperty()]
    [System.ComponentModel.Description('Policy Change Audit Other Policy Change Events (0: Off/None, 1: Success, 2: Failure, 3: Success+Failure)')]
    [ValidateSet('0', '1', '2', '3')]
    [System.Nullable[System.Int32]] $PolicyChange_AuditOtherPolicyChangeEvents

    [DscProperty()]
    [System.ComponentModel.Description('Privilege Use Audit Sensitive Privilege Use (0: Off/None, 1: Success, 2: Failure, 3: Success+Failure)')]
    [ValidateSet('0', '1', '2', '3')]
    [System.Nullable[System.Int32]] $PrivilegeUse_AuditSensitivePrivilegeUse

    [DscProperty()]
    [System.ComponentModel.Description('System Audit Other System Events (0: Off/None, 1: Success, 2: Failure, 3: Success+Failure)')]
    [ValidateSet('0', '1', '2', '3')]
    [System.Nullable[System.Int32]] $System_AuditOtherSystemEvents

    [DscProperty()]
    [System.ComponentModel.Description('System Audit Security State Change (0: Off/None, 1: Success, 2: Failure, 3: Success+Failure)')]
    [ValidateSet('0', '1', '2', '3')]
    [System.Nullable[System.Int32]] $System_AuditSecurityStateChange

    [DscProperty()]
    [System.ComponentModel.Description('System Audit System Integrity (0: Off/None, 1: Success, 2: Failure, 3: Success+Failure)')]
    [ValidateSet('0', '1', '2', '3')]
    [System.Nullable[System.Int32]] $System_AuditSystemIntegrity

    [DscProperty()]
    [System.ComponentModel.Description('Allow Direct Memory Access (0: Not allowed., 1: Allowed.)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $AllowDirectMemoryAccess

    [DscProperty()]
    [System.ComponentModel.Description('Allow Archive Scanning (0: Not allowed. Turns off scanning on archived files., 1: Allowed. Scans the archive files.)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $AllowArchiveScanning

    [DscProperty()]
    [System.ComponentModel.Description('Allow Behavior Monitoring (0: Not allowed. Turns off behavior monitoring., 1: Allowed. Turns on real-time behavior monitoring.)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $AllowBehaviorMonitoring

    [DscProperty()]
    [System.ComponentModel.Description('Allow Cloud Protection (0: Not allowed. Turns off the Microsoft Active Protection Service., 1: Allowed. Turns on the Microsoft Active Protection Service.)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $AllowCloudProtection

    [DscProperty()]
    [System.ComponentModel.Description('Allow Full Scan Removable Drive Scanning (0: Not allowed. Turns off scanning on removable drives., 1: Allowed. Scans removable drives.)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $AllowFullScanRemovableDriveScanning

    [DscProperty()]
    [System.ComponentModel.Description('Allow On Access Protection (0: Not allowed., 1: Allowed.)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $AllowOnAccessProtection

    [DscProperty()]
    [System.ComponentModel.Description('Allow Realtime Monitoring (0: Not allowed. Turns off the real-time monitoring service., 1: Allowed. Turns on and runs the real-time monitoring service.)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $AllowRealtimeMonitoring

    [DscProperty()]
    [System.ComponentModel.Description('Allow scanning of all downloaded files and attachments (0: Not allowed., 1: Allowed.)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $AllowIOAVProtection

    [DscProperty()]
    [System.ComponentModel.Description('Allow Script Scanning (0: Not allowed., 1: Allowed.)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $AllowScriptScanning

    [DscProperty()]
    [System.ComponentModel.Description('Block execution of potentially obfuscated scripts - Depends on AttackSurfaceReductionRules (off: Off, block: Block, audit: Audit, warn: Warn)')]
    [ValidateSet('off', 'block', 'audit', 'warn')]
    [System.String] $BlockExecutionOfPotentiallyObfuscatedScripts

    [DscProperty()]
    [System.ComponentModel.Description('ASR Only Per Rule Exclusions')]
    [System.String[]] $BlockExecutionOfPotentiallyObfuscatedScripts_ASROnlyPerRuleExclusions

    [DscProperty()]
    [System.ComponentModel.Description('Block Win32 API calls from Office macros - Depends on AttackSurfaceReductionRules (off: Off, block: Block, audit: Audit, warn: Warn)')]
    [ValidateSet('off', 'block', 'audit', 'warn')]
    [System.String] $BlockWin32APICallsFromOfficeMacros

    [DscProperty()]
    [System.ComponentModel.Description('ASR Only Per Rule Exclusions')]
    [System.String[]] $BlockWin32APICallsFromOfficeMacros_ASROnlyPerRuleExclusions

    [DscProperty()]
    [System.ComponentModel.Description('Block executable files from running unless they meet a prevalence, age, or trusted list criterion - Depends on AttackSurfaceReductionRules (off: Off, block: Block, audit: Audit, warn: Warn)')]
    [ValidateSet('off', 'block', 'audit', 'warn')]
    [System.String] $BlockExecutableFilesRunningUnlessTheyMeetPrevalenceAgeTrustedListCriterion

    [DscProperty()]
    [System.ComponentModel.Description('ASR Only Per Rule Exclusions')]
    [System.String[]] $BlockExecutableFilesRunningUnlessTheyMeetPrevalenceAgeTrustedListCriterion_ASROnlyPerRuleExclusions

    [DscProperty()]
    [System.ComponentModel.Description('Block Office communication application from creating child processes - Depends on AttackSurfaceReductionRules (off: Off, block: Block, audit: Audit, warn: Warn)')]
    [ValidateSet('off', 'block', 'audit', 'warn')]
    [System.String] $BlockOfficeCommunicationAppFromCreatingChildProcesses

    [DscProperty()]
    [System.ComponentModel.Description('ASR Only Per Rule Exclusions')]
    [System.String[]] $BlockOfficeCommunicationAppFromCreatingChildProcesses_ASROnlyPerRuleExclusions

    [DscProperty()]
    [System.ComponentModel.Description('Block all Office applications from creating child processes - Depends on AttackSurfaceReductionRules (off: Off, block: Block, audit: Audit, warn: Warn)')]
    [ValidateSet('off', 'block', 'audit', 'warn')]
    [System.String] $BlockAllOfficeApplicationsFromCreatingChildProcesses

    [DscProperty()]
    [System.ComponentModel.Description('ASR Only Per Rule Exclusions')]
    [System.String[]] $BlockAllOfficeApplicationsFromCreatingChildProcesses_ASROnlyPerRuleExclusions

    [DscProperty()]
    [System.ComponentModel.Description('Block Adobe Reader from creating child processes - Depends on AttackSurfaceReductionRules (off: Off, block: Block, audit: Audit, warn: Warn)')]
    [ValidateSet('off', 'block', 'audit', 'warn')]
    [System.String] $BlockAdobeReaderFromCreatingChildProcesses

    [DscProperty()]
    [System.ComponentModel.Description('ASR Only Per Rule Exclusions')]
    [System.String[]] $BlockAdobeReaderFromCreatingChildProcesses_ASROnlyPerRuleExclusions

    [DscProperty()]
    [System.ComponentModel.Description('Block credential stealing from the Windows local security authority subsystem - Depends on AttackSurfaceReductionRules (off: Off, block: Block, audit: Audit, warn: Warn)')]
    [ValidateSet('off', 'block', 'audit', 'warn')]
    [System.String] $BlockCredentialStealingFromWindowsLocalSecurityAuthoritySubsystem

    [DscProperty()]
    [System.ComponentModel.Description('ASR Only Per Rule Exclusions')]
    [System.String[]] $BlockCredentialStealingFromWindowsLocalSecurityAuthoritySubsystem_ASROnlyPerRuleExclusions

    [DscProperty()]
    [System.ComponentModel.Description('Block JavaScript or VBScript from launching downloaded executable content - Depends on AttackSurfaceReductionRules (off: Off, block: Block, audit: Audit, warn: Warn)')]
    [ValidateSet('off', 'block', 'audit', 'warn')]
    [System.String] $BlockJavaScriptOrVBScriptFromLaunchingDownloadedExecutableContent

    [DscProperty()]
    [System.ComponentModel.Description('ASR Only Per Rule Exclusions')]
    [System.String[]] $BlockJavaScriptOrVBScriptFromLaunchingDownloadedExecutableContent_ASROnlyPerRuleExclusions

    [DscProperty()]
    [System.ComponentModel.Description('Block Webshell creation for Servers - Depends on AttackSurfaceReductionRules (off: Off, block: Block, audit: Audit, warn: Warn)')]
    [ValidateSet('off', 'block', 'audit', 'warn')]
    [System.String] $BlockWebshellCreationForServers

    [DscProperty()]
    [System.ComponentModel.Description('ASR Only Per Rule Exclusions')]
    [System.String[]] $BlockWebshellCreationForServers_ASROnlyPerRuleExclusions

    [DscProperty()]
    [System.ComponentModel.Description('Block untrusted and unsigned processes that run from USB - Depends on AttackSurfaceReductionRules (off: Off, block: Block, audit: Audit, warn: Warn)')]
    [ValidateSet('off', 'block', 'audit', 'warn')]
    [System.String] $BlockUntrustedUnsignedProcessesThatRunFromUSB

    [DscProperty()]
    [System.ComponentModel.Description('ASR Only Per Rule Exclusions')]
    [System.String[]] $BlockUntrustedUnsignedProcessesThatRunFromUSB_ASROnlyPerRuleExclusions

    [DscProperty()]
    [System.ComponentModel.Description('Block persistence through WMI event subscription - Depends on AttackSurfaceReductionRules (off: Off, block: Block, audit: Audit, warn: Warn)')]
    [ValidateSet('off', 'block', 'audit', 'warn')]
    [System.String] $BlockPersistenceThroughWMIEventSubscription

    [DscProperty()]
    [System.ComponentModel.Description('[PREVIEW] Block use of copied or impersonated system tools - Depends on AttackSurfaceReductionRules (off: Off, block: Block, audit: Audit, warn: Warn)')]
    [ValidateSet('off', 'block', 'audit', 'warn')]
    [System.String] $BlockUseOfCopiedOrImpersonatedSystemTools

    [DscProperty()]
    [System.ComponentModel.Description('ASR Only Per Rule Exclusions')]
    [System.String[]] $BlockUseOfCopiedOrImpersonatedSystemTools_ASROnlyPerRuleExclusions

    [DscProperty()]
    [System.ComponentModel.Description('Block abuse of exploited vulnerable signed drivers (Device) - Depends on AttackSurfaceReductionRules (off: Off, block: Block, audit: Audit, warn: Warn)')]
    [ValidateSet('off', 'block', 'audit', 'warn')]
    [System.String] $BlockAbuseOfExploitedVulnerableSignedDrivers

    [DscProperty()]
    [System.ComponentModel.Description('ASR Only Per Rule Exclusions')]
    [System.String[]] $BlockAbuseOfExploitedVulnerableSignedDrivers_ASROnlyPerRuleExclusions

    [DscProperty()]
    [System.ComponentModel.Description('Block process creations originating from PSExec and WMI commands - Depends on AttackSurfaceReductionRules (off: Off, block: Block, audit: Audit, warn: Warn)')]
    [ValidateSet('off', 'block', 'audit', 'warn')]
    [System.String] $BlockProcessCreationsFromPSExecAndWMICommands

    [DscProperty()]
    [System.ComponentModel.Description('ASR Only Per Rule Exclusions')]
    [System.String[]] $BlockProcessCreationsFromPSExecAndWMICommands_ASROnlyPerRuleExclusions

    [DscProperty()]
    [System.ComponentModel.Description('Block Office applications from creating executable content - Depends on AttackSurfaceReductionRules (off: Off, block: Block, audit: Audit, warn: Warn)')]
    [ValidateSet('off', 'block', 'audit', 'warn')]
    [System.String] $BlockOfficeApplicationsFromCreatingExecutableContent

    [DscProperty()]
    [System.ComponentModel.Description('ASR Only Per Rule Exclusions')]
    [System.String[]] $BlockOfficeApplicationsFromCreatingExecutableContent_ASROnlyPerRuleExclusions

    [DscProperty()]
    [System.ComponentModel.Description('Block Office applications from injecting code into other processes - Depends on AttackSurfaceReductionRules (off: Off, block: Block, audit: Audit, warn: Warn)')]
    [ValidateSet('off', 'block', 'audit', 'warn')]
    [System.String] $BlockOfficeApplicationsFromInjectingCodeIntoOtherProcesses

    [DscProperty()]
    [System.ComponentModel.Description('ASR Only Per Rule Exclusions')]
    [System.String[]] $BlockOfficeApplicationsFromInjectingCodeIntoOtherProcesses_ASROnlyPerRuleExclusions

    [DscProperty()]
    [System.ComponentModel.Description('[PREVIEW] Block rebooting machine in Safe Mode - Depends on AttackSurfaceReductionRules (off: Off, block: Block, audit: Audit, warn: Warn)')]
    [ValidateSet('off', 'block', 'audit', 'warn')]
    [System.String] $BlockRebootingMachineInSafeMode

    [DscProperty()]
    [System.ComponentModel.Description('ASR Only Per Rule Exclusions')]
    [System.String[]] $BlockRebootingMachineInSafeMode_ASROnlyPerRuleExclusions

    [DscProperty()]
    [System.ComponentModel.Description('Use advanced protection against ransomware - Depends on AttackSurfaceReductionRules (off: Off, block: Block, audit: Audit, warn: Warn)')]
    [ValidateSet('off', 'block', 'audit', 'warn')]
    [System.String] $UseAdvancedProtectionAgainstRansomware

    [DscProperty()]
    [System.ComponentModel.Description('ASR Only Per Rule Exclusions')]
    [System.String[]] $UseAdvancedProtectionAgainstRansomware_ASROnlyPerRuleExclusions

    [DscProperty()]
    [System.ComponentModel.Description('Block executable content from email client and webmail - Depends on AttackSurfaceReductionRules (off: Off, block: Block, audit: Audit, warn: Warn)')]
    [ValidateSet('off', 'block', 'audit', 'warn')]
    [System.String] $BlockExecutableContentFromEmailClientAndWebmail

    [DscProperty()]
    [System.ComponentModel.Description('ASR Only Per Rule Exclusions')]
    [System.String[]] $BlockExecutableContentFromEmailClientAndWebmail_ASROnlyPerRuleExclusions

    [DscProperty()]
    [System.ComponentModel.Description('Cloud Block Level (0: NotConfigured, 2: High, 4: HighPlus, 6: ZeroTolerance)')]
    [ValidateSet('0', '2', '4', '6')]
    [System.Nullable[System.Int32]] $CloudBlockLevel

    [DscProperty()]
    [System.ComponentModel.Description('Cloud Extended Timeout')]
    [System.Nullable[System.Int32]] $CloudExtendedTimeout

    [DscProperty()]
    [System.ComponentModel.Description('Disable Local Admin Merge (0: Enable Local Admin Merge, 1: Disable Local Admin Merge)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $DisableLocalAdminMerge

    [DscProperty()]
    [System.ComponentModel.Description('Enable File Hash Computation (0: Disable, 1: Enable)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $EnableFileHashComputation

    [DscProperty()]
    [System.ComponentModel.Description('Enable Network Protection (0: Disabled, 1: Enabled (block mode), 2: Enabled (audit mode))')]
    [ValidateSet('0', '1', '2')]
    [System.Nullable[System.Int32]] $EnableNetworkProtection

    [DscProperty()]
    [System.ComponentModel.Description('Hide Exclusions From Local Admins (1: If you enable this setting, local admins will no longer be able to see the exclusion list in Windows Security App or via PowerShell., 0: If you disable or do not configure this setting, local admins will be able to see exclusions in the Windows Security App and via PowerShell.)')]
    [ValidateSet('1', '0')]
    [System.Nullable[System.Int32]] $HideExclusionsFromLocalAdmins

    [DscProperty()]
    [System.ComponentModel.Description('PUA Protection (0: PUA Protection off. Windows Defender will not protect against potentially unwanted applications., 1: PUA Protection on. Detected items are blocked. They will show in history along with other threats., 2: Audit mode. Windows Defender will detect potentially unwanted applications, but take no action. You can review information about the applications Windows Defender would have taken action against by searching for events created by Windows Defender in the Event Viewer.)')]
    [ValidateSet('0', '1', '2')]
    [System.Nullable[System.Int32]] $PUAProtection

    [DscProperty()]
    [System.ComponentModel.Description('Real Time Scan Direction (0: Monitor all files (bi-directional)., 1: Monitor incoming files., 2: Monitor outgoing files.)')]
    [ValidateSet('0', '1', '2')]
    [System.Nullable[System.Int32]] $RealTimeScanDirection

    [DscProperty()]
    [System.ComponentModel.Description('Submit Samples Consent (0: Always prompt., 1: Send safe samples automatically., 2: Never send., 3: Send all samples automatically.)')]
    [ValidateSet('0', '1', '2', '3')]
    [System.Nullable[System.Int32]] $SubmitSamplesConsent

    [DscProperty()]
    [System.ComponentModel.Description('Configure System Guard Launch (0: Unmanaged Configurable by Administrative user, 1: Unmanaged Enables Secure Launch if supported by hardware, 2: Unmanaged Disables Secure Launch)')]
    [ValidateSet('0', '1', '2')]
    [System.Nullable[System.Int32]] $ConfigureSystemGuardLaunch

    [DscProperty()]
    [System.ComponentModel.Description('Credential Guard (0: (Disabled) Turns off Credential Guard remotely if configured previously without UEFI Lock., 1: (Enabled with UEFI lock) Turns on Credential Guard with UEFI lock., 2: (Enabled without lock) Turns on Credential Guard without UEFI lock.)')]
    [ValidateSet('0', '1', '2')]
    [System.Nullable[System.Int32]] $LsaCfgFlags

    [DscProperty()]
    [System.ComponentModel.Description('Enable Virtualization Based Security (0: disable virtualization based security., 1: enable virtualization based security.)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $EnableVirtualizationBasedSecurity

    [DscProperty()]
    [System.ComponentModel.Description('Require Platform Security Features (1: Turns on VBS with Secure Boot., 3: Turns on VBS with Secure Boot and direct memory access (DMA). DMA requires hardware support.)')]
    [ValidateSet('1', '3')]
    [System.Nullable[System.Int32]] $RequirePlatformSecurityFeatures

    [DscProperty()]
    [System.ComponentModel.Description('Device Password Enabled (0: Enabled, 1: Disabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $DevicePasswordEnabled

    [DscProperty()]
    [System.ComponentModel.Description('Device Password Expiration - Depends on DevicePasswordEnabled')]
    [System.Nullable[System.Int32]] $DevicePasswordExpiration

    [DscProperty()]
    [System.ComponentModel.Description('Min Device Password Length - Depends on DevicePasswordEnabled')]
    [System.Nullable[System.Int32]] $MinDevicePasswordLength

    [DscProperty()]
    [System.ComponentModel.Description('Alphanumeric Device Password Required - Depends on DevicePasswordEnabled (0: Password or Alphanumeric PIN required., 1: Password or Numeric PIN required., 2: Password, Numeric PIN, or Alphanumeric PIN required.)')]
    [ValidateSet('0', '1', '2')]
    [System.Nullable[System.Int32]] $AlphanumericDevicePasswordRequired

    [DscProperty()]
    [System.ComponentModel.Description('Max Device Password Failed Attempts - Depends on DevicePasswordEnabled')]
    [System.Nullable[System.Int32]] $MaxDevicePasswordFailedAttempts

    [DscProperty()]
    [System.ComponentModel.Description('Min Device Password Complex Characters - Depends on DevicePasswordEnabled. (1: Digits only, 2: Digits and lowercase letters are required, 3: Digits lowercase letters and uppercase letters are required. Not supported in desktop Microsoft accounts and domain accounts, 4: Digits lowercase letters uppercase letters and special characters are required. Not supported in desktop)')]
    [ValidateSet('1', '2', '3', '4')]
    [System.Nullable[System.Int32]] $MinDevicePasswordComplexCharacters

    [DscProperty()]
    [System.ComponentModel.Description('Max Inactivity Time Device Lock - Depends on DevicePasswordEnabled')]
    [System.Nullable[System.Int32]] $MaxInactivityTimeDeviceLock

    [DscProperty()]
    [System.ComponentModel.Description('Device Password History - Depends on DevicePasswordEnabled')]
    [System.Nullable[System.Int32]] $DevicePasswordHistory

    [DscProperty()]
    [System.ComponentModel.Description('Allow Simple Device Password - Depends on DevicePasswordEnabled (0: Not allowed., 1: Allowed.)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $AllowSimpleDevicePassword

    [DscProperty()]
    [System.ComponentModel.Description('Device Enumeration Policy (0: Block all (Most restrictive), 1: Only after log in/screen unlock, 2: Allow all (Least restrictive))')]
    [ValidateSet('0', '1', '2')]
    [System.Nullable[System.Int32]] $DeviceEnumerationPolicy

    [DscProperty()]
    [System.ComponentModel.Description('Enable Insecure Guest Logons (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $EnableInsecureGuestLogons

    [DscProperty()]
    [System.ComponentModel.Description('Configure Lsa Protected Process (0: Disabled. Default value. LSA will not run as protected process., 1: Enabled with UEFI lock. LSA will run as protected process and this configuration is UEFI locked., 2: Enabled without UEFI lock. LSA will run as protected process and this configuration is not UEFI locked.)')]
    [ValidateSet('0', '1', '2')]
    [System.Nullable[System.Int32]] $ConfigureLsaProtectedProcess

    [DscProperty()]
    [System.ComponentModel.Description('Allow Game DVR (0: Not allowed., 1: Allowed.)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $AllowGameDVR

    [DscProperty()]
    [System.ComponentModel.Description('MSI Allow User Control Over Install (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $MSIAllowUserControlOverInstall

    [DscProperty()]
    [System.ComponentModel.Description('MSI Always Install With Elevated Privileges (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $MSIAlwaysInstallWithElevatedPrivileges

    [DscProperty()]
    [System.ComponentModel.Description('Default Adobe Flash setting (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $MicrosoftEdge_ContentSettings_DefaultPluginsSetting

    [DscProperty()]
    [System.ComponentModel.Description('Default Adobe Flash setting (Device) - Depends on MicrosoftEdge_ContentSettings_DefaultPluginsSetting (2: Block the Adobe Flash plugin, 3: Click to play)')]
    [ValidateSet('2', '3')]
    [System.Nullable[System.Int32]] $DefaultPluginsSetting_DefaultPluginsSetting

    [DscProperty()]
    [System.ComponentModel.Description('Minimum TLS version enabled (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $edge_SSLVersionMin

    [DscProperty()]
    [System.ComponentModel.Description('Minimum SSL version enabled (Device) - Depends on edge_SSLVersionMin (tls1: TLS 1.0, tls1.1: TLS 1.1, tls1.2: TLS 1.2)')]
    [ValidateSet('tls1', 'tls1.1', 'tls1.2')]
    [System.String] $SSLVersionMin_SSLVersionMin

    [DscProperty()]
    [System.ComponentModel.Description('Configure Microsoft Defender SmartScreen (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $SmartScreenEnabled

    [DscProperty()]
    [System.ComponentModel.Description('Prevent bypassing Microsoft Defender SmartScreen prompts for sites (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $PreventSmartScreenPromptOverride

    [DscProperty()]
    [System.ComponentModel.Description('Let Apps Activate With Voice Above Lock (0: User in control. Users can decide if Windows apps can be activated by voice while the screen is locked using Settings > Privacy options on the device., 1: Force allow. Windows apps can be activated by voice while the screen is locked, and users cannot change it., 2: Force deny. Windows apps cannot be activated by voice while the screen is locked, and users cannot change it.)')]
    [ValidateSet('0', '1', '2')]
    [System.Nullable[System.Int32]] $LetAppsActivateWithVoiceAboveLock

    [DscProperty()]
    [System.ComponentModel.Description('Allow Indexing Encrypted Stores Or Items (0: Not allowed., 1: Allowed.)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $AllowIndexingEncryptedStoresOrItems

    [DscProperty()]
    [System.ComponentModel.Description('Enable Smart Screen In Shell (0: Disabled., 1: Enabled.)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $EnableSmartScreenInShell

    [DscProperty()]
    [System.ComponentModel.Description('Notify Malicious (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $NotifyMalicious

    [DscProperty()]
    [System.ComponentModel.Description('Notify Password Reuse (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $NotifyPasswordReuse

    [DscProperty()]
    [System.ComponentModel.Description('Notify Unsafe App (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $NotifyUnsafeApp

    [DscProperty()]
    [System.ComponentModel.Description('Service Enabled (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $ServiceEnabled

    [DscProperty()]
    [System.ComponentModel.Description('Prevent Override For Files In Shell (0: Do not prevent override., 1: Prevent override.)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $PreventOverrideForFilesInShell

    [DscProperty()]
    [System.ComponentModel.Description('Access From Network')]
    [System.String[]] $AccessFromNetwork

    [DscProperty()]
    [System.ComponentModel.Description('Allow Local Log On')]
    [System.String[]] $AllowLocalLogOn

    [DscProperty()]
    [System.ComponentModel.Description('Backup Files And Directories')]
    [System.String[]] $BackupFilesAndDirectories

    [DscProperty()]
    [System.ComponentModel.Description('Create Global Objects')]
    [System.String[]] $CreateGlobalObjects

    [DscProperty()]
    [System.ComponentModel.Description('Create Page File')]
    [System.String[]] $CreatePageFile

    [DscProperty()]
    [System.ComponentModel.Description('Debug Programs')]
    [System.String[]] $DebugPrograms

    [DscProperty()]
    [System.ComponentModel.Description('Deny Access From Network')]
    [System.String[]] $DenyAccessFromNetwork

    [DscProperty()]
    [System.ComponentModel.Description('Deny Remote Desktop Services Log On')]
    [System.String[]] $DenyRemoteDesktopServicesLogOn

    [DscProperty()]
    [System.ComponentModel.Description('Impersonate Client')]
    [System.String[]] $ImpersonateClient

    [DscProperty()]
    [System.ComponentModel.Description('Load Unload Device Drivers')]
    [System.String[]] $LoadUnloadDeviceDrivers

    [DscProperty()]
    [System.ComponentModel.Description('Manage Auditing And Security Log')]
    [System.String[]] $ManageAuditingAndSecurityLog

    [DscProperty()]
    [System.ComponentModel.Description('Manage Volume')]
    [System.String[]] $ManageVolume

    [DscProperty()]
    [System.ComponentModel.Description('Modify Firmware Environment')]
    [System.String[]] $ModifyFirmwareEnvironment

    [DscProperty()]
    [System.ComponentModel.Description('Profile Single Process')]
    [System.String[]] $ProfileSingleProcess

    [DscProperty()]
    [System.ComponentModel.Description('Remote Shutdown')]
    [System.String[]] $RemoteShutdown

    [DscProperty()]
    [System.ComponentModel.Description('Restore Files And Directories')]
    [System.String[]] $RestoreFilesAndDirectories

    [DscProperty()]
    [System.ComponentModel.Description('Take Ownership')]
    [System.String[]] $TakeOwnership

    [DscProperty()]
    [System.ComponentModel.Description('Hypervisor Enforced Code Integrity (0: (Disabled) Turns off Hypervisor-Protected Code Integrity remotely if configured previously without UEFI Lock., 1: (Enabled with UEFI lock) Turns on Hypervisor-Protected Code Integrity with UEFI lock., 2: (Enabled without lock) Turns on Hypervisor-Protected Code Integrity without UEFI lock.)')]
    [ValidateSet('0', '1', '2')]
    [System.Nullable[System.Int32]] $HypervisorEnforcedCodeIntegrity

    [DscProperty()]
    [System.ComponentModel.Description('Allow Windows Ink Workspace (0: access to ink workspace is disabled. The feature is turned off., 1: ink workspace is enabled (feature is turned on), but the user cannot access it above the lock screen., 2: ink workspace is enabled (feature is turned on), and the user is allowed to use it above the lock screen.)')]
    [ValidateSet('0', '1', '2')]
    [System.Nullable[System.Int32]] $AllowWindowsInkWorkspace

    [DscProperty()]
    [System.ComponentModel.Description('Accounts Limit Local Account Use Of Blank Passwords To Console Logon Only (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $Accounts_LimitLocalAccountUseOfBlankPasswordsToConsoleLogonOnly

    [DscProperty()]
    [System.ComponentModel.Description('Interactive Logon Machine Inactivity Limit')]
    [System.Nullable[System.Int32]] $InteractiveLogon_MachineInactivityLimit

    [DscProperty()]
    [System.ComponentModel.Description('Interactive Logon Smart Card Removal Behavior (0: No Action, 1: Lock Workstation, 2: Force Logoff, 3: Disconnect if a Remote Desktop Services session)')]
    [ValidateSet('0', '1', '2', '3')]
    [System.Nullable[System.Int32]] $InteractiveLogon_SmartCardRemovalBehavior

    [DscProperty()]
    [System.ComponentModel.Description('Microsoft Network Client Digitally Sign Communications Always (1: Enable, 0: Disable)')]
    [ValidateSet('1', '0')]
    [System.Nullable[System.Int32]] $MicrosoftNetworkClient_DigitallySignCommunicationsAlways

    [DscProperty()]
    [System.ComponentModel.Description('Microsoft Network Client Send Unencrypted Password To Third Party SMB Servers (1: Enable, 0: Disable)')]
    [ValidateSet('1', '0')]
    [System.Nullable[System.Int32]] $MicrosoftNetworkClient_SendUnencryptedPasswordToThirdPartySMBServers

    [DscProperty()]
    [System.ComponentModel.Description('Microsoft Network Server Digitally Sign Communications Always (1: Enable, 0: Disable)')]
    [ValidateSet('1', '0')]
    [System.Nullable[System.Int32]] $MicrosoftNetworkServer_DigitallySignCommunicationsAlways

    [DscProperty()]
    [System.ComponentModel.Description('Network Access Do Not Allow Anonymous Enumeration Of SAM Accounts (1: Enabled, 0: Disabled)')]
    [ValidateSet('1', '0')]
    [System.Nullable[System.Int32]] $NetworkAccess_DoNotAllowAnonymousEnumerationOfSAMAccounts

    [DscProperty()]
    [System.ComponentModel.Description('Network Access Do Not Allow Anonymous Enumeration Of Sam Accounts And Shares (1: Enabled, 0: Disabled)')]
    [ValidateSet('1', '0')]
    [System.Nullable[System.Int32]] $NetworkAccess_DoNotAllowAnonymousEnumerationOfSamAccountsAndShares

    [DscProperty()]
    [System.ComponentModel.Description('Network Access Restrict Anonymous Access To Named Pipes And Shares (1: Enable, 0: Disable)')]
    [ValidateSet('1', '0')]
    [System.Nullable[System.Int32]] $NetworkAccess_RestrictAnonymousAccessToNamedPipesAndShares

    [DscProperty()]
    [System.ComponentModel.Description('Network Access Restrict Clients Allowed To Make Remote Calls To SAM')]
    [System.String] $NetworkAccess_RestrictClientsAllowedToMakeRemoteCallsToSAM

    [DscProperty()]
    [System.ComponentModel.Description('Network Security Do Not Store LAN Manager Hash Value On Next Password Change (1: Enable, 0: Disable)')]
    [ValidateSet('1', '0')]
    [System.Nullable[System.Int32]] $NetworkSecurity_DoNotStoreLANManagerHashValueOnNextPasswordChange

    [DscProperty()]
    [System.ComponentModel.Description('Network Security LAN Manager Authentication Level (0: Send LM and NTLM responses, 1: Send LM and NTLM-use NTLMv2 session security if negotiated, 2: Send LM and NTLM responses only, 3: Send LM and NTLMv2 responses only, 4: Send LM and NTLMv2 responses only. Refuse LM, 5: Send LM and NTLMv2 responses only. Refuse LM and NTLM)')]
    [ValidateSet('0', '1', '2', '3', '4', '5')]
    [System.Nullable[System.Int32]] $NetworkSecurity_LANManagerAuthenticationLevel

    [DscProperty()]
    [System.ComponentModel.Description('Network Security Minimum Session Security For NTLMSSP Based Clients (0: None, 524288: Require NTLMv2 session security, 536870912: Require 128-bit encryption, 537395200: Require NTLM and 128-bit encryption)')]
    [ValidateSet('0', '524288', '536870912', '537395200')]
    [System.String] $NetworkSecurity_MinimumSessionSecurityForNTLMSSPBasedClients

    [DscProperty()]
    [System.ComponentModel.Description('Network Security Minimum Session Security For NTLMSSP Based Servers (0: None, 524288: Require NTLMv2 session security, 536870912: Require 128-bit encryption, 537395200: Require NTLM and 128-bit encryption)')]
    [ValidateSet('0', '524288', '536870912', '537395200')]
    [System.String] $NetworkSecurity_MinimumSessionSecurityForNTLMSSPBasedServers

    [DscProperty()]
    [System.ComponentModel.Description('User Account Control Behavior Of The Elevation Prompt For Administrators (0: Elevate without prompting, 1: Prompt for credentials on the secure desktop, 2: Prompt for consent on the secure desktop, 3: Prompt for credentials, 4: Prompt for consent, 5: Prompt for consent for non-Windows binaries)')]
    [ValidateSet('0', '1', '2', '3', '4', '5')]
    [System.Nullable[System.Int32]] $UserAccountControl_BehaviorOfTheElevationPromptForAdministrators

    [DscProperty()]
    [System.ComponentModel.Description('User Account Control Behavior Of The Elevation Prompt For Standard Users (0: Automatically deny elevation requests, 1: Prompt for credentials on the secure desktop, 3: Prompt for credentials)')]
    [ValidateSet('0', '1', '3')]
    [System.Nullable[System.Int32]] $UserAccountControl_BehaviorOfTheElevationPromptForStandardUsers

    [DscProperty()]
    [System.ComponentModel.Description('User Account Control Detect Application Installations And Prompt For Elevation (1: Enable, 0: Disable)')]
    [ValidateSet('1', '0')]
    [System.Nullable[System.Int32]] $UserAccountControl_DetectApplicationInstallationsAndPromptForElevation

    [DscProperty()]
    [System.ComponentModel.Description('User Account Control Only Elevate UI Access Applications That Are Installed In Secure Locations (0: Disabled: Application runs with UIAccess integrity even if it does not reside in a secure location., 1: Enabled: Application runs with UIAccess integrity only if it resides in secure location.)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $UserAccountControl_OnlyElevateUIAccessApplicationsThatAreInstalledInSecureLocations

    [DscProperty()]
    [System.ComponentModel.Description('User Account Control Run All Administrators In Admin Approval Mode (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $UserAccountControl_RunAllAdministratorsInAdminApprovalMode

    [DscProperty()]
    [System.ComponentModel.Description('User Account Control Use Admin Approval Mode (1: Enable, 0: Disable)')]
    [ValidateSet('1', '0')]
    [System.Nullable[System.Int32]] $UserAccountControl_UseAdminApprovalMode

    [DscProperty()]
    [System.ComponentModel.Description('User Account Control Virtualize File And Registry Write Failures To Per User Locations (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $UserAccountControl_VirtualizeFileAndRegistryWriteFailuresToPerUserLocations
}

class MSFT_MicrosoftGraphIntuneSettingsCatalogUserSettings_IntuneSecurityBaselineWindows365
{
    [DscProperty()]
    [System.ComponentModel.Description('Turn off toast notifications on the lock screen (User) (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $NoLockScreenToastNotification

    [DscProperty()]
    [System.ComponentModel.Description('Turn on the auto-complete feature for user names and passwords on forms (User) (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $RestrictFormSuggestPW

    [DscProperty()]
    [System.ComponentModel.Description('Prompt me to save passwords (User) - Depends on RestrictFormSuggestPW (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $ChkBox_PasswordAsk

    [DscProperty()]
    [System.ComponentModel.Description('Allow Windows Spotlight (User) (0: Not allowed., 1: Allowed.)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $AllowWindowsSpotlight

    [DscProperty()]
    [System.ComponentModel.Description('Allow Windows Tips - Depends on AllowWindowsSpotlight (0: Disabled., 1: Enabled.)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $AllowWindowsTips

    [DscProperty()]
    [System.ComponentModel.Description('Allow Tailored Experiences With Diagnostic Data (User) - Depends on AllowWindowsSpotlight (0: Not allowed., 1: Allowed.)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $AllowTailoredExperiencesWithDiagnosticData

    [DscProperty()]
    [System.ComponentModel.Description('Allow Windows Spotlight On Action Center (User) - Depends on AllowWindowsSpotlight (0: Not allowed., 1: Allowed.)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $AllowWindowsSpotlightOnActionCenter

    [DscProperty()]
    [System.ComponentModel.Description('Allow Windows Consumer Features - Depends on AllowWindowsSpotlight (0: Not allowed., 1: Allowed.)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $AllowWindowsConsumerFeatures

    [DscProperty()]
    [System.ComponentModel.Description('Configure Windows Spotlight On Lock Screen (User) - Depends on AllowWindowsSpotlight (0: Windows spotlight disabled., 1: Windows spotlight enabled., 2: Windows spotlight is always enabled, the user cannot disable it, 3: Windows spotlight is always enabled, the user cannot disable it. For special configurations only)')]
    [ValidateSet('0', '1', '2', '3')]
    [System.Nullable[System.Int32]] $ConfigureWindowsSpotlightOnLockScreen

    [DscProperty()]
    [System.ComponentModel.Description('Allow Windows Spotlight Windows Welcome Experience (User) - Depends on AllowWindowsSpotlight (0: Not allowed., 1: Allowed.)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $AllowWindowsSpotlightWindowsWelcomeExperience

    [DscProperty()]
    [System.ComponentModel.Description('Allow Third Party Suggestions In Windows Spotlight (User) - Depends on AllowWindowsSpotlight (0: Third-party suggestions not allowed., 1: Third-party suggestions allowed.)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $AllowThirdPartySuggestionsInWindowsSpotlight

    [DscProperty()]
    [System.ComponentModel.Description('Default Adobe Flash setting (User) (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $MicrosoftEdge_ContentSettings_DefaultPluginsSetting

    [DscProperty()]
    [System.ComponentModel.Description('Default Adobe Flash setting (User) - Depends on MicrosoftEdge_ContentSettings_DefaultPluginsSetting (2: Block the Adobe Flash plugin, 3: Click to play)')]
    [ValidateSet('2', '3')]
    [System.Nullable[System.Int32]] $DefaultPluginsSetting_DefaultPluginsSetting

    [DscProperty()]
    [System.ComponentModel.Description('Minimum TLS version enabled (User) (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $edge_SSLVersionMin

    [DscProperty()]
    [System.ComponentModel.Description('Minimum SSL version enabled (User) - Depends on edge_SSLVersionMin (tls1: TLS 1.0, tls1.1: TLS 1.1, tls1.2: TLS 1.2)')]
    [ValidateSet('tls1', 'tls1.1', 'tls1.2')]
    [System.String] $SSLVersionMin_SSLVersionMin
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

class MSFT_MicrosoftGraphIntuneSettingsCatalogpol_hardenedpaths
{
    [DscProperty()]
    [System.ComponentModel.Description('Value')]
    [System.String] $value

    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('Name')]
    [System.String] $key
}
