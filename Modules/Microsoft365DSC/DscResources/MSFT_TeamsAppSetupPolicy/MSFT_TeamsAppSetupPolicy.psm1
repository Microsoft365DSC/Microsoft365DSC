using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class TeamsAppSetupPolicy : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('Unique identifier to be assigned to the new Teams app setup policy. Use the ''Global'' Identity if you wish to assign this policy to the entire tenant.')]
    [System.String] $Identity

    [DscProperty()]
    [System.ComponentModel.Description('Enables administrators to provide explanatory text to accompany a Teams app setup policy.')]
    [System.String] $Description

    [DscProperty()]
    [System.ComponentModel.Description('Choose which apps and messaging extensions you want to be installed in your users'' personal Teams environment and in meetings they create. Users can install other available apps from the Teams app store.')]
    [System.String[]] $AppPresetList

    [DscProperty()]
    [System.ComponentModel.Description('Choose which apps and meeting extensions you want to be installed in your users'' personal Teams environment and in meetings they create. Users can install other available apps from the Teams app store.')]
    [System.String[]] $AppPresetMeetingList

    [DscProperty()]
    [System.ComponentModel.Description('Pinning an app displays the app in the app bar in Teams client. Admins can pin apps and they can allow users to pin apps. Pinning is used to highlight apps that are needed the most by users and promote ease of access.')]
    [System.String[]] $PinnedAppBarApps

    [DscProperty()]
    [System.ComponentModel.Description('Determines the list of apps that are pre pinned for a participant in Calls.')]
    [System.String[]] $PinnedCallingBarApps

    [DscProperty()]
    [System.ComponentModel.Description('Apps are pinned in messaging extensions and into the ellipsis menu.')]
    [System.String[]] $PinnedMessageBarApps

    [DscProperty()]
    [System.ComponentModel.Description('If you turn this on, the user''s existing app pins will be added to the list of pinned apps set in this policy. Users can rearrange, add, and remove pins as they choose. If you turn this off, the user''s existing app pins will be removed and replaced with the apps defined in this policy.')]
    [System.Nullable[System.Boolean]] $AllowUserPinning

    [DscProperty()]
    [System.ComponentModel.Description('This is also known as side loading. This setting determines if a user can upload a custom app package in the Teams app. Turning it on lets you create or develop a custom app to be used personally or across your organization without having to submit it to the Teams app store. Uploading a custom app also lets you test an app before you distribute it more widely by only assigning it to a single user or group of users.')]
    [System.Nullable[System.Boolean]] $AllowSideLoading

    [DscProperty()]
    [System.ComponentModel.Description('Present ensures the instance exists, absent ensures it is removed.')]
    [ValidateSet('Present', 'Absent')]
    [System.String] $Ensure

    [DscProperty()]
    [System.ComponentModel.Description('Credentials of the workload''s Admin')]
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
    [System.String] $Filter = '*'

    # Export-only. Not part of the resource schema.
    [System.Management.Automation.PSCredential] $ApplicationSecret

    [TeamsAppSetupPolicy] Get()
    {
        $nullResult = $null
        if ($this.RequiresPowerShellCore())
        {
            $remote = [TeamsAppSetupPolicy]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration for TeamsAppSetupPolicy $($this.Identity)"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.Identity -ne $this.Identity)
            {
                $null = $this.Connect('MicrosoftTeams')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullResult = $this.GetBoundParameters()
                $nullResult.Ensure = 'Absent'

                $instance = Get-CsTeamsAppSetupPolicy -Identity $this.Identity -ErrorAction SilentlyContinue
            }
            else
            {
                $instance = $this.ExportedInstance
            }

            if ($null -eq $instance)
            {
                return $this.AsResult($nullResult)
            }

            $appPresetListValue = $instance.AppPresetList.Id
            if ($instance.AppPresetList.Count -eq 0)
            {
                $appPresetListValue = @()
            }

            $appPresetMeetingListValue = $instance.AppPresetMeetingList.Id
            if ($instance.AppPresetMeetingList.Count -eq 0)
            {
                $appPresetMeetingListValue = @()
            }

            $pinnedAppBarAppsValue = $instance.PinnedAppBarApps.Id
            if ($instance.PinnedAppBarApps.Count -eq 0)
            {
                $pinnedAppBarAppsValue = @()
            }

            $pinnedCallingBarAppsValue = $instance.PinnedCallingBarApps.Id
            if ($instance.PinnedCallingBarApps.Count -eq 0)
            {
                $pinnedCallingBarAppsValue = @()
            }

            $pinnedMessageBarAppsValue = $instance.PinnedMessageBarApps.Id
            if ($instance.PinnedMessageBarApps.Count -eq 0)
            {
                $pinnedMessageBarAppsValue = @()
            }

            Write-Verbose -Message "Found an instance with Identity {$($this.Identity)}"
            $results = @{
                Identity              = $instance.Identity.Replace('Tag:', '')
                Description           = $instance.Description
                AppPresetList         = [Array]$appPresetListValue
                AppPresetMeetingList  = [Array]$appPresetMeetingListValue
                PinnedAppBarApps      = [Array]$pinnedAppBarAppsValue
                PinnedCallingBarApps  = [Array]$pinnedCallingBarAppsValue
                PinnedMessageBarApps  = [Array]$pinnedMessageBarAppsValue
                AllowUserPinning      = $instance.AllowUserPinning
                AllowSideLoading      = $instance.AllowSideLoading
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

        Write-Verbose -Message "Setting configuration for TeamsAppSetupPolicy $($this.Identity)"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $currentInstance = $this.Get().ToHashtable()

        $appPresetValues = @()
        if ($null -ne $this.AppPresetList -and ([Array]$this.AppPresetList).Count -gt 0)
        {
            foreach ($appInstance in $this.AppPresetList)
            {
                $appPresetValues += New-Object -TypeName 'Microsoft.Teams.Policy.Administration.Cmdlets.Core.AppPreset' -ArgumentList $appInstance
            }
        }

        $appPresetMeetingValues = @()
        if ($null -ne $this.AppPresetMeetingList -and ([Array]$this.AppPresetMeetingList).Count -gt 0)
        {
            foreach ($appInstance in $this.AppPresetMeetingList)
            {
                $appPresetMeetingValues += New-Object -TypeName 'Microsoft.Teams.Policy.Administration.Cmdlets.Core.AppPresetMeeting' -ArgumentList $appInstance
            }
        }

        $pinnedAppBarAppsValue = @()
        if ($null -ne $this.PinnedAppBarApps -and ([Array]$this.PinnedAppBarApps).Count -gt 0)
        {
            $i = 1
            foreach ($appInstance in $this.PinnedAppBarApps)
            {
                $pinnedAppBarAppsValue += New-Object -TypeName 'Microsoft.Teams.Policy.Administration.Cmdlets.Core.PinnedApp' -ArgumentList $appInstance, $i
                $i++
            }
        }

        $pinnedCallingBarAppsValue = @()
        if ($null -ne $this.PinnedCallingBarApps -and ([Array]$this.PinnedCallingBarApps).Count -gt 0)
        {
            foreach ($appInstance in $this.PinnedCallingBarApps)
            {
                $pinnedCallingBarAppsValue += New-Object -TypeName 'Microsoft.Teams.Policy.Administration.Cmdlets.Core.PinnedCallingBarApp' -ArgumentList $appInstance
            }
        }

        $pinnedMessageBarAppsValue = @()
        if ($null -ne $this.PinnedMessageBarApps -and ([Array]$this.PinnedMessageBarApps).Count -gt 0)
        {
            $i = 1
            foreach ($appInstance in $this.PinnedMessageBarApps)
            {
                $pinnedMessageBarAppsValue += New-Object -TypeName 'Microsoft.Teams.Policy.Administration.Cmdlets.Core.PinnedMessageBarApp' -ArgumentList $appInstance, $i
                $i++
            }
        }

        if ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
        {
            $createParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()
            $createParameters.Remove('Verbose') | Out-Null
            Write-Verbose -Message "Creating the Teams App Setup Policy {$($this.Identity)} with Parameters:`r`n$(Convert-M365DscHashtableToString -Hashtable $createParameters)"

            $createParameters.AppPresetList = $appPresetValues
            $createParameters.AppPresetMeetingList = $appPresetMeetingValues
            $createParameters.PinnedAppBarApps = $pinnedAppBarAppsValue
            $createParameters.PinnedCallingBarApps = $pinnedCallingBarAppsValue
            $createParameters.PinnedMessageBarApps = $pinnedMessageBarAppsValue

            New-CsTeamsAppSetupPolicy @createParameters | Out-Null
        }
        elseif ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Present')
        {
            $updateParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()
            $updateParameters.Remove('Verbose') | Out-Null
            Write-Verbose -Message "Updating the Teams App Setup Policy with Identity {$($this.Identity)}"

            $updateParameters.AppPresetList = $appPresetValues
            $updateParameters.AppPresetMeetingList = $appPresetMeetingValues
            $updateParameters.PinnedAppBarApps = $pinnedAppBarAppsValue
            $updateParameters.PinnedCallingBarApps = $pinnedCallingBarAppsValue
            $updateParameters.PinnedMessageBarApps = $pinnedMessageBarAppsValue

            Set-CsTeamsAppSetupPolicy @updateParameters | Out-Null
        }
        elseif ($this.Ensure -eq 'Absent' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Removing the Teams App Setup Policy with Identity {$($this.Identity)}"
            Remove-CsTeamsAppSetupPolicy -Identity $currentInstance.Identity
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
            [array]$getValue = Get-CsTeamsAppSetupPolicy -Filter $this.Filter -ErrorAction Stop

            $i = 1
            $dscContent = [System.Text.StringBuilder]::new()
            if ($getValue.Length -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
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
                Write-M365DSCHost -Message "    |---[$i/$($getValue.Count)] $displayedKey" -DeferWrite
                $params = @{
                    Identity              = $config.Identity
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

                $this.ExportedInstance = $config
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

    hidden [TeamsAppSetupPolicy] AsResult([System.Object] $Values)
    {
        if ($Values -is [TeamsAppSetupPolicy])
        {
            return $Values
        }

        $result = [TeamsAppSetupPolicy]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
