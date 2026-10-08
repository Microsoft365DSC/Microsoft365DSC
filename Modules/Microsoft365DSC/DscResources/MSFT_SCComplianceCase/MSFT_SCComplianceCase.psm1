using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class SCComplianceCase : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The Name parameter specifies the unique name of the compliance case.')]
    [System.String] $Name

    [DscProperty()]
    [System.ComponentModel.Description('The description of the case.')]
    [System.String] $Description

    [DscProperty()]
    [System.ComponentModel.Description('Specify if this case should exist or not.')]
    [ValidateSet('Present', 'Absent')]
    [System.String] $Ensure

    [DscProperty()]
    [System.ComponentModel.Description('Status for the case. Can either be ''Active'' or ''Closed''')]
    [ValidateSet('Active', 'Closed')]
    [System.String] $Status

    [DscProperty()]
    [System.ComponentModel.Description('Credentials of the Global Admin Account')]
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

    [SCComplianceCase] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [SCComplianceCase]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of SCComplianceCase for $($this.Name)"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.Name -ne $this.Name)
            {
                $null = $this.Connect('SecurityComplianceCenter')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullReturn = $this.GetBoundParameters()
                $nullReturn.Ensure = 'Absent'

                $Case = Invoke-M365DSCCommand -ScriptBlock { Get-ComplianceCase -Identity $this.Name -ErrorAction Stop } -SuppressNotFoundError

                if ($null -eq $Case)
                {
                    Write-Verbose -Message "SCComplianceCase $($this.Name) does not exist."
                    return $this.AsResult($nullReturn)
                }
            }
            else
            {
                $Case = $this.ExportedInstance
            }

            Write-Verbose "Found existing SCComplianceCase $($this.Name)"
            $currentStatus = $Case.Status
            if ('Closing' -eq $currentStatus)
            {
                $currentStatus = 'Closed'
            }
            $result = @{
                Name                  = $Case.Name
                Description           = $Case.Description
                Status                = $currentStatus
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

        Write-Verbose -Message "Setting configuration of SCComplianceCase for $($this.Name)"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $CurrentCase = $this.Get().ToHashtable()

        if ($this.Ensure -eq 'Present' -and $CurrentCase.Ensure -eq 'Absent')
        {
            $CreationParams = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()
            $CreationParams.Remove('Status')

            Write-Verbose "Creating new Compliance Case $($this.Name) calling the New-ComplianceCase cmdlet."
            New-ComplianceCase @CreationParams

            # There is a possibility that the new case has to be closed to begin with (could be for future re-open);
            if ('Closed' -eq $this.Status)
            {
                Set-ComplianceCase -Identity $this.Name -Close
            }
        }
        # Compliance Case exists and it should. Update it.
        elseif ($this.Ensure -eq 'Present' -and $CurrentCase.Ensure -eq 'Present')
        {
            # The only real value we can update is the description;
            if ($CurrentCase.Description -ne $this.Description)
            {
                Set-ComplianceCase -Identity $this.Name -Description $this.Description
            }

            # Compliance case is currently Active, but should be Closed; Close it.
            if ('Active' -eq $CurrentCase.Status -and 'Closed' -eq $this.Status)
            {
                Set-ComplianceCase -Identity $this.Name -Close
            }

            # Compliance Case is currently Closed, but should be active. Re-open it.
            if ('Closed' -eq $CurrentCase.Status -and 'Active' -eq $this.Status)
            {
                Set-ComplianceCase -Identity $this.Name -Reopen
            }
        }
        # Compliance Case exists but it shouldn't. Remove it.
        elseif ($this.Ensure -eq 'Absent' -and $CurrentCase.Ensure -eq 'Present')
        {
            Remove-ComplianceCase -Identity $this.Name -Confirm:$false
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
            [array]$Cases = Get-ComplianceCase -ErrorAction Stop

            $dscContent = [System.Text.StringBuilder]::new()
            $i = 1
            if ($Cases.Length -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }
            foreach ($Case in $Cases)
            {
                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }

                Write-M365DSCHost -Message "    eDiscovery: [$i/$($Cases.Count)] $($Case.Name)" -DeferWrite

                $this.ExportedInstance = $Case
                $Results = $this.GetForExport(@{ Name = $Case.Name })
                $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                    -ConnectionMode $ConnectionMode `
                    -ModulePath $this.GetModulePath() `
                    -Results $Results `
                    -Credential $this.Credential
                [void]$dscContent.Append($currentDSCBlock)
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
                $i++
            }

            [array]$Cases = Get-ComplianceCase -CaseType 'DSR' -ErrorAction Stop

            $i = 1
            foreach ($Case in $Cases)
            {
                Write-M365DSCHost -Message "    GDPR: [$i/$($Cases.Count)] $($Case.Name)" -DeferWrite
                $Results = $this.GetForExport(@{ Name = $Case.Name })
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

    hidden [SCComplianceCase] AsResult([System.Object] $Values)
    {
        if ($Values -is [SCComplianceCase])
        {
            return $Values
        }

        $result = [SCComplianceCase]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
