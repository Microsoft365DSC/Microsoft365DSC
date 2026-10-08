using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class SPOAccessControlSettings : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('Specifies the resource is a single instance, the value must be ''Yes''')]
    [ValidateSet('Yes')]
    [System.String] $IsSingleInstance

    [DscProperty()]
    [System.ComponentModel.Description('Determines whether tenant users see the Start a Site menu option')]
    [System.Nullable[System.Boolean]] $DisplayStartASiteOption

    [DscProperty()]
    [System.ComponentModel.Description('Specifies URL of the form to load in the Start a Site dialog. The valid values are:<emptyString> (default) - Blank by default, this will also remove or clear any value that has been set.Full URL - Example: https://contoso.sharepoint.com/path/to/form')]
    [System.String] $StartASiteFormUrl

    [DscProperty()]
    [System.ComponentModel.Description('Allows access from network locations that are defined by an administrator.')]
    [System.Nullable[System.Boolean]] $IPAddressEnforcement

    [DscProperty()]
    [System.ComponentModel.Description('Configures multiple IP addresses or IP address ranges (IPv4 or IPv6). Use commas to separate multiple IP addresses or IP address ranges.')]
    [System.String] $IPAddressAllowList

    [DscProperty()]
    [System.ComponentModel.Description('Office webapps TokenLifeTime in minutes')]
    [System.Nullable[System.UInt32]] $IPAddressWACTokenLifetime

    [DscProperty()]
    [System.ComponentModel.Description('Prevents the Download button from being displayed on the Virus Found warning page.')]
    [System.Nullable[System.Boolean]] $DisallowInfectedFileDownload

    [DscProperty()]
    [System.ComponentModel.Description('Enables external services for a tenant. External services are defined as services that are not in the Office 365 datacenters.')]
    [System.Nullable[System.Boolean]] $ExternalServicesEnabled

    [DscProperty()]
    [System.ComponentModel.Description('Sets email attestation to required')]
    [System.Nullable[System.Boolean]] $EmailAttestationRequired

    [DscProperty()]
    [System.ComponentModel.Description('Sets email attestation re-auth days')]
    [System.Nullable[System.UInt32]] $EmailAttestationReAuthDays

    [DscProperty()]
    [System.ComponentModel.Description('Enables or disables the restricted access control.')]
    [System.Nullable[System.Boolean]] $EnableRestrictedAccessControl

    [DscProperty()]
    [System.ComponentModel.Description('Controls whether resource accounts used by Teams Rooms and Devices can retain access to files after the meeting/collaboration is complete. The valid values are: - False (default) - Allows devices from accessing files and other Microsoft 365 assets when not actively in-use. - True - Prevents devices from accessing files and other Microsoft 365 assets when not actively in-use.')]
    [System.Nullable[System.Boolean]] $RestrictResourceAccountAccess

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
    [System.ComponentModel.Description('Blocks or limits access to SharePoint and OneDrive content from un-managed devices.')]
    [ValidateSet('AllowFullAccess', 'AllowLimitedAccess', 'BlockAccess', 'ProtectionLevel')]
    [System.String] $ConditionalAccessPolicy

    [DscProperty()]
    [System.ComponentModel.Description('Access token used for authentication.')]
    [System.String[]] $AccessTokens

    [SPOAccessControlSettings] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [SPOAccessControlSettings]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message 'Getting configuration of SharePoint Online Access Control Settings'

        try
        {
            if ($null -eq $this.ExportedInstance)
            {
                $null = $this.Connect('PnP')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $SPOAccessControlSettings = Get-PnPTenant -ErrorAction Stop
            }
            else
            {
                $SPOAccessControlSettings = $this.ExportedInstance
            }

            return $this.AsResult(@{
                IsSingleInstance              = 'Yes'
                ConditionalAccessPolicy       = $SPOAccessControlSettings.ConditionalAccessPolicy
                DisplayStartASiteOption       = $SPOAccessControlSettings.DisplayStartASiteOption
                StartASiteFormUrl             = $SPOAccessControlSettings.StartASiteFormUrl
                IPAddressEnforcement          = $SPOAccessControlSettings.IPAddressEnforcement
                IPAddressAllowList            = $SPOAccessControlSettings.IPAddressAllowList
                IPAddressWACTokenLifetime     = $SPOAccessControlSettings.IPAddressWACTokenLifetime
                DisallowInfectedFileDownload  = $SPOAccessControlSettings.DisallowInfectedFileDownload
                ExternalServicesEnabled       = $SPOAccessControlSettings.ExternalServicesEnabled
                EmailAttestationRequired      = $SPOAccessControlSettings.EmailAttestationRequired
                EmailAttestationReAuthDays    = $SPOAccessControlSettings.EmailAttestationReAuthDays
                RestrictResourceAccountAccess = $SPOAccessControlSettings.RestrictResourceAccountAccess
                EnableRestrictedAccessControl = $SPOAccessControlSettings.RestrictedAccessControl
                Credential                    = $this.Credential
                ApplicationId                 = $this.ApplicationId
                TenantId                      = $this.TenantId
                ApplicationSecret             = $this.ApplicationSecret
                CertificateThumbprint         = $this.CertificateThumbprint
                CertificatePath               = $this.CertificatePath
                CertificatePassword           = $this.CertificatePassword
                ManagedIdentity               = $this.ManagedIdentity
                AccessTokens                  = $this.AccessTokens
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

        Write-Verbose -Message 'Setting configuration of SharePoint Online Access Control Settings'

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $null = $this.Connect('PnP')

        $CurrentParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()
        $CurrentParameters.Remove('IsSingleInstance') | Out-Null

        if ($this.IPAddressAllowList -eq '')
        {
            Write-Verbose -Message 'The IPAddressAllowList is not configured, for that the IPAddressEnforcement parameter can not be set and will be removed'
            $CurrentParameters.Remove('IPAddressEnforcement')
            $CurrentParameters.Remove('IPAddressAllowList')
        }

        $EnableRestrictedAccessControlValue = $null
        if ($null -ne $this.EnableRestrictedAccessControl)
        {
            $EnableRestrictedAccessControlValue = $this.EnableRestrictedAccessControl
            $CurrentParameters.Remove('EnableRestrictedAccessControl') | Out-Null
        }

        Set-PnPTenant @CurrentParameters -Force | Out-Null

        try
        {
            Set-PnPTenant -EnableRestrictedAccessControl $EnableRestrictedAccessControlValue -Force -ErrorAction Stop | Out-Null
        }
        catch
        {
            if ($_.ErrorDetails.Message.Contains("This operation can't be performed as the tenant doesn't have the required license"))
            {
                Write-Warning -Message "The tenant doesn't have the required license to configure Restricted Access Control."
            }
            else
            {
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

            if ($null -ne $Global:M365DSCExportResourceInstancesCount)
            {
                $Global:M365DSCExportResourceInstancesCount++
            }

            $this.ExportedInstance = Get-PnPTenant -ErrorAction Stop

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

    hidden [SPOAccessControlSettings] AsResult([System.Object] $Values)
    {
        if ($Values -is [SPOAccessControlSettings])
        {
            return $Values
        }

        $result = [SPOAccessControlSettings]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
