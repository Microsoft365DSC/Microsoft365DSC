using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class SHSpaceGroup : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('Name of the associated Services Hub space.')]
    [System.String] $SpaceName

    [DscProperty(Key)]
    [System.ComponentModel.Description('Name of the group.')]
    [System.String] $GroupName

    [DscProperty()]
    [System.ComponentModel.Description('List of roles associated with the group. Accepted values are: CustomerActivityPagePermissionRole, HealthPermissionRole, InviteUsersPermissionRole, PlansPermissionRole, SharedFilesPermissionRole, SupportCasePermissionRole, TrainingManager, TrainingPermissionRole, WorkspaceAdministratorRole. Role Account manager,IncidentManagerUnified,CSMAdministrator, ContractSupportUser are read-only and inherited from the upstream system and cannot be modified.')]
    [System.String[]] $Roles

    [DscProperty()]
    [System.ComponentModel.Description('Present ensures the instance exists, absent ensures it is removed.')]
    [ValidateSet('Absent', 'Present')]
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
    [System.Management.Automation.PSCredential] $ApplicationSecret

    [SHSpaceGroup] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [SHSpaceGroup]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting SHSpaceGroup configuration for Space: $($this.SpaceName), Group: $($this.GroupName)"

        try
        {
            $null = $this.Connect('EngageHub')

            #Ensure the proper dependencies are installed in the current environment.
            Confirm-M365DSCDependencies

            #region Telemetry
            $this.AddTelemetry('Get')
            #endregion

            $nullResult = $this.GetBoundParameters()
            $nullResult.Ensure = 'Absent'

            Write-Verbose -Message "Retrieving space by name {$($this.SpaceName)}"
            $spacesUri = (Get-MSCloudLoginConnectionProfile -Workload EngageHub).APIUrl + '/spaces'
            $response = Invoke-M365DSCServicesHubWebRequest -Uri $spacesUri -Method GET
            $space = $response.value | Where-Object -FilterScript { $_.name -eq $this.SpaceName }

            if ($space.Length -gt 1)
            {
                throw "Multiple spaces with name {$($this.SpaceName)} were found"
            }
            elseif ($null -eq $space -or $space.Length -eq 0)
            {
                return $this.AsResult($nullResult)
            }

            $groupsUri = (Get-MSCloudLoginConnectionProfile -Workload EngageHub).APIUrl + '/spaces/' + $space.spaceId + '/groups'
            $response = Invoke-M365DSCServicesHubWebRequest -Uri $groupsUri -Method GET
            $instance = $response.value | Where-Object -FilterScript { $_.groupName -eq $this.GroupName }

            if ($instance.Length -gt 1)
            {
                throw "Multiple groups with name {$($this.GroupName)} were found."
            }
            elseif ($null -eq $instance)
            {
                return $this.AsResult($nullResult)
            }

            $results = @{
                SpaceName             = $this.SpaceName
                GroupName             = $this.GroupName
                Roles                 = $instance.roles
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
        $group = $null
        if ($this.RequiresPowerShellCore())
        {
            $null = $this.InvokeInPowerShellCore('Set')
            return
        }

        Write-Verbose -Message "Setting SHSpaceGroup configuration for Space: $($this.SpaceName), Group: $($this.GroupName)"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $currentInstance = $this.Get().ToHashtable()

        Write-Verbose -Message "Retrieving space by name {$($this.SpaceName)}"
        $spacesUri = (Get-MSCloudLoginConnectionProfile -Workload EngageHub).APIUrl + '/spaces'
        $response = Invoke-M365DSCServicesHubWebRequest -Uri $spacesUri -Method GET
        $space = $response.value | Where-Object -FilterScript { $_.name -eq $this.SpaceName }

        if ($currentInstance.Ensure -eq 'Present')
        {
            $groupsUri = (Get-MSCloudLoginConnectionProfile -Workload EngageHub).APIUrl + '/spaces/' + $space.spaceId + '/groups'
            $response = Invoke-M365DSCServicesHubWebRequest -Uri $groupsUri -Method GET
            $group = $response.value | Where-Object -FilterScript { $_.groupName -eq $this.GroupName }
        }

        # Retrieve Group ID from Microsoft Graph
        Write-Verbose -Message 'Authenticating to Microsoft Graph'
        $null = $this.Connect('MicrosoftGraph')

        Write-Verbose -Message "Retrieving group id for {$($this.GroupName)}"
        $groupInfo = Get-MgGroup -Filter "DisplayName eq '$($this.GroupName -replace "'", "''")'"
        Write-Verbose -Message "Found group info:`r`n$($groupInfo | Out-String)"
        $groupId = $null
        if ($null -ne $groupInfo)
        {
            $groupId = $groupInfo.Id
            Write-Verbose -Message "Retrieved GroupId {$groupId}"
        }
        else
        {
            throw "Could not retrieve group {$($this.GroupName)} from Entra Id."
        }

        # CREATE
        if ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Creating new group {$($this.GroupName)} with Roles {$($this.Roles -join ',')}"
            $body = @{
                DisplayName = $this.GroupName
                Roles       = $this.Roles
                GroupId     = $groupId
            }

            $uri = (Get-MSCloudLoginConnectionProfile -Workload EngageHub).APIUrl + '/spaces/' + $space.spaceId + '/groups'
            Write-Verbose -Message "POST request to {$uri}`r`n$(ConvertTo-Json $body -Depth 5)"
            Invoke-M365DSCServicesHubWebRequest -Uri $uri `
                -Method POST `
                -Body $body
        }
        # UPDATE
        elseif ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Updating group {$($this.GroupName)} with Roles {$($this.Roles -join ',')}"
            $body = @{
                roles = $this.Roles
            }

            $uri = (Get-MSCloudLoginConnectionProfile -Workload EngageHub).APIUrl + '/spaces/' + $space.spaceId + '/groups/' + $group.groupId
            Write-Verbose -Message "PATCH request to {$uri}`r`n$(ConvertTo-Json $body -Depth 5)"
            Invoke-M365DSCServicesHubWebRequest -Uri $uri `
                -Method PATCH `
                -Body $body
        }
        # REMOVE
        elseif ($this.Ensure -eq 'Absent' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Removing group {$($this.GroupName)}"
            $uri = (Get-MSCloudLoginConnectionProfile -Workload EngageHub).APIUrl + '/spaces/' + $space.spaceId + '/groups/' + $group.groupId
            Invoke-M365DSCServicesHubWebRequest -Uri $uri `
                -Method DELETE
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

        $ConnectionMode = $this.Connect('EngageHub')

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Export')

        try
        {
            $spacesUri = (Get-MSCloudLoginConnectionProfile -Workload EngageHub).APIUrl + '/spaces'
            $response = Invoke-M365DSCServicesHubWebRequest -Uri $spacesUri -Method GET
            $spaces = $response.value

            $dscContent = [System.Text.StringBuilder]::new()
            if ($spaces.Length -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }

            $j = 1
            foreach ($space in $spaces)
            {
                $displayedKey = $space.name
                Write-M365DSCHost -Message "    |---[$j/$($spaces.Count)] $displayedKey" -DeferWrite

                $groupsUri = (Get-MSCloudLoginConnectionProfile -Workload EngageHub).APIUrl + '/spaces/' + $space.spaceId + '/groups'
                $response = Invoke-M365DSCServicesHubWebRequest -Uri $groupsUri -Method GET
                $groups = $response.value

                if ($groups.Length -eq 0)
                {
                    Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
                }
                else
                {
                    Write-M365DSCHost -Message "`r`n" -DeferWrite
                }

                $i = 1
                foreach ($group in $groups)
                {
                    if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                    {
                        $Global:M365DSCExportResourceInstancesCount++
                    }

                    $displayedKey = $group.groupName
                    Write-M365DSCHost -Message "        |---[$i/$($groups.Count)] $displayedKey" -DeferWrite
                    $params = @{
                        SpaceName             = $space.name
                        GroupName             = $group.groupName
                        Credential            = $this.Credential
                        ApplicationId         = $this.ApplicationId
                        TenantId              = $this.TenantId
                        CertificateThumbprint = $this.CertificateThumbprint
                        ManagedIdentity       = $this.ManagedIdentity
                        AccessTokens          = $this.AccessTokens
                    }

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

    hidden [SHSpaceGroup] AsResult([System.Object] $Values)
    {
        if ($Values -is [SHSpaceGroup])
        {
            return $Values
        }

        $result = [SHSpaceGroup]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
