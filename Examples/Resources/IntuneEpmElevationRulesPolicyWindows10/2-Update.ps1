<#
This example updates a Intune Firewall Policy for Windows10.
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
        IntuneEpmElevationRulesPolicyWindows10 'IntuneEpmElevationRulesPolicyWindows10-Example'
        {
            Assignments           = @(
                MSFT_DeviceManagementConfigurationPolicyAssignments{
                    deviceAndAppManagementAssignmentFilterType = 'none'
                    dataType                                   = '#microsoft.graph.groupAssignmentTarget'
                    groupDisplayName                           = 'Intune Pilot Devices'
                }
            );
            Description           = 'Description'
            DisplayName           = "IntuneEpmElevationRulesPolicyWindows10_1";
            ElevationRuleName     = @(
                MSFT_MicrosoftGraphIntuneSettingsCatalogElevationRuleName{
                    ChildProcessBehavior                  = "allowrunelevated"
                    FilePath                              = "C:\temp"
                    FileVersion                           = "1.1.1.1"
                    CertificateType                       = "publisher"
                    FileDescription                       = "File Description"
                    Elevationtype                         = "self"
                    FileName                              = "file.exe"
                    ElevationTypeValidation               = @(
                        1
                        2
                    )
                    Name                                  = "Rule name"
                    RestrictArguments                     = "allow"
                    Description                           = "Description"
                    CertificatePayloadWithReusableSetting = "IntuneEpmCertificatePolicySetting_1"
                    AppliesTo                             = "allusers"
                    ProductName                           = "Product name"
                    InternalName                          = "Internal name"
                    SignatureSource                       = 0
                }
                MSFT_MicrosoftGraphIntuneSettingsCatalogElevationRuleName{
                    ChildProcessBehavior                  = "allowrunelevatedrulerequired"
                    CertificateType                       = "issuingauthority"
                    Elevationtype                         = "automatic"
                    FileName                              = "file.exe" # Updated Property
                    Name                                  = "Rule 2"
                    CertificatePayloadWithReusableSetting = "IntuneEpmCertificatePolicySetting_1"
                    AppliesTo                             = "allusers"
                    SignatureSource                       = 0
                }
            );
            Ensure                = "Present";
            Id                    = '00000000-0000-0000-0000-000000000000'
            RoleScopeTagIds       = @("0");
            ApplicationId         = $ApplicationId;
            TenantId              = $TenantId;
            CertificateThumbprint = $CertificateThumbprint;
        }
    }
}
