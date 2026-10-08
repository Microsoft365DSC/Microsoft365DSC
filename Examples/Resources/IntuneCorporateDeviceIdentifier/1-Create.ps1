<#
This example creates corporate device identifiers in Intune.
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
        IntuneCorporateDeviceIdentifier 'IntuneCorporateDeviceIdentifier-Example'
        {
            IsSingleInstance      = 'Yes'
            Devices               = @(
                MSFT_IntuneDeviceIdentifier {
                    importedDeviceIdentifier   = 'ABC123456'
                    importedDeviceIdentityType = 'serialNumber'
                    description                = 'Corporate laptop'
                    platform                   = 'windows'
                }
                MSFT_IntuneDeviceIdentifier {
                    importedDeviceIdentifier   = '353456789012345'
                    importedDeviceIdentityType = 'imei'
                    description                = 'Corporate phone'
                    platform                   = 'android'
                }
            )
            Ensure                = 'Present'
            ApplicationId         = $ApplicationId
            TenantId              = $TenantId
            CertificateThumbprint = $CertificateThumbprint
        }
    }
}
