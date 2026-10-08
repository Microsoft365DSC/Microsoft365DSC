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
        EXOSafeAttachmentRule 'EXOSafeAttachmentRule-Example'
        {
            Identity                  = "Research Department Attachment Rule"
            Comments                  = "Applies to Research Department, except managers"
            Enabled                   = $False # Updated Property
            Priority                  = 0
            ExceptIfRecipientDomainIs = @("fabrikam.com")
            ExceptIfSentTo            = @("AlexW@$TenantId")
            ExceptIfSentToMemberOf    = "Executives@$TenantId"
            RecipientDomainIs         = @("contoso.com")
            SafeAttachmentPolicy      = "Marketing Block Attachments"
            SentTo                    = @("AdeleV@$TenantId")
            SentToMemberOf            = "Retail@$TenantId"
            Ensure                    = "Present"
            ApplicationId             = $ApplicationId
            TenantId                  = $TenantId
            CertificateThumbprint     = $CertificateThumbprint
        }
    }
}
