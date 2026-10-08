using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class SPOTenantCdnEnabled : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('Specifies the CDN type. The valid values are public or private.')]
    [ValidateSet('Public', 'Private')]
    [System.String] $CdnType

    [DscProperty()]
    [System.ComponentModel.Description('Specify to enable or disable tenant CDN.')]
    [System.Nullable[System.Boolean]] $Enable

    [DscProperty()]
    [System.ComponentModel.Description('Get-PNPTenantCdnEnabled always returns a value, only support value is Present')]
    [ValidateSet('Present')]
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

    [SPOTenantCdnEnabled] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [SPOTenantCdnEnabled]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message 'Getting configuration of SPO Tenant Cdn Enabled'

        try
        {
            if (-not $this.ResourceCache['ExportMode'])
            {
                $null = $this.Connect('PNP')

                # Ensure the proper dependencies are installed in the current environment.
                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')
            }

            $cdnEnabled = Get-PnPTenantCdnEnabled -CdnType $this.CdnType `
                -ErrorAction Stop

            $result = @{
                Ensure                = 'Present'
                CdnType               = $this.CdnType
                Enable                = $cdnEnabled.Value
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

        Write-Verbose -Message 'Setting configuration of SPO Cdn enabled'

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $null = $this.Get().ToHashtable()
        $currentParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()

        #No add only a set
        Set-PnPTenantCdnEnabled @currentParameters
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
            $cdnTypes = 'Public', 'Private'

            $i = 1
            Write-M365DSCHost -Message "`r`n" -DeferWrite

            $this.ResourceCache['ExportMode'] = $true
            foreach ($cType in $cdnTypes)
            {
                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }

                Write-M365DSCHost -Message "    |---[$i/2] $cType" -DeferWrite
                $Params = @{
                    Credential            = $this.Credential
                    CdnType               = $cType
                    ApplicationId         = $this.ApplicationId
                    TenantId              = $this.TenantId
                    ApplicationSecret     = $this.ApplicationSecret
                    CertificateThumbprint = $this.CertificateThumbprint
                    CertificatePath       = $this.CertificatePath
                    CertificatePassword   = $this.CertificatePassword
                    ManagedIdentity       = $this.ManagedIdentity
                    AccessTokens          = $this.AccessTokens
                }

                $Results = $this.GetForExport($Params)
                if ($Results -is [System.Collections.Hashtable] -and $Results.Count -gt 1)
                {
                    $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                        -ConnectionMode $ConnectionMode `
                        -ModulePath $this.GetModulePath() `
                        -Results $Results `
                        -Credential $this.Credential
                    [void]$dscContent.Append($currentDSCBlock)
                    Save-M365DSCPartialExport -Content $currentDSCBlock `
                        -FileName $Global:PartialExportFileName

                    Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
                }
                else
                {
                    Write-M365DSCHost -Message $Global:M365DSCEmojiRedX -CommitWrite
                }

                $i++
            }

            return $dscContent.ToString()
        }
        catch
        {
            # This method is not implemented in some sovereign clouds (e.g. GCCHigh)
            if ($_.Exception -like '*The method or operation is not implemented*')
            {
                Write-M365DSCHost -Message "    $($Global:M365DSCEmojiYellowCircle) The current tenant does not support this feature." -CommitWrite
                return ''
            }
            else
            {
                $this.LogError($_, 'Error during Export:')

                throw
            }
        }
    }

    hidden [SPOTenantCdnEnabled] AsResult([System.Object] $Values)
    {
        if ($Values -is [SPOTenantCdnEnabled])
        {
            return $Values
        }

        $result = [SPOTenantCdnEnabled]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
