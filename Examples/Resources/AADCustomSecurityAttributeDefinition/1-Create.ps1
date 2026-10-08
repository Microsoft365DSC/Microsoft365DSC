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
        AADCustomSecurityAttributeDefinition "AADCustomSecurityAttributeDefinition-Example"
        {
            AllowedValues           = @(
                MSFT_CustomSecurityAttributeAllowedValue{
                    IsActive = $True
                    ValueId  = "Alpine"
                }
            );
            AttributeSet            = "Engineering";
            Ensure                  = "Present";
            IsCollection            = $False;
            IsSearchable            = $True;
            Name                    = "Project";
            Status                  = "Available";
            Type                    = "String";
            UsePreDefinedValuesOnly = $True;
            Description             = "Active project of the user"
            ApplicationId           = $ApplicationId;
            TenantId                = $TenantId;
            CertificateThumbprint   = $CertificateThumbprint;
        }
    }
}
