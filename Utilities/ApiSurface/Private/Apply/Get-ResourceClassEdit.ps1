<#
.SYNOPSIS
    Parses a resource module and returns the anchors an applier needs.

.DESCRIPTION
    Shipped resources keep their MOF era property order. A new declaration anchors on the terminal
    groups: Ensure, then the workload auth block, then the export-only members. Get() has a second
    AsResult call for the null result, told apart by the auth keys the real one carries.

.PARAMETER Path
    Specifies the resource module.

.OUTPUTS
    An ordered dictionary with the path, the text, the class, its DscProperty members, the
    insertion offset and the result hashtable.
#>
function Get-ResourceClassEdit
{
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Path
    )

    $text = [System.IO.File]::ReadAllText($Path)
    $ast = Get-ResourceAst -Path $Path

    # A resource module also declares its embedded CIM classes. Only one carries DscResource.
    $class = @($ast.FindAll({ $args[0] -is [System.Management.Automation.Language.TypeDefinitionAst] }, $true) |
            Where-Object -FilterScript { $_.IsClass -and @($_.Attributes.TypeName.Name) -contains 'DscResource' })[0]

    if ($null -eq $class)
    {
        throw "'$Path' declares no [DscResource()] class."
    }

    $property = [System.Collections.Specialized.OrderedDictionary]::new([System.StringComparer]::OrdinalIgnoreCase)
    foreach ($member in $class.Members)
    {
        if ($member -isnot [System.Management.Automation.Language.PropertyMemberAst])
        {
            continue
        }

        if (@($member.Attributes.TypeName.Name) -notcontains 'DscProperty')
        {
            continue
        }

        $property[$member.Name] = $member
    }

    return [ordered]@{
        Path            = $Path
        Text            = $text
        Class           = $class
        ClassName       = $class.Name
        Property        = $property
        InsertOffset    = Get-PropertyInsertOffset -Property $property
        ResultHashtable = Get-ResultHashtable -Class $class
    }
}

<#
.SYNOPSIS
    Returns every DSC property a resource module declares, across all of its classes.

.PARAMETER Path
    Specifies the resource module.

.OUTPUTS
    A case-insensitive set of property names.
#>
function Get-ResourceDeclaredProperty
{
    [CmdletBinding()]
    [OutputType([System.Collections.Generic.HashSet[System.String]])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Path
    )

    $names = [System.Collections.Generic.HashSet[System.String]]::new([System.StringComparer]::OrdinalIgnoreCase)
    $ast = Get-ResourceAst -Path $Path

    foreach ($class in $ast.FindAll({ $args[0] -is [System.Management.Automation.Language.TypeDefinitionAst] }, $true))
    {
        if (-not $class.IsClass)
        {
            continue
        }

        foreach ($member in $class.Members)
        {
            if ($member -isnot [System.Management.Automation.Language.PropertyMemberAst])
            {
                continue
            }

            if (@($member.Attributes.TypeName.Name) -notcontains 'DscProperty')
            {
                continue
            }

            $null = $names.Add($member.Name)
        }
    }

    return , $names
}

<#
.SYNOPSIS
    Parses a resource module from disk.

.DESCRIPTION
    ParseFile, never ParseInput. A resource opens with 'using module ..\_Base\M365DSCResourceBase.psm1'
    and the base type only resolves relative to the file.

.PARAMETER Path
    Specifies the resource module.

.OUTPUTS
    The script AST.
#>
function Get-ResourceAst
{
    [CmdletBinding()]
    [OutputType([System.Object])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Path
    )

    $parseErrors = $null
    $ast = [System.Management.Automation.Language.Parser]::ParseFile(
        (Resolve-Path -Path $Path).Path, [ref] $null, [ref] $parseErrors)

    if ($parseErrors.Count -gt 0)
    {
        throw "'$Path' does not parse: $($parseErrors[0].Message)"
    }

    return $ast
}

<#
.SYNOPSIS
    Returns the offset a new declaration is inserted at.

