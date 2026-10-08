#Requires -Version 7.3

<#
.SYNOPSIS
    Lists the raw Graph calls of the resource modules that a shim cmdlet could replace.

.DESCRIPTION
    Walks every resource module for Invoke-MgGraphRequest calls, turns each URI into a route
    template and matches method plus template against Utilities/cmdlet-mapping.json. A hit whose
    cmdlet the resource does not call yet is a candidate, where the shim manifest tells whether that
    cmdlet is already served. A route with no cmdlet lands on the second list, which is the input
    for a shim regeneration.

.PARAMETER RepositoryRoot
    Root of the Microsoft365DSC repository. Defaults to the parent of this script's folder.

.PARAMETER ResourcePath
    Folder holding the MSFT_<Name> resource folders. Defaults to Modules/Microsoft365DSC/DscResources.

.PARAMETER CmdletMappingPath
    Path to cmdlet-mapping.json. Defaults to Utilities/cmdlet-mapping.json.

.PARAMETER ShimManifestPath
    Path to the shim manifest. Defaults to Modules/Microsoft365DSC/Modules/M365DSCGraphShim.psd1.

.PARAMETER OutputPath
    Path of the Markdown worklist. Defaults to Utilities/ApiSurface/rawgraph-shim-candidates.md.

.PARAMETER ResourceFilter
    Wildcard on the resource name without MSFT_.

.PARAMETER SkipSdkLookup
    Leaves every route the mapping does not carry on the REST only list instead of asking
    Find-MgGraphCommand whether a Graph SDK cmdlet serves it.

.EXAMPLE
    ./Utilities/Find-M365DSCRawGraphCall.ps1

.EXAMPLE
    ./Utilities/Find-M365DSCRawGraphCall.ps1 -ResourceFilter 'AAD*'

.OUTPUTS
    A summary object with the candidate, uncovered and unresolved rows.
#>
[CmdletBinding()]
param
(
    [Parameter()]
    [System.String]
    $RepositoryRoot = (Split-Path -Path $PSScriptRoot -Parent),

    [Parameter()]
    [System.String]
    $ResourcePath,

    [Parameter()]
    [System.String]
    $CmdletMappingPath,

    [Parameter()]
    [System.String]
    $ShimManifestPath,

    [Parameter()]
    [System.String]
    $OutputPath,

    [Parameter()]
    [System.String]
    $ResourceFilter = '*',

    [Parameter()]
    [switch]
    $SkipSdkLookup
)

$ErrorActionPreference = 'Stop'

$script:RawCommandNames = @('Invoke-MgGraphRequest', 'Invoke-M365DSCGraphRequest')

<#
.SYNOPSIS
    Returns the text of a URI expression, or $null when it cannot be resolved statically.

.DESCRIPTION
    A literal is taken as is. A concatenation keeps the literal parts and drops the runtime base
    URL. A variable is resolved against the last assignment above the call site.

.PARAMETER Expression
    Specifies the expression node holding the URI.

.PARAMETER Assignments
    Specifies the assignment nodes of the file, keyed by variable name.

.PARAMETER BeforeLine
    Specifies the line of the call site. Only assignments above it are considered.

.PARAMETER Depth
    Specifies the current resolution depth. A variable chain longer than four is given up on.
