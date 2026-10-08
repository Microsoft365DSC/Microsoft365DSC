using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class IntuneMobileAppsBundleMacOS : M365DSCResourceBase
{
    [DscProperty()]
    [System.ComponentModel.Description('The unique identifier for an entity. Read-only.')]
    [System.String] $Id

    [DscProperty(Key)]
    [System.ComponentModel.Description('The admin provided or imported title of the app.')]
    [System.String] $DisplayName

    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('The bundle type. To change the app type, you have to first delete and then recreate it. Possible values are: Dmg, Pkg')]
    [ValidateSet('Dmg', 'Pkg')]
    [System.String] $PackageFileType

    [DscProperty()]
    [System.ComponentModel.Description('The description of the app.')]
    [System.String] $Description

    [DscProperty()]
    [System.ComponentModel.Description('The developer of the app.')]
    [System.String] $Developer

    [DscProperty()]
    [System.ComponentModel.Description('The file name of the app.')]
    [System.String] $FileName

    [DscProperty()]
    [System.ComponentModel.Description('The more information Url.')]
    [System.String] $InformationUrl

    [DscProperty()]
    [System.ComponentModel.Description('The value indicating whether the app is marked as featured by the admin.')]
    [System.Nullable[System.Boolean]] $IsFeatured

    [DscProperty()]
    [System.ComponentModel.Description('The large icon, to be displayed in the app details and used for upload of the icon.')]
    [MSFT_MicrosoftGraphMimeContent] $LargeIcon

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
    [System.ComponentModel.Description('The list of categories for this app.')]
    [MSFT_DeviceManagementMobileAppCategory[]] $Categories

    [DscProperty()]
    [System.ComponentModel.Description('The list of apps expected to be installed by the bundle.')]
    [MSFT_MicrosoftGraphMacOSIncludedApp[]] $IncludedApps

    [DscProperty()]
    [System.ComponentModel.Description('When TRUE, indicates that the app''s version will NOT be used to detect if the app is installed on a device. When FALSE, indicates that the app''s version will be used to detect if the app is installed on a device. Set this to true for apps that use a self update feature.')]
    [System.Nullable[System.Boolean]] $IgnoreVersionDetection

    [DscProperty()]
    [System.ComponentModel.Description('Indicates the minimum operating system applicable for the application.')]
    [MSFT_MicrosoftGraphMacOSMinimumOperatingSystem] $MinimumSupportedOperatingSystem

    [DscProperty()]
    [System.ComponentModel.Description('Contains the pre-install script for the app. This will execute on the macOS device before the app is installed.')]
    [System.String] $PreInstallScript

    [DscProperty()]
    [System.ComponentModel.Description('Contains the post-install script for the app. This will execute on the macOS device after the app is installed.')]
    [System.String] $PostInstallScript

    [DscProperty()]
    [System.ComponentModel.Description('List of scope tag ids for this mobile app.')]
    [System.String[]] $RoleScopeTagIds

    [DscProperty()]
    [System.ComponentModel.Description('Represents the assignment to the Intune policy.')]
    [MSFT_DeviceManagementMobileAppAssignment[]] $Assignments

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

    [IntuneMobileAppsBundleMacOS] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [IntuneMobileAppsBundleMacOS]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration for the Intune Mobile Apps Bundle for macOS with Id {$($this.Id)} and DisplayName {$($this.DisplayName)}"

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
                    $getValue = Get-MgBetaDeviceAppManagementMobileApp -MobileAppId $this.Id -ExpandProperty 'categories' -ErrorAction SilentlyContinue
                }

                if ($null -eq $getValue)
                {
                    Write-Verbose -Message "Could not find an Intune Mobile Apps Bundle for macOS with Id {$($this.Id)}"

                    if (-not [System.String]::IsNullOrEmpty($this.DisplayName))
                    {
                        $getValue = Get-MgBetaDeviceAppManagementMobileApp `
                            -Filter "DisplayName eq '$($this.DisplayName -replace "'", "''")'" `
                            -All `
                            -ErrorAction SilentlyContinue | Where-Object -Property '@odata.type' -In @('#microsoft.graph.macOSDmgApp', '#microsoft.graph.macOSPkgApp')
                    }
                }
                #endregion
                if ($null -eq $getValue)
                {
                    Write-Verbose -Message "Could not find an Intune Mobile Apps Bundle for macOS with DisplayName {$($this.DisplayName)}."
                    return $this.AsResult($nullResult)
                }

                $getValue = Get-MgBetaDeviceAppManagementMobileApp -MobileAppId $getValue.Id -ExpandProperty 'categories'
            }
            else
            {
                $getValue = Get-MgBetaDeviceAppManagementMobileApp -MobileAppId $this.ExportedInstance.Id -ExpandProperty 'categories'
            }
            $resolvedId = $getValue.Id
            Write-Verbose -Message "An Intune Mobile Apps Bundle for macOS with Id {$($resolvedId)} and DisplayName {$($this.DisplayName)} was found"

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

            $complexIncludedApps = @()
            foreach ($complexApp in $getValue.includedApps)
            {
                $complexIncludedApp = @{
                    BundleId      = $complexApp.bundleId
                    BundleVersion = $complexApp.bundleVersion
                }
                $complexIncludedApps += $complexIncludedApp
            }

            $complexMinimumSupportedOperatingSystem = [ordered]@{}
            $complexMinimumSupportedOperatingSystem.Add('V10_7', $getValue.minimumSupportedOperatingSystem.v10_7)
            $complexMinimumSupportedOperatingSystem.Add('V10_8', $getValue.minimumSupportedOperatingSystem.v10_8)
            $complexMinimumSupportedOperatingSystem.Add('V10_9', $getValue.minimumSupportedOperatingSystem.v10_9)
            $complexMinimumSupportedOperatingSystem.Add('V10_10', $getValue.minimumSupportedOperatingSystem.v10_10)
            $complexMinimumSupportedOperatingSystem.Add('V10_11', $getValue.minimumSupportedOperatingSystem.v10_11)
            $complexMinimumSupportedOperatingSystem.Add('V10_12', $getValue.minimumSupportedOperatingSystem.v10_12)
            $complexMinimumSupportedOperatingSystem.Add('V10_13', $getValue.minimumSupportedOperatingSystem.v10_13)
            $complexMinimumSupportedOperatingSystem.Add('V10_14', $getValue.minimumSupportedOperatingSystem.v10_14)
            $complexMinimumSupportedOperatingSystem.Add('V10_15', $getValue.minimumSupportedOperatingSystem.v10_15)
            $complexMinimumSupportedOperatingSystem.Add('V11_0', $getValue.minimumSupportedOperatingSystem.v11_0)
            $complexMinimumSupportedOperatingSystem.Add('V12_0', $getValue.minimumSupportedOperatingSystem.v12_0)
            $complexMinimumSupportedOperatingSystem.Add('V13_0', $getValue.minimumSupportedOperatingSystem.v13_0)
            $complexMinimumSupportedOperatingSystem.Add('V14_0', $getValue.minimumSupportedOperatingSystem.v14_0)
            $complexMinimumSupportedOperatingSystem.Add('V15_0', $getValue.minimumSupportedOperatingSystem.v15_0)
            if ($complexMinimumSupportedOperatingSystem.Values.Where({ $null -ne $_ }).Count -eq 0)
            {
                $complexMinimumSupportedOperatingSystem = $null
            }
            #endregion

            $results = @{
                #region resource generator code
                Categories                      = $complexCategories
                Description                     = $getValue.Description
                Developer                       = $getValue.Developer
                DisplayName                     = $getValue.DisplayName
                FileName                        = $getValue.fileName
                IgnoreVersionDetection          = $getValue.ignoreVersionDetection
                IncludedApps                    = $complexIncludedApps
                InformationUrl                  = $getValue.InformationUrl
                IsFeatured                      = $getValue.IsFeatured
                LargeIcon                       = $complexLargeIcon
                MinimumSupportedOperatingSystem = $complexMinimumSupportedOperatingSystem
                Notes                           = $getValue.Notes
                Owner                           = $getValue.Owner
                PackageFileType                 = $getValue.'@odata.type'.Replace('#microsoft.graph.macOS', '').Replace('App', '')
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
            if ($results.PackageFileType -eq 'Pkg')
            {
                $results.PreInstallScript = $this.DecodeTextPayload($getValue.preInstallScript.scriptContent)
                $results.PostInstallScript = $this.DecodeTextPayload($getValue.postInstallScript.scriptContent)
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

        Write-Verbose -Message "Setting configuration of the Intune Mobile Apps Bundle for macOS with Id {$($this.Id)} and DisplayName {$($this.DisplayName)}"

        $this.ValidateBoundParameters()

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $currentInstance = $this.Get().ToHashtable()
        $boundParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()

        if ($boundParameters.ContainsKey('RoleScopeTagIds'))
        {
            $boundParameters.RoleScopeTagIds = Resolve-M365DSCIntuneRoleScopeTagIds -RoleScopeTagIds $this.RoleScopeTagIds
        }

        $boundParameters.Remove('Categories') | Out-Null
        $boundParameters.Remove('PackageFileType') | Out-Null

        if ($boundParameters.ContainsKey('PreInstallScript'))
        {
            $convertedPreInstallScript = $this.EncodeTextPayload($boundParameters.PreInstallScript)
            $boundParameters.Remove('PreInstallScript') | Out-Null
            $boundParameters.Add('PreInstallScript', @{
                scriptContent = $convertedPreInstallScript
            })
        }
        if ($boundParameters.ContainsKey('PostInstallScript'))
        {
            $convertedPostInstallScript = $this.EncodeTextPayload($boundParameters.PostInstallScript)
            $boundParameters.Remove('PostInstallScript') | Out-Null
            $boundParameters.Add('PostInstallScript', @{
                scriptContent = $convertedPostInstallScript
            })
        }

        $boundParameters = Rename-M365DSCCimInstanceParameter -Properties $boundParameters

        if ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Creating an Intune Mobile Apps Bundle for macOS with DisplayName {$($this.DisplayName)}"
            $createParameters = $boundParameters
            $createParameters.Remove('Assignments') | Out-Null

            $createParameters.Remove('Id') | Out-Null

            if (-not $createParameters.ContainsKey('FileName') -or -not $createParameters.ContainsKey('IncludedApps'))
            {
                throw 'FileName and IncludedApps are required parameters.'
            }

            #region resource generator code
            $odataType = "#microsoft.graph.macOS$($this.PackageFileType)App"
            $createParameters.Add('@odata.type', $odataType)
            $createParameters.Add('primaryBundleId', $createParameters.IncludedApps[0].BundleId)
            $createParameters.Add('primaryBundleVersion', $createParameters.IncludedApps[0].BundleVersion)
            $policy = New-MgBetaDeviceAppManagementMobileApp -BodyParameter $createParameters

            Invoke-M365DSCIntuneMobileAppInitialUpload -AppId $policy.Id -OdataType $odataType -FileExtension $this.PackageFileType.ToLower()

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

            Write-Warning -Message 'The Intune Mobile Apps Bundle for macOS resource has been created and the sample content was uploaded. Please ensure to upload the actual content from the Intune portal.'
            #endregion
        }
        elseif ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Updating the Intune Mobile Apps Bundle for macOS with Id {$($currentInstance.Id)}"
            $updateParameters = $boundParameters
            $updateParameters.Remove('Assignments') | Out-Null

            $updateParameters.Remove('Id') | Out-Null

            #region resource generator code
            $updateParameters.Add('@odata.type', "#microsoft.graph.macOS$($this.PackageFileType)App")
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
            Write-Verbose -Message "Removing the Intune Mobile Apps Bundle for macOS with Id {$($currentInstance.Id)}"
            #region resource generator code
            Remove-MgBetaDeviceAppManagementMobileApp -MobileAppId $currentInstance.Id
            #endregion
        }
    }

    [bool] Test()
    {
        $this.ValidateBoundParameters()

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
            $baseFilter = "isof('microsoft.graph.macOSDmgApp') or isof('microsoft.graph.macOSPkgApp')"
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
                    PackageFileType       = $config.'@odata.type'.Replace('#microsoft.graph.macOS', '').Replace('App', '')
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
                if ($null -ne $Results.IncludedApps)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.IncludedApps `
                        -CIMInstanceName 'MicrosoftGraphMacOSIncludedApp'
                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.IncludedApps = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('IncludedApps') | Out-Null
                    }
                }
                if ($null -ne $Results.MinimumSupportedOperatingSystem)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.MinimumSupportedOperatingSystem `
                        -CIMInstanceName 'MicrosoftGraphMacOSMinimumOperatingSystem'
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
                        -CIMInstanceName 'MicrosoftGraphMimeContent'
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
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString -ComplexObject $Results.Assignments -CIMInstanceName DeviceManagementMobileAppAssignment
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
                    -NoEscape @('Assignments', 'IncludedApps', 'LargeIcon', 'MinimumSupportedOperatingSystem', 'Categories') `
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
            ExcludedProperties = @('PackageFileType')
        }
    }

    hidden [void] ValidateBoundParameters()
    {
        $boundParameters = $this.GetBoundParameters()
        if ($boundParameters.PackageFileType -eq 'Dmg' -and ($boundParameters.ContainsKey('PreInstallScript') -or $boundParameters.ContainsKey('PostInstallScript')))
        {
            throw 'PreInstallScript and PostInstallScript are not supported for Dmg package type.'
        }
    }

    hidden [IntuneMobileAppsBundleMacOS] AsResult([System.Object] $Values)
    {
        if ($Values -is [IntuneMobileAppsBundleMacOS])
        {
            return $Values
        }

        $result = [IntuneMobileAppsBundleMacOS]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
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

class MSFT_DeviceManagementMobileAppCategory
{
    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('The name of the app category.')]
    [System.String] $DisplayName

    [DscProperty()]
    [System.ComponentModel.Description('The unique identifier for an entity. Read-only.')]
    [System.String] $Id
}

