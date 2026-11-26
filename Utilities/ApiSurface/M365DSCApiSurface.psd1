@{
    RootModule        = 'M365DSCApiSurface.psm1'
    ModuleVersion     = '1.0.0'
    GUID              = 'f7bd5df5-ad9e-42f3-b828-25f90082e004'
    Author            = 'Microsoft Corporation'
    CompanyName       = 'Microsoft Corporation'
    Copyright         = '(c) Microsoft Corporation. All rights reserved.'
    Description       = 'Captures and compares the vendor API surface Microsoft365DSC resources are built on.'
    PowerShellVersion = '7.3'
    FunctionsToExport = @('Compare-M365DSCApiSurface', 'Get-M365DSCApiSurface',
        'Invoke-M365DSCApiSurfaceCheck', 'Invoke-M365DSCApiSurfaceUpdate',
        'Update-M365DSCResourceFromDrift')
    CmdletsToExport   = @()
    VariablesToExport = @()
    AliasesToExport   = @()
    PrivateData       = @{
        PSData = @{
            Tags = @('Microsoft365DSC', 'ApiSurface', 'DSC')
        }
    }
}
