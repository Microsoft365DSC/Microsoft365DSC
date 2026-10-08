using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class SPOStorageEntity : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The key of the storage entity.')]
    [System.String] $Key

    [DscProperty()]
    [System.ComponentModel.Description('Scope of the storage entity.')]
    [ValidateSet('Tenant', 'Site')]
    [System.String] $EntityScope

    [DscProperty()]
    [System.ComponentModel.Description('Value of the storage entity.')]
    [System.String] $Value

    [DscProperty()]
    [System.ComponentModel.Description('Description of storage entity.')]
    [System.String] $Description

    [DscProperty()]
    [System.ComponentModel.Description('Comment for the storage entity.')]
    [System.String] $Comment

    [DscProperty()]
    [System.ComponentModel.Description('Used to add or remove storage entity.')]
    [ValidateSet('Present', 'Absent')]
    [System.String] $Ensure

    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('The url of site collection or tenant.')]
    [System.String] $SiteUrl

    [DscProperty()]
    [System.ComponentModel.Description('Credentials of the Office365 Tenant Admin.')]
    [System.Management.Automation.PSCredential] $Credential

    [DscProperty()]
    [System.ComponentModel.Description('Id of the Azure Active Directory application to authenticate with.')]
    [System.String] $ApplicationId

    [DscProperty()]
    [System.ComponentModel.Description('Secret of the Azure Active Directory application to authenticate with.')]
    [System.Management.Automation.PSCredential] $ApplicationSecret

    [DscProperty()]
    [System.ComponentModel.Description('Name of the Azure Active Directory tenant used for authentication. Format contoso.onmicrosoft.com')]
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

    [SPOStorageEntity] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [SPOStorageEntity]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration for SPO Storage Entity for $($this.Key)"

        try
        {
            if ($null -eq $this.ExportedInstance)
            {
                $ConnectionMode = $this.Connect('PNP', $this.SiteUrl)

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullReturn = $this.GetBoundParameters()
                $nullReturn.Ensure = 'Absent'

                Write-Verbose -Message "Getting storage entity $($this.Key)"
                $entityStorageParms = @{ }
                $entityStorageParms.Add('Key', $this.Key)

                if ($null -ne $this.EntityScope -and '' -ne $this.EntityScope)
                {
                    $entityStorageParms.Add('Scope', $this.EntityScope)
                }

                $Entity = Get-PnPStorageEntity @entityStorageParms -ErrorAction SilentlyContinue
                ## Get-PnPStorageEntity seems to not return $null when not found
                ## so checking key
                if ($null -eq $Entity.Key)
                {
                    Write-Verbose -Message "No storage entity found for $($this.Key)"
                    return $this.AsResult($nullReturn)
                }
            }
            else
            {
                $Entity = $this.ExportedInstance
            }

            Write-Verbose -Message "Found storage entity $($Entity.Key)"

            return $this.AsResult(@{
                Key                   = $Entity.Key
                Value                 = $Entity.Value
                EntityScope           = $this.EntityScope
                Description           = $Entity.Description
                Comment               = $Entity.Comment
                Ensure                = 'Present'
                SiteUrl               = $this.SiteUrl
                Credential            = $this.Credential
                ApplicationId         = $this.ApplicationId
                TenantId              = $this.TenantId
                ApplicationSecret     = $this.ApplicationSecret
                CertificateThumbprint = $this.CertificateThumbprint
                CertificatePath       = $this.CertificatePath
                CertificatePassword   = $this.CertificatePassword
                ManagedIdentity       = $this.ManagedIdentity
                AccessTokens          = $this.AccessTokens
            })
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

        Write-Verbose -Message "Setting configuration for SPO Storage Entity for $($this.Key)"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $curStorageEntry = $this.Get().ToHashtable()

        $CurrentParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()
        $CurrentParameters.Remove('SiteUrl') | Out-Null
        $CurrentParameters.Remove('EntityScope') | Out-Null
        if (-not [System.String]::IsNullOrEmpty($this.EntityScope))
        {
            $CurrentParameters.Add('Scope', $this.EntityScope)
        }

        $isRemoval = $this.Ensure -eq 'Absent'
        if ($isRemoval -and $curStorageEntry.Ensure -ne 'Present')
        {
            return
        }

        $storageSiteUrl = $this.SiteUrl
        if ($this.EntityScope -ne 'Site')
        {
            $storageSiteUrl = Get-PnPTenantAppCatalogUrl
            if ([System.String]::IsNullOrEmpty($storageSiteUrl))
            {
                throw "Storage entity {$($this.Key)} cannot be written: tenant-scoped storage entities are stored in the tenant app catalog, and the tenant has none."
            }
        }

        $storageSite = Get-PnPTenantSite -Identity $storageSiteUrl
        $resetSecurity = $false
        try
        {
            if ($storageSite.DenyAddAndCustomizePages -eq 'Enabled')
            {
                Set-PnPTenantSite -Identity $storageSiteUrl -NoScriptSite:$false -ErrorAction Stop
                $resetSecurity = $true
            }

            if ($isRemoval)
            {
                Write-Verbose -Message "Removing storage entity $($this.Key)"
                $removeParameters = @{
                    Key = $this.Key
                }

                if (-not [System.String]::IsNullOrEmpty($this.EntityScope))
                {
                    $removeParameters.Add('Scope', $this.EntityScope)
                }

                Remove-PnPStorageEntity @removeParameters -ErrorAction Stop
            }
            else
            {
                Write-Verbose -Message "Adding new storage entity $($this.Key)"
                Set-PnPStorageEntity @CurrentParameters -ErrorAction Stop
            }
        }
        catch
        {
            if ($_.Exception.Message -like '*Access denied*' -or $_.Exception.Message -like '*Access is denied*')
            {
                throw "Access denied while writing storage entity {$($this.Key)} to {$storageSiteUrl}. " + `
                    "Storage entities can only be written while custom script is allowed on that site; DenyAddAndCustomizePages was {$($storageSite.DenyAddAndCustomizePages)}. " + `
                    'Allow it with Set-PnPTenantSite -Url <site> -DenyAddAndCustomizePages:$false, and make sure the account is a site collection administrator there or the application has Sites.FullControl.All.'
            }

            throw
        }
        finally
        {
            if ($resetSecurity)
            {
                Write-Verbose -Message "Resetting security for $storageSiteUrl"
                Set-PnPTenantSite -Identity $storageSiteUrl -NoScriptSite:$true
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

        try
        {
            $ConnectionMode = $this.Connect('PNP')

            #Ensure the proper dependencies are installed in the current environment.
            Confirm-M365DSCDependencies

            #region Telemetry
            $this.AddTelemetry('Export')
            #endregion

            $storageEntities = Get-PnPStorageEntity -ErrorAction SilentlyContinue

            $i = 1
            $dscContent = [System.Text.StringBuilder]::new()
            $organization = ''
            $principal = '' # Principal represents the "NetBios" name of the tenant (e.g. the M365DSC part of M365DSC.onmicrosoft.com)
            $organization = Get-M365DSCOrganization -Credential $this.Credential -TenantId $this.Tenantid
            if ($organization.IndexOf('.') -gt 0)
            {
                $principal = $organization.Split('.')[0]
            }

            # Obtain central administration url from a User Principal Name
            if ($ConnectionMode -eq 'Credential')
            {
                $centralAdminUrl = Get-SPOAdministrationUrl -Credential $this.Credential
            }
            else
            {
                $centralAdminUrl = "https://$principal-admin.sharepoint.com"
            }

            if ($storageEntities.Length -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }

            foreach ($storageEntity in $storageEntities)
            {
                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }

                $Params = @{
                    Credential            = $this.Credential
                    Key                   = $storageEntity.Key
                    SiteUrl               = $centralAdminUrl
                    ApplicationId         = $this.ApplicationId
                    TenantId              = $this.TenantId
                    ApplicationSecret     = $this.ApplicationSecret
                    CertificateThumbprint = $this.CertificateThumbprint
                    CertificatePath       = $this.CertificatePath
                    CertificatePassword   = $this.CertificatePassword
                    ManagedIdentity       = $this.ManagedIdentity
                    AccessTokens          = $this.AccessTokens
                }
                Write-M365DSCHost -Message "    |---[$i/$($storageEntities.Length)] $($storageEntity.Key)" -DeferWrite

                $this.ExportedInstance = $storageEntity
                $Results = $this.GetForExport($Params)
                $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                    -ConnectionMode $ConnectionMode `
                    -ModulePath $this.GetModulePath() `
                    -Results $Results `
                    -Credential $this.Credential

                # Make the Url parameterized
                if ($currentDSCBlock.ToLower().Contains($organization.ToLower()) -or `
                        $currentDSCBlock.ToLower().Contains($principal.ToLower()))
                {
                    $currentDSCBlock = $currentDSCBlock -ireplace [regex]::Escape('https://' + $principal + '.sharepoint.com'), "https://`$(`$OrganizationName.Split('.')[0]).sharepoint.com"
                    $currentDSCBlock = $currentDSCBlock -ireplace [regex]::Escape('https://' + $principal + '-admin.sharepoint.com'), "https://`$(`$OrganizationName.Split('.')[0])-admin.sharepoint.com"
                }
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

    [System.Collections.Hashtable] GetCompareParameters()
    {
        return @{
            ExcludedProperties = @('SiteUrl')
        }
    }

    hidden [SPOStorageEntity] AsResult([System.Object] $Values)
    {
        if ($Values -is [SPOStorageEntity])
        {
            return $Values
        }

        $result = [SPOStorageEntity]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
