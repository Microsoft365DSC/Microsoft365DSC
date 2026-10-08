using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class ADOOrganizationOwner : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('NAme of the Azure DevOPS Organization')]
    [System.String] $OrganizationName

    [DscProperty()]
    [System.ComponentModel.Description('User principal of the organization''s owner')]
    [System.String] $Owner

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

    [ADOOrganizationOwner] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [ADOOrganizationOwner]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration for ADO Organization Owner for organization $($this.OrganizationName)"

        try
        {
            $null = $this.Connect('AzureDevOPS')

            #Ensure the proper dependencies are installed in the current environment.
            Confirm-M365DSCDependencies

            #region Telemetry
            $this.AddTelemetry('Get')
            #endregion

            $uri = "https://vssps.dev.azure.com/$($this.OrganizationName)/_apis/Organization/Collections/Me"
            $organizationInfo = Invoke-M365DSCAzureDevOPSWebRequest -Uri $uri

            $uri = "https://vsaex.dev.azure.com/$($this.OrganizationName)/_apis/userentitlements?api-version=7.2-preview.4"
            $allUsers = Invoke-M365DSCAzureDevOPSWebRequest -Uri $uri

            $ownerInfo = $allUsers.Items | Where-Object -FilterScript { $_.id -eq $organizationInfo.owner }

            $results = @{
                OrganizationName      = $this.OrganizationName
                Owner                 = $ownerInfo.user.principalName
                Credential            = $this.Credential
                ApplicationId         = $this.ApplicationId
                TenantId              = $this.TenantId
                CertificateThumbprint = $this.CertificateThumbprint
                CertificatePath       = $this.CertificatePath
                CertificatePassword   = $this.CertificatePassword
                ManagedIdentity       = $this.ManagedIdentity
                AccessTokens          = $this.AccessTokens
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

        Write-Verbose -Message "Setting ADO Organization Owner for organization $($this.OrganizationName)"

        $null = $this.Connect('AzureDevOPS')

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        Write-Verbose -Message 'Retrieving all users.'
        $uri = "https://vsaex.dev.azure.com/$($this.OrganizationName)/_apis/userentitlements?api-version=7.2-preview.4"
        $allUsers = Invoke-M365DSCAzureDevOPSWebRequest -Uri $uri

        $ownerInfo = $allUsers.items | Where-Object -FilterScript { $_.user.principalName -eq $this.Owner }

        if ($null -ne $ownerInfo)
        {
            Write-Verbose -Message "Updating owner for organization {$($this.OrganizationName)} to {$($ownerInfo.id)}"
            $body = "[{`"from`":`"`",`"op`":2,`"path`":`"/Owner`",`"value`":`"$($ownerInfo.id)`"}]"
            $uri = "https://vssps.dev.azure.com/$($this.OrganizationName)/_apis/Organization/Collections/Me?api-version=7.1-preview.1"
            Invoke-M365DSCAzureDevOPSWebRequest -Uri $uri -Method PATCH -Body $body
        }
        else
        {
            throw "Could not retrieve an Azure DevOPS user entitlement for {$($this.Owner)}"
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

        try
        {
            $ConnectionMode = $this.Connect('AzureDevOPS')

            #Ensure the proper dependencies are installed in the current environment.
            Confirm-M365DSCDependencies

            #region Telemetry
            $this.AddTelemetry('Export')
            #endregion

            $devOpsProfile = Invoke-M365DSCAzureDevOPSWebRequest -Uri 'https://app.vssps.visualstudio.com/_apis/profile/profiles/me?api-version=5.1'
            $accounts = Invoke-M365DSCAzureDevOPSWebRequest -Uri "https://app.vssps.visualstudio.com/_apis/accounts?api-version=7.1-preview.1&memberId=$($devOpsProfile.id)"

            $i = 1
            $dscContent = [System.Text.StringBuilder]::new()
            if ($accounts.Count -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
                return ''
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }
            foreach ($account in $accounts)
            {
                $organization = $account.Value.accountName
                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }

                $displayedKey = $organization
                Write-M365DSCHost -Message "    |---[$i/$($accounts.Count)] $displayedKey" -DeferWrite
                $params = @{
                    OrganizationName      = $organization
                    Credential            = $this.Credential
                    ApplicationId         = $this.ApplicationId
                    TenantId              = $this.TenantId
                    CertificateThumbprint = $this.CertificateThumbprint
                    CertificatePath       = $this.CertificatePath
                    CertificatePassword   = $this.CertificatePassword
                    ManagedIdentity       = $this.ManagedIdentity
                    AccessTokens          = $this.AccessTokens
                }

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

    hidden [ADOOrganizationOwner] AsResult([System.Object] $Values)
    {
        if ($Values -is [ADOOrganizationOwner])
        {
            return $Values
        }

        $result = [ADOOrganizationOwner]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
