using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class TeamsOnlineVoicemailPolicy : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('Identity of the Teams Online Voicemail Policy.')]
    [System.String] $Identity

    [DscProperty()]
    [System.ComponentModel.Description('Controls if editing call answer rule settings are enabled or disabled for a user. Possible values are $true or $false.')]
    [System.Nullable[System.Boolean]] $EnableEditingCallAnswerRulesSetting

    [DscProperty()]
    [System.ComponentModel.Description('Allows you to disable or enable voicemail transcription. Possible values are $true or $false.')]
    [System.Nullable[System.Boolean]] $EnableTranscription

    [DscProperty()]
    [System.ComponentModel.Description('Allows you to disable or enable profanity masking for the voicemail transcriptions. Possible values are $true or $false.')]
    [System.Nullable[System.Boolean]] $EnableTranscriptionProfanityMasking

    [DscProperty()]
    [System.ComponentModel.Description('Allows you to disable or enable translation for the voicemail transcriptions. Possible values are $true or $false.')]
    [System.Nullable[System.Boolean]] $EnableTranscriptionTranslation

    [DscProperty()]
    [System.ComponentModel.Description('Specifies whether AI-powered voicemail triage is enabled. Possible values are $true or $false.')]
    [System.Nullable[System.Boolean]] $EnableVoicemailTriage

    [DscProperty()]
    [System.ComponentModel.Description('A duration of voicemail maximum recording length. The length should be between 30 seconds to 600 seconds.')]
    [System.Nullable[System.Int32]] $MaximumRecordingLength

    [DscProperty()]
    [System.ComponentModel.Description('The audio file to play to the caller after the user''s voicemail greeting has played and before the caller is allowed to leave a voicemail message.')]
    [System.String] $PostambleAudioFile

    [DscProperty()]
    [System.ComponentModel.Description('The audio file to play to the caller before the user''s voicemail greeting is played.')]
    [System.String] $PreambleAudioFile

    [DscProperty()]
    [System.ComponentModel.Description('Is playing the Pre- or Post-amble mandatory before the caller can leave a message. Possible values are $true or $false.')]
    [System.Nullable[System.Boolean]] $PreamblePostambleMandatory

    [DscProperty()]
    [System.ComponentModel.Description('The primary (or first) language that voicemail system prompts will be presented in. Must also set SecondarySystemPromptLanguage. When set, this overrides the user language choice.')]
    [System.String] $PrimarySystemPromptLanguage

    [DscProperty()]
    [System.ComponentModel.Description('The secondary language that voicemail system prompts will be presented in. Must also set PrimarySystemPromptLanguage and may not be the same value as PrimarySystemPromptanguage. When set, this overrides the user language choice. ')]
    [System.String] $SecondarySystemPromptLanguage

    [DscProperty()]
    [System.ComponentModel.Description('Specifies whether voicemail and transcription data are shared with the service for training and improving accuracy. Possible values are Defer and Deny.')]
    [System.String] $ShareData

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
    [System.String] $Filter = '*'

    [TeamsOnlineVoicemailPolicy] Get()
    {
        $nullReturn = $null
        ${$Identity} = $null
        if ($this.RequiresPowerShellCore())
        {
            $remote = [TeamsOnlineVoicemailPolicy]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting the Teams Online Voicemail Policy $($this.Identity)"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.Identity -ne $this.Identity)
            {
                $null = $this.Connect('MicrosoftTeams')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullReturn = $this.GetBoundParameters()
                $nullReturn.Ensure = 'Absent'

                $policy = Get-CsOnlineVoicemailPolicy -Identity $this.Identity `
                    -ErrorAction 'SilentlyContinue'
            }
            else
            {
                $policy = $this.ExportedInstance
            }

            if ($null -eq $policy)
            {
                Write-Verbose -Message "Could not find Teams Online Voicemail Policy ${$Identity}"
                return $this.AsResult($nullReturn)
            }

            Write-Verbose -Message "Found Teams Online Voicemail Policy {$($this.Identity)}"
            return $this.AsResult(@{
                Identity                            = $policy.Identity.Replace('Tag:', '')
                EnableEditingCallAnswerRulesSetting = $policy.EnableEditingCallAnswerRulesSetting
                EnableTranscription                 = $policy.EnableTranscription
                EnableTranscriptionProfanityMasking = $policy.EnableTranscriptionProfanityMasking
                EnableTranscriptionTranslation      = $policy.EnableTranscriptionTranslation
                EnableVoicemailTriage               = $policy.EnableVoicemailTriage
                MaximumRecordingLength              = $policy.MaximumRecordingLength.TotalSeconds
                PostambleAudioFile                  = $policy.PostambleAudioFile
                PreambleAudioFile                   = $policy.PreambleAudioFile
                PreamblePostambleMandatory          = $policy.PreamblePostambleMandatory
                PrimarySystemPromptLanguage         = $policy.PrimarySystemPromptLanguage
                SecondarySystemPromptLanguage       = $policy.SecondarySystemPromptLanguage
                ShareData                           = $policy.ShareData
                Ensure                              = 'Present'
                Credential                          = $this.Credential
                ApplicationId                       = $this.ApplicationId
                TenantId                            = $this.TenantId
                CertificateThumbprint               = $this.CertificateThumbprint
                CertificatePath                     = $this.CertificatePath
                CertificatePassword                 = $this.CertificatePassword
                ManagedIdentity                     = $this.ManagedIdentity
                AccessTokens                        = $this.AccessTokens
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

        Write-Verbose -Message 'Setting Teams Online Voicemail Policy'

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $CurrentValues = $this.Get().ToHashtable()
        $SetParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()

        # Convert recording length in seconds to a TimeSpan value expected by Teams cmdlets.
        if ($this.GetBoundParameters().ContainsKey('MaximumRecordingLength'))
        {
            $SetParameters.MaximumRecordingLength = New-TimeSpan -Seconds $this.MaximumRecordingLength
        }

        if ($this.Ensure -eq 'Present' -and $CurrentValues.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Creating a new Teams Online Voicemail Policy {$($this.Identity)}"
            New-CsOnlineVoicemailPolicy @SetParameters
        }
        elseif ($this.Ensure -eq 'Present' -and $CurrentValues.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Updating the Teams Online Voicemail Policy with Identity {$($this.Identity)}"
            Set-CsOnlineVoicemailPolicy @SetParameters
        }
        elseif ($this.Ensure -eq 'Absent' -and $CurrentValues.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Removing the Teams Online Voicemail Policy with Identity {$($this.Identity)}"
            Remove-CsOnlineVoicemailPolicy -Identity $this.Identity
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
            [array]$policies = Get-CsOnlineVoicemailPolicy -Filter $this.Filter -ErrorAction Stop
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

    hidden [TeamsOnlineVoicemailPolicy] AsResult([System.Object] $Values)
    {
        if ($Values -is [TeamsOnlineVoicemailPolicy])
        {
            return $Values
        }

        $result = [TeamsOnlineVoicemailPolicy]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
