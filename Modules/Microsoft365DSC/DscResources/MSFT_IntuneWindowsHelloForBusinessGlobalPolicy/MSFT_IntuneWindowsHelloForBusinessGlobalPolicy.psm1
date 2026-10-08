using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class IntuneWindowsHelloForBusinessGlobalPolicy : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('Only valid value is ''Yes''.')]
    [ValidateSet('Yes')]
    [System.String] $IsSingleInstance

    [DscProperty()]
    [System.ComponentModel.Description('Controls the ability to use the anti-spoofing features for facial recognition on devices which support it. If set to disabled, anti-spoofing features are not allowed. If set to Not Configured, the user can choose whether they want to use anti-spoofing. Possible values are: notConfigured, enabled, disabled.')]
    [ValidateSet('notConfigured', 'enabled', 'disabled')]
    [System.String] $EnhancedBiometricsState

    [DscProperty()]
    [System.ComponentModel.Description('Setting to configure Enhanced sign-in security. Default is Not Configured')]
    [System.Nullable[System.UInt32]] $EnhancedSignInSecurity

    [DscProperty()]
    [System.ComponentModel.Description('Controls the period of time (in days) that a PIN can be used before the system requires the user to change it. This must be set between 0 and 730, inclusive. If set to 0, the user''s PIN will never expire')]
    [System.Nullable[System.UInt32]] $PinExpirationInDays

    [DscProperty()]
    [System.ComponentModel.Description('Controls the ability to use lowercase letters in the Windows Hello for Business PIN.  Allowed permits the use of lowercase letter(s), whereas Required ensures they are present. If set to Not Allowed, lowercase letters will not be permitted. Possible values are: allowed, required, disallowed.')]
    [ValidateSet('allowed', 'required', 'disallowed')]
    [System.String] $PinLowercaseCharactersUsage

    [DscProperty()]
    [System.ComponentModel.Description('Controls the maximum number of characters allowed for the Windows Hello for Business PIN. This value must be between 4 and 127, inclusive. This value must be greater than or equal to the value set for the minimum PIN.')]
    [System.Nullable[System.UInt32]] $PinMaximumLength

    [DscProperty()]
    [System.ComponentModel.Description('Controls the minimum number of characters required for the Windows Hello for Business PIN.  This value must be between 4 and 127, inclusive, and less than or equal to the value set for the maximum PIN.')]
    [System.Nullable[System.UInt32]] $PinMinimumLength

    [DscProperty()]
    [System.ComponentModel.Description('Controls the ability to prevent users from using past PINs. This must be set between 0 and 50, inclusive, and the current PIN of the user is included in that count. If set to 0, previous PINs are not stored. PIN history is not preserved through a PIN reset.')]
    [System.Nullable[System.UInt32]] $PinPreviousBlockCount

    [DscProperty()]
    [System.ComponentModel.Description('Controls the ability to use special characters in the Windows Hello for Business PIN.  Allowed permits the use of special character(s), whereas Required ensures they are present. If set to Not Allowed, special character(s) will not be permitted. Possible values are: allowed, required, disallowed.')]
    [ValidateSet('allowed', 'required', 'disallowed')]
    [System.String] $PinSpecialCharactersUsage

    [DscProperty()]
    [System.ComponentModel.Description('Controls the ability to use uppercase letters in the Windows Hello for Business PIN.  Allowed permits the use of uppercase letter(s), whereas Required ensures they are present. If set to Not Allowed, uppercase letters will not be permitted. Possible values are: allowed, required, disallowed.')]
    [ValidateSet('allowed', 'required', 'disallowed')]
    [System.String] $PinUppercaseCharactersUsage

    [DscProperty()]
    [System.ComponentModel.Description('Controls the use of Remote Windows Hello for Business. Remote Windows Hello for Business provides the ability for a portable, registered device to be usable as a companion for desktop authentication. The desktop must be Azure AD joined and the companion device must have a Windows Hello for Business PIN.')]
    [System.Nullable[System.Boolean]] $RemotePassportEnabled

    [DscProperty()]
    [System.ComponentModel.Description('Controls whether to require a Trusted Platform Module (TPM) for provisioning Windows Hello for Business. A TPM provides an additional security benefit in that data stored on it cannot be used on other devices. If set to False, all devices can provision Windows Hello for Business even if there is not a usable TPM.')]
    [System.Nullable[System.Boolean]] $SecurityDeviceRequired

    [DscProperty()]
    [System.ComponentModel.Description('Security key for Sign In provides the capacity for remotely turning ON/OFF Windows Hello Sercurity Keyl Not configured will honor configurations done on the clinet. Possible values are: notConfigured, enabled, disabled.')]
    [ValidateSet('notConfigured', 'enabled', 'disabled')]
    [System.String] $SecurityKeyForSignIn

    [DscProperty()]
    [System.ComponentModel.Description('Controls whether to allow the device to be configured for Windows Hello for Business. If set to disabled, the user cannot provision Windows Hello for Business except on Azure Active Directory joined mobile phones if otherwise required. If set to Not Configured, Intune will not override client defaults. Possible values are: notConfigured, enabled, disabled.')]
    [ValidateSet('notConfigured', 'enabled', 'disabled')]
    [System.String] $State

    [DscProperty()]
    [System.ComponentModel.Description('Controls the use of biometric gestures, such as face and fingerprint, as an alternative to the Windows Hello for Business PIN.  If set to False, biometric gestures are not allowed. Users must still configure a PIN as a backup in case of failures.')]
    [System.Nullable[System.Boolean]] $UnlockWithBiometricsEnabled

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

    [IntuneWindowsHelloForBusinessGlobalPolicy] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [IntuneWindowsHelloForBusinessGlobalPolicy]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message 'Getting configuration for the Intune Windows Hello For Business Global Policy'

        try
        {
            if (-not $this.ExportedInstance)
            {
                $null = $this.Connect('MicrosoftGraph')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                #region resource generator code
                $getValue = Get-MgBetaDeviceManagementDeviceEnrollmentConfiguration `
                    -ErrorAction SilentlyContinue | Where-Object `
                    -FilterScript {
                    $_.'@odata.type' -eq '#microsoft.graph.deviceEnrollmentWindowsHelloForBusinessConfiguration'
                }
                #endregion
            }
            else
            {
                $getValue = $this.ExportedInstance
            }

            Write-Verbose -Message 'An Intune Windows Hello For Business Global Policy was found'

            $results = @{
                #region resource generator code
                IsSingleInstance            = 'Yes'
                EnhancedBiometricsState     = $getValue.enhancedBiometricsState
                EnhancedSignInSecurity      = $getValue.enhancedSignInSecurity
                PinExpirationInDays         = $getValue.pinExpirationInDays
                PinLowercaseCharactersUsage = $getValue.pinLowercaseCharactersUsage
                PinMaximumLength            = $getValue.pinMaximumLength
                PinMinimumLength            = $getValue.pinMinimumLength
                PinPreviousBlockCount       = $getValue.pinPreviousBlockCount
                PinSpecialCharactersUsage   = $getValue.pinSpecialCharactersUsage
                PinUppercaseCharactersUsage = $getValue.pinUppercaseCharactersUsage
                RemotePassportEnabled       = $getValue.remotePassportEnabled
                SecurityDeviceRequired      = $getValue.securityDeviceRequired
                SecurityKeyForSignIn        = $getValue.securityKeyForSignIn
                State                       = $getValue.state
                UnlockWithBiometricsEnabled = $getValue.unlockWithBiometricsEnabled
                Credential                  = $this.Credential
                ApplicationId               = $this.ApplicationId
                TenantId                    = $this.TenantId
                ApplicationSecret           = $this.ApplicationSecret
                CertificateThumbprint       = $this.CertificateThumbprint
                CertificatePath             = $this.CertificatePath
                CertificatePassword         = $this.CertificatePassword
                ManagedIdentity             = $this.ManagedIdentity
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

        Write-Verbose -Message 'Setting configuration of the Intune Windows Hello For Business Global Policy'

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $null = $this.Get().ToHashtable()
        $boundParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()

        $updateParameters = Rename-M365DSCCimInstanceParameter -Properties $boundParameters

        #region resource generator code
        $updateParameters.Add('@odata.type', '#microsoft.graph.deviceEnrollmentWindowsHelloForBusinessConfiguration')
        $policy = Get-MgBetaDeviceManagementDeviceEnrollmentConfiguration | Where-Object -FilterScript {
            $_.'@odata.type' -eq '#microsoft.graph.deviceEnrollmentWindowsHelloForBusinessConfiguration'
        }
        Update-MgBetaDeviceManagementDeviceEnrollmentConfiguration `
            -DeviceEnrollmentConfigurationId $policy.Id `
            -BodyParameter $updateParameters
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
            [array]$getValue = Get-M365DSCExportCachedCollection -Collection 'deviceEnrollmentConfigurations' `
                -ODataType 'microsoft.graph.deviceEnrollmentWindowsHelloForBusinessConfiguration' `
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

                $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                    -ConnectionMode $ConnectionMode `
                    -ModulePath $this.GetModulePath() `
                    -Results $Results `
                    -Credential $this.Credential
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

    hidden [IntuneWindowsHelloForBusinessGlobalPolicy] AsResult([System.Object] $Values)
    {
        if ($Values -is [IntuneWindowsHelloForBusinessGlobalPolicy])
        {
            return $Values
        }

        $result = [IntuneWindowsHelloForBusinessGlobalPolicy]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
