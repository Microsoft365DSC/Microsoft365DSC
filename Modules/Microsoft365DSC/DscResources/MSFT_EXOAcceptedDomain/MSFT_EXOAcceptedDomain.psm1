using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class EXOAcceptedDomain : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('Specify the Fully Qualified Domain Name for the AcceptedDomain.')]
    [ValidatePattern( '(?=^.{1,254}$)(^(?:[a-zA-Z0-9_\-]{1,63}(?<!-)\.?)+(?:[a-zA-Z]{2,})$)' )]
    [System.String] $Identity

    [DscProperty()]
    [System.ComponentModel.Description('Specify if the AcceptedDomain should exist or not.')]
    [ValidateSet('Present', 'Absent')]
    [System.String] $Ensure

    [DscProperty()]
    [System.ComponentModel.Description('The type of AcceptedDomain. Currently the EXOAcceptedDomain DSC Resource accepts a value of ''Authoritative'' and ''InternalRelay''.')]
    [ValidateSet('Authoritative', 'InternalRelay')]
    [System.String] $DomainType

    [DscProperty()]
    [System.ComponentModel.Description('The MatchSubDomains parameter must be false on Authoritative domains. The default value is false.')]
    [System.Nullable[System.Boolean]] $MatchSubDomains

    [DscProperty()]
    [System.ComponentModel.Description('OutboundOnly can only be enabled if the DomainType parameter is set to Authoritative or InternalRelay. The default value is false.')]
    [System.Nullable[System.Boolean]] $OutboundOnly

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

    [EXOAcceptedDomain] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [EXOAcceptedDomain]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of Accepted Domain for $($this.Identity)"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.Identity -ne $this.Identity)
            {
                $null = $this.Connect('ExchangeOnline')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullReturn = $this.GetBoundParameters()
                $nullReturn.Ensure = 'Absent'

                Write-Verbose -Message 'Getting all Accepted Domain'
                $AcceptedDomain = Invoke-M365DSCCommand -ScriptBlock { Get-AcceptedDomain -Identity $this.Identity -ErrorAction Stop } -SuppressNotFoundError

                if ($null -eq $AcceptedDomain)
                {
                    Write-Verbose -Message "AcceptedDomain configuration for {$($this.Identity)} does not exist."
                    return $this.AsResult($nullReturn)
                }
            }
            else
            {
                $AcceptedDomain = $this.ExportedInstance
            }

            Write-Verbose -Message "Found AcceptedDomain configuration for $($this.Identity)"

            $result = @{
                DomainType            = $AcceptedDomain.DomainType
                Ensure                = 'Present'
                Identity              = $AcceptedDomain.Identity
                MatchSubDomains       = $AcceptedDomain.MatchSubDomains
                OutboundOnly          = $AcceptedDomain.OutboundOnly
                Credential            = $this.Credential
                ApplicationId         = $this.ApplicationId
                TenantId              = $this.TenantId
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

        Write-Verbose -Message "Setting configuration of Accepted Domain for $($this.Identity)"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        if ($this.MatchSubDomains -eq $true -and $this.DomainType -ne 'InternalRelay')
        {
            throw 'MatchSubDomains can only be enabled on an InternalRelay domain.'
        }

        if ($this.OutboundOnly -eq $true -and $this.DomainType -eq 'ExternalRelay')
        {
            throw 'OutboundOnly can only be enabled if the DomainType parameter is set to Authoritative or InternalRelay.'
        }

        $null = $this.Connect('ExchangeOnline')

        $AcceptedDomainParams = @{
            DomainType      = $this.DomainType
            Identity        = $this.Identity
            MatchSubDomains = $this.MatchSubDomains
            OutboundOnly    = $this.OutboundOnly
        }
        $AcceptedDomainParams = Remove-NullEntriesFromHashtable -Hash $AcceptedDomainParams

        Write-Verbose -Message "Setting AcceptedDomain for {$($this.Identity)} with values: $(Convert-M365DscHashtableToString -Hashtable $AcceptedDomainParams)"
        Set-AcceptedDomain @AcceptedDomainParams
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
            [array]$AllAcceptedDomains = Get-AcceptedDomain -ErrorAction Stop

            $dscContent = [System.Text.StringBuilder]::new()
            $i = 1
            if ($AllAcceptedDomains.Length -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }
            foreach ($domain in $AllAcceptedDomains)
            {
                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }

                Write-M365DSCHost -Message "    |---[$i/$($AllAcceptedDomains.Count)] $($domain.Identity)" -DeferWrite

                $Params = @{
                    Identity              = $domain.Identity
                    ApplicationId         = $this.ApplicationId
                    TenantId              = $this.TenantId
                    CertificateThumbprint = $this.CertificateThumbprint
                    CertificatePassword   = $this.CertificatePassword
                    CertificatePath       = $this.CertificatePath
                    Credential            = $this.Credential
                    ManagedIdentity       = $this.ManagedIdentity
                    AccessTokens          = $this.AccessTokens
                }
                $this.ExportedInstance = $domain
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

    hidden [EXOAcceptedDomain] AsResult([System.Object] $Values)
    {
        if ($Values -is [EXOAcceptedDomain])
        {
            return $Values
        }

        $result = [EXOAcceptedDomain]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
