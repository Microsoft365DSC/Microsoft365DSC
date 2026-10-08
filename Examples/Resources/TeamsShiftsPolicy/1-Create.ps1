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
        TeamsShiftsPolicy 'TeamsShiftsPolicy-Example'
        {
            Identity                       = 'Retail Shifts'
            AccessGracePeriodMinutes       = 15
            AccessType                     = 'UnrestrictedAccess_TeamsApp'
            EnableScheduleOwnerPermissions = $False
            Ensure                         = 'Present'
            ShiftNoticeFrequency           = 'Never'
            ShiftNoticeMessageCustom       = ''
            ShiftNoticeMessageType         = 'DefaultMessage'
            ApplicationId                  = $ApplicationId
            TenantId                       = $TenantId
            CertificateThumbprint          = $CertificateThumbprint
        }
    }
}
