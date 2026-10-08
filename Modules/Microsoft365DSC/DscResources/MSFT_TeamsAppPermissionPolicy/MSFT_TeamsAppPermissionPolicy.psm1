using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class TeamsAppPermissionPolicy : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('Unique identifier to be assigned to the new Teams app permission policy. Use the ''Global'' Identity if you wish to assign this policy to the entire tenant.')]
    [System.String] $Identity

    [DscProperty()]
    [System.ComponentModel.Description('Enables administrators to provide explanatory text to accompany a Teams app permission policy.')]
    [System.String] $Description

    [DscProperty()]
    [System.ComponentModel.Description('The types of apps for the Global Catalog.')]
    [System.String] $GlobalCatalogAppsType

    [DscProperty()]
    [System.ComponentModel.Description('The types of apps for the Private Catalog.')]
    [System.String] $PrivateCatalogAppsType

    [DscProperty()]
    [System.ComponentModel.Description('The types of apps for the Default Catalog.')]
    [System.String] $DefaultCatalogAppsType

    [DscProperty()]
    [System.ComponentModel.Description('The list of apps for the Global Catalog.')]
    [System.String[]] $GlobalCatalogApps

    [DscProperty()]
    [System.ComponentModel.Description('The list of apps for the Private Catalog.')]
    [System.String[]] $PrivateCatalogApps

    [DscProperty()]
    [System.ComponentModel.Description('The list of apps for the Default Catalog.')]
    [System.String[]] $DefaultCatalogApps

    [DscProperty()]
    [System.ComponentModel.Description('Present ensures the instance exists, absent ensures it is removed.')]
    [ValidateSet('Present', 'Absent')]
    [System.String] $Ensure

    [DscProperty()]
    [System.ComponentModel.Description('Credentials of the workload''s Admin')]
    [System.Management.Automation.PSCredential] $Credential

    [DscProperty()]
    [System.ComponentModel.Description('Id of the Azure Active Directory application to authenticate with.')]
    [System.String] $ApplicationId

    [DscProperty()]
    [System.ComponentModel.Description('Id of the Azure Active Directory tenant used for authentication.')]
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

    # Export-only. Not part of the resource schema.
    [System.String] $Filter = '*'

    # Export-only. Not part of the resource schema.
    [System.Management.Automation.PSCredential] $ApplicationSecret

    [TeamsAppPermissionPolicy] Get()
    {
        $nullResult = $null
        if ($this.RequiresPowerShellCore())
        {
            $remote = [TeamsAppPermissionPolicy]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration for TeamsAppPermissionPolicy $($this.Identity)"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.Identity -ne $this.Identity)
            {
                $null = $this.Connect('MicrosoftTeams')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullResult = $this.GetBoundParameters()
                $nullResult.Ensure = 'Absent'

                $instance = Get-CsTeamsAppPermissionPolicy -Identity $this.Identity -ErrorAction SilentlyContinue
            }
            else
            {
                $instance = $this.ExportedInstance
            }

            if ($null -eq $instance)
            {
                return $this.AsResult($nullResult)
            }

            $DefaultCatalogAppsValue = $instance.DefaultCatalogApps.Id
            if ($instance.DefaultCatalogApps.Count -eq 0)
            {
                $DefaultCatalogAppsValue = @()
            }

            $GlobalCatalogAppsValue = $instance.GlobalCatalogApps.Id
            if ($instance.GlobalCatalogApps.Count -eq 0)
            {
                $GlobalCatalogAppsValue = @()
            }

            $PrivateCatalogAppsValue = $instance.PrivateCatalogApps.Id
            if ($instance.PrivateCatalogApps.Count -eq 0)
            {
                $PrivateCatalogAppsValue = @()
            }

            Write-Verbose -Message "Found an instance with Identity {$($this.Identity)}"
            $results = @{
                Identity               = $instance.Identity.Replace('Tag:', '')
                Description            = $instance.Description
                GlobalCatalogAppsType  = $instance.GlobalCatalogAppsType
                PrivateCatalogAppsType = $instance.PrivateCatalogAppsType
                DefaultCatalogAppsType = $instance.DefaultCatalogAppsType
                GlobalCatalogApps      = [Array]$GlobalCatalogAppsValue
                PrivateCatalogApps     = [Array]$PrivateCatalogAppsValue
                DefaultCatalogApps     = [Array]$DefaultCatalogAppsValue
                Ensure                 = 'Present'
                Credential             = $this.Credential
                ApplicationId          = $this.ApplicationId
                TenantId               = $this.TenantId
                CertificateThumbprint  = $this.CertificateThumbprint
                CertificatePath        = $this.CertificatePath
                CertificatePassword    = $this.CertificatePassword
                ManagedIdentity        = $this.ManagedIdentity
                AccessTokens           = $this.AccessTokens
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

        Write-Verbose -Message "Setting configuration for TeamsAppPermissionPolicy $($this.Identity)"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $currentInstance = $this.Get().ToHashtable()

        $DefaultCatalogAppsValue = @()
        if ($this.DefaultCatalogApps.Count -gt 0)
        {
            foreach ($appEntry in $this.DefaultCatalogApps)
            {
                $DefaultCatalogAppsValue += New-Object -TypeName 'Microsoft.Teams.Policy.Administration.Cmdlets.Core.DefaultCatalogApp' -ArgumentList $appEntry
            }
        }
        $PrivateCatalogAppsValue = @()
        if ($this.PrivateCatalogApps.Count -gt 0)
        {
            foreach ($appEntry in $this.PrivateCatalogApps)
            {
                $PrivateCatalogAppsValue += New-Object -TypeName 'Microsoft.Teams.Policy.Administration.Cmdlets.Core.PrivateCatalogApp' -ArgumentList $appEntry
            }
        }
        $GlobalCatalogAppsValue = @()
        if ($this.GlobalCatalogApps.Count -gt 0)
        {
            foreach ($appEntry in $this.GlobalCatalogApps)
            {
                $GlobalCatalogAppsValue += New-Object -TypeName 'Microsoft.Teams.Policy.Administration.Cmdlets.Core.GlobalCatalogApp' -ArgumentList $appEntry
            }
        }
        if ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
        {
            $createParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()
            $createParameters.Remove('Verbose') | Out-Null
            Write-Verbose -Message "Creating a Teams App Permission Policy with Identity {$($this.Identity)}"

            $createParameters.GlobalCatalogApps = $GlobalCatalogAppsValue
            $createParameters.PrivateCatalogApps = $PrivateCatalogAppsValue
            $createParameters.DefaultCatalogApps = $DefaultCatalogAppsValue

            New-CsTeamsAppPermissionPolicy @createParameters | Out-Null
        }
        elseif ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Present')
        {
            $updateParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()
            $updateParameters.Remove('Verbose') | Out-Null
            Write-Verbose -Message "Updating the Teams App Permission Policy with Identity {$($this.Identity)}"

            $updateParameters.GlobalCatalogApps = $GlobalCatalogAppsValue
            $updateParameters.PrivateCatalogApps = $PrivateCatalogAppsValue
            $updateParameters.DefaultCatalogApps = $DefaultCatalogAppsValue

            Set-CsTeamsAppPermissionPolicy @updateParameters | Out-Null
        }
        elseif ($this.Ensure -eq 'Absent' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Removing the Teams App Permission Policy with Identity {$($this.Identity)}"
            Remove-CsTeamsAppPermissionPolicy -Identity $currentInstance.Identity
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

        $ConnectionMode = $this.Connect('MicrosoftTeams')

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Export')

        try
        {
            [array]$getValue = Get-CsTeamsAppPermissionPolicy -Filter $this.Filter -ErrorAction Stop

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
                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }

                $displayedKey = $config.Identity
                if (-not [String]::IsNullOrEmpty($config.displayName))
                {
                    $displayedKey = $config.displayName
                }
                Write-M365DSCHost -Message "    |---[$i/$($getValue.Count)] $displayedKey" -DeferWrite
                $params = @{
                    Identity              = $config.Identity
                    Ensure                = 'Present'
                    Credential            = $this.Credential
                    ApplicationId         = $this.ApplicationId
                    TenantId              = $this.TenantId
                    CertificateThumbprint = $this.CertificateThumbprint
                    CertificatePath       = $this.CertificatePath
                    CertificatePassword   = $this.CertificatePassword
                    ManagedIdentity       = $this.ManagedIdentity
                    AccessTokens          = $this.AccessTokens
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

    hidden [TeamsAppPermissionPolicy] AsResult([System.Object] $Values)
    {
        if ($Values -is [TeamsAppPermissionPolicy])
        {
            return $Values
        }

        $result = [TeamsAppPermissionPolicy]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
