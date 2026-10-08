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
        IntuneAccountProtectionPolicyWindows10 'IntuneAccountProtectionPolicyWindows10-Example'
        {
            Description           = "Requires Windows Hello for Business with a hardware-backed PIN on corporate devices";
            DisplayName           = "Windows Hello for Business - Corporate";
            RoleScopeTagIds       = @("0");
            DeviceSettings        = MSFT_MicrosoftGraphIntuneSettingsCatalogDeviceSettings_IntuneAccountProtectionPolicyWindows10{
                EnablePinRecovery                     = "true"
                Expiration                            = 365
                FacialFeaturesUseEnhancedAntiSpoofing = "true"
                History                               = 10
                LowercaseLetters                      = "1"
                LsaCfgFlags                           = "2"
                MaximumPINLength                      = 12
                MinimumPINLength                      = 6
                RequireSecurityDevice                 = "true"
                SpecialCharacters                     = "0"
                UppercaseLetters                      = "1"
                UseCertificateForOnPremAuth           = "false"
                UsePassportForWork                    = "true"
            };
            UserSettings          = MSFT_MicrosoftGraphIntuneSettingsCatalogUserSettings_IntuneAccountProtectionPolicyWindows10{
                EnablePinRecovery     = "true"
                Expiration            = 365
                History               = 30 # Updated Property
                LowercaseLetters      = "1"
                MaximumPINLength      = 12
                MinimumPINLength      = 6
                RequireSecurityDevice = "true"
                SpecialCharacters     = "0"
                UppercaseLetters      = "1"
                UsePassportForWork    = "true"
            };
            Assignments           = @(
                MSFT_DeviceManagementConfigurationPolicyAssignments{
                    dataType                                   = "#microsoft.graph.allDevicesAssignmentTarget"
                    deviceAndAppManagementAssignmentFilterType = "none"
                }
                MSFT_DeviceManagementConfigurationPolicyAssignments{
                    dataType         = "#microsoft.graph.exclusionGroupAssignmentTarget"
                    groupDisplayName = "Intune Excluded Devices"
                }
            );
            Ensure                = "Present";
            ApplicationId         = $ApplicationId;
            TenantId              = $TenantId;
            CertificateThumbprint = $CertificateThumbprint;
        }
    }
}
