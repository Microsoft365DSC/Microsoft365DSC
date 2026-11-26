<#
.SYNOPSIS
    Captures the vendor API surface the Microsoft365DSC resources are built on.

.DESCRIPTION
    Returns one snapshot object and writes nothing. ConvertTo-M365DSCApiSurfaceJson serializes it
    into api-surface.json. Exchange Online, Security and Compliance and the Intune settings
    catalog need a tenant connection and are listed in completeness.skippedWorkloads without one.

.PARAMETER Workload
    Specifies which workloads to capture. Defaults to every workload the run can reach offline.

.PARAMETER IncludeTenantConnected
    Indicates that the workloads which need a tenant connection are captured.

.PARAMETER Credential
    Specifies the credential to authenticate with.

.PARAMETER RepositoryRoot
    Specifies the root of the Microsoft365DSC repository. Defaults to the parent of this module.

.PARAMETER ResourcePath
    Specifies the folder holding the MSFT_<Name> resource folders.

.PARAMETER CmdletMappingPath
    Specifies the path of cmdlet-mapping.json.

.PARAMETER FunctionSignaturePath
    Specifies the path of function-signatures.json.

.PARAMETER CmdletMappingOverridePath
    Specifies the path of cmdlet-mapping-overrides.json.

.PARAMETER ShimModulePath
    Specifies the path of M365DSCGraphShim.psm1.

.PARAMETER ShimManifestPath
    Specifies the path of M365DSCGraphShim.psd1.

.PARAMETER ManifestPath
    Specifies the path of Dependencies/Manifest.psd1.

.PARAMETER DevManifestPath
    Specifies the path of Dependencies/DevManifest.psd1.

.PARAMETER CsdlPathV1
    Specifies a v1.0 CSDL file to read instead of the generator's cached download.

.PARAMETER CsdlPathBeta
    Specifies a beta CSDL file to read instead of the generator's cached download.

.PARAMETER ApplicationId
    Specifies the application registration.

.PARAMETER TenantId
    Specifies the tenant domain name.

.PARAMETER CertificateThumbprint
    Specifies the certificate registered on the application.

.PARAMETER WorkloadAuthentication
    Specifies per-workload ApplicationId and CertificateThumbprint overrides, keyed by workload.

.PARAMETER SkipGalleryLookup
    Indicates that no dependency is looked up in the gallery.

.EXAMPLE
    Get-M365DSCApiSurface

.EXAMPLE
    Get-M365DSCApiSurface -Workload 'MicrosoftGraph' -SkipGalleryLookup

.OUTPUTS
    An ordered dictionary holding the snapshot.
