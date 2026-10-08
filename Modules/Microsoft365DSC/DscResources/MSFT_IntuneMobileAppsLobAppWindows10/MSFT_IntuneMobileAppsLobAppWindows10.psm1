using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class IntuneMobileAppsLobAppWindows10 : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The admin provided or imported title of the app.')]
    [System.String] $DisplayName

    [DscProperty()]
    [System.ComponentModel.Description('The unique identifier for an entity. Read-only.')]
    [System.String] $Id

    [DscProperty()]
    [System.ComponentModel.Description('The name of the main Lob application file. Required for creating the resource.')]
    [System.String] $FileName

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
    [System.ComponentModel.Description('List of scope tag ids for this mobile app.')]
    [System.String[]] $RoleScopeTagIds

    [DscProperty()]
    [System.ComponentModel.Description('The list of categories for this app.')]
    [MSFT_DeviceManagementMobileAppCategory[]] $Categories

    [DscProperty()]
    [System.ComponentModel.Description('The value for the minimum applicable Windows operating system.')]
    [MSFT_MicrosoftGraphWindowsMinimumOperatingSystem] $MinimumSupportedOperatingSystem

    [DscProperty()]
    [System.ComponentModel.Description('Represents the assignment to the Intune policy.')]
    [MSFT_DeviceManagementAppxMobileAppAssignment[]] $Assignments

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

    IntuneMobileAppsLobAppWindows10() : base()
    {
        $this.ResourceCache.Add('FileTypeToPropertyMap', @{
            Appx       = @{
                ApplicableArchitectures = @('x64')
                ApplicableDeviceTypes   = @('desktop')
            }
            AppxBundle = @{
                ApplicableArchitectures = @('x86', 'x64', 'arm')
                ApplicableDeviceTypes   = @('desktop')
            }
            Msix       = @{
                ApplicableArchitectures = @('x64')
                ApplicableDeviceTypes   = @('desktop', 'mobile', 'holographic', 'team')
            }
            MsixBundle = @{
                ApplicableArchitectures = @('x86', 'x64')
                ApplicableDeviceTypes   = @('desktop', 'mobile', 'holographic', 'team')
            }
        })
    }

    [IntuneMobileAppsLobAppWindows10] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [IntuneMobileAppsLobAppWindows10]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration for the Intune Mobile Apps Lob App for Windows10 with Id {$($this.Id)} and DisplayName {$($this.DisplayName)}"

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
                    Write-Verbose -Message "Could not find an Intune Mobile Apps Lob App for Windows10 with Id {$($this.Id)}"

                    if (-not [System.String]::IsNullOrEmpty($this.DisplayName))
                    {
                        $getValue = Get-MgBetaDeviceAppManagementMobileApp `
                            -Filter "DisplayName eq '$($this.DisplayName -replace "'", "''")'" `
                            -All `
                            -ErrorAction SilentlyContinue | Where-Object -Property '@odata.type' -EQ '#microsoft.graph.windowsUniversalAppX'
                    }
                }
                #endregion
                if ($null -eq $getValue)
                {
                    Write-Verbose -Message "Could not find an Intune Mobile Apps Lob App for Windows10 with DisplayName {$($this.DisplayName)}."
                    return $this.AsResult($nullResult)
                }

                $getValue = Get-MgBetaDeviceAppManagementMobileApp -MobileAppId $getValue.Id -ExpandProperty 'Categories'
            }
            else
            {
                $getValue = Get-MgBetaDeviceAppManagementMobileApp -MobileAppId $this.ExportedInstance.Id -ExpandProperty 'Categories'
            }
            $resolvedId = $getValue.Id
            Write-Verbose -Message "An Intune Mobile Apps Lob App for Windows10 with Id {$($resolvedId)} and DisplayName {$($this.DisplayName)} was found"

            #region resource generator code
            $complexCategories = @()
            foreach ($category in $getValue.Categories)
            {
                $myCategory = [ordered]@{}
                $myCategory.Add('Id', $category.id)
                $myCategory.Add('DisplayName', $category.displayName)
                $complexCategories += $myCategory
            }

            $complexMinimumSupportedOperatingSystem = [ordered]@{}
            $complexMinimumSupportedOperatingSystem.Add('V8_0', $getValue.minimumSupportedOperatingSystem.v8_0)
            $complexMinimumSupportedOperatingSystem.Add('V8_1', $getValue.minimumSupportedOperatingSystem.v8_1)
            $complexMinimumSupportedOperatingSystem.Add('V10_0', $getValue.minimumSupportedOperatingSystem.v10_0)
            $complexMinimumSupportedOperatingSystem.Add('V10_1607', $getValue.minimumSupportedOperatingSystem.v10_1607)
            $complexMinimumSupportedOperatingSystem.Add('V10_1703', $getValue.minimumSupportedOperatingSystem.v10_1703)
            $complexMinimumSupportedOperatingSystem.Add('V10_1709', $getValue.minimumSupportedOperatingSystem.v10_1709)
            $complexMinimumSupportedOperatingSystem.Add('V10_1803', $getValue.minimumSupportedOperatingSystem.v10_1803)
            $complexMinimumSupportedOperatingSystem.Add('V10_1809', $getValue.minimumSupportedOperatingSystem.v10_1809)
            $complexMinimumSupportedOperatingSystem.Add('V10_1903', $getValue.minimumSupportedOperatingSystem.v10_1903)
            $complexMinimumSupportedOperatingSystem.Add('V10_1909', $getValue.minimumSupportedOperatingSystem.v10_1909)
            $complexMinimumSupportedOperatingSystem.Add('V10_2004', $getValue.minimumSupportedOperatingSystem.v10_2004)
            $complexMinimumSupportedOperatingSystem.Add('V10_2H20', $getValue.minimumSupportedOperatingSystem.v10_2H20)
            $complexMinimumSupportedOperatingSystem.Add('V10_21H1', $getValue.minimumSupportedOperatingSystem.v10_21H1)
            if ($complexMinimumSupportedOperatingSystem.Values.Where({ $null -ne $_ }).Count -eq 0)
            {
                $complexMinimumSupportedOperatingSystem = $null
            }

            $complexLargeIcon = $null
            if ($null -ne $getValue.LargeIcon.Value)
            {
                $complexLargeIcon = [ordered]@{}
                $complexLargeIcon.Add('Type', $getValue.LargeIcon.Type)
                $complexLargeIcon.Add('Value', $getValue.LargeIcon.Value)
            }
            #endregion

            $results = @{
                #region resource generator code
                Categories                      = $complexCategories
                MinimumSupportedOperatingSystem = $complexMinimumSupportedOperatingSystem
                FileName                        = $getValue.fileName
                Description                     = $getValue.Description
                Developer                       = $getValue.Developer
                DisplayName                     = $getValue.DisplayName
                InformationUrl                  = $getValue.InformationUrl
                IsFeatured                      = $getValue.IsFeatured
                LargeIcon                       = $complexLargeIcon
                Notes                           = $getValue.Notes
                Owner                           = $getValue.Owner
                PrivacyInformationUrl           = $getValue.PrivacyInformationUrl
                Publisher                       = $getValue.Publisher
                RoleScopeTagIds                 = Resolve-M365DSCIntuneRoleScopeTagNames -CurrentValues $getValue.RoleScopeTagIds -DesiredValues $this.RoleScopeTagIds
                Id                              = $getValue.Id
                Ensure                          = 'Present'
                Credential                      = $this.Credential
                ApplicationId                   = $this.ApplicationId
                TenantId                        = $this.TenantId
                ApplicationSecret               = $this.ApplicationSecret
                CertificateThumbprint           = $this.CertificateThumbprint
                CertificatePath                 = $this.CertificatePath
                CertificatePassword             = $this.CertificatePassword
                ManagedIdentity                 = $this.ManagedIdentity
                #endregion
            }

            $assignmentsValues = Get-MgBetaDeviceAppManagementMobileAppAssignment -MobileAppId $resolvedId
            $assignmentResult = @()
            if ($assignmentsValues.Count -gt 0)
            {
                [array]$assignmentsValues = $assignmentsValues | Where-Object -Property source -EQ 'direct'
                $assignmentResult += ConvertFrom-IntuneMobileAppAssignment -Assignments $assignmentsValues -IncludeDeviceFilter $true
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

        Write-Verbose -Message "Setting configuration of the Intune Mobile Apps Lob App for Windows10 with Id {$($this.Id)} and DisplayName {$($this.DisplayName)}"

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
            Write-Verbose -Message "Creating an Intune Mobile Apps Lob App for Windows10 with DisplayName {$($this.DisplayName)}"
            $createParameters = $boundParameters
            $createParameters.Remove('Assignments') | Out-Null

            if (-not $createParameters.ContainsKey('FileName') -or [System.String]::IsNullOrEmpty($createParameters.FileName))
            {
                throw 'FileName is required to create an Intune Mobile Apps Lob App for Windows10.'
            }

            $createParameters.Remove('Id') | Out-Null

            #region resource generator code
            $fileExtension = $this.FileName.Split('.')[-1]
            $createParameters.Add('@odata.type', '#microsoft.graph.windowsUniversalAppX')
            $createParameters.Add('applicableArchitectures', $this.ResourceCache['FileTypeToPropertyMap'][$fileExtension].ApplicableArchitectures -join ',')
            $createParameters.Add('applicableDeviceTypes', $this.ResourceCache['FileTypeToPropertyMap'][$fileExtension].ApplicableDeviceTypes -join ',')
            if (-not $createParameters.ContainsKey('minimumSupportedOperatingSystem'))
            {
                $createParameters.Add('minimumSupportedOperatingSystem', @{v10_0 = $true })
            }
            $createParameters.Add('identityName', 'Sample')
            $createParameters.Add('identityPublisherHash', 'SamplePublisherHash')
            $createParameters.Add('identityVersion', '0.0.1')
            if ($fileExtension -like 'Msix*')
            {
                $createParameters.Add('isMsix', $true)
            }
            else
            {
                $createParameters.Add('isMsix', $false)
            }
            if ($fileExtension -like '*Bundle')
            {
                $createParameters.Add('isBundle', $true)
            }
            else
            {
                $createParameters.Add('isBundle', $false)
            }
            $policy = New-MgBetaDeviceAppManagementMobileApp -BodyParameter $createParameters

            Invoke-M365DSCIntuneMobileAppInitialUpload -AppId $policy.Id -OdataType '#microsoft.graph.windowsUniversalAppX' -FileExtension $fileExtension

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
            }
            #endregion
        }
        elseif ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Updating the Intune Mobile Apps Lob App for Windows10 with Id {$($currentInstance.Id)}"
            $updateParameters = $boundParameters
            $updateParameters.Remove('Assignments') | Out-Null

            $updateParameters.Remove('Id') | Out-Null

            #region resource generator code
            $updateParameters.Add('@odata.type', '#microsoft.graph.windowsUniversalAppX')
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
            #endregion
        }
        elseif ($this.Ensure -eq 'Absent' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Removing the Intune Mobile Apps Lob App for Windows10 with Id {$($currentInstance.Id)}"
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
            $baseFilter = "isof('microsoft.graph.windowsUniversalAppX')"
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
                if ($null -ne $Results.MinimumSupportedOperatingSystem)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.MinimumSupportedOperatingSystem `
                        -CIMInstanceName 'MicrosoftGraphWindowsMinimumOperatingSystem'
                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.MinimumSupportedOperatingSystem = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('MinimumSupportedOperatingSystem') | Out-Null
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

                if ($Results.Assignments)
                {
                    $complexMapping = @(
                        @{
                            Name            = 'AssignmentSettings'
                            CIMInstanceName = 'DeviceManagementAppxMobileAppAssignmentSettings'
                            IsRequired      = $false
                        }
                    )
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.Assignments `
                        -CIMInstanceName DeviceManagementAppxMobileAppAssignment `
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
                    -NoEscape @('Assignments', 'Categories', 'LargeIcon', 'MinimumSupportedOperatingSystem') `
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

    hidden [IntuneMobileAppsLobAppWindows10] AsResult([System.Object] $Values)
    {
        if ($Values -is [IntuneMobileAppsLobAppWindows10])
        {
            return $Values
        }

        $result = [IntuneMobileAppsLobAppWindows10]::new()
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

class MSFT_MicrosoftGraphWindowsMinimumOperatingSystem
{
    [DscProperty()]
    [System.ComponentModel.Description('Windows version 10.0 or later.')]
    [System.Nullable[System.Boolean]] $V10_0

    [DscProperty()]
    [System.ComponentModel.Description('Windows 10 1607 or later.')]
    [System.Nullable[System.Boolean]] $V10_1607

    [DscProperty()]
    [System.ComponentModel.Description('Windows 10 1703 or later.')]
    [System.Nullable[System.Boolean]] $V10_1703

    [DscProperty()]
    [System.ComponentModel.Description('Windows 10 1709 or later.')]
    [System.Nullable[System.Boolean]] $V10_1709

    [DscProperty()]
    [System.ComponentModel.Description('Windows 10 1803 or later.')]
    [System.Nullable[System.Boolean]] $V10_1803

    [DscProperty()]
    [System.ComponentModel.Description('Windows 10 1809 or later.')]
    [System.Nullable[System.Boolean]] $V10_1809

    [DscProperty()]
    [System.ComponentModel.Description('Windows 10 1903 or later.')]
    [System.Nullable[System.Boolean]] $V10_1903

    [DscProperty()]
    [System.ComponentModel.Description('Windows 10 1909 or later.')]
    [System.Nullable[System.Boolean]] $V10_1909

    [DscProperty()]
    [System.ComponentModel.Description('Windows 10 2004 or later.')]
    [System.Nullable[System.Boolean]] $V10_2004

    [DscProperty()]
    [System.ComponentModel.Description('Windows 10 21H1 or later.')]
    [System.Nullable[System.Boolean]] $V10_21H1

    [DscProperty()]
    [System.ComponentModel.Description('Windows 10 2H20 or later.')]
    [System.Nullable[System.Boolean]] $V10_2H20

    [DscProperty()]
    [System.ComponentModel.Description('Windows version 8.0 or later.')]
    [System.Nullable[System.Boolean]] $V8_0

    [DscProperty()]
    [System.ComponentModel.Description('Windows version 8.1 or later.')]
    [System.Nullable[System.Boolean]] $V8_1
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

class MSFT_DeviceManagementAppxMobileAppAssignment : MSFT_DeviceManagementMobileAppAssignment
{
    [DscProperty()]
    [System.ComponentModel.Description('The settings of the assignment.')]
    [MSFT_DeviceManagementAppxMobileAppAssignmentSettings] $assignmentSettings
}

class MSFT_DeviceManagementMobileAppAssignmentSettings
{
    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('The odata type of the assignment type.')]
    [ValidateSet('#microsoft.graph.androidManagedStoreAppAssignmentSettings', '#microsoft.graph.iosStoreAppAssignmentSettings', '#microsoft.graph.iosLobAppAssignmentSettings', '#microsoft.graph.macOsLobAppAssignmentSettings', '#microsoft.graph.win32CatalogAppAssignmentSettings', '#microsoft.graph.win32LobAppAssignmentSettings', '#microsoft.graph.winGetAppAssignmentSettings', '#microsoft.graph.windowsAutoUpdateCatalogAppAssignmentSettings', '#microsoft.graph.windowsUniversalAppXAppAssignmentSettings')]
    [System.String] $odataType
}

class MSFT_DeviceManagementAppxMobileAppAssignmentSettings : MSFT_DeviceManagementMobileAppAssignmentSettings
{
    [DscProperty()]
    [System.ComponentModel.Description('If true, uses device execution context for Windows Universal AppX mobile app. Device-context install is not allowed when this type of app is targeted with Available intent. Defaults to false.')]
    [System.Nullable[System.Boolean]] $useDeviceContext
}
