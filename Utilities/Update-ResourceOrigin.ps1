#Requires -Version 7.3

<#
.SYNOPSIS
    Fills the generatedFrom block of every resource's settings.json.

.DESCRIPTION
    Derives the workload, the cmdlet noun and the Graph entity type of a resource from its module,
    its commands array, Utilities/cmdlet-mapping.json and the Graph CSDL. Nothing is guessed.
    Whatever cannot be derived lands in the unresolved worklist with its reason.

.PARAMETER RepositoryRoot
    Root of the Microsoft365DSC repository. Defaults to the parent of this script's folder.

.PARAMETER ResourcePath
    Folder holding the MSFT_<Name> resource folders. Defaults to Modules/Microsoft365DSC/DscResources.

.PARAMETER CmdletMappingPath
    Path to cmdlet-mapping.json. Defaults to Utilities/cmdlet-mapping.json.

.PARAMETER UnresolvedPath
    Path of the Markdown worklist. Defaults to Utilities/ApiSurface/generatedfrom-unresolved.md.

.PARAMETER CsdlPathV1
    Optional path to a v1.0 CSDL file. The generator's cached download is used when it is empty.

.PARAMETER CsdlPathBeta
    Optional path to a beta CSDL file. The generator's cached download is used when it is empty.

.PARAMETER ResourceFilter
    Wildcard on the resource name without MSFT_. A filtered run merges its rows into the worklist.

.PARAMETER Force
    Recomputes generatedFrom for resources that already carry a resolved block. A recorded fact the
    run cannot derive again is kept rather than overwritten with a null.

.EXAMPLE
    ./Utilities/Update-ResourceOrigin.ps1 -Verbose

.EXAMPLE
    ./Utilities/Update-ResourceOrigin.ps1 -ResourceFilter 'AAD*' -Force

.OUTPUTS
    A summary object with the resolved, unresolved, skipped and written counts plus the unresolved rows.
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
    $UnresolvedPath,

    [Parameter()]
    [System.String]
    $CsdlPathV1,

    [Parameter()]
    [System.String]
    $CsdlPathBeta,

    [Parameter()]
    [System.String]
    $ResourceFilter = '*',

    [Parameter()]
    [switch]
    $Force
)

$ErrorActionPreference = 'Stop'

$script:GraphWorkloads = @('MicrosoftGraph', 'Intune')
$script:CmdletWorkloads = @('ExchangeOnline', 'SecurityComplianceCenter', 'MicrosoftTeams', 'PnP', 'PowerPlatforms')
$script:CrudVerbs = @('Get', 'New', 'Update', 'Set', 'Remove')
$script:IgnoredCommandModules = @('MSCloudLoginAssistant', 'Microsoft.Graph.Authentication')
$script:LookupNouns = @(
    'MgGroup', 'MgBetaGroup', 'MgUser', 'MgBetaUser', 'MgServicePrincipal', 'MgBetaServicePrincipal',
    'MgApplication', 'MgBetaApplication', 'MgDirectoryObjectById', 'MgBetaDirectoryObjectById',
    'MgDirectoryRoleTemplate', 'MgBetaDirectoryRoleTemplate', 'MgBetaDeviceManagementAssignmentFilter',
    'AzResource', 'AzResourceGroup', 'AzSubscription', 'AzContext'
)
$script:GenericPropertyNames = @(
    'Id', 'DisplayName', 'Description', 'Ensure', 'IsSingleInstance', 'Filter', 'Credential', 'ApplicationId',
    'TenantId', 'CertificateThumbprint', 'CertificatePath', 'CertificatePassword', 'ManagedIdentity',
    'AccessTokens', 'ApplicationSecret', 'Assignments'
)
$script:WorkloadConnectMap = @{
    'MicrosoftGraph'           = @('MicrosoftGraph')
    'Intune'                   = @('MicrosoftGraph')
    'ExchangeOnline'           = @('ExchangeOnline')
    'SecurityComplianceCenter' = @('SecurityComplianceCenter')
    'MicrosoftTeams'           = @('MicrosoftTeams')
    'PnP'                      = @('PnP')
    'PowerPlatforms'           = @('PowerPlatforms', 'PowerPlatformREST')
    'Azure'                    = @('Azure')
}
$script:ModuleWorkloadMap = @{
    'ExchangeOnlineManagement'                      = 'ExchangeOnline'
    'MicrosoftTeams'                                = 'MicrosoftTeams'
    'PnP.PowerShell'                                = 'PnP'
    'Microsoft.PowerApps.Administration.PowerShell' = 'PowerPlatforms'
}
$script:SchemaContexts = @{}

#region CSDL

<#
.SYNOPSIS
    Loads the CSDL schema nodes for an API version from a fixture file or the generator cache.

.PARAMETER APIVersion
    Specifies the Graph API version, v1.0 or beta.

.PARAMETER FixturePath
    Specifies a local CSDL file. The generator cache is used when it is empty.
#>
function Get-OriginCsdlSchema
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $APIVersion,

        [Parameter()]
        [System.String]
        $FixturePath
    )

    if (-not [System.String]::IsNullOrEmpty($FixturePath))
    {
        return & $script:Generator { param($Version, $File) Get-M365DSCGraphCsdlMetadata -APIVersion $Version -Path $File } $APIVersion $FixturePath
    }

    return & $script:Generator { param($Version) Get-M365DSCGraphCsdlMetadata -APIVersion $Version } $APIVersion
}

<#
.SYNOPSIS
    Builds and caches the type index, entity container, alias map and derived types of one version.

.PARAMETER APIVersion
    Specifies the Graph API version, v1.0 or beta.
