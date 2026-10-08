using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class TeamsUpdateManagementPolicy : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('Identity of the Teams Update Management Policy.')]
    [System.String] $Identity

    [DscProperty()]
    [System.ComponentModel.Description('The description of the Teams Update Management Policy.')]
    [System.String] $Description

    [DscProperty()]
    [System.ComponentModel.Description('Determines if managed updates should be allowed or not.')]
    [System.Nullable[System.Boolean]] $AllowManagedUpdates

    [DscProperty()]
    [System.ComponentModel.Description('Determines if preview builds should be allowed or not.')]
    [System.Nullable[System.Boolean]] $AllowPreview

    [DscProperty()]
    [System.ComponentModel.Description('Determines the ring of public previews to subscribes to.')]
    [ValidateSet('Disabled', 'Enabled', 'Forced', 'FollowOfficePreview')]
    [System.String] $AllowPublicPreview

    [DscProperty()]
    [System.ComponentModel.Description('This setting will force Teams clients to enforce session revocation for core Messaging and Calling/Meeting scenarios. If turned ON, session revocation will be enforced for calls, chats and meetings for opted-in users. If turned OFF, session revocation will not be enforced for calls, chats and meetings for opted-in users.')]
    [System.Nullable[System.Boolean]] $BlockLegacyAuthorization

    [DscProperty()]
    [System.ComponentModel.Description('List of IDs of the categories of the in-product messages that will be disabled. You can choose one of the categories from this table: 91382d07-8b89-444c-bbcb-cfe43133af33 = What''s New. edf2633e-9827-44de-b34c-8b8b9717e84c = Conferences')]
    [ValidateSet('91382d07-8b89-444c-bbcb-cfe43133af33', 'edf2633e-9827-44de-b34c-8b8b9717e84c')]
    [System.String[]] $DisabledInProductMessages

    [DscProperty()]
    [System.ComponentModel.Description('Determines the day of week to perform the updates. Value should be between 0 and 6.')]
    [ValidateRange(0, 6)]
    [System.Nullable[System.UInt32]] $UpdateDayOfWeek

    [DscProperty()]
    [System.ComponentModel.Description('Determines the time of day to perform the updates. Must be a valid HH:MM format string with leading 0. For instance 08:30.')]
    [System.String] $UpdateTime

    [DscProperty()]
    [System.ComponentModel.Description('Determines the time of day to perform the updates. Accepts a DateTime as string. Only the time will be considered.')]
    [System.String] $UpdateTimeOfDay

    [DscProperty()]
    [System.ComponentModel.Description('Determines whether or not users will use the new Teams client.')]
    [ValidateSet('NewTeamsAsDefault', 'UserChoice', 'MicrosoftChoice', 'AdminDisabled', 'NewTeamsOnly')]
    [System.String] $UseNewTeamsClient

    [DscProperty()]
    [System.ComponentModel.Description('Present ensures the policy exists, absent ensures it is removed.')]
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

    [TeamsUpdateManagementPolicy] Get()
    {
        $nullReturn = $null
        if ($this.RequiresPowerShellCore())
        {
            $remote = [TeamsUpdateManagementPolicy]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration for Teams Update Management Policy $($this.Identity)"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.Identity.Replace('Tag:', '') -ne $this.Identity)
            {
                $null = $this.Connect('MicrosoftTeams')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                Write-Verbose -Message 'Checking the Teams Update Management Policies'

                $nullReturn = $this.GetBoundParameters()
                $nullReturn.Ensure = 'Absent'

                $policy = Get-CsTeamsUpdateManagementPolicy -Identity $this.Identity `
                    -ErrorAction SilentlyContinue
            }
            else
            {
                $policy = $this.ExportedInstance
            }

            if ($null -eq $policy)
            {
                Write-Verbose "No Teams Update Management Policy with Identity {$($this.Identity)} was found"
                return $this.AsResult($nullReturn)
            }

            Write-Verbose -Message "Found Teams Update Management Policy with Identity {$($this.Identity)}"
            $results = @{
                Identity                  = $policy.Identity
                DisabledInProductMessages = $policy.DisabledInProductMessages
                Description               = $policy.Description
                AllowManagedUpdates       = $policy.AllowManagedUpdates
                AllowPreview              = $policy.AllowPreview
                AllowPublicPreview        = $policy.AllowPublicPreview
                BlockLegacyAuthorization  = $policy.BlockLegacyAuthorization
                UpdateDayOfWeek           = $policy.UpdateDayOfWeek
                UpdateTime                = $policy.UpdateTime
                UseNewTeamsClient         = $policy.UseNewTeamsClient
                Ensure                    = 'Present'
                Credential                = $this.Credential
                ApplicationId             = $this.ApplicationId
                TenantId                  = $this.TenantId
                CertificateThumbprint     = $this.CertificateThumbprint
                CertificatePath           = $this.CertificatePath
                CertificatePassword       = $this.CertificatePassword
                ManagedIdentity           = $this.ManagedIdentity
                AccessTokens              = $this.AccessTokens
            }
            if (-not [System.String]::IsNullOrEmpty($policy.UpdateTimeOfDay))
            {
                $updateTimeOfDayValue = $policy.UpdateTimeOfDay.ToString('h:mm tt', [System.Globalization.CultureInfo]::InvariantCulture)
                $results.Add('UpdateTimeOfDay', $updateTimeOfDayValue)
            }
            return $this.AsResult($results)
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

        Write-Verbose -Message "Setting configuration for Teams Update Management Policy $($this.Identity)"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $CurrentValues = $this.Get().ToHashtable()
        $boundParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()

        if ($CurrentValues.Ensure -eq 'Absent' -and $this.Ensure -eq 'Present')
        {
            Write-Verbose "Creating new Teams Update Management Policy {$($this.Identity)}"
            $createParameters = $boundParameters
            New-CsTeamsUpdateManagementPolicy @createParameters | Out-Null
        }
        elseif ($CurrentValues.Ensure -eq 'Present' -and $this.Ensure -eq 'Present')
        {
            Write-Verbose "Updating existing Teams Update Management Policy {$($this.Identity)}"
            $updateParameters = $boundParameters
            Set-CsTeamsUpdateManagementPolicy @updateParameters | Out-Null
        }
        elseif ($CurrentValues.Ensure -eq 'Present' -and $this.Ensure -eq 'Absent')
        {
            Write-Verbose "Removing existing Teams Update Management Policy {$($this.Identity)}"
            Remove-CsTeamsUpdateManagementPolicy -Identity $this.Identity | Out-Null
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
            [array]$policies = Get-CsTeamsUpdateManagementPolicy -Filter $this.Filter -ErrorAction Stop
            $i = 1
            $dscContent = [System.Text.StringBuilder]::new()
            Write-M365DSCHost -Message "`r`n" -DeferWrite
            foreach ($policy in $policies)
            {
                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }

                Write-M365DSCHost -Message "    |---[$i/$($policies.Count)] $($policy.Identity.Replace('Tag:', ''))" -DeferWrite
                $params = @{
                    Identity              = $policy.Identity.Replace('Tag:', '')
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
                $result = $this.GetForExport($params)
                $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                    -ConnectionMode $ConnectionMode `
                    -ModulePath $this.GetModulePath() `
                    -Results $result `
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

    hidden [TeamsUpdateManagementPolicy] AsResult([System.Object] $Values)
    {
        if ($Values -is [TeamsUpdateManagementPolicy])
        {
            return $Values
        }

        $result = [TeamsUpdateManagementPolicy]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
