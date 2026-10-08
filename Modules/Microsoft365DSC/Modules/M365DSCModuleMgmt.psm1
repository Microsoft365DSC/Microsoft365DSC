$Script:IsPowerShellCore = $PSVersionTable.PSEdition -eq 'Core'
$Script:IsPsResourceGetAvailable = $null -ne (Get-Module -Name Microsoft.PowerShell.PSResourceGet -ListAvailable)
$Script:M365DSCDependenciesValidated = $false
$Script:M365DSCGraphShimLoaded = $false
$Script:M365DSCVerboseScopeDepth = 0

<#
.DESCRIPTION
    Reads every resource's settings.json, keyed by resource name without the MSFT_ prefix. A built
    module carries them folded into ResourcePermissions.json. The individual files are only opened
    in a working tree that has not been built yet.

.FUNCTIONALITY
    Internal
#>
function Import-M365DSCResourceSettings
{
    [CmdletBinding()]
    param()

    $settings = [System.Collections.Generic.Dictionary[System.String, System.Object]]::new([System.StringComparer]::OrdinalIgnoreCase)
    $aggregatePath = Join-Path -Path $PSScriptRoot -ChildPath '../ResourcePermissions.json'

    if (Test-Path -Path $aggregatePath)
    {
        $aggregate = [System.IO.File]::ReadAllText($aggregatePath) | ConvertFrom-Json
        foreach ($resource in $aggregate.PSObject.Properties)
        {
            $settings.Add($resource.Name, $resource.Value)
        }

        return , $settings
    }

    $dscResourcesFolder = Join-Path -Path $PSScriptRoot -ChildPath '../DscResources'
    if (-not (Test-Path -Path $dscResourcesFolder))
    {
        Write-Verbose -Message "Neither '$aggregatePath' nor '$dscResourcesFolder' exists, resource settings will be empty."
        return , $settings
    }

    Write-Verbose -Message "No aggregate at '$aggregatePath', reading each resource's settings.json instead."
    foreach ($file in (Get-ChildItem -Path $dscResourcesFolder -Filter 'settings.json' -Recurse -File))
    {
        $resourceName = (Split-Path -Path $file.DirectoryName -Leaf).Replace('MSFT_', '')
        $settings.Add($resourceName, ([System.IO.File]::ReadAllText($file.FullName) | ConvertFrom-Json))
    }

    return , $settings
}

<#
.DESCRIPTION
    This function performs the one-time initialization of the M365DSC dependency and resource-settings
    metadata used throughout this module. It is wrapped in a function (rather than run as top-level module
    code) so that the scratch/intermediate variables it uses are released once it returns, instead of being
    pinned for the lifetime of the session as module-scope variables.

.FUNCTIONALITY
    Internal
#>
function Initialize-M365DSCModuleMgmt
{
    [CmdletBinding()]
    param()

    if ($null -eq $Script:M365DSCDependencies)
    {
        $Script:M365DSCDependencies = [System.Collections.Generic.Dictionary[System.String, System.Object]]::new([System.StringComparer]::OrdinalIgnoreCase)
        $Script:M365DSCDevDependencies = [System.Collections.Generic.Dictionary[System.String, System.Object]]::new([System.StringComparer]::OrdinalIgnoreCase)
        $dependencies = (Import-PowerShellDataFile "$PSScriptRoot/../Dependencies/Manifest.psd1").Dependencies
        $devDependencies = (Import-PowerShellDataFile "$PSScriptRoot/../Dependencies/DevManifest.psd1").Dependencies
        foreach ($dependency in $dependencies)
        {
            # TODO: Review again once ModuleFast can work with additional properties
            # https://github.com/microsoft/Microsoft365DSC/pull/6726
            # https://github.com/ykuijs/M365DSC_CICD/issues/53
            if ($dependency.ModuleName -eq 'PnP.PowerShell')
            {
                $dependency.DependsOn = @('Microsoft.Graph.Authentication')
            }
            $Script:M365DSCDependencies.Add($dependency.ModuleName, $dependency)
        }

        foreach ($devDependency in $devDependencies)
        {
            $Script:M365DSCDevDependencies.Add($devDependency.ModuleName, $devDependency)
        }

        $commandToModuleMap = @{}
        $Script:M365DSCResourceSettings = [System.Collections.Generic.Dictionary[System.String, System.Object]]::new([System.StringComparer]::OrdinalIgnoreCase)
        $allResourceSettings = Import-M365DSCResourceSettings

        foreach ($entry in $allResourceSettings.GetEnumerator()) {
            $jsonContent = $entry.Value
            foreach ($commandMap in ($jsonContent.commands | Where-Object -Property module -NotIn $Script:M365DSCDevDependencies.Keys)) {
                $commandToModuleMap[$commandMap.module] += @($commandMap.cmdlets)
            }
            $Script:M365DSCResourceSettings.Add($entry.Key, @{
                requiredModules = $jsonContent.requiredModules | Where-Object { $_ -notin $Script:M365DSCDevDependencies.Keys }
                mode = $jsonContent.mode
            })
        }

        Write-Verbose -Message "Loading current configuration from config.json"
        $Script:M365DSCValidatedDependencies = [System.Collections.Generic.List[System.String]]::new($Script:M365DSCDependencies.Count + $Script:M365DSCDevDependencies.Count)
        $configAsPsCustomObject = Get-Content -Path "$PSScriptRoot/../config.json" | ConvertFrom-Json
        $configAsHashtable = @{}
        foreach ($property in $configAsPsCustomObject.PSObject.Properties)
        {
            $configAsHashtable.Add($property.Name, $property.Value)
        }
        $Script:CurrentConfiguration = $configAsHashtable
        $globalRequiredModules = $Script:CurrentConfiguration.requiredModules
        foreach ($entry in $commandToModuleMap.GetEnumerator())
        {
            $sortedFunctions = @($globalRequiredModules.$($entry.Key)) + @($entry.Value) | Sort-Object -Unique
            $Script:M365DSCDependencies[$entry.Key].Commands = $sortedFunctions
        }
        $Script:M365DSCRequiredModules = @($globalRequiredModules.psobject.Properties.Name)
        $Script:M365DSCRequiredModulesLoaded = $false
    }
}
Initialize-M365DSCModuleMgmt

<#
.SYNOPSIS
    Returns resource settings metadata loaded by module management.

