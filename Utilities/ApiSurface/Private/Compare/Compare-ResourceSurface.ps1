<#
.SYNOPSIS
    Reports where a resource disagrees with the vendor type it was generated from.

.PARAMETER Baseline
    Specifies the previous snapshot.

.PARAMETER Current
    Specifies the snapshot just taken.

.PARAMETER Origin
    Specifies the resource rows from Get-ResourceOriginSurface.

.PARAMETER SchemaKeyword
    Specifies the DscSchemaCache keyword map, keyed by resource name.

.PARAMETER Exclusion
    Specifies the parsed exclusions.json.

.PARAMETER ExcludedProperty
    Specifies a map of resource name to its settings.json excludedProperties array.

.OUTPUTS
    An ordered dictionary with Findings, Coverage and Backlog.
#>
function Compare-ResourceSurface
{
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
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
        $Origin = @(),

        [Parameter()]
        [System.Collections.IDictionary]
        $SchemaKeyword = @{},

        [Parameter()]
        [AllowNull()]
        [System.Object]
        $Exclusion,

        [Parameter()]
        [System.Collections.IDictionary]
        $ExcludedProperty = @{}
    )

    $findings = [System.Collections.Generic.List[System.Object]]::new()
    $coverage = [System.Collections.Generic.List[System.Object]]::new()

    $currentTypes = Get-SurfaceMember -Container $Current -Name 'graphTypes'
    $baselineTypes = Get-SurfaceMember -Container $Baseline -Name 'graphTypes'
    $nonComparable = [System.String[]] @((Get-SurfaceMember -Container $Exclusion -Name 'nonComparableEntityTypes') | ForEach-Object -Process { [System.String] $_.entityType })

    $nonVendorProperty = [System.String[]] @((Get-SurfaceMember -Container $Exclusion -Name 'nonVendorProperties'))
    if ($nonVendorProperty.Count -eq 0)
    {
        $nonVendorProperty = Get-DefaultNonVendorProperty
    }

    $serviceManagedProperty = [System.String[]] @(@(Get-SurfaceMember -Container $Exclusion -Name 'serviceManagedProperties') |
            Where-Object { -not [System.String]::IsNullOrEmpty($_) })
    if ($serviceManagedProperty.Count -eq 0)
    {
        $serviceManagedProperty = Get-DefaultServiceManagedProperty
    }

    $globalReadOnly = @(Get-SurfaceMember -Container $Exclusion -Name 'globalReadOnlyProperties')

    $backlogTotal = 0

    $gateByResource = @{}
    $declaredByTypeKey = @{}
    foreach ($row in $Origin)
    {
        $probe = Test-ResourceComparable -Origin $row `
            -GraphType $currentTypes `
            -SchemaKeyword $SchemaKeyword `
            -NonComparableEntityType $nonComparable

        $gateByResource[$row.Resource] = $probe
        if (-not $probe.Comparable)
        {
            continue
        }

        if (-not $declaredByTypeKey.ContainsKey($probe.TypeKey))
        {
            $declaredByTypeKey[$probe.TypeKey] = [System.Collections.Generic.HashSet[System.String]]::new([System.StringComparer]::OrdinalIgnoreCase)
        }

        foreach ($name in (Get-SurfaceMemberName -Container $SchemaKeyword[$row.Resource].properties))
        {
            $null = $declaredByTypeKey[$probe.TypeKey].Add($name)
        }
    }

    foreach ($row in $Origin)
    {
        $gate = $gateByResource[$row.Resource]

        if (-not $gate.Comparable)
        {
            $coverage.Add([ordered]@{
                    resource   = $row.Resource
                    workload   = $row.Workload
                    compared   = $false
                    reason     = $gate.Reason
                    declared   = 0
                    vendorTop  = 0
                    backlog    = 0
                })
            continue
        }

        $typeName = @($gate.TypeName)

        $vendor = Expand-VendorPropertySet -GraphType $currentTypes `
            -ApiVersion $gate.ApiVersion `
            -TypeName $typeName `
            -IncludeNavigationProperties ([System.Boolean] $row.IncludeNavigationProperties)

        $baselineVendor = $null
        if ($null -ne (Get-SurfaceMember -Container $baselineTypes -Name $gate.TypeKey))
        {
            $baselineVendor = Expand-VendorPropertySet -GraphType $baselineTypes `
                -ApiVersion $gate.ApiVersion `
                -TypeName $typeName `
                -IncludeNavigationProperties ([System.Boolean] $row.IncludeNavigationProperties)
        }

        $keyword = $SchemaKeyword[$row.Resource]
        $declared = [ordered]@{}
        foreach ($name in (Get-SurfaceMemberName -Container $keyword.properties))
        {
            if ($name -in $nonVendorProperty)
            {
                continue
            }

            $declared[$name] = Get-SurfaceMember -Container $keyword.properties -Name $name
        }

        $exclusions = $ExcludedProperty[$row.Resource]
        $matchedVendorName = [System.Collections.Generic.HashSet[System.String]]::new([System.StringComparer]::Ordinal)

        foreach ($name in $declared.Keys)
        {
            $match = Resolve-PropertyName -Name $name -VendorProperty $vendor.Properties -LeafIndex $vendor.ByLeaf

            if (-not $match.Matched)
            {
                $suppression = Resolve-FindingExclusion -Exclusion $exclusions -Property $name
                if ($suppression.Suppressed)
                {
                    continue
                }

                $findings.Add((New-M365DSCApiSurfaceFinding -Code 'RES-PROP-ORPHANED' `
                            -Subject $row.Resource `
                            -Property $name `
                            -Resource $row.Resource `
                            -Workload $row.Workload `
                            -Severity $suppression.Severity `
                            -From ([ordered]@{ typeConstraint = [System.String] $declared[$name].typeConstraint }) `
                            -To $null `
                            -Evidence ([ordered]@{
                                source    = "csdl:$($gate.TypeKey -replace ':', '/')"
                                exclusion = $suppression.Reason
                            })))
                continue
            }

            $null = $matchedVendorName.Add($match.VendorName)
            $vendorProperty = $vendor.Properties[$match.VendorName]

            $findings.AddRange([System.Object[]] @(Compare-DeclaredProperty -Resource $row `
                        -Name $name `
                        -Declared $declared[$name] `
                        -Vendor $vendorProperty `
                        -TypeKey $gate.TypeKey `
                        -MatchRule ([System.String] $match.Rule) `
                        -Exclusion $exclusions))
        }

        foreach ($path in (Get-DeclaredVendorPath -Exclusion $exclusions))
        {
            if ($vendor.Properties.Contains($path))
            {
                $null = $matchedVendorName.Add($path)
            }
        }

        $flattenedContainer = Get-FlattenedContainer -MatchedPath $matchedVendorName
        $siblingOwner = $declaredByTypeKey[$gate.TypeKey]

        $backlog = 0
        foreach ($vendorName in $vendor.Properties.Keys)
        {
            $vendorProperty = $vendor.Properties[$vendorName]
            if ($matchedVendorName.Contains($vendorName))
            {
                continue
            }

            $nested = $vendorProperty.Level -ne 0
            if ($nested -and -not (Test-FlattenedSibling -Path $vendorName `
                        -Container $flattenedContainer `
                        -Vendor $vendorProperty `
                        -ServiceManagedProperty $serviceManagedProperty))
            {
                continue
            }

            $dscName = if ($nested)
            {
                ConvertTo-FlattenedDscPropertyName -Path $vendorName
            }
            else
            {
                ConvertTo-DscPropertyName -Name $vendorName
            }

            if ($declared.Contains($dscName) -or $dscName -in $nonVendorProperty)
            {
                continue
            }

            if ($nested -and $null -ne $siblingOwner -and
                ($siblingOwner.Contains($dscName) -or $siblingOwner.Contains((ConvertTo-DscPropertyName -Name $vendorProperty.Name))))
            {
                continue
            }

            if (-not $nested)
            {
                $backlog++
            }

            $suppression = Resolve-FindingExclusion -Exclusion $exclusions -Property $dscName
            if ($nested -and $null -eq $suppression.Reason -and -not $vendor.Properties.Contains($vendorProperty.Name))
            {
                $suppression = Resolve-FindingExclusion -Exclusion $exclusions `
                    -Property (ConvertTo-DscPropertyName -Name $vendorProperty.Name)
            }

            if ($suppression.Suppressed)
            {
                continue
            }

            $seenBefore = $null -ne $baselineVendor -and $baselineVendor.Properties.Contains($vendorName)

            $code = 'RES-PROP-BACKLOG'
            $autoFixable = $false
            if ($nested)
            {
                $code = 'RES-PROP-NESTED'
            }
            elseif ($vendorProperty.IsReadOnly -or $vendorProperty.Name -in $serviceManagedProperty)
            {
                $code = 'RES-PROP-READONLY'
            }
            elseif (-not $seenBefore)
            {
                $code = 'RES-PROP-MISSING'
                $autoFixable = -not $vendorProperty.IsComplex
            }

            # Exclude a property if it is read-only and globally suppressed
            if ($code -eq 'RES-PROP-READONLY' -and
                (Resolve-FindingExclusion -Exclusion $globalReadOnly -Property $dscName).Suppressed)
            {
                continue
            }

            if ($code -eq 'RES-PROP-NESTED' -and -not $seenBefore -and [System.String]::IsNullOrEmpty($suppression.Severity))
            {
                $suppression.Severity = 'warning'
            }

            if ($null -ne $suppression.AutoFixable)
            {
                $autoFixable = [System.Boolean] $suppression.AutoFixable
            }

            $findings.Add((New-M365DSCApiSurfaceFinding -Code $code `
                        -Subject $row.Resource `
                        -Property $dscName `
                        -Resource $row.Resource `
                        -Workload $row.Workload `
                        -AutoFixable $autoFixable `
                        -Severity $suppression.Severity `
                        -From $null `
                        -To ([ordered]@{
                            vendorType = $vendorProperty.Type
                            isArray    = $vendorProperty.IsArray
                            isComplex  = $vendorProperty.IsComplex
                            enum       = @($vendorProperty.Enum)
                        }) `
                        -Evidence ([ordered]@{
                            source      = "csdl:$($gate.TypeKey -replace ':', '/')/$vendorName"
                            exclusion   = $suppression.Reason
                            flattenedAs = if ($nested) { $vendorProperty.Name } else { $null }
                            seenBefore  = $seenBefore
                        })))
        }

        $backlogTotal += $backlog

        $coverage.Add([ordered]@{
                resource  = $row.Resource
                workload  = $row.Workload
                compared  = $true
                reason    = $null
                declared  = $declared.Count
                vendorTop = $vendor.TopLevelCount
                backlog   = $backlog
            })
    }

    return [ordered]@{
        Findings = $findings.ToArray()
        Coverage = $coverage.ToArray()
        Backlog  = $backlogTotal
    }
}

