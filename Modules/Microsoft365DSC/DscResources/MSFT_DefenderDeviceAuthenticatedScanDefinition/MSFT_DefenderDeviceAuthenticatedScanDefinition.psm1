using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class DefenderDeviceAuthenticatedScanDefinition : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('Name of the scan definition.')]
    [System.String] $Name

    [DscProperty()]
    [System.ComponentModel.Description('Unique identified for the scan definition.')]
    [System.String] $Id

    [DscProperty()]
    [System.ComponentModel.Description('Interval in hours to run the scan.')]
    [System.Nullable[System.UInt32]] $IntervalInHours

    [DscProperty()]
    [System.ComponentModel.Description('Target of the scan definition.')]
    [System.String] $Target

    [DscProperty()]
    [System.ComponentModel.Description('Determines if the scan definition is active or not.')]
    [System.Nullable[System.Boolean]] $IsActive

    [DscProperty()]
    [System.ComponentModel.Description('Type of scan.')]
    [System.String] $ScanType

    [DscProperty()]
    [System.ComponentModel.Description('Information about the associated scan agent.')]
    [MSFT_DefenderDeviceAuthenticatedScanDefinitionScanAgent] $ScannerAgent

    [DscProperty()]
    [System.ComponentModel.Description('Authentication parameters.')]
    [MSFT_DefenderDeviceAuthenticatedScanDefinitionAuthenticationParams] $ScanAuthenticationParams

    [DscProperty()]
    [System.ComponentModel.Description('Present ensures the instance exists, absent ensures it is removed.')]
    [ValidateSet('Absent', 'Present')]
    [System.String] $Ensure

    [DscProperty()]
    [System.ComponentModel.Description('Credentials of the workload''s Admin')]
    [System.Management.Automation.PSCredential] $Credential

    [DscProperty()]
    [System.ComponentModel.Description('Id of the Azure Active Directory application to authenticate with.')]
    [System.String] $ApplicationId

    [DscProperty()]
    [System.ComponentModel.Description('Id of the Azure Active Directory tenant used for authentication.')]
    [System.String] $TenantId

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
    [System.Management.Automation.PSCredential] $ApplicationSecret

    [DefenderDeviceAuthenticatedScanDefinition] Get()
    {
        $nullResult = $null
        $instance = $null
        if ($this.RequiresPowerShellCore())
        {
            $remote = [DefenderDeviceAuthenticatedScanDefinition]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration for Defender Device Authenticated Scan Definition with Name $($this.Name)"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.Id -ne $this.Id)
            {
                $null = $this.Connect('DefenderForEndpoint')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullResult = $this.GetBoundParameters()
                $nullResult.Ensure = 'Absent'

                $instances = (Invoke-M365DSCDefenderREST -Uri 'https://api.securitycenter.microsoft.com/api/DeviceAuthenticatedScanDefinitions' `
                        -Method GET).value
                if (-not [System.String]::IsNullOrEmpty($this.Id))
                {
                    $instance = $instances | Where-Object -FilterScript { $_.id -eq $this.Id }
                }
                if ($null -eq $instance)
                {
                    $instance = $instances | Where-Object -FilterScript { $_.scanName -eq $this.Name }
                }
            }
            else
            {
                $instance = $this.ExportedInstance
            }

            if ($null -eq $instance)
            {
                return $this.AsResult($nullResult)
            }

            $ScannerAgentValue = $null
            if ($null -ne $instance.scannerAgent)
            {
                $ScannerAgentValue = @{
                    id          = $instance.scannerAgent.id
                    machineId   = $instance.scannerAgent.machineId
                    machineName = $instance.scannerAgent.machineName
                }
            }

            # This property cannot be retrieve, nor changed once set.
            $ScanAuthenticationParamsValue = $null
            if ($null -ne $instance.scanAuthenticationParams)
            {
                $ScanAuthenticationParamsValue = @{
                    DataType           = $this.ScanAuthenticationParams.DataType
                    Type               = $this.ScanAuthenticationParams.Type
                    KeyVaultUrl        = $this.ScanAuthenticationParams.KeyVaultUrl
                    KeyVaultSecretName = $this.ScanAuthenticationParams.keyVaultSecretName
                    Domain             = $this.ScanAuthenticationParams.Domain
                    Username           = $this.ScanAuthenticationParams.Username
                    IsGMSAUser         = $this.ScanAuthenticationParams.IsGMSAUser
                    CommunityString    = $this.ScanAuthenticationParams.CommunityString
                    AuthProtocol       = $this.ScanAuthenticationParams.AuthProtocol
                    AuthPassword       = $this.ScanAuthenticationParams.AuthPassword
                    PrivProtocol       = $this.ScanAuthenticationParams.PrivProtocol
                    PrivPassword       = $this.ScanAuthenticationParams.PrivPassword
                }
            }
            else
            {
                $ScanAuthenticationParamsValue = @{
                    DataType = '#microsoft.windowsDefenderATP.api.SnmpAuthParams'
                    Type     = 'NoAuthNoPriv'
                }
            }

            $results = @{
                Name                     = $instance.scanName
                Id                       = $instance.id
                IntervalInHours          = $instance.intervalInHours
                Target                   = $instance.Target
                IsActive                 = $instance.isActive
                ScanType                 = $instance.scanType
                ScannerAgent             = $ScannerAgentValue
                ScanAuthenticationParams = $ScanAuthenticationParamsValue
                Ensure                   = 'Present'
                Credential               = $this.Credential
                ApplicationId            = $this.ApplicationId
                TenantId                 = $this.TenantId
                CertificateThumbprint    = $this.CertificateThumbprint
                CertificatePath          = $this.CertificatePath
                CertificatePassword      = $this.CertificatePassword
                ManagedIdentity          = $this.ManagedIdentity
                AccessTokens             = $this.AccessTokens
            }
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

        Write-Verbose -Message "Setting configuration for Defender Device Authenticated Scan Definition with Name $($this.Name)"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $currentInstance = $this.Get().ToHashtable()

        $instanceParams = @{
            scanType                 = $this.ScanType
            scanName                 = $this.Name
            isActive                 = $this.IsActive
            target                   = $this.Target
            intervalInHours          = $this.IntervalInHours
            scannerAgent             = @{
                machineName = $this.ScannerAgent.machineName
                id          = $this.ScannerAgent.id
            }
            targetType               = 'Ip'
            scanAuthenticationParams = @{
                '@odata.type' = $this.ScanAuthenticationParams.DataType
                type          = $this.ScanAuthenticationParams.Type
            }
        }

        if ($null -ne $this.ScanAuthenticationParams.KeyVaultUrl)
        {
            $instanceParams.scanAuthenticationParams.Add('keyVaultUrl', $this.ScanAuthenticationParams.KeyVaultUrl)
        }
        if ($null -ne $this.ScanAuthenticationParams.KeyVaultSecretName)
        {
            $instanceParams.scanAuthenticationParams.Add('keyVaultSecretName', $this.ScanAuthenticationParams.KeyVaultSecretName)
        }
        if ($null -ne $this.ScanAuthenticationParams.Domain)
        {
            $instanceParams.scanAuthenticationParams.Add('domain', $this.ScanAuthenticationParams.Domain)
        }
        if ($null -ne $this.ScanAuthenticationParams.Username)
        {
            $instanceParams.scanAuthenticationParams.Add('username', $this.ScanAuthenticationParams.Username)
        }
        if ($null -ne $this.ScanAuthenticationParams.IsGMSAUser)
        {
            $instanceParams.scanAuthenticationParams.Add('isGMSAUser', $this.ScanAuthenticationParams.IsGMSAUser)
        }
        if ($null -ne $this.ScanAuthenticationParams.CommunityString)
        {
            $instanceParams.scanAuthenticationParams.Add('communityString', $this.ScanAuthenticationParams.CommunityString)
        }
        if ($null -ne $this.ScanAuthenticationParams.AuthProtocol)
        {
            $instanceParams.scanAuthenticationParams.Add('authProtocol', $this.ScanAuthenticationParams.AuthProtocol)
        }
        if ($null -ne $this.ScanAuthenticationParams.AuthPassword)
        {
            $instanceParams.scanAuthenticationParams.Add('authPassword', $this.ScanAuthenticationParams.AuthPassword)
        }
        if ($null -ne $this.ScanAuthenticationParams.PrivProtocol)
        {
            $instanceParams.scanAuthenticationParams.Add('privProtocol', $this.ScanAuthenticationParams.PrivProtocol)
        }
        if ($null -ne $this.ScanAuthenticationParams.PrivPassword)
        {
            $instanceParams.scanAuthenticationParams.Add('privPassword', $this.ScanAuthenticationParams.PrivPassword)
        }

        # CREATE
        if ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Creating new device authenticated scan definition {$($this.Name)} with payload:`r`n$(ConvertTo-Json $instanceParams -Depth 10)"
            $response = Invoke-M365DSCDefenderREST -Uri 'https://api.securitycenter.microsoft.com/api/DeviceAuthenticatedScanDefinitions' `
                -Method POST `
                -Body $instanceParams
            Write-Verbose -Message "Response:`r`n$($response.Content)"
        }
        # UPDATE
        elseif ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Updating device authenticated scan definition {$($this.Name)} with payload:`r`n$(ConvertTo-Json $instanceParams -Depth 10)"
            $response = Invoke-M365DSCDefenderREST -Uri "https://api.securitycenter.microsoft.com/api/DeviceAuthenticatedScanDefinitions/$($currentInstance.Id)" `
                -Method PATCH `
                -Body $instanceParams
            Write-Verbose -Message "Response:`r`n$($response.Content)"
        }
        # REMOVE
        elseif ($this.Ensure -eq 'Absent' -and $currentInstance.Ensure -eq 'Present')
        {
            $instanceParams = @{
                ScanDefinitionIds = @($currentInstance.Id)
            }
            Write-Verbose -Message "Deleting device authenticated scan definition {$($this.Name)} with payload:`r`n$(ConvertTo-Json $instanceParams -Depth 10)"
            $response = Invoke-M365DSCDefenderREST -Uri 'https://api.securitycenter.microsoft.com/api/DeviceAuthenticatedScanDefinitions/BatchDelete' `
                -Method POST `
                -Body $instanceParams
            Write-Verbose -Message "Response:`r`n$($response.Content)"
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

        $ConnectionMode = $this.Connect('DefenderForEndpoint')

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Export')

        try
        {
            [array] $this.ResourceCache['exportedInstances'] = (Invoke-M365DSCDefenderREST -Uri 'https://api.securitycenter.microsoft.com/api/DeviceAuthenticatedScanDefinitions' `
                    -Method GET).value

            $i = 1
            $dscContent = [System.Text.StringBuilder]::new()
            if ($this.ResourceCache['exportedInstances'].Length -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }
            foreach ($config in $this.ResourceCache['exportedInstances'])
            {
                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }

                $displayedKey = $config.scanName
                Write-M365DSCHost -Message "    |---[$i/$($this.ResourceCache['exportedInstances'].Count)] $displayedKey" -DeferWrite
                $params = @{
                    Name                  = $config.scanName
                    id                    = $config.id
                    Credential            = $this.Credential
                    ApplicationId         = $this.ApplicationId
                    TenantId              = $this.TenantId
                    CertificateThumbprint = $this.CertificateThumbprint
                    CertificatePath       = $this.CertificatePath
                    CertificatePassword   = $this.CertificatePassword
                    ManagedIdentity       = $this.ManagedIdentity
                    AccessTokens          = $this.AccessTokens
                }

                $this.ExportedInstance = $config
                $Results = $this.GetForExport($Params)

                if ($Results.ScannerAgent)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString -ComplexObject $Results.ScannerAgent -CIMInstanceName DefenderDeviceAuthenticatedScanDefinitionScanAgent
                    if ($complexTypeStringResult)
                    {
                        $Results.ScannerAgent = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('ScannerAgent') | Out-Null
                    }
                }

                if ($Results.ScanAuthenticationParams)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString -ComplexObject $Results.ScanAuthenticationParams -CIMInstanceName DefenderDeviceAuthenticatedScanDefinitionAuthenticationParams
                    if ($complexTypeStringResult)
                    {
                        $Results.ScanAuthenticationParams = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('ScanAuthenticationParams') | Out-Null
                    }
                }

                $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                    -ConnectionMode $ConnectionMode `
                    -ModulePath $this.GetModulePath() `
                    -Results $Results `
                    -Credential $this.Credential `
                    -NoEscape @('ScannerAgent', 'ScanAuthenticationParams')

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
        return @{
            ExcludedProperties = @('ScanAuthenticationParams')
        }
    }

    hidden [DefenderDeviceAuthenticatedScanDefinition] AsResult([System.Object] $Values)
    {
        if ($Values -is [DefenderDeviceAuthenticatedScanDefinition])
        {
            return $Values
        }

        $result = [DefenderDeviceAuthenticatedScanDefinition]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}