.DESCRIPTION
    Returns the in-memory dictionary of resource settings built from each resource settings.json file.
#>
function Get-M365DSCResourceSettings
{
    [CmdletBinding()]
    param()

    return $Script:M365DSCResourceSettings
}

<#
.SYNOPSIS
    Returns one resource's settings.json content.

.DESCRIPTION
    Returns everything a resource declares about itself, being its permissions, roles, required
    modules, commands and mode. Returns $null for a resource the module carries no settings for.

.PARAMETER ResourceName
    Name of the resource, with or without its MSFT_ prefix.
#>
function Get-M365DSCResourceSetting
{
    [CmdletBinding()]
    [OutputType([System.Object])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $ResourceName
    )

    if ($null -eq $Script:M365DSCAllResourceSettings)
    {
        $Script:M365DSCAllResourceSettings = Import-M365DSCResourceSettings
    }

    $settings = $null
    $null = $Script:M365DSCAllResourceSettings.TryGetValue($ResourceName.Replace('MSFT_', ''), [ref] $settings)

    return $settings
}

<#
.SYNOPSIS
    Returns globally required module names for Microsoft365DSC.

.DESCRIPTION
    Returns the module names defined as required in the module configuration.
#>
function Get-M365DSCRequiredModules
{
    [CmdletBinding()]
    param()

    return $Script:M365DSCRequiredModules
}

<#
.SYNOPSIS
    Sets the required-modules-loaded state flag.

.DESCRIPTION
    Updates the module-scope flag used to track whether required modules were loaded in the current session.

.PARAMETER Value
    Specifies the new loaded state value.
#>
function Set-M365DSCRequiredModulesLoaded
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [System.Boolean]$Value
    )

    $Script:M365DSCRequiredModulesLoaded = $Value
}

<#
.SYNOPSIS
    Returns whether required modules are marked as loaded.

.DESCRIPTION
    Returns the module-scope boolean state indicating whether required modules were loaded.
#>
function Test-IsM365DSCRequiredModulesLoaded
{
    [CmdletBinding()]
    param()

    return $Script:M365DSCRequiredModulesLoaded
}

<#
.SYNOPSIS
    Returns the current Microsoft365DSC module configuration.

.DESCRIPTION
    Returns a cloned hashtable of the loaded module configuration values.

.OUTPUTS
    System.Collections.Hashtable
#>
function Get-M365DSCModuleConfiguration
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param()

    return $Script:CurrentConfiguration.Clone()
}

<#
.SYNOPSIS
    Updates a single Microsoft365DSC module configuration value.

.DESCRIPTION
    Sets a configuration entry in the current module configuration hashtable.

.PARAMETER Key
    Specifies the configuration key to update.

.PARAMETER Value
    Specifies the value to assign to the configuration key.
#>
function Set-M365DSCModuleConfiguration
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Key,

        [Parameter(Mandatory = $true)]
        [AllowEmptyCollection()]
        [AllowEmptyString()]
        [AllowNull()]
        [System.Object]
        $Value
    )

    $Script:CurrentConfiguration.$Key = $Value
}

<#
.SYNOPSIS
    Validates that required Microsoft365DSC dependencies are installed.

.DESCRIPTION
    Checks dependency health and throws when required module versions are missing.
    Validation can be skipped by session flags already used by Microsoft365DSC.

.FUNCTIONALITY
    Internal
#>
function Confirm-M365DSCDependencies
{
    [CmdletBinding()]
    param()

    if (-not $Script:M365DSCDependenciesValidated -and ($null -eq $Global:M365DSCSkipDependenciesValidation -or -not $Global:M365DSCSkipDependenciesValidation))
    {
        Write-Verbose -Message 'Dependencies were not already validated.'

        Test-CodePage
        $result = Update-M365DSCDependencies -ValidateOnly

        if ($result.Length -gt 0)
        {
            $ErrorMessage = "The following dependencies need updating:`r`n"
            foreach ($invalidDependency in $result)
            {
                $ErrorMessage += '    * ' + $invalidDependency.ModuleName + "`r`n"
            }
            $ErrorMessage += 'Please run Update-M365DSCDependencies as Administrator. '
            $Script:M365DSCDependenciesValidated = $false
            Add-M365DSCEvent -Message $ErrorMessage -EntryType 'Error' `
                -EventID 1 -Source $($MyInvocation.MyCommand.Source) `
                -TenantId $tenantIdValue
            throw $ErrorMessage
        }
        else
        {
            Write-Verbose -Message 'Dependencies were all successfully validated.'
            $Script:M365DSCDependenciesValidated = $true
        }
    }
    else
    {
        Write-Debug -Message 'Dependencies were already successfully validated.'
    }
}

<#
.SYNOPSIS
    Assigns $VerbosePreference inside a set of module scopes.

.DESCRIPTION
    Skips any scope that refuses the assignment instead of failing the caller.

.PARAMETER Scope
    Specifies the modules whose session state receives the value.

.PARAMETER Preference
    Specifies the value to assign.

.FUNCTIONALITY
    Internal
#>
function Set-M365DSCVerbosePreferenceInScope
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [AllowEmptyCollection()]
        [System.Management.Automation.PSModuleInfo[]]
        $Scope,

        [Parameter(Mandatory = $true)]
        [System.String]
        $Preference
    )

    $value = $Preference
    try
    {
        $value = [System.Management.Automation.ActionPreference] [System.Enum]::Parse(
            [System.Management.Automation.ActionPreference], $Preference, $true)
    }
    catch
    {
        $value = $Preference
    }

    foreach ($module in $Scope)
    {
        if ($null -eq $module.SessionState)
        {
            continue
        }

        try
        {
            $module.SessionState.PSVariable.Set('VerbosePreference', $value)
        }
        catch
        {
            continue
        }
    }
}

<#
.SYNOPSIS
    Confines the verbose stream to the Microsoft365DSC module scopes.

.DESCRIPTION
    Write-Verbose resolves $VerbosePreference through the scope chain of the module it runs in.
    Silencing the global scope and raising it again inside the Microsoft365DSC scopes keeps the
    messages Microsoft365DSC writes and drops those of every dependency.

    The ambient value comes from the global scope. The caller's own $VerbosePreference is unusable
    as the source because an outer call has already overridden it in every Microsoft365DSC scope.

    Restore levels the per-scope values with the global one. An optimized module scope refuses
    variable removal, so the values stay in place.

