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
        SCDLPSensitiveInformationType "SCDLPSensitiveInformationType-Example"
        {
            Description           = "Detects internal employee identification numbers";
            Ensure                = "Present";
            FileData              = "Employee identification numbers at Contoso consist of the letters EMP followed by five digits, such as EMP12345. They are issued by Human Resources when an employee joins the company and are printed on every badge, payslip and internal directory entry. Contractor numbers follow the same pattern but begin with the letters CON.";
            Locale                = "en-US";
            Name                  = "Contoso Employee ID";
            ApplicationId         = $ApplicationId;
            TenantId              = $TenantId;
            CertificateThumbprint = $CertificateThumbprint;
        }
    }
}
