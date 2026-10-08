<#
.SYNOPSIS
    Compares the captured Intune setting templates against what the resources declare.

.DESCRIPTION
    Only settings the generator would emit are compared. A definition the tenant serves but the
    generator never reaches is recorded with exposed false and raises nothing.

.PARAMETER Baseline
    Specifies the previous snapshot.

.PARAMETER Current
    Specifies the snapshot just taken.

.PARAMETER Binding
    Specifies the Resource and TemplateId rows from Get-M365DSCIntuneTemplateBinding.

.PARAMETER DeclaredProperty
    Specifies a map of resource name to the DSC property names it declares.

.OUTPUTS
    The findings.
#>
function Compare-SettingsCatalog
{
    [CmdletBinding()]
    [OutputType([System.Object[]])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Object]
        $Baseline,

        [Parameter(Mandatory = $true)]
        [System.Object]
        $Current,

        [Parameter()]
        [AllowEmptyCollection()]
        [System.Object[]]
        $Binding = @(),

        [Parameter()]
        [System.Collections.IDictionary]
        $DeclaredProperty = @{}
    )

    if ((Test-SettingsCatalogSkipped -Snapshot $Current) -or (Test-SettingsCatalogSkipped -Snapshot $Baseline))
    {
        return [System.Object[]] @()
    }

    $currentSection = $Current.settingsCatalog
    $baselineSection = $Baseline.settingsCatalog

    if ($null -eq $currentSection -or $null -eq $baselineSection)
    {
        return [System.Object[]] @()
    }

    $findings = [System.Collections.Generic.List[System.Object]]::new()

    foreach ($item in ($Binding | Sort-Object -Property @{ Expression = { $_.Resource } }))
    {
        $resource = [System.String] $item.Resource
        $templateId = [System.String] $item.TemplateId

        $declared = $DeclaredProperty[$resource]
        if ($null -eq $declared)
        {
            $declared = [System.Collections.Generic.HashSet[System.String]]::new([System.StringComparer]::OrdinalIgnoreCase)
        }

        $findings.AddRange([System.Object[]] @(Compare-SettingsCatalogSetting -Resource $resource `
                    -TemplateId $templateId `
                    -Baseline (Get-SettingsCatalogPinnedSetting -Section $baselineSection -TemplateId $templateId) `
                    -Current (Get-SettingsCatalogPinnedSetting -Section $currentSection -TemplateId $templateId) `
                    -Declared $declared))

        $active = Find-SettingsCatalogActiveTemplate -Section $currentSection -TemplateId $templateId
        if (-not [System.String]::IsNullOrEmpty($active))
        {
            $findings.Add((New-M365DSCApiSurfaceFinding -Code 'CAT-TEMPLATE-VERSION' `
                        -Subject $resource `
                        -Resource $resource `
                        -Workload 'Intune' `
                        -From ([ordered]@{
                                templateId     = $templateId
                                displayVersion = [System.String] (Get-SettingsCatalogMember -Value $currentSection.templates -Name $templateId).displayVersion
                                lifecycleState = [System.String] (Get-SettingsCatalogMember -Value $currentSection.templates -Name $templateId).lifecycleState
                            }) `
                        -To ([ordered]@{
                                templateId     = $active
                                displayVersion = [System.String] (Get-SettingsCatalogMember -Value $currentSection.templates -Name $active).displayVersion
                                lifecycleState = 'active'
                            }) `
                        -Evidence ([ordered]@{ source = "settingsCatalog:$active" })))
        }
    }

    $findings.AddRange([System.Object[]] @(Compare-SettingsCatalogTemplate -Baseline $baselineSection `
                -Current $currentSection `
                -Binding $Binding))

    return [System.Object[]] $findings
}

<#
.SYNOPSIS
    Tells whether a snapshot could not reach the settings catalog.

.PARAMETER Snapshot
    Specifies the snapshot.

.OUTPUTS
    True when the section was skipped.
#>
function Test-SettingsCatalogSkipped
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter()]
        [AllowNull()]
        [System.Object]
        $Snapshot
    )

    if ($null -eq $Snapshot -or $null -eq $Snapshot.completeness)
    {
        return $true
    }

    return @($Snapshot.completeness.skippedWorkloads) -contains 'settingsCatalog'
}

