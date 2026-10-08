using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class EXOApplicationAccessPolicy : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The Identity parameter specifies the application access policy that you want to modify.')]
    [System.String] $Identity

    [DscProperty()]
    [System.ComponentModel.Description('The AccessRight parameter specifies the permission that you want to assign in the application access policy.')]
    [ValidateSet('RestrictAccess', 'DenyAccess')]
    [System.String] $AccessRight

    [DscProperty()]
    [System.ComponentModel.Description('The AppID parameter specifies the GUID of the apps to include in the policy.')]
    [System.String[]] $AppID

    [DscProperty()]
    [System.ComponentModel.Description('The PolicyScopeGroupID parameter specifies the recipient to define in the policy. You can use any value that uniquely identifies the recipient.')]
    [System.String] $PolicyScopeGroupId

    [DscProperty()]
    [System.ComponentModel.Description('The Description parameter specifies a description for the policy.')]
    [System.String] $Description

    [DscProperty()]
    [System.ComponentModel.Description('Specify if the Application Access Policy should exist or not.')]
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

    [EXOApplicationAccessPolicy] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [EXOApplicationAccessPolicy]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting Application Access Policy configuration for $($this.Identity)"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.Identity -ne $this.Identity)
            {
                $null = $this.Connect('ExchangeOnline')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullReturn = $this.GetBoundParameters()
                $nullReturn.Ensure = 'Absent'

                $ApplicationAccessPolicy = $null
                [Array]$ApplicationAccessPolicy = Get-ApplicationAccessPolicy -Identity $this.Identity -ErrorAction SilentlyContinue

                $ScopeIdentityValue = $null
                if ($null -ne $ApplicationAccessPolicy)
                {
                    $ScopeIdentityValue = $ApplicationAccessPolicy.ScopeIdentity
                }
                elseif (-not [System.String]::IsNullOrEmpty($this.PolicyScopeGroupId))
                {
                    $scopeIdentityGroup = $null
                    $scopeIdentityGroup = Get-Group -Identity $this.PolicyScopeGroupId -ErrorAction SilentlyContinue

                    if ($null -ne $scopeIdentityGroup)
                    {
                        $ScopeIdentityValue = $scopeIdentityGroup.WindowsEmailAddress
                        $ApplicationAccessPolicy = Get-ApplicationAccessPolicy -ErrorAction SilentlyContinue | Where-Object -FilterScript { $this.AppID -eq $_.AppId -and $_.ScopeIdentity -eq $scopeIdentityGroup }
                    }
                    else
                    {
                        Write-Verbose -Message "Could not find Group with Identity {$($this.PolicyScopeGroupId)}"
                    }

                    if ($null -ne $ApplicationAccessPolicy)
                    {
                        Write-Verbose -Message "Found Application Access Policy by Scope {$($this.PolicyScopeGroupId)}"
                    }
                }

                if ($null -eq $ApplicationAccessPolicy)
                {
                    Write-Verbose -Message "Application Access Policy $($this.Identity) does not exist."
                    return $this.AsResult($nullReturn)
                }
            }
            else
            {
                $ApplicationAccessPolicy = $this.ExportedInstance
                $ScopeIdentityValue = $ApplicationAccessPolicy.ScopeIdentity
            }

            Write-Verbose -Message "Found Application Access Policy {$($this.Identity)}"

            $ApplicationAccessPolicy = $ApplicationAccessPolicy[0]
            $result = @{
                Identity              = $ApplicationAccessPolicy.Identity
                AccessRight           = $ApplicationAccessPolicy.AccessRight
                AppID                 = $ApplicationAccessPolicy.AppID
                PolicyScopeGroupId    = $ScopeIdentityValue
                Description           = $ApplicationAccessPolicy.Description
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

        $this.WarnResourceDeprecated("RBAC for Applications with 'EXOServicePrincipal', 'EXOManagementScope' and 'EXOManagementRoleAssignment'", 'https://learn.microsoft.com/exchange/permissions-exo/application-rbac')

        Write-Verbose -Message "Setting Application Access Policy configuration for $($this.Identity)"

        $currentApplicationAccessPolicyConfig = $this.Get().ToHashtable()

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $null = $this.Connect('ExchangeOnline')

        $NewApplicationAccessPolicyParams = @{
            AccessRight        = $this.AccessRight
            AppID              = $this.AppID
            PolicyScopeGroupId = $this.PolicyScopeGroupId
            Description        = $this.Description
            Confirm            = $false
        }

        $SetApplicationAccessPolicyParams = @{
            Identity    = $currentApplicationAccessPolicyConfig.Identity
            Description = $this.Description
            Confirm     = $false
        }

        # CASE: Application Access Policy doesn't exist but should;
        if ($this.Ensure -eq 'Present' -and $currentApplicationAccessPolicyConfig.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Application Access Policy '$($this.Identity)' does not exist but it should. Create and configure it."
            # Create Application Access Policy
            New-ApplicationAccessPolicy @NewApplicationAccessPolicyParams

        }
        # CASE: Application Access Policy exists but it shouldn't;
        elseif ($this.Ensure -eq 'Absent' -and $currentApplicationAccessPolicyConfig.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Application Access Policy '$($this.Identity)' exists but it shouldn't. Remove it."
            Remove-ApplicationAccessPolicy -Identity $this.Identity -Confirm:$false
        }
        # CASE: Application Access Policy exists and it should, but Description attribute has different values than desired (Set-ApplicationAccessPolicy is only able to change description attribute)
        elseif ($this.Ensure -eq 'Present' -and $currentApplicationAccessPolicyConfig.Ensure -eq 'Present' -and $currentApplicationAccessPolicyConfig.Description -ne $this.Description)
        {
            Write-Verbose -Message "Application Access Policy '$($currentApplicationAccessPolicyConfig.Identity)' already exists, but needs updating."
            Write-Verbose -Message "Setting Application Access Policy $($currentApplicationAccessPolicyConfig.Identity) with values: $(Convert-M365DscHashtableToString -Hashtable $SetApplicationAccessPolicyParams)"
            Set-ApplicationAccessPolicy @SetApplicationAccessPolicyParams
        }
        # CASE: Application Access Policy exists and it should, but has different values than the desired one
        # Set-ApplicationAccessPolicy is only able to change description attribute, therefore re-create policy
        elseif ($this.Ensure -eq 'Present' -and $currentApplicationAccessPolicyConfig.Ensure -eq 'Present' -and $currentApplicationAccessPolicyConfig.Description -eq $this.Description)
        {
            Write-Verbose -Message "Re-create Application Access Policy '$($currentApplicationAccessPolicyConfig.Identity)'"
            Remove-ApplicationAccessPolicy -Identity $currentApplicationAccessPolicyConfig.Identity -Confirm:$false
            Write-Verbose -Message 'Removing existing policy was successful'
            Write-Verbose -Message "Creating new instance with parameters: $(Convert-M365DscHashtableToString -Hashtable $NewApplicationAccessPolicyParams)"
            New-ApplicationAccessPolicy @NewApplicationAccessPolicyParams
        }
    }

    [bool] Test()
    {
        $this.WarnResourceDeprecated("RBAC for Applications with 'EXOServicePrincipal', 'EXOManagementScope' and 'EXOManagementRoleAssignment'", 'https://learn.microsoft.com/exchange/permissions-exo/application-rbac')

        return ([M365DSCResourceBase] $this).Test()
    }

    [string] Export()
    {
        if ($this.RequiresPowerShellCore())
        {
            return [string] $this.InvokeInPowerShellCore('Export')
        }

        $this.WarnResourceDeprecated("RBAC for Applications with 'EXOServicePrincipal', 'EXOManagementScope' and 'EXOManagementRoleAssignment'", 'https://learn.microsoft.com/exchange/permissions-exo/application-rbac')

        $ConnectionMode = $this.Connect('ExchangeOnline')

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Export')

        try
        {
            try
            {
                [array]$AllApplicationAccessPolicies = Get-ApplicationAccessPolicy -ErrorAction Stop
            }
            catch
            {
                if ($_.Exception -like "*The operation couldn't be performed because object*")
                {
                    Write-M365DSCHost -Message "`r`n    $($Global:M365DSCEmojiYellowCircle) The current tenant is not registered to allow for Application Access Policies" -CommitWrite
                    return ''
                }
                throw $_
            }

            $dscContent = [System.Text.StringBuilder]::new()
            if ($AllApplicationAccessPolicies.Length -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }
            $i = 1
            foreach ($ApplicationAccessPolicy in $AllApplicationAccessPolicies)
            {
                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }

                Write-M365DSCHost -Message "    |---[$i/$($AllApplicationAccessPolicies.Count)] $($ApplicationAccessPolicy.Identity)" -DeferWrite

                $Params = @{
                    Identity              = $ApplicationAccessPolicy.Identity
                    Credential            = $this.Credential
                    ApplicationId         = $this.ApplicationId
                    TenantId              = $this.TenantId
                    CertificateThumbprint = $this.CertificateThumbprint
                    CertificatePassword   = $this.CertificatePassword
                    ManagedIdentity       = $this.ManagedIdentity
                    CertificatePath       = $this.CertificatePath
                    AccessTokens          = $this.AccessTokens
                }
                $this.ExportedInstance = $ApplicationAccessPolicy
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

    hidden [EXOApplicationAccessPolicy] AsResult([System.Object] $Values)
    {
        if ($Values -is [EXOApplicationAccessPolicy])
        {
            return $Values
        }

        $result = [EXOApplicationAccessPolicy]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
