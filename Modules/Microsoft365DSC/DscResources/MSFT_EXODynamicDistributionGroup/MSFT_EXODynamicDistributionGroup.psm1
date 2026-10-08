using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class EXODynamicDistributionGroup : M365DSCResourceBase
{
    [DscProperty()]
    [System.ComponentModel.Description('The AcceptMessagesOnlyFrom parameter specifies who is allowed to send messages to this recipient.')]
    [System.String[]] $AcceptMessagesOnlyFrom

    [DscProperty()]
    [System.ComponentModel.Description('The AcceptMessagesOnlyFromDLMembers parameter specifies who is allowed to send messages to this recipient. Messages from other senders are rejected.')]
    [System.String[]] $AcceptMessagesOnlyFromDLMembers

    [DscProperty()]
    [System.ComponentModel.Description('The Alias parameter specifies the Exchange alias (also known as the mail nickname) for the recipient. This value identifies the recipient as a mail-enabled object, and shouldn''t be confused with multiple email addresses for the same recipient (also known as proxy addresses). A recipient can have only one Alias value. The maximum length is 64 characters.')]
    [ValidateLength(1,64)]
    [System.String] $Alias

    [DscProperty()]
    [System.ComponentModel.Description('The BypassModerationFromSendersOrMembers parameter specifies who is allowed to send messages to this moderated recipient without approval from a moderator. Valid values for this parameter are individual senders and groups in your organization. Specifying a group means all members of the group are allowed to send messages to this recipient without approval from a moderator.')]
    [System.String[]] $BypassModerationFromSendersOrMembers

    [DscProperty()]
    [System.ComponentModel.Description('The ConditionalCompany parameter specifies a precanned filter that''s based on the value of the recipient''s Company property. When you use multiple values for this parameter, the OR Boolean operator is applied.')]
    [System.String] $ConditionalCompany

    [DscProperty()]
    [System.ComponentModel.Description('The ConditionalCustomAttribute1 parameter specifies a precanned filter that''s based on the value of the recipient''s CustomAttribute1 property. You can specify multiple values separated by commas. When you use multiple values for this parameter, the OR Boolean operator is applied.')]
    [System.String[]] $ConditionalCustomAttribute1

    [DscProperty()]
    [System.ComponentModel.Description('The ConditionalCustomAttribute10 parameter specifies a precanned filter that''s based on the value of the recipient''s CustomAttribute10 property. You can specify multiple values separated by commas. When you use multiple values for this parameter, the OR Boolean operator is applied.')]
    [System.String[]] $ConditionalCustomAttribute10

    [DscProperty()]
    [System.ComponentModel.Description('The ConditionalCustomAttribute11 parameter specifies a precanned filter that''s based on the value of the recipient''s CustomAttribute11 property. You can specify multiple values separated by commas. When you use multiple values for this parameter, the OR Boolean operator is applied.')]
    [System.String[]] $ConditionalCustomAttribute11

    [DscProperty()]
    [System.ComponentModel.Description('The ConditionalCustomAttribute12 parameter specifies a precanned filter that''s based on the value of the recipient''s CustomAttribute12 property. You can specify multiple values separated by commas. When you use multiple values for this parameter, the OR Boolean operator is applied.')]
    [System.String[]] $ConditionalCustomAttribute12

    [DscProperty()]
    [System.ComponentModel.Description('The ConditionalCustomAttribute13 parameter specifies a precanned filter that''s based on the value of the recipient''s CustomAttribute13 property. You can specify multiple values separated by commas. When you use multiple values for this parameter, the OR Boolean operator is applied.')]
    [System.String[]] $ConditionalCustomAttribute13

    [DscProperty()]
    [System.ComponentModel.Description('The ConditionalCustomAttribute14 parameter specifies a precanned filter that''s based on the value of the recipient''s CustomAttribute14 property. You can specify multiple values separated by commas. When you use multiple values for this parameter, the OR Boolean operator is applied.')]
    [System.String[]] $ConditionalCustomAttribute14

    [DscProperty()]
    [System.ComponentModel.Description('The ConditionalCustomAttribute15 parameter specifies a precanned filter that''s based on the value of the recipient''s CustomAttribute15 property. You can specify multiple values separated by commas. When you use multiple values for this parameter, the OR Boolean operator is applied.')]
    [System.String[]] $ConditionalCustomAttribute15

    [DscProperty()]
    [System.ComponentModel.Description('The ConditionalCustomAttribute2 parameter specifies a precanned filter that''s based on the value of the recipient''s CustomAttribute2 property. You can specify multiple values separated by commas. When you use multiple values for this parameter, the OR Boolean operator is applied.')]
    [System.String[]] $ConditionalCustomAttribute2

    [DscProperty()]
    [System.ComponentModel.Description('The ConditionalCustomAttribute3 parameter specifies a precanned filter that''s based on the value of the recipient''s CustomAttribute3 property. You can specify multiple values separated by commas. When you use multiple values for this parameter, the OR Boolean operator is applied.')]
    [System.String[]] $ConditionalCustomAttribute3

    [DscProperty()]
    [System.ComponentModel.Description('The ConditionalCustomAttribute4 parameter specifies a precanned filter that''s based on the value of the recipient''s CustomAttribute4 property. You can specify multiple values separated by commas. When you use multiple values for this parameter, the OR Boolean operator is applied.')]
    [System.String[]] $ConditionalCustomAttribute4

    [DscProperty()]
    [System.ComponentModel.Description('The ConditionalCustomAttribute5 parameter specifies a precanned filter that''s based on the value of the recipient''s CustomAttribute5 property. You can specify multiple values separated by commas. When you use multiple values for this parameter, the OR Boolean operator is applied.')]
    [System.String[]] $ConditionalCustomAttribute5

    [DscProperty()]
    [System.ComponentModel.Description('The ConditionalCustomAttribute6 parameter specifies a precanned filter that''s based on the value of the recipient''s CustomAttribute6 property. You can specify multiple values separated by commas. When you use multiple values for this parameter, the OR Boolean operator is applied.')]
    [System.String[]] $ConditionalCustomAttribute6

    [DscProperty()]
    [System.ComponentModel.Description('The ConditionalCustomAttribute7 parameter specifies a precanned filter that''s based on the value of the recipient''s CustomAttribute7 property. You can specify multiple values separated by commas. When you use multiple values for this parameter, the OR Boolean operator is applied.')]
    [System.String[]] $ConditionalCustomAttribute7

    [DscProperty()]
    [System.ComponentModel.Description('The ConditionalCustomAttribute8 parameter specifies a precanned filter that''s based on the value of the recipient''s CustomAttribute8 property. You can specify multiple values separated by commas. When you use multiple values for this parameter, the OR Boolean operator is applied.')]
    [System.String[]] $ConditionalCustomAttribute8

    [DscProperty()]
    [System.ComponentModel.Description('The ConditionalCustomAttribute9 parameter specifies a precanned filter that''s based on the value of the recipient''s CustomAttribute9 property. You can specify multiple values separated by commas. When you use multiple values for this parameter, the OR Boolean operator is applied.')]
    [System.String[]] $ConditionalCustomAttribute9

    [DscProperty()]
    [System.ComponentModel.Description('The ConditionalDepartment parameter specifies a precanned filter that''s based on the value of the recipient''s Department property. You can specify multiple values separated by commas. When you use multiple values for this parameter, the OR Boolean operator is applied.')]
    [System.String[]] $ConditionalDepartment

    [DscProperty()]
    [System.ComponentModel.Description('The ConditionalStateOrProvince parameter specifies a precanned filter that''s based on the value of the recipient''s StateOrProvince property. You can specify multiple values separated by commas. When you use multiple values for this parameter, the OR Boolean operator is applied.')]
    [System.String[]] $ConditionalStateOrProvince

    [DscProperty()]
    [System.ComponentModel.Description('This parameter specifies a value for the CustomAttribute1 property on the recipient. You can use this property to store custom information about the recipient, and to identify the recipient in filters. The maximum length is 1024 characters.')]
    [ValidateLength(0, 1024)]
    [System.String] $CustomAttribute1

    [DscProperty()]
    [System.ComponentModel.Description('This parameter specifies a value for the CustomAttribute10 property on the recipient. You can use this property to store custom information about the recipient, and to identify the recipient in filters. The maximum length is 1024 characters. ')]
    [ValidateLength(0, 1024)]
    [System.String] $CustomAttribute10

    [DscProperty()]
    [System.ComponentModel.Description('This parameter specifies a value for the CustomAttribute11 property on the recipient. You can use this property to store custom information about the recipient, and to identify the recipient in filters. The maximum length is 1024 characters.')]
    [ValidateLength(0, 1024)]
    [System.String] $CustomAttribute11

    [DscProperty()]
    [System.ComponentModel.Description('This parameter specifies a value for the CustomAttribute12 property on the recipient. You can use this property to store custom information about the recipient, and to identify the recipient in filters. The maximum length is 1024 characters.')]
    [ValidateLength(0, 1024)]
    [System.String] $CustomAttribute12

    [DscProperty()]
    [System.ComponentModel.Description('This parameter specifies a value for the CustomAttribute13 property on the recipient. You can use this property to store custom information about the recipient, and to identify the recipient in filters. The maximum length is 1024 characters.')]
    [ValidateLength(0, 1024)]
    [System.String] $CustomAttribute13

    [DscProperty()]
    [System.ComponentModel.Description('This parameter specifies a value for the CustomAttribute14 property on the recipient. You can use this property to store custom information about the recipient, and to identify the recipient in filters. The maximum length is 1024 characters.')]
    [ValidateLength(0, 1024)]
    [System.String] $CustomAttribute14

    [DscProperty()]
    [System.ComponentModel.Description('This parameter specifies a value for the CustomAttribute15 property on the recipient. You can use this property to store custom information about the recipient, and to identify the recipient in filters. The maximum length is 1024 characters.')]
    [ValidateLength(0, 1024)]
    [System.String] $CustomAttribute15

    [DscProperty()]
    [System.ComponentModel.Description('This parameter specifies a value for the CustomAttribute2 property on the recipient. You can use this property to store custom information about the recipient, and to identify the recipient in filters. The maximum length is 1024 characters.')]
    [ValidateLength(0, 1024)]
    [System.String] $CustomAttribute2

    [DscProperty()]
    [System.ComponentModel.Description('This parameter specifies a value for the CustomAttribute3 property on the recipient. You can use this property to store custom information about the recipient, and to identify the recipient in filters. The maximum length is 1024 characters.')]
    [ValidateLength(0, 1024)]
    [System.String] $CustomAttribute3

    [DscProperty()]
    [System.ComponentModel.Description('This parameter specifies a value for the CustomAttribute4 property on the recipient. You can use this property to store custom information about the recipient, and to identify the recipient in filters. The maximum length is 1024 characters.')]
    [ValidateLength(0, 1024)]
    [System.String] $CustomAttribute4

    [DscProperty()]
    [System.ComponentModel.Description('This parameter specifies a value for the CustomAttribute5 property on the recipient. You can use this property to store custom information about the recipient, and to identify the recipient in filters. The maximum length is 1024 characters.')]
    [ValidateLength(0, 1024)]
    [System.String] $CustomAttribute5

    [DscProperty()]
    [System.ComponentModel.Description('This parameter specifies a value for the CustomAttribute6 property on the recipient. You can use this property to store custom information about the recipient, and to identify the recipient in filters. The maximum length is 1024 characters.')]
    [ValidateLength(0, 1024)]
    [System.String] $CustomAttribute6

    [DscProperty()]
    [System.ComponentModel.Description('This parameter specifies a value for the CustomAttribute7 property on the recipient. You can use this property to store custom information about the recipient, and to identify the recipient in filters. The maximum length is 1024 characters.')]
    [ValidateLength(0, 1024)]
    [System.String] $CustomAttribute7

    [DscProperty()]
    [System.ComponentModel.Description('This parameter specifies a value for the CustomAttribute8 property on the recipient. You can use this property to store custom information about the recipient, and to identify the recipient in filters. The maximum length is 1024 characters.')]
    [ValidateLength(0, 1024)]
    [System.String] $CustomAttribute8

    [DscProperty()]
    [System.ComponentModel.Description('This parameter specifies a value for the CustomAttribute9 property on the recipient. You can use this property to store custom information about the recipient, and to identify the recipient in filters. The maximum length is 1024 characters.')]
    [ValidateLength(0, 1024)]
    [System.String] $CustomAttribute9

    [DscProperty()]
    [System.ComponentModel.Description('The DisplayName parameter specifies the display name of the dynamic distribution group. The display name is visible in the Exchange admin center and in address lists. The maximum length is 256 characters.')]
    [ValidateLength(0, 256)]
    [System.String] $DisplayName

    [DscProperty()]
    [System.ComponentModel.Description('The EmailAddresses parameter specifies all email addresses (proxy addresses) for the recipient, including the primary SMTP address. ')]
    [System.String[]] $EmailAddresses

    [DscProperty()]
    [System.ComponentModel.Description('This parameter specifies a value for the ExtensionCustomAttribute1 property on the recipient. You can use this property to store custom information about the recipient, and to identify the recipient in filters. You can specify up to 1300 values separated by commas.')]
    [System.String[]] $ExtensionCustomAttribute1

    [DscProperty()]
    [System.ComponentModel.Description('This parameter specifies a value for the ExtensionCustomAttribute2 property on the recipient. You can use this property to store custom information about the recipient, and to identify the recipient in filters. You can specify up to 1300 values separated by commas.')]
    [System.String] $ExtensionCustomAttribute2

    [DscProperty()]
    [System.ComponentModel.Description('This parameter specifies a value for the ExtensionCustomAttribute3 property on the recipient. You can use this property to store custom information about the recipient, and to identify the recipient in filters. You can specify up to 1300 values separated by commas.')]
    [System.String] $ExtensionCustomAttribute3

    [DscProperty()]
    [System.ComponentModel.Description('This parameter specifies a value for the ExtensionCustomAttribute4 property on the recipient. You can use this property to store custom information about the recipient, and to identify the recipient in filters. You can specify up to 1300 values separated by commas.')]
    [System.String] $ExtensionCustomAttribute4

    [DscProperty()]
    [System.ComponentModel.Description('This parameter specifies a value for the ExtensionCustomAttribute5 property on the recipient. You can use this property to store custom information about the recipient, and to identify the recipient in filters. You can specify up to 1300 values separated by commas.')]
    [System.String] $ExtensionCustomAttribute5

    [DscProperty()]
    [System.ComponentModel.Description('The GrantSendOnBehalfTo parameter specifies who can send on behalf of this dynamic distribution group. Although messages send on behalf of the group clearly show the sender in the From field (<Sender> on behalf of <Group>), replies to these messages are delivered to the group, not the sender.')]
    [System.String[]] $GrantSendOnBehalfTo

    [DscProperty()]
    [System.ComponentModel.Description('The HiddenFromAddressListsEnabled parameter specifies whether this recipient is visible in address lists. Valid values are: $true: The recipient isn''t visible in address lists. $false: The recipient is visible in address lists. This value is the default.')]
    [System.Nullable[System.Boolean]] $HiddenFromAddressListsEnabled

    [DscProperty(Key)]
    [System.ComponentModel.Description('The Identity parameter specifies the dynamic distribution group that you want to modify. You can use any value that uniquely identifies the dynamic distribution group.')]
    [System.String] $Identity

    [DscProperty()]
    [System.ComponentModel.Description('The IncludedRecipients parameter specifies a precanned filter that''s based on the recipient type. Valid values are: AllRecipients: This value can be used only by itself. MailboxUsers. MailContacts. MailGroups. MailUsers. Resources: This value indicates room or equipment mailboxes. You can specify multiple values separated by commas. When you use multiple values, the OR Boolean operator is applied.')]
    [ValidateSet('AllRecipients', 'MailboxUsers', 'MailContacts', 'MailGroups', 'MailUsers', 'Resources')]
    [System.String[]] $IncludedRecipients

    [DscProperty()]
    [System.ComponentModel.Description('The MailTip parameter specifies the custom MailTip text for this recipient. The MailTip is shown to senders when they start drafting an email message to this recipient. If the value contains spaces, enclose the value in quotation marks (\')]
    [System.String] $MailTip

    [DscProperty()]
    [System.ComponentModel.Description('The MailTipTranslations parameter specifies additional languages for the custom MailTip text that''s defined by the MailTip parameter. HTML tags are automatically added to the MailTip translation, additional HTML tags aren''t supported, and the length of the MailTip translation can''t exceed 175 displayed characters.')]
    [System.String[]] $MailTipTranslations

    [DscProperty()]
    [System.ComponentModel.Description('The ManagedBy parameter specifies an owner for the group. A dynamic group can only have one owner.')]
    [System.String] $ManagedBy

    [DscProperty()]
    [System.ComponentModel.Description('The ModeratedBy parameter specifies one or more moderators for this recipient. A moderator approves messages sent to the recipient before the messages are delivered. A moderator must be a mailbox, mail user, or mail contact in your organization. You can use any value that uniquely identifies the moderator.')]
    [System.String[]] $ModeratedBy

    [DscProperty()]
    [System.ComponentModel.Description('The ModerationEnabled parameter specifies whether moderation is enabled for this recipient.')]
    [System.Nullable[System.Boolean]] $ModerationEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The Name parameter specifies the unique name of the dynamic distribution group. The maximum length is 64 characters.')]
    [ValidateLength(1,64)]
    [System.String] $Name

    [DscProperty()]
    [System.ComponentModel.Description('The Notes parameters specifies additional information about the object.')]
    [System.String] $Notes

    [DscProperty()]
    [System.ComponentModel.Description('The PhoneticDisplayName parameter specifies an alternate spelling of the user''s name that''s used for text to speech in Unified Messaging (UM) environments. Typically, you use this parameter when the pronunciation and spelling of the user''s name don''t match. The maximum length is 256 characters.')]
    [ValidateLength(0,256)]
    [System.String] $PhoneticDisplayName

    [DscProperty()]
    [System.ComponentModel.Description('The PrimarySmtpAddress parameter specifies the primary return email address that''s used for the recipient.')]
    [System.String] $PrimarySmtpAddress

    [DscProperty()]
    [System.ComponentModel.Description('The RecipientContainer parameter specifies a filter that''s based on the recipient''s location in Active Directory. Valid input for this parameter is an organizational unit (OU) or domain that''s returned by the Get-OrganizationalUnit cmdlet. You can use any value that uniquely identifies the OU or domain.')]
    [System.String] $RecipientContainer

    [DscProperty()]
    [System.ComponentModel.Description('The RecipientFilter parameter specifies a custom OPATH filter that''s based on the value of any available recipient property. You can use any available Windows PowerShell operator, and wildcards and partial matches are supported. The search criteria uses the syntax \"Property -ComparisonOperator ''Value''\".')]
    [System.String] $RecipientFilter

    [DscProperty()]
    [System.ComponentModel.Description('The RejectMessagesFrom parameter specifies who isn''t allowed to send messages to this recipient. Messages from these senders are rejected.')]
    [System.String[]] $RejectMessagesFrom

    [DscProperty()]
    [System.ComponentModel.Description('The RejectMessagesFromDLMembers parameter specifies who isn''t allowed to send messages to this recipient. Messages from these senders are rejected.')]
    [System.String[]] $RejectMessagesFromDLMembers

    [DscProperty()]
    [System.ComponentModel.Description('The RejectMessagesFromSendersOrMembers parameter specifies who isn''t allowed to send messages to this recipient. Messages from these senders are rejected.')]
    [System.String[]] $RejectMessagesFromSendersOrMembers

    [DscProperty()]
    [System.ComponentModel.Description('The ReportToManagerEnabled parameter specifies whether delivery status notifications (also known as DSNs, non-delivery reports, NDRs, or bounce messages) are sent to the owners of the group (defined by the ManagedBy property).')]
    [System.Nullable[System.Boolean]] $ReportToManagerEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The ReportToOriginatorEnabled parameter specifies whether delivery status notifications (also known as DSNs, non-delivery reports, NDRs, or bounce messages) are sent to senders who send messages to this group.')]
    [System.Nullable[System.Boolean]] $ReportToOriginatorEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The RequireSenderAuthenticationEnabled parameter specifies whether to accept messages only from authenticated (internal) senders.')]
    [System.Nullable[System.Boolean]] $RequireSenderAuthenticationEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The SendModerationNotifications parameter specifies when moderation notification messages are sent. Valid values are: Always: Notify all senders when their messages aren''t approved. This value is the default. Internal: Notify senders in the organization when their messages aren''t approved. Never: Don''t notify anyone when a message isn''t approved.')]
    [ValidateSet('Always', 'Internal', 'Never')]
    [System.String] $SendModerationNotifications

    [DscProperty()]
    [System.ComponentModel.Description('The SendOofMessageToOriginatorEnabled parameter specifies how to handle out of office (OOF) messages for members of the group.')]
    [System.Nullable[System.Boolean]] $SendOofMessageToOriginatorEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The SimpleDisplayName parameter is used to display an alternative description of the object when only a limited set of characters is permitted.')]
    [System.String] $SimpleDisplayName

    [DscProperty()]
    [System.ComponentModel.Description('The WindowsEmailAddress parameter specifies the Windows email address for this recipient. This is a common Active Directory attribute that''s present in all environments, including environments without Exchange.')]
    [System.String] $WindowsEmailAddress

    [DscProperty()]
    [System.ComponentModel.Description('Present ensures the policy exists, absent ensures it is removed.')]
    [ValidateSet('Present', 'Absent')]
    [System.String] $Ensure

    [DscProperty()]
    [System.ComponentModel.Description('Credentials of the Exchange Global Admin')]
    [System.Management.Automation.PSCredential] $Credential

    [DscProperty()]
    [System.ComponentModel.Description('Id of the Azure Active Directory application to authenticate with.')]
    [System.String] $ApplicationId

    [DscProperty()]
    [System.ComponentModel.Description('Id of the Azure Active Directory tenant used for authentication.')]
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
    [System.String] $Filter

    [EXODynamicDistributionGroup] Get()
    {
        $nullResult = $null
        $ApplicationSecret = $null
        if ($this.RequiresPowerShellCore())
        {
            $remote = [EXODynamicDistributionGroup]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of the EXO Dynamic Distribution Group with Identity {$($this.Identity)}"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.Identity -ne $this.Identity)
            {
                $null = $this.Connect('ExchangeOnline')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullResult = $this.GetBoundParameters()
                $nullResult.Ensure = 'Absent'

                if (-not [System.String]::IsNullOrEmpty($this.PrimarySmtpAddress))
                {
                    $instance = Get-DynamicDistributionGroup -Identity $this.PrimarySmtpAddress -ErrorAction SilentlyContinue
                }
                else
                {
                    $instance = Get-DynamicDistributionGroup -Identity $this.Identity -ErrorAction SilentlyContinue
                }

                if ($null -eq $instance)
                {
                    Write-Verbose -Message "Could not find an EXO Dynamic Distribution Group with Identity $($this.Identity)."
                    return $this.AsResult($nullResult)
                }
            }
            else
            {
                $instance = $this.ExportedInstance
            }

            Write-Verbose -Message "An EXO Dynamic Distribution Group with Identity {$($this.Identity)} was found"

            $acceptMessagesOnlyFromValue = @()
            if ($null -ne $instance.AcceptMessagesOnlyFrom)
            {
                Write-Verbose -Message "Getting Dynamic Distribution Group AcceptMessagesOnlyFrom for $($this.Identity)"
                $acceptMessagesOnlyFromValue += $this.GetElementFromRecipientsCacheAsPrimarySmtpAddress($instance.AcceptMessagesOnlyFrom)
            }

            $acceptMessagesOnlyFromDLMembersValue = @()
            if ($null -ne $instance.AcceptMessagesOnlyFromDLMembers)
            {
                Write-Verbose -Message "Getting Dynamic Distribution Group AcceptMessagesOnlyFromDLMembers for $($this.Identity)"
                $acceptMessagesOnlyFromDLMembersValue += $this.GetElementFromRecipientsCacheAsPrimarySmtpAddress($instance.AcceptMessagesOnlyFromDLMembers)
            }

            $bypassModerationFromSendersOrMembersValue = @()
            if ($null -ne $instance.BypassModerationFromSendersOrMembers)
            {
                Write-Verbose -Message "Getting Dynamic Distribution Group BypassModerationFromSendersOrMembers for $($this.Identity)"
                $bypassModerationFromSendersOrMembersValue += $this.GetElementFromRecipientsCacheAsPrimarySmtpAddress($instance.BypassModerationFromSendersOrMembers)
            }

            $grantSendOnBehalfToValue = @()
            if ($null -ne $instance.GrantSendOnBehalfTo)
            {
                Write-Verbose -Message "Getting Dynamic Distribution Group GrantSendOnBehalfTo for $($this.Identity)"
                $grantSendOnBehalfToValue += $this.GetElementFromRecipientsCacheAsPrimarySmtpAddress($instance.GrantSendOnBehalfTo)
            }

            $managedByValue = $null
            if ($null -ne $instance.ManagedBy)
            {
                Write-Verbose -Message "Getting Dynamic Distribution Group manager for $($this.Identity)"
                $managedByValue = $this.GetElementFromRecipientsCacheAsPrimarySmtpAddress($instance.ManagedBy)
            }

            $moderatedByValue = @()
            if ($null -ne $instance.ModeratedBy)
            {
                Write-Verbose -Message "Getting Dynamic Distribution Group moderators for $($this.Identity)"
                $moderatedByValue += $this.GetElementFromRecipientsCacheAsPrimarySmtpAddress($instance.ModeratedBy)
            }

            $rejectMessagesFromValue = @()
            if ($null -ne $instance.RejectMessagesFrom)
            {
                Write-Verbose -Message "Getting Dynamic Distribution Group RejectMessagesFrom for $($this.Identity)"
                $rejectMessagesFromValue += $this.GetElementFromRecipientsCacheAsPrimarySmtpAddress($instance.RejectMessagesFrom)
            }

            $rejectMessagesFromDLMembersValue = @()
            if ($null -ne $instance.RejectMessagesFromDLMembers)
            {
                Write-Verbose -Message "Getting Dynamic Distribution Group RejectMessagesFromDLMembers for $($this.Identity)"
                $rejectMessagesFromDLMembersValue += $this.GetElementFromRecipientsCacheAsPrimarySmtpAddress($instance.RejectMessagesFromDLMembers)
            }

            $includedRecipientsValue = @()
            foreach ($includedRecipient in $instance.IncludedRecipients)
            {
                foreach ($recipientType in ("$includedRecipient" -split ',\s*'))
                {
                    if (-not [System.String]::IsNullOrEmpty($recipientType))
                    {
                        $includedRecipientsValue += $recipientType
                    }
                }
            }

            $mailTipTranslationsValue = @()
            foreach ($mailTipTranslation in $instance.MailTipTranslations)
            {
                if ($mailTipTranslation -notlike 'default:*')
                {
                    $mailTipTranslationsValue += [EXODynamicDistributionGroup]::RemoveMailTipHtml($mailTipTranslation)
                }
            }

            $results = @{
                AcceptMessagesOnlyFrom                 = $acceptMessagesOnlyFromValue
                AcceptMessagesOnlyFromDLMembers        = $acceptMessagesOnlyFromDLMembersValue
                Alias                                  = $instance.Alias
                BypassModerationFromSendersOrMembers   = $bypassModerationFromSendersOrMembersValue
                ConditionalCompany                     = $instance.ConditionalCompany
                ConditionalCustomAttribute1            = $instance.ConditionalCustomAttribute1
                ConditionalCustomAttribute10           = $instance.ConditionalCustomAttribute10
                ConditionalCustomAttribute11           = $instance.ConditionalCustomAttribute11
                ConditionalCustomAttribute12           = $instance.ConditionalCustomAttribute12
                ConditionalCustomAttribute13           = $instance.ConditionalCustomAttribute13
                ConditionalCustomAttribute14           = $instance.ConditionalCustomAttribute14
                ConditionalCustomAttribute15           = $instance.ConditionalCustomAttribute15
                ConditionalCustomAttribute2            = $instance.ConditionalCustomAttribute2
                ConditionalCustomAttribute3            = $instance.ConditionalCustomAttribute3
                ConditionalCustomAttribute4            = $instance.ConditionalCustomAttribute4
                ConditionalCustomAttribute5            = $instance.ConditionalCustomAttribute5
                ConditionalCustomAttribute6            = $instance.ConditionalCustomAttribute6
                ConditionalCustomAttribute7            = $instance.ConditionalCustomAttribute7
                ConditionalCustomAttribute8            = $instance.ConditionalCustomAttribute8
                ConditionalCustomAttribute9            = $instance.ConditionalCustomAttribute9
                ConditionalDepartment                  = $instance.ConditionalDepartment
                ConditionalStateOrProvince             = $instance.ConditionalStateOrProvince
                CustomAttribute1                       = $instance.CustomAttribute1
                CustomAttribute10                      = $instance.CustomAttribute10
                CustomAttribute11                      = $instance.CustomAttribute11
                CustomAttribute12                      = $instance.CustomAttribute12
                CustomAttribute13                      = $instance.CustomAttribute13
                CustomAttribute14                      = $instance.CustomAttribute14
                CustomAttribute15                      = $instance.CustomAttribute15
                CustomAttribute2                       = $instance.CustomAttribute2
                CustomAttribute3                       = $instance.CustomAttribute3
                CustomAttribute4                       = $instance.CustomAttribute4
                CustomAttribute5                       = $instance.CustomAttribute5
                CustomAttribute6                       = $instance.CustomAttribute6
                CustomAttribute7                       = $instance.CustomAttribute7
                CustomAttribute8                       = $instance.CustomAttribute8
                CustomAttribute9                       = $instance.CustomAttribute9
                DisplayName                            = $instance.DisplayName
                EmailAddresses                         = $instance.EmailAddresses
                ExtensionCustomAttribute1              = $instance.ExtensionCustomAttribute1
                ExtensionCustomAttribute2              = $instance.ExtensionCustomAttribute2
                ExtensionCustomAttribute3              = $instance.ExtensionCustomAttribute3
                ExtensionCustomAttribute4              = $instance.ExtensionCustomAttribute4
                ExtensionCustomAttribute5              = $instance.ExtensionCustomAttribute5
                ForceMembershipRefresh                 = $instance.ForceMembershipRefresh
                GrantSendOnBehalfTo                    = $grantSendOnBehalfToValue
                HiddenFromAddressListsEnabled          = $instance.HiddenFromAddressListsEnabled
                Identity                               = $instance.Identity
                IncludedRecipients                     = [System.String[]]$includedRecipientsValue
                MailTip                                = [EXODynamicDistributionGroup]::RemoveMailTipHtml($instance.MailTip)
                MailTipTranslations                    = [System.String[]]$mailTipTranslationsValue
                ManagedBy                              = $managedByValue
                ModeratedBy                            = $moderatedByValue
                ModerationEnabled                      = $instance.ModerationEnabled
                Name                                   = $instance.Name
                Notes                                  = $instance.Notes
                PhoneticDisplayName                    = $instance.PhoneticDisplayName
                PrimarySmtpAddress                     = $instance.PrimarySmtpAddress
                RecipientContainer                     = $instance.RecipientContainer
                RecipientFilter                        = $this.RestoreOriginalRecipientFilter($instance.RecipientFilter)
                RejectMessagesFrom                     = $rejectMessagesFromValue
                RejectMessagesFromDLMembers            = $rejectMessagesFromDLMembersValue
                ReportToManagerEnabled                 = $instance.ReportToManagerEnabled
                ReportToOriginatorEnabled              = $instance.ReportToOriginatorEnabled
                RequireSenderAuthenticationEnabled     = $instance.RequireSenderAuthenticationEnabled
                SendModerationNotifications            = $instance.SendModerationNotifications
                SendOofMessageToOriginatorEnabled      = $instance.SendOofMessageToOriginatorEnabled
                SimpleDisplayName                      = $instance.SimpleDisplayName
                UpdateMemberCount                      = $instance.UpdateMemberCount
                WindowsEmailAddress                    = $instance.WindowsEmailAddress
                Ensure                                 = 'Present'
                Credential                             = $this.Credential
                ApplicationId                          = $this.ApplicationId
                TenantId                               = $this.TenantId
                CertificateThumbprint                  = $this.CertificateThumbprint
                ApplicationSecret                      = $ApplicationSecret
            }
            return $this.AsResult($results)
        }
        catch
        {
            $this.LogError($_, 'Error retrieving data:')

            return $this.AsResult($nullResult)
        }
    }

    [void] Set()
    {
        if ($this.RequiresPowerShellCore())
        {
            $null = $this.InvokeInPowerShellCore('Set')
            return
        }

        $null = $this.Connect('ExchangeOnline')

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $currentInstance = $this.Get().ToHashtable()
        $boundParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()
        if ($boundParameters.ContainsKey('RecipientFilter') -and -not [System.String]::IsNullOrEmpty($boundParameters['RecipientFilter']))
        {
            Write-Verbose -Message 'Removing Conditional* parameters because RecipientFilter is set'
            $boundParameters.Keys.Clone() | ForEach-Object {
                if ($_ -like 'Conditional*')
                {
                    $boundParameters.Remove($_) | Out-Null
                }
            }
        }

        if ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
        {
            $createParameters = ([Hashtable]$boundParameters).Clone()
            $onlyUpateParameters = @(
                'Identity',
                'AcceptMessagesOnlyFrom',
                'AcceptMessagesOnlyFromDLMembers',
                'BypassModerationFromSendersOrMembers',
                'CustomAttribute1',
                'CustomAttribute10',
                'CustomAttribute11',
                'CustomAttribute12',
                'CustomAttribute13',
                'CustomAttribute14',
                'CustomAttribute15',
                'CustomAttribute2',
                'CustomAttribute3',
                'CustomAttribute4',
                'CustomAttribute5',
                'CustomAttribute6',
                'CustomAttribute7',
                'CustomAttribute8',
                'CustomAttribute9',
                'EmailAddresses',
                'ExtensionCustomAttribute1',
                'ExtensionCustomAttribute2',
                'ExtensionCustomAttribute3',
                'ExtensionCustomAttribute4',
                'ExtensionCustomAttribute5',
                'GrantSendOnBehalfTo',
                'HiddenFromAddressListsEnabled',
                'MailTip',
                'MailTipTranslations',
                'ManagedBy',
                'Notes',
                'PhoneticDisplayName',
                'RejectMessagesFrom',
                'RejectMessagesFromDLMembers',
                'ReportToManagerEnabled',
                'ReportToOriginatorEnabled',
                'RequireSenderAuthenticationEnabled',
                'SendOofMessageToOriginatorEnabled',
                'SimpleDisplayName',
                'WindowsEmailAddress'
            )

            $updateParameters = @{}
            foreach ($param in $onlyUpateParameters)
            {
                if ($createParameters.ContainsKey($param) -and $param -ne 'Identity')
                {
                    $updateParameters[$param] = $createParameters[$param]
                }
                $createParameters.Remove($param) | Out-Null
            }

            Write-Verbose -Message "Creating an EXO Dynamic Distribution Group with Identity {$($this.Identity)}"
            $group = New-DynamicDistributionGroup @createParameters -ErrorAction Stop

            if ($updateParameters.Count -gt 1)
            {
                Write-Verbose -Message "Updating the EXO Dynamic Distribution Group with Identity {$($this.Identity)} after creation"
                Set-DynamicDistributionGroup -Identity $group.Identity @updateParameters | Out-Null
            }
        }
        elseif ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Updating the EXO Dynamic Distribution Group with Identity {$($this.Identity)}"

            $updateParameters = ([Hashtable]$boundParameters).Clone()
            if ($this.EmailAddresses.Length -gt 0)
            {
                $updateParameters.Remove('PrimarySmtpAddress') | Out-Null
            }

            if ($this.AcceptMessagesOnlyFrom.Length -gt 0)
            {
                $updateParameters.Remove('AcceptMessagesOnlyFromDLMembers') | Out-Null
                $updateParameters.Remove('AcceptMessagesOnlyFromSendersOrMembers') | Out-Null
            }

            Set-DynamicDistributionGroup @updateParameters | Out-Null
        }
        elseif ($this.Ensure -eq 'Absent' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Removing the EXO Dynamic Distribution Group with Identity {$($this.Identity)}"
            Remove-DynamicDistributionGroup -Identity $currentInstance.Identity -Confirm:$false
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

       $ConnectionMode = $this.Connect('ExchangeOnline')

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Export')

        try
        {
            [array]$getValue = Get-DynamicDistributionGroup -Filter $this.Filter -ErrorAction Stop

            $i = 1
            $dscContent = ''
            if ($getValue.Length -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }
            foreach ($config in $getValue)
            {
                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }

                $displayedKey = $config.Identity
                if (-not [String]::IsNullOrEmpty($config.displayName))
                {
                    $displayedKey = $config.displayName
                }
                Write-M365DSCHost -Message "    |---[$i/$($getValue.Count)] $displayedKey" -DeferWrite
                $params = @{
                    Identity              = $config.Identity
                    Ensure                = 'Present'
                    Credential            = $this.Credential
                    ApplicationId         = $this.ApplicationId
                    TenantId              = $this.TenantId
                    CertificateThumbprint = $this.CertificateThumbprint
                    CertificatePassword   = $this.CertificatePassword
                    ManagedIdentity       = $this.ManagedIdentity
                    CertificatePath       = $this.CertificatePath
                    AccessTokens          = $this.AccessTokens
                }

                $this.ExportedInstance = $config
                $Results = $this.GetForExport($Params)
                $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                    -ConnectionMode $ConnectionMode `
                    -ModulePath $this.GetModulePath() `
                    -Results $Results `
                    -Credential $this.Credential
                $dscContent += $currentDSCBlock
                Save-M365DSCPartialExport -Content $currentDSCBlock `
                    -FileName $Global:PartialExportFileName
                $i++
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            return $dscContent
        }
        catch
        {
            Write-M365DSCHost -Message $Global:M365DSCEmojiRedX -CommitWrite

            $this.LogError($_, 'Error during Export:')

            return ''
        }
    }

    [System.Collections.Hashtable] GetCompareParameters()
    {
        return @{
            PostProcessing = {
                param($DesiredValues, $CurrentValues, $ValuesToCheck, $ignore)
                if ($DesiredValues.ContainsKey('RecipientFilter') -and -not [System.String]::IsNullOrEmpty($DesiredValues.RecipientFilter))
                {
                    $DesiredValues.RecipientFilter = [EXODynamicDistributionGroup]::ToExchangeFilterSyntax($DesiredValues.RecipientFilter)

                    # If RecipientFilter is specified, ignore the conditional properties
                    $ValuesToCheck.Keys.Clone() | Where-Object { $_ -like "Conditional*" } | Foreach-Object {
                        $ValuesToCheck.Remove($_) | Out-Null
                    }
                }
                return [System.Tuple[Hashtable, Hashtable, Hashtable]]::new($DesiredValues, $CurrentValues, $ValuesToCheck)
            }
        }
    }

    hidden [System.Object[]] GetElementFromRecipientsCacheAsPrimarySmtpAddress([System.String[]] $RecipientName)
    {
        if ($null -eq $this.ResourceCache['RecipientsCache'])
        {
            $this.ResourceCache['RecipientsCache'] = [System.Collections.Generic.Dictionary[System.String, System.Object]]::new()
        }

        $recipientsCache = $this.ResourceCache['RecipientsCache']
        $addresses = @()
        foreach ($name in $RecipientName)
        {
            if (-not $recipientsCache.ContainsKey($name))
            {
                Get-Recipient -Identity $name -ErrorAction SilentlyContinue | ForEach-Object {
                    $recipientsCache[$_.Name] = @{
                        PrimarySmtpAddress = $_.PrimarySmtpAddress
                        WindowsLiveID      = $_.WindowsLiveID
                    }
                }
            }
            $addresses += $recipientsCache[$name].PrimarySmtpAddress
        }

        return $addresses
    }

    hidden [System.String] RestoreOriginalRecipientFilter([System.String] $ExpandedFilter)
    {
        # region --- define the two known Exchange Online auto-append patterns ---
        $patterns = @()

        # 1. System/Arbitration mailbox exclusion block
        $patterns += [regex]::Escape("-and (-not(Name -like 'SystemMailbox{*')) -and (-not(Name -like 'CAS_{*')) -and (-not(RecipientTypeDetailsValue -eq 'MailboxPlan')) -and (-not(RecipientTypeDetailsValue -eq 'DiscoveryMailbox')) -and (-not(RecipientTypeDetailsValue -eq 'PublicFolderMailbox')) -and (-not(RecipientTypeDetailsValue -eq 'ArbitrationMailbox')) -and (-not(RecipientTypeDetailsValue -eq 'AuditLogMailbox')) -and (-not(RecipientTypeDetailsValue -eq 'AuxAuditLogMailbox')) -and (-not(RecipientTypeDetailsValue -eq 'SupervisoryReviewPolicyMailbox'))")

        # 2. Extended RecipientType filtering block
        $patterns += [regex]::Escape("-and (((RecipientType -eq 'UserMailbox') -or (RecipientType -eq 'MailContact') -or (RecipientType -eq 'MailUser') -or (((RecipientType -eq 'MailUniversalDistributionGroup') -or (RecipientType -eq 'MailUniversalSecurityGroup') -or (RecipientType -eq 'MailNonUniversalGroup') -or (RecipientType -eq 'DynamicDistributionGroup'))) -or (((RecipientType -eq 'UserMailbox') -and (ResourceMetaData -like 'ResourceType:*') -and (ResourceSearchProperties -ne )))))))  -and (-not(RecipientTypeDetailsValue -eq 'GuestMailUser')))")

        # endregion

        $cleaned = $ExpandedFilter

        foreach ($pattern in $patterns)
        {
            $cleaned = [regex]::Replace($cleaned, $pattern, '', 'IgnoreCase')
        }

        # Normalize whitespace
        $cleaned = $cleaned -replace '\s{2,}', ' '

        # Trim outer parentheses if they wrap the whole expression
        $trimmed = $cleaned.Trim()
        if ($trimmed.StartsWith('(') -and $trimmed.EndsWith(')'))
        {
            # Check parentheses balance before trimming
            $open = 0
            $balanced = $true
            for ($i = 0; $i -lt $trimmed.Length; $i++)
            {
                switch ($trimmed[$i])
                {
                    '(' { $open++ }
                    ')' { $open-- }
                }

                if ($open -lt 0)
                {
                    $balanced = $false
                    break
                }
            }
            if ($balanced -and $open -eq 0)
            {
                # Remove only one outer layer of parentheses
                $trimmed = $trimmed.Substring(1, $trimmed.Length - 2).Trim()
            }
        }

        return $trimmed
    }

    hidden static [System.String] RemoveMailTipHtml([System.String] $Value)
    {
        if ([System.String]::IsNullOrEmpty($Value))
        {
            return $Value
        }

        return $Value -replace '(?is)<html>\s*<body>\s*(.*?)\s*</body>\s*</html>\s*', '$1'
    }

    hidden static [System.String] ToExchangeFilterSyntax([System.String] $Expression)
    {
        # Always add one final outer wrapper
        return '(' + [EXODynamicDistributionGroup]::NormalizeFilterExpression($Expression) + ')'
    }

    hidden static [System.String] NormalizeFilterExpression([System.String] $Expression)
    {
        # Trim outer spaces and redundant parentheses
        $expression = $Expression.Trim()
        while ($expression.StartsWith('(') -and $expression.EndsWith(')'))
        {
            $inner = $expression.Substring(1, $expression.Length - 2).Trim()
            $balance = 0
            $valid = $true
            foreach ($ch in $inner.ToCharArray())
            {
                if ($ch -eq '(')
                {
                    $balance++
                }
                elseif ($ch -eq ')')
                {
                    $balance--
                }

                if ($balance -lt 0)
                {
                    $valid = $false
                    break
                }
            }

            if (-not $valid -or $balance -ne 0)
            {
                break
            }
            $expression = $inner
        }

        # Parse into tokens considering nested parentheses
        $tokens = [System.Collections.Generic.List[string]]::new()
        $current = ''
        $depth = 0
        for ($i = 0; $i -lt $expression.Length; $i++)
        {
            $ch = $expression[$i]
            if ($ch -eq '(')
            {
                $depth++
                $current += $ch
            }
            elseif ($ch -eq ')')
            {
                $depth--
                $current += $ch
            }
            elseif ($depth -eq 0 -and $expression.Substring($i) -match '^-or\s|^-and\s')
            {
                # Split at top-level logical operator
                $match = $matches[0].Trim()
                $tokens.Add(($current.Trim()))
                $tokens.Add($match)
                $current = ''
                $i += $match.Length - 1
            }
            else
            {
                $current += $ch
            }
        }
        if ($current.Trim())
        {
            $tokens.Add(($current.Trim()))
        }

        # Base condition - no logical operators
        if ($tokens.Count -eq 1)
        {
            return $tokens[0]
        }

        # Handle operator precedence: -and before -or
        # First handle all -and operations
        for ($i = 0; $i -lt $tokens.Count; $i++)
        {
            if ($tokens[$i] -eq '-and')
            {
                $left = [EXODynamicDistributionGroup]::NormalizeFilterExpression($tokens[$i - 1])
                $right = [EXODynamicDistributionGroup]::NormalizeFilterExpression($tokens[$i + 1])
                $tokens[$i - 1] = "(($left) -and ($right))"
                $tokens.RemoveAt($i)    # remove operator
                $tokens.RemoveAt($i)    # remove right operand
                $i--
            }
        }

        # Then handle -or operations
        for ($i = 0; $i -lt $tokens.Count; $i++)
        {
            if ($tokens[$i] -eq '-or')
            {
                $left = [EXODynamicDistributionGroup]::NormalizeFilterExpression($tokens[$i - 1])
                $right = [EXODynamicDistributionGroup]::NormalizeFilterExpression($tokens[$i + 1])
                $tokens[$i - 1] = "(($left) -or ($right))"
                $tokens.RemoveAt($i)
                $tokens.RemoveAt($i)
                $i--
            }
        }

        return $tokens[0]
    }

    hidden [EXODynamicDistributionGroup] AsResult([System.Object] $Values)
    {
        if ($Values -is [EXODynamicDistributionGroup])
        {
            return $Values
        }

        $result = [EXODynamicDistributionGroup]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
