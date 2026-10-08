using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class DefenderRoleDefinition : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The display name for the role definition.')]
    [System.String] $DisplayName

    [DscProperty()]
    [System.ComponentModel.Description('The id of the role definition.')]
    [System.String] $Id

    [DscProperty()]
    [System.ComponentModel.Description('The description of the role definition.')]
    [System.String] $Description

    [DscProperty()]
    [System.ComponentModel.Description('List of permissions included in the role.')]
    [MSFT_DefenderRoleDefinitionRolePermissions[]] $RolePermissions

    [DscProperty()]
    [System.ComponentModel.Description('Present ensures the instance exists, absent ensures it is removed.')]
    [ValidateSet('Absent', 'Present')]
    [System.String] $Ensure

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
    [System.String] $Filter

    [DefenderRoleDefinition] Get()
    {
        $ApplicationSecret = $null
        if ($this.RequiresPowerShellCore())
        {
            $remote = [DefenderRoleDefinition]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of the Defender Role Definition with Id {$($this.Id)} and DisplayName {$($this.DisplayName)}"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.DisplayName -ne $this.DisplayName)
            {
                $null = $this.Connect('MicrosoftGraph')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullResult = $this.GetBoundParameters()
                $nullResult.Ensure = 'Absent'

                if (-not [System.String]::IsNullOrEmpty($this.Id))
                {
                    $uri = "/beta/roleManagement/defender/roleDefinitions/$($this.Id)"
                    $response = Invoke-M365DSCGraphRequest -Method GET -Uri $uri -ErrorAction Stop
                    [array]$definition = $response.value
                }
                if ($null -eq $definition -or $definition.Length -eq 0)
                {
                    Write-Verbose -Message "No Defender Role Definition {$($this.Id)} was found by Identity. Trying to retrieve by DisplayName"
                    $uri = "/beta/roleManagement/defender/roleDefinitions/?`$filter=displayName eq '$($this.DisplayName)'"
                    $response = Invoke-M365DSCGraphRequest -Method GET -Uri $uri -ErrorAction SilentlyContinue
                    [Array]$definition = $response.value
                }

                if ($null -ne $definition -and $definition.Length -gt 1)
                {
                    throw "Multiple definitions with display name {$($this.DisplayName)} were found. Please ensure only one instance exists."
                }
                elseif ($null -eq $definition -or $definition.Length -eq 0)
                {
                    Write-Verbose -Message "No Defender Role Definition {$($this.DisplayName)} was found by Display Name. Instance doesn't exist."
                    return $this.AsResult($nullResult)
                }
            }
            else
            {
                $definition = $this.ExportedInstance
            }

            $rolePermissionsValue = $null
            if ($definition.RolePermissions.Length -gt 0)
            {
                $rolePermissionsValue = @(
                    @{
                            allowedResourceActions = $definition.RolePermissions.allowedResourceActions
                    }
                )
            }

            return $this.AsResult(@{
                Id                    = $definition.Id
                DisplayName           = $definition.DisplayName
                Description           = $definition.Description
                RolePermissions       = $rolePermissionsValue
                Ensure                = 'Present'
                Credential            = $this.Credential
                ApplicationId         = $this.ApplicationId
                ApplicationSecret     = $ApplicationSecret
                TenantId              = $this.TenantId
                CertificateThumbprint = $this.CertificateThumbprint
                CertificatePath       = $this.CertificatePath
                CertificatePassword   = $this.CertificatePassword
                ManagedIdentity       = $this.ManagedIdentity
                AccessTokens          = $this.AccessTokens
            })
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

        Write-Verbose -Message "Setting configuration of the Defender Role Definition with DisplayName {$($this.DisplayName)}"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $currentDefinition = $this.Get().ToHashtable()
        if ($this.Ensure -eq 'Present' -and $currentDefinition.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Creating new Defender Role Definition {$($this.DisplayName)}"

            $newParams = @{
                displayName = $this.DisplayName
                description = $this.Description
                rolePermissions = @(
                    @{
                        allowedResourceActions = [Array]($this.RolePermissions.allowedResourceActions)
                    }
                )
            }

            $uri = "/beta/roleManagement/defender/roleDefinitions"
            $response = Invoke-M365DSCGraphRequest -Method POST -Uri $uri -Body $newParams
        }
        elseif ($this.Ensure -eq 'Present' -and $currentDefinition.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Updating existing Defender Role Definition {$($this.DisplayName)}"

            $updateParams = @{
                displayName = $this.DisplayName
                description = $this.Description
                rolePermissions = @(
                    @{
                        allowedResourceActions = [Array]($this.RolePermissions.allowedResourceActions)
                    }
                )
            }

            $uri = "/beta/roleManagement/defender/roleDefinitions/$($currentDefinition.Id)"
            $response = Invoke-M365DSCGraphRequest -Method PATCH -Uri $uri -Body $updateParams
        }
        elseif ($this.Ensure -eq 'Absent' -and $currentDefinition.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Removing Defender Role Definition {$($this.DisplayName)}"
            $uri = "/beta/roleManagement/defender/roleDefinitions/$($currentDefinition.Id)"
            $response = Invoke-M365DSCGraphRequest -Method DELETE -Uri $uri
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

        #Ensure the proper dependencies are installed in the current environment
        Confirm-M365DSCDependencies

        #region Telemetry
        $this.AddTelemetry('Export')
        #endregion

        try
        {
            $uri = "/beta/roleManagement/defender/roleDefinitions"
            [array]$roleDefinitions = (Invoke-M365DSCGraphRequest -Method GET -Uri $uri -ErrorAction Stop).value

            $i = 1
            $dscContent = [System.Text.StringBuilder]::new()
            if ($roleDefinitions.Length -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }
            foreach ($role in $roleDefinitions)
            {
                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }

                Write-M365DSCHost -Message "    |---[$i/$($roleDefinitions.Count)] $($role.displayName)" -DeferWrite
                $params = @{
                    Id                    = $role.id
                    DisplayName           = $role.displayName
                    Ensure                = 'Present'
                    Credential            = $this.Credential
                    ApplicationID         = $this.ApplicationId
                    TenantId              = $this.TenantId
                    CertificateThumbprint = $this.CertificateThumbprint
                    CertificatePath       = $this.CertificatePath
                    CertificatePassword   = $this.CertificatePassword
                    ManagedIdentity       = $this.ManagedIdentity
                    AccessTokens          = $this.AccessTokens
                }

                $this.ExportedInstance = $role
                $Results = $this.GetForExport($Params)

                if ($Results.RolePermissions)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString -ComplexObject $Results.RolePermissions `
                                                                                 -CIMInstanceName 'DefenderRoleDefinitionRolePermissions'
                    if ($complexTypeStringResult)
                    {
                        $Results.RolePermissions = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('RolePermissions') | Out-Null
                    }
                }

                $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                    -ConnectionMode $ConnectionMode `
                    -ModulePath $this.GetModulePath() `
                    -Results $Results `
                    -Credential $this.Credential `
                    -NoEscape @('RolePermissions')
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

    hidden [DefenderRoleDefinition] AsResult([System.Object] $Values)
    {
        if ($Values -is [DefenderRoleDefinition])
        {
            return $Values
        }

        $result = [DefenderRoleDefinition]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}

class MSFT_DefenderRoleDefinitionRolePermissions
{
    [DscProperty()]
    [System.ComponentModel.Description('Set of tasks that can be performed on a resource.')]
    [System.String[]] $allowedResourceActions
}
