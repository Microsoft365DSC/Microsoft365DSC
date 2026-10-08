<#
.SYNOPSIS
    Reads what every resource says it was generated from.

.DESCRIPTION
    Identity is the folder name without the MSFT_ prefix. Three settings.json files carry a
    resourceName that differs from their folder.

.PARAMETER ResourcePath
    Specifies the folder holding the MSFT_<Name> resource folders.

.OUTPUTS
    One object per resource with Resource, Workload, ApiVersion, EntityType, ODataSubtype,
    CmdletNoun, CmdletVerb, IncludeNavigationProperties and Commands.
#>
function Get-ResourceOriginSurface
{
    [CmdletBinding()]
    [OutputType([System.Object[]])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $ResourcePath
    )

    $rows = @()

    foreach ($folder in (Get-ChildItem -Path $ResourcePath -Directory | Sort-Object -Property Name))
    {
        $settingsPath = Join-Path -Path $folder.FullName -ChildPath 'settings.json'
        if (-not (Test-Path -Path $settingsPath))
        {
            continue
        }

        $settings = Get-Content -Path $settingsPath -Raw | ConvertFrom-Json
        $origin = $settings.generatedFrom

        $commands = @()
        foreach ($entry in @($settings.commands))
        {
            if ($null -eq $entry -or [System.String]::IsNullOrEmpty($entry.module))
            {
                continue
            }

            foreach ($cmdlet in @($entry.cmdlets))
            {
                if ([System.String]::IsNullOrEmpty($cmdlet))
                {
                    continue
                }

                $commands += [PSCustomObject]@{
                    Module = [System.String] $entry.module
                    Name   = [System.String] $cmdlet
                }
            }
        }

        $rows += [PSCustomObject]@{
            Resource                    = $folder.Name -replace '^MSFT_', ''
            Workload                    = [System.String] $origin.workload
            ApiVersion                  = [System.String] $origin.apiVersion
            EntityType                  = [System.String] $origin.entityType
            ODataSubtype                = [System.String[]] @(@($origin.odataSubtype) | Where-Object { -not [System.String]::IsNullOrEmpty($_) })
            CmdletNoun                  = [System.String] $origin.cmdletNoun
            CmdletVerb                  = [System.String] $origin.cmdletVerb
            IncludeNavigationProperties = [System.Boolean] $origin.includeNavigationProperties
            Commands                    = $commands
        }
    }

    return $rows
}
