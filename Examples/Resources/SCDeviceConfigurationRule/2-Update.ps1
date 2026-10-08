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
        SCDeviceConfigurationRule "SCDeviceConfigurationRule-Example"
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
            AllowPassbookWhileLocked      = $true;
            AllowScreenshot               = $true;
            AllowSimplePassword           = $false;
            AllowVideoConferencing        = $true;
            AllowVoiceAssistant           = $false; # Updated Property
            AllowVoiceDialing             = $true;
            AntiVirusSignatureStatus      = 1;
            AntiVirusStatus               = 1;
            AppsRating                    = "Rating9plus";
            AutoUpdateStatus              = "AutomaticDownloadUpdates";
            BluetoothEnabled              = $true;
            CameraEnabled                 = $true;
            EmailAddress                  = "mobile.access@contoso.com";
            EnableRemovableStorage        = $true;
            Ensure                        = "Present";
            ExchangeActiveSyncHost        = "outlook.office365.com";
            FirewallStatus                = "Required";
            ForceAppStorePassword         = $false;
            ForceEncryptedBackup          = $false;
            MaxPasswordAttemptsBeforeWipe = 8;
            MaxPasswordGracePeriod        = "15.00:00:00";
            MoviesRating                  = "USRatingPG";
            Name                          = "Human Resources Device Settings{2b18}";
            PasswordComplexity            = 1;
            PasswordExpirationDays        = 60;
            PasswordHistoryCount          = 3;
            PasswordMinComplexChars       = 2;
            PasswordMinimumLength         = 6;
            PasswordQuality               = 3;
            PasswordRequired              = $true;
            PasswordTimeout               = "00:05:00";
            PhoneMemoryEncrypted          = $false;
            Policy                        = "Human Resources Device Settings";
            RegionRatings                 = "us";
            RequireEmailProfile           = $false;
            SmartScreenEnabled            = $false;
            SystemSecurityTLS             = $false;
            TargetGroups                  = @("All Company");
            TVShowsRating                 = "USRatingTVPG";
            UserAccountControlStatus      = "NotifyAppChanges";
            WLANEnabled                   = $true;
            WorkFoldersSyncUrl            = "https://workfolders.contoso.com";
            ApplicationId                 = $ApplicationId;
            TenantId                      = $TenantId;
            CertificateThumbprint         = $CertificateThumbprint;
        }
    }
}
