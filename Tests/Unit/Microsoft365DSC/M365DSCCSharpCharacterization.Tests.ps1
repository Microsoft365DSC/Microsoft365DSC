<#
    Characterization tests for the compiled helpers under src/.

    These pin the CURRENT observable behaviour of the public entry points that the PowerShell
    module calls, so that refactoring can be shown to preserve it. They are not a statement that
    the current behaviour is correct.

    Tests tagged 'CurrentBehaviour' pin behaviour that is known to be defective. The phase that
    changes each one is named in the test body. Changing an expectation here is a deliberate
    behaviour change and belongs in the commit that makes it.
#>

BeforeAll {
    Import-Module "$PSScriptRoot/../../../Modules/Microsoft365DSC/Modules/M365DSCDllLoader.psm1" -Force -Global
    Initialize-M365DSCDllLoader

    $Script:AllAuthMethods = @('ApplicationWithSecret', 'CertificateThumbprint', 'CertificatePath', 'Credentials', 'CredentialsWithTenantId', 'CredentialsWithApplicationId', 'ManagedIdentity', 'AccessTokens')

    $Script:Schema = @(
        @{
            ClassName  = 'MSFT_TestResource'
            Parameters = @(
                @{ Name = 'Identity'; CIMType = 'String'; Option = 'Key' }
                @{ Name = 'DisplayName'; CIMType = 'String'; Option = 'Write' }
                @{ Name = 'Count'; CIMType = 'UInt32'; Option = 'Write' }
                @{ Name = 'Tags'; CIMType = 'StringArray'; Option = 'Write' }
                @{ Name = 'Ensure'; CIMType = 'String'; Option = 'Write' }
                @{ Name = 'Credential'; CIMType = 'PSCredential'; Option = 'Write' }
                @{ Name = 'Items'; CIMType = 'MSFT_TestItem[]'; Option = 'Write' }
            )
        }
        @{
            ClassName  = 'MSFT_TestItem'
            Parameters = @(
                @{ Name = 'Key'; CIMType = 'String'; Option = 'Required' }
                @{ Name = 'Value'; CIMType = 'String'; Option = 'Write' }
            )
        }
    )

    function Invoke-ResourceCompare
    {
        [CmdletBinding()]
        param
        (
            [Parameter(Mandatory = $true)] $Desired,
            [Parameter()] $Current,
            [Parameter()] $ValuesToCheck,
            [Parameter()] $SchemaOverride = 'unset'
        )

        if ($null -eq $ValuesToCheck) { $ValuesToCheck = $Desired }
        $schemaArg = if ($SchemaOverride -is [System.String] -and $SchemaOverride -eq 'unset') { [object[]]$Script:Schema } else { $SchemaOverride }

        return [Microsoft365DSC.Compare.ResourceComparer]::Compare($Desired, $Current, $ValuesToCheck, $schemaArg, 'TestResource', $null, $null)
    }

    function Get-DriftFor
    {
        [CmdletBinding()]
        param
        (
            [Parameter(Mandatory = $true)] $Result,
            [Parameter(Mandatory = $true)] [System.String] $PropertyName
        )

        return $Result.DriftInfo | Where-Object -FilterScript { $_['PropertyName'] -eq $PropertyName }
    }
}

