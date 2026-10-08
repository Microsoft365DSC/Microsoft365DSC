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
        IntuneDefenderGlobalExclusionsPolicyLinux 'IntuneDefenderGlobalExclusionsPolicyLinux-Example'
        {
            Assignments           = @();
            Description           = "";
            DisplayName           = "Linux Servers - Defender Global Exclusions";
            Ensure                = "Present";
            Exclusions            = @(
                MSFT_MicrosoftGraphIntuneSettingsCatalogExclusionsV2{
                    exclusions_item_path        = '/path/to/otherDirectory' # Updated Property
                    exclusions_item_isDirectory = 'true'
                    exclusions_item_type        = 'excludedPath'
                }
                MSFT_MicrosoftGraphIntuneSettingsCatalogExclusionsV2{
                    Exclusions_item_name = 'process1'
                    Exclusions_item_type = 'excludedFileName'
                }
            );
            RoleScopeTagIds       = @("0");
            ApplicationId         = $ApplicationId;
            TenantId              = $TenantId;
            CertificateThumbprint = $CertificateThumbprint;
        }
    }
}
