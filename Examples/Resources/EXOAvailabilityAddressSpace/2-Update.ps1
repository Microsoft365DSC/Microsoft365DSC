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
        EXOAvailabilityAddressSpace 'EXOAvailabilityAddressSpace-Example'
        {
            Identity              = 'freebusy.contoso.com'
            AccessMethod          = 'OrgWideFBToken'
            ForestName            = 'freebusy.contoso.com'
            TargetServiceEpr      = 'https://contoso.com/autodiscover/autodiscover.xml'
            TargetTenantId        = "$TenantId" # Updated Property
            Ensure                = 'Present'
            ApplicationId         = $ApplicationId
            TenantId              = $TenantId
            CertificateThumbprint = $CertificateThumbprint
        }
    }
}
