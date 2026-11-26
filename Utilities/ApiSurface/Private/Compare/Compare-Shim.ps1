<#
.SYNOPSIS
    Reports where the generated Graph shim disagrees with the SDK.

.DESCRIPTION
    Absolute rather than delta scoped. The shim is regenerated as a whole. A wrapper goes stale
    on the day the SDK moves, not on the day a baseline was taken.

.PARAMETER Current
    Specifies the snapshot just taken.

.PARAMETER Origin
    Specifies the resource rows from Get-ResourceOriginSurface.

.PARAMETER Exclusion
    Specifies the parsed exclusions.json.

.OUTPUTS
    The findings.
#>
function Compare-Shim
{
    [CmdletBinding()]
    [OutputType([System.Object[]])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Object]
        $Current,

        [Parameter()]
        [AllowEmptyCollection()]
        [System.Object[]]
        $Origin = @(),

        [Parameter()]
        [AllowNull()]
        [System.Object]
        $Exclusion
    )

    $findings = [System.Collections.Generic.List[System.Object]]::new()

    $exported = [System.Collections.Generic.HashSet[System.String]]::new(
        [System.String[]] @(Get-SurfaceMemberName -Container $Current.shim), [System.StringComparer]::OrdinalIgnoreCase)

    $findings.AddRange([System.Object[]] @(Find-MissingShimCmdlet -Origin $Origin -Exported $exported -Exclusion $Exclusion))
    $findings.AddRange([System.Object[]] @(Find-StaleShimWrapper -Current $Current -Exported $exported))

    return [System.Object[]] $findings
}

<#
.SYNOPSIS
    Reports a Graph cmdlet a resource calls that the shim does not export.

.DESCRIPTION
    Reads what the resources call rather than the snapshot's cmdlets map. A cmdlet the SDK
    metadata has no route for still lands in that map without variants. Its absence from the
    shim would go unnoticed there.

.PARAMETER Origin
    Specifies the resource rows.

.PARAMETER Exported
    Specifies the names the shim manifest exports.

.PARAMETER Exclusion
    Specifies the parsed exclusions.json.

.OUTPUTS
    The findings.
#>
function Find-MissingShimCmdlet
{
    [CmdletBinding()]
    [OutputType([System.Object[]])]
    param
    (
        [Parameter()]
        [AllowEmptyCollection()]
        [System.Object[]]
        $Origin = @(),

        [Parameter(Mandatory = $true)]
        [System.Object]
        $Exported,

        [Parameter()]
        [AllowNull()]
        [System.Object]
        $Exclusion
    )

    $ignored = [System.Collections.Generic.HashSet[System.String]]::new(
        [System.String[]] @($Exclusion.nonShimCmdlets | ForEach-Object -Process { [System.String] $_.cmdlet }),
        [System.StringComparer]::OrdinalIgnoreCase)

    $callers = [System.Collections.Specialized.OrderedDictionary]::new([System.StringComparer]::Ordinal)

    foreach ($row in $Origin)
    {
        foreach ($command in $row.Commands)
        {
            $name = [System.String] $command.Name
            if (([System.String] $command.Module) -notlike 'Microsoft.Graph*')
            {
                continue
            }

            if ($Exported.Contains($name) -or $ignored.Contains($name))
            {
                continue
            }

            if (-not $callers.Contains($name))
            {
                $callers[$name] = [System.Collections.Generic.List[System.String]]::new()
            }

            $callers[$name].Add([System.String] $row.Resource)
        }
    }

    $findings = [System.Collections.Generic.List[System.Object]]::new()

    foreach ($name in (Get-M365DSCOrderedName -Value ([System.String[]] @($callers.Keys))))
    {
        $resources = Get-M365DSCOrderedName -Value ([System.String[]] @($callers[$name] | Select-Object -Unique))

        $findings.Add((New-M365DSCApiSurfaceFinding -Code 'SHIM-MISSING' `
                    -Subject $name `
                    -Evidence ([ordered]@{
                        source   = "shim:$name"
                        calledBy = @($resources)
                    })))
    }

    return [System.Object[]] $findings
}

