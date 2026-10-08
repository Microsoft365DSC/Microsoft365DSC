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
        AADTenantAppManagementPolicy "AADTenantAppManagementPolicy-Example"
        {
            ApplicationRestrictions = MSFT_AADTenantAppManagementPolicyRestrictions{
                passwordCredentials = @(
                    MSFT_AADTenantAppManagementPolicyRestrictionsCredential{
                        restrictForAppsCreatedAfterDateTime = "1/1/2021 3:37:00 PM"
                        restrictionType                     = "passwordAddition"
                        state                               = "enabled"
                    }
                    MSFT_AADTenantAppManagementPolicyRestrictionsCredential{
                        maxLifetime                         = "P4DT12H30M5S"
                        restrictForAppsCreatedAfterDateTime = "1/1/2001 3:37:00 PM"
                        restrictionType                     = "passwordLifetime"
                        state                               = "enabled"
                    }
                    MSFT_AADTenantAppManagementPolicyRestrictionsCredential{
                        restrictForAppsCreatedAfterDateTime = "1/1/2002 3:37:00 PM"
                        restrictionType                     = "customPasswordAddition"
                        state                               = "enabled"
                    }
                    MSFT_AADTenantAppManagementPolicyRestrictionsCredential{
                        restrictForAppsCreatedAfterDateTime = "1/1/2003 3:37:00 PM"
                        restrictionType                     = "symmetricKeyAddition"
                        state                               = "enabled"
                    }
                    MSFT_AADTenantAppManagementPolicyRestrictionsCredential{
                        maxLifetime                         = "P40DT0H0M0S"
                        restrictForAppsCreatedAfterDateTime = "1/1/2004 3:37:00 PM"
                        restrictionType                     = "symmetricKeyLifetime"
                        state                               = "enabled"
                    }
                )
                keyCredentials      = @(
                    MSFT_AADTenantAppManagementPolicyRestrictionsCredential{
                        maxLifetime                         = "P30DT0H0M0S"
                        restrictForAppsCreatedAfterDateTime = "1/1/2015 3:37:00 PM"
                        restrictionType                     = "asymmetricKeyLifetime"
                        state                               = "enabled"
                    }
                )
            };
            Description             = "Default tenant policy that enforces app management restrictions on applications and service principals. To apply policy to targeted resources, create a new policy under appManagementPolicies collection.";
            DisplayName             = "Default app management tenant policy";
            IsSingleInstance        = 'Yes';
            IsEnabled               = $True;
            ApplicationId           = $ApplicationId;
            TenantId                = $TenantId;
            CertificateThumbprint   = $CertificateThumbprint;
        }
    }
}
