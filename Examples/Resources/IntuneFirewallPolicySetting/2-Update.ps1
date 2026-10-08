<#
This example updates a Intune Firewall Policy Setting.
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
        IntuneFirewallPolicySetting "IntuneFirewallPolicySetting-Example"
        {
            Description           = "";
            DisplayName           = "IntuneFirewallPolicySetting_1";
            Ensure                = "Present";
            PolicySettings        = @(
                MSFT_ReusableFirewallPolicySetting{
                    Keyword     = "ReusableSetting1"
                    AutoResolve = $True # Updated Property
                }
            );
            ApplicationId         = $ApplicationId;
            TenantId              = $TenantId;
            CertificateThumbprint = $CertificateThumbprint;
        }
    }
}
