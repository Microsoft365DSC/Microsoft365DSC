using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class AADAuthenticationMethodPolicy : M365DSCResourceBase
{
    [DscProperty()]
    [System.ComponentModel.Description('Days before the user will be asked to reconfirm their method.')]
    [System.Nullable[System.UInt32]] $ReconfirmationInDays

    [DscProperty()]
    [System.ComponentModel.Description('Enforce registration at sign-in time. This property can be used to remind users to set up targeted authentication methods.')]
    [MSFT_MicrosoftGraphregistrationEnforcement] $RegistrationEnforcement

    [DscProperty()]
    [System.ComponentModel.Description('Allows users to report suspicious activities if they receive an authentication request that they did not initiate.')]
    [MSFT_MicrosoftGraphreportSuspiciousActivitySettings] $ReportSuspiciousActivitySettings

    [DscProperty()]
    [System.ComponentModel.Description('Prompt users with their most-preferred credential for multifactor authentication.')]
    [MSFT_MicrosoftGraphsystemCredentialPreferences] $SystemCredentialPreferences

    [DscProperty(Key)]
    [System.ComponentModel.Description('Only valid value is ''Yes''.')]
    [ValidateSet('Yes')]
    [System.String] $IsSingleInstance

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

    [AADAuthenticationMethodPolicy] Get()
    {
        $DisplayName = $null
        if ($this.RequiresPowerShellCore())
        {
            $remote = [AADAuthenticationMethodPolicy]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of Authentication Method Policy '$DisplayName'"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.DisplayName -ne $DisplayName)
            {
                $null = $this.Connect('MicrosoftGraph')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $getValue = Get-MgBetaPolicyAuthenticationMethodPolicy -ErrorAction Stop
            }
            else
            {
                $getValue = $this.ExportedInstance
            }
            Write-Verbose -Message "An Azure AD Authentication Method Policy was found."

            #region resource generator code
            $complexRegistrationEnforcement = [ordered]@{}
            $complexAuthenticationMethodsRegistrationCampaign = [ordered]@{}
            $complexExcludeTargets = @()
            foreach ($currentExcludeTargets in $getValue.registrationEnforcement.authenticationMethodsRegistrationCampaign.excludeTargets)
            {
                $myExcludeTargets = [ordered]@{}
                if ($null -ne $currentExcludeTargets.targetType)
                {
                    $myExcludeTargets.Add('TargetType', $currentExcludeTargets.targetType)
                    if ($myExcludeTargets.TargetType -eq 'Group')
                    {
                        $myExcludeTargetsDisplayName = Get-M365DSCGroupDisplayNameById -GroupId $currentExcludeTargets.Id
                        if ($null -eq $myExcludeTargetsDisplayName)
                        {
                            continue
                        }
                        $myExcludeTargets.Add('Id', $myExcludeTargetsDisplayName)
                    }
                    elseif ($myExcludeTargets.TargetType -eq 'User')
                    {
                        $myExcludeTargetsUserPrincipalName = Get-M365DSCUserPrincipalNameById -UserId $currentExcludeTargets.Id
                        if ($null -eq $myExcludeTargetsUserPrincipalName)
                        {
                            continue
                        }
                        $myExcludeTargets.Add('Id', $myExcludeTargetsUserPrincipalName)
                    }
                }
                if ($myExcludeTargets.values.Where({ $null -ne $_ }).Count -gt 0)
                {
                    $complexExcludeTargets += $myExcludeTargets
                }
            }
            $complexAuthenticationMethodsRegistrationCampaign.Add('ExcludeTargets', $complexExcludeTargets)
            $complexIncludeTargets = @()
            foreach ($currentIncludeTargets in $getValue.registrationEnforcement.authenticationMethodsRegistrationCampaign.includeTargets)
            {
                $myIncludeTargets = [ordered]@{}
                if ($currentIncludeTargets.id -ne "all_users")
                {
                    $myIncludeTargetsDisplayName = $null
                    if ($currentIncludeTargets.targetType -eq 'Group')
                    {
                        $myIncludeTargetsDisplayName = Get-M365DSCGroupDisplayNameById -GroupId $currentIncludeTargets.Id
                    }
                    elseif ($currentIncludeTargets.targetType -eq 'User')
                    {
                        $myIncludeTargetsDisplayName = Get-M365DSCUserPrincipalNameById -UserId $currentIncludeTargets.Id
                    }
                    if (-not [System.String]::IsNullOrEmpty($myIncludeTargetsDisplayName))
                    {
                        $myIncludeTargets.Add('Id', $myIncludeTargetsDisplayName)
                    }
                }
                else
                {
                    $myIncludeTargets.Add('Id', $currentIncludeTargets.id)
                }
                $myIncludeTargets.Add('TargetedAuthenticationMethod', $currentIncludeTargets.targetedAuthenticationMethod)
                if ($null -ne $currentIncludeTargets.targetType)
                {
                    $myIncludeTargets.Add('TargetType', $currentIncludeTargets.targetType)
                }
                if ($myIncludeTargets.values.Where({ $null -ne $_ }).Count -gt 0)
                {
                    $complexIncludeTargets += $myIncludeTargets
                }
            }
            $complexAuthenticationMethodsRegistrationCampaign.Add('IncludeTargets', $complexIncludeTargets)
            $complexAuthenticationMethodsRegistrationCampaign.Add('SnoozeDurationInDays', $getValue.registrationEnforcement.authenticationMethodsRegistrationCampaign.snoozeDurationInDays)
            if ($null -ne $getValue.registrationEnforcement.authenticationMethodsRegistrationCampaign.state)
            {
                $complexAuthenticationMethodsRegistrationCampaign.Add('State', $getValue.registrationEnforcement.authenticationMethodsRegistrationCampaign.state)
            }
            if ($complexAuthenticationMethodsRegistrationCampaign.values.Where({ $null -ne $_ }).Count -eq 0)
            {
                $complexAuthenticationMethodsRegistrationCampaign = $null
            }
            $complexRegistrationEnforcement.Add('AuthenticationMethodsRegistrationCampaign', $complexAuthenticationMethodsRegistrationCampaign)
            if ($complexRegistrationEnforcement.values.Where({ $null -ne $_ }).Count -eq 0)
            {
                $complexRegistrationEnforcement = $null
            }

            $complexReportSuspiciousActivitySettings = [ordered]@{}
            $newComplexIncludeTarget = [ordered]@{}
            if ($getValue.ReportSuspiciousActivitySettings.IncludeTarget.id -ne "all_users")
            {
                $includeTargetDisplayName = $null
                if ($getValue.ReportSuspiciousActivitySettings.IncludeTarget.targetType -eq 'Group')
                {
                    $includeTargetDisplayName = Get-M365DSCGroupDisplayNameById -GroupId $getValue.ReportSuspiciousActivitySettings.IncludeTarget.Id
                    if ($null -ne $includeTargetDisplayName)
                    {
                        $newComplexIncludeTarget.Add('Id', $includeTargetDisplayName)
                    }
                }
            }
            else
            {
                $newComplexIncludeTarget.Add('Id', $getValue.ReportSuspiciousActivitySettings.IncludeTarget.id)
            }
            if ($null -ne $getValue.ReportSuspiciousActivitySettings.IncludeTarget.targetType)
            {
                $newComplexIncludeTarget.Add('TargetType', $getValue.ReportSuspiciousActivitySettings.IncludeTarget.targetType)
            }
            $complexReportSuspiciousActivitySettings.Add('IncludeTarget', $newComplexIncludeTarget)

            if ($null -ne $getValue.ReportSuspiciousActivitySettings.state)
            {
                $complexReportSuspiciousActivitySettings.Add('State', $getValue.ReportSuspiciousActivitySettings.state)
            }
            if ($null -ne $getValue.ReportSuspiciousActivitySettings.VoiceReportingCode)
            {
                $complexReportSuspiciousActivitySettings.Add('VoiceReportingCode', $getValue.ReportSuspiciousActivitySettings.VoiceReportingCode)
            }
            if ($complexReportSuspiciousActivitySettings.values.Where({ $null -ne $_ }).Count -eq 0)
            {
                $complexReportSuspiciousActivitySettings = $null
            }

            $complexSystemCredentialPreferences = [ordered]@{}
            $complexExcludeTargets = @()
            foreach ($currentExcludeTargets in $getValue.SystemCredentialPreferences.excludeTargets)
            {
                $myExcludeTargets = [ordered]@{}
                if ($currentExcludeTargets.id -ne "all_users")
                {
                    if ($currentExcludeTargets.targetType -eq 'Group')
                    {
                        $myExcludeTargetsDisplayName = Get-M365DSCGroupDisplayNameById -GroupId $currentExcludeTargets.Id
                        if ($null -eq $myExcludeTargetsDisplayName)
                        {
                            continue
                        }
                        $myExcludeTargets.Add('Id', $myExcludeTargetsDisplayName)
                    }
                }
                else
                {
                    $myExcludeTargets.Add('Id', $currentExcludeTargets.id)
                }
                if ($null -ne $currentExcludeTargets.targetType)
                {
                    $myExcludeTargets.Add('TargetType', $currentExcludeTargets.targetType)
                }
                if ($myExcludeTargets.values.Where({ $null -ne $_ }).Count -gt 0)
                {
                    $complexExcludeTargets += $myExcludeTargets
                }
            }
            $complexSystemCredentialPreferences.Add('ExcludeTargets', $complexExcludeTargets)
            $complexIncludeTargets = @()
            foreach ($currentIncludeTargets in $getValue.SystemCredentialPreferences.includeTargets)
            {
                $myIncludeTargets = [ordered]@{}
                if ($currentIncludeTargets.id -ne "all_users")
                {
                    if ($currentIncludeTargets.targetType -eq 'Group')
                    {
                        $myIncludeTargetsDisplayName = Get-M365DSCGroupDisplayNameById -GroupId $currentIncludeTargets.Id
                        if ($null -eq $myIncludeTargetsDisplayName)
                        {
                            continue
                        }
                        $myIncludeTargets.Add('Id', $myIncludeTargetsDisplayName)
                    }
                }
                else
                {
                    $myIncludeTargets.Add('Id', $currentIncludeTargets.id)
                }
                if ($null -ne $currentIncludeTargets.targetType)
                {
                    $myIncludeTargets.Add('TargetType', $currentIncludeTargets.targetType)
                }
                if ($myIncludeTargets.values.Where({ $null -ne $_ }).Count -gt 0)
                {
                    $complexIncludeTargets += $myIncludeTargets
                }
            }
            $complexSystemCredentialPreferences.Add('IncludeTargets', $complexIncludeTargets)
            if ($null -ne $getValue.SystemCredentialPreferences.state)
            {
                $complexSystemCredentialPreferences.Add('State', $getValue.SystemCredentialPreferences.state)
            }
            if ($complexSystemCredentialPreferences.values.Where({ $null -ne $_ }).Count -eq 0)
            {
                $complexSystemCredentialPreferences = $null
            }
            #endregion

            $results = @{
                #region resource generator code
                ReconfirmationInDays             = $getValue.ReconfirmationInDays
                RegistrationEnforcement          = $complexRegistrationEnforcement
                ReportSuspiciousActivitySettings = $complexReportSuspiciousActivitySettings
                SystemCredentialPreferences      = $complexSystemCredentialPreferences
                IsSingleInstance                 = 'Yes'
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
        $DisplayName = $null
        if ($this.RequiresPowerShellCore())
        {
            $null = $this.InvokeInPowerShellCore('Set')
            return
        }

        Write-Verbose -Message "Setting configuration of Authentication Method Policy '$DisplayName'"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $currentInstance = $this.Get().ToHashtable()
        $boundParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()

        Write-Verbose -Message "Updating the Azure AD Authentication Method Policy"

        $updateParameters = Rename-M365DSCCimInstanceParameter -Properties $boundParameters
        Update-M365DSCAuthenticationTargets -Targets $updateParameters.RegistrationEnforcement.AuthenticationMethodsRegistrationCampaign.ExcludeTargets
        Update-M365DSCAuthenticationTargets -Targets $updateParameters.RegistrationEnforcement.AuthenticationMethodsRegistrationCampaign.IncludeTargets
        Update-M365DSCAuthenticationTargets -Targets $updateParameters.ReportSuspiciousActivitySettings.IncludeTarget
        Update-M365DSCAuthenticationTargets -Targets $updateParameters.SystemCredentialPreferences.ExcludeTargets
        Update-M365DSCAuthenticationTargets -Targets $updateParameters.SystemCredentialPreferences.IncludeTargets

        #region resource generator code
        $updateParameters.Remove('IsSingleInstance') | Out-Null
        $updateParameters.Add('@odata.type', '#microsoft.graph.AuthenticationMethodsPolicy')
        Update-MgBetaPolicyAuthenticationMethodPolicy -BodyParameter $updateParameters
        #endregion
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
            [array]$getValue = Get-MgBetaPolicyAuthenticationMethodPolicy -ErrorAction Stop
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

                    Write-M365DSCHost -Message "    |---[$i/$($getValue.Count)] $displayedKey" -DeferWrite
                    $params = @{
                        IsSingleInstance      = 'Yes'
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
                    if ($null -ne $Results.RegistrationEnforcement)
                    {
                        $complexMapping = @(
                            @{
                                Name            = 'RegistrationEnforcement'
                                CimInstanceName = 'MicrosoftGraphRegistrationEnforcement'
                                IsRequired      = $False
                            }
                            @{
                                Name            = 'AuthenticationMethodsRegistrationCampaign'
                                CimInstanceName = 'MicrosoftGraphAuthenticationMethodsRegistrationCampaign'
                                IsRequired      = $False
                            }
                            @{
                                Name            = 'ExcludeTargets'
                                CimInstanceName = 'MicrosoftGraphExcludeTarget'
                                IsRequired      = $False
                            }
                            @{
                                Name            = 'IncludeTargets'
                                CimInstanceName = 'MicrosoftGraphAuthenticationMethodsRegistrationCampaignIncludeTarget'
                                IsRequired      = $False
                            }
                        )
                        $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                            -ComplexObject $Results.RegistrationEnforcement `
                            -CIMInstanceName 'MicrosoftGraphregistrationEnforcement' `
                            -ComplexTypeMapping $complexMapping

                        if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                        {
                            $Results.RegistrationEnforcement = $complexTypeStringResult
                        }
                        else
                        {
                            $Results.Remove('RegistrationEnforcement') | Out-Null
                        }
                    }

                    if ($null -ne $Results.ReportSuspiciousActivitySettings)
                    {
                        $complexMapping = @(
                            @{
                                Name            = 'ReportSuspiciousActivitySettings'
                                CimInstanceName = 'MicrosoftGraphReportSuspiciousActivitySettings'
                                IsRequired      = $False
                            }
                            @{
                                Name            = 'IncludeTarget'
                                CimInstanceName = 'AADAuthenticationMethodPolicyIncludeTarget'
                                IsRequired      = $False
                            }
                        )
                        $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                            -ComplexObject $Results.ReportSuspiciousActivitySettings `
                            -CIMInstanceName 'MicrosoftGraphreportSuspiciousActivitySettings' `
                            -ComplexTypeMapping $complexMapping

                        if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                        {
                            $Results.ReportSuspiciousActivitySettings = $complexTypeStringResult
                        }
                        else
                        {
                            $Results.Remove('ReportSuspiciousActivitySettings') | Out-Null
                        }
                    }

                    if ($null -ne $Results.SystemCredentialPreferences)
                    {
                        $complexMapping = @(
                            @{
                                Name            = 'SystemCredentialPreferences'
                                CimInstanceName = 'MicrosoftGraphSystemCredentialPreferences'
                                IsRequired      = $False
                            }
                            @{
                                Name            = 'ExcludeTargets'
                                CimInstanceName = 'AADAuthenticationMethodPolicyExcludeTarget'
                                IsRequired      = $False
                            }
                            @{
                                Name            = 'IncludeTargets'
                                CimInstanceName = 'AADAuthenticationMethodPolicyIncludeTarget'
                                IsRequired      = $False
                            }
                        )
                        $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                            -ComplexObject $Results.SystemCredentialPreferences `
                            -CIMInstanceName 'MicrosoftGraphsystemCredentialPreferences' `
                            -ComplexTypeMapping $complexMapping

                        if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                        {
                            $Results.SystemCredentialPreferences = $complexTypeStringResult
                        }
                        else
                        {
                            $Results.Remove('SystemCredentialPreferences') | Out-Null
                        }
                    }

                    $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                        -ConnectionMode $ConnectionMode `
                        -ModulePath $this.GetModulePath() `
                        -Results $Results `
                        -Credential $this.Credential `
                        -NoEscape @('RegistrationEnforcement', 'ReportSuspiciousActivitySettings', 'SystemCredentialPreferences')

                    [void]$dscContent.Append($currentDSCBlock)
                    Save-M365DSCPartialExport -Content $currentDSCBlock `
                        -FileName $Global:PartialExportFileName
                }
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

    hidden [AADAuthenticationMethodPolicy] AsResult([System.Object] $Values)
    {
        if ($Values -is [AADAuthenticationMethodPolicy])
        {
            return $Values
        }

        $result = [AADAuthenticationMethodPolicy]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}

class MSFT_MicrosoftGraphregistrationEnforcement
{
    [DscProperty()]
    [System.ComponentModel.Description('Run campaigns to remind users to setup targeted authentication methods.')]
    [MSFT_MicrosoftGraphAuthenticationMethodsRegistrationCampaign] $AuthenticationMethodsRegistrationCampaign
}

class MSFT_MicrosoftGraphreportSuspiciousActivitySettings
{
    [DscProperty()]
    [System.ComponentModel.Description('Group IDs in scope for report suspicious activity.')]
    [MSFT_AADAuthenticationMethodPolicyIncludeTarget] $IncludeTarget

    [DscProperty()]
    [System.ComponentModel.Description('Specifies the state of the reportSuspiciousActivitySettings object.')]
    [ValidateSet('default', 'enabled', 'disabled', 'unknownFutureValue')]
    [System.String] $State

    [DscProperty()]
    [System.ComponentModel.Description('Specifies the number the user enters on their phone to report the MFA prompt as suspicious.')]
    [System.Nullable[System.UInt32]] $VoiceReportingCode
}

class MSFT_MicrosoftGraphsystemCredentialPreferences
{
    [DscProperty()]
    [System.ComponentModel.Description('Users and groups excluded from the preferred authentication method experience of the system.')]
    [MSFT_AADAuthenticationMethodPolicyExcludeTarget[]] $ExcludeTargets

    [DscProperty()]
    [System.ComponentModel.Description('Users and groups included in the preferred authentication method experience of the system.')]
    [MSFT_AADAuthenticationMethodPolicyIncludeTarget[]] $IncludeTargets

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether the feature is enabled or disabled. Possible values are: default, enabled, disabled, unknownFutureValue. The default value is used when the configuration hasn''t been explicitly set, and uses the default behavior of Azure Active Directory for the setting. The default value is disabled.')]
    [ValidateSet('default', 'enabled', 'disabled', 'unknownFutureValue')]
    [System.String] $State
}

class MSFT_MicrosoftGraphAuthenticationMethodsRegistrationCampaign
{
    [DscProperty()]
    [System.ComponentModel.Description('Users and groups of users that are excluded from being prompted to set up the authentication method.')]
    [MSFT_MicrosoftGraphExcludeTarget[]] $ExcludeTargets

    [DscProperty()]
    [System.ComponentModel.Description('Users and groups of users that are prompted to set up the authentication method.')]
    [MSFT_MicrosoftGraphAuthenticationMethodsRegistrationCampaignIncludeTarget[]] $IncludeTargets

    [DscProperty()]
    [System.ComponentModel.Description('Specifies the number of days that the user sees a prompt again if they select ''Not now'' and snoozes the prompt. Minimum 0 days. Maximum: 14 days. If the value is ''0''  The user is prompted during every MFA attempt.')]
    [System.Nullable[System.UInt32]] $SnoozeDurationInDays

    [DscProperty()]
    [System.ComponentModel.Description('Enable or disable the feature. Possible values are: default, enabled, disabled, unknownFutureValue. The default value is used when the configuration hasn''t been explicitly set and uses the default behavior of Azure AD for the setting. The default value is disabled.')]
    [ValidateSet('default', 'enabled', 'disabled', 'unknownFutureValue')]
    [System.String] $State
}

class MSFT_AADAuthenticationMethodPolicyIncludeTarget
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The ID of the entity targeted.')]
    [System.String] $Id

    [DscProperty(Key)]
    [System.ComponentModel.Description('The kind of entity targeted. Possible values are: user, group.')]
    [ValidateSet('user', 'group', 'unknownFutureValue')]
    [System.String] $TargetType
}

class MSFT_AADAuthenticationMethodPolicyExcludeTarget
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The object identifier of an Azure AD group.')]
    [System.String] $Id

    [DscProperty(Key)]
    [System.ComponentModel.Description('The type of the authentication method target. Possible values are: group and unknownFutureValue.')]
    [ValidateSet('user', 'group', 'unknownFutureValue')]
    [System.String] $TargetType
}

class MSFT_MicrosoftGraphExcludeTarget
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The object identifier of an Azure AD user or group.')]
    [System.String] $Id

    [DscProperty(Key)]
    [System.ComponentModel.Description('The type of the authentication method target. Possible values are: user, group, unknownFutureValue.')]
    [ValidateSet('user', 'group', 'unknownFutureValue')]
    [System.String] $TargetType
}

class MSFT_MicrosoftGraphAuthenticationMethodsRegistrationCampaignIncludeTarget
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The object identifier of an Azure AD user or group.')]
    [System.String] $Id

    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('The authentication method that the user is prompted to register. The value can be Fido2 or microsoftAuthenticator.')]
    [ValidateSet('Fido2', 'microsoftAuthenticator')]
    [System.String] $TargetedAuthenticationMethod

    [DscProperty(Key)]
    [System.ComponentModel.Description('The type of the authentication method target. Possible values are: user, group, unknownFutureValue.')]
    [ValidateSet('user', 'group', 'unknownFutureValue')]
    [System.String] $TargetType
}
