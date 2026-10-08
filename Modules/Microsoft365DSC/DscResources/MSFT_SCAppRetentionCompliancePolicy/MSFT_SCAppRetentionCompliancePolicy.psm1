using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class SCAppRetentionCompliancePolicy : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The name of the app retention policy.')]
    [System.String] $Name

    [DscProperty()]
    [System.ComponentModel.Description('The apps the policy applies to, in the format <LocationType>:<App>, for example User:MicrosoftTeamsChannelMessages or Group:Yammer. Separate several apps of the same location type with a comma inside a single entry.')]
    [System.String[]] $Applications

    [DscProperty()]
    [System.ComponentModel.Description('The names of the adaptive scopes the policy applies to. An adaptive policy cannot use any other location, and a policy cannot switch between adaptive and static locations.')]
    [System.String[]] $AdaptiveScopeLocation

    [DscProperty()]
    [System.ComponentModel.Description('The mailboxes to include in a static policy, or All.')]
    [System.String[]] $ExchangeLocation

    [DscProperty()]
    [System.ComponentModel.Description('The mailboxes to exclude when ExchangeLocation is All.')]
    [System.String[]] $ExchangeLocationException

    [DscProperty()]
    [System.ComponentModel.Description('The Microsoft 365 groups to include in a static policy, or All.')]
    [System.String[]] $ModernGroupLocation

    [DscProperty()]
    [System.ComponentModel.Description('The Microsoft 365 groups to exclude when ModernGroupLocation is All.')]
    [System.String[]] $ModernGroupLocationException

    [DscProperty()]
    [System.ComponentModel.Description('The comment of the app retention policy.')]
    [System.String] $Comment

    [DscProperty()]
    [System.ComponentModel.Description('Specifies whether the policy is enabled.')]
    [System.Nullable[System.Boolean]] $Enabled

    [DscProperty()]
    [System.ComponentModel.Description('Specifies whether Preservation Lock is enabled for the policy. Once enabled, it cannot be turned off.')]
    [System.Nullable[System.Boolean]] $RestrictiveRetention

    [DscProperty()]
    [System.ComponentModel.Description('Specify if the app retention policy should exist.')]
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

    [SCAppRetentionCompliancePolicy] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [SCAppRetentionCompliancePolicy]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of SC App Retention Compliance Policy {$($this.Name)}"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.Name -ne $this.Name)
            {
                $null = $this.Connect('SecurityComplianceCenter')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullResult = $this.GetBoundParameters()
                $nullResult.Ensure = 'Absent'

                $policyName = $this.Name
                $instance = Invoke-M365DSCCommand -ScriptBlock { Get-AppRetentionCompliancePolicy -Identity $policyName -DistributionDetail -ErrorAction Stop } -SuppressNotFoundError

                if ($null -eq $instance -or $instance.Mode -eq 'PendingDeletion')
                {
                    Write-Verbose -Message "No SC App Retention Compliance Policy with Name {$($this.Name)} was found"
                    return $this.AsResult($nullResult)
                }
            }
            else
            {
                $instance = $this.ExportedInstance
            }

            Write-Verbose -Message "Found SC App Retention Compliance Policy with Name {$($this.Name)}"

            $commentValue = $null
            if (-not [System.String]::IsNullOrEmpty($instance.Comment))
            {
                $commentValue = $instance.Comment
            }

            $result = @{
                Name                         = $instance.Name
                Applications                 = [System.String[]] $instance.Applications
                AdaptiveScopeLocation        = [System.String[]] $instance.AdaptiveScopeLocation.Name
                ExchangeLocation             = [System.String[]] $instance.ExchangeLocation.Name
                ExchangeLocationException    = [System.String[]] $instance.ExchangeLocationException.Name
                ModernGroupLocation          = [System.String[]] $instance.ModernGroupLocation.Name
                ModernGroupLocationException = [System.String[]] $instance.ModernGroupLocationException.Name
                Comment                      = $commentValue
                Enabled                      = $instance.Enabled
                RestrictiveRetention         = $instance.RestrictiveRetention
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

        Write-Verbose -Message "Setting configuration of SC App Retention Compliance Policy {$($this.Name)}"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        try
        {
            $null = $this.Connect('SecurityComplianceCenter')

            $currentInstance = $this.Get().ToHashtable()

            $boundParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()

            $staticLocationNames = @('ExchangeLocation', 'ExchangeLocationException', 'ModernGroupLocation', 'ModernGroupLocationException')
            $isAdaptive = @($this.AdaptiveScopeLocation | Where-Object -FilterScript { -not [System.String]::IsNullOrEmpty($_) }).Count -gt 0
            if ($this.Ensure -eq 'Present' -and $isAdaptive -and @($staticLocationNames | Where-Object -FilterScript { $boundParameters.ContainsKey($_) }).Count -gt 0)
            {
                throw "SC App Retention Compliance Policy {$($this.Name)} cannot combine AdaptiveScopeLocation with static locations."
            }

            if ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
            {
                Write-Verbose -Message "Creating new SC App Retention Compliance Policy {$($this.Name)}"

                [SCAppRetentionCompliancePolicy]::InvokeWithDeploymentRetry('New-AppRetentionCompliancePolicy', $boundParameters)
            }
            elseif ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Present')
            {
                Write-Verbose -Message "Updating SC App Retention Compliance Policy {$($this.Name)}"

                if ($isAdaptive -ne (@($currentInstance.AdaptiveScopeLocation | Where-Object -FilterScript { -not [System.String]::IsNullOrEmpty($_) }).Count -gt 0))
                {
                    throw "SC App Retention Compliance Policy {$($this.Name)} cannot switch between adaptive and static locations. Remove the policy and create it again instead."
                }

                $updateParameters = $boundParameters
                $updateParameters.Remove('Name') | Out-Null
                $updateParameters.Identity = $this.Name

                foreach ($locationName in @('AdaptiveScopeLocation') + $staticLocationNames)
                {
                    if (-not $updateParameters.ContainsKey($locationName))
                    {
                        continue
                    }

                    $desired = @($updateParameters[$locationName])
                    $current = @($currentInstance[$locationName] | Where-Object -FilterScript { -not [System.String]::IsNullOrEmpty($_) })
                    $toRemove = @($current | Where-Object -FilterScript { $_ -notin $desired })
                    $toAdd = @($desired | Where-Object -FilterScript { $_ -notin $current })
                    if ($toRemove.Count -gt 0)
                    {
                        $updateParameters["Remove$locationName"] = $toRemove
                    }
                    if ($toAdd.Count -gt 0)
                    {
                        $updateParameters["Add$locationName"] = $toAdd
                    }
                    $updateParameters.Remove($locationName) | Out-Null
                }

                [SCAppRetentionCompliancePolicy]::InvokeWithDeploymentRetry('Set-AppRetentionCompliancePolicy', $updateParameters)
            }
            elseif ($this.Ensure -eq 'Absent' -and $currentInstance.Ensure -eq 'Present')
            {
                Write-Verbose -Message "Removing SC App Retention Compliance Policy {$($this.Name)}"

                [SCAppRetentionCompliancePolicy]::InvokeWithDeploymentRetry('Remove-AppRetentionCompliancePolicy', @{ Identity = $this.Name; Confirm = $false })
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
            [array] $exportedInstances = @(Get-AppRetentionCompliancePolicy -DistributionDetail -ErrorAction Stop | Where-Object -FilterScript {
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

    # Runs a policy cmdlet, waiting while changes to the policy are still being deployed.
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

    hidden [SCAppRetentionCompliancePolicy] AsResult([System.Object] $Values)
    {
        if ($Values -is [SCAppRetentionCompliancePolicy])
        {
            return $Values
        }

        $result = [SCAppRetentionCompliancePolicy]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
