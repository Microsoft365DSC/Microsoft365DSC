using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class IntuneAlertRuleWindows365 : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The rule template of the alert event. The possible values are: cloudPcProvisionScenario, cloudPcImageUploadScenario, cloudPcOnPremiseNetworkConnectionCheckScenario, cloudPcInGracePeriodScenario, cloudPcFrontlineInsufficientLicensesScenario, cloudPcInaccessibleScenario, cloudPcFrontlineConcurrencyScenario, cloudPcUserSettingsPersistenceScenario, cloudPcDeprovisionFailedScenario.')]
    [ValidateSet('cloudPcProvisionScenario', 'cloudPcImageUploadScenario', 'cloudPcOnPremiseNetworkConnectionCheckScenario', 'cloudPcInGracePeriodScenario', 'cloudPcFrontlineInsufficientLicensesScenario', 'cloudPcInaccessibleScenario', 'cloudPcFrontlineConcurrencyScenario', 'cloudPcUserSettingsPersistenceScenario', 'cloudPcDeprovisionFailedScenario')]
    [System.String] $AlertRuleTemplate

    [DscProperty()]
    [System.ComponentModel.Description('The conditions that determine when to send alerts. For example, you can configure a condition to send an alert when provisioning fails for six or more Cloud PCs.')]
    [MSFT_IntuneAlertRuleCondition[]] $Conditions

    [DscProperty()]
    [System.ComponentModel.Description('The status of the rule that indicates whether the rule is enabled or disabled. If true, the rule is enabled otherwise, the rule is disabled.')]
    [System.Nullable[System.Boolean]] $Enabled

    [DscProperty()]
    [System.ComponentModel.Description('The notification channels of the rule selected by the user.')]
    [MSFT_IntuneAlertRuleNotificationChannel[]] $NotificationChannels

    [DscProperty()]
    [System.ComponentModel.Description('The severity of the rule. The possible values are: informational, warning, critical.')]
    [ValidateSet('Critical', 'Warning', 'Informational', 'unknown')]
    [System.String] $Severity

    [DscProperty()]
    [System.ComponentModel.Description('Present ensures the rule exists. Alert rules for Windows365 cannot be removed.')]
    [ValidateSet('Present', 'Absent')]
    [System.String] $Ensure

    [DscProperty()]
    [System.ComponentModel.Description('Credentials of the Admin')]
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

    # Export-only. Not part of the resource schema.
    [System.String] $Filter

    [IntuneAlertRuleWindows365] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [IntuneAlertRuleWindows365]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration for the Intune Alert Rule for Windows365 with AlertRuleTemplate {$($this.AlertRuleTemplate)}"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.AlertRuleTemplate -ne $this.AlertRuleTemplate)
            {
                $null = $this.Connect('MicrosoftGraph')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullResult = $this.GetBoundParameters()
                $nullResult.Ensure = 'Absent'

                #region resource generator code
                $getValue = Get-MgBetaDeviceManagementMonitoringAlertRule `
                    -Filter "alertRuleTemplate eq '$($this.AlertRuleTemplate -replace "'", "''")'" `
                    -All `
                    -ErrorAction SilentlyContinue | Where-Object {
                        $_.AlertRuleTemplate -eq $this.AlertRuleTemplate
                    }
                $this.ResourceCache['currentAlertRule'] = $getValue
                #endregion
                if ($null -eq $getValue)
                {
                    Write-Verbose -Message "Could not find an Intune Alert Rule for Windows365 with AlertRuleTemplate {$($this.AlertRuleTemplate)}."
                    return $this.AsResult($nullResult)
                }
            }
            else
            {
                $getValue = $this.ExportedInstance
            }

            Write-Verbose -Message "An Intune Alert Rule for Windows365 with AlertRuleTemplate {$($this.AlertRuleTemplate)} was found."

            $complexConditions = @()
            foreach ($condition in $getValue.Conditions)
            {
                $complexConditions += [ordered]@{
                    Aggregation       = $condition.aggregation
                    ConditionCategory = $condition.conditionCategory
                    Operator          = $condition.operator
                    RelationshipType  = $condition.relationshipType
                    ThresholdValue    = $condition.thresholdValue
                }
            }

            $complexNotificationChannels = @()
            foreach ($channel in $getValue.NotificationChannels)
            {
                $complexNotificationChannels += [ordered]@{
                    NotificationChannelType = $channel.notificationChannelType
                    NotificationReceivers   = @($channel.notificationReceivers | ForEach-Object {
                        [ordered]@{
                            ContactInformation = $_.ContactInformation
                            Locale             = $_.locale
                        }
                    })
                }
            }

            $results = @{
                #region resource generator code
                AlertRuleTemplate     = $getValue.AlertRuleTemplate
                Conditions            = $complexConditions
                Enabled               = $getValue.Enabled
                NotificationChannels  = $complexNotificationChannels
                Severity              = $getValue.Severity
                Ensure                = 'Present'
                Credential            = $this.Credential
                ApplicationId         = $this.ApplicationId
                TenantId              = $this.TenantId
                ApplicationSecret     = $this.ApplicationSecret
                CertificateThumbprint = $this.CertificateThumbprint
                CertificatePath       = $this.CertificatePath
                CertificatePassword   = $this.CertificatePassword
                ManagedIdentity       = $this.ManagedIdentity
                #endregion
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
        $aggregation = $null
        if ($this.RequiresPowerShellCore())
        {
            $null = $this.InvokeInPowerShellCore('Set')
            return
        }

        Write-Verbose -Message "Setting configuration of the Intune Alert Rule for Windows365 with AlertRuleTemplate {$($this.AlertRuleTemplate)}"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $currentInstance = $this.Get().ToHashtable()
        $boundParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()
        $boundParameters.Add('isSystemRule', $true)
        $boundParameters.Add('id', $this.ResourceCache['currentAlertRule'].Id)
        $boundParameters.Add('description', $this.ResourceCache['currentAlertRule'].Description)
        $boundParameters.Add('displayName', $this.ResourceCache['currentAlertRule'].DisplayName)

        $requiresThreshold = $false
        if ($this.AlertRuleTemplate -in @('cloudPcImageUploadScenario', 'cloudPcOnPremiseNetworkConnectionCheckScenario'))
        {
            $requiresThreshold = $true
            $aggregation = 'count'
        }
        elseif ($this.AlertRuleTemplate -eq 'cloudPcFrontlineInsufficientLicensesScenario')
        {
            $requiresThreshold = $true
            $aggregation = 'percentage'
        }

        if ($requiresThreshold)
        {
            $boundParameters.Add('threshold', @{
                aggregation = $aggregation
                operator    = 'greaterOrEqual'
                target      = 1
            })
        }

        $updateParameters = Rename-M365DSCCimInstanceParameter -Properties $boundParameters

        #region resource generator code
        if ($this.ResourceCache['currentAlertRule'].Id -eq '00000000-0000-0000-0000-000000000000')
        {
            Write-Verbose -Message "Updating the Intune Alert Rule for Windows365 with AlertRuleTemplate {$($currentInstance.AlertRuleTemplate)} from default instance."
            $null = New-MgBetaDeviceManagementMonitoringAlertRule -BodyParameter $updateParameters
        }
        else
        {
            Write-Verbose -Message "Updating the Intune Alert Rule for Windows365 with AlertRuleTemplate {$($currentInstance.AlertRuleTemplate)} and Id {$($this.ResourceCache['currentAlertRule'].Id)}."
            Update-MgBetaDeviceManagementMonitoringAlertRule `
                -AlertRuleId $this.ResourceCache['currentAlertRule'].Id `
                -BodyParameter $updateParameters
        }
        #endregion
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
            #region resource generator code
            [array]$getValue = Get-MgBetaDeviceManagementMonitoringAlertRule `
                -Filter $this.Filter `
                -All `
                -ErrorAction Stop
            #endregion

            $i = 1
            $dscContent = [System.Text.StringBuilder]::new()
            if ($getValue.Length -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }
            foreach ($config in $getValue)
            {
                $displayedKey = $config.alertRuleTemplate
                Write-M365DSCHost -Message "    |---[$i/$($getValue.Count)] $displayedKey" -DeferWrite
                $params = @{
                    AlertRuleTemplate     = $config.alertRuleTemplate
                    Ensure                = 'Present'
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

                if ($Results.Conditions)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.Conditions `
                        -CIMInstanceName 'IntuneAlertRuleCondition'
                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.Conditions = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('Conditions') | Out-Null
                    }
                }
                if ($Results.NotificationChannels)
                {
                    $complexMapping = @(
                        @{
                            Name            = 'NotificationChannels'
                            CimInstanceName = 'IntuneAlertRuleNotificationChannel'
                            IsRequired      = $False
                        }
                        @{
                            Name            = 'NotificationReceivers'
                            CimInstanceName = 'IntuneAlertRuleNotificationChannelReceiver'
                            IsRequired      = $false
                        }
                    )
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.NotificationChannels `
                        -CIMInstanceName 'IntuneAlertRuleNotificationChannel' `
                        -ComplexTypeMapping $complexMapping

                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.NotificationChannels = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('NotificationChannels') | Out-Null
                    }
                }

                $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                    -ConnectionMode $ConnectionMode `
                    -ModulePath $this.GetModulePath() `
                    -Results $Results `
                    -Credential $this.Credential `
                    -NoEscape @('Conditions', 'NotificationChannels')

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
            $this.LogError($_, 'Error during Export:')

            throw
        }
    }

    hidden [IntuneAlertRuleWindows365] AsResult([System.Object] $Values)
    {
        if ($Values -is [IntuneAlertRuleWindows365])
        {
            return $Values
        }

        $result = [IntuneAlertRuleWindows365]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}

class MSFT_IntuneAlertRuleCondition
{
    [DscProperty()]
    [System.ComponentModel.Description('The built-in aggregation method for the rule condition. The possible values are: count, percentage, affectedCloudPcCount, affectedCloudPcPercentage, durationInMinutes.')]
    [ValidateSet('count', 'percentage', 'affectedCloudPcCount', 'affectedCloudPcPercentage', 'durationInMinutes')]
    [System.String] $Aggregation

    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('The property that the rule condition monitors. Possible values are: provisionFailures, imageUploadFailures, azureNetworkConnectionCheckFailures, cloudPcInGracePeriod, frontlineInsufficientLicenses, cloudPcConnectionErrors, cloudPcHostHealthCheckFailures, cloudPcZoneOutage, unknownFutureValue, frontlineBufferUsageDuration, frontlineBufferUsageThreshold, cloudPcUserSettingsPersistenceUsageThreshold, cloudPcDeprovisionedThreshold, cloudPcReserveDeprovisionFailedThreshold.')]
    [ValidateSet('provisionFailures', 'imageUploadFailures', 'azureNetworkConnectionCheckFailures', 'cloudPcInGracePeriod', 'frontlineInsufficientLicenses', 'cloudPcConnectionErrors', 'cloudPcHostHealthCheckFailures', 'cloudPcZoneOutage', 'unknownFutureValue', 'frontlineBufferUsageDuration', 'frontlineBufferUsageThreshold', 'cloudPcUserSettingsPersistenceUsageThreshold', 'cloudPcDeprovisionedThreshold', 'cloudPcReserveDeprovisionFailedThreshold')]
    [System.String] $ConditionCategory

    [DscProperty()]
    [System.ComponentModel.Description('The built-in operator for the rule condition. The possible values are: greaterOrEqual, equal, greater, less, lessOrEqual, notEqual.')]
    [ValidateSet('greaterOrEqual', 'greater', 'equal', 'less', 'lessOrEqual')]
    [System.String] $Operator

    [DscProperty()]
    [System.ComponentModel.Description('The relationship type. Possible values are: and, or.')]
    [ValidateSet('and', 'or')]
    [System.String] $RelationshipType

    [DscProperty()]
    [System.ComponentModel.Description('The threshold value of the alert condition. The threshold value can be a number in string form or string like ''WestUS''.')]
    [System.String] $ThresholdValue
}

class MSFT_IntuneAlertRuleNotificationChannel
{
    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('The notification channel type.')]
    [ValidateSet('portal', 'email')]
    [System.String] $NotificationChannelType

    [DscProperty()]
    [System.ComponentModel.Description('The receivers of the notification. Only applicable if the NotificationChannelType is ''email''.')]
    [MSFT_IntuneAlertRuleNotificationChannelReceiver[]] $NotificationReceivers
}

class MSFT_IntuneAlertRuleNotificationChannelReceiver
{
    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('The email address of the receiver.')]
    [System.String] $ContactInformation

    [DscProperty()]
    [System.ComponentModel.Description('The locale of the email.')]
    [ValidateSet('en-us', 'cs-cz', 'de-de', 'es-es', 'fr-fr', 'hu-hu', 'it-it', 'ja-jp', 'ko-kr', 'nl-nl', 'pl-pl', 'pt-br', 'pt-pt', 'ru-ru', 'sv-se', 'tr-tr', 'zh-cn', 'zh-tw')]
    [System.String] $Locale
}
