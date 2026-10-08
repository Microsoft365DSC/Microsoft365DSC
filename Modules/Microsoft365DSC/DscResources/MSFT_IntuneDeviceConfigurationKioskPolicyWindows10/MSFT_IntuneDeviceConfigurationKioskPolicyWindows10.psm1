using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class IntuneDeviceConfigurationKioskPolicyWindows10 : M365DSCResourceBase
{
    [DscProperty()]
    [System.ComponentModel.Description('Enable public browsing kiosk mode for the Microsoft Edge browser. The Default is false.')]
    [System.Nullable[System.Boolean]] $EdgeKioskEnablePublicBrowsing

    [DscProperty()]
    [System.ComponentModel.Description('Specify URLs that the kiosk browser is allowed to navigate to')]
    [System.String[]] $KioskBrowserBlockedUrlExceptions

    [DscProperty()]
    [System.ComponentModel.Description('Specify URLs that the kiosk browsers should not navigate to')]
    [System.String[]] $KioskBrowserBlockedURLs

    [DscProperty()]
    [System.ComponentModel.Description('Specify the default URL the browser should navigate to on launch.')]
    [System.String] $KioskBrowserDefaultUrl

    [DscProperty()]
    [System.ComponentModel.Description('Enable the kiosk browser''s end session button. By default, the end session button is disabled.')]
    [System.Nullable[System.Boolean]] $KioskBrowserEnableEndSessionButton

    [DscProperty()]
    [System.ComponentModel.Description('Enable the kiosk browser''s home button. By default, the home button is disabled.')]
    [System.Nullable[System.Boolean]] $KioskBrowserEnableHomeButton

    [DscProperty()]
    [System.ComponentModel.Description('Enable the kiosk browser''s navigation buttons(forward/back). By default, the navigation buttons are disabled.')]
    [System.Nullable[System.Boolean]] $KioskBrowserEnableNavigationButtons

    [DscProperty()]
    [System.ComponentModel.Description('Specify the number of minutes the session is idle until the kiosk browser restarts in a fresh state.  Valid values are 1-1440. Valid values 1 to 1440')]
    [System.Nullable[System.UInt32]] $KioskBrowserRestartOnIdleTimeInMinutes

    [DscProperty()]
    [System.ComponentModel.Description('This policy setting allows to define a list of Kiosk profiles for a Kiosk configuration. This collection can contain a maximum of 3 elements.')]
    [MSFT_MicrosoftGraphwindowsKioskProfile[]] $KioskProfiles

    [DscProperty()]
    [System.ComponentModel.Description('force update schedule for Kiosk devices.')]
    [MSFT_MicrosoftGraphwindowsKioskForceUpdateSchedule] $WindowsKioskForceUpdateSchedule

    [DscProperty()]
    [System.ComponentModel.Description('Admin provided description of the Device Configuration.')]
    [System.String] $Description

    [DscProperty()]
    [System.ComponentModel.Description('The device mode applicability rule for this Policy.')]
    [MSFT_DeviceManagementApplicabilityRuleDeviceMode] $DeviceManagementApplicabilityRuleDeviceMode

    [DscProperty()]
    [System.ComponentModel.Description('The OS edition applicability for this Policy. ')]
    [MSFT_DeviceManagementApplicabilityRuleOsEdition] $DeviceManagementApplicabilityRuleOsEdition

    [DscProperty()]
    [System.ComponentModel.Description('The OS version applicability rule for this Policy.')]
    [MSFT_DeviceManagementApplicabilityRuleOsVersion] $DeviceManagementApplicabilityRuleOsVersion

    [DscProperty(Key)]
    [System.ComponentModel.Description('Admin provided name of the device configuration.')]
    [System.String] $DisplayName

    [DscProperty()]
    [System.ComponentModel.Description('The unique identifier for an entity. Read-only.')]
    [System.String] $Id

    [DscProperty()]
    [System.ComponentModel.Description('List of Scope Tags for this Entity instance.')]
    [System.String[]] $RoleScopeTagIds

    [DscProperty()]
    [System.ComponentModel.Description('Represents the assignment to the Intune policy.')]
    [MSFT_DeviceManagementConfigurationPolicyAssignments[]] $Assignments

    [DscProperty()]
    [System.ComponentModel.Description('Present ensures the policy exists, absent ensures it is removed.')]
    [ValidateSet('Present', 'Absent')]
    [System.String] $Ensure

    [DscProperty()]
    [System.ComponentModel.Description('Credentials of the Admin')]
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

    # Export-only. Not part of the resource schema.
    [System.String] $Filter

    [IntuneDeviceConfigurationKioskPolicyWindows10] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [IntuneDeviceConfigurationKioskPolicyWindows10]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of the Intune Device Configuration Kiosk Policy for Windows10 with Id {$($this.Id)} and DisplayName {$($this.DisplayName)}"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.DisplayName -ne $this.DisplayName)
            {
                $null = $this.Connect('MicrosoftGraph')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullResult = $this.GetBoundParameters()
                $nullResult.Ensure = 'Absent'

                $getValue = $null
                #region resource generator code
                if (-not [string]::IsNullOrEmpty($this.Id))
                {
                    $getValue = Get-MgBetaDeviceManagementDeviceConfiguration -All -Filter "Id eq '$($this.Id)'" -ErrorAction SilentlyContinue
                }

                if ($null -eq $getValue)
                {
                    Write-Verbose -Message "Could not find an Intune Device Configuration Kiosk Policy for Windows10 with Id {$($this.Id)}"

                    if (-not [string]::IsNullOrEmpty($this.DisplayName))
                    {
                        $getValue = Get-MgBetaDeviceManagementDeviceConfiguration `
                            -All `
                            -Filter "DisplayName eq '$($this.DisplayName -replace "'", "''")' and isof('microsoft.graph.windowsKioskConfiguration')" `
                            -ErrorAction SilentlyContinue
                    }
                }
                #endregion
                if ($null -eq $getValue)
                {
                    Write-Verbose -Message "Could not find an Intune Device Configuration Kiosk Policy for Windows10 with DisplayName {$($this.DisplayName)}"
                    return $this.AsResult($nullResult)
                }
            }
            else
            {
                $getValue = $this.ExportedInstance
            }
            $resolvedId = $getValue.Id
            Write-Verbose -Message "An Intune Device Configuration Kiosk Policy for Windows10 with Id {$($resolvedId)} and DisplayName {$($this.DisplayName)} was found."

            #region resource generator code
            $complexKioskProfiles = @()
            foreach ($currentkioskProfiles in $getValue.kioskProfiles)
            {
                $mykioskProfiles = [ordered]@{}
                $complexAppConfiguration = [ordered]@{}
                $complexAppConfiguration.Add('AllowAccessToDownloadsFolder', $currentkioskProfiles.appConfiguration.allowAccessToDownloadsFolder)
                $complexApps = @()
                foreach ($currentApps in $currentkioskProfiles.appConfiguration.apps)
                {
                    $myApps = [ordered]@{}
                    if ($null -ne $currentApps.appType)
                    {
                        $myApps.Add('AppType', $currentApps.appType)
                    }
                    $myApps.Add('AutoLaunch', $currentApps.autoLaunch)
                    $myApps.Add('Name', $currentApps.name)
                    if ($null -ne $currentApps.startLayoutTileSize)
                    {
                        $myApps.Add('StartLayoutTileSize', $currentApps.startLayoutTileSize)
                    }
                    $myApps.Add('DesktopApplicationId', $currentApps.desktopApplicationId)
                    $myApps.Add('DesktopApplicationLinkPath', $currentApps.desktopApplicationLinkPath)
                    $myApps.Add('Path', $currentApps.path)
                    $myApps.Add('AppId', $currentApps.appId)
                    $myApps.Add('AppUserModelId', $currentApps.appUserModelId)
                    $myApps.Add('ContainedAppId', $currentApps.containedAppId)
                    $myApps.Add('ClassicAppPath', $currentApps.classicAppPath)
                    $myApps.Add('EdgeKiosk', $currentApps.edgeKiosk)
                    $myApps.Add('EdgeKioskIdleTimeoutMinutes', $currentApps.edgeKioskIdleTimeoutMinutes)
                    if ($null -ne $currentApps.edgeKioskType)
                    {
                        $myApps.Add('EdgeKioskType', $currentApps.edgeKioskType)
                    }
                    $myApps.Add('EdgeNoFirstRun', $currentApps.edgeNoFirstRun)
                    if ($null -ne $currentApps.'@odata.type')
                    {
                        $myApps.Add('odataType', $currentApps.'@odata.type')
                    }
                    if ($myApps.values.Where({ $null -ne $_ }).Count -gt 0)
                    {
                        $complexApps += $myApps
                    }
                }
                $complexAppConfiguration.Add('Apps', $complexApps)
                $complexAppConfiguration.Add('DisallowDesktopApps', $currentkioskProfiles.appConfiguration.disallowDesktopApps)
                $complexAppConfiguration.Add('ShowTaskBar', $currentkioskProfiles.appConfiguration.showTaskBar)
                $complexAppConfiguration.Add('StartMenuLayoutXml', $currentkioskProfiles.appConfiguration.startMenuLayoutXml)
                $complexUwpApp = [ordered]@{}
                $complexUwpApp.Add('AppId', $currentkioskProfiles.appConfiguration.uwpApp.appId)
                $complexUwpApp.Add('AppUserModelId', $currentkioskProfiles.appConfiguration.uwpApp.appUserModelId)
                $complexUwpApp.Add('ContainedAppId', $currentkioskProfiles.appConfiguration.uwpApp.containedAppId)
                if ($null -ne $currentkioskProfiles.appConfiguration.uwpApp.appType)
                {
                    $complexUwpApp.Add('AppType', $currentkioskProfiles.appConfiguration.uwpApp.appType)
                }
                $complexUwpApp.Add('AutoLaunch', $currentkioskProfiles.appConfiguration.uwpApp.autoLaunch)
                $complexUwpApp.Add('Name', $currentkioskProfiles.appConfiguration.uwpApp.name)
                if ($null -ne $currentkioskProfiles.appConfiguration.uwpApp.startLayoutTileSize)
                {
                    $complexUwpApp.Add('StartLayoutTileSize', $currentkioskProfiles.appConfiguration.uwpApp.startLayoutTileSize)
                }
                $complexUwpApp.Add('DesktopApplicationId', $currentkioskProfiles.appConfiguration.uwpApp.desktopApplicationId)
                $complexUwpApp.Add('DesktopApplicationLinkPath', $currentkioskProfiles.appConfiguration.uwpApp.desktopApplicationLinkPath)
                $complexUwpApp.Add('Path', $currentkioskProfiles.appConfiguration.uwpApp.path)
                $complexUwpApp.Add('ClassicAppPath', $currentkioskProfiles.appConfiguration.uwpApp.classicAppPath)
                $complexUwpApp.Add('EdgeKiosk', $currentkioskProfiles.appConfiguration.uwpApp.edgeKiosk)
                $complexUwpApp.Add('EdgeKioskIdleTimeoutMinutes', $currentkioskProfiles.appConfiguration.uwpApp.edgeKioskIdleTimeoutMinutes)
                if ($null -ne $currentkioskProfiles.appConfiguration.uwpApp.edgeKioskType)
                {
                    $complexUwpApp.Add('EdgeKioskType', $currentkioskProfiles.appConfiguration.uwpApp.edgeKioskType)
                }
                $complexUwpApp.Add('EdgeNoFirstRun', $currentkioskProfiles.appConfiguration.uwpApp.edgeNoFirstRun)
                if ($null -ne $currentkioskProfiles.appConfiguration.uwpApp.'@odata.type')
                {
                    $complexUwpApp.Add('odataType', $currentkioskProfiles.appConfiguration.uwpApp.'@odata.type')
                }
                if ($complexUwpApp.values.Where({ $null -ne $_ }).Count -eq 0)
                {
                    $complexUwpApp = $null
                }
                $complexAppConfiguration.Add('UwpApp', $complexUwpApp)
                $complexWin32App = [ordered]@{}
                $complexWin32App.Add('ClassicAppPath', $currentkioskProfiles.appConfiguration.win32App.classicAppPath)
                $complexWin32App.Add('EdgeKiosk', $currentkioskProfiles.appConfiguration.win32App.edgeKiosk)
                $complexWin32App.Add('EdgeKioskIdleTimeoutMinutes', $currentkioskProfiles.appConfiguration.win32App.edgeKioskIdleTimeoutMinutes)
                if ($null -ne $currentkioskProfiles.appConfiguration.win32App.edgeKioskType)
                {
                    $complexWin32App.Add('EdgeKioskType', $currentkioskProfiles.appConfiguration.win32App.edgeKioskType)
                }
                $complexWin32App.Add('EdgeNoFirstRun', $currentkioskProfiles.appConfiguration.win32App.edgeNoFirstRun)
                if ($null -ne $currentkioskProfiles.appConfiguration.win32App.appType)
                {
                    $complexWin32App.Add('AppType', $currentkioskProfiles.appConfiguration.win32App.appType)
                }
                $complexWin32App.Add('AutoLaunch', $currentkioskProfiles.appConfiguration.win32App.autoLaunch)
                $complexWin32App.Add('Name', $currentkioskProfiles.appConfiguration.win32App.name)
                if ($null -ne $currentkioskProfiles.appConfiguration.win32App.startLayoutTileSize)
                {
                    $complexWin32App.Add('StartLayoutTileSize', $currentkioskProfiles.appConfiguration.win32App.startLayoutTileSize)
                }
                $complexWin32App.Add('DesktopApplicationId', $currentkioskProfiles.appConfiguration.win32App.desktopApplicationId)
                $complexWin32App.Add('DesktopApplicationLinkPath', $currentkioskProfiles.appConfiguration.win32App.desktopApplicationLinkPath)
                $complexWin32App.Add('Path', $currentkioskProfiles.appConfiguration.win32App.path)
                $complexWin32App.Add('AppId', $currentkioskProfiles.appConfiguration.win32App.appId)
                $complexWin32App.Add('AppUserModelId', $currentkioskProfiles.appConfiguration.win32App.appUserModelId)
                $complexWin32App.Add('ContainedAppId', $currentkioskProfiles.appConfiguration.win32App.containedAppId)
                if ($null -ne $currentkioskProfiles.appConfiguration.win32App.'@odata.type')
                {
                    $complexWin32App.Add('odataType', $currentkioskProfiles.appConfiguration.win32App.'@odata.type')
                }
                if ($complexWin32App.values.Where({ $null -ne $_ }).Count -eq 0)
                {
                    $complexWin32App = $null
                }
                $complexAppConfiguration.Add('Win32App', $complexWin32App)
                if ($null -ne $currentkioskProfiles.appConfiguration.'@odata.type')
                {
                    $complexAppConfiguration.Add('odataType', $currentkioskProfiles.appConfiguration.'@odata.type')
                }
                if ($complexAppConfiguration.values.Where({ $null -ne $_ }).Count -eq 0)
                {
                    $complexAppConfiguration = $null
                }
                $mykioskProfiles.Add('AppConfiguration', $complexAppConfiguration)
                $mykioskProfiles.Add('ProfileName', $currentkioskProfiles.profileName)
                $complexUserAccountsConfiguration = @()
                foreach ($currentUserAccountsConfiguration in $currentkioskProfiles.userAccountsConfiguration)
                {
                    $myUserAccountsConfiguration = [ordered]@{}
                    $myUserAccountsConfiguration.Add('GroupName', $currentUserAccountsConfiguration.groupName)
                    $myUserAccountsConfiguration.Add('DisplayName', $currentUserAccountsConfiguration.displayName)
                    $myUserAccountsConfiguration.Add('GroupId', $currentUserAccountsConfiguration.groupId)
                    $myUserAccountsConfiguration.Add('UserId', $currentUserAccountsConfiguration.userId)
                    $myUserAccountsConfiguration.Add('UserPrincipalName', $currentUserAccountsConfiguration.userPrincipalName)
                    $myUserAccountsConfiguration.Add('UserName', $currentUserAccountsConfiguration.userName)
                    if ($null -ne $currentUserAccountsConfiguration.'@odata.type')
                    {
                        $myUserAccountsConfiguration.Add('odataType', $currentUserAccountsConfiguration.'@odata.type')
                    }
                    if ($myUserAccountsConfiguration.values.Where({ $null -ne $_ }).Count -gt 0)
                    {
                        $complexUserAccountsConfiguration += $myUserAccountsConfiguration
                    }
                }
                $mykioskProfiles.Add('UserAccountsConfiguration', $complexUserAccountsConfiguration)
                if ($mykioskProfiles.values.Where({ $null -ne $_ }).Count -gt 0)
                {
                    $complexKioskProfiles += $mykioskProfiles
                }
            }

            $complexWindowsKioskForceUpdateSchedule = [ordered]@{}
            $complexWindowsKioskForceUpdateSchedule.Add('DayofMonth', $getValue.windowsKioskForceUpdateSchedule.dayofMonth)
            if ($null -ne $getValue.windowsKioskForceUpdateSchedule.dayofWeek)
            {
                $complexWindowsKioskForceUpdateSchedule.Add('DayofWeek', $getValue.windowsKioskForceUpdateSchedule.dayofWeek)
            }
            if ($null -ne $getValue.windowsKioskForceUpdateSchedule.recurrence)
            {
                $complexWindowsKioskForceUpdateSchedule.Add('Recurrence', $getValue.windowsKioskForceUpdateSchedule.recurrence)
            }
            $complexWindowsKioskForceUpdateSchedule.Add('RunImmediatelyIfAfterStartDateTime', $getValue.windowsKioskForceUpdateSchedule.runImmediatelyIfAfterStartDateTime)
            if ($null -ne $getValue.windowsKioskForceUpdateSchedule.startDateTime)
            {
                $complexWindowsKioskForceUpdateSchedule.Add('StartDateTime', ([DateTimeOffset]$getValue.windowsKioskForceUpdateSchedule.startDateTime).ToString('o'))
            }
            if ($complexWindowsKioskForceUpdateSchedule.values.Where({ $null -ne $_ }).Count -eq 0)
            {
                $complexWindowsKioskForceUpdateSchedule = $null
            }

            $complexDeviceManagementApplicabilityRuleDeviceMode = [ordered]@{}
            $complexDeviceManagementApplicabilityRuleDeviceMode.Add('DeviceMode', $getValue.DeviceManagementApplicabilityRuleDeviceMode.DeviceMode)
            $complexDeviceManagementApplicabilityRuleDeviceMode.Add('Name', $getValue.DeviceManagementApplicabilityRuleDeviceMode.Name)
            $complexDeviceManagementApplicabilityRuleDeviceMode.Add('RuleType', $getValue.DeviceManagementApplicabilityRuleDeviceMode.RuleType)
            if ($complexDeviceManagementApplicabilityRuleDeviceMode.values.Where({ $null -ne $_ }).Count -eq 0)
            {
                $complexDeviceManagementApplicabilityRuleDeviceMode = $null
            }

            $complexDeviceManagementApplicabilityRuleOsEdition = [ordered]@{}
            $complexDeviceManagementApplicabilityRuleOsEdition.Add('Name', $getValue.DeviceManagementApplicabilityRuleOSEdition.Name)
            $complexDeviceManagementApplicabilityRuleOsEdition.Add('OsEditionTypes', [string[]]$getValue.DeviceManagementApplicabilityRuleOSEdition.OsEditionTypes)
            $complexDeviceManagementApplicabilityRuleOsEdition.Add('RuleType', $getValue.DeviceManagementApplicabilityRuleOSEdition.RuleType)
            if ($complexDeviceManagementApplicabilityRuleOsEdition.values.Where({ $null -ne $_ }).Count -eq 0)
            {
                $complexDeviceManagementApplicabilityRuleOsEdition = $null
            }

            $complexDeviceManagementApplicabilityRuleOsVersion = [ordered]@{}
            $complexDeviceManagementApplicabilityRuleOsVersion.Add('MaxOSVersion', $getValue.DeviceManagementApplicabilityRuleOSVersion.MaxOSVersion)
            $complexDeviceManagementApplicabilityRuleOsVersion.Add('MinOSVersion', $getValue.DeviceManagementApplicabilityRuleOSVersion.MinOSVersion)
            $complexDeviceManagementApplicabilityRuleOsVersion.Add('Name', $getValue.DeviceManagementApplicabilityRuleOSVersion.Name)
            $complexDeviceManagementApplicabilityRuleOsVersion.Add('RuleType', $getValue.DeviceManagementApplicabilityRuleOSVersion.RuleType)
            if ($complexDeviceManagementApplicabilityRuleOsVersion.values.Where({ $null -ne $_ }).Count -eq 0)
            {
                $complexDeviceManagementApplicabilityRuleOsVersion = $null
            }
            #endregion

            $results = @{
                #region resource generator code
                EdgeKioskEnablePublicBrowsing               = $getValue.edgeKioskEnablePublicBrowsing
                KioskBrowserBlockedUrlExceptions            = $getValue.kioskBrowserBlockedUrlExceptions
                KioskBrowserBlockedURLs                     = $getValue.kioskBrowserBlockedURLs
                KioskBrowserDefaultUrl                      = $getValue.kioskBrowserDefaultUrl
                KioskBrowserEnableEndSessionButton          = $getValue.kioskBrowserEnableEndSessionButton
                KioskBrowserEnableHomeButton                = $getValue.kioskBrowserEnableHomeButton
                KioskBrowserEnableNavigationButtons         = $getValue.kioskBrowserEnableNavigationButtons
                KioskBrowserRestartOnIdleTimeInMinutes      = $getValue.kioskBrowserRestartOnIdleTimeInMinutes
                KioskProfiles                               = $complexKioskProfiles
                WindowsKioskForceUpdateSchedule             = $complexWindowsKioskForceUpdateSchedule
                Description                                 = $getValue.Description
                DeviceManagementApplicabilityRuleDeviceMode = $complexDeviceManagementApplicabilityRuleDeviceMode
                DeviceManagementApplicabilityRuleOsEdition  = $complexDeviceManagementApplicabilityRuleOsEdition
                DeviceManagementApplicabilityRuleOsVersion  = $complexDeviceManagementApplicabilityRuleOsVersion
                DisplayName                                 = $getValue.DisplayName
                Id                                          = $getValue.Id
                RoleScopeTagIds                             = Resolve-M365DSCIntuneRoleScopeTagNames -CurrentValues $getValue.RoleScopeTagIds -DesiredValues $this.RoleScopeTagIds
                Ensure                                      = 'Present'
                Credential                                  = $this.Credential
                ApplicationId                               = $this.ApplicationId
                TenantId                                    = $this.TenantId
                ApplicationSecret                           = $this.ApplicationSecret
                CertificateThumbprint                       = $this.CertificateThumbprint
                CertificatePath                             = $this.CertificatePath
                CertificatePassword                         = $this.CertificatePassword
                ManagedIdentity                             = $this.ManagedIdentity
                AccessTokens                                = $this.AccessTokens
                #endregion
            }

            $assignmentsValues = Get-M365DSCIntuneExpandedAssignments -Instance $getValue
            if ($null -eq $assignmentsValues)
            {
                $assignmentsValues = Get-MgBetaDeviceManagementDeviceConfigurationAssignment -DeviceConfigurationId $resolvedId
            }
            $assignmentResult = @()
            if ($assignmentsValues.Count -gt 0)
            {
                $assignmentResult += ConvertFrom-IntunePolicyAssignment `
                    -IncludeDeviceFilter:$true `
                    -Assignments ($assignmentsValues)
            }
            $results.Add('Assignments', $assignmentResult)

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

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $currentInstance = $this.Get().ToHashtable()
        $boundParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()

        if ($boundParameters.ContainsKey('RoleScopeTagIds'))
        {
            $boundParameters.RoleScopeTagIds = Resolve-M365DSCIntuneRoleScopeTagIds -RoleScopeTagIds $this.RoleScopeTagIds
        }

        $boundParameters = Rename-M365DSCCimInstanceParameter -Properties $boundParameters

        foreach ($kioskProfile in $boundParameters.kioskProfiles)
        {
            $appConfiguration = $kioskProfile.appConfiguration
            if ($null -eq $appConfiguration)
            {
                continue
            }

            if ($appConfiguration['@odata.type'] -eq '#microsoft.graph.windowsKioskSingleUWPApp' -and $null -ne $appConfiguration.uwpApp)
            {
                $appConfiguration.uwpApp['@odata.type'] = '#microsoft.graph.windowsKioskUWPApp'
            }
            elseif ($appConfiguration['@odata.type'] -eq '#microsoft.graph.windowsKioskSingleWin32App' -and $null -ne $appConfiguration.win32App)
            {
                $appConfiguration.win32App['@odata.type'] = '#microsoft.graph.windowsKioskWin32App'
            }
        }

        $this.RemoveForeignSubtypeProperties($boundParameters, @{
                '#microsoft.graph.windowsKioskMultipleApps'        = @('allowAccessToDownloadsFolder', 'apps', 'disallowDesktopApps', 'showTaskBar', 'startMenuLayoutXml')
                '#microsoft.graph.windowsKioskSingleUWPApp'        = @('uwpApp')
                '#microsoft.graph.windowsKioskSingleWin32App'      = @('win32App')
                '#microsoft.graph.windowsKioskDesktopApp'          = @('appType', 'autoLaunch', 'desktopApplicationId', 'desktopApplicationLinkPath', 'name', 'path', 'startLayoutTileSize')
                '#microsoft.graph.windowsKioskUWPApp'              = @('appId', 'appType', 'appUserModelId', 'autoLaunch', 'containedAppId', 'name', 'startLayoutTileSize')
                '#microsoft.graph.windowsKioskWin32App'            = @('appType', 'autoLaunch', 'classicAppPath', 'edgeKiosk', 'edgeKioskIdleTimeoutMinutes', 'edgeKioskType', 'edgeNoFirstRun', 'name', 'startLayoutTileSize')
                '#microsoft.graph.windowsKioskActiveDirectoryGroup' = @('groupName')
                '#microsoft.graph.windowsKioskAutologon'           = @()
                '#microsoft.graph.windowsKioskAzureADGroup'        = @('displayName', 'groupId')
                '#microsoft.graph.windowsKioskAzureADUser'         = @('userId', 'userPrincipalName')
                '#microsoft.graph.windowsKioskLocalGroup'          = @('groupName')
                '#microsoft.graph.windowsKioskLocalUser'           = @('userName')
                '#microsoft.graph.windowsKioskVisitor'             = @()
            })

        if ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Creating an Intune Device Configuration Kiosk Policy for Windows10 with DisplayName {$($this.DisplayName)}"
            $createParameters = $boundParameters
            $createParameters.Remove('Assignments') | Out-Null

            $createParameters.Remove('Id') | Out-Null

            #region resource generator code
            $createParameters.Add('@odata.type', '#microsoft.graph.windowsKioskConfiguration')
            $policy = New-MgBetaDeviceManagementDeviceConfiguration -BodyParameter $createParameters
            $assignmentsHash = ConvertTo-IntunePolicyAssignment -IncludeDeviceFilter:$true -Assignments $this.Assignments

            if ($policy.id)
            {
                Update-DeviceConfigurationPolicyAssignment -DeviceConfigurationPolicyId $policy.id `
                    -Targets $assignmentsHash `
                    -Repository 'deviceManagement/deviceConfigurations'
            }
            #endregion
        }
        elseif ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Updating the Intune Device Configuration Kiosk Policy for Windows10 with Id {$($currentInstance.Id)}"
            $updateParameters = $boundParameters
            $updateParameters.Remove('Assignments') | Out-Null

            $updateParameters.Remove('Id') | Out-Null

            #region resource generator code
            $updateParameters.Add('@odata.type', '#microsoft.graph.windowsKioskConfiguration')
            Update-MgBetaDeviceManagementDeviceConfiguration `
                -DeviceConfigurationId $currentInstance.Id `
                -BodyParameter $updateParameters
            $assignmentsHash = ConvertTo-IntunePolicyAssignment -IncludeDeviceFilter:$true -Assignments $this.Assignments
            Update-DeviceConfigurationPolicyAssignment `
                -DeviceConfigurationPolicyId $currentInstance.id `
                -Targets $assignmentsHash `
                -Repository 'deviceManagement/deviceConfigurations'
            #endregion
        }
        elseif ($this.Ensure -eq 'Absent' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Removing the Intune Device Configuration Kiosk Policy for Windows10 with Id {$($currentInstance.Id)}"
            #region resource generator code
            Remove-MgBetaDeviceManagementDeviceConfiguration -DeviceConfigurationId $currentInstance.Id
            #endregion
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

        $ConnectionMode = $this.Connect('MicrosoftGraph')

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Export')

        try
        {
            #region resource generator code
            [array]$getValue = Get-M365DSCExportCachedCollection -Collection 'deviceConfigurations' `
                -ODataType 'microsoft.graph.windowsKioskConfiguration' `
                -Filter $this.Filter
            #endregion

            $i = 1
            $dscContent = [System.Text.StringBuilder]::new()
            if ($getValue.Length -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }
            foreach ($config in $getValue)
            {
                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }

                $displayedKey = $config.Id
                if (-not [String]::IsNullOrEmpty($config.displayName))
                {
                    $displayedKey = $config.displayName
                }
                Write-M365DSCHost -Message "    |---[$i/$($getValue.Count)] $displayedKey" -DeferWrite
                $params = @{
                    Id                    = $config.Id
                    DisplayName           = $config.DisplayName
                    Ensure                = 'Present'
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

                $this.ExportedInstance = $config
                $Results = $this.GetForExport($Params)
                $rawResults = $Results.Clone()

                if ($null -ne $Results.KioskProfiles)
                {
                    $complexMapping = @(
                        @{
                            Name            = 'KioskProfiles'
                            CimInstanceName = 'MicrosoftGraphWindowsKioskProfile'
                            IsRequired      = $False
                        }
                        @{
                            Name            = 'AppConfiguration'
                            CimInstanceName = 'MicrosoftGraphWindowsKioskAppConfiguration'
                            IsRequired      = $False
                        }
                        @{
                            Name            = 'Apps'
                            CimInstanceName = 'MicrosoftGraphWindowsKioskAppBase'
                            IsRequired      = $False
                        }
                        @{
                            Name            = 'UwpApp'
                            CimInstanceName = 'MicrosoftGraphWindowsKioskUWPApp'
                            IsRequired      = $False
                        }
                        @{
                            Name            = 'Win32App'
                            CimInstanceName = 'MicrosoftGraphWindowsKioskWin32App'
                            IsRequired      = $False
                        }
                        @{
                            Name            = 'UserAccountsConfiguration'
                            CimInstanceName = 'MicrosoftGraphWindowsKioskUser'
                            IsRequired      = $False
                        }
                    )
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.KioskProfiles `
                        -CIMInstanceName 'MicrosoftGraphwindowsKioskProfile' `
                        -ComplexTypeMapping $complexMapping

                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.KioskProfiles = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('KioskProfiles') | Out-Null
                    }
                }
                if ($null -ne $Results.WindowsKioskForceUpdateSchedule)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.WindowsKioskForceUpdateSchedule `
                        -CIMInstanceName 'MicrosoftGraphwindowsKioskForceUpdateSchedule'
                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.WindowsKioskForceUpdateSchedule = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('WindowsKioskForceUpdateSchedule') | Out-Null
                    }
                }
                if ($Results.DeviceManagementApplicabilityRuleDeviceMode)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString -ComplexObject $Results.DeviceManagementApplicabilityRuleDeviceMode -CIMInstanceName DeviceManagementApplicabilityRuleDeviceMode
                    if ($complexTypeStringResult)
                    {
                        $Results.DeviceManagementApplicabilityRuleDeviceMode = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('DeviceManagementApplicabilityRuleDeviceMode') | Out-Null
                    }
                }
                if ($Results.DeviceManagementApplicabilityRuleOsEdition)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString -ComplexObject $Results.DeviceManagementApplicabilityRuleOsEdition -CIMInstanceName DeviceManagementApplicabilityRuleOsEdition
                    if ($complexTypeStringResult)
                    {
                        $Results.DeviceManagementApplicabilityRuleOsEdition = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('DeviceManagementApplicabilityRuleOsEdition') | Out-Null
                    }
                }
                if ($Results.DeviceManagementApplicabilityRuleOsVersion)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString -ComplexObject $Results.DeviceManagementApplicabilityRuleOsVersion -CIMInstanceName DeviceManagementApplicabilityRuleOsVersion
                    if ($complexTypeStringResult)
                    {
                        $Results.DeviceManagementApplicabilityRuleOsVersion = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('DeviceManagementApplicabilityRuleOsVersion') | Out-Null
                    }
                }
                if ($Results.Assignments)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString -ComplexObject $Results.Assignments -CIMInstanceName DeviceManagementConfigurationPolicyAssignments
                    if ($complexTypeStringResult)
                    {
                        $Results.Assignments = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('Assignments') | Out-Null
                    }
                }
                $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                    -ConnectionMode $ConnectionMode `
                    -ModulePath $this.GetModulePath() `
                    -Results $Results `
                    -Credential $this.Credential `
                    -NoEscape @('KioskProfiles', 'WindowsKioskForceUpdateSchedule', 'Assignments', 'DeviceManagementApplicabilityRuleDeviceMode', 'DeviceManagementApplicabilityRuleOsEdition', 'DeviceManagementApplicabilityRuleOsVersion') `
                    -RawResults $rawResults

                [void]$dscContent.Append($currentDSCBlock)
                Save-M365DSCPartialExport -Content $currentDSCBlock `
                    -FileName $Global:PartialExportFileName
                $i++
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            return $dscContent.ToString()
        }
        catch
        {
            if ($_.Exception -like '*401*' -or $_.ErrorDetails.Message -like "*`"ErrorCode`":`"Forbidden`"*" -or `
                    $_.Exception -like '*Request not applicable to target tenant*')
            {
                Write-M365DSCHost -Message "`r`n    $($Global:M365DSCEmojiYellowCircle) The current tenant is not registered for Intune."
            }
            else
            {
                $this.LogError($_, 'Error during Export:')

                throw
            }
        }

        # Every code path must return in a method with a declared return type.
        return ''
    }

    hidden [IntuneDeviceConfigurationKioskPolicyWindows10] AsResult([System.Object] $Values)
    {
        if ($Values -is [IntuneDeviceConfigurationKioskPolicyWindows10])
        {
            return $Values
        }

        $result = [IntuneDeviceConfigurationKioskPolicyWindows10]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}

