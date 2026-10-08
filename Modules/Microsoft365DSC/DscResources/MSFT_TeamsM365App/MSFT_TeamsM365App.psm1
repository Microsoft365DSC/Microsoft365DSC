using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class TeamsM365App : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('Application ID of Microsoft Teams app.')]
    [System.String] $Id

    [DscProperty()]
    [System.ComponentModel.Description('The state of the app in the tenant.')]
    [System.Nullable[System.Boolean]] $IsBlocked

    [DscProperty()]
    [System.ComponentModel.Description('App availability type.')]
    [ValidateSet('Everyone', 'UsersAndGroups', 'NoOne')]
    [System.String] $AssignmentType

    [DscProperty()]
    [System.ComponentModel.Description('List of all the users for whom the app is enabled or disabled.')]
    [System.String[]] $Users

    [DscProperty()]
    [System.ComponentModel.Description('List of all the groups for whom the app is enabled or disabled.')]
    [System.String[]] $Groups

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

    [TeamsM365App] Get()
    {
        $nullResult = $null
        if ($this.RequiresPowerShellCore())
        {
            $remote = [TeamsM365App]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration for Teams M365App $($this.Id)"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.Id -ne $this.Id)
            {
                $null = $this.Connect('MicrosoftTeams')

                $null = $this.Connect('MicrosoftGraph')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullResult = $this.GetBoundParameters()
                $instance = Get-M365TeamsApp -Id $this.Id -ErrorAction SilentlyContinue
            }
            else
            {
                $instance = $this.ExportedInstance
            }

            if ($null -eq $instance)
            {
                return $this.AsResult($nullResult)
            }

            $usersValue = @()
            if ($null -ne $instance.AvailableTo.Users)
            {
                foreach ($userEntry in $instance.AvailableTo.Users)
                {
                    $userInfo = Get-MgUser -UserId $userEntry.Id
                    $usersValue += $userInfo.UserPrincipalName
                }
            }

            $groupsValue = @()
            if ($null -ne $instance.AvailableTo.Groups)
            {
                foreach ($groupEntry in $instance.AvailableTo.Groups)
                {
                    $groupInfo = Get-MgGroup -GroupId $groupEntry.Id
                    $groupsValue += $groupInfo.DisplayName
                }
            }

            Write-Verbose -Message "Found an instance with Id {$($this.Id)}"
            $results = @{
                Id                    = $instance.Id
                IsBlocked             = [Boolean]$instance.IsBlocked
                AssignmentType        = $instance.AvailableTo.AssignmentType
                Users                 = $usersValue
                Groups                = $groupsValue
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

        Write-Verbose -Message "Setting configuration for Teams M365App $($this.Id)"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $currentInstance = $this.Get().ToHashtable()

        Write-Verbose -Message "Updating {$($this.Id)}"

        if ($this.AssignmentType -eq 'UsersAndGroups')
        {
            #region Users
            $usersDelta = Compare-Object -ReferenceObject $currentInstance.Users -DifferenceObject $this.Users
            $usersToAdd = @()
            $usersToRemove = @()
            foreach ($delta in $usersDelta)
            {
                if ($delta.SideIndicator -eq '<=')
                {
                    $userInfo = Get-MgUser -UserId $delta.InputObject -ErrorAction Stop
                    $usersToRemove += $userInfo.Id
                }
                elseif ($delta.SideIndicator -eq '=>')
                {
                    $userInfo = Get-MgUser -UserId $delta.InputObject -ErrorAction Stop
                    $usersToAdd += $userInfo.Id
                }
            }

            if ($usersToRemove.Length -gt 0)
            {
                Write-Verbose -Message "Removing Users Assignments for {$($usersToAdd)}"
                Update-M365TeamsApp -Id $this.Id `
                    -IsBlocked $this.IsBlocked `
                    -AppAssignmentType $this.AssignmentType `
                    -OperationType 'Remove' `
                    -Users $usersToRemove
            }

            if ($usersToAdd.Length -gt 0)
            {
                Write-Verbose -Message "Removing Users Assignments for {$($usersToAdd)}"
                Update-M365TeamsApp -Id $this.Id `
                    -IsBlocked $this.IsBlocked `
                    -AppAssignmentType $this.AssignmentType `
                    -OperationType 'Add' `
                    -Users $usersToAdd
            }
            #endregion

            #region Groups
            $groupsDelta = Compare-Object -ReferenceObject $currentInstance.Groups -DifferenceObject $this.Groups
            $groupsToAdd = @()
            $groupsToRemove = @()
            foreach ($delta in $groupsDelta)
            {
                if ($delta.SideIndicator -eq '<=')
                {
                    $groupInfo = Get-MgGroup -Filter "DisplayName eq '$($delta.InputObject -replace "'", "''")'" -ErrorAction Stop
                    $groupsToRemove += $groupInfo.Id
                }
                elseif ($delta.SideIndicator -eq '=>')
                {
                    $groupInfo = Get-MgGroup -Filter "DisplayName eq '$($delta.InputObject -replace "'", "''")'" -ErrorAction Stop
                    $groupsToAdd += $groupInfo.Id
                }
            }

            if ($groupsToRemove.Length -gt 0)
            {
                Write-Verbose -Message "Removing Group Assignments for {$($groupsToRemove)}"
                Update-M365TeamsApp -Id $this.Id `
                    -IsBlocked $this.IsBlocked `
                    -AppAssignmentType $this.AssignmentType `
                    -OperationType 'Remove' `
                    -Groups $groupsToRemove
            }

            if ($groupsToAdd.Length -gt 0)
            {
                Write-Verbose -Message "Adding Group Assignments for {$($groupsToAdd)}"
                Update-M365TeamsApp -Id $this.Id `
                    -IsBlocked $this.IsBlocked `
                    -AppAssignmentType $this.AssignmentType `
                    -OperationType 'Add' `
                    -Groups $groupsToAdd
            }
            #endregion
        }
        else
        {
            Write-Verbose -Message "Updating core settings for app {$($this.Id)}"
            Update-M365TeamsApp -Id $this.Id `
                -IsBlocked $this.IsBlocked `
                -AppAssignmentType $this.AssignmentType
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
            [array] $exportedInstances = @()
            try
            {
                [array] $exportedInstances = Get-AllM365TeamsApps -ErrorAction Stop
            }
            catch
            {
                Write-Verbose $_
            }

            $i = 1
            $dscContent = [System.Text.StringBuilder]::new()
            if ($exportedInstances.Length -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }
            foreach ($config in $exportedInstances)
            {
                $displayedKey = $config.Id
                Write-M365DSCHost -Message "    |---[$i/$($exportedInstances.Count)] $displayedKey" -DeferWrite
                $params = @{
                    Id                    = $config.Id
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
            return $dscContent.ToString()
        }
        catch
        {
            $this.LogError($_, 'Error during Export:')

            throw
        }
    }

    hidden [TeamsM365App] AsResult([System.Object] $Values)
    {
        if ($Values -is [TeamsM365App])
        {
            return $Values
        }

        $result = [TeamsM365App]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