.PARAMETER Preference
    Specifies the preference the Microsoft365DSC scopes run with. Defaults to the global scope.

.PARAMETER ModuleName
    Specifies which module scopes keep the preference. Defaults to every Microsoft365DSC scope.

.PARAMETER Restore
    Specifies the previous preference to restore.

.EXAMPLE
    PS> $previous = Set-M365DSCVerboseScope
    PS> try { Invoke-Something } finally { $null = Set-M365DSCVerboseScope -Restore $previous }

.FUNCTIONALITY
    Internal

.OUTPUTS
    System.String
#>
function Set-M365DSCVerboseScope
{
    [CmdletBinding(DefaultParameterSetName = 'Apply')]
    [OutputType([System.String])]
    param(
        [Parameter(ParameterSetName = 'Apply')]
        [System.String]
        $Preference,

        [Parameter(ParameterSetName = 'Apply')]
        [System.String[]]
        $ModuleName,

        [Parameter(Mandatory = $true, ParameterSetName = 'Restore')]
        [AllowNull()]
        [System.String]
        $Restore
    )

    $rootModule = Get-Module -Name 'Microsoft365DSC'
    if ($null -eq $rootModule)
    {
        return $global:VerbosePreference
    }

    $scopes = @($rootModule) + @($rootModule.NestedModules)

    if ($PSCmdlet.ParameterSetName -eq 'Restore')
    {
        $Script:M365DSCVerboseScopeDepth--
        if ($Script:M365DSCVerboseScopeDepth -gt 0)
        {
            return $Restore
        }

        $global:VerbosePreference = $Restore
        Set-M365DSCVerbosePreferenceInScope -Scope $scopes -Preference $Restore
        return $Restore
    }

    if ($PSBoundParameters.ContainsKey('ModuleName') -and $ModuleName.Count -gt 0)
    {
        $scopes = $scopes | Where-Object -FilterScript { $ModuleName -contains $_.Name }
    }

    $Script:M365DSCVerboseScopeDepth++
    if ($Script:M365DSCVerboseScopeDepth -gt 1)
    {
        return $global:VerbosePreference
    }

    $previous = $global:VerbosePreference
    if (-not $PSBoundParameters.ContainsKey('Preference'))
    {
        $Preference = $previous
    }

    $global:VerbosePreference = 'SilentlyContinue'
    Set-M365DSCVerbosePreferenceInScope -Scope $scopes -Preference $Preference

    return $previous
}

<#
.SYNOPSIS
    Imports a module without its load-time output reaching the verbose stream.

.DESCRIPTION
    An imported module resolves $VerbosePreference from the global scope, so -Verbose:$false on
    Import-Module leaves every "Importing cmdlet" and "Exporting function" line in place. Lowering
    the global preference for the duration of the call is the only thing that silences them.

.PARAMETER Parameters
    Specifies the parameters to splat onto Import-Module.

.EXAMPLE
    PS> Import-M365DSCDependencyModule -Parameters @{ Name = 'Microsoft.Graph.Authentication' }

.FUNCTIONALITY
    Internal
#>
function Import-M365DSCDependencyModule
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [System.Collections.Hashtable]
        $Parameters
    )

    $VerbosePreference = 'SilentlyContinue'
    $previousVerbosePreference = $global:VerbosePreference
    $global:VerbosePreference = 'SilentlyContinue'
    try
    {
        Import-Module @Parameters
    }
    finally
    {
        $global:VerbosePreference = $previousVerbosePreference
    }
}

<#
.SYNOPSIS
    Serves Microsoft.Identity.Client to PnP.PowerShell from a dedicated load context.

.DESCRIPTION
    Registers a Default.Resolving handler that loads the Microsoft.Identity.Client assemblies of the
    PnP.PowerShell folder into a dedicated load context. The handler only answers when the default
    load context already holds another version. Must run before PnP.PowerShell is imported.

.PARAMETER ModuleBase
    Specifies the folder of the PnP.PowerShell version that is imported. Defaults to the version
    the dependency manifest requires.

.EXAMPLE
    PS> Register-M365DSCPnPIdentityClientResolver

.FUNCTIONALITY
    Internal
#>
function Register-M365DSCPnPIdentityClientResolver
{
    [CmdletBinding()]
    param(
        [Parameter()]
        [System.String]
        $ModuleBase
    )

    # TODO: Remove once https://github.com/pnp/powershell/pull/5480 and new PnP.PowerShell version is released
    if ($PSEdition -ne 'Core' -or $Script:M365DSCPnPIdentityClientResolverRegistered)
    {
        return
    }

    if ([System.String]::IsNullOrEmpty($ModuleBase))
    {
        $requiredVersion = $Script:M365DSCDependencies['PnP.PowerShell'].RequiredVersion
        $pnpModule = Get-Module -Name 'PnP.PowerShell' -ListAvailable | Where-Object -FilterScript { $_.Version -eq $requiredVersion } | Select-Object -First 1
        if ($null -eq $pnpModule)
        {
            Write-Verbose -Message "PnP.PowerShell $requiredVersion is not installed. The PnP.PowerShell resolver workaround is not registered."
            return
        }
        $ModuleBase = $pnpModule.ModuleBase
    }

    $dependencyPath = Join-Path -Path $ModuleBase -ChildPath 'Common'
    if (-not (Test-Path -Path (Join-Path -Path $dependencyPath -ChildPath 'Microsoft.Identity.Client.dll')))
    {
        Write-Verbose -Message "No Microsoft.Identity.Client found under '$dependencyPath'. The PnP.PowerShell resolver workaround is not registered."
        return
    }

    if ($null -eq ('Microsoft365DSC.Workarounds.PnPIdentityClientResolver' -as [System.Type]))
    {
        Add-Type -Language CSharp -TypeDefinition @"
using System;
using System.IO;
using System.Reflection;
using System.Runtime.Loader;
using System.Threading;

namespace Microsoft365DSC.Workarounds
{
    public static class PnPIdentityClientResolver
    {
        private static readonly object s_gate = new object();
        private static string s_dependencyPath;
        private static AssemblyLoadContext s_context;
        private static int s_registered;

        public static void Register(string dependencyPath)
        {
            s_dependencyPath = dependencyPath;
            if (Interlocked.Exchange(ref s_registered, 1) == 0)
            {
                AssemblyLoadContext.Default.Resolving += Resolve;
            }
        }

        private static Assembly Resolve(AssemblyLoadContext context, AssemblyName assemblyName)
        {
            string name = assemblyName == null ? null : assemblyName.Name;
            if (string.IsNullOrEmpty(name) || !name.StartsWith("Microsoft.Identity.Client", StringComparison.OrdinalIgnoreCase))
            {
                return null;
            }

            string candidate = Path.Combine(s_dependencyPath, name + ".dll");
            if (!File.Exists(candidate) || !IsLoadedInDefaultContext(name))
            {
                return null;
            }

            if (assemblyName.Version != null && !assemblyName.Version.Equals(AssemblyName.GetAssemblyName(candidate).Version))
            {
                return null;
            }

            lock (s_gate)
            {
                if (s_context == null)
                {
                    s_context = new AssemblyLoadContext("Microsoft365DSC.PnP.IdentityClient", false);
                }

                foreach (Assembly loaded in s_context.Assemblies)
                {
                    if (string.Equals(loaded.GetName().Name, name, StringComparison.OrdinalIgnoreCase))
                    {
                        return loaded;
                    }
                }

                return s_context.LoadFromAssemblyPath(candidate);
            }
        }

        private static bool IsLoadedInDefaultContext(string name)
        {
            foreach (Assembly assembly in AssemblyLoadContext.Default.Assemblies)
            {
                if (string.Equals(assembly.GetName().Name, name, StringComparison.OrdinalIgnoreCase))
                {
                    return true;
                }
            }

            return false;
        }
    }
}
"@
    }

    [Microsoft365DSC.Workarounds.PnPIdentityClientResolver]::Register($dependencyPath)
    $Script:M365DSCPnPIdentityClientResolverRegistered = $true
    Write-Verbose -Message "Registered the PnP.PowerShell Microsoft.Identity.Client resolver for '$dependencyPath'."
}

