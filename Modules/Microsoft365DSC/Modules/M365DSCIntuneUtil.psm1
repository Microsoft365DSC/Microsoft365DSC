<#
.SYNOPSIS
    Loads the Intune RoleScopeTag cache from Graph.

.DESCRIPTION
    Reads every role scope tag of the tenant once and hands them to the cache the resolve functions
    read from. A tenant that does not grant the permission to read them is recorded as such, so the
    rest of the run passes role scope tags through untouched instead of repeating a call that has
    already failed.

.PARAMETER Force
    Reloads the tags even when they have already been read.

.EXAMPLE
    Initialize-M365DSCIntuneRoleScopeTagCache
#>
function Initialize-M365DSCIntuneRoleScopeTagCache
{
    [CmdletBinding()]
    param(
        [Parameter()]
        [switch]
        $Force
    )

    Initialize-M365DSCDllLoader -ErrorAction Stop

    if ($Force)
    {
        [Microsoft365DSC.Intune.RoleScopeTagCache]::Reset()
    }
    elseif ([Microsoft365DSC.Intune.RoleScopeTagCache]::IsPopulated)
    {
        return
    }

    Write-Verbose -Message 'Refreshing Intune RoleScopeTag cache from Graph'

    try
    {
        $tags = Get-MgBetaDeviceManagementRoleScopeTag -All -ErrorAction Stop
    }
    catch
    {
        [Microsoft365DSC.Intune.RoleScopeTagCache]::MarkUnavailable()
        Write-Warning -Message "Unable to read the Intune role scope tags. $($_.Exception.Message) They are reported and written as their raw ids for the rest of this run."
        return
    }

    [Microsoft365DSC.Intune.RoleScopeTagCache]::Populate(
        [System.Object[]]@($tags),
        [System.Func[System.Object, System.String]] { param($tag) [System.String]$tag.Id },
        [System.Func[System.Object, System.String]] { param($tag) [System.String]$tag.DisplayName })
}

<#
.SYNOPSIS
    Resolves Intune RoleScopeTag Names to their Id.

.DESCRIPTION
    Resolves RoleScopeTag Names into their corresponding Ids.
    If a tag has been deleted, this will return the raw name and emit a warning.

.PARAMETER RoleScopeTagIds
    One or more RoleScopeTag Names to resolve into Ids.

.EXAMPLE
    Resolve-M365DSCIntuneRoleScopeTagIds -RoleScopeTagIds @('Default', 'Second')
#>
function Resolve-M365DSCIntuneRoleScopeTagIds
{
    [CmdletBinding()]
    [OutputType([System.String[]])]
    param(
        [Parameter(Mandatory = $true)]
        [AllowEmptyCollection()]
        [AllowNull()]
        [System.String[]]
        $RoleScopeTagIds
    )

    if ($RoleScopeTagIds.Count -eq 0)
    {
        return ,@()
    }

    Initialize-M365DSCIntuneRoleScopeTagCache

    if (-not [Microsoft365DSC.Intune.RoleScopeTagCache]::IsAvailable)
    {
        return ,([System.String[]]$RoleScopeTagIds)
    }

    $ids = @()
    foreach ($id in $RoleScopeTagIds)
    {
        $resolvedIds = $null
        if ([Microsoft365DSC.Intune.RoleScopeTagCache]::TryGetIds($id, [ref]$resolvedIds))
        {
            $ids += $resolvedIds
            continue
        }

        $resolvedName = $null
        if (-not [Microsoft365DSC.Intune.RoleScopeTagCache]::TryGetName($id, [ref]$resolvedName))
        {
            Write-Warning "RoleScopeTag with Name or Id {$id} not found in the directory. It may have been deleted or renamed. Skipping it."
            continue
        }

        # Already an id, return it as-is
        $ids += $id
    }

    return ,$ids
}

<#
.SYNOPSIS
    Resolves Intune RoleScopeTag Ids to their current DisplayNames.

.DESCRIPTION
    Resolves RoleScopeTag Ids returned by Graph into their current DisplayNames.
    If a tag has been renamed since the Id was retrieved, this will return the new name.
    If a tag has been deleted, this will return the raw Id and emit a warning.

.PARAMETER CurrentValues
    One or more current RoleScopeTagIds as returned by Graph.

.PARAMETER DesiredValues
    One or more bound RoleScopeTagIds that should be excluded from the resolution and returned as-is.

.EXAMPLE
    Resolve-M365DSCIntuneRoleScopeTagNames -CurrentValues @('0', '4') -DesiredValues @('0')
#>
function Resolve-M365DSCIntuneRoleScopeTagNames
{
    [CmdletBinding()]
    [OutputType([System.String[]])]
    param(
        [Parameter(Mandatory = $true)]
        [AllowEmptyCollection()]
        [AllowNull()]
        [System.String[]]
        $CurrentValues,

        [Parameter(Mandatory = $true)]
        [AllowEmptyCollection()]
        [AllowNull()]
        [System.String[]]
        $DesiredValues
    )

    if ($CurrentValues.Count -eq 0)
    {
        return ,@()
    }

    Initialize-M365DSCIntuneRoleScopeTagCache

    if (-not [Microsoft365DSC.Intune.RoleScopeTagCache]::IsAvailable)
    {
        return ,([System.String[]]$CurrentValues)
    }

    $names = @()
    foreach ($id in $CurrentValues)
    {
        if ($DesiredValues -contains $id)
        {
            $names += $id
            continue
        }

        $resolvedName = $null
        if (-not [Microsoft365DSC.Intune.RoleScopeTagCache]::TryGetName($id, [ref]$resolvedName))
        {
            Write-Warning "RoleScopeTag with Id {$id} not found in the directory. It may have been deleted or renamed."
            $resolvedName = $id
        }

        $names += $resolvedName
    }

    return ,$names
}

<#
.SYNOPSIS
    Converts Microsoft Graph Intune policy assignments into DSC-friendly hashtables.

.DESCRIPTION
    Transforms assignment objects returned by Intune policy endpoints into hashtables used by Microsoft365DSC.
    It resolves group display names and, when enabled, enriches assignments with device filter metadata.

.PARAMETER Assignments
    Specifies the Intune assignment objects returned by Microsoft Graph.

.PARAMETER IncludeDeviceFilter
    Indicates whether assignment filter type, identifier, and display name should be included.

.OUTPUTS
    System.Collections.Hashtable[]
#>
function ConvertFrom-IntunePolicyAssignment
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable[]])]
    param (
        [Parameter(Mandatory = $true)]
        [Array]
        $Assignments,

        [Parameter()]
        [System.Boolean]
        $IncludeDeviceFilter = $true
    )

    if ($null -eq $Script:IntuneAssignmentFilters)
    {
        $Script:IntuneAssignmentFilters = Get-MgBetaDeviceManagementAssignmentFilter -All -ErrorAction SilentlyContinue | ForEach-Object {
            @{
                FilterId    = $_.Id
                DisplayName = $_.DisplayName
            }
        }
    }

    $assignmentResult = @()
    foreach ($assignment in $Assignments)
    {
        if (-not [System.String]::IsNullOrEmpty($assignment.source) -and $assignment.source -ne 'direct')
        {
            continue
        }

        $groupDisplayName = $null
        $hashAssignment = [ordered]@{}
        if ($null -ne $assignment.Target.'@odata.type')
        {
            $dataType = $assignment.Target.'@odata.type'
        }
        else
        {
            $dataType = $assignment.Target.'@odata.type'
        }

        if ($null -ne $assignment.Target.groupId)
        {
            $groupId = $assignment.Target.groupId
        }
        else
        {
            $groupId = $assignment.Target.groupId
        }

        if ($null -ne $assignment.Target.collectionId)
        {
            $collectionId = $assignment.Target.collectionId
        }
        else
        {
            $collectionId = $assignment.Target.collectionId
        }

        $hashAssignment.Add('dataType', $dataType)
        if (-not [string]::IsNullOrEmpty($groupId))
        {
            $hashAssignment.Add('groupId', $groupId)

            $group = Get-M365DSCIntuneGroup -GroupId $groupId
            if ($null -ne $group)
            {
                $groupDisplayName = $group.DisplayName
            }
        }
        if ($dataType -eq '#microsoft.graph.allLicensedUsersAssignmentTarget')
        {
            $groupDisplayName = 'All users'
        }
        if ($dataType -eq '#microsoft.graph.allDevicesAssignmentTarget')
        {
            $groupDisplayName = 'All devices'
        }
        if ($null -ne $groupDisplayName)
        {
            $hashAssignment.Add('groupDisplayName', $groupDisplayName)
        }
        if (-not [string]::IsNullOrEmpty($collectionId))
        {
            $hashAssignment.Add('collectionId', $collectionId)
        }
        if ($IncludeDeviceFilter)
        {
            if ($null -ne $assignment.Target.DeviceAndAppManagementAssignmentFilterType)
            {
                $hashAssignment.Add('deviceAndAppManagementAssignmentFilterType', $assignment.Target.DeviceAndAppManagementAssignmentFilterType.ToString())
            }
            if ($null -ne $assignment.Target.DeviceAndAppManagementAssignmentFilterId)
            {
                $filterId = $assignment.Target.DeviceAndAppManagementAssignmentFilterId
                $hashAssignment.Add('deviceAndAppManagementAssignmentFilterId', $filterId)
                $hashAssignment.Add('deviceAndAppManagementAssignmentFilterDisplayName', (($Script:IntuneAssignmentFilters | Where-Object -Property FilterId -EQ $filterId).DisplayName))
            }
        }

        $assignmentResult += $hashAssignment
    }

    return ,$assignmentResult
}

