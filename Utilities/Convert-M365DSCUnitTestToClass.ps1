#Requires -Version 5.1

<#
.SYNOPSIS
    Converts a Microsoft365DSC unit test from the script-based shape to the class-based one.

.DESCRIPTION
    Two transformations, both AST-driven.

    1. Resource invocation. There are no *-TargetResource functions any more, so the four call sites
       go through the exported factory. A type literal cannot be used: the classes live in nested
       Classes/Part<NN>.psm1 modules and are not resolvable from the test's scope.

           Get-TargetResource    @p  ->  (New-M365DSCResourceInstance ... -Property $p).Get().ToHashtable()
           Set-TargetResource    @p  ->  (New-M365DSCResourceInstance ... -Property $p).Set()
           Test-TargetResource   @p  ->  (New-M365DSCResourceInstance ... -Property $p).Test()
           Export-TargetResource @p  ->  Invoke-M365DSCResourceMethod ... -MethodName 'Export' -Parameters $p

       Get() returns the resource type; .ToHashtable() keeps the existing assertions working, since
       they index into the result like a hashtable.

    2. Mock scope. Pester scopes a mock to a module, and a mock does not reach a class method
       executing in a different module: the call returns the real value and Should -Invoke counts
       zero.

       UnitTestHelper.psm1 reports the resource's part module, so mocks default to where the
       resource body runs. Commands reached through a base-class method execute in _Shared instead
       and get an explicit -ModuleName.

    Files already carrying the class-based shape are skipped, so the script is safe to re-run.

.PARAMETER TestName
    Resource name to convert, e.g. 'AADGroup'. Accepts wildcards. Omit for all.

.PARAMETER RepositoryRoot
    Root of the Microsoft365DSC repository.

.PARAMETER OutputPath
    Where to write converted tests. Defaults to updating them in place.

.PARAMETER ReportPath
    Where to write the JSON conversion report.

.EXAMPLE
    .\Convert-M365DSCUnitTestToClass.ps1 -TestName AADAttributeSet -OutputPath D:\out

.EXAMPLE
    .\Convert-M365DSCUnitTestToClass.ps1 -WhatIf

.OUTPUTS
    System.Collections.Hashtable
#>

using namespace System.Management.Automation.Language

[CmdletBinding(SupportsShouldProcess)]
param
(
    [Parameter()]
    [System.String[]]
    $TestName,

    [Parameter()]
    [System.String]
    $RepositoryRoot = (Split-Path -Path $PSScriptRoot -Parent),

    [Parameter()]
    [System.String]
    $OutputPath,

    [Parameter()]
    [System.String]
    $ReportPath
)

$ErrorActionPreference = 'Stop'

$script:TestRoot = Join-Path -Path $RepositoryRoot -ChildPath 'Tests/Unit/Microsoft365DSC'
$script:ResourceRoot = Join-Path -Path $RepositoryRoot -ChildPath 'Modules/Microsoft365DSC/DscResources'
$script:SchemaPath = Join-Path -Path $RepositoryRoot -ChildPath 'Modules/Microsoft365DSC/SchemaDefinition.json'
$script:SchemaLookup = $null
$script:ClassRoot = Join-Path -Path $RepositoryRoot -ChildPath 'Modules/Microsoft365DSC/Classes'
$script:ClassMembers = $null

<#
.SYNOPSIS
    Returns class name -> the set of members it accepts, inherited members included.

.DESCRIPTION
    Read from the built Classes/_Types<NN>.psm1 rather than SchemaDefinition.json: that is what the
    cast has to satisfy, and it is the only source carrying the inheritance chain. Used to strip
    members the test passes that the class does not declare.