<#
.SYNOPSIS
    Ensures a dependency module is loaded at the required version.

.DESCRIPTION
    Loads dependency modules on demand, validates versions, and recursively validates dependency chains.
    For Graph typed modules, it applies the Microsoft365DSC Graph shim behavior.

.PARAMETER ModuleName
    Specifies the dependency module name to validate and load.

.EXAMPLE
    PS> Confirm-M365DSCLoadedModule -ModuleName 'Microsoft.Graph.Authentication'

.FUNCTIONALITY
    Internal
#>
function Confirm-M365DSCLoadedModule
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [System.String]
        $ModuleName
    )

    if ($Script:M365DSCValidatedDependencies.Contains($ModuleName))
    {
        Write-Verbose -Message "Module '$ModuleName' has already been validated."
        return
    }

    # Graph Shim intercept: Replace typed Graph SDK
    # sub-modules with the lightweight M365DSCGraphShim module that wraps
    # Invoke-MgGraphRequest. Microsoft.Graph.Authentication is always loaded
    # natively because it provides Connect-MgGraph and the underlying HTTP client.
    if ($ModuleName -like 'Microsoft.Graph.*' -and
        $ModuleName -ne 'Microsoft.Graph.Authentication')
    {
        if (-not $Script:M365DSCGraphShimLoaded)
        {
            Write-Verbose -Message "Graph Shim enabled: importing M365DSCGraphShim instead of '$ModuleName'."
            # Ensure Microsoft.Graph.Authentication is loaded first
            Confirm-M365DSCLoadedModule -ModuleName 'Microsoft.Graph.Authentication'

            Import-M365DSCDependencyModule -Parameters @{
                Name                = "$PSScriptRoot/M365DSCGraphShim.psd1"
                Global              = $true
                Force               = $true
                DisableNameChecking = $true
                Function            = '*'
                Cmdlet              = @()
                Variable            = @()
                Alias               = @()
            }
            $Script:M365DSCGraphShimLoaded = $true
        }
        else
        {
            Write-Verbose -Message "Graph Shim already loaded, skipping import for '$ModuleName'."
        }

        $Script:M365DSCValidatedDependencies.Add($ModuleName)
        return
    }

    $manifestModule = $Script:M365DSCDependencies[$ModuleName]

    if ($null -ne $manifestModule.DependsOn -and $manifestModule.DependsOn.Count -gt 0)
    {
        foreach ($dependency in $manifestModule.DependsOn)
        {
            Write-Verbose -Message "Validating dependency '$dependency' for module '$ModuleName'."
            Confirm-M365DSCLoadedModule -ModuleName $dependency
        }
    }

    $loadedModule = Get-Module -Name $ModuleName
    if ($ModuleName -eq 'PnP.PowerShell' -and ($null -eq $loadedModule -or $loadedModule.Version -ne $manifestModule.RequiredVersion))
    {
        Register-M365DSCPnPIdentityClientResolver
    }

    $importModuleSplat = @{
        Name                = $ModuleName
        RequiredVersion     = $manifestModule.RequiredVersion
        Global              = $true
        Alias               = @()
        Cmdlet              = @()
        Variable            = @()
        DisableNameChecking = $true
    }

    if ($manifestModule.Commands.Count -gt 0)
    {
        $importModuleSplat.Add('Function', $manifestModule.Commands)
        $importModuleSplat.Cmdlet = $manifestModule.Commands
    }

    if ($null -eq $loadedModule)
    {
        Write-Verbose -Message "Module '$ModuleName' is not loaded. Importing it now."
        Import-M365DSCDependencyModule -Parameters $importModuleSplat
        Write-Verbose -Message "Module '$ModuleName' with version '$($manifestModule.RequiredVersion)' has been imported."
    }
    elseif ($loadedModule.Version -ne $manifestModule.RequiredVersion)
    {
        Write-Verbose -Message "Module '$ModuleName' is loaded but the version '$($loadedModule.Version)' does not match the required version '$($manifestModule.RequiredVersion)'."
        Remove-Module -Name $ModuleName -Force -ErrorAction SilentlyContinue
        Write-Verbose -Message "Unloaded module '$ModuleName' with version '$($loadedModule.Version)'."
        Import-M365DSCDependencyModule -Parameters $importModuleSplat
        Write-Verbose -Message "Re-imported module '$ModuleName' with version '$($manifestModule.RequiredVersion)'."
    }
    else
    {
        Write-Verbose -Message "Module '$ModuleName' is already loaded."
    }

    if (-not $Script:M365DSCValidatedDependencies.Contains($ModuleName))
    {
        $Script:M365DSCValidatedDependencies.Add($ModuleName)
    }
}

