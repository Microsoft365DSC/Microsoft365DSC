Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath '..\..\..\Utilities\ApiSurface\M365DSCApiSurface.psd1') -Force

InModuleScope -ModuleName 'M365DSCApiSurface' {

    BeforeAll {
        function New-TestProperty
        {
            param
            (
                [System.String] $Type = 'Edm.String',
                [System.Object[]] $Enum = @(),
                [System.Boolean] $IsArray = $false,
                [System.Boolean] $IsComplex = $false,
                [System.Boolean] $IsReadOnly = $false,
                [System.Boolean] $IsFlags = $false,
                [System.Boolean] $IsNavigation = $false
            )

            $entry = [ordered]@{ type = $Type }
            if ($Enum.Count -gt 0) { $entry['enum'] = $Enum; $entry['isFlags'] = $IsFlags }
            if ($IsComplex) { $entry['isComplex'] = $true }
            $entry['isArray'] = $IsArray
            $entry['isNavigation'] = $IsNavigation
            $entry['isReadOnly'] = $IsReadOnly
            $entry['isImmutable'] = $false

            return $entry
        }

        function New-TestSnapshot
        {
            param
            (
                [System.Collections.IDictionary] $GraphType = @{},
                [System.Collections.IDictionary] $Cmdlet = @{},
                [System.Collections.IDictionary] $Override = @{},
                [System.Collections.IDictionary] $Dependency = @{},
                [System.String[]] $SkippedWorkload = @(),
                [System.String[]] $SkippedModule = @()
            )

            return [ordered]@{
                formatVersion   = 1
                capturedAt      = '2026-08-27T00:00:00Z'
                capturedBy      = 'local'
                completeness    = [ordered]@{
                    tenantConnected  = $false
                    skippedWorkloads = $SkippedWorkload
                    skippedModules   = $SkippedModule
                }
                dependencies    = $Dependency
                graphTypes      = $GraphType
                cmdlets         = $Cmdlet
                cmdletOverrides = $Override
                shim            = [ordered]@{}
            }
        }

        function New-TestOrigin
        {
            param
            (
                [System.String] $Resource = 'TestPolicy',
                [System.String] $EntityType = 'testPolicy',
                [System.String] $ODataSubtype = '',
                [System.String] $ApiVersion = 'beta',
                [System.Boolean] $Navigation = $false,
                [System.Object[]] $Command = @()
            )

            return [PSCustomObject]@{
                Resource                    = $Resource
                Workload                    = 'MicrosoftGraph'
                ApiVersion                  = $ApiVersion
                EntityType                  = $EntityType
                ODataSubtype                = $ODataSubtype
                CmdletNoun                  = 'MgBetaTestPolicy'
                CmdletVerb                  = 'New'
                IncludeNavigationProperties = $Navigation
                Commands                    = $Command
            }
        }

        function New-TestKeyword
        {
            param
            (
                [System.String] $Resource = 'TestPolicy',
                [System.Collections.IDictionary] $Property = @{}
            )

            $properties = [ordered]@{}
            foreach ($name in $Property.Keys)
            {
                $definition = $Property[$name]
                $properties[$name] = [PSCustomObject]@{
                    typeConstraint = $definition.typeConstraint
                    values         = @($definition.values)
                    isKey          = [System.Boolean] $definition.isKey
                    name           = $name
                    mandatory      = $false
                }
            }

            return @{ $Resource = [PSCustomObject]@{ resourceName = $Resource; properties = [PSCustomObject] $properties } }
        }

        function Invoke-TestCompare
        {
            param
            (
                [System.Object] $Baseline,
                [System.Object] $Current,
                [System.Object[]] $Origin = @(),
                [System.Collections.IDictionary] $SchemaKeyword = @{},
                [System.Object] $Exclusion,
                [System.Collections.IDictionary] $ExcludedProperty = @{}
            )

            if ($null -eq $Baseline) { $Baseline = $Current }

            return Compare-M365DSCApiSurface -Baseline $Baseline `
                -Current $Current `
                -Origin $Origin `
                -SchemaKeyword $SchemaKeyword `
                -Exclusion $Exclusion `
                -ExcludedProperty $ExcludedProperty `
                -RunDate '2026-08-27'
        }

        $script:containerType = [ordered]@{
            'beta:testPolicy'    = [ordered]@{
                kind       = 'EntityType'
                baseType   = 'entity'
                isAbstract = $false
                properties = [ordered]@{
                    displayName   = New-TestProperty
                    grantControls = New-TestProperty -Type 'grantControls' -IsComplex $true
                }
            }
            'beta:grantControls' = [ordered]@{
                kind       = 'ComplexType'
                isAbstract = $false
                properties = [ordered]@{
                    operator        = New-TestProperty
                    termsOfUse      = New-TestProperty
                    builtInControls = New-TestProperty
                }
            }
        }

        $script:policyType = [ordered]@{
            'beta:testPolicy' = [ordered]@{
                kind       = 'EntityType'
                baseType   = 'entity'
                isAbstract = $false
                properties = [ordered]@{
                    displayName = New-TestProperty
                    state       = New-TestProperty -Type 'testState' -Enum @('disabled', 'enabled')
                }
            }
        }
    }

    Describe 'Compare-M365DSCApiSurface, vendor findings' {
        It 'reports nothing when a snapshot is compared to itself' {
            $snapshot = New-TestSnapshot -GraphType $script:policyType
            (Invoke-TestCompare -Current $snapshot).Findings | Should -HaveCount 0
        }

        It 'reports an added enum member' {
            $before = New-TestSnapshot -GraphType $script:policyType
            $after = New-TestSnapshot -GraphType ([ordered]@{
                    'beta:testPolicy' = [ordered]@{
                        kind       = 'EntityType'
                        baseType   = 'entity'
                        isAbstract = $false
                        properties = [ordered]@{
                            displayName = New-TestProperty
                            state       = New-TestProperty -Type 'testState' -Enum @('disabled', 'enabled', 'reportOnly')
                        }
                    }
                })

            $finding = @((Invoke-TestCompare -Baseline $before -Current $after).Findings | Where-Object { $_.code -eq 'VND-ENUM-MEMBER-ADDED' })
            $finding | Should -HaveCount 1
            $finding[0].to.added | Should -Be @('reportOnly')
            $finding[0].severity | Should -Be 'warning'
        }

        It 'reports an added type property' {
            $before = New-TestSnapshot -GraphType $script:policyType
            $after = New-TestSnapshot -GraphType ([ordered]@{
                    'beta:testPolicy' = [ordered]@{
                        kind       = 'EntityType'
                        baseType   = 'entity'
                        isAbstract = $false
                        properties = [ordered]@{
                            displayName = New-TestProperty
                            state       = New-TestProperty -Type 'testState' -Enum @('disabled', 'enabled')
                            newFlag     = New-TestProperty -Type 'Edm.Boolean'
                        }
                    }
                })

            $finding = @((Invoke-TestCompare -Baseline $before -Current $after).Findings | Where-Object { $_.code -eq 'VND-TYPE-PROP-ADDED' })
            $finding | Should -HaveCount 1
            $finding[0].id | Should -Be 'VND-TYPE-PROP-ADDED:beta:testPolicy:newFlag'
        }

        It 'reports a cmdlet that disappeared and names its callers' {
            $cmdlet = [ordered]@{
                'Get-MgBetaTestPolicy' = [ordered]@{
                    workload = 'MicrosoftGraph'; module = 'Microsoft.Graph.Beta.Test'; moduleVersion = '2.35.1'
                    apiVersion = 'beta'; variants = @(); parameters = [ordered]@{}
                }
            }
            $before = New-TestSnapshot -Cmdlet $cmdlet
            $after = New-TestSnapshot

            $origin = @(New-TestOrigin -Command @([PSCustomObject]@{ Module = 'Microsoft.Graph.Beta.Test'; Name = 'Get-MgBetaTestPolicy' }))
            $finding = @((Invoke-TestCompare -Baseline $before -Current $after -Origin $origin).Findings | Where-Object { $_.code -eq 'VND-CMDLET-REMOVED' })

            $finding | Should -HaveCount 1
            $finding[0].severity | Should -Be 'breaking'
            $finding[0].evidence.calledBy | Should -Be @('TestPolicy')
        }

        It 'reports a cmdlet no resource calls any more as coverage, not as a vendor removal' {
            $cmdlet = [ordered]@{
                'Get-MgBetaTestPolicy' = [ordered]@{
                    workload = 'MicrosoftGraph'; module = 'Microsoft.Graph.Beta.Test'; moduleVersion = '2.35.1'
                    apiVersion = 'beta'; variants = @(); parameters = [ordered]@{}
                }
            }
            $before = New-TestSnapshot -Cmdlet $cmdlet
            $after = New-TestSnapshot

            $result = Invoke-TestCompare -Baseline $before -Current $after -Origin @(New-TestOrigin)

            @($result.Findings | Where-Object { $_.code -eq 'VND-CMDLET-REMOVED' }) | Should -HaveCount 0
            $finding = @($result.Findings | Where-Object { $_.code -eq 'COV-CMDLET-UNUSED' })
            $finding | Should -HaveCount 1
            $finding[0].severity | Should -Be 'info'
            @($finding[0].evidence.calledBy) | Should -HaveCount 0
        }

        It 'reports a route that moved within its own API version' {
            $before = New-TestSnapshot -Cmdlet ([ordered]@{
                    'Get-MgBetaTestPolicy' = [ordered]@{
                        workload = 'MicrosoftGraph'; module = 'M'; moduleVersion = '1.0'; apiVersion = 'beta'
                        variants = @([ordered]@{ method = 'GET'; uri = '/old'; apiVersion = 'beta' }); parameters = [ordered]@{}
                    }
                })
            $after = New-TestSnapshot -Cmdlet ([ordered]@{
                    'Get-MgBetaTestPolicy' = [ordered]@{
                        workload = 'MicrosoftGraph'; module = 'M'; moduleVersion = '1.0'; apiVersion = 'beta'
                        variants = @([ordered]@{ method = 'GET'; uri = '/new'; apiVersion = 'beta' }); parameters = [ordered]@{}
                    }
                })

            @((Invoke-TestCompare -Baseline $before -Current $after).Findings | Where-Object { $_.code -eq 'VND-CMDLET-REROUTED' }) | Should -HaveCount 1
        }

        It 'reports nothing when the moved route matches a shim override' {
            $before = New-TestSnapshot -Cmdlet ([ordered]@{
                    'Get-MgBetaTestPolicy' = [ordered]@{
                        workload = 'MicrosoftGraph'; module = 'M'; moduleVersion = '1.0'; apiVersion = 'beta'
                        variants = @([ordered]@{ method = 'POST'; uri = '/thing'; apiVersion = 'beta' }); parameters = [ordered]@{}
                    }
                })
            $after = New-TestSnapshot -Cmdlet ([ordered]@{
                    'Get-MgBetaTestPolicy' = [ordered]@{
                        workload = 'MicrosoftGraph'; module = 'M'; moduleVersion = '1.0'; apiVersion = 'beta'
                        variants = @([ordered]@{ method = 'GET'; uri = '/thing'; apiVersion = 'beta' }); parameters = [ordered]@{}
                    }
                }) -Override ([ordered]@{
                    'Get-MgBetaTestPolicy' = [ordered]@{
                        reason = 'The beta endpoint answers GET.'
                        variants = @([ordered]@{ method = 'POST'; uri = '/thing'; apiVersion = 'beta' })
                    }
                })

            @((Invoke-TestCompare -Baseline $before -Current $after).Findings | Where-Object { $_.code -eq 'VND-CMDLET-REROUTED' }) | Should -HaveCount 0
        }

        It 'reports nothing when a v1.0 route appears beside the beta route' {
            $before = New-TestSnapshot -Cmdlet ([ordered]@{
                    'Get-MgBetaTestPolicy' = [ordered]@{
                        workload = 'MicrosoftGraph'; module = 'M'; moduleVersion = '1.0'; apiVersion = 'beta'
                        variants = @([ordered]@{ method = 'GET'; uri = '/thing'; apiVersion = 'beta' }); parameters = [ordered]@{}
                    }
                })
            $after = New-TestSnapshot -Cmdlet ([ordered]@{
                    'Get-MgBetaTestPolicy' = [ordered]@{
                        workload = 'MicrosoftGraph'; module = 'M'; moduleVersion = '1.0'; apiVersion = 'beta'
                        variants = @(
                            [ordered]@{ method = 'GET'; uri = '/thing'; apiVersion = 'beta' }
                            [ordered]@{ method = 'GET'; uri = '/thing'; apiVersion = 'v1.0' }
                        ); parameters = [ordered]@{}
                    }
                })

            (Invoke-TestCompare -Baseline $before -Current $after).Findings | Should -HaveCount 0
        }

        It 'reports an added parameter and a changed parameter type' {
            $before = New-TestSnapshot -Cmdlet ([ordered]@{
                    'Set-CsTestThing' = [ordered]@{
                        workload = 'MicrosoftTeams'; module = 'MicrosoftTeams'; moduleVersion = '7.6.0'; apiVersion = $null
                        variants = @(); parameters = [ordered]@{ Identity = 'System.String' }
                    }
                })
            $after = New-TestSnapshot -Cmdlet ([ordered]@{
                    'Set-CsTestThing' = [ordered]@{
                        workload = 'MicrosoftTeams'; module = 'MicrosoftTeams'; moduleVersion = '7.9.0'; apiVersion = $null
                        variants = @(); parameters = [ordered]@{ Identity = 'System.Guid'; Tags = 'System.String[]' }
                    }
                })

            $findings = (Invoke-TestCompare -Baseline $before -Current $after).Findings
            @($findings | Where-Object { $_.code -eq 'VND-PARAM-ADDED' }) | Should -HaveCount 1
            $typeChanged = @($findings | Where-Object { $_.code -eq 'VND-PARAM-TYPECHANGED' })
            $typeChanged | Should -HaveCount 1
            $typeChanged[0].severity | Should -Be 'breaking'
        }

        It 'reports nothing for a module the run could not look at' {
            $before = New-TestSnapshot -Cmdlet ([ordered]@{
                    'Get-Mailbox' = [ordered]@{
                        workload = 'ExchangeOnline'; module = 'ExchangeOnlineManagement'; moduleVersion = '3.9.2'
                        apiVersion = $null; variants = @(); parameters = [ordered]@{}
                    }
                })
            $after = New-TestSnapshot -SkippedWorkload @('ExchangeOnline') -SkippedModule @('ExchangeOnlineManagement')

            (Invoke-TestCompare -Baseline $before -Current $after).Findings | Should -HaveCount 0
        }

        It 'groups a newer dependency version by the size of the jump' {
            $snapshot = New-TestSnapshot -Dependency ([ordered]@{
                    'Az.Resources'   = [ordered]@{ pinned = '9.0.1'; manifests = @('Manifest'); latestPublished = '10.1.0' }
                    'MicrosoftTeams' = [ordered]@{ pinned = '7.6.0'; manifests = @('Manifest'); latestPublished = '7.9.0' }
                    'PnP.PowerShell' = [ordered]@{ pinned = '3.3.0'; manifests = @('Manifest'); latestPublished = '3.3.1' }
                    'Pinned.Current' = [ordered]@{ pinned = '1.0.0'; manifests = @('Manifest'); latestPublished = '1.0.0' }
                })

            $findings = @((Invoke-TestCompare -Current $snapshot).Findings | Where-Object { $_.code -eq 'VND-NEWER-VERSION' })
            $findings | Should -HaveCount 3
            ($findings | Where-Object { $_.id -eq 'VND-NEWER-VERSION:Az.Resources' }).to.jump | Should -Be 'Major'
            ($findings | Where-Object { $_.id -eq 'VND-NEWER-VERSION:MicrosoftTeams' }).to.jump | Should -Be 'Minor'
            ($findings | Where-Object { $_.id -eq 'VND-NEWER-VERSION:PnP.PowerShell' }).to.jump | Should -Be 'Patch'
        }
    }

    Describe 'Compare-M365DSCApiSurface, resource findings' {
        It 'reports a property the resource declares and the vendor does not have' {
            $snapshot = New-TestSnapshot -GraphType $script:policyType
            $keyword = New-TestKeyword -Property @{
                DisplayName = @{ typeConstraint = 'String' }
                Invented    = @{ typeConstraint = 'String' }
            }

            $finding = @((Invoke-TestCompare -Current $snapshot -Origin @(New-TestOrigin) -SchemaKeyword $keyword).Findings |
                    Where-Object { $_.code -eq 'RES-PROP-ORPHANED' })

            $finding | Should -HaveCount 1
            $finding[0].property | Should -Be 'Invented'
            $finding[0].severity | Should -Be 'breaking'
        }

        It 'reports nothing for a property undeclared in both snapshots' {
            $snapshot = New-TestSnapshot -GraphType $script:policyType
            $keyword = New-TestKeyword -Property @{ DisplayName = @{ typeConstraint = 'String' } }

            $result = Invoke-TestCompare -Current $snapshot -Origin @(New-TestOrigin) -SchemaKeyword $keyword
            @($result.Findings | Where-Object { $_.code -eq 'RES-PROP-MISSING' }) | Should -HaveCount 0
            $result.Backlog | Should -Be 1
        }

        It 'reports a property that appeared since the baseline' {
            $before = New-TestSnapshot -GraphType $script:policyType
            $after = New-TestSnapshot -GraphType ([ordered]@{
                    'beta:testPolicy' = [ordered]@{
                        kind = 'EntityType'; baseType = 'entity'; isAbstract = $false
                        properties = [ordered]@{
                            displayName = New-TestProperty
                            state       = New-TestProperty -Type 'testState' -Enum @('disabled', 'enabled')
                            newFlag     = New-TestProperty -Type 'Edm.Boolean'
                        }
                    }
                })
            $keyword = New-TestKeyword -Property @{
                DisplayName = @{ typeConstraint = 'String' }
                State       = @{ typeConstraint = 'String'; values = @('disabled', 'enabled') }
            }

            $finding = @((Invoke-TestCompare -Baseline $before -Current $after -Origin @(New-TestOrigin) -SchemaKeyword $keyword).Findings |
                    Where-Object { $_.code -eq 'RES-PROP-MISSING' })

            $finding | Should -HaveCount 1
            $finding[0].property | Should -Be 'NewFlag'
            $finding[0].autoFixable | Should -BeTrue
        }

        It 'marks a new complex property as not auto-fixable' {
            $before = New-TestSnapshot -GraphType $script:policyType
            $after = New-TestSnapshot -GraphType ([ordered]@{
                    'beta:testPolicy'    = [ordered]@{
                        kind = 'EntityType'; baseType = 'entity'; isAbstract = $false
                        properties = [ordered]@{
                            displayName = New-TestProperty
                            state       = New-TestProperty -Type 'testState' -Enum @('disabled', 'enabled')
                            conditions  = New-TestProperty -Type 'testConditionSet' -IsComplex $true
                        }
                    }
                    'beta:testConditionSet' = [ordered]@{
                        kind = 'ComplexType'; baseType = $null; isAbstract = $false
                        properties = [ordered]@{ includeUsers = New-TestProperty -IsArray $true }
                    }
                })
            $keyword = New-TestKeyword -Property @{
                DisplayName = @{ typeConstraint = 'String' }
                State       = @{ typeConstraint = 'String'; values = @('disabled', 'enabled') }
            }

            $finding = @((Invoke-TestCompare -Baseline $before -Current $after -Origin @(New-TestOrigin) -SchemaKeyword $keyword).Findings |
                    Where-Object { $_.code -eq 'RES-PROP-MISSING' -and $_.property -eq 'Conditions' })

            $finding | Should -HaveCount 1
            $finding[0].autoFixable | Should -BeFalse
        }

        It 'reports a new read-only property as read-only rather than missing' {
            $before = New-TestSnapshot -GraphType $script:policyType
            $after = New-TestSnapshot -GraphType ([ordered]@{
                    'beta:testPolicy' = [ordered]@{
                        kind = 'EntityType'; baseType = 'entity'; isAbstract = $false
                        properties = [ordered]@{
                            displayName = New-TestProperty
                            state       = New-TestProperty -Type 'testState' -Enum @('disabled', 'enabled')
                            createdOn   = New-TestProperty -Type 'Edm.DateTimeOffset' -IsReadOnly $true
                        }
                    }
                })
            $keyword = New-TestKeyword -Property @{
                DisplayName = @{ typeConstraint = 'String' }
                State       = @{ typeConstraint = 'String'; values = @('disabled', 'enabled') }
            }

            $findings = (Invoke-TestCompare -Baseline $before -Current $after -Origin @(New-TestOrigin) -SchemaKeyword $keyword).Findings
            @($findings | Where-Object { $_.code -eq 'RES-PROP-READONLY' }) | Should -HaveCount 1
            @($findings | Where-Object { $_.code -eq 'RES-PROP-MISSING' }) | Should -HaveCount 0
        }

        It 'resolves a property the resource flattened out of a complex type' {
            $snapshot = New-TestSnapshot -GraphType ([ordered]@{
                    'beta:testPolicy'    = [ordered]@{
                        kind = 'EntityType'; baseType = 'entity'; isAbstract = $false
                        properties = [ordered]@{ conditions = New-TestProperty -Type 'testConditionSet' -IsComplex $true }
                    }
                    'beta:testConditionSet' = [ordered]@{
                        kind = 'ComplexType'; baseType = $null; isAbstract = $false
                        properties = [ordered]@{ includeUsers = New-TestProperty -IsArray $true }
                    }
                })
            $keyword = New-TestKeyword -Property @{ IncludeUsers = @{ typeConstraint = 'StringArray' } }

            @((Invoke-TestCompare -Current $snapshot -Origin @(New-TestOrigin) -SchemaKeyword $keyword).Findings |
                    Where-Object { $_.code -eq 'RES-PROP-ORPHANED' }) | Should -HaveCount 0
        }

        It 'reports a typeConstraint that disagrees with the vendor type' {
            $snapshot = New-TestSnapshot -GraphType ([ordered]@{
                    'beta:testPolicy' = [ordered]@{
                        kind = 'EntityType'; baseType = 'entity'; isAbstract = $false
                        properties = [ordered]@{ retryCount = New-TestProperty -Type 'Edm.Int32' }
                    }
                })
            $keyword = New-TestKeyword -Property @{ RetryCount = @{ typeConstraint = 'String' } }

            $finding = @((Invoke-TestCompare -Current $snapshot -Origin @(New-TestOrigin) -SchemaKeyword $keyword).Findings |
                    Where-Object { $_.code -eq 'RES-TYPE-MISMATCH' })

            $finding | Should -HaveCount 1
            $finding[0].severity | Should -Be 'breaking'
        }

        It 'accepts an array constraint on a flags enum' {
            $snapshot = New-TestSnapshot -GraphType ([ordered]@{
                    'beta:testPolicy' = [ordered]@{
                        kind = 'EntityType'; baseType = 'entity'; isAbstract = $false
                        properties = [ordered]@{ scope = New-TestProperty -Type 'testScope' -Enum @('a', 'b') -IsFlags $true }
                    }
                })
            $keyword = New-TestKeyword -Property @{ Scope = @{ typeConstraint = 'StringArray'; values = @('a', 'b') } }

            @((Invoke-TestCompare -Current $snapshot -Origin @(New-TestOrigin) -SchemaKeyword $keyword).Findings |
                    Where-Object { $_.code -eq 'RES-TYPE-MISMATCH' }) | Should -HaveCount 0
        }

        It 'reports a ValidateSet that is a strict subset of the vendor enum' {
            $snapshot = New-TestSnapshot -GraphType $script:policyType
            $keyword = New-TestKeyword -Property @{
                DisplayName = @{ typeConstraint = 'String' }
                State       = @{ typeConstraint = 'String'; values = @('enabled') }
            }

            $finding = @((Invoke-TestCompare -Current $snapshot -Origin @(New-TestOrigin) -SchemaKeyword $keyword).Findings |
                    Where-Object { $_.code -eq 'RES-ENUM-STALE' })

            $finding | Should -HaveCount 1
            $finding[0].to.added | Should -Be @('disabled')
            $finding[0].autoFixable | Should -BeTrue
            $finding[0].evidence.match.level | Should -Be 0
            $finding[0].evidence.match.isReadOnly | Should -BeFalse
        }

        It 'refuses an unattended fix for a ValidateSet matched below the entity' {
            $snapshot = New-TestSnapshot -GraphType ([ordered]@{
                    'beta:testPolicy' = [ordered]@{
                        kind = 'EntityType'; baseType = 'entity'; isAbstract = $false
                        properties = [ordered]@{
                            displayName = New-TestProperty
                            reporting   = New-TestProperty -Type 'reportingSettings' -IsComplex $true
                        }
                    }
                    'beta:reportingSettings' = [ordered]@{
                        kind = 'ComplexType'; isAbstract = $false
                        properties = [ordered]@{
                            state = New-TestProperty -Type 'testState' -Enum @('default', 'disabled', 'enabled')
                        }
                    }
                })
            $keyword = New-TestKeyword -Property @{
                DisplayName = @{ typeConstraint = 'String' }
                State       = @{ typeConstraint = 'String'; values = @('enabled', 'disabled') }
            }

            $finding = @((Invoke-TestCompare -Current $snapshot -Origin @(New-TestOrigin) -SchemaKeyword $keyword).Findings |
                    Where-Object { $_.code -eq 'RES-ENUM-STALE' })

            $finding | Should -HaveCount 1
            $finding[0].autoFixable | Should -BeFalse
            $finding[0].evidence.source | Should -Be 'csdl:beta/testPolicy/reporting.state'
            $finding[0].evidence.match.level | Should -Be 1
        }

        It 'refuses an unattended fix for a read-only vendor enum' {
            $snapshot = New-TestSnapshot -GraphType ([ordered]@{
                    'beta:testPolicy' = [ordered]@{
                        kind = 'EntityType'; baseType = 'entity'; isAbstract = $false
                        properties = [ordered]@{
                            displayName = New-TestProperty
                            state       = New-TestProperty -Type 'testState' -Enum @('disabled', 'enabled') -IsReadOnly $true
                        }
                    }
                })
            $keyword = New-TestKeyword -Property @{
                DisplayName = @{ typeConstraint = 'String' }
                State       = @{ typeConstraint = 'String'; values = @('enabled') }
            }

            $finding = @((Invoke-TestCompare -Current $snapshot -Origin @(New-TestOrigin) -SchemaKeyword $keyword).Findings |
                    Where-Object { $_.code -eq 'RES-ENUM-STALE' })

            $finding | Should -HaveCount 1
            $finding[0].autoFixable | Should -BeFalse
            $finding[0].evidence.match.isReadOnly | Should -BeTrue
        }

        It 'reports nothing for a resource on a non-comparable entity type' {
            $snapshot = New-TestSnapshot -GraphType ([ordered]@{
                    'beta:deviceManagementConfigurationPolicy' = [ordered]@{
                        kind = 'EntityType'; baseType = 'entity'; isAbstract = $false
                        properties = [ordered]@{ name = New-TestProperty }
                    }
                })
            $origin = @(New-TestOrigin -Resource 'IntuneCatalog' -EntityType 'deviceManagementConfigurationPolicy')
            $keyword = New-TestKeyword -Resource 'IntuneCatalog' -Property @{ Invented = @{ typeConstraint = 'String' } }
            $exclusion = [PSCustomObject]@{
                nonComparableEntityTypes = @([PSCustomObject]@{ entityType = 'deviceManagementConfigurationPolicy'; reason = 'settings catalog' })
            }

            $result = Invoke-TestCompare -Current $snapshot -Origin $origin -SchemaKeyword $keyword -Exclusion $exclusion
            $result.Findings | Should -HaveCount 0
            $result.Summary.compared | Should -Be 0
            $result.Summary.skipped | Should -Be 1
            $result.Coverage[0].reason | Should -BeLike '*is served by another surface*'
        }

        It 'reports nothing for a resource with no resolved entityType' {
            $snapshot = New-TestSnapshot -GraphType $script:policyType
            $origin = @(New-TestOrigin -Resource 'RestOnly' -EntityType '')

            $result = Invoke-TestCompare -Current $snapshot -Origin $origin
            $result.Findings | Should -HaveCount 0
            $result.Coverage[0].reason | Should -Be 'no resolved entityType'
        }

        It 'suppresses a finding on an excluded property' {
            $snapshot = New-TestSnapshot -GraphType $script:policyType
            $keyword = New-TestKeyword -Property @{
                DisplayName = @{ typeConstraint = 'String' }
                Invented    = @{ typeConstraint = 'String' }
            }
            $excluded = @{ TestPolicy = @([PSCustomObject]@{ name = 'Invented'; reason = 'NotConfigurable' }) }

            @((Invoke-TestCompare -Current $snapshot -Origin @(New-TestOrigin) -SchemaKeyword $keyword -ExcludedProperty $excluded).Findings |
                    Where-Object { $_.property -eq 'Invented' }) | Should -HaveCount 0
        }

        It 'keeps a Deferred exclusion visible at info' {
            $snapshot = New-TestSnapshot -GraphType $script:policyType
            $keyword = New-TestKeyword -Property @{
                DisplayName = @{ typeConstraint = 'String' }
                Invented    = @{ typeConstraint = 'String' }
            }
            $excluded = @{ TestPolicy = @([PSCustomObject]@{ name = 'Invented'; reason = 'Deferred' }) }

            $findings = @((Invoke-TestCompare -Current $snapshot -Origin @(New-TestOrigin) -SchemaKeyword $keyword -ExcludedProperty $excluded).Findings |
                    Where-Object { $_.property -eq 'Invented' })
            $findings | Should -HaveCount 1
            $findings[0].severity | Should -Be 'info'
        }

        It 'takes auto-fixability away from a Deferred exclusion' {
            $snapshot = New-TestSnapshot -GraphType $script:policyType
            $keyword = New-TestKeyword -Property @{
                DisplayName = @{ typeConstraint = 'String' }
                State       = @{ typeConstraint = 'String'; values = @('enabled') }
            }
            $excluded = @{ TestPolicy = @([PSCustomObject]@{ name = 'State'; reason = 'Deferred' }) }

            $finding = @((Invoke-TestCompare -Current $snapshot -Origin @(New-TestOrigin) -SchemaKeyword $keyword -ExcludedProperty $excluded).Findings |
                    Where-Object { $_.code -eq 'RES-ENUM-STALE' })

            $finding | Should -HaveCount 1
            $finding[0].severity | Should -Be 'info'
            $finding[0].autoFixable | Should -BeFalse
        }

        It 'takes auto-fixability away from a Deferred missing property' {
            $before = New-TestSnapshot -GraphType $script:policyType
            $after = New-TestSnapshot -GraphType ([ordered]@{
                    'beta:testPolicy' = [ordered]@{
                        kind = 'EntityType'; baseType = 'entity'; isAbstract = $false
                        properties = [ordered]@{
                            displayName = New-TestProperty
                            state       = New-TestProperty -Type 'testState' -Enum @('disabled', 'enabled')
                            newFlag     = New-TestProperty -Type 'Edm.Boolean'
                        }
                    }
                })
            $keyword = New-TestKeyword -Property @{
                DisplayName = @{ typeConstraint = 'String' }
                State       = @{ typeConstraint = 'String'; values = @('disabled', 'enabled') }
            }
            $excluded = @{ TestPolicy = @([PSCustomObject]@{ name = 'NewFlag'; reason = 'Deferred' }) }

            $finding = @((Invoke-TestCompare -Baseline $before -Current $after -Origin @(New-TestOrigin) -SchemaKeyword $keyword -ExcludedProperty $excluded).Findings |
                    Where-Object { $_.code -eq 'RES-PROP-MISSING' })

            $finding | Should -HaveCount 1
            $finding[0].property | Should -Be 'NewFlag'
            $finding[0].severity | Should -Be 'info'
            $finding[0].autoFixable | Should -BeFalse
        }

        It 'classifies a service managed property that the CSDL leaves writable as read only' {
            $before = New-TestSnapshot -GraphType $script:policyType
            $after = New-TestSnapshot -GraphType ([ordered]@{
                    'beta:testPolicy' = [ordered]@{
                        kind = 'EntityType'; baseType = 'entity'; isAbstract = $false
                        properties = [ordered]@{
                            displayName             = New-TestProperty
                            state                   = New-TestProperty -Type 'testState' -Enum @('disabled', 'enabled')
                            committedContentVersion = New-TestProperty
                        }
                    }
                })
            $keyword = New-TestKeyword -Property @{
                DisplayName = @{ typeConstraint = 'String' }
                State       = @{ typeConstraint = 'String'; values = @('disabled', 'enabled') }
            }

            $finding = @((Invoke-TestCompare -Baseline $before -Current $after -Origin @(New-TestOrigin) -SchemaKeyword $keyword).Findings |
                    Where-Object { $_.code -eq 'RES-PROP-READONLY' })

            $finding | Should -HaveCount 1
            $finding[0].property | Should -Be 'CommittedContentVersion'
            $finding[0].autoFixable | Should -BeFalse
        }

        It 'drops an Accepted exclusion from the report' {
            $snapshot = New-TestSnapshot -GraphType $script:policyType
            $keyword = New-TestKeyword -Property @{
                DisplayName = @{ typeConstraint = 'String' }
                Invented    = @{ typeConstraint = 'String' }
            }
            $excluded = @{ TestPolicy = @([PSCustomObject]@{ name = 'Invented'; reason = 'Accepted' }) }

            @((Invoke-TestCompare -Current $snapshot -Origin @(New-TestOrigin) -SchemaKeyword $keyword -ExcludedProperty $excluded).Findings |
                    Where-Object { $_.property -eq 'Invented' }) | Should -HaveCount 0
        }

        It 'reports a property already in the baseline as backlog rather than as a gap' {
            $snapshot = New-TestSnapshot -GraphType $script:policyType
            $keyword = New-TestKeyword -Property @{ DisplayName = @{ typeConstraint = 'String' } }

            $result = Invoke-TestCompare -Current $snapshot -Origin @(New-TestOrigin) -SchemaKeyword $keyword
            $finding = @($result.Findings | Where-Object { $_.property -eq 'State' })

            $finding | Should -HaveCount 1
            $finding[0].code | Should -Be 'RES-PROP-BACKLOG'
            $finding[0].severity | Should -Be 'info'
            $finding[0].autoFixable | Should -BeFalse
            $result.Backlog | Should -Be 1
        }

        It 'reports a sibling of a member the resource already flattened' {
            $snapshot = New-TestSnapshot -GraphType $script:containerType
            $keyword = New-TestKeyword -Property @{
                DisplayName = @{ typeConstraint = 'String' }
                Operator    = @{ typeConstraint = 'String' }
                TermsOfUse  = @{ typeConstraint = 'String' }
            }

            $finding = @((Invoke-TestCompare -Current $snapshot -Origin @(New-TestOrigin) -SchemaKeyword $keyword).Findings |
                    Where-Object { $_.code -eq 'RES-PROP-NESTED' })

            $finding | Should -HaveCount 1
            $finding[0].property | Should -Be 'GrantControlsBuiltInControls'
            $finding[0].autoFixable | Should -BeFalse
            $finding[0].evidence.source | Should -Be 'csdl:beta/testPolicy/grantControls.builtInControls'
            $finding[0].evidence.flattenedAs | Should -Be 'builtInControls'
        }

        It 'suppresses a nested member excluded under its leaf name' {
            $snapshot = New-TestSnapshot -GraphType $script:containerType
            $keyword = New-TestKeyword -Property @{
                DisplayName = @{ typeConstraint = 'String' }
                Operator    = @{ typeConstraint = 'String' }
                TermsOfUse  = @{ typeConstraint = 'String' }
            }
            $excluded = @{ TestPolicy = @([PSCustomObject]@{ name = 'BuiltInControls'; reason = 'Accepted' }) }

            @((Invoke-TestCompare -Current $snapshot -Origin @(New-TestOrigin) -SchemaKeyword $keyword -ExcludedProperty $excluded).Findings |
                    Where-Object { $_.code -eq 'RES-PROP-NESTED' }) | Should -HaveCount 0
        }

        It 'treats a single matched member as a lookup rather than as flattening' {
            $snapshot = New-TestSnapshot -GraphType $script:containerType
            $keyword = New-TestKeyword -Property @{
                DisplayName = @{ typeConstraint = 'String' }
                Operator    = @{ typeConstraint = 'String' }
            }

            @((Invoke-TestCompare -Current $snapshot -Origin @(New-TestOrigin) -SchemaKeyword $keyword).Findings |
                    Where-Object { $_.code -eq 'RES-PROP-NESTED' }) | Should -HaveCount 0
        }

        It 'takes a vendorPath on an exclusion as proof the resource covers the member' {
            $snapshot = New-TestSnapshot -GraphType $script:containerType
            $keyword = New-TestKeyword -Property @{
                DisplayName = @{ typeConstraint = 'String' }
                Operator    = @{ typeConstraint = 'String' }
                Renamed     = @{ typeConstraint = 'String' }
            }
            $excluded = @{ TestPolicy = @([PSCustomObject]@{
                        name       = 'Renamed'
                        reason     = 'Accepted'
                        vendorPath = 'grantControls.termsOfUse'
                    }) }

            $finding = @((Invoke-TestCompare -Current $snapshot -Origin @(New-TestOrigin) -SchemaKeyword $keyword -ExcludedProperty $excluded).Findings |
                    Where-Object { $_.code -eq 'RES-PROP-NESTED' })

            $finding | Should -HaveCount 1
            $finding[0].property | Should -Be 'GrantControlsBuiltInControls'
        }

        It 'leaves a member another resource on the same type declares out of the report' {
            $snapshot = New-TestSnapshot -GraphType $script:containerType
            $keyword = New-TestKeyword -Property @{
                DisplayName = @{ typeConstraint = 'String' }
                Operator    = @{ typeConstraint = 'String' }
                TermsOfUse  = @{ typeConstraint = 'String' }
            }
            $keyword['SiblingPolicy'] = [PSCustomObject]@{
                resourceName = 'SiblingPolicy'
                properties   = [PSCustomObject][ordered]@{
                    BuiltInControls = [PSCustomObject]@{ typeConstraint = 'StringArray'; values = @(); isKey = $false; name = 'BuiltInControls'; mandatory = $false }
                }
            }

            $origin = @((New-TestOrigin), (New-TestOrigin -Resource 'SiblingPolicy'))

            @((Invoke-TestCompare -Current $snapshot -Origin $origin -SchemaKeyword $keyword).Findings |
                    Where-Object { $_.code -eq 'RES-PROP-NESTED' }) | Should -HaveCount 0
        }

        It 'stays silent inside a container the resource ignores' {
            $snapshot = New-TestSnapshot -GraphType $script:containerType
            $keyword = New-TestKeyword -Property @{ DisplayName = @{ typeConstraint = 'String' } }

            @((Invoke-TestCompare -Current $snapshot -Origin @(New-TestOrigin) -SchemaKeyword $keyword).Findings |
                    Where-Object { $_.code -eq 'RES-PROP-NESTED' }) | Should -HaveCount 0
        }

        It 'leaves a read-only nested member out of the report' {
            $snapshot = New-TestSnapshot -GraphType ([ordered]@{
                    'beta:testPolicy' = [ordered]@{
                        kind = 'EntityType'; baseType = 'entity'; isAbstract = $false
                        properties = [ordered]@{
                            displayName   = New-TestProperty
                            grantControls = New-TestProperty -Type 'grantControls' -IsComplex $true
                        }
                    }
                    'beta:grantControls' = [ordered]@{
                        kind = 'ComplexType'; isAbstract = $false
                        properties = [ordered]@{
                            operator        = New-TestProperty
                            termsOfUse      = New-TestProperty
                            builtInControls = New-TestProperty -IsReadOnly $true
                        }
                    }
                })
            $keyword = New-TestKeyword -Property @{
                DisplayName = @{ typeConstraint = 'String' }
                Operator    = @{ typeConstraint = 'String' }
                TermsOfUse  = @{ typeConstraint = 'String' }
            }

            @((Invoke-TestCompare -Current $snapshot -Origin @(New-TestOrigin) -SchemaKeyword $keyword).Findings |
                    Where-Object { $_.code -eq 'RES-PROP-NESTED' }) | Should -HaveCount 0
        }

        It 'raises a nested finding to warning when the baseline did not hold it' {
            $before = New-TestSnapshot -GraphType ([ordered]@{
                    'beta:testPolicy' = [ordered]@{
                        kind = 'EntityType'; baseType = 'entity'; isAbstract = $false
                        properties = [ordered]@{
                            displayName   = New-TestProperty
                            grantControls = New-TestProperty -Type 'grantControls' -IsComplex $true
                        }
                    }
                    'beta:grantControls' = [ordered]@{
                        kind = 'ComplexType'; isAbstract = $false
                        properties = [ordered]@{ operator = New-TestProperty; termsOfUse = New-TestProperty }
                    }
                })
            $keyword = New-TestKeyword -Property @{
                DisplayName = @{ typeConstraint = 'String' }
                Operator    = @{ typeConstraint = 'String' }
                TermsOfUse  = @{ typeConstraint = 'String' }
            }

            $finding = @((Invoke-TestCompare -Baseline $before -Current (New-TestSnapshot -GraphType $script:containerType) -Origin @(New-TestOrigin) -SchemaKeyword $keyword).Findings |
                    Where-Object { $_.code -eq 'RES-PROP-NESTED' })

            $finding | Should -HaveCount 1
            $finding[0].severity | Should -Be 'warning'
            $finding[0].evidence.seenBefore | Should -BeFalse
        }

        It 'leaves the backlog count to the entity level' {
            $snapshot = New-TestSnapshot -GraphType $script:containerType
            $keyword = New-TestKeyword -Property @{
                DisplayName = @{ typeConstraint = 'String' }
                Operator    = @{ typeConstraint = 'String' }
                TermsOfUse  = @{ typeConstraint = 'String' }
            }

            (Invoke-TestCompare -Current $snapshot -Origin @(New-TestOrigin) -SchemaKeyword $keyword).Backlog | Should -Be 1
        }

        It 'classifies an author stamp the CSDL leaves writable as read only' {
            $snapshot = New-TestSnapshot -GraphType ([ordered]@{
                    'beta:testPolicy' = [ordered]@{
                        kind = 'EntityType'; baseType = 'entity'; isAbstract = $false
                        properties = [ordered]@{
                            displayName    = New-TestProperty
                            createdBy      = New-TestProperty -Type 'identitySet' -IsComplex $true
                            lastModifiedBy = New-TestProperty -Type 'identitySet' -IsComplex $true
                        }
                    }
                })
            $keyword = New-TestKeyword -Property @{ DisplayName = @{ typeConstraint = 'String' } }

            $finding = @((Invoke-TestCompare -Current $snapshot -Origin @(New-TestOrigin) -SchemaKeyword $keyword).Findings |
                    Where-Object { $_.property -in @('CreatedBy', 'LastModifiedBy') })

            $finding | Should -HaveCount 2
            @($finding | Where-Object { $_.code -ne 'RES-PROP-READONLY' }) | Should -HaveCount 0
        }

        It 'keeps a read-only property on the read-only code even when the baseline already held it' {
            $snapshot = New-TestSnapshot -GraphType ([ordered]@{
                    'beta:testPolicy' = [ordered]@{
                        kind = 'EntityType'; baseType = 'entity'; isAbstract = $false
                        properties = [ordered]@{
                            displayName     = New-TestProperty
                            createdDateTime = New-TestProperty -Type 'Edm.DateTimeOffset' -IsReadOnly $true
                        }
                    }
                })
            $keyword = New-TestKeyword -Property @{ DisplayName = @{ typeConstraint = 'String' } }

            $finding = @((Invoke-TestCompare -Current $snapshot -Origin @(New-TestOrigin) -SchemaKeyword $keyword).Findings |
                    Where-Object { $_.property -eq 'CreatedDateTime' })

            $finding | Should -HaveCount 1
            $finding[0].code | Should -Be 'RES-PROP-READONLY'
        }

        It 'drops a read-only property the global list names' {
            $snapshot = New-TestSnapshot -GraphType ([ordered]@{
                    'beta:testPolicy' = [ordered]@{
                        kind = 'EntityType'; baseType = 'entity'; isAbstract = $false
                        properties = [ordered]@{
                            displayName     = New-TestProperty
                            createdDateTime = New-TestProperty -Type 'Edm.DateTimeOffset' -IsReadOnly $true
                        }
                    }
                })
            $keyword = New-TestKeyword -Property @{ DisplayName = @{ typeConstraint = 'String' } }
            $exclusion = [PSCustomObject]@{
                globalReadOnlyProperties = @([PSCustomObject]@{ name = 'CreatedDateTime'; reason = 'ReadOnly' })
            }

            @((Invoke-TestCompare -Current $snapshot -Origin @(New-TestOrigin) -SchemaKeyword $keyword -Exclusion $exclusion).Findings |
                    Where-Object { $_.property -eq 'CreatedDateTime' }) | Should -HaveCount 0
        }

        It 'keeps a globally listed name on the report where the type leaves it writable' {
            $snapshot = New-TestSnapshot -GraphType ([ordered]@{
                    'beta:testPolicy' = [ordered]@{
                        kind = 'EntityType'; baseType = 'entity'; isAbstract = $false
                        properties = [ordered]@{
                            displayName       = New-TestProperty
                            supportsScopeTags = New-TestProperty -Type 'Edm.Boolean'
                        }
                    }
                })
            $keyword = New-TestKeyword -Property @{ DisplayName = @{ typeConstraint = 'String' } }
            $exclusion = [PSCustomObject]@{
                globalReadOnlyProperties = @([PSCustomObject]@{ name = 'SupportsScopeTags'; reason = 'ReadOnly' })
            }

            $finding = @((Invoke-TestCompare -Current $snapshot -Origin @(New-TestOrigin) -SchemaKeyword $keyword -Exclusion $exclusion).Findings |
                    Where-Object { $_.property -eq 'SupportsScopeTags' })

            $finding | Should -HaveCount 1
            $finding[0].code | Should -Be 'RES-PROP-BACKLOG'
        }
    }

    Describe 'Finding identity' {
        It 'produces the same ids twice over identical input' {
            $snapshot = New-TestSnapshot -GraphType $script:policyType
            $keyword = New-TestKeyword -Property @{ DisplayName = @{ typeConstraint = 'String' }; Invented = @{ typeConstraint = 'String' } }

            $first = (Invoke-TestCompare -Current $snapshot -Origin @(New-TestOrigin) -SchemaKeyword $keyword).Findings.id
            $second = (Invoke-TestCompare -Current $snapshot -Origin @(New-TestOrigin) -SchemaKeyword $keyword).Findings.id

            Compare-Object -ReferenceObject $first -DifferenceObject $second | Should -BeNullOrEmpty
        }

        It 'orders findings by id' {
            $snapshot = New-TestSnapshot -Dependency ([ordered]@{
                    'Zeta.Module'  = [ordered]@{ pinned = '1.0.0'; manifests = @('Manifest'); latestPublished = '2.0.0' }
                    'Alpha.Module' = [ordered]@{ pinned = '1.0.0'; manifests = @('Manifest'); latestPublished = '2.0.0' }
                })

            $ids = (Invoke-TestCompare -Current $snapshot).Findings.id
            $ids | Should -Be @('VND-NEWER-VERSION:Alpha.Module', 'VND-NEWER-VERSION:Zeta.Module')
        }

        It 'carries firstSeen forward for a finding that was already reported' {
            $snapshot = New-TestSnapshot -Dependency ([ordered]@{
                    'Az.Resources' = [ordered]@{ pinned = '9.0.1'; manifests = @('Manifest'); latestPublished = '10.1.0' }
                })
            $previous = @([PSCustomObject]@{ id = 'VND-NEWER-VERSION:Az.Resources'; firstSeen = '2026-01-01' })

            $findings = (Compare-M365DSCApiSurface -Baseline $snapshot -Current $snapshot -PreviousFinding $previous -RunDate '2026-08-27').Findings
            $findings[0].firstSeen | Should -Be '2026-01-01'
        }

        It 'stamps the run date on a finding seen for the first time' {
            $snapshot = New-TestSnapshot -Dependency ([ordered]@{
                    'Az.Resources' = [ordered]@{ pinned = '9.0.1'; manifests = @('Manifest'); latestPublished = '10.1.0' }
                })

            (Invoke-TestCompare -Current $snapshot).Findings[0].firstSeen | Should -Be '2026-08-27'
        }

        It 'throws on a finding code that is not in the table' {
            { Resolve-FindingSeverity -Code 'VND-INVENTED' } | Should -Throw
        }
    }

    Describe 'Resolve-PropertyName' {
        BeforeAll {
            $script:vendor = [System.Collections.Specialized.OrderedDictionary]::new([System.StringComparer]::Ordinal)
            $script:vendor['displayName'] = [ordered]@{ Name = 'displayName'; Path = 'displayName' }
            $script:vendor['@odata.type'] = [ordered]@{ Name = '@odata.type'; Path = '@odata.type' }
            $script:vendor['mdmAuthority'] = [ordered]@{ Name = 'mdmAuthority'; Path = 'mdmAuthority'; Level = 0 }
            $script:vendor['sessionControls.signInFrequency.isEnabled'] = [ordered]@{
                Name = 'isEnabled'; Path = 'sessionControls.signInFrequency.isEnabled'; Level = 2
            }
            $script:vendor['sessionControls.persistentBrowser.mode'] = [ordered]@{
                Name = 'mode'; Path = 'sessionControls.persistentBrowser.mode'; Level = 2
            }
            $script:vendor['grantControls.operator'] = [ordered]@{
                Name = 'operator'; Path = 'grantControls.operator'; Level = 1
            }
        }

        It 'matches <Name> by the <Rule> rule' -TestCases @(
            @{ Name = 'DisplayName'; Rule = 'Camel' }
            @{ Name = 'ODataType'; Rule = 'ODataType' }
            @{ Name = 'MDMAuthority'; Rule = 'Acronym' }
            @{ Name = 'SignInFrequencyIsEnabled'; Rule = 'FlattenedPath' }
            @{ Name = 'PersistentBrowserMode'; Rule = 'FlattenedPath' }
            @{ Name = 'GrantControlOperator'; Rule = 'FlattenedPathSingular' }
        ) {
            $result = Resolve-PropertyName -Name $Name -VendorProperty $script:vendor
            $result.Matched | Should -BeTrue
            $result.Rule | Should -Be $Rule
        }

        It 'matches a singular DSC name against a plural vendor collection' {
            $vendor = [System.Collections.Specialized.OrderedDictionary]::new([System.StringComparer]::Ordinal)
            $vendor['tokenLifetimePolicies'] = [ordered]@{
                Name = 'tokenLifetimePolicies'; Path = 'tokenLifetimePolicies'; Level = 0
            }

            $result = Resolve-PropertyName -Name 'TokenLifetimePolicy' -VendorProperty $vendor
            $result.Matched | Should -BeTrue
            $result.Rule | Should -Be 'Plural'
            $result.VendorName | Should -BeExactly 'tokenLifetimePolicies'
        }

        It 'pluralizes <Name> to <Expected>' -TestCases @(
            @{ Name = 'TokenLifetimePolicy'; Expected = 'TokenLifetimePolicies' }
            @{ Name = 'Key'; Expected = 'Keys' }
            @{ Name = 'ServerCollection'; Expected = 'ServerCollections' }
            @{ Name = 'Roles'; Expected = 'Roles' }
            @{ Name = 'Branch'; Expected = 'Branch' }
        ) {
            Get-PluralName -Name $Name | Should -BeExactly $Expected
        }

        It 'prefers an exact vendor name over its plural' {
            $vendor = [System.Collections.Specialized.OrderedDictionary]::new([System.StringComparer]::Ordinal)
            $vendor['policy'] = [ordered]@{ Name = 'policy'; Path = 'policy'; Level = 0 }
            $vendor['policies'] = [ordered]@{ Name = 'policies'; Path = 'policies'; Level = 0 }

            $result = Resolve-PropertyName -Name 'Policy' -VendorProperty $vendor
            $result.Rule | Should -Be 'Camel'
            $result.VendorName | Should -BeExactly 'policy'
        }

        It 'resolves a flattened name that drops the root container to its full path' {
            $result = Resolve-PropertyName -Name 'SignInFrequencyIsEnabled' -VendorProperty $script:vendor
            $result.VendorName | Should -BeExactly 'sessionControls.signInFrequency.isEnabled'
        }

        It 'prefers the shallowest path when a leaf name repeats' {
            $vendor = [System.Collections.Specialized.OrderedDictionary]::new([System.StringComparer]::Ordinal)
            $vendor['nested.state'] = [ordered]@{ Name = 'state'; Path = 'nested.state'; Level = 1 }
            $vendor['state'] = [ordered]@{ Name = 'state'; Path = 'state'; Level = 0 }

            (Resolve-PropertyName -Name 'State' -VendorProperty $vendor).VendorName | Should -BeExactly 'state'
        }

        It 'reports no match for a name the vendor does not have' {
            (Resolve-PropertyName -Name 'Invented' -VendorProperty $script:vendor).Matched | Should -BeFalse
        }
    }

    Describe 'Expand-VendorPropertySet' {
        It 'admits the members of a referenced complex type' {
            $types = [ordered]@{
                'beta:a' = [ordered]@{ properties = [ordered]@{ nested = New-TestProperty -Type 'b' -IsComplex $true } }
                'beta:b' = [ordered]@{ properties = [ordered]@{ leaf = New-TestProperty } }
            }

            $result = Expand-VendorPropertySet -GraphType $types -ApiVersion 'beta' -TypeName 'a'
            $result.Properties.Contains('nested.leaf') | Should -BeTrue
            $result.Properties['nested.leaf'].Path | Should -Be 'nested.leaf'
            $result.Properties['nested.leaf'].Name | Should -Be 'leaf'
            $result.TopLevelCount | Should -Be 1
        }

        It 'keeps every member that shares a leaf name' {
            $types = [ordered]@{
                'beta:a' = [ordered]@{
                    properties = [ordered]@{
                        signInFrequency  = New-TestProperty -Type 'b' -IsComplex $true
                        persistentBrowser = New-TestProperty -Type 'c' -IsComplex $true
                    }
                }
                'beta:b' = [ordered]@{ properties = [ordered]@{ isEnabled = New-TestProperty -Type 'Edm.Boolean' } }
                'beta:c' = [ordered]@{ properties = [ordered]@{ isEnabled = New-TestProperty -Type 'Edm.Boolean' } }
            }

            $result = Expand-VendorPropertySet -GraphType $types -ApiVersion 'beta' -TypeName 'a'

            $result.Properties.Contains('signInFrequency.isEnabled') | Should -BeTrue
            $result.Properties.Contains('persistentBrowser.isEnabled') | Should -BeTrue
            @($result.ByLeaf['isEnabled']) | Should -HaveCount 2
        }

        It 'expands a complex type reached from two parents under both paths' {
            $types = [ordered]@{
                'beta:a' = [ordered]@{
                    properties = [ordered]@{
                        applicationFilter = New-TestProperty -Type 'filter' -IsComplex $true
                        deviceFilter      = New-TestProperty -Type 'filter' -IsComplex $true
                    }
                }
                'beta:filter' = [ordered]@{ properties = [ordered]@{ mode = New-TestProperty } }
            }

            $result = Expand-VendorPropertySet -GraphType $types -ApiVersion 'beta' -TypeName 'a'

            $result.Properties.Contains('applicationFilter.mode') | Should -BeTrue
            $result.Properties.Contains('deviceFilter.mode') | Should -BeTrue
        }

        It 'leaves a navigation property out unless the resource asks for it' {
            $types = [ordered]@{
                'beta:a' = [ordered]@{ properties = [ordered]@{ owners = New-TestProperty -Type 'b' -IsComplex $true -IsNavigation $true } }
            }

            (Expand-VendorPropertySet -GraphType $types -ApiVersion 'beta' -TypeName 'a').Properties.Contains('owners') | Should -BeFalse
            (Expand-VendorPropertySet -GraphType $types -ApiVersion 'beta' -TypeName 'a' -IncludeNavigationProperties $true).Properties.Contains('owners') | Should -BeTrue
        }

        It 'stops at a self-referencing complex type' {
            $types = [ordered]@{
                'beta:a' = [ordered]@{ properties = [ordered]@{ self = New-TestProperty -Type 'a' -IsComplex $true } }
            }

            { Expand-VendorPropertySet -GraphType $types -ApiVersion 'beta' -TypeName 'a' } | Should -Not -Throw
        }

        It 'reports that the walk was truncated' {
            $types = [ordered]@{
                'beta:a' = [ordered]@{ properties = [ordered]@{ n = New-TestProperty -Type 'b' -IsComplex $true } }
                'beta:b' = [ordered]@{ properties = [ordered]@{ n = New-TestProperty -Type 'c' -IsComplex $true } }
                'beta:c' = [ordered]@{ properties = [ordered]@{ leaf = New-TestProperty } }
            }

            (Expand-VendorPropertySet -GraphType $types -ApiVersion 'beta' -TypeName 'a' -MaxDepth 1).Truncated | Should -BeTrue
        }
    }

    Describe 'Report rendering' {
        BeforeAll {
            $script:snapshot = New-TestSnapshot -GraphType $script:policyType -Dependency ([ordered]@{
                    'Az.Resources' = [ordered]@{ pinned = '9.0.1'; manifests = @('Manifest'); latestPublished = '10.1.0' }
                })
            $script:keyword = New-TestKeyword -Property @{
                DisplayName = @{ typeConstraint = 'String' }
                State       = @{ typeConstraint = 'String'; values = @('enabled') }
                Invented    = @{ typeConstraint = 'String' }
            }
            $script:result = Invoke-TestCompare -Current $script:snapshot -Origin @(New-TestOrigin) -SchemaKeyword $script:keyword
        }

        It 'renders the same Markdown twice' {
            (Format-DriftMarkdown -Result $script:result) | Should -BeExactly (Format-DriftMarkdown -Result $script:result)
        }

        It 'renders the same Issue body twice' {
            (Format-DriftIssueBody -Result $script:result) | Should -BeExactly (Format-DriftIssueBody -Result $script:result)
        }

        It 'states a count on every section even when it is empty' {
            $body = Format-DriftIssueBody -Result $script:result
            $body | Should -Match '## Read-only, suggested for no implementation  \(0\)'
        }

        It 'groups the dependency section by jump size' {
            (Format-DriftMarkdown -Result $script:result) | Should -Match 'Major \(1\)'
        }

        It 'round trips the ticked ids out of an Issue body' {
            $ids = @($script:result.Findings | Where-Object { $_.autoFixable } | ForEach-Object { $_.id })
            $ids.Count | Should -BeGreaterThan 0

            $body = Format-DriftIssueBody -Result $script:result -Ticked $ids
            Get-DriftIssueTicked -Body $body | Should -Be $ids
        }

        It 'leaves an unticked body parsing to nothing' {
            Get-DriftIssueTicked -Body (Format-DriftIssueBody -Result $script:result) | Should -HaveCount 0
        }

        It 'carries no timestamp into the Issue body' {
            Format-DriftIssueBody -Result $script:result | Should -Not -Match '\d{4}-\d{2}-\d{2}T'
        }
    }
}
