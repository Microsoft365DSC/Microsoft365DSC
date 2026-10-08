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
        AADLifecycleWorkflowSettings "AADLifecycleWorkflowSettings-Example"
        {
            IsSingleInstance                = "Yes";
            QuarantineConfiguration         = MSFT_MicrosoftGraphquarantineConfiguration{
                MatchMode  = "any"
                Conditions = @(
                    MSFT_MicrosoftGraphquarantineCondition{
                        odataType = "#microsoft.graph.identityGovernance.countBasedQuarantineCondition"
                        Threshold = 500
                    }
                    MSFT_MicrosoftGraphquarantineCondition{
                        odataType  = "#microsoft.graph.identityGovernance.percentageBasedQuarantineCondition"
                        Percentage = 25
                    }
                )
            };
            SenderDomain                    = "microsoft.com";
            UseCompanyBranding              = $True;
            WorkflowScheduleIntervalInHours = 10;
            ApplicationId                   = $ApplicationId;
            TenantId                        = $TenantId;
            CertificateThumbprint           = $CertificateThumbprint;
        }
    }
}