Describe 'ResourceComparer.Compare' {
    It 'Reports no drift when desired and current match' {
        $values = @{ Identity = 'a'; DisplayName = 'Contoso'; Count = 3; Tags = @('x', 'y'); Ensure = 'Present' }
        $result = Invoke-ResourceCompare -Desired $values -Current $values.Clone()

        $result.TestResult | Should -BeTrue
        $result.DriftInfo.Count | Should -Be 0
        $result.DriftedParameters.Count | Should -Be 0
    }

    It 'Reports one drift entry per drifted scalar and array property' {
        $desired = @{ Identity = 'a'; DisplayName = 'Contoso'; Count = 3; Tags = @('x', 'y'); Ensure = 'Present' }
        $current = @{ Identity = 'a'; DisplayName = 'Fabrikam'; Count = 3; Tags = @('x', 'z'); Ensure = 'Present' }
        $result = Invoke-ResourceCompare -Desired $desired -Current $current

        $result.TestResult | Should -BeFalse
        $result.DriftInfo.Count | Should -Be 2
        (Get-DriftFor -Result $result -PropertyName 'DisplayName')['CurrentValue'] | Should -Be 'Fabrikam'
        (Get-DriftFor -Result $result -PropertyName 'DisplayName')['DesiredValue'] | Should -Be 'Contoso'
        (Get-DriftFor -Result $result -PropertyName 'Tags')['CurrentValue'] | Should -Be 'x, z'
        (Get-DriftFor -Result $result -PropertyName 'Tags')['DesiredValue'] | Should -Be 'x, y'
        ($result.DriftedParameters.Keys | Sort-Object) | Should -Be @('DisplayName', 'Tags')
    }

    It 'Skips Key properties and PSCredential properties declared in the schema' {
        $desired = @{ Identity = 'a'; DisplayName = 'Contoso'; Ensure = 'Present'; Credential = 'desired-secret' }
        $current = @{ Identity = 'b'; DisplayName = 'Contoso'; Ensure = 'Present'; Credential = 'current-secret' }
        $result = Invoke-ResourceCompare -Desired $desired -Current $current

        $result.TestResult | Should -BeTrue
        $result.DriftInfo.Count | Should -Be 0
    }

    It 'Emits an Ensure drift when the resource is desired Present but is Absent' {
        $desired = @{ Identity = 'a'; DisplayName = 'Contoso'; Count = 3; Tags = @('x', 'y'); Ensure = 'Present' }
        $result = Invoke-ResourceCompare -Desired $desired -Current @{ Identity = 'a'; Ensure = 'Absent' }

        $result.TestResult | Should -BeFalse
        $result.DriftInfo[0]['PropertyName'] | Should -Be 'Ensure'
        $result.DriftInfo[0]['CurrentValue'] | Should -Be 'Absent'
        $result.DriftInfo[0]['DesiredValue'] | Should -Be 'Present'
        $result.DriftInfo.Count | Should -Be 5
    }

    It 'Short-circuits when both sides are Absent' {
        $desired = @{ Identity = 'a'; DisplayName = 'zzz'; Ensure = 'Absent' }
        $result = Invoke-ResourceCompare -Desired $desired -Current @{ Identity = 'a'; Ensure = 'Absent' }

        $result.TestResult | Should -BeTrue
        $result.DriftInfo.Count | Should -Be 0
    }

    It 'Throws when the resource is not present in the schema' {
        {
            [Microsoft365DSC.Compare.ResourceComparer]::Compare(@{ Identity = 'a' }, @{ Identity = 'a' }, @{ Identity = 'a' }, [object[]]$Script:Schema, 'NotInSchema', $null, $null)
        } | Should -Throw -ExceptionType ([System.Management.Automation.MethodInvocationException])
    }

    It 'Throws ArgumentNullException for a null desiredValues' {
        {
            [Microsoft365DSC.Compare.ResourceComparer]::Compare($null, @{ }, @{ }, [object[]]$Script:Schema, 'TestResource', $null, $null)
        } | Should -Throw -ExceptionType ([System.Management.Automation.MethodInvocationException])
    }

    It 'Throws ArgumentNullException for null currentValues and null schema' {
        $desired = @{ Identity = 'a'; DisplayName = 'Contoso' }

        $nullCurrent = { [Microsoft365DSC.Compare.ResourceComparer]::Compare($desired, $null, $desired, [object[]]$Script:Schema, 'TestResource', $null, $null) }
        $nullSchema = { [Microsoft365DSC.Compare.ResourceComparer]::Compare($desired, @{ }, $desired, $null, 'TestResource', $null, $null) }

        (& { try { & $nullCurrent } catch { $_.Exception.InnerException.GetType().Name } }) | Should -Be 'ArgumentNullException'
        (& { try { & $nullSchema } catch { $_.Exception.InnerException.GetType().Name } }) | Should -Be 'ArgumentNullException'
    }
}

Describe 'ComplexObjectComparer.Compare' {
    It 'Detects drift between two hashtables and reports the property path' {
        $result = [Microsoft365DSC.Compare.ComplexObjectComparer]::Compare(@{ Name = 'n1'; Secret = 's1' }, @{ Name = 'n1'; Secret = 's2' }, 'Prop', $null)

        $result.Item2 | Should -BeFalse
        $result.Item1.Count | Should -Be 1
    }

    It 'Honours an explicit exclusion set' {
        $excluded = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
        $null = $excluded.Add('Secret')
        $result = [Microsoft365DSC.Compare.ComplexObjectComparer]::Compare(@{ Name = 'n1'; Secret = 's1' }, @{ Name = 'n1'; Secret = 's2' }, 'Prop', $excluded)

        $result.Item2 | Should -BeTrue
        $result.Item1.Count | Should -Be 0
    }

    It 'Does not carry the previous call''s exclusion set over to a $null argument' {
        $source = @{ Name = 'n1'; Secret = 's1' }
        $target = @{ Name = 'n1'; Secret = 's2' }

        $excluded = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
        $null = $excluded.Add('Secret')
        $null = [Microsoft365DSC.Compare.ComplexObjectComparer]::Compare($source, $target, 'Prop', $excluded)

        $subsequent = [Microsoft365DSC.Compare.ComplexObjectComparer]::Compare($source, $target, 'Prop', $null)
        $subsequent.Item2 | Should -BeFalse
        $subsequent.Item1.Count | Should -Be 1
    }
}