#>
function Resolve-RawGraphUriText
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Object]
        $Expression,

        [Parameter(Mandatory = $true)]
        [System.Collections.Hashtable]
        $Assignments,

        [Parameter(Mandatory = $true)]
        [System.Int32]
        $BeforeLine,

        [Parameter()]
        [System.Int32]
        $Depth = 0
    )

    if ($Depth -gt 4)
    {
        return $null
    }

    if ($Expression -is [System.Management.Automation.Language.ParenExpressionAst])
    {
        return Resolve-RawGraphUriText -Expression $Expression.Pipeline -Assignments $Assignments -BeforeLine $BeforeLine -Depth ($Depth + 1)
    }

    if ($Expression -is [System.Management.Automation.Language.CommandExpressionAst])
    {
        return Resolve-RawGraphUriText -Expression $Expression.Expression -Assignments $Assignments -BeforeLine $BeforeLine -Depth ($Depth + 1)
    }

    if ($Expression -is [System.Management.Automation.Language.PipelineAst])
    {
        if (@($Expression.PipelineElements).Count -ne 1 -or $Expression.PipelineElements[0] -isnot [System.Management.Automation.Language.CommandExpressionAst])
        {
            return $null
        }
        return Resolve-RawGraphUriText -Expression $Expression.PipelineElements[0].Expression -Assignments $Assignments -BeforeLine $BeforeLine -Depth ($Depth + 1)
    }

    if ($Expression -is [System.Management.Automation.Language.StringConstantExpressionAst] -or
        $Expression -is [System.Management.Automation.Language.ExpandableStringExpressionAst])
    {
        return [System.String] $Expression.Value
    }

    if ($Expression -is [System.Management.Automation.Language.BinaryExpressionAst])
    {
        if ($Expression.Operator -ne [System.Management.Automation.Language.TokenKind]::Plus)
        {
            return $null
        }

        $left = Resolve-RawGraphUriText -Expression $Expression.Left -Assignments $Assignments -BeforeLine $BeforeLine -Depth ($Depth + 1)
        $right = Resolve-RawGraphUriText -Expression $Expression.Right -Assignments $Assignments -BeforeLine $BeforeLine -Depth ($Depth + 1)
        if ($null -eq $right)
        {
            return $null
        }
        if ($null -eq $left)
        {
            # The left side is the tenant specific service root, which carries no route segments.
            return $right
        }
        return $left + $right
    }

    if ($Expression -is [System.Management.Automation.Language.VariableExpressionAst])
    {
        $name = $Expression.VariablePath.UserPath
        if (-not $Assignments.ContainsKey($name))
        {
            return $null
        }

        $candidate = @($Assignments[$name] |
                Where-Object -FilterScript { $_.Extent.StartLineNumber -lt $BeforeLine } |
                Sort-Object -Property { $_.Extent.StartLineNumber } |
                Select-Object -Last 1)
        if ($candidate.Count -eq 0)
        {
            return $null
        }

        return Resolve-RawGraphUriText -Expression $candidate[0].Right -Assignments $Assignments -BeforeLine $BeforeLine -Depth ($Depth + 1)
    }

    return $null
}

<#
.SYNOPSIS
    Turns a URI into the route template form the cmdlet mapping uses.

.DESCRIPTION
    Query strings are dropped, the service root is stripped and every segment carrying a
    PowerShell expression or a bare identifier becomes the {id} placeholder.

.PARAMETER Uri
    Specifies the URI text.

.OUTPUTS
    A hashtable with ApiVersion and Template, both empty when the URI carries no version prefix.
#>
function ConvertTo-RawGraphRoute
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Uri
    )

    $path = ($Uri -split '\?')[0]
    # The service root is resolved at runtime, either as a concatenation or as a leading
    # subexpression.
    $path = $path -replace '^\$\([^)]*\([^)]*\)[^)]*\)', ''
    $path = $path -replace '^\$\([^)]*\)', ''
    $path = $path -replace '^https?://[^/]+/', ''
    $path = $path.Trim('/')

    $segments = @($path -split '/' | Where-Object -FilterScript { $_ -ne '' })
    if ($segments.Count -eq 0)
    {
        return @{ ApiVersion = ''; Template = '' }
    }

    $apiVersion = ''
    if ($segments[0] -in @('beta', 'v1.0'))
    {
        $apiVersion = $segments[0]
        $segments = @($segments | Select-Object -Skip 1)
    }

    $template = @(foreach ($segment in $segments)
        {
            if ($segment.Contains('$') -or $segment -match '^[0-9a-fA-F]{8}-')
            {
                '{id}'
            }
            else
            {
                $segment
            }
        }) -join '/'

    return @{ ApiVersion = $apiVersion; Template = "/$template" }
}

<#
.SYNOPSIS
    Indexes the cmdlet mapping by HTTP method, API version and route template.

.PARAMETER Mapping
    Specifies the parsed cmdlet-mapping.json.
