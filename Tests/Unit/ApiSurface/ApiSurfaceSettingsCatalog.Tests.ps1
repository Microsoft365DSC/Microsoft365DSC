Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath '..\..\..\Utilities\ApiSurface\M365DSCApiSurface.psd1') -Force

Describe 'Get-M365DSCIntuneTemplateBinding' {
    BeforeAll {
        . (Join-Path -Path $PSScriptRoot -ChildPath '..\..\..\Utilities\Get-M365DSCIntuneTemplateBinding.ps1')

        $script:fixtureRoot = Join-Path -Path $PSScriptRoot -ChildPath 'Fixtures\SettingsCatalog'
        $script:binding = @(Get-M365DSCIntuneTemplateBinding -ResourcePath $script:fixtureRoot)
    }

    It 'Reads both literal spellings and skips a resource that pins none' {
        @($script:binding.Resource) | Should -Be @('TestCatalogAlt', 'TestCatalogPolicy')
    }

    It 'Reads the templateReferenceId spelling' {
        @($script:binding | Where-Object -FilterScript { $_.Resource -eq 'TestCatalogPolicy' }).TemplateId |
            Should -Be '11111111-1111-1111-1111-111111111111_2'
    }

    It 'Reads the policyTemplateId spelling' {
        @($script:binding | Where-Object -FilterScript { $_.Resource -eq 'TestCatalogAlt' }).TemplateId |
            Should -Be '22222222-2222-2222-2222-222222222222_1'
    }

    It 'Does not read an id that only appears inside a string' {
        @($script:binding.Resource) | Should -Not -Contain 'TestCatalogNone'
    }
}