<#
.SYNOPSIS
    Returns the recorded settings of one pinned template.

.PARAMETER Section
    Specifies the settingsCatalog section.

.PARAMETER TemplateId
    Specifies the template.

.OUTPUTS
    The settings, or null when the template was not captured.
#>
function Get-SettingsCatalogPinnedSetting
{
    [CmdletBinding()]
    [OutputType([System.Object])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Object]
        $Section,

        [Parameter(Mandatory = $true)]
        [System.String]
        $TemplateId
    )

    $entry = Get-SettingsCatalogMember -Value $Section.pinned -Name $TemplateId
    if ($null -eq $entry)
    {
        return $null
    }

    return $entry.settings
}

<#
.SYNOPSIS
    Reads one member of a map that survived a JSON round trip as a PSCustomObject.

.PARAMETER Value
    Specifies the map or object.

.PARAMETER Name
    Specifies the member.

.OUTPUTS
    The member value, or null.
#>
function Get-SettingsCatalogMember
{
    [CmdletBinding()]
    [OutputType([System.Object])]
    param
    (
        [Parameter()]
        [AllowNull()]
        [System.Object]
        $Value,

        [Parameter(Mandatory = $true)]
        [System.String]
        $Name
    )

    if ($null -eq $Value)
    {
        return $null
    }

    if ($Value -is [System.Collections.IDictionary])
    {
        if ($Value.Contains($Name))
        {
            return $Value[$Name]
        }

        return $null
    }

    return $Value.PSObject.Properties[$Name].Value
}

<#
.SYNOPSIS
    Returns the member names of a map that survived a JSON round trip as a PSCustomObject.

.PARAMETER Value
    Specifies the map or object.

.OUTPUTS
    The names.
#>
function Get-SettingsCatalogMemberName
{
    [CmdletBinding()]
    [OutputType([System.String[]])]
    param
    (
        [Parameter()]
        [AllowNull()]
        [System.Object]
        $Value
    )

    if ($null -eq $Value)
    {
        return [System.String[]] @()
    }

    if ($Value -is [System.Collections.IDictionary])
    {
        return [System.String[]] @($Value.Keys)
    }

    return [System.String[]] @($Value.PSObject.Properties.Name)
}

<#
.SYNOPSIS
    Compares the settings of one template against the properties one resource declares.

.PARAMETER Resource
    Specifies the resource.

.PARAMETER TemplateId
    Specifies the template the resource pins.

.PARAMETER Baseline
    Specifies the recorded settings of the previous snapshot.

.PARAMETER Current
    Specifies the recorded settings of the snapshot just taken.

.PARAMETER Declared
    Specifies the DSC property names the resource declares.

.OUTPUTS
    The findings.
