using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class FabricAdminTenantSettings : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('Specifies the resource is a single instance, the value must be ''Yes''.')]
    [ValidateSet('Yes')]
    [System.String] $IsSingleInstance

    [DscProperty()]
    [System.ComponentModel.Description('Microsoft Entra single sign-on for data gateway')]
    [MSFT_FabricTenantSetting] $AADSSOForGateway

    [DscProperty()]
    [System.ComponentModel.Description('Enhance admin APIs responses with detailed metadata')]
    [MSFT_FabricTenantSetting] $AdminApisIncludeDetailedMetadata

    [DscProperty()]
    [System.ComponentModel.Description('Enhance admin APIs responses with DAX and mashup expressions')]
    [MSFT_FabricTenantSetting] $AdminApisIncludeExpressions

    [DscProperty()]
    [System.ComponentModel.Description('Show a custom message before publishing reports')]
    [MSFT_FabricTenantSetting] $AdminCustomDisclaimer

    [DscProperty()]
    [System.ComponentModel.Description('Users can create and share AI skill item types (preview)')]
    [MSFT_FabricTenantSetting] $AISkillArtifactTenantSwitch

    [DscProperty()]
    [System.ComponentModel.Description('Azure Private Link')]
    [MSFT_FabricTenantSetting] $AllowAccessOverPrivateLinks

    [DscProperty()]
    [System.ComponentModel.Description('AppSource Custom Visuals SSO')]
    [MSFT_FabricTenantSetting] $AllowCVAuthenticationTenant

    [DscProperty()]
    [System.ComponentModel.Description('Allow access to the browser''s local storage')]
    [MSFT_FabricTenantSetting] $AllowCVLocalStorageV2Tenant

    [DscProperty()]
    [System.ComponentModel.Description('Allow downloads from custom visuals')]
    [MSFT_FabricTenantSetting] $AllowCVToExportDataToFileTenant

    [DscProperty()]
    [System.ComponentModel.Description('Endorse master data (preview)')]
    [MSFT_FabricTenantSetting] $AllowEndorsementMasterDataSwitch

    [DscProperty()]
    [System.ComponentModel.Description('Users can accept external data shares (preview)')]
    [MSFT_FabricTenantSetting] $AllowExternalDataSharingReceiverSwitch

    [DscProperty()]
    [System.ComponentModel.Description('External data sharing (preview)')]
    [MSFT_FabricTenantSetting] $AllowExternalDataSharingSwitch

    [DscProperty()]
    [System.ComponentModel.Description('Use short-lived user-delegated SAS tokens (preview).')]
    [MSFT_FabricTenantSetting] $AllowGetOneLakeUDK

    [DscProperty()]
    [System.ComponentModel.Description('Users can try Microsoft Fabric paid features')]
    [MSFT_FabricTenantSetting] $AllowFreeTrial

    [DscProperty()]
    [System.ComponentModel.Description('Users can see guest users in lists of suggested people')]
    [MSFT_FabricTenantSetting] $AllowGuestLookup

    [DscProperty()]
    [System.ComponentModel.Description('Guest users can access Microsoft Fabric')]
    [MSFT_FabricTenantSetting] $AllowGuestUserToAccessSharedContent

    [DscProperty()]
    [System.ComponentModel.Description('DEPRECATED')]
    [MSFT_FabricTenantSetting] $AllowMountDfCreation

    [DscProperty()]
    [System.ComponentModel.Description('Authenticate with OneLake user-delegated SAS tokens (preview).')]
    [MSFT_FabricTenantSetting] $AllowOneLakeUDK

    [DscProperty()]
    [System.ComponentModel.Description('Allow DirectQuery connections to Power BI semantic models')]
    [MSFT_FabricTenantSetting] $AllowPowerBIASDQOnTenant

    [DscProperty()]
    [System.ComponentModel.Description('Data sent to Azure OpenAI can be processed outside your capacity''s geographic region, compliance boundary, or national cloud instance')]
    [MSFT_FabricTenantSetting] $AllowSendAOAIDataToOtherRegions

    [DscProperty()]
    [System.ComponentModel.Description('Allow user data to leave their geography')]
    [MSFT_FabricTenantSetting] $AllowSendNLToDaxDataToOtherRegions

    [DscProperty()]
    [System.ComponentModel.Description('Allow service principals to create and use profiles')]
    [MSFT_FabricTenantSetting] $AllowServicePrincipalsCreateAndUseProfiles

    [DscProperty()]
    [System.ComponentModel.Description('Service principals can access read-only admin APIs')]
    [MSFT_FabricTenantSetting] $AllowServicePrincipalsUseReadAdminAPIs

    [DscProperty()]
    [System.ComponentModel.Description('Push apps to end users')]
    [MSFT_FabricTenantSetting] $AppPush

    [DscProperty()]
    [System.ComponentModel.Description('Users can discover and create org apps (preview).')]
    [MSFT_FabricTenantSetting] $ArtifactOrgAppPreview

    [DscProperty()]
    [System.ComponentModel.Description('Use global search for Power BI')]
    [MSFT_FabricTenantSetting] $ArtifactSearchTenant

    [DscProperty()]
    [System.ComponentModel.Description('Microsoft can store query text to aid in support investigations')]
    [MSFT_FabricTenantSetting] $ASCollectQueryTextTelemetryTenantSwitch

    [DscProperty()]
    [System.ComponentModel.Description('Enable granular access control for all data connections')]
    [MSFT_FabricTenantSetting] $ASShareableCloudConnectionBindingSecurityModeTenant

    [DscProperty()]
    [System.ComponentModel.Description('Semantic models can export data to OneLake (preview)')]
    [MSFT_FabricTenantSetting] $ASWritethruContinuousExportTenantSwitch

    [DscProperty()]
    [System.ComponentModel.Description('Users can store semantic model tables in OneLake (preview)')]
    [MSFT_FabricTenantSetting] $ASWritethruTenantSwitch

    [DscProperty()]
    [System.ComponentModel.Description('Install Power BI app for Microsoft Teams automatically')]
    [MSFT_FabricTenantSetting] $AutoInstallPowerBIAppInTeamsTenant

    [DscProperty()]
    [System.ComponentModel.Description('Show entry points for insights (preview)')]
    [MSFT_FabricTenantSetting] $AutomatedInsightsEntryPoints

    [DscProperty()]
    [System.ComponentModel.Description('Receive notifications for top insights (preview)')]
    [MSFT_FabricTenantSetting] $AutomatedInsightsTenant

    [DscProperty()]
    [System.ComponentModel.Description('DEPRECATED')]
    [MSFT_FabricTenantSetting] $AzureMap

    [DscProperty()]
    [System.ComponentModel.Description('Map and filled map visuals')]
    [MSFT_FabricTenantSetting] $BingMap

    [DscProperty()]
    [System.ComponentModel.Description('Block Public Internet Access')]
    [MSFT_FabricTenantSetting] $BlockAccessFromPublicNetworks

    [DscProperty()]
    [System.ComponentModel.Description('Block republish and disable package refresh')]
    [MSFT_FabricTenantSetting] $BlockAutoDiscoverAndPackageRefresh

    [DscProperty()]
    [System.ComponentModel.Description('Restrict content with protected labels from being shared via link with everyone in your organization')]
    [MSFT_FabricTenantSetting] $BlockProtectedLabelSharingToEntireOrg

    [DscProperty()]
    [System.ComponentModel.Description('Block ResourceKey Authentication')]
    [MSFT_FabricTenantSetting] $BlockResourceKeyAuthentication

    [DscProperty()]
    [System.ComponentModel.Description('Create and use Gen1 dataflows')]
    [MSFT_FabricTenantSetting] $CDSAManagement

    [DscProperty()]
    [System.ComponentModel.Description('Add and use certified visuals only (block uncertified)')]
    [MSFT_FabricTenantSetting] $CertifiedCustomVisualsTenant

    [DscProperty()]
    [System.ComponentModel.Description('Certification')]
    [MSFT_FabricTenantSetting] $CertifyDatasets

    [DscProperty()]
    [System.ComponentModel.Description('Define workspace retention period')]
    [MSFT_FabricTenantSetting] $ConfigureFolderRetentionPeriod

    [DscProperty()]
    [System.ComponentModel.Description('Create workspaces')]
    [MSFT_FabricTenantSetting] $CreateAppWorkspaces

    [DscProperty()]
    [System.ComponentModel.Description('Allow visuals created using the Power BI SDK')]
    [MSFT_FabricTenantSetting] $CustomVisualsTenant

    [DscProperty()]
    [System.ComponentModel.Description('Create Datamarts (preview)')]
    [MSFT_FabricTenantSetting] $DatamartTenant

    [DscProperty()]
    [System.ComponentModel.Description('Semantic Model Execute Queries REST API')]
    [MSFT_FabricTenantSetting] $DatasetExecuteQueries

    [DscProperty()]
    [System.ComponentModel.Description('Publish template apps')]
    [MSFT_FabricTenantSetting] $DevelopServiceApps

    [DscProperty()]
    [System.ComponentModel.Description('Discover content')]
    [MSFT_FabricTenantSetting] $DiscoverDatasetsConsumption

    [DscProperty()]
    [System.ComponentModel.Description('Make certified content discoverable ')]
    [MSFT_FabricTenantSetting] $DiscoverDatasetsSettingsCertified

    [DscProperty()]
    [System.ComponentModel.Description('Make promoted content discoverable')]
    [MSFT_FabricTenantSetting] $DiscoverDatasetsSettingsPromoted

    [DscProperty()]
    [System.ComponentModel.Description('Dremio SSO')]
    [MSFT_FabricTenantSetting] $DremioSSO

    [DscProperty()]
    [System.ComponentModel.Description('Apply sensitivity labels from data sources to their data in Power BI')]
    [MSFT_FabricTenantSetting] $EimInformationProtectionDataSourceInheritanceSetting

    [DscProperty()]
    [System.ComponentModel.Description('Automatically apply sensitivity labels to downstream content')]
    [MSFT_FabricTenantSetting] $EimInformationProtectionDownstreamInheritanceSetting

    [DscProperty()]
    [System.ComponentModel.Description('Allow users to apply sensitivity labels for content')]
    [MSFT_FabricTenantSetting] $EimInformationProtectionEdit

    [DscProperty()]
    [System.ComponentModel.Description('DEPRECATED')]
    [MSFT_FabricTenantSetting] $EimInformationProtectionLessElevated

    [DscProperty()]
    [System.ComponentModel.Description('Allow workspace admins to override automatically applied sensitivity labels')]
    [MSFT_FabricTenantSetting] $EimInformationProtectionWorkspaceAdminsOverrideAutomaticLabelsSetting

    [DscProperty()]
    [System.ComponentModel.Description('Guest users can browse and access Fabric content')]
    [MSFT_FabricTenantSetting] $ElevatedGuestsTenant

    [DscProperty()]
    [System.ComponentModel.Description('Receive email notifications for service outages or incidents')]
    [MSFT_FabricTenantSetting] $EmailSecurityGroupsOnOutage

    [DscProperty()]
    [System.ComponentModel.Description('Guest users can set up and subscribe to email subscriptions')]
    [MSFT_FabricTenantSetting] $EmailSubscriptionsToB2BUsers

    [DscProperty()]
    [System.ComponentModel.Description('Users can send email subscriptions to guest users')]
    [MSFT_FabricTenantSetting] $EmailSubscriptionsToExternalUsers

    [DscProperty()]
    [System.ComponentModel.Description('Users can set up email subscriptions')]
    [MSFT_FabricTenantSetting] $EmailSubscriptionTenant

    [DscProperty()]
    [System.ComponentModel.Description('Embed content in apps')]
    [MSFT_FabricTenantSetting] $Embedding

    [DscProperty()]
    [System.ComponentModel.Description('Users can use Copilot and other features powered by Azure OpenAI')]
    [MSFT_FabricTenantSetting] $EnableAOAI

    [DscProperty()]
    [System.ComponentModel.Description('Allow specific users to turn on external data sharing')]
    [MSFT_FabricTenantSetting] $EnableDatasetInPlaceSharing

    [DscProperty()]
    [System.ComponentModel.Description('Allow connections to featured tables')]
    [MSFT_FabricTenantSetting] $EnableExcelYellowIntegration

    [DscProperty()]
    [System.ComponentModel.Description('DEPRECATED')]
    [MSFT_FabricTenantSetting] $EnableFabricAirflow

    [DscProperty()]
    [System.ComponentModel.Description('Allow quick measure suggestions (preview)')]
    [MSFT_FabricTenantSetting] $EnableNLToDax

    [DscProperty()]
    [System.ComponentModel.Description('Allow tenant and domain admins to override workspace assignments (preview)')]
    [MSFT_FabricTenantSetting] $EnableReassignDataDomainSwitch

    [DscProperty()]
    [System.ComponentModel.Description('Use ArcGIS Maps for Power BI')]
    [MSFT_FabricTenantSetting] $EsriVisual

    [DscProperty()]
    [System.ComponentModel.Description('Help Power BI optimize your experience')]
    [MSFT_FabricTenantSetting] $ExpFlightingTenant

    [DscProperty()]
    [System.ComponentModel.Description('Download reports')]
    [MSFT_FabricTenantSetting] $ExportReport

    [DscProperty()]
    [System.ComponentModel.Description('Export to .csv')]
    [MSFT_FabricTenantSetting] $ExportToCsv

    [DscProperty()]
    [System.ComponentModel.Description('Export to Excel')]
    [MSFT_FabricTenantSetting] $ExportToExcelSetting

    [DscProperty()]
    [System.ComponentModel.Description('Export reports as image files')]
    [MSFT_FabricTenantSetting] $ExportToImage

    [DscProperty()]
    [System.ComponentModel.Description('Export reports as MHTML documents')]
    [MSFT_FabricTenantSetting] $ExportToMHTML

    [DscProperty()]
    [System.ComponentModel.Description('Export reports as PowerPoint presentations or PDF documents')]
    [MSFT_FabricTenantSetting] $ExportToPowerPoint

    [DscProperty()]
    [System.ComponentModel.Description('Export reports as Word documents')]
    [MSFT_FabricTenantSetting] $ExportToWord

    [DscProperty()]
    [System.ComponentModel.Description('Export reports as XML documents')]
    [MSFT_FabricTenantSetting] $ExportToXML

    [DscProperty()]
    [System.ComponentModel.Description('Copy and paste visuals')]
    [MSFT_FabricTenantSetting] $ExportVisualImageTenant

    [DscProperty()]
    [System.ComponentModel.Description('Guest users can work with shared semantic models in their own tenants')]
    [MSFT_FabricTenantSetting] $ExternalDatasetSharingTenant

    [DscProperty()]
    [System.ComponentModel.Description('Users can invite guest users to collaborate through item sharing and permissions')]
    [MSFT_FabricTenantSetting] $ExternalSharingV2

    [DscProperty()]
    [System.ComponentModel.Description('Capacity admins and contributors can add and remove additional workloads')]
    [MSFT_FabricTenantSetting] $FabricAddPartnerWorkload

    [DscProperty()]
    [System.ComponentModel.Description('Product Feedback')]
    [MSFT_FabricTenantSetting] $FabricFeedbackTenantSwitch

    [DscProperty()]
    [System.ComponentModel.Description('Users can create Fabric items')]
    [MSFT_FabricTenantSetting] $FabricGAWorkloads

    [DscProperty()]
    [System.ComponentModel.Description('Capacity admins can develop additional workloads')]
    [MSFT_FabricTenantSetting] $FabricThirdPartyWorkloads

    [DscProperty()]
    [System.ComponentModel.Description('Users can sync workspace items with GitHub repositories ')]
    [MSFT_FabricTenantSetting] $GitHubTenantSettings

    [DscProperty()]
    [System.ComponentModel.Description('Users can export items to Git repositories in other geographical locations (preview)')]
    [MSFT_FabricTenantSetting] $GitIntegrationCrossGeoTenantSwitch

    [DscProperty()]
    [System.ComponentModel.Description('Users can export workspace items with applied sensitivity labels to Git repositories (preview)')]
    [MSFT_FabricTenantSetting] $GitIntegrationSensitivityLabelsTenantSwitch

    [DscProperty()]
    [System.ComponentModel.Description('Users can synchronize workspace items with their Git repositories (preview)')]
    [MSFT_FabricTenantSetting] $GitIntegrationTenantSwitch

    [DscProperty()]
    [System.ComponentModel.Description('Google BigQuery SSO')]
    [MSFT_FabricTenantSetting] $GoogleBigQuerySSO

    [DscProperty()]
    [System.ComponentModel.Description('DEPRECATED')]
    [MSFT_FabricTenantSetting] $GraphQLTenant

    [DscProperty()]
    [System.ComponentModel.Description('Healthcare data solutions (preview)')]
    [MSFT_FabricTenantSetting] $HealthcareSolutionsTenantSwitch

    [DscProperty()]
    [System.ComponentModel.Description('Install template apps not listed in AppSource')]
    [MSFT_FabricTenantSetting] $InstallNonvalidatedTemplateApps

    [DscProperty()]
    [System.ComponentModel.Description('Install template apps')]
    [MSFT_FabricTenantSetting] $InstallServiceApps

    [DscProperty()]
    [System.ComponentModel.Description('Users can create Real-Time Dashboards (preview)')]
    [MSFT_FabricTenantSetting] $KustoDashboardTenantSwitch

    [DscProperty()]
    [System.ComponentModel.Description('Users can work with semantic models in Excel using a live connection')]
    [MSFT_FabricTenantSetting] $LiveConnection

    [DscProperty()]
    [System.ComponentModel.Description('Azure Log Analytics connections for workspace administrators')]
    [MSFT_FabricTenantSetting] $LogAnalyticsAttachForWorkspaceAdmins

    [DscProperty()]
    [System.ComponentModel.Description('Users can see Microsoft Fabric metadata in Microsoft 365')]
    [MSFT_FabricTenantSetting] $M365DataSharing

    [DscProperty()]
    [System.ComponentModel.Description('Database Mirroring (preview)')]
    [MSFT_FabricTenantSetting] $Mirroring

    [DscProperty()]
    [System.ComponentModel.Description('Semantic model owners can choose to automatically update semantic models from files imported from OneDrive or SharePoint')]
    [MSFT_FabricTenantSetting] $ODSPRefreshEnforcementTenantAllowAutomaticUpdate

    [DscProperty()]
    [System.ComponentModel.Description('Users can share links to Power BI files stored in OneDrive and SharePoint through Power BI Desktop (preview)')]
    [MSFT_FabricTenantSetting] $OneDriveSharePointAllowSharingTenantSetting

    [DscProperty()]
    [System.ComponentModel.Description('Users can view Power BI files saved in OneDrive and SharePoint (preview)')]
    [MSFT_FabricTenantSetting] $OneDriveSharePointViewerIntegrationTenantSettingV2

    [DscProperty()]
    [System.ComponentModel.Description('Users can sync data in OneLake with the OneLake File Explorer app')]
    [MSFT_FabricTenantSetting] $OneLakeFileExplorer

    [DscProperty()]
    [System.ComponentModel.Description('Users can access data stored in OneLake with apps external to Fabric')]
    [MSFT_FabricTenantSetting] $OneLakeForThirdParty

    [DscProperty()]
    [System.ComponentModel.Description('Allow XMLA endpoints and Analyze in Excel with on-premises semantic models')]
    [MSFT_FabricTenantSetting] $OnPremAnalyzeInExcel

    [DscProperty()]
    [System.ComponentModel.Description('Create and use Metrics')]
    [MSFT_FabricTenantSetting] $PowerBIGoalsTenant

    [DscProperty()]
    [System.ComponentModel.Description('DEPRECATED')]
    [MSFT_FabricTenantSetting] $PowerPlatformSolutionsIntegrationTenant

    [DscProperty()]
    [System.ComponentModel.Description('Print dashboards and reports')]
    [MSFT_FabricTenantSetting] $Printing

    [DscProperty()]
    [System.ComponentModel.Description('Featured content')]
    [MSFT_FabricTenantSetting] $PromoteContent

    [DscProperty()]
    [System.ComponentModel.Description('Publish apps to the entire organization')]
    [MSFT_FabricTenantSetting] $PublishContentPack

    [DscProperty()]
    [System.ComponentModel.Description('Publish to web')]
    [MSFT_FabricTenantSetting] $PublishToWeb

    [DscProperty()]
    [System.ComponentModel.Description('Review questions')]
    [MSFT_FabricTenantSetting] $QnaFeedbackLoop

    [DscProperty()]
    [System.ComponentModel.Description('Synonym sharing')]
    [MSFT_FabricTenantSetting] $QnaLsdlSharing

    [DscProperty()]
    [System.ComponentModel.Description('Scale out queries for large semantic models')]
    [MSFT_FabricTenantSetting] $QueryScaleOutTenant

    [DscProperty()]
    [System.ComponentModel.Description('Redshift SSO')]
    [MSFT_FabricTenantSetting] $RedshiftSSO

    [DscProperty()]
    [System.ComponentModel.Description('Block users from reassigning personal workspaces (My Workspace)')]
    [MSFT_FabricTenantSetting] $RestrictMyFolderCapacity

    [DscProperty()]
    [System.ComponentModel.Description('DEPRECATED')]
    [MSFT_FabricTenantSetting] $RetailSolutionsTenantSwitch

    [DscProperty()]
    [System.ComponentModel.Description('Interact with and share R and Python visuals')]
    [MSFT_FabricTenantSetting] $RScriptVisual

    [DscProperty()]
    [System.ComponentModel.Description('DEPRECATED')]
    [MSFT_FabricTenantSetting] $ServicePrincipalAccess

    [DscProperty()]
    [System.ComponentModel.Description('Allow shareable links to grant access to everyone in your organization')]
    [MSFT_FabricTenantSetting] $ShareLinkToEntireOrg

    [DscProperty()]
    [System.ComponentModel.Description('Enable Microsoft Teams integration')]
    [MSFT_FabricTenantSetting] $ShareToTeamsTenant

    [DscProperty()]
    [System.ComponentModel.Description('Snowflake SSO')]
    [MSFT_FabricTenantSetting] $SnowflakeSSO

    [DscProperty()]
    [System.ComponentModel.Description('Enable Power BI add-in for PowerPoint')]
    [MSFT_FabricTenantSetting] $StorytellingTenant

    [DscProperty()]
    [System.ComponentModel.Description('Sustainability solutions (preview)')]
    [MSFT_FabricTenantSetting] $SustainabilitySolutionsTenantSwitch

    [DscProperty()]
    [System.ComponentModel.Description('Create template organizational apps')]
    [MSFT_FabricTenantSetting] $TemplatePublish

    [DscProperty()]
    [System.ComponentModel.Description('Publish Get Help information')]
    [MSFT_FabricTenantSetting] $TenantSettingPublishGetHelpInfo

    [DscProperty()]
    [System.ComponentModel.Description('Data Activator (preview)')]
    [MSFT_FabricTenantSetting] $TridentPrivatePreview

    [DscProperty()]
    [System.ComponentModel.Description('Usage metrics for content creators')]
    [MSFT_FabricTenantSetting] $UsageMetrics

    [DscProperty()]
    [System.ComponentModel.Description('Per-user data in usage metrics for content creators')]
    [MSFT_FabricTenantSetting] $UsageMetricsTrackUserLevelInfo

    [DscProperty()]
    [System.ComponentModel.Description('Use semantic models across workspaces')]
    [MSFT_FabricTenantSetting] $UseDatasetsAcrossWorkspaces

    [DscProperty()]
    [System.ComponentModel.Description('Integration with SharePoint and Microsoft Lists')]
    [MSFT_FabricTenantSetting] $VisualizeListInPowerBI

    [DscProperty()]
    [System.ComponentModel.Description('Web content on dashboard tiles')]
    [MSFT_FabricTenantSetting] $WebContentTilesTenant

    [DscProperty()]
    [System.ComponentModel.Description('Users can edit data models in the Power BI service (preview)')]
    [MSFT_FabricTenantSetting] $WebModelingTenantSwitch

    [DscProperty()]
    [System.ComponentModel.Description('Users with view permission can launch Explore')]
    [MSFT_FabricTenantSetting] $AdminDataExploreViewPermission

    [DscProperty()]
    [System.ComponentModel.Description('Show user data in the Fabric Capacity Metrics app and reports')]
    [MSFT_FabricTenantSetting] $AllowCapacityMetricsReportUserMask

    [DscProperty()]
    [System.ComponentModel.Description('Allow non-Entra ID auth in Eventstream')]
    [MSFT_FabricTenantSetting] $AllowNonEntraADAuthInEventStream

    [DscProperty()]
    [System.ComponentModel.Description('Service principals can access admin APIs used for updates')]
    [MSFT_FabricTenantSetting] $AllowServicePrincipalsUseWriteAdminAPIs

    [DscProperty()]
    [System.ComponentModel.Description('Data sent to Azure OpenAI can be stored outside your capacity''s geographic region, compliance boundary, or national cloud instance')]
    [MSFT_FabricTenantSetting] $AllowStoreAOAIDataInOtherRegions

    [DscProperty()]
    [System.ComponentModel.Description('Users can create dbt job items (preview)')]
    [MSFT_FabricTenantSetting] $ArtifactDBTItemTenantSwitch

    [DscProperty()]
    [System.ComponentModel.Description('User can create Graph (preview)')]
    [MSFT_FabricTenantSetting] $ArtifactGraphPreview

    [DscProperty()]
    [System.ComponentModel.Description('Users can create Maps (preview)')]
    [MSFT_FabricTenantSetting] $ArtifactMapTenantSwitch

    [DscProperty()]
    [System.ComponentModel.Description('TBD')]
    [MSFT_FabricTenantSetting] $ArtifactSnowflakeDatabasePreview

    [DscProperty()]
    [System.ComponentModel.Description('Automatically convert and store reports using Power BI enhanced metadata format (PBIR) (preview)')]
    [MSFT_FabricTenantSetting] $AutomaticallyUsePBIR

    [DscProperty()]
    [System.ComponentModel.Description('Users can use the Azure Maps visual')]
    [MSFT_FabricTenantSetting] $AzureMaps

    [DscProperty()]
    [System.ComponentModel.Description('Data sent to Azure Maps can be processed outside your tenant''s geographic region, compliance boundary, or national cloud instance')]
    [MSFT_FabricTenantSetting] $AzureMapsCrossRegionDataProcessing

    [DscProperty()]
    [System.ComponentModel.Description('Users can use Azure Maps services')]
    [MSFT_FabricTenantSetting] $AzureMapsInFabric

    [DscProperty()]
    [System.ComponentModel.Description('Data sent to Azure Maps can be processed outside your capacity''s geographic region, compliance boundary or national cloud instance')]
    [MSFT_FabricTenantSetting] $AzureMapsInFabricCrossRegionDataProcessing

    [DscProperty()]
    [System.ComponentModel.Description('Data sent to Azure Maps can be processed by Microsoft Online Services Subprocessors')]
    [MSFT_FabricTenantSetting] $AzureMapsThirdPartyDataProcessing

    [DscProperty()]
    [System.ComponentModel.Description('Users can use Azure Maps Weather Services (Preview)')]
    [MSFT_FabricTenantSetting] $AzureMapsWeatherServices

    [DscProperty()]
    [System.ComponentModel.Description('Configure workspace IP firewall rules (preview)')]
    [MSFT_FabricTenantSetting] $ConfigureWorkspaceLevelIPFirewallRules

    [DscProperty()]
    [System.ComponentModel.Description('Capacities can be designated as Fabric Copilot capacities')]
    [MSFT_FabricTenantSetting] $CopilotCapacitySetupPermissionSwitch

    [DscProperty()]
    [System.ComponentModel.Description('Allow Microsoft Purview to secure AI interactions')]
    [MSFT_FabricTenantSetting] $DataSecurityForAIInteractions

    [DscProperty()]
    [System.ComponentModel.Description('TBD')]
    [MSFT_FabricTenantSetting] $DeltaToIcebergTableVirtualization

    [DscProperty()]
    [System.ComponentModel.Description('Users can create Digital Twin Builder (preview) items')]
    [MSFT_FabricTenantSetting] $DigitalOperationsPreview

    [DscProperty()]
    [System.ComponentModel.Description('Users can create Direct Lake on OneLake semantic models (preview)')]
    [MSFT_FabricTenantSetting] $DirectLakeOnOneLakeSemanticModelCreation

    [DscProperty()]
    [System.ComponentModel.Description('Domain admins can set default sensitivity labels for their domains (preview)')]
    [MSFT_FabricTenantSetting] $EimInformationProtectionDefaultLabelDomainSetting

    [DscProperty()]
    [System.ComponentModel.Description('ArcGIS GeoAnalytics for Fabric Runtime')]
    [MSFT_FabricTenantSetting] $EnableEsriLibraries

    [DscProperty()]
    [System.ComponentModel.Description('Workspace admins can add and remove additional workloads (preview)')]
    [MSFT_FabricTenantSetting] $FabricAddWorkloadToWorkspace

    [DscProperty()]
    [System.ComponentModel.Description('Users can be informed of upcoming conferences featuring Microsoft Fabric when they are logged in to Fabric')]
    [MSFT_FabricTenantSetting] $FabricPromotionTenantSwitch

    [DscProperty()]
    [System.ComponentModel.Description('Users can access a standalone, cross-item Power BI Copilot experience (preview)')]
    [MSFT_FabricTenantSetting] $ImmersiveTenantAdminSwitch

    [DscProperty()]
    [System.ComponentModel.Description('ML models can serve real-time predictions from API endpoints (preview)')]
    [MSFT_FabricTenantSetting] $MLModelEndpointsTenantSwitch

    [DscProperty()]
    [System.ComponentModel.Description('Include end-user identifiers in OneLake diagnostic logs')]
    [MSFT_FabricTenantSetting] $OneLakeDiagnosticLogsEUII

    [DscProperty()]
    [System.ComponentModel.Description('Users can create Ontology (preview) items')]
    [MSFT_FabricTenantSetting] $OntologyPreview

    [DscProperty()]
    [System.ComponentModel.Description('Workspace admins can turn on monitoring for their workspaces (preview)')]
    [MSFT_FabricTenantSetting] $PlatformMonitoringTenantSetting

    [DscProperty()]
    [System.ComponentModel.Description('Users can use the Power BI Model Context Protocol server endpoint (preview)')]
    [MSFT_FabricTenantSetting] $PowerBIMCP

    [DscProperty()]
    [System.ComponentModel.Description('Only show approved items in the standalone Copilot in Power BI experience (preview)')]
    [MSFT_FabricTenantSetting] $PreppedForCopilotContentDiscovery

    [DscProperty()]
    [System.ComponentModel.Description('Detect anomalies in Real-Time Intelligence (Preview)')]
    [MSFT_FabricTenantSetting] $RTHAnomalyDetectionTenantSwitch

    [DscProperty()]
    [System.ComponentModel.Description('Enable Operations Agents (Preview)')]
    [MSFT_FabricTenantSetting] $RTHOperationalAgentsTenantSwitch

    [DscProperty()]
    [System.ComponentModel.Description('Service principals can create workspaces, connections, and deployment pipelines')]
    [MSFT_FabricTenantSetting] $ServicePrincipalAccessGlobalAPIs

    [DscProperty()]
    [System.ComponentModel.Description('Service principals can call Fabric public APIs')]
    [MSFT_FabricTenantSetting] $ServicePrincipalAccessPermissionAPIs

    [DscProperty()]
    [System.ComponentModel.Description('All Power BI users can see Set alert button to create Fabric Activator alerts')]
    [MSFT_FabricTenantSetting] $ShowActivatorEntryPointsTenantSwitch

    [DscProperty()]
    [System.ComponentModel.Description('Users can see and work with additional workloads not validated by Microsoft')]
    [MSFT_FabricTenantSetting] $ThirdPartyPrivateWorkloads

    [DscProperty()]
    [System.ComponentModel.Description('Configure workspace-level inbound network rules')]
    [MSFT_FabricTenantSetting] $WorkspaceBlockInboundAccess

    [DscProperty()]
    [System.ComponentModel.Description('Configure workspace-level outbound network rules')]
    [MSFT_FabricTenantSetting] $WorkspaceBlockOutboundAccess

    [DscProperty()]
    [System.ComponentModel.Description('Apply customer-managed keys')]
    [MSFT_FabricTenantSetting] $WorkspaceCmk

    [DscProperty()]
    [System.ComponentModel.Description('Id of the Azure Active Directory application to authenticate with.')]
    [System.String] $ApplicationId

    [DscProperty()]
    [System.ComponentModel.Description('Secret of the Azure Active Directory application to authenticate with.')]
    [System.Management.Automation.PSCredential] $ApplicationSecret

    [DscProperty()]
    [System.ComponentModel.Description('Id of the Azure Active Directory tenant used for authentication.')]
    [System.String] $TenantId

    [DscProperty()]
    [System.ComponentModel.Description('Thumbprint of the Azure Active Directory application''s authentication certificate to use for authentication.')]
    [System.String] $CertificateThumbprint

    [DscProperty()]
    [System.ComponentModel.Description('Username can be made up to anything but password will be used for CertificatePassword')]
    [System.Management.Automation.PSCredential] $CertificatePassword

    [DscProperty()]
    [System.ComponentModel.Description('Path to certificate used in service principal usually a PFX file.')]
    [System.String] $CertificatePath

    [DscProperty()]
    [System.ComponentModel.Description('Managed ID being used for authentication.')]
    [System.Nullable[System.Boolean]] $ManagedIdentity

    [DscProperty()]
    [System.ComponentModel.Description('Access token used for authentication.')]
    [System.String[]] $AccessTokens

    [FabricAdminTenantSettings] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [FabricAdminTenantSettings]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message 'Getting configuration of Fabric Admin Tenant Settings'

        try
        {
            $null = $this.Connect('Fabric')

            #Ensure the proper dependencies are installed in the current environment.
            Confirm-M365DSCDependencies

            #region Telemetry
            $this.AddTelemetry('Get')
            #endregion

            $nullResult = $this.GetBoundParameters()

            if ($null -ne $this.ResourceCache['exportedInstances'] -and $this.ResourceCache['ExportMode'])
            {
                $instance = $this.ResourceCache['exportedInstances']
            }
            else
            {
                $uri = (Get-MSCloudLoginConnectionProfile -Workload 'Fabric').HostUrl + '/v1/admin/tenantsettings'
                $instance = Invoke-M365DSCFabricWebRequest -Uri $uri -Method 'GET'
            }
            if ($null -eq $instance)
            {
                return $this.AsResult($nullResult)
            }

            $results = @{
                IsSingleInstance                                                      = 'Yes'
                AADSSOForGateway                                                      = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'AADSSOForGateway' }))
                AdminApisIncludeDetailedMetadata                                      = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'AdminApisIncludeDetailedMetadata' }))
                AdminApisIncludeExpressions                                           = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'AdminApisIncludeExpressions' }))
                AdminCustomDisclaimer                                                 = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'AdminCustomDisclaimer' }))
                AISkillArtifactTenantSwitch                                           = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'AISkillArtifactTenantSwitch' }))
                AllowAccessOverPrivateLinks                                           = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'AllowAccessOverPrivateLinks' }))
                AllowCVAuthenticationTenant                                           = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'AllowCVAuthenticationTenant' }))
                AllowCVLocalStorageV2Tenant                                           = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'AllowCVLocalStorageV2Tenant' }))
                AllowCVToExportDataToFileTenant                                       = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'AllowCVToExportDataToFileTenant' }))
                AllowEndorsementMasterDataSwitch                                      = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'AllowEndorsementMasterDataSwitch' }))
                AllowExternalDataSharingReceiverSwitch                                = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'AllowExternalDataSharingReceiverSwitch' }))
                AllowExternalDataSharingSwitch                                        = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'AllowExternalDataSharingSwitch' }))
                AllowFreeTrial                                                        = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'AllowFreeTrial' }))
                AllowGetOneLakeUDK                                                    = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'AllowGetOneLakeUDK' }))
                AllowGuestLookup                                                      = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'AllowGuestLookup' }))
                AllowGuestUserToAccessSharedContent                                   = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'AllowGuestUserToAccessSharedContent' }))
                # DEPRECATED
                #AllowMountDfCreation                                                  = Get-M365DSCFabricTenantSettingObject -Setting ($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'AllowMountDfCreation' })
                AllowOneLakeUDK                                                       = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'AllowOneLakeUDK' }))
                AllowPowerBIASDQOnTenant                                              = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'AllowPowerBIASDQOnTenant' }))
                AllowSendAOAIDataToOtherRegions                                       = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'AllowSendAOAIDataToOtherRegions' }))
                AllowSendNLToDaxDataToOtherRegions                                    = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'AllowSendNLToDaxDataToOtherRegions' }))
                AllowServicePrincipalsCreateAndUseProfiles                            = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'AllowServicePrincipalsCreateAndUseProfiles' }))
                AllowServicePrincipalsUseReadAdminAPIs                                = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'AllowServicePrincipalsUseReadAdminAPIs' }))
                AppPush                                                               = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'AppPush' }))
                ArtifactOrgAppPreview                                                 = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'ArtifactOrgAppPreview' }))
                ArtifactSearchTenant                                                  = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'ArtifactSearchTenant' }))
                ASCollectQueryTextTelemetryTenantSwitch                               = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'ASCollectQueryTextTelemetryTenantSwitch' }))
                ASShareableCloudConnectionBindingSecurityModeTenant                   = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'ASShareableCloudConnectionBindingSecurityModeTenant' }))
                ASWritethruContinuousExportTenantSwitch                               = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'ASWritethruContinuousExportTenantSwitch' }))
                ASWritethruTenantSwitch                                               = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'ASWritethruTenantSwitch' }))
                AutoInstallPowerBIAppInTeamsTenant                                    = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'AutoInstallPowerBIAppInTeamsTenant' }))
                AutomatedInsightsEntryPoints                                          = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'AutomatedInsightsEntryPoints' }))
                AutomatedInsightsTenant                                               = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'AutomatedInsightsTenant' }))
                # DEPRECATED
                #AzureMap                                                              = Get-M365DSCFabricTenantSettingObject -Setting ($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'AzureMap' })
                BingMap                                                               = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'BingMap' }))
                BlockAccessFromPublicNetworks                                         = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'BlockAccessFromPublicNetworks' }))
                BlockAutoDiscoverAndPackageRefresh                                    = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'BlockAutoDiscoverAndPackageRefresh' }))
                BlockProtectedLabelSharingToEntireOrg                                 = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'BlockProtectedLabelSharingToEntireOrg' }))
                BlockResourceKeyAuthentication                                        = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'BlockResourceKeyAuthentication' }))
                CDSAManagement                                                        = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'CDSAManagement' }))
                CertifiedCustomVisualsTenant                                          = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'CertifiedCustomVisualsTenant' }))
                CertifyDatasets                                                       = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'CertifyDatasets' }))
                ConfigureFolderRetentionPeriod                                        = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'ConfigureFolderRetentionPeriod' }))
                CreateAppWorkspaces                                                   = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'CreateAppWorkspaces' }))
                CustomVisualsTenant                                                   = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'CustomVisualsTenant' }))
                DatamartTenant                                                        = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'DatamartTenant' }))
                DatasetExecuteQueries                                                 = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'DatasetExecuteQueries' }))
                DevelopServiceApps                                                    = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'DevelopServiceApps' }))
                DiscoverDatasetsConsumption                                           = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'DiscoverDatasetsConsumption' }))
                DiscoverDatasetsSettingsCertified                                     = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'DiscoverDatasetsSettingsCertified' }))
                DiscoverDatasetsSettingsPromoted                                      = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'DiscoverDatasetsSettingsPromoted' }))
                DremioSSO                                                             = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'DremioSSO' }))
                EimInformationProtectionDataSourceInheritanceSetting                  = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'EimInformationProtectionDataSourceInheritanceSetting' }))
                EimInformationProtectionDownstreamInheritanceSetting                  = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'EimInformationProtectionDownstreamInheritanceSetting' }))
                EimInformationProtectionEdit                                          = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'EimInformationProtectionEdit' }))
                # DEPRECATED
                #EimInformationProtectionLessElevated                                  = Get-M365DSCFabricTenantSettingObject -Setting ($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'EimInformationProtectionLessElevated' })
                EimInformationProtectionWorkspaceAdminsOverrideAutomaticLabelsSetting = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'EimInformationProtectionWorkspaceAdminsOverrideAutomaticLabelsSetting' }))
                ElevatedGuestsTenant                                                  = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'ElevatedGuestsTenant' }))
                EmailSecurityGroupsOnOutage                                           = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'EmailSecurityGroupsOnOutage' }))
                EmailSubscriptionsToB2BUsers                                          = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'EmailSubscriptionsToB2BUsers' }))
                EmailSubscriptionsToExternalUsers                                     = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'EmailSubscriptionsToExternalUsers' }))
                EmailSubscriptionTenant                                               = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'EmailSubscriptionTenant' }))
                Embedding                                                             = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'Embedding' }))
                EnableAOAI                                                            = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'EnableAOAI' }))
                EnableDatasetInPlaceSharing                                           = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'EnableDatasetInPlaceSharing' }))
                EnableExcelYellowIntegration                                          = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'EnableExcelYellowIntegration' }))
                # DEPRECATED
                #EnableFabricAirflow                                                   = Get-M365DSCFabricTenantSettingObject -Setting ($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'EnableFabricAirflow' })
                EnableNLToDax                                                         = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'EnableNLToDax' }))
                EnableReassignDataDomainSwitch                                        = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'EnableReassignDataDomainSwitch' }))
                EsriVisual                                                            = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'EsriVisual' }))
                ExpFlightingTenant                                                    = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'ExpFlightingTenant' }))
                ExportReport                                                          = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'ExportReport' }))
                ExportToCsv                                                           = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'ExportToCsv' }))
                ExportToExcelSetting                                                  = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'ExportToExcelSetting' }))
                ExportToImage                                                         = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'ExportToImage' }))
                ExportToMHTML                                                         = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'ExportToMHTML' }))
                ExportToPowerPoint                                                    = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'ExportToPowerPoint' }))
                ExportToWord                                                          = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'ExportToWord' }))
                ExportToXML                                                           = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'ExportToXML' }))
                ExportVisualImageTenant                                               = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'ExportVisualImageTenant' }))
                ExternalDatasetSharingTenant                                          = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'ExternalDatasetSharingTenant' }))
                ExternalSharingV2                                                     = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'ExternalSharingV2' }))
                FabricAddPartnerWorkload                                              = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'FabricAddPartnerWorkload' }))
                FabricFeedbackTenantSwitch                                            = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'FabricFeedbackTenantSwitch' }))
                FabricGAWorkloads                                                     = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'FabricGAWorkloads' }))
                FabricThirdPartyWorkloads                                             = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'FabricThirdPartyWorkloads' }))
                GitHubTenantSettings                                                  = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'GitHubTenantSettings' }))
                GitIntegrationCrossGeoTenantSwitch                                    = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'GitIntegrationCrossGeoTenantSwitch' }))
                GitIntegrationSensitivityLabelsTenantSwitch                           = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'GitIntegrationSensitivityLabelsTenantSwitch' }))
                GitIntegrationTenantSwitch                                            = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'GitIntegrationTenantSwitch' }))
                GoogleBigQuerySSO                                                     = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'GoogleBigQuerySSO' }))
                # DEPRECATED
                #GraphQLTenant                                                         = Get-M365DSCFabricTenantSettingObject -Setting ($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'GraphQLTenant' })
                HealthcareSolutionsTenantSwitch                                       = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'HealthcareSolutionsTenantSwitch' }))
                InstallNonvalidatedTemplateApps                                       = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'InstallNonvalidatedTemplateApps' }))
                InstallServiceApps                                                    = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'InstallServiceApps' }))
                KustoDashboardTenantSwitch                                            = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'KustoDashboardTenantSwitch' }))
                LiveConnection                                                        = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'LiveConnection' }))
                LogAnalyticsAttachForWorkspaceAdmins                                  = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'LogAnalyticsAttachForWorkspaceAdmins' }))
                M365DataSharing                                                       = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'M365DataSharing' }))
                Mirroring                                                             = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'Mirroring' }))
                ODSPRefreshEnforcementTenantAllowAutomaticUpdate                      = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'ODSPRefreshEnforcementTenantAllowAutomaticUpdate' }))
                OneDriveSharePointAllowSharingTenantSetting                           = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'OneDriveSharePointAllowSharingTenantSetting' }))
                OneDriveSharePointViewerIntegrationTenantSettingV2                    = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'OneDriveSharePointViewerIntegrationTenantSettingV2' }))
                OneLakeFileExplorer                                                   = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'OneLakeFileExplorer' }))
                OneLakeForThirdParty                                                  = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'OneLakeForThirdParty' }))
                OnPremAnalyzeInExcel                                                  = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'OnPremAnalyzeInExcel' }))
                PowerBIGoalsTenant                                                    = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'PowerBIGoalsTenant' }))
                # DEPRECATED
                #PowerPlatformSolutionsIntegrationTenant                               = Get-M365DSCFabricTenantSettingObject -Setting ($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'PowerPlatformSolutionsIntegrationTenant' })
                Printing                                                              = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'Printing' }))
                PromoteContent                                                        = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'PromoteContent' }))
                PublishContentPack                                                    = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'PublishContentPack' }))
                PublishToWeb                                                          = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'PublishToWeb' }))
                QnaFeedbackLoop                                                       = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'QnaFeedbackLoop' }))
                QnaLsdlSharing                                                        = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'QnaLsdlSharing' }))
                QueryScaleOutTenant                                                   = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'QueryScaleOutTenant' }))
                RedshiftSSO                                                           = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'RedshiftSSO' }))
                RestrictMyFolderCapacity                                              = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'RestrictMyFolderCapacity' }))
                # DEPRECATED
                #RetailSolutionsTenantSwitch                                           = Get-M365DSCFabricTenantSettingObject -Setting ($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'RetailSolutionsTenantSwitch' })
                RScriptVisual                                                         = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'RScriptVisual' }))
                # DEPRECATED
                #ServicePrincipalAccess                                                = Get-M365DSCFabricTenantSettingObject -Setting ($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'ServicePrincipalAccess' })
                ShareLinkToEntireOrg                                                  = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'ShareLinkToEntireOrg' }))
                ShareToTeamsTenant                                                    = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'ShareToTeamsTenant' }))
                SnowflakeSSO                                                          = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'SnowflakeSSO' }))
                StorytellingTenant                                                    = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'StorytellingTenant' }))
                SustainabilitySolutionsTenantSwitch                                   = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'SustainabilitySolutionsTenantSwitch' }))
                TemplatePublish                                                       = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'TemplatePublish' }))
                TenantSettingPublishGetHelpInfo                                       = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'TenantSettingPublishGetHelpInfo' }))
                TridentPrivatePreview                                                 = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'TridentPrivatePreview' }))
                UsageMetrics                                                          = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'UsageMetrics' }))
                UsageMetricsTrackUserLevelInfo                                        = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'UsageMetricsTrackUserLevelInfo' }))
                UseDatasetsAcrossWorkspaces                                           = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'UseDatasetsAcrossWorkspaces' }))
                VisualizeListInPowerBI                                                = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'VisualizeListInPowerBI' }))
                WebContentTilesTenant                                                 = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'WebContentTilesTenant' }))
                WebModelingTenantSwitch                                               = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'WebModelingTenantSwitch' }))
                AdminDataExploreViewPermission                                        = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'AdminDataExploreViewPermission' }))
                AllowCapacityMetricsReportUserMask                                    = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'AllowCapacityMetricsReportUserMask' }))
                AllowNonEntraADAuthInEventStream                                      = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'AllowNonEntraADAuthInEventStream' }))
                AllowServicePrincipalsUseWriteAdminAPIs                               = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'AllowServicePrincipalsUseWriteAdminAPIs' }))
                AllowStoreAOAIDataInOtherRegions                                      = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'AllowStoreAOAIDataInOtherRegions' }))
                ArtifactDBTItemTenantSwitch                                           = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'ArtifactDBTItemTenantSwitch' }))
                ArtifactGraphPreview                                                  = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'ArtifactGraphPreview' }))
                ArtifactMapTenantSwitch                                               = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'ArtifactMapTenantSwitch' }))
                ArtifactSnowflakeDatabasePreview                                      = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'ArtifactSnowflakeDatabasePreview' }))
                AutomaticallyUsePBIR                                                  = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'AutomaticallyUsePBIR' }))
                AzureMaps                                                             = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'AzureMaps' }))
                AzureMapsCrossRegionDataProcessing                                    = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'AzureMapsCrossRegionDataProcessing' }))
                AzureMapsInFabric                                                     = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'AzureMapsInFabric' }))
                AzureMapsInFabricCrossRegionDataProcessing                            = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'AzureMapsInFabricCrossRegionDataProcessing' }))
                AzureMapsThirdPartyDataProcessing                                     = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'AzureMapsThirdPartyDataProcessing' }))
                AzureMapsWeatherServices                                              = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'AzureMapsWeatherServices' }))
                ConfigureWorkspaceLevelIPFirewallRules                                = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'ConfigureWorkspaceLevelIPFirewallRules' }))
                CopilotCapacitySetupPermissionSwitch                                  = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'CopilotCapacitySetupPermissionSwitch' }))
                DataSecurityForAIInteractions                                         = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'DataSecurityForAIInteractions' }))
                DeltaToIcebergTableVirtualization                                     = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'DeltaToIcebergTableVirtualization' }))
                DigitalOperationsPreview                                              = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'DigitalOperationsPreview' }))
                DirectLakeOnOneLakeSemanticModelCreation                              = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'DirectLakeOnOneLakeSemanticModelCreation' }))
                EimInformationProtectionDefaultLabelDomainSetting                     = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'EimInformationProtectionDefaultLabelDomainSetting' }))
                EnableEsriLibraries                                                   = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'EnableEsriLibraries' }))
                FabricAddWorkloadToWorkspace                                          = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'FabricAddWorkloadToWorkspace' }))
                FabricPromotionTenantSwitch                                           = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'FabricPromotionTenantSwitch' }))
                ImmersiveTenantAdminSwitch                                            = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'ImmersiveTenantAdminSwitch' }))
                MLModelEndpointsTenantSwitch                                          = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'MLModelEndpointsTenantSwitch' }))
                OneLakeDiagnosticLogsEUII                                             = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'OneLakeDiagnosticLogsEUII' }))
                OntologyPreview                                                       = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'OntologyPreview' }))
                PlatformMonitoringTenantSetting                                       = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'PlatformMonitoringTenantSetting' }))
                PowerBIMCP                                                            = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'PowerBIMCP' }))
                PreppedForCopilotContentDiscovery                                     = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'PreppedForCopilotContentDiscovery' }))
                RTHAnomalyDetectionTenantSwitch                                       = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'RTHAnomalyDetectionTenantSwitch' }))
                RTHOperationalAgentsTenantSwitch                                      = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'RTHOperationalAgentsTenantSwitch' }))
                ServicePrincipalAccessGlobalAPIs                                      = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'ServicePrincipalAccessGlobalAPIs' }))
                ServicePrincipalAccessPermissionAPIs                                  = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'ServicePrincipalAccessPermissionAPIs' }))
                ShowActivatorEntryPointsTenantSwitch                                  = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'ShowActivatorEntryPointsTenantSwitch' }))
                ThirdPartyPrivateWorkloads                                            = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'ThirdPartyPrivateWorkloads' }))
                WorkspaceBlockInboundAccess                                           = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'WorkspaceBlockInboundAccess' }))
                WorkspaceBlockOutboundAccess                                          = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'WorkspaceBlockOutboundAccess' }))
                WorkspaceCmk                                                          = $this.GetFabricTenantSettingObject(($instance.tenantSettings | Where-Object -FilterScript { $_.settingName -eq 'WorkspaceCmk' }))
                ApplicationId                                                         = $this.ApplicationId
                TenantId                                                              = $this.TenantId
                ApplicationSecret                                                     = $this.ApplicationSecret
                CertificateThumbprint                                                 = $this.CertificateThumbprint
                CertificatePath                                                       = $this.CertificatePath
                CertificatePassword                                                   = $this.CertificatePassword
                ManagedIdentity                                                       = $this.ManagedIdentity
                AccessTokens                                                          = $this.AccessTokens
            }
            return $this.AsResult($results)
        }
        catch
        {
            $this.LogError($_, 'Error retrieving data:')

            throw
        }
    }

    [void] Set()
    {
        if ($this.RequiresPowerShellCore())
        {
            $null = $this.InvokeInPowerShellCore('Set')
            return
        }

        Write-Warning -Message 'This resource is read-only and does not support changing the settings. It is used for monitoring purposes only.'
    }

    [bool] Test()
    {
        return ([M365DSCResourceBase] $this).Test()
    }

    [string] Export()
    {
        $Credential = $null
        if ($this.RequiresPowerShellCore())
        {
            return [string] $this.InvokeInPowerShellCore('Export')
        }

        $ConnectionMode = $this.Connect('Fabric')

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Export')

        try
        {
            $this.ResourceCache['ExportMode'] = $true
            $uri = (Get-MSCloudLoginConnectionProfile -Workload 'Fabric').HostUrl + '/v1/admin/tenantsettings'
            [array] $this.ResourceCache['exportedInstances'] = Invoke-M365DSCFabricWebRequest -Uri $uri -Method 'GET'

            if ($null -ne $Global:M365DSCExportResourceInstancesCount)
            {
                $Global:M365DSCExportResourceInstancesCount++
            }
            $dscContent = [System.Text.StringBuilder]::new()
            $params = @{
                IsSingleInstance      = 'Yes'
                ApplicationId         = $this.ApplicationId
                TenantId              = $this.TenantId
                CertificateThumbprint = $this.CertificateThumbprint
                CertificatePath       = $this.CertificatePath
                CertificatePassword   = $this.CertificatePassword
                ManagedIdentity       = $this.ManagedIdentity
                AccessTokens          = $this.AccessTokens
            }

            $Results = $this.GetForExport($Params)

            $newResults = ([Hashtable]$Results).Clone()
            $noEscape = @()
            foreach ($key in @($Results.Keys))
            {
                if ($null -ne $Results.$key -and $key -notin $params.Keys)
                {
                    $complexTypeMapping = @(
                        @{
                            Name            = $key
                            CIMInstanceName = 'FabricTenantSetting'
                        },
                        @{
                            Name            = 'properties'
                            CIMInstanceName = 'FabricTenantSettingProperty'
                            IsArray         = $true
                        }
                    )

                    if ($null -ne $Results.$key.enabledSecurityGroups)
                    {
                        $Results.$key.enabledSecurityGroups = $Results.$key.enabledSecurityGroups -join ','
                    }

                    if ($null -ne $Results.$key.excludedSecurityGroups)
                    {
                        $Results.$key.excludedSecurityGroups = $Results.$key.excludedSecurityGroups -join ','
                    }

                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.$key `
                        -CIMInstanceName 'FabricTenantSetting' `
                        -ComplexTypeMapping $complexTypeMapping
                    if (-not [String]::IsNullOrEmpty($complexTypeStringResult))
                    {
                        $newResults.$key = $complexTypeStringResult
                        $noEscape += $key
                    }
                }
            }

            $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                -ConnectionMode $ConnectionMode `
                -ModulePath $this.GetModulePath() `
                -Results $newResults `
                -Credential $Credential `
                -NoEscape $noEscape

            [void]$dscContent.Append($currentDSCBlock)
            Save-M365DSCPartialExport -Content $currentDSCBlock `
                -FileName $Global:PartialExportFileName
            Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            return $dscContent.ToString()
        }
        catch
        {
            $this.LogError($_, 'Error during Export:')

            throw
        }
    }

    hidden [System.Collections.Hashtable] GetFabricTenantSettingObject([System.Object] $Setting)
    {
        if ($null -eq $Setting)
        {
            return $null
        }

        Write-Verbose -Message "Retrieving values for setting {$($Setting.settingName)}"

        $values = @{
            settingName = $Setting.settingName
            enabled     = [Boolean]$Setting.enabled
            title       = ($Setting.title -creplace '\P{IsBasicLatin}').Replace("`"", "```"")
        }
        if (-not [System.String]::IsNullOrEmpty($Setting.canSpecifySecurityGroups))
        {
            $values.Add('canSpecifySecurityGroups', [Boolean]$Setting.canSpecifySecurityGroups)
        }
        if (-not [System.String]::IsNullOrEmpty($Setting.delegateToWorkspace))
        {
            $values.Add('delegateToWorkspace', $Setting.delegateToWorkspace)
        }
        if (-not [System.String]::IsNullOrEmpty($Setting.delegatedFrom))
        {
            $values.Add('delegatedFrom', $Setting.delegatedFrom)
        }
        if (-not [System.String]::IsNullOrEmpty($Setting.tenantSettingGroup))
        {
            $values.Add('tenantSettingGroup', ($Setting.tenantSettingGroup -creplace '\P{IsBasicLatin}'))
        }
        if ($null -ne $Setting.properties -and $Setting.properties.Length -gt 0)
        {
            $propertiesValue = @()
            foreach ($property in $Setting.Properties)
            {
                $curProperty = @{
                    name  = $property.name
                    value = $property.value
                    type  = $property.type
                }
                $propertiesValue += $curProperty
            }

            $values.Add('properties', $propertiesValue)
        }
        if ($null -ne $Setting.excludedSecurityGroups -and $Setting.excludedSecurityGroups.Length -gt 0)
        {
            $values.Add('excludedSecurityGroups', [Array]$Setting.excludedSecurityGroups.name)
        }
        if ($null -ne $Setting.enabledSecurityGroups -and $Setting.enabledSecurityGroups.Length -gt 0)
        {
            $values.Add('enabledSecurityGroups', [Array]$Setting.enabledSecurityGroups.name)
        }
        return $values
    }

    hidden [FabricAdminTenantSettings] AsResult([System.Object] $Values)
    {
        if ($Values -is [FabricAdminTenantSettings])
        {
            return $Values
        }

        $result = [FabricAdminTenantSettings]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}

