using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class EXOIntraOrganizationConnector : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The Identity parameter specifies the intraorg connector that you want to modify.')]
    [System.String] $Identity

    [DscProperty()]
    [System.ComponentModel.Description('The DiscoveryEndpoint parameter specifies the externally-accessible URL that''s used for the Autodiscover service for the domain that''s configured in the Intra-Organization connector.')]
    [System.String] $DiscoveryEndpoint

    [DscProperty()]
    [System.ComponentModel.Description('Specifies whether connector is enabled.')]
    [System.Nullable[System.Boolean]] $Enabled

    [DscProperty()]
    [System.ComponentModel.Description('The TargetAddressDomains parameter specifies the domain namespaces that will be used in the Intra-organization connector. These domains must have valid Autodiscover endpoints defined in their organizations. The domains and their associated Autodiscover endpoints are used by the Intra-Organization connector for feature and service connectivity. You can specify multiple domains separated by commas.')]
    [System.String[]] $TargetAddressDomains

    [DscProperty()]
    [System.ComponentModel.Description('The TargetSharingEpr parameter specifies the URL of the target Exchange Web Services that will be used in the Intra-Organization connector.')]
    [System.String] $TargetSharingEpr

    [DscProperty()]
    [System.ComponentModel.Description('Specifies if this Intra-Organization connector should exist.')]
    [ValidateSet('Present', 'Absent')]
    [System.String] $Ensure

    [DscProperty()]
    [System.ComponentModel.Description('Credentials of the Exchange Global Admin')]
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

    [EXOIntraOrganizationConnector] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [EXOIntraOrganizationConnector]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of IntraOrganizationConnector for $($this.Identity)"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.Identity -ne $this.Identity)
            {
                $null = $this.Connect('ExchangeOnline')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullReturn = $this.GetBoundParameters()
                $nullReturn.Ensure = 'Absent'

                $IntraOrganizationConnector = Get-IntraOrganizationConnector -Identity $this.Identity -ErrorAction SilentlyContinue
                if ($null -eq $IntraOrganizationConnector)
                {
                    Write-Verbose -Message "IntraOrganizationConnector $($this.Identity) does not exist."
                    return $this.AsResult($nullReturn)
                }
            }
            else
            {
                $IntraOrganizationConnector = $this.ExportedInstance
            }

            Write-Verbose -Message "Found IntraOrganizationConnector $($this.Identity)"

            $DiscoveryEndpointValue = $null
            if ($null -ne $IntraOrganizationConnector.DiscoveryEndpoint)
            {
                $DiscoveryEndpointValue = $IntraOrganizationConnector.DiscoveryEndpoint.ToString()
                if (-not $DiscoveryEndpointValue.EndsWith('/'))
                {
                    $DiscoveryEndpointValue = $DiscoveryEndpointValue + '/'
                }
            }
            $TargetSharingEprValue = ''
            if ($null -ne $IntraOrganizationConnector.TargetSharingEpr)
            {
                $TargetSharingEprValue = $IntraOrganizationConnector.TargetSharingEpr.ToString()
            }
            $result = @{
                Identity              = $this.Identity
                DiscoveryEndpoint     = $DiscoveryEndpointValue
                Enabled               = $IntraOrganizationConnector.Enabled
                TargetAddressDomains  = $IntraOrganizationConnector.TargetAddressDomains
                TargetSharingEpr      = $TargetSharingEprValue
                Credential            = $this.Credential
                Ensure                = 'Present'
                ApplicationId         = $this.ApplicationId
                CertificateThumbprint = $this.CertificateThumbprint
                CertificatePath       = $this.CertificatePath
                CertificatePassword   = $this.CertificatePassword
                ManagedIdentity       = $this.ManagedIdentity
                TenantId              = $this.TenantId
                AccessTokens          = $this.AccessTokens
            }

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

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        Write-Verbose -Message "Setting configuration of IntraOrganizationConnector for $($this.Identity)"

        $null = $this.Connect('ExchangeOnline')

        $IntraOrganizationConnectors = Get-IntraOrganizationConnector
        $IntraOrganizationConnector = $IntraOrganizationConnectors | Where-Object -FilterScript { $_.Identity -eq $this.Identity }
        $IntraOrganizationConnectorParams = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()

        if ($IntraOrganizationConnectorParams.TargetSharingEpr -eq '')
        {
            $IntraOrganizationConnectorParams.TargetSharingEpr = $null
        }
        if ($this.Ensure -eq 'Present' -and $null -eq $IntraOrganizationConnector)
        {
            Write-Verbose -Message "Creating IntraOrganizationConnector $($this.Identity) with:`r`n $(ConvertTo-Json $IntraOrganizationConnectorParams -Depth 10)"
            $IntraOrganizationConnectorParams.Add('Name', $this.Identity)
            $IntraOrganizationConnectorParams.Remove('Identity') | Out-Null
            New-IntraOrganizationConnector @IntraOrganizationConnectorParams
        }
        elseif ($this.Ensure -eq 'Present' -and $null -ne $IntraOrganizationConnector)
        {
            Write-Verbose -Message "Setting IntraOrganizationConnector $($this.Identity) with values: $(Convert-M365DscHashtableToString -Hashtable $IntraOrganizationConnectorParams)"
            Set-IntraOrganizationConnector @IntraOrganizationConnectorParams -Confirm:$false
        }
        elseif ($this.Ensure -eq 'Absent' -and $null -ne $IntraOrganizationConnector)
        {
            Write-Verbose -Message "Removing IntraOrganizationConnector $($this.Identity)"
            Remove-IntraOrganizationConnector -Identity $this.Identity -Confirm:$false
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

        $ConnectionMode = $this.Connect('ExchangeOnline')

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Export')

        try
        {
            [array]$IntraOrganizationConnectors = Get-IntraOrganizationConnector -ErrorAction Stop
            $dscContent = [System.Text.StringBuilder]::new()

            if ($IntraOrganizationConnectors.Length -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }
            $i = 1
            foreach ($IntraOrganizationConnector in $IntraOrganizationConnectors)
            {
                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }

                Write-M365DSCHost -Message "    |---[$i/$($IntraOrganizationConnectors.Length)] $($IntraOrganizationConnector.Identity)" -DeferWrite

                $Params = @{
                    Identity              = $IntraOrganizationConnector.Identity
                    Credential            = $this.Credential
                    ApplicationId         = $this.ApplicationId
                    TenantId              = $this.TenantId
                    CertificateThumbprint = $this.CertificateThumbprint
                    CertificatePassword   = $this.CertificatePassword
                    ManagedIdentity       = $this.ManagedIdentity
                    CertificatePath       = $this.CertificatePath
                    AccessTokens          = $this.AccessTokens
                }
                $this.ExportedInstance = $IntraOrganizationConnector
                $Results = $this.GetForExport($Params)
                $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                    -ConnectionMode $ConnectionMode `
                    -ModulePath $this.GetModulePath() `
                    -Results $Results `
                    -Credential $this.Credential
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
            $this.LogError($_, 'Error during Export:')

            throw
        }
    }

    hidden [EXOIntraOrganizationConnector] AsResult([System.Object] $Values)
    {
        if ($Values -is [EXOIntraOrganizationConnector])
        {
            return $Values
        }

        $result = [EXOIntraOrganizationConnector]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
