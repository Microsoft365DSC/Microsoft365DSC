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
        IntuneDeviceConfigurationDefenderOnboardingPolicyWindows10 'IntuneDeviceConfigurationDefenderOnboardingPolicyWindows10-Example'
        {
            AdvancedThreatProtectionAutoPopulateOnboardingBlob = $true; # Updated Property
            AdvancedThreatProtectionOffboardingBlob            = "<offboarding-blob>";
            AdvancedThreatProtectionOffboardingFilename        = "WindowsDefenderATP.offboarding";
            AdvancedThreatProtectionOnboardingFilename         = "WindowsDefenderATP.onboarding";
            AllowSampleSharing                                 = $true;
            Assignments                                        = @(
                MSFT_DeviceManagementConfigurationPolicyAssignments{
                    dataType                                   = '#microsoft.graph.groupAssignmentTarget'
                    deviceAndAppManagementAssignmentFilterType = 'none'
                    groupDisplayName                           = 'Intune Pilot Devices'
                }
            );
            Description                                        = "Onboards corporate Windows endpoints to Microsoft Defender for Endpoint";
            DeviceManagementApplicabilityRuleDeviceMode        = MSFT_DeviceManagementApplicabilityRuleDeviceMode{
                Name       = "Standard configuration devices only"
                DeviceMode = "standardConfiguration"
                RuleType   = "include"
            };
            DeviceManagementApplicabilityRuleOsEdition         = MSFT_DeviceManagementApplicabilityRuleOsEdition{
                Name           = "Enterprise and Professional editions only"
                OsEditionTypes = @("windows10Enterprise", "windows10Professional")
                RuleType       = "include"
            };
            DeviceManagementApplicabilityRuleOsVersion         = MSFT_DeviceManagementApplicabilityRuleOsVersion{
                Name         = "Windows 10 22H2 or later"
                MinOSVersion = "10.0.19045.0"
                MaxOSVersion = "10.0.26100.9999"
                RuleType     = "include"
            };
            DisplayName                                        = "MDE onboarding Legacy";
            EnableExpeditedTelemetryReporting                  = $true;
            Ensure                                             = "Present";
            RoleScopeTagIds                                    = @("0");
            ApplicationId                                      = $ApplicationId;
            TenantId                                           = $TenantId;
            CertificateThumbprint                              = $CertificateThumbprint;
        }
    }
}
