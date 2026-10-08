<#
.SYNOPSIS
    Generates the Microsoft365DSC Graph shim module.

.DESCRIPTION
    Reads cmdlet-mapping.json (URI/method data from Find-MgGraphCommand) and
    function-signatures.json to produce a single .psm1 file that re-exports
    every Graph SDK cmdlet Microsoft365DSC uses as a lightweight wrapper
    around Invoke-MgGraphRequest.

    The cmdlet list comes from the commands declared in every resource settings.json,
    plus the Graph cmdlets called from the helper modules and the resource base classes.

    The generated module depends ONLY on Microsoft.Graph.Authentication and
    eliminates the need to install/import the ~22 heavy Graph SDK sub-modules.

.PARAMETER CmdletMappingPath
    Path to the cmdlet-mapping.json produced by Build-CmdletMapping.ps1.

.PARAMETER FunctionSignaturesPath
    Path to the function-signatures.json produced by Extract-FunctionSignatures.ps1.

.PARAMETER OutputModulePath
    Path for the generated .psm1 file.

.PARAMETER OutputManifestPath
    Path for the generated .psd1 manifest file.

.EXAMPLE
    .\New-M365DSCGraphShimModule.ps1
#>
#Requires -PSEdition Core
param(
    [Parameter()]
    [System.String]
    $CmdletMappingPath = "$PSScriptRoot\cmdlet-mapping.json",

    [Parameter()]
    [System.String]
    $CmdletMappingOverridesPath = "$PSScriptRoot\cmdlet-mapping-overrides.json",

    [Parameter()]
    [System.String]
    $FunctionSignaturesPath = "$PSScriptRoot\function-signatures.json",

    [Parameter()]
    [System.String]
    $OutputModulePath = "$PSScriptRoot\..\Modules\Microsoft365DSC\Modules\M365DSCGraphShim.psm1",

    [Parameter()]
    [System.String]
    $OutputManifestPath = "$PSScriptRoot\..\Modules\Microsoft365DSC\Modules\M365DSCGraphShim.psd1",

    [Parameter()]
    [switch]
    $SkipCmdletMappingGeneration,

    [Parameter()]
    [switch]
    $SkipFunctionSignatureGeneration
)

$ErrorActionPreference = 'Stop'

Update-M365DSCDependencies -ValidateOnly -Development

$settingsFiles = Get-ChildItem -Path "$PSScriptRoot\..\Modules\Microsoft365DSC\DscResources" -Filter 'settings.json' -Recurse
$map = [ordered]@{}
foreach ($file in $settingsFiles)
{
    $json = Get-Content $file.FullName -Raw | ConvertFrom-Json -AsHashtable
    if (-not $json.ContainsKey('commands'))
    {
        continue
    }

    foreach ($command in $json.commands)
    {
        if ($command.module -notlike 'Microsoft.Graph*' -or $command.module -eq 'Microsoft.Graph.Authentication')
        {
            continue
        }
        foreach ($cmd in $command.cmdlets)
        {
            $map[$cmd] = $command.module
        }
    }
}

$hiddenScanPaths = @(
    "$PSScriptRoot\..\Modules\Microsoft365DSC\Modules",
    "$PSScriptRoot\..\Modules\Microsoft365DSC\DscResources\_Base"
)
$hiddenReferences = [ordered]@{}
foreach ($path in $hiddenScanPaths)
{
    foreach ($file in Get-ChildItem -Path $path -Filter '*.psm1' -Recurse -File)
    {
        if ($file.Name -eq (Split-Path -Path $OutputModulePath -Leaf))
        {
            continue
        }

        $ast = [System.Management.Automation.Language.Parser]::ParseFile($file.FullName, [ref] $null, [ref] $null)
        $commandAsts = $ast.FindAll(
            {
                param($Item)
                return ($Item -is [System.Management.Automation.Language.CommandAst])
            }, $true)

        foreach ($commandAst in $commandAsts)
        {
            $name = $commandAst.GetCommandName()
            if ([System.String]::IsNullOrEmpty($name) -or $name -notmatch '^[A-Za-z]+-Mg[A-Za-z0-9]+$')
            {
                continue
            }
            if ($map.Contains($name) -or $hiddenReferences.Contains($name))
            {
                continue
            }

            $hiddenReferences[$name] = $file.Name
        }
    }
}

foreach ($reference in $hiddenReferences.GetEnumerator())
{
    $resolved = @(Get-Command -Name $reference.Key -ErrorAction SilentlyContinue |
            Where-Object -FilterScript { $_.ModuleName -like 'Microsoft.Graph*' })
    $fromSdk = @($resolved | Where-Object -FilterScript { $_.ModuleName -ne 'Microsoft.Graph.Authentication' })
    if ($fromSdk.Count -eq 0)
    {
        if ($resolved.Count -eq 0)
        {
            Write-Warning -Message "$($reference.Key) is called in $($reference.Value) but resolves to no Graph module; it is left out of the shim."
        }
        continue
    }

    $map[$reference.Key] = ($fromSdk | Sort-Object -Property Version -Descending | Select-Object -First 1).ModuleName
    Write-Host "Adding $($reference.Key) from $($reference.Value) ($($map[$reference.Key]))."
}

$map | ConvertTo-Json -Depth 10 | Out-File -FilePath "$PSScriptRoot\cmdlet-source-modules.json" -Encoding UTF8

if (-not $SkipCmdletMappingGeneration) {
    Write-Host "Build Cmdlet Mapping..."
    & "$PSScriptRoot\Build-CmdletMapping.ps1" -CmdletSourceModulesPath "$PSScriptRoot\cmdlet-source-modules.json" -OutputPath $CmdletMappingPath
}

if (-not $SkipFunctionSignatureGeneration) {
    Write-Host "Extract Function Signatures..."
    & "$PSScriptRoot\Extract-FunctionSignatures.ps1" -CmdletSourceModulesPath "$PSScriptRoot\cmdlet-source-modules.json" -OutputPath $FunctionSignaturesPath
}

#region Load data sources
Write-Host 'Loading cmdlet mapping...'
$cmdletMapping = Get-Content $CmdletMappingPath -Raw | ConvertFrom-Json

if (Test-Path -Path $CmdletMappingOverridesPath)
{
    Write-Host 'Applying cmdlet mapping overrides...'
    $mappingOverrides = Get-Content $CmdletMappingOverridesPath -Raw | ConvertFrom-Json
    foreach ($override in $mappingOverrides.PSObject.Properties)
    {
        $entry = $cmdletMapping.PSObject.Properties[$override.Name]
        if ($null -eq $entry)
        {
            Write-Warning -Message "Mapping override for '$($override.Name)' does not match any cmdlet in the mapping."
            continue
        }

        $entry.Value.Variants = $override.Value.Variants
        Write-Host "  $($override.Name): $($override.Value.Reason)"
    }
}