<#
.SYNOPSIS
    Reports an exported wrapper whose route or parameters differ from the SDK.

.DESCRIPTION
    A Get wrapper flattens its collection route and its item route into one record. Both routes
    are compared. A route matching cmdletOverrides is a correction the shim generator applies
    and is not stale.

.PARAMETER Current
    Specifies the snapshot just taken.

.PARAMETER Exported
    Specifies the names the shim manifest exports.

.OUTPUTS
    The findings.
#>
function Find-StaleShimWrapper
{
    [CmdletBinding()]
    [OutputType([System.Object[]])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Object]
        $Current,

        [Parameter(Mandatory = $true)]
        [System.Object]
        $Exported
    )

    $findings = [System.Collections.Generic.List[System.Object]]::new()

    foreach ($name in (Get-M365DSCOrderedName -Value ([System.String[]] @($Exported))))
    {
        $wrapper = Get-SurfaceMember -Container $Current.shim -Name $name
        $sdk = Get-SurfaceMember -Container $Current.cmdlets -Name $name
        if ($null -eq $wrapper -or $null -eq $sdk)
        {
            continue
        }

        $variants = @($sdk.variants)
        $override = Get-SurfaceMember -Container $Current.cmdletOverrides -Name $name
        if ($null -ne $override)
        {
            $variants += @($override.variants)
        }

        if ($variants.Count -eq 0)
        {
            continue
        }

        $known = [System.Collections.Generic.HashSet[System.String]]::new([System.StringComparer]::OrdinalIgnoreCase)
        foreach ($variant in $variants)
        {
            $null = $known.Add("$($variant.method) $(ConvertTo-ShimRouteKey -Uri ([System.String] $variant.uri))")
        }

        foreach ($route in @([System.String] $wrapper.uri, [System.String] $wrapper.itemUri))
        {
            if ([System.String]::IsNullOrEmpty($route))
            {
                continue
            }

            $key = "$($wrapper.method) $(ConvertTo-ShimRouteKey -Uri $route)"
            if ($known.Contains($key))
            {
                continue
            }

            $findings.Add((New-M365DSCApiSurfaceFinding -Code 'SHIM-STALE' `
                        -Subject $name `
                        -From ([ordered]@{ method = [System.String] $wrapper.method; uri = $route }) `
                        -To ([ordered]@{ variants = @($variants | ForEach-Object -Process { "$($_.method) $($_.uri)" }) }) `
                        -Evidence ([ordered]@{ source = "shim:$name"; reason = 'route' })))
        }

        $declared = [System.Collections.Generic.HashSet[System.String]]::new(
            [System.String[]] @($wrapper.parameters), [System.StringComparer]::OrdinalIgnoreCase)

        $absent = @(Get-SurfaceMemberName -Container $sdk.parameters |
                Where-Object -FilterScript { -not $declared.Contains($_) })

        if ($absent.Count -gt 0)
        {
            $findings.Add((New-M365DSCApiSurfaceFinding -Code 'SHIM-STALE' `
                        -Subject $name `
                        -Property 'parameters' `
                        -To ([ordered]@{ added = @(Get-M365DSCOrderedName -Value ([System.String[]] $absent)) }) `
                        -Evidence ([ordered]@{ source = "shim:$name"; reason = 'parameters' })))
        }
    }

    return [System.Object[]] $findings
}

<#
.SYNOPSIS
    Reduces a route to the form both sides can be compared in.

.DESCRIPTION
    The shim names a placeholder after its PowerShell parameter and the SDK after the OData
    property. The token text is erased. Literal segments already agree, including their case.

.PARAMETER Uri
    Specifies the route.

.OUTPUTS
    The comparable route.
#>
function ConvertTo-ShimRouteKey
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter()]
        [AllowEmptyString()]
        [System.String]
        $Uri
    )

    if ([System.String]::IsNullOrEmpty($Uri))
    {
        return ''
    }

    return ($Uri -replace '\{[^}]*\}', '{}').TrimEnd('/')
}
