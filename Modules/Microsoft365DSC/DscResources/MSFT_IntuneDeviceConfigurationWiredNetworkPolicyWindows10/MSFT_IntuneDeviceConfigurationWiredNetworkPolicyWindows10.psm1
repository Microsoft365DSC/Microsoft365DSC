using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class IntuneDeviceConfigurationWiredNetworkPolicyWindows10 : M365DSCResourceBase
{
    [DscProperty()]
    [System.ComponentModel.Description('Specify the duration for which automatic authentication attempts will be blocked from occurring after a failed authentication attempt.')]
    [System.Nullable[System.UInt32]] $AuthenticationBlockPeriodInMinutes

    [DscProperty()]
    [System.ComponentModel.Description('Specify the authentication method. Possible values are: certificate, usernameAndPassword, derivedCredential. Possible values are: certificate, usernameAndPassword, derivedCredential, unknownFutureValue.')]
    [ValidateSet('certificate', 'usernameAndPassword', 'derivedCredential', 'unknownFutureValue')]
    [System.String] $AuthenticationMethod

    [DscProperty()]
    [System.ComponentModel.Description('Specify the number of seconds for the client to wait after an authentication attempt before failing. Valid range 1-3600.')]
    [System.Nullable[System.UInt32]] $AuthenticationPeriodInSeconds

    [DscProperty()]
    [System.ComponentModel.Description('Specify the number of seconds between a failed authentication and the next authentication attempt. Valid range 1-3600.')]
    [System.Nullable[System.UInt32]] $AuthenticationRetryDelayPeriodInSeconds

    [DscProperty()]
    [System.ComponentModel.Description('Specify whether to authenticate the user, the device, either, or to use guest authentication (none). If you''re using certificate authentication, make sure the certificate type matches the authentication type. Possible values are: none, user, machine, machineOrUser, guest. Possible values are: none, user, machine, machineOrUser, guest, unknownFutureValue.')]
    [ValidateSet('none', 'user', 'machine', 'machineOrUser', 'guest', 'unknownFutureValue')]
    [System.String] $AuthenticationType

    [DscProperty()]
    [System.ComponentModel.Description('When TRUE, caches user credentials on the device so that users don''t need to keep entering them each time they connect. When FALSE, do not cache credentials. Default value is FALSE.')]
    [System.Nullable[System.Boolean]] $CacheCredentials

    [DscProperty()]
    [System.ComponentModel.Description('When TRUE, prevents the user from being prompted to authorize new servers for trusted certification authorities when EAP type is selected as PEAP. When FALSE, does not prevent the user from being prompted. Default value is FALSE.')]
    [System.Nullable[System.Boolean]] $DisableUserPromptForServerValidation

    [DscProperty()]
    [System.ComponentModel.Description('Specify the number of seconds to wait before sending an EAPOL (Extensible Authentication Protocol over LAN) Start message. Valid range 1-3600.')]
    [System.Nullable[System.UInt32]] $EapolStartPeriodInSeconds

    [DscProperty()]
    [System.ComponentModel.Description('Extensible Authentication Protocol (EAP). Indicates the type of EAP protocol set on the Wi-Fi endpoint (router). Possible values are: eapTls, leap, eapSim, eapTtls, peap, eapFast, teap. Possible values are: eapTls, leap, eapSim, eapTtls, peap, eapFast, teap.')]
    [ValidateSet('eapTls', 'leap', 'eapSim', 'eapTtls', 'peap', 'eapFast', 'teap')]
    [System.String] $EapType

    [DscProperty()]
    [System.ComponentModel.Description('When TRUE, the automatic configuration service for wired networks requires the use of 802.1X for port authentication. When FALSE, 802.1X is not required. Default value is FALSE.')]
    [System.Nullable[System.Boolean]] $Enforce8021X

    [DscProperty()]
    [System.ComponentModel.Description('When TRUE, forces FIPS compliance. When FALSE, does not enable FIPS compliance. Default value is FALSE.')]
    [System.Nullable[System.Boolean]] $ForceFIPSCompliance

    [DscProperty()]
    [System.ComponentModel.Description('Specify inner authentication protocol for EAP TTLS. Possible values are: unencryptedPassword, challengeHandshakeAuthenticationProtocol, microsoftChap, microsoftChapVersionTwo. Possible values are: unencryptedPassword, challengeHandshakeAuthenticationProtocol, microsoftChap, microsoftChapVersionTwo.')]
    [ValidateSet('unencryptedPassword', 'challengeHandshakeAuthenticationProtocol', 'microsoftChap', 'microsoftChapVersionTwo')]
    [System.String] $InnerAuthenticationProtocolForEAPTTLS

    [DscProperty()]
    [System.ComponentModel.Description('Specify the maximum authentication failures allowed for a set of credentials. Valid range 1-100.')]
    [System.Nullable[System.UInt32]] $MaximumAuthenticationFailures

    [DscProperty()]
    [System.ComponentModel.Description('Specify the maximum number of EAPOL (Extensible Authentication Protocol over LAN) Start messages to be sent before returning failure. Valid range 1-100.')]
    [System.Nullable[System.UInt32]] $MaximumEAPOLStartMessages

    [DscProperty()]
    [System.ComponentModel.Description('Specify the string to replace usernames for privacy when using EAP TTLS or PEAP.')]
    [System.String] $OuterIdentityPrivacyTemporaryValue

    [DscProperty()]
    [System.ComponentModel.Description('When TRUE, enables verification of server''s identity by validating the certificate when EAP type is selected as PEAP. When FALSE, the certificate is not validated. Default value is TRUE.')]
    [System.Nullable[System.Boolean]] $PerformServerValidation

    [DscProperty()]
    [System.ComponentModel.Description('When TRUE, enables cryptographic binding when EAP type is selected as PEAP. When FALSE, does not enable cryptogrpahic binding. Default value is TRUE.')]
    [System.Nullable[System.Boolean]] $RequireCryptographicBinding

    [DscProperty()]
    [System.ComponentModel.Description('Specify the secondary authentication method. Possible values are: certificate, usernameAndPassword, derivedCredential. Possible values are: certificate, usernameAndPassword, derivedCredential, unknownFutureValue.')]
    [ValidateSet('certificate', 'usernameAndPassword', 'derivedCredential', 'unknownFutureValue')]
    [System.String] $SecondaryAuthenticationMethod

    [DscProperty()]
    [System.ComponentModel.Description('Specify trusted server certificate names.')]
    [System.String[]] $TrustedServerCertificateNames

    [DscProperty()]
    [System.ComponentModel.Description('Specify root certificates for server validation. This collection can contain a maximum of 500 elements.')]
    [System.String[]] $RootCertificatesForServerValidationIds

    [DscProperty()]
    [System.ComponentModel.Description('Specify root certificate display names for server validation. This collection can contain a maximum of 500 elements.')]
    [System.String[]] $RootCertificatesForServerValidationDisplayNames

    [DscProperty()]
    [System.ComponentModel.Description('Specify identity certificate for client authentication.')]
    [System.String] $IdentityCertificateForClientAuthenticationId

    [DscProperty()]
    [System.ComponentModel.Description('Specify identity certificate display name for client authentication.')]
    [System.String] $IdentityCertificateForClientAuthenticationDisplayName

    [DscProperty()]
    [System.ComponentModel.Description('Specify root certificate for client validation')]
    [System.String] $SecondaryIdentityCertificateForClientAuthenticationId

    [DscProperty()]
    [System.ComponentModel.Description('Specify root certificate display name for client validation')]
    [System.String] $SecondaryIdentityCertificateForClientAuthenticationDisplayName

    [DscProperty()]
    [System.ComponentModel.Description('Specify root certificate for client validation.')]
    [System.String] $RootCertificateForClientValidationId

    [DscProperty()]
    [System.ComponentModel.Description('Specify root certificate display name for client validation.')]
    [System.String] $RootCertificateForClientValidationDisplayName

    [DscProperty()]
    [System.ComponentModel.Description('Specify secondary root certificate for client validation.')]
    [System.String] $SecondaryRootCertificateForClientValidationId

    [DscProperty()]
    [System.ComponentModel.Description('Specify secondary root certificate display name for client validation.')]
    [System.String] $SecondaryRootCertificateForClientValidationDisplayName

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

    [IntuneDeviceConfigurationWiredNetworkPolicyWindows10] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [IntuneDeviceConfigurationWiredNetworkPolicyWindows10]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of the Intune Device Configuration Wired Network Policy for Windows10 with Id {$($this.Id)} and DisplayName {$($this.DisplayName)}"

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
                    Write-Verbose -Message "Could not find an Intune Device Configuration Wired Network Policy for Windows10 with Id {$($this.Id)}"

                    if (-not [string]::IsNullOrEmpty($this.DisplayName))
                    {
                        $getValue = Get-MgBetaDeviceManagementDeviceConfiguration `
                            -All `
                            -Filter "DisplayName eq '$($this.DisplayName -replace "'", "''")' and isof('microsoft.graph.windowsWiredNetworkConfiguration')" `
                            -ErrorAction SilentlyContinue
                    }
                }
                #endregion
                if ($null -eq $getValue)
                {
                    Write-Verbose -Message "Could not find an Intune Device Configuration Wired Network Policy for Windows10 with DisplayName {$($this.DisplayName)}"
                    return $this.AsResult($nullResult)
                }
            }
            else
            {
                $getValue = $this.ExportedInstance
            }
            $resolvedId = $getValue.Id
            Write-Verbose -Message "An Intune Device Configuration Wired Network Policy for Windows10 with Id {$($resolvedId)} and DisplayName {$($this.DisplayName)} was found."

            #region resource generator code
            $enumSecondaryAuthenticationMethod = $null
            if ($null -ne $getValue.secondaryAuthenticationMethod)
            {
                $enumSecondaryAuthenticationMethod = $getValue.secondaryAuthenticationMethod
            }
            #endregion

            $rootCertificateForClientValidation = $this.GetDeviceConfigurationPolicyCertificate($getValue.Id, 'rootCertificateForClientValidation')
            $rootCertificatesForServerValidation = $this.GetDeviceConfigurationPolicyCertificate($getValue.Id, 'rootCertificatesForServerValidation')
            $identityCertificateForClientAuthentication = $this.GetDeviceConfigurationPolicyCertificate($getValue.Id, 'identityCertificateForClientAuthentication')

            $secondaryIdentityCertificateForClientAuthentication = $null
            $secondaryRootCertificateForClientValidation = $null
            if (-not [System.String]::IsNullOrEmpty($enumSecondaryAuthenticationMethod))
            {
                $secondaryIdentityCertificateForClientAuthentication = $this.GetDeviceConfigurationPolicyCertificate($getValue.Id, 'secondaryIdentityCertificateForClientAuthentication')
                $secondaryRootCertificateForClientValidation = $this.GetDeviceConfigurationPolicyCertificate($getValue.Id, 'secondaryRootCertificateForClientValidation')
            }

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

            $results = @{
                #region resource generator code
                AuthenticationBlockPeriodInMinutes                             = $getValue.authenticationBlockPeriodInMinutes
                AuthenticationMethod                                           = $getValue.authenticationMethod
                AuthenticationPeriodInSeconds                                  = $getValue.authenticationPeriodInSeconds
                AuthenticationRetryDelayPeriodInSeconds                        = $getValue.authenticationRetryDelayPeriodInSeconds
                AuthenticationType                                             = $getValue.authenticationType
                CacheCredentials                                               = $getValue.cacheCredentials
                DisableUserPromptForServerValidation                           = $getValue.disableUserPromptForServerValidation
                EapolStartPeriodInSeconds                                      = $getValue.eapolStartPeriodInSeconds
                EapType                                                        = $getValue.eapType
                Enforce8021X                                                   = $getValue.enforce8021X
                ForceFIPSCompliance                                            = $getValue.forceFIPSCompliance
                InnerAuthenticationProtocolForEAPTTLS                          = $getValue.innerAuthenticationProtocolForEAPTTLS
                MaximumAuthenticationFailures                                  = $getValue.maximumAuthenticationFailures
                MaximumEAPOLStartMessages                                      = $getValue.maximumEAPOLStartMessages
                OuterIdentityPrivacyTemporaryValue                             = $getValue.outerIdentityPrivacyTemporaryValue
                PerformServerValidation                                        = $getValue.performServerValidation
                RequireCryptographicBinding                                    = $getValue.requireCryptographicBinding
                SecondaryAuthenticationMethod                                  = $enumSecondaryAuthenticationMethod
                TrustedServerCertificateNames                                  = $getValue.trustedServerCertificateNames
                RootCertificatesForServerValidationIds                         = Get-M365DSCArrayFromProperty -PropertyValue $rootCertificatesForServerValidation.Id -ElementType ([System.String])
                RootCertificatesForServerValidationDisplayNames                = Get-M365DSCArrayFromProperty -PropertyValue $rootCertificatesForServerValidation.DisplayName -ElementType ([System.String])
                IdentityCertificateForClientAuthenticationId                   = $identityCertificateForClientAuthentication.Id
                IdentityCertificateForClientAuthenticationDisplayName          = $identityCertificateForClientAuthentication.DisplayName
                SecondaryIdentityCertificateForClientAuthenticationId          = $secondaryIdentityCertificateForClientAuthentication.Id
                SecondaryIdentityCertificateForClientAuthenticationDisplayName = $secondaryIdentityCertificateForClientAuthentication.DisplayName
                RootCertificateForClientValidationId                           = $rootCertificateForClientValidation.Id
                RootCertificateForClientValidationDisplayName                  = $rootCertificateForClientValidation.DisplayName
                SecondaryRootCertificateForClientValidationId                  = $secondaryRootCertificateForClientValidation.Id
                SecondaryRootCertificateForClientValidationDisplayName         = $secondaryRootCertificateForClientValidation.DisplayName
                Description                                                    = $getValue.Description
                DeviceManagementApplicabilityRuleDeviceMode                    = $complexDeviceManagementApplicabilityRuleDeviceMode
                DeviceManagementApplicabilityRuleOsEdition                     = $complexDeviceManagementApplicabilityRuleOsEdition
                DeviceManagementApplicabilityRuleOsVersion                     = $complexDeviceManagementApplicabilityRuleOsVersion
                DisplayName                                                    = $getValue.DisplayName
                Id                                                             = $getValue.Id
                RoleScopeTagIds                                                = Resolve-M365DSCIntuneRoleScopeTagNames -CurrentValues $getValue.RoleScopeTagIds -DesiredValues $this.RoleScopeTagIds
                Ensure                                                         = 'Present'
                Credential                                                     = $this.Credential
                ApplicationId                                                  = $this.ApplicationId
                TenantId                                                       = $this.TenantId
                ApplicationSecret                                              = $this.ApplicationSecret
                CertificateThumbprint                                          = $this.CertificateThumbprint
                CertificatePath                                                = $this.CertificatePath
                CertificatePassword                                            = $this.CertificatePassword
                ManagedIdentity                                                = $this.ManagedIdentity
                AccessTokens                                                   = $this.AccessTokens
                #endregion
            }

            $assignmentsValues = Get-M365DSCIntuneExpandedAssignments -Instance $getValue
            if ($null -eq $assignmentsValues)
            {
                $assignmentsValues = Get-MgBetaDeviceManagementDeviceConfigurationAssignment -DeviceConfigurationId $resolvedId
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
            Write-Verbose -Message "Creating an Intune Device Configuration Wired Network Policy for Windows10 with DisplayName {$($this.DisplayName)}"
            $createParameters = $boundParameters
            $createParameters.Remove('Assignments') | Out-Null
            $createParameters.Remove('RootCertificatesForServerValidationIds') | Out-Null
            $createParameters.Remove('RootCertificatesForServerValidationDisplayNames') | Out-Null
            $createParameters.Remove('IdentityCertificateForClientAuthenticationId') | Out-Null
            $createParameters.Remove('IdentityCertificateForClientAuthenticationDisplayName') | Out-Null
            $createParameters.Remove('SecondaryIdentityCertificateForClientAuthenticationId') | Out-Null
            $createParameters.Remove('SecondaryIdentityCertificateForClientAuthenticationDisplayName') | Out-Null
            $createParameters.Remove('RootCertificateForClientValidationId') | Out-Null
            $createParameters.Remove('RootCertificateForClientValidationDisplayName') | Out-Null
            $createParameters.Remove('SecondaryRootCertificateForClientValidationId') | Out-Null
            $createParameters.Remove('SecondaryRootCertificateForClientValidationDisplayName') | Out-Null

            $createParameters.Remove('Id') | Out-Null

            #region resource generator code

            if ($null -ne $this.RootCertificatesForServerValidationIds -and $this.RootCertificatesForServerValidationIds.Count -gt 0 )
            {
                $rootCertificatesForServerValidation = @()
                for ($i = 0; $i -lt $this.RootCertificatesForServerValidationIds.Length; $i++)
                {
                    $certName = $null
                    if ($null -ne $this.RootCertificatesForServerValidationDisplayNames -and $i -lt $this.RootCertificatesForServerValidationDisplayNames.Count)
                    {
                        $certName = $this.RootCertificatesForServerValidationDisplayNames[$i]
                    }

                    $checkedCertId = $this.GetCertificateId(
                        $this.RootCertificatesForServerValidationIds[$i],
                        $certName,
                        @('#microsoft.graph.windows81TrustedRootCertificate'))
                    $rootCertificatesForServerValidation += "$((Get-MSCloudLoginConnectionProfile -Workload MicrosoftGraph).ResourceUrl)beta/deviceManagement/deviceConfigurations('$checkedCertId')"
                }
                $createParameters.Add('rootCertificatesForServerValidation@odata.bind', $rootCertificatesForServerValidation)
            }

            if (-not [String]::IsNullOrWhiteSpace($this.IdentityCertificateForClientAuthenticationId))
            {
                $checkedCertId = $this.GetCertificateId(
                    $this.IdentityCertificateForClientAuthenticationId,
                    $this.IdentityCertificateForClientAuthenticationDisplayName,
                    @(
                        '#microsoft.graph.windows81SCEPCertificateProfile',
                        '#microsoft.graph.windows81TrustedRootCertificate',
                        '#microsoft.graph.windows10PkcsCertificateProfile'
                    ))
                $ref = "$((Get-MSCloudLoginConnectionProfile -Workload MicrosoftGraph).ResourceUrl)beta/deviceManagement/deviceConfigurations('$checkedCertId')"
                $createParameters.Add('identityCertificateForClientAuthentication@odata.bind', $ref)
            }

            if (-not [String]::IsNullOrWhiteSpace($this.SecondaryIdentityCertificateForClientAuthenticationId))
            {
                $checkedCertId = $this.GetCertificateId(
                    $this.SecondaryIdentityCertificateForClientAuthenticationId,
                    $this.SecondaryIdentityCertificateForClientAuthenticationDisplayName,
                    @(
                        '#microsoft.graph.windows81SCEPCertificateProfile',
                        '#microsoft.graph.windows81TrustedRootCertificate',
                        '#microsoft.graph.windows10PkcsCertificateProfile'
                    ))
                $ref = "$((Get-MSCloudLoginConnectionProfile -Workload MicrosoftGraph).ResourceUrl)beta/deviceManagement/deviceConfigurations('$checkedCertId')"
                $createParameters.Add('secondaryIdentityCertificateForClientAuthentication@odata.bind', $ref)
            }

            if (-not [String]::IsNullOrWhiteSpace($this.RootCertificateForClientValidationId))
            {
                $checkedCertId = $this.GetCertificateId(
                    $this.RootCertificateForClientValidationId,
                    $this.RootCertificateForClientValidationDisplayName,
                    @('#microsoft.graph.windows81TrustedRootCertificate'))
                $ref = "$((Get-MSCloudLoginConnectionProfile -Workload MicrosoftGraph).ResourceUrl)beta/deviceManagement/deviceConfigurations('$checkedCertId')"
                $createParameters.Add('rootCertificateForClientValidation@odata.bind', $ref)
            }

            if (-not [String]::IsNullOrWhiteSpace($this.SecondaryRootCertificateForClientValidationId))
            {
                $checkedCertId = $this.GetCertificateId(
                    $this.SecondaryRootCertificateForClientValidationId,
                    $this.SecondaryRootCertificateForClientValidationDisplayName,
                    @('#microsoft.graph.windows81TrustedRootCertificate'))
                $ref = "$((Get-MSCloudLoginConnectionProfile -Workload MicrosoftGraph).ResourceUrl)beta/deviceManagement/deviceConfigurations('$checkedCertId')"
                $createParameters.Add('secondaryRootCertificateForClientValidation@odata.bind', $ref)
            }

            $createParameters.Add('@odata.type', '#microsoft.graph.windowsWiredNetworkConfiguration')
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
            Write-Verbose -Message "Updating the Intune Device Configuration Wired Network Policy for Windows10 with Id {$($currentInstance.Id)}"
            $updateParameters = $boundParameters
            $updateParameters.Remove('Assignments') | Out-Null
            $updateParameters.Remove('RootCertificatesForServerValidationIds') | Out-Null
            $updateParameters.Remove('RootCertificatesForServerValidationDisplayNames') | Out-Null
            $updateParameters.Remove('IdentityCertificateForClientAuthenticationId') | Out-Null
            $updateParameters.Remove('IdentityCertificateForClientAuthenticationDisplayName') | Out-Null
            $updateParameters.Remove('SecondaryIdentityCertificateForClientAuthenticationId') | Out-Null
            $updateParameters.Remove('SecondaryIdentityCertificateForClientAuthenticationDisplayName') | Out-Null
            $updateParameters.Remove('RootCertificateForClientValidationId') | Out-Null
            $updateParameters.Remove('RootCertificateForClientValidationDisplayName') | Out-Null
            $updateParameters.Remove('SecondaryRootCertificateForClientValidationId') | Out-Null
            $updateParameters.Remove('SecondaryRootCertificateForClientValidationDisplayName') | Out-Null

            $updateParameters.Remove('Id') | Out-Null

            #region resource generator code
            $updateParameters.Add('@odata.type', '#microsoft.graph.windowsWiredNetworkConfiguration')
            Update-MgBetaDeviceManagementDeviceConfiguration `
                -DeviceConfigurationId $currentInstance.Id `
                -BodyParameter $updateParameters
            $assignmentsHash = ConvertTo-IntunePolicyAssignment -IncludeDeviceFilter:$true -Assignments $this.Assignments
            Update-DeviceConfigurationPolicyAssignment `
                -DeviceConfigurationPolicyId $currentInstance.Id `
                -Targets $assignmentsHash `
                -Repository 'deviceManagement/deviceConfigurations'
            #endregion

            if ($null -ne $this.RootCertificatesForServerValidationIds -and $this.RootCertificatesForServerValidationIds.Count -gt 0 )
            {
                [Array]$rootCertificatesForServerValidationChecked = @()
                for ($i = 0; $i -lt $this.RootCertificatesForServerValidationIds.Count; $i++)
                {
                    $certId = $this.RootCertificatesForServerValidationIds[$i]
                    $certName = $null
                    if ($null -ne $this.RootCertificatesForServerValidationDisplayNames -and $i -lt $this.RootCertificatesForServerValidationDisplayNames.Count)
                    {
                        $certName = $this.RootCertificatesForServerValidationDisplayNames[$i]
                    }

                    $checkedCertId = $this.GetCertificateId($certId, $certName, @('#microsoft.graph.windows81TrustedRootCertificate'))
                    $rootCertificatesForServerValidationChecked += $checkedCertId
                }
                $compareResult = Compare-Object -ReferenceObject $currentInstance.RootCertificatesForServerValidationIds `
                    -DifferenceObject $rootCertificatesForServerValidationChecked

                [Array]$certsToAdd = ($compareResult | Where-Object { $_.SideIndicator -eq '=>' }).InputObject
                [Array]$certsToRemove = ($compareResult | Where-Object { $_.SideIndicator -eq '<=' }).InputObject

                if ($certsToAdd.Count -gt 0)
                {
                    $this.UpdateDeviceConfigurationPolicyCertificateId($currentInstance.Id, $certsToAdd, 'rootCertificatesForServerValidation')
                }

                if ($certsToRemove.Count -gt 0)
                {
                    $this.RemoveDeviceConfigurationPolicyCertificateId($currentInstance.Id, $certsToRemove, 'rootCertificatesForServerValidation')
                }
            }

            if (-not [String]::IsNullOrWhiteSpace($this.IdentityCertificateForClientAuthenticationId))
            {
                if ($this.IdentityCertificateForClientAuthenticationId -ne $currentInstance.IdentityCertificateForClientAuthenticationId)
                {
                    $resolvedCertId = $this.GetCertificateId(
                        $this.IdentityCertificateForClientAuthenticationId,
                        $this.IdentityCertificateForClientAuthenticationDisplayName,
                        @(
                            '#microsoft.graph.windows81SCEPCertificateProfile',
                            '#microsoft.graph.windows81TrustedRootCertificate',
                            '#microsoft.graph.windows10PkcsCertificateProfile'
                        ))
                    $this.UpdateDeviceConfigurationPolicyCertificateId($currentInstance.Id, $resolvedCertId, 'identityCertificateForClientAuthentication')
                }
            }

            if (-not [String]::IsNullOrWhiteSpace($this.SecondaryIdentityCertificateForClientAuthenticationId))
            {
                if ($this.SecondaryIdentityCertificateForClientAuthenticationId -ne $currentInstance.SecondaryIdentityCertificateForClientAuthenticationId)
                {
                    $resolvedCertId = $this.GetCertificateId(
                        $this.SecondaryIdentityCertificateForClientAuthenticationId,
                        $this.SecondaryIdentityCertificateForClientAuthenticationDisplayName,
                        @(
                            '#microsoft.graph.windows81SCEPCertificateProfile',
                            '#microsoft.graph.windows81TrustedRootCertificate',
                            '#microsoft.graph.windows10PkcsCertificateProfile'
                        ))
                    $this.UpdateDeviceConfigurationPolicyCertificateId($currentInstance.Id, $resolvedCertId, 'secondaryIdentityCertificateForClientAuthentication')
                }
            }

            if (-not [String]::IsNullOrWhiteSpace($this.RootCertificateForClientValidationId))
            {
                if ($this.RootCertificateForClientValidationId -ne $currentInstance.RootCertificateForClientValidationId)
                {
                    $resolvedCertId = $this.GetCertificateId(
                        $this.RootCertificateForClientValidationId,
                        $this.RootCertificateForClientValidationDisplayName,
                        @('#microsoft.graph.windows81TrustedRootCertificate'))
                    $this.UpdateDeviceConfigurationPolicyCertificateId($currentInstance.Id, $resolvedCertId, 'rootCertificateForClientValidation')
                }
            }

            if (-not [String]::IsNullOrWhiteSpace($this.SecondaryRootCertificateForClientValidationId))
            {
                if ($this.SecondaryRootCertificateForClientValidationId -ne $currentInstance.SecondaryRootCertificateForClientValidationId)
                {
                    $resolvedCertId = $this.GetCertificateId(
                        $this.SecondaryRootCertificateForClientValidationId,
                        $this.SecondaryRootCertificateForClientValidationDisplayName,
                        @('#microsoft.graph.windows81TrustedRootCertificate'))
                    $this.UpdateDeviceConfigurationPolicyCertificateId($currentInstance.Id, $resolvedCertId, 'secondaryRootCertificateForClientValidation')
                }
            }
        }
        elseif ($this.Ensure -eq 'Absent' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Removing the Intune Device Configuration Wired Network Policy for Windows10 with Id {$($currentInstance.Id)}"
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
                -ODataType 'microsoft.graph.windowsWiredNetworkConfiguration' `
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
                    -NoEscape @('Assignments', 'DeviceManagementApplicabilityRuleDeviceMode', 'DeviceManagementApplicabilityRuleOsEdition', 'DeviceManagementApplicabilityRuleOsVersion') `
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
                    $_.Exception -like '*Message: Location header not present in redirection response.*' -or `
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
                if ($DesiredValues.ContainsKey('RootCertificatesForServerValidationDisplayNames'))
                {
                    $ValuesToCheck.Remove('RootCertificatesForServerValidationIds') | Out-Null
                }
                if ($DesiredValues.ContainsKey('IdentityCertificateForClientAuthenticationDisplayName'))
                {
                    $ValuesToCheck.Remove('IdentityCertificateForClientAuthenticationId') | Out-Null
                }
                if ($DesiredValues.ContainsKey('SecondaryIdentityCertificateForClientAuthenticationDisplayName'))
                {
                    $ValuesToCheck.Remove('SecondaryIdentityCertificateForClientAuthenticationId') | Out-Null
                }
                if ($DesiredValues.ContainsKey('RootCertificateForClientValidationDisplayName'))
                {
                    $ValuesToCheck.Remove('RootCertificateForClientValidationId') | Out-Null
                }
                if ($DesiredValues.ContainsKey('SecondaryRootCertificateForClientValidationDisplayName'))
                {
                    $ValuesToCheck.Remove('SecondaryRootCertificateForClientValidationId') | Out-Null
                }
                return [System.Tuple[Hashtable, Hashtable, Hashtable]]::new($DesiredValues, $CurrentValues, $ValuesToCheck)
            }
        }
    }

    hidden [System.String] GetCertificateId([System.String] $CertificateId, [System.String] $CertificateDisplayName, [System.String[]] $OdataTypes)
    {
        $Certificate = Get-MgBetaDeviceManagementDeviceConfiguration `
            -DeviceConfigurationId $CertificateId `
            -ErrorAction SilentlyContinue | `
                Where-Object -FilterScript {
                $_.'@odata.type' -in $OdataTypes
            }

        if ($null -eq $Certificate)
        {
            Write-Verbose -Message "Could not find certificate with Id {$CertificateId}, searching by display name {$CertificateDisplayName}"

            $Certificate = Get-MgBetaDeviceManagementDeviceConfiguration -All `
                -Filter "DisplayName eq '$($CertificateDisplayName -replace "'", "''")'" `
                -ErrorAction SilentlyContinue | `
                    Where-Object -FilterScript {
                    $_.'@odata.type' -in $OdataTypes
                }

            if ($null -eq $Certificate)
            {
                throw "Could not find certificate with Id {$CertificateId} or display name {$CertificateDisplayName}"
            }

            $CertificateId = $Certificate.Id
            Write-Verbose -Message "Found certificate with Id {$($CertificateId)} and DisplayName {$($Certificate.DisplayName)}"
        }
        else
        {
            Write-Verbose -Message "Found certificate with Id {$CertificateId}"
        }

        return $CertificateId
    }

    hidden [System.Object] GetDeviceConfigurationPolicyCertificate([System.String] $DeviceConfigurationPolicyId, [System.String] $CertificateName)
    {
        try
        {
            $uri = "/beta/deviceManagement/deviceConfigurations('$DeviceConfigurationPolicyId')/microsoft.graph.windowsWiredNetworkConfiguration/$CertificateName"
            $result = Invoke-M365DSCGraphRequest -Method Get -Uri $uri -ErrorAction Stop 4>$null

            if ($result.value)
            {
                return $result.value
            }

            return $result
        }
        catch
        {
            return $null
        }
    }

    hidden [void] RemoveDeviceConfigurationPolicyCertificateId([System.String] $DeviceConfigurationPolicyId, [System.String[]] $CertificateIds, [System.String] $CertificateName)
    {
        foreach ($certificateId in $CertificateIds)
        {
            $uri = "/beta/deviceManagement/deviceConfigurations('$DeviceConfigurationPolicyId')/microsoft.graph.windowsWiredNetworkConfiguration/$CertificateName/$certificateId/`$ref"
            $ref = @{
                '@odata.id' = "$((Get-MSCloudLoginConnectionProfile -Workload MicrosoftGraph).ResourceUrl)beta/deviceManagement/deviceConfigurations('$certificateId')"
            }
            $null = Invoke-M365DSCGraphRequest -Method DELETE -Uri $uri -Body ($ref | ConvertTo-Json) -ErrorAction Stop 4>$null
        }
    }

    hidden [void] UpdateDeviceConfigurationPolicyCertificateId([System.String] $DeviceConfigurationPolicyId, [System.String[]] $CertificateIds, [System.String] $CertificateName)
    {
        if ($CertificateName -eq 'rootCertificatesForServerValidation')
        {
            $method = 'POST'
        }
        else
        {
            $method = 'PUT'
        }

        foreach ($certificateId in $CertificateIds)
        {
            $ref = @{
                '@odata.id' = "$((Get-MSCloudLoginConnectionProfile -Workload MicrosoftGraph).ResourceUrl)beta/deviceManagement/deviceConfigurations('$certificateId')"
            }

            $uri = "/beta/deviceManagement/deviceConfigurations('$DeviceConfigurationPolicyId')/microsoft.graph.windowsWiredNetworkConfiguration/$CertificateName/`$ref"
            $null = Invoke-M365DSCGraphRequest -Method $method -Uri $uri -Body ($ref | ConvertTo-Json) -ErrorAction Stop 4>$null
        }
    }

    hidden [IntuneDeviceConfigurationWiredNetworkPolicyWindows10] AsResult([System.Object] $Values)
    {
        if ($Values -is [IntuneDeviceConfigurationWiredNetworkPolicyWindows10])
        {
            return $Values
        }

        $result = [IntuneDeviceConfigurationWiredNetworkPolicyWindows10]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
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
