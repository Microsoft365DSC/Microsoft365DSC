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
        IntuneCloudProvisioningPolicyWindows365 "IntuneCloudProvisioningPolicyWindows365-Example"
        {
            Assignments              = @(
                MSFT_DeviceManagementConfigurationPolicyAssignments{
                    dataType         = "#microsoft.graph.cloudPcManagementGroupAssignmentTarget"
                    groupDisplayName = "Intune Pilot Users"
                }
            );
            CloudPcNamingTemplate    = "CPC-%USERNAME:5%-%RAND:5%";
            Description              = "Enterprise Cloud PCs for the pilot user group in Europe"; # Updated Property
            DisplayName              = "Pilot Users Cloud PC";
            DomainJoinConfigurations = @(
                MSFT_MicrosoftGraphCloudPcDomainJoinConfiguration{
                    Type                   = "azureADJoin"
                    RegionName             = "automatic"
                    DomainJoinType         = "azureADJoin"
                    RegionGroup            = "automatic"
                    GeographicLocationType = "europe"
                }
            );
            EnableSingleSignOn       = $True;
            Ensure                   = "Present";
            ImageDisplayName         = "Windows 11 Enterprise 25H2";
            ImageId                  = "microsoftwindowsdesktop_windows-ent-cpc_win11-25h2-ent-cpc";
            ImageType                = "gallery";
            ProvisioningType         = "dedicated";
            ScopeIds                 = @("0");
            WindowsSetting           = MSFT_MicrosoftGraphCloudPcWindowsSetting{
                Locale = "en-US"
            };
            WindowsSettings          = MSFT_MicrosoftGraphCloudPcWindowsSettings{
                Language = "en-US"
            };
            ApplicationId            = $ApplicationId;
            TenantId                 = $TenantId;
            CertificateThumbprint    = $CertificateThumbprint;
        }
    }
}
