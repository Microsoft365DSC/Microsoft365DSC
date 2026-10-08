using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class AADLifecycleWorkflowSettings : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('Only valid value is ''Yes''.')]
    [ValidateSet('Yes')]
    [System.String] $IsSingleInstance

    [DscProperty()]
    [System.ComponentModel.Description('Specifies the domain that should be used when sending email notifications. This domain must be verified in order to be used. We recommend that you use a domain that has the appropriate DNS records to facilitate email validation, like SPF, DKIM, DMARC, and MX, because this then complies with the RFC compliance for sending and receiving email. For details, see Learn more about Exchange Online Email Routing.')]
    [System.String] $SenderDomain

    [DscProperty()]
    [System.ComponentModel.Description('The interval in hours at which all workflows running in the tenant should be scheduled for execution. This interval has a minimum value of 1 and a maximum value of 24. The default value is 3 hours.')]
    [System.Nullable[System.UInt32]] $WorkflowScheduleIntervalInHours

    [DscProperty()]
    [System.ComponentModel.Description('Specifies if the organization''s banner logo should be included in email notifications. The banner logo will replace the Microsoft logo at the top of the email notification. If true the banner logo will be taken from the tenant''s branding settings. This value can only be set to true if the organizationalBranding bannerLogo property is set.')]
    [System.Nullable[System.Boolean]] $UseCompanyBranding

    [DscProperty()]
    [System.ComponentModel.Description('The tenant-level quarantine configuration that automatically halts a workflow when its threshold conditions are met.')]
    [MSFT_MicrosoftGraphquarantineConfiguration] $QuarantineConfiguration

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
    [System.ComponentModel.Description('Access token used for authentication.')]
    [System.String[]] $AccessTokens

    [AADLifecycleWorkflowSettings] Get()
    {
        $nullResult = $null
        if ($this.RequiresPowerShellCore())
        {
            $remote = [AADLifecycleWorkflowSettings]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message 'Getting the AAD Lifecycle Workflow Settings'

        try
        {
            if (-not $this.ExportedInstance)
            {
                $null = $this.Connect('MicrosoftGraph')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullResult = $this.GetBoundParameters()
                $instance = Get-MgBetaIdentityGovernanceLifecycleWorkflowSetting -ErrorAction SilentlyContinue
            }
            else
            {
                $instance = $this.ExportedInstance
            }

            if ($null -eq $instance)
            {
                return $this.AsResult($nullResult)
            }

            $complexQuarantineConditions = @()
            foreach ($currentQuarantineCondition in $instance.QuarantineConfiguration.Conditions)
            {
                $myQuarantineCondition = [ordered]@{}
                $myQuarantineCondition.Add('Percentage', $currentQuarantineCondition.Percentage)
                $myQuarantineCondition.Add('Threshold', $currentQuarantineCondition.Threshold)
                if ($null -ne $currentQuarantineCondition.'@odata.type')
                {
                    $myQuarantineCondition.Add('odataType', $currentQuarantineCondition.'@odata.type')
                }
                if ($myQuarantineCondition.values.Where({ $null -ne $_ }).Count -gt 0)
                {
                    $complexQuarantineConditions += $myQuarantineCondition
                }
            }

            $complexQuarantineConfiguration = [ordered]@{}
            if ($complexQuarantineConditions.Count -gt 0)
            {
                $complexQuarantineConfiguration.Add('Conditions', [Array]$complexQuarantineConditions)
            }
            $complexQuarantineConfiguration.Add('MatchMode', $instance.QuarantineConfiguration.MatchMode)
            if ($complexQuarantineConfiguration.values.Where({ $null -ne $_ }).Count -eq 0)
            {
                $complexQuarantineConfiguration = $null
            }

            $results = @{
                IsSingleInstance                = 'Yes'
                WorkflowScheduleIntervalInHours = $instance.WorkflowScheduleIntervalInHours
                SenderDomain                    = $instance.EmailSettings.SenderDomain
                UseCompanyBranding              = $instance.EmailSettings.UseCompanyBranding
                QuarantineConfiguration         = $complexQuarantineConfiguration
                Credential                      = $this.Credential
                ApplicationId                   = $this.ApplicationId
                TenantId                        = $this.TenantId
                ApplicationSecret               = $this.ApplicationSecret
                CertificateThumbprint           = $this.CertificateThumbprint
                CertificatePath                 = $this.CertificatePath
                CertificatePassword             = $this.CertificatePassword
                ManagedIdentity                 = $this.ManagedIdentity
                AccessTokens                    = $this.AccessTokens
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

        Write-Verbose -Message 'Setting the AAD Lifecycle Workflow Settings'

        $null = $this.Connect('MicrosoftGraph')

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $updateSettings = @{
            workflowScheduleIntervalInHours = $this.WorkflowScheduleIntervalInHours
            emailSettings                   = @{
                senderDomain       = $this.SenderDomain
                useCompanyBranding = $this.UseCompanyBranding
            }
        }

        if ($null -ne $this.QuarantineConfiguration)
        {
            [Array]$quarantineConditionsValue = @()
            foreach ($quarantineCondition in $this.QuarantineConfiguration.Conditions)
            {
                $quarantineConditionValue = @{}
                if (-not [System.String]::IsNullOrEmpty($quarantineCondition.odataType))
                {
                    $quarantineConditionValue.Add('@odata.type', $quarantineCondition.odataType)
                }
                if ($null -ne $quarantineCondition.Threshold)
                {
                    $quarantineConditionValue.Add('threshold', $quarantineCondition.Threshold)
                }
                if ($null -ne $quarantineCondition.Percentage)
                {
                    $quarantineConditionValue.Add('percentage', $quarantineCondition.Percentage)
                }
                $quarantineConditionsValue += $quarantineConditionValue
            }

            $quarantineConfigurationValue = @{}
            if ($quarantineConditionsValue.Count -gt 0)
            {
                $quarantineConfigurationValue.Add('conditions', $quarantineConditionsValue)
            }
            if (-not [System.String]::IsNullOrEmpty($this.QuarantineConfiguration.MatchMode))
            {
                $quarantineConfigurationValue.Add('matchMode', $this.QuarantineConfiguration.MatchMode)
            }
            if ($quarantineConfigurationValue.Count -gt 0)
            {
                $updateSettings.Add('quarantineConfiguration', $quarantineConfigurationValue)
            }
        }

        Write-Verbose -Message "Updating the lifecycle workflow settings with payload: $($updateSettings | ConvertTo-Json -Depth 10)"
        Update-MgBetaIdentityGovernanceLifecycleWorkflowSetting -BodyParameter $updateSettings
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

        $ConnectionMode = $this.Connect('MicrosoftGraph')

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Export')

        try
        {
            [array] $exportedInstances = Get-MgBetaIdentityGovernanceLifecycleWorkflowSetting -ErrorAction Stop

            $i = 1
            $dscContent = [System.Text.StringBuilder]::new()
            if ($exportedInstances.Length -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }
            foreach ($config in $exportedInstances)
            {
                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }

                $displayedKey = $config.Id
                Write-M365DSCHost -Message "    |---[$i/$($exportedInstances.Count)] $displayedKey" -DeferWrite
                $params = @{
                    IsSingleInstance      = 'Yes'
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

                if ($null -ne $Results.QuarantineConfiguration)
                {
                    $complexMapping = @(
                        @{
                            Name            = 'Conditions'
                            CimInstanceName = 'MicrosoftGraphquarantineCondition'
                            IsRequired      = $false
                        }
                    )
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.QuarantineConfiguration `
                        -CIMInstanceName MicrosoftGraphquarantineConfiguration `
                        -ComplexTypeMapping $complexMapping

                    if ($complexTypeStringResult)
                    {
                        $Results.QuarantineConfiguration = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('QuarantineConfiguration') | Out-Null
                    }
                }

                $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                    -ConnectionMode $ConnectionMode `
                    -ModulePath $this.GetModulePath() `
                    -Results $Results `
                    -Credential $this.Credential `
                    -NoEscape @('QuarantineConfiguration')
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
            if ($_.ErrorDetails.Message -like 'Insufficient license *')
            {
                Write-M365DSCHost -Message "`r`n    " -DeferWrite
                Write-M365DSCHost -Message $Global:M365DSCEmojiYellowCircle -DeferWrite
                Write-M365DSCHost -Message ' Insufficient license. You need the Entra ID Governance license.' -CommitWrite
            }
            else
            {
                $this.LogError($_, 'Error during Export:')

                throw
            }
        }

        # Every code path must return in a method with a declared return type.
        return ''
    }

    hidden [AADLifecycleWorkflowSettings] AsResult([System.Object] $Values)
    {
        if ($Values -is [AADLifecycleWorkflowSettings])
        {
            return $Values
        }

        $result = [AADLifecycleWorkflowSettings]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}

class MSFT_MicrosoftGraphquarantineConfiguration
{
    [DscProperty()]
    [System.ComponentModel.Description('The set of threshold conditions evaluated for the workflow.')]
    [MSFT_MicrosoftGraphquarantineCondition[]] $Conditions

    [DscProperty()]
    [System.ComponentModel.Description('Determines whether any or all of the conditions must be met for the workflow to be quarantined.')]
    [ValidateSet('any', 'all')]
    [System.String] $MatchMode
}

class MSFT_MicrosoftGraphquarantineCondition
{
    [DscProperty()]
    [System.ComponentModel.Description('The maximum number of users a workflow run can process before the workflow is quarantined.')]
    [System.Nullable[System.Int64]] $Threshold

    [DscProperty()]
    [System.ComponentModel.Description('The maximum percentage of in-scope users a workflow run can process before the workflow is quarantined.')]
    [System.Nullable[System.Int32]] $Percentage

    [DscProperty()]
    [System.ComponentModel.Description('The type of the entity.')]
    [ValidateSet('#microsoft.graph.identityGovernance.countBasedQuarantineCondition', '#microsoft.graph.identityGovernance.percentageBasedQuarantineCondition')]
    [System.String] $odataType
}
