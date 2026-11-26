Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath '..\..\..\Utilities\ApiSurface\M365DSCApiSurface.psd1') -Force

InModuleScope -ModuleName 'M365DSCApiSurface' {

    Describe 'Get-M365DSCApiSurface' {
        BeforeAll {
            $script:repositoryRoot = Join-Path -Path $PSScriptRoot -ChildPath '../../..' -Resolve
            $script:fixtureRoot = Join-Path -Path $PSScriptRoot -ChildPath 'Fixtures/ApiSurface' -Resolve
            $script:originalModulePath = $env:PSModulePath
            $env:PSModulePath = (Join-Path -Path $script:fixtureRoot -ChildPath 'Modules') + [System.IO.Path]::PathSeparator + $env:PSModulePath

            $script:surfaceParameters = @{
                RepositoryRoot            = $script:repositoryRoot
                ResourcePath              = Join-Path -Path $script:fixtureRoot -ChildPath 'Resources'
                CmdletMappingPath         = Join-Path -Path $script:fixtureRoot -ChildPath 'cmdlet-mapping.json'
                FunctionSignaturePath     = Join-Path -Path $script:fixtureRoot -ChildPath 'function-signatures.json'
                CmdletMappingOverridePath = Join-Path -Path $script:fixtureRoot -ChildPath 'cmdlet-mapping-overrides.json'
                ShimModulePath            = Join-Path -Path $script:fixtureRoot -ChildPath 'shim.psm1'
                ShimManifestPath          = Join-Path -Path $script:fixtureRoot -ChildPath 'shim.psd1'
                ManifestPath              = Join-Path -Path $script:fixtureRoot -ChildPath 'Manifest.psd1'
                DevManifestPath           = Join-Path -Path $script:fixtureRoot -ChildPath 'DevManifest.psd1'
                CsdlPathV1                = Join-Path -Path $script:fixtureRoot -ChildPath 'csdl-v1.0.xml'
                CsdlPathBeta              = Join-Path -Path $script:fixtureRoot -ChildPath 'csdl-beta.xml'
                SkipGalleryLookup         = $true
            }

            $script:surface = Get-M365DSCApiSurface @script:surfaceParameters -WarningAction SilentlyContinue
        }

        AfterAll {
            $env:PSModulePath = $script:originalModulePath
            Remove-Module -Name 'M365DSCApiSurfaceTestWorkload' -Force -ErrorAction SilentlyContinue
        }

        Context 'Snapshot envelope' {
            It 'declares the format version' {
                $script:surface.formatVersion | Should -Be 1
            }

            It 'stamps capturedAt as a UTC instant' {
                $script:surface.capturedAt | Should -Match '^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z$'
            }

            It 'records who captured the snapshot' {
                $script:surface.capturedBy | Should -BeIn @('ci', 'local')
            }

            It 'carries every contract section' {
                foreach ($section in @('completeness', 'dependencies', 'graphTypes', 'cmdlets', 'cmdletOverrides', 'shim'))
                {
                    $script:surface.Contains($section) | Should -BeTrue -Because "the contract declares a '$section' section"
                }
            }
        }

        Context 'Completeness' {
            It 'reports the workloads that could not be seen' {
                $script:surface.completeness.skippedWorkloads | Should -Contain 'ExchangeOnline'
                $script:surface.completeness.skippedWorkloads | Should -Contain 'SecurityComplianceCenter'
            }

            It 'keeps module names out of the skipped workload list' {
                $script:surface.completeness.skippedWorkloads | Should -Not -Contain 'ExchangeOnlineManagement'
            }

            It 'reports a module that is not installed as skipped' {
                $script:surface.completeness.skippedModules | Should -Contain 'M365DSCApiSurfaceModuleThatIsNotInstalled'
            }

            It 'reports the connect time module as skipped' {
                $script:surface.completeness.skippedModules | Should -Contain 'ExchangeOnlineManagement'
            }

            It 'reports that no tenant was connected' {
                $script:surface.completeness.tenantConnected | Should -BeFalse
            }

            It 'counts the seed types it could not resolve' {
                $script:surface.completeness.graphTypeCoverage.requested | Should -Be 6
                $script:surface.completeness.graphTypeCoverage.captured | Should -Be 5
                $script:surface.completeness.graphTypeCoverage.missing | Should -Be @('beta|testTypeThatDoesNotExist')
            }
        }

        Context 'Graph types' {
            It 'captures every seed entity type' {
                foreach ($key in @('beta:testPolicy', 'beta:testCompliancePolicy', 'beta:testWindowsCompliancePolicy',
                        'beta:testaccess.testProfile', 'v1.0:testGroup'))
                {
                    $script:surface.graphTypes.Contains($key) | Should -BeTrue -Because "'$key' is named by a generatedFrom block"
                }
            }

            It 'records the base type and whether the type is abstract' {
                $script:surface.graphTypes['beta:testCompliancePolicy'].baseType | Should -Be 'entity'
                $script:surface.graphTypes['beta:testCompliancePolicy'].isAbstract | Should -BeTrue
                $script:surface.graphTypes['beta:testWindowsCompliancePolicy'].isAbstract | Should -BeFalse
            }

            It 'flattens the inheritance chain onto the subtype' {
                $properties = $script:surface.graphTypes['beta:testWindowsCompliancePolicy'].properties
                $properties.Contains('bitLockerEnabled') | Should -BeTrue
                $properties.Contains('displayName') | Should -BeTrue -Because 'displayName is declared on the abstract base'
                $properties.Contains('id') | Should -BeTrue -Because 'id is declared on graph.entity'
            }

            It 'keeps the raw vendor type of a scalar property' {
                $script:surface.graphTypes['beta:testPolicy'].properties['displayName'].type | Should -Be 'Edm.String'
            }

            It 'expands an enum inline with all its members' {
                $state = $script:surface.graphTypes['beta:testPolicy'].properties['state']
                $state.type | Should -Be 'testPolicyState'
                $state.enum | Should -Be @('disabled', 'enabled', 'reportOnly')
                $state.Contains('isComplex') | Should -BeFalse
            }

            It 'detects a Collection type as an array' {
                $tags = $script:surface.graphTypes['beta:testPolicy'].properties['tags']
                $tags.type | Should -Be 'Edm.String'
                $tags.isArray | Should -BeTrue
                $script:surface.graphTypes['beta:testPolicy'].properties['displayName'].isArray | Should -BeFalse
            }

            It 'records a complex property by name and follows it' {
                $conditions = $script:surface.graphTypes['beta:testPolicy'].properties['conditions']
                $conditions.type | Should -Be 'testConditionSet'
                $conditions.isComplex | Should -BeTrue
                $script:surface.graphTypes.Contains('beta:testConditionSet') | Should -BeTrue
            }

            It 'follows a complex type reached through another complex type' {
                $script:surface.graphTypes.Contains('beta:testPlatformCondition') | Should -BeTrue
                $platforms = $script:surface.graphTypes['beta:testPlatformCondition'].properties['includePlatforms']
                $platforms.type | Should -Be 'testPlatform'
                $platforms.isArray | Should -BeTrue
                $platforms.enum | Should -Be @('android', 'ios')
            }

            It 'leaves a complex type no resource reaches out of the snapshot' {
                $script:surface.graphTypes.Contains('beta:testUnusedType') | Should -BeFalse
            }

            It 'records a navigation property and captures its target from a seed type' {
                $owners = $script:surface.graphTypes['beta:testPolicy'].properties['owners']
                $owners.type | Should -Be 'testOwner'
                $owners.isNavigation | Should -BeTrue
                $owners.isArray | Should -BeTrue
                $script:surface.graphTypes.Contains('beta:testOwner') | Should -BeTrue
            }

            It 'marks a Computed property as read only' {
                $script:surface.graphTypes['beta:testPolicy'].properties['createdDateTime'].isReadOnly | Should -BeTrue
            }

            It 'marks a Permissions Read property as read only' {
                $script:surface.graphTypes['beta:testPolicy'].properties['signature'].isReadOnly | Should -BeTrue
            }

            It 'keeps an Immutable property configurable' {
                $templateId = $script:surface.graphTypes['beta:testPolicy'].properties['templateId']
                $templateId.isImmutable | Should -BeTrue
                $templateId.isReadOnly | Should -BeFalse
            }

            It 'leaves an unannotated property writable' {
                $displayName = $script:surface.graphTypes['beta:testPolicy'].properties['displayName']
                $displayName.isReadOnly | Should -BeFalse
                $displayName.isImmutable | Should -BeFalse
            }

            It 'keeps the sub-namespace of a type outside microsoft.graph' {
                $script:surface.graphTypes.Contains('beta:testaccess.testProfile') | Should -BeTrue
                $script:surface.graphTypes['beta:testaccess.testProfile'].properties['scope'].type | Should -Be 'testaccess.testScope'
                $script:surface.graphTypes.Contains('beta:testaccess.testScope') | Should -BeTrue
            }

            It 'resolves a base type declared in another namespace' {
                $script:surface.graphTypes['beta:testaccess.testProfile'].baseType | Should -Be 'entity'
                $script:surface.graphTypes['beta:testaccess.testProfile'].properties.Contains('id') | Should -BeTrue
            }

            It 'keeps the two API versions apart' {
                $script:surface.graphTypes.Contains('v1.0:testGroup') | Should -BeTrue
                $script:surface.graphTypes.Contains('beta:testGroup') | Should -BeFalse
            }
        }

        Context 'Cmdlets' {
            It 'merges the routes and the parameter list of a Graph cmdlet' {
                $entry = $script:surface.cmdlets['Get-MgBetaTestPolicy']
                $entry.workload | Should -Be 'MicrosoftGraph'
                $entry.module | Should -Be 'Microsoft.Graph.Beta.Test'
                $entry.apiVersion | Should -Be 'beta'
                $entry.variants | Should -HaveCount 2
                $entry.parameters['Filter'] | Should -Be 'System.String'
                $entry.parameters['All'] | Should -Be 'System.Management.Automation.SwitchParameter'
            }

            It 'stamps the pinned version of the module the cmdlet ships in' {
                $script:surface.cmdlets['Get-MgBetaTestPolicy'].moduleVersion | Should -Be '2.35.1'
            }

            It 'records the SDK route rather than the shim correction' {
                $script:surface.cmdlets['Get-MgBetaTestOverridden'].variants[0].method | Should -Be 'POST'
            }

            It 'records the shim correction next to the cmdlets' {
                $override = $script:surface.cmdletOverrides['Get-MgBetaTestOverridden']
                $override.variants[0].method | Should -Be 'GET'
                $override.reason | Should -Not -BeNullOrEmpty
            }

            It 'captures a workload cmdlet across all its parameter sets' {
                $entry = $script:surface.cmdlets['Set-CsTestThing']
                $entry.module | Should -Be 'M365DSCApiSurfaceTestWorkload'
                $entry.moduleVersion | Should -Be '1.0.0'
                $entry.variants | Should -HaveCount 0
                $entry.parameters['Identity'] | Should -Be 'System.String'
                $entry.parameters['Instance'] | Should -Be 'System.Object' -Because 'Instance sits in a non-default parameter set'
                $entry.parameters['Tags'] | Should -Be 'System.String[]'
            }

            It 'leaves the common parameters out of a workload cmdlet' {
                $script:surface.cmdlets['Set-CsTestThing'].parameters.Contains('Verbose') | Should -BeFalse
                $script:surface.cmdlets['Set-CsTestThing'].parameters.Contains('WhatIf') | Should -BeFalse
            }

            It 'leaves a connect time cmdlet out of the snapshot' {
                $script:surface.cmdlets.Contains('Get-TestMailbox') | Should -BeFalse
            }
        }

        Context 'Shim' {
            It 'captures every function the manifest exports' {
                $script:surface.shim.Keys | Should -HaveCount 5
            }

            It 'leaves the internal helpers out' {
                $script:surface.shim.Contains('Invoke-M365DSCGraphShimGetResource') | Should -BeFalse
                $script:surface.shim.Contains('Get-M365DSCGraphShimAllPages') | Should -BeFalse -Because 'the manifest decides, not the name prefix'
            }

            It 'reads a collection route and an item route off one Get wrapper' {
                $entry = $script:surface.shim['Get-MgBetaTestPolicy']
                $entry.method | Should -Be 'GET'
                $entry.apiVersion | Should -Be 'beta'
                $entry.uri | Should -Be '/testPolicies'
                $entry.itemUri | Should -Be '/testPolicies/{TestPolicyId}'
            }

            It 'reads the literal method off a write wrapper' {
                $script:surface.shim['New-MgBetaTestPolicy'].method | Should -Be 'POST'
                $script:surface.shim['Update-MgBetaTestPolicy'].method | Should -Be 'PATCH'
            }

            It 'reads the route off a delete wrapper' {
                $entry = $script:surface.shim['Remove-MgBetaTestPolicy']
                $entry.method | Should -Be 'DELETE'
                $entry.uri | Should -Be '/testPolicies/{TestPolicyId}'
                $entry.itemUri | Should -BeNullOrEmpty
            }

            It 'records the parameter list of a wrapper' {
                $script:surface.shim['Get-MgBetaTestPolicy'].parameters | Should -Be @('All', 'Filter', 'TestPolicyId')
            }

            It 'keeps the v1.0 routes apart from the beta routes' {
                $script:surface.shim['Get-MgTestGroup'].apiVersion | Should -Be 'v1.0'
                $script:surface.shim['Get-MgTestGroup'].uri | Should -Be '/testGroups'
            }
        }

        Context 'Dependencies' {
            It 'reads the pins of both manifests' {
                $script:surface.dependencies['Microsoft.Graph.Authentication'].pinned | Should -Be '2.35.1'
                $script:surface.dependencies['Microsoft.Graph.Beta.Test'].pinned | Should -Be '2.35.1'
            }

            It 'records which manifest a pin comes from' {
                $script:surface.dependencies['Microsoft.Graph.Authentication'].manifests | Should -Be @('Manifest')
                $script:surface.dependencies['Microsoft.Graph.Beta.Test'].manifests | Should -Be @('DevManifest')
            }

            It 'leaves the latest published version null when the gallery is skipped' {
                $script:surface.dependencies['Microsoft.Graph.Authentication'].latestPublished | Should -BeNullOrEmpty
            }
        }

        Context 'Determinism' {
            BeforeAll {
                $script:first = ConvertTo-M365DSCApiSurfaceJson -Surface $script:surface
                $script:second = ConvertTo-M365DSCApiSurfaceJson -Surface (Get-M365DSCApiSurface @script:surfaceParameters -WarningAction SilentlyContinue)

                $script:strippedFirst = ($script:first -split "`r`n" | Where-Object -FilterScript { $_ -notmatch '"capturedAt"' }) -join "`n"
                $script:strippedSecond = ($script:second -split "`r`n" | Where-Object -FilterScript { $_ -notmatch '"capturedAt"' }) -join "`n"
            }

            It 'produces the same text twice apart from capturedAt' {
                $script:strippedFirst | Should -BeExactly $script:strippedSecond
            }

            It 'orders the type keys ordinally' {
                $keys = [System.String[]] @($script:surface.graphTypes.Keys)
                $sorted = [System.String[]] @($keys)
                [System.Array]::Sort($sorted, [System.StringComparer]::Ordinal)
                $keys | Should -Be $sorted
            }

            It 'orders the cmdlet keys ordinally' {
                $keys = [System.String[]] @($script:surface.cmdlets.Keys)
                $sorted = [System.String[]] @($keys)
                [System.Array]::Sort($sorted, [System.StringComparer]::Ordinal)
                $keys | Should -Be $sorted
            }

            It 'writes CRLF line endings without a trailing blank line' {
                $script:first | Should -Match "`r`n"
                ($script:first -split "`n" | Where-Object -FilterScript { $_ -notmatch "`r$" }) | Should -HaveCount 1
            }
        }
    }

    Describe 'Get-ModuleWorkload' {
        It 'maps <Module> to <Expected>' -TestCases @(
            @{ Module = 'MicrosoftTeams'; Expected = 'MicrosoftTeams' }
            @{ Module = 'PnP.PowerShell'; Expected = 'PnP' }
            @{ Module = 'Microsoft.PowerApps.Administration.PowerShell'; Expected = 'PowerPlatforms' }
            @{ Module = 'Az.Resources'; Expected = 'Azure' }
            @{ Module = 'MSCloudLoginAssistant'; Expected = 'Support' }
            @{ Module = 'DSCParser'; Expected = 'Support' }
        ) {
            Get-ModuleWorkload -Name $Module | Should -Be $Expected
        }
    }

    Describe 'Get-M365DSCOrderedName' {
        It 'sorts ordinally rather than by culture' {
            Get-M365DSCOrderedName -Value @('b', 'A', 'a', 'B') | Should -Be @('A', 'B', 'a', 'b')
        }

        It 'accepts an empty collection' {
            Get-M365DSCOrderedName -Value @() | Should -HaveCount 0
        }
    }

    Describe 'ConvertTo-M365DSCOrderedMap' {
        It 'returns the keys in ordinal order' {
            $map = [System.Collections.Hashtable]::new([System.StringComparer]::Ordinal)
            $map['zebra'] = 1
            $map['Apple'] = 2
            $map['apple'] = 3
            (ConvertTo-M365DSCOrderedMap -Map $map).Keys | Should -Be @('Apple', 'apple', 'zebra')
        }
    }
}
