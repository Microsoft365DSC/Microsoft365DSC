using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class IntuneDeviceFeaturesConfigurationPolicyIOS : M365DSCResourceBase
{
    [DscProperty()]
    [System.ComponentModel.Description('Id of the Intune policy.')]
    [System.String] $Id

    [DscProperty(Key)]
    [System.ComponentModel.Description('Display name of the Intune policy.')]
    [System.String] $DisplayName

    [DscProperty()]
    [System.ComponentModel.Description('Description of the Intune policy.')]
    [System.String] $Description

    [DscProperty()]
    [System.ComponentModel.Description('Represents the assignment to the Intune policy.')]
    [MSFT_DeviceManagementConfigurationPolicyAssignments[]] $Assignments

    [DscProperty()]
    [System.ComponentModel.Description('Present ensures the policy exists, absent ensures it is removed.')]
    [ValidateSet('Present', 'Absent')]
    [System.String] $Ensure

    [DscProperty()]
    [System.ComponentModel.Description('Credentials of the Intune Admin')]
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

    [DscProperty()]
    [System.ComponentModel.Description('List of Scope Tags for this Entity instance. Inherited from deviceConfiguration.')]
    [System.String[]] $RoleScopeTagIds

    [DscProperty()]
    [System.ComponentModel.Description('The OS edition applicability for this Policy. Inherited from deviceConfiguration.')]
    [MSFT_deviceManagementApplicabilityRuleOsEdition[]] $DeviceManagementApplicabilityRuleOsEdition

    [DscProperty()]
    [System.ComponentModel.Description('The OS version applicability rule for this Policy. Inherited from deviceConfiguration.')]
    [MSFT_deviceManagementApplicabilityRuleOsVersion[]] $DeviceManagementApplicabilityRuleOsVersion

    [DscProperty()]
    [System.ComponentModel.Description('The device mode applicability rule for this Policy. Inherited from deviceConfiguration.')]
    [MSFT_deviceManagementApplicabilityRuleDeviceMode[]] $DeviceManagementApplicabilityRuleDeviceMode

    [DscProperty()]
    [System.ComponentModel.Description('An array of AirPrint printers that should always be shown.')]
    [MSFT_airPrintDestination[]] $AirPrintDestinations

    [DscProperty()]
    [System.ComponentModel.Description('Asset tag information for the device, displayed on the login window and lock screen.')]
    [System.String] $AssetTagTemplate

    [DscProperty()]
    [System.ComponentModel.Description('Gets or sets iOS Web Content Filter settings, supervised mode only.')]
    [MSFT_iosWebContentFilterSpecificWebsitesAccess[]] $ContentFilterSettings

    [DscProperty()]
    [System.ComponentModel.Description('A footnote displayed on the login window and lock screen. Available in iOS 9.3.1 and later.')]
    [System.String] $LockScreenFootnote

    [DscProperty()]
    [System.ComponentModel.Description('A list of app and folders to appear on the Home Screen Dock. This collection can contain a maximum of 500 elements.')]
    [MSFT_iosHomeScreenApp[]] $HomeScreenDockIcons

    [DscProperty()]
    [System.ComponentModel.Description('A list of pages on the Home Screen. This collection can contain a maximum of 500 elements.')]
    [MSFT_iosHomeScreenItem[]] $HomeScreenPages

    [DscProperty()]
    [System.ComponentModel.Description('Gets or sets the number of columns to render when configuring iOS home screen layout settings. If this value is configured, homeScreenGridHeight must be configured as well.')]
    [System.Nullable[System.UInt32]] $HomeScreenGridWidth

    [DscProperty()]
    [System.ComponentModel.Description('Gets or sets the number of rows to render when configuring iOS home screen layout settings. If this value is configured, homeScreenGridWidth must be configured as well.')]
    [System.Nullable[System.UInt32]] $HomeScreenGridHeight

    [DscProperty()]
    [System.ComponentModel.Description('Notification settings for each bundle id. Applicable to devices in supervised mode only (iOS 9.3 and later).')]
    [MSFT_iosNotificationSettings[]] $NotificationSettings

    [DscProperty()]
    [System.ComponentModel.Description('The Kerberos login settings that enable apps on receiving devices to authenticate smoothly.')]
    [MSFT_iosSingleSignOnSettings[]] $SingleSignOnSettings

    [DscProperty()]
    [System.ComponentModel.Description('A wallpaper display location specifier. Possible values are: notConfigured, lockScreen, homeScreen, lockAndHomeScreens.')]
    [ValidateSet('notConfigured', 'lockScreen', 'homeScreen', 'lockAndHomeScreens')]
    [System.String] $WallpaperDisplayLocation

    [DscProperty()]
    [System.ComponentModel.Description('A wallpaper image must be in either PNG or JPEG format. It requires a supervised device with iOS 8 or later version.')]
    [MSFT_mimeContent[]] $WallpaperImage

    [DscProperty()]
    [System.ComponentModel.Description('Gets or sets a single sign-on extension profile.')]
    [MSFT_iosSingleSignOnExtension[]] $IosSingleSignOnExtension

    # Export-only. Not part of the resource schema.
    [System.String] $Filter

    [IntuneDeviceFeaturesConfigurationPolicyIOS] Get()
    {
        $getValue = $null
        if ($this.RequiresPowerShellCore())
        {
            $remote = [IntuneDeviceFeaturesConfigurationPolicyIOS]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of the Intune Device Features Configuration Policy for iOS with Id {$($this.Id)} and DisplayName {$($this.DisplayName)}"

        try
        {
            if (-not $this.ExportedInstance)
            {
                $null = $this.Connect('MicrosoftGraph')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullResult = $this.GetBoundParameters()
                $nullResult.Ensure = 'Absent'

                if (-not [string]::IsNullOrWhiteSpace($this.Id))
                {
                    $getValue = Get-MgBetaDeviceManagementDeviceConfiguration -All -Filter "Id eq '$($this.Id)'" -ErrorAction SilentlyContinue
                }

                #region resource generator code
                if ($null -eq $getValue)
                {
                    $getValue = Get-MgBetaDeviceManagementDeviceConfiguration -All -Filter "DisplayName eq '$($this.Displayname -replace "'", "''")' and isof('microsoft.graph.iosDeviceFeaturesConfiguration')" -ErrorAction SilentlyContinue
                }
                #endregion

                if ($null -eq $getValue)
                {
                    Write-Verbose -Message "No Intune Device Features Policy for iOS with Id {$($this.Id)} was found"
                    return $this.AsResult($nullResult)
                }

                $resolvedId = $getValue.Id

                Write-Verbose -Message "An Intune Device Features Policy for iOS with id {$($resolvedId)} and DisplayName {$($this.DisplayName)} was found"
            }
            else
            {
                $getValue = $this.ExportedInstance
            }

            #value could be bool, string or int - export as a string and handle later
            $complexIosSingleSignonExtension = $this.ConvertComplexObjectToHashtableArrayExportDataType($getValue.iosSingleSignOnExtension)
            foreach ($configuration in $complexIosSingleSignonExtension.configurations)
            {
                $configuration.value = [string]$configuration.value
            }

            foreach ($dockPage in $getValue.homeScreenDockIcons.pages)
            {
                # Remove null displayName property
                $dockPage.Remove('displayName') | Out-Null
            }

            foreach ($page in $getValue.homeScreenPages)
            {
                # Remove null displayName property
                $page.Remove('displayName') | Out-Null
                foreach ($iconPage in $page.icons.pages)
                {
                    $iconPage.Remove('displayName') | Out-Null
                }
            }

            $results = @{
                #region resource generator code
                Id                       = $getValue.Id
                Description              = $getValue.Description
                DisplayName              = $getValue.DisplayName
                Ensure                   = 'Present'
                Credential               = $this.Credential
                ApplicationId            = $this.ApplicationId
                TenantId                 = $this.TenantId
                ApplicationSecret        = $this.ApplicationSecret
                CertificateThumbprint    = $this.CertificateThumbprint
                CertificatePath          = $this.CertificatePath
                CertificatePassword      = $this.CertificatePassword
                ManagedIdentity          = $this.ManagedIdentity
                AccessTokens             = $this.AccessTokens
                AirPrintDestinations     = $this.ConvertComplexObjectToHashtableArray($getValue.airPrintDestinations)
                AssetTagTemplate         = $getValue.assetTagTemplate
                ContentFilterSettings    = $this.ConvertComplexObjectToHashtableArrayExportDataType($getValue.contentFilterSettings)
                LockScreenFootnote       = $getValue.lockScreenFootnote
                HomeScreenDockIcons      = $this.ConvertComplexObjectToHashtableArray($getValue.homeScreenDockIcons)
                HomeScreenPages          = $this.ConvertComplexObjectToHashtableArray($getValue.homeScreenPages)
                HomeScreenGridWidth      = $getValue.homeScreenGridWidth
                HomeScreenGridHeight     = $getValue.homeScreenGridHeight
                NotificationSettings     = $this.ConvertComplexObjectToHashtableArray($getValue.notificationSettings)
                SingleSignOnSettings     = $this.ConvertComplexObjectToHashtableArray($getValue.singleSignOnSettings)
                WallpaperDisplayLocation = $getValue.wallpaperDisplayLocation
                WallpaperImage           = $this.ConvertComplexObjectToHashtableArray($getValue.wallpaperImage)
                IosSingleSignOnExtension = $complexIosSingleSignonExtension
            }

            $assignmentsValues = Get-M365DSCIntuneExpandedAssignments -Instance $getValue
            if ($null -eq $assignmentsValues)
            {
                $assignmentsValues = Get-MgBetaDeviceManagementDeviceConfigurationAssignment -DeviceConfigurationId $Results.Id
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

        Write-Verbose -Message "Setting configuration of the Intune Device Features Configuration Policy for iOS with Id {$($this.Id)} and DisplayName {$($this.DisplayName)}"

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
            Write-Verbose -Message "Creating an Intune Device Features Configuration Policy for iOS with DisplayName {$($this.DisplayName)}"
            $createParameters = $boundParameters
            $createParameters.Remove('Assignments') | Out-Null
            $createParameters.Remove('Id') | Out-Null

            #create params need some processing to get payload in correct format
            $createParameters.Add('@odata.type', '#microsoft.graph.iosDeviceFeaturesConfiguration') #add odata type or payload will be rejected
            if ($createParameters.WallpaperImage)
            {
                $createParameters['WallpaperImage'] = $createParameters.WallpaperImage[0] #needs the hashtable not embedded in array
                $createParameters.WallpaperImage['value'] = [System.Convert]::FromBase64String($createParameters.WallpaperImage['value'])
            }
            if ($createParameters.HomeScreenPages)
            {
                foreach ($homeScreenPage in $createParameters.HomeScreenPages)
                {
                    foreach ($icon in $homeScreenPage.icons)
                    {
                        if ($icon.ContainsKey('pages'))
                        {
                            $icon.Add('@odata.type', '#microsoft.graph.iosHomeScreenFolder')
                            continue
                        }
                        $icon.Add('@odata.type', '#microsoft.graph.iosHomeScreenApp')
                    }
                }
            }
            if ($createParameters.HomeScreenDockIcons)
            {
                foreach ($homeScreenDockIcon in $createParameters.HomeScreenDockIcons)
                {
                    if ($homeScreenDockIcon.ContainsKey('pages'))
                    {
                        $homeScreenDockIcon.Add('@odata.type', '#microsoft.graph.iosHomeScreenFolder')
                        continue
                    }
                    $homeScreenDockIcon.Add('@odata.type', '#microsoft.graph.iosHomeScreenApp')
                }
            }
            if ($createParameters.ContentFilterSettings)
            {
                $this.ConvertDataTypeFormat($createParameters.ContentFilterSettings)
                $createParameters['ContentFilterSettings'] = $createParameters.ContentFilterSettings[0] #needs the hashtable not embedded in array
            }
            if ($createParameters.SingleSignOnSettings)
            {
                $createParameters['SingleSignOnSettings'] = $createParameters.SingleSignOnSettings[0] #needs the hashtable not embedded in array
            }
            if ($createParameters.IosSingleSignOnExtension)
            {
                $this.ConvertDataTypeFormat($createParameters.IosSingleSignOnExtension)
                if ($null -ne $createParameters.IosSingleSignOnExtension.configurations)
                {
                    $this.ConvertStringToBooleans($createParameters.IosSingleSignOnExtension.configurations)
                }
                $createParameters['iosSingleSignOnExtension'] = $createParameters.IosSingleSignOnExtension[0] #needs the hashtable not embedded in array
            }
            #finished processing create parameters

            $this.RemoveForeignSubtypeProperties($createParameters, @{
                    '#microsoft.graph.iosHomeScreenFolder' = @('displayName', 'pages')
                    '#microsoft.graph.iosHomeScreenApp'    = @('bundleID', 'displayName', 'isWebClip')
                })

            #region resource generator code
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
            Write-Verbose -Message "Updating {$($this.DisplayName)}"

            $updateParameters = $boundParameters
            $updateParameters.Remove('Assignments') | Out-Null
            $updateParameters.Remove('Id') | Out-Null

            #update params need some processing to get payload in correct format
            $updateParameters.Add('@odata.type', '#microsoft.graph.iosDeviceFeaturesConfiguration') #add odata type or payload will be rejected
            if ($updateParameters.WallpaperImage)
            {
                $updateParameters['WallpaperImage'] = $updateParameters.WallpaperImage[0] #needs the hashtable not embedded in array
                $updateParameters.WallpaperImage['value'] = [System.Convert]::FromBase64String($updateParameters.WallpaperImage['value'])
            }
            if ($updateParameters.HomeScreenPages)
            {
                foreach ($homeScreenPage in $updateParameters.HomeScreenPages)
                {
                    foreach ($icon in $homeScreenPage.icons)
                    {
                        if ($icon.ContainsKey('pages'))
                        {
                            $icon.Add('@odata.type', '#microsoft.graph.iosHomeScreenFolder')
                            continue
                        }
                        $icon.Add('@odata.type', '#microsoft.graph.iosHomeScreenApp')
                    }
                }
            }
            if ($updateParameters.HomeScreenDockIcons)
            {
                foreach ($homeScreenDockIcon in $updateParameters.HomeScreenDockIcons)
                {
                    if ($homeScreenDockIcon.ContainsKey('pages'))
                    {
                        $homeScreenDockIcon.Add('@odata.type', '#microsoft.graph.iosHomeScreenFolder')
                        continue
                    }
                    $homeScreenDockIcon.Add('@odata.type', '#microsoft.graph.iosHomeScreenApp')
                }
            }
            if ($updateParameters.ContentFilterSettings)
            {
                $this.ConvertDataTypeFormat($updateParameters.ContentFilterSettings)
                $updateParameters['ContentFilterSettings'] = $updateParameters.ContentFilterSettings[0] #needs the hashtable not embedded in array
            }
            if ($updateParameters.SingleSignOnSettings)
            {
                $updateParameters['SingleSignOnSettings'] = $updateParameters.SingleSignOnSettings[0] #needs the hashtable not embedded in array
            }
            if ($updateParameters.IosSingleSignOnExtension)
            {
                $this.ConvertDataTypeFormat($updateParameters.IosSingleSignOnExtension)
                if ($null -ne $updateParameters.IosSingleSignOnExtension.configurations)
                {
                    $this.ConvertStringToBooleans($updateParameters.IosSingleSignOnExtension.configurations)
                }
                $updateParameters['IosSingleSignOnExtension'] = $updateParameters.IosSingleSignOnExtension[0] #needs the hashtable not embedded in array
            }
            #finished processing update parameters

            $this.RemoveForeignSubtypeProperties($updateParameters, @{
                    '#microsoft.graph.iosHomeScreenFolder' = @('displayName', 'pages')
                    '#microsoft.graph.iosHomeScreenApp'    = @('bundleID', 'displayName', 'isWebClip')
                })

            #region resource generator code
            Update-MgBetaDeviceManagementDeviceConfiguration -BodyParameter $updateParameters `
                -DeviceConfigurationId $currentInstance.Id
            $assignmentsHash = ConvertTo-IntunePolicyAssignment -IncludeDeviceFilter:$true -Assignments $this.Assignments
            Update-DeviceConfigurationPolicyAssignment -DeviceConfigurationPolicyId $currentInstance.id `
                -Targets $assignmentsHash `
                -Repository 'deviceManagement/deviceConfigurations'
            #endregion
        }
        elseif ($this.Ensure -eq 'Absent' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Removing {$($this.DisplayName)}"
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
                -ODataType 'microsoft.graph.iosDeviceFeaturesConfiguration' `
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

                Write-M365DSCHost -Message "    |---[$i/$($getValue.Count)] $($config.DisplayName)" -DeferWrite
                $params = @{
                    Id                    = $config.id
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

                if ($null -ne $Results.airPrintDestinations)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.AirPrintDestinations `
                        -CIMInstanceName 'MSFT_airPrintDestination'
                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.AirPrintDestinations = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('AirPrintDestinations') | Out-Null
                    }
                }

                if ($null -ne $Results.ContentFilterSettings)
                {
                    $complexMapping = @(
                        @{
                            Name            = 'websiteList'
                            CimInstanceName = 'iosWebContentFilterBase'
                            IsRequired      = $false
                        }
                        @{
                            Name            = 'specificWebsitesOnly'
                            CimInstanceName = 'iosWebContentFilterBase'
                            IsRequired      = $false
                        }
                    )
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.ContentFilterSettings `
                        -CIMInstanceName 'MSFT_iosWebContentFilterSpecificWebsitesAccess' `
                        -ComplexTypeMapping $complexMapping
                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.ContentFilterSettings = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('contentFilterSettings') | Out-Null
                    }
                }

                if ($null -ne $Results.HomeScreenDockIcons)
                {
                    $complexMapping = @(
                        @{
                            Name            = 'pages'
                            CimInstanceName = 'MSFT_iosHomeScreenFolderPage'
                            IsRequired      = $false
                        },
                        @{
                            Name            = 'apps'
                            CimInstanceName = 'iosHomeScreenApp'
                            IsRequired      = $false
                        }
                    )
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.HomeScreenDockIcons `
                        -CIMInstanceName 'MSFT_iosHomeScreenApp' `
                        -ComplexTypeMapping $complexMapping
                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.HomeScreenDockIcons = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('HomeScreenDockIcons') | Out-Null
                    }
                }

                if ($null -ne $Results.HomeScreenPages)
                {
                    $complexMapping = @(
                        @{
                            Name            = 'icons'
                            CimInstanceName = 'iosHomeScreenApp'
                            IsRequired      = $false
                        },
                        @{
                            Name            = 'pages'
                            CimInstanceName = 'MSFT_iosHomeScreenFolderPage'
                            IsRequired      = $false
                        },
                        @{
                            Name            = 'apps'
                            CimInstanceName = 'iosHomeScreenApp'
                            IsRequired      = $false
                        }
                    )
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.HomeScreenPages `
                        -CIMInstanceName 'MSFT_iosHomeScreenItem' `
                        -ComplexTypeMapping $complexMapping
                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.HomeScreenPages = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('HomeScreenPages') | Out-Null
                    }
                }

                if ($null -ne $Results.WallpaperImage)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.WallpaperImage `
                        -CIMInstanceName 'MSFT_mimeContent'
                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.WallpaperImage = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('WallpaperImage') | Out-Null
                    }
                }

                if ($null -ne $Results.IosSingleSignOnExtension)
                {
                    $complexMapping = @(
                        @{
                            Name            = 'configurations'
                            CimInstanceName = 'keyTypedValuePair'
                            IsRequired      = $false
                        }
                    )
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.IosSingleSignOnExtension `
                        -CIMInstanceName 'MSFT_iosSingleSignOnExtension' `
                        -ComplexTypeMapping $complexMapping
                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.IosSingleSignOnExtension = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('IosSingleSignOnExtension') | Out-Null
                    }
                }

                if ($null -ne $Results.NotificationSettings)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.NotificationSettings `
                        -CIMInstanceName 'MSFT_iosNotificationSettings'
                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.NotificationSettings = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('NotificationSettings') | Out-Null
                    }
                }

                if ($null -ne $Results.SingleSignOnSettings)
                {
                    $complexMapping = @(
                        @{
                            Name            = 'allowedAppsList'
                            CimInstanceName = 'appListItem'
                            IsRequired      = $false
                        }
                    )
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.SingleSignOnSettings `
                        -CIMInstanceName 'MSFT_iosSingleSignOnSettings' `
                        -ComplexTypeMapping $complexMapping
                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.SingleSignOnSettings = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('SingleSignOnSettings') | Out-Null
                    }
                }

                $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                    -ConnectionMode $ConnectionMode `
                    -ModulePath $this.GetModulePath() `
                    -Results $Results `
                    -Credential $this.Credential `
                    -NoEscape @('Assignments', 'AirPrintDestinations', 'ContentFilterSettings', 'HomeScreenDockIcons', 'HomeScreenPages', 'WallpaperImage', 'IosSingleSignOnExtension', 'NotificationSettings', 'SingleSignOnSettings') `
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

    hidden [System.Object[]] ConvertComplexObjectToHashtableArray([System.Object] $InputObject)
    {
        $resultArray = @()

        foreach ($item in $InputObject)
        {
            $hashtable = [ordered]@{}

            foreach ($key in $item.Keys)
            {
                $keyValue = $item.$key
                if ($key -ne '@odata.type')
                {
                    if ($keyValue -is [array])
                    {
                        $elementTypes = $keyValue | ForEach-Object { $_.GetType().Name }
                        if ($elementTypes -contains 'Hashtable') #another embedded complex type, not a string array
                        {
                            $keyValue = $this.ConvertComplexObjectToHashtableArray($keyValue)
                        }
                    }
                    $hashtable.Add($key, $keyValue)
                }
            }

            # Add the hash table to the result array only if it contains non-null values
            if ($hashtable.Values.Where({ $null -ne $_ }).Count -gt 0)
            {
                $resultArray += $hashtable
            }
        }

        return $resultArray
    }

    hidden [System.Object[]] ConvertComplexObjectToHashtableArrayExportDataType([System.Object] $InputObject)
    {
        $resultArray = @()

        foreach ($item in $InputObject)
        {
            $hashtable = [ordered]@{}

            foreach ($key in $item.Keys)
            {
                $keyValue = $item.$key
                if ($key -ne '@odata.type')
                {
                    if ($keyValue -is [array])
                    {
                        $elementTypes = $keyValue | ForEach-Object { $_.GetType().Name }
                        if ($elementTypes -contains 'Hashtable') #another embedded complex type, not a string array
                        {
                            $keyValue = $this.ConvertComplexObjectToHashtableArrayExportDataType($keyValue)
                        }
                    }
                    $hashtable.Add($key, $keyValue)
                }
                else
                {
                    $hashtable.Add('dataType', $item.$key)
                }
            }

            # Add the hash table to the result array only if it contains non-null values
            if ($hashtable.Values.Where({ $null -ne $_ }).Count -gt 0)
            {
                $resultArray += $hashtable
            }
        }

        return $resultArray
    }

    hidden [System.Object] ConvertDataTypeFormat([System.Object] $InputObject)
    {
        foreach ($item in $InputObject)
        {
            $keysToModify = @()
            $keysToRecurse = @()
            foreach ($key in $item.Keys)
            {
                if ($key -eq 'dataType')
                {
                    $keysToModify += $key
                }
                if ($item.$key -is [array] -and ($item.$key | Where-Object { $_ -is [hashtable] }))
                {
                    $keysToRecurse += $key
                }
            }
            foreach ($key in $keysToModify)
            {
                $item['@odata.type'] = $item.$key
                $item.Remove($key)
            }
            foreach ($key in $keysToRecurse)
            {
                $item[$key] = $this.ConvertDataTypeFormat($item.$key)
            }
        }
        return $InputObject
    }

    hidden [System.Object[]] ConvertStringToBooleans([System.Object[]] $Configurations)
    {
        foreach ($config in $Configurations)
        {
            if ($config.ContainsKey('value'))
            {
                switch ($config.value)
                {
                    'True'
                    {
                        $config.value = $true
                    }
                    'False'
                    {
                        $config.value = $false
                    }
                }
            }
        }
        return $Configurations
    }

    hidden [IntuneDeviceFeaturesConfigurationPolicyIOS] AsResult([System.Object] $Values)
    {
        if ($Values -is [IntuneDeviceFeaturesConfigurationPolicyIOS])
        {
            return $Values
        }

        $result = [IntuneDeviceFeaturesConfigurationPolicyIOS]::new()
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

class MSFT_deviceManagementApplicabilityRuleOsEdition
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

class MSFT_deviceManagementApplicabilityRuleOsVersion
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

class MSFT_deviceManagementApplicabilityRuleDeviceMode
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

class MSFT_airPrintDestination
{
    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('The IP Address of the AirPrint destination.')]
    [System.String] $ipAddress

    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('The Resource Path associated with the printer. This corresponds to the rp parameter of the _ipps.tcp Bonjour record. For example: printers/Canon_MG5300_series, printers/Xerox_Phaser_7600, ipp/print, Epson_IPP_Printer.')]
    [System.String] $resourcePath

    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('The listening port of the AirPrint destination. If this key is not specified, AirPrint will use the default port. Available in iOS 11.0 and later.')]
    [System.Nullable[System.UInt32]] $port

    [DscProperty()]
    [System.ComponentModel.Description('If true, AirPrint connections are secured by Transport Layer Security (TLS). Default is false. Available in iOS 11.0 and later.')]
    [System.Nullable[System.Boolean]] $forceTls
}

class MSFT_iosWebContentFilterSpecificWebsitesAccess
{
    [DscProperty()]
    [System.ComponentModel.Description('The type of data.')]
    [System.String] $dataType

    [DscProperty()]
    [System.ComponentModel.Description('specificWebsitesOnly, embedded instance of iosWebContentFilterBase.')]
    [MSFT_iosWebContentFilterBase[]] $specificWebsitesOnly

    [DscProperty()]
    [System.ComponentModel.Description('websiteList, embedded instance of iosWebContentFilterBase.')]
    [MSFT_iosWebContentFilterBase[]] $websiteList

    [DscProperty()]
    [System.ComponentModel.Description('allowedUrls.')]
    [System.String[]] $allowedUrls

    [DscProperty()]
    [System.ComponentModel.Description('blockedUrls.')]
    [System.String[]] $blockedUrls
}

class MSFT_iosHomeScreenApp
{
    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('Name of the app. Inherited from iosHomeScreenItem.')]
    [System.String] $displayName

    [DscProperty()]
    [System.ComponentModel.Description('BundleID of the app if isWebClip is false or the URL of a web clip if isWebClip is true.')]
    [System.String] $bundleID

    [DscProperty()]
    [System.ComponentModel.Description('Is it a website URL or an app')]
    [System.Nullable[System.Boolean]] $isWebClip

    [DscProperty()]
    [System.ComponentModel.Description('Pages of the folder.')]
    [MSFT_iosHomeScreenFolderPage[]] $pages
}

