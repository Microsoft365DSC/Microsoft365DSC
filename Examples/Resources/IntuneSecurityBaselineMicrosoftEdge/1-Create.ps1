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
        IntuneSecurityBaselineMicrosoftEdge 'IntuneSecurityBaselineMicrosoftEdge-Example'
        {
            DisplayName                                             = 'Microsoft Edge Baseline'
            ApplicationBoundEncryptionEnabled                       = "1";
            Assignments                                             = @(
                MSFT_DeviceManagementConfigurationPolicyAssignments{
                    dataType                                   = "#microsoft.graph.allDevicesAssignmentTarget"
                    deviceAndAppManagementAssignmentFilterType = "none"
                }
                MSFT_DeviceManagementConfigurationPolicyAssignments{
                    dataType         = "#microsoft.graph.exclusionGroupAssignmentTarget"
                    groupDisplayName = "Intune Excluded Devices"
                }
            );
            AuthSchemes_AuthSchemes                                 = "ntlm,negotiate";
            BasicAuthOverHttpEnabled                                = "0";
            BrowserLegacyExtensionPointsBlockingEnabled             = "1";
            Description                                             = "Hardened browser settings for corporate Windows workstations";
            DynamicCodeSettings_DynamicCodeSettings                 = "1";
            edge_DynamicCodeSettings                                = "1";
            ExtensionInstallBlocklist                               = "1";
            ExtensionInstallBlocklistDesc                           = @("aapbdbdomjkkjkaonfhkkikfgjllcleb", "gighmmpiobklfepjocnamgkkbiglidom");
            InsecurePrivateNetworkRequestsAllowed                   = "0";
            InternetExplorerIntegrationReloadInIEModeAllowed        = "0";
            InternetExplorerIntegrationZoneIdentifierMhtFileAllowed = "0";
            InternetExplorerModeToolbarButtonEnabled                = "0";
            MicrosoftEdge_HTTPAuthentication_AuthSchemes            = "1";
            NativeMessagingUserLevelHosts                           = "0";
            PreventSmartScreenPromptOverride                        = "1";
            PreventSmartScreenPromptOverrideForFiles                = "1";
            RoleScopeTagIds                                         = @("0");
            SharedArrayBufferUnrestrictedAccessAllowed              = "0";
            SitePerProcess                                          = "1";
            SmartScreenEnabled                                      = "1";
            SmartScreenPuaEnabled                                   = "1";
            SSLErrorOverrideAllowed                                 = "0";
            TyposquattingCheckerEnabled                             = "1";
            Ensure                                                  = 'Present'
            ApplicationId                                           = $ApplicationId;
            TenantId                                                = $TenantId;
            CertificateThumbprint                                   = $CertificateThumbprint;
        }
    }
}