<#
.SYNOPSIS
    Reads the vendor paths an excludedProperties entry states it already covers.

.DESCRIPTION
    A resource that renames a flattened member beyond what the name matcher can derive states the
    path it covers on the entry itself. Without that the member reads as a gap on every run.

.PARAMETER Exclusion
    Specifies the excludedProperties entries of the resource.

.OUTPUTS
    The vendor paths.
#>
function Get-DeclaredVendorPath
{
    [CmdletBinding()]
    [OutputType([System.String[]])]
    param
    (
        [Parameter()]
        [AllowNull()]
        [System.Object]
        $Exclusion
    )

    $path = [System.Collections.Generic.List[System.String]]::new()

    foreach ($entry in @($Exclusion))
    {
        if ($null -eq $entry)
        {
            continue
        }

        foreach ($value in @($entry.vendorPath))
        {
            if (-not [System.String]::IsNullOrWhiteSpace($value))
            {
                $path.Add([System.String] $value)
            }
        }
    }

    return [System.String[]] $path
}

<#
.SYNOPSIS
    Lists the vendor containers a resource has proven it flattens.

.DESCRIPTION
    A container counts as flattened once two of its members matched a declared property. Every
    ancestor of a matched member counts toward its own tally, which is what lets a two level
    container be reached. One match alone is not enough, because a resource that resolves a
    related object by display name matches exactly one member of it and flattens nothing.

