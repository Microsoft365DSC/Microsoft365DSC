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
        TeamsEnhancedEncryptionPolicy 'TeamsEnhancedEncryptionPolicy-Example'
        {
            CallingEndtoEndEncryptionEnabledType = 'Disabled'
            Description                          = 'End-to-end encryption options for the executive and legal teams' # Updated Property
            Ensure                               = 'Present'
            Identity                             = 'Executive Encryption'
            MeetingEndToEndEncryption            = 'DisabledUserOverride'
            ApplicationId                        = $ApplicationId
            TenantId                             = $TenantId
            CertificateThumbprint                = $CertificateThumbprint
        }
    }
}
