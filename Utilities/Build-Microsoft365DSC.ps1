<#
.SYNOPSIS
    Builds the class-based resource files for the Microsoft365DSC module.

.DESCRIPTION
    Reads the per-resource source files under Modules/Microsoft365DSC/DscResources/MSFT_*/ and emits
    the class files the shipped module actually loads:

        Modules/Microsoft365DSC/Classes/_Shared.psm1     base class and factory
        Modules/Microsoft365DSC/Classes/_Types<NN>.psm1  the complex types, bucketed
        Modules/Microsoft365DSC/Classes/Part<NN>.psm1    the [DscResource()] classes, bucketed

    then wires both into Microsoft365DSC.psd1 and regenerates SchemaDefinition.json from class
    reflection.

    Why this shape?

      - PowerShell type creation is superlinear in the number of classes in ONE parse unit, and
        each NestedModules entry is its own parse unit. On the real tree the import splits into
        type creation (about 5.5 ms per resource class plus 0.5 ms per method) and parsing of the
        method bodies (about 20% of the import on PowerShell 7, about 50% on Windows PowerShell).
        Any layout from 8 to 32 parts lands in the same noise band, measured 2026-09-02.

      - Class types do not cross module boundaries, and `using module` does not re-export what the
        module it names imported in turn. So each part opens with `using module .\_Shared.psm1` for
        the base class plus one `using module .\_Types<NN>.psm1` per complex-type bucket it
        references.

      - The complex-type buckets never reference each other. DscClassCache resolves an embedded
        type only inside one parse unit, so a bucket holds whole connected components of the
        reference graph - see Get-M365DSCConnectedComponent.

      - Because the parts are separate modules, no single scope can resolve every resource class
        with `$Name -as [System.Type]`. Each part therefore ends with
        [M365DSCResourceBase]::Register([X]) and the factory resolves through that registry.

      - The manifest's FunctionsToExport key MUST stay absent or '*'. When FunctionsToExport,
        CmdletsToExport and AliasesToExport are all explicit, Get-Module -ListAvailable returns
        from its manifest analysis before it records DscResourcesToExport, so ExportedDscResources
        is empty and every DSC engine reports zero resources. A wildcard in one of the three keys
        keeps the resources but not the analysis savings. This script never writes that key.

.PARAMETER RepositoryRoot
    Root of the Microsoft365DSC repository. Defaults to the parent of this script's folder.

.PARAMETER BucketCount
    Number of Part<NN>.psm1 files to spread the resource classes across. Import time is flat
    from 8 to 32 parts on the real tree. Re-measure with Utilities/Measure-M365DSCLoadPerformance.ps1
    before changing it.

.PARAMETER TypeBucketCount
    Number of _Types<NN>.psm1 files to spread the complex types across. Four, eight and sixteen
    buckets measure the same on the real tree. Re-measure with
    Utilities/Measure-M365DSCLoadPerformance.ps1 before changing it.

.PARAMETER BalanceBy
    Whether a bucket holds an equal number of classes (Count) or an equal amount of source text
    (Bytes). Measure with Utilities/Measure-M365DSCLoadPerformance.ps1 before changing it.

.PARAMETER KeepDescriptions
    Emit the [System.ComponentModel.Description()] attributes into the generated files. They are
    stripped by default: nothing reads them at runtime, SchemaDefinition.json takes them from the
    sources, and they are 53% of _Shared.psm1 - bytes that DscClassCache re-parses on every
    Get-DscResourceV2 call.

.PARAMETER SkipSchema
    Skip regenerating SchemaDefinition.json.

.PARAMETER SkipResourcePermissions
    Skip regenerating ResourcePermissions.json.

.PARAMETER SkipSchemaCache
    Skip generating DscSchemaCache.json for the fast compile host.

.PARAMETER SkipAdaptedManifests
    Skip generating the DSC v3 adapted resource manifests. They are also skipped with a warning
    when DscResource.Authoring is not installed.

.PARAMETER SkipValidation
    Skip the post-build import and discovery check.

.EXAMPLE
    .\Build-Microsoft365DSC.ps1

.EXAMPLE
    .\Build-Microsoft365DSC.ps1 -BucketCount 8 -SkipSchema

.NOTES
    Replaces a regex-based predecessor that shadowed New-ModuleManifest with a self-recursive
    function, and that resolved complex-type name collisions by renaming one side - which would
    silently break every exported configuration referencing that type. Collisions are now a hard
    failure.
#>

[CmdletBinding(SupportsShouldProcess)]
param
(
    [Parameter()]
    [System.String]
    $RepositoryRoot = (Split-Path -Path $PSScriptRoot -Parent),

    [Parameter()]
    [ValidateRange(1, 64)]
    [System.Int32]
    $BucketCount = 16,

    [Parameter()]
    [ValidateRange(1, 64)]
    [System.Int32]
    $TypeBucketCount = 8,

    [Parameter()]
    [ValidateSet('Count', 'Bytes')]
    [System.String]
    $BalanceBy = 'Count',

    [Parameter()]
    [Switch]
    $KeepDescriptions,

    [Parameter()]
    [Switch]
    $SkipSchema,

    [Parameter()]
    [Switch]
    $SkipSchemaCache,

    [Parameter()]
    [Switch]
    $SkipResourcePermissions,

    [Parameter()]
    [Switch]
    $SkipAdaptedManifests,

    [Parameter()]
    [Switch]
    $SkipValidation
)

$ErrorActionPreference = 'Stop'

Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'M365DSCBuildHelpers.psm1') -Force

