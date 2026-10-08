using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class EXOInboundConnector : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The Identity parameter specifies the outbound connector that you want to modify.')]
    [System.String] $Identity

    [DscProperty()]
    [System.ComponentModel.Description('The AssociatedAcceptedDomains parameter specifies the accepted domains that the connector applies to, thereby limiting its scope. For example, you can apply the connector to a specific accepted domain in your organization, such as contoso.com.')]
    [System.String[]] $AssociatedAcceptedDomains

    [DscProperty()]
    [System.ComponentModel.Description('The CloudServicesMailEnabled parameter specifies whether the connector is used for hybrid mail flow between an on-premises Exchange environment and Microsoft Office 365. Specifically, this parameter controls how certain internal X-MS-Exchange-Organization-* message headers are handled in messages that are sent between accepted domains in the on-premises and cloud organizations. These headers are collectively known as cross-premises headers. DO NOT USE MANUALLY!')]
    [System.Nullable[System.Boolean]] $CloudServicesMailEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The Comment parameter specifies an optional comment.')]
    [System.String] $Comment

    [DscProperty()]
    [System.ComponentModel.Description('The ConnectorSource parameter specifies how the connector is created. DO NOT CHANGE THIS!')]
    [ValidateSet('Default', 'Migrated', 'HybridWizard')]
    [System.String] $ConnectorSource

    [DscProperty()]
    [System.ComponentModel.Description('The ConnectorType parameter specifies a category for the domains that are serviced by the connector. Valid values are Partner and OnPremises')]
    [ValidateSet('Partner', 'OnPremises')]
    [System.String] $ConnectorType

    [DscProperty()]
    [System.ComponentModel.Description('The EFSkipIPs parameter specifies the source IP addresses to skip in Enhanced Filtering for Connectors when the EFSkipLastIP parameter value is $false.')]
    [System.String[]] $EFSkipIPs

    [DscProperty()]
    [System.ComponentModel.Description('The EFSkipLastIP parameter specifies the behavior of Enhanced Filtering for Connectors.')]
    [System.Nullable[System.Boolean]] $EFSkipLastIP

    [DscProperty()]
    [System.ComponentModel.Description('The EFUsers parameter specifies the recipients that Enhanced Filtering for Connectors applies to.')]
    [System.String[]] $EFUsers

    [DscProperty()]
    [System.ComponentModel.Description('Specifies whether connector is enabled.')]
    [System.Nullable[System.Boolean]] $Enabled

    [DscProperty()]
    [System.ComponentModel.Description('The RequireTLS parameter specifies that all messages received by this connector require TLS transmission. Valid values for this parameter are $true or $false. The default value is $false. When the RequireTLS parameter is set to $true, all messages received by this connector require TLS transmission.')]
    [System.Nullable[System.Boolean]] $RequireTls

    [DscProperty()]
    [System.ComponentModel.Description('The RestrictDomainsToCertificate parameter specifies that Office 365 should identify incoming messages that are eligible for this connector by verifying that the remote server authenticates using a TLS certificate that has the TlsSenderCertificateName in the Subject.')]
    [System.Nullable[System.Boolean]] $RestrictDomainsToCertificate

    [DscProperty()]
    [System.ComponentModel.Description('The RestrictDomainsToIPAddresses parameter, when set to $true, automatically rejects mail from the domains specified by the SenderDomains parameter if the mail originates from an IP address that isn''t specified by the SenderIPAddresses parameter.')]
    [System.Nullable[System.Boolean]] $RestrictDomainsToIPAddresses

    [DscProperty()]
    [System.ComponentModel.Description('The SenderDomains parameter specifies the remote domains from which this connector accepts messages, thereby limiting its scope. You can use a wildcard character to specify all subdomains of a specified domain, as shown in the following example: *.contoso.com. However, you can''t embed a wildcard character, as shown in the following example: domain.*.contoso.com.')]
    [System.String[]] $SenderDomains

    [DscProperty()]
    [System.ComponentModel.Description('The SenderIPAddresses parameter specifies the remote IP addresses from which this connector accepts messages.')]
    [System.String[]] $SenderIPAddresses

    [DscProperty()]
    [System.ComponentModel.Description('The TlsSenderCertificateName parameter specifies the certificate used by the sender''s domain when the RequireTls parameter is set to $true. Valid input for the TlsSenderCertificateName parameter is an SMTP domain. ')]
    [System.String] $TlsSenderCertificateName

    [DscProperty()]
    [System.ComponentModel.Description('The TreatMessagesAsInternal parameter specifies an alternative method to identify messages sent from an on-premises organization as internal messages. You should only consider using this parameter when your on-premises organization doesn''t use Exchange.')]
    [System.Nullable[System.Boolean]] $TreatMessagesAsInternal

    [DscProperty()]
    [System.ComponentModel.Description('Specifies if this Outbound connector should exist.')]
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

    [EXOInboundConnector] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [EXOInboundConnector]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of InboundConnector for $($this.Identity)"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.Identity -ne $this.Identity)
            {
                $null = $this.Connect('ExchangeOnline')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullReturn = $this.GetBoundParameters()
                $nullReturn.Ensure = 'Absent'

                $InboundConnector = Get-InboundConnector -Identity $this.Identity -ErrorAction SilentlyContinue
                if ($null -eq $InboundConnector)
                {
                    Write-Verbose -Message "InboundConnector $($this.Identity) does not exist."
                    return $this.AsResult($nullReturn)
                }
            }
            else
            {
                $InboundConnector = $this.ExportedInstance
            }

            Write-Verbose -Message "Found InboundConnector $($this.Identity)"

            $ConnectorSourceValue = $InboundConnector.ConnectorSource
            if ($ConnectorSourceValue -eq 'AdminUI')
            {
                $ConnectorSourceValue = 'Default'
            }

            $result = @{
                Identity                     = $this.Identity
                AssociatedAcceptedDomains    = $InboundConnector.AssociatedAcceptedDomains
                CloudServicesMailEnabled     = $InboundConnector.CloudServicesMailEnabled
                Comment                      = $InboundConnector.Comment
                ConnectorSource              = $ConnectorSourceValue
                ConnectorType                = $InboundConnector.ConnectorType
                EFSkipIPs                    = $InboundConnector.EFSkipIPs
                EFSkipLastIP                 = $InboundConnector.EFSkipLastIP
                EFUsers                      = $InboundConnector.EFUsers
                Enabled                      = $InboundConnector.Enabled
                RequireTls                   = $InboundConnector.RequireTls
                RestrictDomainsToCertificate = $InboundConnector.RestrictDomainsToCertificate
                RestrictDomainsToIPAddresses = $InboundConnector.RestrictDomainsToIPAddresses
                SenderDomains                = $InboundConnector.SenderDomains
                SenderIPAddresses            = $InboundConnector.SenderIPAddresses
                TlsSenderCertificateName     = $InboundConnector.TlsSenderCertificateName
                TreatMessagesAsInternal      = $InboundConnector.TreatMessagesAsInternal
                Credential                   = $this.Credential
                Ensure                       = 'Present'
                ApplicationId                = $this.ApplicationId
                CertificateThumbprint        = $this.CertificateThumbprint
                CertificatePath              = $this.CertificatePath
                CertificatePassword          = $this.CertificatePassword
                ManagedIdentity              = $this.ManagedIdentity
                TenantId                     = $this.TenantId
                AccessTokens                 = $this.AccessTokens
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

        Write-Verbose -Message "Setting configuration of InboundConnector for $($this.Identity)"

        $null = $this.Connect('ExchangeOnline')

        $InboundConnectors = Get-InboundConnector
        $InboundConnector = $InboundConnectors | Where-Object -FilterScript { $_.Identity -eq $this.Identity }
        $InboundConnectorParams = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()

        if ($this.Ensure -eq 'Present' -and $null -eq $InboundConnector)
        {
            Write-Verbose -Message "Creating InboundConnector $($this.Identity)."
            $InboundConnectorParams.Add('Name', $this.Identity)
            $InboundConnectorParams.Remove('Identity') | Out-Null
            New-InboundConnector @InboundConnectorParams
        }
        elseif ($this.Ensure -eq 'Present' -and $null -ne $InboundConnector)
        {
            Write-Verbose -Message "Setting InboundConnector $($this.Identity) with values: $(Convert-M365DscHashtableToString -Hashtable $InboundConnectorParams)"
            Set-InboundConnector @InboundConnectorParams -Confirm:$false
        }
        elseif ($this.Ensure -eq 'Absent' -and $null -ne $InboundConnector)
        {
            Write-Verbose -Message "Removing InboundConnector $($this.Identity)"
            Remove-InboundConnector -Identity $this.Identity -Confirm:$false
        }
    }

    [bool] Test()
    {
        return ([M365DSCResourceBase] $this).Test()
    }

    [System.Collections.Hashtable] GetCompareParameters()
    {
        return @{
            PostProcessing = {
                param($DesiredValues, $CurrentValues, $ValuesToCheck, $ignore)
                if ($DesiredValues.ContainsKey('SenderDomains'))
                {
                    $newSenderDomains = @()
                    foreach ($domain in $DesiredValues.SenderDomains)
                    {
                        if ($domain -notlike 'smtp:*')
                        {
                            $newSenderDomains += 'smtp:' + $domain + ';1'
                        }
                        else
                        {
                            $newSenderDomains += $domain
                        }
                    }
                    $DesiredValues.SenderDomains = [Array] $newSenderDomains
                    $ValuesToCheck.SenderDomains = [Array] $newSenderDomains
                }
                return [System.Tuple[Hashtable, Hashtable, Hashtable]]::new($DesiredValues, $CurrentValues, $ValuesToCheck)
            }
        }
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
            [array]$InboundConnectors = Get-InboundConnector -ErrorAction Stop
            $dscContent = [System.Text.StringBuilder]::new()

            if ($InboundConnectors.Length -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }
            $i = 1
            foreach ($InboundConnector in $InboundConnectors)
            {
                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }

                Write-M365DSCHost -Message "    |---[$i/$($InboundConnectors.Length)] $($InboundConnector.Identity)" -DeferWrite

                $Params = @{
                    Identity              = $InboundConnector.Identity
                    Credential            = $this.Credential
                    ApplicationId         = $this.ApplicationId
                    TenantId              = $this.TenantId
                    CertificateThumbprint = $this.CertificateThumbprint
                    CertificatePassword   = $this.CertificatePassword
                    ManagedIdentity       = $this.ManagedIdentity
                    CertificatePath       = $this.CertificatePath
                    AccessTokens          = $this.AccessTokens
                }
                $this.ExportedInstance = $InboundConnector
                $Results = $this.GetForExport($Params)
                $rawResults = $Results.Clone()
                $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                    -ConnectionMode $ConnectionMode `
                    -ModulePath $this.GetModulePath() `
                    -Results $Results `
                    -Credential $this.Credential `
                    -RawResults $rawResults
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

    hidden [EXOInboundConnector] AsResult([System.Object] $Values)
    {
        if ($Values -is [EXOInboundConnector])
        {
            return $Values
        }

        $result = [EXOInboundConnector]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