#>
function Get-ClassMemberLookup
{
    if ($null -ne $script:ClassMembers)
    {
        return $script:ClassMembers
    }

    $script:ClassMembers = @{}

    if (-not (Test-Path -Path $script:ClassRoot))
    {
        return $script:ClassMembers
    }

    $own = @{}
    $base = @{}

    foreach ($file in (Get-ChildItem -Path $script:ClassRoot -Filter '_Types*.psm1'))
    {
        $ast = [Parser]::ParseFile($file.FullName, [ref] $null, [ref] $null)

        foreach ($type in $ast.FindAll({ $args[0] -is [TypeDefinitionAst] -and $args[0].IsClass }, $false))
        {
            $own[$type.Name] = @($type.Members | Where-Object { $_ -is [PropertyMemberAst] } | ForEach-Object { $_.Name })
            if ($type.BaseTypes.Count -gt 0)
            {
                $base[$type.Name] = $type.BaseTypes[0].TypeName.Name
            }
        }
    }

    foreach ($name in $own.Keys)
    {
        $members = [System.Collections.Generic.HashSet[String]]::new([StringComparer]::OrdinalIgnoreCase)
        $current = $name
        $guard = 0

        while (-not [String]::IsNullOrEmpty($current) -and $own.ContainsKey($current) -and $guard -lt 20)
        {
            foreach ($member in $own[$current]) { $null = $members.Add($member) }
            $current = $base[$current]
            $guard++
        }

        $script:ClassMembers[$name] = $members
    }

    return $script:ClassMembers
}

<#
.SYNOPSIS
    Returns ClassName -> (property -> CIM type) for every class in SchemaDefinition.json.

.DESCRIPTION
    Resolves what type a complex value is declared as, rather than trusting the -ClassName the test
    names. The two disagree in a fair number of suites; nothing checked before, because
    New-CimInstance -ClientOnly does not validate the class name. A class-typed property does.
#>
function Get-TestSchemaLookup
{
    if ($null -ne $script:SchemaLookup)
    {
        return $script:SchemaLookup
    }

    $script:SchemaLookup = @{}

    if (-not (Test-Path -Path $script:SchemaPath))
    {
        return $script:SchemaLookup
    }

    foreach ($class in (Get-Content -Path $script:SchemaPath -Raw | ConvertFrom-Json))
    {
        $properties = @{}
        foreach ($parameter in $class.Parameters)
        {
            $properties[$parameter.Name] = $parameter.CIMType
        }

        $script:SchemaLookup[$class.ClassName] = $properties
    }

    return $script:SchemaLookup
}

<#
.SYNOPSIS
    Resolves the declared complex type of the value a New-CimInstance call produces.

.DESCRIPTION
    Walks outwards: the hashtable key this call sits under names a property, and the owner of that
    property is either the enclosing New-CimInstance - resolved by recursion - or, when there is
    none, the resource itself. Returns $null when any link cannot be resolved, in which case the
    caller keeps the -ClassName it was given.
