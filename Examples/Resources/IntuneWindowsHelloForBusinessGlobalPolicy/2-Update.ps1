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
        IntuneWindowsHelloForBusinessGlobalPolicy 'IntuneWindowsHelloForBusinessGlobalPolicy-Example'
        {
            EnhancedBiometricsState     = "notConfigured";
            EnhancedSignInSecurity      = 0;
            IsSingleInstance            = "Yes";
            PinExpirationInDays         = 0;
            PinLowercaseCharactersUsage = "disallowed";
            PinMaximumLength            = 127;
            PinMinimumLength            = 6;
            PinPreviousBlockCount       = 0;
            PinSpecialCharactersUsage   = "disallowed";
            PinUppercaseCharactersUsage = "disallowed";
            RemotePassportEnabled       = $True;
            SecurityDeviceRequired      = $False;
            SecurityKeyForSignIn        = "notConfigured";
            State                       = "notConfigured";
            UnlockWithBiometricsEnabled = $True;
            ApplicationId               = $ApplicationId;
            TenantId                    = $TenantId;
            CertificateThumbprint       = $CertificateThumbprint;
        }
    }
}
