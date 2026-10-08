using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class AADDomainFederation : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The domain ID for which the federation configuration is being managed.')]
    [System.String] $DomainId

    [DscProperty()]
    [System.ComponentModel.Description('The unique identifier of the federation configuration.')]
    [System.String] $Id

    [DscProperty()]
    [System.ComponentModel.Description('The display name of the federation configuration.')]
    [System.String] $DisplayName

    [DscProperty()]
    [System.ComponentModel.Description('Issuer URI of the federation server.')]
    [System.String] $IssuerUri

    [DscProperty()]
    [System.ComponentModel.Description('URI of the metadata exchange endpoint used for authentication.')]
    [System.String] $MetadataExchangeUri

    [DscProperty()]
    [System.ComponentModel.Description('Current certificate used to sign tokens passed to the Microsoft identity platform. The certificate is formatted as a Base64 encoded string of the public portion of the federated IdP''s token signing certificate.')]
    [System.String] $SigningCertificate

    [DscProperty()]
    [System.ComponentModel.Description('Next signing certificate that can be used to sign tokens passed to the Microsoft identity platform. The certificate is formatted as a Base64 encoded string of the public portion of the federated IdP''s token signing certificate.')]
    [System.String] $NextSigningCertificate

    [DscProperty()]
    [System.ComponentModel.Description('URI that web-based clients are directed to when signing in to Microsoft Entra services.')]
    [System.String] $PassiveSignInUri

    [DscProperty()]
    [System.ComponentModel.Description('URI that active clients are directed to when signing in to Microsoft Entra services.')]
    [System.String] $ActiveSignInUri

    [DscProperty()]
    [System.ComponentModel.Description('URI to which clients are redirected when signing out of Microsoft Entra services.')]
    [System.String] $SignOutUri

    [DscProperty()]
    [System.ComponentModel.Description('Preferred authentication protocol. Supported values are wsFed and saml.')]
    [System.String] $PreferredAuthenticationProtocol

    [DscProperty()]
    [System.ComponentModel.Description('Prompt login behavior of the federated IdP.')]
    [System.String] $PromptLoginBehavior

    [DscProperty()]
    [System.ComponentModel.Description('Determines whether Microsoft Entra ID accepts the MFA performed by the federated IdP. Supported values are acceptIfMfaDoneByFederatedIdp, enforceMfaByFederatedIdp, rejectMfaByFederatedIdp.')]
    [System.String] $FederatedIdpMfaBehavior

    [DscProperty()]
    [System.ComponentModel.Description('URI that clients are redirected to for resetting their password.')]
    [System.String] $PasswordResetUri

    [DscProperty()]
    [System.ComponentModel.Description('Specifies whether the federation requires signed authentication requests.')]
    [System.Nullable[System.Boolean]] $IsSignedAuthenticationRequestRequired

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
    [System.ComponentModel.Description('Secret of the Azure Active Directory application to authenticate with.')]
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

    [AADDomainFederation] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [AADDomainFederation]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of Azure AD Domain Federation for domain {$($this.DomainId)}"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.DomainId -ne $this.DomainId)
            {
                $null = $this.Connect('MicrosoftGraph')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullResult = $this.GetBoundParameters()
                $nullResult.Ensure = 'Absent'

                # Get domain to verify it exists
                $domain = Get-MgBetaDomain -DomainId $this.DomainId -ErrorAction SilentlyContinue
                if ($null -eq $domain)
                {
                    Write-Verbose -Message "Domain {$($this.DomainId)} not found"
                    return $this.AsResult($nullResult)
                }

                # Get federation configuration for the domain
                $instance = Get-MgBetaDomainFederationConfiguration -DomainId $this.DomainId -ErrorAction SilentlyContinue

                if ($null -eq $instance -or $instance.Count -eq 0)
                {
                    Write-Verbose -Message "No federation configuration found for domain {$($this.DomainId)}"
                    return $this.AsResult($nullResult)
                }

                # If multiple configurations exist, take the first one or match by Id if provided
                if ($instance -is [System.Array])
                {
                    if (-not [System.String]::IsNullOrEmpty($this.Id))
                    {
                        $instance = $instance | Where-Object -FilterScript { $_.Id -eq $this.Id }
                    }
                    else
                    {
                        $instance = $instance[0]
                    }
                }

                if ($null -eq $instance)
                {
                    Write-Verbose -Message "Federation configuration with Id {$($this.Id)} not found for domain {$($this.DomainId)}"
                    return $this.AsResult($nullResult)
                }
            }
            else
            {
                $instance = $this.ExportedInstance
            }

            $results = @{
                DomainId                                = $this.DomainId
                Id                                      = $instance.Id
                DisplayName                             = $instance.DisplayName
                IssuerUri                               = $instance.IssuerUri
                MetadataExchangeUri                     = $instance.MetadataExchangeUri
                SigningCertificate                      = $instance.SigningCertificate
                NextSigningCertificate                  = $instance.NextSigningCertificate
                PassiveSignInUri                        = $instance.PassiveSignInUri
                ActiveSignInUri                         = $instance.ActiveSignInUri
                SignOutUri                              = $instance.SignOutUri
                PreferredAuthenticationProtocol         = $instance.PreferredAuthenticationProtocol
                PromptLoginBehavior                     = $instance.PromptLoginBehavior
                FederatedIdpMfaBehavior                 = $instance.FederatedIdpMfaBehavior
                PasswordResetUri                        = $instance.PasswordResetUri
                IsSignedAuthenticationRequestRequired   = $instance.IsSignedAuthenticationRequestRequired
                Ensure                                  = 'Present'
                Credential                              = $this.Credential
                ApplicationId                           = $this.ApplicationId
                TenantId                                = $this.TenantId
                ApplicationSecret                       = $this.ApplicationSecret
                CertificateThumbprint                   = $this.CertificateThumbprint
                CertificatePath                         = $this.CertificatePath
                CertificatePassword                     = $this.CertificatePassword
                ManagedIdentity                         = $this.ManagedIdentity
                AccessTokens                            = $this.AccessTokens
            }

            return $this.AsResult($results)
        }
        catch
        {
            $this.LogError($_, "Error retrieving data:")

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

        Write-Verbose -Message "Setting configuration of Azure AD Domain Federation for domain {$($this.DomainId)}"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $currentInstance = $this.Get().ToHashtable()
        $setParameters = Remove-M365DSCAuthenticationParameter -BoundParameters ([Hashtable]$this.GetBoundParameters()).Clone()

        # Remove parameters that are not valid for the API calls
        $setParameters.Remove('DomainId') | Out-Null
        $setParameters.Remove('Ensure') | Out-Null
        $setParameters.Remove('Id') | Out-Null

        # CREATE
        if ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Creating federation configuration for domain {$($this.DomainId)}"

            try
            {
                # Get domain to verify authentication type
                $domain = Get-MgBetaDomain -DomainId $this.DomainId -ErrorAction Stop

                # Verify domain AuthenticationType is Managed before creating federation configuration
                if ($domain.AuthenticationType -ne 'Managed')
                {
                    $message = "Cannot create federation configuration. Domain '$($this.DomainId)' must have AuthenticationType 'Managed' but found '$($domain.AuthenticationType)'. " +
                               "Please ensure the domain is set to Managed authentication type before configuring federation."
                    Write-Verbose -Message $message
                    throw $message
                }

                Write-Verbose -Message "Creating federation configuration with parameters: $(Convert-M365DscHashtableToString -Hashtable $setParameters)"
                $null = New-MgBetaDomainFederationConfiguration -DomainId $this.DomainId -BodyParameter $setParameters
                Write-Verbose -Message "Successfully created federation configuration for domain {$($this.DomainId)}"
            }
            catch
            {
                $this.LogError($_, "Error creating federation configuration:")
                throw
            }
        }
        # UPDATE
        elseif ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Present')
        {
            $testResult = Test-M365DSCTargetResource -DesiredValues $this.GetBoundParameters() `
                                                     -ResourceName $this.GetResourceName() -CurrentValues $this.Get().ToHashtable()
            if (-not $testResult)
            {
                Write-Verbose -Message "Updating federation configuration for domain {$($this.DomainId)}"

                try
                {
                    Write-Verbose -Message "Updating federation configuration with parameters: $(Convert-M365DscHashtableToString -Hashtable $setParameters)"
                    Update-MgBetaDomainFederationConfiguration -DomainId $this.DomainId `
                        -InternalDomainFederationId $currentInstance.Id `
                        -BodyParameter $setParameters
                    Write-Verbose -Message "Successfully updated federation configuration for domain {$($this.DomainId)}"
                }
                catch
                {
                    $this.LogError($_, "Error updating federation configuration:")
                    throw
                }
            }
        }
        # REMOVE
        elseif ($this.Ensure -eq 'Absent' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Removing federation configuration for domain {$($this.DomainId)}"

            try
            {
                Remove-MgBetaDomainFederationConfiguration -DomainId $this.DomainId `
                    -InternalDomainFederationId $currentInstance.Id `
                    -ErrorAction Stop
                Write-Verbose -Message "Successfully removed federation configuration for domain {$($this.DomainId)}"
            }
            catch
            {
                $this.LogError($_, "Error removing federation configuration:")
                throw
            }
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
            [array] $domains = Get-MgBetaDomain -ErrorAction Stop |
                Where-Object { $_.AuthenticationType -eq 'Federated' }
            [array] $exportedInstances = @()

            # Get federation configurations for federated domains only
            foreach ($domain in $domains)
            {
                try
                {
                    $federationConfigs = Get-MgBetaDomainFederationConfiguration -DomainId $domain.Id -ErrorAction SilentlyContinue
                    if ($null -ne $federationConfigs)
                    {
                        if ($federationConfigs -is [System.Array])
                        {
                            $configsToExport = $federationConfigs
                        }
                        else
                        {
                            $configsToExport = @([PSCustomObject]$federationConfigs)
                        }

                        foreach ($config in $configsToExport)
                        {
                            $config | Add-Member -MemberType NoteProperty -Name 'DomainId' -Value $domain.Id -Force
                            $exportedInstances += $config
                        }
                    }
                }
                catch
                {
                    Write-Verbose -Message "No federation configuration found for domain $($domain.Id)"
                }
            }

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

            foreach ($config in $exportedInstances)
            {
                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }

                $displayedKey = "$($config.DomainId) - $($config.DisplayName)"
                Write-M365DSCHost -Message "    |---[$i/$($exportedInstances.Count)] $displayedKey" -DeferWrite
                $params = @{
                    DomainId              = $config.DomainId
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

    hidden [AADDomainFederation] AsResult([System.Object] $Values)
    {
        if ($Values -is [AADDomainFederation])
        {
            return $Values
        }

        $result = [AADDomainFederation]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
