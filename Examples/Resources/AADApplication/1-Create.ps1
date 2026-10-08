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
        AADApplication 'AADApplication-Example'
        {
            DisplayName                     = "AppDisplayName"
            AuthenticationBehaviors         = MSFT_MicrosoftGraphauthenticationBehaviors{
                BlockAzureADGraphAccess    = 'Null'
                RemoveUnverifiedEmailClaim = 'Null'
            }
            Description                     = "Application Description"
            GroupMembershipClaims           = "None"
            Homepage                        = "https://$TenantId"
            IdentifierUris                  = "https://$TenantId"
            KnownClientApplications         = ""
            LogoutURL                       = "https://$TenantId/logout"
            PublicClient                    = $false
            ReplyURLs                       = "https://$TenantId"
            DefaultRedirectUri              = "https://$TenantId"
            IsFallbackPublicClient          = $false
            IsDeviceOnlyAuthSupported       = $false
            IsDisabled                      = $false
            NativeAuthenticationApisEnabled = "none"
            Notes                           = "Reviewed annually by the identity governance team"
            SamlMetadataUrl                 = "https://$TenantId/federationmetadata/2007-06/federationmetadata.xml"
            PublicClientRedirectUris        = @("https://login.microsoftonline.com/common/oauth2/nativeclient")
            ServiceManagementReference      = "IT-SVC-0001"
            SignInAudience                  = "AzureADMyOrg"
            Owners                          = @("admin@$TenantId")
            Info                            = MSFT_MicrosoftGraphInformationalUrl{
                MarketingUrl               = "https://$TenantId/marketing"
                PrivacyStatementUrl        = "https://$TenantId/privacy"
                SupportUrl                 = "https://$TenantId/support"
                TermsOfServiceUrl          = "https://$TenantId/termsofservice"
            }
            Spa                             = MSFT_AADApplicationSpa{
                RedirectUris               = @("https://$TenantId/spa")
            }
            OptionalClaims                  = MSFT_MicrosoftGraphoptionalClaims{
                AccessToken                = @(
                    MSFT_MicrosoftGraphOptionalClaim{
                        Name                    = "groups"
                        Essential               = $false
                    }
                )
                IdToken                    = @(
                    MSFT_MicrosoftGraphOptionalClaim{
                        Name                    = "upn"
                        Essential               = $false
                    }
                )
                Saml2Token                 = @(
                    MSFT_MicrosoftGraphOptionalClaim{
                        Name                    = "groups"
                        Essential               = $false
                    }
                )
            }
            Api                             = MSFT_MicrosoftGraphapiApplication{
                Oauth2PermissionScopes     = @(
                    MSFT_MicrosoftGraphAPIOauth2PermissionScopes{
                        adminConsentDescription = "Allows the app to read the signed-in user's profile."
                        adminConsentDisplayName = "Read user profile"
                        userConsentDescription  = "Allows the app to read your profile."
                        userConsentDisplayName  = "Read your profile"
                        value                   = "Profile.Read"
                        isEnabled               = $true
                        type                    = "User"
                    }
                )
            }
            AppRoles                        = @(
                MSFT_MicrosoftGraphappRole{
                    AllowedMemberTypes  = @("User")
                    Description         = "Readers can view expense report data."
                    DisplayName         = "Reader"
                    Id                  = "c1b2a3d4-5e6f-4a7b-8c9d-0e1f2a3b4c5d"
                    IsEnabled           = $true
                    Origin              = "Application"
                    Value               = "Expenses.Read"
                }
            )
            RequiredResourceAccess          = @(
                MSFT_AADApplicationPermission
                {
                    Name                = 'User.Read'
                    Type                = 'Delegated'
                    SourceAPI           = 'Microsoft Graph'
                    AdminConsentGranted = $false
                }
                MSFT_AADApplicationPermission
                {
                    Name                = 'User.ReadWrite.All'
                    Type                = 'Delegated'
                    SourceAPI           = 'Microsoft Graph'
                    AdminConsentGranted = $True
                }
                MSFT_AADApplicationPermission
                {
                    Name                = 'User.Read.All'
                    Type                = 'AppOnly'
                    SourceAPI           = 'Microsoft Graph'
                    AdminConsentGranted = $True
                }
            )
            Tags                            = @("Finance", "Expense Reporting")
            TokenEncryptionKeyId            = "<token-encryption-key-id>"
            TokenLifetimePolicy             = 'AADTokenLifetimePolicy_1'
            Ensure                          = "Present"
            ApplicationId                   = $ApplicationId
            TenantId                        = $TenantId
            CertificateThumbprint           = $CertificateThumbprint
        }
    }
}
