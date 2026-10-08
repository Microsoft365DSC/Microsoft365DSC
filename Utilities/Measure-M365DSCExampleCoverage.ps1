#Requires -Version 5.1

<#
.SYNOPSIS
    Reports how much of each resource's schema the files under Examples/Resources actually configure.

.DESCRIPTION
    Read-only report over Examples/Resources, checking three conventions:

      1-Create.ps1 / 2-Update.ps1  configure every configurable non-auth property that is valid
                                   alongside the values already chosen.
      2-Update.ps1                 differs from its 1-Create sibling in at least one property.
      3-Remove.ps1                 carries nothing beyond keys, mandatory properties, the
                                   authentication properties and Ensure = 'Absent'.

    Keys must also be identical across the three files.

    Schema comes from the class sources by AST and the examples from a brace-depth scanner, so no
    built module is needed. A missing 1-Create or 3-Remove is reported through Shape, never counted
    against Verdict - update-only is the correct shape for singleton resources.

.PARAMETER RepositoryRoot
    Root of the Microsoft365DSC repository.

.PARAMETER Workload
    One or more workload prefixes to limit the report to, e.g. AAD, EXO, Intune, Teams.

.PARAMETER ResourceName
    One or more resource names, wildcards allowed, e.g. 'AADGroup*'.

.PARAMETER CoverageThreshold
    Percentage of configurable properties a Create/Update example must use to count as compliant.

.PARAMETER NonCompliantOnly
    Emit only the resources whose Verdict is NeedsWork.

.PARAMETER Format
    Object (default) emits the objects so they compose with Where-Object and Sort-Object.
    Json and Csv write to -OutputPath.

.PARAMETER OutputPath
    Destination file. Required when -Format is Json or Csv.

.PARAMETER Summary
    Emit one rollup row per workload instead of one row per resource.

.EXAMPLE
    .\Measure-M365DSCExampleCoverage.ps1 -Workload Teams -NonCompliantOnly

.EXAMPLE
    .\Measure-M365DSCExampleCoverage.ps1 -Summary

.EXAMPLE
    .\Measure-M365DSCExampleCoverage.ps1 -Workload AAD -Format Json -OutputPath .\aad-coverage.json
#>

[CmdletBinding()]
param
(
    [Parameter()]
    [System.String]
    $RepositoryRoot = (Split-Path -Path $PSScriptRoot -Parent),

    [Parameter()]
    [System.String[]]
    $Workload,

    [Parameter()]
    [System.String[]]
    $ResourceName,

    [Parameter()]
    [ValidateRange(0, 100)]
    [System.Int32]
    $CoverageThreshold = 70,

    [Parameter()]
    [Switch]
    $NonCompliantOnly,

    [Parameter()]
    [ValidateSet('Object', 'Json', 'Csv')]
    [System.String]
    $Format = 'Object',

    [Parameter()]
    [System.String]
    $OutputPath,

    [Parameter()]
    [Switch]
    $Summary
)

$ErrorActionPreference = 'Stop'

if ($Format -ne 'Object' -and -not $OutputPath)
{
    throw "-OutputPath is required when -Format is '$Format'."
}

$script:AuthenticationProperties = @(
    'Credential'
    'ApplicationId'
    'TenantId'
    'ApplicationSecret'
    'CertificateThumbprint'
    'CertificatePassword'
    'CertificatePath'
    'ManagedIdentity'
    'AccessTokens'
)

$script:StructuralProperties = @('Ensure', 'IsSingleInstance')

$script:IntrinsicProperties = @('DependsOn', 'PsDscRunAsCredential')

$script:WorkloadPrefixes = @(
    'ODSettings', 'Commerce', 'Defender', 'Sentinel', 'M365DSC', 'Planner', 'Fabric'
    'Intune', 'Viva', 'Azure', 'Teams', 'ADO', 'AAD', 'EXO', 'SPO', 'SC', 'PP', 'SH', 'O365'
) | Sort-Object -Property Length -Descending

function Get-M365DSCWorkloadName
{
    [OutputType([System.String])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Name
    )

    foreach ($prefix in $script:WorkloadPrefixes)
    {
        if ($Name.StartsWith($prefix, [System.StringComparison]::OrdinalIgnoreCase))
        {
            return $prefix
        }
    }

    return 'Other'
}

