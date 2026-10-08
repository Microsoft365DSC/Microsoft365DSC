using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class IntuneMobileAppsLobAppiOS : M365DSCResourceBase
{
    [DscProperty()]
    [System.ComponentModel.Description('The unique identifier for an entity. Read-only.')]
    [System.String] $Id

    [DscProperty(Key)]
    [System.ComponentModel.Description('The admin provided or imported title of the app.')]
    [System.String] $DisplayName

    [DscProperty()]
    [System.ComponentModel.Description('The protocol used to deliver the app to the apple device(s). When the property is set to Declarative Device Management (DDM) protocol ''declarativeDeviceManagement'' then it can no longer be modified or updated to ''mobileDeviceManagement'' or ''default''. The default value is ''default'', which indicates the Apple MDM protocol. Possible values are: default, mobileDeviceManagement, declarativeDeviceManagement.')]
    [ValidateSet('default', 'mobileDeviceManagement', 'declarativeDeviceManagement')]
    [System.String] $AppleDeviceAppDeliveryProtocolType

    [DscProperty()]
    [System.ComponentModel.Description('The iOS architecture for which this app can run on.')]
    [MSFT_MicrosoftGraphIosDeviceType] $ApplicableDeviceType

    [DscProperty()]
    [System.ComponentModel.Description('The build number of iOS Line of Business (LoB) app.')]
    [System.String] $BuildNumber

    [DscProperty()]
    [System.ComponentModel.Description('The Identity Name.')]
    [System.String] $BundleId

    [DscProperty()]
    [System.ComponentModel.Description('The list of categories for this app.')]
    [MSFT_DeviceManagementMobileAppCategory[]] $Categories

    [DscProperty()]
    [System.ComponentModel.Description('The value for the minimum applicable operating system.')]
    [MSFT_MicrosoftGraphIosMinimumOperatingSystem] $MinimumSupportedOperatingSystem

    [DscProperty()]
    [System.ComponentModel.Description('The version number of iOS Line of Business (LoB) app.')]
    [System.String] $VersionNumber

    [DscProperty()]
    [System.ComponentModel.Description('The name of the main Lob application file.')]
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
    [System.ComponentModel.Description('Represents the assignment to the Intune policy.')]
    [MSFT_DeviceManagementLobAppiOSAssignment[]] $Assignments

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

    [IntuneMobileAppsLobAppiOS] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [IntuneMobileAppsLobAppiOS]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration for the Intune Mobile Apps Lob App iOS with Id {$($this.Id)} and DisplayName {$($this.DisplayName)}"

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
                    Write-Verbose -Message "Could not find an Intune Mobile Apps Lob App iOS with Id {$($this.Id)}"

                    if (-not [System.String]::IsNullOrEmpty($this.DisplayName))
                    {
                        $getValue = Get-MgBetaDeviceAppManagementMobileApp -All `
                            -Filter "DisplayName eq '$($this.DisplayName -replace "'", "''")'" `
                            -ErrorAction SilentlyContinue | Where-Object -Property '@odata.type' -EQ '#microsoft.graph.iosLobApp'
                    }
                }
                #endregion
                if ($null -eq $getValue)
                {
                    Write-Verbose -Message "Could not find an Intune Mobile Apps Lob App iOS with DisplayName {$($this.DisplayName)}."
                    return $this.AsResult($nullResult)
                }

                $getValue = Get-MgBetaDeviceAppManagementMobileApp -MobileAppId $getValue.Id -ExpandProperty 'Categories'
            }
            else
            {
                $getValue = Get-MgBetaDeviceAppManagementMobileApp -MobileAppId $this.ExportedInstance.Id -ExpandProperty 'Categories'
            }
            $resolvedId = $getValue.Id
            Write-Verbose -Message "An Intune Mobile Apps Lob App iOS with Id {$($resolvedId)} and DisplayName {$($this.DisplayName)} was found"

            #region resource generator code
            $complexApplicableDeviceType = [ordered]@{}
            $complexApplicableDeviceType.Add('IPad', $getValue.applicableDeviceType.iPad)
            $complexApplicableDeviceType.Add('IPhoneAndIPod', $getValue.applicableDeviceType.iPhoneAndIPod)
            if ($complexApplicableDeviceType.Values.Where({ $null -ne $_ }).Count -eq 0)
            {
                $complexApplicableDeviceType = $null
            }

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
            $complexMinimumSupportedOperatingSystem.Add('V9_0', $getValue.minimumSupportedOperatingSystem.v9_0)
            $complexMinimumSupportedOperatingSystem.Add('V10_0', $getValue.minimumSupportedOperatingSystem.v10_0)
            $complexMinimumSupportedOperatingSystem.Add('V11_0', $getValue.minimumSupportedOperatingSystem.v11_0)
            $complexMinimumSupportedOperatingSystem.Add('V12_0', $getValue.minimumSupportedOperatingSystem.v12_0)
            $complexMinimumSupportedOperatingSystem.Add('V13_0', $getValue.minimumSupportedOperatingSystem.v13_0)
            $complexMinimumSupportedOperatingSystem.Add('V14_0', $getValue.minimumSupportedOperatingSystem.v14_0)
            $complexMinimumSupportedOperatingSystem.Add('V15_0', $getValue.minimumSupportedOperatingSystem.v15_0)
            $complexMinimumSupportedOperatingSystem.Add('V16_0', $getValue.minimumSupportedOperatingSystem.v16_0)
            $complexMinimumSupportedOperatingSystem.Add('V17_0', $getValue.minimumSupportedOperatingSystem.v17_0)
            $complexMinimumSupportedOperatingSystem.Add('V18_0', $getValue.minimumSupportedOperatingSystem.v18_0)
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
                AppleDeviceAppDeliveryProtocolType = $getValue.appleDeviceAppDeliveryProtocolType
                ApplicableDeviceType               = $complexApplicableDeviceType
                BuildNumber                        = $getValue.buildNumber
                BundleId                           = $getValue.bundleId
                Categories                         = $complexCategories
                MinimumSupportedOperatingSystem    = $complexMinimumSupportedOperatingSystem
                VersionNumber                      = $getValue.versionNumber
                FileName                           = $getValue.fileName
                Description                        = $getValue.Description
                Developer                          = $getValue.Developer
                DisplayName                        = $getValue.DisplayName
                InformationUrl                     = $getValue.InformationUrl
                IsFeatured                         = $getValue.IsFeatured
                LargeIcon                          = $complexLargeIcon
                Notes                              = $getValue.Notes
                Owner                              = $getValue.Owner
                PrivacyInformationUrl              = $getValue.PrivacyInformationUrl
                Publisher                          = $getValue.Publisher
                RoleScopeTagIds                    = Resolve-M365DSCIntuneRoleScopeTagNames -CurrentValues $getValue.RoleScopeTagIds -DesiredValues $this.RoleScopeTagIds
                Id                                 = $getValue.Id
                Ensure                             = 'Present'
                Credential                         = $this.Credential
                ApplicationId                      = $this.ApplicationId
                TenantId                           = $this.TenantId
                ApplicationSecret                  = $this.ApplicationSecret
                CertificateThumbprint              = $this.CertificateThumbprint
                CertificatePath                    = $this.CertificatePath
                CertificatePassword                = $this.CertificatePassword
                ManagedIdentity                    = $this.ManagedIdentity
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
                if ($null -ne $assignment.assignmentSettings -and $null -ne $assignment.assignmentSettings.vpnConfigurationId)
                {
                    $vpnConfiguration = Get-MgBetaDeviceManagementDeviceConfiguration -DeviceConfigurationId $assignment.assignmentSettings.vpnConfigurationId -Property 'DisplayName' -ErrorAction SilentlyContinue
                    if ($null -ne $vpnConfiguration)
                    {
                        $assignment.assignmentSettings.vpnConfigurationId = $vpnConfiguration.DisplayName
                    }
                }
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

        Write-Verbose -Message "Setting configuration of the Intune Mobile Apps Lob App iOS with Id {$($this.Id)} and DisplayName {$($this.DisplayName)}"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $currentInstance = $this.Get().ToHashtable()

        foreach ($assignment in $this.Assignments)
        {
            if ($null -ne $assignment.assignmentSettings -and -not [System.String]::IsNullOrEmpty($assignment.assignmentSettings.vpnConfigurationId))
            {
                if (-not [System.Guid]::TryParse($assignment.assignmentSettings.vpnConfigurationId, [ref][System.Guid]::Empty))
                {
                    [array]$vpnConfiguration = Get-MgBetaDeviceManagementDeviceConfiguration -All -Filter "displayName eq '$($assignment.assignmentSettings.vpnConfigurationId)'" | Where-Object -Property '@odata.type' -Like '#microsoft.graph.*VpnConfiguration'
                    if ($null -eq $vpnConfiguration -or $vpnConfiguration.Count -eq 0)
                    {
                        throw "Could not find a VPN Configuration Policy with DisplayName '$($assignment.assignmentSettings.vpnConfigurationId)'."
                    }
                    $assignment.assignmentSettings.vpnConfigurationId = $vpnConfiguration.Id
                }
            }
        }

        $boundParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()

        if ($boundParameters.ContainsKey('RoleScopeTagIds'))
        {
            $boundParameters.RoleScopeTagIds = Resolve-M365DSCIntuneRoleScopeTagIds -RoleScopeTagIds $this.RoleScopeTagIds
        }

        $boundParameters.Remove('Categories') | Out-Null

        $boundParameters = Rename-M365DSCCimInstanceParameter -Properties $boundParameters

        if ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Creating an Intune Mobile Apps Lob App iOS with DisplayName {$($this.DisplayName)}"
            $createParameters = $boundParameters
            $createParameters.Remove('Assignments') | Out-Null

            $createParameters.Remove('Id') | Out-Null

            #region resource generator code
            $createParameters.Add('@odata.type', '#microsoft.graph.iosLobApp')
            $policy = New-MgBetaDeviceAppManagementMobileApp -BodyParameter $createParameters

            Invoke-M365DSCIntuneMobileAppInitialUpload -AppId $policy.Id -OdataType '#microsoft.graph.iosLobApp' -FileExtension 'ipa'

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
            Write-Verbose -Message "Updating the Intune Mobile Apps Lob App iOS with Id {$($currentInstance.Id)}"
            $updateParameters = $boundParameters
            $updateParameters.Remove('Assignments') | Out-Null

            $updateParameters.Remove('Id') | Out-Null
            $updateParameters.Remove('AppleDeviceAppDeliveryProtocolType') | Out-Null

            #region resource generator code
            $updateParameters.Add('@odata.type', '#microsoft.graph.iosLobApp')
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
            Write-Verbose -Message "Removing the Intune Mobile Apps Lob App iOS with Id {$($currentInstance.Id)}"
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
            $baseFilter = "isof('microsoft.graph.iosLobApp')"
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

                if ($null -ne $Results.ApplicableDeviceType)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.ApplicableDeviceType `
                        -CIMInstanceName 'MicrosoftGraphIosDeviceType'
                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.ApplicableDeviceType = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('ApplicableDeviceType') | Out-Null
                    }
                }
                if ($null -ne $Results.MinimumSupportedOperatingSystem)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.MinimumSupportedOperatingSystem `
                        -CIMInstanceName 'MicrosoftGraphIosMinimumOperatingSystem'
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
                            CIMInstanceName = 'DeviceManagementLobAppiOSAssignmentSettings'
                            IsRequired      = $false
                        }
                    )
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.Assignments `
                        -CIMInstanceName DeviceManagementLobAppiOSAssignment `
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
                    -NoEscape @('Assignments', 'ApplicableDeviceType', 'MinimumSupportedOperatingSystem', 'LargeIcon') `
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

    hidden [IntuneMobileAppsLobAppiOS] AsResult([System.Object] $Values)
    {
        if ($Values -is [IntuneMobileAppsLobAppiOS])
        {
            return $Values
        }

        $result = [IntuneMobileAppsLobAppiOS]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}

class MSFT_MicrosoftGraphIosDeviceType
{
    [DscProperty()]
    [System.ComponentModel.Description('Whether the app should run on iPads.')]
    [System.Nullable[System.Boolean]] $IPad

    [DscProperty()]
    [System.ComponentModel.Description('Whether the app should run on iPhones and iPods.')]
    [System.Nullable[System.Boolean]] $IPhoneAndIPod
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

class MSFT_MicrosoftGraphIosMinimumOperatingSystem
{
    [DscProperty()]
    [System.ComponentModel.Description('Indicates the minimum iOS version support required for the managed device. When ''True'', iOS with OS Version 10.0 or later is required to install the app. If ''False'', iOS Version 10.0 is not the minimum version. Default value is False. Exactly one of the minimum operating system boolean values will be TRUE.')]
    [System.Nullable[System.Boolean]] $V10_0

    [DscProperty()]
    [System.ComponentModel.Description('Indicates the minimum iOS version support required for the managed device. When ''True'', iOS with OS Version 11.0 or later is required to install the app. If ''False'', iOS Version 11.0 is not the minimum version. Default value is False. Exactly one of the minimum operating system boolean values will be TRUE.')]
    [System.Nullable[System.Boolean]] $V11_0

    [DscProperty()]
    [System.ComponentModel.Description('Indicates the minimum iOS version support required for the managed device. When ''True'', iOS with OS Version 12.0 or later is required to install the app. If ''False'', iOS Version 12.0 is not the minimum version. Default value is False. Exactly one of the minimum operating system boolean values will be TRUE.')]
    [System.Nullable[System.Boolean]] $V12_0

    [DscProperty()]
    [System.ComponentModel.Description('Indicates the minimum iOS version support required for the managed device. When ''True'', iOS with OS Version 13.0 or later is required to install the app. If ''False'', iOS Version 13.0 is not the minimum version. Default value is False. Exactly one of the minimum operating system boolean values will be TRUE.')]
    [System.Nullable[System.Boolean]] $V13_0

    [DscProperty()]
    [System.ComponentModel.Description('Indicates the minimum iOS version support required for the managed device. When ''True'', iOS with OS Version 14.0 or later is required to install the app. If ''False'', iOS Version 14.0 is not the minimum version. Default value is False. Exactly one of the minimum operating system boolean values will be TRUE.')]
    [System.Nullable[System.Boolean]] $V14_0

    [DscProperty()]
    [System.ComponentModel.Description('Indicates the minimum iOS version support required for the managed device. When ''True'', iOS with OS Version 15.0 or later is required to install the app. If ''False'', iOS Version 15.0 is not the minimum version. Default value is False. Exactly one of the minimum operating system boolean values will be TRUE.')]
    [System.Nullable[System.Boolean]] $V15_0

    [DscProperty()]
    [System.ComponentModel.Description('Indicates the minimum iOS version support required for the managed device. When ''True'', iOS with OS Version 16.0 or later is required to install the app. If ''False'', iOS Version 16.0 is not the minimum version. Default value is False. Exactly one of the minimum operating system boolean values will be TRUE.')]
    [System.Nullable[System.Boolean]] $V16_0

    [DscProperty()]
    [System.ComponentModel.Description('Indicates the minimum iOS version support required for the managed device. When ''True'', iOS with OS Version 17.0 or later is required to install the app. If ''False'', iOS Version 17.0 is not the minimum version. Default value is False. Exactly one of the minimum operating system boolean values will be TRUE.')]
    [System.Nullable[System.Boolean]] $V17_0

    [DscProperty()]
    [System.ComponentModel.Description('Indicates the minimum iOS version support required for the managed device. When ''True'', iOS with OS Version 18.0 or later is required to install the app. If ''False'', iOS Version 18.0 is not the minimum version. Default value is False. Exactly one of the minimum operating system boolean values will be TRUE.')]
    [System.Nullable[System.Boolean]] $V18_0

    [DscProperty()]
    [System.ComponentModel.Description('Indicates the minimum iOS version support required for the managed device. When ''True'', iOS with OS Version 8.0 or later is required to install the app. If ''False'', iOS Version 8.0  is not the minimum version. Default value is False. Exactly one of the minimum operating system boolean values will be TRUE.')]
    [System.Nullable[System.Boolean]] $V8_0

    [DscProperty()]
    [System.ComponentModel.Description('Indicates the minimum iOS version support required for the managed device. When ''True'', iOS with OS Version 9.0 or later is required to install the app. If ''False'', iOS Version 9.0 is not the minimum version. Default value is False. Exactly one of the minimum operating system boolean values will be TRUE.')]
    [System.Nullable[System.Boolean]] $V9_0
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

class MSFT_DeviceManagementLobAppiOSAssignment : MSFT_DeviceManagementMobileAppAssignment
{
    [DscProperty()]
    [System.ComponentModel.Description('The settings of the assignment.')]
    [MSFT_DeviceManagementLobAppiOSAssignmentSettings] $assignmentSettings
}

class MSFT_DeviceManagementMobileAppAssignmentSettings
{
    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('The odata type of the assignment type.')]
    [ValidateSet('#microsoft.graph.androidManagedStoreAppAssignmentSettings', '#microsoft.graph.iosStoreAppAssignmentSettings', '#microsoft.graph.iosLobAppAssignmentSettings', '#microsoft.graph.macOsLobAppAssignmentSettings', '#microsoft.graph.win32CatalogAppAssignmentSettings', '#microsoft.graph.win32LobAppAssignmentSettings', '#microsoft.graph.winGetAppAssignmentSettings', '#microsoft.graph.windowsAutoUpdateCatalogAppAssignmentSettings', '#microsoft.graph.windowsUniversalAppXAppAssignmentSettings')]
    [System.String] $odataType
}

class MSFT_DeviceManagementLobAppiOSAssignmentSettings : MSFT_DeviceManagementMobileAppAssignmentSettings
{
    [DscProperty()]
    [System.ComponentModel.Description('Display name or Id of the VPN configuration profile associated with this policy.')]
    [System.String] $vpnConfigurationId

    [DscProperty()]
    [System.ComponentModel.Description('When TRUE, indicates that the app should be uninstalled when the device is removed from Intune. When FALSE, indicates that the app will not be uninstalled when the device is removed from Intune. By default, property is set to null which internally is treated as TRUE.')]
    [System.Nullable[System.Boolean]] $uninstallOnDeviceRemoval

    [DscProperty()]
    [System.ComponentModel.Description('When TRUE, indicates that the app can be uninstalled by the user. When FALSE, indicates that the app cannot be uninstalled by the user. By default, this property is set to null which internally is treated as TRUE.')]
    [System.Nullable[System.Boolean]] $isRemovable

    [DscProperty()]
    [System.ComponentModel.Description('When TRUE, indicates that the app should not be backed up to iCloud. When FALSE, indicates that the app may be backed up to iCloud. By default, this property is set to null which internally is treated as FALSE.')]
    [System.Nullable[System.Boolean]] $preventManagedAppBackup
}