<#
.SYNOPSIS
    Converts DSC assignment hashtables into Intune policy assignment payloads.

.DESCRIPTION
    Builds Microsoft Graph assignment payloads from DSC-style hashtables for policy assignment operations.
    It resolves groups by id or display name and optionally adds assignment filter values.

.PARAMETER Assignments
    Specifies the DSC assignment hashtables to convert.

.PARAMETER IncludeDeviceFilter
    Indicates whether assignment filter information should be added to generated targets.

.OUTPUTS
    Hashtable[]
#>
function ConvertTo-IntunePolicyAssignment
{
    [CmdletBinding()]
    [OutputType([Hashtable[]])]
    param (
        [Parameter(Mandatory = $true)]
        [AllowNull()]
        $Assignments,

        [Parameter()]
        [System.Boolean]
        $IncludeDeviceFilter = $true
    )

    if ($null -eq $Script:IntuneAssignmentFilters)
    {
        $Script:IntuneAssignmentFilters = Get-MgBetaDeviceManagementAssignmentFilter -All -ErrorAction SilentlyContinue | ForEach-Object {
            @{
                FilterId    = $_.Id
                DisplayName = $_.DisplayName
            }
        }
    }

    if ($null -eq $Assignments)
    {
        return ,@()
    }

    $assignmentResult = @()
    foreach ($assignment in $Assignments)
    {
        $target = @{
            '@odata.type' = $assignment.dataType
        }
        if ($IncludeDeviceFilter)
        {
            if ($null -ne $assignment.DeviceAndAppManagementAssignmentFilterType -and $assignment.DeviceAndAppManagementAssignmentFilterType -ne 'none')
            {
                $filter = $Script:IntuneAssignmentFilters | Where-Object -Property FilterId -EQ $assignment.DeviceAndAppManagementAssignmentFilterId
                if ($null -eq $filter)
                {
                    $filter = $Script:IntuneAssignmentFilters | Where-Object -Property DisplayName -EQ $assignment.DeviceAndAppManagementAssignmentFilterDisplayName
                    if ($null -eq $filter)
                    {
                        Write-Warning -Message "Assignment filter with DisplayName {$($assignment.DeviceAndAppManagementAssignmentFilterDisplayName)} not found in the directory. Please update your DSC resource extract with the correct filterId or filterDisplayName."
                    }
                }

                if ($null -ne $filter)
                {
                    $target.Add('deviceAndAppManagementAssignmentFilterType', $assignment.DeviceAndAppManagementAssignmentFilterType)
                    $target.Add('deviceAndAppManagementAssignmentFilterId', $filter.FilterId)
                }
            }
        }
        if ($assignment.dataType -like '*CollectionAssignmentTarget')
        {
            $target.Add('collectionId', $assignment.collectionId)
        }
        elseif ($assignment.dataType -like '*GroupAssignmentTarget')
        {
            $group = $null
            if (-not [System.String]::IsNullOrEmpty($assignment.groupId))
            {
                $group = Get-M365DSCIntuneGroup -GroupId $assignment.groupId
            }
            if ($null -eq $group -and -not [System.String]::IsNullOrEmpty($assignment.groupDisplayName))
            {
                [array]$group = Get-M365DSCIntuneGroup -DisplayName $assignment.groupDisplayName
                if ($null -eq $group -or $group.Count -eq 0)
                {
                    Write-Warning "Skipping assignment: groupDisplayName '{$($assignment.groupDisplayName)}' not found."
                    $target = $null
                    $group = $null
                }
                elseif ($group.Count -gt 1)
                {
                    Write-Warning "Skipping assignment: groupDisplayName '{$($assignment.groupDisplayName)}' is not unique."
                    $target = $null
                    $group = $null
                }
            }
            # If group found, add its ID
            if ($null -ne $group)
            {
                $target.Add('groupId', $group.Id)
            }
            elseif ($null -eq $group -and [System.String]::IsNullOrEmpty($assignment.groupDisplayName))
            {
                Write-Warning 'Skipping assignment: missing both groupId and groupDisplayName.'
                $target = $null
            }
        }

        if ($null -ne $target)
        {
            $assignmentResult += @{ target = $target }
        }
    }

    return ,$assignmentResult
}

<#
.SYNOPSIS
    Converts mobile app assignment objects into DSC hashtables.

.DESCRIPTION
    Transforms Intune mobile app assignments into hashtables used by Microsoft365DSC resources.
    It includes assignment intent, group display names, optional filter details, and assignment settings when present.

.PARAMETER Assignments
    Specifies the mobile app assignment objects returned by Microsoft Graph.

.PARAMETER IncludeDeviceFilter
    Indicates whether assignment filter details should be included in the output.

.OUTPUTS
    System.Collections.Hashtable[]
#>
function ConvertFrom-IntuneMobileAppAssignment
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable[]])]
    param (
        [Parameter(Mandatory = $true)]
        [Array]
        $Assignments,

        [Parameter()]
        [System.Boolean]
        $IncludeDeviceFilter = $true
    )

    if ($null -eq $Script:IntuneAssignmentFilters)
    {
        $Script:IntuneAssignmentFilters = Get-MgBetaDeviceManagementAssignmentFilter -All -ErrorAction SilentlyContinue | ForEach-Object {
            @{
                FilterId    = $_.Id
                DisplayName = $_.DisplayName
            }
        }
    }

    $assignmentResult = @()
    foreach ($assignment in $Assignments)
    {
        $groupDisplayName = $null
        $hashAssignment = @{}
        if ($null -ne $assignment.Target.'@odata.type')
        {
            $dataType = $assignment.Target.'@odata.type'
        }
        else
        {
            $dataType = $assignment.Target.'@odata.type'
        }

        if ($null -ne $assignment.Target.groupId)
        {
            $groupId = $assignment.Target.groupId
        }
        else
        {
            $groupId = $assignment.Target.groupId
        }

        $hashAssignment.Add('dataType', $dataType)
        if (-not [string]::IsNullOrEmpty($groupId))
        {
            $hashAssignment.Add('groupId', $groupId)

            $group = Get-M365DSCIntuneGroup -GroupId $groupId
            if ($null -ne $group)
            {
                $groupDisplayName = $group.DisplayName
            }
        }

        if ($dataType -eq '#microsoft.graph.allLicensedUsersAssignmentTarget')
        {
            $groupDisplayName = 'All users'
        }
        if ($dataType -eq '#microsoft.graph.allDevicesAssignmentTarget')
        {
            $groupDisplayName = 'All devices'
        }
        if ($null -ne $groupDisplayName)
        {
            $hashAssignment.Add('groupDisplayName', $groupDisplayName)
        }

        $hashAssignment.Add('intent', $assignment.intent.ToString())

        if ($IncludeDeviceFilter)
        {
            if ($null -ne $assignment.Target.DeviceAndAppManagementAssignmentFilterType)
            {
                $hashAssignment.Add('deviceAndAppManagementAssignmentFilterType', $assignment.Target.DeviceAndAppManagementAssignmentFilterType.ToString())
            }
            if ($null -ne $assignment.Target.DeviceAndAppManagementAssignmentFilterId)
            {
                $filterId = $assignment.Target.DeviceAndAppManagementAssignmentFilterId
                $hashAssignment.Add('deviceAndAppManagementAssignmentFilterId', $filterId)
                $hashAssignment.Add('deviceAndAppManagementAssignmentFilterDisplayName', (($Script:IntuneAssignmentFilters | Where-Object -Property FilterId -EQ $filterId).DisplayName))
            }
        }

        if ($null -ne $assignment.settings -and $assignment.settings.Count -gt 0)
        {
            $settings = (Convert-M365DSCDRGComplexTypeToHashtable -ComplexObject $assignment.settings)
            if ($settings.Contains('@odata.type'))
            {
                $settings['odataType'] = $settings['@odata.type']
                $settings.Remove('@odata.type')
            }

            $hashAssignment.Add('assignmentSettings', $settings)
        }

        $assignmentResult += $hashAssignment
    }

    return ,$assignmentResult
}

<#
.SYNOPSIS
    Converts DSC mobile app assignment hashtables into Graph request payloads.

.DESCRIPTION
    Creates Intune mobile app assignment payloads from DSC-style hashtables.
    It resolves target groups, applies optional assignment filters, and maps assignment settings into the expected schema.

.PARAMETER Assignments
    Specifies the mobile app assignment hashtables to convert.

.PARAMETER IncludeDeviceFilter
    Indicates whether assignment filter fields should be emitted in the generated targets.