$script:ModuleRoot = Join-Path -Path $RepositoryRoot -ChildPath 'Modules/Microsoft365DSC'
$script:SourceRoot = Join-Path -Path $script:ModuleRoot -ChildPath 'DscResources'
$script:BaseRoot = Join-Path -Path $script:SourceRoot -ChildPath '_Base'
$script:ClassRoot = Join-Path -Path $script:ModuleRoot -ChildPath 'Classes'
$script:ManifestPath = Join-Path -Path $script:ModuleRoot -ChildPath 'Microsoft365DSC.psd1'

# Markers let the generated NestedModules entries be rewritten in place without disturbing the
# hand-maintained ones around them.
$script:BeginMarker = '# BEGIN GENERATED CLASS MODULES - Utilities/Build-Microsoft365DSC.ps1'
$script:EndMarker = '# END GENERATED CLASS MODULES'

# Every spelling the sources use for the documentation attribute that is stripped from the output.
$script:DescriptionAttributeNames = @(
    'System.ComponentModel.Description',
    'System.ComponentModel.DescriptionAttribute',
    'Description',
    'DescriptionAttribute'
)

#region Helpers

function Write-BuildLog
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Message,

        [Parameter()]
        [ValidateSet('Info', 'Warning', 'Error', 'Success', 'Detail')]
        [System.String]
        $Level = 'Info'
    )

    $color = switch ($Level)
    {
        'Info' { 'Cyan' }
        'Warning' { 'Yellow' }
        'Error' { 'Red' }
        'Success' { 'Green' }
        'Detail' { 'DarkGray' }
    }

    Write-Host "[build] $Message" -ForegroundColor $color
}

# Parses one source file and returns its top-level class definitions.
function Get-M365DSCClassDefinition
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Path
    )

    $errors = $null
    $ast = [System.Management.Automation.Language.Parser]::ParseFile($Path, [ref] $null, [ref] $errors)

    <#
        Two error kinds are expected when a resource file is parsed on its own and must not be
        fatal, because they are artefacts of the split layout rather than defects in the source:

          TypeNotFound                 - the file opens `class X : M365DSCResourceBase`, and the
                                         base lives in _Shared.psm1, which this file does not pull
                                         in. The generated Part<NN>.psm1 does.
          DscResourceMissingTestMethod - Test() is inherited from M365DSCResourceBase, which the
                                         parser cannot see here for the same reason.

        Anything else is a real syntax error and still stops the build.
    #>
    $ignorable = @('TypeNotFound', 'DscResourceMissingTestMethod')
    $fatal = @($errors | Where-Object { $_.ErrorId -notin $ignorable })

    if ($fatal.Count -gt 0)
    {
        throw "Cannot parse '$Path': $($fatal[0].Message) (line $($fatal[0].Extent.StartLineNumber))"
    }

    # searchNestedScriptBlocks = $false: DSC only recognises classes at file top level, so anything
    # nested would not be discoverable anyway.
    $typeDefinitions = $ast.FindAll(
        { $args[0] -is [System.Management.Automation.Language.TypeDefinitionAst] },
        $false)

    $resourceClasses = [System.Collections.Generic.List[Object]]::new()
    $complexTypes = [System.Collections.Generic.List[Object]]::new()

    foreach ($typeDefinition in $typeDefinitions)
    {
        if ($typeDefinition.IsEnum)
        {
            # Enums are emitted alongside the complex types; they carry no DscResource attribute.
            $complexTypes.Add($typeDefinition)
            continue
        }

        $isResource = $false
        foreach ($attribute in $typeDefinition.Attributes)
        {
            if ($attribute.TypeName.Name -in @('DscResource', 'DscResourceAttribute'))
            {
                $isResource = $true
                break
            }
        }

        if ($isResource)
        {
            $resourceClasses.Add($typeDefinition)
        }
        else
        {
            $complexTypes.Add($typeDefinition)
        }
    }

    <#
        Converted resources carry private helpers alongside the class (Get-<Resource>SettingValue
        and friends). They are module-scope functions, not class members, so they must be emitted
        into the same part file or every call site fails at runtime.
    #>
    $typeSpans = @($typeDefinitions | ForEach-Object {
            [PSCustomObject] @{ Start = $_.Extent.StartOffset; End = $_.Extent.EndOffset }
        })

    $helperFunctions = @($ast.FindAll(
            { $args[0] -is [System.Management.Automation.Language.FunctionDefinitionAst] },
            $false) |
            Where-Object {
                $function = $_
                $inside = @($typeSpans | Where-Object {
                        $function.Extent.StartOffset -ge $_.Start -and $function.Extent.EndOffset -le $_.End
                    })
                $inside.Count -eq 0
            })

    return @{
        ResourceClasses = $resourceClasses
        ComplexTypes    = $complexTypes
        HelperFunctions = $helperFunctions
    }
}

function Get-NormalizedText
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Text
    )

    return (($Text -replace '\s+', ' ').Trim())
}

<#
.SYNOPSIS
    Returns the class text as it should be emitted.

.DESCRIPTION
    [System.ComponentModel.Description()] carries the documentation for every property. Nothing
    reads it at runtime - SchemaDefinition.json is generated from the sources, which keep it - but
    it is 53% of _Shared.psm1 and every byte is parsed again by DscClassCache on each
    Get-DscResourceV2, and turned into a CustomAttributeBuilder on each import. So it is dropped
    here unless -KeepDescriptions was passed.
