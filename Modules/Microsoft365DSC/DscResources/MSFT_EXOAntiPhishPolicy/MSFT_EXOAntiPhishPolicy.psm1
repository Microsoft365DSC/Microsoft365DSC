using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class EXOAntiPhishPolicy : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The Identity parameter specifies the name of the antiphishing policy that you want to modify.')]
    [System.String] $Identity

    [DscProperty()]
    [System.ComponentModel.Description('Specify if this policy should exist or not.')]
    [ValidateSet('Present', 'Absent')]
    [System.String] $Ensure

    [DscProperty()]
    [System.ComponentModel.Description('The AdminDisplayName parameter specifies a description for the policy.')]
    [System.String] $AdminDisplayName

    [DscProperty()]
    [System.ComponentModel.Description('The PhishThresholdLevel parameter specifies the tolerance level that''s used by machine learning in the handling of phishing messages.')]
    [ValidateSet('1', '2', '3', '4')]
    [System.Nullable[System.UInt32]] $PhishThresholdLevel

    [DscProperty()]
    [System.ComponentModel.Description('The AuthenticationFailAction parameter specifies the action to take when the message fails composite authentication.')]
    [ValidateSet('MoveToJmf', 'Quarantine')]
    [System.String] $AuthenticationFailAction

    [DscProperty()]
    [System.ComponentModel.Description('The TargetedUserProtectionAction parameter specifies the action to take on detected user impersonation messages for the users specified by the TargetedUsersToProtect parameter.')]
    [ValidateSet('BccMessage', 'Delete', 'MoveToJmf', 'NoAction', 'Quarantine', 'Redirect')]
    [System.String] $TargetedUserProtectionAction

    [DscProperty()]
    [System.ComponentModel.Description('Specify if this policy should be enabled. Default is $true.')]
    [System.Nullable[System.Boolean]] $Enabled

    [DscProperty()]
    [System.ComponentModel.Description('The EnableFirstContactSafetyTips parameter specifies whether to enable or disable the safety tip that''s shown when recipients first receive an email from a sender or do not often receive email from a sender.')]
    [System.Nullable[System.Boolean]] $EnableFirstContactSafetyTips

    [DscProperty()]
    [System.ComponentModel.Description('The EnableMailboxIntelligence parameter specifies whether to enable or disable mailbox intelligence (the first contact graph) in domain and user impersonation protection.')]
    [System.Nullable[System.Boolean]] $EnableMailboxIntelligence

    [DscProperty()]
    [System.ComponentModel.Description('The EnableMailboxIntelligenceProtection specifies whether to enable or disable enhanced impersonation results based on each user''s individual sender map. This intelligence allows Microsoft 365 to customize user impersonation detection and better handle false positives.')]
    [System.Nullable[System.Boolean]] $EnableMailboxIntelligenceProtection

    [DscProperty()]
    [System.ComponentModel.Description('The EnableOrganizationDomainsProtection parameter specifies whether to enable domain impersonation protection for all registered domains in the Office 365 organization.')]
    [System.Nullable[System.Boolean]] $EnableOrganizationDomainsProtection

    [DscProperty()]
    [System.ComponentModel.Description('The EnableSimilarDomainsSafetyTips parameter specifies whether to enable safety tips that are shown to recipients in messages for domain impersonation detections.')]
    [System.Nullable[System.Boolean]] $EnableSimilarDomainsSafetyTips

    [DscProperty()]
    [System.ComponentModel.Description('The EnableSimilarUsersSafetyTips parameter specifies whether to enable safety tips that are shown to recipients in messages for user impersonation detections.')]
    [System.Nullable[System.Boolean]] $EnableSimilarUsersSafetyTips

    [DscProperty()]
    [System.ComponentModel.Description('The EnableSpoofIntelligence parameter specifies whether to enable or disable antispoofing protection for the policy.')]
    [System.Nullable[System.Boolean]] $EnableSpoofIntelligence

    [DscProperty()]
    [System.ComponentModel.Description('The EnableTargetedDomainsProtection parameter specifies whether to enable domain impersonation protection for a list of specified domains.')]
    [System.Nullable[System.Boolean]] $EnableTargetedDomainsProtection

    [DscProperty()]
    [System.ComponentModel.Description('The EnableTargetedUserProtection parameter specifies whether to enable user impersonation protection for the users specified by the TargetedUsersToProtect parameter')]
    [System.Nullable[System.Boolean]] $EnableTargetedUserProtection

    [DscProperty()]
    [System.ComponentModel.Description('The EnableUnauthenticatedSender parameter enables or disables unauthenticated sender identification in Outlook.')]
    [System.Nullable[System.Boolean]] $EnableUnauthenticatedSender

    [DscProperty()]
    [System.ComponentModel.Description('The EnableUnusualCharactersSafetyTips parameter specifies whether to enable safety tips that are shown to recipients in messages for unusual characters in domain and user impersonation detections.')]
    [System.Nullable[System.Boolean]] $EnableUnusualCharactersSafetyTips

    [DscProperty()]
    [System.ComponentModel.Description('This setting is part of spoof protection. The EnableViaTag parameter enables or disables adding the via tag to the From address in Outlook.')]
    [System.Nullable[System.Boolean]] $EnableViaTag

    [DscProperty()]
    [System.ComponentModel.Description('Make this the default antiphishing policy')]
    [System.Nullable[System.Boolean]] $MakeDefault

    [DscProperty()]
    [System.ComponentModel.Description('The ExcludedDomains parameter specifies trusted domains that are excluded from scanning by antiphishing protection. You can specify multiple domains separated by commas.')]
    [System.String[]] $ExcludedDomains

    [DscProperty()]
    [System.ComponentModel.Description('The ExcludedSenders parameter specifies a list of trusted sender email addresses that are excluded from scanning by antiphishing protection. You can specify multiple email addresses separated by commas.')]
    [System.String[]] $ExcludedSenders

    [DscProperty()]
    [System.ComponentModel.Description('The HonorDmarcPolicy enables or disables using the sender''s DMARC policy to determine what to do to messages that fail DMARC checks.')]
    [System.Nullable[System.Boolean]] $HonorDmarcPolicy

    [DscProperty()]
    [System.ComponentModel.Description('The ImpersonationProtectionState parameter specifies the configuration of impersonation protection.')]
    [System.String] $ImpersonationProtectionState

    [DscProperty()]
    [System.ComponentModel.Description('The MailboxIntelligenceProtectionAction parameter specifies what to do with messages that fail mailbox intelligence protection.')]
    [System.String] $MailboxIntelligenceProtectionAction

    [DscProperty()]
    [System.ComponentModel.Description('The MailboxIntelligenceProtectionActionRecipients parameter specifies the recipients to add to detected messages when the MailboxIntelligenceProtectionAction parameter is set to the value Redirect or BccMessage.')]
    [System.String[]] $MailboxIntelligenceProtectionActionRecipients

    [DscProperty()]
    [System.ComponentModel.Description('The MailboxIntelligenceQuarantineTag specifies the quarantine policy that''s used on messages that are quarantined by mailbox intelligence.')]
    [System.String] $MailboxIntelligenceQuarantineTag

    [DscProperty()]
    [System.ComponentModel.Description('The SpoofQuarantineTag specifies the quarantine policy that''s used on messages that are quarantined by spoof intelligence.')]
    [System.String] $SpoofQuarantineTag

    [DscProperty()]
    [System.ComponentModel.Description('The TargetedDomainActionRecipients parameter specifies the recipients to add to detected domain impersonation messages when the TargetedDomainProtectionAction parameter is set to the value Redirect or BccMessage. A valid value for this parameter is an email address. You can specify multiple email addresses separated by commas.')]
    [System.String[]] $TargetedDomainActionRecipients

    [DscProperty()]
    [System.ComponentModel.Description('The TargetedDomainProtectionAction parameter specifies the action to take on detected domain impersonation messages.')]
    [ValidateSet('BccMessage', 'Delete', 'MoveToJmf', 'NoAction', 'Quarantine', 'Redirect')]
    [System.String] $TargetedDomainProtectionAction

    [DscProperty()]
    [System.ComponentModel.Description('The TargetedDomainsToProtect parameter specifies the domains that are included in domain impersonation protection when the EnableTargetedDomainsProtection parameter is set to $true.')]
    [System.String[]] $TargetedDomainsToProtect

    [DscProperty()]
    [System.ComponentModel.Description('The TargetedDomainQuarantineTag specifies the quarantine policy that''s used on messages that are quarantined by domain impersonation protection.')]
    [System.String] $TargetedDomainQuarantineTag

    [DscProperty()]
    [System.ComponentModel.Description('The TargetedUserActionRecipients parameter specifies the replacement or additional recipients for detected user impersonation messages when the TargetedUserProtectionAction parameter is set to the value Redirect or BccMessage. A valid value for this parameter is an email address. You can specify multiple email addresses separated by commas.')]
    [System.String[]] $TargetedUserActionRecipients

    [DscProperty()]
    [System.ComponentModel.Description('The TargetedUsersToProtect parameter specifies the users that are included in user impersonation protection when the EnableTargetedUserProtection parameter is set to $true.')]
    [System.String[]] $TargetedUsersToProtect

    [DscProperty()]
    [System.ComponentModel.Description('The TargetedUserQuarantineTag specifies the quarantine policy that''s used on messages that are quarantined by user impersonation protection.')]
    [System.String] $TargetedUserQuarantineTag

    [DscProperty()]
    [System.ComponentModel.Description('The DmarcQuarantineAction parameter specifies the action to take when a message fails DMARC checks and the sender''s DMARC policy is p=quarantine')]
    [ValidateSet('MoveToJmf', 'Quarantine')]
    [System.String] $DmarcQuarantineAction

    [DscProperty()]
    [System.ComponentModel.Description('The DmarcRejectAction parameter specifies the action to take when a message fails DMARC checks and the sender''s DMARC policy is p=reject.')]
    [ValidateSet('Quarantine', 'Reject')]
    [System.String] $DmarcRejectAction

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

    [EXOAntiPhishPolicy] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [EXOAntiPhishPolicy]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of AntiPhishPolicy for $($this.Identity)"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.Identity -ne $this.Identity)
            {

                $null = $this.Connect('ExchangeOnline')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullReturn = $this.GetBoundParameters()
                $nullReturn.Ensure = 'Absent'

                $AntiPhishPolicy = Get-AntiPhishPolicy -Identity $this.Identity -ErrorAction SilentlyContinue
                if ($null -eq $AntiPhishPolicy)
                {
                    Write-Verbose -Message "AntiPhishPolicy $($this.Identity) does not exist."
                    return $this.AsResult($nullReturn)
                }
            }
            else
            {
                $AntiPhishPolicy = $this.ExportedInstance
            }

            $PhishThresholdLevelValue = $AntiPhishPolicy.PhishThresholdLevel
            if ([System.String]::IsNullOrEmpty($PhishThresholdLevelValue))
            {
                $PhishThresholdLevelValue = 1
            }

            $TargetedUserProtectionActionValue = $AntiPhishPolicy.TargetedUserProtectionAction
            if ([System.String]::IsNullOrEmpty($TargetedUserProtectionActionValue))
            {
                $TargetedUserProtectionActionValue = 'NoAction'
            }

            $TargetedDomainProtectionActionValue = $AntiPhishPolicy.TargetedDomainProtectionAction
            if ([System.String]::IsNullOrEmpty($TargetedDomainProtectionActionValue))
            {
                $TargetedDomainProtectionActionValue = 'NoAction'
            }

            Write-Verbose -Message "Found AntiPhishPolicy $($this.Identity)"

            $result = @{
                Identity                                      = $this.Identity
                AdminDisplayName                              = $AntiPhishPolicy.AdminDisplayName
                AuthenticationFailAction                      = $AntiPhishPolicy.AuthenticationFailAction
                Enabled                                       = $AntiPhishPolicy.Enabled
                EnableFirstContactSafetyTips                  = $AntiPhishPolicy.EnableFirstContactSafetyTips
                EnableMailboxIntelligence                     = $AntiPhishPolicy.EnableMailboxIntelligence
                EnableMailboxIntelligenceProtection           = $AntiPhishPolicy.EnableMailboxIntelligenceProtection
                EnableOrganizationDomainsProtection           = $AntiPhishPolicy.EnableOrganizationDomainsProtection
                EnableSimilarDomainsSafetyTips                = $AntiPhishPolicy.EnableSimilarDomainsSafetyTips
                EnableSimilarUsersSafetyTips                  = $AntiPhishPolicy.EnableSimilarUsersSafetyTips
                EnableSpoofIntelligence                       = $AntiPhishPolicy.EnableSpoofIntelligence
                EnableTargetedDomainsProtection               = $AntiPhishPolicy.EnableTargetedDomainsProtection
                EnableTargetedUserProtection                  = $AntiPhishPolicy.EnableTargetedUserProtection
                EnableUnauthenticatedSender                   = $AntiPhishPolicy.EnableUnauthenticatedSender
                EnableUnusualCharactersSafetyTips             = $AntiPhishPolicy.EnableUnusualCharactersSafetyTips
                EnableViaTag                                  = $AntiPhishPolicy.EnableViaTag
                ExcludedDomains                               = $AntiPhishPolicy.ExcludedDomains
                ExcludedSenders                               = $AntiPhishPolicy.ExcludedSenders
                HonorDmarcPolicy                              = $AntiPhishPolicy.HonorDmarcPolicy
                ImpersonationProtectionState                  = $AntiPhishPolicy.ImpersonationProtectionState
                MailboxIntelligenceProtectionAction           = $AntiPhishPolicy.MailboxIntelligenceProtectionAction
                MailboxIntelligenceProtectionActionRecipients = $AntiPhishPolicy.MailboxIntelligenceProtectionActionRecipients
                MailboxIntelligenceQuarantineTag              = $AntiPhishPolicy.MailboxIntelligenceQuarantineTag
                SpoofQuarantineTag                            = $AntiPhishPolicy.SpoofQuarantineTag
                MakeDefault                                   = $AntiPhishPolicy.IsDefault
                PhishThresholdLevel                           = $PhishThresholdLevelValue
                TargetedDomainActionRecipients                = $AntiPhishPolicy.TargetedDomainActionRecipients
                TargetedDomainProtectionAction                = $TargetedDomainProtectionActionValue
                TargetedDomainsToProtect                      = $AntiPhishPolicy.TargetedDomainsToProtect
                TargetedDomainQuarantineTag                   = $AntiPhishPolicy.TargetedDomainQuarantineTag
                TargetedUserActionRecipients                  = $AntiPhishPolicy.TargetedUserActionRecipients
                TargetedUserProtectionAction                  = $TargetedUserProtectionActionValue
                TargetedUsersToProtect                        = $AntiPhishPolicy.TargetedUsersToProtect
                TargetedUserQuarantineTag                     = $AntiPhishPolicy.TargetedUserQuarantineTag
                DmarcQuarantineAction                         = $AntiPhishPolicy.DmarcQuarantineAction
                DmarcRejectAction                             = $AntiPhishPolicy.DmarcRejectAction
                Credential                                    = $this.Credential
                Ensure                                        = 'Present'
                ApplicationId                                 = $this.ApplicationId
                CertificateThumbprint                         = $this.CertificateThumbprint
                CertificatePath                               = $this.CertificatePath
                CertificatePassword                           = $this.CertificatePassword
                ManagedIdentity                               = $this.ManagedIdentity
                TenantId                                      = $this.TenantId
                AccessTokens                                  = $this.AccessTokens
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

        Write-Verbose -Message "Setting configuration of AntiPhishPolicy for $($this.Identity)"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $null = $this.Connect('ExchangeOnline')

        $currentInstance = $this.Get().ToHashtable()

        if ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Creating new instance of AntiPhish Policy {$($this.Identity)}"
            $createParams = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()
            $createParams.Remove('Ensure') | Out-Null
            $createParams.Add('Name', $this.Identity)
            $createParams.Remove('Identity') | Out-Null
            New-AntiPhishPolicy @createParams
        }
        elseif ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Updating existing AntiPhishPolicy {$($this.Identity)}"
            $UpdateParams = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()
            $UpdateParams.Remove('Ensure') | Out-Null
            Set-AntiphishPolicy @UpdateParams
        }
        elseif ($this.Ensure -eq 'Absent' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Removing AntiPhishPolicy $($this.Identity)"
            Remove-AntiPhishPolicy -Identity $this.Identity -Confirm:$false -Force
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
            [array]$AntiPhishPolicies = Get-AntiPhishPolicy -ErrorAction Stop
            $dscContent = [System.Text.StringBuilder]::new()
            $i = 1

            if ($AntiphishPolicies.Length -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }
            foreach ($Policy in $AntiPhishPolicies)
            {
                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }

                Write-M365DSCHost -Message "    |---[$i/$($AntiphishPolicies.Length)] $($Policy.Identity)" -DeferWrite

                $Params = @{
                    Identity              = $Policy.Identity
                    Credential            = $this.Credential
                    ApplicationId         = $this.ApplicationId
                    TenantId              = $this.TenantId
                    CertificateThumbprint = $this.CertificateThumbprint
                    CertificatePassword   = $this.CertificatePassword
                    ManagedIdentity       = $this.ManagedIdentity
                    CertificatePath       = $this.CertificatePath
                    AccessTokens          = $this.AccessTokens
                }
                $this.ExportedInstance = $Policy
                $Results = $this.GetForExport($Params)
                $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                    -ConnectionMode $ConnectionMode `
                    -ModulePath $this.GetModulePath() `
                    -Results $Results `
                    -Credential $this.Credential
                [void]$dscContent.Append($currentDSCBlock)

                Save-M365DSCPartialExport -Content $currentDSCBlock `
                    -FileName $Global:PartialExportFileName
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
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

    hidden [EXOAntiPhishPolicy] AsResult([System.Object] $Values)
    {
        if ($Values -is [EXOAntiPhishPolicy])
        {
            return $Values
        }

        $result = [EXOAntiPhishPolicy]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
