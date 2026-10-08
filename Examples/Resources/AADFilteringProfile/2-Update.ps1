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
        AADFilteringProfile "AADFilteringProfile-Example"
        {
            Description           = "Applies the corporate web content filtering policies";
            Ensure                = "Present";
            Name                  = "Corporate Web Filtering";
            Policies              = @(
                MSFT_AADFilteringProfilePolicyLink{
                    Priority     = 100
                    LoggingState = 'enabled'
                    PolicyName   = 'MyPolicy'
                    State        = 'enabled'
                }
            );
            Priority              = 140; # Updated Property
            State                 = "enabled";
            ApplicationId         = $ApplicationId;
            TenantId              = $TenantId;
            CertificateThumbprint = $CertificateThumbprint;
        }
    }
}
