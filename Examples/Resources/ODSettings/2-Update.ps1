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
        ODSettings 'ODSettings-Example'
        {
            IsSingleInstance                          = "Yes"
            OneDriveStorageQuota                      = "1024"
            ExcludedFileExtensions                    = @("pst")
            DomainGuids                               = "786548dd-877b-4760-a749-6b1efbc1190a"
            GrooveBlockOption                         = "OptOut"
            DisableReportProblemDialog                = $true
            BlockMacSync                              = $true
            OrphanedPersonalSitesRetentionPeriod      = "45"
            OneDriveForGuestsEnabled                  = $false
            ODBAccessRequests                         = "On"
            ODBMembersCanShare                        = "On"
            NotificationsInOneDriveForBusinessEnabled = $false
            ApplicationId                             = $ApplicationId
            TenantId                                  = $TenantId
            CertificateThumbprint                     = $CertificateThumbprint
        }
    }
}
