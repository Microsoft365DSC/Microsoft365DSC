<#
This example updates a Intune Device Control Policy Setting.
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
        IntuneDeviceControlPolicySetting "IntuneDeviceControlPolicySetting-Example"
        {
            Description           = "";
            DisplayName           = "IntuneDeviceControlPolicySetting_1";
            Ensure                = "Present";
            MatchType             = "All";
            PrinterPolicySettings = @(
                MSFT_ReusablePrinterDeviceControlPolicySetting{
                    FriendlyNameId      = "Printer\FriendlyNameId"
                    Name                = "PrinterReusableSetting"
                    VID_PID             = "0000_1111"
                    PrinterConnectionId = 1 # Updated Property
                    PrimaryId           = 0
                }
            );
            StoragePolicySettings = @(
                MSFT_ReusableStorageDeviceControlPolicySetting{
                    VID_PID        = "1111_2222"
                    SerialNumberId = "bbbb"
                    HardwareId     = "HardwareId"
                    PrimaryId      = "RemovableMediaDevices"
                    DeviceId       = "aaa"
                    Name           = "RemovableStorageSetting"
                    VID            = "0000"
                    BusId          = "USB"
                    FriendlyNameId = "FriendlyNameId"
                    PID            = "1111"
                    InstancePathId = "USBSTOR\DISK&VEN_GENERIC&PROD_FLASH_DISK&REV_8.07\8735B611&0"
                }
            );
            ApplicationId         = $ApplicationId;
            TenantId              = $TenantId;
            CertificateThumbprint = $CertificateThumbprint;
        }
    }
}
