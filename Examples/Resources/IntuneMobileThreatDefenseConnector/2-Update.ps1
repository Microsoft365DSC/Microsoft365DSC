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
        IntuneMobileThreatDefenseConnector "IntuneMobileThreatDefenseConnector-Example"
        {
            AllowPartnerToCollectIOSApplicationMetadata         = $False;
            AllowPartnerToCollectIosCertificateMetadata         = $False;
            AllowPartnerToCollectIosPersonalApplicationMetadata = $False;
            AllowPartnerToCollectIosPersonalCertificateMetadata = $False;
            AndroidDeviceBlockedOnMissingPartnerData            = $False;
            AndroidEnabled                                      = $False;
            AndroidMobileApplicationManagementEnabled           = $False;
            DisplayName                                         = "Microsoft Defender for Endpoint";
            GrantMobileThreatDefensePartnerRole                 = $false;
            Id                                                  = "fc780465-2017-40d4-a0c5-307022471b92";
            IosDeviceBlockedOnMissingPartnerData                = $False;
            IosEnabled                                          = $False;
            IosMobileApplicationManagementEnabled               = $False;
            LastHeartbeatDateTime                               = "1/1/0001 12:00:00 AM";
            LaunchMobileThreatDefensePartnerOnSetupEnabled      = $false;
            MacDeviceBlockedOnMissingPartnerData                = $False;
            MacEnabled                                          = $False;
            MicrosoftDefenderForEndpointAttachEnabled           = $True;
            PartnerState                                        = "notSetUp";
            PartnerUnresponsivenessThresholdInDays              = 7;
            PartnerUnsupportedOsVersionBlocked                  = $False;
            WindowsDeviceBlockedOnMissingPartnerData            = $False;
            WindowsEnabled                                      = $False;
            WindowsMobileApplicationManagementEnabled           = $False;
            Ensure                                              = "Present";
            ApplicationId                                       = $ApplicationId;
            TenantId                                            = $TenantId;
            CertificateThumbprint                               = $CertificateThumbprint;
        }
    }
}
