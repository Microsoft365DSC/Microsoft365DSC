<#
.SYNOPSIS
    Converts the first character of a string to uppercase.

.DESCRIPTION
    Returns a new string where the first character is converted to uppercase and the remaining characters are unchanged.

.PARAMETER Value
    Specifies the input string to transform.

.OUTPUTS
    System.String
#>
function Get-StringFirstCharacterToUpper
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Value
    )

    return $Value.Substring(0, 1).ToUpper() + $Value.Substring(1, $Value.Length - 1)
}

<#
.SYNOPSIS
    Converts the first character of a string to lowercase.

.DESCRIPTION
    Returns a new string where the first character is converted to lowercase and the remaining characters are unchanged.

.PARAMETER Value
    Specifies the input string to transform.

.OUTPUTS
    System.String
#>
function Get-StringFirstCharacterToLower
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Value
    )

    return $Value.Substring(0, 1).ToLower() + $Value.Substring(1, $Value.Length - 1)
}

<#
.SYNOPSIS
    Renames complex object parameter keys for DSC and API compatibility.

.DESCRIPTION
    Recursively processes hashtables, CIM instances, and object arrays, normalizes key casing, and applies explicit key mappings such as converting odataType to @odata.type.

.PARAMETER Properties
    Specifies the source properties to process.

.PARAMETER KeyMapping
    Specifies key name mappings to apply during conversion.

.OUTPUTS
    System.Collections.Hashtable
    System.Object[]
#>
function Rename-M365DSCCimInstanceParameter
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable], [System.Object[]])]
    param(
        [Parameter(Mandatory = $true)]
        $Properties,

        [Parameter(Mandatory = $false)]
        [System.Collections.Hashtable]
        $KeyMapping = @{ 'odataType' = '@odata.type' }
    )

    $result = $Properties
    $type = $Properties.GetType().FullName
    #region Array
    if ($type -like '*[[\]]')
    {
        $values = @()
        foreach ($item in $Properties)
        {
            $itemType = $item.GetType().FullName
            if ($itemType -like '*Hashtable*' -or $itemType -like '*CimInstance*' -or $itemType -like '*Object*' -or $itemType -like "*MSFT_*")
            {
                try
                {
                    $values += Rename-M365DSCCimInstanceParameter -Properties $item -KeyMapping $KeyMapping
                }
                catch
                {
                    Write-Verbose -Message "Error getting values for item {$item}"
                }
            }
            else
            {
                $values += $item
            }
        }
        $result = $values

        return ,$result
    }
    #endregion

    #region Single
    if ($type -like '*Hashtable')
    {
        $result = [System.Collections.Specialized.CollectionsUtil]::CreateCaseInsensitiveHashtable([Hashtable]$Properties)
    }

    if ($type -like '*CimInstance*' -or $type -like '*Hashtable*' -or $type -like '*Object*' -or $type -like "*MSFT_*")
    {
        $hashProperties = Get-M365DSCDRGComplexTypeToHashtable -ComplexObject $result
        $keys = ($hashProperties.Clone()).Keys

        foreach ($key in $keys)
        {
            $keyName = if ($key -cmatch '^[A-Z0-9]+$')
            {
                $key.ToLower()
            }
            elseif ($key -cmatch '^([A-Z]+)(?=[A-Z][a-z])')
            {
                $Matches[1].ToLower() + $key.Substring($Matches[1].Length)
            }
            else
            {
                $key.Substring(0, 1).ToLower() + $key.Substring(1, $key.Length - 1)
            }
            if ($key -in $KeyMapping.Keys)
            {
                $keyName = $KeyMapping.$key
            }

            $property = $hashProperties.$key

            if ($null -ne $property)
            {
                $hashProperties.Remove($key)
                try
                {
                    $subValue = Rename-M365DSCCimInstanceParameter $property -KeyMapping $KeyMapping
                    if ($null -ne $subValue)
                    {
                        $hashProperties.Add($keyName, $subValue)
                    }
                }
                catch
                {
                    Write-Verbose -Message "Error adding $property"
                }
            }
        }
        $result = $hashProperties
    }

    return $result
    #endregion
}

<#
.SYNOPSIS
    Converts a complex object to a hashtable representation.

.DESCRIPTION
    Uses Microsoft365DSC conversion helpers to transform CIM instances or arrays of CIM instances into hashtables.

.PARAMETER ComplexObject
    Specifies the complex object or array of complex objects to convert.

.OUTPUTS
    System.Collections.Hashtable
    System.Collections.Hashtable[]
