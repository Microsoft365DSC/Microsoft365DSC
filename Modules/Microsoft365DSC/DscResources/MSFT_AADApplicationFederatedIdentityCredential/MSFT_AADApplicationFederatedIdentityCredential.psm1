using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class AADApplicationFederatedIdentityCredential : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('Display name of the Azure AD application that owns the federated identity credential.')]
    [System.String] $ApplicationDisplayName

    [DscProperty(Key)]
    [System.ComponentModel.Description('The unique name of the federated identity credential.')]
    [System.String] $Name

    [DscProperty()]
    [System.ComponentModel.Description('Object ID of the Azure AD application that owns the federated identity credential.')]
    [System.String] $ApplicationObjectId

    [DscProperty()]
    [System.ComponentModel.Description('The unique identifier of the federated identity credential.')]
    [System.String] $Id

    [DscProperty()]
    [System.ComponentModel.Description('The issuer URL of the external identity provider.')]
    [System.String] $Issuer

    [DscProperty()]
    [System.ComponentModel.Description('The subject identifier of the external workload.')]
    [System.String] $Subject

    [DscProperty()]
    [System.ComponentModel.Description('The audiences that can appear in the external token.')]
    [System.String[]] $Audiences

    [DscProperty()]
    [System.ComponentModel.Description('The description of the federated identity credential.')]
    [System.String] $Description

    [DscProperty()]
    [System.ComponentModel.Description('Specify if the federated identity credential should exist or not.')]
    [ValidateSet('Present', 'Absent')]
    [System.String] $Ensure

    [DscProperty()]
    [System.ComponentModel.Description('Credentials for the Microsoft Graph delegated permissions.')]
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
    [System.ComponentModel.Description('Username can be made up to anything but password will be used for CertificatePassword.')]
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

    [AADApplicationFederatedIdentityCredential] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [AADApplicationFederatedIdentityCredential]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting federated identity credential {$($this.Name)} for application {$($this.ApplicationDisplayName)}"

        $errorLogged = $false
        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.Name -ne $this.Name -or $this.ExportedInstance.ApplicationDisplayName -ne $this.ApplicationDisplayName)
            {
                $null = $this.Connect('MicrosoftGraph')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullReturn = $this.GetBoundParameters()
                $nullReturn.Ensure = 'Absent'

                $application = $null
                try
                {
                    if (-not [System.String]::IsNullOrEmpty($this.ApplicationObjectId))
                    {
                        [array]$application = Get-MgApplication `
                            -ApplicationId $this.ApplicationObjectId `
                            -Property @('id', 'displayName') `
                            -ErrorAction Stop
                    }
                }
                catch
                {
                    Write-Verbose -Message "Could not retrieve Azure AD application by ID {$($this.ApplicationObjectId)}"
                }

                if ($null -eq $application)
                {
                    try
                    {
                        [array]$application = Get-MgApplication `
                            -Filter "DisplayName eq '$($this.ApplicationDisplayName -replace "'", "''")'" `
                            -Property @('id', 'displayName') `
                            -ErrorAction Stop
                    }
                    catch
                    {
                        $this.LogError($_, 'Error retrieving application data:')
                    }
                }

                if ($null -eq $application)
                {
                    return $this.AsResult($nullReturn)
                }

                if ($application.Count -gt 1)
                {
                    throw "Multiple Azure AD applications with the display name $($this.ApplicationDisplayName) exist in the tenant."
                }

                $applicationObjectIdValue = $application.Id
                $applicationDisplayNameValue = $application.DisplayName
                $nullReturn.ApplicationObjectId = $applicationObjectIdValue
                $nullReturn.ApplicationDisplayName = $applicationDisplayNameValue

                $federatedIdentityCredential = $null
                try
                {
                    if (-not [System.String]::IsNullOrEmpty($this.Id))
                    {
                        [array]$federatedIdentityCredential = Get-MgApplicationFederatedIdentityCredential `
                            -ApplicationId $applicationObjectIdValue `
                            -FederatedIdentityCredentialId $this.Id `
                            -ErrorAction Stop
                    }
                }
                catch
                {
                    Write-Verbose -Message "Could not retrieve federated identity credential by ID {$($this.Id)}"
                }

                if ($null -eq $federatedIdentityCredential)
                {
                    try
                    {
                        [array]$federatedIdentityCredential = Get-MgApplicationFederatedIdentityCredential `
                            -ApplicationId $applicationObjectIdValue `
                            -Filter "name eq '$($this.Name -replace "'", "''")'" `
                            -ErrorAction Stop
                    }
                    catch
                    {
                        if (Test-M365DSCNotFoundError -ErrorRecord $_)
                        {
                            Write-Verbose -Message "Could not retrieve federated identity credential by name {$($this.Name)}"
                        }
                        else
                        {
                            $this.LogError($_, 'Error retrieving data:')
                            $errorLogged = $true
                            throw
                        }
                    }
                }

                if ($null -eq $federatedIdentityCredential)
                {
                    return $this.AsResult($nullReturn)
                }

                if ($federatedIdentityCredential.Count -gt 1)
                {
                    throw "Multiple federated identity credentials with the name $($this.Name) exist for application $($applicationDisplayNameValue)."
                }
            }
            else
            {
                $federatedIdentityCredential = $this.ExportedInstance
                $applicationObjectIdValue = $this.ExportedInstance.ApplicationObjectId
                $applicationDisplayNameValue = $this.ExportedInstance.ApplicationDisplayName
            }

            $result = @{
                ApplicationDisplayName = $applicationDisplayNameValue
                ApplicationObjectId    = $applicationObjectIdValue
                Name                   = $federatedIdentityCredential.Name
                Id                     = $federatedIdentityCredential.Id
                Issuer                 = $federatedIdentityCredential.Issuer
                Subject                = $federatedIdentityCredential.Subject
                Audiences              = $federatedIdentityCredential.Audiences
                Description            = $federatedIdentityCredential.Description
                Ensure                 = 'Present'
                Credential             = $this.Credential
                ApplicationId          = $this.ApplicationId
                ApplicationSecret      = $this.ApplicationSecret
                TenantId               = $this.TenantId
                CertificateThumbprint  = $this.CertificateThumbprint
                CertificatePath        = $this.CertificatePath
                CertificatePassword    = $this.CertificatePassword
                ManagedIdentity        = $this.ManagedIdentity.IsPresent
                AccessTokens           = $this.AccessTokens
            }

            return $this.AsResult($result)
        }
        catch
        {
            if (-not $errorLogged)
            {
                $this.LogError($_, 'Error retrieving data:')
            }

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

        Write-Verbose -Message "Setting federated identity credential {$($this.Name)} for application {$($this.ApplicationDisplayName)}"

        Confirm-M365DSCDependencies

        #region Telemetry
        $this.AddTelemetry('Set')
        #endregion

        $currentFederatedIdentityCredential = $this.Get().ToHashtable()
        $bodyParameter = @{
            name      = $this.Name
            issuer    = $this.Issuer
            subject   = $this.Subject
            audiences = $this.Audiences
        }

        if ($this.GetBoundParameters().ContainsKey('Description'))
        {
            $bodyParameter.Add('description', $this.Description)
        }

        if ($this.Ensure -eq 'Present' -and $currentFederatedIdentityCredential.Ensure -eq 'Absent')
        {
            if ([System.String]::IsNullOrEmpty($currentFederatedIdentityCredential.ApplicationObjectId))
            {
                throw "Could not find Azure AD application with display name {$($this.ApplicationDisplayName)}."
            }

            Write-Verbose -Message "Creating federated identity credential {$($this.Name)}"
            New-MgApplicationFederatedIdentityCredential `
                -ApplicationId $currentFederatedIdentityCredential.ApplicationObjectId `
                -BodyParameter $bodyParameter
        }
        elseif ($this.Ensure -eq 'Present' -and $currentFederatedIdentityCredential.Ensure -eq 'Present')
        {
            $bodyParameter = @{}
            foreach ($propertyName in @('Issuer', 'Subject', 'Audiences', 'Description'))
            {
                if ($this.GetBoundParameters().ContainsKey($propertyName))
                {
                    $bodyParameter.Add($propertyName.Substring(0, 1).ToLower() + $propertyName.Substring(1), $this.$propertyName)
                }
            }

            Write-Verbose -Message "Updating federated identity credential {$($this.Name)}"
            Update-MgApplicationFederatedIdentityCredential `
                -ApplicationId $currentFederatedIdentityCredential.ApplicationObjectId `
                -FederatedIdentityCredentialId $currentFederatedIdentityCredential.Id `
                -BodyParameter $bodyParameter
        }
        elseif ($this.Ensure -eq 'Absent' -and $currentFederatedIdentityCredential.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Removing federated identity credential {$($this.Name)}"
            Remove-MgApplicationFederatedIdentityCredential `
                -ApplicationId $currentFederatedIdentityCredential.ApplicationObjectId `
                -FederatedIdentityCredentialId $currentFederatedIdentityCredential.Id
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

        #region Telemetry
        $this.AddTelemetry('Export')
        #endregion

        $dscContent = [System.Text.StringBuilder]::new()
        try
        {
            [array]$applications = Get-MgApplication -All -Filter $this.Filter -Property @('id', 'displayName') `
                -ExpandProperty 'federatedIdentityCredentials' -ErrorAction Stop
            if ($applications.Length -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }

            foreach ($application in $applications)
            {
                [array]$federatedIdentityCredentials = $this.ResolveExpandedNavigation($application, 'FederatedIdentityCredentials')
                if ($null -eq $federatedIdentityCredentials)
                {
                    [array]$federatedIdentityCredentials = Get-MgApplicationFederatedIdentityCredential `
                        -ApplicationId $application.Id `
                        -All `
                        -ErrorAction Stop
                }

                $i = 1
                foreach ($federatedIdentityCredential in $federatedIdentityCredentials)
                {
                    if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                    {
                        $Global:M365DSCExportResourceInstancesCount++
                    }

                    Write-M365DSCHost -Message "    |---[$i/$($federatedIdentityCredentials.Count)] $($application.DisplayName) - $($federatedIdentityCredential.Name)" -DeferWrite
                    $params = @{
                        Credential            = $this.Credential
                        ApplicationId         = $this.ApplicationId
                        ApplicationSecret     = $this.ApplicationSecret
                        TenantId              = $this.TenantId
                        CertificateThumbprint = $this.CertificateThumbprint
                        CertificatePath       = $this.CertificatePath
                        CertificatePassword   = $this.CertificatePassword
                        ManagedIdentity       = $this.ManagedIdentity.IsPresent
                        ApplicationDisplayName = $application.DisplayName
                        ApplicationObjectId   = $application.Id
                        Name                  = $federatedIdentityCredential.Name
                        Id                    = $federatedIdentityCredential.Id
                        AccessTokens          = $this.AccessTokens
                    }
                    $this.ExportedInstance = $federatedIdentityCredential
                    $this.ExportedInstance.Add('ApplicationObjectId', $application.Id)
                    $this.ExportedInstance.Add('ApplicationDisplayName', $application.DisplayName)
                    $results = $this.GetForExport($params)
                    $results.Remove('ApplicationObjectId') | Out-Null

                    if ($results.Ensure -eq 'Present')
                    {
                        $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                            -ConnectionMode $ConnectionMode `
                            -ModulePath $this.GetModulePath() `
                            -Results $results `
                            -Credential $this.Credential
                        [void]$dscContent.Append($currentDSCBlock)
                        Save-M365DSCPartialExport -Content $currentDSCBlock `
                            -FileName $Global:PartialExportFileName

                        Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
                        $i++
                    }
                }
            }

            return $dscContent.ToString()
        }
        catch
        {
            $this.LogError($_, 'Error during Export:')

            throw
        }
    }

    hidden [AADApplicationFederatedIdentityCredential] AsResult([System.Object] $Values)
    {
        if ($Values -is [AADApplicationFederatedIdentityCredential])
        {
            return $Values
        }

        $result = [AADApplicationFederatedIdentityCredential]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