.DESCRIPTION
    The offset points at the start of the anchor member's first attribute, not at the property
    name.

.PARAMETER Property
    Specifies the DscProperty members, keyed by name.

.OUTPUTS
    The offset, or -1 when neither anchor is present.
#>
function Get-PropertyInsertOffset
{
    [CmdletBinding()]
    [OutputType([System.Int32])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Collections.IDictionary]
        $Property
    )

    foreach ($name in @('Ensure', 'Credential', 'ApplicationId', 'AccessTokens'))
    {
        if ($Property.Contains($name))
        {
            return $Property[$name].Extent.StartOffset
        }
    }

    return -1
}

<#
.SYNOPSIS
    Returns the hashtable Get() hands to AsResult.

.PARAMETER Class
    Specifies the resource class.

.OUTPUTS
    The HashtableAst, or null when it is absent or ambiguous.
#>
function Get-ResultHashtable
{
    [CmdletBinding()]
    [OutputType([System.Object])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Object]
        $Class
    )

    $get = @($Class.Members | Where-Object -FilterScript {
            $_ -is [System.Management.Automation.Language.FunctionMemberAst] -and $_.Name -eq 'Get'
        })[0]

    if ($null -eq $get)
    {
        return $null
    }

    $calls = @($get.Body.FindAll({
                $args[0] -is [System.Management.Automation.Language.InvokeMemberExpressionAst] -and
                $args[0].Member.Value -eq 'AsResult'
            }, $true))

    $matched = [System.Collections.Generic.List[System.Object]]::new()

    foreach ($call in $calls)
    {
        $hashtable = Resolve-HashtableArgument -Body $get.Body -Argument (@($call.Arguments)[0])
        if ($null -eq $hashtable)
        {
            continue
        }

        $keys = @($hashtable.KeyValuePairs.Item1.Extent.Text)
        if (($keys -contains 'Credential') -or ($keys -contains 'AccessTokens') -or ($keys -contains 'ApplicationId'))
        {
            $matched.Add($hashtable)
        }
    }

    $distinct = @($matched | Sort-Object -Property { $_.Extent.StartOffset } -Unique)
    if ($distinct.Count -eq 1)
    {
        return $distinct[0]
    }

    return $null
}

<#
.SYNOPSIS
    Resolves an AsResult argument to a hashtable literal.

.PARAMETER Body
    Specifies the body of Get().

.PARAMETER Argument
    Specifies the argument expression.

.OUTPUTS
    The HashtableAst, or null.
#>
function Resolve-HashtableArgument
{
    [CmdletBinding()]
    [OutputType([System.Object])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Object]
        $Body,

        [Parameter()]
        [AllowNull()]
        [System.Object]
        $Argument
    )

    if ($Argument -is [System.Management.Automation.Language.HashtableAst])
    {
        return $Argument
    }

    if ($Argument -isnot [System.Management.Automation.Language.VariableExpressionAst])
    {
        return $null
    }

    $name = $Argument.VariablePath.UserPath
    $assignments = @($Body.FindAll({
                $args[0] -is [System.Management.Automation.Language.AssignmentStatementAst] -and
                $args[0].Left -is [System.Management.Automation.Language.VariableExpressionAst] -and
                $args[0].Left.VariablePath.UserPath -eq $name -and
                $args[0].Right.Expression -is [System.Management.Automation.Language.HashtableAst]
            }, $true))

    if ($assignments.Count -eq 0)
    {
        return $null
    }

    return $assignments[-1].Right.Expression
}

<#
.SYNOPSIS
    Returns the ValidateSet attribute of a property.

.PARAMETER Member
    Specifies the property member.

.OUTPUTS
    The AttributeAst, or null.
#>
function Get-ValidateSetAttribute
{
    [CmdletBinding()]
    [OutputType([System.Object])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Object]
        $Member
    )

    return @($Member.Attributes | Where-Object -FilterScript { $_.TypeName.Name -eq 'ValidateSet' })[0]
}
