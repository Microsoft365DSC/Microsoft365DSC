<#
.SYNOPSIS
    Collects the cmdlet names, key parameters and entity type behind a Graph resource.

.PARAMETER CmdLetNoun
    Specifies the Graph cmdlet noun, for example 'MgBetaPolicyPermissionGrantPolicy'.

.PARAMETER APIVersion
    Specifies the API version to search first. A missing cmdlet falls back to beta.

.PARAMETER ResourceName
    Specifies the resource name that scores the output type candidates.

.PARAMETER FixActualType
    Specifies the entity type explicitly when the cmdlet's output type name does not match it.

.PARAMETER AllowPrompt
    Indicates that interactive prompts are allowed while the scoring stays ambiguous.
#>
function Get-M365DSCGraphCmdletInfo
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $CmdLetNoun,

        [Parameter()]
        [ValidateSet('v1.0', 'beta')]
        [System.String]
        $APIVersion = 'v1.0',

        [Parameter()]
        [System.String]
        $ResourceName,

        [Parameter()]
        [System.String]
        $FixActualType,

        [Parameter()]
        [System.Boolean]
        $AllowPrompt = $true
    )

    $getCmdletName = "Get-$CmdLetNoun"

    $commandDetails = Find-MgGraphCommand -Command $getCmdletName -ApiVersion $APIVersion -ErrorAction SilentlyContinue
    if (-not $commandDetails)
    {
        if ($APIVersion -ne 'beta')
        {
            Write-Verbose -Message "Cmdlet $getCmdletName not found in v1.0, falling back to beta."
            $APIVersion = 'beta'
            $commandDetails = Find-MgGraphCommand -Command $getCmdletName -ApiVersion $APIVersion -ErrorAction SilentlyContinue
        }

        if (-not $commandDetails)
        {
            throw "Cmdlet '$getCmdletName' was not found. Verify the noun and that the Microsoft.Graph modules are installed."
        }
    }

    $getCommand = Get-Command -Name $getCmdletName -ErrorAction Stop
    $graphModule = $getCommand.ModuleName
    Import-Module -Name $graphModule -ErrorAction Stop

    # Several output types mean the URI is ambiguous. Scoring by name picks one.
    $outputTypes = @($commandDetails.OutputType | Sort-Object -Unique | Where-Object { -not [System.String]::IsNullOrEmpty($_) })
    if ($outputTypes.Count -gt 1)
    {
        $outputType = Resolve-M365DSCTypeCandidate -Candidates $outputTypes `
            -ResourceName $ResourceName `
            -CmdLetNoun $CmdLetNoun `
            -PromptCaption 'The cmdlet declares multiple output types' `
            -AllowPrompt $AllowPrompt
    }
    else
    {
        $outputType = $outputTypes[0]
    }

    # Graph output types sometimes carry a '1' disambiguation suffix.
    $outputType = $outputType -replace '(?<=[A-Za-z])1$', ''

    if ([System.String]::IsNullOrEmpty($FixActualType))
    {
        $actualType = $outputType.Replace('IMicrosoftGraph', '')
    }
    else
    {
        $actualType = $FixActualType
    }

    # The entity type name in the CSDL is camelCase.
    $actualType = Get-StringFirstCharacterToLower -Value $actualType

    # Update cmdlets are verbed Update- or Set- depending on the module.
    $updateVerb = 'Update'
    if ($null -eq (Find-MgGraphCommand -Command "Update-$CmdLetNoun" -ApiVersion $APIVersion -ErrorAction SilentlyContinue))
    {
        $updateVerb = 'Set'
    }

    $result = @{
        APIVersion    = $APIVersion
        GraphModule   = $graphModule
        ActualType    = $actualType
        GetCmdlet     = $getCmdletName
        NewCmdlet     = "New-$CmdLetNoun"
        UpdateCmdlet  = "$updateVerb-$CmdLetNoun"
        UpdateVerb    = $updateVerb
        RemoveCmdlet  = "Remove-$CmdLetNoun"
        GetKeyParameters    = @(Get-M365DSCCmdletKeyParameter -CmdletName $getCmdletName -ParameterSetNames @('Get'))
        NewKeyParameters    = @(Get-M365DSCCmdletKeyParameter -CmdletName "New-$CmdLetNoun" -ParameterSetNames @('Create'))
        UpdateKeyParameters = @(Get-M365DSCCmdletKeyParameter -CmdletName "$updateVerb-$CmdLetNoun" -ParameterSetNames @('Update', 'Set'))
        RemoveKeyParameters = @(Get-M365DSCCmdletKeyParameter -CmdletName "Remove-$CmdLetNoun" -ParameterSetNames @('Delete'))
        Warnings            = @()
    }

    # Some entities have no New- cmdlet because a PUT through the Set- cmdlet creates them.
    $result.SupportsNew = $null -ne (Get-Command -Name "New-$CmdLetNoun" -ErrorAction SilentlyContinue)
    if (-not $result.SupportsNew)
    {
        $message = "Cmdlet 'New-$CmdLetNoun' does not exist. The generated create logic calls '$($result.UpdateCmdlet)' instead."
        Write-Warning -Message $message
        $result.Warnings += $message
        $result.NewCmdlet = $result.UpdateCmdlet
        $result.NewKeyParameters = $result.UpdateKeyParameters
    }

    # What the List parameter set supports shapes the export enumeration.
    $listParameterSet = $getCommand.ParameterSets | Where-Object -FilterScript { $_.Name -eq 'List' }
    $result.SupportsAll = @($listParameterSet.Parameters.Name) -contains 'All'
    $result.SupportsFilter = @($listParameterSet.Parameters.Name) -contains 'Filter'
    if ($null -eq $listParameterSet -and @($result.GetKeyParameters).Count -gt 0)
    {
        $message = "Cmdlet '$getCmdletName' cannot list instances. Write Export() to enumerate the parent collection, see AADCrossTenantIdentitySyncPolicyPartner."
        Write-Warning -Message $message
        $result.Warnings += $message
    }

    # Intune style assignments need a Get-<Noun>Assignment cmdlet and the policy's REST repository.
    $result.HasAssignments = $false
    $assignmentCommand = Get-Command -Name "$getCmdletName`Assignment" -Module $graphModule -ErrorAction SilentlyContinue
    if ($null -ne $assignmentCommand)
    {
        $repository = @($commandDetails | Where-Object -FilterScript { $_.Variants -contains 'List' }).URI | Select-Object -First 1
        $assignmentKey = @(Get-M365DSCCmdletKeyParameter -CmdletName $assignmentCommand.Name -ParameterSetNames @('List')) | Select-Object -First 1

        if (-not [System.String]::IsNullOrWhiteSpace($repository) -and -not [System.String]::IsNullOrWhiteSpace($assignmentKey))
        {
            $result.HasAssignments = $true
            $result.AssignmentCmdlet = $assignmentCommand.Name
            $result.AssignmentNoun = $assignmentCommand.Noun
            $result.AssignmentKeyParameter = $assignmentKey
            $result.AssignmentRepository = $repository.TrimStart('/')
        }
    }

    return $result
}

