<#
.SYNOPSIS
    Resolves the initial onmicrosoft tenant domain.

.DESCRIPTION
    Retrieves the tenant's initial domain through Microsoft Graph when connection parameters support it.
    When a certificate path is provided and the tenant id already contains onmicrosoft, it returns the tenant id directly.

.PARAMETER ApplicationId
    Specifies the application id used for app-based authentication.

.PARAMETER TenantId
    Specifies the tenant id or tenant domain.

.PARAMETER ApplicationSecret
    Specifies the application secret used for app-based authentication.

.PARAMETER CertificateThumbprint
    Specifies the certificate thumbprint used for app-based authentication.

.PARAMETER CertificatePath
    Specifies the certificate file path used for app-based authentication.

.PARAMETER ManagedIdentity
    Indicates that managed identity authentication should be used.

.FUNCTIONALITY
    Internal

.OUTPUTS
    System.String
#>
function Get-M365DSCTenantDomain
{
    [CmdletBinding(DefaultParameterSetName = 'AppId')]
    [OutputType([System.String])]
    param
    (
        [Parameter(ParameterSetName = 'AppId', Mandatory = $true)]
        [System.String]
        $ApplicationId,

        [Parameter(Mandatory = $true)]
        [System.String]
        $TenantId,

        [Parameter(ParameterSetName = 'AppId')]
        [System.Management.Automation.PSCredential]
        $ApplicationSecret,

        [Parameter(ParameterSetName = 'AppId')]
        [System.String]
        $CertificateThumbprint,

        [Parameter(ParameterSetName = 'AppId')]
        [System.String]
        $CertificatePath,

        [Parameter(ParameterSetName = 'MID')]
        [Switch]
        $ManagedIdentity
    )

    if ([System.String]::IsNullOrEmpty($CertificatePath))
    {
        $null = New-M365DSCConnection -Workload 'MicrosoftGraph' `
            -InboundParameters $PSBoundParameters

        try
        {
            $tenantDetails = (Invoke-MgGraphRequest -Uri '/beta/organization' -Method GET -ErrorAction 'Stop').value
            $defaultDomain = $tenantDetails.verifiedDomains | Where-Object -Property isInitial -EQ $true

            return $defaultDomain.name
        }
        catch
        {
            if ($_.Exception.Message -like '*Insufficient privileges*' -or
                $_.ErrorDetails.Message -like '*Insufficient privileges*' -or
                $_.Exception.Response.StatusCode -eq [System.Net.HttpStatusCode]::Forbidden)
            {
                $message = 'Error retrieving Organizational information: Missing Organization.Read.All permission.'
                New-M365DSCLogEntry `
                    -Message $message `
                    -Exception $_ `
                    -Source $($MyInvocation.MyCommand.Source) `
                    -TenantId $TenantId

                throw [System.UnauthorizedAccessException]::new($message, $_.Exception)
            }

            throw $_
        }
    }

    if ($TenantId.Contains('onmicrosoft'))
    {
        return $TenantId
    }
    else
    {
        throw 'TenantID must be in format contoso.onmicrosoft.com'
    }
}

<#
.SYNOPSIS
    Derives the tenant name from a bound parameter set.

.DESCRIPTION
    Returns the tenant identifier directly when TenantId is present.
    Otherwise, it derives the tenant name from the credential user principal name.

.PARAMETER ParameterSet
    Specifies the bound parameter hashtable to inspect.

.FUNCTIONALITY
    Internal

.OUTPUTS
    System.String
#>
function Get-M365DSCTenantNameFromParameterSet
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter(Mandatory = $true, Position = 1)]
        [System.Collections.HashTable]
        $ParameterSet
    )

    if ($ParameterSet.ContainsKey('TenantId'))
    {
        return $ParameterSet.TenantId
    }
    elseif ($ParameterSet.ContainsKey('Credential'))
    {
        try
        {
            $tenantName = $ParameterSet.Credential.Username.Split('@')[1]
            return $tenantName
        }
        catch
        {
            return $null
        }
    }
}

<#
.SYNOPSIS
    Resolves the organization domain from credential or tenant id.

.DESCRIPTION
    Extracts the DNS domain part from the credential username when available.
    If no credential is provided, it validates and returns the tenant id when it represents a domain value.

.PARAMETER Credential
    Specifies the credential containing a user principal name.

.PARAMETER TenantId
    Specifies the tenant id or domain value to return.

.FUNCTIONALITY
    Internal
#>
function Get-M365DSCOrganization
{
    param
    (
        [Parameter()]
        [System.Management.Automation.PSCredential]
        $Credential,

        [Parameter()]
        [System.String]
        $TenantId
    )

    if ($null -ne $Credential -and $Credential.UserName.Contains('@'))
    {
        $organization = $Credential.UserName.Split('@')[1]
        return $organization
    }

    if (-not [System.String]::IsNullOrEmpty($TenantId))
    {
        if ($TenantId.Contains('.'))
        {
            $organization = $TenantId
            return $organization
        }
        else
        {
            throw 'Tenant ID must be name of the tenant, e.g. contoso.onmicrosoft.com'
        }

    }
}

<#
.SYNOPSIS
    Retrieves the tenant short name from initial Microsoft Graph domains.

.DESCRIPTION
    Connects to Microsoft Graph and finds the initial onmicrosoft domain.
    Returns the tenant short name portion that is used to build workload-specific endpoints.

.PARAMETER UseMFA
    Obsolete. This parameter has no effect and is ignored.

.PARAMETER Credential
    Specifies the credential used for delegated authentication.

.FUNCTIONALITY
    Internal
#>
function Get-M365TenantName
{
    [CmdletBinding()]
    param
    (
        # TODO: Remove during next breaking change release
        [Parameter(Mandatory = $false)]
        [switch]
        $UseMFA,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $Credential
    )

    $initialDomain = Get-M365DSCInitialDomain -InboundParameters $PSBoundParameters
    $tenantName = $initialDomain.Split('.')[0]

    Write-Verbose -Message "M365 tenant name is $tenantName"
    return $tenantName
}

<#
.SYNOPSIS
    Resolves API endpoint base URLs for the connected cloud.

.DESCRIPTION
    Returns endpoint values used by Microsoft365DSC. Currently resolves the Azure management endpoint
    from the Azure connection profile, without a trailing slash. Requires an Azure connection.

.PARAMETER TenantId
    Specifies the tenant id or tenant domain. Not used, the endpoint comes from the Azure connection profile.

.EXAMPLE
    PS> Get-M365DSCAPIEndpoint -TenantId 'contoso.onmicrosoft.com'

.FUNCTIONALITY
    Internal

.OUTPUTS
    System.Collections.Hashtable
#>
function Get-M365DSCAPIEndpoint
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param(
        [Parameter(Mandatory = $true)]
        [System.String]
        $TenantId
    )

    $managementUrl = (Get-MSCloudLoginConnectionProfile -Workload 'Azure').ManagementUrl
    if ([System.String]::IsNullOrEmpty($managementUrl))
    {
        throw 'The Azure management endpoint is not available. Connect to the Azure workload first.'
    }

    return @{
        AzureManagement = $managementUrl.TrimEnd('/')
    }
}

<#
.SYNOPSIS
    Retrieves the SharePoint Online administration URL.

.DESCRIPTION
    Connects to Microsoft Graph, discovers the initial tenant domain, and builds the SharePoint admin URL of the tenant cloud.
    Returns the URL in the https://tenant-admin.sharepoint.com format, with the SharePoint domain of
    US Government (sharepoint.us), DoD (sharepoint-mil.us), China (sharepoint.cn) and sovereign cloud tenants.

.PARAMETER UseMFA
    Obsolete. This parameter has no effect and is ignored.

.PARAMETER Credential
    Specifies the credential used for delegated authentication.

.FUNCTIONALITY
    Internal
#>
function Get-SPOAdministrationUrl
{
    [CmdletBinding()]
    param
    (
        # TODO: Remove during next breaking change release
        [Parameter(Mandatory = $false)]
        [switch]
        $UseMFA,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $Credential
    )

    Write-Verbose -Message 'Getting SharePoint Online admin URL...'
    $initialDomain = Get-M365DSCInitialDomain -InboundParameters $PSBoundParameters
    $tenantName = $initialDomain.Split('.')[0]
    $environmentName = (Get-MSCloudLoginConnectionProfile -Workload 'MicrosoftGraph').EnvironmentName

    if ($initialDomain -like '*.onsovcloud.*')
    {
        $adminHost = $initialDomain.Replace('.onsovcloud.', '-admin.sovcloud-sharepoint.')
    }
    elseif ($initialDomain -like '*.partner.onmschina.cn')
    {
        $adminHost = "$tenantName-admin.sharepoint.cn"
    }
    elseif ($environmentName -eq 'AzureDOD')
    {
        $adminHost = "$tenantName-admin.sharepoint-mil.us"
    }
    elseif ($environmentName -eq 'AzureUSGovernment')
    {
        $adminHost = "$tenantName-admin.sharepoint.us"
    }
    else
    {
        $adminHost = "$tenantName-admin.sharepoint.$($initialDomain.Split('.')[-1])"
    }

    $adminUrl = "https://$adminHost"
    Write-Verbose -Message "SharePoint Online admin URL is $adminUrl"
    return $adminUrl
}

<#
.SYNOPSIS
    Returns the initial domain of the tenant (e.g. contoso.onmicrosoft.com).

.DESCRIPTION
    Connects to Microsoft Graph and returns the initial onmicrosoft, onmschina or onsovcloud domain of the tenant.
    The default domain is not used because it could be a custom domain.

.PARAMETER InboundParameters
    Specifies the parameters used to connect to Microsoft Graph.

.FUNCTIONALITY
    Internal

.OUTPUTS
    System.String
#>
function Get-M365DSCInitialDomain
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param(
        [Parameter(Mandatory = $true)]
        [System.Collections.Hashtable]
        $InboundParameters
    )

    Write-Verbose -Message 'Connection to Microsoft Graph is required to determine the initial domain of the tenant...'
    $null = New-M365DSCConnection -Workload 'MicrosoftGraph' `
        -InboundParameters $InboundParameters

    $domains = (Invoke-MgGraphRequest -Uri 'beta/domains' -Method GET -ErrorAction Stop).value
    $initialDomainPattern = '^[^.]+\.(onmicrosoft\.(com|de|us)|partner\.onmschina\.cn|onsovcloud\..+)$'
    foreach ($domain in $domains)
    {
        if ($domain.isInitial -eq $true -and $domain.id -match $initialDomainPattern)
        {
            return $domain.id
        }
    }

    throw 'Could not determine the initial onmicrosoft domain of the tenant.'
}

Export-ModuleMember -Function @(
    'Get-M365DSCTenantDomain',
    'Get-M365DSCTenantNameFromParameterSet',
    'Get-M365DSCOrganization',
    'Get-M365TenantName',
    'Get-M365DSCAPIEndpoint',
    'Get-SPOAdministrationUrl'
)
