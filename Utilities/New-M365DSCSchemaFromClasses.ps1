#Requires -Version 5.1

<#
.SYNOPSIS
    Regenerates SchemaDefinition.json by reflecting over the built class-based resources.

.DESCRIPTION
    Replaced the MOF-based generator, which walked *.schema.mof with regular expressions. Once
    resources are classes there are no .mof files to walk, and the class metadata is richer and
    cannot drift from the code.

    The output shape is unchanged, because it is consumed at runtime:

        [ { "ClassName": "MSFT_AADGroup",
            "Description": "...",
            "Parameters": [ { "CIMType": "String", "Description": "...", "Name": "Id",
                              "Option": "Key", "ValueMap": [...], "Values": [...] } ] } ]

    Note the ClassName stays MSFT_-prefixed for resources even though the CLASS is named without
    the prefix. Test-M365DSCTargetResource looks the resource up as "MSFT_$ResourceName"
    (M365DSCUtil.psm1), so changing it here would break every drift check.

    Reflection runs in a child PowerShell 7 process. The module has to be imported for the types to
    exist, and importing it into the build's own session would pin the files and prevent a
    subsequent rebuild from overwriting them.

.PARAMETER RepositoryRoot
    Root of the Microsoft365DSC repository.

.EXAMPLE
    .\New-M365DSCSchemaFromClasses.ps1

.NOTES
    Called by Utilities/Build-Microsoft365DSC.ps1. Safe to run on its own against an already-built
    module.
#>

[CmdletBinding(SupportsShouldProcess)]
param
(
    [Parameter()]
    [System.String]
    $RepositoryRoot = (Split-Path -Path $PSScriptRoot -Parent)
)

$ErrorActionPreference = 'Stop'

$moduleRoot = Join-Path -Path $RepositoryRoot -ChildPath 'Modules/Microsoft365DSC'
$manifestPath = Join-Path -Path $moduleRoot -ChildPath 'Microsoft365DSC.psd1'
$outputPath = Join-Path -Path $moduleRoot -ChildPath 'SchemaDefinition.json'
$sourceRoot = Join-Path -Path $moduleRoot -ChildPath 'DscResources'

if (-not (Test-Path -Path $manifestPath))
{
    throw "Manifest not found: $manifestPath"
}

# Resource descriptions still come from readme.md, exactly as the MOF-based generator did.
$descriptions = @{}
foreach ($directory in (Get-ChildItem -Path $sourceRoot -Directory -Filter 'MSFT_*'))
{
    $readMePath = Join-Path -Path $directory.FullName -ChildPath 'readme.md'
    if (-not (Test-Path -Path $readMePath))
    {
        continue
    }

    $readMe = Get-Content -Path $readMePath -Raw
    $parts = $readMe -split '## Description'
    if ($parts.Count -gt 1)
    {
        $descriptions[$directory.Name] = $parts[1].Trim()
    }
}

$descriptionJson = $descriptions | ConvertTo-Json -Depth 5 -Compress
$propertyDescriptions = @{}
$propertyBase = @{}
foreach ($sourceFile in (Get-ChildItem -Path $sourceRoot -Directory -Filter 'MSFT_*' |
            ForEach-Object { Join-Path -Path $_.FullName -ChildPath "$($_.Name).psm1" } |
            Where-Object { Test-Path -Path $_ }))
{
    $ast = [System.Management.Automation.Language.Parser]::ParseFile($sourceFile, [ref] $null, [ref] $null)

    foreach ($typeDefinition in $ast.FindAll({ $args[0] -is [System.Management.Automation.Language.TypeDefinitionAst] }, $false))
    {
        if (-not $propertyDescriptions.ContainsKey($typeDefinition.Name))
        {
            $propertyDescriptions[$typeDefinition.Name] = @{}
        }

        $map = $propertyDescriptions[$typeDefinition.Name]

        if ($typeDefinition.BaseTypes.Count -gt 0 -and -not $propertyBase.ContainsKey($typeDefinition.Name))
        {
            $propertyBase[$typeDefinition.Name] = $typeDefinition.BaseTypes[0].TypeName.Name
        }

        foreach ($member in $typeDefinition.Members)
        {
            if ($member -isnot [System.Management.Automation.Language.PropertyMemberAst] -or $map.ContainsKey($member.Name))
            {
                continue
            }

            foreach ($attribute in $member.Attributes)
            {
                if ($attribute.TypeName.FullName -notin @('System.ComponentModel.Description',
                        'System.ComponentModel.DescriptionAttribute', 'Description', 'DescriptionAttribute'))
                {
                    continue
                }

                $argument = @($attribute.PositionalArguments)[0]
                if ($argument -is [System.Management.Automation.Language.StringConstantExpressionAst])
                {
                    $map[$member.Name] = $argument.Value
                }
            }
        }
    }
}

