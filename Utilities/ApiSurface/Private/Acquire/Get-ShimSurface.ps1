<#
.SYNOPSIS
    Captures the routes and parameters the generated Graph shim exposes.

.DESCRIPTION
    Parses M365DSCGraphShim.psm1 with the PowerShell parser. The file is over fifty thousand lines
    and importing it loads the whole Graph request stack. The manifest names the public functions.
    Four internal helpers do not carry the shim prefix the other five do.

.PARAMETER ModulePath
    Specifies the path of M365DSCGraphShim.psm1.

.PARAMETER ManifestPath
    Specifies the path of M365DSCGraphShim.psd1.

.OUTPUTS
    A hashtable with Shim, an ordered map, and Unparsed, the exported names the parser could not
    resolve a route for.
#>
function Get-ShimSurface
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $ModulePath,

        [Parameter(Mandatory = $true)]
        [System.String]
        $ManifestPath
    )

    $tokens = $null
    $errors = $null
    $ast = [System.Management.Automation.Language.Parser]::ParseFile($ModulePath, [ref] $tokens, [ref] $errors)

    if ($errors.Count -gt 0)
    {
        throw "Parsing '$ModulePath' produced $($errors.Count) error(s). The first one is: $($errors[0].Message)"
    }

    $manifest = Import-PowerShellDataFile -Path $ManifestPath
    $exported = [System.Collections.Generic.HashSet[System.String]]::new(
        [System.String[]] @($manifest.FunctionsToExport), [System.StringComparer]::OrdinalIgnoreCase)

    $functions = $ast.FindAll({
            param($node) $node -is [System.Management.Automation.Language.FunctionDefinitionAst]
        }, $false)

    $shim = @{}
    $unparsed = [System.Collections.Generic.List[System.String]]::new()

    foreach ($function in $functions)
    {
        if (-not $exported.Contains($function.Name))
        {
            continue
        }

        $route = Get-ShimFunctionRoute -Function $function
        if ($null -eq $route)
        {
            $unparsed.Add($function.Name)
            continue
        }

        $shim[$function.Name] = $route
    }

    foreach ($name in @($manifest.FunctionsToExport))
    {
        if (-not $shim.ContainsKey($name) -and $name -notin $unparsed)
        {
            $unparsed.Add($name)
        }
    }

    return @{
        Shim     = ConvertTo-M365DSCOrderedMap -Map $shim
        Unparsed = Get-M365DSCOrderedName -Value ([System.String[]] $unparsed)
    }
}

<#
.SYNOPSIS
    Reads the route, the method and the parameters of one generated shim function.

.PARAMETER Function
    Specifies the function definition node.

.OUTPUTS
    An ordered dictionary describing the route, or $null when no helper call was found.
#>
function Get-ShimFunctionRoute
{
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.Language.FunctionDefinitionAst]
        $Function
    )

    $calls = @($Function.Body.FindAll({
                param($node) $node -is [System.Management.Automation.Language.CommandAst]
            }, $true) | Where-Object -FilterScript { $_.GetCommandName() -like 'Invoke-M365DSCGraphShim*Resource' })

    if ($calls.Count -eq 0)
    {
        return $null
    }

    $call = $calls[0]
    $helper = $call.GetCommandName()
    $arguments = Get-CommandArgumentMap -Command $call

    $method = $null
    if ($null -ne $arguments['Method'])
    {
        $method = [System.String] $arguments['Method'].Value
    }
    elseif ($helper -eq 'Invoke-M365DSCGraphShimGetResource')
    {
        $method = 'GET'
    }
    elseif ($helper -eq 'Invoke-M365DSCGraphShimDeleteResource')
    {
        $method = 'DELETE'
    }

    $collection = Resolve-ShimRouteArgument -Function $Function -Argument $arguments['CollectionUri']
    if ($null -eq $collection)
    {
        $collection = Resolve-ShimRouteArgument -Function $Function -Argument $arguments['Uri']
    }

    $item = Resolve-ShimRouteArgument -Function $Function -Argument $arguments['SingleItemUri']

    if ($null -eq $collection -and $null -eq $item)
    {
        return $null
    }

    $apiVersion = $null
    foreach ($candidate in @($collection, $item))
    {
        if ($null -ne $candidate)
        {
            $apiVersion = $candidate.ApiVersion
            break
        }
    }

    $parameters = @()
    if ($null -ne $Function.Body.ParamBlock)
    {
        foreach ($parameter in $Function.Body.ParamBlock.Parameters)
        {
            $parameters += $parameter.Name.VariablePath.UserPath
        }
    }

    $collectionUri = $null
    if ($null -ne $collection)
    {
        $collectionUri = $collection.Uri
    }

    $itemUri = $null
    if ($null -ne $item)
    {
        $itemUri = $item.Uri
    }

    return [ordered]@{
        helper     = $helper
        method     = $method
        apiVersion = $apiVersion
        uri        = $collectionUri
        itemUri    = $itemUri
        parameters = @(Get-M365DSCOrderedName -Value ([System.String[]] $parameters))
    }
}