class MSFT_MicrosoftGraphwindowsKioskProfile
{
    [DscProperty()]
    [System.ComponentModel.Description('The App configuration that will be used for this kiosk configuration.')]
    [MSFT_MicrosoftGraphWindowsKioskAppConfiguration] $AppConfiguration

    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('This is a friendly name used to identify a group of applications, the layout of these apps on the start menu and the users to whom this kiosk configuration is assigned.')]
    [System.String] $ProfileName

    [DscProperty()]
    [System.ComponentModel.Description('The user accounts that will be locked to this kiosk configuration. This collection can contain a maximum of 100 elements.')]
    [MSFT_MicrosoftGraphWindowsKioskUser[]] $UserAccountsConfiguration
}

class MSFT_MicrosoftGraphwindowsKioskForceUpdateSchedule
{
    [DscProperty()]
    [System.ComponentModel.Description('Day of month. Valid values 1 to 31')]
    [System.Nullable[System.UInt32]] $DayofMonth

    [DscProperty()]
    [System.ComponentModel.Description('Day of week. Possible values are: sunday, monday, tuesday, wednesday, thursday, friday, saturday.')]
    [ValidateSet('sunday', 'monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday')]
    [System.String] $DayofWeek

    [DscProperty()]
    [System.ComponentModel.Description('Recurrence schedule. Possible values are: none, daily, weekly, monthly.')]
    [ValidateSet('none', 'daily', 'weekly', 'monthly')]
    [System.String] $Recurrence