.PARAMETER MatchedPath
    Specifies the vendor paths the declared properties matched.

.PARAMETER Minimum
    Specifies how many matched members a container needs.

.OUTPUTS
    The container paths.
#>
function Get-FlattenedContainer
{
    [CmdletBinding()]
    [OutputType([System.Collections.Generic.HashSet[System.String]])]
    param
    (
        [Parameter()]
        [AllowNull()]
        [System.Object]
        $MatchedPath,

        [Parameter()]
        [System.Int32]
        $Minimum = 2
    )

    $tally = @{}

    foreach ($path in @($MatchedPath))
    {
        $current = [System.String] $path
        $cut = $current.LastIndexOf('.')
        while ($cut -gt 0)
        {
            $current = $current.Substring(0, $cut)
            $tally[$current] = 1 + $tally[$current]
            $cut = $current.LastIndexOf('.')
        }
    }

    $container = [System.Collections.Generic.HashSet[System.String]]::new([System.StringComparer]::Ordinal)
    foreach ($name in $tally.Keys)
    {
        if ($tally[$name] -ge $Minimum)
        {
            $null = $container.Add($name)
        }
    }

    return , $container
}

<#
.SYNOPSIS
    Decides whether a vendor property below the entity is worth reporting.

.DESCRIPTION
    Only a sibling of something the resource already flattened qualifies. A container the resource
    ignores altogether stays silent, which keeps a navigation collection out of the report. A
    complex member is a container rather than a setting, and a member the service owns is never
    configured, so neither is reported.

