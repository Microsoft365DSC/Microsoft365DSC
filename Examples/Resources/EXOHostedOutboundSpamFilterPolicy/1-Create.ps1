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
        EXOHostedOutboundSpamFilterPolicy 'EXOHostedOutboundSpamFilterPolicy-Example'
        {
            Identity                                  = "Outbound Spam Limits"
            ActionWhenThresholdReached                = "BlockUserForToday"
            AdminDisplayName                          = ""
            AutoForwardingMode                        = "Automatic"
            BccSuspiciousOutboundAdditionalRecipients = @()
            BccSuspiciousOutboundMail                 = $False
            NotifyOutboundSpam                        = $False
            NotifyOutboundSpamRecipients              = @()
            RecipientLimitExternalPerHour             = 500
            RecipientLimitInternalPerHour             = 1000
            RecipientLimitPerDay                      = 1000
            Ensure                                    = "Present"
            ApplicationId                             = $ApplicationId
            TenantId                                  = $TenantId
            CertificateThumbprint                     = $CertificateThumbprint
        }
    }
}