.OUTPUTS
    Hashtable[]
#>
function ConvertTo-IntuneMobileAppAssignment
{
    [CmdletBinding()]
    [OutputType([Hashtable[]])]
    param (
        [Parameter(Mandatory = $true)]
        [AllowNull()]
        $Assignments,

        [Parameter()]
        [System.Boolean]
        $IncludeDeviceFilter = $true
    )

    if ($null -eq $Script:IntuneAssignmentFilters)
    {
        $Script:IntuneAssignmentFilters = Get-MgBetaDeviceManagementAssignmentFilter -All -ErrorAction SilentlyContinue | ForEach-Object {
            @{
                FilterId    = $_.Id
                DisplayName = $_.DisplayName
            }
        }
    }

    if ($null -eq $Assignments)
    {
        return ,@()
    }

    $assignmentResult = @()
    foreach ($assignment in $Assignments)
    {
        $formattedAssignment = @{}
        $target = @{
            '@odata.type' = $assignment.dataType
        }

        # Handle Device Filters
        if ($IncludeDeviceFilter)
        {
            if ($null -ne $assignment.DeviceAndAppManagementAssignmentFilterType -and
                $assignment.DeviceAndAppManagementAssignmentFilterType -ne 'none')
            {
                $filter = $Script:IntuneAssignmentFilters | Where-Object -Property FilterId -EQ $assignment.DeviceAndAppManagementAssignmentFilterId

                if ($null -eq $filter)
                {
                    $filter = $Script:IntuneAssignmentFilters | Where-Object -Property DisplayName -EQ $assignment.DeviceAndAppManagementAssignmentFilterDisplayName
                }

                if ($null -ne $filter)
                {
                    $target.Add('deviceAndAppManagementAssignmentFilterType', $assignment.DeviceAndAppManagementAssignmentFilterType)
                    $target.Add('deviceAndAppManagementAssignmentFilterId', $filter.FilterId)
                }
                else
                {
                    Write-Warning "Assignment filter with DisplayName {$($assignment.DeviceAndAppManagementAssignmentFilterDisplayName)} not found."
                }
            }
        }

        # Add intent (required for app assignments)
        $formattedAssignment.Add('intent', $assignment.intent)

        if ($assignment.dataType -like '*groupAssignmentTarget')
        {
            $group = $null
            if (-not [System.String]::IsNullOrEmpty($assignment.groupId))
            {
                $group = Get-M365DSCIntuneGroup -GroupId $assignment.groupId
            }
            # If groupId lookup failed, try by display name
            if ($null -eq $group -and -not [System.String]::IsNullOrEmpty($assignment.groupDisplayName))
            {
                [array]$group = Get-M365DSCIntuneGroup -DisplayName $assignment.groupDisplayName
                if ($null -eq $group -or $group.Count -eq 0)
                {
                    Write-Warning "Skipping assignment: groupDisplayName '{$($assignment.groupDisplayName)}' not found."
                    $target = $null
                    $group = $null
                }
                elseif ($group.Count -gt 1)
                {
                    Write-Warning "Skipping assignment: groupDisplayName '{$($assignment.groupDisplayName)}' is not unique."
                    $target = $null
                    $group = $null
                }
            }
            # If group found, add its ID
            if ($null -ne $group)
            {
                $target.Add('groupId', $group.Id)
            }
            elseif ($null -eq $group -and [System.String]::IsNullOrEmpty($assignment.groupDisplayName))
            {
                Write-Warning 'Skipping assignment: missing both groupId and groupDisplayName.'
                $target = $null
            }
        }
        # Add target if valid
        if ($null -ne $target)
        {
            $formattedAssignment.Add('target', $target)

            # Add assignment settings if present
            if ($null -ne $assignment.assignmentSettings)
            {
                $settings = Convert-M365DSCDRGComplexTypeToHashtable -ComplexObject $assignment.assignmentSettings
                $formattedAssignment.Add('settings', $settings)
                $formattedAssignment.settings.Add('@odata.type', $formattedAssignment.settings.odataType)
                $formattedAssignment.settings.Remove('odataType') | Out-Null
            }
            $assignmentResult += $formattedAssignment
        }
    }
    return ,$assignmentResult
}

<#
.SYNOPSIS
    Retrieves cached Intune configuration policies by templateId or filter.

.DESCRIPTION
    Fetches Intune configuration policies from the local cache if available, or queries Microsoft Graph using the provided templateId or filter.
    This function is used to optimize retrieval of configuration policies during DSC operations.

.PARAMETER TemplateId
    Specifies the templateId of the configuration policy to retrieve.

.PARAMETER Filter
    Specifies an optional OData filter string to apply when querying configuration policies.

.OUTPUTS
    List of configuration policy objects from cache or Microsoft Graph.
#>
function Get-M365DSCExportCachedConfigurationPolicies
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [System.String]
        $TemplateId,

        [Parameter(Mandatory = $false)]
        [System.String]
        $Filter
    )

    # Fetch from cache if the filter is empty or matches the templateId filter
    if (-not [System.String]::IsNullOrEmpty($Filter) -and $Filter -like 'templateReference/templateId eq ''*''')
    {
        $cacheValue = [Microsoft365DSC.Intune.ConfigurationPolicyCache]::GetByTemplateId($TemplateId)
        if ($null -ne $cacheValue)
        {
            return $cacheValue
        }
    }

    if (-not [System.String]::IsNullOrEmpty($Filter))
    {
        return Get-MgBetaDeviceManagementConfigurationPolicy -All `
            -Filter $Filter `
            -ExpandProperty 'assignments' `
            -ErrorAction Stop
    }

    return Get-MgBetaDeviceManagementConfigurationPolicy -All `
        -Filter "templateReference/TemplateId eq '$TemplateId'" `
        -ExpandProperty 'assignments' `
        -ErrorAction Stop
}


<#
.SYNOPSIS
    Returns the assignments expanded on a Graph item, or $null when they must be fetched.

.DESCRIPTION
    Reads the 'assignments' navigation property of an item returned with $expand=assignments. Returns
    $null when the item carries no expanded assignments or when Graph truncated them.

.PARAMETER Instance
    Specifies the Graph item, as a hashtable or object.

.OUTPUTS
    System.Object[]
#>
function Get-M365DSCIntuneExpandedAssignments
{
    [CmdletBinding()]
    [OutputType([System.Object[]])]
    param (
        [Parameter(Mandatory = $true)]
        [AllowNull()]
        [System.Object]
        $Instance
    )

    if ($null -eq $Instance)
    {
        return $null
    }

    if ($Instance -is [System.Collections.IDictionary])
    {
        if ($Instance.Contains('assignments@odata.nextLink') -or -not $Instance.Contains('assignments'))
        {
            return $null
        }

        return , [System.Object[]]@($Instance['assignments'] | Where-Object -FilterScript { $null -ne $_ })
    }

    $properties = $Instance.PSObject.Properties
    if ($null -ne $properties['assignments@odata.nextLink'])
    {
        return $null
    }

    $property = $properties['assignments']
    if ($null -eq $property)
    {
        return $null
    }

    return , [System.Object[]]@($property.Value | Where-Object -FilterScript { $null -ne $_ })
}

<#
.SYNOPSIS
    Resolves an Entra group by identifier or display name.

.DESCRIPTION
    Looks a group up by id or by an exact display name match and returns its id and display name.
    Results are served from the export group cache while an export session is active.

.PARAMETER GroupId
    Specifies the group identifier. Returns a single group, or $null when not found.

.PARAMETER DisplayName
    Specifies the exact display name. Returns the matching groups as an array, empty when none match.

.OUTPUTS
    System.Object
#>
function Get-M365DSCIntuneGroup
{
    [CmdletBinding(DefaultParameterSetName = 'ById')]
    param (
        [Parameter(Mandatory = $true, ParameterSetName = 'ById')]
        [System.String]
        $GroupId,

        [Parameter(Mandatory = $true, ParameterSetName = 'ByDisplayName')]
        [System.String]
        $DisplayName
    )

    $cacheAvailable = $null -ne ('Microsoft365DSC.Intune.IntuneGroupCache' -as [System.Type]) -and
        [Microsoft365DSC.Intune.IntuneGroupCache]::IsEnabled

    if ($PSCmdlet.ParameterSetName -eq 'ById')
    {
        $group = $null
        if ($cacheAvailable -and [Microsoft365DSC.Intune.IntuneGroupCache]::TryGetById($GroupId, [ref] $group))
        {
            return $group
        }

        $group = Get-MgGroup -GroupId $GroupId -Property 'id,displayName' -ErrorAction SilentlyContinue
        if ($cacheAvailable)
        {
            [Microsoft365DSC.Intune.IntuneGroupCache]::SetById($GroupId, $group)
        }
        return $group
    }

    $groups = $null
    if ($cacheAvailable -and [Microsoft365DSC.Intune.IntuneGroupCache]::TryGetByName($DisplayName, [ref] $groups))
    {
        return , [System.Object[]]$groups
    }

    $escapedName = $DisplayName -replace "'", "''"
    [System.Object[]]$groups = @(Get-MgGroup -Filter "displayName eq '$escapedName'" -Property 'id,displayName' -All -ErrorAction SilentlyContinue | Where-Object -FilterScript { $null -ne $_ })
    if ($cacheAvailable)
    {
        [Microsoft365DSC.Intune.IntuneGroupCache]::SetByName($DisplayName, $groups)
    }
    return , $groups
}

