<#
.SYNOPSIS
    Loads and initializes the Microsoft365DSC C# dll files.

.DESCRIPTION
    This module provides Initialize-M365DSCDllLoader, which loads all of the Microsoft365DSC.*.dll
    files the first time a function that needs them calls it. It fails when a dll file is missing
    or cannot be loaded.

.NOTES
    The DLLs are located in the Dependencies/Assemblies directory relative to the module root.
#>

$Script:AssembliesInitialized = $false

<#
.SYNOPSIS
    Initializes the Microsoft365DSC C# dll files.

.DESCRIPTION
    Validates that the compiled C# dll files exist and loads the assemblies.
    This function is called by functions that require access to the Microsoft365DSC C# dll files.

.EXAMPLE
    PS> Initialize-M365DSCDllLoader
    Loads the dll files.

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
                throw "$dllName not found at: $dllPath. Please run Utilities/Build-DllFiles.ps1 to build the dll file."
            }

            Write-Verbose -Message "Loading dll from: $dllPath"
            try
            {
                Add-Type -Path $dllPath -ErrorAction Stop
                Write-Verbose -Message "Loaded assembly: $([System.Reflection.AssemblyName]::GetAssemblyName($dllPath).FullName)"
            }
            catch
            {
                if ($_.Exception.Message -notlike "*Assembly with same name is already loaded*")
                {
                    throw "$dllName could not be loaded from $($dllPath): $($_.Exception.Message)"
                }

                # Check if another copy of the assembly is loaded
                $expectedVersion = [System.Reflection.AssemblyName]::GetAssemblyName($dllPath).Version
                $assemblyName = [System.IO.Path]::GetFileNameWithoutExtension($dllName)
                $loadedAssembly = [System.AppDomain]::CurrentDomain.GetAssemblies() | `
                    Where-Object -FilterScript { $_.GetName().Name -eq $assemblyName } | `
                    Select-Object -First 1
                if ($null -ne $loadedAssembly -and $loadedAssembly.GetName().Version -ne $expectedVersion)
                {
                    Write-Warning -Message "$assemblyName version $($loadedAssembly.GetName().Version) is already loaded from $($loadedAssembly.Location), but version $expectedVersion is expected. Start a new PowerShell session to load the expected version."
                }
                else
                {
                    Write-Verbose -Message "Assembly $dllName is already loaded. Skipping."
                }
            }
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
