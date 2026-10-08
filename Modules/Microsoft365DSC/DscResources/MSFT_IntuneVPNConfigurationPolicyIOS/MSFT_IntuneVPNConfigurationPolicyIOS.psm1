using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class IntuneVPNConfigurationPolicyIOS : M365DSCResourceBase
{
    [DscProperty()]
    [System.ComponentModel.Description('Id of the Intune policy.')]
    [System.String] $Id

    [DscProperty(Key)]
    [System.ComponentModel.Description('Display name of the Intune policy.')]
    [System.String] $DisplayName

    [DscProperty()]
    [System.ComponentModel.Description('Description of the Intune policy.')]
    [System.String] $Description

    [DscProperty()]
    [System.ComponentModel.Description('List of Scope Tags for this Entity instance.')]
    [System.String[]] $RoleScopeTagIds

    [DscProperty()]
    [System.ComponentModel.Description('Connection name displayed to the user.')]
    [System.String] $connectionName

    [DscProperty()]
    [System.ComponentModel.Description('Connection type. Possible values are: ciscoAnyConnect, pulseSecure, f5EdgeClient, dellSonicWallMobileConnect, checkPointCapsuleVpn, customVpn, ciscoIPSec, citrix, ciscoAnyConnectV2, paloAltoGlobalProtect, zscalerPrivateAccess, f5Access2018, citrixSso, paloAltoGlobalProtectV2, ikEv2, alwaysOn, microsoftTunnel, netMotionMobility, microsoftProtect.')]
    [ValidateSet('ciscoAnyConnect', 'pulseSecure', 'f5EdgeClient', 'dellSonicWallMobileConnect', 'checkPointCapsuleVpn', 'customVpn', 'ciscoIPSec', 'citrix', 'ciscoAnyConnectV2', 'paloAltoGlobalProtect', 'zscalerPrivateAccess', 'f5Access2018', 'citrixSso', 'paloAltoGlobalProtectV2', 'ikEv2', 'alwaysOn', 'microsoftTunnel', 'netMotionMobility', 'microsoftProtect')]
    [System.String] $connectionType

    [DscProperty()]
    [System.ComponentModel.Description('Send all network traffic through VPN.')]
    [System.Nullable[System.Boolean]] $enableSplitTunneling

    [DscProperty()]
    [System.ComponentModel.Description('Authentication method for this VPN connection.')]
    [ValidateSet('certificate', 'usernameAndPassword', 'sharedSecret', 'derivedCredential', 'azureAD')]
    [System.String] $authenticationMethod

    [DscProperty()]
    [System.ComponentModel.Description('Safari domains when this VPN per App setting is enabled. In addition to the apps associated with this VPN, Safari domains specified here will also be able to trigger this VPN connection.')]
    [System.String[]] $safariDomains

    [DscProperty()]
    [System.ComponentModel.Description('Associated Domains. These domains will be linked with the VPN configuration.')]
    [System.String[]] $associatedDomains

    [DscProperty()]
    [System.ComponentModel.Description('Domains that are accessed through the public internet instead of through VPN, even when per-app VPN is activated.')]
    [System.String[]] $excludedDomains

    [DscProperty()]
    [System.ComponentModel.Description('Represents the assignment to the Intune policy.')]
    [MSFT_MicrosoftvpnProxyServer[]] $proxyServer

    [DscProperty()]
    [System.ComponentModel.Description('Opt-In to sharing the device''s Id to third-party vpn clients for use during network access control validation.')]
    [System.Nullable[System.Boolean]] $optInToDeviceIdSharing

    [DscProperty()]
    [System.ComponentModel.Description('Not documented on https://learn.microsoft.com/en-us/graph/api/resources/intune-deviceconfig-applevpnconfiguration?view=graph-rest-beta.')]
    [System.String[]] $excludeList

    [DscProperty()]
    [System.ComponentModel.Description('VPN Server on the network. Make sure end users can access this network location.')]
    [MSFT_MicrosoftGraphvpnServer[]] $server

    [DscProperty()]
    [System.ComponentModel.Description('Use this field to enable functionality not supported by Intune, but available in your VPN solution. Contact your VPN vendor to learn how to add these key/value pairs. This collection can contain a maximum of 25 elements')]
    [MSFT_customData[]] $customData

    [DscProperty()]
    [System.ComponentModel.Description('Use this field to enable functionality not supported by Intune, but available in your VPN solution. Contact your VPN vendor to learn how to add these key/value pairs. This collection can contain a maximum of 25 elements')]
    [MSFT_customKeyValueData[]] $customKeyValueData

    [DscProperty()]
    [System.ComponentModel.Description('On-Demand Rules. This collection can contain a maximum of 500 elements.')]
    [MSFT_DeviceManagementConfigurationPolicyVpnOnDemandRule[]] $onDemandRules

    [DscProperty()]
    [System.ComponentModel.Description('Not documented on https://learn.microsoft.com/en-us/graph/api/resources/intune-deviceconfig-applevpnconfiguration?view=graph-rest-beta.')]
    [MSFT_targetedMobileApps[]] $targetedMobileApps

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

    [DscProperty()]
    [System.ComponentModel.Description('Version of the device configuration. Inherited from deviceConfiguration.')]
    [System.Nullable[System.UInt32]] $version

    [DscProperty()]
    [System.ComponentModel.Description('Login group or domain when connection type is set to Dell SonicWALL Mobile Connection. Inherited from appleVpnConfiguration.')]
    [System.String] $loginGroupOrDomain

    [DscProperty()]
    [System.ComponentModel.Description('Role when connection type is set to Pulse Secure. Inherited from appleVpnConfiguration.')]
    [System.String] $role

    [DscProperty()]
    [System.ComponentModel.Description('Realm when connection type is set to Pulse Secure. Inherited from appleVpnConfiguration.')]
    [System.String] $realm

    [DscProperty()]
    [System.ComponentModel.Description('Identifier provided by VPN vendor when connection type is set to Custom VPN. For example: Cisco AnyConnect uses an identifier of the form com.cisco.anyconnect.applevpn.plugin Inherited from appleVpnConfiguration.')]
    [System.String] $identifier

    [DscProperty()]
    [System.ComponentModel.Description('Setting this to true creates Per-App VPN payload which can later be associated with Apps that can trigger this VPN conneciton on the end user''s iOS device. Inherited from appleVpnConfiguration.')]
    [System.Nullable[System.Boolean]] $enablePerApp

    [DscProperty()]
    [System.ComponentModel.Description('Provider type for per-app VPN. Inherited from appleVpnConfiguration. Possible values are: notConfigured, appProxy, packetTunnel.')]
    [ValidateSet('notConfigured', 'appProxy', 'packetTunnel')]
    [System.String] $providerType

    [DscProperty()]
    [System.ComponentModel.Description('Toggle to prevent user from disabling automatic VPN in the Settings app Inherited from appleVpnConfiguration.')]
    [System.Nullable[System.Boolean]] $disableOnDemandUserOverride

    [DscProperty()]
    [System.ComponentModel.Description('Whether to disconnect after on-demand connection idles Inherited from appleVpnConfiguration')]
    [System.Nullable[System.Boolean]] $disconnectOnIdle

    [DscProperty()]
    [System.ComponentModel.Description('The length of time in seconds to wait before disconnecting an on-demand connection. Valid values 0 to 65535 Inherited from appleVpnConfiguration.')]
    [System.Nullable[System.UInt32]] $disconnectOnIdleTimerInSeconds

    [DscProperty()]
    [System.ComponentModel.Description('Microsoft Tunnel site ID.')]
    [System.String] $microsoftTunnelSiteId

    [DscProperty()]
    [System.ComponentModel.Description('Zscaler only. Zscaler cloud which the user is assigned to.')]
    [System.String] $cloudName

    [DscProperty()]
    [System.ComponentModel.Description('Zscaler only. Blocks network traffic until the user signs into Zscaler app. True means traffic is blocked.')]
    [System.Nullable[System.Boolean]] $strictEnforcement

    [DscProperty()]
    [System.ComponentModel.Description('Zscaler only. Enter a static domain to pre-populate the login field with in the Zscaler app. If this is left empty, the user''s Azure Active Directory domain will be used instead.')]
    [System.String] $userDomain

    # Export-only. Not part of the resource schema.
    [System.String] $Filter

    [IntuneVPNConfigurationPolicyIOS] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [IntuneVPNConfigurationPolicyIOS]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of the Intune VPN Policy for iOS with Id {$($this.Id)} and DisplayName {$($this.DisplayName)}"

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
                if (-not [string]::IsNullOrWhiteSpace($this.Id))
                {
                    $getValue = Get-MgBetaDeviceManagementDeviceConfiguration -All -Filter "Id eq '$($this.Id)'" -ErrorAction SilentlyContinue
                }

                #region resource generator code
                if ($null -eq $getValue)
                {
                    $getValue = Get-MgBetaDeviceManagementDeviceConfiguration -All -Filter "DisplayName eq '$($this.Displayname -replace "'", "''")' and isof('microsoft.graph.iosVpnConfiguration')" -ErrorAction SilentlyContinue
                }
                #endregion

                if ($null -eq $getValue)
                {
                    Write-Verbose -Message "No Intune VPN Policy for iOS with Id {$($this.Id)} was found"
                    return $this.AsResult($nullResult)
                }
            }
            else
            {
                $getValue = $this.ExportedInstance
            }
            $resolvedId = $getValue.Id

            Write-Verbose -Message "An Intune VPN Policy for iOS with id {$($resolvedId)} and DisplayName {$($this.DisplayName)} was found"

            $complexServer = $null
            if ($null -ne $getValue.server)
            {
                $complexServer = @{
                    address = $getValue.server.address
                    description = $getValue.server.description
                    isDefaultServer = $getValue.server.isDefaultServer
                }
            }
            if ($complexServer.values.Where({ $null -ne $_ }).Count -eq 0)
            {
                $complexServer = $null
            }

            $complexProxyServer = $null
            if ($null -ne $getValue.proxyServer)
            {
                $complexProxyServer = @{
                    automaticConfigurationScriptUrl = $getValue.proxyServer.automaticConfigurationScriptUrl
                    address = $getValue.proxyServer.address
                    port = $getValue.proxyServer.port
                }
            }
            if ($complexProxyServer.values.Where({ $null -ne $_ }).Count -eq 0)
            {
                $complexProxyServer = $null
            }

            $complexCustomData = @()
            foreach ($value in $getValue.customData)
            {
                $myCustomdata = [ordered]@{}
                $myCustomdata.Add('key', $value.key)
                $myCustomdata.Add('value', $value.value)
                if ($myCustomdata.values.Where({ $null -ne $_ }).Count -gt 0)
                {
                    $complexCustomData += $myCustomdata
                }
            }

            $complexCustomKeyValueData = @()
            foreach ($value in $getValue.customKeyValueData)
            {
                $myCVdata = [ordered]@{}
                $myCVdata.Add('name', $value.name)
                $myCVdata.Add('value', $value.value)
                if ($myCVdata.values.Where({ $null -ne $_ }).Count -gt 0)
                {
                    $complexCustomKeyValueData += $myCVdata
                }
            }

            $complexTargetedMobileApps = @()
            foreach ($value in $getValue.targetedMobileApps)
            {
                $myTMAdata = [ordered]@{}
                $myTMAdata.Add('name', $value.name)
                $myTMAdata.Add('publisher', $value.publisher)
                $myTMAdata.Add('appStoreUrl', $value.appStoreUrl)
                $myTMAdata.Add('appId', $value.appId)
                if ($myTMAdata.values.Where({ $null -ne $_ }).Count -gt 0)
                {
                    $complexTargetedMobileApps += $myTMAdata
                }
            }

            $results = @{
                #region resource generator code
                Id                             = $getValue.Id
                Description                    = $getValue.Description
                DisplayName                    = $getValue.DisplayName
                RoleScopeTagIds                = Resolve-M365DSCIntuneRoleScopeTagNames -CurrentValues $getValue.RoleScopeTagIds -DesiredValues $this.RoleScopeTagIds
                connectionName                 = $getValue.connectionName
                connectionType                 = $getValue.connectionType
                enableSplitTunneling           = $getValue.enableSplitTunneling
                authenticationMethod           = $getValue.authenticationMethod
                safariDomains                  = $getValue.safariDomains
                associatedDomains              = $getValue.associatedDomains
                excludedDomains                = $getValue.excludedDomains
                optInToDeviceIdSharing         = $getValue.optInToDeviceIdSharing
                excludeList                    = $getValue.excludeList
                server                         = [array]$complexServer
                customData                     = $complexCustomData #$getValue.customData
                customKeyValueData             = $complexCustomKeyValueData #$getValue.customKeyValueData
                onDemandRules                  = $getValue.onDemandRules
                proxyServer                    = [array]$complexProxyServer
                targetedMobileApps             = $complexTargetedMobileApps #$getValue.targetedMobileApps
                Ensure                         = 'Present'
                Credential                     = $this.Credential
                ApplicationId                  = $this.ApplicationId
                TenantId                       = $this.TenantId
                ApplicationSecret              = $this.ApplicationSecret
                CertificateThumbprint          = $this.CertificateThumbprint
                CertificatePath                = $this.CertificatePath
                CertificatePassword            = $this.CertificatePassword
                ManagedIdentity                = $this.ManagedIdentity
                AccessTokens                   = $this.AccessTokens
                loginGroupOrDomain             = $getValue.loginGroupOrDomain
                role                           = $getValue.role
                realm                          = $getValue.realm
                identifier                     = $getValue.identifier
                enablePerApp                   = $getValue.enablePerApp
                providerType                   = $getValue.providerType
                disableOnDemandUserOverride    = $getValue.disableOnDemandUserOverride
                disconnectOnIdle               = $getValue.disconnectOnIdle
                disconnectOnIdleTimerInSeconds = $getValue.disconnectOnIdleTimerInSeconds
                microsoftTunnelSiteId          = $getValue.microsoftTunnelSiteId
                cloudName                      = $getValue.cloudName
                strictEnforcement              = $getValue.strictEnforcement
                userDomain                     = $getValue.userDomain

            }

            $assignmentsValues = Get-M365DSCIntuneExpandedAssignments -Instance $getValue
            if ($null -eq $assignmentsValues)
            {
                $assignmentsValues = Get-MgBetaDeviceManagementDeviceConfigurationAssignment -DeviceConfigurationId $Results.Id
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

        Write-Verbose -Message "Setting configuration of the Intune VPN Configuration Policy for iOS with Id {$($this.Id)} and DisplayName {$($this.DisplayName)}"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $currentInstance = $this.Get().ToHashtable()
        $boundParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()

        if ($boundParameters.ContainsKey('RoleScopeTagIds'))
        {
            $boundParameters.RoleScopeTagIds = Resolve-M365DSCIntuneRoleScopeTagIds -RoleScopeTagIds $this.RoleScopeTagIds
        }

        if ($boundParameters.ContainsKey('proxyServer') -and $this.proxyServer.Count -gt 0)
        {
            $boundParameters.Remove('proxyServer') | Out-Null
            $boundParameters.Add('proxyServer', $this.proxyServer[0])
        }
        if ($boundParameters.ContainsKey('server') -and $this.server.Count -gt 0)
        {
            $boundParameters.Remove('server') | Out-Null
            $boundParameters.Add('server', $this.server[0])
        }
        if ($boundParameters.ContainsKey('customKeyValueData'))
        {
            $boundParameters.Remove('customKeyValueData') | Out-Null
            $newCustomKeyValueData = @()
            foreach ($item in $this.customKeyValueData)
            {
                $newCustomKeyValueData += @{
                    '@odata.type' = '#microsoft.graph.keyValuePair'
                    name = $item.name
                    value = $item.value
                }
            }
            $boundParameters.Add('customKeyValueData', $newCustomKeyValueData)
        }

        $boundParameters = Rename-M365DSCCimInstanceParameter -Properties $boundParameters

        if ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Creating {$($this.DisplayName)}"
            $createParameters = $boundParameters
            $createParameters.Remove('Assignments') | Out-Null
            $createParameters.Remove('Id') | Out-Null

            #region resource generator code
            $createParameters.Add('@odata.type', '#microsoft.graph.iosVpnConfiguration')
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
            Write-Verbose -Message "Updating {$($this.DisplayName)}"

            $updateParameters = $boundParameters
            $updateParameters.Remove('Assignments') | Out-Null
            $updateParameters.Remove('Id') | Out-Null

            #region resource generator code
            $updateParameters.Add('@odata.type', '#microsoft.graph.iosVpnConfiguration')
            Update-MgBetaDeviceManagementDeviceConfiguration -BodyParameter $updateParameters `
                -DeviceConfigurationId $currentInstance.Id
            $assignmentsHash = ConvertTo-IntunePolicyAssignment -IncludeDeviceFilter:$true -Assignments $this.Assignments
            Update-DeviceConfigurationPolicyAssignment -DeviceConfigurationPolicyId $currentInstance.Id `
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
            # TODO: Check if microsoft.graph.iosikEv2VpnConfiguration matches this resource
            [array]$getValue = Get-M365DSCExportCachedCollection -Collection 'deviceConfigurations' `
                -ODataType @('microsoft.graph.iosVpnConfiguration') `
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

                if ($null -ne $Results.server)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.server `
                        -CIMInstanceName 'MicrosoftGraphvpnServer' #MSFT_MicrosoftGraphVpnServer
                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.server = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('server') | Out-Null
                    }
                }

                if ($null -ne $Results.onDemandRules)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.onDemandRules `
                        -CIMInstanceName 'MSFT_DeviceManagementConfigurationPolicyVpnOnDemandRule' #MSFT_DeviceManagementConfigurationPolicyVpnOnDemandRule
                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.onDemandRules = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('onDemandRules') | Out-Null
                    }
                }

                if ($null -ne $Results.proxyServer)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.proxyServer `
                        -CIMInstanceName 'MSFT_MicrosoftvpnProxyServer'
                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.proxyServer = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('proxyServer') | Out-Null
                    }
                }

                if ($null -ne $Results.customData)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.customData `
                        -CIMInstanceName 'MSFT_CustomData'
                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.customData = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('customData') | Out-Null
                    }
                }

                if ($null -ne $Results.customKeyValueData)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.customKeyValueData `
                        -CIMInstanceName 'MSFT_customKeyValueData'
                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.customKeyValueData = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('customKeyValueData') | Out-Null
                    }
                }

                if ($null -ne $Results.targetedMobileApps)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.targetedMobileApps `
                        -CIMInstanceName 'MSFT_targetedMobileApps'
                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.targetedMobileApps = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('targetedMobileApps') | Out-Null
                    }
                }

                $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                    -ConnectionMode $ConnectionMode `
                    -ModulePath $this.GetModulePath() `
                    -Results $Results `
                    -Credential $this.Credential `
                    -NoEscape @('server', 'onDemandRules', 'proxyServer', 'customData', 'customKeyValueData', 'targetedMobileApps', 'Assignments') `
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

    hidden [IntuneVPNConfigurationPolicyIOS] AsResult([System.Object] $Values)
    {
        if ($Values -is [IntuneVPNConfigurationPolicyIOS])
        {
            return $Values
        }

        $result = [IntuneVPNConfigurationPolicyIOS]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}

class MSFT_MicrosoftvpnProxyServer
{
    [DscProperty()]
    [System.ComponentModel.Description('Proxy''s automatic configuration script url.')]
    [System.String] $automaticConfigurationScriptUrl

    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('Address.')]
    [System.String] $address

    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('Port. Valid values 0 to 65535.')]
    [System.Nullable[System.UInt32]] $port
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

class MSFT_customData
{
    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('Key for the custom data entry.')]
    [System.String] $key

    [DscProperty()]
    [System.ComponentModel.Description('Value for the custom data entry.')]
    [System.String] $value
}

class MSFT_customKeyValueData
{
    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('Name for the custom data entry.')]
    [System.String] $name

    [DscProperty()]
    [System.ComponentModel.Description('Value for the custom data entry.')]
    [System.String] $value
}

class MSFT_DeviceManagementConfigurationPolicyVpnOnDemandRule
{
    [DscProperty()]
    [System.ComponentModel.Description('Network Service Set Identifiers (SSIDs).')]
    [System.String[]] $ssids

    [DscProperty()]
    [System.ComponentModel.Description('DNS Search Domains.')]
    [System.String[]] $dnsSearchDomains

    [DscProperty()]
    [System.ComponentModel.Description('A URL to probe. If this URL is successfully fetched, returning a 200 HTTP status code, without redirection, this rule matches.')]
    [System.String] $probeUrl

    [DscProperty()]
    [System.ComponentModel.Description('Action. Possible values are: connect, evaluateConnection, ignore, disconnect.')]
    [ValidateSet('connect', 'evaluateConnection', 'ignore', 'disconnect')]
    [System.String] $action

    [DscProperty()]
    [System.ComponentModel.Description('Domain Action, Only applicable when Action is evaluate connection. Possible values are: connectIfNeeded, neverConnect.')]
    [ValidateSet('connectIfNeeded', 'neverConnect')]
    [System.String] $domainAction

    [DscProperty()]
    [System.ComponentModel.Description('Domains, Only applicable when Action is evaluate connection.')]
    [System.String[]] $domains

    [DscProperty()]
    [System.ComponentModel.Description('Probe Required URL. Only applicable when Action is evaluate connection and DomainAction is connectIfNeeded.')]
    [System.String] $probeRequiredUrl

    [DscProperty()]
    [System.ComponentModel.Description('Network interface to trigger VPN. Possible values are: notConfigured, ethernet, wiFi, cellular.')]
    [ValidateSet('notConfigured', 'ethernet', 'wiFi', 'cellular')]
    [System.String] $interfaceTypeMatch

    [DscProperty()]
    [System.ComponentModel.Description('DNS Search Server Address.')]
    [System.String[]] $dnsServerAddressMatch
}

class MSFT_targetedMobileApps
{
    [DscProperty()]
    [System.ComponentModel.Description('The application name.')]
    [System.String] $name

    [DscProperty()]
    [System.ComponentModel.Description('The publisher of the application.')]
    [System.String] $publisher

    [DscProperty()]
    [System.ComponentModel.Description('The Store URL of the application.')]
    [System.String] $appStoreUrl

    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('The application or bundle identifier of the application.')]
    [System.String] $appId
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