Describe 'ComplexObjectConverter' {
    It 'Returns a Hashtable unchanged' {
        $result = [Microsoft365DSC.Converter.ComplexObjectConverter]::ToHashtable(@{ A = 1 })
        $result['A'] | Should -Be 1
    }

    It 'Returns null for a null input' {
        [Microsoft365DSC.Converter.ComplexObjectConverter]::ToHashtable($null) | Should -BeNullOrEmpty
    }

    It 'Converts a generic dictionary, preserving array values' {
        $dictionary = [System.Collections.Generic.Dictionary[string, object]]::new()
        $dictionary['X'] = 5
        $dictionary['Y'] = @('a', 'b')
        $result = [Microsoft365DSC.Converter.ComplexObjectConverter]::ToHashtable($dictionary)

        ($result.Keys | Sort-Object) | Should -Be @('X', 'Y')
        $result['Y'].Count | Should -Be 2
    }

    It 'Converts each element of an array' {
        $result = [Microsoft365DSC.Converter.ComplexObjectConverter]::ToHashtableArray([object[]]@(@{ A = 1 }, @{ A = 2 }))

        $result.Length | Should -Be 2
        $result[1]['A'] | Should -Be 2
    }

    It 'Keeps the note properties of a PSCustomObject' {
        $result = [Microsoft365DSC.Converter.ComplexObjectConverter]::ToHashtable([PSCustomObject]@{ A = 1; B = 'two' })

        ($result.Keys | Sort-Object) | Should -Be @('A', 'B')
        $result['B'] | Should -Be 'two'
    }

    It 'Includes AdditionalProperties of a Graph type on the first conversion as well as later ones' {
        # The converter caches the reflected property set per type, so a regression here shows up
        # only on the first conversion of a given type. Both calls must agree.
        if (-not ('Microsoft.Graph.M365DSCCharacterization.Widget' -as [type]))
        {
            Add-Type -TypeDefinition @'
using System.Collections.Generic;
namespace Microsoft.Graph.M365DSCCharacterization
{
    public class Widget
    {
        public string Name { get; set; }
        private IDictionary<string, object> WidgetAdditionalProperties { get; set; }
        public Widget() { WidgetAdditionalProperties = new Dictionary<string, object> { { "extra", "value" } }; }
    }
}
'@
        }

        $widget = [Microsoft.Graph.M365DSCCharacterization.Widget]::new()
        $widget.Name = 'first'

        $first = [Microsoft365DSC.Converter.ComplexObjectConverter]::ToHashtable($widget)
        $second = [Microsoft365DSC.Converter.ComplexObjectConverter]::ToHashtable($widget)

        ($first.Keys | Sort-Object) | Should -Be @('Name', 'WidgetAdditionalProperties')
        ($second.Keys | Sort-Object) | Should -Be @('Name', 'WidgetAdditionalProperties')
    }
}

Describe 'ObjectNormalizer.Normalize' {
    It 'Returns null for a null input' {
        [Microsoft365DSC.Converter.ObjectNormalizer]::Normalize($null) | Should -BeNullOrEmpty
    }

    It 'Leaves a Uri as a leaf value' {
        [Microsoft365DSC.Converter.ObjectNormalizer]::Normalize([uri]'https://contoso.example') | Should -BeOfType ([System.Uri])
    }

    It 'Preserves array length and element order' {
        $result = [Microsoft365DSC.Converter.ObjectNormalizer]::Normalize([object[]]@(1, 'two', $null))

        $result.Count | Should -Be 3
        $result[1] | Should -Be 'two'
        $result[2] | Should -BeNullOrEmpty
    }

    It 'Converts a PSCustomObject and its nested PSCustomObject to hashtables' {
        $result = [Microsoft365DSC.Converter.ObjectNormalizer]::Normalize([PSCustomObject]@{ A = 1; Nested = [PSCustomObject]@{ B = 2 } })

        $result | Should -BeOfType ([System.Collections.Hashtable])
        ($result.Keys | Sort-Object) | Should -Be @('A', 'Nested')
        $result['Nested']['B'] | Should -Be 2
    }
}