<#
.SYNOPSIS
    Updates assignments on an Intune device configuration policy.

.DESCRIPTION
    Builds and submits assignment payloads for a device configuration policy.
    It resolves groups when needed and posts the final assignment set to the selected Graph endpoint.
    Throws when Graph rejects the assignments.

.PARAMETER DeviceConfigurationPolicyId
    Specifies the identifier of the device configuration policy to update.

.PARAMETER Targets
    Specifies assignment targets to apply to the policy.

.PARAMETER Repository
    Specifies the Graph repository segment used to address the policy resource.

.PARAMETER APIVersion
    Specifies the Graph API version to call.

.PARAMETER RootIdentifier
    Specifies the root property name used for the assignment payload body.

.OUTPUTS
    System.Collections.Hashtable
#>
function Update-DeviceConfigurationPolicyAssignment
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param (
        [Parameter(Mandatory = $true)]
        [System.String]
        $DeviceConfigurationPolicyId,

        [Parameter()]
        [Array]
        $Targets,

        [Parameter()]
        [System.String]
        $Repository = 'deviceManagement/configurationPolicies',

        [Parameter()]
        [ValidateSet('v1.0', 'beta')]
        [System.String]
        $APIVersion = 'beta',

        [Parameter()]
        [System.String]
        $RootIdentifier = 'assignments'
    )

    try
    {
        $deviceManagementPolicyAssignments = @()
        $Uri = "/$APIVersion/$Repository/$DeviceConfigurationPolicyId/assign"

        foreach ($target in $targets)
        {
            $targetAssignment = @{}
            $formattedTarget = @{'@odata.type' = $target.dataType }
            if ($null -ne $target.runRemediationScript)
            {
                $targetAssignment.Add('runRemediationScript', $target.runRemediationScript)
            }
            if ($null -ne $target.runSchedule)
            {
                $targetAssignment.Add('runSchedule', $target.runSchedule)
            }
            if ($target.target -is [hashtable])
            {
                $target = $target.target
            }
            if (-not $formattedTarget.'@odata.type' -and $target.'@odata.type')
            {
                $formattedTarget.'@odata.type' = $target.'@odata.type'
            }
            if ($target.groupId)
            {
                $group = Get-M365DSCIntuneGroup -GroupId $target.groupId
                if ($null -eq $group)
                {
                    if ($target.groupDisplayName)
                    {
                        [array]$group = Get-M365DSCIntuneGroup -DisplayName $target.groupDisplayName
                        if ($null -eq $group -or $group.Count -eq 0)
                        {
                            $message = "Skipping assignment for the group with DisplayName {$($target.groupDisplayName)} as it could not be found in the directory.`r`n"
                            $message += 'Please update your DSC resource extract with the correct groupId or groupDisplayName.'
                            Write-Warning -Message $message
                            continue
                        }
                        if ($group -and $group.Count -gt 1)
                        {
                            $message = "Skipping assignment for the group with DisplayName {$($target.groupDisplayName)} as it is not unique in the directory.`r`n"
                            $message += 'Please update your DSC resource extract with the correct groupId or a unique group DisplayName.'
                            Write-Warning -Message $message
                            continue
                        }
                    }
                    else
                    {
                        $message = "Skipping assignment for the group with Id {$($target.groupId)} as it could not be found in the directory.`r`n"
                        $message += 'Please update your DSC resource extract with the correct groupId or a unique group DisplayName.'
                        Write-Warning -Message $message
                        continue
                    }
                }
                #Skipping assignment if group not found from either groupId or groupDisplayName
                if ($null -ne $group)
                {
                    $formattedTarget.Add('groupId', $group.Id)
                }
            }
            if ($target.collectionId)
            {
                $formattedTarget.Add('collectionId', $target.collectionId)
            }
            if ($target.deviceAndAppManagementAssignmentFilterType)
            {
                $formattedTarget.Add('deviceAndAppManagementAssignmentFilterType', $target.deviceAndAppManagementAssignmentFilterType)
            }
            if ($target.deviceAndAppManagementAssignmentFilterId)
            {
                $formattedTarget.Add('deviceAndAppManagementAssignmentFilterId', $target.deviceAndAppManagementAssignmentFilterId)
            }
            $targetAssignment.Add('target', $formattedTarget)
            $deviceManagementPolicyAssignments += $targetAssignment
        }

        $body = @{$RootIdentifier = $deviceManagementPolicyAssignments } | ConvertTo-Json -Depth 20
        Write-Verbose -Message $body

        Invoke-MgGraphRequest -Method POST -Uri $Uri -Body $body -ErrorAction Stop
    }
    catch
    {
        $message = "Failed to update the assignments of policy {$DeviceConfigurationPolicyId}: $($_.ToString())"
        New-M365DSCLogEntry -Message $message `
            -Exception $_ `
            -Source $($MyInvocation.MyCommand.Source) `
            -TenantId $TenantId `
            -Credential $Credential

        throw $message
    }
}

<#
.SYNOPSIS
    Updates assignments on an Intune app management policy.

.DESCRIPTION
    Creates and submits mobile app assignment payloads for the target app policy.
    The function resolves assignment groups and filter settings before posting the payload to Graph.
    Throws when Graph rejects the assignments.

.PARAMETER AppManagementPolicyId
    Specifies the identifier of the app management policy to update.

.PARAMETER Assignments
    Specifies the mobile app assignments to apply.

.PARAMETER Repository
    Specifies the Graph repository segment used to address the app resource.

.PARAMETER APIVersion
    Specifies the Graph API version to call.

.PARAMETER RootIdentifier
    Specifies the root property name used for the assignment payload body.

.OUTPUTS
    System.Collections.Hashtable
#>
function Update-DeviceAppManagementPolicyAssignment
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param (
        [Parameter(Mandatory = $true)]
        [System.String]
        $AppManagementPolicyId,

        [Parameter()]
        [Array]
        $Assignments,

        [Parameter()]
        [System.String]
        $Repository = 'deviceAppManagement/mobileApps',

        [Parameter()]
        [ValidateSet('v1.0', 'beta')]
        [System.String]
        $APIVersion = 'beta',

        [Parameter()]
        [System.String]
        $RootIdentifier = 'mobileAppAssignments'
    )

    try
    {
        $appManagementPolicyAssignments = @()
        $Uri = "/$APIVersion/$Repository/$AppManagementPolicyId/assign"

        foreach ($assignment in $Assignments)
        {
            $formattedAssignment = @{
                '@odata.type' = '#microsoft.graph.mobileAppAssignment'
                intent        = $assignment.intent
            }
            if ($assignment.settings)
            {
                $formattedAssignment.Add('settings', $assignment.settings)
            }

            if ($assignment.target -is [hashtable])
            {
                $target = $assignment.target
            }

            $formattedTarget = @{'@odata.type' = $target.dataType }
            if (-not $formattedTarget.'@odata.type' -and $target.'@odata.type')
            {
                $formattedTarget.'@odata.type' = $target.'@odata.type'
            }
            if ($target.groupId)
            {
                $group = Get-M365DSCIntuneGroup -GroupId $target.groupId
                if ($null -eq $group)
                {
                    if ($target.groupDisplayName)
                    {
                        [array]$group = Get-M365DSCIntuneGroup -DisplayName $target.groupDisplayName
                        if ($null -eq $group -or $group.Count -eq 0)
                        {
                            $message = "Skipping assignment for the group with DisplayName {$($target.groupDisplayName)} as it could not be found in the directory.`r`n"
                            $message += 'Please update your DSC resource extract with the correct groupId or groupDisplayName.'
                            Write-Warning -Message $message
                            continue
                        }
                        if ($group -and $group.Count -gt 1)
                        {
                            $message = "Skipping assignment for the group with DisplayName {$($target.groupDisplayName)} as it is not unique in the directory.`r`n"
                            $message += 'Please update your DSC resource extract with the correct groupId or a unique group DisplayName.'
                            Write-Warning -Message $message
                            continue
                        }
                    }
                    else
                    {
                        $message = "Skipping assignment for the group with Id {$($target.groupId)} as it could not be found in the directory.`r`n"
                        $message += 'Please update your DSC resource extract with the correct groupId or a unique group DisplayName.'
                        Write-Warning -Message $message
                        continue
                    }
                }
                #Skipping assignment if group not found from either groupId or groupDisplayName
                if ($null -ne $group)
                {
                    $formattedTarget.Add('groupId', $group.Id)
                }
            }
            if ($target.deviceAndAppManagementAssignmentFilterType)
            {
                $formattedTarget.Add('deviceAndAppManagementAssignmentFilterType', $target.deviceAndAppManagementAssignmentFilterType)
            }
            if ($target.deviceAndAppManagementAssignmentFilterId)
            {
                $formattedTarget.Add('deviceAndAppManagementAssignmentFilterId', $target.deviceAndAppManagementAssignmentFilterId)
            }
            $formattedAssignment.Add('target', $formattedTarget)
            $appManagementPolicyAssignments += $formattedAssignment
        }

        $body = @{ $RootIdentifier = $appManagementPolicyAssignments } | ConvertTo-Json -Depth 20
        Write-Verbose -Message $body

        Invoke-MgGraphRequest -Method POST -Uri $Uri -Body $body -ErrorAction Stop
    }
    catch
    {
        $message = "Failed to update the assignments of policy {$AppManagementPolicyId}: $($_.ToString())"
        New-M365DSCLogEntry -Message $message `
            -Exception $_ `
            -Source $($MyInvocation.MyCommand.Source) `
            -TenantId $TenantId `
            -Credential $Credential

        throw $message
    }
}