#>
function Resolve-CimTargetType
{
    param
    (
        [Parameter(Mandatory = $true)]
        [CommandAst]
        $Call,

        [Parameter(Mandatory = $true)]
        [String]
        $ResourceName
    )

    $node = $Call
    $key = $null
    $owner = $null

    while ($null -ne $node.Parent -and $null -eq $key)
    {
        $node = $node.Parent

        if ($node -isnot [HashtableAst])
        {
            continue
        }

        foreach ($pair in $node.KeyValuePairs)
        {
            if ($pair.Item2.Extent.StartOffset -le $Call.Extent.StartOffset -and
                $pair.Item2.Extent.EndOffset -ge $Call.Extent.EndOffset)
            {
                $key = $pair.Item1
                $owner = $node
            }
        }
    }

    if ($null -eq $key)
    {
        return $null
    }

    $keyName = if ($key -is [StringConstantExpressionAst]) { $key.Value } else { $key.Extent.Text.Trim("'`"") }

    $enclosing = $owner.Parent
    while ($null -ne $enclosing -and
        -not ($enclosing -is [CommandAst] -and $enclosing.GetCommandName() -eq 'New-CimInstance'))
    {
        $enclosing = $enclosing.Parent
    }

    $ownerType = if ($null -eq $enclosing)
    {
        "MSFT_$ResourceName"
    }
    else
    {
        Resolve-CimTargetType -Call $enclosing -ResourceName $ResourceName
    }

    if ([String]::IsNullOrEmpty($ownerType))
    {
        return $null
    }

    $schema = Get-TestSchemaLookup
    if (-not $schema.ContainsKey($ownerType) -or -not $schema[$ownerType].ContainsKey($keyName))
    {
        return $null
    }

    # MSFT_Credential is spelled like a complex type but maps to [PSCredential]; no class of that
    # name exists, so casting to it fails with "Unable to find type [MSFT_Credential]".
    $cimType = $schema[$ownerType][$keyName] -replace '\[\]$', ''
    if ($cimType -notlike 'MSFT_*' -or $cimType -eq 'MSFT_Credential')
    {
        return $null
    }

    return $cimType
}

if (-not $ReportPath)
{
    $ReportPath = Join-Path -Path $PSScriptRoot -ChildPath 'UnitTestConversionReport.json'
}

<#
    Commands the resource body reaches through a method on M365DSCResourceBase, which is declared in
    _Shared.psm1 and therefore executes there rather than in the resource's part module.

      New-M365DSCConnection            <- Connect()
      Format-M365DSCTelemetryParameters, Add-M365DSCTelemetryEvent <- AddTelemetry()
      New-M365DSCLogEntry              <- LogError()
      Test-M365DSCTargetResource       <- the inherited Test()

    Everything else is invoked directly from the class method and is already covered by the
    surrounding InModuleScope.
#>
$script:SharedScopeCommand = @(
    'New-M365DSCConnection',
    'Format-M365DSCTelemetryParameters',
    'Add-M365DSCTelemetryEvent',
    'New-M365DSCLogEntry',
    'Test-M365DSCTargetResource'
)

class TestEdit
{
    [int] $Offset
    [int] $Length
    [string] $Text
    [string] $Reason
}

<#
.SYNOPSIS
    Reads the helper renames a converted resource carries.

.DESCRIPTION
    Private helpers are renamed with a resource-specific prefix during conversion, and tests that
    call one directly have to follow the rename.

    The map is read back out of the converted resource rather than recomputed, so the two cannot
    drift. Convert-M365DSCResourceToClass.ps1 emits a '# Was <original>.' comment above each renamed
    declaration for this purpose.

.PARAMETER ResourceName
    Specifies the resource name, e.g. 'AADPermissionGrantPolicy'.

.EXAMPLE
    Get-HelperRenameMap -ResourceName 'AADPermissionGrantPolicy'

.FUNCTIONALITY
    Internal

.OUTPUTS
    System.Collections.Hashtable
#>
function Get-HelperRenameMap
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $ResourceName
    )

    $map = @{}
    $path = Join-Path -Path $script:ResourceRoot -ChildPath "MSFT_$ResourceName/MSFT_$ResourceName.psm1"

    if (-not (Test-Path -Path $path))
    {
        return $map
    }

    $text = Get-Content -Path $path -Raw
    foreach ($match in [regex]::Matches($text, '#\s*Was\s+(?<old>[^\s.]+)\.\s*Renamed[^\r\n]*\r?\n[^\r\n]*\r?\nfunction\s+(?<new>[^\s\r\n{]+)'))
    {
        $map[$match.Groups['old'].Value] = $match.Groups['new'].Value
    }

    return $map
}

<#
.SYNOPSIS
    Renders a call site's named parameters as a hashtable literal.

.DESCRIPTION
    -Property takes a hashtable, so a call passing its parameters by name has to be rewritten into
    one. Argument text is lifted verbatim from the source extent, keeping subexpressions, quoting
    style and nested hashtables intact.

    Returns $null when the call cannot be expressed that way - a positional argument or an unbound
    trailing parameter - so the caller can leave it for review.

.PARAMETER Command
    The CommandAst to render.

.EXAMPLE
    ConvertTo-PropertyHashtableLiteral -Command $ast

.FUNCTIONALITY
    Internal

.OUTPUTS
    System.String
#>
function ConvertTo-PropertyHashtableLiteral
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter(Mandatory = $true)]
        [CommandAst]
        $Command
    )

    $pairs = [System.Collections.Generic.List[String]]::new()
    $elements = @($Command.CommandElements)

    for ($i = 1; $i -lt $elements.Count; $i++)
    {
        $element = $elements[$i]
        if ($element -isnot [CommandParameterAst])
        {
            return $null
        }

        if ($null -ne $element.Argument)
        {
            $pairs.Add("$($element.ParameterName) = $($element.Argument.Extent.Text)")
            continue
        }

        if (($i + 1) -ge $elements.Count -or $elements[$i + 1] -is [CommandParameterAst])
        {
            return $null
        }

        $pairs.Add("$($element.ParameterName) = $($elements[$i + 1].Extent.Text)")
        $i++
    }

    if ($pairs.Count -eq 0)
    {
        return $null
    }

    return '@{ ' + ($pairs -join '; ') + ' }'
}

