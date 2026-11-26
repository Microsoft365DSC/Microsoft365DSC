class CharacterizationThing
{
    [System.String] $Name
    [System.Int32] $Number
    [System.String] $Empty
}

class CharacterizationBag
{
    [System.String] $Name
    [System.String] $Empty
    [System.String[]] $Tags
}

class CharacterizationLink
{
    [System.String] $Name
    [System.Uri] $Link
}

BeforeAll {
    Import-Module "$PSScriptRoot/../../../Modules/Microsoft365DSC/Modules/M365DSCDllLoader.psm1" -Force -Global
    Initialize-M365DSCDllLoader

    $Script:NoMapping = [System.Collections.Generic.List[Microsoft365DSC.Converter.ComplexTypeMapping]]::new()

    function New-Mapping
    {
        [CmdletBinding()]
        param
        (
            [Parameter(Mandatory = $true)] [System.String] $Name,
            [Parameter(Mandatory = $true)] [System.String] $CimInstanceName,
            [Parameter()] [Switch] $IsArray,
            [Parameter()] [Switch] $IsRequired
        )

        $mapping = [Microsoft365DSC.Converter.ComplexTypeMapping]::new()
        $mapping.Name = $Name
        $mapping.CimInstanceName = $CimInstanceName
        $mapping.IsArray = $IsArray.IsPresent
        $mapping.IsRequired = $IsRequired.IsPresent
        return $mapping
    }

    function New-MappingList
    {
        [CmdletBinding()]
        param([Parameter()] [Microsoft365DSC.Converter.ComplexTypeMapping[]] $Mappings = @())

        $list = [System.Collections.Generic.List[Microsoft365DSC.Converter.ComplexTypeMapping]]::new()
        foreach ($mapping in $Mappings)
        {
            $list.Add($mapping)
        }
        return $list
    }

    function ConvertTo-DscString
    {
        [CmdletBinding()]
        param
        (
            [Parameter()] $InputObject,
            [Parameter()] [System.String] $CimInstanceName = 'MSFT_Thing',
            [Parameter()] $Mappings = $Script:NoMapping,
            [Parameter()] [System.UInt32] $IndentLevel = 3,
            [Parameter()] [Switch] $IsArray
        )

        return [Microsoft365DSC.Converter.ComplexObjectConverter]::ToDscString($InputObject, $CimInstanceName, $Mappings, '', $IndentLevel, $IsArray.IsPresent)
    }

    function Join-Lines
    {
        param([Parameter(Mandatory = $true)] [AllowEmptyString()] [System.String[]] $Lines)

        return ($Lines -join "`r`n")
    }

    $Script:Indent8 = ' ' * 8
    $Script:Indent12 = ' ' * 12
    $Script:Indent16 = ' ' * 16
    $Script:Indent20 = ' ' * 20
    $Script:Indent24 = ' ' * 24
}

