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
        IntuneDiskEncryptionPDEPolicyWindows10 "IntuneDiskEncryptionPDEPolicyWindows10-Example"
        {
            Assignments                  = @();
            Description                  = "Enables Personal Data Encryption on corporate laptops";
            DisplayName                  = "Personal Data Encryption - Windows 11";
            Ensure                       = "Present";
            EnablePersonalDataEncryption = "1";
            ProtectDesktop               = "0";
            ProtectDocuments             = "1"; # Updated Property
            ProtectPictures              = "1"; # Updated Property
            RoleScopeTagIds              = @("0");
            ApplicationId                = $ApplicationId;
            TenantId                     = $TenantId;
            CertificateThumbprint        = $CertificateThumbprint;
        }
    }
}
