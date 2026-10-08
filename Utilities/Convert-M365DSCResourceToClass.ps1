#Requires -Version 5.1

<#
.SYNOPSIS
    Converts a script-based Microsoft365DSC resource into a class-based one.

.DESCRIPTION
    Rewrites Get/Set/Test/Export-TargetResource into methods on a [DscResource()] class deriving
    from M365DSCResourceBase.

    The transformation is AST-driven. Every rewrite is collected as an (offset, length, text) edit
    against the ORIGINAL file, then applied in reverse offset order. Nothing pattern-matches against
    source text.

    What gets rewritten:

      $PSBoundParameters                            -> $this.GetBoundParameters()
      $Script:exportedInstance                      -> $this.ExportedInstance
      other $Script:<name>                          -> $this.ResourceCache['<name>']
      a variable matching a schema property         -> $this.<Name>            (exact name match)
      $PSScriptRoot                                 -> $this.GetModulePath()
      $MyInvocation.MyCommand.ModuleName/.Source    -> $this.GetResourceName()
      the if ($PSEdition -ne 'Core') block          -> the class-based shim
      the telemetry block                           -> $this.AddTelemetry('<Method>')
      New-M365DSCConnection -InboundParameters ...  -> $this.Connect('<Workload>')
      New-M365DSCLogEntry ...                       -> $this.LogError($_, '<message>')
      Get-TargetResource @PSBoundParameters         -> $this.Get()
      return <hashtable> inside Get()               -> return $this.AsResult(<hashtable>)

    Test-TargetResource is DROPPED when its body is the standard telemetry-plus-one-call shape,
    because M365DSCResourceBase implements exactly that. A non-standard body is emitted as an
    override and flagged in the report.

    Anything the converter cannot do mechanically is recorded in the report rather than guessed at.

.PARAMETER ResourceName
    Resource to convert, with or without the MSFT_ prefix. Accepts wildcards. Omit for all.

.PARAMETER RepositoryRoot
    Root of the Microsoft365DSC repository.

.PARAMETER OutputPath
    Where to write converted files. Defaults to a 'converted' folder beside this script, so the
    shipping module is never modified in place.

.PARAMETER ReportPath
    Where to write the JSON conversion report.

.EXAMPLE
    .\Convert-M365DSCResourceToClass.ps1 -ResourceName AADGroup

.EXAMPLE
    .\Convert-M365DSCResourceToClass.ps1 -ResourceName 'AAD*' -OutputPath D:\out

.OUTPUTS
    System.Collections.Hashtable
#>

using namespace System.Management.Automation.Language

[CmdletBinding(SupportsShouldProcess)]
param
(
    [Parameter()]
    [System.String[]]
    $ResourceName,

    [Parameter()]
    [System.String]
    $RepositoryRoot = (Split-Path -Path $PSScriptRoot -Parent),

    [Parameter()]
    [System.String]
    $OutputPath = (Join-Path -Path $PSScriptRoot -ChildPath 'converted'),

    [Parameter()]
    [System.String]
    $ReportPath
)

$ErrorActionPreference = 'Stop'

$script:ModuleRoot = Join-Path -Path $RepositoryRoot -ChildPath 'Modules/Microsoft365DSC'
$script:SourceRoot = Join-Path -Path $script:ModuleRoot -ChildPath 'DscResources'
$script:SchemaPath = Join-Path -Path $script:ModuleRoot -ChildPath 'SchemaDefinition.json'

if (-not $ReportPath)
{
    $ReportPath = Join-Path -Path $OutputPath -ChildPath 'ConversionReport.json'
}

#region Schema

# Schema comes from SchemaDefinition.json: CIMType, Description, Name and Option (Key/Required/Write).
# Validation attributes are not in there - [ValidateRange] and friends are read from the param block.
$script:Schema = @{}
foreach ($entry in (Get-Content -Path $script:SchemaPath -Raw | ConvertFrom-Json))
{
    $script:Schema[$entry.ClassName] = $entry
}

<#
    Inheritance, which SchemaDefinition.json does not carry. A derived class declares only its own
    members, so emitting it standalone loses every inherited one.

    OMI_BaseResource is skipped; resource classes derive from M365DSCResourceBase instead.
#>
$script:SuperClass = @{}
foreach ($mofFile in (Get-ChildItem -Path $script:SourceRoot -Filter '*.schema.mof' -Recurse -File))
{
    $mofText = Get-Content -Path $mofFile.FullName -Raw
    foreach ($match in [regex]::Matches($mofText, '(?m)^\s*class\s+(?<Name>[A-Za-z0-9_]+)\s*:\s*(?<Base>[A-Za-z0-9_]+)'))
    {
        $derived = $match.Groups['Name'].Value
        $base = $match.Groups['Base'].Value

        if ($base -eq 'OMI_BaseResource')
        {
            continue
        }

        if ($script:SuperClass.ContainsKey($derived) -and $script:SuperClass[$derived] -ne $base)
        {
            Write-Warning "Class '$derived' is declared with two different base classes: '$($script:SuperClass[$derived])' and '$base'. Keeping the first."
            continue
        }

        $script:SuperClass[$derived] = $base
    }
}

<#
    Automatic variables a class method cannot read. Each needs an explicit $global: qualifier;
    declaring a local instead would shadow it with $null and silently change behaviour.

    $PSBoundParameters, $PSScriptRoot and $MyInvocation are absent on purpose - they have dedicated
    rewrites to base-class methods.
#>
$script:AutomaticVariable = @(
    'PSVersionTable', 'PSEdition', 'PSCulture', 'PSUICulture', 'PSHOME', 'PSCommandPath',
    'ExecutionContext', 'Host', 'PID', 'PROFILE', 'ShellId', 'IsWindows', 'IsLinux', 'IsMacOS',
    'IsCoreCLR'
)

function ConvertTo-ClassType
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $CimType,

        # Keys stay non-nullable: DSC rejects a nullable key. A key is always specified, so it never
        # needs $null to mean "omitted".
        [Parameter()]
        [Switch]
        $NoNullable
    )

    $isArray = $CimType.EndsWith('[]')
    $bare = if ($isArray) { $CimType.Substring(0, $CimType.Length - 2) } else { $CimType }

    $mapped = switch ($bare)
    {
        'String' { 'System.String' }
        'Boolean' { 'System.Boolean' }
        'DateTime' { 'System.DateTime' }
        'SInt16' { 'System.Int16' }
        'SInt32' { 'System.Int32' }
        'SInt64' { 'System.Int64' }
        'Uint16' { 'System.UInt16' }
        'UInt32' { 'System.UInt32' }
        'UInt64' { 'System.UInt64' }
        'Real64' { 'System.Double' }
        'MSFT_Credential' { 'System.Management.Automation.PSCredential' }
        default { $bare }
    }

    if ($isArray)
    {
        # An array is already a reference type: $null means "not specified".
        return "$mapped[]"
    }

    <#
        Scalar value types become Nullable[T]. DSC leaves unset properties at their CLR defaults,
        so a plain [Boolean] cannot distinguish "omitted" from "specified as $false" and
        GetBoundParameters() would either drop a deliberate $false or invent values that were never
        configured. The nullability does not leak into the reported schema.
    #>
    $valueTypes = @(
        'System.Boolean', 'System.DateTime', 'System.Int16', 'System.Int32', 'System.Int64',
        'System.UInt16', 'System.UInt32', 'System.UInt64', 'System.Double'
    )

    if ($mapped -in $valueTypes -and -not $NoNullable)
    {
        return "System.Nullable[$mapped]"
    }

    return $mapped
}

