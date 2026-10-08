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
        FabricAdminTenantSettings "FabricAdminTenantSettings-Example"
        {
            IsSingleInstance                 = 'Yes'
            AADSSOForGateway                 = MSFT_FabricTenantSetting {
                settingName              = 'AADSSOForGateway'
                canSpecifySecurityGroups = $False
                enabled                  = $True
                tenantSettingGroup       = 'Integration settings'
                title                    = 'Microsoft Entra single sign-on for data gateway'
            };
            AdminApisIncludeDetailedMetadata = MSFT_FabricTenantSetting {
                settingName              = 'AdminApisIncludeDetailedMetadata'
                canSpecifySecurityGroups = $True
                enabled                  = $True
                tenantSettingGroup       = 'Admin API settings'
                title                    = 'Enhance admin APIs responses with detailed metadata'
                excludedSecurityGroups   = @('MyExcludedGroup')
                enabledSecurityGroups    = @('Group1','Group2')
            };
            ApplicationId                    = $ApplicationId
            TenantId                         = $TenantId
            CertificateThumbprint            = $CertificateThumbprint
        }
    }
}
