<#
This examples sets the Teams Federation Configuration.
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
        TeamsFederationConfiguration 'TeamsFederationConfiguration-Example'
        {
            IsSingleInstance                                    = 'Yes';
            AllowedDomains                                      = @();
            AllowedTrialTenantDomains                           = @("northwindtraders.onmicrosoft.com");
            BlockedDomains                                      = @();
            BlockAllSubdomains                                  = $false;
            AllowFederatedUsers                                 = $true;
            AllowTeamsConsumer                                  = $true;
            AllowTeamsConsumerInbound                           = $true;
            EnableExternalAccessRestrictionsForChatParticipants = $false;
            EnableMutualFederationForChatParticipants           = $false;
            ExternalAccessWithTrialTenants                      = "Blocked";
            RestrictTeamsConsumerToExternalUserProfiles         = $false;
            SecurityTeamAllowBlockListDelegation                = "Enabled";
            SharedSipAddressSpace                               = $false;
            TreatDiscoveredPartnersAsUnverified                 = $false;
            ApplicationId                                       = $ApplicationId
            TenantId                                            = $TenantId
            CertificateThumbprint                               = $CertificateThumbprint
        }
    }
}
