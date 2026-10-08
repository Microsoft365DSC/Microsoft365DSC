using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class EXOCalendarProcessing : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The Identity parameter specifies the resource mailbox that you want to view. You can use any value that uniquely identifies the mailbox.')]
    [System.String] $Identity

    [DscProperty()]
    [System.ComponentModel.Description('The AddAdditionalResponse parameter specifies whether additional information (the value of the AdditionalResponse parameter) is added to meeting request responses')]
    [System.Nullable[System.Boolean]] $AddAdditionalResponse

    [DscProperty()]
    [System.ComponentModel.Description('The AdditionalResponse parameter specifies the additional information to be included in responses to meeting requests when the value of the AddAdditionalResponse parameter is $true. If the value contains spaces, enclose the value in quotation marks.')]
    [System.String] $AdditionalResponse

    [DscProperty()]
    [System.ComponentModel.Description('The AddNewRequestsTentatively parameter specifies whether new meeting requests are added to the calendar as tentative')]
    [System.Nullable[System.Boolean]] $AddNewRequestsTentatively

    [DscProperty()]
    [System.ComponentModel.Description('The AddOrganizerToSubject parameter specifies whether the meeting organizer''s name is used as the subject of the meeting request.')]
    [System.Nullable[System.Boolean]] $AddOrganizerToSubject

    [DscProperty()]
    [System.ComponentModel.Description('The AllBookInPolicy parameter specifies whether to automatically approve in-policy requests from all users to the resource mailbox.')]
    [System.Nullable[System.Boolean]] $AllBookInPolicy

    [DscProperty()]
    [System.ComponentModel.Description('The AllowConflicts parameter specifies whether to allow conflicting meeting requests.')]
    [System.Nullable[System.Boolean]] $AllowConflicts

    [DscProperty()]
    [System.ComponentModel.Description('The AllowRecurringMeetings parameter specifies whether to allow recurring meetings in meeting requests.')]
    [System.Nullable[System.Boolean]] $AllowRecurringMeetings

    [DscProperty()]
    [System.ComponentModel.Description('The AllRequestInPolicy parameter specifies whether to allow all users to submit in-policy requests to the resource mailbox.')]
    [System.Nullable[System.Boolean]] $AllRequestInPolicy

    [DscProperty()]
    [System.ComponentModel.Description('The AllRequestOutOfPolicy parameter specifies whether to allow all users to submit out-of-policy requests to the resource mailbox.')]
    [System.Nullable[System.Boolean]] $AllRequestOutOfPolicy

    [DscProperty()]
    [System.ComponentModel.Description('The AutomateProcessing parameter enables or disables calendar processing on the mailbox.')]
    [ValidateSet('None', 'AutoUpdate', 'AutoAccept')]
    [System.String] $AutomateProcessing

    [DscProperty()]
    [System.ComponentModel.Description('The BookingType parameter specifies how reservations work on the resource mailbox.')]
    [ValidateSet('Standard', 'Reserved')]
    [System.String] $BookingType

    [DscProperty()]
    [System.ComponentModel.Description('The BookingWindowInDays parameter specifies the maximum number of days in advance that the resource can be reserved. A valid value is an integer from 0 through 1080. The default value is 180 days. The value 0 means today.')]
    [ValidateRange(0, 1080)]
    [System.Nullable[System.UInt32]] $BookingWindowInDays

    [DscProperty()]
    [System.ComponentModel.Description('The BookInPolicy parameter specifies users or groups who are allowed to submit in-policy meeting requests to the resource mailbox that are automatically approved. You can use any value that uniquely identifies the user or group.')]
    [System.String[]] $BookInPolicy

    [DscProperty()]
    [System.ComponentModel.Description('The ConflictPercentageAllowed parameter specifies the maximum percentage of meeting conflicts for new recurring meeting requests. A valid value is an integer from 0 through 100. The default value is 0.')]
    [System.Nullable[System.UInt32]] $ConflictPercentageAllowed

    [DscProperty()]
    [System.ComponentModel.Description('The DeleteAttachments parameter specifies whether to remove attachments from all incoming messages.')]
    [System.Nullable[System.Boolean]] $DeleteAttachments

    [DscProperty()]
    [System.ComponentModel.Description('The DeleteComments parameter specifies whether to remove or keep any text in the message body of incoming meeting requests.')]
    [System.Nullable[System.Boolean]] $DeleteComments

    [DscProperty()]
    [System.ComponentModel.Description('The DeleteNonCalendarItems parameter specifies whether to remove or keep all non-calendar-related messages that are received by the resource mailbox.')]
    [System.Nullable[System.Boolean]] $DeleteNonCalendarItems

    [DscProperty()]
    [System.ComponentModel.Description('The DeleteSubject parameter specifies whether to remove or keep the subject of incoming meeting requests. ')]
    [System.Nullable[System.Boolean]] $DeleteSubject

    [DscProperty()]
    [System.ComponentModel.Description('N/A')]
    [System.Nullable[System.Boolean]] $EnableAutoRelease

    [DscProperty()]
    [System.ComponentModel.Description('The EnableResponseDetails parameter specifies whether to include the reasons for accepting or declining a meeting in the response email message.')]
    [System.Nullable[System.Boolean]] $EnableResponseDetails

    [DscProperty()]
    [System.ComponentModel.Description('The EnforceCapacity parameter specifies whether to restrict the number of attendees to the capacity of the workspace. For example, if capacity is set to 10, then only 10 people can book the workspace.')]
    [System.Nullable[System.Boolean]] $EnforceCapacity

    [DscProperty()]
    [System.ComponentModel.Description('The EnforceSchedulingHorizon parameter controls the behavior of recurring meetings that extend beyond the date specified by the BookingWindowInDays parameter.')]
    [System.Nullable[System.Boolean]] $EnforceSchedulingHorizon

    [DscProperty()]
    [System.ComponentModel.Description('The ForwardRequestsToDelegates parameter specifies whether to forward incoming meeting requests to the delegates that are configured for the resource mailbox.')]
    [System.Nullable[System.Boolean]] $ForwardRequestsToDelegates

    [DscProperty()]
    [System.ComponentModel.Description('The MaximumConflictInstances parameter specifies the maximum number of conflicts for new recurring meeting requests when the AllowRecurringMeetings parameter is set to $true. A valid value is an integer from 0 through INT32 (2147483647). The default value is 0.')]
    [System.Nullable[System.UInt32]] $MaximumConflictInstances

    [DscProperty()]
    [System.ComponentModel.Description('The MaximumDurationInMinutes parameter specifies the maximum duration in minutes for meeting requests. A valid value is an integer from 0 through INT32 (2147483647). The default value is 1440 (24 hours).')]
    [System.Nullable[System.UInt32]] $MaximumDurationInMinutes

    [DscProperty()]
    [System.ComponentModel.Description('The MinimumDurationInMinutes parameter specifies the minimum duration in minutes for meeting requests in workspace mailboxes. A valid value is an integer from 0 through INT32 (2147483647). The default value is 0, which means there is no minimum duration.')]
    [System.Nullable[System.UInt32]] $MinimumDurationInMinutes

    [DscProperty()]
    [System.ComponentModel.Description('The OrganizerInfo parameter specifies whether the resource mailbox sends organizer information when a meeting request is declined because of conflicts.')]
    [System.Nullable[System.Boolean]] $OrganizerInfo

    [DscProperty()]
    [System.ComponentModel.Description('N/A')]
    [System.Nullable[System.UInt32]] $PostReservationMaxClaimTimeInMinutes

    [DscProperty()]
    [System.ComponentModel.Description('The ProcessExternalMeetingMessages parameter specifies whether to process meeting requests that originate outside the Exchange organization.')]
    [System.Nullable[System.Boolean]] $ProcessExternalMeetingMessages

    [DscProperty()]
    [System.ComponentModel.Description('The RemoveCanceledMeetings parameter specifies whether to automatically delete meetings that were cancelled by the organizer from the resource mailbox''s calendar. ')]
    [System.Nullable[System.Boolean]] $RemoveCanceledMeetings

    [DscProperty()]
    [System.ComponentModel.Description('The RemoveForwardedMeetingNotifications parameter specifies whether forwarded meeting notifications are moved to the Deleted Items folder after they''re processed by the Calendar Attendant. ')]
    [System.Nullable[System.Boolean]] $RemoveForwardedMeetingNotifications

    [DscProperty()]
    [System.ComponentModel.Description('The RemoveOldMeetingMessages parameter specifies whether the Calendar Attendant removes old and redundant updates and responses.')]
    [System.Nullable[System.Boolean]] $RemoveOldMeetingMessages

    [DscProperty()]
    [System.ComponentModel.Description('The RemovePrivateProperty parameter specifies whether to clear the private flag for incoming meetings that were sent by the organizer in the original requests. ')]
    [System.Nullable[System.Boolean]] $RemovePrivateProperty

    [DscProperty()]
    [System.ComponentModel.Description('The RemovePrivateProperty parameter specifies whether to clear the private flag for incoming meetings that were sent by the organizer in the original requests. ')]
    [System.String[]] $RequestInPolicy

    [DscProperty()]
    [System.ComponentModel.Description('The RequestOutOfPolicy parameter specifies users who are allowed to submit out-of-policy requests that require approval by a resource mailbox delegate. You can use any value that uniquely identifies the user. ')]
    [System.String[]] $RequestOutOfPolicy

    [DscProperty()]
    [System.ComponentModel.Description('The ResourceDelegates parameter specifies users can approve or reject requests that are sent to the resource mailbox. You can use any value that uniquely identifies the user. ')]
    [System.String[]] $ResourceDelegates

    [DscProperty()]
    [System.ComponentModel.Description('The ScheduleOnlyDuringWorkHours parameter specifies whether to allow meetings to be scheduled outside of the working hours that are defined for the resource mailbox.')]
    [System.Nullable[System.Boolean]] $ScheduleOnlyDuringWorkHours

    [DscProperty()]
    [System.ComponentModel.Description('The TentativePendingApproval parameter specifies whether to mark pending requests as tentative on the calendar.')]
    [System.Nullable[System.Boolean]] $TentativePendingApproval

    [DscProperty()]
    [System.ComponentModel.Description('Credentials of the Exchange Global Admin')]
    [System.Management.Automation.PSCredential] $Credential

    [DscProperty()]
    [System.ComponentModel.Description('Determines whether or not the instance exist. This resource cannot be removed and the value must be set to ''Ensure''.')]
    [ValidateSet('Present', 'Absent')]
    [System.String] $Ensure

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

    [EXOCalendarProcessing] Get()
    {
        $OrgWideAccount = $null
        if ($this.RequiresPowerShellCore())
        {
            $remote = [EXOCalendarProcessing]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of Calendar Processing settings for $($this.Identity)"

        try
        {
            $null = $this.Connect('ExchangeOnline')

            #Ensure the proper dependencies are installed in the current environment.
            Confirm-M365DSCDependencies

            #region Telemetry
            $this.AddTelemetry('Get')
            #endregion

            $nullReturn = $this.GetBoundParameters()
            $nullReturn.Ensure = 'Absent'

            $calendarProc = Get-CalendarProcessing -Identity $this.Identity -ErrorAction SilentlyContinue

            if ($null -eq $calendarProc)
            {
                Write-Verbose -Message "Calendar processing settings for $($this.Identity) does not exist."
                return $this.AsResult($nullReturn)
            }

            if ($null -eq $this.ResourceCache['UsersCache'])
            {
                $this.ResourceCache['UsersCache'] = [System.Collections.Generic.Dictionary[System.String, System.String]]::new()
            }

            $RequestInPolicyValue = @()
            if ($null -ne $calendarProc.RequestInPolicy)
            {
                foreach ($user in $calendarProc.RequestInPolicy)
                {
                    $userInfo = $null
                    if ($this.ResourceCache['UsersCache'].TryGetValue($user, [ref]$userInfo))
                    {
                        $RequestInPolicyValue += $userInfo
                    }
                    else
                    {
                        $userInfo = (Get-User -Identity $user).UserPrincipalName
                        $this.ResourceCache['UsersCache'][$user] = $userInfo
                        $RequestInPolicyValue += $userInfo
                    }
                }
            }

            $RequestOutOfPolicyValue = @()
            if ($null -ne $calendarProc.RequestOutOfPolicy)
            {
                foreach ($user in $calendarProc.RequestOutOfPolicy)
                {
                    $userInfo = $null
                    if ($this.ResourceCache['UsersCache'].TryGetValue($user, [ref]$userInfo))
                    {
                        $RequestOutOfPolicyValue += $userInfo
                    }
                    else
                    {
                        $userInfo = (Get-User -Identity $user).UserPrincipalName
                        $this.ResourceCache['UsersCache'][$user] = $userInfo
                        $RequestOutOfPolicyValue += $userInfo
                    }
                }
            }

            $ResourceDelegatesValue = @()
            if ($null -ne $calendarProc.ResourceDelegates)
            {
                foreach ($user in $calendarProc.ResourceDelegates)
                {
                    $userInfo = $null
                    if ($this.ResourceCache['UsersCache'].TryGetValue($user, [ref]$userInfo))
                    {
                        $ResourceDelegatesValue += $userInfo
                    }
                    else
                    {
                        $userInfo = (Get-Recipient -Identity $user).PrimarySmtpAddress
                        $this.ResourceCache['UsersCache'][$user] = $userInfo
                        $ResourceDelegatesValue += $userInfo
                    }
                }
            }

            $result = @{
                Identity                             = $this.Identity
                AddAdditionalResponse                = $calendarProc.AddAdditionalResponse
                AdditionalResponse                   = $calendarProc.AdditionalResponse
                AddNewRequestsTentatively            = $calendarProc.AddNewRequestsTentatively
                AddOrganizerToSubject                = $calendarProc.AddOrganizerToSubject
                AllBookInPolicy                      = $calendarProc.AllBookInPolicy
                AllowConflicts                       = $calendarProc.AllowConflicts
                AllowRecurringMeetings               = $calendarProc.AllowRecurringMeetings
                AllRequestInPolicy                   = $calendarProc.AllRequestInPolicy
                AllRequestOutOfPolicy                = $calendarProc.AllRequestOutOfPolicy
                AutomateProcessing                   = $calendarProc.AutomateProcessing
                BookingType                          = $calendarProc.BookingType
                BookingWindowInDays                  = $calendarProc.BookingWindowInDays
                BookInPolicy                         = [Array]$calendarProc.BookInPolicy
                ConflictPercentageAllowed            = $calendarProc.ConflictPercentageAllowed
                DeleteAttachments                    = $calendarProc.DeleteAttachments
                DeleteComments                       = $calendarProc.DeleteComments
                DeleteNonCalendarItems               = $calendarProc.DeleteNonCalendarItems
                DeleteSubject                        = $calendarProc.DeleteSubject
                EnableAutoRelease                    = $calendarProc.EnableAutoRelease
                EnableResponseDetails                = $calendarProc.EnableResponseDetails
                EnforceCapacity                      = $calendarProc.EnforceCapacity
                EnforceSchedulingHorizon             = $calendarProc.EnforceSchedulingHorizon
                ForwardRequestsToDelegates           = $calendarProc.ForwardRequestsToDelegates
                MaximumConflictInstances             = $calendarProc.MaximumConflictInstances
                MaximumDurationInMinutes             = $calendarProc.MaximumDurationInMinutes
                MinimumDurationInMinutes             = $calendarProc.MinimumDurationInMinutes
                OrganizerInfo                        = $calendarProc.OrganizerInfo
                PostReservationMaxClaimTimeInMinutes = $calendarProc.PostReservationMaxClaimTimeInMinutes
                ProcessExternalMeetingMessages       = $calendarProc.ProcessExternalMeetingMessages
                RemoveCanceledMeetings               = $calendarProc.RemoveCanceledMeetings
                RemoveForwardedMeetingNotifications  = $calendarProc.RemoveForwardedMeetingNotifications
                RemoveOldMeetingMessages             = $calendarProc.RemoveOldMeetingMessages
                RemovePrivateProperty                = $calendarProc.RemovePrivateProperty
                RequestInPolicy                      = $RequestInPolicyValue
                RequestOutOfPolicy                   = $RequestOutOfPolicyValue
                ResourceDelegates                    = $ResourceDelegatesValue
                ScheduleOnlyDuringWorkHours          = $calendarProc.ScheduleOnlyDuringWorkHours
                TentativePendingApproval             = $calendarProc.TentativePendingApproval
                Ensure                               = 'Present'
                Credential                           = $this.Credential
                ApplicationId                        = $this.ApplicationId
                CertificateThumbprint                = $this.CertificateThumbprint
                CertificatePath                      = $this.CertificatePath
                CertificatePassword                  = $this.CertificatePassword
                ManagedIdentity                      = $this.ManagedIdentity
                TenantId                             = $this.TenantId
                AccessTokens                         = $this.AccessTokens
            }

            Write-Verbose -Message "Found Availability Config for $($OrgWideAccount)"
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

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $currentValues = $this.Get().ToHashtable()

        if ($null -ne $currentValues)
        {
            Write-Verbose -Message "Setting configuration of Calendar Processing for $($this.Identity)"
        }
        else
        {
            return
        }

        $updateParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()

        # Some parameters can only be applied to Resource Mailboxes
        if ($updateParameters.ContainsKey('AddNewRequestsTentatively'))
        {
            $mailbox = Get-Mailbox $updateParameters.Identity
            if ($mailbox.RecipientTypeDetails -ne 'EquipmentMailbox' -and $mailbox.RecipientTypeDetails -ne 'RoomMailbox')
            {
                Write-Verbose -Message 'Removing the AddNewRequestsTentatively parameter because the mailbox is not a resource one.'
                $updateParameters.Remove('AddNewRequestsTentatively') | Out-Null

                Write-Verbose -Message 'Removing the BookingType parameter because the mailbox is not a resource one.'
                $updateParameters.Remove('BookingType') | Out-Null

                Write-Verbose -Message 'Removing the ProcessExternalMeetingMessages parameter because the mailbox is not a resource one.'
                $updateParameters.Remove('ProcessExternalMeetingMessages') | Out-Null
            }
        }

        Set-CalendarProcessing @updateParameters
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
            $dscContent = [System.Text.StringBuilder]::new()
            [array]$mailboxes = Get-M365DSCExportCachedCollection -Collection 'exoMailboxes'

            if ($null -eq $mailboxes)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
                return ''
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }

            Write-Verbose -Message 'Fetching all users for caching purposes'
            $this.ResourceCache['UsersCache'] = [System.Collections.Generic.Dictionary[System.String, System.String]]::new()
            [array]$exoUsers = Get-M365DSCExportCachedCollection -Collection 'exoUsers'
            foreach ($exoUser in $exoUsers)
            {
                $this.ResourceCache['UsersCache'][$exoUser.Identity] = $exoUser.UserPrincipalName
            }
            Write-Verbose -Message 'Fetching all recipients for caching purposes'
            Get-Recipient -ResultSize 'Unlimited' | ForEach-Object {
                $this.ResourceCache['UsersCache'][$_.Identity] = $_.PrimarySmtpAddress
            }

            $i = 1
            foreach ($mailbox in $mailboxes)
            {
                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }

                Write-M365DSCHost -Message "    |---[$i/$($mailboxes.Count)] $($mailbox.UserPrincipalName)" -DeferWrite
                $Params = @{
                    Identity              = $mailbox.UserPrincipalName
                    Credential            = $this.Credential
                    ApplicationId         = $this.ApplicationId
                    TenantId              = $this.TenantId
                    CertificateThumbprint = $this.CertificateThumbprint
                    CertificatePassword   = $this.CertificatePassword
                    ManagedIdentity       = $this.ManagedIdentity
                    CertificatePath       = $this.CertificatePath
                    AccessTokens          = $this.AccessTokens
                }
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

    hidden [EXOCalendarProcessing] AsResult([System.Object] $Values)
    {
        if ($Values -is [EXOCalendarProcessing])
        {
            return $Values
        }

        $result = [EXOCalendarProcessing]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
