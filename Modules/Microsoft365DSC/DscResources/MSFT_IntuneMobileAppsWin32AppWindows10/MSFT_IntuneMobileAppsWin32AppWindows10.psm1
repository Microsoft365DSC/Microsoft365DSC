using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class IntuneMobileAppsWin32AppWindows10 : M365DSCResourceBase
{
    [DscProperty()]
    [System.ComponentModel.Description('The unique identifier for an entity. Read-only.')]
    [System.String] $Id

    [DscProperty(Key)]
    [System.ComponentModel.Description('The admin provided or imported title of the app.')]
    [System.String] $DisplayName

    [DscProperty()]
    [System.ComponentModel.Description('The description of the app.')]
    [System.String] $Description

    [DscProperty()]
    [System.ComponentModel.Description('The developer of the app.')]
    [System.String] $Developer

    [DscProperty()]
    [System.ComponentModel.Description('The more information Url.')]
    [System.String] $InformationUrl

    [DscProperty()]
    [System.ComponentModel.Description('The value indicating whether the app is marked as featured by the admin.')]
    [System.Nullable[System.Boolean]] $IsFeatured

    [DscProperty()]
    [System.ComponentModel.Description('The large icon, to be displayed in the app details and used for upload of the icon.')]
    [MSFT_DeviceManagementMimeContent] $LargeIcon

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
    [System.ComponentModel.Description('The file name of the app. Required for creating the resource.')]
    [System.String] $FileName

    [DscProperty()]
    [System.ComponentModel.Description('List of scope tag ids for this mobile app.')]
    [System.String[]] $RoleScopeTagIds

    [DscProperty()]
    [System.ComponentModel.Description('The list of categories for this app.')]
    [MSFT_DeviceManagementMobileAppCategory[]] $Categories

    [DscProperty()]
    [System.ComponentModel.Description('Indicates the command line to install this app. Used to install the Win32 app. Example: msiexec /i ''Orca.Msi'' /qn.')]
    [System.String] $InstallCommandLine

    [DscProperty()]
    [System.ComponentModel.Description('Indicates the command line to uninstall this app. Used to uninstall the app. Example: msiexec /x ''{85F4CBCB-9BBC-4B50-A7D8-E1106771498D}'' /qn.')]
    [System.String] $UninstallCommandLine

    [DscProperty()]
    [System.ComponentModel.Description('Indicates the Windows architecture(s) this app should be installed on. The app will be treated as not applicable for devices with architectures not matching the selected value. The value ''none'' cannot be combined with other values.')]
    [ValidateSet('none', 'x86', 'x64', 'arm64', 'arm', 'neutral')]
    [System.String[]] $AllowedArchitectures

    [DscProperty()]
    [System.ComponentModel.Description('Indicates the value for the minimum free disk space which is required to install this app.')]
    [System.Nullable[System.Int32]] $MinimumFreeDiskSpaceInMB

    [DscProperty()]
    [System.ComponentModel.Description('Indicates the value for the minimum physical memory which is required to install this app.')]
    [System.Nullable[System.Int32]] $MinimumMemoryInMB

    [DscProperty()]
    [System.ComponentModel.Description('Indicates the value for the minimum number of processors which is required to install this app.')]
    [System.Nullable[System.Int32]] $MinimumNumberOfProcessors

    [DscProperty()]
    [System.ComponentModel.Description('Indicates the value for the minimum CPU speed which is required to install this app.')]
    [System.Nullable[System.Int32]] $MinimumCpuSpeedInMHz

    [DscProperty()]
    [System.ComponentModel.Description('Indicates the detection and requirement rules for this app.')]
    [MSFT_MicrosoftGraphWin32LobAppRule[]] $Rules

    [DscProperty()]
    [System.ComponentModel.Description('Indicates the install experience for this app.')]
    [MSFT_MicrosoftGraphWin32LobAppInstallExperience] $InstallExperience

    [DscProperty()]
    [System.ComponentModel.Description('Indicates the return codes for post installation behavior.')]
    [MSFT_MicrosoftGraphWin32LobAppReturnCode[]] $ReturnCodes

    [DscProperty()]
    [System.ComponentModel.Description('Indicates the MSI details if this Win32 app is an MSI app.')]
    [MSFT_MicrosoftGraphWin32LobAppMsiInformation] $MsiInformation

    [DscProperty()]
    [System.ComponentModel.Description('Indicates the relative path of the setup file in the encrypted Win32LobApp package.')]
    [System.String] $SetupFilePath

    [DscProperty()]
    [System.ComponentModel.Description('Indicates the value for the minimum supported windows release. Format for Windows 10: <VersionNumber>, e.g. ''1709'' or ''20H2''. For Windows 11: ''Windows11_<VersionNumber>'', e.g. ''Windows11_21H2''')]
    [System.String] $MinimumSupportedWindowsRelease

    [DscProperty()]
    [System.ComponentModel.Description('Indicates the version displayed in the UX for this app. Used to set the version of the app. Example: 1.0.3.215.')]
    [System.String] $DisplayVersion

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether the uninstall is supported from the company portal for the Win32 app with an available assignment. When TRUE, indicates that uninstall is supported from the company portal for the Windows app (Win32) with an available assignment. When FALSE, indicates that uninstall is not supported for the Windows app (Win32) with an Available assignment.')]
    [System.Nullable[System.Boolean]] $AllowAvailableUninstall

    [DscProperty()]
    [System.ComponentModel.Description('Represents the assignment to the Intune policy.')]
    [MSFT_DeviceManagementWin32MobileAppAssignment[]] $Assignments

    [DscProperty()]
    [System.ComponentModel.Description('The set of direct relationships for this app.')]
    [MSFT_MicrosoftGraphMobileAppRelationship[]] $Relationships

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

    [IntuneMobileAppsWin32AppWindows10] Get()
    {
        $complexMsiInformation = $null
        $complexInstallExperience = $null
        if ($this.RequiresPowerShellCore())
        {
            $remote = [IntuneMobileAppsWin32AppWindows10]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration for the Intune Mobile Apps Win32 App for Windows10 with Id {$($this.Id)} and DisplayName {$($this.DisplayName)}"

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
                if (-not [System.String]::IsNullOrEmpty($this.Id))
                {
                    $getValue = Get-MgBetaDeviceAppManagementMobileApp -MobileAppId $this.Id -ExpandProperty 'Categories' -ErrorAction SilentlyContinue
                }

                if ($null -eq $getValue)
                {
                    Write-Verbose -Message "Could not find an Intune Mobile Apps Win32 App for Windows10 with Id {$($this.Id)}"

                    if (-not [System.String]::IsNullOrEmpty($this.DisplayName))
                    {
                        $getValue = Get-MgBetaDeviceAppManagementMobileApp `
                            -Filter "DisplayName eq '$($this.DisplayName -replace "'", "''")'" `
                            -All `
                            -ErrorAction SilentlyContinue | Where-Object -Property '@odata.type' -EQ '#microsoft.graph.win32LobApp'
                    }
                }
                #endregion
                if ($null -eq $getValue)
                {
                    Write-Verbose -Message "Could not find an Intune Mobile Apps Win32 App for Windows10 with DisplayName {$($this.DisplayName)}."
                    return $this.AsResult($nullResult)
                }

                $getValue = Get-MgBetaDeviceAppManagementMobileApp -MobileAppId $getValue.Id -ExpandProperty 'Categories'
            }
            else
            {
                $getValue = Get-MgBetaDeviceAppManagementMobileApp -MobileAppId $this.ExportedInstance.Id -ExpandProperty 'Categories'
            }
            $resolvedId = $getValue.Id
            Write-Verbose -Message "An Intune Mobile Apps Win32 App for Windows10 with Id {$($resolvedId)} and DisplayName {$($this.DisplayName)} was found"

            #region resource generator code
            $complexCategories = @()
            foreach ($category in $getValue.Categories)
            {
                $myCategory = [ordered]@{}
                $myCategory.Add('Id', $category.id)
                $myCategory.Add('DisplayName', $category.displayName)
                $complexCategories += $myCategory
            }
            $complexLargeIcon = $null
            if ($null -ne $getValue.LargeIcon.Value)
            {
                $complexLargeIcon = [ordered]@{}
                $complexLargeIcon.Add('Type', $getValue.LargeIcon.Type)
                $complexLargeIcon.Add('Value', $getValue.LargeIcon.Value)
            }

            $complexRules = @()
            foreach ($rule in $getValue.rules)
            {
                $ruleType = $rule.'@odata.type'.Replace('#microsoft.graph.win32LobApp', '').Replace('Rule', '')
                $baseRule = @{
                    OdataType       = $ruleType
                    RuleType        = $rule.ruleType
                    Operator        = $rule.operator
                    ComparisonValue = $rule.comparisonValue
                }
                switch ($ruleType)
                {
                    'FileSystem'
                    {
                        $baseRule.Add('Check32BitOn64System', $rule.check32BitOn64System)
                        $baseRule.Add('Path', $rule.path)
                        $baseRule.Add('FileOrFolderName', $rule.fileOrFolderName)
                        $baseRule.Add('FileSystemOperationType', $rule.operationType)
                    }
                    'Registry'
                    {
                        $baseRule.Add('Check32BitOn64System', $rule.check32BitOn64System)
                        $baseRule.Add('KeyPath', $rule.keyPath)
                        $baseRule.Add('RegistryOperationType', $rule.operationType)
                        $baseRule.Add('ValueName', $rule.valueName)
                    }
                    'ProductCode'
                    {
                        $baseRule.Add('ProductCode', $rule.productCode)
                        $baseRule.Add('ProductVersionOperator', $rule.productVersionOperator)
                        $baseRule.Add('ProductVersion', $rule.productVersion)
                        $baseRule.Remove('Operator') | Out-Null
                        $baseRule.Remove('ComparisonValue') | Out-Null
                    }
                    'PowerShellScript'
                    {
                        $baseRule.Add('DisplayName', $rule.displayName)
                        $baseRule.Add('Script', $this.DecodeTextPayload($rule.scriptContent))
                        $baseRule.Add('RunAs32Bit', $rule.runAs32Bit)
                        $baseRule.Add('EnforceSignatureCheck', $rule.enforceSignatureCheck)
                        $baseRule.Add('RunAsAccount', $rule.runAsAccount)
                        $baseRule.Add('PowerShellScriptOperationType', $rule.operationType)
                    }
                }
                $complexRules += $baseRule
            }

            if ($null -ne $getValue.installExperience)
            {
                $complexInstallExperience = [ordered]@{}
                $complexInstallExperience.Add('DeviceRestartBehavior', $getValue.installExperience.deviceRestartBehavior)
                $complexInstallExperience.Add('MaxRunTimeInMinutes', $getValue.installExperience.maxRunTimeInMinutes)
                $complexInstallExperience.Add('RunAsAccount', $getValue.installExperience.runAsAccount)
            }

            $complexReturnCodes = @()
            foreach ($returnCode in $getValue.returnCodes)
            {
                $complexReturnCodes += @{
                    ReturnCode = $returnCode.returnCode
                    Type       = $returnCode.type
                }
            }

            if ($null -ne $getValue.msiInformation)
            {
                $complexMsiInformation = [ordered]@{}
                $complexMsiInformation.Add('ProductCode', $getValue.msiInformation.productCode)
                $complexMsiInformation.Add('ProductVersion', $getValue.msiInformation.productVersion)
                $complexMsiInformation.Add('UpgradeCode', $getValue.msiInformation.upgradeCode)
                $complexMsiInformation.Add('RequiresReboot', $getValue.msiInformation.requiresReboot)
                $complexMsiInformation.Add('PackageType', $getValue.msiInformation.packageType)
                $complexMsiInformation.Add('ProductName', $getValue.msiInformation.productName)
                $complexMsiInformation.Add('Publisher', $getValue.msiInformation.publisher)
            }
            #endregion

            [System.String[]]$allowedArchitecturesValue = @()
            foreach ($arch in ($getValue.allowedArchitectures -split ',' | Where-Object -FilterScript { -not [System.String]::IsNullOrEmpty($_) }))
            {
                $allowedArchitecturesValue += $arch
            }

            $results = @{
                #region resource generator code
                AllowedArchitectures           = $allowedArchitecturesValue
                Categories                     = $complexCategories
                Description                    = $getValue.Description
                Developer                      = $getValue.Developer
                DisplayName                    = $getValue.DisplayName
                FileName                       = $getValue.fileName
                InformationUrl                 = $getValue.InformationUrl
                InstallCommandLine             = $getValue.installCommandLine
                UninstallCommandLine           = $getValue.uninstallCommandLine
                MinimumFreeDiskSpaceInMB       = $getValue.minimumFreeDiskSpaceInMB
                MinimumMemoryInMB              = $getValue.minimumMemoryInMB
                MinimumNumberOfProcessors      = $getValue.minimumNumberOfProcessors
                MinimumCpuSpeedInMHz           = $getValue.minimumCpuSpeedInMHz
                InstallExperience              = $complexInstallExperience
                ReturnCodes                    = $complexReturnCodes
                Rules                          = $complexRules
                MsiInformation                 = $complexMsiInformation
                SetupFilePath                  = $getValue.setupFilePath
                MinimumSupportedWindowsRelease = $getValue.minimumSupportedWindowsRelease
                DisplayVersion                 = $getValue.displayVersion
                AllowAvailableUninstall        = $getValue.allowAvailableUninstall
                IsFeatured                     = $getValue.IsFeatured
                LargeIcon                      = $complexLargeIcon
                Notes                          = $getValue.Notes
                Owner                          = $getValue.Owner
                PrivacyInformationUrl          = $getValue.PrivacyInformationUrl
                Publisher                      = $getValue.Publisher
                RoleScopeTagIds                = Resolve-M365DSCIntuneRoleScopeTagNames -CurrentValues $getValue.RoleScopeTagIds -DesiredValues $this.RoleScopeTagIds
                Id                             = $getValue.Id
                Ensure                         = 'Present'
                Credential                     = $this.Credential
                ApplicationId                  = $this.ApplicationId
                TenantId                       = $this.TenantId
                ApplicationSecret              = $this.ApplicationSecret
                CertificateThumbprint          = $this.CertificateThumbprint
                CertificatePath                = $this.CertificatePath
                CertificatePassword            = $this.CertificatePassword
                ManagedIdentity                = $this.ManagedIdentity
                #endregion
            }
            $assignmentsValues = Get-MgBetaDeviceAppManagementMobileAppAssignment -MobileAppId $resolvedId
            $assignmentResult = @()
            if ($assignmentsValues.Count -gt 0)
            {
                [array]$assignmentsValues = $assignmentsValues | Where-Object -Property source -EQ 'direct'
                $assignmentResult += ConvertFrom-IntuneMobileAppAssignment -Assignments $assignmentsValues -IncludeDeviceFilter $true
            }
            foreach ($assignment in $assignmentResult)
            {
                if ($assignment.assignmentSettings.installTimeSettings.deadlineDateTime -is [System.DateTime])
                {
                    $assignment.assignmentSettings.installTimeSettings.deadlineDateTime = $assignment.assignmentSettings.installTimeSettings.deadlineDateTime.ToString("yyyy-MM-ddTHH:mm:ssZ")
                }
                if ($assignment.assignmentSettings.installTimeSettings.startDateTime -is [System.DateTime])
                {
                    $assignment.assignmentSettings.installTimeSettings.startDateTime = $assignment.assignmentSettings.installTimeSettings.startDateTime.ToString("yyyy-MM-ddTHH:mm:ssZ")
                }
            }
            $results.Add('Assignments', $assignmentResult)

            $relationshipsUri = (Get-MSCloudLoginConnectionProfile -Workload MicrosoftGraph).ResourceUrl + "beta/deviceAppManagement/mobileApps/$resolvedId/relationships"
            $relationshipsResponse = Invoke-MgGraphRequest -Method GET -Uri $relationshipsUri -ErrorAction Stop
            $relationshipsResult = @()
            if ($null -ne $relationshipsResponse -and $null -ne $relationshipsResponse.value)
            {
                foreach ($relationship in $relationshipsResponse.value)
                {
                    $myRelationship = [ordered]@{}
                    $myRelationship.Add('odataType', $relationship.'@odata.type')
                    $myRelationship.Add('targetId', $relationship.targetId)
                    $myRelationship.Add('targetDisplayName', $relationship.targetDisplayName)
                    switch ($relationship.'@odata.type')
                    {
                        '#microsoft.graph.mobileAppDependency'
                        {
                            $myRelationship.Add('dependencyType', $relationship.dependencyType)
                        }
                        '#microsoft.graph.mobileAppSupersedence'
                        {
                            $myRelationship.Add('supersedenceType', $relationship.supersedenceType)
                        }
                    }
                    $relationshipsResult += $myRelationship
                }
            }
            $results.Add('Relationships', $relationshipsResult)

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

        Write-Verbose -Message "Setting configuration of the Intune Mobile Apps Win32 App for Windows10 with Id {$($this.Id)} and DisplayName {$($this.DisplayName)}"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $currentInstance = $this.Get().ToHashtable()
        $boundParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()

        if ($boundParameters.ContainsKey('RoleScopeTagIds'))
        {
            $boundParameters.RoleScopeTagIds = Resolve-M365DSCIntuneRoleScopeTagIds -RoleScopeTagIds $this.RoleScopeTagIds
        }

        $boundParameters.Remove('Categories') | Out-Null
        $boundParameters.Remove('Relationships') | Out-Null

        if ($boundParameters.ContainsKey('AllowedArchitectures'))
        {
            if ($boundParameters.AllowedArchitectures -contains 'none' -and $boundParameters.AllowedArchitectures.Count -gt 1)
            {
                throw "AllowedArchitectures cannot contain 'none' when other architectures are specified."
            }

            $boundParameters.Remove('AllowedArchitectures') | Out-Null
            $boundParameters.Add('allowedArchitectures', ($this.GetBoundParameters().AllowedArchitectures -join ','))
            $boundParameters.Add('applicableArchitectures', 'none')

            if ([System.String]::IsNullOrEmpty($boundParameters.allowedArchitectures))
            {
                $boundParameters.allowedArchitectures = $null
            }
        }

        $boundParameters = Rename-M365DSCCimInstanceParameter -Properties $boundParameters

        if ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Creating an Intune Mobile Apps Win32 App for Windows10 with DisplayName {$($this.DisplayName)}"
            $createParameters = $boundParameters
            $createParameters.Remove('Assignments') | Out-Null

            if (-not $createParameters.ContainsKey('FileName') -or [System.String]::IsNullOrEmpty($createParameters.FileName))
            {
                throw 'FileName is required to create an Intune Mobile Apps Win32 App for Windows10.'
            }

            $createParameters.Remove('Id') | Out-Null

            if ($createParameters.ContainsKey('Rules'))
            {
                $rulesToProcess = @()
                $rulesToProcess = $createParameters.Rules

                foreach ($rule in $rulesToProcess)
                {
                    $odataType = $rule.'@odata.type'
                    $rule.'@odata.type' = "#microsoft.graph.win32LobApp$($odataType)Rule"
                    switch ($odataType)
                    {
                        'FileSystem'
                        {
                            $rule.Add('operationType', $rule.fileSystemOperationType)
                            $rule.Remove('fileSystemOperationType') | Out-Null
                        }
                        'Registry'
                        {
                            $rule.Add('operationType', $rule.registryOperationType)
                            $rule.Remove('registryOperationType') | Out-Null
                        }
                        'PowerShellScript'
                        {
                            $rule.Add('scriptContent', $this.EncodeTextPayload($rule.script))
                            $rule.Remove('script') | Out-Null
                            $rule.Add('operationType', $rule.powerShellScriptOperationType)
                            $rule.Remove('powerShellScriptOperationType') | Out-Null
                        }
                    }
                }

                $createParameters.Rules = $rulesToProcess
            }
            #region resource generator code
            $createParameters.Add('@odata.type', '#microsoft.graph.win32LobApp')
            $policy = New-MgBetaDeviceAppManagementMobileApp -BodyParameter $createParameters

            Invoke-M365DSCIntuneMobileAppInitialUpload -AppId $policy.Id -OdataType '#microsoft.graph.win32LobApp' -FileExtension 'intunewin'

            if ($this.GetBoundParameters().ContainsKey('Categories'))
            {
                Update-DeviceAppManagementAppCategory -App $policy -Categories $this.Categories
            }

            if ($policy.Id)
            {
                $assignmentsHash = ConvertTo-IntuneMobileAppAssignment -IncludeDeviceFilter:$true -Assignments $this.Assignments
                Wait-M365DSCIntuneMobileAppPublished -AppId $policy.Id
                Update-DeviceAppManagementPolicyAssignment `
                    -AppManagementPolicyId $policy.Id `
                    -Assignments $assignmentsHash

                if ($this.GetBoundParameters().ContainsKey('Relationships'))
                {
                    $this.UpdateRelationships($policy.Id, $this.Relationships)
                }
            }
            #endregion
        }
        elseif ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Updating the Intune Mobile Apps Win32 App for Windows10 with Id {$($currentInstance.Id)}"
            $updateParameters = $boundParameters
            $updateParameters.Remove('Assignments') | Out-Null

            $updateParameters.Remove('Id') | Out-Null

            if ($updateParameters.ContainsKey('Rules'))
            {
                $rulesToProcess = @()
                $rulesToProcess = $updateParameters.Rules

                foreach ($rule in $rulesToProcess)
                {
                    $odataType = $rule.'@odata.type'
                    $rule.'@odata.type' = "#microsoft.graph.win32LobApp$($odataType)Rule"
                    switch ($odataType)
                    {
                        'FileSystem'
                        {
                            $rule.Add('operationType', $rule.fileSystemOperationType)
                            $rule.Remove('fileSystemOperationType') | Out-Null
                        }
                        'Registry'
                        {
                            $rule.Add('operationType', $rule.registryOperationType)
                            $rule.Remove('registryOperationType') | Out-Null
                        }
                        'PowerShellScript'
                        {
                            $rule.Add('scriptContent', $this.EncodeTextPayload($rule.script))
                            $rule.Remove('script') | Out-Null
                            $rule.Add('operationType', $rule.powerShellScriptOperationType)
                            $rule.Remove('powerShellScriptOperationType') | Out-Null
                        }
                    }
                }

                $updateParameters.Rules = $rulesToProcess
            }

            #region resource generator code
            $updateParameters.Add('@odata.type', '#microsoft.graph.win32LobApp')
            Update-MgBetaDeviceAppManagementMobileApp `
                -MobileAppId $currentInstance.Id `
                -BodyParameter $updateParameters

            if ($this.GetBoundParameters().ContainsKey('Categories'))
            {
                Update-DeviceAppManagementAppCategory -App $currentInstance -Categories $this.Categories -Compare
            }

            $assignmentsHash = ConvertTo-IntuneMobileAppAssignment -IncludeDeviceFilter:$true -Assignments $this.Assignments
            Update-DeviceAppManagementPolicyAssignment `
                -AppManagementPolicyId $currentInstance.Id `
                -Assignments $assignmentsHash

            if ($this.GetBoundParameters().ContainsKey('Relationships'))
            {
                $this.UpdateRelationships($currentInstance.Id, $this.Relationships)
            }
            #endregion
        }
        elseif ($this.Ensure -eq 'Absent' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Removing the Intune Mobile Apps Win32 App for Windows10 with Id {$($currentInstance.Id)}"
            #region resource generator code
            Remove-MgBetaDeviceAppManagementMobileApp -MobileAppId $currentInstance.Id
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
            $baseFilter = "isof('microsoft.graph.win32LobApp')"
            $mergedFilter = $baseFilter
            if (-not [System.String]::IsNullOrEmpty($this.Filter))
            {
                $mergedFilter = "($($this.Filter)) and ($baseFilter)"
            }
            [array]$getValue = Get-MgBetaDeviceAppManagementMobileApp `
                -Filter $mergedFilter `
                -All `
                -ErrorAction Stop
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
                $displayedKey = $config.Id
                if (-not [String]::IsNullOrEmpty($config.displayName))
                {
                    $displayedKey = $config.displayName
                }
                elseif (-not [string]::IsNullOrEmpty($config.name))
                {
                    $displayedKey = $config.name
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
                if ($null -ne $Results.Rules)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.Rules `
                        -CIMInstanceName 'MicrosoftGraphWin32LobAppRule'
                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.Rules = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('Rules') | Out-Null
                    }
                }
                if ($null -ne $Results.InstallExperience)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.InstallExperience `
                        -CIMInstanceName 'MicrosoftGraphWin32LobAppInstallExperience'
                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.InstallExperience = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('InstallExperience') | Out-Null
                    }
                }
                if ($null -ne $Results.ReturnCodes)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.ReturnCodes `
                        -CIMInstanceName 'MicrosoftGraphWin32LobAppReturnCode'
                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.ReturnCodes = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('ReturnCodes') | Out-Null
                    }
                }
                if ($null -ne $Results.MsiInformation)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.MsiInformation `
                        -CIMInstanceName 'MicrosoftGraphWin32LobAppMsiInformation'
                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.MsiInformation = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('MsiInformation') | Out-Null
                    }
                }
                if ($null -ne $Results.LargeIcon)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.LargeIcon `
                        -CIMInstanceName 'DeviceManagementMimeContent'
                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.LargeIcon = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('LargeIcon') | Out-Null
                    }
                }

                if ($null -ne $Results.Relationships)
                {
                    $complexMapping = @(
                        @{
                            Name            = 'Relationships'
                            CIMInstanceName = 'MicrosoftGraphMobileAppRelationship'
                            IsRequired      = $false
                        }
                    )
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.Relationships `
                        -CIMInstanceName 'MicrosoftGraphMobileAppRelationship' `
                        -ComplexTypeMapping $complexMapping
                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.Relationships = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('Relationships') | Out-Null
                    }
                }

                if ($Results.Assignments)
                {
                    $complexMapping = @(
                        @{
                            Name            = 'AssignmentSettings'
                            CIMInstanceName = 'DeviceManagementWin32MobileAppAssignmentSettings'
                            IsRequired      = $false
                        },
                        @{
                            Name            = 'AutoUpdateSettings'
                            CIMInstanceName = 'DeviceManagementWin32MobileAppAssignmentSettingsAutoUpdateSettings'
                            IsRequired      = $false
                        },
                        @{
                            Name            = 'InstallTimeSettings'
                            CIMInstanceName = 'DeviceManagementWin32MobileAppAssignmentSettingsInstallTimeSettings'
                            IsRequired      = $false
                        },
                        @{
                            Name            = 'RestartSettings'
                            CIMInstanceName = 'DeviceManagementWin32MobileAppAssignmentSettingsRestartSettings'
                            IsRequired      = $false
                        }
                    )
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.Assignments `
                        -CIMInstanceName DeviceManagementWin32MobileAppAssignment `
                        -ComplexTypeMapping $complexMapping
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
                    -NoEscape @('Assignments', 'Categories', 'Rules', 'LargeIcon', 'InstallExperience', 'ReturnCodes', 'MsiInformation', 'Relationships') `
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
            $this.LogError($_, 'Error during Export:')

            throw
        }
    }

    hidden [void] UpdateRelationships([System.String] $AppId, [System.Object[]] $Relationships)
    {
        $resourceUrl = (Get-MSCloudLoginConnectionProfile -Workload MicrosoftGraph).ResourceUrl
        $entries = @()

        foreach ($relationship in $Relationships)
        {
            $targetId = $relationship.targetId
            if ([System.String]::IsNullOrEmpty($targetId))
            {
                if ([System.String]::IsNullOrEmpty($relationship.targetDisplayName))
                {
                    throw 'A relationship of an Intune Mobile Apps Win32 App for Windows10 requires either a targetId or a targetDisplayName.'
                }

                $targetFilter = [System.Uri]::EscapeDataString("displayName eq '$($relationship.targetDisplayName -replace "'", "''")'")
                $targetUri = $resourceUrl + "beta/deviceAppManagement/mobileApps?`$filter=$targetFilter"
                $targetResponse = Invoke-MgGraphRequest -Method GET -Uri $targetUri -ErrorAction Stop

                $targetApp = $null
                if ($null -ne $targetResponse -and $null -ne $targetResponse.value)
                {
                    $targetApp = @($targetResponse.value)[0]
                }

                if ($null -eq $targetApp)
                {
                    throw "Could not find a mobile app with DisplayName {$($relationship.targetDisplayName)} to relate to the Intune Mobile Apps Win32 App for Windows10 with Id {$AppId}."
                }

                $targetId = $targetApp.id
            }

            $entry = @{
                '@odata.type' = $relationship.odataType
                targetId      = $targetId
            }

            switch ($relationship.odataType)
            {
                '#microsoft.graph.mobileAppDependency'
                {
                    if (-not [System.String]::IsNullOrEmpty($relationship.dependencyType))
                    {
                        $entry.Add('dependencyType', $relationship.dependencyType)
                    }
                }
                '#microsoft.graph.mobileAppSupersedence'
                {
                    if (-not [System.String]::IsNullOrEmpty($relationship.supersedenceType))
                    {
                        $entry.Add('supersedenceType', $relationship.supersedenceType)
                    }
                }
            }

            $entries += $entry
        }

        $body = @{
            relationships = [System.Collections.ArrayList]@($entries)
        }

        Invoke-MgGraphRequest -Method POST `
            -Uri ($resourceUrl + "beta/deviceAppManagement/mobileApps/$AppId/updateRelationships") `
            -Body ($body | ConvertTo-Json -Depth 10) `
            -ContentType 'application/json' `
            -ErrorAction Stop | Out-Null
    }

    hidden [IntuneMobileAppsWin32AppWindows10] AsResult([System.Object] $Values)
    {
        if ($Values -is [IntuneMobileAppsWin32AppWindows10])
        {
            return $Values
        }

        $result = [IntuneMobileAppsWin32AppWindows10]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}

class MSFT_DeviceManagementMimeContent
{
    [DscProperty()]
    [System.ComponentModel.Description('Indicates the type of content mime.')]
    [System.String] $Type

    [DscProperty()]
    [System.ComponentModel.Description('The Base64 encoded string content.')]
    [System.String] $Value
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

class MSFT_MicrosoftGraphWin32LobAppRule
{
    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('The provider rule type. Possible values are: FileSystem, PowerShellScript, Registry')]
    [ValidateSet('FileSystem', 'PowerShellScript', 'ProductCode', 'Registry')]
    [System.String] $OdataType

    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('The type of rule. Possible values are: Detection, Requirement')]
    [ValidateSet('Detection', 'Requirement')]
    [System.String] $RuleType

    [DscProperty()]
    [System.ComponentModel.Description('The operator of the rule. Not applicable for the ''ProductCode'' odata type. Possible values are: notConfigured, equal, notEqual, greaterThan, greaterThanOrEqual, lessThan, lessThanOrEqual.')]
    [ValidateSet('notConfigured', 'equal', 'notEqual', 'greaterThan', 'greaterThanOrEqual', 'lessThan', 'lessThanOrEqual')]
    [System.String] $Operator

    [DscProperty()]
    [System.ComponentModel.Description('The value to compare. Not applicable for the ''ProductCode'' odata type.')]
    [System.String] $ComparisonValue

    [DscProperty()]
    [System.ComponentModel.Description('A value indicating whether to checking 32-bit on 64-bit system. Only applicable for the ''FileSystem'' and ''Registry'' odata type.')]
    [System.Nullable[System.Boolean]] $Check32BitOn64System

    [DscProperty()]
    [System.ComponentModel.Description('The file or folder path to detect Win32 Line of Business (LoB) app. Only applicable for the ''FileSystem'' odata type.')]
    [System.String] $Path

    [DscProperty()]
    [System.ComponentModel.Description('The file or folder name to detect Win32 Line of Business (LoB) app. Only applicable for the ''FileSystem'' odata type.')]
    [System.String] $FileOrFolderName

    [DscProperty()]
    [System.ComponentModel.Description('The file system comparison operator type. Only applicable for the ''FileSystem'' odata type. Possible values are: notConfigured, exists, modifiedDate, createdDate, version, sizeInMB, doesNotExist, sizeInBytes, appVersion.')]
    [ValidateSet('notConfigured', 'exists', 'modifiedDate', 'createdDate', 'version', 'sizeInMB', 'doesNotExist', 'sizeInBytes', 'appVersion')]
    [System.String] $FileSystemOperationType

    [DscProperty()]
    [System.ComponentModel.Description('The display name for the rule. Do not specify this value if the rule is used for detection.')]
    [System.String] $DisplayName

    [DscProperty()]
    [System.ComponentModel.Description('A value indicating whether signature check is enforced. Only Applicable for the ''PowerShellScript'' odata type.')]
    [System.Nullable[System.Boolean]] $EnforceSignatureCheck

    [DscProperty()]
    [System.ComponentModel.Description('A value indicating whether this script should run as 32-bit. Only Applicable for the ''PowerShellScript'' odata type.')]
    [System.Nullable[System.Boolean]] $RunAs32Bit

    [DscProperty()]
    [System.ComponentModel.Description('Indicates the type of execution context the script runs in. Only Applicable for the ''PowerShellScript'' odata type. Possible values are: system, user.')]
    [ValidateSet('system', 'user')]
    [System.String] $RunAsAccount

    [DscProperty()]
    [System.ComponentModel.Description('The PowerShell script. Only Applicable for the ''PowerShellScript'' odata type.')]
    [System.String] $Script

    [DscProperty()]
    [System.ComponentModel.Description('The comparison operator type for script output. Only Applicable for the ''PowerShellScript'' odata type. Possible values are: notConfigured, string, dateTime, integer, float, version, boolean.')]
    [ValidateSet('notConfigured', 'string', 'dateTime', 'integer', 'float', 'version', 'boolean')]
    [System.String] $PowerShellScriptOperationType

    [DscProperty()]
    [System.ComponentModel.Description('The product code of Win32 Line of Business (LoB) app.')]
    [System.String] $ProductCode

    [DscProperty()]
    [System.ComponentModel.Description('The operator for detection. Only applicable for the ''ProductCode'' odata typ. Possible values are: notConfigured, equal, notEqual, greaterThan, greaterThanOrEqual, lessThan, lessThanOrEqual.')]
    [ValidateSet('notConfigured', 'equal', 'notEqual', 'greaterThan', 'greaterThanOrEqual', 'lessThan', 'lessThanOrEqual')]
    [System.String] $ProductVersionOperator

    [DscProperty()]
    [System.ComponentModel.Description('The product version of Win32 Line of Business (LoB) app.')]
    [System.String] $ProductVersion

    [DscProperty()]
    [System.ComponentModel.Description('The registry key path to detect Win32 Line of Business (LoB) app.')]
    [System.String] $KeyPath

    [DscProperty()]
    [System.ComponentModel.Description('The registry value name.')]
    [System.String] $ValueName

    [DscProperty()]
    [System.ComponentModel.Description('The registry data comparison operator type. Only applicable for the ''Registry'' odata type. Possible values are: notConfigured, exists, doesNotExist, string, integer, version.')]
    [ValidateSet('notConfigured', 'exists', 'doesNotExist', 'string', 'integer', 'version')]
    [System.String] $RegistryOperationType
}