<#
.SYNOPSIS
    Maps the named arguments of a command call to their argument nodes.

.PARAMETER Command
    Specifies the command node.

.OUTPUTS
    A map of parameter name to argument node.
#>
function Get-CommandArgumentMap
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.Language.CommandAst]
        $Command
    )

    $map = [System.Collections.Hashtable]::new([System.StringComparer]::OrdinalIgnoreCase)

    for ($index = 0; $index -lt $Command.CommandElements.Count - 1; $index++)
    {
        $element = $Command.CommandElements[$index]
        if ($element -isnot [System.Management.Automation.Language.CommandParameterAst])
        {
            continue
        }

        $map[$element.ParameterName] = $Command.CommandElements[$index + 1]
    }

    return $map
}

<#
.SYNOPSIS
    Turns a route argument into its version and its parameter template.

.DESCRIPTION
    A route reaches the helper as a string or as the local a Get wrapper assigned it to. It is the
    only string in scope that starts with an API version segment. The recorded route drops that
    segment and puts every interpolated value in braces, the form the SDK metadata declares.

.PARAMETER Function
    Specifies the function definition node the argument belongs to.

.PARAMETER Argument
    Specifies the argument node.

.OUTPUTS
    A hashtable with ApiVersion and Uri, or $null.
#>
function Resolve-ShimRouteArgument
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.Language.FunctionDefinitionAst]
        $Function,

        [Parameter()]
        [AllowNull()]
        [System.Object]
        $Argument
    )

    if ($null -eq $Argument)
    {
        return $null
    }

    $raw = $null

    if ($Argument -is [System.Management.Automation.Language.StringConstantExpressionAst] -or
        $Argument -is [System.Management.Automation.Language.ExpandableStringExpressionAst])
    {
        $raw = $Argument.Value
    }
    elseif ($Argument -is [System.Management.Automation.Language.VariableExpressionAst])
    {
        $variableName = $Argument.VariablePath.UserPath
        $assignments = @($Function.Body.FindAll({
                    param($node) $node -is [System.Management.Automation.Language.AssignmentStatementAst]
                }, $true) | Where-Object -FilterScript {
                $_.Left -is [System.Management.Automation.Language.VariableExpressionAst] -and
                $_.Left.VariablePath.UserPath -eq $variableName
            })

        foreach ($assignment in $assignments)
        {
            $strings = @($assignment.Right.FindAll({
                        param($node)
                        ($node -is [System.Management.Automation.Language.StringConstantExpressionAst]) -or
                        ($node -is [System.Management.Automation.Language.ExpandableStringExpressionAst])
                    }, $true) | Where-Object -FilterScript { $_.Value -match '^/(v1\.0|beta)/' })

            if ($strings.Count -gt 0)
            {
                $raw = $strings[0].Value
                break
            }
        }
    }

    if ([System.String]::IsNullOrEmpty($raw) -or $raw -notmatch '^/(v1\.0|beta)/')
    {
        return $null
    }

    $apiVersion = $Matches[1]
    $uri = $raw.Substring($apiVersion.Length + 1)

    # $ref is a literal OData segment, not an interpolated variable.
    $uri = $uri -replace '\$\(\$([A-Za-z_][A-Za-z0-9_]*)\)', '{$1}'
    $uri = $uri -replace '\$(?!ref\b)([A-Za-z_][A-Za-z0-9_]*)', '{$1}'

    return @{
        ApiVersion = $apiVersion
        Uri        = $uri
    }
}