Write-Host 'Loading function signatures...'
$functionSignatures = Get-Content $FunctionSignaturesPath -Raw | ConvertFrom-Json

$cmdletNames = @($cmdletMapping.PSObject.Properties.Name | Sort-Object)
Write-Host "  $($cmdletNames.Count) cmdlets in mapping"

$uncovered = @(@($map.Keys) | Where-Object { $_ -notin $cmdletNames } | Sort-Object)
if ($uncovered.Count -gt 0)
{
    Write-Warning -Message "$($uncovered.Count) of $(@($map.Keys).Count) cmdlets the resources declare are absent from the mapping and get no wrapper. The API surface check reports each as SHIM-MISSING."
    $uncovered | ForEach-Object { Write-Warning -Message "  $_ ($($map[$_]))" }
}
#endregion

#region Classify parameters
# Parameters that are part of the SDK infrastructure and should NOT be sent in the request body.
$infrastructureParams = @(
    'Headers', 'HttpPipelinePrepend', 'HttpPipelineAppend',
    'Proxy', 'ProxyCredential', 'ProxyUseDefaultCredentials',
    'Break', 'ResponseHeadersVariable', 'InputObject'
)

# Parameters that map to OData query options (used in GET requests).
$odataParams = @(
    'Filter', 'Property', 'ExpandProperty', 'Top', 'Skip',
    'Search', 'Sort', 'CountVariable', 'ConsistencyLevel',
    'All', 'PageSize', 'NoPageSize'
)

# Parameters that are used for body construction in POST/PATCH/PUT
$bodyMetaParams = @(
    'BodyParameter', 'AdditionalProperties'
)
#endregion

#region Helper: convert PascalCase identity param name to URI placeholder
function ConvertTo-UriPlaceholder {
    param([string]$ParamName)
    # Strip trailing 'Id' or '_Id'
    $base = $ParamName -replace 'Id$', '' -replace '_Id$', ''
    # Insert hyphens before uppercase letters (PascalCase → kebab-case)
    $kebab = ($base -creplace '([a-z])([A-Z])', '$1-$2').ToLower()
    return "{$kebab-id}"
}
#endregion

#region Helper: determine identity parameters and their URI placeholders for a cmdlet
function Get-IdentityParamMapping {
    param(
        [string]$CmdletName,
        [array]$Variants,
        [array]$ParamList
    )

    # Find URI variant with placeholders (single-item endpoint)
    $singleItemVariant = $Variants | Where-Object { $_.URI -match '\{[^}]+\}' } | Select-Object -First 1
    if (-not $singleItemVariant) { return @{} }

    $uri = $singleItemVariant.URI
    # Extract all placeholders like {application-id}
    $placeholders = [regex]::Matches($uri, '\{([^}]+)\}') | ForEach-Object { $_.Groups[1].Value }

    $paramMapping = [ordered]@{}
    foreach ($placeholder in $placeholders) {
        # Try to find matching parameter: convert placeholder to PascalCase + 'Id'
        # {application-id} → ApplicationId
        # {conditionalAccessPolicy-id} → ConditionalAccessPolicyId
        $pascalCase = ($placeholder -replace '-id$', '' -split '-' | ForEach-Object {
            $_.Substring(0, 1).ToUpper() + $_.Substring(1)
        }) -join ''
        $paramName = $pascalCase + 'Id'

        # Check if this parameter exists in the stub signature
        $matchingParam = $ParamList | Where-Object { $_.Name -eq $paramName }
        if ($matchingParam) {
            $paramMapping[$paramName] = $placeholder
        }
        else {
            # Try common alternatives: Id, DirectoryObjectId
            foreach ($alt in @('Id', $CmdletName -replace '^(Get|New|Update|Remove|Set|Invoke)-Mg(Beta)?', '' -replace '([A-Z])', '$1' | ForEach-Object { $_ + 'Id' })) {
                $altMatch = $ParamList | Where-Object { $_.Name -eq $alt }
                if ($altMatch) {
                    $paramMapping[$alt] = $placeholder
                    break
                }
            }
        }
    }
    return $paramMapping
}
#endregion

#region Build the module content
$sb = [System.Text.StringBuilder]::new(512KB)

# Module header
[void]$sb.AppendLine(@'
#region Module Header
# =============================================================================
# AUTO-GENERATED FILE — Do not edit manually.
# Generated by: New-M365DSCGraphShimModule.ps1
# Purpose:      Drop-in replacement for Microsoft Graph SDK typed cmdlets.
#               Each function wraps Invoke-MgGraphRequest from
#               Microsoft.Graph.Authentication, eliminating the need for
#               the heavy auto-generated SDK sub-modules.
# =============================================================================
#endregion

$Script:IsPowerShell76OrGreater = $PSVersionTable.PSVersion -ge [Version]'7.6'

#region Shared Helpers

<#
.SYNOPSIS
    Centralized wrapper around Invoke-MgGraphRequest with retry logic.
#>
function Invoke-M365DSCGraphShimRequest
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [System.String]
        $Method,

        [Parameter(Mandatory = $true)]
        [System.String]
        $Uri,

        [Parameter()]
        [System.Object]
        $Body,

        [Parameter()]
        [System.Collections.IDictionary]
        $Headers,

        [Parameter()]
        [System.String]
        $OutputType,

        [Parameter()]
        [Switch]
        $PassThru
    )

    $invokeParams = @{
        Method = $Method
        Uri    = $Uri
    }

    if ($PSBoundParameters.ContainsKey('Body') -and $null -ne $Body)
    {
        if ($Body -isnot [string])
        {
            $Body = $Body | ConvertTo-Json -Depth 99 -Compress
        }
        $invokeParams['Body'] = $Body
        $invokeParams['ContentType'] = 'application/json'
    }
    if ($PSBoundParameters.ContainsKey('Headers') -and $Headers.Keys.Count -gt 0)
    {
        $invokeParams['Headers'] = $Headers
    }
    if ($PSBoundParameters.ContainsKey('OutputType') -and -not [System.String]::IsNullOrEmpty($OutputType))
    {
        $invokeParams['OutputType'] = $OutputType
    }
    if ($ErrorActionPreference -eq 'SilentlyContinue')
    {
        $invokeParams['SkipHttpErrorCheck'] = $true
    }

    $maxRetries = 5
    for ($attempt = 1; $attempt -le $maxRetries; $attempt++)
    {
        try
        {
            $returnValue = Invoke-MgGraphRequest @invokeParams
            if ($null -ne $returnValue -and $returnValue.ContainsKey('value') -and -not $PassThru)
            {
                $returnValue = $returnValue.value
            }
            elseif ($null -ne $returnValue -and $returnValue.ContainsKey('error'))
            {
                $returnValue = $null
            }
            return $returnValue
        }
        catch
        {
            $statusCode = $null
            if ($_.Exception.Response)
            {
                $statusCode = [int]$_.Exception.Response.StatusCode
            }
            elseif ($_.Exception.Message -match '(\d{3})')
            {
                $statusCode = [int]$Matches[1]
            }

            if ($statusCode -in @(429, 503, 504) -and $attempt -lt $maxRetries)
            {
                $retryAfter = 2
                if ($_.Exception.Response.Headers -and $_.Exception.Response.Headers['Retry-After'])
                {
                    $retryAfter = [int]$_.Exception.Response.Headers['Retry-After']
                }
                $delay = [Math]::Max($retryAfter, [Math]::Pow(2, $attempt))
                Write-Verbose "Graph API returned $statusCode. Retrying in $delay seconds (attempt $attempt/$maxRetries)..."
                Start-Sleep -Seconds $delay
            }
            elseif ($statusCode -eq 400 -and $_.ErrorDetails.Message -match 'Header ''x-msft-approval-justification'' is required to request approval')
            {
                throw [System.InvalidOperationException] 'Multi Admin Approval (MAA) is enabled for this resource type. Microsoft365DSC does not support running with MAA enabled. Please exclude the app registration from MAA or disable MAA for this resource type.'
            }
            else
            {
                throw
            }
        }
    }
}

