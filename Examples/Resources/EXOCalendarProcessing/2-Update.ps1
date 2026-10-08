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
        EXOCalendarProcessing "EXOCalendarProcessing-Example"
        {
            AddAdditionalResponse                = $False;
            AddNewRequestsTentatively            = $True;
            AddOrganizerToSubject                = $False; # Updated Property
            AllBookInPolicy                      = $True;
            AllowConflicts                       = $False;
            AllowRecurringMeetings               = $True;
            AllRequestInPolicy                   = $False;
            AllRequestOutOfPolicy                = $False;
            AutomateProcessing                   = "AutoUpdate";
            BookingType                          = "Standard";
            BookingWindowInDays                  = 180;
            BookInPolicy                         = @();
            ConflictPercentageAllowed            = 0;
            DeleteAttachments                    = $True;
            DeleteComments                       = $True;
            DeleteNonCalendarItems               = $True;
            DeleteSubject                        = $True;
            EnableAutoRelease                    = $False;
            EnableResponseDetails                = $True;
            EnforceCapacity                      = $False;
            EnforceSchedulingHorizon             = $True;
            Ensure                               = "Present";
            ForwardRequestsToDelegates           = $True;
            Identity                             = "MeganB@$TenantId";
            MaximumConflictInstances             = 0;
            MaximumDurationInMinutes             = 1440;
            MinimumDurationInMinutes             = 0;
            OrganizerInfo                        = $True;
            PostReservationMaxClaimTimeInMinutes = 10;
            ProcessExternalMeetingMessages       = $False;
            RemoveCanceledMeetings               = $False;
            RemoveForwardedMeetingNotifications  = $False;
            RemoveOldMeetingMessages             = $False;
            RemovePrivateProperty                = $True;
            RequestInPolicy                      = @("AlexW@$TenantId");
            ResourceDelegates                    = @();
            ScheduleOnlyDuringWorkHours          = $False;
            TentativePendingApproval             = $True;
            ApplicationId                        = $ApplicationId
            TenantId                             = $TenantId
            CertificateThumbprint                = $CertificateThumbprint
        }
    }
}
