using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class IntuneDeviceComplianceNotificationMessageTemplate : M365DSCResourceBase
{
    [DscProperty()]
    [System.ComponentModel.Description('The Message Template Branding Options. Branding is defined in the Intune Admin Console. Possible values are: none, includeCompanyLogo, includeCompanyName, includeContactInformation, includeCompanyPortalLink, includeDeviceDetails')]
    [ValidateSet('none', 'includeCompanyLogo', 'includeCompanyName', 'includeContactInformation', 'includeCompanyPortalLink', 'includeDeviceDetails')]
    [System.String[]] $BrandingOptions

    [DscProperty()]
    [System.ComponentModel.Description('The localized notification message templates.')]
    [MSFT_DeviceManagementNotificationMessageTemplate[]] $LocalizedNotificationMessages

    [DscProperty()]
    [System.ComponentModel.Description('Display name for the Notification Message Template.')]
    [System.String] $Description

    [DscProperty(Key)]
    [System.ComponentModel.Description('Display name for the Notification Message Template.')]
    [System.String] $DisplayName

    [DscProperty()]
    [System.ComponentModel.Description('List of Scope Tags for this Entity instance.')]
    [System.String[]] $RoleScopeTagIds

    [DscProperty()]
    [System.ComponentModel.Description('The unique identifier for an entity. Read-only.')]
    [System.String] $Id

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

    [IntuneDeviceComplianceNotificationMessageTemplate] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [IntuneDeviceComplianceNotificationMessageTemplate]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration for the Intune Device Compliance Notification Message Template with Id {$($this.Id)} and DisplayName {$($this.DisplayName)}"

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
                    $getValue = Get-MgBetaDeviceManagementNotificationMessageTemplate -NotificationMessageTemplateId $this.Id `
                        -ExpandProperty 'localizedNotificationMessages' `
                        -ErrorAction SilentlyContinue
                }

                if ($null -eq $getValue)
                {
                    Write-Verbose -Message "Could not find an Intune Device Compliance Notification Message Template with Id {$($this.Id)}"

                    if (-not [System.String]::IsNullOrEmpty($this.DisplayName))
                    {
                        $getValue = Get-MgBetaDeviceManagementNotificationMessageTemplate -All `
                            -Filter "DisplayName eq '$($this.DisplayName -replace "'", "''")'" `
                            -ExpandProperty 'localizedNotificationMessages' `
                            -ErrorAction SilentlyContinue
                    }
                }
                #endregion
                if ($null -eq $getValue)
                {
                    Write-Verbose -Message "Could not find an Intune Device Compliance Notification Message Template with DisplayName {$($this.DisplayName)}."
                    return $this.AsResult($nullResult)
                }
            }
            else
            {
                $getValue = $this.ExportedInstance
            }
            $resolvedId = $getValue.Id
            Write-Verbose -Message "An Intune Device Compliance Notification Message Template with Id {$($resolvedId)} and DisplayName {$($this.DisplayName)} was found"

            #region resource generator code
            $enumBrandingOptions = $null
            if ($null -ne $getValue.BrandingOptions)
            {
                $enumBrandingOptions = $getValue.BrandingOptions.Split(',')
            }

            $messages = @()
            foreach ($message in $getValue.LocalizedNotificationMessages)
            {
                $messages += @{
                    IsDefault       = $message.IsDefault
                    Locale          = $message.Locale
                    MessageTemplate = $message.MessageTemplate
                    Subject         = $message.Subject
                }
            }
            #endregion

            $results = @{
                #region resource generator code
                BrandingOptions               = $enumBrandingOptions
                Description                   = $getValue.Description
                DisplayName                   = $getValue.DisplayName
                LocalizedNotificationMessages = $messages
                RoleScopeTagIds               = Resolve-M365DSCIntuneRoleScopeTagNames -CurrentValues $getValue.RoleScopeTagIds -DesiredValues $this.RoleScopeTagIds
                Id                            = $getValue.Id
                Ensure                        = 'Present'
                Credential                    = $this.Credential
                ApplicationId                 = $this.ApplicationId
                TenantId                      = $this.TenantId
                ApplicationSecret             = $this.ApplicationSecret
                CertificateThumbprint         = $this.CertificateThumbprint
                CertificatePath               = $this.CertificatePath
                CertificatePassword           = $this.CertificatePassword
                ManagedIdentity               = $this.ManagedIdentity
                #endregion
            }

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

        Write-Verbose -Message "Setting configuration of the Intune Device Compliance Notification Message Template with Id {$($this.Id)} and DisplayName {$($this.DisplayName)}"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $currentInstance = $this.Get().ToHashtable()
        $boundParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()

        if ($boundParameters.ContainsKey('RoleScopeTagIds'))
        {
            $boundParameters.RoleScopeTagIds = Resolve-M365DSCIntuneRoleScopeTagIds -RoleScopeTagIds $this.RoleScopeTagIds
        }

        if ($boundParameters.ContainsKey('BrandingOptions'))
        {
            $boundParameters.BrandingOptions = $boundParameters.BrandingOptions -join ','
        }

        $boundParameters = Rename-M365DSCCimInstanceParameter -Properties $boundParameters

        if ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Creating an Intune Device Compliance Notification Message Template with DisplayName {$($this.DisplayName)}"

            $createParameters = $boundParameters
            $createParameters.Remove('Id') | Out-Null

            $localizedNotificationMessagesConverted = $createParameters.LocalizedNotificationMessages
            $createParameters.Remove('LocalizedNotificationMessages') | Out-Null
            #region resource generator code
            $policy = New-MgBetaDeviceManagementNotificationMessageTemplate -BodyParameter $createParameters
            #endregion

            foreach ($messageTemplate in $localizedNotificationMessagesConverted)
            {
                New-MgBetaDeviceManagementNotificationMessageTemplateLocalizedNotificationMessage `
                    -NotificationMessageTemplateId $policy.Id `
                    -BodyParameter $messageTemplate
            }
        }
        elseif ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Updating the Intune Device Compliance Notification Message Template with Id {$($currentInstance.Id)}"

            $updateParameters = $boundParameters
            $updateParameters.Remove('Id') | Out-Null
            $localizedNotificationMessagesConverted = $updateParameters.LocalizedNotificationMessages
            $updateParameters.Remove('LocalizedNotificationMessages') | Out-Null

            #region resource generator code
            Update-MgBetaDeviceManagementNotificationMessageTemplate `
                -NotificationMessageTemplateId $currentInstance.Id `
                -BodyParameter $updateParameters

            $comparison = Compare-Object -ReferenceObject $localizedNotificationMessagesConverted.Locale -DifferenceObject $currentInstance.LocalizedNotificationMessages.Locale -IncludeEqual
            foreach ($compare in $comparison)
            {
                if ($compare.SideIndicator -eq '=>')
                {
                    Write-Verbose -Message "Removing the Localized Notification Message with Locale {$($compare.InputObject)} from the Intune Device Compliance Notification Message Template with Id {$($currentInstance.Id)}"
                    Remove-MgBetaDeviceManagementNotificationMessageTemplateLocalizedNotificationMessage `
                        -NotificationMessageTemplateId $currentInstance.Id `
                        -LocalizedNotificationMessageId "$($currentInstance.Id)_$($compare.InputObject)"
                }
                elseif ($compare.SideIndicator -eq '<=')
                {
                    Write-Verbose -Message "Adding the Localized Notification Message with Locale {$($compare.InputObject)} to the Intune Device Compliance Notification Message Template with Id {$($currentInstance.Id)}"
                    $messageTemplate = $localizedNotificationMessagesConverted | Where-Object { $_.locale -eq $compare.InputObject }
                    New-MgBetaDeviceManagementNotificationMessageTemplateLocalizedNotificationMessage `
                        -NotificationMessageTemplateId $currentInstance.Id `
                        -BodyParameter $messageTemplate
                }
                elseif ($compare.SideIndicator -eq '==')
                {
                    Write-Verbose -Message "Updating the Localized Notification Message with Locale {$($compare.InputObject)} in the Intune Device Compliance Notification Message Template with Id {$($currentInstance.Id)}"
                    $messageTemplate = $localizedNotificationMessagesConverted | Where-Object { $_.locale -eq $compare.InputObject }
                    $messageTemplate.Remove('locale') | Out-Null
                    if (-not $messageTemplate.isDefault)
                    {
                        $messageTemplate.Remove('isDefault') | Out-Null
                    }
                    Update-MgBetaDeviceManagementNotificationMessageTemplateLocalizedNotificationMessage `
                        -NotificationMessageTemplateId $currentInstance.Id `
                        -LocalizedNotificationMessageId "$($currentInstance.Id)_$($compare.InputObject)" `
                        -BodyParameter $messageTemplate
                }
            }
            #endregion
        }
        elseif ($this.Ensure -eq 'Absent' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Removing the Intune Device Compliance Notification Message Template with Id {$($currentInstance.Id)}"
            #region resource generator code
            Remove-MgBetaDeviceManagementNotificationMessageTemplate -NotificationMessageTemplateId $currentInstance.Id
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
            $baseFilter = "displayName ne 'EnrollmentNotificationInternalMEO'"
            $mergedFilter = $baseFilter
            if (-not [System.String]::IsNullOrEmpty($this.Filter))
            {
                $mergedFilter = "($($this.Filter)) and ($baseFilter)"
            }
            [array]$getValue = Get-MgBetaDeviceManagementNotificationMessageTemplate `
                -ExpandProperty 'localizedNotificationMessages' `
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

                if ($Results.LocalizedNotificationMessages)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString -ComplexObject ([Array]$Results.LocalizedNotificationMessages) -CIMInstanceName DeviceManagementNotificationMessageTemplate

                    if ($complexTypeStringResult)
                    {
                        $Results.LocalizedNotificationMessages = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('LocalizedNotificationMessages') | Out-Null
                    }
                }

                $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                    -ConnectionMode $ConnectionMode `
                    -ModulePath $this.GetModulePath() `
                    -Results $Results `
                    -Credential $this.Credential `
                    -NoEscape @('LocalizedNotificationMessages') `
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

    hidden [IntuneDeviceComplianceNotificationMessageTemplate] AsResult([System.Object] $Values)
    {
        if ($Values -is [IntuneDeviceComplianceNotificationMessageTemplate])
        {
            return $Values
        }

        $result = [IntuneDeviceComplianceNotificationMessageTemplate]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}

class MSFT_DeviceManagementNotificationMessageTemplate
{
    [DscProperty()]
    [System.ComponentModel.Description('If this is the default message template.')]
    [System.Nullable[System.Boolean]] $IsDefault

    [DscProperty()]
    [System.ComponentModel.Description('The locale of the message template.')]
    [ValidateSet('ar-sa', 'bg-bg', 'cs-cz', 'da-dk', 'de-de', 'el-gr', 'en-gb', 'en-us', 'es-es', 'es-mx', 'et-ee', 'fi-fi', 'fr-ca', 'fr-fr', 'he-il', 'hr-hr', 'hu-hu', 'it-it', 'ja-jp', 'ko-kr', 'lt-lt', 'lv-lv', 'nb-no', 'nl-nl', 'pl-pl', 'pt-br', 'pt-pt', 'ro-ro', 'sk-sk', 'sl-si', 'ru-ru', 'sr-Latn-rs', 'sv-se', 'th-th', 'tr-tr', 'uk-ua', 'zh-cn', 'zh-tw')]
    [System.String] $Locale

    [DscProperty()]
    [System.ComponentModel.Description('The body of the message template')]
    [System.String] $MessageTemplate

    [DscProperty()]
    [System.ComponentModel.Description('The subject of the message template.')]
    [System.String] $Subject
}
