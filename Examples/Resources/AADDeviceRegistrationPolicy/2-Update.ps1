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
        AADDeviceRegistrationPolicy "AADDeviceRegistrationPolicy-Example"
        {
            AzureADAllowedToJoin                    = "Selected";
            AzureADAllowedToJoinGroups              = @();
            AzureADAllowedToJoinUsers               = @("AlexW@M365x73318397.OnMicrosoft.com");
            AzureAdJoinLocalAdminsRegisteringGroups = @();
            AzureAdJoinLocalAdminsRegisteringMode   = "Selected";
            AzureAdJoinLocalAdminsRegisteringUsers  = @("AllanD@M365x73318397.OnMicrosoft.com");
            AzureADRegistration                     = MSFT_AzureADRegistrationPolicy{
                AllowedToRegister   = MSFT_DeviceRegistrationMembership{
                    Groups    = @()
                    Users     = @()
                    odataType = "#microsoft.graph.allDeviceRegistrationMembership"
                }
                IsAdminConfigurable = $False
            };
            IsSingleInstance                        = "Yes";
            LocalAdminPasswordIsEnabled             = $False;
            LocalAdminsEnableGlobalAdmins           = $True;
            MultiFactorAuthConfiguration            = "required";
            UserDeviceQuota                         = 50;
            ApplicationId                           = $ApplicationId;
            TenantId                                = $TenantId;
            CertificateThumbprint                   = $CertificateThumbprint;
        }
    }
}
