using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class SCFilePlanPropertyAuthority : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The Name parameter specifies the unique name of the Authority.')]
    [System.String] $Name

    [DscProperty()]
    [System.ComponentModel.Description('Specify if this authority should exist or not.')]
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

    [SCFilePlanPropertyAuthority] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [SCFilePlanPropertyAuthority]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of SCFilePlanPropertyAuthority for $($this.Name)"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.Name -ne $this.Name)
            {
                $null = $this.Connect('SecurityComplianceCenter')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullReturn = $this.GetBoundParameters()
                $nullReturn.Ensure = 'Absent'

                $property = Get-FilePlanPropertyAuthority -ErrorAction Stop | Where-Object -FilterScript { $_.DisplayName -eq $this.Name -and "$($_.Mode)" -ne 'PendingDeletion' }

                if ($null -eq $property)
                {
                    Write-Verbose -Message "SCFilePlanPropertyAuthority $($this.Name) does not exist."
                    return $this.AsResult($nullReturn)
                }
            }
            else
            {
                $property = $this.ExportedInstance
            }

            Write-Verbose "Found existing SCFilePlanPropertyAuthority $($this.Name)"

            $result = @{
                Name                  = $property.DisplayName
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

        Write-Verbose -Message "Setting configuration of SCFilePlanPropertyAuthority for $($this.Name)"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $Current = $this.Get().ToHashtable()

        if ($this.Ensure -eq 'Present' -and $Current.Ensure -eq 'Absent')
        {
            $CreationParams = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()
            New-FilePlanPropertyAuthority @CreationParams
        }
        elseif ($this.Ensure -eq 'Present' -and $Current.Ensure -eq 'Present')
        {
            # Do Nothing
        }
        elseif ($this.Ensure -eq 'Absent' -and $Current.Ensure -eq 'Present')
        {
            try
            {
                $property = Get-FilePlanPropertyAuthority | Where-Object -FilterScript { $_.DisplayName -eq $this.Name }
                if ($null -eq $property)
                {
                    Write-Verbose -Message "Property $($this.Name) was not found."
                }
                elseif ("$($property.Mode)" -ne 'PendingDeletion')
                {
                    Remove-FilePlanPropertyAuthority -Identity $this.Name -Confirm:$false -ErrorAction Stop
                }
                else
                {
                    Write-Verbose -Message "Property $($this.Name) is already in the process of being deleted."
                }
            }
            catch
            {
                $this.LogError($_, "Error removing the file plan property $($this.Name)")

                throw
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
            [array]$Properties = Get-FilePlanPropertyAuthority -ErrorAction Stop

            $i = 1
            $dscContent = [System.Text.StringBuilder]::new()
            if ($Properties.Length -eq 0)
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }
            else
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            foreach ($Property in $Properties)
            {
                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }

                Write-M365DSCHost -Message "    |---[$i/$($Properties.Length)] $($Property.Name)" -DeferWrite

                $this.ExportedInstance = $Property
                $Results = $this.GetForExport(@{ Name = $Property.DisplayName })
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

    hidden [SCFilePlanPropertyAuthority] AsResult([System.Object] $Values)
    {
        if ($Values -is [SCFilePlanPropertyAuthority])
        {
            return $Values
        }

        $result = [SCFilePlanPropertyAuthority]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
