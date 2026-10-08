<#
This example adds a new Teams Channels Policy.
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
        TeamsChannelsPolicy 'TeamsChannelsPolicy-Example'
        {
            Identity                                      = 'New Channels Policy'
            Description                                   = 'Enables private and shared channels for project teams'
            AllowChannelSharingToExternalUser             = $True
            AllowOrgWideTeamCreation                      = $True
            EnablePrivateTeamDiscovery                    = $True
            AllowPrivateChannelCreation                   = $True
            AllowSharedChannelCreation                    = $True
            AllowUserToParticipateInExternalSharedChannel = $True
            AllowCreateChannel                            = "Enabled"
            AllowCreateClassicChannel                     = "Enabled"
            AllowCreatePrivateChannel                     = "Enabled"
            AllowCreateSharedChannel                      = "Enabled"
            CreateSharedChannelsByDefault                 = "Disabled"
            AllowUsersFromOutsideTeam                     = "Enabled"
            AllowGuestsFromOutsideTeam                    = "Disabled"
            AllowUsersFromOutsideTeamInPrivateChannel     = "Enabled"
            AllowGuestsFromOutsideTeamInPrivateChannel    = "Disabled"
            AllowSharingWithTeamInOrg                     = "Enabled"
            AllowSharingPrivateChannelWithTeamInOrg       = "Enabled"
            DefaultChannelTypeOnCreation                  = "Standard"
            Ensure                                        = 'Present'
            ApplicationId                                 = $ApplicationId
            TenantId                                      = $TenantId
            CertificateThumbprint                         = $CertificateThumbprint
        }
    }
}
