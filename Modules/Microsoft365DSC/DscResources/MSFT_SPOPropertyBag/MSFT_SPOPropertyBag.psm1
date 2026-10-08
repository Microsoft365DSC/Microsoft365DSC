using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class SPOPropertyBag : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('Url of the site where to configure the PropertyBag property.')]
    [System.String] $Url

    [DscProperty(Key)]
    [System.ComponentModel.Description('Key that should be configured.')]
    [System.String] $Key

    [DscProperty(Key)]
    [System.ComponentModel.Description('Value of the assigned key.')]
    [System.String] $Value

    [DscProperty()]
    [System.ComponentModel.Description('Specify if this policy should exist or not.')]
    [ValidateSet('Present', 'Absent')]
    [System.String] $Ensure

    [DscProperty()]
    [System.ComponentModel.Description('Credentials of the Global Admin')]
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

    [SPOPropertyBag] Get()
    {
        $property = $null
        $nullReturn = $null
        if ($this.RequiresPowerShellCore())
        {
            $remote = [SPOPropertyBag]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of SPOPropertyBag for $($this.Key)"

        try
        {
            if ($null -eq $this.ExportedInstance -or $this.ExportedInstance.Key -ne $this.Key)
            {
                $null = $this.Connect('PnP', $this.Url)

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullReturn = $this.GetBoundParameters()
                $nullReturn.Ensure = 'Absent'
                try
                {
                    Write-Verbose -Message "Obtaining all properties from the Get method for url {$($this.Url)}"
                    [array]$property = (Get-PnPPropertyBag -ErrorAction 'Stop' | Where-Object -Property Key -CEQ $this.Key).Value

                    Write-Verbose -Message 'Properties obtained correctly'
                }
                catch
                {
                    Write-Verbose "Credential or service principal specified does not have admin access to site {$($this.Url)}"
                    if ($_.Exception -like '*Unable to cast object of type*')
                    {
                        [array]$property = (Get-PnPPropertyBag | Where-Object -Property Key -CEQ $this.Key).Value
                    }
                    elseif ($_.Exception -like '*The underlying connection was closed*')
                    {
                        $null = $this.Connect('PnP', $this.Url)

                        Write-Verbose -Message "Obtaining all properties from the Get method for url {$($this.Url)}"
                        [array]$property = (Get-PnPPropertyBag -ErrorAction 'SilentlyContinue' | Where-Object -Property Key -CEQ $this.Key).Value
                    }
                    else
                    {
                        $this.LogError($_, "Couldn't get Property Bag for {$($this.Url)}")
                        Write-Verbose "Credential specified does not have admin access to site {$($this.Url)}"
                    }
                }
            }
            else
            {
                [array]$property = @($this.ExportedInstance.Value)
            }

            if ($property.Count -eq 0)
            {
                Write-Verbose -Message "SPOPropertyBag $($this.Key) does not exist at {$($this.Url)}."
                return $this.AsResult($nullReturn)
            }
            else
            {
                Write-Verbose "Found existing SPOPropertyBag Key $($this.Key) at {$($this.Url)}"
                $result = @{
                    Ensure                = 'Present'
                    Url                   = $this.Url
                    Key                   = $this.Key
                    Value                 = $property[0]
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
        }
        catch
        {
            $this.LogError($_, 'Error retrieving data:')

            throw
        }
    }

    [void] Set()
    {
        $CurrentPolicy = $null
        if ($this.RequiresPowerShellCore())
        {
            $null = $this.InvokeInPowerShellCore('Set')
            return
        }

        Write-Verbose -Message "Setting configuration of SPOPropertyBag property for $($this.Key) at {$($this.Url)}"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $CurrentPolicy = $this.Get().ToHashtable()
        if ('Present' -eq $this.Ensure)
        {
            $CreationParams = @{
                Key   = $this.Key
                Value = $this.Value
            }
            Set-PnPPropertyBagValue @CreationParams -Force
        }
        elseif ($this.Ensure -eq 'Absent' -and $CurrentPolicy.Ensure -eq 'Present')
        {
            Remove-PnPPropertyBagValue -Key $this.Key -Force
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

            # Get all Site Collections in tenant;
            $sites = Get-PnPTenantSite -ErrorAction Stop
            $i = 1
            $dscContent = [System.Text.StringBuilder]::new()

            if ($sites.Length -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }
            foreach ($site in $sites)
            {
                $siteUrl = $site.Url
                Write-M365DSCHost -Message "    [$i/$($sites.Length)] $($siteUrl)" -DeferWrite
                try
                {
                    $null = $this.Connect('PnP', $siteUrl)
                }
                catch
                {
                    Write-M365DSCHost -Message $Global:M365DSCEmojiRedX -CommitWrite

                    $this.LogError($_, 'Error during Export:')

                    continue
                }

                try
                {
                    $properties = Get-PnPPropertyBag
                    $j = 1

                    if ($properties.Length -eq 0)
                    {
                        Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
                        continue
                    }
                    else
                    {
                        Write-M365DSCHost -Message "`r`n" -DeferWrite
                    }
                    foreach ($property in $properties)
                    {
                        if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                        {
                            $Global:M365DSCExportResourceInstancesCount++
                        }

                        Write-M365DSCHost -Message "        |---[$j/$($properties.Length)] $($property.Key)" -DeferWrite
                        $Params = @{
                            Url                   = $siteUrl
                            Key                   = $property.Key
                            Value                 = '*'
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

                        $this.ExportedInstance = @{
                            Key   = $property.Key
                            Value = $property.Value
                        }
                        $Results = $this.GetForExport($Params)
                        $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName 'SPOPropertyBag' `
                            -ConnectionMode $ConnectionMode `
                            -ModulePath $this.GetModulePath() `
                            -Results $Results `
                            -Credential $this.Credential
                        [void]$dscContent.Append($currentDSCBlock)
                        Save-M365DSCPartialExport -Content $currentDSCBlock `
                            -FileName $Global:PartialExportFileName

                        Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
                        $j++
                    }
                }
                catch
                {
                    Write-M365DSCHost -Message $Global:M365DSCEmojiRedX -CommitWrite

                    $this.LogError($_, 'Error during Export:')

                    continue
                }
                $i++
            }

            $organization = ''
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

            $dscContent = $dscContent.ToString()
            if ($dscContent.ToLower().Contains($organization.ToLower()) -or `
                    $dscContent.ToLower().Contains($principal.ToLower()))
            {
                $dscContent = $dscContent -ireplace [regex]::Escape('https://' + $principal + '.sharepoint.com/'), "https://`$(`$OrganizationName.Split('.')[0]).sharepoint.com/"
                $dscContent = $dscContent -ireplace [regex]::Escape('@' + $organization), "@`$(`$OrganizationName)"
            }
            return $dscContent
        }
        catch
        {
            $this.LogError($_, 'Error during Export:')

            throw
        }
    }

    hidden [SPOPropertyBag] AsResult([System.Object] $Values)
    {
        if ($Values -is [SPOPropertyBag])
        {
            return $Values
        }

        $result = [SPOPropertyBag]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
