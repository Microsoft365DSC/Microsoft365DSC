using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class EXOSharingPolicy : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The Name parameter specifies the unique name of the sharing policy. The maximum length is 64 characters.')]
    [ValidateLength(1, 64)]
    [System.String] $Name

    [DscProperty()]
    [System.ComponentModel.Description('The Default switch specifies that the sharing policy is the default sharing policy for all mailboxes.')]
    [System.Nullable[System.Boolean]] $Default

    [DscProperty()]
    [System.ComponentModel.Description('The Enabled parameter specifies whether to enable the sharing policy. Valid values for this parameter are $true or $false.')]
    [System.Nullable[System.Boolean]] $Enabled

    [DscProperty()]
    [System.ComponentModel.Description('The Domains parameter specifies domains to which this policy applies and the sharing policy action.')]
    [System.String[]] $Domains

    [DscProperty()]
    [System.ComponentModel.Description('Specify if the Sharing Policy should exist or not.')]
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

    [EXOSharingPolicy] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [EXOSharingPolicy]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting Sharing Policy configuration for $($this.Name)"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.Name -ne $this.Name)
            {
                $null = $this.Connect('ExchangeOnline')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullReturn = $this.GetBoundParameters()
                $nullReturn.Ensure = 'Absent'

                $SharingPolicy = Get-SharingPolicy -Identity $this.Name -ErrorAction SilentlyContinue
                if ($null -eq $SharingPolicy)
                {
                    Write-Verbose -Message "Sharing Policy $($this.Name) does not exist."
                    return $this.AsResult($nullReturn)
                }
            }
            else
            {
                $SharingPolicy = $this.ExportedInstance
            }

            Write-Verbose -Message "An EXO Sharing Policy with Name $($SharingPolicy.Name) was found."

            $result = @{
                Name                  = $SharingPolicy.Name
                Default               = $SharingPolicy.Default
                Domains               = $SharingPolicy.Domains
                Enabled               = $SharingPolicy.Enabled
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

        Write-Verbose -Message "Setting Sharing Policy configuration for $($this.Name)"

        $currentSharingPolicyConfig = $this.Get().ToHashtable()

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $null = $this.Connect('ExchangeOnline')

        $NewSharingPolicyParams = @{
            Name    = $this.Name
            Domains = $this.Domains
            Enabled = $this.Enabled
            Default = $this.Default
            Confirm = $false
        }

        $SetSharingPolicyParams = @{
            Identity = $this.Name
            Name     = $this.Name
            Domains  = $this.Domains
            Enabled  = $this.Enabled
            Default  = $this.Default
            Confirm  = $false
        }

        # CASE: Sharing Policy doesn't exist but should;
        if ($this.Ensure -eq 'Present' -and $currentSharingPolicyConfig.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Sharing Policy '$($this.Name)' does not exist but it should. Create and configure it."
            # Create Sharing Policy
            New-SharingPolicy @NewSharingPolicyParams
        }
        # CASE: Sharing Policy exists but it shouldn't;
        elseif ($this.Ensure -eq 'Absent' -and $currentSharingPolicyConfig.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Sharing Policy '$($this.Name)' exists but it shouldn't. Remove it."
            Remove-SharingPolicy -Identity $this.Name -Confirm:$false
        }
        # CASE: Sharing Policy exists and it should, but has different values than the desired ones
        elseif ($this.Ensure -eq 'Present' -and $currentSharingPolicyConfig.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Sharing Policy '$($this.Name)' already exists, but needs updating."
            Write-Verbose -Message "Setting Sharing Policy $($this.Name) with values: $(Convert-M365DscHashtableToString -Hashtable $SetSharingPolicyParams)"
            Set-SharingPolicy @SetSharingPolicyParams
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
            [array]$AllSharingPolicies = Get-SharingPolicy -ErrorAction Stop

            $dscContent = [System.Text.StringBuilder]::new()

            if ($AllSharingPolicies.Length -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }
            $i = 1
            foreach ($SharingPolicy in $AllSharingPolicies)
            {
                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }

                Write-M365DSCHost -Message "    |---[$i/$($AllSharingPolicies.Length)] $($SharingPolicy.Name)" -DeferWrite

                $Params = @{
                    Name                  = $SharingPolicy.Name
                    Credential            = $this.Credential
                    ApplicationId         = $this.ApplicationId
                    TenantId              = $this.TenantId
                    CertificateThumbprint = $this.CertificateThumbprint
                    CertificatePassword   = $this.CertificatePassword
                    ManagedIdentity       = $this.ManagedIdentity
                    CertificatePath       = $this.CertificatePath
                    AccessTokens          = $this.AccessTokens
                }
                $this.ExportedInstance = $SharingPolicy
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

    hidden [EXOSharingPolicy] AsResult([System.Object] $Values)
    {
        if ($Values -is [EXOSharingPolicy])
        {
            return $Values
        }

        $result = [EXOSharingPolicy]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
