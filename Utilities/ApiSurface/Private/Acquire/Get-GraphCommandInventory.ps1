<#
.SYNOPSIS
    Reads the Graph SDK command metadata and groups it by cmdlet noun.

.DESCRIPTION
    MgCommandMetadata.json ships inside Microsoft.Graph.Authentication and carries the route of
    every SDK command. Enumerating ExportedCommands would cost 39 module imports and would not
    carry the routes. A version other than the pinned one is marked as a fallback.

.PARAMETER PinnedVersion
    Specifies the version Manifest.psd1 pins.

.PARAMETER MetadataPath
    Specifies the metadata file. Empty resolves it from the installed module.

.OUTPUTS
    An ordered dictionary with Source and Noun, a map of noun to its commands.
#>
function Get-GraphCommandInventory
{
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param
    (
        [Parameter()]
        [AllowEmptyString()]
        [System.String]
        $PinnedVersion,

        [Parameter()]
        [AllowEmptyString()]
        [System.String]
        $MetadataPath
    )

    $source = [ordered]@{
        module        = 'Microsoft.Graph.Authentication'
        version       = ''
        versionSource = 'missing'
    }

    if ([System.String]::IsNullOrEmpty($MetadataPath))
    {
        $module = @(Get-Module -ListAvailable -Name 'Microsoft.Graph.Authentication' -ErrorAction SilentlyContinue |
                Sort-Object -Property Version -Descending)

        $selected = @($module | Where-Object -FilterScript { $_.Version.ToString() -eq $PinnedVersion })[0]
        if ($null -eq $selected)
        {
            $selected = $module[0]
        }

        if ($null -eq $selected)
        {
            Write-Warning -Message 'Microsoft.Graph.Authentication is not installed. The coverage report is skipped.'
            return [ordered]@{ Source = $source; Noun = [ordered]@{} }
        }

        $source['version'] = $selected.Version.ToString()
        $MetadataPath = Join-Path -Path (Split-Path -Path $selected.Path -Parent) -ChildPath 'custom/common/MgCommandMetadata.json'
    }

    if (-not (Test-Path -Path $MetadataPath))
    {
        Write-Warning -Message "'$MetadataPath' does not exist. The coverage report is skipped."
        return [ordered]@{ Source = $source; Noun = [ordered]@{} }
    }

    $source['versionSource'] = 'fallback'
    if ($source['version'] -eq $PinnedVersion -or [System.String]::IsNullOrEmpty($PinnedVersion))
    {
        $source['versionSource'] = 'pinned'
    }

    return [ordered]@{
        Source = $source
        Noun   = ConvertTo-GraphNounMap -Row @(Get-Content -Path $MetadataPath -Raw | ConvertFrom-Json)
    }
}

<#
.SYNOPSIS
    Groups metadata rows by the noun of their command.

.DESCRIPTION
    A noun is the command name after the Mg or MgBeta prefix, which is what New-M365DSCResource
    takes as -CmdLetNoun. Mg and MgBeta of one noun are the same candidate.

.PARAMETER Row
    Specifies the metadata rows.

.OUTPUTS
    A map of noun to an object with Verbs, Modules, ApiVersions, Uris, OutputTypes and Commands.
#>
function ConvertTo-GraphNounMap
{
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param
    (
        [Parameter()]
        [AllowEmptyCollection()]
        [System.Object[]]
        $Row = @()
    )

    $map = @{}

    foreach ($entry in $Row)
    {
        $command = [System.String] $entry.Command
        if ($command -notmatch '^(?<verb>[A-Za-z]+)-Mg(Beta)?(?<noun>.+)$')
        {
            continue
        }

        $noun = $Matches['noun']
        $verb = $Matches['verb']

        if (-not $map.ContainsKey($noun))
        {
            $map[$noun] = [ordered]@{
                Verbs       = [System.Collections.Generic.HashSet[System.String]]::new([System.StringComparer]::OrdinalIgnoreCase)
                Modules     = [System.Collections.Generic.HashSet[System.String]]::new([System.StringComparer]::OrdinalIgnoreCase)
                ApiVersions = [System.Collections.Generic.HashSet[System.String]]::new([System.StringComparer]::OrdinalIgnoreCase)
                Uris        = [System.Collections.Generic.HashSet[System.String]]::new([System.StringComparer]::OrdinalIgnoreCase)
                OutputTypes = [System.Collections.Generic.HashSet[System.String]]::new([System.StringComparer]::OrdinalIgnoreCase)
                Commands    = [System.Collections.Generic.HashSet[System.String]]::new([System.StringComparer]::OrdinalIgnoreCase)
            }
        }

        $null = $map[$noun].Verbs.Add($verb)
        $null = $map[$noun].Commands.Add($command)

        foreach ($pair in @(
                @{ Key = 'Modules'; Value = [System.String] $entry.Module }
                @{ Key = 'ApiVersions'; Value = [System.String] $entry.ApiVersion }
                @{ Key = 'Uris'; Value = [System.String] $entry.Uri }
                @{ Key = 'OutputTypes'; Value = [System.String] $entry.OutputType }
            ))
        {
            if (-not [System.String]::IsNullOrWhiteSpace($pair.Value))
            {
                $null = $map[$noun][$pair.Key].Add($pair.Value)
            }
        }
    }

    return ConvertTo-M365DSCOrderedMap -Map $map
}

<#
.SYNOPSIS
    Tells whether a noun offers a create, a read, an update and a delete.

.PARAMETER Verb
    Specifies the verbs the noun carries.

.OUTPUTS
    True when all four are present.
#>
function Test-FullCrudNoun
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Object]
        $Verb
    )

    $verbs = [System.Collections.Generic.HashSet[System.String]]::new(
        [System.String[]] @($Verb), [System.StringComparer]::OrdinalIgnoreCase)

    return $verbs.Contains('Get') -and
        $verbs.Contains('New') -and
        $verbs.Contains('Remove') -and
        ($verbs.Contains('Set') -or $verbs.Contains('Update'))
}
