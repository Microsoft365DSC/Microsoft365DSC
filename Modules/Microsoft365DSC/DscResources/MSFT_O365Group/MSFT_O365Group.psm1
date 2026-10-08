using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class O365Group : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The display name for the group.')]
    [System.String] $DisplayName

    [DscProperty(Key)]
    [System.ComponentModel.Description('The group''s Internal Name.')]
    [System.String] $MailNickName

    [DscProperty()]
    [System.ComponentModel.Description('The group''s owner user principal.')]
    [System.String[]] $ManagedBy

    [DscProperty()]
    [System.ComponentModel.Description('The group''s description.')]
    [System.String] $Description

    [DscProperty()]
    [System.ComponentModel.Description('Members of the group.')]
    [System.String[]] $Members

    [DscProperty()]
    [System.ComponentModel.Description('Specifies a Microsoft 365 group''s color theme. Possible values are Teal, Purple, Green, Blue, Pink, Orange or Red. Returned by default.')]
    [ValidateSet('Teal', 'Purple', 'Green', 'Blue', 'Pink', 'Orange', 'Red')]
    [System.String] $Theme

    [DscProperty()]
    [System.ComponentModel.Description('Present ensures the group exists, absent ensures it is removed.')]
    [ValidateSet('Present', 'Absent')]
    [System.String] $Ensure

    [DscProperty()]
    [System.ComponentModel.Description('Credentials of the Global Admin')]
    [System.Management.Automation.PSCredential] $Credential

    [DscProperty()]
    [System.ComponentModel.Description('Id of the Azure Active Directory application to authenticate with.')]
    [System.String] $ApplicationId

    [DscProperty()]
    [System.ComponentModel.Description('Name of the Azure Active Directory tenant used for authentication. Format contoso.onmicrosoft.com')]
    [System.String] $TenantId

    [DscProperty()]
    [System.ComponentModel.Description('Secret of the Azure Active Directory application used for authentication.')]
    [System.Management.Automation.PSCredential] $ApplicationSecret

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
    [System.String] $Filter

    [O365Group] Get()
    {
        $nullReturn = $null
        $newMemberList = $null
        if ($this.RequiresPowerShellCore())
        {
            $remote = [O365Group]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of Office 365 Group $($this.DisplayName)"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.DisplayName -ne $this.DisplayName)
            {
                $null = $this.Connect('MicrosoftGraph')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullReturn = $this.GetBoundParameters()
                $nullReturn.Ensure = 'Absent'

                Write-Verbose -Message "Retrieving AzureADGroup by MailNickName {$($this.MailNickName)}"
                [array]$ADGroup = Get-MgGroup -All | Where-Object -FilterScript { $_.MailNickName -eq $this.MailNickName }
                if ($null -eq $ADGroup)
                {
                    Write-Verbose -Message "Retrieving AzureADGroup by DisplayName {$($this.DisplayName)}"
                    [array]$ADGroup = Get-MgGroup -All | Where-Object -FilterScript { $_.DisplayName -eq $this.DisplayName }
                    if ($null -eq $ADGroup)
                    {
                        Write-Verbose -Message "Office 365 Group {$($this.DisplayName)} was not found."
                        return $this.AsResult($nullReturn)
                    }
                }
                if ($ADGroup.Length -gt 1)
                {
                    $Message = "Multiple O365 groups were found with DisplayName {$($this.DisplayName)}. Please specify the MailNickName parameter to uniquely identify the group."
                    $this.LogError($_, $Message)
                }
                $ADGroup = $ADGroup[0]
            }
            else
            {
                $ADGroup = $this.ExportedInstance
            }
            Write-Verbose -Message "Found Existing Instance of Group {$($ADGroup.DisplayName)}"

            try
            {
                $membersList = Get-MgGroupMember -GroupId $ADGroup.Id
                Write-Verbose -Message "Found Members for Group {$($ADGroup.DisplayName)}"
                $owners = Get-MgGroupOwner -GroupId $ADGroup.Id
                Write-Verbose -Message "Found Owners for Group {$($ADGroup.DisplayName)}"
                $ownersUPN = @()
                if ($null -ne $owners)
                {
                    $ownersUPN = [System.String[]]$owners.userPrincipalName
                    $newMemberList = @()

                    foreach ($member in $membersList)
                    {
                        if ($null -ne $ownersUPN -and $ownersUPN.Length -ge 1 -and `
                                -not [System.String]::IsNullOrEmpty($member.userPrincipalName) -and `
                                -not $ownersUPN.Contains($member.userPrincipalName))
                        {
                            $newMemberList += $member.userPrincipalName
                        }
                    }
                }

                $currentDescription = ''
                if ($null -ne $ADGroup.Description)
                {
                    $currentDescription = $ADGroup.Description.ToString()
                }

                $returnValue = @{
                    DisplayName           = $ADGroup.DisplayName
                    MailNickName          = $ADGroup.MailNickName
                    Members               = $newMemberList
                    ManagedBy             = $ownersUPN
                    Description           = $currentDescription
                    Theme                 = $ADGroup.Theme
                    Credential            = $this.Credential
                    ApplicationId         = $this.ApplicationId
                    ApplicationSecret     = $this.ApplicationSecret
                    TenantId              = $this.TenantId
                    CertificateThumbprint = $this.CertificateThumbprint
                    ManagedIdentity       = $this.ManagedIdentity
                    Ensure                = 'Present'
                    AccessTokens          = $this.AccessTokens
                }
                return $this.AsResult($returnValue)
            }
            catch
            {
                $Message = "An error occured retrieving info for Group $($this.DisplayName)"
                $this.LogError($_, $Message)
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
        $ADGroup = $null
        $groupCreated = $false
        $newGroup = $null
        if ($this.RequiresPowerShellCore())
        {
            $null = $this.InvokeInPowerShellCore('Set')
            return
        }

        Write-Verbose -Message "Setting configuration of Office 365 Group $($this.DisplayName)"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $currentGroup = $this.Get().ToHashtable()

        if ($this.Ensure -eq 'Present')
        {
            $CurrentParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()

            if ($currentGroup.Ensure -eq 'Absent')
            {
                Write-Verbose -Message "Creating Office 365 Group {$($this.DisplayName)}"
                $groupParams = @{
                    DisplayName     = $this.DisplayName
                    Description     = $this.Description
                    MailEnabled     = $true
                    SecurityEnabled = $true
                }

                if ('' -ne $this.MailNickName)
                {
                    $groupParams.Add('mailNickName', $this.MailNickName)
                }
                if (-not [System.String]::IsNullOrEmpty($this.Theme))
                {
                    $groupParams.Add('theme', $this.Theme)
                }

                $directoryObjectsUrl = "$((Get-MSCloudLoginConnectionProfile -Workload MicrosoftGraph).ResourceUrl)v1.0/directoryObjects/"
                $ownerReferences = @()
                foreach ($owner in $this.ManagedBy)
                {
                    if (-not [System.String]::IsNullOrEmpty($owner))
                    {
                        $ownerReferences += $directoryObjectsUrl + (Get-MgUser -UserId $owner -ErrorAction Stop).Id
                    }
                }

                $memberReferences = @()
                foreach ($member in $this.Members)
                {
                    if (-not [System.String]::IsNullOrEmpty($member))
                    {
                        $memberReferences += $directoryObjectsUrl + (Get-MgUser -UserId $member -ErrorAction Stop).Id
                    }
                }

                $bindOnCreation = ($ownerReferences.Count + $memberReferences.Count) -le 20
                if ($bindOnCreation -and $ownerReferences.Count -gt 0)
                {
                    $groupParams.Add('owners@odata.bind', [System.String[]] $ownerReferences)
                }

                if ($bindOnCreation -and $memberReferences.Count -gt 0)
                {
                    $groupParams.Add('members@odata.bind', [System.String[]] $memberReferences)
                }

                Write-Verbose -Message 'Initiating Group Creation'
                Write-Verbose -Message "Creating New Group with values: $(Convert-M365DscHashtableToString -Hashtable $groupParams)"
                $groupParams.Add('GroupTypes', @('Unified'))
                $newGroup = New-MgGroup -BodyParameter $groupParams

                Write-Verbose -Message 'Group Created'
                if ($bindOnCreation)
                {
                    return
                }
                $groupCreated = $true
            }

            [array]$ADGroup = @()
            if ($groupCreated -and $null -ne $newGroup.Id)
            {
                $ADGroup = @($newGroup)
            }
            else
            {
                $ADGroup = $this.FindGroups()
            }

            if ($null -eq $ADGroup)
            {
                Write-Verbose -Message "Office 365 Group {$($this.DisplayName)} was not found."
                return
            }
            elseif ($ADGroup.Length -gt 1)
            {
                $Message = "Multiple O365 groups were found with DisplayName {$($this.DisplayName)}. Please specify the MailNickName parameter to uniquely identify the group."
                $this.LogError($_, $Message)
            }

            Write-Verbose -Message "Found Existing Instance of Group {$($ADGroup.DisplayName)}"

            $groupUpdate = @{}
            if ($currentGroup.Ensure -eq 'Present' -and $this.DisplayName -ne $ADGroup[0].DisplayName)
            {
                $groupUpdate.displayName = $this.DisplayName
            }
            if ($currentGroup.Ensure -eq 'Present' -and $null -ne $this.Description -and $this.Description -ne $ADGroup[0].Description)
            {
                $groupUpdate.description = $this.Description
            }
            if ($groupUpdate.Count -gt 0)
            {
                Write-Verbose -Message "Updating Group {$($ADGroup[0].DisplayName)} with $(Convert-M365DscHashtableToString -Hashtable $groupUpdate)"
                Invoke-M365DSCGraphRequest -Method PATCH -Uri "/v1.0/groups/$($ADGroup[0].Id)" -Body $groupUpdate | Out-Null
            }

            #region Theme
            if (-not [System.String]::IsNullOrEmpty($this.Theme) -and $this.Theme -ne $currentGroup.Theme)
            {
                Write-Verbose -Message "Updating the theme of Group {$($ADGroup.DisplayName)} to {$($this.Theme)}"
                $url = "/v1.0/groups/$($ADGroup[0].Id)"
                Invoke-M365DSCGraphRequest -Method PATCH -Uri $url -Body @{ theme = $this.Theme } | Out-Null
            }
            #endregion

            #region Members
            $membersList = $null
            for ($attempt = 1; $attempt -le 6; $attempt++)
            {
                try
                {
                    $membersList = Get-MgGroupMember -GroupId $ADGroup[0].Id -ErrorAction Stop
                    break
                }
                catch
                {
                    if (-not $groupCreated -or $attempt -ge 6 -or -not (Test-M365DSCNotFoundError -ErrorRecord $_))
                    {
                        throw
                    }
                    Start-Sleep -Seconds 5
                }
            }

            $curMembers = @()
            foreach ($member in $membersList)
            {
                $curMembers += $member.userPrincipalName
            }

            if ($null -ne $CurrentParameters.Members)
            {
                Write-Verbose -Message "Current Members: $($curMembers | Out-String)"
                Write-Verbose -Message "Desired Members: $($CurrentParameters.Members | Out-String)"
                $difference = Compare-Object -ReferenceObject $curMembers -DifferenceObject $CurrentParameters.Members

                if ($null -ne $difference.InputObject)
                {
                    Write-Verbose -Message 'Detected a difference in the current list of members and the desired one'
                    $membersToRemove = @()
                    $membersToAdd = @()
                    foreach ($diff in $difference)
                    {
                        if ($null -eq $this.ManagedBy -or -not $this.ManagedBy.Contains($diff.InputObject))
                        {
                            if ($diff.SideIndicator -eq '<=')
                            {
                                Write-Verbose "Will be removing Member: {$($diff.InputObject)}"
                                $membersToRemove += $diff.InputObject
                            }
                            elseif ($diff.SideIndicator -eq '=>')
                            {
                                Write-Verbose "Will be adding Member: {$($diff.InputObject)}"
                                $membersToAdd += $diff.InputObject
                            }
                        }
                    }

                    foreach ($member in $membersToAdd)
                    {
                        Write-Verbose "Adding members {$member}"
                        $userId = (Get-MgUser -UserId $member).Id
                        New-MgGroupMemberByRef -GroupId $ADGroup[0].Id -BodyParameter @{
                            '@odata.id' = (Get-MSCloudLoginConnectionProfile -Workload MicrosoftGraph).ResourceUrl + "v1.0/directoryObjects/$userId"
                        } | Out-Null
                    }

                    foreach ($member in $membersToRemove)
                    {
                        Write-Verbose "Removing members {$member}"
                        $userId = (Get-MgUser -UserId $member).Id

                        # There are no cmldet to remove members from group available at the time of writing this resource (March 8th 2022)
                        $url = "/v1.0/groups/$($ADGroup[0].Id)/members/$userId/`$ref"
                        Invoke-M365DSCGraphRequest -Method DELETE -Uri $url | Out-Null
                    }
                }
            }
            #endregion

            #region Owners
            $ownersList = Get-MgGroupOwner -GroupId $ADGroup[0].Id

            $curOwners = @()
            foreach ($owner in $ownersList)
            {
                $curOwners += $owner.userPrincipalName
            }

            if ($null -ne $CurrentParameters.ManagedBy)
            {
                Write-Verbose -Message "Current Owners: $($curOwners | Out-String)"
                Write-Verbose -Message "Desired Owners: $($CurrentParameters.ManagedBy | Out-String)"
                $difference = Compare-Object -ReferenceObject $curOwners -DifferenceObject $CurrentParameters.ManagedBy

                if ($null -ne $difference.InputObject)
                {
                    Write-Verbose -Message 'Detected a difference in the current list of members and the desired one'
                    $ownersToRemove = @()
                    $ownersToAdd = @()
                    foreach ($diff in $difference)
                    {
                        if ($diff.SideIndicator -eq '<=')
                        {
                            Write-Verbose "Will be removing Member: {$($diff.InputObject)}"
                            $ownersToRemove += $diff.InputObject
                        }
                        elseif ($diff.SideIndicator -eq '=>')
                        {
                            Write-Verbose "Will be adding Owner: {$($diff.InputObject)}"
                            $ownersToAdd += $diff.InputObject
                        }
                    }

                    foreach ($owner in $ownersToAdd)
                    {
                        Write-Verbose -Message "Adding Owner {$owner}"
                        $userId = (Get-MgUser -UserId $owner).Id
                        $newGroupOwner = @{
                            '@odata.id' = "$((Get-MSCloudLoginConnectionProfile -Workload MicrosoftGraph).ResourceUrl)v1.0/directoryObjects/$userId"
                        }

                        New-MgGroupOwnerByRef -GroupId $ADGroup[0].Id -BodyParameter $newGroupOwner
                    }

                    foreach ($owner in $ownersToRemove)
                    {
                        Write-Verbose "Removing owner {$owner}"
                        $userId = (Get-MgUser -UserId $owner).Id

                        # There are no cmldet to remove members from group available at the time of writing this resource (March 8th 2022)
                        $url = "/v1.0/groups/$($ADGroup[0].Id)/owners/$userId/`$ref"
                        Invoke-M365DSCGraphRequest -Method DELETE -Uri $url | Out-Null
                    }
                }
            }
            #endregion
        }
        elseif ($this.Ensure -eq 'Absent')
        {
            [array]$ADGroup = $this.FindGroups()
            if ($null -eq $ADGroup -or $ADGroup.Count -eq 0)
            {
                Write-Verbose -Message "Office 365 Group {$($this.DisplayName)} was not found."
            }
            elseif ($ADGroup.Count -eq 1)
            {
                Write-Verbose -Message "Removing O365Group $($ADGroup[0].DisplayName)"
                Remove-MgGroup -GroupId $ADGroup[0].Id | Out-Null
            }
            else
            {
                Write-Verbose -Message "There was more than one group identified with the name $($currentGroup.MailNickName)."
                Write-Verbose -Message 'No action taken. Please remove the group manually.'
            }
        }
    }

    hidden [System.Object[]] FindGroups()
    {
        [array]$groups = Get-MgGroup -All | Where-Object -Property MailNickName -EQ $this.MailNickName
        if ($null -eq $groups)
        {
            Write-Verbose -Message "Retrieving AzureADGroup by DisplayName {$($this.DisplayName)}"
            [array]$groups = Get-MgGroup -All | Where-Object -FilterScript { $_.DisplayName -eq $this.DisplayName }
        }
        return $groups
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
            $dscContent = [System.Text.StringBuilder]::new()
            $ExportParameters = @{
                Filter      = $this.Filter
                All         = [switch]$true
                ErrorAction = 'Stop'
            }
            if ( ($this.Filter -like '*endsWith*') -or ($this.Filter -like '*not*') )
            {
                $ExportParameters.Add('CountVariable', 'count')
                $ExportParameters.Add('ConsistencyLevel', 'eventual')
            }
            $groups = Get-MgGroup @ExportParameters | Where-Object -Property MailNickName -NE '00000000-0000-0000-0000-000000000000'

            $i = 1
            Write-M365DSCHost -Message "`r`n" -DeferWrite
            foreach ($group in $groups)
            {
                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }

                Write-M365DSCHost -Message "    |---[$i/$($groups.Length)] $($group.DisplayName)" -DeferWrite
                $Params = @{
                    DisplayName           = $group.DisplayName
                    ManagedBy             = 'DummyUser'
                    MailNickName          = $group.MailNickName
                    Credential            = $this.Credential
                    ApplicationId         = $this.ApplicationId
                    TenantId              = $this.TenantId
                    ApplicationSecret     = $this.ApplicationSecret
                    CertificateThumbprint = $this.CertificateThumbprint
                    CertificatePath       = $this.CertificatePath
                    CertificatePassword   = $this.CertificatePassword
                    ManagedIdentity       = $this.ManagedIdentity
                    AccessTokens          = $this.AccessTokens
                }
                $this.ExportedInstance = $group
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

    hidden [O365Group] AsResult([System.Object] $Values)
    {
        if ($Values -is [O365Group])
        {
            return $Values
        }

        $result = [O365Group]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
