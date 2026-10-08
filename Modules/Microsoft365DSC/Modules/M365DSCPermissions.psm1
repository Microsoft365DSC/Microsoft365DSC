using namespace System.Management.Automation.Language

<#
.SYNOPSIS
    Returns an empty permissions matrix.

.DESCRIPTION
    Returns an empty permissions matrix pre-populated with the Organization.Read.All Graph
    application permission every tenant interaction needs.

.FUNCTIONALITY
    Internal, Hidden
#>
function New-M365DSCPermissionsMatrix
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param ()

    return @{
        AdministrativeRoles = @{
            Read   = @()
            Update = @()
        }
        Read                = @(
            @{
                API        = 'graph'
                Permission = @{
                    Name = 'Organization.Read.All'
                    Type = 'Application'
                }
            }
        )
        Update              = @(
            @{
                API        = 'graph'
                Permission = @{
                    Name = 'Organization.Read.All'
                    Type = 'Application'
                }
            }
        )
        RequiredRoles       = @{
            Read   = @()
            Update = @()
        }
        RequiredRoleGroups  = @{
            Read   = @()
            Update = @()
        }
    }
}

<#
.SYNOPSIS
    Compiles required permissions for selected Microsoft365DSC resources.

.DESCRIPTION
    Reads resource settings metadata and aggregates delegated/application permissions, required Exchange roles, and administrative roles.
    Output can be returned as a global matrix or grouped by resource.
    With the parameters, you can specify a specific subset of permissions, to be used with the Permissions parameter of
    Update-M365DSCAzureAdApplication.

.PARAMETER ResourceNameList
    Specifies resource names to evaluate.

.PARAMETER PermissionType
    Specifies the permission type filter to return.

.PARAMETER AccessType
    Specifies whether read or update permissions should be returned.

.PARAMETER GroupByResourceName
    Indicates that results should be grouped per resource.

.EXAMPLE
    Get-M365DSCCompiledPermissionList -ResourceNameList @('EXOAcceptedDomain')

.EXAMPLE
    Get-M365DSCCompiledPermissionList -ResourceNameList (Get-M365DSCAllResources)

.EXAMPLE
    Get-M365DSCCompiledPermissionList -ResourceNameList (Get-M365DSCAllResources) -PermissionType 'Application' -AccessType 'Update'

.EXAMPLE
    Get-M365DSCCompiledPermissionList -ResourceNameList (Get-M365DSCAllResources) -PermissionType 'Delegated' -AccessType 'Read'

.EXAMPLE
    Get-M365DSCCompiledPermissionList -ResourceNameList @('AADUser', 'EXOMailbox') -GroupByResourceName

.FUNCTIONALITY
    Public

.OUTPUTS
    System.Collections.Hashtable