#>
function Get-OriginSchemaContext
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $APIVersion
    )

    if ($script:SchemaContexts.ContainsKey($APIVersion))
    {
        return $script:SchemaContexts[$APIVersion]
    }

    $fixturePath = $CsdlPathBeta
    if ($APIVersion -eq 'v1.0')
    {
        $fixturePath = $CsdlPathV1
    }

    $schema = @(Get-OriginCsdlSchema -APIVersion $APIVersion -FixturePath $fixturePath)

    $typeIndex = [System.Collections.Generic.Dictionary[System.String, System.Object]]::new([System.StringComparer]::OrdinalIgnoreCase)
    $aliasMap = @{}
    $entities = [System.Collections.Generic.List[System.Object]]::new()
    foreach ($namespaceNode in $schema)
    {
        $namespace = [System.String] $namespaceNode.Namespace
        $alias = [System.String] $namespaceNode.Alias
        if (-not [System.String]::IsNullOrEmpty($alias))
        {
            $aliasMap[$alias] = $namespace
        }

        $displayPrefix = ''
        if ($namespace -ne 'microsoft.graph')
        {
            $displayPrefix = ($namespace -replace '^microsoft\.graph\.', '') + '.'
        }

        foreach ($kind in @('EntityType', 'ComplexType'))
        {
            foreach ($node in @($namespaceNode.$kind))
            {
                if ($null -eq $node)
                {
                    continue
                }

                $entry = [PSCustomObject]@{
                    Name        = [System.String] $node.Name
                    Namespace   = $namespace
                    Kind        = $kind
                    Node        = $node
                    DisplayName = $displayPrefix + $node.Name
                    BaseType    = [System.String] $node.BaseType
                    IsAbstract  = ([System.String] $node.Abstract) -eq 'true'
                }
                $typeIndex["$namespace.$($node.Name)"] = $entry
                if (-not [System.String]::IsNullOrEmpty($alias))
                {
                    $typeIndex["$alias.$($node.Name)"] = $entry
                }
                if ($kind -eq 'EntityType')
                {
                    $entities.Add($entry)
                }
            }
        }
    }

    $container = @($schema | ForEach-Object { $_.EntityContainer } | Where-Object { $null -ne $_ }) | Select-Object -First 1
    if ($null -eq $container)
    {
        throw "The $APIVersion CSDL has no EntityContainer."
    }

    $context = [PSCustomObject]@{
        APIVersion = $APIVersion
        TypeIndex  = $typeIndex
        AliasMap   = $aliasMap
        Container  = $container
        Entities   = $entities
        Children   = $null
    }

    $children = @{}
    foreach ($entity in $entities)
    {
        if ([System.String]::IsNullOrEmpty($entity.BaseType))
        {
            continue
        }
        $parent = Resolve-OriginTypeReference -Context $context -Reference $entity.BaseType
        if ($null -eq $parent)
        {
            continue
        }
        $parentKey = "$($parent.Namespace).$($parent.Name)"
        if (-not $children.ContainsKey($parentKey))
        {
            $children[$parentKey] = @()
        }
        $children[$parentKey] += $entity
    }
    $context.Children = $children

    $script:SchemaContexts[$APIVersion] = $context
    return $context
}

<#
.SYNOPSIS
    Resolves a CSDL type reference such as 'Collection(microsoft.graph.group)' to its index entry.

.PARAMETER Context
    Specifies the schema context of the API version.

.PARAMETER Reference
    Specifies the CSDL type reference, with or without the Collection wrapper.
#>
function Resolve-OriginTypeReference
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Object]
        $Context,

        [Parameter(Mandatory = $true)]
        [System.String]
        $Reference
    )

    $name = $Reference -replace '^Collection\((.+)\)$', '$1'
    if ($Context.TypeIndex.ContainsKey($name))
    {
        return $Context.TypeIndex[$name]
    }

    foreach ($alias in $Context.AliasMap.Keys)
    {
        if ($name.StartsWith("$alias.", [System.StringComparison]::OrdinalIgnoreCase))
        {
            $expanded = $Context.AliasMap[$alias] + $name.Substring($alias.Length)
            if ($Context.TypeIndex.ContainsKey($expanded))
            {
                return $Context.TypeIndex[$expanded]
            }
        }
    }

    return $null
}

<#
.SYNOPSIS
    Finds a navigation property by name on a type or any of its base types.

.PARAMETER Context
    Specifies the schema context of the API version.

.PARAMETER TypeEntry
    Specifies the type index entry to search.

.PARAMETER Name
    Specifies the navigation property name.
#>
function Get-OriginNavigationProperty
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Object]
        $Context,

        [Parameter(Mandatory = $true)]
        [System.Object]
        $TypeEntry,

        [Parameter(Mandatory = $true)]
        [System.String]
        $Name
    )

    $current = $TypeEntry
    $depth = 0
    while ($null -ne $current -and $depth -lt 32)
    {
        $navigation = @($current.Node.NavigationProperty) |
            Where-Object { $null -ne $_ -and $_.Name -eq $Name } |
            Select-Object -First 1
        if ($null -ne $navigation)
        {
            return $navigation
        }

        if ([System.String]::IsNullOrEmpty($current.BaseType))
        {
            break
        }
        $current = Resolve-OriginTypeReference -Context $Context -Reference $current.BaseType
        $depth++
    }

    return $null
}

<#
.SYNOPSIS
    Returns the navigation property names of a type and all its base types.

.PARAMETER Context
    Specifies the schema context of the API version.

.PARAMETER TypeEntry
    Specifies the type index entry to read.
#>
function Get-OriginNavigationPropertyName
{
    [CmdletBinding()]
    [OutputType([System.String[]])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Object]
        $Context,

        [Parameter(Mandatory = $true)]
        [System.Object]
        $TypeEntry
    )

    $names = @()
    $current = $TypeEntry
    $depth = 0
    while ($null -ne $current -and $depth -lt 32)
    {
        $names += @($current.Node.NavigationProperty | Where-Object { $null -ne $_ } | ForEach-Object { [System.String] $_.Name })
        if ([System.String]::IsNullOrEmpty($current.BaseType))
        {
            break
        }
        $current = Resolve-OriginTypeReference -Context $Context -Reference $current.BaseType
        $depth++
    }

    return [System.String[]] @($names | Where-Object { -not [System.String]::IsNullOrEmpty($_) } | Sort-Object -Unique)
}

<#
.SYNOPSIS
    Returns the structural and navigation property names of a type and all its base types.

.PARAMETER Context
    Specifies the schema context of the API version.

.PARAMETER TypeEntry
    Specifies the type index entry to read.
#>
function Get-OriginPropertyName
{
    [CmdletBinding()]
    [OutputType([System.String[]])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Object]
        $Context,

        [Parameter(Mandatory = $true)]
        [System.Object]
        $TypeEntry
    )

    $names = @()
    $current = $TypeEntry
    $depth = 0
    while ($null -ne $current -and $depth -lt 32)
    {
        $names += @($current.Node.Property | Where-Object { $null -ne $_ } | ForEach-Object { [System.String] $_.Name })
        $names += @($current.Node.NavigationProperty | Where-Object { $null -ne $_ } | ForEach-Object { [System.String] $_.Name })
        if ([System.String]::IsNullOrEmpty($current.BaseType))
        {
            break
        }
        $current = Resolve-OriginTypeReference -Context $Context -Reference $current.BaseType
        $depth++
    }

    return [System.String[]] @($names | Where-Object { -not [System.String]::IsNullOrEmpty($_) } | Sort-Object -Unique)
}

<#
.SYNOPSIS
    Returns every entity type deriving, directly or transitively, from the given entity type.

