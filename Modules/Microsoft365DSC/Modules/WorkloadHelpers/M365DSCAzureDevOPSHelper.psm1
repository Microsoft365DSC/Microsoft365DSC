<#
.SYNOPSIS
    Helper function to invoke a web request to Azure DevOPS API with the correct authorization header.

.DESCRIPTION
    This function is used to invoke a web request to the Azure DevOPS API. It automatically adds the correct authorization header using the access token obtained from the M365DSC connection profile for Azure DevOPS.

.PARAMETER Uri
    The URI of the Azure DevOPS API endpoint to which the request will be sent.

.PARAMETER Method
    The HTTP method to use for the request (e.g., GET, POST, PUT, DELETE). Default is 'GET'.

.PARAMETER Body
    The body of the request, if applicable. This is typically used for POST or PUT requests.

.PARAMETER ContentType
    The content type of the request. Default is 'application/json-patch+json'.

.OUTPUTS
    System.Management.Automation.PSCustomObject
    Returns the response from the Azure DevOPS API converted from JSON, or $null when the response content is empty.
    For GET requests, the value, items and members arrays of all pages are merged into the first page.
#>
function Invoke-M365DSCAzureDevOPSWebRequest
{
    [OutputType([System.Management.Automation.PSCustomObject])]
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [System.String]
        $Uri,

        [Parameter()]
        [System.String]
        $Method = 'GET',

        [Parameter()]
        [System.String]
        $Body,

        [Parameter()]
        [System.String]
        $ContentType = 'application/json-patch+json'
    )

    $headers = @{
        Authorization  = (Get-MSCloudLoginConnectionProfile -Workload AzureDevOPS).AccessToken
        'Content-Type' = $ContentType
    }

    $params = @{
        Headers = $headers
        Uri     = $Uri
        Method  = $Method

    }

    if ($Method -ne 'GET')
    {
        $params.Add('Body', $Body)
    }

    $result = $null
    $previousToken = $null
    do
    {
        $response = Invoke-WebRequest @params -UseBasicParsing
        $page = $null
        if (-not [System.String]::IsNullOrEmpty($response.Content))
        {
            $page = ConvertFrom-Json $response.Content
        }

        $continuationToken = $null
        if ($Method -eq 'GET')
        {
            if ($null -ne $response.Headers)
            {
                $continuationToken = $response.Headers['X-MS-ContinuationToken'] | Select-Object -First 1
            }
            if ([System.String]::IsNullOrEmpty($continuationToken) -and $null -ne $page -and $null -ne $page.PSObject.Properties['continuationToken'])
            {
                $continuationToken = $page.continuationToken | Select-Object -First 1
            }
        }

        if ($null -eq $result)
        {
            $result = $page
        }
        elseif ($null -ne $page)
        {
            foreach ($property in @('value', 'items', 'members'))
            {
                if ($null -ne $page.PSObject.Properties[$property] -and $null -ne $result.PSObject.Properties[$property])
                {
                    $result.$property = @($result.$property) + @($page.$property)
                }
            }
        }

        if ([System.String]::IsNullOrEmpty($continuationToken) -or $continuationToken -eq $previousToken)
        {
            break
        }
        $previousToken = $continuationToken
        $separator = if ($Uri.Contains('?')) { '&' } else { '?' }
        $params.Uri = $Uri + $separator + 'continuationToken=' + [System.Uri]::EscapeDataString($continuationToken)
    } while ($true)

    return $result
}
