<#
This example is used to test new resources and showcase the usage of new resources being worked on.
It is not meant to use as a production baseline.
#>

configuration Example
{
    param
    (
        [Parameter()]
        [System.String]
        $ApplicationId,

        [Parameter()]
        [System.String]
        $TenantId,

        [Parameter()]
        [System.String]
        $CertificateThumbprint
    )

    Import-DscResource -ModuleName Microsoft365DSC

    Node localhost
    {
        EXOTransportRule 'EXOTransportRule-Example'
        {
            Name                                         = "Ethical Wall - Sales and Executives Departments"
            ADComparisonAttribute                        = "Department"
            ADComparisonOperator                         = "NotEqual"
            ActivationDate                               = "2030-01-01T00:00:00.0000000Z"
            AddManagerAsRecipientType                    = "Cc"
            AddToRecipients                              = @("AlexW@$TenantId")
            AnyOfCcHeader                                = @("AlexW@$TenantId")
            AnyOfCcHeaderMemberOf                        = @("Executives@$TenantId")
            AnyOfRecipientAddressContainsWords           = @("sales", "executive")
            AnyOfRecipientAddressMatchesPatterns         = @("^exec")
            AnyOfToCcHeader                              = @("Executives@$TenantId")
            AnyOfToCcHeaderMemberOf                      = @("Executives@$TenantId")
            AnyOfToHeader                                = @("Executives@$TenantId")
            AnyOfToHeaderMemberOf                        = @("Executives@$TenantId")
            ApplyHtmlDisclaimerFallbackAction            = "Ignore"
            ApplyHtmlDisclaimerLocation                  = "Append"
            ApplyHtmlDisclaimerText                      = "<p>This message crossed the information barrier between the Sales and the Executives departments and has been recorded for compliance review.</p>"
            AttachmentContainsWords                      = @("Confidential", "Deal Sheet")
            AttachmentExtensionMatchesWords              = @("docx", "xlsx", "pptx")
            AttachmentHasExecutableContent               = $false
            AttachmentIsPasswordProtected                = $false
            AttachmentIsUnsupported                      = $false
            AttachmentMatchesPatterns                    = @("Project Aurora")
            AttachmentNameMatchesPatterns                = @("Board-", "Deal-")
            AttachmentProcessingLimitExceeded            = $false
            AttachmentPropertyContainsWords              = @("Classification:Confidential")
            AttachmentSizeOver                           = "2MB"
            BetweenMemberOf1                             = @("SalesandMarketing@$TenantId")
            BetweenMemberOf2                             = @("Executives@$TenantId")
            BlindCopyTo                                  = @("MeganB@$TenantId")
            Comments                                     = "Records mail crossing the information barrier between the Sales and the Executives departments while the barrier is being piloted."
            ContentCharacterSetContainsWords             = @("iso-8859-1", "windows-1252")
            CopyTo                                       = @("AdeleV@$TenantId")
            Enabled                                      = $false # Updated Property
            ExceptIfAttachmentExtensionMatchesWords      = @("txt", "csv")
            ExceptIfFrom                                 = @("AdeleV@$TenantId")
            ExceptIfFromMemberOf                         = @("Retail@$TenantId")
            ExceptIfHeaderContainsMessageHeader          = "X-Legal-Review"
            ExceptIfHeaderContainsWords                  = @("Approved", "Cleared")
            ExceptIfManagerAddresses                     = @("AlexW@$TenantId")
            ExceptIfManagerForEvaluatedUser              = "Recipient"
            ExceptIfMessageTypeMatches                   = "AutoForward"
            ExceptIfMessageSizeOver                      = "25MB"
            ExceptIfRecipientDomainIs                    = @("fabrikam.com")
            ExceptIfSenderDomainIs                       = @("fabrikam.com")
            ExceptIfSenderIpRanges                       = @("192.168.20.0/24")
            ExceptIfSentTo                               = @("AlexW@$TenantId")
            ExceptIfSentToMemberOf                       = @("Retail@$TenantId")
            ExceptIfSubjectContainsWords                 = @("Press Release", "Corporate Communication")
            ExceptIfWithImportance                       = "Low"
            ExpiryDate                                   = "2031-01-01T00:00:00.0000000Z"
            From                                         = @("AlexW@$TenantId")
            FromAddressContainsWords                     = @("sales")
            FromAddressMatchesPatterns                   = @("^sales")
            FromMemberOf                                 = @("SalesandMarketing@$TenantId")
            FromScope                                    = "InOrganization"
            GenerateIncidentReport                       = "MeganB@$TenantId"
            GenerateNotification                         = "<p>Your message crossed the information barrier between the Sales and the Executives departments and has been recorded for compliance review.</p>"
            HasNoClassification                          = $false
            HeaderContainsMessageHeader                  = "X-Message-Classification"
            HeaderContainsWords                          = @("Confidential", "Restricted")
            HeaderMatchesMessageHeader                   = "X-Project-Code"
            HeaderMatchesPatterns                        = @("Aurora", "Northwind")
            IncidentReportContent                        = @("Sender", "Recipients", "Subject", "Cc", "Severity")
            ManagerAddresses                             = @("AdeleV@$TenantId")
            ManagerForEvaluatedUser                      = "Sender"
            MessageSizeOver                              = "10MB"
            MessageTypeMatches                           = "Encrypted"
            Mode                                         = "Audit"
            PrependSubject                               = "[Ethical Wall]"
            Priority                                     = 0
            RecipientADAttributeContainsWords            = @("Department:Executives")
            RecipientADAttributeMatchesPatterns          = @("Title:^Chief")
            RecipientAddressContainsWords                = @("exec")
            RecipientAddressMatchesPatterns              = @("^exec")
            RecipientAddressType                         = "Resolved"
            RecipientDomainIs                            = @("$TenantId")
            RemoveHeader                                 = "X-Information-Barrier-Reviewed"
            RouteMessageOutboundRequireTls               = $true
            RuleErrorAction                              = "Ignore"
            RuleSubType                                  = "None"
            SCLOver                                      = "5"
            SenderADAttributeContainsWords               = @("Department:Sales")
            SenderADAttributeMatchesPatterns             = @("Title:^Account")
            SenderAddressLocation                        = "HeaderOrEnvelope"
            SenderDomainIs                               = @("$TenantId")
            SenderIpRanges                               = @("192.168.10.0/24")
            SenderManagementRelationship                 = "Manager"
            SentTo                                       = @("AdeleV@$TenantId")
            SentToMemberOf                               = @("Executives@$TenantId")
            SentToScope                                  = "InOrganization"
            SetAuditSeverity                             = "Medium"
            SetHeaderName                                = "X-Information-Barrier"
            SetHeaderValue                               = "Sales-Executives"
            SetSCL                                       = "0"
            StopRuleProcessing                           = $false
            SubjectContainsWords                         = @("Confidential", "Board Deck")
            SubjectMatchesPatterns                       = @("Project Aurora")
            SubjectOrBodyContainsWords                   = @("Deal Sheet", "Term Sheet")
            SubjectOrBodyMatchesPatterns                 = @("Project (Aurora|Northwind)")
            WithImportance                               = "High"
            Ensure                                       = 'Present'
            ApplicationId                                = $ApplicationId
            TenantId                                     = $TenantId
            CertificateThumbprint                        = $CertificateThumbprint
        }
    }
}
