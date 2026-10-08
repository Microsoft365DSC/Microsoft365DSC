using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class IntuneCustomizationBrandingProfile : M365DSCResourceBase
{
    [DscProperty()]
    [System.ComponentModel.Description('Collection of blocked actions on the company portal as per platform and device ownership types.')]
    [MSFT_MicrosoftGraphcompanyPortalBlockedAction[]] $CompanyPortalBlockedActions

    [DscProperty()]
    [System.ComponentModel.Description('E-mail address of the person/organization responsible for IT support')]
    [System.String] $ContactITEmailAddress

    [DscProperty()]
    [System.ComponentModel.Description('Name of the person/organization responsible for IT support')]
    [System.String] $ContactITName

    [DscProperty()]
    [System.ComponentModel.Description('Text comments regarding the person/organization responsible for IT support')]
    [System.String] $ContactITNotes

    [DscProperty()]
    [System.ComponentModel.Description('Phone number of the person/organization responsible for IT support')]
    [System.String] $ContactITPhoneNumber

    [DscProperty()]
    [System.ComponentModel.Description('Text comments regarding what the admin has access to on the device')]
    [System.String] $CustomCanSeePrivacyMessage

    [DscProperty()]
    [System.ComponentModel.Description('Text comments regarding what the admin doesn''t have access to on the device')]
    [System.String] $CustomCantSeePrivacyMessage

    [DscProperty()]
    [System.ComponentModel.Description('Boolean that indicates if Device Category Selection will be shown in Company Portal')]
    [System.Nullable[System.Boolean]] $DisableDeviceCategorySelection

    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('Company/organization name that is displayed to end users')]
    [System.String] $DisplayName

    [DscProperty()]
    [System.ComponentModel.Description('Customized device enrollment flow displayed to the end user . Possible values are: availableWithPrompts, availableWithoutPrompts, unavailable.')]
    [ValidateSet('availableWithPrompts', 'availableWithoutPrompts', 'unavailable')]
    [System.String] $EnrollmentAvailability

    [DscProperty()]
    [System.ComponentModel.Description('Customized image displayed in Company Portal apps landing page')]
    [MSFT_MicrosoftGraphMimeContent] $LandingPageCustomizedImage

    [DscProperty()]
    [System.ComponentModel.Description('Logo image displayed in Company Portal apps which have a light background behind the logo')]
    [MSFT_MicrosoftGraphMimeContent] $LightBackgroundLogo

    [DscProperty()]
    [System.ComponentModel.Description('Display name of the company/organizations IT helpdesk site')]
    [System.String] $OnlineSupportSiteName

    [DscProperty()]
    [System.ComponentModel.Description('URL to the company/organizations IT helpdesk site')]
    [System.String] $OnlineSupportSiteUrl

    [DscProperty()]
    [System.ComponentModel.Description('URL to the company/organizations privacy policy')]
    [System.String] $PrivacyUrl

    [DscProperty()]
    [System.ComponentModel.Description('Description of the profile')]
    [System.String] $ProfileDescription

    [DscProperty(Key)]
    [System.ComponentModel.Description('Name of the profile')]
    [System.String] $ProfileName

    [DscProperty()]
    [System.ComponentModel.Description('List of scope tags assigned to the branding profile')]
    [System.String[]] $RoleScopeTagIds

    [DscProperty()]
    [System.ComponentModel.Description('Boolean that indicates if AzureAD Enterprise Apps will be shown in Company Portal')]
    [System.Nullable[System.Boolean]] $ShowAzureADEnterpriseApps

    [DscProperty()]
    [System.ComponentModel.Description('Boolean that indicates if Configuration Manager Apps will be shown in Company Portal')]
    [System.Nullable[System.Boolean]] $ShowConfigurationManagerApps

    [DscProperty()]
    [System.ComponentModel.Description('Boolean that represents whether the administrator-supplied display name will be shown next to the logo image or not')]
    [System.Nullable[System.Boolean]] $ShowDisplayNameNextToLogo

    [DscProperty()]
    [System.ComponentModel.Description('Boolean that represents whether the administrator-supplied logo images are shown or not')]
    [System.Nullable[System.Boolean]] $ShowLogo

    [DscProperty()]
    [System.ComponentModel.Description('Boolean that indicates if Office WebApps will be shown in Company Portal')]
    [System.Nullable[System.Boolean]] $ShowOfficeWebApps

    [DscProperty()]
    [System.ComponentModel.Description('Primary theme color used in the Company Portal applications and web portal')]
    [MSFT_MicrosoftGraphrgbColor] $ThemeColor

    [DscProperty()]
    [System.ComponentModel.Description('Logo image displayed in Company Portal apps which have a theme color background behind the logo')]
    [MSFT_MicrosoftGraphMimeContent] $ThemeColorLogo

    [DscProperty()]
    [System.ComponentModel.Description('The unique identifier for an entity. Read-only.')]
    [System.String] $Id

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

    [IntuneCustomizationBrandingProfile] Get()
    {
        $nullResult = $null
        if ($this.RequiresPowerShellCore())
        {
            $remote = [IntuneCustomizationBrandingProfile]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration for the Intune Customization Branding Profile with Id {$($this.Id)} and ProfileName {$($this.ProfileName)}"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.ProfileName -ne $this.ProfileName)
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
                    $getValue = Get-MgBetaDeviceManagementIntuneBrandingProfile -IntuneBrandingProfileId $this.Id -ErrorAction SilentlyContinue
                }

                if ($null -eq $getValue)
                {
                    Write-Verbose -Message "Could not find an Intune Customization Branding Profile with Id {$($this.Id)}"

                    if (-not [System.String]::IsNullOrEmpty($this.DisplayName))
                    {
                        $getValue = Get-MgBetaDeviceManagementIntuneBrandingProfile -All `
                            -Filter "ProfileName eq '$($this.ProfileName -replace "'", "''")'" `
                            -ErrorAction SilentlyContinue
                    }
                }
                #endregion
                if ($null -eq $getValue)
                {
                    Write-Verbose -Message "Could not find an Intune Customization Branding Profile with ProfileName {$($this.ProfileName)}."
                    return $this.AsResult($nullResult)
                }
            }
            else
            {
                $getValue = $this.ExportedInstance
            }
            $resolvedId = $getValue.Id
            Write-Verbose -Message "An Intune Customization Branding Profile with Id {$($resolvedId)} and ProfileName {$($this.ProfileName)} was found"

            $batchRequests = @(
                @{
                    id = 'themeColorLogo'
                    method = 'GET'
                    url = "/deviceManagement/intuneBrandingProfiles/$($resolvedId)/themeColorLogo"
                }
                @{
                    id = 'lightBackgroundLogo'
                    method = 'GET'
                    url = "/deviceManagement/intuneBrandingProfiles/$($resolvedId)/lightBackgroundLogo"
                }
                @{
                    id = 'landingPageCustomizedImage'
                    method = 'GET'
                    url = "/deviceManagement/intuneBrandingProfiles/$($resolvedId)/landingPageCustomizedImage"
                }
            )
            $batchResponses = Invoke-M365DSCGraphBatchRequest -Requests $batchRequests
            $themeColorLogoResponse = ($batchResponses | Where-Object { $_.id -eq 'themeColorLogo' }).body
            $lightBackgroundLogoResponse = ($batchResponses | Where-Object { $_.id -eq 'lightBackgroundLogo' }).body
            $landingPageCustomizedImageResponse = ($batchResponses | Where-Object { $_.id -eq 'landingPageCustomizedImage' }).body

            #region resource generator code
            $complexCompanyPortalBlockedActions = @()
            foreach ($currentCompanyPortalBlockedActions in $getValue.companyPortalBlockedActions)
            {
                $myCompanyPortalBlockedActions = [ordered]@{}
                if ($null -ne $currentCompanyPortalBlockedActions.action)
                {
                    $myCompanyPortalBlockedActions.Add('Action', $currentCompanyPortalBlockedActions.action)
                }
                if ($null -ne $currentCompanyPortalBlockedActions.ownerType)
                {
                    $myCompanyPortalBlockedActions.Add('OwnerType', $currentCompanyPortalBlockedActions.ownerType)
                }
                if ($null -ne $currentCompanyPortalBlockedActions.platform)
                {
                    $myCompanyPortalBlockedActions.Add('Platform', $currentCompanyPortalBlockedActions.platform)
                }
                if ($myCompanyPortalBlockedActions.values.Where({$null -ne $_}).Count -gt 0)
                {
                    $complexCompanyPortalBlockedActions += $myCompanyPortalBlockedActions
                }
            }

            $complexLandingPageCustomizedImage = [ordered]@{}
            $complexLandingPageCustomizedImage.Add('Type', $landingPageCustomizedImageResponse.type)
            $complexLandingPageCustomizedImage.Add('Value', $landingPageCustomizedImageResponse.value)
            if ($complexLandingPageCustomizedImage.Values.Where({ $null -ne $_ }).Count -eq 0)
            {
                $complexLandingPageCustomizedImage = $null
            }

            $complexLightBackgroundLogo = [ordered]@{}
            $complexLightBackgroundLogo.Add('Type', $lightBackgroundLogoResponse.type)
            $complexLightBackgroundLogo.Add('Value', $lightBackgroundLogoResponse.value)
            if ($complexLightBackgroundLogo.Values.Where({ $null -ne $_ }).Count -eq 0)
            {
                $complexLightBackgroundLogo = $null
            }

            $complexThemeColor = [ordered]@{}
            $complexThemeColor.Add('B', $getValue.ThemeColor.b)
            $complexThemeColor.Add('G', $getValue.ThemeColor.g)
            $complexThemeColor.Add('R', $getValue.ThemeColor.r)
            if ($complexThemeColor.Values.Where({ $null -ne $_ }).Count -eq 0)
            {
                $complexThemeColor = $null
            }

            $complexThemeColorLogo = [ordered]@{}
            $complexThemeColorLogo.Add('Type', $themeColorLogoResponse.type)
            $complexThemeColorLogo.Add('Value', $themeColorLogoResponse.value)
            if ($complexThemeColorLogo.Values.Where({ $null -ne $_ }).Count -eq 0)
            {
                $complexThemeColorLogo = $null
            }
            #endregion

            $results = @{
                #region resource generator code
                CompanyPortalBlockedActions               = $complexCompanyPortalBlockedActions
                ContactITEmailAddress                     = $getValue.ContactITEmailAddress
                ContactITName                             = $getValue.ContactITName
                ContactITNotes                            = $getValue.ContactITNotes
                ContactITPhoneNumber                      = $getValue.ContactITPhoneNumber
                CustomCanSeePrivacyMessage                = $getValue.CustomCanSeePrivacyMessage
                CustomCantSeePrivacyMessage               = $getValue.CustomCantSeePrivacyMessage
                #CustomPrivacyMessage                      = $getValue.CustomPrivacyMessage
                #DisableClientTelemetry                    = $getValue.DisableClientTelemetry
                DisableDeviceCategorySelection            = $getValue.DisableDeviceCategorySelection
                DisplayName                               = $getValue.DisplayName
                EnrollmentAvailability                    = $getValue.EnrollmentAvailability
                #IsFactoryResetDisabled                    = $getValue.IsFactoryResetDisabled
                #IsRemoveDeviceDisabled                    = $getValue.IsRemoveDeviceDisabled
                LandingPageCustomizedImage                = $complexLandingPageCustomizedImage
                LightBackgroundLogo                       = $complexLightBackgroundLogo
                OnlineSupportSiteName                     = $getValue.OnlineSupportSiteName
                OnlineSupportSiteUrl                      = $getValue.OnlineSupportSiteUrl
                PrivacyUrl                                = $getValue.PrivacyUrl
                ProfileDescription                        = $getValue.ProfileDescription
                ProfileName                               = $getValue.ProfileName
                RoleScopeTagIds                           = Resolve-M365DSCIntuneRoleScopeTagNames -CurrentValues $getValue.RoleScopeTagIds -DesiredValues $this.RoleScopeTagIds
                #SendDeviceOwnershipChangePushNotification = $getValue.SendDeviceOwnershipChangePushNotification
                ShowAzureADEnterpriseApps                 = $getValue.ShowAzureADEnterpriseApps
                ShowConfigurationManagerApps              = $getValue.ShowConfigurationManagerApps
                ShowDisplayNameNextToLogo                 = $getValue.ShowDisplayNameNextToLogo
                ShowLogo                                  = $getValue.ShowLogo
                ShowOfficeWebApps                         = $getValue.ShowOfficeWebApps
                ThemeColor                                = $complexThemeColor
                ThemeColorLogo                            = $complexThemeColorLogo
                Id                                        = $getValue.Id
                Ensure                                    = 'Present'
                Credential                                = $this.Credential
                ApplicationId                             = $this.ApplicationId
                TenantId                                  = $this.TenantId
                ApplicationSecret                         = $this.ApplicationSecret
                CertificateThumbprint                     = $this.CertificateThumbprint
                CertificatePath                           = $this.CertificatePath
                CertificatePassword                       = $this.CertificatePassword
                ManagedIdentity                           = $this.ManagedIdentity
                #endregion
            }
            $assignmentsValues = Get-MgBetaDeviceManagementIntuneBrandingProfileAssignment -IntuneBrandingProfileId $resolvedId
            $assignmentResult = @()
            if ($assignmentsValues.Count -gt 0)
            {
                $assignmentResult += ConvertFrom-IntunePolicyAssignment -Assignments $assignmentsValues -IncludeDeviceFilter $true
            }
            $results.Add('Assignments', $assignmentResult)

            return $this.AsResult($results)
        }
        catch
        {
            $this.LogError($_, 'Error retrieving data:')

            return $this.AsResult($nullResult)
        }
    }

    [void] Set()
    {
        if ($this.RequiresPowerShellCore())
        {
            $null = $this.InvokeInPowerShellCore('Set')
            return
        }

        Write-Verbose -Message "Setting configuration of the Intune Customization Branding Profile with Id {$($this.Id)} and ProfileName {$($this.ProfileName)}"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $currentInstance = $this.Get().ToHashtable()
        $boundParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()
        $boundParameters = Rename-M365DSCCimInstanceParameter -Properties $boundParameters

        if ($boundParameters.ContainsKey('RoleScopeTagIds'))
        {
            $boundParameters.RoleScopeTagIds = Resolve-M365DSCIntuneRoleScopeTagIds -RoleScopeTagIds $this.RoleScopeTagIds
        }

        if ($boundParameters.ContainsKey('themeColor'))
        {
            $rgbProperties = @('r', 'g', 'b')
            foreach ($property in $rgbProperties)
            {
                if ($null -ne $boundParameters.themeColor.$property)
                {
                    $boundParameters.themeColor.$property = [int]$boundParameters.themeColor.$property
                }
            }
        }

        if ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Creating an Intune Customization Branding Profile with ProfileName {$($this.ProfileName)}"
            $boundParameters.Remove("Assignments") | Out-Null

            $createParameters = ([Hashtable]$boundParameters).Clone()
            $createParameters.Remove('Id') | Out-Null

            #region resource generator code
            $policy = New-MgBetaDeviceManagementIntuneBrandingProfile -BodyParameter $createParameters

            # Some properties cannot be set during creation
            # Wait a few seconds for the policy to be created
            Start-Sleep -Seconds 3
            Update-MgBetaDeviceManagementIntuneBrandingProfile `
                -IntuneBrandingProfileId $policy.Id `
                -BodyParameter $createParameters

            if ($policy.Id)
            {
                $assignmentsHash = ConvertTo-IntunePolicyAssignment -IncludeDeviceFilter:$true -Assignments $this.Assignments
                Update-DeviceConfigurationPolicyAssignment `
                    -DeviceConfigurationPolicyId $policy.Id `
                    -Targets $assignmentsHash `
                    -Repository 'deviceManagement/intuneBrandingProfiles'
            }
            #endregion
        }
        elseif ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Updating the Intune Customization Branding Profile with Id {$($currentInstance.Id)}"
            $boundParameters.Remove("Assignments") | Out-Null

            $updateParameters = ([Hashtable]$boundParameters).Clone()
            $updateParameters.Remove('Id') | Out-Null

            #region resource generator code
            Update-MgBetaDeviceManagementIntuneBrandingProfile `
                -IntuneBrandingProfileId $currentInstance.Id `
                -BodyParameter $updateParameters

            $assignmentsHash = ConvertTo-IntunePolicyAssignment -IncludeDeviceFilter:$true -Assignments $this.Assignments
            Update-DeviceConfigurationPolicyAssignment `
                -DeviceConfigurationPolicyId $currentInstance.Id `
                -Targets $assignmentsHash `
                -Repository 'deviceManagement/intuneBrandingProfiles'
            #endregion
        }
        elseif ($this.Ensure -eq 'Absent' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Removing the Intune Customization Branding Profile with Id {$($currentInstance.Id)}"
            #region resource generator code
            Remove-MgBetaDeviceManagementIntuneBrandingProfile -IntuneBrandingProfileId $currentInstance.Id
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
            [array]$getValue = Get-MgBetaDeviceManagementIntuneBrandingProfile `
                -Filter $this.Filter `
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
                if (-not [System.String]::IsNullOrEmpty($config.displayName))
                {
                    $displayedKey = $config.displayName
                }
                elseif (-not [System.String]::IsNullOrEmpty($config.name))
                {
                    $displayedKey = $config.name
                }
                Write-M365DSCHost -Message "    |---[$i/$($getValue.Count)] $displayedKey" -DeferWrite
                $params = @{
                    Id                    = $config.Id
                    ProfileName           = $config.ProfileName
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

                if ($null -ne $Results.CompanyPortalBlockedActions)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.CompanyPortalBlockedActions `
                        -CIMInstanceName 'MicrosoftGraphcompanyPortalBlockedAction'
                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.CompanyPortalBlockedActions = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('CompanyPortalBlockedActions') | Out-Null
                    }
                }
                if ($null -ne $Results.LandingPageCustomizedImage)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.LandingPageCustomizedImage `
                        -CIMInstanceName 'MicrosoftGraphMimeContent'
                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.LandingPageCustomizedImage = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('LandingPageCustomizedImage') | Out-Null
                    }
                }
                if ($null -ne $Results.LightBackgroundLogo)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.LightBackgroundLogo `
                        -CIMInstanceName 'MicrosoftGraphMimeContent'
                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.LightBackgroundLogo = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('LightBackgroundLogo') | Out-Null
                    }
                }
                if ($null -ne $Results.ThemeColor)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.ThemeColor `
                        -CIMInstanceName 'MicrosoftGraphRgbColor'
                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.ThemeColor = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('ThemeColor') | Out-Null
                    }
                }
                if ($null -ne $Results.ThemeColorLogo)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.ThemeColorLogo `
                        -CIMInstanceName 'MicrosoftGraphMimeContent'
                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.ThemeColorLogo = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('ThemeColorLogo') | Out-Null
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
                    -NoEscape @('Assignments', 'CompanyPortalBlockedActions', 'LandingPageCustomizedImage', 'LightBackgroundLogo', 'ThemeColor', 'ThemeColorLogo') `
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
            Write-M365DSCHost -Message $Global:M365DSCEmojiRedX -CommitWrite

            $this.LogError($_, 'Error during Export:')

            throw
        }
    }

    hidden [IntuneCustomizationBrandingProfile] AsResult([System.Object] $Values)
    {
        if ($Values -is [IntuneCustomizationBrandingProfile])
        {
            return $Values
        }

        $result = [IntuneCustomizationBrandingProfile]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}