function Get-EscapedSingleQuoteString
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter()]
        [AllowNull()]
        [AllowEmptyString()]
        [System.String]
        $Value
    )

    if ([String]::IsNullOrEmpty($Value))
    {
        return ''
    }

    # Smart quotes are string delimiters to the PowerShell tokenizer. Normalise before escaping.
    $normalised = $Value -replace [char] 0x2018, "'" -replace [char] 0x2019, "'" `
        -replace [char] 0x201C, '"' -replace [char] 0x201D, '"'

    return ($normalised -replace "'", "''")
}

#endregion

#region AST helpers

function Get-FunctionDefinition
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.Language.Ast]
        $Ast
    )

    $result = @{}
    foreach ($function in $Ast.FindAll({ $args[0] -is [FunctionDefinitionAst] }, $false))
    {
        $result[$function.Name] = $function
    }

    return $result
}

# Validation attributes declared on the function parameters, keyed by parameter name.
function Get-ParameterValidationAttribute
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.Language.FunctionDefinitionAst]
        $Function
    )

    $result = @{}
    if ($null -eq $Function.Body.ParamBlock)
    {
        return $result
    }

    foreach ($parameter in $Function.Body.ParamBlock.Parameters)
    {
        $name = $parameter.Name.VariablePath.UserPath
        $attributes = [System.Collections.Generic.List[String]]::new()

        foreach ($attribute in $parameter.Attributes)
        {
            if ($attribute -isnot [AttributeAst])
            {
                continue
            }

            $typeName = $attribute.TypeName.Name
            # ValidateSet is regenerated from the schema ValueMap, so it is not duplicated here.
            if ($typeName -like 'Validate*' -and $typeName -ne 'ValidateSet')
            {
                $attributes.Add($attribute.Extent.Text)
            }
        }

        if ($attributes.Count -gt 0)
        {
            $result[$name] = $attributes
        }
    }

    return $result
}

#endregion

#region Body rewriting

<#
    Rewrites schema-property references inside an argument that is being lifted verbatim into a
    replacement. A command-level edit replaces the whole command extent, and the overlap rule then
    discards the property rewrites nested inside it.
#>
function Convert-EmbeddedPropertyReference
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.Language.Ast]
        $Expression,

        [Parameter(Mandatory = $true)]
        [System.Object]
        $PropertyName,

        [Parameter()]
        [System.Object]
        $LoopVariable = $null
    )

    $text = $Expression.Extent.Text
    $base = $Expression.Extent.StartOffset
    $replacements = [System.Collections.Generic.List[Object]]::new()

    foreach ($nested in $Expression.FindAll({ $args[0] -is [VariableExpressionAst] }, $true))
    {
        $name = $nested.VariablePath.UserPath
        if (-not $PropertyName.Contains($name))
        {
            continue
        }

        if ($null -ne $LoopVariable -and $LoopVariable.Contains($name))
        {
            continue
        }

        # Directly inside an expandable string a bare $this.X would expand the object and then
        # append the literal '.X', so a subexpression is required there.
        $replacementText = if ($nested.Parent -is [ExpandableStringExpressionAst])
        {
            "`$(`$this.$name)"
        }
        else
        {
            "`$this.$name"
        }

        $replacements.Add([PSCustomObject] @{
                Start  = $nested.Extent.StartOffset - $base
                Length = $nested.Extent.EndOffset - $nested.Extent.StartOffset
                Text   = $replacementText
            })
    }

    foreach ($replacement in ($replacements | Sort-Object Start -Descending))
    {
        $text = $text.Remove($replacement.Start, $replacement.Length).Insert($replacement.Start, $replacement.Text)
    }

    return $text
}

class ConversionEdit
{
    [int] $Offset
    [int] $Length
    [string] $Text
    [string] $Reason
}

<#
.SYNOPSIS
    Rewrites calls to renamed helper functions inside a block of source text.

.DESCRIPTION
    Helper declarations are renamed with a resource-specific prefix, because all resources share one
    generated part file. Convert-FunctionBody covers the call sites inside class methods; this
    covers the ones inside the helper bodies themselves.

    Offsets are relative to $Text, so the text passed in must be the same string the AST was parsed
    from - not a substring of the original file.

.PARAMETER Text
    The source text to rewrite.

.PARAMETER HelperRename
    Map of original helper name to renamed helper name.

.EXAMPLE
    Update-HelperCallSite -Text $helperText -HelperRename @{ 'Get-Thing' = 'Get-AADGroupThing' }

.FUNCTIONALITY
    Internal

.OUTPUTS
    System.String
#>
function Update-HelperCallSite
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Text,

        [Parameter(Mandatory = $true)]
        [System.Collections.Hashtable]
        $HelperRename
    )

    if ($HelperRename.Count -eq 0)
    {
        return $Text
    }

    $errors = $null
    $ast = [Parser]::ParseInput($Text, [ref] $null, [ref] $errors)
    if ($errors.Count -gt 0)
    {
        return $Text
    }

    $replacements = [System.Collections.Generic.List[Object]]::new()
    foreach ($command in $ast.FindAll({ $args[0] -is [CommandAst] }, $true))
    {
        $name = $command.GetCommandName()
        if ($name -and $HelperRename.ContainsKey($name))
        {
            $replacements.Add([PSCustomObject] @{
                    Extent = $command.CommandElements[0].Extent
                    Text   = $HelperRename[$name]
                })
        }
    }

    foreach ($replacement in ($replacements | Sort-Object { $_.Extent.StartOffset } -Descending))
    {
        $start = $replacement.Extent.StartOffset
        $length = $replacement.Extent.EndOffset - $start
        $Text = $Text.Remove($start, $length).Insert($start, $replacement.Text)
    }

    return $Text
}

function New-Edit
{
    [CmdletBinding()]
    [OutputType([ConversionEdit])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Object]
        $Extent,

        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [System.String]
        $Text,

        [Parameter(Mandatory = $true)]
        [System.String]
        $Reason
    )

    $edit = [ConversionEdit]::new()
    $edit.Offset = $Extent.StartOffset
    $edit.Length = $Extent.EndOffset - $Extent.StartOffset
    $edit.Text = $Text
    $edit.Reason = $Reason
    return $edit
}

<#
    Produces the method body for one *-TargetResource function.

    $Method is the DSC method name (Get/Set/Test/Export) and drives the shim and telemetry text.
