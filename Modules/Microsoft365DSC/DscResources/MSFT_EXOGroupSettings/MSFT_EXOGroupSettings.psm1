using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class EXOGroupSettings : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The DisplayName parameter specifies the name of the Microsoft 365 Group. The display name is visible in the Exchange admin center, address lists, and Outlook. The maximum length is 64 characters.')]
    [System.String] $DisplayName

    [DscProperty()]
    [System.ComponentModel.Description('The unique Id of the group')]
    [System.String] $Id

    [DscProperty()]
    [System.ComponentModel.Description('The AcceptMessagesOnlyFromSendersOrMembers parameter specifies who is allowed to send messages to this recipient. Messages from other senders are rejected.')]
    [System.String[]] $AcceptMessagesOnlyFromSendersOrMembers

    [DscProperty()]
    [System.ComponentModel.Description('Private')]
    [ValidateSet('Public', 'Private')]
    [System.String] $AccessType

    [DscProperty()]
    [System.ComponentModel.Description('The AlwaysSubscribeMembersToCalendarEvents switch controls the default subscription settings of new members that are added to the Microsoft 365 Group. Changing this setting doesn''t affect existing group members.')]
    [System.Nullable[System.Boolean]] $AlwaysSubscribeMembersToCalendarEvents

    [DscProperty()]
    [System.ComponentModel.Description('The AlwaysSubscribeMembersToCalendarEvents switch controls the default subscription settings of new members that are added to the Microsoft 365 Group. Changing this setting doesn''t affect existing group members.')]
    [System.String] $AuditLogAgeLimit

    [DscProperty()]
    [System.ComponentModel.Description('The AutoSubscribeNewMembers switch specifies whether to automatically subscribe new members that are added to the Microsoft 365 Group to conversations and calendar events. Only users that are added to the group after you enable this setting are automatically subscribed to the group.')]
    [System.Nullable[System.Boolean]] $AutoSubscribeNewMembers

    [DscProperty()]
    [System.ComponentModel.Description('The CalendarMemberReadOnly parameter specifies whether to set read-only Calendar permissions to the Microsoft 365 Group for members of the group.')]
    [System.Nullable[System.Boolean]] $CalendarMemberReadOnly

    [DscProperty()]
    [System.ComponentModel.Description('The CalendarMemberReadOnly switch specifies whether to set read-only Calendar permissions to the Microsoft 365 Group for members of the group.')]
    [System.String] $Classification

    [DscProperty()]
    [System.ComponentModel.Description('The CalendarMemberReadOnly switch specifies whether to set read-only Calendar permissions to the Microsoft 365 Group for members of the group.')]
    [System.Nullable[System.Boolean]] $ConnectorsEnabled

    [DscProperty()]
    [System.ComponentModel.Description('This parameter specifies a value for the CustomAttribute1 property on the recipient. You can use this property to store custom information about the recipient, and to identify the recipient in filters. The maximum length is 1024 characters.')]
    [System.String] $CustomAttribute1

    [DscProperty()]
    [System.ComponentModel.Description('This parameter specifies a value for the CustomAttribute2 property on the recipient. You can use this property to store custom information about the recipient, and to identify the recipient in filters. The maximum length is 1024 characters.')]
    [System.String] $CustomAttribute2

    [DscProperty()]
    [System.ComponentModel.Description('This parameter specifies a value for the CustomAttribute3 property on the recipient. You can use this property to store custom information about the recipient, and to identify the recipient in filters. The maximum length is 1024 characters.')]
    [System.String] $CustomAttribute3

    [DscProperty()]
    [System.ComponentModel.Description('This parameter specifies a value for the CustomAttribute4 property on the recipient. You can use this property to store custom information about the recipient, and to identify the recipient in filters. The maximum length is 1024 characters.')]
    [System.String] $CustomAttribute4

    [DscProperty()]
    [System.ComponentModel.Description('This parameter specifies a value for the CustomAttribute5 property on the recipient. You can use this property to store custom information about the recipient, and to identify the recipient in filters. The maximum length is 1024 characters.')]
    [System.String] $CustomAttribute5

    [DscProperty()]
    [System.ComponentModel.Description('This parameter specifies a value for the CustomAttribute6 property on the recipient. You can use this property to store custom information about the recipient, and to identify the recipient in filters. The maximum length is 1024 characters.')]
    [System.String] $CustomAttribute6

    [DscProperty()]
    [System.ComponentModel.Description('This parameter specifies a value for the CustomAttribute7 property on the recipient. You can use this property to store custom information about the recipient, and to identify the recipient in filters. The maximum length is 1024 characters.')]
    [System.String] $CustomAttribute7

    [DscProperty()]
    [System.ComponentModel.Description('This parameter specifies a value for the CustomAttribute8 property on the recipient. You can use this property to store custom information about the recipient, and to identify the recipient in filters. The maximum length is 1024 characters.')]
    [System.String] $CustomAttribute8

    [DscProperty()]
    [System.ComponentModel.Description('This parameter specifies a value for the CustomAttribute9 property on the recipient. You can use this property to store custom information about the recipient, and to identify the recipient in filters. The maximum length is 1024 characters.')]
    [System.String] $CustomAttribute9

    [DscProperty()]
    [System.ComponentModel.Description('This parameter specifies a value for the CustomAttribute10 property on the recipient. You can use this property to store custom information about the recipient, and to identify the recipient in filters. The maximum length is 1024 characters.')]
    [System.String] $CustomAttribute10

    [DscProperty()]
    [System.ComponentModel.Description('This parameter specifies a value for the CustomAttribute11 property on the recipient. You can use this property to store custom information about the recipient, and to identify the recipient in filters. The maximum length is 1024 characters.')]
    [System.String] $CustomAttribute11

    [DscProperty()]
    [System.ComponentModel.Description('This parameter specifies a value for the CustomAttribute12 property on the recipient. You can use this property to store custom information about the recipient, and to identify the recipient in filters. The maximum length is 1024 characters.')]
    [System.String] $CustomAttribute12

    [DscProperty()]
    [System.ComponentModel.Description('This parameter specifies a value for the CustomAttribute13 property on the recipient. You can use this property to store custom information about the recipient, and to identify the recipient in filters. The maximum length is 1024 characters.')]
    [System.String] $CustomAttribute13

    [DscProperty()]
    [System.ComponentModel.Description('This parameter specifies a value for the CustomAttribute14 property on the recipient. You can use this property to store custom information about the recipient, and to identify the recipient in filters. The maximum length is 1024 characters.')]
    [System.String] $CustomAttribute14

    [DscProperty()]
    [System.ComponentModel.Description('This parameter specifies a value for the CustomAttribute15 property on the recipient. You can use this property to store custom information about the recipient, and to identify the recipient in filters. The maximum length is 1024 characters.')]
    [System.String] $CustomAttribute15

    [DscProperty()]
    [System.ComponentModel.Description('The DataEncryptionPolicy parameter specifies the data encryption policy that''s applied to the Microsoft 365 Group. ')]
    [System.String] $DataEncryptionPolicy

    [DscProperty()]
    [System.ComponentModel.Description('The EmailAddresses parameter specifies all the email addresses (proxy addresses) for the recipient, including the primary SMTP address.')]
    [System.String[]] $EmailAddresses

    [DscProperty()]
    [System.ComponentModel.Description('This parameter specifies a value for the ExtensionCustomAttribute1 property on the recipient. You can use this property to store custom information about the recipient, and to identify the recipient in filters. You can specify up to 1300 values separated by commas.')]
    [System.String[]] $ExtensionCustomAttribute1

    [DscProperty()]
    [System.ComponentModel.Description('This parameter specifies a value for the ExtensionCustomAttribute2 property on the recipient. You can use this property to store custom information about the recipient, and to identify the recipient in filters. You can specify up to 1300 values separated by commas.')]
    [System.String[]] $ExtensionCustomAttribute2

    [DscProperty()]
    [System.ComponentModel.Description('This parameter specifies a value for the ExtensionCustomAttribute3 property on the recipient. You can use this property to store custom information about the recipient, and to identify the recipient in filters. You can specify up to 1300 values separated by commas.')]
    [System.String[]] $ExtensionCustomAttribute3

    [DscProperty()]
    [System.ComponentModel.Description('This parameter specifies a value for the ExtensionCustomAttribute4 property on the recipient. You can use this property to store custom information about the recipient, and to identify the recipient in filters. You can specify up to 1300 values separated by commas.')]
    [System.String[]] $ExtensionCustomAttribute4

    [DscProperty()]
    [System.ComponentModel.Description('This parameter specifies a value for the ExtensionCustomAttribute5 property on the recipient. You can use this property to store custom information about the recipient, and to identify the recipient in filters. You can specify up to 1300 values separated by commas.')]
    [System.String[]] $ExtensionCustomAttribute5

    [DscProperty()]
    [System.ComponentModel.Description('The GrantSendOnBehalfTo parameter specifies who can send on behalf of this Microsoft 365 Group.')]
    [System.String[]] $GrantSendOnBehalfTo

    [DscProperty()]
    [System.ComponentModel.Description('The GrantSendOnBehalfTo parameter specifies who can send on behalf of this Microsoft 365 Group.')]
    [System.Nullable[System.Boolean]] $HiddenFromAddressListsEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The HiddenFromExchangeClientsEnabled switch specifies whether the Microsoft 365 Group is hidden from Outlook clients connected to Microsoft 365.')]
    [System.Nullable[System.Boolean]] $HiddenFromExchangeClientsEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The InformationBarrierMode parameter specifies the information barrier mode for the Microsoft 365 Group.')]
    [ValidateSet('Explicit', 'Implicit', 'Open', 'OwnerModerated')]
    [System.String] $InformationBarrierMode

    [DscProperty()]
    [System.ComponentModel.Description('This parameter specifies whether or not members are allow to edit content.')]
    [System.Nullable[System.Boolean]] $IsMemberAllowedToEditContent

    [DscProperty()]
    [System.ComponentModel.Description('The Language parameter specifies language preference for the Microsoft 365 Group.')]
    [System.String] $Language

    [DscProperty()]
    [System.ComponentModel.Description('The MailboxRegion parameter specifies the preferred data location (PDL) for the Microsoft 365 Group in multi-geo environments.')]
    [System.String] $MailboxRegion

    [DscProperty()]
    [System.ComponentModel.Description('The MailTip parameter specifies the custom MailTip text for this recipient. The MailTip is shown to senders when they start drafting an email message to this recipient. ')]
    [System.String] $MailTip

    [DscProperty()]
    [System.ComponentModel.Description('The MailTipTranslations parameter specifies additional languages for the custom MailTip text that''s defined by the MailTip parameter.')]
    [System.String[]] $MailTipTranslations

    [DscProperty()]
    [System.ComponentModel.Description('The MaxReceiveSize parameter specifies the maximum size of an email message that can be sent to this group. Messages that exceed the maximum size are rejected by the group.')]
    [System.String] $MaxReceiveSize

    [DscProperty()]
    [System.ComponentModel.Description('The MaxSendSize parameter specifies the maximum size of an email message that can be sent by this group.')]
    [System.String] $MaxSendSize

    [DscProperty()]
    [System.ComponentModel.Description('The ModeratedBy parameter specifies one or more moderators for this recipient. A moderator approves messages sent to the recipient before the messages are delivered. A moderator must be a mailbox, mail user, or mail contact in your organization. You can use any value that uniquely identifies the moderator. ')]
    [System.String[]] $ModeratedBy

    [DscProperty()]
    [System.ComponentModel.Description('The ModerationEnabled parameter specifies whether moderation is enabled for this recipient.')]
    [System.Nullable[System.Boolean]] $ModerationEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The Notes parameter specifies the description of the Microsoft 365 Group. If the value contains spaces, enclose the value in quotation marks.')]
    [System.String] $Notes

    [DscProperty()]
    [System.ComponentModel.Description('The PrimarySmtpAddress parameter specifies the primary return email address that''s used for the recipient. You can''t use the EmailAddresses and PrimarySmtpAddress parameters in the same command.')]
    [System.String] $PrimarySmtpAddress

    [DscProperty()]
    [System.ComponentModel.Description('The RejectMessagesFromSendersOrMembers parameter specifies who isn''t allowed to send messages to this recipient. Messages from these senders are rejected.')]
    [System.String[]] $RejectMessagesFromSendersOrMembers

    [DscProperty()]
    [System.ComponentModel.Description('The RequireSenderAuthenticationEnabled parameter specifies whether to accept messages only from authenticated (internal) senders. ')]
    [System.Nullable[System.Boolean]] $RequireSenderAuthenticationEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The SensitivityLabelId parameter specifies the GUID value of the sensitivity label that''s assigned to the Microsoft 365 Group.')]
    [System.String] $SensitivityLabelId

    [DscProperty()]
    [System.ComponentModel.Description('The SubscriptionEnabled switch specifies whether the group owners can enable subscription to conversations and calendar events on the groups they own. ')]
    [System.Nullable[System.Boolean]] $SubscriptionEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The WelcomeMessageEnabled switch specifies whether to enable or disable sending system-generated welcome messages to users who are added as members to the Microsoft 365 Group.')]
    [System.Nullable[System.Boolean]] $WelcomeMessageEnabled

    [DscProperty()]
    [System.ComponentModel.Description('Credentials of the Exchange Admin')]
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

    EXOGroupSettings() : base()
    {
        $this.ResourceCache['displayNameProperties'] = @{
            IncludeAcceptMessagesOnlyFromSendersOrMembersWithDisplayNames = $true
            IncludeGrantSendOnBehalfToWithDisplayNames                    = $true
            IncludeModeratedByWithDisplayNames                            = $true
            IncludeRejectMessagesFromSendersOrMembersWithDisplayNames     = $true
        }
    }

    [EXOGroupSettings] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [EXOGroupSettings]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of Office 365 Group Settings for $($this.DisplayName)"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.DisplayName -ne $this.DisplayName)
            {
                $null = $this.Connect('ExchangeOnline')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullReturn = @{
                    DisplayName = $this.DisplayName
                }

                Write-Verbose -Message "Retrieving group by id {$($this.Id)}"

                $displayNameProperties = $this.ResourceCache['displayNameProperties']
                $group = Get-UnifiedGroup -Identity $this.Id -IncludeAllProperties @displayNameProperties -ErrorAction SilentlyContinue
                if ($null -eq $group)
                {
                    Write-Verbose -Message "Couldn't retrieve group by ID. Trying by DisplayName {$($this.DisplayName)}"
                    $group = Get-UnifiedGroup -Identity $this.DisplayName -IncludeAllProperties @displayNameProperties -ErrorAction SilentlyContinue
                }

                if ($null -eq $group)
                {
                    Write-Verbose -Message "The specified group {$($this.DisplayName)} doesn't exist."
                    return $this.AsResult($nullReturn)
                }

                if ($group -is [array] -and $group.Count -gt 1)
                {
                    Write-Warning -Message "Multiple instances of a group named {$($this.DisplayName)} was discovered which could result in inconsistencies retrieving its values."
                    $group = $group[0]
                }
            }
            else
            {
                $group = $this.ExportedInstance
            }

            $ExtensionCustomAttribute1Value = $group.ExtensionCustomAttribute1
            if ($null -eq $group.ExtensionCustomAttribute1)
            {
                $ExtensionCustomAttribute1Value = @()
            }

            $ExtensionCustomAttribute2Value = $group.ExtensionCustomAttribute2
            if ($null -eq $group.ExtensionCustomAttribute2)
            {
                $ExtensionCustomAttribute2Value = @()
            }

            $ExtensionCustomAttribute3Value = $group.ExtensionCustomAttribute3
            if ($null -eq $group.ExtensionCustomAttribute3)
            {
                $ExtensionCustomAttribute3Value = @()
            }

            $ExtensionCustomAttribute4Value = $group.ExtensionCustomAttribute4
            if ($null -eq $group.ExtensionCustomAttribute4)
            {
                $ExtensionCustomAttribute4Value = @()
            }

            $ExtensionCustomAttribute5Value = $group.ExtensionCustomAttribute5
            if ($null -eq $group.ExtensionCustomAttribute5)
            {
                $ExtensionCustomAttribute5Value = @()
            }

            $GrantSendOnBehalfToValue = $this.GetDisplayNameSimplified($group.GrantSendOnBehalfToWithDisplayNames)
            if ($null -eq $group.GrantSendOnBehalfToWithDisplayNames)
            {
                $GrantSendOnBehalfToValue = @()
            }

            $ModeratedByValue = $this.GetDisplayNameSimplified($group.ModeratedByWithDisplayNames)
            if ($null -eq $group.ModeratedByWithDisplayNames)
            {
                $ModeratedByValue = @()
            }

            $AcceptMessagesOnlyFromSendersOrMembersValue = $this.GetDisplayNameSimplified($group.AcceptMessagesOnlyFromSendersOrMembersWithDisplayNames)
            if ($null -eq $group.AcceptMessagesOnlyFromSendersOrMembersWithDisplayNames)
            {
                $AcceptMessagesOnlyFromSendersOrMembersValue = @()
            }

            $MailTipTranslationsValue = $group.MailTipTranslations
            if ($null -eq $group.MailTipTranslations)
            {
                $MailTipTranslationsValue = @()
            }

            $RejectMessagesFromSendersOrMembersValue = $this.GetDisplayNameSimplified($group.RejectMessagesFromSendersOrMembersWithDisplayNames)
            if ($null -eq $group.RejectMessagesFromSendersOrMembersWithDisplayNames)
            {
                $RejectMessagesFromSendersOrMembersValue = @()
            }

            $result = @{
                DisplayName                            = $this.DisplayName
                Id                                     = $group.Id
                AcceptMessagesOnlyFromSendersOrMembers = $AcceptMessagesOnlyFromSendersOrMembersValue
                AccessType                             = $group.AccessType
                AlwaysSubscribeMembersToCalendarEvents = $group.AlwaysSubscribeMembersToCalendarEvents
                AuditLogAgeLimit                       = $group.AuditLogAgeLimit
                AutoSubscribeNewMembers                = $group.AutoSubscribeNewMembers
                CalendarMemberReadOnly                 = $group.CalendarMemberReadOnly
                Classification                         = $group.Classification
                ConnectorsEnabled                      = $group.ConnectorsEnabled
                CustomAttribute1                       = $group.CustomAttribute1
                CustomAttribute2                       = $group.CustomAttribute2
                CustomAttribute3                       = $group.CustomAttribute3
                CustomAttribute4                       = $group.CustomAttribute4
                CustomAttribute5                       = $group.CustomAttribute5
                CustomAttribute6                       = $group.CustomAttribute6
                CustomAttribute7                       = $group.CustomAttribute7
                CustomAttribute8                       = $group.CustomAttribute8
                CustomAttribute9                       = $group.CustomAttribute9
                CustomAttribute10                      = $group.CustomAttribute10
                CustomAttribute11                      = $group.CustomAttribute11
                CustomAttribute12                      = $group.CustomAttribute12
                CustomAttribute13                      = $group.CustomAttribute13
                CustomAttribute14                      = $group.CustomAttribute14
                CustomAttribute15                      = $group.CustomAttribute15
                DataEncryptionPolicy                   = $group.DataEncryptionPolicy
                EmailAddresses                         = $group.EmailAddresses
                ExtensionCustomAttribute1              = $ExtensionCustomAttribute1Value
                ExtensionCustomAttribute2              = $ExtensionCustomAttribute2Value
                ExtensionCustomAttribute3              = $ExtensionCustomAttribute3Value
                ExtensionCustomAttribute4              = $ExtensionCustomAttribute4Value
                ExtensionCustomAttribute5              = $ExtensionCustomAttribute5Value
                GrantSendOnBehalfTo                    = $GrantSendOnBehalfToValue
                HiddenFromAddressListsEnabled          = $group.HiddenFromAddressListsEnabled
                HiddenFromExchangeClientsEnabled       = $group.HiddenFromExchangeClientsEnabled
                InformationBarrierMode                 = $group.InformationBarrierMode
                IsMemberAllowedToEditContent           = $group.IsMemberAllowedToEditContent
                Language                               = $group.Language.Name
                MailboxRegion                          = $group.MailboxRegion
                MailTip                                = $group.MailTip
                MailTipTranslations                    = $MailTipTranslationsValue
                MaxReceiveSize                         = $group.MaxReceiveSize
                MaxSendSize                            = $group.MaxSendSize
                ModeratedBy                            = $ModeratedByValue
                ModerationEnabled                      = $group.ModerationEnabled
                Notes                                  = $group.Notes
                PrimarySmtpAddress                     = $group.PrimarySmtpAddress
                RejectMessagesFromSendersOrMembers     = $RejectMessagesFromSendersOrMembersValue
                RequireSenderAuthenticationEnabled     = $group.RequireSenderAuthenticationEnabled
                SensitivityLabelId                     = $group.SensitivityLabelId
                SubscriptionEnabled                    = $group.SubscriptionEnabled
                WelcomeMessageEnabled                  = $group.WelcomeMessageEnabled
                Credential                             = $this.Credential
                ApplicationId                          = $this.ApplicationId
                TenantId                               = $this.TenantId
                CertificateThumbprint                  = $this.CertificateThumbprint
                CertificatePath                        = $this.CertificatePath
                CertificatePassword                    = $this.CertificatePassword
                ManagedIdentity                        = $this.ManagedIdentity
                AccessTokens                           = $this.AccessTokens
            }

            return $this.AsResult($result)
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

        Write-Verbose -Message "Setting configuration of Office 365 group Settings for $($this.DisplayName)"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $CurrentValues = $this.Get().ToHashtable()

        $updateParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()
        $updateParameters.Add('Identity', $CurrentValues.Id)
        $updateParameters.Remove('Id') | Out-Null
        $updateParameters.Remove('DisplayName') | Out-Null

        # Cannot use PrimarySmtpAddress and EmailAddresses at the same time. If both are present, then give priority to PrimarySmtpAddress.
        if ($updateParameters.ContainsKey('PrimarySmtpAddress') -and $null -ne $updateParameters.PrimarySmtpAddress)
        {
            $updateParameters.Remove('EmailAddresses') | Out-Null
        }

        # Renaming of WelcomeMessageEnabled to UnifiedGroupWelcomeMessageEnabled
        if ($updateParameters.ContainsKey('WelcomeMessageEnabled'))
        {
            $updateParameters.Add('UnifiedGroupWelcomeMessageEnabled', $updateParameters.WelcomeMessageEnabled)
            $updateParameters.Remove('WelcomeMessageEnabled') | Out-Null
        }

        foreach ($key in $this.ResourceCache['displayNameProperties'].Keys)
        {
            $key = $key.Replace('Include', '').Replace('WithDisplayNames', '')
            if ($this.GetBoundParameters().ContainsKey($key))
            {
                $convertedList = [System.Collections.Generic.List[System.String]]::new()
                foreach ($member in $updateParameters.$key)
                {
                    # If member is a GUID, keep as-is
                    if ([System.Guid]::TryParse($member, [ref][System.Guid]::Empty))
                    {
                        $convertedList.Add($member)
                        continue
                    }

                    $entry = Get-Recipient -Identity $member
                    $convertedList.Add($entry.Name)
                }

                $updateParameters[$key] = $convertedList.ToArray()
            }
        }

        Set-UnifiedGroup @updateParameters
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
            $displayNameProperties = $this.ResourceCache['displayNameProperties']
            [array] $exportedInstances = Get-UnifiedGroup -ResultSize Unlimited @displayNameProperties -ErrorAction SilentlyContinue

            $i = 1
            if ($exportedInstances.Length -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message "`r`n"-DeferWrite
            }
            $dscContent = [System.Text.StringBuilder]::new()
            foreach ($group in $exportedInstances)
            {
                Write-M365DSCHost -Message "    |---[$i/$($exportedInstances.Length)] $($group.DisplayName)" -DeferWrite
                $groupName = $group.DisplayName
                if (-not [System.String]::IsNullOrEmpty($groupName))
                {
                    if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                    {
                        $Global:M365DSCExportResourceInstancesCount++
                    }

                    $Params = @{
                        Credential            = $this.Credential
                        DisplayName           = $groupName
                        Id                    = $group.Id
                        ApplicationId         = $this.ApplicationId
                        TenantId              = $this.TenantId
                        CertificateThumbprint = $this.CertificateThumbprint
                        CertificatePassword   = $this.CertificatePassword
                        ManagedIdentity       = $this.ManagedIdentity
                        CertificatePath       = $this.CertificatePath
                        AccessTokens          = $this.AccessTokens
                    }
                    $this.ExportedInstance = $group
                    $Results = $this.GetForExport($Params)
                    $rawResults = $Results.Clone()
                    if ($Results -is [System.Collections.Hashtable] -and $Results.Count -gt 1)
                    {
                        $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                            -ConnectionMode $ConnectionMode `
                            -ModulePath $this.GetModulePath() `
                            -Results $Results `
                            -Credential $this.Credential `
                            -RawResults $rawResults
                        [void]$dscContent.Append($currentDSCBlock)
                        Save-M365DSCPartialExport -Content $currentDSCBlock `
                            -FileName $Global:PartialExportFileName

                        Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
                    }
                    else
                    {
                        Write-M365DSCHost -Message $Global:M365DSCEmojiRedX -CommitWrite
                    }
                }
                $i++
            }
            return $dscContent.ToString()
        }
        catch
        {
            $this.LogError($_, 'Error during Export:')

            throw
        }
    }

    [System.Collections.Hashtable] GetCompareParameters()
    {
        return @{
            PostProcessing = {
                param($DesiredValues, $CurrentValues, $ValuesToCheck, $PostProcessingArgs)

                if ([M365DSCResourceBase]::IsReportContext($PostProcessingArgs))
                {
                    return [System.Tuple[Hashtable, Hashtable, Hashtable]]::new($DesiredValues, $CurrentValues, $ValuesToCheck)
                }

                foreach ($key in $PostProcessingArgs[0])
                {
                    $key = $key.Replace('Include', '').Replace('WithDisplayNames', '')
                    if ($DesiredValues.ContainsKey($key))
                    {
                        $convertedValues = @()
                        foreach ($member in $DesiredValues.$key)
                        {
                            if ([System.Guid]::TryParse($member, [ref][System.Guid]::Empty))
                            {
                                $entry = Get-Recipient -Identity $member
                                $convertedValues += $entry.PrimarySmtpAddress
                            }
                            else
                            {
                                $convertedValues += $member
                            }
                        }
                        $DesiredValues.$key = $convertedValues
                    }
                }
                return [System.Tuple[Hashtable, Hashtable, Hashtable]]::new($DesiredValues, $CurrentValues, $ValuesToCheck)
            }
            # Prevent array unrolling
            PostProcessingArgs = @(, [System.String[]] $this.ResourceCache['displayNameProperties'].Keys)
        }
    }

    hidden [System.String[]] GetDisplayNameSimplified([System.String[]] $DisplayName)
    {
        $simplifiedNames = @()
        foreach ($name in $DisplayName)
        {
            if ([System.String]::IsNullOrEmpty($name))
            {
                continue
            }
            $simplifiedNames += $name.Split(',')[0].Replace('(', '')
        }
        return @($simplifiedNames | Sort-Object)
    }

    hidden [EXOGroupSettings] AsResult([System.Object] $Values)
    {
        if ($Values -is [EXOGroupSettings])
        {
            return $Values
        }

        $result = [EXOGroupSettings]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
