using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class PPTenantSettings : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('Should be set to yes')]
    [ValidateSet('Yes')]
    [System.String] $IsSingleInstance

    [DscProperty()]
    [System.ComponentModel.Description('When using Copilot in Power Apps, allow users to submit feedback to Microsoft. Default value is false.')]
    [System.Nullable[System.Boolean]] $DisableCopilotFeedback

    [DscProperty()]
    [System.ComponentModel.Description('TBD')]
    [System.Nullable[System.Boolean]] $DisableMakerMatch

    [DscProperty()]
    [System.ComponentModel.Description('TBD')]
    [System.Nullable[System.Boolean]] $DisableUnusedLicenseAssignment

    [DscProperty()]
    [System.ComponentModel.Description('Allow people to use AI to generate an app based on an image. Default value is false.')]
    [System.Nullable[System.Boolean]] $DisableCreateFromImage

    [DscProperty()]
    [System.ComponentModel.Description('Gets or sets a value indicating whether non-admin users in the tenant can share connections with everyone. Default value is false.')]
    [System.Nullable[System.Boolean]] $DisableConnectionSharingWithEveryone

    [DscProperty()]
    [System.ComponentModel.Description('TBD')]
    [System.Nullable[System.Boolean]] $AllowNewOrgChannelDefault

    [DscProperty()]
    [System.ComponentModel.Description('Disables cloud flows copilot in Power Automate. It doesn''t control the ability to add AI-related connectors or actions in the flow designer. For example, the Skills connector or AI Builder creates text with a GPT action. Default value is false.')]
    [System.Nullable[System.Boolean]] $DisableCopilot

    [DscProperty()]
    [System.ComponentModel.Description('Disables the copilot-enhanced help feature within Power Automate to enhance answers on product documentation through Bing Search. Default value is false.')]
    [System.Nullable[System.Boolean]] $DisableCopilotWithBing

    [DscProperty()]
    [System.ComponentModel.Description('Disables the weekly admin digest email for Managed Environments. Default value is false.')]
    [System.Nullable[System.Boolean]] $DisableAdminDigest

    [DscProperty()]
    [System.ComponentModel.Description('Ignore the Teams group-preferred data location when provisioning a Teams environment. Default value is false.')]
    [System.Nullable[System.Boolean]] $DisablePreferredDataLocationForTeamsEnvironment

    [DscProperty()]
    [System.ComponentModel.Description('Restrict all developer environments to be created by tenant admins, Power Platform admins, or Dynamics 365 service admins. Default is false.')]
    [System.Nullable[System.Boolean]] $DisableDeveloperEnvironmentCreationByNonAdminUsers

    [DscProperty()]
    [System.ComponentModel.Description('TBD')]
    [System.Nullable[System.Boolean]] $EnvironmentRoutingAllMakers

    [DscProperty()]
    [System.ComponentModel.Description('Enables the Default Environment routing feature that creates personal, developer environments for new makers. Default value is false.')]
    [System.Nullable[System.Boolean]] $EnableDefaultEnvironmentRouting

    [DscProperty()]
    [System.ComponentModel.Description('When this setting is true, admins can view and manage desktop flow action groups in DLP policies in the Power Platform admin center. Default value is false.')]
    [System.Nullable[System.Boolean]] $EnableDesktopFlowDataPolicyManagement

    [DscProperty()]
    [System.ComponentModel.Description('Allow users to collect telemetry data about their app in Azure Application Insights. Setting this to False blocks the transmission of this data.')]
    [System.Nullable[System.Boolean]] $EnableCanvasAppInsights

    [DscProperty()]
    [System.ComponentModel.Description('Allow people to create a canvas app based on a Figma file. Default value is false.')]
    [System.Nullable[System.Boolean]] $DisableCreateFromFigma

    [DscProperty()]
    [System.ComponentModel.Description('This is a legacy setting that is no longer used by the platform. Default value is false.')]
    [System.Nullable[System.Boolean]] $DisableBillingPolicyCreationByNonAdminUsers

    [DscProperty()]
    [System.ComponentModel.Description('This setting isn''t currently used by the platform but might be used in the future.')]
    [System.Nullable[System.UInt32]] $StorageCapacityConsumptionWarningThreshold

    [DscProperty()]
    [System.ComponentModel.Description('Ability to allow tenant, Power Platform, or Dynamics 365 admins to grant permissions to an environment administrator to view the Capacity summary tab. Default value is false.')]
    [System.Nullable[System.Boolean]] $EnableTenantCapacityReportForEnvironmentAdmins

    [DscProperty()]
    [System.ComponentModel.Description('Ability to allow tenant, Power Platform, or Dynamics 365 admins to grant permissions to an environment administrator to view the tenant-scoped license reports. Default value is false.')]
    [System.Nullable[System.Boolean]] $EnableTenantLicensingReportForEnvironmentAdmins

    [DscProperty()]
    [System.ComponentModel.Description('Ability to use unallocated AI Builder credits in environments without allocated credits. Default value is true.')]
    [System.Nullable[System.Boolean]] $DisableUseOfUnassignedAIBuilderCredits

    [DscProperty()]
    [System.ComponentModel.Description('TBD')]
    [System.String] $EnableGenerativeAIFeaturesForSiteUsers

    [DscProperty()]
    [System.ComponentModel.Description('TBD')]
    [System.String] $EnableExternalAuthenticationProvidersInPowerPages

    [DscProperty()]
    [System.ComponentModel.Description('This setting isn''t currently used by the platform but might be used in the future.')]
    [System.Nullable[System.Boolean]] $DisableChampionsInvitationReachout

    [DscProperty()]
    [System.ComponentModel.Description('This setting isn''t currently used by the platform but might be used in the future.')]
    [System.Nullable[System.Boolean]] $DisableSkillsMatchInvitationReachout

    [DscProperty()]
    [System.ComponentModel.Description('This setting isn''t currently used by the platform but might be used in the future.')]
    [System.Nullable[System.Boolean]] $EnableOpenAiBotPublishing

    [DscProperty()]
    [System.ComponentModel.Description('TBD')]
    [System.Nullable[System.Boolean]] $DisableAiPrompts

    [DscProperty()]
    [System.ComponentModel.Description('When using Copilot in Power Apps, allow users to share their prompts, questions, and requests with Microsoft. Default value is true.')]
    [System.Nullable[System.Boolean]] $DisableCopilotFeedbackMetadata

    [DscProperty()]
    [System.ComponentModel.Description('Ability to allow Microsoft to read Power Automate Copilot AI feature customer data (inputs and outputs) and provide improved models. Default value is false.')]
    [System.Nullable[System.Boolean]] $EnableModelDataSharing

    [DscProperty()]
    [System.ComponentModel.Description('Ability to disable data logging and remove all data logged for Power Automate Copilot AI feature customer data (inputs and outputs). Default value is false.')]
    [System.Nullable[System.Boolean]] $DisableDataLogging

    [DscProperty()]
    [System.ComponentModel.Description('This setting is reserved for future use. No enforcement is driven by this setting at the current time.')]
    [System.String] $PowerCatalogAudienceSetting

    [DscProperty()]
    [System.ComponentModel.Description('TBD')]
    [System.Nullable[System.Boolean]] $EnableDeleteDisabledUserinAllEnvironments

    [DscProperty()]
    [System.ComponentModel.Description('TBD')]
    [System.Nullable[System.Boolean]] $DisableHelpSupportCopilot

    [DscProperty()]
    [System.ComponentModel.Description('TBD')]
    [System.Nullable[System.Boolean]] $DisableSurveyScreenshots

    [DscProperty()]
    [System.ComponentModel.Description('This is a legacy setting that is no longer used by the platform. Default value is false.')]
    [System.Nullable[System.Boolean]] $WalkMeOptOut

    [DscProperty()]
    [System.ComponentModel.Description('TBD')]
    [System.Nullable[System.Boolean]] $useSupportBingSearchByAllUsers

    [DscProperty()]
    [System.ComponentModel.Description('Ability to disable re-surveying users who left prior feedback via NPS prompts in Power Platform. Default value is false.')]
    [System.Nullable[System.Boolean]] $DisableNPSCommentsReachout

    [DscProperty()]
    [System.ComponentModel.Description('Ability to disable the newsletter sendout feature. Default value is false.')]
    [System.Nullable[System.Boolean]] $DisableNewsletterSendout

    [DscProperty()]
    [System.ComponentModel.Description('Restrict all environments to be created by tenant admins, Power Platform admins, or Dynamics 365 service admins. Default value is false.')]
    [System.Nullable[System.Boolean]] $DisableEnvironmentCreationByNonAdminUsers

    [DscProperty()]
    [System.ComponentModel.Description('Restrict all portals to be created by tenant admins, Power Platform admins, or Dynamics 365 service admins. Default value is false.')]
    [System.Nullable[System.Boolean]] $DisablePortalsCreationByNonAdminUsers

    [DscProperty()]
    [System.ComponentModel.Description('Ability to disable all NPS survey feedback prompts in Power Platform. Default value is false.')]
    [System.Nullable[System.Boolean]] $DisableSurveyFeedback

    [DscProperty()]
    [System.ComponentModel.Description('Restrict all trial environments to be created by tenant admins, Power Platform admins, or Dynamics 365 service admins. Default value is false.')]
    [System.Nullable[System.Boolean]] $DisableTrialEnvironmentCreationByNonAdminUsers

    [DscProperty()]
    [System.ComponentModel.Description('Ability to disable capacity allocation by environment administrators. Default value is false.')]
    [System.Nullable[System.Boolean]] $DisableCapacityAllocationByEnvironmentAdmins

    [DscProperty()]
    [System.ComponentModel.Description('Allows users, who already have access to the Help + Support page in Power Platform admin center, to see support requests created by other users in the tenant. Default value is True, which means this feature is turned off by default.')]
    [System.Nullable[System.Boolean]] $DisableSupportTicketsVisibleByAllUsers

    [DscProperty()]
    [System.ComponentModel.Description('When this setting is true, users in the environment can see a message that indicates Microsoft Learn and documentation search categories have been turned off by the administrator. Default value is false.')]
    [System.Nullable[System.Boolean]] $DisableDocsSearch

    [DscProperty()]
    [System.ComponentModel.Description('When this setting is true, users in the environment can see a message that indicates community and blog search categories have been turned off by the administrator. Default value is false.')]
    [System.Nullable[System.Boolean]] $DisableCommunitySearch

    [DscProperty()]
    [System.ComponentModel.Description('When this setting is true, users in the environment can see a message that indicates video search categories have been turned off by the administrator. Default value is false.')]
    [System.Nullable[System.Boolean]] $DisableBingVideoSearch

    [DscProperty()]
    [System.ComponentModel.Description('Ability to turn off the Share with Everyone capability for nonadmin users in all Power Apps. Default value is true.')]
    [System.Nullable[System.Boolean]] $DisableShareWithEveryone

    [DscProperty()]
    [System.ComponentModel.Description('When set to true this will enable the ability for guests in your tenant to create Power Platform resources.')]
    [System.Nullable[System.Boolean]] $EnableGuestsToMake

    [DscProperty()]
    [System.ComponentModel.Description('Maximum value setting for the number of users in a security group used to share an app built using Power Apps on Microsoft Teams. Default value is 10000 but can be increased or decreased, as required.')]
    [ValidateRange(1, 10000)]
    [System.Nullable[System.UInt32]] $ShareWithColleaguesUserLimit

    [DscProperty()]
    [System.ComponentModel.Description('Credentials of the Power Platform Admin')]
    [System.Management.Automation.PSCredential] $Credential

    [DscProperty()]
    [System.ComponentModel.Description('Id of the Azure Active Directory application to authenticate with.')]
    [System.String] $ApplicationId

    [DscProperty()]
    [System.ComponentModel.Description('Id of the Azure Active Directory tenant used for authentication.')]
    [System.String] $TenantId

    [DscProperty()]
    [System.ComponentModel.Description('Secret of the Azure Active Directory tenant used for authentication.')]
    [System.Management.Automation.PSCredential] $ApplicationSecret

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
    [System.ComponentModel.Description('Access tokens used for authentication in scenarios requiring multiple tokens.')]
    [System.String[]] $AccessTokens

    [PPTenantSettings] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [PPTenantSettings]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message 'Getting the Power Platform Tenant Settings Configuration'

        try
        {
            $null = $this.Connect('PowerPlatformREST')

            #Ensure the proper dependencies are installed in the current environment.
            Confirm-M365DSCDependencies

            #region Telemetry
            $this.AddTelemetry('Get')
            #endregion

            $uri = 'https://' + (Get-MSCloudLoginConnectionProfile -Workload 'PowerPlatformREST').BapEndpoint + `
                '/providers/Microsoft.BusinessAppPlatform/listTenantSettings?api-version=2016-11-01'
            $PPTenantSettings = Invoke-M365DSCPowerPlatformRESTWebRequest -Uri $uri -Method 'POST'
            return $this.AsResult(@{
                IsSingleInstance                                   = 'Yes'

                # search
                DisableDocsSearch                                  = $PPTenantSettings.powerPlatform.search.disableDocsSearch
                DisableCommunitySearch                             = $PPTenantSettings.powerPlatform.search.disableCommunitySearch
                DisableBingVideoSearch                             = $PPTenantSettings.powerPlatform.search.disableBingVideoSearch

                #teamsIntegration
                ShareWithColleaguesUserLimit                       = $PPTenantSettings.powerPlatform.teamsIntegration.shareWithColleaguesUserLimit

                #powerApps
                DisableShareWithEveryone                           = $PPTenantSettings.powerPlatform.powerApps.disableShareWithEveryone
                EnableGuestsToMake                                 = $PPTenantSettings.powerPlatform.powerApps.enableGuestsToMake
                DisableMakerMatch                                  = $PPTenantSettings.powerPlatform.powerApps.disableMakerMatch
                DisableUnusedLicenseAssignment                     = $PPTenantSettings.powerPlatform.powerApps.disableUnusedLicenseAssignment
                DisableCreateFromImage                             = $PPTenantSettings.powerPlatform.powerApps.disableCreateFromImage
                DisableCreateFromFigma                             = $PPTenantSettings.powerPlatform.powerApps.disableCreateFromFigma
                EnableCanvasAppInsights                            = $PPTenantSettings.powerPlatform.powerApps.enableCanvasAppInsights
                DisableConnectionSharingWithEveryone               = $PPTenantSettings.powerPlatform.powerApps.disableConnectionSharingWithEveryone
                AllowNewOrgChannelDefault                          = $PPTenantSettings.powerPlatform.powerApps.allowNewOrgChannelDefault
                DisableCopilot                                     = $PPTenantSettings.powerPlatform.powerApps.disableCopilot

                #powerAutomate
                DisableCopilotWithBing                             = $PPTenantSettings.powerPlatform.powerAutomate.disableCopilotWithBing

                #environments
                DisablePreferredDataLocationForTeamsEnvironment    = $PPTenantSettings.powerPlatform.environments.disablePreferredDataLocationForTeamsEnvironment

                #governance
                DisableAdminDigest                                 = $PPTenantSettings.powerPlatform.governance.disableAdminDigest
                DisableDeveloperEnvironmentCreationByNonAdminUsers = $PPTenantSettings.powerPlatform.governance.disableDeveloperEnvironmentCreationByNonAdminUsers
                EnableDefaultEnvironmentRouting                    = $PPTenantSettings.powerPlatform.governance.enableDefaultEnvironmentRouting
                EnableDesktopFlowDataPolicyManagement              = $PPTenantSettings.powerPlatform.governance.policy.enableDesktopFlowDataPolicyManagement
                EnvironmentRoutingAllMakers                        = $PPTenantSettings.powerPlatform.governance.environmentRoutingAllMakers

                #licensing
                DisableBillingPolicyCreationByNonAdminUsers        = $PPTenantSettings.powerPlatform.licensing.disableBillingPolicyCreationByNonAdminUsers
                EnableTenantCapacityReportForEnvironmentAdmins     = $PPTenantSettings.powerPlatform.licensing.enableTenantCapacityReportForEnvironmentAdmins
                StorageCapacityConsumptionWarningThreshold         = $PPTenantSettings.powerPlatform.licensing.storageCapacityConsumptionWarningThreshold
                EnableTenantLicensingReportForEnvironmentAdmins    = $PPTenantSettings.powerPlatform.licensing.enableTenantLicensingReportForEnvironmentAdmins
                DisableUseOfUnassignedAIBuilderCredits             = $PPTenantSettings.powerPlatform.licensing.disableUseOfUnassignedAIBuilderCredits

                #powerPages
                EnableGenerativeAIFeaturesForSiteUsers             = $PPTenantSettings.powerPlatform.powerPages.enableGenerativeAIFeaturesForSiteUsers
                EnableExternalAuthenticationProvidersInPowerPages  = $PPTenantSettings.powerPlatform.powerPages.enableExternalAuthenticationProvidersInPowerPages

                #champions
                DisableChampionsInvitationReachout                 = $PPTenantSettings.powerPlatform.champions.disableChampionsInvitationReachout
                DisableSkillsMatchInvitationReachout               = $PPTenantSettings.powerPlatform.champions.disableSkillsMatchInvitationReachout

                #intelligence
                DisableCopilotFeedback                             = $PPTenantSettings.powerPlatform.intelligence.disableCopilotFeedback
                EnableOpenAiBotPublishing                          = $PPTenantSettings.powerPlatform.intelligence.enableOpenAiBotPublishing
                DisableCopilotFeedbackMetadata                     = $PPTenantSettings.powerPlatform.intelligence.disableCopilotFeedbackMetadata
                DisableAiPrompts                                   = $PPTenantSettings.powerPlatform.intelligence.disableAiPrompts

                #modelExperimentation
                EnableModelDataSharing                             = $PPTenantSettings.powerPlatform.modelExperimentation.enableModelDataSharing
                DisableDataLogging                                 = $PPTenantSettings.powerPlatform.modelExperimentation.disableDataLogging

                #catalogSettings
                PowerCatalogAudienceSetting                        = $PPTenantSettings.powerPlatform.catalogSettings.powerCatalogAudienceSetting

                #userManagementSettings
                EnableDeleteDisabledUserinAllEnvironments          = $PPTenantSettings.powerPlatform.userManagementSettings.enableDeleteDisabledUserinAllEnvironments

                #helpSupportSettings
                DisableHelpSupportCopilot                          = $PPTenantSettings.powerPlatform.helpSupportSettings.disableHelpSupportCopilot
                UseSupportBingSearchByAllUsers                     = $PPTenantSettings.powerPlatform.helpSupportSettings.useSupportBingSearchByAllUsers

                #Main
                WalkMeOptOut                                       = $PPTenantSettings.walkMeOptOut
                DisableNPSCommentsReachout                         = $PPTenantSettings.disableNPSCommentsReachout
                DisableNewsletterSendout                           = $PPTenantSettings.disableNewsletterSendout
                DisableEnvironmentCreationByNonAdminUsers          = $PPTenantSettings.disableEnvironmentCreationByNonAdminUsers
                DisablePortalsCreationByNonAdminUsers              = $PPTenantSettings.disablePortalsCreationByNonAdminUsers
                DisableSurveyFeedback                              = $PPTenantSettings.disableSurveyFeedback
                DisableSurveyScreenshots                           = $PPTenantSettings.disableSurveyScreenshots
                DisableTrialEnvironmentCreationByNonAdminUsers     = $PPTenantSettings.disableTrialEnvironmentCreationByNonAdminUsers
                DisableCapacityAllocationByEnvironmentAdmins       = $PPTenantSettings.disableCapacityAllocationByEnvironmentAdmins
                DisableSupportTicketsVisibleByAllUsers             = $PPTenantSettings.disableSupportTicketsVisibleByAllUsers

                Credential                                         = $this.Credential
                ApplicationId                                      = $this.ApplicationId
                TenantId                                           = $this.TenantId
                ApplicationSecret                                  = $this.ApplicationSecret
                CertificateThumbprint                              = $this.CertificateThumbprint
                CertificatePath                                    = $this.CertificatePath
                CertificatePassword                                = $this.CertificatePassword
                ManagedIdentity                                    = $this.ManagedIdentity
                AccessTokens                                       = $this.AccessTokens
            })
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

        Write-Verbose -Message 'Setting Power Platform Tenant Settings configuration'

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $null = $this.Connect('PowerPlatformREST')

        $SetParameters = $this.GetBoundParameters()
        $RequestBody = $this.GetPowerPlatformTenantSettings($SetParameters)
        $jsonBody = ConvertTo-Json $RequestBody -Depth 20
        Write-Verbose -Message $jsonBody

        $uri = 'https://' + (Get-MSCloudLoginConnectionProfile -Workload 'PowerPlatformREST').BapEndpoint + `
            '/providers/Microsoft.BusinessAppPlatform/scopes/admin/updateTenantSettings?api-version=2016-11-01'
        Invoke-M365DSCPowerPlatformRESTWebRequest -Uri $uri -Method 'POST' -Body $RequestBody
    }

    [bool] Test()
    {
        return ([M365DSCResourceBase] $this).Test()
    }

    [string] Export()
    {
        if ($this.RequiresPowerShellCore())
        {
            return [string] $this.InvokeInPowerShellCore('Export')
        }

        $ConnectionMode = $this.Connect('PowerPlatformREST')

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Export')

        try
        {
            $uri = 'https://' + (Get-MSCloudLoginConnectionProfile -Workload 'PowerPlatformREST').BapEndpoint + `
                '/providers/Microsoft.BusinessAppPlatform/listTenantSettings?api-version=2016-11-01'
            $settings = Invoke-M365DSCPowerPlatformRESTWebRequest -Uri $uri -Method 'POST'

            if ($settings.StatusCode -eq 403)
            {
                throw 'Invalid permission for the application. If you are using a custom app registration to authenticate, make sure it is defined as a Power Platform admin management application. For additional information refer to https://learn.microsoft.com/en-us/power-platform/admin/powershell-create-service-principal#registering-an-admin-management-application'
            }
            $dscContent = [System.Text.StringBuilder]::new()

            if ($null -ne $Global:M365DSCExportResourceInstancesCount)
            {
                $Global:M365DSCExportResourceInstancesCount++
            }

            $Params = @{
                IsSingleInstance      = 'Yes'
                Credential            = $this.Credential
                ApplicationId         = $this.ApplicationId
                TenantId              = $this.TenantId
                ApplicationSecret     = $this.ApplicationSecret
                CertificateThumbprint = $this.CertificateThumbprint
                CertificatePath       = $this.CertificatePath
                CertificatePassword   = $this.CertificatePassword
                ManagedIdentity       = $this.ManagedIdentity
                AccessTokens          = $this.AccessTokens
            }
            $Results = $this.GetForExport($Params)
            if ($Results -is [System.Collections.Hashtable] -and $Results.Count -gt 1)
            {
                $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                    -ConnectionMode $ConnectionMode `
                    -ModulePath $this.GetModulePath() `
                    -Results $Results `
                    -Credential $this.Credential
                [void]$dscContent.Append($currentDSCBlock)

                Save-M365DSCPartialExport -Content $currentDSCBlock `
                    -FileName $Global:PartialExportFileName

                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiRedX -CommitWrite
            }

            return $dscContent.ToString()
        }
        catch
        {
            $this.LogError($_, 'Error during Export:')

            throw
        }
    }

    hidden [System.Collections.Hashtable] GetPowerPlatformTenantSettings([System.Collections.Hashtable] $Parameters)
    {
        $result = @{
            disableCapacityAllocationByEnvironmentAdmins   = $Parameters.DisableCapacityAllocationByEnvironmentAdmins
            disableSupportTicketsVisibleByAllUsers         = $Parameters.DisableSupportTicketsVisibleByAllUsers
            walkMeOptOut                                   = $Parameters.WalkMeOptOut
            disableSurveyScreenshots                       = $Parameters.DisableSurveyScreenshots
            disableEnvironmentCreationByNonAdminUsers      = $Parameters.DisableEnvironmentCreationByNonAdminUsers
            disablePortalsCreationByNonAdminUsers          = $Parameters.DisablePortalsCreationByNonAdminUsers
            disableNewsletterSendout                       = $Parameters.DisableNewsletterSendout
            disableNPSCommentsReachout                     = $Parameters.DisableNPSCommentsReachout
            disableSurveyFeedback                          = $Parameters.DisableSurveyFeedback
            disableTrialEnvironmentCreationByNonAdminUsers = $Parameters.DisableTrialEnvironmentCreationByNonAdminUsers
            powerPlatform                                  = @{
                powerAutomate          = @{
                    disableCopilotWithBing = $Parameters.DisableCopilotWithBing
                }
                catalogSettings        = @{
                    powerCatalogAudienceSetting = $Parameters.PowerCatalogAudienceSetting
                }
                environments           = @{
                    disablePreferredDataLocationForTeamsEnvironment = $Parameters.DisablePreferredDataLocationForTeamsEnvironment
                }
                helpSupportSettings    = @{
                    disableHelpSupportCopilot      = $Parameters.DisableHelpSupportCopilot
                    useSupportBingSearchByAllUsers = $Parameters.UseSupportBingSearchByAllUsers
                }
                teamsIntegration       = @{
                    shareWithColleaguesUserLimit = $Parameters.ShareWithColleaguesUserLimit
                }
                powerApps              = @{
                    disableShareWithEveryone             = $Parameters.DisableShareWithEveryone
                    enableGuestsToMake                   = $Parameters.EnableGuestsToMake
                    disableMakerMatch                    = $Parameters.DisableMakerMatch
                    disableUnusedLicenseAssignment       = $Parameters.DisableUnusedLicenseAssignment
                    disableCreateFromImage               = $Parameters.DisableCreateFromImage
                    disableCreateFromFigma               = $Parameters.DisableCreateFromFigma
                    enableCanvasAppInsights              = $Parameters.EnableCanvasAppInsights
                    disableConnectionSharingWithEveryone = $Parameters.DisableConnectionSharingWithEveryone
                    allowNewOrgChannelDefault            = $Parameters.AllowNewOrgChannelDefault
                    disableCopilot                       = $Parameters.DisableCopilot
                }
                search                 = @{
                    disableDocsSearch      = $Parameters.DisableDocsSearch
                    disableCommunitySearch = $Parameters.DisableCommunitySearch
                    disableBingVideoSearch = $Parameters.DisableBingVideoSearch
                }
                userManagementSettings = @{
                    enableDeleteDisabledUserinAllEnvironments = $Parameters.EnableDeleteDisabledUserinAllEnvironments
                }
                powerPages             = @{
                    enableGenerativeAIFeaturesForSiteUsers            = $Parameters.EnableGenerativeAIFeaturesForSiteUsers
                    enableExternalAuthenticationProvidersInPowerPages = $Parameters.EnableExternalAuthenticationProvidersInPowerPages
                }
                modelExperimentation   = @{
                    enableModelDataSharing = $Parameters.EnableModelDataSharing
                    disableDataLogging     = $Parameters.DisableDataLogging
                }
                intelligence           = @{
                    disableCopilotFeedback         = $Parameters.DisableCopilotFeedback
                    enableOpenAiBotPublishing      = $Parameters.EnableOpenAiBotPublishing
                    disableCopilotFeedbackMetadata = $Parameters.DisableCopilotFeedbackMetadata
                    disableAiPrompts               = $Parameters.DisableAiPrompts
                }
                licensing              = @{
                    disableBillingPolicyCreationByNonAdminUsers     = $Parameters.DisableBillingPolicyCreationByNonAdminUsers
                    enableTenantCapacityReportForEnvironmentAdmins  = $Parameters.EnableTenantCapacityReportForEnvironmentAdmins
                    storageCapacityConsumptionWarningThreshold      = $Parameters.StorageCapacityConsumptionWarningThreshold
                    enableTenantLicensingReportForEnvironmentAdmins = $Parameters.EnableTenantLicensingReportForEnvironmentAdmins
                    disableUseOfUnassignedAIBuilderCredits          = $Parameters.DisableUseOfUnassignedAIBuilderCredits
                }
                champions              = @{
                    disableChampionsInvitationReachout   = $Parameters.DisableChampionsInvitationReachout
                    disableSkillsMatchInvitationReachout = $Parameters.DisableSkillsMatchInvitationReachout
                }
                gccCommercialSettings  = @{}
            }
        }

        $governance = @{
            disableAdminDigest                                 = $Parameters.DisableAdminDigest
            disableDeveloperEnvironmentCreationByNonAdminUsers = $Parameters.DisableDeveloperEnvironmentCreationByNonAdminUsers
            enableDefaultEnvironmentRouting                    = $Parameters.EnableDefaultEnvironmentRouting
            environmentRoutingAllMakers                        = $Parameters.EnvironmentRoutingAllMakers
        }

        if ($null -ne $Parameters.EnableDesktopFlowDataPolicyManagement)
        {
            $policy = @{
                enableDesktopFlowDataPolicyManagement = $Parameters.EnableDesktopFlowDataPolicyManagement
            }
            $governance.Add('policy', $policy)
        }
        $result.powerplatform.Add('governance', $governance)

        return $result
    }

    hidden [PPTenantSettings] AsResult([System.Object] $Values)
    {
        if ($Values -is [PPTenantSettings])
        {
            return $Values
        }

        $result = [PPTenantSettings]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