#>
function Convert-FunctionBody
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.Language.FunctionDefinitionAst]
        $Function,

        [Parameter(Mandatory = $true)]
        [System.String]
        $Method,

        [Parameter(Mandatory = $true)]
        [System.String]
        $ClassName,

        [Parameter(Mandatory = $true)]
        [System.String]
        $FileText,

        [Parameter(Mandatory = $true)]
        [System.Object]
        $PropertyName,

        [Parameter()]
        [System.Collections.Hashtable]
        $HelperRename = @{}
    )

    $edits = [System.Collections.Generic.List[ConversionEdit]]::new()
    $notes = [System.Collections.Generic.List[String]]::new()
    $body = $Function.Body

    # Names bound by a foreach are locals and shadow any schema property of the same name. Rewriting
    # them to $this.<Name> changes what the code means, and on the declaration it does not parse.
    $loopVariables = [System.Collections.Generic.HashSet[String]]::new([StringComparer]::OrdinalIgnoreCase)
    foreach ($loop in $body.FindAll({ $args[0] -is [ForEachStatementAst] }, $true))
    {
        [void] $loopVariables.Add($loop.Variable.VariablePath.UserPath)
    }

    # --- 1. the PowerShell 5.1 dispatch shim ---------------------------------------------------
    foreach ($ifStatement in $body.FindAll({ $args[0] -is [IfStatementAst] }, $true))
    {
        $condition = $ifStatement.Clauses[0].Item1.Extent.Text
        if ($condition -notmatch '\$PSEdition\s*-ne\s*[''"]Core[''"]')
        {
            continue
        }

        $replacement = switch ($Method)
        {
            # The extent starts at the `if` keyword, so the leading whitespace on that line survives:
            # the first line below carries no indentation of its own.
            'Get'
            {
                @"
if (`$this.RequiresPowerShellCore())
    {
        `$remote = [$ClassName]::new()
        `$remote.FromHashtable(`$this.InvokeInPowerShellCore('Get'))
        return `$remote
    }
"@
            }
            'Set'
            {
                @"
if (`$this.RequiresPowerShellCore())
    {
        `$null = `$this.InvokeInPowerShellCore('Set')
        return
    }
"@
            }
            'Export'
            {
                @"
if (`$this.RequiresPowerShellCore())
    {
        return [string] `$this.InvokeInPowerShellCore('Export')
    }
"@
            }
            default
            {
                @"
if (`$this.RequiresPowerShellCore())
    {
        return [bool] `$this.InvokeInPowerShellCore('$Method')
    }
"@
            }
        }

        $edits.Add((New-Edit -Extent $ifStatement.Extent -Text $replacement -Reason 'PS 5.1 dispatch shim'))
    }

    # --- 2. telemetry block --------------------------------------------------------------------
    # The $ResourceName / $CommandName / $data assignments plus the Add-M365DSCTelemetryEvent call,
    # collapsed to one base-class call.
    $telemetryStart = -1
    $telemetryEnd = -1

    $telemetryCall = $body.FindAll({
            $args[0] -is [CommandAst] -and
            $args[0].GetCommandName() -eq 'Add-M365DSCTelemetryEvent'
        }, $true) | Select-Object -First 1

    if ($null -ne $telemetryCall)
    {
        $start = $telemetryCall.Extent.StartOffset
        foreach ($assignment in $body.FindAll({ $args[0] -is [AssignmentStatementAst] }, $true))
        {
            $target = $assignment.Left.Extent.Text
            if ($target -in @('$ResourceName', '$CommandName', '$data') -and
                $assignment.Extent.StartOffset -lt $telemetryCall.Extent.StartOffset)
            {
                $start = [System.Math]::Min($start, $assignment.Extent.StartOffset)
            }
        }

        $telemetryStart = $start
        $telemetryEnd = $telemetryCall.Extent.EndOffset

        $edit = [ConversionEdit]::new()
        $edit.Offset = $start
        $edit.Length = $telemetryCall.Extent.EndOffset - $start
        $edit.Text = "`$this.AddTelemetry('$Method')"
        $edit.Reason = 'telemetry block'
        $edits.Add($edit)
    }

    # --- 3. commands ---------------------------------------------------------------------------
    foreach ($command in $body.FindAll({ $args[0] -is [CommandAst] }, $true))
    {
        $name = $command.GetCommandName()

        if ($name -eq 'New-M365DSCConnection')
        {
            $workload = $null
            $url = $null
            for ($i = 0; $i -lt $command.CommandElements.Count; $i++)
            {
                $element = $command.CommandElements[$i]
                if ($element -is [CommandParameterAst])
                {
                    # Lifted verbatim, these arguments would keep bare schema-property references
                    # that the overlap rule then drops.
                    if ($element.ParameterName -eq 'Workload' -and ($i + 1) -lt $command.CommandElements.Count)
                    {
                        $workload = Convert-EmbeddedPropertyReference -Expression $command.CommandElements[$i + 1] `
                            -PropertyName $PropertyName -LoopVariable $loopVariables
                    }
                    elseif ($element.ParameterName -eq 'Url' -and ($i + 1) -lt $command.CommandElements.Count)
                    {
                        $url = Convert-EmbeddedPropertyReference -Expression $command.CommandElements[$i + 1] `
                            -PropertyName $PropertyName -LoopVariable $loopVariables
                    }
                }
            }

            if ($null -ne $workload)
            {
                $text = if ($null -ne $url) { "`$this.Connect($workload, $url)" } else { "`$this.Connect($workload)" }
                $edits.Add((New-Edit -Extent $command.Extent -Text $text -Reason 'New-M365DSCConnection'))
            }
            else
            {
                $notes.Add("New-M365DSCConnection without a literal -Workload at line $($command.Extent.StartLineNumber); left as-is.")
            }
        }
        elseif ($name -eq 'New-M365DSCLogEntry')
        {
            $message = "'Error:'"
            for ($i = 0; $i -lt $command.CommandElements.Count; $i++)
            {
                $element = $command.CommandElements[$i]
                if ($element -is [CommandParameterAst] -and $element.ParameterName -eq 'Message' -and
                    ($i + 1) -lt $command.CommandElements.Count)
                {
                    $message = Convert-EmbeddedPropertyReference -Expression $command.CommandElements[$i + 1] `
                        -PropertyName $PropertyName -LoopVariable $loopVariables
                }
            }

            $edits.Add((New-Edit -Extent $command.Extent -Text "`$this.LogError(`$_, $message)" -Reason 'New-M365DSCLogEntry'))
        }
        elseif ($name -eq 'Get-TargetResource')
        {
            <#
                Two call shapes, converted differently.

                  Get-TargetResource @PSBoundParameters   $this already carries every value, so
                                                          $this.Get() is exact.
                  Get-TargetResource @params              $params carries the current item's key,
                                                          which $this does not. GetForExport applies
                                                          the hashtable first, and returns the
                                                          Hashtable that -Results expects.
            #>
            $splatted = @($command.CommandElements |
                    Where-Object { $_ -is [VariableExpressionAst] -and $_.Splatted })

            # Named arguments override the splat and are usually the per-item key, so they cannot be
            # dropped.
            $overrides = [System.Collections.Generic.List[String]]::new()
            for ($i = 0; $i -lt $command.CommandElements.Count; $i++)
            {
                $element = $command.CommandElements[$i]
                if ($element -is [CommandParameterAst] -and ($i + 1) -lt $command.CommandElements.Count)
                {
                    $argument = $command.CommandElements[$i + 1]
                    if ($argument -isnot [CommandParameterAst])
                    {
                        # Same lifting hazard as above.
                        $overrides.Add("$($element.ParameterName) = $(Convert-EmbeddedPropertyReference -Expression $argument -PropertyName $PropertyName -LoopVariable $loopVariables)")
                    }
                }
            }

            $splatName = $null
            if ($splatted.Count -eq 1 -and $splatted[0].VariablePath.UserPath -ne 'PSBoundParameters')
            {
                $splatName = $splatted[0].VariablePath.UserPath
            }

            if ($null -ne $splatName)
            {
                if ($overrides.Count -gt 0)
                {
                    $notes.Add(("Get-TargetResource at line {0} splats `${1} AND passes {2}; the " +
                            'overrides were not merged - review.') -f
                        $command.Extent.StartLineNumber, $splatName, ($overrides -join ', '))
                }

                $edits.Add((New-Edit -Extent $command.Extent `
                            -Text "`$this.GetForExport(`$$splatName)" `
                            -Reason 'Get-TargetResource with a per-item splat'))
            }
            elseif ($overrides.Count -gt 0)
            {
                # GetForExport applies the hashtable onto $this before calling Get(), so only the
                # overrides need passing.
                $edits.Add((New-Edit -Extent $command.Extent `
                            -Text ("`$this.GetForExport(@{{ {0} }})" -f ($overrides -join '; ')) `
                            -Reason 'Get-TargetResource with explicit overrides'))
            }
            else
            {
                # ToHashtable, because the code around the call site was written against one.
                $edits.Add((New-Edit -Extent $command.Extent -Text '$this.Get().ToHashtable()' -Reason 'Get-TargetResource call'))
            }
        }
        elseif ($name -eq 'Test-M365DSCTargetResource' -and
            -not @($command.CommandElements | Where-Object {
                    $_ -is [CommandParameterAst] -and $_.ParameterName -eq 'CurrentValues'
                }))
        {
            <#
                -CurrentValues is mandatory, and has to go at the END of the command. PowerShell
                evaluates arguments left to right and Get() writes the retrieved state onto $this,
                so a -CurrentValues placed ahead of -DesiredValues makes GetBoundParameters() read
                the state Get() just wrote and every comparison comes back "in the desired state".
            #>
            $append = [ConversionEdit]::new()
            $append.Offset = $command.Extent.EndOffset
            $append.Length = 0
            $append.Text = ' -CurrentValues $this.Get().ToHashtable()'
            $append.Reason = 'Test-M365DSCTargetResource requires -CurrentValues'
            $edits.Add($append)
        }
        elseif ($name -eq 'Get-CompareParameters')
        {
            # Emitted as the GetCompareParameters() override on the class, so the call has to become
            # a method call. Left as a command it parses fine and dies at runtime on the first Test().
            $edits.Add((New-Edit -Extent $command.Extent `
                        -Text '$this.GetCompareParameters()' `
                        -Reason 'Get-CompareParameters call'))
        }
        elseif ($name -and $HelperRename.ContainsKey($name))
        {
            # Only the name changes; all resources land in one generated part file.
            $edits.Add((New-Edit -Extent $command.CommandElements[0].Extent -Text $HelperRename[$name] -Reason "helper rename $name"))
        }
    }

    # --- 4. variables --------------------------------------------------------------------------
    foreach ($variable in $body.FindAll({ $args[0] -is [VariableExpressionAst] }, $true))
    {
        # Parameters are declared in the param block, which is dropped; skip those extents.
        if ($null -ne $body.ParamBlock -and
            $variable.Extent.StartOffset -ge $body.ParamBlock.Extent.StartOffset -and
            $variable.Extent.EndOffset -le $body.ParamBlock.Extent.EndOffset)
        {
            continue
        }

        $userPath = $variable.VariablePath.UserPath

        if ($userPath -eq 'PSBoundParameters')
        {
            $edits.Add((New-Edit -Extent $variable.Extent -Text '$this.GetBoundParameters()' -Reason '$PSBoundParameters'))
            continue
        }

        if ($userPath -eq 'PSScriptRoot')
        {
            $edits.Add((New-Edit -Extent $variable.Extent -Text '$this.GetModulePath()' -Reason '$PSScriptRoot'))
            continue
        }

        # Qualifying these explicitly also stops Repair-DefiniteAssignment from later "fixing" them
        # with a $null local, which parses cleanly and silently inverts what they were testing for.
        if ($userPath -in $script:AutomaticVariable)
        {
            $edits.Add((New-Edit -Extent $variable.Extent -Text "`$global:$userPath" -Reason "automatic variable `$$userPath"))
            continue
        }

        <#
            $ResourceName is assigned inside the telemetry block, which is collapsed away, but
            Export reads it again afterwards. Left alone it becomes an unassigned variable, which is
            a parse error in a class method. Only occurrences outside the collapsed span are
            rewritten; the ones inside go with the block.
        #>
        if ($userPath -eq 'ResourceName' -and $telemetryStart -ge 0 -and
            ($variable.Extent.StartOffset -lt $telemetryStart -or $variable.Extent.StartOffset -ge $telemetryEnd))
        {
            $edits.Add((New-Edit -Extent $variable.Extent -Text '$this.GetResourceName()' -Reason '$ResourceName after telemetry collapse'))
            continue
        }

        if ($userPath -eq 'CommandName' -and $telemetryStart -ge 0 -and
            ($variable.Extent.StartOffset -lt $telemetryStart -or $variable.Extent.StartOffset -ge $telemetryEnd))
        {
            $notes.Add("`$CommandName is read at line $($variable.Extent.StartLineNumber), outside the telemetry block; review manually.")
        }

        if ($userPath -match '^(?i)script:')
        {
            $bare = ($userPath -replace '^(?i)script:', '')

            # $Script:exportedInstance has a dedicated base-class field.
            if ($bare -eq 'exportedInstance')
            {
                $edits.Add((New-Edit -Extent $variable.Extent -Text '$this.ExportedInstance' -Reason '$Script:exportedInstance'))
            }
            else
            {
                $edits.Add((New-Edit -Extent $variable.Extent -Text "`$this.ResourceCache['$bare']" -Reason "`$Script:$bare"))
            }
            continue
        }

        # Loop-bound names are locals and shadow the schema property - see $loopVariables above.
        if ($loopVariables.Contains($userPath))
        {
            continue
        }

        if ($PropertyName.Contains($userPath))
        {
            # Inside an expandable string, "$this.DisplayName" expands the object and appends the
            # literal '.DisplayName'. It parses, so nothing catches it. A subexpression is required;
            # variables already inside "$( ... )" are fine as-is.
            $replacement = if ($variable.Parent -is [ExpandableStringExpressionAst])
            {
                "`$(`$this.$userPath)"
            }
            else
            {
                "`$this.$userPath"
            }

            $edits.Add((New-Edit -Extent $variable.Extent -Text $replacement -Reason 'schema property'))
        }
    }

    # --- 5. $MyInvocation.MyCommand.* -----------------------------------------------------------
    foreach ($member in $body.FindAll({ $args[0] -is [MemberExpressionAst] }, $true))
    {
        if ($member.Extent.Text -like '*MyInvocation.MyCommand*')
        {
            $edits.Add((New-Edit -Extent $member.Extent -Text '$this.GetResourceName()' -Reason '$MyInvocation.MyCommand'))
        }
    }

    # --- 6. return statements -------------------------------------------------------------------
    foreach ($statement in $body.FindAll({ $args[0] -is [ReturnStatementAst] }, $true))
    {
        # A bare `return` is legal in a function but not in a method with a declared return type -
        # "Not all code path returns value within method".
        if ($null -eq $statement.Pipeline)
        {
            if ($Method -eq 'Export')
            {
                $edits.Add((New-Edit -Extent $statement.Extent -Text "return ''" -Reason 'bare return in a [string] method'))
            }
            elseif ($Method -eq 'Test')
            {
                $edits.Add((New-Edit -Extent $statement.Extent -Text 'return $false' -Reason 'bare return in a [bool] method'))
            }

            continue
        }

        # A [void] method may not return a value.
        if ($Method -eq 'Set')
        {
            $edits.Add((New-Edit -Extent $statement.Extent -Text 'return' -Reason 'value returned from a [void] method'))
            continue
        }

        # Get() must return the class type, so the returned hashtable is wrapped in AsResult().
        if ($Method -eq 'Get')
        {
            $open = [ConversionEdit]::new()
            $open.Offset = $statement.Extent.StartOffset
            $open.Length = $statement.Pipeline.Extent.StartOffset - $statement.Extent.StartOffset
            $open.Text = 'return $this.AsResult('
            $open.Reason = 'Get returns the resource type (open)'
            $edits.Add($open)

            $close = [ConversionEdit]::new()
            $close.Offset = $statement.Pipeline.Extent.EndOffset
            $close.Length = 0
            $close.Text = ')'
            $close.Reason = 'Get returns the resource type (close)'
            $edits.Add($close)
        }
    }

    # --- apply ----------------------------------------------------------------------------------
    # The overlap rule: an edit fully inside another is dropped and the outer one wins. This is what
    # makes the telemetry-block collapse safe.
    $ordered = @($edits | Sort-Object Offset, @{ Expression = { $_.Length }; Descending = $true })
    $kept = [System.Collections.Generic.List[ConversionEdit]]::new()
    $coveredTo = -1

    foreach ($edit in $ordered)
    {
        if ($edit.Offset -lt $coveredTo)
        {
            continue
        }

        $kept.Add($edit)
        $coveredTo = $edit.Offset + $edit.Length
    }

    $text = $FileText
    foreach ($edit in ($kept | Sort-Object Offset -Descending))
    {
        $text = $text.Remove($edit.Offset, $edit.Length).Insert($edit.Offset, $edit.Text)
    }

    # Recompute the body extent by re-parsing the rewritten file.
    $errors = $null
    $rewritten = [Parser]::ParseInput($text, [ref] $null, [ref] $errors)
    $newFunction = ($rewritten.FindAll({ $args[0] -is [FunctionDefinitionAst] }, $false) |
            Where-Object { $_.Name -eq $Function.Name } | Select-Object -First 1)

    if ($null -eq $newFunction)
    {
        throw "Lost function '$($Function.Name)' while rewriting."
    }

    # Strip the outer braces, then the param block and the attributes that preceded it.
    $bodyText = $newFunction.Body.Extent.Text
    $bodyText = $bodyText.Substring(1, $bodyText.Length - 2)

    if ($null -ne $newFunction.Body.ParamBlock)
    {
        # [CmdletBinding()] and [OutputType()] are attributes on the param block and start before
        # its extent, so removing the param block alone leaves them behind as a parse error.
        $paramBlock = $newFunction.Body.ParamBlock
        $startOffset = $paramBlock.Extent.StartOffset
        foreach ($attribute in $paramBlock.Attributes)
        {
            $startOffset = [System.Math]::Min($startOffset, $attribute.Extent.StartOffset)
        }

        # Offsets are file-relative; the body text starts one character into the body extent.
        $relativeStart = $startOffset - $newFunction.Body.Extent.StartOffset - 1
        $relativeEnd = $paramBlock.Extent.EndOffset - $newFunction.Body.Extent.StartOffset - 1

        if ($relativeStart -ge 0 -and $relativeEnd -le $bodyText.Length -and $relativeEnd -gt $relativeStart)
        {
            $bodyText = $bodyText.Remove($relativeStart, $relativeEnd - $relativeStart)
        }
    }

    # Drop leading blank lines without touching the indentation of the first real one.
    $bodyText = [System.Text.RegularExpressions.Regex]::Replace($bodyText, '^(?:[ \t]*\r?\n)+', '')

    return @{
        Body  = $bodyText.TrimEnd()
        Notes = $notes
    }
}