.PARAMETER Context
    Specifies the schema context of the API version.

.PARAMETER BaseEntry
    Specifies the type index entry of the base entity type.
#>
function Get-OriginDerivedType
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Object]
        $Context,

        [Parameter(Mandatory = $true)]
        [System.Object]
        $BaseEntry
    )

    $result = @()
    $frontier = @($BaseEntry)
    $seen = [System.Collections.Generic.HashSet[System.String]]::new([System.StringComparer]::OrdinalIgnoreCase)
    while ($frontier.Count -gt 0)
    {
        $next = @()
        foreach ($base in $frontier)
        {
            $key = "$($base.Namespace).$($base.Name)"
            if (-not $Context.Children.ContainsKey($key))
            {
                continue
            }
            foreach ($child in $Context.Children[$key])
            {
                if ($seen.Add("$($child.Namespace).$($child.Name)"))
                {
                    $result += $child
                    $next += $child
                }
            }
        }
        $frontier = $next
    }

    return $result
}

<#
.SYNOPSIS
    Walks a Graph request URI through the entity container and returns the terminal entity type.

.PARAMETER Context
    Specifies the schema context of the API version.

.PARAMETER Uri
    Specifies the Graph request URI, with or without a query string.
#>
function Resolve-OriginUriEntityType
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Object]
        $Context,

        [Parameter(Mandatory = $true)]
        [System.String]
        $Uri
    )

    $path = ($Uri -split '\?')[0].Trim()
    $segments = @($path -split '/' | Where-Object { $_ -ne '' })
    if ($segments.Count -eq 0)
    {
        throw "URI '$Uri' has no path segments."
    }

    $current = $null
    foreach ($segment in $segments)
    {
        if ($segment -match '^\{.*\}$')
        {
            continue
        }
        if ($segment.StartsWith('$'))
        {
            throw "URI '$Uri': segment '$segment' is an OData system segment."
        }
        if ($segment.Contains('('))
        {
            throw "URI '$Uri': segment '$segment' is an action or function."
        }

        if ($segment -match '^(microsoft\.)?graph\.')
        {
            $castEntry = Resolve-OriginTypeReference -Context $Context -Reference $segment
            if ($null -eq $castEntry)
            {
                throw "URI '$Uri': type cast '$segment' is not in the $($Context.APIVersion) CSDL."
            }
            $current = $castEntry
            continue
        }

        if ($null -eq $current)
        {
            $reference = $null
            $entitySet = @($Context.Container.EntitySet) |
                Where-Object { $null -ne $_ -and $_.Name -eq $segment } |
                Select-Object -First 1
            if ($null -ne $entitySet)
            {
                $reference = [System.String] $entitySet.EntityType
            }
            else
            {
                $singleton = @($Context.Container.Singleton) |
                    Where-Object { $null -ne $_ -and $_.Name -eq $segment } |
                    Select-Object -First 1
                if ($null -eq $singleton)
                {
                    throw "URI '$Uri': '$segment' is neither an entity set nor a singleton of the $($Context.APIVersion) entity container."
                }
                $reference = [System.String] $singleton.Type
            }

            $current = Resolve-OriginTypeReference -Context $Context -Reference $reference
            if ($null -eq $current)
            {
                throw "URI '$Uri': '$segment' targets type '$reference' which is not in the $($Context.APIVersion) CSDL."
            }
            continue
        }

        $navigation = Get-OriginNavigationProperty -Context $Context -TypeEntry $current -Name $segment
        if ($null -eq $navigation)
        {
            throw "URI '$Uri': '$segment' is not a navigation property of '$($current.DisplayName)'."
        }
        $next = Resolve-OriginTypeReference -Context $Context -Reference ([System.String] $navigation.Type)
        if ($null -eq $next)
        {
            throw "URI '$Uri': navigation property '$segment' targets type '$($navigation.Type)' which is not in the $($Context.APIVersion) CSDL."
        }
        $current = $next
    }

    if ($null -eq $current)
    {
        throw "URI '$Uri' resolved to no type."
    }
    if ($current.Kind -ne 'EntityType')
    {
        throw "URI '$Uri' resolved to complex type '$($current.DisplayName)', not an entity type."
    }

    return $current
}

#endregion

#region Resource facts

<#
.SYNOPSIS
    Returns the workloads a resource module connects to, in order of first appearance.

.PARAMETER ModuleContent
    Specifies the text of the resource module.
#>
function Get-OriginConnectWorkload
{
    [CmdletBinding()]
    [OutputType([System.String[]])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $ModuleContent
    )

    $workloads = @()
    foreach ($match in [regex]::Matches($ModuleContent, '\$this\.Connect\(\s*[''"]([^''"]+)[''"]'))
    {
        $workload = $match.Groups[1].Value
        if ($workload -ceq 'PNP')
        {
            $workload = 'PnP'
        }
        if ($workload -notin $workloads)
        {
            $workloads += $workload
        }
    }

    return [System.String[]] $workloads
}

<#
.SYNOPSIS
    Returns the names of the [DscProperty()] members of the resource class.

.PARAMETER ModulePath
    Specifies the path of the resource module.
#>
function Get-OriginDscPropertyName
{
    [CmdletBinding()]
    [OutputType([System.String[]])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $ModulePath
    )

    $ast = [System.Management.Automation.Language.Parser]::ParseFile($ModulePath, [ref] $null, [ref] $null)
    $classes = @($ast.FindAll(
            {
                param($Item)
                return ($Item -is [System.Management.Automation.Language.TypeDefinitionAst]) -and
                    @($Item.Attributes | Where-Object { $_.TypeName.Name -eq 'DscResource' }).Count -gt 0
            }, $true))

    $names = @()
    foreach ($class in $classes)
    {
        foreach ($member in @($class.Members))
        {
            if ($member -isnot [System.Management.Automation.Language.PropertyMemberAst])
            {
                continue
            }
            if (@($member.Attributes | Where-Object { $_.TypeName.Name -eq 'DscProperty' }).Count -gt 0)
            {
                $names += $member.Name
            }
        }
    }

    return [System.String[]] @($names | Sort-Object -Unique)
}

<#
.SYNOPSIS
    Returns the 'microsoft.graph.<type>' literals of a resource module, without the prefix.

.DESCRIPTION
    Payload literals come from '@odata.type' values, filter literals from isof() expressions.

.PARAMETER ModuleContent
    Specifies the text of the resource module.