#>
function Get-M365DSCEmittedText
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.Language.Ast]
        $Ast
    )

    $text = $Ast.Extent.Text

    if ($KeepDescriptions)
    {
        return $text
    }

    $origin = $Ast.Extent.StartOffset

    $attributes = @($Ast.FindAll(
            {
                $args[0] -is [System.Management.Automation.Language.AttributeAst] -and
                $args[0].TypeName.FullName -in $script:DescriptionAttributeNames
            },
            $true) | Sort-Object { $_.Extent.StartOffset } -Descending)

    foreach ($attribute in $attributes)
    {
        $start = $attribute.Extent.StartOffset - $origin
        $end = $attribute.Extent.EndOffset - $origin

        # Swallow the indentation in front of the attribute, and - when that leaves the line empty -
        # the line break behind it, so no blank line is left where the attribute was.
        while ($start -gt 0 -and ($text[$start - 1] -eq ' ' -or $text[$start - 1] -eq "`t"))
        {
            $start--
        }

        if ($start -eq 0 -or $text[$start - 1] -eq "`n")
        {
            if ($end -lt $text.Length -and $text[$end] -eq "`r") { $end++ }
            if ($end -lt $text.Length -and $text[$end] -eq "`n") { $end++ }
        }

        $text = $text.Remove($start, $end - $start)
    }

    return $text
}

<#
.SYNOPSIS
    Returns a complex type with any inheritance from another complex type flattened away: the base
    members are copied in and the ": Base" clause is dropped.

.DESCRIPTION
    DscClassCache cannot generate MOF for a derived complex type once the module is imported. With
    the module absent it resolves the property type by name from the AST and treats it as an
    embedded instance, which works; with the module imported it gets the real PowerShell class type
    and throws "The '<property>' property with type '<type>' of DSC resource class '<class>' is not
    supported". That breaks every in-process caller of ConvertTo-DSCObject, New-M365DSCDeltaReport
    among them, and compiling any configuration in a session that has the module loaded.
#>
function Get-M365DSCFlattenedComplexText
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.Language.TypeDefinitionAst]
        $TypeDefinition,

        [Parameter(Mandatory = $true)]
        [System.Collections.Generic.IDictionary[System.String, System.Object]]
        $ComplexTypeAst
    )

    $baseName = if ($TypeDefinition.BaseTypes.Count -gt 0) { $TypeDefinition.BaseTypes[0].TypeName.Name } else { $null }

    if ([System.String]::IsNullOrEmpty($baseName) -or -not $ComplexTypeAst.ContainsKey($baseName))
    {
        return (Get-M365DSCEmittedText -Ast $TypeDefinition)
    }

    # Names already declared lower in the chain win, so an override is not emitted twice.
    $seen = [System.Collections.Generic.HashSet[String]]::new([StringComparer]::OrdinalIgnoreCase)
    $members = [System.Collections.Generic.List[String]]::new()

    foreach ($member in $TypeDefinition.Members)
    {
        $null = $seen.Add($member.Name)
        $members.Add((Get-M365DSCEmittedText -Ast $member))
    }

    $current = $baseName
    while (-not [System.String]::IsNullOrEmpty($current) -and $ComplexTypeAst.ContainsKey($current))
    {
        $baseAst = $ComplexTypeAst[$current]

        $inherited = [System.Collections.Generic.List[String]]::new()
        foreach ($member in $baseAst.Members)
        {
            if (-not $seen.Add($member.Name))
            {
                continue
            }

            $inherited.Add((Get-M365DSCEmittedText -Ast $member))
        }

        # Base members first, so the flattened class reads the way the inheritance did.
        $members.InsertRange(0, $inherited)

        $current = if ($baseAst.BaseTypes.Count -gt 0) { $baseAst.BaseTypes[0].TypeName.Name } else { $null }
    }

    $builder = [System.Text.StringBuilder]::new()
    [void] $builder.AppendLine("class $($TypeDefinition.Name)")
    [void] $builder.AppendLine('{')

    for ($index = 0; $index -lt $members.Count; $index++)
    {
        if ($index -gt 0)
        {
            [void] $builder.AppendLine()
        }

        foreach ($line in ($members[$index] -split '\r?\n'))
        {
            [void] $builder.AppendLine('    ' + $line.TrimStart())
        }
    }

    [void] $builder.Append('}')

    return $builder.ToString()
}

<#
.SYNOPSIS
    Returns every type name a type reference mentions, with array and generic wrappers unwrapped.
#>
function Get-M365DSCReferencedName
{
    [CmdletBinding()]
    [OutputType([System.String[]])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.Language.ITypeName]
        $TypeName
    )

    if ($TypeName -is [System.Management.Automation.Language.ArrayTypeName])
    {
        return (Get-M365DSCReferencedName -TypeName $TypeName.ElementType)
    }

    if ($TypeName -is [System.Management.Automation.Language.GenericTypeName])
    {
        $names = [System.Collections.Generic.List[String]]::new()
        $names.Add($TypeName.TypeName.Name)
        foreach ($argument in $TypeName.GenericArguments)
        {
            $names.AddRange([System.String[]] (Get-M365DSCReferencedName -TypeName $argument))
        }
        return $names.ToArray()
    }

    return @($TypeName.Name)
}

<#
.SYNOPSIS
    Returns the complex types a block of generated code refers to.

.DESCRIPTION
    Drives both the dependency order of the _Types<NN>.psm1 buckets and the `using module` lines a
    bucket or a part needs. Reads the emitted text rather than the source AST, because inheritance
    is flattened on the way out and that moves property types between classes.
