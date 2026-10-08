using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class IntuneAppleMDMPushNotificationCertificate : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The name of the Apple Identifier.')]
    [System.String] $AppleIdentifier

    [DscProperty()]
    [System.ComponentModel.Description('The Apple Push notification certificate.')]
    [System.String] $Certificate

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether the data sharing consent between Intune and Apple is granted.')]
    [System.Nullable[System.Boolean]] $DataSharingConsentGranted

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

    [IntuneAppleMDMPushNotificationCertificate] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [IntuneAppleMDMPushNotificationCertificate]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of the Intune Apple Push Notification Certificate with Id {$($this.AppleIdentifier)}."

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.AppleIdentifier -ne $this.AppleIdentifier)
            {
                $null = $this.Connect('MicrosoftGraph')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullResult = $this.GetBoundParameters()
                $nullResult.Ensure = 'Absent'

                # There is only one Apple push notification certificate per tenant so no need to filter by Id
                $instance = Get-MgBetaDeviceManagementApplePushNotificationCertificate -ErrorAction SilentlyContinue

                if ($null -eq $instance)
                {
                    Write-Verbose -Message "No Intune Apple MDM Push Notification Certificate with Id {$($this.AppleIdentifier)}."

                    $absentConsentInstance = Get-MgBetaDeviceManagementDataSharingConsent -DataSharingConsentId 'appleMDMPushCertificate'
                    $nullResult.DataSharingConsentGranted = $absentConsentInstance.Granted

                    return $this.AsResult($nullResult)
                }
            }
            else
            {
                $instance = $this.ExportedInstance
            }

            $results = @{
                AppleIdentifier       = $instance.AppleIdentifier
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

            if (-not [String]::IsNullOrEmpty($instance.Certificate))
            {
                $results.Add('Certificate', $instance.Certificate)
            }
            else
            {
                $results.Add('Certificate', '')
            }

            # Get the value of Data sharing consent between Intune and Apple. The id is hardcoded to "appleMDMPushCertificate".
            $consentInstance = Get-MgBetaDeviceManagementDataSharingConsent -DataSharingConsentId 'appleMDMPushCertificate'
            $results.Add('DataSharingConsentGranted', $consentInstance.Granted)

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

        $SetParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()
        $SetParameters = Rename-M365DSCCimInstanceParameter -Properties $SetParameters
        $SetParameters.Remove('DataSharingConsentGranted') | Out-Null

        # Apple refuses the certificate until the data sharing consent is granted, and Intune offers no way to revoke it afterwards.
        if ($this.Ensure -eq 'Present')
        {
            $consentInstance = Get-MgBetaDeviceManagementDataSharingConsent -DataSharingConsentId 'appleMDMPushCertificate'
            $grantConsent = $this.DataSharingConsentGranted -eq $true -or
                ($null -eq $this.DataSharingConsentGranted -and $currentInstance.Ensure -eq 'Absent')

            if ($grantConsent -and $consentInstance.Granted -ne $true)
            {
                Invoke-M365DSCGraphRequest -Method POST -Uri '/beta/deviceManagement/dataSharingConsents/appleMDMPushCertificate/consentToDataSharing' -Headers @{ 'Content-Type' = 'application/json' }
            }
            elseif ($this.DataSharingConsentGranted -eq $false -and $consentInstance.Granted -eq $true)
            {
                Write-M365DSCHost -Message 'The data sharing consent between Intune and Apple is already granted and cannot be revoked.'
            }
        }

        # CREATE
        if ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Creating an Intune Apple Push Notification Certificate with Apple ID: '$($this.AppleIdentifier)'."

            # There is only PATCH request hence using Update cmdlet to post the certificate
            Update-MgBetaDeviceManagementApplePushNotificationCertificate -BodyParameter $SetParameters
        }
        # UPDATE
        elseif ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Updating the Intune Apple Push Notification Certificate with Apple ID: '$($this.AppleIdentifier)'."
            Update-MgBetaDeviceManagementApplePushNotificationCertificate -BodyParameter $SetParameters
        }
        # REMOVE
        elseif ($this.Ensure -eq 'Absent' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Removing the Intune Apple Push Notification Certificate with Apple ID: '$($this.AppleIdentifier)' by patching with empty certificate."

            # There is only PATCH request hence using Update cmdlet to remove the certificate by passing empty certificate as param.
            $params = @{
                appleIdentifier = ''
                certificate     = ''
            }
            Update-MgBetaDeviceManagementApplePushNotificationCertificate -BodyParameter $params
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
            [array]$getValue = Get-MgBetaDeviceManagementApplePushNotificationCertificate -ErrorAction SilentlyContinue

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
                Write-M365DSCHost -Message "    |---[$i/$($getValue.Count)] $displayedKey" -DeferWrite

                $Params = @{
                    AppleIdentifier       = $config.AppleIdentifier
                    Certificate           = $config.Certificate
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

                # Get the value of Data sharing consent between Intune and Apple. The id is hardcoded to "appleMDMPushCertificate".
                $consentInstance = Get-MgBetaDeviceManagementDataSharingConsent -DataSharingConsentId 'appleMDMPushCertificate'
                $Params.Add('DataSharingConsentGranted', $consentInstance.Granted)

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

    hidden [IntuneAppleMDMPushNotificationCertificate] AsResult([System.Object] $Values)
    {
        if ($Values -is [IntuneAppleMDMPushNotificationCertificate])
        {
            return $Values
        }

        $result = [IntuneAppleMDMPushNotificationCertificate]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
