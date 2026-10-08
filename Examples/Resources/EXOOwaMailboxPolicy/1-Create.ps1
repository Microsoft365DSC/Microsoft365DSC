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
        EXOOwaMailboxPolicy 'EXOOwaMailboxPolicy-Example'
        {
            Name                                                 = "OwaMailboxPolicy-Restricted"
            ActionForUnknownFileAndMIMETypes                     = "ForceSave"
            ActiveSyncIntegrationEnabled                         = $True
            AdditionalStorageProvidersAvailable                  = $True
            AllAddressListsEnabled                               = $True
            AllowCopyContactsToDeviceAddressBook                 = $True
            AllowedFileTypes                                     = @(".rpmsg",".xlsx",".xlsm",".xlsb",".tiff",".pptx",".pptm",".ppsx",".ppsm",".docx",".docm",".zip",".xls",".wmv",".wma",".wav",".vsd",".txt",".tif",".rtf",".pub",".ppt",".png",".pdf",".one",".mp3",".jpg",".gif",".doc",".bmp",".avi")
            AllowedMimeTypes                                     = @("image/jpeg","image/png","image/gif","image/bmp")
            BlockedFileTypes                                     = @(".settingcontent-ms",".printerexport",".appcontent-ms",".appref-ms",".vsmacros",".website",".msh2xml",".msh1xml",".diagcab",".webpnp",".ps2xml",".ps1xml",".mshxml",".gadget",".theme",".psdm1",".mhtml",".cdxml",".xbap",".vhdx",".pyzw",".pssc",".psd1",".psc2",".psc1",".msh2",".msh1",".jnlp",".aspx",".appx",".xnk",".xml",".xll",".wsh",".wsf",".wsc",".wsb",".vsw",".vst",".vss",".vhd",".vbs",".vbp",".vbe",".url",".udl",".tmp",".shs",".shb",".sct",".scr",".scf",".reg",".pyz",".pyw",".pyo",".pyc",".pst",".ps2",".ps1",".prg",".prf",".plg",".pif",".pcd",".ops",".msu",".mst",".msp",".msi",".msh",".msc",".mht",".mdz",".mdw",".mdt",".mde",".mdb",".mda",".mcf",".maw",".mav",".mau",".mat",".mas",".mar",".maq",".mam",".mag",".maf",".mad",".lnk",".ksh",".jse",".jar",".its",".isp",".ins",".inf",".htc",".hta",".hpj",".hlp",".grp",".fxp",".exe",".der",".csh",".crt",".cpl",".com",".cnt",".cmd",".chm",".cer",".bat",".bas",".asx",".asp",".app",".apk",".adp",".ade",".ws",".vb",".py",".pl",".js")
            BlockedMimeTypes                                     = @("application/x-javascript","application/javascript","application/msaccess","x-internet-signup","text/javascript","application/xml","application/prg","application/hta","text/scriplet","text/xml")
            ClassicAttachmentsEnabled                            = $True
            ConditionalAccessPolicy                              = "Off"
            DefaultTheme                                         = ""
            DirectFileAccessOnPrivateComputersEnabled            = $True
            DirectFileAccessOnPublicComputersEnabled             = $True
            DisplayPhotosEnabled                                 = $True
            ExplicitLogonEnabled                                 = $True
            ExternalImageProxyEnabled                            = $True
            ForceSaveAttachmentFilteringEnabled                  = $False
            ForceSaveFileTypes                                   = @(".vsmacros",".ps2xml",".ps1xml",".mshxml",".gadget",".psc2",".psc1",".aspx",".wsh",".wsf",".wsc",".vsw",".vst",".vss",".vbs",".vbe",".url",".tmp",".swf",".spl",".shs",".shb",".sct",".scr",".scf",".reg",".pst",".ps2",".ps1",".prg",".prf",".plg",".pif",".pcd",".ops",".mst",".msp",".msi",".msh",".msc",".mdz",".mdw",".mdt",".mde",".mdb",".mda",".maw",".mav",".mau",".mat",".mas",".mar",".maq",".mam",".mag",".maf",".mad",".lnk",".ksh",".jse",".its",".isp",".ins",".inf",".hta",".hlp",".fxp",".exe",".dir",".dcr",".csh",".crt",".cpl",".com",".cmd",".chm",".cer",".bat",".bas",".asx",".asp",".app",".adp",".ade",".ws",".vb",".js")
            ForceSaveMimeTypes                                   = @("Application/x-shockwave-flash","Application/octet-stream","Application/futuresplash","Application/x-director")
            ForceWacViewingFirstOnPrivateComputers               = $False
            ForceWacViewingFirstOnPublicComputers                = $False
            FreCardsEnabled                                      = $True
            GlobalAddressListEnabled                             = $True
            GroupCreationEnabled                                 = $True
            InstantMessagingEnabled                              = $True
            InstantMessagingType                                 = "Ocs"
            InterestingCalendarsEnabled                          = $True
            IRMEnabled                                           = $True
            IsDefault                                            = $False
            JournalEnabled                                       = $True
            LocalEventsEnabled                                   = $False
            LogonAndErrorLanguage                                = 0
            NotesEnabled                                         = $True
            NpsSurveysEnabled                                    = $True
            OnSendAddinsEnabled                                  = $False
            OrganizationEnabled                                  = $True
            OutboundCharset                                      = "AutoDetect"
            OutlookBetaToggleEnabled                             = $True
            OWALightEnabled                                      = $True
            PersonalAccountCalendarsEnabled                      = $True
            PhoneticSupportEnabled                               = $False
            PlacesEnabled                                        = $True
            PremiumClientEnabled                                 = $True
            PrintWithoutDownloadEnabled                          = $True
            PublicFoldersEnabled                                 = $True
            RecoverDeletedItemsEnabled                           = $True
            ReferenceAttachmentsEnabled                          = $True
            RemindersAndNotificationsEnabled                     = $True
            ReportJunkEmailEnabled                               = $True
            RulesEnabled                                         = $True
            SatisfactionEnabled                                  = $True
            SaveAttachmentsToCloudEnabled                        = $True
            SearchFoldersEnabled                                 = $True
            SetPhotoEnabled                                      = $True
            SetPhotoURL                                          = ""
            SignaturesEnabled                                    = $True
            SkipCreateUnifiedGroupCustomSharepointClassification = $True
            TeamSnapCalendarsEnabled                             = $True
            TextMessagingEnabled                                 = $True
            ThemeSelectionEnabled                                = $True
            UMIntegrationEnabled                                 = $True
            UseGB18030                                           = $False
            UseISO885915                                         = $False
            UserVoiceEnabled                                     = $True
            WacEditingEnabled                                    = $True
            WacExternalServicesEnabled                           = $True
            WacOMEXEnabled                                       = $False
            WacViewingOnPrivateComputersEnabled                  = $True
            WacViewingOnPublicComputersEnabled                   = $True
            WeatherEnabled                                       = $True
            WebPartsFrameOptionsType                             = "SameOrigin"
            Ensure                                               = "Present"
            ApplicationId                                        = $ApplicationId
            TenantId                                             = $TenantId
            CertificateThumbprint                                = $CertificateThumbprint
        }
    }
}
