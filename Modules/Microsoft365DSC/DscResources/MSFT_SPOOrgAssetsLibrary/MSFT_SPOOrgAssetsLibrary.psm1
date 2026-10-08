using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class SPOOrgAssetsLibrary : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('Indicates the absolute URL of the library to be designated as a central location for organization assets.')]
    [System.String] $LibraryUrl

    [DscProperty()]
    [System.ComponentModel.Description('Specifies the CDN type. The valid values are public or private.')]
    [ValidateSet('Public', 'Private')]
    [System.String] $CdnType

    [DscProperty()]
    [System.ComponentModel.Description('Indicates the absolute URL of the library to be designated as a central location for organization Indicates the URL of the background image used when the library is publicly displayed. If no thumbnail URL is indicated, the card will have a gray background.')]
    [System.String] $ThumbnailUrl

    [DscProperty()]
    [System.ComponentModel.Description('Specify if the SPO Org Assets library should exist or not.')]
    [ValidateSet('Present', 'Absent')]
    [System.String] $Ensure

    [DscProperty()]
    [System.ComponentModel.Description('Credentials of the SharePoint Admin')]
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

    [SPOOrgAssetsLibrary] Get()
    {
        $cdn = $null
        $orgAsset = $null
        $orgthumbnailUrl = $null
        if ($this.RequiresPowerShellCore())
        {
            $remote = [SPOOrgAssetsLibrary]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message 'Getting configuration of SPO Org Assets Library'

        try
        {
            $ConnectionMode = $this.Connect('PnP')

            if ($ConnectionMode -eq 'Credentials')
            {
                $tenantName = Get-M365TenantName -Credential $this.Credential
            }
            else
            {
                $tenantName = $this.TenantId.Split('.')[0]
            }
            $orgLibraryUrl = "https://$tenantName.sharepoint.com/$($this.ExportedInstance.libraryurl.DecodedUrl)"

            if (-not $this.ExportedInstance -or $orgLibraryUrl -ne $this.LibraryUrl)
            {
                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullReturn = $this.GetBoundParameters()
                $nullReturn.Ensure = 'Absent'

                $orgAssets = Get-PnPOrgAssetsLibrary -ErrorAction SilentlyContinue

                $cdn = $null
                if ($this.CdnType -eq 'Public')
                {
                    if ((Get-PnPTenantCdnEnabled -CdnType $this.CdnType).Value)
                    {
                        $cdn = 'Public'
                    }
                }

                if ($this.CdnType -eq 'Private')
                {
                    if ((Get-PnPTenantCdnEnabled -CdnType $this.CdnType).Value)
                    {
                        $cdn = 'Private'
                    }
                }

                if ($null -eq $orgAssets)
                {
                    return $this.AsResult($nullReturn)
                }

                foreach ($asset in $orgAssets)
                {
                    $orgLibraryUrl = "https://$tenantName.sharepoint.com/$($asset.libraryurl.DecodedUrl)"
                    if ($orgLibraryUrl -eq $this.LibraryUrl)
                    {
                        $orgAsset = $asset
                        break
                    }
                }

                if ($null -eq $orgAsset)
                {
                    return $this.AsResult($nullReturn)
                }
            }
            else
            {
                $orgAsset = $this.ExportedInstance
            }

            Write-Verbose -Message "Found existing SharePoint Org Site Assets for $($this.LibraryUrl)"
            if ($null -ne $orgAsset.ThumbnailUrl.DecodedUrl)
            {
                $orgthumbnailUrl = "https://$tenantName.sharepoint.com/$($orgAsset.LibraryUrl.decodedurl.Substring(0,$orgAsset.LibraryUrl.decodedurl.LastIndexOf('/')))/$($orgAsset.ThumbnailUrl.decodedurl)"
            }

            $result = @{
                LibraryUrl            = $orgLibraryUrl
                ThumbnailUrl          = $orgthumbnailUrl
                CdnType               = $cdn
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

        Write-Verbose -Message 'Setting configuration of SharePoint Org Site Assets'

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $currentOrgSiteAsset = $this.Get().ToHashtable()
        $currentParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()

        if ($this.Ensure -eq 'Present')
        {
            $cdn = $null
            if ($this.CdnType -eq 'Public')
            {
                if ((Get-PnPTenantCdnEnabled -CdnType $this.CdnType).Value)
                {
                    $cdn = 'Public'
                }
            }

            if ($this.CdnType -eq 'Private')
            {
                if ((Get-PnPTenantCdnEnabled -CdnType $this.CdnType).Value)
                {
                    $cdn = 'Private'
                }
            }

            if ($null -eq $cdn)
            {
                throw "Tenant $($this.CdnType) CDN must be configured before setting site organization Library"
            }
        }

        if ($this.Ensure -eq 'Present' -and $currentOrgSiteAsset.Ensure -eq 'Present')
        {
            Write-Verbose -Message 'Removing existing Org Asset Library'
            ## No set so remove / add
            Remove-PnPOrgAssetsLibrary -LibraryUrl $currentOrgSiteAsset.LibraryUrl
            ### add slight delay fails if you immediately try to add
            Write-Verbose -Message 'Waiting 30 seconds'
            Start-Sleep -Seconds 30
            Write-Verbose -Message 'Adding Org Asset Library'
            Add-PnPOrgAssetsLibrary @currentParameters
        }
        elseif ($this.Ensure -eq 'Present' -and $currentOrgSiteAsset.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Adding Org Asset Library $($currentParameters.LibraryUrl)"
            try
            {
                Add-PnPOrgAssetsLibrary @currentParameters -ErrorAction Stop
            }
            catch
            {
                Write-Warning -Message "Exception: $($_.Exception)"
                if ($_ -notlike '*This library is already an organization assets library.*')
                {
                    throw $_
                }
            }
        }
        elseif ($this.Ensure -eq 'Absent' -and $currentOrgSiteAsset.Ensure -eq 'Present')
        {
            Write-Verbose -Message 'Removing existing Org Asset Library'
            Remove-PnPOrgAssetsLibrary -LibraryUrl $currentOrgSiteAsset.LibraryUrl

            $originUrl = [System.Uri]::UnescapeDataString(([System.Uri]$currentOrgSiteAsset.LibraryUrl).AbsolutePath).Trim('/')
            foreach ($cdnType in @('Public', 'Private'))
            {
                $origins = @(Get-PnPTenantCdnOrigin -CdnType $cdnType -ErrorAction SilentlyContinue) -replace '\s*\(configuration pending\)$', ''
                if ($origins -contains $originUrl)
                {
                    Write-Verbose -Message "Removing $cdnType CDN origin {$originUrl}"
                    Remove-PnPTenantCdnOrigin -OriginUrl $originUrl -CdnType $cdnType
                }
            }
        }
    }

    [bool] Test()
    {
        return ([M365DSCResourceBase] $this).Test()
    }

    [string] Export()
    {
        $tenantName = $null
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

            [array]$orgAssets = Get-PnPOrgAssetsLibrary -ErrorAction Stop
            $i = 1
            $dscContent = [System.Text.StringBuilder]::new()

            if ($orgAssets.Length -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }
            if ($null -ne $orgAssets)
            {
                foreach ($orgAssetLib in $orgAssets)
                {
                    if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                    {
                        $Global:M365DSCExportResourceInstancesCount++
                    }

                    Write-M365DSCHost -Message "    [$i/$($orgAssets.Length)] $($orgAssetLib.libraryurl.DecodedUrl)" -DeferWrite
                    $Params = @{
                        Credential            = $this.Credential
                        LibraryUrl            = "https://$tenantName.sharepoint.com/$($orgAssetLib.libraryurl.DecodedUrl)"
                        ApplicationId         = $this.ApplicationId
                        TenantId              = $this.TenantId
                        CertificatePassword   = $this.CertificatePassword
                        CertificatePath       = $this.CertificatePath
                        CertificateThumbprint = $this.CertificateThumbprint
                        ManagedIdentity       = $this.ManagedIdentity
                        ApplicationSecret     = $this.ApplicationSecret
                        AccessTokens          = $this.AccessTokens
                    }

                    $this.ExportedInstance = $orgAssetLib
                    $Results = $this.GetForExport($Params)
                    $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                        -ConnectionMode $ConnectionMode `
                        -ModulePath $this.GetModulePath() `
                        -Results $Results `
                        -Credential $this.Credential
                    [void]$dscContent.Append($currentDSCBlock)
                    Save-M365DSCPartialExport -Content $currentDSCBlock `
                        -FileName $Global:PartialExportFileName
                    Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
                    $i++
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

    hidden [SPOOrgAssetsLibrary] AsResult([System.Object] $Values)
    {
        if ($Values -is [SPOOrgAssetsLibrary])
        {
            return $Values
        }

        $result = [SPOOrgAssetsLibrary]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
