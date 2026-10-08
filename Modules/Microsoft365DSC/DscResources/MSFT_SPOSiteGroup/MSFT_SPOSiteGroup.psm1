using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class SPOSiteGroup : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The name of the site group')]
    [System.String] $Identity

    [DscProperty(Key)]
    [System.ComponentModel.Description('The URL of the site.')]
    [System.String] $Url

    [DscProperty()]
    [System.ComponentModel.Description('The owner (email address) of the site group')]
    [System.String] $Owner

    [DscProperty()]
    [System.ComponentModel.Description('The permission level of the site group')]
    [System.String[]] $PermissionLevels

    [DscProperty()]
    [System.ComponentModel.Description('Used to add or remove site design.')]
    [ValidateSet('Present', 'Absent')]
    [System.String] $Ensure

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

    [SPOSiteGroup] Get()
    {
        $siteGroup = $null
        $nullReturn = $null
        $sitePermissions = $null
        if ($this.RequiresPowerShellCore())
        {
            $remote = [SPOSiteGroup]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting SPOSiteGroups for {$($this.Url)}"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.Title -ne $this.Identity)
            {
                $null = $this.Connect('PNP')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullReturn = $this.GetBoundParameters()
                $nullReturn.Ensure = 'Absent'

                #checking if the site actually exists
                try
                {
                    $null = Get-PnPTenantSite $this.Url -ErrorAction Stop
                }
                catch
                {
                    $Message = "The specified site collection doesn't exist."
                    $this.LogError($_, $Message)
                    throw $Message
                    return $this.AsResult($nullReturn)
                }
                try
                {
                    $null = $this.Connect('PNP', $this.Url)
                    $siteGroup = Get-PnPGroup -Identity $this.Identity `
                        -ErrorAction Stop
                }
                catch
                {
                    if ($Error[0].Exception.Message -eq 'Group cannot be found.')
                    {
                        Write-Verbose -Message "Site group $($this.Identity) could not be found on site $($this.Url)"

                    }
                }
                if ($null -eq $siteGroup)
                {
                    return $this.AsResult($nullReturn)
                }

                $null = Get-PnPProperty -ClientObject $siteGroup -Property Owner
            }
            else
            {
                $siteGroup = $this.ExportedInstance
            }

            try
            {
                $sitePermissions = Get-PnPGroupPermissions -Identity $this.Identity `
                    -ErrorAction Stop
            }
            catch
            {
                if ($_.Exception -like '*Access denied*')
                {
                    Write-Warning -Message 'The specified account does not have access to the permissions list'
                    return $this.AsResult($nullReturn)
                }
            }
            $permissions = @()
            foreach ($entry in $sitePermissions.Name)
            {
                $permissions += $entry.ToString()
            }
            return $this.AsResult(@{
                Url                   = $this.Url
                Identity              = $siteGroup.Title
                Owner                 = ([System.String]$siteGroup.Owner.LoginName).Split('|')[-1]
                PermissionLevels      = [array]$permissions
                Credential            = $this.Credential
                Ensure                = 'Present'
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

        Write-Verbose -Message "Setting SPOSiteGroups for {$($this.Url)}"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $currentValues = $this.Get().ToHashtable()
        $IsNew = $false
        if ($this.Ensure -eq 'Present' -and $currentValues.Ensure -eq 'Absent')
        {
            $SiteGroupSettings = @{
                Title = $this.Identity
                Owner = $this.Owner
            }
            Write-Verbose -Message "Site group $($this.Identity) does not exist, creating it."
            New-PnPGroup @SiteGroupSettings
            $IsNew = $true
        }
        if (($this.Ensure -eq 'Present' -and $currentValues.Ensure -eq 'Present') -or $IsNew)
        {
            $GroupPermissionsParameters = @{
                Identity = $this.Identity
            }
            if ($this.GetBoundParameters().ContainsKey('PermissionLevels'))
            {
                $currentRoles = @()
                if (-not $IsNew)
                {
                    $currentRoles = @($currentValues.PermissionLevels | Where-Object -FilterScript { -not [System.String]::IsNullOrEmpty($_) })
                }
                $PermissionLevelsToAdd = @($this.PermissionLevels | Where-Object -FilterScript { $currentRoles -notcontains $_ })
                $PermissionLevelsToRemove = @($currentRoles | Where-Object -FilterScript { $this.PermissionLevels -notcontains $_ })
                if ($PermissionLevelsToAdd.Count -gt 0)
                {
                    Write-Verbose -Message "Permission levels to add: $($PermissionLevelsToAdd -join ', ')"
                    $GroupPermissionsParameters.Add('AddRole', $PermissionLevelsToAdd)
                }

                if ($PermissionLevelsToRemove.Count -gt 0)
                {
                    Write-Verbose -Message "Permission levels to remove: $($PermissionLevelsToRemove -join ', ')"
                    $GroupPermissionsParameters.Add('RemoveRole', $PermissionLevelsToRemove)
                }
            }

            if (-not $IsNew -and $this.GetBoundParameters().ContainsKey('Owner') -and $this.Owner -ne $currentValues.Owner)
            {
                Write-Verbose -Message "Setting PnP Group with Identity {$($this.Identity)} and Owner {$($this.Owner)}"
                Set-PnPGroup -Identity $this.Identity -Owner $this.Owner
            }

            if ($GroupPermissionsParameters.Count -gt 1)
            {
                Set-PnPGroupPermissions @GroupPermissionsParameters
            }
        }
        elseif ($this.Ensure -eq 'Absent' -and $currentValues.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Removing SPOSiteGroup $($this.Identity)"
            $SiteGroupSettings = @{
                Identity = $this.Identity
            }

            Remove-PnPGroup @SiteGroupSettings -Force
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

            #Loop through all sites
            #for each site loop through all site groups and retrieve parameters
            $sites = Get-PnPTenantSite -ErrorAction Stop

            $i = 1

            $principal = '' # Principal represents the "NetBios" name of the tenant (e.g. the M365DSC part of M365DSC.onmicrosoft.com)
            if ($null -ne $this.Credential -and $this.Credential.UserName.Contains('@'))
            {
                $organization = $this.Credential.UserName.Split('@')[1]

                if ($organization.IndexOf('.') -gt 0)
                {
                    $principal = $organization.Split('.')[0]
                }
            }
            else
            {
                $organization = $this.TenantId
                $principal = $organization.Split('.')[0]
            }

            $dscContent = [System.Text.StringBuilder]::new()
            Write-M365DSCHost -Message "`r`n" -DeferWrite
            foreach ($site in $sites)
            {
                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }

                Write-M365DSCHost -Message "    |---[$i/$($sites.Length)] SPOSite groups for {$($site.Url)}" -DeferWrite
                $siteGroups = $null
                try
                {

                    $ConnectionMode = $this.Connect('PNP', $site.Url)
                    $siteGroups = Get-PnPGroup -ErrorAction Stop
                }
                catch
                {
                    Write-Warning -Message "Could not retrieve sitegroups for site $($site.Url): $($_.Exception.Message)"
                }

                $j = 1
                if ($siteGroups.Length -eq 0)
                {
                    Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
                    continue
                }
                else
                {
                    Write-M365DSCHost -Message "`r`n" -DeferWrite
                }
                foreach ($siteGroup in $siteGroups)
                {
                    Write-M365DSCHost -Message "        |---[$j/$($siteGroups.Length)] $($siteGroup.Title)" -DeferWrite
                    $Params = @{
                        Url                   = $site.Url
                        Identity              = $siteGroup.Title
                        ApplicationId         = $this.ApplicationId
                        TenantId              = $this.TenantId
                        ApplicationSecret     = $this.ApplicationSecret
                        CertificatePassword   = $this.CertificatePassword
                        CertificatePath       = $this.CertificatePath
                        CertificateThumbprint = $this.CertificateThumbprint
                        ManagedIdentity       = $this.ManagedIdentity
                        Credential            = $this.Credential
                        AccessTokens          = $this.AccessTokens
                    }
                    try
                    {
                        $this.ExportedInstance = $siteGroup
                        $Results = $this.GetForExport($Params)
                        if ($Results.Ensure -eq 'Present')
                        {
                            $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                                -ConnectionMode $ConnectionMode `
                                -ModulePath $this.GetModulePath() `
                                -Results $Results `
                                -Credential $this.Credential

                            # Make the Url parameterized
                            if ($currentDSCBlock.ToLower().Contains($organization.ToLower()) -or `
                                    $currentDSCBlock.ToLower().Contains($principal.ToLower()))
                            {
                                $currentDSCBlock = $currentDSCBlock -ireplace [regex]::Escape('https://' + $principal + '.sharepoint.com/'), "https://`$(`$OrganizationName.Split('.')[0]).sharepoint.com/"
                                $currentDSCBlock = $currentDSCBlock -ireplace [regex]::Escape('https://' + $principal + '-my.sharepoint.com/'), "https://`$(`$OrganizationName.Split('.')[0])-my.sharepoint.com/"
                                $currentDSCBlock = $currentDSCBlock -ireplace [regex]::Escape('@' + $organization), "@`$(`$OrganizationName)"
                            }
                            [void]$dscContent.Append($currentDSCBlock)

                            Save-M365DSCPartialExport -Content $currentDSCBlock `
                                -FileName $Global:PartialExportFileName
                        }
                    }
                    catch
                    {
                        Write-Verbose -Message "There was an issue retrieving the SiteGroups for $($this.Url)"
                    }
                    $j++
                    Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
                }

                $i++
            }

            if ($i -eq 1)
            {
                Write-M365DSCHost -Message ''
            }

            return $dscContent.ToString()
        }
        catch
        {
            $this.LogError($_, 'Error during Export:')

            throw
        }
    }

    hidden [SPOSiteGroup] AsResult([System.Object] $Values)
    {
        if ($Values -is [SPOSiteGroup])
        {
            return $Values
        }

        $result = [SPOSiteGroup]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
