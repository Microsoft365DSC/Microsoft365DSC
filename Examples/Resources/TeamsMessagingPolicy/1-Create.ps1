<#
This example adds a new Teams Messaging Policy.
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
        TeamsMessagingPolicy 'TeamsMessagingPolicy-Example'
        {
            Identity                                      = "CorporateMessaging"
            Description                                   = "Messaging defaults for corporate staff"
            ReadReceiptsEnabledType                       = "UserPreference"
            AllowImmersiveReader                          = $true
            AllowGiphy                                    = $true
            AllowStickers                                 = $true
            AllowUrlPreviews                              = $false
            AllowUserChat                                 = $true
            AllowUserDeleteMessage                        = $false
            AllowUserEditMessage                          = $false
            AllowUserTranslation                          = $true
            AllowRemoveUser                               = $false
            AllowPriorityMessages                         = $true
            GiphyRatingType                               = "MODERATE"
            AllowMemes                                    = $false
            AudioMessageEnabledType                       = "ChatsOnly"
            AllowOwnerDeleteMessage                       = $false
            AllowChatWithGroup                            = $true
            AllowCommunicationComplianceEndUserReporting  = $true
            AllowCustomGroupChatAvatars                   = $true
            AllowFluidCollaborate                         = $true
            AllowFullChatPermissionUserToDeleteAnyMessage = $false
            AllowGiphyDisplay                             = $true
            AllowGroupChatJoinLinks                       = $true
            AllowPasteInternetImage                       = $true
            AllowSecurityEndUserReporting                 = $true
            AllowSmartCompose                             = $true
            AllowSmartReply                               = $true
            AllowUserDeleteChat                           = $false
            AllowVideoMessages                            = $true
            AutoShareFilesInExternalChats                 = "Enabled"
            ChannelsInChatListEnabledType                 = "EnabledUserOverride"
            ChatPermissionRole                            = "Full"
            CreateCustomEmojis                            = $true
            DeleteCustomEmojis                            = $false
            DesignerForBackgroundsAndImages               = "Enabled"
            InOrganizationChatControl                     = "BlockingDisallowed"
            UseB2BInvitesToAddExternalUsers               = "Disabled"
            UsersCanDeleteBotMessages                     = $false
            Ensure                                        = "Present"
            ApplicationId                                 = $ApplicationId
            TenantId                                      = $TenantId
            CertificateThumbprint                         = $CertificateThumbprint
        }
    }
}
