using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class SCRoleGroup : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The Name parameter specifies the name of the role. The maximum length of the name is 64 characters.')]
    [ValidateLength(1, 64)]
    [System.String] $Name

    [DscProperty()]
    [System.ComponentModel.Description('The DisplayName parameter specifies the friendly name of the role group. If the name contains spaces, enclose the name in quotation marks. This parameter has a maximum length of 256 characters.')]
    [ValidateLength(1, 256)]
    [System.String] $DisplayName

    [DscProperty()]
    [System.ComponentModel.Description('The Description parameter specifies the description that''s displayed when the role group is viewed using the Get-RoleGroup cmdlet. Enclose the description in quotation marks')]
    [System.String] $Description

    [DscProperty()]
    [System.ComponentModel.Description('The Roles parameter specifies the management roles to assign to the role group when it''s created. If a role name contains spaces, enclose the name in quotation marks. If you want to assign more that one role, separate the role names with commas.')]
    [System.String[]] $Roles

    [DscProperty()]
    [System.ComponentModel.Description('Specify if the Role Group should exist or not.')]
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

    [SCRoleGroup] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [SCRoleGroup]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting Role Group configuration for $($this.Name)"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.Name -ne $this.Name)
            {
                $null = $this.Connect('SecurityComplianceCenter')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullReturn = $this.GetBoundParameters()
                $nullReturn.Ensure = 'Absent'

                $AllRoleGroups = Get-RoleGroup -ErrorAction Stop
                $RoleGroup = $AllRoleGroups | Where-Object -FilterScript { $_.Name -eq $this.Name }

                if ($null -eq $RoleGroup)
                {
                    Write-Verbose -Message "Role Group $($this.Name) does not exist."
                    return $this.AsResult($nullReturn)
                }
            }
            else
            {
                $RoleGroup = $this.ExportedInstance
            }

            $result = @{
                Name                  = $RoleGroup.Name
                DisplayName           = $RoleGroup.DisplayName
                Description           = $RoleGroup.Description
                Roles                 = $RoleGroup.Roles -replace '^.*\/(?=[^\/]*$)'
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

            Write-Verbose -Message "Found Role Group $($this.Name)"
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
        $Members = $null
        if ($this.RequiresPowerShellCore())
        {
            $null = $this.InvokeInPowerShellCore('Set')
            return
        }

        Write-Verbose -Message "Setting Role Group configuration for $($this.Name)"

        $currentRoleGroupConfig = $this.Get().ToHashtable()

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $null = $this.Connect('SecurityComplianceCenter')

        $NewRoleGroupParams = @{
            Name        = $this.Name
            Description = $this.Description
            Roles       = $this.Roles
            Confirm     = $false
        }
        # Add DisplayName Parameter equals Name if null or Empty as creation with no value will lead to a corrupted state of the created RoleGroup
        if ([System.String]::IsNullOrEmpty($this.DisplayName))
        {
            $NewRoleGroupParams.Add('DisplayName', $this.Name)
        }
        else
        {
            $NewRoleGroupParams.Add('DisplayName', $this.DisplayName)
        }
        # Remove Description Parameter if null or Empty as the creation fails with $null parameter
        if ([System.String]::IsNullOrEmpty($this.Description))
        {
            $NewRoleGroupParams.Remove('Description') | Out-Null
        }
        # CASE: Role Group doesn't exist but should;
        if ($this.Ensure -eq 'Present' -and $currentRoleGroupConfig.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Role Group '$($this.Name)' does not exist but it should. Create and configure it."
            # Create Role Group
            if ($Members.Length -gt 0)
            {
                $NewRoleGroupParams.Add('Members', $Members)
            }
            New-RoleGroup @NewRoleGroupParams
        }
        elseif ($this.Ensure -eq 'Present' -and $currentRoleGroupConfig.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Role Group '$($this.Name)' already exists. Update its display name and description."
            $UpdateRoleGroupParams = @{
                Identity = $this.Name
                Confirm  = $false
            }

            if (-not [System.String]::IsNullOrEmpty($this.DisplayName))
            {
                $UpdateRoleGroupParams.Add('DisplayName', $this.DisplayName)
            }

            if ($null -ne $this.Description)
            {
                $UpdateRoleGroupParams.Add('Description', $this.Description)
            }

            Set-RoleGroup @UpdateRoleGroupParams -ErrorAction Stop
        }
        # CASE: Role Group exists but it shouldn't;
        elseif ($this.Ensure -eq 'Absent' -and $currentRoleGroupConfig.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Role Group '$($this.Name)' exists but it shouldn't. Remove it."
            Remove-RoleGroup -Identity $this.Name -Confirm:$false -Force
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

        $ConnectionMode = $this.Connect('SecurityComplianceCenter')

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Export')

        try
        {
            [array] $exportedInstances = Get-RoleGroup
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
            foreach ($RoleGroup in $exportedInstances)
            {
                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }

                Write-M365DSCHost -Message "    |---[$i/$($exportedInstances.Count)] $($RoleGroup.Name)" -DeferWrite

                $Params = @{
                    Name                  = $RoleGroup.Name
                    Roles                 = $RoleGroup.Roles
                    Credential            = $this.Credential
                    ApplicationId         = $this.ApplicationId
                    TenantId              = $this.TenantId
                    CertificateThumbprint = $this.CertificateThumbprint
                    CertificatePassword   = $this.CertificatePassword
                    ManagedIdentity       = $this.ManagedIdentity
                    CertificatePath       = $this.CertificatePath
                    AccessTokens          = $this.AccessTokens
                }
                $this.ExportedInstance = $RoleGroup
                $Results = $this.GetForExport($Params)
                $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                    -ConnectionMode $ConnectionMode `
                    -ModulePath $this.GetModulePath() `
                    -Results $Results `
                    -Credential $this.Credential
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

    hidden [SCRoleGroup] AsResult([System.Object] $Values)
    {
        if ($Values -is [SCRoleGroup])
        {
            return $Values
        }

        $result = [SCRoleGroup]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
