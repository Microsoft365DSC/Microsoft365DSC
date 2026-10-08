using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class EXODkimSigningConfig : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The Identity parameter specifies the DKIM signing policy that you want to modify.  This should be the FQDN. ')]
    [System.String] $Identity

    [DscProperty()]
    [System.ComponentModel.Description('The AdminDisplayName parameter specifies a description for the policy.')]
    [System.String] $AdminDisplayName

    [DscProperty()]
    [System.ComponentModel.Description('The BodyCanonicalization parameter specifies the canonicalization algorithm that''s used to create and verify the message body part of the DKIM signature. This value effectively controls the sensitivity of DKIM to changes to the message body in transit. Valid values are ''Simple'' or ''Relaxed''.  ''Relaxed'' is the default.')]
    [ValidateSet('Simple', 'Relaxed')]
    [System.String] $BodyCanonicalization

    [DscProperty()]
    [System.ComponentModel.Description('The HeaderCanonicalization parameter specifies the canonicalization algorithm that''s used to create and verify the message header part of the DKIM signature. This value effectively controls the sensitivity of DKIM to changes to the message headers in transit. Valid values are ''Simple'' or ''Relaxed''.  ''Relaxed'' is the default.')]
    [ValidateSet('Simple', 'Relaxed')]
    [System.String] $HeaderCanonicalization

    [DscProperty()]
    [System.ComponentModel.Description('The KeySize parameter specifies the size in bits of the public key that''s used in the DKIM signing policy. Valid values are 1024 and 2048')]
    [ValidateSet('1024', '2048')]
    [System.Nullable[System.UInt16]] $KeySize

    [DscProperty()]
    [System.ComponentModel.Description('The Enabled parameter specifies whether the DKIM Signing Configuration is enabled or disabled. Default is $true.')]
    [System.Nullable[System.Boolean]] $Enabled

    [DscProperty()]
    [System.ComponentModel.Description('Specifies if this Client Access Rule should exist.')]
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

    [EXODkimSigningConfig] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [EXODkimSigningConfig]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of DkimSigningConfig for $($this.Identity)"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.Identity -ne $this.Identity)
            {
                $null = $this.Connect('ExchangeOnline')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullReturn = $this.GetBoundParameters()
                $nullReturn.Ensure = 'Absent'

                $DkimSigningConfig = Get-DkimSigningConfig -Identity $this.Identity

                if ($null -eq $DkimSigningConfig -or "System.Object" -eq $DkimSigningConfig.ToString())
                {
                    Write-Verbose -Message "DkimSigningConfig $($this.Identity) does not exist."
                    return $this.AsResult($nullReturn)
                }
            }
            else
            {
                $DkimSigningConfig = $this.ExportedInstance
            }

            Write-Verbose -Message "Found DkimSigningConfig $($this.Identity)"

            $result = @{
                Ensure                 = 'Present'
                Identity               = $this.Identity
                AdminDisplayName       = $DkimSigningConfig.AdminDisplayName
                BodyCanonicalization   = $DkimSigningConfig.BodyCanonicalization
                Enabled                = $DkimSigningConfig.Enabled
                HeaderCanonicalization = $DkimSigningConfig.HeaderCanonicalization
                KeySize                = $DkimSigningConfig.Selector1KeySize
                Credential             = $this.Credential
                ApplicationId          = $this.ApplicationId
                CertificateThumbprint  = $this.CertificateThumbprint
                CertificatePath        = $this.CertificatePath
                CertificatePassword    = $this.CertificatePassword
                ManagedIdentity        = $this.ManagedIdentity
                TenantId               = $this.TenantId
                AccessTokens           = $this.AccessTokens
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

        Write-Verbose -Message "Setting configuration of DkimSigningConfig for $($this.Identity)"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $DkimSigningConfig = $this.Get().ToHashtable()
        $boundParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()

        if ($this.Ensure -eq 'Present' -and $DkimSigningConfig.Ensure -eq 'Absent')
        {
            $createParameters = $boundParameters
            $createParameters.Add('DomainName', $this.Identity) | Out-Null
            $createParameters.Remove('Identity') | Out-Null
            Write-Verbose -Message "Creating DkimSigningConfig $($this.Identity)."
            New-DkimSigningConfig @createParameters
        }
        elseif ($this.Ensure -eq 'Present' -and $DkimSigningConfig.Ensure -eq 'Present')
        {
            $updateParameters = $boundParameters
            $updateParameters.Remove('KeySize') | Out-Null
            Write-Verbose -Message "Setting DkimSigningConfig $($this.Identity) with values: $(Convert-M365DscHashtableToString -Hashtable $updateParameters)"
            Set-DkimSigningConfig @updateParameters -Confirm:$false
        }

        if ($this.Ensure -eq 'Absent' -and $DkimSigningConfig.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Disabling DkimSigningConfig $($this.Identity) "
            Set-DkimSigningConfig -Identity $this.Identity -Enabled $false -Confirm:$false
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

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Export')

        try
        {
            if (Confirm-ImportedCmdletIsAvailable -CmdletName Get-DkimSigningConfig)
            {
                [array]$DkimSigningConfigs = Get-DkimSigningConfig

                $i = 1
                if ($DkimSigningConfigs.Count -eq 0)
                {
                    Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
                }
                else
                {
                    Write-M365DSCHost -Message "`r`n" -DeferWrite
                }
                $dscContent = [System.Text.StringBuilder]::new()
                foreach ($DkimSigningConfig in $DkimSigningConfigs)
                {
                    if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                    {
                        $Global:M365DSCExportResourceInstancesCount++
                    }

                    Write-M365DSCHost -Message "    |---[$i/$($DkimSigningConfigs.Count)] $($DkimSigningConfig.Identity)" -DeferWrite
                    $Params = @{
                        Identity              = $DkimSigningConfig.Identity
                        Credential            = $this.Credential
                        ApplicationId         = $this.ApplicationId
                        TenantId              = $this.TenantId
                        CertificateThumbprint = $this.CertificateThumbprint
                        CertificatePassword   = $this.CertificatePassword
                        ManagedIdentity       = $this.ManagedIdentity
                        CertificatePath       = $this.CertificatePath
                        AccessTokens          = $this.AccessTokens
                    }
                    $this.ExportedInstance = $DkimSigningConfig
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
            else
            {
                Write-M365DSCHost -Message "`r`n    $($Global:M365DSCEmojiYellowCircle) The current tenant is not registered to allow for DKIM Signing Config"
                return ''
            }
            return $dscContent.ToString()
        }
        catch
        {
            $this.LogError($_, 'Error during Export:')

            throw
        }
    }

    hidden [EXODkimSigningConfig] AsResult([System.Object] $Values)
    {
        if ($Values -is [EXODkimSigningConfig])
        {
            return $Values
        }

        $result = [EXODkimSigningConfig]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