#>
function Get-M365DSCCompiledPermissionList
{
    [CmdletBinding(DefaultParametersetName = 'None')]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true, Position = 0)]
        [System.String[]]
        $ResourceNameList,

        [Parameter(ParameterSetName = 'PermissionType', Mandatory = $true)]
        [ValidateSet('Delegated', 'Application')]
        [System.String]
        $PermissionType,

        [Parameter(ParameterSetName = 'PermissionType', Mandatory = $true)]
        [ValidateSet('Read', 'Update')]
        [System.String]
        $AccessType,

        [Parameter(ParameterSetName = 'GroupByResourceName')]
        [Switch]
        $GroupByResourceName
    )

    if ($GroupByResourceName)
    {
        $results = [ordered]@{}
    }
    else
    {
        $results = New-M365DSCPermissionsMatrix
    }

    $total = $ResourceNameList.Count
    $count = 1
    $ResourceNameList = $ResourceNameList | Sort-Object
    foreach ($resourceName in $ResourceNameList)
    {
        $percentage = ($count / $total) * 100
        Write-Progress -Activity 'Retrieving required permissions' -PercentComplete $percentage -Status 'Processing resource' -CurrentOperation $resourceName

        Write-Verbose -Message "Processing $resourceName"

        if ($GroupByResourceName)
        {
            $currentResourceResults = New-M365DSCPermissionsMatrix
        }
        $resourceSettings = Get-M365DSCResourceSetting -ResourceName $resourceName
        if ($null -eq $resourceSettings)
        {
            Write-Warning -Message "Settings were not found for resource {$resourceName}"
        }
        else
        {
            $targetMatrix = if ($GroupByResourceName) { $currentResourceResults } else { $results }

            # Entra / Administrative roles
            if ($null -ne $resourceSettings.roles.read -or $null -ne $resourceSettings.roles.update)
            {
                $readRoles = $resourceSettings.roles.read
                $updateRoles = $resourceSettings.roles.update
                foreach ($role in $readRoles)
                {
                    if (-not $targetMatrix.AdministrativeRoles.Read.Contains($role))
                    {
                        Write-Verbose -Message "    Found new Administrative Read role {$($role)}"
                        $targetMatrix.AdministrativeRoles.Read += $role
                    }
                    else
                    {
                        Write-Verbose -Message "    Administrative Read role {$($role)} was already added"
                    }
                }
                foreach ($role in $updateRoles)
                {
                    if (-not $targetMatrix.AdministrativeRoles.Update.Contains($role))
                    {
                        Write-Verbose -Message "    Found new Administrative Update role {$($role)}"
                        $targetMatrix.AdministrativeRoles.Update += $role
                    }
                    else
                    {
                        Write-Verbose -Message "    Administrative Update role {$($role)} was already added"
                    }
                }
            }

            if ($null -eq $resourceSettings.permissions)
            {
                Write-Warning "Error in reading permissions. Missing permissions node in settings.json for $resourceName."
                continue
            }

            foreach ($api in $resourceSettings.permissions.PSObject.Properties)
            {
                $apiName = $api.Name
                Write-Verbose -Message "  Retrieving $apiName permissions"

                foreach ($permissionType in @('Delegated', 'Application'))
                {
                    foreach ($accessType in @('Read', 'Update'))
                    {
                        Update-M365DSCPermissionsMatrix -Source $apiName `
                            -PermissionType $permissionType `
                            -AccessType $accessType `
                            -Matrix ([ref]$targetMatrix) `
                            -Permissions ($api.Value)
                    }
                }

                foreach ($accessType in @('Read', 'Update'))
                {
                    foreach ($requiredRole in $api.Value.requiredRoles.$accessType)
                    {
                        if (-not $targetMatrix.RequiredRoles.$accessType.Contains($requiredRole))
                        {
                            Write-Verbose -Message "    Found new $accessType Required Role {$($requiredRole)}"
                            $targetMatrix.RequiredRoles.$accessType += $requiredRole
                        }
                        else
                        {
                            Write-Verbose -Message "    Required $accessType Role {$($requiredRole)} was already added"
                        }
                    }

                    foreach ($requiredRoleGroup in $api.Value.requiredRoleGroups.$accessType)
                    {
                        if (-not $targetMatrix.RequiredRoleGroups.$accessType.Contains($requiredRoleGroup))
                        {
                            Write-Verbose -Message "    Found new $accessType Required Role Group {$($requiredRoleGroup)}"
                            $targetMatrix.RequiredRoleGroups.$accessType += $requiredRoleGroup
                        }
                        else
                        {
                            Write-Verbose -Message "    Required $accessType Role Group {$($requiredRoleGroup)} was already added"
                        }
                    }
                }
            }

            if ($GroupByResourceName)
            {
                $currentResourceResults.AdministrativeRoles.Read   = Get-M365DSCArrayFromProperty -PropertyValue ($currentResourceResults.AdministrativeRoles.Read | Sort-Object -Unique) -ElementType ([System.String])
                $currentResourceResults.AdministrativeRoles.Update = Get-M365DSCArrayFromProperty -PropertyValue ($currentResourceResults.AdministrativeRoles.Update | Sort-Object -Unique) -ElementType ([System.String])
                $currentResourceResults.RequiredRoleGroups.Read    = Get-M365DSCArrayFromProperty -PropertyValue ($currentResourceResults.RequiredRoleGroups.Read | Sort-Object -Unique) -ElementType ([System.String])
                $currentResourceResults.RequiredRoleGroups.Update  = Get-M365DSCArrayFromProperty -PropertyValue ($currentResourceResults.RequiredRoleGroups.Update | Sort-Object -Unique) -ElementType ([System.String])
                $currentResourceResults.RequiredRoles.Read         = Get-M365DSCArrayFromProperty -PropertyValue ($currentResourceResults.RequiredRoles.Read | Sort-Object -Unique) -ElementType ([System.String])
                $currentResourceResults.RequiredRoles.Update       = Get-M365DSCArrayFromProperty -PropertyValue ($currentResourceResults.RequiredRoles.Update | Sort-Object -Unique) -ElementType ([System.String])
                $results[$resourceName] = $currentResourceResults
            }
        }
        $count++
    }

    if ($PSBoundParameters.ContainsKey('PermissionType'))
    {
        $resultsByType = $results.$AccessType | Where-Object -FilterScript { $_.Permission.Type -eq $PermissionType }
        $resultsByType | ForEach-Object -Process {
            $_.PermissionName = $_.Permission.Name
            $_.Remove('Permission')
        }
        $results = @{
            AdministrativeRoles = $results.AdministrativeRoles.$AccessType
            Permissions         = $resultsByType
            RequiredRoles       = ($results.RequiredRoles).$AccessType
            RequiredRoleGroups  = ($results.RequiredRoleGroups).$AccessType
        }
    }

    if (-not $GroupByResourceName)
    {
        $results.AdministrativeRoles = $results.AdministrativeRoles | Sort-Object -Unique
        $results.RequiredRoleGroups  = $results.RequiredRoleGroups | Sort-Object -Unique
        $results.RequiredRoles       = $results.RequiredRoles | Sort-Object -Unique
    }

    return $results
}

<#
.Description
This function updates the inputted permissions matrix.
It is generic code used in the Get-M365DSCCompiledPermissionList function.

.Functionality
Internal, Hidden
#>
function Update-M365DSCPermissionsMatrix
{
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Source,

        [Parameter(Mandatory = $true)]
        [System.String]
        [ValidateSet('Delegated', 'Application')]
        $PermissionType,

        [Parameter(Mandatory = $true)]
        [System.String]
        [ValidateSet('Read', 'Update')]
        $AccessType,

        [Parameter(Mandatory = $true)]
        [System.Collections.Hashtable]
        [ref]$Matrix,

        [Parameter(Mandatory = $true)]
        [PSCustomObject]
        $Permissions
    )

    foreach ($permission in $Permissions.$PermissionType.$AccessType)
    {
        if ($permission.Name -ne 'NotSupported')
        {
            $matrixPermission = $Matrix.$AccessType | Where-Object -FilterScript {
                $_.API -eq $Source -and $_.Permission.Name -eq $permission.name -and $_.Permission.Type -eq $PermissionType
            }

            if ($null -eq $matrixPermission)
            {
                Write-Verbose -Message "    Found new $AccessType permission {$($permission.name)} for API {$Source}"
                $Matrix.$AccessType += @{
                    API        = $Source
                    Permission = @{
                        Type = $PermissionType
                        Name = $permission.name
                    }
                }
            }
            else
            {
                Write-Verbose -Message "    $AccessType permission {$($permission.name)} was already added for API {$Source}"
            }
        }
    }
}

