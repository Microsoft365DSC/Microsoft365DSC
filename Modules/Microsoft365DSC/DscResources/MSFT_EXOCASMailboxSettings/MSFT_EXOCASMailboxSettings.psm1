using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class EXOCASMailboxSettings : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The Identity parameter specifies the mailbox that you want to configure.')]
    [System.String] $Identity

    [DscProperty()]
    [System.ComponentModel.Description('TheActiveSyncAllowedDeviceIDs parameter specifies one or more Exchange ActiveSync device IDs that are allowed to synchronize with the mailbox.')]
    [System.String[]] $ActiveSyncAllowedDeviceIDs

    [DscProperty()]
    [System.ComponentModel.Description('The ActiveSyncBlockedDeviceIDs parameter specifies one or more Exchange ActiveSync device IDs that aren''t allowed to synchronize with the mailbox.')]
    [System.String[]] $ActiveSyncBlockedDeviceIDs

    [DscProperty()]
    [System.ComponentModel.Description('The ActiveSyncDebugLogging parameter enables or disables Exchange ActiveSync debug logging for the mailbox.')]
    [System.Nullable[System.Boolean]] $ActiveSyncDebugLogging

    [DscProperty()]
    [System.ComponentModel.Description('The ActiveSyncEnabled parameter enables or disables access to the mailbox using Exchange ActiveSync.')]
    [System.Nullable[System.Boolean]] $ActiveSyncEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The ActiveSyncMailboxPolicy parameter specifies the Exchange ActiveSync mailbox policy for the mailbox.')]
    [System.String] $ActiveSyncMailboxPolicy

    [DscProperty()]
    [System.ComponentModel.Description('The ActiveSyncSuppressReadReceipt parameter controls the behavior of read receipts for Exchange ActiveSync clients that access the mailbox.')]
    [System.Nullable[System.Boolean]] $ActiveSyncSuppressReadReceipt

    [DscProperty()]
    [System.ComponentModel.Description('The EwsAllowEntourage parameter enables or disables access to the mailbox by Microsoft Entourage clients that use Exchange Web Services.')]
    [System.Nullable[System.Boolean]] $EwsAllowEntourage

    [DscProperty()]
    [System.ComponentModel.Description('The EwsAllowList parameter specifies the Exchange Web Services applications (user agent strings) that are allowed to access the mailbox.')]
    [System.String[]] $EwsAllowList

    [DscProperty()]
    [System.ComponentModel.Description('The EwsAllowMacOutlook parameter enables or disables access to the mailbox by Outlook for Mac clients that use Exchange Web Services.')]
    [System.Nullable[System.Boolean]] $EwsAllowMacOutlook

    [DscProperty()]
    [System.ComponentModel.Description('The EwsAllowOutlook parameter enables or disables access to the mailbox by Outlook clients that use Exchange Web Services.')]
    [System.Nullable[System.Boolean]] $EwsAllowOutlook

    [DscProperty()]
    [System.ComponentModel.Description('The EwsApplicationAccessPolicy parameter controls access to the mailbox using Exchange Web Services applications.')]
    [System.String] $EwsApplicationAccessPolicy

    [DscProperty()]
    [System.ComponentModel.Description('The EwsBlockList parameter specifies the Exchange Web Services applications (user agent strings) that aren''t allowed to access the mailbox using Exchange Web Services.')]
    [System.String[]] $EwsBlockList

    [DscProperty()]
    [System.ComponentModel.Description('The EwsEnabled parameter enables or disables access to the mailbox using Exchange Web Services clients.')]
    [System.Nullable[System.Boolean]] $EwsEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The ImapEnabled parameter enables or disables access to the mailbox using IMAP4 clients.')]
    [System.Nullable[System.Boolean]] $ImapEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The ImapMessagesRetrievalMimeFormat parameter specifies the message format for IMAP4 clients that access the mailbox.')]
    [System.String] $ImapMessagesRetrievalMimeFormat

    [DscProperty()]
    [System.ComponentModel.Description('The ImapForceICalForCalendarRetrievalOption parameter specifies how meeting requests are presented to IMAP4 clients that access the mailbox.')]
    [System.Nullable[System.Boolean]] $ImapForceICalForCalendarRetrievalOption

    [DscProperty()]
    [System.ComponentModel.Description('The ImapSuppressReadReceipt parameter controls the behavior of read receipts for IMAP4 clients that access the mailbox.')]
    [System.Nullable[System.Boolean]] $ImapSuppressReadReceipt

    [DscProperty()]
    [System.ComponentModel.Description('The ImapUseProtocolDefaults parameter specifies whether to use the IMAP4 protocol defaults for the mailbox.')]
    [System.Nullable[System.Boolean]] $ImapUseProtocolDefaults

    [DscProperty()]
    [System.ComponentModel.Description('The MacOutlookEnabled parameter enables or disables access to the mailbox using Outlook for Mac clients that use Microsoft Sync technology.')]
    [System.Nullable[System.Boolean]] $MacOutlookEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The MAPIEnabled parameter enables or disables access to the mailbox using MAPI clients (for example, Outlook).')]
    [System.Nullable[System.Boolean]] $MAPIEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The OneWinNativeOutlookEnabled parameter enables or disables access to the mailbox using the new Outlook for Windows.')]
    [System.Nullable[System.Boolean]] $OneWinNativeOutlookEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The OutlookMobileEnabled parameter enables or disables access to the mailbox using Outlook for iOS and Android.')]
    [System.Nullable[System.Boolean]] $OutlookMobileEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The OWAEnabled parameter enables or disables access to the mailbox using Outlook on the web (formerly known as Outlook Web App or OWA).')]
    [System.Nullable[System.Boolean]] $OWAEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The OWAforDevicesEnabled parameter enables or disables access to the mailbox using the older Outlook Web App (OWA) app on iOS and Android devices.')]
    [System.Nullable[System.Boolean]] $OWAforDevicesEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The OwaMailboxPolicy parameter specifies the Outlook on the web mailbox policy for the mailbox.')]
    [System.String] $OwaMailboxPolicy

    [DscProperty()]
    [System.ComponentModel.Description('The PopEnabled parameter enables or disables access to the mailbox using POP3 clients.')]
    [System.Nullable[System.Boolean]] $PopEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The PopForceICalForCalendarRetrievalOption parameter specifies how meeting requests are presented to POP3 clients that access the mailbox.')]
    [System.Nullable[System.Boolean]] $PopForceICalForCalendarRetrievalOption

    [DscProperty()]
    [System.ComponentModel.Description('The PopMessagesRetrievalMimeFormat parameter specifies the message format for POP3 clients that access the mailbox.')]
    [System.String] $PopMessagesRetrievalMimeFormat

    [DscProperty()]
    [System.ComponentModel.Description('The PopSuppressReadReceipt parameter controls the behavior of read receipts for POP3 clients that access the mailbox.')]
    [System.Nullable[System.Boolean]] $PopSuppressReadReceipt

    [DscProperty()]
    [System.ComponentModel.Description('The PopUseProtocolDefaults parameter specifies whether to use the POP3 protocol defaults for the mailbox.')]
    [System.Nullable[System.Boolean]] $PopUseProtocolDefaults

    [DscProperty()]
    [System.ComponentModel.Description('The PublicFolderClientAccess parameter enables or disables access to public folders in Microsoft Outlook.')]
    [System.Nullable[System.Boolean]] $PublicFolderClientAccess

    [DscProperty()]
    [System.ComponentModel.Description('The ShowGalAsDefaultView parameter specifies whether the global address list (GAL) is the default recipient picker for messages.')]
    [System.Nullable[System.Boolean]] $ShowGalAsDefaultView

    [DscProperty()]
    [System.ComponentModel.Description('The SmtpClientAuthenticationDisabled parameter specifies whether to disable authenticated SMTP (SMTP AUTH) for the mailbox.')]
    [System.Nullable[System.Boolean]] $SmtpClientAuthenticationDisabled

    [DscProperty()]
    [System.ComponentModel.Description('The UniversalOutlookEnabled parameter enables or disables access to the mailbox using Windows 10 Mail and Calendar.')]
    [System.Nullable[System.Boolean]] $UniversalOutlookEnabled

    [DscProperty()]
    [System.ComponentModel.Description('Present ensures the Mailbox CAS settings are applied. This resource cannot be removed and the value must be set to ''Ensure''.')]
    [ValidateSet('Present', 'Absent')]
    [System.String] $Ensure

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

    [EXOCASMailboxSettings] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [EXOCASMailboxSettings]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of Exchange Online CAS Mailbox Settings for $($this.Identity)"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.Identity -ne $this.Identity)
            {
                $null = $this.Connect('ExchangeOnline')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullReturn = @{
                    Identity = $this.Identity
                    Ensure   = 'Absent'
                }

                $mailboxCasSettings = Get-CASMailbox -Identity $this.Identity -ErrorAction SilentlyContinue
                if ($null -eq $mailboxCasSettings)
                {
                    Write-Verbose -Message 'The specified Mailbox does not exist.'
                    return $this.AsResult($nullReturn)
                }
            }
            else
            {
                $mailboxCasSettings = $this.ExportedInstance
            }

            Write-Verbose -Message "Found an existing instance of Mailbox '$($this.Identity)'"

            $result = @{
                Ensure                                  = 'Present'
                Identity                                = $this.Identity
                ActiveSyncAllowedDeviceIDs              = $mailboxCasSettings.ActiveSyncAllowedDeviceIDs
                ActiveSyncBlockedDeviceIDs              = $mailboxCasSettings.ActiveSyncBlockedDeviceIDs
                ActiveSyncDebugLogging                  = $mailboxCasSettings.ActiveSyncDebugLogging
                ActiveSyncEnabled                       = $mailboxCasSettings.ActiveSyncEnabled
                ActiveSyncMailboxPolicy                 = $mailboxCasSettings.ActiveSyncMailboxPolicy
                ActiveSyncSuppressReadReceipt           = $mailboxCasSettings.ActiveSyncSuppressReadReceipt
                EwsAllowEntourage                       = $mailboxCasSettings.EwsAllowEntourage
                EwsAllowList                            = $mailboxCasSettings.EwsAllowList
                EwsAllowMacOutlook                      = $mailboxCasSettings.EwsAllowMacOutlook
                EwsAllowOutlook                         = $mailboxCasSettings.EwsAllowOutlook
                EwsApplicationAccessPolicy              = $mailboxCasSettings.EwsApplicationAccessPolicy
                EwsBlockList                            = $mailboxCasSettings.EwsBlockList
                EwsEnabled                              = $mailboxCasSettings.EwsEnabled
                ImapEnabled                             = $mailboxCasSettings.ImapEnabled
                ImapMessagesRetrievalMimeFormat         = $mailboxCasSettings.ImapMessagesRetrievalMimeFormat
                ImapForceICalForCalendarRetrievalOption = $mailboxCasSettings.ImapForceICalForCalendarRetrievalOption
                ImapSuppressReadReceipt                 = $mailboxCasSettings.ImapSuppressReadReceipt
                ImapUseProtocolDefaults                 = $mailboxCasSettings.ImapUseProtocolDefaults
                MacOutlookEnabled                       = $mailboxCasSettings.MacOutlookEnabled
                MAPIEnabled                             = $mailboxCasSettings.MAPIEnabled
                OneWinNativeOutlookEnabled              = $mailboxCasSettings.OneWinNativeOutlookEnabled
                OutlookMobileEnabled                    = $mailboxCasSettings.OutlookMobileEnabled
                OWAEnabled                              = $mailboxCasSettings.OWAEnabled
                OWAforDevicesEnabled                    = $mailboxCasSettings.OWAforDevicesEnabled
                OwaMailboxPolicy                        = $mailboxCasSettings.OwaMailboxPolicy
                PopEnabled                              = $mailboxCasSettings.PopEnabled
                PopForceICalForCalendarRetrievalOption  = $mailboxCasSettings.PopForceICalForCalendarRetrievalOption
                PopMessagesRetrievalMimeFormat          = $mailboxCasSettings.PopMessagesRetrievalMimeFormat
                PopSuppressReadReceipt                  = $mailboxCasSettings.PopSuppressReadReceipt
                PopUseProtocolDefaults                  = $mailboxCasSettings.PopUseProtocolDefaults
                PublicFolderClientAccess                = $mailboxCasSettings.PublicFolderClientAccess
                ShowGalAsDefaultView                    = $mailboxCasSettings.ShowGalAsDefaultView
                SmtpClientAuthenticationDisabled        = $mailboxCasSettings.SmtpClientAuthenticationDisabled
                UniversalOutlookEnabled                 = $mailboxCasSettings.UniversalOutlookEnabled
                Credential                              = $this.Credential
                ApplicationId                           = $this.ApplicationId
                CertificateThumbprint                   = $this.CertificateThumbprint
                CertificatePath                         = $this.CertificatePath
                CertificatePassword                     = $this.CertificatePassword
                ManagedIdentity                         = $this.ManagedIdentity
                TenantId                                = $this.TenantId
                AccessTokens                            = $this.AccessTokens
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

        Write-Verbose -Message "Setting configuration of Exchange Online CAS Mailbox settings for $($this.Identity)"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $null = $this.Get().ToHashtable()
        $CASMailboxParams = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()

        # CASE: Mailbox exists;
        Write-Verbose -Message "Setting CAS Mailbox settings for $($this.Identity) with values: $(Convert-M365DscHashtableToString -Hashtable $CASMailboxParams)"
        Set-CASMailbox @CASMailboxParams -Confirm:$false
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

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Export')

        try
        {
            [array]$mailboxes = Get-CASMailbox -ResultSize 'Unlimited'

            $i = 1
            if ($mailboxes.Count -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message "`r`n"-DeferWrite
            }
            $dscContent = [System.Text.StringBuilder]::new()
            foreach ($mailbox in $mailboxes)
            {
                Write-M365DSCHost -Message "    |---[$i/$($mailboxes.Count)] $($mailbox.Name)" -DeferWrite
                $mailboxName = $mailbox.Identity
                if (![System.String]::IsNullOrEmpty($mailboxName))
                {
                    if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                    {
                        $Global:M365DSCExportResourceInstancesCount++
                    }

                    $Params = @{
                        Credential            = $this.Credential
                        Identity              = $mailboxName
                        ApplicationId         = $this.ApplicationId
                        TenantId              = $this.TenantId
                        CertificateThumbprint = $this.CertificateThumbprint
                        CertificatePassword   = $this.CertificatePassword
                        ManagedIdentity       = $this.ManagedIdentity
                        CertificatePath       = $this.CertificatePath
                        AccessTokens          = $this.AccessTokens
                    }
                    $this.ExportedInstance = $mailbox
                    $Results = $this.GetForExport($Params)
                    $rawResults = $Results.Clone()
                    if ($Results -is [System.Collections.Hashtable] -and $Results.Count -gt 1)
                    {
                        $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                            -ConnectionMode $ConnectionMode `
                            -ModulePath $this.GetModulePath() `
                            -Results $Results `
                            -Credential $this.Credential `
                            -RawResults $rawResults
                        [void]$dscContent.Append($currentDSCBlock)
                        Save-M365DSCPartialExport -Content $currentDSCBlock `
                            -FileName $Global:PartialExportFileName

                        Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
                    }
                    else
                    {
                        Write-M365DSCHost -Message $Global:M365DSCEmojiRedX -CommitWrite
                    }
                }

                $i++
            }

            return $dscContent.ToString()
        }
        catch
        {
            $this.LogError($_, 'Error during Export:')

            throw
        }
    }

    hidden [EXOCASMailboxSettings] AsResult([System.Object] $Values)
    {
        if ($Values -is [EXOCASMailboxSettings])
        {
            return $Values
        }

        $result = [EXOCASMailboxSettings]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
