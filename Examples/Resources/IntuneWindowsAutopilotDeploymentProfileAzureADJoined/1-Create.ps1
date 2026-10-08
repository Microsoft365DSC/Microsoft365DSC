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
        IntuneWindowsAutopilotDeploymentProfileAzureADJoined 'IntuneWindowsAutopilotDeploymentProfileAzureADJoined-Example'
        {
            Assignments                    = @(
                MSFT_DeviceManagementConfigurationPolicyAssignments{
                    dataType                                   = "#microsoft.graph.allDevicesAssignmentTarget"
                    deviceAndAppManagementAssignmentFilterType = "none"
                }
                MSFT_DeviceManagementConfigurationPolicyAssignments{
                    dataType         = "#microsoft.graph.exclusionGroupAssignmentTarget"
                    groupDisplayName = "Intune Excluded Devices"
                }
            );
            Description                    = "User-driven provisioning for Entra joined laptops";
            DeviceNameTemplate             = "CONTOSO-%RAND:6%";
            DeviceType                     = "windowsPc";
            DisplayName                    = "AAD";
            PreprovisioningAllowed               = $true;
            EnrollmentStatusScreenSettings = MSFT_MicrosoftGraphwindowsEnrollmentStatusScreenSettings{
                AllowDeviceUseBeforeProfileAndAppInstallComplete = $false
                AllowDeviceUseOnInstallFailure                   = $true
                AllowLogCollectionOnInstallFailure               = $true
                BlockDeviceSetupRetryByUser                      = $false
                CustomErrorMessage                               = "Setup could not be completed. Please contact the service desk on extension 4500."
                HideInstallationProgress                         = $false
                InstallProgressTimeoutInMinutes                  = 60
            };
            Ensure                         = "Present";
            HardwareHashExtractionEnabled  = $true;
            Locale                         = "en-US";
            ManagementServiceAppId         = "<application-id>";
            OutOfBoxExperienceSetting     = MSFT_MicrosoftGraphoutOfBoxExperienceSetting{
                DeviceUsageType           = "singleUser"
                EulaHidden                  = $false
                EscapeLinkHidden            = $true
                PrivacySettingsHidden       = $true
                KeyboardSelectionPageSkipped = $true
                UserType                  = "administrator"
            };
            RoleScopeTagIds                = @("0");
            ApplicationId                  = $ApplicationId;
            TenantId                       = $TenantId;
            CertificateThumbprint          = $CertificateThumbprint;
        }
    }
}
