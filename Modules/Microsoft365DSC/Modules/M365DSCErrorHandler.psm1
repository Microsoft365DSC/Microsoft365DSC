$Script:M365DSCPartialExportPath = $null

<#
.SYNOPSIS
    Saves the already exported configuration to a temporary file to prevent data loss
    in case of an error during export.

.DESCRIPTION
    This function stores the already exported configuration to file, so this
    information isn't lost when the export encounters an issue

.PARAMETER Content
    The content to save to the temporary file.

.PARAMETER FileName
    The name of the temporary file to save the content to.

.FUNCTIONALITY
    Internal
#>
function Save-M365DSCPartialExport
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Content,

        [Parameter(Mandatory = $true)]
        [System.String]
        $FileName
    )

    if (-not [System.String]::IsNullOrEmpty($env:TEMP))
    {
        $tempPath = Join-Path -Path $env:TEMP -ChildPath $FileName
        $Script:M365DSCPartialExportPath = $tempPath
        [Microsoft365DSC.Cache.PartialExportWriter]::Append($tempPath, $Content)
    }
}

<#
.DESCRIPTION
    Releases the lock used by Save-M365DSCPartialExport. Call at export completion or on error.

.FUNCTIONALITY
    Internal
#>
function Close-M365DSCPartialExport
{
    [CmdletBinding()]
    param()

    if ($null -ne $Script:M365DSCPartialExportPath)
    {
        [Microsoft365DSC.Cache.PartialExportWriter]::Release($Script:M365DSCPartialExportPath)
        $Script:M365DSCPartialExportPath = $null
    }
}

<#
.SYNOPSIS
    Determines whether an error record represents a transient (retriable) error
    such as timeouts, HTTP 5XX, throttling (429), or network failures.

.DESCRIPTION
    Inspects the exception message, HTTP status code, and error details of a
    PowerShell ErrorRecord to classify it as transient or permanent. This is used
    by Invoke-M365DSCCommand to decide whether to retry a failed operation.

.PARAMETER ErrorRecord
    The PowerShell ErrorRecord to inspect.

.OUTPUTS
    [System.Boolean] $true if the error is transient (should be retried), $false otherwise.

.FUNCTIONALITY
    Internal
#>
function Test-M365DSCTransientError
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.ErrorRecord]
        $ErrorRecord
    )

    $message = $ErrorRecord.Exception.Message

    # HTTP status code patterns (5XX server errors + 429 throttling)
    $transientStatusCodes = @(429, 500, 502, 503, 504)
    foreach ($code in $transientStatusCodes)
    {
        if ($message -match "\b$code\b")
        {
            return $true
        }
    }

    # Check for HttpResponseException or similar with a Response.StatusCode property
    $response = $null
    if ($null -ne $ErrorRecord.Exception.PSObject.Properties['Response'])
    {
        $response = $ErrorRecord.Exception.Response
    }
    if ($null -ne $response -and $null -ne $response.PSObject.Properties['StatusCode'])
    {
        $statusCodeInt = [int]$response.StatusCode
        if ($statusCodeInt -in $transientStatusCodes)
        {
            return $true
        }
    }

    # Common transient error message patterns across all workloads
    $transientPatterns = @(
        '*timed out*',
        '*timeout*',
        '*time out*',
        '*Too Many Requests*',
        '*throttled*',
        '*Service Unavailable*',
        '*Bad Gateway*',
        '*Gateway Timeout*',
        '*Internal Server Error*',
        '*connection was closed*',
        '*connection reset*',
        '*Unable to connect*',
        '*Could not establish trust*',
        '*The underlying connection*',
        '*A connection attempt failed*',
        '*An existing connection was forcibly closed*',
        '*request was canceled due to*',
        '*task was canceled*',
        '*Transient*'
    )
    foreach ($pattern in $transientPatterns)
    {
        if ($message -like $pattern)
        {
            return $true
        }
    }

    # Check ErrorDetails.Message for JSON error bodies (common in Graph/Intune)
    if ($null -ne $ErrorRecord.ErrorDetails -and -not [System.String]::IsNullOrEmpty($ErrorRecord.ErrorDetails.Message))
    {
        $detailsMessage = $ErrorRecord.ErrorDetails.Message
        foreach ($pattern in $transientPatterns)
        {
            if ($detailsMessage -like $pattern)
            {
                return $true
            }
        }
    }

    return $false
}

<#
.SYNOPSIS
    Determines whether an error record represents a "resource not found" error,
    which is expected during resource lookups by Id.