Describe 'HashtableConverter.ToString' {
    It 'Renders one sorted key=value line per entry' {
        $lines = [Microsoft365DSC.Converter.HashtableConverter]::ConvertToString(@{ B = 2; A = 1 }) -split "`r?`n"
        $lines | Should -Be @('A=1', 'B=2')
    }

    It 'Obfuscates credential-bearing properties' {
        $lines = [Microsoft365DSC.Converter.HashtableConverter]::ConvertToString(@{ ApplicationSecret = 'hunter2'; Name = 'x' }) -split "`r?`n"
        $lines | Should -Be @('ApplicationSecret=***', 'Name=x')
    }

    It 'Renders a nested hashtable in braces' {
        [Microsoft365DSC.Converter.HashtableConverter]::ConvertToString(@{ Outer = @{ Inner = 1 } }) | Should -Be 'Outer={Inner=1}'
    }

    It 'Renders an array in parentheses' {
        [Microsoft365DSC.Converter.HashtableConverter]::ConvertToString(@{ Tags = @('a', 'b') }) | Should -Be 'Tags=(a,b)'
    }
}

Describe 'CimInstance rendering through HashtableConverter' {
    BeforeAll {
        $Script:CimInstance = New-CimInstance -ClassName MSFT_TestItem -ClientOnly `
            -Namespace root/microsoft/windows/desiredstateconfiguration `
            -Property @{ Key = 'k1'; Value = 'v1' }
    }

    It 'Separates the CIM instance properties with a comma' {
        # Add() stores the raw CimInstance; a PowerShell hashtable literal would store a PSObject
        # wrapper instead and take a different branch (see the test below).
        # CimInstanceProperties enumeration order is not stable, so both orderings are accepted.
        $container = [System.Collections.Hashtable]::new()
        $container.Add('Item', $Script:CimInstance)

        [Microsoft365DSC.Converter.HashtableConverter]::ConvertToString($container) | Should -Match '^Item=\{(Key=k1, Value=v1|Value=v1, Key=k1)\}$'
    }

    It 'Renders a PSObject-wrapped CIM instance as its class name' -Tag 'CurrentBehaviour' {
        # No branch in HashtableConverter unwraps PSObject, so a CimInstance stored through a
        # PowerShell hashtable literal falls through to entry.Value.ToString(). Phase 3b routes the
        # value through the shared unwrap helper, after which this matches the test above.
        [Microsoft365DSC.Converter.HashtableConverter]::ConvertToString(@{ Item = $Script:CimInstance }) | Should -Be 'Item=MSFT_TestItem'
    }
}

Describe 'Utilities' {
    It 'Escapes the three smart-quote characters with a backtick' {
        $input = [string][char]0x201C + 'q' + [string][char]0x201D
        $expected = '`' + [string][char]0x201C + 'q' + '`' + [string][char]0x201D

        [Microsoft365DSC.Utilities.Utilities]::UpdateSpecialCharacters($input) | Should -Be $expected
    }

    It 'Replaces every character that would need escaping in an instance name' {
        $value = 'Tag "A" (prod) $100' + [string][char]0x201C + 'x' + [string][char]0x201D

        [Microsoft365DSC.Utilities.Utilities]::RemoveSpecialCharacters($value) | Should -Be 'Tag__A___prod___100_x_'
    }

    It 'Leaves a value that needs no escaping untouched' {
        [Microsoft365DSC.Utilities.Utilities]::RemoveSpecialCharacters('Policy-A.1') | Should -Be 'Policy-A.1'
    }

    It 'Returns a new array and leaves the caller''s array untouched' {
        $original = [object[]]@([PSCustomObject]@{ V = 1 }, 'plain')
        $result = [Microsoft365DSC.Utilities.Utilities]::UnwrapArray($original)

        [object]::ReferenceEquals($original, $result) | Should -BeFalse
        $result.Length | Should -Be 2
        $result[1] | Should -Be 'plain'
    }

    It 'Stringifies every element, including non-strings' {
        [Microsoft365DSC.Utilities.Utilities]::UnwrapArrayToStrings([object[]]@('a', 1, $true)) | Should -Be @('a', '1', 'True')
    }

    It 'Filters hashtables by resource name and key value' {
        $entries = [object[]]@(
            @{ ResourceName = 'R1'; Id = '1' }
            @{ ResourceName = 'R1'; Id = '2' }
            @{ ResourceName = 'R2'; Id = '1' }
        )
        $result = [Microsoft365DSC.Utilities.Utilities]::FilterHashtablesByResourceAndKey($entries, 'R1', 'Id', '2')

        $result.Count | Should -Be 1
        $result[0]['Id'] | Should -Be '2'
    }
}

