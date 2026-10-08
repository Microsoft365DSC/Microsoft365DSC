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
        IntuneDeviceConfigurationPolicyAndroidOpenSourceProject 'IntuneDeviceConfigurationPolicyAndroidOpenSourceProject-Example'
        {
            DisplayName                                    = 'AOSP Device Restrictions'
            Description                                    = "Baseline restrictions for AOSP handheld scanners in the warehouse"
            RoleScopeTagIds                                = @("0")
            AppsBlockInstallFromUnknownSources             = $true
            BluetoothBlockConfiguration                    = $true
            BluetoothBlocked                               = $false
            CameraBlocked                                  = $false
            FactoryResetBlocked                            = $true
            PasswordMinimumLength                          = 6
            PasswordMinutesOfInactivityBeforeScreenTimeout = 5
            PasswordRequiredType                           = "numericComplex"
            PasswordSignInFailureCountBeforeFactoryReset   = 10
            ScreenCaptureBlocked                           = $true
            SecurityAllowDebuggingFeatures                 = $false
            StorageBlockExternalMedia                      = $true
            StorageBlockUsbFileTransfer                    = $true
            WifiBlockEditConfigurations                    = $true
            Assignments                                    = @(
                MSFT_DeviceManagementConfigurationPolicyAssignments{
                    dataType                                   = "#microsoft.graph.allDevicesAssignmentTarget"
                    deviceAndAppManagementAssignmentFilterType = "none"
                }
                MSFT_DeviceManagementConfigurationPolicyAssignments{
                    dataType                                   = "#microsoft.graph.exclusionGroupAssignmentTarget"
                    deviceAndAppManagementAssignmentFilterType = "none"
                    groupDisplayName                           = "Intune Excluded Devices"
                }
            )
            Ensure                                         = "Present"
            ApplicationId                                  = $ApplicationId;
            TenantId                                       = $TenantId;
            CertificateThumbprint                          = $CertificateThumbprint;
        }
    }
}
