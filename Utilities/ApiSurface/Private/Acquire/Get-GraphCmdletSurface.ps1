<#
.SYNOPSIS
    Captures the Graph SDK cmdlets the shim is generated from.

.DESCRIPTION
    Build-CmdletMapping.ps1 and Extract-FunctionSignatures.ps1 produce both files from the
    installed SDK. Reading them avoids loading the SDK sub-modules a second time. The overrides
    correct a few routes at build time and are captured next to the cmdlets they change.

.PARAMETER CmdletMappingPath
    Specifies the path of cmdlet-mapping.json.

.PARAMETER FunctionSignaturePath
    Specifies the path of function-signatures.json.

.PARAMETER CmdletMappingOverridePath
    Specifies the path of cmdlet-mapping-overrides.json.

.PARAMETER ModuleVersion
    Specifies a map of module name to pinned version.

.OUTPUTS
    A hashtable with Cmdlets and Overrides, both ordered maps.
#>
function Get-GraphCmdletSurface
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $CmdletMappingPath,

        [Parameter(Mandatory = $true)]
        [System.String]
        $FunctionSignaturePath,

        [Parameter()]
        [AllowNull()]
        [System.String]
        $CmdletMappingOverridePath,

        [Parameter()]
        [System.Collections.IDictionary]
        $ModuleVersion = @{}
    )

    $mapping = Get-Content -Path $CmdletMappingPath -Raw | ConvertFrom-Json
    $signatures = Get-Content -Path $FunctionSignaturePath -Raw | ConvertFrom-Json

    $cmdlets = @{}
    foreach ($property in $mapping.PSObject.Properties)
    {
        $name = $property.Name
        $entry = $property.Value

        $variants = @()
        foreach ($variant in @($entry.Variants))
        {
            if ($null -eq $variant)
            {
                continue
            }

            $variants += [ordered]@{
                method     = [System.String] $variant.Method
                uri        = [System.String] $variant.URI
                apiVersion = [System.String] $variant.ApiVersion
            }
        }

        $module = [System.String] $entry.SourceModule

        $cmdlets[$name] = [ordered]@{
            workload      = 'MicrosoftGraph'
            module        = $module
            moduleVersion = $ModuleVersion[$module]
            apiVersion    = [System.String] $entry.ApiVersion
            variants      = @(Get-OrderedVariant -Variant $variants)
            parameters    = ConvertTo-ParameterMap -Signature $signatures.PSObject.Properties[$name].Value
        }
    }

    $overrides = @{}
    if (-not [System.String]::IsNullOrEmpty($CmdletMappingOverridePath) -and (Test-Path -Path $CmdletMappingOverridePath))
    {
        $overrideContent = Get-Content -Path $CmdletMappingOverridePath -Raw | ConvertFrom-Json
        foreach ($property in $overrideContent.PSObject.Properties)
        {
            $variants = @()
            foreach ($variant in @($property.Value.Variants))
            {
                if ($null -eq $variant)
                {
                    continue
                }

                $variants += [ordered]@{
                    method     = [System.String] $variant.Method
                    uri        = [System.String] $variant.URI
                    apiVersion = [System.String] $variant.ApiVersion
                }
            }

            $overrides[$property.Name] = [ordered]@{
                reason   = [System.String] $property.Value.Reason
                variants = @(Get-OrderedVariant -Variant $variants)
            }
        }
    }

    return @{
        Cmdlets   = ConvertTo-M365DSCOrderedMap -Map $cmdlets
        Overrides = ConvertTo-M365DSCOrderedMap -Map $overrides
    }
}

<#
.SYNOPSIS
    Returns the route variants in a stable order.

.PARAMETER Variant
    Specifies the variants to order.

.OUTPUTS
    The ordered variants.
#>
function Get-OrderedVariant
{
    [CmdletBinding()]
    [OutputType([System.Object[]])]
    param
    (
        [Parameter()]
        [AllowEmptyCollection()]
        [System.Object[]]
        $Variant = @()
    )

    $keys = @{}
    foreach ($item in $Variant)
    {
        $keys["$($item.method) $($item.uri) $($item.apiVersion)"] = $item
    }

    return @((ConvertTo-M365DSCOrderedMap -Map $keys).Values)
}

<#
.SYNOPSIS
    Turns a function-signatures.json entry into an ordered parameter map.

.PARAMETER Signature
    Specifies the array of Name and Type pairs.

.OUTPUTS
    An ordered map of parameter name to type name.
#>
function ConvertTo-ParameterMap
{
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param
    (
        [Parameter()]
        [AllowNull()]
        [System.Object]
        $Signature
    )

    $parameters = @{}
    foreach ($item in @($Signature))
    {
        if ($null -eq $item -or [System.String]::IsNullOrEmpty($item.Name))
        {
            continue
        }

        $parameters[[System.String] $item.Name] = [System.String] $item.Type
    }

    return ConvertTo-M365DSCOrderedMap -Map $parameters
}