class MSFT_MicrosoftGraphMacOSIncludedApp
{
    [DscProperty()]
    [System.ComponentModel.Description('The bundleId of the app. This maps to the CFBundleIdentifier in the app''s bundle configuration.')]
    [System.String] $BundleId

    [DscProperty()]
    [System.ComponentModel.Description('The version of the app. This maps to the CFBundleShortVersion in the app''s bundle configuration.')]
    [System.String] $BundleVersion
}

class MSFT_MicrosoftGraphMacOSMinimumOperatingSystem
{
    [DscProperty()]
    [System.ComponentModel.Description('Indicates the minimum version support required for the managed device. When ''True'', OS Version 10.7 or later is required to install the app. If ''False'', Version 10.7 is not the minimum version.')]
    [System.Nullable[System.Boolean]] $V10_7

    [DscProperty()]
    [System.ComponentModel.Description('Indicates the minimum version support required for the managed device. When ''True'', OS Version 10.8 or later is required to install the app. If ''False'', Version 10.8 is not the minimum version.')]
    [System.Nullable[System.Boolean]] $V10_8

    [DscProperty()]
    [System.ComponentModel.Description('Indicates the minimum version support required for the managed device. When ''True'', OS Version 10.9 or later is required to install the app. If ''False'', Version 10.9 is not the minimum version.')]
    [System.Nullable[System.Boolean]] $V10_9

