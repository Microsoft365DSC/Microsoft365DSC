<#
.SYNOPSIS
    Captures the Intune setting templates the configuration policy resources are built on.

.DESCRIPTION
    Setting definitions are served by Graph and exist in no offline metadata. The section is only
    filled on a connected run. Every tenant template is recorded thinly and the templates a
    resource pins are recorded with their settings.

.PARAMETER Generator
    Specifies the resource generator module, which owns the setting tree walk.

.PARAMETER Binding
    Specifies the Resource and TemplateId rows from Get-M365DSCIntuneTemplateBinding.

.PARAMETER TemplateList
    Specifies the thin template rows. Empty fetches them from Graph.

.PARAMETER SettingTemplate
    Specifies a map of template id to its setting templates. An absent entry is fetched from Graph.

.OUTPUTS
    An ordered dictionary with Section and Error.
#>
function Get-SettingsCatalogSurface
{
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSModuleInfo]
        $Generator,

        [Parameter()]
        [AllowEmptyCollection()]
        [System.Object[]]
        $Binding = @(),

        [Parameter()]
        [AllowEmptyCollection()]
        [System.Object[]]
        $TemplateList = @(),

        [Parameter()]
        [System.Collections.IDictionary]
        $SettingTemplate = @{}
    )

    $empty = [ordered]@{
        Section = [ordered]@{ templates = [ordered]@{}; pinned = [ordered]@{} }
        Error   = ''
    }

    try
    {
        $rows = $TemplateList
        if ($rows.Count -eq 0)
        {
            $rows = @(Get-SettingsCatalogTemplateList)
        }

        $templates = @{}
        foreach ($row in $rows)
        {
            $id = [System.String] $row.id
            if ([System.String]::IsNullOrEmpty($id))
            {
                continue
            }

            $templates[$id] = [ordered]@{
                displayName    = [System.String] $row.displayName
                displayVersion = [System.String] $row.displayVersion
                platforms      = [System.String] $row.platforms
                technologies   = [System.String] $row.technologies
                lifecycleState = [System.String] $row.lifecycleState
            }
        }

        $resourcesByTemplate = @{}
        foreach ($item in $Binding)
        {
            $id = [System.String] $item.TemplateId
            if (-not $resourcesByTemplate.ContainsKey($id))
            {
                $resourcesByTemplate[$id] = [System.Collections.Generic.List[System.String]]::new()
            }

            $resourcesByTemplate[$id].Add([System.String] $item.Resource)
        }

        $pinned = @{}
        foreach ($id in $resourcesByTemplate.Keys)
        {
            $definitions = $SettingTemplate[$id]
            if ($null -eq $definitions)
            {
                $definitions = @(Get-SettingsCatalogSettingTemplate -TemplateId $id)
            }

            $projection = Get-SettingsCatalogProjection -Generator $Generator -SettingTemplate @($definitions)

            $pinned[$id] = [ordered]@{
                resources = @(Get-M365DSCOrderedName -Value ([System.String[]] @($resourcesByTemplate[$id])))
                settings  = (ConvertTo-SettingsCatalogSetting -SettingTemplate @($definitions) -Projection $projection)
            }
        }

        return [ordered]@{
            Section = [ordered]@{
                templates = ConvertTo-M365DSCOrderedMap -Map $templates
                pinned    = ConvertTo-M365DSCOrderedMap -Map $pinned
            }
            Error   = ''
        }
    }
    catch
    {
        $message = "The settings catalog was not captured. $($_.Exception.Message)"
        Write-Warning -Message $message
        $empty.Error = $message
        return $empty
    }
}

<#
.SYNOPSIS
    Reads every configuration policy template the tenant serves, without their settings.

.OUTPUTS
    The template rows.
#>
function Get-SettingsCatalogTemplateList
{
    [CmdletBinding()]
    [OutputType([System.Object[]])]
    param ()

    $rows = [System.Collections.Generic.List[System.Object]]::new()
    $uri = '/beta/deviceManagement/configurationPolicyTemplates?$top=999'

    do
    {
        $response = Invoke-MgGraphRequest -Method GET -Uri $uri -ErrorAction Stop
        $rows.AddRange([System.Object[]] @($response.value))
        $uri = [System.String] $response.'@odata.nextLink'
    } while (-not [System.String]::IsNullOrEmpty($uri))

    return [System.Object[]] $rows
}

<#
.SYNOPSIS
    Reads the setting templates of one configuration policy template.

.PARAMETER TemplateId
    Specifies the template.

.OUTPUTS
    The setting template rows.
#>
function Get-SettingsCatalogSettingTemplate
{
    [CmdletBinding()]
    [OutputType([System.Object[]])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $TemplateId
    )

    $rows = [System.Collections.Generic.List[System.Object]]::new()
    $uri = "/beta/deviceManagement/configurationPolicyTemplates('$TemplateId')/settingTemplates?`$expand=settingDefinitions&`$top=999"

    do
    {
        $response = Invoke-MgGraphRequest -Method GET -Uri $uri -ErrorAction Stop
        $rows.AddRange([System.Object[]] @($response.value))
        $uri = [System.String] $response.'@odata.nextLink'
    } while (-not [System.String]::IsNullOrEmpty($uri))

    return [System.Object[]] $rows
}

<#
.SYNOPSIS
    Maps every setting definition of a template to the DSC property name it produces.

