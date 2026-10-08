<#
.SYNOPSIS
    Returns the Graph cmdlet nouns the resources already claim.

.DESCRIPTION
    Built from the commands each resource records rather than from generatedFrom. A resource
    names the cmdlets it calls even when its entity type could not be resolved.

.PARAMETER Origin
    Specifies the resource rows from Get-ResourceOriginSurface.

.PARAMETER Inventory
    Specifies the noun map from Get-GraphCommandInventory.

.OUTPUTS
    An ordered dictionary with Noun, Cmdlet, ClaimedModule, OutputType and RouteParent, each a
    case-insensitive set.
#>
function Get-CoverageClaimSet
{
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param
    (
        [Parameter()]
        [AllowEmptyCollection()]
        [System.Object[]]
        $Origin = @(),

        [Parameter()]
        [System.Collections.IDictionary]
        $Inventory = @{}
    )

    $nouns = [System.Collections.Generic.HashSet[System.String]]::new([System.StringComparer]::OrdinalIgnoreCase)
    $cmdlets = [System.Collections.Generic.HashSet[System.String]]::new([System.StringComparer]::OrdinalIgnoreCase)
    $modules = [System.Collections.Generic.HashSet[System.String]]::new([System.StringComparer]::OrdinalIgnoreCase)

    foreach ($row in $Origin)
    {
        foreach ($command in $row.Commands)
        {
            $module = [System.String] $command.Module
            if ($module -notlike 'Microsoft.Graph*')
            {
                continue
            }

            # settings.json spells the full module name and the metadata only the part after it.
            $null = $modules.Add(($module -replace '^Microsoft\.Graph\.(Beta\.)?', ''))

            $name = [System.String] $command.Name
            $null = $cmdlets.Add($name)

            if ($name -match '^[A-Za-z]+-Mg(Beta)?(?<noun>.+)$')
            {
                $null = $nouns.Add($Matches['noun'])
            }
        }
    }

    $outputTypes = [System.Collections.Generic.HashSet[System.String]]::new([System.StringComparer]::OrdinalIgnoreCase)
    $parents = [System.Collections.Generic.HashSet[System.String]]::new([System.StringComparer]::OrdinalIgnoreCase)

    foreach ($noun in $nouns)
    {
        if (-not $Inventory.Contains($noun))
        {
            continue
        }

        foreach ($type in $Inventory[$noun].OutputTypes)
        {
            $null = $outputTypes.Add([System.String] $type)
        }

        foreach ($route in $Inventory[$noun].Uris)
        {
            $route = [System.String] $route
            $cut = $route.LastIndexOf('/')
            if ($cut -gt 0)
            {
                $null = $parents.Add($route.Substring(0, $cut))
            }
        }
    }

    return [ordered]@{
        Noun          = $nouns
        Cmdlet        = $cmdlets
        ClaimedModule = $modules
        OutputType    = $outputTypes
        RouteParent   = $parents
    }
}