#>
function Get-OriginODataTypeLiteral
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $ModuleContent
    )

    $tokens = $null
    $null = [System.Management.Automation.Language.Parser]::ParseInput($ModuleContent, [ref] $tokens, [ref] $null)
    $builder = [System.Text.StringBuilder]::new($ModuleContent)
    foreach ($token in @($tokens | Where-Object { $_.Kind -eq [System.Management.Automation.Language.TokenKind]::Comment }))
    {
        $null = $builder.Remove($token.Extent.StartOffset, $token.Extent.EndOffset - $token.Extent.StartOffset)
        $null = $builder.Insert($token.Extent.StartOffset, (' ' * ($token.Extent.EndOffset - $token.Extent.StartOffset)))
    }
    $codeOnly = $builder.ToString() -replace "not\s+isof\(\s*'[^']*'\s*\)", ' '

    $filterLiterals = @()
    foreach ($match in [regex]::Matches($codeOnly, "isof\(\s*'microsoft\.graph\.([A-Za-z0-9_.]+)'\s*\)"))
    {
        $literal = $match.Groups[1].Value.TrimEnd('.')
        if (-not [System.String]::IsNullOrEmpty($literal) -and $literal -notin $filterLiterals)
        {
            $filterLiterals += $literal
        }
    }
    $payloadOnly = $codeOnly -replace "isof\(\s*'microsoft\.graph\.[A-Za-z0-9_.]+'\s*\)", ' '

    $payloadLiterals = @()
    foreach ($match in [regex]::Matches($payloadOnly, '(?<![A-Za-z0-9_])#?microsoft\.graph\.([A-Za-z0-9_.]+)'))
    {
        $literal = $match.Groups[1].Value.TrimEnd('.')
        if (-not [System.String]::IsNullOrEmpty($literal) -and $literal -notin $payloadLiterals)
        {
            $payloadLiterals += $literal
        }
    }

    return @{
        Payload = [System.String[]] $payloadLiterals
        Filter  = [System.String[]] $filterLiterals
    }
}

<#
.SYNOPSIS
    Scores a cmdlet noun against the resource name with the generator's type candidate scorer.

.PARAMETER Candidate
    Specifies the candidate noun.

.PARAMETER Target
    Specifies the resource name to score against.
#>
function Get-OriginNameScore
{
    [CmdletBinding()]
    [OutputType([System.Double])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Candidate,

        [Parameter(Mandatory = $true)]
        [System.String]
        $Target
    )

    return [System.Double] (& $script:Generator {
            param($CandidateName, $TargetName)
            Get-M365DSCTypeCandidateScore -Candidate $CandidateName -Target $TargetName
        } $Candidate $Target)
}

<#
.SYNOPSIS
    Picks the cmdlet noun a resource is built on from its commands array.

.PARAMETER Settings
    Specifies the parsed settings.json of the resource.

.PARAMETER ResourceName
    Specifies the resource name without the MSFT_ prefix.

.PARAMETER UsesGraphRest
    Tells whether the resource calls the Graph REST helpers directly.
#>
function Select-OriginCmdletNoun
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Object]
        $Settings,

        [Parameter(Mandatory = $true)]
        [System.String]
        $ResourceName,

        [Parameter()]
        [System.Boolean]
        $UsesGraphRest = $false
    )

    if (-not $Settings.Contains('commands'))
    {
        return @{ Noun = $null; Reason = 'settings.json has no commands array (run Utilities/Build-DscResourceCmdletsByModule.ps1).' }
    }

    $byNoun = [ordered]@{}
    foreach ($group in @($Settings.commands))
    {
        if ($null -eq $group -or $group.module -in $script:IgnoredCommandModules)
        {
            continue
        }
        foreach ($cmdletName in @($group.cmdlets))
        {
            if ($cmdletName -notmatch '^([A-Za-z]+)-([A-Za-z0-9]+)$')
            {
                continue
            }
            $verb = $Matches[1]
            $noun = $Matches[2]
            if ($verb -notin $script:CrudVerbs)
            {
                continue
            }
            if (-not $byNoun.Contains($noun))
            {
                $byNoun[$noun] = [PSCustomObject]@{ Noun = $noun; Module = [System.String] $group.module; Verbs = @() }
            }
            if ($verb -notin $byNoun[$noun].Verbs)
            {
                $byNoun[$noun].Verbs += $verb
            }
        }
    }

    if ($byNoun.Count -eq 0)
    {
        return @{ Noun = $null; Reason = 'The commands array holds no Get, New, Update, Set or Remove cmdlet outside the authentication modules.' }
    }

    foreach ($noun in @($byNoun.Keys))
    {
        if ($noun -notmatch '^Mg(?!Beta)(.+)$')
        {
            continue
        }
        $betaNoun = "MgBeta$($Matches[1])"
        if ($byNoun.Contains($betaNoun))
        {
            foreach ($verb in $byNoun[$noun].Verbs)
            {
                if ($verb -notin $byNoun[$betaNoun].Verbs)
                {
                    $byNoun[$betaNoun].Verbs += $verb
                }
            }
            $byNoun.Remove($noun)
        }
    }

    $scored = @(foreach ($candidate in $byNoun.Values)
        {
            $bareNoun = $candidate.Noun -replace '^MgBeta', '' -replace '^Mg', '' -replace '^Cs', '' -replace '^PnP', ''
            [PSCustomObject]@{
                Noun      = $candidate.Noun
                Module    = $candidate.Module
                Verbs     = @($candidate.Verbs)
                VerbCount = @($candidate.Verbs).Count
                NameScore = Get-OriginNameScore -Candidate $bareNoun -Target $ResourceName
            }
        })

    $describe = {
        param($Candidates)
        ($Candidates | Select-Object -First 4 | ForEach-Object {
                '{0} (verbs {1}, name {2:N2})' -f $_.Noun, $_.VerbCount, $_.NameScore
            }) -join ', '
    }

    $scored = @($scored | Where-Object {
            -not ($_.Noun -in $script:LookupNouns -and $_.VerbCount -eq 1 -and $_.NameScore -lt 1.0)
        })
    if ($scored.Count -eq 0)
    {
        return @{ Noun = $null; Reason = 'The commands array only holds Get-only lookups (group, user, service principal, Azure resource) that do not name the resource.' }
    }

    $scored = @($scored | Where-Object {
            $child = $_
            $parents = @($scored | Where-Object {
                    $_.Noun -ne $child.Noun -and
                    $child.Noun.StartsWith($_.Noun, [System.StringComparison]::OrdinalIgnoreCase) -and
                    $_.NameScore -ge $child.NameScore
                })
            $parents.Count -eq 0
        })

    $exact = @($scored | Where-Object { $_.NameScore -ge 1.0 })
    if ($exact.Count -eq 1)
    {
        $top = $exact[0]
    }
    else
    {
        $ranked = @($scored | Sort-Object -Property @{ Expression = 'VerbCount'; Descending = $true },
            @{ Expression = 'NameScore'; Descending = $true },
            @{ Expression = 'Noun'; Descending = $false })
        $top = $ranked[0]

        if ($ranked.Count -gt 1)
        {
            $runnerUp = $ranked[1]
            if ($runnerUp.VerbCount -eq $top.VerbCount -and ($top.NameScore - $runnerUp.NameScore) -lt 0.15)
            {
                return @{ Noun = $null; Reason = "Ambiguous cmdlet noun, no confident pick between: $(& $describe $ranked)." }
            }

            $betterNamed = @($ranked | Where-Object { $_.NameScore - $top.NameScore -gt 0.25 })
            if ($betterNamed.Count -gt 0)
            {
                return @{ Noun = $null; Reason = "Ambiguous cmdlet noun: $($top.Noun) has the most verbs but $(& $describe $betterNamed) names the resource better." }
            }
        }
    }

    if ($top.VerbCount -eq 1 -and $top.NameScore -lt 0.6)
    {
        return @{
            Noun      = $null
            Reason    = "Only a Get cmdlet for $($top.Noun) (name score $($top.NameScore.ToString('N2'))) and nothing corroborates it as the resource's entity."
            Candidate = @{ Noun = $top.Noun; Module = $top.Module; Verbs = @($top.Verbs) }
        }
    }
    if ($top.NameScore -le 0.0 -and $UsesGraphRest)
    {
        return @{ Noun = $null; Reason = "The resource calls Invoke-MgGraphRequest and its best cmdlet noun $($top.Noun) shares no name with it." }
    }

    return @{
        Noun   = $top.Noun
        Module = $top.Module
        Verbs  = @($top.Verbs)
        Reason = $null
    }
}

