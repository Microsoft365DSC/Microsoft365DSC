using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class IntuneMobileAppsAutoUpdateCatalogAppWindows10 : M365DSCResourceBase
{
    [DscProperty()]
    [System.ComponentModel.Description('Represents the assignment to the Intune app.')]
    [MSFT_DeviceManagementWindowsAutoUpdateCatalogMobileAppAssignment[]] $Assignments

    [DscProperty()]
    [System.ComponentModel.Description('The list of categories for this app.')]
    [MSFT_DeviceManagementMobileAppCategory[]] $Categories

    [DscProperty()]
    [System.ComponentModel.Description('The description of the app.')]
    [System.String] $Description

    [DscProperty()]
    [System.ComponentModel.Description('The developer of the app.')]
    [System.String] $Developer

    [DscProperty(Key)]
    [System.ComponentModel.Description('The admin provided or imported title of the app.')]
    [System.String] $DisplayName

    [DscProperty()]
    [System.ComponentModel.Description('The unique identifier for an entity. Read-only.')]
    [System.String] $Id

    [DscProperty()]
    [System.ComponentModel.Description('The more information Url.')]
    [System.String] $InformationUrl

    [DscProperty()]
    [System.ComponentModel.Description('Describes how the app installer executes on the target device, including the account context (system or user) under which the installer runs and how the device handles restarts after installation completes. When omitted, the service applies default values (runAsAccount = system, deviceRestartBehavior = basedOnReturnCode).')]
    [MSFT_MicrosoftGraphWindowsAutoUpdateCatalogAppInstallExperience] $InstallExperience

    [DscProperty()]
    [System.ComponentModel.Description('The value indicating whether the app is marked as featured by the admin.')]
    [System.Nullable[System.Boolean]] $IsFeatured

    [DscProperty()]
    [System.ComponentModel.Description('The large icon, to be displayed in the app details and used for upload of the icon.')]
    [MSFT_MicrosoftGraphMimeContent] $LargeIcon

    [DscProperty()]
    [System.ComponentModel.Description('The identifier of a specific branch in a product, which is a specific subset of product functionality as defined by the publisher . This is run-time resolved to be the latest MobileAppCatalogPackage in the branch. (example:''31a4c766-f23d-8d41-4803-35e155be7389''). Read-Only')]
    [System.String] $MobileAppCatalogPackageBranchId

    [DscProperty()]
    [System.ComponentModel.Description('Notes for the app.')]
    [System.String] $Notes

    [DscProperty()]
    [System.ComponentModel.Description('The owner of the app.')]
    [System.String] $Owner

    [DscProperty()]
    [System.ComponentModel.Description('The privacy statement Url.')]
    [System.String] $PrivacyInformationUrl

    [DscProperty()]
    [System.ComponentModel.Description('The publisher of the app.')]
    [System.String] $Publisher

    [DscProperty()]
    [System.ComponentModel.Description('List of scope tag ids for this mobile app.')]
    [System.String[]] $RoleScopeTagIds

    [DscProperty()]
    [System.ComponentModel.Description('Specify if the app should exist.')]
    [ValidateSet('Present', 'Absent')]
    [System.String] $Ensure

    [DscProperty()]
    [System.ComponentModel.Description('Credentials of the Intune Admin')]
    [System.Management.Automation.PSCredential] $Credential

    [DscProperty()]
    [System.ComponentModel.Description('Id of the Entra ID application to authenticate with.')]
    [System.String] $ApplicationId

    [DscProperty()]
    [System.ComponentModel.Description('Id of the Entra ID tenant used for authentication.')]
    [System.String] $TenantId

    [DscProperty()]
    [System.ComponentModel.Description('Secret of the Entra ID application to authenticate with.')]
    [System.Management.Automation.PSCredential] $ApplicationSecret

    [DscProperty()]
    [System.ComponentModel.Description('Thumbprint of the Entra ID application''s authentication certificate to use for authentication.')]
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

    [IntuneMobileAppsAutoUpdateCatalogAppWindows10] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [IntuneMobileAppsAutoUpdateCatalogAppWindows10]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of Intune Mobile Apps Auto Update Catalog App for Windows10 {$($this.Id)}"

        try
        {
            $null = $this.Connect('MicrosoftGraph')

            #Ensure the proper dependencies are installed in the current environment.
            Confirm-M365DSCDependencies

            #region Telemetry
            $this.AddTelemetry('Get')
            #endregion

            $nullResult = $this.GetBoundParameters()
            $nullResult.Ensure = 'Absent'

            if (-not $this.ExportedInstance -or $this.ExportedInstance.Id -ne $this.Id)
            {
                $getValue = $null
                if (-not [System.String]::IsNullOrEmpty($this.Id))
                {
                    $getValue = Get-MgBetaDeviceAppManagementMobileApp -MobileAppId $this.Id `
                        -ErrorAction SilentlyContinue
                }

                if ($null -eq $getValue -and -not [System.String]::IsNullOrEmpty($this.DisplayName))
                {
                    $getValue = Get-MgBetaDeviceAppManagementMobileApp `
                        -All `
                        -Filter "DisplayName eq '$($this.DisplayName -replace "'", "''")'" `
                        -ErrorAction SilentlyContinue | Where-Object -Property '@odata.type' -EQ '#microsoft.graph.windowsAutoUpdateCatalogApp' | Select-Object -First 1
                }

                if ($null -eq $getValue)
                {
                    Write-Verbose -Message "No Intune Mobile Apps Auto Update Catalog App for Windows10 with Id {$($this.Id)} was found"
                    return $this.AsResult($nullResult)
                }

                $getValue = Get-MgBetaDeviceAppManagementMobileApp -MobileAppId $getValue.Id `
                    -ExpandProperty 'categories'
            }
            else
            {
                $getValue = Get-MgBetaDeviceAppManagementMobileApp -MobileAppId $this.ExportedInstance.Id `
                    -ExpandProperty 'categories' `
                    -ErrorAction SilentlyContinue
            }


            Write-Verbose -Message "Found Intune Mobile Apps Auto Update Catalog App for Windows10 with Id {$($this.Id)}"

            $complexCategories = @()
            foreach ($category in $getValue.Categories)
            {
                $myCategory = [ordered]@{}
                $myCategory.Add('Id', $category.id)
                $myCategory.Add('DisplayName', $category.displayName)
                $complexCategories += $myCategory
            }

            $complexInstallExperience = [ordered]@{}
            $complexInstallExperience.Add('DeviceRestartBehavior', $getValue.installExperience.deviceRestartBehavior)
            $complexInstallExperience.Add('RunAsAccount', $getValue.installExperience.runAsAccount)
            if ($complexInstallExperience.values.Where({ $null -ne $_ }).Count -eq 0)
            {
                $complexInstallExperience = $null
            }

            $complexLargeIcon = [ordered]@{}
            $complexLargeIcon.Add('Type', $getValue.LargeIcon.type)
            $complexLargeIcon.Add('Value', $getValue.LargeIcon.value)
            if ($complexLargeIcon.values.Where({ $null -ne $_ }).Count -eq 0)
            {
                $complexLargeIcon = $null
            }

            $result = @{
                Categories                      = $complexCategories
                Description                     = $getValue.Description
                Developer                       = $getValue.Developer
                DisplayName                     = $getValue.DisplayName
                Id                              = $getValue.Id
                InformationUrl                  = $getValue.InformationUrl
                InstallExperience               = $complexInstallExperience
                IsFeatured                      = $getValue.IsFeatured
                LargeIcon                       = $complexLargeIcon
                MobileAppCatalogPackageBranchId = $getValue.mobileAppCatalogPackageBranchId
                Notes                           = $getValue.Notes
                Owner                           = $getValue.Owner
                PrivacyInformationUrl           = $getValue.PrivacyInformationUrl
                Publisher                       = $getValue.Publisher
                RoleScopeTagIds                 = Resolve-M365DSCIntuneRoleScopeTagNames -CurrentValues $getValue.RoleScopeTagIds -DesiredValues $this.RoleScopeTagIds
                Ensure                          = 'Present'
                Credential                      = $this.Credential
                ApplicationId                   = $this.ApplicationId
                TenantId                        = $this.TenantId
                ApplicationSecret               = $this.ApplicationSecret
                CertificateThumbprint           = $this.CertificateThumbprint
                CertificatePassword             = $this.CertificatePassword
                CertificatePath                 = $this.CertificatePath
                ManagedIdentity                 = $this.ManagedIdentity
                AccessTokens                    = $this.AccessTokens
            }

            $assignmentsValues = Get-MgBetaDeviceAppManagementMobileAppAssignment -MobileAppId $getValue.Id -ErrorAction SilentlyContinue
            $assignmentResult = @()
            if ($null -ne $assignmentsValues -and $assignmentsValues.Count -gt 0)
            {
                [array] $assignmentsValues = $assignmentsValues | Where-Object -Property source -EQ 'direct'
                $assignmentResult += ConvertFrom-IntuneMobileAppAssignment `
                    -IncludeDeviceFilter $true `
                    -Assignments $assignmentsValues
            }
            $result.Add('Assignments', $assignmentResult)

            return $this.AsResult($result)
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

        Write-Verbose -Message "Setting configuration of Intune Mobile Apps Auto Update Catalog App for Windows10 {$($this.Id)}"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        try
        {
            $null = $this.Connect('MicrosoftGraph')

            $currentInstance = $this.Get().ToHashtable()

            $boundParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()

            if ($boundParameters.ContainsKey('RoleScopeTagIds'))
            {
                $boundParameters.RoleScopeTagIds = Resolve-M365DSCIntuneRoleScopeTagIds -RoleScopeTagIds $this.RoleScopeTagIds
            }

            $boundParameters = Rename-M365DSCCimInstanceParameter -Properties $boundParameters
            $boundParameters.Remove('Id') | Out-Null
            $boundParameters.Remove('Assignments') | Out-Null
            $boundParameters.Remove('Categories') | Out-Null
            $boundParameters.Add('@odata.type', '#microsoft.graph.windowsAutoUpdateCatalogApp')

            if ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
            {
                Write-Verbose -Message "Creating new Intune Mobile Apps Auto Update Catalog App for Windows10 {$($this.Id)}"

                $createParameters = $boundParameters
                $createdInstance = New-MgBetaDeviceAppManagementMobileApp -BodyParameter $createParameters

                if ($this.GetBoundParameters().ContainsKey('Categories'))
                {
                    Update-DeviceAppManagementAppCategory -App $createdInstance -Categories $this.Categories
                }

                $assignmentsHash = ConvertTo-IntuneMobileAppAssignment -IncludeDeviceFilter:$true -Assignments $this.Assignments
                if ($createdInstance.Id)
                {
                    Wait-M365DSCIntuneMobileAppPublished -AppId $createdInstance.Id
                    Update-DeviceAppManagementPolicyAssignment `
                        -AppManagementPolicyId $createdInstance.Id `
                        -Assignments $assignmentsHash
                }
            }
            elseif ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Present')
            {
                Write-Verbose -Message "Updating Intune Mobile Apps Auto Update Catalog App for Windows10 {$($this.Id)}"

                $updateParameters = $boundParameters
                $updateParameters.Remove('MobileAppCatalogPackageBranchId') | Out-Null
                Update-MgBetaDeviceAppManagementMobileApp -MobileAppId $currentInstance.Id -BodyParameter $updateParameters | Out-Null

                if ($this.GetBoundParameters().ContainsKey('Categories'))
                {
                    Update-DeviceAppManagementAppCategory -App $currentInstance -Categories $this.Categories -Compare
                }

                $assignmentsHash = ConvertTo-IntuneMobileAppAssignment -IncludeDeviceFilter:$true -Assignments $this.Assignments
                if ($currentInstance.Id)
                {
                    Update-DeviceAppManagementPolicyAssignment `
                        -AppManagementPolicyId $currentInstance.Id `
                        -Assignments $assignmentsHash
                }
            }
            elseif ($this.Ensure -eq 'Absent' -and $currentInstance.Ensure -eq 'Present')
            {
                Write-Verbose -Message "Removing Intune Mobile Apps Auto Update Catalog App for Windows10 {$($this.Id)}"
                Remove-MgBetaDeviceAppManagementMobileApp -MobileAppId $currentInstance.Id | Out-Null
            }
        }
        catch
        {
            $this.LogError($_, 'Error updating data:')

            throw
        }
    }

    [bool] Test()
    {
        return ([M365DSCResourceBase] $this).Test()
    }

    [System.Collections.Hashtable] GetCompareParameters()
    {
        return @{
            ExcludedProperties = @('MobileAppCatalogPackageBranchId')
        }
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
            $baseFilter = "isof('microsoft.graph.windowsAutoUpdateCatalogApp')"
            $mergedFilter = $baseFilter
            if (-not [System.String]::IsNullOrEmpty($this.Filter))
            {
                $mergedFilter = "($baseFilter) and ($($this.Filter))"
            }
            [array] $exportedInstances = Get-MgBetaDeviceAppManagementMobileApp -All -ExpandProperty 'assignments' -Filter $mergedFilter `
                -ErrorAction Stop

            $dscContent = [System.Text.StringBuilder]::new()
            $i = 1

            if ($exportedInstances.Length -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }

            foreach ($exportedInstance in $exportedInstances)
            {
                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }

                Write-M365DSCHost -Message "    |---[$i/$($exportedInstances.Count)] $($exportedInstance.DisplayName)" -DeferWrite

                $Params = @{
                    Id                    = $exportedInstance.Id
                    DisplayName           = $exportedInstance.DisplayName
                    Credential            = $this.Credential
                    ApplicationId         = $this.ApplicationId
                    TenantId              = $this.TenantId
                    ApplicationSecret     = $this.ApplicationSecret
                    CertificateThumbprint = $this.CertificateThumbprint
                    CertificatePassword   = $this.CertificatePassword
                    CertificatePath       = $this.CertificatePath
                    ManagedIdentity       = $this.ManagedIdentity
                    AccessTokens          = $this.AccessTokens
                }

                $this.ExportedInstance = $exportedInstance
                $Results = $this.GetForExport($Params)

                if ($null -ne $Results.Assignments)
                {
                    $complexMapping = @(
                        @{
                            Name            = 'AssignmentSettings'
                            CIMInstanceName = 'DeviceManagementWindowsAutoUpdateCatalogMobileAppAssignmentSettings'
                            IsRequired      = $false
                        },
                        @{
                            Name            = 'InstallTimeSettings'
                            CIMInstanceName = 'DeviceManagementWindowsAutoUpdateCatalogMobileAppAssignmentSettingsInstallTimeSettings'
                            IsRequired      = $false
                        },
                        @{
                            Name            = 'RestartSettings'
                            CIMInstanceName = 'DeviceManagementWindowsAutoUpdateCatalogMobileAppAssignmentSettingsRestartSettings'
                            IsRequired      = $false
                        }
                    )
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.Assignments `
                        -CIMInstanceName DeviceManagementWindowsAutoUpdateCatalogMobileAppAssignment `
                        -ComplexTypeMapping $complexMapping
                    if (-not [System.String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.Assignments = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('Assignments') | Out-Null
                    }
                }

                if ($null -ne $Results.Categories)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.Categories `
                        -CIMInstanceName 'DeviceManagementMobileAppCategory'
                    if (-not [System.String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.Categories = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('Categories') | Out-Null
                    }
                }

                if ($null -ne $Results.InstallExperience)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.InstallExperience `
                        -CIMInstanceName 'MSFT_MicrosoftGraphWindowsAutoUpdateCatalogAppInstallExperience'
                    if (-not [System.String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.InstallExperience = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('InstallExperience') | Out-Null
                    }
                }

                if ($null -ne $Results.LargeIcon)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.LargeIcon `
                        -CIMInstanceName 'MSFT_MicrosoftGraphMimeContent'
                    if (-not [System.String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.LargeIcon = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('LargeIcon') | Out-Null
                    }
                }
                $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                    -ConnectionMode $ConnectionMode `
                    -ModulePath $this.GetModulePath() `
                    -Results $Results `
                    -Credential $this.Credential `
                    -NoEscape @('Assignments', 'Categories', 'InstallExperience', 'LargeIcon')
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
            Write-M365DSCHost -Message $Global:M365DSCEmojiRedX

            $this.LogError($_, 'Error during Export:')

            throw
        }
    }

    hidden [IntuneMobileAppsAutoUpdateCatalogAppWindows10] AsResult([System.Object] $Values)
    {
        if ($Values -is [IntuneMobileAppsAutoUpdateCatalogAppWindows10])
        {
            return $Values
        }

        $result = [IntuneMobileAppsAutoUpdateCatalogAppWindows10]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}

class MSFT_DeviceManagementMobileAppAssignment
{
    [DscProperty()]
    [System.ComponentModel.Description('The type of the target assignment.')]
    [ValidateSet('#microsoft.graph.groupAssignmentTarget', '#microsoft.graph.allLicensedUsersAssignmentTarget', '#microsoft.graph.allDevicesAssignmentTarget', '#microsoft.graph.exclusionGroupAssignmentTarget', '#microsoft.graph.mobileAppAssignment')]
    [System.String] $dataType

    [DscProperty()]
    [System.ComponentModel.Description('The Id of the filter for the target assignment.')]
    [System.String] $deviceAndAppManagementAssignmentFilterId

    [DscProperty()]
    [System.ComponentModel.Description('The display name of the filter for the target assignment.')]
    [System.String] $deviceAndAppManagementAssignmentFilterDisplayName

    [DscProperty()]
    [System.ComponentModel.Description('The type of filter of the target assignment i.e. Exclude or Include. Possible values are: none, include, exclude.')]
    [ValidateSet('none', 'include', 'exclude')]
    [System.String] $deviceAndAppManagementAssignmentFilterType

    [DscProperty()]
    [System.ComponentModel.Description('The group Id that is the target of the assignment.')]
    [System.String] $groupId

    [DscProperty()]
    [System.ComponentModel.Description('The group Display Name that is the target of the assignment.')]
    [System.String] $groupDisplayName

    [DscProperty()]
    [System.ComponentModel.Description('Possible values for the install intent chosen by the admin.')]
    [ValidateSet('available', 'required', 'uninstall', 'availableWithoutEnrollment')]
    [System.String] $intent
}

class MSFT_DeviceManagementWindowsAutoUpdateCatalogMobileAppAssignment : MSFT_DeviceManagementMobileAppAssignment
{
    [DscProperty()]
    [System.ComponentModel.Description('The settings of the assignment.')]
    [MSFT_DeviceManagementWindowsAutoUpdateCatalogMobileAppAssignmentSettings] $assignmentSettings
}

class MSFT_DeviceManagementMobileAppAssignmentSettings
{
    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('The odata type of the assignment type.')]
    [ValidateSet('#microsoft.graph.androidManagedStoreAppAssignmentSettings', '#microsoft.graph.iosStoreAppAssignmentSettings', '#microsoft.graph.iosLobAppAssignmentSettings', '#microsoft.graph.macOsLobAppAssignmentSettings', '#microsoft.graph.win32CatalogAppAssignmentSettings', '#microsoft.graph.win32LobAppAssignmentSettings', '#microsoft.graph.winGetAppAssignmentSettings', '#microsoft.graph.windowsAutoUpdateCatalogAppAssignmentSettings', '#microsoft.graph.windowsUniversalAppXAppAssignmentSettings')]
    [System.String] $odataType
}

class MSFT_DeviceManagementWindowsAutoUpdateCatalogMobileAppAssignmentSettings : MSFT_DeviceManagementMobileAppAssignmentSettings
{
    [DscProperty()]
    [System.ComponentModel.Description('Indicates the priority level for downloading the app content using Delivery Optimization. foreground prioritizes the download over background tasks, which may result in faster installation but higher bandwidth usage. Defaults to notConfigured (background priority) if not specified. When omitted from the request, the service applies notConfigured and the device downloads app content using normal background priority. In National Cloud environments (e.g., US Government, China), Delivery Optimization is not available the service accepts and stores any value provided, but the device agent ignores it at runtime and delivers content via CDN using background priority regardless of the configured value. Possible values are: notConfigured, foreground, unknownFutureValue.')]
    [ValidateSet('notConfigured', 'foreground', 'unknownFutureValue')]
    [System.String] $deliveryOptimizationPriority

    [DscProperty()]
    [System.ComponentModel.Description('Specifies the deadline by which the app must be installed on the device. When null, the app is offered for immediate installation with no enforced deadline.')]
    [MSFT_DeviceManagementWindowsAutoUpdateCatalogMobileAppAssignmentSettingsInstallTimeSettings] $installTimeSettings

    [DscProperty()]
    [System.ComponentModel.Description('Indicates which notifications the Intune management extension displays to the end user during app installation and restart. Defaults to showAll if not specified. Possible values are: showAll, showReboot, hideAll, unknownFutureValue.')]
    [ValidateSet('showAll', 'showReboot', 'hideAll', 'unknownFutureValue')]
    [System.String] $notificationType

    [DscProperty()]
    [System.ComponentModel.Description('Specifies the restart coordination behavior after the app is installedincluding how long to wait before restarting, when to show a countdown, and how long the user can snooze. When null, no restart coordination is applied (the device may still restart based on the app''s deviceRestartBehavior setting). Note: the service accepts restart settings regardless of the app''s deviceRestartBehavior value the device agent determines which settings are actually honored at runtime.')]
    [MSFT_DeviceManagementWindowsAutoUpdateCatalogMobileAppAssignmentSettingsRestartSettings] $restartSettings
}

class MSFT_DeviceManagementWindowsAutoUpdateCatalogMobileAppAssignmentSettingsInstallTimeSettings
{
    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether the startDateTime and deadlineDateTime values should be interpreted using the device''s local time zone. When false, the values are interpreted as UTC. Defaults to false if not specified.')]
    [System.Nullable[System.Boolean]] $useLocalTime

    [DscProperty()]
    [System.ComponentModel.Description('The time at which the app should be available for installation on the device. When null, the app is available immediately.')]
    [System.String] $startDateTime

    [DscProperty()]
    [System.ComponentModel.Description('The maximum allowed date and time by which the app must be installed on the device. After this deadline, the Intune management extension enforces installation automatically. When null, there is no enforced deadline.')]
    [System.String] $deadlineDateTime
}

class MSFT_DeviceManagementWindowsAutoUpdateCatalogMobileAppAssignmentSettingsRestartSettings
{
    [DscProperty()]
    [System.ComponentModel.Description('The number of minutes before the scheduled restart at which a countdown notification is displayed to the user. Must be between 1 and the value of gracePeriodInMinutes. This countdown is non-dismissible and warns the user that a restart is imminent. For example, a value of 15 means the countdown appears 15 minutes before the restart.')]
    [System.Nullable[System.Int32]] $countdownDisplayBeforeRestartInMinutes

    [DscProperty()]
    [System.ComponentModel.Description('The number of minutes the device waits after app installation before initiating a restart. During this period, the user can continue working and save their documents. For example, a value of 1440 means the device waits 24 hours before restarting.')]
    [System.Nullable[System.Int32]] $gracePeriodInMinutes

    [DscProperty()]
    [System.ComponentModel.Description('The number of minutes by which the user can defer (snooze) the restart notification each time they press the snooze button. When null, the snooze option is not available and the user cannot defer the restart. For example, a value of 240 allows the user to defer the restart by 4 hours each time.')]
    [System.Nullable[System.Int32]] $restartNotificationSnoozeDurationInMinutes
}

class MSFT_DeviceManagementMobileAppCategory
{
    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('The name of the app category.')]
    [System.String] $DisplayName

    [DscProperty()]
    [System.ComponentModel.Description('The unique identifier for an entity. Read-only.')]
    [System.String] $Id
}

class MSFT_MicrosoftGraphWindowsAutoUpdateCatalogAppInstallExperience
{
    [DscProperty()]
    [System.ComponentModel.Description('Indicates how the device handles restarts after the app installation completes. This controls whether the Intune management extension initiates, suppresses, or forces a device restart based on the installer''s exit code. Defaults to basedOnReturnCode if not specified. Possible values are: basedOnReturnCode, allow, suppress, force, unknownFutureValue.')]
    [ValidateSet('basedOnReturnCode', 'allow', 'suppress', 'force', 'unknownFutureValue')]
    [System.String] $DeviceRestartBehavior

    [DscProperty()]
    [System.ComponentModel.Description('Indicates the account context under which the app installer runs on the device. When set to system, the installer runs with elevated privileges in the SYSTEM account context. When set to user, the installer runs in the context of the currently logged-in user. Defaults to system if not specified. Possible values are: system, user.')]
    [ValidateSet('system', 'user')]
    [System.String] $RunAsAccount
}

class MSFT_MicrosoftGraphMimeContent
{
    [DscProperty()]
    [System.ComponentModel.Description('Indicates the content mime type.')]
    [System.String] $Type

    [DscProperty()]
    [System.ComponentModel.Description('The Base64 encoded string content.')]
    [System.String] $Value
}
