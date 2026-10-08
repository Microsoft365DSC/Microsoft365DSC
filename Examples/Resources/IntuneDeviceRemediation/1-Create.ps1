<#
This example creates a new Device Remediation.
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
        IntuneDeviceRemediation 'IntuneDeviceRemediation-Example'
        {
            Assignments              = @(
                MSFT_IntuneDeviceRemediationPolicyAssignments{
                    RunSchedule          = MSFT_IntuneDeviceRemediationRunSchedule{
                        Time     = '01:00:00'
                        Interval = 1
                        DataType = '#microsoft.graph.deviceHealthScriptDailySchedule'
                        UseUtc   = $False
                    }
                    RunRemediationScript = $False
                    Assignment           = MSFT_DeviceManagementConfigurationPolicyAssignments{
                        deviceAndAppManagementAssignmentFilterType = 'none'
                        dataType                                   = '#microsoft.graph.groupAssignmentTarget'
                        groupDisplayName                           = 'Intune Pilot Devices'
                    }
                }
            );
            Description              = 'Restarts the Print Spooler service when it is not running'
            DetectionScriptContent   = "JHNlcnZpY2UgPSBHZXQtU2VydmljZSAtTmFtZSAnU3Bvb2xlcicgLUVycm9yQWN0aW9uIFNpbGVudGx5Q29udGludWUNCmlmICgkc2VydmljZS5TdGF0dXMgLWVxICdSdW5uaW5nJykgeyBleGl0IDAgfQ0KZXhpdCAxDQo=";
            DeviceHealthScriptType   = "deviceHealthScript";
            DisplayName              = "Restart Print Spooler";
            EnforceSignatureCheck    = $False;
            Ensure                   = "Present";
            Publisher                = "Contoso IT Operations";
            RemediationScriptContent = "U3RhcnQtU2VydmljZSAtTmFtZSAnU3Bvb2xlcicNCg==";
            RoleScopeTagIds          = @("0");
            RunAs32Bit               = $True;
            RunAsAccount             = "system";
            ApplicationId            = $ApplicationId;
            TenantId                 = $TenantId;
            CertificateThumbprint    = $CertificateThumbprint;
        }
    }
}
