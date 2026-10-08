using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class EXOMailboxCalendarConfiguration : M365DSCResourceBase
{
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

    [DscProperty(Key)]
    [System.ComponentModel.Description('Specifies the mailbox identity.')]
    [System.String] $Identity

    [DscProperty()]
    [System.ComponentModel.Description('Enables or disables agenda mail introduction.')]
    [System.Nullable[System.Boolean]] $AgendaMailIntroductionEnabled

    [DscProperty()]
    [System.ComponentModel.Description('Automatically declines meeting requests when the user is busy.')]
    [System.Nullable[System.Boolean]] $AutoDeclineWhenBusy

    [DscProperty()]
    [System.ComponentModel.Description('Preferred language for calendar feeds.')]
    [System.String] $CalendarFeedsPreferredLanguage

    [DscProperty()]
    [System.ComponentModel.Description('Preferred region for calendar feeds.')]
    [System.String] $CalendarFeedsPreferredRegion

    [DscProperty()]
    [System.ComponentModel.Description('Root page ID for calendar feeds.')]
    [System.String] $CalendarFeedsRootPageId

    [DscProperty()]
    [System.ComponentModel.Description('Enables or disables conversational scheduling.')]
    [System.Nullable[System.Boolean]] $ConversationalSchedulingEnabled

    [DscProperty()]
    [System.ComponentModel.Description('Creates events from email as private.')]
    [System.Nullable[System.Boolean]] $CreateEventsFromEmailAsPrivate

    [DscProperty()]
    [System.ComponentModel.Description('Default minutes to reduce long events by.')]
    [System.Nullable[System.UInt32]] $DefaultMinutesToReduceLongEventsBy

    [DscProperty()]
    [System.ComponentModel.Description('Default minutes to reduce short events by.')]
    [System.Nullable[System.UInt32]] $DefaultMinutesToReduceShortEventsBy

    [DscProperty()]
    [System.ComponentModel.Description('Default online meeting provider.')]
    [System.String] $DefaultOnlineMeetingProvider

    [DscProperty()]
    [System.ComponentModel.Description('Default reminder time.')]
    [System.String] $DefaultReminderTime

    [DscProperty()]
    [System.ComponentModel.Description('Deletes meeting request on respond.')]
    [System.Nullable[System.Boolean]] $DeleteMeetingRequestOnRespond

    [DscProperty()]
    [System.ComponentModel.Description('Enables or disables dining events from email.')]
    [System.Nullable[System.Boolean]] $DiningEventsFromEmailEnabled

    [DscProperty()]
    [System.ComponentModel.Description('Enables or disables entertainment events from email.')]
    [System.Nullable[System.Boolean]] $EntertainmentEventsFromEmailEnabled

    [DscProperty()]
    [System.ComponentModel.Description('Enables or disables events from email.')]
    [System.Nullable[System.Boolean]] $EventsFromEmailEnabled

    [DscProperty()]
    [System.ComponentModel.Description('Specifies the first week of the year.')]
    [System.String] $FirstWeekOfYear

    [DscProperty()]
    [System.ComponentModel.Description('Enables or disables flight events from email.')]
    [System.Nullable[System.Boolean]] $FlightEventsFromEmailEnabled

    [DscProperty()]
    [System.ComponentModel.Description('Enables or disables hotel events from email.')]
    [System.Nullable[System.Boolean]] $HotelEventsFromEmailEnabled

    [DscProperty()]
    [System.ComponentModel.Description('Enables or disables invoice events from email.')]
    [System.Nullable[System.Boolean]] $InvoiceEventsFromEmailEnabled

    [DscProperty()]
    [System.ComponentModel.Description('Specifies location details in free/busy information.')]
    [System.String] $LocationDetailsInFreeBusy

    [DscProperty()]
    [System.ComponentModel.Description('Specifies the mailbox location.')]
    [System.String] $MailboxLocation

    [DscProperty()]
    [System.ComponentModel.Description('Enables or disables online meetings by default.')]
    [System.Nullable[System.Boolean]] $OnlineMeetingsByDefaultEnabled

    [DscProperty()]
    [System.ComponentModel.Description('Enables or disables package delivery events from email.')]
    [System.Nullable[System.Boolean]] $PackageDeliveryEventsFromEmailEnabled

    [DscProperty()]
    [System.ComponentModel.Description('Preserves declined meetings.')]
    [System.Nullable[System.Boolean]] $PreserveDeclinedMeetings

    [DscProperty()]
    [System.ComponentModel.Description('Enables or disables reminders.')]
    [System.Nullable[System.Boolean]] $RemindersEnabled

    [DscProperty()]
    [System.ComponentModel.Description('Enables or disables reminder sound.')]
    [System.Nullable[System.Boolean]] $ReminderSoundEnabled

    [DscProperty()]
    [System.ComponentModel.Description('Enables or disables rental car events from email.')]
    [System.Nullable[System.Boolean]] $RentalCarEventsFromEmailEnabled

    [DscProperty()]
    [System.ComponentModel.Description('Enables or disables service appointment events from email.')]
    [System.Nullable[System.Boolean]] $ServiceAppointmentEventsFromEmailEnabled

    [DscProperty()]
    [System.ComponentModel.Description('Specifies the default scope for shortening events.')]
    [System.String] $ShortenEventScopeDefault

    [DscProperty()]
    [System.ComponentModel.Description('Shows or hides week numbers.')]
    [System.Nullable[System.Boolean]] $ShowWeekNumbers

    [DscProperty()]
    [System.ComponentModel.Description('Specifies the time increment for calendar events.')]
    [System.String] $TimeIncrement

    [DscProperty()]
    [System.ComponentModel.Description('Uses a bright calendar color theme in Outlook on the web.')]
    [System.Nullable[System.Boolean]] $UseBrightCalendarColorThemeInOwa

    [DscProperty()]
    [System.ComponentModel.Description('Enables or disables weather information.')]
    [System.String] $WeatherEnabled

    [DscProperty()]
    [System.ComponentModel.Description('Specifies the weather location bookmark.')]
    [System.Nullable[System.UInt32]] $WeatherLocationBookmark

    [DscProperty()]
    [System.ComponentModel.Description('Specifies the weather locations.')]
    [System.String[]] $WeatherLocations

    [DscProperty()]
    [System.ComponentModel.Description('Specifies the weather unit.')]
    [System.String] $WeatherUnit

    [DscProperty()]
    [System.ComponentModel.Description('Specifies the start day of the week.')]
    [System.String] $WeekStartDay

    [DscProperty()]
    [System.ComponentModel.Description('Specifies the work days.')]
    [System.String] $WorkDays

    [DscProperty()]
    [System.ComponentModel.Description('Specifies the end time of working hours.')]
    [System.String] $WorkingHoursEndTime

    [DscProperty()]
    [System.ComponentModel.Description('Specifies the start time of working hours.')]
    [System.String] $WorkingHoursStartTime

    [DscProperty()]
    [System.ComponentModel.Description('Specifies the time zone for working hours.')]
    [System.String] $WorkingHoursTimeZone

    [DscProperty()]
    [System.ComponentModel.Description('Enables or disables workspace user.')]
    [System.Nullable[System.Boolean]] $WorkspaceUserEnabled

    [DscProperty()]
    [System.ComponentModel.Description('Ensures the presence or absence of the configuration.')]
    [System.String] $Ensure

    # Export-only. Not part of the resource schema.
    [System.Management.Automation.PSCredential] $ApplicationSecret

    [EXOMailboxCalendarConfiguration] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [EXOMailboxCalendarConfiguration]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of Mailbox Calendar Configuration with Identity $($this.Identity)"

        try
        {
            $null = $this.Connect('ExchangeOnline')

            #Ensure the proper dependencies are installed in the current environment.
            Confirm-M365DSCDependencies

            #region Telemetry
            $this.AddTelemetry('Get')
            #endregion

            $nullResult = $this.GetBoundParameters()
            $nullResult.Ensure = 'Absent'

            # The cmdlet will show the warning "Events from Email parameters of this cmdlet are deprecated. Use Get-EventsFromEmailConfiguration instead."
            # However, the new cmdlet does not work and throws an Internal Server Error exception
            # Keep using Get-MailboxCalendarConfiguration for now
            $config = Get-MailboxCalendarConfiguration -Identity $this.Identity -ErrorAction SilentlyContinue

            if ($null -eq $config)
            {
                Write-Verbose -Message "Mailbox Calendar Configuration with Identity $($this.Identity) not found"
                return $this.AsResult($nullResult)
            }

            Write-Verbose -Message "Found Mailbox Calendar Configuration for $($this.Identity)"

            $results = @{
                Ensure                                   = 'Present'
                Identity                                 = $this.Identity
                AgendaMailIntroductionEnabled            = $config.AgendaMailIntroductionEnabled
                AutoDeclineWhenBusy                      = $config.AutoDeclineWhenBusy
                CalendarFeedsPreferredLanguage           = $config.CalendarFeedsPreferredLanguage
                CalendarFeedsPreferredRegion             = $config.CalendarFeedsPreferredRegion
                CalendarFeedsRootPageId                  = $config.CalendarFeedsRootPageId
                ConversationalSchedulingEnabled          = $config.ConversationalSchedulingEnabled
                CreateEventsFromEmailAsPrivate           = $config.CreateEventsFromEmailAsPrivate
                DefaultMinutesToReduceLongEventsBy       = $config.DefaultMinutesToReduceLongEventsBy
                DefaultMinutesToReduceShortEventsBy      = $config.DefaultMinutesToReduceShortEventsBy
                DefaultOnlineMeetingProvider             = $config.DefaultOnlineMeetingProvider
                DefaultReminderTime                      = $config.DefaultReminderTime
                DeleteMeetingRequestOnRespond            = $config.DeleteMeetingRequestOnRespond
                DiningEventsFromEmailEnabled             = $config.DiningEventsFromEmailEnabled
                EntertainmentEventsFromEmailEnabled      = $config.EntertainmentEventsFromEmailEnabled
                EventsFromEmailEnabled                   = $config.EventsFromEmailEnabled
                FirstWeekOfYear                          = $config.FirstWeekOfYear
                FlightEventsFromEmailEnabled             = $config.FlightEventsFromEmailEnabled
                HotelEventsFromEmailEnabled              = $config.HotelEventsFromEmailEnabled
                InvoiceEventsFromEmailEnabled            = $config.InvoiceEventsFromEmailEnabled
                LocationDetailsInFreeBusy                = $config.LocationDetailsInFreeBusy
                MailboxLocation                          = $config.MailboxLocation
                OnlineMeetingsByDefaultEnabled           = $config.OnlineMeetingsByDefaultEnabled
                PackageDeliveryEventsFromEmailEnabled    = $config.PackageDeliveryEventsFromEmailEnabled
                PreserveDeclinedMeetings                 = $config.PreserveDeclinedMeetings
                RemindersEnabled                         = $config.RemindersEnabled
                ReminderSoundEnabled                     = $config.ReminderSoundEnabled
                RentalCarEventsFromEmailEnabled          = $config.RentalCarEventsFromEmailEnabled
                ServiceAppointmentEventsFromEmailEnabled = $config.ServiceAppointmentEventsFromEmailEnabled
                ShortenEventScopeDefault                 = $config.ShortenEventScopeDefault
                ShowWeekNumbers                          = $config.ShowWeekNumbers
                TimeIncrement                            = $config.TimeIncrement
                UseBrightCalendarColorThemeInOwa         = $config.UseBrightCalendarColorThemeInOwa
                WeatherEnabled                           = $config.WeatherEnabled
                WeatherLocationBookmark                  = $config.WeatherLocationBookmark
                WeatherLocations                         = [System.String[]]$config.WeatherLocations
                WeatherUnit                              = $config.WeatherUnit
                WeekStartDay                             = $config.WeekStartDay
                WorkDays                                 = $config.WorkDays
                WorkingHoursEndTime                      = $config.WorkingHoursEndTime
                WorkingHoursStartTime                    = $config.WorkingHoursStartTime
                WorkingHoursTimeZone                     = $config.WorkingHoursTimeZone
                WorkspaceUserEnabled                     = $config.WorkspaceUserEnabled
                Credential                               = $this.Credential
                ApplicationId                            = $this.ApplicationId
                TenantId                                 = $this.TenantId
                CertificateThumbprint                    = $this.CertificateThumbprint
                CertificatePath                          = $this.CertificatePath
                CertificatePassword                      = $this.CertificatePassword
                ManagedIdentity                          = $this.ManagedIdentity
                AccessTokens                             = $this.AccessTokens
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

        Write-Verbose -Message "Setting configuration of Mailbox Calendar Configuration with Identity $($this.Identity)"

        $null = $this.Connect('ExchangeOnline')

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $setParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()
        Set-MailboxCalendarConfiguration @SetParameters
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
            [array]$mailboxes = Get-M365DSCExportCachedCollection -Collection 'exoMailboxes'

            $i = 1
            $dscContent = [System.Text.StringBuilder]::new()
            if ($mailboxes.Length -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }
            foreach ($config in $mailboxes)
            {
                $displayedKey = $config.UserPrincipalName
                Write-M365DSCHost -Message "    |---[$i/$($mailboxes.Count)] $displayedKey" -DeferWrite
                $params = @{
                    Identity              = $config.UserPrincipalName
                    Credential            = $this.Credential
                    ApplicationId         = $this.ApplicationId
                    TenantId              = $this.TenantId
                    CertificateThumbprint = $this.CertificateThumbprint
                    CertificatePath       = $this.CertificatePath
                    CertificatePassword   = $this.CertificatePassword
                    ManagedIdentity       = $this.ManagedIdentity
                    AccessTokens          = $this.AccessTokens
                }
                $Results = $this.GetForExport($params)
                $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                    -ConnectionMode $ConnectionMode `
                    -ModulePath $this.GetModulePath() `
                    -Results $Results `
                    -Credential $this.Credential
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

    hidden [EXOMailboxCalendarConfiguration] AsResult([System.Object] $Values)
    {
        if ($Values -is [EXOMailboxCalendarConfiguration])
        {
            return $Values
        }

        $result = [EXOMailboxCalendarConfiguration]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
