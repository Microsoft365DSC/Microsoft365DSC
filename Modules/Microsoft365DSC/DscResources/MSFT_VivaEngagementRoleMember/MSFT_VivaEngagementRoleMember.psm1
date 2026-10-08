using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class VivaEngagementRoleMember : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('Name of the engagement role.')]
    [System.String] $Role

    [DscProperty()]
    [System.ComponentModel.Description('User principal names of the users to assign to the role.')]
    [System.String[]] $Members

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

    [VivaEngagementRoleMember] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [VivaEngagementRoleMember]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration for Viva Engagement Role Member for role $($this.Role)"

        try
        {
            if ($null -eq $this.ExportedInstance -or $this.Role -ne $this.ExportedInstance.displayName)
            {
                $null = $this.Connect('MicrosoftGraph')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $uri = '/beta/employeeExperience/roles'
                $roles = Invoke-M365DSCGraphRequest -Uri $uri -Method GET
                $roleInstance = $roles.value | Where-Object -FilterScript { $_.displayName -eq $this.role }

                if ([System.String]::IsNullOrEmpty($roleInstance))
                {
                    throw "Could not find role instance with name {$($this.role)}"
                }
            }
            else
            {
                $roleInstance = $this.ExportedInstance
            }

            $uri = "/beta/employeeExperience/roles/$($roleInstance.id)/members"
            $idsOfMembers = Invoke-M365DSCGraphRequest -Uri $uri -Method GET

            $membersValue = @()
            foreach ($memberId in $idsOfMembers.value)
            {
                $userInfo = Get-MgUser -UserId $memberId.id
                $membersValue += $userInfo.UserPrincipalName
            }

            $results = @{
                Role                  = $this.Role
                Members               = $membersValue
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

        Write-Verbose -Message "Setting configuration for Viva Engagement Role Member for role $($this.Role)"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $currentInstance = $this.Get().ToHashtable()

        $uri = '/beta/employeeExperience/roles'
        $roles = Invoke-M365DSCGraphRequest -Uri $uri -Method GET
        $roleInstance = $roles.value | Where-Object -FilterScript { $_.displayName -eq $this.role }

        $membersDiff = Compare-Object -ReferenceObject $currentInstance.Members -DifferenceObject $this.Members

        foreach ($member in $membersDiff)
        {
            $userInfo = Get-MgUser -Filter "UserPrincipalName eq '$($member.InputObject)'"
            if (-not [System.String]::IsNullOrEmpty($userInfo))
            {
                if ($member.SideIndicator -eq '=>')
                {
                    Write-Verbose -Message "Adding user {$($member.InputObject)} to role {$($this.Role)}"
                    $uri = "/beta/employeeExperience/roles/$($roleInstance.id)/members"
                    $body = @{
                        'user@odata.bind' = (Get-MSCloudLoginConnectionProfile -Workload MicrosoftGraph).ResourceUrl + "beta/users('" + $userInfo.Id + "')"
                    }
                    Write-Verbose -Message "POST request to $uri with:`r`n$(ConvertTo-Json $body -Depth 10)"
                    Invoke-M365DSCGraphRequest -Uri $uri -Method POST -Body $body
                }
                else
                {
                    Write-Verbose -Message "Removing user {$($member.InputObject)} from role {$($this.Role)}"
                    $uri = "/beta/employeeExperience/roles/$($roleInstance.id)/members/$($userInfo.Id)"
                    Invoke-M365DSCGraphRequest -Uri $uri -Method DELETE
                }
            }
            else
            {
                throw "Could not find user {$($member.InputObject)}"
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

        $ConnectionMode = $this.Connect('MicrosoftGraph')

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Export')

        try
        {
            $uri = '/beta/employeeExperience/roles'
            [array]$roles = (Invoke-M365DSCGraphRequest -Uri $uri -Method Get -ErrorAction Stop).value

            $i = 1
            $dscContent = [System.Text.StringBuilder]::new()
            if ($roles.Length -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }
            foreach ($role in $roles)
            {
                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }

                $displayedKey = $role.displayName
                Write-M365DSCHost -Message "    |---[$i/$($roles.Count)] $displayedKey" -DeferWrite
                $params = @{
                    Role                  = $role.displayName
                    Credential            = $this.Credential
                    ApplicationId         = $this.ApplicationId
                    TenantId              = $this.TenantId
                    CertificateThumbprint = $this.CertificateThumbprint
                    CertificatePath       = $this.CertificatePath
                    CertificatePassword   = $this.CertificatePassword
                    ManagedIdentity       = $this.ManagedIdentity
                    AccessTokens          = $this.AccessTokens
                }

                $this.ExportedInstance = $role
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

    hidden [VivaEngagementRoleMember] AsResult([System.Object] $Values)
    {
        if ($Values -is [VivaEngagementRoleMember])
        {
            return $Values
        }

        $result = [VivaEngagementRoleMember]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
