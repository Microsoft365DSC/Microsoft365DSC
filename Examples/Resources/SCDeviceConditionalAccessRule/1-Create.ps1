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
        SCDeviceConditionalAccessRule "SCDeviceConditionalAccessRule-Example"
        {
            AccountName                   = "Contoso Mail";
            AccountUserName               = "mobile.access@contoso.com";
            AllowAppStore                 = $true;
            AllowAssistantWhileLocked     = $true;
            AllowConvenienceLogon         = $true;
            AllowDiagnosticSubmission     = $true;
            AllowiCloudBackup             = $true;
            AllowiCloudDocSync            = $true;
            AllowiCloudPhotoSync          = $true;
            AllowJailbroken               = $false;
            AllowPassbookWhileLocked      = $true;
            AllowScreenshot               = $true;
            AllowSimplePassword           = $false;
            AllowVideoConferencing        = $true;
            AllowVoiceAssistant           = $true;
            AllowVoiceDialing             = $true;
            AntiVirusSignatureStatus      = 1;
            AntiVirusStatus               = 1;
            AppsRating                    = "Rating12plus";
            AutoUpdateStatus              = "AutomaticUpdatesRequired";
            BluetoothEnabled              = $true;
            CameraEnabled                 = $true;
            EmailAddress                  = "mobile.access@contoso.com";
            EnableRemovableStorage        = $true;
            Ensure                        = "Present";
            ExchangeActiveSyncHost        = "outlook.office365.com";
            FirewallStatus                = "Required";
            ForceAppStorePassword         = $false;
            ForceEncryptedBackup          = $false;
            MaxPasswordAttemptsBeforeWipe = 10;
            MaxPasswordGracePeriod        = "15.00:00:00";
            MoviesRating                  = "USRatingPG13";
            Name                          = "Human Resources{394b}";
            PasswordComplexity            = 1;
            PasswordExpirationDays        = 90;
            PasswordHistoryCount          = 5;
            PasswordMinComplexChars       = 2;
            PasswordMinimumLength         = 8;
            PasswordQuality               = 3;
            PasswordRequired              = $true;
            PasswordTimeout               = "00:15:00";
            PhoneMemoryEncrypted          = $false;
            Policy                        = "Human Resources";
            RegionRatings                 = "us";
            RequireEmailProfile           = $false;
            SmartScreenEnabled            = $false;
            SystemSecurityTLS             = $false;
            TargetGroups                  = @("Sales and Marketing");
            TVShowsRating                 = "USRatingTV14";
            UserAccountControlStatus      = "AlwaysNotify";
            WLANEnabled                   = $true;
            WorkFoldersSyncUrl            = "https://workfolders.contoso.com";
            ApplicationId                 = $ApplicationId;
            TenantId                      = $TenantId;
            CertificateThumbprint         = $CertificateThumbprint;
        }
    }
}
