using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class AADTenantAppManagementPolicy : M365DSCResourceBase
{
    [DscProperty()]
    [System.ComponentModel.Description('The display name of the policy.')]
    [System.String] $DisplayName

    [DscProperty(Key)]
    [System.ComponentModel.Description('Only valid value is ''Yes''.')]
    [ValidateSet('Yes')]
    [System.String] $IsSingleInstance

    [DscProperty()]
    [System.ComponentModel.Description('The description of the policy.')]
    [System.String] $Description

    [DscProperty()]
    [System.ComponentModel.Description('Denotes whether the policy is enabled.')]
    [System.Nullable[System.Boolean]] $IsEnabled

    [DscProperty()]
    [System.ComponentModel.Description('Restrictions that apply to an application  object.')]
    [MSFT_AADTenantAppManagementPolicyRestrictions] $ApplicationRestrictions

    [DscProperty()]
    [System.ComponentModel.Description('Restrictions that apply to a service principal  object.')]
    [MSFT_AADTenantAppManagementPolicyRestrictions] $ServicePrincipalRestrictions

    [DscProperty()]
    [System.ComponentModel.Description('Credentials of the workload''s Admin')]
    [System.Management.Automation.PSCredential] $Credential

    [DscProperty()]
    [System.ComponentModel.Description('Id of the Azure Active Directory application to authenticate with.')]
    [System.String] $ApplicationId

    [DscProperty()]
    [System.ComponentModel.Description('Id of the Azure Active Directory tenant used for authentication.')]
    [System.String] $TenantId

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
    [System.Management.Automation.PSCredential] $ApplicationSecret

    [AADTenantAppManagementPolicy] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [AADTenantAppManagementPolicy]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration for the AAD Tenant App Management Policy with DisplayName {$($this.DisplayName)}"

        try
        {
            if (-not $this.ExportedInstance)
            {
                $null = $this.Connect('MicrosoftGraph')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $instance = Get-MgBetaPolicyDefaultAppManagementPolicy -ErrorAction SilentlyContinue

                if ($null -eq $instance)
                {
                    throw 'Could not find the tenant app management policy.'
                }
            }
            else
            {
                $instance = $this.ExportedInstance
            }

            #region ApplicationRestrictions
            $appRestrictionsValue = @{
                passwordCredentials = @()
                keyCredentials      = @()
            }

            foreach ($passwordCred in $instance.ApplicationRestrictions.PasswordCredentials)
            {
                $newItem = [ordered]@{
                    restrictForAppsCreatedAfterDateTime = $passwordCred.RestrictForAppsCreatedAfterDateTime.ToString("o")
                    restrictionType                     = $passwordCred.RestrictionType
                    state                               = $passwordCred.State
                }
                if ($null -ne $passwordCred.MaxLifetime)
                {
                    $newItem.Add('maxLifetime', $passwordCred.MaxLifetime)
                }
                $appRestrictionsValue.passwordCredentials += $newItem
            }

            foreach ($keyCred in $instance.ApplicationRestrictions.KeyCredentials)
            {
                $newItem = [ordered]@{
                    restrictForAppsCreatedAfterDateTime = $keyCred.RestrictForAppsCreatedAfterDateTime.ToString("o")
                    restrictionType                     = $keyCred.RestrictionType
                    state                               = $keyCred.State
                }
                if ($null -ne $keyCred.MaxLifetime)
                {
                    $newItem.Add('maxLifetime', $keyCred.MaxLifetime)
                }
                if ($null -ne $keyCred.CertificateBasedApplicationConfigurationIds -and $keyCred.CertificateBasedApplicationConfigurationIds.Count -gt 0)
                {
                    $newItem.Add('certificateBasedApplicationConfigurationIds', [System.String[]]$keyCred.CertificateBasedApplicationConfigurationIds)
                }
                $appRestrictionsValue.keyCredentials += $newItem
            }
            #endregion

            #region ServicePrincipalRestrictions
            $spnRestrictionsValue = [ordered]@{
                passwordCredentials = @()
                keyCredentials      = @()
            }

            foreach ($passwordCred in $instance.ServicePrincipalRestrictions.PasswordCredentials)
            {
                $newItem = [ordered]@{
                    restrictForAppsCreatedAfterDateTime = $passwordCred.RestrictForAppsCreatedAfterDateTime.ToString("o")
                    restrictionType                     = $passwordCred.RestrictionType
                    state                               = $passwordCred.State
                }
                if ($null -ne $passwordCred.MaxLifetime)
                {
                    $newItem.Add('maxLifetime', $passwordCred.MaxLifetime)
                }
                $spnRestrictionsValue.passwordCredentials += $newItem
            }

            foreach ($keyCred in $instance.ServicePrincipalRestrictions.KeyCredentials)
            {
                $newItem = [ordered]@{
                    restrictForAppsCreatedAfterDateTime = $keyCred.RestrictForAppsCreatedAfterDateTime.ToString("o")
                    restrictionType                     = $keyCred.RestrictionType
                    state                               = $keyCred.State
                }
                if ($null -ne $keyCred.MaxLifetime)
                {
                    $newItem.Add('maxLifetime', $keyCred.MaxLifetime)
                }
                if ($null -ne $keyCred.CertificateBasedApplicationConfigurationIds -and $keyCred.CertificateBasedApplicationConfigurationIds.Count -gt 0)
                {
                    $newItem.Add('certificateBasedApplicationConfigurationIds', [System.String[]]$keyCred.CertificateBasedApplicationConfigurationIds)
                }
                $spnRestrictionsValue.keyCredentials += $newItem
            }
            #endregion

            $results = @{
                DisplayName                  = $instance.DisplayName
                Description                  = $instance.Description
                IsEnabled                    = $instance.IsEnabled
                ApplicationRestrictions      = $appRestrictionsValue
                ServicePrincipalRestrictions = $spnRestrictionsValue
                IsSingleInstance             = 'Yes'
                Credential                   = $this.Credential
                ApplicationId                = $this.ApplicationId
                TenantId                     = $this.TenantId
                CertificateThumbprint        = $this.CertificateThumbprint
                CertificatePath              = $this.CertificatePath
                CertificatePassword          = $this.CertificatePassword
                ManagedIdentity              = $this.ManagedIdentity
                AccessTokens                 = $this.AccessTokens
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

        Write-Verbose -Message "Setting configuration of Default App Management Policy"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $null = $this.Get().ToHashtable()

        $setParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()
        $appRestrictionsValue = @{
            passwordCredentials = @()
            keyCredentials      = @()
        }

        foreach ($passwordCred in $this.ApplicationRestrictions.PasswordCredentials)
        {
            $newItem = @{
                restrictForAppsCreatedAfterDateTime = $passwordCred.RestrictForAppsCreatedAfterDateTime
                restrictionType                     = $passwordCred.RestrictionType
                state                               = $passwordCred.State
            }
            if ($null -ne $passwordCred.MaxLifetime)
            {
                $newItem.Add('maxLifetime', $passwordCred.MaxLifetime.ToString())
            }
            $appRestrictionsValue.passwordCredentials += $newItem
        }

        foreach ($keyCred in $this.ApplicationRestrictions.KeyCredentials)
        {
            $newItem = @{
                restrictForAppsCreatedAfterDateTime = $keyCred.RestrictForAppsCreatedAfterDateTime
                restrictionType                     = $keyCred.RestrictionType
                state                               = $keyCred.State
            }
            if ($null -ne $keyCred.MaxLifetime)
            {
                $newItem.Add('maxLifetime', $keyCred.MaxLifetime.ToString())
            }
            if ($null -ne $keyCred.CertificateBasedApplicationConfigurationIds -and $keyCred.CertificateBasedApplicationConfigurationIds.Count -gt 0)
            {
                $newItem.Add('certificateBasedApplicationConfigurationIds', [System.String[]]$keyCred.CertificateBasedApplicationConfigurationIds)
            }
            $appRestrictionsValue.keyCredentials += $newItem
        }

        $setParameters.Remove('ApplicationRestrictions') | Out-Null
        $setParameters.applicationRestrictions = $appRestrictionsValue

        $spnRestrictionsValue = @{
            passwordCredentials = @()
            keyCredentials      = @()
        }

        foreach ($passwordCred in $this.ServicePrincipalRestrictions.PasswordCredentials)
        {
            $newItem = @{
                restrictForAppsCreatedAfterDateTime = $passwordCred.RestrictForAppsCreatedAfterDateTime
                restrictionType                     = $passwordCred.RestrictionType
                state                               = $passwordCred.State
            }
            if ($null -ne $passwordCred.MaxLifetime)
            {
                $newItem.Add('maxLifetime', $passwordCred.MaxLifetime.ToString())
            }
            $spnRestrictionsValue.passwordCredentials += $newItem
        }

        foreach ($keyCred in $this.ServicePrincipalRestrictions.KeyCredentials)
        {
            $newItem = @{
                restrictForAppsCreatedAfterDateTime = $keyCred.RestrictForAppsCreatedAfterDateTime
                restrictionType                     = $keyCred.RestrictionType
                state                               = $keyCred.State
            }
            if ($null -ne $keyCred.MaxLifetime)
            {
                $newItem.Add('maxLifetime', $keyCred.MaxLifetime.ToString())
            }
            if ($null -ne $keyCred.CertificateBasedApplicationConfigurationIds -and $keyCred.CertificateBasedApplicationConfigurationIds.Count -gt 0)
            {
                $newItem.Add('certificateBasedApplicationConfigurationIds', [System.String[]]$keyCred.CertificateBasedApplicationConfigurationIds)
            }
            $spnRestrictionsValue.keyCredentials += $newItem
        }

        $setParameters.Remove('ServicePrincipalRestrictions') | Out-Null
        $setParameters.servicePrincipalRestrictions = $spnRestrictionsValue
        $setParameters.Remove('IsSingleInstance') | Out-Null

        Write-Verbose -Message 'Updating the Default App Management Policy'
        Update-MgBetaPolicyDefaultAppManagementPolicy -BodyParameter $setParameters
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
            [array] $exportedInstances = Get-MgBetaPolicyDefaultAppManagementPolicy -ErrorAction Stop

            $i = 1
            $dscContent = [System.Text.StringBuilder]::new()
            if ($exportedInstances.Length -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }
            foreach ($config in $exportedInstances)
            {
                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }

                $displayedKey = $config.DisplayName
                Write-M365DSCHost -Message "    |---[$i/$($exportedInstances.Count)] $displayedKey" -DeferWrite
                $params = @{
                    IsSingleInstance      = 'Yes'
                    Credential            = $this.Credential
                    ApplicationId         = $this.ApplicationId
                    TenantId              = $this.TenantId
                    CertificateThumbprint = $this.CertificateThumbprint
                    CertificatePath       = $this.CertificatePath
                    CertificatePassword   = $this.CertificatePassword
                    ManagedIdentity       = $this.ManagedIdentity
                    AccessTokens          = $this.AccessTokens
                }

                $this.ExportedInstance = $config
                $Results = $this.GetForExport($Params)
                if ($null -ne $Results.ApplicationRestrictions)
                {
                    $complexMapping = @(
                        @{
                            Name            = 'ApplicationRestrictions'
                            CimInstanceName = 'AADTenantAppManagementPolicyRestrictions'
                            IsRequired      = $False
                        }
                        @{
                            Name            = 'PasswordCredentials'
                            CimInstanceName = 'AADTenantAppManagementPolicyRestrictionsCredential'
                            IsRequired      = $False
                        }
                        @{
                            Name            = 'KeyCredentials'
                            CimInstanceName = 'AADTenantAppManagementPolicyRestrictionsCredential'
                            IsRequired      = $False
                        }
                    )
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.ApplicationRestrictions `
                        -CIMInstanceName 'AADTenantAppManagementPolicyRestrictions' `
                        -ComplexTypeMapping $complexMapping

                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.ApplicationRestrictions = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('ApplicationRestrictions') | Out-Null
                    }
                }
                if ($null -ne $Results.ServicePrincipalRestrictions)
                {
                    $complexMapping = @(
                        @{
                            Name            = 'ServicePrincipalRestrictions'
                            CimInstanceName = 'AADTenantAppManagementPolicyRestrictions'
                            IsRequired      = $False
                        }
                        @{
                            Name            = 'PasswordCredentials'
                            CimInstanceName = 'AADTenantAppManagementPolicyRestrictionsCredential'
                            IsRequired      = $False
                        }
                        @{
                            Name            = 'KeyCredentials'
                            CimInstanceName = 'AADTenantAppManagementPolicyRestrictionsCredential'
                            IsRequired      = $False
                        }
                    )
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.ServicePrincipalRestrictions `
                        -CIMInstanceName 'AADTenantAppManagementPolicyRestrictions' `
                        -ComplexTypeMapping $complexMapping

                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.ServicePrincipalRestrictions = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('ServicePrincipalRestrictions') | Out-Null
                    }
                }
                $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                    -ConnectionMode $ConnectionMode `
                    -ModulePath $this.GetModulePath() `
                    -Results $Results `
                    -Credential $this.Credential `
                    -NoEscape @('ApplicationRestrictions', 'ServicePrincipalRestrictions', 'KeyCredentials', 'PasswordCredentials')
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
            PostProcessing = {
                param($DesiredValues, $CurrentValues, $ValuesToCheck, $ignore)
                foreach ($keyCred in $DesiredValues.ApplicationRestrictions.KeyCredentials)
                {
                    if (-not [System.String]::IsNullOrWhiteSpace($keyCred.MaxLifetime))
                    {
                        $keyCred.MaxLifetime = $keyCred.MaxLifetime.Replace("T0H0M0S", "")
                    }
                }
                foreach ($passwordCred in $DesiredValues.ApplicationRestrictions.PasswordCredentials)
                {
                    if (-not [System.String]::IsNullOrWhiteSpace($passwordCred.MaxLifetime))
                    {
                        $passwordCred.MaxLifetime = $passwordCred.MaxLifetime.Replace("T0H0M0S", "")
                    }
                }
                foreach ($keyCred in $DesiredValues.ServicePrincipalRestrictions.KeyCredentials)
                {
                    if (-not [System.String]::IsNullOrWhiteSpace($keyCred.MaxLifetime))
                    {
                        $keyCred.MaxLifetime = $keyCred.MaxLifetime.Replace("T0H0M0S", "")
                    }
                }
                foreach ($passwordCred in $DesiredValues.ServicePrincipalRestrictions.PasswordCredentials)
                {
                    if (-not [System.String]::IsNullOrWhiteSpace($passwordCred.MaxLifetime))
                    {
                        $passwordCred.MaxLifetime = $passwordCred.MaxLifetime.Replace("T0H0M0S", "")
                    }
                }
                foreach ($keyCred in $CurrentValues.ApplicationRestrictions.KeyCredentials)
                {
                    if (-not [System.String]::IsNullOrWhiteSpace($keyCred.MaxLifetime))
                    {
                        $keyCred.MaxLifetime = $keyCred.MaxLifetime.Replace("T0H0M0S", "")
                    }
                }
                foreach ($passwordCred in $CurrentValues.ApplicationRestrictions.PasswordCredentials)
                {
                    if (-not [System.String]::IsNullOrWhiteSpace($passwordCred.MaxLifetime))
                    {
                        $passwordCred.MaxLifetime = $passwordCred.MaxLifetime.Replace("T0H0M0S", "")
                    }
                }
                foreach ($keyCred in $CurrentValues.ServicePrincipalRestrictions.KeyCredentials)
                {
                    if (-not [System.String]::IsNullOrWhiteSpace($keyCred.MaxLifetime))
                    {
                        $keyCred.MaxLifetime = $keyCred.MaxLifetime.Replace("T0H0M0S", "")
                    }
                }
                foreach ($passwordCred in $CurrentValues.ServicePrincipalRestrictions.PasswordCredentials)
                {
                    if (-not [System.String]::IsNullOrWhiteSpace($passwordCred.MaxLifetime))
                    {
                        $passwordCred.MaxLifetime = $passwordCred.MaxLifetime.Replace("T0H0M0S", "")
                    }
                }
                return [System.Tuple[Hashtable, Hashtable, Hashtable]]::new($DesiredValues, $CurrentValues, $ValuesToCheck)
            }
        }
    }

    hidden [AADTenantAppManagementPolicy] AsResult([System.Object] $Values)
    {
        if ($Values -is [AADTenantAppManagementPolicy])
        {
            return $Values
        }

        $result = [AADTenantAppManagementPolicy]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}