<#
.SYNOPSIS
    Validates dependencies required by a DSC resource module.

.DESCRIPTION
    Resolves required modules from resource settings and validates each dependency before resource execution.

.PARAMETER ModuleName
    Specifies the DSC resource module name whose dependencies should be validated.

.EXAMPLE
    PS> Confirm-M365DSCModuleDependency -ModuleName 'MSFT_AADApplication'

.FUNCTIONALITY
    Internal
#>
function Confirm-M365DSCModuleDependency
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [System.String]
        $ModuleName
    )

    $Global:MaximumFunctionCount = 32767

    if ($Global:IsTestEnvironment -or (Get-M365DSCModuleConfiguration).skipModuleDependencyValidation)
    {
        Write-Verbose -Message "Skipping module dependency validation in test environment for module '$ModuleName'."
        return
    }

    $modulesToCheck = $Script:M365DSCResourceSettings[$ModuleName.Replace('MSFT_', '')].requiredModules
    foreach ($module in $modulesToCheck)
    {
        Write-Verbose -Message "Validating module dependency: $($module)"
        Confirm-M365DSCLoadedModule -ModuleName $module
    }
    Write-Verbose -Message "All dependencies for module '$ModuleName' have been validated."
}

<#
.SYNOPSIS
    Checks whether newer versions exist for configured dependencies.

.DESCRIPTION
    Queries the gallery for each configured dependency and reports modules with newer available versions.

.EXAMPLE
    PS> Test-M365DSCDependenciesForNewVersions

.FUNCTIONALITY
    Public
#>
function Test-M365DSCDependenciesForNewVersions
{
    [CmdletBinding()]
    param ()

    $i = 1
    Import-Module PowerShellGet -Force

    foreach ($dependency in $Script:M365DSCDependencies.Values.GetEnumerator())
    {
        Write-Progress -Activity 'Scanning Dependencies' -PercentComplete ($i / $Script:M365DSCDependencies.Count * 100)
        try
        {
            $moduleInGallery = Find-Module $dependency.ModuleName
            [array]$moduleInstalled = Get-Module $dependency.ModuleName -ListAvailable | Select-Object Version
            if ($moduleInstalled)
            {
                $modules = $moduleInstalled | Sort-Object Version -Descending
            }
            $moduleInstalled = $modules[0]
            if (-not $modules -or [Version]($moduleInGallery.Version) -gt [Version]($moduleInstalled[0].Version))
            {
                Write-Host "New version of {$($dependency.ModuleName)} is available {$($moduleInGallery.Version)}"
            }
        }
        catch
        {
            Write-Host $_
            Write-Host "New version of {$($dependency.ModuleName)} is available"
        }
        $i++
    }

    # The progress bar seems to hang sometimes. Make sure it is no longer displayed.
    Write-Progress -Activity 'Scanning Dependencies' -Completed
}

<#
.SYNOPSIS
    Validates the installed Microsoft365DSC module version.

.DESCRIPTION
    Compares local and gallery module versions and reports when a newer Microsoft365DSC module is available.


.EXAMPLE
    PS> Test-M365DSCModuleValidity

.FUNCTIONALITY
    Public
#>
function Test-M365DSCModuleValidity
{
    [CmdletBinding()]
    param()

    if ($Script:IsM365DSCModuleValidated)
    {
        Write-Verbose -Message 'The Microsoft365DSC module has already been validated in this session.'
        Write-Verbose -Message 'If you have updated the module, please restart your PowerShell session to re-validate.'
        return
    }

    if ($env:AZUREPS_HOST_ENVIRONMENT -like 'AzureAutomation*')
    {
        $message = 'Skipping check for newer version of Microsoft365DSC due to Azure Automation Environment restrictions.'
        Write-Verbose -Message $message
        return
    }

    # Validate if only one installation of the module is present and that it's the latest version available
    if ($Script:IsPsResourceGetAvailable)
    {
        $latestVersion = (Find-PSResource -Name 'Microsoft365DSC' -Repository 'PSGallery').Version | Sort-Object -Descending | Select-Object -First 1
    }
    else
    {
        $latestVersion = (Find-Module -Name 'Microsoft365DSC' -Includes 'DSCResource').Version
    }
    $localVersion = (Get-Module -Name 'Microsoft365DSC').Version

    if ($latestVersion -gt $localVersion)
    {
        Write-Host "There is a newer version of the 'Microsoft365DSC' module available on the gallery."
        Write-Host "To update the module and it's dependencies, run the following command:"
        Write-Host 'Update-M365DSCModule' -ForegroundColor Blue
    }

    $Script:IsM365DSCModuleValidated = $true
}

<#
.SYNOPSIS
    Removes outdated Microsoft365DSC module and dependency versions.

.DESCRIPTION
    Scans installed module versions and removes outdated Microsoft365DSC and dependency versions while preserving required versions.

.EXAMPLE
    PS> Uninstall-M365DSCOutdatedDependencies

.FUNCTIONALITY
    Public
