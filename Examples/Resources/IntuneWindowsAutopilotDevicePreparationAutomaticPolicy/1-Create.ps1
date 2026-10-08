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
        IntuneWindowsAutopilotDevicePreparationAutomaticPolicy 'IntuneWindowsAutopilotDevicePreparationAutomaticPolicy-Example'
        {
            AllowedApplications   = @("IntuneMobileAppsWindowsOfficeSuiteApp_1","IntuneMobileAppsMicrosoftEdge_Windows");
            AllowedScripts        = @("IntuneDeviceConfigurationPlatformScriptWindows_1");
            AssignmentTarget      = "Intune Pilot Devices";
            Description           = "Installs core apps and scripts while corporate Windows devices are provisioned automatically";
            DisplayName           = "Windows Automatic Device Preparation";
            Ensure                = "Present";
            RoleScopeTagIds       = @("0");
            ApplicationId         = $ApplicationId;
            TenantId              = $TenantId;
            CertificateThumbprint = $CertificateThumbprint;
        }
    }
}