<#
.SYNOPSIS
    Resolves the concrete OData subtype of a polymorphic entity type.

.PARAMETER Schema
    Specifies the CSDL schema nodes from Get-M365DSCGraphCsdlMetadata.

.PARAMETER ActualType
    Specifies the entity type behind the cmdlet.

.PARAMETER ResourceName
    Specifies the resource name that scores the subtype candidates.

.PARAMETER CmdLetNoun
    Specifies the Graph cmdlet noun that scores the subtype candidates.

.PARAMETER AdditionalPropertiesType
    Specifies the subtype to take instead of the scored one.

.PARAMETER AllowPrompt
    Indicates that interactive prompts are allowed while the scoring stays ambiguous.

.OUTPUTS
    A hashtable with SelectedODataType and IsAdditionalProperty. An entity without subtypes
    selects itself and IsAdditionalProperty stays false.
#>
function Resolve-M365DSCGraphODataSubtype
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Object]
        $Schema,

        [Parameter(Mandatory = $true)]
        [System.String]
        $ActualType,

        [Parameter()]
        [System.String]
        $ResourceName,

        [Parameter()]
        [System.String]
        $CmdLetNoun,

        [Parameter()]
        [System.String]
        $AdditionalPropertiesType,

        [Parameter()]
        [System.Boolean]
        $AllowPrompt = $true
    )

    # An abstract type between the entity and its concrete subtypes adds one level to the search.
    [array] $abstractTypes = @($Schema.EntityType | Where-Object -FilterScript {
            $_.BaseType -eq "graph.$ActualType" -and $_.Abstract -eq 'true'
        }).Name

    $typesToSearch = @(@($abstractTypes) + $ActualType | Where-Object { -not [System.String]::IsNullOrEmpty($_) })
    $subtypes = @()
    foreach ($typeToSearch in $typesToSearch)
    {
        $subtypes += @($Schema.EntityType | Where-Object -FilterScript { $_.BaseType -eq "graph.$typeToSearch" }).Name
    }
    $subtypes = @($subtypes | Where-Object { -not [System.String]::IsNullOrEmpty($_) } | Sort-Object -Unique)

    if ($subtypes.Count -eq 0)
    {
        return @{
            SelectedODataType    = $ActualType
            IsAdditionalProperty = $false
        }
    }

    $selected = Resolve-M365DSCTypeCandidate -Candidates $subtypes `
        -ResourceName $ResourceName `
        -CmdLetNoun $CmdLetNoun `
        -Override $AdditionalPropertiesType `
        -PromptCaption "Entity type '$ActualType' is polymorphic" `
        -AllowPrompt $AllowPrompt

    return @{
        SelectedODataType    = $selected
        IsAdditionalProperty = $true
    }
}

<#
.SYNOPSIS
    Returns a CSDL type name in the form settings.json records it.

.DESCRIPTION
    Types in the microsoft.graph namespace keep the bare name. A sub-namespace stays in front, for
    example 'networkaccess.filteringProfile'. The first namespace that declares a bare name wins.

.PARAMETER Schema
    Specifies the CSDL schema nodes from Get-M365DSCGraphCsdlMetadata.

.PARAMETER TypeName
    Specifies the bare type name.
#>
function Get-M365DSCGraphQualifiedTypeName
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Object]
        $Schema,

        [Parameter()]
        [System.String]
        $TypeName
    )

    if ([System.String]::IsNullOrEmpty($TypeName))
    {
        return $null
    }

    $namespaceNode = @($Schema | Where-Object -FilterScript {
            $_.EntityType.Name -contains $TypeName -or $_.ComplexType.Name -contains $TypeName
        }) | Select-Object -First 1

    if ($null -eq $namespaceNode -or [System.String] $namespaceNode.Namespace -eq 'microsoft.graph')
    {
        return $TypeName
    }

    return (([System.String] $namespaceNode.Namespace) -replace '^microsoft\.graph\.', '') + '.' + $TypeName
}

<#
.SYNOPSIS
    Returns the mandatory parameters of a cmdlet's parameter set.

.DESCRIPTION
    The default parameter set answers when none of the named sets exist.

.PARAMETER CmdletName
    Specifies the cmdlet to read.

.PARAMETER ParameterSetNames
    Specifies the parameter set names to try in order.
#>
function Get-M365DSCCmdletKeyParameter
{
    [CmdletBinding()]
    [OutputType([System.String[]])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $CmdletName,

        [Parameter(Mandatory = $true)]
        [System.String[]]
        $ParameterSetNames
    )

    $command = Get-Command -Name $CmdletName -ErrorAction SilentlyContinue
    if ($null -eq $command)
    {
        return [System.String[]] @()
    }

    $parameterSet = $null
    foreach ($setName in $ParameterSetNames)
    {
        $parameterSet = $command.ParameterSets | Where-Object -FilterScript { $_.Name -eq $setName }
        if ($null -ne $parameterSet)
        {
            break
        }
    }

    if ($null -eq $parameterSet)
    {
        $parameterSet = $command.ParameterSets | Where-Object -FilterScript { $_.IsDefault }
    }

    $keys = @($parameterSet.Parameters | Where-Object -FilterScript { $_.IsMandatory }).Name

    return [System.String[]] @($keys | Where-Object { -not [System.String]::IsNullOrEmpty($_) })
}
