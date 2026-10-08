using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class SPOSiteDesignRights : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The title of the site design')]
    [System.String] $SiteDesignTitle

    [DscProperty(Key)]
    [System.ComponentModel.Description('Rights to grant user principals on site design rights.')]
    [ValidateSet('View', 'None')]
    [System.String] $Rights

    [DscProperty()]
    [System.ComponentModel.Description('List of user principals with separated by commas to site design rights.')]
    [System.String[]] $UserPrincipals

    [DscProperty()]
    [System.ComponentModel.Description('Used to add or remove list of users from site design rights.')]
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

    [SPOSiteDesignRights] Get()
    {
        $nullReturn = $null
        if ($this.RequiresPowerShellCore())
        {
            $remote = [SPOSiteDesignRights]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration for SPO SiteDesignRights for $($this.SiteDesignTitle)"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.Title -ne $this.SiteDesignTitle)
            {
                $null = $this.Connect('PNP')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullReturn = $this.GetBoundParameters()
                $nullReturn.Ensure = 'Absent'

                Write-Verbose -Message "Getting Site Design Rights for $($this.SiteDesignTitle)"
                $siteDesign = Get-PnPSiteDesign -Identity $this.SiteDesignTitle -ErrorAction SilentlyContinue
                if ($null -eq $siteDesign)
                {
                    Write-Verbose -Message "Site Design with title $($this.SiteDesignTitle) doesn't exist in tenant"
                    return $this.AsResult($nullReturn)
                }
            }
            else
            {
                $siteDesign = $this.ExportedInstance
            }

            Write-Verbose -Message "Site Design ID is $($siteDesign.Id)"

            $siteDesignRights = Get-PnPSiteDesignRights -Identity $siteDesign.Id -ErrorAction SilentlyContinue | `
                    Where-Object -FilterScript { $_.Rights -eq $this.Rights }

            if ($null -eq $siteDesignRights)
            {
                Write-Verbose -Message "No Site Design Rights exist for site design $($this.SiteDesignTitle)."
                return $this.AsResult($nullReturn)
            }

            $curUserPrincipals = @()
            foreach ($siteDesignRight in $siteDesignRights)
            {
                $curUserPrincipals += $siteDesignRight.PrincipalName.Split('|')[2]
            }

            Write-Verbose -Message "Site Design Rights User Principals = $($curUserPrincipals)"
            return $this.AsResult(@{
                SiteDesignTitle       = $this.SiteDesignTitle
                UserPrincipals        = $curUserPrincipals
                Rights                = $this.Rights
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

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $null = $this.Connect('PNP')

        $cursiteDesign = Get-PnPSiteDesign -Identity $this.SiteDesignTitle -ErrorAction SilentlyContinue
        if ($null -eq $cursiteDesign)
        {
            if ($this.Ensure -eq 'Absent')
            {
                return
            }

            throw "Site Design with title $($this.SiteDesignTitle) doesn't exist in tenant"
        }

        $currentSiteDesignRights = $this.Get().ToHashtable()
        $CurrentParameters = $this.GetBoundParameters()

        if ($this.Ensure -eq 'Absent')
        {
            if ($currentSiteDesignRights.Ensure -eq 'Present')
            {
                Write-Verbose -Message "Revoking SiteDesign rights on $($currentSiteDesignRights.UserPrincipals) for site design $($this.SiteDesignTitle)"
                Revoke-PnPSiteDesignRights -Identity $cursiteDesign.Id -Principals $currentSiteDesignRights.UserPrincipals
            }
            return
        }

        if ($currentSiteDesignRights.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Granting SiteDesign rights on site design $($this.SiteDesignTitle)"
            Grant-PnPSiteDesignRights -Identity $cursiteDesign.Id -Principals $this.UserPrincipals -Rights $this.Rights
            return
        }

        $difference = Compare-Object -ReferenceObject @($currentSiteDesignRights.UserPrincipals) -DifferenceObject @($CurrentParameters.UserPrincipals)
        $principalsToRemove = @()
        $principalsToAdd = @()
        foreach ($delta in $difference)
        {
            if ($delta.SideIndicator -eq '<=')
            {
                $principalsToRemove += $delta.InputObject
            }
            elseif ($delta.SideIndicator -eq '=>')
            {
                $principalsToAdd += $delta.InputObject
            }
        }

        if ($principalsToAdd.Count -gt 0)
        {
            Write-Verbose -Message "Granting SiteDesign rights on site design $($this.SiteDesignTitle)"
            Grant-PnPSiteDesignRights -Identity $cursiteDesign.Id -Principals $principalsToAdd -Rights $this.Rights
        }

        if ($principalsToRemove.Count -gt 0)
        {
            Write-Verbose -Message "Revoking SiteDesign rights on $principalsToRemove for site design $($this.SiteDesignTitle) with Id $($cursiteDesign.Id)"
            Revoke-PnPSiteDesignRights -Identity $cursiteDesign.Id -Principals $principalsToRemove
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

            [array]$siteDesigns = Get-PnPSiteDesign -ErrorAction Stop

            $dscContent = [System.Text.StringBuilder]::new()
            $i = 1
            if ($siteDesigns.Length -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }
            foreach ($siteDesign in $siteDesigns)
            {
                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }

                Write-M365DSCHost -Message "    |---[$i/$($siteDesigns.Count)] $($siteDesign.Title)" -DeferWrite

                $Params = @{
                    SiteDesignTitle       = $siteDesign.Title
                    Rights                = 'View'
                    ApplicationId         = $this.ApplicationId
                    TenantId              = $this.TenantId
                    ApplicationSecret     = $this.ApplicationSecret
                    CertificateThumbprint = $this.CertificateThumbprint
                    CertificatePath       = $this.CertificatePath
                    CertificatePassword   = $this.CertificatePassword
                    ManagedIdentity       = $this.ManagedIdentity
                    Credential            = $this.Credential
                    AccessTokens          = $this.AccessTokens
                }

                $this.ExportedInstance = $siteDesign
                $Results = $this.GetForExport($Params)
                if ($Results.Ensure -eq 'Present')
                {
                    $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                        -ConnectionMode $ConnectionMode `
                        -ModulePath $this.GetModulePath() `
                        -Results $Results `
                        -Credential $this.Credential
                    [void]$dscContent.Append($currentDSCBlock)

                    Save-M365DSCPartialExport -Content $currentDSCBlock `
                        -FileName $Global:PartialExportFileName
                }

                $Params = @{
                    SiteDesignTitle       = $siteDesign.Title
                    Rights                = 'None'
                    ApplicationId         = $this.ApplicationId
                    TenantId              = $this.TenantId
                    ApplicationSecret     = $this.ApplicationSecret
                    CertificatePassword   = $this.CertificatePassword
                    CertificatePath       = $this.CertificatePath
                    CertificateThumbprint = $this.CertificateThumbprint
                    Credential            = $this.Credential
                    ManagedIdentity       = $this.ManagedIdentity
                    AccessTokens          = $this.AccessTokens
                }
                $Results = $this.GetForExport($Params)
                if ($Results.Ensure -eq 'Present')
                {

                    $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                        -ConnectionMode $ConnectionMode `
                        -ModulePath $this.GetModulePath() `
                        -Results $Results `
                        -Credential $this.Credential
                    [void]$dscContent.Append($currentDSCBlock)

                    Save-M365DSCPartialExport -Content $currentDSCBlock `
                        -FileName $Global:PartialExportFileName
                }
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

    [System.Collections.Hashtable] GetCompareParameters()
    {
        return @{
            ExcludedProperties = @('SiteDesignTitle')
        }
    }

    hidden [SPOSiteDesignRights] AsResult([System.Object] $Values)
    {
        if ($Values -is [SPOSiteDesignRights])
        {
            return $Values
        }

        $result = [SPOSiteDesignRights]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