class MSFT_DefenderDeviceAuthenticatedScanDefinitionScanAgent
{
    [DscProperty()]
    [System.ComponentModel.Description('Unique identified for the scan agent.')]
    [System.String] $id

    [DscProperty()]
    [System.ComponentModel.Description('Id of the machine associated with the agent.')]
    [System.String] $machineId

    [DscProperty()]
    [System.ComponentModel.Description('Name of the machine associated with the agent.')]
    [System.String] $machineName
}

class MSFT_DefenderDeviceAuthenticatedScanDefinitionAuthenticationParams
{
    [DscProperty()]
    [System.ComponentModel.Description('Odata type associated with the request.')]
    [System.String] $DataType

    [DscProperty()]
    [System.ComponentModel.Description('Type of scan.')]
    [System.String] $Type

    [DscProperty()]
    [System.ComponentModel.Description('An optional property that specifies from which KeyVault the scanner should retrieve credentials. If KeyVault is specified there''s no need to specify username, password.')]
    [System.String] $KeyVaultUrl

    [DscProperty()]
    [System.ComponentModel.Description('An optional property that specifies KeyVault secret name from which the scanner should retrieve credentials. If KeyVault is specified there''s no need to specify username, password.')]
    [System.String] $KeyVaultSecretName

    [DscProperty()]
    [System.ComponentModel.Description('Domain name when using WindowsAuthParams.')]
    [System.String] $Domain

