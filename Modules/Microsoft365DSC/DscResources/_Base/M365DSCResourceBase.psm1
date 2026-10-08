using namespace System
using namespace System.Collections
using namespace System.Collections.Concurrent
using namespace System.Collections.Generic
using namespace System.Management.Automation
using namespace System.Management.Automation.Runspaces
using namespace System.Reflection

<#
    Shared foundation for all Microsoft365DSC class-based resources.

    This file is SOURCE ONLY. Utilities/Build-Microsoft365DSC.ps1 emits it verbatim into
    Modules/Microsoft365DSC/Classes/_Shared.psm1, which every generated Part<NN>.psm1 opens with
    `using module`. It is never imported on its own: PowerShell classes do not cross module
    boundaries, and DSC only parses RootModule plus one level of NestedModules when looking for
    [DscResource()] classes.

    IMPORTANT - this file must never gain top-level executable code.

    Every converted resource opens with `using module ..\_Base\M365DSCResourceBase.psm1` so that it
    parses cleanly in an editor instead of showing TypeNotFound on the base class. `using module`
    IMPORTS the module at PARSE time, which means an editor executes this file every time anyone
    opens a resource. Class and enum definitions are inert and safe. Anything else - a command
    call, an assignment, a Write-Host - would run in the contributor's editor, unprompted, on every
    file open. Put such code in one of the Modules/*.psm1 helpers instead.

    It exists to give class-based resources back three things that function-based resources got
    for free:

      1. $PSBoundParameters      -> $this.GetBoundParameters()
      2. $MyInvocation.MyCommand -> $this.GetResourceName()
      3. a per-resource $Script: scope. The generated root module has ONE module scope shared by
         all resources, so the former $Script:exportedInstance / $Script:* caches would
         cross-contaminate. They become $this.ExportedInstance / $this.ResourceCache.
#>

# Per-property reflection and validation metadata, built once per derived type.
class M365DSCPropertyMeta
{
    [PropertyInfo] $Property

    [Type] $PropertyType

    [FieldInfo] $BackingField

    [bool] $IsSchema

    [bool] $IsRequired

    [bool] $IsComplex

    [bool] $HasValidateSet

    [bool] $TreatsEmptyStringAsNull

    [bool] $HasEnumeratedValidation

    [Attribute[]] $Validators

    M365DSCPropertyMeta([PropertyInfo] $Property)
    {
        $this.Property = $Property
        $this.PropertyType = $Property.PropertyType
        $this.BackingField = $Property.DeclaringType.GetField(
            "<$($Property.Name)>k__BackingField",
            [BindingFlags]::Instance -bor [BindingFlags]::NonPublic)
        $this.IsComplex = [M365DSCResourceBase]::IsComplexClassType($Property.PropertyType)

        $list = [List[Attribute]]::new()
        foreach ($attribute in $Property.GetCustomAttributes($true))
        {
            if ($attribute -is [DscPropertyAttribute])
            {
                $this.IsSchema = $true
                $this.IsRequired = $attribute.Key -or $attribute.Mandatory
                continue
            }

            if ($attribute -is [ValidateEnumeratedArgumentsAttribute])
            {
                $this.HasEnumeratedValidation = $true
            }

            if ($attribute -is [ValidateSetAttribute])
            {
                $this.HasValidateSet = $true
                $this.TreatsEmptyStringAsNull = $true
            }
            elseif ($attribute -is [ValidatePatternAttribute] -or
                ($attribute -is [ValidateLengthAttribute] -and $attribute.MinLength -gt 0))
            {
                $this.TreatsEmptyStringAsNull = $true
            }

            if ($attribute -is [ValidateSetAttribute] -or
                $attribute -is [ValidateRangeAttribute] -or
                $attribute -is [ValidateScriptAttribute] -or
                $attribute -is [ValidateNotNullOrEmptyAttribute] -or
                $attribute -is [ValidateLengthAttribute] -or
                $attribute -is [ValidatePatternAttribute])
            {
                $list.Add($attribute)
            }
        }

        $this.Validators = $list.ToArray()
    }
}

# Per-derived-type reflection cache.
class M365DSCResourceInfo
{
    [Type] $Type

    [Dictionary[String, PropertyInfo]] $Properties

    [Dictionary[String, PropertyInfo]] $NonSchemaProperties

    [Dictionary[String, M365DSCPropertyMeta]] $Meta

    [String[]] $RequiredProperties

    hidden static [System.UInt32] $SerializationDepth = 25

    hidden static [void] RegisterSerializationDepth([Type] $Type)
    {
        $element = $Type
        if ($null -ne $element -and $element.IsArray)
        {
            $element = $element.GetElementType()
        }

        if ($null -eq $element -or -not $element.IsClass -or $element.Name -notlike 'MSFT_*')
        {
            return
        }

        if (-not [M365DSCResourceBase]::GetRunspaceTypeCache('DepthRegistered').TryAdd($element, $true))
        {
            return
        }

        $typeData = [TypeData]::new($element.Name)
        $typeData.SerializationDepth = [M365DSCResourceInfo]::SerializationDepth
        Update-TypeData -TypeData $typeData -Force -ErrorAction Stop

        foreach ($property in $element.GetProperties())
        {
            [M365DSCResourceInfo]::RegisterSerializationDepth($property.PropertyType)
        }
    }

    M365DSCResourceInfo([Type] $Type)
    {
        $this.Type = $Type
        $this.Properties = [Dictionary[String, PropertyInfo]]::new([StringComparer]::OrdinalIgnoreCase)
        $this.NonSchemaProperties = [Dictionary[String, PropertyInfo]]::new([StringComparer]::OrdinalIgnoreCase)
        $this.Meta = [Dictionary[String, M365DSCPropertyMeta]]::new([StringComparer]::OrdinalIgnoreCase)
        $required = [List[String]]::new()

        # Members declared on the base class are infrastructure, not resource schema.
        $baseMembers = [HashSet[String]]::new([String[]] [M365DSCResourceBase].GetProperties().Name, [StringComparer]::OrdinalIgnoreCase)
        $typeData = [TypeData]::new($Type.Name)

        foreach ($property in $Type.GetProperties())
        {
            if ($baseMembers.Contains($property.Name) -or -not $property.CanWrite)
            {
                continue
            }

            $propertyMeta = [M365DSCPropertyMeta]::new($property)
            $this.Meta[$property.Name] = $propertyMeta

            if (-not $propertyMeta.IsSchema)
            {
                $this.NonSchemaProperties[$property.Name] = $property
                continue
            }

            $this.Properties[$property.Name] = $property
            if ($propertyMeta.IsRequired)
            {
                $required.Add($property.Name)
            }

            [M365DSCResourceInfo]::RegisterSerializationDepth($property.PropertyType)
        }

        $this.RequiredProperties = $required.ToArray()

        if ($this.Properties.Count -gt 0)
        {
            $typeData.SerializationDepth = [M365DSCResourceInfo]::SerializationDepth
            Update-TypeData -TypeData $typeData -Force -ErrorAction Stop
        }
    }
}

class M365DSCResourceBase
{
    #region Infrastructure state

    <#
        Property state lives in the CLR properties, because that is where DSC reads and writes it.
        There is no extended type system layer over them: the LCM reads the instance returned by
        Get() after disposing the pipeline that ran it, and a ScriptProperty getter needs a runspace.

        Assignment therefore does not validate. _SetProperty and FromHashtable do.
    #>
    # Underscore-prefixed on purpose. A derived class cannot redeclare a member the base already
    # defines, and resource schemas use ordinary words as property names, so the internal members
    # stay out of that namespace.

    # Replaces $Script:exportedInstance, which cannot stay script-scoped once all
    # resources share one module scope.
    hidden [System.Object] $ExportedInstance

    # Replaces the assorted per-resource $Script:* caches ($Script:RoleDefinitions,
    # $Script:AllSchedules, $Script:exportedGroups, ...).
    hidden [Hashtable] $ResourceCache = @{}

    # Each runspace compiles its own class types. A PowerShell class instance references only the session
    # state it was created in.
    hidden static [System.Runtime.CompilerServices.ConditionalWeakTable[Runspace, ConcurrentDictionary[String, ConcurrentDictionary[Type, System.Object]]]] $_runspaceTypeCaches = `
        [System.Runtime.CompilerServices.ConditionalWeakTable[Runspace, ConcurrentDictionary[String, ConcurrentDictionary[Type, System.Object]]]]::new()

    hidden static [ConcurrentDictionary[String, ConcurrentDictionary[Type, System.Object]]] $_processTypeCaches = `
        [ConcurrentDictionary[String, ConcurrentDictionary[Type, System.Object]]]::new()

    hidden static [ConcurrentDictionary[Type, System.Object]] GetRunspaceTypeCache([System.String] $Name)
    {
        $caches = [M365DSCResourceBase]::_processTypeCaches
        $runspace = [Runspace]::DefaultRunspace
        if ($null -ne $runspace -and -not [M365DSCResourceBase]::_runspaceTypeCaches.TryGetValue($runspace, [ref] $caches))
        {
            $caches = [ConcurrentDictionary[String, ConcurrentDictionary[Type, System.Object]]]::new()
            [M365DSCResourceBase]::_runspaceTypeCaches.Add($runspace, $caches)
        }

        $cache = $null
        if (-not $caches.TryGetValue($Name, [ref] $cache))
        {
            $cache = $caches.GetOrAdd($Name, [ConcurrentDictionary[Type, System.Object]]::new())
        }

        return $cache
    }

    hidden [M365DSCResourceInfo] $_info

    hidden [Hashtable] $_snapshot = @{}

    hidden [bool] $_seeded

    # Resource-name to type map, populated by each generated Part<NN>.psm1 at import time.
    hidden static [ConcurrentDictionary[String, Type]] $_registry = `
        [ConcurrentDictionary[String, Type]]::new([StringComparer]::OrdinalIgnoreCase)

    # Resolves the type registry to every runspace to prevent deadlocks because
    # of static method calls between the different runspaces being marshalled.
    hidden static [System.Runtime.CompilerServices.ConditionalWeakTable[Runspace, ConcurrentDictionary[String, Type]]] $_registryByRunspace = `
        [System.Runtime.CompilerServices.ConditionalWeakTable[Runspace, ConcurrentDictionary[String, Type]]]::new()

    # Which part module declares each resource.
    hidden static [ConcurrentDictionary[String, String]] $_moduleByResource = `
        [ConcurrentDictionary[String, String]]::new([StringComparer]::OrdinalIgnoreCase)

    static [void] Register([Type] $Type, [System.String] $ModuleName)
    {
        $runspace = [Runspace]::DefaultRunspace
        if ($null -ne $runspace)
        {
            $runspaceRegistry = $null
            if (-not [M365DSCResourceBase]::_registryByRunspace.TryGetValue($runspace, [ref] $runspaceRegistry))
            {
                $runspaceRegistry = [ConcurrentDictionary[String, Type]]::new([StringComparer]::OrdinalIgnoreCase)
                [M365DSCResourceBase]::_registryByRunspace.Add($runspace, $runspaceRegistry)
            }
            $runspaceRegistry[$Type.Name] = $Type
        }

        [M365DSCResourceBase]::_registry[$Type.Name] = $Type
        [M365DSCResourceBase]::_moduleByResource[$Type.Name] = $ModuleName
    }

    static [System.String] ResolveModuleName([System.String] $Name)
    {
        $moduleName = $null
        [void] [M365DSCResourceBase]::_moduleByResource.TryGetValue($Name, [ref] $moduleName)
        return $moduleName
    }

    static [Type] Resolve([System.String] $Name)
    {
        $type = $null
        $runspaceRegistry = $null
        $runspace = [Runspace]::DefaultRunspace
        if ($null -ne $runspace -and
            [M365DSCResourceBase]::_registryByRunspace.TryGetValue($runspace, [ref] $runspaceRegistry) -and
            $runspaceRegistry.TryGetValue($Name, [ref] $type))
        {
            return $type
        }

        [void] [M365DSCResourceBase]::_registry.TryGetValue($Name, [ref] $type)
        return $type
    }

    static [String[]] GetRegisteredNames()
    {
        return [String[]] [M365DSCResourceBase]::_registry.Keys
    }

    #endregion

    M365DSCResourceBase()
    {
        $type = $this.GetType()

        $initialized = [M365DSCResourceBase]::GetRunspaceTypeCache('Initialized')
        $info = $null
        if (-not $initialized.TryGetValue($type, [ref] $info))
        {
            $info = [M365DSCResourceInfo]::new($type)
            $initialized[$type] = $info
        }

        $this._info = $info
    }

    # Graph caps an $expand'ed collection at 20 entries. Returns $null when the caller has to fetch the
    # navigation property itself, and the items otherwise.
    hidden [System.Object] ResolveExpandedNavigation([System.Object] $Instance, [System.String] $Name)
    {
        if ($null -eq $Instance)
        {
            return $null
        }

        $value = $Instance.$Name
        if ($null -eq $value)
        {
            return $null
        }

        $items = @($value)
        if ($items.Count -ge 20)
        {
            return $null
        }

        return $items
    }

    #region Property plumbing

    hidden [PropertyInfo] _FindProperty([System.String] $Name)
    {
        $propertyInfo = $this._info.Properties[$Name]
        if ($null -eq $propertyInfo)
        {
            $propertyInfo = $this._info.NonSchemaProperties[$Name]
        }

        return $propertyInfo
    }

    # Reads the real CLR property.
    hidden [System.Object] _GetProperty([System.String] $Name)
    {
        $propertyInfo = $this._FindProperty($Name)
        if ($null -eq $propertyInfo)
        {
            return $null
        }

        return $propertyInfo.GetValue($this)
    }

    # Validates, then writes THROUGH to the real CLR property.
    hidden [void] _SetProperty([System.String] $Name, [System.Object] $Value)
    {
        $meta = $null
        if (-not $this._info.Meta.TryGetValue($Name, [ref] $meta) -or -not $meta.IsSchema)
        {
            throw [ArgumentException]::new("Unknown property '$Name' on resource '$($this.GetResourceName())'.", $Name)
        }

        if (-not $this._seeded -and $meta.IsRequired)
        {
            $this.SeedSnapshotIfPopulated()
        }

        $this.ValidateProperty($meta, $Name, $Value)

        if ($meta.IsComplex)
        {
            $Value = [M365DSCResourceBase]::SanitizeComplexValue($Value, $meta.PropertyType)
        }

        if ($null -eq $Value)
        {
            $this.SetNullValue($meta)
            return
        }

        if ($meta.TreatsEmptyStringAsNull -and $Value -is [System.String] -and $Value -eq '')
        {
            $this.SetNullValue($meta)
            return
        }

        if ($meta.HasEnumeratedValidation -and $Value -isnot [System.String] -and
            $Value -is [System.Collections.IEnumerable] -and @($Value).Count -eq 0)
        {
            $this.SetNullValue($meta)
            return
        }

        $converted = $Value -as $meta.PropertyType
        if ($null -eq $converted)
        {
            throw [InvalidOperationException]::new(
                "Cannot assign property '$Name' on resource '$($this.GetResourceName())': " +
                "a value of type '$($Value.GetType().FullName)' does not convert to " +
                "'$($meta.PropertyType.FullName)'." +
                $this.DescribeConversionFailure($Value, $meta.PropertyType))
        }

        $meta.Property.SetValue($this, $converted)
        $this._snapshot[$meta.Property.Name] = $converted
    }

    hidden [void] SetNullValue([M365DSCPropertyMeta] $Meta)
    {
        $value = $null
        if ($Meta.PropertyType.IsValueType -and
            $null -eq [Nullable]::GetUnderlyingType($Meta.PropertyType))
        {
            $value = [Activator]::CreateInstance($Meta.PropertyType)
        }

        if ($null -ne $Meta.BackingField)
        {
            $Meta.BackingField.SetValue($this, $value)
        }
        else
        {
            $Meta.Property.SetValue($this, $value)
        }

        if (-not $Meta.IsSchema)
        {
            return
        }

        if ($null -eq $value)
        {
            $this._snapshot.Remove($Meta.Property.Name)
        }
        else
        {
            $this._snapshot[$Meta.Property.Name] = $value
        }
    }

    hidden [void] ClearNonSchemaProperties()
    {
        foreach ($meta in $this._info.Meta.Values)
        {
            if (-not $meta.IsSchema)
            {
                $this.SetNullValue($meta)
            }
        }
    }

    # Detects an instance that DSC populated by reflection and seeds the snapshot from the CLR state.
    hidden [void] SeedSnapshotIfPopulated()
    {
        foreach ($name in $this._info.RequiredProperties)
        {
            if ($this._snapshot.ContainsKey($name) -or $null -eq $this._info.Properties[$name].GetValue($this))
            {
                continue
            }

            $this._snapshot = $this.ReadBoundParameters()
            $this._seeded = $true
            return
        }
    }

    hidden [Hashtable] ReadBoundParameters()
    {
        $result = @{}
        foreach ($entry in $this._info.Properties.GetEnumerator())
        {
            $value = $entry.Value.GetValue($this)
            if ($null -ne $value)
            {
                $result[$entry.Key] = $value
            }
        }

        return $result
    }

    # True when the property targets an embedded complex class (or an array of one).
    hidden static [System.Boolean] IsComplexClassType([Type] $Type)
    {
        $element = if ($Type.IsArray) { $Type.GetElementType() } else { $Type }
        return ($element.IsClass -and $element.Name -like 'MSFT_*')
    }

    hidden static [System.Object] GetComplexPropertyMetadata([Type] $Type)
    {
        $metadata = $null
        $complexMetadata = [M365DSCResourceBase]::GetRunspaceTypeCache('ComplexMetadata')
        if ($complexMetadata.TryGetValue($Type, [ref] $metadata))
        {
            return $metadata
        }

        $table = [Dictionary[String, System.Object]]::new([StringComparer]::OrdinalIgnoreCase)
        foreach ($property in $Type.GetProperties())
        {
            if (-not $property.CanWrite)
            {
                continue
            }

            $table[$property.Name] = [PSCustomObject] @{
                HasValidateSet = @($property.GetCustomAttributes([ValidateSetAttribute], $true)).Count -gt 0
                IsComplex      = [M365DSCResourceBase]::IsComplexClassType($property.PropertyType)
                Type           = $property.PropertyType
            }
        }

        $complexMetadata[$Type] = $table
        return $table
    }

    # Check and fix all values for each property recursively
    hidden static [System.Object] SanitizeComplexValue([System.Object] $Value, [Type] $TargetType)
    {
        if ($null -eq $Value)
        {
            return $null
        }

        if ($TargetType.IsArray)
        {
            $element = $TargetType.GetElementType()

            if ($Value -is [System.String])
            {
                # Would enumerate as chars; let the cast fail exactly as today.
                return $Value
            }

            if ($Value -is [IDictionary] -or $Value -isnot [IEnumerable])
            {
                # Scalar-to-array coercion: sanitize the single element, PowerShell wraps it.
                return [M365DSCResourceBase]::SanitizeComplexValue($Value, $element)
            }

            $result = [List[System.Object]]::new()
            foreach ($item in $Value)
            {
                $result.Add([M365DSCResourceBase]::SanitizeComplexValue($item, $element))
            }
            return $result.ToArray()
        }

        if ($TargetType.IsInstanceOfType($Value))
        {
            return $Value
        }

        $entries = [Ordered] @{}
        if ($Value -is [IDictionary])
        {
            foreach ($key in @($Value.Keys))
            {
                $entries[[System.String] $key] = $Value[$key]
            }
        }
        elseif ($Value.PSObject.BaseObject -is [System.Management.Automation.PSCustomObject])
        {
            # Includes Deserialized.MSFT_* instances from the PS 5.1 -> 7 dispatch, which carry
            # every property. Flattening to a hashtable means only the surviving keys are assigned.
            foreach ($property in $Value.PSObject.Properties)
            {
                $entries[$property.Name] = $property.Value
            }
        }
        else
        {
            # Unrecognized shape: pass through unchanged, worst case equals today's behavior.
            return $Value
        }

        $metadata = [M365DSCResourceBase]::GetComplexPropertyMetadata($TargetType)
        $clean = @{}
        foreach ($key in $entries.Keys)
        {
            $item = $entries[$key]
            if ($null -eq $item)
            {
                continue
            }

            $meta = $null
            if ($metadata.TryGetValue($key, [ref] $meta))
            {
                if ($meta.HasValidateSet -and $item -is [System.String] -and $item -eq '')
                {
                    continue
                }

                if ($meta.IsComplex)
                {
                    $item = [M365DSCResourceBase]::SanitizeComplexValue($item, $meta.Type)
                }
            }

            # Unknown keys stay: they still fail the cast and get reported, semantics preserved.
            $clean[$key] = $item
        }

        return $clean
    }

    # Narrows a failed conversion down to the element and member that caused it.
    hidden [System.String] DescribeConversionFailure([System.Object] $Value, [Type] $Type)
    {
        $elementType = if ($Type.IsArray) { $Type.GetElementType() } else { $Type }

        $index = -1
        foreach ($item in @($Value))
        {
            $index++

            if ($null -eq $item -or $null -ne ($item -as $elementType))
            {
                continue
            }

            $where = if ($Type.IsArray) { " Element [$index]" } else { ' The value' }

            if ($item -isnot [System.Collections.IDictionary])
            {
                return "$where of type '$($item.GetType().FullName)' does not convert to '$($elementType.FullName)'."
            }

            $known = @($elementType.GetProperties() | ForEach-Object { $_.Name })
            $unknown = @($item.Keys | Where-Object { $_ -notin $known })
            if ($unknown.Count -gt 0)
            {
                return "$where carries member(s) not declared on '$($elementType.Name)': $($unknown -join ', ')."
            }

            foreach ($key in $item.Keys)
            {
                $member = $elementType.GetProperty($key)
                if ($null -eq $member)
                {
                    continue
                }

                # An out-of-set string converts to [string] just fine, so the -as probe below
                # cannot name it. Check the ValidateSet explicitly.
                $validateSet = @($member.GetCustomAttributes([System.Management.Automation.ValidateSetAttribute], $true)) |
                    Select-Object -First 1
                if ($null -ne $validateSet -and $null -ne $item[$key])
                {
                    foreach ($single in @($item[$key]))
                    {
                        if ($null -ne $single -and
                            -not ($single -is [System.String] -and $single -eq '') -and
                            $validateSet.ValidValues -notcontains $single)
                        {
                            return "$where member '$key' value '$single' is not in the valid set for " +
                                "'$($elementType.Name).$key': $($validateSet.ValidValues -join ', ')."
                        }
                    }
                }

                if ($null -ne $item[$key] -and $null -eq ($item[$key] -as $member.PropertyType))
                {
                    # Recursive conversion failure description
                    return "$where member '$key' of type '$($item[$key].GetType().FullName)' does not convert to '$($member.PropertyType.FullName)'." +
                        $this.DescribeConversionFailure($item[$key], $member.PropertyType)
                }
            }

            return "$where does not convert to '$($elementType.Name)' and no single member explains it."
        }

        return ''
    }

    hidden [void] ValidateProperty([M365DSCPropertyMeta] $Meta, [System.String] $Name, [System.Object] $Value)
    {
        if ($null -eq $Value)
        {
            return
        }

        foreach ($attribute in $Meta.Validators)
        {
            if ($attribute -is [System.Management.Automation.ValidateSetAttribute])
            {
                foreach ($item in @($Value))
                {
                    if ($item -is [System.String] -and $item -eq '')
                    {
                        continue
                    }

                    if ($attribute.ValidValues -notcontains $item)
                    {
                        throw [ArgumentException]::new(
                            "The value '$item' is not valid for property '$Name'. Valid values are: $($attribute.ValidValues -join ', ').",
                            $Name)
                    }
                }
            }
            elseif ($attribute -is [System.Management.Automation.ValidateRangeAttribute])
            {
                foreach ($item in @($Value))
                {
                    if ($item -lt $attribute.MinRange -or $item -gt $attribute.MaxRange)
                    {
                        throw [ArgumentOutOfRangeException]::new(
                            $Name,
                            $item,
                            "The value '$item' is outside the valid range for property '$Name' ($($attribute.MinRange) to $($attribute.MaxRange)).")
                    }
                }
            }
            elseif ($attribute -is [System.Management.Automation.ValidateScriptAttribute])
            {
                foreach ($item in @($Value))
                {
                    if (-not (& $attribute.ScriptBlock $item))
                    {
                        throw [ArgumentException]::new("The value '$item' is not valid for property '$Name'.", $Name)
                    }
                }
            }
            elseif ($attribute -is [System.Management.Automation.ValidateNotNullOrEmptyAttribute])
            {
                if ($Value -is [System.String] -and [System.String]::IsNullOrEmpty($Value))
                {
                    throw [ArgumentException]::new("Property '$Name' may not be null or empty.", $Name)
                }
            }
            elseif ($attribute -is [System.Management.Automation.ValidateLengthAttribute])
            {
                foreach ($item in @($Value))
                {
                    if ($item -isnot [System.String] -or $item -eq '')
                    {
                        continue
                    }

                    if ($item.Length -lt $attribute.MinLength -or $item.Length -gt $attribute.MaxLength)
                    {
                        throw [ArgumentException]::new(
                            "The value '$item' is not valid for property '$Name': its length must be between $($attribute.MinLength) and $($attribute.MaxLength) characters.",
                            $Name)
                    }
                }
            }
            elseif ($attribute -is [System.Management.Automation.ValidatePatternAttribute])
            {
                foreach ($item in @($Value))
                {
                    if ($item -isnot [System.String] -or $item -eq '')
                    {
                        continue
                    }

                    if (-not [System.Text.RegularExpressions.Regex]::IsMatch($item, $attribute.RegexPattern, $attribute.Options))
                    {
                        throw [ArgumentException]::new(
                            "The value '$item' is not valid for property '$Name': it does not match the pattern '$($attribute.RegexPattern)'.",
                            $Name)
                    }
                }
            }
        }
    }

    #endregion

    #region $PSBoundParameters replacement

    [Hashtable] GetBoundParameters()
    {
        if (-not $this._seeded)
        {
            $this.SeedSnapshotIfPopulated()
            $this._seeded = $true
        }

        return $this._snapshot.Clone()
    }

    [Hashtable] GetAllParameters()
    {
        $result = $this.GetBoundParameters()
        foreach ($name in $this._info.NonSchemaProperties.Keys)
        {
            $value = $this._GetProperty($name)
            if ($null -ne $value)
            {
                $result[$name] = $value
            }
        }
        return $result
    }

    [Hashtable] ToHashtable()
    {
        return $this.GetBoundParameters()
    }

    [void] FromHashtable([Hashtable] $Source)
    {
        if ($null -eq $Source)
        {
            return
        }

        foreach ($entry in $Source.GetEnumerator())
        {
            $meta = $null
            if (-not $this._info.Meta.TryGetValue($entry.Key, [ref] $meta))
            {
                continue
            }

            if ($meta.IsSchema)
            {
                $this._SetProperty($meta.Property.Name, $entry.Value)
            }
            else
            {
                $this.($entry.Key) = $entry.Value
            }
        }
    }

    #endregion

    #region Identity

    # Replaces $MyInvocation.MyCommand.ModuleName.Replace('MSFT_', '') and
    # $MyInvocation.MyCommand.Source
    [System.String] GetResourceName()
    {
        return $this.GetType().Name
    }

    # Replaces $PSScriptRoot, used by every Export-TargetResource as
    # Get-M365DSCExportContentForResource -ModulePath $PSScriptRoot.
    [System.String] GetModulePath()
    {
        $module = Get-Module -Name 'Microsoft365DSC'
        if ($null -eq $module)
        {
            $module = Get-Module -Name 'Microsoft365DSC' -ListAvailable | Select-Object -First 1
        }
        return $module.ModuleBase
    }

    #endregion

    #region Shared resource plumbing

    # Replaces the copy-pasted #region Telemetry block in all 535 resources.
    [void] AddTelemetry([System.String] $MethodName)
    {
        $data = Format-M365DSCTelemetryParameters -ResourceName $this.GetResourceName() `
            -CommandName $MethodName `
            -Parameters $this.GetBoundParameters()
        Add-M365DSCTelemetryEvent -Data $data
    }

    [System.String] Connect([System.String] $Workload)
    {
        return (New-M365DSCConnection -Workload $Workload -InboundParameters $this.GetAllParameters())
    }

    [System.String] Connect([System.String] $Workload, [System.String] $Url)
    {
        return (New-M365DSCConnection -Workload $Workload -InboundParameters $this.GetAllParameters() -Url $Url)
    }

    # Replaces the copy-pasted New-M365DSCLogEntry call in every catch block.
    [void] LogError([System.Object] $Exception, [System.String] $Message)
    {
        New-M365DSCLogEntry -Message $Message `
            -Exception $Exception `
            -Source $this.GetResourceName() `
            -TenantId $this._GetProperty('TenantId') `
            -Credential $this._GetProperty('Credential')
    }


    # Emits the standard deprecation warning for every listed parameter the user actually bound.
    # TODO: callers remove their parameters (and this call) at the next breaking change release.
    hidden [void] WarnDeprecated([System.String[]] $ParameterNames)
    {
        $bound = $this.GetBoundParameters()
        foreach ($name in $ParameterNames)
        {
            if ($bound.ContainsKey($name))
            {
                Write-Warning -Message "The parameter '$name' is deprecated. It will be removed in the next breaking change release."
            }
        }
    }

    [System.String] DecodeTextPayload([System.Object] $Value)
    {
        if ($null -eq $Value -or $Value -isnot [System.String] -or [System.String]::IsNullOrEmpty($Value))
        {
            return [System.String] $Value
        }

        try
        {
            return [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($Value))
        }
        catch
        {
            return [System.String] $Value
        }
    }

    [System.String] EncodeTextPayload([System.Object] $Value)
    {
        if ($null -eq $Value -or $Value -isnot [System.String] -or [System.String]::IsNullOrEmpty($Value))
        {
            return [System.String] $Value
        }

        return [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($Value))
    }

    # Serialises a nullable boolean into a JSON literal
    [System.String] BoolToJson([System.Object] $Value)
    {
        if ($null -eq $Value)
        {
            return 'false'
        }

        return ([System.Boolean] $Value).ToString().ToLower()
    }

    [System.String] NumberToJson([System.Object] $Value)
    {
        if ($null -eq $Value)
        {
            return 'null'
        }

        return [System.Convert]::ToString($Value, [System.Globalization.CultureInfo]::InvariantCulture)
    }

    [void] RemoveForeignSubtypeProperties([System.Object] $Node, [System.Collections.Hashtable] $AllowedByType)
    {
        if ($Node -is [System.Collections.IDictionary])
        {
            $odataType = $Node['@odata.type']
            if ($null -ne $odataType -and $AllowedByType.ContainsKey($odataType))
            {
                foreach ($key in @($Node.Keys))
                {
                    if ($key -eq '@odata.type')
                    {
                        continue
                    }

                    if ($key -notin $AllowedByType.$odataType -or
                        ($Node.$key -is [System.String] -and [System.String]::IsNullOrWhiteSpace($Node.$key)))
                    {
                        $Node.Remove($key)
                    }
                }
            }

            foreach ($value in @($Node.Values))
            {
                $this.RemoveForeignSubtypeProperties($value, $AllowedByType)
            }
        }
        elseif ($Node -is [System.Collections.IEnumerable] -and $Node -isnot [System.String])
        {
            foreach ($item in $Node)
            {
                $this.RemoveForeignSubtypeProperties($item, $AllowedByType)
            }
        }
    }

    #endregion

    #region Default DSC method implementations

    # Default Test() for every resource. Splats GetCompareParameters() so a resource that only
    # needs custom comparison parameters overrides that method and keeps this Test() untouched.
    # Argument order is load-bearing: -DesiredValues must be evaluated BEFORE -CurrentValues so the
    # desired snapshot is taken before Get() runs.
    [bool] Test()
    {
        $previousVerbosePreference = Set-M365DSCVerboseScope
        try
        {
            $this.AddTelemetry('Test')

            $compareParameters = $this.GetCompareParameters()
            return (Test-M365DSCTargetResource -DesiredValues $this.GetBoundParameters() `
                    -ResourceName $this.GetResourceName() `
                    @compareParameters `
                    -CurrentValues $this.Get().ToHashtable())
        }
        finally
        {
            $null = Set-M365DSCVerboseScope -Restore $previousVerbosePreference
        }
    }

    # Reads a DateTime, DateTimeOffset or string as an instant. Strings use the invariant culture and a value
    # without offset counts as UTC. Returns $null when the value is empty or cannot be parsed.
    hidden static [System.Nullable[System.DateTimeOffset]] ConvertToDateTimeOffset([System.Object] $Value)
    {
        if ($Value -is [System.DateTimeOffset])
        {
            return [System.DateTimeOffset]$Value
        }

        if ($Value -is [System.DateTime])
        {
            $dateTime = [System.DateTime]$Value
            if ($dateTime.Kind -eq [System.DateTimeKind]::Unspecified)
            {
                $dateTime = [System.DateTime]::SpecifyKind($dateTime, [System.DateTimeKind]::Utc)
            }

            return [System.DateTimeOffset]::new($dateTime)
        }

        $text = [System.String]$Value
        $parsedValue = [System.DateTimeOffset]::MinValue
        if (-not [System.String]::IsNullOrEmpty($text) -and
            [System.DateTimeOffset]::TryParse($text, [System.Globalization.CultureInfo]::InvariantCulture, [System.Globalization.DateTimeStyles]::AssumeUniversal, [ref] $parsedValue))
        {
            return $parsedValue
        }

        return $null
    }

    # Formats a date and time as a round-trip UTC timestamp, e.g. 2030-01-01T00:00:00.0000000Z.
    # Returns $null for an empty value and the original text when it cannot be parsed.
    hidden static [System.String] FormatDateTime([System.Object] $Value)
    {
        if ($null -eq $Value -or [System.String]::IsNullOrEmpty([System.String] $Value))
        {
            return $null
        }

        $parsedValue = [M365DSCResourceBase]::ConvertToDateTimeOffset($Value)
        if ($null -eq $parsedValue)
        {
            return [System.String] $Value
        }

        return $parsedValue.UtcDateTime.ToString('o', [System.Globalization.CultureInfo]::InvariantCulture)
    }

    # Returns $true when both values are the same instant, or the same text when either cannot be parsed.
    hidden static [System.Boolean] IsSameDateTime([System.Object] $First, [System.Object] $Second)
    {
        $firstValue = [M365DSCResourceBase]::ConvertToDateTimeOffset($First)
        $secondValue = [M365DSCResourceBase]::ConvertToDateTimeOffset($Second)
        if ($null -ne $firstValue -and $null -ne $secondValue)
        {
            return $firstValue -eq $secondValue
        }

        return [System.String]$First -eq [System.String]$Second
    }

    # Reads a TimeSpan or an ISO-8601 duration such as P90D. Returns $null when the value is empty or cannot be parsed.
    hidden static [System.Nullable[System.TimeSpan]] ConvertToTimeSpan([System.Object] $Value)
    {
        if ($Value -is [System.TimeSpan])
        {
            return [System.TimeSpan]$Value
        }

        $text = [System.String]$Value
        if ([System.String]::IsNullOrEmpty($text))
        {
            return $null
        }

        try
        {
            return [System.Xml.XmlConvert]::ToTimeSpan($text)
        }
        catch
        {
            return $null
        }
    }

    # Formats a duration in its shortest ISO-8601 form, e.g. P90D for P90DT0H0M0S.
    # Returns $null for an empty value and the original text when it cannot be parsed.
    hidden static [System.String] FormatDuration([System.Object] $Value)
    {
        if ($null -eq $Value)
        {
            return $null
        }

        $span = [M365DSCResourceBase]::ConvertToTimeSpan($Value)
        if ($null -eq $span)
        {
            return [System.String]$Value
        }

        return [System.Xml.XmlConvert]::ToString([System.TimeSpan]$span)
    }

    # True when the time between the two dates matches the ISO 8601 duration to the minute.
    hidden static [System.Boolean] IsSameDuration([System.Object] $Duration, [System.Object] $StartDateTime, [System.Object] $EndDateTime)
    {
        $expectedSpan = [M365DSCResourceBase]::ConvertToTimeSpan($Duration)
        $start = [M365DSCResourceBase]::ConvertToDateTimeOffset($StartDateTime)
        $end = [M365DSCResourceBase]::ConvertToDateTimeOffset($EndDateTime)
        if ($null -eq $expectedSpan -or $null -eq $start -or $null -eq $end)
        {
            return $false
        }

        return [System.Math]::Abs((($end - $start) - $expectedSpan).TotalMinutes) -lt 1
    }

    # Warns that the resource is deprecated, names its replacement and, when given, a link with more information.
    hidden [void] WarnResourceDeprecated([System.String] $Replacement, [System.String] $InformationUrl)
    {
        Write-Warning -Message "The resource '$($this.GetResourceName())' is deprecated. It will be removed in a future release. Please use $Replacement instead."
        if (-not [System.String]::IsNullOrEmpty($InformationUrl))
        {
            Write-Warning -Message "For more information, please visit $InformationUrl"
        }
    }

    # Overridden by resources that need custom comparison parameters
    # (ExcludedProperties / IncludedProperties / PostProcessing / PostProcessingArgs).
    [Hashtable] GetCompareParameters()
    {
        return @{}
    }

    # True when the PostProcessing scriptblock runs for report generation (New-M365DSCDeltaReport)
    # rather than for Test(). Reporting compares two configuration files and has no guaranteed
    # workload connection, so callbacks that call a cmdlet must return their values untouched.
    static [bool] IsReportContext([System.Object[]] $PostProcessingArgs)
    {
        foreach ($argument in $PostProcessingArgs)
        {
            if ($argument -is [System.Collections.Hashtable] -and $argument['IsReport'] -eq $true)
            {
                return $true
            }
        }

        return $false
    }

    # Every schema property of the derived type. Replaces
    # $MyInvocation.MyCommand.Parameters.GetEnumerator()
    [System.String[]] GetSchemaPropertyNames()
    {
        return [System.String[]] $this._info.Properties.Keys
    }

    # Declared type of one schema property, or $null when the derived type has no such property.
    [Type] GetSchemaPropertyType([System.String] $Name)
    {
        $propertyInfo = $this._info.Properties[$Name]
        if ($null -eq $propertyInfo)
        {
            return $null
        }

        return $propertyInfo.PropertyType
    }

    [Hashtable] GetSettingsCatalogCompareParameters()
    {
        return $this.GetSettingsCatalogCompareParameters(@())
    }

    # Shared comparison shim for the settings-catalog resources.
    [Hashtable] GetSettingsCatalogCompareParameters([System.String[]] $ExcludedProperties)
    {
        $result = @{
            PostProcessing     = {
                param($DesiredValues, $CurrentValues, $ValuesToCheck, $PostProcessingArgs)
                foreach ($name in $PostProcessingArgs[0])
                {
                    $currentValue = $CurrentValues[$name]
                    $desiredValue = $DesiredValues[$name]

                    if ($currentValue -is [System.Collections.ICollection] -and $currentValue.Count -eq 0)
                    {
                        $currentValue = $null
                    }
                    if ($desiredValue -is [System.Collections.ICollection] -and $desiredValue.Count -eq 0)
                    {
                        $desiredValue = $null
                    }

                    if ($null -ne $currentValue -or $null -ne $desiredValue)
                    {
                        $ValuesToCheck[$name] = $null
                        if (-not $DesiredValues.ContainsKey($name))
                        {
                            $DesiredValues.Add($name, $null)
                        }
                    }
                }

                return [System.Tuple[Hashtable, Hashtable, Hashtable]]::new($DesiredValues, $CurrentValues, $ValuesToCheck)
            }
            # Prevent array unrolling
            PostProcessingArgs = @(, $this.GetSchemaPropertyNames())
        }

        if ($ExcludedProperties.Count -gt 0)
        {
            $result.ExcludedProperties = $ExcludedProperties
        }

        return $result
    }

    [Hashtable] GetForExport([Hashtable] $Values)
    {
        $this.FromHashtable($Values)
        return $this.Get().ToHashtable()
    }

    #endregion

    #region Windows PowerShell 5.1 dispatch

    [bool] RequiresPowerShellCore()
    {
        $this.ApplyEnsureDefault()
        return ($global:PSVersionTable.PSEdition -ne 'Core')
    }

    hidden [void] ApplyEnsureDefault()
    {
        $meta = $null
        if (-not $this._info.Meta.TryGetValue('Ensure', [ref] $meta) -or -not $meta.IsSchema -or
            -not [System.String]::IsNullOrEmpty($meta.Property.GetValue($this)))
        {
            return
        }

        $null = $this.GetBoundParameters()
        $meta.Property.SetValue($this, 'Present')
    }

    [System.Object] InvokeInPowerShellCore([System.String] $MethodName)
    {
        $previousVerbosePreference = Set-M365DSCVerboseScope
        try
        {
            $output = Invoke-M365DSCClassResourceInPowerShellCore -ClassName $this.GetResourceName() `
                -MethodName $MethodName `
                -Parameters $this.GetAllParameters()

            if ($null -eq $output)
            {
                return $null
            }

            return $output
        }
        finally
        {
            $null = Set-M365DSCVerboseScope -Restore $previousVerbosePreference
        }
    }

    #endregion
}
