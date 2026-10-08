using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class IntuneMobileAppsWindowsOfficeSuiteApp : M365DSCResourceBase
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
    [System.ComponentModel.Description('The value indicating whether the app is marked as featured by the admin. Inherited from mobileApp.')]
    [System.Nullable[System.Boolean]] $IsFeatured

    [DscProperty()]
    [System.ComponentModel.Description('The privacy statement Url. Inherited from mobileApp.')]
    [System.String] $PrivacyInformationUrl

    [DscProperty()]
    [System.ComponentModel.Description('The InformationUrl of the app. Inherited from mobileApp.')]
    [System.String] $InformationUrl

    [DscProperty()]
    [System.ComponentModel.Description('Notes for the app. Inherited from mobileApp.')]
    [System.String] $Notes

    [DscProperty()]
    [System.ComponentModel.Description('List of Scope Tag IDs for mobile app.')]
    [System.String[]] $RoleScopeTagIds

    [DscProperty()]
    [System.ComponentModel.Description('Specifies if the EULA is accepted automatically on the end user''s device.')]
    [System.Nullable[System.Boolean]] $AutoAcceptEula

    [DscProperty()]
    [System.ComponentModel.Description('The Product IDs that represent the Office 365 Suite SKU, such as ''O365ProPlusRetail'' or ''VisioProRetail''.')]
    [System.String[]] $ProductIds

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether shared computer activation is used for Office installations.')]
    [System.Nullable[System.Boolean]] $UseSharedComputerActivation

    [DscProperty()]
    [System.ComponentModel.Description('Specifies the update channel for the Office 365 app suite, such as ''Current'' or ''Deferred''.')]
    [System.String] $UpdateChannel

    [DscProperty()]
    [System.ComponentModel.Description('Specifies the default file format type for Office apps, such as ''OfficeOpenXMLFormat'' or ''OfficeOpenDocumentFormat''.')]
    [System.String] $OfficeSuiteAppDefaultFileFormat

    [DscProperty()]
    [System.ComponentModel.Description('The architecture of the Office installation (e.g., ''X86'', ''X64'', or ''Arm64''). Cannot be changed after creation.')]
    [System.String] $OfficePlatformArchitecture

    [DscProperty()]
    [System.ComponentModel.Description('Specifies the locales to be installed when the Office 365 apps are deployed. Uses the standard RFC 5646 format (e.g., ''en-US'', ''fr-FR'').')]
    [System.String[]] $LocalesToInstall

    [DscProperty()]
    [System.ComponentModel.Description('Specifies the display level of the installation progress for Office apps. Use ''Full'' to display the installation UI, or ''None'' for a silent installation.')]
    [System.String] $InstallProgressDisplayLevel

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether older versions of Office should be uninstalled when deploying the Office 365 app suite.')]
    [System.Nullable[System.Boolean]] $ShouldUninstallOlderVersionsOfOffice

    [DscProperty()]
    [System.ComponentModel.Description('The specific target version of the Office 365 app suite to be deployed.')]
    [System.String] $TargetVersion

    [DscProperty()]
    [System.ComponentModel.Description('The update version in which the target version is available for the Office 365 app suite.')]
    [System.String] $UpdateVersion

    [DscProperty()]
    [System.ComponentModel.Description('A base64-encoded XML configuration file that specifies Office ProPlus installation settings. Takes precedence over all other properties. When present, this XML file will be used to create the app.')]
    [System.String] $OfficeConfigurationXml

    [DscProperty()]
    [System.ComponentModel.Description('The list of categories for this app.')]
    [MSFT_DeviceManagementMobileAppCategory[]] $Categories

    [DscProperty()]
    [System.ComponentModel.Description('The list of assignments for this app.')]
    [MSFT_DeviceManagementMobileAppAssignment[]] $Assignments

    [DscProperty()]
    [System.ComponentModel.Description('The property that represents the apps excluded from the selected Office 365 Product ID.')]
    [MSFT_DeviceManagementMobileAppExcludedApp] $ExcludedApps

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

    [IntuneMobileAppsWindowsOfficeSuiteApp] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [IntuneMobileAppsWindowsOfficeSuiteApp]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of the Intune Windows Office Suite App with Id {$($this.Id)} and DisplayName {$($this.DisplayName)}"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.DisplayName -ne $this.DisplayName)
            {
                $null = $this.Connect('MicrosoftGraph')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullResult = $this.GetBoundParameters()
                $nullResult.Ensure = 'Absent'

                $instance = $null
                if (-not [System.String]::IsNullOrEmpty($this.Id))
                {
                    $instance = Get-MgBetaDeviceAppManagementMobileApp -MobileAppId $this.Id `
                        -ExpandProperty 'categories' `
                        -ErrorAction SilentlyContinue
                }

                if ($null -eq $instance)
                {
                    Write-Verbose -Message "Could not find an Intune Windows Office Suite App with Id {$($this.Id)}."

                    if (-not [System.String]::IsNullOrEmpty($this.DisplayName))
                    {
                        $instance = Get-MgBetaDeviceAppManagementMobileApp `
                            -All `
                            -Filter "DisplayName eq '$($this.DisplayName -replace "'", "''")'" `
                            -ErrorAction SilentlyContinue | Where-Object -Property '@odata.type' -EQ '#microsoft.graph.officeSuiteApp'
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
                    Write-Verbose -Message "Could not find an Intune Windows Office Suite App with DisplayName {$($this.DisplayName)} was found."
                    return $this.AsResult($nullResult)
                }
            }
            else
            {
                $instance = Get-MgBetaDeviceAppManagementMobileApp -MobileAppId $this.ExportedInstance.Id `
                    -ExpandProperty 'categories' `
                    -ErrorAction SilentlyContinue
            }

            Write-Verbose "An Intune Windows Office Suite App with Id {$($instance.Id)} and DisplayName {$($this.DisplayName)} was found."

            #region complex types
            $complexCategories = @()
            foreach ($category in $instance.Categories)
            {
                $myCategory = [ordered]@{}
                $myCategory.Add('Id', $category.id)
                $myCategory.Add('DisplayName', $category.displayName)
                $complexCategories += $myCategory
            }

            $complexExcludedApps = [ordered]@{}
            if ($null -ne $instance.excludedApps)
            {
                $instance.excludedApps.GetEnumerator() | ForEach-Object {
                    $complexExcludedApps.Add($_.Key, $_.Value)
                }
            }
            if ($complexExcludedApps.Count -eq 0)
            {
                $complexExcludedApps = $null
            }

            $results = @{
                Id                                   = $instance.Id
                DisplayName                          = $instance.DisplayName
                Description                          = $instance.Description
                IsFeatured                           = $instance.IsFeatured
                PrivacyInformationUrl                = $instance.PrivacyInformationUrl
                InformationUrl                       = $instance.InformationUrl
                Notes                                = $instance.Notes
                RoleScopeTagIds                      = Resolve-M365DSCIntuneRoleScopeTagNames -CurrentValues $instance.RoleScopeTagIds -DesiredValues $this.RoleScopeTagIds
                AutoAcceptEula                       = $instance.autoAcceptEula
                ProductIds                           = $instance.productIds
                UseSharedComputerActivation          = $instance.useSharedComputerActivation
                UpdateChannel                        = $instance.updateChannel
                OfficeSuiteAppDefaultFileFormat      = $instance.officeSuiteAppDefaultFileFormat
                OfficePlatformArchitecture           = $instance.officePlatformArchitecture
                LocalesToInstall                     = $instance.localesToInstall
                InstallProgressDisplayLevel          = $instance.installProgressDisplayLevel
                ShouldUninstallOlderVersionsOfOffice = $instance.shouldUninstallOlderVersionsOfOffice
                TargetVersion                        = $instance.targetVersion
                UpdateVersion                        = $instance.updateVersion
                OfficeConfigurationXml               = $instance.officeConfigurationXml
                # LargeIcon                       = $complexLargeIcon
                ExcludedApps                         = $complexExcludedApps
                Categories                           = $complexCategories
                Ensure                               = 'Present'
                Credential                           = $this.Credential
                ApplicationId                        = $this.ApplicationId
                TenantId                             = $this.TenantId
                ApplicationSecret                    = $this.ApplicationSecret
                CertificateThumbprint                = $this.CertificateThumbprint
                CertificatePath                      = $this.CertificatePath
                CertificatePassword                  = $this.CertificatePassword
                ManagedIdentity                      = $this.ManagedIdentity
                AccessTokens                         = $this.AccessTokens
            }

            #Assignments
            $resultAssignments = @()
            $appAssignments = Get-MgBetaDeviceAppManagementMobileAppAssignment -MobileAppId $instance.Id
            if ($null -ne $appAssignments -and $appAssignments.Count -gt 0)
            {
                [array]$appAssignments = $appAssignments | Where-Object -Property source -EQ 'direct'
                $convertedAssignments = ConvertFrom-IntuneMobileAppAssignment `
                    -IncludeDeviceFilter:$true `
                    -Assignments ($appAssignments)

                # Filter out 'source' from the assignment objects
                foreach ($assignment in $convertedAssignments)
                {
                    if ($assignment.ContainsKey('source'))
                    {
                        $assignment.Remove('source')
                    }
                }

                $resultAssignments += $convertedAssignments
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

        $boundParameters.Remove('Categories') | Out-Null

        $boundParameters = Rename-M365DSCCimInstanceParameter -Properties $boundParameters

        if ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Creating an Intune Windows Office Suite App with DisplayName {$($this.DisplayName)}"
            $createParameters = $boundParameters
            $createParameters.Remove('Assignments') | Out-Null

            $createParameters.Remove('Id') | Out-Null
            $createParameters.Add('Publisher', 'Microsoft')
            $createParameters.Add('Developer', 'Microsoft')
            $createParameters.Add('Owner', 'Microsoft')

            $createParameters.Add('@odata.type', '#microsoft.graph.officeSuiteApp')
            $app = New-MgBetaDeviceAppManagementMobileApp -BodyParameter $createParameters

            foreach ($category in $this.Categories)
            {
                if ($category.Id)
                {
                    $currentCategory = Get-MgBetaDeviceAppManagementMobileAppCategory -MobileAppCategoryId $category.Id
                }
                else
                {
                    $currentCategory = Get-MgBetaDeviceAppManagementMobileAppCategory -All -Filter "DisplayName eq '$($category.DisplayName -replace "'", "''")'"
                }

                if ($null -eq $currentCategory)
                {
                    throw "Mobile App Category with DisplayName $($category.DisplayName) not found."
                }

                Invoke-M365DSCGraphRequest -Uri "/beta/deviceAppManagement/mobileApps/$($app.Id)/categories/`$ref" -Method 'POST' -Body @{
                    '@odata.id' = "$((Get-MSCloudLoginConnectionProfile -Workload MicrosoftGraph).ResourceUrl)beta/deviceAppManagement/mobileAppCategories/$($currentCategory.Id)"
                }
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
            Write-Verbose -Message "Updating the Intune Windows Office Suite App with DisplayName {$($this.DisplayName)}"
            $updateParameters = $boundParameters
            $updateParameters.Remove('Assignments') | Out-Null

            $updateParameters.Remove('Id') | Out-Null
            $updateParameters.Remove('OfficePlatformArchitecture') | Out-Null

            if (-not [System.String]::IsNullOrEmpty($currentInstance.OfficeConfigurationXml))
            {
                foreach ($designerProperty in @('AutoAcceptEula', 'ProductIds', 'UseSharedComputerActivation', 'UpdateChannel',
                        'OfficeSuiteAppDefaultFileFormat', 'LocalesToInstall', 'InstallProgressDisplayLevel',
                        'ShouldUninstallOlderVersionsOfOffice', 'TargetVersion', 'UpdateVersion', 'ExcludedApps'))
                {
                    $updateParameters.Remove($designerProperty) | Out-Null
                }
            }

            $updateParameters.Add('@odata.type', '#microsoft.graph.officeSuiteApp')
            Update-MgBetaDeviceAppManagementMobileApp -MobileAppId $currentInstance.Id -BodyParameter $updateParameters

            [array]$referenceObject = if ($null -ne $currentInstance.Categories.DisplayName)
            {
                $currentInstance.Categories.DisplayName
            }
            else
            {
                , @()
            }
            [array]$differenceObject = if ($null -ne $this.Categories.DisplayName)
            {
                $this.Categories.DisplayName
            }
            else
            {
                , @()
            }
            $delta = Compare-Object -ReferenceObject $referenceObject -DifferenceObject $differenceObject -PassThru
            foreach ($diff in $delta)
            {
                if ($diff.SideIndicator -eq '=>')
                {
                    $category = $this.Categories | Where-Object -Property DisplayName -EQ $diff
                    if ($category.Id)
                    {
                        $currentCategory = Get-MgBetaDeviceAppManagementMobileAppCategory -MobileAppCategoryId $category.Id
                    }
                    else
                    {
                        $currentCategory = Get-MgBetaDeviceAppManagementMobileAppCategory -All -Filter "DisplayName eq '$($category.DisplayName -replace "'", "''")'"
                    }

                    if ($null -eq $currentCategory)
                    {
                        throw "Mobile App Category with DisplayName $($category.DisplayName) not found."
                    }

                    Invoke-M365DSCGraphRequest -Uri "/beta/deviceAppManagement/mobileApps/$($currentInstance.Id)/categories/`$ref" -Method 'POST' -Body @{
                        '@odata.id' = "$((Get-MSCloudLoginConnectionProfile -Workload MicrosoftGraph).ResourceUrl)beta/deviceAppManagement/mobileAppCategories/$($currentCategory.Id)"
                    }
                }
                else
                {
                    $category = $currentInstance.Categories | Where-Object -Property DisplayName -EQ $diff
                    Invoke-M365DSCGraphRequest -Uri "/beta/deviceAppManagement/mobileApps/$($currentInstance.Id)/categories/$($category.Id)/`$ref" -Method 'DELETE'
                }
            }

            #Assignments
            $assignmentsHash = ConvertTo-IntuneMobileAppAssignment -IncludeDeviceFilter:$true -Assignments $this.Assignments
            Update-DeviceAppManagementPolicyAssignment -AppManagementPolicyId $currentInstance.Id `
                -Assignments $assignmentsHash
        }
        elseif ($this.Ensure -eq 'Absent' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Remove the Intune Windows Office Suite App with Id {$($currentInstance.Id)}"
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
            $baseFilter = "isof('microsoft.graph.officeSuiteApp')"
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

                if ($null -ne $Results.ExcludedApps)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.ExcludedApps `
                        -CIMInstanceName 'DeviceManagementMobileAppExcludedApp'

                    if (-not [System.String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.ExcludedApps = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('ExcludedApps') | Out-Null
                    }
                }

                # if ($null -ne $Results.LargeIcon)
                # {
                #     $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                #         -ComplexObject $Results.LargeIcon `
                #         -CIMInstanceName 'DeviceManagementMimeContent'

                #     if (-not [System.String]::IsNullOrWhiteSpace($complexTypeStringResult))
                #     {
                #         $Results.LargeIcon = $complexTypeStringResult
                #     }
                #     else
                #     {
                #         $Results.Remove('LargeIcon') | Out-Null
                #     }
                # }

                if ($null -ne $Results.Assignments)
                {
                    if ($Results.Assignments)
                    {
                        $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                            -ComplexObject $Results.Assignments `
                            -CIMInstanceName DeviceManagementMobileAppAssignment

                        if ($complexTypeStringResult)
                        {
                            $Results.Assignments = $complexTypeStringResult
                        }
                        else
                        {
                            $Results.Remove('Assignments') | Out-Null
                        }
                    }
                }
                #endregion complex types

                $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                    -ConnectionMode $ConnectionMode `
                    -ModulePath $this.GetModulePath() `
                    -Results $Results `
                    -Credential $this.Credential `
                    -NoEscape @('Categories', 'ExcludedApps', 'Assignments') `
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

    [System.Collections.Hashtable] GetCompareParameters()
    {
        return @{
            ExcludedProperties = @('OfficePlatformArchitecture')
        }
    }

    hidden [IntuneMobileAppsWindowsOfficeSuiteApp] AsResult([System.Object] $Values)
    {
        if ($Values -is [IntuneMobileAppsWindowsOfficeSuiteApp])
        {
            return $Values
        }

        $result = [IntuneMobileAppsWindowsOfficeSuiteApp]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
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

class MSFT_DeviceManagementMobileAppExcludedApp
{
    [DscProperty()]
    [System.ComponentModel.Description('Specifies whether to exclude Microsoft Office Access from the installation.')]
    [System.Nullable[System.Boolean]] $Access

    [DscProperty()]
    [System.ComponentModel.Description('Specifies whether to exclude Microsoft Search (Bing) as the default from the installation.')]
    [System.Nullable[System.Boolean]] $Bing

    [DscProperty()]
    [System.ComponentModel.Description('Specifies whether to exclude Microsoft Office Excel from the installation.')]
    [System.Nullable[System.Boolean]] $Excel

    [DscProperty()]
    [System.ComponentModel.Description('Specifies whether to exclude Microsoft Office OneDrive for Business (Groove) from the installation.')]
    [System.Nullable[System.Boolean]] $Groove

    [DscProperty()]
    [System.ComponentModel.Description('Specifies whether to exclude Microsoft Office InfoPath from the installation.')]
    [System.Nullable[System.Boolean]] $InfoPath

    [DscProperty()]
    [System.ComponentModel.Description('Specifies whether to exclude Microsoft Office Skype for Business (Lync) from the installation.')]
    [System.Nullable[System.Boolean]] $Lync

    [DscProperty()]
    [System.ComponentModel.Description('Specifies whether to exclude Microsoft Office OneDrive from the installation.')]
    [System.Nullable[System.Boolean]] $OneDrive

    [DscProperty()]
    [System.ComponentModel.Description('Specifies whether to exclude Microsoft Office OneNote from the installation.')]
    [System.Nullable[System.Boolean]] $OneNote

    [DscProperty()]
    [System.ComponentModel.Description('Specifies whether to exclude Microsoft Office Outlook from the installation.')]
    [System.Nullable[System.Boolean]] $Outlook

    [DscProperty()]
    [System.ComponentModel.Description('Specifies whether to exclude Microsoft Office PowerPoint from the installation.')]
    [System.Nullable[System.Boolean]] $PowerPoint

    [DscProperty()]
    [System.ComponentModel.Description('Specifies whether to exclude Microsoft Office Publisher from the installation.')]
    [System.Nullable[System.Boolean]] $Publisher

    [DscProperty()]
    [System.ComponentModel.Description('Specifies whether to exclude Microsoft Office SharePoint Designer from the installation.')]
    [System.Nullable[System.Boolean]] $SharePointDesigner

    [DscProperty()]
    [System.ComponentModel.Description('Specifies whether to exclude Microsoft Office Teams from the installation.')]
    [System.Nullable[System.Boolean]] $Teams

    [DscProperty()]
    [System.ComponentModel.Description('Specifies whether to exclude Microsoft Office Visio from the installation.')]
    [System.Nullable[System.Boolean]] $Visio

    [DscProperty()]
    [System.ComponentModel.Description('Specifies whether to exclude Microsoft Office Word from the installation.')]
    [System.Nullable[System.Boolean]] $Word
}