class MSFT_MicrosoftGraphWin32LobAppInstallExperience
{
    [DscProperty()]
    [System.ComponentModel.Description('Indicates the type of execution context the app runs in. Possible values are: system, user.')]
    [ValidateSet('system', 'user')]
    [System.String] $RunAsAccount

    [DscProperty()]
    [System.ComponentModel.Description('The number of minutes the system will wait for install program to finish. Default value is 60 minutes.')]
    [System.Nullable[System.Int32]] $MaxRunTimeInMinutes

    [DscProperty()]
    [System.ComponentModel.Description('Device restart behavior. Possible values are: basedOnReturnCode, allow, suppress, force.')]
    [ValidateSet('basedOnReturnCode', 'allow', 'suppress', 'force')]
    [System.String] $DeviceRestartBehavior
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

class MSFT_MicrosoftGraphMobileAppRelationship
{
    [DscProperty()]
    [System.ComponentModel.Description('Selects whether the entry is a dependency or a supersedence relationship.')]
    [ValidateSet('#microsoft.graph.mobileAppDependency', '#microsoft.graph.mobileAppSupersedence')]
    [System.String] $odataType

    [DscProperty()]
    [System.ComponentModel.Description('The unique app identifier of the target of the mobile app relationship entity. For example: 2dbc75b9-e993-4e4d-a071-91ac5a218672. Read-Only. Returned by default. Supports: $select. Does not support $search, $filter, $orderBy.')]
    [System.String] $targetId