#>
function Uninstall-M365DSCOutdatedDependencies
{
    [CmdletBinding()]
    param()

    try
    {
        $InformationPreference = 'Continue'

        [array]$microsoft365DscModules = Get-Module Microsoft365DSC -ListAvailable
        $outdatedMicrosoft365DscModules = $microsoft365DscModules | Sort-Object -Property Version | Select-Object -SkipLast 1

        foreach ($module in $outdatedMicrosoft365DscModules)
        {
            try
            {
                Write-Information -MessageData "Uninstalling $($module.Name) Version {$($module.Version)}"
                if (Test-Path -Path $($module.Path))
                {
                    Remove-Item $($module.ModuleBase) -Force -Recurse -ErrorAction Stop
                }
            }
            catch
            {
                $message = "Could not uninstall $($module.Name) Version $($module.Version)"
                if ($_.Exception.Message -like "*Access to the path* is denied*" -and ($Scope -eq "AllUsers") -and ($PSEdition -eq 'Desktop' -or $IsWindows) -and -not
                    ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
                {
                    $message += ' You need to run this command as a local administrator.'
                }
                New-M365DSCLogEntry -Message $message `
                    -Exception $_ `
                    -Source $($MyInvocation.MyCommand.Source)
                Write-Error -Message $message -ErrorAction Continue
            }
        }

        $allDependenciesExceptAuth = $Script:M365DSCDependencies.Values.GetEnumerator().Where({ $_.ModuleName -ne 'Microsoft.Graph.Authentication' })

        $i = 1
        foreach ($dependency in $allDependenciesExceptAuth)
        {
            Write-Progress -Activity 'Scanning Dependencies' -PercentComplete ($i / $allDependenciesExceptAuth.Count * 100)
            try
            {
                if ($dependency.PowerShellCore -and -not $Script:IsPowerShellCore)
                {
                    Write-Verbose -Message "Skipping module {$($dependency.ModuleName)} as it is managed by PowerShell Core."
                    continue
                }
                elseif ($dependency.PowerShellCore -eq $false -and $Script:IsPowerShellCore)
                {
                    Write-Verbose -Message "Skipping module {$($dependency.ModuleName)} as it is managed by Windows PowerShell."
                    continue
                }
                $found = Get-Module $dependency.ModuleName -ListAvailable | Where-Object -Property Version -NE $dependency.RequiredVersion
                foreach ($foundModule in $found)
                {
                    try
                    {
                        Write-Information -MessageData "Uninstalling $($foundModule.Name) Version {$($foundModule.Version)}"
                        if (Test-Path -Path $($foundModule.Path))
                        {
                            Remove-Item $($foundModule.ModuleBase) -Force -Recurse -ErrorAction Stop
                        }
                    }
                    catch
                    {
                        $message = "Could not uninstall $($foundModule.Name) Version $($foundModule.Version)"
                        if ($_.Exception.Message -like "*Access to the path* is denied*" -and ($PSEdition -eq 'Desktop' -or $IsWindows) -and
                            ($Scope -eq "AllUsers") -and -not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
                        {
                            $message += ' You need to run this command as a local administrator.'
                        }
                        New-M365DSCLogEntry -Message $message `
                            -Exception $_ `
                            -Source $($MyInvocation.MyCommand.Source)
                        Write-Error -Message $message -ErrorAction Continue
                    }
                }
            }
            catch
            {
                Write-Error -Message "Could not uninstall {$($dependency.ModuleName)}" -ErrorAction Continue
            }
            $i++
        }
    }
    catch
    {
        New-M365DSCLogEntry -Message 'Error uninstalling outdated dependencies:' `
            -Exception $_ `
            -Source $($MyInvocation.MyCommand.Source)
        Write-Error $_
    }

    $authModule = $Script:M365DSCDependencies['Microsoft.Graph.Authentication']
    try
    {
        Write-Information -MessageData 'Checking Microsoft.Graph.Authentication'
        $found = Get-Module $authModule.ModuleName -ListAvailable | Where-Object -Property Version -NE $authModule.RequiredVersion
        foreach ($foundModule in $found)
        {
            try
            {
                Write-Information -MessageData "Uninstalling $($foundModule.Name) version {$($foundModule.Version)}"
                if (Test-Path -Path $($foundModule.Path))
                {
                    Remove-Item $($foundModule.ModuleBase) -Force -Recurse -ErrorAction Stop
                }
            }
            catch
            {
                $message = "Could not uninstall $($foundModule.Name) Version $($foundModule.Version)"
                if ($_.Exception.Message -like "*Access to the path* is denied*" -and ($PSEdition -eq 'Desktop' -or $IsWindows) -and
                    ($Scope -eq "AllUsers") -and -not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
                {
                    $message += ' You need to run this command as a local administrator.'
                }
                New-M365DSCLogEntry -Message $message `
                    -Exception $_ `
                    -Source $($MyInvocation.MyCommand.Source)
                Write-Error -Message $message -ErrorAction Continue
            }
        }
    }
    catch
    {
        Write-Error -Message "Could not uninstall {$($dependency.ModuleName)}" -ErrorAction Continue
    }
}

<#
.SYNOPSIS
    Determines whether a module version is present on the module path.

.DESCRIPTION
    Probes every PSModulePath root for the manifest of the requested module version. This answers the
    common case without enumerating the metadata of every installed module.

.PARAMETER ModuleName
    Specifies the name of the module to look for.

.PARAMETER RequiredVersion
    Specifies the version the module directory must carry.

.FUNCTIONALITY
    Internal

.OUTPUTS
    System.Boolean
#>
function Test-M365DSCDependencyManifestPath
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $ModuleName,

        [Parameter(Mandatory = $true)]
        [System.String]
        $RequiredVersion
    )

    if ($null -eq $Script:M365DSCModulePathRoots)
    {
        $Script:M365DSCModulePathRoots = @($env:PSModulePath -split [System.IO.Path]::PathSeparator |
                Where-Object -FilterScript { -not [System.String]::IsNullOrWhiteSpace($_) })
    }

    foreach ($root in $Script:M365DSCModulePathRoots)
    {
        if (Test-Path -Path (Join-Path -Path $root -ChildPath "$ModuleName\$RequiredVersion\$ModuleName.psd1"))
        {
            return $true
        }
    }

    return $false
}

<#
.SYNOPSIS
    Installs or validates Microsoft365DSC dependencies.

.DESCRIPTION
    Validates, installs, or force-refreshes dependency modules according to manifest requirements and selected installation options.

.PARAMETER Force
    Indicates that dependencies should be reinstalled even when required versions are present.

.PARAMETER ValidateOnly
    Indicates that only validation should run and missing dependencies should be returned.

.PARAMETER Scope
    Specifies the installation scope for dependency modules.

.PARAMETER Proxy
    Specifies the proxy server used for module installation requests.

.PARAMETER Repository
    Specifies the repository used to install dependencies.

.PARAMETER UsePowerShellGet
    Indicates that Install-Module should be used instead of Install-PSResource.

.PARAMETER Development
    Indicates that development dependencies should also be processed.

.EXAMPLE
    PS> Update-M365DSCDependencies

.EXAMPLE
    PS> Update-M365DSCDependencies -Force

.EXAMPLE
    PS> Update-M365DSCDependencies -Scope CurrentUser

.FUNCTIONALITY
    Public
#>
function Update-M365DSCDependencies
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [Switch]
        $Force,

        [Parameter()]
        [Switch]
        $ValidateOnly,

        [Parameter()]
        [ValidateSet("CurrentUser", "AllUsers")]
        $Scope = "AllUsers",

        [Parameter()]
        [System.String]
        $Proxy,

        [Parameter()]
        [System.String]
        $Repository = 'PSGallery',

        [Parameter()]
        [switch]
        $UsePowerShellGet,

        [Parameter()]
        [Switch]
        $Development
    )

    try
    {
        $InformationPreference = 'Continue'
        $i = 1

        $returnValue = @()

        $params = @{}
        if (-not [System.String]::IsNullOrEmpty($Proxy))
        {
            $params.Add('Proxy', $Proxy)
        }

        # Check if PSResourceGet is installed or not
        if (-not $Script:IsPsResourceGetAvailable)
        {
            Write-Warning -Message 'Microsoft.PowerShell.PSResourceGet is not installed, installing it now...'
            try
            {
                Install-Module -Name Microsoft.PowerShell.PSResourceGet -Scope $Scope -AllowClobber @params -Force -ErrorAction Stop -Repository PSGallery
                $Script:IsPsResourceGetAvailable = $true
            }
            catch
            {
                Write-Warning -Message "Failed to install Microsoft.PowerShell.PSResourceGet, continuing without it..."
            }
        }

        $scopedIsPsResourceGetAvailable = $Script:IsPsResourceGetAvailable
        if ($params.ContainsKey('Proxy'))
        {
            Write-Information -MessageData "Falling back to Install-Module because Install-PSResource does not support a proxy"
            $scopedIsPsResourceGetAvailable = $false
        }

        $dependencies = [System.Object[]]::new($Script:M365DSCDependencies.Count + $Script:M365DSCDevDependencies.Count)
        $Script:M365DSCDependencies.Values.CopyTo($dependencies, 0)
        if ($Development)
        {
            $Script:M365DSCDevDependencies.Values.CopyTo($dependencies, $Script:M365DSCDependencies.Count)
        }

        # $null comparison is correct in that way because the left-hand side is always an array and the right-hand side is a single value
        foreach ($dependency in ($dependencies -ne $null))
        {
            if (-not $ValidateOnly)
            {
                Write-Progress -Activity 'Scanning dependencies' -PercentComplete ($i / $dependencies.Count * 100)
            }
            try
            {
                if (-not $Force)
                {
                    if ($dependency.PowerShellCore -and -not $Script:IsPowerShellCore)
                    {
                        Write-Verbose -Message "The dependency {$($dependency.ModuleName)} requires PowerShell Core. Skipping."
                        continue
                    }
                    elseif ($dependency.PowerShellCore -eq $false -and $Script:IsPowerShellCore -and $IsWindows)
                    {
                        Write-Verbose -Message "The dependency {$($dependency.ModuleName)} requires Windows PowerShell. Skipping."
                        continue
                    }
                    $found = Test-M365DSCDependencyManifestPath -ModuleName $dependency.ModuleName -RequiredVersion $dependency.RequiredVersion
                    if (-not $found)
                    {
                        $found = Get-Module $dependency.ModuleName -ListAvailable | Where-Object -Property Version -EQ $dependency.RequiredVersion
                    }
                    if (-not $found)
                    {
                        $found = Get-PSResource -Name $dependency.ModuleName -Version $dependency.RequiredVersion -Scope $Scope -ErrorAction SilentlyContinue
                    }
                }

                if ((-not $found -or $Force) -and -not $ValidateOnly)
                {
                    $errorFound = $false
                    try
                    {
                        if (($PSEdition -eq 'Desktop' -or $IsWindows) -and (-not(([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))) -and ($Scope -eq "AllUsers"))
                        {
                            Write-Error 'Cannot update the dependencies for Microsoft365DSC. You need to run this command as a local administrator.'
                            $errorFound = $true
                        }
                    }
                    catch
                    {
                        Write-Verbose -Message "Couldn't retrieve Windows Principal. One possible cause is that the current environment is not a Windows OS."
                    }
                    if (-not $errorFound)
                    {
                        if (-not $dependency.PowerShellCore -and $Script:IsPowerShellCore -and $IsWindows)
                        {
                            Write-Warning "The dependency {$($dependency.ModuleName)} does not support PowerShell Core. Please run Update-M365DSCDependencies in Windows PowerShell."
                            continue
                        }
                        elseif ($dependency.PowerShellCore -and -not $Script:IsPowerShellCore)
                        {
                            Write-Warning "The dependency {$($dependency.ModuleName)} requires PowerShell Core. Please run Update-M365DSCDependencies in PowerShell Core."
                            continue
                        }

                        Remove-Module $dependency.ModuleName -Force -ErrorAction SilentlyContinue
                        if ($dependency.ModuleName -like 'Microsoft.Graph*')
                        {
                            Remove-Module 'Microsoft.Graph.Authentication' -Force -ErrorAction SilentlyContinue
                        }
                        Remove-Module $dependency.ModuleName -Force -ErrorAction SilentlyContinue

                        if ($scopedIsPsResourceGetAvailable -and -not $UsePowerShellGet)
                        {
                            Write-Information -MessageData "Using Install-PSResource to install $($dependency.ModuleName) with version {$($dependency.RequiredVersion)}"
                            Install-PSResource -Name $dependency.ModuleName -Version $dependency.RequiredVersion -Scope $Scope -AcceptLicense -SkipDependencyCheck -TrustRepository -Repository $Repository
                        }
                        else
                        {
                            Write-Information -MessageData "Using Install-Module to install $($dependency.ModuleName) with version {$($dependency.RequiredVersion)}"
                            Install-Module $dependency.ModuleName -RequiredVersion $dependency.RequiredVersion -AllowClobber -Force -Scope "$Scope" @Params -Repository $Repository
                        }
                    }
                }

                if ($dependency.ExplicitLoading)
                {
                    Remove-Module $dependency.ModuleName -Force -ErrorAction SilentlyContinue
                    if ($dependency.Prefix)
                    {
                        Import-M365DSCDependencyModule -Parameters @{
                            Name                = $dependency.ModuleName
                            Global              = $true
                            Prefix              = $dependency.Prefix
                            Force               = $true
                            DisableNameChecking = $true
                        }
                    }
                    else
                    {
                        Import-M365DSCDependencyModule -Parameters @{
                            Name                = $dependency.ModuleName
                            Global              = $true
                            Force               = $true
                            Alias               = @()
                            Cmdlet              = @()
                            Variable            = @()
                            DisableNameChecking = $true
                        }
                    }
                }

                if (-not $found -and $validateOnly)
                {
                    $returnValue += $dependency
                }
            }
            catch
            {
                Write-Error -Message "Could not update or import {$($dependency.ModuleName)}: $($_.Exception.Message)" -ErrorAction Continue
            }

            $i++
        }

        # The progress bar seems to hang sometimes. Make sure it is no longer displayed.
        Write-Progress -Activity 'Scanning dependencies' -Completed

        if ($ValidateOnly)
        {
            return $returnValue
        }
    }
    catch
    {
        New-M365DSCLogEntry -Message 'Error updating dependencies:' `
            -Exception $_ `
            -Source $($MyInvocation.MyCommand.Source)
        Write-Error $_ -ErrorAction Continue
    }
}

