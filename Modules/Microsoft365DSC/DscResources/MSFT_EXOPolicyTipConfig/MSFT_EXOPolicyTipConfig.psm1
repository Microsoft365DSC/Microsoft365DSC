using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class EXOPolicyTipConfig : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The Name parameter specifies the custom Policy Tip you want to modify.')]
    [System.String] $Name

    [DscProperty()]
    [System.ComponentModel.Description('The Value parameter specifies the text that''s displayed by the Policy Tip.')]
    [System.String] $Value

    [DscProperty()]
    [System.ComponentModel.Description('Specify if the Policy Tip Config should exist or not.')]
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

    [EXOPolicyTipConfig] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [EXOPolicyTipConfig]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting Policy Tip configuration for $($this.Name)"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.Name -ne $this.Name)
            {
                $null = $this.Connect('ExchangeOnline')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullReturn = $this.GetBoundParameters()
                $nullReturn.Ensure = 'Absent'

                $PolicyTipConfig = Get-PolicyTipConfig -Identity $this.Name -ErrorAction SilentlyContinue
                if ($null -eq $PolicyTipConfig)
                {
                    Write-Verbose -Message "Policy Tip Config $($this.Name) does not exist."
                    return $this.AsResult($nullReturn)
                }
            }
            else
            {
                $PolicyTipConfig = $this.ExportedInstance
            }

            Write-Verbose -Message "Found Policy Tip Config with Name {$($this.Name)}"

            $result = @{
                Name                  = $PolicyTipConfig.Name
                Value                 = $PolicyTipConfig.Value
                Ensure                = 'Present'
                Credential            = $this.Credential
                ApplicationId         = $this.ApplicationId
                CertificateThumbprint = $this.CertificateThumbprint
                CertificatePath       = $this.CertificatePath
                CertificatePassword   = $this.CertificatePassword
                ManagedIdentity       = $this.ManagedIdentity
                TenantId              = $this.TenantId
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

        Write-Verbose -Message "Setting Policy Tip config for $($this.Name)"

        $currentPolicyTipConfig = $this.Get().ToHashtable()

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $null = $this.Connect('ExchangeOnline')

        $NewPolicyTipConfigParams = @{
            Name    = $this.Name
            Value   = $this.Value
            Confirm = $false
        }

        $SetPolicyTipConfigParams = @{
            Identity = $this.Name
            Value    = $this.Value
            Confirm  = $false
        }

        # CASE: Policy Tip Config doesn't exist but should;
        if ($this.Ensure -eq 'Present' -and $currentPolicyTipConfig.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Policy Tip Config '$($this.Name)' does not exist but it should. Create and configure it."
            # Create Policy Tip Config
            New-PolicyTipConfig @NewPolicyTipConfigParams

        }
        # CASE: Policy Tip Config exists but it shouldn't;
        elseif ($this.Ensure -eq 'Absent' -and $currentPolicyTipConfig.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Policy Tip Config '$($this.Name)' exists but it shouldn't. Remove it."
            Remove-PolicyTipConfig -Identity $this.Name -Confirm:$false
        }
        # CASE: Policy Tip Config exists and it should, but has different values than the desired ones
        elseif ($this.Ensure -eq 'Present' -and $currentPolicyTipConfig.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Policy Tip Config '$($this.Name)' already exists, but needs updating."
            Write-Verbose -Message "Setting Policy Tip Config $($this.Name) with values: $(Convert-M365DscHashtableToString -Hashtable $SetPolicyTipConfigParams)"
            Set-PolicyTipConfig @SetPolicyTipConfigParams
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
            $dscContent = [System.Text.StringBuilder]::new()
            $command = Get-Command Get-PolicyTipConfig -ErrorAction SilentlyContinue
            if ($null -ne $command)
            {
                [array]$AllPolicyTips = Get-PolicyTipConfig

                $i = 1
                if ($AllPolicyTips.Length -eq 0)
                {
                    Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
                }
                else
                {
                    Write-M365DSCHost -Message "`r`n" -DeferWrite
                }
                foreach ($PolicyTipConfig in $AllPolicyTips)
                {
                    if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                    {
                        $Global:M365DSCExportResourceInstancesCount++
                    }

                    Write-M365DSCHost -Message "    |---[$i/$($AllPolicyTips.Length)] $($PolicyTipConfig.Name)" -DeferWrite

                    $Params = @{
                        Name                  = $PolicyTipConfig.Name
                        Credential            = $this.Credential
                        ApplicationId         = $this.ApplicationId
                        TenantId              = $this.TenantId
                        CertificateThumbprint = $this.CertificateThumbprint
                        CertificatePassword   = $this.CertificatePassword
                        ManagedIdentity       = $this.ManagedIdentity
                        CertificatePath       = $this.CertificatePath
                        AccessTokens          = $this.AccessTokens
                    }
                    $this.ExportedInstance = $PolicyTipConfig
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
                Write-M365DSCHost -Message "`r`n    $($Global:M365DSCEmojiYellowCircle) The current tenant is not registered for Policy Tip Configurations." -CommitWrite
            }
            return $dscContent.ToString()
        }
        catch
        {
            $this.LogError($_, 'Error during Export:')

            throw
        }
    }

    hidden [EXOPolicyTipConfig] AsResult([System.Object] $Values)
    {
        if ($Values -is [EXOPolicyTipConfig])
        {
            return $Values
        }

        $result = [EXOPolicyTipConfig]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