    [DscProperty()]
    [System.ComponentModel.Description('If true, runs the task immediately if StartDateTime is in the past, else, runs at the next recurrence.')]
    [System.Nullable[System.Boolean]] $RunImmediatelyIfAfterStartDateTime

    [DscProperty()]
    [System.ComponentModel.Description('The start time for the force restart.')]
    [System.String] $StartDateTime
}

class MSFT_DeviceManagementApplicabilityRuleDeviceMode
{
    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('Name for object')]
    [System.String] $Name

    [DscProperty()]
    [System.ComponentModel.Description('Applicability rule for device mode')]
    [ValidateSet('standardConfiguration', 'sModeConfiguration')]
    [System.String] $DeviceMode

    [DscProperty()]
    [System.ComponentModel.Description('Applicability Rule type')]
    [ValidateSet('include', 'exclude')]
    [System.String] $RuleType
}

class MSFT_DeviceManagementApplicabilityRuleOsEdition
{
    [DscProperty()]
    [System.ComponentModel.Description('Name for object')]
    [System.String] $Name

    [DscProperty()]
    [System.ComponentModel.Description('Applicability rule OS edition type')]
    [System.String[]] $OsEditionTypes

    [DscProperty()]
    [System.ComponentModel.Description('Applicability Rule type')]
    [ValidateSet('include', 'exclude')]
    [System.String] $RuleType
}

