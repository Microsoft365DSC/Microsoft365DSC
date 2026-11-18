<#
.SYNOPSIS
    Invokes a Defender for Endpoint REST request.

.DESCRIPTION
    Sends an authenticated REST request to Microsoft Defender for Endpoint using the current connection profile and returns the parsed response content.

.PARAMETER Uri
    Specifies the target URI for the REST request.

.PARAMETER Method
    Specifies the HTTP method to use. The default value is GET.

.PARAMETER Body
    Specifies the request payload to send when the method supports a body.

.OUTPUTS
    System.Management.Automation.PSCustomObject
#>
function Invoke-M365DSCDefenderREST
{
    [CmdletBinding()]
    [OutputType([System.Management.Automation.PSCustomObject])]
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

    $bodyJSON = $null
    if ($null -ne $Body)
    {
        $bodyJSON = ConvertTo-Json $Body -Depth 10 -Compress
    }
    $headers = @{
        Authorization  = (Get-MSCloudLoginConnectionProfile -Workload DefenderForEndpoint).AccessToken
        'Content-Type' = 'application/json'
    }
    $response = Invoke-WebRequest -Method $Method `
        -Uri $Uri `
        -Headers $headers `
        -Body $bodyJSON `
        -UseBasicParsing
    $result = ConvertFrom-Json $response.Content
    return $result
}
