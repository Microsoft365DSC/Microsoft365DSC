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
        SCInsiderRiskPolicy "SCInsiderRiskPolicy-Example"
        {
            Name                                          = "Customer Data Leak Detection";
            InsiderRiskScenario                           = "LeakOfInformation";
            HistoricTimeSpan                              = "90";
            InScopeTimeSpan                               = "30";
            AIAppRiskyPrompt                              = $false;
            AnomalyDetections                             = $false;
            AWSS3BlockPublicAccessDisabled                = $false;
            AWSS3BucketDeleted                            = $false;
            AWSS3PublicAccessEnabled                      = $false;
            AWSS3ServerLoggingDisabled                    = $false;
            AzureElevateAccessToAllSubscriptions          = $false;
            AzureResourceThreatProtectionSettingsUpdated  = $false;
            AzureSQLServerAuditingSettingsUpdated         = $false;
            AzureSQLServerFirewallRuleDeleted             = $false;
            AzureSQLServerFirewallRuleUpdated             = $false;
            AzureStorageAccountOrContainerDeleted         = $false;
            BoxContentAccess                              = $false;
            BoxContentDelete                              = $false;
            BoxContentDownload                            = $false;
            BoxContentExternallyShared                    = $false;
            CCFinancialRegulatoryRiskyTextSent            = $false;
            CCInappropriateContentSent                    = $false;
            CCInappropriateImagesSent                     = $false;
            CCPromptShields                               = $false;
            CCProtectedMaterialDetection                  = $false;
            CCSensitiveInformationType                    = $true;
            CCSupervisionRuleMatch                        = $false;
            CompromisedSignInAlerts                       = $false;
            CompromisedUserAlerts                         = $false;
            ConnectedAIAppRiskyPrompt                     = $false;
            ConnectedAIAppSensitiveResponse               = $false;
            CopilotRiskyPrompt                            = $false;
            CopilotSensitiveResponse                      = $true;
            CopyToPersonalCloud                           = $true;
            CopyToUSB                                     = $true;
            CumulativeExfiltrationDetector                = $true;
            DropboxContentAccess                          = $false;
            DropboxContentDelete                          = $false;
            DropboxContentDownload                        = $false;
            DropboxContentExternallyShared                = $false;
            EmailExternal                                 = $true;
            EmployeeAccessedEmployeePatientData           = $false;
            EmployeeAccessedFamilyData                    = $false;
            EmployeeAccessedHighVolumePatientData         = $false;
            EmployeeAccessedNeighbourData                 = $false;
            EmployeeAccessedRestrictedData                = $false;
            EpoBrowseToChildAbuseSites                    = $false;
            EpoBrowseToCriminalActivitySites              = $false;
            EpoBrowseToCultSites                          = $false;
            EpoBrowseToGamblingSites                      = $false;
            EpoBrowseToHackingSites                       = $false;
            EpoBrowseToHateIntoleranceSites               = $false;
            EpoBrowseToIllegalSoftwareSites               = $false;
            EpoBrowseToKeyloggerSites                     = $false;
            EpoBrowseToLlmSites                           = $false;
            EpoBrowseToMalwareSites                       = $false;
            EpoBrowseToPhishingSites                      = $false;
            EpoBrowseToPornographySites                   = $false;
            EpoBrowseToUnallowedDomain                    = $false;
            EpoBrowseToViolenceSites                      = $false;
            EpoCopyToClipboardFromSensitiveFile           = $false;
            EpoCopyToNetworkShare                         = $true;
            EpoFileArchived                               = $false;
            EpoFileCopiedToRemoteDesktopSession           = $true;
            EpoFileDeleted                                = $false;
            EpoFileDownloadedFromBlacklistedDomain        = $false;
            EpoFileDownloadedFromEnterpriseDomain         = $false;
            EpoFileRenamed                                = $false;
            EpoFileStagedToCentralLocation                = $false;
            EpoHiddenFileCreated                          = $false;
            EpoRemovableMediaMount                        = $false;
            EpoSensitiveFileRead                          = $false;
            FabricExternalDataSharingSwitchEnabled        = $false;
            GoogleDriveContentAccess                      = $false;
            GoogleDriveContentDelete                      = $false;
            GoogleDriveContentExternallyShared            = $false;
            HighSeverityDlpRuleMatch                      = $true;
            LakehouseArtifactDeleted                      = $false;
            LakehouseExternalDataShareCreated             = $false;
            LakehouseFileOrBlobDeleted                    = $false;
            LakehouseSensitivityLabelDowngraded           = $false;
            LakehouseSensitivityLabelRemoved              = $false;
            Mcas3rdPartyAppDownload                       = $false;
            Mcas3rdPartyAppFileDelete                     = $false;
            Mcas3rdPartyAppFileSharing                    = $false;
            McasActivityFromInfrequentCountry             = $false;
            McasImpossibleTravel                          = $false;
            McasMultipleFailedLogins                      = $false;
            McasMultipleStorageDeletion                   = $false;
            McasMultipleVMCreation                        = $false;
            McasMultipleVMDeletion                        = $false;
            McasSuspiciousAdminActivities                 = $false;
            McasSuspiciousCloudCreation                   = $false;
            McasSuspiciousCloudTrailLoggingChange         = $false;
            McasTerminatedEmployeeActivity                = $false;
            NetworkDownloadFile                           = $false;
            NetworkDownloadText                           = $false;
            NetworkUploadFile                             = $false;
            NetworkUploadText                             = $false;
            OdbDownload                                   = $true;
            OdbSyncDownload                               = $true;
            PeerCumulativeExfiltrationDetector            = $false;
            PhysicalAccess                                = $false;
            PotentialHighImpactUser                       = $false;
            PowerBIDashboardsDeleted                      = $false;
            PowerBIReportsDeleted                         = $false;
            PowerBIReportsDownloaded                      = $false;
            PowerBIReportsExported                        = $false;
            PowerBIReportsViewed                          = $false;
            PowerBISemanticModelsDeleted                  = $false;
            PowerBISensitivityLabelDowngradedForArtifacts = $false;
            PowerBISensitivityLabelRemovedFromArtifacts   = $false;
            Print                                         = $true;
            PriorityUserGroupMember                       = $false;
            SecurityAlertDefenseEvasion                   = $false;
            SecurityAlertUnwantedSoftware                 = $false;
            SpoAccessRequest                              = $false;
            SpoApprovedAccess                             = $false;
            SpoDownload                                   = $true;
            SpoDownloadV2                                 = $true;
            SpoFileAccessed                               = $false;
            SpoFileDeleted                                = $false;
            SpoFileDeletedFromFirstStageRecycleBin        = $false;
            SpoFileDeletedFromSecondStageRecycleBin       = $false;
            SpoFileLabelDowngraded                        = $true;
            SpoFileLabelRemoved                           = $true;
            SpoFileSharing                                = $true;
            SpoFolderDeleted                              = $false;
            SpoFolderDeletedFromFirstStageRecycleBin      = $false;
            SpoFolderDeletedFromSecondStageRecycleBin     = $false;
            SpoFolderSharing                              = $true;
            SpoSiteExternalUserAdded                      = $false;
            SpoSiteInternalUserAdded                      = $false;
            SpoSiteLabelRemoved                           = $false;
            SpoSiteSharing                                = $true;
            SpoSyncDownload                               = $true;
            TeamsChannelFileSharedExternal                = $true;
            TeamsChannelMemberAddedExternal               = $false;
            TeamsChatFileSharedExternal                   = $true;
            TeamsFileDownload                             = $true;
            TeamsFolderSharedExternal                     = $true;
            TeamsMemberAddedExternal                      = $false;
            TeamsSensitiveMessage                         = $false;
            UserHistory                                   = $false;
            Ensure                                        = "Present";
            ApplicationId                                 = $ApplicationId;
            TenantId                                      = $TenantId;
            CertificateThumbprint                         = $CertificateThumbprint;
        }
    }
}