#>
function Get-M365DSCApiSurface
{
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param
    (
        [Parameter()]
        [ValidateSet('MicrosoftGraph', 'Intune', 'ExchangeOnline', 'SecurityComplianceCenter',
            'MicrosoftTeams', 'PnP', 'PowerPlatforms', 'Azure')]
        [System.String[]]
        $Workload = @('MicrosoftGraph', 'Intune', 'ExchangeOnline', 'SecurityComplianceCenter',
            'MicrosoftTeams', 'PnP', 'PowerPlatforms', 'Azure'),

        [Parameter()]
        [switch]
        $IncludeTenantConnected,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $Credential,

        [Parameter()]
        [System.String]
        $RepositoryRoot = (Join-Path -Path $PSScriptRoot -ChildPath '../../..' -Resolve),

        [Parameter()]
        [System.String]
        $ResourcePath,

        [Parameter()]
        [System.String]
        $CmdletMappingPath,

        [Parameter()]
        [System.String]
        $FunctionSignaturePath,

        [Parameter()]
        [System.String]
        $CmdletMappingOverridePath,

        [Parameter()]
        [System.String]
        $ShimModulePath,

        [Parameter()]
        [System.String]
        $ShimManifestPath,

        [Parameter()]
        [System.String]
        $ManifestPath,

        [Parameter()]
        [System.String]
        $DevManifestPath,

        [Parameter()]
        [System.String]
        $CsdlPathV1,

        [Parameter()]
        [System.String]
        $CsdlPathBeta,

        [Parameter()]
        [System.String]
        $ApplicationId,

        [Parameter()]
        [System.String]
        $TenantId,

        [Parameter()]
        [System.String]
        $CertificateThumbprint,

        [Parameter()]
        [System.Collections.IDictionary]
        $WorkloadAuthentication = @{},

        [Parameter()]
        [switch]
        $SkipGalleryLookup
    )

    $defaults = @{
        ResourcePath              = 'Modules/Microsoft365DSC/DscResources'
        CmdletMappingPath         = 'Utilities/cmdlet-mapping.json'
        FunctionSignaturePath     = 'Utilities/function-signatures.json'
        CmdletMappingOverridePath = 'Utilities/cmdlet-mapping-overrides.json'
        ShimModulePath            = 'Modules/Microsoft365DSC/Modules/M365DSCGraphShim.psm1'
        ShimManifestPath          = 'Modules/Microsoft365DSC/Modules/M365DSCGraphShim.psd1'
        ManifestPath              = 'Modules/Microsoft365DSC/Dependencies/Manifest.psd1'
        DevManifestPath           = 'Modules/Microsoft365DSC/Dependencies/DevManifest.psd1'
    }

    foreach ($name in $defaults.Keys)
    {
        if ([System.String]::IsNullOrEmpty((Get-Variable -Name $name -ValueOnly)))
        {
            Set-Variable -Name $name -Value (Join-Path -Path $RepositoryRoot -ChildPath $defaults[$name])
        }
    }

    $generator = Get-M365DSCApiSurfaceGenerator -RepositoryRoot $RepositoryRoot
    $origin = @(Get-ResourceOriginSurface -ResourcePath $ResourcePath)

    $dependency = Get-DependencySurface -ManifestPath $ManifestPath `
        -DevManifestPath $DevManifestPath `
        -SkipGalleryLookup:$SkipGalleryLookup

    $skippedModules = [System.Collections.Generic.List[System.String]]::new()
    $connected = @{}
    $tenantError = ''
    $skippedWorkloads = [System.Collections.Generic.List[System.String]]::new()

    $graphRequested = ('MicrosoftGraph' -in $Workload) -or ('Intune' -in $Workload)

    $graphTypes = [ordered]@{}
    $typeCoverage = [ordered]@{
        requested = 0
        captured  = 0
        missing   = @()
    }

    if ($graphRequested)
    {
        $csdlPath = @{}
        if (-not [System.String]::IsNullOrEmpty($CsdlPathV1))
        {
            $csdlPath['v1.0'] = $CsdlPathV1
        }
        if (-not [System.String]::IsNullOrEmpty($CsdlPathBeta))
        {
            $csdlPath['beta'] = $CsdlPathBeta
        }

        $graphOrigin = @($origin | Where-Object -FilterScript { $_.Workload -in @('MicrosoftGraph', 'Intune') })
        $typeSurface = Get-GraphTypeSurface -Generator $generator -Origin $graphOrigin -CsdlPath $csdlPath

        $graphTypes = $typeSurface.Types
        $typeCoverage = [ordered]@{
            requested = @($typeSurface.Seeds).Count
            captured  = @($typeSurface.Seeds).Count - @($typeSurface.Missing).Count
            missing   = @($typeSurface.Missing)
        }
    }

    $cmdlets = @{}
    $overrides = [ordered]@{}

    if ($graphRequested)
    {
        $graphCmdlets = Get-GraphCmdletSurface -CmdletMappingPath $CmdletMappingPath `
            -FunctionSignaturePath $FunctionSignaturePath `
            -CmdletMappingOverridePath $CmdletMappingOverridePath `
            -ModuleVersion $dependency.PinnedVersion

        foreach ($entry in $graphCmdlets.Cmdlets.GetEnumerator())
        {
            $cmdlets[$entry.Key] = $entry.Value
        }

        $overrides = $graphCmdlets.Overrides
    }

    $graphCmdletNames = [System.String[]] @($cmdlets.Keys)
    $workloadModules = @('MicrosoftTeams', 'PnP', 'PowerPlatforms', 'Azure', 'ExchangeOnline', 'SecurityComplianceCenter') |
        Where-Object -FilterScript { $_ -in $Workload }

    $missingCmdlets = @()
    if (@($workloadModules).Count -gt 0)
    {
        # The offline modules are captured before any connection. Connecting loads assemblies that
        # stop MicrosoftTeams importing afterwards.
        $workloadCmdlets = Get-WorkloadCmdletSurface -Origin $origin `
            -GraphCmdletName $graphCmdletNames `
            -ModuleVersion $dependency.PinnedVersion

        $missingCmdlets = @($workloadCmdlets.MissingCmdlets)
        $connectTimeModules = @($workloadCmdlets.SkippedModules)

        foreach ($entry in $workloadCmdlets.Cmdlets.GetEnumerator())
        {
            if ($entry.Value.workload -eq 'Support' -or $entry.Value.workload -in $Workload)
            {
                $cmdlets[$entry.Key] = $entry.Value
            }
        }

        foreach ($name in $workloadCmdlets.SkippedModules)
        {
            $skippedModules.Add($name)
        }

        if ($IncludeTenantConnected)
        {
            $connection = Connect-TenantWorkload -Workload $Workload `
                -RepositoryRoot $RepositoryRoot `
                -Credential $Credential `
                -ApplicationId $ApplicationId `
                -TenantId $TenantId `
                -CertificateThumbprint $CertificateThumbprint `
                -WorkloadAuthentication $WorkloadAuthentication

            $connected = $connection.Module
            $tenantError = $connection.Error
        }

        if ($connected.Count -gt 0)
        {
            $connectedCmdlets = Get-WorkloadCmdletSurface -Origin $origin `
                -GraphCmdletName $graphCmdletNames `
                -ModuleVersion $dependency.PinnedVersion `
                -ConnectedModule $connected `
                -IncludeModule ([System.String[]] $connectTimeModules)

            $missingCmdlets = @($connectedCmdlets.MissingCmdlets)

            foreach ($entry in $connectedCmdlets.Cmdlets.GetEnumerator())
            {
                if ($entry.Value.workload -in $Workload)
                {
                    $cmdlets[$entry.Key] = $entry.Value
                }
            }

            $captured = @($connectedCmdlets.SkippedModules)
            $skippedModules = [System.Collections.Generic.List[System.String]]::new(
                [System.String[]] @($skippedModules | Where-Object -FilterScript { $_ -in $captured }))
        }
    }

    foreach ($name in @('ExchangeOnline', 'SecurityComplianceCenter'))
    {
        if ($name -in $Workload -and -not $connected.ContainsKey($name))
        {
            $skippedWorkloads.Add($name)
        }
    }

    $settingsCatalog = [ordered]@{ templates = [ordered]@{}; pinned = [ordered]@{} }

    if ('Intune' -in $Workload)
    {
        $catalog = $null

        if ($IncludeTenantConnected)
        {
            $graphConnection = Connect-TenantGraph -RepositoryRoot $RepositoryRoot `
                -Credential $Credential `
                -ApplicationId $ApplicationId `
                -TenantId $TenantId `
                -CertificateThumbprint $CertificateThumbprint `
                -WorkloadAuthentication $WorkloadAuthentication

            if ($graphConnection.Connected)
            {
                . (Join-Path -Path $RepositoryRoot -ChildPath 'Utilities/Get-M365DSCIntuneTemplateBinding.ps1')

                $catalog = Get-SettingsCatalogSurface -Generator $generator `
                    -Binding @(Get-M365DSCIntuneTemplateBinding -ResourcePath $ResourcePath)
            }
            elseif ([System.String]::IsNullOrEmpty($tenantError))
            {
                $tenantError = $graphConnection.Error
            }
        }

        if ($null -eq $catalog -or -not [System.String]::IsNullOrEmpty($catalog.Error))
        {
            $skippedWorkloads.Add('settingsCatalog')
        }
        else
        {
            $settingsCatalog = $catalog.Section
        }
    }

    $shim = [ordered]@{}
    if ($graphRequested)
    {
        $shim = (Get-ShimSurface -ModulePath $ShimModulePath -ManifestPath $ShimManifestPath).Shim
    }

    $capturedBy = 'local'
    if (-not [System.String]::IsNullOrEmpty($env:GITHUB_ACTIONS) -or -not [System.String]::IsNullOrEmpty($env:CI))
    {
        $capturedBy = 'ci'
    }

    return [ordered]@{
        formatVersion   = 1
        capturedAt      = [System.DateTime]::UtcNow.ToString('yyyy-MM-ddTHH:mm:ssZ', [System.Globalization.CultureInfo]::InvariantCulture)
        capturedBy      = $capturedBy
        completeness    = [ordered]@{
            tenantConnected   = ($connected.Count -gt 0)
            tenantError       = $tenantError
            workloads         = @(Get-M365DSCOrderedName -Value $Workload)
            skippedWorkloads  = @(Get-M365DSCOrderedName -Value ([System.String[]] $skippedWorkloads))
            skippedModules    = @(Get-M365DSCOrderedName -Value ([System.String[]] $skippedModules))
            missingCmdlets    = @(Get-M365DSCOrderedName -Value ([System.String[]] $missingCmdlets))
            graphTypeCoverage = $typeCoverage
        }
        dependencies    = $dependency.Dependencies
        graphTypes      = $graphTypes
        cmdlets         = ConvertTo-M365DSCOrderedMap -Map $cmdlets
        cmdletOverrides = $overrides
        shim            = $shim
        settingsCatalog = $settingsCatalog
    }
}