<#
.SYNOPSIS
    Opens Graph consent flow for required delegated scopes.

.DESCRIPTION
    Resolves delegated Graph scopes required by selected resources and calls Connect-MgGraph with those scopes so consent can be granted.

.PARAMETER ResourceNameList
    Specifies resource names used to determine required scopes.

.PARAMETER All
    Indicates that all Microsoft365DSC resources should be included.

.PARAMETER Type
    Specifies whether read or update scopes should be requested.

.PARAMETER Environment
    Specifies the Microsoft Graph cloud environment.

.EXAMPLE
    Update-M365DSCAllowedGraphScopes -ResourceNameList @('AADUSer', 'AADApplication') -Type 'Read'

.EXAMPLE
    Update-M365DSCAllowedGraphScopes -All -Type 'Update' -Environment 'Global'

.FUNCTIONALITY
    Public
#>
function Update-M365DSCAllowedGraphScopes
{
    [CmdletBinding()]
    [OutputType()]
    param
    (
        [Parameter()]
        [System.String[]]
        $ResourceNameList,

        [Parameter()]
        [Switch]
        $All,

        [Parameter(Mandatory = $true)]
        [ValidateSet('Read', 'Update')]
        [System.String]
        $Type,

        [Parameter()]
        [ValidateSet('Global', 'China', 'USGov', 'USGovDoD', 'Germany')]
        [System.String]
        $Environment = 'Global'
    )

    if ($All)
    {
        Write-Verbose -Message 'All parameter specified'
        $resourceNames = Get-M365DSCAllResources
    }
    else
    {
        if ($PSBoundParameters.ContainsKey('ResourceNameList') -eq $false)
        {
            throw 'You have to specify either the All or ResourceNameList parameter!'
        }

        Write-Verbose -Message "Specified resources: $($ResourceNameList -join ', ')"
        $resourceNames = $ResourceNameList
    }

    Write-Verbose -Message "Specified type: $Type"
    $results = (Get-M365DSCCompiledPermissionList -ResourceNameList $resourceNames -PermissionType 'Delegated' -AccessType $Type).Permissions
    [System.String[]]$permissions = ($results | Where-Object -Property API -EQ 'Graph').PermissionName

    # Remove the Tasks.Read.All permission from the list as it is causing an issue with the Graph SDK
    $permissions = $permissions -ne 'Tasks.Read.All'
    Write-Verbose -Message "Found permissions: $($permissions -join ', ')"
    $params = @{
        Scopes = $permissions
    }

    Write-Verbose -Message 'Connecting to MS Graph to update permissions'
    $result = Connect-MgGraph @params -Environment $Environment
    if ($result -like '*Welcome To Microsoft Graph!*')
    {
        Write-Output 'Allowed Graph scopes updated!'
    }
    else
    {
        Write-Output 'Error during updating allowed Graph scopes!'
    }
}

<#
.SYNOPSIS
    Resolves the service principal backing an API name used in a resource settings.json file.

.DESCRIPTION
    Resolves the service principal using the API name provided. A known API name resolves through
    its application id because the Entra portal name may be different from what's in the settings file.

.PARAMETER ApiName
    Name of the API as written in the settings file or passed by the caller.

.PARAMETER Cache
    Hashtable holding the service principals already resolved during the current call.

.FUNCTIONALITY
    Internal, Hidden
#>
function Get-M365DSCApiServicePrincipal
{
    [CmdletBinding()]
    [OutputType([System.Object])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $ApiName,

        [Parameter(Mandatory = $true)]
        [System.Collections.Hashtable]
        $Cache
    )

    $knownApiAppIds = @{
        'graph'                                = '00000003-0000-0000-c000-000000000000'
        'Microsoft Graph'                      = '00000003-0000-0000-c000-000000000000'
        'sharepoint'                           = '00000003-0000-0ff1-ce00-000000000000'
        'Office 365 SharePoint Online'         = '00000003-0000-0ff1-ce00-000000000000'
        'exchange'                             = '00000002-0000-0ff1-ce00-000000000000'
        'purview'                              = '00000002-0000-0ff1-ce00-000000000000'
        'Office 365 Exchange Online'           = '00000002-0000-0ff1-ce00-000000000000'
        'Azure Service Management'             = '797f4846-ba00-4fd7-ba43-dac1f8f63013'
        'Azure DevOps'                         = '499b84ac-1321-427f-aa17-267ca6975798'
        'M365 License Manager'                 = 'aeb86249-8ea3-49e2-900b-54cc8e308f85'
        'powerAppsService'                     = '475226c6-020e-4fb2-8a90-7a972cbfc1d4'
        'ProjectWorkManagement'                = '09abbdfd-ed23-44ee-a2d9-a627aa1c90f3'
        'Verifiable Credentials Service Admin' = '6a8b4b39-c021-437c-b060-5a14a3fd65f3'
        'WindowsDefenderATP'                   = 'fc780465-2017-40d4-a0c5-307022471b92'
    }

    $appId = $null
    if ([System.Guid]::TryParse($ApiName, [ref][System.Guid]::Empty))
    {
        $appId = $ApiName
    }
    elseif ($knownApiAppIds.ContainsKey($ApiName))
    {
        $appId = $knownApiAppIds.$ApiName
    }

    if ($null -ne $appId)
    {
        $cacheKey = $appId
        $filter = "appId eq '$appId'"
    }
    else
    {
        $cacheKey = $ApiName
        $filter = "displayName eq '$($ApiName -replace "'", "''")'"
    }

    if ($Cache.ContainsKey($cacheKey))
    {
        return $Cache.$cacheKey
    }

    $servicePrincipal = Get-MgServicePrincipal -Filter $filter -ErrorAction SilentlyContinue | Select-Object -First 1
    $Cache.Add($cacheKey, $servicePrincipal)

    return $servicePrincipal
}

