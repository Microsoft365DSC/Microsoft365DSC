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
        IntuneEndpointDetectionAndResponsePolicyWindows10 'IntuneEndpointDetectionAndResponsePolicyWindows10-Example'
        {
            DisplayName           = 'Edr Policy'
            Assignments           = @()
            Description           = 'My updated description' # Updated Property
            Ensure                = 'Present'
            ConfigurationBlob     = "<onboarding-blob>"
            ConfigurationType     = "onboard"
            SampleSharing         = 1
            ApplicationId         = $ApplicationId;
            TenantId              = $TenantId;
            CertificateThumbprint = $CertificateThumbprint;
        }
    }
}