class MSFT_DeviceManagementApplicabilityRuleOsVersion
{
    [DscProperty()]
    [System.ComponentModel.Description('Name for object')]
    [System.String] $Name

    [DscProperty()]
    [System.ComponentModel.Description('Min OS version for Applicability Rule')]
    [System.String] $MinOSVersion

    [DscProperty()]
    [System.ComponentModel.Description('Max OS version for Applicability Rule')]
    [System.String] $MaxOSVersion

    [DscProperty()]
    [System.ComponentModel.Description('Applicability Rule type')]
    [ValidateSet('include', 'exclude')]
    [System.String] $RuleType
}

class MSFT_DeviceManagementConfigurationPolicyAssignments
{
    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('The type of the target assignment.')]
    [ValidateSet('#microsoft.graph.cloudPcManagementGroupAssignmentTarget', '#microsoft.graph.groupAssignmentTarget', '#microsoft.graph.allLicensedUsersAssignmentTarget', '#microsoft.graph.allDevicesAssignmentTarget', '#microsoft.graph.exclusionGroupAssignmentTarget', '#microsoft.graph.configurationManagerCollectionAssignmentTarget')]
    [System.String] $dataType

    [DscProperty()]
    [System.ComponentModel.Description('The type of filter of the target assignment i.e. Exclude or Include. Possible values are:none, include, exclude.')]
    [ValidateSet('none', 'include', 'exclude')]
    [System.String] $deviceAndAppManagementAssignmentFilterType

    [DscProperty()]
    [System.ComponentModel.Description('The Id of the filter for the target assignment.')]
    [System.String] $deviceAndAppManagementAssignmentFilterId

    [DscProperty()]
    [System.ComponentModel.Description('The display name of the filter for the target assignment.')]
    [System.String] $deviceAndAppManagementAssignmentFilterDisplayName

    [DscProperty()]
    [System.ComponentModel.Description('The group Id that is the target of the assignment.')]
    [System.String] $groupId

    [DscProperty()]
    [System.ComponentModel.Description('The group Display Name that is the target of the assignment.')]
    [System.String] $groupDisplayName

    [DscProperty()]
    [System.ComponentModel.Description('The collection Id that is the target of the assignment.(ConfigMgr)')]
    [System.String] $collectionId
}

