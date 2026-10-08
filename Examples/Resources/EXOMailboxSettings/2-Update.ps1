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
        EXOMailboxSettings 'EXOMailboxSettings-Example'
        {
            DisplayName           = 'Conf Room Adams'
            TimeZone              = 'Eastern Standard Time'
            Locale                = 'en-US'
            RetentionPolicy       = 'Default MRM Policy'
            RoleAssignmentPolicy  = 'Default Role Assignment Policy'
            SharingPolicy         = 'Default Sharing Policy'
            AuditEnabled          = $true
            Ensure                = 'Present'
            ApplicationId         = $ApplicationId
            TenantId              = $TenantId
            CertificateThumbprint = $CertificateThumbprint
        }
    }
}
