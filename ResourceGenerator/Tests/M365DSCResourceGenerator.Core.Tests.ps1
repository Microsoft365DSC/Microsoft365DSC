<#
    Offline unit tests for the resource generator core: template engine, property model,
    fake values and the PowerShell literal renderer. No network or Graph modules required.
#>

# Import at discovery time: InModuleScope needs the module loaded before the Describe blocks run.
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath '..\M365DSCResourceGenerator.psd1') -Force

InModuleScope -ModuleName 'M365DSCResourceGenerator' {

    Describe 'Expand-M365DSCTemplate' {
        It 'replaces plain tokens' {
            $result = Expand-M365DSCTemplate -Content 'Hello <Name>!' -Tokens @{ Name = 'World' }
            $result | Should -Be 'Hello World!'
        }

        It 'throws on an unreplaced token' {
            { Expand-M365DSCTemplate -Content 'Hello <Name>!' -Tokens @{} } |
                Should -Throw -ExpectedMessage "*token '<Name>' was not replaced*"
        }

        It 'keeps an IF section when the token is truthy' {
            $template = "a`n<#IF HasThing#>`nthing`n<#ENDIF HasThing#>`nb"
            $result = Expand-M365DSCTemplate -Content $template -Tokens @{ HasThing = $true }
            $result | Should -Be "a`nthing`nb"
        }

        It 'drops an IF section when the token is falsy or missing' {
            $template = "a`n<#IF HasThing#>`nthing`n<#ENDIF HasThing#>`nb"
            $result = Expand-M365DSCTemplate -Content $template -Tokens @{ HasThing = $false }
            $result | Should -Be "a`nb"
        }

        It 'renders the ELSE branch when the token is falsy' {
            $template = "<#IF HasThing#>`nyes`n<#ELSE#>`nno`n<#ENDIF HasThing#>`n"
            $result = Expand-M365DSCTemplate -Content $template -Tokens @{ HasThing = '' }
            $result | Should -Be "no`n"
        }

        It 'resolves nested IF sections' {
            $template = "<#IF Outer#>`nouter`n<#IF Inner#>`ninner`n<#ENDIF Inner#>`n<#ENDIF Outer#>`n"
            $result = Expand-M365DSCTemplate -Content $template -Tokens @{ Outer = $true; Inner = $true }
            $result | Should -Be "outer`ninner`n"

            $result = Expand-M365DSCTemplate -Content $template -Tokens @{ Outer = $true; Inner = $false }
            $result | Should -Be "outer`n"

            $result = Expand-M365DSCTemplate -Content $template -Tokens @{ Outer = $false; Inner = $true }
            $result | Should -Be ''
        }

        It 'treats a non-empty collection as truthy and an empty one as falsy' {
            $template = "<#IF Items#>`nhas items`n<#ENDIF Items#>`n"
            (Expand-M365DSCTemplate -Content $template -Tokens @{ Items = @(1) }) | Should -Be "has items`n"
            (Expand-M365DSCTemplate -Content $template -Tokens @{ Items = @() }) | Should -Be ''
        }

        It 'throws on a dangling conditional marker' {
            { Expand-M365DSCTemplate -Content "<#IF Foo#>`nbody" -Tokens @{ Foo = $true } } |
                Should -Throw -ExpectedMessage '*unresolved conditional marker*'
        }

        It 'writes the destination file when requested' {
            $destination = Join-Path -Path $TestDrive -ChildPath 'sub\out.txt'
            Expand-M365DSCTemplate -Content 'v=<V>' -Tokens @{ V = '1' } -DestinationPath $destination
            Get-Content -Path $destination -Raw | Should -Be 'v=1'
        }
    }

    Describe 'Resolve-M365DSCTypeInfo' {
        It 'maps <_.Type> to CLR <_.Clr>' -ForEach @(
            @{ Type = 'Edm.String'; Clr = 'System.String' }
            @{ Type = 'Edm.Boolean'; Clr = 'System.Boolean' }
            @{ Type = 'System.Int32'; Clr = 'System.Int32' }
            @{ Type = 'Edm.DateTimeOffset'; Clr = 'System.String' }
            @{ Type = 'Edm.Guid'; Clr = 'System.String' }
            @{ Type = 'System.Management.Automation.SwitchParameter'; Clr = 'System.Boolean' }
        ) {
            $result = Resolve-M365DSCTypeInfo -Type $Type
            $result.Clr | Should -Be $Clr
            $result.IsFallback | Should -BeFalse
        }

        It 'falls back to String for unknown types' {
            $result = Resolve-M365DSCTypeInfo -Type 'Some.Unknown.Type'
            $result.Clr | Should -Be 'System.String'
            $result.IsFallback | Should -BeTrue
        }

        It 'maps PSCredential to the PSCredential CLR type' {
            $result = Resolve-M365DSCTypeInfo -Type 'System.Management.Automation.PSCredential'
            $result.Clr | Should -Be 'System.Management.Automation.PSCredential'
            $result.FakeKind | Should -Be 'Credential'
        }
    }

    Describe 'New-M365DSCPropertyModel' {
        It 'wraps value types in System.Nullable' {
            (New-M365DSCPropertyModel -Name 'IsEnabled' -Type 'Edm.Boolean').ClrType |
                Should -Be 'System.Nullable[System.Boolean]'
        }

        It 'does not wrap arrays or strings in System.Nullable' {
            (New-M365DSCPropertyModel -Name 'Names' -Type 'Edm.String' -IsArray $true).ClrType |
                Should -Be 'System.String[]'
            (New-M365DSCPropertyModel -Name 'Name' -Type 'Edm.String').ClrType |
                Should -Be 'System.String'
        }

        It 'does not wrap a key property in System.Nullable' {
            (New-M365DSCPropertyModel -Name 'Priority' -Type 'Edm.Int32' -IsKey $true).ClrType |
                Should -Be 'System.Int32'
        }

        It 'derives the camelCase Graph name' {
            (New-M365DSCPropertyModel -Name 'DisplayName').GraphName | Should -Be 'displayName'
        }

        It 'upper-cases the first letter of the DSC name' {
            (New-M365DSCPropertyModel -Name 'displayName').Name | Should -Be 'DisplayName'
        }

        It 'treats enum values as a ValidateSet string' {
            $model = New-M365DSCPropertyModel -Name 'State' -EnumValues @('enabled', 'disabled')
            $model.IsEnum | Should -BeTrue
            $model.ClrType | Should -Be 'System.String'
            $model.FakeValue | Should -Be 'enabled'
            $model.DriftValue | Should -Be 'disabled'
        }

        It 'yields no drift value for a single-value enum' {
            (New-M365DSCPropertyModel -Name 'State' -EnumValues @('only')).DriftValue | Should -BeNullOrEmpty
        }

        It 'builds complex models with distinct fake and drift values' {
            $members = @(
                New-M365DSCPropertyModel -Name 'Id' -Type 'Edm.String'
                New-M365DSCPropertyModel -Name 'Count' -Type 'Edm.Int32'
            )
            $model = New-M365DSCPropertyModel -Name 'Settings' -CimClassName 'MSFT_TestSetting' -Members $members

            $model.IsComplex | Should -BeTrue
            $model.CimClassName | Should -Be 'MSFT_TestSetting'
            $model.FakeValue | Should -BeOfType [System.Collections.Hashtable]
            # Exactly one leaf drifts.
            $driftedLeaves = @($model.DriftValue.Keys | Where-Object { $model.DriftValue[$_] -ne $model.FakeValue[$_] })
            $driftedLeaves.Count | Should -Be 1
        }

        It 'gives fake and drift values that always differ for scalar kinds' {
            foreach ($type in @('Edm.String', 'Edm.Boolean', 'Edm.Int32', 'Edm.Double', 'Edm.DateTimeOffset', 'Edm.TimeOfDay', 'Edm.Guid'))
            {
                $model = New-M365DSCPropertyModel -Name 'P' -Type $type
                $model.DriftValue | Should -Not -Be $model.FakeValue -Because "type $type must produce a real drift"
            }
        }

        It 'returns no fake values for auth properties' {
            $model = New-M365DSCPropertyModel -Name 'ApplicationId' -IsAuth $true
            $model.FakeValue | Should -BeNullOrEmpty
        }
    }

    Describe 'Get-M365DSCAuthPropertySet' {
        It 'returns the full parameter set for MicrosoftGraph' {
            $models = Get-M365DSCAuthPropertySet -Workload 'MicrosoftGraph'
            $models.Name | Should -Contain 'ApplicationSecret'
            $models.Name | Should -Contain 'AccessTokens'
            ($models | Where-Object { $_.Name -eq 'Credential' }).Description |
                Should -Be 'Credentials for the Microsoft Graph delegated permissions.'
        }

        It 'omits ApplicationSecret for ExchangeOnline' {
            (Get-M365DSCAuthPropertySet -Workload 'ExchangeOnline').Name | Should -Not -Contain 'ApplicationSecret'
        }

        It 'marks every model as auth' {
            (Get-M365DSCAuthPropertySet -Workload 'MicrosoftTeams') |
                ForEach-Object { $_.IsAuth | Should -BeTrue }
        }
    }

    Describe 'ConvertTo-M365DSCPSLiteral' {
        It 'renders scalars' {
            ConvertTo-M365DSCPSLiteral -Value $null | Should -Be '$null'
            ConvertTo-M365DSCPSLiteral -Value $true | Should -Be '$true'
            ConvertTo-M365DSCPSLiteral -Value 25 | Should -Be '25'
            ConvertTo-M365DSCPSLiteral -Value "it's" | Should -Be "'it''s'"
        }

        It 'renders a script block verbatim' {
            ConvertTo-M365DSCPSLiteral -Value { $Credential } | Should -Be '$Credential'
        }

        It 'renders simple arrays inline' {
            ConvertTo-M365DSCPSLiteral -Value @('a', 'b') | Should -Be "@('a', 'b')"
        }

        It 'renders hashtables with aligned keys' {
            $rendered = ConvertTo-M365DSCPSLiteral -Value ([ordered]@{ Id = 'x'; DisplayName = 'y' })
            $rendered | Should -Be ("@{`r`n    Id          = 'x'`r`n    DisplayName = 'y'`r`n}" -replace "`r`n", [System.Environment]::NewLine)
        }

        It 'renders nested structures with growing indentation' {
            $value = [ordered]@{
                Outer = [ordered]@{ Inner = 'v' }
                List  = @([ordered]@{ A = 1 })
            }
            $rendered = ConvertTo-M365DSCPSLiteral -Value $value
            $lines = $rendered -split [System.Environment]::NewLine
            $lines[0] | Should -Be '@{'
            $lines[1] | Should -Be '    Outer = @{'
            $lines[2] | Should -Be '        Inner = ''v'''
            $lines[3] | Should -Be '    }'
            $lines[-1] | Should -Be '}'
        }
    }

    Describe 'Split-M365DSCIdentifierToken' {
        It 'splits camelCase, PascalCase and digits' {
            Split-M365DSCIdentifierToken -Value 'IntuneDeviceCompliancePolicyWindows10' |
                Should -Be @('intune', 'device', 'compliance', 'policy', 'windows', '10')
            Split-M365DSCIdentifierToken -Value 'windows10CompliancePolicy' |
                Should -Be @('windows', '10', 'compliance', 'policy')
        }

        It 'keeps acronym runs together' {
            Split-M365DSCIdentifierToken -Value 'AADGroupPolicy' |
                Should -Be @('aad', 'group', 'policy')
        }
    }

    Describe 'Get-M365DSCSettingsCatalogTemplateBucket' {
        BeforeAll {
            function New-BucketTemplate
            {
                param ($RootId, $DefinitionId, $BaseUri)

                $definitions = @(
                    @{ id = $RootId; baseUri = $BaseUri }
                    @{ id = $DefinitionId; baseUri = $BaseUri }
                )

                return [PSCustomObject]@{
                    SettingInstanceTemplate = [PSCustomObject]@{ SettingDefinitionId = $RootId }
                    SettingDefinitions      = $definitions
                }
            }
        }

        It 'returns no bucket for no template' {
            @(Get-M365DSCSettingsCatalogTemplateBucket -SettingTemplates @()) | Should -HaveCount 0
        }

        It 'returns one bucket carrying every definition when nothing is user scoped' {
            $buckets = @(Get-M365DSCSettingsCatalogTemplateBucket -SettingTemplates @(
                    (New-BucketTemplate -RootId 'vendor_domainprofile' -DefinitionId 'vendor_domainprofile_merge' -BaseUri './Vendor/MSFT')
                    (New-BucketTemplate -RootId 'vendor_privateprofile' -DefinitionId 'vendor_privateprofile_merge' -BaseUri './Vendor/MSFT')
                ))

            $buckets | Should -HaveCount 1
            $buckets[0].Name | Should -BeExactly 'All'
            @($buckets[0].Definitions) | Should -HaveCount 4
        }

        It 'splits the device and the user scope into their own buckets' {
            $buckets = @(Get-M365DSCSettingsCatalogTemplateBucket -SettingTemplates @(
                    (New-BucketTemplate -RootId 'device_passportforwork_enablepinrecovery' -DefinitionId 'device_passportforwork_child' -BaseUri './Device/Vendor/MSFT')
                    (New-BucketTemplate -RootId 'user_passportforwork_enablepinrecovery' -DefinitionId 'user_passportforwork_child' -BaseUri './User/Vendor/MSFT')
                ))

            $buckets | Should -HaveCount 2
            $buckets[0].Name | Should -BeExactly 'DeviceSettings'
            $buckets[1].Name | Should -BeExactly 'UserSettings'
            @($buckets[0].Definitions) | Should -HaveCount 2
            @($buckets[1].Definitions) | Should -HaveCount 2
        }

        It 'classifies a user scoped template by its base uri when the id carries no prefix' {
            $buckets = @(Get-M365DSCSettingsCatalogTemplateBucket -SettingTemplates @(
                    (New-BucketTemplate -RootId 'device_thing' -DefinitionId 'device_thing_child' -BaseUri './Device/Vendor/MSFT')
                    (New-BucketTemplate -RootId 'scoped_thing' -DefinitionId 'scoped_thing_child' -BaseUri './User/Vendor/MSFT')
                ))

            $buckets | Should -HaveCount 2
            @($buckets[1].Templates)[0].SettingInstanceTemplate.SettingDefinitionId | Should -BeExactly 'scoped_thing'
        }
    }
}
