using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class SCAppRetentionComplianceRule : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The name of the app retention rule.')]
    [System.String] $Name

    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('The name of the app retention policy the rule belongs to. It cannot be changed after the rule is created.')]
    [System.String] $Policy

    [DscProperty()]
    [System.ComponentModel.Description('The comment of the app retention rule.')]
    [System.String] $Comment

    [DscProperty()]
    [System.ComponentModel.Description('The number of units to retain the content for, or Unlimited.')]
    [System.String] $RetentionDuration

    [DscProperty()]
    [System.ComponentModel.Description('The unit of the RetentionDuration.')]
    [ValidateSet('Days', 'Months', 'Years')]
    [System.String] $RetentionDurationDisplayHint

    [DscProperty()]
    [System.ComponentModel.Description('The action to take once the retention duration expires.')]
    [ValidateSet('Delete', 'Keep', 'KeepAndDelete')]
    [System.String] $RetentionComplianceAction

    [DscProperty()]
    [System.ComponentModel.Description('Specifies whether the retention duration counts from the creation or the last modification of the content.')]
    [ValidateSet('CreationAgeInDays', 'ModificationAgeInDays')]
    [System.String] $ExpirationDateOption

    [DscProperty()]
    [System.ComponentModel.Description('Specify if the app retention rule should exist.')]
    [ValidateSet('Present', 'Absent')]
    [System.String] $Ensure

    [DscProperty()]
    [System.ComponentModel.Description('Credentials of the Global Admin')]
    [System.Management.Automation.PSCredential] $Credential

    [DscProperty()]
    [System.ComponentModel.Description('Id of the Entra ID application to authenticate with.')]
    [System.String] $ApplicationId

    [DscProperty()]
    [System.ComponentModel.Description('Id of the Entra ID tenant used for authentication.')]
    [System.String] $TenantId

    [DscProperty()]
    [System.ComponentModel.Description('Thumbprint of the Entra ID application''s authentication certificate to use for authentication.')]
    [System.String] $CertificateThumbprint

    [DscProperty()]
    [System.ComponentModel.Description('Username can be made up to anything but password will be used for CertificatePassword')]
    [System.Management.Automation.PSCredential] $CertificatePassword

    [DscProperty()]
    [System.ComponentModel.Description('Path to certificate used in service principal usually a PFX file.')]
    [System.String] $CertificatePath

    [DscProperty()]
    [System.ComponentModel.Description('Access token used for authentication.')]
    [System.String[]] $AccessTokens

    # Export-only. Not part of the resource schema.
    [System.Management.Automation.PSCredential] $ApplicationSecret

    [SCAppRetentionComplianceRule] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [SCAppRetentionComplianceRule]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of SC App Retention Compliance Rule {$($this.Name)}"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.Name -ne $this.Name)
            {
                $null = $this.Connect('SecurityComplianceCenter')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullResult = $this.GetBoundParameters()
                $nullResult.Ensure = 'Absent'

                $ruleName = $this.Name
                $instance = Invoke-M365DSCCommand -ScriptBlock { Get-AppRetentionComplianceRule -Identity $ruleName -ErrorAction Stop } -SuppressNotFoundError

                if ($null -eq $instance -or $instance.Mode -eq 'PendingDeletion')
                {
                    Write-Verbose -Message "No SC App Retention Compliance Rule with Name {$($this.Name)} was found"
                    return $this.AsResult($nullResult)
                }
            }
            else
            {
                $instance = $this.ExportedInstance
            }

            Write-Verbose -Message "Found SC App Retention Compliance Rule with Name {$($this.Name)}"

            $policyName = $instance.Policy
            $policyObject = Get-AppRetentionCompliancePolicy -Identity $instance.Policy -ErrorAction SilentlyContinue
            if ($null -ne $policyObject)
            {
                $policyName = $policyObject.Name
            }

            $commentValue = $null
            if (-not [System.String]::IsNullOrEmpty($instance.Comment))
            {
                $commentValue = $instance.Comment
            }

            $result = @{
                Name                         = $instance.Name
                Policy                       = $policyName
                Comment                      = $commentValue
                RetentionDuration            = [System.String] $instance.RetentionDuration
                RetentionDurationDisplayHint = [System.String] $instance.RetentionDurationDisplayHint
                RetentionComplianceAction    = [System.String] $instance.RetentionComplianceAction
                ExpirationDateOption         = [System.String] $instance.ExpirationDateOption
                Ensure                       = 'Present'
                Credential                   = $this.Credential
                ApplicationId                = $this.ApplicationId
                TenantId                     = $this.TenantId
                CertificateThumbprint        = $this.CertificateThumbprint
                CertificatePassword          = $this.CertificatePassword
                CertificatePath              = $this.CertificatePath
                AccessTokens                 = $this.AccessTokens
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

        Write-Verbose -Message "Setting configuration of SC App Retention Compliance Rule {$($this.Name)}"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        try
        {
            $null = $this.Connect('SecurityComplianceCenter')

            $currentInstance = $this.Get().ToHashtable()

            $boundParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()

            if ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
            {
                Write-Verbose -Message "Creating new SC App Retention Compliance Rule {$($this.Name)}"

                [SCAppRetentionComplianceRule]::InvokeWithDeploymentRetry('New-AppRetentionComplianceRule', $boundParameters)
            }
            elseif ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Present')
            {
                Write-Verbose -Message "Updating SC App Retention Compliance Rule {$($this.Name)}"

                if ($this.Policy -ne $currentInstance.Policy)
                {
                    throw "SC App Retention Compliance Rule {$($this.Name)} cannot move from policy {$($currentInstance.Policy)} to {$($this.Policy)}. Remove the rule and create it again instead."
                }

                $updateParameters = $boundParameters
                $updateParameters.Remove('Name') | Out-Null
                $updateParameters.Remove('Policy') | Out-Null
                $updateParameters.Identity = $this.Name

                [SCAppRetentionComplianceRule]::InvokeWithDeploymentRetry('Set-AppRetentionComplianceRule', $updateParameters)
            }
            elseif ($this.Ensure -eq 'Absent' -and $currentInstance.Ensure -eq 'Present')
            {
                Write-Verbose -Message "Removing SC App Retention Compliance Rule {$($this.Name)}"

                [SCAppRetentionComplianceRule]::InvokeWithDeploymentRetry('Remove-AppRetentionComplianceRule', @{ Identity = $this.Name; Confirm = $false })
            }
        }
        catch
        {
            $this.LogError($_, 'Error updating data:')

            throw
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
            [array] $exportedInstances = @(Get-AppRetentionComplianceRule -ErrorAction Stop | Where-Object -FilterScript {
                    $_.Mode -ne 'PendingDeletion'
                })

            $dscContent = [System.Text.StringBuilder]::new()
            $i = 1

            if ($exportedInstances.Length -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }

            foreach ($exportedInstance in $exportedInstances)
            {
                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }

                Write-M365DSCHost -Message "    |---[$i/$($exportedInstances.Count)] $($exportedInstance.Name)" -DeferWrite

                $Params = @{
                    Name                  = $exportedInstance.Name
                    Policy                = [System.String] $exportedInstance.Policy
                    Credential            = $this.Credential
                    ApplicationId         = $this.ApplicationId
                    TenantId              = $this.TenantId
                    CertificateThumbprint = $this.CertificateThumbprint
                    CertificatePassword   = $this.CertificatePassword
                    CertificatePath       = $this.CertificatePath
                    AccessTokens          = $this.AccessTokens
                }

                $this.ExportedInstance = $exportedInstance
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
            Write-M365DSCHost -Message $Global:M365DSCEmojiRedX

            $this.LogError($_, 'Error during Export:')

            throw
        }
    }

    # Runs a rule cmdlet, waiting while changes to the policy are still being deployed.
    hidden static [void] InvokeWithDeploymentRetry([System.String] $CommandName, [System.Collections.Hashtable] $Parameters)
    {
        for ($attempt = 1; $attempt -le 10; $attempt++)
        {
            try
            {
                & $CommandName @Parameters -ErrorAction Stop | Out-Null
                return
            }
            catch
            {
                if ($_.Exception.Message -like '*failed to be deployed*')
                {
                    Write-Warning -Message "{$CommandName} succeeded, but the policy failed to be deployed. The service retries the deployment later. $($_.Exception.Message)"
                    return
                }

                if ($attempt -eq 10 -or $_.Exception.Message -notlike '*are being deployed. Once deployed, additional actions can be performed*')
                {
                    throw
                }

                Write-Verbose -Message "Changes to the policy are still being deployed. Retrying {$CommandName} in 30 seconds (attempt $attempt of 10)."
                Start-Sleep -Seconds 30
            }
        }
    }

    hidden [SCAppRetentionComplianceRule] AsResult([System.Object] $Values)
    {
        if ($Values -is [SCAppRetentionComplianceRule])
        {
            return $Values
        }

        $result = [SCAppRetentionComplianceRule]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
