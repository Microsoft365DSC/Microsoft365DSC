using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class SCDLPComplianceRule : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('Name of the Rule.')]
    [System.String] $Name

    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('Name of the associated DLP Compliance Policy.')]
    [System.String] $Policy

    [DscProperty()]
    [System.ComponentModel.Description('The AccessScope parameter specifies a condition for the DLP rule that''s based on the access scope of the content. The rule is applied to content that matches the specified access scope.')]
    [ValidateSet('InOrganization', 'NotInOrganization', 'None')]
    [System.String] $AccessScope

    [DscProperty()]
    [System.ComponentModel.Description('The BlockAccess parameter specifies an action for the DLP rule that blocks access to the source item when the conditions of the rule are met. $true: Blocks further access to the source item that matched the rule. The owner, author, and site owner can still access the item. $false: Allows access to the source item that matched the rule. This is the default value.')]
    [System.Nullable[System.Boolean]] $BlockAccess

    [DscProperty()]
    [System.ComponentModel.Description('The BlockAccessScope parameter specifies the scope of the block access action.')]
    [ValidateSet('All', 'PerUser', 'None')]
    [System.String] $BlockAccessScope

    [DscProperty()]
    [System.ComponentModel.Description('The Comment parameter specifies an optional comment. If you specify a value that contains spaces, enclose the value in quotation marks.')]
    [System.String] $Comment

    [DscProperty()]
    [System.ComponentModel.Description('The AdvancedRule parameter uses complex rule syntax that supports multiple AND, OR, and NOT operators and nested groups')]
    [System.String] $AdvancedRule

    [DscProperty()]
    [System.ComponentModel.Description('The ContentContainsSensitiveInformation parameter specifies a condition for the rule that''s based on a sensitive information type match in content. The rule is applied to content that contains the specified sensitive information type.')]
    [MSFT_SCDLPContainsSensitiveInformation[]] $ContentContainsSensitiveInformation

    [DscProperty()]
    [System.ComponentModel.Description('The EndpointDlpRestrictions parameter specifies the restricted endpoints for Endpoint DLP.')]
    [MSFT_SCDLPEndpointDlpRestriction[]] $EndpointDlpRestrictions

    [DscProperty()]
    [System.ComponentModel.Description('The ExceptIfContentContainsSensitiveInformation parameter specifies an exception for the rule that''s based on a sensitive information type match in content. The rule isn''t applied to content that contains the specified sensitive information type.')]
    [MSFT_SCDLPContainsSensitiveInformation[]] $ExceptIfContentContainsSensitiveInformation

    [DscProperty()]
    [System.ComponentModel.Description('The ContentPropertyContainsWords parameter specifies a condition for the DLP rule that''s based on a property match in content. The rule is applied to content that contains the specified property.')]
    [System.String[]] $ContentPropertyContainsWords

    [DscProperty()]
    [System.ComponentModel.Description('The Disabled parameter specifies whether the DLP rule is disabled.')]
    [System.Nullable[System.Boolean]] $Disabled

    [DscProperty()]
    [System.ComponentModel.Description('The Quarantine parameter specifies an action that quarantines messages. Valid values are: $true: The message is delivered to the hosted quarantine. $false: The message is not quarantined.')]
    [System.Nullable[System.Boolean]] $Quarantine

    [DscProperty()]
    [System.ComponentModel.Description('The GenerateAlert parameter specifies an action for the DLP rule that notifies the specified users when the conditions of the rule are met.')]
    [System.String[]] $GenerateAlert

    [DscProperty()]
    [System.ComponentModel.Description('The GenerateIncidentReport parameter specifies an action for the DLP rule that sends an incident report to the specified users when the conditions of the rule are met.')]
    [System.String[]] $GenerateIncidentReport

    [DscProperty()]
    [System.ComponentModel.Description('The IncidentReportContent parameter specifies the content to include in the report when you use the GenerateIncidentReport parameter.')]
    [ValidateSet('All', 'Default', 'DetectionDetails', 'Detections', 'DocumentAuthor', 'DocumentLastModifier', 'MatchedItem', 'OriginalContent', 'RulesMatched', 'Service', 'Severity', 'Title', 'RetentionLabel', 'SensitivityLabel')]
    [System.String[]] $IncidentReportContent

    [DscProperty()]
    [System.ComponentModel.Description('The NotifyAllowOverride parameter specifies the notification override options when the conditions of the rule are met.')]
    [ValidateSet('FalsePositive', 'WithoutJustification', 'WithJustification')]
    [System.String[]] $NotifyAllowOverride

    [DscProperty()]
    [System.ComponentModel.Description('The NotifyEmailCustomText parameter specifies the custom text in the email notification message that''s sent to recipients when the conditions of the rule are met.')]
    [System.String] $NotifyEmailCustomText

    [DscProperty()]
    [System.ComponentModel.Description('The NotifyPolicyTipCustomText parameter specifies the custom text in the Policy Tip notification message that''s shown to recipients when the conditions of the rule are met. The maximum length is 256 characters. HTML tags and tokens (variables) aren''t supported.')]
    [System.String] $NotifyPolicyTipCustomText

    [DscProperty()]
    [System.ComponentModel.Description('The NotifyUser parameter specifies an action for the DLP rule that notifies the specified users when the conditions of the rule are met.')]
    [System.String[]] $NotifyUser

    [DscProperty()]
    [System.ComponentModel.Description('The ReportSeverityLevel parameter specifies the severity level of the incident report for content detections based on the rule.')]
    [ValidateSet('Low', 'Medium', 'High', 'None')]
    [System.String] $ReportSeverityLevel

    [DscProperty()]
    [System.ComponentModel.Description('The RuleErrorAction parameter specifies what to do if an error is encountered during the evaluation of the rule.')]
    [ValidateSet('Ignore', 'RetryThenBlock')]
    [System.String] $RuleErrorAction

    [DscProperty()]
    [System.ComponentModel.Description('The AnyOfRecipientAddressContainsWords parameter specifies a condition for the DLP rule that looks for words or phrases in recipient email addresses.')]
    [System.String[]] $AnyOfRecipientAddressContainsWords

    [DscProperty()]
    [System.ComponentModel.Description('The AnyOfRecipientAddressMatchesPatterns parameter specifies a condition for the DLP rule that looks for text patterns in recipient email addresses by using regular expressions.')]
    [System.String[]] $AnyOfRecipientAddressMatchesPatterns

    [DscProperty()]
    [System.ComponentModel.Description('The RemoveRMSTemplate parameter specifies an action for the DLP rule that removes Office 365 Message Encryption from messages and their attachments.')]
    [System.Nullable[System.Boolean]] $RemoveRMSTemplate

    [DscProperty()]
    [System.ComponentModel.Description('The StopPolicyProcessing parameter specifies an action that stops processing more DLP policy rules.')]
    [System.Nullable[System.Boolean]] $StopPolicyProcessing

    [DscProperty()]
    [System.ComponentModel.Description('The DocumentIsUnsupported parameter specifies a condition for the DLP rule that looks for files that can''t be scanned.')]
    [System.Nullable[System.Boolean]] $DocumentIsUnsupported

    [DscProperty()]
    [System.ComponentModel.Description('The ExceptIfDocumentIsUnsupported parameter specifies an exception for the DLP rule that looks for files that can''t be scanned.')]
    [System.Nullable[System.Boolean]] $ExceptIfDocumentIsUnsupported

    [DscProperty()]
    [System.ComponentModel.Description('The SenderOverride parameter specifies a condition for the rule that looks for messages where the sender chose to override a DLP policy.')]
    [System.Nullable[System.Boolean]] $HasSenderOverride

    [DscProperty()]
    [System.ComponentModel.Description('The ExceptIfHasSenderOverride parameter specifies an exception for the rule that looks for messages where the sender chose to override a DLP policy.')]
    [System.Nullable[System.Boolean]] $ExceptIfHasSenderOverride

    [DscProperty()]
    [System.ComponentModel.Description('The ProcessingLimitExceeded parameter specifies a condition for the DLP rule that looks for files where scanning couldn''t complete.')]
    [System.Nullable[System.Boolean]] $ProcessingLimitExceeded

    [DscProperty()]
    [System.ComponentModel.Description('The ExceptIfProcessingLimitExceeded parameter specifies an exception for the DLP rule that looks for files where scanning couldn''t complete.')]
    [System.Nullable[System.Boolean]] $ExceptIfProcessingLimitExceeded

    [DscProperty()]
    [System.ComponentModel.Description('The DocumentIsPasswordProtected parameter specifies a condition for the DLP rule that looks for password protected files (because the contents of the file can''t be inspected). Password detection only works for Office documents and .zip files.')]
    [System.Nullable[System.Boolean]] $DocumentIsPasswordProtected

    [DscProperty()]
    [System.ComponentModel.Description('The ExceptIfDocumentIsPasswordProtected parameter specifies an exception for the DLP rule that looks for password protected files (because the contents of the file can''t be inspected). Password detection only works for Office documents and .zip files. ')]
    [System.Nullable[System.Boolean]] $ExceptIfDocumentIsPasswordProtected

    [DscProperty()]
    [System.ComponentModel.Description('The MessageTypeMatches parameter specifies a condition for the DLP rule that looks for types of SMIME message patterns.')]
    [System.String[]] $MessageTypeMatches

    [DscProperty()]
    [System.ComponentModel.Description('The FromScope parameter specifies whether messages from inside or outside the organisation are in scope for the DLP rule.')]
    [System.String[]] $FromScope

    [DscProperty()]
    [System.ComponentModel.Description('The ExceptIfFromScope parameter specifies whether messages from inside or outside the organisation are in scope for the DLP rule.')]
    [System.String[]] $ExceptIfFromScope

    [DscProperty()]
    [System.ComponentModel.Description('The SubjectContainsWords parameter specifies a condition for the DLP rule that looks for words or phrases in the Subject field of messages. You can specify multiple words or phrases separated by commas.')]
    [System.String[]] $SubjectContainsWords

    [DscProperty()]
    [System.ComponentModel.Description('The SubjectMatchesPatterns parameter specifies a condition for the DLP rule that looks for text patterns in the Subject field of messages by using regular expressions.')]
    [System.String[]] $SubjectMatchesPatterns

    [DscProperty()]
    [System.ComponentModel.Description('The SubjectOrBodyContainsWords parameter specifies a condition for the rule that looks for words in the Subject field or body of messages.')]
    [System.String[]] $SubjectOrBodyContainsWords

    [DscProperty()]
    [System.ComponentModel.Description('The SubjectOrBodyMatchesPatterns parameter specifies a condition for the rule that looks for text patterns in the Subject field or body of messages.')]
    [System.String[]] $SubjectOrBodyMatchesPatterns

    [DscProperty()]
    [System.ComponentModel.Description('The ContentCharacterSetContainsWords parameter specifies a condition for the rule that looks for character set names in messages. You can specify multiple values separated by commas.')]
    [System.String[]] $ContentCharacterSetContainsWords

    [DscProperty()]
    [System.ComponentModel.Description('The DocumentNameMatchesPatterns parameter specifies a condition for the DLP rule that looks for text patterns in the name of message attachments by using regular expressions.')]
    [System.String[]] $DocumentNameMatchesPatterns

    [DscProperty()]
    [System.ComponentModel.Description('The DocumentNameMatchesWords parameter specifies a condition for the DLP rule that looks for words or phrases in the name of message attachments. ')]
    [System.String[]] $DocumentNameMatchesWords

    [DscProperty()]
    [System.ComponentModel.Description('he ExceptIfAnyOfRecipientAddressContainsWords parameter specifies an exception for the DLP rule that looks for words or phrases in recipient email addresses.')]
    [System.String[]] $ExceptIfAnyOfRecipientAddressContainsWords

    [DscProperty()]
    [System.ComponentModel.Description('The ExceptIfAnyOfRecipientAddressMatchesPatterns parameter specifies an exception for the DLP rule that looks for text patterns in recipient email addresses by using regular expressions.')]
    [System.String[]] $ExceptIfAnyOfRecipientAddressMatchesPatterns

    [DscProperty()]
    [System.ComponentModel.Description('The ExceptIfContentCharacterSetContainsWords parameter specifies an exception for the rule that looks for character set names in messages.')]
    [System.String[]] $ExceptIfContentCharacterSetContainsWords

    [DscProperty()]
    [System.ComponentModel.Description('The ExceptIfContentPropertyContainsWords parameter specifies an exception for the DLP rule that''s based on a property match in content.')]
    [System.String[]] $ExceptIfContentPropertyContainsWords

    [DscProperty()]
    [System.ComponentModel.Description('The ExceptIfDocumentNameMatchesPatterns parameter specifies an exception for the DLP rule that looks for text patterns in the name of message attachments by using regular expressions.')]
    [System.String[]] $ExceptIfDocumentNameMatchesPatterns

    [DscProperty()]
    [System.ComponentModel.Description('The ExceptIfDocumentNameMatchesWords parameter specifies an exception for the DLP rule that looks for words or phrases in the name of message attachments.')]
    [System.String[]] $ExceptIfDocumentNameMatchesWords

    [DscProperty()]
    [System.ComponentModel.Description('The ExceptIfFromAddressContainsWords parameter specifies an exception for the DLP rule that looks for words or phrases in the sender''s email address.')]
    [System.String[]] $ExceptIfFromAddressContainsWords

    [DscProperty()]
    [System.ComponentModel.Description('The ExceptIfFromAddressMatchesPatterns parameter specifies an exception for the DLP rule that looks for text patterns in the sender''s email address by using regular expressions.')]
    [System.String[]] $ExceptIfFromAddressMatchesPatterns

    [DscProperty()]
    [System.ComponentModel.Description('The FromAddressContainsWords parameter specifies a condition for the DLP rule that looks for words or phrases in the sender''s email address.')]
    [System.String[]] $FromAddressContainsWords

    [DscProperty()]
    [System.ComponentModel.Description('The FromAddressMatchesPatterns parameter specifies a condition for the DLP rule that looks for text patterns in the sender''s email address by using regular expressions. ')]
    [System.String[]] $FromAddressMatchesPatterns

    [DscProperty()]
    [System.ComponentModel.Description('The ExceptIfMessageTypeMatches parameter specifies an exception for the rule that looks for messages of the specified type.')]
    [System.String[]] $ExceptIfMessageTypeMatches

    [DscProperty()]
    [System.ComponentModel.Description('The RecipientDomainIs parameter specifies a condition for the DLP rule that looks for recipients with email addresses in the specified domains.')]
    [System.String[]] $RecipientDomainIs

    [DscProperty()]
    [System.ComponentModel.Description('The ExceptIfRecipientDomainIs parameter specifies an exception for the DLP rule that looks for recipients with email addresses in the specified domains.')]
    [System.String[]] $ExceptIfRecipientDomainIs

    [DscProperty()]
    [System.ComponentModel.Description('The ExceptIfSenderDomainIs parameter specifies an exception for the DLP rule that looks for messages from senders with email address in the specified domains. ')]
    [System.String[]] $ExceptIfSenderDomainIs

    [DscProperty()]
    [System.ComponentModel.Description('The ExceptIfSenderIpRanges parameter specifies an exception for the DLP rule that looks for senders whose IP addresses matches the specified value, or fall within the specified ranges.')]
    [System.String[]] $ExceptIfSenderIPRanges

    [DscProperty()]
    [System.ComponentModel.Description('The ExceptIfSentTo parameter specifies an exception for the DLP rule that looks for recipients in messages. You identify the recipients by email address.')]
    [System.String[]] $ExceptIfSentTo

    [DscProperty()]
    [System.ComponentModel.Description('The ExceptIfSubjectContainsWords parameter specifies an exception for the DLP rule that looks for words or phrases in the Subject field of messages.')]
    [System.String[]] $ExceptIfSubjectContainsWords

    [DscProperty()]
    [System.ComponentModel.Description('The ExceptIfSubjectMatchesPatterns parameter specifies an exception for the DLP rule that looks for text patterns in the Subject field of messages by using regular expressions.')]
    [System.String[]] $ExceptIfSubjectMatchesPatterns

    [DscProperty()]
    [System.ComponentModel.Description('The ExceptIfSubjectOrBodyContainsWords parameter specifies an exception for the rule that looks for words in the Subject field or body of messages.')]
    [System.String[]] $ExceptIfSubjectOrBodyContainsWords

    [DscProperty()]
    [System.ComponentModel.Description('The ExceptIfSubjectOrBodyMatchesPatterns parameter specifies an exception for the rule that looks for text patterns in the Subject field or body of messages.')]
    [System.String[]] $ExceptIfSubjectOrBodyMatchesPatterns

    [DscProperty()]
    [System.ComponentModel.Description('The DocumentContainsWords parameter specifies a condition for the DLP rule that looks for words in message attachments. Only supported attachment types are checked.')]
    [System.String[]] $DocumentContainsWords

    [DscProperty()]
    [System.ComponentModel.Description('The SentToMemberOf parameter specifies a condition for the DLP rule that looks for messages sent to members of distribution groups, dynamic distribution groups, or mail-enabled security groups.')]
    [System.String[]] $SentToMemberOf

    [DscProperty()]
    [System.ComponentModel.Description('The ContentIsNotLabeled parameter specifies if the content is labeled. A True or False condition.')]
    [System.Nullable[System.Boolean]] $ContentIsNotLabeled

    [DscProperty()]
    [System.ComponentModel.Description('The SetHeader The SetHeader parameter specifies an action for the DLP rule that adds or modifies a header field and value in the message header. You can specify multiple header name and value pairs separated by commas')]
    [System.String[]] $SetHeader

    [DscProperty()]
    [System.ComponentModel.Description('The ContentExtensionMatchesWords parameter specifies a condition for the DLP rule that looks for words in file name extensions. You can specify multiple words separated by commas.')]
    [System.String[]] $ContentExtensionMatchesWords

    [DscProperty()]
    [System.ComponentModel.Description('The ExceptIfContentExtensionMatchesWords parameter specifies an exception for the DLP rule that looks for words in file name extensions. You can specify multiple words separated by commas.')]
    [System.String[]] $ExceptIfContentExtensionMatchesWords

    [DscProperty()]
    [System.ComponentModel.Description('Specify if this rule should exist or not.')]
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

    [SCDLPComplianceRule] Get()
    {
        $NotifyAllowOverrideValue = $null
        $setHeaders = $null
        if ($this.RequiresPowerShellCore())
        {
            $remote = [SCDLPComplianceRule]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of DLPCompliancePolicy for $($this.Name)"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.Name -ne $this.Name)
            {
                $null = $this.Connect('SecurityComplianceCenter')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullReturn = $this.GetBoundParameters()
                $nullReturn.Ensure = 'Absent'

                $PolicyRule = Invoke-M365DSCCommand -ScriptBlock { Get-DlpComplianceRule -Identity $this.Name -ErrorAction Stop } -SuppressNotFoundError

                if ($null -eq $PolicyRule -or $PolicyRule.Mode -eq 'PendingDeletion')
                {
                    Write-Verbose -Message "DLPComplianceRule $($this.Name) does not exist."
                    return $this.AsResult($nullReturn)
                }
            }
            else
            {
                $PolicyRule = $this.ExportedInstance
            }

            Write-Verbose "Found existing DLPComplianceRule $($this.Name)"

            # Cmdlet returns a string, but in order to properly validate valid values, we need to convert
            # to a String array
            $ArrayIncidentReportContent = @()

            if ($null -ne $PolicyRule.IncidentReportContent)
            {
                $ArrayIncidentReportContent = $PolicyRule.IncidentReportContent.Replace(' ', '').Split(',')
            }

            if ($null -ne $PolicyRule.NotifyAllowOverride)
            {
                $NotifyAllowOverrideValue = $PolicyRule.NotifyAllowOverride.Replace(' ', '').Split(',')
            }

            $anyOfRecipientAddressContainsWordsValue = $null
            if ($null -ne $PolicyRule.AnyOfRecipientAddressContainsWords -and $PolicyRule.AnyOfRecipientAddressContainsWords.Count -gt 0)
            {
                $anyOfRecipientAddressContainsWordsValue = $PolicyRule.AnyOfRecipientAddressContainsWords.Replace(' ', '').Split(',')
            }

            $exceptIfAnyOfRecipientAddressContainsWordsValue = $null
            if ($null -ne $PolicyRule.ExceptIfAnyOfRecipientAddressContainsWords -and $PolicyRule.ExceptIfAnyOfRecipientAddressContainsWords.Count -gt 0)
            {
                $exceptIfAnyOfRecipientAddressContainsWordsValue = $PolicyRule.ExceptIfAnyOfRecipientAddressContainsWords.Replace(' ', '').Split(',')
            }

            $anyOfRecipientAddressMatchesPatternsValue = $null
            if ($null -ne $PolicyRule.AnyOfRecipientAddressMatchesPatterns -and $PolicyRule.AnyOfRecipientAddressMatchesPatterns.Count -gt 0)
            {
                $anyOfRecipientAddressMatchesPatternsValue = $PolicyRule.AnyOfRecipientAddressMatchesPatterns.Replace(' ', '').Split(',')
            }

            $contentExtensionMatchesWordsValue = $null
            if ($null -ne $PolicyRule.ContentExtensionMatchesWords -and $PolicyRule.ContentExtensionMatchesWords.Count -gt 0)
            {
                $contentExtensionMatchesWordsValue = $PolicyRule.ContentExtensionMatchesWords.Replace(' ', '').Split(',')
            }

            $exceptIfContentExtensionMatchesWordsValue = $null
            if ($null -ne $PolicyRule.ExceptIfContentExtensionMatchesWords -and $PolicyRule.ExceptIfContentExtensionMatchesWords.Count -gt 0)
            {
                $exceptIfContentExtensionMatchesWordsValue = $PolicyRule.ExceptIfContentExtensionMatchesWords.Replace(' ', '').Split(',')
            }

            if ($null -ne $PolicyRule.AdvancedRule -and $PolicyRule.AdvancedRule.Count -gt 0)
            {
                $newAdvancedRule = $this.FormatAdvancedRuleWithoutConditionId($PolicyRule.AdvancedRule)
            }
            else
            {
                $newAdvancedRule = $null
            }

            if ($null -ne $PolicyRule.SetHeader)
            {
                $setHeaders = @()
                foreach ($key in $PolicyRule.SetHeader.Keys)
                {
                    $setHeaders += "$($key):$($PolicyRule.SetHeader[$key])"
                }
            }

            $fancyDoubleQuotes = '[\u201C\u201D]'
            $result = @{
                Ensure                                       = 'Present'
                Name                                         = $PolicyRule.Name
                Policy                                       = $PolicyRule.ParentPolicyName
                AccessScope                                  = $PolicyRule.AccessScope
                BlockAccess                                  = $PolicyRule.BlockAccess
                BlockAccessScope                             = $PolicyRule.BlockAccessScope
                Comment                                      = $PolicyRule.Comment
                AdvancedRule                                 = $newAdvancedRule
                ContentContainsSensitiveInformation          = $this.ConvertToContainsSensitiveInformation($PolicyRule.ContentContainsSensitiveInformation)
                EndpointDlpRestrictions                      = [SCDLPComplianceRule]::ConvertSCDLPEndpointDlpRestrictions($PolicyRule.EndpointDlpRestrictions)
                ExceptIfContentContainsSensitiveInformation  = $this.ConvertToContainsSensitiveInformation($PolicyRule.ExceptIfContentContainsSensitiveInformation)
                ContentPropertyContainsWords                 = $PolicyRule.ContentPropertyContainsWords
                Disabled                                     = $PolicyRule.Disabled
                Quarantine                                   = $PolicyRule.Quarantine
                GenerateAlert                                = Get-M365DSCArrayFromProperty -PropertyValue $PolicyRule.GenerateAlert -ElementType ([System.String])
                GenerateIncidentReport                       = $PolicyRule.GenerateIncidentReport
                IncidentReportContent                        = $ArrayIncidentReportContent
                NotifyAllowOverride                          = $NotifyAllowOverrideValue
                NotifyEmailCustomText                        = [regex]::Replace($PolicyRule.NotifyEmailCustomText, $fancyDoubleQuotes, "`"")
                NotifyPolicyTipCustomText                    = [regex]::Replace($PolicyRule.NotifyPolicyTipCustomText, $fancyDoubleQuotes, "`"")
                NotifyUser                                   = $PolicyRule.NotifyUser
                ReportSeverityLevel                          = $PolicyRule.ReportSeverityLevel
                RuleErrorAction                              = $PolicyRule.RuleErrorAction
                RemoveRMSTemplate                            = $PolicyRule.RemoveRMSTemplate
                StopPolicyProcessing                         = $PolicyRule.StopPolicyProcessing
                DocumentIsUnsupported                        = $PolicyRule.DocumentIsUnsupported
                ExceptIfDocumentIsUnsupported                = $PolicyRule.ExceptIfDocumentIsUnsupported
                HasSenderOverride                            = $PolicyRule.HasSenderOverride
                ExceptIfHasSenderOverride                    = $PolicyRule.ExceptIfHasSenderOverride
                ProcessingLimitExceeded                      = $PolicyRule.ProcessingLimitExceeded
                ExceptIfProcessingLimitExceeded              = $PolicyRule.ExceptIfProcessingLimitExceeded
                DocumentIsPasswordProtected                  = $PolicyRule.DocumentIsPasswordProtected
                ExceptIfDocumentIsPasswordProtected          = $PolicyRule.ExceptIfDocumentIsPasswordProtected
                MessageTypeMatches                           = $PolicyRule.MessageTypeMatches
                ExceptIfMessageTypeMatches                   = $PolicyRule.ExceptIfMessageTypeMatches
                FromScope                                    = $PolicyRule.FromScope
                ExceptIfFromScope                            = $PolicyRule.ExceptIfFromScope
                SubjectContainsWords                         = $PolicyRule.SubjectContainsWords
                SubjectMatchesPatterns                       = $PolicyRule.SubjectMatchesPatterns
                SubjectOrBodyContainsWords                   = $PolicyRule.SubjectOrBodyContainsWords
                SubjectOrBodyMatchesPatterns                 = $PolicyRule.SubjectOrBodyMatchesPatterns
                ContentCharacterSetContainsWords             = $PolicyRule.ContentCharacterSetContainsWords
                DocumentNameMatchesPatterns                  = $PolicyRule.DocumentNameMatchesPatterns
                DocumentNameMatchesWords                     = $PolicyRule.DocumentNameMatchesWords
                ExceptIfAnyOfRecipientAddressMatchesPatterns = $PolicyRule.ExceptIfAnyOfRecipientAddressMatchesPatterns
                ExceptIfContentCharacterSetContainsWords     = $PolicyRule.ExceptIfContentCharacterSetContainsWords
                ExceptIfContentPropertyContainsWords         = $PolicyRule.ExceptIfContentPropertyContainsWords
                ExceptIfDocumentNameMatchesPatterns          = $PolicyRule.ExceptIfDocumentNameMatchesPatterns
                ExceptIfDocumentNameMatchesWords             = $PolicyRule.ExceptIfDocumentNameMatchesWords
                RecipientDomainIs                            = $PolicyRule.RecipientDomainIs
                ExceptIfRecipientDomainIs                    = $PolicyRule.ExceptIfRecipientDomainIs
                ExceptIfSenderDomainIs                       = $PolicyRule.ExceptIfSenderDomainIs
                ExceptIfSenderIPRanges                       = $PolicyRule.ExceptIfSenderIPRanges
                ExceptIfSentTo                               = $PolicyRule.ExceptIfSentTo
                ExceptIfSubjectContainsWords                 = $PolicyRule.ExceptIfSubjectContainsWords
                ExceptIfSubjectMatchesPatterns               = $PolicyRule.ExceptIfSubjectMatchesPatterns
                ExceptIfSubjectOrBodyContainsWords           = $PolicyRule.ExceptIfSubjectOrBodyContainsWords
                ExceptIfSubjectOrBodyMatchesPatterns         = $PolicyRule.ExceptIfSubjectOrBodyMatchesPatterns
                FromAddressMatchesPatterns                   = $PolicyRule.FromAddressMatchesPatterns
                FromAddressContainsWords                     = $PolicyRule.FromAddressContainsWords
                ExceptIfFromAddressContainsWords             = $PolicyRule.ExceptIfFromAddressContainsWords
                ExceptIfFromAddressMatchesPatterns           = $PolicyRule.ExceptIfFromAddressMatchesPatterns
                SentToMemberOf                               = $PolicyRule.SentToMemberOf
                DocumentContainsWords                        = $PolicyRule.DocumentContainsWords
                ContentIsNotLabeled                          = $PolicyRule.ContentIsNotLabeled
                SetHeader                                    = $setHeaders
                AnyOfRecipientAddressContainsWords           = $anyOfRecipientAddressContainsWordsValue
                AnyOfRecipientAddressMatchesPatterns         = $anyOfRecipientAddressMatchesPatternsValue
                ExceptIfAnyOfRecipientAddressContainsWords   = $exceptIfAnyOfRecipientAddressContainsWordsValue
                ContentExtensionMatchesWords                 = $contentExtensionMatchesWordsValue
                ExceptIfContentExtensionMatchesWords         = $exceptIfContentExtensionMatchesWordsValue
                Credential                                   = $this.Credential
                ApplicationId                                = $this.ApplicationId
                TenantId                                     = $this.TenantId
                CertificateThumbprint                        = $this.CertificateThumbprint
                CertificatePath                              = $this.CertificatePath
                CertificatePassword                          = $this.CertificatePassword
                ManagedIdentity                              = $this.ManagedIdentity
                AccessTokens                                 = $this.AccessTokens
            }

            $paramsToRemove = @()
            if (-not [System.String]::IsNullOrEmpty($PolicyRule.AdvancedRule))
            {
                foreach ($paramName in $result.Keys)
                {
                    if ($paramName -eq 'GenerateAlert')
                    {
                        continue
                    }

                    if ($null -eq $result[$paramName] -or '' -eq $result[$paramName] -or @() -eq $result[$paramName])
                    {
                        $paramsToRemove += $paramName
                    }
                }
            }

            foreach ($paramName in $paramsToRemove)
            {
                $result.Remove($paramName)
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

        Write-Verbose -Message "Setting configuration of DLPComplianceRule for $($this.Name)"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $CurrentRule = $this.Get().ToHashtable()
        $boundParameters = $this.GetBoundParameters()

        if ($null -ne $boundParameters.AdvancedRule)
        {
            $newAdvancedRule = $boundParameters.AdvancedRule | ConvertFrom-Json | ConvertFrom-Json
            $newAdvancedRule.Condition = $this.AddAdvancedRuleConditionId($newAdvancedRule.Condition, $this.ResourceCache)
            $boundParameters.AdvancedRule = [SCDLPComplianceRule]::FormatJson(($newAdvancedRule | ConvertTo-Json -Depth 32))
        }

        if ($this.Ensure -eq 'Present' -and $CurrentRule.Ensure -eq 'Absent')
        {
            Write-Verbose "Rule {$($CurrentRule.Name)} doesn't exists but need to. Creating Rule."
            $createParameters = $boundParameters
            $CreationParams = Remove-M365DSCAuthenticationParameter -BoundParameters $createParameters
            if ($null -ne $CreationParams.ContentContainsSensitiveInformation)
            {
                $value = @()
                foreach ($item in $CreationParams.ContentContainsSensitiveInformation)
                {
                    if ($null -ne $item.groups)
                    {
                        $value += [SCDLPComplianceRule]::GetSCDLPSensitiveInformationGroups($item)
                    }
                    else
                    {
                        $value += [SCDLPComplianceRule]::GetSCDLPSensitiveInformation($item)
                    }
                }
                $CreationParams.ContentContainsSensitiveInformation = $value
            }

            if ($null -ne $CreationParams.ExceptIfContentContainsSensitiveInformation)
            {
                $value = @()
                foreach ($item in $CreationParams.ExceptIfContentContainsSensitiveInformation)
                {
                    if ($null -ne $item.groups)
                    {
                        $value += [SCDLPComplianceRule]::GetSCDLPSensitiveInformationGroups($item)
                    }
                    else
                    {
                        $value += [SCDLPComplianceRule]::GetSCDLPSensitiveInformation($item)
                    }
                }
                $CreationParams.ExceptIfContentContainsSensitiveInformation = $value
            }

            if ($null -ne $CreationParams.ContentContainsSensitiveInformation)
            {
                $CreationParams.Remove('AdvancedRule')
            }

            if ($null -ne $CreationParams.EndpointDlpRestrictions)
            {
                $CreationParams.EndpointDlpRestrictions = [SCDLPComplianceRule]::ConvertSCDLPEndpointDlpRestrictions($CreationParams.EndpointDlpRestrictions)
            }

            if ($null -ne $CreationParams.SetHeader)
            {
                $setHeaders = @{}
                foreach ($header in $CreationParams.SetHeader)
                {
                    $key, $value = $header -split ':'
                    $setHeaders[$key] = $value
                }
                $CreationParams.Remove('SetHeader') | Out-Null
                $CreationParams.Add('SetHeader', $setHeaders)
            }

            Write-Verbose -Message "Calling New-DLPComplianceRule with Values: $(Convert-M365DscHashtableToString -Hashtable $CreationParams)"
            New-DLPComplianceRule @CreationParams -Confirm:$false
        }
        elseif ($this.Ensure -eq 'Present' -and $CurrentRule.Ensure -eq 'Present')
        {
            Write-Verbose "Rule {$($CurrentRule.Name)} already exists and needs to get updated. Updating Rule."
            $updateParameters = $boundParameters
            $UpdateParams = Remove-M365DSCAuthenticationParameter -BoundParameters $updateParameters

            if ($null -ne $UpdateParams.ContentContainsSensitiveInformation)
            {
                $value = @()
                foreach ($item in $UpdateParams.ContentContainsSensitiveInformation)
                {
                    if ($null -ne $item.groups)
                    {
                        $value += [SCDLPComplianceRule]::GetSCDLPSensitiveInformationGroups($item)
                    }
                    else
                    {
                        $value += [SCDLPComplianceRule]::GetSCDLPSensitiveInformation($item)
                    }
                }
                $UpdateParams.ContentContainsSensitiveInformation = $value
            }

            if ($null -ne $UpdateParams.ExceptIfContentContainsSensitiveInformation)
            {
                $value = @()
                foreach ($item in $UpdateParams.ExceptIfContentContainsSensitiveInformation)
                {
                    if ($null -ne $item.groups)
                    {
                        $value += [SCDLPComplianceRule]::GetSCDLPSensitiveInformationGroups($item)
                    }
                    else
                    {
                        $value += [SCDLPComplianceRule]::GetSCDLPSensitiveInformation($item)
                    }
                }
                $UpdateParams.ExceptIfContentContainsSensitiveInformation = $value
            }

            if ($null -ne $UpdateParams.ContentContainsSensitiveInformation)
            {
                $UpdateParams.Remove('AdvancedRule')
            }

            if ($null -ne $UpdateParams.EndpointDlpRestrictions)
            {
                $UpdateParams.EndpointDlpRestrictions = [SCDLPComplianceRule]::ConvertSCDLPEndpointDlpRestrictions($UpdateParams.EndpointDlpRestrictions)
            }

            if ($null -ne $UpdateParams.SetHeader)
            {
                $setHeaders = @{}
                foreach ($header in $UpdateParams.SetHeader)
                {
                    $key, $value = $header -split ':'
                    $setHeaders[$key] = $value
                }
                $UpdateParams.Remove('SetHeader') | Out-Null
                $UpdateParams.Add('SetHeader', $setHeaders)
            }

            $UpdateParams.Remove('Name') | Out-Null
            $UpdateParams.Remove('Policy') | Out-Null
            $UpdateParams.Add('Identity', $this.Name)

            Write-Verbose "Updating Rule with values: $(Convert-M365DscHashtableToString -Hashtable $UpdateParams)"
            Set-DLPComplianceRule @UpdateParams -Confirm:$false
        }
        elseif ($this.Ensure -eq 'Absent' -and $CurrentRule.Ensure -eq 'Present')
        {
            Write-Verbose "Rule {$($CurrentRule.Name)} already exists but shouldn't. Deleting Rule."
            Remove-DLPComplianceRule -Identity $CurrentRule.Name -Confirm:$false
        }
    }

    [bool] Test()
    {
        return ([M365DSCResourceBase] $this).Test()
    }

    [System.Collections.Hashtable] GetCompareParameters()
    {
        return @{
            PostProcessing = {
                param($DesiredValues, $CurrentValues, $ValuesToCheck, $PostProcessingArgs)
                $logDrift = -not [M365DSCResourceBase]::IsReportContext($PostProcessingArgs)
                foreach ($key in @('ContentContainsSensitiveInformation', 'ExceptIfContentContainsSensitiveInformation'))
                {
                    if ($null -ne $DesiredValues[$key])
                    {
                        if ($null -ne $DesiredValues[$key].groups)
                        {
                            $contentSITS = [SCDLPComplianceRule]::GetSCDLPSensitiveInformationGroups($DesiredValues[$key])
                            $currentSITS = [SCDLPComplianceRule]::GetSCDLPSensitiveInformationGroups($CurrentValues[$key])
                            $desiredState = [SCDLPComplianceRule]::TestContainsSensitiveInformationGroups($contentSITS, $currentSITS, $logDrift)
                        }
                        else
                        {
                            $contentSITS = [SCDLPComplianceRule]::GetSCDLPSensitiveInformation($DesiredValues[$key])
                            $currentSITS = [SCDLPComplianceRule]::GetSCDLPSensitiveInformation($CurrentValues[$key])
                            $desiredState = [SCDLPComplianceRule]::TestContainsSensitiveInformation($contentSITS, $currentSITS, $logDrift)
                        }

                        if ($desiredState)
                        {
                            $DesiredValues.Remove($key)
                            $CurrentValues.Remove($key)
                            $ValuesToCheck.Remove($key)
                        }
                        else
                        {
                            # Sentinel strings force the comparer to flag drift on this key.
                            $DesiredValues[$key] = 'SIT-Drift-Desired'
                            $CurrentValues[$key] = 'SIT-Drift-Current'
                            $ValuesToCheck[$key] = 'SIT-Drift-Desired'
                        }
                    }
                }

                if ($null -ne $DesiredValues['EndpointDlpRestrictions'])
                {
                    $DesiredValues['EndpointDlpRestrictions'] = [SCDLPComplianceRule]::ConvertSCDLPEndpointDlpRestrictions($DesiredValues['EndpointDlpRestrictions'])
                    $ValuesToCheck['EndpointDlpRestrictions'] = $DesiredValues['EndpointDlpRestrictions']
                    $CurrentValues['EndpointDlpRestrictions'] = [SCDLPComplianceRule]::ConvertSCDLPEndpointDlpRestrictions($CurrentValues['EndpointDlpRestrictions'])
                }

                if ($null -ne $DesiredValues['AdvancedRule'] -and $CurrentValues.Ensure -eq 'Present')
                {
                    $advancedRuleObject = $DesiredValues['AdvancedRule'] | ConvertFrom-Json | ConvertFrom-Json
                    $conditions = [System.Collections.Generic.Queue[System.Object]]::new()
                    foreach ($condition in @($advancedRuleObject.Condition))
                    {
                        if ($null -ne $condition)
                        {
                            $conditions.Enqueue($condition)
                        }
                    }

                    while ($conditions.Count -gt 0)
                    {
                        $currentCondition = $conditions.Dequeue()
                        foreach ($subCondition in @($currentCondition.SubConditions))
                        {
                            if ($null -ne $subCondition)
                            {
                                $conditions.Enqueue($subCondition)
                            }
                        }

                        if ($currentCondition.ConditionName -like '*ContentContainsSensitiveInformation*' -and `
                            $null -ne $currentCondition.Value.Groups.Sensitivetypes)
                        {
                            foreach ($sensitiveType in $currentCondition.Value.Groups.Sensitivetypes)
                            {
                                if ($sensitiveType.Classifiertype -eq 'MLModel' -and $null -ne $sensitiveType.Id)
                                {
                                    $sensitiveType.Id = $null
                                }
                            }
                        }
                    }

                    $newAdvancedRule = [SCDLPComplianceRule]::FormatJson(($advancedRuleObject | ConvertTo-Json -Depth 32))
                    $DesiredValues['AdvancedRule'] = $newAdvancedRule | ConvertTo-Json -Compress
                    $ValuesToCheck['AdvancedRule'] = $DesiredValues['AdvancedRule']
                }

                return [System.Tuple[Hashtable, Hashtable, Hashtable]]::new($DesiredValues, $CurrentValues, $ValuesToCheck)
            }
        }
    }

    [string] Export()
    {
        if ($this.RequiresPowerShellCore())
        {
            return [string] $this.InvokeInPowerShellCore('Export')
        }

        $ConnectionMode = $this.Connect('SecurityComplianceCenter')

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Export')

        try
        {
            [array]$rules = Get-DLPComplianceRule -ErrorAction Stop | Where-Object { $_.Mode -ne 'PendingDeletion' }

            $i = 1
            $dscContent = [System.Text.StringBuilder]::new()
            if ($rules.Length -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }
            foreach ($rule in $rules)
            {
                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }

                Write-M365DSCHost -Message "    |---[$i/$($rules.Length)] $($rule.Name)" -DeferWrite

                $this.ExportedInstance = $rule
                $Results = $this.GetForExport(@{ Name = $rule.name; Policy = $rule.ParentPolicyName })
                $rawResults = $Results.Clone()

                if ($null -ne $Results.ContentContainsSensitiveInformation)
                {
                    $complexTypeMapping = @(
                        @{
                            Name            = 'ContentContainsSensitiveInformation'
                            CimInstanceName = 'SCDLPContainsSensitiveInformation'
                        },
                        @{
                            Name            = 'Groups'
                            CimInstanceName = 'SCDLPContainsSensitiveInformationGroup'
                            IsArray         = $true
                        },
                        @{
                            Name            = 'SensitiveInformation'
                            CimInstanceName = 'SCDLPSensitiveInformation'
                            IsArray         = $true
                        },
                        @{
                            Name            = 'Labels'
                            CimInstanceName = 'SCDLPLabel'
                            IsArray         = $true
                        }
                    )

                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.ContentContainsSensitiveInformation `
                        -CIMInstanceName 'SCDLPContainsSensitiveInformation' `
                        -ComplexTypeMapping $complexTypeMapping
                    if (-not [String]::IsNullOrEmpty($complexTypeStringResult))
                    {
                        $Results.ContentContainsSensitiveInformation = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('ContentContainsSensitiveInformation') | Out-Null
                    }
                }

                if ($null -ne $Results.ExceptIfContentContainsSensitiveInformation)
                {
                    $complexTypeMapping = @(
                        @{
                            Name            = 'ExceptIfContentContainsSensitiveInformation'
                            CimInstanceName = 'SCDLPContainsSensitiveInformation'
                        },
                        @{
                            Name            = 'Groups'
                            CimInstanceName = 'SCDLPContainsSensitiveInformationGroup'
                            IsArray         = $true
                        },
                        @{
                            Name            = 'SensitiveInformation'
                            CimInstanceName = 'SCDLPSensitiveInformation'
                            IsArray         = $true
                        },
                        @{
                            Name            = 'Labels'
                            CimInstanceName = 'SCDLPLabel'
                            IsArray         = $true
                        }
                    )

                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.ExceptIfContentContainsSensitiveInformation `
                        -CIMInstanceName 'SCDLPContainsSensitiveInformation' `
                        -ComplexTypeMapping $complexTypeMapping
                    if (-not [String]::IsNullOrEmpty($complexTypeStringResult))
                    {
                        $Results.ExceptIfContentContainsSensitiveInformation = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('ExceptIfContentContainsSensitiveInformation') | Out-Null
                    }
                }

                if ($null -ne $Results.EndpointDlpRestrictions)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.EndpointDlpRestrictions `
                        -CIMInstanceName 'SCDLPEndpointDlpRestriction' `
                        -IsArray
                    if (-not [String]::IsNullOrEmpty($complexTypeStringResult))
                    {
                        $Results.EndpointDlpRestrictions = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('EndpointDlpRestrictions') | Out-Null
                    }
                }

                $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                    -ConnectionMode $ConnectionMode `
                    -ModulePath $this.GetModulePath() `
                    -Results $Results `
                    -Credential $this.Credential `
                    -NoEscape @('ContentContainsSensitiveInformation', 'EndpointDlpRestrictions', 'ExceptIfContentContainsSensitiveInformation') `
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

    hidden [System.Object] AddAdvancedRuleConditionId([System.Object] $Condition, [System.Collections.Hashtable] $Cache)
    {
        for ($i = 0; $i -lt $Condition.SubConditions.Count; $i++)
        {
            $Condition.SubConditions[$i] = $this.AddAdvancedRuleConditionId($Condition.SubConditions[$i], $Cache)
        }

        if ([System.String]::IsNullOrEmpty($Condition.ConditionName))
        {
            return $Condition
        }

        $index = $Condition.ConditionName.IndexOf('ContentContainsSensitiveInformation')
        if ($index -ne -1)
        {
            if ($null -ne $Condition.Value.Groups.Sensitivetypes)
            {
                if ($null -eq $Cache['SensitiveInformationTypes'])
                {
                    $Cache['SensitiveInformationTypes'] = Get-DlpSensitiveInformationType
                }

                $sensitiveTypesValue = $Condition.Value.Groups.Sensitivetypes
                foreach ($stype in $sensitiveTypesValue)
                {
                    # Do not attempt to resolve trainable classifiers that have a classifier type set, e.g. MLModel
                    # See https://github.com/Microsoft365DSC/Microsoft365DSC/issues/7156
                    if ($null -eq $stype.Id -and [System.String]::IsNullOrEmpty($stype.Classifiertype))
                    {
                        $stype.Id = $Cache['SensitiveInformationTypes'] | Where-Object -FilterScript { $_.Name -eq $stype.Name } | Select-Object -ExpandProperty Id
                    }
                }
            }
        }

        return $Condition
    }

    hidden [System.String] FormatAdvancedRuleWithoutConditionId([System.String] $AdvancedRule)
    {
        $ruleObject = $AdvancedRule | ConvertFrom-Json

        $ruleObject.Condition = $this.RemoveAdvancedRuleConditionId($ruleObject.Condition)
        $newAdvancedRule = [SCDLPComplianceRule]::FormatJson(($ruleObject | ConvertTo-Json -Depth 32))
        return $newAdvancedRule | ConvertTo-Json -Compress
    }

    hidden [System.Object] RemoveAdvancedRuleConditionId([System.Object] $Condition)
    {
        for ($i = 0; $i -lt $Condition.SubConditions.Count; $i++)
        {
            $Condition.SubConditions[$i] = $this.RemoveAdvancedRuleConditionId($Condition.SubConditions[$i])
        }

        if ([System.String]::IsNullOrEmpty($Condition.ConditionName))
        {
            return $Condition
        }

        $index = $Condition.ConditionName.IndexOf('ContentContainsSensitiveInformation')
        if ($index -ne -1)
        {
            if ($null -eq $Condition.Value.Groups)
            {
                $Condition.Value = $Condition.Value | Select-Object * -ExcludeProperty Id
            }
            elseif ($null -ne $Condition.Value.Groups.Sensitivetypes)
            {
                $sensitiveTypesValue = $Condition.Value.Groups.Sensitivetypes
                foreach ($stype in $sensitiveTypesValue)
                {
                    if ($null -ne $stype.Id)
                    {
                        $stype.Id = $null
                    }
                }
            }
        }

        return $Condition
    }

    hidden [System.Collections.Hashtable] ConvertToContainsSensitiveInformation([System.Object] $SensitiveInformation)
    {
        if ($null -eq $SensitiveInformation)
        {
            return $null
        }

        if ($null -ne $SensitiveInformation.groups)
        {
            $shapedGroups = @()
            foreach ($group in $SensitiveInformation.groups)
            {
                $shapedGroup = @{}
                foreach ($key in $group.Keys)
                {
                    $shapedGroup[$key] = $group[$key]
                }

                $shapedTypes = @()
                foreach ($sensitiveType in $group.sensitivetypes)
                {
                    $shapedType = @{}
                    foreach ($key in $sensitiveType.Keys)
                    {
                        if ($key -in @('confidencelevel', 'rulePackId'))
                        {
                            continue
                        }
                        $shapedType[$key] = $sensitiveType[$key]
                    }
                    $shapedTypes += $shapedType
                }

                $null = $shapedGroup.Remove('sensitivetypes')
                if ($shapedTypes.Count -gt 0)
                {
                    $shapedGroup.SensitiveInformation = [array]$shapedTypes
                }
                $shapedGroups += $shapedGroup
            }

            return @{
                Groups   = [array]$shapedGroups
                Operator = $SensitiveInformation.operator
            }
        }

        $shapedInformation = @()
        foreach ($item in $SensitiveInformation)
        {
            $shapedItem = @{}
            foreach ($key in $item.Keys)
            {
                if ($key -in @('confidencelevel', 'rulePackId'))
                {
                    continue
                }
                $shapedItem[$key] = $item[$key]
            }
            $shapedInformation += $shapedItem
        }

        if ($shapedInformation.Count -eq 0)
        {
            return $null
        }

        return @{
            SensitiveInformation = [array]$shapedInformation
        }
    }

    hidden static [System.Collections.Hashtable] NewMemberLookup([System.Object] $Items, [System.String] $MemberName)
    {
        $lookup = @{}
        foreach ($item in @($Items))
        {
            if ($null -eq $item)
            {
                continue
            }

            $key = [System.String] $item.$MemberName
            if (-not $lookup.ContainsKey($key))
            {
                $lookup[$key] = $item
            }
        }

        return $lookup
    }

    hidden static [System.Boolean] TestContainsSensitiveInformation([System.Object[]] $DesiredValues, [System.Object[]] $CurrentValues, [System.Boolean] $LogDrift)
    {
        $currentItems = [SCDLPComplianceRule]::NewMemberLookup($CurrentValues, 'name')
        foreach ($sit in @($DesiredValues))
        {
            if ($null -eq $sit)
            {
                continue
            }

            $sitName = [System.String] $sit.name
            Write-Verbose -Message "Trying to find existing Sensitive Information Action matching name {$sitName}"
            $matchingExistingRule = $currentItems[$sitName.Replace("''", "'")]
            if ($null -eq $matchingExistingRule)
            {
                Write-Verbose -Message "Sensitive Information Action {$sitName} was not found"
                if ($LogDrift)
                {
                    $EventMessage = "DLP Compliance Rule was not in the desired state.`r`n" + `
                        "An action on {$sitName} Sensitive Information Type is missing."
                    Add-M365DSCEvent -Message $EventMessage -EntryType 'Warning' `
                        -EventID 1 -Source 'SCDLPComplianceRule'
                }
                return $false
            }

            Write-Verbose -Message "Sensitive Information Action {$sitName} was found"
            foreach ($property in @('id', 'maxconfidence', 'minconfidence', 'classifiertype', 'mincount', 'maxcount'))
            {
                $desiredValue = $sit.$property
                $currentValue = $matchingExistingRule.$property
                if ([System.String] $desiredValue -ne [System.String] $currentValue)
                {
                    Write-Verbose -Message "Property {$property} is set to {$currentValue} and is expected to be {$desiredValue}."
                    if ($LogDrift)
                    {
                        $EventMessage = "DLP Compliance Rule was not in the desired state.`r`n" + `
                            "Sensitive Information Action {$sitName} has invalid value for property {$property}. " + `
                            "Current value is {$currentValue} and is expected to be {$desiredValue}."
                        Add-M365DSCEvent -Message $EventMessage -EntryType 'Warning' `
                            -EventID 1 -Source 'SCDLPComplianceRule'
                    }
                    return $false
                }
            }
        }

        return $true
    }

    hidden static [System.Object[]] GetSCDLPSensitiveInformationGroups([System.Object[]] $SensitiveInformationGroups)
    {
        $returnValue = @()
        $sits = @()
        $groups = @()

        $result = @{
            operator = $SensitiveInformationGroups.operator
        }

        foreach ($group in $SensitiveInformationGroups.groups)
        {
            $myGroup = [ordered]@{
                name = $group.name
            }
            if ($null -ne $group.operator)
            {
                $myGroup.Add('operator', $group.operator)
            }
            $sits = @()
            foreach ($item in $group.SensitiveInformation)
            {
                $sit = @{
                    name = $item.name
                }

                if ($null -ne $item.id)
                {
                    $sit.Add('id', $item.id)
                }

                if ($null -ne $item.maxconfidence)
                {
                    $sit.Add('maxconfidence', $item.maxconfidence)
                }

                if ($null -ne $item.minconfidence)
                {
                    $sit.Add('minconfidence', $item.minconfidence)
                }

                if ($null -ne $item.classifiertype)
                {
                    $sit.Add('classifiertype', $item.classifiertype)
                }

                if ($null -ne $item.mincount)
                {
                    $sit.Add('mincount', $item.mincount)
                }

                if ($null -ne $item.maxcount)
                {
                    $sit.Add('maxcount', $item.maxcount)
                }
                $sits += $sit
            }
            foreach ($item in $group.SensitiveTypes)
            {
                $sit = @{
                    name = $item.name
                }

                if ($null -ne $item.id)
                {
                    $sit.Add('id', $item.id)
                }

                if ($null -ne $item.maxconfidence)
                {
                    $sit.Add('maxconfidence', $item.maxconfidence)
                }

                if ($null -ne $item.minconfidence)
                {
                    $sit.Add('minconfidence', $item.minconfidence)
                }

                if ($null -ne $item.classifiertype)
                {
                    $sit.Add('classifiertype', $item.classifiertype)
                }

                if ($null -ne $item.mincount)
                {
                    $sit.Add('mincount', $item.mincount)
                }

                if ($null -ne $item.maxcount)
                {
                    $sit.Add('maxcount', $item.maxcount)
                }
                $sits += $sit
            }
            if ($sits.Length -gt 0)
            {
                $myGroup.Add('sensitivetypes', $sits)
            }
            $labels = @()
            foreach ($item in $group.labels)
            {
                $label = @{
                    name = $item.name
                }

                if ($null -ne $item.id)
                {
                    $label.Add('id', $item.id)
                }

                if ($null -ne $item.type)
                {
                    $label.Add('type', $item.type)
                }
                $labels += $label
            }
            if ($labels.Length -gt 0)
            {
                $myGroup.Add('labels', $labels)
            }
            $groups += $myGroup
        }
        $result.Add('groups', $groups)
        $returnValue += $result
        return $returnValue
    }

    hidden static [System.Boolean] TestContainsSensitiveInformationGroups([System.Object[]] $DesiredValues, [System.Object[]] $CurrentValues, [System.Boolean] $LogDrift)
    {
        $desiredOperator = $DesiredValues.operator
        $currentOperator = $CurrentValues.operator
        if ([System.String] $desiredOperator -ne [System.String] $currentOperator)
        {
            if ($LogDrift)
            {
                $EventMessage = "DLP Compliance Rule was not in the desired state.`r`n" + `
                    "DLP Compliance Rule has invalid value for property operator. " + `
                    "Current value is {$currentOperator} and is expected to be {$desiredOperator}."
                Add-M365DSCEvent -Message $EventMessage -EntryType 'Warning' `
                    -EventID 1 -Source 'SCDLPComplianceRule'
            }
            return $false
        }

        $currentGroups = [SCDLPComplianceRule]::NewMemberLookup($CurrentValues.groups, 'name')
        foreach ($group in @($DesiredValues.groups))
        {
            if ($null -eq $group)
            {
                continue
            }

            $groupName = [System.String] $group.name
            $matchingExistingGroup = $currentGroups[$groupName]
            if ($null -eq $matchingExistingGroup)
            {
                Write-Verbose -Message "Sensitive Information Action {$groupName} was not found"
                if ($LogDrift)
                {
                    $EventMessage = "DLP Compliance Rule was not in the desired state.`r`n" + `
                        "An action on {$groupName} Sensitive Information Type is missing."
                    Add-M365DSCEvent -Message $EventMessage -EntryType 'Warning' `
                        -EventID 1 -Source 'SCDLPComplianceRule'
                }
                return $false
            }

            Write-Verbose -Message "ContainsSensitiveInformationGroup {$groupName} was found"
            $desiredGroupOperator = $group.operator
            $currentGroupOperator = $matchingExistingGroup.operator
            if ([System.String] $desiredGroupOperator -ne [System.String] $currentGroupOperator)
            {
                if ($LogDrift)
                {
                    $EventMessage = "DLP Compliance Rule was not in the desired state.`r`n" + `
                        "Group {$groupName} has invalid value for property operator. " + `
                        "Current value is {$currentGroupOperator} and is expected to be {$desiredGroupOperator}."
                    Add-M365DSCEvent -Message $EventMessage -EntryType 'Warning' `
                        -EventID 1 -Source 'SCDLPComplianceRule'
                }
                return $false
            }

            $desiredTypes = $group.sensitivetypes
            if ($null -ne $desiredTypes)
            {
                $desiredState = [SCDLPComplianceRule]::TestContainsSensitiveInformation($desiredTypes, $matchingExistingGroup.sensitivetypes, $LogDrift)
                if ($desiredState -eq $false)
                {
                    return $false
                }
            }

            $desiredLabels = $group.labels
            if ($null -ne $desiredLabels)
            {
                $desiredState = [SCDLPComplianceRule]::TestContainsSensitiveInformationLabels($desiredLabels, $matchingExistingGroup.labels, $LogDrift)
                if ($desiredState -eq $false)
                {
                    return $false
                }
            }
        }

        return $true
    }

    hidden static [System.String] FormatJson([System.String] $json)
    {
        $indent = 0
        return ($json -split "`n" | ForEach-Object {
            if ($_ -match '[\}\]]\s*,?\s*$')
            {
                # This line ends with ] or }, decrement the indentation level
                $indent--
            }
            $line = ('  ' * $indent) + $($_.TrimStart() -replace '":  (["{[])', '": $1' -replace ':  ', ': ')
            if ($_ -match '[\{\[]\s*$')
            {
                # This line ends with [ or {, increment the indentation level
                $indent++
            }
            $line
        }) -join "`n"
    }

    hidden static [System.Object[]] ConvertSCDLPEndpointDlpRestrictions([System.Object[]] $EndpointDlpRestrictions)
    {
        if ($null -eq $EndpointDlpRestrictions)
        {
            return $null
        }

        $returnValue = @()
        foreach ($restriction in $EndpointDlpRestrictions)
        {
            $currentRestriction = @{}
            foreach ($propertyName in @('Setting', 'Value', 'Value2'))
            {
                if ($restriction -is [System.Collections.IDictionary])
                {
                    if ($restriction.Contains($propertyName) -and $null -ne $restriction[$propertyName])
                    {
                        $currentRestriction[$propertyName] = $restriction[$propertyName]
                    }
                }
                elseif ($null -ne $restriction.$propertyName)
                {
                    $currentRestriction[$propertyName] = $restriction.$propertyName
                }
            }
            $returnValue += $currentRestriction
        }

        return $returnValue
    }

    hidden static [System.Boolean] TestContainsSensitiveInformationLabels([System.Object[]] $DesiredValues, [System.Object[]] $CurrentValues, [System.Boolean] $LogDrift)
    {
        $currentItems = [SCDLPComplianceRule]::NewMemberLookup($CurrentValues, 'name')
        foreach ($sit in @($DesiredValues))
        {
            if ($null -eq $sit)
            {
                continue
            }

            $sitName = [System.String] $sit.name
            Write-Verbose -Message "Trying to find existing Sensitive Information labels matching name {$sitName}"
            $matchingExistingRule = $currentItems[$sitName.Replace("''", "'")]
            if ($null -eq $matchingExistingRule)
            {
                Write-Verbose -Message "Sensitive Information label {$sitName} was not found"
                if ($LogDrift)
                {
                    $EventMessage = "DLP Compliance Rule was not in the desired state.`r`n" + `
                        "An action on {$sitName} Sensitive Information label is missing."
                    Add-M365DSCEvent -Message $EventMessage -EntryType 'Warning' `
                        -EventID 1 -Source 'SCDLPComplianceRule'
                }
                return $false
            }

            Write-Verbose -Message "Sensitive Information label {$sitName} was found"
            foreach ($property in @('id', 'type'))
            {
                $desiredValue = $sit.$property
                $currentValue = $matchingExistingRule.$property
                if ([System.String] $desiredValue -ne [System.String] $currentValue)
                {
                    Write-Verbose -Message "Property {$property} is set to {$currentValue} and is expected to be {$desiredValue}."
                    if ($LogDrift)
                    {
                        $EventMessage = "DLP Compliance Rule was not in the desired state.`r`n" + `
                            "Sensitive Information Action {$sitName} has invalid value for property {$property}. " + `
                            "Current value is {$currentValue} and is expected to be {$desiredValue}."
                        Add-M365DSCEvent -Message $EventMessage -EntryType 'Warning' `
                            -EventID 1 -Source 'SCDLPComplianceRule'
                    }
                    return $false
                }
            }
        }

        return $true
    }

    hidden static [System.Object[]] GetSCDLPSensitiveInformation([System.Object[]] $SensitiveInformationItems)
    {
        $returnValue = @()

        foreach ($item in $SensitiveInformationItems.SensitiveInformation)
        {
            $result = @{
                name = $item.name
            }

            if ($null -ne $item.id)
            {
                $result.Add('id', $item.id)
            }

            if ($null -ne $item.maxconfidence)
            {
                $result.Add('maxconfidence', $item.maxconfidence)
            }

            if ($null -ne $item.minconfidence)
            {
                $result.Add('minconfidence', $item.minconfidence)
            }

            if ($null -ne $item.classifiertype)
            {
                $result.Add('classifiertype', $item.classifiertype)
            }

            if ($null -ne $item.mincount)
            {
                $result.Add('mincount', $item.mincount)
            }

            if ($null -ne $item.maxcount)
            {
                $result.Add('maxcount', $item.maxcount)
            }
            $returnValue += $result
        }
        return $returnValue
    }

    hidden [SCDLPComplianceRule] AsResult([System.Object] $Values)
    {
        if ($Values -is [SCDLPComplianceRule])
        {
            return $Values
        }

        $result = [SCDLPComplianceRule]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}

class MSFT_SCDLPContainsSensitiveInformation
{
    [DscProperty()]
    [System.ComponentModel.Description('Sensitive Information Content Types')]
    [MSFT_SCDLPSensitiveInformation[]] $SensitiveInformation

    [DscProperty()]
    [System.ComponentModel.Description('Groups of sensitive information types.')]
    [MSFT_SCDLPContainsSensitiveInformationGroup[]] $Groups

    [DscProperty()]
    [System.ComponentModel.Description('Operator')]
    [ValidateSet('And', 'Or')]
    [System.String] $Operator
}

class MSFT_SCDLPEndpointDlpRestriction
{
    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('The Endpoint DLP restriction setting.')]
    [System.String] $Setting

    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('The Endpoint DLP restriction value.')]
    [System.String] $Value

    [DscProperty()]
    [System.ComponentModel.Description('Additional Endpoint DLP restriction value.')]
    [System.String] $Value2
}

class MSFT_SCDLPSensitiveInformation
{
    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('Name of the Sensitive Information Content')]
    [System.String] $name

    [DscProperty()]
    [System.ComponentModel.Description('Id of the Sensitive Information Content')]
    [System.String] $id

    [DscProperty()]
    [System.ComponentModel.Description('Maximum Confidence level value for the Sensitive Information')]
    [System.String] $maxconfidence

    [DscProperty()]
    [System.ComponentModel.Description('Minimum Confidence level value for the Sensitive Information')]
    [System.String] $minconfidence

    [DscProperty()]
    [System.ComponentModel.Description('Type of Classifier value for the Sensitive Information')]
    [System.String] $classifiertype

    [DscProperty()]
    [System.ComponentModel.Description('Minimum Count value for the Sensitive Information')]
    [System.String] $mincount

    [DscProperty()]
    [System.ComponentModel.Description('Maximum Count value for the Sensitive Information')]
    [System.String] $maxcount
}

class MSFT_SCDLPContainsSensitiveInformationGroup
{
    [DscProperty()]
    [System.ComponentModel.Description('Sensitive Information Content Types')]
    [MSFT_SCDLPSensitiveInformation[]] $SensitiveInformation

    [DscProperty()]
    [System.ComponentModel.Description('Sensitive Information Labels')]
    [MSFT_SCDLPLabel[]] $Labels

    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('Name of the group')]
    [System.String] $Name

    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('Operator')]
    [ValidateSet('And', 'Or')]
    [System.String] $Operator
}

class MSFT_SCDLPLabel
{
    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('Name of the Sensitive Label')]
    [System.String] $name

    [DscProperty()]
    [System.ComponentModel.Description('Id of the Sensitive Information label')]
    [System.String] $id

    [DscProperty()]
    [System.ComponentModel.Description('Type of the Sensitive Information label')]
    [System.String] $type
}