    [DscProperty()]
    [System.ComponentModel.Description('Indicates the minimum version support required for the managed device. When ''True'', OS Version 10.10 or later is required to install the app. If ''False'', Version 10.10 is not the minimum version.')]
    [System.Nullable[System.Boolean]] $V10_10

    [DscProperty()]
    [System.ComponentModel.Description('Indicates the minimum version support required for the managed device. When ''True'', OS Version 10.11 or later is required to install the app. If ''False'', Version 10.11 is not the minimum version.')]
    [System.Nullable[System.Boolean]] $V10_11

    [DscProperty()]
    [System.ComponentModel.Description('Indicates the minimum version support required for the managed device. When ''True'', OS Version 10.12 or later is required to install the app. If ''False'', Version 10.12 is not the minimum version.')]
    [System.Nullable[System.Boolean]] $V10_12

    [DscProperty()]
    [System.ComponentModel.Description('Indicates the minimum version support required for the managed device. When ''True'', OS Version 10.13 or later is required to install the app. If ''False'', Version 10.13 is not the minimum version.')]
    [System.Nullable[System.Boolean]] $V10_13

    [DscProperty()]
    [System.ComponentModel.Description('Indicates the minimum version support required for the managed device. When ''True'', OS Version 10.14 or later is required to install the app. If ''False'', Version 10.14 is not the minimum version.')]
    [System.Nullable[System.Boolean]] $V10_14