class MSFT_MicrosoftGraphWindowsKioskAppConfiguration
{
    [DscProperty()]
    [System.ComponentModel.Description('This setting allows access to Downloads folder in file explorer.')]
    [System.Nullable[System.Boolean]] $AllowAccessToDownloadsFolder

    [DscProperty()]
    [System.ComponentModel.Description('These are the only Windows Store Apps that will be available to launch from the Start menu. This collection can contain a maximum of 128 elements.')]
    [MSFT_MicrosoftGraphWindowsKioskAppBase[]] $Apps

    [DscProperty()]
    [System.ComponentModel.Description('This setting indicates that desktop apps are allowed. Default to true.')]
    [System.Nullable[System.Boolean]] $DisallowDesktopApps

    [DscProperty()]
    [System.ComponentModel.Description('This setting allows the admin to specify whether the Task Bar is shown or not.')]
    [System.Nullable[System.Boolean]] $ShowTaskBar

    [DscProperty()]
    [System.ComponentModel.Description('Allows admins to override the default Start layout and prevents the user from changing it.The layout is modified by specifying an XML file based on a layout modification schema. XML needs to be in Binary format.')]
    [System.String] $StartMenuLayoutXml

    [DscProperty()]
    [System.ComponentModel.Description('This is the only Application User Model ID (AUMID) that will be available to launch use while in Kiosk Mode')]
    [MSFT_MicrosoftGraphWindowsKioskUWPApp] $UwpApp

