<#
    The ONE place where raw types (Graph CSDL Edm.* types and .NET types discovered through
    Get-Command) map to everything the generator emits: the CLR type on the class property and
    the kind of fake value the unit tests and examples use.

    Value-type class properties are emitted as System.Nullable[T]. The base class treats
    "specified" as "not $null" (see M365DSCResourceBase.GetBoundParameters), so a plain [Boolean]
    would make an omitted property indistinguishable from one explicitly set to $false.
    Key properties are the exception: the DSC engine rejects Nullable[T] on a [DscProperty(Key)]
    member outright, and a key is always supplied anyway.
#>
$script:M365DSCTypeTable = @{
    'edm.string'                                    = @{ Clr = 'System.String'; FakeKind = 'String' }
    'system.string'                                 = @{ Clr = 'System.String'; FakeKind = 'String' }
    'edm.boolean'                                   = @{ Clr = 'System.Boolean'; FakeKind = 'Boolean' }
    'system.boolean'                                = @{ Clr = 'System.Boolean'; FakeKind = 'Boolean' }
    'system.management.automation.switchparameter'  = @{ Clr = 'System.Boolean'; FakeKind = 'Boolean' }
    'edm.int32'                                     = @{ Clr = 'System.Int32'; FakeKind = 'Int' }
    'system.int32'                                  = @{ Clr = 'System.Int32'; FakeKind = 'Int' }
    'system.uint32'                                 = @{ Clr = 'System.UInt32'; FakeKind = 'Int' }
    'edm.int64'                                     = @{ Clr = 'System.Int64'; FakeKind = 'Int' }
    'system.int64'                                  = @{ Clr = 'System.Int64'; FakeKind = 'Int' }
    'system.uint64'                                 = @{ Clr = 'System.UInt64'; FakeKind = 'Int' }
    'edm.byte'                                      = @{ Clr = 'System.Byte'; FakeKind = 'Int' }
    'edm.single'                                    = @{ Clr = 'System.Single'; FakeKind = 'Real' }
    'system.single'                                 = @{ Clr = 'System.Single'; FakeKind = 'Real' }
    'edm.double'                                    = @{ Clr = 'System.Double'; FakeKind = 'Real' }
    'system.double'                                 = @{ Clr = 'System.Double'; FakeKind = 'Real' }
    'edm.decimal'                                   = @{ Clr = 'System.Double'; FakeKind = 'Real' }
    'system.decimal'                                = @{ Clr = 'System.Double'; FakeKind = 'Real' }
    # Date, time and GUID values travel as strings, matching the shipped resources.
    'edm.datetimeoffset'                            = @{ Clr = 'System.String'; FakeKind = 'DateTime' }
    'edm.date'                                      = @{ Clr = 'System.String'; FakeKind = 'DateTime' }
    'system.datetime'                               = @{ Clr = 'System.String'; FakeKind = 'DateTime' }
    'system.datetimeoffset'                         = @{ Clr = 'System.String'; FakeKind = 'DateTime' }
    'edm.timeofday'                                 = @{ Clr = 'System.String'; FakeKind = 'Time' }
    'edm.duration'                                  = @{ Clr = 'System.String'; FakeKind = 'Time' }
    'system.timespan'                               = @{ Clr = 'System.String'; FakeKind = 'Time' }
    'edm.guid'                                      = @{ Clr = 'System.String'; FakeKind = 'Guid' }
    'system.guid'                                   = @{ Clr = 'System.String'; FakeKind = 'Guid' }
    'edm.binary'                                    = @{ Clr = 'System.String'; FakeKind = 'String' }
    'edm.stream'                                    = @{ Clr = 'System.String'; FakeKind = 'String' }
    'system.management.automation.pscredential'     = @{ Clr = 'System.Management.Automation.PSCredential'; FakeKind = 'Credential' }
    'system.security.securestring'                  = @{ Clr = 'System.Management.Automation.PSCredential'; FakeKind = 'Credential' }
}

# CLR value types that must be wrapped in System.Nullable[T] on the class.
$script:M365DSCNullableClrTypes = @(
    'System.Boolean', 'System.Int32', 'System.UInt32', 'System.Int64', 'System.UInt64',
    'System.Byte', 'System.Single', 'System.Double'
)

<#
.SYNOPSIS
    Resolves a raw property type into its CLR / fake-value projection.

.DESCRIPTION
    Unknown types resolve to String so that generation always produces a valid resource; the
    caller receives IsFallback = $true and can warn about the property.
#>
function Resolve-M365DSCTypeInfo
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Type
    )

    $lookup = $Type.ToLowerInvariant()
    $entry = $script:M365DSCTypeTable[$lookup]

    if ($null -eq $entry)
    {
        return @{
            Clr        = 'System.String'
            FakeKind   = 'String'
            IsFallback = $true
        }
    }

    $result = @{ IsFallback = $false }
    foreach ($key in $entry.Keys)
    {
        $result[$key] = $entry[$key]
    }

    return $result
}

