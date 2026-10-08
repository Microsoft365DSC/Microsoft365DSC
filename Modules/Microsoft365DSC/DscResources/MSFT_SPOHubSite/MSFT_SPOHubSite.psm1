using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class SPOHubSite : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The URL of the site collection')]
    [System.String] $Url

    [DscProperty()]
    [System.ComponentModel.Description('The title of the hub site')]
    [System.String] $Title

    [DscProperty()]
    [System.ComponentModel.Description('The description of the hub site')]
    [System.String] $Description

    [DscProperty()]
    [System.ComponentModel.Description('The url to the logo of the hub site')]
    [System.String] $LogoUrl

    [DscProperty()]
    [System.ComponentModel.Description('Does the hub site require approval to join')]
    [System.Nullable[System.Boolean]] $RequiresJoinApproval

    [DscProperty()]
    [System.ComponentModel.Description('The users or mail-enabled security groups which are allowed to associate their site with a hub site')]
    [System.String[]] $AllowedToJoin

    [DscProperty()]
    [System.ComponentModel.Description('The guid of the site design to link to the hub site')]
    [System.String] $SiteDesignId

    [DscProperty()]
    [System.ComponentModel.Description('Present ensures the site collection is registered as hub site, absent ensures it is unregistered')]
    [ValidateSet('Present', 'Absent')]
    [System.String] $Ensure

    [DscProperty()]
    [System.ComponentModel.Description('Credentials of the account to authenticate with.')]
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

    [SPOHubSite] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [SPOHubSite]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration for hub site collection $($this.Url)"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.SiteUrl -ne $this.Url)
            {
                $null = $this.Connect('MicrosoftGraph')

                $null = $this.Connect('PnP')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullReturn = $this.GetBoundParameters()
                $nullReturn.Ensure = 'Absent'

                Write-Verbose -Message "Getting hub site collection $($this.Url)"
                $site = Get-PnPTenantSite -Identity $this.Url -ErrorAction SilentlyContinue
                if ($null -eq $site)
                {
                    Write-Verbose -Message "The specified Site Collection doesn't already exist."
                    return $this.AsResult($nullReturn)
                }

                if ($site.IsHubSite -eq $false)
                {
                    Write-Verbose -Message "The specified Site Collection isn't a hub site."
                    return $this.AsResult($nullReturn)
                }
            }
            else
            {
                $hubSite = $this.ExportedInstance
            }

            $hubSite = Get-PnPHubSite -Identity $this.Url
            $principals = @()
            foreach ($permission in $hubSite.Permissions.PrincipalName)
            {
                $result = $permission.Split('|')
                if ($result[0].StartsWith('c') -eq $true)
                {
                    # Group permissions
                    $group = Get-MgGroup -GroupId $result[2]

                    if ($null -eq $group.EmailAddress)
                    {
                        $principal = $group.DisplayName
                    }
                    else
                    {
                        $principal = $group.EmailAddress
                    }
                    $principals += $principal
                }
                else
                {
                    # User permissions
                    $principals += $result[2]
                }
            }

            if (-not [System.String]::IsNullOrEmpty($this.LogoUrl) -and $this.LogoUrl.StartsWith('http'))
            {
                $configuredLogo = $hubSite.LogoUrl
            }
            else
            {
                $configuredLogo = ([System.Uri]$hubSite.LogoUrl).AbsolutePath
            }

            $result = @{
                Url                   = $this.Url
                Title                 = $hubSite.Title
                Description           = $hubSite.Description
                LogoUrl               = $configuredLogo
                RequiresJoinApproval  = $hubSite.RequiresJoinApproval
                AllowedToJoin         = $principals
                SiteDesignId          = $hubSite.SiteDesignId
                Ensure                = 'Present'
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

        Write-Verbose -Message "Setting configuration for hub site collection $($this.Url)"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $ConnectionModeGraph = $this.Connect('MicrosoftGraph')

        $ConnectionMode = $this.Connect('PnP')

        try
        {
            Write-Verbose -Message "Setting hub site collection $($this.Url)"
            $site = Get-PnPTenantSite $this.Url
        }
        catch
        {
            $Message = "The specified Site Collection {$($this.Url)} for SPOHubSite doesn't already exist."
            $this.LogError($_, $Message)
            throw $Message
        }

        $currentValues = $this.Get().ToHashtable()

        if ($this.Ensure -eq 'Present' -and $currentValues.Ensure -eq 'Absent')
        {
            Write-Verbose -Message 'Configuring site collection as Hub Site'
            Register-PnPHubSite -Site $site.Url | Out-Null

            $params = @{
                Identity = $site.Url
            }

            if ($this.GetBoundParameters().ContainsKey('Title') -eq $true)
            {
                $params.Title = $this.Title
            }

            if ($this.GetBoundParameters().ContainsKey('Description') -eq $true)
            {
                $params.Description = $this.Description
            }

            if ($this.GetBoundParameters().ContainsKey('LogoUrl') -eq $true)
            {
                $params.LogoUrl = $this.LogoUrl
            }

            if ($this.GetBoundParameters().ContainsKey('RequiresJoinApproval') -eq $true)
            {
                $params.RequiresJoinApproval = $this.RequiresJoinApproval
            }

            if ($this.GetBoundParameters().ContainsKey('SiteDesignId') -eq $true)
            {
                $params.SiteDesignId = $this.SiteDesignId
            }

            if ($params.Count -ne 1)
            {
                Write-Verbose -Message 'Updating Hub Site properties'
                Set-PnPHubSite @params | Out-Null
            }

            if ($this.GetBoundParameters().ContainsKey('AllowedToJoin') -eq $true)
            {
                $groups = Get-MgGroup -All
                $regex = "^[a-zA-Z0-9.!£#$%&'^_`{}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$"

                Write-Verbose -Message 'Validating AllowedToJoin principals'
                foreach ($principal in $this.AllowedToJoin)
                {
                    Write-Verbose -Message "Processing $principal"
                    if ($principal -notmatch $regex)
                    {
                        $group = $groups | Where-Object -FilterScript {
                            $_.DisplayName -eq $principal
                        }

                        if ($group.Count -ne 1)
                        {
                            throw "Error for principal $principal. Number of occurences: $($group.Count)"
                        }
                    }
                }
                Grant-PnPHubSiteRights -Identity $site.Url `
                    -Principals $this.AllowedToJoin | Out-Null
            }
        }
        elseif ($this.Ensure -eq 'Present' -and $currentValues.Ensure -eq 'Present')
        {
            Write-Verbose -Message 'Updating Hub Site settings'
            $params = @{
                Identity = $site.Url
            }

            if ($this.GetBoundParameters().ContainsKey('Title') -eq $true -and
                $currentValues.Title -ne $this.Title)
            {
                $params.Title = $this.Title
            }

            if ($this.GetBoundParameters().ContainsKey('Description') -eq $true -and
                $currentValues.Description -ne $this.Description)
            {
                $params.Description = $this.Description
            }

            if ($this.GetBoundParameters().ContainsKey('LogoUrl') -eq $true -and
                $currentValues.LogoUrl -ne $this.LogoUrl)
            {
                $params.LogoUrl = $this.LogoUrl
            }

            if ($this.GetBoundParameters().ContainsKey('RequiresJoinApproval') -eq $true -and
                $currentValues.RequiresJoinApproval -ne $this.RequiresJoinApproval)
            {
                $params.RequiresJoinApproval = $this.RequiresJoinApproval
            }

            if ($this.GetBoundParameters().ContainsKey('SiteDesignId') -eq $true -and
                $currentValues.SiteDesignId -ne $this.SiteDesignId)
            {
                $params.SiteDesignId = $this.SiteDesignId
            }

            if ($params.Count -ne 1)
            {
                Write-Verbose -Message 'Updating Hub Site properties'
                Set-PnPHubSite @params | Out-Null
            }

            if ($this.GetBoundParameters().ContainsKey('AllowedToJoin') -eq $true)
            {
                if ($null -eq $currentValues.AllowedToJoin)
                {
                    $differences = Compare-Object -ReferenceObject $this.AllowedToJoin -DifferenceObject @()
                }
                else
                {
                    $differences = Compare-Object -ReferenceObject $this.AllowedToJoin -DifferenceObject $currentValues.AllowedToJoin
                }

                if ($null -ne $differences)
                {
                    $groups = Get-MgGroup -All
                    $regex = "^[a-zA-Z0-9.!£#$%&'^_`{}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$"

                    Write-Verbose -Message 'Updating Hub Site permissions'
                    foreach ($item in $differences)
                    {
                        if ($item.SideIndicator -eq '<=')
                        {
                            Write-Verbose -Message 'Validating AllowedToJoin principals'
                            foreach ($principal in $this.AllowedToJoin)
                            {
                                Write-Verbose -Message "Processing $principal"
                                if ($principal -notmatch $regex)
                                {
                                    $group = $groups | Where-Object -FilterScript {
                                        $_.DisplayName -eq $principal
                                    }

                                    if ($group.Count -ne 1)
                                    {
                                        throw "Error for principal $principal. Number of occurences: $($group.Count)"
                                    }
                                }
                            }
                            Grant-PnPHubSiteRights -Identity $site.Url `
                                -Principals $item.InputObject | Out-Null
                        }
                        else
                        {
                            Revoke-PnPHubSiteRights -Identity $site.Url `
                                -Principals $item.InputObject | Out-Null
                        }
                    }
                }
            }
        }
        else
        {
            # Remove hub site
            Unregister-PnPHubSite -Site $site.Url
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
            $ConnectionMode = $this.Connect('PnP')

            #Ensure the proper dependencies are installed in the current environment.
            Confirm-M365DSCDependencies

            #region Telemetry
            $this.AddTelemetry('Export')
            #endregion

            [array]$hubSites = Get-PnPHubSite -ErrorAction Stop

            $i = 1
            if ($hubSites.Length -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }

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
            foreach ($hub in $hubSites)
            {
                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }

                Write-M365DSCHost -Message "    [$i/$($hubSites.Length)] $($hub.SiteUrl)" -DeferWrite

                $Params = @{
                    Url                   = $hub.SiteUrl
                    Credential            = $this.Credential
                    ApplicationId         = $this.ApplicationId
                    TenantId              = $this.TenantId
                    ApplicationSecret     = $this.ApplicationSecret
                    CertificateThumbprint = $this.CertificateThumbprint
                    CertificatePassword   = $this.CertificatePassword
                    CertificatePath       = $this.CertificatePath
                    ManagedIdentity       = $this.ManagedIdentity
                    AccessTokens          = $this.AccessTokens
                }

                $this.ExportedInstance = $hub
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
                    $currentDSCBlock = $currentDSCBlock -ireplace [regex]::Escape('https://' + $principal + '.sharepoint.com/'), "https://`$(`$OrganizationName.Split('.')[0]).sharepoint.com/"
                    $currentDSCBlock = $currentDSCBlock -ireplace [regex]::Escape('@' + $organization), "@`$(`$OrganizationName)"
                }
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

    hidden [SPOHubSite] AsResult([System.Object] $Values)
    {
        if ($Values -is [SPOHubSite])
        {
            return $Values
        }

        $result = [SPOHubSite]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
