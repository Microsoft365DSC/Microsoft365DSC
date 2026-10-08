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
        AADEntitlementManagementAccessPackageAssignmentPolicy "AADEntitlementManagementAccessPackageAssignmentPolicy-Example"
        {
            AccessPackageId                   = "Finance Reporting Access";
            AccessPackageNotificationSettings = MSFT_MicrosoftGraphaccessPackageNotificationSettings{
                IsAssignmentNotificationDisabled = $False
            };
            AccessReviewSettings              = MSFT_MicrosoftGraphassignmentreviewsettings{
                IsEnabled                       = $True
                StartDateTime                   = '2030-01-01T00:00:00.0000000Z'
                IsAccessRecommendationEnabled   = $True
                AccessReviewTimeoutBehavior     = 'keepAccess'
                IsApprovalJustificationRequired = $True
                ReviewerType                    = 'Self'
                RecurrenceType                  = 'quarterly'
                Reviewers                       = @()
                DurationInDays                  = 25
            };
            CanExtend                         = $False;
            Description                       = "Assignment Policy for access packages";
            DisplayName                       = "External tenant";
            DurationInDays                    = 180; # Updated Property
            Questions                         = @(
                MSFT_MicrosoftGraphaccesspackagequestion{
                    odataType            = "#microsoft.graph.accessPackageTextInputQuestion"
                    IsRequired           = $true
                    IsAnswerEditable     = $true
                    IsSingleLineQuestion = $true
                    SequencePosition     = 1
                    QuestionText         = MSFT_MicrosoftGraphaccessPackageLocalizedContent{
                        DefaultText    = "Which project requires this access?"
                        LocalizedTexts = @(
                            MSFT_MicrosoftGraphaccessPackageLocalizedText{
                                Text         = "Which project requires this access?"
                                LanguageCode = "en-GB"
                            }
                        )
                    }
                }
            );
            RequestorSettings                 = MSFT_MicrosoftGraphrequestorsettings{
                AcceptRequests = $false
                ScopeType      = "NoSubjects"
            };
            RequestApprovalSettings           = MSFT_MicrosoftGraphapprovalsettings{
                ApprovalMode                     = 'NoApproval'
                IsRequestorJustificationRequired = $False
                IsApprovalRequired               = $False
                IsApprovalRequiredForExtension   = $False
            };
            Ensure                            = "Present"
            ApplicationId                     = $ApplicationId
            TenantId                          = $TenantId
            CertificateThumbprint             = $CertificateThumbprint
        }
    }
}
