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
        EXOOrganizationRelationship 'EXOOrganizationRelationship-Example'
        {
            Name                       = "Contoso"
            ArchiveAccessEnabled       = $True
            DeliveryReportEnabled      = $True
            DomainNames                = "mail.contoso.com"
            Enabled                    = $True
            FreeBusyAccessEnabled      = $True
            FreeBusyAccessLevel        = "AvailabilityOnly"
            FreeBusyAccessScope        = "Executives"
            MailboxMoveEnabled         = $True
            MailboxMoveCapability      = "RemoteOutbound"
            MailboxMovePublishedScopes = @("Executives")
            MailTipsAccessEnabled      = $True
            MailTipsAccessLevel        = "Limited"
            MailTipsAccessScope        = "Executives"
            OrganizationContact        = "administrator@contoso.com"
            PhotosEnabled              = $True
            TargetApplicationUri       = "mail.contoso.com"
            TargetAutodiscoverEpr      = "https://mail.contoso.com/autodiscover/autodiscover.svc/wssecurity"
            TargetOwaURL               = "https://mail.contoso.com/owa"
            TargetSharingEpr           = "https://mail.contoso.com/EWS/Exchange.asmx"
            Ensure                     = "Present"
            ApplicationId              = $ApplicationId
            TenantId                   = $TenantId
            CertificateThumbprint      = $CertificateThumbprint
        }
    }
}
