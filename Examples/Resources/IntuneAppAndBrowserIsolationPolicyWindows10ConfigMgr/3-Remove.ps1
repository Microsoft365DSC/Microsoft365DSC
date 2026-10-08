<#
This example removes a Device Remediation.
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
        IntuneAppAndBrowserIsolationPolicyWindows10ConfigMgr 'IntuneAppAndBrowserIsolationPolicyWindows10ConfigMgr-Example'
        {
            DisplayName           = 'App and Browser Isolation (ConfigMgr)'
            Ensure                = 'Absent'
            ApplicationId         = $ApplicationId;
            TenantId              = $TenantId;
            CertificateThumbprint = $CertificateThumbprint;
        }
    }
}
