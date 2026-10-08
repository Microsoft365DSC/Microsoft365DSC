using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class EXOHostedOutboundSpamFilterPolicy : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The Identity parameter specifies the name of the policy that you want to modify. There is only one policy named ''Default''')]
    [System.String] $Identity

    [DscProperty()]
    [System.ComponentModel.Description('The AdminDisplayName parameter specifies a description for the policy.')]
    [System.String] $AdminDisplayName

    [DscProperty()]
    [System.ComponentModel.Description('The BccSuspiciousOutboundAdditionalRecipients parameter specifies the recipients to add to the Bcc field of outgoing spam messages. Valid input for this parameter is an email address. Separate multiple email addresses with commas.')]
    [System.String[]] $BccSuspiciousOutboundAdditionalRecipients

    [DscProperty()]
    [System.ComponentModel.Description('The BccSuspiciousOutboundMail parameter enables or disables adding recipients to the Bcc field of outgoing spam messages. Valid input for this parameter is $true or $false. The default value is $false. You specify the additional recipients using the BccSuspiciousOutboundAdditionalRecipients parameter.')]
    [System.Nullable[System.Boolean]] $BccSuspiciousOutboundMail

    [DscProperty()]
    [System.ComponentModel.Description('The NotifyOutboundSpam parameter enables or disables sending notification messages to administrators when an outgoing message is determined to be spam. Valid input for this parameter is $true or $false. The default value is $false. You specify the administrators to notify by using the NotifyOutboundSpamRecipients parameter.')]
    [System.Nullable[System.Boolean]] $NotifyOutboundSpam

    [DscProperty()]
    [System.ComponentModel.Description('The NotifyOutboundSpamRecipients parameter specifies the administrators to notify when an outgoing message is determined to be spam. Valid input for this parameter is an email address. Separate multiple email addresses with commas.')]
    [System.String[]] $NotifyOutboundSpamRecipients

    [DscProperty()]
    [System.ComponentModel.Description('The RecipientLimitInternalPerHour parameter specifies the maximum number of internal recipients that a user can send to within an hour. A valid value is 0 to 10000. The default value is 0, which means the service defaults are used.')]
    [System.Nullable[System.UInt32]] $RecipientLimitInternalPerHour

    [DscProperty()]
    [System.ComponentModel.Description('The RecipientLimitPerDay parameter specifies the maximum number of recipients that a user can send to within a day. A valid value is 0 to 10000. The default value is 0, which means the service defaults are used.')]
    [System.Nullable[System.UInt32]] $RecipientLimitPerDay

    [DscProperty()]
    [System.ComponentModel.Description('The RecipientLimitExternalPerHour parameter specifies the maximum number of external recipients that a user can send to within an hour. A valid value is 0 to 10000. The default value is 0, which means the service defaults are used.')]
    [System.Nullable[System.UInt32]] $RecipientLimitExternalPerHour

    [DscProperty()]
    [System.ComponentModel.Description('The ActionWhenThresholdReached parameter specifies the action to take when any of the limits specified in the policy are reached. Valid values are: Alert, BlockUser, BlockUserForToday. BlockUserForToday is the default value.')]
    [System.String] $ActionWhenThresholdReached

    [DscProperty()]
    [System.ComponentModel.Description('The AutoForwardingMode specifies how the policy controls automatic email forwarding to outbound recipients. Valid values are: Automatic, On, Off.')]
    [System.String] $AutoForwardingMode

    [DscProperty()]
    [System.ComponentModel.Description('Specify if this policy should exist or not.')]
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

    [EXOHostedOutboundSpamFilterPolicy] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [EXOHostedOutboundSpamFilterPolicy]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of HostedOutboundSpamFilterPolicy for $($this.Identity)"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.Identity -ne $this.Identity)
            {
                $null = $this.Connect('ExchangeOnline')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullReturn = $this.GetBoundParameters()
                $nullReturn.Ensure = 'Absent'

                $HostedOutboundSpamFilterPolicy = Get-HostedOutboundSpamFilterPolicy -Identity $this.Identity -ErrorAction SilentlyContinue
                if (-not $HostedOutboundSpamFilterPolicy)
                {
                    Write-Verbose -Message "HostedOutboundSpamFilterPolicy $($this.Identity) does not exist."
                    return $this.AsResult($nullReturn)
                }
            }
            else
            {
                $HostedOutboundSpamFilterPolicy = $this.ExportedInstance
            }

            Write-Verbose -Message "Found HostedOutboundSpamFilterPolicy $($this.Identity)"

            $result = @{
                Ensure                                    = 'Present'
                Identity                                  = $this.Identity
                AdminDisplayName                          = $HostedOutboundSpamFilterPolicy.AdminDisplayName
                BccSuspiciousOutboundAdditionalRecipients = $HostedOutboundSpamFilterPolicy.BccSuspiciousOutboundAdditionalRecipients
                BccSuspiciousOutboundMail                 = $HostedOutboundSpamFilterPolicy.BccSuspiciousOutboundMail
                NotifyOutboundSpamRecipients              = $HostedOutboundSpamFilterPolicy.NotifyOutboundSpamRecipients
                NotifyOutboundSpam                        = $HostedOutboundSpamFilterPolicy.NotifyOutboundSpam
                RecipientLimitInternalPerHour             = $HostedOutboundSpamFilterPolicy.RecipientLimitInternalPerHour
                RecipientLimitPerDay                      = $HostedOutboundSpamFilterPolicy.RecipientLimitPerDay
                RecipientLimitExternalPerHour             = $HostedOutboundSpamFilterPolicy.RecipientLimitExternalPerHour
                ActionWhenThresholdReached                = $HostedOutboundSpamFilterPolicy.ActionWhenThresholdReached
                AutoForwardingMode                        = $HostedOutboundSpamFilterPolicy.AutoForwardingMode
                Credential                                = $this.Credential
                ApplicationId                             = $this.ApplicationId
                CertificateThumbprint                     = $this.CertificateThumbprint
                CertificatePath                           = $this.CertificatePath
                CertificatePassword                       = $this.CertificatePassword
                ManagedIdentity                           = $this.ManagedIdentity
                TenantId                                  = $this.TenantId
                AccessTokens                              = $this.AccessTokens
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

        Write-Verbose -Message "Testing configuration of HostedOutboundSpamFilterPolicy for $($this.Identity)"

        $currentHostedOutboundSpamFilterPolicyConfig = $this.Get().ToHashtable()

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $null = $this.Connect('ExchangeOnline')

        $HostedOutboundSpamFilterPolicyParams = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()

        # CASE: Hosted Outbound Spam Filter Policy doesn't exist but should;
        if ($this.Ensure -eq 'Present' -and $currentHostedOutboundSpamFilterPolicyConfig.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Hosted Outbound Spam Filter Policy '$($this.Identity)' does not exist but it should. Create and configure it."
            $HostedOutboundSpamFilterPolicyParams.Add('Name', $this.Identity)
            $HostedOutboundSpamFilterPolicyParams.Remove('Identity') | Out-Null
            New-HostedOutboundSpamFilterPolicy @HostedOutboundSpamFilterPolicyParams
        }
        # CASE: Hosted Outbound Spam Filter Policy exists but it shouldn't;
        elseif ($this.Ensure -eq 'Absent' -and $currentHostedOutboundSpamFilterPolicyConfig.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Hosted Outbound Spam Filter Policy '$($this.Identity)' exists but it shouldn't. Remove it."
            Remove-HostedOutboundSpamFilterPolicy -Identity $this.Identity -Force
        }
        # CASE: Hosted Outbound Spam Filter Policy exists and it should, but has different values than the desired ones
        elseif ($this.Ensure -eq 'Present' -and $currentHostedOutboundSpamFilterPolicyConfig.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Hosted Outbound Spam Filter Policy '$($this.Identity)' already exists, but needs updating."
            Write-Verbose -Message "Setting Hosted Outbound Spam Filter Policy $($this.Identity) with values: $(Convert-M365DscHashtableToString -Hashtable $HostedOutboundSpamFilterPolicyParams)"
            Set-HostedOutboundSpamFilterPolicy @HostedOutboundSpamFilterPolicyParams -Confirm:$false
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
            [array]$HostedOutboundSpamFilterPolicies = Get-HostedOutboundSpamFilterPolicy -ErrorAction stop
            $dscContent = [System.Text.StringBuilder]::new()

            if ($HostedOutboundSpamFilterPolicies.Count -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }
            $i = 1
            foreach ($HostedOutboundSpamFilterPolicy in $HostedOutboundSpamFilterPolicies)
            {
                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }

                $Params = @{
                    Credential            = $this.Credential
                    Identity              = $HostedOutboundSpamFilterPolicy.Identity
                    ApplicationId         = $this.ApplicationId
                    TenantId              = $this.TenantId
                    CertificateThumbprint = $this.CertificateThumbprint
                    CertificatePassword   = $this.CertificatePassword
                    ManagedIdentity       = $this.ManagedIdentity
                    CertificatePath       = $this.CertificatePath
                    AccessTokens          = $this.AccessTokens
                }
                $this.ExportedInstance = $HostedOutboundSpamFilterPolicy
                Write-M365DSCHost -Message "    |---[$i/$($HostedOutboundSpamFilterPolicies.Length)] $($HostedOutboundSpamFilterPolicy.Identity)" -DeferWrite
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

    hidden [EXOHostedOutboundSpamFilterPolicy] AsResult([System.Object] $Values)
    {
        if ($Values -is [EXOHostedOutboundSpamFilterPolicy])
        {
            return $Values
        }

        $result = [EXOHostedOutboundSpamFilterPolicy]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