#>
function Get-M365DSCDRGComplexTypeToHashtable
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable], [System.Collections.Hashtable[]])]
    param(
        [Parameter()]
        $ComplexObject
    )

    Initialize-M365DSCDllLoader -ErrorAction Stop

    if ($null -eq $ComplexObject)
    {
        return $null
    }

    if ($ComplexObject -is [array])
    {
        return [Microsoft365DSC.Converter.ComplexObjectConverter]::ToHashtableArray($ComplexObject)
    }

    return [Microsoft365DSC.Converter.ComplexObjectConverter]::ToHashtable($ComplexObject)
}

<#
    Use ComplexTypeMapping to overwrite the type of nested CIM
    Example
    $complexMapping=@(
                    @{
                        Name="ApprovalStages"
                        CimInstanceName="MSFT_MicrosoftGraphapprovalstage1"
                        IsRequired=$false
                    }
                    @{
                        Name="PrimaryApprovers"
                        CimInstanceName="MicrosoftGraphuserset"
                        IsRequired=$false
                    }
                    @{
                        Name="EscalationApprovers"
                        CimInstanceName="MicrosoftGraphuserset"
                        IsRequired=$false
                    }
                )
    With
    Name: the name of the parameter to be overwritten
    CimInstanceName: The type of the CIM instance (can include or not the prefix MSFT_)
    IsRequired: If isRequired equals true, an empty hashtable or array will be returned. Some of the Graph parameters are required even though they are empty
#>

<#
.SYNOPSIS
    Converts a complex object to a DSC string representation.

.DESCRIPTION
    Converts CIM instances or hashtables to the DSC CIM instance string format, with optional nested type mapping, whitespace control, and array handling.

.PARAMETER ComplexObject
    Specifies the complex object or array to convert.

.PARAMETER CIMInstanceName
    Specifies the CIM instance class name used in the generated DSC representation.

.PARAMETER ComplexTypeMapping
    Specifies optional nested type mappings for specific properties.

.PARAMETER Whitespace
    Specifies the whitespace prefix used when rendering output.

.PARAMETER IndentLevel
    Specifies the indentation level used when rendering output.

.PARAMETER IsArray
    Indicates that the input should be rendered as an array of instances.

.OUTPUTS
    System.String
    System.String[]
#>
function Get-M365DSCDRGComplexTypeToString
{
    [CmdletBinding()]
    [OutputType([System.String], [System.String[]])]
    param(
        [Parameter()]
        $ComplexObject,

        [Parameter(Mandatory = $true)]
        [System.String]
        $CIMInstanceName,

        [Parameter()]
        [Array]
        $ComplexTypeMapping,

        [Parameter()]
        [System.String]
        $Whitespace = '',

        [Parameter()]
        [System.uint32]
        $IndentLevel = 3,

        [Parameter()]
        [switch]
        $IsArray
    )

    if ($null -eq $ComplexObject)
    {
        return $null
    }

    Initialize-M365DSCDllLoader -ErrorAction Stop

    $typeMappingList = [System.Collections.Generic.List[Microsoft365DSC.Converter.ComplexTypeMapping]]::new()
    if ($PSBoundParameters.ContainsKey('ComplexTypeMapping') -and $ComplexTypeMapping -ne $null)
    {
        foreach ($mapping in $ComplexTypeMapping)
        {
            $typeMappingList.Add($mapping)
        }
    }

    $returnValue = [Microsoft365DSC.Converter.ComplexObjectConverter]::ToDscString($ComplexObject, $CIMInstanceName, $typeMappingList, $Whitespace, $IndentLevel, $IsArray)
    if ($returnValue -is [System.Array])
    {
        return ,$returnValue
    }

    return $returnValue
}

<#
.SYNOPSIS
    Replace every character that would need escaping inside a DSC instance name with an underscore.

.DESCRIPTION
    This function replaces the characters that cannot appear unescaped in a DSC instance name.
    The function replaces the following characters:
        - <>:"/\|?*'[]()`$ and the space
        - 0x2019, 0x201C, 0x201D, 0x201E and 0x201F

.PARAMETER String
    The string to be updated.

.OUTPUTS
    System.String

.EXAMPLE
    PS> Remove-M365DSCSpecialCharacters -String 'Policy (Windows) "Baseline"'
#>
function Remove-M365DSCSpecialCharacters
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param(
        [Parameter(Mandatory = $true)]
        [System.String]
        $String
    )

    Initialize-M365DSCDllLoader -ErrorAction Stop
    return [Microsoft365DSC.Utilities.Utilities]::RemoveSpecialCharacters($String)
}

<#
.SYNOPSIS
    Compares two complex objects for drift.

.DESCRIPTION
    Compares source and target complex objects using the Microsoft365DSC comparer, records drift details in the global drift collection, and returns whether both objects are equivalent.

.PARAMETER Source
    Specifies the current or source object.

.PARAMETER Target
    Specifies the desired or target object.

.PARAMETER PropertyName
    Specifies the property name context used by the comparer.

.OUTPUTS
    System.Boolean
