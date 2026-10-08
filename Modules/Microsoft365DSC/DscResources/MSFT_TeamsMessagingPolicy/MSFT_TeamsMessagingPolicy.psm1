using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class TeamsMessagingPolicy : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('Identity for the teams messaging policy you''re modifying. To modify the global policy, use this syntax: -Identity global. To modify a per-user policy, use syntax similar to this: -Identity TeamsMessagingPolicy.')]
    [System.String] $Identity

    [DscProperty()]
    [System.ComponentModel.Description('This setting determines if users can chat with groups (Distribution, M365 and Security groups). Possible values: True, False')]
    [System.Nullable[System.Boolean]] $AllowChatWithGroup

    [DscProperty()]
    [System.ComponentModel.Description('These settings enables, disables updating or fetching custom group chat avatars for the users included in the messaging policy. Possible values: True, False')]
    [System.Nullable[System.Boolean]] $AllowCustomGroupChatAvatars

    [DscProperty()]
    [System.ComponentModel.Description('This setting determines if users with the ''Full permissions'' role can delete any group or meeting chat message within their tenant. Possible values: True, False')]
    [System.Nullable[System.Boolean]] $AllowFullChatPermissionUserToDeleteAnyMessage

    [DscProperty()]
    [System.ComponentModel.Description('Determines if Giphy images should be displayed that had been already sent or received in chat. Possible values: True, False')]
    [System.Nullable[System.Boolean]] $AllowGiphyDisplay

    [DscProperty()]
    [System.ComponentModel.Description('This setting determines if users in a group chat can create and share join links for other users within the organization to join that chat. Possible values: True, False')]
    [System.Nullable[System.Boolean]] $AllowGroupChatJoinLinks

    [DscProperty()]
    [System.ComponentModel.Description('Determines if a user is allowed to paste internet-based images in compose. Possible values: True, False')]
    [System.Nullable[System.Boolean]] $AllowPasteInternetImage

    [DscProperty()]
    [System.ComponentModel.Description('Determines whether files are automatically shared in external chats. Possible values: Enabled: Files are automatically shared in external chats. Disabled: Files are not automatically shared in external chats.')]
    [ValidateSet('Enabled', 'Disabled')]
    [System.String] $AutoShareFilesInExternalChats

    [DscProperty()]
    [System.ComponentModel.Description('Determines the Supervised Chat role of the user. Set this to Full to allow the user to supervise chats. Supervisors have the ability to initiate chats with and invite any user within the environment. Set this to Limited to allow the user to initiate conversations with Full and Limited permissioned users, but not Restricted. Set this to Restricted to block chat creation with anyone other than Full permissioned users.')]
    [ValidateSet('Full', 'Limited', 'Restricted')]
    [System.String] $ChatPermissionRole

    [DscProperty()]
    [System.ComponentModel.Description('This setting enables the creation of custom emojis and reactions within an organization for the specified policy users.')]
    [System.Nullable[System.Boolean]] $CreateCustomEmojis

    [DscProperty()]
    [System.ComponentModel.Description('These settings enable and disable the editing and deletion of custom emojis and reactions for the users included in the messaging policy.')]
    [System.Nullable[System.Boolean]] $DeleteCustomEmojis

    [DscProperty()]
    [System.ComponentModel.Description('This setting determines whether a user is allowed to create custom AI-powered backgrounds and images with MS Designer.Possible values are: Enabled, Disabled')]
    [ValidateSet('Enabled', 'Disabled')]
    [System.String] $DesignerForBackgroundsAndImages

    [DscProperty()]
    [System.ComponentModel.Description('This setting determines if chat regulation for internal communication in the tenant is allowed. Possible values: BlockingAllowed, BlockingDisallowed')]
    [ValidateSet('BlockingDisallowed', 'BlockingAllowed')]
    [System.String] $InOrganizationChatControl

    [DscProperty()]
    [System.ComponentModel.Description('Determines whether a user is allowed to delete messages sent by bots. Possible values are: True, False')]
    [System.Nullable[System.Boolean]] $UsersCanDeleteBotMessages

    [DscProperty()]
    [System.ComponentModel.Description('Report inappropriate content.')]
    [System.Nullable[System.Boolean]] $AllowCommunicationComplianceEndUserReporting

    [DscProperty()]
    [System.ComponentModel.Description('Determines is Fluid Collaboration should be enabled or not.')]
    [System.Nullable[System.Boolean]] $AllowFluidCollaborate

    [DscProperty()]
    [System.ComponentModel.Description('Report a security concern.')]
    [System.Nullable[System.Boolean]] $AllowSecurityEndUserReporting

    [DscProperty()]
    [System.ComponentModel.Description('Determines whether a user is allowed to access and post Giphys. Set this to TRUE to allow. Set this FALSE to prohibit.')]
    [System.Nullable[System.Boolean]] $AllowGiphy

    [DscProperty()]
    [System.ComponentModel.Description('Determines whether a user is allowed to access and post memes. Set this to TRUE to allow. Set this FALSE to prohibit.')]
    [System.Nullable[System.Boolean]] $AllowMemes

    [DscProperty()]
    [System.ComponentModel.Description('Determines whether owners are allowed to delete all the messages in their team. Set this to TRUE to allow. Set this to FALSE to prohibit.')]
    [System.Nullable[System.Boolean]] $AllowOwnerDeleteMessage

    [DscProperty()]
    [System.ComponentModel.Description('Determines whether a user is allowed to edit their own messages. Set this to TRUE to allow. Set this to FALSE to prohibit.')]
    [System.Nullable[System.Boolean]] $AllowUserEditMessage

    [DscProperty()]
    [System.ComponentModel.Description('Turn on this setting to let a user get text predictions for chat messages.')]
    [System.Nullable[System.Boolean]] $AllowSmartCompose

    [DscProperty()]
    [System.ComponentModel.Description('Turn this setting on to enable suggested replies for chat messages. Set this to TRUE to allow. Set this to FALSE to prohibit.')]
    [System.Nullable[System.Boolean]] $AllowSmartReply

    [DscProperty()]
    [System.ComponentModel.Description('Determines whether a user is allowed to access and post stickers. Set this to TRUE to allow. Set this FALSE to prohibit.')]
    [System.Nullable[System.Boolean]] $AllowStickers

    [DscProperty()]
    [System.ComponentModel.Description('Use this setting to turn automatic URL previewing on or off in messages. Set this to TRUE to turn on. Set this to FALSE to turn off.')]
    [System.Nullable[System.Boolean]] $AllowUrlPreviews

    [DscProperty()]
    [System.ComponentModel.Description('Determines whether a user is allowed to chat. Set this to TRUE to allow a user to chat across private chat, group chat and in meetings. Set this to FALSE to prohibit all chat.')]
    [System.Nullable[System.Boolean]] $AllowUserChat

    [DscProperty()]
    [System.ComponentModel.Description('Determines whether a user is allowed to delete their own messages. Set this to TRUE to allow. Set this to FALSE to prohibit.')]
    [System.Nullable[System.Boolean]] $AllowUserDeleteMessage

    [DscProperty()]
    [System.ComponentModel.Description('Determines whether a user is allowed to translate messages to their client languages. Set this to TRUE to allow. Set this to FALSE to prohibit.')]
    [System.Nullable[System.Boolean]] $AllowUserTranslation

    [DscProperty()]
    [System.ComponentModel.Description('Determines whether a user is allowed to use Immersive Reader for reading conversation messages. Set this to TRUE to allow. Set this FALSE to prohibit.')]
    [System.Nullable[System.Boolean]] $AllowImmersiveReader

    [DscProperty()]
    [System.ComponentModel.Description('Determines whether a user is allowed to remove a user from a conversation. Set this to TRUE to allow. Set this FALSE to prohibit.')]
    [System.Nullable[System.Boolean]] $AllowRemoveUser

    [DscProperty()]
    [System.ComponentModel.Description('Determines whether a user is allowed to send priorities messages. Set this to TRUE to allow. Set this FALSE to prohibit.')]
    [System.Nullable[System.Boolean]] $AllowPriorityMessages

    [DscProperty()]
    [System.ComponentModel.Description('Turn this setting on to allow users to permanently delete their 1:1, group chat, and meeting chat as participants (this deletes the chat only for them, not other users in the chat).')]
    [System.Nullable[System.Boolean]] $AllowUserDeleteChat

    [DscProperty()]
    [System.ComponentModel.Description('Determines whether a user is allowed to send video messages in Chat. Set this to TRUE to allow a user to send video messages. Set this to FALSE to prohibit sending video messages.')]
    [System.Nullable[System.Boolean]] $AllowVideoMessages

    [DscProperty()]
    [System.ComponentModel.Description('Provide a description of your policy to identify purpose of creating it.')]
    [System.String] $Description

    [DscProperty()]
    [System.ComponentModel.Description('Determines the Giphy content restrictions applicable to a user. Set this to STRICT, MODERATE or NORESTRICTION.')]
    [ValidateSet('STRICT', 'MODERATE', 'NORESTRICTION')]
    [System.String] $GiphyRatingType

    [DscProperty()]
    [System.ComponentModel.Description('Use this setting to specify whether read receipts are user controlled, enabled for everyone, or disabled. Set this to UserPreference, Everyone or None.')]
    [ValidateSet('UserPreference', 'Everyone', 'None')]
    [System.String] $ReadReceiptsEnabledType

    [DscProperty()]
    [System.ComponentModel.Description('Possible values are: DisabledUserOverride,EnabledUserOverride.')]
    [ValidateSet('DisabledUserOverride', 'EnabledUserOverride')]
    [System.String] $ChannelsInChatListEnabledType

    [DscProperty()]
    [System.ComponentModel.Description('Determines whether a user is allowed to send audio messages. Possible values are: ChatsAndChannels,ChatsOnly,Disabled.')]
    [ValidateSet('ChatsAndChannels', 'ChatsOnly', 'Disabled')]
    [System.String] $AudioMessageEnabledType

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether B2B invites should be used to add external users when necessary. Possible values: Enabled: External users will be added using B2B invites. Disabled: External users will not be added using B2B invites.')]
    [ValidateSet('Enabled', 'Disabled')]
    [System.String] $UseB2BInvitesToAddExternalUsers

    [DscProperty()]
    [System.ComponentModel.Description('Globally unique identifier (GUID) of the tenant account whose external user communication policy are being created.')]
    [System.String] $Tenant

    [DscProperty()]
    [System.ComponentModel.Description('Present ensures the Team Message Policy exists, absent ensures it is removed')]
    [ValidateSet('Present', 'Absent')]
    [System.String] $Ensure

    [DscProperty()]
    [System.ComponentModel.Description('Credentials of the Teams Service Admin')]
    [System.Management.Automation.PSCredential] $Credential

    [DscProperty()]
    [System.ComponentModel.Description('Id of the Azure Active Directory application to authenticate with.')]
    [System.String] $ApplicationId

    [DscProperty()]
    [System.ComponentModel.Description('Name of the Azure Active Directory tenant used for authentication. Format contoso.onmicrosoft.com')]
    [System.String] $TenantId

    [DscProperty()]
    [System.ComponentModel.Description('Thumbprint of the Azure Active Directory application''s authentication certificate to use for authentication.')]
    [System.String] $CertificateThumbprint

    [DscProperty()]
    [System.ComponentModel.Description('Username can be made up to anything but password will be used for CertificatePassword')]
    [System.Management.Automation.PSCredential] $CertificatePassword

    [DscProperty()]
    [System.ComponentModel.Description('Path to certificate used in service principal usually a PFX file.')]
    [System.String] $CertificatePath

    [DscProperty()]
    [System.ComponentModel.Description('Managed ID being used for authentication.')]
    [System.Nullable[System.Boolean]] $ManagedIdentity

    [DscProperty()]
    [System.ComponentModel.Description('Access token used for authentication.')]
    [System.String[]] $AccessTokens

    # Export-only. Not part of the resource schema.
    [System.String] $Filter = '*'

    [TeamsMessagingPolicy] Get()
    {
        $nullReturn = $null
        if ($this.RequiresPowerShellCore())
        {
            $remote = [TeamsMessagingPolicy]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message 'Getting configuration of Teams Messaging Policy'

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.Identity -ne $this.Identity)
            {
                $null = $this.Connect('MicrosoftTeams')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullReturn = $this.GetBoundParameters()
                $nullReturn.Ensure = 'Absent'

                $policy = Get-CsTeamsMessagingPolicy -Identity $this.Identity `
                    -ErrorAction SilentlyContinue
            }
            else
            {
                $policy = $this.ExportedInstance
            }

            if ($null -eq $policy)
            {
                return $this.AsResult($nullReturn)
            }
            else
            {
                # Tag: gets prefixed to Identity on Get, need to remove
                $currentPolicy = $policy.Identity
                if ($currentPolicy -like 'Tag:*')
                {
                    $currentPolicy = $currentPolicy.Split(':')[1]
                }

                if ($policy.UseB2BInvitesToAddExternalUsers)
                {
                    $useB2BInvitesToAddExternalUsersValue = 'Enabled'
                }
                else
                {
                    $useB2BInvitesToAddExternalUsersValue = 'Disabled'
                }
                return $this.AsResult(@{
                    Identity                                      = $currentPolicy
                    AllowChatWithGroup                            = $policy.AllowChatWithGroup
                    AllowCustomGroupChatAvatars                   = $policy.AllowCustomGroupChatAvatars
                    AllowFullChatPermissionUserToDeleteAnyMessage = $policy.AllowFullChatPermissionUserToDeleteAnyMessage
                    AllowGiphyDisplay                             = $policy.AllowGiphyDisplay
                    AllowGroupChatJoinLinks                       = $policy.AllowGroupChatJoinLinks
                    AllowPasteInternetImage                       = $policy.AllowPasteInternetImage
                    AutoShareFilesInExternalChats                 = $policy.AutoShareFilesInExternalChats
                    ChatPermissionRole                            = $policy.ChatPermissionRole
                    CreateCustomEmojis                            = $policy.CreateCustomEmojis
                    DeleteCustomEmojis                            = $policy.DeleteCustomEmojis
                    DesignerForBackgroundsAndImages               = $policy.DesignerForBackgroundsAndImages
                    InOrganizationChatControl                     = $policy.InOrganizationChatControl
                    UsersCanDeleteBotMessages                     = $policy.UsersCanDeleteBotMessages
                    AllowCommunicationComplianceEndUserReporting  = $policy.AllowCommunicationComplianceEndUserReporting
                    AllowGiphy                                    = $policy.AllowGiphy
                    AllowFluidCollaborate                         = $policy.AllowFluidCollaborate
                    AllowMemes                                    = $policy.AllowMemes
                    AllowOwnerDeleteMessage                       = $policy.AllowOwnerDeleteMessage
                    AllowSecurityEndUserReporting                 = $policy.AllowSecurityEndUserReporting
                    AllowStickers                                 = $policy.AllowStickers
                    AllowUrlPreviews                              = $policy.AllowUrlPreviews
                    AllowUserChat                                 = $policy.AllowUserChat
                    AllowUserDeleteMessage                        = $policy.AllowUserDeleteMessage
                    AllowUserEditMessage                          = $policy.AllowUserEditMessage
                    AllowSmartCompose                             = $policy.AllowSmartCompose
                    AllowSmartReply                               = $policy.AllowSmartReply
                    AllowUserTranslation                          = $policy.AllowUserTranslation
                    GiphyRatingType                               = $policy.GiphyRatingType
                    ReadReceiptsEnabledType                       = $policy.ReadReceiptsEnabledType
                    AllowImmersiveReader                          = $policy.AllowImmersiveReader
                    AllowRemoveUser                               = $policy.AllowRemoveUser
                    AllowPriorityMessages                         = $policy.AllowPriorityMessages
                    AllowUserDeleteChat                           = $policy.AllowUserDeleteChat
                    AllowVideoMessages                            = $policy.AllowVideoMessages
                    ChannelsInChatListEnabledType                 = $policy.ChannelsInChatListEnabledType
                    AudioMessageEnabledType                       = $policy.AudioMessageEnabledType
                    UseB2BInvitesToAddExternalUsers               = $useB2BInvitesToAddExternalUsersValue
                    Description                                   = $policy.Description
                    Tenant                                        = $policy.Tenant
                    Ensure                                        = 'Present'
                    Credential                                    = $this.Credential
                    ApplicationId                                 = $this.ApplicationId
                    TenantId                                      = $this.TenantId
                    CertificateThumbprint                         = $this.CertificateThumbprint
                    ManagedIdentity                               = $this.ManagedIdentity
                    AccessTokens                                  = $this.AccessTokens
                })
            }
        }
        catch
        {
            $this.LogError($_, 'Error retrieving data:')

            throw
        }
    }

    [void] Set()
    {
        if ($this.RequiresPowerShellCore())
        {
            $null = $this.InvokeInPowerShellCore('Set')
            return
        }

        Write-Verbose -Message 'Setting configuration of Teams Messaging Policy'

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $curPolicy = $this.Get().ToHashtable()
        $SetParams = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()

        # TODO: Review during next breaking change for updated documentation - Refactor if necessary
        if ($SetParams.ContainsKey('UseB2BInvitesToAddExternalUsers'))
        {
            if ($this.UseB2BInvitesToAddExternalUsers -eq 'Enabled')
            {
               $SetParams.UseB2BInvitesToAddExternalUsers = $true
            }
            else
            {
                $SetParams.UseB2BInvitesToAddExternalUsers = $false
            }
        }

        if ($curPolicy.Ensure -eq 'Absent' -and 'Present' -eq $this.Ensure )
        {
            New-CsTeamsMessagingPolicy @SetParams
        }
        elseif (($curPolicy.Ensure -eq 'Present' -and 'Present' -eq $this.Ensure))
        {
            Set-CsTeamsMessagingPolicy @SetParams
        }
        elseif (($this.Ensure -eq 'Absent' -and $curPolicy.Ensure -eq 'Present'))
        {
            Remove-CsTeamsMessagingPolicy -Identity $curPolicy.Identity
        }
    }

    [bool] Test()
    {
        return ([M365DSCResourceBase] $this).Test()
    }

    [string] Export()
    {
        if ($this.RequiresPowerShellCore())
        {
            return [string] $this.InvokeInPowerShellCore('Export')
        }

        $ConnectionMode = $this.Connect('MicrosoftTeams')

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Export')

        try
        {
            $i = 1
            [array]$policies = Get-CsTeamsMessagingPolicy -Filter $this.Filter -ErrorAction Stop
            $dscContent = [System.Text.StringBuilder]::new()
            Write-M365DSCHost -Message "`r`n" -DeferWrite
            foreach ($policy in $policies)
            {
                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }

                Write-M365DSCHost -Message "    |---[$i/$($policies.Count)] $($policy.Identity)" -DeferWrite

                $params = @{
                    Identity              = $policy.Identity
                    Ensure                = 'Present'
                    Credential            = $this.Credential
                    ApplicationId         = $this.ApplicationId
                    TenantId              = $this.TenantId
                    CertificateThumbprint = $this.CertificateThumbprint
                    CertificatePath       = $this.CertificatePath
                    CertificatePassword   = $this.CertificatePassword
                    ManagedIdentity       = $this.ManagedIdentity
                    AccessTokens          = $this.AccessTokens
                }

                $this.ExportedInstance = $policy
                $Results = $this.GetForExport($Params)
                $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                    -ConnectionMode $ConnectionMode `
                    -ModulePath $this.GetModulePath() `
                    -Results $Results `
                    -Credential $this.Credential
                [void]$dscContent.Append($currentDSCBlock)
                Save-M365DSCPartialExport -Content $currentDSCBlock `
                    -FileName $Global:PartialExportFileName
                $i++
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            return $dscContent.ToString()
        }
        catch
        {
            $this.LogError($_, 'Error during Export:')

            throw
        }
    }

    hidden [TeamsMessagingPolicy] AsResult([System.Object] $Values)
    {
        if ($Values -is [TeamsMessagingPolicy])
        {
            return $Values
        }

        $result = [TeamsMessagingPolicy]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
