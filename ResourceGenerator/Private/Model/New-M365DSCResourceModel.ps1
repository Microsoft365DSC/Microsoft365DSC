<#
.SYNOPSIS
    Assembles the complete intermediate representation of a resource to generate.

.DESCRIPTION
    Every emitter (class module, unit test, example, settings, readme) is a projection of the
    object returned here.

.PARAMETER ResourceName
    Specifies the resource name, for example 'AADPermissionGrantPolicy'.

.PARAMETER Workload
    Specifies the workload.

.PARAMETER CmdletInfo
    Specifies the hashtable produced by Get-M365DSCGraphCmdletInfo or Get-M365DSCGenericCmdletInfo.

.PARAMETER Properties
    Specifies the schema property models. The auth and Ensure properties are appended here.

.PARAMETER ParametersToSkip
    Specifies property names to leave out of the generated resource.

.PARAMETER SelectedODataType
    Specifies the concrete OData subtype for polymorphic Graph entities.

.PARAMETER IsAdditionalProperty
    Indicates that the resource's typed properties travel under AdditionalProperties in the API.

.PARAMETER IsSingleInstance
    Indicates a singleton resource (gets an IsSingleInstance key instead of Id).

.PARAMETER CmdLetNoun
    Specifies the cmdlet noun the resource was generated from. Recorded in settings.json under
    generatedFrom.

.PARAMETER CmdLetVerb
    Specifies the verb of the cmdlet whose parameters describe the resource (non-Graph workloads).

.PARAMETER IncludeNavigationProperties
    Indicates that Graph navigation properties were included in the generated schema.