<#
.SYNOPSIS
    Waits until an Intune mobile app is published.

.DESCRIPTION
    Reads the publishing state of the app until it is published or the attempts are used up.
    Graph accepts assignments only for a published app. Returns after one read when the app is already published.

.PARAMETER AppId
    Specifies the identifier of the mobile app.

.PARAMETER MaxAttempts
    Specifies the maximum number of reads. Default is 6.

.PARAMETER RetryDelayInSeconds
    Specifies the delay between reads. Default is 3 seconds.
#>
function Wait-M365DSCIntuneMobileAppPublished
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [System.String]
        $AppId,

        [Parameter()]
        [System.Int32]
        $MaxAttempts = 6,

        [Parameter()]
        [System.Int32]
        $RetryDelayInSeconds = 3
    )

    $uri = "/beta/deviceAppManagement/mobileApps/$($AppId)?`$select=publishingState"
    $null = Wait-M365DSCCondition -Description "the publishing of mobile app {$AppId}" `
        -MaxAttempts $MaxAttempts `
        -RetryDelayInSeconds $RetryDelayInSeconds `
        -ScriptBlock {
            (Invoke-MgGraphRequest -Method GET -Uri $uri -ErrorAction Stop).publishingState -eq 'published'
        }
}

<#
.SYNOPSIS
    Synchronizes Intune mobile app category assignments.

.DESCRIPTION
    Adds or removes mobile app categories for a target app.
    In compare mode, it computes differences and only applies required adds or removals.

.PARAMETER App
    Specifies the mobile app object to update.

.PARAMETER Categories
    Specifies the category set to add or compare against.

.PARAMETER Compare
    Indicates that categories should be reconciled by difference instead of only added.
#>
function Update-DeviceAppManagementAppCategory
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        $App,

        [Parameter(Mandatory = $true)]
        [AllowEmptyCollection()]
        [Array]
        $Categories,

        [Parameter()]
        [switch]
        $Compare
    )

    if ($Compare)
    {
        [array]$referenceObject = if ($null -ne $App.Categories.DisplayName)
        {
            $App.Categories.DisplayName
        }
        else
        {
            , @()
        }
        [array]$differenceObject = if ($null -ne $Categories.DisplayName)
        {
            $Categories.DisplayName
        }
        else
        {
            , @()
        }
        $delta = Compare-Object -ReferenceObject $referenceObject -DifferenceObject $differenceObject -PassThru
        foreach ($diff in $delta)
        {
            if ($diff.SideIndicator -eq '=>')
            {
                $category = $Categories | Where-Object -Property DisplayName -EQ $diff
                if ($category.Id)
                {
                    $currentCategory = Get-MgBetaDeviceAppManagementMobileAppCategory -MobileAppCategoryId $category.Id -ErrorAction SilentlyContinue
                }

                if ($null -eq $currentCategory)
                {
                    $currentCategory = Get-MgBetaDeviceAppManagementMobileAppCategory -Filter "DisplayName eq '$($category.DisplayName -replace "'", "''")'"
                }

                if ($null -eq $currentCategory -or $currentCategory.Count -eq 0)
                {
                    throw "Mobile App Category with DisplayName $($category.DisplayName) not found."
                }

                Invoke-MgGraphRequest -Uri "/beta/deviceAppManagement/mobileApps/$($App.Id)/categories/`$ref" -Method 'POST' -Body @{
                    '@odata.id' = "$((Get-MSCloudLoginConnectionProfile -Workload MicrosoftGraph).ResourceUrl)beta/deviceAppManagement/mobileAppCategories/$($currentCategory.Id)"
                }
            }
            else
            {
                $category = $App.Categories | Where-Object -Property DisplayName -EQ $diff
                Invoke-MgGraphRequest -Uri "/beta/deviceAppManagement/mobileApps/$($App.Id)/categories/$($category.Id)/`$ref" -Method 'DELETE'
            }
        }
    }
    else
    {
        foreach ($category in $Categories)
        {
            if ($category.Id)
            {
                $currentCategory = Get-MgBetaDeviceAppManagementMobileAppCategory -MobileAppCategoryId $category.Id -ErrorAction SilentlyContinue
            }

            if ($null -eq $currentCategory)
            {
                $currentCategory = Get-MgBetaDeviceAppManagementMobileAppCategory -Filter "DisplayName eq '$($category.DisplayName -replace "'", "''")'"
            }

            if ($null -eq $currentCategory -or $currentCategory.Count -eq 0)
            {
                throw "Mobile App Category with DisplayName $($category.DisplayName) not found."
            }

            Invoke-MgGraphRequest -Uri "$((Get-MSCloudLoginConnectionProfile -Workload MicrosoftGraph).ResourceUrl)beta/deviceAppManagement/mobileApps/$($App.Id)/categories/`$ref" -Method 'POST' -Body @{
                '@odata.id' = "$((Get-MSCloudLoginConnectionProfile -Workload MicrosoftGraph).ResourceUrl)beta/deviceAppManagement/mobileAppCategories/$($currentCategory.Id)"
            }
        }
    }
}

<#
.SYNOPSIS
    Builds setting instances for an Intune configuration template.

.DESCRIPTION
    Retrieves recommended setting definitions for a template category and merges them with provided property values.
    The function outputs settings in the format expected by configuration policy update calls.

.PARAMETER Properties
    Specifies desired property values keyed by setting suffix.

.PARAMETER TemplateId
    Specifies the Intune configuration template identifier.

.OUTPUTS
    System.Collections.Hashtable
#>
function Get-M365DSCIntuneDeviceConfigurationSettings
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = 'true')]
        [System.Collections.Hashtable]
        $Properties,

        [Parameter()]
        [System.String]
        $TemplateId
    )

    $templateCategoryId = (Get-MgBetaDeviceManagementTemplateCategory -DeviceManagementTemplateId $TemplateId).Id
    $templateSettings = Get-MgBetaDeviceManagementTemplateCategoryRecommendedSetting `
        -DeviceManagementTemplateId $TemplateId `
        -DeviceManagementTemplateSettingCategoryId $templateCategoryId

    $results = @()
    foreach ($setting in $templateSettings)
    {
        $result = @{}
        $settingType = $setting.'@odata.type'
        $settingValue = $null
        $currentValueKey = $Properties.keys | Where-Object -FilterScript { $setting.DefinitionId -like "*$_" }
        if ($null -ne $currentValueKey)
        {
            $settingValue = $Properties.$currentValueKey
        }

        $requiresValueJson = $false
        switch ($settingType)
        {
            {
                ( $_ -eq '#microsoft.graph.deviceManagementStringSettingInstance' ) -or
                ( $_ -eq '#microsoft.graph.deviceManagementBooleanSettingInstance' )
            }
            {
                if ([String]::IsNullOrEmpty($settingValue))
                {
                    $settingValue = $setting.ValueJson | ConvertFrom-Json
                }
            }
            '#microsoft.graph.deviceManagementCollectionSettingInstance'
            {
                $requiresValueJson = $true
                if ($null -eq $settingValue)
                {
                    $settingValue = ConvertTo-Json -InputObject @()
                }
                else
                {
                    $settingValue = ConvertTo-Json -InputObject ([Array]$settingValue)
                }
            }
            default
            {
                if ($null -eq $settingValue)
                {
                    $settingValue = $setting.ValueJson | ConvertFrom-Json
                }
            }
        }

        $result.Add('@odata.type', $settingType)
        $result.Add('Id', $setting.Id)
        $result.Add('definitionId', $setting.DefinitionId)

        if ($requiresValueJson)
        {
            $result.Add('valueJson', $settingValue)
        }
        else
        {
            $result.Add('value', $settingValue)
        }

        $results += $result
    }

    return $results
}

<#
.SYNOPSIS
    Retrieves the decrypted value for an OMA setting secret reference.

.DESCRIPTION
    Extracts the parent policy identifier from a secret reference value id and calls Graph to return the plain-text OMA setting value.
    Returns null when the identifier is invalid or decryption fails.

.PARAMETER SecretReferenceValueId
    Specifies the secret reference identifier associated with an encrypted OMA setting value.

