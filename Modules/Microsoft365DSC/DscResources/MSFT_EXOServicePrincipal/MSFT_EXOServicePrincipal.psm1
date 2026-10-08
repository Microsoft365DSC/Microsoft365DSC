using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class EXOServicePrincipal : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The AppName parameter specifies the corresponding friendly name of the unique AppId GUID value for the service principal.')]
    [System.String] $AppName

    [DscProperty()]
    [System.ComponentModel.Description('The DisplayName parameter specifies the friendly name of the service principal.')]
    [System.String] $DisplayName

    [DscProperty()]
    [System.ComponentModel.Description('The Identity parameter specifies the service principal that you want to view.')]
    [System.String] $Identity

    [DscProperty()]
    [System.ComponentModel.Description('The AppId parameter specifies the unique AppId GUID value for the service principal.')]
    [System.String] $AppId

    [DscProperty()]
    [System.ComponentModel.Description('Present ensures the group exists, absent ensures it is removed')]
    [ValidateSet('Present', 'Absent')]
    [System.String] $Ensure

    [DscProperty()]
    [System.ComponentModel.Description('Credentials of the Exchange Global Admin')]
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
    [System.Management.Automation.PSCredential] $ApplicationSecret

    [EXOServicePrincipal] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [EXOServicePrincipal]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting Exchange Service Principal configuration for $($this.AppName)"

        try
        {
            if (-not $this.ExportedInstance)
            {
                $null = $this.Connect('ExchangeOnline')

                $null = $this.Connect('MicrosoftGraph')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullResult = $this.GetBoundParameters()
                $nullResult.Ensure = 'Absent'

                $servicePrincipal = Get-MgServicePrincipal -Filter "DisplayName eq '$($this.AppName -replace "'", "''")'"
                if ($null -eq $servicePrincipal)
                {
                    Write-Verbose -Message "Microsoft Graph Service Principal with AppName {$($this.AppName)} not found."
                    return $this.AsResult($nullResult)
                }

                $instance = Get-ServicePrincipal -Identity $servicePrincipal.Id -ErrorAction SilentlyContinue
                if ($null -eq $instance)
                {
                    Write-Verbose -Message "EXO Service Principal with Id {$($servicePrincipal.Id)} not found."
                    return $this.AsResult($nullResult)
                }
            }
            else
            {
                $instance = $this.ExportedInstance
                $servicePrincipal = $this.ResourceCache['exportedInstance2']
            }

            Write-Verbose -Message "Found Service Principal with AppName {$($this.AppName)}"

            $results = @{
                Identity              = $servicePrincipal.Id
                AppName               = $servicePrincipal.AppDisplayName
                DisplayName           = $instance.DisplayName
                AppId                 = $instance.AppId
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

        Write-Verbose -Message "Setting Exchange Service Principal configuration for $($this.AppName)"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $currentInstance = $this.Get().ToHashtable()

        $setParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()

        $servicePrincipal = Get-MgServicePrincipal -Filter "DisplayName eq '$($this.AppName -replace "'", "''")'"

        # CREATE
        if ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
        {
            New-ServicePrincipal -AppId $servicePrincipal.AppId -ObjectId $servicePrincipal.Id
        }
        # UPDATE
        elseif ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Present')
        {
            $setParameters.Remove('AppId')
            Set-ServicePrincipal -DisplayName $this.DisplayName -Identity $servicePrincipal.Id
        }
        # REMOVE
        elseif ($this.Ensure -eq 'Absent' -and $currentInstance.Ensure -eq 'Present')
        {
            Remove-ServicePrincipal -Identity $servicePrincipal.Id
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

        $ConnectionMode = $this.Connect('ExchangeOnline')

        $ConnectionMode = $this.Connect('MicrosoftGraph')

        Confirm-M365DSCDependencies

        #region Telemetry
        $this.AddTelemetry('Export')
        #endregion

        try
        {
            [array] $servicePrincipals = Get-ServicePrincipal -ErrorAction Stop

            $i = 1
            $dscContent = [System.Text.StringBuilder]::new()
            if ($servicePrincipals.Length -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }
            foreach ($config in $servicePrincipals)
            {
                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }

                $graphServicePrincipal = Get-MgServicePrincipal -ServicePrincipalId $config.Identity
                $appDisplayName = $graphServicePrincipal.AppDisplayName
                if ([System.String]::IsNullOrEmpty($appDisplayName))
                {
                    $appDisplayName = $graphServicePrincipal.DisplayName
                }

                $displayedKey = $appDisplayName
                Write-M365DSCHost -Message "    |---[$i/$($servicePrincipals.Count)] $displayedKey" -DeferWrite
                $params = @{
                    AppName               = $appDisplayName
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
                $this.ResourceCache['exportedInstance2'] = $graphServicePrincipal
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

    hidden [EXOServicePrincipal] AsResult([System.Object] $Values)
    {
        if ($Values -is [EXOServicePrincipal])
        {
            return $Values
        }

        $result = [EXOServicePrincipal]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