<#
    Indents a converted method body by one level.

    Lines that are the content of a multi-line string must not be touched: here-string content is
    literal, and a here-string terminator ("@ or '@) has to sit at the very start of its line or it
    stops terminating the string. Those lines come from the token stream rather than a guess.
#>
function Add-MethodBodyIndent
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [System.String]
        $Body,

        [Parameter()]
        [System.Int32]
        $Width = 4
    )

    if ([String]::IsNullOrWhiteSpace($Body))
    {
        return $Body
    }

    $tokens = $null
    $errors = $null
    $null = [Parser]::ParseInput($Body, [ref] $tokens, [ref] $errors)

    $literalLines = [System.Collections.Generic.HashSet[Int32]]::new()

    foreach ($token in $tokens)
    {
        if ($token.Extent.StartLineNumber -eq $token.Extent.EndLineNumber)
        {
            continue
        }

        if ($token.Kind -notin @([TokenKind]::StringLiteral, [TokenKind]::StringExpandable,
                [TokenKind]::HereStringLiteral, [TokenKind]::HereStringExpandable))
        {
            continue
        }

        # Everything after the opening line, up to and including the closing line.
        for ($line = $token.Extent.StartLineNumber + 1; $line -le $token.Extent.EndLineNumber; $line++)
        {
            [void] $literalLines.Add($line)
        }
    }

    $indent = ' ' * $Width
    $lines = $Body -split "`r?`n"

    for ($index = 0; $index -lt $lines.Count; $index++)
    {
        if ($literalLines.Contains($index + 1))
        {
            continue
        }

        if ([String]::IsNullOrWhiteSpace($lines[$index]))
        {
            continue
        }

        $lines[$index] = $indent + $lines[$index]
    }

    return ($lines -join "`r`n")
}