    [DscProperty()]
    [System.ComponentModel.Description('This is the win32 app that will be available to launch use while in Kiosk Mode')]
    [MSFT_MicrosoftGraphWindowsKioskWin32App] $Win32App

    [DscProperty()]
    [System.ComponentModel.Description('The type of the entity.')]
    [ValidateSet('#microsoft.graph.windowsKioskMultipleApps', '#microsoft.graph.windowsKioskSingleUWPApp', '#microsoft.graph.windowsKioskSingleWin32App')]
    [System.String] $odataType
}

class MSFT_MicrosoftGraphWindowsKioskUser
{
    [DscProperty()]
    [System.ComponentModel.Description('The name of the AD group that will be locked to this kiosk configuration')]
    [System.String] $GroupName

    [DscProperty()]
    [System.ComponentModel.Description('The display name of the AzureAD group that will be locked to this kiosk configuration')]
    [System.String] $DisplayName

    [DscProperty()]
    [System.ComponentModel.Description('The ID of the AzureAD group that will be locked to this kiosk configuration')]
    [System.String] $GroupId

    [DscProperty()]
    [System.ComponentModel.Description('The ID of the AzureAD user that will be locked to this kiosk configuration')]
    [System.String] $UserId

    [DscProperty()]
    [System.ComponentModel.Description('The user accounts that will be locked to this kiosk configuration')]
    [System.String] $UserPrincipalName

