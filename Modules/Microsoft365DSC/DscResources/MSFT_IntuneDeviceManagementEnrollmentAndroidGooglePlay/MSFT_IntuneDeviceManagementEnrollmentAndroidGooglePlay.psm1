using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class IntuneDeviceManagementEnrollmentAndroidGooglePlay : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('Primary key identifier of the Android Managed Store Account Enterprise Setting.')]
    [System.String] $Id

    [DscProperty()]
    [System.ComponentModel.Description('Binding status of the Android Managed Store Account Enterprise Setting (e.g., ''bound'', ''notBound'').')]
    [System.String] $BindStatus

    [DscProperty()]
    [System.ComponentModel.Description('The user principal name of the owner of the Android Managed Store Account.')]
    [System.String] $OwnerUserPrincipalName

    [DscProperty()]
    [System.ComponentModel.Description('The organization name of the owner of the Android Managed Store Account.')]
    [System.String] $OwnerOrganizationName

    [DscProperty()]
    [System.ComponentModel.Description('Specifies the enrollment target for the account enterprise setting (e.g., ''defaultEnrollmentRestrictions'', ''targetedAsEnrollmentRestrictions'').')]
    [System.String] $EnrollmentTarget

    [DscProperty()]
    [System.ComponentModel.Description('Specifies the display names of the groups that are targeted when the enrollment target is a targeted one.')]
    [System.String[]] $TargetGroups

    [DscProperty()]
    [System.ComponentModel.Description('Specifies whether device owner management is enabled.')]
    [System.Nullable[System.Boolean]] $DeviceOwnerManagementEnabled

    [DscProperty()]
    [System.ComponentModel.Description('Specifies whether fully managed enrollment is enabled for Android devices.')]
    [System.Nullable[System.Boolean]] $AndroidDeviceOwnerFullyManagedEnrollmentEnabled

    [DscProperty()]
    [System.ComponentModel.Description('Specifies the initial scope tags applied to managed Google Play apps.')]
    [System.String[]] $ManagedGooglePlayInitialScopeTagIds

    [DscProperty()]
    [System.ComponentModel.Description('Present ensures the instance exists, absent ensures it is removed.')]
    [ValidateSet('Absent', 'Present')]
    [System.String] $Ensure

    [DscProperty()]
    [System.ComponentModel.Description('Credentials of the workload''s Admin.')]
    [System.Management.Automation.PSCredential] $Credential

    [DscProperty()]
    [System.ComponentModel.Description('Id of the Azure Active Directory application to authenticate with.')]
    [System.String] $ApplicationId

    [DscProperty()]
    [System.ComponentModel.Description('Id of the Azure Active Directory tenant used for authentication.')]
    [System.String] $TenantId

    [DscProperty()]
    [System.ComponentModel.Description('Credential for the application secret used in authentication.')]
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
    [System.ComponentModel.Description('Indicates whether a Managed Identity is used for authentication.')]
    [System.Nullable[System.Boolean]] $ManagedIdentity

    [DscProperty()]
    [System.ComponentModel.Description('Access tokens used for authentication in scenarios requiring multiple tokens.')]
    [System.String[]] $AccessTokens

    # Export-only. Not part of the resource schema.
    [System.String] $Filter

    [IntuneDeviceManagementEnrollmentAndroidGooglePlay] Get()
    {
        $specificSetting = $null
        if ($this.RequiresPowerShellCore())
        {
            $remote = [IntuneDeviceManagementEnrollmentAndroidGooglePlay]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of the Intune Device Management Android Google Play Enrollment with Id {$($this.Id)}"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.Id -ne $this.Id)
            {
                $null = $this.Connect('MicrosoftGraph')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullResult = $this.GetBoundParameters()
                $nullResult.Ensure = 'Absent'

                if (-not [string]::IsNullOrEmpty($this.Id))
                {
                    $allSettings = Get-MgBetaDeviceManagementAndroidManagedStoreAccountEnterpriseSetting
                    $specificSetting = $allSettings | Where-Object { $_.id -eq $this.Id }
                }

                if (-not $specificSetting)
                {
                    Write-Verbose "No Android Managed Store Account Enterprise Setting found with Id $($this.Id)."
                    return $this.AsResult($nullResult)
                }
            }
            else
            {
                $specificSetting = $this.ExportedInstance
            }

            $resolvedTargetGroups = @()
            foreach ($targetGroupId in @($specificSetting.targetGroupIds))
            {
                $displayName = Get-M365DSCGroupDisplayNameById -GroupId $targetGroupId
                if (-not [System.String]::IsNullOrEmpty($displayName))
                {
                    $resolvedTargetGroups += $displayName
                }
            }

            $result = @{
                Id                                              = $specificSetting.id
                BindStatus                                      = $specificSetting.bindStatus
                OwnerUserPrincipalName                          = $specificSetting.ownerUserPrincipalName
                OwnerOrganizationName                           = $specificSetting.ownerOrganizationName
                EnrollmentTarget                                = $specificSetting.enrollmentTarget
                TargetGroups                                    = $resolvedTargetGroups
                DeviceOwnerManagementEnabled                    = $specificSetting.deviceOwnerManagementEnabled
                AndroidDeviceOwnerFullyManagedEnrollmentEnabled = $specificSetting.androidDeviceOwnerFullyManagedEnrollmentEnabled
                ManagedGooglePlayInitialScopeTagIds             = ([Array]$specificSetting.managedGooglePlayInitialScopeTagIds)
                Ensure                                          = 'Present'
                Credential                                      = $this.Credential
                ApplicationId                                   = $this.ApplicationId
                TenantId                                        = $this.TenantId
                ApplicationSecret                               = $this.ApplicationSecret
                CertificateThumbprint                           = $this.CertificateThumbprint
                CertificatePath                                 = $this.CertificatePath
                CertificatePassword                             = $this.CertificatePassword
                ManagedIdentity                                 = $this.ManagedIdentity
                AccessTokens                                    = $this.AccessTokens
            }

            return $this.AsResult($result)

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

        Write-Verbose -Message "WARNING: This resource is currently read-only. This means you can use it to monitor for drifts, but it can't automate any configuration changes. The APIs associated with the binding process are owned by Google."
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
            [array] $getValue = Get-MgBetaDeviceManagementAndroidManagedStoreAccountEnterpriseSetting `
                -ErrorAction Stop

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

    hidden [IntuneDeviceManagementEnrollmentAndroidGooglePlay] AsResult([System.Object] $Values)
    {
        if ($Values -is [IntuneDeviceManagementEnrollmentAndroidGooglePlay])
        {
            return $Values
        }

        $result = [IntuneDeviceManagementEnrollmentAndroidGooglePlay]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
