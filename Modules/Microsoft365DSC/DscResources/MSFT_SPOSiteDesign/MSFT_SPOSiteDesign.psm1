using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class SPOSiteDesign : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The title of the site design.')]
    [System.String] $Title

    [DscProperty()]
    [System.ComponentModel.Description('The names of the site design scripts.')]
    [System.String[]] $SiteScriptNames

    [DscProperty()]
    [System.ComponentModel.Description('Web template to which the site design is applied to when invoked.')]
    [ValidateSet('CommunicationSite', 'TeamSite', 'GrouplessTeamSite')]
    [System.String] $WebTemplate

    [DscProperty()]
    [System.ComponentModel.Description('Description of site design.')]
    [System.String] $Description

    [DscProperty()]
    [System.ComponentModel.Description('Is site design applied by default to web templates.')]
    [System.Nullable[System.Boolean]] $IsDefault

    [DscProperty()]
    [System.ComponentModel.Description('Site design alternate preview image text.')]
    [System.String] $PreviewImageAltText

    [DscProperty()]
    [System.ComponentModel.Description('Site design preview image url.')]
    [System.String] $PreviewImageUrl

    [DscProperty()]
    [System.ComponentModel.Description('Site design version number.')]
    [System.Nullable[System.UInt32]] $Version

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

    [SPOSiteDesign] Get()
    {
        $nullReturn = $null
        if ($this.RequiresPowerShellCore())
        {
            $remote = [SPOSiteDesign]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration for SPO SiteDesign for $($this.Title)"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.Title -ne $this.Title)
            {
                $null = $this.Connect('PNP')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullReturn = $this.GetBoundParameters()
                $nullReturn.Ensure = 'Absent'

                Write-Verbose -Message "Getting Site Design for $($this.Title)"
                $siteDesign = Get-PnPSiteDesign -Identity $this.Title -ErrorAction SilentlyContinue
            }
            else
            {
                $siteDesign = $this.ExportedInstance
            }

            if ($null -eq $siteDesign)
            {
                Write-Verbose -Message "No Site Design found for $($this.Title)"
                return $this.AsResult($nullReturn)
            }

            $scriptTitles = @()
            foreach ($scriptId in $siteDesign.SiteScriptIds)
            {
                $siteScript = Get-PnPSiteScript -Identity $scriptId -ErrorAction SilentlyContinue

                if ($null -ne $siteScript)
                {
                    $scriptTitles += $siteScript.Title
                }
            }
            ## Todo need to see if we can get this somehow from PNP module instead of hard coded in script
            ## https://github.com/SharePoint/PnP-PowerShell/blob/master/Commands/Enums/SiteWebTemplate.cs
            $webtemp = $null
            if ($siteDesign.WebTemplate -eq '64')
            {
                $webtemp = 'TeamSite'
            }
            elseif ($siteDesign.WebTemplate -eq '1')
            {
                $webtemp = 'GrouplessTeamSite'
            }
            else
            {
                $webtemp = 'CommunicationSite'
            }

            return $this.AsResult(@{
                Title                 = $siteDesign.Title
                SiteScriptNames       = $scriptTitles
                WebTemplate           = $webtemp
                IsDefault             = $siteDesign.IsDefault
                Description           = $siteDesign.Description
                PreviewImageAltText   = $siteDesign.PreviewImageAltText
                PreviewImageUrl       = $siteDesign.PreviewImageUrl
                Version               = $siteDesign.Version
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

        Write-Verbose -Message "Setting configuration for SPO SiteDesign for $($this.Title)"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $curSiteDesign = $this.Get().ToHashtable()

        # Get list of site script names
        $scriptIds = @()
        foreach ($siteScriptName in $this.SiteScriptNames)
        {
            $siteScript = Get-PnPSiteScript | Where-Object -FilterScript { $_.Title -eq $siteScriptName }
            $scriptIds += $siteScript.Id
        }

        $CurrentParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()
        $CurrentParameters.Remove('SiteScriptNames') | Out-Null
        $CurrentParameters.Add('SiteScriptIds', $scriptIds)

        if ($curSiteDesign.Ensure -eq 'Absent' -and 'Present' -eq $this.Ensure )
        {
            $CurrentParameters.Remove('Version')
            Write-Verbose -Message "Adding new site design $($this.Title)"
            Add-PnPSiteDesign @CurrentParameters
        }
        elseif (($curSiteDesign.Ensure -eq 'Present' -and 'Present' -eq $this.Ensure))
        {
            $siteDesign = Get-PnPSiteDesign -Identity $this.Title -ErrorAction SilentlyContinue
            if ($null -ne $siteDesign)
            {
                Write-Verbose -Message "Updating current site design $($this.Title)"
                Set-PnPSiteDesign -Identity $siteDesign.Id @CurrentParameters
            }
        }
        elseif (($this.Ensure -eq 'Absent' -and $curSiteDesign.Ensure -eq 'Present'))
        {
            $siteDesign = Get-PnPSiteDesign -Identity $this.Title -ErrorAction SilentlyContinue
            if ($null -ne $siteDesign)
            {
                Write-Verbose -Message "Removing site design $($this.Title)"
                Remove-PnPSiteDesign -Identity $siteDesign.Id -Force
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

            $dscContent = [System.Text.StringBuilder]::new()
            $i = 1
            [array]$designs = Get-PnPSiteDesign -ErrorAction Stop

            if ($designs.Length -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }

            foreach ($design in $designs)
            {
                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }

                Write-M365DSCHost -Message "    |---[$i/$($designs.Length)] $($design.Title)" -DeferWrite
                $Params = @{
                    Title                 = $design.Title
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

                $this.ExportedInstance = $design
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

    hidden [SPOSiteDesign] AsResult([System.Object] $Values)
    {
        if ($Values -is [SPOSiteDesign])
        {
            return $Values
        }

        $result = [SPOSiteDesign]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
