using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class SCAuditConfigurationPolicy : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('Workload associated with the policy.')]
    [ValidateSet('Exchange', 'SharePoint', 'OneDriveForBusiness')]
    [System.String] $Workload

    [DscProperty()]
    [System.ComponentModel.Description('Specify if this policy should exist or not.')]
    [ValidateSet('Present', 'Absent')]
    [System.String] $Ensure

    [DscProperty()]
    [System.ComponentModel.Description('Credentials of the Global Admin')]
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

    [SCAuditConfigurationPolicy] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [SCAuditConfigurationPolicy]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of SCAuditConfigurationPolicy for Workload {$($this.Workload)}"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.Workload -ne $this.Workload)
            {
                $null = $this.Connect('SecurityComplianceCenter')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullReturn = $this.GetBoundParameters()
                $nullReturn.Ensure = 'Absent'

                $PolicyObject = $null
                Write-Verbose -Message "Current Workload = {$($this.Workload)}"

                if ($this.Workload -eq 'OneDriveForBusiness')
                {
                    $PolicyObject = Get-AuditConfigurationPolicy | Where-Object -FilterScript { $_.Name -eq 'a415dcce-19a0-4153-b137-eb6fd67995b5' }
                }
                else
                {
                    $PolicyObject = Get-AuditConfigurationPolicy | Where-Object -FilterScript { $_.Workload -eq $this.Workload }
                }

                if ($null -eq $PolicyObject)
                {
                    Write-Verbose -Message "SCAuditConfigurationPolicy $($this.Workload) does not exist."
                    return $this.AsResult($nullReturn)
                }
            }
            else
            {
                $PolicyObject = $this.ExportedInstance
            }

            Write-Verbose -Message "Found existing SCAuditConfigurationPolicy $($this.Workload)"
            $result = @{
                Ensure                = 'Present'
                Workload              = $this.Workload
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

        Write-Verbose -Message "Setting configuration of SCAuditConfigurationPolicy for $($this.Workload)"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $CurrentPolicy = $this.Get().ToHashtable()

        if ($this.Ensure -eq 'Present' -and $CurrentPolicy.Ensure -eq 'Absent')
        {
            $CreationParams = @{Workload = $this.Workload }
            New-AuditConfigurationPolicy @CreationParams
        }
        elseif ($this.Ensure -eq 'Present' -and $CurrentPolicy.Ensure -eq 'Present')
        {
            Write-Verbose "SCAuditConfigurationPolicy already exists for Workload {$($this.Workload)}"
        }
        elseif ($this.Ensure -eq 'Absent' -and $CurrentPolicy.Ensure -eq 'Present')
        {
            # If the Policy exists and it shouldn't, simply remove it;
            Write-Verbose "Removing SCAuditConfigurationPolicy for Workload {$($this.Workload)}"
            if ($this.Workload -eq 'OneDriveForBusiness')
            {
                $policy = Get-AuditConfigurationPolicy | Where-Object -FilterScript { $_.Name -eq 'a415dcce-19a0-4153-b137-eb6fd67995b5' }
            }
            else
            {
                $policy = Get-AuditConfigurationPolicy | Where-Object -FilterScript { $_.Workload -eq $CurrentPolicy.Workload }
            }

            try
            {
                Remove-AuditConfigurationPolicy -Identity $policy.Identity -ErrorAction Stop
            }
            catch
            {
                Write-Verbose -Message "Policy for $($this.Workload) is already in the process of being deleted."
                $this.LogError($_, "Error removing the audit configuration policy for $($this.Workload)")
            }
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
            [array]$policies = Get-AuditConfigurationPolicy -ErrorAction Stop
            $dscContent = [System.Text.StringBuilder]::new()
            $i = 1
            if ($policies.Length -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }
            foreach ($policy in $policies)
            {
                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }

                Write-M365DSCHost -Message "    |---[$i/$($policies.Length)] $($policy.Workload)" -DeferWrite

                $this.ExportedInstance = $policy
                $Results = $this.GetForExport(@{ Workload = $policy.Workload })
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

    hidden [SCAuditConfigurationPolicy] AsResult([System.Object] $Values)
    {
        if ($Values -is [SCAuditConfigurationPolicy])
        {
            return $Values
        }

        $result = [SCAuditConfigurationPolicy]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
