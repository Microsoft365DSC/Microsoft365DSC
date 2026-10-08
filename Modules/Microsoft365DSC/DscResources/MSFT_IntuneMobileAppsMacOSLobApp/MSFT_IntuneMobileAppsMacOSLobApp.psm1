using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class IntuneMobileAppsMacOSLobApp : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The admin provided or imported title of the app. Inherited from mobileApp.')]
    [System.String] $DisplayName

    [DscProperty()]
    [System.ComponentModel.Description('The unique identifier for an entity. Read-only. Inherited from mobileApp object.')]
    [System.String] $Id

    [DscProperty()]
    [System.ComponentModel.Description('The description of the app. Inherited from mobileApp.')]
    [System.String] $Description

    [DscProperty()]
    [System.ComponentModel.Description('The dewveloper of the app. Inherited from mobileApp.')]
    [System.String] $Developer

    [DscProperty()]
    [System.ComponentModel.Description('The InformationUrl of the app. Inherited from mobileApp.')]
    [System.String] $InformationUrl

    [DscProperty()]
    [System.ComponentModel.Description('The value indicating whether the app is marked as featured by the admin. Inherited from mobileApp.')]
    [System.Nullable[System.Boolean]] $IsFeatured

    [DscProperty()]
    [System.ComponentModel.Description('Notes for the app. Inherited from mobileApp.')]
    [System.String] $Notes

    [DscProperty()]
    [System.ComponentModel.Description('The owner of the app. Inherited from mobileApp.')]
    [System.String] $Owner

    [DscProperty()]
    [System.ComponentModel.Description('The privacy statement Url. Inherited from mobileApp.')]
    [System.String] $PrivacyInformationUrl

    [DscProperty()]
    [System.ComponentModel.Description('The publisher of the app. Inherited from mobileApp.')]
    [System.String] $Publisher

    [DscProperty()]
    [System.ComponentModel.Description('The bundleId of the app.')]
    [System.String] $BundleId

    [DscProperty()]
    [System.ComponentModel.Description('The build number of the app.')]
    [System.String] $BuildNumber

    [DscProperty()]
    [System.ComponentModel.Description('The version number of the app.')]
    [System.String] $VersionNumber

    [DscProperty()]
    [System.ComponentModel.Description('List of Scope Tag IDs for mobile app.')]
    [System.String[]] $RoleScopeTagIds

    [DscProperty()]
    [System.ComponentModel.Description('Whether to ignore the version of the app or not.')]
    [System.Nullable[System.Boolean]] $IgnoreVersionDetection

    [DscProperty()]
    [System.ComponentModel.Description('Install the app as managed. Requires macOS 11.0.')]
    [System.Nullable[System.Boolean]] $InstallAsManaged

    [DscProperty()]
    [System.ComponentModel.Description('The icon for this app.')]
    [MSFT_DeviceManagementMimeContent] $LargeIcon

    [DscProperty()]
    [System.ComponentModel.Description('The minimum supported operating system to install the app.')]
    [MSFT_DeviceManagementMinimumOperatingSystem] $MinimumSupportedOperatingSystem

    [DscProperty()]
    [System.ComponentModel.Description('The list of categories for this app.')]
    [MSFT_DeviceManagementMobileAppCategory[]] $Categories

    [DscProperty()]
    [System.ComponentModel.Description('The list of assignments for this app.')]
    [MSFT_DeviceManagementMacOSLobAppAssignment[]] $Assignments

    [DscProperty()]
    [System.ComponentModel.Description('The list of child apps for this app package.')]
    [MSFT_DeviceManagementMobileAppChildApp[]] $ChildApps

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

    [IntuneMobileAppsMacOSLobApp] Get()
    {
        $instance = $null
        if ($this.RequiresPowerShellCore())
        {
            $remote = [IntuneMobileAppsMacOSLobApp]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of the Intune MacOS Lob App with Id {$($this.Id)} and DisplayName {$($this.DisplayName)}"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.DisplayName -ne $this.DisplayName)
            {
                $null = $this.Connect('MicrosoftGraph')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullResult = $this.GetBoundParameters()
                $nullResult.Ensure = 'Absent'

                if (-not [System.String]::IsNullOrEmpty($this.Id))
                {
                    $instance = Get-MgBetaDeviceAppManagementMobileApp -MobileAppId $this.Id -ExpandProperty 'categories' -ErrorAction SilentlyContinue
                }

                if ($null -eq $instance)
                {
                    Write-Verbose -Message "Could not find an Intune MacOS Lob App with Id {$($this.Id)}."

                    if (-not [System.String]::IsNullOrEmpty($this.DisplayName))
                    {
                        $instance = Get-MgBetaDeviceAppManagementMobileApp `
                            -All `
                            -Filter "DisplayName eq '$($this.DisplayName -replace "'", "''")'" `
                            -ErrorAction SilentlyContinue | Where-Object -Property '@odata.type' -EQ '#microsoft.graph.macOSLobApp'
                    }

                    if ($null -ne $instance)
                    {
                        $instance = Get-MgBetaDeviceAppManagementMobileApp -MobileAppId $instance.Id `
                            -ExpandProperty 'categories' `
                            -ErrorAction SilentlyContinue
                    }
                }

                if ($null -eq $instance)
                {
                    Write-Verbose -Message "Could not find an Intune MacOS Lob App with DisplayName {$($this.DisplayName)} was found."
                    return $this.AsResult($nullResult)
                }
            }
            else
            {
                $instance = Get-MgBetaDeviceAppManagementMobileApp -MobileAppId $this.ExportedInstance.Id `
                    -ExpandProperty 'categories' `
                    -ErrorAction SilentlyContinue
            }
            $resolvedId = $instance.Id

            Write-Verbose "An Intune MacOS Lob App with Id {$($resolvedId)} and DisplayName {$($this.DisplayName)} was found."

            #region complex types
            $complexCategories = @()
            foreach ($category in $instance.Categories)
            {
                $myCategory = [ordered]@{}
                $myCategory.Add('Id', $category.id)
                $myCategory.Add('DisplayName', $category.displayName)
                $complexCategories += $myCategory
            }

            $complexChildApps = @()
            foreach ($childApp in $instance.childApps)
            {
                $myChildApp = [ordered]@{}
                $myChildApp.Add('BundleId', $childApp.bundleId)
                $myChildApp.Add('BuildNumber', $childApp.buildNumber)
                $myChildApp.Add('VersionNumber', $childApp.versionNumber)
                $complexChildApps += $myChildApp
            }

            $complexLargeIcon = [ordered]@{}
            if ($null -ne $instance.LargeIcon.Value)
            {
                $complexLargeIcon.Add('Type', $instance.LargeIcon.Type)
                $complexLargeIcon.Add('Value', $instance.LargeIcon.Value)
            }

            $complexMinimumSupportedOperatingSystem = [ordered]@{}
            if ($null -ne $instance.minimumSupportedOperatingSystem)
            {
                $instance.minimumSupportedOperatingSystem.GetEnumerator() | ForEach-Object {
                    if ($_.Value) # Values are either true or false. Only export the true value.
                    {
                        $complexMinimumSupportedOperatingSystem.Add($_.Key, $_.Value)
                    }
                }
            }

            $results = @{
                Id                              = $instance.Id
                BundleId                        = $instance.bundleId
                BuildNumber                     = $instance.buildNumber
                Categories                      = $complexCategories
                ChildApps                       = $complexChildApps
                Description                     = $instance.Description
                Developer                       = $instance.Developer
                DisplayName                     = $instance.DisplayName
                IgnoreVersionDetection          = $instance.ignoreVersionDetection
                InformationUrl                  = $instance.InformationUrl
                IsFeatured                      = $instance.IsFeatured
                InstallAsManaged                = $instance.installAsManaged
                LargeIcon                       = $complexLargeIcon
                MinimumSupportedOperatingSystem = $complexMinimumSupportedOperatingSystem
                Notes                           = $instance.Notes
                Owner                           = $instance.Owner
                PrivacyInformationUrl           = $instance.PrivacyInformationUrl
                Publisher                       = $instance.Publisher
                RoleScopeTagIds                 = Resolve-M365DSCIntuneRoleScopeTagNames -CurrentValues $instance.RoleScopeTagIds -DesiredValues $this.RoleScopeTagIds
                VersionNumber                   = $instance.versionNumber
                Ensure                          = 'Present'
                Credential                      = $this.Credential
                ApplicationId                   = $this.ApplicationId
                TenantId                        = $this.TenantId
                ApplicationSecret               = $this.ApplicationSecret
                CertificateThumbprint           = $this.CertificateThumbprint
                CertificatePath                 = $this.CertificatePath
                CertificatePassword             = $this.CertificatePassword
                ManagedIdentity                 = $this.ManagedIdentity
                AccessTokens                    = $this.AccessTokens
            }

            #Assignments
            $resultAssignments = @()
            $appAssignments = Get-MgBetaDeviceAppManagementMobileAppAssignment -MobileAppId $instance.Id
            if ($null -ne $appAssignments -and $appAssignments.Count -gt 0)
            {
                [array]$appAssignments = $appAssignments | Where-Object -Property source -EQ 'direct'
                $resultAssignments += ConvertFrom-IntuneMobileAppAssignment `
                    -IncludeDeviceFilter:$true `
                    -Assignments ($appAssignments)
            }
            $results.Add('Assignments', $resultAssignments)

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

        if ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Creating an Intune MacOS Lob App with DisplayName {$($this.DisplayName)}"
            $createParameters = $boundParameters
            $createParameters.Remove('Assignments') | Out-Null

            $createParameters.Remove('Id') | Out-Null
            $createParameters.Remove('Categories') | Out-Null

            $createParameters.Add('@odata.type', '#microsoft.graph.macOSLobApp')
            $createParameters.Add('fileName', "$($this.DisplayName).pkg")
            $app = New-MgBetaDeviceAppManagementMobileApp -BodyParameter $createParameters

            Invoke-M365DSCIntuneMobileAppInitialUpload -AppId $app.Id -OdataType '#microsoft.graph.macOSLobApp' -FileExtension 'pkg'

            if ($this.GetBoundParameters().ContainsKey('Categories'))
            {
                Update-DeviceAppManagementAppCategory -App $app -Categories $this.Categories
            }

            #Assignments
            if ($app.Id)
            {
                $assignmentsHash = ConvertTo-IntuneMobileAppAssignment -IncludeDeviceFilter:$true -Assignments $this.Assignments
                Wait-M365DSCIntuneMobileAppPublished -AppId $app.Id
                Update-DeviceAppManagementPolicyAssignment -AppManagementPolicyId $app.Id `
                    -Assignments $assignmentsHash
            }
        }
        elseif ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Updating the Intune MacOS Lob App with DisplayName {$($this.DisplayName)}"
            $updateParameters = $boundParameters
            $updateParameters.Remove('Assignments') | Out-Null

            $updateParameters.Remove('Id') | Out-Null
            $updateParameters.Remove('Categories') | Out-Null

            $updateParameters.Add('@odata.type', '#microsoft.graph.macOSLobApp')
            Update-MgBetaDeviceAppManagementMobileApp -MobileAppId $currentInstance.Id -BodyParameter $updateParameters

            if ($this.GetBoundParameters().ContainsKey('Categories'))
            {
                Update-DeviceAppManagementAppCategory -App $currentInstance -Categories $this.Categories -Compare
            }

            #Assignments
            $assignmentsHash = ConvertTo-IntuneMobileAppAssignment -IncludeDeviceFilter:$true -Assignments $this.Assignments
            Update-DeviceAppManagementPolicyAssignment -AppManagementPolicyId $currentInstance.Id `
                -Assignments $assignmentsHash
        }
        elseif ($this.Ensure -eq 'Absent' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Remove the Intune MacOS Lob App with Id {$($currentInstance.Id)}"
            Remove-MgBetaDeviceAppManagementMobileApp -MobileAppId $currentInstance.Id
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
            $baseFilter = "isof('microsoft.graph.macOSLobApp')"
            $mergedFilter = $baseFilter
            if (-not [System.String]::IsNullOrEmpty($this.Filter))
            {
                $mergedFilter = "($($this.Filter)) and ($baseFilter)"
            }
            [array] $getValue = Get-MgBetaDeviceAppManagementMobileApp `
                -All `
                -Filter $mergedFilter `
                -ErrorAction Stop

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

                #region complex types
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

                if ($null -ne $Results.ChildApps)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.ChildApps `
                        -CIMInstanceName 'DeviceManagementMobileAppChildApp'

                    if (-not [System.String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.ChildApps = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('ChildApps') | Out-Null
                    }
                }

                if ($null -ne $Results.LargeIcon)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.LargeIcon `
                        -CIMInstanceName 'DeviceManagementMimeContent'

                    if (-not [System.String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.LargeIcon = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('LargeIcon') | Out-Null
                    }
                }

                if ($null -ne $Results.MinimumSupportedOperatingSystem)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.MinimumSupportedOperatingSystem `
                        -CIMInstanceName 'DeviceManagementMinimumOperatingSystem'

                    if (-not [System.String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.MinimumSupportedOperatingSystem = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('MinimumSupportedOperatingSystem') | Out-Null
                    }
                }

                if ($Results.Assignments)
                {
                    $complexMapping = @(
                        @{
                            Name            = 'AssignmentSettings'
                            CIMInstanceName = 'DeviceManagementMacOSLobAppAssignmentSettings'
                            IsRequired      = $false
                        }
                    )
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.Assignments `
                        -CIMInstanceName DeviceManagementMacOSLobAppAssignment `
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
                #endregion complex types

                $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                    -ConnectionMode $ConnectionMode `
                    -ModulePath $this.GetModulePath() `
                    -Results $Results `
                    -Credential $this.Credential `
                    -NoEscape @('Categories', 'ChildApps', 'LargeIcon', 'MinimumSupportedOperatingSystem', 'Assignments') `
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

    hidden [IntuneMobileAppsMacOSLobApp] AsResult([System.Object] $Values)
    {
        if ($Values -is [IntuneMobileAppsMacOSLobApp])
        {
            return $Values
        }

        $result = [IntuneMobileAppsMacOSLobApp]::new()
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

class MSFT_DeviceManagementMinimumOperatingSystem
{
    [DscProperty()]
    [System.ComponentModel.Description('Indicates if Mac OS X 10.7 or later is required to install the app.')]
    [System.Nullable[System.Boolean]] $v10_7

    [DscProperty()]
    [System.ComponentModel.Description('Indicates if Mac OS X 10.8 or later is required to install the app.')]
    [System.Nullable[System.Boolean]] $v10_8

    [DscProperty()]
    [System.ComponentModel.Description('Indicates if Mac OS X 10.9 or later is required to install the app.')]
    [System.Nullable[System.Boolean]] $v10_9

    [DscProperty()]
    [System.ComponentModel.Description('Indicates if Mac OS X 10.10 or later is required to install the app.')]
    [System.Nullable[System.Boolean]] $v10_10

    [DscProperty()]
    [System.ComponentModel.Description('Indicates if Mac OS X 10.11 or later is required to install the app.')]
    [System.Nullable[System.Boolean]] $v10_11

    [DscProperty()]
    [System.ComponentModel.Description('Indicates if Mac OS X 10.12 or later is required to install the app.')]
    [System.Nullable[System.Boolean]] $v10_12

    [DscProperty()]
    [System.ComponentModel.Description('Indicates if Mac OS X 10.13 or later is required to install the app.')]
    [System.Nullable[System.Boolean]] $v10_13

    [DscProperty()]
    [System.ComponentModel.Description('Indicates if Mac OS X 10.14 or later is required to install the app.')]
    [System.Nullable[System.Boolean]] $v10_14

    [DscProperty()]
    [System.ComponentModel.Description('Indicates if Mac OS X 10.15 or later is required to install the app.')]
    [System.Nullable[System.Boolean]] $v10_15

    [DscProperty()]
    [System.ComponentModel.Description('Indicates if Mac OS X 11.0 or later is required to install the app.')]
    [System.Nullable[System.Boolean]] $v11_0

    [DscProperty()]
    [System.ComponentModel.Description('Indicates if Mac OS X 12.0 or later is required to install the app.')]
    [System.Nullable[System.Boolean]] $v12_0

    [DscProperty()]
    [System.ComponentModel.Description('Indicates if Mac OS X 13.0 or later is required to install the app.')]
    [System.Nullable[System.Boolean]] $v13_0

    [DscProperty()]
    [System.ComponentModel.Description('Indicates if Mac OS X 14.0 or later is required to install the app.')]
    [System.Nullable[System.Boolean]] $v14_0
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

class MSFT_DeviceManagementMacOSLobAppAssignment : MSFT_DeviceManagementMobileAppAssignment
{
    [DscProperty()]
    [System.ComponentModel.Description('The settings of the assignment.')]
    [MSFT_DeviceManagementMacOSLobAppAssignmentSettings] $assignmentSettings
}

class MSFT_DeviceManagementMobileAppChildApp
{
    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('The bundleId of the app.')]
    [System.String] $BundleId

    [DscProperty()]
    [System.ComponentModel.Description('The build number of the app.')]
    [System.String] $BuildNumber

    [DscProperty()]
    [System.ComponentModel.Description('The version number of the app.')]
    [System.String] $VersionNumber
}

class MSFT_DeviceManagementMobileAppAssignmentSettings
{
    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('The odata type of the assignment type.')]
    [ValidateSet('#microsoft.graph.androidManagedStoreAppAssignmentSettings', '#microsoft.graph.iosStoreAppAssignmentSettings', '#microsoft.graph.iosLobAppAssignmentSettings', '#microsoft.graph.macOsLobAppAssignmentSettings', '#microsoft.graph.win32CatalogAppAssignmentSettings', '#microsoft.graph.win32LobAppAssignmentSettings', '#microsoft.graph.winGetAppAssignmentSettings', '#microsoft.graph.windowsAutoUpdateCatalogAppAssignmentSettings', '#microsoft.graph.windowsUniversalAppXAppAssignmentSettings')]
    [System.String] $odataType
}

class MSFT_DeviceManagementMacOSLobAppAssignmentSettings : MSFT_DeviceManagementMobileAppAssignmentSettings
{
    [DscProperty()]
    [System.ComponentModel.Description('When TRUE, indicates that the app should be uninstalled when the device is removed from Intune. When FALSE, indicates that the app will not be uninstalled when the device is removed from Intune.')]
    [System.Nullable[System.Boolean]] $uninstallOnDeviceRemoval
}
