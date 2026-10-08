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
        IntuneWindowsAutopilotDeploymentProfileAzureADHybridJoined 'IntuneWindowsAutopilotDeploymentProfileAzureADHybridJoined-Example'
        {
            Assignments                            = @();
            Description                            = "";
            DeviceNameTemplate                     = "";
            DeviceType                             = "windowsPc";
            DisplayName                            = "hybrid";
            PreprovisioningAllowed                 = $False; # Updated Property
            Ensure                                 = "Present";
            HardwareHashExtractionEnabled          = $False;
            HybridAzureADJoinSkipConnectivityCheck = $True;
            Locale                                 = "os-default";
            OutOfBoxExperienceSetting              = MSFT_MicrosoftGraphoutOfBoxExperienceSetting{
                DeviceUsageType              = 'singleUser'
                EscapeLinkHidden             = $True
                EulaHidden                   = $True
                KeyboardSelectionPageSkipped = $False
                PrivacySettingsHidden        = $True
                UserType                     = 'standard'
            };
            ApplicationId                          = $ApplicationId;
            TenantId                               = $TenantId;
            CertificateThumbprint                  = $CertificateThumbprint;
        }
    }
}