<#
    Adds a terminal return to methods the parser reports as able to fall off the end - a method with
    a declared return type cannot, unlike a function.

    Which bodies need one is not obvious (if/else where both branches return is fine, try/catch
    where only the try returns is not), so the parser is asked rather than the rule modelled here.
#>
function Repair-MissingReturn
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Text,

        [Parameter()]
        [System.Int32]
        $MaxPass = 5
    )

    $repaired = [System.Collections.Generic.List[String]]::new()

    for ($pass = 0; $pass -lt $MaxPass; $pass++)
    {
        $errors = $null
        $ast = [Parser]::ParseInput($Text, [ref] $null, [ref] $errors)
        $flagged = @($errors | Where-Object { $_.ErrorId -eq 'MethodHasCodePathNotReturn' })

        if ($flagged.Count -eq 0)
        {
            break
        }

        $insertions = @{}

        foreach ($item in $flagged)
        {
            $method = ($ast.FindAll({ $args[0] -is [FunctionMemberAst] }, $true) |
                    Where-Object {
                        $_.Extent.StartOffset -le $item.Extent.StartOffset -and
                        $_.Extent.EndOffset -ge $item.Extent.EndOffset
                    } | Select-Object -Last 1)

            if ($null -eq $method -or $null -eq $method.Body)
            {
                continue
            }

            $returnType = ''
            if ($null -ne $method.ReturnType)
            {
                $returnType = $method.ReturnType.TypeName.FullName
            }

            $value = switch -Wildcard ($returnType)
            {
                '*string*' { "''" }
                '*bool*' { '$false' }
                default { '$null' }
            }

            # Just inside the method's closing brace.
            $offset = $method.Body.Extent.EndOffset - 1
            $insertions[$offset] = [PSCustomObject] @{
                Offset = $offset
                Name   = $method.Name
                Text   = "`r`n        # Every code path must return in a method with a declared return type.`r`n        return $value`r`n    "
            }
        }

        if ($insertions.Count -eq 0)
        {
            break
        }

        foreach ($insertion in ($insertions.Values | Sort-Object Offset -Descending))
        {
            $Text = $Text.Insert($insertion.Offset, $insertion.Text)
            $repaired.Add($insertion.Name)
        }
    }

    return @{
        Text     = $Text
        Repaired = @($repaired | Sort-Object -Unique)
    }
}

<#
    True when Test-TargetResource is the standard shape - telemetry plus a single
    Test-M365DSCTargetResource call - in which case the base class already implements it and no
    override is emitted.

    Command names alone are not enough: custom logic frequently contains no commands at all -
    assignments ($excludedProperties = @()), method calls ($ValuesToCheck.Remove(...)), if/throw
    statements, scriptblock definitions. So on top of the command check, every top-level statement
    must match one of the standard shapes; anything else makes the body non-standard.
#>
function Test-IsStandardTestBody
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.Language.FunctionDefinitionAst]
        $Function
    )

    $benign = @('Write-Verbose', 'Write-M365DSCHost', 'Convert-M365DscHashtableToString')
    $expected = @('Add-M365DSCTelemetryEvent', 'Format-M365DSCTelemetryParameters',
        'Invoke-PowerShellCoreResource', 'Test-M365DSCTargetResource')

    $commands = @($Function.Body.FindAll({ $args[0] -is [CommandAst] }, $true) |
            ForEach-Object { $_.GetCommandName() } |
            Where-Object { $_ -and $_ -notin $benign })

    if (@($commands | Where-Object { $_ -eq 'Test-M365DSCTargetResource' }).Count -ne 1)
    {
        return $false
    }

    if (@($commands | Where-Object { $_ -notin $expected }).Count -gt 0)
    {
        return $false
    }

    if ($null -eq $Function.Body.EndBlock)
    {
        return $false
    }

    foreach ($statement in $Function.Body.EndBlock.Statements)
    {
        # The PowerShell 5.1 dispatch shim.
        if ($statement -is [IfStatementAst] -and
            $statement.Clauses[0].Item1.Extent.Text -match '\$PSEdition\s*-ne\s*[''"]Core[''"]')
        {
            continue
        }

        if ($statement -is [AssignmentStatementAst])
        {
            # The telemetry block.
            if ($statement.Left.Extent.Text -in @('$ResourceName', '$CommandName', '$data'))
            {
                continue
            }

            # Capturing the comparison result before returning it.
            $rightCommands = @($statement.Right.FindAll({ $args[0] -is [CommandAst] }, $true) |
                    ForEach-Object { $_.GetCommandName() })
            if ($rightCommands -contains 'Test-M365DSCTargetResource')
            {
                continue
            }

            return $false
        }

        if ($statement -is [ReturnStatementAst])
        {
            $pipelineText = if ($null -ne $statement.Pipeline) { $statement.Pipeline.Extent.Text } else { '' }
            if ($pipelineText -match 'Test-M365DSCTargetResource' -or $pipelineText -match '^\$\w+$')
            {
                continue
            }

            return $false
        }

        if ($statement -is [PipelineAst])
        {
            $pipelineCommands = @($statement.FindAll({ $args[0] -is [CommandAst] }, $true) |
                    ForEach-Object { $_.GetCommandName() } | Where-Object { $_ })

            # An expression statement without any command (a bare method call, say) is custom logic.
            if ($pipelineCommands.Count -gt 0 -and
                @($pipelineCommands | Where-Object { $_ -notin ($benign + $expected) }).Count -eq 0)
            {
                continue
            }

            return $false
        }

        return $false
    }

    return $true
}

<#
    Adds `$name = $null` initialisers for variables PowerShell reports as unassigned.

    Class methods use definite-assignment analysis; plain functions do not. A variable first
    assigned inside an if/switch/try branch and read afterwards is perfectly legal in a function and
    a parse error - "Variable is not assigned in the method" - once the same body becomes a method.
    That pattern is everywhere in these resources.

    Rather than trying to model the control flow, this uses the parser itself as the oracle: parse,
    read the errors, insert an initialiser for each flagged name at the top of the method that
    contains it, repeat. It converges because each pass can only remove errors of this kind, and it
    stops if a pass makes no progress.
#>
function Repair-DefiniteAssignment
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Text,

        [Parameter()]
        [System.Object]
        $PropertyName = $null,

        [Parameter()]
        [System.Int32]
        $MaxPass = 10
    )

    $repaired = [System.Collections.Generic.List[String]]::new()
    $skipped = [System.Collections.Generic.List[String]]::new()

    for ($pass = 0; $pass -lt $MaxPass; $pass++)
    {
        $errors = $null
        $ast = [Parser]::ParseInput($Text, [ref] $null, [ref] $errors)
        $flagged = @($errors | Where-Object { $_.ErrorId -eq 'VariableNotLocal' })

        if ($flagged.Count -eq 0)
        {
            break
        }

        # name -> offset just inside the owning method body
        $insertions = @{}

        foreach ($item in $flagged)
        {
            $name = $item.Extent.Text.TrimStart('$')
            if ([String]::IsNullOrWhiteSpace($name))
            {
                continue
            }

            # Never declare a local that shadows a PowerShell automatic variable.
            if ($name -in $script:AutomaticVariable)
            {
                if (-not $skipped.Contains($name))
                {
                    $skipped.Add($name)
                }
                continue
            }

            <#
                Never declare a local that shadows a schema property. Doing so turns one parse error
                into another - "Cannot assign property, use '$this.X'" - and hides the real problem,
                which is a $X the property rewrite failed to reach. Record it instead.
            #>
            if ($null -ne $PropertyName -and $PropertyName.Contains($name))
            {
                if (-not $skipped.Contains($name))
                {
                    $skipped.Add($name)
                }
                continue
            }

            $method = ($ast.FindAll({ $args[0] -is [FunctionMemberAst] }, $true) |
                    Where-Object {
                        $_.Body.Extent.StartOffset -lt $item.Extent.StartOffset -and
                        $_.Body.Extent.EndOffset -gt $item.Extent.StartOffset
                    } | Select-Object -Last 1)

            if ($null -eq $method)
            {
                continue
            }

            $offset = $method.Body.Extent.StartOffset + 1
            $key = "$offset|$name"
            if (-not $insertions.ContainsKey($key))
            {
                $insertions[$key] = [PSCustomObject] @{ Offset = $offset; Name = $name }
            }
        }

        if ($insertions.Count -eq 0)
        {
            break
        }

        foreach ($insertion in ($insertions.Values | Sort-Object Offset -Descending))
        {
            $Text = $Text.Insert($insertion.Offset,
                "`r`n        # Declared up front: assigned conditionally below, which class methods reject.`r`n        `$$($insertion.Name) = `$null")
            $repaired.Add($insertion.Name)
        }
    }

    return @{
        Text     = $Text
        Repaired = @($repaired | Sort-Object -Unique)
        Skipped  = @($skipped | Sort-Object -Unique)
    }
}