class MSFT_iosHomeScreenItem
{
    [DscProperty()]
    [System.ComponentModel.Description('A list of apps, folders, and web clips to appear on a page. This collection can contain a maximum of 500 elements.')]
    [MSFT_iosHomeScreenApp[]] $icons
}

class MSFT_iosNotificationSettings
{
    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('Bundle id of the app to which to apply these notification settings.')]
    [System.String] $bundleID

    [DscProperty()]
    [System.ComponentModel.Description('Application name to be associated with the BundleID.')]
    [System.String] $appName

    [DscProperty()]
    [System.ComponentModel.Description('Publisher to be associated with the BundleID.')]
    [System.String] $publisher

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether notifications are allowed for this app.')]
    [System.Nullable[System.Boolean]] $enabled

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether notifications can be shown in the notification center.')]
    [System.Nullable[System.Boolean]] $showInNotificationCenter

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether notifications can be shown on the lock screen.')]
    [System.Nullable[System.Boolean]] $showOnLockScreen

    [DscProperty()]
    [System.ComponentModel.Description('Indicates the type of alert for notifications for this app. Possible values are: deviceDefault, banner, modal, none.')]
    [ValidateSet('deviceDefault', 'banner', 'modal', 'none')]
    [System.String] $alertType

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether badges are allowed for this app.')]
    [System.Nullable[System.Boolean]] $badgesEnabled

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether sounds are allowed for this app.')]
    [System.Nullable[System.Boolean]] $soundsEnabled

    [DscProperty()]
    [System.ComponentModel.Description('Overrides the notification preview policy set by the user on an iOS device. Possible values are: notConfigured, alwaysShow, hideWhenLocked, neverShow.')]
    [ValidateSet('notConfigured', 'alwaysShow', 'hideWhenLocked', 'neverShow')]
    [System.String] $previewVisibility
}

