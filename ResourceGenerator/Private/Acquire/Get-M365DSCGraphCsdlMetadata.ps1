<#
.SYNOPSIS
    Returns the Microsoft Graph CSDL schema nodes for an API version.

.DESCRIPTION
    Downloads the cleaned Graph metadata published in the msgraph-metadata repository and caches
    it under $env:LOCALAPPDATA so repeat generations - and offline runs - do not depend on the
    network. A fresh cache (younger than 7 days) is used directly; otherwise the download is
    attempted and any stale cache serves as fallback when the download fails.

.PARAMETER APIVersion
    Specifies the Graph API version to load.

.PARAMETER Force
    Forces a re-download even when a fresh cache exists.
#>
function Get-M365DSCGraphCsdlMetadata
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateSet('v1.0', 'beta')]
        [System.String]
        $APIVersion,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $Force,

        [Parameter()]
        [System.String]
        $Path
    )

    if (-not [System.String]::IsNullOrEmpty($Path))
    {
        return Read-M365DSCGraphCsdlFile -Path $Path
    }

    if ($APIVersion -eq 'v1.0')
    {
        $uri = 'https://raw.githubusercontent.com/microsoftgraph/msgraph-metadata/master/clean_v10_metadata/cleanMetadataWithDescriptionsAndAnnotationsv1.0.xml'
        $cacheFileName = 'csdl-v1.0.xml'
    }
    else
    {
        $uri = 'https://raw.githubusercontent.com/microsoftgraph/msgraph-metadata/master/clean_beta_metadata/cleanMetadataWithDescriptionsAndAnnotationsbeta.xml'
        $cacheFileName = 'csdl-beta.xml'
    }

    $cacheFolder = Join-Path -Path $env:LOCALAPPDATA -ChildPath 'M365DSC\ResourceGenerator'
    $cachePath = Join-Path -Path $cacheFolder -ChildPath $cacheFileName

    $cacheIsFresh = (Test-Path -Path $cachePath) -and
        ((Get-Date) - (Get-Item -Path $cachePath).LastWriteTime).TotalDays -lt 7

    if ($Force -or -not $cacheIsFresh)
    {
        try
        {
            Write-Verbose -Message "Downloading Graph $APIVersion metadata from $uri"
            if (-not (Test-Path -Path $cacheFolder))
            {
                $null = New-Item -Path $cacheFolder -ItemType Directory -Force
            }

            Invoke-WebRequest -Uri $uri -OutFile $cachePath -UseBasicParsing -ErrorAction Stop
        }
        catch
        {
            if (Test-Path -Path $cachePath)
            {
                Write-Warning -Message "Downloading the Graph metadata failed ($($_.Exception.Message)). Using the cached copy from $((Get-Item -Path $cachePath).LastWriteTime)."
            }
            else
            {
                throw ("Downloading the Graph $APIVersion metadata failed and no cached copy exists at '$cachePath'. " +
                    "Connect to the internet once to populate the cache. Error: $($_.Exception.Message)")
            }
        }
    }
    else
    {
        Write-Verbose -Message "Using cached Graph $APIVersion metadata from $cachePath"
    }

    return Read-M365DSCGraphCsdlFile -Path $cachePath
}

<#
.SYNOPSIS
    Parses a CSDL file into its schema nodes.
#>
function Read-M365DSCGraphCsdlFile
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Path
    )

    # The published file starts with a zero-width no-break space that breaks the XML parser.
    $zwnbsp = [System.Char] 0xFEFF
    $metadata = (Get-Content -Path $Path -Raw) -replace $zwnbsp, ''

    return ([Xml] $metadata).Edmx.DataServices.schema
}
