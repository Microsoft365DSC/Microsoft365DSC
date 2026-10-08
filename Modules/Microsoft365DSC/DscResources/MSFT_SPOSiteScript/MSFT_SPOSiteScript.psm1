using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class SPOSiteScript : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The title of the site script.')]
    [System.String] $Title

    [DscProperty()]
    [System.ComponentModel.Description('ID of the site Script')]
    [System.String] $Identity

    [DscProperty()]
    [System.ComponentModel.Description('The description of the site script.')]
    [System.String] $Description

    [DscProperty()]
    [System.ComponentModel.Description('A JSON string containing the site script.')]
    [System.String] $Content

    [DscProperty()]
    [System.ComponentModel.Description('Present ensures the site script exists, absent ensures it is removed')]
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

    [SPOSiteScript] Get()
    {
        $SiteScript = $null
        if ($this.RequiresPowerShellCore())
        {
            $remote = [SPOSiteScript]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting Site Script: $($this.Title)"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.Id -ne $this.Identity)
            {
                $null = $this.Connect('PnP')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullReturn = $this.GetBoundParameters()
                $nullReturn.Ensure = 'Absent'

                Write-Verbose -Message "Getting the SPO Site Script with Identity {$($this.Identity)} and Title {$($this.Title)}"

                if (-not [System.String]::IsNullOrEmpty($this.Identity))
                {
                    $SiteScript = Get-PnPSiteScript -Identity $this.Identity -ErrorAction SilentlyContinue
                }

                if ($null -eq $SiteScript)
                {
                    $SiteScript = Get-PnPSiteScript -ErrorAction SilentlyContinue | Where-Object -FilterScript { $_.Title -eq $this.Title } | Select-Object -First 1

                    # No script was returned
                    if ($null -eq $SiteScript)
                    {
                        Write-Verbose -Message "No Site Script with the Title, {$($this.Title)}, was found."
                        return $this.AsResult($nullReturn)
                    }
                    else
                    {
                        # get site script *with* content
                        $SiteScript = Get-PnPSiteScript -Identity $SiteScript.Id
                    }
                }
            }
            else
            {
                $SiteScript = Get-PnPSiteScript -Identity $this.ExportedInstance.Id -ErrorAction SilentlyContinue
            }
            ##### End of Check

            return $this.AsResult(@{
                Identity              = $SiteScript.Id
                Title                 = $SiteScript.Title
                Description           = $SiteScript.Description
                Content               = $SiteScript.Content
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
        $UpdateParams = $null
        if ($this.RequiresPowerShellCore())
        {
            $null = $this.InvokeInPowerShellCore('Set')
            return
        }

        Write-Verbose -Message "Setting Site Script: $($this.Title)"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        # region Telemetry
        $CurrentValues = $this.Get().ToHashtable()
        $CurrentParameters = Remove-M365DSCAuthenticationParameter $this.GetBoundParameters()
        # end region

        if ($this.Ensure -eq 'Present' -and $CurrentValues.Ensure -eq 'Absent')
        {
            # Splatting
            $CreationParams = @{
                Title       = $this.Title
                Content     = $this.Content
                Description = $this.Description
            }

            # Adding the Site Script Again.
            Write-Verbose -Message "Site Script, {$($this.Title)}, doesn't exist. Creating it."
            $newSiteScript = Add-PnPSiteScript @CreationParams

            # let's make sure the Site Script gets added
            $siteScript = $null
            $circuitBreaker = 0
            do
            {
                Write-Verbose -Message 'Waiting for another 3 seconds for Site Script to be ready.'
                Start-Sleep -Seconds 3
                try
                {
                    $siteScript = Get-PnPSiteScript -Identity $newSiteScript.Id -ErrorAction Stop
                }
                catch
                {
                    $siteScript = $null
                }
                $circuitBreaker++
            } while ($null -eq $siteScript -and $circuitBreaker -lt 20)

            Write-Verbose -Message "Site Script, {$($this.Title)}, has been successfully created."
        }
        elseif ($this.Ensure -eq 'Absent' -and $CurrentValues.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Removing Site Script {$($this.Title)}"
            try
            {
                # The Site Script exists and it shouldn't
                [Array]$SiteScript = Get-PnPSiteScript | Where-Object -FilterScript { $_.Title -eq $this.Title } -ErrorAction SilentlyContinue

                ##### Check to see if more than one site script is returned
                if ($SiteScript.Count -gt 1)
                {
                    $SiteScript = Get-PnPSiteScript -Identity $SiteScript[0].Id
                }
                ##### End of Check
            }
            catch
            {
                if ($Error[0].Exception.Message -eq 'Site Script Not Found')
                {
                    $Message = "The Site Script, $($this.Title), does not exist."
                    $this.LogError($_, $Message)
                    throw $Message
                }
            }
            try
            {
                Remove-PnPSiteScript -Identity $sitescript.Id -Force -ErrorAction Stop
            }
            catch
            {
                $this.LogError($_, 'Error removing Site Script:')

                throw
            }
        }
        if ($this.Ensure -ne 'Absent')
        {
            Write-Verbose -Message "Site Script, {$($this.Title)} already exists, updating its settings"

            try
            {
                # The Site Script exists and it shouldn't
                [Array]$SiteScripts = Get-PnPSiteScript | Where-Object -FilterScript { $_.Title -eq $this.Title } -ErrorAction SilentlyContinue

                ##### Check to see if more than one site script is returned
                if ($SiteScripts.Count -gt 0)
                {
                    #
                    #the only way to get the $content is to query the site again, but this time with the ID and not the Title like above
                    $UpdateParams = @{
                        Identity    = $SiteScripts[0].Id
                        Title       = $this.Title
                        Content     = $this.Content
                        Description = $this.Description
                    }
                }

                ##### End of Check
                if ($null -ne $UpdateParams)
                {
                    $UpdateParams = Remove-NullEntriesFromHashtable -Hash $UpdateParams
                    Set-PnPSiteScript @UpdateParams -ErrorAction Stop
                }
            }
            catch
            {
                $this.LogError($_, 'Error updating Site Script:')

                throw
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

            [array]$siteScripts = Get-PnPSiteScript -ErrorAction Stop

            if ($siteScripts.Length -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }
            foreach ($script in $siteScripts)
            {
                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }

                Write-M365DSCHost -Message "    [$i/$($siteScripts.Length)] $($script.Title)" -DeferWrite
                $params = @{
                    Identity              = $script.Id
                    Title                 = $script.Title
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

                $this.ExportedInstance = $script
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
            return $dscContent.ToString()
        }
        catch
        {
            $this.LogError($_, 'Error during Export:')

            throw
        }
    }

    hidden [SPOSiteScript] AsResult([System.Object] $Values)
    {
        if ($Values -is [SPOSiteScript])
        {
            return $Values
        }

        $result = [SPOSiteScript]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