#>
function Compare-M365DSCComplexObject
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter()]
        $Source,

        [Parameter()]
        $Target,

        [Parameter(Mandatory = $true)]
        [System.String]
        $PropertyName
    )

    if ($null -eq $Global:AllDrifts)
    {
        $Global:AllDrifts = @{
            DriftInfo     = @()
            CurrentValues = @{}
            DesiredValues = @{}
        }
    }

    Initialize-M365DSCDllLoader -ErrorAction Stop

    $tuple = [Microsoft365DSC.Compare.ComplexObjectComparer]::Compare($Source, $Target, $PropertyName, $null)
    if ($tuple.Item1.Count -gt 0)
    {
        $Global:AllDrifts.DriftInfo += $tuple.Item1
    }
    return $tuple.Item2
}

<#
.SYNOPSIS
    Renders a drift value as readable text.

.DESCRIPTION
    A drift on a complex property carries the object itself. String interpolation renders such an
    object as its type name. This function expands its members instead.

.PARAMETER Value
    The value to render.

.PARAMETER Depth
    How many levels of nesting to expand before falling back to the type name.

.FUNCTIONALITY
    Internal
#>
function Convert-M365DSCDriftValueToString
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param(
        [Parameter()]
        $Value,

        [Parameter()]
        [System.Int32]
        $Depth = 3
    )

    if ($null -eq $Value)
    {
        return [System.String]::Empty
    }

    if ($Value -is [System.String] -or $Value -is [System.ValueType])
    {
        return $Value.ToString()
    }

    if ($Depth -le 0)
    {
        return $Value.ToString()
    }

    if ($Value -is [System.Collections.IDictionary])
    {
        $entries = @()
        foreach ($key in ($Value.Keys | Sort-Object))
        {
            $entries += "$key=$(Convert-M365DSCDriftValueToString -Value $Value[$key] -Depth ($Depth - 1))"
        }

        return '{' + ($entries -join ', ') + '}'
    }

    if ($Value -is [System.Collections.IEnumerable])
    {
        $entries = @()
        foreach ($item in $Value)
        {
            $entries += Convert-M365DSCDriftValueToString -Value $item -Depth ($Depth - 1)
        }

        return $entries -join ', '
    }

    return $Value.ToString()
}

<#
.SYNOPSIS
    Writes detected configuration drifts to the event log.

.DESCRIPTION
    Masks authentication parameters, builds a drift event payload from desired and current values, and writes the event to the Microsoft365DSC event source when drift information is present.

.PARAMETER Drifts
    Specifies the drift object that contains drift details.

.PARAMETER ResourceName
    Specifies the DSC resource name associated with the drift.

.PARAMETER TenantName
    Specifies the tenant identifier or display name included in the event payload.

.PARAMETER CurrentValues
    Specifies current resource values to include in the event payload.

.PARAMETER DesiredValues
    Specifies desired resource values to include in the event payload.
