using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class SCDeviceConditionalAccessPolicy : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The name of the Device Conditional Access Policy.')]
    [System.String] $Name

    [DscProperty()]
    [System.ComponentModel.Description('Specify if this policy should exist or not.')]
    [ValidateSet('Present', 'Absent')]
    [System.String] $Ensure

    [DscProperty()]
    [System.ComponentModel.Description('The Comment parameter specifies an optional comment.')]
    [System.String] $Comment

    [DscProperty()]
    [System.ComponentModel.Description('The Enabled parameter specifies whether the policy is enabled.')]
    [System.Nullable[System.Boolean]] $Enabled

    [DscProperty()]
    [System.ComponentModel.Description('Credentials of Security and Compliance Center Admin')]
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

    [SCDeviceConditionalAccessPolicy] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [SCDeviceConditionalAccessPolicy]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of Device Conditional Access Policy for $($this.Name)"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.Name -ne $this.Name)
            {
                $null = $this.Connect('SecurityComplianceCenter')
                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullReturn = $this.GetBoundParameters()
                $nullReturn.Ensure = 'Absent'

                $PolicyObject = Invoke-M365DSCCommand -ScriptBlock { Get-DeviceConditionalAccessPolicy -Identity $this.Name -ErrorAction Stop } -SuppressNotFoundError

                if ($null -eq $PolicyObject)
                {
                    Write-Verbose -Message "Device Conditional Access Policy $($this.Name) does not exist."
                    return $this.AsResult($nullReturn)
                }
            }
            else
            {
                $PolicyObject = $this.ExportedInstance
            }

            Write-Verbose "Found existing Device Conditional Access Policy $($this.Name)"
            $result = @{
                Ensure                = 'Present'
                Name                  = $PolicyObject.Name
                Comment               = $PolicyObject.Comment
                Enabled               = $PolicyObject.Enabled
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

        Write-Verbose -Message "Setting configuration of Device Conditional Access Policy for $($this.Name)"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $CurrentPolicy = $this.Get().ToHashtable()

        if ($this.Ensure -eq 'Present' -and $CurrentPolicy.Ensure -eq 'Absent')
        {
            $CreationParams = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()
            New-DeviceConditionalAccessPolicy @CreationParams
        }
        elseif ($this.Ensure -eq 'Present' -and $CurrentPolicy.Ensure -eq 'Present')
        {
            $CreationParams = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()
            $CreationParams.Remove('Name')
            $CreationParams.Add('Identity', $this.Name)

            Write-Verbose "Updating Policy with values: $(Convert-M365DscHashtableToString -Hashtable $CreationParams)"
            Set-DeviceConditionalAccessPolicy @CreationParams
        }
        elseif ($this.Ensure -eq 'Absent' -and $CurrentPolicy.Ensure -eq 'Present')
        {
            # If the Policy exists and it shouldn't, simply remove it;
            Remove-DeviceConditionalAccessPolicy -Identity $this.Name -Confirm:$false
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
            [array]$policies = Get-DeviceConditionalAccessPolicy -ErrorAction Stop | Where-Object -FilterScript { $_.Mode -ne 'PendingDeletion' }

            $i = 1
            $dscContent = [System.Text.StringBuilder]::new()
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

                Write-M365DSCHost -Message "    |---[$i/$($policies.Length)] $($policy.Name)" -DeferWrite

                $this.ExportedInstance = $policy
                $Results = $this.GetForExport(@{ Name = $policy.Name })
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

    hidden [SCDeviceConditionalAccessPolicy] AsResult([System.Object] $Values)
    {
        if ($Values -is [SCDeviceConditionalAccessPolicy])
        {
            return $Values
        }

        $result = [SCDeviceConditionalAccessPolicy]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
