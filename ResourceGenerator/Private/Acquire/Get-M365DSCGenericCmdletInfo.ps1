<#
.SYNOPSIS
    Discovers cmdlet and property information for the non-Graph workloads.

.DESCRIPTION
    Introspects the workload cmdlet (ExchangeOnline, MicrosoftTeams, SecurityComplianceCenter,
    PnP, PowerPlatforms) through Get-Command: the default parameter set supplies the property
    list, or the union of all sets when the cmdlet declares no default. Parameter help supplies
    the descriptions. A mandatory 'Identity' or 'Name', else the first mandatory parameter,
    becomes the primary key (Teams resources force 'Identity'). Returns cmdlet names plus ready property
    models - the same shape the Graph acquisition produces, so everything downstream is shared.

.PARAMETER CmdLetNoun
    Specifies the cmdlet noun, e.g. 'DistributionGroup'.

.PARAMETER CmdLetVerb
    Specifies the verb of the cmdlet whose parameters describe the resource, usually 'New' or 'Set'.

.PARAMETER Workload
    Specifies the workload the cmdlet belongs to.
#>
function Get-M365DSCGenericCmdletInfo
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $CmdLetNoun,

        [Parameter()]
        [System.String]
        $CmdLetVerb = 'New',

        [Parameter(Mandatory = $true)]
        [System.String]
        $Workload
    )

    $commonParameters = @(
        'Verbose', 'Debug', 'ErrorAction', 'WarningAction', 'InformationAction', 'ErrorVariable',
        'WarningVariable', 'InformationVariable', 'OutVariable', 'OutBuffer', 'PipelineVariable',
        'WhatIf', 'Confirm', 'ProgressAction', 'Break', 'HttpPipelineAppend', 'HttpPipelinePrepend',
        'Proxy', 'ProxyCredential', 'ProxyUseDefaultCredentials'
    )

    $cmdletName = "$CmdLetVerb-$CmdLetNoun"
    $cmdlet = Get-Command -Name $cmdletName -ErrorAction Stop

    $defaultParameterSet = $cmdlet.ParameterSets | Where-Object -FilterScript { $_.IsDefault }
    if ($null -eq $defaultParameterSet -and $cmdlet.ParameterSets.Count -eq 1)
    {
        $defaultParameterSet = $cmdlet.ParameterSets[0]
    }

    if ($null -ne $defaultParameterSet)
    {
        $parameters = @($defaultParameterSet.Parameters)
    }
    else
    {
        # Remote session proxies such as the Security & Compliance cmdlets declare no default set.
        $parameterSets = @($cmdlet.ParameterSets | Sort-Object -Property { $_.Name -ne 'Default' })
        $parameters = @($parameterSets.Parameters | Group-Object -Property Name | ForEach-Object -Process {
                [PSCustomObject]@{
                    Name          = $_.Name
                    ParameterType = $_.Group[0].ParameterType
                    IsMandatory   = $_.Count -eq $parameterSets.Count -and @($_.Group | Where-Object -FilterScript { -not $_.IsMandatory }).Count -eq 0
                }
            })
    }

    $parameters = @($parameters | Where-Object -FilterScript {
            $_.Name -notin $commonParameters -and -not $_.Name.StartsWith('MsftInternal')
        })

    $primaryKey = ''
    $identityParameter = $parameters | Where-Object -FilterScript { $_.Name -eq 'Identity' } | Select-Object -First 1
    $nameKeyParameter = $parameters | Where-Object -FilterScript { $_.IsMandatory -and $_.Name -in @('Identity', 'Name') } | Select-Object -First 1
    if ($Workload -eq 'MicrosoftTeams' -and $null -ne $identityParameter)
    {
        $primaryKey = 'Identity'
    }
    elseif ($null -ne $nameKeyParameter)
    {
        $primaryKey = $nameKeyParameter.Name
    }
    else
    {
        $firstMandatory = $parameters | Where-Object -FilterScript { $_.IsMandatory } | Select-Object -First 1
        if ($null -ne $firstMandatory)
        {
            $primaryKey = $firstMandatory.Name
        }
    }

    $models = @()
    $warnings = @()
    foreach ($parameter in $parameters)
    {
        # Descriptions come back as MamlDescription object arrays; flatten them to plain text.
        $description = ''
        $rawDescription = $null
        if ($null -ne $parameter.PSObject.Properties['Description'])
        {
            $rawDescription = $parameter.Description
        }
        if ($null -eq $rawDescription)
        {
            try
            {
                $rawDescription = (Get-Help -Name $cmdletName -Parameter $parameter.Name -ErrorAction SilentlyContinue).Description
            }
            catch
            {
                $rawDescription = $null
            }
        }
        if ($null -ne $rawDescription)
        {
            $description = (@($rawDescription | ForEach-Object {
                        if ($null -ne $_.PSObject.Properties['Text'])
                        {
                            $_.Text
                        }
                        else
                        {
                            [System.String] $_
                        }
                    }) -join ' ').Trim()
        }
        if ([System.String]::IsNullOrEmpty($description))
        {
            $description = "The $($parameter.Name) parameter of the $CmdLetNoun."
        }
        $description = ConvertTo-M365DSCPlainDescription -Description $description

        $isKey = $parameter.Name -eq $primaryKey

        $parameterType = $parameter.ParameterType
        $isArray = $parameterType.IsArray
        $typeName = $parameterType.FullName
        if ($isArray)
        {
            $typeName = $parameterType.GetElementType().FullName
        }

        $enumValues = @()
        $elementType = $parameterType
        if ($isArray)
        {
            $elementType = $parameterType.GetElementType()
        }
        if ($elementType.IsEnum)
        {
            $enumValues = [System.String[]] [System.Enum]::GetNames($elementType)
        }
        elseif ($typeName -notlike 'System.*' -or $typeName -in @('System.Object', 'System.Management.Automation.PSObject'))
        {
            $message = "Parameter '$($parameter.Name)' has type '$typeName' and is generated as a string. Model it as a complex type."
            Write-Warning -Message $message
            $warnings += $message
        }

        $models += New-M365DSCPropertyModel -Name $parameter.Name `
            -Type $typeName `
            -Description $description `
            -IsArray $isArray `
            -IsKey $isKey `
            -IsMandatory $parameter.IsMandatory `
            -EnumValues $enumValues
    }

    # Which cmdlets exist decides what Set() can do and what the tests mock.
    $result = @{
        Workload      = $Workload
        PrimaryKey    = $primaryKey
        Properties    = $models
        GetCmdlet     = "Get-$CmdLetNoun"
        NewCmdlet     = "New-$CmdLetNoun"
        UpdateCmdlet  = "Set-$CmdLetNoun"
        RemoveCmdlet  = "Remove-$CmdLetNoun"
        Warnings      = $warnings
    }

    foreach ($operation in @('Get', 'New', 'Update', 'Remove'))
    {
        $verb = $operation
        if ($operation -eq 'Update')
        {
            $verb = 'Set'
        }

        $exists = $null -ne (Get-Command -Name "$verb-$CmdLetNoun" -ErrorAction SilentlyContinue)
        $result["Supports$operation"] = $exists
        if (-not $exists)
        {
            Write-Warning -Message "Cmdlet '$verb-$CmdLetNoun' does not exist; the generated $operation logic will need manual attention."
        }
    }

    # Whether Export() can pass the -Filters entry the reverse engine collected. Also decides
    # whether the class declares the export-only $Filter property that the engine probes for.
    $getCommand = Get-Command -Name "Get-$CmdLetNoun" -ErrorAction SilentlyContinue
    $result.FilterParameterName = $null
    foreach ($filterParameterName in @('Filter', 'NameFilter'))
    {
        if ($null -ne $getCommand -and $getCommand.Parameters.ContainsKey($filterParameterName))
        {
            $result.FilterParameterName = $filterParameterName
            break
        }
    }
    $result.SupportsFilter = $null -ne $result.FilterParameterName

    # Teams list cmdlets return one page per call and need -First/-Skip to enumerate everything.
    $result.SupportsPaging = $null -ne $getCommand -and
        $getCommand.Parameters.ContainsKey('First') -and
        $getCommand.Parameters.ContainsKey('Skip')

    # Key parameter of the Get cmdlet, for the Get() lookup.
    $getKeys = @(Get-M365DSCCmdletKeyParameter -CmdletName "Get-$CmdLetNoun" -ParameterSetNames @('Identity', 'Default'))
    $result.GetKeyParameters = $getKeys
    $result.GetLookup = Get-M365DSCGenericLookup -GetCommand $getCommand `
        -PrimaryKey $primaryKey `
        -Workload $Workload `
        -FilterParameterName $result.FilterParameterName

    # Remove() passes the service object's own values, so only the parameter names are needed.
    $removeCommand = Get-Command -Name "Remove-$CmdLetNoun" -ErrorAction SilentlyContinue
    $result.RemoveKeyParameters = @(Get-M365DSCMandatoryParameterName -Command $removeCommand)
    $result.RemoveSupportsConfirm = $null -ne $removeCommand -and $removeCommand.Parameters.ContainsKey('Confirm')

    # Update() drops what the Set cmdlet does not accept, such as the key or create-only values.
    $updateCommand = Get-Command -Name "Set-$CmdLetNoun" -ErrorAction SilentlyContinue
    $result.UpdateParameterNames = @()
    if ($null -ne $updateCommand)
    {
        $result.UpdateParameterNames = @($updateCommand.Parameters.Keys)
    }

    return $result
}

<#
.SYNOPSIS
    Decides how Get() finds the instance of a non-Graph resource from its primary key.

.DESCRIPTION
    Returns Mode (Direct, NameFilter, List or None) and the Get parameter that receives the key.
    Exchange and Security and Compliance pass names to Identity.

.PARAMETER GetCommand
    Specifies the Get cmdlet, or $null when it does not exist.

.PARAMETER PrimaryKey
    Specifies the primary key of the resource.

.PARAMETER Workload
    Specifies the workload of the resource.

.PARAMETER FilterParameterName
    Specifies the filter parameter of the Get cmdlet, if any.
#>
function Get-M365DSCGenericLookup
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter()]
        [System.Management.Automation.CommandInfo]
        $GetCommand,

        [Parameter()]
        [System.String]
        $PrimaryKey,

        [Parameter(Mandatory = $true)]
        [System.String]
        $Workload,

        [Parameter()]
        [System.String]
        $FilterParameterName
    )

    if ($null -eq $GetCommand)
    {
        return @{ Mode = 'None'; Parameter = $null }
    }

    if (-not [System.String]::IsNullOrEmpty($PrimaryKey) -and $GetCommand.Parameters.ContainsKey($PrimaryKey))
    {
        return @{ Mode = 'Direct'; Parameter = $PrimaryKey }
    }

    if ($FilterParameterName -eq 'NameFilter')
    {
        return @{ Mode = 'NameFilter'; Parameter = 'NameFilter' }
    }

    if ($Workload -in @('ExchangeOnline', 'SecurityComplianceCenter') -and $GetCommand.Parameters.ContainsKey('Identity'))
    {
        return @{ Mode = 'Direct'; Parameter = 'Identity' }
    }

    return @{ Mode = 'List'; Parameter = $null }
}

<#
.SYNOPSIS
    Returns the mandatory parameter names of a cmdlet's default parameter set.

.PARAMETER Command
    Specifies the cmdlet, or $null when it does not exist.
#>
function Get-M365DSCMandatoryParameterName
{
    [CmdletBinding()]
    [OutputType([System.String[]])]
    param
    (
        [Parameter()]
        [System.Management.Automation.CommandInfo]
        $Command
    )

    if ($null -eq $Command)
    {
        return [System.String[]] @()
    }

    $parameterSet = $Command.ParameterSets | Where-Object -FilterScript { $_.IsDefault } | Select-Object -First 1
    if ($null -eq $parameterSet)
    {
        $parameterSet = $Command.ParameterSets | Select-Object -First 1
    }

    return [System.String[]] @($parameterSet.Parameters | Where-Object -FilterScript { $_.IsMandatory } | ForEach-Object -Process { $_.Name })
}

<#
.SYNOPSIS
    Turns cmdlet help text into a plain one-line property description.

.DESCRIPTION
    Strips callouts and links, and turns PARAMVALUE and list items into sentences.

.PARAMETER Description
    Specifies the raw help text.
#>
function ConvertTo-M365DSCPlainDescription
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter()]
        [System.String]
        $Description
    )

    if ([System.String]::IsNullOrEmpty($Description))
    {
        return ''
    }

    $result = $Description.Replace('"', "'")
    $result = $result -replace '>\s*\[!(NOTE|IMPORTANT|WARNING|TIP|CAUTION)\]', ''
    $result = $result -replace '\s*\(https?://[^)\s]*\)\s*', ' '
    $result = [System.Text.RegularExpressions.Regex]::Replace($result, 'PARAMVALUE:\s*([^.]+?)\s*(\.|$)', {
            param($match)
            $values = @($match.Groups[1].Value -split '\s*\|\s*' | Where-Object -FilterScript { -not [System.String]::IsNullOrWhiteSpace($_) })
            'Possible values are ' + ($values -join ', ') + '.'
        })
    $result = $result -replace '(^|\s)>\s', '$1'
    $result = ($result -replace '\s+', ' ').Trim()

    foreach ($listMarker in @('\s+\d+\.\s+(?=\S)', '\s+-\s+(?=\S)'))
    {
        $segments = @([System.Text.RegularExpressions.Regex]::Split($result, $listMarker))
        if ($segments.Count -lt 3)
        {
            continue
        }

        $sentences = for ($index = 0; $index -lt $segments.Count; $index++)
        {
            $sentence = $segments[$index].Trim()
            if ([System.String]::IsNullOrEmpty($sentence))
            {
                continue
            }

            if ($index -gt 0 -and $sentence -notmatch '[.!?]$')
            {
                $sentence += '.'
            }

            $sentence
        }
        $result = $sentences -join ' '
    }

    return $result
}
