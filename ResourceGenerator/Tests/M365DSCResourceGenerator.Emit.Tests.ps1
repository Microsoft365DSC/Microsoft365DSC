<#
    Offline unit tests for the emitters: class module, unit test, examples and
    settings, all generated from a hand-built resource model fixture and validated with the
    PowerShell parser. No network or Graph modules required.
#>

Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath '..\M365DSCResourceGenerator.psd1') -Force

InModuleScope -ModuleName 'M365DSCResourceGenerator' {

    BeforeAll {
        function Get-ParseError
        {
            param ([System.String] $Content)

            $parseErrors = $null
            $null = [System.Management.Automation.Language.Parser]::ParseInput($Content, [ref] $null, [ref] $parseErrors)

            # Artefacts of parsing outside the repository layout: the relative 'using module'
            # cannot resolve, which also makes DSC complain about the base type. The QA suite
            # (Tests\QA\Microsoft365DSC.ClassResources.Tests.ps1) parses in place and catches
            # real occurrences of these.
            return @($parseErrors | Where-Object {
                    $_.ErrorId -notin @('TypeNotFound', 'DscResourceMissingTestMethod', 'ModuleNotFoundDuringParse')
                })
        }

        $ruleMembers = @(
            New-M365DSCPropertyModel -Name 'Name' -Type 'Edm.String' -Description 'Rule name.'
            New-M365DSCPropertyModel -Name 'Threshold' -Type 'Edm.Int32' -Description 'Rule threshold.'
            New-M365DSCPropertyModel -Name 'State' -EnumValues @('enabled', 'disabled') -Description 'Rule state.'
        )

        $properties = @(
            New-M365DSCPropertyModel -Name 'Id' -Type 'Edm.String' -Description 'The unique identifier.'
            New-M365DSCPropertyModel -Name 'DisplayName' -Type 'Edm.String' -Description 'The display name.'
            New-M365DSCPropertyModel -Name 'IsEnabled' -Type 'Edm.Boolean' -Description 'Whether enabled.'
            New-M365DSCPropertyModel -Name 'RequiredSetting' -Type 'Edm.String' -IsMandatory $true -Description 'A mandatory property.'
            New-M365DSCPropertyModel -Name 'StartDate' -Type 'Edm.DateTimeOffset' -Description 'The start date.'
            New-M365DSCPropertyModel -Name 'Level' -EnumValues @('low', 'medium', 'high') -Description 'The level.'
            New-M365DSCPropertyModel -Name 'Tags' -Type 'Edm.String' -IsArray $true -Description 'The tags.'
            New-M365DSCPropertyModel -Name 'Rules' -CimClassName 'MSFT_MicrosoftGraphTestRule' -IsArray $true -Members $ruleMembers -Description 'The rules.'
        )

        $cmdletInfo = @{
            APIVersion          = 'beta'
            ActualType          = 'testPolicy'
            GetCmdlet           = 'Get-MgBetaTestPolicy'
            NewCmdlet           = 'New-MgBetaTestPolicy'
            UpdateCmdlet        = 'Update-MgBetaTestPolicy'
            RemoveCmdlet        = 'Remove-MgBetaTestPolicy'
            GetKeyParameters    = @('TestPolicyId')
            NewKeyParameters    = @('BodyParameter')
            UpdateKeyParameters = @('TestPolicyId', 'BodyParameter')
            RemoveKeyParameters = @('TestPolicyId')
            SupportsAll         = $true
            SupportsFilter      = $true
        }

        $script:model = New-M365DSCResourceModel -ResourceName 'AADTestPolicy' -Workload 'MicrosoftGraph' `
            -CmdletInfo $cmdletInfo -Properties $properties

        $script:classContent = New-M365DSCClassModuleFile -ResourceModel $script:model
        $script:testContent = New-M365DSCUnitTestFile -ResourceModel $script:model
    }

    Describe 'New-M365DSCClassModuleFile' {
        It 'produces parseable PowerShell' {
            $parseErrors = Get-ParseError -Content $script:classContent
            $messages = ($parseErrors | ForEach-Object { "line $($_.Extent.StartLineNumber): $($_.Message)" }) -join '; '
            $parseErrors.Count | Should -Be 0 -Because $messages
        }

        It 'opens with the base-class using statement' {
            $firstStatement = @($script:classContent -split "`r?`n" |
                    Where-Object { $_.Trim() -ne '' -and -not $_.Trim().StartsWith('#') } |
                    Select-Object -First 1)[0]
            $firstStatement.Trim() | Should -Be 'using module ..\_Base\M365DSCResourceBase.psm1'
        }

        It 'declares exactly one [DscResource()] class' {
            ([regex]::Matches($script:classContent, '(?m)^\s*\[DscResource\(\)\]')).Count | Should -Be 1
            $script:classContent | Should -Match 'class AADTestPolicy : M365DSCResourceBase'
        }

        It 'declares the embedded CIM class without a DscResource attribute' {
            $script:classContent | Should -Match '(?m)^class MSFT_MicrosoftGraphTestRule'
        }

        It 'declares the four DSC methods plus AsResult' {
            $script:classContent | Should -Match '\[AADTestPolicy\] Get\(\)'
            $script:classContent | Should -Match '\[void\] Set\(\)'
            $script:classContent | Should -Match '\[bool\] Test\(\)'
            $script:classContent | Should -Match '\[string\] Export\(\)'
            $script:classContent | Should -Match 'hidden \[AADTestPolicy\] AsResult'
        }

        It 'uses the base-class plumbing instead of script-scope state' {
            $script:classContent | Should -Match '\$this\.Connect\(''MicrosoftGraph''\)'
            $script:classContent | Should -Match '\$this\.AddTelemetry\('
            $script:classContent | Should -Match '\$this\.ExportedInstance'
            $script:classContent | Should -Not -Match '\$Script:exportedInstance'
            $script:classContent | Should -Not -Match 'function Get-TargetResource'
        }

        It 'wraps value types in Nullable and keys the name' {
            $script:classContent | Should -Match '\[System\.Nullable\[System\.Boolean\]\] \$IsEnabled'
            $script:classContent | Should -Match '(?s)\[DscProperty\(Key\)\]\s*\[System\.ComponentModel\.Description\(''The display name\.''\)\]\s*\[System\.String\] \$DisplayName'
        }

        It 'declares no conversion helper method' {
            $script:classContent | Should -Not -Match 'hidden \[System\.Collections\.Hashtable\]'
            $script:classContent | Should -Not -Match '(?m)^function '
        }

        It 'converts dates before the result hashtable' {
            $script:classContent | Should -Match '\$dateStartDate = \$getValue\.StartDate\.ToUniversalTime\(\)\.ToString\(''o''\)'
        }

        It 'exports with -All and NoEscape for the complex property' {
            $script:classContent | Should -Match 'Get-MgBetaTestPolicy -All'
            $script:classContent | Should -Match "-NoEscape @\('Rules'\)"
        }
    }
    Describe 'New-M365DSCComplexConversionBlock' {
        It 'converts a complex property inline instead of calling a helper method' {
            $script:classContent | Should -Not -Match 'AsHashtable'
            $script:classContent | Should -Match '\$complexRules = @\(\)'
            $script:classContent | Should -Match 'foreach \(\$currentRules in \$getValue\.Rules\)'
            $script:classContent | Should -Match "\`$myRules\.Add\('Name', \`$currentRules\.name\)"
            $script:classContent | Should -Match "\`$myRules\.values\.Where\(\{ \`$null -ne \`$_ \}\)\.Count -gt 0"
        }

        It 'maps a Graph enum straight from the returned value' {
            $script:classContent | Should -Not -Match '\$enumLevel'
            $script:classContent | Should -Not -Match '\$getValue\.\w+\.ToString\(\)'
            $script:classContent | Should -Match 'Level\s+= \$getValue\.Level'
        }

        It 'keeps the ToString conversion for a workload without the shim' {
            $exoInfo = @{
                GetCmdlet    = 'Get-AcceptedDomain'
                NewCmdlet    = 'New-AcceptedDomain'
                UpdateCmdlet = 'Set-AcceptedDomain'
                RemoveCmdlet = 'Remove-AcceptedDomain'
            }
            $exoProperties = @(
                New-M365DSCPropertyModel -Name 'Identity' -Type 'Edm.String' -Description 'The identity.'
                New-M365DSCPropertyModel -Name 'DomainType' -EnumValues @('authoritative', 'internalRelay') -Description 'The domain type.'
            )
            $exoModel = New-M365DSCResourceModel -ResourceName 'EXOAcceptedDomain' -Workload 'ExchangeOnline' `
                -CmdletInfo $exoInfo -Properties $exoProperties -CmdLetNoun 'AcceptedDomain' -CmdLetVerb 'Set'

            $block = New-M365DSCComplexConversionBlock -ResourceModel $exoModel

            $block | Should -Match '\$enumDomainType = \$getValue\.DomainType\.ToString\(\)'
        }
    }

    Describe 'New-M365DSCCompareParametersBlock' {
        It 'excludes the create-only properties from Test' {
            $model = [PSCustomObject] @{ CreateOnlyProperties = @('MobileAppCatalogPackageBranchId') }

            $block = New-M365DSCCompareParametersBlock -ResourceModel $model

            $block | Should -Match '\[System\.Collections\.Hashtable\] GetCompareParameters\(\)'
            $block | Should -Match "ExcludedProperties = @\('MobileAppCatalogPackageBranchId'\)"
        }

        It 'renders nothing without a create-only property' {
            New-M365DSCCompareParametersBlock -ResourceModel ([PSCustomObject] @{ CreateOnlyProperties = @() }) | Should -Be ''
        }

        It 'leaves the class module without the override when nothing is create-only' {
            $script:classContent | Should -Not -Match 'GetCompareParameters'
        }
    }


    Describe 'New-M365DSCUnitTestFile' {
        It 'produces parseable PowerShell' {
            $parseErrors = Get-ParseError -Content $script:testContent
            $messages = ($parseErrors | ForEach-Object { "line $($_.Extent.StartLineNumber): $($_.Message)" }) -join '; '
            $parseErrors.Count | Should -Be 0 -Because $messages
        }

        It 'contains no unreplaced tokens' {
            $script:testContent | Should -Not -Match '<[A-Za-z][A-Za-z0-9]*>'
        }

        It 'uses the class-based invocation pattern' {
            $script:testContent | Should -Match "New-M365DSCResourceInstance -ResourceName 'AADTestPolicy'"
            $script:testContent | Should -Match "Invoke-M365DSCResourceMethod -ResourceName 'AADTestPolicy' -MethodName 'Export'"
            $script:testContent | Should -Match "Mock -CommandName New-M365DSCConnection -ModuleName '_Shared'"
        }

        It 'asserts scalar property values from the Get result' {
            $script:testContent | Should -Match "\`$result\.DisplayName \| Should -Be 'FakeStringValue'"
            $script:testContent | Should -Match '\$result\.IsEnabled \| Should -Be \$true'
            $script:testContent | Should -Match "\`$result\.Level \| Should -Be 'low'"
            $script:testContent | Should -Match "\`$result\.Tags \| Should -Be @\('FakeStringArrayValue1', 'FakeStringArrayValue2'\)"
        }

        It 'drives the drift context through one changed desired state property' {
            $script:testContent | Should -Match "FakeStringValueDrift' # Updated property"
        }

        It 'defines the Get mock return value once, without branching' {
            $script:testContent | Should -Not -Match 'if \(\$All\)'
            $script:testContent | Should -Not -Match 'This mock returns genuinely drifted values'
            @([regex]::Matches($script:testContent, 'Mock -CommandName Get-MgBetaTestPolicy -MockWith')).Count | Should -Be 2
        }
    }

    Describe 'New-M365DSCExampleFile' {
        BeforeAll {
            $script:exampleFolder = Join-Path -Path $TestDrive -ChildPath 'Examples'
            New-M365DSCExampleFile -ResourceModel $script:model -DestinationFolder $script:exampleFolder
        }

        It 'creates three distinct example files' {
            $createContent = Get-Content -Path (Join-Path $script:exampleFolder '1-Create.ps1') -Raw
            $updateContent = Get-Content -Path (Join-Path $script:exampleFolder '2-Update.ps1') -Raw
            $removeContent = Get-Content -Path (Join-Path $script:exampleFolder '3-Remove.ps1') -Raw

            $createContent | Should -Not -Be $updateContent
            $createContent | Should -Match "Ensure\s+= `"Present`";"
            $removeContent | Should -Match "Ensure\s+= `"Absent`";"
            $removeContent | Should -Not -Match 'IsEnabled'
        }

        It 'names the string placeholder after its property instead of reusing one word' {
            $createContent = Get-Content -Path (Join-Path $script:exampleFolder '1-Create.ps1') -Raw

            $createContent | Should -Match 'M365DSC-DisplayName'
            $createContent | Should -Not -Match 'FakeStringValue'
        }

        It 'drifts exactly one property in the update example and marks it' {
            $createContent = Get-Content -Path (Join-Path $script:exampleFolder '1-Create.ps1') -Raw
            $updateContent = Get-Content -Path (Join-Path $script:exampleFolder '2-Update.ps1') -Raw
            $removeContent = Get-Content -Path (Join-Path $script:exampleFolder '3-Remove.ps1') -Raw

            @([regex]::Matches($updateContent, '# Updated Property')).Count | Should -Be 1
            $createContent | Should -Not -Match '# Updated Property'
            $removeContent | Should -Not -Match '# Updated Property'
        }

        It 'keeps the mandatory properties in the remove example' {
            # [DscProperty(Mandatory)] compiles to Required in the MOF, so a keys-only remove
            # example does not compile.
            $removeContent = Get-Content -Path (Join-Path $script:exampleFolder '3-Remove.ps1') -Raw

            $removeContent | Should -Match 'RequiredSetting'
        }

        It 'produces parseable configurations with CIM instance blocks' {
            foreach ($exampleFile in Get-ChildItem -Path $script:exampleFolder -Filter '*.ps1')
            {
                $parseErrors = $null
                $null = [System.Management.Automation.Language.Parser]::ParseFile($exampleFile.FullName, [ref] $null, [ref] $parseErrors)
                $realErrors = @($parseErrors | Where-Object {
                        $_.ErrorId -notin @('ResourceNotDefined', 'MultipleModuleEntriesFoundDuringParse')
                    })
                $realErrors.Count | Should -Be 0 -Because "$($exampleFile.Name) must parse"
            }

            (Get-Content -Path (Join-Path $script:exampleFolder '1-Create.ps1') -Raw) |
                Should -Match 'MSFT_MicrosoftGraphTestRule\{'
        }
    }

    Describe 'New-M365DSCSettingsFile' {
        It 'emits valid JSON with the roles and commands sections' {
            $json = New-M365DSCSettingsFile -ResourceModel $script:model -WarningAction SilentlyContinue
            $settings = $json | ConvertFrom-Json

            $settings.resourceName | Should -Be 'AADTestPolicy'
            $settings.roles | Should -Not -BeNullOrEmpty
            $settings.mode | Should -Be 'Configuration'
            $settings.supportedEnvironments | Should -Contain 'Global'
        }

        It 'records the origin in generatedFrom directly after resourceName' {
            $json = New-M365DSCSettingsFile -ResourceModel $script:model -WarningAction SilentlyContinue
            $settings = $json | ConvertFrom-Json

            @($settings.PSObject.Properties.Name)[0..2] | Should -Be @('resourceName', 'generatedFrom', 'excludedProperties')
            $settings.generatedFrom.workload | Should -Be 'MicrosoftGraph'
            $settings.generatedFrom.apiVersion | Should -Be 'beta'
            $settings.generatedFrom.entityType | Should -Be 'testPolicy'
            $settings.generatedFrom.odataSubtype | Should -BeNullOrEmpty
            $settings.generatedFrom.cmdletNoun | Should -Be 'MgBetaTestPolicy'
            $settings.generatedFrom.cmdletVerb | Should -Be 'New'
            $settings.generatedFrom.includeNavigationProperties | Should -BeFalse
            $settings.generatedFrom.generatorVersion | Should -Be (Get-Module -Name 'M365DSCResourceGenerator').Version.ToString()
        }

        It 'leaves excludedProperties empty and never writes lastVerified' {
            $json = New-M365DSCSettingsFile -ResourceModel $script:model -WarningAction SilentlyContinue
            $settings = $json | ConvertFrom-Json

            @($settings.excludedProperties) | Should -HaveCount 0
            $settings.PSObject.Properties.Name | Should -Not -Contain 'lastVerified'
        }

        It 'records the concrete subtype of a polymorphic entity in odataSubtype' {
            $polymorphicInfo = @{
                APIVersion   = 'beta'
                ActualType   = 'deviceCompliancePolicy'
                GetCmdlet    = 'Get-MgBetaDeviceManagementDeviceCompliancePolicy'
                NewCmdlet    = 'New-MgBetaDeviceManagementDeviceCompliancePolicy'
                UpdateCmdlet = 'Update-MgBetaDeviceManagementDeviceCompliancePolicy'
                RemoveCmdlet = 'Remove-MgBetaDeviceManagementDeviceCompliancePolicy'
            }
            $polymorphicModel = New-M365DSCResourceModel -ResourceName 'IntuneDeviceCompliancePolicyWindows10' -Workload 'Intune' `
                -CmdletInfo $polymorphicInfo -Properties $properties `
                -SelectedODataType 'windows10CompliancePolicy' -IsAdditionalProperty $true `
                -CmdLetNoun 'MgBetaDeviceManagementDeviceCompliancePolicy' -IncludeNavigationProperties $true

            $settings = (New-M365DSCSettingsFile -ResourceModel $polymorphicModel -WarningAction SilentlyContinue) | ConvertFrom-Json

            $settings.generatedFrom.workload | Should -Be 'Intune'
            $settings.generatedFrom.entityType | Should -Be 'deviceCompliancePolicy'
            $settings.generatedFrom.odataSubtype | Should -Be 'windows10CompliancePolicy'
            $settings.generatedFrom.includeNavigationProperties | Should -BeTrue
        }

        It 'records sub-namespaced Graph types with their namespace prefix' {
            $namespacedInfo = @{
                APIVersion       = 'beta'
                ActualType       = 'policyRule'
                EntityTypeName   = 'networkaccess.policyRule'
                ODataSubtypeName = 'networkaccess.fqdnFilteringRule'
                GetCmdlet        = 'Get-MgBetaNetworkAccessFilteringPolicyRule'
                NewCmdlet        = 'New-MgBetaNetworkAccessFilteringPolicyRule'
                UpdateCmdlet     = 'Update-MgBetaNetworkAccessFilteringPolicyRule'
                RemoveCmdlet     = 'Remove-MgBetaNetworkAccessFilteringPolicyRule'
            }
            $namespacedModel = New-M365DSCResourceModel -ResourceName 'AADFilteringPolicyRule' -Workload 'MicrosoftGraph' `
                -CmdletInfo $namespacedInfo -Properties $properties `
                -SelectedODataType 'fqdnFilteringRule' -IsAdditionalProperty $true `
                -CmdLetNoun 'MgBetaNetworkAccessFilteringPolicyRule'

            $settings = (New-M365DSCSettingsFile -ResourceModel $namespacedModel -WarningAction SilentlyContinue) | ConvertFrom-Json

            $settings.generatedFrom.entityType | Should -Be 'networkaccess.policyRule'
            $settings.generatedFrom.odataSubtype | Should -Be 'networkaccess.fqdnFilteringRule'
        }

        It 'records the origin of a settings catalog resource' {
            $catalogInfo = @{
                TemplateId = '4cfd164c-5e8a-4ea9-b15d-9aa71e4ffff4_1'
                Properties = @(New-M365DSCPropertyModel -Name 'Threshold' -Type 'Edm.Int32' -Description 'A catalog setting.')
            }
            $catalogModel = New-M365DSCSettingsCatalogResourceModel -ResourceName 'IntuneCatalogTestPolicyWindows10' -SettingsCatalogInfo $catalogInfo

            $settings = (New-M365DSCSettingsFile -ResourceModel $catalogModel -WarningAction SilentlyContinue) | ConvertFrom-Json

            $settings.generatedFrom.workload | Should -Be 'Intune'
            $settings.generatedFrom.apiVersion | Should -Be 'beta'
            $settings.generatedFrom.entityType | Should -Be 'deviceManagementConfigurationPolicy'
            $settings.generatedFrom.cmdletNoun | Should -Be 'MgBetaDeviceManagementConfigurationPolicy'
            $settings.generatedFrom.cmdletVerb | Should -Be 'New'
        }

        It 'records only the cmdlet noun and verb for a non-Graph workload' {
            $exoInfo = @{
                Workload     = 'ExchangeOnline'
                GetCmdlet    = 'Get-AcceptedDomain'
                NewCmdlet    = 'New-AcceptedDomain'
                UpdateCmdlet = 'Set-AcceptedDomain'
                RemoveCmdlet = 'Remove-AcceptedDomain'
            }
            $exoModel = New-M365DSCResourceModel -ResourceName 'EXOAcceptedDomain' -Workload 'ExchangeOnline' `
                -CmdletInfo $exoInfo -Properties $properties -CmdLetNoun 'AcceptedDomain' -CmdLetVerb 'Set'

            $settings = (New-M365DSCSettingsFile -ResourceModel $exoModel -WarningAction SilentlyContinue) | ConvertFrom-Json

            $settings.generatedFrom.workload | Should -Be 'ExchangeOnline'
            $settings.generatedFrom.apiVersion | Should -BeNullOrEmpty
            $settings.generatedFrom.entityType | Should -BeNullOrEmpty
            $settings.generatedFrom.cmdletNoun | Should -Be 'AcceptedDomain'
            $settings.generatedFrom.cmdletVerb | Should -Be 'Set'
        }
    }
    Describe 'Select-M365DSCReadPermission' {
        It 'Drops a ReadWrite permission whose Read counterpart is present' {
            Select-M365DSCReadPermission -Permission @('DeviceManagementConfiguration.Read.All', 'DeviceManagementConfiguration.ReadWrite.All') |
                Should -Be @('DeviceManagementConfiguration.Read.All')
        }

        It 'Keeps a ReadWrite permission that stands alone' {
            Select-M365DSCReadPermission -Permission @('DeviceManagementApps.ReadWrite.All') |
                Should -Be @('DeviceManagementApps.ReadWrite.All')
        }

        It 'Returns nothing for an empty list' {
            @(Select-M365DSCReadPermission -Permission @()) | Should -HaveCount 0
        }
    }
    Describe 'Add-M365DSCLookupPermission' {
        It 'Puts GroupMember.Read.All first when the resource handles assignments' {
            $model = [PSCustomObject] @{ HasAssignments = $true; SchemaProperties = @() }

            Add-M365DSCLookupPermission -Permission @('DeviceManagementConfiguration.Read.All') -ResourceModel $model |
                Should -Be @('GroupMember.Read.All', 'DeviceManagementConfiguration.Read.All')
        }

        It 'Puts DeviceManagementRBAC.Read.All last when the resource carries RoleScopeTagIds' {
            $model = [PSCustomObject] @{
                HasAssignments   = $false
                SchemaProperties = @([PSCustomObject] @{ Name = 'RoleScopeTagIds' })
            }

            Add-M365DSCLookupPermission -Permission @('DeviceManagementConfiguration.Read.All') -ResourceModel $model |
                Should -Be @('DeviceManagementConfiguration.Read.All', 'DeviceManagementRBAC.Read.All')
        }

        It 'Adds both lookups around the resource permissions' {
            $model = [PSCustomObject] @{
                HasAssignments   = $true
                SchemaProperties = @([PSCustomObject] @{ Name = 'RoleScopeTagIds' })
            }

            Add-M365DSCLookupPermission -Permission @('DeviceManagementConfiguration.ReadWrite.All') -ResourceModel $model |
                Should -Be @('GroupMember.Read.All', 'DeviceManagementConfiguration.ReadWrite.All', 'DeviceManagementRBAC.Read.All')
        }

        It 'Leaves the permissions untouched without assignments and without RoleScopeTagIds' {
            $model = [PSCustomObject] @{ HasAssignments = $false; SchemaProperties = @() }

            Add-M365DSCLookupPermission -Permission @('DeviceManagementApps.Read.All') -ResourceModel $model |
                Should -Be @('DeviceManagementApps.Read.All')
        }

        It 'Adds no duplicate when the permission is already declared' {
            $model = [PSCustomObject] @{
                HasAssignments   = $true
                SchemaProperties = @([PSCustomObject] @{ Name = 'RoleScopeTagIds' })
            }

            @(Add-M365DSCLookupPermission -Permission @('GroupMember.Read.All', 'DeviceManagementRBAC.Read.All') -ResourceModel $model) |
                Should -Be @('GroupMember.Read.All', 'DeviceManagementRBAC.Read.All')
        }
    }
}