#>
function New-RawGraphRouteIndex
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Object]
        $Mapping
    )

    $index = [System.Collections.Hashtable]::new([System.StringComparer]::OrdinalIgnoreCase)
    foreach ($cmdletName in $Mapping.Keys)
    {
        $entry = $Mapping[$cmdletName]
        foreach ($variant in @($entry.Variants))
        {
            if ($null -eq $variant -or [System.String]::IsNullOrEmpty([System.String] $variant.URI))
            {
                continue
            }

            $apiVersion = [System.String] $variant.ApiVersion
            if ([System.String]::IsNullOrEmpty($apiVersion))
            {
                $apiVersion = [System.String] $entry.ApiVersion
            }

            $template = [regex]::Replace([System.String] $variant.URI, '\{[^}]+\}', '{id}')
            $key = "$([System.String] $variant.Method) $apiVersion $template"
            if (-not $index.ContainsKey($key))
            {
                $index[$key] = @()
            }
            if ($cmdletName -notin $index[$key])
            {
                $index[$key] += $cmdletName
            }
        }
    }

    return $index
}

#region Main

if ([System.String]::IsNullOrEmpty($ResourcePath))
{
    $ResourcePath = Join-Path -Path $RepositoryRoot -ChildPath 'Modules/Microsoft365DSC/DscResources'
}
if ([System.String]::IsNullOrEmpty($CmdletMappingPath))
{
    $CmdletMappingPath = Join-Path -Path $RepositoryRoot -ChildPath 'Utilities/cmdlet-mapping.json'
}
if ([System.String]::IsNullOrEmpty($ShimManifestPath))
{
    $ShimManifestPath = Join-Path -Path $RepositoryRoot -ChildPath 'Modules/Microsoft365DSC/Modules/M365DSCGraphShim.psd1'
}
if ([System.String]::IsNullOrEmpty($OutputPath))
{
    $OutputPath = Join-Path -Path $RepositoryRoot -ChildPath 'Utilities/ApiSurface/rawgraph-shim-candidates.md'
}

$mapping = [System.IO.File]::ReadAllText($CmdletMappingPath) | ConvertFrom-Json -AsHashtable
$routeIndex = New-RawGraphRouteIndex -Mapping $mapping
$shimFunctions = @((Import-PowerShellDataFile -Path $ShimManifestPath).FunctionsToExport)

$candidates = @()
$uncovered = @()
$unresolved = @()

