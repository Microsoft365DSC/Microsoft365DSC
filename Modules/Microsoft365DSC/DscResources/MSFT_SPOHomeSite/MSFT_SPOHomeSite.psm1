using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class SPOHomeSite : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('Specifies the resource is a single instance, the value must be ''Yes''')]
    [ValidateSet('Yes')]
    [System.String] $IsSingleInstance

    [DscProperty()]
    [System.ComponentModel.Description('The URL of the home site collection')]
    [System.String] $Url

    [DscProperty()]
    [System.ComponentModel.Description('Present ensures the site collection is registered as home site, absent ensures it is unregistered')]
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

    [SPOHomeSite] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [SPOHomeSite]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting current home site collection settings for $($this.Url)"

        try
        {
            if ($null -eq $this.ExportedInstance)
            {
                $null = $this.Connect('PnP')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullReturn = $this.GetBoundParameters()
                $nullReturn.Ensure = 'Absent'

                $homeSiteUrl = Get-PnPHomeSite -ErrorAction Stop
                if ([System.String]::IsNullOrEmpty($homeSiteUrl))
                {
                    Write-Verbose -Message 'There is no Home Site Collection set.'
                    return $this.AsResult($nullReturn)
                }
            }
            else
            {
                $homeSiteUrl = $this.ExportedInstance
            }

            $result = @{
                IsSingleInstance      = $this.IsSingleInstance
                Url                   = $homeSiteUrl
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

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')
        Write-Verbose -Message "Setting configuration for home site '$($this.Url)'"

        $currentValues = $this.Get().ToHashtable()

        if ($this.Ensure -eq 'Present')
        {
            try
            {
                Write-Verbose -Message "Setting home site collection $($this.Url)"
                Get-PnPTenantSite -Identity $this.Url
            }
            catch
            {
                $Message = "The specified Site Collection $($this.Url) for SPOHomeSite doesn't exist."
                $this.LogError($_, $Message)
                throw $Message
            }

            Write-Verbose -Message 'Configuring site collection as Home Site'
            Set-PnPHomeSite -HomeSiteUrl $this.Url
        }

        if ($this.Ensure -eq 'Absent' -and $currentValues.Ensure -eq 'Present')
        {
            # Remove home site
            Remove-PnPHomeSite -Force
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

            $this.ExportedInstance = Get-PnPHomeSite -ErrorAction Stop
            if ([System.String]::IsNullOrEmpty($this.ExportedInstance))
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
                return ''
            }

            if ($null -ne $Global:M365DSCExportResourceInstancesCount)
            {
                $Global:M365DSCExportResourceInstancesCount++
            }

            $Params = @{
                IsSingleInstance      = 'Yes'
                ApplicationId         = $this.ApplicationId
                TenantId              = $this.TenantId
                CertificateThumbprint = $this.CertificateThumbprint
                CertificatePath       = $this.CertificatePath
                CertificatePassword   = $this.CertificatePassword
                ManagedIdentity       = $this.ManagedIdentity
                Credential            = $this.Credential
                ApplicationSecret     = $this.ApplicationSecret
                AccessTokens          = $this.AccessTokens
            }
            $dscContent = [System.Text.StringBuilder]::new()
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
            return $dscContent.ToString()
        }
        catch
        {
            $this.LogError($_, 'Error during Export:')

            throw
        }
    }

    hidden [SPOHomeSite] AsResult([System.Object] $Values)
    {
        if ($Values -is [SPOHomeSite])
        {
            return $Values
        }

        $result = [SPOHomeSite]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