function Invoke-M365DSCGraphShimRequestV76
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [System.String]
        $Method,

        [Parameter(Mandatory = $true)]
        [System.String]
        $Uri,

        [Parameter()]
        [System.Object]
        $Body,

        [Parameter()]
        [System.Collections.IDictionary]
        $Headers,

        [Parameter()]
        [System.String]
        $OutputType,

        [Parameter()]
        [System.Int32]
        $Skip = 0,

        [Parameter()]
        [System.Int32]
        $Top = 0,

        [Parameter()]
        [System.Int32]
        $PageSize = 0,

        [Parameter()]
        [switch]
        $NoPageSize,

        [Parameter()]
        [switch]
        $All,

        [Parameter()]
        [Switch]
        $PassThru
    )

    if ($PSBoundParameters.ContainsKey('OutputType') -and -not [System.String]::IsNullOrEmpty($OutputType))
    {
        throw [System.NotSupportedException] 'The OutputType parameter is not supported in PowerShell 7.6 or later.'
    }

    $invokeParams = @{
        All        = $All
        ApiVersion = if ($Uri -match '^/beta') { 'beta' } else { 'v1.0' }
        Method     = $Method
        Uri        = [regex]::Replace($Uri, '^/beta|^/v1.0', '')
        ErrorAction = 'Stop'
    }

    if ($PSBoundParameters.ContainsKey('Skip') -and $Skip -gt 0)
    {
        $invokeParams['Skip'] = $Skip
    }

    if ($PSBoundParameters.ContainsKey('Top') -and $Top -gt 0)
    {
        $invokeParams['Top'] = $Top
    }

    if ($PSBoundParameters.ContainsKey('PageSize') -and $PageSize -gt 0)
    {
        $invokeParams['PageSize'] = $PageSize
    }

    if ($NoPageSize.IsPresent)
    {
        $invokeParams.Remove('PageSize') | Out-Null
        $invokeParams['NoPageSize'] = $true
    }

    if ($PSBoundParameters.ContainsKey('Body') -and $null -ne $Body)
    {
        if ($Body -isnot [string])
        {
            $Body = $Body | ConvertTo-Json -Depth 99 -Compress
        }
        $invokeParams['Body'] = $Body
    }
    if ($PSBoundParameters.ContainsKey('Headers') -and $Headers.Keys.Count -gt 0)
    {
        $invokeParams['Headers'] = $Headers
    }
    if ($ErrorActionPreference -eq 'SilentlyContinue')
    {
        $invokeParams['SkipForbidden'] = $true
        $invokeParams['SkipNotFound'] = $true
        $invokeParams['ErrorAction'] = 'SilentlyContinue'
    }

    $pageSizeLimitPattern = "The limit of '(\d+)' for Top query has been exceeded"
    try
    {
        $response = Invoke-MgxRequest @invokeParams -ErrorVariable mgxErrors
        if ($All -and $mgxErrors.Count -gt 0 -and "$($mgxErrors[0])" -match $pageSizeLimitPattern)
        {
            Write-Warning -Message "The limit for Top query has been exceeded. Retrying with PageSize set to $($Matches[1])."
            $invokeParams.Remove('NoPageSize') | Out-Null
            $invokeParams.Remove('PageSize') | Out-Null
            if ([int]$Matches[1] -gt 0)
            {
                $invokeParams['PageSize'] = [int]$Matches[1]
            }
            else
            {
                $invokeParams['NoPageSize'] = $true
            }
            $response = Invoke-MgxRequest @invokeParams
        }
        return $response
    }
    catch
    {
        if ($All -and $_.Exception.Message -match $pageSizeLimitPattern)
        {
            Write-Warning -Message "The limit for Top query has been exceeded. Retrying with PageSize set to $($Matches[1])."
            $invokeParams.Remove('NoPageSize') | Out-Null
            $invokeParams.Remove('PageSize') | Out-Null
            if ([int]$Matches[1] -gt 0)
            {
                $invokeParams['PageSize'] = [int]$Matches[1]
            }
            else
            {
                $invokeParams['NoPageSize'] = $true
            }
            return Invoke-MgxRequest @invokeParams
        }

        $statusCode = $null
        if ($_.Exception)
        {
            $statusCode = [int]$_.Exception.StatusCode
        }
        elseif ($_.Exception.Message -match '(\d{3})')
        {
            $statusCode = [int]$Matches[1]
        }

        if ($statusCode -eq 400 -and $_.Exception.Message -match 'Header ''x-msft-approval-justification'' is required to request approval')
        {
            throw [System.InvalidOperationException] 'Multi Admin Approval (MAA) is enabled for this resource type. Microsoft365DSC does not support running with MAA enabled. Please exclude the app registration from MAA or disable MAA for this resource type.'
        }
        else
        {
            throw
        }
    }
}

<#
.SYNOPSIS
    Follows @odata.nextLink to retrieve all pages of a Graph API collection.