    [DscProperty()]
    [System.ComponentModel.Description('The local user that will be locked to this kiosk configuration')]
    [System.String] $UserName

    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('The type of the entity.')]
    [ValidateSet('#microsoft.graph.windowsKioskActiveDirectoryGroup', '#microsoft.graph.windowsKioskAutologon', '#microsoft.graph.windowsKioskAzureADGroup', '#microsoft.graph.windowsKioskAzureADUser', '#microsoft.graph.windowsKioskLocalGroup', '#microsoft.graph.windowsKioskLocalUser', '#microsoft.graph.windowsKioskVisitor')]
    [System.String] $odataType
}

class MSFT_MicrosoftGraphWindowsKioskAppBase
{
    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('The app type. Possible values are: unknown, store, desktop, aumId.')]
    [ValidateSet('unknown', 'store', 'desktop', 'aumId')]
    [System.String] $AppType

    [DscProperty()]
    [System.ComponentModel.Description('Allow the app to be auto-launched in multi-app kiosk mode')]
    [System.Nullable[System.Boolean]] $AutoLaunch

    [DscProperty()]
    [System.ComponentModel.Description('Represents the friendly name of an app')]
    [System.String] $Name

    [DscProperty()]
    [System.ComponentModel.Description('The app tile size for the start layout. Possible values are: hidden, small, medium, wide, large.')]
    [ValidateSet('hidden', 'small', 'medium', 'wide', 'large')]
    [System.String] $StartLayoutTileSize

    [DscProperty()]
    [System.ComponentModel.Description('Define the DesktopApplicationID of the app')]
    [System.String] $DesktopApplicationId

    [DscProperty()]
    [System.ComponentModel.Description('Define the DesktopApplicationLinkPath of the app')]
    [System.String] $DesktopApplicationLinkPath

    [DscProperty()]
    [System.ComponentModel.Description('Define the path of a desktop app')]
    [System.String] $Path

    [DscProperty()]
    [System.ComponentModel.Description('This references an Intune App that will be target to the same assignments as Kiosk configuration')]
    [System.String] $AppId

    [DscProperty()]
    [System.ComponentModel.Description('This is the only Application User Model ID (AUMID) that will be available to launch use while in Kiosk Mode')]
    [System.String] $AppUserModelId

    [DscProperty()]
    [System.ComponentModel.Description('This references an contained App from an Intune App')]
    [System.String] $ContainedAppId

    [DscProperty()]
    [System.ComponentModel.Description('This is the classicapppath to be used by v4 Win32 app while in Kiosk Mode')]
    [System.String] $ClassicAppPath

    [DscProperty()]
    [System.ComponentModel.Description('Edge kiosk (url) for Edge kiosk mode')]
    [System.String] $EdgeKiosk

    [DscProperty()]
    [System.ComponentModel.Description('Edge kiosk idle timeout in minutes for Edge kiosk mode. Valid values 0 to 1440')]
    [System.Nullable[System.UInt32]] $EdgeKioskIdleTimeoutMinutes

    [DscProperty()]
    [System.ComponentModel.Description('Edge kiosk type for Edge kiosk mode. Possible values are: publicBrowsing, fullScreen.')]
    [ValidateSet('publicBrowsing', 'fullScreen')]
    [System.String] $EdgeKioskType

    [DscProperty()]
    [System.ComponentModel.Description('Edge first run flag for Edge kiosk mode')]
    [System.Nullable[System.Boolean]] $EdgeNoFirstRun

    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('The type of the entity.')]
    [ValidateSet('#microsoft.graph.windowsKioskDesktopApp', '#microsoft.graph.windowsKioskUWPApp', '#microsoft.graph.windowsKioskWin32App')]
    [System.String] $odataType
}