class MSFT_iosSingleSignOnSettings
{
    [DscProperty()]
    [System.ComponentModel.Description('List of app identifiers that are allowed to use this login. If this field is omitted, the login applies to all applications on the device. This collection can contain a maximum of 500 elements.')]
    [MSFT_appListItem[]] $allowedAppsList

    [DscProperty()]
    [System.ComponentModel.Description('List of HTTP URLs that must be matched in order to use this login. With iOS 9.0 or later, wildcard characters may be used.')]
    [System.String[]] $allowedUrls

    [DscProperty()]
    [System.ComponentModel.Description('The display name of login settings shown on the receiving device.')]
    [System.String] $displayName

    [DscProperty()]
    [System.ComponentModel.Description('A Kerberos principal name. If not provided, the user is prompted for one during profile installation.')]
    [System.String] $kerberosPrincipalName

    [DscProperty()]
    [System.ComponentModel.Description('A Kerberos realm name. Case sensitive.')]
    [System.String] $kerberosRealm
}

class MSFT_mimeContent
{
    [DscProperty()]
    [System.ComponentModel.Description('Indicates the content mime type.')]
    [System.String] $type

    [DscProperty()]
    [System.ComponentModel.Description('The byte array that contains the actual content.')]
    [System.String[]] $value
}

