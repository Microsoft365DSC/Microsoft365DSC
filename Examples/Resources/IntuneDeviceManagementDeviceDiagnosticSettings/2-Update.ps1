<#
This example updates the Device Management Compliance Settings
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
        IntuneDeviceManagementDeviceDiagnosticSettings 'IntuneDeviceManagementDeviceDiagnosticSettings-Example'
        {
            IsSingleInstance           = "Yes";
            EnableLogCollection        = $true;
            EnableAutopilotDiagnostics = $true;
            M365AppDiagnosticsEnabled  = $true;
            ApplicationId              = $ApplicationId;
            TenantId                   = $TenantId;
            CertificateThumbprint      = $CertificateThumbprint;
        }
    }
}
