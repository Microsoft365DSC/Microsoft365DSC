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
        IntuneDeviceComplianceScriptLinux 'IntuneDeviceComplianceScriptLinux-Example'
        {
            Description           = "Reports whether SSH root login is disabled on Linux servers and workstations"; # Updated Property
            DisplayName           = "Linux SSH Root Login Check";
            Ensure                = "Present";
            DiscoveryScript       = "#!/bin/bash
if grep -q '^PermitRootLogin no' /etc/ssh/sshd_config; then
    echo '{`"SshRootLoginDisabled`":`"true`"}'
else
    echo '{`"SshRootLoginDisabled`":`"false`"}'
fi";
            ApplicationId         = $ApplicationId;
            TenantId              = $TenantId;
            CertificateThumbprint = $CertificateThumbprint;
        }
    }
}