function Convert-UnitTest
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Path,

        [Parameter(Mandatory = $true)]
        [System.String]
        $ResourceName
    )

    $text = Get-Content -Path $Path -Raw
    $notes = [System.Collections.Generic.List[String]]::new()

    $errors = $null
    $ast = [Parser]::ParseInput($text, [ref] $null, [ref] $errors)
    if ($errors.Count -gt 0)
    {
        throw "Cannot parse '$Path': $($errors[0].Message) (line $($errors[0].Extent.StartLineNumber))"
    }

    $edits = [System.Collections.Generic.List[TestEdit]]::new()
    $helperRename = Get-HelperRenameMap -ResourceName $ResourceName

    $methodByCommand = @{
        'Get-TargetResource'    = 'Get'
        'Set-TargetResource'    = 'Set'
        'Test-TargetResource'   = 'Test'
        'Export-TargetResource' = 'Export'
    }

    foreach ($command in $ast.FindAll({ $args[0] -is [CommandAst] }, $true))
    {
        $name = $command.GetCommandName()
        if ([String]::IsNullOrEmpty($name))
        {
            continue
        }

        # --- resource invocation ------------------------------------------------------------
        if ($methodByCommand.ContainsKey($name))
        {
            $splatted = @($command.CommandElements |
                    Where-Object { $_ -is [VariableExpressionAst] -and $_.Splatted })

            if ($splatted.Count -eq 1)
            {
                $parameterVariable = '$' + $splatted[0].VariablePath.UserPath
            }
            else
            {
                # Call sites that pass parameters by name rather than splatting become an inline
                # hashtable.
                $parameterVariable = ConvertTo-PropertyHashtableLiteral -Command $command

                if ($null -eq $parameterVariable)
                {
                    $notes.Add(("{0} at line {1} neither splats one variable nor passes named parameters only; left for review." -f
                            $name, $command.Extent.StartLineNumber))
                    continue
                }
            }

            $method = $methodByCommand[$name]

            $replacement = if ($method -eq 'Export')
            {
                "Invoke-M365DSCResourceMethod -ResourceName '$ResourceName' -MethodName 'Export' -Parameters $parameterVariable"
            }
            else
            {
                $call = "(New-M365DSCResourceInstance -ResourceName '$ResourceName' -Property $parameterVariable).$method()"

                # Get() returns the resource instance; the assertions treat the result as a hashtable.
                if ($method -eq 'Get')
                {
                    $call += '.ToHashtable()'
                }

                $call
            }

            $edit = [TestEdit]::new()
            $edit.Offset = $command.Extent.StartOffset
            $edit.Length = $command.Extent.EndOffset - $command.Extent.StartOffset
            $edit.Text = $replacement
            $edit.Reason = "$name -> $method()"
            $edits.Add($edit)

            continue
        }

        # --- helper rename ------------------------------------------------------------------
        # Direct calls to a private helper. Mocks of one are renamed in the mock pass below, where
        # the name sits in -CommandName rather than in the command position.
        if ($helperRename.ContainsKey($name))
        {
            $edit = [TestEdit]::new()
            $edit.Offset = $command.CommandElements[0].Extent.StartOffset
            $edit.Length = $command.CommandElements[0].Extent.EndOffset - $edit.Offset
            $edit.Text = $helperRename[$name]
            $edit.Reason = "helper rename $name"
            $edits.Add($edit)

            continue
        }

        # Get-CompareParameters became a method on the class rather than a function.
        if ($name -eq 'Get-CompareParameters')
        {
            $edit = [TestEdit]::new()
            $edit.Offset = $command.Extent.StartOffset
            $edit.Length = $command.Extent.EndOffset - $edit.Offset
            $edit.Text = "(New-M365DSCResourceInstance -ResourceName '$ResourceName').GetCompareParameters()"
            $edit.Reason = 'Get-CompareParameters -> GetCompareParameters()'
            $edits.Add($edit)

            continue
        }

        <#
            --- mock scope ---------------------------------------------------------------------
            Should -Invoke is treated exactly like Mock: it names a command in -CommandName and
            resolves it in the same scope, so both rewrites apply. Otherwise a mock placed in
            _Shared pairs with an assertion searching the ambient Part<NN>, which reports
            "Could not find Mock for command X in module Part<NN>".
        #>
        if ($name -ne 'Mock' -and $name -ne 'Should')
        {
            continue
        }

        if ($name -eq 'Should' -and
            -not @($command.CommandElements | Where-Object { $_ -is [CommandParameterAst] -and $_.ParameterName -eq 'Invoke' }))
        {
            continue
        }

        $mockedCommand = $null
        $mockedCommandArgument = $null
        $hasModuleName = $false

        for ($i = 0; $i -lt $command.CommandElements.Count; $i++)
        {
            $element = $command.CommandElements[$i]
            if ($element -isnot [CommandParameterAst])
            {
                continue
            }

            if ($element.ParameterName -eq 'ModuleName')
            {
                $hasModuleName = $true
            }
            elseif ($element.ParameterName -eq 'CommandName' -and ($i + 1) -lt $command.CommandElements.Count)
            {
                $argument = $command.CommandElements[$i + 1]
                if ($argument -is [StringConstantExpressionAst])
                {
                    $mockedCommand = $argument.Value
                    $mockedCommandArgument = $argument
                }
            }
        }

        if ($null -eq $mockedCommand)
        {
            continue
        }

        if ($helperRename.ContainsKey($mockedCommand))
        {
            $edit = [TestEdit]::new()
            $edit.Offset = $mockedCommandArgument.Extent.StartOffset
            $edit.Length = $mockedCommandArgument.Extent.EndOffset - $edit.Offset
            $edit.Text = $helperRename[$mockedCommand]
            $edit.Reason = "helper rename $mockedCommand"
            $edits.Add($edit)
        }

        if ($hasModuleName)
        {
            continue
        }

        if ($mockedCommand -notin $script:SharedScopeCommand)
        {
            continue
        }

        # Insert -ModuleName immediately after the command name so the mock lands in _Shared.
        $edit = [TestEdit]::new()
        $edit.Offset = $mockedCommandArgument.Extent.EndOffset
        $edit.Length = 0
        $edit.Text = " -ModuleName '_Shared'"
        $edit.Reason = "$mockedCommand is reached through a base-class method"
        $edits.Add($edit)
    }

    <#
        --- complex values -------------------------------------------------------------------
        A complex property is declared as a class, so the value has to be an instance of it.
        Assigning a CimInstance converts to $null and the property is silently dropped.

            (New-CimInstance -ClassName MSFT_X -Property @{ ... } -ClientOnly)  ->  ([MSFT_X] @{ ... })

        Two edits per call - before and after the -Property hashtable - rather than one
        replacement of the whole command, so that nested calls inside that hashtable keep their own
        edits in spans this one never touches.
    #>
    foreach ($command in $ast.FindAll({ $args[0] -is [CommandAst] }, $true))
    {
        if ($command.GetCommandName() -ne 'New-CimInstance')
        {
            continue
        }

        $className = $null
        $propertyValue = $null

        for ($i = 0; $i -lt $command.CommandElements.Count; $i++)
        {
            $element = $command.CommandElements[$i]
            if ($element -isnot [CommandParameterAst] -or $i + 1 -ge $command.CommandElements.Count)
            {
                continue
            }

            switch -Regex ($element.ParameterName)
            {
                '^Cl(a(s(s(N(a(m(e)?)?)?)?)?)?)?$' { $className = $command.CommandElements[$i + 1] }
                '^P(r(o(p(e(r(t(y)?)?)?)?)?)?)?$' { $propertyValue = $command.CommandElements[$i + 1] }
            }
        }

        if ($null -eq $propertyValue)
        {
            # -Property is positional in a handful of call sites.
            $propertyValue = @($command.CommandElements | Where-Object { $_ -is [HashtableAst] })[0]
        }

        if ($null -eq $className -or $className -isnot [StringConstantExpressionAst] -or
            $null -eq $propertyValue -or $propertyValue -isnot [HashtableAst])
        {
            $notes.Add(("New-CimInstance at line {0} does not pass a literal -ClassName and a -Property hashtable; left for review." -f
                    $command.Extent.StartLineNumber))
            continue
        }

        # No mechanical rewrite exists - a username/password hashtable is not a PSCredential - so
        # this is left alone and reported. The test data needs a real credential object.
        if ($className.Value -eq 'MSFT_Credential')
        {
            $notes.Add(("line {0}: New-CimInstance MSFT_Credential needs a real PSCredential in the class world; left for review." -f
                    $command.Extent.StartLineNumber))
            continue
        }

        # The declared type wins over the -ClassName the test names; see Resolve-CimTargetType.
        $targetType = Resolve-CimTargetType -Call $command -ResourceName $ResourceName
        if ([String]::IsNullOrEmpty($targetType))
        {
            $targetType = $className.Value
        }
        elseif ($targetType -ne $className.Value)
        {
            $notes.Add(("line {0}: -ClassName {1} but the property is declared {2}; emitted the declared type." -f
                    $command.Extent.StartLineNumber, $className.Value, $targetType))
        }

        $edit = [TestEdit]::new()
        $edit.Offset = $command.Extent.StartOffset
        $edit.Length = $propertyValue.Extent.StartOffset - $command.Extent.StartOffset
        $edit.Text = "[$targetType] "
        $edit.Reason = "New-CimInstance $($className.Value) -> [$targetType]"
        $edits.Add($edit)

        $edit = [TestEdit]::new()
        $edit.Offset = $propertyValue.Extent.EndOffset
        $edit.Length = $command.Extent.EndOffset - $propertyValue.Extent.EndOffset
        $edit.Text = ''
        $edit.Reason = 'drop -ClientOnly'
        $edits.Add($edit)

        <#
            Members the class does not declare are dropped - a cast rejects them with "The property
            'X' was not found", which takes the whole BeforeAll down with no Pester message.

            Only a pair occupying its own line is removed. Deleting one out of `@{ A = 1; B = 2 }`
            can leave a leading separator behind, which will not parse.
        #>
        $known = (Get-ClassMemberLookup)[$targetType]
        if ($null -ne $known)
        {
            foreach ($pair in $propertyValue.KeyValuePairs)
            {
                $memberName = if ($pair.Item1 -is [StringConstantExpressionAst]) { $pair.Item1.Value } else { $pair.Item1.Extent.Text.Trim("'`"") }
                if ($known.Contains($memberName))
                {
                    continue
                }

                $lineStart = $text.LastIndexOf("`n", $pair.Item1.Extent.StartOffset) + 1
                $lineEnd = $text.IndexOf("`n", $pair.Item2.Extent.EndOffset)
                if ($lineEnd -lt 0) { $lineEnd = $text.Length }

                $before = $text.Substring($lineStart, $pair.Item1.Extent.StartOffset - $lineStart)
                $after = $text.Substring($pair.Item2.Extent.EndOffset, $lineEnd - $pair.Item2.Extent.EndOffset)

                if ($before.Trim() -ne '' -or ($after -replace '[;\s]', '') -ne '')
                {
                    $notes.Add(("line {0}: '{1}' is not a member of {2} but shares its line; left for review." -f
                            $pair.Item1.Extent.StartLineNumber, $memberName, $targetType))
                    continue
                }

                $edit = [TestEdit]::new()
                $edit.Offset = $lineStart
                $edit.Length = ($lineEnd + 1) - $lineStart
                $edit.Text = ''
                $edit.Reason = "'$memberName' is not a member of $targetType"
                $edits.Add($edit)

                $notes.Add(("line {0}: dropped '{1}'; {2} does not declare it." -f
                        $pair.Item1.Extent.StartLineNumber, $memberName, $targetType))
            }
        }
    }

    # [CimInstance[]] casts around those arrays. The array coerces to [MSFT_X[]] on assignment, so
    # the constraint is dropped rather than rewritten - the element type is not always recoverable.
    foreach ($convert in $ast.FindAll({ $args[0] -is [ConvertExpressionAst] }, $true))
    {
        $typeName = $convert.Type.TypeName.FullName
        if ($typeName -ne 'CimInstance' -and $typeName -ne 'CimInstance[]')
        {
            continue
        }

        $edit = [TestEdit]::new()
        $edit.Offset = $convert.Type.Extent.StartOffset
        $edit.Length = $convert.Type.Extent.EndOffset - $convert.Type.Extent.StartOffset
        $edit.Text = ''
        $edit.Reason = "drop [$typeName] cast"
        $edits.Add($edit)
    }

    if ($edits.Count -eq 0)
    {
        return @{ Text = $text; Notes = $notes; EditCount = 0 }
    }

    foreach ($edit in ($edits | Sort-Object Offset -Descending))
    {
        $text = $text.Remove($edit.Offset, $edit.Length).Insert($edit.Offset, $edit.Text)
    }

    return @{ Text = $text; Notes = $notes; EditCount = $edits.Count }
}

#region Main

$candidates = @(Get-ChildItem -Path $script:TestRoot -Filter 'Microsoft365DSC.*.Tests.ps1' -File)

if ($TestName)
{
    $candidates = @($candidates | Where-Object {
            $resource = $_.Name -replace '^Microsoft365DSC\.', '' -replace '\.Tests\.ps1$', ''
            $matched = $false
            foreach ($pattern in $TestName)
            {
                if ($resource -like $pattern) { $matched = $true }
            }
            $matched
        })
}

Write-Host "[tests] $($candidates.Count) test file(s) selected" -ForegroundColor Cyan

$report = [System.Collections.Generic.List[Object]]::new()
$converted = 0

foreach ($candidate in $candidates)
{
    # The file name is only a hint - a few suites are named for a resource that does not exist under
    # that name. What the suite passes to New-M365DscUnitTestHelper is authoritative.
    $resourceName = $candidate.Name -replace '^Microsoft365DSC\.', '' -replace '\.Tests\.ps1$', ''
    $declared = [regex]::Match((Get-Content -Path $candidate.FullName -Raw), '-DscResource\s+[''"]([^''"]+)[''"]')
    if ($declared.Success)
    {
        $resourceName = $declared.Groups[1].Value
    }

    try
    {
        # Already converted - the script must be safe to re-run.
        if ((Get-Content -Path $candidate.FullName -Raw) -match 'New-M365DSCResourceInstance')
        {
            $report.Add([PSCustomObject] @{ Test = $resourceName; Status = 'AlreadyConverted'; Edits = 0; Notes = @() })
            continue
        }

        $result = Convert-UnitTest -Path $candidate.FullName -ResourceName $resourceName

        $parseErrors = $null
        $null = [Parser]::ParseInput($result.Text, [ref] $null, [ref] $parseErrors)

        $status = if ($parseErrors.Count -eq 0) { 'OK' } else { 'ParseError' }
        if ($status -eq 'OK') { $converted++ }

        $target = if ($OutputPath)
        {
            $null = New-Item -Path $OutputPath -ItemType Directory -Force -WhatIf:$false
            Join-Path -Path $OutputPath -ChildPath $candidate.Name
        }
        else
        {
            $candidate.FullName
        }

        if ($status -eq 'OK' -and $PSCmdlet.ShouldProcess($target, 'Write converted unit test'))
        {
            Set-Content -Path $target -Value $result.Text -Encoding UTF8
        }

        $report.Add([PSCustomObject] @{
                Test        = $resourceName
                Status      = $status
                Edits       = $result.EditCount
                ParseErrors = @($parseErrors | ForEach-Object { "$($_.ErrorId) line $($_.Extent.StartLineNumber): $($_.Message)" })
                Notes       = @($result.Notes)
            })

        $color = if ($status -eq 'OK') { 'Green' } else { 'Red' }
        Write-Host ("  {0,-55} {1} ({2} edits)" -f $resourceName, $status, $result.EditCount) -ForegroundColor $color
        foreach ($note in $result.Notes)
        {
            Write-Host "      note: $note" -ForegroundColor DarkGray
        }
    }
    catch
    {
        $report.Add([PSCustomObject] @{ Test = $resourceName; Status = 'Failed'; Edits = 0; Notes = @($_.Exception.Message) })
        Write-Host ("  {0,-55} FAILED: {1}" -f $resourceName, $_.Exception.Message) -ForegroundColor Red
    }
}

ConvertTo-Json -InputObject ([Object[]] $report) -Depth 10 |
    Set-Content -Path $ReportPath -Encoding UTF8 -WhatIf:$false

Write-Host ''
Write-Host "[tests] $converted / $($candidates.Count) converted" -ForegroundColor $(if ($converted -eq $candidates.Count) { 'Green' } else { 'Yellow' })
Write-Host "[tests] report: $ReportPath" -ForegroundColor Cyan

#endregion