#>
function Get-M365DSCGraphShimAllPages
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [System.String]
        $Uri,

        [Parameter()]
        [System.Collections.IDictionary]
        $Headers,

        [Parameter()]
        [System.Int32]
        $Skip = 0,

        [Parameter()]
        [System.Int32]
        $PageSize = 0,

        [Parameter()]
        [switch]
        $NoPageSize
    )

    $allResults = [System.Collections.Generic.List[System.Object]]::new()
    $currentUri = $Uri

    if ($Skip -gt 0 -and $currentUri -notmatch '[\?&]\$skip=')
    {
        $separator = if ($currentUri.Contains('?')) { '&' } else { '?' }
        $currentUri = "$currentUri$separator`$skip=$Skip"
    }

    if ($PageSize -gt 0 -and $currentUri -notmatch '[\?&]\$top=')
    {
        $separator = if ($currentUri.Contains('?')) { '&' } else { '?' }
        $currentUri = "$currentUri$separator`$top=$PageSize"
    }

    $requestParams = @{
        Method = 'GET'
        Uri    = $currentUri
    }
    if ($PSBoundParameters.ContainsKey('Headers') -and $Headers.Keys.Count -gt 0)
    {
        $requestParams['Headers'] = $Headers
    }

    do
    {
        $response = Invoke-M365DSCGraphShimRequest @requestParams -PassThru
        if ($null -eq $response)
        {
            break
        }
        elseif ($response.ContainsKey('value'))
        {
            $allResults.AddRange([array]$response.value)
        }
        elseif ($response -is [System.Collections.IEnumerable] -and $response -isnot [string])
        {
            $allResults.AddRange([array]$response)
        }
        else
        {
            # Single object response, not a collection
            $allResults.Add($response)
        }

        $nextLink = $response.'@odata.nextLink'
        if (-not [System.String]::IsNullOrEmpty($nextLink))
        {
            $requestParams['Uri'] = $nextLink
        }
    }
    while (-not [System.String]::IsNullOrEmpty($nextLink))

    return $allResults
}

function Get-M365DSCGraphShimAllPagesV76
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [System.String]
        $Uri,

        [Parameter()]
        [System.Collections.IDictionary]
        $Headers,

        [Parameter()]
        [System.Int32]
        $Skip = 0,

        [Parameter()]
        [System.Int32]
        $PageSize = 0,

        [Parameter()]
        [switch]
        $NoPageSize
    )

    $allResults = [System.Collections.Generic.List[System.Object]]::new()
    $currentUri = $Uri

    $requestParams = @{
        All    = $true
        Method = 'GET'
        Uri    = $currentUri
    }

    if ($NoPageSize.IsPresent)
    {
        $requestParams['NoPageSize'] = $true
    }

    if ($PSBoundParameters.ContainsKey('Headers') -and $Headers.Keys.Count -gt 0)
    {
        $requestParams['Headers'] = $Headers
    }

    if ($PSBoundParameters.ContainsKey('Skip'))
    {
        $requestParams['Skip'] = $Skip
    }

    if ($PSBoundParameters.ContainsKey('PageSize'))
    {
        $requestParams['PageSize'] = $PageSize
    }

    $response = Invoke-M365DSCGraphShimRequestV76 @requestParams -PassThru
    if ($response -is [System.Collections.IEnumerable] -and $response -isnot [string])
    {
        $allResults.AddRange([array]$response)
    }
    elseif ($null -ne $response)
    {
        # Single object response, not a collection
        $allResults.Add($response)
    }

    return $allResults
}

<#
.SYNOPSIS
    Builds a Graph API URI from a template, identity parameters, and OData query options.
#>
function ConvertTo-M365DSCGraphShimUri
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [System.String]
        $UriTemplate,

        [Parameter()]
        [System.String]
        $Filter,

        [Parameter()]
        [System.String[]]
        $Property,

        [Parameter()]
        [System.String[]]
        $ExpandProperty,

        [Parameter()]
        [System.Int32]
        $Top = 0,

        [Parameter()]
        [System.Int32]
        $Skip = 0,

        [Parameter()]
        [System.String]
        $Search,

        [Parameter()]
        [System.String[]]
        $Sort,

        [Parameter()]
        [System.String]
        $CountVariable
    )

    $uri = $UriTemplate
    $queryParts = [System.Collections.Generic.List[System.String]]::new()
    if (-not [System.String]::IsNullOrEmpty($Filter))
    {
        $queryParts.Add("`$filter=$([System.Web.HttpUtility]::UrlEncode($Filter))")
    }
    if ($Property -and $Property.Count -gt 0)
    {
        $queryParts.Add("`$select=$($Property -join ',')")
    }
    if ($ExpandProperty -and $ExpandProperty.Count -gt 0)
    {
        $queryParts.Add("`$expand=$($ExpandProperty -join ',')")
    }
    if ($Top -gt 0)
    {
        $queryParts.Add("`$top=$Top")
    }
    if ($Skip -gt 0)
    {
        $queryParts.Add("`$skip=$Skip")
    }
    if (-not [System.String]::IsNullOrEmpty($Search))
    {
        $queryParts.Add("`$search=$([System.Web.HttpUtility]::UrlEncode($Search))")
    }
    if ($Sort -and $Sort.Count -gt 0)
    {
        $queryParts.Add("`$orderby=$($Sort -join ',')")
    }
    if (-not [System.String]::IsNullOrEmpty($CountVariable))
    {
        $queryParts.Add('$count=true')
    }

    if ($queryParts.Count -gt 0)
    {
        $uri = "$uri`?$($queryParts -join '&')"
    }
    return $uri
}

<#
.SYNOPSIS
    Converts a PascalCase property name to the camelCase name Graph expects. A leading run of
    capitals is lowered up to the last one that starts a word. Keys that do not start with a
    capital, such as @odata.type, are returned unchanged.
#>
function ConvertTo-M365DSCGraphShimPropertyName
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param(
        [Parameter(Mandatory = $true)]
        [System.String]
        $Name
    )

    if ($Name -cnotmatch '^[A-Z]')
    {
        return $Name
    }
    if ($Name -cmatch '^[A-Z0-9]+$')
    {
        return $Name.ToLower()
    }
    if ($Name -cmatch '^([A-Z]+)(?=[A-Z][a-z])')
    {
        return $Matches[1].ToLower() + $Name.Substring($Matches[1].Length)
    }
    return $Name.Substring(0, 1).ToLower() + $Name.Substring(1)
}

<#
.SYNOPSIS
    Assembles a request body from bound parameters, merging AdditionalProperties.