#>
function Write-M365DSCDriftsToEventLog
{
    [CmdletBinding()]
    param(
        [Parameter()]
        [System.Collections.Hashtable]
        $Drifts,

        [Parameter()]
        [System.String]
        $ResourceName,

        [Parameter()]
        [System.String]
        $TenantName,

        [Parameter(Mandatory = $true)]
        [HashTable]
        $CurrentValues,

        [Parameter(Mandatory = $true)]
        [Object]
        $DesiredValues
    )

    $CurrentValues = Set-M365DSCAuthenticationParameterMask -BoundParameters $CurrentValues
    $DesiredValues = Set-M365DSCAuthenticationParameterMask -BoundParameters $DesiredValues

    # If ExistingDrifts is null, then this is the main call and not a recursive one. Write to the Event log.
    if ($null -ne $Drifts -and $Drifts.DriftInfo.Length -gt 0)
    {

        if ($PSEdition -eq 'Desktop' -or $IsWindows)
        {
            # Get LCMState
            $LCMState = $null
            try
            {
                if (([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
                {
                    $LCMInfo = Get-DscLocalConfigurationManager -ErrorAction Stop

                    if ($LCMInfo.LCMStateDetail -eq 'LCM is performing a consistency check.' -or `
                            $LCMInfo.LCMStateDetail -eq 'LCM exécute une vérification de cohérence.' -or `
                            $LCMInfo.LCMStateDetail -eq 'LCM führt gerade eine Konsistenzüberprüfung durch.')
                    {
                        $LCMState = 'ConsistencyCheck'
                    }
                    elseif ($LCMInfo.LCMStateDetail -eq 'LCM is testing node against the configuration.')
                    {
                        $LCMState = 'ManualTestDSCConfiguration'
                    }
                    elseif ($LCMInfo.LCMStateDetail -eq 'LCM is applying a new configuration.' -or `
                            $LCMInfo.LCMStateDetail -eq 'LCM applique une nouvelle configuration.')
                    {
                        $LCMState = 'Initial'
                    }
                }
                else
                {
                    $LCMState = 'Unauthorized'
                }
            }
            catch
            {
                Write-Verbose -Message $_.Exception
            }
        }

        if (-not $ResourceName.StartsWith('MSFT_'))
        {
            $ResourceName = 'MSFT_' + $ResourceName
        }

        $EventMessage = [System.Text.StringBuilder]::new()
        $EventMessage.Append("<M365DSCEvent>`r`n") | Out-Null
        $EventMessage.Append("    <ConfigurationDrift Source=`"$ResourceName`" TenantId=`"$TenantName`"") | Out-Null
        if (-not [System.String]::IsNullOrEmpty($LCMState))
        {
            $EventMessage.Append(" LCMState=`"" + $LCMState + "`"") | Out-Null
        }
        $EventMessage.Append(">`r`n") | Out-Null
        $EventMessage.Append("        <ParametersNotInDesiredState>`r`n") | Out-Null
        foreach ($drift in $Drifts.DriftInfo)
        {
            $currentText = Convert-M365DSCDriftValueToString -Value $drift.CurrentValue
            $desiredText = Convert-M365DSCDriftValueToString -Value $drift.DesiredValue
            $EventMessage.Append("            <Param Name=`"$($drift.PropertyName.Replace('..', '.'))`"><CurrentValue>$currentText</CurrentValue><DesiredValue>$desiredText</DesiredValue></Param>`r`n") | Out-Null
        }
        $EventMessage.Append("        </ParametersNotInDesiredState>`r`n") | Out-Null
        $EventMessage.Append("    </ConfigurationDrift>`r`n") | Out-Null
        $EventMessage.Append("    <DesiredValues>`r`n") | Out-Null
        foreach ($Key in $DesiredValues.Keys)
        {
            $Value = $DesiredValues.$Key
            if ([System.String]::IsNullOrEmpty($Value))
            {
                $Value = "`$null"
            }
            $EventMessage.Append("        <Param Name =`"$($key)`">$Value</Param>`r`n") | Out-Null
        }
        $EventMessage.Append("    </DesiredValues>`r`n") | Out-Null
        $EventMessage.Append("    <CurrentValues>`r`n") | Out-Null
        foreach ($Key in $CurrentValues.Keys)
        {
            $Value = $CurrentValues.$Key
            if ([System.String]::IsNullOrEmpty($Value))
            {
                $Value = "`$null"
            }
            $EventMessage.Append("        <Param Name =`"$key`">$Value</Param>`r`n") | Out-Null
        }
        $EventMessage.Append("    </CurrentValues>`r`n") | Out-Null
        $EventMessage.Append('</M365DSCEvent>') | Out-Null
        Write-Verbose -Message $EventMessage.ToString()
        Add-M365DSCEvent -Message $EventMessage.ToString() -EventType 'Drift' -EntryType 'Warning' `
            -EventID 1 -Source $ResourceName
    }
}

<#
.SYNOPSIS
    Normalizes complex objects into hashtables.

.DESCRIPTION
    Converts complex CIM instances into normalized hashtables. Supports single-level conversion and optional exclusion of unchanged properties.

.PARAMETER ComplexObject
    Specifies the complex object to normalize.

.PARAMETER SingleLevel
    Converts only top-level properties and lowercases the first character of each property name.

.PARAMETER ExcludeUnchangedProperties
    Excludes properties that were not modified when SingleLevel conversion is used.

.OUTPUTS
    System.Collections.Hashtable
    System.Collections.Hashtable[]
#>
function Convert-M365DSCDRGComplexTypeToHashtable
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable], [System.Collections.Hashtable[]])]
    param(
        [Parameter(Mandatory = $true)]
        [AllowNull()]
        $ComplexObject,

        [Parameter()]
        [switch]
        $SingleLevel,

        [Parameter()]
        [switch]
        $ExcludeUnchangedProperties
    )

    if ($null -eq $ComplexObject)
    {
        return @{}
    }

    if ($SingleLevel)
    {
        $returnObject = @{}
        $keys = $ComplexObject.CimInstanceProperties | Where-Object -Property Name -NE 'PSComputerName'
        foreach ($key in $keys)
        {
            if ($ExcludeUnchangedProperties -and -not $key.IsValueModified)
            {
                continue
            }
            $propertyName = $key.Name[0].ToString().ToLower() + $key.Name.Substring(1, $key.Name.Length - 1)
            $propertyValue = $ComplexObject.$($key.Name)
            $returnObject.Add($propertyName, $propertyValue)
        }
        return $returnObject
    }

    Initialize-M365DSCDllLoader -ErrorAction Stop

    return [Microsoft365DSC.Converter.ObjectNormalizer]::Normalize($ComplexObject)
}
