using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class EXOActiveSyncDeviceAccessRule : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The Identity parameter specifies the identity of the device access rule.')]
    [System.String] $Identity

    [DscProperty()]
    [System.ComponentModel.Description('The AccessLevel parameter specifies whether the devices are allowed, blocked or quarantined.')]
    [ValidateSet('Allow', 'Block', 'Quarantine')]
    [System.String] $AccessLevel

    [DscProperty()]
    [System.ComponentModel.Description('The Characteristic parameter specifies the device characteristic or category that''s used by the rule.')]
    [ValidateSet('DeviceModel', 'DeviceType', 'DeviceOS', 'UserAgent', 'XMSWLHeader')]
    [System.String] $Characteristic

    [DscProperty()]
    [System.ComponentModel.Description('The QueryString parameter specifies the device identifier that''s used by the rule. This parameter uses a text value that''s used with Characteristic parameter value to define the device.')]
    [System.String] $QueryString

    [DscProperty()]
    [System.ComponentModel.Description('Specify if the Active Sync Device Access Rule should exist or not.')]
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

    [EXOActiveSyncDeviceAccessRule] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [EXOActiveSyncDeviceAccessRule]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting Active Sync Device Access Rule configuration for $($this.Identity)"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.Identity -ne $this.Identity)
            {
                $null = $this.Connect('ExchangeOnline')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullReturn = $this.GetBoundParameters()
                $nullReturn.Ensure = 'Absent'

                $ActiveSyncDeviceAccessRule = Get-ActiveSyncDeviceAccessRule -Identity "$($this.QueryString) ($($this.Characteristic))" -ErrorAction SilentlyContinue
                if ($null -eq $ActiveSyncDeviceAccessRule)
                {
                    Write-Verbose -Message 'Trying to retrieve instance by Identity'
                    $ActiveSyncDeviceAccessRule = Get-ActiveSyncDeviceAccessRule -Identity $this.Identity -ErrorAction 'SilentlyContinue'

                    if ($null -eq $ActiveSyncDeviceAccessRule)
                    {
                        Write-Verbose -Message "Active Sync Device Access Rule $($this.Identity) does not exist."
                        return $this.AsResult($nullReturn)
                    }
                }
            }
            else
            {
                $ActiveSyncDeviceAccessRule = $this.ExportedInstance
            }

            Write-Verbose -Message "Found Active Sync Device Access Rule $($this.Identity)"

            $result = @{
                Identity              = $ActiveSyncDeviceAccessRule.Identity
                AccessLevel           = $ActiveSyncDeviceAccessRule.AccessLevel
                Characteristic        = $ActiveSyncDeviceAccessRule.Characteristic
                QueryString           = $ActiveSyncDeviceAccessRule.QueryString
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

        Write-Verbose -Message "Setting Active Sync Device Access Rule configuration for $($this.Identity)"

        $currentActiveSyncDeviceAccessRuleConfig = $this.Get().ToHashtable()

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $null = $this.Connect('ExchangeOnline')

        $NewActiveSyncDeviceAccessRuleParams = @{
            AccessLevel    = $this.AccessLevel
            Characteristic = $this.Characteristic
            QueryString    = $this.QueryString
            Confirm        = $false
        }

        $SetActiveSyncDeviceAccessRuleParams = @{
            Identity    = "$($this.QueryString) ($($this.Characteristic))"
            AccessLevel = $this.AccessLevel
            Confirm     = $false
        }

        # CASE: Active Sync Device Access Rule doesn't exist but should;
        if ($this.Ensure -eq 'Present' -and $currentActiveSyncDeviceAccessRuleConfig.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Active Sync Device Access Rule '$($this.Identity)' does not exist but it should. Create and configure it."
            # Create Active Sync Device Access Rule
            New-ActiveSyncDeviceAccessRule @NewActiveSyncDeviceAccessRuleParams

        }
        # CASE: Active Sync Device Access Rule exists but it shouldn't;
        elseif ($this.Ensure -eq 'Absent' -and $currentActiveSyncDeviceAccessRuleConfig.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Active Sync Device Access Rule '$($this.Identity)' exists but it shouldn't. Remove it."
            Remove-ActiveSyncDeviceAccessRule -Identity $currentActiveSyncDeviceAccessRuleConfig.Identity -Confirm:$false
        }
        # CASE: Active Sync Device Access Rule exists and it should, but has different values than the desired ones
        elseif ($this.Ensure -eq 'Present' -and $currentActiveSyncDeviceAccessRuleConfig.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Active Sync Device Access Rule '$($this.Identity)' already exists, but needs updating."
            $SetActiveSyncDeviceAccessRuleParams.Identity = $currentActiveSyncDeviceAccessRuleConfig.Identity
            Write-Verbose -Message "Setting Active Sync Device Access Rule $($this.Identity) with values: $(Convert-M365DscHashtableToString -Hashtable $SetActiveSyncDeviceAccessRuleParams)"
            Set-ActiveSyncDeviceAccessRule @SetActiveSyncDeviceAccessRuleParams
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
            [array]$AllActiveSyncDeviceAccessRules = Get-ActiveSyncDeviceAccessRule -ErrorAction Stop

            $dscContent = [System.Text.StringBuilder]::new()
            $i = 1
            if ($AllActiveSyncDeviceAccessRules.Length -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }
            foreach ($ActiveSyncDeviceAccessRule in $AllActiveSyncDeviceAccessRules)
            {
                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }

                Write-M365DSCHost -Message "    |---[$i/$($AllActiveSyncDeviceAccessRules.Count)] $($ActiveSyncDeviceAccessRule.Identity)" -DeferWrite

                $Params = @{
                    Identity              = $ActiveSyncDeviceAccessRule.Identity
                    Credential            = $this.Credential
                    ApplicationId         = $this.ApplicationId
                    TenantId              = $this.TenantId
                    CertificateThumbprint = $this.CertificateThumbprint
                    CertificatePassword   = $this.CertificatePassword
                    ManagedIdentity       = $this.ManagedIdentity
                    CertificatePath       = $this.CertificatePath
                    AccessTokens          = $this.AccessTokens
                }
                $this.ExportedInstance = $ActiveSyncDeviceAccessRule
                $Results = $this.GetForExport($Params)
                $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                    -ConnectionMode $ConnectionMode `
                    -ModulePath $this.GetModulePath() `
                    -Results $Results `
                    -Credential $this.Credential
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
                [void]$dscContent.Append($currentDSCBlock)

                Save-M365DSCPartialExport -Content $currentDSCBlock `
                    -FileName $Global:PartialExportFileName
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

    hidden [EXOActiveSyncDeviceAccessRule] AsResult([System.Object] $Values)
    {
        if ($Values -is [EXOActiveSyncDeviceAccessRule])
        {
            return $Values
        }

        $result = [EXOActiveSyncDeviceAccessRule]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
