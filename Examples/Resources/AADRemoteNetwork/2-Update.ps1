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
        AADRemoteNetwork "AADRemoteNetwork-Example"
        {
            Ensure                = "Present";
            ForwardingProfiles    = @("Microsoft 365 traffic forwarding profile");
            Name                  = "Sydney Branch Network";
            Region                = "australiaSouthEast";
            DeviceLinks           = @(
                MSFT_AADRemoteNetworkDeviceLink {
                    Name                    = 'Sydney Secondary Link' # Updated Property
                    IPAddress               = '1.1.1.1'
                    BandwidthCapacityInMbps = 'mbps500'
                    DeviceVendor            = 'ciscoCatalyst'
                    BgpConfiguration        = MSFT_AADRemoteNetworkDeviceLinkbgpConfiguration {
                        Asn            = 82
                        LocalIPAddress = '1.1.1.87'
                        PeerIPAddress  = '1.1.1.2'
                    }
                    RedundancyConfiguration = MSFT_AADRemoteNetworkDeviceLinkRedundancyConfiguration {
                        RedundancyTier     = 'zoneRedundancy'
                        ZoneLocalIPAddress = '1.1.1.8'
                    }
                    TunnelConfiguration     = MSFT_AADRemoteNetworkDeviceLinkTunnelConfiguration {
                        PreSharedKey               = '<vpn-pre-shared-key>'
                        ZoneRedundancyPreSharedKey = '<vpn-zone-redundancy-pre-shared-key>'
                        SaLifeTimeSeconds          = 300
                        IPSecEncryption            = 'gcmAes192'
                        IPSecIntegrity             = 'gcmAes192'
                        IKEEncryption              = 'aes192'
                        IKEIntegrity               = 'gcmAes128'
                        DHGroup                    = 'ecp256'
                        PFSGroup                   = 'pfsmm'
                        ODataType                  = '#microsoft.graph.networkaccess.tunnelConfigurationIKEv2Custom'
                    }
                }
            );
            ApplicationId         = $ApplicationId
            TenantId              = $TenantId
            CertificateThumbprint = $CertificateThumbprint
        }
    }
}
