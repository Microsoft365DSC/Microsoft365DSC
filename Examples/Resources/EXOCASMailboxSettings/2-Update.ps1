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
        EXOCASMailboxSettings 'EXOCASMailboxSettings-Example'
        {
            ActiveSyncAllowedDeviceIDs              = @()
            ActiveSyncBlockedDeviceIDs              = @()
            ActiveSyncDebugLogging                  = $False
            ActiveSyncEnabled                       = $True
            ActiveSyncMailboxPolicy                 = 'Default'
            ActiveSyncSuppressReadReceipt           = $False
            EwsEnabled                              = $True
            Identity                                = "MeganB@$TenantId"
            ImapEnabled                             = $True # Updated Property
            ImapForceICalForCalendarRetrievalOption = $False
            ImapMessagesRetrievalMimeFormat         = 'BestBodyFormat'
            ImapSuppressReadReceipt                 = $False
            ImapUseProtocolDefaults                 = $True
            MacOutlookEnabled                       = $True
            MAPIEnabled                             = $True
            OutlookMobileEnabled                    = $True
            OWAEnabled                              = $True
            OWAforDevicesEnabled                    = $True
            OwaMailboxPolicy                        = 'OwaMailboxPolicy-Restricted'
            PopEnabled                              = $False
            PopForceICalForCalendarRetrievalOption  = $True
            PopMessagesRetrievalMimeFormat          = 'BestBodyFormat'
            PopSuppressReadReceipt                  = $False
            PopUseProtocolDefaults                  = $True
            PublicFolderClientAccess                = $False
            ShowGalAsDefaultView                    = $True
            UniversalOutlookEnabled                 = $True
            Ensure                                  = 'Present'
            ApplicationId                           = $ApplicationId
            TenantId                                = $TenantId
            CertificateThumbprint                   = $CertificateThumbprint
        }
    }
}