class MSFT_MicrosoftGraphWindowsKioskUWPApp
{
    [DscProperty()]
    [System.ComponentModel.Description('This references an Intune App that will be target to the same assignments as Kiosk configuration')]
    [System.String] $AppId

    [DscProperty()]
    [System.ComponentModel.Description('This is the only Application User Model ID (AUMID) that will be available to launch use while in Kiosk Mode')]
    [System.String] $AppUserModelId

    [DscProperty()]
    [System.ComponentModel.Description('This references an contained App from an Intune App')]
    [System.String] $ContainedAppId

    [DscProperty()]
    [System.ComponentModel.Description('The app type. Possible values are: unknown, store, desktop, aumId.')]
    [ValidateSet('unknown', 'store', 'desktop', 'aumId')]
    [System.String] $AppType

    [DscProperty()]
    [System.ComponentModel.Description('Allow the app to be auto-launched in multi-app kiosk mode')]
    [System.Nullable[System.Boolean]] $AutoLaunch

    [DscProperty()]
    [System.ComponentModel.Description('Represents the friendly name of an app')]
    [System.String] $Name

    [DscProperty()]
    [System.ComponentModel.Description('The app tile size for the start layout. Possible values are: hidden, small, medium, wide, large.')]
    [ValidateSet('hidden', 'small', 'medium', 'wide', 'large')]
    [System.String] $StartLayoutTileSize

    [DscProperty()]
    [System.ComponentModel.Description('Define the DesktopApplicationID of the app')]
    [System.String] $DesktopApplicationId

    [DscProperty()]
    [System.ComponentModel.Description('Define the DesktopApplicationLinkPath of the app')]
    [System.String] $DesktopApplicationLinkPath

    [DscProperty()]
    [System.ComponentModel.Description('Define the path of a desktop app')]
    [System.String] $Path

    [DscProperty()]
    [System.ComponentModel.Description('This is the classicapppath to be used by v4 Win32 app while in Kiosk Mode')]
    [System.String] $ClassicAppPath

    [DscProperty()]
    [System.ComponentModel.Description('Edge kiosk (url) for Edge kiosk mode')]
    [System.String] $EdgeKiosk

    [DscProperty()]
    [System.ComponentModel.Description('Edge kiosk idle timeout in minutes for Edge kiosk mode. Valid values 0 to 1440')]
    [System.Nullable[System.UInt32]] $EdgeKioskIdleTimeoutMinutes

    [DscProperty()]
    [System.ComponentModel.Description('Edge kiosk type for Edge kiosk mode. Possible values are: publicBrowsing, fullScreen.')]
    [ValidateSet('publicBrowsing', 'fullScreen')]
    [System.String] $EdgeKioskType

    [DscProperty()]
    [System.ComponentModel.Description('Edge first run flag for Edge kiosk mode')]
    [System.Nullable[System.Boolean]] $EdgeNoFirstRun

    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('The type of the entity.')]
    [ValidateSet('#microsoft.graph.windowsKioskDesktopApp', '#microsoft.graph.windowsKioskUWPApp', '#microsoft.graph.windowsKioskWin32App')]
    [System.String] $odataType
}

class MSFT_MicrosoftGraphWindowsKioskWin32App
{
    [DscProperty()]
    [System.ComponentModel.Description('This is the classicapppath to be used by v4 Win32 app while in Kiosk Mode')]
    [System.String] $ClassicAppPath

    [DscProperty()]
    [System.ComponentModel.Description('Edge kiosk (url) for Edge kiosk mode')]
    [System.String] $EdgeKiosk

    [DscProperty()]
    [System.ComponentModel.Description('Edge kiosk idle timeout in minutes for Edge kiosk mode. Valid values 0 to 1440')]
    [System.Nullable[System.UInt32]] $EdgeKioskIdleTimeoutMinutes

    [DscProperty()]
    [System.ComponentModel.Description('Edge kiosk type for Edge kiosk mode. Possible values are: publicBrowsing, fullScreen.')]
    [ValidateSet('publicBrowsing', 'fullScreen')]
    [System.String] $EdgeKioskType

    [DscProperty()]
    [System.ComponentModel.Description('Edge first run flag for Edge kiosk mode')]
    [System.Nullable[System.Boolean]] $EdgeNoFirstRun

    [DscProperty()]
    [System.ComponentModel.Description('The app type. Possible values are: unknown, store, desktop, aumId.')]
    [ValidateSet('unknown', 'store', 'desktop', 'aumId')]
    [System.String] $AppType

    [DscProperty()]
    [System.ComponentModel.Description('Allow the app to be auto-launched in multi-app kiosk mode')]
    [System.Nullable[System.Boolean]] $AutoLaunch

    [DscProperty()]
    [System.ComponentModel.Description('Represents the friendly name of an app')]
    [System.String] $Name

    [DscProperty()]
    [System.ComponentModel.Description('The app tile size for the start layout. Possible values are: hidden, small, medium, wide, large.')]
    [ValidateSet('hidden', 'small', 'medium', 'wide', 'large')]
    [System.String] $StartLayoutTileSize

    [DscProperty()]
    [System.ComponentModel.Description('Define the DesktopApplicationID of the app')]
    [System.String] $DesktopApplicationId

    [DscProperty()]
    [System.ComponentModel.Description('Define the DesktopApplicationLinkPath of the app')]
    [System.String] $DesktopApplicationLinkPath

    [DscProperty()]
    [System.ComponentModel.Description('Define the path of a desktop app')]
    [System.String] $Path

    [DscProperty()]
    [System.ComponentModel.Description('This references an Intune App that will be target to the same assignments as Kiosk configuration')]
    [System.String] $AppId

    [DscProperty()]
    [System.ComponentModel.Description('This is the only Application User Model ID (AUMID) that will be available to launch use while in Kiosk Mode')]
    [System.String] $AppUserModelId

    [DscProperty()]
    [System.ComponentModel.Description('This references an contained App from an Intune App')]
    [System.String] $ContainedAppId

    [DscProperty()]
    [System.ComponentModel.Description('The type of the entity.')]
    [ValidateSet('#microsoft.graph.windowsKioskDesktopApp', '#microsoft.graph.windowsKioskUWPApp', '#microsoft.graph.windowsKioskWin32App')]
    [System.String] $odataType
}
