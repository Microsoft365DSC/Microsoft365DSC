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
        AADIdentityGovernanceLifecycleWorkflowCustomTaskExtension "AADIdentityGovernanceLifecycleWorkflowCustomTaskExtension-Example"
        {
            CallbackConfiguration = MSFT_AADIdentityGovernanceLifecycleWorkflowCustomTaskExtensionCallbackConfiguration{
                TimeoutDuration = 'PT34M'
                AuthorizedApps  = @('Lifecycle Workflow Connector')
            };
            ClientConfiguration   = MSFT_AADIdentityGovernanceLifecycleWorkflowCustomTaskExtensionClientConfiguration{
                MaximumRetries        = 1
                TimeoutInMilliseconds = 1000
            };
            Description           = "My Description";
            DisplayName           = "My Custom Extension";
            EndpointConfiguration = MSFT_AADIdentityGovernanceLifecycleWorkflowCustomTaskExtensionEndpointConfiguration{
                SubscriptionId       = '<subscription-id>'
                logicAppWorkflowName = 'OnboardingNotification'
                resourceGroupName    =    'rg-identity-prod'
                url                  = 'https://prod-35.eastus.logic.azure.com:443/workflows/xxxxxxxxxxx/triggers/manual/paths/invoke?api-version=2016-10-01'
            };
            Ensure                = "Present";
            ApplicationId         = $ApplicationId;
            TenantId              = $TenantId;
            CertificateThumbprint = $CertificateThumbprint;
        }
    }
}
