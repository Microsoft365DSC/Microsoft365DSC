using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class EXOMailboxAuditBypassAssociation : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The Identity parameter specifies the user account or computer account where you want to view the value of the AuditBypassEnabled property.')]
    [System.String] $Identity

    [DscProperty()]
    [System.ComponentModel.Description('The AuditBypassEnabled parameter specifies whether audit bypass is enabled for the user or computer.')]
    [System.Nullable[System.Boolean]] $AuditBypassEnabled

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

    [EXOMailboxAuditBypassAssociation] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [EXOMailboxAuditBypassAssociation]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of Mailbox Audit Bypass Association with Identity $($this.Identity)"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.Identity -ne $this.Identity)
            {
                $null = $this.Connect('ExchangeOnline')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullResult = $this.GetBoundParameters()
                $nullResult.Ensure = 'Absent'

                # We need the Where-Object clause because calling the cmdlet by Identity only can retrieve similar
                # patterns.
                $instance = Get-MailboxAuditBypassAssociation -Identity $this.Identity.Replace("`r", '') -ErrorAction SilentlyContinue
                $instance = $instance | Where-Object -FilterScript { $_.Identity -eq $this.Identity.Replace("`r", '') }
                if ($null -eq $instance)
                {
                    Write-Verbose -Message "Mailbox Audit Bypass Association with Identity $($this.Identity) not found"
                    return $this.AsResult($nullResult)
                }
            }
            else
            {
                $instance = $this.ExportedInstance
            }

            $results = @{
                Identity              = [System.String]$this.Identity
                AuditBypassEnabled    = [System.Boolean]$instance.AuditBypassEnabled
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

        Write-Verbose -Message "Setting configuration of Mailbox Audit Bypass Association with Identity $($this.Identity)"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $null = $this.Get().ToHashtable()
        $setParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()
        Set-MailboxAuditBypassAssociation @SetParameters
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

        #region Telemetry
        $this.AddTelemetry('Export')
        #endregion

        try
        {
            [array]$associations = Get-MailboxAuditBypassAssociation -ErrorAction Stop | Sort-Object -Property Identity

            $i = 1
            $dscContent = [System.Text.StringBuilder]::new()
            if ($associations.Length -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }
            foreach ($config in $associations)
            {
                $displayedKey = $config.Identity
                Write-M365DSCHost -Message "    |---[$i/$($associations.Count)] $displayedKey" -DeferWrite
                $params = @{
                    Identity              = $config.Identity.Replace("`r", '')
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

    hidden [EXOMailboxAuditBypassAssociation] AsResult([System.Object] $Values)
    {
        if ($Values -is [EXOMailboxAuditBypassAssociation])
        {
            return $Values
        }

        $result = [EXOMailboxAuditBypassAssociation]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
