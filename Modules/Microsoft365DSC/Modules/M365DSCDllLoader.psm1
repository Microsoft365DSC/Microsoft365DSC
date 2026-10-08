<#
.SYNOPSIS
    Loads and initializes the Microsoft365DSC C# dll files.

.DESCRIPTION
    This module loads all of the Microsoft365DSC.*.dll at module import time.
    It provides fail-fast validation of .NET Framework version requirements and
    ensures that the necessary dll files are present and can be loaded successfully.

.NOTES
    The dll loader requires .NET Framework 4.7.2 or higher.
    The DLLs are located in the Dependencies/Assemblies directory relative to the module root.
#>

$Script:AssembliesInitialized = $false

<#
.SYNOPSIS
    Initializes the Microsoft365DSC C# dll files.

.DESCRIPTION
    Validates .NET Framework version requirements and loads the compiled C# dll files.
    This function is called by functions that require access to the Microsoft365DSC C# dll files.

.EXAMPLE
    PS> Initialize-M365DSCDllLoader
    Loads the dll files with standard version checks.

.OUTPUTS
    None.
#>
function Initialize-M365DSCDllLoader
{
    [CmdletBinding()]
    param()

    if ($Script:AssembliesInitialized)
    {
        Write-Debug -Message 'Microsoft365DSC C# dll files are already initialized.'
        return
    }

    try
    {
        if ($PSVersionTable.PSEdition -eq 'Desktop')
        {
            # Validate .NET Framework version (4.7.2 = Release 461808+)
            $netFrameworkVersion = Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full' -ErrorAction Stop
            $releaseKey = $netFrameworkVersion.Release

            if ($releaseKey -lt 461808)
            {
                $versionString = $netFrameworkVersion.Version
                $errorMessage = ".NET Framework 4.7.2 or higher is required for Microsoft365DSC C# dll files on Windows PowerShell. Current version: $versionString (Release: $releaseKey). Please install .NET Framework 4.7.2+ from https://dotnet.microsoft.com/download/dotnet-framework"

                throw $errorMessage
            }

            Write-Verbose -Message ".NET Framework version check passed (Release: $releaseKey)"
        }

        # Locate the accelerator DLL
        $moduleRoot = Split-Path -Path $PSScriptRoot -Parent
        $dllsToLoad = @(
            'Microsoft365DSC.Cache.dll'
            'Microsoft365DSC.Compare.dll'
            'Microsoft365DSC.Connection.dll'
            'Microsoft365DSC.Converter.dll'
            'Microsoft365DSC.Intune.dll'
            'Microsoft365DSC.Utilities.dll'
            'Microsoft365DSC.Relations.dll'
            'Microsoft365DSC.Reporting.dll'
        )

        foreach ($dllName in $dllsToLoad)
        {
            $dllPath = Join-Path -Path $moduleRoot -ChildPath "Dependencies/Assemblies/$dllName"
            if (-not (Test-Path -Path $dllPath))
            {
                $errorMessage = "$dllName not found at: $dllPath. Please run Utilities/Build-DllFiles.ps1 to build the dll file."
                Write-Warning $errorMessage

                $Script:AssembliesInitialized = $false
            }

            Write-Verbose -Message "Loading dll from: $dllPath"
        }

        # Load the assembly
        $loadedAssemblies = @()
        foreach ($dllName in $dllsToLoad)
        {
            $dllPath = Join-Path -Path $moduleRoot -ChildPath "Dependencies/Assemblies/$dllName"
            try
            {
                $loadedAssemblies += Add-Type -Path $dllPath -PassThru -ErrorAction Stop
            }
            catch
            {
                if ($_.Exception.Message -like "*Assembly with same name is already loaded*")
                {
                    Write-Verbose -Message "Assembly $dllName is already loaded. Skipping."
                }
                else
                {
                    throw "Failed to load assembly $($dllName): $($_.Exception.Message)"
                }
            }
        }

        foreach ($assembly in $loadedAssemblies)
        {
            Write-Verbose -Message "Loaded assembly: $($assembly.FullName)"
        }

        Write-Verbose -Message "Microsoft365DSC C# dll files loaded successfully."
        $Script:AssembliesInitialized = $true
    }
    catch
    {
        throw "Failed to initialize Microsoft365DSC C# dll files: $($_.Exception.Message)"
    }
}

Export-ModuleMember -Function Initialize-M365DSCDllLoader
