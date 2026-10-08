using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class IntuneVPNConfigurationPolicyMacOS : M365DSCResourceBase
{
    [DscProperty()]
    [System.ComponentModel.Description('Represents the assignment to the Intune policy.')]
    [MSFT_DeviceManagementConfigurationPolicyAssignments[]] $Assignments

    [DscProperty()]
    [System.ComponentModel.Description('Associated Domains')]
    [System.String[]] $AssociatedDomains

    [DscProperty()]
    [System.ComponentModel.Description('Authentication method for this VPN connection. Possible values are: certificate, usernameAndPassword, sharedSecret, derivedCredential, azureAD.')]
    [ValidateSet('certificate', 'usernameAndPassword', 'sharedSecret', 'derivedCredential', 'azureAD')]
    [System.String] $AuthenticationMethod

    [DscProperty()]
    [System.ComponentModel.Description('Connection name displayed to the user.')]
    [System.String] $ConnectionName

    [DscProperty()]
    [System.ComponentModel.Description('Connection type. Possible values are: ciscoAnyConnect, pulseSecure, f5EdgeClient, dellSonicWallMobileConnect, checkPointCapsuleVpn, customVpn, ciscoIPSec, citrix, ciscoAnyConnectV2, paloAltoGlobalProtect, zscalerPrivateAccess, f5Access2018, citrixSso, paloAltoGlobalProtectV2, ikEv2, alwaysOn, microsoftTunnel, netMotionMobility, microsoftProtect.')]
    [ValidateSet('ciscoAnyConnect', 'pulseSecure', 'f5EdgeClient', 'dellSonicWallMobileConnect', 'checkPointCapsuleVpn', 'customVpn', 'ciscoIPSec', 'citrix', 'ciscoAnyConnectV2', 'paloAltoGlobalProtect', 'zscalerPrivateAccess', 'f5Access2018', 'citrixSso', 'paloAltoGlobalProtectV2', 'ikEv2', 'alwaysOn', 'microsoftTunnel', 'netMotionMobility', 'microsoftProtect')]
    [System.String] $ConnectionType

    [DscProperty()]
    [System.ComponentModel.Description('Custom data when connection type is set to Custom VPN. Use this field to enable functionality not supported by Intune, but available in your VPN solution. Contact your VPN vendor to learn how to add these key/value pairs. This collection can contain a maximum of 25 elements.')]
    [MSFT_MicrosoftGraphKeyValue[]] $CustomData

    [DscProperty()]
    [System.ComponentModel.Description('Custom data when connection type is set to Custom VPN. Use this field to enable functionality not supported by Intune, but available in your VPN solution. Contact your VPN vendor to learn how to add these key/value pairs. This collection can contain a maximum of 25 elements.')]
    [MSFT_MicrosoftGraphKeyValuePair2[]] $CustomKeyValueData

    [DscProperty()]
    [System.ComponentModel.Description('Indicates the deployment channel type used to deploy the configuration profile. Possible values are deviceChannel, userChannel. Possible values are: deviceChannel, userChannel, unknownFutureValue.')]
    [ValidateSet('deviceChannel', 'userChannel', 'unknownFutureValue')]
    [System.String] $DeploymentChannel

    [DscProperty()]
    [System.ComponentModel.Description('Admin provided description of the Device Configuration.')]
    [System.String] $Description

    [DscProperty()]
    [System.ComponentModel.Description('Toggle to prevent user from disabling automatic VPN in the Settings app')]
    [System.Nullable[System.Boolean]] $DisableOnDemandUserOverride

    [DscProperty()]
    [System.ComponentModel.Description('Whether to disconnect after on-demand connection idles')]
    [System.Nullable[System.Boolean]] $DisconnectOnIdle

    [DscProperty()]
    [System.ComponentModel.Description('The length of time in seconds to wait before disconnecting an on-demand connection. Valid values 0 to 65535')]
    [System.Nullable[System.Int32]] $DisconnectOnIdleTimerInSeconds

    [DscProperty(Key)]
    [System.ComponentModel.Description('Admin provided name of the device configuration.')]
    [System.String] $DisplayName

    [DscProperty()]
    [System.ComponentModel.Description('Setting this to true creates Per-App VPN payload which can later be associated with Apps that can trigger this VPN conneciton on the end user''s iOS device.')]
    [System.Nullable[System.Boolean]] $EnablePerApp

    [DscProperty()]
    [System.ComponentModel.Description('Send all network traffic through VPN.')]
    [System.Nullable[System.Boolean]] $EnableSplitTunneling

    [DscProperty()]
    [System.ComponentModel.Description('Domains that are accessed through the public internet instead of through VPN, even when per-app VPN is activated')]
    [System.String[]] $ExcludedDomains

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether local network traffic is excluded from the VPN tunnel. When TRUE, local network traffic bypasses the VPN tunnel. Default value is null. Only takes effect when includeAllNetworks is TRUE or enforceVpnRouting is TRUE. Not applicable when enablePerApp is TRUE.')]
    [System.Nullable[System.Boolean]] $ExcludeLocalNetworks

    [DscProperty()]
    [System.ComponentModel.Description('The unique identifier for an entity. Read-only.')]
    [System.String] $Id

    [DscProperty()]
    [System.ComponentModel.Description('Identifier provided by VPN vendor when connection type is set to Custom VPN. For example: Cisco AnyConnect uses an identifier of the form com.cisco.anyconnect.applevpn.plugin')]
    [System.String] $Identifier

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether most network traffic is routed through the VPN tunnel. When TRUE, most network traffic is sent through the VPN tunnel. Default value is null. Not applicable when enablePerApp is TRUE.')]
    [System.Nullable[System.Boolean]] $IncludeAllNetworks

    [DscProperty()]
    [System.ComponentModel.Description('Login group or domain when connection type is set to Dell SonicWALL Mobile Connection.')]
    [System.String] $LoginGroupOrDomain

    [DscProperty()]
    [System.ComponentModel.Description('On-Demand Rules. This collection can contain a maximum of 500 elements.')]
    [MSFT_MicrosoftGraphVpnOnDemandRule[]] $OnDemandRules

    [DscProperty()]
    [System.ComponentModel.Description('Opt-In to sharing the device''s Id to third-party vpn clients for use during network access control validation.')]
    [System.Nullable[System.Boolean]] $OptInToDeviceIdSharing

    [DscProperty()]
    [System.ComponentModel.Description('Provider type for per-app VPN. Possible values are: notConfigured, appProxy, packetTunnel.')]
    [ValidateSet('notConfigured', 'appProxy', 'packetTunnel')]
    [System.String] $ProviderType

    [DscProperty()]
    [System.ComponentModel.Description('Proxy Server.')]
    [MSFT_MicrosoftGraphVpnProxyServer] $ProxyServer

    [DscProperty()]
    [System.ComponentModel.Description('Realm when connection type is set to Pulse Secure.')]
    [System.String] $Realm

    [DscProperty()]
    [System.ComponentModel.Description('Role when connection type is set to Pulse Secure.')]
    [System.String] $Role

    [DscProperty()]
    [System.ComponentModel.Description('List of Scope Tags for this Entity instance.')]
    [System.String[]] $RoleScopeTagIds

    [DscProperty()]
    [System.ComponentModel.Description('Safari domains when this VPN per App setting is enabled. In addition to the apps associated with this VPN, Safari domains specified here will also be able to trigger this VPN connection.')]
    [System.String[]] $SafariDomains

    [DscProperty()]
    [System.ComponentModel.Description('VPN Server on the network. Make sure end users can access this network location.')]
    [MSFT_MicrosoftGraphVpnServer1] $Server

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

    [IntuneVPNConfigurationPolicyMacOS] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [IntuneVPNConfigurationPolicyMacOS]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of Intune V P N Configuration Policy for macOS {$($this.Id)}"

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
                        -Filter "DisplayName eq '$($this.DisplayName -replace "'", "''")' and isof('microsoft.graph.macOSVpnConfiguration')" `
                        -ErrorAction SilentlyContinue | Select-Object -First 1
                }
            }
            else
            {
                $getValue = $this.ExportedInstance
            }

            if ($null -eq $getValue)
            {
                Write-Verbose -Message "No Intune V P N Configuration Policy for macOS with Id {$($this.Id)} was found"
                return $this.AsResult($nullResult)
            }

            Write-Verbose -Message "Found Intune V P N Configuration Policy for macOS with Id {$($this.Id)}"

            $complexCustomData = @()
            foreach ($currentCustomData in $getValue.customData)
            {
                $myCustomData = [ordered]@{}
                $myCustomData.Add('Key', $currentCustomData.key)
                $myCustomData.Add('Value', $currentCustomData.value)
                if ($myCustomData.values.Where({ $null -ne $_ }).Count -gt 0)
                {
                    $complexCustomData += $myCustomData
                }
            }

            $complexCustomKeyValueData = @()
            foreach ($currentCustomKeyValueData in $getValue.customKeyValueData)
            {
                $myCustomKeyValueData = [ordered]@{}
                $myCustomKeyValueData.Add('Name', $currentCustomKeyValueData.name)
                $myCustomKeyValueData.Add('Value', $currentCustomKeyValueData.value)
                if ($myCustomKeyValueData.values.Where({ $null -ne $_ }).Count -gt 0)
                {
                    $complexCustomKeyValueData += $myCustomKeyValueData
                }
            }

            $complexOnDemandRules = @()
            foreach ($currentOnDemandRules in $getValue.onDemandRules)
            {
                $myOnDemandRules = [ordered]@{}
                $myOnDemandRules.Add('Action', $currentOnDemandRules.action)
                $myOnDemandRules.Add('DnsSearchDomains', [Array]$currentOnDemandRules.dnsSearchDomains)
                $myOnDemandRules.Add('DnsServerAddressMatch', [Array]$currentOnDemandRules.dnsServerAddressMatch)
                $myOnDemandRules.Add('DomainAction', $currentOnDemandRules.domainAction)
                $myOnDemandRules.Add('Domains', [Array]$currentOnDemandRules.domains)
                $myOnDemandRules.Add('InterfaceTypeMatch', $currentOnDemandRules.interfaceTypeMatch)
                $myOnDemandRules.Add('ProbeRequiredUrl', $currentOnDemandRules.probeRequiredUrl)
                $myOnDemandRules.Add('ProbeUrl', $currentOnDemandRules.probeUrl)
                $myOnDemandRules.Add('Ssids', [Array]$currentOnDemandRules.ssids)
                if ($myOnDemandRules.values.Where({ $null -ne $_ }).Count -gt 0)
                {
                    $complexOnDemandRules += $myOnDemandRules
                }
            }

            $complexProxyServer = [ordered]@{}
            $complexProxyServer.Add('Address', $getValue.proxyServer.address)
            $complexProxyServer.Add('AutomaticallyDetectProxySettings', $getValue.proxyServer.automaticallyDetectProxySettings)
            $complexProxyServer.Add('AutomaticConfigurationScriptUrl', $getValue.proxyServer.automaticConfigurationScriptUrl)
            $complexProxyServer.Add('BypassProxyServerForLocalAddress', $getValue.proxyServer.bypassProxyServerForLocalAddress)
            if ($null -ne $getValue.proxyServer.'@odata.type')
            {
                $complexProxyServer.Add('ODataType', $getValue.proxyServer.'@odata.type')
            }
            $complexProxyServer.Add('Port', $getValue.proxyServer.port)
            if ($complexProxyServer.values.Where({ $null -ne $_ }).Count -eq 0)
            {
                $complexProxyServer = $null
            }

            $complexServer = [ordered]@{}
            $complexServer.Add('Address', $getValue.server.address)
            $complexServer.Add('Description', $getValue.server.description)
            $complexServer.Add('IsDefaultServer', $getValue.server.isDefaultServer)
            if ($complexServer.values.Where({ $null -ne $_ }).Count -eq 0)
            {
                $complexServer = $null
            }

            $result = @{
                AssociatedDomains              = $getValue.associatedDomains
                AuthenticationMethod           = $getValue.authenticationMethod
                ConnectionName                 = $getValue.connectionName
                ConnectionType                 = $getValue.connectionType
                CustomData                     = [Array]$complexCustomData
                CustomKeyValueData             = [Array]$complexCustomKeyValueData
                DeploymentChannel              = $getValue.deploymentChannel
                Description                    = $getValue.Description
                DisableOnDemandUserOverride    = $getValue.disableOnDemandUserOverride
                DisconnectOnIdle               = $getValue.disconnectOnIdle
                DisconnectOnIdleTimerInSeconds = $getValue.disconnectOnIdleTimerInSeconds
                DisplayName                    = $getValue.DisplayName
                EnablePerApp                   = $getValue.enablePerApp
                EnableSplitTunneling           = $getValue.enableSplitTunneling
                ExcludedDomains                = $getValue.excludedDomains
                ExcludeLocalNetworks           = $getValue.excludeLocalNetworks
                Id                             = $getValue.Id
                Identifier                     = $getValue.identifier
                IncludeAllNetworks             = $getValue.includeAllNetworks
                LoginGroupOrDomain             = $getValue.loginGroupOrDomain
                OnDemandRules                  = [Array]$complexOnDemandRules
                OptInToDeviceIdSharing         = $getValue.optInToDeviceIdSharing
                ProviderType                   = $getValue.providerType
                ProxyServer                    = $complexProxyServer
                Realm                          = $getValue.realm
                Role                           = $getValue.role
                RoleScopeTagIds                = Resolve-M365DSCIntuneRoleScopeTagNames -CurrentValues $getValue.RoleScopeTagIds -DesiredValues $this.RoleScopeTagIds
                SafariDomains                  = $getValue.safariDomains
                Server                         = $complexServer
                Ensure                         = 'Present'
                Credential                     = $this.Credential
                ApplicationId                  = $this.ApplicationId
                TenantId                       = $this.TenantId
                ApplicationSecret              = $this.ApplicationSecret
                CertificateThumbprint          = $this.CertificateThumbprint
                CertificatePassword            = $this.CertificatePassword
                CertificatePath                = $this.CertificatePath
                ManagedIdentity                = $this.ManagedIdentity
                AccessTokens                   = $this.AccessTokens
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

        Write-Verbose -Message "Setting configuration of Intune V P N Configuration Policy for macOS {$($this.Id)}"

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
            $boundParameters.Add('@odata.type', '#microsoft.graph.macOSVpnConfiguration')

            if ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
            {
                Write-Verbose -Message "Creating new Intune V P N Configuration Policy for macOS {$($this.Id)}"

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
                Write-Verbose -Message "Updating Intune V P N Configuration Policy for macOS {$($this.Id)}"

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
                Write-Verbose -Message "Removing Intune V P N Configuration Policy for macOS {$($this.Id)}"
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
                -ODataType 'microsoft.graph.macOSVpnConfiguration' `
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

                if ($null -ne $Results.CustomData)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.CustomData `
                        -CIMInstanceName 'MSFT_MicrosoftGraphKeyValue'
                    if (-not [System.String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.CustomData = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('CustomData') | Out-Null
                    }
                }

                if ($null -ne $Results.CustomKeyValueData)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.CustomKeyValueData `
                        -CIMInstanceName 'MSFT_MicrosoftGraphKeyValuePair2'
                    if (-not [System.String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.CustomKeyValueData = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('CustomKeyValueData') | Out-Null
                    }
                }

                if ($null -ne $Results.OnDemandRules)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.OnDemandRules `
                        -CIMInstanceName 'MSFT_MicrosoftGraphVpnOnDemandRule'
                    if (-not [System.String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.OnDemandRules = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('OnDemandRules') | Out-Null
                    }
                }

                if ($null -ne $Results.ProxyServer)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.ProxyServer `
                        -CIMInstanceName 'MSFT_MicrosoftGraphVpnProxyServer'
                    if (-not [System.String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.ProxyServer = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('ProxyServer') | Out-Null
                    }
                }

                if ($null -ne $Results.Server)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.Server `
                        -CIMInstanceName 'MSFT_MicrosoftGraphVpnServer1'
                    if (-not [System.String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.Server = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('Server') | Out-Null
                    }
                }
                $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                    -ConnectionMode $ConnectionMode `
                    -ModulePath $this.GetModulePath() `
                    -Results $Results `
                    -Credential $this.Credential `
                    -NoEscape @('Assignments', 'CustomData', 'CustomKeyValueData', 'OnDemandRules', 'ProxyServer', 'Server')
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

    hidden [IntuneVPNConfigurationPolicyMacOS] AsResult([System.Object] $Values)
    {
        if ($Values -is [IntuneVPNConfigurationPolicyMacOS])
        {
            return $Values
        }

        $result = [IntuneVPNConfigurationPolicyMacOS]::new()
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

class MSFT_MicrosoftGraphKeyValue
{
    [DscProperty()]
    [System.ComponentModel.Description('Key.')]
    [System.String] $Key

    [DscProperty()]
    [System.ComponentModel.Description('Value.')]
    [System.String] $Value
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

class MSFT_MicrosoftGraphVpnOnDemandRule
{
    [DscProperty()]
    [System.ComponentModel.Description('Action. Possible values are: connect, evaluateConnection, ignore, disconnect.')]
    [ValidateSet('connect', 'evaluateConnection', 'ignore', 'disconnect')]
    [System.String] $Action

    [DscProperty()]
    [System.ComponentModel.Description('DNS Search Domains.')]
    [System.String[]] $DnsSearchDomains

    [DscProperty()]
    [System.ComponentModel.Description('DNS Search Server Address.')]
    [System.String[]] $DnsServerAddressMatch

    [DscProperty()]
    [System.ComponentModel.Description('Domain Action (Only applicable when Action is evaluate connection). Possible values are: connectIfNeeded, neverConnect.')]
    [ValidateSet('connectIfNeeded', 'neverConnect')]
    [System.String] $DomainAction

    [DscProperty()]
    [System.ComponentModel.Description('Domains (Only applicable when Action is evaluate connection).')]
    [System.String[]] $Domains

    [DscProperty()]
    [System.ComponentModel.Description('Network interface to trigger VPN. Possible values are: notConfigured, ethernet, wiFi, cellular.')]
    [ValidateSet('notConfigured', 'ethernet', 'wiFi', 'cellular')]
    [System.String] $InterfaceTypeMatch

    [DscProperty()]
    [System.ComponentModel.Description('Probe Required Url (Only applicable when Action is evaluate connection and DomainAction is connect if needed).')]
    [System.String] $ProbeRequiredUrl

    [DscProperty()]
    [System.ComponentModel.Description('A URL to probe. If this URL is successfully fetched (returning a 200 HTTP status code) without redirection, this rule matches.')]
    [System.String] $ProbeUrl

    [DscProperty()]
    [System.ComponentModel.Description('Network Service Set Identifiers (SSIDs).')]
    [System.String[]] $Ssids
}

class MSFT_MicrosoftGraphVpnProxyServer
{
    [DscProperty()]
    [System.ComponentModel.Description('Address.')]
    [System.String] $Address

    [DscProperty()]
    [System.ComponentModel.Description('Automatically detect proxy settings.')]
    [System.Nullable[System.Boolean]] $AutomaticallyDetectProxySettings

    [DscProperty()]
    [System.ComponentModel.Description('Proxy''s automatic configuration script url.')]
    [System.String] $AutomaticConfigurationScriptUrl

    [DscProperty()]
    [System.ComponentModel.Description('Bypass proxy server for local address.')]
    [System.Nullable[System.Boolean]] $BypassProxyServerForLocalAddress

    [DscProperty()]
    [System.ComponentModel.Description('The type of the entity.')]
    [ValidateSet('#microsoft.graph.windows10VpnProxyServer', '#microsoft.graph.windows81VpnProxyServer')]
    [System.String] $ODataType

    [DscProperty()]
    [System.ComponentModel.Description('Port. Valid values 0 to 65535')]
    [System.Nullable[System.Int32]] $Port
}

class MSFT_MicrosoftGraphVpnServer1
{
    [DscProperty()]
    [System.ComponentModel.Description('Address (IP address, FQDN or URL)')]
    [System.String] $Address

    [DscProperty()]
    [System.ComponentModel.Description('Description.')]
    [System.String] $Description

    [DscProperty()]
    [System.ComponentModel.Description('Default server.')]
    [System.Nullable[System.Boolean]] $IsDefaultServer
}