$folders = @(Get-ChildItem -Path $ResourcePath -Directory -Filter "MSFT_$ResourceFilter" | Sort-Object -Property Name)
foreach ($folder in $folders)
{
    $modulePath = Join-Path -Path $folder.FullName -ChildPath "$($folder.Name).psm1"
    if (-not (Test-Path -Path $modulePath))
    {
        continue
    }

    $resourceName = $folder.Name -replace '^MSFT_', ''

    $declaredCmdlets = @()
    $settingsPath = Join-Path -Path $folder.FullName -ChildPath 'settings.json'
    if (Test-Path -Path $settingsPath)
    {
        $settings = [System.IO.File]::ReadAllText($settingsPath) | ConvertFrom-Json -AsHashtable
        if ($settings.Contains('commands'))
        {
            $declaredCmdlets = @(foreach ($group in @($settings.commands)) { @($group.cmdlets) })
        }
    }

    $ast = [System.Management.Automation.Language.Parser]::ParseFile($modulePath, [ref] $null, [ref] $null)

    $assignments = @{}
    foreach ($assignment in @($ast.FindAll({ param($Item) $Item -is [System.Management.Automation.Language.AssignmentStatementAst] }, $true)))
    {
        $target = $assignment.Left
        if ($target -is [System.Management.Automation.Language.ConvertExpressionAst])
        {
            $target = $target.Child
        }
        if ($target -isnot [System.Management.Automation.Language.VariableExpressionAst])
        {
            continue
        }

        $name = $target.VariablePath.UserPath
        if (-not $assignments.ContainsKey($name))
        {
            $assignments[$name] = @()
        }
        $assignments[$name] += $assignment
    }

    $calls = @($ast.FindAll({
                param($Item)
                $Item -is [System.Management.Automation.Language.CommandAst] -and $Item.GetCommandName() -in $script:RawCommandNames
            }, $true))

    foreach ($call in $calls)
    {
        $elements = @($call.CommandElements)
        $uriExpression = $null
        $methodExpression = $null
        $positional = @()
        $skipNext = $false
        for ($i = 1; $i -lt $elements.Count; $i++)
        {
            if ($skipNext)
            {
                $skipNext = $false
                continue
            }

            $element = $elements[$i]
            if ($element -isnot [System.Management.Automation.Language.CommandParameterAst])
            {
                $positional += $element
                continue
            }

            $argument = $element.Argument
            if ($null -eq $argument -and ($i + 1) -lt $elements.Count)
            {
                $argument = $elements[$i + 1]
                $skipNext = $true
            }
            if ($null -eq $argument)
            {
                continue
            }

            if ($element.ParameterName -like 'Ur*')
            {
                $uriExpression = $argument
            }
            elseif ($element.ParameterName -like 'Me*')
            {
                $methodExpression = $argument
            }
        }

        foreach ($element in $positional)
        {
            if ($null -eq $methodExpression)
            {
                $methodExpression = $element
                continue
            }
            if ($null -eq $uriExpression)
            {
                $uriExpression = $element
            }
            break
        }

        $method = 'GET'
        if ($null -ne $methodExpression)
        {
            $methodText = Resolve-RawGraphUriText -Expression $methodExpression -Assignments $assignments -BeforeLine $call.Extent.StartLineNumber
            if (-not [System.String]::IsNullOrEmpty($methodText))
            {
                $method = $methodText.ToUpperInvariant()
            }
        }

        $row = [PSCustomObject]@{
            Resource = $resourceName
            Line     = $call.Extent.StartLineNumber
            Method   = $method
            Uri      = $null
            Route    = $null
            Cmdlets  = @()
        }

        if ($null -eq $uriExpression)
        {
            $unresolved += ($row | Select-Object -Property *, @{ Name = 'Note'; Expression = { 'The call passes no Uri parameter.' } })
            continue
        }

        $uriText = Resolve-RawGraphUriText -Expression $uriExpression -Assignments $assignments -BeforeLine $call.Extent.StartLineNumber
        if ([System.String]::IsNullOrEmpty($uriText))
        {
            $row.Uri = $uriExpression.Extent.Text
            $unresolved += ($row | Select-Object -Property *, @{ Name = 'Note'; Expression = { 'The URI is built from a value the parser cannot resolve.' } })
            continue
        }

        $row.Uri = $uriText
        $route = ConvertTo-RawGraphRoute -Uri $uriText
        if ([System.String]::IsNullOrEmpty($route.ApiVersion))
        {
            $unresolved += ($row | Select-Object -Property *, @{ Name = 'Note'; Expression = { 'The URI carries no v1.0 or beta prefix.' } })
            continue
        }

        $row.Route = "$($route.ApiVersion)$($route.Template)"
        $key = "$($row.Method) $($route.ApiVersion) $($route.Template)"
        $matched = @()
        if ($routeIndex.ContainsKey($key))
        {
            $matched = @($routeIndex[$key])
        }
        if ($matched.Count -eq 0)
        {
            $uncovered += $row
            continue
        }

        $row.Cmdlets = $matched
        $missing = @($matched | Where-Object -FilterScript { $_ -notin $declaredCmdlets })
        if ($missing.Count -eq 0)
        {
            continue
        }

        $candidates += ($row | Select-Object -Property *,
            @{ Name = 'Candidate'; Expression = { $missing -join ', ' } },
            @{ Name = 'InShim'; Expression = { @($missing | Where-Object { $_ -in $shimFunctions }).Count -eq $missing.Count } })
    }
}

$sdkByRoute = @{}
$sdkResolver = $null
if (-not $SkipSdkLookup)
{
    $sdkResolver = Get-Command -Name 'Find-MgGraphCommand' -ErrorAction SilentlyContinue
}
if ($null -eq $sdkResolver -and -not $SkipSdkLookup)
{
    Write-Warning -Message 'Find-MgGraphCommand is not available, so the uncovered routes are not resolved to a Graph SDK cmdlet.'
}
else
{
    foreach ($row in $uncovered)
    {
        $key = "$($row.Method) $($row.Route)"
        if ($sdkByRoute.ContainsKey($key))
        {
            continue
        }

        $apiVersion = ($row.Route -split '/', 2)[0]
        $template = '/' + ($row.Route -split '/', 2)[1]
        $found = @(Find-MgGraphCommand -Uri $template -ApiVersion $apiVersion -Method $row.Method -ErrorAction SilentlyContinue)
        $sdkByRoute[$key] = @($found | ForEach-Object -Process { $_.Command } | Sort-Object -Unique)
    }
}

