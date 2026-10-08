<#
.SYNOPSIS
    Generates a class-based Microsoft365DSC resource from a cmdlet.

.DESCRIPTION
    Point the generator at a cmdlet noun and it produces every artifact of a resource: the
    MSFT_<Name>.psm1 class module, settings.json, readme.md, a unit test that
    asserts the resource's real property values (including a genuine drift context), the three
    example configurations and the unit test stubs.

    Generation is non-interactive by default. When a Graph entity is polymorphic the concrete
    subtype is auto-picked by name similarity against the resource name and cmdlet noun; explicit
    -AdditionalPropertiesType always wins, and only an ambiguous match in an interactive session
    falls back to a prompt.

    All artifacts are written to a staging folder first and moved into place only when the whole
    generation succeeded, so a failure never leaves a half-generated resource behind.

.PARAMETER ResourceName
    Specifies the name of the resource to generate, e.g. 'AADPermissionGrantPolicy'.

.PARAMETER Workload
    Specifies the workload the resource belongs to.

.PARAMETER CmdLetNoun
    Specifies the noun of the cmdlets backing the resource, e.g. 'MgBetaPolicyPermissionGrantPolicy'.

.PARAMETER CmdLetVerb
    Specifies the verb of the non-Graph cmdlet whose parameters describe the resource. Defaults to 'New'.

.PARAMETER IsSingleInstance
    Indicates a singleton resource: it gets an IsSingleInstance key and no Ensure property.

.PARAMETER Path
    Specifies the folder receiving the MSFT_<ResourceName> resource folder.
    Defaults to the repository's DscResources folder.

.PARAMETER UnitTestPath
    Specifies the folder receiving the unit test. Defaults to Tests\Unit\Microsoft365DSC.

.PARAMETER ExampleFilePath
    Specifies the folder receiving the example configurations. Defaults to Examples\Resources.

.PARAMETER APIVersion
    Specifies the Graph API version to inspect. Falls back to beta automatically when the cmdlet
    only exists there.

.PARAMETER ParametersToSkip
    Specifies property names to leave out of the generated resource.

.PARAMETER CreateOnlyProperties
    Specifies property names the service accepts on create and rejects on update, such as the
    catalog package a catalog app was created from.

.PARAMETER TextPayloadProperties
    Specifies property names Graph carries base64 encoded and a configuration carries as text, such
    as the payload of a custom configuration profile.

.PARAMETER AdditionalPropertiesType
    Specifies the concrete OData subtype for polymorphic Graph entities, bypassing the auto-pick.

.PARAMETER FixActualType
    Specifies the Graph entity type explicitly when it cannot be derived from the cmdlet output type.

.PARAMETER IncludeNavigationProperties
    Indicates that Graph navigation properties (relationships) are included. Use with caution:
    only include when a relationship carries writable properties.

.PARAMETER NonInteractive
    Suppresses every interactive prompt; ambiguity becomes an error with retry guidance.

.PARAMETER Force
    Overwrites existing generated files.

.EXAMPLE
    New-M365DSCResource -ResourceName AADPermissionGrantPolicy -Workload MicrosoftGraph -CmdLetNoun MgBetaPolicyPermissionGrantPolicy -APIVersion beta