function Get-M365DSCClassSchema
{
    [OutputType([System.Object])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Path
    )

    $ast = [System.Management.Automation.Language.Parser]::ParseFile($Path, [ref] $null, [ref] $null)
    $typeDefinitions = $ast.FindAll(
        { $args[0] -is [System.Management.Automation.Language.TypeDefinitionAst] },
        $false)

    $resourceType = $typeDefinitions | Where-Object -FilterScript {
        $_.Attributes.TypeName.Name -contains 'DscResource'
    } | Select-Object -First 1

    if ($null -eq $resourceType)
    {
        return $null
    }

    $properties = [System.Collections.Generic.List[Object]]::new()
    foreach ($member in $resourceType.Members)
    {
        if ($member -isnot [System.Management.Automation.Language.PropertyMemberAst])
        {
            continue
        }

        $dscProperty = $member.Attributes | Where-Object -FilterScript { $_.TypeName.Name -eq 'DscProperty' }
        if (-not $dscProperty)
        {
            continue
        }

        $qualifiers = @($dscProperty.PositionalArguments | ForEach-Object { $_.Extent.Text }) +
                      @($dscProperty.NamedArguments | ForEach-Object { $_.ArgumentName })

        $validateSet = $member.Attributes | Where-Object -FilterScript { $_.TypeName.Name -eq 'ValidateSet' }
        $allowedValues = @()
        if ($validateSet)
        {
            $allowedValues = @($validateSet.PositionalArguments | ForEach-Object {
                    $_.Extent.Text.Trim("'", '"')
                })
        }

        $typeName = $member.PropertyType.TypeName.FullName
        $isArray = $typeName.EndsWith('[]')
        $bareType = $typeName.TrimEnd('[', ']')
        if ($bareType -match '^System\.Nullable\[(?<inner>.+)\]$')
        {
            $bareType = $Matches['inner']
        }

        $properties.Add([PSCustomObject] @{
                Name          = $member.Name
                IsKey         = ($qualifiers -contains 'Key')
                IsMandatory   = ($qualifiers -contains 'Mandatory')
                Type          = $bareType
                IsArray       = $isArray
                AllowedValues = $allowedValues
            })
    }

    $complexTypes = @{}
    foreach ($typeDefinition in $typeDefinitions)
    {
        if ($typeDefinition -eq $resourceType)
        {
            continue
        }

        $members = @{}
        foreach ($member in $typeDefinition.Members)
        {
            if ($member -isnot [System.Management.Automation.Language.PropertyMemberAst])
            {
                continue
            }

            $validateSet = $member.Attributes | Where-Object -FilterScript { $_.TypeName.Name -eq 'ValidateSet' }
            if (-not $validateSet)
            {
                continue
            }

            $members[$member.Name] = [PSCustomObject] @{
                AllowedValues = @($validateSet.PositionalArguments | ForEach-Object { $_.Extent.Text.Trim("'", '"') })
                IsArray       = $member.PropertyType.TypeName.FullName.EndsWith('[]')
            }
        }

        if ($members.Count -gt 0)
        {
            $complexTypes[$typeDefinition.Name] = $members
        }
    }

    return [PSCustomObject] @{
        ClassName    = $resourceType.Name
        Properties   = $properties
        ComplexTypes = $complexTypes
    }
}

