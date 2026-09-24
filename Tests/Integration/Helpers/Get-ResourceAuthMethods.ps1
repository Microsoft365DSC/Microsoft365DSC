<#
.SYNOPSIS
    Discovers which authentication methods a Microsoft365DSC resource supports
    by inspecting its .schema.mof file.

.DESCRIPTION
    Parses the MOF schema for a given DSC resource and returns the list of
    supported authentication methods (Credential, CertificateThumbprint,
    ApplicationSecret, ManagedIdentity, AccessTokens).

.PARAMETER ResourceName
    The friendly name of the resource (e.g., 'AADApplication').

.PARAMETER ModulePath
    Path to the Microsoft365DSC module root. Defaults to the repo's Modules folder.

.EXAMPLE
    Get-ResourceAuthMethods -ResourceName 'AADApplication'
    # Returns: @('Credential','CertificateThumbprint','ApplicationSecret','ManagedIdentity','AccessTokens')
#>
function Get-ResourceAuthMethods
{
    [CmdletBinding()]
    [OutputType([System.String[]])]
    param(
        [Parameter(Mandatory = $true)]
        [System.String]
        $ResourceName,

        [Parameter()]
        [System.String]
        $ModulePath
    )

    if ([string]::IsNullOrEmpty($ModulePath))
    {
        $ModulePath = Join-Path -Path $PSScriptRoot -ChildPath '..\..\..\..\Modules\Microsoft365DSC' -Resolve
    }

    # Find the MSFT_ resource folder
    $resourceFolder = Get-ChildItem -Path (Join-Path $ModulePath 'DSCResources') -Directory |
        Where-Object { $_.Name -like "MSFT_$ResourceName" -or $_.Name -eq $ResourceName } |
        Select-Object -First 1

    if ($null -eq $resourceFolder)
    {
        Write-Warning "Resource folder not found for '$ResourceName'"
        return @()
    }

    $schemaFile = Join-Path $resourceFolder.FullName "$($resourceFolder.Name).schema.mof"
    if (-not (Test-Path $schemaFile))
    {
        Write-Warning "Schema MOF not found: $schemaFile"
        return @()
    }

    $content = Get-Content -Path $schemaFile -Raw

    $authMethods = @()
    $authProperties = @(
        'Credential',
        'CertificateThumbprint',
        'ApplicationSecret',
        'ManagedIdentity',
        'AccessTokens',
        'ApplicationId',
        'TenantId',
        'CertificatePath',
        'CertificatePassword'
    )

    # Only report the "method-level" auth properties
    $methodProperties = @(
        'Credential',
        'CertificateThumbprint',
        'ApplicationSecret',
        'ManagedIdentity',
        'AccessTokens'
    )

    foreach ($prop in $methodProperties)
    {
        # Match property definitions within the main class (not embedded classes)
        if ($content -match "(?i)\b$prop\b")
        {
            $authMethods += $prop
        }
    }

    return $authMethods
}

<#
.SYNOPSIS
    Builds a complete resource test matrix with auth methods for all resources
    or a specific workload.

.PARAMETER Workload
    Filter by workload prefix (AAD, EXO, Intune, Teams, SPO, SC, O365, OD, PP, etc.)

.PARAMETER ModulePath
    Path to the Microsoft365DSC module root.
#>
function Get-ResourceTestMatrix
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable[]])]
    param(
        [Parameter()]
        [System.String]
        $Workload,

        [Parameter()]
        [System.String]
        $ModulePath
    )

    if ([string]::IsNullOrEmpty($ModulePath))
    {
        $ModulePath = Join-Path -Path $PSScriptRoot -ChildPath '..\..\..\..\Modules\Microsoft365DSC' -Resolve
    }

    $resourceFolders = Get-ChildItem -Path (Join-Path $ModulePath 'DSCResources') -Directory |
        Where-Object { $_.Name -like 'MSFT_*' }

    if (-not [string]::IsNullOrEmpty($Workload))
    {
        $resourceFolders = $resourceFolders | Where-Object {
            $_.Name -like "MSFT_$Workload*"
        }
    }

    $matrix = @()
    foreach ($folder in $resourceFolders)
    {
        $friendlyName = $folder.Name -replace '^MSFT_', ''
        $authMethods = Get-ResourceAuthMethods -ResourceName $friendlyName -ModulePath $ModulePath

        # Check for example files
        $examplesPath = Join-Path -Path $PSScriptRoot -ChildPath "..\..\..\..\Examples\Resources\$friendlyName"
        $hasCreate = Test-Path (Join-Path $examplesPath '1-Create.ps1') -ErrorAction SilentlyContinue
        $hasUpdate = Test-Path (Join-Path $examplesPath '2-Update.ps1') -ErrorAction SilentlyContinue
        $hasRemove = Test-Path (Join-Path $examplesPath '3-Remove.ps1') -ErrorAction SilentlyContinue

        $matrix += @{
            ResourceName  = $friendlyName
            ClassName     = $folder.Name
            AuthMethods   = $authMethods
            HasCreate     = $hasCreate
            HasUpdate     = $hasUpdate
            HasRemove     = $hasRemove
            ExamplesPath  = $examplesPath
        }
    }

    return $matrix
}

Export-ModuleMember -Function @(
    'Get-ResourceAuthMethods',
    'Get-ResourceTestMatrix'
)
