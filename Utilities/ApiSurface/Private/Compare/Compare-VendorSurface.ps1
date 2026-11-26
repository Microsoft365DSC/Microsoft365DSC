<#
.SYNOPSIS
    Reports what the vendor changed between two snapshots.

.DESCRIPTION
    A workload or module skipped by either snapshot is dropped entirely. Without that, a tenant
    connected run reports every Exchange Online cmdlet as added and the next offline run reports
    them all as removed.

.PARAMETER Baseline
    Specifies the previous snapshot.

.PARAMETER Current
    Specifies the snapshot just taken.

.PARAMETER Origin
    Specifies the resource rows, used to name which resources call a removed cmdlet.

.OUTPUTS
    The findings.
#>
function Compare-VendorSurface
{
    [CmdletBinding()]
    [OutputType([System.Object[]])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Object]
        $Baseline,

        [Parameter(Mandatory = $true)]
        [System.Object]
        $Current,

        [Parameter()]
        [AllowEmptyCollection()]
        [System.Object[]]
        $Origin = @()
    )

    $findings = [System.Collections.Generic.List[System.Object]]::new()

    $skipped = [System.Collections.Generic.HashSet[System.String]]::new([System.StringComparer]::OrdinalIgnoreCase)
    foreach ($snapshot in @($Baseline, $Current))
    {
        $completeness = Get-SurfaceMember -Container $snapshot -Name 'completeness'
        foreach ($name in @((Get-SurfaceMember -Container $completeness -Name 'skippedWorkloads')))
        {
            $null = $skipped.Add([System.String] $name)
        }
        foreach ($name in @((Get-SurfaceMember -Container $completeness -Name 'skippedModules')))
        {
            $null = $skipped.Add([System.String] $name)
        }
    }

    $callers = @{}
    foreach ($row in $Origin)
    {
        foreach ($command in @($row.Commands))
        {
            if (-not $callers.ContainsKey($command.Name))
            {
                $callers[$command.Name] = [System.Collections.Generic.List[System.String]]::new()
            }

            if ($row.Resource -notin $callers[$command.Name])
            {
                $callers[$command.Name].Add($row.Resource)
            }
        }
    }

    $baselineCmdlets = Get-SurfaceMember -Container $Baseline -Name 'cmdlets'
    $currentCmdlets = Get-SurfaceMember -Container $Current -Name 'cmdlets'
    $overrides = Get-SurfaceMember -Container $Current -Name 'cmdletOverrides'

    foreach ($name in (Get-SurfaceMemberName -Container $baselineCmdlets))
    {
        $before = Get-SurfaceMember -Container $baselineCmdlets -Name $name
        if ($before.workload -in $skipped -or $before.module -in $skipped)
        {
            continue
        }

        $after = Get-SurfaceMember -Container $currentCmdlets -Name $name

        if ($null -eq $after)
        {
            $calledBy = @()
            if ($callers.ContainsKey($name))
            {
                $calledBy = @($callers[$name] | Where-Object { -not [System.String]::IsNullOrEmpty($_) })
            }

            $code = 'VND-CMDLET-REMOVED'
            if ($calledBy.Count -eq 0)
            {
                $code = 'COV-CMDLET-UNUSED'
            }

            $findings.Add((New-M365DSCApiSurfaceFinding -Code $code `
                        -Subject $name `
                        -Workload ([System.String] $before.workload) `
                        -From ([ordered]@{ module = [System.String] $before.module; moduleVersion = [System.String] $before.moduleVersion }) `
                        -To $null `
                        -Evidence ([ordered]@{
                            source     = "cmdlet:$name"
                            calledBy   = $calledBy
                            fromModule = "$([System.String] $before.module) $([System.String] $before.moduleVersion)"
                        })))
            continue
        }

        $findings.AddRange([System.Object[]] @(Compare-CmdletRoute -Name $name -Before $before -After $after -Override $overrides))
        $findings.AddRange([System.Object[]] @(Compare-CmdletParameter -Name $name -Before $before -After $after))
    }

    $baselineTypes = Get-SurfaceMember -Container $Baseline -Name 'graphTypes'
    $currentTypes = Get-SurfaceMember -Container $Current -Name 'graphTypes'

    foreach ($typeKey in (Get-SurfaceMemberName -Container $currentTypes))
    {
        $before = Get-SurfaceMember -Container $baselineTypes -Name $typeKey
        if ($null -eq $before)
        {
            continue
        }

        $after = Get-SurfaceMember -Container $currentTypes -Name $typeKey
        $beforeProperties = Get-SurfaceMember -Container $before -Name 'properties'
        $afterProperties = Get-SurfaceMember -Container $after -Name 'properties'

        foreach ($property in (Get-SurfaceMemberName -Container $afterProperties))
        {
            $beforeProperty = Get-SurfaceMember -Container $beforeProperties -Name $property
            $afterProperty = Get-SurfaceMember -Container $afterProperties -Name $property

            if ($null -eq $beforeProperty)
            {
                $findings.Add((New-M365DSCApiSurfaceFinding -Code 'VND-TYPE-PROP-ADDED' `
                            -Subject $typeKey `
                            -Property $property `
                            -Workload 'MicrosoftGraph' `
                            -From $null `
                            -To ([ordered]@{
                                type       = [System.String] $afterProperty.type
                                isArray    = [System.Boolean] $afterProperty.isArray
                                isReadOnly = [System.Boolean] $afterProperty.isReadOnly
                            }) `
                            -Evidence ([ordered]@{ source = "csdl:$($typeKey -replace ':', '/')/$property" })))
                continue
            }

            $addedMembers = @(Get-AddedEnumMember -Before $beforeProperty -After $afterProperty)
            if ($addedMembers.Count -gt 0)
            {
                $findings.Add((New-M365DSCApiSurfaceFinding -Code 'VND-ENUM-MEMBER-ADDED' `
                            -Subject $typeKey `
                            -Property $property `
                            -Workload 'MicrosoftGraph' `
                            -From ([ordered]@{ enum = @($beforeProperty.enum) }) `
                            -To ([ordered]@{ enum = @($afterProperty.enum); added = $addedMembers }) `
                            -Evidence ([ordered]@{ source = "csdl:$($typeKey -replace ':', '/')/$property" })))
            }
        }
    }

    return $findings.ToArray()
}

<#
.SYNOPSIS
    Reports a route that moved within its own API version.

.DESCRIPTION
    A variant present before and absent after, within the API version the resource uses, is a
    reroute. A variant that only appears in the other API version is a promotion. A route that
    matches a cmdletOverrides entry is a build time correction rather than a vendor change.

.PARAMETER Name
    Specifies the cmdlet name.

.PARAMETER Before
    Specifies the baseline cmdlet entry.

.PARAMETER After
    Specifies the current cmdlet entry.

.PARAMETER Override
    Specifies the cmdletOverrides section.

.OUTPUTS
    The findings.
#>
function Compare-CmdletRoute
{
    [CmdletBinding()]
    [OutputType([System.Object[]])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [Parameter(Mandatory = $true)]
        [System.Object]
        $Before,

        [Parameter(Mandatory = $true)]
        [System.Object]
        $After,

        [Parameter()]
        [AllowNull()]
        [System.Object]
        $Override
    )

    $apiVersion = [System.String] $Before.apiVersion
    if ([System.String]::IsNullOrEmpty($apiVersion))
    {
        return @()
    }

    $overrideEntry = Get-SurfaceMember -Container $Override -Name $Name
    $overrideRoutes = [System.Collections.Generic.HashSet[System.String]]::new([System.StringComparer]::OrdinalIgnoreCase)
    foreach ($variant in @((Get-SurfaceMember -Container $overrideEntry -Name 'variants')))
    {
        $null = $overrideRoutes.Add("$($variant.method) $($variant.uri)")
    }

    $afterRoutes = [System.Collections.Generic.HashSet[System.String]]::new([System.StringComparer]::OrdinalIgnoreCase)
    foreach ($variant in @($After.variants))
    {
        if ([System.String] $variant.apiVersion -ne $apiVersion)
        {
            continue
        }

        $null = $afterRoutes.Add("$($variant.method) $($variant.uri)")
    }

    $findings = [System.Collections.Generic.List[System.Object]]::new()

    foreach ($variant in @($Before.variants))
    {
        if ([System.String] $variant.apiVersion -ne $apiVersion)
        {
            continue
        }

        $route = "$($variant.method) $($variant.uri)"
        if ($afterRoutes.Contains($route) -or $overrideRoutes.Contains($route))
        {
            continue
        }

        $findings.Add((New-M365DSCApiSurfaceFinding -Code 'VND-CMDLET-REROUTED' `
                    -Subject $Name `
                    -Property $route `
                    -Workload ([System.String] $Before.workload) `
                    -From ([ordered]@{ method = [System.String] $variant.method; uri = [System.String] $variant.uri }) `
                    -To ([ordered]@{ variants = @($afterRoutes) }) `
                    -Evidence ([ordered]@{ source = "cmdlet:$Name"; apiVersion = $apiVersion })))
    }

    return $findings.ToArray()
}

<#
.SYNOPSIS
    Reports parameters that appeared or changed type on a cmdlet.

.PARAMETER Name
    Specifies the cmdlet name.

.PARAMETER Before
    Specifies the baseline cmdlet entry.

.PARAMETER After
    Specifies the current cmdlet entry.

.OUTPUTS
    The findings.
#>
function Compare-CmdletParameter
{
    [CmdletBinding()]
    [OutputType([System.Object[]])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [Parameter(Mandatory = $true)]
        [System.Object]
        $Before,

        [Parameter(Mandatory = $true)]
        [System.Object]
        $After
    )

    $findings = [System.Collections.Generic.List[System.Object]]::new()
    $beforeParameters = Get-SurfaceMember -Container $Before -Name 'parameters'
    $afterParameters = Get-SurfaceMember -Container $After -Name 'parameters'

    foreach ($parameter in (Get-SurfaceMemberName -Container $afterParameters))
    {
        $beforeType = Get-SurfaceMember -Container $beforeParameters -Name $parameter
        $afterType = Get-SurfaceMember -Container $afterParameters -Name $parameter

        if ($null -eq $beforeType)
        {
            $findings.Add((New-M365DSCApiSurfaceFinding -Code 'VND-PARAM-ADDED' `
                        -Subject $Name `
                        -Property $parameter `
                        -Workload ([System.String] $After.workload) `
                        -From $null `
                        -To ([ordered]@{ type = [System.String] $afterType }) `
                        -Evidence ([ordered]@{ source = "cmdlet:$Name/$parameter" })))
            continue
        }

        if ([System.String] $beforeType -ne [System.String] $afterType)
        {
            $findings.Add((New-M365DSCApiSurfaceFinding -Code 'VND-PARAM-TYPECHANGED' `
                        -Subject $Name `
                        -Property $parameter `
                        -Workload ([System.String] $After.workload) `
                        -From ([ordered]@{ type = [System.String] $beforeType }) `
                        -To ([ordered]@{ type = [System.String] $afterType }) `
                        -Evidence ([ordered]@{ source = "cmdlet:$Name/$parameter" })))
        }
    }

    return $findings.ToArray()
}

<#
.SYNOPSIS
    Returns the enum members present after and absent before.

.PARAMETER Before
    Specifies the baseline property entry.

.PARAMETER After
    Specifies the current property entry.

.OUTPUTS
    The added member names.
#>
function Get-AddedEnumMember
{
    [CmdletBinding()]
    [OutputType([System.String[]])]
    param
    (
        [Parameter()]
        [AllowNull()]
        [System.Object]
        $Before,

        [Parameter()]
        [AllowNull()]
        [System.Object]
        $After
    )

    $beforeMembers = [System.Collections.Generic.HashSet[System.String]]::new(
        [System.String[]] @(@((Get-SurfaceMember -Container $Before -Name 'enum')) | Where-Object -FilterScript { $null -ne $_ }),
        [System.StringComparer]::Ordinal)

    $added = [System.Collections.Generic.List[System.String]]::new()
    foreach ($member in @((Get-SurfaceMember -Container $After -Name 'enum')))
    {
        if ($null -eq $member)
        {
            continue
        }

        if (-not $beforeMembers.Contains([System.String] $member))
        {
            $added.Add([System.String] $member)
        }
    }

    return [System.String[]] $added
}

<#
.SYNOPSIS
    Reports dependencies whose pin is behind what the gallery publishes.

.DESCRIPTION
    Reads the dependencies section rather than comparing two snapshots. Every module that is
    behind is reported, with the jump size on the finding for the renderer to group by.

.PARAMETER Current
    Specifies the snapshot just taken.

.OUTPUTS
    The findings.
#>
function Compare-DependencyVersion
{
    [CmdletBinding()]
    [OutputType([System.Object[]])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Object]
        $Current
    )

    $findings = [System.Collections.Generic.List[System.Object]]::new()
    $dependencies = Get-SurfaceMember -Container $Current -Name 'dependencies'

    foreach ($name in (Get-SurfaceMemberName -Container $dependencies))
    {
        $entry = Get-SurfaceMember -Container $dependencies -Name $name
        $pinned = [System.String] $entry.pinned
        $latest = [System.String] $entry.latestPublished

        if ([System.String]::IsNullOrEmpty($latest) -or $latest -eq $pinned)
        {
            continue
        }

        $pinnedVersion = $null
        $latestVersion = $null
        if (-not [System.Version]::TryParse($pinned, [ref] $pinnedVersion) -or
            -not [System.Version]::TryParse($latest, [ref] $latestVersion))
        {
            continue
        }

        if ($latestVersion -le $pinnedVersion)
        {
            continue
        }

        $jump = 'Patch'
        if ($latestVersion.Major -gt $pinnedVersion.Major)
        {
            $jump = 'Major'
        }
        elseif ($latestVersion.Minor -gt $pinnedVersion.Minor)
        {
            $jump = 'Minor'
        }

        $findings.Add((New-M365DSCApiSurfaceFinding -Code 'VND-NEWER-VERSION' `
                    -Subject $name `
                    -From ([ordered]@{ version = $pinned }) `
                    -To ([ordered]@{ version = $latest; jump = $jump }) `
                    -Evidence ([ordered]@{
                        source    = "gallery:$name"
                        manifests = @($entry.manifests)
                    })))
    }

    return $findings.ToArray()
}