.PARAMETER APIVersion
    Specifies the Graph API version to call.

.OUTPUTS
    System.String
#>
function Get-OmaSettingPlainTextValue
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param(
        [Parameter(Mandatory = $true)]
        [System.String]
        $SecretReferenceValueId,

        [Parameter()]
        [ValidateSet('v1.0', 'beta')]
        [System.String]
        $APIVersion = 'beta'
    )

    try
    {
        <#
            e.g. PolicyId for SecretReferenceValueId '35ea58ec-2a79-471d-8eea-7e28e6cd2722_bdf6c690-05fb-4d02-835d-5a7406c35d58_abe32712-2255-445f-a35e-0c6f143d82ca'
            is 'bdf6c690-05fb-4d02-835d-5a7406c35d58'
        #>
        $SplitSecretReferenceValueId = $SecretReferenceValueId.Split('_')
        if ($SplitSecretReferenceValueId.Count -eq 3)
        {
            $PolicyId = $SplitSecretReferenceValueId[1]
        }
        else
        {
            return $null
        }
    }
    catch
    {
        return $null
    }

    $Repository = 'deviceManagement/deviceConfigurations'
    $Uri = "/{0}/{1}/{2}/getOmaSettingPlainTextValue(secretReferenceValueId='{3}')" -f $APIVersion, $Repository, $PolicyId, $SecretReferenceValueId

    try
    {
        $Result = Invoke-MgGraphRequest -Method GET -Uri $Uri -ErrorAction Stop
    }
    catch
    {
        $Message = 'Error decrypting OmaSetting with SecretReferenceValueId {0}:' -f $SecretReferenceValueId
        New-M365DSCLogEntry -Message $Message `
            -Exception $_ `
            -Source $($MyInvocation.MyCommand.Source) `
            -TenantId $TenantId `
            -Credential $Credential

        return $null
    }

    if (![String]::IsNullOrEmpty($Result.Value))
    {
        return $Result.Value
    }
    else
    {
        return $null
    }
}

<#
.SYNOPSIS
    Constructs setting catalog policy settings from DSC parameters.

.DESCRIPTION
    Builds setting catalog policy setting objects from DSC input values.
    It can start from a template id or use preloaded setting templates for nested calls.

.PARAMETER DSCParams
    Specifies DSC parameter values used to build setting instances.

.PARAMETER TemplateId
    Specifies the setting catalog template identifier used in the Start parameter set.

.PARAMETER SettingTemplates
    Specifies preloaded setting templates used in the DeviceAndUserSettings parameter set.

.PARAMETER ContainsDeviceAndUserSettings
    Indicates whether the policy contains both device and user settings.

.OUTPUTS
    System.Object[]
#>
function Get-IntuneSettingCatalogPolicySetting
{
    [CmdletBinding()]
    [OutputType([System.Object[]])]
    param (
        [Parameter(Mandatory = $true)]
        [System.Collections.Hashtable]
        $DSCParams,

        [Parameter(
            Mandatory = 'true',
            ParameterSetName = 'Start'
        )]
        [System.String]
        $TemplateId,

        [Parameter(
            Mandatory = 'true',
            ParameterSetName = 'DeviceAndUserSettings'
        )]
        [System.Array]
        $SettingTemplates,

        [Parameter(ParameterSetName = 'Start')]
        [switch]
        $ContainsDeviceAndUserSettings
    )

    $DSCParams.Remove('Identity') | Out-Null
    $DSCParams.Remove('DisplayName') | Out-Null
    $DSCParams.Remove('Description') | Out-Null

    if ($PSCmdlet.ParameterSetName -eq 'Start')
    {
        $SettingTemplates = Get-M365DSCSettingCatalogTemplate -TemplateId $TemplateId
    }

    Initialize-M365DSCDllLoader -ErrorAction Stop

    return ,[Microsoft365DSC.Intune.SettingCatalogPolicySettingBuilder]::Build(
        [System.Collections.Generic.List[object]]@($SettingTemplates),
        $DSCParams,
        $ContainsDeviceAndUserSettings.IsPresent)
}

<#
.SYNOPSIS
    Returns the setting templates of a Settings Catalog template, with their setting definitions.

.DESCRIPTION
    Fetches the template once per process and serves every later request for the same template id
    from the cache. The payload of a security baseline runs to several megabytes, and every Set of
    every instance would otherwise download it again.

.PARAMETER TemplateId
    Specifies the configuration policy template id, including its version suffix.

.EXAMPLE
    Get-M365DSCSettingCatalogTemplate -TemplateId '66df8dce-0166-4b82-92f7-1f74e3ca17a3_4'

.OUTPUTS
    System.Object[]
#>
function Get-M365DSCSettingCatalogTemplate
{
    [CmdletBinding()]
    [OutputType([System.Object[]])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $TemplateId
    )

    $templates = Get-M365DSCCachedSettingCatalogTemplate -TemplateId $TemplateId
    if ($null -ne $templates)
    {
        return , $templates
    }

    $templates = [System.Object[]] @(Get-MgBetaDeviceManagementConfigurationPolicyTemplateSettingTemplate `
            -DeviceManagementConfigurationPolicyTemplateId $TemplateId `
            -ExpandProperty 'settingDefinitions' `
            -All `
            -ErrorAction Stop)
    Set-M365DSCCachedSettingCatalogTemplate -TemplateId $TemplateId -Templates $templates

    return , $templates
}

<#
.SYNOPSIS
    Returns the cached setting templates of a Settings Catalog template, or null on a miss.

.PARAMETER TemplateId
    Specifies the configuration policy template id, including its version suffix.

.OUTPUTS
    System.Object[]
#>
function Get-M365DSCCachedSettingCatalogTemplate
{
    [CmdletBinding()]
    [OutputType([System.Object[]])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $TemplateId
    )

    Initialize-M365DSCDllLoader -ErrorAction Stop

    $templates = $null
    if ([Microsoft365DSC.Intune.SettingTemplateCache]::TryGet($TemplateId, [ref] $templates))
    {
        return , $templates
    }

    return $null
}

<#
.SYNOPSIS
    Stores the setting templates of a Settings Catalog template for the rest of the process.

.PARAMETER TemplateId
    Specifies the configuration policy template id, including its version suffix.

.PARAMETER Templates
    Specifies the setting templates, each carrying its setting definitions.
#>
function Set-M365DSCCachedSettingCatalogTemplate
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $TemplateId,

        [Parameter(Mandatory = $true)]
        [System.Object[]]
        $Templates
    )

    Initialize-M365DSCDllLoader -ErrorAction Stop
    [Microsoft365DSC.Intune.SettingTemplateCache]::Set($TemplateId, $Templates)
}

<#
.SYNOPSIS
    Exports Intune setting catalog settings into DSC hashtable format.

.DESCRIPTION
    Converts setting catalog instances from Graph into the return hashtable used by export routines.
    It supports root export execution and nested setting processing flows.

.PARAMETER Settings
    Specifies the settings collection to export in the Start parameter set.

.PARAMETER ReturnHashtable
    Specifies the hashtable that receives exported values.

.PARAMETER SettingInstance
    Specifies the current setting instance to process in the Setting parameter set.

.PARAMETER SettingDefinitions
    Specifies setting definitions used when processing a single setting instance.

.PARAMETER AllSettingDefinitions
    Specifies all available setting definitions for name and value resolution.

.PARAMETER IsRoot
    Indicates that the current setting instance is processed as a root node.

.PARAMETER ContainsDeviceAndUserSettings
    Indicates whether the policy contains both device and user settings.

.OUTPUTS
    System.Collections.Hashtable
#>
function Export-IntuneSettingCatalogPolicySettings
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param(
        [Parameter(
            Mandatory = $true,
            ParameterSetName = 'Start'
        )]
        $Settings,

        [Parameter(
            Mandatory = $true
        )]
        [System.Collections.Hashtable]$ReturnHashtable,

        [Parameter(
            Mandatory = $true,
            ParameterSetName = 'Setting'
        )]
        $SettingInstance,

        [Parameter(
            Mandatory = $true,
            ParameterSetName = 'Setting'
        )]
        $SettingDefinitions,

        [Parameter(
            Mandatory = $true,
            ParameterSetName = 'Setting'
        )]
        [Parameter(
            ParameterSetName = 'Start'
        )]
        [System.Array]
        $AllSettingDefinitions,

        [Parameter(
            ParameterSetName = 'Setting'
        )]
        [switch]$IsRoot,

        [Parameter(
            ParameterSetName = 'Start'
        )]
        [switch]$ContainsDeviceAndUserSettings
    )

    Initialize-M365DSCDllLoader -ErrorAction Stop

    return [Microsoft365DSC.Intune.SettingCatalogPolicyExporter]::Export($Settings, $ReturnHashtable, $AllSettingDefinitions, $ContainsDeviceAndUserSettings)
}

<#
.SYNOPSIS
    Updates an Intune configuration policy definition.

.DESCRIPTION
    Builds a policy update payload and sends it to the Intune configuration policy endpoint.
    Optional template and creation source values are included only when supplied.