    [DscProperty()]
    [System.ComponentModel.Description('Username when using WindowsAuthParams or the username when choosing SnmpAuthParams with any type other than CommunityString.')]
    [System.String] $Username

    [DscProperty()]
    [System.ComponentModel.Description('Must be set to true when choosing WindowsAuthParams.')]
    [System.Nullable[System.Boolean]] $IsGMSAUser

    [DscProperty()]
    [System.ComponentModel.Description('Community string to use when choosing SnmpAuthParams with CommunityString.')]
    [System.String] $CommunityString

    [DscProperty()]
    [System.ComponentModel.Description('Auth protocol to use with SnmpAuthParams and AuthNoPriv or AuthPriv. Possible values are MD5, SHA1.')]
    [System.String] $AuthProtocol

    [DscProperty()]
    [System.ComponentModel.Description('Auth password to use with SnmpAuthParams and AuthNoPriv or AuthPriv.')]
    [System.String] $AuthPassword

    [DscProperty()]
    [System.ComponentModel.Description('Priv protocol to use with SnmpAuthParams and AuthPriv. Possible values are DES, 3DES, AES.')]
    [System.String] $PrivProtocol

    [DscProperty()]
    [System.ComponentModel.Description('Priv password to use with SnmpAuthParams and AuthPriv.')]
    [System.String] $PrivPassword
}
