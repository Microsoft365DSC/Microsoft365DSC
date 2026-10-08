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
        EXOATPBuiltInProtectionRule "EXOATPBuiltInProtectionRule-Example"
        {
            Comments                  = "Excludes the security awareness team and partner domains from built-in protection";
            Ensure                    = "Present";
            ExceptIfRecipientDomainIs = @("contoso.com","fabrikam.com");
            ExceptIfSentTo            = @("AlexW@$TenantId");
            ExceptIfSentToMemberOf    = @("Executives@$TenantId");
            Identity                  = "ATP Built-In Protection Rule";
            ApplicationId             = $ApplicationId;
            TenantId                  = $TenantId;
            CertificateThumbprint     = $CertificateThumbprint;
        }
    }
}