    [DscProperty()]
    [System.ComponentModel.Description('Indicates the minimum version support required for the managed device. When ''True'', OS Version 10.15 or later is required to install the app. If ''False'', Version 10.15 is not the minimum version.')]
    [System.Nullable[System.Boolean]] $V10_15

    [DscProperty()]
    [System.ComponentModel.Description('Indicates the minimum version support required for the managed device. When ''True'', OS Version 11.0 or later is required to install the app. If ''False'', Version 11.0 is not the minimum version.')]
    [System.Nullable[System.Boolean]] $V11_0

    [DscProperty()]
    [System.ComponentModel.Description('Indicates the minimum version support required for the managed device. When ''True'', OS Version 12.0 or later is required to install the app. If ''False'', Version 12.0 is not the minimum version.')]
    [System.Nullable[System.Boolean]] $V12_0

    [DscProperty()]
    [System.ComponentModel.Description('Indicates the minimum version support required for the managed device. When ''True'', OS Version 13.0 or later is required to install the app. If ''False'', Version 13.0 is not the minimum version.')]
    [System.Nullable[System.Boolean]] $V13_0

    [DscProperty()]
    [System.ComponentModel.Description('Indicates the minimum version support required for the managed device. When ''True'', OS Version 14.0 or later is required to install the app. If ''False'', Version 14.0 is not the minimum version.')]
    [System.Nullable[System.Boolean]] $V14_0

    [DscProperty()]
    [System.ComponentModel.Description('Indicates the minimum version support required for the managed device. When ''True'', OS Version 15.0 or later is required to install the app. If ''False'', Version 15.0 is not the minimum version.')]
    [System.Nullable[System.Boolean]] $V15_0
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
