using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class EXOOnPremisesOrganization : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The Identity parameter specifies the identity of the on-premises organization object.')]
    [System.String] $Identity

    [DscProperty()]
    [System.ComponentModel.Description('The HybridDomains parameter specifies the domains that are configured in the hybrid deployment between an Office 365 tenant and an on-premises Exchange organization. The domains specified in this parameter must match the domains listed in the HybridConfiguration Active Directory object for the on-premises Exchange organization configured by the Hybrid Configuration wizard. ')]
    [System.String[]] $HybridDomains

    [DscProperty()]
    [System.ComponentModel.Description('The InboundConnector parameter specifies the name of the inbound connector configured on the Microsoft Exchange Online Protection (EOP) service for a hybrid deployment configured with an on-premises Exchange organization.')]
    [System.String] $InboundConnector

    [DscProperty()]
    [System.ComponentModel.Description('The OutboundConnector parameter specifies the name of the outbound connector configured on the EOP service for a hybrid deployment configured with an on-premises Exchange organization.')]
    [System.String] $OutboundConnector

    [DscProperty()]
    [System.ComponentModel.Description('The OrganizationName parameter specifies the Active Directory object name of the on-premises Exchange organization.')]
    [System.String] $OrganizationName

    [DscProperty()]
    [System.ComponentModel.Description('The OrganizationGuid parameter specifies the globally unique identifier (GUID) of the on-premises Exchange organization object in the Office 365 tenant.')]
    [System.String] $OrganizationGuid

    [DscProperty()]
    [System.ComponentModel.Description('The OrganizationRelationship parameter specifies the organization relationship configured by the Hybrid Configuration wizard on the Office 365 tenant as part of a hybrid deployment with an on-premises Exchange organization. This organization relationship defines the federated sharing features enabled on the Office 365 tenant.')]
    [System.String] $OrganizationRelationship

    [DscProperty()]
    [System.ComponentModel.Description('The Comment parameter specifies an optional comment.')]
    [System.String] $Comment

    [DscProperty()]
    [System.ComponentModel.Description('Specify if the On-Premises Organization should exist or not.')]
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

    [EXOOnPremisesOrganization] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [EXOOnPremisesOrganization]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting On-premises Organization configuration for $($this.Identity)"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.Identity -ne $this.Identity)
            {
                $null = $this.Connect('ExchangeOnline')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullReturn = $this.GetBoundParameters()
                $nullReturn.Ensure = 'Absent'

                $OnPremisesOrganization = Get-OnPremisesOrganization -Identity $this.Identity -ErrorAction SilentlyContinue
                if ($null -eq $OnPremisesOrganization)
                {
                    Write-Verbose -Message "On-premises Organization $($this.Identity) does not exist."
                    return $this.AsResult($nullReturn)
                }
            }
            else
            {
                $OnPremisesOrganization = $this.ExportedInstance
            }

            Write-Verbose -Message "On-premises Organization with Identity $($OnPremisesOrganization.Identity) found"

            $result = @{
                Identity                 = $OnPremisesOrganization.Identity
                Comment                  = $OnPremisesOrganization.Comment
                HybridDomains            = $OnPremisesOrganization.HybridDomains
                InboundConnector         = $OnPremisesOrganization.InboundConnector
                OrganizationName         = $OnPremisesOrganization.OrganizationName
                OrganizationGuid         = $OnPremisesOrganization.OrganizationGuid
                OrganizationRelationship = $OnPremisesOrganization.OrganizationRelationship
                OutboundConnector        = $OnPremisesOrganization.OutboundConnector
                Ensure                   = 'Present'
                Credential               = $this.Credential
                ApplicationId            = $this.ApplicationId
                CertificateThumbprint    = $this.CertificateThumbprint
                CertificatePath          = $this.CertificatePath
                CertificatePassword      = $this.CertificatePassword
                ManagedIdentity          = $this.ManagedIdentity
                TenantId                 = $this.TenantId
                AccessTokens             = $this.AccessTokens
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

        Write-Verbose -Message "Setting On-premises Organization configuration for $($this.Identity)"

        $currentOnPremisesOrganizationConfig = $this.Get().ToHashtable()

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $null = $this.Connect('ExchangeOnline')

        $NewOnPremisesOrganizationParams = @{
            Name              = $this.Identity
            Comment           = $this.Comment
            HybridDomains     = $this.HybridDomains
            InboundConnector  = $this.InboundConnector
            OrganizationName  = $this.OrganizationName
            OrganizationGuid  = $this.OrganizationGuid
            OutboundConnector = $this.OutboundConnector
            Confirm           = $false
        }

        $SetOnPremisesOrganizationParams = @{
            Identity          = $this.Identity
            Comment           = $this.Comment
            HybridDomains     = $this.HybridDomains
            InboundConnector  = $this.InboundConnector
            OrganizationName  = $this.OrganizationName
            OutboundConnector = $this.OutboundConnector
            Confirm           = $false
        }

        if (-not [System.String]::IsNullOrEmpty($this.OrganizationRelationship))
        {
            $NewOnPremisesOrganizationParams.Add('OrganizationRelationship', $this.OrganizationRelationship)
            $SetOnPremisesOrganizationParams.Add('OrganizationRelationship', $this.OrganizationRelationship)
        }

        # CASE: On-premises Organization doesn't exist but should;
        if ($this.Ensure -eq 'Present' -and $currentOnPremisesOrganizationConfig.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "On-premises Organization '$($this.Identity)' does not exist but it should. Create and configure it."
            # Create On-premises Organization
            New-OnPremisesOrganization @NewOnPremisesOrganizationParams

        }
        # CASE: On-premises Organization exists but it shouldn't;
        elseif ($this.Ensure -eq 'Absent' -and $currentOnPremisesOrganizationConfig.Ensure -eq 'Present')
        {
            Write-Verbose -Message "On-premises Organization '$($this.Identity)' exists but it shouldn't. Remove it."
            Remove-OnPremisesOrganization -Identity $this.Identity -Confirm:$false
        }
        # CASE: On-premises Organization exists and it should, but has different values than the desired ones
        elseif ($this.Ensure -eq 'Present' -and $currentOnPremisesOrganizationConfig.Ensure -eq 'Present')
        {
            Write-Verbose -Message "On-premises Organization '$($this.Identity)' already exists, but needs updating."
            Write-Verbose -Message "Setting On-premises Organization $($this.Identity) with values: $(Convert-M365DscHashtableToString -Hashtable $SetOnPremisesOrganizationParams)"
            Set-OnPremisesOrganization @SetOnPremisesOrganizationParams
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
            [array]$AllOnPremisesOrganizations = Get-OnPremisesOrganization -ErrorAction Stop

            $dscContent = [System.Text.StringBuilder]::new()

            if ($AllOnPremisesOrganizations.Length -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }
            $i = 1
            foreach ($OnPremisesOrganization in $AllOnPremisesOrganizations)
            {
                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }

                Write-M365DSCHost -Message "    |---[$i/$($AllOnPremisesOrganizations.Count)] $($OnPremisesOrganization.Identity)" -DeferWrite

                $Params = @{
                    Identity              = $OnPremisesOrganization.Identity
                    Credential            = $this.Credential
                    ApplicationId         = $this.ApplicationId
                    TenantId              = $this.TenantId
                    CertificateThumbprint = $this.CertificateThumbprint
                    CertificatePassword   = $this.CertificatePassword
                    ManagedIdentity       = $this.ManagedIdentity
                    CertificatePath       = $this.CertificatePath
                    AccessTokens          = $this.AccessTokens
                }
                $this.ExportedInstance = $OnPremisesOrganization
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

    hidden [EXOOnPremisesOrganization] AsResult([System.Object] $Values)
    {
        if ($Values -is [EXOOnPremisesOrganization])
        {
            return $Values
        }

        $result = [EXOOnPremisesOrganization]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
