<#
    Offline unit tests for acquisition: type auto-pick scoring, CSDL type walking (against an
    in-memory fixture) and resource model assembly. No network or Graph modules required.
#>

Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath '..\M365DSCResourceGenerator.psd1') -Force

InModuleScope -ModuleName 'M365DSCResourceGenerator' {

    Describe 'Resolve-M365DSCTypeCandidate' {
        It 'returns the single candidate without scoring' {
            Resolve-M365DSCTypeCandidate -Candidates @('onlyOne') -ResourceName 'Whatever' |
                Should -Be 'onlyOne'
        }

        It 'honors the override even when unknown' {
            Resolve-M365DSCTypeCandidate -Candidates @('a', 'b') -Override 'custom' -WarningAction SilentlyContinue |
                Should -Be 'custom'
        }

        It 'picks windows10CompliancePolicy for IntuneDeviceCompliancePolicyWindows10' {
            $candidates = @(
                'androidCompliancePolicy', 'androidWorkProfileCompliancePolicy', 'iosCompliancePolicy',
                'macOSCompliancePolicy', 'windows10CompliancePolicy', 'windows10MobileCompliancePolicy',
                'windowsPhone81CompliancePolicy'
            )
            Resolve-M365DSCTypeCandidate -Candidates $candidates `
                -ResourceName 'IntuneDeviceCompliancePolicyWindows10' `
                -CmdLetNoun 'MgBetaDeviceManagementDeviceCompliancePolicy' `
                -AllowPrompt $false |
                Should -Be 'windows10CompliancePolicy'
        }

        It 'picks the exact-match subtype for a simple resource' {
            Resolve-M365DSCTypeCandidate -Candidates @('group', 'unifiedGroup', 'dynamicGroup') `
                -ResourceName 'AADGroup' `
                -CmdLetNoun 'MgGroup' `
                -AllowPrompt $false |
                Should -Be 'group'
        }

        It 'throws with guidance when non-interactive and ambiguous' {
            { Resolve-M365DSCTypeCandidate -Candidates @('alphaBravoCharlie', 'deltaEchoFoxtrot') `
                    -ResourceName 'ZuluYankee' `
                    -CmdLetNoun 'MgXrayWhiskey' `
                    -AllowPrompt $false } |
                Should -Throw -ExpectedMessage '*-AdditionalPropertiesType*'
        }
    }

    Describe 'Get-M365DSCTypeCandidateScore' {
        It 'scores an exact normalized match as 1.0' {
            Get-M365DSCTypeCandidateScore -Candidate '#microsoft.graph.permissionGrantPolicy' -Target 'MgBetaPolicyPermissionGrantPolicy' |
                Should -BeGreaterOrEqual 0.85
        }

        It 'scores unrelated names low' {
            Get-M365DSCTypeCandidateScore -Candidate 'windows10CompliancePolicy' -Target 'TeamsMeetingPolicy' |
                Should -BeLessThan 0.5
        }

        It 'strips the IMicrosoftGraph prefix and the trailing 1' {
            Get-M365DSCTypeCandidateScore -Candidate 'IMicrosoftGraphGroup1' -Target 'MgGroup' |
                Should -Be 1.0
        }
    }

    Describe 'Get-M365DSCGraphTypeProperty' {
        BeforeAll {
            $csdl = @'
<Edmx xmlns="http://docs.oasis-open.org/odata/ns/edmx" Version="4.0">
  <DataServices>
    <schema Namespace="microsoft.graph" xmlns="http://docs.oasis-open.org/odata/ns/edm">
      <EntityType Name="entity" Abstract="true">
        <Property Name="id" Type="Edm.String">
          <Annotation Term="Org.OData.Core.V1.Description" String="The unique identifier." />
        </Property>
      </EntityType>
      <EntityType Name="testPolicy" BaseType="graph.entity">
        <Property Name="displayName" Type="Edm.String">
          <Annotation Term="Org.OData.Core.V1.Description" String="The display name." />
        </Property>
        <Property Name="isEnabled" Type="Edm.Boolean">
          <Annotation Term="Org.OData.Core.V1.Description" String="Whether enabled." />
        </Property>
        <Property Name="createdDateTime" Type="Edm.DateTimeOffset" />
        <Property Name="state" Type="graph.testState" />
        <Property Name="rules" Type="Collection(graph.testRule)" />
        <NavigationProperty Name="linkedThing" Type="graph.testPolicy" />
      </EntityType>
      <ComplexType Name="testRule">
        <Property Name="name" Type="Edm.String">
          <Annotation Term="Org.OData.Core.V1.Description" String="Rule name." />
        </Property>
        <Property Name="threshold" Type="Edm.Int32" />
      </ComplexType>
      <EnumType Name="testState">
        <Member Name="enabled" Value="0" />
        <Member Name="disabled" Value="1" />
      </EnumType>
    </schema>
  </DataServices>
</Edmx>
'@
            $script:schema = ([Xml] $csdl).Edmx.DataServices.schema
        }

        It 'walks the inheritance chain and returns base properties' {
            $models = Get-M365DSCGraphTypeProperty -Schema $script:schema -Entity 'testPolicy'
            $models.Name | Should -Contain 'Id'
            $models.Name | Should -Contain 'DisplayName'
        }

        It 'resolves enums with their members' {
            $models = Get-M365DSCGraphTypeProperty -Schema $script:schema -Entity 'testPolicy'
            $state = $models | Where-Object { $_.Name -eq 'State' }
            $state.IsEnum | Should -BeTrue
            $state.EnumValues | Should -Be @('enabled', 'disabled')
        }

        It 'recurses into complex collections' {
            $models = Get-M365DSCGraphTypeProperty -Schema $script:schema -Entity 'testPolicy'
            $rules = $models | Where-Object { $_.Name -eq 'Rules' }
            $rules.IsComplex | Should -BeTrue
            $rules.IsArray | Should -BeTrue
            $rules.CimClassName | Should -Be 'MSFT_MicrosoftGraphTestRule'
            $rules.Members.Name | Should -Be @('Name', 'Threshold')
        }

        It 'extracts descriptions from annotations' {
            $models = Get-M365DSCGraphTypeProperty -Schema $script:schema -Entity 'testPolicy'
            ($models | Where-Object { $_.Name -eq 'DisplayName' }).Description | Should -Be 'The display name.'
        }

        It 'breaks self-referencing navigation cycles instead of looping' {
            $models = Get-M365DSCGraphTypeProperty -Schema $script:schema -Entity 'testPolicy' `
                -IncludeNavigationProperties $true -WarningAction SilentlyContinue
            # The self-reference is skipped, everything else survives.
            $models.Name | Should -Not -Contain 'LinkedThing'
            $models.Name | Should -Contain 'DisplayName'
        }

        It 'suffixes CIM class names that collide with shipped classes' {
            Get-M365DSCUniqueCimClassName -TypeName 'testRule' -ExistingCimClassNames @('MSFT_MicrosoftGraphTestRule') |
                Should -Be 'MSFT_MicrosoftGraphTestRule1'
        }
    }

    Describe 'New-M365DSCResourceModel' {
        BeforeAll {
            $script:properties = @(
                New-M365DSCPropertyModel -Name 'Id' -Type 'Edm.String' -Description 'The id.'
                New-M365DSCPropertyModel -Name 'DisplayName' -Type 'Edm.String' -Description 'The name.'
                New-M365DSCPropertyModel -Name 'CreatedDateTime' -Type 'Edm.DateTimeOffset'
            )
            $script:cmdletInfo = @{
                GetCmdlet    = 'Get-MgTestPolicy'
                NewCmdlet    = 'New-MgTestPolicy'
                UpdateCmdlet = 'Update-MgTestPolicy'
                RemoveCmdlet = 'Remove-MgTestPolicy'
                GetKeyParameters = @('TestPolicyId')
            }
        }

        It 'filters read-only properties and appends Ensure and auth' {
            $model = New-M365DSCResourceModel -ResourceName 'AADTestPolicy' -Workload 'MicrosoftGraph' `
                -CmdletInfo $script:cmdletInfo -Properties $script:properties

            $model.SchemaProperties.Name | Should -Not -Contain 'CreatedDateTime'
            $model.Properties.Name | Should -Contain 'Ensure'
            $model.Properties.Name | Should -Contain 'Credential'
            $model.Properties.Name | Should -Contain 'AccessTokens'
        }

        It 'keys the name and leaves the identifier to the cmdlets' {
            $model = New-M365DSCResourceModel -ResourceName 'AADTestPolicy' -Workload 'MicrosoftGraph' `
                -CmdletInfo $script:cmdletInfo -Properties $script:properties

            $model.PrimaryKey | Should -Be 'Id'
            $model.AlternativeKey | Should -Be 'DisplayName'
            ($model.Properties | Where-Object { $_.Name -eq 'DisplayName' }).IsKey | Should -BeTrue
            ($model.Properties | Where-Object { $_.Name -eq 'Id' }).IsKey | Should -BeFalse
        }

        It 'unwraps System.Nullable when a value-typed property becomes the key' {
            $valueKeyProperties = @(
                New-M365DSCPropertyModel -Name 'Priority' -Type 'Edm.Int32' -Description 'The priority.'
                New-M365DSCPropertyModel -Name 'Comment' -Type 'Edm.String' -Description 'The comment.'
            )
            $model = New-M365DSCResourceModel -ResourceName 'AADTestPolicy' -Workload 'MicrosoftGraph' `
                -CmdletInfo (@{} + $script:cmdletInfo + @{ PrimaryKey = 'Priority' }) -Properties $valueKeyProperties

            ($model.Properties | Where-Object { $_.Name -eq 'Priority' }).ClrType | Should -Be 'System.Int32'
        }

        It 'replaces the key with IsSingleInstance for singletons' {
            $model = New-M365DSCResourceModel -ResourceName 'AADTestPolicy' -Workload 'MicrosoftGraph' `
                -CmdletInfo $script:cmdletInfo -Properties $script:properties -IsSingleInstance $true

            $model.PrimaryKey | Should -Be 'IsSingleInstance'
            $model.Properties.Name | Should -Not -Contain 'Ensure'
        }

        It 'honors ParametersToSkip' {
            $model = New-M365DSCResourceModel -ResourceName 'AADTestPolicy' -Workload 'MicrosoftGraph' `
                -CmdletInfo $script:cmdletInfo -Properties $script:properties -ParametersToSkip @('DisplayName')

            $model.SchemaProperties.Name | Should -Not -Contain 'DisplayName'
        }

        It 'collects nested complex classes depth-first' {
            $inner = New-M365DSCPropertyModel -Name 'Inner' -CimClassName 'MSFT_TestInner' -Members @(
                New-M365DSCPropertyModel -Name 'Value' -Type 'Edm.String'
            )
            $outer = New-M365DSCPropertyModel -Name 'Outer' -CimClassName 'MSFT_TestOuter' -Members @($inner)

            $classes = @(Get-M365DSCComplexTypeClass -Properties @($outer))
            $classes.CimClassName | Should -Be @('MSFT_TestInner', 'MSFT_TestOuter')
        }
    }

    Describe 'Get-M365DSCResourceDescriptor' {
        It 'spaces out the resource name and maps platforms' {
            (Get-M365DSCResourceDescriptor -ResourceName 'IntuneDeviceCompliancePolicyWindows10').Description |
                Should -Be 'Intune Device Compliance Policy for Windows10'
        }

        It 'keeps acronyms whole' {
            (Get-M365DSCResourceDescriptor -ResourceName 'SCAdaptiveScope').Description | Should -Be 'SC Adaptive Scope'
            (Get-M365DSCResourceDescriptor -ResourceName 'SCDLPCompliancePolicy').Description | Should -Be 'SC DLP Compliance Policy'
            (Get-M365DSCResourceDescriptor -ResourceName 'EXOCASMailboxPlan').Description | Should -Be 'EXO CAS Mailbox Plan'
            (Get-M365DSCResourceDescriptor -ResourceName 'AADB2BManagementPolicy').Description | Should -Be 'Entra ID B2B Management Policy'
        }

        It 'maps Apple platforms whatever their casing in the resource name' {
            (Get-M365DSCResourceDescriptor -ResourceName 'IntuneDeviceConfigurationPolicyiOS').Description | Should -Be 'Intune Device Configuration Policy for iOS'
            (Get-M365DSCResourceDescriptor -ResourceName 'IntuneVPNConfigurationPolicyIOS').Description | Should -Be 'Intune VPN Configuration Policy for iOS'
            (Get-M365DSCResourceDescriptor -ResourceName 'IntuneVPNConfigurationPolicyMacOS').Description | Should -Be 'Intune VPN Configuration Policy for macOS'
        }

        It 'derives the short descriptor' {
            (Get-M365DSCResourceDescriptor -ResourceName 'IntuneDeviceCompliancePolicyWindows10').ShortDescriptor |
                Should -Be 'policy'
            (Get-M365DSCResourceDescriptor -ResourceName 'AADGroup').ShortDescriptor |
                Should -Be 'group'
        }
    }

    Describe 'Get-M365DSCGraphPropertyDescription' {
        BeforeAll {
            $descriptionCsdl = @'
<Edmx xmlns="http://docs.oasis-open.org/odata/ns/edmx" Version="4.0">
  <DataServices>
    <schema Namespace="microsoft.graph" xmlns="http://docs.oasis-open.org/odata/ns/edm">
      <EntityType Name="entity" Abstract="true">
        <Property Name="id" Type="Edm.String" />
      </EntityType>
      <EntityType Name="testRoot" BaseType="graph.entity">
        <Property Name="inlineOne" Type="Edm.String">
          <Annotation Term="Org.OData.Core.V1.Description" String="Inline description." />
        </Property>
        <Property Name="inlineMany" Type="Edm.String">
          <Annotation Term="Org.OData.Core.V1.Computed" Bool="true" />
          <Annotation Term="Org.OData.Capabilities.V1.UpdateRestrictions" />
          <Annotation Term="Org.OData.Core.V1.Description" String="Third annotation wins." />
        </Property>
        <Property Name="onlyCapability" Type="Edm.String">
          <Annotation Term="Org.OData.Core.V1.Computed" Bool="true" />
        </Property>
        <Property Name="viaFallback" Type="Edm.String" />
      </EntityType>
      <Annotations Target="microsoft.graph.testRoot/viaFallback">
        <Annotation Term="Org.OData.Core.V1.Description" String="Root fallback description." />
      </Annotations>
      <Annotations Target="microsoft.graph.testRoot/onlyCapability">
        <Annotation Term="Org.OData.Core.V1.Description" String="Capability fallback description." />
      </Annotations>
    </schema>
    <schema Namespace="microsoft.graph.testaccess" xmlns="http://docs.oasis-open.org/odata/ns/edm">
      <EntityType Name="testProfile" BaseType="graph.entity">
        <Property Name="profileName" Type="Edm.String" />
      </EntityType>
      <Annotations Target="microsoft.graph.testaccess.testProfile/profileName">
        <Annotation Term="Org.OData.Core.V1.Description" String="Sub-namespace description." />
      </Annotations>
    </schema>
  </DataServices>
</Edmx>
'@
            $script:descriptionSchema = ([Xml] $descriptionCsdl).Edmx.DataServices.schema
            $script:descriptionIndex = New-M365DSCGraphSchemaIndex -Schema $script:descriptionSchema
            $script:descriptionSchemaWithoutAnnotations = ([Xml] ($descriptionCsdl -replace '(?s)<Annotations.*?</Annotations>', '')).Edmx.DataServices.schema

            function Get-TestProperty
            {
                param
                (
                    [System.String] $Namespace,
                    [System.String] $Type,
                    [System.String] $Property
                )

                $node = $script:descriptionSchema | Where-Object -FilterScript { $_.Namespace -eq $Namespace }
                $entity = $node.EntityType | Where-Object -FilterScript { $_.Name -eq $Type }

                return $entity.Property | Where-Object -FilterScript { $_.Name -eq $Property }
            }
        }

        It 'reads an inline description' {
            $property = Get-TestProperty -Namespace 'microsoft.graph' -Type 'testRoot' -Property 'inlineOne'
            Get-M365DSCGraphPropertyDescription -Schema $script:descriptionSchema -Property $property |
                Should -Be 'Inline description.'
        }

        It 'picks the Description out of several inline annotations' {
            $property = Get-TestProperty -Namespace 'microsoft.graph' -Type 'testRoot' -Property 'inlineMany'
            Get-M365DSCGraphPropertyDescription -Schema $script:descriptionSchema -Property $property |
                Should -Be 'Third annotation wins.'
        }

        It 'does not throw when a property carries several inline annotations' {
            $property = Get-TestProperty -Namespace 'microsoft.graph' -Type 'testRoot' -Property 'inlineMany'
            { Get-M365DSCGraphPropertyDescription -Schema $script:descriptionSchema -Property $property } |
                Should -Not -Throw
        }

        It 'falls back to the schema-level block in microsoft.graph' {
            $property = Get-TestProperty -Namespace 'microsoft.graph' -Type 'testRoot' -Property 'viaFallback'
            Get-M365DSCGraphPropertyDescription -Schema $script:descriptionSchema -Property $property |
                Should -Be 'Root fallback description.'
        }

        It 'falls back when the only inline annotation is not a description' {
            $property = Get-TestProperty -Namespace 'microsoft.graph' -Type 'testRoot' -Property 'onlyCapability'
            Get-M365DSCGraphPropertyDescription -Schema $script:descriptionSchema -Property $property |
                Should -Be 'Capability fallback description.'
        }

        It 'resolves the schema-level block of a sub-namespaced type' {
            $property = Get-TestProperty -Namespace 'microsoft.graph.testaccess' -Type 'testProfile' -Property 'profileName'
            Get-M365DSCGraphPropertyDescription -Schema $script:descriptionSchema `
                -Property $property `
                -NamespaceName 'microsoft.graph.testaccess' `
                -TypeName 'testProfile' |
                Should -Be 'Sub-namespace description.'
        }

        It 'finds nothing for a sub-namespaced type when the namespace is assumed' {
            $property = Get-TestProperty -Namespace 'microsoft.graph.testaccess' -Type 'testProfile' -Property 'profileName'
            Get-M365DSCGraphPropertyDescription -Schema $script:descriptionSchema -Property $property |
                Should -BeNullOrEmpty
        }

        It 'reads the schema-level block off the index instead of scanning the schema' {
            $property = Get-TestProperty -Namespace 'microsoft.graph' -Type 'testRoot' -Property 'viaFallback'
            Get-M365DSCGraphPropertyDescription -Schema $script:descriptionSchemaWithoutAnnotations `
                -Property $property `
                -Index $script:descriptionIndex |
                Should -Be 'Root fallback description.'
        }

        It 'keys the index by target regardless of the declaring namespace' {
            $property = Get-TestProperty -Namespace 'microsoft.graph.testaccess' -Type 'testProfile' -Property 'profileName'
            Get-M365DSCGraphPropertyDescription -Schema $script:descriptionSchemaWithoutAnnotations `
                -Property $property `
                -NamespaceName 'microsoft.graph.testaccess' `
                -TypeName 'testProfile' `
                -Index $script:descriptionIndex |
                Should -Be 'Sub-namespace description.'
        }

        It 'carries the declaring namespace through Get-M365DSCGraphTypeProperty' {
            $models = Get-M365DSCGraphTypeProperty -Schema $script:descriptionSchema -Entity 'testProfile'
            ($models | Where-Object { $_.Name -eq 'ProfileName' }).Description |
                Should -Be 'Sub-namespace description.'
        }

        It 'returns an empty string for <Case>' -TestCases @(
            @{ Case = 'no annotation at all'; Value = $null }
            @{ Case = 'an empty collection'; Value = @() }
        ) {
            Get-M365DSCGraphAnnotationDescription -Annotation $Value | Should -Be ''
        }
    }
}
