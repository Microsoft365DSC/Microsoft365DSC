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
        SCAutoSensitivityLabelPolicy 'SCAutoSensitivityLabelPolicy-Example'
        {
            ApplySensitivityLabel           = "defa4170-0d19-0005-000a-bc88714345d2";
            Comment                         = "Applies the Highly Confidential label to sales email and is reviewed quarterly by the compliance team"; # Updated Property
            Ensure                          = "Present";
            ExchangeLocation                = @("All");
            ExchangeSender                  = @("PradeepG@$TenantId");
            ExchangeSenderException         = @("MeganB@$TenantId");
            ExchangeSenderMemberOf          = @("U.S.Sales@$TenantId");
            ExchangeSenderMemberOfException = @("DigitalInitiativePublicRelations@$TenantId");
            Mode                            = "TestWithoutNotifications";
            Name                            = "Highly Confidential Sales Auto-labeling";
            Priority                        = 0;
            ApplicationId                   = $ApplicationId;
            TenantId                        = $TenantId;
            CertificateThumbprint           = $CertificateThumbprint;
        }
    }
}
