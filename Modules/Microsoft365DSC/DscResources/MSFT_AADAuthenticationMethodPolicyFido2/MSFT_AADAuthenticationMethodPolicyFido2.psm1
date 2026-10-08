using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class AADAuthenticationMethodPolicyFido2 : M365DSCResourceBase
{
    [DscProperty()]
    [System.ComponentModel.Description('Determines whether attestation must be enforced for FIDO2 security key registration.')]
    [System.Nullable[System.Boolean]] $IsAttestationEnforced

    [DscProperty()]
    [System.ComponentModel.Description('Determines if users can register new FIDO2 security keys.')]
    [System.Nullable[System.Boolean]] $IsSelfServiceRegistrationAllowed

    [DscProperty()]
    [System.ComponentModel.Description('Controls whether key restrictions are enforced on FIDO2 security keys, either allowing or disallowing certain key types as defined by Authenticator Attestation GUID (AAGUID), an identifier that indicates the type (e.g. make and model) of the authenticator.')]
    [MSFT_MicrosoftGraphFido2KeyRestrictions] $KeyRestrictions

    [DscProperty()]
    [System.ComponentModel.Description('Displayname of the groups of users that are excluded from a policy.')]
    [MSFT_AADAuthenticationMethodPolicyFido2ExcludeTarget[]] $ExcludeTargets

    [DscProperty()]
    [System.ComponentModel.Description('Displayname of the groups of users that are included from a policy.')]
    [MSFT_AADAuthenticationMethodPolicyFido2IncludeTarget[]] $IncludeTargets

    [DscProperty()]
    [System.ComponentModel.Description('Passkey profiles configuration for FIDO2 authentication.')]
    [MSFT_AADAuthenticationMethodPolicyFido2PasskeyProfile[]] $PasskeyProfiles

    [DscProperty()]
    [System.ComponentModel.Description('The state of the policy. Possible values are: enabled, disabled.')]
    [ValidateSet('enabled', 'disabled')]
    [System.String] $State

    [DscProperty(Key)]
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

    [AADAuthenticationMethodPolicyFido2] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [AADAuthenticationMethodPolicyFido2]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting the Azure AD Authentication Method Policy Fido2 with Id {$($this.Id)}"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.Id -ne $this.Id)
            {
                $null = $this.Connect('MicrosoftGraph')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullResult = $this.GetBoundParameters()
                $nullResult.Ensure = 'Absent'

                $getValue = $null
                #region resource generator code
                $getValue = Get-MgBetaPolicyAuthenticationMethodPolicyAuthenticationMethodConfiguration -AuthenticationMethodConfigurationId $this.Id -ErrorAction SilentlyContinue

                #endregion
                if ($null -eq $getValue)
                {
                    Write-Verbose -Message "Could not find an Azure AD Authentication Method Policy Fido2 with id {$($this.id)}"
                    return $this.AsResult($nullResult)
                }
            }
            else
            {
                $getValue = $this.ExportedInstance
            }
            $resolvedId = $getValue.Id
            Write-Verbose -Message "An Azure AD Authentication Method Policy Fido2 with Id {$($resolvedId)} was found."

            #region resource generator code
            Write-Verbose 'Processing KeyRestrictions'
            $complexKeyRestrictions = [ordered]@{}
            $complexKeyRestrictions.Add('AaGuids', $getValue.keyRestrictions.aaGuids)
            if ($null -ne $getValue.keyRestrictions.enforcementType)
            {
                $complexKeyRestrictions.Add('EnforcementType', $getValue.keyRestrictions.enforcementType)
            }
            $complexKeyRestrictions.Add('IsEnforced', $getValue.keyRestrictions.isEnforced)
            if ($complexKeyRestrictions.values.Where({ $null -ne $_ }).Count -eq 0)
            {
                $complexKeyRestrictions = $null
            }

            Write-Verbose 'Processing ExcludeTargets'
            $complexExcludeTargets = @()
            foreach ($currentExcludeTargets in $getValue.excludeTargets)
            {
                $myExcludeTargets = [ordered]@{}
                if ($currentExcludeTargets.id -ne 'all_users')
                {
                    $myExcludeTargetsDisplayName = Get-M365DSCGroupDisplayNameById -GroupId $currentExcludeTargets.id
                    if ($null -eq $myExcludeTargetsDisplayName)
                    {
                        continue
                    }
                    $myExcludeTargets.Add('Id', $myExcludeTargetsDisplayName)
                }
                else
                {
                    $myExcludeTargets.Add('Id', $currentExcludeTargets.id)
                }

                if ($null -ne $currentExcludeTargets.targetType)
                {
                    $myExcludeTargets.Add('TargetType', $currentExcludeTargets.targetType)
                }

                if ($null -ne $currentExcludeTargets.isRegistrationRequired)
                {
                    $myExcludeTargets.Add('IsRegistrationRequired', [System.Convert]::ToBoolean($currentExcludeTargets.isRegistrationRequired))
                }

                if ($null -ne $currentExcludeTargets.allowedPasskeyProfiles)
                {
                    $myExcludeTargets.Add('AllowedPasskeyProfiles', [string[]]$currentExcludeTargets.allowedPasskeyProfiles)
                }

                if ($myExcludeTargets.values.Where({ $null -ne $_ }).Count -gt 0)
                {
                    $complexExcludeTargets += $myExcludeTargets
                }
            }
            #endregion

            Write-Verbose 'Processing IncludeTargets'
            $complexIncludeTargets = @()
            foreach ($currentIncludeTargets in $getValue.includeTargets)
            {
                $myIncludeTargets = [ordered]@{}
                if ($currentIncludeTargets.id -ne 'all_users')
                {
                    $myIncludeTargetsDisplayName = Get-M365DSCGroupDisplayNameById -GroupId $currentIncludeTargets.id
                    if ($null -eq $myIncludeTargetsDisplayName)
                    {
                        continue
                    }
                    $myIncludeTargets.Add('Id', $myIncludeTargetsDisplayName)
                }
                else
                {
                    $myIncludeTargets.Add('Id', $currentIncludeTargets.id)
                }

                if ($null -ne $currentIncludeTargets.targetType)
                {
                    $myIncludeTargets.Add('TargetType', $currentIncludeTargets.targetType)
                }

                if ($null -ne $currentIncludeTargets.isRegistrationRequired)
                {
                    $myIncludeTargets.Add('IsRegistrationRequired', [System.Convert]::ToBoolean($currentIncludeTargets.isRegistrationRequired))
                }

                if ($null -ne $currentIncludeTargets.allowedPasskeyProfiles)
                {
                    $myIncludeTargets.Add('AllowedPasskeyProfiles', [string[]]$currentIncludeTargets.allowedPasskeyProfiles)
                }

                if ($myIncludeTargets.values.Where({ $null -ne $_ }).Count -gt 0)
                {
                    $complexIncludeTargets += $myIncludeTargets
                }
            }

            Write-Verbose 'Processing Passkey profiles'
            $complexPasskeyProfiles = @()
            foreach ($currentPasskeyProfiles in $getValue.passkeyProfiles){
                $myPasskeyProfiles = @{}
                $myPasskeyProfiles.Add('Id', $currentPasskeyProfiles.id)
                $myPasskeyProfiles.Add('Name', $currentPasskeyProfiles.name)
                if ($null -ne $currentPasskeyProfiles.passkeyTypes)
                {
                    # Convert array to single comma-separated string if needed
                    if ($currentPasskeyProfiles.passkeyTypes -is [Array])
                    {
                        $myPasskeyProfiles.Add('PasskeyTypes', $currentPasskeyProfiles.passkeyTypes -join ',')
                    }
                    else
                    {
                        $myPasskeyProfiles.Add('PasskeyTypes', $currentPasskeyProfiles.passkeyTypes)
                    }
                }
                if ($null -ne $currentPasskeyProfiles.attestationEnforcement)
                {
                    $myPasskeyProfiles.Add('AttestationEnforcement', $currentPasskeyProfiles.attestationEnforcement)
                }
                if ($null -ne $currentPasskeyProfiles.keyRestrictions)
                {
                    $KeyRestrictionsForProfile = @{
                        AaGuids = $currentPasskeyProfiles.keyRestrictions.aaGuids
                        IsEnforced = $currentPasskeyProfiles.keyRestrictions.isEnforced
                    }
                    if ($null -ne $currentPasskeyProfiles.keyRestrictions.enforcementType)
                    {
                        $KeyRestrictionsForProfile['EnforcementType'] = $currentPasskeyProfiles.keyRestrictions.enforcementType.ToString()
                    }
                    $myPasskeyProfiles.Add('KeyRestrictions', $KeyRestrictionsForProfile)
                }
                if ($myPasskeyProfiles.values.Where({ $null -ne $_ }).Count -gt 0)
                {
                    $complexPasskeyProfiles += $myPasskeyProfiles
                }
            }

            $results = @{
                #region resource generator code
                IsAttestationEnforced            = $getValue.isAttestationEnforced
                IsSelfServiceRegistrationAllowed = $getValue.isSelfServiceRegistrationAllowed
                KeyRestrictions                  = $complexKeyRestrictions
                ExcludeTargets                   = $complexExcludeTargets
                IncludeTargets                   = $complexIncludeTargets
                PasskeyProfiles                  = $complexPasskeyProfiles
                State                            = $getValue.State
                Id                               = $getValue.Id
                Ensure                           = 'Present'
                Credential                       = $this.Credential
                ApplicationId                    = $this.ApplicationId
                TenantId                         = $this.TenantId
                ApplicationSecret                = $this.ApplicationSecret
                CertificateThumbprint            = $this.CertificateThumbprint
                CertificatePath                  = $this.CertificatePath
                CertificatePassword              = $this.CertificatePassword
                ManagedIdentity                  = $this.ManagedIdentity
                AccessTokens                     = $this.AccessTokens
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

        Write-Verbose -Message "Setting the Azure AD Authentication Method Policy Fido2 with Id {$($this.Id)}"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $currentInstance = $this.Get().ToHashtable()
        $boundParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()

        if ($this.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Updating the Azure AD Authentication Method Policy Fido2 with Id {$($currentInstance.Id)}"

            $updateParameters = Rename-M365DSCCimInstanceParameter -Properties $boundParameters

            Update-M365DSCAuthenticationTargets -Targets $updateParameters.ExcludeTargets
            Update-M365DSCAuthenticationTargets -Targets $updateParameters.IncludeTargets

            if ($updateParameters.ContainsKey('PasskeyProfiles'))
            {
                # Ensure passkeyTypes is handled as a single string value for API compatibility
                foreach ($passkeyProfile in $updateParameters.PasskeyProfiles)
                {
                    if ($null -ne $passkeyProfile.passkeyTypes -and $passkeyProfile.passkeyTypes -is [Array])
                    {
                        $passkeyProfile.passkeyTypes = $passkeyProfile.passkeyTypes -join ','
                    }
                }
            }

            #region resource generator code
            Write-Verbose -Message "Parameters:`r`n$(ConvertTo-Json $updateParameters -Depth 10)"
            $updateParameters.Add('@odata.type', '#microsoft.graph.fido2AuthenticationMethodConfiguration')
            Update-MgBetaPolicyAuthenticationMethodPolicyAuthenticationMethodConfiguration `
                -AuthenticationMethodConfigurationId $currentInstance.Id `
                -BodyParameter $updateParameters
            #endregion
        }
        elseif ($this.Ensure -eq 'Absent' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Removing the Azure AD Authentication Method Policy Fido2 with Id {$($currentInstance.Id)}"
            #region resource generator code
            Remove-MgBetaPolicyAuthenticationMethodPolicyAuthenticationMethodConfiguration -AuthenticationMethodConfigurationId $currentInstance.Id
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
            [array]$getValue = Get-MgBetaPolicyAuthenticationMethodPolicyAuthenticationMethodConfiguration `
                -AuthenticationMethodConfigurationId Fido2 `
                -ErrorAction Stop | Where-Object -FilterScript { $null -ne $_.Id }
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
                Write-M365DSCHost -Message "    |---[$i/$($getValue.Count)] $displayedKey" -DeferWrite
                $params = @{
                    Id                    = $config.Id
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
                if ($null -ne $Results.KeyRestrictions)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.KeyRestrictions `
                        -CIMInstanceName 'MicrosoftGraphFido2KeyRestrictions'
                    if (-Not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.KeyRestrictions = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('KeyRestrictions') | Out-Null
                    }
                }
                if ($null -ne $Results.ExcludeTargets)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.ExcludeTargets `
                        -CIMInstanceName 'AADAuthenticationMethodPolicyFido2ExcludeTarget'
                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.ExcludeTargets = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('ExcludeTargets') | Out-Null
                    }
                }
                if ($null -ne $Results.IncludeTargets)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.IncludeTargets `
                        -CIMInstanceName 'AADAuthenticationMethodPolicyFido2IncludeTarget'
                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.IncludeTargets = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('IncludeTargets') | Out-Null
                    }
                }
                if ($null -ne $Results.PasskeyProfiles)
                {
                    $complexMapping = @(
                        @{
                            Name            = 'PasskeyProfiles'
                            CimInstanceName = 'AADAuthenticationMethodPolicyFido2PasskeyProfile'
                            IsRequired      = $False
                        }
                        @{
                            Name            = 'KeyRestrictions'
                            CimInstanceName = 'MicrosoftGraphFido2KeyRestrictions'
                            IsRequired      = $False
                        }
                    )
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.PasskeyProfiles `
                        -CIMInstanceName 'AADAuthenticationMethodPolicyFido2PasskeyProfile' `
                        -ComplexTypeMapping $complexMapping `
                        -Whitespace ''
                    if (-Not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.PasskeyProfiles = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('PasskeyProfiles') | Out-Null
                    }
                }

                $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                    -ConnectionMode $ConnectionMode `
                    -ModulePath $this.GetModulePath() `
                    -Results $Results `
                    -Credential $this.Credential `
                    -NoEscape @('KeyRestrictions', 'ExcludeTargets', 'IncludeTargets', 'PasskeyProfiles') `

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

    hidden [AADAuthenticationMethodPolicyFido2] AsResult([System.Object] $Values)
    {
        if ($Values -is [AADAuthenticationMethodPolicyFido2])
        {
            return $Values
        }

        $result = [AADAuthenticationMethodPolicyFido2]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}

class MSFT_MicrosoftGraphFido2KeyRestrictions
{
    [DscProperty()]
    [System.ComponentModel.Description('A collection of Authenticator Attestation GUIDs. AADGUIDs define key types and manufacturers.')]
    [System.String[]] $AaGuids

    [DscProperty()]
    [System.ComponentModel.Description('Enforcement type. Possible values are: allow, block.')]
    [ValidateSet('allow', 'block', 'unknownFutureValue')]
    [System.String] $EnforcementType

    [DscProperty()]
    [System.ComponentModel.Description('Determines if the configured key enforcement is enabled.')]
    [System.Nullable[System.Boolean]] $IsEnforced
}

class MSFT_AADAuthenticationMethodPolicyFido2ExcludeTarget
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The object identifier of an Azure AD group.')]
    [System.String] $Id

    [DscProperty(Key)]
    [System.ComponentModel.Description('The type of the authentication method target. Possible values are: group and unknownFutureValue.')]
    [ValidateSet('group', 'unknownFutureValue')]
    [System.String] $TargetType

    [DscProperty()]
    [System.ComponentModel.Description('Determines if registration is required for the authentication method.')]
    [System.Nullable[System.Boolean]] $IsRegistrationRequired

    [DscProperty()]
    [System.ComponentModel.Description('Collection of allowed passkey profile IDs for this target.')]
    [System.String[]] $AllowedPasskeyProfiles
}

class MSFT_AADAuthenticationMethodPolicyFido2IncludeTarget
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The object identifier of an Azure AD group.')]
    [System.String] $Id

    [DscProperty(Key)]
    [System.ComponentModel.Description('The type of the authentication method target. Possible values are: group and unknownFutureValue.')]
    [ValidateSet('group', 'unknownFutureValue')]
    [System.String] $TargetType

    [DscProperty()]
    [System.ComponentModel.Description('Determines if registration is required for the authentication method.')]
    [System.Nullable[System.Boolean]] $IsRegistrationRequired

    [DscProperty()]
    [System.ComponentModel.Description('Collection of allowed passkey profile IDs for this target.')]
    [System.String[]] $AllowedPasskeyProfiles
}

class MSFT_AADAuthenticationMethodPolicyFido2PasskeyProfile
{
    [DscProperty()]
    [System.ComponentModel.Description('The unique identifier for the passkey profile.')]
    [System.String] $Id

    [DscProperty(Key)]
    [System.ComponentModel.Description('The display name for the passkey profile.')]
    [System.String] $Name

    [DscProperty()]
    [System.ComponentModel.Description('The passkey types supported by this profile.')]
    [ValidateSet('deviceBound', 'deviceBound,synced', 'crossDevice', 'synced')]
    [System.String] $PasskeyTypes

    [DscProperty()]
    [System.ComponentModel.Description('The attestation enforcement level for this profile.')]
    [ValidateSet('disabled', 'registrationOnly', 'registrationAndSignIn')]
    [System.String] $AttestationEnforcement

    [DscProperty()]
    [System.ComponentModel.Description('Key restrictions for this passkey profile.')]
    [MSFT_MicrosoftGraphFido2KeyRestrictions] $KeyRestrictions
}