.PARAMETER Path
    Specifies the full vendor path of the candidate.

.PARAMETER Container
    Specifies the containers the resource has proven it flattens.

.PARAMETER Vendor
    Specifies the candidate vendor property.

.PARAMETER ServiceManagedProperty
    Specifies the property names the service owns.

.OUTPUTS
    True when the candidate should be reported.
#>
function Test-FlattenedSibling
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Path,

        [Parameter(Mandatory = $true)]
        [AllowEmptyCollection()]
        [System.Collections.Generic.HashSet[System.String]]
        $Container,

        [Parameter(Mandatory = $true)]
        [System.Collections.IDictionary]
        $Vendor,

        [Parameter()]
        [AllowEmptyCollection()]
        [System.String[]]
        $ServiceManagedProperty = @()
    )

    $cut = $Path.LastIndexOf('.')
    if ($cut -lt 1 -or -not $Container.Contains($Path.Substring(0, $cut)))
    {
        return $false
    }

    if ([System.Boolean] $Vendor.IsComplex -or [System.Boolean] $Vendor.IsReadOnly)
    {
        return $false
    }

    return [System.String] $Vendor.Name -notin $ServiceManagedProperty
}

<#
.SYNOPSIS
    Names a vendor path the way a resource that flattens it would.

.DESCRIPTION
    Every segment is capitalized and joined, so sessionControls.signInFrequency.isEnabled reads as
    SessionControlsSignInFrequencyIsEnabled. The full path keeps the name unique when a leaf
    repeats under two containers.

.PARAMETER Path
    Specifies the vendor path.

.OUTPUTS
    The DSC style name.
#>
function ConvertTo-FlattenedDscPropertyName
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Path
    )

    $segments = @($Path -split '\.' | Where-Object -FilterScript { -not [System.String]::IsNullOrEmpty($_) } |
            ForEach-Object -Process { ConvertTo-DscPropertyName -Name $_ })

    return ($segments -join '')
}

<#
.SYNOPSIS
    Compares one declared property against the vendor property it matched.

.DESCRIPTION
    unknownFutureValue is an OData sentinel and is not expected in a declared ValidateSet.

.PARAMETER Resource
    Specifies the resource row.

.PARAMETER Name
    Specifies the DSC property name.

.PARAMETER Declared
    Specifies the DscSchemaCache property entry.

.PARAMETER Vendor
    Specifies the matched vendor property.

.PARAMETER TypeKey
    Specifies the graphTypes key the resource was compared against.

.PARAMETER MatchRule
    Specifies the rule Resolve-PropertyName matched the name with.

.PARAMETER Exclusion
    Specifies the resource's excludedProperties entries.

.OUTPUTS
    The findings.
