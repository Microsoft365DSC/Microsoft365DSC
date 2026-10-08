using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class AzureRoleDefinition : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('Specifies a display name for the custom role definition.')]
    [System.String] $CustomRoleName

    [DscProperty()]
    [System.ComponentModel.Description('Specifies the unique identifier (GUID) of the role definition.')]
    [System.String] $Id

    [DscProperty()]
    [System.ComponentModel.Description('Specifies a description for the custom role definition.')]
    [System.String] $Description

    [DscProperty()]
    [System.ComponentModel.Description('Specifies the permitted control plane actions for the role definition.')]
    [System.String[]] $Actions

    [DscProperty()]
    [System.ComponentModel.Description('Specifies the excluded control plane actions for the role definition.')]
    [System.String[]] $NotActions

    [DscProperty()]
    [System.ComponentModel.Description('Specifies the permitted data plane actions for the role definition.')]
    [System.String[]] $DataActions

    [DscProperty()]
    [System.ComponentModel.Description('Specifies the excluded data plane actions for the role definition.')]
    [System.String[]] $NotDataActions

    [DscProperty()]
    [System.ComponentModel.Description('Specifies the assignable scopes for the role definition.')]
    [System.String[]] $AssignableScopes

    [DscProperty()]
    [System.ComponentModel.Description('Present ensures the instance exists, absent ensures it is removed.')]
    [ValidateSet('Present', 'Absent')]
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
    [System.ComponentModel.Description('Secret of the Azure Active Directory application to authenticate with.')]
    [System.Management.Automation.PSCredential] $ApplicationSecret

    [DscProperty()]
    [System.ComponentModel.Description('Thumbprint of the Azure Active Directory application''s authentication certificate to use for authentication.')]
    [System.String] $CertificateThumbprint

    [DscProperty()]
    [System.ComponentModel.Description('Managed ID being used for authentication.')]
    [System.Nullable[System.Boolean]] $ManagedIdentity

    [DscProperty()]
    [System.ComponentModel.Description('Access token used for authentication.')]
    [System.String[]] $AccessTokens

    # Export-only. Not part of the resource schema.
    [System.String] $Filter

    [AzureRoleDefinition] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [AzureRoleDefinition]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of Azure Role Definition with Name {$($this.CustomRoleName)}"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.Name -ne $this.CustomRoleName)
            {
                $null = $this.Connect('Azure')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullReturn = $this.GetBoundParameters()
                $nullReturn.Ensure = 'Absent'

                $AzureRoleDefinition = $null
                try
                {
                    if (-not [System.String]::IsNullOrEmpty($this.Id))
                    {
                        $AzureRoleDefinition = Get-AzRoleDefinition -Id $this.Id -ErrorAction SilentlyContinue
                    }
                }
                catch
                {
                    Write-Verbose -Message "Could not retrieve Azure Role Definition by Id: {$($this.Id)}"
                }

                if ($null -eq $AzureRoleDefinition)
                {
                    $AzureRoleDefinition = Get-AzRoleDefinition -Name $this.CustomRoleName -ErrorAction SilentlyContinue
                }

                if ($null -eq $AzureRoleDefinition)
                {
                    return $this.AsResult($nullReturn)
                }

                if (-not $AzureRoleDefinition.IsCustom)
                {
                    Write-Verbose -Message "Role definition {$($this.CustomRoleName)} is a built-in role. Returning Absent."
                    return $this.AsResult($nullReturn)
                }
            }
            else
            {
                $AzureRoleDefinition = $this.ExportedInstance
            }

            $result = @{
                CustomRoleName        = $AzureRoleDefinition.Name
                Id                    = $AzureRoleDefinition.Id
                Description           = $AzureRoleDefinition.Description
                Actions               = [Array]$AzureRoleDefinition.Actions
                NotActions            = [Array]$AzureRoleDefinition.NotActions
                DataActions           = [Array]$AzureRoleDefinition.DataActions
                NotDataActions        = [Array]$AzureRoleDefinition.NotDataActions
                AssignableScopes      = [Array]$AzureRoleDefinition.AssignableScopes
                IsCustom              = $AzureRoleDefinition.IsCustom
                Ensure                = 'Present'
                SubscriptionId        = $this.SubscriptionId
                Credential            = $this.Credential
                ApplicationId         = $this.ApplicationId
                TenantId              = $this.TenantId
                ApplicationSecret     = $this.ApplicationSecret
                CertificateThumbprint = $this.CertificateThumbprint
                ManagedIdentity       = $this.ManagedIdentity
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

        Write-Verbose -Message "Setting configuration of Azure Role Definition with Name {$($this.CustomRoleName)}"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $currentInstance = $this.Get().ToHashtable()

        # Role definition should exist but does not
        if ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Creating new Azure Role Definition {$($this.CustomRoleName)}"

            # Create role definition through the REST API if description is empty
            if ([System.String]::IsNullOrWhiteSpace($this.Description))
            {
                $this.PutRoleDefinition([System.Guid]::NewGuid().ToString())
                return
            }

            $roleObject = @{
                Name             = $this.CustomRoleName
                Description      = $this.Description
                Actions          = $this.Actions
                NotActions       = $this.NotActions
                DataActions      = $this.DataActions
                NotDataActions   = $this.NotDataActions
                AssignableScopes = $this.AssignableScopes
            }
            New-AzRoleDefinition -Role $roleObject
        }
        # Role definition exists and will be configured to desired state
        elseif ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Updating existing Azure Role Definition {$($this.CustomRoleName)}"

            if ([System.String]::IsNullOrWhiteSpace($this.Description))
            {
                $this.PutRoleDefinition($currentInstance.Id)
                return
            }

            $roleObject = @{
                Id               = $currentInstance.Id
                Name             = $this.CustomRoleName
                Description      = $this.Description
                Actions          = $this.Actions
                NotActions       = $this.NotActions
                DataActions      = $this.DataActions
                NotDataActions   = $this.NotDataActions
                AssignableScopes = $this.AssignableScopes
            }
            Set-AzRoleDefinition -Role $roleObject
        }
        # Role definition exists but should not
        elseif ($this.Ensure -eq 'Absent' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Removing Azure Role Definition {$($this.CustomRoleName)}"
            Remove-AzRoleDefinition -Id $currentInstance.Id -Force
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

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Export')

        $dscContent = ''
        $i = 1
        try
        {
            $this.ResourceCache['ExportMode'] = $true
            [array] $this.ResourceCache['exportedInstances'] = Get-AzRoleDefinition -Custom -ErrorAction Stop

            if ($this.ResourceCache['exportedInstances'].Length -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }
            foreach ($role in $this.ResourceCache['exportedInstances'])
            {
                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }

                Write-M365DSCHost -Message "    |---[$i/$($this.ResourceCache['exportedInstances'].Count)] $($role.Name)" -DeferWrite
                $Params = @{
                    CustomRoleName        = $role.Name
                    Id                    = $role.Id
                    SubscriptionId        = $this.SubscriptionId
                    Credential            = $this.Credential
                    ApplicationId         = $this.ApplicationId
                    TenantId              = $this.TenantId
                    ApplicationSecret     = $this.ApplicationSecret
                    CertificateThumbprint = $this.CertificateThumbprint
                    ManagedIdentity       = $this.ManagedIdentity
                    AccessTokens          = $this.AccessTokens
                }
                $this.ExportedInstance = $role
                $Results = $this.GetForExport($Params)

                if ($Results.Ensure -eq 'Present')
                {
                    $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                        -ConnectionMode $ConnectionMode `
                        -ModulePath $this.GetModulePath() `
                        -Results $Results `
                        -Credential $this.Credential
                    $dscContent += $currentDSCBlock
                    Save-M365DSCPartialExport -Content $currentDSCBlock `
                        -FileName $Global:PartialExportFileName
                }

                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
                $i++
            }
            return $dscContent
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

    hidden [void] PutRoleDefinition([System.String] $RoleDefinitionId)
    {
        $body = @{
            properties = @{
                roleName         = $this.CustomRoleName
                description      = ''
                type             = 'CustomRole'
                permissions      = @(
                    @{
                        actions        = @($this.Actions | Where-Object -FilterScript { $_ })
                        notActions     = @($this.NotActions | Where-Object -FilterScript { $_ })
                        dataActions    = @($this.DataActions | Where-Object -FilterScript { $_ })
                        notDataActions = @($this.NotDataActions | Where-Object -FilterScript { $_ })
                    }
                )
                assignableScopes = @($this.AssignableScopes)
            }
        } | ConvertTo-Json -Depth 6

        $path = "$($this.AssignableScopes[0])/providers/Microsoft.Authorization/roleDefinitions/$($RoleDefinitionId)?api-version=2022-04-01"
        $response = Invoke-AzRestMethod -Method PUT -Path $path -Payload $body
        if ($response.StatusCode -ge 300)
        {
            throw "Saving the role definition {$($this.CustomRoleName)} failed with status $($response.StatusCode): $($response.Content)"
        }
    }

    hidden [AzureRoleDefinition] AsResult([System.Object] $Values)
    {
        if ($Values -is [AzureRoleDefinition])
        {
            return $Values
        }

        $result = [AzureRoleDefinition]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
