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
        IntuneDeviceConfigurationEmailProfilePolicyWindows10 'IntuneDeviceConfigurationEmailProfilePolicyWindows10-Example'
        {
            AccountName                                = "Contoso Mail";
            Assignments                                = @(
                MSFT_DeviceManagementConfigurationPolicyAssignments{
                    dataType                                   = '#microsoft.graph.groupAssignmentTarget'
                    deviceAndAppManagementAssignmentFilterType = 'none'
                    groupDisplayName                           = 'Intune Pilot Users'
                }
            );
            Description                                = "Configures the built-in Windows mail app for Exchange Online";
            DeviceManagementApplicabilityRuleDeviceMode = MSFT_DeviceManagementApplicabilityRuleDeviceMode{
                Name       = "Standard configuration devices only"
                DeviceMode = "standardConfiguration"
                RuleType   = "include"
            };
            DeviceManagementApplicabilityRuleOsEdition = MSFT_DeviceManagementApplicabilityRuleOsEdition{
                Name           = "Enterprise and Professional editions only"
                OsEditionTypes = @("windows10Enterprise", "windows10Professional")
                RuleType       = "include"
            };
            DeviceManagementApplicabilityRuleOsVersion = MSFT_DeviceManagementApplicabilityRuleOsVersion{
                Name         = "Windows 10 22H2 through Windows 11 24H2"
                MinOSVersion = "10.0.19045.0"
                MaxOSVersion = "10.0.26100.9999"
                RuleType     = "include"
            };
            DisplayName                                = "Corporate Mail Profile";
            DurationOfEmailToSync                      = "unlimited";
            EmailAddressSource                         = "primarySmtpAddress";
            EmailSyncSchedule                          = "fifteenMinutes";
            Ensure                                     = "Present";
            HostName                                   = "outlook.office365.com";
            RequireSsl                                 = $true;
            RoleScopeTagIds                            = @("0");
            SyncCalendar                               = $true;
            SyncContacts                               = $true;
            SyncTasks                                  = $true;
            UserDomainNameSource                       = "fullDomainName";
            UsernameAADSource                          = "userPrincipalName";
            UsernameSource                             = "userPrincipalName";
            ApplicationId                              = $ApplicationId;
            TenantId                                   = $TenantId;
            CertificateThumbprint                      = $CertificateThumbprint;
        }
    }
}