#>
function Compare-SettingsCatalogSetting
{
    [CmdletBinding()]
    [OutputType([System.Object[]])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Resource,

        [Parameter(Mandatory = $true)]
        [System.String]
        $TemplateId,

        [Parameter()]
        [AllowNull()]
        [System.Object]
        $Baseline,

        [Parameter()]
        [AllowNull()]
        [System.Object]
        $Current,

        [Parameter(Mandatory = $true)]
        [System.Object]
        $Declared
    )

    if ($null -eq $Baseline -or $null -eq $Current)
    {
        return [System.Object[]] @()
    }

    $findings = [System.Collections.Generic.List[System.Object]]::new()
    $baselineNames = [System.Collections.Generic.HashSet[System.String]]::new(
        [System.String[]] @(Get-SettingsCatalogMemberName -Value $Baseline), [System.StringComparer]::Ordinal)

    foreach ($id in (Get-M365DSCOrderedName -Value ([System.String[]] @(Get-SettingsCatalogMemberName -Value $Current))))
    {
        $setting = Get-SettingsCatalogMember -Value $Current -Name $id
        if (-not [System.Boolean] $setting.exposed)
        {
            continue
        }

        $name = [System.String] $setting.name

        if (-not $baselineNames.Contains($id))
        {
            if ($Declared.Contains($name))
            {
                continue
            }

            $findings.Add((New-M365DSCApiSurfaceFinding -Code 'CAT-SETTING-ADDED' `
                        -Subject $Resource `
                        -Property $id `
                        -Resource $Resource `
                        -Workload 'Intune' `
                        -To ([ordered]@{
                                templateId = $TemplateId
                                name       = $name
                                vendorType = [System.String] $setting.type
                                options    = @($setting.options)
                            }) `
                        -Evidence ([ordered]@{ source = "settingsCatalog:$TemplateId/$id" })))

            continue
        }

        $previous = Get-SettingsCatalogMember -Value $Baseline -Name $id
        $added = @(Get-SettingsCatalogAddedOption -Baseline $previous -Current $setting)

        if ($added.Count -gt 0)
        {
            $findings.Add((New-M365DSCApiSurfaceFinding -Code 'CAT-OPTION-ADDED' `
                        -Subject $Resource `
                        -Property $id `
                        -Resource $Resource `
                        -Workload 'Intune' `
                        -From ([ordered]@{ options = @($previous.options) }) `
                        -To ([ordered]@{
                                templateId = $TemplateId
                                name       = $name
                                options    = @($setting.options)
                                added      = $added
                            }) `
                        -Evidence ([ordered]@{ source = "settingsCatalog:$TemplateId/$id" })))
        }
    }

    $currentNames = [System.Collections.Generic.HashSet[System.String]]::new(
        [System.String[]] @(Get-SettingsCatalogMemberName -Value $Current), [System.StringComparer]::Ordinal)

    foreach ($id in (Get-M365DSCOrderedName -Value ([System.String[]] @(Get-SettingsCatalogMemberName -Value $Baseline))))
    {
        if ($currentNames.Contains($id))
        {
            continue
        }

        $setting = Get-SettingsCatalogMember -Value $Baseline -Name $id
        if (-not [System.Boolean] $setting.exposed)
        {
            continue
        }

        $name = [System.String] $setting.name
        if (-not $Declared.Contains($name))
        {
            continue
        }

        $findings.Add((New-M365DSCApiSurfaceFinding -Code 'CAT-SETTING-REMOVED' `
                    -Subject $Resource `
                    -Property $id `
                    -Resource $Resource `
                    -Workload 'Intune' `
                    -From ([ordered]@{
                            templateId = $TemplateId
                            name       = $name
                            vendorType = [System.String] $setting.type
                        }) `
                    -Evidence ([ordered]@{ source = "settingsCatalog:$TemplateId/$id" })))
    }

    return [System.Object[]] $findings
}

<#
.SYNOPSIS
    Returns the options a choice setting gained.

.PARAMETER Baseline
    Specifies the recorded setting of the previous snapshot.

.PARAMETER Current
    Specifies the recorded setting of the snapshot just taken.

.OUTPUTS
    The added option values.
#>
function Get-SettingsCatalogAddedOption
{
    [CmdletBinding()]
    [OutputType([System.String[]])]
    param
    (
        [Parameter()]
        [AllowNull()]
        [System.Object]
        $Baseline,

        [Parameter()]
        [AllowNull()]
        [System.Object]
        $Current
    )

    $previous = [System.Collections.Generic.HashSet[System.String]]::new(
        [System.String[]] @($Baseline.options | ForEach-Object -Process { [System.String] $_ }),
        [System.StringComparer]::Ordinal)

    $added = @(@($Current.options | ForEach-Object -Process { [System.String] $_ }) |
            Where-Object -FilterScript { -not [System.String]::IsNullOrEmpty($_) -and -not $previous.Contains($_) })

    return [System.String[]] @(Get-M365DSCOrderedName -Value ([System.String[]] $added))
}

<#
.SYNOPSIS
    Returns the active template of the family a resource pins, when the pinned one is not it.

.DESCRIPTION
    The number after the underscore is a revision counter and does not order by recency. Only
    lifecycleState tells which template of a family is current.

.PARAMETER Section
    Specifies the settingsCatalog section.

.PARAMETER TemplateId
    Specifies the pinned template.

.OUTPUTS
    The active template id, or an empty string.
#>
function Find-SettingsCatalogActiveTemplate
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Object]
        $Section,

        [Parameter(Mandatory = $true)]
        [System.String]
        $TemplateId
    )

    $baseId = (Split-SettingsCatalogTemplateId -TemplateId $TemplateId).BaseId
    if ([System.String]::IsNullOrEmpty($baseId))
    {
        return ''
    }

    $pinned = Get-SettingsCatalogMember -Value $Section.templates -Name $TemplateId
    if ($null -eq $pinned -or [System.String] $pinned.lifecycleState -eq 'active')
    {
        return ''
    }

    foreach ($candidate in (Get-M365DSCOrderedName -Value ([System.String[]] @(Get-SettingsCatalogMemberName -Value $Section.templates))))
    {
        if ($candidate -eq $TemplateId -or (Split-SettingsCatalogTemplateId -TemplateId $candidate).BaseId -ne $baseId)
        {
            continue
        }

        if ([System.String] (Get-SettingsCatalogMember -Value $Section.templates -Name $candidate).lifecycleState -eq 'active')
        {
            return $candidate
        }
    }

    return ''
}

<#
.SYNOPSIS
    Splits a template id into its base id and its revision.

.PARAMETER TemplateId
    Specifies the template id.

.OUTPUTS
    An ordered dictionary with BaseId and Revision.
#>
function Split-SettingsCatalogTemplateId
{
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param
    (
        [Parameter()]
        [AllowEmptyString()]
        [System.String]
        $TemplateId
    )

    if ($TemplateId -notmatch '^(?<base>.+)_(?<revision>\d+)$')
    {
        return [ordered]@{ BaseId = ''; Revision = 0 }
    }

    return [ordered]@{ BaseId = $Matches['base']; Revision = [System.Int32] $Matches['revision'] }
}

<#
.SYNOPSIS
    Reports the tenant templates no resource pins.

.DESCRIPTION
    Delta scoped against the baseline. A newer version of a pinned template is reported as
    CAT-TEMPLATE-VERSION instead.

.PARAMETER Baseline
    Specifies the settingsCatalog section of the previous snapshot.

.PARAMETER Current
    Specifies the settingsCatalog section of the snapshot just taken.

.PARAMETER Binding
    Specifies the Resource and TemplateId rows.

.OUTPUTS
    The findings.
#>
function Compare-SettingsCatalogTemplate
{
    [CmdletBinding()]
    [OutputType([System.Object[]])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Object]
        $Baseline,

        [Parameter(Mandatory = $true)]
        [System.Object]
        $Current,

        [Parameter()]
        [AllowEmptyCollection()]
        [System.Object[]]
        $Binding = @()
    )

    $known = [System.Collections.Generic.HashSet[System.String]]::new(
        [System.String[]] @(Get-SettingsCatalogMemberName -Value $Baseline.templates), [System.StringComparer]::OrdinalIgnoreCase)

    $pinnedBase = [System.Collections.Generic.HashSet[System.String]]::new([System.StringComparer]::OrdinalIgnoreCase)
    foreach ($item in $Binding)
    {
        $null = $pinnedBase.Add((Split-SettingsCatalogTemplateId -TemplateId ([System.String] $item.TemplateId)).BaseId)
    }

    if ($known.Count -eq 0)
    {
        return [System.Object[]] @()
    }

    $findings = [System.Collections.Generic.List[System.Object]]::new()

    foreach ($id in (Get-M365DSCOrderedName -Value ([System.String[]] @(Get-SettingsCatalogMemberName -Value $Current.templates))))
    {
        if ($known.Contains($id) -or $pinnedBase.Contains((Split-SettingsCatalogTemplateId -TemplateId $id).BaseId))
        {
            continue
        }

        $template = Get-SettingsCatalogMember -Value $Current.templates -Name $id

        $findings.Add((New-M365DSCApiSurfaceFinding -Code 'CAT-TEMPLATE-NEW' `
                    -Subject $id `
                    -Workload 'Intune' `
                    -To ([ordered]@{
                            displayName  = [System.String] $template.displayName
                            platforms    = [System.String] $template.platforms
                            technologies = [System.String] $template.technologies
                        }) `
                    -Evidence ([ordered]@{ source = "settingsCatalog:$id" })))
    }

    return [System.Object[]] $findings
}
