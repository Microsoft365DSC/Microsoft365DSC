using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class AADCertificateBasedApplicationConfiguration : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('Display name for the configuration.')]
    [System.String] $DisplayName

    [DscProperty()]
    [System.ComponentModel.Description('The unique identifier for the configuration.')]
    [System.String] $Id

    [DscProperty()]
    [System.ComponentModel.Description('Description for the configuration.')]
    [System.String] $Description

    [DscProperty()]
    [System.ComponentModel.Description('Collection of trusted certificate authorities.')]
    [MSFT_AADCertificateBasedApplicationConfigurationTrustedCertificateAuthority[]] $TrustedCertificateAuthorities

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

    [AADCertificateBasedApplicationConfiguration] Get()
    {
        $instance = $null
        if ($this.RequiresPowerShellCore())
        {
            $remote = [AADCertificateBasedApplicationConfiguration]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of Certificate-Based Application Configuration '$($this.DisplayName)'"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.DisplayName -ne $this.DisplayName)
            {
                $null = $this.Connect('MicrosoftGraph')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullResult = $this.GetBoundParameters()
                $nullResult.Ensure = 'Absent'

                if (-not [System.String]::IsNullOrEmpty($this.Id))
                {
                    $instance = Get-MgBetaDirectoryCertificateAuthorityCertificateBasedApplicationConfiguration `
                        -CertificateBasedApplicationConfigurationId $this.Id `
                        -ErrorAction SilentlyContinue
                }

                if ($null -eq $instance)
                {
                    Write-Verbose -Message "Could not find an AAD Certificate Based Application Configuration with Id {$($this.Id)}"
                    $instance = Get-MgBetaDirectoryCertificateAuthorityCertificateBasedApplicationConfiguration -All `
                        -Filter "displayName eq '$($this.DisplayName)'" `
                        -ErrorAction SilentlyContinue
                }

                if ($null -eq $instance)
                {
                    Write-Verbose -Message "Could not find an AAD Certificate Based Application Configuration with DisplayName {$($this.DisplayName)}"
                    return $this.AsResult($nullResult)
                }
            }
            else
            {
                $instance = $this.ExportedInstance
            }

            # Get trusted certificate authorities using the dedicated cmdlet
            $trustedCAs = @()
            try
            {
                Write-Verbose -Message "GET: Fetching trusted certificate authorities for $($instance.Id)"
                $certificateAuthorities = Get-MgBetaDirectoryCertificateAuthorityCertificateBasedApplicationConfigurationTrustedCertificateAuthority `
                    -CertificateBasedApplicationConfigurationId $instance.Id `
                    -ErrorAction SilentlyContinue

                foreach ($ca in $certificateAuthorities)
                {
                    $certificateValue = $this.ConvertToBase64CertificateValue($ca.Certificate)
                    $trustedCAs += @{
                        Certificate                 = $certificateValue
                        IsRootAuthority             = [System.Boolean]$ca.IsRootAuthority
                    }
                }
            }
            catch
            {
                Write-Verbose -Message "Could not retrieve certificate authorities: $_"
                throw
            }

            $results = @{
                DisplayName                   = $instance.DisplayName
                Id                            = $instance.Id
                Description                   = $instance.Description
                TrustedCertificateAuthorities = $trustedCAs
                Ensure                        = 'Present'
                Credential                    = $this.Credential
                ApplicationId                 = $this.ApplicationId
                TenantId                      = $this.TenantId
                CertificateThumbprint         = $this.CertificateThumbprint
                CertificatePath               = $this.CertificatePath
                CertificatePassword           = $this.CertificatePassword
                ManagedIdentity               = $this.ManagedIdentity
                AccessTokens                  = $this.AccessTokens
            }
            Write-Verbose -Message "GET: Returning results => $($results | ConvertTo-Json -Depth 6)"
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

        Write-Verbose -Message "Setting configuration of Certificate-Based Application Configuration '$($this.DisplayName)'"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')
        Write-Verbose -Message "SET: Resolving current instance state"
        $currentInstance = $this.Get().ToHashtable()
        Write-Verbose -Message "SET: Current instance Ensure = $($currentInstance.Ensure)"

        # CREATE
        if ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Creating new Certificate-Based Application Configuration: $($this.DisplayName)"

            $params = @{
                displayName = $this.DisplayName
            }

            if (-not [System.String]::IsNullOrEmpty($this.Description))
            {
                $params.description = $this.Description
            }

            try
            {
                if ($null -ne $this.TrustedCertificateAuthorities)
                {
                    $params.trustedCertificateAuthorities = @()
                    foreach ($ca in $this.TrustedCertificateAuthorities)
                    {
                        $normalizedCertificate = $this.ConvertToBase64CertificateValue($ca.Certificate)
                        $caParams = @{
                            certificate     = $normalizedCertificate
                            isRootAuthority = $ca.IsRootAuthority
                        }

                        if (-not [System.String]::IsNullOrEmpty($ca.Issuer))
                        {
                            $caParams.issuer = $ca.Issuer
                        }

                        if (-not [System.String]::IsNullOrEmpty($ca.IssuerSubjectKeyIdentifier))
                        {
                            $caParams.issuerSubjectKeyIdentifier = $ca.IssuerSubjectKeyIdentifier
                        }

                        $params.trustedCertificateAuthorities += $caParams
                    }
                }
                $newConfig = New-MgBetaDirectoryCertificateAuthorityCertificateBasedApplicationConfiguration -BodyParameter $params
            }
            catch
            {
                Write-Verbose -Message "Error creating certificate configuration: $_"
                throw
            }
        }
        # UPDATE
        elseif ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Updating Certificate-Based Application Configuration: $($this.DisplayName)"

            $updateParams = @{
                DisplayName = $this.DisplayName
            }

            if (-not [System.String]::IsNullOrEmpty($this.Description))
            {
                $updateParams.Description = $this.Description
            }

            try
            {
                Update-MgBetaDirectoryCertificateAuthorityCertificateBasedApplicationConfiguration `
                    -CertificateBasedApplicationConfigurationId $currentInstance.Id `
                    -BodyParameter $updateParams

                # Compare and update trusted certificate authorities
                # Note: For simplicity, we'll check if the count differs or if any certificate data changed
                $updateCAs = $false

                if ($null -eq $this.TrustedCertificateAuthorities -and $null -ne $currentInstance.TrustedCertificateAuthorities)
                {
                    $updateCAs = $true
                }
                elseif ($null -ne $this.TrustedCertificateAuthorities -and $null -eq $currentInstance.TrustedCertificateAuthorities)
                {
                    $updateCAs = $true
                }
                elseif ($null -ne $this.TrustedCertificateAuthorities -and $null -ne $currentInstance.TrustedCertificateAuthorities)
                {
                    if ($this.TrustedCertificateAuthorities.Count -ne $currentInstance.TrustedCertificateAuthorities.Count)
                    {
                        $updateCAs = $true
                    }
                    else
                    {
                        # Check if any certificate differs
                        for ($i = 0; $i -lt $this.TrustedCertificateAuthorities.Count; $i++)
                        {
                            $desiredCertificate = $this.ConvertToBase64CertificateValue($this.TrustedCertificateAuthorities[$i].Certificate)
                            $currentCertificate = $this.ConvertToBase64CertificateValue($currentInstance.TrustedCertificateAuthorities[$i].Certificate)
                            if ($desiredCertificate -ne $currentCertificate -or
                                $this.TrustedCertificateAuthorities[$i].IsRootAuthority -ne $currentInstance.TrustedCertificateAuthorities[$i].IsRootAuthority)
                            {
                                $updateCAs = $true
                                break
                            }
                        }
                    }
                }

                if ($updateCAs)
                {
                    Write-Verbose -Message "Certificate authorities need to be updated"

                    # Get current certificate authorities to compare
                    $currentCAs = @()
                    try
                    {
                        $currentCertAuthorities = Get-MgBetaDirectoryCertificateAuthorityCertificateBasedApplicationConfigurationTrustedCertificateAuthority `
                            -CertificateBasedApplicationConfigurationId $currentInstance.Id `
                            -ErrorAction SilentlyContinue

                        if ($null -ne $currentCertAuthorities)
                        {
                            $currentCAs = $currentCertAuthorities
                        }
                    }
                    catch
                    {
                        Write-Verbose -Message "Could not retrieve current certificate authorities: $_"
                    }

                    # Remove certificate authorities that are no longer needed
                    foreach ($currentCA in $currentCAs)
                    {
                        $found = $false
                        $currentCertificate = $this.ConvertToBase64CertificateValue($currentCA.Certificate)

                        if ($null -ne $this.TrustedCertificateAuthorities)
                        {
                            foreach ($desiredCA in $this.TrustedCertificateAuthorities)
                            {
                                $desiredCertificate = $this.ConvertToBase64CertificateValue($desiredCA.Certificate)

                                if ($currentCertificate -eq $desiredCertificate)
                                {
                                    $found = $true
                                    break
                                }
                            }
                        }

                        if (-not $found)
                        {
                            Write-Verbose -Message "Removing certificate authority: $($currentCA.Issuer)"
                            try
                            {
                                Remove-MgBetaDirectoryCertificateAuthorityCertificateBasedApplicationConfigurationTrustedCertificateAuthority `
                                    -CertificateBasedApplicationConfigurationId $currentInstance.Id `
                                    -CertificateAuthorityAsEntityId $currentCA.Id `
                                    -ErrorAction Stop
                            }
                            catch
                            {
                                Write-Verbose -Message "Error removing certificate authority: $_"
                            }
                        }
                    }

                    # Add or update certificate authorities
                    if ($null -ne $this.TrustedCertificateAuthorities)
                    {
                        foreach ($desiredCA in $this.TrustedCertificateAuthorities)
                        {
                            $existingCA = $null
                            $desiredCertificate = $this.ConvertToBase64CertificateValue($desiredCA.Certificate)

                            foreach ($currentCA in $currentCAs)
                            {

                                $currentCertificate = $this.ConvertToBase64CertificateValue($currentCA.Certificate)
                                if ($currentCertificate -eq $desiredCertificate)
                                {
                                    $existingCA = $currentCA
                                    break
                                }
                            }

                            if ($null -eq $existingCA)
                            {
                                # Add new certificate authority
                                Write-Verbose -Message "Adding certificate authority: $($desiredCA.Issuer)"
                                $caParams = @{
                                    Certificate     = $desiredCertificate
                                    IsRootAuthority = $desiredCA.IsRootAuthority
                                }

                                try
                                {
                                    New-MgBetaDirectoryCertificateAuthorityCertificateBasedApplicationConfigurationTrustedCertificateAuthority `
                                        -CertificateBasedApplicationConfigurationId $currentInstance.Id `
                                        -BodyParameter $caParams
                                }
                                catch
                                {
                                    Write-Verbose -Message "Error adding certificate authority: $_"
                                }
                            }
                            else
                            {
                                # Update existing certificate authority if needed
                                $needsUpdate = $false
                                if ($existingCA.IsRootAuthority -ne $desiredCA.IsRootAuthority)
                                {
                                    $needsUpdate = $true
                                }

                                if ($needsUpdate)
                                {
                                    Write-Verbose -Message "Updating certificate authority: $($desiredCA.Issuer)"
                                    $updateCAParams = @{
                                        Certificate     = $desiredCertificate
                                        IsRootAuthority = $desiredCA.IsRootAuthority
                                    }

                                    try
                                    {
                                        Update-MgBetaDirectoryCertificateAuthorityCertificateBasedApplicationConfigurationTrustedCertificateAuthority `
                                            -CertificateBasedApplicationConfigurationId $currentInstance.Id `
                                            -CertificateAuthorityAsEntityId $existingCA.Id `
                                            -BodyParameter $updateCAParams
                                    }
                                    catch
                                    {
                                        Write-Verbose -Message "Error updating certificate authority: $_"
                                    }
                                }
                            }
                        }
                    }
                }
            }
            catch
            {
                Write-Verbose -Message "Error updating certificate configuration: $_"
                throw
            }
        }
        # REMOVE
        elseif ($this.Ensure -eq 'Absent' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Removing Certificate-Based Application Configuration: $($this.DisplayName)"

            try
            {
                Remove-MgBetaDirectoryCertificateAuthorityCertificateBasedApplicationConfiguration `
                    -CertificateBasedApplicationConfigurationId $currentInstance.Id
            }
            catch
            {
                Write-Verbose -Message "Error removing certificate configuration: $_"
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
            [array] $exportedInstances = Get-MgBetaDirectoryCertificateAuthorityCertificateBasedApplicationConfiguration -All -ErrorAction Stop

            $i = 1
            $dscContent = [System.Text.StringBuilder]::new()

            if ($exportedInstances.Count -eq 0)
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

                $displayedKey = $config.DisplayName
                Write-M365DSCHost -Message "    |---[$i/$($exportedInstances.Count)] $displayedKey" -DeferWrite

                $params = @{
                    DisplayName           = $config.DisplayName
                    Id                    = $config.Id
                    Description           = $config.Description
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

                if ($null -ne $Results.TrustedCertificateAuthorities -and $Results.TrustedCertificateAuthorities.Count -gt 0)
                {
                    $complexMapping = @(
                        @{
                            Name            = 'TrustedCertificateAuthorities'
                            CimInstanceName = 'AADCertificateBasedApplicationConfigurationTrustedCertificateAuthority'
                            IsRequired      = $False
                        }
                    )

                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.TrustedCertificateAuthorities `
                        -CIMInstanceName 'AADCertificateBasedApplicationConfigurationTrustedCertificateAuthority' `
                        -ComplexTypeMapping $complexMapping

                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.TrustedCertificateAuthorities = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('TrustedCertificateAuthorities') | Out-Null
                    }
                }
                else
                {
                    $Results.Remove('TrustedCertificateAuthorities') | Out-Null
                }

                $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                    -ConnectionMode $ConnectionMode `
                    -ModulePath $this.GetModulePath() `
                    -Results $Results `
                    -Credential $this.Credential `
                    -NoEscape @('TrustedCertificateAuthorities')

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

    # Returns [System.Object] rather than [System.String] on purpose: the trailing branch hands back
    # $CertificateValue unchanged, which may be $null, and a [System.String]-typed method would
    # convert that $null to an empty string.
    hidden [System.Object] ConvertToBase64CertificateValue([System.Object] $CertificateValue)
    {
        if ($CertificateValue -is [System.Security.Cryptography.X509Certificates.X509Certificate2])
        {
            return [System.Convert]::ToBase64String($CertificateValue.RawData)
        }
        elseif ($CertificateValue -is [System.Byte[]])
        {
            return [System.Convert]::ToBase64String($CertificateValue)
        }
        elseif ($null -ne $CertificateValue -and -not ($CertificateValue -is [System.String]))
        {
            return $CertificateValue.ToString()
        }

        return $CertificateValue
    }

    hidden [AADCertificateBasedApplicationConfiguration] AsResult([System.Object] $Values)
    {
        if ($Values -is [AADCertificateBasedApplicationConfiguration])
        {
            return $Values
        }

        $result = [AADCertificateBasedApplicationConfiguration]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}

class MSFT_AADCertificateBasedApplicationConfigurationTrustedCertificateAuthority
{
    [DscProperty()]
    [System.ComponentModel.Description('The certificate data in base64 encoded format.')]
    [System.String] $Certificate

    [DscProperty()]
    [System.ComponentModel.Description('Indicates if the certificate is a root authority.')]
    [System.Nullable[System.Boolean]] $IsRootAuthority

    [DscProperty()]
    [System.ComponentModel.Description('The issuer of the certificate.')]
    [System.String] $Issuer

    [DscProperty()]
    [System.ComponentModel.Description('The subject key identifier of the issuer.')]
    [System.String] $IssuerSubjectKeyIdentifier
}