#Fold each base class's descriptions into the classes deriving from it.
foreach ($className in @($propertyBase.Keys))
{
    $chain = [System.Collections.Generic.List[String]]::new()
    $current = $propertyBase[$className]
    while (-not [String]::IsNullOrEmpty($current) -and $propertyDescriptions.ContainsKey($current) -and -not $chain.Contains($current))
    {
        $chain.Add($current)
        $current = $propertyBase[$current]
    }

    $map = $propertyDescriptions[$className]
    foreach ($baseName in $chain)
    {
        foreach ($entry in $propertyDescriptions[$baseName].GetEnumerator())
        {
            if (-not $map.ContainsKey($entry.Key))
            {
                $map[$entry.Key] = $entry.Value
            }
        }
    }
}

$propertyDescriptionJson = $propertyDescriptions | ConvertTo-Json -Depth 5 -Compress

$reflect = @'
param([string] $ManifestPath, [string] $DescriptionPath, [string] $PropertyDescriptionPath)

$ErrorActionPreference = 'Stop'
Import-Module $ManifestPath -Force -WarningAction SilentlyContinue
$descriptions = (Get-Content -Path $DescriptionPath -Raw) | ConvertFrom-Json
$propertyDescriptions = (Get-Content -Path $PropertyDescriptionPath -Raw) | ConvertFrom-Json -AsHashtable

$module = Get-Module -Name 'Microsoft365DSC'