<#
.SYNOPSIS
    Creates the intermediate representation of one resource property.

.DESCRIPTION
    Every emitted artifact - class property block, hashtable mapping, fake values for unit tests
    and examples - is a projection of the objects this function returns. Complex types carry
    their member models in Members and reference their CIM class through CimClassName.

.PARAMETER Name
    Specifies the DSC property name (PascalCase).

.PARAMETER Type
    Specifies the raw type name, e.g. 'Edm.String', 'System.Int32'. Ignored for complex types.

.PARAMETER GraphName
    Specifies the Graph API (camelCase) name. Defaults to the camelCase form of Name.

.PARAMETER Description
    Specifies the property description used in the class Description attribute.

.PARAMETER EnumValues
    Specifies the allowed values. Turns the property into a ValidateSet/ValueMap string property.

.PARAMETER CimClassName
    Specifies the CIM class for complex properties, e.g. 'MSFT_AADPermissionGrantConditionSet'.

.PARAMETER Members
    Specifies the nested property models of a complex property.

.PARAMETER IsFromAdditionalProperties
    Indicates that the Graph cmdlet returns this property nested under AdditionalProperties.

.PARAMETER IsReadOnly
    Indicates that the endpoint configures the value. A configuration can never set it.
#>
function New-M365DSCPropertyModel
{
    [CmdletBinding()]
    [OutputType([System.Management.Automation.PSCustomObject])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [Parameter()]
        [System.String]
        $Type = 'Edm.String',

        [Parameter()]
        [System.String]
        $GraphName,

        [Parameter()]
        [AllowEmptyString()]
        [System.String]
        $Description = '',

        [Parameter()]
        [System.Boolean]
        $IsArray = $false,

        [Parameter()]
        [System.Boolean]
        $IsKey = $false,

        [Parameter()]
        [System.Boolean]
        $IsMandatory = $false,

        [Parameter()]
        [System.String[]]
        $EnumValues = @(),

        [Parameter()]
        [System.String]
        $CimClassName,

        [Parameter()]
        [System.Object[]]
        $Members = @(),

        [Parameter()]
        [System.Boolean]
        $IsAuth = $false,

        [Parameter()]
        [System.Boolean]
        $IsFromAdditionalProperties = $false,

        [Parameter()]
        [System.Boolean]
        $IsReadOnly = $false
    )

    $pascalName = Get-StringFirstCharacterToUpper -Value $Name
    if ([System.String]::IsNullOrEmpty($GraphName))
    {
        $GraphName = Get-StringFirstCharacterToLower -Value $Name
    }

    # Members render as CIM class properties - keep them alphabetical like the resource schema.
    $Members = @($Members | Sort-Object -Property Name)

    $isComplex = -not [System.String]::IsNullOrEmpty($CimClassName)
    $isEnum = $EnumValues.Count -gt 0

    if ($isComplex)
    {
        $clrType = $CimClassName
        $fakeKind = 'Complex'
    }
    elseif ($isEnum)
    {
        $clrType = 'System.String'
        $fakeKind = 'Enum'
    }
    else
    {
        $typeInfo = Resolve-M365DSCTypeInfo -Type $Type
        if ($typeInfo.IsFallback)
        {
            Write-Verbose -Message "Property '$pascalName': no mapping for type '$Type', falling back to String."
        }

        $clrType = $typeInfo.Clr
        $fakeKind = $typeInfo.FakeKind
    }

    if ($IsArray)
    {
        $clrType = "$clrType[]"
    }
    elseif (-not $IsKey -and $clrType -in $script:M365DSCNullableClrTypes)
    {
        $clrType = "System.Nullable[$clrType]"
    }

    $model = [PSCustomObject]@{
        Name                       = $pascalName
        GraphName                  = $GraphName
        RawType                    = $Type
        ClrType                    = $clrType
        CimClassName               = $CimClassName
        FakeKind                   = $fakeKind
        IsArray                    = $IsArray
        IsKey                      = $IsKey
        IsMandatory                = $IsMandatory
        IsComplex                  = $isComplex
        IsEnum                     = $isEnum
        IsAuth                     = $IsAuth
        IsFromAdditionalProperties = $IsFromAdditionalProperties
        IsReadOnly                 = $IsReadOnly
        EnumValues                 = $EnumValues
        Description                = $Description
        Members                    = $Members
        FakeValue                  = $null
        DriftValue                 = $null
    }

    $model.FakeValue = Get-M365DSCFakeValue -PropertyModel $model
    $model.DriftValue = Get-M365DSCFakeValue -PropertyModel $model -Drift

    return $model
}
