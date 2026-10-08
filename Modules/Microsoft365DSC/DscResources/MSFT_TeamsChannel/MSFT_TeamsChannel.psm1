using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class TeamsChannel : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('Current channel name')]
    [ValidateLength(1, 50)]
    [System.String] $DisplayName

    [DscProperty(Key)]
    [System.ComponentModel.Description('Name of the team the Channel belongs to')]
    [System.String] $TeamName

    [DscProperty()]
    [System.ComponentModel.Description('Team group ID, only used to target a Team when duplicated display names occurs.')]
    [System.String] $GroupID

    [DscProperty()]
    [System.ComponentModel.Description('Used to update current channel name')]
    [ValidateLength(0, 50)]
    [System.String] $NewDisplayName

    [DscProperty()]
    [System.ComponentModel.Description('Channel description')]
    [ValidateLength(1, 1024)]
    [System.String] $Description

    [DscProperty()]
    [System.ComponentModel.Description('Present ensures the Team channel exists, absent ensures it is removed')]
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

    [TeamsChannel] Get()
    {
        $team = $null
        if ($this.RequiresPowerShellCore())
        {
            $remote = [TeamsChannel]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of Teams channel $($this.DisplayName)"

        try
        {
            if ($null -eq $this.ExportedInstance -or $this.ExportedInstance.DisplayName -ne $this.DisplayName)
            {
                $null = $this.Connect('MicrosoftTeams')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullReturn = $this.GetBoundParameters()
                $nullReturn.Ensure = 'Absent'
                Write-Verbose -Message 'Checking for existance of team channels'

                if (-not [System.String]::IsNullOrEmpty($this.GroupId))
                {
                    $team = Get-Team -GroupId $this.GroupId -ErrorAction 'SilentlyContinue'
                }

                if ($null -eq $team)
                {
                    $team = Get-TeamByName ([System.Net.WebUtility]::UrlEncode($this.TeamName))
                }

                if ($null -eq $team)
                {
                    return $this.AsResult($nullReturn)
                }

                Write-Verbose -Message "Retrieve team GroupId: $($team.GroupId)"

                $channel = Get-TeamChannel -GroupId $team.GroupId `
                    -ErrorAction SilentlyContinue | Where-Object -FilterScript {
                        $_.DisplayName -eq $this.DisplayName
                    }

                # Current channel doesnt exist and trying to rename throw an error
                if (($null -eq $channel) -and $this.GetBoundParameters().ContainsKey('NewDisplayName'))
                {
                    Write-Verbose -Message "Cannot rename channel $($this.DisplayName), doesnt exist in current Team"
                    throw "Channel named $($this.DisplayName) doesn't exist in current Team"
                }

                if ($null -eq $channel)
                {
                    Write-Verbose -Message "Failed to get team channels with ID $($team.GroupId) and display name of $($this.DisplayName)"
                    return $this.AsResult($nullReturn)
                }
            }
            else
            {
                $channel = $this.ExportedInstance
                $team = $this.ResourceCache['currentTeam']
            }

            $results = @{
                DisplayName           = $channel.DisplayName
                TeamName              = $team.DisplayName
                GroupId               = $team.GroupId
                Description           = $channel.Description
                Ensure                = 'Present'
                ApplicationId         = $this.ApplicationId
                TenantId              = $this.TenantId
                CertificateThumbprint = $this.CertificateThumbprint
                Credential            = $this.Credential
                ManagedIdentity       = $this.ManagedIdentity
                AccessTokens          = $this.AccessTokens
            }

            if ($this.NewDisplayName)
            {
                $results.Add('NewDisplayName', $this.NewDisplayName)
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

        Write-Verbose -Message "Setting configuration of Teams channel $($this.DisplayName)"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $channel = $this.Get().ToHashtable()

        $CurrentParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()

        $team = Get-TeamByName ([System.Net.WebUtility]::UrlEncode($this.TeamName))

        if ($team.Length -gt 1)
        {
            throw "Multiple Teams with name {$($this.TeamName)} were found"
        }
        Write-Verbose -Message "Retrieve team GroupId: $($team.GroupId)"

        $CurrentParameters.Remove('TeamName') | Out-Null
        if ($CurrentParameters.ContainsKey('GroupId'))
        {
            $CurrentParameters.GroupId = $team.GroupId
        }
        else
        {
            $CurrentParameters.Add('GroupId', $team.GroupId)
        }

        if ($this.Ensure -eq 'Present')
        {
            # Remap attribute from DisplayName to current display name for Set-TeamChannel cmdlet
            if ($channel.Ensure -eq 'Present')
            {
                Write-Verbose -Message "Updating team channel $($this.DisplayName)"
                $CurrentParameters.Remove('DisplayName') | Out-Null
                Set-TeamChannel @CurrentParameters -CurrentDisplayName $this.DisplayName
            }
            else
            {
                if ($CurrentParameters.ContainsKey('NewDisplayName'))
                {
                    $CurrentParameters.Remove('NewDisplayName')
                }
                Write-Verbose -Message "Creating team channel $($this.DisplayName)"
                Write-Verbose -Message "Values: $(Convert-M365DscHashtableToString -Hashtable $CurrentParameters)"
                New-TeamChannel @CurrentParameters
            }
        }
        else
        {
            if ($channel.DisplayName)
            {
                # Teams never frees the name of a deleted channel
                # Rename first to keep the name reusable
                $deletedDisplayName = "Deleted-$([System.Guid]::NewGuid().ToString('N'))"
                Write-Verbose -Message "Renaming team channel $($this.DisplayName) to $deletedDisplayName before removal"
                Set-TeamChannel -GroupId $team.GroupId -CurrentDisplayName $this.DisplayName -NewDisplayName $deletedDisplayName
                Write-Verbose -Message "Removing team channel $deletedDisplayName"
                Remove-TeamChannel -GroupId $team.GroupId -DisplayName $deletedDisplayName
            }
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
            $teams = Get-Team -ErrorAction Stop | Sort-Object -Property GroupId
            $j = 1
            $dscContent = [System.Text.StringBuilder]::new()
            Write-M365DSCHost -Message "`r`n" -DeferWrite
            foreach ($team in $Teams)
            {
                if ($null -ne $team.GroupId)
                {
                    $channels = Get-TeamChannel -GroupId $team.GroupId
                    $i = 1
                    Write-M365DSCHost -Message "    |---[$j/$($Teams.Length)] Team {$($team.DisplayName)}"
                    foreach ($channel in $channels)
                    {
                        if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                        {
                            $Global:M365DSCExportResourceInstancesCount++
                        }

                        Write-M365DSCHost -Message "        |---[$i/$($channels.Length)] $($channel.DisplayName)" -DeferWrite
                        $params = @{
                            TeamName              = $team.DisplayName
                            GroupId               = $team.GroupId
                            DisplayName           = $channel.DisplayName
                            Credential            = $this.Credential
                            ApplicationId         = $this.ApplicationId
                            TenantId              = $this.TenantId
                            CertificateThumbprint = $this.CertificateThumbprint
                            CertificatePath       = $this.CertificatePath
                            CertificatePassword   = $this.CertificatePassword
                            ManagedIdentity       = $this.ManagedIdentity
                            AccessTokens          = $this.AccessTokens
                        }

                        $this.ExportedInstance = $channel
                        $this.ResourceCache['currentTeam'] = $team
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
                else
                {
                    Write-M365DSCHost -Message "    |---[$j/$($Teams.Length)] Team has no GroupId and will be skipped"
                }
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

    [System.Collections.Hashtable] GetCompareParameters()
    {
        return @{
            ExcludedProperties = @('GroupID', 'NewDisplayName')
        }
    }

    hidden [TeamsChannel] AsResult([System.Object] $Values)
    {
        if ($Values -is [TeamsChannel])
        {
            return $Values
        }

        $result = [TeamsChannel]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
