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
        TeamsComplianceRecordingPolicy "TeamsComplianceRecordingPolicy-Example"
        {
            ComplianceRecordingApplications                     = @(
                MSFT_TeamsComplianceRecordingApplication{
                    Id                                    = "<compliance-recording-application-id>"
                    ComplianceRecordingPairedApplications = @("<compliance-recording-paired-application-id>")
                    ConcurrentInvitationCount             = 1
                    RequiredDuringCall                    = $True
                    RequiredBeforeMeetingJoin             = $True
                    RequiredBeforeCallEstablishment       = $True
                    RequiredDuringMeeting                 = $True
                }
            );
            Description                                         = "Records calls and meetings of the trading floor staff";
            DisableComplianceRecordingAudioNotificationForCalls = $False;
            Enabled                                             = $True;
            Ensure                                              = "Present";
            Identity                                            = "Tag:Trading Floor Recording";
            WarnUserOnRemoval                                   = $True;
            ApplicationId                                       = $ApplicationId;
            TenantId                                            = $TenantId;
            CertificateThumbprint                               = $CertificateThumbprint;
        }
    }
}