#endregion

#region Convert one resource

function Convert-Resource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Path
    )

    $prefixed = [System.IO.Path]::GetFileNameWithoutExtension($Path)
    $friendly = $prefixed -replace '^MSFT_', ''
    $notes = [System.Collections.Generic.List[String]]::new()

    if (-not $script:Schema.ContainsKey($prefixed))
    {
        throw "No schema entry for '$prefixed' in SchemaDefinition.json."
    }

    $schema = $script:Schema[$prefixed]
    $fileText = Get-Content -Path $Path -Raw

    $errors = $null
    $ast = [Parser]::ParseInput($fileText, [ref] $null, [ref] $errors)
    if ($errors.Count -gt 0)
    {
        throw "Cannot parse '$Path': $($errors[0].Message)"
    }

    $functions = Get-FunctionDefinition -Ast $ast
    foreach ($required in @('Get-TargetResource', 'Set-TargetResource'))
    {
        if (-not $functions.ContainsKey($required))
        {
            throw "'$Path' has no $required."
        }
    }

    $propertyNames = [System.Collections.Generic.HashSet[String]]::new([StringComparer]::OrdinalIgnoreCase)
    foreach ($parameter in $schema.Parameters)
    {
        [void] $propertyNames.Add($parameter.Name)
    }

    # Export-only parameters (typically -Filter) are not schema, but the Export body reads them, so
    # they become plain properties without [DscProperty()].
    $extraProperties = [System.Collections.Generic.List[Object]]::new()
    if ($functions.ContainsKey('Export-TargetResource') -and
        $null -ne $functions['Export-TargetResource'].Body.ParamBlock)
    {
        foreach ($parameter in $functions['Export-TargetResource'].Body.ParamBlock.Parameters)
        {
            $name = $parameter.Name.VariablePath.UserPath
            if (-not $propertyNames.Contains($name))
            {
                [void] $propertyNames.Add($name)
                $type = 'System.String'
                if ($null -ne $parameter.StaticType -and $parameter.StaticType.FullName -ne 'System.Object')
                {
                    $type = $parameter.StaticType.FullName
                }

                $extraProperties.Add([PSCustomObject] @{ Name = $name; Type = $type })
            }
        }
    }

    $validation = Get-ParameterValidationAttribute -Function $functions['Get-TargetResource']

    <#
        Resource files routinely define private helpers next to the four entry points -
        Get-CompareParameters, Get-SettingValue, Get-M365DSCAzureADGroupLicenses and so on. Dropping
        them produces a class that parses cleanly and then fails at runtime on the first call, so
        they are carried across:

          Get-CompareParameters -> the GetCompareParameters() override the base class declares.
          anything else         -> a module-scope function in the same generated part file.

        The others are renamed, because the same helper names recur across many resources and every
        part file holds a batch of them. Call sites are rewritten to match.
    #>
    $mainFunctions = @('Get-TargetResource', 'Set-TargetResource', 'Test-TargetResource', 'Export-TargetResource')
    $helperRename = @{}
    $helperFunctions = [System.Collections.Generic.List[Object]]::new()

    foreach ($functionName in $functions.Keys)
    {
        if ($functionName -in $mainFunctions -or $functionName -eq 'Get-CompareParameters')
        {
            continue
        }

        $parts = $functionName -split '-', 2
        $renamed = if ($parts.Count -eq 2) { "$($parts[0])-$friendly$($parts[1])" } else { "$friendly$functionName" }

        $helperRename[$functionName] = $renamed
        $helperFunctions.Add([PSCustomObject] @{ Original = $functionName; Renamed = $renamed })
    }

    # --- class text -----------------------------------------------------------------------------
    $builder = [System.Text.StringBuilder]::new()

    <#
        Editor-only, and it must be the first statement in the file - a using statement has to
        precede everything else.

        Without it, opening this file in VS Code raises two parser errors and underlines the whole
        thing: TypeNotFound for [M365DSCResourceBase], and DscResourceMissingTestMethod because the
        parser cannot see the inherited Test(). Both are artefacts of parsing the file on its own;
        the built module is fine. They cannot be suppressed through editor settings, because they
        come from the parser rather than from PSScriptAnalyzer.

        It never reaches the shipped module. Build-Microsoft365DSC.ps1 emits only the class extent
        plus the helper-function extents, and a using statement is file-level - it is never inside
        a TypeDefinitionAst extent. The build asserts this rather than relying on it silently.
    #>
    [void] $builder.AppendLine('# Editor-only: lets this file resolve [M365DSCResourceBase] when parsed on its own.')
    [void] $builder.AppendLine('# Build-Microsoft365DSC.ps1 emits only the class extent, so this line is not shipped.')
    [void] $builder.AppendLine('using module ..\_Base\M365DSCResourceBase.psm1')
    [void] $builder.AppendLine('')

    [void] $builder.AppendLine('[DscResource()]')
    [void] $builder.AppendLine("class $friendly : M365DSCResourceBase")
    [void] $builder.AppendLine('{')

    foreach ($parameter in $schema.Parameters)
    {
        $attribute = switch ($parameter.Option)
        {
            'Key' { '[DscProperty(Key)]' }
            'Required' { '[DscProperty(Mandatory)]' }
            default { '[DscProperty()]' }
        }

        [void] $builder.AppendLine("    $attribute")

        if ($parameter.Description)
        {
            [void] $builder.AppendLine("    [System.ComponentModel.Description('$(Get-EscapedSingleQuoteString -Value $parameter.Description)')]")
        }

        if ($parameter.Values)
        {
            $set = (@($parameter.Values) | ForEach-Object { "'$(Get-EscapedSingleQuoteString -Value $_)'" }) -join ', '
            [void] $builder.AppendLine("    [ValidateSet($set)]")
        }

        if ($validation.ContainsKey($parameter.Name))
        {
            foreach ($extra in $validation[$parameter.Name])
            {
                [void] $builder.AppendLine("    $extra")
            }
        }

        [void] $builder.AppendLine("    [$(ConvertTo-ClassType -CimType $parameter.CIMType -NoNullable:($parameter.Option -eq 'Key'))] `$$($parameter.Name)")
        [void] $builder.AppendLine('')
    }

    foreach ($extra in $extraProperties)
    {
        [void] $builder.AppendLine('    # Export-only. Not part of the resource schema.')
        [void] $builder.AppendLine("    [$($extra.Type)] `$$($extra.Name)")
        [void] $builder.AppendLine('')
    }

    # --- methods ---------------------------------------------------------------------------------
    $methodMap = [ordered] @{
        'Get'    = @{ Function = 'Get-TargetResource'; Signature = "[$friendly] Get()" }
        'Set'    = @{ Function = 'Set-TargetResource'; Signature = '[void] Set()' }
        'Test'   = @{ Function = 'Test-TargetResource'; Signature = '[bool] Test()' }
        'Export' = @{ Function = 'Export-TargetResource'; Signature = '[string] Export()' }
    }

    foreach ($method in $methodMap.Keys)
    {
        $functionName = $methodMap[$method].Function
        if (-not $functions.ContainsKey($functionName))
        {
            $notes.Add("No $functionName; method omitted.")
            continue
        }

        if ($method -eq 'Test')
        {
            if (Test-IsStandardTestBody -Function $functions[$functionName])
            {
                # Emitted rather than left inherited, purely so editors stay quiet.
                [void] $builder.AppendLine('    [bool] Test()')
                [void] $builder.AppendLine('    {')
                [void] $builder.AppendLine('        return ([M365DSCResourceBase] $this).Test()')
                [void] $builder.AppendLine('    }')
                [void] $builder.AppendLine('')
                continue
            }

            $notes.Add('Test-TargetResource has a non-standard body; emitted as an override for review.')
        }

        $converted = Convert-FunctionBody -Function $functions[$functionName] `
            -Method $method `
            -ClassName $friendly `
            -FileText $fileText `
            -PropertyName $propertyNames `
            -HelperRename $helperRename

        foreach ($note in $converted.Notes)
        {
            $notes.Add("${method}: $note")
        }

        [void] $builder.AppendLine("    $($methodMap[$method].Signature)")
        [void] $builder.AppendLine('    {')
        [void] $builder.AppendLine((Add-MethodBodyIndent -Body $converted.Body))

        # A terminal return is added afterwards by Repair-MissingReturn, and only where the parser
        # says one is missing. Emitting it unconditionally left a second, unreachable return under
        # every body that already returned on all paths, which reads like a mistake.
        [void] $builder.AppendLine('    }')
        [void] $builder.AppendLine('')
    }

    # Get-CompareParameters becomes the override the base class already declares.
    if ($functions.ContainsKey('Get-CompareParameters'))
    {
        $converted = Convert-FunctionBody -Function $functions['Get-CompareParameters'] `
            -Method 'GetCompareParameters' `
            -ClassName $friendly `
            -FileText $fileText `
            -PropertyName $propertyNames `
            -HelperRename $helperRename

        foreach ($note in $converted.Notes)
        {
            $notes.Add("GetCompareParameters: $note")
        }

        [void] $builder.AppendLine('    # Was Get-CompareParameters. M365DSCResourceBase declares this; the default returns')
        [void] $builder.AppendLine('    # GetBoundParameters().')
        [void] $builder.AppendLine('    [System.Collections.Hashtable] GetCompareParameters()')
        [void] $builder.AppendLine('    {')
        [void] $builder.AppendLine((Add-MethodBodyIndent -Body $converted.Body))
        [void] $builder.AppendLine('    }')
        [void] $builder.AppendLine('')
    }

    # Helper the Get() rewrite depends on. Generated per class because a base-class version could
    # not return the derived type - PowerShell classes have no covariant returns.
    [void] $builder.AppendLine('    # Materialises a Get() result. The script-based body built a hashtable; DSC needs the type.')
    [void] $builder.AppendLine("    hidden [$friendly] AsResult([System.Object] `$Values)")
    [void] $builder.AppendLine('    {')
    [void] $builder.AppendLine("        if (`$Values -is [$friendly])")
    [void] $builder.AppendLine('        {')
    [void] $builder.AppendLine('            return $Values')
    [void] $builder.AppendLine('        }')
    [void] $builder.AppendLine('')
    [void] $builder.AppendLine("        `$result = [$friendly]::new()")
    [void] $builder.AppendLine('        $result.ClearNonSchemaProperties()')
    [void] $builder.AppendLine('        if ($Values -is [System.Collections.Hashtable])')
    [void] $builder.AppendLine('        {')
    [void] $builder.AppendLine('            $result.FromHashtable($Values)')
    [void] $builder.AppendLine('        }')
    [void] $builder.AppendLine('')
    [void] $builder.AppendLine('        return $result')
    [void] $builder.AppendLine('    }')
    [void] $builder.AppendLine('}')

    <#
        Complex types (the MOF EmbeddedInstance targets) are emitted as PLAIN classes - no
        [DscResource()], which would demand a Key plus Get/Set/Test and fail to parse.

        They are collected transitively, because complex types reference each other; AADGroup
        reaching MSFT_MicrosoftGraphAssignedLicense is only the first hop. The build deduplicates
        them across all resources into _Shared.psm1 and fails hard if two resources declare the same
        name differently.
    #>
    $emitted = [System.Collections.Generic.HashSet[String]]::new([StringComparer]::OrdinalIgnoreCase)
    $pending = [System.Collections.Generic.Queue[String]]::new()
    $typeText = [ordered] @{}
    $typeBase = @{}

    foreach ($parameter in $schema.Parameters)
    {
        $bare = $parameter.CIMType -replace '\[\]$', ''
        if ($bare -ne $prefixed -and $script:Schema.ContainsKey($bare) -and $bare -ne 'MSFT_Credential')
        {
            $pending.Enqueue($bare)
        }
    }

    while ($pending.Count -gt 0)
    {
        $typeName = $pending.Dequeue()
        if (-not $emitted.Add($typeName))
        {
            continue
        }

        $typeSchema = $script:Schema[$typeName]

        # Inherited members are declared on the base, not repeated here - same as the MOF.
        $baseType = $script:SuperClass[$typeName]
        if (-not [String]::IsNullOrEmpty($baseType) -and $script:Schema.ContainsKey($baseType))
        {
            $pending.Enqueue($baseType)
        }
        else
        {
            $baseType = $null
        }

        $typeBase[$typeName] = $baseType

        $typeBuilder = [System.Text.StringBuilder]::new()
        [void] $typeBuilder.AppendLine("class $typeName$(if ($baseType) { " : $baseType" })")
        [void] $typeBuilder.AppendLine('{')

        foreach ($parameter in $typeSchema.Parameters)
        {
            <#
                Carry Key/Required across. SchemaDefinition.json derives Option purely from this
                attribute once it is generated from the classes, and ResourceComparer uses those
                two options as the primary keys it aligns complex array elements by.
            #>
            $attribute = switch ($parameter.Option)
            {
                'Key' { '    [DscProperty(Key)]' }
                'Required' { '    [DscProperty(Mandatory)]' }
                default { '    [DscProperty()]' }
            }

            [void] $typeBuilder.AppendLine($attribute)

            if ($parameter.Description)
            {
                [void] $typeBuilder.AppendLine("    [System.ComponentModel.Description('$(Get-EscapedSingleQuoteString -Value $parameter.Description)')]")
            }

            <#
                No [ValidateSet] on complex-type members, deliberately. The MOF ValueMap on an
                embedded class was never enforced by anything - New-CimInstance -ClientOnly does
                not validate, and the MOF compiler only checks the resource's own properties - so
                the values a Get() legitimately produces were never held to it. Emitting one turns
                every such value into a hard conversion failure, and worse: [ValidateSet] derives
                from ValidateEnumeratedArgumentsAttribute, which rejects an EMPTY collection
                outright, so an ordinary `groupByAlertDetails = @()` cannot be assigned at all.
                The set still reaches SchemaDefinition.json from the MOF, and the resource's own
                properties keep their [ValidateSet].
            #>
            [void] $typeBuilder.AppendLine("    [$(ConvertTo-ClassType -CimType $parameter.CIMType)] `$$($parameter.Name)")

            $bare = $parameter.CIMType -replace '\[\]$', ''
            if ($bare -ne $typeName -and $bare -ne 'MSFT_Credential' -and
                $script:Schema.ContainsKey($bare) -and -not $emitted.Contains($bare))
            {
                $pending.Enqueue($bare)
            }
        }

        [void] $typeBuilder.AppendLine('}')
        $typeText[$typeName] = $typeBuilder.ToString()
    }

    <#
        A base class has to be defined before the class deriving from it, so the complex types are
        emitted depth-first over the inheritance edges rather than in discovery order. Property
        references need no ordering - PowerShell resolves those across the whole file - so
        inheritance is the only edge that matters here.
    #>
    $ordered = [System.Collections.Generic.List[String]]::new()
    $placed = [System.Collections.Generic.HashSet[String]]::new([StringComparer]::OrdinalIgnoreCase)

    $place = {
        param([String] $Name)

        if (-not $typeText.Contains($Name) -or -not $placed.Add($Name))
        {
            return
        }

        $base = $typeBase[$Name]
        if (-not [String]::IsNullOrEmpty($base))
        {
            & $place $base
        }

        $ordered.Add($Name)
    }

    foreach ($name in $typeText.Keys)
    {
        & $place $name
    }

    foreach ($name in $ordered)
    {
        [void] $builder.AppendLine('')
        [void] $builder.Append($typeText[$name])
    }

    if ($emitted.Count -gt 0)
    {
        $notes.Add("Emitted $($emitted.Count) complex type(s): $(($emitted | Sort-Object) -join ', ').")
    }

    # Private helpers, carried across as module-scope functions under a resource-specific name.
    foreach ($helper in $helperFunctions)
    {
        $definition = $functions[$helper.Original]
        $text = $definition.Extent.Text

        # Rename the declaration...
        $text = 'function ' + $helper.Renamed + $text.Substring($text.IndexOf($helper.Original) + $helper.Original.Length)

        # ...and the calls the body makes to its siblings. Helpers call each other - Get-...AsHashtable
        # calls ConvertTo-...PermissionName - and leaving those bodies verbatim points them at names
        # that no longer exist anywhere.
        $text = Update-HelperCallSite -Text $text -HelperRename $HelperRename

        [void] $builder.AppendLine('')
        [void] $builder.AppendLine($text)

        $notes.Add("Helper $($helper.Original) emitted as $($helper.Renamed).")
    }

    # Insert `$x = $null` where a conditionally assigned variable is read - legal in a function,
    # rejected in a method.
    $repair = Repair-DefiniteAssignment -Text $builder.ToString() -PropertyName $propertyNames
    if ($repair.Repaired.Count -gt 0)
    {
        $notes.Add("Declared up front for definite assignment: $($repair.Repaired -join ', ').")
    }

    # Only the methods that can actually fall off the end get a terminal return.
    $returnRepair = Repair-MissingReturn -Text $repair.Text
    if ($returnRepair.Repaired.Count -gt 0)
    {
        $notes.Add("Terminal return added to: $($returnRepair.Repaired -join ', ').")
    }

    if ($repair.Skipped.Count -gt 0)
    {
        $notes.Add(("Reported unassigned but they are schema properties, so the rewrite missed a " +
                "reference - REVIEW: $($repair.Skipped -join ', ')."))
    }

    return @{
        Name  = $friendly
        Text  = $returnRepair.Text
        Notes = $notes
    }
}

