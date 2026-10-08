using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class EXOManagementRole : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The Name parameter specifies the name of the role. The maximum length of the name is 64 characters.')]
    [ValidateLength(1, 64)]
    [System.String] $Name

    [DscProperty(Key)]
    [System.ComponentModel.Description('The Parent parameter specifies the identity of the role to copy. Mandatory for management role creation/update or when Ensure=Present. Non-mandatory for Ensure=Absent')]
    [System.String] $Parent

    [DscProperty()]
    [System.ComponentModel.Description('The Description parameter specifies the description that''s displayed when the management role is viewed using the Get-ManagementRole cmdlet.')]
    [System.String] $Description

    [DscProperty()]
    [System.ComponentModel.Description('Specify if the Management Role should exist or not.')]
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

    [EXOManagementRole] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [EXOManagementRole]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting Management Role configuration for $($this.Name)"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.Name -ne $this.Name)
            {
                $null = $this.Connect('ExchangeOnline')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullReturn = $this.GetBoundParameters()
                $nullReturn.Ensure = 'Absent'

                $ManagementRole = $this.GetManagementRoleWithRetry($this.Name)
                if ($null -eq $ManagementRole)
                {
                    Write-Verbose -Message "Management Role $($this.Name) does not exist."
                    return $this.AsResult($nullReturn)
                }
            }
            else
            {
                $ManagementRole = $this.ExportedInstance
            }

            $result = @{
                Name                  = $ManagementRole.Name
                Parent                = $ManagementRole.Parent
                Description           = $ManagementRole.Description
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

            Write-Verbose -Message "Found Management Role $($this.Name)"
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

        Write-Verbose -Message "Setting Management Role configuration for $($this.Name)"

        $currentManagementRoleConfig = $this.Get().ToHashtable()

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $newManagementRoleParams = @{
            Name        = $this.Name
            Parent      = $this.Parent
            Description = $this.Description
            Confirm     = $false
        }

        # CASE: Management Role doesn't exist but should;
        if ($this.Ensure -eq 'Present' -and $currentManagementRoleConfig.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Management Role '$($this.Name)' does not exist but it should. Create and configure it."
            # Create Management Role
            New-ManagementRole @newManagementRoleParams

        }
        # CASE: Management Role exists but it shouldn't;
        elseif ($this.Ensure -eq 'Absent' -and $currentManagementRoleConfig.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Management Role '$($this.Name)' exists but it shouldn't. Remove it."
            Remove-ManagementRole -Identity $this.Name -Confirm:$false -Force
        }
        # CASE: Management Role exists and it should, but has different values than the desired ones
        elseif ($this.Ensure -eq 'Present' -and $currentManagementRoleConfig.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Management Role '$($this.Name)' already exists, but needs updating. Re-create management role."
            Write-Verbose -Message "Setting Management Role $($this.Name) with values: $(Convert-M365DscHashtableToString -Hashtable $newManagementRoleParams)"
            # Since there is no Set-ManagementRole cmdlet available, remove management role and re-create it
            Remove-ManagementRole -Identity $this.Name -Confirm:$false -Force
            $null = Wait-M365DSCCondition -Description "removal of Management Role {$($newManagementRoleParams.Name)}" -ConsecutiveCount 2 -ScriptBlock {
                $null -eq (Invoke-M365DSCCommand -ScriptBlock { Get-ManagementRole -Identity $newManagementRoleParams.Name -ErrorAction Stop } -SuppressNotFoundError)
            }

            New-ManagementRole @newManagementRoleParams
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
            [array] $exportedInstances = $this.GetManagementRoleWithRetry($null) | Where-Object -FilterScript { $null -ne $_.Parent }

            $dscContent = [System.Text.StringBuilder]::new()

            if ($exportedInstances.Length -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }
            $i = 1
            foreach ($ManagementRole in $exportedInstances)
            {
                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }

                Write-M365DSCHost -Message "    |---[$i/$($exportedInstances.Count)] $($ManagementRole.Name)" -DeferWrite

                $Params = @{
                    Name                  = $ManagementRole.Name
                    Credential            = $this.Credential
                    ApplicationId         = $this.ApplicationId
                    TenantId              = $this.TenantId
                    CertificateThumbprint = $this.CertificateThumbprint
                    CertificatePassword   = $this.CertificatePassword
                    ManagedIdentity       = $this.ManagedIdentity
                    CertificatePath       = $this.CertificatePath
                    Parent                = $ManagementRole.Parent
                    AccessTokens          = $this.AccessTokens
                }
                $this.ExportedInstance = $ManagementRole
                $Results = $this.GetForExport($Params)
                $rawResults = $Results.Clone()
                $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                    -ConnectionMode $ConnectionMode `
                    -ModulePath $this.GetModulePath() `
                    -Results $Results `
                    -Credential $this.Credential `
                    -RawResults $rawResults
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

    hidden [System.Object] GetManagementRoleWithRetry([System.String] $Identity)
    {
        $maxAttempts = 2
        $retryDelayInSeconds = 10

        for ($attempt = 1; $attempt -le $maxAttempts; $attempt++)
        {
            if ([System.String]::IsNullOrEmpty($Identity))
            {
                $managementRole = Invoke-M365DSCCommand -ScriptBlock { Get-ManagementRole -ErrorAction Stop }
                $lookupDescription = 'all management roles'
            }
            else
            {
                $managementRole = Invoke-M365DSCCommand -ScriptBlock { Get-ManagementRole -Identity $Identity -ErrorAction Stop } -SuppressNotFoundError
                $lookupDescription = "management role '$Identity'"
            }

            if ($null -ne $managementRole -and @($managementRole).Count -gt 0)
            {
                return $managementRole
            }

            $message = "Get-ManagementRole returned no results for $lookupDescription on attempt $attempt of $maxAttempts."
            if ($attempt -lt $maxAttempts)
            {
                $message += " Retrying in $retryDelayInSeconds seconds."
            }

            New-M365DSCLogEntry -Message $message `
                -Source $this.GetResourceName() `
                -TenantId $this.TenantId `
                -Credential $this.Credential

            if ($attempt -lt $maxAttempts)
            {
                Start-Sleep -Seconds $retryDelayInSeconds
            }
        }

        return $null
    }

    hidden [EXOManagementRole] AsResult([System.Object] $Values)
    {
        if ($Values -is [EXOManagementRole])
        {
            return $Values
        }

        $result = [EXOManagementRole]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