$shimGaps = @()
$restOnly = @()
foreach ($row in $uncovered)
{
    $found = @($sdkByRoute["$($row.Method) $($row.Route)"])
    if ($found.Count -eq 0)
    {
        $restOnly += $row
        continue
    }
    $shimGaps += ($row | Select-Object -Property *, @{ Name = 'SdkCmdlet'; Expression = { $found -join ', ' }.GetNewClosure() })
}

$lines = @(
    '# Raw Graph calls a shim cmdlet could replace'
    ''
    'Generated by `Utilities/Find-M365DSCRawGraphCall.ps1`. Do not edit by hand: re-run the script.'
    ''
    'Every `Invoke-MgGraphRequest` call of a resource module is turned into a route template and'
    'matched against `Utilities/cmdlet-mapping.json`. A hit names a Graph SDK cmdlet the shim'
    'serves, or can serve once regenerated, and the resource can call it instead of the raw route.'
    ''
    "Candidates: $($candidates.Count). Shim gaps: $($shimGaps.Count). REST only: $($restOnly.Count). Unresolved call sites: $($unresolved.Count)."
    ''
    '## Candidates'
    ''
    'The shim already serves a cmdlet for the route and the resource does not call it yet.'
    ''
    '| Resource | Line | Method | Route | Cmdlet | In shim |'
    '| --- | --- | --- | --- | --- | --- |'
)
foreach ($row in @($candidates | Sort-Object -Property Resource, Line))
{
    $lines += "| $($row.Resource) | $($row.Line) | $($row.Method) | ``$($row.Route)`` | $($row.Candidate) | $(if ($row.InShim) { 'yes' } else { 'no' }) |"
}

$lines += @(
    ''
    '## Shim gaps'
    ''
    'A Graph SDK cmdlet serves the route but the mapping does not carry it, so the shim does not'
    'export it yet. Switching the resource to the cmdlet and regenerating the shim closes the gap.'
    ''
    '| Resource | Line | Method | Route | SDK cmdlet |'
    '| --- | --- | --- | --- | --- |'
)
foreach ($row in @($shimGaps | Sort-Object -Property Resource, Line))
{
    $lines += "| $($row.Resource) | $($row.Line) | $($row.Method) | ``$($row.Route)`` | $($row.SdkCmdlet) |"
}

$lines += @(
    ''
    '## REST only'
    ''
    'No Graph SDK cmdlet serves the route, so the raw call stays.'
    ''
    '| Resource | Line | Method | Route |'
    '| --- | --- | --- | --- |'
)
foreach ($row in @($restOnly | Sort-Object -Property Resource, Line))
{
    $lines += "| $($row.Resource) | $($row.Line) | $($row.Method) | ``$($row.Route)`` |"
}

$lines += @(
    ''
    '## Unresolved call sites'
    ''
    'The URI could not be derived statically. Resolve by hand, or leave the call as it is.'
    ''
    '| Resource | Line | Method | Expression | Reason |'
    '| --- | --- | --- | --- | --- |'
)
foreach ($row in @($unresolved | Sort-Object -Property Resource, Line))
{
    $expression = ([System.String] $row.Uri).Replace('|', '/').Replace("`r", ' ').Replace("`n", ' ')
    $lines += "| $($row.Resource) | $($row.Line) | $($row.Method) | ``$expression`` | $($row.Note) |"
}

$outputFolder = Split-Path -Path $OutputPath -Parent
if (-not (Test-Path -Path $outputFolder))
{
    $null = New-Item -Path $outputFolder -ItemType Directory -Force
}
[System.IO.File]::WriteAllText($OutputPath, (($lines -join "`r`n") + "`r`n"), [System.Text.UTF8Encoding]::new($false))
Write-Host -Object "Wrote $($candidates.Count) candidates, $($shimGaps.Count) shim gaps, $($restOnly.Count) REST only routes and $($unresolved.Count) unresolved call sites to $OutputPath."

[PSCustomObject]@{
    Candidates = $candidates
    ShimGaps   = $shimGaps
    RestOnly   = $restOnly
    Unresolved = $unresolved
}

#endregion