.DESCRIPTION
    Inspects the exception message, HTTP status code, and error details of a
    PowerShell ErrorRecord to determine if the error indicates that the requested
    resource does not exist. This covers patterns from Microsoft Graph, Exchange
    Online, Teams, SharePoint/PnP, and Security & Compliance workloads.

.PARAMETER ErrorRecord
    The PowerShell ErrorRecord to inspect.

.OUTPUTS
    [System.Boolean] $true if the error indicates the resource was not found, $false otherwise.

.FUNCTIONALITY
    Internal
#>
function Test-M365DSCNotFoundError
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.ErrorRecord]
        $ErrorRecord
    )

    # Check for HTTP 404 status code on the response object
    if ($null -ne $ErrorRecord.Exception.PSObject.Properties['Response'])
    {
        $response = $ErrorRecord.Exception.Response
        if ($null -ne $response -and $null -ne $response.PSObject.Properties['StatusCode'])
        {
            if ([int]$response.StatusCode -eq 404)
            {
                return $true
            }
        }
    }

    $message = $ErrorRecord.Exception.Message

    # Common "not found" patterns across all workloads
    $notFoundPatterns = @(
        '*ResourceNotFound*',
        '*Resource * does not exist*',
        '*resource * not found*',
        '*does not exist*',
        '*doesn''t exist*',
        '*was not found*',
        '*wasn''t found*',
        '*could not be found*',
        '*couldn''t be found*',
        '*cannot be found*',
        '*is not recognized*',
        '*Item not found*',
        '*File Not Found*',
        '*Not Found*',
        '*Cannot find*',
        '*404*'
    )
    foreach ($pattern in $notFoundPatterns)
    {
        if ($message -like $pattern)
        {
            return $true
        }
    }

    # Check ErrorDetails.Message for JSON error bodies
    if ($null -ne $ErrorRecord.ErrorDetails -and -not [System.String]::IsNullOrEmpty($ErrorRecord.ErrorDetails.Message))
    {
        $detailsMessage = $ErrorRecord.ErrorDetails.Message
        foreach ($pattern in $notFoundPatterns)
        {
            if ($detailsMessage -like $pattern)
            {
                return $true
            }
        }
    }

    return $false
}

<#
.SYNOPSIS
    Executes a scriptblock with automatic retry for transient errors and optional
    suppression of "not found" errors.

.DESCRIPTION
    Wraps the execution of external cmdlet calls (Microsoft Graph, Exchange Online,
    Teams, SharePoint, etc.) with resilient error handling. The function:

    - Retries transient errors (timeouts, HTTP 5XX, throttling) with exponential backoff.
    - Optionally returns $null for "not found" errors instead of throwing (for resource
    lookups by Id where the resource may not exist).
    - Throws immediately on permanent, unexpected errors.

    This replaces the pattern of using -ErrorAction SilentlyContinue which swallows
    all errors including transient ones, causing the DSC engine to incorrectly
    report resources as absent.

.PARAMETER ScriptBlock
    The scriptblock containing the cmdlet call to execute. The cmdlet inside should
    use -ErrorAction Stop to ensure errors are catchable.

.PARAMETER SuppressNotFoundError
    When specified, errors classified as "resource not found" (HTTP 404, various
    workload-specific "not found" messages) will cause the function to return $null
    instead of throwing. Use this for lookups by Id where non-existence is expected.

.PARAMETER RetryOnNotFoundError
    When specified, errors classified as "resource not found" will be treated as errors to retry.

.PARAMETER MaxRetries
    Maximum number of retry attempts for transient errors. Default is 3.

.PARAMETER BaseDelayInSeconds
    Base delay in seconds for exponential backoff between retries. The actual delay
    is calculated as BaseDelayInSeconds * 2^(retryCount-1), giving delays of 2, 4, 8
    seconds by default.

.EXAMPLE
    # Lookup by Id with not-found suppression (returns $null if resource doesn't exist)
    PS> $getValue = Invoke-M365DSCCommand -ScriptBlock {
        Get-MgBetaIdentityGovernanceAccessReviewDefinition `
            -AccessReviewScheduleDefinitionId $Id -ErrorAction Stop
    } -SuppressNotFoundError

.EXAMPLE
    # Lookup by filter (no suppression needed — empty results return naturally)
    PS> $getValue = Invoke-M365DSCCommand -ScriptBlock {
        Get-MgBetaIdentityGovernanceAccessReviewDefinition `
            -Filter "DisplayName eq 'MyReview'" -ErrorAction Stop
    }