$payload = & $module {
    param($descriptions, $propertyDescriptions)

    function ConvertTo-CimType
    {
        param([Type] $Type)

        $isArray = $Type.IsArray
        $bare = if ($isArray) { $Type.GetElementType() } else { $Type }

        # Value-type properties are declared as Nullable[T] so that "omitted" stays distinguishable
        # from "specified as $false / 0" across DSC's reflection boundary. The schema must keep
        # reporting the underlying MOF type, so unwrap before mapping.
        $underlying = [System.Nullable]::GetUnderlyingType($bare)
        if ($null -ne $underlying)
        {
            $bare = $underlying
        }

        $mapped = switch ($bare.FullName)
        {
            'System.String' { 'String' }
            'System.Boolean' { 'Boolean' }
            'System.DateTime' { 'DateTime' }
            'System.Int16' { 'SInt16' }
            'System.Int32' { 'SInt32' }
            'System.Int64' { 'SInt64' }
            'System.UInt16' { 'Uint16' }
            'System.UInt32' { 'UInt32' }
            'System.UInt64' { 'UInt64' }
            'System.Double' { 'Real64' }
            'System.Management.Automation.PSCredential' { 'MSFT_Credential' }
            default { $bare.Name }
        }

        if ($isArray) { return "$mapped[]" }
        return $mapped
    }

    function Get-ParameterInfo
    {
        param([Type] $Type, [string[]] $ExcludeNames, [hashtable] $DescriptionMap = @{})

        $result = [System.Collections.Generic.List[Object]]::new()

        foreach ($property in $Type.GetProperties())
        {
            if ($property.Name -in $ExcludeNames) { continue }
            if (-not $property.CanWrite) { continue }

            $option = 'Write'
            $isDsc = $false
            $description = ''
            $validValues = $null

            $declaring = $property.DeclaringType.Name
            if ($DescriptionMap.ContainsKey($declaring) -and $DescriptionMap[$declaring].ContainsKey($property.Name))
            {
                $description = $DescriptionMap[$declaring][$property.Name]
            }

            foreach ($attribute in $property.GetCustomAttributes($true))
            {
                if ($attribute -is [System.Management.Automation.DscPropertyAttribute])
                {
                    $isDsc = $true
                    if ($attribute.Key) { $option = 'Key' }
                    elseif ($attribute.Mandatory) { $option = 'Required' }
                }
                elseif ($attribute -is [System.ComponentModel.DescriptionAttribute])
                {
                    # Only present when the module was built with -KeepDescriptions.
                    $description = $attribute.Description
                }
                elseif ($attribute -is [System.Management.Automation.ValidateSetAttribute])
                {
                    $validValues = $attribute.ValidValues
                }
            }

            if (-not $isDsc) { continue }

            $entry = [ordered] @{
                CIMType     = ConvertTo-CimType -Type $property.PropertyType
                Description = $description
                Name        = $property.Name
                Option      = $option
            }

            if ($null -ne $validValues)
            {
                # ValueMap and Values are identical off a [ValidateSet]; the MOF form allowed them
                # to differ but nothing in the codebase relies on that.
                $entry.ValueMap = [String[]] $validValues
                $entry.Values = [String[]] $validValues
            }

            $result.Add($entry)
        }

        return $result
    }

    function Get-CompareParameterInfo
    {
        param([Type] $Type)

        $declared = $null
        try
        {
            $declared = $Type::new().GetCompareParameters()
        }
        catch
        {
            [Console]::Out.WriteLine("WARNING: $($Type.Name).GetCompareParameters() failed. Its comparison parameters are missing from SchemaDefinition.json: $($_.Exception.Message)")
            return @{}
        }

        if ($null -eq $declared -or $declared.Count -eq 0)
        {
            return @{}
        }

        $result = @{}
        $parameters = [ordered] @{}

        foreach ($name in @('ExcludedProperties', 'IncludedProperties'))
        {
            if (-not $declared.ContainsKey($name))
            {
                continue
            }

            $values = @([System.String[]] $declared[$name])
            if ($values.Count -gt 0)
            {
                $parameters[$name] = $values
            }
        }

        if ($parameters.Count -gt 0)
        {
            $result['CompareParameters'] = $parameters
        }

        if ($declared.ContainsKey('PostProcessing') -and $null -ne $declared['PostProcessing'])
        {
            $result['HasPostProcessing'] = $true
        }

        return $result
    }

    $baseMembers = [M365DSCResourceBase].GetProperties().Name
    $classInfo = [System.Collections.Generic.List[Object]]::new()

    # --- resource classes, via the registry each part populates at import ---
    foreach ($name in ([M365DSCResourceBase]::GetRegisteredNames() | Sort-Object))
    {
        $type = [M365DSCResourceBase]::Resolve($name)
        $prefixed = "MSFT_$name"

        $entry = [ordered] @{
            ClassName   = $prefixed
            Parameters  = @(Get-ParameterInfo -Type $type -ExcludeNames $baseMembers `
                    -DescriptionMap $propertyDescriptions)
            Description = $(if ($descriptions.PSObject.Properties.Name -contains $prefixed) { $descriptions.$prefixed } else { '' })
        }

        foreach ($compareEntry in (Get-CompareParameterInfo -Type $type).GetEnumerator())
        {
            $entry[$compareEntry.Key] = $compareEntry.Value
        }

        $classInfo.Add($entry)
    }

    <#
        --- complex types ---

        PowerShell emits one dynamic assembly per module, so the complex types are spread over the
        Classes/_Types<NN>.psm1 assemblies and none of them is [M365DSCResourceBase]'s. Reach them
        by following property types out of the resource classes and on through the complex types
        they embed, collecting assemblies until nothing new turns up. Then enumerate those whole,
        so a type that only some other complex type embeds is still picked up.
    #>
    $infrastructure = @('M365DSCResourceBase', 'M365DSCResourceInfo', 'M365DSCPropertyMeta')

    $seed = [System.Collections.Generic.List[Type]]::new()
    foreach ($name in [M365DSCResourceBase]::GetRegisteredNames())
    {
        $seed.Add([M365DSCResourceBase]::Resolve($name))
    }

    $assemblies = [System.Collections.Generic.HashSet[System.Reflection.Assembly]]::new()
    $pending = [System.Collections.Generic.Queue[Type]]::new()
    $visited = [System.Collections.Generic.HashSet[Type]]::new()

    foreach ($type in $seed)
    {
        $pending.Enqueue($type)
    }

    while ($pending.Count -gt 0)
    {
        $current = $pending.Dequeue()
        if (-not $visited.Add($current))
        {
            continue
        }

        foreach ($property in $current.GetProperties())
        {
            $candidate = if ($property.PropertyType.IsArray) { $property.PropertyType.GetElementType() } else { $property.PropertyType }

            if (-not $candidate.IsClass -or $candidate.Name -notlike 'MSFT_*')
            {
                continue
            }

            if ($assemblies.Add($candidate.Assembly))
            {
                foreach ($sibling in $candidate.Assembly.GetTypes())
                {
                    $pending.Enqueue($sibling)
                }
            }

            $pending.Enqueue($candidate)
        }
    }

    $complexTypes = @($assemblies | ForEach-Object { $_.GetTypes() } | Sort-Object Name)

    foreach ($type in $complexTypes)
    {
        if ($type.Name -in $infrastructure) { continue }
        if ($type.IsEnum) { continue }
        if ($type.IsSubclassOf([M365DSCResourceBase])) { continue }

        # PowerShell emits a compiler-generated <staticHelpers> type per class into the same
        # assembly. Those are not schema.
        if ($type.Name.Contains('<')) { continue }

        $classInfo.Add([ordered] @{
                ClassName   = $type.Name
                Parameters  = @(Get-ParameterInfo -Type $type -ExcludeNames @() `
                        -DescriptionMap $propertyDescriptions)
                Description = ''
            })
    }

    return $classInfo
} $descriptions $propertyDescriptions

