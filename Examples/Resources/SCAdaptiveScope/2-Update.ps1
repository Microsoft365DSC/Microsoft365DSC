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
        SCAdaptiveScope 'SCAdaptiveScope-Example'
        {
            AdministrativeUnit    = "New York Office";
            Comment               = "Members of the finance department located in New York"; # Updated Property
            EnabledStates         = @("Active", "Inactive");
            FilterConditions      = '{"Conditions":[{"Value":"Finance","Operator":"Equals","Name":"Department"},{"Value":"New York","Operator":"Equals","Name":"City"}],"Conjunction":"And"}';
            LocationType          = "User";
            Name                  = "Finance New York Users";
            Ensure                = "Present";
            ApplicationId         = $ApplicationId;
            TenantId              = $TenantId;
            CertificateThumbprint = $CertificateThumbprint;
        }
    }
}
