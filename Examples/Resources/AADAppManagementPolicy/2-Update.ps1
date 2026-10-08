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
        AADAppManagementPolicy "AADAppManagementPolicy-Example"
        {
            Description           = "Restricts client secrets and limits credential lifetimes to 90 days";
            DisplayName           = "Application Credential Restrictions";
            Ensure                = "Present";
            IsEnabled             = $True;
            Restrictions          = MSFT_AADAppManagementPolicyRestrictions{
                keyCredentials      = @(
                    MSFT_AADAppManagementPolicyRestrictionsCredential{
                        maxLifetime                         = "P90D"
                        restrictForAppsCreatedAfterDateTime = "2026-01-01T00:00:00.0000000Z"
                        restrictionType                     = "asymmetricKeyLifetime"
                        state                               = "enabled"
                    }
                )
                passwordCredentials = @(
                    MSFT_AADAppManagementPolicyRestrictionsCredential{
                        restrictForAppsCreatedAfterDateTime = "2026-01-01T00:00:00.0000000Z"
                        restrictionType                     = "passwordAddition"
                        state                               = "disabled" # Updated Property
                    }
                    MSFT_AADAppManagementPolicyRestrictionsCredential{
                        maxLifetime                         = "P90D"
                        restrictForAppsCreatedAfterDateTime = "2026-01-01T00:00:00.0000000Z"
                        restrictionType                     = "passwordLifetime"
                        state                               = "enabled"
                    }
                    MSFT_AADAppManagementPolicyRestrictionsCredential{
                        restrictForAppsCreatedAfterDateTime = "2026-01-01T00:00:00.0000000Z"
                        restrictionType                     = "symmetricKeyAddition"
                        state                               = "enabled"
                    }
                    MSFT_AADAppManagementPolicyRestrictionsCredential{
                        maxLifetime                         = "P90D"
                        restrictForAppsCreatedAfterDateTime = "2026-01-01T00:00:00.0000000Z"
                        restrictionType                     = "symmetricKeyLifetime"
                        state                               = "enabled"
                    }
                )
            };
            ApplicationId         = $ApplicationId;
            TenantId              = $TenantId;
            CertificateThumbprint = $CertificateThumbprint;
        }
    }
}