.EXAMPLE
    # Write operation with retry but no not-found suppression
    PS> Invoke-M365DSCCommand -ScriptBlock {
        New-MgBetaIdentityGovernanceAccessReviewDefinition `
            -BodyParameter $params -ErrorAction Stop
    }

.OUTPUTS
    The output of the ScriptBlock, or $null if a not-found error was suppressed.

.FUNCTIONALITY
    Internal
#>
function Invoke-M365DSCCommand
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [scriptblock]
        $ScriptBlock,

        [Parameter()]
        [switch]
        $SuppressNotFoundError,

        [Parameter()]
        [switch]
        $RetryOnNotFoundError,

        [Parameter()]
        [System.Int32]
        $MaxRetries = 3,

        [Parameter()]
        [System.Int32]
        $BaseDelayInSeconds = 2
    )

    $retryCount = 0
    $previousErrorActionPreference = $ErrorActionPreference
    $ErrorActionPreference = 'Stop' # Ensure all errors are catchable
    while ($true)
    {
        try
        {
            $result = (& $ScriptBlock)
            $ErrorActionPreference = $previousErrorActionPreference
            return $result
        }
        catch
        {
            # Check if this is a "not found" error that should return $null
            if ($SuppressNotFoundError -and -not $RetryOnNotFoundError -and (Test-M365DSCNotFoundError -ErrorRecord $_))
            {
                Write-Verbose -Message "Resource not found (expected): $($_.Exception.Message)"
                $ErrorActionPreference = $previousErrorActionPreference
                return $null
            }

            # Check if this is a transient error that warrants retry
            if ((Test-M365DSCTransientError -ErrorRecord $_) -and $retryCount -lt $MaxRetries -or ($RetryOnNotFoundError -and (Test-M365DSCNotFoundError -ErrorRecord $_) -and $retryCount -lt $MaxRetries))
            {
                $retryCount++
                $delay = $BaseDelayInSeconds * [Math]::Pow(2, $retryCount - 1)
                Write-Verbose -Message "Transient error detected (attempt $retryCount/$MaxRetries). Retrying after ${delay}s: $($_.Exception.Message)"
                Start-Sleep -Seconds $delay
                continue
            }

            # Permanent error or retries exhausted. Throw the exception to be handled by the caller.
            Write-Verbose -Message "Permanent error or max retries reached: $($_.Exception.Message)"
            $ErrorActionPreference = $previousErrorActionPreference
            throw
        }
    }
}

<#
.SYNOPSIS
    Waits until a condition is met, with a maximum number of attempts.

.DESCRIPTION
    Invokes the scriptblock until it returns a truthy value the required number of times in a row.
    Sleeps between attempts only after an unmet result. Used to wait for objects that the service
    replicates with a delay.

.PARAMETER ScriptBlock
    The condition to evaluate. A truthy result counts as met.

.PARAMETER Description
    Describes what is awaited, used in the verbose messages.

.PARAMETER MaxAttempts
    Maximum number of evaluations. Default is 6.

.PARAMETER RetryDelayInSeconds
    Delay after an unmet result. Default is 5 seconds.

.PARAMETER ConsecutiveCount
    Number of consecutive met results required. Default is 1.

.OUTPUTS
    System.Boolean. $true when the condition was met, otherwise $false.

.FUNCTIONALITY
    Internal
#>
function Wait-M365DSCCondition
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [scriptblock]
        $ScriptBlock,

        [Parameter(Mandatory = $true)]
        [System.String]
        $Description,

        [Parameter()]
        [System.Int32]
        $MaxAttempts = 6,

        [Parameter()]
        [System.Int32]
        $RetryDelayInSeconds = 5,

        [Parameter()]
        [System.Int32]
        $ConsecutiveCount = 1
    )

    $metCount = 0
    for ($attempt = 1; $attempt -le $MaxAttempts; $attempt++)
    {
        if (& $ScriptBlock)
        {
            $metCount++
            if ($metCount -ge $ConsecutiveCount)
            {
                return $true
            }
            continue
        }

        $metCount = 0
        if ($attempt -lt $MaxAttempts)
        {
            Write-Verbose -Message "Waiting for $Description (attempt $attempt of $MaxAttempts). Retrying in $RetryDelayInSeconds seconds."
            Start-Sleep -Seconds $RetryDelayInSeconds
        }
    }

    Write-Verbose -Message "Stopped waiting for $Description after $MaxAttempts attempts."
    return $false
}

Export-ModuleMember -Function @(
    'Close-M365DSCPartialExport',
    'Invoke-M365DSCCommand',
    'Save-M365DSCPartialExport',
    'Test-M365DSCNotFoundError',
    'Test-M365DSCTransientError',
    'Wait-M365DSCCondition'
)