.PARAMETER DeviceConfigurationPolicyId
    Specifies the identifier of the configuration policy to update.

.PARAMETER Name
    Specifies the policy display name.

.PARAMETER Description
    Specifies the policy description.

.PARAMETER Platforms
    Specifies the target platform value for the policy.

.PARAMETER Technologies
    Specifies the technologies value for the policy.

.PARAMETER TemplateReferenceId
    Specifies the template identifier to reference in the policy payload.

.PARAMETER CreationSource
    Specifies the creation source value to include in the payload.

.PARAMETER Settings
    Specifies the settings collection to apply to the policy.

.PARAMETER RoleScopeTagIds
    Specifies role scope tag identifiers assigned to the policy.

.OUTPUTS
    System.Collections.Hashtable
#>
function Update-IntuneDeviceConfigurationPolicy
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = 'true')]
        [System.String]
        $DeviceConfigurationPolicyId,

        [Parameter()]
        [System.String]
        $Name,

        [Parameter()]
        [System.String]
        $Description,

        [Parameter()]
        [System.String]
        $Platforms,

        [Parameter()]
        [System.String]
        $Technologies,

        [Parameter()]
        [System.String]
        $TemplateReferenceId,

        [Parameter()]
        [AllowNull()]
        [System.String]
        $CreationSource,

        [Parameter()]
        [Array]
        $Settings,

        [Parameter()]
        [System.String[]]
        $RoleScopeTagIds
    )

    try
    {
        $Uri = (Get-MSCloudLoginConnectionProfile -Workload MicrosoftGraph).ResourceUrl + "beta/deviceManagement/configurationPolicies/$DeviceConfigurationPolicyId"

        $policy = @{
            'name'            = $Name
            'description'     = $Description
            'platforms'       = $Platforms
            'technologies'    = $Technologies
            'settings'        = $Settings
            'roleScopeTagIds' = $RoleScopeTagIds
        }

        if ($PSBoundParameters.ContainsKey('TemplateReferenceId'))
        {
            $policy.Add('templateReference', @{ 'templateId' = $TemplateReferenceId })
        }

        if ($PSBoundParameters.ContainsKey('CreationSource') -and -not [System.String]::IsNullOrEmpty($CreationSource))
        {
            $policy.Add('creationSource', $CreationSource)
        }

        $body = $policy | ConvertTo-Json -Depth 20
        Write-Verbose -Message "Updating policy with:`r`n$body"
        Invoke-MgGraphRequest -Method PUT -Uri $Uri -Body $body -ErrorAction Stop
    }
    catch
    {
        New-M365DSCLogEntry -Message 'Error updating data:' `
            -Exception $_ `
            -Source $($MyInvocation.MyCommand.Source) `
            -TenantId $TenantId `
            -Credential $Credential

        throw
    }
}

<#
.SYNOPSIS
    Extracts startswith, endswith, and contains clauses from a filter query.

.DESCRIPTION
    Parses an OData-like filter string and returns complex function fragments.
    These fragments can then be evaluated against in-memory policy objects.

.PARAMETER FilterQuery
    Specifies the filter query string to parse.

.OUTPUTS
    System.Array
#>
function Get-ComplexFunctionsFromFilterQuery
{
    [CmdletBinding()]
    [OutputType([System.Array])]
    param (
        [string]$FilterQuery
    )

    $complexFunctionsRegex = "startswith\((.*?),\s*'(.*?)'\)|endswith\((.*?),\s*'(.*?)'\)|contains\((.*?),\s*'(.*?)'\)"
    [array]$complexFunctions = [regex]::Matches($FilterQuery, $complexFunctionsRegex) | ForEach-Object {
        $_.Value
    }

    return $complexFunctions
}

<#
.SYNOPSIS
    Removes complex function clauses from a filter query.

.DESCRIPTION
    Removes startswith, endswith, and contains clauses from an OData-like filter string.
    The resulting query can be sent to Graph while complex predicates are evaluated locally.

.PARAMETER FilterQuery
    Specifies the filter query string to simplify.

.OUTPUTS
    System.String
#>
function Remove-ComplexFunctionsFromFilterQuery
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param (
        [string]$FilterQuery
    )

    $complexFunctionsRegex = "startswith\((.*?),\s*'(.*?)'\)|endswith\((.*?),\s*'(.*?)'\)|contains\((.*?),\s*'(.*?)'\)"
    $basicFilterQuery = [regex]::Replace($FilterQuery, $complexFunctionsRegex, '').Trim()
    $basicFilterQuery = $basicFilterQuery -replace '^and\s', '' -replace '\sand$', '' -replace '\sand\s+', ' and ' -replace '\sor\s+', ' or '

    return $basicFilterQuery
}

<#
.SYNOPSIS
    Applies complex filter function fragments to a policy collection.

.DESCRIPTION
    Evaluates startswith, endswith, and contains predicates against policy properties.
    Returns only policies that satisfy all provided complex function conditions.

.PARAMETER Policies
    Specifies the policy collection to filter.

.PARAMETER ComplexFunctions
    Specifies parsed complex function expressions to apply.

.OUTPUTS
    System.Array
#>
function Find-GraphDataUsingComplexFunctions
{
    [CmdletBinding()]
    [OutputType([System.Array])]
    param (
        [array]$Policies,
        [array]$ComplexFunctions
    )

    foreach ($function in $ComplexFunctions)
    {
        if ($function -match "startswith\((.*?),\s*'(.*?)'")
        {
            $property = $matches[1]
            $value = $matches[2]
            $Policies = $Policies | Where-Object -Property $property -Like "$value*"
        }
        elseif ($function -match "endswith\((.*?),\s*'(.*?)'")
        {
            $property = $matches[1]
            $value = $matches[2]
            $Policies = $Policies | Where-Object -Property $property -Like "*$value"
        }
        elseif ($function -match "contains\((.*?),\s*'(.*?)'")
        {
            $property = $matches[1]
            $value = $matches[2]
            $Policies = $Policies | Where-Object -Property $property -Like "*$value*"
        }
    }

    return $Policies
}

<#
.SYNOPSIS
    Performs the initial content upload flow for an Intune mobile app.

.DESCRIPTION
    Creates a content version and placeholder file, uploads sample encrypted content to Azure Storage, commits the file, and updates the app with the committed content version.
    This helper supports app creation flows that require an initial content artifact.

.PARAMETER AppId
    Specifies the target mobile app identifier.

.PARAMETER OdataType
    Specifies the mobile app OData type used for content endpoints.

.PARAMETER FileExtension
    Specifies the file extension used when creating the sample content file.
