using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class IntuneDerivedCredential : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The name of the app category.')]
    [System.String] $DisplayName

    [DscProperty()]
    [System.ComponentModel.Description('The unique identifier for an entity. Read-only.')]
    [System.String] $Id

    [DscProperty()]
    [System.ComponentModel.Description('The URL that will be accessible to end users as they retrieve a derived credential using the Company Portal.')]
    [System.String] $HelpUrl

    [DscProperty()]
    [System.ComponentModel.Description('The nominal percentage of time before certificate renewal is initiated by the client.')]
    [System.Nullable[System.UInt32]] $RenewalThresholdPercentage

    [DscProperty()]
    [System.ComponentModel.Description('Supported values for the derived credential issuer.')]
    [ValidateSet('intercede', 'entrustDataCard', 'purebred', 'xTec')]
    [System.String] $Issuer

    [DscProperty()]
    [System.ComponentModel.Description('Supported values for the notification type to use.')]
    [ValidateSet('none', 'email', 'companyPortal', 'companyPortal,email')]
    [System.String] $NotificationType

    [DscProperty()]
    [System.ComponentModel.Description('Supported values for the notification type to use.')]
    [ValidateSet('Present', 'Absent')]
    [System.String] $Ensure

    [DscProperty()]
    [System.ComponentModel.Description('Credentials of the Intune Admin')]
    [System.Management.Automation.PSCredential] $Credential

    [DscProperty()]
    [System.ComponentModel.Description('Id of the Azure Active Directory application to authenticate with.')]
    [System.String] $ApplicationId

    [DscProperty()]
    [System.ComponentModel.Description('Name of the Azure Active Directory tenant used for authentication. Format contoso.onmicrosoft.com')]
    [System.String] $TenantId

    [DscProperty()]
    [System.ComponentModel.Description('Secret of the Azure Active Directory tenant used for authentication.')]
    [System.Management.Automation.PSCredential] $ApplicationSecret

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

    # Export-only. Not part of the resource schema.
    [System.String] $Filter

    [IntuneDerivedCredential] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [IntuneDerivedCredential]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of the Intune Derived Credential with Id {$($this.Id)} and DisplayName {$($this.DisplayName)}."

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.DisplayName -ne $this.DisplayName)
            {
                $null = $this.Connect('MicrosoftGraph')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullResult = $this.GetBoundParameters()
                $nullResult.Ensure = 'Absent'

                $instance = $null
                if (-not [System.String]::IsNullOrEmpty($this.Id))
                {
                    $instance = Get-MgBetaDeviceManagementDerivedCredential -DeviceManagementDerivedCredentialSettingsId $this.Id -ErrorAction SilentlyContinue
                }

                if ($null -eq $instance)
                {
                    Write-Verbose -Message "Could not find Derived Credential by Id {$($this.Id)}."

                    if (-not [string]::IsNullOrEmpty($this.DisplayName))
                    {
                        $instance = Get-MgBetaDeviceManagementDerivedCredential `
                            -All `
                            -Filter "DisplayName eq '$($this.DisplayName -replace "'", "''")'" `
                            -ErrorAction SilentlyContinue

                        if ($null -eq $instance)
                        {
                            Write-Verbose -Message "Could not find Derived Credential by DisplayName {$($this.DisplayName)}."
                            return $this.AsResult($nullResult)
                        }
                    }
                }
            }
            else
            {
                $instance = $this.ExportedInstance
            }

            $results = @{
                Ensure                     = 'Present'
                Id                         = $instance.Id
                DisplayName                = $instance.DisplayName
                HelpUrl                    = $instance.HelpUrl
                Issuer                     = $instance.Issuer.ToString()
                NotificationType           = $instance.NotificationType.ToString()
                RenewalThresholdPercentage = $instance.RenewalThresholdPercentage
                Credential                 = $this.Credential
                ApplicationId              = $this.ApplicationId
                TenantId                   = $this.TenantId
                CertificateThumbprint      = $this.CertificateThumbprint
                ApplicationSecret          = $this.ApplicationSecret
                ManagedIdentity            = $this.ManagedIdentity
                AccessTokens               = $this.AccessTokens
            }

            return $this.AsResult($results)
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

        $currentInstance = $this.Get().ToHashtable()

        $setParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()
        $setParameters.Remove('Id') | Out-Null

        # CREATE
        if ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Creating an Intune Derived Credential with DisplayName {$($this.DisplayName)}"
            New-MgBetaDeviceManagementDerivedCredential -BodyParameter $setParameters
        }
        # UPDATE is not supported API, it always creates a new Derived Credential instance
        # REMOVE
        elseif ($this.Ensure -eq 'Absent' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Removing the Intune Derived Credential with DisplayName {$($this.DisplayName)}"
            Remove-MgBetaDeviceManagementDerivedCredential -DeviceManagementDerivedCredentialSettingsId $currentInstance.Id
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

        $ConnectionMode = $this.Connect('MicrosoftGraph')

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Export')

        try
        {
            [array] $getValue = Get-MgBetaDeviceManagementDerivedCredential -All -Filter $this.Filter -ErrorAction Stop

            $i = 1
            $dscContent = [System.Text.StringBuilder]::new()
            if ($getValue.Length -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }
            foreach ($config in $getValue)
            {
                $displayedKey = $config.Id
                Write-M365DSCHost -Message "    |---[$i/$($getValue.Count)] $displayedKey" -DeferWrite

                $params = @{
                    Ensure                     = 'Present'
                    Id                         = $config.Id
                    DisplayName                = $config.DisplayName
                    HelpUrl                    = $config.HelpUrl
                    Issuer                     = $config.Issuer.ToString()
                    NotificationType           = $config.NotificationType.ToString()
                    RenewalThresholdPercentage = $config.RenewalThresholdPercentage
                    Credential                 = $this.Credential
                    ApplicationId              = $this.ApplicationId
                    TenantId                   = $this.TenantId
                    ApplicationSecret          = $this.ApplicationSecret
                    CertificateThumbprint      = $this.CertificateThumbprint
                    CertificatePath            = $this.CertificatePath
                    CertificatePassword        = $this.CertificatePassword
                    ManagedIdentity            = $this.ManagedIdentity
                    AccessTokens               = $this.AccessTokens
                }

                $this.ExportedInstance = $config
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

    hidden [IntuneDerivedCredential] AsResult([System.Object] $Values)
    {
        if ($Values -is [IntuneDerivedCredential])
        {
            return $Values
        }

        $result = [IntuneDerivedCredential]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