    [DscProperty()]
    [System.ComponentModel.Description('The display name of the app that is the target of the mobile app relationship entity. For example: Firefox Setup 52.0.2 32bit.intunewin. Maximum length is 500 characters. Read-Only. Returned by default. Supports: $select. Does not support $search, $filter, $orderBy. This property is read-only.')]
    [System.String] $targetDisplayName

    [DscProperty()]
    [System.ComponentModel.Description('The type of dependency relationship between the parent and child apps. Possible values are: detect, autoInstall. Read-Only. Possible values are: detect, autoInstall, unknownFutureValue.')]
    [ValidateSet('detect', 'autoInstall')]
    [System.String] $dependencyType

    [DscProperty()]
    [System.ComponentModel.Description('The supersedence relationship type between the parent and child apps. Possible values are: update, replace. Read-Only. Possible values are: update, replace, unknownFutureValue.')]
    [ValidateSet('update', 'replace')]
    [System.String] $supersedenceType
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

class MSFT_DeviceManagementWin32MobileAppAssignment : MSFT_DeviceManagementMobileAppAssignment
{
    [DscProperty()]
    [System.ComponentModel.Description('The settings of the assignment.')]
    [MSFT_DeviceManagementWin32MobileAppAssignmentSettings] $assignmentSettings
}

class MSFT_DeviceManagementMobileAppAssignmentSettings
{
    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('The odata type of the assignment type.')]
    [ValidateSet('#microsoft.graph.androidManagedStoreAppAssignmentSettings', '#microsoft.graph.iosStoreAppAssignmentSettings', '#microsoft.graph.iosLobAppAssignmentSettings', '#microsoft.graph.macOsLobAppAssignmentSettings', '#microsoft.graph.win32CatalogAppAssignmentSettings', '#microsoft.graph.win32LobAppAssignmentSettings', '#microsoft.graph.winGetAppAssignmentSettings', '#microsoft.graph.windowsAutoUpdateCatalogAppAssignmentSettings', '#microsoft.graph.windowsUniversalAppXAppAssignmentSettings')]
    [System.String] $odataType
}

class MSFT_DeviceManagementWin32MobileAppAssignmentSettings : MSFT_DeviceManagementMobileAppAssignmentSettings
{
    [DscProperty()]
    [System.ComponentModel.Description('The auto-update settings to apply for this app assignment.')]
    [MSFT_DeviceManagementWin32MobileAppAssignmentSettingsAutoUpdateSettings] $autoUpdateSettings

