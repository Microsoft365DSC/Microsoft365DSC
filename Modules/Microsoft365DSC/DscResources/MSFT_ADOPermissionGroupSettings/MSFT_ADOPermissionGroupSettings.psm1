using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class ADOPermissionGroupSettings : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('Name of the group.')]
    [System.String] $GroupName

    [DscProperty()]
    [System.ComponentModel.Description('Name of the DevOPS Organization.')]
    [System.String] $OrganizationName

    [DscProperty()]
    [System.ComponentModel.Description('Descriptor for the group.')]
    [System.String] $Descriptor

    [DscProperty()]
    [System.ComponentModel.Description('Allow permissions.')]
    [MSFT_ADOPermission[]] $AllowPermissions

    [DscProperty()]
    [System.ComponentModel.Description('Deny permissions')]
    [MSFT_ADOPermission[]] $DenyPermissions

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

    [ADOPermissionGroupSettings] Get()
    {
        $instance = $null
        if ($this.RequiresPowerShellCore())
        {
            $remote = [ADOPermissionGroupSettings]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration for ADO Permission Group Settings for Organization {$($this.OrganizationName)} and Group {$($this.GroupName)}"

        try
        {
            if ($null -eq $this.ResourceCache['exportedInstances'] -or -not $this.ResourceCache['ExportMode'])
            {
                $null = $this.Connect('AzureDevOPS')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullResult = $this.GetBoundParameters()
                if ($null -eq $this.ResourceCache['AllGroups'] -or $this.ResourceCache['CurrentOrganization'] -ne $this.OrganizationName)
                {
                    $uri = "https://vssps.dev.azure.com/$($this.OrganizationName)/_apis/graph/groups?api-version=7.1-preview.1"
                    $this.ResourceCache['AllGroups'] = (Invoke-M365DSCAzureDevOPSWebRequest -Uri $uri).value
                    $this.ResourceCache['CurrentOrganization'] = $this.OrganizationName
                }

                if (-not [System.String]::IsNullOrEmpty($this.Descriptor))
                {
                    $instance = $this.ResourceCache['AllGroups'] | Where-Object -FilterScript { $_.descriptor -eq $this.Descriptor }
                }
                if ($null -eq $instance)
                {
                    $instance = $this.ResourceCache['AllGroups'] | Where-Object -FilterScript { $_.principalName -eq $this.GroupName }
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
                    $instance = $this.ResourceCache['exportedInstances'] | Where-Object -FilterScript { $_.principalName -eq $this.GroupName }
                }

                $this.ResourceCache['AllGroups'] = $this.ResourceCache['exportedInstances']
                $this.ResourceCache['CurrentOrganization'] = $this.OrganizationName
            }

            $groupPermissions = $this.GetGroupPermission($instance.principalName, $this.OrganizationName, $this.ResourceCache)

            $results = @{
                OrganizationName      = $this.OrganizationName
                GroupName             = $instance.principalName
                Descriptor            = $instance.Descriptor
                AllowPermissions      = $groupPermissions.Allow
                DenyPermissions       = $groupPermissions.Deny
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

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $currentInstance = $this.Get().ToHashtable()

        $uri = "https://vssps.dev.azure.com/$($this.OrganizationName)/_apis/identities?subjectDescriptors=$($currentInstance.Descriptor)&api-version=7.2-preview.1"
        $info = Invoke-M365DSCAzureDevOPSWebRequest -Uri $uri
        $identityDescriptor = $info.value.descriptor

        # Get all Namespaces from the Allow and Deny
        $namespacesToUpdate = @()
        foreach ($namespace in $this.AllowPermissions)
        {
            if ($namespacesToUpdate.Length -eq 0 -or -not $namespacesToUpdate.NameSpaceId.Contains($namespace.namespaceId))
            {
                $namespacesToUpdate += $namespace
            }
        }
        foreach ($namespace in $this.DenyPermissions)
        {
            if ($namespacesToUpdate.Length -eq 0 -or -not $namespacesToUpdate.NameSpaceId.Contains($namespace.namespaceId))
            {
                $namespacesToUpdate += $namespace
            }
        }

        foreach ($namespace in $namespacesToUpdate)
        {
            $allowPermissionValue = 0
            $denyPermissionValue = 0
            $allowPermissionsEntries = $this.AllowPermissions | Where-Object -FilterScript { $_.NamespaceId -eq $namespace.namespaceId }
            foreach ($entry in $allowPermissionsEntries)
            {
                $allowPermissionValue += [Uint32]::Parse($entry.Bit)
            }

            $denyPermissionsEntries = $this.DenyPermissions | Where-Object -FilterScript { $_.NamespaceId -eq $namespace.namespaceId }
            foreach ($entry in $denyPermissionsEntries)
            {
                $denyPermissionValue += [Uint32]::Parse($entry.Bit)
            }

            $updateParams = @{
                merge                = $false
                token                = $namespace.token
                accessControlEntries = @(
                    @{
                        descriptor   = $identityDescriptor
                        allow        = $allowPermissionValue
                        deny         = $denyPermissionValue
                        extendedInfo = @{}
                    }
                )
            }
            $uri = "https://dev.azure.com/$($this.OrganizationName)/_apis/accesscontrolentries/$($namespace.namespaceId)?api-version=7.1"
            $body = ConvertTo-Json $updateParams -Depth 10 -Compress
            Write-Verbose -Message "Updating with payload:`r`n$body"
            Invoke-M365DSCAzureDevOPSWebRequest -Method POST `
                -Uri $uri `
                -Body $body `
                -ContentType 'application/json'
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
                        GroupName             = $config.principalName
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
                        if ($results.AllowPermissions.Length -gt 0)
                        {
                            $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                                -ComplexObject $Results.AllowPermissions `
                                -CIMInstanceName 'ADOPermission' `
                                -IsArray
                            if (-not [String]::IsNullOrEmpty($complexTypeStringResult))
                            {
                                $Results.AllowPermissions = $complexTypeStringResult
                            }
                            else
                            {
                                $Results.Remove('AllowPermissions') | Out-Null
                            }
                        }

                        if ($results.DenyPermissions.Length -gt 0)
                        {
                            $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                                -ComplexObject $Results.DenyPermissions `
                                -CIMInstanceName 'ADOPermission' `
                                -IsArray
                            if (-not [String]::IsNullOrEmpty($complexTypeStringResult))
                            {
                                $Results.DenyPermissions = $complexTypeStringResult
                            }
                            else
                            {
                                $Results.Remove('DenyPermissions') | Out-Null
                            }
                        }

                        $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                            -ConnectionMode $ConnectionMode `
                            -ModulePath $this.GetModulePath() `
                            -Results $Results `
                            -Credential $this.Credential `
                            -NoEscape @('AllowPermissions', 'DenyPermissions')

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

    hidden [System.Collections.Hashtable] GetGroupPermission([System.String] $GroupName, [System.String] $OrganizationName, [System.Collections.Hashtable] $Cache)
    {
        $results = @{
            Allow = @()
            Deny  = @()
        }

        try
        {
            $mygroup = $Cache['AllGroups'] | Where-Object -FilterScript { $_.principalName -eq $GroupName }

            $uri = "https://vssps.dev.azure.com/$($OrganizationName)/_apis/identities?subjectDescriptors=$($mygroup.descriptor)&api-version=7.2-preview.1"
            $info = Invoke-M365DSCAzureDevOPSWebRequest -Uri $uri
            $identityDescriptor = $info.value.descriptor

            if ($null -eq $Cache['AllSecurityNamespaces'] -or $Cache['CurrentOrganization'] -ne $OrganizationName)
            {
                $uri = "https://dev.azure.com/$($OrganizationName)/_apis/securitynamespaces?api-version=7.1-preview.1"
                $response = Invoke-M365DSCAzureDevOPSWebRequest -Uri $uri
                $Cache['AllSecurityNamespaces'] = $response.Value
                $Cache['CurrentOrganization'] = $OrganizationName
            }

            if ($null -eq $Cache['AllAccessControlLists'] -or $Cache['CurrentOrganization'] -ne $OrganizationName)
            {
                $Cache['AllAccessControlLists'] = [System.Collections.Generic.Dictionary[System.String, System.Object[]]]::new(100)
                foreach ($namespace in $Cache['AllSecurityNamespaces'])
                {
                    $uri = "https://dev.azure.com/$($OrganizationName)/_apis/accesscontrollists/$($namespace.namespaceId)?api-version=7.2-preview.1"
                    $response = Invoke-M365DSCAzureDevOPSWebRequest -Uri $uri
                    if ($response.value.Count -gt 0)
                    {
                        $Cache['AllAccessControlLists'].Add($namespace.namespaceId, @($response.value))
                    }
                }
            }

            foreach ($namespace in $Cache['AllSecurityNamespaces'])
            {
                foreach ($entry in $Cache['AllAccessControlLists'][$namespace.namespaceId])
                {
                    $token = $entry.token
                    foreach ($ace in $entry.acesDictionary)
                    {
                        if ($ace.$identityDescriptor)
                        {
                            $allow = $ace.$identityDescriptor.Allow
                            $allowBinary = [Convert]::ToString($allow, 2)

                            $deny = $ace.$identityDescriptor.Deny
                            $denyBinary = [Convert]::ToString($deny, 2)

                            # Breakdown the allow bits
                            $position = -1
                            $bitMaskPositionsFound = @()
                            do
                            {
                                $position = $allowBinary.IndexOf('1', $position + 1)
                                if ($position -ge 0)
                                {
                                    $zerosToAdd = $allowBinary.Length - $position - 1
                                    $value = '1'
                                    for ($i = 1; $i -le $zerosToAdd; $i++)
                                    {
                                        $value += '0'
                                    }

                                    $bitMaskPositionsFound += $value
                                }
                            } while ($position -ge 0 -and ($position + 1) -le $allowBinary.Length)

                            foreach ($bitmask in $bitMaskPositionsFound)
                            {
                                $associatedAction = $namespace.actions | Where-Object -FilterScript { [Convert]::ToString($_.bit, 2) -eq $bitmask }
                                if (-not [System.String]::IsNullOrEmpty($associatedAction.displayName))
                                {
                                    $entry = @{
                                        DisplayName = $associatedAction.displayName
                                        Bit         = $associatedAction.bit
                                        NamespaceId = $namespace.namespaceId
                                        Token       = $token
                                    }
                                    $results.Allow += $entry
                                }
                            }

                            # Breakdown the deny bits
                            $position = -1
                            $bitMaskPositionsFound = @()
                            do
                            {
                                $position = $denyBinary.IndexOf('1', $position + 1)
                                if ($position -ge 0)
                                {
                                    $zerosToAdd = $denyBinary.Length - $position - 1
                                    $value = '1'
                                    for ($i = 1; $i -le $zerosToAdd; $i++)
                                    {
                                        $value += '0'
                                    }

                                    $bitMaskPositionsFound += $value
                                }
                            } while ($position -ge 0 -and ($position + 1) -le $denyBinary.Length)

                            foreach ($bitmask in $bitMaskPositionsFound)
                            {
                                $associatedAction = $namespace.actions | Where-Object -FilterScript { [Convert]::ToString($_.bit, 2) -eq $bitmask }
                                if (-not [System.String]::IsNullOrEmpty($associatedAction.displayName))
                                {
                                    $entry = @{
                                        DisplayName = $associatedAction.displayName
                                        Bit         = $associatedAction.bit
                                        NamespaceId = $namespace.namespaceId
                                        Token       = $token
                                    }
                                    $results.Deny += $entry
                                }
                            }
                        }
                    }
                }
            }
        }
        catch
        {
            throw $_
        }
        return $results
    }

    hidden [ADOPermissionGroupSettings] AsResult([System.Object] $Values)
    {
        if ($Values -is [ADOPermissionGroupSettings])
        {
            return $Values
        }

        $result = [ADOPermissionGroupSettings]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}

class MSFT_ADOPermission
{
    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('Id of the associate security namespace.')]
    [System.String] $NamespaceId

    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('Display name of the permission scope.')]
    [System.String] $DisplayName

    [DscProperty()]
    [System.ComponentModel.Description('Bit mask for the permission')]
    [System.Nullable[System.UInt32]] $Bit

    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('Token value')]
    [System.String] $Token
}
