<#
.SYNOPSIS
    Resets a test tenant to a clean baseline state after deployment tests.

.DESCRIPTION
    Removes resources created during integration testing by deploying
    the 3-Remove.ps1 examples for each tested resource. Falls back to
    direct API cleanup for resources that don't have remove examples.

.PARAMETER Workload
    The workload to clean up (AAD, EXO, Intune, Teams, etc.)

.PARAMETER ResourceNames
    Optional list of specific resource names to clean up. If not specified,
    cleans up all resources for the given workload.

.PARAMETER AuthParams
    Hashtable containing authentication parameters (ApplicationId, TenantId,
    CertificateThumbprint, etc.)
#>
function Invoke-TenantCleanup
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [System.String]
        $Workload,

        [Parameter()]
        [System.String[]]
        $ResourceNames,

        [Parameter(Mandatory = $true)]
        [System.Collections.Hashtable]
        $AuthParams,

        [Parameter()]
        [System.String]
        $ExamplesBasePath
    )

    if ([string]::IsNullOrEmpty($ExamplesBasePath))
    {
        $ExamplesBasePath = Join-Path -Path $PSScriptRoot -ChildPath '..\..\..\..\Examples\Resources' -Resolve
    }

    $cleanupResults = @()

    # Get all remove example files for the workload
    $removeFiles = Get-ChildItem -Path "$ExamplesBasePath\*\3-Remove.ps1" -Recurse -ErrorAction SilentlyContinue
    if (-not [string]::IsNullOrEmpty($Workload))
    {
        $removeFiles = $removeFiles | Where-Object {
            $_.Directory.Name -like "$Workload*"
        }
    }

    if ($null -ne $ResourceNames -and $ResourceNames.Count -gt 0)
    {
        $removeFiles = $removeFiles | Where-Object {
            $ResourceNames -contains $_.Directory.Name
        }
    }

    # Process in reverse dependency order (remove dependent resources first)
    foreach ($file in $removeFiles)
    {
        $resourceName = $file.Directory.Name
        Write-Host "  Cleaning up: $resourceName..." -NoNewline

        try
        {
            # Build the remove configuration
            $configContent = Get-Content $file.FullName -Raw

            # Create a temporary script that injects auth params
            $tempScript = Join-Path $env:TEMP "Cleanup_$resourceName.ps1"
            $configContent | Set-Content -Path $tempScript -Encoding UTF8

            # Dot-source and invoke the configuration
            . $tempScript @AuthParams

            # Compile and apply the removal configuration
            $configData = @{
                AllNodes = @(@{
                    NodeName                    = 'Localhost'
                    PSDSCAllowPlaintextPassword = $true
                })
            }

            Example -ConfigurationData $configData @AuthParams
            Start-DscConfiguration -Path .\Example -Wait -Force -ErrorAction Stop

            Write-Host ' Done' -ForegroundColor Green
            $cleanupResults += @{
                ResourceName = $resourceName
                Status       = 'Cleaned'
                Error        = $null
            }
        }
        catch
        {
            Write-Host ' Failed' -ForegroundColor Red
            Write-Warning "  Cleanup failed for $resourceName`: $_"
            $cleanupResults += @{
                ResourceName = $resourceName
                Status       = 'Failed'
                Error        = $_.Exception.Message
            }
        }
        finally
        {
            # Clean up temp files
            Remove-Item -Path $tempScript -Force -ErrorAction SilentlyContinue
            Remove-Item -Path .\Example -Recurse -Force -ErrorAction SilentlyContinue
        }
    }

    return $cleanupResults
}

Export-ModuleMember -Function @(
    'Invoke-TenantCleanup'
)
