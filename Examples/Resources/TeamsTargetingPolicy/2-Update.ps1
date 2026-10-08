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
        TeamsTargetingPolicy 'TeamsTargetingPolicy-Example'
        {
            CustomTagsMode                     = "Disabled";
            Description                        = "Limits tags to the preset roles used on the retail floor";
            IsSingleInstance                   = "Yes";
            ManageTagsPermissionMode           = "MicrosoftDefault";
            ShiftBackedTagsMode                = "Disabled";
            SuggestedPresetTags                = "Manager,Cashier,Pharmacist";
            TeamOwnersEditWhoCanManageTagsMode = "Enabled";
            ApplicationId                      = $ApplicationId;
            TenantId                           = $TenantId;
            CertificateThumbprint              = $CertificateThumbprint;
        }
    }
}