#>
function Compare-DeclaredProperty
{
    [CmdletBinding()]
    [OutputType([System.Object[]])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Object]
        $Resource,

        [Parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [Parameter(Mandatory = $true)]
        [System.Object]
        $Declared,

        [Parameter(Mandatory = $true)]
        [System.Collections.IDictionary]
        $Vendor,

        [Parameter(Mandatory = $true)]
        [System.String]
        $TypeKey,

        [Parameter()]
        [AllowEmptyString()]
        [System.String]
        $MatchRule = 'Exact',

        [Parameter()]
        [AllowNull()]
        [System.Object]
        $Exclusion
    )

    $findings = [System.Collections.Generic.List[System.Object]]::new()
    $suppression = Resolve-FindingExclusion -Exclusion $Exclusion -Property $Name
    if ($suppression.Suppressed)
    {
        return @()
    }

    $matchLevel = [System.Int32] $Vendor.Level
    $autoFixable = $null
    if ($matchLevel -gt 0 -or $Vendor.IsReadOnly)
    {
        $autoFixable = $false
    }

    if ($null -ne $suppression.AutoFixable)
    {
        $autoFixable = [System.Boolean] $suppression.AutoFixable
    }

    $match = [ordered]@{
        rule       = $MatchRule
        level      = $matchLevel
        isReadOnly = [System.Boolean] $Vendor.IsReadOnly
    }

    $expected = @(ConvertTo-MofTypeConstraint -VendorType $Vendor.Type `
            -IsArray $Vendor.IsArray `
            -HasEnum (@($Vendor.Enum).Count -gt 0) `
            -IsFlags $Vendor.IsFlags `
            -IsComplex $Vendor.IsComplex)
    $actual = [System.String] $Declared.typeConstraint

    if ($expected.Count -gt 0 -and $actual -notin $expected -and -not $Vendor.IsComplex)
    {
        $findings.Add((New-M365DSCApiSurfaceFinding -Code 'RES-TYPE-MISMATCH' `
                    -Subject $Resource.Resource `
                    -Property $Name `
                    -Resource $Resource.Resource `
                    -Workload $Resource.Workload `
                    -AutoFixable $autoFixable `
                    -Severity $suppression.Severity `
                    -From ([ordered]@{ typeConstraint = $actual }) `
                    -To ([ordered]@{ vendorType = $Vendor.Type; isArray = $Vendor.IsArray; expected = $expected }) `
                    -Evidence ([ordered]@{
                        source = "csdl:$($TypeKey -replace ':', '/')/$($Vendor.Path)"
                        match  = $match
                    })))
    }

    $vendorMembers = @($Vendor.Enum | Where-Object -FilterScript { $null -ne $_ -and $_ -ne 'unknownFutureValue' })
    if ($vendorMembers.Count -gt 0)
    {
        $declaredMembers = [System.Collections.Generic.HashSet[System.String]]::new(
            [System.String[]] @(@($Declared.values) | Where-Object -FilterScript { $null -ne $_ }),
            [System.StringComparer]::OrdinalIgnoreCase)

        if ($declaredMembers.Count -gt 0)
        {
            $missingMembers = @($vendorMembers | Where-Object -FilterScript { -not $declaredMembers.Contains([System.String] $_) })
            if ($missingMembers.Count -gt 0)
            {
                $findings.Add((New-M365DSCApiSurfaceFinding -Code 'RES-ENUM-STALE' `
                            -Subject $Resource.Resource `
                            -Property $Name `
                            -Resource $Resource.Resource `
                            -Workload $Resource.Workload `
                            -AutoFixable $autoFixable `
                            -Severity $suppression.Severity `
                            -From ([ordered]@{ values = @($Declared.values) }) `
                            -To ([ordered]@{ values = $vendorMembers; added = $missingMembers }) `
                            -Evidence ([ordered]@{
                                source = "csdl:$($TypeKey -replace ':', '/')/$($Vendor.Path)"
                                match  = $match
                            })))
            }
        }
    }

    return $findings.ToArray()
}

<#
.SYNOPSIS
    Maps a CSDL type onto the MOF type constraints DscSchemaCache.json records.

.PARAMETER VendorType
    Specifies the CSDL type name.

.PARAMETER IsArray
    Indicates a Collection type.

