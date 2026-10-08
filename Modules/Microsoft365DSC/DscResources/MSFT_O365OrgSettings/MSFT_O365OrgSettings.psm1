using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class O365OrgSettings : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('Specifies the resource is a single instance, the value must be ''Yes''')]
    [ValidateSet('Yes')]
    [System.String] $IsSingleInstance

    [DscProperty()]
    [System.ComponentModel.Description('Allow people in your organization to start trial subscriptions for apps and services that support trials. Admins manage licenses for these trials in the same way as other licenses in your organization. Only admins can upgrade these trials to paid subscriptions, so they won''t affect your billing.')]
    [System.Nullable[System.Boolean]] $AppsAndServicesIsAppAndServicesTrialEnabled

    [DscProperty()]
    [System.ComponentModel.Description('Allow people in your organization to access the Office Store using their work account. The Office Store provides access to apps that aren''t curated or managed by Microsoft.')]
    [System.Nullable[System.Boolean]] $AppsAndServicesIsOfficeStoreEnabled

    [DscProperty()]
    [System.ComponentModel.Description('Allow Cortana in windows 10 (version 1909 and earlier), and the Cortana app on iOS and Android, to access Microsoft-hosted data on behalf of people in your organization.')]
    [System.Nullable[System.Boolean]] $CortanaEnabled

    [DscProperty()]
    [System.ComponentModel.Description('Automatically block any internal surveys that request confidential information. Admins will be notified in the Message Center when a survey is blocked.')]
    [System.Nullable[System.Boolean]] $DynamicsCustomerVoiceIsInOrgFormsPhishingScanEnabled

    [DscProperty()]
    [System.ComponentModel.Description('Capture the first and last names of respondents in your organization that complete a survey. You can still change this for individual surveys.')]
    [System.Nullable[System.Boolean]] $DynamicsCustomerVoiceIsRecordIdentityByDefaultEnabled

    [DscProperty()]
    [System.ComponentModel.Description('Capture the first and last names of respondents in your organization that complete a survey. You can still change this for individual surveys.')]
    [System.Nullable[System.Boolean]] $DynamicsCustomerVoiceIsRestrictedSurveyAccessEnabled

    [DscProperty()]
    [System.ComponentModel.Description('Allow YouTube and Bing.')]
    [System.Nullable[System.Boolean]] $FormsIsBingImageSearchEnabled

    [DscProperty()]
    [System.ComponentModel.Description('External Sharing - Send a link to the form and collect responses.')]
    [System.Nullable[System.Boolean]] $FormsIsExternalSendFormEnabled

    [DscProperty()]
    [System.ComponentModel.Description('External Sharing - Share to collaborate on the form layout and structure.')]
    [System.Nullable[System.Boolean]] $FormsIsExternalShareCollaborationEnabled

    [DscProperty()]
    [System.ComponentModel.Description('External Sharing - Share form result summary.')]
    [System.Nullable[System.Boolean]] $FormsIsExternalShareResultEnabled

    [DscProperty()]
    [System.ComponentModel.Description('External Sharing - Share the form as a template that can be duplicated.')]
    [System.Nullable[System.Boolean]] $FormsIsExternalShareTemplateEnabled

    [DscProperty()]
    [System.ComponentModel.Description('Phishing protection.')]
    [System.Nullable[System.Boolean]] $FormsIsInOrgFormsPhishingScanEnabled

    [DscProperty()]
    [System.ComponentModel.Description('Record names of people in your org.')]
    [System.Nullable[System.Boolean]] $FormsIsRecordIdentityByDefaultEnabled

    [DscProperty()]
    [System.ComponentModel.Description('Let users open files stored in third-party storage services in Microsoft 365 on the Web.')]
    [System.Nullable[System.Boolean]] $M365WebEnableUsersToOpenFilesFrom3PStorage

    [DscProperty()]
    [System.ComponentModel.Description('Specifies whether or not to allow users to have access to use the Viva Insights web experience.')]
    [System.Nullable[System.Boolean]] $VivaInsightsWebExperience

    [DscProperty()]
    [System.ComponentModel.Description('Specifies whether or not to allow users to have access to use the Viva Insights digest email feature.')]
    [System.Nullable[System.Boolean]] $VivaInsightsDigestEmail

    [DscProperty()]
    [System.ComponentModel.Description('Specifies whether or not to allow users to have access to use the Viva Insights Outlook add-in and inline suggestions.')]
    [System.Nullable[System.Boolean]] $VivaInsightsOutlookAddInAndInlineSuggestions

    [DscProperty()]
    [System.ComponentModel.Description('Specifies whether or not to allow users to have access to use the Viva Insights schedule send suggestions feature.')]
    [System.Nullable[System.Boolean]] $VivaInsightsScheduleSendSuggestions

    [DscProperty()]
    [System.ComponentModel.Description('Allow Planner users to publish their plans and assigned tasks to Outlook or other calendars through iCalendar feeds.')]
    [System.Nullable[System.Boolean]] $PlannerAllowCalendarSharing

    [DscProperty()]
    [System.ComponentModel.Description('Enables Copilot for Planner.')]
    [System.Nullable[System.Boolean]] $AllowPlannerCopilot

    [DscProperty()]
    [System.ComponentModel.Description('To Do - Allow external users to join.')]
    [System.Nullable[System.Boolean]] $ToDoIsExternalJoinEnabled

    [DscProperty()]
    [System.ComponentModel.Description('To Do - Allow sharing with external users.')]
    [System.Nullable[System.Boolean]] $ToDoIsExternalShareEnabled

    [DscProperty()]
    [System.ComponentModel.Description('To Do - Allow your users to receive push notifications.')]
    [System.Nullable[System.Boolean]] $ToDoIsPushNotificationEnabled

    [DscProperty()]
    [System.ComponentModel.Description('Controls whether or not the Admin Center reports will conceale user, group and site names.')]
    [System.Nullable[System.Boolean]] $AdminCenterReportDisplayConcealedNames

    [DscProperty()]
    [System.ComponentModel.Description('Defines how often you want your users to get feature updates for Microsoft 365 apps installed on devices running Windows')]
    [ValidateSet('current', 'monthlyEnterprise', 'semiAnnual')]
    [System.String] $InstallationOptionsUpdateChannel

    [DscProperty()]
    [System.ComponentModel.Description('Defines the apps users can install on Windows and mobile devices.')]
    [ValidateSet('isVisioEnabled', 'isSkypeForBusinessEnabled', 'isProjectEnabled', 'isMicrosoft365AppsEnabled')]
    [System.String[]] $InstallationOptionsAppsForWindows

    [DscProperty()]
    [System.ComponentModel.Description('Defines the apps users can install on Mac devices.')]
    [ValidateSet('isSkypeForBusinessEnabled', 'isMicrosoft365AppsEnabled')]
    [System.String[]] $InstallationOptionsAppsForMac

    [DscProperty()]
    [System.ComponentModel.Description('Credentials of the Global Admin')]
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
    [System.ComponentModel.Description('Access token used for authentication.')]
    [System.String[]] $AccessTokens

    [O365OrgSettings] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [O365OrgSettings]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message 'Getting configuration of Office 365 Org Settings'

        try
        {
            $null = $this.Connect('ExchangeOnline')

            $null = $this.Connect('MicrosoftGraph')

            $ConnectionModeTasks = $this.Connect('Tasks')

            #Ensure the proper dependencies are installed in the current environment.
            Confirm-M365DSCDependencies

            #region Telemetry
            $this.AddTelemetry('Get')
            #endregion

            $results = @{
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

            if ($this.GetBoundParameters().ContainsKey('M365WebEnableUsersToOpenFilesFrom3PStorage') -or `
                    $this.ExportedInstance)
            {
                $OfficeOnline3rdPtyStorageAppId = 'c1f33bc0-bdb4-4248-ba9b-096807ddb43e'
                $M365WebEnableUsersToOpenFilesFrom3PStorageValue = Get-MgServicePrincipal -Filter "appId eq '$OfficeOnline3rdPtyStorageAppId'" -Property 'AccountEnabled' -ErrorAction SilentlyContinue
                if ($null -eq $M365WebEnableUsersToOpenFilesFrom3PStorageValue)
                {
                    Write-Verbose -Message 'Registering the Office on the web Service Principal'
                    New-MgServicePrincipal -AppId $OfficeOnline3rdPtyStorageAppId -ErrorAction Stop | Out-Null
                    $M365WebEnableUsersToOpenFilesFrom3PStorageValue = Invoke-M365DSCCommand -ScriptBlock {
                        Get-MgServicePrincipal -Filter "appId eq '$OfficeOnline3rdPtyStorageAppId'" -Property 'AccountEnabled' -ErrorAction Stop
                    } -RetryOnNotFoundError
                }

                if ($null -ne $M365WebEnableUsersToOpenFilesFrom3PStorageValue)
                {
                    $results += @{
                        M365WebEnableUsersToOpenFilesFrom3PStorage = $M365WebEnableUsersToOpenFilesFrom3PStorageValue.AccountEnabled
                    }
                }
            }

            # Planner iCal settings
            if ($this.GetBoundParameters().ContainsKey('PlannerAllowCalendarSharing') -or `
                    $this.GetBoundParameters().ContainsKey('AllowPlannerCopilot') -or `
                    $this.ExportedInstance)
            {
                $PlannerSettings = Invoke-M365DSCCommand -ScriptBlock { $this.GetPlannerConfig() } -RetryOnNotFoundError
                if ($null -ne $PlannerSettings)
                {
                    $results += @{
                        PlannerAllowCalendarSharing = $PlannerSettings.allowCalendarSharing
                        AllowPlannerCopilot         = $PlannerSettings.allowPlannerCopilot
                    }
                }
            }

            # Cortana settings
            if ($this.GetBoundParameters().ContainsKey('CortanaEnabled') -or `
                    $this.ExportedInstance)
            {
                $CortanaId = '0a0a29f9-0a25-49c7-94bf-c53c3f8fa69d'
                $CortanaEnabledValue = Get-MgServicePrincipal -Filter "appId eq '$CortanaId'" -Property 'AccountEnabled'
                if ($null -ne $CortanaEnabledValue)
                {
                    $results += @{
                        CortanaEnabled = $CortanaEnabledValue.AccountEnabled
                    }
                }
            }

            # Viva Insights settings
            if ($this.GetBoundParameters().ContainsKey('VivaInsightsDigestEmail') -or `
                    $this.GetBoundParameters().ContainsKey('VivaInsightsOutlookAddInAndInlineSuggestions') -or `
                    $this.GetBoundParameters().ContainsKey('VivaInsightsScheduleSendSuggestions') -or `
                    $this.GetBoundParameters().ContainsKey('VivaInsightsWebExperience') -or `
                    $this.ExportedInstance)
            {
                try
                {
                    $currentVivaInsightsSettings = Invoke-M365DSCCommand -ScriptBlock { Get-DefaultTenantMyAnalyticsFeatureConfig } -RetryOnNotFoundError
                    if ($null -ne $currentVivaInsightsSettings)
                    {
                        $results += @{
                            VivaInsightsDigestEmail                      = $currentVivaInsightsSettings.IsDigestEmailEnabled
                            VivaInsightsOutlookAddInAndInlineSuggestions = $currentVivaInsightsSettings.IsAddInEnabled
                            VivaInsightsScheduleSendSuggestions          = $currentVivaInsightsSettings.IsScheduleSendEnabled
                            VivaInsightsWebExperience                    = $currentVivaInsightsSettings.IsDashboardEnabled
                        }
                    }
                }
                catch
                {
                    if ($_.Exception.Message -like '*The following authorization requirements are not satisfied*')
                    {
                        Write-Warning -Message "Exporting Viva Insights configuration requires either Exchange Administrator, Insights Administrator or Global Administrator."
                    }
                }
            }

            $MRODeviceManagerService = 'ebe0c285-db95-403f-a1a3-a793bd6d7767'
            try
            {
                $servicePrincipal = Get-MgServicePrincipal -Filter "appid eq '$($MRODeviceManagerService)'"
                if ($null -eq $servicePrincipal)
                {
                    Write-Verbose -Message 'Registering the MRO Device Manager Service Principal'
                    New-MgServicePrincipal -AppId $MRODeviceManagerService -ErrorAction Stop | Out-Null
                }
            }
            catch
            {
                Write-Verbose -Message $_
            }

            # Reports Display Settings
            if ($this.GetBoundParameters().ContainsKey('AdminCenterReportDisplayConcealedNames') -or `
                    $this.ExportedInstance)
            {
                $AdminCenterReportDisplayConcealedNamesValue = Invoke-M365DSCCommand -ScriptBlock { $this.GetOrgSettingsAdminCenterReport() } -RetryOnNotFoundError
                if ($null -ne $AdminCenterReportDisplayConcealedNamesValue)
                {
                    $results += @{
                        AdminCenterReportDisplayConcealedNames = $AdminCenterReportDisplayConcealedNamesValue.displayConcealedNames
                    }
                }
            }

            # Installation Options
            if ($this.GetBoundParameters().ContainsKey('InstallationOptionsUpdateChannel') -or `
                    $this.GetBoundParameters().ContainsKey('InstallationOptionsAppsForWindows') -or `
                    $this.GetBoundParameters().ContainsKey('InstallationOptionsAppsForMac') -or `
                    $this.ExportedInstance)
            {
                $installationOptions = Invoke-M365DSCCommand -ScriptBlock { $this.GetOrgSettingsInstallationOptions($ConnectionModeTasks) } -RetryOnNotFoundError
                if ($null -ne $installationOptions)
                {
                    $appsForWindowsValue = @()
                    foreach ($key in $installationOptions.appsForWindows.Keys)
                    {
                        if ($installationOptions.appsForWindows.$key)
                        {
                            $appsForWindowsValue += $key
                        }
                    }
                    $appsForMacValue = @()
                    foreach ($key in $installationOptions.appsForMac.Keys)
                    {
                        if ($installationOptions.appsForMac.$key)
                        {
                            $appsForMacValue += $key
                        }
                    }

                    $results += @{
                        InstallationOptionsUpdateChannel  = $installationOptions.updateChannel
                        InstallationOptionsAppsForWindows = @($appsForWindowsValue | Sort-Object)
                        InstallationOptionsAppsForMac     = @($appsForMacValue | Sort-Object)
                    }
                }
            }

            # Forms
            if ($this.GetBoundParameters().ContainsKey('FormsIsExternalSendFormEnabled') -or `
                    $this.GetBoundParameters().ContainsKey('FormsIsExternalShareCollaborationEnabled') -or `
                    $this.GetBoundParameters().ContainsKey('FormsIsExternalShareResultEnabled') -or `
                    $this.GetBoundParameters().ContainsKey('FormsIsExternalShareTemplateEnabled') -or `
                    $this.GetBoundParameters().ContainsKey('FormsIsRecordIdentityByDefaultEnabled') -or `
                    $this.GetBoundParameters().ContainsKey('FormsIsBingImageSearchEnabled') -or `
                    $this.GetBoundParameters().ContainsKey('FormsIsInOrgFormsPhishingScanEnabled') -or `
                    $this.ExportedInstance)
            {
                $FormsSettings = Invoke-M365DSCCommand -ScriptBlock { $this.GetOrgSettingsForms() } -RetryOnNotFoundError
                if ($null -ne $FormsSettings)
                {
                    $results += @{
                        FormsIsExternalSendFormEnabled           = $FormsSettings.isExternalSendFormEnabled
                        FormsIsExternalShareCollaborationEnabled = $FormsSettings.isExternalShareCollaborationEnabled
                        FormsIsExternalShareResultEnabled        = $FormsSettings.isExternalShareResultEnabled
                        FormsIsExternalShareTemplateEnabled      = $FormsSettings.isExternalShareTemplateEnabled
                        FormsIsRecordIdentityByDefaultEnabled    = $FormsSettings.isRecordIdentityByDefaultEnabled
                        FormsIsBingImageSearchEnabled            = $FormsSettings.isBingImageSearchEnabled
                        FormsIsInOrgFormsPhishingScanEnabled     = $FormsSettings.isInOrgFormsPhishingScanEnabled
                    }
                }
            }

            # DynamicsCustomerVoice
            if ($this.GetBoundParameters().ContainsKey('DynamicsCustomerVoiceIsRestrictedSurveyAccessEnabled') -or `
                    $this.GetBoundParameters().ContainsKey('DynamicsCustomerVoiceIsRecordIdentityByDefaultEnabled') -or `
                    $this.GetBoundParameters().ContainsKey('DynamicsCustomerVoiceIsInOrgFormsPhishingScanEnabled') -or `
                    $this.ExportedInstance)
            {
                $DynamicCustomerVoiceSettings = Invoke-M365DSCCommand -ScriptBlock { $this.GetOrgSettingsDynamicsCustomerVoice() } -RetryOnNotFoundError
                if ($null -ne $DynamicCustomerVoiceSettings)
                {
                    $results += @{
                        DynamicsCustomerVoiceIsRestrictedSurveyAccessEnabled  = $DynamicCustomerVoiceSettings.isRestrictedSurveyAccessEnabled
                        DynamicsCustomerVoiceIsRecordIdentityByDefaultEnabled = $DynamicCustomerVoiceSettings.isRecordIdentityByDefaultEnabled
                        DynamicsCustomerVoiceIsInOrgFormsPhishingScanEnabled  = $DynamicCustomerVoiceSettings.isInOrgFormsPhishingScanEnabled
                    }
                }
            }

            # Apps and Services
            if ($this.GetBoundParameters().ContainsKey('AppsAndServicesIsOfficeStoreEnabled') -or `
                    $this.GetBoundParameters().ContainsKey('AppsAndServicesIsAppAndServicesTrialEnabled') -or `
                    $this.ExportedInstance)
            {
                $AppsAndServicesSettings = Invoke-M365DSCCommand -ScriptBlock { $this.GetOrgSettingsAppsAndServices() } -RetryOnNotFoundError
                if ($null -ne $AppsAndServicesSettings)
                {
                    $results += @{
                        AppsAndServicesIsOfficeStoreEnabled         = $AppsAndServicesSettings.isOfficeStoreEnabled
                        AppsAndServicesIsAppAndServicesTrialEnabled = $AppsAndServicesSettings.IsAppAndServicesTrialEnabled
                    }
                }
            }

            # To do
            if ($this.GetBoundParameters().ContainsKey('ToDoIsPushNotificationEnabled') -or `
                    $this.GetBoundParameters().ContainsKey('ToDoIsExternalJoinEnabled') -or `
                    $this.GetBoundParameters().ContainsKey('ToDoIsExternalShareEnabled') -or `
                    $this.ExportedInstance)
            {
                $ToDoSettings = Invoke-M365DSCCommand -ScriptBlock { $this.GetOrgSettingsToDo() } -RetryOnNotFoundError
                if ($null -ne $ToDoSettings)
                {
                    $results += @{
                        ToDoIsPushNotificationEnabled = $ToDoSettings.IsPushNotificationEnabled
                        ToDoIsExternalJoinEnabled     = $ToDoSettings.IsExternalJoinEnabled
                        ToDoIsExternalShareEnabled    = $ToDoSettings.IsExternalShareEnabled
                    }
                }
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

        Write-Verbose -Message 'Setting configuration of Office 365 Org Settings'

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $null = $this.Connect('MicrosoftGraph')
        $currentValues = $this.Get().ToHashtable()

        if ($this.GetBoundParameters().ContainsKey('M365WebEnableUsersToOpenFilesFrom3PStorage') -and `
            ($this.M365WebEnableUsersToOpenFilesFrom3PStorage -ne $currentValues.M365WebEnableUsersToOpenFilesFrom3PStorage))
        {
            Write-Verbose -Message "Updating the Microsoft 365 On the Web setting to {$($this.M365WebEnableUsersToOpenFilesFrom3PStorage)}"
            $OfficeOnlineId = 'c1f33bc0-bdb4-4248-ba9b-096807ddb43e'
            $M365WebEnableUsersToOpenFilesFrom3PStorageValue = Get-MgServicePrincipal -Filter "appId eq '$OfficeOnlineId'" -Property 'AccountEnabled, Id'
            Invoke-M365DSCCommand -ScriptBlock {
                Update-MgServicePrincipal -ServicePrincipalId $($M365WebEnableUsersToOpenFilesFrom3PStorageValue.Id) `
                -BodyParameter @{ accountEnabled = $this.M365WebEnableUsersToOpenFilesFrom3PStorage }
            } -RetryOnNotFoundError
        }
        if (($this.GetBoundParameters().ContainsKey('PlannerAllowCalendarSharing') -and `
                ($this.PlannerAllowCalendarSharing -ne $currentValues.PlannerAllowCalendarSharing)) -or `
            ($this.GetBoundParameters().ContainsKey('AllowPlannerCopilot') -and `
                ($this.AllowPlannerCopilot -ne $currentValues.AllowPlannerCopilot)))
        {
            Write-Verbose -Message "Updating the Planner Allow Calendar Sharing setting to {$($this.PlannerAllowCalendarSharing)}"
            Invoke-M365DSCCommand -ScriptBlock {
                $this.SetPlannerConfig($this.PlannerAllowCalendarSharing, $this.AllowPlannerCopilot)
            } -RetryOnNotFoundError
        }

        if ($this.GetBoundParameters().ContainsKey('CortanaEnabled') -and `
            ($this.CortanaEnabled -ne $currentValues.CortanaEnabled))
        {
            $CortanaId = '0a0a29f9-0a25-49c7-94bf-c53c3f8fa69d'
            $CortanaEnabledValue = Get-MgServicePrincipal -Filter "appId eq '$CortanaId'" -Property 'AccountEnabled, Id'

            if ($null -ne $CortanaEnabledValue.Id)
            {
                Write-Verbose -Message "Updating the Cortana setting to {$($this.CortanaEnabled)}"
                Update-MgServicePrincipal -ServicePrincipalId $($CortanaEnabledValue.Id) `
                    -BodyParameter @{ accountEnabled = $this.CortanaEnabled }
            }
        }

        # Viva Insights
        if ($this.GetBoundParameters().ContainsKey('VivaInsightsWebExperience') -and `
            ($currentValues.VivaInsightsWebExperience -ne $this.VivaInsightsWebExperience))
        {
            Write-Verbose -Message 'Updating Viva Insights settings for Web Experience'
            Invoke-M365DSCCommand -ScriptBlock {
                Set-DefaultTenantMyAnalyticsFeatureConfig -Feature 'Dashboard' -IsEnabled $this.VivaInsightsWebExperience | Out-Null
            } -RetryOnNotFoundError
        }

        if ($this.GetBoundParameters().ContainsKey('VivaInsightsDigestEmail') -and `
            ($currentValues.VivaInsightsDigestEmail -ne $this.VivaInsightsDigestEmail))
        {
            Write-Verbose -Message 'Updating Viva Insights settings for Digest Email'
            Invoke-M365DSCCommand -ScriptBlock {
                Set-DefaultTenantMyAnalyticsFeatureConfig -Feature 'Digest-email' -IsEnabled $this.VivaInsightsDigestEmail | Out-Null
            } -RetryOnNotFoundError
        }

        if ($this.GetBoundParameters().ContainsKey('VivaInsightsOutlookAddInAndInlineSuggestions') -and `
            ($currentValues.VivaInsightsOutlookAddInAndInlineSuggestions -ne $this.VivaInsightsOutlookAddInAndInlineSuggestions))
        {
            Write-Verbose -Message 'Updating Viva Insights settings for Addin and Inline Suggestions'
            Invoke-M365DSCCommand -ScriptBlock {
                Set-DefaultTenantMyAnalyticsFeatureConfig -Feature 'Add-In' -IsEnabled $this.VivaInsightsOutlookAddInAndInlineSuggestions | Out-Null
            } -RetryOnNotFoundError
        }

        if ($this.GetBoundParameters().ContainsKey('VivaInsightsScheduleSendSuggestions') -and `
            ($currentValues.VivaInsightsScheduleSendSuggestions -ne $this.VivaInsightsScheduleSendSuggestions))
        {
            Write-Verbose -Message 'Updating Viva Insights settings for ScheduleSendSuggestions'
            Invoke-M365DSCCommand -ScriptBlock {
                Set-DefaultTenantMyAnalyticsFeatureConfig -Feature 'Scheduled-send' -IsEnabled $this.VivaInsightsScheduleSendSuggestions | Out-Null
            } -RetryOnNotFoundError
        }

        # Reports Display Names
        $AdminCenterReportDisplayConcealedNamesEnabled = $this.GetOrgSettingsAdminCenterReport()
        if ($this.GetBoundParameters().ContainsKey('AdminCenterReportDisplayConcealedNames') -and `
            ($this.AdminCenterReportDisplayConcealedNames -ne $AdminCenterReportDisplayConcealedNamesEnabled.displayConcealedNames))
        {
            Write-Verbose -Message "Updating the Admin Center Report Display Concealed Names setting to {$($this.AdminCenterReportDisplayConcealedNames)}"
            Invoke-M365DSCCommand -ScriptBlock {
                $this.UpdateOrgSettingsAdminCenterReport($this.AdminCenterReportDisplayConcealedNames)
            } -RetryOnNotFoundError
        }

        # Apps Installation
        if (($this.GetBoundParameters().ContainsKey('InstallationOptionsAppsForWindows') -and `
            ($null -ne (Compare-Object -ReferenceObject $currentValues.InstallationOptionsAppsForWindows -DifferenceObject $this.InstallationOptionsAppsForWindows))) `
        -or ($this.GetBoundParameters().ContainsKey('InstallationOptionsAppsForMac') -and `
            ($null -ne (Compare-Object -ReferenceObject $currentValues.InstallationOptionsAppsForMac -DifferenceObject $this.InstallationOptionsAppsForMac))))
        {
            $ConnectionModeTasks = $this.Connect('Tasks')
            $InstallationOptions = Invoke-M365DSCCommand -ScriptBlock { $this.GetOrgSettingsInstallationOptions($ConnectionModeTasks) } -RetryOnNotFoundError
            $InstallationOptionsToUpdate = @{
                updateChannel  = ''
                appsForWindows = @{
                    isMicrosoft365AppsEnabled = $false
                    isProjectEnabled          = $false
                    isSkypeForBusinessEnabled = $false
                    isVisioEnabled            = $false
                }
                appsForMac     = @{
                    isMicrosoft365AppsEnabled = $false
                    isSkypeForBusinessEnabled = $false
                }
            }

            if ($this.GetBoundParameters().ContainsKey('InstallationOptionsUpdateChannel') -and `
                ($this.InstallationOptionsUpdateChannel -ne $InstallationOptions.updateChannel))
            {
                $InstallationOptionsToUpdate.updateChannel = $this.InstallationOptionsUpdateChannel
            }
            else
            {
                $InstallationOptionsToUpdate.Remove('updateChannel') | Out-Null
            }

            if ($this.GetBoundParameters().ContainsKey('InstallationOptionsAppsForWindows'))
            {
                foreach ($key in $this.InstallationOptionsAppsForWindows)
                {
                    $InstallationOptionsToUpdate.appsForWindows.$key = $true
                }
            }
            else
            {
                $InstallationOptionsToUpdate.Remove('appsForWindows') | Out-Null
            }

            if ($this.GetBoundParameters().ContainsKey('InstallationOptionsAppsForMac'))
            {
                foreach ($key in $this.InstallationOptionsAppsForMac)
                {
                    $InstallationOptionsToUpdate.appsForMac.$key = $true
                }
            }
            else
            {
                $InstallationOptionsToUpdate.Remove('appsForMac') | Out-Null
            }

            if ($InstallationOptionsToUpdate.Keys.Count -gt 0)
            {
                Write-Verbose -Message "Updating O365 Installation Options with $(Convert-M365DscHashtableToString -Hashtable $InstallationOptionsToUpdate)"
                Invoke-M365DSCCommand -ScriptBlock {
                    $this.UpdateOrgSettingsInstallationOptions($InstallationOptionsToUpdate, $ConnectionModeTasks)
                } -RetryOnNotFoundError
            }
        }

        # Forms
        $FormsParametersToUpdate = @{}
        if ($this.GetBoundParameters().ContainsKey('FormsIsExternalSendFormEnabled') -and `
            ($this.FormsIsExternalSendFormEnabled -ne $currentValues.FormsIsExternalSendFormEnabled))
        {
            $FormsParametersToUpdate.Add('isExternalSendFormEnabled', $this.FormsIsExternalSendFormEnabled)
        }
        if ($this.GetBoundParameters().ContainsKey('FormsIsExternalShareCollaborationEnabled') -and `
            ($this.FormsIsExternalShareCollaborationEnabled -ne $currentValues.FormsIsExternalShareCollaborationEnabled))
        {
            $FormsParametersToUpdate.Add('isExternalShareCollaborationEnabled', $this.FormsIsExternalShareCollaborationEnabled)
        }
        if ($this.GetBoundParameters().ContainsKey('FormsIsExternalShareResultEnabled') -and `
            ($this.FormsIsExternalShareResultEnabled -ne $currentValues.FormsIsExternalShareResultEnabled))
        {
            $FormsParametersToUpdate.Add('isExternalShareResultEnabled', $this.FormsIsExternalShareResultEnabled)
        }
        if ($this.GetBoundParameters().ContainsKey('FormsIsExternalShareTemplateEnabled') -and `
            ($this.FormsIsExternalShareTemplateEnabled -ne $currentValues.FormsIsExternalShareTemplateEnabled))
        {
            $FormsParametersToUpdate.Add('isExternalShareTemplateEnabled', $this.FormsIsExternalShareTemplateEnabled)
        }
        if ($this.GetBoundParameters().ContainsKey('FormsIsRecordIdentityByDefaultEnabled') -and `
            ($this.FormsIsRecordIdentityByDefaultEnabled -ne $currentValues.FormsIsRecordIdentityByDefaultEnabled))
        {
            $FormsParametersToUpdate.Add('isRecordIdentityByDefaultEnabled', $this.FormsIsRecordIdentityByDefaultEnabled)
        }
        if ($this.GetBoundParameters().ContainsKey('FormsIsBingImageSearchEnabled') -and `
            ($this.FormsIsBingImageSearchEnabled -ne $currentValues.FormsIsBingImageSearchEnabled))
        {
            $FormsParametersToUpdate.Add('isBingImageSearchEnabled', $this.FormsIsBingImageSearchEnabled)
        }
        if ($this.GetBoundParameters().ContainsKey('FormsIsInOrgFormsPhishingScanEnabled') -and `
            ($this.FormsIsInOrgFormsPhishingScanEnabled -ne $currentValues.FormsIsInOrgFormsPhishingScanEnabled))
        {
            $FormsParametersToUpdate.Add('isInOrgFormsPhishingScanEnabled', $this.FormsIsInOrgFormsPhishingScanEnabled)
        }
        if ($FormsParametersToUpdate.Keys.Count -gt 0)
        {
            Write-Verbose -Message "Updating the Microsoft Forms settings with values:$(Convert-M365DscHashtableToString -Hashtable $FormsParametersToUpdate)"
            Invoke-M365DSCCommand -ScriptBlock {
                $this.UpdateOrgSettingsForms($FormsParametersToUpdate)
            } -RetryOnNotFoundError
        }

        # Dynamics Customer Voice Settings
        $DynamicsCustomerVoiceParametersToUpdate = @{}
        if ($this.GetBoundParameters().ContainsKey('DynamicsCustomerVoiceIsRestrictedSurveyAccessEnabled') -and `
            ($this.DynamicsCustomerVoiceIsRestrictedSurveyAccessEnabled -ne $currentValues.DynamicsCustomerVoiceIsRestrictedSurveyAccessEnabled))
        {
            $DynamicsCustomerVoiceParametersToUpdate.Add('isRestrictedSurveyAccessEnabled', $this.DynamicsCustomerVoiceIsRestrictedSurveyAccessEnabled)
        }
        if ($this.GetBoundParameters().ContainsKey('DynamicsCustomerVoiceIsRecordIdentityByDefaultEnabled') -and `
            ($this.DynamicsCustomerVoiceIsRecordIdentityByDefaultEnabled -ne $currentValues.DynamicsCustomerVoiceIsRecordIdentityByDefaultEnabled))
        {
            $DynamicsCustomerVoiceParametersToUpdate.Add('isRecordIdentityByDefaultEnabled', $this.DynamicsCustomerVoiceIsRecordIdentityByDefaultEnabled)
        }
        if ($this.GetBoundParameters().ContainsKey('DynamicsCustomerVoiceIsInOrgFormsPhishingScanEnabled') -and `
            ($this.DynamicsCustomerVoiceIsInOrgFormsPhishingScanEnabled -ne $currentValues.DynamicsCustomerVoiceIsInOrgFormsPhishingScanEnabled))
        {
            $DynamicsCustomerVoiceParametersToUpdate.Add('isInOrgFormsPhishingScanEnabled', $this.DynamicsCustomerVoiceIsInOrgFormsPhishingScanEnabled)
        }
        if ($DynamicsCustomerVoiceParametersToUpdate.Keys.Count -gt 0)
        {
            Write-Verbose -Message "Updating the Dynamics 365 Customer Voice settings with values:$(Convert-M365DscHashtableToString -Hashtable $DynamicsCustomerVoiceParametersToUpdate)"
            Invoke-M365DSCCommand -ScriptBlock {
                $this.UpdateOrgSettingsDynamicsCustomerVoice($DynamicsCustomerVoiceParametersToUpdate)
            } -RetryOnNotFoundError
        }

        # Apps And Services
        $AppsAndServicesParametersToUpdate = @{}
        if ($this.GetBoundParameters().ContainsKey('AppsAndServicesIsOfficeStoreEnabled') -and `
            ($this.AppsAndServicesIsOfficeStoreEnabled -ne $currentValues.AppsAndServicesIsOfficeStoreEnabled))
        {
            $AppsAndServicesParametersToUpdate.Add('isOfficeStoreEnabled', $this.AppsAndServicesIsOfficeStoreEnabled)
        }
        if ($this.GetBoundParameters().ContainsKey('AppsAndServicesIsAppAndServicesTrialEnabled') -and `
            ($this.AppsAndServicesIsAppAndServicesTrialEnabled -ne $currentValues.AppsAndServicesIsAppAndServicesTrialEnabled))
        {
            $AppsAndServicesParametersToUpdate.Add('isAppAndServicesTrialEnabled', $this.AppsAndServicesIsAppAndServicesTrialEnabled)
        }
        if ($AppsAndServicesParametersToUpdate.Keys.Count -gt 0)
        {
            Write-Verbose -Message "Updating the Apps & Settings settings with values:$(Convert-M365DscHashtableToString -Hashtable $AppsAndServicesParametersToUpdate)"
            Invoke-M365DSCCommand -ScriptBlock {
                $this.UpdateOrgSettingsAppsAndServices($AppsAndServicesParametersToUpdate)
            } -RetryOnNotFoundError
        }

        # To Do
        $ToDoParametersToUpdate = @{}
        if ($this.GetBoundParameters().ContainsKey('ToDoIsPushNotificationEnabled') -and `
            ($this.ToDoIsPushNotificationEnabled -ne $currentValues.ToDoIsPushNotificationEnabled))
        {
            $ToDoParametersToUpdate.Add('isPushNotificationEnabled', $this.ToDoIsPushNotificationEnabled)
        }
        if ($this.GetBoundParameters().ContainsKey('ToDoIsExternalJoinEnabled') -and `
            ($this.ToDoIsExternalJoinEnabled -ne $currentValues.ToDoIsExternalJoinEnabled))
        {
            $ToDoParametersToUpdate.Add('isExternalJoinEnabled', $this.ToDoIsExternalJoinEnabled)
        }
        if ($this.GetBoundParameters().ContainsKey('ToDoIsExternalShareEnabled') -and `
            ($this.ToDoIsExternalShareEnabled -ne $currentValues.ToDoIsExternalShareEnabled))
        {
            $ToDoParametersToUpdate.Add('isExternalShareEnabled', $this.ToDoIsExternalShareEnabled)
        }
        if ($ToDoParametersToUpdate.Keys.Count -gt 0)
        {
            Write-Verbose -Message "Updating the To Do settings with values:$(Convert-M365DscHashtableToString -Hashtable $ToDoParametersToUpdate)"
            Invoke-M365DSCCommand -ScriptBlock {
                $this.UpdateOrgSettingsToDo($ToDoParametersToUpdate)
            } -RetryOnNotFoundError
        }
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

        $null = $this.Connect('ExchangeOnline')

        $ConnectionMode = $this.Connect('MicrosoftGraph')

        $null = $this.Connect('Tasks')

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Export')

        try
        {
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

            $this.ExportedInstance = $true
            $Results = $this.GetForExport($Params)
            $dscContent = [System.Text.StringBuilder]::new()
            $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                -ConnectionMode $ConnectionMode `
                -ModulePath $this.GetModulePath() `
                -Results $Results `
                -Credential $this.Credential
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

    hidden [System.Collections.Hashtable] GetOrgSettingsDynamicsCustomerVoice()
    {
        try
        {
            $url = '/beta/admin/dynamics/customerVoice'
            $results = Invoke-M365DSCGraphRequest -Method GET -Uri $url -ErrorAction Stop
            return $results
        }
        catch
        {
            Write-Verbose -Message 'Not able to retrieve O365OrgSettings Dynamics Customer Voice Settings. Please ensure correct permissions have been granted.'
            New-M365DSCLogEntry -Message 'Error retrieving O365OrgSettings Dynamics Customer Voice Settings' `
                -Exception $_ `
                -Source 'O365OrgSettings'

            throw
        }
    }

    hidden [System.Collections.Hashtable] GetOrgSettingsToDo()
    {
        try
        {
            $url = '/beta/admin/todo/settings'
            $results = Invoke-M365DSCGraphRequest -Method GET -Uri $url -ErrorAction Stop
            return $results
        }
        catch
        {
            Write-Verbose -Message 'Not able to retrieve ToDo settings. Please ensure correct permissions have been granted.'
            New-M365DSCLogEntry -Message 'Error retrieving O365OrgSettings To Do Settings' `
                -Exception $_ `
                -Source 'O365OrgSettings'

            throw
        }
    }

    hidden [Void] UpdateOrgSettingsAppsAndServices([System.Collections.Hashtable] $Options)
    {
        try
        {
            $url = '/beta/admin/appsAndServices/settings'
            Invoke-M365DSCGraphRequest -Method PATCH -Uri $url -Body $Options | Out-Null
        }
        catch
        {
            New-M365DSCLogEntry -Message 'Error updating O365OrgSettings Apps and Services Settings' `
                -Exception $_ `
                -Source 'O365OrgSettings'

            throw
        }
    }

    hidden [System.Collections.Hashtable] GetOrgSettingsForms()
    {
        try
        {
            $url = '/beta/admin/forms/settings'
            $results = Invoke-M365DSCGraphRequest -Method GET -Uri $url -ErrorAction Stop
            return $results
        }
        catch
        {
            Write-Verbose -Message 'Not able to retrieve O365OrgSettings Forms Settings. Please ensure correct permissions have been granted.'
            New-M365DSCLogEntry -Message 'Error retrieving O365OrgSettings Forms Settings' `
                -Exception $_ `
                -Source 'O365OrgSettings'

            throw
        }
    }

    hidden [Void] UpdateOrgSettingsForms([System.Collections.Hashtable] $Options)
    {
        try
        {
            Write-Verbose -Message 'Updating Forms Settings'
            $url = '/beta/admin/forms/settings'
            Invoke-M365DSCGraphRequest -Method PATCH -Uri $url -Body $Options | Out-Null
        }
        catch
        {
            New-M365DSCLogEntry -Message 'Error updating O365OrgSettings Forms Settings' `
                -Exception $_ `
                -Source 'O365OrgSettings'

            throw
        }
    }

    hidden [System.Collections.Hashtable] GetOrgSettingsAdminCenterReport()
    {
        try
        {
            return Get-MgBetaAdminReportSetting -ErrorAction Stop
        }
        catch
        {
            Write-Verbose -Message 'Not able to retrieve Office 365 Report Settings. Please ensure correct permissions have been granted.'
            New-M365DSCLogEntry -Message 'Error retrieving O365OrgSettings Admin Center Report Settings' `
                -Exception $_ `
                -Source 'O365OrgSettings'

            throw
        }
    }

    hidden [Void] SetPlannerConfig([System.Boolean] $AllowCalendarSharing, [System.Boolean] $AllowPlannerCopilot)
    {
        $flags = @{}

        if ($null -ne $AllowCalendarSharing)
        {
            $flags.Add('allowCalendarSharing', $AllowCalendarSharing)
        }
        if ($null -ne $AllowPlannerCopilot)
        {
            $flags.Add('allowPlannerCopilot', $AllowPlannerCopilot)
        }

        if ($flags.Keys.Count -gt 0)
        {
            $requestBody = $flags | ConvertTo-Json
            Write-Verbose -Message "Updating Planner settings with values:`r`n$($requestBody)"
            $Uri = (Get-MSCloudLoginConnectionProfile -Workload Tasks).HostUrl + '/taskAPI/tenantAdminSettings/Settings'
            $results = Invoke-RestMethod -ContentType 'application/json;odata.metadata=full' `
                -Headers @{'Accept' = 'application/json'; 'Authorization' = (Get-MSCloudLoginConnectionProfile -Workload Tasks).AccessToken; 'Accept-Charset' = 'UTF-8'; 'OData-Version' = '4.0;NetFx'; 'OData-MaxVersion' = '4.0;NetFx' } `
                -Method PATCH `
                -Body $requestBody `
                -Uri $Uri
        }
    }

    hidden [Void] UpdateOrgSettingsAdminCenterReport([System.Boolean] $DisplayConcealedNames)
    {
        Update-MgBetaAdminReportSetting -DisplayConcealedNames $DisplayConcealedNames | Out-Null
    }

    hidden [System.Collections.Hashtable] GetOrgSettingsInstallationOptions([System.String] $AuthenticationOption)
    {
        try
        {
            $url = '/beta/admin/microsoft365Apps/installationOptions'
            $results = Invoke-M365DSCGraphRequest -Method GET -Uri $url
            return $results
        }
        catch
        {
            Write-Verbose -Message 'Not able to retrieve Office 365 Apps Installation Options. Please ensure correct permissions have been granted.'
            New-M365DSCLogEntry -Message 'Error retrieving Office 365 Apps Installation Options' `
                -Exception $_ `
                -Source 'O365OrgSettings'

            throw
        }
    }

    hidden [Void] UpdateOrgSettingsInstallationOptions([System.Collections.Hashtable] $Options, [System.String] $AuthenticationOption)
    {
        try
        {
            $url = '/beta/admin/microsoft365Apps/installationOptions'
            Invoke-M365DSCGraphRequest -Method PATCH -Uri $url -Body $Options | Out-Null
        }
        catch
        {
            if ($_.Exception.ToString().Contains('Forbidden (Forbidden)') -and $AuthenticationOption -eq 'Credentials')
            {
                $errorMessage = "You don't have the proper permissions to update the Office 365 Apps Installation Options." `
                    + ' When using Credentials to authenticate, you need to grant permissions to the Microsoft Graph PowerShell SDK by running' `
                    + ' Connect-MgGraph -Scopes OrgSettings-Microsoft365Install.ReadWrite.All'
                throw $errorMessage
            }

            throw
        }
    }

    hidden [Void] UpdateOrgSettingsToDo([System.Collections.Hashtable] $Options)
    {
        try
        {
            $url = '/beta/admin/todo/settings'
            Invoke-M365DSCGraphRequest -Method PATCH -Uri $url -Body $Options | Out-Null
        }
        catch
        {
            Write-Verbose -Message "Error: $($_.Exception.Message)"
            New-M365DSCLogEntry -Message 'Error updating O365OrgSettings To Do Settings' `
                -Exception $_ `
                -Source 'O365OrgSettings'

            throw
        }
    }

    hidden [System.Collections.Hashtable] GetOrgSettingsAppsAndServices()
    {
        try
        {
            $url = '/beta/admin/appsAndServices/settings'
            $results = Invoke-M365DSCGraphRequest -Method GET -Uri $url -ErrorAction Stop
            return $results
        }
        catch
        {
            Write-Verbose -Message 'Not able to retrieve O365OrgSettings Apps and Services Settings. Please ensure correct permissions have been granted.'
            New-M365DSCLogEntry -Message 'Error retrieving O365OrgSettings Apps and Services Settings' `
                -Exception $_ `
                -Source 'O365OrgSettings'

            throw
        }
    }

    hidden [System.Object] GetPlannerConfig()
    {
        try
        {
            $Uri = (Get-MSCloudLoginConnectionProfile -Workload Tasks).HostUrl + '/taskAPI/tenantAdminSettings/Settings'
            [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
            $results = Invoke-RestMethod -ContentType 'application/json;odata.metadata=full' `
                -Headers @{'Accept' = 'application/json'; 'Authorization' = (Get-MSCloudLoginConnectionProfile -Workload Tasks).AccessToken; 'Accept-Charset' = 'UTF-8'; 'OData-Version' = '4.0;NetFx'; 'OData-MaxVersion' = '4.0;NetFx' } `
                -Method GET `
                -Uri $Uri -ErrorAction Stop
            return $results
        }
        catch
        {
            if ($_.Exception.Message -eq 'The request was aborted: Could not create SSL/TLS secure channel.')
            {
                Write-Warning -Message 'Could not create SSL/TLS secure channel. Skipping the Planner settings.'
            }
            else
            {
                Write-Verbose -Message 'Not able to retrieve Office 365 Planner Settings. Please ensure correct permissions have been granted.'
                New-M365DSCLogEntry -Message 'Error retrieving Office 365 Planner Settings' `
                    -Exception $_ `
                    -Source 'O365OrgSettings'
            }
            throw
        }
    }

    hidden [Void] UpdateOrgSettingsDynamicsCustomerVoice([System.Collections.Hashtable] $Options)
    {
        try
        {
            $url = '/beta/admin/dynamics/customerVoice'
            Invoke-M365DSCGraphRequest -Method PATCH -Uri $url -Body $Options | Out-Null
        }
        catch
        {
            New-M365DSCLogEntry -Message 'Error updating O365OrgSettings Dynamics Customer Voice Settings' `
                -Exception $_ `
                -Source 'O365OrgSettings'

            throw
        }
    }

    hidden [O365OrgSettings] AsResult([System.Object] $Values)
    {
        if ($Values -is [O365OrgSettings])
        {
            return $Values
        }

        $result = [O365OrgSettings]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
