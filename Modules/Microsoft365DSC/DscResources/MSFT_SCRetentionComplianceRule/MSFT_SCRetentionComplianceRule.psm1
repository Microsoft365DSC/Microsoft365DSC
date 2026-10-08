using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class SCRetentionComplianceRule : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The Name parameter specifies the unique name of the retention rule.')]
    [System.String] $Name

    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('The Policy parameter specifies the policy to contain the rule.')]
    [System.String] $Policy

    [DscProperty()]
    [System.ComponentModel.Description('Specify if this rule should exist or not.')]
    [ValidateSet('Present', 'Absent')]
    [System.String] $Ensure

    [DscProperty()]
    [System.ComponentModel.Description('The Comment parameter specifies an optional comment.')]
    [System.String] $Comment

    [DscProperty()]
    [System.ComponentModel.Description('The ExpirationDateOption parameter specifies whether the expiration date is calculated from the content creation date or last modification date. Valid values are: CreationAgeInDays and ModificationAgeInDays.')]
    [ValidateSet('CreationAgeInDays', 'ModificationAgeInDays')]
    [System.String] $ExpirationDateOption

    [DscProperty()]
    [System.ComponentModel.Description('The ExcludedItemClasses parameter specifies the types of messages to exclude from the rule. You can use this parameter only to exclude items from a hold policy, which excludes the specified item class from being held. Using this parameter won''t exclude items from deletion policies. Typically, you use this parameter to exclude voicemail messages, IM conversations, and other Skype for Business Online content from being held by a hold policy.')]
    [System.String[]] $ExcludedItemClasses

    [DscProperty()]
    [System.ComponentModel.Description('The ContentMatchQuery parameter specifies a content search filter.')]
    [System.String] $ContentMatchQuery

    [DscProperty()]
    [System.ComponentModel.Description('The RetentionComplianceAction parameter specifies the retention action for the rule. Valid values are: Delete, Keep and KeepAndDelete.')]
    [ValidateSet('Delete', 'Keep', 'KeepAndDelete')]
    [System.String] $RetentionComplianceAction

    [DscProperty()]
    [System.ComponentModel.Description('The RetentionDuration parameter specifies the hold duration for the retention rule. Valid values are: An integer - The hold duration in days, Unlimited - The content is held indefinitely.')]
    [System.String] $RetentionDuration

    [DscProperty()]
    [System.ComponentModel.Description('The RetentionDurationDisplayHint parameter specifies the units that are used to display the retention duration in the Security and Compliance Center. Valid values are: Days, Months or Years.')]
    [ValidateSet('Days', 'Months', 'Years')]
    [System.String] $RetentionDurationDisplayHint

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

    [SCRetentionComplianceRule] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [SCRetentionComplianceRule]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of RetentionComplianceRule for $($this.Name)"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.Name -ne $this.Name)
            {
                $null = $this.Connect('SecurityComplianceCenter')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullReturn = $this.GetBoundParameters()
                $nullReturn.Ensure = 'Absent'

                $RuleObject = Invoke-M365DSCCommand -ScriptBlock { Get-RetentionComplianceRule -Identity $this.Name -ErrorAction Stop } -SuppressNotFoundError

                if ($null -eq $RuleObject -or $RuleObject.Mode -eq 'PendingDeletion')
                {
                    Write-Verbose -Message "RetentionComplianceRule $($this.Name) does not exist."
                    return $this.AsResult($nullReturn)
                }
            }
            else
            {
                $RuleObject = $this.ExportedInstance
            }

            Write-Verbose "Found existing RetentionComplianceRule $($this.Name)"
            $AssociatedPolicy = Invoke-M365DSCCommand -ScriptBlock { Get-RetentionCompliancePolicy -Identity $RuleObject.Policy -ErrorAction Stop }
            $RetentionComplianceActionValue = $null
            if (-not [System.String]::IsNullOrEmpty($ruleObject.RetentionComplianceAction))
            {
                $RetentionComplianceActionValue = $RuleObject.RetentionComplianceAction
            }
            $result = @{
                Name                         = $RuleObject.Name
                Comment                      = $RuleObject.Comment
                Policy                       = $AssociatedPolicy.Name
                RetentionDuration            = $RuleObject.RetentionDuration
                RetentionComplianceAction    = $RetentionComplianceActionValue
                RetentionDurationDisplayHint = $RuleObject.RetentionDurationDisplayHint
                ExpirationDateOption         = $RuleObject.ExpirationDateOption
                Ensure                       = 'Present'
                Credential                   = $this.Credential
                ApplicationId                = $this.ApplicationId
                TenantId                     = $this.TenantId
                CertificateThumbprint        = $this.CertificateThumbprint
                CertificatePath              = $this.CertificatePath
                CertificatePassword          = $this.CertificatePassword
                ManagedIdentity              = $this.ManagedIdentity
                AccessTokens                 = $this.AccessTokens
            }
            if (-not $associatedPolicy.TeamsPolicy)
            {
                $result.Add('ExcludedItemClasses', $RuleObject.ExcludedItemClasses)
                $result.Add('ContentMatchQuery', $RuleObject.ContentMatchQuery)
            }

            Write-Verbose -Message "Found RetentionComplianceRule $($this.Name)"
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

        Write-Verbose -Message "Setting configuration of RetentionComplianceRule for $($this.Name)"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $CurrentRule = $this.Get().ToHashtable()

        if ($this.Ensure -eq 'Present' -and $CurrentRule.Ensure -eq 'Absent')
        {
            $CreationParams = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()

            Write-Verbose -Message 'Checking to see if the policy is a Teams based one.'
            $RuleObject = Get-RetentionComplianceRule -Identity $this.Name `
                -ErrorAction SilentlyContinue
            $AssociatedPolicy = Get-RetentionCompliancePolicy $this.Policy

            if ($AssociatedPolicy.TeamsPolicy)
            {
                Write-Verbose -Message 'The current policy is a Teams based one, removing invalid parameters for Creation.'
                if ($CreationParams.ContainsKey('ApplyComplianceTag'))
                {
                    $CreationParams.Remove('ApplyComplianceTag') | Out-Null
                }
                if ($CreationParams.ContainsKey('ContentContainsSensitiveInformation'))
                {
                    $CreationParams.Remove('ContentContainsSensitiveInformation') | Out-Null
                }
                if ($CreationParams.ContainsKey('ContentMatchQuery'))
                {
                    $CreationParams.Remove('ContentMatchQuery') | Out-Null
                }
                if ($CreationParams.ContainsKey('ExcludedItemClasses'))
                {
                    $CreationParams.Remove('ExcludedItemClasses') | Out-Null
                }
                if ($CreationParams.ContainsKey('ExpirationDateOption'))
                {
                    $CreationParams.Remove('ExpirationDateOption') | Out-Null
                }
                if ($CreationParams.ContainsKey('PublishComplianceTag'))
                {
                    $CreationParams.Remove('PublishComplianceTag') | Out-Null
                }
                if ($CreationParams.ContainsKey('RetentionDurationDisplayHint'))
                {
                    $CreationParams.Remove('RetentionDurationDisplayHint') | Out-Null
                }
            }

            Write-Verbose -Message "Creating new RetentionComplianceRule with values:`r`n$(Convert-M365DscHashtableToString -Hashtable $CreationParams)"
            try
            {
                New-RetentionComplianceRule @CreationParams -ErrorAction Stop
            }
            catch
            {
                if ($_.Exception.Message -notlike '*failed to be deployed*')
                {
                    throw
                }

                Write-Warning -Message "The creation succeeded, but the policy failed to be deployed. The service retries the deployment later. $($_.Exception.Message)"
            }
        }
        elseif ($this.Ensure -eq 'Present' -and $CurrentRule.Ensure -eq 'Present')
        {
            $CreationParams = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()
            $CreationParams.Remove('Name')
            $CreationParams.Add('Identity', $this.Name)
            $CreationParams.Remove('Policy')

            Write-Verbose -Message 'Checking to see if the policy is a Teams based one.'
            $RuleObject = Get-RetentionComplianceRule -Identity $this.Name `
                -ErrorAction SilentlyContinue
            $AssociatedPolicy = Get-RetentionCompliancePolicy $RuleObject.Policy

            if ($AssociatedPolicy.TeamsPolicy)
            {
                Write-Verbose -Message 'The current policy is a Teams based one, removing invalid parameters for Update.'

                if ($CreationParams.ContainsKey('ApplyComplianceTag'))
                {
                    $CreationParams.Remove('ApplyComplianceTag') | Out-Null
                }
                if ($CreationParams.ContainsKey('ContentContainsSensitiveInformation'))
                {
                    $CreationParams.Remove('ContentContainsSensitiveInformation') | Out-Null
                }
                if ($CreationParams.ContainsKey('ContentMatchQuery'))
                {
                    $CreationParams.Remove('ContentMatchQuery') | Out-Null
                }
                if ($CreationParams.ContainsKey('ExcludedItemClasses'))
                {
                    $CreationParams.Remove('ExcludedItemClasses') | Out-Null
                }
                if ($CreationParams.ContainsKey('ExpirationDateOption'))
                {
                    $CreationParams.Remove('ExpirationDateOption') | Out-Null
                }
                if ($CreationParams.ContainsKey('PublishComplianceTag'))
                {
                    $CreationParams.Remove('PublishComplianceTag') | Out-Null
                }
                if ($CreationParams.ContainsKey('RetentionDurationDisplayHint'))
                {
                    $CreationParams.Remove('RetentionDurationDisplayHint') | Out-Null
                }
            }

            Write-Verbose -Message "Updating RetentionComplianceRule with values:`r`n$(Convert-M365DscHashtableToString -Hashtable $CreationParams)"

            $success = $false
            $retries = 1
            while (!$success -and $retries -le 10)
            {
                try
                {
                    Set-RetentionComplianceRule @CreationParams -ErrorAction Stop
                    $success = $true
                }
                catch
                {
                    if ($_.Exception.Message -like '*failed to be deployed*')
                    {
                        Write-Warning -Message "The update succeeded, but the policy failed to be deployed. The service retries the deployment later. $($_.Exception.Message)"
                        $success = $true
                    }
                    elseif ($_.Exception.Message -like '*are being deployed. Once deployed, additional actions can be performed*' -and $retries -lt 10)
                    {
                        Write-Verbose -Message "The associated policy has pending changes being deployed. Waiting 30 seconds for a maximum of 300 seconds (5 minutes). Total time waited so far {$($retries * 30) seconds}"
                        Start-Sleep -Seconds 30
                    }
                    else
                    {
                        throw
                    }
                }
                $retries++
            }
        }
        elseif ($this.Ensure -eq 'Absent' -and $CurrentRule.Ensure -eq 'Present')
        {
            # If the Rule exists and it shouldn't, simply remove it;
            try
            {
                Remove-RetentionComplianceRule -Identity $this.Name -Confirm:$false -ErrorAction Stop
            }
            catch
            {
                if ($_.Exception.Message -notlike '*failed to be deployed*')
                {
                    throw
                }

                Write-Warning -Message "The removal succeeded, but the policy failed to be deployed. The service retries the deployment later. $($_.Exception.Message)"
            }

            $this.CompleteDeletion($this.Name)
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
            [array]$policies = @(Get-RetentionCompliancePolicy -ErrorAction Stop | Where-Object -FilterScript { $_.Mode -ne 'PendingDeletion' })

            $j = 1
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
                [array]$rules = @(Get-RetentionComplianceRule -Policy $policy.Name | Where-Object -FilterScript { $_.Mode -ne 'PendingDeletion' })
                Write-M365DSCHost -Message "    Policy [$j/$($policies.Length)] $($policy.Name)"
                $i = 1

                foreach ($rule in $rules)
                {
                    if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                    {
                        $Global:M365DSCExportResourceInstancesCount++
                    }

                    Write-M365DSCHost -Message "        |---[$i/$($rules.Length)] $($rule.Name)" -DeferWrite

                    $this.ExportedInstance = $rule
                    $Results = $this.GetForExport(@{ Name = $rule.Name; Policy = $rule.Policy })
                    $rawResults = $Results.Clone()

                    if ([System.String]::IsNullOrEmpty($Results.ExpirationDateOption))
                    {
                        $Results.Remove('ExpirationDateOption') | Out-Null
                    }
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
                $j++
            }
            return $dscContent.ToString()
        }
        catch
        {
            $this.LogError($_, 'Error during Export:')

            throw
        }
    }

    hidden [void] CompleteDeletion([System.String] $Identity)
    {
        for ($attempt = 1; $attempt -le 10; $attempt++)
        {
            try
            {
                Remove-RetentionComplianceRule -Identity $Identity -ForceDeletion -Confirm:$false -ErrorAction Stop
                return
            }
            catch
            {
                if ($_.Exception.Message -like '*failed to be deployed*')
                {
                    Write-Warning -Message "The deletion succeeded, but the policy failed to be deployed. The service retries the deployment later. $($_.Exception.Message)"
                    return
                }

                if ($_.Exception.Message -notlike '*are being deployed. Once deployed, additional actions can be performed*' -or $attempt -eq 10)
                {
                    throw
                }

                Write-Verbose -Message "The policy has pending changes being deployed. Waiting 30 seconds for a maximum of 300 seconds (5 minutes). Total time waited so far {$($attempt * 30) seconds}"
                Start-Sleep -Seconds 30
            }
        }
    }

    hidden [SCRetentionComplianceRule] AsResult([System.Object] $Values)
    {
        if ($Values -is [SCRetentionComplianceRule])
        {
            return $Values
        }

        $result = [SCRetentionComplianceRule]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
