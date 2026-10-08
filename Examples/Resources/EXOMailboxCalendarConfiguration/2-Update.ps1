<#
This example is used to test new resources and showcase the usage of new resources being worked on.
It is not meant to use as a production baseline.
#>

Configuration Example
{
    param
    (
        [Parameter()]
        [System.String]
        $ApplicationId,

        [Parameter()]
        [System.String]
        $TenantId,

        [Parameter()]
        [System.String]
        $CertificateThumbprint
    )

    Import-DscResource -ModuleName Microsoft365DSC

    Node localhost
    {
        EXOMailboxCalendarConfiguration "EXOMailboxCalendarConfiguration-Example"
        {
            AgendaMailIntroductionEnabled            = $True;
            AutoDeclineWhenBusy                      = $False;
            ConversationalSchedulingEnabled          = $True;
            CreateEventsFromEmailAsPrivate           = $True;
            DefaultMinutesToReduceLongEventsBy       = 10;
            DefaultMinutesToReduceShortEventsBy      = 6; # Updated Property
            DefaultOnlineMeetingProvider             = "TeamsForBusiness";
            DefaultReminderTime                      = "00:15:00";
            DeleteMeetingRequestOnRespond            = $True;
            DiningEventsFromEmailEnabled             = $True;
            Ensure                                   = "Present";
            EntertainmentEventsFromEmailEnabled      = $True;
            EventsFromEmailEnabled                   = $True;
            FirstWeekOfYear                          = "FirstDay";
            FlightEventsFromEmailEnabled             = $True;
            HotelEventsFromEmailEnabled              = $True;
            Identity                                 = "MeganB@$TenantId";
            InvoiceEventsFromEmailEnabled            = $True;
            LocationDetailsInFreeBusy                = "Desk";
            PackageDeliveryEventsFromEmailEnabled    = $False;
            PreserveDeclinedMeetings                 = $False;
            RemindersEnabled                         = $True;
            ReminderSoundEnabled                     = $True;
            RentalCarEventsFromEmailEnabled          = $True;
            ServiceAppointmentEventsFromEmailEnabled = $True;
            ShortenEventScopeDefault                 = "None";
            ShowWeekNumbers                          = $False;
            TimeIncrement                            = "ThirtyMinutes";
            UseBrightCalendarColorThemeInOwa         = $False;
            WeatherEnabled                           = "FirstRun";
            WeatherLocationBookmark                  = 0;
            WeatherLocations                         = @();
            WeatherUnit                              = "Default";
            WeekStartDay                             = "Sunday";
            WorkDays                                 = "Monday, Tuesday";
            WorkingHoursEndTime                      = "17:00:00";
            WorkingHoursStartTime                    = "08:00:00";
            WorkingHoursTimeZone                     = "Pacific Standard Time";
            WorkspaceUserEnabled                     = $False;
            ApplicationId                            = $ApplicationId
            TenantId                                 = $TenantId
            CertificateThumbprint                    = $CertificateThumbprint
        }
    }
}
