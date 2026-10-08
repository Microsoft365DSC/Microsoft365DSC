using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class IntuneMobileAppsWin32CatalogAppWindows10 : M365DSCResourceBase
{
    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether the uninstall is supported from the company portal for the Win32 app with an available assignment. When TRUE, indicates that uninstall is supported from the company portal for the Windows app (Win32) with an available assignment. When FALSE, indicates that uninstall is not supported for the Windows app (Win32) with an Available assignment. Default value is FALSE.')]
    [System.Nullable[System.Boolean]] $AllowAvailableUninstall

    [DscProperty()]
    [System.ComponentModel.Description('Indicates the Windows architecture(s) this app should be installed on. The app will be treated as not applicable for devices with architectures not matching the selected value. When a non-null value is provided for the allowedArchitectures property, the value of the applicableArchitectures property is set to none. Possible values are: null, x86, x64, arm64. Possible values are: none, x86, x64, arm, neutral, arm64.')]
    [ValidateSet('none', 'x86', 'x64', 'arm', 'neutral', 'arm64')]
    [System.String] $AllowedArchitectures

    [DscProperty()]
    [System.ComponentModel.Description('Represents the assignment to the Intune app.')]
    [MSFT_DeviceManagementWin32CatalogMobileAppAssignment[]] $Assignments

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
    [System.ComponentModel.Description('Indicates the version displayed in the UX for this app. Used to set the version of the app. Example: 1.0.3.215.')]
    [System.String] $DisplayVersion

    [DscProperty()]
    [System.ComponentModel.Description('The name of the main Lob application file.')]
    [System.String] $FileName

    [DscProperty()]
    [System.ComponentModel.Description('The unique identifier for an entity. Read-only.')]
    [System.String] $Id

    [DscProperty()]
    [System.ComponentModel.Description('The more information Url.')]
    [System.String] $InformationUrl

    [DscProperty()]
    [System.ComponentModel.Description('Indicates the command line to install this app. Used to install the Win32 app. Example: msiexec /i ''Orca.Msi'' /qn.')]
    [System.String] $InstallCommandLine

    [DscProperty()]
    [System.ComponentModel.Description('Indicates the install experience for this app.')]
    [MSFT_MicrosoftGraphWin32LobAppInstallExperience1] $InstallExperience

    [DscProperty()]
    [System.ComponentModel.Description('The value indicating whether the app is marked as featured by the admin.')]
    [System.Nullable[System.Boolean]] $IsFeatured

    [DscProperty()]
    [System.ComponentModel.Description('The large icon, to be displayed in the app details and used for upload of the icon.')]
    [MSFT_MicrosoftGraphMimeContent] $LargeIcon

    [DscProperty()]
    [System.ComponentModel.Description('Indicates the value for the minimum CPU speed which is required to install this app. Allowed range from 0 to clock speed from WMI helper.')]
    [System.Nullable[System.Int32]] $MinimumCpuSpeedInMHz

    [DscProperty()]
    [System.ComponentModel.Description('Indicates the value for the minimum free disk space which is required to install this app. Allowed range from 0 to driver''s maximum available free space.')]
    [System.Nullable[System.Int32]] $MinimumFreeDiskSpaceInMB

    [DscProperty()]
    [System.ComponentModel.Description('Indicates the value for the minimum physical memory which is required to install this app. Allowed range from 0 to total physical memory from WMI helper.')]
    [System.Nullable[System.Int32]] $MinimumMemoryInMB

    [DscProperty()]
    [System.ComponentModel.Description('Indicates the value for the minimum number of processors which is required to install this app. Minimum value is 0.')]
    [System.Nullable[System.Int32]] $MinimumNumberOfProcessors

    [DscProperty()]
    [System.ComponentModel.Description('Indicates the value for the minimum supported windows release. Example: Windows11_23H2.')]
    [System.String] $MinimumSupportedWindowsRelease

    [DscProperty()]
    [System.ComponentModel.Description('The mobileAppCatalogPackageId property references the mobileAppCatalogPackage entity which contains information about an application catalog package that can be deployed to Intune-managed devices')]
    [System.String] $MobileAppCatalogPackageId

    [DscProperty()]
    [System.ComponentModel.Description('Indicates the MSI details if this Win32 app is an MSI app.')]
    [MSFT_MicrosoftGraphWin32LobAppMsiInformation] $MsiInformation

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
    [System.ComponentModel.Description('Indicates the return codes for post installation behavior.')]
    [MSFT_MicrosoftGraphWin32LobAppReturnCode[]] $ReturnCodes

    [DscProperty()]
    [System.ComponentModel.Description('List of scope tag ids for this mobile app.')]
    [System.String[]] $RoleScopeTagIds

    [DscProperty()]
    [System.ComponentModel.Description('Indicates the detection and requirement rules for this app. Possible values are: Win32LobAppFileSystemRule, Win32LobAppPowerShellScriptRule, Win32LobAppProductCodeRule, Win32LobAppRegistryRule.')]
    [MSFT_MicrosoftGraphWin32LobAppRule1[]] $Rules

    [DscProperty()]
    [System.ComponentModel.Description('Indicates the relative path of the setup file in the encrypted Win32LobApp package. Example: Intel-SA-00075 Detection and Mitigation Tool.msi.')]
    [System.String] $SetupFilePath

    [DscProperty()]
    [System.ComponentModel.Description('Indicates the command line to uninstall this app. Used to uninstall the app. Example: msiexec /x ''85F4CBCB-9BBC-4B50-A7D8-E1106771498D}'' /qn.')]
    [System.String] $UninstallCommandLine

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

    [IntuneMobileAppsWin32CatalogAppWindows10] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [IntuneMobileAppsWin32CatalogAppWindows10]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of Intune Mobile Apps Win32 Catalog App for Windows10 {$($this.Id)}"

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
                        -ErrorAction SilentlyContinue | Where-Object -Property '@odata.type' -EQ '#microsoft.graph.win32CatalogApp' | Select-Object -First 1
                }

                if ($null -eq $getValue)
                {
                    Write-Verbose -Message "No Intune Mobile Apps Win32 Catalog App for Windows10 with Id {$($this.Id)} was found"
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


            Write-Verbose -Message "Found Intune Mobile Apps Win32 Catalog App for Windows10 with Id {$($this.Id)}"

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
            $complexInstallExperience.Add('InUseBehavior', $getValue.installExperience.inUseBehavior)
            $complexInstallExperience.Add('MaxRunTimeInMinutes', $getValue.installExperience.maxRunTimeInMinutes)
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

            $complexMsiInformation = [ordered]@{}
            $complexMsiInformation.Add('PackageType', $getValue.msiInformation.packageType)
            $complexMsiInformation.Add('ProductCode', $getValue.msiInformation.productCode)
            $complexMsiInformation.Add('ProductName', $getValue.msiInformation.productName)
            $complexMsiInformation.Add('ProductVersion', $getValue.msiInformation.productVersion)
            $complexMsiInformation.Add('Publisher', $getValue.msiInformation.publisher)
            $complexMsiInformation.Add('RequiresReboot', $getValue.msiInformation.requiresReboot)
            $complexMsiInformation.Add('UpgradeCode', $getValue.msiInformation.upgradeCode)
            if ($complexMsiInformation.values.Where({ $null -ne $_ }).Count -eq 0)
            {
                $complexMsiInformation = $null
            }

            $complexReturnCodes = @()
            foreach ($currentReturnCodes in $getValue.returnCodes)
            {
                $myReturnCodes = [ordered]@{}
                $myReturnCodes.Add('ReturnCode', $currentReturnCodes.returnCode)
                $myReturnCodes.Add('Type', $currentReturnCodes.type)
                if ($myReturnCodes.values.Where({ $null -ne $_ }).Count -gt 0)
                {
                    $complexReturnCodes += $myReturnCodes
                }
            }

            $complexRules = @()
            foreach ($currentRules in $getValue.rules)
            {
                $myRules = [ordered]@{}
                $myRules.Add('Check32BitOn64System', $currentRules.check32BitOn64System)
                $myRules.Add('ComparisonValue', $currentRules.comparisonValue)
                $myRules.Add('DisplayName', $currentRules.displayName)
                $myRules.Add('EnforceSignatureCheck', $currentRules.enforceSignatureCheck)
                $myRules.Add('FileOrFolderName', $currentRules.fileOrFolderName)
                $myRules.Add('KeyPath', $currentRules.keyPath)
                if ($null -ne $currentRules.'@odata.type')
                {
                    $myRules.Add('ODataType', $currentRules.'@odata.type')
                }
                $myRules.Add('OperationType', $currentRules.operationType)
                $myRules.Add('Operator', $currentRules.operator)
                $myRules.Add('Path', $currentRules.path)
                $myRules.Add('ProcessDisplayName', $currentRules.processDisplayName)
                $myRules.Add('ProcessName', $currentRules.processName)
                $myRules.Add('ProductCode', $currentRules.productCode)
                $myRules.Add('ProductVersion', $currentRules.productVersion)
                $myRules.Add('ProductVersionOperator', $currentRules.productVersionOperator)
                $myRules.Add('RuleType', $currentRules.ruleType)
                $myRules.Add('RunAs32Bit', $currentRules.runAs32Bit)
                $myRules.Add('RunAsAccount', $currentRules.runAsAccount)
                $myRules.Add('ScriptContent', $currentRules.scriptContent)
                $myRules.Add('ValueName', $currentRules.valueName)
                if ($myRules.values.Where({ $null -ne $_ }).Count -gt 0)
                {
                    $complexRules += $myRules
                }
            }

            $result = @{
                AllowAvailableUninstall        = $getValue.allowAvailableUninstall
                AllowedArchitectures           = $getValue.allowedArchitectures
                Categories                     = $complexCategories
                Description                    = $getValue.Description
                Developer                      = $getValue.Developer
                DisplayName                    = $getValue.DisplayName
                DisplayVersion                 = $getValue.displayVersion
                FileName                       = $getValue.fileName
                Id                             = $getValue.Id
                InformationUrl                 = $getValue.InformationUrl
                InstallCommandLine             = $getValue.installCommandLine
                InstallExperience              = $complexInstallExperience
                IsFeatured                     = $getValue.IsFeatured
                LargeIcon                      = $complexLargeIcon
                MinimumCpuSpeedInMHz           = $getValue.minimumCpuSpeedInMHz
                MinimumFreeDiskSpaceInMB       = $getValue.minimumFreeDiskSpaceInMB
                MinimumMemoryInMB              = $getValue.minimumMemoryInMB
                MinimumNumberOfProcessors      = $getValue.minimumNumberOfProcessors
                MinimumSupportedWindowsRelease = $getValue.minimumSupportedWindowsRelease
                MobileAppCatalogPackageId      = $getValue.mobileAppCatalogPackageId
                MsiInformation                 = $complexMsiInformation
                Notes                          = $getValue.Notes
                Owner                          = $getValue.Owner
                PrivacyInformationUrl          = $getValue.PrivacyInformationUrl
                Publisher                      = $getValue.Publisher
                ReturnCodes                    = [Array]$complexReturnCodes
                RoleScopeTagIds                = Resolve-M365DSCIntuneRoleScopeTagNames -CurrentValues $getValue.RoleScopeTagIds -DesiredValues $this.RoleScopeTagIds
                Rules                          = [Array]$complexRules
                SetupFilePath                  = $getValue.setupFilePath
                UninstallCommandLine           = $getValue.uninstallCommandLine
                Ensure                         = 'Present'
                Credential                     = $this.Credential
                ApplicationId                  = $this.ApplicationId
                TenantId                       = $this.TenantId
                ApplicationSecret              = $this.ApplicationSecret
                CertificateThumbprint          = $this.CertificateThumbprint
                CertificatePassword            = $this.CertificatePassword
                CertificatePath                = $this.CertificatePath
                ManagedIdentity                = $this.ManagedIdentity
                AccessTokens                   = $this.AccessTokens
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

        Write-Verbose -Message "Setting configuration of Intune Mobile Apps Win32 Catalog App for Windows10 {$($this.Id)}"

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

            $this.RemoveForeignSubtypeProperties($boundParameters, @{
                    '#microsoft.graph.win32LobAppFileSystemRule'      = @('ruleType', 'path', 'fileOrFolderName', 'check32BitOn64System', 'operationType', 'operator', 'comparisonValue')
                    '#microsoft.graph.win32LobAppPowerShellScriptRule' = @('ruleType', 'displayName', 'enforceSignatureCheck', 'runAs32Bit', 'runAsAccount', 'scriptContent', 'operationType', 'operator', 'comparisonValue')
                    '#microsoft.graph.win32LobAppProductCodeRule'     = @('ruleType', 'productCode', 'productVersionOperator', 'productVersion')
                    '#microsoft.graph.win32LobAppRegistryRule'        = @('ruleType', 'check32BitOn64System', 'keyPath', 'valueName', 'operationType', 'operator', 'comparisonValue')
                })
            $boundParameters.Remove('Id') | Out-Null
            $boundParameters.Remove('Assignments') | Out-Null
            $boundParameters.Remove('Categories') | Out-Null
            $boundParameters.Add('@odata.type', '#microsoft.graph.win32CatalogApp')

            if ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
            {
                Write-Verbose -Message "Creating new Intune Mobile Apps Win32 Catalog App for Windows10 {$($this.Id)}"

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
                Write-Verbose -Message "Updating Intune Mobile Apps Win32 Catalog App for Windows10 {$($this.Id)}"

                $updateParameters = $boundParameters
                $updateParameters.Remove('MobileAppCatalogPackageId') | Out-Null
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
                Write-Verbose -Message "Removing Intune Mobile Apps Win32 Catalog App for Windows10 {$($this.Id)}"
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
            ExcludedProperties = @('MobileAppCatalogPackageId')
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
            $baseFilter = "isof('microsoft.graph.win32CatalogApp')"
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
                            CIMInstanceName = 'DeviceManagementWin32CatalogMobileAppAssignmentSettings'
                            IsRequired      = $false
                        },
                        @{
                            Name            = 'AutoUpdateSettings'
                            CIMInstanceName = 'DeviceManagementWin32CatalogMobileAppAssignmentSettingsAutoUpdateSettings'
                            IsRequired      = $false
                        },
                        @{
                            Name            = 'InstallTimeSettings'
                            CIMInstanceName = 'DeviceManagementWin32CatalogMobileAppAssignmentSettingsInstallTimeSettings'
                            IsRequired      = $false
                        },
                        @{
                            Name            = 'RestartSettings'
                            CIMInstanceName = 'DeviceManagementWin32CatalogMobileAppAssignmentSettingsRestartSettings'
                            IsRequired      = $false
                        }
                    )
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.Assignments `
                        -CIMInstanceName DeviceManagementWin32CatalogMobileAppAssignment `
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
                        -CIMInstanceName 'MSFT_MicrosoftGraphWin32LobAppInstallExperience1'
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

                if ($null -ne $Results.MsiInformation)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.MsiInformation `
                        -CIMInstanceName 'MSFT_MicrosoftGraphWin32LobAppMsiInformation'
                    if (-not [System.String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.MsiInformation = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('MsiInformation') | Out-Null
                    }
                }

                if ($null -ne $Results.ReturnCodes)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.ReturnCodes `
                        -CIMInstanceName 'MSFT_MicrosoftGraphWin32LobAppReturnCode'
                    if (-not [System.String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.ReturnCodes = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('ReturnCodes') | Out-Null
                    }
                }

                if ($null -ne $Results.Rules)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.Rules `
                        -CIMInstanceName 'MSFT_MicrosoftGraphWin32LobAppRule1'
                    if (-not [System.String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.Rules = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('Rules') | Out-Null
                    }
                }
                $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                    -ConnectionMode $ConnectionMode `
                    -ModulePath $this.GetModulePath() `
                    -Results $Results `
                    -Credential $this.Credential `
                    -NoEscape @('Assignments', 'Categories', 'InstallExperience', 'LargeIcon', 'MsiInformation', 'ReturnCodes', 'Rules')
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

    hidden [IntuneMobileAppsWin32CatalogAppWindows10] AsResult([System.Object] $Values)
    {
        if ($Values -is [IntuneMobileAppsWin32CatalogAppWindows10])
        {
            return $Values
        }

        $result = [IntuneMobileAppsWin32CatalogAppWindows10]::new()
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

class MSFT_DeviceManagementWin32CatalogMobileAppAssignment : MSFT_DeviceManagementMobileAppAssignment
{
    [DscProperty()]
    [System.ComponentModel.Description('The settings of the assignment.')]
    [MSFT_DeviceManagementWin32CatalogMobileAppAssignmentSettings] $assignmentSettings
}

class MSFT_DeviceManagementMobileAppAssignmentSettings
{
    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('The odata type of the assignment type.')]
    [ValidateSet('#microsoft.graph.androidManagedStoreAppAssignmentSettings', '#microsoft.graph.iosStoreAppAssignmentSettings', '#microsoft.graph.iosLobAppAssignmentSettings', '#microsoft.graph.macOsLobAppAssignmentSettings', '#microsoft.graph.win32CatalogAppAssignmentSettings', '#microsoft.graph.win32LobAppAssignmentSettings', '#microsoft.graph.winGetAppAssignmentSettings', '#microsoft.graph.windowsAutoUpdateCatalogAppAssignmentSettings', '#microsoft.graph.windowsUniversalAppXAppAssignmentSettings')]
    [System.String] $odataType
}

class MSFT_DeviceManagementWin32CatalogMobileAppAssignmentSettings : MSFT_DeviceManagementMobileAppAssignmentSettings
{
    [DscProperty()]
    [System.ComponentModel.Description('The auto-update settings to apply for this app assignment.')]
    [MSFT_DeviceManagementWin32CatalogMobileAppAssignmentSettingsAutoUpdateSettings] $autoUpdateSettings

    [DscProperty()]
    [System.ComponentModel.Description('The delivery optimization priority for this app assignment. This setting is not supported in National Cloud environments. The possible values are: notConfigured, foreground.')]
    [ValidateSet('notConfigured', 'foreground')]
    [System.String] $deliveryOptimizationPriority

    [DscProperty()]
    [System.ComponentModel.Description('The install time settings to apply for this app assignment.')]
    [MSFT_DeviceManagementWin32CatalogMobileAppAssignmentSettingsInstallTimeSettings] $installTimeSettings

    [DscProperty()]
    [System.ComponentModel.Description('The notification status for this app assignment. The possible values are: showAll, showReboot, hideAll.')]
    [ValidateSet('showAll', 'showReboot', 'hideAll')]
    [System.String] $notifications

    [DscProperty()]
    [System.ComponentModel.Description('The reboot settings to apply for this app assignment.')]
    [MSFT_DeviceManagementWin32CatalogMobileAppAssignmentSettingsRestartSettings] $restartSettings
}

class MSFT_DeviceManagementWin32CatalogMobileAppAssignmentSettingsAutoUpdateSettings
{
    [DscProperty()]
    [System.ComponentModel.Description('The auto-update superseded apps state setting for the app assignment. Possible values are notConfigured and enabled. Default value is notConfigured. The possible values are: notConfigured, enabled, unknownFutureValue.')]
    [ValidateSet('notConfigured', 'enabled', 'unknownFutureValue')]
    [System.String] $autoUpdateSupersededAppsState
}

class MSFT_DeviceManagementWin32CatalogMobileAppAssignmentSettingsInstallTimeSettings
{
    [DscProperty()]
    [System.ComponentModel.Description('Whether the local device time or UTC time should be used when determining the available and deadline times.')]
    [System.Nullable[System.Boolean]] $useLocalTime

    [DscProperty()]
    [System.ComponentModel.Description('The time at which the app should be available for installation.')]
    [System.String] $startDateTime

    [DscProperty()]
    [System.ComponentModel.Description('The time at which the app should be installed.')]
    [System.String] $deadlineDateTime
}

class MSFT_DeviceManagementWin32CatalogMobileAppAssignmentSettingsRestartSettings
{
    [DscProperty()]
    [System.ComponentModel.Description('The number of minutes before the restart time to display the countdown dialog for pending restarts.')]
    [System.Nullable[System.Int32]] $countdownDisplayBeforeRestartInMinutes

    [DscProperty()]
    [System.ComponentModel.Description('The number of minutes to wait before restarting the device after an app installation.')]
    [System.Nullable[System.Int32]] $gracePeriodInMinutes

    [DscProperty()]
    [System.ComponentModel.Description('The number of minutes to snooze the restart notification dialog when the snooze button is selected.')]
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

class MSFT_MicrosoftGraphWin32LobAppInstallExperience1
{
    [DscProperty()]
    [System.ComponentModel.Description('Device restart behavior. Possible values are: basedOnReturnCode, allow, suppress, force.')]
    [ValidateSet('basedOnReturnCode', 'allow', 'suppress', 'force')]
    [System.String] $DeviceRestartBehavior

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether app-in-use detection is enabled before app enforcement, and if enabled, the action to take when the app is detected to be in-use. Null indicates the feature is not enabled. Possible values are: notEnabled, fail, terminateWithoutUserInteraction, terminateWithUserInteraction.')]
    [ValidateSet('notEnabled', 'fail', 'terminateWithoutUserInteraction', 'terminateWithUserInteraction', 'unknownFutureValue')]
    [System.String] $InUseBehavior

    [DscProperty()]
    [System.ComponentModel.Description('The number of minutes the system will wait for install program to finish. Default value is 60 minutes.')]
    [System.Nullable[System.Int32]] $MaxRunTimeInMinutes

    [DscProperty()]
    [System.ComponentModel.Description('Indicates the type of execution context the app runs in. Possible values are: system, user.')]
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

class MSFT_MicrosoftGraphWin32LobAppMsiInformation
{
    [DscProperty()]
    [System.ComponentModel.Description('The MSI product code.')]
    [System.String] $ProductCode

    [DscProperty()]
    [System.ComponentModel.Description('The MSI product version.')]
    [System.String] $ProductVersion

    [DscProperty()]
    [System.ComponentModel.Description('The MSI upgrade code.')]
    [System.String] $UpgradeCode

    [DscProperty()]
    [System.ComponentModel.Description('Whether the MSI app requires the machine to reboot to complete installation.')]
    [System.Nullable[System.Boolean]] $RequiresReboot

    [DscProperty()]
    [System.ComponentModel.Description('The MSI package type. Possible values are: perMachine, perUser, dualPurpose.')]
    [ValidateSet('perMachine', 'perUser', 'dualPurpose')]
    [System.String] $PackageType

    [DscProperty()]
    [System.ComponentModel.Description('The MSI product name.')]
    [System.String] $ProductName

    [DscProperty()]
    [System.ComponentModel.Description('The MSI publisher')]
    [System.String] $Publisher
}

class MSFT_MicrosoftGraphWin32LobAppReturnCode
{
    [DscProperty()]
    [System.ComponentModel.Description('Return code.')]
    [System.Nullable[System.Int32]] $ReturnCode

    [DscProperty()]
    [System.ComponentModel.Description('The type of return code. Possible values are: failed, success, softReboot, hardReboot, retry.')]
    [ValidateSet('failed', 'success', 'softReboot', 'hardReboot', 'retry')]
    [System.String] $Type
}

class MSFT_MicrosoftGraphWin32LobAppRule1
{
    [DscProperty()]
    [System.ComponentModel.Description('A value indicating whether to expand environment variables in the 32-bit context on 64-bit systems.')]
    [System.Nullable[System.Boolean]] $Check32BitOn64System

    [DscProperty()]
    [System.ComponentModel.Description('The file or folder comparison value.')]
    [System.String] $ComparisonValue

    [DscProperty()]
    [System.ComponentModel.Description('The display name for the rule. Do not specify this value if the rule is used for detection.')]
    [System.String] $DisplayName

    [DscProperty()]
    [System.ComponentModel.Description('A value indicating whether a signature check is enforced.')]
    [System.Nullable[System.Boolean]] $EnforceSignatureCheck

    [DscProperty()]
    [System.ComponentModel.Description('The file or folder name to look up.')]
    [System.String] $FileOrFolderName

    [DscProperty()]
    [System.ComponentModel.Description('The full path of the registry entry containing the value to detect.')]
    [System.String] $KeyPath

    [DscProperty()]
    [System.ComponentModel.Description('The type of the entity.')]
    [ValidateSet('#microsoft.graph.win32LobAppFileSystemRule', '#microsoft.graph.win32LobAppPowerShellScriptRule', '#microsoft.graph.win32LobAppProcessRule', '#microsoft.graph.win32LobAppProductCodeRule', '#microsoft.graph.win32LobAppRegistryRule')]
    [System.String] $ODataType

    [DscProperty()]
    [System.ComponentModel.Description('The file system operation type. Possible values are: notConfigured, exists, modifiedDate, createdDate, version, sizeInMB, doesNotExist, sizeInBytes, appVersion, unknownFutureValue.')]
    [ValidateSet('notConfigured', 'exists', 'modifiedDate', 'createdDate', 'version', 'sizeInMB', 'doesNotExist', 'sizeInBytes', 'appVersion', 'unknownFutureValue', 'string', 'dateTime', 'integer', 'float', 'boolean')]
    [System.String] $OperationType

    [DscProperty()]
    [System.ComponentModel.Description('The operator for file or folder detection. Possible values are: notConfigured, equal, notEqual, greaterThan, greaterThanOrEqual, lessThan, lessThanOrEqual.')]
    [ValidateSet('notConfigured', 'equal', 'notEqual', 'greaterThan', 'greaterThanOrEqual', 'lessThan', 'lessThanOrEqual')]
    [System.String] $Operator

    [DscProperty()]
    [System.ComponentModel.Description('The file or folder path to look up.')]
    [System.String] $Path

    [DscProperty()]
    [System.ComponentModel.Description('Indicates the display name for the process in the Intune admin console. Example: Microsoft Word.')]
    [System.String] $ProcessDisplayName

    [DscProperty()]
    [System.ComponentModel.Description('Indicates the process name to be searched for on a managed device when enforcing a managed app. Example: TestApp.exe.')]
    [System.String] $ProcessName

    [DscProperty()]
    [System.ComponentModel.Description('The product code of the app.')]
    [System.String] $ProductCode

    [DscProperty()]
    [System.ComponentModel.Description('The product version comparison value.')]
    [System.String] $ProductVersion

    [DscProperty()]
    [System.ComponentModel.Description('The product version comparison operator. Possible values are: notConfigured, equal, notEqual, greaterThan, greaterThanOrEqual, lessThan, lessThanOrEqual.')]
    [ValidateSet('notConfigured', 'equal', 'notEqual', 'greaterThan', 'greaterThanOrEqual', 'lessThan', 'lessThanOrEqual')]
    [System.String] $ProductVersionOperator

    [DscProperty()]
    [System.ComponentModel.Description('The rule type indicating the purpose of the rule. Possible values are: detection, requirement.')]
    [ValidateSet('detection', 'requirement')]
    [System.String] $RuleType

    [DscProperty()]
    [System.ComponentModel.Description('A value indicating whether the script should run as 32-bit.')]
    [System.Nullable[System.Boolean]] $RunAs32Bit

    [DscProperty()]
    [System.ComponentModel.Description('The execution context of the script. Do not specify this value if the rule is used for detection. Script detection rules will run in the same context as the associated app install context. Possible values are: system, user.')]
    [ValidateSet('system', 'user')]
    [System.String] $RunAsAccount

    [DscProperty()]
    [System.ComponentModel.Description('The base64-encoded script content.')]
    [System.String] $ScriptContent

    [DscProperty()]
    [System.ComponentModel.Description('The name of the registry value to detect.')]
    [System.String] $ValueName
}
