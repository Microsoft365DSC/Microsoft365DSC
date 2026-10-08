using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class EXORoleGroup : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The Name parameter specifies the name of the role. The maximum length of the name is 64 characters.')]
    [ValidateLength(1, 64)]
    [System.String] $Name

    [DscProperty()]
    [System.ComponentModel.Description('The Description parameter specifies the description that''s displayed when the role group is viewed using the Get-RoleGroup cmdlet. Enclose the description in quotation marks')]
    [System.String] $Description

    [DscProperty()]
    [System.ComponentModel.Description('The Members parameter specifies the mailboxes or mail-enabled USGs to add as a member of the role group. You can identify the user or group by the name, DN, or primary SMTP address value. You can specify multiple members separated by commas (Value1,Value2,...ValueN). If the value contains spaces, enclose the value in quotation marks')]
    [System.String[]] $Members

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

    # Export-only. Not part of the resource schema.
    [System.String] $Filter

    [EXORoleGroup] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [EXORoleGroup]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting Role Group configuration for $($this.Name)"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.Name -ne $this.Name)
            {
                $null = $this.Connect('ExchangeOnline')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullReturn = $this.GetBoundParameters()
                $nullReturn.Ensure = 'Absent'

                $RoleGroup = Get-RoleGroup -Filter "Name -eq '$($this.Name)'" -ErrorAction SilentlyContinue
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

            # Get RoleGroup Members DN if RoleGroup exists. This is required especially when adding Members like "Exchange Administrator" or "Global Administrator" that have different Names across Tenants
            $roleGroupMembers = Get-RoleGroupMember -Identity $this.Name | Select-Object DisplayName, RecipientTypeDetails, PrimarySmtpAddress, WindowsLiveId

            $roleGroupMembersValue = @()
            foreach ($member in $roleGroupMembers)
            {
                if (-not [System.String]::IsNullOrEmpty($member.WindowsLiveID))
                {
                    $roleGroupMembersValue += $member.WindowsLiveID
                }
                elseif (-not [System.String]::IsNullOrEmpty($member.WindowsEmailAddress))
                {
                    $roleGroupMembersValue += $member.WindowsEmailAddress
                }
                elseif (-not [System.String]::IsNullOrEmpty($member.PrimarySmtpAddress))
                {
                    $roleGroupMembersValue += $member.PrimarySmtpAddress
                }
                else
                {
                    $roleGroupMembersValue += $member.DisplayName
                }
            }
            $result = @{
                Name                  = $RoleGroup.Name
                Description           = $RoleGroup.Description
                Members               = $roleGroupMembersValue
                Roles                 = $RoleGroup.Roles
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
        if ($this.RequiresPowerShellCore())
        {
            $null = $this.InvokeInPowerShellCore('Set')
            return
        }

        Write-Verbose -Message "Setting Role Group configuration for $($this.Name)"

        $currentRoleGroupConfig = $this.Get().ToHashtable()

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $NewRoleGroupParams = @{
            Name        = $this.Name
            Description = $this.Description
            Roles       = $this.Roles
            Confirm     = $false
        }
        # Remove Description Parameter if null or Empty as the creation fails with $null parameter
        if ([System.String]::IsNullOrEmpty($this.Description))
        {
            $NewRoleGroupParams.Remove('Description') | Out-Null
        }
        # Remove Roles Parameter if null or Empty as the creation requires at least one Role
        if ($this.Roles.Length -eq 0)
        {
            $NewRoleGroupParams.Remove('Roles') | Out-Null
        }
        # CASE: Role Group doesn't exist but should;
        if ($this.Ensure -eq 'Present' -and $currentRoleGroupConfig.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Role Group '$($this.Name)' does not exist but it should. Create and configure it."
            # Create Role Group
            if ($this.Members.Length -gt 0)
            {
                $NewRoleGroupParams.Add('Members', $this.Members)
            }
            New-RoleGroup @NewRoleGroupParams
        }
        # CASE: Role Group exists but it shouldn't;
        elseif ($this.Ensure -eq 'Absent' -and $currentRoleGroupConfig.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Role Group '$($this.Name)' exists but it shouldn't. Remove it."
            Remove-RoleGroup -Identity $this.Name -Confirm:$false -Force
        }
        # CASE: Role Group exists and it should, but has different values than the desired ones
        elseif ($this.Ensure -eq 'Present' -and $currentRoleGroupConfig.Ensure -eq 'Present')
        {
            $boundParameters = $this.GetBoundParameters()

            if ($boundParameters.ContainsKey('Description') -and $this.Description -ne $currentRoleGroupConfig.Description)
            {
                Write-Verbose -Message "Updating Role Group $($this.Name) description to '$($this.Description)'"
                Set-RoleGroup -Identity $this.Name -Description $this.Description -Confirm:$false
            }

            if ($boundParameters.ContainsKey('Members') -and $null -ne (Compare-Object -ReferenceObject @($currentRoleGroupConfig.Members | Select-Object) -DifferenceObject @($this.Members | Select-Object)))
            {
                Write-Verbose -Message "Updating Role Group $($this.Name) members with values: $($this.Members -join ', ')"
                Update-RoleGroupMember -Identity $this.Name -Members $this.Members -Confirm:$false
            }

            if ($boundParameters.ContainsKey('Roles'))
            {
                $differences = Compare-Object -ReferenceObject @($currentRoleGroupConfig.Roles | Select-Object) -DifferenceObject @($this.Roles | Select-Object)
                foreach ($difference in $differences)
                {
                    if ($difference.SideIndicator -eq '=>')
                    {
                        Write-Verbose -Message "Adding Role {$($difference.InputObject)} to Role Group {$($this.Name)}"
                        New-ManagementRoleAssignment -Role $($difference.InputObject) -SecurityGroup $this.Name
                    }
                    elseif ($difference.SideIndicator -eq '<=')
                    {
                        Write-Verbose -Message "Removing Role {$($difference.InputObject)} from Role Group {$($this.Name)}"
                        Remove-ManagementRoleAssignment -Identity "$($difference.InputObject)-$($this.Name)" -Confirm:$false
                    }
                }
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

        $ConnectionMode = $this.Connect('ExchangeOnline')

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Export')

        try
        {
            $roleGroups = Get-RoleGroup

            if (-not [System.String]::IsNullOrEmpty($this.Filter))
            {
                $filterScriptBlock = [ScriptBlock]::Create($this.Filter)
                $roleGroups = $roleGroups | Where-Object -FilterScript $filterScriptBlock
            }
            [array] $exportedInstances = $roleGroups

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

    # Members provided as display names are resolved to comparable identifiers.
    [System.Collections.Hashtable] GetCompareParameters()
    {
        return @{
            PostProcessing = {
                param($DesiredValues, $CurrentValues, $ValuesToCheck, $PostProcessingArgs)

                if ([M365DSCResourceBase]::IsReportContext($PostProcessingArgs))
                {
                    return [System.Tuple[Hashtable, Hashtable, Hashtable]]::new($DesiredValues, $CurrentValues, $ValuesToCheck)
                }

                if ($DesiredValues.ContainsKey('Members'))
                {
                    $newMembersValue = @()
                    foreach ($member in $DesiredValues.Members)
                    {
                        $group = Get-Group -Filter "DisplayName eq '$member'" -ErrorAction 'SilentlyContinue'
                        if ($null -ne $group -and $null -ne $group.PrimarySmtpAddress)
                        {
                            $newMembersValue += $group.PrimarySmtpAddress
                        }
                        elseif ($null -ne $group -and $null -ne $group.WindowsEmailAddress)
                        {
                            $newMembersValue += $group.WindowsEmailAddress
                        }
                        else
                        {
                            $user = Get-User -Identity $member -ErrorAction 'SilentlyContinue'
                            if ($null -ne $user)
                            {
                                if ($member.Contains('@'))
                                {
                                    $newMembersValue += $user.UserPrincipalName
                                }
                                else
                                {
                                    $newMembersValue += $user.DisplayName
                                }
                            }
                            else
                            {
                                $newMembersValue += $member
                            }
                        }
                    }
                    $DesiredValues.Members = [Array] $newMembersValue
                    $ValuesToCheck.Members = [Array] $newMembersValue
                }

                return [System.Tuple[Hashtable, Hashtable, Hashtable]]::new($DesiredValues, $CurrentValues, $ValuesToCheck)
            }
        }
    }

    hidden [EXORoleGroup] AsResult([System.Object] $Values)
    {
        if ($Values -is [EXORoleGroup])
        {
            return $Values
        }

        $result = [EXORoleGroup]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