.PARAMETER HasEnum
    Indicates that the property carries enum members.

.PARAMETER IsFlags
    Indicates a flags enum, which is declared scalar but accepts several values at once.

.PARAMETER IsComplex
    Indicates a complex or navigation type.

.OUTPUTS
    The accepted typeConstraint values, or an empty array when the vendor type has no mapping.
#>
function ConvertTo-MofTypeConstraint
{
    [CmdletBinding()]
    [OutputType([System.String[]])]
    param
    (
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [System.String]
        $VendorType,

        [Parameter()]
        [System.Boolean]
        $IsArray = $false,

        [Parameter()]
        [System.Boolean]
        $HasEnum = $false,

        [Parameter()]
        [System.Boolean]
        $IsFlags = $false,

        [Parameter()]
        [System.Boolean]
        $IsComplex = $false
    )

    if ($IsComplex)
    {
        return [System.String[]] @()
    }

    if ($HasEnum)
    {
        $base = @('String')
    }
    else
    {
        $table = @{
            'edm.string'         = @('String')
            'edm.boolean'        = @('Boolean')
            'edm.int16'          = @('SInt16', 'SInt32')
            'edm.int32'          = @('SInt32', 'UInt32')
            'edm.int64'          = @('SInt64', 'UInt64')
            'edm.byte'           = @('UInt8', 'UInt32', 'SInt32')
            'edm.sbyte'          = @('SInt8', 'SInt32')
            'edm.single'         = @('Real32', 'Real64')
            'edm.double'         = @('Real64')
            'edm.decimal'        = @('Real64')
            'edm.datetimeoffset' = @('String', 'DateTime')
            'edm.date'           = @('String', 'DateTime')
            'edm.timeofday'      = @('String', 'DateTime')
            'edm.duration'       = @('String', 'DateTime')
            'edm.guid'           = @('String')
            'edm.binary'         = @('String')
            'edm.stream'         = @('String')
        }

        # A resource may model a vendor string as a credential when the value is a secret.
        $table['edm.string'] += 'MSFT_Credential'

        $base = $table[$VendorType.ToLowerInvariant()]
        if ($null -eq $base)
        {
            return [System.String[]] @()
        }
    }

    $arrayForms = @($base | ForEach-Object -Process { "${_}Array" })

    if ($IsArray)
    {
        return [System.String[]] $arrayForms
    }

    if ($IsFlags)
    {
        return [System.String[]] @($base + $arrayForms)
    }

    return [System.String[]] $base
}

<#
.SYNOPSIS
    Returns the property names that come from DSC rather than from the vendor type.

.OUTPUTS
    The property names.
#>
function Get-DefaultNonVendorProperty
{
    [CmdletBinding()]
    [OutputType([System.String[]])]
    param ()

    return [System.String[]] @(
        'AccessTokens', 'ApplicationId', 'ApplicationSecret', 'Assignments', 'CertificatePassword',
        'CertificatePath', 'CertificateThumbprint', 'Credential', 'DependsOn', 'Ensure',
        'IsSingleInstance', 'ManagedIdentity', 'PsDscRunAsCredential', 'TenantId'
    )
}

<#
.SYNOPSIS
    Returns the vendor property names the service owns and a resource never writes.

.DESCRIPTION
    The CSDL annotates most of these as read only, but not on every type. Without the list the
    same property is reported as read only on one entity and as an auto fixable gap on another.
    The content version pair carries the same problem for a different reason. Both are writable
    in the CSDL and both are owned by the app content upload sequence, never by a configuration.
    The author stamps behave the same way. Whichever entity carries one, the directory records
    who acted and a configuration never supplies it.

.OUTPUTS
    The property names, matched against the vendor name.
#>
function Get-DefaultServiceManagedProperty
{
    [CmdletBinding()]
    [OutputType([System.String[]])]
    param ()

    return [System.String[]] @(
        'committedContentVersion', 'contentVersions', 'createdBy', 'createdByAppId',
        'createdDateTime', 'createdOnBehalfOf', 'deletedDateTime', 'lastModifiedBy',
        'lastModifiedByAppId', 'lastModifiedDateTime', 'modifiedBy', 'modifiedDateTime', 'version'
    )
}
