using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class IntuneWifiConfigurationPolicyAndroidEnterpriseDeviceOwner : M365DSCResourceBase
{
    [DscProperty()]
    [System.ComponentModel.Description('Id of the Intune policy')]
    [System.String] $Id

    [DscProperty(Key)]
    [System.ComponentModel.Description('Disaply name of the Intune policy')]
    [System.String] $DisplayName

    [DscProperty()]
    [System.ComponentModel.Description('Description of the Intune policy')]
    [System.String] $Description

    [DscProperty()]
    [System.ComponentModel.Description('List of Scope Tags for this Entity instance.')]
    [System.String[]] $RoleScopeTagIds

    [DscProperty()]
    [System.ComponentModel.Description('Authentication method the client needs to use when the EAP type is configured to PEAP or EAP-TTLS.')]
    [ValidateSet('certificate', 'derivedCredential', 'usernameAndPassword')]
    [System.String] $AuthenticationMethod

    [DscProperty()]
    [System.ComponentModel.Description('If the network is in range, automatically connect.')]
    [System.Nullable[System.Boolean]] $ConnectAutomatically

    [DscProperty()]
    [System.ComponentModel.Description('Don''t show this Wi-Fi network on an end-user''s device in the list of available networks. The SSID will not be broadcasted.')]
    [System.Nullable[System.Boolean]] $ConnectWhenNetworkNameIsHidden

    [DscProperty()]
    [System.ComponentModel.Description('Extensible Authentication Protocol (EAP) type set on the Wi-Fi endpoint.')]
    [ValidateSet('eapTls', 'eapTtls', 'peap')]
    [System.String] $EapType

    [DscProperty()]
    [System.ComponentModel.Description('Non-EAP Method for Authentication (Inner Identity) when EAP Type is EAP-TTLS and Authenticationmethod is Username and Password.')]
    [ValidateSet('challengeHandshakeAuthenticationProtocol', 'microsoftChap', 'microsoftChapVersionTwo', 'unencryptedPassword')]
    [System.String] $InnerAuthenticationProtocolForEapTtls

    [DscProperty()]
    [System.ComponentModel.Description('Non-EAP Method for Authentication (Inner Identity) when EAP Type is PEAP and Authenticationmethod is Username and Password.')]
    [ValidateSet('microsoftChapVersionTwo', 'none')]
    [System.String] $InnerAuthenticationProtocolForPeap

    [DscProperty()]
    [System.ComponentModel.Description('The MAC address randomization mode for Android device Wi-Fi configuration.')]
    [ValidateSet('automatic', 'hardware')]
    [System.String] $MacAddressRandomizationMode

    [DscProperty()]
    [System.ComponentModel.Description('Network name.')]
    [System.String] $NetworkName

    [DscProperty()]
    [System.ComponentModel.Description('Enable identity privacy (Outer Identity) when EAP Type is configured to EAP-TTLS or PEAP. The String provided here is used to mask the username of individual users when they attempt to connect to Wi-Fi network.')]
    [System.String] $OuterIdentityPrivacyTemporaryValue

    [DscProperty()]
    [System.ComponentModel.Description('Pre shared key.')]
    [System.String] $PreSharedKey

    [DscProperty()]
    [System.ComponentModel.Description('Pre shared key is set.')]
    [System.Nullable[System.Boolean]] $PreSharedKeyIsSet

    [DscProperty()]
    [System.ComponentModel.Description('URL of the automatic proxy.')]
    [System.String] $ProxyAutomaticConfigurationUrl

    [DscProperty()]
    [System.ComponentModel.Description('Exclusion list of the proxy.')]
    [System.String] $ProxyExclusionList

    [DscProperty()]
    [System.ComponentModel.Description('Address of the proxy.')]
    [System.String] $ProxyManualAddress

    [DscProperty()]
    [System.ComponentModel.Description('Port of the proxy.')]
    [System.Nullable[System.UInt32]] $ProxyManualPort

    [DscProperty()]
    [System.ComponentModel.Description('Proxy setting type.')]
    [ValidateSet('none', 'manual', 'automatic')]
    [System.String] $ProxySettings

    [DscProperty()]
    [System.ComponentModel.Description('Service Set Identifier. The name of the Wi-Fi connection.')]
    [System.String] $Ssid

    [DscProperty()]
    [System.ComponentModel.Description('Trusted server certificate names.')]
    [System.String[]] $TrustedServerCertificateNames

    [DscProperty()]
    [System.ComponentModel.Description('Type of Wi-Fi profile.')]
    [ValidateSet('open', 'wep', 'wpaPersonal', 'wpaEnterprise')]
    [System.String] $WiFiSecurityType

    [DscProperty()]
    [System.ComponentModel.Description('Represents the assignment to the Intune policy.')]
    [MSFT_DeviceManagementConfigurationPolicyAssignments[]] $Assignments

    [DscProperty()]
    [System.ComponentModel.Description('Present ensures the policy exists, absent ensures it is removed.')]
    [ValidateSet('Present', 'Absent')]
    [System.String] $Ensure

    [DscProperty()]
    [System.ComponentModel.Description('Credentials of the Intune Admin')]
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

    [IntuneWifiConfigurationPolicyAndroidEnterpriseDeviceOwner] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [IntuneWifiConfigurationPolicyAndroidEnterpriseDeviceOwner]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of the Intune Wifi Configuration Policy Android Enterprise Device Owner with Id {$($this.Id)} and DisplayName {$($this.DisplayName)}"

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
                if (-not [string]::IsNullOrEmpty($this.Id))
                {
                    $getValue = Get-MgBetaDeviceManagementDeviceConfiguration -All -Filter "Id eq '$($this.Id)'" -ErrorAction SilentlyContinue
                }

                #region resource generator code
                if ($null -eq $getValue)
                {
                    $getValue = Get-MgBetaDeviceManagementDeviceConfiguration -All -Filter "DisplayName eq '$($this.DisplayName -replace "'", "''")' and isof('microsoft.graph.androidDeviceOwnerEnterpriseWiFiConfiguration')" -ErrorAction SilentlyContinue
                }
                #endregion

                if ($null -eq $getValue)
                {
                    Write-Verbose -Message "Nothing with id {$($this.Id)} was found"
                    return $this.AsResult($nullResult)
                }
            }
            else
            {
                $getValue = $this.ExportedInstance
            }
            $resolvedId = $getValue.Id

            Write-Verbose -Message "Found something with id {$($resolvedId)}"
            $results = @{
                #region resource generator code
                Id                                    = $getValue.Id
                Description                           = $getValue.Description
                DisplayName                           = $getValue.DisplayName
                RoleScopeTagIds                       = Resolve-M365DSCIntuneRoleScopeTagNames -CurrentValues $getValue.RoleScopeTagIds -DesiredValues $this.RoleScopeTagIds
                AuthenticationMethod                  = $getValue.authenticationMethod
                ConnectAutomatically                  = $getValue.connectAutomatically
                ConnectWhenNetworkNameIsHidden        = $getValue.connectWhenNetworkNameIsHidden
                EapType                               = $getValue.eapType
                InnerAuthenticationProtocolForEapTtls = $getValue.innerAuthenticationProtocolForEapTtls
                InnerAuthenticationProtocolForPeap    = $getValue.innerAuthenticationProtocolForPeap
                MacAddressRandomizationMode           = $getValue.macAddressRandomizationMode
                NetworkName                           = $getValue.networkName
                OuterIdentityPrivacyTemporaryValue    = $getValue.outerIdentityPrivacyTemporaryValue
                PreSharedKey                          = $getValue.preSharedKey
                PreSharedKeyIsSet                     = $getValue.preSharedKeyIsSet
                ProxyAutomaticConfigurationUrl        = $getValue.proxyAutomaticConfigurationUrl
                ProxyExclusionList                    = $getValue.proxyExclusionList
                ProxyManualAddress                    = $getValue.proxyManualAddress
                ProxyManualPort                       = $getValue.proxyManualPort
                ProxySettings                         = $getValue.proxySettings
                Ssid                                  = $getValue.ssid
                TrustedServerCertificateNames         = $getValue.trustedServerCertificateNames
                WiFiSecurityType                      = $getValue.wiFiSecurityType
                Ensure                                = 'Present'
                Credential                            = $this.Credential
                ApplicationId                         = $this.ApplicationId
                TenantId                              = $this.TenantId
                ApplicationSecret                     = $this.ApplicationSecret
                CertificateThumbprint                 = $this.CertificateThumbprint
                CertificatePath                       = $this.CertificatePath
                CertificatePassword                   = $this.CertificatePassword
                ManagedIdentity                       = $this.ManagedIdentity
                AccessTokens                          = $this.AccessTokens
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

        Write-Verbose -Message "Setting configuration of the Intune Wifi Configuration Policy Android Enterprise Device Owner with Id {$($this.Id)} and DisplayName {$($this.DisplayName)}"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $currentInstance = $this.Get().ToHashtable()

        $boundParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()
        $boundParameters.Remove('Assignments') | Out-Null
        $boundParameters = Rename-M365DSCCimInstanceParameter -Properties $boundParameters

        if ($boundParameters.ContainsKey('RoleScopeTagIds'))
        {
            $boundParameters.RoleScopeTagIds = Resolve-M365DSCIntuneRoleScopeTagIds -RoleScopeTagIds $this.RoleScopeTagIds
        }

        if ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Creating the Intune Wifi Configuration Policy Android Enterprise Device Owner with DisplayName {$($this.DisplayName)}"
            $createParameters = $boundParameters
            $createParameters.Remove('Id') | Out-Null

            #region resource generator code
            $createParameters.Add('@odata.type', '#microsoft.graph.androidDeviceOwnerEnterpriseWiFiConfiguration')
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
            Write-Verbose -Message "Updating the Intune Wifi Configuration Policy Android Enterprise Device Owner with Id {$($this.Id)} and DisplayName {$($this.DisplayName)}"
            $updateParameters = $boundParameters
            $updateParameters.Remove('Id') | Out-Null

            #region resource generator code
            $updateParameters.Add('@odata.type', '#microsoft.graph.androidDeviceOwnerEnterpriseWiFiConfiguration')
            Update-MgBetaDeviceManagementDeviceConfiguration -BodyParameter $updateParameters `
                -DeviceConfigurationId $currentInstance.Id
            $assignmentsHash = ConvertTo-IntunePolicyAssignment -IncludeDeviceFilter:$true -Assignments $this.Assignments
            Update-DeviceConfigurationPolicyAssignment `
                -DeviceConfigurationPolicyId $currentInstance.id `
                -Targets $assignmentsHash `
                -Repository 'deviceManagement/deviceConfigurations'
            #endregion
        }
        elseif ($this.Ensure -eq 'Absent' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Removing {$($this.DisplayName)}"
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
                -ODataType 'microsoft.graph.androidDeviceOwnerEnterpriseWiFiConfiguration' `
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

                Write-M365DSCHost -Message "    |---[$i/$($getValue.Count)] $($config.DisplayName)" -DeferWrite
                $params = @{
                    Id                    = $config.id
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

    [System.Collections.Hashtable] GetCompareParameters()
    {
        return @{
            ExcludedProperties = @('PreSharedKey')
        }
    }

    hidden [IntuneWifiConfigurationPolicyAndroidEnterpriseDeviceOwner] AsResult([System.Object] $Values)
    {
        if ($Values -is [IntuneWifiConfigurationPolicyAndroidEnterpriseDeviceOwner])
        {
            return $Values
        }

        $result = [IntuneWifiConfigurationPolicyAndroidEnterpriseDeviceOwner]::new()
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
