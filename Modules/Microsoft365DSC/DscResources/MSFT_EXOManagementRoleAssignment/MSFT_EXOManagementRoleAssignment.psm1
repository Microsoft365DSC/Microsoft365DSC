using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class EXOManagementRoleAssignment : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The Name parameter specifies a name for the new management role assignment. The maximum length of the name is 64 characters.')]
    [ValidateLength(1, 64)]
    [System.String] $Name

    [DscProperty(Key)]
    [System.ComponentModel.Description('The Role parameter specifies the existing role to assign. You can use any value that uniquely identifies the role.')]
    [System.String] $Role

    [DscProperty()]
    [System.ComponentModel.Description('The App parameter specifies the service principal to assign the management role to. Specifically, the ObjectId GUID value from the output of the Get-ServicePrincipal cmdlet (for example, 6233fba6-0198-4277-892f-9275bf728bcc).')]
    [System.String] $App

    [DscProperty()]
    [System.ComponentModel.Description('The Policy parameter specifies the name of the management role assignment policy to assign the management role to.')]
    [System.String] $Policy

    [DscProperty()]
    [System.ComponentModel.Description('The SecurityGroup parameter specifies the name of the management role group or mail-enabled universal security group to assign the management role to.')]
    [System.String] $SecurityGroup

    [DscProperty()]
    [System.ComponentModel.Description('The User parameter specifies the name or alias of the user to assign the management role to.')]
    [System.String] $User

    [DscProperty()]
    [System.ComponentModel.Description('The CustomRecipientWriteScope parameter specifies the existing recipient-based management scope to associate with this management role assignment.')]
    [System.String] $CustomRecipientWriteScope

    [DscProperty()]
    [System.ComponentModel.Description('The CustomResourceScope parameter specifies the custom management scope to associate with this management role assignment. You can use any value that uniquely identifies the management scope.')]
    [System.String] $CustomResourceScope

    [DscProperty()]
    [System.ComponentModel.Description('The ExclusiveRecipientWriteScope parameter specifies the exclusive recipient-based management scope to associate with the new role assignment. If you use the ExclusiveRecipientWriteScope parameter, you can''t use the CustomRecipientWriteScope or RecipientOrganizationalUnitScope parameters.')]
    [System.String] $ExclusiveRecipientWriteScope

    [DscProperty()]
    [System.ComponentModel.Description('The RecipientAdministrativeUnitScope parameter specifies the administrative unit to scope the new role assignment to.')]
    [System.String] $RecipientAdministrativeUnitScope

    [DscProperty()]
    [System.ComponentModel.Description('The RecipientOrganizationalUnitScope parameter specifies the OU to scope the new role assignment to. If you use the RecipientOrganizationalUnitScope parameter, you can''t use the CustomRecipientWriteScope or ExclusiveRecipientWriteScope parameters.')]
    [System.String] $RecipientOrganizationalUnitScope

    [DscProperty()]
    [System.ComponentModel.Description('The RecipientRelativeWriteScope parameter specifies the type of restriction to apply to a recipient scope. The available types are None, Organization, MyGAL, Self, and MyDistributionGroups. The RecipientRelativeWriteScope parameter is automatically set when the CustomRecipientWriteScope or RecipientOrganizationalUnitScope parameters are used.')]
    [System.String] $RecipientRelativeWriteScope

    [DscProperty()]
    [System.ComponentModel.Description('Specify if the Management Role Assignment should exist or not.')]
    [ValidateSet('Present', 'Absent')]
    [System.String] $Ensure

    [DscProperty()]
    [System.ComponentModel.Description('Credentials of the Exchange Global Admin')]
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

    [EXOManagementRoleAssignment] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [EXOManagementRoleAssignment]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting Management Role Assignment for $($this.Name)"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.Name -ne $this.Name)
            {
                $null = $this.Connect('ExchangeOnline')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullReturn = $this.GetBoundParameters()
                $nullReturn.Ensure = 'Absent'

                $roleAssignment = Get-ManagementRoleAssignment -Identity $this.Name -ErrorAction SilentlyContinue

                if ($null -eq $roleAssignment)
                {
                    Write-Verbose -Message "Management Role Assignment $($this.Name) does not exist."
                    return $this.AsResult($nullReturn)
                }
            }
            else
            {
                $roleAssignment = $this.ExportedInstance
            }

            $RecipientAdministrativeUnitScopeValue = $null
            if ($roleAssignment.RecipientWriteScope -eq 'AdministrativeUnit')
            {
                $adminUnit = Get-AdministrativeUnit -Identity $roleAssignment.CustomRecipientWriteScope

                if ($this.RecipientAdministrativeUnitScope -eq $adminUnit.Id)
                {
                    $RecipientAdministrativeUnitScopeValue = $this.RecipientAdministrativeUnitScope
                }
                else
                {
                    $RecipientAdministrativeUnitScopeValue = $adminUnit.DisplayName
                }
            }

            $RecipientRelativeWriteScopeValue = $null
            if ([System.String]$roleAssignment.RecipientWriteScope -in @('None', 'Organization', 'MyGAL', 'Self', 'MyDistributionGroups'))
            {
                $RecipientRelativeWriteScopeValue = [System.String]$roleAssignment.RecipientWriteScope
            }

            $CustomRecipientWriteScopeValue = $null
            $ExclusiveRecipientWriteScopeValue = $null
            $RecipientOrganizationalUnitScopeValue = $null
            switch ([System.String]$roleAssignment.RecipientWriteScope)
            {
                'CustomRecipientScope'
                {
                    $CustomRecipientWriteScopeValue = $roleAssignment.CustomRecipientWriteScope
                }
                'ExclusiveRecipientScope'
                {
                    $ExclusiveRecipientWriteScopeValue = $roleAssignment.CustomRecipientWriteScope
                    if (-not [System.String]::IsNullOrEmpty($this.ExclusiveRecipientWriteScope) -and `
                            $this.ExclusiveRecipientWriteScope -ne $ExclusiveRecipientWriteScopeValue)
                    {
                        $exclusiveScope = Get-ManagementScope -Identity $this.ExclusiveRecipientWriteScope -ErrorAction SilentlyContinue
                        if ($null -ne $exclusiveScope -and $exclusiveScope.Name -eq $ExclusiveRecipientWriteScopeValue)
                        {
                            $ExclusiveRecipientWriteScopeValue = $this.ExclusiveRecipientWriteScope
                        }
                    }
                }
                'OU'
                {
                    $RecipientOrganizationalUnitScopeValue = $roleAssignment.CustomRecipientWriteScope
                    if ([EXOManagementRoleAssignment]::GetOrganizationalUnitName($this.RecipientOrganizationalUnitScope) -eq $RecipientOrganizationalUnitScopeValue)
                    {
                        $RecipientOrganizationalUnitScopeValue = $this.RecipientOrganizationalUnitScope
                    }
                }
            }

            $result = @{
                Name                             = $roleAssignment.Name
                CustomRecipientWriteScope        = $CustomRecipientWriteScopeValue
                CustomResourceScope              = $roleAssignment.CustomResourceScope
                ExclusiveRecipientWriteScope     = $ExclusiveRecipientWriteScopeValue
                RecipientAdministrativeUnitScope = $RecipientAdministrativeUnitScopeValue
                RecipientOrganizationalUnitScope = $RecipientOrganizationalUnitScopeValue
                RecipientRelativeWriteScope      = $RecipientRelativeWriteScopeValue
                Role                             = $roleAssignment.Role
                Ensure                           = 'Present'
                Credential                       = $this.Credential
                ApplicationId                    = $this.ApplicationId
                CertificateThumbprint            = $this.CertificateThumbprint
                CertificatePath                  = $this.CertificatePath
                CertificatePassword              = $this.CertificatePassword
                ManagedIdentity                  = $this.ManagedIdentity
                TenantId                         = $this.TenantId
                AccessTokens                     = $this.AccessTokens
            }

            if ($roleAssignment.RoleAssigneeType -eq 'SecurityGroup' -or $roleAssignment.RoleAssigneeType -eq 'RoleGroup')
            {
                $result.Add('SecurityGroup', $roleAssignment.RoleAssignee)
            }
            elseif ($roleAssignment.RoleAssigneeType -eq 'RoleAssignmentPolicy')
            {
                $result.Add('Policy', $roleAssignment.RoleAssignee)
            }
            elseif ($roleAssignment.RoleAssigneeType -eq 'ServicePrincipal')
            {
                $result.Add('App', $roleAssignment.RoleAssignee)
            }
            elseif ($roleAssignment.RoleAssigneeType -eq 'User')
            {
                $null = $this.Connect('MicrosoftGraph')
                $userInfo = Get-MgUser -UserId ($roleAssignment.RoleAssignee)
                $result.Add('User', $userInfo.UserPrincipalName)
            }

            Write-Verbose -Message "Found Management Role Assignment $($this.Name)"
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

        Write-Verbose -Message "Setting Management Role Assignment for $($this.Name)"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $currentManagementRoleConfig = $this.Get().ToHashtable()

        $newManagementRoleParams = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()

        # If the RecipientAdministrativeUnitScope parameter is provided, then retrieve its ID by Name
        if (-not [System.String]::IsNullOrEmpty($this.RecipientAdministrativeUnitScope))
        {
            $newManagementRoleParams.Remove('CustomRecipientWriteScope') | Out-Null
            $null = $this.Connect('MicrosoftGraph')
            $adminUnit = Get-MgDirectoryAdministrativeUnit -AdministrativeUnitId $this.RecipientAdministrativeUnitScope -ErrorAction SilentlyContinue
            if ($null -eq $adminUnit)
            {
                $adminUnit = Get-MgDirectoryAdministrativeUnit -Filter "DisplayName eq '$($this.RecipientAdministrativeUnitScope -replace "'", "''")'"
            }
            $newManagementRoleParams.RecipientAdministrativeUnitScope = $adminUnit.Id
        }

        # CASE: Management Role doesn't exist but should;
        if ($this.Ensure -eq 'Present' -and $currentManagementRoleConfig.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Management Role Assignment'$($this.Name)' does not exist but it should. Create and configure it."
            # Create Management Role
            New-ManagementRoleAssignment @newManagementRoleParams | Out-Null
        }
        # CASE: Management Role exists but it shouldn't;
        elseif ($this.Ensure -eq 'Absent' -and $currentManagementRoleConfig.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Management Role Assignment'$($this.Name)' exists but it shouldn't. Remove it."
            Remove-ManagementRoleAssignment -Identity $this.Name -Confirm:$false -Force | Out-Null
        }
        # CASE: Management Role exists and it should, but has different values than the desired ones
        elseif ($this.Ensure -eq 'Present' -and $currentManagementRoleConfig.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Management Role Assignment'$($this.Name)' already exists, but needs updating. Deleting and recreating the instance."
            Remove-ManagementRoleAssignment -Identity $this.Name -Confirm:$false -Force | Out-Null
            New-ManagementRoleAssignment @newManagementRoleParams | Out-Null
        }

        # Wait for the permission to be applied
        $testResults = $false
        $retries = 12
        $count = 1
        do
        {
            Write-Verbose -Message 'Testing to ensure changes were applied.'
            $testResults = $this.Test()
            if (-not $testResults)
            {
                Write-Verbose -Message "Test method returned $false. Waiting for a total of $(($count * 10).ToString()) out of 120"
                Start-Sleep -Seconds 10
            }
            $retries--
            $count++
        } while (-not $testResults -and $retries -gt 0)

        # Need to force reconnect to Exchange for the new permissions to kick in.
        if ($null -ne (Get-MSCloudLoginConnectionProfile -Workload ExchangeOnline))
        {
            Write-Verbose -Message 'Waiting for 20 seconds for new permissions to be effective.'
            Start-Sleep 20
            Write-Verbose -Message 'Disconnecting from Exchange Online'
            Reset-MSCloudLoginConnectionProfileContext -Workload ExchangeOnline
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

        $ConnectionMode = $this.Connect('ExchangeOnline')

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Export')

        try
        {
            [array] $exportedInstances = Get-ManagementRoleAssignment | Where-Object -FilterScript { $_.RoleAssigneeType -eq 'ServicePrincipal' -or `
                    $_.RoleAssigneeType -eq 'User' -or $_.RoleAssigneeType -eq 'RoleAssignmentPolicy' -or $_.RoleAssigneeType -eq 'SecurityGroup' `
                    -or $_.RoleAssigneeType -eq 'RoleGroup' }

            $dscContent = [System.Text.StringBuilder]::new()

            if ($exportedInstances.Length -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }
            $i = 1
            foreach ($assignment in $exportedInstances)
            {
                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }

                Write-M365DSCHost -Message "    |---[$i/$($exportedInstances.Count)] $($assignment.Name)" -DeferWrite

                $Params = @{
                    Name                  = $assignment.Name
                    Role                  = $assignment.Role
                    Credential            = $this.Credential
                    ApplicationId         = $this.ApplicationId
                    TenantId              = $this.TenantId
                    CertificateThumbprint = $this.CertificateThumbprint
                    CertificatePassword   = $this.CertificatePassword
                    ManagedIdentity       = $this.ManagedIdentity
                    CertificatePath       = $this.CertificatePath
                    AccessTokens          = $this.AccessTokens
                }
                $this.ExportedInstance = $assignment
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

    hidden static [System.String] GetOrganizationalUnitName([System.String] $Value)
    {
        if ([System.String]::IsNullOrEmpty($Value))
        {
            return $null
        }

        if ($Value -match '^OU=([^,]+),')
        {
            return $Matches[1]
        }

        return ($Value.TrimEnd('/') -split '/')[-1]
    }

    hidden [EXOManagementRoleAssignment] AsResult([System.Object] $Values)
    {
        if ($Values -is [EXOManagementRoleAssignment])
        {
            return $Values
        }

        $result = [EXOManagementRoleAssignment]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
