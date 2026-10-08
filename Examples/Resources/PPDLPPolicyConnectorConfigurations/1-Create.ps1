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
        PPDLPPolicyConnectorConfigurations "PPDLPPolicyConnectorConfigurations-Example"
        {
            ConnectorActionConfigurations = @(
                MSFT_PPDLPPolicyConnectorConfigurationsAction{
                    actionRules                        = @(
                        MSFT_PPDLPPolicyConnectorConfigurationsActionRules{
                            actionId = 'CreateInvitation'
                            behavior = 'Allow'
                        }
                    )
                    connectorId                        = '/providers/Microsoft.PowerApps/apis/shared_aadinvitationmanager'
                    defaultConnectorActionRuleBehavior = 'Allow'
                }
            );
            Ensure                        = "Present";
            PolicyName                    = "Contoso Data Policy";
            PPTenantId                    = "e91d4e0e-d5a5-4e3a-be14-2192592a59af";
            ApplicationId                 = $ApplicationId;
            TenantId                      = $TenantId;
            CertificateThumbprint         = $CertificateThumbprint;
        }
    }
}