#>
function Get-M365DSCComplexReference
{
    [CmdletBinding()]
    [OutputType([System.String[]])]
    param
    (
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [System.String]
        $Text,

        [Parameter(Mandatory = $true)]
        [System.Collections.Generic.IDictionary[System.String, System.Object]]
        $ComplexType,

        [Parameter()]
        [System.String]
        $Exclude
    )

    $ast = [System.Management.Automation.Language.Parser]::ParseInput($Text, [ref] $null, [ref] $null)

    $references = $ast.FindAll(
        {
            $args[0] -is [System.Management.Automation.Language.TypeConstraintAst] -or
            $args[0] -is [System.Management.Automation.Language.TypeExpressionAst]
        },
        $true)

    $found = [System.Collections.Generic.HashSet[String]]::new([StringComparer]::OrdinalIgnoreCase)
    foreach ($reference in $references)
    {
        foreach ($name in (Get-M365DSCReferencedName -TypeName $reference.TypeName))
        {
            if ($name -eq $Exclude -or -not $ComplexType.ContainsKey($name))
            {
                continue
            }

            $null = $found.Add($ComplexType[$name].Name)
        }
    }

    return [System.String[]] $found
}

<#
.SYNOPSIS
    Returns name -> connected component id over the undirected reference graph.

.DESCRIPTION
    DscClassCache resolves an embedded complex type only against the classes in the same parse
    unit. `using module` does not widen what it looks at, and the fallback is the loaded CLR type,
    which it rejects with "The '<property>' property with type '<type>' of DSC resource class
    '<class>' is not supported" - the same wall Get-M365DSCFlattenedComplexText works around for
    inheritance. So two complex types that reference each other, in either direction, have to be
    emitted into one _Types<NN>.psm1 and no bucket may reference another.
#>
function Get-M365DSCConnectedComponent
{
    [CmdletBinding()]
    [OutputType([System.Collections.Generic.Dictionary[System.String, System.Int32]])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Collections.Generic.IDictionary[System.String, System.Object]]
        $Dependency
    )

    $adjacency = [System.Collections.Generic.Dictionary[String, System.Collections.Generic.HashSet[String]]]::new([StringComparer]::OrdinalIgnoreCase)
    foreach ($name in $Dependency.Keys)
    {
        $adjacency[$name] = [System.Collections.Generic.HashSet[String]]::new([StringComparer]::OrdinalIgnoreCase)
    }

    foreach ($name in $Dependency.Keys)
    {
        foreach ($other in @($Dependency[$name]))
        {
            $null = $adjacency[$name].Add($other)
            $null = $adjacency[$other].Add($name)
        }
    }

    $component = [System.Collections.Generic.Dictionary[String, System.Int32]]::new([StringComparer]::OrdinalIgnoreCase)
    $next = 0

    foreach ($root in ($Dependency.Keys | Sort-Object))
    {
        if ($component.ContainsKey($root))
        {
            continue
        }

        $component[$root] = $next
        $stack = [System.Collections.Generic.Stack[String]]::new()
        $stack.Push($root)

        while ($stack.Count -gt 0)
        {
            foreach ($neighbour in $adjacency[$stack.Pop()])
            {
                if (-not $component.ContainsKey($neighbour))
                {
                    $component[$neighbour] = $next
                    $stack.Push($neighbour)
                }
            }
        }

        $next++
    }

    return $component
}

#endregion

#region Collect

Write-BuildLog "Repository : $RepositoryRoot"
Write-BuildLog "Source     : $script:SourceRoot"

foreach ($required in @('M365DSCResourceBase.psm1', 'M365DSCResourceFactory.psm1'))
{
    $path = Join-Path -Path $script:BaseRoot -ChildPath $required
    if (-not (Test-Path -Path $path))
    {
        throw "Required base file not found: $path"
    }
}

$sourceFiles = @(Get-ChildItem -Path $script:SourceRoot -Directory -Filter 'MSFT_*' |
        ForEach-Object {
            $candidate = Join-Path -Path $_.FullName -ChildPath "$($_.Name).psm1"
            if (Test-Path -Path $candidate) { Get-Item -Path $candidate }
        })

Write-BuildLog "Found $($sourceFiles.Count) resource source files"

$resourceEntries = [System.Collections.Generic.List[Object]]::new()

# Keyed case-insensitively on purpose. Complex types are declared once per resource that uses
# them and the casing is not always consistent between those copies.
$complexByName = [System.Collections.Generic.Dictionary[String, Object]]::new([StringComparer]::OrdinalIgnoreCase)
$collisions = [System.Collections.Generic.List[String]]::new()
$skipped = [System.Collections.Generic.List[String]]::new()

foreach ($file in $sourceFiles)
{
    $definition = Get-M365DSCClassDefinition -Path $file.FullName

    if ($definition.ResourceClasses.Count -eq 0)
    {
        # Not converted yet - still a script-based resource. Expected during the transition.
        $skipped.Add($file.BaseName)
        continue
    }

    if ($definition.ResourceClasses.Count -gt 1)
    {
        throw ("'{0}' declares {1} [DscResource()] classes. One resource per source file." -f
            $file.Name, $definition.ResourceClasses.Count)
    }

    $resourceClass = $definition.ResourceClasses[0]

    $resourceEntries.Add([PSCustomObject] @{
            Name       = $resourceClass.Name
            SourceFile = $file.FullName
            SourceDir  = $file.DirectoryName
            Text       = Get-M365DSCEmittedText -Ast $resourceClass
            Helpers    = @($definition.HelperFunctions | ForEach-Object { $_.Extent.Text })
        })

    foreach ($complexType in $definition.ComplexTypes)
    {
        $normalized = Get-NormalizedText -Text $complexType.Extent.Text

        if ($complexByName.ContainsKey($complexType.Name))
        {
            $existing = $complexByName[$complexType.Name]
            if ($existing.Normalized -ne $normalized)
            {
                $collisions.Add(("{0}: declared differently in '{1}' and '{2}'" -f
                        $complexType.Name, $existing.Source, $file.Name))
            }
            continue
        }

        $complexByName[$complexType.Name] = [PSCustomObject] @{
            Name       = $complexType.Name
            Ast        = $complexType
            Normalized = $normalized
            Source     = $file.Name
        }
    }
}

