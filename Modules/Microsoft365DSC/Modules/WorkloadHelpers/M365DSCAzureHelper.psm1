<#
.SYNOPSIS
    Sends a request to the Azure Billing REST API.

.DESCRIPTION
    Calls Invoke-AzRestMethod against the Azure management endpoint and returns the parsed response.

.PARAMETER Method
    Specifies the HTTP method.

.PARAMETER Path
    Specifies the request path and query string, relative to the Azure management endpoint.

.PARAMETER Body
    Specifies the request payload, sent as JSON.

.FUNCTIONALITY
    Private

.OUTPUTS
    System.Object
#>
function Invoke-M365DSCAzureBillingRequest
{
    [CmdletBinding()]
    [OutputType([System.Object])]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateSet('GET', 'PUT', 'POST', 'DELETE')]
        [System.String]
        $Method,

        [Parameter(Mandatory = $true)]
        [System.String]
        $Path,

        [Parameter()]
        [System.Collections.Hashtable]
        $Body
    )

    $requestParams = @{
        Method = $Method
        Uri    = "$((Get-MSCloudLoginConnectionProfile -Workload Azure).ManagementUrl)$Path"
    }
    if ($PSBoundParameters.ContainsKey('Body'))
    {
        $requestParams.Payload = ConvertTo-Json $Body -Depth 10 -Compress
    }
    $response = Invoke-AzRestMethod @requestParams

    $statusCode = [System.Int32]$response.StatusCode
    if ($statusCode -ge 400)
    {
        $errorDetails = $response.Content
        try
        {
            $errorContent = ConvertFrom-Json $response.Content -ErrorAction Stop
            if ($null -ne $errorContent.error)
            {
                $errorDetails = "$($errorContent.error.code) $($errorContent.error.message)"
            }
        }
        catch
        {
            Write-Verbose -Message "Could not parse the error response: $_"
        }
        $statusText = "$statusCode $([System.Enum]::GetName([System.Net.HttpStatusCode], $statusCode))".TrimEnd()
        throw "Azure Billing $Method $Path failed ($statusText): $errorDetails"
    }

    if ([System.String]::IsNullOrEmpty($response.Content))
    {
        return $null
    }
    return ConvertFrom-Json $response.Content
}

<#
.SYNOPSIS
    Gets Azure billing accounts.

.DESCRIPTION
    Retrieves the list of Azure billing accounts for the current authenticated context.

.OUTPUTS
    System.Collections.Hashtable
#>
function Get-M365DSCAzureBillingAccount
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param()

    return Invoke-M365DSCAzureBillingRequest -Method GET `
        -Path 'providers/Microsoft.Billing/billingAccounts?api-version=2024-04-01&includeAll=true'
}

<#
.SYNOPSIS
    Gets associated tenants for a billing account.

.DESCRIPTION
    Retrieves the tenants currently associated to a specific Azure billing account.

.PARAMETER BillingAccountId
    Specifies the billing account identifier.

.OUTPUTS
    System.Collections.Hashtable
#>
function Get-M365DSCAzureBillingAccountsAssociatedTenant
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param(
        [Parameter(Mandatory = $true)]
        [System.String]
        $BillingAccountId
    )

    return Invoke-M365DSCAzureBillingRequest -Method GET `
        -Path "providers/Microsoft.Billing/billingAccounts/$($BillingAccountId)/associatedTenants?api-version=2024-04-01"
}

<#
.SYNOPSIS
    Removes an associated tenant from a billing account.

.DESCRIPTION
    Deletes the association between an Azure billing account and an associated tenant.

.PARAMETER BillingAccountId
    Specifies the billing account identifier.

.PARAMETER AssociatedTenantId
    Specifies the associated tenant identifier to remove.

.OUTPUTS
    System.Collections.Hashtable