<#
.SYNOPSIS
    Creates or updates the Microsoft365DSC Entra application registration.

.DESCRIPTION
    This function creates or updates an application in Azure AD. It assigns permissions,
    grants consent and creates a secret or uploads a certificate to the application.

    This application can then be used for Application Authentication.

    With Type set to ManagedIdentity, the function assigns the permissions to an existing managed identity
    instead. It creates no application, grants no consent and creates no credential.

    The provided permissions have to be as an array of hashtables, with Api set to the name of the API
    owning the permission and PermissionName set to the permission itself. The Api value is any API name a
    resource settings file uses, such as 'Office 365 Exchange Online' or 'Azure Service Management', one of
    the Microsoft365DSC aliases 'Graph', 'SharePoint' and 'Exchange', or an application id. See examples for
    more information.

    NOTE:
    Please make sure you have the following permissions for the 'Microsoft Graph Command Line Tools'
    Enterprise Application in your tenant:

    - Application.ReadWrite.All

    You can add this scope to the 'Microsoft Graph Command Line Tools' Enterprise Application by running
    the following command:

    ```powershell
    Connect-MgGraph -Scopes 'Application.ReadWrite.All'
    ```

    NOTE:
    If consent cannot be given for whatever reason, make sure all these permissions are
    given Admin Consent by browsing to the App Registration in Azure AD > API Permissions
    and clicking the "Grant admin consent for <orgname>" button.

    More information:
    Graph API permissions: https://docs.microsoft.com/en-us/graph/permissions-reference
    Exchange permissions: https://docs.microsoft.com/en-us/exchange/permissions-exo/permissions-exo

    Note:
    If you want to configure App-Only permission for Exchange, as described here:
    https://docs.microsoft.com/en-us/powershell/exchange/app-only-auth-powershell-v2?view=exchange-ps#step-2-assign-api-permissions-to-the-application
    Using the following permission will achieve exactly that: @{Api='Exchange';PermissionsName='Exchange.ManageAsApp'}

    Note 2:
    If you want to configure App-Only permission for Security and compliance, please refer to this information on how to setup the permissions:
    https://microsoft365dsc.com/user-guide/get-started/authentication-and-permissions/#security-and-compliance-center-permissions

    Note 3:
    If you want to configure App-Only permission for Power Platform, please refer to this information on how to setup the permissions:
    https://microsoft365dsc.com/user-guide/get-started/authentication-and-permissions/#power-apps-permissions

.PARAMETER ApplicationName
    Specifies the application display name. With Type set to ManagedIdentity, specifies the display name,
    object id or client id of the managed identity.

.PARAMETER Permissions
    Specifies permission definitions to assign.

.PARAMETER Type
    Specifies whether the app should use a secret or certificate credential, or whether the permissions
    are assigned to an existing managed identity.

.PARAMETER MonthsValid
    Specifies the validity period in months for newly created credentials.

.PARAMETER CreateNewSecret
    Indicates that a new secret should be created when using secret mode.

.PARAMETER CertificatePath
    Specifies the certificate file path to upload or create.

.PARAMETER CreateSelfSignedCertificate
    If specified, a self-signed certificate will be created for the application. Once specified, -CertificatePath is required as well.
    The certificate is create in the Cert:\CurrentUser\My store and will be exported to the path specified in -CertificatePath.
    If you require the certificate with the private key, you can export it from the certificate store after running the command using the Export-PfxCertificate cmdlet.

.PARAMETER AdminConsent
    Indicates that admin consent flow should be executed.

.PARAMETER Credential
    Specifies delegated credentials used for interactive operations.

.PARAMETER ApplicationId
    Specifies the application id used for app-based authentication.

.PARAMETER TenantId
    Specifies the tenant id or tenant domain used for authentication.

.PARAMETER ApplicationSecret
    Specifies the application secret used for app-based authentication.

.PARAMETER CertificateThumbprint
    Specifies the certificate thumbprint used for app-based authentication.

.PARAMETER ManagedIdentity
    Indicates that managed identity authentication should be used.

.EXAMPLE
    PS> $creds = Get-Credential
    PS> Update-M365DSCAzureAdApplication -ApplicationName 'Microsoft365DSC' -Permissions @(@{Api='SharePoint';PermissionName='Sites.FullControl.All'}) -AdminConsent -Type Secret -Credential $creds

.EXAMPLE
    PS> $creds = Get-Credential
    PS> Update-M365DSCAzureAdApplication -ApplicationName 'Microsoft365DSC' -Permissions @(@{Api='Graph';PermissionName='Domain.Read.All'}) -AdminConsent  -Credential $creds -Type Certificate -CreateSelfSignedCertificate -CertificatePath c:\Temp\M365DSC.cer

