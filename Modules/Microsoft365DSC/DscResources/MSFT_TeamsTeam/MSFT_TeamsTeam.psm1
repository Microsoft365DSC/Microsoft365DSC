using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class TeamsTeam : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('Display Name of the Team')]
    [ValidateLength(1, 256)]
    [System.String] $DisplayName

    [DscProperty()]
    [System.ComponentModel.Description('Description of Team.')]
    [ValidateLength(0, 1024)]
    [System.String] $Description

    [DscProperty()]
    [System.ComponentModel.Description('Team group ID, only used to target a Team when duplicated display names occurs.')]
    [System.String] $GroupID

    [DscProperty()]
    [System.ComponentModel.Description('MailNickName of O365 Group associated with Team')]
    [System.String] $MailNickName

    [DscProperty()]
    [System.ComponentModel.Description('Owners of the Team. At least one entry is required.')]
    [System.String[]] $Owner

    [DscProperty()]
    [System.ComponentModel.Description('Visibility of the Team')]
    [ValidateSet('Public', 'Private', 'HiddenMembership')]
    [System.String] $Visibility

    [DscProperty()]
    [System.ComponentModel.Description('Allow add or remove apps from the Team.')]
    [System.Nullable[System.Boolean]] $AllowAddRemoveApps

    [DscProperty()]
    [System.ComponentModel.Description('Allow giphy in Team.')]
    [System.Nullable[System.Boolean]] $AllowGiphy

    [DscProperty()]
    [System.ComponentModel.Description('Giphy content rating of the Team.')]
    [ValidateSet('Strict', 'Moderate')]
    [System.String] $GiphyContentRating

    [DscProperty()]
    [System.ComponentModel.Description('Allow stickers and mimes in the Team.')]
    [System.Nullable[System.Boolean]] $AllowStickersAndMemes

    [DscProperty()]
    [System.ComponentModel.Description('Allow custom memes in Team.')]
    [System.Nullable[System.Boolean]] $AllowCustomMemes

    [DscProperty()]
    [System.ComponentModel.Description('Allow members to edit messages within Team.')]
    [System.Nullable[System.Boolean]] $AllowUserEditMessages

    [DscProperty()]
    [System.ComponentModel.Description('Allow members to delete messages within Team.')]
    [System.Nullable[System.Boolean]] $AllowUserDeleteMessages

    [DscProperty()]
    [System.ComponentModel.Description('Allow owners to delete messages within Team.')]
    [System.Nullable[System.Boolean]] $AllowOwnerDeleteMessages

    [DscProperty()]
    [System.ComponentModel.Description('Allow members to delete channels within Team.')]
    [System.Nullable[System.Boolean]] $AllowDeleteChannels

    [DscProperty()]
    [System.ComponentModel.Description('Determines whether private channel creation is allowed for the team.')]
    [System.Nullable[System.Boolean]] $AllowCreatePrivateChannels

    [DscProperty()]
    [System.ComponentModel.Description('Allow members to manage connectors within Team.')]
    [System.Nullable[System.Boolean]] $AllowCreateUpdateRemoveConnectors

    [DscProperty()]
    [System.ComponentModel.Description('Allow members to manage tabs within Team.')]
    [System.Nullable[System.Boolean]] $AllowCreateUpdateRemoveTabs

    [DscProperty()]
    [System.ComponentModel.Description('Allow mentions in Team.')]
    [System.Nullable[System.Boolean]] $AllowTeamMentions

    [DscProperty()]
    [System.ComponentModel.Description('Allow channel mention in Team.')]
    [System.Nullable[System.Boolean]] $AllowChannelMentions

    [DscProperty()]
    [System.ComponentModel.Description('Allow guests to create and update channels in Team.')]
    [System.Nullable[System.Boolean]] $AllowGuestCreateUpdateChannels

    [DscProperty()]
    [System.ComponentModel.Description('Allow guests to delete channel in Team.')]
    [System.Nullable[System.Boolean]] $AllowGuestDeleteChannels

    [DscProperty()]
    [System.ComponentModel.Description('Allow members to create and update channels within Team.')]
    [System.Nullable[System.Boolean]] $AllowCreateUpdateChannels

    [DscProperty()]
    [System.ComponentModel.Description('determines whether or not private teams should be searchable from Teams clients for users who do not belong to that team.  Set to $false to make those teams not discoverable from Teams clients.')]
    [System.Nullable[System.Boolean]] $ShowInTeamsSearchAndSuggestions

    [DscProperty()]
    [System.ComponentModel.Description('Present ensures the Team exists, absent ensures it is removed.')]
    [ValidateSet('Present', 'Absent')]
    [System.String] $Ensure

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

    [TeamsTeam] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [TeamsTeam]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of Team $($this.DisplayName)"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.DisplayName -ne $this.DisplayName)
            {
                $ConnectionMode = $this.Connect('MicrosoftTeams')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullReturn = $this.GetBoundParameters()
                $nullReturn.Ensure = 'Absent'

                Write-Verbose -Message "Checking for existence of Team $($this.DisplayName)"

                ## will only return 1 instance
                if ($this.GetBoundParameters().ContainsKey('GroupID'))
                {
                    Write-Verbose -Message 'GroupID was specified'
                    $team = Get-Team -GroupId $this.GroupID
                    if ($null -eq $team)
                    {
                        Write-Verbose -Message "Teams with GroupId $($this.GroupID) doesn't exist"
                        return $this.AsResult($nullReturn)
                    }
                }
                else
                {
                    Write-Verbose -Message 'GroupID was NOT specified'
                    ## Can retreive multiple Teams since displayname is not unique
                    # Filter on DisplayName as -DisplayName also does partial matches and will report duplicate names that are not real duplicate names
                    $team = Get-Team -DisplayName $this.DisplayName | Where-Object { $_.DisplayName -eq $this.DisplayName }
                    if ($null -eq $team)
                    {
                        Write-Verbose -Message "Teams with displayname $($this.DisplayName) doesn't exist"
                        return $this.AsResult($nullReturn)
                    }
                    if ($team.Length -gt 1)
                    {
                        throw "Duplicate Teams name $($this.DisplayName) exist in tenant"
                    }
                }
            }
            else
            {
                $team = $this.ExportedInstance
            }

            Write-Verbose -Message "Getting Team {$($this.DisplayName)} Owners"
            [array]$Owners = Get-TeamUser -GroupId $team.GroupId | Where-Object { $_.Role -eq 'owner' }
            if ($null -eq $Owners)
            {
                # Without Users, Get-TeamUser returns null instead of an empty array
                $Owners = @()
            }

            Write-Verbose -Message "Found Team $($team.DisplayName)."

            $result = @{
                DisplayName                       = $team.DisplayName
                GroupID                           = $team.GroupId
                Description                       = $team.Description
                Owner                             = [array]$Owners.User
                MailNickName                      = $team.MailNickName
                Visibility                        = $team.Visibility
                AllowAddRemoveApps                = $team.AllowAddRemoveApps
                AllowGiphy                        = $team.AllowGiphy
                GiphyContentRating                = $team.GiphyContentRating
                AllowStickersAndMemes             = $team.AllowStickersAndMemes
                AllowCustomMemes                  = $team.AllowCustomMemes
                AllowUserEditMessages             = $team.AllowUserEditMessages
                AllowUserDeleteMessages           = $team.AllowUserDeleteMessages
                AllowOwnerDeleteMessages          = $team.AllowOwnerDeleteMessages
                AllowCreatePrivateChannels        = $team.AllowCreatePrivateChannels
                AllowCreateUpdateRemoveConnectors = $team.AllowCreateUpdateRemoveConnectors
                AllowCreateUpdateRemoveTabs       = $team.AllowCreateUpdateRemoveTabs
                AllowTeamMentions                 = $team.AllowTeamMentions
                AllowChannelMentions              = $team.AllowChannelMentions
                AllowGuestCreateUpdateChannels    = $team.AllowGuestCreateUpdateChannels
                AllowGuestDeleteChannels          = $team.AllowGuestDeleteChannels
                AllowCreateUpdateChannels         = $team.AllowCreateUpdateChannels
                AllowDeleteChannels               = $team.AllowDeleteChannels
                ShowInTeamsSearchAndSuggestions   = $team.ShowInTeamsSearchAndSuggestions
                Ensure                            = 'Present'
                Credential                        = $this.Credential
                ApplicationId                     = $this.ApplicationId
                TenantId                          = $this.TenantId
                CertificateThumbprint             = $this.CertificateThumbprint
                CertificatePath                   = $this.CertificatePath
                CertificatePassword               = $this.CertificatePassword
                ManagedIdentity                   = $this.ManagedIdentity
                AccessTokens                      = $this.AccessTokens
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

        Write-Verbose -Message "Setting configuration of Team $($this.DisplayName)"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $ConnectionMode = $this.Connect('MicrosoftTeams')

        $team = $this.Get().ToHashtable()
        $CurrentParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()

        if ($this.Ensure -eq 'Present' -and ($team.Ensure -eq 'Present'))
        {
            ## Can't pass Owner parm into set opertaion
            if ($CurrentParameters.ContainsKey('Owner'))
            {
                $CurrentParameters.Remove('Owner') | Out-Null
            }
            if (-not $CurrentParameters.ContainsKey('GroupID'))
            {
                $CurrentParameters.Add('GroupID', $team.GroupID)
            }
            Set-Team @CurrentParameters
            Write-Verbose -Message "Updating team $($this.DisplayName)"
        }
        elseif ($this.Ensure -eq 'Present' -and ($team.Ensure -eq 'Absent'))
        {
            ## GroupID not used on New-Team cmdlet
            if ($CurrentParameters.ContainsKey('GroupID'))
            {
                $CurrentParameters.Remove('GroupID') | Out-Null
            }
            Write-Verbose -Message "Creating team $($this.DisplayName)"
            if ($null -ne $this.Owner)
            {
                $CurrentParameters.Owner = [array](($this.Owner[0]).ToString())
            }
            Write-Verbose -Message "Connection mode: $ConnectionMode"
            if ($ConnectionMode.StartsWith('ServicePrincipal'))
            {
                $ConnectionMode = $this.Connect('MicrosoftGraph')
                $graphUrl = (Get-MSCloudLoginConnectionProfile -Workload MicrosoftGraph).ResourceUrl
                $ownerUrls = @()
                foreach ($currentOwner in $this.Owner)
                {
                    Write-Verbose -Message "Retrieving Group Owner {$currentOwner}"
                    $ownerUser = Get-MgUser -UserId $currentOwner -ErrorAction Stop
                    $ownerUrls += "$($graphUrl)v1.0/directoryObjects/$($ownerUser.Id)"
                }

                $group = $null
                if (-not [System.String]::IsNullOrEmpty($this.MailNickName))
                {
                    $group = Get-MgGroup -Filter "mailNickname eq '$($this.MailNickName.Replace("'", "''"))'" -ErrorAction SilentlyContinue |
                        Where-Object -Property GroupTypes -Contains 'Unified' |
                        Select-Object -First 1
                }

                if ($null -eq $group)
                {
                    $groupBody = @{
                        displayName     = $this.DisplayName
                        groupTypes      = @('Unified')
                        mailEnabled     = $true
                        securityEnabled = $true
                        mailNickname    = $this.MailNickName
                    }
                    if (-not [System.String]::IsNullOrEmpty($this.Description))
                    {
                        $groupBody.description = $this.Description
                    }
                    if (-not [System.String]::IsNullOrEmpty($this.Visibility))
                    {
                        $groupBody.visibility = $this.Visibility
                    }
                    if ($ownerUrls.Count -gt 0)
                    {
                        $groupBody.'owners@odata.bind' = $ownerUrls
                    }
                    Write-Verbose -Message "Creating group {$($this.MailNickName)} for team $($this.DisplayName)"
                    $group = New-MgGroup -BodyParameter $groupBody -ErrorAction Stop
                }
                else
                {
                    Write-Verbose -Message "Using existing group {$($group.Id)} for team $($this.DisplayName)"
                    $existingOwnerIds = @((Get-MgGroupOwner -GroupId $group.Id -All -ErrorAction Stop).Id)
                    foreach ($ownerUrl in $ownerUrls)
                    {
                        if ($existingOwnerIds -notcontains $ownerUrl.Split('/')[-1])
                        {
                            Write-Verbose -Message "Adding Owner {$ownerUrl} to Group {$($group.Id)}"
                            New-MgGroupOwnerByRef -GroupId $group.Id -BodyParameter @{ '@odata.id' = $ownerUrl } -ErrorAction Stop
                        }
                    }
                }

                try
                {
                    New-Team -GroupId $group.Id -ErrorAction Stop
                }
                catch
                {
                    Write-Verbose -Message 'Creating Team - Sleeping for 15 seconds'
                    Start-Sleep -Seconds 15
                    New-Team -GroupId $group.Id -ErrorAction Stop
                }

                $settingParameters = ([System.Collections.Hashtable]$CurrentParameters).Clone()
                $settingParameters.Remove('Owner') | Out-Null
                if ($this.Visibility -eq 'HiddenMembership')
                {
                    $settingParameters.Remove('Visibility') | Out-Null
                }
                $settingParameters.GroupId = $group.Id
                Write-Verbose -Message "Applying the settings of team $($this.DisplayName)"
                try
                {
                    Set-Team @settingParameters -ErrorAction Stop
                }
                catch
                {
                    Write-Verbose -Message 'Updating Team - Sleeping for 15 seconds'
                    Start-Sleep -Seconds 15
                    Set-Team @settingParameters -ErrorAction Stop
                }
            }
            else
            {
                Write-Verbose -Message 'Using Credentials to authenticate.'
                if (-not $this.Owner -or $this.Owner.Length -eq 0)
                {
                    $OwnerValue = $this.Credential.UserName
                }
                else
                {
                    $OwnerValue = $this.Owner[0].ToString()
                }
                $CurrentParameters.Owner = [System.String]$OwnerValue
                Write-Verbose -Message "Creating team with Values: $(Convert-M365DscHashtableToString -Hashtable $CurrentParameters)"
                $newTeam = New-Team @CurrentParameters
                Write-Verbose -Message "Team {$($this.DisplayName)} was just created."

                for ($i = 1; $i -lt $this.Owner.Length; $i++)
                {
                    Add-TeamUser -GroupId $newTeam.GroupId -User $this.Owner[$i] -Role 'Owner'
                }
            }
        }
        elseif ($this.Ensure -eq 'Absent' -and ($team.Ensure -eq 'Present'))
        {
            Write-Verbose -Message "Removing team $($this.DisplayName)"
            Remove-Team -GroupId $team.GroupId
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
            $teams = Get-Team | Sort-Object -Property GroupId
            $i = 1
            $dscContent = [System.Text.StringBuilder]::new()
            Write-M365DSCHost -Message "`r`n" -DeferWrite
            foreach ($team in $teams)
            {
                # Skip Teams without DisplayName (orphaned/deleted Teams) because the Get method cannot be called without a display name
                if ($null -ne $team.DisplayName -and $team.DisplayName -ne '')
                {
                    if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                    {
                        $Global:M365DSCExportResourceInstancesCount++
                    }

                    Write-M365DSCHost -Message "    |---[$i/$($teams.Length)] $($team.DisplayName)" -DeferWrite
                    $params = @{
                        DisplayName           = $team.DisplayName
                        GroupID               = $team.GroupId
                        Credential            = $this.Credential
                        ApplicationId         = $this.ApplicationId
                        TenantId              = $this.TenantId
                        CertificateThumbprint = $this.CertificateThumbprint
                        CertificatePath       = $this.CertificatePath
                        CertificatePassword   = $this.CertificatePassword
                        ManagedIdentity       = $this.ManagedIdentity
                        AccessTokens          = $this.AccessTokens
                    }

                    $this.ExportedInstance = $team
                    $Results = $this.GetForExport($Params)
                    $rawResults = $Results.Clone()
                    $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                        -ConnectionMode $ConnectionMode `
                        -ModulePath $this.GetModulePath() `
                        -Results $Results `
                        -Credential $this.Credential `
                        -RawResults $rawResults
                    [void]$dscContent.Append($currentDSCBlock)
                    Save-M365DSCPartialExport -Content $currentDSCBlock `
                        -FileName $Global:PartialExportFileName
                    $i++
                    Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
                }
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
            ExcludedProperties = @('GroupID')
        }
    }

    hidden [TeamsTeam] AsResult([System.Object] $Values)
    {
        if ($Values -is [TeamsTeam])
        {
            return $Values
        }

        $result = [TeamsTeam]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
