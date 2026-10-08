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
        SCLabelPolicy 'SCLabelPolicy-Example'
        {
            Name                         = "Finance Label Policy"
            Comment                      = "Publishes the Finance Confidential label to the finance team"
            Labels                       = @("Finance Confidential")
            ExchangeLocation             = @("AdeleV@$TenantId", "MeganB@$TenantId")
            ModernGroupLocation          = @("Mark8ProjectTeam@$TenantId")
            AdvancedSettings             = @(
                MSFT_SCLabelSetting{
                    Key   = "RequireDowngradeJustification"
                    Value = "True"
                }
                MSFT_SCLabelSetting{
                    Key   = "AttachmentAction"
                    Value = "Automatic"
                }
            )
            Ensure                       = "Present"
            ApplicationId                = $ApplicationId
            TenantId                     = $TenantId
            CertificateThumbprint        = $CertificateThumbprint
        }
    }
}
