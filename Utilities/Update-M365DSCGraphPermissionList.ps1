#Requires -Version 5.1

<#
.SYNOPSIS
    Refreshes the Microsoft Graph permission lists the settings.json QA test validates against.

.DESCRIPTION
    Reads the application permissions (app roles) and the delegated permissions (OAuth2 permission
    scopes) of the Microsoft Graph service principal and writes them, one name per line, to
    Tests/QA/Graph.ApplicationPermissionList.txt and Tests/QA/Graph.DelegatedPermissionList.txt.
    Requires a Microsoft Graph connection that can read service principals.

.PARAMETER RepositoryRoot
    Root of the Microsoft365DSC repository.

.EXAMPLE
    Connect-MgGraph -Scopes 'Application.Read.All'
    .\Update-M365DSCGraphPermissionList.ps1
#>
param
(
    [Parameter()]
    [System.String]
    $RepositoryRoot = (Split-Path -Path $PSScriptRoot -Parent)
)

$ErrorActionPreference = 'Stop'

$graphAppId = '00000003-0000-0000-c000-000000000000'
$response = Invoke-MgGraphRequest -Method GET -Uri "/v1.0/servicePrincipals?`$filter=appId eq '$graphAppId'&`$select=appRoles,oauth2PermissionScopes"
$servicePrincipal = $response.value | Select-Object -First 1
if ($null -eq $servicePrincipal)
{
    throw 'The Microsoft Graph service principal was not found in the connected tenant.'
}

$lists = @{
    'Graph.ApplicationPermissionList.txt' = @($servicePrincipal.appRoles | ForEach-Object -Process { $_.value })
    'Graph.DelegatedPermissionList.txt'   = @($servicePrincipal.oauth2PermissionScopes | ForEach-Object -Process { $_.value })
}

foreach ($list in $lists.GetEnumerator())
{
    $path = Join-Path -Path $RepositoryRoot -ChildPath "Tests/QA/$($list.Key)"
    $names = @($list.Value | Where-Object -FilterScript { -not [System.String]::IsNullOrEmpty($_) } | Sort-Object -Unique)
    Set-Content -Path $path -Value $names -Encoding ASCII
    Write-Host "Wrote $($names.Count) permissions to $path"
}
