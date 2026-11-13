# Because modules are imported in alphabetical order using NestedModules in the module manifest,
# we need to import the DLL Loader module before everything else from the M365DSCInit nested module,
# which is listed first in NestedModules
Import-Module -Name "$PSScriptRoot/Modules/M365DSCDllLoader.psm1" -Global -Force
