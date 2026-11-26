@{
    RootModule        = 'M365DSCResourceGenerator.psm1'
    ModuleVersion     = '2.0.0'
    GUID              = '2b72f4a4-6dcf-47b6-8b6e-e2a1f4a9b7d1'
    Author            = 'Microsoft Corporation'
    CompanyName       = 'Microsoft Corporation'
    Copyright         = '(c) Microsoft Corporation. All rights reserved.'
    Description       = 'Generates class-based Microsoft365DSC resources (module, unit test, example, settings and readme files) from a cmdlet.'
    PowerShellVersion = '5.1'
    FunctionsToExport = @('New-M365DSCResource', 'Update-M365DSCResourceStub')
    CmdletsToExport   = @()
    VariablesToExport = @()
    AliasesToExport   = @()
    PrivateData       = @{
        PSData = @{
            Tags = @('Microsoft365DSC', 'ResourceGenerator', 'DSC')
        }
    }
}
