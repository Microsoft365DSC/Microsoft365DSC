using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class AzureBillingAccountsRoleAssignment : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('Name of the principal associated to the role assignment.')]
    [System.String] $PrincipalName

    [DscProperty(Key)]
    [System.ComponentModel.Description('Name of the role assigned to the principal.')]
    [System.String] $RoleDefinition

    [DscProperty()]
    [System.ComponentModel.Description('Principal type. Can be User, Group or ServicePrincipal.')]
    [System.String] $PrincipalType

    [DscProperty()]
    [System.ComponentModel.Description('Name of the billing account.')]
    [System.String] $BillingAccount

    [DscProperty()]
    [System.ComponentModel.Description('The principal tenant id of the user to whom the role was assigned.')]
    [System.String] $PrincipalTenantId

    [DscProperty()]
    [System.ComponentModel.Description('Present ensures the instance exists, absent ensures it is removed.')]
    [ValidateSet('Absent', 'Present')]
    [System.String] $Ensure

    [DscProperty()]
    [System.ComponentModel.Description('The Azure subscription to connect to if the access is restricted on subscription level.')]
    [System.String] $SubscriptionId

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

    [AzureBillingAccountsRoleAssignment] Get()
    {
        $RoleDefinitionValue = $null
        $instance = $null
        if ($this.RequiresPowerShellCore())
        {
            $remote = [AzureBillingAccountsRoleAssignment]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of Azure Billing Accounts Role Assignment for Billing Account $($this.BillingAccount) and Principal Name $($this.PrincipalName)"

        try
        {
            $null = $this.Connect('Azure')

            $null = $this.Connect('MicrosoftGraph')

            #Ensure the proper dependencies are installed in the current environment.
            Confirm-M365DSCDependencies

            #region Telemetry
            $this.AddTelemetry('Get')
            #endregion

            $nullResult = $this.GetBoundParameters()
            $nullResult.Ensure = 'Absent'

            $accounts = Get-M365DSCAzureBillingAccount
            $currentAccount = $accounts.value | Where-Object -FilterScript { $_.properties.displayName -eq $this.BillingAccount }

            if ($null -ne $currentAccount)
            {
                $instances = Get-M365DSCAzureBillingAccountsRoleAssignment -BillingAccountId $currentAccount.Name -ErrorAction Stop
                $PrincipalIdValue = $this.GetPrincipalIdFromName($this.PrincipalName, $this.PrincipalType)
                $instance = $instances.value | Where-Object -FilterScript { $_.properties.principalId -eq $PrincipalIdValue }

                if ($null -ne $instance)
                {
                    $roleDefinitionId = $instance.properties.roleDefinitionId.Split('/')
                    $roleDefinitionId = $roleDefinitionId[$roleDefinitionId.Length - 1]
                    $RoleDefinitionValue = Get-M365DSCAzureBillingAccountsRoleDefinition -BillingAccountId $currentAccount.Name `
                        -RoleDefinitionId $roleDefinitionId
                }
            }
            if ($null -eq $instance)
            {
                return $this.AsResult($nullResult)
            }

            $results = @{
                BillingAccount        = $this.BillingAccount
                PrincipalName         = $this.PrincipalName
                PrincipalType         = $this.PrincipalType
                PrincipalTenantId     = $instance.properties.principalTenantId
                RoleDefinition        = $RoleDefinitionValue.properties.roleName
                Ensure                = 'Present'
                SubscriptionId        = $this.SubscriptionId
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
        $roleDefinitionId = $null
        if ($this.RequiresPowerShellCore())
        {
            $null = $this.InvokeInPowerShellCore('Set')
            return
        }

        Write-Verbose -Message "Setting configuration of Azure Billing Accounts Role Assignment for Billing Account {$($this.BillingAccount)} and Principal Name {$($this.PrincipalName)}"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $currentInstance = $this.Get().ToHashtable()

        $billingAccounts = Get-M365DSCAzureBillingAccount
        $account = $billingAccounts.value | Where-Object -FilterScript { $_.properties.displayName -eq $this.BillingAccount }
        $PrincipalIdValue = $this.GetPrincipalIdFromName($this.PrincipalName, $this.PrincipalType)
        $RoleDefinitionValues = Get-M365DSCAzureBillingAccountsRoleDefinition -BillingAccountId $account.Name
        $roleDefinitionInstance = $RoleDefinitionValues.value | Where-Object -FilterScript { $_.properties.roleName -eq $currentInstance.RoleDefinition }
        $instanceParams = @{
            principalId       = $PrincipalIdValue
            principalTenantId = $currentInstance.PrincipalTenantId
            roleDefinitionId  = $roleDefinitionInstance.id
        }
        # CREATE
        if ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Adding new role assignment for user {$($this.PrincipalName)} for role {$($this.RoleDefinition)}"
            New-M365DSCAzureBillingAccountsRoleAssignment -BillingAccountId $account.Name `
                -Body $instanceParams
        }
        # UPDATE
        elseif ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Updating role assignment for user {$($this.PrincipalName)} for role {$($this.RoleDefinition)}"
            New-M365DSCAzureBillingAccountsRoleAssignment -BillingAccountId $account.Name `
                -Body $instanceParams
        }
        # REMOVE
        elseif ($this.Ensure -eq 'Absent' -and $currentInstance.Ensure -eq 'Present')
        {
            $instances = Get-M365DSCAzureBillingAccountsRoleAssignment -BillingAccountId $account.Name -ErrorAction Stop
            $instance = $instances.value | Where-Object -FilterScript { $_.properties.principalId -eq $PrincipalIdValue }
            $AssignmentId = $instance.Id.Split('/')
            $AssignmentId = $AssignmentId[$roleDefinitionId.Length - 1]
            Write-Verbose -Message "Removing role assignment for user {$($this.PrincipalName)} for role {$($this.RoleDefinition)}"
            Remove-M365DSCAzureBillingAccountsRoleAssignment -BillingAccountId $account.Name `
                -AssignmentId $AssignmentId
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

        $ConnectionMode = $this.Connect('Azure')

        $ConnectionMode = $this.Connect('MicrosoftGraph')

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Export')

        try
        {
            #Get all billing account
            [array]$accounts = Get-M365DSCAzureBillingAccount

            $i = 1
            $dscContent = [System.Text.StringBuilder]::new()
            if ($accounts.Count -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }
            foreach ($config in $accounts.value)
            {
                $displayedKey = $config.properties.displayName
                Write-M365DSCHost -Message "    |---[$i/$($accounts.Count)] $displayedKey"

                $assignments = Get-M365DSCAzureBillingAccountsRoleAssignment -BillingAccountId $config.name

                $j = 1
                foreach ($assignment in $assignments.value)
                {
                    if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                    {
                        $Global:M365DSCExportResourceInstancesCount++
                    }

                    $PrincipalNameValue = $this.GetPrincipalNameFromId($assignment.properties.principalId, $assignment.properties.principalType)
                    $roleDefinitionId = $assignment.properties.roleDefinitionId.Split('/')
                    $roleDefinitionId = $roleDefinitionId[$roleDefinitionId.Length - 1]

                    Write-M365DSCHost -Message "        |---[$j/$($assignments.value.Length)] $($assignment.properties.principalId)" -DeferWrite
                    $params = @{
                        BillingAccount        = $config.properties.displayName
                        PrincipalName         = $PrincipalNameValue
                        PrincipalType         = $assignment.properties.principalType
                        PrincipalTenantId     = $assignment.properties.principalTenantId
                        RoleDefinition        = 'AnyRole'
                        SubscriptionId        = $this.SubscriptionId
                        Credential            = $this.Credential
                        ApplicationId         = $this.ApplicationId
                        TenantId              = $this.TenantId
                        CertificateThumbprint = $this.CertificateThumbprint
                        ManagedIdentity       = $this.ManagedIdentity
                        AccessTokens          = $this.AccessTokens
                    }

                    $Results = $this.GetForExport($Params)

                    $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                        -ConnectionMode $ConnectionMode `
                        -ModulePath $this.GetModulePath() `
                        -Results $Results `
                        -Credential $this.Credential
                    [void]$dscContent.Append($currentDSCBlock)
                    Save-M365DSCPartialExport -Content $currentDSCBlock `
                        -FileName $Global:PartialExportFileName
                    $j++
                    Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
                }
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
            ExcludedProperties = @('SubscriptionId')
        }
    }

    hidden [System.String] GetPrincipalNameFromId([System.String] $PrincipalId, [System.String] $PrincipalType)
    {
        $result = $null
        if ($PrincipalType -eq 'User')
        {
            $userInfo = Get-MgUser -UserId $PrincipalId
            if ($null -ne $userInfo)
            {
                $result = $userInfo.UserPrincipalName
            }
        }
        elseif ($PrincipalType -eq 'ServicePrincipal')
        {
            $spnInfo = Get-MgServicePrincipal -ServicePrincipalId $PrincipalId
            if ($null -ne $spnInfo)
            {
                $result = $spnInfo.DisplayName
            }
        }
        elseif ($PrincipalType -eq 'Group')
        {
            $groupInfo = Get-MgGroup -GroupId $PrincipalId
            if ($null -ne $groupInfo)
            {
                $result = $groupInfo.DisplayName
            }
        }
        return $result
    }

    hidden [System.String] GetPrincipalIdFromName([System.String] $PrincipalName, [System.String] $PrincipalType)
    {
        $result = $null
        if ($PrincipalType -eq 'User')
        {
            $userInfo = Get-MgUser -Filter "UserPrincipalName eq '$($PrincipalName -replace "'", "''")'"
            if ($null -ne $userInfo)
            {
                $result = $userInfo.Id
            }
        }
        elseif ($PrincipalType -eq 'ServicePrincipal')
        {
            $spnInfo = Get-MgServicePrincipal -Filter "DisplayName eq '$($PrincipalName -replace "'", "''")'"
            if ($null -ne $spnInfo)
            {
                $result = $spnInfo.Id
            }
        }
        elseif ($PrincipalType -eq 'Group')
        {
            $groupInfo = Get-MgGroup -Filter "DisplayName eq '$($PrincipalName -replace "'", "''")'"
            if ($null -ne $groupInfo)
            {
                $result = $groupInfo.Id
            }
        }
        return $result
    }

    hidden [AzureBillingAccountsRoleAssignment] AsResult([System.Object] $Values)
    {
        if ($Values -is [AzureBillingAccountsRoleAssignment])
        {
            return $Values
        }

        $result = [AzureBillingAccountsRoleAssignment]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