.EXAMPLE
    PS> $creds = Get-Credential
    PS> Update-M365DSCAzureAdApplication -ApplicationName 'Microsoft365DSC' -Permissions @(@{Api='SharePoint';PermissionName='Sites.FullControl.All'},@{Api='Graph';PermissionName='Group.ReadWrite.All'},@{Api='Exchange';PermissionName='Exchange.ManageAsApp'}) -AdminConsent -Credential $creds -Type Certificate -CertificatePath c:\Temp\M365DSC.cer

.EXAMPLE
    PS> $creds = Get-Credential
    PS> Update-M365DSCAzureAdApplication -ApplicationName 'Microsoft365DSC' -Permissions $((Get-M365DSCCompiledPermissionList -ResourceNameList (Get-M365DSCAllResources) -PermissionType Application -AccessType Read).Permissions) -Type Certificate -CreateSelfSignedCertificate -AdminConsent -MonthsValid 12 -Credential $creds -CertificatePath c:\Temp\M365DSC.cer

.EXAMPLE
    PS> $creds = Get-Credential
    PS> Update-M365DSCAzureAdApplication -ApplicationName 'm365dsc-automation' -Permissions @(@{Api='Graph';PermissionName='Group.ReadWrite.All'},@{Api='Exchange';PermissionName='Exchange.ManageAsApp'}) -Type ManagedIdentity -Credential $creds

.FUNCTIONALITY
    Public
