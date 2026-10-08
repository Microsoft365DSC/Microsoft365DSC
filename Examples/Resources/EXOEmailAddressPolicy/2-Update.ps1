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
        EXOEmailAddressPolicy 'EXOEmailAddressPolicy-Example'
        {
            Name                              = "Standard Address Format"
            EnabledEmailAddressTemplates      = @("SMTP:@$TenantId")
            EnabledPrimarySMTPAddressTemplate = "@$TenantId"
            ManagedByFilter                   = "Department -eq 'Sales'" # Updated Property
            Priority                          = 1
            Ensure                            = "Present"
            ApplicationId                     = $ApplicationId
            TenantId                          = $TenantId
            CertificateThumbprint             = $CertificateThumbprint
        }
    }
}