class MSFT_iosSingleSignOnExtension
{
    [DscProperty()]
    [System.ComponentModel.Description('The type of data.')]
    [System.String] $dataType

    [DscProperty()]
    [System.ComponentModel.Description('The case-sensitive realm name for this profile.')]
    [System.String] $Realm

    [DscProperty()]
    [System.ComponentModel.Description('A list of hosts or domain names for which the app extension performs SSO.')]
    [System.String[]] $Domains

    [DscProperty()]
    [System.ComponentModel.Description('Enables or disables Keychain usage.')]
    [System.Nullable[System.Boolean]] $BlockAutomaticLogin

    [DscProperty()]
    [System.ComponentModel.Description('The Generic Security Services name of the Kerberos cache to use for this profile.')]
    [System.String] $CacheName

    [DscProperty()]
    [System.ComponentModel.Description('A list of app Bundle IDs allowed to access the Kerberos Ticket Granting Ticket.')]
    [System.String[]] $CredentialBundleIdAccessControlList

    [DscProperty()]
    [System.ComponentModel.Description('A list of realms for custom domain-realm mapping. Realms are case sensitive.')]
    [System.String[]] $DomainRealms

    [DscProperty()]
    [System.ComponentModel.Description('When true, this profile''s realm will be selected as the default. Necessary if multiple Kerberos-type profiles are configured.')]
    [System.Nullable[System.Boolean]] $IsDefaultRealm