#>
function Update-M365DSCAzureAdApplication
{
    [CmdletBinding(DefaultParameterSetName = 'Secret')]
    param
    (
        [Parameter(ParameterSetName = 'Secret')]
        [Parameter(ParameterSetName = 'Certificate')]
        [System.String]
        $ApplicationName = 'Microsoft365DSC',

        [Parameter(Mandatory = $true, ParameterSetName = 'Secret')]
        [Parameter(Mandatory = $true, ParameterSetName = 'Certificate')]
        [System.Collections.Hashtable[]]
        $Permissions,

        [Parameter(ParameterSetName = 'Secret')]
        [Parameter(ParameterSetName = 'Certificate')]
        [ValidateSet('Secret', 'Certificate', 'ManagedIdentity')]
        [System.String]
        $Type = 'Secret',

        [Parameter(ParameterSetName = 'Secret')]
        [Parameter(ParameterSetName = 'Certificate')]
        [System.Int32]
        $MonthsValid = 12,

        [Parameter(ParameterSetName = 'Secret')]
        [Switch]
        $CreateNewSecret,

        [Parameter(ParameterSetName = 'Certificate')]
        [System.String]
        $CertificatePath,

        [Parameter(ParameterSetName = 'Certificate')]
        [Switch]
        $CreateSelfSignedCertificate,

        [Parameter(ParameterSetName = 'Secret')]
        [Parameter(ParameterSetName = 'Certificate')]
        [Switch]
        $AdminConsent,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $Credential,

        [Parameter()]
        [System.String]
        $ApplicationId,

        [Parameter()]
        [System.String]
        $TenantId,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $ApplicationSecret,

        [Parameter()]
        [System.String]
        $CertificateThumbprint,

        [Parameter()]
        [Switch]
        $ManagedIdentity
    )
    function Write-LogEntry
    {
        param
        (
            [Parameter(Mandatory = $true)]
            [System.String]
            $Message,

            [Parameter()]
            [ValidateSet('Error', 'Warning', 'Info')]
            [System.String]
            $Type = 'Info'
        )

        $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'

        switch ($Type)
        {
            'Error'
            {
                $params = @{
                    Object          = ('{0} - [ERROR] {1}' -f $timestamp, $Message)
                    ForegroundColor = 'Red'
                }
            }
            'Warning'
            {
                $params = @{
                    Object          = ('{0} - [WARNING] {1}' -f $timestamp, $Message)
                    ForegroundColor = 'Yellow'
                }
            }
            'Info'
            {
                $params = @{
                    Object          = ('{0} - {1}' -f $timestamp, $Message)
                    ForegroundColor = 'White'
                }
            }
        }

        Write-Host @params
    }

    Confirm-M365DSCDependencies

    $null = New-M365DSCConnection -Workload 'MicrosoftGraph' `
        -InboundParameters $PSBoundParameters

    $requireWait = $false
    Write-LogEntry -Message 'Checking specified parameters'
    switch ($Type)
    {
        'Secret'
        {
            Write-LogEntry -Message '  Using a Secret as credential'
        }
        'Certificate'
        {
            Write-LogEntry -Message '  Using a Certificate as credential'
            Write-LogEntry -Message ' '
            Write-LogEntry -Message '  Make sure your certificate has the following prerequisites:'
            Write-LogEntry -Message '    KeySpec           : Signature'
            Write-LogEntry -Message '    KeyLength         : 2048'
            Write-LogEntry -Message '    KeyAlgorithm      : RSA'
            Write-LogEntry -Message '    HashAlgorithm     : SHA256 or SHA1'
            Write-LogEntry -Message '    Enhanced Key Uses : Client Authentication and Server Authentication'
            Write-LogEntry -Message '    And the entire certificate chain is available!'
            Write-LogEntry -Message ' '

            if (-not $PSBoundParameters.ContainsKey('CertificatePath'))
            {
                if ($PSBoundParameters.ContainsKey('CreateSelfSignedCertificate'))
                {
                    # CreateSelfSignedCertificate is specified, but CertificatePath is missing.
                    Write-LogEntry -Message 'You have to specify CertificatePath, when specifying the CreateSelfSignedCertificate parameter.' -Type Error
                    return
                }
                else
                {
                    # Neither CertificatePath and CreateSelfSignedCertificate are specified.
                    Write-LogEntry -Message 'Certificate is specified as Type, but neither the CertificatePath or CreateSelfSignedCertificate parameters are specified.' -Type Error
                    return
                }
            }
            else
            {
                if ($PSBoundParameters.ContainsKey('CreateSelfSignedCertificate'))
                {
                    # CreateSelfSignedCertificate is specified and path specified in CertificatePath already exists.
                    if ((Test-Path -Path $CertificatePath) -eq $true)
                    {
                        Write-LogEntry -Message "Specified CertificatePath '$CertificatePath', where the Self Signed Certificate should be exported, already exists." -Type Error
                        return
                    }
                }
                else
                {
                    # CreateSelfSignedCertificate is NOT specified and path specified in CertificatePath does not exists.
                    if (-not (Test-Path -Path $CertificatePath))
                    {
                        Write-LogEntry -Message "Specified CertificatePath '$CertificatePath' does not exist." -Type Error
                        return
                    }
                }
            }
        }
        'ManagedIdentity'
        {
            Write-LogEntry -Message '  Assigning the permissions to a managed identity'
            if ($AdminConsent)
            {
                Write-LogEntry -Message '  AdminConsent is ignored because permissions assigned to a managed identity need no consent.' -Type Warning
            }
        }
    }

    if ($Type -eq 'ManagedIdentity')
    {
        Write-LogEntry ' '
        Write-LogEntry 'Checking existence of managed identity'
        $identityFilter = "servicePrincipalType eq 'ManagedIdentity' and displayName eq '$($ApplicationName -replace "'", "''")'"
        if ([System.Guid]::TryParse($ApplicationName, [ref][System.Guid]::Empty))
        {
            $identityFilter = "servicePrincipalType eq 'ManagedIdentity' and (id eq '$ApplicationName' or appId eq '$ApplicationName')"
        }

        $identities = @(Get-MgServicePrincipal -Filter $identityFilter -ErrorAction SilentlyContinue)
        if ($identities.Count -eq 0)
        {
            Write-LogEntry -Message "No managed identity '$ApplicationName' found." -Type Error
            return
        }
        if ($identities.Count -gt 1)
        {
            Write-LogEntry -Message "Multiple managed identities named '$ApplicationName' found. Specify the object id or client id of the managed identity instead." -Type Error
            return
        }

        $identity = $identities[0]
        Write-LogEntry "  Managed identity '$($identity.DisplayName)' found"

        Write-LogEntry ' '
        Write-LogEntry 'Checking managed identity permissions'
        $assignmentsUri = "/v1.0/servicePrincipals/$($identity.Id)/appRoleAssignments"
        $existingAssignments = Get-M365DSCRawGraphCollection -Uri $assignmentsUri
        $servicePrincipalCache = @{}
        foreach ($permission in $Permissions)
        {
            if ([System.String]::IsNullOrWhiteSpace($permission.Api) -or [System.String]::IsNullOrWhiteSpace($permission.PermissionName))
            {
                Write-LogEntry "Specified permission is invalid $(Convert-M365DscHashtableToString -Hashtable $permission)" -Type Warning
                continue
            }
            Write-LogEntry "  Checking permission '$($permission.Api)\$($permission.PermissionName)'"

            $svcprincipal = Get-M365DSCApiServicePrincipal -ApiName ($permission.Api) -Cache $servicePrincipalCache
            if ($null -eq $svcprincipal)
            {
                Write-LogEntry "    No service principal found for API '$($permission.Api)'. Grant '$($permission.PermissionName)' manually." -Type Warning
                continue
            }

            $appRoleId = ($svcprincipal.AppRoles | Where-Object -Property Value -EQ $permission.PermissionName).Id
            if ($null -eq $appRoleId -and [System.Guid]::TryParse($permission.PermissionName, [ref][System.Guid]::Empty))
            {
                $appRoleId = $permission.PermissionName
            }
            if ($null -eq $appRoleId)
            {
                Write-LogEntry "    API '$($permission.Api)' has no application permission '$($permission.PermissionName)'." -Type Warning
                continue
            }

            if ($null -ne ($existingAssignments | Where-Object -FilterScript { $_.resourceId -eq $svcprincipal.Id -and $_.appRoleId -eq $appRoleId }))
            {
                Write-LogEntry "    Permission '$($permission.Api)\$($permission.PermissionName)' already assigned to the managed identity!"
                continue
            }

            try
            {
                $null = Invoke-MgGraphRequest -Method POST -Uri $assignmentsUri -Body @{
                    principalId = $identity.Id
                    resourceId  = $svcprincipal.Id
                    appRoleId   = $appRoleId
                } -ErrorAction Stop
                Write-LogEntry "    Permission '$($permission.Api)\$($permission.PermissionName)' assigned to the managed identity"
            }
            catch
            {
                Write-LogEntry "    Error while assigning permission '$($permission.Api)\$($permission.PermissionName)': $($_.Exception.Message)" -Type Error
            }
        }

        Write-LogEntry ' '
        Write-LogEntry "Managed identity client id: $($identity.AppId)"
        Write-LogEntry ' '
        Write-LogEntry 'NOTE: Make sure you add the managed identity to the required Microsoft 365 (e.g. Global Admin) or Exchange (e.g. Organization Management) role groups as well!'
        Write-LogEntry '      See the documentation for any required permissions.'
        return
    }

    Write-LogEntry ' '
    Write-LogEntry 'Checking existence of AD Application'
    if (-not ($azureADApp = Get-MgApplication -Filter "DisplayName eq '$($ApplicationName -replace "'", "''")'" -ErrorAction SilentlyContinue))
    {
        $azureADApp = New-MgApplication -DisplayName $ApplicationName
        Write-LogEntry "  New Azure AD application '$ApplicationName' created!"
        $requireWait = $true
    }
    else
    {
        Write-LogEntry "  Application '$ApplicationName' already exists!"
    }

    if ($null -ne $azureADApp)
    {
        Write-LogEntry ' '
        Write-LogEntry 'Checking app permissions'
        $allRequiredAccess = @{}
        $servicePrincipalCache = @{}
        foreach ($permission in $Permissions)
        {
            if ([System.String]::IsNullOrWhiteSpace($permission.Api) -or [System.String]::IsNullOrWhiteSpace($permission.PermissionName))
            {
                Write-LogEntry "Specified permission is invalid $(Convert-M365DscHashtableToString -Hashtable $permission)" -Type Warning
                continue
            }
            Write-LogEntry "  Checking permission '$($permission.Api)\$($permission.PermissionName)'"

            $svcprincipal = Get-M365DSCApiServicePrincipal -ApiName ($permission.Api) -Cache $servicePrincipalCache
            if ($null -eq $svcprincipal)
            {
                Write-LogEntry "    No service principal found for API '$($permission.Api)'. Grant '$($permission.PermissionName)' manually." -Type Warning
                continue
            }

            $appRole = $azureADApp.AppRoles | Where-Object -Property Value -EQ $permission.PermissionName

            if ($null -eq $appRole)
            {
                $currentAPIAccess = $allRequiredAccess.($svcprincipal.AppId)

                if ($null -eq $currentAPIAccess)
                {
                    $allRequiredAccess.Add(($svcprincipal.AppId), @())
                }
                $role = $svcPrincipal.AppRoles | Where-Object -Property Value -EQ $permission.PermissionName
                if ($null -eq $role)
                {
                    if ([System.Guid]::TryParse($permission.PermissionName , [ref][System.Guid]::Empty))
                    {
                        $appPermission = @{
                            id   = $permission.PermissionName
                            type = 'Role'
                        }
                    }
                    else
                    {
                        continue
                    }
                }
                else
                {
                    $appPermission = @{
                        id   = $role.Id
                        type = 'Role'
                    }
                }
                $allRequiredAccess.($svcprincipal.AppId) += $appPermission
            }
            else
            {
                Write-LogEntry "    Permission '$($permission.Api)\$($permission.PermissionName)' already added to the application!"
            }
        }

        $requiredResourceAccess = @()
        foreach ($provider in $allRequiredAccess.Keys)
        {
            $valueToAdd = @{
                resourceAppId  = $provider
                resourceAccess = @()
            }

            foreach ($permissionEntry in $allRequiredAccess.$provider)
            {
                $permissionToAdd = @{
                    type = $permissionEntry.type
                    id   = $permissionEntry.id
                }
                $valueToAdd.resourceAccess += $permissionToAdd
            }
            $requiredResourceAccess += $valueToAdd
        }

        Update-MgApplication -ApplicationId ($azureADApp.Id) `
            -BodyParameter @{ requiredResourceAccess = $requiredResourceAccess } | Out-Null

        Write-LogEntry '    Permission updated for application'

        if ($AdminConsent)
        {
            if (-not $PSBoundParameters.ContainsKey('Credential'))
            {
                Write-LogEntry '[ERROR] You need to provide admin credentials when specifying the AdminConsent parameter.'
            }
            else
            {
                $null = New-M365DSCConnection -Workload 'MicrosoftGraph' `
                    -InboundParameters $PSBoundParameters
                if ($requireWait)
                {
                    Write-LogEntry ' '
                    Write-LogEntry 'Waiting 10 seconds for application creation'
                    Write-LogEntry '  ...'
                    Start-Sleep -Seconds 10
                }

                Write-LogEntry ' '
                Write-LogEntry 'Providing Admin Consent for application permissions'

                $currentConnectionProfile = Get-MSCloudLoginConnectionProfile -Workload 'MicrosoftGraph'
                $authorizationUrl = $currentConnectionProfile.AuthorizationUrl
                $tenantId = $Credential.GetNetworkCredential().UserName.Split('@')[-1]
                $token = Get-AuthToken -AuthorizationUrl $authorizationUrl `
                    -ClientId '1950a258-227b-4e31-a9cf-717495945fc2' `
                    -Scope '74658136-14ec-4630-ad9b-26e160ff0fc6/.default' `
                    -Credentials $Credential `
                    -TenantId $tenantId `
                    -DeviceCode

                $headers = @{
                    authorization            = "Bearer $($token.access_token)"
                    'x-ms-client-request-id' = [guid]::NewGuid().ToString()
                    'x-ms-client-session-id' = [guid]::NewGuid().ToString()
                }

                $applicationId = $azureADApp.AppId
                $url = "https://main.iam.ad.ext.azure.com/api/RegisteredApplications/$applicationId/Consent?onBehalfOfAll=true"
                try
                {
                    $null = Invoke-RestMethod -Uri $url -Headers $headers -Method POST -ErrorAction Stop
                    Write-LogEntry '  Admin Consent for application permissions provided'
                }
                catch
                {
                    Write-LogEntry '[ERROR] Error while providing consent to the requested permissions. Please make sure you provide consent via the Azure AD Admin Portal.' -Type Error
                    Write-LogEntry "Error details: $($_.Exception.Message)"
                }
            }
        }

        Write-LogEntry ' '
        Write-LogEntry 'Checking app credentials'
        $endDate = (Get-Date).AddMonths($MonthsValid)
        switch ($Type)
        {
            'Secret'
            {
                # Filtering retrieved credentials for PasswordCredentials
                $passwordCreds = $azureADApp.PasswordCredentials

                $createSecret = $false
                if ($passwordCreds.Count -eq 0)
                {
                    Write-LogEntry '  No app credentials found, creating new'
                    Write-LogEntry '    Creating App Secret'
                    $createSecret = $true
                }
                else
                {
                    if ($CreateNewSecret)
                    {
                        Write-LogEntry '  Existing app credentials found, but CreateNewSecret specified. Creating new secret!'
                        $createSecret = $true
                    }
                    else
                    {
                        Write-LogEntry '  Existing app credentials found, but CreateNewSecret not specified. Please use an existing secret!'
                    }
                }

                if ($createSecret)
                {
                    $passwordCred = @{
                        displayName = 'Created by Microsoft365DSC'
                        endDateTime = $endDate
                    }
                    $appCred = Add-MgBetaApplicationPassword -ApplicationId $azureADApp.Id -BodyParameter @{
                        passwordCredential = $passwordCred
                    }
                }
            }
            'Certificate'
            {
                $createCertificate = $false

                # Filtering retrieved credentials for CertificateCredentials
                $certCreds = $azureADApp.KeyCredentials

                if (($PSBoundParameters.ContainsKey('CertificatePath') -and (-not $CreateSelfSignedCertificate)))
                {
                    $cerCert = New-Object -TypeName System.Security.Cryptography.X509Certificates.X509Certificate2 -ArgumentList $CertificatePath
                }

                if ($certCreds.Count -eq 0)
                {
                    Write-LogEntry '  Uploading App Certificate'
                    $createCertificate = $true
                }
                else
                {
                    if ($PSBoundParameters.ContainsKey('CreateSelfSignedCertificate') -eq $false)
                    {
                        Write-LogEntry "  CertificatePath specified '$CertificatePath', using that certificate"
                        $certCred = $certCreds | Where-Object { $_.DisplayName -eq $cerCert.Subject -and $_.EndDateTime -eq $cerCert.NotAfter.ToUniversalTime() }
                        if ($null -eq $certCred)
                        {
                            Write-LogEntry '    Specified certificate does not exist in the app, uploading now'
                            $createCertificate = $true
                        }
                        else
                        {
                            Write-LogEntry '    Specified certificate already exists in the app, continuing'
                        }

                    }
                    else
                    {
                        Write-LogEntry 'Parameter CreateSelfSignedCertificate has been specified, but a Certificate has already been added to the application.' -Type Warning
                        Write-LogEntry 'Ignoring creating a new self signed certificate.' -Type Warning
                    }
                }

                if ($createCertificate)
                {
                    if ($CreateSelfSignedCertificate)
                    {
                        Write-LogEntry '    CreateSelfSignedCertificate specified, generating new Self Signed Certificate'
                        $cerCert = New-SelfSignedCertificate -CertStoreLocation 'Cert:\CurrentUser\My' `
                            -Subject "CN=$ApplicationName" `
                            -KeySpec Signature `
                            -NotAfter $endDate `
                            -KeyLength 2048 `
                            -KeyAlgorithm RSA `
                            -HashAlgorithm SHA256

                        $null = Export-Certificate -Cert $cerCert -Type CERT -FilePath $CertificatePath
                        Write-LogEntry "    Certificate exported to $CertificatePath"
                    }

                    Write-LogEntry "    Certificate details: $($cerCert.Subject) ($($cerCert.Thumbprint))"
                    $params = @()
                    $params += @{
                        type  = 'AsymmetricX509Cert'
                        usage = 'Verify'
                        key   = [System.Convert]::ToBase64String($cerCert.GetRawCertData())
                    }

                    $maxRetries = 3
                    $retryCount = 0
                    $retryDelay = 10 # seconds

                    do
                    {
                        try
                        {
                            $appCred = Update-MgApplication -ApplicationId $azureAdApp.Id -BodyParameter @{
                                keyCredentials = $params
                            } -ErrorAction Stop
                            break # exit the loop if the operation succeeds
                        }
                        catch
                        {
                            if ($_.Exception.Message -match 'Key credential end date is invalid')
                            {
                                Write-Error $($_.Exception.Message) -ErrorAction Continue
                                if ($retryCount -lt $maxRetries)
                                {
                                    $retryCount++
                                    Write-Host "Retrying in $retryDelay seconds..."
                                    Start-Sleep -Seconds $retryDelay
                                }
                                else
                                {
                                    Write-Host 'Maximum number of retries reached.'
                                    throw # re-throw the exception if the maximum number of retries is reached
                                }
                            }
                            else
                            {
                                throw # re-throw the exception if it's not the expected error
                            }
                        }
                    } while ($true)
                }
            }
        }

        Write-LogEntry ' '
        Write-LogEntry "Application Id: $($azureADapp.AppId)"

        if ($null -ne $appCred)
        {
            Write-LogEntry "Secret        : $($appCred.SecretText)"
            Write-LogEntry ' '
            Write-LogEntry 'IMPORTANT: A new secret has been created. This is only displayed once: Make sure you store this information!'
        }

        Write-LogEntry ' '
        Write-LogEntry 'NOTE: Make sure you add the application to the required Microsoft 365 (e.g. Global Admin) or Exchange (e.g. Organization Management) role groups as well!'
        Write-LogEntry '      See the documentation for any required permissions.'
    }
}

Export-ModuleMember -Function @(
    'Get-M365DSCCompiledPermissionList',
    'Update-M365DSCAllowedGraphScopes',
    'Update-M365DSCAzureAdApplication'
)
