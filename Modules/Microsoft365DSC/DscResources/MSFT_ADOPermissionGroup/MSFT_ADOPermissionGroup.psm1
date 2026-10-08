using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class ADOPermissionGroup : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The name of the Azure DevOPS Organization.')]
    [System.String] $OrganizationName

    [DscProperty(Key)]
    [System.ComponentModel.Description('Principal name to identify the group.')]
    [System.String] $PrincipalName

    [DscProperty()]
    [System.ComponentModel.Description('Display name for the group.')]
    [System.String] $DisplayName

    [DscProperty()]
    [System.ComponentModel.Description('Description of the group.')]
    [System.String] $Description

    [DscProperty()]
    [System.ComponentModel.Description('List of principal names of the members of the group.')]
    [System.String[]] $Members

    [DscProperty()]
    [System.ComponentModel.Description('Unique identifier for the group.')]
    [System.String] $Id

    [DscProperty()]
    [System.ComponentModel.Description('Unique descriptor for the group.')]
    [System.String] $Descriptor

    [DscProperty()]
    [System.ComponentModel.Description('Determines at what level in the hierarchy the group exists. Valid values are Project or Organization.')]
    [ValidateSet('Organization', 'Project')]
    [System.String] $Level

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
    [System.Management.Automation.PSCredential] $ApplicationSecret

    [ADOPermissionGroup] Get()
    {
        $instance = $null
        if ($this.RequiresPowerShellCore())
        {
            $remote = [ADOPermissionGroup]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of ADO Permission Group for Organization {$($this.OrganizationName)} and Principal {$($this.PrincipalName)}"

        try
        {
            if ($null -eq $this.ResourceCache['exportedInstances'] -or -not $this.ResourceCache['ExportMode'])
            {
                $null = $this.Connect('AzureDevOPS')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullResult = $this.GetBoundParameters()
                $nullResult.Ensure = 'Absent'

                $uri = "https://vssps.dev.azure.com/$($this.OrganizationName)/_apis/graph/groups?api-version=7.1-preview.1"
                $allInstances = (Invoke-M365DSCAzureDevOPSWebRequest -Uri $uri).value
                if (-not [System.String]::IsNullOrEmpty($this.Descriptor))
                {
                    $instance = $allInstances | Where-Object -FilterScript { $_.descriptor -eq $this.Descriptor }
                }
                if ($null -eq $instance)
                {
                    $instance = $allInstances | Where-Object -FilterScript { $_.principalName -eq $this.PrincipalName }
                }

                if ($null -eq $instance)
                {
                    return $this.AsResult($nullResult)
                }
            }
            else
            {
                if (-not [System.String]::IsNullOrEmpty($this.Descriptor))
                {
                    $instance = $this.ResourceCache['exportedInstances'] | Where-Object -FilterScript { $_.descriptor -eq $this.Descriptor }
                }

                if ($null -eq $instance)
                {
                    $instance = $this.ResourceCache['exportedInstances'] | Where-Object -FilterScript { $_.principalName -eq $this.PrincipalName }
                }
            }

            # Level
            $LevelValue = 'Project'
            if ($instance.domain.StartsWith('vstfs:///Framework/IdentityDomain/'))
            {
                $LevelValue = 'Organization'
            }

            # Membership
            $MembersValue = @()
            $uri = "https://vsaex.dev.azure.com/$($this.OrganizationName)/_apis/GroupEntitlements/$($instance.originId)/members?api-version=7.1"
            $membership = (Invoke-M365DSCAzureDevOPSWebRequest -Uri $uri).members

            foreach ($member in $membership)
            {
                $MembersValue += $member.user.principalName
            }

            $results = @{
                OrganizationName      = $this.OrganizationName
                PrincipalName         = $instance.principalName
                Description           = $instance.description
                DisplayName           = $instance.displayName
                Descriptor            = $instance.descriptor
                Level                 = $LevelValue
                Id                    = $instance.originId
                Members               = $MembersValue
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
        ${$PrincipalName} = $null
        if ($this.RequiresPowerShellCore())
        {
            $null = $this.InvokeInPowerShellCore('Set')
            return
        }

        Write-Verbose -Message "Setting configuration of ADO Permission Group for Organization {$($this.OrganizationName)} and Principal {$($this.PrincipalName)}"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $currentInstance = $this.Get().ToHashtable()

        # CREATE
        if ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
        {
            $newGroup = $null
            if ($this.Level -eq 'Organization')
            {
                $uri = "https://vssps.dev.azure.com/$($this.OrganizationName)/_apis/graph/groups?api-version=7.1-preview.1"
                $body = '{"displayName": "' + $this.DisplayName + '","description": "' + $this.Description + '"}'
                $newGroup = Invoke-M365DSCAzureDevOPSWebRequest -Uri $uri -Method POST -Body $body -ContentType 'application/json'
            }
            elseif ($this.Level -eq 'Project')
            {
                $projectName = $this.PrincipalName.Split(']')[0]
                $projectName = $projectName.Substring(1, $projectName.Length - 1)
                $uri = "https://dev.azure.com/$($this.OrganizationName)/_apis/projects/$($ProjectName)?api-version=7.1"
                $response = Invoke-M365DSCAzureDevOPSWebRequest -Uri $uri
                $projectId = $response.id

                $uri = "https://vssps.dev.azure.com/$($this.OrganizationName)/_apis/graph/descriptors/$($projectId)?api-version=7.1-preview.1"
                $response = Invoke-M365DSCAzureDevOPSWebRequest -Uri $uri
                $scope = $response.value

                $uri = "https://vssps.dev.azure.com/$($this.OrganizationName)/_apis/graph/groups?scopeDescriptor=$($scope)&api-version=7.1-preview.1"
                $body = '{"displayName": "' + $this.DisplayName + '","description": "' + $this.Description + '"}'
                $newGroup = Invoke-M365DSCAzureDevOPSWebRequest -Uri $uri -Method POST -Body $body -ContentType 'application/json'
            }

            Write-M365DSCHost -Message "NEWGROUP::: $($newGroup | Format-List * | Out-String)"
            foreach ($member in $this.Members)
            {
                Write-Verbose -Message "Adding Member {$member} to group ${$PrincipalName}"
                $this.SetPermissionGroupMember($this.OrganizationName, $newGroup.originId, $member, 'Put')
            }
        }
        # UPDATE
        elseif ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Present')
        {
            if ($this.Description -ne $currentInstance.Description)
            {
                Write-Verbose -Message "Updating group {$($this.PrincipalName)} description to {$($this.Description)}"
                $uri = "https://vssps.dev.azure.com/$($this.OrganizationName)/_apis/graph/groups/$($currentInstance.Descriptor)?api-version=7.1-preview.1"
                $body = '[{"op": "replace", "path": "/description", "from": null, "value": "' + $this.Description + '"}]'
            }

            $membershipChanges = Compare-Object -ReferenceObject $currentInstance.Members -DifferenceObject $this.Members
            foreach ($diff in $membershipChanges)
            {
                if ($diff.SideIndicator -eq '=>')
                {
                    Write-Verbose -Message "Adding Member {$($diff.InputObject)} to group ${$PrincipalName}"
                    $this.SetPermissionGroupMember($this.OrganizationName, $currentInstance.Id, $diff.InputObject, 'PUT')
                }
                else
                {
                    Write-Verbose -Message "Removing Member {$($diff.InputObject)} to group ${$PrincipalName}"
                    $this.SetPermissionGroupMember($this.OrganizationName, $currentInstance.Id, $diff.InputObject, 'DELETE')
                }
            }
        }
        # REMOVE
        elseif ($this.Ensure -eq 'Absent' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Removing group {$($this.principalName)} with Descriptor {$($currentInstance.Descriptor)}"
            $uri = "https://vssps.dev.azure.com/$($this.OrganizationName)/_apis/graph/groups/$($currentInstance.Descriptor)?api-version=7.1-preview.1"
            Invoke-M365DSCAzureDevOPSWebRequest -Uri $uri -Method 'DELETE' -ContentType 'application/json' | Out-Null
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

        $ConnectionMode = $this.Connect('AzureDevOPS')

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Export')

        try
        {
            $this.ResourceCache['ExportMode'] = $true

            $profileValue = Invoke-M365DSCAzureDevOPSWebRequest -Uri 'https://app.vssps.visualstudio.com/_apis/profile/profiles/me?api-version=5.1'
            $accounts = Invoke-M365DSCAzureDevOPSWebRequest -Uri "https://app.vssps.visualstudio.com/_apis/accounts?api-version=7.1-preview.1&memberId=$($profileValue.id)"

            $i = 1
            $dscContent = [System.Text.StringBuilder]::new()
            if ($accounts.Count -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
                return ''
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }
            foreach ($account in $accounts)
            {
                $organization = $account.Value.accountName
                $uri = "https://vssps.dev.azure.com/$organization/_apis/graph/groups?api-version=7.1-preview.1"

                [array] $this.ResourceCache['exportedInstances'] = (Invoke-M365DSCAzureDevOPSWebRequest -Uri $uri).Value

                $i = 1
                $dscContent = [System.Text.StringBuilder]::new()
                foreach ($config in $this.ResourceCache['exportedInstances'])
                {
                    $displayedKey = $config.principalName
                    if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                    {
                        $Global:M365DSCExportResourceInstancesCount++
                    }
                    Write-M365DSCHost -Message "    |---[$i/$($this.ResourceCache['exportedInstances'].Count)] $displayedKey" -DeferWrite
                    $params = @{
                        OrganizationName      = $Organization
                        PrincipalName         = $config.principalName
                        Descriptor            = $config.descriptor
                        Credential            = $this.Credential
                        ApplicationId         = $this.ApplicationId
                        TenantId              = $this.TenantId
                        CertificateThumbprint = $this.CertificateThumbprint
                        ManagedIdentity       = $this.ManagedIdentity
                        AccessTokens          = $this.AccessTokens
                    }

                    if (-not $config.principalName.StartsWith('[TEAM FOUNDATION]'))
                    {
                        $Results = $this.GetForExport($Params)

                        $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                            -ConnectionMode $ConnectionMode `
                            -ModulePath $this.GetModulePath() `
                            -Results $Results `
                            -Credential $this.Credential
                        [void]$dscContent.Append($currentDSCBlock)
                        Save-M365DSCPartialExport -Content $currentDSCBlock `
                            -FileName $Global:PartialExportFileName
                    }
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

    hidden [void] SetPermissionGroupMember([System.String] $OrganizationName, [System.String] $GroupId, [System.String] $PrincipalName, [System.String] $Method)
    {
        if ($null -eq $this.ResourceCache['allUsers'])
        {
            $uri = "https://vsaex.dev.azure.com/$($OrganizationName)/_apis/userentitlements?api-version=7.2-preview.4"
            $this.ResourceCache['allUsers'] = Invoke-M365DSCAzureDevOPSWebRequest -Uri $uri
        }
        $user = $this.ResourceCache['allUsers'].items | Where-Object -FilterScript { $_.user.principalName -eq $PrincipalName }
        $UserId = $user.id
        $uri = "https://vsaex.dev.azure.com/$($OrganizationName)/_apis/GroupEntitlements/$($GroupId)/members/$($UserId)?api-version=5.0-preview.1"
        Invoke-M365DSCAzureDevOPSWebRequest -Uri $uri -Method $Method | Out-Null
    }

    hidden [ADOPermissionGroup] AsResult([System.Object] $Values)
    {
        if ($Values -is [ADOPermissionGroup])
        {
            return $Values
        }

        $result = [ADOPermissionGroup]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
