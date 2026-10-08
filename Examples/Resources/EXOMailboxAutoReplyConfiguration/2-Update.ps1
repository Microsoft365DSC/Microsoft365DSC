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
        EXOMailboxAutoReplyConfiguration "EXOMailboxAutoReplyConfiguration-Example"
        {
            AutoDeclineFutureRequestsWhenOOF = $False;
            AutoReplyState                   = "Disabled";
            CreateOOFEvent                   = $False;
            DeclineAllEventsForScheduledOOF  = $False;
            DeclineEventsForScheduledOOF     = $False;
            DeclineMeetingMessage            = "";
            EndTime                          = "1/23/2024 3:00:00 PM";
            Ensure                           = "Present";
            ExternalAudience                 = "All";
            ExternalMessage                  = (New-Guid).ToString(); # Updated Property
            Identity                         = "AdeleV@$TenantId";
            InternalMessage                  = "";
            OOFEventSubject                  = "";
            StartTime                        = "1/22/2024 3:00:00 PM";
            ApplicationId                    = $ApplicationId
            TenantId                         = $TenantId
            CertificateThumbprint            = $CertificateThumbprint
        }
    }
}
