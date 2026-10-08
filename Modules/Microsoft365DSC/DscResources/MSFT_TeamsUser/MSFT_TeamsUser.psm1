using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class TeamsUser : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('Team NAme')]
    [System.String] $TeamName

    [DscProperty(Key)]
    [System.ComponentModel.Description('UPN of user to add to Team')]
    [System.String] $User

    [DscProperty()]
    [System.ComponentModel.Description('User role in Team')]
    [ValidateSet('Guest', 'Member', 'Owner')]
    [System.String] $Role

    [DscProperty()]
    [System.ComponentModel.Description('Present ensures the Team user exists, absent ensures it is removed')]
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

    [TeamsUser] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [TeamsUser]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of member $($this.User) to Team $($this.TeamName)"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.User -ne $this.User)
            {
                $null = $this.Connect('MicrosoftTeams')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullReturn = $this.GetBoundParameters()
                $nullReturn.Ensure = 'Absent'

                Write-Verbose -Message "Checking for existance of Team User $($this.User)"
                $team = Get-TeamByName ([System.Net.WebUtility]::UrlEncode($this.TeamName)) -ErrorAction SilentlyContinue
                if ($null -eq $team)
                {
                    return $this.AsResult($nullReturn)
                }

                Write-Verbose -Message "Retrieve team GroupId: $($team.GroupId)"

                try
                {
                    Write-Verbose 'Retrieving user without a specific Role specified'
                    $allMembers = Get-TeamUser -GroupId $team.GroupId -ErrorAction SilentlyContinue
                }
                catch
                {
                    Write-Warning "The current user doesn't have the rights to access the list of members for Team {$($this.TeamName)}."
                    Write-Verbose -Message $_
                    return $this.AsResult($nullReturn)
                }

                if ($null -eq $allMembers)
                {
                    Write-Verbose -Message "Failed to get Team's users for Team $($this.TeamName)"
                    return $this.AsResult($nullReturn)
                }

                $myUser = $allMembers | Where-Object -FilterScript { $_.User -eq $this.User }
                if ($null -eq $myUser)
                {
                    Write-Verbose -Message "User $($this.User) is not a member of Team $($this.TeamName)"
                    return $this.AsResult($nullReturn)
                }
            }
            else
            {
                $myUser = $this.ExportedInstance
            }

            Write-Verbose -Message "Found team user $($myUser.User) with role:$($myUser.Role)"
            return $this.AsResult(@{
                User                  = $myUser.User
                Role                  = $myUser.Role
                TeamName              = $this.TeamName
                Ensure                = 'Present'
                Credential            = $this.Credential
                ApplicationId         = $this.ApplicationId
                TenantId              = $this.TenantId
                CertificateThumbprint = $this.CertificateThumbprint
                CertificatePath       = $this.CertificatePath
                CertificatePassword   = $this.CertificatePassword
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

        Write-Verbose -Message "Setting configuration of member $($this.User) to Team $($this.TeamName)"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $null = $this.Connect('MicrosoftTeams')

        $team = Get-TeamByName ([System.Net.WebUtility]::UrlEncode($this.TeamName))

        Write-Verbose -Message "Retrieve team GroupId: $($team.GroupId)"

        $CurrentParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()
        $CurrentParameters.Remove('TeamName') | Out-Null
        $CurrentParameters.Add('GroupId', $team.GroupId)

        $currentInstance = $this.Get().ToHashtable()

        if ($this.Ensure -eq 'Present' -and $this.Role -eq 'Member' -and $currentInstance.Role -eq 'Owner')
        {
            Write-Verbose -Message "Removing owner role of team user $($this.User)"
            Remove-TeamUser -GroupId $team.GroupId -User $this.User -Role 'Owner'
        }
        elseif ($this.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Adding team user $($this.User) with role:$($this.Role)"
            Add-TeamUser @CurrentParameters
        }
        elseif ($this.Ensure -eq 'Absent' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Removing team user $($this.User)"
            Remove-TeamUser -GroupId $team.GroupId -User $this.User
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
            [array]$instances = Get-Team | Sort-Object -Property GroupId
            if ($instances.Length -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }
            $dscContent = [System.Text.StringBuilder]::new()
            $j = 1
            foreach ($item in $instances)
            {
                foreach ($team in $item)
                {
                    try
                    {
                        [Array]$users = Get-TeamUser -GroupId $team.GroupId
                        $k = 1
                        $totalCount = $instances.Length
                        if ($null -eq $totalCount)
                        {
                            $totalCount = 1
                        }
                        Write-M365DSCHost -Message "    > [$j/$totalCount] Team {$($team.DisplayName)}"
                        foreach ($user in $users)
                        {
                            if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                            {
                                $Global:M365DSCExportResourceInstancesCount++
                            }

                            Write-M365DSCHost -Message "        - [$k/$($users.Length)] $($user.User)" -DeferWrite

                            $getParams = @{
                                TeamName              = $team.DisplayName
                                User                  = $user.User
                                Credential            = $this.Credential
                                ApplicationId         = $this.ApplicationId
                                TenantId              = $this.TenantId
                                CertificateThumbprint = $this.CertificateThumbprint
                                CertificatePath       = $this.CertificatePath
                                CertificatePassword   = $this.CertificatePassword
                                ManagedIdentity       = $this.ManagedIdentity
                                AccessTokens          = $this.AccessTokens
                            }

                            $this.ExportedInstance = $user
                            $results = $this.GetForExport($getParams)
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
                            Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
                            $k++
                        }
                    }
                    catch
                    {
                        Write-Verbose -Message $_
                        Write-Verbose -Message "The current User doesn't have the required permissions to extract Users for Team {$($team.DisplayName)}."
                    }
                    $j++
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
            IncludedProperties = @('Role', 'User')
        }
    }

    hidden [TeamsUser] AsResult([System.Object] $Values)
    {
        if ($Values -is [TeamsUser])
        {
            return $Values
        }

        $result = [TeamsUser]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
