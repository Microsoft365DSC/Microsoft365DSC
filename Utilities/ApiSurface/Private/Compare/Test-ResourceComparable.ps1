<#
.SYNOPSIS
    Decides whether a resource can be compared against a Graph CSDL type at all.

.DESCRIPTION
    A resource that fails here yields one coverage line instead of findings.

.PARAMETER Origin
    Specifies one resource row from Get-ResourceOriginSurface.

.PARAMETER GraphType
    Specifies the graphTypes section of the current snapshot.

.PARAMETER SchemaKeyword
    Specifies the DscSchemaCache keyword map, keyed by resource name.

.PARAMETER NonComparableEntityType
    Specifies the entity types whose real surface lives elsewhere.

.OUTPUTS
    An ordered dictionary with Comparable, Reason, TypeKey and ApiVersion.
#>
function Test-ResourceComparable
{
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Object]
        $Origin,

        [Parameter(Mandatory = $true)]
        [System.Object]
        $GraphType,

        [Parameter(Mandatory = $true)]
        [System.Collections.IDictionary]
        $SchemaKeyword,

        [Parameter()]
        [AllowEmptyCollection()]
        [System.String[]]
        $NonComparableEntityType = @()
    )

    $apiVersion = $Origin.ApiVersion
    if ([System.String]::IsNullOrEmpty($apiVersion))
    {
        $apiVersion = 'beta'
    }

    $result = [ordered]@{
        Comparable = $false
        Reason     = $null
        TypeKey    = $null
        TypeName   = [System.String[]] @()
        ApiVersion = $apiVersion
    }

    if ([System.String]::IsNullOrEmpty($Origin.EntityType))
    {
        $result.Reason = 'no resolved entityType'
        return $result
    }

    if ($Origin.EntityType -in $NonComparableEntityType)
    {
        $result.Reason = "entity type '$($Origin.EntityType)' is served by another surface"
        return $result
    }

    if (-not $SchemaKeyword.Contains($Origin.Resource))
    {
        $result.Reason = 'not present in the schema cache'
        return $result
    }

    $typeName = @($Origin.ODataSubtype | Where-Object { -not [System.String]::IsNullOrEmpty($_) })
    if ($typeName.Count -eq 0)
    {
        $typeName = @($Origin.EntityType)
    }

    $missing = @($typeName | Where-Object {
            $null -eq (Get-SurfaceMember -Container $GraphType -Name "${apiVersion}:$_")
        })
    if ($missing.Count -gt 0)
    {
        $result.Reason = "type '${apiVersion}:$($missing[0])' is not in the snapshot"
        return $result
    }

    $result.Comparable = $true
    $result.TypeKey = "${apiVersion}:$($typeName[0])"
    $result.TypeName = [System.String[]] $typeName

    return $result
}
