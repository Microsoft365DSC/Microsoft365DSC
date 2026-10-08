using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class IntuneDeviceManagementAndroidDeviceOwnerEnrollmentProfile : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('Display name for the enrollment profile.')]
    [System.String] $DisplayName

    [DscProperty()]
    [System.ComponentModel.Description('Unique GUID for the enrollment profile. Read-Only.')]
    [System.String] $Id

    [DscProperty()]
    [System.ComponentModel.Description('Intune AccountId GUID the enrollment profile belongs to.')]
    [System.String] $AccountId

    [DscProperty()]
    [System.ComponentModel.Description('Description for the enrollment profile.')]
    [System.String] $Description

    [DscProperty()]
    [System.ComponentModel.Description('The enrollment mode of devices that use this enrollment profile.')]
    [ValidateSet('corporateOwnedDedicatedDevice', 'corporateOwnedFullyManaged', 'corporateOwnedWorkProfile', 'corporateOwnedAOSPUserlessDevice', 'corporateOwnedAOSPUserAssociatedDevice')]
    [System.String] $EnrollmentMode

    [DscProperty()]
    [System.ComponentModel.Description('The enrollment token type for an enrollment profile.')]
    [ValidateSet('default', 'corporateOwnedDedicatedDeviceWithAzureADSharedMode', 'deviceStaging')]
    [System.String] $EnrollmentTokenType

    [DscProperty()]
    [System.ComponentModel.Description('Date time the most recently created token will expire.')]
    [System.String] $TokenExpirationDateTime

    [DscProperty()]
    [System.ComponentModel.Description('List of Scope Tags for this Entity instance.')]
    [System.String[]] $RoleScopeTagIds

    [DscProperty()]
    [System.ComponentModel.Description('Boolean that indicates that the Wi-Fi network should be configured during device provisioning. When set to TRUE, device provisioning will use Wi-Fi related properties to automatically connect to Wi-Fi networks. When set to FALSE or undefined, other Wi-Fi related properties will be ignored. Default value is TRUE. Returned by default.')]
    [System.Nullable[System.Boolean]] $ConfigureWifi

    [DscProperty()]
    [System.ComponentModel.Description('String that contains the wi-fi login ssid')]
    [System.String] $WifiSsid

    [DscProperty()]
    [System.ComponentModel.Description('String that contains the wi-fi login password. The parameter is a PSCredential object.')]
    [System.Management.Automation.PSCredential] $WifiPassword

    [DscProperty()]
    [System.ComponentModel.Description('String that contains the wi-fi security type.')]
    [ValidateSet('none', 'wpa', 'wep')]
    [System.String] $WifiSecurityType

    [DscProperty()]
    [System.ComponentModel.Description('Boolean that indicates if hidden wifi networks are enabled')]
    [System.Nullable[System.Boolean]] $WifiHidden

    [DscProperty()]
    [System.ComponentModel.Description('Boolean indicating if this profile is an Android AOSP for Teams device profile.')]
    [System.Nullable[System.Boolean]] $IsTeamsDeviceProfile

    [DscProperty()]
    [System.ComponentModel.Description('Indicates the device name template used for the enrolled Android devices.')]
    [System.String] $DeviceNameTemplate

    [DscProperty()]
    [System.ComponentModel.Description('Present ensures the instance exists, absent ensures it is removed.')]
    [ValidateSet('Present', 'Absent')]
    [System.String] $Ensure

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
    [System.String] $Filter

    # Export-only. Not part of the resource schema.
    [System.Management.Automation.PSCredential] $ApplicationSecret

    [IntuneDeviceManagementAndroidDeviceOwnerEnrollmentProfile] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [IntuneDeviceManagementAndroidDeviceOwnerEnrollmentProfile]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of the Intune Android Device Owner Enrollment Profile with Id {$($this.Id)} and DisplayName {$($this.DisplayName)}"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.DisplayName -ne $this.DisplayName)
            {
                $null = $this.Connect('MicrosoftGraph')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullResult = $this.GetBoundParameters()
                $nullResult.Ensure = 'Absent'

                $androidDeviceOwnerEnrollmentProfile = $null
                if (-not [System.String]::IsNullOrEmpty($this.Id))
                {
                    Write-Verbose -Message 'Trying to retrieve profile by Id'
                    $androidDeviceOwnerEnrollmentProfile = Get-MgBetaDeviceManagementAndroidDeviceOwnerEnrollmentProfile `
                        -AndroidDeviceOwnerEnrollmentProfileId $this.Id `
                        -ErrorAction SilentlyContinue
                }

                if ($null -eq $androidDeviceOwnerEnrollmentProfile)
                {
                    Write-Verbose -Message 'Trying to retrieve profile by DisplayName'
                    $androidDeviceOwnerEnrollmentProfile = Get-MgBetaDeviceManagementAndroidDeviceOwnerEnrollmentProfile `
                        -All `
                        -Filter "DisplayName eq '$($this.DisplayName -replace "'", "''")'" `
                        -ErrorAction SilentlyContinue
                }

                if ($null -eq $androidDeviceOwnerEnrollmentProfile)
                {
                    Write-Verbose -Message "No AndroidDeviceOwnerEnrollmentProfile with {$($this.Id)} was found."
                    return $this.AsResult($nullResult)
                }
            }
            else
            {
                $androidDeviceOwnerEnrollmentProfile = $this.ExportedInstance
            }

            $tokenExpirationDateTimeString = $androidDeviceOwnerEnrollmentProfile.TokenExpirationDateTime
            if ($tokenExpirationDateTimeString -is [System.DateTime])
            {
                $tokenExpirationDateTimeString = $tokenExpirationDateTimeString.ToString('yyyy-MM-ddTHH:mm:ssZ')
            }
            elseif (-not [string]::IsNullOrEmpty($tokenExpirationDateTimeString))
            {
                $tokenExpirationDateTimeString = [System.DateTime]::Parse($tokenExpirationDateTimeString).ToString('yyyy-MM-ddTHH:mm:ssZ')
            }

            $results = @{
                Id                      = $androidDeviceOwnerEnrollmentProfile.Id
                DisplayName             = $androidDeviceOwnerEnrollmentProfile.DisplayName
                AccountId               = $androidDeviceOwnerEnrollmentProfile.AccountId
                ConfigureWifi           = $androidDeviceOwnerEnrollmentProfile.ConfigureWifi
                Description             = $androidDeviceOwnerEnrollmentProfile.Description
                DeviceNameTemplate      = $androidDeviceOwnerEnrollmentProfile.DeviceNameTemplate
                EnrollmentMode          = $androidDeviceOwnerEnrollmentProfile.EnrollmentMode.ToString()
                EnrollmentTokenType     = $androidDeviceOwnerEnrollmentProfile.EnrollmentTokenType.ToString()
                IsTeamsDeviceProfile    = $androidDeviceOwnerEnrollmentProfile.IsTeamsDeviceProfile
                RoleScopeTagIds         = Resolve-M365DSCIntuneRoleScopeTagNames -CurrentValues $androidDeviceOwnerEnrollmentProfile.RoleScopeTagIds -DesiredValues $this.RoleScopeTagIds
                TokenExpirationDateTime = $tokenExpirationDateTimeString
                WifiHidden              = $androidDeviceOwnerEnrollmentProfile.WifiHidden
                WifiPassword            = $androidDeviceOwnerEnrollmentProfile.WifiPassword
                WifiSecurityType        = $androidDeviceOwnerEnrollmentProfile.WifiSecurityType.ToString()
                WifiSsid                = $androidDeviceOwnerEnrollmentProfile.WifiSsid
                Ensure                  = 'Present'
                Credential              = $this.Credential
                ApplicationId           = $this.ApplicationId
                TenantId                = $this.TenantId
                CertificateThumbprint   = $this.CertificateThumbprint
                CertificatePath         = $this.CertificatePath
                CertificatePassword     = $this.CertificatePassword
                ManagedIdentity         = $this.ManagedIdentity
                AccessTokens            = $this.AccessTokens
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

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $currentInstance = $this.Get().ToHashtable()
        $setParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()
        $setParameters = Rename-M365DSCCimInstanceParameter -Properties $setParameters
        if ($setParameters.ContainsKey('RoleScopeTagIds'))
        {
            $setParameters.RoleScopeTagIds = Resolve-M365DSCIntuneRoleScopeTagIds -RoleScopeTagIds $this.RoleScopeTagIds
        }

        if (-not [System.String]::IsNullOrEmpty($this.TokenExpirationDateTime))
        {
            $setParameters.TokenExpirationDateTime = [M365DSCResourceBase]::FormatDateTime($this.TokenExpirationDateTime)
        }

        # CREATE
        if ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Create AndroidDeviceOwnerEnrollmentProfile: $($this.DisplayName) with Enrollment Mode: $($this.EnrollmentMode)"
            $setParameters.Remove('Id') | Out-Null
            $null = New-MgBetaDeviceManagementAndroidDeviceOwnerEnrollmentProfile -BodyParameter $setParameters
        }
        # UPDATE
        elseif ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Updating AndroidDeviceOwnerEnrollmentProfile: $($this.DisplayName)"
            Remove-MgBetaDeviceManagementAndroidDeviceOwnerEnrollmentProfile -AndroidDeviceOwnerEnrollmentProfileId $currentInstance.Id
            $null = New-MgBetaDeviceManagementAndroidDeviceOwnerEnrollmentProfile -BodyParameter $setParameters
        }
        # REMOVE
        elseif ($this.Ensure -eq 'Absent' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Removing AndroidDeviceOwnerEnrollmentProfile: $($this.DisplayName)"
            Remove-MgBetaDeviceManagementAndroidDeviceOwnerEnrollmentProfile -AndroidDeviceOwnerEnrollmentProfileId $currentInstance.Id
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
            # Exclude profiles with Microsoft internal enrollment mode (EnrollmentMode 5) from export
            # as it cannot be managed. Example is "Default enrollment profile for personally-owned work profile devices"
            [array] $getValue = Get-MgBetaDeviceManagementAndroidDeviceOwnerEnrollmentProfile `
                -All `
                -ErrorAction Stop | Where-Object EnrollmentMode -NE 5

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
                $displayedKey = $config.DisplayName
                Write-M365DSCHost -Message "    |---[$i/$($getValue.Count)] $displayedKey" -DeferWrite
                $params = @{
                    Id                    = $config.Id
                    DisplayName           = $config.DisplayName
                    Ensure                = 'Present'
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
                $rawResults = $Results.Clone()
                $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                    -ConnectionMode $ConnectionMode `
                    -ModulePath $this.GetModulePath() `
                    -Results $Results `
                    -Credential $this.Credential `
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
            ExcludedProperties = @('AccountId', 'TokenExpirationDateTime', 'WifiPassword')
        }
    }

    hidden [IntuneDeviceManagementAndroidDeviceOwnerEnrollmentProfile] AsResult([System.Object] $Values)
    {
        if ($Values -is [IntuneDeviceManagementAndroidDeviceOwnerEnrollmentProfile])
        {
            return $Values
        }

        $result = [IntuneDeviceManagementAndroidDeviceOwnerEnrollmentProfile]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