function Get-M365DSCExampleProperties
{
    [OutputType([System.Object])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Path,

        [Parameter(Mandatory = $true)]
        [System.String]
        $ResourceType
    )

    $lines = [System.IO.File]::ReadAllLines($Path)
    $assignments = [ordered] @{}
    $markers = [System.Collections.Generic.List[String]]::new()

    $nested = [System.Collections.Generic.List[Object]]::new()
    $stack = [System.Collections.Generic.Stack[Object]]::new()
    $pendingType = $null

    $inBlock = $false
    $depth = 0
    $current = $null
    $currentValue = $null

    $headerPattern = '^\s*' + [regex]::Escape($ResourceType) + '\s+(''[^'']*''|"[^"]*"|\S+)\s*\{?\s*$'

    for ($index = 0; $index -lt $lines.Count; $index++)
    {
        $line = $lines[$index]

        if (-not $inBlock)
        {
            if ($line -match $headerPattern)
            {
                $inBlock = $true
                $depth = 0
                if ($line.TrimEnd().EndsWith('{'))
                {
                    $depth = 1
                }
            }

            continue
        }

        if ($depth -eq 0)
        {
            if ($line.Trim() -eq '{')
            {
                $depth = 1
            }

            continue
        }

        # Masked for brace counting, unmasked for the value itself.
        $masked = Remove-M365DSCLineNoise -Line $line -MaskLiterals
        $literal = Remove-M365DSCLineNoise -Line $line
        $openers = ([regex]::Matches($masked, '[\{\(]')).Count
        $closers = ([regex]::Matches($masked, '[\}\)]')).Count
        $depthBefore = $depth

        if ($depthBefore -gt 1 -and $stack.Count -gt 0 -and
            $masked -match '^\s*(?<name>[A-Za-z_][A-Za-z0-9_]*)\s*=')
        {
            $memberName = $Matches['name']
            $memberValue = ''
            if ($literal -match '^\s*[A-Za-z_][A-Za-z0-9_]*\s*=(?<value>.*)$')
            {
                $memberValue = $Matches['value'].Trim()
            }

            $nested.Add([PSCustomObject] @{
                    Type   = $stack.Peek().Type
                    Member = $memberName
                    Value  = $memberValue
                })
        }

        if ($depthBefore -eq 1 -and $masked -match '^\s*(?<name>[A-Za-z_][A-Za-z0-9_]*)\s*=')
        {
            if ($null -ne $current)
            {
                $assignments[$current] = $currentValue
            }

            $current = $Matches['name']
            $currentValue = ''
            if ($literal -match '^\s*[A-Za-z_][A-Za-z0-9_]*\s*=(?<value>.*)$')
            {
                $currentValue = $Matches['value'].Trim()
            }

            if ($line -match '#\s*Updated\s*Propert(y|ies)')
            {
                $markers.Add($current)
            }
        }
        elseif ($null -ne $current -and $depthBefore -gt 1)
        {
            $currentValue = $currentValue + ' ' + $literal.Trim()
        }

        $opened = @([regex]::Matches($masked, '(?<t>MSFT_[A-Za-z0-9_]+)\s*\{') |
                ForEach-Object { $_.Groups['t'].Value })
        foreach ($openedType in $opened)
        {
            $stack.Push([PSCustomObject] @{ Type = $openedType; Depth = $depthBefore })
        }

        if ($opened.Count -eq 0)
        {
            if ($masked -match '(?<t>MSFT_[A-Za-z0-9_]+)\s*$')
            {
                $pendingType = $Matches['t']
            }
            elseif ($null -ne $pendingType -and $masked.Trim() -eq '{')
            {
                $stack.Push([PSCustomObject] @{ Type = $pendingType; Depth = $depthBefore })
                $pendingType = $null
            }
        }

        $depth = $depth + $openers - $closers

        while ($stack.Count -gt 0 -and $depth -le $stack.Peek().Depth)
        {
            $null = $stack.Pop()
        }

        if ($depth -le 0)
        {
            if ($null -ne $current)
            {
                $assignments[$current] = $currentValue
                $current = $null
            }

            break
        }
    }

    if ($null -ne $current)
    {
        $assignments[$current] = $currentValue
    }

    return [PSCustomObject] @{
        Assignments = $assignments
        Markers     = $markers
        Nested      = $nested
    }
}