    [DscProperty()]
    [System.ComponentModel.Description('Enables or disables password changes.')]
    [System.Nullable[System.Boolean]] $PasswordBlockModification

    [DscProperty()]
    [System.ComponentModel.Description('Overrides the default password expiration in days. For most domains, this value is calculated automatically.')]
    [System.Nullable[System.UInt32]] $PasswordExpirationDays

    [DscProperty()]
    [System.ComponentModel.Description('The number of days until the user is notified that their password will expire (default is 15).')]
    [System.Nullable[System.UInt32]] $PasswordExpirationNotificationDays

    [DscProperty()]
    [System.ComponentModel.Description('The principal user name to use for this profile. The realm name does not need to be included.')]
    [System.String] $UserPrincipalName

    [DscProperty()]
    [System.ComponentModel.Description('Enables or disables whether passwords must meet Active Directory''s complexity requirements.')]
    [System.Nullable[System.Boolean]] $PasswordRequireActiveDirectoryComplexity

    [DscProperty()]
    [System.ComponentModel.Description('The number of previous passwords to block.')]
    [System.Nullable[System.UInt32]] $PasswordPreviousPasswordBlockCount

    [DscProperty()]
    [System.ComponentModel.Description('The minimum length of a password.')]
    [System.Nullable[System.UInt32]] $PasswordMinimumLength