if ($collisions.Count -gt 0)
{
    $message = "Complex type collisions must be resolved at the source:`n  " + ($collisions -join "`n  ")
    throw $message
}

Write-BuildLog "Class-based resources : $($resourceEntries.Count)"
Write-BuildLog "Complex types         : $($complexByName.Count)"
Write-BuildLog "Still script-based    : $($skipped.Count)" -Level $(if ($skipped.Count -gt 0) { 'Warning' } else { 'Info' })

if ($resourceEntries.Count -eq 0)
{
    throw "No class-based resources found under $script:SourceRoot. Nothing to build."
}

#endregion

#region Emit

if (-not $PSCmdlet.ShouldProcess($script:ClassRoot, 'Generate class modules'))
{
    Write-BuildLog 'WhatIf: stopping before any file is written.' -Level Warning
    return
}

if (Test-Path -Path $script:ClassRoot)
{
    Get-ChildItem -Path $script:ClassRoot -Filter '*.psm1' | Remove-Item -Force
}
else
{
    $null = New-Item -Path $script:ClassRoot -ItemType Directory -Force
}

$generatedFiles = [System.Collections.Generic.List[String]]::new()

# --- _Shared.psm1 -----------------------------------------------------------------------------
# Order matters inside one parse unit: the base class first, then the factory that references it.
$shared = [System.Text.StringBuilder]::new()
[void] $shared.AppendLine('# GENERATED FILE - do not edit.')
[void] $shared.AppendLine('# Produced by Utilities/Build-Microsoft365DSC.ps1 from DscResources/_Base.')
[void] $shared.AppendLine('')
[void] $shared.AppendLine((Get-Content -Path (Join-Path $script:BaseRoot 'M365DSCResourceBase.psm1') -Raw))
[void] $shared.AppendLine('')
[void] $shared.AppendLine((Get-Content -Path (Join-Path $script:BaseRoot 'M365DSCResourceFactory.psm1') -Raw))

$sharedPath = Join-Path -Path $script:ClassRoot -ChildPath '_Shared.psm1'
Set-Content -Path $sharedPath -Value $shared.ToString() -Encoding UTF8
$generatedFiles.Add('Classes/_Shared.psm1')
Write-BuildLog "Wrote $($sharedPath.Substring($RepositoryRoot.Length + 1)) ($([math]::Round((Get-Item $sharedPath).Length / 1KB)) KB)" -Level Detail

# --- _Types<NN>.psm1 --------------------------------------------------------------------------
$complexTypeAst = [System.Collections.Generic.Dictionary[String, Object]]::new([StringComparer]::OrdinalIgnoreCase)
foreach ($complexType in $complexByName.Values)
{
    $complexTypeAst[$complexType.Name] = $complexType.Ast
}

