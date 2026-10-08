using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class AzureBillingAccountScheduledAction : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('Display name of the scheduled action.')]
    [System.String] $DisplayName

    [DscProperty()]
    [System.ComponentModel.Description('Associated billing account id.')]
    [System.String] $BillingAccount

    [DscProperty()]
    [System.ComponentModel.Description('Status of the scheduled action.')]
    [System.String] $Status

    [DscProperty()]
    [System.ComponentModel.Description('Associated view id.')]
    [System.String] $View

    [DscProperty()]
    [System.ComponentModel.Description('Notification properties based on scheduled action kind.')]
    [MSFT_AzureBillingAccountScheduledActionNotification] $Notification

    [DscProperty()]
    [System.ComponentModel.Description('Email address of the point of contact that should get the unsubscribe requests and notification emails.')]
    [System.String] $NotificationEmail

    [DscProperty()]
    [System.ComponentModel.Description('Schedule of the scheduled action.')]
    [MSFT_AzureBillingAccountScheduledActionSchedule] $Schedule

    [DscProperty()]
    [System.ComponentModel.Description('Present ensures the instance exists, absent ensures it is removed.')]
    [ValidateSet('Absent', 'Present')]
    [System.String] $Ensure

    [DscProperty()]
    [System.ComponentModel.Description('The Azure subscription to connect to if the access is restricted on subscription level.')]
    [System.String] $SubscriptionId

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
    [System.Management.Automation.PSCredential] $ApplicationSecret

    [AzureBillingAccountScheduledAction] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [AzureBillingAccountScheduledAction]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of Azure Billing Account Scheduled Action for Billing Account $($this.BillingAccount) with Display Name $($this.DisplayName)"

        try
        {
            $null = $this.Connect('Azure')

            #Ensure the proper dependencies are installed in the current environment.
            Confirm-M365DSCDependencies

            #region Telemetry
            $this.AddTelemetry('Get')
            #endregion

            $nullResult = $this.GetBoundParameters()
            $nullResult.Ensure = 'Absent'

            $uri = "$((Get-MSCloudLoginConnectionProfile -Workload Azure).ManagementUrl)providers/Microsoft.Billing/billingAccounts/$($this.BillingAccount)/providers/Microsoft.CostManagement/scheduledActions?api-version=2023-11-01"
            $response = Invoke-AzRestMethod -Uri $uri -Method GET
            $actions = (ConvertFrom-Json ($response.Content)).value

            $instance = $actions | Where-Object -FilterScript { $_.properties.displayName -eq $this.DisplayName }

            if ($null -eq $instance)
            {
                return $this.AsResult($nullResult)
            }

            $NotificationValue = $null
            if ($null -ne $instance.properties.notification)
            {
                $NotificationValue = @{
                    subject = $instance.properties.notification.subject
                    message = $instance.properties.notification.message
                    to      = $instance.properties.notification.to
                }
            }

            $ScheduleValue = $null
            if ($null -ne $instance.properties.schedule)
            {
                $startDateVal = $instance.properties.schedule.startDate
                if ($null -ne $startDateVal -and $startDateVal -isnot [DateTime])
                {
                    try
                    {
                        $startDateVal = [DateTime]::Parse($startDateVal).ToUniversalTime()
                    }
                    catch { }
                }
                $endDateVal = $instance.properties.schedule.endDate
                if ($null -ne $endDateVal -and $endDateVal -isnot [DateTime])
                {
                    try
                    {
                        $endDateVal = [DateTime]::Parse($endDateVal).ToUniversalTime()
                    }
                    catch { }
                }

                $ScheduleValue = @{
                    frequency    = $instance.properties.schedule.frequency
                    hourOfDay    = $instance.properties.schedule.hourOfDay
                    daysOfWeek   = [Array]($instance.properties.schedule.daysOfWeek)
                    weeksofMonth = [Array]($instance.properties.schedule.weeksofMonth)
                    dayOfMonth   = $instance.properties.schedule.dayOfMonth
                    startDate    = if ($startDateVal -is [DateTime]) { $startDateVal.ToString('yyyy-MM-ddTHH:mm:ssZ') } else { $startDateVal }
                    endDate      = if ($endDateVal -is [DateTime]) { $endDateVal.ToString('yyyy-MM-ddTHH:mm:ssZ') } else { $endDateVal }
                }
            }

            $results = @{
                DisplayName           = $this.DisplayName
                BillingAccount        = $this.BillingAccount
                Status                = $instance.properties.Status
                View                  = $instance.properties.viewId
                Notification          = $NotificationValue
                NotificationEmail     = $instance.properties.notificationEmail
                Schedule              = $ScheduleValue
                Ensure                = 'Present'
                SubscriptionId        = $this.SubscriptionId
                Credential            = $this.Credential
                ApplicationId         = $this.ApplicationId
                TenantId              = $this.TenantId
                CertificateThumbprint = $this.CertificateThumbprint
                CertificatePath       = $this.CertificatePath
                CertificatePassword   = $this.CertificatePassword
                ManagedIdentity       = $this.ManagedIdentity
                AccessTokens          = $this.AccessTokens
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

        Write-Verbose -Message "Setting configuration of Azure Billing Account Scheduled Action for Billing Account $($this.BillingAccount) with Display Name $($this.DisplayName)"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $currentInstance = $this.Get().ToHashtable()

        $instanceParams = @{
            kind       = 'Email'
            properties = @{
                displayName       = $this.DisplayName
                notificationEmail = $this.NotificationEmail
                notification      = @{
                    to      = $this.Notification.to
                    subject = $this.Notification.subject
                    message = $this.Notification.message
                }
                schedule          = @{
                    frequency    = $this.Schedule.frequency
                    weeksOfMonth = $this.Schedule.weeksOfMonth
                    daysOfWeek   = $this.Schedule.daysOfWeek
                    startDate    = $this.Schedule.startDate
                    endDate      = $this.Schedule.endDate
                    dayOfMonth   = $this.Schedule.dayOfMonth
                }
                viewId            = $this.View
                status            = $this.Status
            }
        }
        $payload = ConvertTo-Json $instanceParams -Depth 10 -Compress

        # CREATE
        if ($this.Ensure -eq 'Present')
        {
            $uri = "$((Get-MSCloudLoginConnectionProfile -Workload Azure).ManagementUrl)providers/Microsoft.Billing/billingAccounts/$($this.BillingAccount)/providers/Microsoft.CostManagement/scheduledActions/$($this.DisplayName)?api-version=2023-11-01"
            Write-Verbose -Message "Making PUT call to {$uri}"

            if ($currentInstance.Ensure -eq 'Absent')
            {
                Write-Verbose -Message "Creating new scheduled action {$($this.DisplayName)} with payload:`r`n$($payload)"
            }
            else
            {
                Write-Verbose -Message "Updating scheduled action {$($this.DisplayName)} with payload:`r`n$($payload)"
            }

            $response = Invoke-AzRestMethod -Uri $uri -Method PUT -Payload $payload
            Write-Verbose -Message "Response:`r`n$($response.Content)"
        }
        # REMOVE
        elseif ($this.Ensure -eq 'Absent' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Removing scheduled action {$($this.DisplayName)} with payload:`r`n$($payload)"
            $uri = "$((Get-MSCloudLoginConnectionProfile -Workload Azure).ManagementUrl)providers/Microsoft.Billing/billingAccounts/$($this.BillingAccount)/providers/Microsoft.CostManagement/scheduledActions/$($this.DisplayName)?api-version=2023-11-01"
            $response = Invoke-AzRestMethod -Uri $uri -Method DELETE
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

        $ConnectionMode = $this.Connect('Azure')

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Export')

        try
        {
            #Get all billing account
            $accounts = Get-M365DSCAzureBillingAccount

            $i = 1
            $dscContent = [System.Text.StringBuilder]::new()
            if ($accounts.Length -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }
            foreach ($account in $accounts.value)
            {
                $displayedKey = $account.properties.displayName
                Write-M365DSCHost -Message "    |---[$i/$($accounts.value.Length)] $displayedKey" -DeferWrite

                $uri = "$((Get-MSCloudLoginConnectionProfile -Workload Azure).ManagementUrl)providers/Microsoft.Billing/billingAccounts/$($account.name)/providers/Microsoft.CostManagement/scheduledActions?api-version=2023-11-01"
                $response = Invoke-AzRestMethod -Uri $uri -Method GET
                $actions = (ConvertFrom-Json ($response.Content)).value
                $j = 1
                if ($actions.Length -eq 0)
                {
                    Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
                }
                else
                {
                    Write-M365DSCHost -Message "`r`n" -DeferWrite
                }
                foreach ($config in $actions)
                {
                    if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                    {
                        $Global:M365DSCExportResourceInstancesCount++
                    }

                    $displayedKey = $config.properties.displayName
                    Write-M365DSCHost -Message "        |---[$j/$($actions.Count)] $displayedKey" -DeferWrite
                    $params = @{
                        DisplayName           = $config.properties.displayName
                        BillingAccount        = $account.name
                        SubscriptionId        = $this.SubscriptionId
                        Credential            = $this.Credential
                        ApplicationId         = $this.ApplicationId
                        TenantId              = $this.TenantId
                        CertificateThumbprint = $this.CertificateThumbprint
                        ManagedIdentity       = $this.ManagedIdentity
                        AccessTokens          = $this.AccessTokens
                    }

                    $Results = $this.GetForExport($Params)

                    if ($Results.Notification)
                    {
                        $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString -ComplexObject $Results.Notification -CIMInstanceName AzureBillingAccountScheduledActionNotification
                        if ($complexTypeStringResult)
                        {
                            $Results.Notification = $complexTypeStringResult
                        }
                        else
                        {
                            $Results.Remove('Notification') | Out-Null
                        }
                    }
                    if ($Results.Schedule)
                    {
                        $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString -ComplexObject $Results.Schedule -CIMInstanceName AzureBillingAccountScheduledActionSchedule
                        if ($complexTypeStringResult)
                        {
                            $Results.Schedule = $complexTypeStringResult
                        }
                        else
                        {
                            $Results.Remove('Schedule') | Out-Null
                        }
                    }
                    $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                        -ConnectionMode $ConnectionMode `
                        -ModulePath $this.GetModulePath() `
                        -Results $Results `
                        -Credential $this.Credential `
                        -NoEscape @('Notification', 'Schedule')
                    [void]$dscContent.Append($currentDSCBlock)
                    Save-M365DSCPartialExport -Content $currentDSCBlock `
                        -FileName $Global:PartialExportFileName
                    $i++
                    Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
                }
            }
            return $dscContent.ToString()
        }
        catch
        {
            $this.LogError($_, 'Error during Export:')

            throw
        }
    }

    [System.Collections.Hashtable] GetCompareParameters()
    {
        return @{
            ExcludedProperties = @('SubscriptionId')
        }
    }

    hidden [AzureBillingAccountScheduledAction] AsResult([System.Object] $Values)
    {
        if ($Values -is [AzureBillingAccountScheduledAction])
        {
            return $Values
        }

        $result = [AzureBillingAccountScheduledAction]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}

class MSFT_AzureBillingAccountScheduledActionNotification
{
    [DscProperty()]
    [System.ComponentModel.Description('Subject of the email. Length is limited to 70 characters.')]
    [System.String] $subject

    [DscProperty()]
    [System.ComponentModel.Description('Optional message to be added in the email. Length is limited to 250 characters.')]
    [System.String] $message

    [DscProperty()]
    [System.ComponentModel.Description('Array of email addresses.')]
    [System.String[]] $to
}

class MSFT_AzureBillingAccountScheduledActionSchedule
{
    [DscProperty()]
    [System.ComponentModel.Description('UTC day on which cost analysis data will be emailed. Must be between 1 and 31. This property is applicable when frequency is Monthly and overrides weeksOfMonth or daysOfWeek.')]
    [System.Nullable[System.UInt32]] $dayOfMonth

    [DscProperty()]
    [System.ComponentModel.Description('Day names in english on which cost analysis data will be emailed. This property is applicable when frequency is Weekly or Monthly.')]
    [System.String[]] $daysOfWeek

    [DscProperty()]
    [System.ComponentModel.Description('The start date and time of the scheduled action (UTC).')]
    [System.String] $startDate

    [DscProperty()]
    [System.ComponentModel.Description('The end date and time of the scheduled action (UTC).')]
    [System.String] $endDate

    [DscProperty()]
    [System.ComponentModel.Description('Weeks in which cost analysis data will be emailed. This property is applicable when frequency is Monthly and used in combination with daysOfWeek.')]
    [System.String[]] $weeksOfMonth

    [DscProperty()]
    [System.ComponentModel.Description('Frequency of the schedule.')]
    [System.String] $frequency

    [DscProperty()]
    [System.ComponentModel.Description('UTC time at which cost analysis data will be emailed.')]
    [System.Nullable[System.UInt32]] $hourOfDay
}