.DESCRIPTION
    A name is disambiguated against the whole bucket the setting template belongs to, never
    against one setting template. Scoping it narrower leaves every name bare, and the three
    firewall profiles then collapse onto one.

.PARAMETER Generator
    Specifies the resource generator module.

.PARAMETER SettingTemplate
    Specifies the setting templates of one configuration policy template.

.OUTPUTS
    An ordered dictionary with Name, a map of definition id to property name, and Exposed, the
    property names the generator emits.
#>
function Get-SettingsCatalogProjection
{
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSModuleInfo]
        $Generator,

        [Parameter()]
        [AllowEmptyCollection()]
        [System.Object[]]
        $SettingTemplate = @()
    )

    $names = @{}
    $exposed = [System.Collections.Generic.HashSet[System.String]]::new([System.StringComparer]::OrdinalIgnoreCase)

    $buckets = & $Generator {
        param ($Templates)

        return @(Get-M365DSCSettingsCatalogTemplateBucket -SettingTemplates $Templates)
    } $SettingTemplate

    foreach ($bucket in $buckets)
    {
        $all = @($bucket.Definitions)

        foreach ($definition in $all)
        {
            $id = [System.String] $definition.id
            if ([System.String]::IsNullOrEmpty($id) -or $names.ContainsKey($id))
            {
                continue
            }

            $raw = [System.String] (Get-SettingsCatalogSettingName -SettingDefinition $definition -AllSettingDefinitions $all)
            if ([System.String]::IsNullOrEmpty($raw))
            {
                continue
            }

            $names[$id] = & $Generator {
                param ($Value)
                Get-StringFirstCharacterToUpper -Value $Value
            } $raw
        }

        foreach ($template in $bucket.Templates)
        {
            $tree = & $Generator {
                param ($Template, $All)
                New-SettingsCatalogSettingDefinitionSettingsFromTemplate -SettingTemplate $Template -FromRoot -AllSettingDefinitions $All
            } $template $all

            foreach ($name in (Get-SettingsCatalogTreeName -Setting @($tree)))
            {
                $null = $exposed.Add(( & $Generator {
                            param ($Value)
                            Get-StringFirstCharacterToUpper -Value $Value
                        } $name))
            }
        }
    }

    return [ordered]@{ Name = $names; Exposed = $exposed }
}

<#
.SYNOPSIS
    Flattens the setting names of a generator setting tree.

.PARAMETER Setting
    Specifies the setting nodes.

.OUTPUTS
    The names.
#>
function Get-SettingsCatalogTreeName
{
    [CmdletBinding()]
    [OutputType([System.String[]])]
    param
    (
        [Parameter()]
        [AllowEmptyCollection()]
        [System.Object[]]
        $Setting = @()
    )

    $names = [System.Collections.Generic.List[System.String]]::new()

    foreach ($node in $Setting)
    {
        if ($null -eq $node)
        {
            continue
        }

        $name = [System.String] $node.Name
        if (-not [System.String]::IsNullOrEmpty($name))
        {
            $names.Add($name)
        }

        $names.AddRange([System.String[]] @(Get-SettingsCatalogTreeName -Setting @($node.ChildSettings)))
    }

    return [System.String[]] $names
}

<#
.SYNOPSIS
    Records the setting definitions of one template as the service declares them.

.PARAMETER SettingTemplate
    Specifies the setting templates of one configuration policy template.

.PARAMETER Projection
    Specifies the map from Get-SettingsCatalogProjection.

.OUTPUTS
    An ordered map of definition id to its recorded shape.
#>
function ConvertTo-SettingsCatalogSetting
{
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param
    (
        [Parameter()]
        [AllowEmptyCollection()]
        [System.Object[]]
        $SettingTemplate = @(),

        [Parameter(Mandatory = $true)]
        [System.Collections.IDictionary]
        $Projection
    )

    $settings = @{}

    foreach ($template in $SettingTemplate)
    {
        foreach ($definition in @($template.settingDefinitions))
        {
            $id = [System.String] $definition.id
            if ([System.String]::IsNullOrEmpty($id) -or $settings.ContainsKey($id))
            {
                continue
            }

            $name = [System.String] $Projection.Name[$id]

            $settings[$id] = [ordered]@{
                name    = $name
                type    = [System.String] $definition.'@odata.type'
                options = @(Get-M365DSCOrderedName -Value ([System.String[]] @($definition.options |
                                ForEach-Object -Process { [System.String] $_.optionValue.value })))
                parent  = Get-SettingsCatalogSettingParent -Definition $definition
                exposed = $Projection.Exposed.Contains($name)
            }
        }
    }

    return ConvertTo-M365DSCOrderedMap -Map $settings
}

<#
.SYNOPSIS
    Returns the parent setting of a definition, or null when it is a root.

.PARAMETER Definition
    Specifies the setting definition.

.OUTPUTS
    The parent definition id, or null.
#>
function Get-SettingsCatalogSettingParent
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Object]
        $Definition
    )

    $parents = @(@($Definition.dependentOn) + @($Definition.options.dependentOn) |
            ForEach-Object -Process { [System.String] $_.parentSettingId } |
            Where-Object -FilterScript { -not [System.String]::IsNullOrEmpty($_) })

    if ($parents.Count -eq 0)
    {
        return $null
    }

    return @(Get-M365DSCOrderedName -Value ([System.String[]] $parents))[0]
}
