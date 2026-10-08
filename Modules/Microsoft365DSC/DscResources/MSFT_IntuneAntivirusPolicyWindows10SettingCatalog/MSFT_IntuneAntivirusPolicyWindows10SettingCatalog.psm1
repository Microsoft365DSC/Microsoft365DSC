using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class IntuneAntivirusPolicyWindows10SettingCatalog : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('Display name of the endpoint protection policy for Windows 10.')]
    [System.String] $DisplayName

    [DscProperty()]
    [System.ComponentModel.Description('Identity of the endpoint protection policy for Windows 10.')]
    [System.String] $Identity

    [DscProperty()]
    [System.ComponentModel.Description('Description of the endpoint protection policy for Windows 10.')]
    [System.String] $Description

    [DscProperty()]
    [System.ComponentModel.Description('List of Scope Tags for this Entity instance.')]
    [System.String[]] $RoleScopeTagIds

    [DscProperty()]
    [System.ComponentModel.Description('Tamper protection (Device). (Offboarding, Onboarding, ControlledConfig_Onboarding)')]
    [ValidateSet('Onboarding', 'Offboarding', 'ControlledConfig_Onboarding')]
    [System.String] $ControlledConfiguration

    [DscProperty()]
    [System.ComponentModel.Description('Tamper protection (Device). (Offboarding, Onboarding)')]
    [ValidateSet('Onboarding', 'Offboarding')]
    [System.String] $TamperProtection

    [DscProperty()]
    [System.ComponentModel.Description('Use this policy setting to specify if to display the Account protection area in Windows Defender Security Center. (0: disable feature. 1: enable feature)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $DisableAccountProtectionUI

    [DscProperty()]
    [System.ComponentModel.Description('Use this policy setting if you want to disable the display of the app and browser protection area in Windows Defender Security Center. (0: disable feature. 1: enable feature)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $DisableAppBrowserUI

    [DscProperty()]
    [System.ComponentModel.Description('Disable the Clear TPM button in Windows Security. (0: disable feature. 1: enable feature)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $DisableClearTpmButton

    [DscProperty()]
    [System.ComponentModel.Description('Use this policy setting if you want to disable the display of the Device security area in the Windows Defender Security Center. (0: disable feature. 1: enable feature)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $DisableDeviceSecurityUI

    [DscProperty()]
    [System.ComponentModel.Description('Use this policy setting if you want to disable the display of the family options area in Windows Defender Security Center. (0: disable feature. 1: enable feature)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $DisableFamilyUI

    [DscProperty()]
    [System.ComponentModel.Description('Use this policy setting if you want to disable the display of the device performance and health area in Windows Defender Security Center. (0: disable feature. 1: enable feature)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $DisableHealthUI

    [DscProperty()]
    [System.ComponentModel.Description('Use this policy setting if you want to disable the display of the firewall and network protection area in Windows Defender Security Center. (0: disable feature. 1: enable feature)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $DisableNetworkUI

    [DscProperty()]
    [System.ComponentModel.Description('Use this policy setting if you want to disable the display of Windows Defender Security Center notifications. (0: disable feature. 1: enable feature)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $DisableEnhancedNotifications

    [DscProperty()]
    [System.ComponentModel.Description('Hide the recommendation to update TPM Firmware when a vulnerable firmware is detected. (0: disable feature. 1: enable feature)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $DisableTpmFirmwareUpdateWarning

    [DscProperty()]
    [System.ComponentModel.Description('Use this policy setting if you want to disable the display of the virus and threat protection area in Windows Defender Security Center.  (0: disable feature. 1: enable feature)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $DisableVirusUI

    [DscProperty()]
    [System.ComponentModel.Description('Use this policy setting to hide the Ransomware data recovery area in Windows Defender Security Center. (0: disable feature. 1: enable feature)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $HideRansomwareDataRecovery

    [DscProperty()]
    [System.ComponentModel.Description('This policy setting hides the Windows Security notification area control. (0: disable feature. 1: enable feature)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $HideWindowsSecurityNotificationAreaControl

    [DscProperty()]
    [System.ComponentModel.Description('Enable this policy to display your company name and contact options in the notifications. (0: disable feature. 1: enable feature)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $EnableCustomizedToasts

    [DscProperty()]
    [System.ComponentModel.Description('Enable this policy to have your company name and contact options displayed in a contact card fly out in Windows Defender Security Center. (0: disable feature. 1: enable feature)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $EnableInAppCustomization

    [DscProperty()]
    [System.ComponentModel.Description('The company name that is displayed to the users. CompanyName is required for both EnableCustomizedToasts and EnableInAppCustomization.')]
    [System.String] $CompanyName

    [DscProperty()]
    [System.ComponentModel.Description('The email address that is displayed to users. The default mail application is used to initiate email actions.')]
    [System.String] $Email

    [DscProperty()]
    [System.ComponentModel.Description('The phone number or Skype ID that is displayed to users. Skype is used to initiate the call.')]
    [System.String] $Phone

    [DscProperty()]
    [System.ComponentModel.Description('The help portal URL that is displayed to users. The default browser is used to initiate this action.')]
    [System.String] $URL

    [DscProperty()]
    [System.ComponentModel.Description('Allows or disallows scanning of archives. (0: disable feature. 1: enable feature)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $AllowArchiveScanning

    [DscProperty()]
    [System.ComponentModel.Description('Allows or disallows Windows Defender Behavior Monitoring functionality. (0: disable feature. 1: enable feature)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $AllowBehaviorMonitoring

    [DscProperty()]
    [System.ComponentModel.Description('To best protect your PC, Windows Defender will send information to Microsoft about any problems it finds. Microsoft will analyze that information, learn more about problems affecting you and other customers, and offer improved solutions. (0: disable feature. 1: enable feature)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $AllowCloudProtection

    [DscProperty()]
    [System.ComponentModel.Description('Allows or disallows Network Protection to enable datagram processing on Windows Server. (0: disable feature. 1: enable feature)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $AllowDatagramProcessingOnWinServer

    [DscProperty()]
    [System.ComponentModel.Description('Allows or disallows scanning of email. (0: disable feature. 1: enable feature)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $AllowEmailScanning

    [DscProperty()]
    [System.ComponentModel.Description('Allows or disallows a full scan of mapped network drives. (0: disable feature. 1: enable feature)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $AllowFullScanOnMappedNetworkDrives

    [DscProperty()]
    [System.ComponentModel.Description('Allows or disallows a full scan of removable drives. During a quick scan, removable drives may still be scanned. (0: disable feature. 1: enable feature)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $AllowFullScanRemovableDriveScanning

    [DscProperty()]
    [System.ComponentModel.Description('https://github.com/MicrosoftDocs/memdocs/issues/2250 (0: disable feature. 1: enable feature)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $AllowIntrusionPreventionSystem

    [DscProperty()]
    [System.ComponentModel.Description('Allows or disallows Windows Defender IOAVP Protection functionality. (0: disable feature. 1: enable feature)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $AllowIOAVProtection

    [DscProperty()]
    [System.ComponentModel.Description('Allows or disallows Network Protection to be configured into block or audit mode on windows downlevel of RS3. (0: disable feature. 1: enable feature)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $AllowNetworkProtectionDownLevel

    [DscProperty()]
    [System.ComponentModel.Description('Allows or disallows Windows Defender real-time Monitoring functionality. (0: disable feature. 1: enable feature)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $AllowRealtimeMonitoring

    [DscProperty()]
    [System.ComponentModel.Description('Allows or disallows a scanning of network files. (0: disable feature. 1: enable feature)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $AllowScanningNetworkFiles

    [DscProperty()]
    [System.ComponentModel.Description('Allows or disallows Windows Defender Script Scanning functionality. (0: disable feature. 1: enable feature)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $AllowScriptScanning

    [DscProperty()]
    [System.ComponentModel.Description('Allows or disallows user access to the Windows Defender UI. I disallowed, all Windows Defender notifications will also be suppressed. (0: Prevents users from accessing UI. 1: Lets users access UI)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $AllowUserUIAccess

    [DscProperty()]
    [System.ComponentModel.Description('Represents the average CPU load factor for the Windows Defender scan (in percent).')]
    [System.Nullable[System.Int32]] $AvgCPULoadFactor

    [DscProperty()]
    [System.ComponentModel.Description('Specify the maximum folder depth to extract from archive files for scanning.')]
    [System.Nullable[System.Int32]] $ArchiveMaxDepth

    [DscProperty()]
    [System.ComponentModel.Description('Specify the maximum size, in KB, of archive files to be extracted and scanned.')]
    [System.Nullable[System.Int32]] $ArchiveMaxSize

    [DscProperty()]
    [System.ComponentModel.Description('This policy setting allows you to manage whether a check for new virus and spyware definitions will occur before running a scan. (0: disable feature. 1: enable feature)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $CheckForSignaturesBeforeRunningScan

    [DscProperty()]
    [System.ComponentModel.Description('This policy setting determines how aggressive Microsoft Defender Antivirus will be in blocking and scanning suspicious files. Value type is integer.(0: Default windows defender blocking level, 2: High blocking level, 4:High+ blocking level, 6:Zero tolerance blocking level)')]
    [ValidateSet('0', '2', '4', '6')]
    [System.Nullable[System.Int32]] $CloudBlockLevel

    [DscProperty()]
    [System.ComponentModel.Description('This feature allows Microsoft Defender Antivirus to block a suspicious file for up to 60 seconds, and scan it in the cloud to make sure it''s safe. Value type is integer, range is 0 - 50.')]
    [System.Nullable[System.Int32]] $CloudExtendedTimeout

    [DscProperty()]
    [System.ComponentModel.Description('Time period (in days) that quarantine items will be stored on the system.')]
    [System.Nullable[System.Int32]] $DaysToRetainCleanedMalware

    [DscProperty()]
    [System.ComponentModel.Description('This policy setting allows you to configure catch-up scans for scheduled full scans.  (1: disabled, 0: enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $DisableCatchupFullScan

    [DscProperty()]
    [System.ComponentModel.Description('This policy setting allows you to configure catch-up scans for scheduled quick scans.  (1: disabled, 0: enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $DisableCatchupQuickScan

    [DscProperty()]
    [System.ComponentModel.Description('Disable Core Service ECS Integration.  (0: disabled, 1: enabled)')]
    [ValidateSet('0', '1')]
    [System.Int32[]] $DisableCoreServiceECSIntegration

    [DscProperty()]
    [System.ComponentModel.Description('Disable Core Service Telemetry.  (1: disabled, 0: enabled)')]
    [ValidateSet('0', '1')]
    [System.Int32[]] $DisableCoreServiceTelemetry

    [DscProperty()]
    [System.ComponentModel.Description('Disables or enables DNS over TCP Parsing for Network Protection. (0: enable feature. 1: disable feature)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $DisableDnsOverTcpParsing

    [DscProperty()]
    [System.ComponentModel.Description('Disables or enables HTTP Parsing for Network Protection. (0: enable feature. 1: disable feature)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $DisableHttpParsing

    [DscProperty()]
    [System.ComponentModel.Description('Disable Ssh Parsing (1: SSH parsing is disabled, 0: SSH parsing is enabled)')]
    [ValidateSet('1', '0')]
    [System.Nullable[System.Int32]] $DisableSshParsing

    [DscProperty()]
    [System.ComponentModel.Description('This policy setting allows you to enable or disable low CPU priority for scheduled scans. (0: disable feature. 1: enable feature)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $EnableLowCPUPriority

    [DscProperty()]
    [System.ComponentModel.Description('This policy allows you to turn on network protection (block/audit) or off. (0: disabled, 1: block mode, 2: audit mode)')]
    [ValidateSet('0', '1', '2')]
    [System.Nullable[System.Int32]] $EnableNetworkProtection

    [DscProperty()]
    [System.ComponentModel.Description('Allows an administrator to specify a list of file type extensions to ignore during a scan.')]
    [System.String[]] $ExcludedExtensions

    [DscProperty()]
    [System.ComponentModel.Description('Allows an administrator to specify a list of directory paths to ignore during a scan.')]
    [System.String[]] $ExcludedPaths

    [DscProperty()]
    [System.ComponentModel.Description('Allows an administrator to specify a list of files opened by processes to ignore during a scan.')]
    [System.String[]] $ExcludedProcesses

    [DscProperty()]
    [System.ComponentModel.Description('Specifies the level of detection for potentially unwanted applications (PUAs). (0: disabled, 1: block mode, 2: audit mode)')]
    [ValidateSet('0', '1', '2')]
    [System.Nullable[System.Int32]] $PUAProtection

    [DscProperty()]
    [System.ComponentModel.Description('Enable this policy to specify when devices receive Microsoft Defender engine updates during the monthly gradual rollout. (0: Not configured, 2: Beta Channel, 3: Current Channel (Preview), 4: Current Channel (Staged), 5: Current Channel (Broad), 6: Critical)')]
    [ValidateSet('0', '2', '3', '4', '5', '6')]
    [System.Nullable[System.Int32]] $EngineUpdatesChannel

    [DscProperty()]
    [System.ComponentModel.Description('Allow managed devices to update through metered connections. (0: disabled, 1: enabled)')]
    [ValidateSet('0', '1')]
    [System.String] $MeteredConnectionUpdates

    [DscProperty()]
    [System.ComponentModel.Description('Enable this policy to specify when devices receive Microsoft Defender platform updates during the monthly gradual rollout. (0: Not configured, 2: Beta Channel, 3: Current Channel (Preview), 4: Current Channel (Staged), 5: Current Channel (Broad), 6: Critical)')]
    [ValidateSet('0', '2', '3', '4', '5', '6')]
    [System.Nullable[System.Int32]] $PlatformUpdatesChannel

    [DscProperty()]
    [System.ComponentModel.Description('Enable this policy to specify when devices receive Microsoft Defender security intelligence updates during the daily gradual rollout. (0: Not configured, 4: Current Channel (Staged), 5: Current Channel (Broad))')]
    [ValidateSet('0', '4', '5')]
    [System.Nullable[System.Int32]] $SecurityIntelligenceUpdatesChannel

    [DscProperty()]
    [System.ComponentModel.Description('Controls which sets of files should be monitored. (0: Monitor all files (bi-directional), 1: Monitor incoming files, 2: Monitor outgoing files)')]
    [ValidateSet('0', '1', '2')]
    [System.Nullable[System.Int32]] $RealTimeScanDirection

    [DscProperty()]
    [System.ComponentModel.Description('Selects whether to perform a quick scan or full scan. (1: Quick scan, 2: Full scan)')]
    [ValidateSet('1', '2')]
    [System.Nullable[System.Int32]] $ScanParameter

    [DscProperty()]
    [System.ComponentModel.Description('Selects the time of day that the Windows Defender quick scan should run.')]
    [System.Nullable[System.Int32]] $ScheduleQuickScanTime

    [DscProperty()]
    [System.ComponentModel.Description('Selects the day that the Windows Defender scan should run. (0: Every day, 1: Sunday, 2: Monday, 3: Tuesday, 4: Wednesday, 5: Thursday, 6: Friday, 7: Saturday, 8: No scheduled scan)')]
    [ValidateSet('0', '1', '2', '3', '4', '5', '6', '7', '8')]
    [System.Nullable[System.Int32]] $ScheduleScanDay

    [DscProperty()]
    [System.ComponentModel.Description('Selects the time of day that the Windows Defender scan should run. Must be between 0 and 1380 minutes.')]
    [ValidateRange(0, 1380)]
    [System.Nullable[System.Int32]] $ScheduleScanTime

    [DscProperty()]
    [System.ComponentModel.Description('This setting disables TLS Parsing for Network Protection. (0: enabled, 1: disabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $DisableTlsParsing

    [DscProperty()]
    [System.ComponentModel.Description('Specifies if the start time of the scan is randomized. (0: no randomization, 1: randomized)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $RandomizeScheduleTaskTimes

    [DscProperty()]
    [System.ComponentModel.Description('This setting allows you to configure the scheduler randomization in hours. The randomization interval is [1 - 23] hours.')]
    [ValidateRange(1, 23)]
    [System.Nullable[System.Int32]] $SchedulerRandomizationTime

    [DscProperty()]
    [System.ComponentModel.Description('This policy setting allows you to define the order in which different definition update sources should be contacted.')]
    [System.String[]] $SignatureUpdateFallbackOrder

    [DscProperty()]
    [System.ComponentModel.Description('This policy setting allows you to configure UNC file share sources for downloading definition updates.')]
    [System.String[]] $SignatureUpdateFileSharesSources

    [DscProperty()]
    [System.ComponentModel.Description('Specifies the interval (in hours) that will be used to check for signatures, so instead of using the ScheduleDay and ScheduleTime the check for new signatures will be set according to the interval. Must be between 0 and 24 hours.')]
    [ValidateRange(0, 24)]
    [System.Nullable[System.Int32]] $SignatureUpdateInterval

    [DscProperty()]
    [System.ComponentModel.Description('Checks for the user consent level in Windows Defender to send data. (0: Always prompt, 1: Send safe samples automatically, 2: Never send, 3: Send all samples automatically)')]
    [ValidateSet('0', '1', '2', '3')]
    [System.Nullable[System.Int32]] $SubmitSamplesConsent

    [DscProperty()]
    [System.ComponentModel.Description('This policy setting controls whether or not complex list settings configured by a local administrator are merged with managed settings. (0: enable local admin merge, 1: disable local admin merge)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $DisableLocalAdminMerge

    [DscProperty()]
    [System.ComponentModel.Description('Allows or disallows Windows Defender On Access Protection functionality. (0: disable feature. 1: enable feature)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $AllowOnAccessProtection

    [DscProperty()]
    [System.ComponentModel.Description('Allows an administrator to specify low severity threats corresponding action ID to take.')]
    [ValidateSet('clean', 'quarantine', 'remove', 'allow', 'userdefined', 'block')]
    [System.String] $LowSeverityThreats

    [DscProperty()]
    [System.ComponentModel.Description('Allows an administrator to specify moderate severity threats corresponding action ID to take.')]
    [ValidateSet('clean', 'quarantine', 'remove', 'allow', 'userdefined', 'block')]
    [System.String] $ModerateSeverityThreats

    [DscProperty()]
    [System.ComponentModel.Description('Allows an administrator to specify high severity threats corresponding action ID to take.')]
    [ValidateSet('clean', 'quarantine', 'remove', 'allow', 'userdefined', 'block')]
    [System.String] $SevereThreats

    [DscProperty()]
    [System.ComponentModel.Description('Allows an administrator to specify severe threats corresponding action ID to take.')]
    [ValidateSet('clean', 'quarantine', 'remove', 'allow', 'userdefined', 'block')]
    [System.String] $HighSeverityThreats

    [DscProperty()]
    [System.ComponentModel.Description('Template Id of the policy. 0: Windows Security Experience, 1: Defender Update controls, 2: Microsoft Defender Antivirus exclusions, 3: Microsoft Defender Antivirus')]
    [ValidateSet('d948ff9b-99cb-4ee0-8012-1fbc09685377_1', 'e3f74c5a-a6de-411d-aef6-eb15628f3a0a_1', '45fea5e9-280d-4da1-9792-fb5736da0ca9_1', '804339ad-1553-4478-a742-138fb5807418_1')]
    [System.String] $TemplateId

    [DscProperty()]
    [System.ComponentModel.Description('Represents the assignment to the Intune policy.')]
    [MSFT_DeviceManagementConfigurationPolicyAssignments[]] $Assignments

    [DscProperty()]
    [System.ComponentModel.Description('Present ensures the policy exists, absent ensures it is removed')]
    [ValidateSet('Present', 'Absent')]
    [System.String] $Ensure

    [DscProperty()]
    [System.ComponentModel.Description('Credentials of the Intune Admin')]
    [System.Management.Automation.PSCredential] $Credential

    [DscProperty()]
    [System.ComponentModel.Description('Id of the Azure Active Directory application to authenticate with.')]
    [System.String] $ApplicationId

    [DscProperty()]
    [System.ComponentModel.Description('Name of the Azure Active Directory tenant used for authentication. Format contoso.onmicrosoft.com')]
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

    [IntuneAntivirusPolicyWindows10SettingCatalog] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [IntuneAntivirusPolicyWindows10SettingCatalog]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of the Intune Antivirus Policy for Windows10 Setting Catalog with Id {$($this.Identity)} and DisplayName {$($this.DisplayName)}"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.Name -ne $this.DisplayName)
            {
                $null = $this.Connect('MicrosoftGraph')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullResult = $this.GetBoundParameters()
                $nullResult.Ensure = 'Absent'

                $templateReferences = 'd948ff9b-99cb-4ee0-8012-1fbc09685377_1', 'e3f74c5a-a6de-411d-aef6-eb15628f3a0a_1', '45fea5e9-280d-4da1-9792-fb5736da0ca9_1', '804339ad-1553-4478-a742-138fb5807418_1'

                # Retrieve policy general settings
                $policy = $null
                if (-not [System.String]::IsNullOrEmpty($this.Identity))
                {
                    $policy = Get-MgBetaDeviceManagementConfigurationPolicy -DeviceManagementConfigurationPolicyId $this.Identity -ErrorAction SilentlyContinue `
                        -ExpandProperty 'settings($expand=settingDefinitions)'
                    $settings = $policy.settings
                }

                if ($null -eq $policy)
                {
                    Write-Verbose -Message "Could not find an Intune Antivirus Policy for Windows10 Setting Catalog with Id {$($this.Identity)}"

                    if (-not [System.String]::IsNullOrEmpty($this.DisplayName))
                    {
                        $policy = Get-MgBetaDeviceManagementConfigurationPolicy `
                            -All `
                            -Filter "Name eq '$($this.DisplayName -replace "'", "''")'" `
                            -ErrorAction SilentlyContinue | Where-Object `
                            -FilterScript {
                                $_.TemplateReference.TemplateId -in $templateReferences
                            }

                        if ($policy.Length -gt 1)
                        {
                            throw "Duplicate Intune Antivirus Policy for Windows10 Setting Catalog named $($this.DisplayName) exist in tenant"
                        }
                    }
                }

                if ($null -eq $policy)
                {
                    Write-Verbose -Message "Could not find an Intune Antivirus Policy for Windows10 Setting Catalog with Name {$($this.DisplayName)}"
                    return $this.AsResult($nullResult)
                }
            }
            else
            {
                $policy = $this.ExportedInstance
            }
            $resolvedId = $policy.Id
            Write-Verbose -Message "An Intune Antivirus Policy for Windows10 Setting Catalog with Id {$($resolvedId)} and Name {$($this.DisplayName)} was found."

            #Retrieve policy specific settings
            if ($null -eq $settings)
            {
                [array]$settings = Get-MgBetaDeviceManagementConfigurationPolicySetting `
                    -DeviceManagementConfigurationPolicyId $resolvedId `
                    -ExpandProperty 'settingDefinitions' `
                    -All `
                    -ErrorAction Stop
            }

            $policySettings = @{}
            $policySettings = Export-IntuneSettingCatalogPolicySettings -Settings $settings -ReturnHashtable $policySettings

            $returnHashtable = @{}
            $returnHashtable.Add('Identity', $resolvedId)
            $returnHashtable.Add('DisplayName', $policy.name)
            $returnHashtable.Add('Description', $policy.description)
            $returnHashtable.Add('RoleScopeTagIds', (Resolve-M365DSCIntuneRoleScopeTagNames -CurrentValues $policy.roleScopeTagIds -DesiredValues $this.RoleScopeTagIds))
            $returnHashtable.Add('TemplateId', $policy.templateReference.TemplateId)

            if ($null -ne $policySettings.SevereThreatDefaultAction)
            {
                $returnHashtable.Add('SevereThreats', $policySettings.SevereThreatDefaultAction)
                $policySettings.Remove('SevereThreatDefaultAction')
            }
            if ($null -ne $policySettings.HighSeverityThreatDefaultAction)
            {
                $returnHashtable.Add('HighSeverityThreats', $policySettings.HighSeverityThreatDefaultAction)
                $policySettings.Remove('HighSeverityThreatDefaultAction')
            }
            if ($null -ne $policySettings.ModerateSeverityThreatDefaultAction)
            {
                $returnHashtable.Add('ModerateSeverityThreats', $policySettings.ModerateSeverityThreatDefaultAction)
                $policySettings.Remove('ModerateSeverityThreatDefaultAction')
            }
            if ($null -ne $policySettings.LowSeverityThreatDefaultAction)
            {
                $returnHashtable.Add('LowSeverityThreats', $policySettings.LowSeverityThreatDefaultAction)
                $policySettings.Remove('LowSeverityThreatDefaultAction')
            }
            if ($policySettings.ContainsKey('EnableDnsSinkhole'))
            {
                Write-Warning -Message "The setting 'EnableDnsSinkhole' is deprecated and will be ignored."
                $policySettings.Remove('EnableDnsSinkhole') | Out-Null
            }
            $returnHashtable += $policySettings

            $returnAssignments = @()
            $graphAssignments = Get-M365DSCIntuneExpandedAssignments -Instance $policy
            if ($null -eq $graphAssignments)
            {
                $graphAssignments = Get-MgBetaDeviceManagementConfigurationPolicyAssignment -DeviceManagementConfigurationPolicyId $resolvedId
            }
            if ($graphAssignments.Count -gt 0)
            {
                $returnAssignments += ConvertFrom-IntunePolicyAssignment `
                    -IncludeDeviceFilter:$true `
                    -Assignments ($graphAssignments)
            }
            $returnHashtable.Add('Assignments', $returnAssignments)

            $returnHashtable.Add('Ensure', 'Present')
            $returnHashtable.Add('Credential', $this.Credential)
            $returnHashtable.Add('ApplicationId', $this.ApplicationId)
            $returnHashtable.Add('TenantId', $this.TenantId)
            $returnHashtable.Add('ApplicationSecret', $this.ApplicationSecret)
            $returnHashtable.Add('CertificateThumbprint', $this.CertificateThumbprint)
            $returnHashtable.Add('ManagedIdentity', $this.ManagedIdentity)
            $returnHashtable.Add('AccessTokens', $this.AccessTokens)

            return $this.AsResult($returnHashtable)
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

        Write-Verbose -Message "Setting configuration of the Intune Antivirus Policy for Windows10 Setting Catalog with Id {$($this.Identity)} and DisplayName {$($this.DisplayName)}"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $currentPolicy = $this.Get().ToHashtable()
        $boundParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()

        $resolvedRoleScopeTagIds = $this.RoleScopeTagIds
        if ($boundParameters.ContainsKey('RoleScopeTagIds'))
        {
            $resolvedRoleScopeTagIds = Resolve-M365DSCIntuneRoleScopeTagIds -RoleScopeTagIds $this.RoleScopeTagIds
        }

        if ($boundParameters.ContainsKey('TamperProtection'))
        {
            $boundParameters['ControlledConfiguration'] = $boundParameters['TamperProtection']
            $boundParameters.Remove('TamperProtection')
        }

        if ($boundParameters.ContainsKey('SevereThreats'))
        {
            $boundParameters.Add('SevereThreatDefaultAction', $boundParameters['SevereThreats'])
            $boundParameters.Remove('SevereThreats')
        }
        if ($boundParameters.ContainsKey('HighSeverityThreats'))
        {
            $boundParameters.Add('HighSeverityThreatDefaultAction', $boundParameters['HighSeverityThreats'])
            $boundParameters.Remove('HighSeverityThreats')
        }
        if ($boundParameters.ContainsKey('ModerateSeverityThreats'))
        {
            $boundParameters.Add('ModerateSeverityThreatDefaultAction', $boundParameters['ModerateSeverityThreats'])
            $boundParameters.Remove('ModerateSeverityThreats')
        }
        if ($boundParameters.ContainsKey('LowSeverityThreats'))
        {
            $boundParameters.Add('LowSeverityThreatDefaultAction', $boundParameters['LowSeverityThreats'])
            $boundParameters.Remove('LowSeverityThreats')
        }

        $templateReferenceId = $this.TemplateId
        $platforms = 'windows10'
        $technologies = 'mdm,microsoftSense'

        if ($this.Ensure -eq 'Present' -and $currentPolicy.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Creating new Endpoint Protection Policy {$($this.DisplayName)}"
            $boundParameters.Remove('Identity') | Out-Null
            $boundParameters.Remove('Assignments') | Out-Null

            $settings = Get-IntuneSettingCatalogPolicySetting `
                -DSCParams ([System.Collections.Hashtable]$boundParameters) `
                -TemplateId $templateReferenceId

            $createParameters = @{
                name              = $this.DisplayName
                description       = $this.Description
                templateReference = @{ templateId = $templateReferenceId }
                platforms         = $platforms
                technologies      = $technologies
                settings          = $settings
                roleScopeTagIds   = $resolvedRoleScopeTagIds
            }

            $policy = New-MgBetaDeviceManagementConfigurationPolicy -BodyParameter $createParameters

            if ($policy.Id)
            {
                $assignmentsHash = ConvertTo-IntunePolicyAssignment -Assignments $this.Assignments -IncludeDeviceFilter:$true
                Update-DeviceConfigurationPolicyAssignment -DeviceConfigurationPolicyId $policy.Id `
                    -Targets $assignmentsHash `
                    -Repository 'deviceManagement/configurationPolicies'
            }
        }
        elseif ($this.Ensure -eq 'Present' -and $currentPolicy.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Updating existing Endpoint Protection Policy {$($currentPolicy.DisplayName)}"
            $boundParameters.Remove('Identity') | Out-Null
            $boundParameters.Remove('Assignments') | Out-Null
            $boundParameters.Remove('TemplateId') | Out-Null

            $settings = Get-IntuneSettingCatalogPolicySetting `
                -DSCParams ([System.Collections.Hashtable]$boundParameters) `
                -TemplateId $templateReferenceId

            Update-IntuneDeviceConfigurationPolicy `
                -DeviceConfigurationPolicyId $currentPolicy.Identity `
                -Name $this.DisplayName `
                -Description $this.Description `
                -TemplateReferenceId $templateReferenceId `
                -Platforms $platforms `
                -Technologies $technologies `
                -Settings $settings `
                -RoleScopeTagIds $resolvedRoleScopeTagIds

            $assignmentsHash = ConvertTo-IntunePolicyAssignment -IncludeDeviceFilter:$true -Assignments $this.Assignments
            Update-DeviceConfigurationPolicyAssignment `
                -DeviceConfigurationPolicyId $currentPolicy.Identity `
                -Targets $assignmentsHash `
                -Repository 'deviceManagement/configurationPolicies'
        }
        elseif ($this.Ensure -eq 'Absent' -and $currentPolicy.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Removing Endpoint Protection Policy {$($currentPolicy.DisplayName)}"
            Remove-MgBetaDeviceManagementConfigurationPolicy -DeviceManagementConfigurationPolicyId $currentPolicy.Identity
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

        $dscContent = [System.Text.StringBuilder]::new()
        $i = 1

        try
        {
            $templateFamily = 'endpointSecurityAntivirus'
            $templateReferences = 'd948ff9b-99cb-4ee0-8012-1fbc09685377_1', 'e3f74c5a-a6de-411d-aef6-eb15628f3a0a_1', '45fea5e9-280d-4da1-9792-fb5736da0ca9_1', '804339ad-1553-4478-a742-138fb5807418_1'
            $baseFilter = foreach ($templateReference in $templateReferences)
            {
                "templateReference/templateId eq '$templateReference'"
            }
            $baseFilter = $baseFilter -join ' or '
            $baseFilter = "($baseFilter) and templateReference/templateFamily eq '$templateFamily'"
            $mergedFilter = $baseFilter
            if (-not [System.String]::IsNullOrEmpty($this.Filter))
            {
                $mergedFilter = "($($this.Filter)) and ($baseFilter)"
            }
            [array]$policies = Get-MgBetaDeviceManagementConfigurationPolicy `
                -Filter $mergedFilter `
                -All `
                -ExpandProperty 'assignments' `
                -ErrorAction Stop

            if ($policies.Length -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }
            foreach ($policy in $policies)
            {
                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }

                Write-M365DSCHost -Message "    |---[$i/$($policies.Count)] $($policy.Name)" -DeferWrite

                $params = @{
                    Identity              = $policy.Id
                    DisplayName           = $policy.Name
                    TemplateId            = $policy.TemplateReference.TemplateId
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

                $this.ExportedInstance = $policy
                $Results = $this.GetForExport($params)
                $rawResults = $Results.Clone()

                if ($Results.Assignments)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString -ComplexObject ([Array]$Results.Assignments) -CIMInstanceName DeviceManagementConfigurationPolicyAssignments
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
                    -NoEscape @('Assignments') `
                    -RawResults $rawResults

                [void]$dscContent.Append($currentDSCBlock)
                Save-M365DSCPartialExport -Content $currentDSCBlock `
                    -FileName $Global:PartialExportFileName

                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
                $i++
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

    [System.Collections.Hashtable] GetCompareParameters()
    {
        return @{
            PostProcessing     = {
                param($DesiredValues, $CurrentValues, $ValuesToCheck, $PostProcessingArgs)
                foreach ($name in $PostProcessingArgs[0])
                {
                    $currentValue = $CurrentValues[$name]
                    $desiredValue = $DesiredValues[$name]

                    # See M365DSCResourceBase.GetSettingsCatalogCompareParameters: an empty
                    # collection from Get() is not a value the configuration has to restate.
                    if ($currentValue -is [System.Collections.ICollection] -and $currentValue.Count -eq 0)
                    {
                        $currentValue = $null
                    }
                    if ($desiredValue -is [System.Collections.ICollection] -and $desiredValue.Count -eq 0)
                    {
                        $desiredValue = $null
                    }

                    if ($null -ne $currentValue -or $null -ne $desiredValue)
                    {
                        $ValuesToCheck[$name] = $null
                        if (-not $DesiredValues.ContainsKey($name))
                        {
                            $DesiredValues.Add($name, $null)
                        }
                    }
                }

                # Map the renaming of TamperProtection to ControlledConfiguration for comparison
                if ($DesiredValues.ContainsKey('TamperProtection'))
                {
                    $DesiredValues['ControlledConfiguration'] = $DesiredValues['TamperProtection']
                    $DesiredValues.Remove('TamperProtection')
                }
                if ($CurrentValues.ContainsKey('TamperProtection'))
                {
                    $CurrentValues['ControlledConfiguration'] = $CurrentValues['TamperProtection']
                    $CurrentValues.Remove('TamperProtection')
                }

                return [System.Tuple[Hashtable, Hashtable, Hashtable]]::new($DesiredValues, $CurrentValues, $ValuesToCheck)
            }
            # The leading comma matters: PostProcessingArgs is [Object[]], so without it the names
            # unroll and $PostProcessingArgs[0] is a single string again.
            PostProcessingArgs = @(, $this.GetSchemaPropertyNames())
        }
    }

    hidden [IntuneAntivirusPolicyWindows10SettingCatalog] AsResult([System.Object] $Values)
    {
        if ($Values -is [IntuneAntivirusPolicyWindows10SettingCatalog])
        {
            return $Values
        }

        $result = [IntuneAntivirusPolicyWindows10SettingCatalog]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
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
