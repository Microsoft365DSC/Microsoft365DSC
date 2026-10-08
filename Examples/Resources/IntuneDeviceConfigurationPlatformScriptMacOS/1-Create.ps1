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
        IntuneDeviceConfigurationPlatformScriptMacOS 'IntuneDeviceConfigurationPlatformScriptMacOS-Example'
        {
            Assignments                 = @(
                MSFT_DeviceManagementConfigurationPolicyAssignments{
                    deviceAndAppManagementAssignmentFilterType = 'none'
                    dataType                                   = '#microsoft.graph.allDevicesAssignmentTarget'
                }
                MSFT_DeviceManagementConfigurationPolicyAssignments{
                    dataType         = '#microsoft.graph.exclusionGroupAssignmentTarget'
                    groupDisplayName = 'Intune Excluded Devices'
                }
            );
            DisplayName                 = "Configure Dock Layout";
            Ensure                      = "Present";
            BlockExecutionNotifications = $False;
            Description                 = "Hides the Dock automatically on managed Macs";
            ExecutionFrequency          = "1.00:00:00";
            FileName                    = "configure-dock.sh";
            RetryCount                  = 0;
            RoleScopeTagIds             = @("0");
            RunAsAccount                = "user";
            ScriptContent               = "IyEvYmluL3pzaApkZWZhdWx0cyB3cml0ZSBjb20uYXBwbGUuZG9jayBhdXRvaGlkZSAtYm9vbCB0cnVlCmtpbGxhbGwgRG9jawo=";
            ApplicationId               = $ApplicationId;
            TenantId                    = $TenantId;
            CertificateThumbprint       = $CertificateThumbprint;
        }
    }
}
