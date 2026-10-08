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

        AADAccessReviewDefinition "AADAccessReviewDefinition-Example"
        {
            AdditionalNotificationRecipients = @(
                MSFT_AADAccessReviewDefinitionReviewer{
                    DisplayName = "Alex Wilber"
                    Type        = "User"
                }
            );
            DescriptionForAdmins             = "";
            DescriptionForReviewers          = "";
            DisplayName                      = "Review guest access across Microsoft 365 groups";
            Ensure                           = "Present";
            FallbackReviewers                = @(
                MSFT_AADAccessReviewDefinitionReviewer{
                    DisplayName = "Adele Vance"
                    Type        = "User"
                }
            );
            InstanceEnumerationScope         = MSFT_MicrosoftGraphAccessReviewScope2{
                Query     = "/groups?`$filter=(groupTypes/any(c:c+eq+'Unified'))&`$count=true"
                QueryType = "MicrosoftGraph"
            };
            Reviewers                        = @(
                MSFT_AADAccessReviewDefinitionReviewer{
                    Type = "Owner"
                }
            );
            ScopeValue                       = MSFT_MicrosoftGraphaccessReviewScope{
                Query     = "./members/microsoft.graph.user/?`$count=true&`$filter=(userType eq 'Guest')"
                QueryType = "MicrosoftGraph"
                odataType = "#microsoft.graph.accessReviewQueryScope"
            };
            Settings                         = MSFT_MicrosoftGraphaccessReviewScheduleSettings{
                ApplyActions                         = @(
                    MSFT_MicrosoftGraphAccessReviewApplyAction{
                        odataType = "#microsoft.graph.removeAccessApplyAction"
                    }
                )
                AutoApplyDecisionsEnabled            = $True
                DecisionHistoriesForReviewersEnabled = $False
                DefaultDecision                      = "None"
                DefaultDecisionEnabled               = $False
                InstanceDurationInDays               = 3
                JustificationRequiredOnApproval      = $True
                MailNotificationsEnabled             = $True
                RecommendationInsightSettings        = @(
                    MSFT_MicrosoftGraphAccessReviewRecommendationInsightSetting{
                        RecommendationLookBackDuration = "P30D"
                        SignInScope                    = "tenant"
                        odataType                      = "#microsoft.graph.userLastSignInRecommendationInsightSetting"
                    }
                )
                RecommendationLookBackDuration       = "30.00:00:00"
                RecommendationsEnabled               = $True
                Recurrence                           = MSFT_MicrosoftGraphPatternedRecurrence{
                    Pattern = MSFT_MicrosoftGraphRecurrencePattern{
                        DayOfMonth     = 0
                        FirstDayOfWeek = "sunday"
                        Index          = "first"
                        Interval       = 1
                        Month          = 0
                        Type           = "absoluteMonthly"
                    }
                    Range   = MSFT_MicrosoftGraphRecurrenceRange{
                        EndDate             = "12/31/9999 12:00:00 AM"
                        NumberOfOccurrences = 0
                        StartDate           = "9/30/2025 12:00:00 AM"
                        Type                = "noEnd"
                    }
                }
                ReminderNotificationsEnabled         = $True
            }
            ApplicationId                    = $ApplicationId
            TenantId                         = $TenantId
            CertificateThumbprint            = $CertificateThumbprint
        }
    }
}
