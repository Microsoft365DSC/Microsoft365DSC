@{
    RootModule        = 'M365DSCApiSurfaceTestWorkload.psm1'
    ModuleVersion     = '1.0.0'
    GUID              = '3b3d1f6e-6f22-4d2b-9a0e-0f7c1c9a6d42'
    Author            = 'Microsoft Corporation'
    CompanyName       = 'Microsoft Corporation'
    Copyright         = '(c) Microsoft Corporation. All rights reserved.'
    Description       = 'Fixture standing in for a workload module the resources call.'
    PowerShellVersion = '7.3'
    FunctionsToExport = @('Get-CsTestThing', 'Set-CsTestThing')
    CmdletsToExport   = @()
    VariablesToExport = @()
    AliasesToExport   = @()
}