InModuleScope -ModuleName 'M365DSCApiSurface' {

    BeforeAll {
        function New-CatalogSetting
        {
            param
            (
                [System.String] $Name = 'CRLcheck',
                [System.String] $Type = '#microsoft.graph.deviceManagementConfigurationChoiceSettingDefinition',
                [System.String[]] $Option = @('0', '1'),
                [System.String] $Parent,
                [System.Boolean] $Exposed = $true
            )

            return [ordered]@{
                name    = $Name
                type    = $Type
                options = $Option
                parent  = $Parent
                exposed = $Exposed
            }
        }

        function New-CatalogSnapshot
        {
            param
            (
                [System.Collections.IDictionary] $Template = [ordered]@{},
                [System.Collections.IDictionary] $Pinned = [ordered]@{},
                [System.String[]] $SkippedWorkload = @()
            )

            return [ordered]@{
                completeness    = [ordered]@{ skippedWorkloads = $SkippedWorkload }
                settingsCatalog = [ordered]@{ templates = $Template; pinned = $Pinned }
            }
        }

        function New-PinnedTemplate
        {
            param
            (
                [System.String[]] $Resource = @('TestCatalogPolicy'),
                [System.Collections.IDictionary] $Setting = [ordered]@{}
            )

            return [ordered]@{ resources = $Resource; settings = $Setting }
        }

        function New-ThinTemplate
        {
            param
            (
                [System.String] $DisplayName = 'Test template',
                [System.String] $Version = 'Version 1',
                [System.String] $LifecycleState = 'active'
            )

            return [ordered]@{
                displayName    = $DisplayName
                displayVersion = $Version
                platforms      = 'windows10'
                technologies   = 'mdm'
                lifecycleState = $LifecycleState
            }
        }

        function New-DeclaredMap
        {
            param
            (
                [System.String] $Resource = 'TestCatalogPolicy',
                [System.String[]] $Name = @()
            )

            return @{
                $Resource = [System.Collections.Generic.HashSet[System.String]]::new(
                    [System.String[]] @($Name), [System.StringComparer]::OrdinalIgnoreCase)
            }
        }

        $script:templateId = '11111111-1111-1111-1111-111111111111_2'
        $script:bindingRow = @([PSCustomObject]@{ Resource = 'TestCatalogPolicy'; TemplateId = $script:templateId })
    }

    Describe 'Split-SettingsCatalogTemplateId' {
        It 'Splits a template id into its base and its revision' {
            $parts = Split-SettingsCatalogTemplateId -TemplateId 'abc_4'

            $parts.BaseId | Should -Be 'abc'
            $parts.Revision | Should -Be 4
        }

        It 'Returns an empty base for an id without a version' {
            (Split-SettingsCatalogTemplateId -TemplateId 'abc').BaseId | Should -Be ''
        }
    }

    Describe 'Get-SettingsCatalogSettingParent' {
        It 'Reads the parent off dependentOn' {
            Get-SettingsCatalogSettingParent -Definition ([ordered]@{
                    dependentOn = @([ordered]@{ parentSettingId = 'root_setting' })
                }) | Should -Be 'root_setting'
        }

        It 'Reads the parent off an option dependentOn' {
            Get-SettingsCatalogSettingParent -Definition ([ordered]@{
                    options = @([ordered]@{ dependentOn = @([ordered]@{ parentSettingId = 'option_parent' }) })
                }) | Should -Be 'option_parent'
        }

        It 'Returns null for a root definition' {
            Get-SettingsCatalogSettingParent -Definition ([ordered]@{ id = 'root' }) | Should -BeNullOrEmpty
        }
    }

    Describe 'Get-SettingsCatalogTreeName' {
        It 'Flattens the names of a nested setting tree' {
            $tree = @(
                [ordered]@{ Name = 'Parent'; ChildSettings = @(
                        [ordered]@{ Name = 'Child'; ChildSettings = @([ordered]@{ Name = 'GrandChild'; ChildSettings = @() }) }
                    )
                }
            )

            @(Get-SettingsCatalogTreeName -Setting $tree) | Should -Be @('Parent', 'Child', 'GrandChild')
        }

        It 'Returns nothing for an empty tree' {
            @(Get-SettingsCatalogTreeName -Setting @()) | Should -HaveCount 0
        }
    }

    Describe 'ConvertTo-SettingsCatalogSetting' {
        BeforeAll {
            $script:settingTemplate = @(
                [ordered]@{
                    settingDefinitions = @(
                        [ordered]@{
                            id            = 'vendor_msft_firewall_crlcheck'
                            '@odata.type' = '#microsoft.graph.deviceManagementConfigurationChoiceSettingDefinition'
                            options       = @(
                                [ordered]@{ optionValue = [ordered]@{ value = '1' } }
                                [ordered]@{ optionValue = [ordered]@{ value = '0' } }
                            )
                        }
                        [ordered]@{
                            id            = 'vendor_msft_firewall_hidden'
                            '@odata.type' = '#microsoft.graph.deviceManagementConfigurationSimpleSettingDefinition'
                            dependentOn   = @([ordered]@{ parentSettingId = 'vendor_msft_firewall_crlcheck' })
                        }
                    )
                }
            )

            $script:projection = [ordered]@{
                Name    = @{
                    'vendor_msft_firewall_crlcheck' = 'CRLcheck'
                    'vendor_msft_firewall_hidden'   = 'Hidden'
                }
                Exposed = [System.Collections.Generic.HashSet[System.String]]::new(
                    [System.String[]] @('CRLcheck'), [System.StringComparer]::OrdinalIgnoreCase)
            }

            $script:recorded = ConvertTo-SettingsCatalogSetting -SettingTemplate $script:settingTemplate -Projection $script:projection
        }

        It 'Keys the settings by their definition id' {
            @($script:recorded.Keys) | Should -Be @('vendor_msft_firewall_crlcheck', 'vendor_msft_firewall_hidden')
        }

        It 'Records the projected DSC property name' {
            $script:recorded['vendor_msft_firewall_crlcheck'].name | Should -Be 'CRLcheck'
        }

        It 'Sorts the options ordinally' {
            @($script:recorded['vendor_msft_firewall_crlcheck'].options) | Should -Be @('0', '1')
        }

        It 'Records a definition the generator does not emit with exposed false' {
            $script:recorded['vendor_msft_firewall_hidden'].exposed | Should -BeFalse
            $script:recorded['vendor_msft_firewall_crlcheck'].exposed | Should -BeTrue
        }

        It 'Records the parent of a dependent definition' {
            $script:recorded['vendor_msft_firewall_hidden'].parent | Should -Be 'vendor_msft_firewall_crlcheck'
        }
    }

    Describe 'Get-SettingsCatalogProjection' {
        BeforeAll {
            function New-ProjectionTemplate
            {
                param ($RootId, $ChildId, $ChildName, $BaseUri)

                $definitions = @(
                    [ordered]@{ id = $RootId; name = 'Root'; baseUri = $BaseUri }
                    [ordered]@{ id = $ChildId; name = $ChildName; baseUri = $BaseUri }
                )

                return [PSCustomObject]@{
                    SettingInstanceTemplate = [PSCustomObject]@{ SettingDefinitionId = $RootId }
                    SettingDefinitions      = $definitions
                }
            }

            $script:seenCount = [System.Collections.Generic.List[System.Int32]]::new()

            function Get-SettingsCatalogSettingName
            {
                param
                (
                    [System.Object] $SettingDefinition,

                    [System.Object] $AllSettingDefinitions
                )

                $script:seenCount.Add(@($AllSettingDefinitions).Count)

                return [System.String] $SettingDefinition.name
            }
        }

        BeforeEach {
            $script:seenCount.Clear()
        }

        It 'Disambiguates against every definition of the bucket, not one setting template' {
            $generator = New-Module -Name 'ProjectionStubGenerator' -ScriptBlock {
                function Get-M365DSCSettingsCatalogTemplateBucket
                {
                    param ($SettingTemplates)

                    return @([PSCustomObject]@{
                            Name        = 'All'
                            Templates   = $SettingTemplates
                            Definitions = $SettingTemplates.SettingDefinitions
                        })
                }

                function Get-StringFirstCharacterToUpper
                {
                    param ($Value)

                    return $Value
                }

                function New-SettingsCatalogSettingDefinitionSettingsFromTemplate
                {
                    param ($SettingTemplate, [switch] $FromRoot, $AllSettingDefinitions)

                    $null = $SettingTemplate, $FromRoot, $AllSettingDefinitions
                    return @()
                }

                Export-ModuleMember -Function 'Get-M365DSCSettingsCatalogTemplateBucket',
                    'Get-StringFirstCharacterToUpper', 'New-SettingsCatalogSettingDefinitionSettingsFromTemplate'
            }

            $null = Get-SettingsCatalogProjection -Generator $generator -SettingTemplate @(
                (New-ProjectionTemplate -RootId 'vendor_domainprofile' -ChildId 'vendor_domainprofile_merge' -ChildName 'AllowLocalIpsecPolicyMerge' -BaseUri './Vendor/MSFT')
                (New-ProjectionTemplate -RootId 'vendor_privateprofile' -ChildId 'vendor_privateprofile_merge' -ChildName 'AllowLocalIpsecPolicyMerge' -BaseUri './Vendor/MSFT')
            )

            @($script:seenCount) | Should -HaveCount 4
            @($script:seenCount | Sort-Object -Unique) | Should -Be @(4)
        }

        It 'Keeps the two scopes apart when the template splits device and user settings' {
            $generator = New-Module -Name 'ProjectionSplitStubGenerator' -ScriptBlock {
                function Get-M365DSCSettingsCatalogTemplateBucket
                {
                    param ($SettingTemplates)

                    return @(
                        [PSCustomObject]@{ Name = 'DeviceSettings'; Templates = @($SettingTemplates[0]); Definitions = $SettingTemplates[0].SettingDefinitions }
                        [PSCustomObject]@{ Name = 'UserSettings'; Templates = @($SettingTemplates[1]); Definitions = $SettingTemplates[1].SettingDefinitions }
                    )
                }

                function Get-StringFirstCharacterToUpper
                {
                    param ($Value)

                    return $Value
                }

                function New-SettingsCatalogSettingDefinitionSettingsFromTemplate
                {
                    param ($SettingTemplate, [switch] $FromRoot, $AllSettingDefinitions)

                    $null = $SettingTemplate, $FromRoot, $AllSettingDefinitions
                    return @()
                }

                Export-ModuleMember -Function 'Get-M365DSCSettingsCatalogTemplateBucket',
                    'Get-StringFirstCharacterToUpper', 'New-SettingsCatalogSettingDefinitionSettingsFromTemplate'
            }

            $null = Get-SettingsCatalogProjection -Generator $generator -SettingTemplate @(
                (New-ProjectionTemplate -RootId 'device_passportforwork' -ChildId 'device_passportforwork_pin' -ChildName 'EnablePinRecovery' -BaseUri './Device/Vendor/MSFT')
                (New-ProjectionTemplate -RootId 'user_passportforwork' -ChildId 'user_passportforwork_pin' -ChildName 'EnablePinRecovery' -BaseUri './User/Vendor/MSFT')
            )

            @($script:seenCount) | Should -HaveCount 4
            @($script:seenCount | Sort-Object -Unique) | Should -Be @(2)
        }
    }

    Describe 'Compare-SettingsCatalog' {
        It 'Reports a setting the template gained that the resource does not declare' {
            $baseline = New-CatalogSnapshot -Pinned ([ordered]@{ $script:templateId = New-PinnedTemplate -Setting ([ordered]@{
                            'setting_a' = New-CatalogSetting -Name 'CRLcheck'
                        }) })
            $current = New-CatalogSnapshot -Pinned ([ordered]@{ $script:templateId = New-PinnedTemplate -Setting ([ordered]@{
                            'setting_a' = New-CatalogSetting -Name 'CRLcheck'
                            'setting_b' = New-CatalogSetting -Name 'NewKnob'
                        }) })

            $findings = @(Compare-SettingsCatalog -Baseline $baseline -Current $current `
                    -Binding $script:bindingRow -DeclaredProperty (New-DeclaredMap -Name @('CRLcheck')))

            $findings | Should -HaveCount 1
            $findings[0].code | Should -Be 'CAT-SETTING-ADDED'
            $findings[0].id | Should -Be 'CAT-SETTING-ADDED:TestCatalogPolicy:setting_b'
            $findings[0].to.name | Should -Be 'NewKnob'
            $findings[0].severity | Should -Be 'warning'
            $findings[0].autoFixable | Should -BeFalse
        }

        It 'Reports nothing when the resource already declares the new setting' {
            $baseline = New-CatalogSnapshot -Pinned ([ordered]@{ $script:templateId = New-PinnedTemplate -Setting ([ordered]@{}) })
            $current = New-CatalogSnapshot -Pinned ([ordered]@{ $script:templateId = New-PinnedTemplate -Setting ([ordered]@{
                            'setting_b' = New-CatalogSetting -Name 'NewKnob'
                        }) })

            @(Compare-SettingsCatalog -Baseline $baseline -Current $current `
                    -Binding $script:bindingRow -DeclaredProperty (New-DeclaredMap -Name @('NewKnob'))) |
                Should -HaveCount 0
        }

        It 'Reports nothing for a definition the generator does not emit' {
            $baseline = New-CatalogSnapshot -Pinned ([ordered]@{ $script:templateId = New-PinnedTemplate -Setting ([ordered]@{}) })
            $current = New-CatalogSnapshot -Pinned ([ordered]@{ $script:templateId = New-PinnedTemplate -Setting ([ordered]@{
                            'setting_b' = New-CatalogSetting -Name 'NewKnob' -Exposed $false
                        }) })

            @(Compare-SettingsCatalog -Baseline $baseline -Current $current `
                    -Binding $script:bindingRow -DeclaredProperty (New-DeclaredMap)) |
                Should -HaveCount 0
        }

        It 'Reports a setting the template lost that the resource still declares' {
            $baseline = New-CatalogSnapshot -Pinned ([ordered]@{ $script:templateId = New-PinnedTemplate -Setting ([ordered]@{
                            'setting_a' = New-CatalogSetting -Name 'CRLcheck'
                        }) })
            $current = New-CatalogSnapshot -Pinned ([ordered]@{ $script:templateId = New-PinnedTemplate -Setting ([ordered]@{}) })

            $findings = @(Compare-SettingsCatalog -Baseline $baseline -Current $current `
                    -Binding $script:bindingRow -DeclaredProperty (New-DeclaredMap -Name @('CRLcheck')))

            $findings | Should -HaveCount 1
            $findings[0].code | Should -Be 'CAT-SETTING-REMOVED'
            $findings[0].severity | Should -Be 'breaking'
            $findings[0].from.name | Should -Be 'CRLcheck'
        }

        It 'Reports a choice setting that gained an option, not a new setting' {
            $baseline = New-CatalogSnapshot -Pinned ([ordered]@{ $script:templateId = New-PinnedTemplate -Setting ([ordered]@{
                            'setting_a' = New-CatalogSetting -Option @('0', '1')
                        }) })
            $current = New-CatalogSnapshot -Pinned ([ordered]@{ $script:templateId = New-PinnedTemplate -Setting ([ordered]@{
                            'setting_a' = New-CatalogSetting -Option @('0', '1', '2')
                        }) })

            $findings = @(Compare-SettingsCatalog -Baseline $baseline -Current $current `
                    -Binding $script:bindingRow -DeclaredProperty (New-DeclaredMap -Name @('CRLcheck')))

            $findings | Should -HaveCount 1
            $findings[0].code | Should -Be 'CAT-OPTION-ADDED'
            @($findings[0].to.added) | Should -Be @('2')
        }

        It 'Reports the active template when the pinned one is superseded' {
            $templates = [ordered]@{
                $script:templateId                       = New-ThinTemplate -Version 'Version 24H2' -LifecycleState 'superseded'
                '11111111-1111-1111-1111-111111111111_3' = New-ThinTemplate -Version 'Version 25H2'
            }
            $snapshot = New-CatalogSnapshot -Template $templates -Pinned ([ordered]@{ $script:templateId = New-PinnedTemplate })

            $findings = @(Compare-SettingsCatalog -Baseline $snapshot -Current $snapshot `
                    -Binding $script:bindingRow -DeclaredProperty (New-DeclaredMap))

            $findings | Should -HaveCount 1
            $findings[0].code | Should -Be 'CAT-TEMPLATE-VERSION'
            $findings[0].to.templateId | Should -Be '11111111-1111-1111-1111-111111111111_3'
            $findings[0].to.displayVersion | Should -Be 'Version 25H2'
            $findings[0].from.lifecycleState | Should -Be 'superseded'
        }

        It 'Reports nothing when the pinned template is the active one, whatever the revision number' {
            $templates = [ordered]@{
                $script:templateId                       = New-ThinTemplate -Version 'Version 24H1'
                '11111111-1111-1111-1111-111111111111_3' = New-ThinTemplate -Version 'Version 6' -LifecycleState 'superseded'
            }
            $snapshot = New-CatalogSnapshot -Template $templates -Pinned ([ordered]@{ $script:templateId = New-PinnedTemplate })

            @(Compare-SettingsCatalog -Baseline $snapshot -Current $snapshot `
                    -Binding $script:bindingRow -DeclaredProperty (New-DeclaredMap)) |
                Should -HaveCount 0
        }

        It 'Reports nothing when no sibling of a superseded template is active' {
            $templates = [ordered]@{
                $script:templateId                       = New-ThinTemplate -LifecycleState 'superseded'
                '11111111-1111-1111-1111-111111111111_3' = New-ThinTemplate -LifecycleState 'deprecated'
            }
            $snapshot = New-CatalogSnapshot -Template $templates -Pinned ([ordered]@{ $script:templateId = New-PinnedTemplate })

            @(Compare-SettingsCatalog -Baseline $snapshot -Current $snapshot `
                    -Binding $script:bindingRow -DeclaredProperty (New-DeclaredMap)) |
                Should -HaveCount 0
        }

        It 'Reports a tenant template no resource pins and the baseline does not carry' {
            $baseline = New-CatalogSnapshot -Template ([ordered]@{ $script:templateId = New-ThinTemplate }) `
                -Pinned ([ordered]@{ $script:templateId = New-PinnedTemplate })
            $current = New-CatalogSnapshot -Template ([ordered]@{
                    $script:templateId                       = New-ThinTemplate
                    '99999999-9999-9999-9999-999999999999_1' = New-ThinTemplate -DisplayName 'Brand new'
                }) -Pinned ([ordered]@{ $script:templateId = New-PinnedTemplate })

            $findings = @(Compare-SettingsCatalog -Baseline $baseline -Current $current `
                    -Binding $script:bindingRow -DeclaredProperty (New-DeclaredMap))

            $findings | Should -HaveCount 1
            $findings[0].code | Should -Be 'CAT-TEMPLATE-NEW'
            $findings[0].id | Should -Be 'CAT-TEMPLATE-NEW:99999999-9999-9999-9999-999999999999_1'
            $findings[0].severity | Should -Be 'info'
        }

        It 'Reports nothing when the baseline already carries the unpinned template' {
            $templates = [ordered]@{
                $script:templateId                       = New-ThinTemplate
                '99999999-9999-9999-9999-999999999999_1' = New-ThinTemplate
            }
            $snapshot = New-CatalogSnapshot -Template $templates -Pinned ([ordered]@{ $script:templateId = New-PinnedTemplate })

            @(Compare-SettingsCatalog -Baseline $snapshot -Current $snapshot `
                    -Binding $script:bindingRow -DeclaredProperty (New-DeclaredMap)) |
                Should -HaveCount 0
        }

        It 'Reports nothing when the run could not reach the settings catalog' {
            $baseline = New-CatalogSnapshot -Pinned ([ordered]@{ $script:templateId = New-PinnedTemplate -Setting ([ordered]@{
                            'setting_a' = New-CatalogSetting
                        }) })
            $current = New-CatalogSnapshot -SkippedWorkload @('settingsCatalog')

            @(Compare-SettingsCatalog -Baseline $baseline -Current $current `
                    -Binding $script:bindingRow -DeclaredProperty (New-DeclaredMap -Name @('CRLcheck'))) |
                Should -HaveCount 0
        }

        It 'Reports nothing when the baseline predates the settings catalog section' {
            $current = New-CatalogSnapshot -Pinned ([ordered]@{ $script:templateId = New-PinnedTemplate -Setting ([ordered]@{
                            'setting_a' = New-CatalogSetting
                        }) })

            @(Compare-SettingsCatalog -Baseline ([ordered]@{ completeness = [ordered]@{ skippedWorkloads = @() } }) `
                    -Current $current -Binding $script:bindingRow -DeclaredProperty (New-DeclaredMap)) |
                Should -HaveCount 0
        }
    }

    Describe 'Get-ResourceDeclaredProperty' {
        BeforeAll {
            $script:modulePath = Join-Path -Path $PSScriptRoot -ChildPath 'Fixtures\SettingsCatalog\MSFT_TestCatalogPolicy\MSFT_TestCatalogPolicy.psm1'
            $script:declared = Get-ResourceDeclaredProperty -Path $script:modulePath
        }

        It 'Reads the properties of the resource class' {
            $script:declared.Contains('CRLcheck') | Should -BeTrue
        }

        It 'Reads the properties of a wrapper class in the same file' {
            $script:declared.Contains('DeviceScopedSetting') | Should -BeTrue
        }

        It 'Ignores a member without a DscProperty attribute' {
            $script:declared.Contains('ExportOnly') | Should -BeFalse
        }
    }

    Describe 'Test-ApplyAllowed' {
        It 'Refuses a settings catalog code even under the override' {
            Test-ApplyAllowed -Code 'CAT-SETTING-ADDED' -Finding ([ordered]@{ autoFixable = $true }) -AllowNonAutomatic |
                Should -BeFalse
        }
    }
}

Describe 'Update-M365DSCResourceFromDrift' {
    BeforeAll {
        $script:previousGitHubActions = $env:GITHUB_ACTIONS
        $env:GITHUB_ACTIONS = $null
    }

    AfterAll {
        $env:GITHUB_ACTIONS = $script:previousGitHubActions
    }

    It 'Throws on a settings catalog finding and names the generator' {
        $finding = [ordered]@{
            code     = 'CAT-SETTING-ADDED'
            resource = 'IntuneFirewallPolicyWindows10'
            property = 'vendor_msft_firewall_crlcheck'
        }

        { Update-M365DSCResourceFromDrift -Finding $finding } |
            Should -Throw -ExpectedMessage '*New-M365DSCResource*SettingsCatalogTemplateId*'
    }

    It 'Throws on a settings catalog finding even with AllowNonAutomatic' {
        $finding = [ordered]@{
            code        = 'CAT-OPTION-ADDED'
            resource    = 'IntuneFirewallPolicyWindows10'
            autoFixable = $true
        }

        { Update-M365DSCResourceFromDrift -Finding $finding -AllowNonAutomatic } |
            Should -Throw -ExpectedMessage '*never applied by the splicer*'
    }
}
