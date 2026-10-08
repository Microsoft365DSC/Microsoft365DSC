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
        TeamsCortanaPolicy 'TeamsCortanaPolicy-Example'
        {
            Identity                   = "Frontline Workers Cortana Policy"
            CortanaVoiceInvocationMode = "WakeWordPushToTalkUserOverride"
            Description                = "Lets shop floor staff call Cortana hands-free on shared devices"
            Ensure                     = "Present"
            ApplicationId              = $ApplicationId
            TenantId                   = $TenantId
            CertificateThumbprint      = $CertificateThumbprint
        }
    }
}
