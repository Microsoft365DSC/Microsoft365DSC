using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class SPOApp : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The name of the App.')]
    [System.String] $Identity

    [DscProperty(Key)]
    [System.ComponentModel.Description('The path the the app package on disk.')]
    [System.String] $Path

    [DscProperty()]
    [System.ComponentModel.Description('This will deploy/trust an app into the app catalog.')]
    [System.Nullable[System.Boolean]] $Publish

    [DscProperty()]
    [System.ComponentModel.Description('Overwrites the existing app package if it already exists.')]
    [System.Nullable[System.Boolean]] $Overwrite

    [DscProperty()]
    [System.ComponentModel.Description('Present ensures the site collection exists, absent ensures it is removed')]
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

    [SPOApp] Get()
    {
        $nullReturn = $null
        if ($this.RequiresPowerShellCore())
        {
            $remote = [SPOApp]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration for app $($this.Identity)"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.Title -ne $this.Identity)
            {
                $null = $this.Connect('PnP')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullReturn = $this.GetBoundParameters()
                $nullReturn.Ensure = 'Absent'

                $app = Get-PnPApp -Identity $this.Identity -ErrorAction SilentlyContinue
            }
            else
            {
                $app = $this.ExportedInstance
            }

            if ($null -eq $app)
            {
                Write-Verbose -Message "The specified app wasn't found."
                return $this.AsResult($nullReturn)
            }

            return $this.AsResult(@{
                Identity              = $app.Title
                Path                  = $this.Path
                Publish               = $app.Deployed
                Overwrite             = $this.Overwrite
                Ensure                = 'Present'
                ApplicationId         = $this.ApplicationId
                TenantId              = $this.TenantId
                ApplicationSecret     = $this.ApplicationSecret
                CertificateThumbprint = $this.CertificateThumbprint
                CertificatePath       = $this.CertificatePath
                CertificatePassword   = $this.CertificatePassword
                ManagedIdentity       = $this.ManagedIdentity
                Credential            = $this.Credential
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

        Write-Verbose -Message "Setting configuration for app $($this.Identity)"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $currentApp = $this.Get().ToHashtable()

        if ($this.Ensure -eq 'Present' -and $currentApp.Ensure -eq 'Present' -and $this.Overwrite -eq $false)
        {
            throw "The app already exists in the Catalog. To overwrite it, please make sure you set the Overwrite property to 'true'."
        }
        elseif ($this.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Adding app instance $($this.Identity)"
            Add-PnPApp -Path $this.Path -Overwrite:$true -Force
        }
        elseif ($this.Ensure -eq 'Absent' -and $currentApp.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Removing app instance $($this.Identity)"
            Remove-PnPApp -Identity $this.Identity -Force
        }
    }

    [bool] Test()
    {
        return ([M365DSCResourceBase] $this).Test()
    }

    [string] Export()
    {
        $dscContent = $null
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

            $tenantAppCatalogUrl = Get-PnPTenantAppCatalogUrl -ErrorAction Stop

            if (-not [string]::IsNullOrEmpty($tenantAppCatalogUrl))
            {
                $ConnectionMode = $this.Connect('PnP', $tenantAppCatalogUrl)

                if ($ConnectionMode -eq 'Credentials')
                {
                    [array]$filesToDownload = Get-AllSPOPackages -Credential $this.Credential
                }
                else
                {
                    # mlh
                    [array]$filesToDownload = Get-AllSPOPackages -ApplicationId $this.ApplicationId -CertificateThumbprint $this.CertificateThumbprint `
                        -CertificatePassword $this.CertificatePassword -TenantId $this.TenantId -CertificatePath $this.CertificatePath -ManagedIdentity:$this.ManagedIdentity
                }
                $tenantAppCatalogPath = $tenantAppCatalogUrl.Replace('https://', '')
                $tenantAppCatalogPath = $tenantAppCatalogPath.Replace($tenantAppCatalogPath.Split('/')[0], '')

                $dscContent = [System.Text.StringBuilder]::new()
                $i = 1

                if ($filesToDownload.Count -eq 0)
                {
                    Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
                }
                else
                {
                    Write-M365DSCHost -Message "`r`n" -DeferWrite
                }
                foreach ($file in $filesToDownload)
                {
                    Write-M365DSCHost -Message "    |---[$i/$($filesToDownload.Count)] $($file.Name)" -DeferWrite

                    $identityValue = $file.Name.ToLower().Replace('.app', '').Replace('.sppkg', '')
                    $app = Get-PnPApp -Identity $identityValue -ErrorAction SilentlyContinue

                    if ($null -eq $app)
                    {
                        $identityValue = $file.Title
                        $app = Get-PnPApp -Identity $file.Title -ErrorAction SilentlyContinue
                    }
                    if ($null -ne $app)
                    {
                        if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                        {
                            $Global:M365DSCExportResourceInstancesCount++
                        }

                        $Params = @{
                            Identity              = $identityValue
                            Path                  = ("`$PSScriptRoot\" + $file.Name)
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

                        $this.ExportedInstance = $app
                        $Results = $this.GetForExport($Params)
                        $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                            -ConnectionMode $ConnectionMode `
                            -ModulePath $this.GetModulePath() `
                            -Results $Results `
                            -Credential $this.Credential
                        [void]$dscContent.Append($currentDSCBlock)
                        Save-M365DSCPartialExport -Content $currentDSCBlock `
                            -FileName $Global:PartialExportFileName
                    }
                    $i++
                    Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
                }

                foreach ($file in $filesToDownload)
                {
                    $appInstanceUrl = $tenantAppCatalogPath + '/AppCatalog/' + $file.Name
                    $appFileName = $appInstanceUrl.Split('/')[$appInstanceUrl.Split('/').Length - 1]
                    Get-PnPFile -Url $appInstanceUrl -Path $env:TEMP -Filename $appFileName -AsFile -Force | Out-Null
                }
            }
            else
            {
                Write-Verbose -Message '    * App Catalog is not configured on tenant. Cannot extract information about SharePoint apps.'
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
            ExcludedProperties = @('Path', 'Publish', 'Overwrite')
        }
    }

    hidden [SPOApp] AsResult([System.Object] $Values)
    {
        if ($Values -is [SPOApp])
        {
            return $Values
        }

        $result = [SPOApp]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
