using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class IntuneDeviceConfigurationSCEPCertificatePolicyWindows10 : M365DSCResourceBase
{
    [DscProperty()]
    [System.ComponentModel.Description('Target store certificate. Possible values are: user, machine.')]
    [ValidateSet('user', 'machine')]
    [System.String] $CertificateStore

    [DscProperty()]
    [System.ComponentModel.Description('SCEP Hash Algorithm. Possible values are: sha1, sha2.')]
    [ValidateSet('sha1', 'sha2', 'sha1,sha2')]
    [System.String] $HashAlgorithm

    [DscProperty()]
    [System.ComponentModel.Description('SCEP Key Size. Possible values are: size1024, size2048, size4096.')]
    [ValidateSet('size1024', 'size2048', 'size4096')]
    [System.String] $KeySize

    [DscProperty()]
    [System.ComponentModel.Description('SCEP Key Usage. Possible values are: keyEncipherment, digitalSignature.')]
    [ValidateSet('keyEncipherment', 'digitalSignature')]
    [System.String[]] $KeyUsage

    [DscProperty()]
    [System.ComponentModel.Description('SCEP Server Url(s).')]
    [System.String[]] $ScepServerUrls

    [DscProperty()]
    [System.ComponentModel.Description('Custom String that defines the AAD Attribute.')]
    [System.String] $SubjectAlternativeNameFormatString

    [DscProperty()]
    [System.ComponentModel.Description('Custom format to use with SubjectNameFormat = Custom. Example: CN={{UserName}},E={{EmailAddress}},OU=Enterprise Users,O=Contoso Corporation,L=Redmond,ST=WA,C=US')]
    [System.String] $SubjectNameFormatString

    [DscProperty()]
    [System.ComponentModel.Description('Custom Subject Alternative Name Settings. This collection can contain a maximum of 500 elements.')]
    [MSFT_MicrosoftGraphcustomSubjectAlternativeName[]] $CustomSubjectAlternativeNames

    [DscProperty()]
    [System.ComponentModel.Description('Extended Key Usage (EKU) settings. This collection can contain a maximum of 500 elements.')]
    [MSFT_MicrosoftGraphextendedKeyUsage[]] $ExtendedKeyUsages

    [DscProperty()]
    [System.ComponentModel.Description('Scale for the Certificate Validity Period. Possible values are: days, months, years.')]
    [ValidateSet('days', 'months', 'years')]
    [System.String] $CertificateValidityPeriodScale

    [DscProperty()]
    [System.ComponentModel.Description('Value for the Certificate Validity Period')]
    [System.Nullable[System.UInt32]] $CertificateValidityPeriodValue

    [DscProperty()]
    [System.ComponentModel.Description('Key Storage Provider (KSP). Possible values are: useTpmKspOtherwiseUseSoftwareKsp, useTpmKspOtherwiseFail, usePassportForWorkKspOtherwiseFail, useSoftwareKsp.')]
    [ValidateSet('useTpmKspOtherwiseUseSoftwareKsp', 'useTpmKspOtherwiseFail', 'usePassportForWorkKspOtherwiseFail', 'useSoftwareKsp')]
    [System.String] $KeyStorageProvider

    [DscProperty()]
    [System.ComponentModel.Description('Certificate renewal threshold percentage. Valid values 1 to 99')]
    [System.Nullable[System.UInt32]] $RenewalThresholdPercentage

    [DscProperty()]
    [System.ComponentModel.Description('Certificate Subject Alternative Name Type. Possible values are: none, emailAddress, userPrincipalName, customAzureADAttribute, domainNameService, universalResourceIdentifier.')]
    [ValidateSet('none', 'emailAddress', 'userPrincipalName', 'customAzureADAttribute', 'domainNameService', 'universalResourceIdentifier')]
    [System.String] $SubjectAlternativeNameType

    [DscProperty()]
    [System.ComponentModel.Description('Certificate Subject Name Format. Possible values are: commonName, commonNameIncludingEmail, commonNameAsEmail, custom, commonNameAsIMEI, commonNameAsSerialNumber, commonNameAsAadDeviceId, commonNameAsIntuneDeviceId, commonNameAsDurableDeviceId.')]
    [ValidateSet('commonName', 'commonNameIncludingEmail', 'commonNameAsEmail', 'custom', 'commonNameAsIMEI', 'commonNameAsSerialNumber', 'commonNameAsAadDeviceId', 'commonNameAsIntuneDeviceId', 'commonNameAsDurableDeviceId')]
    [System.String] $SubjectNameFormat

    [DscProperty()]
    [System.ComponentModel.Description('Trusted Root Certificate DisplayName')]
    [System.String] $RootCertificateDisplayName

    [DscProperty()]
    [System.ComponentModel.Description('Trusted Root Certificate Id')]
    [System.String] $RootCertificateId

    [DscProperty()]
    [System.ComponentModel.Description('Admin provided description of the Device Configuration.')]
    [System.String] $Description

    [DscProperty()]
    [System.ComponentModel.Description('The device mode applicability rule for this Policy.')]
    [MSFT_DeviceManagementApplicabilityRuleDeviceMode] $DeviceManagementApplicabilityRuleDeviceMode

    [DscProperty()]
    [System.ComponentModel.Description('The OS edition applicability for this Policy. ')]
    [MSFT_DeviceManagementApplicabilityRuleOsEdition] $DeviceManagementApplicabilityRuleOsEdition

    [DscProperty()]
    [System.ComponentModel.Description('The OS version applicability rule for this Policy.')]
    [MSFT_DeviceManagementApplicabilityRuleOsVersion] $DeviceManagementApplicabilityRuleOsVersion

    [DscProperty(Key)]
    [System.ComponentModel.Description('Admin provided name of the device configuration.')]
    [System.String] $DisplayName

    [DscProperty()]
    [System.ComponentModel.Description('The unique identifier for an entity. Read-only.')]
    [System.String] $Id

    [DscProperty()]
    [System.ComponentModel.Description('List of Scope Tags for this Entity instance.')]
    [System.String[]] $RoleScopeTagIds

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

    [IntuneDeviceConfigurationSCEPCertificatePolicyWindows10] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [IntuneDeviceConfigurationSCEPCertificatePolicyWindows10]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of the Intune Device Configuration Scep Certificate Policy for Windows10 with Id {$($this.Id)} and DisplayName {$($this.DisplayName)}"

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
                if (-not [string]::IsNullOrEmpty($this.Id))
                {
                    $getValue = Get-MgBetaDeviceManagementDeviceConfiguration -All -Filter "Id eq '$($this.Id)'" -ErrorAction SilentlyContinue
                }

                if ($null -eq $getValue)
                {
                    Write-Verbose -Message "Could not find an Intune Device Configuration Scep Certificate Policy for Windows10 with Id {$($this.Id)}"

                    if (-not [string]::IsNullOrEmpty($this.DisplayName))
                    {
                        $getValue = Get-MgBetaDeviceManagementDeviceConfiguration `
                            -All `
                            -Filter "DisplayName eq '$($this.DisplayName -replace "'", "''")' and isof('microsoft.graph.windows81SCEPCertificateProfile')" `
                            -ErrorAction SilentlyContinue
                    }
                }
                #endregion
                if ($null -eq $getValue)
                {
                    Write-Verbose -Message "Could not find an Intune Device Configuration Scep Certificate Policy for Windows10 with DisplayName {$($this.DisplayName)}"
                    return $this.AsResult($nullResult)
                }
            }
            else
            {
                $getValue = $this.ExportedInstance
            }
            $policyId = $getValue.Id
            Write-Verbose -Message "An Intune Device Configuration Scep Certificate Policy for Windows10 with Id {$policyId} and DisplayName {$($this.DisplayName)} was found."

            #region resource generator code
            $complexCustomSubjectAlternativeNames = @()
            foreach ($currentcustomSubjectAlternativeNames in $getValue.customSubjectAlternativeNames)
            {
                $mycustomSubjectAlternativeNames = [ordered]@{}
                $mycustomSubjectAlternativeNames.Add('Name', $currentcustomSubjectAlternativeNames.name)
                if ($null -ne $currentcustomSubjectAlternativeNames.sanType)
                {
                    $mycustomSubjectAlternativeNames.Add('SanType', $currentcustomSubjectAlternativeNames.sanType)
                }
                if ($mycustomSubjectAlternativeNames.values.Where({ $null -ne $_ }).Count -gt 0)
                {
                    $complexCustomSubjectAlternativeNames += $mycustomSubjectAlternativeNames
                }
            }

            $complexExtendedKeyUsages = @()
            foreach ($currentextendedKeyUsages in $getValue.extendedKeyUsages)
            {
                $myextendedKeyUsages = [ordered]@{}
                $myextendedKeyUsages.Add('Name', $currentextendedKeyUsages.name)
                $myextendedKeyUsages.Add('ObjectIdentifier', $currentextendedKeyUsages.objectIdentifier)
                if ($myextendedKeyUsages.values.Where({ $null -ne $_ }).Count -gt 0)
                {
                    $complexExtendedKeyUsages += $myextendedKeyUsages
                }
            }
            #endregion

            $complexDeviceManagementApplicabilityRuleDeviceMode = [ordered]@{}
            $complexDeviceManagementApplicabilityRuleDeviceMode.Add('DeviceMode', $getValue.DeviceManagementApplicabilityRuleDeviceMode.DeviceMode)
            $complexDeviceManagementApplicabilityRuleDeviceMode.Add('Name', $getValue.DeviceManagementApplicabilityRuleDeviceMode.Name)
            $complexDeviceManagementApplicabilityRuleDeviceMode.Add('RuleType', $getValue.DeviceManagementApplicabilityRuleDeviceMode.RuleType)
            if ($complexDeviceManagementApplicabilityRuleDeviceMode.values.Where({ $null -ne $_ }).Count -eq 0)
            {
                $complexDeviceManagementApplicabilityRuleDeviceMode = $null
            }

            $complexDeviceManagementApplicabilityRuleOsEdition = [ordered]@{}
            $complexDeviceManagementApplicabilityRuleOsEdition.Add('Name', $getValue.DeviceManagementApplicabilityRuleOSEdition.Name)
            $complexDeviceManagementApplicabilityRuleOsEdition.Add('OsEditionTypes', [string[]]$getValue.DeviceManagementApplicabilityRuleOSEdition.OsEditionTypes)
            $complexDeviceManagementApplicabilityRuleOsEdition.Add('RuleType', $getValue.DeviceManagementApplicabilityRuleOSEdition.RuleType)
            if ($complexDeviceManagementApplicabilityRuleOsEdition.values.Where({ $null -ne $_ }).Count -eq 0)
            {
                $complexDeviceManagementApplicabilityRuleOsEdition = $null
            }

            $complexDeviceManagementApplicabilityRuleOsVersion = [ordered]@{}
            $complexDeviceManagementApplicabilityRuleOsVersion.Add('MaxOSVersion', $getValue.DeviceManagementApplicabilityRuleOSVersion.MaxOSVersion)
            $complexDeviceManagementApplicabilityRuleOsVersion.Add('MinOSVersion', $getValue.DeviceManagementApplicabilityRuleOSVersion.MinOSVersion)
            $complexDeviceManagementApplicabilityRuleOsVersion.Add('Name', $getValue.DeviceManagementApplicabilityRuleOSVersion.Name)
            $complexDeviceManagementApplicabilityRuleOsVersion.Add('RuleType', $getValue.DeviceManagementApplicabilityRuleOSVersion.RuleType)
            if ($complexDeviceManagementApplicabilityRuleOsVersion.values.Where({ $null -ne $_ }).Count -eq 0)
            {
                $complexDeviceManagementApplicabilityRuleOsVersion = $null
            }

            $RootCertificate = $this.GetDeviceConfigurationPolicyRootCertificate($getValue.Id)
            $rootCertificateIdValue = $RootCertificate.Id
            $rootCertificateDisplayNameValue = $RootCertificate.DisplayName

            $results = @{
                #region resource generator code
                CertificateStore                            = $getValue.certificateStore
                HashAlgorithm                               = $getValue.hashAlgorithm
                KeySize                                     = $getValue.keySize
                KeyUsage                                    = $getValue.keyUsage.Split(',')
                ScepServerUrls                              = $getValue.scepServerUrls
                SubjectAlternativeNameFormatString          = $getValue.subjectAlternativeNameFormatString
                SubjectNameFormatString                     = $getValue.subjectNameFormatString
                CustomSubjectAlternativeNames               = $complexCustomSubjectAlternativeNames
                ExtendedKeyUsages                           = $complexExtendedKeyUsages
                CertificateValidityPeriodScale              = $getValue.certificateValidityPeriodScale
                CertificateValidityPeriodValue              = $getValue.certificateValidityPeriodValue
                KeyStorageProvider                          = $getValue.keyStorageProvider
                RenewalThresholdPercentage                  = $getValue.renewalThresholdPercentage
                SubjectAlternativeNameType                  = $getValue.subjectAlternativeNameType
                SubjectNameFormat                           = $getValue.subjectNameFormat
                RootCertificateId                           = $rootCertificateIdValue
                RootCertificateDisplayName                  = $rootCertificateDisplayNameValue
                Description                                 = $getValue.Description
                DeviceManagementApplicabilityRuleDeviceMode = $complexDeviceManagementApplicabilityRuleDeviceMode
                DeviceManagementApplicabilityRuleOsEdition  = $complexDeviceManagementApplicabilityRuleOsEdition
                DeviceManagementApplicabilityRuleOsVersion  = $complexDeviceManagementApplicabilityRuleOsVersion
                DisplayName                                 = $getValue.DisplayName
                Id                                          = $getValue.Id
                RoleScopeTagIds                             = Resolve-M365DSCIntuneRoleScopeTagNames -CurrentValues $getValue.RoleScopeTagIds -DesiredValues $this.RoleScopeTagIds
                Ensure                                      = 'Present'
                Credential                                  = $this.Credential
                ApplicationId                               = $this.ApplicationId
                TenantId                                    = $this.TenantId
                ApplicationSecret                           = $this.ApplicationSecret
                CertificateThumbprint                       = $this.CertificateThumbprint
                CertificatePath                             = $this.CertificatePath
                CertificatePassword                         = $this.CertificatePassword
                ManagedIdentity                             = $this.ManagedIdentity
                AccessTokens                                = $this.AccessTokens
                #endregion
            }

            $assignmentsValues = Get-M365DSCIntuneExpandedAssignments -Instance $getValue
            if ($null -eq $assignmentsValues)
            {
                $assignmentsValues = Get-MgBetaDeviceManagementDeviceConfigurationAssignment -DeviceConfigurationId $policyId
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
            Write-Verbose -Message "Creating an Intune Device Configuration Scep Certificate Policy for Windows10 with DisplayName {$($this.DisplayName)}"
            $createParameters = $boundParameters
            $createParameters.Remove('Assignments') | Out-Null
            $createParameters.Remove('RootCertificateId') | Out-Null
            $createParameters.Remove('RootCertificateDisplayName') | Out-Null

            $createParameters.Remove('Id') | Out-Null
            $createParameters['keyUsage'] = $createParameters['keyUsage'] -join ','

            $rootCertificateIdValue = $this.RootCertificateId
            $RootCertificate = $null
            if (-not [System.String]::IsNullOrEmpty($rootCertificateIdValue))
            {
                $RootCertificate = Get-MgBetaDeviceManagementDeviceConfiguration `
                    -DeviceConfigurationId $rootCertificateIdValue `
                    -ErrorAction SilentlyContinue | Where-Object -FilterScript {
                        $_.'@odata.type' -eq '#microsoft.graph.windows81TrustedRootCertificate'
                    }
            }

            if ($null -eq $RootCertificate)
            {
                Write-Verbose -Message "Could not find trusted root certificate with Id {$rootCertificateIdValue}, searching by display name {$($this.RootCertificateDisplayName)}"

                $RootCertificate = Get-MgBetaDeviceManagementDeviceConfiguration -All `
                    -Filter "DisplayName eq '$($this.RootCertificateDisplayName -replace "'", "''")' and isof('microsoft.graph.windows81TrustedRootCertificate')" `
                    -ErrorAction SilentlyContinue

                if ($null -eq $RootCertificate)
                {
                    throw "Could not find trusted root certificate with Id {$rootCertificateIdValue} or display name {$($this.RootCertificateDisplayName)}"
                }
                $rootCertificateIdValue = $RootCertificate.Id

                Write-Verbose -Message "Found trusted root certificate with Id {$($RootCertificate.Id)} and DisplayName {$($RootCertificate.DisplayName)}"
            }
            else
            {
                Write-Verbose -Message "Found trusted root certificate with Id {$rootCertificateIdValue}"
            }

            #region resource generator code
            $createParameters.Add('rootCertificate@odata.bind', "$((Get-MSCloudLoginConnectionProfile -Workload MicrosoftGraph).ResourceUrl)beta/deviceManagement/deviceConfigurations('$rootCertificateIdValue')")
            $createParameters.Add('@odata.type', '#microsoft.graph.windows81SCEPCertificateProfile')
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
            Write-Verbose -Message "Updating the Intune Device Configuration Scep Certificate Policy for Windows10 with Id {$($currentInstance.Id)}"
            $updateParameters = $boundParameters
            $updateParameters.Remove('Assignments') | Out-Null
            $updateParameters.Remove('RootCertificateId') | Out-Null
            $updateParameters.Remove('RootCertificateDisplayName') | Out-Null

            $updateParameters.Remove('Id') | Out-Null
            $updateParameters['keyUsage'] = $updateParameters['keyUsage'] -join ','

            #region resource generator code
            $updateParameters.Add('@odata.type', '#microsoft.graph.windows81SCEPCertificateProfile')
            Update-MgBetaDeviceManagementDeviceConfiguration `
                -DeviceConfigurationId $currentInstance.Id `
                -BodyParameter $updateParameters
            $assignmentsHash = ConvertTo-IntunePolicyAssignment -IncludeDeviceFilter:$true -Assignments $this.Assignments
            Update-DeviceConfigurationPolicyAssignment `
                -DeviceConfigurationPolicyId $currentInstance.id `
                -Targets $assignmentsHash `
                -Repository 'deviceManagement/deviceConfigurations'
            #endregion

            $rootCertificate = $null
            $rootCertificateIdValue = $this.RootCertificateId
            if (-not [System.String]::IsNullOrEmpty($rootCertificateIdValue))
            {
                $rootCertificate = Get-MgBetaDeviceManagementDeviceConfiguration `
                    -DeviceConfigurationId $rootCertificateIdValue `
                    -ErrorAction SilentlyContinue | Where-Object -FilterScript {
                        $_.'@odata.type' -eq '#microsoft.graph.windows81TrustedRootCertificate'
                    }
            }

            if ($null -eq $rootCertificate)
            {
                Write-Verbose -Message "Could not find trusted root certificate with Id {$rootCertificateIdValue}, searching by display name {$($this.RootCertificateDisplayName)}"

                $rootCertificate = Get-MgBetaDeviceManagementDeviceConfiguration -All `
                    -Filter "DisplayName eq '$($this.RootCertificateDisplayName -replace "'", "''")'" `
                    -ErrorAction SilentlyContinue | `
                        Where-Object -FilterScript {
                        $_.'@odata.type' -eq '#microsoft.graph.windows81TrustedRootCertificate'
                    }

                if ($null -eq $rootCertificate)
                {
                    throw "Could not find trusted root certificate with Id {$rootCertificateIdValue} or display name {$($this.RootCertificateDisplayName)}"
                }
                $rootCertificateIdValue = $rootCertificate.Id

                Write-Verbose -Message "Found trusted root certificate with Id {$($rootCertificate.Id)} and DisplayName {$($rootCertificate.DisplayName)}"
            }
            else
            {
                Write-Verbose -Message "Found trusted root certificate with Id {$rootCertificateIdValue}"
            }

            $this.UpdateDeviceConfigurationPolicyRootCertificateId($currentInstance.id, $rootCertificateIdValue)
        }
        elseif ($this.Ensure -eq 'Absent' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Removing the Intune Device Configuration Scep Certificate Policy for Windows10 with Id {$($currentInstance.Id)}"
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
                -ODataType 'microsoft.graph.windows81SCEPCertificateProfile' `
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

                $displayedKey = $config.Id
                if (-not [String]::IsNullOrEmpty($config.displayName))
                {
                    $displayedKey = $config.displayName
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

                if ($null -ne $Results.CustomSubjectAlternativeNames)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.CustomSubjectAlternativeNames `
                        -CIMInstanceName 'MicrosoftGraphcustomSubjectAlternativeName'
                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.CustomSubjectAlternativeNames = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('CustomSubjectAlternativeNames') | Out-Null
                    }
                }
                if ($null -ne $Results.ExtendedKeyUsages)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.ExtendedKeyUsages `
                        -CIMInstanceName 'MicrosoftGraphextendedKeyUsage'
                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.ExtendedKeyUsages = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('ExtendedKeyUsages') | Out-Null
                    }
                }
                if ($Results.DeviceManagementApplicabilityRuleDeviceMode)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString -ComplexObject $Results.DeviceManagementApplicabilityRuleDeviceMode -CIMInstanceName DeviceManagementApplicabilityRuleDeviceMode
                    if ($complexTypeStringResult)
                    {
                        $Results.DeviceManagementApplicabilityRuleDeviceMode = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('DeviceManagementApplicabilityRuleDeviceMode') | Out-Null
                    }
                }
                if ($Results.DeviceManagementApplicabilityRuleOsEdition)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString -ComplexObject $Results.DeviceManagementApplicabilityRuleOsEdition -CIMInstanceName DeviceManagementApplicabilityRuleOsEdition
                    if ($complexTypeStringResult)
                    {
                        $Results.DeviceManagementApplicabilityRuleOsEdition = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('DeviceManagementApplicabilityRuleOsEdition') | Out-Null
                    }
                }
                if ($Results.DeviceManagementApplicabilityRuleOsVersion)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString -ComplexObject $Results.DeviceManagementApplicabilityRuleOsVersion -CIMInstanceName DeviceManagementApplicabilityRuleOsVersion
                    if ($complexTypeStringResult)
                    {
                        $Results.DeviceManagementApplicabilityRuleOsVersion = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('DeviceManagementApplicabilityRuleOsVersion') | Out-Null
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
                    -NoEscape @('CustomSubjectAlternativeNames', 'DeviceManagementApplicabilityRuleDeviceMode', 'DeviceManagementApplicabilityRuleOsEdition', 'DeviceManagementApplicabilityRuleOsVersion', 'ExtendedKeyUsages', 'Assignments') `
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

    [System.Collections.Hashtable] GetCompareParameters()
    {
        return @{
            PostProcessing = {
                param($DesiredValues, $CurrentValues, $ValuesToCheck, $PostProcessingArgs)
                if (-not [System.String]::IsNullOrEmpty($DesiredValues.RootCertificateDisplayName))
                {
                    $ValuesToCheck.Remove('RootCertificateId') | Out-Null
                }
                return [System.Tuple[Hashtable, Hashtable, Hashtable]]::new($DesiredValues, $CurrentValues, $ValuesToCheck)
            }
        }
    }

    hidden [void] UpdateDeviceConfigurationPolicyRootCertificateId([System.String] $DeviceConfigurationPolicyId, [System.String] $RootCertificateId)
    {
        $Uri = "/beta/deviceManagement/deviceConfigurations('$DeviceConfigurationPolicyId')/microsoft.graph.windows81SCEPCertificateProfile/rootCertificate/`$ref"
        $ref = @{
            '@odata.id' = (Get-MSCloudLoginConnectionProfile -Workload MicrosoftGraph).ResourceUrl + "beta/deviceManagement/deviceConfigurations('$RootCertificateId')"
        }

        $null = Invoke-M365DSCGraphRequest -Method PUT -Uri $Uri -Body ($ref | ConvertTo-Json) -ErrorAction Stop
    }

    hidden [System.Object] GetDeviceConfigurationPolicyRootCertificate([System.String] $DeviceConfigurationPolicyId)
    {
        $Uri = "/beta/deviceManagement/deviceConfigurations('$DeviceConfigurationPolicyId')/microsoft.graph.windows81SCEPCertificateProfile/rootCertificate"
        $result = Invoke-M365DSCGraphRequest -Method Get -Uri $Uri -ErrorAction Stop

        return $result
    }

    hidden [IntuneDeviceConfigurationSCEPCertificatePolicyWindows10] AsResult([System.Object] $Values)
    {
        if ($Values -is [IntuneDeviceConfigurationSCEPCertificatePolicyWindows10])
        {
            return $Values
        }

        $result = [IntuneDeviceConfigurationSCEPCertificatePolicyWindows10]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}

class MSFT_MicrosoftGraphcustomSubjectAlternativeName
{
    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('Custom SAN Name')]
    [System.String] $Name

    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('Custom SAN Type. Possible values are: none, emailAddress, userPrincipalName, customAzureADAttribute, domainNameService, universalResourceIdentifier.')]
    [ValidateSet('none', 'emailAddress', 'userPrincipalName', 'customAzureADAttribute', 'domainNameService', 'universalResourceIdentifier')]
    [System.String] $SanType
}

class MSFT_MicrosoftGraphextendedKeyUsage
{
    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('Extended Key Usage Name')]
    [System.String] $Name

    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('Extended Key Usage Object Identifier')]
    [System.String] $ObjectIdentifier
}

class MSFT_DeviceManagementApplicabilityRuleDeviceMode
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

class MSFT_DeviceManagementApplicabilityRuleOsEdition
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

class MSFT_DeviceManagementApplicabilityRuleOsVersion
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
