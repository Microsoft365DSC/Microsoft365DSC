using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class EXOHostedConnectionFilterPolicy : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The Identity parameter specifies the Hosted Connection Filter Policy that you want to modify.')]
    [System.String] $Identity

    [DscProperty()]
    [System.ComponentModel.Description('The AdminDisplayName parameter specifies a description for the policy.')]
    [System.String] $AdminDisplayName

    [DscProperty()]
    [System.ComponentModel.Description('The EnableSafeList parameter enables or disables use of the safe list. The safe list is a dynamic allow list in the Microsoft datacenter that requires no customer configuration. Valid input for this parameter is $true or $false. The default value is $false.')]
    [System.Nullable[System.Boolean]] $EnableSafeList

    [DscProperty()]
    [System.ComponentModel.Description('The IPAllowList parameter specifies IP addresses from which messages are always allowed. Messages from the IP addresses you specify won''t be identified as spam, despite any other spam characteristics of the messages. Valid values for this parameter are: A single IP address, an IP address range, a CIDR IP.')]
    [System.String[]] $IPAllowList

    [DscProperty()]
    [System.ComponentModel.Description('The IPBlockList parameter specifies IP addresses from which messages are never allowed. Messages from the IP addresses you specify are blocked without any further spam scanning. Valid values for this parameter are: A single IP address, an IP address range, a CIDR IP.')]
    [System.String[]] $IPBlockList

    [DscProperty()]
    [System.ComponentModel.Description('The MakeDefault parameter makes the specified policy the default connection filter policy. Default is $false.')]
    [System.Nullable[System.Boolean]] $MakeDefault

    [DscProperty()]
    [System.ComponentModel.Description('Specifies if this Hosted Connection Filter Policy should exist.')]
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

    [EXOHostedConnectionFilterPolicy] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [EXOHostedConnectionFilterPolicy]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of HostedConnectionFilterPolicy for $($this.Identity)"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.Identity -ne $this.Identity)
            {
                $null = $this.Connect('ExchangeOnline')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullReturn = $this.GetBoundParameters()
                $nullReturn.Ensure = 'Absent'

                $HostedConnectionFilterPolicy = Get-HostedConnectionFilterPolicy -Identity $this.Identity -ErrorAction SilentlyContinue
                if (-not $HostedConnectionFilterPolicy)
                {
                    Write-Verbose -Message "HostedConnectionFilterPolicy [$($this.Identity)] does not exist."
                    return $this.AsResult($nullReturn)
                }
            }
            else
            {
                $HostedConnectionFilterPolicy = $this.ExportedInstance
            }

            Write-Verbose -Message "Found HostedConnectionFilterPolicy $($this.Identity)"

            $result = @{
                Ensure                = 'Present'
                Identity              = $this.Identity
                AdminDisplayName      = $HostedConnectionFilterPolicy.AdminDisplayName
                EnableSafeList        = $HostedConnectionFilterPolicy.EnableSafeList
                IPAllowList           = $HostedConnectionFilterPolicy.IPAllowList
                IPBlockList           = $HostedConnectionFilterPolicy.IPBlockList
                MakeDefault           = $false
                Credential            = $this.Credential
                ApplicationId         = $this.ApplicationId
                CertificateThumbprint = $this.CertificateThumbprint
                CertificatePath       = $this.CertificatePath
                CertificatePassword   = $this.CertificatePassword
                ManagedIdentity       = $this.ManagedIdentity
                TenantId              = $this.TenantId
                AccessTokens          = $this.AccessTokens
            }

            if ($HostedConnectionFilterPolicy.IsDefault)
            {
                $result.MakeDefault = $true
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

        Write-Verbose -Message "Setting configuration of HostedConnectionFilterPolicy for $($this.Identity)"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $CurrentInstance = $this.Get().ToHashtable()

        $HostedConnectionFilterPolicyParams = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()
        $HostedConnectionFilterPolicyParams.Remove('MakeDefault') | Out-Null

        if ($HostedConnectionFilterPolicyParams.RuleScope)
        {
            $HostedConnectionFilterPolicyParams += @{
                Scope = $HostedConnectionFilterPolicyParams.RuleScope
            }
            $HostedConnectionFilterPolicyParams.Remove('RuleScope') | Out-Null
        }

        if ($this.Ensure -eq 'Present' -and $CurrentInstance.Ensure -eq 'Absent')
        {
            $HostedConnectionFilterPolicyParams += @{
                Name = $HostedConnectionFilterPolicyParams.Identity
            }
            $HostedConnectionFilterPolicyParams.Remove('Identity') | Out-Null
            Write-Verbose -Message "Creating New Policy {$($this.Identity)}"
            New-HostedConnectionFilterPolicy @HostedConnectionFilterPolicyParams

            if ($this.GetBoundParameters().MakeDefault)
            {
                Write-Verbose -Message "Making Policy {$($this.Identity)} the default one"
                $attempt = 1
                while ($true)
                {
                    try
                    {
                        Set-HostedConnectionFilterPolicy -Identity $this.Identity -MakeDefault -Confirm:$false -ErrorAction Stop
                        break
                    }
                    catch
                    {
                        if ($attempt -ge 5 -or -not (Test-M365DSCNotFoundError -ErrorRecord $_))
                        {
                            throw
                        }

                        $attempt++
                        Start-Sleep -Seconds 5
                    }
                }
            }

            Write-Verbose -Message "With Parameters: $(Convert-M365DscHashtableToString -Hashtable $HostedConnectionFilterPolicyParams)"
        }
        elseif ($this.Ensure -eq 'Present' -and $CurrentInstance.Ensure -eq 'Present')
        {
            if ($this.GetBoundParameters().MakeDefault)
            {
                Set-HostedConnectionFilterPolicy @HostedConnectionFilterPolicyParams -MakeDefault -Confirm:$false
            }
            else
            {
                Set-HostedConnectionFilterPolicy @HostedConnectionFilterPolicyParams -Confirm:$false
            }
        }
        elseif ($this.Ensure -eq 'Absent' -and $CurrentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Removing HostedConnectionFilterPolicy $($this.Identity)"
            Remove-HostedConnectionFilterPolicy -Identity $this.Identity -Confirm:$false
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
            [array]$HostedConnectionFilterPolicies = Get-HostedConnectionFilterPolicy
            $dscContent = [System.Text.StringBuilder]::new()

            if ($HostedConnectionFilterPolicies.Length -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }
            $i = 1
            foreach ($HostedConnectionFilterPolicy in $HostedConnectionFilterPolicies)
            {
                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }

                $Params = @{
                    Credential            = $this.Credential
                    Identity              = $HostedConnectionFilterPolicy.Identity
                    ApplicationId         = $this.ApplicationId
                    TenantId              = $this.TenantId
                    CertificateThumbprint = $this.CertificateThumbprint
                    CertificatePassword   = $this.CertificatePassword
                    ManagedIdentity       = $this.ManagedIdentity
                    CertificatePath       = $this.CertificatePath
                    AccessTokens          = $this.AccessTokens
                }
                $this.ExportedInstance = $HostedConnectionFilterPolicy
                Write-M365DSCHost -Message "    |---[$i/$($HostedConnectionFilterPolicies.Length)] $($HostedConnectionFilterPolicy.Identity)" -DeferWrite
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

    hidden [EXOHostedConnectionFilterPolicy] AsResult([System.Object] $Values)
    {
        if ($Values -is [EXOHostedConnectionFilterPolicy])
        {
            return $Values
        }

        $result = [EXOHostedConnectionFilterPolicy]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
