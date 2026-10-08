using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class TeamsOnlineVoicemailUserSettings : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The Identity parameter represents the ID of the specific user in your organization; this can be either a SIP URI or an Object ID.')]
    [System.String] $Identity

    [DscProperty()]
    [System.ComponentModel.Description('The CallAnswerRule parameter represents the value of the call answer rule, which can be any of the following: DeclineCall, PromptOnly, PromptOnlyWithTransfer, RegularVoicemail, VoicemailWithTransferOption.')]
    [ValidateSet('DeclineCall', 'PromptOnly', 'PromptOnlyWithTransfer', 'RegularVoicemail', 'VoicemailWithTransferOption')]
    [System.String] $CallAnswerRule

    [DscProperty()]
    [System.ComponentModel.Description('The CallToActionDetectionEnabled parameter represents whether call to action detection, an AI triage feature for personal voicemail, is enabled for the user.')]
    [System.Nullable[System.Boolean]] $CallToActionDetectionEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The CategoryDetectionEnabled parameter represents whether category detection, an AI triage feature for personal voicemail, is enabled for the user.')]
    [System.Nullable[System.Boolean]] $CategoryDetectionEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The DefaultGreetingPromptOverwrite parameter represents the contents that overwrite the default normal greeting prompt. If the user''s normal custom greeting is not set and DefaultGreetingPromptOverwrite is not empty, the voicemail service will play this overwrite greeting instead of the default normal greeting in the voicemail deposit scenario.')]
    [System.String] $DefaultGreetingPromptOverwrite

    [DscProperty()]
    [System.ComponentModel.Description('The DefaultOofGreetingPromptOverwrite parameter represents the contents that overwrite the default out-of-office greeting prompt. If the user''s out-of-office custom greeting is not set and DefaultOofGreetingPromptOverwrite is not empty, the voicemail service will play this overwrite greeting instead of the default out-of-office greeting in the voicemail deposit scenario.')]
    [System.String] $DefaultOofGreetingPromptOverwrite

    [DscProperty()]
    [System.ComponentModel.Description('The OofGreetingEnabled parameter represents whether to play out-of-office greeting in voicemail deposit scenario.')]
    [System.Nullable[System.Boolean]] $OofGreetingEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The OofGreetingFollowAutomaticRepliesEnabled parameter represents whether to play out-of-office greeting in voicemail deposit scenario when user set automatic replies in Outlook.')]
    [System.Nullable[System.Boolean]] $OofGreetingFollowAutomaticRepliesEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The PromptLanguage parameter represents the language that is used to play voicemail prompts.')]
    [System.String] $PromptLanguage

    [DscProperty()]
    [System.ComponentModel.Description('Specifies whether voicemail and transcription data is shared with the service for training and improving accuracy.')]
    [System.Nullable[System.Boolean]] $ShareData

    [DscProperty()]
    [System.ComponentModel.Description('The TransferTarget parameter represents the target to transfer the call when call answer rule set to PromptOnlyWithTransfer or VoicemailWithTransferOption. Value of this parameter should be a SIP URI of another user in your organization. For user with Enterprise Voice enabled, a valid telephone number could also be accepted as TransferTarget.')]
    [System.String] $TransferTarget

    [DscProperty()]
    [System.ComponentModel.Description('The UrgencyDetectionEnabled parameter represents whether urgency detection, an AI triage feature for personal voicemail, is enabled for the user.')]
    [System.Nullable[System.Boolean]] $UrgencyDetectionEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The VoicemailEnabled parameter represents whether to enable voicemail service. If set to $false, the user has no voicemail service.')]
    [System.Nullable[System.Boolean]] $VoicemailEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The VoiceToTextSummaryEnabled parameter represents whether voice to text summary, an AI triage feature for personal voicemail, is enabled for the user.')]
    [System.Nullable[System.Boolean]] $VoiceToTextSummaryEnabled

    [DscProperty()]
    [System.ComponentModel.Description('Present ensures the policy exists, absent ensures it is removed.')]
    [ValidateSet('Present', 'Absent')]
    [System.String] $Ensure

    [DscProperty()]
    [System.ComponentModel.Description('Credentials of the Teams Global Admin.')]
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
    [System.String] $Filter

    [TeamsOnlineVoicemailUserSettings] Get()
    {
        ${$Identity} = $null
        if ($this.RequiresPowerShellCore())
        {
            $remote = [TeamsOnlineVoicemailUserSettings]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting the Teams Online Voicemail User Settings $($this.Identity)"

        $boundParameters = $this.GetBoundParameters()

        try
        {
            if (-not $this.ResourceCache['exportMode'])
            {
                $null = $this.Connect('MicrosoftTeams')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')
            }

            $nullReturn = $boundParameters
            $nullReturn.Ensure = 'Absent'

            $instance = Get-CsOnlineVoicemailUserSettings -Identity $this.Identity -ErrorAction 'SilentlyContinue'

            if ($null -eq $instance)
            {
                Write-Verbose -Message "Could not find Teams Online Voicemail User Settings for ${$Identity}"
                return $this.AsResult($nullReturn)
            }

            Write-Verbose -Message "Found Teams Online Voicemail User Settings for {$($this.Identity)}"
            return $this.AsResult(@{
                Identity                                 = $this.Identity
                CallAnswerRule                           = $instance.CallAnswerRule
                CallToActionDetectionEnabled             = $instance.CallToActionDetectionEnabled
                CategoryDetectionEnabled                 = $instance.CategoryDetectionEnabled
                DefaultGreetingPromptOverwrite           = $instance.DefaultGreetingPromptOverwrite
                DefaultOofGreetingPromptOverwrite        = $instance.DefaultOofGreetingPromptOverwrite
                OofGreetingEnabled                       = $instance.OofGreetingEnabled
                OofGreetingFollowAutomaticRepliesEnabled = $instance.OofGreetingFollowAutomaticRepliesEnabled
                PromptLanguage                           = $instance.PromptLanguage
                ShareData                                = $instance.ShareData
                TransferTarget                           = $instance.TransferTarget
                UrgencyDetectionEnabled                  = $instance.UrgencyDetectionEnabled
                VoicemailEnabled                         = $instance.VoicemailEnabled
                VoiceToTextSummaryEnabled                = $instance.VoiceToTextSummaryEnabled
                Ensure                                   = 'Present'
                Credential                               = $this.Credential
                ApplicationId                            = $this.ApplicationId
                TenantId                                 = $this.TenantId
                CertificateThumbprint                    = $this.CertificateThumbprint
                CertificatePath                          = $this.CertificatePath
                CertificatePassword                      = $this.CertificatePassword
                ManagedIdentity                          = $this.ManagedIdentity
                AccessTokens                             = $this.AccessTokens
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

        Write-Verbose -Message 'Setting Teams Online Voicemail User Settings'

        $boundParameters = $this.GetBoundParameters()

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $null = $this.Connect('MicrosoftTeams')

        $SetParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $boundParameters

        try
        {
            Set-CsOnlineVoicemailUserSettings @SetParameters
        }
        catch
        {
            $this.LogError($_, 'Error updating data:')

            throw
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
            $splat = @{
                Properties = 'UserPrincipalName'
            }
            if (-not [System.String]::IsNullOrEmpty($this.Filter))
            {
                $splat.Add('Filter', $this.Filter)
            }
            $allUsers = Get-CsOnlineUser @splat
            $i = 1
            Write-M365DSCHost -Message "`r`n" -DeferWrite
            $dscContent = [System.Text.StringBuilder]::new()
            $this.ResourceCache['exportMode'] = $true
            foreach ($user in $allUsers)
            {
                Write-M365DSCHost -Message "    |---[$i/$($allUsers.Length)] $($user.UserPrincipalName)" -DeferWrite
                $params = @{
                    Identity              = $user.UserPrincipalName
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
                $Results = $this.GetForExport($Params)
                if ($Results.Ensure -eq 'Present')
                {
                    if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                    {
                        $Global:M365DSCExportResourceInstancesCount++
                    }

                    $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                        -ConnectionMode $ConnectionMode `
                        -ModulePath $this.GetModulePath() `
                        -Results $Results `
                        -Credential $this.Credential
                    [void]$dscContent.Append($currentDSCBlock)
                    Save-M365DSCPartialExport -Content $currentDSCBlock `
                        -FileName $Global:PartialExportFileName
                }
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

    hidden [TeamsOnlineVoicemailUserSettings] AsResult([System.Object] $Values)
    {
        if ($Values -is [TeamsOnlineVoicemailUserSettings])
        {
            return $Values
        }

        $result = [TeamsOnlineVoicemailUserSettings]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