class MSFT_FabricTenantSetting
{
    [DscProperty()]
    [System.ComponentModel.Description('Indicates if the tenant setting is enabled for a security group. 0 - The tenant setting is enabled for the entire organization.')]
    [System.Nullable[System.Boolean]] $canSpecifySecurityGroups

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether the tenant setting can be delegated to a workspace admin. False - Workspace admin cannot override the tenant setting.')]
    [System.Nullable[System.Boolean]] $delegateToWorkspace

    [DscProperty()]
    [System.ComponentModel.Description('Tenant setting delegated from tenant, capacity or domain.')]
    [MSFT_FabricDelegatedFrom] $delegatedFrom

    [DscProperty()]
    [System.ComponentModel.Description('The name of the tenant setting.')]
    [System.String] $settingName

    [DscProperty()]
    [System.ComponentModel.Description('The status of the tenant setting.')]
    [System.Nullable[System.Boolean]] $enabled

    [DscProperty()]
    [System.ComponentModel.Description('Tenant setting group name.')]
    [System.String] $tenantSettingGroup

    [DscProperty()]
    [System.ComponentModel.Description('The title of the tenant setting.')]
    [System.String] $title

    [DscProperty()]
    [System.ComponentModel.Description('Tenant setting properties.')]
    [MSFT_FabricTenantSettingProperty[]] $properties

    [DscProperty()]
    [System.ComponentModel.Description('A list of excluded security groups.')]
    [System.String[]] $excludedSecurityGroups

    [DscProperty()]
    [System.ComponentModel.Description('A list of enabled security groups.')]
    [System.String[]] $enabledSecurityGroups
}

class MSFT_FabricDelegatedFrom
{
    [DscProperty()]
    [System.ComponentModel.Description('The setting is delegated from a capacity.')]
    [System.String] $Capacity

    [DscProperty()]
    [System.ComponentModel.Description('The setting is delegated from a domain.')]
    [System.String] $Domain

    [DscProperty()]
    [System.ComponentModel.Description('The setting is delegated from a tenant.')]
    [System.String] $Tenant
}

class MSFT_FabricTenantSettingProperty
{
    [DscProperty()]
    [System.ComponentModel.Description('The name of the property.')]
    [System.String] $name

    [DscProperty()]
    [System.ComponentModel.Description('The type of the property.')]
    [System.String] $type

    [DscProperty()]
    [System.ComponentModel.Description('The value of the property.')]
    [System.String] $value
}
