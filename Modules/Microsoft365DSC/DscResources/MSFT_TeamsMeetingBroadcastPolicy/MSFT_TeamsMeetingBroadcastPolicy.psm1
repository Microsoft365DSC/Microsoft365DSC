using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class TeamsMeetingBroadcastPolicy : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The identifier of the Teams Meeting Broadcast Policy.')]
    [System.String] $Identity

    [DscProperty()]
    [System.ComponentModel.Description('Specifies whether this user can create broadcast events in Teams. This setting impacts broadcasts that use both self-service and external encoder production methods.')]
    [System.Nullable[System.Boolean]] $AllowBroadcastScheduling

    [DscProperty()]
    [System.ComponentModel.Description('Specifies whether real-time transcription and translation can be enabled in the broadcast event. Note: this setting is applicable to broadcast events that use Teams Meeting production only and does not apply when external encoder is used as production method.')]
    [System.Nullable[System.Boolean]] $AllowBroadcastTranscription

    [DscProperty()]
    [System.ComponentModel.Description('Specifies the attendee visibility mode of the broadcast events created by this user.  This setting controls who can watch the broadcast event - e.g. anyone can watch this event including anonymous users or only authenticated users in my company can watch the event.  Note: this setting is applicable to broadcast events that use Teams Meeting production only and does not apply when external encoder is used as production method.')]
    [ValidateSet('Everyone', 'EveryoneInCompany', 'InvitedUsersInCompany', 'EveryoneInCompanyAndExternal', 'InvitedUsersInCompanyAndExternal')]
    [System.String] $BroadcastAttendeeVisibilityMode

    [DscProperty()]
    [System.ComponentModel.Description('Specifies whether broadcast events created by this user are always recorded, never recorded or user can choose whether to record or not. Note: this setting is applicable to broadcast events that use Teams Meeting production only and does not apply when external encoder is used as production method.')]
    [ValidateSet('AlwaysEnabled', 'AlwaysDisabled', 'UserOverride')]
    [System.String] $BroadcastRecordingMode

    [DscProperty()]
    [System.ComponentModel.Description('Present ensures the Policy exists, absent ensures it is removed')]
    [ValidateSet('Present', 'Absent')]
    [System.String] $Ensure

    [DscProperty()]
    [System.ComponentModel.Description('Credentials of the Teams Admin')]
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

    [TeamsMeetingBroadcastPolicy] Get()
    {
        $nullReturn = $null
        if ($this.RequiresPowerShellCore())
        {
            $remote = [TeamsMeetingBroadcastPolicy]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of Teams Meeting Broadcast Policy {$($this.Identity)}"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.Identity -ne $this.Identity)
            {
                $null = $this.Connect('MicrosoftTeams')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullReturn = $this.GetBoundParameters()
                $nullReturn.Ensure = 'Absent'

                $config = Get-CsTeamsMeetingBroadcastPolicy -Identity $this.Identity `
                    -ErrorAction SilentlyContinue
            }
            else
            {
                $config = $this.ExportedInstance
            }

            if ($null -ne $config)
            {
                return $this.AsResult(@{
                    Identity                        = $this.Identity
                    AllowBroadcastScheduling        = $config.AllowBroadcastScheduling
                    AllowBroadcastTranscription     = $config.AllowBroadcastTranscription
                    BroadcastAttendeeVisibilityMode = $config.BroadcastAttendeeVisibilityMode
                    BroadcastRecordingMode          = $config.BroadcastRecordingMode
                    Ensure                          = 'Present'
                    Credential                      = $this.Credential
                    ApplicationId                   = $this.ApplicationId
                    TenantId                        = $this.TenantId
                    CertificateThumbprint           = $this.CertificateThumbprint
                    ManagedIdentity                 = $this.ManagedIdentity
                    AccessTokens                    = $this.AccessTokens
                })
            }
            return $this.AsResult($nullReturn)
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

        Write-Verbose -Message "Setting configuration of Teams Meeting Broadcast Policy {$($this.Identity)}"

        # Check that at least one optional parameter is specified
        $inputValues = @()
        foreach ($item in $this.GetBoundParameters().Keys)
        {
            if (-not [System.String]::IsNullOrEmpty($this.GetBoundParameters().$item) -and $item -ne 'Credential' `
                    -and $item -ne 'Identity' -and $item -ne 'Ensure')
            {
                $inputValues += $item
            }
        }

        if ($inputValues.Count -eq 0)
        {
            throw "You need to specify at least one optional parameter for the [TeamsMeetingBroadcastPolicy] instance {$($this.Identity)}"
        }

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $currentValues = $this.Get().ToHashtable()
        $SetParams = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()

        if ($this.Ensure -eq 'Present' -and $currentValues.Ensure -eq 'Absent')
        {
            New-CsTeamsMeetingBroadcastPolicy @SetParams
        }
        elseif ($this.Ensure -eq 'Present' -and $currentValues.Ensure -eq 'Present')
        {
            Set-CsTeamsMeetingBroadcastPolicy @SetParams
        }
        elseif ($this.Ensure -eq 'Absent' -and $currentValues.Ensure -eq 'Present')
        {
            Remove-CsTeamsMeetingBroadcastPolicy -Identity $this.Identity
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
            [array]$policies = Get-CsTeamsMeetingBroadcastPolicy -Filter $this.Filter -ErrorAction Stop

            $i = 1
            $dscContent = [System.Text.StringBuilder]::new()
            Write-M365DSCHost -Message "`r`n" -DeferWrite
            foreach ($policy in $policies)
            {
                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }

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
                Write-M365DSCHost -Message "    |---[$i/$($policies.Length)] $($policy.Identity)" -DeferWrite

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

    hidden [TeamsMeetingBroadcastPolicy] AsResult([System.Object] $Values)
    {
        if ($Values -is [TeamsMeetingBroadcastPolicy])
        {
            return $Values
        }

        $result = [TeamsMeetingBroadcastPolicy]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