#>
function New-M365DSCResourceModel
{
    [CmdletBinding()]
    [OutputType([System.Management.Automation.PSCustomObject])]
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
        [System.Collections.Hashtable]
        $CmdletInfo,

        [Parameter(Mandatory = $true)]
        [System.Object[]]
        $Properties,

        [Parameter()]
        [System.String[]]
        $ParametersToSkip = @(),

        [Parameter()]
        [System.String]
        $SelectedODataType,

        [Parameter()]
        [System.Boolean]
        $IsAdditionalProperty = $false,

        [Parameter()]
        [System.Boolean]
        $IsSingleInstance = $false,

        [Parameter()]
        [System.String]
        $CmdLetNoun,

        [Parameter()]
        [System.String]
        $CmdLetVerb = 'New',

        [Parameter()]
        [System.Boolean]
        $IncludeNavigationProperties = $false,

        [Parameter()]
        [AllowEmptyString()]
        [System.String]
        $AssignmentSettingsType,

        [Parameter()]
        [AllowEmptyCollection()]
        [System.Object[]]
        $AssignmentSettingsMember = @(),

        [Parameter()]
        [AllowEmptyCollection()]
        [System.String[]]
        $CreateOnlyProperties = @(),

        [Parameter()]
        [AllowEmptyCollection()]
        [System.String[]]
        $TextPayloadProperties = @()
    )

    # Exclude read-only server-side properties from the DSC schema.
    $readOnlyProperties = @(
        'createdDateTime', 'deletedDateTime', 'isAssigned', 'lastModifiedDateTime', 'priorityMetaData',
        'retryCount', 'settingCount', 'templateReference', 'creationSource', 'version', 'supportsScopeTags'
    )

    $schemaProperties = @($Properties | Where-Object -FilterScript {
            $_.GraphName -notin $readOnlyProperties -and
            -not $_.IsReadOnly -and
            $_.Name -notin $ParametersToSkip
        })

    # Only polymorphic Graph resources round-trip subtype properties through AdditionalProperties.
    if (-not $IsAdditionalProperty)
    {
        foreach ($property in $schemaProperties)
        {
            $property.IsFromAdditionalProperties = $false
        }
    }

    $warnings = @($CmdletInfo.Warnings | Where-Object -FilterScript { -not [System.String]::IsNullOrEmpty($_) })
    $excludedPropertyReasons = @{}

    $reservedNames = @(Get-M365DSCAuthPropertySet -Workload $Workload | ForEach-Object -Process { $_.Name }) + @('Ensure', 'IsSingleInstance')
    foreach ($property in @($schemaProperties | Where-Object -FilterScript { $_.Name -in $reservedNames }))
    {
        $message = "Property '$($property.Name)' collides with the authentication or engine property of the same name and is left out."
        Write-Warning -Message $message
        $warnings += $message
        $excludedPropertyReasons[$property.Name] = 'CollidesWithAuthenticationProperty'
    }
    $schemaProperties = @($schemaProperties | Where-Object -FilterScript { $_.Name -notin $reservedNames })

    # An entity without Id that is read through one path parameter, such as a partner tenant id,
    # is identified by that parameter.
    $pathKey = $null
    $getKeyParameters = @($CmdletInfo.GetKeyParameters | Where-Object -FilterScript { -not [System.String]::IsNullOrEmpty($_) -and $_ -ne 'InputObject' })
    if (-not $IsSingleInstance -and
        [System.String]::IsNullOrEmpty($CmdletInfo.PrimaryKey) -and
        $schemaProperties.Name -notcontains 'Id' -and
        $getKeyParameters.Count -eq 1 -and
        $schemaProperties.Name -notcontains $getKeyParameters[0])
    {
        $pathKey = $getKeyParameters[0]
        $pathKeyProperty = New-M365DSCPropertyModel -Name $pathKey `
            -Description "The $pathKey that identifies the instance." `
            -IsKey $true
        $pathKeyProperty | Add-Member -NotePropertyName 'IsPathKey' -NotePropertyValue $true
        $schemaProperties = @($pathKeyProperty) + $schemaProperties
    }

    # Primary key precedence is the acquired value, then the Get path parameter, then Id, then the first property.
    $primaryKey = $CmdletInfo.PrimaryKey
    if ([System.String]::IsNullOrEmpty($primaryKey) -and $null -ne $pathKey)
    {
        $primaryKey = $pathKey
    }
    if ([System.String]::IsNullOrEmpty($primaryKey))
    {
        if ($schemaProperties.Name -contains 'Id')
        {
            $primaryKey = 'Id'
        }
        elseif ($schemaProperties.Count -gt 0)
        {
            $primaryKey = $schemaProperties[0].Name
        }
    }

    $alternativeKey = $null
    if ($schemaProperties.Name -contains 'DisplayName')
    {
        $alternativeKey = 'DisplayName'
    }
    elseif ($schemaProperties.Name -contains 'Name')
    {
        $alternativeKey = 'Name'
    }
    if ($alternativeKey -eq $primaryKey -or $null -ne $pathKey)
    {
        $alternativeKey = $null
    }

    if ($IsSingleInstance)
    {
        $schemaProperties = @(
            New-M365DSCPropertyModel -Name 'IsSingleInstance' `
                -Description "Only valid value is 'Yes'." `
                -EnumValues @('Yes') `
                -IsKey $true
        ) + $schemaProperties
        $primaryKey = 'IsSingleInstance'
    }
    else
    {
        $dscKey = $primaryKey
        if ($null -ne $alternativeKey)
        {
            $dscKey = $alternativeKey
        }

        foreach ($property in $schemaProperties)
        {
            if ($property.Name -eq $dscKey)
            {
                $property.IsKey = $true
                $property.ClrType = $property.ClrType -replace '^System\.Nullable\[(.+)\]$', '$1'
            }
        }
    }

    $resourceDescriptor = Get-M365DSCResourceDescriptor -ResourceName $ResourceName

    $hasAssignments = $CmdletInfo.ContainsKey('HasAssignments') -and $CmdletInfo.HasAssignments

    $assignmentKind = 'Policy'
    $assignmentCimClassName = ''
    if ($hasAssignments -and ([System.String] $CmdletInfo.AssignmentRepository) -like 'deviceAppManagement/mobileApps*')
    {
        $assignmentKind = 'MobileApp'
        $assignmentCimClassName = "MSFT_DeviceManagement$(Get-StringFirstCharacterToUpper -Value $SelectedODataType)Assignment"
    }

    if ($hasAssignments)
    {
        $assignmentModel = @{ Kind = $assignmentKind; CimClassName = $assignmentCimClassName }
        if ($assignmentKind -eq 'MobileApp' -and @($AssignmentSettingsMember).Count -gt 0)
        {
            $assignmentModel['SettingsType'] = $AssignmentSettingsType
            $assignmentModel['SettingsMember'] = $AssignmentSettingsMember
            $assignmentModel['SettingsCimClassName'] = "MSFT_DeviceManagement$(Get-StringFirstCharacterToUpper -Value $AssignmentSettingsType)"
        }

        $schemaProperties = @($schemaProperties) + (Get-M365DSCAssignmentPropertyModel @assignmentModel)
    }

    # Every downstream artifact renders in model order. Alphabetical keeps it readable.
    $schemaProperties = @($schemaProperties | Sort-Object -Property Name)

    $allProperties = @($schemaProperties)
    if (-not $IsSingleInstance)
    {
        $allProperties += Get-M365DSCEnsurePropertyModel -ResourceDescriptor $resourceDescriptor.ShortDescriptor
    }
    $allProperties += Get-M365DSCAuthPropertySet -Workload $Workload

    $cmdlets = @{}
    foreach ($key in $CmdletInfo.Keys)
    {
        $cmdlets[$key] = $CmdletInfo[$key]
    }

    return [PSCustomObject]@{
        ResourceName         = $ResourceName
        Workload             = $Workload
        ResourceDescription  = $resourceDescriptor.Description
        ResourceDescriptor   = $resourceDescriptor.ShortDescriptor
        PrimaryKey           = $primaryKey
        AlternativeKey       = $alternativeKey
        SelectedODataType    = $SelectedODataType
        IsAdditionalProperty = $IsAdditionalProperty
        IsSingleInstance     = $IsSingleInstance
        Cmdlets              = $cmdlets
        Properties           = $allProperties
        SchemaProperties     = $schemaProperties
        ComplexTypeClasses   = @(Get-M365DSCComplexTypeClass -Properties $schemaProperties)
        HasAssignments       = $hasAssignments
        AssignmentKind       = $assignmentKind
        ExcludedProperties   = @($ParametersToSkip) + @($excludedPropertyReasons.Keys)
        ExcludedPropertyReasons = $excludedPropertyReasons
        Warnings             = $warnings
        CreateOnlyProperties = @($CreateOnlyProperties)
        TextPayloadProperties = @($TextPayloadProperties)
        SettingsCatalog      = $null
        CmdLetNoun           = $CmdLetNoun
        CmdLetVerb           = $CmdLetVerb
        IncludeNavigationProperties = $IncludeNavigationProperties
    }
}

<#
.SYNOPSIS
    Derives the human-readable resource description from the resource name.

.DESCRIPTION
    'IntuneDeviceCompliancePolicyWindows10' becomes 'Intune Device Compliance Policy for
    Windows10'. Acronyms stay whole, so 'SCDLPCompliancePolicy' becomes 'SC DLP Compliance
    Policy'. The short descriptor used in the Ensure description is the last non platform noun,
    for example 'policy'.

.PARAMETER ResourceName
    Specifies the resource name.
#>
function Get-M365DSCResourceDescriptor
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $ResourceName
    )

    $replacements = @{
        'Windows10' = 'for Windows10'
        'Windows11' = 'for Windows11'
        'Android'   = 'for Android'
        'MacOS'     = 'for macOS'
        'iOS'       = 'for iOS'
        'AAD'       = 'Entra ID'
        'Linux'     = 'for Linux'
    }

    # Workload prefixes run straight into the next acronym, as in 'SCDLP' or 'EXOCAS'.
    $name = ($ResourceName -split '_')[0] -creplace '^(AAD|ADO|EXO|O365|OD|PP|SC|SH|SPO)(?=[A-Z])', '$1 '
    $words = [regex]::Matches($name, 'Windows1[01]|[Mm]ac[Oo][Ss]|iOS|IOS(?![a-z])|[A-Z][A-Z0-9]*(?![a-z])|[A-Z]?(?:(?!iOS)[a-z0-9])+') | ForEach-Object -Process {
        $word = $_.Value
        if ($replacements.ContainsKey($word))
        {
            $replacements[$word]
        }
        else
        {
            $word
        }
    }
    $description = $words -join ' '

    $descriptorWords = @(($description -split ' ') | Where-Object {
            $_ -notmatch '^(for|Windows10|Windows11|Android|macOS|iOS|Linux|Entra|ID)$' -and $_.Length -gt 1
        })
    $shortDescriptor = 'resource'
    if ($descriptorWords.Count -gt 0)
    {
        $shortDescriptor = $descriptorWords[-1].ToLowerInvariant()
    }

    return @{
        Description     = $description
        ShortDescriptor = $shortDescriptor
    }
}

<#
.SYNOPSIS
    Flattens the unique CIM classes declared by a property tree.

.DESCRIPTION
    Depth first order puts a nested class before the class that references it.

.PARAMETER Properties
    Specifies the property models to walk.

.PARAMETER Seen
    Specifies the CIM class names already collected on the current walk.
#>
function Get-M365DSCComplexTypeClass
{
    [CmdletBinding()]
    [OutputType([System.Object[]])]
    param
    (
        [Parameter()]
        [System.Object[]]
        $Properties = @(),

        [Parameter()]
        [System.Collections.Generic.HashSet[System.String]]
        $Seen
    )

    if ($null -eq $Seen)
    {
        $Seen = [System.Collections.Generic.HashSet[System.String]]::new([System.StringComparer]::OrdinalIgnoreCase)
    }

    $classes = @()
    foreach ($property in $Properties)
    {
        if (-not $property.IsComplex)
        {
            continue
        }

        $classes += @(Get-M365DSCComplexTypeClass -Properties $property.Members -Seen $Seen)

        if ($Seen.Add($property.CimClassName))
        {
            $classes += [PSCustomObject]@{
                CimClassName = $property.CimClassName
                Members      = $property.Members
            }
        }
    }

    return $classes
}
