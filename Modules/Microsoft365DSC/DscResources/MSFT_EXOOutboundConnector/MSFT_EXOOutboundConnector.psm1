using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class EXOOutboundConnector : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The Identity parameter specifies the outbound connector that you want to modify.')]
    [System.String] $Identity

    [DscProperty()]
    [System.ComponentModel.Description('Specifies whether connector is enabled.')]
    [System.Nullable[System.Boolean]] $Enabled

    [DscProperty()]
    [System.ComponentModel.Description('Specifies whether connector should use MXRecords for target resolution.')]
    [System.Nullable[System.Boolean]] $UseMXRecord

    [DscProperty()]
    [System.ComponentModel.Description('The Comment parameter specifies an optional comment.')]
    [System.String] $Comment

    [DscProperty()]
    [System.ComponentModel.Description('The ConnectorSource parameter specifies how the connector is created. DO NOT CHANGE THIS!')]
    [ValidateSet('Default', 'Migrated', 'HybridWizard')]
    [System.String] $ConnectorSource

    [DscProperty()]
    [System.ComponentModel.Description('The ConnectorType parameter specifies a category for the domains that are serviced by the connector.')]
    [ValidateSet('Partner', 'OnPremises')]
    [System.String] $ConnectorType

    [DscProperty()]
    [System.ComponentModel.Description('The RecipientDomains parameter specifies the domain that the Outbound connector routes mail to. You can specify multiple domains separated by commas.')]
    [System.String[]] $RecipientDomains

    [DscProperty()]
    [System.ComponentModel.Description('The SmartHosts parameter specifies the smart hosts the Outbound connector uses to route mail. This parameter is required if you set the UseMxRecord parameter to $false and must be specified on the same command line.')]
    [System.String[]] $SmartHosts

    [DscProperty()]
    [System.ComponentModel.Description('The TlsDomain parameter specifies the domain name that the Outbound connector uses to verify the FQDN of the target certificate when establishing a TLS secured connection. This parameter is only used if the TlsSettings parameter is set to DomainValidation. Valid input for the TlsDomain parameter is an SMTP domain. You can use a wildcard character to specify all subdomains of a specified domain, as shown in the following example: *.contoso.com. However, you can''t embed a wildcard character, as shown in the following example: domain.*.contoso.com')]
    [System.String] $TlsDomain

    [DscProperty()]
    [System.ComponentModel.Description('The TlsSettings parameter specifies the TLS authentication level that''s used for outbound TLS connections established by this Outbound connector.')]
    [ValidateSet('EncryptionOnly', 'CertificateValidation', 'DomainValidation')]
    [System.String] $TlsSettings

    [DscProperty()]
    [System.ComponentModel.Description('The IsTransportRuleScoped parameter specifies whether the Outbound connector is associated with a transport rule (also known as a mail flow rule).')]
    [System.Nullable[System.Boolean]] $IsTransportRuleScoped

    [DscProperty()]
    [System.ComponentModel.Description('The RouteAllMessagesViaOnPremises parameter specifies that all messages serviced by this connector are first routed through the on-premises messaging system (Centralized mailrouting).')]
    [System.Nullable[System.Boolean]] $RouteAllMessagesViaOnPremises

    [DscProperty()]
    [System.ComponentModel.Description('The CloudServicesMailEnabled parameter specifies whether the connector is used for hybrid mail flow between an on-premises Exchange environment and Microsoft Office 365. Specifically, this parameter controls how certain internal X-MS-Exchange-Organization-* message headers are handled in messages that are sent between accepted domains in the on-premises and cloud organizations. These headers are collectively known as cross-premises headers. DO NOT USE MANUALLY!')]
    [System.Nullable[System.Boolean]] $CloudServicesMailEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The AllAcceptedDomains parameter specifies whether the Outbound connector is used in hybrid organizations where message recipients are in accepted domains of the cloud-based organization.')]
    [System.Nullable[System.Boolean]] $AllAcceptedDomains

    [DscProperty()]
    [System.ComponentModel.Description('The SenderRewritingEnabled parameter specifies that all messages that normally qualify for SRS rewriting are rewritten for routing through the on-premises email system.')]
    [System.Nullable[System.Boolean]] $SenderRewritingEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The TestMode parameter specifies whether you want to enabled or disable test mode for the Outbound connector.')]
    [System.Nullable[System.Boolean]] $TestMode

    [DscProperty()]
    [System.ComponentModel.Description('The ValidationRecipients parameter specifies the email addresses of the validation recipients for the Outbound connector. You can specify multiple email addresses separated by commas.')]
    [System.String[]] $ValidationRecipients

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

    [EXOOutboundConnector] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [EXOOutboundConnector]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of OutBoundConnector for $($this.Identity)"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.Identity -ne $this.Identity)
            {
                $null = $this.Connect('ExchangeOnline')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullReturn = $this.GetBoundParameters()
                $nullReturn.Ensure = 'Absent'

                $OutBoundConnector = Get-OutBoundConnector -Identity $this.Identity -IncludeTestModeConnectors:$true -ErrorAction SilentlyContinue
                if ($null -eq $OutBoundConnector)
                {
                    Write-Verbose -Message "OutBoundConnector $($this.Identity) does not exist."
                    return $this.AsResult($nullReturn)
                }
            }
            else
            {
                $OutBoundConnector = $this.ExportedInstance
            }

            Write-Verbose -Message "OutBoundConnector with Identity $($OutBoundConnector.Identity) found"

            $ConnectorSourceValue = $OutBoundConnector.ConnectorSource
            if ($ConnectorSourceValue -eq 'AdminUI' -or `
                    [System.String]::IsNullOrEmpty($ConnectorSourceValue))
            {
                $ConnectorSourceValue = 'Default'
            }

            $result = @{
                Identity                      = $this.Identity
                AllAcceptedDomains            = $OutBoundConnector.AllAcceptedDomains
                CloudServicesMailEnabled      = $OutBoundConnector.CloudServicesMailEnabled
                Comment                       = $OutBoundConnector.Comment
                ConnectorSource               = $ConnectorSourceValue
                ConnectorType                 = $OutBoundConnector.ConnectorType
                Enabled                       = $OutBoundConnector.Enabled
                IsTransportRuleScoped         = $OutBoundConnector.IsTransportRuleScoped
                RecipientDomains              = $OutBoundConnector.RecipientDomains
                RouteAllMessagesViaOnPremises = $OutBoundConnector.RouteAllMessagesViaOnPremises
                SenderRewritingEnabled        = $OutBoundConnector.SenderRewritingEnabled
                SmartHosts                    = $OutBoundConnector.SmartHosts
                TestMode                      = $OutBoundConnector.TestMode
                TlsDomain                     = $OutBoundConnector.TlsDomain
                TlsSettings                   = $OutBoundConnector.TlsSettings
                UseMxRecord                   = $OutBoundConnector.UseMxRecord
                ValidationRecipients          = $OutBoundConnector.ValidationRecipients
                Credential                    = $this.Credential
                Ensure                        = 'Present'
                ApplicationId                 = $this.ApplicationId
                CertificateThumbprint         = $this.CertificateThumbprint
                CertificatePath               = $this.CertificatePath
                CertificatePassword           = $this.CertificatePassword
                ManagedIdentity               = $this.ManagedIdentity
                TenantId                      = $this.TenantId
                AccessTokens                  = $this.AccessTokens
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

        Write-Verbose -Message "Setting configuration of OutBoundConnector for $($this.Identity)"

        $null = $this.Connect('ExchangeOnline')

        $OutBoundConnectors = Get-OutBoundConnector
        $OutBoundConnector = $OutBoundConnectors | Where-Object -FilterScript { $_.Identity -eq $this.Identity }
        $OutBoundConnectorParams = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()

        if ($this.Ensure -eq 'Present' -and $null -eq $OutBoundConnector)
        {
            Write-Verbose -Message "Creating OutBoundConnector $($this.Identity)."
            $OutBoundConnectorParams.Add('Name', $this.Identity)
            $OutBoundConnectorParams.Remove('Identity') | Out-Null
            $OutBoundConnectorParams.Remove('ValidationRecipients') | Out-Null
            New-OutBoundConnector @OutBoundConnectorParams

            if ($null -ne $this.ValidationRecipients)
            {
                Write-Verbose -Message 'Updating ValidationRecipients'
                Set-OutboundConnector -Identity $this.Identity -ValidationRecipients $this.ValidationRecipients -Confirm:$false
            }
        }
        elseif ($this.Ensure -eq 'Present' -and $null -ne $OutBoundConnector)
        {
            Write-Verbose -Message "Setting OutBoundConnector $($this.Identity) with values: $(Convert-M365DscHashtableToString -Hashtable $OutBoundConnectorParams)"
            Set-OutBoundConnector @OutBoundConnectorParams -Confirm:$false
        }
        elseif ($this.Ensure -eq 'Absent' -and $null -ne $OutBoundConnector)
        {
            Write-Verbose -Message "Removing OutBoundConnector $($this.Identity)"
            Remove-OutBoundConnector -Identity $this.Identity -Confirm:$false
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
            [array]$OutboundConnectors = Get-OutboundConnector -IncludeTestModeConnectors:$true -ErrorAction Stop
            if ($OutBoundConnectors.Length -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }
            $dscContent = [System.Text.StringBuilder]::new()
            $i = 1
            foreach ($OutboundConnector in $OutboundConnectors)
            {
                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }

                Write-M365DSCHost -Message "    |---[$i/$($OutboundConnectors.Length)] $($OutboundConnector.Identity)" -DeferWrite

                $Params = @{
                    Identity              = $OutboundConnector.Identity
                    Credential            = $this.Credential
                    ApplicationId         = $this.ApplicationId
                    TenantId              = $this.TenantId
                    CertificateThumbprint = $this.CertificateThumbprint
                    CertificatePassword   = $this.CertificatePassword
                    ManagedIdentity       = $this.ManagedIdentity
                    CertificatePath       = $this.CertificatePath
                    AccessTokens          = $this.AccessTokens
                }
                $this.ExportedInstance = $OutboundConnector
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

    hidden [EXOOutboundConnector] AsResult([System.Object] $Values)
    {
        if ($Values -is [EXOOutboundConnector])
        {
            return $Values
        }

        $result = [EXOOutboundConnector]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