#>
function Invoke-M365DSCIntuneMobileAppInitialUpload
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [System.String]
        $AppId,

        [Parameter(Mandatory = $true)]
        [System.String]
        $OdataType,

        [Parameter(Mandatory = $true)]
        [System.String]
        $FileExtension
    )

    $OdataType = $OdataType.Replace('#', '')
    $contentVersionsUri = "beta/deviceAppManagement/mobileApps/$($AppId)/$OdataType/contentVersions"
    $contentVersion = Invoke-MgGraphRequest -Method POST -Uri $contentVersionsUri -Body @{}

    $manifest = $null
    $size = 1
    $sizeEncrypted = 64
    $base64File = '+drh1SKfuLjdp37gfv8EuWqOTt06m0TirqJJ0xQvrd5sm6NkiYBY8vBkFM+9ZwHRskO83NEfsLPtTzLB9FFsKA=='
    $encryptionKey = 'yqjlzT5KYpwU0wkr5eJGGukMB0Ar8iGqYX3B0lJJnKk='
    $fileDigest = 'ypeBEsobvcr6wjGzmiPcTaeG7/gUfE5yuYB3ha/uSLs='
    $initializationVector = 'bJujZImAWPLwZBTPvWcB0Q=='
    $mac = '+drh1SKfuLjdp37gfv8EuWqOTt06m0TirqJJ0xQvrd4='
    $macKey = 'mGfhTn/0AB3fftWzENQcoU34xghAfvVq23PoiBD81tM='
    switch ($OdataType)
    {
        'microsoft.graph.androidLobApp'
        {
            $size = 13168
            $sizeEncrypted = 13232
            $manifest = $([System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes('<?xml version="1.0" encoding="utf-8"?><AndroidManifestProperties xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><Package>a.a</Package><PackageVersionCode>1</PackageVersionCode><PackageVersionName>1.0</PackageVersionName><ApplicationName>Sample.apk</ApplicationName><MinSdkVersion>24</MinSdkVersion><AWTVersion></AWTVersion></AndroidManifestProperties>')))
            $base64File = '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'
            $encryptionKey = '3uV+NpJnmT5vaufsl9xalZJqwpFmACdOT1OQH9LBJNQ='
            $fileDigest = 'EVykpzyjw9oNRwY4NR/JJNC7rjgSauvcOcuQ/hjHQu0='
            $initializationVector = 'd/kzcmL9UjjMlPxQdPIA6g=='
            $mac = 'l+rn68BUBB1/+Od1k1JnMcqcbzrbf7vhcy+zofWz6YY='
            $macKey = 'kb7oEqtP0SJGiy6jrkj0rUggcCmkcb3AkFkXTYovnLc='
        }
        'microsoft.graph.windowsMobileMSI'
        {
            $manifest = $([System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes('<MobileMsiData MsiExecutionContext="User" MsiRequiresReboot="false" MsiUpgradeCode="{00000000-0000-0000-0000-000000000000}" MsiIsMachineInstall="false" MsiIsUserInstall="true" MsiRequiresLogon="true" MsiIncludesServices="false" MsiContainsSystemRegistryKeys="false" MsiContainsSystemFolders="false"></MobileMsiData>')))
        }
        'microsoft.graph.windowsUniversalAppx'
        {
            $manifest = $([System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes("Sample.$($FileExtension)".ToUpper())))
        }
    }

    $fileUri = "beta/deviceAppManagement/mobileApps/$($AppId)/$OdataType/contentVersions/$($contentVersion.id)/files"
    if ($OdataType -eq 'microsoft.graph.windowsUniversalAppx')
    {
        # Manifest is required for Windows Universal Appx
        $manifest = $([System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes("Sample.$($FileExtension)".ToUpper())))
    }
    elseif ($OdataType -eq 'microsoft.graph.windowsMobileMSI')
    {
        # Manifest is required for Windows Mobile MSI
        $manifest = $([System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes('<MobileMsiData MsiExecutionContext="User" MsiRequiresReboot="false" MsiUpgradeCode="{00000000-0000-0000-0000-000000000000}" MsiIsMachineInstall="false" MsiIsUserInstall="true" MsiRequiresLogon="true" MsiIncludesServices="false" MsiContainsSystemRegistryKeys="false" MsiContainsSystemFolders="false"></MobileMsiData>')))
    }
    $file = Invoke-MgGraphRequest -Method POST `
        -Uri $fileUri `
        -Body @{
            '@odata.type' = '#microsoft.graph.mobileAppContentFile'
            name          = "Sample.$($FileExtension)"
            size          = $size
            sizeEncrypted = $sizeEncrypted
            isDependency  = $false
            manifest      = $manifest
        }

    $file = Wait-ForFileProcessing -AppId $AppId -OdataType $OdataType -FileId $file.id -ContentVersionId $contentVersion.id -UploadStatePrefix 'AzureStorageUriRequest'

    # Upload the encrypted Sample file to Azure Storage
    $success = $false
    $breakCounter = 0
    do
    {
        try
        {
            Write-Verbose "Uploading file to Azure Storage: $($file.azureStorageUri)"
            $sasUri = $file.azureStorageUri
            $uri = "$($sasUri)&comp=block&blockid=0001"
            $iso = [System.Text.Encoding]::GetEncoding('iso-8859-1')
            $body = [System.Convert]::FromBase64String($base64File)
            $encodedBody = $iso.GetString($body)
            Invoke-WebRequest -Uri $uri -Method PUT -Body $encodedBody -Headers @{
                'content-type' = 'text/plain; charset=iso-8859-1'
                'x-ms-blob-type' = 'BlockBlob'
            } -ErrorAction Stop -UseBasicParsing | Out-Null
            Write-Verbose 'File uploaded successfully to Azure Storage.'
            $success = $true
        }
        catch
        {
            Write-Warning -Message "Failed to upload file to Azure Storage: $($_.Exception.Message)"
            Start-Sleep -Seconds 2
        }
    } while ($success -eq $false -and $breakCounter -lt 5)

    # Finalize the upload to Azure Storage
    $uri = "$($sasUri)&comp=blocklist"
    $xml = '<?xml version="1.0" encoding="utf-8"?><BlockList><Latest>0001</Latest></BlockList>'
    Invoke-RestMethod -Uri $uri -Method PUT -Body $xml

    # Commit the file and update the app
    $jsonCommit = @{
        fileEncryptionInfo = @{
            fileDigestAlgorithm  = 'SHA256'
            encryptionKey        = $encryptionKey
            initializationVector = $initializationVector
            fileDigest           = $fileDigest
            mac                  = $mac
            profileIdentifier    = 'ProfileVersion1'
            macKey               = $macKey
        }
    }
    $commitUri = "beta/deviceAppManagement/mobileApps/$AppId/$OdataType/contentVersions/$($contentVersion.id)/files/$($file.id)/commit"
    Invoke-MgGraphRequest -Method POST -Uri $commitUri -Body $($jsonCommit | ConvertTo-Json -Depth 10)

    Wait-ForFileProcessing -AppId $AppId -OdataType $OdataType -FileId $file.id -ContentVersionId $contentVersion.id -UploadStatePrefix 'CommitFile'

    # Update the app with the committed content version
    Invoke-MgGraphRequest -Method PATCH -Uri "beta/deviceAppManagement/mobileApps/$AppId" -Body @{
        '@odata.type'           = "#$OdataType"
        committedContentVersion = '1'
    }
}

<#
.SYNOPSIS
    Waits until Intune mobile app content file processing completes.

.DESCRIPTION
    Polls the mobile app content file endpoint until the upload state reaches the expected success state.
    Throws when the upload state enters a failure state.

.PARAMETER AppId
    Specifies the target mobile app identifier.

.PARAMETER OdataType
    Specifies the mobile app OData type used for the file endpoint.

.PARAMETER FileId
    Specifies the content file identifier.

.PARAMETER ContentVersionId
    Specifies the content version identifier containing the file.

.PARAMETER UploadStatePrefix
    Specifies the upload state prefix that is combined with Success for completion checks.

.OUTPUTS
    System.Object
#>
function Wait-ForFileProcessing
{
    [CmdletBinding()]
    [OutputType([System.Object])]
    param (
        [Parameter(Mandatory = $true)]
        [System.String]
        $AppId,

        [Parameter(Mandatory = $true)]
        [System.String]
        $OdataType,

        [Parameter(Mandatory = $true)]
        [System.String]
        $FileId,

        [Parameter(Mandatory = $true)]
        [System.String]
        $ContentVersionId,

        [Parameter(Mandatory = $true)]
        [System.String]
        $UploadStatePrefix
    )

    $fileUri = "beta/deviceAppManagement/mobileApps/$($AppId)/$OdataType/contentVersions/$ContentVersionId/files/$($FileId)"

    Write-Verbose "Waiting for file processing to complete for AppId: $AppId, OdataType: $OdataType, FileId: $FileId, ContentVersionId: $ContentVersionId"
    $file = Invoke-MgGraphRequest -Method GET -Uri $fileUri

    while ($file.uploadState -ne "$($UploadStatePrefix)Success")
    {
        if ($file.uploadState -like '*Failed')
        {
            throw "File upload failed with state: $($file.uploadState). Please check the file and try again."
        }

        Start-Sleep -Seconds 1
        Write-Verbose "Current upload state: $($file.uploadState). Waiting for processing to complete..."
        $file = Invoke-MgGraphRequest -Method GET -Uri $fileUri
    }

    $file
}

<#
.SYNOPSIS
    Clears the cached Intune assignment filters.

.DESCRIPTION
    Removes the assignment filters cached by the assignment conversion functions. The next
    conversion reads them from the tenant again.
#>
function Clear-M365DSCIntuneAssignmentFilterCache
{
    [CmdletBinding()]
    param ()

    $Script:IntuneAssignmentFilters = $null
}

Export-ModuleMember -Function @(
    'Clear-M365DSCIntuneAssignmentFilterCache',
    'Compare-M365DSCIntunePolicyAssignment',
    'ConvertFrom-IntuneMobileAppAssignment',
    'ConvertFrom-IntunePolicyAssignment',
    'ConvertTo-IntuneMobileAppAssignment',
    'ConvertTo-IntunePolicyAssignment',
    'Export-IntuneSettingCatalogPolicySettings',
    'Find-GraphDataUsingComplexFunctions',
    'Get-ComplexFunctionsFromFilterQuery',
    'Get-IntuneSettingCatalogPolicySetting',
    'Get-M365DSCExportCachedConfigurationPolicies',
    'Get-M365DSCCachedSettingCatalogTemplate',
    'Get-M365DSCSettingCatalogTemplate',
    'Set-M365DSCCachedSettingCatalogTemplate',
    'Get-M365DSCIntuneDeviceConfigurationSettings',
    'Get-M365DSCIntuneExpandedAssignments',
    'Get-M365DSCIntuneGroup',
    'Get-OmaSettingPlainTextValue',
    'Invoke-M365DSCIntuneMobileAppInitialUpload',
    'Remove-ComplexFunctionsFromFilterQuery',
    'Resolve-M365DSCIntuneRoleScopeTagIds',
    'Resolve-M365DSCIntuneRoleScopeTagNames',
    'Update-DeviceAppManagementAppCategory',
    'Update-DeviceAppManagementPolicyAssignment',
    'Update-DeviceConfigurationPolicyAssignment',
    'Update-IntuneDeviceConfigurationPolicy',
    'Wait-ForFileProcessing',
    'Wait-M365DSCIntuneMobileAppPublished'
)