<#
.SYNOPSIS
    Updates Microsoft365DSC and refreshes dependency state.

.DESCRIPTION
    Updates the Microsoft365DSC module, reloads the latest installed version, updates dependencies, and optionally removes outdated versions.

.PARAMETER Scope
    Specifies the installation scope used for update operations.

.PARAMETER Proxy
    Specifies the proxy server used for update operations.

.PARAMETER BaseRepository
    Specifies the repository used to update the Microsoft365DSC module.

.PARAMETER DependencyRepository
    Specifies the repository used to update dependencies.

.PARAMETER NoUninstall
    Indicates that outdated module and dependency versions should not be removed.

.EXAMPLE
    PS> Update-M365DSCModule

.EXAMPLE
    PS> Update-M365DSCModule -Scope CurrentUser

.EXAMPLE
    PS> Update-M365DSCModule -Scope AllUsers

.FUNCTIONALITY
    Public
#>
function Update-M365DSCModule
{
    [CmdletBinding()]
    param(
        [Parameter()]
        [ValidateSet("CurrentUser", "AllUsers")]
        $Scope = "AllUsers",

        [Parameter()]
        [System.String]
        $Proxy,

        [Parameter()]
        [System.String]
        $BaseRepository = 'PSGallery',

        [Parameter()]
        [System.String]
        $DependencyRepository = 'PSGallery',

        [Parameter()]
        [switch]
        $NoUninstall
    )

    $params = @{}
    $unloadModule = $true

    if (-not [System.String]::IsNullOrEmpty($proxy))
    {
        $params.Add('Proxy', $Proxy)
    }
    try
    {
        Update-Module -Name 'Microsoft365DSC' @Params -ErrorAction Stop
    }
    catch
    {
        if ($_.Exception.Message -like "*Module 'Microsoft365DSC' was not installed by using Install-Module*")
        {
            Write-Verbose -Message "The Microsoft365DSC module might have been installed with Install-PSResource"
            if ($Script:IsPsResourceGetAvailable)
            {
                Write-Verbose -Message "Updating the Microsoft365DSC module using Update-PSResource..."
                try
                {
                    Update-PSResource -Name 'Microsoft365DSC' -Scope $Scope `
                        -TrustRepository -AcceptLicense -SkipDependencyCheck `
                        -Repository $BaseRepository -ErrorAction Stop
                }
                catch
                {
                    if ($_.Exception.Message -like "*No installed packages*")
                    {
                        Write-Verbose -Message "Microsoft365DSC was neither installed using Install-Module nor Install-PSResource. Trying to install it now..."
                        Install-PSResource -Name 'Microsoft365DSC' -Scope $Scope `
                            -TrustRepository -AcceptLicense -SkipDependencyCheck `
                            -Repository $BaseRepository -ErrorAction Stop
                    }
                    else
                    {
                        New-M365DSCLogEntry -Message 'Error Updating Module:' `
                            -Exception $_ `
                            -Source $($MyInvocation.MyCommand.Source)
                        throw
                    }
                }
            }
        }
        elseif ($_.Exception.Message -like "*was not updated because no valid module was found*")
        {
            Write-Verbose -Message "No valid module was found to update."
            $unloadModule = $false
        }
    }
    try
    {
        if ($unloadModule)
        {
            Write-Verbose -Message "Unloading all instances of the Microsoft365DSC module from the current PowerShell session."
            Remove-Module Microsoft365DSC -Force
        }

        Write-Verbose -Message "Retrieving all versions of the Microsoft365DSC installed on the machine."
        [Array]$instances = Get-Module Microsoft365DSC -ListAvailable | Sort-Object -Property Version -Descending
        if ($instances.Length -gt 0)
        {
            Write-Verbose -Message "Loading version {$($instances[0].Version.ToString())} of the Microsoft365DSC module from {$($instances[0].ModuleBase)}"
            Import-Module Microsoft365DSC -RequiredVersion $instances[0].Version.ToString() -Force
        }
    }
    catch
    {
        New-M365DSCLogEntry -Message 'Error Updating Module:' `
            -Exception $_ `
            -Source $($MyInvocation.MyCommand.Source)
        throw $_
    }

    Update-M365DSCDependencies -Scope $Scope -Proxy $Proxy -Repository $DependencyRepository

    if (-not $NoUninstall)
    {
        Uninstall-M365DSCOutdatedDependencies
    }
}

Export-ModuleMember -Function @(
    'Confirm-M365DSCDependencies',
    'Confirm-M365DSCLoadedModule',
    'Confirm-M365DSCModuleDependency',
    'Get-M365DSCModuleConfiguration',
    'Get-M365DSCRequiredModules',
    'Get-M365DSCResourceSetting',
    'Get-M365DSCResourceSettings',
    'Import-M365DSCDependencyModule',
    'Register-M365DSCPnPIdentityClientResolver',
    'Set-M365DSCVerboseScope',
    'Set-M365DSCModuleConfiguration',
    'Set-M365DSCRequiredModulesLoaded',
    'Test-IsM365DSCRequiredModulesLoaded',
    'Test-M365DSCDependenciesForNewVersions',
    'Test-M365DSCModuleValidity',
    'Uninstall-M365DSCOutdatedDependencies',
    'Update-M365DSCDependencies',
    'Update-M365DSCModule'
)