    [DscProperty()]
    [System.ComponentModel.Description('The minimum number of days until a user can change their password again.')]
    [System.Nullable[System.UInt32]] $PasswordMinimumAgeDays

    [DscProperty()]
    [System.ComponentModel.Description('A description of the password complexity requirements.')]
    [System.String] $PasswordRequirementsDescription

    [DscProperty()]
    [System.ComponentModel.Description('Whether to require authentication via Touch ID, Face ID, or a passcode to access the keychain entry.')]
    [System.Nullable[System.Boolean]] $RequireUserPresence

    [DscProperty()]
    [System.ComponentModel.Description('The Active Directory site.')]
    [System.String] $ActiveDirectorySiteCode

    [DscProperty()]
    [System.ComponentModel.Description('Enables or disables password syncing. This won''t affect users logged in with a mobile account on macOS.')]
    [System.Nullable[System.Boolean]] $PasswordEnableLocalSync

    [DscProperty()]
    [System.ComponentModel.Description('Enables or disables whether the Kerberos extension can automatically determine its site name.')]
    [System.Nullable[System.Boolean]] $BlockActiveDirectorySiteAutoDiscovery

    [DscProperty()]
    [System.ComponentModel.Description('The URL that the user will be sent to when they initiate a password change.')]
    [System.String] $PasswordChangeUrl