$flattened = 0
$complexText = [System.Collections.Generic.Dictionary[String, String]]::new([StringComparer]::OrdinalIgnoreCase)
foreach ($complexType in ($complexByName.Values | Sort-Object Name))
{
    if ($complexType.Ast.BaseTypes.Count -gt 0 -and $complexTypeAst.ContainsKey($complexType.Ast.BaseTypes[0].TypeName.Name))
    {
        $flattened++
    }

    $complexText[$complexType.Name] = Get-M365DSCFlattenedComplexText -TypeDefinition $complexType.Ast `
        -ComplexTypeAst $complexTypeAst
}

$complexDependency = [System.Collections.Generic.Dictionary[String, Object]]::new([StringComparer]::OrdinalIgnoreCase)
foreach ($name in $complexText.Keys)
{
    $complexDependency[$name] = @(Get-M365DSCComplexReference -Text $complexText[$name] `
            -ComplexType $complexByName `
            -Exclude $name)
}

# Whole components per bucket, so no bucket ever has to reference another.
$complexComponent = Get-M365DSCConnectedComponent -Dependency $complexDependency

$componentMembers = @{}
foreach ($name in ($complexText.Keys | Sort-Object))
{
    $id = $complexComponent[$name]
    if (-not $componentMembers.ContainsKey($id))
    {
        $componentMembers[$id] = [System.Collections.Generic.List[String]]::new()
    }

    $componentMembers[$id].Add($name)
}

$orderedComponents = @($componentMembers.Keys | Sort-Object @{ Expression = { $componentMembers[$_][0] } })

$typeWeight = @{}
foreach ($name in $complexText.Keys)
{
    $typeWeight[$name] = if ($BalanceBy -eq 'Bytes') { $complexText[$name].Length } else { 1 }
}
$totalTypeWeight = ($typeWeight.Values | Measure-Object -Sum).Sum
$effectiveTypeBuckets = [System.Math]::Min($TypeBucketCount, $componentMembers.Count)
$perTypeBucket = [System.Math]::Ceiling($totalTypeWeight / $effectiveTypeBuckets)
$pendingWeight = 0

$typeBuckets = [System.Collections.Generic.List[Object]]::new()
$typeBucketByName = [System.Collections.Generic.Dictionary[String, Int32]]::new([StringComparer]::OrdinalIgnoreCase)
$pending = [System.Collections.Generic.List[String]]::new()

foreach ($id in $orderedComponents)
{
    $members = $componentMembers[$id]

    $membersWeight = ($members | ForEach-Object { $typeWeight[$_] } | Measure-Object -Sum).Sum
    if ($pending.Count -gt 0 -and ($pendingWeight + $membersWeight) -gt $perTypeBucket)
    {
        $typeBuckets.Add($pending.ToArray())
        $pending = [System.Collections.Generic.List[String]]::new()
        $pendingWeight = 0
    }

    $pending.AddRange($members)
    $pendingWeight += $membersWeight
}

if ($pending.Count -gt 0)
{
    $typeBuckets.Add($pending.ToArray())
}

for ($bucket = 0; $bucket -lt $typeBuckets.Count; $bucket++)
{
    foreach ($name in $typeBuckets[$bucket])
    {
        $typeBucketByName[$name] = $bucket
    }
}

for ($bucket = 0; $bucket -lt $typeBuckets.Count; $bucket++)
{
    $slice = $typeBuckets[$bucket]

    foreach ($name in $slice)
    {
        foreach ($dependency in $complexDependency[$name])
        {
            $other = $typeBucketByName[$dependency]
            if ($other -ne $bucket)
            {
                throw ("Complex type '{0}' is in bucket {1} but references '{2}' in bucket {3}. " -f
                    $name, $bucket, $dependency, $other) +
                    'A bucket must hold whole components; DscClassCache cannot resolve across them.'
            }
        }
    }

    $types = [System.Text.StringBuilder]::new()
    [void] $types.AppendLine('# GENERATED FILE - do not edit.')
    [void] $types.AppendLine('# Produced by Utilities/Build-Microsoft365DSC.ps1 from DscResources/MSFT_*.')
    [void] $types.AppendLine('')

    foreach ($name in $slice)
    {
        [void] $types.AppendLine($complexText[$name])
        [void] $types.AppendLine('')
    }

    $fileName = '_Types{0:D2}.psm1' -f $bucket
    Set-Content -Path (Join-Path $script:ClassRoot $fileName) -Value $types.ToString() -Encoding UTF8
    $generatedFiles.Add("Classes/$fileName")
}

Write-BuildLog "Wrote $($typeBuckets.Count) complex type file(s), $perTypeBucket type(s) each at most"
Write-BuildLog "Flattened $flattened derived complex type(s)" -Level Detail

# --- Part<NN>.psm1 ----------------------------------------------------------------------------
$sortedResources = @($resourceEntries | Sort-Object Name)
$effectiveBuckets = [System.Math]::Min($BucketCount, $sortedResources.Count)
$resourceWeight = @{}
foreach ($resource in $sortedResources)
{
    $resourceWeight[$resource.Name] = if ($BalanceBy -eq 'Bytes') { $resource.Text.Length + (@($resource.Helpers) -join '').Length } else { 1 }
}
$perBucket = [System.Math]::Ceiling((($resourceWeight.Values | Measure-Object -Sum).Sum) / $effectiveBuckets)

$partSlices = [System.Collections.Generic.List[Object]]::new()
$pendingResources = [System.Collections.Generic.List[Object]]::new()
$pendingResourceWeight = 0
foreach ($resource in $sortedResources)
{
    $weight = $resourceWeight[$resource.Name]
    if ($pendingResources.Count -gt 0 -and ($pendingResourceWeight + $weight) -gt $perBucket -and $partSlices.Count -lt ($effectiveBuckets - 1))
    {
        $partSlices.Add($pendingResources.ToArray())
        $pendingResources = [System.Collections.Generic.List[Object]]::new()
        $pendingResourceWeight = 0
    }

    $pendingResources.Add($resource)
    $pendingResourceWeight += $weight
}

if ($pendingResources.Count -gt 0)
{
    $partSlices.Add($pendingResources.ToArray())
}

for ($bucket = 0; $bucket -lt $partSlices.Count; $bucket++)
{
    $slice = @($partSlices[$bucket])

    $sliceText = (@($slice | ForEach-Object { $_.Text; $_.Helpers }) -join "`n")
    $required = [System.Collections.Generic.SortedSet[Int32]]::new()
    foreach ($name in (Get-M365DSCComplexReference -Text $sliceText -ComplexType $complexByName))
    {
        $null = $required.Add($typeBucketByName[$name])
    }

    $part = [System.Text.StringBuilder]::new()
    [void] $part.AppendLine('# GENERATED FILE - do not edit.')
    [void] $part.AppendLine('# Produced by Utilities/Build-Microsoft365DSC.ps1.')
    [void] $part.AppendLine('')
    # Classes do not cross module boundaries; this is what makes M365DSCResourceBase and the
    # complex types these resources declare visible here.
    [void] $part.AppendLine('using module .\_Shared.psm1')
    foreach ($other in $required)
    {
        [void] $part.AppendLine(('using module .\_Types{0:D2}.psm1' -f $other))
    }
    [void] $part.AppendLine('')

    foreach ($resource in $slice)
    {
        [void] $part.AppendLine($resource.Text)
        [void] $part.AppendLine('')

        foreach ($helper in $resource.Helpers)
        {
            [void] $part.AppendLine($helper)
            [void] $part.AppendLine('')
        }
    }

    [void] $part.AppendLine('# Self-registration. The factory cannot use `$Name -as [System.Type]`, because each part is')
    [void] $part.AppendLine('# its own module and no single scope sees every resource class.')
    [void] $part.AppendLine('#')
    [void] $part.AppendLine('# The module name is captured here rather than derived later: this runs at module top level,')
    [void] $part.AppendLine('# so $ExecutionContext.SessionState.Module is THIS part. A class type does not expose the')
    [void] $part.AppendLine('# module that declared it, and the unit tests need it to scope their mocks.')
    [void] $part.AppendLine('$partModuleName = $ExecutionContext.SessionState.Module.Name')
    foreach ($resource in $slice)
    {
        [void] $part.AppendLine(('[M365DSCResourceBase]::Register([{0}], $partModuleName)' -f $resource.Name))
    }

    $fileName = 'Part{0:D2}.psm1' -f $bucket

    <#
        Source resource files open with `using module ..\_Base\M365DSCResourceBase.psm1` so that
        they parse cleanly in an editor. That line must not survive into the generated part, which
        pulls the base class from _Shared.psm1 and the complex types from _Types<NN>.psm1 instead.
    #>
    if ($part.ToString() -match '(?m)^\s*using module (?!\.\\(?:_Shared|_Types\d{2})\.psm1)')
    {
        throw ("Generated $fileName carries a using statement other than _Shared.psm1 or " +
            '_Types<NN>.psm1. Class-text extraction must exclude file-level using statements.')
    }

    Set-Content -Path (Join-Path $script:ClassRoot $fileName) -Value $part.ToString() -Encoding UTF8
    $generatedFiles.Add("Classes/$fileName")
}