<#
.SYNOPSIS
    Derives the workload the origin is recorded under.

.PARAMETER ConnectWorkloads
    Specifies the workloads the resource module connects to.

.PARAMETER CmdletModule
    Specifies the module that ships the picked cmdlet noun.

.PARAMETER ResourceName
    Specifies the resource name without the MSFT_ prefix.
#>
function Resolve-OriginWorkload
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter()]
        [System.String[]]
        $ConnectWorkloads = @(),

        [Parameter()]
        [System.String]
        $CmdletModule,

        [Parameter(Mandatory = $true)]
        [System.String]
        $ResourceName
    )

    $graphWorkload = 'MicrosoftGraph'
    if ($ResourceName -like 'Intune*')
    {
        $graphWorkload = 'Intune'
    }

    $cmdletWorkload = $null
    if (-not [System.String]::IsNullOrEmpty($CmdletModule))
    {
        if ($CmdletModule -like 'Microsoft.Graph*')
        {
            $cmdletWorkload = $graphWorkload
        }
        elseif ($CmdletModule -eq 'ExchangeOnlineManagement')
        {
            $cmdletWorkload = 'ExchangeOnline'
            if ('SecurityComplianceCenter' -in $ConnectWorkloads -and 'ExchangeOnline' -notin $ConnectWorkloads)
            {
                $cmdletWorkload = 'SecurityComplianceCenter'
            }
        }
        elseif ($script:ModuleWorkloadMap.ContainsKey($CmdletModule))
        {
            $cmdletWorkload = $script:ModuleWorkloadMap[$CmdletModule]
        }
        elseif ($CmdletModule -like 'Az.*')
        {
            $cmdletWorkload = 'Azure'
        }
    }

    if ($null -ne $cmdletWorkload)
    {
        $accepted = @($script:WorkloadConnectMap[$cmdletWorkload])
        if ($ConnectWorkloads.Count -gt 0 -and @($ConnectWorkloads | Where-Object { $_ -in $accepted }).Count -eq 0)
        {
            return @{ Workload = $null; Reason = "Cmdlet module '$CmdletModule' implies workload $cmdletWorkload but the resource only connects to $($ConnectWorkloads -join ', ')." }
        }
        return @{ Workload = $cmdletWorkload; Reason = $null }
    }

    if ($ConnectWorkloads.Count -eq 1)
    {
        $workload = $ConnectWorkloads[0]
        if ($workload -eq 'MicrosoftGraph')
        {
            $workload = $graphWorkload
        }
        return @{ Workload = $workload; Reason = $null }
    }
    if ($ConnectWorkloads.Count -eq 0)
    {
        return @{ Workload = $null; Reason = 'The resource module has no $this.Connect() call.' }
    }

    return @{ Workload = $null; Reason = "The resource connects to several workloads ($($ConnectWorkloads -join ', ')) and no cmdlet decides between them." }
}

<#
.SYNOPSIS
    Resolves the Graph origin of a resource, from the API version down to the concrete subtype.

.PARAMETER Selection
    Specifies the picked cmdlet noun with its module and verbs.

.PARAMETER Mapping
    Specifies the parsed cmdlet-mapping.json.

.PARAMETER ModuleContent
    Specifies the text of the resource module.

.PARAMETER ResourceName
    Specifies the resource name without the MSFT_ prefix.

.PARAMETER DscPropertyNames
    Specifies the names of the DSC properties the resource declares.
