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
        EXOMailboxPermission "EXOMailboxPermission-Example"
        {
            AccessRights          = @("FullAccess","ReadPermission");
            Deny                  = $True; # Updated Property
            Ensure                = "Present";
            Identity              = "AlexW@$TenantId";
            InheritanceType       = "All";
            User                  = "NT AUTHORITY\SELF";
            ApplicationId         = $ApplicationId
            TenantId              = $TenantId
            CertificateThumbprint = $CertificateThumbprint
        }
    }
}
