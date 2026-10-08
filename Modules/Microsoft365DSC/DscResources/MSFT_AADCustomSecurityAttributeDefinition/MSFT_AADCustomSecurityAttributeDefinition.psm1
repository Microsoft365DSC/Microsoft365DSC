using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class AADCustomSecurityAttributeDefinition : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('Name of the custom security attribute. Must be unique within an attribute set. Can be up to 32 characters long and include Unicode characters. Can''t contain spaces or special characters. Can''t be changed later. Case sensitive.')]
    [System.String] $Name

    [DscProperty(Key)]
    [System.ComponentModel.Description('Name of the attribute set. Case sensitive.')]
    [System.String] $AttributeSet

    [DscProperty()]
    [System.ComponentModel.Description('The allowed values of the attribute definition.')]
    [MSFT_CustomSecurityAttributeAllowedValue[]] $AllowedValues

    [DscProperty()]
    [System.ComponentModel.Description('Unique identifier of the Attribute Definition.')]
    [System.String] $Id

    [DscProperty()]
    [System.ComponentModel.Description('Description of the custom security attribute. Can be up to 128 characters long and include Unicode characters. Can''t contain spaces or special characters. Can be changed later. ')]
    [System.String] $Description

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether multiple values can be assigned to the custom security attribute. Can''t be changed later. If type is set to Boolean, isCollection can''t be set to true.')]
    [System.Nullable[System.Boolean]] $IsCollection

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether custom security attribute values are indexed for searching on objects that are assigned attribute values. Can''t be changed later.')]
    [System.Nullable[System.Boolean]] $IsSearchable

    [DscProperty()]
    [System.ComponentModel.Description('Specifies whether the custom security attribute is active or deactivated. Acceptable values are Available and Deprecated. Can be changed later.')]
    [ValidateSet('Available', 'Deprecated')]
    [System.String] $Status

    [DscProperty()]
    [System.ComponentModel.Description('Data type for the custom security attribute values. Supported types are: Boolean, Integer, and String. Can''t be changed later.')]
    [System.String] $Type

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether only predefined values can be assigned to the custom security attribute. If set to false, free-form values are allowed. Can later be changed from true to false, but can''t be changed from false to true. If type is set to Boolean, usePreDefinedValuesOnly can''t be set to true.')]
    [System.Nullable[System.Boolean]] $UsePreDefinedValuesOnly

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
    [System.ComponentModel.Description('Secret of the Azure Active Directory tenant used for authentication.')]
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

    [AADCustomSecurityAttributeDefinition] Get()
    {
        $instance = $null
        if ($this.RequiresPowerShellCore())
        {
            $remote = [AADCustomSecurityAttributeDefinition]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of AzureAD Custom Security Attribute Definition for {$($this.Name)}"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.Name -ne $this.Name)
            {
                $null = $this.Connect('MicrosoftGraph')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullResult = $this.GetBoundParameters()
                $nullResult.Ensure = 'Absent'

                if (-not [System.String]::IsNullOrEmpty($this.Id))
                {
                    $instance = Get-MgBetaDirectoryCustomSecurityAttributeDefinition -CustomSecurityAttributeDefinitionId $this.Id `
                        -ExpandProperty 'allowedValues' `
                        -ErrorAction SilentlyContinue
                }
                if ($null -eq $instance)
                {
                    $instance = Get-MgBetaDirectoryCustomSecurityAttributeDefinition -Filter "attributeSet eq '$($this.AttributeSet -replace "'", "''")' and name eq '$($this.Name -replace "'", "''")'" `
                        -ExpandProperty 'allowedValues' `
                        -ErrorAction SilentlyContinue
                }
                if ($null -eq $instance)
                {
                    return $this.AsResult($nullResult)
                }
            }
            else
            {
                $instance = $this.ExportedInstance
            }

            $complexAllowedValues = @()
            foreach ($allowedValue in $instance.AllowedValues)
            {
                $complexAllowedValues += [ordered]@{
                    ValueId  = $allowedValue.Id
                    IsActive = $allowedValue.IsActive
                }
            }

            $results = @{
                Name                    = $instance.Name
                AllowedValues           = $complexAllowedValues
                AttributeSet            = $instance.AttributeSet
                Id                      = $instance.Id
                Description             = $instance.Description
                IsCollection            = $instance.IsCollection
                IsSearchable            = $instance.IsSearchable
                Status                  = $instance.Status
                Type                    = $instance.Type
                UsePreDefinedValuesOnly = $instance.UsePreDefinedValuesOnly
                Ensure                  = 'Present'
                Credential              = $this.Credential
                ApplicationId           = $this.ApplicationId
                TenantId                = $this.TenantId
                ApplicationSecret       = $this.ApplicationSecret
                CertificateThumbprint   = $this.CertificateThumbprint
                CertificatePath         = $this.CertificatePath
                CertificatePassword     = $this.CertificatePassword
                ManagedIdentity         = $this.ManagedIdentity
                AccessTokens            = $this.AccessTokens
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

        Write-Verbose -Message "Setting configuration of AzureAD Custom Security Attribute Definition for {$($this.Name)}"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $currentInstance = $this.Get().ToHashtable()
        $setParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()
        $setParameters.Remove('AllowedValues') | Out-Null

        # CREATE
        if ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
        {
            $setParameters.Remove('Id') | Out-Null
            if ($this.AllowedValues.Count -gt 0)
            {
                $allowedValueEntries = @()
                foreach ($allowedValue in $this.AllowedValues)
                {
                    $allowedValueEntries += @{
                        id       = $allowedValue.ValueId
                        isActive = [System.Boolean]$allowedValue.IsActive
                    }
                }
                $setParameters.AllowedValues = $allowedValueEntries
            }
            Write-Verbose -Message "Creating new Atribute Definition {$($this.Name)}"
            $null = New-MgBetaDirectoryCustomSecurityAttributeDefinition -BodyParameter $setParameters
        }
        # UPDATE
        elseif ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Updating Atribute Definition {$($this.Name)}"
            $setParameters.Remove('Id') | Out-Null
            $setParameters.Remove('AttributeSet') | Out-Null
            $setParameters.Remove('IsCollection') | Out-Null
            $setParameters.Remove('IsSearchable') | Out-Null
            $setParameters.Remove('Name') | Out-Null
            $setParameters.Remove('Type') | Out-Null
            if ($setParameters.ContainsKey('UsePreDefinedValuesOnly') -and $setParameters.UsePreDefinedValuesOnly -eq $currentInstance.UsePreDefinedValuesOnly)
            {
                $setParameters.Remove('UsePreDefinedValuesOnly') | Out-Null
            }
            Update-MgBetaDirectoryCustomSecurityAttributeDefinition -CustomSecurityAttributeDefinitionId $currentInstance.Id -BodyParameter $setParameters

            # Allowed values cannot be removed, therefore we only need to add new ones or update existing ones
            foreach ($allowedValue in $this.AllowedValues)
            {
                $existingAllowedValue = $currentInstance.AllowedValues | Where-Object -Property ValueId -EQ $allowedValue.ValueId
                if ($null -eq $existingAllowedValue)
                {
                    # Add new allowed value
                    New-MgBetaDirectoryCustomSecurityAttributeDefinitionAllowedValue `
                        -CustomSecurityAttributeDefinitionId $currentInstance.Id `
                        -Id $allowedValue.ValueId `
                        -IsActive:$allowedValue.IsActive
                }
                elseif ($existingAllowedValue.IsActive -ne $allowedValue.IsActive)
                {
                    # Update existing allowed value
                    Update-MgBetaDirectoryCustomSecurityAttributeDefinitionAllowedValue `
                        -CustomSecurityAttributeDefinitionId $currentInstance.Id `
                        -AllowedValueId $allowedValue.ValueId `
                        -IsActive:$allowedValue.IsActive
                }
            }
        }
        # REMOVE
        elseif ($this.Ensure -eq 'Absent' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Removing Atribute Definition {$($this.Name)}. Setting its status to 'Deprecated'"
            Update-MgBetaDirectoryCustomSecurityAttributeDefinition -CustomSecurityAttributeDefinitionId $currentInstance.Id `
                -Status 'Deprecated'
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
            [array] $exportedInstances = Get-MgBetaDirectoryCustomSecurityAttributeDefinition `
                -ExpandProperty 'allowedValues' `
                -ErrorAction Stop

            $i = 1
            $dscContent = [System.Text.StringBuilder]::new()
            if ($exportedInstances.Length -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }
            foreach ($config in $exportedInstances)
            {
                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }

                $displayedKey = $config.Id
                Write-M365DSCHost -Message "    |---[$i/$($exportedInstances.Count)] $displayedKey" -DeferWrite
                $params = @{
                    Id                    = $config.Id
                    Name                  = $config.Name
                    AttributeSet          = $config.AttributeSet
                    Credential            = $this.Credential
                    ApplicationId         = $this.ApplicationId
                    TenantId              = $this.TenantId
                    ApplicationSecret     = $this.ApplicationSecret
                    CertificateThumbprint = $this.CertificateThumbprint
                    CertificatePath       = $this.CertificatePath
                    CertificatePassword   = $this.CertificatePassword
                    ManagedIdentity       = $this.ManagedIdentity
                    AccessTokens          = $this.AccessTokens
                }

                $this.ExportedInstance = $config
                $Results = $this.GetForExport($Params)
                $rawResults = $Results.Clone()
                if ($null -ne $Results.AllowedValues)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.AllowedValues `
                        -CIMInstanceName 'CustomSecurityAttributeAllowedValue'

                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.AllowedValues = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('AllowedValues') | Out-Null
                    }
                }

                $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                    -ConnectionMode $ConnectionMode `
                    -ModulePath $this.GetModulePath() `
                    -Results $Results `
                    -Credential $this.Credential `
                    -NoEscape @('AllowedValues') `
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

    [System.Collections.Hashtable] GetCompareParameters()
    {
        return @{
            IncludedProperties = @('ValueId', 'IsActive')
            PostProcessing     = {
                param($DesiredValues, $CurrentValues, $ValuesToCheck, $ignore)
                if ($DesiredValues.Ensure -eq 'Absent' -and $CurrentValues.Status -eq 'Deprecated')
                {
                    $CurrentValues.Ensure = 'Absent'
                }

                # Values cannot be removed from AllowedValues
                # Therefore, we add the missing values from CurrentValues to DesiredValues for comparison
                if ($DesiredValues.ContainsKey('AllowedValues'))
                {
                    foreach ($currentValue in $CurrentValues.AllowedValues)
                    {
                        $matchingValue = $DesiredValues.AllowedValues | Where-Object { $_.ValueId -eq $currentValue.ValueId }
                        if ($null -eq $matchingValue)
                        {
                            # AllowedValues is either an array of CIM instances or an array of hashtables
                            # CIM instances is when using Test-DscConfiguration (compiled configuration) and hashtables when creating a report, using values from ConvertTo-DscObject
                            if ($DesiredValues.AllowedValues -is [CimInstance[]])
                            {
                                $DesiredValues.AllowedValues += [MSFT_CustomSecurityAttributeAllowedValue] @{
                                    IsActive = $currentValue.IsActive
                                    ValueId  = $currentValue.ValueId
                                }
                            }
                            else
                            {
                                $DesiredValues.AllowedValues = @($DesiredValues.AllowedValues)
                                $DesiredValues.AllowedValues += @{
                                    CIMInstance = 'MSFT_CustomSecurityAttributeAllowedValue'
                                    IsActive    = $currentValue.IsActive
                                    ValueId     = $currentValue.ValueId
                                }
                            }
                        }
                    }

                    if ($DesiredValues.AllowedValues -is [CimInstance[]])
                    {
                        $DesiredValues.AllowedValues = [CimInstance[]]$DesiredValues.AllowedValues
                    }
                }
                return [System.Tuple[Hashtable, Hashtable, Hashtable]]::new($DesiredValues, $CurrentValues, $ValuesToCheck)
            }
        }
    }

    hidden [AADCustomSecurityAttributeDefinition] AsResult([System.Object] $Values)
    {
        if ($Values -is [AADCustomSecurityAttributeDefinition])
        {
            return $Values
        }

        $result = [AADCustomSecurityAttributeDefinition]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}

class MSFT_CustomSecurityAttributeAllowedValue
{
    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('The id of the allowed value. Must be unique in the set of allowed values.')]
    [System.String] $ValueId

    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('If the allowed value is active.')]
    [System.Nullable[System.Boolean]] $IsActive
}
