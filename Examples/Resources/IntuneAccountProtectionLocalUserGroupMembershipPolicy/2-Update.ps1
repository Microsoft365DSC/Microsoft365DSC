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
        IntuneAccountProtectionLocalUserGroupMembershipPolicy "IntuneAccountProtectionLocalUserGroupMembershipPolicy-Example"
        {
            DisplayName           = "Account Protection LUGM Policy";
            Description           = "Grants the helpdesk local administrator rights on corporate workstations and removes field technicians from remote desktop access"; # Updated Property
            Ensure                = "Present";
            RoleScopeTagIds       = @("0");
            Assignments           = @(
                MSFT_IntuneAccountProtectionLocalUserGroupMembershipPolicyAssignments{
                    dataType                                   = "#microsoft.graph.allDevicesAssignmentTarget"
                    deviceAndAppManagementAssignmentFilterType = "none"
                }
                MSFT_IntuneAccountProtectionLocalUserGroupMembershipPolicyAssignments{
                    dataType         = "#microsoft.graph.exclusionGroupAssignmentTarget"
                    groupDisplayName = "Intune Excluded Devices"
                }
            );
            AccessGroup           = @(
                MSFT_MicrosoftGraphIntuneSettingsCatalogAccessGroup{
                    action            = "AddUpdate"
                    desc              = @("administrators")
                    member            = @("S-1-12-1-1167842105-1150511762-402702254-1917434032")
                    userselectiontype = "users"
                }
                MSFT_MicrosoftGraphIntuneSettingsCatalogAccessGroup{
                    action            = "RemoveUpdate"
                    desc              = @("remotedesktopusers")
                    member            = @("AzureAD\field.technician@contoso.com")
                    userselectiontype = "manual"
                }
            );
            ApplicationId         = $ApplicationId;
            TenantId              = $TenantId;
            CertificateThumbprint = $CertificateThumbprint;
        }
    }
}