#>
function Remove-M365DSCAzureBillingAccountsAssociatedTenant
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param(
        [Parameter(Mandatory = $true)]
        [System.String]
        $BillingAccountId,

        [Parameter(Mandatory = $true)]
        [System.String]
        $AssociatedTenantId
    )

    return Invoke-M365DSCAzureBillingRequest -Method DELETE `
        -Path "providers/Microsoft.Billing/billingAccounts/$($BillingAccountId)/associatedTenants/$($AssociatedTenantId)?api-version=2024-04-01"
}

<#
.SYNOPSIS
    Creates or updates an associated tenant for a billing account.

.DESCRIPTION
    Creates or updates the associated tenant relationship for an Azure billing account using the provided request body.

.PARAMETER BillingAccountId
    Specifies the billing account identifier.

.PARAMETER AssociatedTenantId
    Specifies the associated tenant identifier to create or update.

.PARAMETER Body
    Specifies the request payload sent to the Azure Billing API.

.OUTPUTS
    System.Collections.Hashtable
#>
function New-M365DSCAzureBillingAccountsAssociatedTenant
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param(
        [Parameter(Mandatory = $true)]
        [System.String]
        $BillingAccountId,

        [Parameter(Mandatory = $true)]
        [System.String]
        $AssociatedTenantId,

        [Parameter(Mandatory = $true)]
        [System.Collections.Hashtable]
        $Body
    )

    return Invoke-M365DSCAzureBillingRequest -Method PUT `
        -Path "providers/Microsoft.Billing/billingAccounts/$($BillingAccountId)/associatedTenants/$($AssociatedTenantId)?api-version=2024-04-01" `
        -Body $Body
}

<#
.SYNOPSIS
    Gets billing role assignments for a billing account.

.DESCRIPTION
    Retrieves all billing role assignments for a specific Azure billing account.

.PARAMETER BillingAccountId
    Specifies the billing account identifier.

.OUTPUTS
    System.Collections.Hashtable
#>
function Get-M365DSCAzureBillingAccountsRoleAssignment
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param(
        [Parameter(Mandatory = $true)]
        [System.String]
        $BillingAccountId
    )

    return Invoke-M365DSCAzureBillingRequest -Method GET `
        -Path "providers/Microsoft.Billing/billingAccounts/$($BillingAccountId)/billingRoleAssignments?api-version=2024-04-01"
}

<#
.SYNOPSIS
    Gets billing role definitions for a billing account.

.DESCRIPTION
    Retrieves billing role definitions for a specific Azure billing account, or a single role definition when an identifier is provided.

.PARAMETER BillingAccountId
    Specifies the billing account identifier.

.PARAMETER RoleDefinitionId
    Specifies the role definition identifier. When omitted, all role definitions are returned.

.OUTPUTS
    System.Collections.Hashtable
#>
function Get-M365DSCAzureBillingAccountsRoleDefinition
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param(
        [Parameter(Mandatory = $true)]
        [System.String]
        $BillingAccountId,

        [Parameter()]
        [System.String]
        $RoleDefinitionId
    )

    if ([System.String]::IsNullOrEmpty($RoleDefinitionId))
    {
        $path = "providers/Microsoft.Billing/billingAccounts/$($BillingAccountId)/billingRoleDefinitions?api-version=2024-04-01"
    }
    else
    {
        $path = "providers/Microsoft.Billing/billingAccounts/$($BillingAccountId)/billingRoleDefinitions/$($RoleDefinitionId)?api-version=2024-04-01"
    }
    return Invoke-M365DSCAzureBillingRequest -Method GET -Path $path
}

<#
.SYNOPSIS
    Creates a billing role assignment.

.DESCRIPTION
    Creates a new billing role assignment for a specific Azure billing account using the provided request body.

.PARAMETER BillingAccountId
    Specifies the billing account identifier.

.PARAMETER Body
    Specifies the request payload sent to the Azure Billing API.

.OUTPUTS
    System.Collections.Hashtable
#>
function New-M365DSCAzureBillingAccountsRoleAssignment
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param(
        [Parameter(Mandatory = $true)]
        [System.String]
        $BillingAccountId,

        [Parameter(Mandatory = $true)]
        [System.Collections.Hashtable]
        $Body
    )

    return Invoke-M365DSCAzureBillingRequest -Method POST `
        -Path "providers/Microsoft.Billing/billingAccounts/$($BillingAccountId)/createBillingRoleAssignment?api-version=2024-04-01" `
        -Body $Body
}

<#
.SYNOPSIS
    Removes a billing role assignment.

.DESCRIPTION
    Deletes a billing role assignment from a specific Azure billing account.

.PARAMETER BillingAccountId
    Specifies the billing account identifier.

.PARAMETER AssignmentId
    Specifies the billing role assignment identifier to remove.

.OUTPUTS
    System.Collections.Hashtable
#>
function Remove-M365DSCAzureBillingAccountsRoleAssignment
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param(
        [Parameter(Mandatory = $true)]
        [System.String]
        $BillingAccountId,

        [Parameter(Mandatory = $true)]
        [System.String]
        $AssignmentId
    )

    return Invoke-M365DSCAzureBillingRequest -Method DELETE `
        -Path "providers/Microsoft.Billing/billingAccounts/$($BillingAccountId)/billingRoleAssignments/$($AssignmentId)?api-version=2024-04-01"
}

Export-ModuleMember -Function @(
    'Get-M365DSCAzureBillingAccount',
    'Get-M365DSCAzureBillingAccountsAssociatedTenant',
    'Get-M365DSCAzureBillingAccountsRoleAssignment',
    'Get-M365DSCAzureBillingAccountsRoleDefinition',
    'New-M365DSCAzureBillingAccountsAssociatedTenant',
    'New-M365DSCAzureBillingAccountsRoleAssignment',
    'Remove-M365DSCAzureBillingAccountsAssociatedTenant',
    'Remove-M365DSCAzureBillingAccountsRoleAssignment'
)
