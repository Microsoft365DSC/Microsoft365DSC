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

    $response = Invoke-WebRequest @params -UseBasicParsing
    $result = $null
    if (-not [System.String]::IsNullOrEmpty($response.Content))
    {
        $result = ConvertFrom-Json $response.Content
    }
    return $result
}
