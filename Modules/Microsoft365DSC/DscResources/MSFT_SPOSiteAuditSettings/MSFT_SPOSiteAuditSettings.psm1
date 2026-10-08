using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class SPOSiteAuditSettings : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('URL of the site collection to configure.')]
    [System.String] $Url

    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('Audit flag for the site collection. Can be ''All'' or ''None''.')]
    [ValidateSet('All', 'None')]
    [System.String] $AuditFlags

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

    [SPOSiteAuditSettings] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [SPOSiteAuditSettings]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting SPOSiteAuditSettings for {$($this.Url)}"

        try
        {
            $null = $this.Connect('PNP', $this.Url)

            #Ensure the proper dependencies are installed in the current environment.
            Confirm-M365DSCDependencies

            #region Telemetry
            $this.AddTelemetry('Get')
            #endregion

            $auditSettings = Get-PnPAuditing -ErrorAction Stop
            $auditFlag = $auditSettings.AuditFlags
            if ($null -eq $auditFlag)
            {
                $auditFlag = 'None'
            }
            return $this.AsResult(@{
                Url                   = $this.Url
                AuditFlags            = $auditFlag
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

        Write-Verbose -Message "Setting Audit settings for {$($this.Url)}"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $null = $this.Connect('PNP', $this.Url)

        if ($this.AuditFlags -eq 'All')
        {
            Set-PnPAuditing -EnableAll
        }
        else
        {
            Set-PnPAuditing -DisableAll
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

            $sites = Get-PnPTenantSite -ErrorAction Stop

            $i = 1
            Write-M365DSCHost -Message "`r`n" -DeferWrite

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
            foreach ($site in $sites)
            {
                try
                {
                    if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                    {
                        $Global:M365DSCExportResourceInstancesCount++
                    }

                    Write-M365DSCHost -Message "    [$i/$($sites.Length)] Audit Settings for {$($site.Url)}" -DeferWrite

                    $Params = @{
                        Url                   = $site.Url
                        AuditFlags            = 'None'
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

                    $Results = $this.GetForExport($Params)
                    if ($Results -is [System.Collections.Hashtable] -and $Results.Count -gt 1)
                    {
                        if ([System.String]::IsNullOrEmpty($Results.AuditFlags))
                        {
                            $Results.AuditFlags = 'None'
                        }
                        $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                            -ConnectionMode $ConnectionMode `
                            -ModulePath $this.GetModulePath() `
                            -Results $Results `
                            -Credential $this.Credential

                        # Make the Url parameterized
                        if ($currentDSCBlock.ToLower().Contains($currentDSCBlock.ToLower()) -or `
                                $currentDSCBlock.ToLower().Contains($currentDSCBlock.ToLower()))
                        {
                            $currentDSCBlock = $currentDSCBlock -ireplace [regex]::Escape('https://' + $principal + '.sharepoint.com/'), "https://`$(`$OrganizationName.Split('.')[0]).sharepoint.com/"
                        }
                        [void]$dscContent.Append($currentDSCBlock)
                        Save-M365DSCPartialExport -Content $currentDSCBlock `
                            -FileName $Global:PartialExportFileName

                        Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
                    }
                    else
                    {
                        Write-M365DSCHost -Message $Global:M365DSCEmojiRedX -CommitWrite
                    }
                }
                catch
                {
                    Write-M365DSCHost -Message $Global:M365DSCEmojiRedX -CommitWrite

                    $this.LogError($_, 'Error during Export:')

                    Write-Verbose "There was an issue retrieving Audit Settings for $($this.Url)"
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

    [System.Collections.Hashtable] GetCompareParameters()
    {
        return @{
            ExcludedProperties = @('Url')
        }
    }

    hidden [SPOSiteAuditSettings] AsResult([System.Object] $Values)
    {
        if ($Values -is [SPOSiteAuditSettings])
        {
            return $Values
        }

        $result = [SPOSiteAuditSettings]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
