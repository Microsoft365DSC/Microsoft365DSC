using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class EXODistributionGroup : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The Identity parameter specifies the distribution group or mail-enabled security group that you want to modify. You can use any value that uniquely identifies the group.')]
    [System.String] $Identity

    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('The Name parameter specifies a unique name for the address list.')]
    [System.String] $Name

    [DscProperty()]
    [System.ComponentModel.Description('Exchange alias (also known as the mail nickname) for the recipient')]
    [System.String] $Alias

    [DscProperty()]
    [System.ComponentModel.Description('Is Bcc blocked for the distribution group.')]
    [System.Nullable[System.Boolean]] $BccBlocked

    [DscProperty()]
    [System.ComponentModel.Description('The BypassModerationFromSendersOrMembers parameter specifies who is allowed to send messages to this moderated recipient without approval from a moderator. Valid values for this parameter are individual senders and groups in your organization. Specifying a group means all members of the group are allowed to send messages to this recipient without approval from a moderator.')]
    [System.String[]] $BypassModerationFromSendersOrMembers

    [DscProperty()]
    [System.ComponentModel.Description('The ByPassNestedModerationEnabled parameter specifies how to handle message approval when a moderated group contains other moderated groups as members.')]
    [System.Nullable[System.Boolean]] $BypassNestedModerationEnabled

    [DscProperty()]
    [System.ComponentModel.Description('Description of the distribution group.')]
    [System.String] $Description

    [DscProperty()]
    [System.ComponentModel.Description('The DisplayName parameter specifies the display name of the group. The display name is visible in the Exchange admin center and in address lists. The maximum length is 256 characters.')]
    [System.String] $DisplayName

    [DscProperty()]
    [System.ComponentModel.Description('The HiddenGroupMembershipEnabled switch specifies whether to hide the members of the distribution group from members of the group and users who aren''t members of the group.')]
    [System.Nullable[System.Boolean]] $HiddenGroupMembershipEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The ManagedBy parameter specifies an owner for the group. A group must have at least one owner.')]
    [System.String[]] $ManagedBy

    [DscProperty()]
    [System.ComponentModel.Description('The MemberDepartRestriction parameter specifies the restrictions that you put on requests to leave the group. Valid values are: Open & Closed')]
    [ValidateSet('Open', 'Closed')]
    [System.String] $MemberDepartRestriction

    [DscProperty()]
    [System.ComponentModel.Description('The MemberJoinRestriction parameter specifies the restrictions that you put on requests to join the group. Valid values are: Open, Closed & ApprovalRequired')]
    [ValidateSet('Open', 'Closed', 'ApprovalRequired')]
    [System.String] $MemberJoinRestriction

    [DscProperty()]
    [System.ComponentModel.Description('The Members parameter specifies the recipients (mail-enabled objects) that are members of the group. You can use any value that uniquely identifies the recipient.')]
    [System.String[]] $Members

    [DscProperty()]
    [System.ComponentModel.Description('The ModeratedBy parameter specifies one or more moderators for this group. A moderator approves messages sent to the group before the messages are delivered. A moderator must be a mailbox, mail user, or mail contact in your organization. You can use any value that uniquely identifies the moderator.')]
    [System.String[]] $ModeratedBy

    [DscProperty()]
    [System.ComponentModel.Description('The ModerationEnabled parameter specifies whether moderation is enabled for this recipient.')]
    [System.Nullable[System.Boolean]] $ModerationEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The OrganizationalUnit parameter specifies the location in Active Directory where the group is created.')]
    [System.String] $OrganizationalUnit

    [DscProperty()]
    [System.ComponentModel.Description('The PrimarySmtpAddress parameter specifies the primary return email address that''s used for the recipient.')]
    [System.String] $PrimarySmtpAddress

    [DscProperty()]
    [System.ComponentModel.Description('The RequireSenderAuthenticationEnabled parameter specifies whether to accept messages only from authenticated (internal) senders.')]
    [System.Nullable[System.Boolean]] $RequireSenderAuthenticationEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The RoomList switch specifies that all members of this distribution group are room mailboxes. You don''t need to specify a value with this switch.')]
    [System.Nullable[System.Boolean]] $RoomList

    [DscProperty()]
    [System.ComponentModel.Description('The AcceptMessagesOnlyFrom parameter specifies who is allowed to send messages to this recipient. Messages from other senders are rejected.')]
    [System.String[]] $AcceptMessagesOnlyFrom

    [DscProperty()]
    [System.ComponentModel.Description('The AcceptMessagesOnlyFromDLMembers parameter specifies who is allowed to send messages to this recipient. Messages from other senders are rejected.')]
    [System.String[]] $AcceptMessagesOnlyFromDLMembers

    [DscProperty()]
    [System.ComponentModel.Description('The AcceptMessagesOnlyFromSendersOrMembers parameter specifies who is allowed to send messages to this recipient. Messages from other senders are rejected.')]
    [System.String[]] $AcceptMessagesOnlyFromSendersOrMembers

    [DscProperty()]
    [System.ComponentModel.Description('This parameter specifies a value for the CustomAttribute1 property on the recipient. You can use this property to store custom information about the recipient, and to identify the recipient in filters. The maximum length is 1024 characters. If the value contains spaces, enclose the value in quotation marks.')]
    [System.String] $CustomAttribute1

    [DscProperty()]
    [System.ComponentModel.Description('This parameter specifies a value for the CustomAttribute2 property on the recipient. You can use this property to store custom information about the recipient, and to identify the recipient in filters. The maximum length is 1024 characters. If the value contains spaces, enclose the value in quotation marks.')]
    [System.String] $CustomAttribute2

    [DscProperty()]
    [System.ComponentModel.Description('This parameter specifies a value for the CustomAttribute3 property on the recipient. You can use this property to store custom information about the recipient, and to identify the recipient in filters. The maximum length is 1024 characters. If the value contains spaces, enclose the value in quotation marks.')]
    [System.String] $CustomAttribute3

    [DscProperty()]
    [System.ComponentModel.Description('This parameter specifies a value for the CustomAttribute4 property on the recipient. You can use this property to store custom information about the recipient, and to identify the recipient in filters. The maximum length is 1024 characters. If the value contains spaces, enclose the value in quotation marks.')]
    [System.String] $CustomAttribute4

    [DscProperty()]
    [System.ComponentModel.Description('This parameter specifies a value for the CustomAttribute5 property on the recipient. You can use this property to store custom information about the recipient, and to identify the recipient in filters. The maximum length is 1024 characters. If the value contains spaces, enclose the value in quotation marks.')]
    [System.String] $CustomAttribute5

    [DscProperty()]
    [System.ComponentModel.Description('This parameter specifies a value for the CustomAttribute6 property on the recipient. You can use this property to store custom information about the recipient, and to identify the recipient in filters. The maximum length is 1024 characters. If the value contains spaces, enclose the value in quotation marks.')]
    [System.String] $CustomAttribute6

    [DscProperty()]
    [System.ComponentModel.Description('This parameter specifies a value for the CustomAttribute7 property on the recipient. You can use this property to store custom information about the recipient, and to identify the recipient in filters. The maximum length is 1024 characters. If the value contains spaces, enclose the value in quotation marks.')]
    [System.String] $CustomAttribute7

    [DscProperty()]
    [System.ComponentModel.Description('This parameter specifies a value for the CustomAttribute8 property on the recipient. You can use this property to store custom information about the recipient, and to identify the recipient in filters. The maximum length is 1024 characters. If the value contains spaces, enclose the value in quotation marks.')]
    [System.String] $CustomAttribute8

    [DscProperty()]
    [System.ComponentModel.Description('This parameter specifies a value for the CustomAttribute9 property on the recipient. You can use this property to store custom information about the recipient, and to identify the recipient in filters. The maximum length is 1024 characters. If the value contains spaces, enclose the value in quotation marks.')]
    [System.String] $CustomAttribute9

    [DscProperty()]
    [System.ComponentModel.Description('This parameter specifies a value for the CustomAttribute10 property on the recipient. You can use this property to store custom information about the recipient, and to identify the recipient in filters. The maximum length is 1024 characters. If the value contains spaces, enclose the value in quotation marks.')]
    [System.String] $CustomAttribute10

    [DscProperty()]
    [System.ComponentModel.Description('This parameter specifies a value for the CustomAttribute11 property on the recipient. You can use this property to store custom information about the recipient, and to identify the recipient in filters. The maximum length is 1024 characters. If the value contains spaces, enclose the value in quotation marks.')]
    [System.String] $CustomAttribute11

    [DscProperty()]
    [System.ComponentModel.Description('This parameter specifies a value for the CustomAttribute12 property on the recipient. You can use this property to store custom information about the recipient, and to identify the recipient in filters. The maximum length is 1024 characters. If the value contains spaces, enclose the value in quotation marks.')]
    [System.String] $CustomAttribute12

    [DscProperty()]
    [System.ComponentModel.Description('This parameter specifies a value for the CustomAttribute13 property on the recipient. You can use this property to store custom information about the recipient, and to identify the recipient in filters. The maximum length is 1024 characters. If the value contains spaces, enclose the value in quotation marks.')]
    [System.String] $CustomAttribute13

    [DscProperty()]
    [System.ComponentModel.Description('This parameter specifies a value for the CustomAttribute14 property on the recipient. You can use this property to store custom information about the recipient, and to identify the recipient in filters. The maximum length is 1024 characters. If the value contains spaces, enclose the value in quotation marks.')]
    [System.String] $CustomAttribute14

    [DscProperty()]
    [System.ComponentModel.Description('This parameter specifies a value for the CustomAttribute15 property on the recipient. You can use this property to store custom information about the recipient, and to identify the recipient in filters. The maximum length is 1024 characters. If the value contains spaces, enclose the value in quotation marks.')]
    [System.String] $CustomAttribute15

    [DscProperty()]
    [System.ComponentModel.Description('The EmailAddresses parameter specifies all email addresses (proxy addresses) for the recipient, including the primary SMTP address. In on-premises Exchange organizations, the primary SMTP address and other proxy addresses are typically set by email address policies. However, you can use this parameter to configure other proxy addresses for the recipient.')]
    [System.String[]] $EmailAddresses

    [DscProperty()]
    [System.ComponentModel.Description('The GrantSendOnBehalfTo parameter specifies who can send on behalf of this group. Although messages send on behalf of the group clearly show the sender in the From field (<Sender> on behalf of <Group>), replies to these messages are delivered to the group, not the sender.')]
    [System.String[]] $GrantSendOnBehalfTo

    [DscProperty()]
    [System.ComponentModel.Description('The HiddenFromAddressListsEnabled parameter specifies whether this recipient is visible in address lists.')]
    [System.Nullable[System.Boolean]] $HiddenFromAddressListsEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The SendOofMessageToOriginatorEnabled parameter specifies how to handle out of office (OOF) messages for members of the group.')]
    [System.Nullable[System.Boolean]] $SendOofMessageToOriginatorEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The SendModerationNotifications parameter specifies when moderation notification messages are sent. Valid values are: Always, Internal, Never.')]
    [ValidateSet('Always', 'Internal', 'Never')]
    [System.String] $SendModerationNotifications

    [DscProperty()]
    [System.ComponentModel.Description('The Type parameter specifies the type of group that you want to create. Valid values are: Distribution, Security')]
    [ValidateSet('Distribution', 'Security')]
    [System.String] $Type

    [DscProperty()]
    [System.ComponentModel.Description('Specifies if this AddressList should exist.')]
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

    EXODistributionGroup() : base()
    {
        $this.ResourceCache['displayNameProperties'] = @{
            IncludeAcceptMessagesOnlyFromDLMembersWithDisplayNames        = $true
            IncludeAcceptMessagesOnlyFromSendersOrMembersWithDisplayNames = $true
            IncludeAcceptMessagesOnlyFromWithDisplayNames                 = $true
            IncludeBypassModerationFromSendersOrMembersWithDisplayNames   = $true
            IncludeGrantSendOnBehalfToWithDisplayNames                    = $true
            IncludeManagedByWithDisplayNames                              = $true
            IncludeModeratedByWithDisplayNames                            = $true
        }
    }

    [EXODistributionGroup] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [EXODistributionGroup]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of Distribution Group for $($this.Identity)"

        $boundParameters = $this.GetBoundParameters()

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.Name -ne $this.Name)
            {
                $null = $this.Connect('ExchangeOnline')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullReturn = $boundParameters
                $nullReturn.Ensure = 'Absent'

                $displayNameProperties = $this.ResourceCache['displayNameProperties']
                if (-not [System.String]::IsNullOrEmpty($this.PrimarySmtpAddress))
                {
                    $distributionGroup = Get-DistributionGroup -Identity $this.PrimarySmtpAddress @displayNameProperties -ErrorAction SilentlyContinue
                }
                else
                {
                    $distributionGroup = Get-DistributionGroup -Identity $this.Identity @displayNameProperties -ErrorAction SilentlyContinue
                }

                if ($null -eq $distributionGroup)
                {
                    Write-Verbose -Message "Distribution Group $($this.Identity) does not exist."
                    return $this.AsResult($nullReturn)
                }
            }
            else
            {
                $distributionGroup = $this.ExportedInstance
            }

            Write-Verbose -Message "Getting Distribution Group members for $($this.Identity)"
            if (-not [System.String]::IsNullOrEmpty($this.PrimarySmtpAddress))
            {
                $distributionGroupMembers = Get-DistributionGroupMember -Identity $this.PrimarySmtpAddress `
                    -ErrorAction 'Stop' `
                    -ResultSize 'Unlimited'
            }
            else
            {
                $distributionGroupMembers = Get-DistributionGroupMember -Identity $this.Identity `
                    -ErrorAction 'Stop' `
                    -ResultSize 'Unlimited'
            }

            $distributionMembersValue = @()
            foreach ($member in $distributionGroupMembers)
            {
                if (-not [System.String]::IsNullOrEmpty($member.PrimarySmtpAddress))
                {
                    $distributionMembersValue += $member.PrimarySmtpAddress
                }
                else
                {
                    # For RecipientType 'User', PrimarySmtpAddress is unavailable, but WindowsLiveID is, and works with Add-DistributionGroupMember
                    $distributionMembersValue += $member.WindowsLiveID
                }
            }

            Write-Verbose -Message "Found existing Distribution Group {$($this.Identity)}."
            $descriptionValue = $null
            if ($distributionGroup.Description.Length -gt 0)
            {
                $descriptionValue = $distributionGroup.Description[0].Replace("`r", '').Replace("`n", '')
            }

            $groupTypeValue = 'Distribution'
            if (([System.String[]]$distributionGroup.GroupType.Replace(' ', '').Split(',')).Contains('SecurityEnabled'))
            {
                $groupTypeValue = 'Security'
            }

            $acceptMessagesOnlyFromValue = $this.GetDisplayNameSimplified($distributionGroup.AcceptMessagesOnlyFromWithDisplayNames)
            $acceptMessagesOnlyFromDlMembersValue = $this.GetDisplayNameSimplified($distributionGroup.AcceptMessagesOnlyFromDLMembersWithDisplayNames)
            $acceptMessagesOnlyFromSendersOrMembersValue = $this.GetDisplayNameSimplified($distributionGroup.AcceptMessagesOnlyFromSendersOrMembersWithDisplayNames)
            $bypassModerationFromSendersOrMembersValue = $this.GetDisplayNameSimplified($distributionGroup.BypassModerationFromSendersOrMembersWithDisplayNames)
            $grantSendOnBehalfToValue = $this.GetDisplayNameSimplified($distributionGroup.GrantSendOnBehalfToWithDisplayNames)
            $managedByValue = $this.GetDisplayNameSimplified($distributionGroup.ManagedByWithDisplayName)
            $moderatedByValue = $this.GetDisplayNameSimplified($distributionGroup.ModeratedByWithDisplayNames)

            $result = @{
                Identity                               = $distributionGroup.Identity
                Alias                                  = $distributionGroup.Alias
                BccBlocked                             = $distributionGroup.BccBlocked
                BypassModerationFromSendersOrMembers   = $bypassModerationFromSendersOrMembersValue
                BypassNestedModerationEnabled          = $distributionGroup.BypassNestedModerationEnabled
                Description                            = $descriptionValue
                DisplayName                            = $distributionGroup.DisplayName
                HiddenGroupMembershipEnabled           = $distributionGroup.HiddenGroupMembershipEnabled
                ManagedBy                              = $managedByValue
                MemberDepartRestriction                = $distributionGroup.MemberDepartRestriction
                MemberJoinRestriction                  = $distributionGroup.MemberJoinRestriction
                Members                                = $distributionMembersValue
                ModeratedBy                            = $moderatedByValue
                ModerationEnabled                      = $distributionGroup.ModerationEnabled
                Name                                   = $distributionGroup.Name
                OrganizationalUnit                     = $distributionGroup.OrganizationalUnit
                PrimarySmtpAddress                     = $distributionGroup.PrimarySmtpAddress
                RequireSenderAuthenticationEnabled     = $distributionGroup.RequireSenderAuthenticationEnabled
                RoomList                               = $distributionGroup.RecipientTypeDetails -eq 'RoomList'
                SendModerationNotifications            = $distributionGroup.SendModerationNotifications
                AcceptMessagesOnlyFrom                 = $acceptMessagesOnlyFromValue
                AcceptMessagesOnlyFromDLMembers        = $acceptMessagesOnlyFromDlMembersValue
                AcceptMessagesOnlyFromSendersOrMembers = $acceptMessagesOnlyFromSendersOrMembersValue
                CustomAttribute1                       = $distributionGroup.CustomAttribute1
                CustomAttribute2                       = $distributionGroup.CustomAttribute2
                CustomAttribute3                       = $distributionGroup.CustomAttribute3
                CustomAttribute4                       = $distributionGroup.CustomAttribute4
                CustomAttribute5                       = $distributionGroup.CustomAttribute5
                CustomAttribute6                       = $distributionGroup.CustomAttribute6
                CustomAttribute7                       = $distributionGroup.CustomAttribute7
                CustomAttribute8                       = $distributionGroup.CustomAttribute8
                CustomAttribute9                       = $distributionGroup.CustomAttribute9
                CustomAttribute10                      = $distributionGroup.CustomAttribute10
                CustomAttribute11                      = $distributionGroup.CustomAttribute11
                CustomAttribute12                      = $distributionGroup.CustomAttribute12
                CustomAttribute13                      = $distributionGroup.CustomAttribute13
                CustomAttribute14                      = $distributionGroup.CustomAttribute14
                CustomAttribute15                      = $distributionGroup.CustomAttribute15
                EmailAddresses                         = [System.String[]]$distributionGroup.EmailAddresses
                GrantSendOnBehalfTo                    = $grantSendOnBehalfToValue
                HiddenFromAddressListsEnabled          = [Boolean]$distributionGroup.HiddenFromAddressListsEnabled
                SendOofMessageToOriginatorEnabled      = [Boolean]$distributionGroup.SendOofMessageToOriginatorEnabled
                Type                                   = $groupTypeValue
                Ensure                                 = 'Present'
                Credential                             = $this.Credential
                ApplicationId                          = $this.ApplicationId
                CertificateThumbprint                  = $this.CertificateThumbprint
                CertificatePath                        = $this.CertificatePath
                CertificatePassword                    = $this.CertificatePassword
                ManagedIdentity                        = $this.ManagedIdentity
                TenantId                               = $this.TenantId
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

        Write-Verbose -Message "Setting configuration of Distribution Group for $($this.Identity)"

        $boundParameters = $this.GetBoundParameters()

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $currentDistributionGroup = $this.Get().ToHashtable()

        $currentParameters = Remove-M365DSCAuthenticationParameter -BoundParameters ([Hashtable]$boundParameters).Clone()

        # Distribution group doesn't exist but it should
        $newGroup = $null
        if ($this.Ensure -eq 'Present' -and $currentDistributionGroup.Ensure -eq 'Absent')
        {
            $createParameters = Remove-M365DSCAuthenticationParameter -BoundParameters ([Hashtable]$boundParameters).Clone()
            Write-Verbose -Message "The Distribution Group {$($this.Identity)} does not exist but it should. Creating it."
            $createParameters.Remove('Identity') | Out-Null
            $createParameters.Remove('AcceptMessagesOnlyFrom') | Out-Null
            $createParameters.Remove('AcceptMessagesOnlyFromSendersOrMembers') | Out-Null
            $createParameters.Remove('CustomAttribute1') | Out-Null
            $createParameters.Remove('CustomAttribute2') | Out-Null
            $createParameters.Remove('CustomAttribute3') | Out-Null
            $createParameters.Remove('CustomAttribute4') | Out-Null
            $createParameters.Remove('CustomAttribute5') | Out-Null
            $createParameters.Remove('CustomAttribute6') | Out-Null
            $createParameters.Remove('CustomAttribute7') | Out-Null
            $createParameters.Remove('CustomAttribute8') | Out-Null
            $createParameters.Remove('CustomAttribute9') | Out-Null
            $createParameters.Remove('CustomAttribute10') | Out-Null
            $createParameters.Remove('CustomAttribute11') | Out-Null
            $createParameters.Remove('CustomAttribute12') | Out-Null
            $createParameters.Remove('CustomAttribute13') | Out-Null
            $createParameters.Remove('CustomAttribute14') | Out-Null
            $createParameters.Remove('CustomAttribute15') | Out-Null
            $createParameters.Remove('EmailAddresses') | Out-Null
            $createParameters.Remove('GrantSendOnBehalfTo') | Out-Null
            $createParameters.Remove('HiddenFromAddressListsEnabled') | Out-Null
            $createParameters.Remove('SendOofMessageToOriginatorEnabled') | Out-Null
            $createParameters.Remove('BypassModerationFromSendersOrMembers') | Out-Null
            $newGroup = New-DistributionGroup @createParameters
            $null = Wait-M365DSCCondition -Description "Distribution Group {$($newGroup.Identity)}" -ConsecutiveCount 2 -ScriptBlock {
                $null -ne (Get-DistributionGroup -Identity $newGroup.Identity -ErrorAction 'SilentlyContinue')
            }

            Write-Verbose -Message "New Distribution Group with Identity {$($newGroup.Identity)} was successfully created"
        }
        # Distribution group exists but shouldn't
        elseif ($this.Ensure -eq 'Absent' -and $currentDistributionGroup.Ensure -eq 'Present')
        {
            Write-Verbose -Message "The Distribution Group {$($this.Identity)} exists but shouldn't. Removing it."
            # Use the group identity value retrieved from Get(), in case we got the group using PrimarySmtpAddress
            Remove-DistributionGroup -Identity $currentDistributionGroup.Identity `
                -BypassSecurityGroupManagerCheck `
                -Confirm:$false
        }
        # Update even if we just created the group. There are properties that can only be set with the set- cmdlet.
        if ($this.Ensure -eq 'Present')
        {
            # If this is a newly created group, use the new group identity
            if ($null -ne $newGroup)
            {
                $currentParameters.Identity = $newGroup.Identity
            }
            # Otherwise, use the existing group identity (using the value retrieved from Get(), in the event that we got the group using PrimarySmtpAddress)
            else
            {
                $currentParameters.Identity = $currentDistributionGroup.Identity
            }

            $currentParameters.Remove('Type') | Out-Null
            Write-Verbose -Message "Updating Distribution Group {$($this.Identity)} with values: $(Convert-M365DscHashtableToString -Hashtable $currentParameters)"

            if ($null -ne $this.OrganizationalUnit -and $currentDistributionGroup.OrganizationalUnit -ne $this.OrganizationalUnit)
            {
                Write-Warning -Message 'Desired and current OrganizationalUnit values differ. This property cannot be updated once the distribution group has been created. Delete and recreate the distribution group to update the value.'
            }
            $currentParameters.Remove('OrganizationalUnit') | Out-Null
            $currentParameters.Remove('Type') | Out-Null

            # Members
            if ($null -ne $this.Members)
            {
                $membersDiff = Compare-Object -ReferenceObject $currentDistributionGroup.Members -DifferenceObject $this.Members
                $membersToAdd = @()
                $membersToRemove = @()
                foreach ($difference in $membersDiff)
                {
                    if ($difference.SideIndicator -eq '=>')
                    {
                        $membersToAdd += $difference.InputObject
                    }
                    elseif ($difference.SideIndicator -eq '<=')
                    {
                        $membersToRemove += $difference.InputObject
                    }
                }

                foreach ($member in $membersToAdd)
                {
                    Write-Verbose -Message "Adding member {$member}"
                    # Use the group identity value retrieved from Get(), in case we got the group using PrimarySmtpAddress
                    Add-DistributionGroupMember -Identity $currentParameters.Identity -Member $member -BypassSecurityGroupManagerCheck
                }
                foreach ($member in $membersToRemove)
                {
                    Write-Verbose -Message "Removing member {$member}"
                    # Use the group identity value retrieved from Get(), in case we got the group using PrimarySmtpAddress
                    Remove-DistributionGroupMember -Identity $currentParameters.Identity `
                        -Member $member `
                        -BypassSecurityGroupManagerCheck `
                        -Confirm:$false
                }
                $currentParameters.Remove('Members') | Out-Null
            }

            if ($this.EmailAddresses.Length -gt 0)
            {
                $currentParameters.Remove('PrimarySmtpAddress') | Out-Null
            }

            if ($this.AcceptMessagesOnlyFrom.Length -gt 0)
            {
                $currentParameters.Remove('AcceptMessagesOnlyFromDLMembers') | Out-Null
                $currentParameters.Remove('AcceptMessagesOnlyFromSendersOrMembers') | Out-Null
            }
            Set-DistributionGroup @currentParameters -BypassSecurityGroupManagerCheck
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
            $displayNameProperties = $this.ResourceCache['displayNameProperties']
            [array] $exportedInstances = Get-DistributionGroup @displayNameProperties -ResultSize 'Unlimited' -ErrorAction Stop

            $i = 1
            if ($exportedInstances.Length -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }

            $dscContent = [System.Text.StringBuilder]::new()
            foreach ($distributionGroup in $exportedInstances)
            {
                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }

                Write-M365DSCHost -Message "    |---[$i/$($exportedInstances.Count)] $($distributionGroup.Identity)" -DeferWrite
                $params = @{
                    Identity              = $distributionGroup.Identity
                    PrimarySmtpAddress    = $distributionGroup.PrimarySmtpAddress
                    Name                  = $distributionGroup.Name
                    Credential            = $this.Credential
                    ApplicationId         = $this.ApplicationId
                    TenantId              = $this.TenantId
                    CertificateThumbprint = $this.CertificateThumbprint
                    CertificatePassword   = $this.CertificatePassword
                    ManagedIdentity       = $this.ManagedIdentity
                    CertificatePath       = $this.CertificatePath
                    AccessTokens          = $this.AccessTokens
                }
                $this.ExportedInstance = $distributionGroup
                $Results = $this.GetForExport($Params)
                if ($Results.AcceptMessagesOnlyFromSendersOrMembers.Length -eq 0)
                {
                    $Results.Remove('AcceptMessagesOnlyFromSendersOrMembers') | Out-Null
                }

                if ($Results.AcceptMessagesOnlyFrom.Length -eq 0)
                {
                    $Results.Remove('AcceptMessagesOnlyFrom') | Out-Null
                }

                if ($Results.AcceptMessagesOnlyFromDLMembers.Length -eq 0)
                {
                    $Results.Remove('AcceptMessagesOnlyFromDLMembers') | Out-Null
                }

                $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                    -ConnectionMode $ConnectionMode `
                    -ModulePath $this.GetModulePath() `
                    -Results $Results `
                    -Credential $this.Credential
                [void]$dscContent.Append($currentDSCBlock)

                Save-M365DSCPartialExport -Content $currentDSCBlock `
                    -FileName $Global:PartialExportFileName
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
                $i ++
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
                if (-not $ValuesToCheck.OrganizationalUnit)
                {
                    $ValuesToCheck.Remove('OrganizationalUnit') | Out-Null
                }

                if ([M365DSCResourceBase]::IsReportContext($PostProcessingArgs))
                {
                    return [System.Tuple[Hashtable, Hashtable, Hashtable]]::new($DesiredValues, $CurrentValues, $ValuesToCheck)
                }

                foreach ($key in $PostProcessingArgs[0])
                {
                    $key = $key.Replace("Include", "").Replace("WithDisplayNames", "").Replace("WithDisplayName", "")
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

    hidden [System.String[]] GetDisplayNameSimplified([System.String[]] $DisplayNames)
    {
        $simplifiedNames = @()
        foreach ($currentName in $DisplayNames)
        {
            if ([System.String]::IsNullOrEmpty($currentName))
            {
                continue
            }
            $simplifiedNames += $currentName.Split(',')[0].Replace('(','')
        }
        return @($simplifiedNames | Sort-Object)
    }

    hidden [EXODistributionGroup] AsResult([System.Object] $Values)
    {
        if ($Values -is [EXODistributionGroup])
        {
            return $Values
        }

        $result = [EXODistributionGroup]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
