using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class SCUnifiedAuditLogRetentionPolicy : M365DSCResourceBase
{
    [DscProperty()]
    [System.ComponentModel.Description('The description for the audit log retention policy')]
    [System.String] $Description

    [DscProperty(Key)]
    [System.ComponentModel.Description('Unique name for the audit log retention policy')]
    [System.String] $Name

    [DscProperty()]
    [System.ComponentModel.Description('Specifies the audit log operations that are retained by the policy')]
    [System.String[]] $Operations

    [DscProperty()]
    [System.ComponentModel.Description('Priority value for the policy that determines the order of policy processing.')]
    [System.Nullable[System.UInt32]] $Priority

    [DscProperty()]
    [System.ComponentModel.Description('Specifies the audit logs of a specific record type that are retained by the policy.')]
    [System.String[]] $RecordTypes

    [DscProperty()]
    [System.ComponentModel.Description('How long audit log records are kept')]
    [ValidateSet('SevenDays', 'OneMonth', 'ThreeMonths', 'SixMonths', 'NineMonths', 'TwelveMonths', 'ThreeYears', 'FiveYears', 'SevenYears', 'TenYears')]
    [System.String] $RetentionDuration

    [DscProperty()]
    [System.ComponentModel.Description('Specifies the audit logs that are retained by the policy based on the ID of the user who performed the action')]
    [System.String[]] $UserIds

    [DscProperty()]
    [System.ComponentModel.Description('Present ensures the instance exists, absent ensures it is removed.')]
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
    [System.ComponentModel.Description('Secret of the Azure Active Directory tenant used for authentication.')]
    [System.Management.Automation.PSCredential] $ApplicationSecret

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
    [System.ComponentModel.Description('Access tokens used for authentication in scenarios requiring multiple tokens.')]
    [System.String[]] $AccessTokens

    [SCUnifiedAuditLogRetentionPolicy] Get()
    {
        $nullResult = $null
        if ($this.RequiresPowerShellCore())
        {
            $remote = [SCUnifiedAuditLogRetentionPolicy]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of SC Unified Audit Log Retention Policy for $($this.Name)"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.Name -ne $this.Name)
            {
                $null = $this.Connect('SecurityComplianceCenter')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullResult = $this.GetBoundParameters()
                $nullResult.Ensure = 'Absent'

                [array]$instances = @(Invoke-M365DSCCommand -ScriptBlock { Get-UnifiedAuditLogRetentionPolicy -ErrorAction Stop | Where-Object { $_.Mode -ne 'PendingDeletion' } } -SuppressNotFoundError)
                if ($null -eq $instances)
                {
                    return $this.AsResult($nullResult)
                }

                $instance = $instances | Where-Object { $_.Name -eq $this.Name } | Select-Object -First 1
            }
            else
            {
                $instance = $this.ExportedInstance
            }

            if ($null -eq $instance)
            {
                return $this.AsResult($nullResult)
            }

            Write-Verbose -Message "Found an SC Unified Audit Log Retention Policy with Name {$($this.Name)}"
            $results = @{
                Identity              = $instance.Identity
                Description           = $instance.Description
                Name                  = $instance.Name
                Operations            = $instance.Operations
                Priority              = $instance.Priority
                RecordTypes           = $instance.RecordTypes
                RetentionDuration     = $instance.RetentionDuration
                UserIds               = $instance.UserIds
                Ensure                = 'Present'
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

        Write-Verbose -Message "Setting configuration of SC Unified Audit Log Retention Policy for $($this.Name)"

        $null = $this.Connect('SecurityComplianceCenter')

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $GetParameters = ([Hashtable]$this.GetBoundParameters()).Clone()
        $GetParameters.Remove('Description') | Out-Null
        $GetParameters.Remove('Operations') | Out-Null
        $GetParameters.Remove('RecordTypes') | Out-Null
        $GetParameters.Remove('UserIds') | Out-Null

        $currentInstance = $this.GetForExport($GetParameters)
        $boundParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()

        if ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
        {
            $pendingDeletion = Get-UnifiedAuditLogRetentionPolicy -ErrorAction Stop | Where-Object -FilterScript { $_.Name -eq $this.Name -and $_.Mode -eq 'PendingDeletion' }
            if ($null -ne $pendingDeletion)
            {
                Write-Verbose -Message "Completing the pending deletion of the Unified Audit Log Retention Policy with Name {$($this.Name)}"
                Remove-UnifiedAuditLogRetentionPolicy -Identity $this.Name -ForceDeletion -Confirm:$false
            }

            $createParameters = ([Hashtable]$boundParameters).Clone()
            Write-Verbose -Message "Creating a Unified Audit Log Retention Policy with Name {$($this.Name)}"
            New-UnifiedAuditLogRetentionPolicy @createParameters | Out-Null
        }
        elseif ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Updating the Unified Audit Log Retention Policy with Name {$($this.Name)}"

            $updateParameters = ([Hashtable]$boundParameters).Clone()
            $updateParameters.Remove('Name') | Out-Null
            $updateParameters.Add('Identity', $this.Name) | Out-Null
            Set-UnifiedAuditLogRetentionPolicy @updateParameters | Out-Null
        }
        elseif ($this.Ensure -eq 'Absent' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Removing the Unified Audit Log Retention Policy with Name {$($this.Name)}"
            Remove-UnifiedAuditLogRetentionPolicy -Identity $this.Name -Confirm:$false
            Remove-UnifiedAuditLogRetentionPolicy -Identity $this.Name -ForceDeletion -Confirm:$false
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

        $ConnectionMode = $this.Connect('SecurityComplianceCenter')

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Export')

        try
        {
            [array]$getValue = @(Get-UnifiedAuditLogRetentionPolicy -ErrorAction Stop | Where-Object { $_.Mode -ne 'PendingDeletion' })

            $i = 1
            $dscContent = [System.Text.StringBuilder]::new()
            if ($getValue.Length -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }
            foreach ($config in $getValue)
            {
                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }

                $displayedKey = $config.Name
                if (-not [String]::IsNullOrEmpty($config.displayName))
                {
                    $displayedKey = $config.displayName
                }
                Write-M365DSCHost -Message "    |---[$i/$($getValue.Count)] $displayedKey" -DeferWrite
                $params = @{
                    Name                  = $config.Name
                    Priority              = $config.Priority
                    RetentionDuration     = $config.RetentionDuration
                    Ensure                = 'Present'
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

                $this.ExportedInstance = $config
                $Results = $this.GetForExport($Params)
                $Results.Remove('Identity') | Out-Null

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

    [System.Collections.Hashtable] GetCompareParameters()
    {
        return @{
            ExcludedProperties = @('Name')
        }
    }

    hidden [SCUnifiedAuditLogRetentionPolicy] AsResult([System.Object] $Values)
    {
        if ($Values -is [SCUnifiedAuditLogRetentionPolicy])
        {
            return $Values
        }

        $result = [SCUnifiedAuditLogRetentionPolicy]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