#>
function Resolve-OriginGraphEntity
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Collections.Hashtable]
        $Selection,

        [Parameter(Mandatory = $true)]
        [System.Object]
        $Mapping,

        [Parameter(Mandatory = $true)]
        [System.String]
        $ModuleContent,

        [Parameter(Mandatory = $true)]
        [System.String]
        $ResourceName,

        [Parameter()]
        [System.String[]]
        $DscPropertyNames = @()
    )

    $lookupCmdlet = $null
    $entry = $null
    foreach ($verb in $script:CrudVerbs)
    {
        if ($verb -notin $Selection.Verbs)
        {
            continue
        }
        $name = "$verb-$($Selection.Noun)"
        if ($Mapping.Contains($name))
        {
            $lookupCmdlet = $name
            $entry = $Mapping[$name]
            break
        }
    }
    if ($null -eq $entry)
    {
        $tried = ($Selection.Verbs | ForEach-Object { "$_-$($Selection.Noun)" }) -join ', '
        throw "None of the $($Selection.Noun) cmdlets ($tried) is in cmdlet-mapping.json."
    }

    $apiVersion = [System.String] $entry.ApiVersion
    if ($apiVersion -notin @('v1.0', 'beta'))
    {
        throw "The cmdlet-mapping.json entry for '$lookupCmdlet' has no usable ApiVersion ('$apiVersion')."
    }

    $context = Get-OriginSchemaContext -APIVersion $apiVersion

    $variants = @($entry.Variants | Where-Object {
            $null -ne $_ -and ([System.String]::IsNullOrEmpty($_.ApiVersion) -or $_.ApiVersion -eq $apiVersion)
        })
    if ($variants.Count -eq 0)
    {
        throw "The cmdlet-mapping.json entry for '$lookupCmdlet' has no $apiVersion variant."
    }

    $resolved = @()
    $failures = @()
    foreach ($variant in $variants)
    {
        try
        {
            $resolved += Resolve-OriginUriEntityType -Context $context -Uri ([System.String] $variant.URI)
        }
        catch
        {
            $failures += $_.Exception.Message
        }
    }
    if ($resolved.Count -eq 0)
    {
        throw ("$lookupCmdlet`: " + ($failures -join ' '))
    }

    $distinct = @($resolved | ForEach-Object { $_.DisplayName } | Sort-Object -Unique)
    if ($distinct.Count -gt 1)
    {
        throw "The variants of '$lookupCmdlet' resolve to different entity types: $($distinct -join ', ')."
    }
    $entity = $resolved[0]

    $literals = Get-OriginODataTypeLiteral -ModuleContent $ModuleContent
    $derived = @(Get-OriginDerivedType -Context $context -BaseEntry $entity)
    $derivedNames = @($derived | ForEach-Object { $_.DisplayName })

    $payloadHits = @($literals.Payload | Where-Object { $_ -in $derivedNames })
    $filterHits = @($literals.Filter | Where-Object { $_ -in $derivedNames })
    $createsBaseType = $entity.DisplayName -in @($literals.Payload)
    $filterDisagrees = @($filterHits | Where-Object { $_ -notin $payloadHits }).Count -gt 0
    if ($payloadHits.Count -gt 0 -and $filterDisagrees)
    {
        throw "Entity type '$($entity.DisplayName)' is polymorphic and the module writes $($payloadHits -join ', ') but reads with a filter on $($filterHits -join ', ')."
    }

    $subtypeHits = $payloadHits
    if ($subtypeHits.Count -eq 0 -and -not $createsBaseType)
    {
        $subtypeHits = $filterHits
    }

    $odataSubtype = $null
    $schemaEntry = $entity
    if ($subtypeHits.Count -eq 1)
    {
        $odataSubtype = $subtypeHits[0]
    }
    elseif ($subtypeHits.Count -gt 1)
    {
        try
        {
            $odataSubtype = & $script:Generator {
                param($Candidates, $Resource, $Noun)
                Resolve-M365DSCTypeCandidate -Candidates $Candidates -ResourceName $Resource -CmdLetNoun $Noun -AllowPrompt $false
            } $subtypeHits $ResourceName $Selection.Noun
        }
        catch
        {
            throw "Entity type '$($entity.DisplayName)' is polymorphic and the module references several derived types with no confident name match: $($subtypeHits -join ', ')."
        }
    }
    elseif ($entity.IsAbstract)
    {
        throw "Entity type '$($entity.DisplayName)' is abstract and the module references none of its derived types."
    }

    if ($null -ne $odataSubtype)
    {
        $schemaEntry = $derived | Where-Object { $_.DisplayName -eq $odataSubtype } | Select-Object -First 1
        $odataSubtype = $schemaEntry.DisplayName
    }

    $navigationNames = @(Get-OriginNavigationPropertyName -Context $context -TypeEntry $schemaEntry)
    $declaredNavigation = @($DscPropertyNames | Where-Object { $_ -ne 'Assignments' -and $_ -in $navigationNames })

    $typePropertyNames = @(Get-OriginPropertyName -Context $context -TypeEntry $schemaEntry)
    $specificProperties = @($DscPropertyNames | Where-Object { $_ -notin $script:GenericPropertyNames })
    $matchedProperties = @($specificProperties | Where-Object { $_ -in $typePropertyNames })

    return @{
        ApiVersion                  = $apiVersion
        EntityType                  = $entity.DisplayName
        ODataSubtype                = $odataSubtype
        IncludeNavigationProperties = ($declaredNavigation.Count -gt 0)
        DeclaredPropertyMatches     = $matchedProperties.Count
        DeclaredPropertyTotal       = $specificProperties.Count
        Evidence                    = "$lookupCmdlet -> $($variants[0].URI)"
    }
}

<#
.SYNOPSIS
    Tells whether a generatedFrom block is resolved for its workload.

.PARAMETER GeneratedFrom
    Specifies the generatedFrom block to check.
#>
function Test-OriginResolved
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter()]
        [System.Object]
        $GeneratedFrom
    )

    if ($null -eq $GeneratedFrom)
    {
        return $false
    }

    $workload = [System.String] $GeneratedFrom.workload
    if ([System.String]::IsNullOrEmpty($workload))
    {
        return $false
    }
    if ($workload -in $script:GraphWorkloads)
    {
        return -not [System.String]::IsNullOrEmpty([System.String] $GeneratedFrom.entityType) -and
            ([System.String] $GeneratedFrom.apiVersion) -in @('v1.0', 'beta')
    }
    if ($workload -in $script:CmdletWorkloads)
    {
        if (-not [System.String]::IsNullOrEmpty([System.String] $GeneratedFrom.cmdletNoun))
        {
            return $true
        }
        return -not $script:OriginHasCrudCommand
    }

    return $true
}

<#
.SYNOPSIS
    Computes the generatedFrom block of one resource and the reason it stays unresolved, if any.

.PARAMETER ResourceName
    Specifies the resource name without the MSFT_ prefix.

.PARAMETER Settings
    Specifies the parsed settings.json of the resource.

.PARAMETER ModulePath
    Specifies the path of the resource module.

.PARAMETER Mapping
    Specifies the parsed cmdlet-mapping.json.
