using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class AADDomain : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('Custom domain name.')]
    [System.String] $Id

    [DscProperty()]
    [System.ComponentModel.Description('Indicates the configured authentication type for the domain. The value is either Managed or Federated. Managed indicates a cloud managed domain where Microsoft Entra ID performs user authentication. Federated indicates authentication is federated with an identity provider such as the tenant''s on-premises Active Directory via Active Directory Federation Services.')]
    [System.String] $AuthenticationType

    [DscProperty()]
    [System.ComponentModel.Description('This property is always null except when the verify action is used. When the verify action is used, a domain entity is returned in the response. The availabilityStatus property of the domain entity in the response is either AvailableImmediately or EmailVerifiedDomainTakeoverScheduled.')]
    [System.String] $AvailabilityStatus

    [DscProperty()]
    [System.ComponentModel.Description('The value of the property is false if the DNS record management of the domain is delegated to Microsoft 365. Otherwise, the value is true. Not nullable')]
    [System.Nullable[System.Boolean]] $IsAdminManaged

    [DscProperty()]
    [System.ComponentModel.Description('True if this is the default domain that is used for user creation. There''s only one default domain per company. Not nullable.')]
    [System.Nullable[System.Boolean]] $IsDefault

    [DscProperty()]
    [System.ComponentModel.Description('True if the domain is a verified root domain. Otherwise, false if the domain is a subdomain or unverified. Not nullable.')]
    [System.Nullable[System.Boolean]] $IsRoot

    [DscProperty()]
    [System.ComponentModel.Description('True if the domain completed domain ownership verification. Not nullable.')]
    [System.Nullable[System.Boolean]] $IsVerified

    [DscProperty()]
    [System.ComponentModel.Description('Specifies the number of days before a user receives notification that their password expires. If the property isn''t set, a default value of 14 days is used.')]
    [System.Nullable[System.UInt32]] $PasswordNotificationWindowInDays

    [DscProperty()]
    [System.ComponentModel.Description('Specifies the length of time that a password is valid before it must be changed. If the property isn''t set, a default value of 90 days is used.')]
    [System.Nullable[System.UInt32]] $PasswordValidityPeriodInDays

    [DscProperty()]
    [System.ComponentModel.Description('The capabilities assigned to the domain. Can include 0, 1 or more of following values: Email, Sharepoint, EmailInternalRelayOnly, OfficeCommunicationsOnline, SharePointDefaultDomain, FullRedelegation, SharePointPublic, OrgIdAuthentication, Yammer, Intune. The values that you can add or remove using the API include: Email, OfficeCommunicationsOnline, Yammer. Not nullable.')]
    [System.String[]] $SupportedServices

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

    [AADDomain] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [AADDomain]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of AzureAD Domain for Id {$($this.Id)}"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.Id -ne $this.Id)
            {
                $null = $this.Connect('MicrosoftGraph')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullResult = $this.GetBoundParameters()
                $nullResult.Ensure = 'Absent'

                $instance = Get-MgBetaDomain -DomainId $this.Id -ErrorAction SilentlyContinue

                if ($null -eq $instance)
                {
                    return $this.AsResult($nullResult)
                }
            }
            else
            {
                $instance = $this.ExportedInstance
            }

            $results = @{
                Id                               = $instance.Id
                AuthenticationType               = $instance.AuthenticationType
                AvailabilityStatus               = $instance.AvailabilityStatus
                IsAdminManaged                   = $instance.IsAdminManaged
                IsDefault                        = $instance.IsDefault
                IsRoot                           = $instance.IsRoot
                IsVerified                       = $instance.IsVerified
                PasswordNotificationWindowInDays = $instance.PasswordNotificationWindowInDays
                PasswordValidityPeriodInDays     = $instance.PasswordValidityPeriodInDays
                Ensure                           = 'Present'
                Credential                       = $this.Credential
                ApplicationId                    = $this.ApplicationId
                TenantId                         = $this.TenantId
                ApplicationSecret                = $this.ApplicationSecret
                CertificateThumbprint            = $this.CertificateThumbprint
                CertificatePath                  = $this.CertificatePath
                CertificatePassword              = $this.CertificatePassword
                ManagedIdentity                  = $this.ManagedIdentity
                AccessTokens                     = $this.AccessTokens
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

        Write-Verbose -Message "Setting configuration of AzureAD Domain for Id {$($this.Id)}"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $currentInstance = $this.Get().ToHashtable()
        $setParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()

        # CREATE
        if ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
        {
            $NeedAdditionalUpdate = $false
            $UpdatePasswordNotificationWindowInDays = $false
            if (-not [System.String]::IsNullOrEmpty($this.PasswordNotificationWindowInDays))
            {
                $NeedAdditionalUpdate = $true
                $UpdatePasswordNotificationWindowInDays = $true
                $setParameters.Remove('PasswordNotificationWindowInDays') | Out-Null
            }
            $UpdatePasswordValidityPeriodInDays = $false
            if (-not [System.String]::IsNullOrEmpty($this.PasswordValidityPeriodInDays))
            {
                $NeedAdditionalUpdate = $true
                $UpdatePasswordValidityPeriodInDays = $true
                $setParameters.Remove('PasswordValidityPeriodInDays') | Out-Null
            }

            foreach ($property in @('AvailabilityStatus', 'IsAdminManaged', 'IsDefault', 'IsRoot', 'IsVerified'))
            {
                $setParameters.Remove($property) | Out-Null
            }

            Write-Verbose -Message "Creating new custom domain name {$($this.Id)}"
            $domain = New-MgBetaDomain -BodyParameter $setParameters

            if ($NeedAdditionalUpdate -and -not $domain.IsVerified)
            {
                Write-Warning -Message "Domain {$($this.Id)} is not verified. PasswordNotificationWindowInDays and PasswordValidityPeriodInDays can only be set once the domain is verified."
            }
            elseif ($NeedAdditionalUpdate)
            {
                $UpdateParams = @{}
                if ($UpdatePasswordNotificationWindowInDays)
                {
                    Write-Verbose -Message "Updating PasswordNotificationWindowInDays for domain {$($this.Id)}"
                    $UpdateParams.Add('passwordNotificationWindowInDays', $this.PasswordNotificationWindowInDays)
                }
                if ($UpdatePasswordValidityPeriodInDays)
                {
                    Write-Verbose -Message "Updating PasswordValidityPeriodInDays for domain {$($this.Id)}"
                    $UpdateParams.Add('passwordValidityPeriodInDays', $this.PasswordValidityPeriodInDays)
                }

                Update-MgBetaDomain -DomainId $domain.Id -BodyParameter $UpdateParams
            }
        }
        # UPDATE
        elseif ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Present')
        {
            foreach ($property in @('Id', 'AvailabilityStatus', 'IsAdminManaged', 'IsRoot', 'IsVerified'))
            {
                $setParameters.Remove($property) | Out-Null
            }
            Write-Verbose -Message "Updating custom domain name {$($this.Id)}"
            Update-MgBetaDomain -DomainId $this.Id -BodyParameter $setParameters
        }
        # REMOVE
        elseif ($this.Ensure -eq 'Absent' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Removing custom domain name {$($this.Id)}"
            Invoke-MgBetaForceDomainDelete -DomainId $this.Id
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
            [array] $exportedInstances = Get-MgBetaDomain `
                -All `
                -Filter $this.Filter `
                -ErrorAction Stop

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

                $displayedKey = $config.Id
                Write-M365DSCHost -Message "    |---[$i/$($exportedInstances.Count)] $displayedKey" -DeferWrite
                $params = @{
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

    hidden [AADDomain] AsResult([System.Object] $Values)
    {
        if ($Values -is [AADDomain])
        {
            return $Values
        }

        $result = [AADDomain]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