#>
function ConvertTo-M365DSCGraphShimBody
{
    [CmdletBinding()]
    param(
        [Parameter()]
        [System.Object]
        $BodyParameter,

        [Parameter()]
        [System.Collections.Hashtable]
        $AdditionalProperties,

        [Parameter()]
        [System.Collections.Hashtable]
        $NamedParams = @{},

        [Parameter()]
        [System.String[]]
        $ExcludeParams = @()
    )

    # If BodyParameter is provided, use it directly
    if ($null -ne $BodyParameter)
    {
        $body = if ($BodyParameter -is [System.Collections.IDictionary])
        {
            ([System.Collections.Hashtable]$BodyParameter).Clone()
        }
        else
        {
            # Convert PSObject to hashtable
            $ht = @{}
            foreach ($prop in $BodyParameter.PSObject.Properties)
            {
                $ht[$prop.Name] = $prop.Value
            }
            $ht
        }
        $camelBody = @{}
        foreach ($entry in $body.GetEnumerator())
        {
            $camelBody[(ConvertTo-M365DSCGraphShimPropertyName -Name $entry.Key)] = $entry.Value
        }
        $body = $camelBody
    }
    else
    {
        # Build body from named parameters
        $body = @{}
        foreach ($entry in $NamedParams.GetEnumerator())
        {
            if ($entry.Key -notin $ExcludeParams -and $null -ne $entry.Value)
            {
                $value = $entry.Value
                if ($value -is [System.Management.Automation.SwitchParameter])
                {
                    $value = $value.IsPresent
                }
                $body[(ConvertTo-M365DSCGraphShimPropertyName -Name $entry.Key)] = $value
            }
        }
    }

    # Merge AdditionalProperties
    if ($null -ne $AdditionalProperties)
    {
        foreach ($entry in $AdditionalProperties.GetEnumerator())
        {
            $body[$entry.Key] = $entry.Value
        }
    }

    return $body
}

# Base set of parameter names that are never sent in a request body.
# Individual functions append their own identity-parameter names before calling helpers.
$script:GraphShimExcludeFromBody = @(
    'Headers', 'HttpPipelinePrepend', 'HttpPipelineAppend',
    'Proxy', 'ProxyCredential', 'ProxyUseDefaultCredentials',
    'Break', 'ResponseHeadersVariable', 'InputObject',
    'Filter', 'Property', 'ExpandProperty', 'Top', 'Skip',
    'Search', 'Sort', 'CountVariable', 'ConsistencyLevel',
    'All', 'PageSize', 'NoPageSize', 'BodyParameter', 'AdditionalProperties',
    'Confirm', 'WhatIf', 'ErrorAction'
)

<#
.SYNOPSIS
    Centralized GET dispatcher that handles single-item vs. collection retrieval,
    OData query options, and paging — replacing the identical code block that was
    duplicated in every Get-* wrapper function.
#>
function Invoke-M365DSCGraphShimGetResource
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [System.Collections.IDictionary]
        $BoundParameters,

        [Parameter(Mandatory = $true)]
        [System.String]
        $CollectionUri,

        [Parameter()]
        [System.String]
        $SingleItemUri
    )

    # Build headers
    $requestHeaders = @{}
    if ($BoundParameters.ContainsKey('Headers')) { $requestHeaders = $BoundParameters['Headers'] }
    if ($BoundParameters.ContainsKey('ConsistencyLevel')) { $requestHeaders['ConsistencyLevel'] = $BoundParameters['ConsistencyLevel'] }

    # Single-item retrieval when a resolved SingleItemUri is supplied
    if (-not [System.String]::IsNullOrEmpty($SingleItemUri))
    {
        $uri = $SingleItemUri.Replace("#", "%23") # Encode '#' in IDs to prevent confusion with URI fragments
        $queryParts = @()
        if ($BoundParameters['Property']) { $queryParts += "`$select=$($BoundParameters['Property'] -join ',')" }
        if ($BoundParameters['ExpandProperty']) { $queryParts += "`$expand=$($BoundParameters['ExpandProperty'] -join ',')" }
        if ($queryParts.Count -gt 0) { $uri = "$uri`?$($queryParts -join '&')" }

        if ($Script:IsPowerShell76OrGreater)
        {
            return Invoke-M365DSCGraphShimRequestV76 -Method GET -Uri $uri -Headers $requestHeaders -ErrorAction $ErrorActionPreference
        }
        return Invoke-M365DSCGraphShimRequest -Method GET -Uri $uri -Headers $requestHeaders -ErrorAction $ErrorActionPreference
    }

    # Collection retrieval
    $uriParams = @{ UriTemplate = $CollectionUri }
    if ($BoundParameters['Filter'])         { $uriParams['Filter'] = $BoundParameters['Filter'] }
    if ($BoundParameters['Property'])       { $uriParams['Property'] = $BoundParameters['Property'] }
    if ($BoundParameters['ExpandProperty']) { $uriParams['ExpandProperty'] = $BoundParameters['ExpandProperty'] }
    if ($BoundParameters['Search'])         { $uriParams['Search'] = $BoundParameters['Search'] }
    if ($BoundParameters['Sort'])           { $uriParams['Sort'] = $BoundParameters['Sort'] }
    if ($BoundParameters['CountVariable'])  { $uriParams['CountVariable'] = $BoundParameters['CountVariable'] }

    $paramSplat = @{}
    if ($BoundParameters['Top'] -gt 0)      { $paramSplat['Top'] = $BoundParameters['Top'] }
    if ($BoundParameters['Skip'] -gt 0)     { $paramSplat['Skip'] = $BoundParameters['Skip'] }
    if ($BoundParameters['PageSize'] -gt 0) { $paramSplat['PageSize'] = $BoundParameters['PageSize'] }
    if ($BoundParameters['NoPageSize'])     { $paramSplat['NoPageSize'] = $true }

    $retrieveAllPages = ($BoundParameters.ContainsKey('All') -and $BoundParameters['All']) -or
        (-not [System.String]::IsNullOrEmpty($BoundParameters['Filter']) -and -not $paramSplat.ContainsKey('Top'))
    if ($retrieveAllPages)
    {
        # All reads the whole collection. In this case, the Top parameter caps a single page
        # instead of the full collection. Otherwise, it requests 999 objects at a time.
        if (-not $paramSplat.ContainsKey('PageSize') -and $paramSplat.ContainsKey('Top'))
        {
            $paramSplat['PageSize'] = $paramSplat['Top']
        }
        $paramSplat.Remove('Top')
        if ($paramSplat.ContainsKey('NoPageSize'))
        {
            $paramSplat.Remove('PageSize')
        }
    }
    elseif (-not $Script:IsPowerShell76OrGreater)
    {
        # Invoke-MgxRequest applies Top and Skip itself and rejects a URI that already carries them.
        # Without it, a single request can only limit the collection through the query.
        if ($paramSplat.ContainsKey('Top'))  { $uriParams['Top'] = $paramSplat['Top'] }
        if ($paramSplat.ContainsKey('Skip')) { $uriParams['Skip'] = $paramSplat['Skip'] }
    }

    $uri = ConvertTo-M365DSCGraphShimUri @uriParams

    if ($retrieveAllPages)
    {
        if ($Script:IsPowerShell76OrGreater)
        {
            return Get-M365DSCGraphShimAllPagesV76 -Uri $uri -Headers $requestHeaders @paramSplat -ErrorAction $ErrorActionPreference
        }
        return Get-M365DSCGraphShimAllPages -Uri $uri -Headers $requestHeaders @paramSplat -ErrorAction $ErrorActionPreference
    }

    if ($Script:IsPowerShell76OrGreater)
    {
        $response = Invoke-M365DSCGraphShimRequestV76 -Method GET -Uri $uri -Headers $requestHeaders @paramSplat -ErrorAction $ErrorActionPreference
    }
    else
    {
        $response = Invoke-M365DSCGraphShimRequest -Method GET -Uri $uri -Headers $requestHeaders -ErrorAction $ErrorActionPreference
    }


    # Get-MgBetaDeviceManagementGroupPolicyConfigurationDefinitionValuePresentationValue might return an object with the 'value' property,
    # but we also need the values inside 'presentation'. Return the whole object inside $response instead of $response.value
    if ($null -ne $response -and $response -is [hashtable] -and $response.ContainsKey('value') -and -not $response.ContainsKey('presentation'))
    {
        return $response.value
    }
    return $response
}

