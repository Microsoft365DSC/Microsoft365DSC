using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class AADOrganizationCertificateBasedAuthConfiguration : M365DSCResourceBase
{
    [DscProperty()]
    [System.ComponentModel.Description('Collection of certificate authorities which creates a trusted certificate chain.')]
    [MSFT_MicrosoftGraphcertificateAuthority[]] $CertificateAuthorities

    [DscProperty(Key)]
    [System.ComponentModel.Description('The Organization ID, or a verified domain name of the organization.')]
    [System.String] $OrganizationId

    [DscProperty()]
    [System.ComponentModel.Description('Present ensures the policy exists, absent ensures it is removed.')]
    [ValidateSet('Present', 'Absent')]
    [System.String] $Ensure

    [DscProperty()]
    [System.ComponentModel.Description('Credentials of the Admin')]
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

    [AADOrganizationCertificateBasedAuthConfiguration] Get()
    {
        $Id = $null
        if ($this.RequiresPowerShellCore())
        {
            $remote = [AADOrganizationCertificateBasedAuthConfiguration]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration for the Azure AD Organization Certificate Based Auth Configuration for OrganizationId {$($this.OrganizationId)}"

        try
        {
            $null = $this.Connect('MicrosoftGraph')

            #Ensure the proper dependencies are installed in the current environment.
            Confirm-M365DSCDependencies

            #region Telemetry
            $this.AddTelemetry('Get')
            #endregion

            $nullResult = $this.GetBoundParameters()
            $nullResult.Ensure = 'Absent'

            $getValue = $null
            #region resource generator code

            # This GUID is ALWAYS fixed as per the documentation.
            $CertificateBasedAuthConfigurationId = '29728ade-6ae4-4ee9-9103-412912537da5'
            $getValue = Get-MgBetaOrganizationCertificateBasedAuthConfiguration `
                -CertificateBasedAuthConfigurationId $CertificateBasedAuthConfigurationId `
                -OrganizationId $this.GetOrganizationId() -ErrorAction SilentlyContinue

            #endregion
            if ($null -eq $getValue)
            {
                Write-Verbose -Message "Could not find an Azure AD Organization Certificate Based Auth Configuration with Id {$Id}."
                return $this.AsResult($nullResult)
            }

            $Id = $getValue.Id
            Write-Verbose -Message "An Azure AD Organization Certificate Based Auth Configuration with Id {$Id} was found"

            #region resource generator code
            $complexCertificateAuthorities = @()
            foreach ($currentCertificateAuthorities in $getValue.certificateAuthorities)
            {
                $myCertificateAuthorities = [ordered]@{}
                $myCertificateAuthorities.Add('Certificate', $currentCertificateAuthorities.certificate)
                $myCertificateAuthorities.Add('CertificateRevocationListUrl', $currentCertificateAuthorities.certificateRevocationListUrl)
                $myCertificateAuthorities.Add('DeltaCertificateRevocationListUrl', $currentCertificateAuthorities.deltaCertificateRevocationListUrl)
                $myCertificateAuthorities.Add('IsRootAuthority', $currentCertificateAuthorities.isRootAuthority)
                if ($myCertificateAuthorities.values.Where({ $null -ne $_ }).Count -gt 0)
                {
                    $complexCertificateAuthorities += $myCertificateAuthorities
                }
            }
            #endregion

            $results = @{
                #region resource generator code
                CertificateAuthorities = $complexCertificateAuthorities
                OrganizationId         = $this.OrganizationId
                Ensure                 = 'Present'
                Credential             = $this.Credential
                ApplicationId          = $this.ApplicationId
                TenantId               = $this.TenantId
                ApplicationSecret      = $this.ApplicationSecret
                CertificateThumbprint  = $this.CertificateThumbprint
                CertificatePath        = $this.CertificatePath
                CertificatePassword    = $this.CertificatePassword
                ManagedIdentity        = $this.ManagedIdentity
                #endregion
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
        $boundParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()
        $organizationIdValue = $this.GetOrganizationId()

        # This GUID is ALWAYS fixed as per the documentation.
        $CertificateBasedAuthConfigurationId = '29728ade-6ae4-4ee9-9103-412912537da5'

        if ($currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message 'Removing the current Azure AD Organization Certificate Based Auth Configuration.'
            Remove-MgBetaOrganizationCertificateBasedAuthConfiguration -OrganizationId $organizationIdValue `
                -CertificateBasedAuthConfigurationId $CertificateBasedAuthConfigurationId
        }

        if ($this.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Creating an Azure AD Organization Certificate Based Auth Configuration with Id {$CertificateBasedAuthConfigurationId}"

            $createParameters = Rename-M365DSCCimInstanceParameter -Properties $boundParameters
            $createParameters.Remove('OrganizationId') | Out-Null

            $createCertAuthorities = @()
            foreach ($CertificateAuthority in $this.CertificateAuthorities)
            {
                $createCertAuthorities += @{
                    certificate                       = $CertificateAuthority.Certificate
                    certificateRevocationListUrl      = $CertificateAuthority.CertificateRevocationListUrl
                    deltaCertificateRevocationListUrl = $CertificateAuthority.DeltaCertificateRevocationListUrl
                    isRootAuthority                   = $CertificateAuthority.IsRootAuthority
                }
            }
            $params = @{
                certificateAuthorities = $createCertAuthorities
            }

            Write-Verbose -Message "Creating with Parameters:`r`n$(ConvertTo-Json $params -Depth 10)"
            New-MgBetaOrganizationCertificateBasedAuthConfiguration -OrganizationId $organizationIdValue `
                -BodyParameter $params
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
            [array]$getValue = Get-MgBetaOrganization

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
                $displayedKey = "CertificateBasedAuthConfigurations for $($getValue.DisplayName)"
                Write-M365DSCHost -Message "    |---[$i/$($getValue.Count)] $displayedKey" -DeferWrite
                $params = @{
                    Ensure                = 'Present'
                    OrganizationId        = $getValue.Id
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

                $Results = $this.GetForExport($Params)
                if ($null -ne $Results.CertificateAuthorities)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.CertificateAuthorities `
                        -CIMInstanceName 'MicrosoftGraphcertificateAuthority'
                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.CertificateAuthorities = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('CertificateAuthorities') | Out-Null
                    }
                }

                $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                    -ConnectionMode $ConnectionMode `
                    -ModulePath $this.GetModulePath() `
                    -Results $Results `
                    -Credential $this.Credential `
                    -NoEscape @('CertificateAuthorities')

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

    hidden [System.String] GetOrganizationId()
    {
        $parsedId = [System.Guid]::Empty
        if ([System.Guid]::TryParse($this.OrganizationId, [ref] $parsedId))
        {
            return $this.OrganizationId
        }

        $organization = Get-MgBetaOrganization -ErrorAction Stop | Select-Object -First 1
        if ($organization.VerifiedDomains.Name -notcontains $this.OrganizationId)
        {
            throw "OrganizationId {$($this.OrganizationId)} is neither a GUID nor a verified domain of the organization."
        }

        return $organization.Id
    }

    hidden [AADOrganizationCertificateBasedAuthConfiguration] AsResult([System.Object] $Values)
    {
        if ($Values -is [AADOrganizationCertificateBasedAuthConfiguration])
        {
            return $Values
        }

        $result = [AADOrganizationCertificateBasedAuthConfiguration]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}

class MSFT_MicrosoftGraphcertificateAuthority
{
    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('Required. The base64 encoded string representing the public certificate.')]
    [System.String] $Certificate

    [DscProperty()]
    [System.ComponentModel.Description('The URL of the certificate revocation list.')]
    [System.String] $CertificateRevocationListUrl

    [DscProperty()]
    [System.ComponentModel.Description('The URL contains the list of all revoked certificates since the last time a full certificate revocaton list was created.')]
    [System.String] $DeltaCertificateRevocationListUrl

    [DscProperty()]
    [System.ComponentModel.Description('Required. true if the trusted certificate is a root authority, false if the trusted certificate is an intermediate authority.')]
    [System.Nullable[System.Boolean]] $IsRootAuthority
}
