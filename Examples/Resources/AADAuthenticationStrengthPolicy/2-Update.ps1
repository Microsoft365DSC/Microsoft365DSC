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
        AADAuthenticationStrengthPolicy "AADAuthenticationStrengthPolicy-Example"
        {
            AllowedCombinations   = @("windowsHelloForBusiness","fido2","deviceBasedPush"); # Updated Property
            Description           = "Requires phishing-resistant methods for privileged access";
            DisplayName           = "Phishing-Resistant MFA";
            Ensure                = "Present";
            ApplicationId         = $ApplicationId
            TenantId              = $TenantId
            CertificateThumbprint = $CertificateThumbprint
        }
    }
}