<#
.SYNOPSIS
    Centralized POST / PATCH / PUT dispatcher that builds the request body
    from BoundParameters, BodyParameter, and AdditionalProperties, then
    invokes the Graph API — replacing the identical code block that was
    duplicated in every New-*, Update-*, and Set-* wrapper function.
#>
function Invoke-M365DSCGraphShimWriteResource
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [System.Collections.IDictionary]
        $BoundParameters,

        [Parameter(Mandatory = $true)]
        [System.String]
        $Uri,

        [Parameter(Mandatory = $true)]
        [ValidateSet('POST', 'PATCH', 'PUT')]
        [System.String]
        $Method,

        [Parameter()]
        [System.String[]]
        $ExtraExcludeParams = @()
    )

    $requestHeaders = @{}
    if ($BoundParameters.ContainsKey('Headers')) { $requestHeaders = $BoundParameters['Headers'] }

    $excludeFromBody = $script:GraphShimExcludeFromBody + $ExtraExcludeParams
    $namedParams = @{}
    foreach ($key in $BoundParameters.Keys)
    {
        if ($key -notin $excludeFromBody)
        {
            $namedParams[$key] = $BoundParameters[$key]
        }
    }

    $body = ConvertTo-M365DSCGraphShimBody `
        -BodyParameter $BoundParameters['BodyParameter'] `
        -AdditionalProperties $BoundParameters['AdditionalProperties'] `
        -NamedParams $namedParams `
        -ExcludeParams $excludeFromBody

    if ($Script:IsPowerShell76OrGreater)
    {
        return Invoke-M365DSCGraphShimRequestV76 -Method $Method -Uri $Uri -Body $body -Headers $requestHeaders -ErrorAction $ErrorActionPreference
    }
    else
    {
        return Invoke-M365DSCGraphShimRequest -Method $Method -Uri $Uri -Body $body -Headers $requestHeaders -ErrorAction $ErrorActionPreference
    }
}

function Invoke-M365DSCGraphShimDeleteResource
{
    <#
    .SYNOPSIS
        Centralized DELETE dispatcher — replacing the identical 3-line code block
        that was duplicated in every Remove-* wrapper function.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [System.Collections.IDictionary]
        $BoundParameters,

        [Parameter(Mandatory = $true)]
        [System.String]
        $Uri
    )

    $requestHeaders = @{}
    if ($BoundParameters.ContainsKey('Headers')) { $requestHeaders = $BoundParameters['Headers'] }
    if ($Script:IsPowerShell76OrGreater)
    {
        Invoke-M365DSCGraphShimRequestV76 -Method 'DELETE' -Uri $Uri -Headers $requestHeaders -ErrorAction $ErrorActionPreference
    }
    else
    {
        Invoke-M365DSCGraphShimRequest -Method 'DELETE' -Uri $Uri -Headers $requestHeaders -ErrorAction $ErrorActionPreference
    }
}

#endregion Shared Helpers
'@)

Write-Host 'Generating wrapper functions...'
$generated = 0
$skipped = 0
$exportedFunctions = [System.Collections.Generic.List[string]]::new()