#endregion

#region Main

# -WhatIf:$false on purpose. Under -WhatIf the converted resource files are deliberately not
# written, but the run is still expected to produce its report - that is report-only mode - and the
# report needs somewhere to go.
$null = New-Item -Path $OutputPath -ItemType Directory -Force -WhatIf:$false

# Mirror _Base into the output tree.
$baseSource = Join-Path -Path $script:SourceRoot -ChildPath '_Base'
$baseTarget = Join-Path -Path $OutputPath -ChildPath '_Base'

# GetFullPath rather than Resolve-Path: under -WhatIf the output directory was never created, and
# Resolve-Path throws on a path that does not exist.
$outputFull = [System.IO.Path]::GetFullPath($OutputPath).TrimEnd('\', '/')
$sourceFull = [System.IO.Path]::GetFullPath($script:SourceRoot).TrimEnd('\', '/')

if ((Test-Path -Path $baseSource) -and $outputFull -ne $sourceFull -and (Test-Path -Path $OutputPath))
{
    $null = New-Item -Path $baseTarget -ItemType Directory -Force
    Copy-Item -Path (Join-Path -Path $baseSource -ChildPath '*.psm1') -Destination $baseTarget -Force
}

$candidates = @(Get-ChildItem -Path $script:SourceRoot -Directory -Filter 'MSFT_*' |
        ForEach-Object {
            $file = Join-Path -Path $_.FullName -ChildPath "$($_.Name).psm1"
            if (Test-Path -Path $file) { Get-Item -Path $file }
        })

if ($ResourceName)
{
    $patterns = @($ResourceName | ForEach-Object { $_ -replace '^MSFT_', '' })
    $candidates = @($candidates | Where-Object {
            $friendly = $_.BaseName -replace '^MSFT_', ''
            $matched = $false
            foreach ($pattern in $patterns)
            {
                if ($friendly -like $pattern) { $matched = $true }
            }
            $matched
        })
}

Write-Host "[convert] $($candidates.Count) resource(s) selected" -ForegroundColor Cyan

$report = [System.Collections.Generic.List[Object]]::new()
$succeeded = 0

<#
.SYNOPSIS
    Rewrites New-CimInstance literals in a converted resource body into class instances.

.DESCRIPTION
    A handful of resources build their complex values with
    New-CimInstance -ClassName MSFT_X -Property @{ ... } -Namespace root/Microsoft/Windows/DesiredStateConfiguration.
    That is the MOF representation; the property those values are assigned to is now declared as
    the class, and a CimInstance does not convert to it - the assignment fails outright.

    Expressed as two edits per call, the prefix up to the -Property hashtable and the suffix after
    it, so nested calls inside that hashtable keep their own spans and the descending-offset
    application below stays correct.
#>
function Convert-CimInstanceLiteral
{
    [CmdletBinding()]
    [OutputType([String])]
    param
    (
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [String]
        $Text
    )

    $ast = [Parser]::ParseInput($Text, [ref] $null, [ref] $null)
    $edits = [System.Collections.Generic.List[Object]]::new()

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
            $propertyValue = @($command.CommandElements | Where-Object { $_ -is [HashtableAst] })[0]
        }

        <#
            -Property is not always a hashtable literal; several call sites pass a variable or a
            member expression holding one. Casting that works just as well, so any single
            expression is accepted here.
        #>
        if ($null -eq $className -or $className -isnot [StringConstantExpressionAst] -or
            $null -eq $propertyValue -or $propertyValue -isnot [ExpressionAst])
        {
            continue
        }

        $edits.Add([PSCustomObject] @{
                Offset = $command.Extent.StartOffset
                Length = $propertyValue.Extent.StartOffset - $command.Extent.StartOffset
                Text   = "[$($className.Value)] "
            })

        $edits.Add([PSCustomObject] @{
                Offset = $propertyValue.Extent.EndOffset
                Length = $command.Extent.EndOffset - $propertyValue.Extent.EndOffset
                Text   = ''
            })
    }

    <#
        .CimInstanceProperties has no counterpart on a class instance, so the whole expression
        evaluates to $null and the .GetEnumerator() after it throws "You cannot call a method on a
        null-valued expression". PSObject.Properties is the equivalent enumeration and yields
        members with .Name and .Value.

        Note this deliberately does not "fix" the call sites that read .Key off the enumerated item:
        a CimProperty exposes Name and Value, never Key, so those comparisons were already silently
        matching nothing before the conversion. Preserving that keeps the rewrite behaviour-neutral;
        turning a latent no-op into a live check is a separate decision for whoever owns the
        resource.
    #>
    foreach ($member in $ast.FindAll({ $args[0] -is [MemberExpressionAst] }, $true))
    {
        if ($member.Member -isnot [StringConstantExpressionAst] -or
            $member.Member.Value -ne 'CimInstanceProperties')
        {
            continue
        }

        $edits.Add([PSCustomObject] @{
                Offset = $member.Member.Extent.StartOffset
                Length = $member.Member.Extent.EndOffset - $member.Member.Extent.StartOffset
                Text   = 'PSObject.Properties'
            })
    }

    foreach ($edit in ($edits | Sort-Object Offset -Descending))
    {
        $Text = $Text.Remove($edit.Offset, $edit.Length).Insert($edit.Offset, $edit.Text)
    }

    return $Text
}

