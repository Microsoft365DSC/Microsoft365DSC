using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class IntuneVPNConfigurationPolicyAndroidWork : M365DSCResourceBase
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
    [System.ComponentModel.Description('Authentication method. Inherited from vpnConfiguration. Possible values are: certificate, usernameAndPassword, sharedSecret, derivedCredential, azureAD.')]
    [ValidateSet('certificate', 'usernameAndPassword', 'sharedSecret', 'derivedCredential', 'azureAD')]
    [System.String] $authenticationMethod

    [DscProperty()]
    [System.ComponentModel.Description('Connection name displayed to the user.')]
    [System.String] $connectionName

    [DscProperty()]
    [System.ComponentModel.Description('Role when connection type is set to Pulse Secure. Inherited from vpnConfiguration.')]
    [System.String] $role

    [DscProperty()]
    [System.ComponentModel.Description('Realm when connection type is set to Pulse Secure. Inherited from vpnConfiguration.')]
    [System.String] $realm

    [DscProperty()]
    [System.ComponentModel.Description('Fingerprint is a string that will be used to verify the VPN server can be trusted, which is only applicable when connection type is Check Point Capsule VPN.')]
    [System.String] $fingerprint

    [DscProperty()]
    [System.ComponentModel.Description('VPN Server on the network. Make sure end users can access this network location.')]
    [MSFT_MicrosoftGraphvpnServer[]] $servers

    [DscProperty()]
    [System.ComponentModel.Description('Connection type. Possible values are: ciscoAnyConnect, pulseSecure, f5EdgeClient, dellSonicWallMobileConnect, checkPointCapsuleVpn, citrix, microsoftTunnel, netMotionMobility, microsoftProtect.')]
    [ValidateSet('ciscoAnyConnect', 'pulseSecure', 'f5EdgeClient', 'dellSonicWallMobileConnect', 'checkPointCapsuleVpn', 'citrix', 'microsoftTunnel', 'netMotionMobility', 'microsoftProtect', 'paloAltoGlobalProtect')]
    [System.String] $connectionType

    [DscProperty()]
    [System.ComponentModel.Description('Proxy Server.')]
    [MSFT_MicrosoftvpnProxyServer[]] $proxyServer

    [DscProperty()]
    [System.ComponentModel.Description('Targeted App package IDs.')]
    [System.String[]] $targetedPackageIds

    [DscProperty()]
    [System.ComponentModel.Description('Targeted mobile apps. This collection can contain a maximum of 500 elements.')]
    [MSFT_targetedMobileApps[]] $targetedMobileApps

    [DscProperty()]
    [System.ComponentModel.Description('Whether or not to enable always-on VPN connection.')]
    [System.Nullable[System.Boolean]] $alwaysOn

    [DscProperty()]
    [System.ComponentModel.Description('If always-on VPN connection is enabled, whether or not to lock network traffic when that VPN is disconnected.')]
    [System.Nullable[System.Boolean]] $alwaysOnLockdown

    [DscProperty()]
    [System.ComponentModel.Description('List of app package names that will be able to access the network directly when VPN is in lockdown mode but not connected.')]
    [System.String[]] $lockdownExclusionList

    [DscProperty()]
    [System.ComponentModel.Description('Microsoft Tunnel site ID.')]
    [System.String] $microsoftTunnelSiteId

    [DscProperty()]
    [System.ComponentModel.Description('List of hosts to exclude using the proxy on connections for. These hosts can use wildcards such as *.example.com.')]
    [System.String[]] $proxyExclusionList

    [DscProperty()]
    [System.ComponentModel.Description('Custom data to define key/value pairs specific to a VPN provider. This collection can contain a maximum of 25 elements.')]
    [MSFT_customData[]] $customData

    [DscProperty()]
    [System.ComponentModel.Description('Custom data to define key/value pairs specific to a VPN provider. This collection can contain a maximum of 25 elements.')]
    [MSFT_customKeyValueData[]] $customKeyValueData

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

    [IntuneVPNConfigurationPolicyAndroidWork] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [IntuneVPNConfigurationPolicyAndroidWork]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of the Intune VPN Policy for Android Work with Id {$($this.Id)} and DisplayName {$($this.DisplayName)}"

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
                    $getValue = Get-MgBetaDeviceManagementDeviceConfiguration -All -Filter "DisplayName eq '$($this.Displayname -replace "'", "''")' and isof('microsoft.graph.androidWorkProfileVpnConfiguration')" -ErrorAction SilentlyContinue
                }
                #endregion

                if ($null -eq $getValue)
                {
                    Write-Verbose -Message "No Intune VPN Policy for Android Work with Id {$($this.Id)} was found"
                    return $this.AsResult($nullResult)
                }
            }
            else
            {
                $getValue = $this.ExportedInstance
            }

            $resolvedId = $getValue.Id

            Write-Verbose -Message "An Intune VPN Policy for Android Work with id {$($resolvedId)} and DisplayName {$($this.DisplayName)} was found"

            $complexServers = @()
            foreach ($currentservers in $getValue.servers)
            {
                $myservers = [ordered]@{}
                $myservers.Add('address', $currentservers.address)
                $myservers.Add('description', $currentservers.description)
                $myservers.Add('isDefaultServer', $currentservers.isDefaultServer)
                if ($myservers.values.Where({ $null -ne $_ }).Count -gt 0)
                {
                    $complexServers += $myservers
                }
            }

            $complexProxyServers = @()
            foreach ($currentservers in $getValue.proxyServer)
            {
                $myservers = [ordered]@{}
                $myservers.Add('automaticConfigurationScriptUrl', $currentservers.automaticConfigurationScriptUrl)
                $myservers.Add('address', $currentservers.address)
                $myservers.Add('port', $currentservers.port)
                if ($myservers.values.Where({ $null -ne $_ }).Count -gt 0)
                {
                    $complexProxyServers += $myservers
                }
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
                Id                    = $getValue.Id
                Description           = $getValue.Description
                DisplayName           = $getValue.DisplayName
                RoleScopeTagIds       = Resolve-M365DSCIntuneRoleScopeTagNames -CurrentValues $getValue.RoleScopeTagIds -DesiredValues $this.RoleScopeTagIds
                authenticationMethod  = $getValue.authenticationMethod
                connectionName        = $getValue.connectionName
                role                  = $getValue.role
                realm                 = $getValue.realm
                fingerprint           = $getValue.fingerprint
                servers               = $complexServers
                connectionType        = $getValue.connectionType
                proxyServer           = $complexProxyServers
                targetedPackageIds    = $getValue.targetedPackageIds
                targetedMobileApps    = $complexTargetedMobileApps
                alwaysOn              = $getValue.alwaysOn
                alwaysOnLockdown      = $getValue.alwaysOnLockdown
                lockdownExclusionList = $getValue.lockdownExclusionList
                microsoftTunnelSiteId = $getValue.microsoftTunnelSiteId
                proxyExclusionList    = $getValue.proxyExclusionList
                customData            = $complexCustomData
                customKeyValueData    = $complexCustomKeyValueData
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

        Write-Verbose -Message "Setting configuration of the Intune VPN Policy for Android Work with Id {$($this.Id)} and DisplayName {$($this.DisplayName)}"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $currentInstance = $this.Get().ToHashtable()
        $boundParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()

        if ($boundParameters.ContainsKey('RoleScopeTagIds'))
        {
            $boundParameters.RoleScopeTagIds = Resolve-M365DSCIntuneRoleScopeTagIds -RoleScopeTagIds $this.RoleScopeTagIds
        }

        if ($boundParameters.ContainsKey('proxyServer'))
        {
            $boundParameters.Remove('proxyServer') | Out-Null
            if ($this.proxyServer.Count -gt 0)
            {
                $boundParameters.Add('proxyServer', $this.proxyServer[0])
            }
        }

        $boundParameters = Rename-M365DSCCimInstanceParameter -Properties $boundParameters

        if ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Creating {$($this.DisplayName)}"
            $createParameters = $boundParameters
            $createParameters.Remove('Assignments') | Out-Null
            $createParameters.Remove('Id') | Out-Null

            #region resource generator code
            $createParameters.Add('@odata.type', '#microsoft.graph.androidWorkProfileVpnConfiguration')
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
            $updateParameters.Add('@odata.type', '#microsoft.graph.androidWorkProfileVpnConfiguration')
            Update-MgBetaDeviceManagementDeviceConfiguration -BodyParameter $updateParameters `
                -DeviceConfigurationId $currentInstance.Id
            $assignmentsHash = ConvertTo-IntunePolicyAssignment -IncludeDeviceFilter:$true -Assignments $this.Assignments
            Update-DeviceConfigurationPolicyAssignment -DeviceConfigurationPolicyId $currentInstance.id `
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
                -ODataType 'microsoft.graph.androidWorkProfileVpnConfiguration' `
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

                if ($null -ne $Results.servers)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.servers `
                        -CIMInstanceName 'MicrosoftGraphvpnServer' #MSFT_MicrosoftGraphVpnServer
                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.servers = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('servers') | Out-Null
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
                    -NoEscape @('servers', 'proxyServer', 'customData', 'customKeyValueData', 'targetedMobileApps', 'Assignments') `
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

    hidden [IntuneVPNConfigurationPolicyAndroidWork] AsResult([System.Object] $Values)
    {
        if ($Values -is [IntuneVPNConfigurationPolicyAndroidWork])
        {
            return $Values
        }

        $result = [IntuneVPNConfigurationPolicyAndroidWork]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
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
