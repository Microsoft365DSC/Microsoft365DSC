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
        TeamsUnassignedNumberTreatment 'TeamsUnassignedNumberTreatment-Example'
        {
            Description           = "Routes calls to the retired reception number to the front desk team"; # Updated Property
            Ensure                = "Present";
            Identity              = "Former Reception Number";
            Pattern               = "^\+15552224444$";
            Target                = "<user-object-id>";
            TargetType            = "User";
            TreatmentPriority     = 3;
            ApplicationId         = $ApplicationId;
            TenantId              = $TenantId;
            CertificateThumbprint = $CertificateThumbprint;
        }
    }
}
