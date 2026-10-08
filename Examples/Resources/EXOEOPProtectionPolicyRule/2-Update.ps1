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
        EXOEOPProtectionPolicyRule "EXOEOPProtectionPolicyRule-Example"
        {
            Comments                  = "Scopes the Standard preset EOP policy to the pilot recipients.";
            Ensure                    = "Present";
            ExceptIfRecipientDomainIs = @("fabrikam.com");
            ExceptIfSentTo            = @("AlexW@$TenantId");
            ExceptIfSentToMemberOf    = @("Executives@$TenantId");
            Identity                  = "Standard Preset Security Policy";
            Name                      = "Standard Preset Security Policy";
            Priority                  = 0;
            RecipientDomainIs         = @("contoso.com");
            SentTo                    = @("AdeleV@$TenantId");
            SentToMemberOf            = @("Retail@$TenantId");
            State                     = "Disabled";
            ApplicationId             = $ApplicationId
            TenantId                  = $TenantId
            CertificateThumbprint     = $CertificateThumbprint
        }
    }
}
