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
        EXOSafeAttachmentPolicy 'EXOSafeAttachmentPolicy-Example'
        {
            Identity              = "Marketing Block Attachments"
            Action                = "Block"
            AdminDisplayName      = "Blocks malicious attachments sent to the marketing department"
            QuarantineTag         = "AdminOnlyAccessPolicy"
            Enable                = $True
            Redirect              = $True
            RedirectAddress       = "MeganB@$TenantId"
            Ensure                = "Present"
            ApplicationId         = $ApplicationId
            TenantId              = $TenantId
            CertificateThumbprint = $CertificateThumbprint
        }
    }
}
