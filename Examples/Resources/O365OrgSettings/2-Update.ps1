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
        O365OrgSettings 'O365OrgSettings-Example'
        {
            AdminCenterReportDisplayConcealedNames                = $true;
            AllowPlannerCopilot                                   = $true;
            AppsAndServicesIsAppAndServicesTrialEnabled           = $false;
            AppsAndServicesIsOfficeStoreEnabled                   = $false;
            CortanaEnabled                                        = $false;
            DynamicsCustomerVoiceIsInOrgFormsPhishingScanEnabled  = $true;
            DynamicsCustomerVoiceIsRecordIdentityByDefaultEnabled = $true;
            DynamicsCustomerVoiceIsRestrictedSurveyAccessEnabled  = $true;
            FormsIsBingImageSearchEnabled                         = $false;
            FormsIsExternalSendFormEnabled                        = $false;
            FormsIsExternalShareCollaborationEnabled              = $false;
            FormsIsExternalShareResultEnabled                     = $false;
            FormsIsExternalShareTemplateEnabled                   = $false;
            FormsIsInOrgFormsPhishingScanEnabled                  = $true;
            FormsIsRecordIdentityByDefaultEnabled                 = $true;
            InstallationOptionsAppsForMac                         = @("isMicrosoft365AppsEnabled");
            InstallationOptionsAppsForWindows                     = @("isVisioEnabled", "isProjectEnabled", "isMicrosoft365AppsEnabled");
            InstallationOptionsUpdateChannel                      = "monthlyEnterprise";
            IsSingleInstance                                      = "Yes";
            M365WebEnableUsersToOpenFilesFrom3PStorage            = $false;
            PlannerAllowCalendarSharing                           = $false;
            ToDoIsExternalJoinEnabled                             = $false;
            ToDoIsExternalShareEnabled                            = $false;
            ToDoIsPushNotificationEnabled                         = $true;
            VivaInsightsDigestEmail                               = $true;
            VivaInsightsOutlookAddInAndInlineSuggestions          = $true;
            VivaInsightsScheduleSendSuggestions                   = $true;
            VivaInsightsWebExperience                             = $true
            ApplicationId                                         = $ApplicationId;
            TenantId                                              = $TenantId;
            CertificateThumbprint                                 = $CertificateThumbprint;
        }
    }
}
