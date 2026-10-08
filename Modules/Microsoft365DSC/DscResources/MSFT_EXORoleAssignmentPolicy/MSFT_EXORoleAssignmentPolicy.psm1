using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class EXORoleAssignmentPolicy : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The Name parameter specifies the new name of the assignment policy. The maximum length is 64 characters.')]
    [ValidateLength(1, 64)]
    [System.String] $Name

    [DscProperty()]
    [System.ComponentModel.Description('The Description parameter specifies the description that''s displayed when the role assignment policy is viewed using the Get-RoleAssignmentPolicy cmdlet.')]
    [System.String] $Description

    [DscProperty()]
    [System.ComponentModel.Description('The IsDefault switch makes the assignment policy the default assignment policy.')]
    [System.Nullable[System.Boolean]] $IsDefault

    [DscProperty()]
    [System.ComponentModel.Description('The Roles parameter specifies the management roles to assign to the role assignment policy when it''s created.')]
    [System.String[]] $Roles

    [DscProperty()]
    [System.ComponentModel.Description('Specify if the Role Assignment Policy should exist or not.')]
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

    [EXORoleAssignmentPolicy] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [EXORoleAssignmentPolicy]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting Role Assignment Policy configuration for $($this.Name)"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.Name -ne $this.Name)
            {
                $null = $this.Connect('ExchangeOnline')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullReturn = $this.GetBoundParameters()
                $nullReturn.Ensure = 'Absent'

                $RoleAssignmentPolicy = Get-RoleAssignmentPolicy -Identity $this.Name -ErrorAction SilentlyContinue
                if ($null -eq $RoleAssignmentPolicy)
                {
                    Write-Verbose -Message "Role Assignment Policy $($this.Name) does not exist."
                    return $this.AsResult($nullReturn)
                }
            }
            else
            {
                $RoleAssignmentPolicy = $this.ExportedInstance
            }

            $result = @{
                Name                  = $RoleAssignmentPolicy.Name
                Description           = $RoleAssignmentPolicy.Description
                IsDefault             = $RoleAssignmentPolicy.IsDefault
                Roles                 = $RoleAssignmentPolicy.AssignedRoles
                Ensure                = 'Present'
                Credential            = $this.Credential
                ApplicationId         = $this.ApplicationId
                CertificateThumbprint = $this.CertificateThumbprint
                CertificatePath       = $this.CertificatePath
                CertificatePassword   = $this.CertificatePassword
                ManagedIdentity       = $this.ManagedIdentity
                TenantId              = $this.TenantId
                AccessTokens          = $this.AccessTokens
            }

            Write-Verbose -Message "Found Role Assignment Policy $($this.Name)"
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

        Write-Verbose -Message "Setting Role Assignment Policy configuration for $($this.Name)"

        $currentRoleAssignmentPolicyConfig = $this.Get().ToHashtable()

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $NewRoleAssignmentPolicyParams = @{
            Name        = $this.Name
            Description = $this.Description
            IsDefault   = $this.IsDefault
            Roles       = $this.Roles
            Confirm     = $false
        }

        $SetRoleAssignmentPolicyParams = @{
            Identity    = $this.Name
            Name        = $this.Name
            Description = $this.Description
            IsDefault   = $this.IsDefault
            Roles       = $this.Roles
            Confirm     = $false
        }

        # CASE: Role Assignment Policy doesn't exist but should;
        if ($this.Ensure -eq 'Present' -and $currentRoleAssignmentPolicyConfig.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Role Assignment Policy '$($this.Name)' does not exist but it should. Create and configure it."
            # Create Role Assignment Policy
            New-RoleAssignmentPolicy @NewRoleAssignmentPolicyParams
        }
        # CASE: Role Assignment Policy exists but it shouldn't;
        elseif ($this.Ensure -eq 'Absent' -and $currentRoleAssignmentPolicyConfig.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Role Assignment Policy '$($this.Name)' exists but it shouldn't. Remove it."
            foreach ($roleAssignment in @(Get-ManagementRoleAssignment -RoleAssignee $this.Name -ErrorAction SilentlyContinue))
            {
                Write-Verbose -Message "Removing Management Role Assignment {$($roleAssignment.Name)} from Role Assignment Policy {$($this.Name)}"
                Remove-ManagementRoleAssignment -Identity $roleAssignment.Name -Confirm:$false
            }
            Remove-RoleAssignmentPolicy -Identity $this.Name -Confirm:$false
        }
        # CASE: Role Assignment Policy exists and it should, but has different values than the desired ones
        elseif ($this.Ensure -eq 'Present' -and $currentRoleAssignmentPolicyConfig.Ensure -eq 'Present' -and $null -eq (Compare-Object -ReferenceObject $($currentRoleAssignmentPolicyConfig.Roles) -DifferenceObject $this.Roles))
        {
            Write-Verbose -Message "Role Assignment Policy '$($this.Name)' already exists, but needs updating."
            Write-Verbose -Message "Setting Role Assignment Policy $($this.Name) with values: $(Convert-M365DscHashtableToString -Hashtable $SetRoleAssignmentPolicyParams)"
            $SetRoleAssignmentPolicyParams.Remove('Roles') | Out-Null
            Set-RoleAssignmentPolicy @SetRoleAssignmentPolicyParams
        }
        # CASE: Role Assignment Policy exists and it should, but Roles attribute has different values than the desired ones
        # Set-RoleAssignmentPolicy cannot change Roles attribute. Therefore we have to remove and recreate the policy if Roles attribute should be changed.
        elseif ($this.Ensure -eq 'Present' -and $currentRoleAssignmentPolicyConfig.Ensure -eq 'Present' -and $null -ne (Compare-Object -ReferenceObject $($currentRoleAssignmentPolicyConfig.Roles) -DifferenceObject $this.Roles))
        {
            Write-Verbose -Message "Role Assignment Policy '$($this.Name)' already exists, but roles attribute needs updating."
            $differences = Compare-Object -ReferenceObject $($currentRoleAssignmentPolicyConfig.Roles) -DifferenceObject $this.Roles
            foreach ($difference in $differences)
            {
                if ($difference.SideIndicator -eq '=>')
                {
                    Write-Verbose -Message "Adding Role {$($difference.InputObject)} to Role Assignment Policy {$($this.Name)}"
                    New-ManagementRoleAssignment -Role $($difference.InputObject) -Policy $this.Name -Confirm:$false
                }
                elseif ($difference.SideIndicator -eq '<=')
                {
                    Write-Verbose -Message "Removing Role {$($difference.InputObject)} from Role Assignment Policy {$($this.Name)}"
                    Remove-ManagementRoleAssignment -Identity "$($difference.InputObject)-$($this.Name)" -Confirm:$false
                }
            }
            # Update other attributes of role assignment policy
            Set-RoleAssignmentPolicy -Identity $this.Name -Name $this.Name -Description $this.Description -IsDefault:$this.IsDefault -Confirm:$false
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
            [array]$AllRoleAssignmentPolicies = Get-RoleAssignmentPolicy -ErrorAction Stop

            $dscContent = [System.Text.StringBuilder]::new()

            if ($AllRoleAssignmentPolicies.Length -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }
            $i = 1
            foreach ($RoleAssignmentPolicy in $AllRoleAssignmentPolicies)
            {
                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }

                Write-M365DSCHost -Message "    |---[$i/$($AllRoleAssignmentPolicies.Length)] $($RoleAssignmentPolicy.Name)" -DeferWrite

                $Params = @{
                    Name                  = $RoleAssignmentPolicy.Name
                    Credential            = $this.Credential
                    ApplicationId         = $this.ApplicationId
                    TenantId              = $this.TenantId
                    CertificateThumbprint = $this.CertificateThumbprint
                    CertificatePassword   = $this.CertificatePassword
                    ManagedIdentity       = $this.ManagedIdentity
                    CertificatePath       = $this.CertificatePath
                    AccessTokens          = $this.AccessTokens
                }
                $this.ExportedInstance = $RoleAssignmentPolicy
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

    hidden [EXORoleAssignmentPolicy] AsResult([System.Object] $Values)
    {
        if ($Values -is [EXORoleAssignmentPolicy])
        {
            return $Values
        }

        $result = [EXORoleAssignmentPolicy]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
