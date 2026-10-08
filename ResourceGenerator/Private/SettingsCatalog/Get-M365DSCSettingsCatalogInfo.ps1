<#
.SYNOPSIS
    Acquires everything needed to generate a settings catalog resource.

.DESCRIPTION
    Fetches the policy template (platforms, technologies) and its setting templates from Graph
    when only a template id is given, parses the setting definitions into a setting tree and
    projects them into property models. Requires an active Microsoft Graph connection.

.PARAMETER TemplateId
    Specifies the configuration policy template id, e.g. '4cfd164c-5e8a-4ea9-b15d-9aa71e4ffff4_1'.

.PARAMETER SettingTemplates
    Specifies already-fetched setting templates (with -ExpandProperty 'settingDefinitions').
    When omitted, they are fetched from the template id.

.PARAMETER SkipPlatformsAndTechnologies
    Removes the Platforms and Technologies settings from the generated parameters.

.PARAMETER ResourceName
    Specifies the resource name; used to suffix the DeviceSettings/UserSettings wrapper CIM
    classes of split templates.
#>
function Get-M365DSCSettingsCatalogInfo
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $TemplateId,

        [Parameter(Mandatory = $true)]
        [System.String]
        $ResourceName,

        [Parameter()]
        [System.Array]
        $SettingTemplates = @(),

        [Parameter()]
        [System.Boolean]
        $SkipPlatformsAndTechnologies = $false
    )

    # Get-SettingsCatalogSettingName lives in the module's Intune util and needs the compiled
    # helper assemblies loaded by M365DSCDllLoader.
    $modulesFolder = Join-Path -Path $PSScriptRoot -ChildPath '..\..\..\Modules\Microsoft365DSC\Modules' -Resolve
    Import-Module -Name (Join-Path -Path $modulesFolder -ChildPath 'M365DSCDllLoader.psm1') -Force -Global
    Import-Module -Name (Join-Path -Path $modulesFolder -ChildPath 'M365DSCIntuneSettingsCatalogUtil.psm1') -Force

    # Raw REST instead of the typed SDK cmdlets: the parsers rely on raw JSON shapes
    # ('@odata.type', derived-type members inline), which the typed models hide inside
    # AdditionalProperties.
    $template = Invoke-MgGraphRequest -Method GET `
        -Uri "/beta/deviceManagement/configurationPolicyTemplates('$TemplateId')" -ErrorAction Stop

    if ($SettingTemplates.Count -eq 0)
    {
        Write-Verbose -Message "Fetching setting templates for template '$TemplateId' from Graph."
        $SettingTemplates = @()
        $uri = "/beta/deviceManagement/configurationPolicyTemplates('$TemplateId')/settingTemplates?`$expand=settingDefinitions&`$top=999"
        do
        {
            $response = Invoke-MgGraphRequest -Method GET -Uri $uri -ErrorAction Stop
            $SettingTemplates += @($response.value)
            $uri = $response.'@odata.nextLink'
        } while (-not [System.String]::IsNullOrEmpty($uri))
    }

    # A template can scope settings to the device or to the user. When BOTH scopes exist, the
    # resource surfaces them as two single wrapper properties (DeviceSettings / UserSettings).
    #
    # Split detection stays prefix-based (that is what the runtime helpers key on), but the
    # buckets themselves classify by scope: a setting is user-scoped when its definition id
    # carries the user_ prefix or its baseUri starts with ./User. Everything else - including
    # settings whose baseUri goes straight to ./Vendor/MSFT without a device_ prefix.
    $buckets = @(Get-M365DSCSettingsCatalogTemplateBucket -SettingTemplates $SettingTemplates)

    $properties = @()
    if ($buckets.Count -eq 1)
    {
        $properties += Get-M365DSCSettingsCatalogGroupPropertyModel -SettingTemplates $buckets[0].Templates
    }
    else
    {
        foreach ($bucket in $buckets)
        {
            $members = Get-M365DSCSettingsCatalogGroupPropertyModel -SettingTemplates $bucket.Templates
            $properties += New-M365DSCSettingsWrapperPropertyModel -Name $bucket.Name -ResourceName $ResourceName -Members $members
        }
    }

    if ($SkipPlatformsAndTechnologies)
    {
        $properties = @($properties | Where-Object -FilterScript { $_.Name -notin @('Platforms', 'Technologies') })
    }

    # Duplicate names can surface when several setting templates expose the same child; keep the first.
    $seenNames = [System.Collections.Generic.HashSet[System.String]]::new([System.StringComparer]::OrdinalIgnoreCase)
    $uniqueProperties = @()
    foreach ($property in $properties)
    {
        if ($seenNames.Add($property.Name))
        {
            $uniqueProperties += $property
        }
        else
        {
            Write-Warning -Message "Duplicate settings catalog property '$($property.Name)' skipped; review the template."
        }
    }

    return @{
        TemplateId                    = $TemplateId
        DisplayName                   = $template.DisplayName
        Platforms                     = [System.String] $template.Platforms
        Technologies                  = [System.String] $template.Technologies
        ContainsDeviceAndUserSettings = $containsDeviceAndUserSettings
        Properties                    = $uniqueProperties
    }
}

<#
.SYNOPSIS
    Tests whether a setting template is user-scoped.

.DESCRIPTION
    User scope is announced through the user_ definition id prefix or a base URI below ./User.
    Everything else - including base URIs going straight to ./Vendor/MSFT - is device-scoped,
    the CSP default context.
#>
function Test-M365DSCUserScopedSettingTemplate
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Object]
        $SettingTemplate
    )

    if ($SettingTemplate.SettingInstanceTemplate.SettingDefinitionId.StartsWith('user_'))
    {
        return $true
    }

    $rootDefinition = @($SettingTemplate.SettingDefinitions | Where-Object -FilterScript {
            $_.Id -eq $SettingTemplate.SettingInstanceTemplate.SettingDefinitionId
        }) | Select-Object -First 1

    return ($null -ne $rootDefinition -and $rootDefinition.baseUri -like './User*')
}

<#
.SYNOPSIS
    Groups setting templates the way a name is disambiguated.

.DESCRIPTION
    A setting name is unique within a bucket, not within one setting template. The compiled
    helper prefixes a name only when the bucket holds a second definition carrying it, so a
    caller that scopes the check to a single setting template never sees a collision.

.PARAMETER SettingTemplates
    Specifies every setting template of one policy template.

.OUTPUTS
    Objects with Name, Templates and Definitions, the flattened definition union of the bucket.
#>
function Get-M365DSCSettingsCatalogTemplateBucket
{
    [CmdletBinding()]
    [OutputType([System.Object[]])]
    param
    (
        [Parameter()]
        [System.Array]
        $SettingTemplates = @()
    )

    if ($SettingTemplates.Count -eq 0)
    {
        return @()
    }

    $prefixedDeviceTemplates = @($SettingTemplates | Where-Object -FilterScript { $_.SettingInstanceTemplate.SettingDefinitionId.StartsWith('device_') })
    $userTemplates = @($SettingTemplates | Where-Object -FilterScript { Test-M365DSCUserScopedSettingTemplate -SettingTemplate $_ })

    if ($prefixedDeviceTemplates.Count -eq 0 -or $userTemplates.Count -eq 0)
    {
        return @([PSCustomObject]@{
                Name        = 'All'
                Templates   = $SettingTemplates
                Definitions = $SettingTemplates.SettingDefinitions
            })
    }

    $deviceTemplates = @($SettingTemplates | Where-Object -FilterScript { -not (Test-M365DSCUserScopedSettingTemplate -SettingTemplate $_) })

    return @(
        [PSCustomObject]@{ Name = 'DeviceSettings'; Templates = $deviceTemplates; Definitions = $deviceTemplates.SettingDefinitions }
        [PSCustomObject]@{ Name = 'UserSettings'; Templates = $userTemplates; Definitions = $userTemplates.SettingDefinitions }
    )
}

<#
.SYNOPSIS
    Parses one group of setting templates into property models.
#>
function Get-M365DSCSettingsCatalogGroupPropertyModel
{
    [CmdletBinding()]
    [OutputType([System.Object[]])]
    param
    (
        [Parameter()]
        [System.Array]
        $SettingTemplates = @()
    )

    if ($SettingTemplates.Count -eq 0)
    {
        return @()
    }

    $allSettingDefinitions = $SettingTemplates.SettingDefinitions

    $templateSettings = @()
    foreach ($settingTemplate in $SettingTemplates)
    {
        $templateSettings += New-SettingsCatalogSettingDefinitionSettingsFromTemplate `
            -FromRoot `
            -SettingTemplate $settingTemplate `
            -AllSettingDefinitions $allSettingDefinitions
    }

    $models = @()
    foreach ($templateSetting in $templateSettings)
    {
        $models += ConvertTo-M365DSCSettingsCatalogPropertyModel -TemplateSetting $templateSetting
    }

    return $models
}