Describe 'CacheManager' {
    AfterAll {
        # The schema cache is process-wide, so the fixture loaded below must not outlive this file.
        [Microsoft365DSC.Cache.CacheManager]::ClearSchema()
    }

    It 'Reports the schema as loaded and resolves a class by name' {
        [Microsoft365DSC.Cache.CacheManager]::LoadSchema([System.Collections.Generic.List[object]]@($Script:Schema))

        [Microsoft365DSC.Cache.CacheManager]::IsSchemaLoaded | Should -BeTrue

        $found = [Microsoft365DSC.Cache.CacheManager]::FilterLoadedCimClassesByName('MSFT_TestItem')
        $found | Should -BeOfType ([System.Collections.Hashtable])
        $found['ClassName'] | Should -Be 'MSFT_TestItem'
    }

    It 'Returns null for a class that is not in the schema' {
        [Microsoft365DSC.Cache.CacheManager]::LoadSchema([System.Collections.Generic.List[object]]@($Script:Schema))

        [Microsoft365DSC.Cache.CacheManager]::FilterLoadedCimClassesByName('MSFT_Missing') | Should -BeNullOrEmpty
    }
}

Describe 'SettingsCatalogHelper.GetSettingName' {
    It 'Returns the setting name unchanged when it is unique' {
        $definitions = [System.Collections.Generic.List[object]]::new()
        $definitions.Add(@{ Id = 'device_vendor_msft_policy_config_admx_setting'; Name = 'MySetting'; OffsetUri = '/admx/parent/MySetting' })
        $definitions.Add(@{ Id = 'device_vendor_msft_policy_config_other_setting'; Name = 'OtherSetting'; OffsetUri = '/admx/other' })

        [Microsoft365DSC.Intune.SettingsCatalogHelper]::GetSettingName($definitions[0], $definitions) | Should -Be 'MySetting'
    }

    It 'Disambiguates duplicate names using the offset URI' {
        $definitions = [System.Collections.Generic.List[object]]::new()
        $definitions.Add(@{ Id = 'vendor_a_dup'; Name = 'Dup'; OffsetUri = '/a/first' })
        $definitions.Add(@{ Id = 'vendor_b_dup'; Name = 'Dup'; OffsetUri = '/b/second' })

        [Microsoft365DSC.Intune.SettingsCatalogHelper]::GetSettingName($definitions[0], $definitions) | Should -Be 'first_Dup'
        [Microsoft365DSC.Intune.SettingsCatalogHelper]::GetSettingName($definitions[1], $definitions) | Should -Be 'second_Dup'
    }

    It 'Strips braces and replaces spaces and slashes with underscores' {
        $definition = @{ Id = 'x'; Name = 'A {B} C/D'; OffsetUri = '/x' }

        [Microsoft365DSC.Intune.SettingsCatalogHelper]::GetSettingName($definition, [System.Collections.Generic.List[object]]@()) | Should -Be 'A_B_C_D'
    }
}

Describe 'ConnectionHelper.GetComponentsWithMostSecureAuthenticationType' {
    It 'Resolves every shipped resource from the schema to an authentication method' {
        $schemaPath = "$PSScriptRoot/../../../Modules/Microsoft365DSC/SchemaDefinition.json"
        if (-not (Test-Path -Path $schemaPath))
        {
            Set-ItResult -Skipped -Because 'the schema has not been built'
            return
        }

        Import-Module "$PSScriptRoot/../../../Modules/Microsoft365DSC/Modules/M365DSCConnection.psm1" -Force -Global
        $manifest = Import-PowerShellDataFile "$PSScriptRoot/../../../Modules/Microsoft365DSC/Microsoft365DSC.psd1"
        $resources = $manifest.DscResourcesToExport
        try
        {
            [Microsoft365DSC.Cache.CacheManager]::LoadSchema([System.Collections.Generic.List[object]] @([System.IO.File]::ReadAllText($schemaPath) | ConvertFrom-Json))
            $map = Get-M365DSCResourcePropertyNameMap -Resources $resources
            $components = [Microsoft365DSC.Connection.ConnectionHelper]::GetComponentsWithMostSecureAuthenticationType([System.Collections.IDictionary] $map, $Script:AllAuthMethods, $resources)
        }
        finally
        {
            [Microsoft365DSC.Cache.CacheManager]::ClearSchema()
            Remove-Module -Name M365DSCConnection -Force -ErrorAction SilentlyContinue
        }

        $components.Count | Should -Be $resources.Count
    }
}
