using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class AADFederationConfiguration : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The display name of the SAML/WS-Fed based identity provider. Inherited from identityProviderBase.')]
    [System.String] $DisplayName

    [DscProperty()]
    [System.ComponentModel.Description('Unique fientifier')]
    [System.String] $Id

    [DscProperty()]
    [System.ComponentModel.Description('Issuer URI of the federation server. Inherited from samlOrWsFedProvider.')]
    [System.String] $IssuerUri

    [DscProperty()]
    [System.ComponentModel.Description('URI of the metadata exchange endpoint used for authentication from rich client applications. Inherited from samlOrWsFedProvider.')]
    [System.String] $MetadataExchangeUri

    [DscProperty()]
    [System.ComponentModel.Description('URI that web-based clients are directed to when signing in to Microsoft Entra services. Inherited from samlOrWsFedProvider.')]
    [System.String] $PassiveSignInUri

    [DscProperty()]
    [System.ComponentModel.Description('Preferred authentication protocol. The possible values are: wsFed, saml. Inherited from samlOrWsFedProvider.')]
    [System.String] $PreferredAuthenticationProtocol

    [DscProperty()]
    [System.ComponentModel.Description('Current certificate used to sign tokens passed to the Microsoft identity platform. The certificate is formatted as a Base64 encoded string of the public portion of the federated IdP''s token signing certificate and must be compatible with the X509Certificate2 class.')]
    [System.String] $SigningCertificate

    [DscProperty()]
    [System.ComponentModel.Description('List of associated domains.')]
    [System.String[]] $Domains

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

    [AADFederationConfiguration] Get()
    {
        $nullResult = $null
        $instance = $null
        if ($this.RequiresPowerShellCore())
        {
            $remote = [AADFederationConfiguration]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration for the AAD Federation Configuration with Id {$($this.Id)} and DisplayName {$($this.DisplayName)}"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.Id -ne $this.Id)
            {
                $null = $this.Connect('MicrosoftGraph')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullResult = $this.GetBoundParameters()
                $nullResult.Ensure = 'Absent'

                $uri = '/beta/directory/federationConfigurations/microsoft.graph.samlOrWsFedExternalDomainFederation'
                $instances = Invoke-M365DSCGraphRequest -Uri $uri -Method Get -All
                if (-not [System.String]::IsNullOrEmpty($this.Id))
                {
                    $instance = $instances.value | Where-Object -FilterScript { $_.id -eq $this.Id }
                }
                if ($null -eq $instance)
                {
                    $instance = $instances.value | Where-Object -FilterScript { $_.displayName -eq $this.DisplayName }
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

            $results = @{
                Id                              = $instance.id
                DisplayName                     = $instance.displayName
                IssuerUri                       = $instance.issuerUri
                MetadataExchangeUri             = $instance.metadataExchangeUri
                PassiveSignInUri                = $instance.passiveSignInUri
                PreferredAuthenticationProtocol = $instance.preferredAuthenticationProtocol
                Domains                         = $instance.domains.id
                SigningCertificate              = $instance.signingCertificate
                Ensure                          = 'Present'
                Credential                      = $this.Credential
                ApplicationId                   = $this.ApplicationId
                TenantId                        = $this.TenantId
                ApplicationSecret               = $this.ApplicationSecret
                CertificateThumbprint           = $this.CertificateThumbprint
                CertificatePath                 = $this.CertificatePath
                CertificatePassword             = $this.CertificatePassword
                ManagedIdentity                 = $this.ManagedIdentity
                AccessTokens                    = $this.AccessTokens
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

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $currentInstance = $this.Get().ToHashtable()

        $instanceParams = @{
            '@odata.type'                   = 'microsoft.graph.samlOrWsFedExternalDomainFederation'
            displayName                     = $this.DisplayName
            metadataExchangeUri             = $this.MetadataExchangeUri
            issuerUri                       = $this.IssuerUri
            preferredAuthenticationProtocol = $this.PreferredAuthenticationProtocol
            passiveSignInUri                = $this.PassiveSignInUri
            signingCertificate              = $this.SigningCertificate
            domains                         = @()
        }
        foreach ($domain in $this.domains)
        {
            $instanceParams.domains += @{
                '@odata.type' = 'microsoft.graph.externalDomainName'
                id            = $domain
            }
        }

        if ([System.String]::IsNullOrEmpty($this.MetadataExchangeUri))
        {
            $instanceParams.Remove('metadataExchangeUri') | Out-Null
        }

        if ([System.String]::IsNullOrEmpty($this.SigningCertificate))
        {
            $instanceParams.Remove('signingCertificate') | Out-Null
        }

        # CREATE
        if ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
        {
            $uri = '/beta/directory/federationConfigurations/microsoft.graph.samlOrWsFedExternalDomainFederation'
            $body = ConvertTo-Json $instanceParams -Depth 10 -Compress
            Write-Verbose -Message "Creating federation configuration {$($this.DisplayName)} with:`r`n$body"
            Invoke-M365DSCGraphRequest -Uri $uri -Method POST -Body $body
        }
        # UPDATE
        elseif ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Present')
        {
            $instanceParams.Remove('domains') | Out-Null
            $uri = "/beta/directory/federationConfigurations/microsoft.graph.samlOrWsFedExternalDomainFederation/$($currentInstance.Id)"
            $body = ConvertTo-Json $instanceParams -Depth 10 -Compress
            Write-Verbose -Message "Updating federation configuration {$($this.DisplayName)} with:`r`n$body"
            Invoke-M365DSCGraphRequest -Uri $uri -Method PATCH -Body $body

            if ($null -ne $this.Domains)
            {
                $domainsUri = "/beta/directory/federationConfigurations/$($currentInstance.Id)/microsoft.graph.samlOrWsFedExternalDomainFederation/domains"
                foreach ($domain in $this.Domains | Where-Object -FilterScript { $_ -notin $currentInstance.Domains })
                {
                    Write-Verbose -Message "Adding domain {$domain} to federation configuration {$($this.DisplayName)}"
                    $domainBody = ConvertTo-Json @{ '@odata.type' = 'microsoft.graph.externalDomainName'; id = $domain } -Compress
                    Invoke-M365DSCGraphRequest -Uri $domainsUri -Method POST -Body $domainBody
                }
                foreach ($domain in $currentInstance.Domains | Where-Object -FilterScript { $_ -notin $this.Domains })
                {
                    Write-Verbose -Message "Removing domain {$domain} from federation configuration {$($this.DisplayName)}"
                    Invoke-M365DSCGraphRequest -Uri "$domainsUri/$domain" -Method DELETE
                }
            }
        }
        # REMOVE
        elseif ($this.Ensure -eq 'Absent' -and $currentInstance.Ensure -eq 'Present')
        {
            $uri = "/beta/directory/federationConfigurations/microsoft.graph.samlOrWsFedExternalDomainFederation/$($currentInstance.Id)"
            Write-Verbose -Message "Removing federation configuration {$($this.DisplayName)}"
            Invoke-M365DSCGraphRequest -Uri $uri -Method DELETE
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
            $uri = '/beta/directory/federationConfigurations/microsoft.graph.samlOrWsFedExternalDomainFederation'
            if (-not [System.String]::IsNullOrEmpty($this.Filter))
            {
                $uri += "?`$filter=$($this.Filter)"
            }
            [array] $exportedInstances = Invoke-M365DSCGraphRequest -Uri $uri -Method Get -All

            $i = 1
            $dscContent = [System.Text.StringBuilder]::new()
            if ($exportedInstances.Length -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }
            foreach ($config in $exportedInstances.value)
            {
                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }

                $displayedKey = $config.displayName
                Write-M365DSCHost -Message "    |---[$i/$($exportedInstances.Count)] $displayedKey" -DeferWrite
                $params = @{
                    DisplayName           = $config.displayName
                    Id                    = $config.Id
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

                $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                    -ConnectionMode $ConnectionMode `
                    -ModulePath $this.GetModulePath() `
                    -Results $Results `
                    -Credential $this.Credential
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

    hidden [AADFederationConfiguration] AsResult([System.Object] $Values)
    {
        if ($Values -is [AADFederationConfiguration])
        {
            return $Values
        }

        $result = [AADFederationConfiguration]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
