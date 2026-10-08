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
        AADConditionalAccessPolicy 'AADConditionalAccessPolicy-Example'
        {
            BuiltInControls                          = @("mfa");
            ClientAppTypes                           = @("all");
            ExcludeApplications                      = @("Office365");
            IncludeUsers                             = @("AdeleV@$TenantId");
            IncludeGroups                            = @("Sales and Marketing");
            ExcludeGroups                            = @("Retail");
            ExcludeRoles                             = @("Global Administrator");
            IncludeGuestOrExternalUserTypes          = @("b2bCollaborationGuest", "b2bCollaborationMember");
            IncludeExternalTenantsMembershipKind     = "all";
            IncludeExternalTenantsMembers            = @();
            ExcludeGuestOrExternalUserTypes          = @("serviceProvider");
            ExcludeExternalTenantsMembershipKind     = "enumerated";
            ExcludeExternalTenantsMembers            = @("11111111-1111-1111-1111-111111111111");
            IncludePlatforms                         = @("Android", "IOS");
            ExcludePlatforms                         = @("Windows", "MacOS");
            IncludeLocations                         = @("All");
            ExcludeLocations                         = @("AllTrusted");
            UserRiskLevels                           = @("High");
            SignInRiskLevels                         = @("High", "Medium");
            InsiderRiskLevels                        = @("elevated");
            TransferMethods                          = "deviceCodeFlow";
            ApplicationEnforcedRestrictionsIsEnabled = $false;
            CloudAppSecurityIsEnabled                = $true;
            CloudAppSecurityType                     = "MonitorOnly";
            SecureSignInSessionIsEnabled             = $false;
            DisableResilienceDefaultsIsEnabled       = $false;
            DeviceFilterMode                         = "exclude";
            DeviceFilterRule                         = "device.trustType -eq `"AzureAD`" -or device.trustType -eq `"ServerAD`" -or device.trustType -eq `"Workplace`"";
            DisplayName                              = "Require MFA for Mobile Devices";
            Ensure                                   = "Present";
            ExcludeUsers                             = @("MeganB@$TenantId");
            GrantControlOperator                     = "OR";
            IncludeApplications                      = @("All");
            IncludeRoles                             = @("Attack Payload Author");
            SignInFrequencyAuthenticationType        = "primaryAndSecondaryAuthentication";
            SignInFrequencyInterval                  = "timeBased";
            SignInFrequencyIsEnabled                 = $True;
            SignInFrequencyType                      = "hours";
            SignInFrequencyValue                     = 2; # Updated Property
            State                                    = "disabled";
            TermsOfUse                               = @("Company Terms of Use");
            ApplicationId                            = $ApplicationId
            TenantId                                 = $TenantId
            CertificateThumbprint                    = $CertificateThumbprint
        }
    }
}
