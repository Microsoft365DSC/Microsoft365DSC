<#
.SYNOPSIS
    Invokes a Power Platform REST request.

.DESCRIPTION
    Sends an authenticated REST request to the Power Platform REST workload using the current connection profile and returns the parsed response content when available.

.PARAMETER Uri
    Specifies the target URI for the REST request.

.PARAMETER Method
    Specifies the HTTP method to use. The default value is GET.

.PARAMETER Body
    Specifies the request payload to send when the method supports a body.

.OUTPUTS
    System.Collections.Hashtable
#>
function Invoke-M365DSCPowerPlatformRESTWebRequest
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param(
        [Parameter(Mandatory = $true)]
        [System.String]
        $Uri,

        [Parameter()]
        [System.String]
        $Method = 'GET',

        [Parameter()]
        [System.Collections.Hashtable]
        $Body
    )

    $headers = @{
        Authorization = (Get-MSCloudLoginConnectionProfile -Workload 'PowerPlatformREST').AccessToken
    }

    $bodyValue = $null
    if (-not [System.String]::IsNullOrEmpty($Body))
    {
        $bodyValue = ConvertTo-Json $Body -Depth 20 -Compress
    }

    try
    {
        $response = Invoke-WebRequest -Method $Method `
            -Uri $Uri `
            -Headers $headers `
            -Body $bodyValue `
            -ContentType 'application/json; charset=utf-8' `
            -UseBasicParsing
    }
    catch
    {
        if (-not [System.String]::IsNullOrEmpty($_.ErrorDetails.Message))
        {
            throw "$($_.Exception.Message) $($_.ErrorDetails.Message)"
        }

        throw $_
    }
    $result = $null
    if ($response.Content.Length -gt 0)
    {
        $result = ConvertFrom-Json $response.Content -ErrorAction SilentlyContinue
    }
    return $result
}
