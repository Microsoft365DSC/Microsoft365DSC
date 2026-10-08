<#
This example configures the Teams Dial In Conferencing Tenant Settings.
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
        TeamsDialInConferencingTenantSettings 'TeamsDialInConferencingTenantSettings-Example'
        {
            AllowPSTNOnlyMeetingsByDefault   = $False;
            AutomaticallyMigrateUserMeetings = $True;
            AutomaticallyReplaceAcpProvider  = $False;
            AutomaticallySendEmailsToUsers   = $True;
            EnableDialOutJoinConfirmation    = $False;
            EnableEntryExitNotifications     = $True;
            EntryExitAnnouncementsType       = "ToneOnly";
            IsSingleInstance                 = "Yes";
            MaskPstnNumbersType              = "MaskedForExternalUsers";
            PinLength                        = 8;
            ApplicationId                    = $ApplicationId;
            TenantId                         = $TenantId;
            CertificateThumbprint            = $CertificateThumbprint;
        }
    }
}
