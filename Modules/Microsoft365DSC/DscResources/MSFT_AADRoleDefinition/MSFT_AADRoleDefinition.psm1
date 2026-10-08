using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class AADRoleDefinition : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('Specifies a display name for the role definition.')]
    [System.String] $DisplayName

    [DscProperty()]
    [System.ComponentModel.Description('Specifies Id for the role definition.')]
    [System.String] $Id

    [DscProperty()]
    [System.ComponentModel.Description('Specifies a description for the role definition.')]
    [System.String] $Description

    [DscProperty()]
    [System.ComponentModel.Description('Specifies the resource scopes for the role definition.')]
    [System.String[]] $ResourceScopes

    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('Specifies whether the role definition is enabled.')]
    [System.Nullable[System.Boolean]] $IsEnabled

    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('Specifies permissions for the role definition.')]
    [System.String[]] $RolePermissions

    [DscProperty()]
    [System.ComponentModel.Description('Specifies template id for the role definition.')]
    [System.String] $TemplateId

    [DscProperty()]
    [System.ComponentModel.Description('Specifies version for the role definition.')]
    [System.String] $Version

    [DscProperty()]
    [System.ComponentModel.Description('Specify if the Azure AD Role definition should exist or not.')]
    [ValidateSet('Present', 'Absent')]
    [System.String] $Ensure

    [DscProperty()]
    [System.ComponentModel.Description('Credentials of the Azure AD Admin')]
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

    [AADRoleDefinition] Get()
    {
        $AADRoleDefinition = $null
        if ($this.RequiresPowerShellCore())
        {
            $remote = [AADRoleDefinition]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of Azure AD Role Definition with DisplayName {$($this.DisplayName)}"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.DisplayName -ne $this.DisplayName)
            {
                $null = $this.Connect('MicrosoftGraph')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullReturn = $this.GetBoundParameters()
                $nullReturn.Ensure = 'Absent'

                try
                {
                    if (($null -ne $this.Id) -and ($this.Id -ne ''))
                    {
                        $AADRoleDefinition = Get-MgBetaRoleManagementDirectoryRoleDefinition -Filter "Id eq '$($this.Id)'"
                    }
                }
                catch
                {
                    Write-Verbose -Message "Could not retrieve AAD roledefinition by Id: {$($this.Id)}"
                }
                if ($null -eq $AADRoleDefinition)
                {
                    $AADRoleDefinition = Get-MgBetaRoleManagementDirectoryRoleDefinition -Filter "DisplayName eq '$($this.DisplayName -replace "'", "''")'"
                }
                if ($null -eq $AADRoleDefinition)
                {
                    return $this.AsResult($nullReturn)
                }
            }
            else
            {
                $AADRoleDefinition = $this.ExportedInstance
            }

            $result = @{
                Id                    = $AADRoleDefinition.Id
                DisplayName           = $AADRoleDefinition.DisplayName
                Description           = $AADRoleDefinition.Description
                ResourceScopes        = $AADRoleDefinition.ResourceScopes
                IsEnabled             = $AADRoleDefinition.IsEnabled
                RolePermissions       = Get-M365DSCArrayFromProperty -PropertyValue $AADRoleDefinition.RolePermissions.AllowedResourceActions -ElementType ([System.String])
                TemplateId            = $AADRoleDefinition.TemplateId
                Version               = $AADRoleDefinition.Version
                Ensure                = 'Present'
                Credential            = $this.Credential
                ApplicationId         = $this.ApplicationId
                ApplicationSecret     = $this.ApplicationSecret
                TenantId              = $this.TenantId
                CertificateThumbprint = $this.CertificateThumbprint
                CertificatePath       = $this.CertificatePath
                CertificatePassword   = $this.CertificatePassword
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

        Write-Verbose -Message 'Setting configuration of Azure AD role definition'

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $currentAADRoleDef = $this.Get().ToHashtable()
        $currentParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()
        $currentParameters.Remove('RolePermissions') | Out-Null
        $currentParameters.Remove('ResourceScopes') | Out-Null

        $rolePermissionsObj = @()
        $rolePermissionsObj += @{'allowedResourceActions' = $this.rolePermissions }
        $resourceScopesObj = @()
        $resourceScopesObj += $this.ResourceScopes

        $currentParameters.Add('RolePermissions', $rolePermissionsObj) | Out-Null
        if ($this.ResourceScopes.Length -gt 0)
        {
            $currentParameters.Add('ResourceScopes', $resourceScopesObj) | Out-Null
        }
        $currentParameters = Rename-M365DSCCimInstanceParameter -Properties $currentParameters

        # Role definition should exist but it doesn't
        if ($this.Ensure -eq 'Present' -and $currentAADRoleDef.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Creating New AzureAD role defition {$($this.DisplayName)} with parameters:"
            Write-Verbose -Message (Convert-M365DscHashtableToString -Hashtable $currentParameters)
            $currentParameters.Remove('Id') | Out-Null
            New-MgBetaRoleManagementDirectoryRoleDefinition -BodyParameter $currentParameters
        }
        # Role definition should exist and will be configured to desired state
        if ($this.Ensure -eq 'Present' -and $currentAADRoleDef.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Updating existing AzureAD role definition {$($this.DisplayName)}"
            $currentParameters.Remove('Id') | Out-Null
            Update-MgBetaRoleManagementDirectoryRoleDefinition -UnifiedRoleDefinitionId $currentAADRoleDef.Id -BodyParameter $currentParameters
        }
        # Role definition exists but should not
        elseif ($this.Ensure -eq 'Absent' -and $currentAADRoleDef.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Removing AzureAD role definition {$($this.DisplayName)}"
            Remove-MgBetaRoleManagementDirectoryRoleDefinition -UnifiedRoleDefinitionId $currentAADRoleDef.Id
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

        $dscContent = [System.Text.StringBuilder]::new()
        $i = 1
        try
        {
            [array] $exportedInstances = Get-MgBetaRoleManagementDirectoryRoleDefinition -Filter $this.Filter -All -ErrorAction Stop
            if ($exportedInstances.Length -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }
            foreach ($AADRoleDefinition in $exportedInstances)
            {
                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }

                Write-M365DSCHost -Message "    |---[$i/$($exportedInstances.Count)] $($AADRoleDefinition.DisplayName)" -DeferWrite
                $Params = @{
                    Credential            = $this.Credential
                    ApplicationId         = $this.ApplicationId
                    ApplicationSecret     = $this.ApplicationSecret
                    TenantId              = $this.TenantId
                    CertificateThumbprint = $this.CertificateThumbprint
                    CertificatePath       = $this.CertificatePath
                    CertificatePassword   = $this.CertificatePassword
                    ManagedIdentity       = $this.ManagedIdentity
                    DisplayName           = $AADRoleDefinition.DisplayName
                    Id                    = $AADRoleDefinition.Id
                    IsEnabled             = $true
                    RolePermissions       = @('temp')
                    AccessTokens          = $this.AccessTokens
                }
                $this.ExportedInstance = $AADRoleDefinition
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
            ExcludedProperties = @('TemplateId')
        }
    }

    hidden [AADRoleDefinition] AsResult([System.Object] $Values)
    {
        if ($Values -is [AADRoleDefinition])
        {
            return $Values
        }

        $result = [AADRoleDefinition]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
