using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class TeamsUserPolicyAssignment : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('User Principal Name of the user representing the policy assignments.')]
    [System.String] $User

    [DscProperty()]
    [System.ComponentModel.Description('Name of the Calling Line Policy.')]
    [System.String] $CallingLineIdentity

    [DscProperty()]
    [System.ComponentModel.Description('Name of the External Access Policy.')]
    [System.String] $ExternalAccessPolicy

    [DscProperty()]
    [System.ComponentModel.Description('Name of the Online Voicemail Policy.')]
    [System.String] $OnlineVoicemailPolicy

    [DscProperty()]
    [System.ComponentModel.Description('Name of the Online VOice Routing Policy.')]
    [System.String] $OnlineVoiceRoutingPolicy

    [DscProperty()]
    [System.ComponentModel.Description('Name of the Teams App Permission Policy.')]
    [System.String] $TeamsAppPermissionPolicy

    [DscProperty()]
    [System.ComponentModel.Description('Name of the Teams App Setup Policy.')]
    [System.String] $TeamsAppSetupPolicy

    [DscProperty()]
    [System.ComponentModel.Description('Name of the Teams Audio Conferencing Policy.')]
    [System.String] $TeamsAudioConferencingPolicy

    [DscProperty()]
    [System.ComponentModel.Description('Name of the Teams Call Hold Policy.')]
    [System.String] $TeamsCallHoldPolicy

    [DscProperty()]
    [System.ComponentModel.Description('Name of the Teams Calling Policy.')]
    [System.String] $TeamsCallingPolicy

    [DscProperty()]
    [System.ComponentModel.Description('Name of the Teams Call Park Policy.')]
    [System.String] $TeamsCallParkPolicy

    [DscProperty()]
    [System.ComponentModel.Description('Name of the Teams Channel Policy.')]
    [System.String] $TeamsChannelsPolicy

    [DscProperty()]
    [System.ComponentModel.Description('Name of the Teams Emergency Calling Policy.')]
    [System.String] $TeamsEmergencyCallingPolicy

    [DscProperty()]
    [System.ComponentModel.Description('Name of the Teams Emergency Call Routing Policy.')]
    [System.String] $TeamsEmergencyCallRoutingPolicy

    [DscProperty()]
    [System.ComponentModel.Description('Name of the Teams Enhanced Encryption Policy.')]
    [System.String] $TeamsEnhancedEncryptionPolicy

    [DscProperty()]
    [System.ComponentModel.Description('Name of the Teams Events Policy.')]
    [System.String] $TeamsEventsPolicy

    [DscProperty()]
    [System.ComponentModel.Description('Name of the Teams Meeting Broadcast Policy.')]
    [System.String] $TeamsMeetingBroadcastPolicy

    [DscProperty()]
    [System.ComponentModel.Description('Name of the Teams Meeting Policy.')]
    [System.String] $TeamsMeetingPolicy

    [DscProperty()]
    [System.ComponentModel.Description('Name of the Teams Messaging Policy.')]
    [System.String] $TeamsMessagingPolicy

    [DscProperty()]
    [System.ComponentModel.Description('Name of the Teams Mobility Policy.')]
    [System.String] $TeamsMobilityPolicy

    [DscProperty()]
    [System.ComponentModel.Description('Name of the Teams Personal Attendant Policy.')]
    [System.String] $TeamsPersonalAttendantPolicy

    [DscProperty()]
    [System.ComponentModel.Description('Name of the Teams Update Management Policy.')]
    [System.String] $TeamsUpdateManagementPolicy

    [DscProperty()]
    [System.ComponentModel.Description('Name of the Teams Upgrade Policy.')]
    [System.String] $TeamsUpgradePolicy

    [DscProperty()]
    [System.ComponentModel.Description('Name of the Tenant Dial Plan Policy.')]
    [System.String] $TenantDialPlan

    [DscProperty()]
    [System.ComponentModel.Description('Credentials of the Teams Admin')]
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

    [TeamsUserPolicyAssignment] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [TeamsUserPolicyAssignment]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration for Teams User Policy Assignment for user $($this.User)"

        try
        {
            if (-not $this.ResourceCache['exportMode'])
            {
                $null = $this.Connect('MicrosoftTeams')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')
            }

            $assignmentErrors = $null
            $assignment = Get-CsUserPolicyAssignment -Identity $this.User -ErrorAction SilentlyContinue -ErrorVariable assignmentErrors
            if ($assignmentErrors.Count -gt 0)
            {
                Write-Verbose -Message "User {$($this.User)} not found for Teams User Policy Assignment"
                return $this.AsResult($null)
            }

            if ($null -eq $assignment -and $this.ResourceCache['exportMode'])
            {
                Write-Verbose -Message "User {$($this.User)} has no Teams User Policy Assignment to export"
                return $this.AsResult($null)
            }

            $CallingLineIdentityValue = ($assignment | Where-Object -FilterScript { $_.PolicyType -eq 'CallingLineIdentity' }).PolicyName
            if ([System.String]::IsNullOrEmpty($CallingLineIdentityValue))
            {
                $CallingLineIdentityValue = 'Global'
            }

            $ExternalAccessPolicyValue = ($assignment | Where-Object -FilterScript { $_.PolicyType -eq 'ExternalAccessPolicy' }).PolicyName
            if ([System.String]::IsNullOrEmpty($ExternalAccessPolicyValue))
            {
                $ExternalAccessPolicyValue = 'Global'
            }

            $OnlineVoicemailPolicyValue = ($assignment | Where-Object -FilterScript { $_.PolicyType -eq 'OnlineVoicemailPolicy' }).PolicyName
            if ([System.String]::IsNullOrEmpty($OnlineVoicemailPolicyValue))
            {
                $OnlineVoicemailPolicyValue = 'Global'
            }

            $OnlineVoiceRoutingPolicyValue = ($assignment | Where-Object -FilterScript { $_.PolicyType -eq 'OnlineVoiceRoutingPolicy' }).PolicyName
            if ([System.String]::IsNullOrEmpty($OnlineVoiceRoutingPolicyValue))
            {
                $OnlineVoiceRoutingPolicyValue = 'Global'
            }

            $TeamsAppPermissionPolicyValue = ($assignment | Where-Object -FilterScript { $_.PolicyType -eq 'TeamsAppPermissionPolicy' }).PolicyName
            if ([System.String]::IsNullOrEmpty($TeamsAppPermissionPolicyValue))
            {
                $TeamsAppPermissionPolicyValue = 'Global'
            }

            $TeamsAppSetupPolicyValue = ($assignment | Where-Object -FilterScript { $_.PolicyType -eq 'TeamsAppSetupPolicy' }).PolicyName
            if ([System.String]::IsNullOrEmpty($TeamsAppSetupPolicyValue))
            {
                $TeamsAppSetupPolicyValue = 'Global'
            }

            $TeamsAudioConferencingPolicyValue = ($assignment | Where-Object -FilterScript { $_.PolicyType -eq 'TeamsAudioConferencingPolicy' }).PolicyName
            if ([System.String]::IsNullOrEmpty($TeamsAudioConferencingPolicyValue))
            {
                $TeamsAudioConferencingPolicyValue = 'Global'
            }

            $TeamsCallHoldPolicyValue = ($assignment | Where-Object -FilterScript { $_.PolicyType -eq 'TeamsCallHoldPolicy' }).PolicyName
            if ([System.String]::IsNullOrEmpty($TeamsCallHoldPolicyValue))
            {
                $TeamsCallHoldPolicyValue = 'Global'
            }

            $TeamsCallingPolicyValue = ($assignment | Where-Object -FilterScript { $_.PolicyType -eq 'TeamsCallingPolicy' }).PolicyName
            if ([System.String]::IsNullOrEmpty($TeamsCallingPolicyValue))
            {
                $TeamsCallingPolicyValue = 'Global'
            }

            $TeamsCallParkPolicyValue = ($assignment | Where-Object -FilterScript { $_.PolicyType -eq 'TeamsCallParkPolicy' }).PolicyName
            if ([System.String]::IsNullOrEmpty($TeamsCallParkPolicyValue))
            {
                $TeamsCallParkPolicyValue = 'Global'
            }

            $TeamsChannelsPolicyValue = ($assignment | Where-Object -FilterScript { $_.PolicyType -eq 'TeamsChannelsPolicy' }).PolicyName
            if ([System.String]::IsNullOrEmpty($TeamsChannelsPolicyValue))
            {
                $TeamsChannelsPolicyValue = 'Global'
            }

            $TeamsEmergencyCallingPolicyValue = ($assignment | Where-Object -FilterScript { $_.PolicyType -eq 'TeamsEmergencyCallingPolicy' }).PolicyName
            if ([System.String]::IsNullOrEmpty($TeamsEmergencyCallingPolicyValue))
            {
                $TeamsEmergencyCallingPolicyValue = 'Global'
            }

            $TeamsEmergencyCallRoutingPolicyValue = ($assignment | Where-Object -FilterScript { $_.PolicyType -eq 'TeamsEmergencyCallRoutingPolicy' }).PolicyName
            if ([System.String]::IsNullOrEmpty($TeamsEmergencyCallRoutingPolicyValue))
            {
                $TeamsEmergencyCallRoutingPolicyValue = 'Global'
            }

            $TeamsEnhancedEncryptionPolicyValue = ($assignment | Where-Object -FilterScript { $_.PolicyType -eq 'TeamsEnhancedEncryptionPolicy' }).PolicyName
            if ([System.String]::IsNullOrEmpty($TeamsEnhancedEncryptionPolicyValue))
            {
                $TeamsEnhancedEncryptionPolicyValue = 'Global'
            }

            $TeamsEventsPolicyValue = ($assignment | Where-Object -FilterScript { $_.PolicyType -eq 'TeamsEventsPolicy' }).PolicyName
            if ([System.String]::IsNullOrEmpty($TeamsEventsPolicyValue))
            {
                $TeamsEventsPolicyValue = 'Global'
            }

            $TeamsMeetingBroadcastPolicyValue = ($assignment | Where-Object -FilterScript { $_.PolicyType -eq 'TeamsMeetingBroadcastPolicy' }).PolicyName
            if ([System.String]::IsNullOrEmpty($TeamsMeetingBroadcastPolicyValue))
            {
                $TeamsMeetingBroadcastPolicyValue = 'Global'
            }

            $TeamsMeetingPolicyValue = ($assignment | Where-Object -FilterScript { $_.PolicyType -eq 'TeamsMeetingPolicy' }).PolicyName
            if ([System.String]::IsNullOrEmpty($TeamsMeetingPolicyValue))
            {
                $TeamsMeetingPolicyValue = 'Global'
            }

            $TeamsMessagingPolicyValue = ($assignment | Where-Object -FilterScript { $_.PolicyType -eq 'TeamsMessagingPolicy' }).PolicyName
            if ([System.String]::IsNullOrEmpty($TeamsMessagingPolicyValue))
            {
                $TeamsMessagingPolicyValue = 'Global'
            }

            $TeamsMobilityPolicyValue = ($assignment | Where-Object -FilterScript { $_.PolicyType -eq 'TeamsMobilityPolicy' }).PolicyName
            if ([System.String]::IsNullOrEmpty($TeamsMobilityPolicyValue))
            {
                $TeamsMobilityPolicyValue = 'Global'
            }

            $TeamsPersonalAttendantPolicyValue = ($assignment | Where-Object -FilterScript { $_.PolicyType -eq 'TeamsPersonalAttendantPolicy' }).PolicyName
            if ([System.String]::IsNullOrEmpty($TeamsPersonalAttendantPolicyValue))
            {
                $TeamsPersonalAttendantPolicyValue = 'Global'
            }

            $TeamsUpdateManagementPolicyValue = ($assignment | Where-Object -FilterScript { $_.PolicyType -eq 'TeamsUpdateManagementPolicy' }).PolicyName
            if ([System.String]::IsNullOrEmpty($TeamsUpdateManagementPolicyValue))
            {
                $TeamsUpdateManagementPolicyValue = 'Global'
            }

            $TeamsUpgradePolicyValue = ($assignment | Where-Object -FilterScript { $_.PolicyType -eq 'TeamsUpgradePolicy' }).PolicyName
            if ([System.String]::IsNullOrEmpty($TeamsUpgradePolicyValue))
            {
                $TeamsUpgradePolicyValue = 'Global'
            }

            $TenantDialPlanValue = ($assignment | Where-Object -FilterScript { $_.PolicyType -eq 'TenantDialPlan' }).PolicyName
            if ([System.String]::IsNullOrEmpty($TenantDialPlanValue))
            {
                $TenantDialPlanValue = 'Global'
            }

            Write-Verbose -Message "Found Policy Assignment for user {$($this.User)}"
            return $this.AsResult(@{
                User                            = $this.User
                CallingLineIdentity             = $CallingLineIdentityValue
                ExternalAccessPolicy            = $ExternalAccessPolicyValue
                OnlineVoicemailPolicy           = $OnlineVoicemailPolicyValue
                OnlineVoiceRoutingPolicy        = $OnlineVoiceRoutingPolicyValue
                TeamsAppPermissionPolicy        = $TeamsAppPermissionPolicyValue
                TeamsAppSetupPolicy             = $TeamsAppSetupPolicyValue
                TeamsAudioConferencingPolicy    = $TeamsAudioConferencingPolicyValue
                TeamsCallHoldPolicy             = $TeamsCallHoldPolicyValue
                TeamsCallingPolicy              = $TeamsCallingPolicyValue
                TeamsCallParkPolicy             = $TeamsCallParkPolicyValue
                TeamsChannelsPolicy             = $TeamsChannelsPolicyValue
                TeamsEmergencyCallingPolicy     = $TeamsEmergencyCallingPolicyValue
                TeamsEmergencyCallRoutingPolicy = $TeamsEmergencyCallRoutingPolicyValue
                TeamsEnhancedEncryptionPolicy   = $TeamsEnhancedEncryptionPolicyValue
                TeamsEventsPolicy               = $TeamsEventsPolicyValue
                TeamsMeetingBroadcastPolicy     = $TeamsMeetingBroadcastPolicyValue
                TeamsMeetingPolicy              = $TeamsMeetingPolicyValue
                TeamsMessagingPolicy            = $TeamsMessagingPolicyValue
                TeamsMobilityPolicy             = $TeamsMobilityPolicyValue
                TeamsPersonalAttendantPolicy    = $TeamsPersonalAttendantPolicyValue
                TeamsUpdateManagementPolicy     = $TeamsUpdateManagementPolicyValue
                TeamsUpgradePolicy              = $TeamsUpgradePolicyValue
                TenantDialPlan                  = $TenantDialPlanValue
                Credential                      = $this.Credential
                ApplicationId                   = $this.ApplicationId
                TenantId                        = $this.TenantId
                CertificateThumbprint           = $this.CertificateThumbprint
                CertificatePath                 = $this.CertificatePath
                CertificatePassword             = $this.CertificatePassword
                ManagedIdentity                 = $this.ManagedIdentity
                AccessTokens                    = $this.AccessTokens
            })
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

        Write-Verbose -Message "Setting configuration for Teams User Policy Assignment for user $($this.User)"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $currentInstance = $this.Get().ToHashtable()
        try
        {
            if ($null -ne $this.CallingLineIdentity -and $this.CallingLineIdentity -ne $currentInstance.CallingLineIdentity)
            {
                Write-Verbose -Message "Assigning the Call Line Identity Policy {$($this.CallingLineIdentity)} to user {$($this.User)}"
                $policyName = $this.CallingLineIdentity
                if ($policyName -eq 'Global')
                {
                    $policyName = $null
                }
                Grant-CsCallingLineIdentity -Identity $this.User -PolicyName $policyName | Out-Null
            }
            if ($null -ne $this.ExternalAccessPolicy -and $this.ExternalAccessPolicy -ne $currentInstance.ExternalAccessPolicy)
            {
                Write-Verbose -Message "Assigning the External Access Policy {$($this.ExternalAccessPolicy)} to user {$($this.User)}"
                $policyName = $this.ExternalAccessPolicy
                if ($policyName -eq 'Global')
                {
                    $policyName = $null
                }
                Grant-CsExternalAccessPolicy -Identity $this.User -PolicyName $policyName | Out-Null
            }
            if ($null -ne $this.OnlineVoicemailPolicy -and $this.OnlineVoicemailPolicy -ne $currentInstance.OnlineVoicemailPolicy)
            {
                Write-Verbose -Message "Assigning the Online Voicemail Policy {$($this.OnlineVoicemailPolicy)} to user {$($this.User)}"
                $policyName = $this.OnlineVoicemailPolicy
                if ($policyName -eq 'Global')
                {
                    $policyName = $null
                }
                Grant-CsOnlineVoicemailPolicy -Identity $this.User -PolicyName $policyName | Out-Null
            }
            if ($null -ne $this.OnlineVoiceRoutingPolicy -and $this.OnlineVoiceRoutingPolicy -ne $currentInstance.OnlineVoiceRoutingPolicy)
            {
                Write-Verbose -Message "Assigning the Online Voice Routing Policy {$($this.OnlineVoiceRoutingPolicy)} to user {$($this.User)}"
                $policyName = $this.OnlineVoiceRoutingPolicy
                if ($policyName -eq 'Global')
                {
                    $policyName = $null
                }
                Grant-CsOnlineVoiceRoutingPolicy -Identity $this.User -PolicyName $policyName | Out-Null
            }
            if ($null -ne $this.TeamsAppPermissionPolicy -and $this.TeamsAppPermissionPolicy -ne $currentInstance.TeamsAppPermissionPolicy)
            {
                Write-Verbose -Message "Assigning the Apps Permission Policy {$($this.TeamsAppPermissionPolicy)} to user {$($this.User)}"
                $policyName = $this.TeamsAppPermissionPolicy
                if ($policyName -eq 'Global')
                {
                    $policyName = $null
                }
                Grant-CsTeamsAppPermissionPolicy -Identity $this.User -PolicyName $policyName | Out-Null
            }
            if ($null -ne $this.TeamsAppSetupPolicy -and $this.TeamsAppSetupPolicy -ne $currentInstance.TeamsAppSetupPolicy)
            {
                Write-Verbose -Message "Assigning the Apps Setup Policy {$($this.TeamsAppSetupPolicy)} to user {$($this.User)}"
                $policyName = $this.TeamsAppSetupPolicy
                if ($policyName -eq 'Global')
                {
                    $policyName = $null
                }
                Grant-CsTeamsAppSetupPolicy -Identity $this.User -PolicyName $policyName | Out-Null
            }
            if ($null -ne $this.TeamsAudioConferencingPolicy -and $this.TeamsAudioConferencingPolicy -ne $currentInstance.TeamsAudioConferencingPolicy)
            {
                Write-Verbose -Message "Assigning the Audio COnferencing Policy {$($this.TeamsAudioConferencingPolicy)} to user {$($this.User)}"
                $policyName = $this.TeamsAudioConferencingPolicy
                if ($policyName -eq 'Global')
                {
                    $policyName = $null
                }
                Grant-CsTeamsAudioConferencingPolicy -Identity $this.User -PolicyName $policyName | Out-Null
            }
            if ($null -ne $this.TeamsCallHoldPolicy -and $this.TeamsCallHoldPolicy -ne $currentInstance.TeamsCallHoldPolicy)
            {
                Write-Verbose -Message "Assigning the Call Hold Policy {$($this.TeamsCallHoldPolicy)} to user {$($this.User)}"
                $policyName = $this.TeamsCallHoldPolicy
                if ($policyName -eq 'Global')
                {
                    $policyName = $null
                }
                Grant-CsTeamsCallHoldPolicy -Identity $this.User -PolicyName $policyName | Out-Null
            }
            if ($null -ne $this.TeamsCallingPolicy -and $this.TeamsCallingPolicy -ne $currentInstance.TeamsCallingPolicy)
            {
                Write-Verbose -Message "Assigning the Calling Policy {$($this.TeamsCallingPolicy)} to user {$($this.User)}"
                $policyName = $this.TeamsCallingPolicy
                if ($policyName -eq 'Global')
                {
                    $policyName = $null
                }
                Grant-CsTeamsCallingPolicy -Identity $this.User -PolicyName $policyName | Out-Null
            }
            if ($null -ne $this.TeamsCallParkPolicy -and $this.TeamsCallParkPolicy -ne $currentInstance.TeamsCallParkPolicy)
            {
                Write-Verbose -Message "Assigning the Call Park Policy {$($this.TeamsCallParkPolicy)} to user {$($this.User)}"
                $policyName = $this.TeamsCallParkPolicy
                if ($policyName -eq 'Global')
                {
                    $policyName = $null
                }
                Grant-CsTeamsCallParkPolicy -Identity $this.User -PolicyName $policyName | Out-Null
            }
            if ($null -ne $this.TeamsChannelsPolicy -and $this.TeamsChannelsPolicy -ne $currentInstance.TeamsChannelsPolicy)
            {
                Write-Verbose -Message "Assigning the Channels Policy {$($this.TeamsChannelsPolicy)} to user {$($this.User)}"
                $policyName = $this.TeamsChannelsPolicy
                if ($policyName -eq 'Global')
                {
                    $policyName = $null
                }
                Grant-CsTeamsChannelsPolicy -Identity $this.User -PolicyName $policyName | Out-Null
            }
            if ($null -ne $this.TeamsEmergencyCallingPolicy -and $this.TeamsEmergencyCallingPolicy -ne $currentInstance.TeamsEmergencyCallingPolicy)
            {
                Write-Verbose -Message "Assigning the Emergency Calling Policy {$($this.TeamsEmergencyCallingPolicy)} to user {$($this.User)}"
                $policyName = $this.TeamsEmergencyCallingPolicy
                if ($policyName -eq 'Global')
                {
                    $policyName = $null
                }
                Grant-CsTeamsEmergencyCallingPolicy -Identity $this.User -PolicyName $policyName | Out-Null
            }
            if ($null -ne $this.TeamsEmergencyCallRoutingPolicy -and $this.TeamsEmergencyCallRoutingPolicy -ne $currentInstance.TeamsEmergencyCallRoutingPolicy)
            {
                Write-Verbose -Message "Assigning the Emergency Call Routing Policy {$($this.TeamsEmergencyCallRoutingPolicy)} to user {$($this.User)}"
                $policyName = $this.TeamsEmergencyCallRoutingPolicy
                if ($policyName -eq 'Global')
                {
                    $policyName = $null
                }
                Grant-CsTeamsEmergencyCallRoutingPolicy -Identity $this.User -PolicyName $policyName | Out-Null
            }
            if ($null -ne $this.TeamsEnhancedEncryptionPolicy -and $this.TeamsEnhancedEncryptionPolicy -ne $currentInstance.TeamsEnhancedEncryptionPolicy)
            {
                Write-Verbose -Message "Assigning the Enhanced Encryption Policy {$($this.TeamsEnhancedEncryptionPolicy)} to user {$($this.User)}"
                $policyName = $this.TeamsEnhancedEncryptionPolicy
                if ($policyName -eq 'Global')
                {
                    $policyName = $null
                }
                Grant-CsTeamsEnhancedEncryptionPolicy -Identity $this.User -PolicyName $policyName | Out-Null
            }
            if ($null -ne $this.TeamsEventsPolicy -and $this.TeamsEventsPolicy -ne $currentInstance.TeamsEventsPolicy)
            {
                Write-Verbose -Message "Assigning the Events Policy {$($this.TeamsEventsPolicy)} to user {$($this.User)}"
                $policyName = $this.TeamsEventsPolicy
                if ($policyName -eq 'Global')
                {
                    $policyName = $null
                }
                Grant-CsTeamsEventsPolicy -Identity $this.User -PolicyName $policyName | Out-Null
            }
            if ($null -ne $this.TeamsMeetingBroadcastPolicy -and $this.TeamsMeetingBroadcastPolicy -ne $currentInstance.TeamsMeetingBroadcastPolicy)
            {
                Write-Verbose -Message "Assigning the Meeting Broadcast Policy {$($this.TeamsMeetingBroadcastPolicy)} to user {$($this.User)}"
                $policyName = $this.TeamsMeetingBroadcastPolicy
                if ($policyName -eq 'Global')
                {
                    $policyName = $null
                }
                Grant-CsTeamsMeetingBroadcastPolicy -Identity $this.User -PolicyName $policyName | Out-Null
            }
            if ($null -ne $this.TeamsMeetingPolicy -and $this.TeamsMeetingPolicy -ne $currentInstance.TeamsMeetingPolicy)
            {
                Write-Verbose -Message "Assigning the Meeting Policy {$($this.TeamsMeetingPolicy)} to user {$($this.User)}"
                $policyName = $this.TeamsMeetingPolicy
                if ($policyName -eq 'Global')
                {
                    $policyName = $null
                }
                Grant-CsTeamsMeetingPolicy -Identity $this.User -PolicyName $policyName | Out-Null
            }
            if ($null -ne $this.TeamsMessagingPolicy -and $this.TeamsMessagingPolicy -ne $currentInstance.TeamsMessagingPolicy)
            {
                Write-Verbose -Message "Assigning the Messaging Policy {$($this.TeamsMessagingPolicy)} to user {$($this.User)}"
                $policyName = $this.TeamsMessagingPolicy
                if ($policyName -eq 'Global')
                {
                    $policyName = $null
                }
                Grant-CsTeamsMessagingPolicy -Identity $this.User -PolicyName $policyName | Out-Null
            }
            if ($null -ne $this.TeamsMobilityPolicy -and $this.TeamsMobilityPolicy -ne $currentInstance.TeamsMobilityPolicy)
            {
                Write-Verbose -Message "Assigning the Mobility Policy {$($this.TeamsMobilityPolicy)} to user {$($this.User)}"
                $policyName = $this.TeamsMobilityPolicy
                if ($policyName -eq 'Global')
                {
                    $policyName = $null
                }
                Grant-CsTeamsMobilityPolicy -Identity $this.User -PolicyName $policyName | Out-Null
            }
            if ($null -ne $this.TeamsPersonalAttendantPolicy -and $this.TeamsPersonalAttendantPolicy -ne $currentInstance.TeamsPersonalAttendantPolicy)
            {
                Write-Verbose -Message "Assigning the Personal Attendant Policy {$($this.TeamsPersonalAttendantPolicy)} to user {$($this.User)}"
                $policyName = $this.TeamsPersonalAttendantPolicy
                if ($policyName -eq 'Global')
                {
                    $policyName = $null
                }
                Grant-CsTeamsPersonalAttendantPolicy -Identity $this.User -PolicyName $policyName | Out-Null
            }
            if ($null -ne $this.TeamsUpdateManagementPolicy -and $this.TeamsUpdateManagementPolicy -ne $currentInstance.TeamsUpdateManagementPolicy)
            {
                Write-Verbose -Message "Assigning the Update Management Policy {$($this.TeamsUpdateManagementPolicy)} to user {$($this.User)}"
                $policyName = $this.TeamsUpdateManagementPolicy
                if ($policyName -eq 'Global')
                {
                    $policyName = $null
                }
                Grant-CsTeamsUpdateManagementPolicy -Identity $this.User -PolicyName $policyName | Out-Null
            }
            if ($null -ne $this.TeamsUpgradePolicy -and $this.TeamsUpgradePolicy -ne $currentInstance.TeamsUpgradePolicy)
            {
                Write-Verbose -Message "Assigning the Upgrade Policy {$($this.TeamsUpgradePolicy)} to user {$($this.User)}"
                $policyName = $this.TeamsUpgradePolicy
                if ($policyName -eq 'Global')
                {
                    $policyName = $null
                }
                Grant-CsTeamsUpgradePolicy -Identity $this.User -PolicyName $policyName | Out-Null
            }
            if ($null -ne $this.TenantDialPlan -and $this.TenantDialPlan -ne $currentInstance.TenantDialPlan)
            {
                Write-Verbose -Message "Assigning the Tenant Dial Plan {$($this.TenantDialPlan)} to user {$($this.User)}"
                $policyName = $this.TenantDialPlan
                if ($policyName -eq 'Global')
                {
                    $policyName = $null
                }
                Grant-CsTenantDialPlan -Identity $this.User -PolicyName $policyName | Out-Null
            }
        }
        catch
        {
            Write-Verbose -Message "Error: $($_.Exception.Message)"
            $this.LogError($_, "Error while setting Policy Assignment for User {$($this.User)}")
            throw $_
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
        $ConnectionMode = $this.Connect('MicrosoftGraph')

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Export')

        try
        {
            [array]$users = Get-MgUser -All
            if ($users.Length -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }
            $dscContent = [System.Text.StringBuilder]::new()
            $j = 1
            $totalCount = $users.Length
            $this.ResourceCache['exportMode'] = $true
            foreach ($user in $users)
            {
                if ($null -eq $totalCount)
                {
                    $totalCount = 1
                }
                Write-M365DSCHost -Message "    |---[$j/$totalCount] Policy Assignment(s) for user {$($user.UserPrincipalName)}" -DeferWrite
                $getParams = @{
                    User                  = $user.UserPrincipalName
                    Credential            = $this.Credential
                    ApplicationId         = $this.ApplicationId
                    TenantId              = $this.TenantId
                    CertificateThumbprint = $this.CertificateThumbprint
                    CertificatePath       = $this.CertificatePath
                    CertificatePassword   = $this.CertificatePassword
                    ManagedIdentity       = $this.ManagedIdentity
                    AccessTokens          = $this.AccessTokens
                }
                $results = $this.GetForExport($getParams)
                $rawResults = $Results.Clone()

                if ($null -ne $results -and -not [System.String]::IsNullOrEmpty($results.User))
                {
                    if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                    {
                        $Global:M365DSCExportResourceInstancesCount++
                    }

                    $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                        -ConnectionMode $ConnectionMode `
                        -ModulePath $this.GetModulePath() `
                        -Results $Results `
                        -Credential $this.Credential `
                        -RawResults $rawResults
                    [void]$dscContent.Append($currentDSCBlock)
                    Save-M365DSCPartialExport -Content $currentDSCBlock `
                        -FileName $Global:PartialExportFileName
                }
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite

                $j++
            }
            return $dscContent.ToString()
        }
        catch
        {
            $this.LogError($_, 'Error during Export:')

            throw
        }
    }

    hidden [TeamsUserPolicyAssignment] AsResult([System.Object] $Values)
    {
        if ($Values -is [TeamsUserPolicyAssignment])
        {
            return $Values
        }

        $result = [TeamsUserPolicyAssignment]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