class MSFT_AADTenantAppManagementPolicyRestrictions
{
    [DscProperty()]
    [System.ComponentModel.Description('Collection of keyCredential restrictions settings to be applied to an application or service principal.')]
    [MSFT_AADTenantAppManagementPolicyRestrictionsCredential[]] $KeyCredentials

    [DscProperty()]
    [System.ComponentModel.Description('Collection of password restrictions settings to be applied to an application or service principal.')]
    [MSFT_AADTenantAppManagementPolicyRestrictionsCredential[]] $PasswordCredentials
}

class MSFT_AADTenantAppManagementPolicyRestrictionsCredential
{
    [DscProperty()]
    [System.ComponentModel.Description('Collection of GUIDs of certificateBasedApplicationConfiguration objects that represent trusted certificate authorities. Used when restrictionType is set to trustedCertificateAuthority for keyCredentials.')]
    [System.String[]] $CertificateBasedApplicationConfigurationIds

    [DscProperty()]
    [System.ComponentModel.Description('String value that indicates the maximum lifetime for password expiration, defined as an ISO 8601 duration. For example, P4DT12H30M5S represents four days, 12 hours, 30 minutes, and five seconds. This property is required when restrictionType is set to passwordLifetime.')]
    [System.String] $MaxLifetime

    [DscProperty()]
    [System.ComponentModel.Description('Specifies the date from which the policy restriction applies to newly created applications. For existing applications, the enforcement date can be retroactively applied.')]
    [System.String] $RestrictForAppsCreatedAfterDateTime

    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('The type of restriction being applied. The possible values are: passwordAddition, passwordLifetime, symmetricKeyAddition, symmetricKeyLifetime, customPasswordAddition, asymmetricKeyLifetime, trustedCertificateAuthority, and unknownFutureValue. Each value of restrictionType can be used only once per policy.')]
    [System.String] $RestrictionType

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether the restriction is evaluated. The possible values are: enabled, disabled, unknownFutureValue. If enabled, the restriction is evaluated. If disabled, the restriction isn''t evaluated or enforced.')]
    [System.String] $State
}
