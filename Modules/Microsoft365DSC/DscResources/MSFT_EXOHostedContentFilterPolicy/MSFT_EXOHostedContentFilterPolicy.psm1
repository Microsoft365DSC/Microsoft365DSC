using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class EXOHostedContentFilterPolicy : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The Identity parameter specifies the name of the Hosted Content Filter Policy that you want to modify.')]
    [System.String] $Identity

    [DscProperty()]
    [System.ComponentModel.Description('The AddXHeaderValue parameter specifies the X-header value to add to spam messages when an action parameter is set to the value AddXHeader.')]
    [System.String] $AddXHeaderValue

    [DscProperty()]
    [System.ComponentModel.Description('The AdminDisplayName parameter specifies a description for the policy.')]
    [System.String] $AdminDisplayName

    [DscProperty()]
    [System.ComponentModel.Description('The AllowedSenderDomains parameter specifies trusted domains that aren''t processed by the spam filter.')]
    [System.String[]] $AllowedSenderDomains

    [DscProperty()]
    [System.ComponentModel.Description('The AllowedSenders parameter specifies a list of trusted senders that aren''t processed by the spam filter.')]
    [System.String[]] $AllowedSenders

    [DscProperty()]
    [System.ComponentModel.Description('The BlockedSenderDomains parameter specifies domains that are always marked as spam sources.')]
    [System.String[]] $BlockedSenderDomains

    [DscProperty()]
    [System.ComponentModel.Description('The BlockedSenders parameter specifies senders that are always marked as spam sources.')]
    [System.String[]] $BlockedSenders

    [DscProperty()]
    [System.ComponentModel.Description('The BulkQuarantineTag parameter specifies the quarantine policy that''s used on messages that are quarantined as bulk email.')]
    [System.String] $BulkQuarantineTag

    [DscProperty()]
    [System.ComponentModel.Description('The BulkSpamAction parameter specifies the action to take on messages that are classified as bulk email.')]
    [ValidateSet('MoveToJmf', 'AddXHeader', 'ModifySubject', 'Redirect', 'Delete', 'Quarantine', 'NoAction')]
    [System.String] $BulkSpamAction

    [DscProperty()]
    [System.ComponentModel.Description('The BulkThreshold parameter specifies the Bulk Complaint Level (BCL) threshold setting. Valid values are from 1 - 9, where 1 marks most bulk email as spam, and 9 allows the most bulk email to be delivered. The default value is 7.')]
    [ValidateRange(1, 9)]
    [System.Nullable[System.UInt32]] $BulkThreshold

    [DscProperty()]
    [System.ComponentModel.Description('The EnableLanguageBlockList parameter enables or disables blocking email messages that are written in specific languages, regardless of the message contents. Valid input for this parameter is $true or $false. The default value is $false.')]
    [System.Nullable[System.Boolean]] $EnableLanguageBlockList

    [DscProperty()]
    [System.ComponentModel.Description('The EnableRegionBlockList parameter enables or disables blocking email messages that are sent from specific countries or regions, regardless of the message contents. Valid input for this parameter is $true or $false. The default value is $false.')]
    [System.Nullable[System.Boolean]] $EnableRegionBlockList

    [DscProperty()]
    [System.ComponentModel.Description('The HighConfidencePhishAction parameter specifies the action to take on messages that are marked as high confidence phishing')]
    [ValidateSet('MoveToJmf', 'Redirect', 'Quarantine')]
    [System.String] $HighConfidencePhishAction

    [DscProperty()]
    [System.ComponentModel.Description('The HighConfidencePhishQuarantineTag parameter specifies the quarantine policy that''s used on messages that are quarantined as high confidence phishing.')]
    [System.String] $HighConfidencePhishQuarantineTag

    [DscProperty()]
    [System.ComponentModel.Description('The HighConfidenceSpamAction parameter specifies the action to take on messages that are classified as high confidence spam.')]
    [ValidateSet('MoveToJmf', 'AddXHeader', 'ModifySubject', 'Redirect', 'Delete', 'Quarantine', 'NoAction')]
    [System.String] $HighConfidenceSpamAction

    [DscProperty()]
    [System.ComponentModel.Description('The HighConfidenceSpamQuarantineTag parameter specifies the quarantine policy that''s used on messages that are quarantined as high confidence spam.')]
    [System.String] $HighConfidenceSpamQuarantineTag

    [DscProperty()]
    [System.ComponentModel.Description('The IncreaseScoreWithBizOrInfoUrls parameter increases the spam score of messages that contain links to .biz or .info domains. Valid values for this parameter are Off, On or Test. The default value is Off.')]
    [ValidateSet('Off', 'On', 'Test')]
    [System.String] $IncreaseScoreWithBizOrInfoUrls

    [DscProperty()]
    [System.ComponentModel.Description('The IncreaseScoreWithImageLinks parameter increases the spam score of messages that contain image links to remote websites. Valid values for this parameter are Off, On or Test. The default value is Off.')]
    [ValidateSet('Off', 'On', 'Test')]
    [System.String] $IncreaseScoreWithImageLinks

    [DscProperty()]
    [System.ComponentModel.Description('The IncreaseScoreWithNumericIps parameter increases the spam score of messages that contain links to IP addresses. Valid values for this parameter are Off, On or Test. The default value is Off.')]
    [ValidateSet('Off', 'On', 'Test')]
    [System.String] $IncreaseScoreWithNumericIps

    [DscProperty()]
    [System.ComponentModel.Description('The IncreaseScoreWithRedirectToOtherPort parameter increases the spam score of messages that contain links that redirect to other TCP ports. Valid values for this parameter are Off, On or Test. The default value is Off.')]
    [ValidateSet('Off', 'On', 'Test')]
    [System.String] $IncreaseScoreWithRedirectToOtherPort

    [DscProperty()]
    [System.ComponentModel.Description('The InlineSafetyTipsEnabled parameter specifies whether to enable or disable safety tips that are shown to recipients in messages. The default is $true')]
    [System.Nullable[System.Boolean]] $InlineSafetyTipsEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The IntraOrgFilterState parameter specifies whether to enable anti-spam filtering for messages sent between internal users (users in the same organization).')]
    [ValidateSet('Default', 'HighConfidencePhish', 'Phish', 'HighConfidenceSpam', 'Spam', 'Disabled')]
    [System.String] $IntraOrgFilterState

    [DscProperty()]
    [System.ComponentModel.Description('The LanguageBlockList parameter specifies the languages to block when messages are blocked based on their language. Valid input for this parameter is a supported ISO 639-1 lowercase two-letter language code. You can specify multiple values separated by commas. This parameter is only use when the EnableRegionBlockList parameter is set to $true.')]
    [System.String[]] $LanguageBlockList

    [DscProperty()]
    [System.ComponentModel.Description('The MakeDefault parameter makes the specified content filter policy the default content filter policy. The default value is $false')]
    [System.Nullable[System.Boolean]] $MakeDefault

    [DscProperty()]
    [System.ComponentModel.Description('The MarkAsSpamBulkMail parameter classifies the message as spam when the message is identified as a bulk email message. Valid values for this parameter are Off, On or Test. The default value is On.')]
    [ValidateSet('Off', 'On', 'Test')]
    [System.String] $MarkAsSpamBulkMail

    [DscProperty()]
    [System.ComponentModel.Description('The MarkAsSpamEmbedTagsInHtml parameter classifies the message as spam when the message contains HTML <embed> tags. Valid values for this parameter are Off, On or Test. The default value is Off.')]
    [ValidateSet('Off', 'On', 'Test')]
    [System.String] $MarkAsSpamEmbedTagsInHtml

    [DscProperty()]
    [System.ComponentModel.Description('The MarkAsSpamEmptyMessages parameter classifies the message as spam when the message is empty. Valid values for this parameter are Off, On or Test. The default value is Off.')]
    [ValidateSet('Off', 'On', 'Test')]
    [System.String] $MarkAsSpamEmptyMessages

    [DscProperty()]
    [System.ComponentModel.Description('The MarkAsSpamFormTagsInHtml parameter classifies the message as spam when the message contains HTML <form> tags. Valid values for this parameter are Off, On or Test. The default value is Off.')]
    [ValidateSet('Off', 'On', 'Test')]
    [System.String] $MarkAsSpamFormTagsInHtml

    [DscProperty()]
    [System.ComponentModel.Description('The MarkAsSpamFramesInHtml parameter classifies the message as spam when the message contains HTML <frame> or <iframe> tags. Valid values for this parameter are Off, On or Test. The default value is Off.')]
    [ValidateSet('Off', 'On', 'Test')]
    [System.String] $MarkAsSpamFramesInHtml

    [DscProperty()]
    [System.ComponentModel.Description('The MarkAsSpamFromAddressAuthFail parameter classifies the message as spam when Sender ID filtering encounters a hard fail. Valid values for this parameter are Off or On. The default value is Off.')]
    [ValidateSet('Off', 'On', 'Test')]
    [System.String] $MarkAsSpamFromAddressAuthFail

    [DscProperty()]
    [System.ComponentModel.Description('The MarkAsSpamJavaScriptInHtml parameter classifies the message as spam when the message contains JavaScript or VBScript. Valid values for this parameter are Off, On or Test. The default value is Off.')]
    [ValidateSet('Off', 'On', 'Test')]
    [System.String] $MarkAsSpamJavaScriptInHtml

    [DscProperty()]
    [System.ComponentModel.Description('The MarkAsSpamNdrBackscatter parameter classifies the message as spam when the message is a non-delivery report (NDR) to a forged sender. Valid values for this parameter are Off or On. The default value is Off.')]
    [ValidateSet('Off', 'On', 'Test')]
    [System.String] $MarkAsSpamNdrBackscatter

    [DscProperty()]
    [System.ComponentModel.Description('The MarkAsSpamObjectTagsInHtml parameter classifies the message as spam when the message contains HTML <object> tags. Valid values for this parameter are Off, On or Test. The default value is Off.')]
    [ValidateSet('Off', 'On', 'Test')]
    [System.String] $MarkAsSpamObjectTagsInHtml

    [DscProperty()]
    [System.ComponentModel.Description('The MarkAsSpamSensitiveWordList parameter classifies the message as spam when the message contains words from the sensitive words list. Valid values for this parameter are Off, On or Test. The default value is Off.')]
    [ValidateSet('Off', 'On', 'Test')]
    [System.String] $MarkAsSpamSensitiveWordList

    [DscProperty()]
    [System.ComponentModel.Description('The MarkAsSpamSpfRecordHardFail parameter classifies the message as spam when Sender Policy Framework (SPF) record checking encounters a hard fail. Valid values for this parameter are Off or On. The default value is Off.')]
    [ValidateSet('Off', 'On', 'Test')]
    [System.String] $MarkAsSpamSpfRecordHardFail

    [DscProperty()]
    [System.ComponentModel.Description('The MarkAsSpamWebBugsInHtml parameter classifies the message as spam when the message contains web bugs. Valid values for this parameter are Off, On or Test. The default value is Off.')]
    [ValidateSet('Off', 'On', 'Test')]
    [System.String] $MarkAsSpamWebBugsInHtml

    [DscProperty()]
    [System.ComponentModel.Description('The ModifySubjectValue parameter specifies the text to prepend to the existing subject of spam messages when an action parameter is set to the value ModifySubject.')]
    [System.String] $ModifySubjectValue

    [DscProperty()]
    [System.ComponentModel.Description('The PhishSpamAction parameter specifies the action to take on messages that are classified as phishing')]
    [ValidateSet('MoveToJmf', 'AddXHeader', 'ModifySubject', 'Redirect', 'Delete', 'Quarantine', 'NoAction')]
    [System.String] $PhishSpamAction

    [DscProperty()]
    [System.ComponentModel.Description('The PhishQuarantineTag parameter specifies the quarantine policy that''s used on messages that are quarantined as phishing.')]
    [System.String] $PhishQuarantineTag

    [DscProperty()]
    [System.ComponentModel.Description('The SpamQuarantineTag parameter specifies the quarantine policy that''s used on messages that are quarantined as spam.')]
    [System.String] $SpamQuarantineTag

    [DscProperty()]
    [System.ComponentModel.Description('The QuarantineRetentionPeriod parameter specifies the length of time in days that spam messages remain in the quarantine. Valid input for this parameter is an integer between 1 and 30. The default value is 15.')]
    [ValidateRange(1, 30)]
    [System.Nullable[System.UInt32]] $QuarantineRetentionPeriod

    [DscProperty()]
    [System.ComponentModel.Description('The RedirectToRecipients parameter specifies the replacement recipients in spam messages when an action parameter is set to the value Redirect. The action parameters that use the value of RedirectToRecipients are BulkSpamAction, HighConfidencePhishAction, HighConfidenceSpamAction, PhishSpamAction and SpamAction.')]
    [System.String[]] $RedirectToRecipients

    [DscProperty()]
    [System.ComponentModel.Description('The RegionBlockList parameter specifies the region to block when messages are blocked based on their source region. Valid input for this parameter is a supported ISO 3166-1 uppercase two-letter country code. You can specify multiple values separated by commas. This parameter is only used when the EnableRegionBlockList parameter is set to $true.')]
    [System.String[]] $RegionBlockList

    [DscProperty()]
    [System.ComponentModel.Description('The SpamAction parameter specifies the action to take on messages that are classified as spam (not high confidence spam, bulk email, or phishing). ')]
    [ValidateSet('MoveToJmf', 'AddXHeader', 'ModifySubject', 'Redirect', 'Delete', 'Quarantine', 'NoAction')]
    [System.String] $SpamAction

    [DscProperty()]
    [System.ComponentModel.Description('The TestModeAction parameter specifies the additional action to take on messages that match any of the IncreaseScoreWith or MarkAsSpam parameters that are set to the value Test. ')]
    [ValidateSet('None', 'AddXHeader', 'BccMessage')]
    [System.String] $TestModeAction

    [DscProperty()]
    [System.ComponentModel.Description('The TestModeBccToRecipients parameter specifies the blind carbon copy recipients to add to spam messages when the TestModeAction action parameter is set to the value BccMessage.')]
    [System.String[]] $TestModeBccToRecipients

    [DscProperty()]
    [System.ComponentModel.Description('The PhishZapEnabled parameter enables or disables zero-hour auto purge (ZAP) to detect phishing messages in delivered messages in Exchange Online mailboxes.')]
    [System.Nullable[System.Boolean]] $PhishZapEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The SpamZapEnabled parameter enables or disables zero-hour auto purge (ZAP) to detect spam in delivered messages in Exchange Online mailboxes.')]
    [System.Nullable[System.Boolean]] $SpamZapEnabled

    [DscProperty()]
    [System.ComponentModel.Description('Specify if this policy should exist or not.')]
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

    [EXOHostedContentFilterPolicy] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [EXOHostedContentFilterPolicy]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of HostedContentFilterPolicy for $($this.Identity)"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.Identity -ne $this.Identity)
            {
                $null = $this.Connect('ExchangeOnline')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullReturn = $this.GetBoundParameters()
                $nullReturn.Ensure = 'Absent'

                $HostedContentFilterPolicy = Get-HostedContentFilterPolicy -Identity $this.Identity -ErrorAction SilentlyContinue
                if ($null -eq $HostedContentFilterPolicy)
                {
                    Write-Verbose -Message "HostedContentFilterPolicy $($this.Identity) does not exist."
                    return $this.AsResult($nullReturn)
                }
            }
            else
            {
                $HostedContentFilterPolicy = $this.ExportedInstance
            }

            [System.String[]]$AllowedSendersValues = $HostedContentFilterPolicy.AllowedSenders
            [System.String[]]$BlockedSendersValues = $HostedContentFilterPolicy.BlockedSenders
            # Check if the values are null and assign them an empty string array if they are
            if ($null -eq $AllowedSendersValues)
            {
                $AllowedSendersValues = @()
            }
            if ($null -eq $BlockedSendersValues)
            {
                $BlockedSendersValues = @()
            }

            [System.String[]]$AllowedSenderDomainsValues = $HostedContentFilterPolicy.AllowedSenderDomains
            [System.String[]]$BlockedSenderDomainsValues = $HostedContentFilterPolicy.BlockedSenderDomains
            # Check if the values are null and assign them an empty string array if they are
            if ($null -eq $AllowedSenderDomainsValues)
            {
                $AllowedSenderDomainsValues = @()
            }
            if ($null -eq $BlockedSenderDomainsValues)
            {
                $BlockedSenderDomainsValues = @()
            }

            Write-Verbose -Message "Found HostedContentFilterPolicy $($this.Identity)"

            $result = @{
                Ensure                               = 'Present'
                Identity                             = $this.Identity
                AddXHeaderValue                      = $HostedContentFilterPolicy.AddXHeaderValue
                AdminDisplayName                     = $HostedContentFilterPolicy.AdminDisplayName
                AllowedSenderDomains                 = $AllowedSenderDomainsValues
                AllowedSenders                       = $AllowedSendersValues
                BlockedSenderDomains                 = $BlockedSenderDomainsValues
                BlockedSenders                       = $BlockedSendersValues
                BulkQuarantineTag                    = $HostedContentFilterPolicy.BulkQuarantineTag
                BulkSpamAction                       = $HostedContentFilterPolicy.BulkSpamAction
                BulkThreshold                        = $HostedContentFilterPolicy.BulkThreshold
                EnableLanguageBlockList              = $HostedContentFilterPolicy.EnableLanguageBlockList
                EnableRegionBlockList                = $HostedContentFilterPolicy.EnableRegionBlockList
                HighConfidencePhishAction            = $HostedContentFilterPolicy.HighConfidencePhishAction
                HighConfidencePhishQuarantineTag     = $HostedContentFilterPolicy.HighConfidencePhishQuarantineTag
                HighConfidenceSpamAction             = $HostedContentFilterPolicy.HighConfidenceSpamAction
                HighConfidenceSpamQuarantineTag      = $HostedContentFilterPolicy.HighConfidenceSpamQuarantineTag
                InlineSafetyTipsEnabled              = $HostedContentFilterPolicy.InlineSafetyTipsEnabled
                IntraOrgFilterState                  = $HostedContentFilterPolicy.IntraOrgFilterState
                IncreaseScoreWithBizOrInfoUrls       = $HostedContentFilterPolicy.IncreaseScoreWithBizOrInfoUrls
                IncreaseScoreWithImageLinks          = $HostedContentFilterPolicy.IncreaseScoreWithImageLinks
                IncreaseScoreWithNumericIps          = $HostedContentFilterPolicy.IncreaseScoreWithNumericIps
                IncreaseScoreWithRedirectToOtherPort = $HostedContentFilterPolicy.IncreaseScoreWithRedirectToOtherPort
                LanguageBlockList                    = $HostedContentFilterPolicy.LanguageBlockList
                MakeDefault                          = $HostedContentFilterPolicy.IsDefault
                MarkAsSpamBulkMail                   = $HostedContentFilterPolicy.MarkAsSpamBulkMail
                MarkAsSpamEmbedTagsInHtml            = $HostedContentFilterPolicy.MarkAsSpamEmbedTagsInHtml
                MarkAsSpamEmptyMessages              = $HostedContentFilterPolicy.MarkAsSpamEmptyMessages
                MarkAsSpamFormTagsInHtml             = $HostedContentFilterPolicy.MarkAsSpamFormTagsInHtml
                MarkAsSpamFramesInHtml               = $HostedContentFilterPolicy.MarkAsSpamFramesInHtml
                MarkAsSpamFromAddressAuthFail        = $HostedContentFilterPolicy.MarkAsSpamFromAddressAuthFail
                MarkAsSpamJavaScriptInHtml           = $HostedContentFilterPolicy.MarkAsSpamJavaScriptInHtml
                MarkAsSpamNdrBackscatter             = $HostedContentFilterPolicy.MarkAsSpamNdrBackscatter
                MarkAsSpamObjectTagsInHtml           = $HostedContentFilterPolicy.MarkAsSpamObjectTagsInHtml
                MarkAsSpamSensitiveWordList          = $HostedContentFilterPolicy.MarkAsSpamSensitiveWordList
                MarkAsSpamSpfRecordHardFail          = $HostedContentFilterPolicy.MarkAsSpamSpfRecordHardFail
                MarkAsSpamWebBugsInHtml              = $HostedContentFilterPolicy.MarkAsSpamWebBugsInHtml
                ModifySubjectValue                   = $HostedContentFilterPolicy.ModifySubjectValue
                PhishSpamAction                      = $HostedContentFilterPolicy.PhishSpamAction
                PhishQuarantineTag                   = $HostedContentFilterPolicy.PhishQuarantineTag
                SpamQuarantineTag                    = $HostedContentFilterPolicy.SpamQuarantineTag
                QuarantineRetentionPeriod            = $HostedContentFilterPolicy.QuarantineRetentionPeriod
                RedirectToRecipients                 = $HostedContentFilterPolicy.RedirectToRecipients
                RegionBlockList                      = $HostedContentFilterPolicy.RegionBlockList
                SpamAction                           = $HostedContentFilterPolicy.SpamAction
                TestModeAction                       = $HostedContentFilterPolicy.TestModeAction
                TestModeBccToRecipients              = $HostedContentFilterPolicy.TestModeBccToRecipients
                PhishZapEnabled                      = $HostedContentFilterPolicy.PhishZapEnabled
                SpamZapEnabled                       = $HostedContentFilterPolicy.SpamZapEnabled
                Credential                           = $this.Credential
                ApplicationId                        = $this.ApplicationId
                CertificateThumbprint                = $this.CertificateThumbprint
                CertificatePath                      = $this.CertificatePath
                CertificatePassword                  = $this.CertificatePassword
                ManagedIdentity                      = $this.ManagedIdentity
                TenantId                             = $this.TenantId
                AccessTokens                         = $this.AccessTokens
            }

            if ($HostedContentFilterPolicy.IsDefault)
            {
                $result.MakeDefault = $true
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

        Write-Verbose -Message "Setting configuration of HostedContentFilterPolicy for $($this.Identity)"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $null = $this.Connect('ExchangeOnline')

        Write-Verbose (Get-HostedContentFilterPolicy | Out-String)
        $HostedContentFilterPolicy = Get-HostedContentFilterPolicy -Identity $this.Identity -ErrorAction SilentlyContinue
        $HostedContentFilterPolicyParams = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()

        if ($this.IntraOrgFilterState -eq 'Default')
        {
            $HostedContentFilterPolicyParams.IntraOrgFilterState = 'HighConfidencePhish'
        }

        if ($this.Ensure -eq 'Present' -and $null -eq $HostedContentFilterPolicy)
        {
            $HostedContentFilterPolicyParams += @{
                Name = $HostedContentFilterPolicyParams.Identity
            }
            $HostedContentFilterPolicyParams.Remove('Identity') | Out-Null
            $HostedContentFilterPolicyParams.Remove('MakeDefault') | Out-Null
            Write-Verbose -Message "Creating HostedContentFilterPolicy $($this.Identity) with values: $(Convert-M365DscHashtableToString -Hashtable $HostedContentFilterPolicyParams)"
            New-HostedContentFilterPolicy @HostedContentFilterPolicyParams
            if ($this.GetBoundParameters().MakeDefault)
            {
                Write-Verbose -Message 'Updating Policy as default'
                $attempt = 1
                while ($true)
                {
                    try
                    {
                        Set-HostedContentFilterPolicy -Identity $this.Identity -MakeDefault -Confirm:$false -ErrorAction Stop
                        break
                    }
                    catch
                    {
                        if ($attempt -ge 5 -or -not (Test-M365DSCNotFoundError -ErrorRecord $_))
                        {
                            throw
                        }

                        $attempt++
                        Start-Sleep -Seconds 5
                    }
                }
            }
        }
        elseif ($this.Ensure -eq 'Present' -and $null -ne $HostedContentFilterPolicy)
        {
            Write-Verbose -Message "Setting HostedContentFilterPolicy $($this.Identity) with values: $(Convert-M365DscHashtableToString -Hashtable $HostedContentFilterPolicyParams)."
            if ($this.GetBoundParameters().MakeDefault)
            {
                Write-Verbose -Message 'Updating Policy as default'
                $HostedContentFilterPolicyParams.Remove('MakeDefault') | Out-Null
                Set-HostedContentFilterPolicy @HostedContentFilterPolicyParams -MakeDefault -Confirm:$false
            }
            else
            {
                Set-HostedContentFilterPolicy @HostedContentFilterPolicyParams -Confirm:$false
            }
        }
        elseif ($this.Ensure -eq 'Absent' -and $null -ne $HostedContentFilterPolicy)
        {
            Write-Verbose -Message "Removing HostedContentFilterPolicy $($this.Identity) "
            Remove-HostedContentFilterPolicy -Identity $this.Identity -Confirm:$false
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

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Export')

        try
        {
            [array]$HostedContentFilterPolicies = Get-HostedContentFilterPolicy -ErrorAction Stop
            $dscContent = [System.Text.StringBuilder]::new()

            if ($HostedContentFilterPolicies.Count -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }
            $i = 1
            foreach ($HostedContentFilterPolicy in $HostedContentFilterPolicies)
            {
                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }

                $Params = @{
                    Credential            = $this.Credential
                    Identity              = $HostedContentFilterPolicy.Identity
                    ApplicationId         = $this.ApplicationId
                    TenantId              = $this.TenantId
                    CertificateThumbprint = $this.CertificateThumbprint
                    CertificatePassword   = $this.CertificatePassword
                    ManagedIdentity       = $this.ManagedIdentity
                    CertificatePath       = $this.CertificatePath
                    AccessTokens          = $this.AccessTokens
                }
                $this.ExportedInstance = $HostedContentFilterPolicy
                Write-M365DSCHost -Message "    |---[$i/$($HostedContentFilterPolicies.Length)] $($HostedContentFilterPolicy.Identity)" -DeferWrite
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
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
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

    [System.Collections.Hashtable] GetCompareParameters()
    {
        return @{
            PostProcessing = {
                param($DesiredValues, $CurrentValues, $ValuesToCheck, $ignore)
                if ($CurrentValues.IntraOrgFilterState -ne $DesiredValues.IntraOrgFilterState -and $DesiredValues.IntraOrgFilterState -eq 'Default')
                {
                    $ValuesToCheck.IntraOrgFilterState = 'HighConfidencePhish'
                }
                return [System.Tuple[Hashtable, Hashtable, Hashtable]]::new($DesiredValues, $CurrentValues, $ValuesToCheck)
            }
        }
    }

    hidden [EXOHostedContentFilterPolicy] AsResult([System.Object] $Values)
    {
        if ($Values -is [EXOHostedContentFilterPolicy])
        {
            return $Values
        }

        $result = [EXOHostedContentFilterPolicy]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