#>
function Resolve-OriginResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $ResourceName,

        [Parameter(Mandatory = $true)]
        [System.Object]
        $Settings,

        [Parameter(Mandatory = $true)]
        [System.String]
        $ModulePath,

        [Parameter(Mandatory = $true)]
        [System.Object]
        $Mapping
    )

    $generatedFrom = [ordered]@{
        workload                    = $null
        apiVersion                  = $null
        entityType                  = $null
        odataSubtype                = $null
        cmdletNoun                  = $null
        cmdletVerb                  = $null
        includeNavigationProperties = $false
        generatorVersion            = $script:Generator.Version.ToString()
    }

    $moduleContent = [System.IO.File]::ReadAllText($ModulePath)
    $connectWorkloads = @(Get-OriginConnectWorkload -ModuleContent $moduleContent)
    $usesGraphRest = $moduleContent -match 'Invoke-MgGraphRequest|Invoke-M365DSCGraphBatchRequest|Invoke-MgxBatchRequest'

    $selection = Select-OriginCmdletNoun -Settings $Settings -ResourceName $ResourceName -UsesGraphRest $usesGraphRest

    $workloadResult = Resolve-OriginWorkload -ConnectWorkloads $connectWorkloads -CmdletModule $selection.Module -ResourceName $ResourceName
    $generatedFrom.workload = $workloadResult.Workload
    if ($null -ne $workloadResult.Reason)
    {
        $reason = $workloadResult.Reason
        if ($null -ne $selection.Reason)
        {
            $reason = "$($selection.Reason) $reason"
        }
        return @{ GeneratedFrom = $generatedFrom; Reason = $reason }
    }

    $isGraph = $generatedFrom.workload -in $script:GraphWorkloads
    $needsCmdlet = $isGraph -or
        ($generatedFrom.workload -in $script:CmdletWorkloads -and $script:OriginHasCrudCommand)

    $corroborationNote = $null
    if ($null -eq $selection.Noun -and $null -ne $selection.Candidate)
    {
        $candidateWorkload = Resolve-OriginWorkload -ConnectWorkloads $connectWorkloads -CmdletModule $selection.Candidate.Module -ResourceName $ResourceName
        if ($null -eq $candidateWorkload.Reason -and $candidateWorkload.Workload -in $script:GraphWorkloads)
        {
            try
            {
                $candidateProperties = @(Get-OriginDscPropertyName -ModulePath $ModulePath)
                $candidateGraph = Resolve-OriginGraphEntity -Selection $selection.Candidate -Mapping $Mapping -ModuleContent $moduleContent -ResourceName $ResourceName -DscPropertyNames $candidateProperties
                if ($candidateGraph.DeclaredPropertyMatches -ge 2)
                {
                    $selection = @{ Noun = $selection.Candidate.Noun; Module = $selection.Candidate.Module; Verbs = @($selection.Candidate.Verbs); Reason = $null }
                    $generatedFrom.workload = $candidateWorkload.Workload
                    $corroborationNote = "corroborated by $($candidateGraph.DeclaredPropertyMatches) of $($candidateGraph.DeclaredPropertyTotal) declared properties on '$($candidateGraph.EntityType)'"
                }
                else
                {
                    $selection.Reason = "$($selection.Reason) Only $($candidateGraph.DeclaredPropertyMatches) of $($candidateGraph.DeclaredPropertyTotal) declared properties exist on '$($candidateGraph.EntityType)'."
                }
            }
            catch
            {
                $selection.Reason = "$($selection.Reason) Walking it failed too: $($_.Exception.Message)"
            }
        }
    }

    if ($null -eq $selection.Noun)
    {
        if ($needsCmdlet)
        {
            return @{ GeneratedFrom = $generatedFrom; Reason = $selection.Reason }
        }
        return @{ GeneratedFrom = $generatedFrom; Reason = $null }
    }

    $isGraph = $generatedFrom.workload -in $script:GraphWorkloads
    $generatedFrom.cmdletNoun = $selection.Noun
    $verbPreference = @('New', 'Set', 'Update', 'Get')
    if ($isGraph)
    {
        $verbPreference = @('New', 'Update', 'Set', 'Get')
    }
    $generatedFrom.cmdletVerb = @($verbPreference | Where-Object { $_ -in $selection.Verbs })[0]

    if (-not $isGraph)
    {
        return @{ GeneratedFrom = $generatedFrom; Reason = $null }
    }

    try
    {
        $dscPropertyNames = @(Get-OriginDscPropertyName -ModulePath $ModulePath)
        $graph = Resolve-OriginGraphEntity -Selection $selection -Mapping $Mapping -ModuleContent $moduleContent -ResourceName $ResourceName -DscPropertyNames $dscPropertyNames
    }
    catch
    {
        return @{ GeneratedFrom = $generatedFrom; Reason = $_.Exception.Message }
    }

    $generatedFrom.apiVersion = $graph.ApiVersion
    $generatedFrom.entityType = $graph.EntityType
    $generatedFrom.odataSubtype = $graph.ODataSubtype
    $generatedFrom.includeNavigationProperties = [System.Boolean] $graph.IncludeNavigationProperties

    Write-Verbose -Message "$ResourceName`: $($graph.Evidence) -> $($graph.EntityType) $corroborationNote"
    return @{ GeneratedFrom = $generatedFrom; Reason = $null }
}

#endregion

#region Main

if ([System.String]::IsNullOrEmpty($ResourcePath))
{
    $ResourcePath = Join-Path -Path $RepositoryRoot -ChildPath 'Modules/Microsoft365DSC/DscResources'
}
if ([System.String]::IsNullOrEmpty($CmdletMappingPath))
{
    $CmdletMappingPath = Join-Path -Path $RepositoryRoot -ChildPath 'Utilities/cmdlet-mapping.json'
}
if ([System.String]::IsNullOrEmpty($UnresolvedPath))
{
    $UnresolvedPath = Join-Path -Path $RepositoryRoot -ChildPath 'Utilities/ApiSurface/generatedfrom-unresolved.md'
}

$script:Generator = Import-Module -Name (Join-Path -Path $RepositoryRoot -ChildPath 'ResourceGenerator/M365DSCResourceGenerator.psd1') -Force -PassThru
$mapping = [System.IO.File]::ReadAllText($CmdletMappingPath) | ConvertFrom-Json -AsHashtable

