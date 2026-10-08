using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class SCRoleGroupMember : M365DSCResourceBase
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
    [System.ComponentModel.Description('Specify if the Role Group Members should exist or not.')]
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

    [SCRoleGroupMember] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [SCRoleGroupMember]::new()
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

            # Get RoleGroup Members if RoleGroup exists.
            $roleGroupMembers = @()
            if (@($RoleGroup.Members).Count -gt 0)
            {
                $roleGroupMembers = Get-RoleGroupMember -Identity $RoleGroup.Name -ErrorAction Stop | Select-Object -Property @("Alias", "Name")
            }
            $roleGroupMembersValue = @()
            foreach ($member in $roleGroupMembers)
            {
                # To ensure uniqueness for members, use Alias if it is an email address, otherwise use Name
                if ($member.Alias.Contains("@"))
                {
                    $roleGroupMembersValue += $member.Alias
                    continue
                }
                $roleGroupMembersValue += $member.Name
            }

            $result = @{
                Name                  = $RoleGroup.Name
                Description           = $RoleGroup.Description
                Members               = $roleGroupMembersValue
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

        $null = $this.Connect('SecurityComplianceCenter')

        # CASE: Role Group has different member values than the desired ones
        $MembersValue = $this.Members
        if ([System.String]::IsNullOrEmpty($this.Members))
        {
            $MembersValue = @()
        }

        $currentMembersValue = $currentRoleGroupConfig.Members
        if ([System.String]::IsNullOrEmpty($currentRoleGroupConfig.Members))
        {
            $currentMembersValue = @()
        }

        $differences = Compare-Object -ReferenceObject $currentMembersValue -DifferenceObject $MembersValue

        if ($this.Ensure -eq 'Present' -and $currentRoleGroupConfig.Ensure -eq 'Present' -and $null -ne $differences)
        {
            Write-Verbose -Message "Role Group '$($this.Name)' exists, but members need updating."
            foreach ($difference in $differences)
            {
                if ($difference.SideIndicator -eq '=>')
                {
                    Write-Verbose -Message "Adding Member {$($difference.InputObject)} to Role Group {$($this.Name)}"
                    Add-RoleGroupMember -Identity $this.Name -Member $($difference.InputObject)
                }
                elseif ($difference.SideIndicator -eq '<=')
                {
                    Write-Verbose -Message "Removing Member {$($difference.InputObject)} from Role Group {$($this.Name)}"
                    Remove-RoleGroupMember -Identity $this.Name -Member $($difference.InputObject)
                }
            }
        }
        # CASE: Role Group Membership should be removed
        elseif ($this.Ensure -eq 'Absent' -and $currentRoleGroupConfig.Ensure -eq 'Present')
        {
            foreach ($member in $this.Members)
            {
                Write-Verbose -Message "Removing Member {$member} from Role Group {$($this.Name)}"
                Remove-RoleGroupMember -Identity $this.Name -Member $member
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
                    Description           = $RoleGroup.Description
                    Credential            = $this.Credential
                    ApplicationId         = $this.ApplicationId
                    TenantId              = $this.TenantId
                    CertificateThumbprint = $this.CertificateThumbprint
                    CertificatePassword   = $this.CertificatePassword
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

    [System.Collections.Hashtable] GetCompareParameters()
    {
        return @{
            ExcludedProperties = @('Description')
        }
    }

    hidden [SCRoleGroupMember] AsResult([System.Object] $Values)
    {
        if ($Values -is [SCRoleGroupMember])
        {
            return $Values
        }

        $result = [SCRoleGroupMember]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
