<#
This example sets Power Platform tenant settings.
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
    PPTenantSettings "PPTenantSettings-Example"
    {
      IsSingleInstance                                   = 'Yes'
      DisableCopilotFeedback                             = $false
      DisableMakerMatch                                  = $false
      DisableUnusedLicenseAssignment                     = $false
      DisableCreateFromImage                             = $false
      DisableConnectionSharingWithEveryone               = $true
      AllowNewOrgChannelDefault                          = $false
      DisableCopilot                                     = $false
      DisableCopilotWithBing                             = $false
      DisableAdminDigest                                 = $false
      DisablePreferredDataLocationForTeamsEnvironment    = $false
      DisableDeveloperEnvironmentCreationByNonAdminUsers = $true
      EnvironmentRoutingAllMakers                        = $false
      EnableDefaultEnvironmentRouting                    = $false
      EnableDesktopFlowDataPolicyManagement              = $true
      EnableCanvasAppInsights                            = $true
      DisableCreateFromFigma                             = $true
      DisableBillingPolicyCreationByNonAdminUsers        = $true
      StorageCapacityConsumptionWarningThreshold         = 85
      EnableTenantCapacityReportForEnvironmentAdmins     = $true
      EnableTenantLicensingReportForEnvironmentAdmins    = $true
      DisableUseOfUnassignedAIBuilderCredits             = $false
      EnableGenerativeAIFeaturesForSiteUsers             = "Enabled"
      EnableExternalAuthenticationProvidersInPowerPages  = "Enabled"
      DisableChampionsInvitationReachout                 = $false
      DisableSkillsMatchInvitationReachout               = $false
      EnableOpenAiBotPublishing                          = $false
      DisableAiPrompts                                   = $false
      DisableCopilotFeedbackMetadata                     = $true
      EnableModelDataSharing                             = $false
      DisableDataLogging                                 = $false
      PowerCatalogAudienceSetting                        = "All"
      EnableDeleteDisabledUserinAllEnvironments          = $true
      DisableHelpSupportCopilot                          = $false
      DisableSurveyScreenshots                           = $false
      WalkMeOptOut                                       = $false
      useSupportBingSearchByAllUsers                     = $false
      DisableNPSCommentsReachout                         = $false
      DisableNewsletterSendout                           = $false
      DisableEnvironmentCreationByNonAdminUsers          = $true
      DisablePortalsCreationByNonAdminUsers              = $false
      DisableSurveyFeedback                              = $false
      DisableTrialEnvironmentCreationByNonAdminUsers     = $false
      DisableCapacityAllocationByEnvironmentAdmins       = $true
      DisableSupportTicketsVisibleByAllUsers             = $false
      DisableDocsSearch                                  = $false
      DisableCommunitySearch                             = $false
      DisableBingVideoSearch                             = $false
      DisableShareWithEveryone                           = $false
      EnableGuestsToMake                                 = $false
      ShareWithColleaguesUserLimit                       = 10000
      ApplicationId                                      = $ApplicationId
      TenantId                                           = $TenantId
      CertificateThumbprint                              = $CertificateThumbprint
    }
  }
}