$rows = @()
$written = 0
$skipped = 0
$folders = @(Get-ChildItem -Path $ResourcePath -Directory -Filter "MSFT_$ResourceFilter" | Sort-Object -Property Name)
foreach ($folder in $folders)
{
    $settingsPath = Join-Path -Path $folder.FullName -ChildPath 'settings.json'
    if (-not (Test-Path -Path $settingsPath))
    {
        Write-Warning -Message "$($folder.Name) has no settings.json; skipped."
        continue
    }

    $raw = [System.IO.File]::ReadAllText($settingsPath)
    $settings = $raw | ConvertFrom-Json -AsHashtable
    $resourceName = $folder.Name -replace '^MSFT_', ''

    $script:OriginHasCrudCommand = $false
    foreach ($group in @($settings.commands))
    {
        if ($null -eq $group -or $group.module -in $script:IgnoredCommandModules)
        {
            continue
        }
        foreach ($cmdletName in @($group.cmdlets))
        {
            if ($cmdletName -match '^([A-Za-z]+)-([A-Za-z0-9]+)$' -and $Matches[1] -in $script:CrudVerbs)
            {
                $script:OriginHasCrudCommand = $true
                break
            }
        }
    }

    if (-not $Force -and $settings.Contains('generatedFrom') -and (Test-OriginResolved -GeneratedFrom $settings.generatedFrom))
    {
        $skipped++
        continue
    }

    $modulePath = Join-Path -Path $folder.FullName -ChildPath "$($folder.Name).psm1"
    if (-not (Test-Path -Path $modulePath))
    {
        $rows += [PSCustomObject]@{ Resource = $resourceName; Workload = $null; Resolved = $false; Reason = "No $($folder.Name).psm1 next to settings.json." }
        continue
    }

    $result = Resolve-OriginResource -ResourceName $resourceName -Settings $settings -ModulePath $modulePath -Mapping $mapping

    if ($null -ne $result.Reason -and $settings.Contains('generatedFrom') -and $null -ne $settings.generatedFrom)
    {
        $existing = $settings.generatedFrom
        $factKeys = @('workload', 'apiVersion', 'entityType', 'odataSubtype', 'cmdletNoun', 'cmdletVerb')
        $kept = @($factKeys | Where-Object {
                -not [System.String]::IsNullOrEmpty([System.String] $existing[$_]) -and
                [System.String]::IsNullOrEmpty([System.String] $result.GeneratedFrom[$_])
            })

        if ($kept.Count -gt 0)
        {
            foreach ($key in $kept)
            {
                $result.GeneratedFrom[$key] = $existing[$key]
            }
            if ($null -ne $existing['includeNavigationProperties'])
            {
                $result.GeneratedFrom['includeNavigationProperties'] = [System.Boolean] $existing['includeNavigationProperties']
            }

            $result.Reason = "$($result.Reason) Kept the recorded $($kept -join ', ') this run could not derive."
        }
    }

    $updated = [ordered]@{}
    $inserted = $false
    foreach ($key in @($settings.Keys))
    {
        if ($key -in @('generatedFrom', 'excludedProperties'))
        {
            continue
        }
        $updated[$key] = $settings[$key]
        if ($key -eq 'resourceName')
        {
            $updated['generatedFrom'] = $result.GeneratedFrom
            $updated['excludedProperties'] = @()
            if ($settings.Contains('excludedProperties') -and $null -ne $settings['excludedProperties'])
            {
                $updated['excludedProperties'] = @($settings['excludedProperties'])
            }
            $inserted = $true
        }
    }
    if (-not $inserted)
    {
        $updated['generatedFrom'] = $result.GeneratedFrom
        $updated['excludedProperties'] = @()
        if ($settings.Contains('excludedProperties') -and $null -ne $settings['excludedProperties'])
        {
            $updated['excludedProperties'] = @($settings['excludedProperties'])
        }
    }

    $output = (($updated | ConvertTo-Json -Depth 20) -replace "`r?`n", "`r`n") + "`r`n"
    if ($output -cne $raw)
    {
        [System.IO.File]::WriteAllText($settingsPath, $output, [System.Text.UTF8Encoding]::new($false))
        $written++
    }

    $rows += [PSCustomObject]@{
        Resource = $resourceName
        Workload = $result.GeneratedFrom.workload
        Resolved = ($null -eq $result.Reason)
        Reason   = $result.Reason
    }
}

$unresolvedRows = @($rows | Where-Object { -not $_.Resolved })

if ($ResourceFilter -ne '*' -and (Test-Path -Path $UnresolvedPath))
{
    $touched = @($folders | ForEach-Object { $_.Name -replace '^MSFT_', '' })
    $kept = foreach ($line in [System.IO.File]::ReadAllLines($UnresolvedPath))
    {
        if ($line -match '^\| (\S+) \| ([^|]*) \| (.*) \|$' -and $Matches[1] -ne 'Resource' -and $Matches[1] -notmatch '^-+$' -and $Matches[1] -notin $touched)
        {
            $keptWorkload = $Matches[2].Trim()
            if ($keptWorkload -eq '(unknown)')
            {
                $keptWorkload = $null
            }
            [PSCustomObject]@{ Resource = $Matches[1]; Workload = $keptWorkload; Resolved = $false; Reason = $Matches[3].Trim() }
        }
    }
    $unresolvedRows = @($unresolvedRows) + @($kept)
}
$unresolvedRows = @($unresolvedRows | Sort-Object -Property Resource)

if (-not [System.String]::IsNullOrEmpty($UnresolvedPath))
{
    $unresolvedFolder = Split-Path -Path $UnresolvedPath -Parent
    if (-not (Test-Path -Path $unresolvedFolder))
    {
        $null = New-Item -Path $unresolvedFolder -ItemType Directory -Force
    }

    $lines = @(
        '# generatedFrom - unresolved resources'
        ''
        'Generated by `Utilities/Update-ResourceOrigin.ps1`. Do not edit by hand: re-run the script.'
        ''
        'Each row is a resource whose origin could not be derived from its `commands` array,'
        '`Utilities/cmdlet-mapping.json` and the Graph CSDL. The script never guesses. Resolve a row'
        'by adding the missing fact (a `commands` entry, a mapping entry, a single `@odata.type`'
        'literal) and re-running, or by filling `generatedFrom` by hand, then remove the resource'
        'from the allowlist in `Tests/QA/Microsoft365DSC.SettingsJson.Tests.ps1`.'
        ''
        "Unresolved: $($unresolvedRows.Count)"
        ''
        '| Resource | Workload | Reason |'
        '| --- | --- | --- |'
    )
    foreach ($row in $unresolvedRows)
    {
        $workloadText = $row.Workload
        if ([System.String]::IsNullOrEmpty($workloadText))
        {
            $workloadText = '(unknown)'
        }
        $reasonText = ([System.String] $row.Reason).Replace('|', '/').Replace("`r", ' ').Replace("`n", ' ')
        $lines += "| $($row.Resource) | $workloadText | $reasonText |"
    }
    [System.IO.File]::WriteAllText($UnresolvedPath, (($lines -join "`r`n") + "`r`n"), [System.Text.UTF8Encoding]::new($false))
    Write-Host -Object "Wrote $($unresolvedRows.Count) unresolved resources to $UnresolvedPath."
}

$unresolvedByWorkload = [ordered]@{}
foreach ($group in ($unresolvedRows | Group-Object -Property { if ([System.String]::IsNullOrEmpty($_.Workload)) { '(unknown)' } else { $_.Workload } } | Sort-Object -Property Name))
{
    $unresolvedByWorkload[$group.Name] = $group.Count
}

[PSCustomObject]@{
    Total                = $folders.Count
    Resolved             = @($rows | Where-Object { $_.Resolved }).Count
    Unresolved           = $unresolvedRows.Count
    Skipped              = $skipped
    Written              = $written
    UnresolvedByWorkload = $unresolvedByWorkload
    UnresolvedRows       = $unresolvedRows
}

#endregion