#>
function New-M365DSCResource
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $ResourceName,

        [Parameter(Mandatory = $true)]
        [ValidateSet('ExchangeOnline', 'Intune', 'SecurityComplianceCenter', 'PnP', 'PowerPlatforms', 'MicrosoftTeams', 'MicrosoftGraph')]
        [System.String]
        $Workload,

        [Parameter(Mandatory = $true)]
        [System.String]
        $CmdLetNoun,

        [Parameter()]
        [System.String]
        $CmdLetVerb = 'New',

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $IsSingleInstance,

        [Parameter()]
        [System.String]
        $Path,

        [Parameter()]
        [System.String]
        $UnitTestPath,

        [Parameter()]
        [System.String]
        $ExampleFilePath,

        [Parameter()]
        [ValidateSet('v1.0', 'beta')]
        [System.String]
        $APIVersion = 'v1.0',

        [Parameter()]
        [System.String[]]
        $ParametersToSkip = @(),

        [Parameter()]
        [System.String[]]
        $CreateOnlyProperties = @(),

        [Parameter()]
        [System.String[]]
        $TextPayloadProperties = @(),

        [Parameter()]
        [System.String]
        $AdditionalPropertiesType,

        [Parameter()]
        [System.String]
        $FixActualType,

        [Parameter()]
        [System.Boolean]
        $IncludeNavigationProperties = $false,

        [Parameter()]
        [System.String]
        $SettingsCatalogTemplateId,

        [Parameter()]
        [System.Array]
        $SettingsCatalogSettingTemplates,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $SkipPlatformsAndTechnologies,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $NonInteractive,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $Force
    )

    $isSettingsCatalog = -not [System.String]::IsNullOrEmpty($SettingsCatalogTemplateId) -or
        $SettingsCatalogSettingTemplates.Count -gt 0 -or
        $CmdLetNoun -like '*DeviceManagementConfigurationPolicy'

    if ($isSettingsCatalog -and [System.String]::IsNullOrEmpty($SettingsCatalogTemplateId))
    {
        throw ('Settings catalog resources require -SettingsCatalogTemplateId (e.g. ' +
            "'4cfd164c-5e8a-4ea9-b15d-9aa71e4ffff4_1'). The setting templates are fetched from " +
            'Graph automatically, or can be supplied through -SettingsCatalogSettingTemplates. ' +
            'An authenticated Microsoft Graph connection is required.')
    }

    $repositoryRoot = Join-Path -Path $PSScriptRoot -ChildPath '..\..' -Resolve

    if ([System.String]::IsNullOrEmpty($Path))
    {
        $Path = Join-Path -Path $repositoryRoot -ChildPath 'Modules\Microsoft365DSC\DscResources'
    }
    if ([System.String]::IsNullOrEmpty($UnitTestPath))
    {
        $UnitTestPath = Join-Path -Path $repositoryRoot -ChildPath 'Tests\Unit\Microsoft365DSC'
    }
    if ([System.String]::IsNullOrEmpty($ExampleFilePath))
    {
        $ExampleFilePath = Join-Path -Path $repositoryRoot -ChildPath 'Examples\Resources'
    }

    $allowPrompt = -not $NonInteractive.IsPresent

    # ------------------------------------------------------------------ Acquire
    $isGraph = $Workload -in @('MicrosoftGraph', 'Intune')

    if ($isSettingsCatalog)
    {
        $settingsCatalogInfo = Get-M365DSCSettingsCatalogInfo -TemplateId $SettingsCatalogTemplateId `
            -ResourceName $ResourceName `
            -SettingTemplates $SettingsCatalogSettingTemplates `
            -SkipPlatformsAndTechnologies $SkipPlatformsAndTechnologies.IsPresent

        $resourceModel = New-M365DSCSettingsCatalogResourceModel -ResourceName $ResourceName `
            -SettingsCatalogInfo $settingsCatalogInfo
    }
    elseif ($isGraph)
    {
        $cmdletInfo = Get-M365DSCGraphCmdletInfo -CmdLetNoun $CmdLetNoun `
            -APIVersion $APIVersion `
            -ResourceName $ResourceName `
            -FixActualType $FixActualType `
            -AllowPrompt $allowPrompt

        $schema = Get-M365DSCGraphCsdlMetadata -APIVersion $cmdletInfo.APIVersion

        $subtypeInfo = Resolve-M365DSCGraphODataSubtype -Schema $schema `
            -ActualType $cmdletInfo.ActualType `
            -ResourceName $ResourceName `
            -CmdLetNoun $CmdLetNoun `
            -AdditionalPropertiesType $AdditionalPropertiesType `
            -AllowPrompt $allowPrompt

        Write-Verbose -Message "Generating '$ResourceName' from entity type '$($subtypeInfo.SelectedODataType)' (polymorphic: $($subtypeInfo.IsAdditionalProperty))."

        $cmdletInfo.EntityTypeName = Get-M365DSCGraphQualifiedTypeName -Schema $schema -TypeName $cmdletInfo.ActualType
        $cmdletInfo.ODataSubtypeName = $null
        if ($subtypeInfo.IsAdditionalProperty)
        {
            $cmdletInfo.ODataSubtypeName = Get-M365DSCGraphQualifiedTypeName -Schema $schema -TypeName $subtypeInfo.SelectedODataType
        }

        $existingCimClasses = Get-M365DSCExistingCimClassName -ResourceName $ResourceName
        $properties = @(Get-M365DSCGraphTypeProperty -Schema $schema `
                -Entity $subtypeInfo.SelectedODataType `
                -IncludeNavigationProperties $IncludeNavigationProperties `
                -ExistingCimClassNames $existingCimClasses)

        # An app assignment carries the settings of its own app type.
        $assignmentSettings = @()
        $settingsType = Resolve-M365DSCMobileAppAssignmentSettingsType -Schema $schema -AppType $subtypeInfo.SelectedODataType
        if (-not [System.String]::IsNullOrEmpty($settingsType))
        {
            $assignmentSettings = @(Get-M365DSCGraphTypeProperty -Schema $schema `
                    -Entity $settingsType `
                    -ExistingCimClassNames $existingCimClasses)
        }

        $resourceModel = New-M365DSCResourceModel -ResourceName $ResourceName `
            -Workload $Workload `
            -CmdletInfo $cmdletInfo `
            -Properties $properties `
            -ParametersToSkip $ParametersToSkip `
            -SelectedODataType $subtypeInfo.SelectedODataType `
            -IsAdditionalProperty $subtypeInfo.IsAdditionalProperty `
            -IsSingleInstance $IsSingleInstance.IsPresent `
            -CmdLetNoun $CmdLetNoun `
            -CmdLetVerb $CmdLetVerb `
            -IncludeNavigationProperties $IncludeNavigationProperties `
            -AssignmentSettingsType $settingsType `
            -AssignmentSettingsMember $assignmentSettings `
            -CreateOnlyProperties $CreateOnlyProperties `
            -TextPayloadProperties $TextPayloadProperties
    }
    else
    {
        $cmdletInfo = Get-M365DSCGenericCmdletInfo -CmdLetNoun $CmdLetNoun `
            -CmdLetVerb $CmdLetVerb `
            -Workload $Workload

        $resourceModel = New-M365DSCResourceModel -ResourceName $ResourceName `
            -Workload $Workload `
            -CmdletInfo $cmdletInfo `
            -Properties $cmdletInfo.Properties `
            -ParametersToSkip $ParametersToSkip `
            -IsSingleInstance $IsSingleInstance.IsPresent `
            -CmdLetNoun $CmdLetNoun `
            -CmdLetVerb $CmdLetVerb `
            -CreateOnlyProperties $CreateOnlyProperties `
            -TextPayloadProperties $TextPayloadProperties
    }

    # ------------------------------------------------------------------ Emit (into staging)
    $stagingRoot = Join-Path -Path ([System.IO.Path]::GetTempPath()) -ChildPath "M365DSCResourceGenerator\$([System.Guid]::NewGuid().ToString('N'))"
    $stagingResourceFolder = Join-Path -Path $stagingRoot -ChildPath "MSFT_$ResourceName"
    $stagingExampleFolder = Join-Path -Path $stagingRoot -ChildPath 'Examples'
    $null = New-Item -Path $stagingResourceFolder -ItemType Directory -Force
    $null = New-Item -Path $stagingExampleFolder -ItemType Directory -Force

    try
    {
        if ($isSettingsCatalog)
        {
            New-M365DSCSettingsCatalogModuleFile -ResourceModel $resourceModel `
                -DestinationPath (Join-Path -Path $stagingResourceFolder -ChildPath "MSFT_$ResourceName.psm1")
        }
        else
        {
            New-M365DSCClassModuleFile -ResourceModel $resourceModel `
                -DestinationPath (Join-Path -Path $stagingResourceFolder -ChildPath "MSFT_$ResourceName.psm1")
        }
        New-M365DSCSettingsFile -ResourceModel $resourceModel `
            -DestinationPath (Join-Path -Path $stagingResourceFolder -ChildPath 'settings.json')
        New-M365DSCReadmeFile -ResourceModel $resourceModel `
            -DestinationPath (Join-Path -Path $stagingResourceFolder -ChildPath 'readme.md')

        $unitTestFileName = "Microsoft365DSC.$ResourceName.Tests.ps1"
        if ($isSettingsCatalog)
        {
            $unitTestTemplatePath = Join-Path -Path $PSScriptRoot -ChildPath '..\Templates\UnitTest.Template.ps1'
            Expand-M365DSCTemplate -TemplatePath $unitTestTemplatePath `
                -Tokens (Get-M365DSCSettingsCatalogUnitTestToken -ResourceModel $resourceModel) `
                -DestinationPath (Join-Path -Path $stagingRoot -ChildPath $unitTestFileName)
        }
        else
        {
            New-M365DSCUnitTestFile -ResourceModel $resourceModel `
                -DestinationPath (Join-Path -Path $stagingRoot -ChildPath $unitTestFileName)
        }

        New-M365DSCExampleFile -ResourceModel $resourceModel -DestinationFolder $stagingExampleFolder

        # ------------------------------------------------------------------ Move into place
        $resourceDestination = Join-Path -Path $Path -ChildPath "MSFT_$ResourceName"
        $unitTestDestination = Join-Path -Path $UnitTestPath -ChildPath $unitTestFileName
        $exampleDestination = Join-Path -Path $ExampleFilePath -ChildPath $ResourceName

        foreach ($destination in @($resourceDestination, $unitTestDestination, $exampleDestination))
        {
            if ((Test-Path -Path $destination) -and -not $Force)
            {
                throw "Destination '$destination' already exists. Use -Force to overwrite."
            }
        }

        foreach ($folder in @($Path, $UnitTestPath, $ExampleFilePath))
        {
            if (-not (Test-Path -Path $folder))
            {
                $null = New-Item -Path $folder -ItemType Directory -Force
            }
        }

        if (Test-Path -Path $resourceDestination)
        {
            Remove-Item -Path $resourceDestination -Recurse -Force
        }
        Move-Item -Path $stagingResourceFolder -Destination $resourceDestination -Force
        Move-Item -Path (Join-Path -Path $stagingRoot -ChildPath $unitTestFileName) -Destination $unitTestDestination -Force
        if (Test-Path -Path $exampleDestination)
        {
            Remove-Item -Path $exampleDestination -Recurse -Force
        }
        Move-Item -Path $stagingExampleFolder -Destination $exampleDestination -Force

        # Stubs are additive and idempotent, so they update in place rather than staging.
        $stubFilePath = Join-Path -Path $repositoryRoot -ChildPath 'Tests\Unit\Stubs\Microsoft365.psm1'
        if (Test-Path -Path $stubFilePath)
        {
            $stubRegion = (Get-M365DSCWorkloadDefault -Workload $Workload).StubRegion
            Update-M365DSCStubFile -CmdletNoun $CmdLetNoun -StubFilePath $stubFilePath -RegionName $stubRegion
        }

        Write-M365DSCGeneratorSummary -ResourceModel $resourceModel `
            -ResourceDestination $resourceDestination `
            -UnitTestDestination $unitTestDestination `
            -ExampleDestination $exampleDestination
    }
    finally
    {
        if (Test-Path -Path $stagingRoot)
        {
            Remove-Item -Path $stagingRoot -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
}

<#
.SYNOPSIS
    Prints what was generated and which follow-up steps remain.
#>
function Write-M365DSCGeneratorSummary
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Object]
        $ResourceModel,

        [Parameter(Mandatory = $true)]
        [System.String]
        $ResourceDestination,

        [Parameter(Mandatory = $true)]
        [System.String]
        $UnitTestDestination,

        [Parameter(Mandatory = $true)]
        [System.String]
        $ExampleDestination
    )

    Write-Host "Resource '$($ResourceModel.ResourceName)' generated:" -ForegroundColor Green
    Write-Host "  Resource module : $ResourceDestination"
    Write-Host "  Unit test       : $UnitTestDestination"
    Write-Host "  Examples        : $ExampleDestination"
    Write-Host ''

    $warnings = @()
    if ($null -ne $ResourceModel.PSObject.Properties['Warnings'])
    {
        $warnings = @($ResourceModel.Warnings | Where-Object -FilterScript { -not [System.String]::IsNullOrEmpty($_) })
    }
    if ($warnings.Count -gt 0)
    {
        Write-Host 'Needs manual attention:' -ForegroundColor Yellow
        foreach ($warning in $warnings)
        {
            Write-Host "  - $warning"
        }
        Write-Host ''
    }
    Write-Host 'Next steps:' -ForegroundColor Yellow
    Write-Host '  1. Review the generated Set() logic - create/update parameter shaping is resource-specific.'
    Write-Host '  2. Fill the roles section of settings.json.'
    Write-Host "  3. After adding cmdlet calls, run Update-M365DSCResourceStub -ResourceName $($ResourceModel.ResourceName) to stub them."
    Write-Host '  4. Run Utilities\Build-Microsoft365DSC.ps1, then run the generated unit test.'
}