foreach ($candidate in $candidates)
{
    $friendlyName = $candidate.BaseName -replace '^MSFT_', ''

    try
    {
        $result = Convert-Resource -Path $candidate.FullName
        $result.Text = Convert-CimInstanceLiteral -Text $result.Text

        $targetDir = Join-Path -Path $OutputPath -ChildPath $candidate.Directory.Name
        $null = New-Item -Path $targetDir -ItemType Directory -Force
        $targetFile = Join-Path -Path $targetDir -ChildPath $candidate.Name

        if ($PSCmdlet.ShouldProcess($targetFile, 'Write converted resource'))
        {
            Set-Content -Path $targetFile -Value $result.Text -Encoding UTF8

            $readMe = Join-Path -Path $candidate.DirectoryName -ChildPath 'readme.md'
            if (Test-Path -Path $readMe)
            {
                Copy-Item -Path $readMe -Destination $targetDir -Force
            }
        }

        # Parse the result. TypeNotFound and DscResourceMissingTestMethod are expected here: the
        # base class lives in another file and Test() is usually inherited.
        $parseErrors = $null
        $null = [Parser]::ParseInput($result.Text, [ref] $null, [ref] $parseErrors)
        $fatal = @($parseErrors | Where-Object { $_.ErrorId -notin @('TypeNotFound', 'DscResourceMissingTestMethod') })

        $status = if ($fatal.Count -eq 0) { 'OK' } else { 'ParseError' }
        if ($fatal.Count -eq 0)
        {
            $succeeded++
        }

        $report.Add([PSCustomObject] @{
                Resource    = $result.Name
                Status      = $status
                ParseErrors = @($fatal | ForEach-Object { "$($_.ErrorId) line $($_.Extent.StartLineNumber): $($_.Message)" })
                Notes       = @($result.Notes)
            })

        $color = if ($status -eq 'OK') { 'Green' } else { 'Red' }
        Write-Host ("  {0,-55} {1}" -f $result.Name, $status) -ForegroundColor $color
        foreach ($note in $result.Notes)
        {
            Write-Host "      note: $note" -ForegroundColor DarkGray
        }
        foreach ($parseError in $fatal)
        {
            Write-Host "      $($parseError.ErrorId) line $($parseError.Extent.StartLineNumber): $($parseError.Message)" -ForegroundColor Red
        }
    }
    catch
    {
        $report.Add([PSCustomObject] @{
                Resource    = $friendlyName
                Status      = 'Failed'
                ParseErrors = @()
                Notes       = @($_.Exception.Message)
            })
        Write-Host ("  {0,-55} FAILED: {1}" -f $friendlyName, $_.Exception.Message) -ForegroundColor Red
    }
}

# -WhatIf:$false so report-only runs still emit the report they exist to produce.
ConvertTo-Json -InputObject ([Object[]] $report) -Depth 10 |
    Set-Content -Path $ReportPath -Encoding UTF8 -WhatIf:$false

Write-Host ''
Write-Host "[convert] $succeeded / $($candidates.Count) converted cleanly" -ForegroundColor $(if ($succeeded -eq $candidates.Count) { 'Green' } else { 'Yellow' })
Write-Host "[convert] report: $ReportPath" -ForegroundColor Cyan

#endregion
