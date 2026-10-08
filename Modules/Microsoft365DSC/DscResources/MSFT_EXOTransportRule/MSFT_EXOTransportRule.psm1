using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class EXOTransportRule : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The Name parameter specifies the display name of the transport rule to be created. The maximum length is 64 characters.')]
    [ValidateLength(1, 64)]
    [System.String] $Name

    [DscProperty()]
    [System.ComponentModel.Description('This parameter specifies a condition or part of a condition for the rule. The name of the corresponding exception parameter starts with ExceptIf.')]
    [System.String] $ADComparisonAttribute

    [DscProperty()]
    [System.ComponentModel.Description('This parameter specifies a condition or part of a condition for the rule. The name of the corresponding exception parameter starts with ExceptIf.')]
    [ValidateSet('Equal', 'NotEqual')]
    [System.String] $ADComparisonOperator

    [DscProperty()]
    [System.ComponentModel.Description('The ActivationDate parameter specifies when the rule starts processing messages. The rule won''t take any action on messages until the specified date/time.')]
    [System.String] $ActivationDate

    [DscProperty()]
    [System.ComponentModel.Description('The AddManagerAsRecipientType parameter specifies an action that delivers or redirects messages to the user that''s defined in the sender''s Manager attribute.')]
    [ValidateSet('To', 'Cc', 'Bcc', 'Redirect')]
    [System.String] $AddManagerAsRecipientType

    [DscProperty()]
    [System.ComponentModel.Description('The AddToRecipients parameter specifies an action that adds recipients to the To field of messages.')]
    [System.String[]] $AddToRecipients

    [DscProperty()]
    [System.ComponentModel.Description('The AnyOfCcHeader parameter specifies a condition that looks for recipients in the Cc field of messages.')]
    [System.String[]] $AnyOfCcHeader

    [DscProperty()]
    [System.ComponentModel.Description('The AnyOfCcHeaderMemberOf parameter specifies a condition that looks for group members in the Cc field of messages.')]
    [System.String[]] $AnyOfCcHeaderMemberOf

    [DscProperty()]
    [System.ComponentModel.Description('The AnyOfRecipientAddressContainsWords parameter specifies a condition that looks for words in recipient email addresses.')]
    [System.String[]] $AnyOfRecipientAddressContainsWords

    [DscProperty()]
    [System.ComponentModel.Description('The AnyOfRecipientAddressMatchesPatterns parameter specifies a condition that looks for text patterns in recipient email addresses by using regular expressions.')]
    [System.String[]] $AnyOfRecipientAddressMatchesPatterns

    [DscProperty()]
    [System.ComponentModel.Description('The AnyOfToCcHeader parameter specifies a condition that looks for recipients in the To or Cc fields of messages.')]
    [System.String[]] $AnyOfToCcHeader

    [DscProperty()]
    [System.ComponentModel.Description('The AnyOfToCcHeaderMemberOf parameter specifies a condition that looks for group members in the To and Cc fields of messages.')]
    [System.String[]] $AnyOfToCcHeaderMemberOf

    [DscProperty()]
    [System.ComponentModel.Description('The AnyOfToHeader parameter specifies a condition that looks for recipients in the To field of messages.')]
    [System.String[]] $AnyOfToHeader

    [DscProperty()]
    [System.ComponentModel.Description('The AnyOfToHeaderMemberOf parameter specifies a condition that looks for group members in the To field of messages.')]
    [System.String[]] $AnyOfToHeaderMemberOf

    [DscProperty()]
    [System.ComponentModel.Description('The ApplyClassification parameter specifies an action that applies a message classification to messages. ')]
    [System.String] $ApplyClassification

    [DscProperty()]
    [System.ComponentModel.Description('The ApplyHtmlDisclaimerFallbackAction parameter specifies what to do if the HTML disclaimer can''t be added to a message.')]
    [ValidateSet('Wrap', 'Ignore', 'Reject')]
    [System.String] $ApplyHtmlDisclaimerFallbackAction

    [DscProperty()]
    [System.ComponentModel.Description('The ApplyHtmlDisclaimerLocation parameter specifies where to insert the HTML disclaimer text in the body of messages.')]
    [ValidateSet('Append', 'Prepend')]
    [System.String] $ApplyHtmlDisclaimerLocation

    [DscProperty()]
    [System.ComponentModel.Description('The ApplyHtmlDisclaimerText parameter specifies an action that adds the disclaimer text to messages.')]
    [System.String] $ApplyHtmlDisclaimerText

    [DscProperty()]
    [System.ComponentModel.Description('The ApplyRightsProtectionCustomizationTemplate parameter specifies an action that applies a custom branding template for OME encrypted messages.')]
    [System.String] $ApplyRightsProtectionCustomizationTemplate

    [DscProperty()]
    [System.ComponentModel.Description('The ApplyRightsProtectionTemplate parameter specifies an action that applies rights management service (RMS) templates to messages. ')]
    [System.String] $ApplyRightsProtectionTemplate

    [DscProperty()]
    [System.ComponentModel.Description('The AttachmentContainsWords parameter specifies a condition that looks for words in message attachments. ')]
    [System.String[]] $AttachmentContainsWords

    [DscProperty()]
    [System.ComponentModel.Description('The AttachmentExtensionMatchesWords parameter specifies a condition that looks for words in the file name extensions of message attachments.')]
    [System.String[]] $AttachmentExtensionMatchesWords

    [DscProperty()]
    [System.ComponentModel.Description('The AttachmentHasExecutableContent parameter specifies a condition that looks for executable content in message attachments.')]
    [System.Nullable[System.Boolean]] $AttachmentHasExecutableContent

    [DscProperty()]
    [System.ComponentModel.Description('The AttachmentIsPasswordProtected parameter specifies a condition that looks for password protected files in messages (because the contents of the file can''t be inspected).')]
    [System.Nullable[System.Boolean]] $AttachmentIsPasswordProtected

    [DscProperty()]
    [System.ComponentModel.Description('The AttachmentIsUnsupported parameter specifies a condition that looks for unsupported file types in messages.')]
    [System.Nullable[System.Boolean]] $AttachmentIsUnsupported

    [DscProperty()]
    [System.ComponentModel.Description('The AttachmentMatchesPatterns parameter specifies a condition that looks for text patterns in the content of message attachments by using regular expressions.')]
    [System.String[]] $AttachmentMatchesPatterns

    [DscProperty()]
    [System.ComponentModel.Description('The AttachmentNameMatchesPatterns parameter specifies a condition that looks for text patterns in the file name of message attachments by using regular expressions.')]
    [System.String[]] $AttachmentNameMatchesPatterns

    [DscProperty()]
    [System.ComponentModel.Description('The AttachmentProcessingLimitExceeded parameter specifies a condition that looks for messages where attachment scanning didn''t complete.')]
    [System.Nullable[System.Boolean]] $AttachmentProcessingLimitExceeded

    [DscProperty()]
    [System.ComponentModel.Description('The AttachmentPropertyContainsWords parameter specifies a condition that looks for words in the properties of attached Office documents.')]
    [System.String[]] $AttachmentPropertyContainsWords

    [DscProperty()]
    [System.ComponentModel.Description('The AttachmentSizeOver parameter specifies a condition that looks for messages where any attachment is greater than the specified size.')]
    [System.String] $AttachmentSizeOver

    [DscProperty()]
    [System.ComponentModel.Description('The BetweenMemberOf1 parameter specifies a condition that looks for messages that are sent between group members.')]
    [System.String[]] $BetweenMemberOf1

    [DscProperty()]
    [System.ComponentModel.Description('The BetweenMemberOf2 parameter specifies a condition that looks for messages that are sent between group members.')]
    [System.String[]] $BetweenMemberOf2

    [DscProperty()]
    [System.ComponentModel.Description('The BlindCopyTo parameter specifies an action that adds recipients to the Bcc field of messages. ')]
    [System.String[]] $BlindCopyTo

    [DscProperty()]
    [System.ComponentModel.Description('The Comments parameter specifies optional descriptive text for the rule. The length of the comment can''t exceed 1024 characters.')]
    [ValidateLength(0, 1024)]
    [System.String] $Comments

    [DscProperty()]
    [System.ComponentModel.Description('The ContentCharacterSetContainsWords parameter specifies a condition that looks for character set names in messages.')]
    [System.String[]] $ContentCharacterSetContainsWords

    [DscProperty()]
    [System.ComponentModel.Description('The CopyTo parameter specifies an action that adds recipients to the Cc field of messages.')]
    [System.String[]] $CopyTo

    [DscProperty()]
    [System.ComponentModel.Description('The DeleteMessage parameter specifies an action that silently drops messages without an NDR.')]
    [System.Nullable[System.Boolean]] $DeleteMessage

    [DscProperty()]
    [System.ComponentModel.Description('The DlpPolicy parameter specifies the data loss prevention (DLP) policy that''s associated with the rule.')]
    [System.String] $DlpPolicy

    [DscProperty()]
    [System.ComponentModel.Description('The Enabled parameter specifies whether the new rule is created as enabled or disabled.')]
    [System.Nullable[System.Boolean]] $Enabled

    [DscProperty()]
    [System.ComponentModel.Description('The ExceptIfADComparisonAttribute parameter specifies an exception that compares an Active Directory attribute between the sender and all recipients of the message.')]
    [System.String] $ExceptIfADComparisonAttribute

    [DscProperty()]
    [System.ComponentModel.Description('The ExceptIfADComparisonOperator parameter specifies the comparison operator for the ExceptIfADComparisonAttribute parameter.')]
    [ValidateSet('Equal', 'NotEqual')]
    [System.String] $ExceptIfADComparisonOperator

    [DscProperty()]
    [System.ComponentModel.Description('The ExceptIfAnyOfCcHeader parameter specifies an exception that looks for recipients in the Cc field of messages.')]
    [System.String[]] $ExceptIfAnyOfCcHeader

    [DscProperty()]
    [System.ComponentModel.Description('The ExceptIfAnyOfCcHeaderMemberOf parameter specifies an exception that looks for group members in the Cc field of messages. You can use any value that uniquely identifies the group.')]
    [System.String[]] $ExceptIfAnyOfCcHeaderMemberOf

    [DscProperty()]
    [System.ComponentModel.Description('The ExceptIfAnyOfRecipientAddressContainsWords parameter specifies an exception that looks for words in recipient email addresses.')]
    [System.String[]] $ExceptIfAnyOfRecipientAddressContainsWords

    [DscProperty()]
    [System.ComponentModel.Description('The ExceptIfAnyOfRecipientAddressMatchesPatterns parameter specifies an exception that looks for text patterns in recipient email addresses by using regular expressions.')]
    [System.String[]] $ExceptIfAnyOfRecipientAddressMatchesPatterns

    [DscProperty()]
    [System.ComponentModel.Description('The ExceptIfAnyOfToCcHeader parameter specifies an exception that looks for recipients in the To or Cc fields of messages.')]
    [System.String[]] $ExceptIfAnyOfToCcHeader

    [DscProperty()]
    [System.ComponentModel.Description('The ExceptIfAnyOfToCcHeaderMemberOf parameter specifies an exception that looks for group members in the To and Cc fields of messages.')]
    [System.String[]] $ExceptIfAnyOfToCcHeaderMemberOf

    [DscProperty()]
    [System.ComponentModel.Description('The ExceptIfAnyOfToHeader parameter specifies an exception that looks for recipients in the To field of messages.')]
    [System.String[]] $ExceptIfAnyOfToHeader

    [DscProperty()]
    [System.ComponentModel.Description('The ExceptIfAnyOfToHeaderMemberOf parameter specifies an exception that looks for group members in the To field of messages.')]
    [System.String[]] $ExceptIfAnyOfToHeaderMemberOf

    [DscProperty()]
    [System.ComponentModel.Description('The ExceptIfAttachmentContainsWords parameter specifies an exception that looks for words in message attachments.')]
    [System.String[]] $ExceptIfAttachmentContainsWords

    [DscProperty()]
    [System.ComponentModel.Description('The ExceptIfAttachmentExtensionMatchesWords parameter specifies an exception that looks for words in the file name extensions of message attachments.')]
    [System.String[]] $ExceptIfAttachmentExtensionMatchesWords

    [DscProperty()]
    [System.ComponentModel.Description('The ExceptIfAttachmentHasExecutableContent parameter specifies an exception that looks for executable content in message attachments.')]
    [System.Nullable[System.Boolean]] $ExceptIfAttachmentHasExecutableContent

    [DscProperty()]
    [System.ComponentModel.Description('The ExceptIfAttachmentIsPasswordProtected parameter specifies an exception that looks for password protected files in messages (because the contents of the file can''t be inspected).')]
    [System.Nullable[System.Boolean]] $ExceptIfAttachmentIsPasswordProtected

    [DscProperty()]
    [System.ComponentModel.Description('The ExceptIfAttachmentIsUnsupported parameter specifies an exception that looks for unsupported file types in messages.')]
    [System.Nullable[System.Boolean]] $ExceptIfAttachmentIsUnsupported

    [DscProperty()]
    [System.ComponentModel.Description('The ExceptIfAttachmentMatchesPatterns parameter specifies an exception that looks for text patterns in the content of message attachments by using regular expressions.')]
    [System.String[]] $ExceptIfAttachmentMatchesPatterns

    [DscProperty()]
    [System.ComponentModel.Description('The ExceptIfAttachmentNameMatchesPatterns parameter specifies an exception that looks for text patterns in the file name of message attachments by using regular expressions.')]
    [System.String[]] $ExceptIfAttachmentNameMatchesPatterns

    [DscProperty()]
    [System.ComponentModel.Description('The ExceptIfAttachmentPropertyContainsWords parameter specifies an exception that looks for words in the properties of attached Office documents. ')]
    [System.String[]] $ExceptIfAttachmentPropertyContainsWords

    [DscProperty()]
    [System.ComponentModel.Description('The ExceptIfAttachmentProcessingLimitExceeded parameter specifies an exception that looks for messages where attachment scanning didn''t complete.')]
    [System.Nullable[System.Boolean]] $ExceptIfAttachmentProcessingLimitExceeded

    [DscProperty()]
    [System.ComponentModel.Description('The ExceptIfAttachmentSizeOver parameter specifies an exception that looks for messages where any attachment is greater than the specified size.')]
    [System.String] $ExceptIfAttachmentSizeOver

    [DscProperty()]
    [System.ComponentModel.Description('The ExceptIfBetweenMemberOf1 parameter specifies an exception that looks for messages that are sent between group members. ')]
    [System.String[]] $ExceptIfBetweenMemberOf1

    [DscProperty()]
    [System.ComponentModel.Description('The ExceptIfBetweenMemberOf2 parameter specifies an exception that looks for messages that are sent between group members.')]
    [System.String[]] $ExceptIfBetweenMemberOf2

    [DscProperty()]
    [System.ComponentModel.Description('The ExceptIfContentCharacterSetContainsWords parameter specifies an exception that looks for character set names in messages.')]
    [System.String[]] $ExceptIfContentCharacterSetContainsWords

    [DscProperty()]
    [System.ComponentModel.Description('The ExceptIfFrom parameter specifies an exception that looks for messages from specific senders.')]
    [System.String[]] $ExceptIfFrom

    [DscProperty()]
    [System.ComponentModel.Description('The ExceptIfFromAddressContainsWords parameter specifies an exception that looks for words in the sender''s email address.')]
    [System.String[]] $ExceptIfFromAddressContainsWords

    [DscProperty()]
    [System.ComponentModel.Description('The ExceptIfFromAddressMatchesPatterns parameter specifies an exception that looks for text patterns in the sender''s email address by using regular expressions.')]
    [System.String[]] $ExceptIfFromAddressMatchesPatterns

    [DscProperty()]
    [System.ComponentModel.Description('The ExceptIfFromMemberOf parameter specifies an exception that looks for messages sent by group members.')]
    [System.String[]] $ExceptIfFromMemberOf

    [DscProperty()]
    [System.ComponentModel.Description('The ExceptIfFromScope parameter specifies an exception that looks for the location of message senders.')]
    [ValidateSet('InOrganization', 'NotInOrganization')]
    [System.String] $ExceptIfFromScope

    [DscProperty()]
    [System.ComponentModel.Description('The ExceptIfHasClassification parameter specifies an exception that looks for messages with the specified message classification.')]
    [System.String] $ExceptIfHasClassification

    [DscProperty()]
    [System.ComponentModel.Description('The ExceptIfHasNoClassification parameter specifies an exception that looks for messages with or without any message classifications.')]
    [System.Nullable[System.Boolean]] $ExceptIfHasNoClassification

    [DscProperty()]
    [System.ComponentModel.Description('The ExceptIfHeaderContainsMessageHeader parameter specifies the name of header field in the message header when searching for the words specified by the ExceptIfHeaderContainsWords parameter.')]
    [System.String] $ExceptIfHeaderContainsMessageHeader

    [DscProperty()]
    [System.ComponentModel.Description('The ExceptIfHeaderContainsWords parameter specifies an exception that looks for words in a header field.')]
    [System.String[]] $ExceptIfHeaderContainsWords

    [DscProperty()]
    [System.ComponentModel.Description('The ExceptIfHeaderMatchesMessageHeader parameter specifies the name of header field in the message header when searching for the text patterns specified by the ExceptIfHeaderMatchesPatterns parameter.')]
    [System.String] $ExceptIfHeaderMatchesMessageHeader

    [DscProperty()]
    [System.ComponentModel.Description('The ExceptIfHeaderMatchesPatterns parameter specifies an exception that looks for text patterns in a header field by using regular expressions.')]
    [System.String[]] $ExceptIfHeaderMatchesPatterns

    [DscProperty()]
    [System.ComponentModel.Description('The ExceptIfManagerAddresses parameter specifies the users (managers) for the ExceptIfManagerForEvaluatedUser parameter.')]
    [System.String[]] $ExceptIfManagerAddresses

    [DscProperty()]
    [System.ComponentModel.Description('The ExceptIfManagerForEvaluatedUser parameter specifies an exception that looks for users in the Manager attribute of senders or recipients.')]
    [System.String] $ExceptIfManagerForEvaluatedUser

    [DscProperty()]
    [System.ComponentModel.Description('The ExceptIfMessageTypeMatches parameter specifies an exception that looks for messages of the specified type.')]
    [ValidateSet('OOF', 'AutoForward', 'Encrypted', 'Calendaring', 'PermissionControlled', 'Voicemail', 'Signed', 'ApprovalRequest', 'ReadReceipt')]
    [System.String] $ExceptIfMessageTypeMatches

    [DscProperty()]
    [System.ComponentModel.Description('The ExceptIfMessageSizeOver parameter specifies an exception that looks for messages larger than the specified size. ')]
    [System.String] $ExceptIfMessageSizeOver

    [DscProperty()]
    [System.ComponentModel.Description('The ExceptIfRecipientADAttributeContainsWords parameter specifies an exception that looks for words in the Active Directory attributes of recipients.')]
    [System.String[]] $ExceptIfRecipientADAttributeContainsWords

    [DscProperty()]
    [System.ComponentModel.Description('The ExceptIfRecipientADAttributeMatchesPatterns parameter specifies an exception that looks for text patterns in the Active Directory attributes of recipients by using regular expressions.')]
    [System.String[]] $ExceptIfRecipientADAttributeMatchesPatterns

    [DscProperty()]
    [System.ComponentModel.Description('The ExceptIfRecipientAddressContainsWords parameter specifies an exception that looks for words in recipient email addresses.')]
    [System.String[]] $ExceptIfRecipientAddressContainsWords

    [DscProperty()]
    [System.ComponentModel.Description('The ExceptIfRecipientAddressMatchesPatterns parameter specifies an exception that looks for text patterns in recipient email addresses by using regular expressions.')]
    [System.String[]] $ExceptIfRecipientAddressMatchesPatterns

    [DscProperty()]
    [System.ComponentModel.Description('The ExceptIfRecipientDomainIs parameter specifies an exception that looks for recipients with email address in the specified domains.')]
    [System.String[]] $ExceptIfRecipientDomainIs

    [DscProperty()]
    [System.ComponentModel.Description('This parameter is reserved for internal Microsoft use.')]
    [System.String[]] $ExceptIfRecipientInSenderList

    [DscProperty()]
    [System.ComponentModel.Description('The ExceptIfSCLOver parameter specifies an exception that looks for the SCL value of messages')]
    [System.String] $ExceptIfSCLOver

    [DscProperty()]
    [System.ComponentModel.Description('The ExceptIfSenderADAttributeContainsWords parameter specifies an exception that looks for words in Active Directory attributes of message senders.')]
    [System.String[]] $ExceptIfSenderADAttributeContainsWords

    [DscProperty()]
    [System.ComponentModel.Description('The ExceptIfSenderADAttributeMatchesPatterns parameter specifies an exception that looks for text patterns in Active Directory attributes of message senders by using regular expressions.')]
    [System.String[]] $ExceptIfSenderADAttributeMatchesPatterns

    [DscProperty()]
    [System.ComponentModel.Description('The ExceptIfSenderDomainIs parameter specifies an exception that looks for senders with email address in the specified domains.')]
    [System.String[]] $ExceptIfSenderDomainIs

    [DscProperty()]
    [System.ComponentModel.Description('This parameter is reserved for internal Microsoft use.')]
    [System.String[]] $ExceptIfSenderInRecipientList

    [DscProperty()]
    [System.ComponentModel.Description('The ExceptIfSenderIpRanges parameter specifies an exception that looks for senders whose IP addresses matches the specified value, or fall within the specified ranges.')]
    [System.String[]] $ExceptIfSenderIpRanges

    [DscProperty()]
    [System.ComponentModel.Description('The ExceptIfSenderManagementRelationship parameter specifies an exception that looks for the relationship between the sender and recipients in messages.')]
    [ValidateSet('Manager', 'DirectReport')]
    [System.String] $ExceptIfSenderManagementRelationship

    [DscProperty()]
    [System.ComponentModel.Description('The ExceptIfSentTo parameter specifies an exception that looks for recipients in messages. You can use any value that uniquely identifies the recipient.')]
    [System.String[]] $ExceptIfSentTo

    [DscProperty()]
    [System.ComponentModel.Description('The ExceptIfSentToMemberOf parameter specifies an exception that looks for messages sent to members of groups. You can use any value that uniquely identifies the group.')]
    [System.String[]] $ExceptIfSentToMemberOf

    [DscProperty()]
    [System.ComponentModel.Description('The ExceptIfSentToScope parameter specifies an exception that looks for the location of a recipient. ')]
    [ValidateSet('InOrganization', 'NotInOrganization', 'ExternalPartner', 'ExternalNonPartner')]
    [System.String] $ExceptIfSentToScope

    [DscProperty()]
    [System.ComponentModel.Description('The ExceptIfSubjectContainsWords parameter specifies an exception that looks for words in the Subject field of messages.')]
    [System.String[]] $ExceptIfSubjectContainsWords

    [DscProperty()]
    [System.ComponentModel.Description('The ExceptIfSubjectMatchesPatterns parameter specifies an exception that looks for text patterns in the Subject field of messages by using regular expressions.')]
    [System.String[]] $ExceptIfSubjectMatchesPatterns

    [DscProperty()]
    [System.ComponentModel.Description('The ExceptIfSubjectOrBodyContainsWords parameter specifies an exception that looks for words in the Subject field or body of messages.')]
    [System.String[]] $ExceptIfSubjectOrBodyContainsWords

    [DscProperty()]
    [System.ComponentModel.Description('The ExceptIfSubjectOrBodyMatchesPatterns parameter specifies an exception that looks for text patterns in the Subject field or body of messages.')]
    [System.String[]] $ExceptIfSubjectOrBodyMatchesPatterns

    [DscProperty()]
    [System.ComponentModel.Description('The ExceptIfWithImportance parameter specifies an exception that looks for messages with the specified importance level.')]
    [ValidateSet('Low', 'Normal', 'High')]
    [System.String] $ExceptIfWithImportance

    [DscProperty()]
    [System.ComponentModel.Description('The ExpiryDate parameter specifies when this rule will stop processing messages. The rule won''t take any action on messages after the specified date/time.')]
    [System.String] $ExpiryDate

    [DscProperty()]
    [System.ComponentModel.Description('The From parameter specifies a condition that looks for messages from specific senders. You can use any value that uniquely identifies the sender.')]
    [System.String[]] $From

    [DscProperty()]
    [System.ComponentModel.Description('The FromAddressContainsWords parameter specifies a condition that looks for words in the sender''s email address. ')]
    [System.String[]] $FromAddressContainsWords

    [DscProperty()]
    [System.ComponentModel.Description('The FromAddressMatchesPatterns parameter specifies a condition that looks for text patterns in the sender''s email address by using regular expressions.')]
    [System.String[]] $FromAddressMatchesPatterns

    [DscProperty()]
    [System.ComponentModel.Description('The FromMemberOf parameter specifies a condition that looks for messages sent by group members.')]
    [System.String[]] $FromMemberOf

    [DscProperty()]
    [System.ComponentModel.Description('The FromScope parameter specifies a condition that looks for the location of message senders.')]
    [ValidateSet('InOrganization', 'NotInOrganization')]
    [System.String] $FromScope

    [DscProperty()]
    [System.ComponentModel.Description('The GenerateIncidentReport parameter specifies where to send the incident report that''s defined by the IncidentReportContent parameter.')]
    [System.String] $GenerateIncidentReport

    [DscProperty()]
    [System.ComponentModel.Description('The GenerateNotification parameter specifies an action that sends a notification message to recipients.')]
    [System.String] $GenerateNotification

    [DscProperty()]
    [System.ComponentModel.Description('The HasClassification parameter specifies a condition that looks for messages with the specified message classification.')]
    [System.String] $HasClassification

    [DscProperty()]
    [System.ComponentModel.Description('The HasNoClassification parameter specifies a condition that looks for messages with or without any message classifications.')]
    [System.Nullable[System.Boolean]] $HasNoClassification

    [DscProperty()]
    [System.ComponentModel.Description('The HeaderContainsMessageHeader parameter specifies the name of header field in the message header when searching for the words specified by the HeaderContainsWords parameter.')]
    [System.String] $HeaderContainsMessageHeader

    [DscProperty()]
    [System.ComponentModel.Description('The HeaderContainsWords parameter specifies a condition that looks for words in a header field.')]
    [System.String[]] $HeaderContainsWords

    [DscProperty()]
    [System.ComponentModel.Description('The HeaderMatchesMessageHeader parameter specifies the name of header field in the message header when searching for the text patterns specified by the HeaderMatchesPatterns parameter.')]
    [System.String] $HeaderMatchesMessageHeader

    [DscProperty()]
    [System.ComponentModel.Description('The HeaderMatchesPatterns parameter specifies a condition that looks for text patterns in a header field by using regular expressions. ')]
    [System.String[]] $HeaderMatchesPatterns

    [DscProperty()]
    [System.ComponentModel.Description('The IncidentReportContent parameter specifies the message properties that are included in the incident report that''s generated when a message violates a DLP policy. ')]
    [ValidateSet('Sender', 'Recipients', 'Subject', 'Cc', 'Bcc', 'Severity', 'Override', 'RuleDetections', 'FalsePositive', 'DataClassifications', 'IdMatch', 'AttachOriginalMail')]
    [System.String[]] $IncidentReportContent

    [DscProperty()]
    [System.ComponentModel.Description('The ManagerAddresses parameter specifies the users (managers) for the ExceptIfManagerForEvaluatedUser parameter.')]
    [System.String[]] $ManagerAddresses

    [DscProperty()]
    [System.ComponentModel.Description('The ManagerForEvaluatedUser parameter specifies a condition that looks for users in the Manager attribute of senders or recipients.')]
    [ValidateSet('Recipient', 'Sender')]
    [System.String] $ManagerForEvaluatedUser

    [DscProperty()]
    [System.ComponentModel.Description('The MessageSizeOver parameter specifies a condition that looks for messages larger than the specified size. The size includes the message and all attachments.')]
    [System.String] $MessageSizeOver

    [DscProperty()]
    [System.ComponentModel.Description('The MessageTypeMatches parameter specifies a condition that looks for messages of the specified type.')]
    [ValidateSet('OOF', 'AutoForward', 'Encrypted', 'Calendaring', 'PermissionControlled', 'Voicemail', 'Signed', 'ApprovalRequest', 'ReadReceipt')]
    [System.String] $MessageTypeMatches

    [DscProperty()]
    [System.ComponentModel.Description('The Mode parameter specifies how the rule operates.')]
    [ValidateSet('Audit', 'AuditAndNotify', 'Enforce')]
    [System.String] $Mode

    [DscProperty()]
    [System.ComponentModel.Description('The ModerateMessageByManager parameter specifies an action that forwards messages for approval to the user that''s specified in the sender''s Manager attribute.')]
    [System.Nullable[System.Boolean]] $ModerateMessageByManager

    [DscProperty()]
    [System.ComponentModel.Description('The ModerateMessageByUser parameter specifies an action that forwards messages for approval to the specified users.')]
    [System.String[]] $ModerateMessageByUser

    [DscProperty()]
    [System.ComponentModel.Description('The PrependSubject parameter specifies an action that adds text to add to the beginning of the Subject field of messages.')]
    [System.String] $PrependSubject

    [DscProperty()]
    [System.ComponentModel.Description('The Priority parameter specifies a priority value for the rule that determines the order of rule processing.')]
    [System.Nullable[System.UInt32]] $Priority

    [DscProperty()]
    [System.ComponentModel.Description('The Quarantine parameter specifies an action that quarantines messages.')]
    [System.Nullable[System.Boolean]] $Quarantine

    [DscProperty()]
    [System.ComponentModel.Description('The RecipientADAttributeContainsWords parameter specifies a condition that looks for words in the Active Directory attributes of recipients. ')]
    [System.String[]] $RecipientADAttributeContainsWords

    [DscProperty()]
    [System.ComponentModel.Description('The RecipientADAttributeMatchesPatterns parameter specifies a condition that looks for text patterns in the Active Directory attributes of recipients by using regular expressions.')]
    [System.String[]] $RecipientADAttributeMatchesPatterns

    [DscProperty()]
    [System.ComponentModel.Description('The RecipientAddressContainsWords parameter specifies a condition that looks for words in recipient email addresses.')]
    [System.String[]] $RecipientAddressContainsWords

    [DscProperty()]
    [System.ComponentModel.Description('The RecipientAddressMatchesPatterns parameter specifies a condition that looks for text patterns in recipient email addresses by using regular expressions.')]
    [System.String[]] $RecipientAddressMatchesPatterns

    [DscProperty()]
    [System.ComponentModel.Description('The RecipientAddressType parameter specifies how conditions and exceptions check recipient email addresses.')]
    [ValidateSet('Original', 'Resolved')]
    [System.String] $RecipientAddressType

    [DscProperty()]
    [System.ComponentModel.Description('The RecipientDomainIs parameter specifies a condition that looks for recipients with email address in the specified domains.')]
    [System.String[]] $RecipientDomainIs

    [DscProperty()]
    [System.ComponentModel.Description('This parameter is reserved for internal Microsoft use.')]
    [System.String[]] $RecipientInSenderList

    [DscProperty()]
    [System.ComponentModel.Description('The RedirectMessageTo parameter specifies a rule action that redirects messages to the specified recipients.')]
    [System.String[]] $RedirectMessageTo

    [DscProperty()]
    [System.ComponentModel.Description('The RejectMessageEnhancedStatusCode parameter specifies the enhanced status code that''s used when the rule rejects messages.')]
    [System.String] $RejectMessageEnhancedStatusCode

    [DscProperty()]
    [System.ComponentModel.Description('The RejectMessageReasonText parameter specifies the explanation text that''s used when the rule rejects messages.')]
    [System.String] $RejectMessageReasonText

    [DscProperty()]
    [System.ComponentModel.Description('The RemoveHeader parameter specifies an action that removes a header field from the message header.')]
    [System.String] $RemoveHeader

    [DscProperty()]
    [System.ComponentModel.Description('The RemoveOMEv2 parameter specifies an action that removes Office 365 Message Encryption from messages and their attachments.')]
    [System.Nullable[System.Boolean]] $RemoveOMEv2

    [DscProperty()]
    [System.ComponentModel.Description('This parameter specifies an action or part of an action for the rule.')]
    [System.Nullable[System.Boolean]] $RemoveRMSAttachmentEncryption

    [DscProperty()]
    [System.ComponentModel.Description('The RouteMessageOutboundConnector parameter specifies an action that routes messages through the specified Outbound connector in Office 365.')]
    [System.String] $RouteMessageOutboundConnector

    [DscProperty()]
    [System.ComponentModel.Description('The RouteMessageOutboundRequireTls parameter specifies an action that uses Transport Layer Security (TLS) encryption to deliver messages outside your organization.')]
    [System.Nullable[System.Boolean]] $RouteMessageOutboundRequireTls

    [DscProperty()]
    [System.ComponentModel.Description('The RuleErrorAction parameter specifies what to do if rule processing can''t be completed on messages.')]
    [ValidateSet('Ignore', 'Defer')]
    [System.String] $RuleErrorAction

    [DscProperty()]
    [System.ComponentModel.Description('The RuleSubType parameter specifies the rule type.')]
    [ValidateSet('Dlp', 'None')]
    [System.String] $RuleSubType

    [DscProperty()]
    [System.ComponentModel.Description('The SCLOver parameter specifies a condition that looks for the SCL value of messages')]
    [System.String] $SCLOver

    [DscProperty()]
    [System.ComponentModel.Description('The SenderADAttributeContainsWords parameter specifies a condition that looks for words in Active Directory attributes of message senders.')]
    [System.String[]] $SenderADAttributeContainsWords

    [DscProperty()]
    [System.ComponentModel.Description('The SenderADAttributeMatchesPatterns parameter specifies a condition that looks for text patterns in Active Directory attributes of message senders by using regular expressions.')]
    [System.String[]] $SenderADAttributeMatchesPatterns

    [DscProperty()]
    [System.ComponentModel.Description('The SenderAddressLocation parameter specifies where to look for sender addresses in conditions and exceptions that examine sender email addresses.')]
    [ValidateSet('Header', 'Envelope', 'HeaderOrEnvelope')]
    [System.String] $SenderAddressLocation

    [DscProperty()]
    [System.ComponentModel.Description('The SenderDomainIs parameter specifies a condition that looks for senders with email address in the specified domains.')]
    [System.String[]] $SenderDomainIs

    [DscProperty()]
    [System.ComponentModel.Description('This parameter is reserved for internal Microsoft use.')]
    [System.String[]] $SenderInRecipientList

    [DscProperty()]
    [System.ComponentModel.Description('The SenderIpRanges parameter specifies a condition that looks for senders whose IP addresses matches the specified value, or fall within the specified ranges.')]
    [System.String[]] $SenderIpRanges

    [DscProperty()]
    [System.ComponentModel.Description('The SenderManagementRelationship parameter specifies a condition that looks for the relationship between the sender and recipients in messages.')]
    [ValidateSet('Manager', 'DirectReport')]
    [System.String] $SenderManagementRelationship

    [DscProperty()]
    [System.ComponentModel.Description('The SentTo parameter specifies a condition that looks for recipients in messages.')]
    [System.String[]] $SentTo

    [DscProperty()]
    [System.ComponentModel.Description('The SentToMemberOf parameter specifies a condition that looks for messages sent to members of distribution groups, dynamic distribution groups, or mail-enabled security groups.')]
    [System.String[]] $SentToMemberOf

    [DscProperty()]
    [System.ComponentModel.Description('The SentToScope parameter specifies a condition that looks for the location of recipients.')]
    [ValidateSet('InOrganization', 'NotInOrganization', 'ExternalPartner', 'ExternalNonPartner')]
    [System.String] $SentToScope

    [DscProperty()]
    [System.ComponentModel.Description('The SetAuditSeverity parameter specifies an action that sets the severity level of the incident report and the corresponding entry that''s written to the message tracking log when messages violate DLP policies.')]
    [ValidateSet('DoNotAudit', 'Low', 'Medium', 'High')]
    [System.String] $SetAuditSeverity

    [DscProperty()]
    [System.ComponentModel.Description('The SetHeaderName parameter specifies an action that adds or modifies a header field in the message header.')]
    [System.String] $SetHeaderName

    [DscProperty()]
    [System.ComponentModel.Description('The SetHeaderValue parameter specifies an action that adds or modifies a header field in the message header.')]
    [System.String] $SetHeaderValue

    [DscProperty()]
    [System.ComponentModel.Description('The SetSCL parameter specifies an action that adds or modifies the SCL value of messages.')]
    [System.String] $SetSCL

    [DscProperty()]
    [System.ComponentModel.Description('The StopRuleProcessing parameter specifies an action that stops processing more rules.')]
    [System.Nullable[System.Boolean]] $StopRuleProcessing

    [DscProperty()]
    [System.ComponentModel.Description('The SubjectContainsWords parameter specifies a condition that looks for words in the Subject field of messages.')]
    [System.String[]] $SubjectContainsWords

    [DscProperty()]
    [System.ComponentModel.Description('The SubjectMatchesPatterns parameter specifies a condition that looks for text patterns in the Subject field of messages by using regular expressions.')]
    [System.String[]] $SubjectMatchesPatterns

    [DscProperty()]
    [System.ComponentModel.Description('The SubjectOrBodyContainsWords parameter specifies a condition that looks for words in the Subject field or body of messages.')]
    [System.String[]] $SubjectOrBodyContainsWords

    [DscProperty()]
    [System.ComponentModel.Description('The SubjectOrBodyMatchesPatterns parameter specifies a condition that looks for text patterns in the Subject field or body of messages.')]
    [System.String[]] $SubjectOrBodyMatchesPatterns

    [DscProperty()]
    [System.ComponentModel.Description('The WithImportance parameter specifies a condition that looks for messages with the specified importance level.')]
    [ValidateSet('Low', 'Normal', 'High')]
    [System.String] $WithImportance

    [DscProperty()]
    [System.ComponentModel.Description('Specify if the Transport Rule should exist or not.')]
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

    [EXOTransportRule] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [EXOTransportRule]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting Transport Rule configuration for $($this.Name)"

        try
        {
            $nullReturn = $this.GetBoundParameters()
            $nullReturn.Ensure = 'Absent'

            if (-not $this.ExportedInstance -or $this.ExportedInstance.Name -ne $this.Name)
            {
                $null = $this.Connect('ExchangeOnline')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $TransportRule = Get-TransportRule -Identity $this.Name -ErrorAction SilentlyContinue
                if ($null -eq $TransportRule)
                {
                    Write-Verbose -Message "Transport Rule $($this.Name) does not exist."
                    return $this.AsResult($nullReturn)
                }
            }
            else
            {
                $TransportRule = $this.ExportedInstance
            }

            $result = @{
                Name                                         = $TransportRule.Name
                ADComparisonAttribute                        = $TransportRule.ADComparisonAttribute
                ADComparisonOperator                         = $TransportRule.ADComparisonOperator
                ActivationDate                               = $TransportRule.ActivationDate
                AddManagerAsRecipientType                    = $TransportRule.AddManagerAsRecipientType
                AddToRecipients                              = $TransportRule.AddToRecipients
                AnyOfCcHeader                                = $TransportRule.AnyOfCcHeader
                AnyOfCcHeaderMemberOf                        = $TransportRule.AnyOfCcHeaderMemberOf
                AnyOfRecipientAddressContainsWords           = $TransportRule.AnyOfRecipientAddressContainsWords
                AnyOfRecipientAddressMatchesPatterns         = $TransportRule.AnyOfRecipientAddressMatchesPatterns
                AnyOfToCcHeader                              = $TransportRule.AnyOfToCcHeader
                AnyOfToCcHeaderMemberOf                      = $TransportRule.AnyOfToCcHeaderMemberOf
                AnyOfToHeader                                = $TransportRule.AnyOfToHeader
                AnyOfToHeaderMemberOf                        = $TransportRule.AnyOfToHeaderMemberOf
                ApplyClassification                          = $TransportRule.ApplyClassification
                ApplyHtmlDisclaimerFallbackAction            = $TransportRule.ApplyHtmlDisclaimerFallbackAction
                ApplyHtmlDisclaimerLocation                  = $TransportRule.ApplyHtmlDisclaimerLocation
                ApplyHtmlDisclaimerText                      = $TransportRule.ApplyHtmlDisclaimerText
                ApplyRightsProtectionCustomizationTemplate   = $TransportRule.ApplyRightsProtectionCustomizationTemplate
                ApplyRightsProtectionTemplate                = $TransportRule.ApplyRightsProtectionTemplate
                AttachmentContainsWords                      = $TransportRule.AttachmentContainsWords
                AttachmentExtensionMatchesWords              = $TransportRule.AttachmentExtensionMatchesWords
                AttachmentHasExecutableContent               = $TransportRule.AttachmentHasExecutableContent
                AttachmentIsPasswordProtected                = $TransportRule.AttachmentIsPasswordProtected
                AttachmentIsUnsupported                      = $TransportRule.AttachmentIsUnsupported
                AttachmentMatchesPatterns                    = $TransportRule.AttachmentMatchesPatterns
                AttachmentNameMatchesPatterns                = $TransportRule.AttachmentNameMatchesPatterns
                AttachmentPropertyContainsWords              = $TransportRule.AttachmentPropertyContainsWords
                AttachmentProcessingLimitExceeded            = $TransportRule.AttachmentProcessingLimitExceeded
                AttachmentSizeOver                           = $TransportRule.AttachmentSizeOver
                BetweenMemberOf1                             = $TransportRule.BetweenMemberOf1
                BetweenMemberOf2                             = $TransportRule.BetweenMemberOf2
                BlindCopyTo                                  = $TransportRule.BlindCopyTo
                Comments                                     = $TransportRule.Comments
                ContentCharacterSetContainsWords             = $TransportRule.ContentCharacterSetContainsWords
                CopyTo                                       = $TransportRule.CopyTo
                DeleteMessage                                = $TransportRule.DeleteMessage
                DlpPolicy                                    = $TransportRule.DlpPolicy
                Enabled                                      = $TransportRule.State -eq 'Enabled'
                ExceptIfADComparisonAttribute                = $TransportRule.ExceptIfADComparisonAttribute
                ExceptIfADComparisonOperator                 = $TransportRule.ExceptIfADComparisonOperator
                ExceptIfAnyOfCcHeader                        = $TransportRule.ExceptIfAnyOfCcHeader
                ExceptIfAnyOfCcHeaderMemberOf                = $TransportRule.ExceptIfAnyOfCcHeaderMemberOf
                ExceptIfAnyOfRecipientAddressContainsWords   = $TransportRule.ExceptIfAnyOfRecipientAddressContainsWords
                ExceptIfAnyOfRecipientAddressMatchesPatterns = $TransportRule.ExceptIfAnyOfRecipientAddressMatchesPatterns
                ExceptIfAnyOfToCcHeader                      = $TransportRule.ExceptIfAnyOfToCcHeader
                ExceptIfAnyOfToCcHeaderMemberOf              = $TransportRule.ExceptIfAnyOfToCcHeaderMemberOf
                ExceptIfAnyOfToHeader                        = $TransportRule.ExceptIfAnyOfToHeader
                ExceptIfAnyOfToHeaderMemberOf                = $TransportRule.ExceptIfAnyOfToHeaderMemberOf
                ExceptIfAttachmentContainsWords              = $TransportRule.ExceptIfAttachmentContainsWords
                ExceptIfAttachmentExtensionMatchesWords      = $TransportRule.ExceptIfAttachmentExtensionMatchesWords
                ExceptIfAttachmentHasExecutableContent       = $TransportRule.ExceptIfAttachmentHasExecutableContent
                ExceptIfAttachmentIsPasswordProtected        = $TransportRule.ExceptIfAttachmentIsPasswordProtected
                ExceptIfAttachmentIsUnsupported              = $TransportRule.ExceptIfAttachmentIsUnsupported
                ExceptIfAttachmentMatchesPatterns            = $TransportRule.ExceptIfAttachmentMatchesPatterns
                ExceptIfAttachmentNameMatchesPatterns        = $TransportRule.ExceptIfAttachmentNameMatchesPatterns
                ExceptIfAttachmentPropertyContainsWords      = $TransportRule.ExceptIfAttachmentPropertyContainsWords
                ExceptIfAttachmentProcessingLimitExceeded    = $TransportRule.ExceptIfAttachmentProcessingLimitExceeded
                ExceptIfAttachmentSizeOver                   = $TransportRule.ExceptIfAttachmentSizeOver
                ExceptIfBetweenMemberOf1                     = $TransportRule.ExceptIfBetweenMemberOf1
                ExceptIfBetweenMemberOf2                     = $TransportRule.ExceptIfBetweenMemberOf2
                ExceptIfContentCharacterSetContainsWords     = $TransportRule.ExceptIfContentCharacterSetContainsWords
                ExceptIfFrom                                 = $TransportRule.ExceptIfFrom
                ExceptIfFromAddressContainsWords             = $TransportRule.ExceptIfFromAddressContainsWords
                ExceptIfFromAddressMatchesPatterns           = $TransportRule.ExceptIfFromAddressMatchesPatterns
                ExceptIfFromMemberOf                         = $TransportRule.ExceptIfFromMemberOf
                ExceptIfFromScope                            = $TransportRule.ExceptIfFromScope
                ExceptIfHasClassification                    = $TransportRule.ExceptIfHasClassification
                ExceptIfHasNoClassification                  = $TransportRule.ExceptIfHasNoClassification
                ExceptIfHeaderContainsMessageHeader          = $TransportRule.ExceptIfHeaderContainsMessageHeader
                ExceptIfHeaderContainsWords                  = $TransportRule.ExceptIfHeaderContainsWords
                ExceptIfHeaderMatchesMessageHeader           = $TransportRule.ExceptIfHeaderMatchesMessageHeader
                ExceptIfHeaderMatchesPatterns                = $TransportRule.ExceptIfHeaderMatchesPatterns
                ExceptIfManagerAddresses                     = $TransportRule.ExceptIfManagerAddresses
                ExceptIfManagerForEvaluatedUser              = $TransportRule.ExceptIfManagerForEvaluatedUser
                ExceptIfMessageTypeMatches                   = $TransportRule.ExceptIfMessageTypeMatches
                ExceptIfMessageSizeOver                      = $TransportRule.ExceptIfMessageSizeOver
                ExceptIfRecipientADAttributeContainsWords    = $TransportRule.ExceptIfRecipientADAttributeContainsWords
                ExceptIfRecipientADAttributeMatchesPatterns  = $TransportRule.ExceptIfRecipientADAttributeMatchesPatterns
                ExceptIfRecipientAddressContainsWords        = $TransportRule.ExceptIfRecipientAddressContainsWords
                ExceptIfRecipientAddressMatchesPatterns      = $TransportRule.ExceptIfRecipientAddressMatchesPatterns
                ExceptIfRecipientDomainIs                    = $TransportRule.ExceptIfRecipientDomainIs
                ExceptIfRecipientInSenderList                = $TransportRule.ExceptIfRecipientInSenderList
                ExceptIfSCLOver                              = $TransportRule.ExceptIfSCLOver
                ExceptIfSenderADAttributeContainsWords       = $TransportRule.ExceptIfSenderADAttributeContainsWords
                ExceptIfSenderADAttributeMatchesPatterns     = $TransportRule.ExceptIfSenderADAttributeMatchesPatterns
                ExceptIfSenderDomainIs                       = $TransportRule.ExceptIfSenderDomainIs
                ExceptIfSenderInRecipientList                = $TransportRule.ExceptIfSenderInRecipientList
                ExceptIfSenderIpRanges                       = $TransportRule.ExceptIfSenderIpRanges
                ExceptIfSenderManagementRelationship         = $TransportRule.ExceptIfSenderManagementRelationship
                ExceptIfSentTo                               = $TransportRule.ExceptIfSentTo
                ExceptIfSentToMemberOf                       = $TransportRule.ExceptIfSentToMemberOf
                ExceptIfSentToScope                          = $TransportRule.ExceptIfSentToScope
                ExceptIfSubjectContainsWords                 = $TransportRule.ExceptIfSubjectContainsWords
                ExceptIfSubjectMatchesPatterns               = $TransportRule.ExceptIfSubjectMatchesPatterns
                ExceptIfSubjectOrBodyContainsWords           = $TransportRule.ExceptIfSubjectOrBodyContainsWords
                ExceptIfSubjectOrBodyMatchesPatterns         = $TransportRule.ExceptIfSubjectOrBodyMatchesPatterns
                ExceptIfWithImportance                       = $TransportRule.ExceptIfWithImportance
                ExpiryDate                                   = $TransportRule.ExpiryDate
                From                                         = $TransportRule.From
                FromAddressContainsWords                     = $TransportRule.FromAddressContainsWords
                FromAddressMatchesPatterns                   = $TransportRule.FromAddressMatchesPatterns
                FromMemberOf                                 = $TransportRule.FromMemberOf
                FromScope                                    = $TransportRule.FromScope
                GenerateIncidentReport                       = $TransportRule.GenerateIncidentReport
                GenerateNotification                         = $TransportRule.GenerateNotification
                HasClassification                            = $TransportRule.HasClassification
                HasNoClassification                          = $TransportRule.HasNoClassification
                HeaderContainsMessageHeader                  = $TransportRule.HeaderContainsMessageHeader
                HeaderContainsWords                          = $TransportRule.HeaderContainsWords
                HeaderMatchesMessageHeader                   = $TransportRule.HeaderMatchesMessageHeader
                HeaderMatchesPatterns                        = $TransportRule.HeaderMatchesPatterns
                IncidentReportContent                        = $TransportRule.IncidentReportContent
                ManagerAddresses                             = $TransportRule.ManagerAddresses
                ManagerForEvaluatedUser                      = $TransportRule.ManagerForEvaluatedUser
                MessageSizeOver                              = $TransportRule.MessageSizeOver
                MessageTypeMatches                           = $TransportRule.MessageTypeMatches
                Mode                                         = $TransportRule.Mode
                ModerateMessageByManager                     = $TransportRule.ModerateMessageByManager
                ModerateMessageByUser                        = $TransportRule.ModerateMessageByUser
                PrependSubject                               = $TransportRule.PrependSubject
                Priority                                     = $TransportRule.Priority
                Quarantine                                   = $TransportRule.Quarantine
                RecipientADAttributeContainsWords            = $TransportRule.RecipientADAttributeContainsWords
                RecipientADAttributeMatchesPatterns          = $TransportRule.RecipientADAttributeMatchesPatterns
                RecipientAddressContainsWords                = $TransportRule.RecipientAddressContainsWords
                RecipientAddressMatchesPatterns              = $TransportRule.RecipientAddressMatchesPatterns
                RecipientAddressType                         = $TransportRule.RecipientAddressType
                RecipientDomainIs                            = $TransportRule.RecipientDomainIs
                RecipientInSenderList                        = $TransportRule.RecipientInSenderList
                RedirectMessageTo                            = $TransportRule.RedirectMessageTo
                RejectMessageEnhancedStatusCode              = $TransportRule.RejectMessageEnhancedStatusCode
                RejectMessageReasonText                      = $TransportRule.RejectMessageReasonText
                RemoveHeader                                 = $TransportRule.RemoveHeader
                RemoveOMEv2                                  = $TransportRule.RemoveOMEv2
                RemoveRMSAttachmentEncryption                = $TransportRule.RemoveRMSAttachmentEncryption
                RouteMessageOutboundConnector                = $TransportRule.RouteMessageOutboundConnector
                RouteMessageOutboundRequireTls               = $TransportRule.RouteMessageOutboundRequireTls
                RuleErrorAction                              = $TransportRule.RuleErrorAction
                RuleSubType                                  = $TransportRule.RuleSubType
                SCLOver                                      = $TransportRule.SCLOver
                SenderADAttributeContainsWords               = $TransportRule.SenderADAttributeContainsWords
                SenderADAttributeMatchesPatterns             = $TransportRule.SenderADAttributeMatchesPatterns
                SenderAddressLocation                        = $TransportRule.SenderAddressLocation
                SenderDomainIs                               = $TransportRule.SenderDomainIs
                SenderInRecipientList                        = $TransportRule.SenderInRecipientList
                SenderIpRanges                               = $TransportRule.SenderIpRanges
                SenderManagementRelationship                 = $TransportRule.SenderManagementRelationship
                SentTo                                       = $TransportRule.SentTo
                SentToMemberOf                               = $TransportRule.SentToMemberOf
                SentToScope                                  = $TransportRule.SentToScope
                SetAuditSeverity                             = $TransportRule.SetAuditSeverity
                SetHeaderName                                = $TransportRule.SetHeaderName
                SetHeaderValue                               = $TransportRule.SetHeaderValue
                SetSCL                                       = $TransportRule.SetSCL
                StopRuleProcessing                           = $TransportRule.StopRuleProcessing
                SubjectContainsWords                         = $TransportRule.SubjectContainsWords
                SubjectMatchesPatterns                       = $TransportRule.SubjectMatchesPatterns
                SubjectOrBodyContainsWords                   = $TransportRule.SubjectOrBodyContainsWords
                SubjectOrBodyMatchesPatterns                 = $TransportRule.SubjectOrBodyMatchesPatterns
                WithImportance                               = $TransportRule.WithImportance
                Ensure                                       = 'Present'
                Credential                                   = $this.Credential
                ApplicationId                                = $this.ApplicationId
                CertificateThumbprint                        = $this.CertificateThumbprint
                CertificatePath                              = $this.CertificatePath
                CertificatePassword                          = $this.CertificatePassword
                ManagedIdentity                              = $this.ManagedIdentity
                TenantId                                     = $this.TenantId
                AccessTokens                                 = $this.AccessTokens
            }

            foreach ($name in $this.GetSchemaPropertyNames())
            {
                if ($result.ContainsKey($name) -and
                    $this.GetSchemaPropertyType($name) -eq [System.String[]] -and
                    $null -eq $TransportRule.$name)
                {
                    $result.$name = @()
                }
            }

            # Formats DateTime as String
            if ($null -ne $TransportRule.ActivationDate)
            {
                $result.ActivationDate = [M365DSCResourceBase]::FormatDateTime($TransportRule.ActivationDate)
            }
            if ($null -ne $TransportRule.ExpiryDate)
            {
                $result.ExpiryDate = [M365DSCResourceBase]::FormatDateTime($TransportRule.ExpiryDate)
            }

            foreach ($sizeProperty in [EXOTransportRule]::GetSizePropertyNames())
            {
                $result.$sizeProperty = [EXOTransportRule]::ConvertToSizeString($result.$sizeProperty)
            }

            Write-Verbose -Message "Found Transport Rule $($this.Name)"
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

        Write-Verbose -Message "Setting Transport Rule configuration for $($this.Name)"

        $currentTransportRuleConfig = $this.Get().ToHashtable()

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $newTransportRuleParams = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()
        $newTransportRuleParams.Remove('MakeDefault') | Out-Null

        $SetTransportRuleParams = $newTransportRuleParams.Clone()
        $SetTransportRuleParams.Add('Identity', $this.Name)

        # CASE: Transport Rule doesn't exist but should;
        if ($this.Ensure -eq 'Present' -and $currentTransportRuleConfig.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Transport Rule '$($this.Name)' does not exist but it should. Create and configure it."

            $nullKeysToRemove = @()
            foreach ($key in $newTransportRuleParams.Keys)
            {
                if ($newTransportRuleParams.$key.GetType().Name -eq 'String[]' -and $newTransportRuleParams.$key.Length -eq 0)
                {
                    $nullKeysToRemove += $key
                }
            }
            foreach ($paramToRemove in $nullKeysToRemove)
            {
                $newTransportRuleParams.Remove($paramToRemove) | Out-Null
            }

            # Create Transport Rule
            New-TransportRule @NewTransportRuleParams

        }
        # CASE: Transport Rule exists but it shouldn't;
        elseif ($this.Ensure -eq 'Absent' -and $currentTransportRuleConfig.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Transport Rule '$($this.Name)' exists but it shouldn't. Remove it."
            Remove-TransportRule -Identity $this.Name -Confirm:$false
        }
        # CASE: Transport Rule exists and it should, but has different values than the desired ones
        elseif ($this.Ensure -eq 'Present' -and $currentTransportRuleConfig.Ensure -eq 'Present')
        {
            if ($null -ne $this.HeaderContainsMessageHeader -and $null -eq $currentTransportRuleConfig.HeaderContainsMessageHeader)
            {
                if (-not $SetTransportRuleParams.ContainsKey('HeaderContainsMessageHeader'))
                {
                    $SetTransportRuleParams.Add('HeaderContainsMessageHeader', $null)
                }
                else
                {
                    $SetTransportRuleParams.HeaderContainsMessageHeader = $null
                }

                if (-not $SetTransportRuleParams.ContainsKey('HeaderContainsWords'))
                {
                    $SetTransportRuleParams.Add('HeaderContainsWords', @())
                }
                else
                {
                    $SetTransportRuleParams.HeaderContainsWords = @()
                }
            }
            elseif ([System.String]::IsNullOrEmpty($this.HeaderContainsMessageHeader))
            {
                $SetTransportRuleParams.HeaderContainsMessageHeader = $null
            }

            if ($null -eq $this.HeaderMatchesPatterns -and $null -eq $currentTransportRuleConfig.HeaderMatchesMessageHeader)
            {

                if (-not $SetTransportRuleParams.ContainsKey('HeaderMatchesMessageHeader'))
                {
                    $SetTransportRuleParams.Add('HeaderMatchesMessageHeader', $null)
                }
                else
                {
                    $SetTransportRuleParams.HeaderMatchesMessageHeader = $null
                }

                if (-not $SetTransportRuleParams.ContainsKey('HeaderMatchesPatterns'))
                {
                    $SetTransportRuleParams.Add('HeaderMatchesPatterns', @())
                }
                else
                {
                    $SetTransportRuleParams.HeaderMatchesPatterns = @()
                }
            }
            if ($null -eq $this.ExceptIfHeaderContainsWords -and $null -eq $currentTransportRuleConfig.ExceptIfHeaderContainsMessageHeader)
            {
                if (-not $SetTransportRuleParams.ContainsKey('ExceptIfHeaderContainsMessageHeader'))
                {
                    $SetTransportRuleParams.Add('ExceptIfHeaderContainsMessageHeader', $null)
                }
                else
                {
                    $SetTransportRuleParams.ExceptIfHeaderContainsMessageHeader = $null
                }

                if (-not $SetTransportRuleParams.ContainsKey('ExceptIfHeaderContainsWords'))
                {
                    $SetTransportRuleParams.Add('ExceptIfHeaderContainsWords', @())
                }
                else
                {
                    $SetTransportRuleParams.ExceptIfHeaderContainsWords = @()
                }
            }
            if ($null -eq $this.ExceptIfHeaderMatchesPatterns -and $null -eq $currentTransportRuleConfig.ExceptIfHeaderMatchesMessageHeader)
            {
                if (-not $SetTransportRuleParams.ContainsKey('ExceptIfHeaderMatchesMessageHeader'))
                {
                    $SetTransportRuleParams.Add('ExceptIfHeaderMatchesMessageHeader', $null)
                }
                else
                {
                    $SetTransportRuleParams.ExceptIfHeaderMatchesMessageHeader = $null
                }

                if (-not $SetTransportRuleParams.ContainsKey('ExceptIfHeaderMatchesPatterns'))
                {
                    $SetTransportRuleParams.Add('ExceptIfHeaderMatchesPatterns', @())
                }
                else
                {
                    $SetTransportRuleParams.ExceptIfHeaderMatchesPatterns = @()
                }
            }

            if ($SetTransportRuleParams.ContainsKey('Enabled'))
            {
                if ($this.Enabled)
                {
                    Write-Verbose -Message "Enabling TransportRule {$($this.Name)}"
                    Enable-TransportRule -Identity $this.Name -Confirm:$false
                }
                else
                {
                    Write-Verbose -Message "Disabling TransportRule {$($this.Name)}"
                    Disable-TransportRule -Identity $this.Name -Confirm:$false
                }
            }
            $SetTransportRuleParams.Remove('Enabled') | Out-Null
            Write-Verbose -Message "Transport Rule '$($this.Name)' already exists, but needs updating."
            Write-Verbose -Message "Setting Transport Rule $($this.Name) with values: $(Convert-M365DscHashtableToString -Hashtable $SetTransportRuleParams)"
            Set-TransportRule @SetTransportRuleParams
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
            [array]$AllTransportRules = Get-TransportRule
            $dscContent = [System.Text.StringBuilder]::new()
            $i = 1
            if ($AllTransportRules.Length -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }
            foreach ($TransportRule in $AllTransportRules)
            {
                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }

                Write-M365DSCHost -Message "    |---[$i/$($AllTransportRules.Count)] $($TransportRule.Name)" -DeferWrite
                $Params = @{
                    Name                  = $TransportRule.Name
                    Credential            = $this.Credential
                    ApplicationId         = $this.ApplicationId
                    TenantId              = $this.TenantId
                    CertificateThumbprint = $this.CertificateThumbprint
                    CertificatePassword   = $this.CertificatePassword
                    ManagedIdentity       = $this.ManagedIdentity
                    CertificatePath       = $this.CertificatePath
                    AccessTokens          = $this.AccessTokens
                }
                $this.ExportedInstance = $TransportRule
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
                foreach ($sizeProperty in [EXOTransportRule]::GetSizePropertyNames())
                {
                    foreach ($values in @($DesiredValues, $CurrentValues, $ValuesToCheck))
                    {
                        if ($values.ContainsKey($sizeProperty))
                        {
                            $values[$sizeProperty] = [EXOTransportRule]::ConvertToSizeString($values[$sizeProperty])
                        }
                    }
                }
                return [System.Tuple[Hashtable, Hashtable, Hashtable]]::new($DesiredValues, $CurrentValues, $ValuesToCheck)
            }
        }
    }

    hidden static [System.String[]] GetSizePropertyNames()
    {
        return @('AttachmentSizeOver', 'ExceptIfAttachmentSizeOver', 'MessageSizeOver', 'ExceptIfMessageSizeOver')
    }

    hidden static [System.String] ConvertToSizeString([System.Object] $Value)
    {
        if ($null -eq $Value)
        {
            return $null
        }

        $text = [System.String]$Value
        if ($text -match '^\s*(?<value>\d+(?:\.\d+)?)\s*(?<unit>[KMGT]?B)\b')
        {
            return $Matches.value + $Matches.unit.ToUpperInvariant()
        }

        return $text
    }

    hidden [EXOTransportRule] AsResult([System.Object] $Values)
    {
        if ($Values -is [EXOTransportRule])
        {
            return $Values
        }

        $result = [EXOTransportRule]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
