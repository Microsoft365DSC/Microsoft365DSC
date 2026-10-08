# Compiles exported tenant configurations through the M365DSCFastHost-capable
# PSDesiredStateConfiguration engine when one is available (see
# docs/FastHostContract.md in the engine repository).

function Get-M365DSCDscEngineManifest
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param ()

    $installed = Get-Module -ListAvailable -Name M365DSC.PSDesiredStateConfiguration | Where-Object {
        $_.PrivateData.PSData.Tags -contains 'M365DSCFastHost'
    } | Sort-Object -Property Version -Descending | Select-Object -First 1
    if ($installed)
    {
        return $installed.Path
    }

    return $null
}

function Test-M365DSCFastCompileAvailable
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param ()

    $null -ne (Get-M365DSCDscEngineManifest)
}

function Import-M365DSCDscEngine
{
    [CmdletBinding()]
    param ()

    $manifest = Get-M365DSCDscEngineManifest
    if (-not $manifest)
    {
        throw 'No M365DSCFastHost-capable M365DSC.PSDesiredStateConfiguration engine was found.'
    }

    $manifestBase = Split-Path -Path $manifest -Parent
    $loaded = Get-Module -Name M365DSC.PSDesiredStateConfiguration |
        Where-Object -Property ModuleBase -EQ -Value $manifestBase

    if (-not $loaded)
    {
        Get-Module -Name M365DSC.PSDesiredStateConfiguration | Remove-Module -Force
        Import-Module -Name $manifest -Force -Global
    }
}

<#
.SYNOPSIS
    Compiles an exported Microsoft365DSC configuration script to MOF.

.DESCRIPTION
    Uses the fast compile host of the M365DSC.PSDesiredStateConfiguration engine when installed
    (seconds instead of minutes for class-based resources) and falls back
    to standard compilation otherwise.

.PARAMETER Path
    Path to the exported configuration script. Defaults to .\M365TenantConfig.ps1.

.PARAMETER ConfigurationDataPath
    Path to the configuration data .psd1. Defaults to ConfigurationData.psd1
    next to the configuration script when present.

.PARAMETER ConfigurationData
    Configuration data as an in-memory hashtable, for callers that do not have it on disk.
    Takes precedence over ConfigurationDataPath.

.PARAMETER ConfigurationName
    Name of the configuration to compile. Required when the script only declares a configuration
    instead of invoking one.

.PARAMETER Credential
    Credential forwarded to the configuration's -Credential parameter.

.PARAMETER CertificatePassword
    CertificatePassword forwarded to the configuration's -CertificatePassword parameter.

.PARAMETER Parameters
    Additional parameters splatted onto the configuration invocation.

.PARAMETER Engine
    Auto (default) uses the fast host when available; FastHost requires it;
    Standard always compiles through the standard configuration pipeline.

.PARAMETER OutputPath
    Folder for the generated MOF files.

.EXAMPLE
    Invoke-M365DSCConfigurationBuild -Path .\M365TenantConfig.ps1

.FUNCTIONALITY
    Public
#>
function Invoke-M365DSCConfigurationBuild
{
    [CmdletBinding()]
    [OutputType([System.IO.FileInfo])]
    param
    (
        [Parameter()]
        [System.String]
        $Path = '.\M365TenantConfig.ps1',

        [Parameter()]
        [System.String]
        $ConfigurationDataPath,

        [Parameter()]
        [System.Object]
        $ConfigurationData,

        [Parameter()]
        [System.String]
        $ConfigurationName,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $Credential,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $CertificatePassword,

        [Parameter()]
        [System.Collections.Hashtable]
        $Parameters,

        [Parameter()]
        [ValidateSet('Auto', 'FastHost', 'Standard')]
        [System.String]
        $Engine = 'Auto',

        [Parameter()]
        [System.String]
        $OutputPath
    )

    $Path = (Resolve-Path -Path $Path).ProviderPath
    if (-not $ConfigurationDataPath -and $null -eq $ConfigurationData)
    {
        $candidate = Join-Path -Path (Split-Path -Path $Path -Parent) -ChildPath 'ConfigurationData.psd1'
        if (Test-Path -Path $candidate)
        {
            $ConfigurationDataPath = $candidate
        }
    }

    $invokeParameters = @{}
    if ($Parameters)
    {
        $invokeParameters = $Parameters.Clone()
    }
    if ($Credential)
    {
        $invokeParameters['Credential'] = $Credential
    }
    if ($CertificatePassword)
    {
        $invokeParameters['CertificatePassword'] = $CertificatePassword
    }

    $useFastHost = $false
    switch ($Engine)
    {
        'FastHost'
        {
            Import-M365DSCDscEngine
            $useFastHost = $true
        }
        'Auto'
        {
            if (Test-M365DSCFastCompileAvailable)
            {
                Import-M365DSCDscEngine
                $useFastHost = $true
            }
            else
            {
                Write-Warning -Message 'No fast-compile-capable DSC engine found; compiling through the standard pipeline.'
            }
        }
        'Standard'
        {
            if (Test-M365DSCFastCompileAvailable)
            {
                Import-M365DSCDscEngine
            }
        }
    }

    if ($useFastHost)
    {
        $fastArguments = @{
            Path = $Path
        }
        if ($ConfigurationName)
        {
            $fastArguments['ConfigurationName'] = $ConfigurationName
        }
        if ($null -ne $ConfigurationData)
        {
            $fastArguments['ConfigurationData'] = $ConfigurationData
        }
        elseif ($ConfigurationDataPath)
        {
            $fastArguments['ConfigurationData'] = $ConfigurationDataPath
        }
        if ($invokeParameters.Count -gt 0)
        {
            $fastArguments['Parameters'] = $invokeParameters
        }
        if ($OutputPath)
        {
            $fastArguments['OutputPath'] = $OutputPath
        }
        return Invoke-DscFastCompile @fastArguments
    }

    # Standard pipeline: run the script itself. The recursion guard makes its
    # trailer take the plain invocation branch.
    $Global:PSDscFastCompileActive = $true
    try
    {
        $scriptDirectory = Split-Path -Path $Path -Parent
        Push-Location -Path $scriptDirectory
        try
        {
            if (-not $ConfigurationName)
            {
                return (& $Path @invokeParameters)
            }

            # The script only declares the configuration, so dot-source and invoke it.
            . $Path
            try
            {
                if ($OutputPath)
                {
                    $invokeParameters['OutputPath'] = $OutputPath
                }

                $data = if ($null -ne $ConfigurationData)
                {
                    $ConfigurationData
                }
                elseif ($ConfigurationDataPath)
                {
                    Import-PowerShellDataFile -Path $ConfigurationDataPath
                }
                else
                {
                    $null
                }

                if ($null -ne $data)
                {
                    $invokeParameters['ConfigurationData'] = $data
                }

                return (& $ConfigurationName @invokeParameters)
            }
            finally
            {
                Remove-Item -Path "function:$ConfigurationName" -Force -Recurse -ErrorAction 'SilentlyContinue'
            }
        }
        finally
        {
            Pop-Location
        }
    }
    finally
    {
        $Global:PSDscFastCompileActive = $false
    }
}

Export-ModuleMember -Function Invoke-M365DSCConfigurationBuild, Test-M365DSCFastCompileAvailable