Write-BuildLog "Wrote $($partSlices.Count) part file(s) balanced by $BalanceBy"

#endregion

#region Manifest

# Edits the existing manifest in place rather than regenerating it.
function Update-M365DSCBuildManifest
{
    [CmdletBinding(SupportsShouldProcess)]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Path,

        [Parameter(Mandatory = $true)]
        [System.String[]]
        $ClassModule,

        [Parameter(Mandatory = $true)]
        [System.String[]]
        $ResourceName
    )

    $content = Get-Content -Path $Path -Raw

    # 1. Drop any previously generated block so re-runs are idempotent. The leading newline and
    #    indent are part of the block: leaving them behind made each run inherit the previous
    #    run's padding, which grew the NestedModules closing line by four spaces every build.
    $pattern = '\r?\n[ \t]*' + [System.Text.RegularExpressions.Regex]::Escape($script:BeginMarker) +
    '.*?' + [System.Text.RegularExpressions.Regex]::Escape($script:EndMarker)
    $content = [System.Text.RegularExpressions.Regex]::Replace($content, $pattern, '', 'Singleline')

    # 2. Insert the class modules at the end of the NestedModules array.
    $nestedMatch = [System.Text.RegularExpressions.Regex]::Match(
        $content, '(?s)(NestedModules\s*=\s*@\()(.*?)(\r?\n\s*\))')
    if (-not $nestedMatch.Success)
    {
        throw "Could not locate the NestedModules array in '$Path'."
    }

    $body = $nestedMatch.Groups[2].Value.TrimEnd()
    if (-not $body.EndsWith(','))
    {
        $body += ','
    }

    $block = "`r`n    $script:BeginMarker`r`n"
    $block += (($ClassModule | ForEach-Object { "    '$_'" }) -join ",`r`n")
    $block += "`r`n    $script:EndMarker"

    $content = $content.Remove($nestedMatch.Index, $nestedMatch.Length).Insert(
        $nestedMatch.Index,
        $nestedMatch.Groups[1].Value + $body + $block + "`r`n  )")

    # 3. DscResourcesToExport. Mandatory: DscClassCache returns immediately when it is missing or
    #    empty, so without it discovery yields zero resources.
    $exportBlock = "  DscResourcesToExport = @(`r`n"
    $exportBlock += (($ResourceName | Sort-Object | ForEach-Object { "    '$_'" }) -join ",`r`n")
    $exportBlock += "`r`n  )"

    $existing = [System.Text.RegularExpressions.Regex]::Match(
        $content, '(?s)^\s*DscResourcesToExport\s*=\s*@\(.*?\r?\n\s*\)', 'Multiline')

    if ($existing.Success)
    {
        $content = $content.Remove($existing.Index, $existing.Length).Insert($existing.Index, $exportBlock)
    }
    else
    {
        # Place it right after the NestedModules array.
        $anchor = [System.Text.RegularExpressions.Regex]::Match(
            $content, '(?s)NestedModules\s*=\s*@\(.*?\r?\n\s*\)')
        $insertAt = $anchor.Index + $anchor.Length
        $content = $content.Insert($insertAt, "`r`n`r`n  # DSC resources to export from this module.`r`n$exportBlock")
    }

    # 4. FunctionsToExport is deliberately untouched. With every export key explicit the engine
    #    skips the manifest analysis that records DscResourcesToExport, and Get-DscResource
    #    reports zero resources on both editions.

    if ($PSCmdlet.ShouldProcess($Path, 'Update manifest'))
    {
        Set-Content -Path $Path -Value $content -Encoding UTF8 -NoNewline
    }
}

Update-M365DSCBuildManifest -Path $script:ManifestPath `
    -ClassModule $generatedFiles.ToArray() `
    -ResourceName @($resourceEntries.Name)

