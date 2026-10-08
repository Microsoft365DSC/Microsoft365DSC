<#
.SYNOPSIS
    Adds parameter stubs for a cmdlet noun to Tests\Unit\Stubs\Microsoft365.psm1.

.DESCRIPTION
    Inserts each missing stub alphabetically into its module region, creating the region if needed.

.PARAMETER CmdletNoun
    Specifies the cmdlet noun, e.g. 'MgBetaPolicyPermissionGrantPolicy'.

.PARAMETER StubFilePath
    Specifies the stub file. Defaults to Tests\Unit\Stubs\Microsoft365.psm1 in the repository.

.PARAMETER RegionName
    Specifies the region receiving the stubs. Defaults to the module name of each cmdlet.
#>
function Update-M365DSCStubFile
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $CmdletNoun,

        [Parameter()]
        [System.String]
        $StubFilePath,

        [Parameter()]
        [System.String]
        $RegionName
    )

    if ([System.String]::IsNullOrEmpty($StubFilePath))
    {
        $StubFilePath = Join-Path -Path $PSScriptRoot -ChildPath '..\..\..\Tests\Unit\Stubs\Microsoft365.psm1' -Resolve
    }

    $commands = @(Get-M365DSCStubCommand -CmdletNoun $CmdletNoun)
    if ($commands.Count -eq 0)
    {
        Write-Warning -Message "No cmdlets found for noun '$CmdletNoun'; the stub file was not updated."
        return
    }

    $null = Add-M365DSCCommandStub -Command $commands -StubFilePath $StubFilePath -RegionName $RegionName
}

<#
.SYNOPSIS
    Returns the workload cmdlets a resource module calls.

.DESCRIPTION
    Skips aliases, the module's own functions and PowerShell, Pester, DSC and Microsoft365DSC commands.

.PARAMETER ModulePath
    Specifies the resource module file.
#>
function Get-M365DSCResourceCommand
{
    [CmdletBinding()]
    [OutputType([System.Management.Automation.CommandInfo[]])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $ModulePath
    )

    $parseErrors = $null
    $ast = [System.Management.Automation.Language.Parser]::ParseFile($ModulePath, [ref] $null, [ref] $parseErrors)

    $definedNames = @($ast.FindAll({ param($node) $node -is [System.Management.Automation.Language.FunctionDefinitionAst] }, $true) |
            ForEach-Object -Process { $_.Name })

    $invokedNames = @($ast.FindAll({ param($node) $node -is [System.Management.Automation.Language.CommandAst] }, $true) |
            ForEach-Object -Process { $_.GetCommandName() } |
            Where-Object -FilterScript { $_ -match '^[A-Za-z]+-[A-Za-z0-9]+$' -and $_ -notin $definedNames -and $_ -notmatch 'M365DSC' } |
            Sort-Object -Unique)

    $excludedModules = '^(Microsoft\.PowerShell\..*|Microsoft365DSC.*|M365DSC.*|MSCloudLoginAssistant|Pester|PSDesiredStateConfiguration|M365DSCResourceGenerator)$'

    $commands = @()
    foreach ($name in $invokedNames)
    {
        $command = Get-Command -Name $name -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($null -eq $command)
        {
            Write-Verbose -Message "Command '$name' is not available in this session; no stub is added for it."
            continue
        }

        if ($command.CommandType -eq 'Alias' -or $command.ModuleName -match $excludedModules)
        {
            continue
        }

        $commands += $command
    }

    return [System.Management.Automation.CommandInfo[]] $commands
}

<#
.SYNOPSIS
    Adds a stub for every command that has none yet and returns the names of the added stubs.

.PARAMETER Command
    Specifies the commands to stub.

.PARAMETER StubFilePath
    Specifies the stub file.

.PARAMETER RegionName
    Specifies the region receiving the stubs. Defaults to the module name of each command.
#>
function Add-M365DSCCommandStub
{
    [CmdletBinding()]
    [OutputType([System.String[]])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.CommandInfo[]]
        $Command,

        [Parameter(Mandatory = $true)]
        [System.String]
        $StubFilePath,

        [Parameter()]
        [System.String]
        $RegionName
    )

    $lines = [System.Collections.Generic.List[System.String]]::new([System.String[]] @(Get-Content -Path $StubFilePath))
    $addedNames = @()
    foreach ($stubCommand in ($Command | Sort-Object -Property Name))
    {
        if ($lines.Contains("function $($stubCommand.Name)"))
        {
            Write-Verbose -Message "A stub for '$($stubCommand.Name)' already exists in $StubFilePath."
            continue
        }

        $targetRegion = $RegionName
        if ([System.String]::IsNullOrEmpty($targetRegion))
        {
            $targetRegion = $stubCommand.ModuleName
        }

        $stubLines = @((Get-M365DSCCommandStub -Command $stubCommand).TrimEnd() -split "`r?`n")
        Add-M365DSCStubToRegion -Lines $lines -RegionName $targetRegion -FunctionName $stubCommand.Name -StubLines $stubLines
        $addedNames += $stubCommand.Name
    }

    if ($addedNames.Count -gt 0)
    {
        Set-Content -Path $StubFilePath -Value $lines
    }

    return [System.String[]] $addedNames
}

<#
.SYNOPSIS
    Inserts a stub function into a region of the stub file lines, in alphabetical order.