    [DscProperty()]
    [System.ComponentModel.Description('Text displayed to the user at the Kerberos sign-in window. Available for devices running iOS and iPadOS versions 14 and later.')]
    [System.String] $SignInHelpText

    [DscProperty()]
    [System.ComponentModel.Description('When set to True, the Kerberos extension allows managed apps, and any apps entered with the app bundle ID to access the credential. When set to False, the Kerberos extension allows all apps to access the credential. Available for devices running iOS and iPadOS versions 14 and later.')]
    [System.Nullable[System.Boolean]] $ManagedAppsInBundleIdACLIncluded

    [DscProperty()]
    [System.ComponentModel.Description('Enables or disables shared device mode.')]
    [System.Nullable[System.Boolean]] $EnableSharedDeviceMode

    [DscProperty()]
    [System.ComponentModel.Description('An optional list of additional bundle IDs allowed to use the AAD extension for single sign-on.')]
    [System.String[]] $BundleIdAccessControlList

    [DscProperty()]
    [System.ComponentModel.Description('Gets or sets a list of typed key-value pairs used to configure Credential-type profiles. This collection can contain a maximum of 500 elements.')]
    [MSFT_keyTypedValuePair[]] $Configurations

    [DscProperty()]
    [System.ComponentModel.Description('Gets or sets the bundle ID of the app extension that performs SSO for the specified URLs.')]
    [System.String] $ExtensionIdentifier

