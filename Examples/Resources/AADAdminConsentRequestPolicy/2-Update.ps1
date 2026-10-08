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
        AADAdminConsentRequestPolicy "AADAdminConsentRequestPolicy-Example"
        {
            IsEnabled             = $True;
            IsSingleInstance      = "Yes";
            NotifyReviewers       = $False;
            RemindersEnabled      = $True;
            RequestDurationInDays = 30;
            Reviewers             =                 @(
                MSFT_AADAdminConsentRequestPolicyReviewer {
                     ReviewerType = 'User'
                     ReviewerId   = "AlexW@$TenantId"
                }
                MSFT_AADAdminConsentRequestPolicyReviewer {
                     ReviewerType = 'Group'
                     ReviewerId   = 'Communications'
                }
                MSFT_AADAdminConsentRequestPolicyReviewer {
                     ReviewerType = 'Role'
                     ReviewerId   = 'Attack Payload Author'
                }
                MSFT_AADAdminConsentRequestPolicyReviewer {
                     ReviewerType = 'Role'
                     ReviewerId   = 'Attack Simulation Administrator'
                }
                );
            ApplicationId         = $ApplicationId;
            TenantId              = $TenantId;
            CertificateThumbprint = $CertificateThumbprint;
        }
    }
}
