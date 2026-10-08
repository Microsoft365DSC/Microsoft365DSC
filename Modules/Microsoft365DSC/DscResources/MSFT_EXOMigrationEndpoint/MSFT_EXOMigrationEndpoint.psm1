using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class EXOMigrationEndpoint : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('Identity of the migration endpoint.')]
    [System.String] $Identity

    [DscProperty()]
    [System.ComponentModel.Description('Specifies whether to accept untrusted certificates.')]
    [System.Nullable[System.Boolean]] $AcceptUntrustedCertificates

    [DscProperty()]
    [System.ComponentModel.Description('The Application ID used for authentication.')]
    [System.String] $AppID

    [DscProperty()]
    [System.ComponentModel.Description('The URL of the Key Vault that stores the application secret.')]
    [System.String] $AppSecretKeyVaultUrl

    [DscProperty()]
    [System.ComponentModel.Description('The authentication method for the migration endpoint.')]
    [System.String] $Authentication

    [DscProperty()]
    [System.ComponentModel.Description('The type of migration endpoint.')]
    [ValidateSet('IMAP', 'ExchangeRemoteMove')]
    [System.String] $EndpointType

    [DscProperty()]
    [System.ComponentModel.Description('The Exchange Server address for the migration endpoint.')]
    [System.String] $ExchangeServer

    [DscProperty()]
    [System.ComponentModel.Description('The mailbox permission for the migration endpoint.')]
    [System.String] $MailboxPermission

    [DscProperty()]
    [System.ComponentModel.Description('The maximum number of concurrent incremental syncs.')]
    [System.String] $MaxConcurrentIncrementalSyncs

    [DscProperty()]
    [System.ComponentModel.Description('The maximum number of concurrent migrations.')]
    [System.String] $MaxConcurrentMigrations

    [DscProperty()]
    [System.ComponentModel.Description('The NSPI server for the migration endpoint.')]
    [System.String] $NspiServer

    [DscProperty()]
    [System.ComponentModel.Description('The port number for the migration endpoint.')]
    [System.String] $Port

    [DscProperty()]
    [System.ComponentModel.Description('The remote server for the migration endpoint.')]
    [System.String] $RemoteServer

    [DscProperty()]
    [System.ComponentModel.Description('The remote tenant for the migration endpoint.')]
    [System.String] $RemoteTenant

    [DscProperty()]
    [System.ComponentModel.Description('The RPC proxy server for the migration endpoint.')]
    [System.String] $RpcProxyServer

    [DscProperty()]
    [System.ComponentModel.Description('The security level for the migration endpoint.')]
    [ValidateSet('None', 'Tls', 'Ssl')]
    [System.String] $Security

    [DscProperty()]
    [System.ComponentModel.Description('The legacy distinguished name of the source mailbox.')]
    [System.String] $SourceMailboxLegacyDN

    [DscProperty()]
    [System.ComponentModel.Description('Specifies whether to use AutoDiscover.')]
    [System.Nullable[System.Boolean]] $UseAutoDiscover

    [DscProperty()]
    [System.ComponentModel.Description('Specifies if the migration endpoint should exist or not.')]
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
    [System.Management.Automation.PSCredential] $ApplicationSecret

    [EXOMigrationEndpoint] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [EXOMigrationEndpoint]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting Migration Endpoint configuration for $($this.Identity)"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.Identity -ne $this.Identity)
            {
                $null = $this.Connect('ExchangeOnline')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullResult = $this.GetBoundParameters()
                $nullResult.Ensure = 'Absent'

                $migrationEndpoint = Get-MigrationEndpoint -Identity $this.Identity -ErrorAction SilentlyContinue
                if ($null -eq $migrationEndpoint)
                {
                    Write-Verbose -Message "Migration Endpoint with Identity $($this.Identity) not found"
                    return $this.AsResult($nullResult)
                }
            }
            else
            {
                $migrationEndpoint = $this.ExportedInstance
            }

            Write-Verbose -Message "Migration Endpoint with Identity $($migrationEndpoint.Identity) found."

            $results = @{
                Identity                      = $this.Identity
                AcceptUntrustedCertificates   = $migrationEndpoint.AcceptUntrustedCertificates
                AppID                         = $migrationEndpoint.AppID
                AppSecretKeyVaultUrl          = $migrationEndpoint.AppSecretKeyVaultUrl
                Authentication                = $migrationEndpoint.Authentication
                EndpointType                  = $migrationEndpoint.EndpointType
                ExchangeServer                = $migrationEndpoint.ExchangeServer
                MailboxPermission             = $migrationEndpoint.MailboxPermission
                MaxConcurrentIncrementalSyncs = $migrationEndpoint.MaxConcurrentIncrementalSyncs
                MaxConcurrentMigrations       = $migrationEndpoint.MaxConcurrentMigrations
                NspiServer                    = $migrationEndpoint.NspiServer
                Port                          = $migrationEndpoint.Port
                RemoteServer                  = $migrationEndpoint.RemoteServer
                RemoteTenant                  = $migrationEndpoint.RemoteTenant
                RpcProxyServer                = $migrationEndpoint.RpcProxyServer
                Security                      = $migrationEndpoint.Security
                SourceMailboxLegacyDN         = $migrationEndpoint.SourceMailboxLegacyDN
                UseAutoDiscover               = $migrationEndpoint.UseAutoDiscover
                Ensure                        = 'Present'
                Credential                    = $this.Credential
                ApplicationId                 = $this.ApplicationId
                TenantId                      = $this.TenantId
                CertificateThumbprint         = $this.CertificateThumbprint
                CertificatePath               = $this.CertificatePath
                CertificatePassword           = $this.CertificatePassword
                ManagedIdentity               = $this.ManagedIdentity
                AccessTokens                  = $this.AccessTokens
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

        Write-Verbose -Message "Setting Migration Endpoint configuration for $($this.Identity)"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $currentInstance = $this.Get().ToHashtable()

        $setParams = ([Hashtable]$this.GetBoundParameters()).Clone()
        $setParams = Remove-M365DSCAuthenticationParameter -BoundParameters $setParams
        $setParams.Remove('RemoteTenant')
        $setParams.Remove('EndpointType')
        $setParams.Remove('UseAutoDiscover')
        $setParams.Add('Confirm', $false)

        $newParams = ([Hashtable]$this.GetBoundParameters()).Clone()
        $newParams = Remove-M365DSCAuthenticationParameter -BoundParameters $newParams
        $newParams.Remove('EndpointType')
        $newParams.Remove('Identity')
        $newParams.Add('Name', $this.Identity)
        $newParams.Add('Confirm', [Switch]$false)

        if ($this.EndpointType -eq 'IMAP')
        {
            # Removing mailbox permission parameter as this is valid only for outlook anywhere migration
            $setParams.Remove('MailboxPermission')
            $newParams.Remove('MailboxPermission')

            # adding skip verification switch to skip verifying
            # that the remote server is reachable when creating a migration endpoint.
            $setParams.Add('SkipVerification', [Switch]$true)
            $newParams.Add('SkipVerification', [Switch]$true)

            $newParams.Add('IMAP', [Switch]$true)
        }
        elseif ($this.EndpointType -eq 'ExchangeRemoteMove')
        {
            # Removing mailbox permission parameter as this is valid only for outlook anywhere migration
            $setParams.Remove('MailboxPermission') | Out-Null
            $newParams.Remove('MailboxPermission') | Out-Null
            $newParams.Remove('AcceptUntrustedCertificates') | Out-Null
            $setParams.Remove('AcceptUntrustedCertificates') | Out-Null

            # adding skip verification switch to skip verifying
            # that the remote server is reachable when creating a migration endpoint.
            $setParams.Add('SkipVerification', [Switch]$true)
            $newParams.Add('SkipVerification', [Switch]$true)

            $newParams.Add('ExchangeRemoteMove', [Switch]$true)
        }

        # add the logic for other endpoint types ('Exchange Remote', 'Outlook Anywhere', 'Google Workspace')

        # CREATE
        if ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Creating new migration endpoint with parameters:`r`n$(ConvertTo-Json $newParams -Depth 10)"
            New-MigrationEndpoint @newParams
        }
        # UPDATE
        elseif ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Updating migration endpoint with parameters:`r`n$(ConvertTo-Json $setParams -Depth 10)"
            Set-MigrationEndpoint @setParams
        }
        # REMOVE
        elseif ($this.Ensure -eq 'Absent' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Removing migration endpoint with id {$($this.Identity)}"
            Remove-MigrationEndpoint -Identity $this.Identity
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
            [array] $migrationEndpoints = Get-MigrationEndpoint -ErrorAction Stop

            $i = 1
            $dscContent = [System.Text.StringBuilder]::new()
            if ($migrationEndpoints.Length -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }
            foreach ($config in $migrationEndpoints)
            {
                $displayedKey = $config.Identity
                Write-M365DSCHost -Message "    |---[$i/$($migrationEndpoints.Count)] $displayedKey" -DeferWrite
                $params = @{
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

    hidden [EXOMigrationEndpoint] AsResult([System.Object] $Values)
    {
        if ($Values -is [EXOMigrationEndpoint])
        {
            return $Values
        }

        $result = [EXOMigrationEndpoint]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
