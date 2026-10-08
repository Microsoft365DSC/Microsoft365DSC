using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class EXOIRMConfiguration : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('Only valid value is ''Yes''.')]
    [ValidateSet('Yes')]
    [System.String] $IsSingleInstance

    [DscProperty()]
    [System.ComponentModel.Description('The AutomaticServiceUpdateEnabled parameter specifies whether to allow the automatic addition of new features within Azure Information Protection for your cloud-based organization.')]
    [System.Nullable[System.Boolean]] $AutomaticServiceUpdateEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The AzureRMSLicensingEnabled parameter specifies whether the Exchange Online organization can to connect directly to Azure Rights Management.')]
    [System.Nullable[System.Boolean]] $AzureRMSLicensingEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The DecryptAttachmentForEncryptOnly parameter specifies whether mail recipients have unrestricted rights on the attachment or not for Encrypt-only mails sent using Microsoft Purview Message Encryption.')]
    [System.Nullable[System.Boolean]] $DecryptAttachmentForEncryptOnly

    [DscProperty()]
    [System.ComponentModel.Description('The EDiscoverySuperUserEnabled parameter specifies whether members of the Discovery Management role group can access IRM-protected messages in a discovery mailbox that were returned by a discovery search.')]
    [System.Nullable[System.Boolean]] $EDiscoverySuperUserEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The EnablePdfEncryption parameter specifies whether to enable the encryption of PDF attachments using Microsoft Purview Message Encryption. ')]
    [System.Nullable[System.Boolean]] $EnablePdfEncryption

    [DscProperty()]
    [System.ComponentModel.Description('The InternalLicensingEnabled parameter specifies whether to enable IRM features for messages that are sent to internal and external recipients.')]
    [System.Nullable[System.Boolean]] $InternalLicensingEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The JournalReportDecryptionEnabled parameter specifies whether to enable journal report decryption.')]
    [System.Nullable[System.Boolean]] $JournalReportDecryptionEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The LicensingLocation parameter specifies the RMS licensing URLs. You can specify multiple URL values separated by commas.')]
    [System.String[]] $LicensingLocation

    [DscProperty()]
    [System.ComponentModel.Description('This parameter is available only in the cloud-based service.')]
    [System.Nullable[System.Boolean]] $RejectIfRecipientHasNoRights

    [DscProperty()]
    [System.ComponentModel.Description('The RMSOnlineKeySharingLocation parameter specifies the Azure Rights Management URL that''s used to get the trusted publishing domain (TPD) for the Exchange Online organization.')]
    [System.String] $RMSOnlineKeySharingLocation

    [DscProperty()]
    [System.ComponentModel.Description('The SearchEnabled parameter specifies whether to enable searching of IRM-encrypted messages in Outlook on the web (formerly known as Outlook Web App).')]
    [System.Nullable[System.Boolean]] $SearchEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The SimplifiedClientAccessDoNotForwardDisabled parameter specifies whether to disable Do not forward in Outlook on the web.')]
    [System.Nullable[System.Boolean]] $SimplifiedClientAccessDoNotForwardDisabled

    [DscProperty()]
    [System.ComponentModel.Description('The SimplifiedClientAccessEnabled parameter specifies whether to enable the Protect button in Outlook on the web.')]
    [System.Nullable[System.Boolean]] $SimplifiedClientAccessEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The SimplifiedClientAccessEncryptOnlyDisabled parameter specifies whether to disable Encrypt only in Outlook on the web. ')]
    [System.Nullable[System.Boolean]] $SimplifiedClientAccessEncryptOnlyDisabled

    [DscProperty()]
    [System.ComponentModel.Description('The TransportDecryptionSetting parameter specifies the transport decryption configuration.')]
    [ValidateSet('Disabled', 'Mandatory', 'Optional')]
    [System.String] $TransportDecryptionSetting

    [DscProperty()]
    [System.ComponentModel.Description('Credentials of the Exchange Global Admin')]
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

    [EXOIRMConfiguration] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [EXOIRMConfiguration]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message 'Getting IRM Configuration'

        try
        {
            if (-not $this.ExportedInstance)
            {
                $null = $this.Connect('ExchangeOnline')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $IRMConfiguration = Get-IRMConfiguration -ErrorAction Stop
            }
            else
            {
                $IRMConfiguration = $this.ExportedInstance
            }

            Write-Verbose -Message 'Found IRM configuration '

            $RMSOnlineKeySharingLocationValue = $null
            if ($IRMConfiguration.RMSOnlineKeySharingLocation)
            {
                $RMSOnlineKeySharingLocationValue = $IRMConfiguration.RMSOnlineKeySharingLocation.ToString()
            }

            $LicensingLocationValue = $null
            if ($IRMConfiguration.LicensingLocation)
            {
                $LicensingLocationValue = [System.String[]]$IRMConfiguration.LicensingLocation.OriginalString
            }

            $result = @{
                IsSingleInstance                           = 'Yes'
                AutomaticServiceUpdateEnabled              = $IRMConfiguration.AutomaticServiceUpdateEnabled
                AzureRMSLicensingEnabled                   = $IRMConfiguration.AzureRMSLicensingEnabled
                DecryptAttachmentForEncryptOnly            = $IRMConfiguration.DecryptAttachmentForEncryptOnly
                EDiscoverySuperUserEnabled                 = $IRMConfiguration.EDiscoverySuperUserEnabled
                EnablePdfEncryption                        = $IRMConfiguration.EnablePdfEncryption
                InternalLicensingEnabled                   = $IRMConfiguration.InternalLicensingEnabled
                JournalReportDecryptionEnabled             = $IRMConfiguration.JournalReportDecryptionEnabled
                LicensingLocation                          = $LicensingLocationValue
                RejectIfRecipientHasNoRights               = $IRMConfiguration.RejectIfRecipientHasNoRights
                RMSOnlineKeySharingLocation                = $RMSOnlineKeySharingLocationValue
                SearchEnabled                              = $IRMConfiguration.SearchEnabled
                SimplifiedClientAccessDoNotForwardDisabled = $IRMConfiguration.SimplifiedClientAccessDoNotForwardDisabled
                SimplifiedClientAccessEnabled              = $IRMConfiguration.SimplifiedClientAccessEnabled
                SimplifiedClientAccessEncryptOnlyDisabled  = $IRMConfiguration.SimplifiedClientAccessEncryptOnlyDisabled
                TransportDecryptionSetting                 = $IRMConfiguration.TransportDecryptionSetting
                Credential                                 = $this.Credential
                ApplicationId                              = $this.ApplicationId
                CertificateThumbprint                      = $this.CertificateThumbprint
                CertificatePath                            = $this.CertificatePath
                CertificatePassword                        = $this.CertificatePassword
                ManagedIdentity                            = $this.ManagedIdentity
                TenantId                                   = $this.TenantId
                AccessTokens                               = $this.AccessTokens
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

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        Write-Verbose -Message 'Setting configuration of Resource Configuration'

        $boundParameters = $this.GetBoundParameters()

        $null = $this.Connect('ExchangeOnline')

        $IRMConfigurationParams = Remove-M365DSCAuthenticationParameter -BoundParameters $boundParameters
        $IRMConfigurationParams.Remove('IsSingleInstance') | Out-Null

        if ($null -ne $IRMConfigurationParams)
        {
            Write-Verbose -Message "Setting IRM Configuration with values: $(Convert-M365DscHashtableToString -Hashtable $IRMConfigurationParams)"
            Set-IRMConfiguration @IRMConfigurationParams -Confirm:$false

            Write-Verbose -Message 'IRM Configuration updated successfully'
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

        $ConnectionMode = $this.Connect('ExchangeOnline')

        #Ensure the proper dependencies are installed in the current environment.
        Confirm-M365DSCDependencies

        #region Telemetry
        $this.AddTelemetry('Export')

        #endregion
        try
        {
            if ($null -ne $Global:M365DSCExportResourceInstancesCount)
            {
                $Global:M365DSCExportResourceInstancesCount++
            }

            $IRMConfiguration = Get-IRMConfiguration -ErrorAction Stop
            $dscContent = [System.Text.StringBuilder]::new()
            Write-M365DSCHost -Message "`r`n" -DeferWrite
            Write-M365DSCHost -Message "    |---[1/1] $($IRMConfiguration.Identity)" -DeferWrite

            $Params = @{
                IsSingleInstance      = 'Yes'
                Credential            = $this.Credential
                ApplicationId         = $this.ApplicationId
                TenantId              = $this.TenantId
                CertificateThumbprint = $this.CertificateThumbprint
                CertificatePassword   = $this.CertificatePassword
                ManagedIdentity       = $this.ManagedIdentity
                CertificatePath       = $this.CertificatePath
                AccessTokens          = $this.AccessTokens
            }
            $this.ExportedInstance = $IRMConfiguration
            $Results = $this.GetForExport($Params)
            $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                -ConnectionMode $ConnectionMode `
                -ModulePath $this.GetModulePath() `
                -Results $Results `
                -Credential $this.Credential
            [void]$dscContent.Append($currentDSCBlock)
            Save-M365DSCPartialExport -Content $currentDSCBlock `
                -FileName $Global:PartialExportFileName
            Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            return $dscContent.ToString()
        }
        catch
        {
            $this.LogError($_, 'Error during Export:')

            throw
        }
    }

    hidden [EXOIRMConfiguration] AsResult([System.Object] $Values)
    {
        if ($Values -is [EXOIRMConfiguration])
        {
            return $Values
        }

        $result = [EXOIRMConfiguration]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