Describe 'ComplexObjectConverter.ToDscString' {
    It 'Renders a flat hashtable with sorted keys, four-space indentation and CRLF line endings' {
        $result = ConvertTo-DscString -InputObject @{ Beta = 'b'; alpha = 'a'; Gamma = 3; Flag = $true; Arr = @('x', 'y'); One = @('single') }

        $expected = Join-Lines -Lines @(
            'MSFT_Thing{'
            ($Script:Indent16 + 'alpha = "a"')
            ($Script:Indent16 + 'Arr = @(')
            ($Script:Indent20 + '"x"')
            ($Script:Indent20 + '"y"')
            ($Script:Indent16 + ')')
            ($Script:Indent16 + 'Beta = "b"')
            ($Script:Indent16 + 'Flag = $True')
            ($Script:Indent16 + 'Gamma = 3')
            ($Script:Indent16 + 'One = @("single")')
            ($Script:Indent12 + '}')
        )
        $result | Should -BeExactly $expected
    }

    It 'Adds the MSFT_ prefix when the CIM class name lacks it and honours the indent level' {
        $result = ConvertTo-DscString -InputObject @{ A = 'a' } -CimInstanceName 'Thing' -IndentLevel 2 -IsArray

        $expected = Join-Lines -Lines @(
            ''
            ($Script:Indent8 + 'MSFT_Thing{')
            ($Script:Indent12 + 'A = "a"')
            ($Script:Indent8 + '}')
        )
        $result | Should -BeExactly $expected
    }

    It 'Renders an array input as one string per element with the closing indent on the last element' {
        $result = ConvertTo-DscString -InputObject @(@{ A = 'a1' }, @{ A = 'a2' })

        $result -is [System.Object[]] | Should -BeTrue
        $result.Count | Should -Be 2
        $result[0] | Should -BeExactly (Join-Lines -Lines @('', ($Script:Indent16 + 'MSFT_Thing{'), ($Script:Indent20 + 'A = "a1"'), ($Script:Indent16 + '}')))
        $result[1] | Should -BeExactly (Join-Lines -Lines @('', ($Script:Indent16 + 'MSFT_Thing{'), ($Script:Indent20 + 'A = "a2"'), ($Script:Indent16 + '}'), $Script:Indent12))
    }

    It 'Renders mapped nested objects and arrays of nested objects' {
        $mappings = New-MappingList -Mappings @((New-Mapping -Name 'Nested' -CimInstanceName 'MSFT_Inner' -IsRequired), (New-Mapping -Name 'NestedArray' -CimInstanceName 'MSFT_Inner' -IsArray -IsRequired))
        $result = ConvertTo-DscString -InputObject @{ Id = 'x'; Nested = @{ K = 'v' }; NestedArray = @(@{ K = 'v1' }, @{ K = 'v2' }) } -Mappings $mappings

        $expected = Join-Lines -Lines @(
            'MSFT_Thing{'
            ($Script:Indent16 + 'Id = "x"')
            ($Script:Indent16 + 'Nested = MSFT_Inner{')
            ($Script:Indent20 + 'K = "v"')
            ($Script:Indent16 + '}')
            ($Script:Indent16 + 'NestedArray = @(')
            ($Script:Indent20 + 'MSFT_Inner{')
            ($Script:Indent24 + 'K = "v1"')
            ($Script:Indent20 + '}')
            ($Script:Indent20 + 'MSFT_Inner{')
            ($Script:Indent24 + 'K = "v2"')
            ($Script:Indent20 + '}')
            ($Script:Indent16 + ')')
            ($Script:Indent12 + '}')
        )
        $result | Should -BeExactly $expected
    }

    It 'Renders required mapped properties that are null as $null and @()' {
        $mappings = New-MappingList -Mappings @((New-Mapping -Name 'Nested' -CimInstanceName 'MSFT_Inner' -IsRequired), (New-Mapping -Name 'NestedArray' -CimInstanceName 'MSFT_Inner' -IsArray -IsRequired))
        $result = ConvertTo-DscString -InputObject @{ Id = 'x'; Nested = $null; NestedArray = $null } -Mappings $mappings

        $expected = Join-Lines -Lines @(
            'MSFT_Thing{'
            ($Script:Indent16 + 'Id = "x"')
            ($Script:Indent16 + 'Nested = $null')
            ($Script:Indent16 + 'NestedArray = @()')
            ($Script:Indent12 + '}')
        )
        $result | Should -BeExactly $expected
    }

    It 'Omits optional mapped properties that are null' {
        $mappings = New-MappingList -Mappings @((New-Mapping -Name 'Nested' -CimInstanceName 'MSFT_Inner'))
        $result = ConvertTo-DscString -InputObject @{ Id = 'x'; Nested = $null } -Mappings $mappings

        $result | Should -BeExactly (Join-Lines -Lines @('MSFT_Thing{', ($Script:Indent16 + 'Id = "x"'), ($Script:Indent12 + '}')))
    }

    It 'Renders an empty mapped object as $null followed by a blank line and an empty mapped array as @()' -Tag 'CurrentBehaviour' {
        $mappings = New-MappingList -Mappings @((New-Mapping -Name 'Nested' -CimInstanceName 'MSFT_Inner' -IsRequired), (New-Mapping -Name 'NestedArray' -CimInstanceName 'MSFT_Inner' -IsArray -IsRequired))
        $result = ConvertTo-DscString -InputObject @{ Id = 'x'; Nested = @{ }; NestedArray = @() } -Mappings $mappings

        $expected = Join-Lines -Lines @(
            'MSFT_Thing{'
            ($Script:Indent16 + 'Id = "x"')
            ($Script:Indent16 + 'Nested = $null')
            ''
            ($Script:Indent16 + 'NestedArray = @()')
            ($Script:Indent12 + '}')
        )
        $result | Should -BeExactly $expected
    }

    It 'Matches mapping names case-insensitively for values but case-sensitively for nulls' -Tag 'CurrentBehaviour' {
        $mappings = New-MappingList -Mappings @((New-Mapping -Name 'Nested' -CimInstanceName 'MSFT_Inner' -IsRequired), (New-Mapping -Name 'NestedArray' -CimInstanceName 'MSFT_Inner' -IsArray -IsRequired))
        $result = ConvertTo-DscString -InputObject @{ Id = 'x'; nested = @{ K = 'v' }; nestedarray = $null } -Mappings $mappings

        $expected = Join-Lines -Lines @(
            'MSFT_Thing{'
            ($Script:Indent16 + 'Id = "x"')
            ($Script:Indent16 + 'nested = MSFT_Inner{')
            ($Script:Indent20 + 'K = "v"')
            ($Script:Indent16 + '}')
            ($Script:Indent12 + '}')
        )
        $result | Should -BeExactly $expected
    }

    It 'Returns an empty string for an empty object and for an object whose values are all null' {
        ConvertTo-DscString -InputObject @{ } | Should -BeExactly ''
        ConvertTo-DscString -InputObject @{ A = $null } | Should -BeExactly ''
        ConvertTo-DscString -InputObject $null | Should -BeExactly ''
    }

    It 'Escapes backticks, dollar signs, double quotes and the three smart quotes in string values' {
        $value = 'tick`dollar$quote"' + [string][char]0x201C + 'q' + [string][char]0x201D
        $result = ConvertTo-DscString -InputObject @{ S = $value }

        $escaped = 'tick``dollar`$quote`"`' + [string][char]0x201C + 'q`' + [string][char]0x201D
        $result | Should -BeExactly (Join-Lines -Lines @('MSFT_Thing{', ($Script:Indent16 + 'S = "' + $escaped + '"'), ($Script:Indent12 + '}')))
    }

    It 'Replaces the right single quotation mark with two single quotes and leaves the replacement character alone' {
        $value = 'a' + [string][char]0xFFFD + 'b' + [string][char]0x2019 + 'c'
        $result = ConvertTo-DscString -InputObject @{ S = $value }

        $result | Should -BeExactly (Join-Lines -Lines @('MSFT_Thing{', ($Script:Indent16 + 'S = "a' + [string][char]0xFFFD + 'b''''c"'), ($Script:Indent12 + '}')))
    }

    It 'Escapes array items without the smart quote handling' {
        $result = ConvertTo-DscString -InputObject @{ Arr = @('a$b', 'c"d', 'e`f', ('g' + [string][char]0x201C)) }

        $expected = Join-Lines -Lines @(
            'MSFT_Thing{'
            ($Script:Indent16 + 'Arr = @(')
            ($Script:Indent20 + '"a`$b"')
            ($Script:Indent20 + '"c`"d"')
            ($Script:Indent20 + '"e``f"')
            ($Script:Indent20 + '"g' + [string][char]0x201C + '"')
            ($Script:Indent16 + ')')
            ($Script:Indent12 + '}')
        )
        $result | Should -BeExactly $expected
    }

    It 'Renders a PowerShell class instance from its non-null properties' {
        $thing = [CharacterizationThing]::new()
        $thing.Name = 'n'
        $thing.Number = 2

        $result = ConvertTo-DscString -InputObject $thing

        $result | Should -BeExactly (Join-Lines -Lines @('MSFT_Thing{', ($Script:Indent16 + 'Name = "n"'), ($Script:Indent16 + 'Number = 2'), ($Script:Indent12 + '}')))
    }

    It 'Renders a CIM instance like a hashtable' {
        $instance = New-CimInstance -ClassName MSFT_Inner -ClientOnly -Namespace root/microsoft/windows/desiredstateconfiguration -Property @{ K = 'v' }

        ConvertTo-DscString -InputObject $instance -CimInstanceName 'MSFT_Inner' | Should -BeExactly (Join-Lines -Lines @('MSFT_Inner{', ($Script:Indent16 + 'K = "v"'), ($Script:Indent12 + '}')))
    }

    It 'Renders a nested Graph model under its lower-cased type name' -Tag 'CurrentBehaviour' {
        if (-not ('Microsoft.Graph.PowerShell.Models.M365DSCCharacterizationOuter' -as [type]))
        {
            Add-Type -TypeDefinition @'
namespace Microsoft.Graph.PowerShell.Models
{
    public class M365DSCCharacterizationInner
    {
        public string Key { get; set; }
    }

    public class M365DSCCharacterizationOuter
    {
        public string Name { get; set; }
        public M365DSCCharacterizationInner Inner { get; set; }
    }
}
'@
        }

        $outer = [Microsoft.Graph.PowerShell.Models.M365DSCCharacterizationOuter]::new()
        $outer.Name = 'n'
        $outer.Inner = [Microsoft.Graph.PowerShell.Models.M365DSCCharacterizationInner]::new()
        $outer.Inner.Key = 'k'

        $result = ConvertTo-DscString -InputObject $outer

        $expected = Join-Lines -Lines @(
            'MSFT_Thing{'
            ($Script:Indent16 + 'Inner = MSFT_m365dsccharacterizationinner{')
            ($Script:Indent20 + 'Key = "k"')
            ($Script:Indent16 + '}')
            ($Script:Indent16 + 'Name = "n"')
            ($Script:Indent12 + '}')
        )
        $result | Should -BeExactly $expected
    }
}

Describe 'ComplexObjectConverter.ToHashtable and ObjectNormalizer.Normalize' {
    It 'Decompose a PowerShell class instance and omit its null properties' {
        $bag = [CharacterizationBag]::new()
        $bag.Name = 'n'
        $bag.Tags = @('a', 'b')

        $hashtable = [Microsoft365DSC.Converter.ComplexObjectConverter]::ToHashtable($bag)
        ($hashtable.Keys | Sort-Object) | Should -Be @('Name', 'Tags')
        $hashtable['Tags'].Count | Should -Be 2

        $normalized = [Microsoft365DSC.Converter.ObjectNormalizer]::Normalize($bag)
        ($normalized.Keys | Sort-Object) | Should -Be @('Name', 'Tags')
    }

    It 'Leaves a class instance declared inside a function untouched in Normalize but decomposes it in ToHashtable' -Tag 'CurrentBehaviour' {
        function New-ScopedInstance
        {
            class CharacterizationScoped
            {
                [System.String] $Name
            }
            $instance = [CharacterizationScoped]::new()
            $instance.Name = 'n'
            return $instance
        }
        $scoped = New-ScopedInstance

        $scoped.GetType().Namespace | Should -Match 'New-ScopedInstance$'
        ([Microsoft365DSC.Converter.ComplexObjectConverter]::ToHashtable($scoped))['Name'] | Should -Be 'n'
        [object]::ReferenceEquals([Microsoft365DSC.Converter.ObjectNormalizer]::Normalize($scoped), $scoped) | Should -BeTrue
    }

    It 'Decompose a Uri held by a class property into a hashtable while a top-level Uri stays a leaf' -Tag 'CurrentBehaviour' {
        $link = [CharacterizationLink]::new()
        $link.Name = 'n'
        $link.Link = [System.Uri] 'https://contoso.example/path'

        ([Microsoft365DSC.Converter.ComplexObjectConverter]::ToHashtable($link))['Link'] -is [System.Collections.Hashtable] | Should -BeTrue
        ([Microsoft365DSC.Converter.ObjectNormalizer]::Normalize($link))['Link'] -is [System.Collections.Hashtable] | Should -BeTrue
        [Microsoft365DSC.Converter.ObjectNormalizer]::Normalize([System.Uri] 'https://contoso.example') -is [System.Uri] | Should -BeTrue
    }

    It 'Normalizes a generic list to an object array and a CIM instance array to hashtables' {
        $list = [System.Collections.Generic.List[object]]@(1, @{ A = 1 })
        $normalizedList = [Microsoft365DSC.Converter.ObjectNormalizer]::Normalize($list)
        $normalizedList -is [System.Object[]] | Should -BeTrue
        $normalizedList.Count | Should -Be 2

        $instance = New-CimInstance -ClassName MSFT_Inner -ClientOnly -Namespace root/microsoft/windows/desiredstateconfiguration -Property @{ K = 'v' }
        $normalizedInstances = [Microsoft365DSC.Converter.ObjectNormalizer]::Normalize([object[]]@($instance))
        $normalizedInstances[0] -is [System.Collections.Hashtable] | Should -BeTrue
        $normalizedInstances[0]['K'] | Should -Be 'v'
    }

    It 'Converts two same-named classes independently' {
        $first = & ([scriptblock]::Create('class CharacterizationDup { [System.String] $A = "one" }; [CharacterizationDup]::new()'))
        $second = & ([scriptblock]::Create('class CharacterizationDup { [System.String] $A = "two" }; [CharacterizationDup]::new()'))

        [object]::ReferenceEquals($first.GetType(), $second.GetType()) | Should -BeFalse
        ([Microsoft365DSC.Converter.ComplexObjectConverter]::ToHashtable($first))['A'] | Should -Be 'one'
        ([Microsoft365DSC.Converter.ComplexObjectConverter]::ToHashtable($second))['A'] | Should -Be 'two'
    }
}

Describe 'HashtableConverter.ConvertToString nesting' {
    It 'Renders nested hashtables inside arrays and joins nested entries with the platform newline' {
        $result = [Microsoft365DSC.Converter.HashtableConverter]::ConvertToString(@{ N = @{ B = 2; A = 1 }; L = @(@{ X = 1 }, 'y') })

        $result | Should -BeExactly ('L=({X=1},y)' + [System.Environment]::NewLine + 'N={A=1' + [System.Environment]::NewLine + 'B=2}')
    }
}

Describe 'CacheManager schema reference semantics' {
    AfterAll {
        [Microsoft365DSC.Cache.CacheManager]::ClearSchema()
    }

    It 'Returns a new list on every load and null after a clear' {
        [Microsoft365DSC.Cache.CacheManager]::LoadSchema([System.Collections.Generic.List[object]]@(@{ ClassName = 'MSFT_A' }))
        $first = [Microsoft365DSC.Cache.CacheManager]::Schema
        [Microsoft365DSC.Cache.CacheManager]::LoadSchema([System.Collections.Generic.List[object]]@(@{ ClassName = 'MSFT_A' }))
        $second = [Microsoft365DSC.Cache.CacheManager]::Schema

        [object]::ReferenceEquals($first, $second) | Should -BeFalse
        [Microsoft365DSC.Cache.CacheManager]::ClearSchema()
        [Microsoft365DSC.Cache.CacheManager]::Schema | Should -BeNullOrEmpty
        [Microsoft365DSC.Cache.CacheManager]::IsSchemaLoaded | Should -BeFalse
    }
}

Describe 'SettingsCatalogHelper.GetSettingName with duplicated definitions' {
    It 'Derives the name from the setting id when the same definition is listed three times' -Tag 'CurrentBehaviour' {
        $definition = @{ Id = 'device_vendor_msft_policy_config_name'; Name = 'name'; OffsetUri = '/a/b/name' }
        $definitions = [System.Collections.Generic.List[object]]::new()
        $definitions.Add($definition)
        $definitions.Add($definition)
        $definitions.Add($definition)

        [Microsoft365DSC.Intune.SettingsCatalogHelper]::GetSettingName($definition, $definitions) | Should -Be 'config_name'
    }

    It 'Keeps the plain name when the same definition is listed twice' {
        $definition = @{ Id = 'device_vendor_msft_policy_config_name'; Name = 'name'; OffsetUri = '/a/b/name' }
        $definitions = [System.Collections.Generic.List[object]]::new()
        $definitions.Add($definition)
        $definitions.Add($definition)

        [Microsoft365DSC.Intune.SettingsCatalogHelper]::GetSettingName($definition, $definitions) | Should -Be 'name'
    }
}
