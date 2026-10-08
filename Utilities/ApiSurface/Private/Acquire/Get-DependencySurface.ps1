<#
.SYNOPSIS
    Captures the pinned dependency versions and what the gallery publishes today.

.DESCRIPTION
    A failed gallery lookup leaves latestPublished null. The snapshot stays available without
    network access.

.PARAMETER ManifestPath
    Specifies the path of Manifest.psd1.

.PARAMETER DevManifestPath
    Specifies the path of DevManifest.psd1.

.PARAMETER SkipGalleryLookup
    Indicates that latestPublished is left null without contacting the gallery.

.OUTPUTS
    A hashtable with Dependencies, an ordered map, and PinnedVersion, a map of module name to
    pinned version.
#>
function Get-DependencySurface
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $ManifestPath,

        [Parameter(Mandatory = $true)]
        [System.String]
        $DevManifestPath,

        [Parameter()]
        [switch]
        $SkipGalleryLookup
    )

    $pins = @{}
    $sources = @{}

    foreach ($manifest in @(
            @{ Path = $ManifestPath; Name = 'Manifest' },
            @{ Path = $DevManifestPath; Name = 'DevManifest' }))
    {
        if (-not (Test-Path -Path $manifest.Path))
        {
            continue
        }

        foreach ($dependency in (Import-PowerShellDataFile -Path $manifest.Path).Dependencies)
        {
            $name = [System.String] $dependency.ModuleName
            if ([System.String]::IsNullOrEmpty($name))
            {
                continue
            }

            $pins[$name] = [System.String] $dependency.RequiredVersion

            if (-not $sources.ContainsKey($name))
            {
                $sources[$name] = [System.Collections.Generic.List[System.String]]::new()
            }

            if ($manifest.Name -notin $sources[$name])
            {
                $sources[$name].Add($manifest.Name)
            }
        }
    }

    $dependencies = @{}
    foreach ($name in (Get-M365DSCOrderedName -Value ([System.String[]] @($pins.Keys))))
    {
        $latest = $null
        if (-not $SkipGalleryLookup)
        {
            $latest = Get-GalleryLatestVersion -Name $name
        }

        $dependencies[$name] = [ordered]@{
            pinned          = $pins[$name]
            manifests       = @($sources[$name])
            latestPublished = $latest
        }
    }

    return @{
        Dependencies  = ConvertTo-M365DSCOrderedMap -Map $dependencies
        PinnedVersion = $pins
    }
}

<#
.SYNOPSIS
    Asks the PowerShell Gallery for the newest published version of a module.

.DESCRIPTION
    Prefers Find-PSResource, the form CI installs with, and falls back to Find-Module.

.PARAMETER Name
    Specifies the module name.

.OUTPUTS
    The version string, or $null.
#>
function Get-GalleryLatestVersion
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Name
    )

    try
    {
        if ($null -ne (Get-Command -Name 'Find-PSResource' -ErrorAction SilentlyContinue))
        {
            $versions = @(Find-PSResource -Name $Name -Repository 'PSGallery' -ErrorAction Stop).Version
        }
        else
        {
            $versions = @(Find-Module -Name $Name -ErrorAction Stop).Version
        }

        $newest = $versions | Sort-Object -Descending | Select-Object -First 1
        if ($null -eq $newest)
        {
            return $null
        }

        return $newest.ToString()
    }
    catch
    {
        Write-Warning -Message "Looking '$Name' up in the gallery failed. Its latest published version is recorded as null. $($_.Exception.Message)"
        return $null
    }
}
