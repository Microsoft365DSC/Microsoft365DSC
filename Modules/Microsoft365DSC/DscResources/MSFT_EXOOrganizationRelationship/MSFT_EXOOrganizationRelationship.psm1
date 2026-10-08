using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class EXOOrganizationRelationship : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The Name parameter specifies the unique name of the organization relationship. The maximum length is 64 characters.')]
    [ValidateLength(1, 64)]
    [System.String] $Name

    [DscProperty()]
    [System.ComponentModel.Description('The ArchiveAccessEnabled parameter specifies whether the organization relationship has been configured to provide remote archive access.')]
    [System.Nullable[System.Boolean]] $ArchiveAccessEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The DeliveryReportEnabled parameter specifies whether Delivery Reports should be shared over the organization relationship.')]
    [System.Nullable[System.Boolean]] $DeliveryReportEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The DomainNames parameter specifies the SMTP domains of the external organization. You can specify multiple domains separated by commas.')]
    [System.String[]] $DomainNames

    [DscProperty()]
    [System.ComponentModel.Description('The Enabled parameter specifies whether to enable the organization relationship.')]
    [System.Nullable[System.Boolean]] $Enabled

    [DscProperty()]
    [System.ComponentModel.Description('The FreeBusyAccessEnabled parameter specifies whether the organization relationship should be used to retrieve free/busy information from the external organization.')]
    [System.Nullable[System.Boolean]] $FreeBusyAccessEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The FreeBusyAccessLevel parameter specifies the maximum amount of detail returned to the requesting organization. Valid values are: None, AvailabilityOnly or LimitedDetails')]
    [ValidateSet('None', 'AvailabilityOnly', 'LimitedDetails')]
    [System.String] $FreeBusyAccessLevel

    [DscProperty()]
    [System.ComponentModel.Description('The FreeBusyAccessScope parameter specifies a mail-enabled security group in the internal organization that contains users whose free/busy information is accessible by an external organization. You can use any value that uniquely identifies the group.')]
    [System.String] $FreeBusyAccessScope

    [DscProperty()]
    [System.ComponentModel.Description('The MailboxMoveEnabled parameter specifies whether the organization relationship enables moving mailboxes to or from the external organization.')]
    [System.Nullable[System.Boolean]] $MailboxMoveEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The MailboxMoveCapability parameter is used in cross-tenant mailbox migrations.')]
    [ValidateSet('Inbound', 'Outbound', 'RemoteInbound', 'RemoteOutbound', 'None')]
    [System.String] $MailboxMoveCapability

    [DscProperty()]
    [System.ComponentModel.Description('The MailboxMovePublishedScopes parameter is used in cross-tenant mailbox migrations to specify the mail-enabled security groups whose members are allowed to migrate.')]
    [System.String[]] $MailboxMovePublishedScopes

    [DscProperty()]
    [System.ComponentModel.Description('The MailTipsAccessEnabled parameter specifies whether MailTips for users in this organization are returned over this organization relationship.')]
    [System.Nullable[System.Boolean]] $MailTipsAccessEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The MailTipsAccessLevel parameter specifies the level of MailTips data externally shared over this organization relationship. This parameter can have the following values: All, Limited, None')]
    [ValidateSet('None', 'All', 'Limited')]
    [System.String] $MailTipsAccessLevel

    [DscProperty()]
    [System.ComponentModel.Description('The MailTipsAccessScope parameter specifies a mail-enabled security group in the internal organization that contains users whose free/busy information is accessible by an external organization. You can use any value that uniquely identifies the group.')]
    [System.String] $MailTipsAccessScope

    [DscProperty()]
    [System.ComponentModel.Description('The OAuthApplicationId is used in cross-tenant mailbox migrations to specify the application ID of the mailbox migration app that you consented to.')]
    [System.String] $OauthApplicationId

    [DscProperty()]
    [System.ComponentModel.Description('The OrganizationContact parameter specifies the email address that can be used to contact the external organization (for example, administrator@fourthcoffee.com).')]
    [System.String] $OrganizationContact

    [DscProperty()]
    [System.ComponentModel.Description('The PhotosEnabled parameter specifies whether photos for users in the internal organization are returned over the organization relationship.')]
    [System.Nullable[System.Boolean]] $PhotosEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The TargetApplicationUri parameter specifies the target Uniform Resource Identifier (URI) of the external organization. The TargetApplicationUri parameter is specified by Exchange when requesting a delegated token to retrieve free and busy information, for example, mail.contoso.com.')]
    [System.String] $TargetApplicationUri

    [DscProperty()]
    [System.ComponentModel.Description('The TargetAutodiscoverEpr parameter specifies the Autodiscover URL of Exchange Web Services for the external organization. Exchange uses Autodiscover to automatically detect the correct Exchangeserver endpoint to use for external requests.')]
    [System.String] $TargetAutodiscoverEpr

    [DscProperty()]
    [System.ComponentModel.Description('The TargetOwaURL parameter specifies the Outlook on the web (formerly Outlook Web App) URL of the external organization that''s defined in the organization relationship. It is used for Outlook on the web redirection in a cross-premise Exchange scenario. Configuring this attribute enables users in the organization to use their current Outlook on the web URL to access Outlook on the web in the external organization.')]
    [System.String] $TargetOwaURL

    [DscProperty()]
    [System.ComponentModel.Description('The TargetSharingEpr parameter specifies the URL of the target Exchange Web Services for the external organization.')]
    [System.String] $TargetSharingEpr

    [DscProperty()]
    [System.ComponentModel.Description('Specify if the OrganizationRelationship should exist or not.')]
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

    [EXOOrganizationRelationship] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [EXOOrganizationRelationship]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting Organization Relationship configuration for $($this.Name)"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.Name -ne $this.Name)
            {
                $null = $this.Connect('ExchangeOnline')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullReturn = $this.GetBoundParameters()
                $nullReturn.Ensure = 'Absent'

                $OrganizationRelationship = Get-OrganizationRelationship -Identity $this.Name -ErrorAction SilentlyContinue
                if ($null -eq $OrganizationRelationship)
                {
                    Write-Verbose -Message "Organization Relationship configuration for $($this.Name) does not exist."
                    return $this.AsResult($nullReturn)
                }
            }
            else
            {
                $OrganizationRelationship = $this.ExportedInstance
            }

            Write-Verbose -Message "Organization Relationship with Name $($OrganizationRelationship.Name) found"

            $result = @{
                ArchiveAccessEnabled       = $OrganizationRelationship.ArchiveAccessEnabled
                DeliveryReportEnabled      = $OrganizationRelationship.DeliveryReportEnabled
                DomainNames                = $OrganizationRelationship.DomainNames
                Enabled                    = $OrganizationRelationship.Enabled
                FreeBusyAccessEnabled      = $OrganizationRelationship.FreeBusyAccessEnabled
                FreeBusyAccessLevel        = $OrganizationRelationship.FreeBusyAccessLevel
                FreeBusyAccessScope        = $OrganizationRelationship.FreeBusyAccessScope
                MailboxMoveEnabled         = $OrganizationRelationship.MailboxMoveEnabled
                MailboxMoveCapability      = $OrganizationRelationship.MailboxMoveCapability
                MailboxMovePublishedScopes = $OrganizationRelationship.MailboxMovePublishedScopes
                MailTipsAccessEnabled      = $OrganizationRelationship.MailTipsAccessEnabled
                MailTipsAccessLevel        = $OrganizationRelationship.MailTipsAccessLevel
                MailTipsAccessScope        = $OrganizationRelationship.MailTipsAccessScope
                Name                       = $OrganizationRelationship.Name
                OauthApplicationId         = $OrganizationRelationship.OauthApplicationId
                OrganizationContact        = $OrganizationRelationship.OrganizationContact
                PhotosEnabled              = $OrganizationRelationship.PhotosEnabled
                Ensure                     = 'Present'
                Credential                 = $this.Credential
                ApplicationId              = $this.ApplicationId
                CertificateThumbprint      = $this.CertificateThumbprint
                CertificatePath            = $this.CertificatePath
                CertificatePassword        = $this.CertificatePassword
                ManagedIdentity            = $this.ManagedIdentity
                TenantId                   = $this.TenantId
                AccessTokens               = $this.AccessTokens
            }

            if ($OrganizationRelationship.TargetApplicationUri)
            {
                $result.Add('TargetApplicationUri', $($OrganizationRelationship.TargetApplicationUri.ToString()))
            }
            else
            {
                $result.Add('TargetApplicationUri', '')
            }

            if ($OrganizationRelationship.TargetAutodiscoverEpr)
            {
                $result.Add('TargetAutodiscoverEpr', $($OrganizationRelationship.TargetAutodiscoverEpr.ToString()))
            }
            else
            {
                $result.Add('TargetAutodiscoverEpr', '')
            }

            if ($OrganizationRelationship.TargetSharingEpr)
            {
                $result.Add('TargetSharingEpr', $($OrganizationRelationship.TargetSharingEpr.ToString()))
            }
            else
            {
                $result.Add('TargetSharingEpr', '')
            }

            if ($OrganizationRelationship.TargetOwaURL)
            {
                $result.Add('TargetOwaURL', $($OrganizationRelationship.TargetOwaURL.ToString()))
            }
            else
            {
                $result.Add('TargetOwaURL', '')
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

        Write-Verbose -Message "Setting Organization Relationship configuration for $($this.Name)"

        $currentOrgRelationshipConfig = $this.Get().ToHashtable()

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $null = $this.Connect('ExchangeOnline')

        $NewOrganizationRelationshipParams = @{
            ArchiveAccessEnabled       = $this.ArchiveAccessEnabled
            DeliveryReportEnabled      = $this.DeliveryReportEnabled
            DomainNames                = $this.DomainNames
            Enabled                    = $this.Enabled
            FreeBusyAccessEnabled      = $this.FreeBusyAccessEnabled
            FreeBusyAccessLevel        = $this.FreeBusyAccessLevel
            FreeBusyAccessScope        = $this.FreeBusyAccessScope
            MailboxMoveEnabled         = $this.MailboxMoveEnabled
            MailboxMoveCapability      = $this.MailboxMoveCapability
            MailboxMovePublishedScopes = $this.MailboxMovePublishedScopes
            MailTipsAccessEnabled      = $this.MailTipsAccessEnabled
            MailTipsAccessLevel        = $this.MailTipsAccessLevel
            MailTipsAccessScope        = $this.MailTipsAccessScope
            Name                       = $this.Name
            OauthApplicationId         = $this.OauthApplicationId
            OrganizationContact        = $this.OrganizationContact
            PhotosEnabled              = $this.PhotosEnabled
            TargetApplicationUri       = $this.TargetApplicationUri
            TargetAutodiscoverEpr      = $this.TargetAutodiscoverEpr
            TargetOwaURL               = $this.TargetOwaURL
            TargetSharingEpr           = $this.TargetSharingEpr
            Confirm                    = $false
        }
        # Removes empty properties from Splat to prevent function throwing errors if parameter is null or empty
        Remove-NullEntriesFromHashtable -Hash $NewOrganizationRelationshipParams

        $SetOrganizationRelationshipParams = @{
            ArchiveAccessEnabled       = $this.ArchiveAccessEnabled
            DeliveryReportEnabled      = $this.DeliveryReportEnabled
            DomainNames                = $this.DomainNames
            Enabled                    = $this.Enabled
            FreeBusyAccessEnabled      = $this.FreeBusyAccessEnabled
            FreeBusyAccessLevel        = $this.FreeBusyAccessLevel
            FreeBusyAccessScope        = $this.FreeBusyAccessScope
            MailboxMoveEnabled         = $this.MailboxMoveEnabled
            MailboxMoveCapability      = $this.MailboxMoveCapability
            MailboxMovePublishedScopes = $this.MailboxMovePublishedScopes
            MailTipsAccessEnabled      = $this.MailTipsAccessEnabled
            MailTipsAccessLevel        = $this.MailTipsAccessLevel
            MailTipsAccessScope        = $this.MailTipsAccessScope
            Identity                   = $this.Name
            OauthApplicationId         = $this.OauthApplicationId
            OrganizationContact        = $this.OrganizationContact
            PhotosEnabled              = $this.PhotosEnabled
            TargetApplicationUri       = $this.TargetApplicationUri
            TargetAutodiscoverEpr      = $this.TargetAutodiscoverEpr
            TargetOwaURL               = $this.TargetOwaURL
            TargetSharingEpr           = $this.TargetSharingEpr
            Confirm                    = $false
        }
        # Removes empty properties from Splat to prevent function throwing errors if parameter is null or empty
        Remove-NullEntriesFromHashtable -Hash $SetOrganizationRelationshipParams

        # CASE: Organization Relationship doesn't exist but should;
        if ($this.Ensure -eq 'Present' -and $currentOrgRelationshipConfig.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Organization Relationship '$($this.Name)' does not exist but it should. Create and configure it."
            # Create Organization Relationship
            New-OrganizationRelationship @NewOrganizationRelationshipParams
        }
        # CASE: Organization Relationship exists but it shouldn't;
        elseif ($this.Ensure -eq 'Absent' -and $currentOrgRelationshipConfig.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Organization Relationship '$($this.Name)' exists but it shouldn't. Remove it."
            Remove-OrganizationRelationship -Identity $this.Name -Confirm:$false
        }
        # CASE: Organization Relationship exists and it should, but has different values than the desired ones
        elseif ($this.Ensure -eq 'Present' -and $currentOrgRelationshipConfig.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Organization Relationship '$($this.Name)' already exists, but needs updating."
            Write-Verbose -Message "Setting Organization Relationship  $($this.Name) with values: $(Convert-M365DscHashtableToString -Hashtable $SetOrganizationRelationshipParams)"
            Set-OrganizationRelationship @SetOrganizationRelationshipParams
        }
    }

    [bool] Test()
    {
        return ([M365DSCResourceBase] $this).Test()
    }

    [string] Export()
    {
        $AllOrganizationRelationships = $null
        if ($this.RequiresPowerShellCore())
        {
            return [string] $this.InvokeInPowerShellCore('Export')
        }

        $ConnectionMode = $this.Connect('ExchangeOnline')

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Export')

        try
        {
            [array]$AllOrgRelationships = Get-OrganizationRelationship -ErrorAction Stop
            $dscContent = [System.Text.StringBuilder]::new()

            if ($AllOrganizationRelationships.Length -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }
            $i = 1
            foreach ($relationship in $AllOrgRelationships)
            {
                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }

                Write-M365DSCHost -Message "    |---[$i/$($AllOrgRelationships.Length)] $($relationship.Name)" -DeferWrite

                $Params = @{
                    Name                  = $relationship.Name
                    Credential            = $this.Credential
                    ApplicationId         = $this.ApplicationId
                    TenantId              = $this.TenantId
                    CertificateThumbprint = $this.CertificateThumbprint
                    CertificatePassword   = $this.CertificatePassword
                    ManagedIdentity       = $this.ManagedIdentity
                    CertificatePath       = $this.CertificatePath
                    AccessTokens          = $this.AccessTokens
                }
                $this.ExportedInstance = $relationship
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

    hidden [EXOOrganizationRelationship] AsResult([System.Object] $Values)
    {
        if ($Values -is [EXOOrganizationRelationship])
        {
            return $Values
        }

        $result = [EXOOrganizationRelationship]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
