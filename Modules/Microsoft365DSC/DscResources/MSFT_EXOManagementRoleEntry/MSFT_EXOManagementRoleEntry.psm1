using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class EXOManagementRoleEntry : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The Identity parameter specifies the role entry that you want to modify.')]
    [System.String] $Identity

    [DscProperty()]
    [System.ComponentModel.Description('The Parameters parameter specifies the parameters to be added to or removed from the role entry.')]
    [System.String[]] $Parameters

    [DscProperty()]
    [System.ComponentModel.Description('The Type parameter specifies the type of role entry to return.')]
    [ValidateSet('Cmdlet', 'Script', 'ApplicationPermission', 'WebService')]
    [System.String] $Type

    [DscProperty()]
    [System.ComponentModel.Description('Specify if the Management Role entry should exist or not.')]
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

    [EXOManagementRoleEntry] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [EXOManagementRoleEntry]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting Management Role Entry configuration for {$($this.Identity)}"

        $boundParameters = $this.GetBoundParameters()

        try
        {
            if (-not $this.ExportedInstance -or ($this.ExportedInstance.Identity + '\' + $this.ExportedInstance.Name) -ne $this.Identity)
            {
                $null = $this.Connect('ExchangeOnline')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $roleEntry = Get-ManagementRoleEntry -Identity $this.Identity -ResultSize 'Unlimited' -ErrorAction SilentlyContinue

                if ($null -eq $roleEntry)
                {
                    Write-Verbose -Message "Management Role Entry {$($this.Identity)} does not exist."
                    $nullReturn = $boundParameters
                    $nullReturn.Ensure = 'Absent'
                    return $this.AsResult($nullReturn)
                }
            }
            else
            {
                $roleEntry = $this.ExportedInstance
            }

            $result = @{
                Identity              = $this.Identity
                Parameters            = $roleEntry.Parameters
                Type                  = $roleEntry.Type
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

            Write-Verbose -Message "Found Management Role Entry {$($this.Identity)}."
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

        Write-Verbose -Message "Setting Management Role Entry configuration for {$($this.Identity)}"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $currentValues = $this.Get().ToHashtable()

        if ($currentValues.Ensure -eq 'Absent' -and $this.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Creating new Management Role Entry {$($this.Identity)}"
            $params = @{
                Identity = $this.Identity
            }

            if ($null -ne $this.Parameters -and $this.Parameters.Length -gt 0)
            {
                $params.Add('Parameters', $this.Parameters)
            }

            if (-not [System.String]::IsNullOrEmpty($this.Type))
            {
                $params.Add('Type', $this.Type)
            }

            Add-ManagementRoleEntry @params
        }
        elseif ($currentValues.Ensure -eq 'Present' -and $this.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Updating Management Role Entry {$($this.Identity)}"
            $paramDifference = Compare-Object -ReferenceObject $currentValues.Parameters -DifferenceObject $this.Parameters

            $paramsToAdd = $paramDifference | Where-Object -FilterScript { $_.SideIndicator -eq '=>' }
            $paramsToAddEntries = @()
            foreach ($diff in $paramsToAdd)
            {
                $paramsToAddEntries += $diff.InputObject.ToString()
            }
            if ($paramsToAddEntries.Count -gt 0)
            {
                Write-Verbose -Message "Adding the following parameters to {$($this.Identity)}: $($paramsToAddEntries -join ',')"
                Set-ManagementRoleEntry -Identity $this.Identity -AddParameter -Parameters $paramsToAddEntries
            }

            $paramsToRemove = $paramDifference | Where-Object -FilterScript { $_.SideIndicator -eq '<=' }
            $paramsToRemoveEntries = @()
            foreach ($diff in $paramsToRemove)
            {
                $paramsToRemoveEntries += $diff.InputObject.ToString()
            }
            if ($paramsToRemoveEntries.Count -gt 0)
            {
                Write-Verbose -Message "Removing the following parameters to {$($this.Identity)}: $($paramsToRemoveEntries -join ',')"
                Set-ManagementRoleEntry -Identity $this.Identity -RemoveParameter -Parameters $paramsToRemoveEntries
            }
        }
        elseif ($currentValues.Ensure -eq 'Present' -and $this.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Removing Management Role Entry {$($this.Identity)}"
            Remove-ManagementRoleEntry -Identity $this.Identity -Confirm:$false
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
            [array] $exportedInstances = Get-ManagementRoleEntry -Identity '*\*' -ResultSize 'Unlimited'
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
            foreach ($roleEntry in $exportedInstances)
            {
                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }

                Write-M365DSCHost -Message "    |---[$i/$($exportedInstances.Count)] $($roleEntry.Identity + '\' + $roleEntry.Name)" -DeferWrite

                $Params = @{
                    Identity              = $roleEntry.Identity + '\' + $roleEntry.Name
                    Credential            = $this.Credential
                    ApplicationId         = $this.ApplicationId
                    TenantId              = $this.TenantId
                    CertificateThumbprint = $this.CertificateThumbprint
                    CertificatePassword   = $this.CertificatePassword
                    ManagedIdentity       = $this.ManagedIdentity
                    CertificatePath       = $this.CertificatePath
                    AccessTokens          = $this.AccessTokens
                }
                $this.ExportedInstance = $roleEntry
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

    hidden [EXOManagementRoleEntry] AsResult([System.Object] $Values)
    {
        if ($Values -is [EXOManagementRoleEntry])
        {
            return $Values
        }

        $result = [EXOManagementRoleEntry]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
