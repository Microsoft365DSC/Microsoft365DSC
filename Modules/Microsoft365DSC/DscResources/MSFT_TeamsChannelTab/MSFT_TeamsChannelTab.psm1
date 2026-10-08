using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class TeamsChannelTab : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('Display Name of the Channel Tab.')]
    [ValidateLength(1, 256)]
    [System.String] $DisplayName

    [DscProperty(Key)]
    [System.ComponentModel.Description('Display Name of the Team.')]
    [ValidateLength(1, 256)]
    [System.String] $TeamName

    [DscProperty(Key)]
    [System.ComponentModel.Description('Display Name of the Channel.')]
    [ValidateLength(1, 256)]
    [System.String] $ChannelName

    [DscProperty()]
    [System.ComponentModel.Description('Unique Id of the Team of the instance on the source tenant.')]
    [System.String] $TeamId

    [DscProperty()]
    [System.ComponentModel.Description('Id of the Teams App associated with the custom tab.')]
    [System.String] $TeamsApp

    [DscProperty()]
    [System.ComponentModel.Description('Index of the sort order for the custom tab.')]
    [System.String] $SortOrderIndex

    [DscProperty()]
    [System.ComponentModel.Description('Container for custom settings applied to a tab.')]
    [MSFT_MicrosoftGraphTeamsTabConfiguration] $Configuration

    [DscProperty()]
    [System.ComponentModel.Description('Present ensures the Tab exists, absent ensures it is removed.')]
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

    [TeamsChannelTab] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [TeamsChannelTab]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of Tab $($this.DisplayName)"

        try
        {
            if ($null -eq $this.ExportedInstance -or $this.ExportedInstance.DisplayName -ne $this.DisplayName)
            {
                $null = $this.Connect('MicrosoftGraph')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullReturn = @{
                    DisplayName = $this.DisplayName
                    TeamName    = $this.TeamName
                    ChannelName = $this.ChannelName
                    Ensure      = 'Absent'
                }

                # Get the Team ID
                try
                {
                    if ([System.String]::IsNullOrEmpty($this.TeamId))
                    {
                        Write-Verbose -Message "Getting team by Name {$($this.TeamName)}"
                        [array]$teamInstance = Get-MgGroup -Filter "resourceProvisioningOptions/Any(x:x eq 'Team') and DisplayName eq '$($this.TeamName -replace "'", "''")'" -All
                        if ($teamInstance.Length -gt 1)
                        {
                            throw "Multiple Teams with name {$($this.TeamName)} were found. Please specify TeamId in your configuration instead."
                        }
                    }
                    else
                    {
                        Write-Verbose -Message "Getting team by Id {$($this.TeamId)}"
                        $teamInstance = Get-MgBetaTeam -TeamId $this.TeamId -ErrorAction Stop
                    }
                }
                catch
                {
                    $this.LogError($_, 'Error retrieving data:')

                    Write-Verbose "The specified Service Principal doesn't have access to read Group information. Permission Required: GroupMember.Read.All & Team.ReadBasic.All"
                }

                if ($null -eq $teamInstance)
                {
                    $Message = "Team {$($this.TeamName)} was not found."
                    $this.LogError($_, $Message)

                    throw $Message
                }

                # Get the Channel ID
                Write-Verbose -Message "Getting Channels for Team {$($this.TeamName)} with ID {$($teamInstance.Id)}"
                $channelInstance = Get-MgBetaTeamChannel -TeamId $teamInstance.Id | Where-Object -FilterScript { $_.DisplayName -eq $this.ChannelName }

                if ($null -eq $channelInstance)
                {
                    $message = "Could not find Channel {$($this.ChannelName)} for Team {$($teamInstance.Id)}"
                    $this.LogError($_, $Message)

                    throw $message
                }

                # Get the Channel Tab
                Write-Verbose -Message "Getting Tabs for Channel {$($this.ChannelName)}"
                [array]$tabInstance = Get-MgBetaTeamChannelTab -TeamId $teamInstance.Id `
                    -ChannelId $channelInstance.Id `
                    -Filter "DisplayName eq '$($this.DisplayName -replace "'", "''")'" `
                    -ExpandProperty 'TeamsApp' `
                    -All `
                    -NoPageSize

                if ($tabInstance.Length -gt 1)
                {
                    throw "More than one instance of a tab with name {$($this.DisplayName)} was found."
                }

                if ($null -eq $tabInstance)
                {
                    $nullReturn.Ensure = 'Absent'
                    $nullReturn.TeamId = $teamInstance.Id
                    return $this.AsResult($nullReturn)
                }
            }
            else
            {
                $teamInstance = $this.ResourceCache['currentTeam']
                $channelInstance = $this.ResourceCache['currentChannel']
                $tabInstance = $this.ExportedInstance
            }

            $complexConfiguration = [ordered]@{}
            $complexConfiguration.Add('ContentUrl', $tabInstance.configuration.contentUrl)
            $complexConfiguration.Add('EntityId', $tabInstance.configuration.entityId)
            $complexConfiguration.Add('RemoveUrl', $tabInstance.configuration.removeUrl)
            $complexConfiguration.Add('WebsiteUrl', $tabInstance.configuration.websiteUrl)
            if ($complexConfiguration.values.Where({ $null -ne $_ }).Count -eq 0)
            {
                $complexConfiguration = $null
            }

            return $this.AsResult(@{
                DisplayName           = $tabInstance.DisplayName
                TeamName              = $this.TeamName
                TeamId                = $teamInstance.Id
                ChannelName           = $channelInstance.DisplayName
                SortOrderIndex        = $tabInstance.SortOrderIndex
                Configuration         = $complexConfiguration
                TeamsApp              = $tabInstance.teamsApp.id
                Credential            = $this.Credential
                ApplicationId         = $this.ApplicationId
                TenantId              = $this.TenantID
                CertificateThumbprint = $this.CertificateThumbprint
                Ensure                = 'Present'
                ManagedIdentity       = $this.ManagedIdentity
                AccessTokens          = $this.AccessTokens
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

        Write-Verbose -Message "Setting configuration of Team $($this.DisplayName)"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $tab = $this.Get().ToHashtable()

        $CurrentParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()

        Write-Verbose -Message "Retrieving Team Channel {$($this.ChannelName)} from Team {$($tab.TeamId)}"
        $ChannelInstance = Get-MgBetaTeamChannel -TeamId $tab.TeamId `
            -Filter "DisplayName eq '$($this.ChannelName -replace "'", "''")'" `
            -All `
            -NoPageSize

        $CurrentParameters = Rename-M365DSCCimInstanceParameter -Properties $CurrentParameters
        $CurrentParameters.Remove('TeamsApp') | Out-Null

        if ($null -ne $CurrentParameters.Configuration)
        {
            foreach ($key in @($CurrentParameters.Configuration.Keys))
            {
                if ([System.String]::IsNullOrEmpty($CurrentParameters.Configuration[$key]))
                {
                    $CurrentParameters.Configuration.Remove($key) | Out-Null
                }
            }
        }

        if ($this.Ensure -eq 'Present' -and ($tab.Ensure -eq 'Present'))
        {
            Write-Verbose -Message "Retrieving Tab {$($this.DisplayName)} from Channel {$($ChannelInstance.Id))} from Team {$($tab.TeamId)}"
            $tabInstance = Get-MgBetaTeamChannelTab -TeamId $tab.TeamId `
                -ChannelId $ChannelInstance.Id `
                -Filter "DisplayName eq '$($this.DisplayName -replace "'", "''")'" `
                -All `
                -NoPageSize

            $CurrentParameters.Remove('TeamId') | Out-Null
            $CurrentParameters.Remove('TeamName') | Out-Null
            $CurrentParameters.Remove('ChannelName') | Out-Null
            Write-Verbose -Message "Params: $($CurrentParameters | Out-String)"
            Update-MgBetaTeamChannelTab -TeamId $tab.TeamId -ChannelId $ChannelInstance.Id -TeamsTabId $tabInstance.Id -BodyParameter $CurrentParameters | Out-Null
        }
        elseif ($this.Ensure -eq 'Present' -and ($tab.Ensure -eq 'Absent'))
        {
            Write-Verbose -Message "Creating new tab {$($this.DisplayName)}"
            $CurrentParameters.Remove('TeamId') | Out-Null
            $CurrentParameters.Remove('TeamName') | Out-Null
            $CurrentParameters.Remove('ChannelName') | Out-Null
            Write-Verbose -Message "Params: $($CurrentParameters | Out-String)"

            $CurrentParameters.Add('teamsApp@odata.bind', "$((Get-MSCloudLoginConnectionProfile -Workload MicrosoftGraph).ResourceUrl)v1.0/appCatalogs/teamsApps/$($this.TeamsApp)")
            New-MgBetaTeamChannelTab -ChannelId $ChannelInstance.Id -TeamId $tab.TeamId -BodyParameter $CurrentParameters
        }
        elseif ($this.Ensure -eq 'Absent' -and ($tab.Ensure -eq 'Present'))
        {
            Write-Verbose -Message "Retrieving Tab {$($this.DisplayName)} from Channel {$($ChannelInstance.Id))} from Team {$($tab.TeamId)}"
            $tabInstance = Get-MgBetaTeamChannelTab -TeamId $tab.TeamId `
                -ChannelId $ChannelInstance.Id `
                -Filter "DisplayName eq '$($this.DisplayName -replace "'", "''")'" `
                -All `
                -NoPageSize
            Write-Verbose -Message "Removing existing tab {$($this.DisplayName)}"
            Remove-MgBetaTeamChannelTab -TeamId $tab.TeamId -ChannelId $ChannelInstance.Id -TeamsTabId $tabInstance.Id | Out-Null
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

        $ConnectionMode = $this.Connect('MicrosoftGraph')

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Export')

        try
        {
            [array]$teams = Get-MgGroup -Filter "resourceProvisioningOptions/Any(x:x eq 'Team')" -All
            $i = 1
            $dscContent = [System.Text.StringBuilder]::new()
            Write-M365DSCHost -Message "`r`n" -DeferWrite
            foreach ($team in $teams)
            {
                Write-M365DSCHost -Message "    |---[$i/$($teams.Length)] $($team.DisplayName)"

                $channels = $null
                try
                {
                    [array]$channels = Get-MgBetaTeamChannel -TeamId $team.Id -ErrorAction Stop
                }
                catch
                {
                    $message = "        $($Global:M365DSCEmojiRedX) The specified Service Principal doesn't have access to read Channel information. Permission Required: Channel.ReadBasic.All"
                    $this.LogError($_, $Message)
                }

                $j = 1
                foreach ($channel in $channels)
                {
                    Write-M365DSCHost -Message "        |---[$j/$($channels.Length)] $($channel.DisplayName)"

                    $tabs = $null
                    try
                    {
                        [array]$tabs = Get-MgBetaTeamChannelTab -TeamId $team.Id `
                            -ChannelId $channel.Id -ErrorAction Stop
                    }
                    catch
                    {
                        $message = "            $($Global:M365DSCEmojiRedX) The specified Service Principal doesn't have access to read Tab information. Permission Required: TeamsTab.Read.All"
                        $this.LogError($_, $Message)
                    }

                    $k = 1
                    foreach ($tab in $tabs)
                    {
                        if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                        {
                            $Global:M365DSCExportResourceInstancesCount++
                        }

                        Write-M365DSCHost -Message "            |---[$k/$($tabs.Length)] $($tab.DisplayName)" -DeferWrite
                        $params = @{
                            TeamName              = $team.DisplayName
                            TeamId                = $team.Id
                            ChannelName           = $channel.DisplayName
                            DisplayName           = $tab.DisplayName
                            Credential            = $this.Credential
                            ApplicationId         = $this.ApplicationId
                            TenantId              = $this.TenantId
                            CertificateThumbprint = $this.CertificateThumbprint
                            CertificatePath       = $this.CertificatePath
                            CertificatePassword   = $this.CertificatePassword
                            ManagedIdentity       = $this.ManagedIdentity
                            AccessTokens          = $this.AccessTokens
                        }

                        $this.ExportedInstance = $tab
                        $this.ResourceCache['currentTeam'] = $team
                        $this.ResourceCache['currentChannel'] = $channel
                        $Results = $this.GetForExport($Params)
                        $rawResults = $Results.Clone()
                        if ($Results -is [System.Collections.Hashtable] -and $Results.Count -gt 3)
                        {
                            if ($null -ne $Results.Configuration)
                            {
                                $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                                    -ComplexObject $Results.Configuration `
                                    -CIMInstanceName 'MicrosoftGraphTeamsTabConfiguration'
                                if (-not [System.String]::IsNullOrWhiteSpace($complexTypeStringResult))
                                {
                                    $Results.Configuration = $complexTypeStringResult
                                }
                                else
                                {
                                    $Results.Remove('Configuration') | Out-Null
                                }
                            }

                            $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                                -ConnectionMode $ConnectionMode `
                                -ModulePath $this.GetModulePath() `
                                -Results $Results `
                                -Credential $this.Credential `
                                -NoEscape @('Configuration') `
                                -RawResults $rawResults

                            [void]$dscContent.Append($currentDSCBlock)
                            Save-M365DSCPartialExport -Content $currentDSCBlock `
                                -FileName $Global:PartialExportFileName

                            Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
                        }
                        else
                        {
                            Write-M365DSCHost -Message $Global:M365DSCEmojiRedX -CommitWrite
                        }
                        $k++
                    }
                    $j++
                }
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

    hidden [TeamsChannelTab] AsResult([System.Object] $Values)
    {
        if ($Values -is [TeamsChannelTab])
        {
            return $Values
        }

        $result = [TeamsChannelTab]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}

class MSFT_MicrosoftGraphTeamsTabConfiguration
{
    [DscProperty()]
    [System.ComponentModel.Description('Url used for rendering tab contents in Teams.')]
    [System.String] $ContentUrl

    [DscProperty()]
    [System.ComponentModel.Description('Identifier for the entity hosted by the tab provider.')]
    [System.String] $EntityId

    [DscProperty()]
    [System.ComponentModel.Description('Url called by Teams client when a Tab is removed using the Teams client.')]
    [System.String] $RemoveUrl

    [DscProperty()]
    [System.ComponentModel.Description('Url for showing tab contents outside of Teams.')]
    [System.String] $WebsiteUrl
}
