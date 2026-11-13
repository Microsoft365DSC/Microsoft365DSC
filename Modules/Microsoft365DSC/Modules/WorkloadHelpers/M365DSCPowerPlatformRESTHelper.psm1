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
    System.Management.Automation.PSCustomObject
#>
function Invoke-M365DSCPowerPlatformRESTWebRequest
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
        $errorMessage = $_.Exception.Message
        if (-not [System.String]::IsNullOrEmpty($_.ErrorDetails.Message))
        {
            $errorMessage = "$errorMessage $($_.ErrorDetails.Message)"
        }

        if ($_.Exception.Response.StatusCode -eq [System.Net.HttpStatusCode]::Forbidden)
        {
            throw "Invalid permission for the application. If you are using a custom app registration to authenticate, make sure it is defined as a Power Platform admin management application. For additional information refer to https://learn.microsoft.com/en-us/power-platform/admin/powershell-create-service-principal#registering-an-admin-management-application $errorMessage"
        }

        if (-not [System.String]::IsNullOrEmpty($_.ErrorDetails.Message))
        {
            throw $errorMessage
        }

        throw $_
    }
    $result = $null
    if ($response.Content.Length -gt 0)
    {
        try
        {
            $result = ConvertFrom-Json $response.Content -ErrorAction Stop
        }
        catch
        {
            Write-Verbose -Message "The response content is not valid JSON: $_"
        }
    }
    return $result
}
