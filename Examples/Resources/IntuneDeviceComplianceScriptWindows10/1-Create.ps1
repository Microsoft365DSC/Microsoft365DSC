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
        IntuneDeviceComplianceScriptWindows10 'IntuneDeviceComplianceScriptWindows10-Example'
        {
            Description            = "Reports whether Microsoft Defender real-time protection is enabled";
            DisplayName            = "Defender Real-Time Protection Check";
            Ensure                 = "Present";
            EnforceSignatureCheck  = $False;
            RunAs32Bit             = $True;
            RunAsAccount           = "system";
            DetectionScriptContent = "`$status = Get-MpComputerStatus; @{ RealTimeProtectionEnabled = `$status.RealTimeProtectionEnabled } | ConvertTo-Json -Compress";
            Publisher              = "Contoso Endpoint Security";
            RoleScopeTagIds        = @("0");
            ApplicationId          = $ApplicationId;
            TenantId               = $TenantId;
            CertificateThumbprint  = $CertificateThumbprint;
        }
    }
}