foreach ($cmdletName in $cmdletNames) {
    $mapEntry = $cmdletMapping.PSObject.Properties[$cmdletName].Value
    $functionProp = $functionSignatures.PSObject.Properties[$cmdletName]
    $functionEntry = if ($functionProp) { @($functionProp.Value) } else { @() }

    $variants = @($mapEntry.Variants)
    $apiVersion = $mapEntry.ApiVersion
    $method = $variants[0].Method

    # Find the appropriate URI templates
    $allListUris = $variants | Where-Object { $_.URI.Split('/')[-1] -notmatch '\{[^}]+\}' } | Select-Object -ExpandProperty URI
    if ($allListUris.Count -gt 1) {
        $placeHolders = @()
        foreach ($uri in $allListUris) {
            $phs = [regex]::Matches($uri, '\{([^}]+)\}') | ForEach-Object { $_.Groups[1].Value }
            $placeHolders += $phs
        }
        $cleanedAllListUris = $allListUris | ForEach-Object {
            $cleanUri = $_
            foreach ($ph in $placeHolders) {
                $cleanUri = ($cleanUri -replace [regex]::Escape("{$ph}"), '') -replace '//+', '/'
            }
            $cleanUri
        }
        $singleUri = $variants | Where-Object {
            $uri = $_.URI
            foreach ($cleanUri in $cleanedAllListUris) {
                if ($uri -eq $cleanUri) {
                    return $false
                }
            }
            return $true
        } | Select-Object -First 1 | Select-Object -ExpandProperty URI
        $listUri = $allListUris | Where-Object { $_ -notlike "*{*}*" } | Select-Object -First 1
    } else {
        $listUri = ($allListUris | Select-Object -First 1)?.Replace('$','`$') # The Uri that does not end with a placeholder is likely the list endpoint
        $singleUri = ($variants | Where-Object { $_.URI.Split('/')[-1] -match '\{[^}]+\}' } | Select-Object -First 1)?.URI?.Replace('$','`$') # The Uri that ends with a placeholder is likely the single-item endpoint
    }

    $primaryUri = if ($singleUri) { $singleUri } else { $listUri }
    if (-not $primaryUri) { $primaryUri = $variants[0].URI.Replace('$', '`$') }

    # Determine identity parameter mappings
     $identityMapping = [ordered]@{}
    $placeholders = @()
    if ($singleUri) {
        $placeholders = [regex]::Matches($singleUri, '\{([^}]+)\}') | ForEach-Object { $_.Groups[1].Value }
    } elseif ($listUri) {
        $placeholders = [regex]::Matches($listUri, '\{([^}]+)\}') | ForEach-Object { $_.Groups[1].Value }
    } else {
        # No URI with placeholders, try to find any placeholders in the primary URI
        $placeholders = [regex]::Matches($primaryUri, '\{([^}]+)\}') | ForEach-Object { $_.Groups[1].Value }
    }

    foreach ($ph in $placeholders) {
        # Convert {placeholder-id} to PascalCaseId param name
        $parts = $ph.Split('-')
        $pascalParts = $parts | ForEach-Object { $_.Substring(0, 1).ToUpper() + $_.Substring(1) }
        $paramName = $pascalParts -join ''

        # Verify it exists in function params
        $match = $functionEntry | Where-Object { $_.Name -eq $paramName }
        if ($match) {
            $identityMapping[$paramName] = $ph
        }
        else {
            # Try just 'Id'
            $idMatch = $functionEntry | Where-Object { $_.Name -eq 'Id' }
            if ($idMatch) {
                $identityMapping['Id'] = $ph
            }
        }
    }

    # Build the param block string
    $paramLines = [System.Text.StringBuilder]::new()
    [void]$paramLines.AppendLine('    [CmdletBinding()]')
    [void]$paramLines.AppendLine('    param(')
    $paramEntries = @()
    foreach ($p in $functionEntry) {
        $pName = $p.Name
        $pType = $p.Type

        $entry = [System.Text.StringBuilder]::new()
        [void]$entry.AppendLine('        [Parameter()]')
        [void]$entry.AppendLine("        [$pType]")
        [void]$entry.Append("        `$$pName")
        $paramEntries += $entry.ToString()

        if ($method -eq 'GET' -and $pName -eq 'PageSize') {
            $paramEntries += "        [Parameter()]`r`n        [System.Management.Automation.SwitchParameter]`r`n        `$NoPageSize"
        }
    }
    [void]$paramLines.Append(($paramEntries -join ",`r`n`r`n"))
    [void]$paramLines.AppendLine('')
    [void]$paramLines.AppendLine('    )')

    # Build the function body
    $bodyLines = [System.Text.StringBuilder]::new()

    # Determine which params are identity, OData, body-meta, and infrastructure
    $identityParamNames = @($identityMapping.Keys)
    $allExcludeFromBody = $infrastructureParams + $odataParams + $bodyMetaParams + $identityParamNames + @('Confirm', 'WhatIf')

    switch ($method) {
        'GET' {
            # GET requests: delegate to Invoke-M365DSCGraphShimGetResource
            $hasListUri = $null -ne $listUri
            $hasSingleUri = $null -ne $singleUri

            [void]$bodyLines.AppendLine('')

            if ($hasSingleUri -and $identityParamNames.Count -gt 0) {
                # Build the single-item URI expression with variable substitution
                $singleUriExpr = "/$apiVersion$singleUri"
                foreach ($entry in $identityMapping.GetEnumerator()) {
                    $singleUriExpr = $singleUriExpr -replace [regex]::Escape("{$($entry.Value)}"), "`$(`$$($entry.Key))"
                }

                $lastIdParam = $identityParamNames[-1]
                [void]$bodyLines.AppendLine("    if (`$PSBoundParameters.ContainsKey('$lastIdParam') -and [System.String]::IsNullOrEmpty(`$$lastIdParam)) { Write-Error -Message `"Cannot bind argument to parameter '$lastIdParam' because it is an empty string.`" -ErrorAction `$ErrorActionPreference; return }")
                [void]$bodyLines.AppendLine("    `$singleItemUri = if (`$PSBoundParameters.ContainsKey('$lastIdParam') -and -not [System.String]::IsNullOrEmpty(`$$lastIdParam)) { `"$singleUriExpr`" } else { `$null }")
            }

            # Build the collection URI expression (or singleton URI if no list endpoint)
            if ($hasListUri) {
                $listUriExpr = "/$apiVersion$listUri"
                foreach ($entry in $identityMapping.GetEnumerator()) {
                    $listUriExpr = $listUriExpr -replace [regex]::Escape("{$($entry.Value)}"), "`$(`$$($entry.Key))"
                }
                $collectionUriLiteral = $listUriExpr
            }
            else {
                $uriExpr = "/$apiVersion$primaryUri"
                foreach ($entry in $identityMapping.GetEnumerator()) {
                    $uriExpr = $uriExpr -replace [regex]::Escape("{$($entry.Value)}"), "`$(`$$($entry.Key))"
                }
                $collectionUriLiteral = $uriExpr
            }

            if ($hasSingleUri -and $identityParamNames.Count -gt 0) {
                [void]$bodyLines.AppendLine("    return Invoke-M365DSCGraphShimGetResource -BoundParameters `$PSBoundParameters -CollectionUri `"$collectionUriLiteral`" -SingleItemUri `$singleItemUri -ErrorAction `$ErrorActionPreference")
            }
            else {
                [void]$bodyLines.AppendLine("    return Invoke-M365DSCGraphShimGetResource -BoundParameters `$PSBoundParameters -CollectionUri `"$collectionUriLiteral`" -ErrorAction `$ErrorActionPreference")
            }
        }

        { $_ -in @('POST', 'PUT') } {
            # POST/PUT: delegate to Invoke-M365DSCGraphShimWriteResource
            $targetUri = if ($listUri) { $listUri } else { $primaryUri }
            $uriExpr = "/$apiVersion$targetUri"
            foreach ($entry in $identityMapping.GetEnumerator()) {
                $uriExpr = $uriExpr -replace [regex]::Escape("{$($entry.Value)}"), "`$(`$$($entry.Key))"
            }

            $httpMethod = if ($method -eq 'PUT') { 'PUT' } else { 'POST' }
            [void]$bodyLines.AppendLine('')

            if ($identityParamNames.Count -gt 0) {
                $extraExclude = ($identityParamNames | ForEach-Object { "'$_'" }) -join ', '
                [void]$bodyLines.AppendLine("    return Invoke-M365DSCGraphShimWriteResource -BoundParameters `$PSBoundParameters -Uri `"$uriExpr`" -Method '$httpMethod' -ExtraExcludeParams @($extraExclude) -ErrorAction `$ErrorActionPreference")
            }
            else {
                [void]$bodyLines.AppendLine("    return Invoke-M365DSCGraphShimWriteResource -BoundParameters `$PSBoundParameters -Uri `"$uriExpr`" -Method '$httpMethod' -ErrorAction `$ErrorActionPreference")
            }
        }

        'PATCH' {
            # PATCH: delegate to Invoke-M365DSCGraphShimWriteResource
            $targetUri = if ($singleUri) { $singleUri } else { $primaryUri }
            $uriExpr = "/$apiVersion$targetUri"
            foreach ($entry in $identityMapping.GetEnumerator()) {
                $uriExpr = $uriExpr -replace [regex]::Escape("{$($entry.Value)}"), "`$(`$$($entry.Key))"
            }

            [void]$bodyLines.AppendLine('')

            if ($identityParamNames.Count -gt 0) {
                $extraExclude = ($identityParamNames | ForEach-Object { "'$_'" }) -join ', '
                [void]$bodyLines.AppendLine("    return Invoke-M365DSCGraphShimWriteResource -BoundParameters `$PSBoundParameters -Uri `"$uriExpr`" -Method 'PATCH' -ExtraExcludeParams @($extraExclude) -ErrorAction `$ErrorActionPreference")
            }
            else {
                [void]$bodyLines.AppendLine("    return Invoke-M365DSCGraphShimWriteResource -BoundParameters `$PSBoundParameters -Uri `"$uriExpr`" -Method 'PATCH' -ErrorAction `$ErrorActionPreference")
            }
        }

        'DELETE' {
            # DELETE: delegate to Invoke-M365DSCGraphShimDeleteResource
            $targetUri = if ($singleUri) { $singleUri } else { $primaryUri }
            $uriExpr = "/$apiVersion$targetUri"
            foreach ($entry in $identityMapping.GetEnumerator()) {
                $uriExpr = $uriExpr -replace [regex]::Escape("{$($entry.Value)}"), "`$(`$$($entry.Key))"
            }

            [void]$bodyLines.AppendLine('')
            [void]$bodyLines.AppendLine("    Invoke-M365DSCGraphShimDeleteResource -BoundParameters `$PSBoundParameters -Uri `"$uriExpr`" -ErrorAction `$ErrorActionPreference")
        }
    }

    # Assemble the function
    [void]$sb.AppendLine('')
    [void]$sb.AppendLine("function $cmdletName")
    [void]$sb.AppendLine('{')
    [void]$sb.Append($paramLines.ToString())
    [void]$sb.Append($bodyLines.ToString())
    [void]$sb.AppendLine('}')

    $exportedFunctions.Add($cmdletName)
    $generated++
}
#endregion

# Module footer: export functions
[void]$sb.AppendLine('')
[void]$sb.AppendLine('# Export all wrapper functions')
$exportList = ($exportedFunctions | ForEach-Object { "'$_'" }) -join ",`r`n    "
[void]$sb.AppendLine("Export-ModuleMember -Function @(`r`n    $exportList`r`n)")

Write-Host "Writing module to: $OutputModulePath"
$OutputModulePath = [System.IO.Path]::GetFullPath($OutputModulePath)
$sb.ToString() | Set-Content $OutputModulePath -Encoding utf8 -Force

# Generate module manifest
Write-Host "Writing manifest to: $OutputManifestPath"
$OutputManifestPath = [System.IO.Path]::GetFullPath($OutputManifestPath)
$manifestParams = @{
    Path              = $OutputManifestPath
    RootModule        = [System.IO.Path]::GetFileName($OutputModulePath)
    ModuleVersion     = '0.1.0'
    Author            = 'Team Microsoft365DSC'
    Description       = 'Auto-generated Graph SDK shim module for Microsoft365DSC. Replaces typed Graph SDK cmdlets with Invoke-MgGraphRequest wrappers.'
    PowerShellVersion = '5.1'
    FunctionsToExport = $exportedFunctions.ToArray()
    CmdletsToExport   = @()
    AliasesToExport   = @()
    RequiredModules   = @('Microsoft.Graph.Authentication')
    Guid              = '730f252e-c4a5-4290-b1da-5d410df44e2d'
}
New-ModuleManifest @manifestParams

$manifestContent = [System.IO.File]::ReadAllText($OutputManifestPath)
$manifestLines = [System.Collections.Generic.List[System.String]]::new()
$manifestLines.AddRange([System.String[]] ($manifestContent -split "`r`n"))

for ($index = 0; $index -lt $manifestLines.Count; $index++)
{
    if ($manifestLines[$index].StartsWith('# Generated on:'))
    {
        $manifestLines[$index] = "# Generated on: $(Get-Date -Format 'yyyy-MM-dd')"
        break
    }
}

$exportStart = -1
for ($index = 0; $index -lt $manifestLines.Count; $index++)
{
    if ($manifestLines[$index].StartsWith('FunctionsToExport = '))
    {
        $exportStart = $index
        break
    }
}
if ($exportStart -lt 0)
{
    throw 'The generated manifest has no FunctionsToExport entry to reformat.'
}

$exportEnd = $exportStart
while ($exportEnd + 1 -lt $manifestLines.Count -and -not [System.String]::IsNullOrWhiteSpace($manifestLines[$exportEnd + 1]))
{
    $exportEnd++
}

$exportLines = [System.Collections.Generic.List[System.String]]::new()
for ($index = 0; $index -lt $exportedFunctions.Count; $index++)
{
    $prefix = if ($index -eq 0) { 'FunctionsToExport = ' } else { ' ' * 15 }
    $separator = if ($index -lt $exportedFunctions.Count - 1) { ',' } else { '' }
    $exportLines.Add("$prefix'$($exportedFunctions[$index])'$separator")
}

$manifestLines.RemoveRange($exportStart, $exportEnd - $exportStart + 1)
$manifestLines.InsertRange($exportStart, $exportLines)

$manifestContent = (($manifestLines | ForEach-Object { $_.TrimEnd() }) -join "`r`n").TrimEnd("`r", "`n") + "`r`n"
[System.IO.File]::WriteAllText($OutputManifestPath, $manifestContent)

Write-Host "Done. Generated $generated wrappers, skipped $skipped."
Write-Host "Exported functions: $($exportedFunctions.Count)"
