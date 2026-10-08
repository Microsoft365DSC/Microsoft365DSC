<#
This example removes a Intune Firewall Rules Policy for Windows10 Configuration Manager.
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
        IntuneFirewallRulesPolicyWindows10ConfigMgr 'IntuneFirewallRulesPolicyWindows10ConfigMgr-Example'
        {
            DisplayName           = 'Intune Firewall Rules Policy Windows10 ConfigMgr'
            Ensure                = 'Absent'
            ApplicationId         = $ApplicationId;
            TenantId              = $TenantId;
            CertificateThumbprint = $CertificateThumbprint;
        }
    }
}