# -InputObject with an explicit array cast: piping a one-element collection would unroll it and
# emit a bare JSON object, and every consumer of SchemaDefinition.json expects a top-level array.
ConvertTo-Json -InputObject ([Object[]] $payload) -Depth 99 -Compress
'@

$scriptFile = Join-Path -Path ([System.IO.Path]::GetTempPath()) ("m365dsc-schema-{0}.ps1" -f [Guid]::NewGuid())
Set-Content -Path $scriptFile -Value $reflect -Encoding UTF8

try
{
    $descriptionFile = "$scriptFile.desc.json"
    Set-Content -Path $descriptionFile -Value $descriptionJson -Encoding UTF8

    $propertyDescriptionFile = "$scriptFile.propdesc.json"
    Set-Content -Path $propertyDescriptionFile -Value $propertyDescriptionJson -Encoding UTF8

    $outputFile = "$scriptFile.out"
    $process = Start-Process -FilePath 'pwsh' -PassThru -Wait -NoNewWindow -RedirectStandardOutput $outputFile `
        -ArgumentList @('-NoProfile', '-NonInteractive', '-File', $scriptFile,
                        '-ManifestPath', $manifestPath, '-DescriptionPath', $descriptionFile,
                        '-PropertyDescriptionPath', $propertyDescriptionFile)

    $json = if (Test-Path -Path $outputFile) { Get-Content -Path $outputFile } else { $null }

    foreach ($line in @($json | Where-Object { $_.StartsWith('WARNING: ') }))
    {
        Write-Warning -Message $line.Substring('WARNING: '.Length)
    }

    if ($process.ExitCode -ne 0 -or [string]::IsNullOrWhiteSpace(($json -join '')))
    {
        throw "Reflection failed: $json"
    }

    # StartsWith, not -like: '[' opens a wildcard character class, so '[*' is not a valid pattern.
    $json = @($json | Where-Object { $_.TrimStart().StartsWith('[') } | Select-Object -Last 1)[0]
    $parsed = $json | ConvertFrom-Json
    if ($parsed.Count -eq 0)
    {
        throw 'Reflection produced an empty schema.'
    }

    if ($PSCmdlet.ShouldProcess($outputPath, 'Write SchemaDefinition.json'))
    {
        Set-Content -Path $outputPath -Value $json -Encoding UTF8
        Write-Host "[schema] Wrote $($parsed.Count) class definitions to SchemaDefinition.json" -ForegroundColor Green
    }
}
finally
{
    Remove-Item -Path $scriptFile, "$scriptFile.desc.json", "$scriptFile.propdesc.json", "$scriptFile.out" `
        -Force -ErrorAction SilentlyContinue
}