.PARAMETER Lines
    Specifies the lines of the stub file. The list is changed in place.

.PARAMETER RegionName
    Specifies the region receiving the stub. It is created when it does not exist.

.PARAMETER FunctionName
    Specifies the name of the stubbed function, which decides its position.

.PARAMETER StubLines
    Specifies the lines of the stub function.
#>
function Add-M365DSCStubToRegion
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [AllowEmptyCollection()]
        [System.Collections.Generic.List[System.String]]
        $Lines,

        [Parameter(Mandatory = $true)]
        [System.String]
        $RegionName,

        [Parameter(Mandatory = $true)]
        [System.String]
        $FunctionName,

        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [System.String[]]
        $StubLines
    )

    $regionStart = $Lines.IndexOf("#region $RegionName")
    if ($regionStart -lt 0)
    {
        $insertRegionAt = $Lines.Count
        for ($index = 0; $index -lt $Lines.Count; $index++)
        {
            if ($Lines[$index] -match '^#region (.+)$' -and
                [System.String]::Compare($Matches[1], $RegionName, [System.StringComparison]::OrdinalIgnoreCase) -gt 0)
            {
                $insertRegionAt = $index
                break
            }
        }

        $regionLines = @("#region $RegionName", '#endregion', '')
        if ($insertRegionAt -eq $Lines.Count -and $Lines.Count -gt 0 -and $Lines[$Lines.Count - 1] -ne '')
        {
            $regionLines = @('') + $regionLines
        }
        $Lines.InsertRange($insertRegionAt, [System.String[]] $regionLines)
        $regionStart = $Lines.IndexOf("#region $RegionName")
    }

    $regionEnd = $Lines.IndexOf('#endregion', $regionStart)
    $insertAt = $regionEnd
    for ($index = $regionStart + 1; $index -lt $regionEnd; $index++)
    {
        if ($Lines[$index] -match '^function (\S+)$' -and
            [System.String]::Compare($Matches[1], $FunctionName, [System.StringComparison]::OrdinalIgnoreCase) -gt 0)
        {
            $insertAt = $index
            break
        }
    }

    $Lines.InsertRange($insertAt, [System.String[]] ($StubLines + ''))
}

<#
.SYNOPSIS
    Returns the cmdlets of a noun from the highest installed module version, sorted by name.
#>
function Get-M365DSCStubCommand
{
    [CmdletBinding()]
    [OutputType([System.Management.Automation.CommandInfo[]])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $CmdletNoun
    )

    $commands = @(Get-Command -Noun $CmdletNoun -ErrorAction SilentlyContinue)
    if ($commands.Count -eq 0)
    {
        return @()
    }

    $latestVersion = ($commands | Sort-Object -Property Version -Descending | Select-Object -First 1).Version
    return @($commands | Where-Object -FilterScript { $_.Version -eq $latestVersion } | Sort-Object -Property Name)
}

<#
.SYNOPSIS
    Renders stub function shells for every cmdlet of a noun.
#>
function Get-M365DSCCmdletStub
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $CmdletNoun
    )

    $builder = [System.Text.StringBuilder]::new()
    foreach ($command in (Get-M365DSCStubCommand -CmdletNoun $CmdletNoun))
    {
        $null = $builder.Append((Get-M365DSCCommandStub -Command $command))
    }

    return $builder.ToString()
}

<#
.SYNOPSIS
    Renders the stub function shell of one cmdlet.
#>
function Get-M365DSCCommandStub
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.CommandInfo]
        $Command
    )

    $parametersToSkip = @(
        'Verbose', 'Debug', 'ErrorAction', 'WarningAction', 'InformationAction', 'ErrorVariable',
        'WarningVariable', 'InformationVariable', 'OutVariable', 'OutBuffer', 'PipelineVariable',
        'WhatIf', 'ProgressAction', 'IfMatch', 'Break', 'HttpPipelineAppend',
        'HttpPipelinePrepend', 'Proxy', 'ProxyCredential', 'ProxyUseDefaultCredentials'
    )

    $builder = [System.Text.StringBuilder]::new()
    $null = $builder.AppendLine("function $($Command.Name)")
    $null = $builder.AppendLine('{')
    $null = $builder.AppendLine('    [CmdletBinding()]')
    $null = $builder.AppendLine('    param')
    $null = $builder.AppendLine('    (')

    $parameterNames = @($Command.Parameters.Keys | Where-Object -FilterScript { $_ -notin $parametersToSkip })
    $index = 0
    foreach ($parameterName in $parameterNames)
    {
        $parameter = $Command.Parameters[$parameterName]
        $type = $parameter.ParameterType.ToString()
        if ($type -notlike 'System.*')
        {
            $type = 'PSObject'
            if ($parameter.ParameterType.IsArray)
            {
                $type += '[]'
            }
        }

        $null = $builder.AppendLine('        [Parameter()]')
        $null = $builder.AppendLine("        [$type]")
        $null = $builder.Append("        `$$($parameter.Name)")
        if ($index -lt $parameterNames.Count - 1)
        {
            $null = $builder.Append(",`r`n")
        }
        $null = $builder.Append("`r`n")
        $index++
    }

    $null = $builder.AppendLine('    )')
    $null = $builder.AppendLine("}`r`n")

    return $builder.ToString()
}