class MSFT_MicrosoftGraphcompanyPortalBlockedAction
{
    [DscProperty()]
    [System.ComponentModel.Description('Device Action. Possible values are: unknown, remove, reset.')]
    [ValidateSet('unknown', 'remove', 'reset')]
    [System.String] $Action

    [DscProperty()]
    [System.ComponentModel.Description('Device ownership type. Possible values are: unknown, company, personal.')]
    [ValidateSet('unknown', 'company', 'personal')]
    [System.String] $OwnerType

    [DscProperty()]
    [System.ComponentModel.Description('Device OS/Platform. Possible values are: android, androidForWork, iOS, macOS, windowsPhone81, windows81AndLater, windows10AndLater, androidWorkProfile, unknown.')]
    [ValidateSet('android', 'androidForWork', 'iOS', 'macOS', 'windowsPhone81', 'windows81AndLater', 'windows10AndLater', 'androidWorkProfile', 'unknown', 'androidAOSP', 'androidMobileApplicationManagement', 'iOSMobileApplicationManagement', 'unknownFutureValue', 'windowsMobileApplicationManagement')]
    [System.String] $Platform
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

class MSFT_MicrosoftGraphrgbColor
{
    [DscProperty()]
    [System.ComponentModel.Description('Blue value')]
    [System.String] $B

    [DscProperty()]
    [System.ComponentModel.Description('Green value')]
    [System.String] $G

    [DscProperty()]
    [System.ComponentModel.Description('Red value')]
    [System.String] $R
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
