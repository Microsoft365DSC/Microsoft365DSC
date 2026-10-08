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
        DefenderDeviceAuthenticatedScanDefinition "DefenderDeviceAuthenticatedScanDefinition-Example"
        {
            Ensure                   = "Present";
            IntervalInHours          = 24; # Updated Property
            IsActive                 = $True;
            Name                     = "Datacentre Network Scan";
            ScanAuthenticationParams = MSFT_DefenderDeviceAuthenticatedScanDefinitionAuthenticationParams{
                Type         = "AuthPriv"
                DataType     = "#microsoft.windowsDefenderATP.api.SnmpAuthParams"
                Username     = "svc-network-scanner"
                AuthProtocol = "SHA1"
                AuthPassword = "<snmp-auth-password>"
                PrivProtocol = "AES"
                PrivPassword = "<snmp-priv-password>"
            };
            ScannerAgent             = MSFT_DefenderDeviceAuthenticatedScanDefinitionScanAgent{
                machineId   = "<defender-machine-id>"
                machineName = "CONTOSO-SCAN01"
                id          = "<defender-scan-agent-id>"
            };
            ScanType                 = "Network";
            Target                   = "10.20.30.0/24";
            ApplicationId            = $ApplicationId;
            TenantId                 = $TenantId;
            CertificateThumbprint    = $CertificateThumbprint;
        }
    }
}
