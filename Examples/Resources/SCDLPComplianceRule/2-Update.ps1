<#
This example is used to test new resources and showcase the usage of new resources being worked on.
It is not meant to use as a production baseline.
#>

Configuration Example
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
        SCDLPComplianceRule 'SCDLPComplianceRule-Example'
        {
            Name                                         = "Low volume EU Sensitive content found"
            Policy                                       = "Customer Financial Data Protection"
            AccessScope                                  = "InOrganization"
            BlockAccess                                  = $true
            BlockAccessScope                             = "All"
            AnyOfRecipientAddressContainsWords           = @("external")
            AnyOfRecipientAddressMatchesPatterns         = @("@fabrikam[.]com")
            Comment                                      = "Applies to payment card data shared outside the finance and payroll departments" # Updated Property
            ContentCharacterSetContainsWords             = @("utf-8")
            ContentContainsSensitiveInformation          = MSFT_SCDLPContainsSensitiveInformation{
                SensitiveInformation = @(
                    MSFT_SCDLPSensitiveInformation{
                        name           = "EU Debit Card Number"
                        id             = "0e9b3178-9678-47dd-a509-37222ca96b42"
                        maxconfidence  = "100"
                        minconfidence  = "75"
                        classifiertype = "Content"
                        mincount       = "1"
                        maxcount       = "9"
                    }
                )
            }
            ContentExtensionMatchesWords                 = @("csv", "xlsx")
            ContentIsNotLabeled                          = $false
            ContentPropertyContainsWords                 = @("Department:Finance")
            Disabled                                     = $false
            DocumentContainsWords                        = @("primary account number")
            DocumentIsPasswordProtected                  = $false
            DocumentIsUnsupported                        = $false
            DocumentNameMatchesPatterns                  = @("statement-[0-9]{4}")
            DocumentNameMatchesWords                     = @("cardholder")
            ExceptIfAnyOfRecipientAddressContainsWords   = @("archive")
            ExceptIfAnyOfRecipientAddressMatchesPatterns = @("@contoso[.]com")
            ExceptIfContentCharacterSetContainsWords     = @("iso-8859-1")
            ExceptIfContentContainsSensitiveInformation  = MSFT_SCDLPContainsSensitiveInformation{
                SensitiveInformation = @(
                    MSFT_SCDLPSensitiveInformation{
                        name           = "Credit Card Number"
                        maxconfidence  = "100"
                        minconfidence  = "85"
                        classifiertype = "Content"
                        mincount       = "1"
                        maxcount       = "9"
                    }
                )
            }
            ExceptIfContentExtensionMatchesWords         = @("pdf")
            ExceptIfContentPropertyContainsWords         = @("Department:Marketing")
            ExceptIfDocumentIsPasswordProtected          = $false
            ExceptIfDocumentIsUnsupported                = $false
            ExceptIfDocumentNameMatchesPatterns          = @("^draft-")
            ExceptIfDocumentNameMatchesWords             = @("template")
            ExceptIfFromAddressContainsWords             = @("noreply")
            ExceptIfFromAddressMatchesPatterns           = @("^alerts@")
            ExceptIfFromScope                            = @("NotInOrganization")
            ExceptIfHasSenderOverride                    = $false
            ExceptIfMessageTypeMatches                   = @("Calendaring")
            ExceptIfProcessingLimitExceeded              = $false
            ExceptIfRecipientDomainIs                    = @("partner.fabrikam.com")
            ExceptIfSenderDomainIs                       = @("supplier.fabrikam.com")
            ExceptIfSenderIPRanges                       = @("192.168.10.0/24")
            ExceptIfSentTo                               = @("AlexW@$TenantId")
            ExceptIfSubjectContainsWords                 = @("approved exception")
            ExceptIfSubjectMatchesPatterns               = @("^RE:")
            ExceptIfSubjectOrBodyContainsWords           = @("public price list")
            ExceptIfSubjectOrBodyMatchesPatterns         = @("^Newsletter")
            FromAddressContainsWords                     = @("finance")
            FromAddressMatchesPatterns                   = @("^payroll@")
            FromScope                                    = @("InOrganization")
            GenerateAlert                                = @("AdeleV@$TenantId")
            GenerateIncidentReport                       = @("SiteAdmin")
            HasSenderOverride                            = $false
            IncidentReportContent                        = @("DocumentLastModifier", "Detections", "Severity", "DetectionDetails", "OriginalContent")
            MessageTypeMatches                           = @("Signed")
            NotifyAllowOverride                          = @("WithJustification")
            NotifyEmailCustomText                        = "This message contains payment card data. Remove the card numbers or ask the compliance team to record an exception."
            NotifyPolicyTipCustomText                    = "This content contains payment card data and cannot be shared outside the finance department."
            NotifyUser                                   = @("LastModifier")
            ProcessingLimitExceeded                      = $false
            Quarantine                                   = $false
            RecipientDomainIs                            = @("fabrikam.com")
            RemoveRMSTemplate                            = $false
            ReportSeverityLevel                          = "Low"
            RuleErrorAction                              = "Ignore"
            SentToMemberOf                               = @("SalesandMarketing@$TenantId")
            StopPolicyProcessing                         = $false
            SubjectContainsWords                         = @("cardholder data")
            SubjectMatchesPatterns                       = @("card number [0-9]{4}")
            SubjectOrBodyContainsWords                   = @("credit card")
            SubjectOrBodyMatchesPatterns                 = @("account number [0-9]+")
            Ensure                                       = "Present"
            ApplicationId                                = $ApplicationId
            TenantId                                     = $TenantId
            CertificateThumbprint                        = $CertificateThumbprint
        }
    }
}
