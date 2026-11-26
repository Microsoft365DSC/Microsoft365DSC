<#
This example demonstrates how to assign users to a Teams Upgrade Policy.
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
        TeamsUpdateManagementPolicy "TeamsUpdateManagementPolicy-Example"
        {
            AllowManagedUpdates   = $False;
            AllowPreview          = $False;
            AllowPublicPreview    = "Enabled";
            Description           = "Controls the Teams client update rollout for early adopters and pilot users"; # Updated Property
            Ensure                = "Present";
            Identity              = "EarlyAdopters";
            UpdateDayOfWeek       = 1;
            UpdateTime            = "18:00";
            UpdateTimeOfDay       = "6:00 PM";
            UseNewTeamsClient     = 'MicrosoftChoice'
            ApplicationId         = $ApplicationId;
            TenantId              = $TenantId;
            CertificateThumbprint = $CertificateThumbprint;
        }
    }
}
