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
        IntuneDeviceManagementAndroidDeviceOwnerEnrollmentProfile "IntuneDeviceManagementAndroidDeviceOwnerEnrollmentProfile-Example"
        {
            Description             = "Dedicated devices for the warehouse and loading dock scanning stations"; # Updated Property
            DeviceNameTemplate      = "Android-{{SERIAL}}";
            DisplayName             = "Corporate Android Enrollment";
            EnrollmentMode          = "corporateOwnedDedicatedDevice";
            EnrollmentTokenType     = "default";
            Ensure                  = "Present";
            IsTeamsDeviceProfile    = $False;
            RoleScopeTagIds         = @("0");
            TokenExpirationDateTime = "2026-01-01T00:00:00.0000000Z";
            ApplicationId           = $ApplicationId;
            TenantId                = $TenantId;
            CertificateThumbprint   = $CertificateThumbprint;
        }
    }
}
