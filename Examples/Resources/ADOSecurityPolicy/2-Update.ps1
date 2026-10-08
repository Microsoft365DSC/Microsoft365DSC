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
        ADOSecurityPolicy "ADOSecurityPolicy-Example"
        {
            AllowAnonymousAccess                    = $True;
            AllowRequestAccessToken                 = $False;
            AllowTeamAdminsInvitationsAccessToken   = $True;
            ArtifactsExternalPackageProtectionToken = $False;
            DisallowAadGuestUserAccess              = $True;
            DisallowOAuthAuthentication             = $True;
            DisallowSecureShell                     = $False;
            EnforceAADConditionalAccess             = $False;
            LogAuditEvents                          = $True;
            OrganizationName                        = "Contoso-Dev";
            ApplicationId                           = $ApplicationId;
            TenantId                                = $TenantId;
            CertificateThumbprint                   = $CertificateThumbprint;
        }
    }
}