# -MaskLiterals blanks string contents so brace counting survives punctuation in a value.
function Remove-M365DSCLineNoise
{
    [OutputType([System.String])]
    param
    (
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [System.String]
        $Line,

        [Parameter()]
        [Switch]
        $MaskLiterals
    )

    $result = [System.Text.StringBuilder]::new()
    $quote = [char] 0
    $index = 0

    while ($index -lt $Line.Length)
    {
        $character = $Line[$index]

        if ($character -eq '`' -and $index + 1 -lt $Line.Length)
        {
            if ($MaskLiterals)
            {
                $null = $result.Append(' ').Append(' ')
            }
            else
            {
                $null = $result.Append($character).Append($Line[$index + 1])
            }

            $index += 2
            continue
        }

        if ($quote -ne [char] 0)
        {
            $null = $result.Append($(if ($MaskLiterals) { ' ' } else { $character }))
            if ($character -eq $quote)
            {
                $quote = [char] 0
            }

            $index++
            continue
        }

        if ($character -eq '''' -or $character -eq '"')
        {
            $quote = $character
            $null = $result.Append($(if ($MaskLiterals) { ' ' } else { $character }))
            $index++
            continue
        }

        if ($character -eq '#')
        {
            break
        }

        $null = $result.Append($character)
        $index++
    }

    return $result.ToString()
}

function Get-M365DSCExampleShape
{
    [OutputType([System.String])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Boolean]
        $HasCreate,

        [Parameter(Mandatory = $true)]
        [System.Boolean]
        $HasUpdate,

        [Parameter(Mandatory = $true)]
        [System.Boolean]
        $HasRemove
    )

    if ($HasCreate -and $HasUpdate -and $HasRemove) { return 'CreateUpdateRemove' }
    if ($HasCreate -and $HasUpdate) { return 'CreateUpdate' }
    if ($HasCreate -and $HasRemove) { return 'CreateRemove' }
    if ($HasUpdate -and $HasRemove) { return 'UpdateRemove' }
    if ($HasCreate) { return 'CreateOnly' }
    if ($HasUpdate) { return 'UpdateOnly' }
    if ($HasRemove) { return 'RemoveOnly' }

    return 'Missing'
}

$resourcesRoot = Join-Path -Path $RepositoryRoot -ChildPath 'Modules/Microsoft365DSC/DscResources'
$examplesRoot = Join-Path -Path $RepositoryRoot -ChildPath 'Examples/Resources'

foreach ($required in @($resourcesRoot, $examplesRoot))
{
    if (-not (Test-Path -Path $required))
    {
        throw "Path not found: $required"
    }
}

$results = [System.Collections.Generic.List[Object]]::new()

$resourceDirectories = Get-ChildItem -Path $resourcesRoot -Directory -Filter 'MSFT_*'
foreach ($resourceDirectory in $resourceDirectories)
{
    $friendlyName = $resourceDirectory.Name -replace '^MSFT_', ''

    if ($ResourceName -and -not ($ResourceName | Where-Object -FilterScript { $friendlyName -like $_ }))
    {
        continue
    }

    $resourceWorkload = Get-M365DSCWorkloadName -Name $friendlyName
    if ($Workload -and $resourceWorkload -notin $Workload)
    {
        continue
    }

    $sourceFile = Join-Path -Path $resourceDirectory.FullName -ChildPath "$($resourceDirectory.Name).psm1"
    if (-not (Test-Path -Path $sourceFile))
    {
        continue
    }

    $schema = Get-M365DSCClassSchema -Path $sourceFile
    if ($null -eq $schema)
    {
        continue
    }

    $keys = @($schema.Properties | Where-Object -FilterScript { $_.IsKey } | ForEach-Object { $_.Name })
    $mandatory = @($schema.Properties | Where-Object -FilterScript { $_.IsMandatory -and -not $_.IsKey } |
            ForEach-Object { $_.Name })
    $declared = @($schema.Properties | ForEach-Object { $_.Name })
    $configurable = @($schema.Properties | Where-Object -FilterScript {
            $_.Name -notin $script:AuthenticationProperties -and $_.Name -notin $script:StructuralProperties
        } | ForEach-Object { $_.Name })
    $isSingleInstance = ($declared -contains 'IsSingleInstance')
    $allowedInRemove = @($keys + $mandatory + $script:AuthenticationProperties + $script:StructuralProperties)

    $exampleDirectory = Join-Path -Path $examplesRoot -ChildPath $friendlyName
    $fileIssues = [System.Collections.Generic.List[String]]::new()

    if (-not (Test-Path -Path $exampleDirectory))
    {
        $results.Add([PSCustomObject] @{
                ResourceName     = $friendlyName
                Workload         = $resourceWorkload
                Shape            = 'Missing'
                Verdict          = 'NeedsWork'
                Reasons          = @('No example folder')
            })
        continue
    }

    $exampleFiles = @(Get-ChildItem -Path $exampleDirectory -File)
    foreach ($stray in ($exampleFiles | Where-Object -FilterScript { $_.Extension -ne '.ps1' }))
    {
        $fileIssues.Add("$($stray.Name) is not a .ps1 file and will not be run in integration")
    }
    foreach ($spaced in ($exampleFiles | Where-Object -FilterScript { $_.Name -match '\s' }))
    {
        $fileIssues.Add("$($spaced.Name) has spaces in its name and never runs in integration")
    }
    if ($exampleFiles.Count -eq 0)
    {
        $fileIssues.Add('Example folder is empty')
    }

    $createPath = Join-Path -Path $exampleDirectory -ChildPath '1-Create.ps1'
    $updatePath = Join-Path -Path $exampleDirectory -ChildPath '2-Update.ps1'
    $removePath = Join-Path -Path $exampleDirectory -ChildPath '3-Remove.ps1'

    $hasCreate = Test-Path -Path $createPath
    $hasUpdate = Test-Path -Path $updatePath
    $hasRemove = Test-Path -Path $removePath

    if (-not $hasRemove)
    {
        $offPattern = @($exampleFiles | Where-Object -FilterScript {
                $_.Name -match 'Remove' -and $_.Name -ne '3-Remove.ps1'
            })
        foreach ($file in $offPattern)
        {
            $fileIssues.Add("$($file.Name) is a remove example under an off-pattern name, but the integration engine only looks at 3-Remove.ps1")
        }
    }

    $create = if ($hasCreate) { Get-M365DSCExampleProperties -Path $createPath -ResourceType $friendlyName } else { $null }
    $update = if ($hasUpdate) { Get-M365DSCExampleProperties -Path $updatePath -ResourceType $friendlyName } else { $null }
    $remove = if ($hasRemove) { Get-M365DSCExampleProperties -Path $removePath -ResourceType $friendlyName } else { $null }

    $unknown = [System.Collections.Generic.List[String]]::new()
    $invalidValues = [System.Collections.Generic.List[String]]::new()
    $markerNoise = [System.Collections.Generic.List[String]]::new()

    foreach ($entry in @(
            @{ Name = '1-Create.ps1'; Data = $create }
            @{ Name = '2-Update.ps1'; Data = $update }
            @{ Name = '3-Remove.ps1'; Data = $remove }))
    {
        if ($null -eq $entry.Data)
        {
            continue
        }

        foreach ($property in $entry.Data.Assignments.Keys)
        {
            if ($property -in $script:IntrinsicProperties)
            {
                continue
            }

            if ($property -notin $declared)
            {
                $unknown.Add("$($entry.Name): $property")
                continue
            }

            $definition = $schema.Properties | Where-Object -FilterScript { $_.Name -eq $property } | Select-Object -First 1
            if ($definition.AllowedValues.Count -gt 0 -and -not $definition.IsArray)
            {
                $value = "$($entry.Data.Assignments[$property])".Trim().TrimEnd(';').Trim().Trim("'", '"')
                if ($value -and $value -notmatch '^\$' -and $value -notin $definition.AllowedValues)
                {
                    $invalidValues.Add("$($entry.Name): $property = '$value'")
                }
            }
        }

        foreach ($member in $entry.Data.Nested)
        {
            $type = $schema.ComplexTypes[$member.Type]
            if ($null -eq $type -or -not $type.ContainsKey($member.Member))
            {
                continue
            }

            $definition = $type[$member.Member]
            if ($definition.IsArray)
            {
                continue
            }

            $value = "$($member.Value)".Trim().TrimEnd(';').Trim().Trim("'", '"')
            if ($value -and $value -notmatch '^[\$@]' -and $value -notin $definition.AllowedValues)
            {
                $invalidValues.Add("$($entry.Name): $($member.Type).$($member.Member) = '$value'")
            }
        }

        if ($entry.Name -ne '2-Update.ps1' -and $entry.Data.Markers.Count -gt 0)
        {
            $markerNoise.Add("$($entry.Name): $($entry.Data.Markers -join ', ')")
        }
    }

    $createUsed = @()
    $createMissing = @()
    $createCoverage = $null
    if ($null -ne $create)
    {
        $createUsed = @($configurable | Where-Object -FilterScript { $create.Assignments.Contains($_) })
        $createMissing = @($configurable | Where-Object -FilterScript { -not $create.Assignments.Contains($_) })
        $createCoverage = if ($configurable.Count -eq 0) { 100 } else {
            [System.Math]::Round(100 * $createUsed.Count / $configurable.Count, 1)
        }
    }

    $updateUsed = @()
    $updateMissing = @()
    $updateCoverage = $null
    if ($null -ne $update)
    {
        $updateUsed = @($configurable | Where-Object -FilterScript { $update.Assignments.Contains($_) })
        $updateMissing = @($configurable | Where-Object -FilterScript { -not $update.Assignments.Contains($_) })
        $updateCoverage = if ($configurable.Count -eq 0) { 100 } else {
            [System.Math]::Round(100 * $updateUsed.Count / $configurable.Count, 1)
        }
    }

    $driftCount = $null
    $drifted = @()
    if ($null -ne $create -and $null -ne $update)
    {
        foreach ($property in $update.Assignments.Keys)
        {
            if (-not $create.Assignments.Contains($property))
            {
                continue
            }

            $left = "$($create.Assignments[$property])".Trim().TrimEnd(';').Trim()
            $right = "$($update.Assignments[$property])".Trim().TrimEnd(';').Trim()
            if ($left -cne $right)
            {
                $drifted += $property
            }
        }

        $driftCount = $drifted.Count
    }

    $removeExtra = @()
    if ($null -ne $remove)
    {
        $removeExtra = @($remove.Assignments.Keys | Where-Object -FilterScript {
                $_ -in $declared -and $_ -notin $allowedInRemove
            })
    }

    $keyMismatch = [System.Collections.Generic.List[String]]::new()
    foreach ($key in $keys)
    {
        $values = [ordered] @{}
        foreach ($entry in @(
                @{ Name = '1-Create.ps1'; Data = $create }
                @{ Name = '2-Update.ps1'; Data = $update }
                @{ Name = '3-Remove.ps1'; Data = $remove }))
        {
            if ($null -eq $entry.Data -or -not $entry.Data.Assignments.Contains($key))
            {
                continue
            }

            $values[$entry.Name] = "$($entry.Data.Assignments[$key])".Trim().TrimEnd(';').Trim().Trim("'", '"')
        }

        if ($values.Count -lt 2)
        {
            continue
        }

        $distinct = @($values.Values | Select-Object -Unique)
        if ($distinct.Count -gt 1)
        {
            $rendered = @($values.Keys | ForEach-Object { "$_ = $($values[$_])" })
            $keyMismatch.Add("$key differs: $($rendered -join ' | ')")
        }
    }

    $reasons = [System.Collections.Generic.List[String]]::new()

    if ($null -ne $createCoverage -and $createCoverage -lt $CoverageThreshold)
    {
        $reasons.Add("1-Create coverage $createCoverage% below $CoverageThreshold%")
    }
    if ($null -ne $updateCoverage -and $updateCoverage -lt $CoverageThreshold)
    {
        $reasons.Add("2-Update coverage $updateCoverage% below $CoverageThreshold%")
    }
    if ($driftCount -eq 0)
    {
        $reasons.Add('2-Update does not drift from 1-Create')
    }
    if ($removeExtra.Count -gt 0)
    {
        $reasons.Add("3-Remove carries $($removeExtra.Count) property(ies) beyond key, mandatory, auth and Ensure")
    }
    if ($unknown.Count -gt 0)
    {
        $reasons.Add("$($unknown.Count) property(ies) not declared on the class")
    }
    if ($invalidValues.Count -gt 0)
    {
        $reasons.Add("$($invalidValues.Count) value(s) outside the property's ValidateSet")
    }
    if ($markerNoise.Count -gt 0)
    {
        $reasons.Add("'# Updated Property' marker outside 2-Update.ps1")
    }
    if ($keyMismatch.Count -gt 0)
    {
        $reasons.Add("$($keyMismatch.Count) key value(s) not identical across the examples")
    }
    if ($fileIssues.Count -gt 0)
    {
        $reasons.Add("$($fileIssues.Count) file issue(s)")
    }

    $results.Add([PSCustomObject] @{
            ResourceName          = $friendlyName
            Workload              = $resourceWorkload
            Shape                 = (Get-M365DSCExampleShape -HasCreate $hasCreate -HasUpdate $hasUpdate -HasRemove $hasRemove)
            IsSingleInstance      = $isSingleInstance
            KeyProperties         = $keys
            MandatoryProperties   = $mandatory
            ConfigurableCount     = $configurable.Count
            CreateCoveragePercent = $createCoverage
            CreateMissing         = $createMissing
            UpdateCoveragePercent = $updateCoverage
            UpdateMissing         = $updateMissing
            DriftCount            = $driftCount
            DriftedProperties     = $drifted
            RemoveExtra           = $removeExtra
            RemoveExtraCount      = $removeExtra.Count
            UnknownProperties     = $unknown
            InvalidEnumValues     = $invalidValues
            MarkerNoise           = $markerNoise
            KeyMismatch           = $keyMismatch
            FileIssues            = $fileIssues
            Verdict               = $(if ($reasons.Count -gt 0) { 'NeedsWork' } else { 'Compliant' })
            Reasons               = $reasons
        })
}

$output = $results
if ($NonCompliantOnly)
{
    $output = @($output | Where-Object -FilterScript { $_.Verdict -eq 'NeedsWork' })
}

if ($Summary)
{
    $output = @($output | Group-Object -Property Workload | ForEach-Object {
            $group = $_.Group
            [PSCustomObject] @{
                Workload           = $_.Name
                Resources          = $group.Count
                MeanCreateCoverage = [System.Math]::Round((
                        $group | Where-Object -FilterScript { $null -ne $_.CreateCoveragePercent } |
                            Measure-Object -Property CreateCoveragePercent -Average).Average, 1)
                MeanUpdateCoverage = [System.Math]::Round((
                        $group | Where-Object -FilterScript { $null -ne $_.UpdateCoveragePercent } |
                            Measure-Object -Property UpdateCoveragePercent -Average).Average, 1)
                BelowThreshold     = @($group | Where-Object -FilterScript {
                        ($null -ne $_.CreateCoveragePercent -and $_.CreateCoveragePercent -lt $CoverageThreshold) -or
                        ($null -ne $_.UpdateCoveragePercent -and $_.UpdateCoveragePercent -lt $CoverageThreshold)
                    }).Count
                ZeroDrift          = @($group | Where-Object -FilterScript { $_.DriftCount -eq 0 }).Count
                RemoveNoisy        = @($group | Where-Object -FilterScript { $_.RemoveExtraCount -gt 0 }).Count
                FileIssues         = @($group | Where-Object -FilterScript { $_.FileIssues.Count -gt 0 }).Count
                NeedsWork          = @($group | Where-Object -FilterScript { $_.Verdict -eq 'NeedsWork' }).Count
            }
        } | Sort-Object -Property Resources -Descending)
}

switch ($Format)
{
    'Json'
    {
        $output | ConvertTo-Json -Depth 6 | Set-Content -Path $OutputPath -Encoding UTF8
        Write-Verbose -Message "Wrote $(@($output).Count) row(s) to $OutputPath"
    }
    'Csv'
    {
        $flattened = $output | ForEach-Object {
            $row = [ordered] @{}
            foreach ($property in $_.PSObject.Properties)
            {
                $row[$property.Name] = if ($property.Value -is [System.Collections.IEnumerable] -and
                    $property.Value -isnot [System.String])
                {
                    (@($property.Value) -join '; ')
                }
                else
                {
                    $property.Value
                }
            }

            [PSCustomObject] $row
        }

        $flattened | Export-Csv -Path $OutputPath -NoTypeInformation -Encoding UTF8
        Write-Verbose -Message "Wrote $(@($flattened).Count) row(s) to $OutputPath"
    }
    default
    {
        $output
    }
}
