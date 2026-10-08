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
        IntuneAccountProtectionLocalAdministratorPasswordSolutionPolicy "IntuneAccountProtectionLocalAdministratorPasswordSolutionPolicy-Example"
        {
            DisplayName                             = "Account Protection LAPS Policy";
            Description                             = "Backs up the managed local administrator password to Active Directory and rotates it every 30 days"; # Updated Property
            Ensure                                  = "Present";
            RoleScopeTagIds                         = @("0");
            Assignments                             = @(
                MSFT_IntuneAccountProtectionLocalAdministratorPasswordSolutionPolicyAssignments{
                    dataType                                   = "#microsoft.graph.allDevicesAssignmentTarget"
                    deviceAndAppManagementAssignmentFilterType = "none"
                }
                MSFT_IntuneAccountProtectionLocalAdministratorPasswordSolutionPolicyAssignments{
                    dataType         = "#microsoft.graph.exclusionGroupAssignmentTarget"
                    groupDisplayName = "Intune Excluded Devices"
                }
            );
            BackupDirectory                         = "2";
            PasswordAgeDays                         = 30;
            PasswordExpirationProtectionEnabled     = $true;
            AdEncryptedPasswordHistorySize          = 6;
            AdPasswordEncryptionEnabled             = $true;
            AdPasswordEncryptionPrincipal           = "CONTOSO\Helpdesk Administrators";
            AdministratorAccountName                = "LocalAdmin";
            PasswordComplexity                      = "4";
            PasswordLength                          = 16;
            PostAuthenticationActions               = "3";
            PostAuthenticationResetDelay            = 8;
            AutomaticAccountManagementEnabled       = "true";
            AutomaticAccountManagementTarget        = "1";
            AutomaticAccountManagementRandomizeName = "true";
            AutomaticAccountManagementNameOrPrefix  = "LocalAdmin";
            AutomaticAccountManagementEnableAccount = "true";
            ApplicationId                           = $ApplicationId;
            TenantId                                = $TenantId;
            CertificateThumbprint                   = $CertificateThumbprint;
        }
    }
}