    [DscProperty()]
    [System.ComponentModel.Description('The delivery optimization priority for this app assignment. This setting is not supported in National Cloud environments. Possible values are: notConfigured, foreground.')]
    [ValidateSet('foreground', 'notConfigured')]
    [System.String] $deliveryOptimizationPriority

    [DscProperty()]
    [System.ComponentModel.Description('The install time settings to apply for this app assignment.')]
    [MSFT_DeviceManagementWin32MobileAppAssignmentSettingsInstallTimeSettings] $installTimeSettings

    [DscProperty()]
    [System.ComponentModel.Description('The notification status for this app assignment. Possible values are: showAll, showReboot, hideAll.')]
    [ValidateSet('showAll', 'showReboot', 'hideAll')]
    [System.String] $notifications

    [DscProperty()]
    [System.ComponentModel.Description('The reboot settings to apply for this app assignment.')]
    [MSFT_DeviceManagementWin32MobileAppAssignmentSettingsRestartSettings] $restartSettings
}

class MSFT_DeviceManagementWin32MobileAppAssignmentSettingsAutoUpdateSettings
{
    [DscProperty()]
    [System.ComponentModel.Description('The auto-update superseded apps setting for the app assignment. Possible values are notConfigured and enabled. Default value is notConfigured.')]
    [ValidateSet('enabled', 'notConfigured')]
    [System.String] $autoUpdateSupersededAppsState
}

class MSFT_DeviceManagementWin32MobileAppAssignmentSettingsInstallTimeSettings
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

class MSFT_DeviceManagementWin32MobileAppAssignmentSettingsRestartSettings
{
    [DscProperty()]
    [System.ComponentModel.Description('The number of minutes to wait before restarting the device after an app installation.')]
    [System.Nullable[System.Int32]] $countdownDisplayBeforeRestartInMinutes

    [DscProperty()]
    [System.ComponentModel.Description('The number of minutes before the restart time to display the countdown dialog for pending restarts.')]
    [System.Nullable[System.Int32]] $gracePeriodInMinutes

    [DscProperty()]
    [System.ComponentModel.Description('The number of minutes to snooze the restart notification dialog when the snooze button is selected.')]
    [System.Nullable[System.Int32]] $restartNotificationSnoozeDurationInMinutes
}