    [DscProperty()]
    [System.ComponentModel.Description('Gets or sets the team ID of the app extension that performs SSO for the specified URLs.')]
    [System.String] $TeamIdentifier

    [DscProperty()]
    [System.ComponentModel.Description('One or more URL prefixes of identity providers on whose behalf the app extension performs single sign-on. URLs must begin with http:// or https://. All URL prefixes must be unique for all profiles.')]
    [System.String[]] $urlPrefixes
}

class MSFT_iosWebContentFilterBase
{
    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('url.')]
    [System.String] $url

    [DscProperty()]
    [System.ComponentModel.Description('bookmarkFolder.')]
    [System.String] $bookmarkFolder

    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('displayName.')]
    [System.String] $displayName
}

class MSFT_iosHomeScreenFolderPage
{
    [DscProperty()]
    [System.ComponentModel.Description('A list of apps, folders, and web clips to appear on a page. This collection can contain a maximum of 500 elements.')]
    [MSFT_iosHomeScreenApp[]] $apps
}

class MSFT_appListItem
{
    [DscProperty()]
    [System.ComponentModel.Description('The application name.')]
    [System.String] $name

    [DscProperty()]
    [System.ComponentModel.Description('The publisher of the application.')]
    [System.String] $publisher

    [DscProperty()]
    [System.ComponentModel.Description('The Store URL of the application.')]
    [System.String] $appStoreUrl

    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('The application or bundle identifier of the application.')]
    [System.String] $appId
}

class MSFT_keyTypedValuePair
{
    [DscProperty()]
    [System.ComponentModel.Description('The type of data.')]
    [System.String] $dataType

    [DscProperty()]
    [System.ComponentModel.Description('Key for the custom data entry.')]
    [System.String] $key

    [DscProperty()]
    [System.ComponentModel.Description('Value for the custom data entry.')]
    [System.String] $value
}