Write-BuildLog "Updated $($script:ManifestPath.Substring($RepositoryRoot.Length + 1))"

$manifestData = Import-PowerShellDataFile -Path $script:ManifestPath
if ($manifestData.ContainsKey('FunctionsToExport'))
{
    Write-BuildLog ('FunctionsToExport is present in the manifest. An explicit list drops every ' +
        'class-based resource from Get-DscResource. Remove or comment out the key.') -Level Error
    throw 'Manifest declares FunctionsToExport.'
}

#endregion

if (-not $SkipSchema)
{
    Write-BuildLog 'Regenerating SchemaDefinition.json from class reflection...'
    & (Join-Path -Path $PSScriptRoot -ChildPath 'New-M365DSCSchemaFromClasses.ps1') -RepositoryRoot $RepositoryRoot
}

if (-not $SkipResourcePermissions)
{
    Write-BuildLog 'Regenerating ResourcePermissions.json from the resource settings files...'
    $null = & (Join-Path -Path $PSScriptRoot -ChildPath 'New-M365DSCResourcePermissions.ps1') -RepositoryRoot $RepositoryRoot
}

if (-not $SkipAdaptedManifests)
{
    Write-BuildLog 'Generating DSC v3 adapted resource manifests...'
    $null = & (Join-Path -Path $PSScriptRoot -ChildPath 'New-M365DSCAdaptedResourceManifest.ps1') -RepositoryRoot $RepositoryRoot -WarnOnly
}

if (-not $SkipSchemaCache)
{
    Write-BuildLog 'Generating DscSchemaCache.json for the fast compile host...'
    $null = & (Join-Path -Path $PSScriptRoot -ChildPath 'New-M365DSCDscSchemaCache.ps1') -RepositoryRoot $RepositoryRoot -WarnOnly
}

#region Validate

if (-not $SkipValidation)
{
    Write-BuildLog 'Validating...'

    $expectedNames = @($resourceEntries.Name | Sort-Object)
    $expected = $expectedNames.Count

    $version = ([Version] $manifestData.ModuleVersion).ToString()
    $stage = New-M365DSCProbeStage -ModuleRoot $script:ModuleRoot -Version $version
    $stageRoot = $stage.Root.Replace("'", "''")

    $probe = @"
`$ErrorActionPreference = 'Stop'

`$parser = @(Get-Module -ListAvailable -Name 'DSCParser' | Sort-Object Version -Descending)[0]
if (`$null -eq `$parser)
{
    throw 'DSCParser is not installed; Get-DscResourceV2 is unavailable.'
}

`$entries = @(`$env:PSModulePath -split [System.IO.Path]::PathSeparator |
    Where-Object { `$_ -and -not (Test-Path -Path (Join-Path -Path `$_ -ChildPath 'Microsoft365DSC')) })
`$env:PSModulePath = (@('$stageRoot') + `$entries) -join [System.IO.Path]::PathSeparator

Import-Module -Name `$parser.Path -Force -WarningAction SilentlyContinue

`$found = @(Get-DscResourceV2 -Module 'Microsoft365DSC' -ErrorAction SilentlyContinue |
    Where-Object { `$_.ImplementationDetail -eq 'ClassBased' -or `$_.Name -in @('$($expectedNames -join "','")') })
foreach (`$resource in `$found)
{
    'RESOURCE:{0}' -f `$resource.Name
}
"@

    try
    {
        $result = & pwsh -NoProfile -NonInteractive -Command $probe

        $foundNames = @($result |
                Where-Object { $_ -is [System.String] -and $_.StartsWith('RESOURCE:') } |
                ForEach-Object { $_.Substring('RESOURCE:'.Length).Trim() } |
                Sort-Object -Unique)
        $count = $foundNames.Count

        if ($count -ne $expected)
        {
            Write-BuildLog "Discovery returned $count class-based resources, expected $expected." -Level Error

            $foundSet = [System.Collections.Generic.HashSet[String]]::new(
                [String[]] $foundNames, [StringComparer]::OrdinalIgnoreCase)
            $expectedSet = [System.Collections.Generic.HashSet[String]]::new(
                [String[]] $expectedNames, [StringComparer]::OrdinalIgnoreCase)

            $missing = @($expectedNames | Where-Object { -not $foundSet.Contains($_) })
            $unexpected = @($foundNames | Where-Object { -not $expectedSet.Contains($_) })

            if ($missing.Count -gt 0)
            {
                Write-BuildLog "Built but not discovered ($($missing.Count)):" -Level Error
                foreach ($name in $missing)
                {
                    Write-BuildLog "  - $name" -Level Detail
                }
            }

            if ($unexpected.Count -gt 0)
            {
                Write-BuildLog "Discovered but not built ($($unexpected.Count)):" -Level Warning
                foreach ($name in $unexpected)
                {
                    Write-BuildLog "  + $name" -Level Detail
                }
            }

            if ($missing.Count -eq 0 -and $unexpected.Count -eq 0)
            {
                Write-BuildLog 'No name difference found. Raw probe output:' -Level Error
                foreach ($line in $result)
                {
                    Write-BuildLog "  $line" -Level Detail
                }
            }

            throw 'Validation failed.'
        }

        Write-BuildLog "Discovery: $count / $expected class-based resources" -Level Success
    }
    finally
    {
        Remove-M365DSCProbeStage -Stage $stage
    }
}

#endregion

Write-BuildLog 'Build complete.' -Level Success
