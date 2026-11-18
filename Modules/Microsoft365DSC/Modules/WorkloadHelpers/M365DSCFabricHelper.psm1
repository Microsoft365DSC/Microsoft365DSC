<#
.SYNOPSIS
    Invokes a Fabric REST request.

.DESCRIPTION
    Sends an authenticated REST request to Microsoft Fabric using the current connection profile and returns the parsed response content.

.PARAMETER Uri
    Specifies the target URI for the REST request.

.PARAMETER Method
    Specifies the HTTP method to use. The default value is GET.

.PARAMETER Body
    Specifies the request payload to send when the method supports a body.

.OUTPUTS
    System.Management.Automation.PSCustomObject
#>
function Invoke-M365DSCFabricWebRequest
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

    $headers = @{
        Authorization = (Get-MSCloudLoginConnectionProfile -Workload 'Fabric').AccessToken
    }

    $response = Invoke-WebRequest -Method $Method `
        -Uri $Uri `
        -Headers $headers `
        -Body $Body `
        -UseBasicParsing
    $result = ConvertFrom-Json $response.Content
    return $result
}
