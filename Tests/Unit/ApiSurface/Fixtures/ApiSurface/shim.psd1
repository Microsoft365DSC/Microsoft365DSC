@{
    RootModule        = 'shim.psm1'
    ModuleVersion     = '1.0.0'
    GUID              = '0d0f6f14-6c4d-4a2f-93a4-8c9d2b4a5e11'
    Author            = 'Microsoft Corporation'
    CompanyName       = 'Microsoft Corporation'
    Copyright         = '(c) Microsoft Corporation. All rights reserved.'
    Description       = 'Fixture standing in for the generated Graph shim.'
    PowerShellVersion = '7.3'
    RequiredModules   = @('Microsoft.Graph.Authentication')
    FunctionsToExport = 'Get-MgBetaTestPolicy', 'Get-MgTestGroup', 'New-MgBetaTestPolicy',
                        'Remove-MgBetaTestPolicy', 'Update-MgBetaTestPolicy'
    CmdletsToExport   = @()
    VariablesToExport = @()
    AliasesToExport   = @()
}
