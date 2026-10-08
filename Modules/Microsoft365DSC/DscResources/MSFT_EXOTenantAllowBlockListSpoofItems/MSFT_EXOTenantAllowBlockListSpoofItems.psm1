using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class EXOTenantAllowBlockListSpoofItems : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The SpoofedUser parameter specifies the email address or domain for the spoofed sender entry.')]
    [System.String] $SpoofedUser

    [DscProperty()]
    [System.ComponentModel.Description('The Action parameter specifies whether is an allowed or blocked spoofed sender entry.')]
    [System.String] $Action

    [DscProperty()]
    [System.ComponentModel.Description('Unique identified for the blocked item.')]
    [System.String] $Identity

    [DscProperty()]
    [System.ComponentModel.Description('The SendingInfrastructure parameter specifies the source of the messages sent by the spoofed sender that''s defined in the SpoofedUser parameter..')]
    [System.String] $SendingInfrastructure

    [DscProperty()]
    [System.ComponentModel.Description('The SpoofType parameter specifies whether this is an internal or external spoofed sender entry.')]
    [System.String] $SpoofType

    [DscProperty()]
    [System.ComponentModel.Description('Present ensures the instance exists, absent ensures it is removed.')]
    [ValidateSet('Absent', 'Present')]
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
    [System.Management.Automation.PSCredential] $ApplicationSecret

    [EXOTenantAllowBlockListSpoofItems] Get()
    {
        $instance = $null
        if ($this.RequiresPowerShellCore())
        {
            $remote = [EXOTenantAllowBlockListSpoofItems]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration for Tenant Allow/Block List Spoof Items with SpoofedUser {$($this.SpoofedUser)}"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.SpoofedUser -ne $this.SpoofedUser)
            {
                $null = $this.Connect('ExchangeOnline')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullResult = $this.GetBoundParameters()
                $nullResult.Ensure = 'Absent'

                if (-not [System.String]::IsNullOrEmpty($this.Identity))
                {
                    $instance = Get-TenantAllowBlockListSpoofItems -Identity $this.Identity -ErrorAction SilentlyContinue
                }
                if ($null -eq $instance)
                {
                    $instance = Get-TenantAllowBlockListSpoofItems | Where-Object -FilterScript { $_.SpoofedUser -eq $this.SpoofedUser }
                }
                if ($null -eq $instance)
                {
                    Write-Verbose -Message "No existing configuration found for SpoofedUser {$($this.SpoofedUser)}"
                    return $this.AsResult($nullResult)
                }
            }
            else
            {
                $instance = $this.ExportedInstance
            }

            Write-Verbose -Message "An EXO Tenant Allow/Block List Spoof Item with SpoofedUser {$($instance.SpoofedUser)} was found."

            $results = @{
                SpoofedUser           = $instance.SpoofedUser
                Identity              = $instance.Identity
                SendingInfrastructure = $instance.SendingInfrastructure
                SpoofType             = $instance.SpoofType
                Action                = $instance.Action
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

        Write-Verbose -Message "Setting configuration for Tenant Allow/Block List Spoof Items with SpoofedUser {$($this.SpoofedUser)}"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $currentInstance = $this.Get().ToHashtable()

        # CREATE
        if ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Creating blocked spoofed item {$($this.SpoofedUser)}"
            $instanceParams = @{
                Action                = $this.Action
                SpoofedUser           = $this.SpoofedUser
                SendingInfrastructure = $this.SendingInfrastructure
                SpoofType             = $this.SpoofType
                Identity              = 'Default'
            }
            New-TenantAllowBlockListSpoofItems @instanceParams
        }
        # UPDATE
        elseif ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Updating blocked spoofed item {$($this.SpoofedUser)}"
            $instanceParams = @{
                Action   = $this.Action
                Ids      = @($currentInstance.Identity)
                Identity = 'Default'
            }
            Set-TenantAllowBlockListSpoofItems @instanceParams
        }
        # REMOVE
        elseif ($this.Ensure -eq 'Absent' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Removing blocked spoofed item {$($this.SpoofedUser)}"
            Remove-TenantAllowBlockListSpoofItems -Identity 'Default' -Ids @($currentInstance.Identity)
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
            [array]$spoofItems = Get-TenantAllowBlockListSpoofItems -ErrorAction Stop

            $i = 1
            $dscContent = [System.Text.StringBuilder]::new()
            if ($spoofItems.Length -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }
            foreach ($config in $spoofItems)
            {
                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }

                $displayedKey = $config.SpoofedUser
                Write-M365DSCHost -Message "    |---[$i/$($spoofItems.Count)] $displayedKey" -DeferWrite
                $params = @{
                    SpoofedUser           = $config.SpoofedUser
                    Identity              = $config.Identity
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
                $Results = $this.GetForExport($params)
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

    hidden [EXOTenantAllowBlockListSpoofItems] AsResult([System.Object] $Values)
    {
        if ($Values -is [EXOTenantAllowBlockListSpoofItems])
        {
            return $Values
        }

        $result = [EXOTenantAllowBlockListSpoofItems]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
