<#
This example creates a new Intune Firewall Policy Setting.
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
                    AutoResolve = $False
                    Addresses   = @(
                        "192.168.10.0/24"
                        "0.0.0.0/32"
                        "::1/64"
                    )
                }
            );
            ApplicationId         = $ApplicationId;
            TenantId              = $TenantId;
            CertificateThumbprint = $CertificateThumbprint;
        }
    }
}
