BeforeAll {
    Import-Module "$PSScriptRoot/../../../Modules/Microsoft365DSC/Modules/M365DSCDllLoader.psm1" -Force -Global
    Initialize-M365DSCDllLoader
    Import-Module "$PSScriptRoot/../../../Modules/Microsoft365DSC/Microsoft365DSC.psd1" -Global

    function global:Get-MgBetaDeviceManagementDeviceConfiguration
    {
        [CmdletBinding()]
        param ($All, $Filter, $ExpandProperty)
    }

    function global:Get-MgBetaDeviceManagementDeviceCompliancePolicy
    {
        [CmdletBinding()]
        param ($All, $Filter, $ExpandProperty)
    }

    function global:Get-MgBetaDeviceManagementDeviceEnrollmentConfiguration
    {
        [CmdletBinding()]
        param ($All, $Filter, $ExpandProperty)
    }

    function global:Get-MgGroup
    {
        [CmdletBinding()]
        param ($GroupId, $Filter, $Property, [switch] $All)
    }

    function global:Get-MgBetaDeviceManagementAssignmentFilter
    {
        [CmdletBinding()]
        param ([switch] $All)
    }

    $Script:Cache = [Microsoft365DSC.Cache.ExportCollectionCache]
}

Describe 'M365DSCExportCollectionCache' {
    AfterEach {
        [Microsoft365DSC.Cache.ExportCollectionCache]::Reset()
        [Microsoft365DSC.Intune.IntuneGroupCache]::Reset()
    }

    Context 'ExportCollectionCache' {
        It 'reports a miss for every call while disabled' {
            $items = $null
            $Script:Cache::TryGet('deviceConfigurations', [ref] $items) | Should -BeFalse
            $Script:Cache::ShouldPopulate('deviceConfigurations') | Should -BeFalse
            $Script:Cache::TrySet('deviceConfigurations', [object[]] @(@{ id = '1' })) | Should -BeFalse
        }

        It 'round-trips a collection once enabled' {
            $Script:Cache::Enable()
            $Script:Cache::ShouldPopulate('deviceConfigurations') | Should -BeTrue
            $Script:Cache::TrySet('deviceConfigurations', [object[]] @(@{ id = '1' })) | Should -BeTrue
            $Script:Cache::ShouldPopulate('deviceConfigurations') | Should -BeFalse
            $items = $null
            $Script:Cache::TryGet('deviceConfigurations', [ref] $items) | Should -BeTrue
            @($items).Count | Should -Be 1
        }

        It 'treats an empty collection as populated' {
            $Script:Cache::Enable()
            $Script:Cache::TrySet('deviceConfigurations', [object[]] @()) | Should -BeTrue
            $Script:Cache::ShouldPopulate('deviceConfigurations') | Should -BeFalse
            $items = $null
            $Script:Cache::TryGet('deviceConfigurations', [ref] $items) | Should -BeTrue
            @($items).Count | Should -Be 0
        }

        It 'filters by @odata.type ignoring the # prefix and case' {
            $Script:Cache::Enable()
            $null = $Script:Cache::TrySet('deviceConfigurations', [object[]] @(
                    @{ id = '1'; '@odata.type' = '#microsoft.graph.windowsKioskConfiguration' },
                    @{ id = '2'; '@odata.type' = '#microsoft.graph.windowsWifiConfiguration' },
                    @{ id = '3'; '@odata.type' = '#microsoft.graph.windowsWifiEnterpriseEAPConfiguration' }
                ))
            $kiosk = $Script:Cache::GetByODataType('deviceConfigurations', [string[]] @('Microsoft.Graph.WindowsKioskConfiguration'), [string[]] @())
            @($kiosk).id | Should -Be '1'
            $wifi = $Script:Cache::GetByODataType('deviceConfigurations', [string[]] @('microsoft.graph.windowsWifiConfiguration'), [string[]] @('microsoft.graph.windowsWifiEnterpriseEAPConfiguration'))
            @($wifi).id | Should -Be '2'
            $all = $Script:Cache::GetByODataType('deviceConfigurations', [string[]] @(), [string[]] @())
            @($all).Count | Should -Be 3
            $Script:Cache::GetByODataType('deviceCompliancePolicies', [string[]] @(), [string[]] @()) | Should -BeNullOrEmpty
        }

        It 'filters PSCustomObject items' {
            $items = [object[]] @([PSCustomObject] @{ id = '1'; '@odata.type' = '#microsoft.graph.iosCompliancePolicy' }, [PSCustomObject] @{ id = '2'; '@odata.type' = '#microsoft.graph.macOSCompliancePolicy' })
            $result = $Script:Cache::FilterByODataType($items, [string[]] @('microsoft.graph.macOSCompliancePolicy'), [string[]] @())
            @($result).id | Should -Be '2'
        }

        It 'keeps the first collection stored for a key' {
            $Script:Cache::Enable()
            $Script:Cache::TrySet('deviceConfigurations', [object[]] @(@{ id = '1' })) | Should -BeTrue
            $Script:Cache::TrySet('deviceConfigurations', [object[]] @(@{ id = '2' })) | Should -BeTrue
            $items = $null
            $null = $Script:Cache::TryGet('deviceConfigurations', [ref] $items)
            @($items).id | Should -Be '1'
        }

        It 'drops a collection after its last consumer is released' {
            $Script:Cache::Enable()
            $null = $Script:Cache::TrySet('deviceConfigurations', [object[]] @(@{ id = '1' }))
            $Script:Cache::RegisterConsumers('deviceConfigurations', 2)
            $Script:Cache::Release('deviceConfigurations') | Should -Be 1
            $Script:Cache::Keys | Should -Contain 'deviceConfigurations'
            $Script:Cache::Release('deviceConfigurations') | Should -Be 0
            $Script:Cache::Keys | Should -Not -Contain 'deviceConfigurations'
            $Script:Cache::Release('unknown') | Should -Be 0
        }

        It 'clears and disables on Reset' {
            $Script:Cache::Enable()
            $null = $Script:Cache::TrySet('deviceConfigurations', [object[]] @(@{ id = '1' }))
            $Script:Cache::Reset()
            $Script:Cache::IsEnabled | Should -BeFalse
            $Script:Cache::Keys.Count | Should -Be 0
        }
    }

    Context 'Get-M365DSCExportCachedCollection' {
        BeforeEach {
            Mock -ModuleName M365DSCExportUtil -CommandName Get-MgBetaDeviceManagementDeviceConfiguration -MockWith {
                return @(
                    @{ id = '1'; '@odata.type' = '#microsoft.graph.windowsKioskConfiguration' },
                    @{ id = '2'; '@odata.type' = '#microsoft.graph.windowsWifiConfiguration' },
                    @{ id = '3'; '@odata.type' = '#microsoft.graph.windowsWifiEnterpriseEAPConfiguration' }
                )
            }
            Mock -ModuleName M365DSCExportUtil -CommandName Get-MgBetaDeviceManagementDeviceEnrollmentConfiguration -MockWith {
                return @(
                    @{ id = '1'; '@odata.type' = '#microsoft.graph.deviceEnrollmentLimitConfiguration' },
                    @{ id = '2'; '@odata.type' = '#microsoft.graph.windows10EnrollmentCompletionPageConfiguration' }
                )
            }
        }

        It 'performs the isof request with assignments expanded while the cache is disabled' {
            $result = Get-M365DSCExportCachedCollection -Collection 'deviceConfigurations' -ODataType 'microsoft.graph.windowsKioskConfiguration'
            Should -Invoke -ModuleName M365DSCExportUtil -CommandName Get-MgBetaDeviceManagementDeviceConfiguration -Times 1 -Exactly -ParameterFilter {
                $Filter -eq "isof('microsoft.graph.windowsKioskConfiguration')" -and $ExpandProperty -contains 'assignments' -and $All
            }
            $result.Count | Should -Be 3
        }

        It 'builds the exclusion and multi-type filters' {
            $null = Get-M365DSCExportCachedCollection -Collection 'deviceConfigurations' -ODataType 'microsoft.graph.windowsWifiConfiguration' -ExcludeODataType 'microsoft.graph.windowsWifiEnterpriseEAPConfiguration'
            Should -Invoke -ModuleName M365DSCExportUtil -CommandName Get-MgBetaDeviceManagementDeviceConfiguration -Times 1 -Exactly -ParameterFilter {
                $Filter -eq "isof('microsoft.graph.windowsWifiConfiguration') and not isof('microsoft.graph.windowsWifiEnterpriseEAPConfiguration')"
            }
            $null = Get-M365DSCExportCachedCollection -Collection 'deviceConfigurations' -ODataType @('microsoft.graph.iosVpnConfiguration', 'microsoft.graph.iosikEv2VpnConfiguration')
            Should -Invoke -ModuleName M365DSCExportUtil -CommandName Get-MgBetaDeviceManagementDeviceConfiguration -Times 1 -Exactly -ParameterFilter {
                $Filter -eq "(isof('microsoft.graph.iosVpnConfiguration') or isof('microsoft.graph.iosikEv2VpnConfiguration'))"
            }
        }

        It 'merges a user filter and bypasses the cache' {
            [Microsoft365DSC.Cache.ExportCollectionCache]::Enable()
            $null = Get-M365DSCExportCachedCollection -Collection 'deviceConfigurations' -ODataType 'microsoft.graph.windowsKioskConfiguration' -Filter "displayName eq 'x'"
            Should -Invoke -ModuleName M365DSCExportUtil -CommandName Get-MgBetaDeviceManagementDeviceConfiguration -Times 1 -Exactly -ParameterFilter {
                $Filter -eq "(isof('microsoft.graph.windowsKioskConfiguration')) and (displayName eq 'x')"
            }
            [Microsoft365DSC.Cache.ExportCollectionCache]::ShouldPopulate('deviceConfigurations') | Should -BeTrue
        }

        It 'filters enrollment configurations client-side' {
            $result = Get-M365DSCExportCachedCollection -Collection 'deviceEnrollmentConfigurations' -ODataType 'microsoft.graph.deviceEnrollmentLimitConfiguration'
            Should -Invoke -ModuleName M365DSCExportUtil -CommandName Get-MgBetaDeviceManagementDeviceEnrollmentConfiguration -Times 1 -Exactly -ParameterFilter {
                $null -eq $Filter -and $ExpandProperty -contains 'assignments'
            }
            @($result).id | Should -Be '1'
        }

        It 'downloads once and serves later types from the cache' {
            [Microsoft365DSC.Cache.ExportCollectionCache]::Enable()
            $kiosk = Get-M365DSCExportCachedCollection -Collection 'deviceConfigurations' -ODataType 'microsoft.graph.windowsKioskConfiguration'
            $wifi = Get-M365DSCExportCachedCollection -Collection 'deviceConfigurations' -ODataType 'microsoft.graph.windowsWifiConfiguration' -ExcludeODataType 'microsoft.graph.windowsWifiEnterpriseEAPConfiguration'
            Should -Invoke -ModuleName M365DSCExportUtil -CommandName Get-MgBetaDeviceManagementDeviceConfiguration -Times 1 -Exactly -ParameterFilter {
                $null -eq $Filter -and $ExpandProperty -contains 'assignments'
            }
            @($kiosk).id | Should -Be '1'
            @($wifi).id | Should -Be '2'
        }

        It 'returns an empty array when nothing matches' {
            Mock -ModuleName M365DSCExportUtil -CommandName Get-MgBetaDeviceManagementDeviceConfiguration -MockWith { }
            $result = Get-M365DSCExportCachedCollection -Collection 'deviceConfigurations' -ODataType 'microsoft.graph.windowsKioskConfiguration'
            $result.Length | Should -Be 0
        }
    }

    Context 'Get-M365DSCPIMEnabledGroup' {
        BeforeEach {
            Mock -ModuleName M365DSCExportUtil -CommandName Get-M365DSCRawGraphCollection -MockWith {
                return @(@{ id = 'g1' }, @{ id = 'g2' })
            }
            Mock -ModuleName M365DSCExportUtil -CommandName Invoke-M365DSCGraphBatchRequest -MockWith {
                return @(
                    @{ id = 'g1'; status = 200; body = @{ id = 'g1'; displayName = 'Group 1' } },
                    @{ id = 'g2'; status = 404; body = @{ error = @{ code = 'Request_ResourceNotFound' } } }
                )
            }
        }

        It 'lists the PIM group resources and resolves their display names' {
            $result = Get-M365DSCPIMEnabledGroup
            Should -Invoke -ModuleName M365DSCExportUtil -CommandName Get-M365DSCRawGraphCollection -Times 1 -Exactly -ParameterFilter {
                $Uri -eq '/beta/identityGovernance/privilegedAccess/group/resources'
            }
            Should -Invoke -ModuleName M365DSCExportUtil -CommandName Invoke-M365DSCGraphBatchRequest -Times 1 -Exactly -ParameterFilter {
                $Requests.Count -eq 2 -and $Requests[0].url -eq '/groups/g1?$select=id,displayName'
            }
            @($result).Count | Should -Be 1
            @($result)[0].Id | Should -Be 'g1'
            @($result)[0].DisplayName | Should -Be 'Group 1'
        }

        It 'returns an empty array when no group is enabled in PIM' {
            Mock -ModuleName M365DSCExportUtil -CommandName Get-M365DSCRawGraphCollection -MockWith { return , [object[]] @() }
            Mock -ModuleName M365DSCExportUtil -CommandName Invoke-M365DSCGraphBatchRequest -MockWith { }
            @(Get-M365DSCPIMEnabledGroup).Count | Should -Be 0
        }

        It 'lists the PIM groups once per export' {
            [Microsoft365DSC.Cache.ExportCollectionCache]::Enable()
            Mock -ModuleName M365DSCExportUtil -CommandName Invoke-M365DSCGraphBatchRequest -MockWith {
                return @(
                    @{ id = 'g1'; status = 200; body = @{ id = 'g1'; displayName = 'Group 1' } },
                    @{ id = 'g2'; status = 200; body = @{ id = 'g2'; displayName = 'Group 2' } }
                )
            }
            $null = Get-M365DSCExportCachedCollection -Collection 'pimGroups'
            $second = Get-M365DSCExportCachedCollection -Collection 'pimGroups'
            Should -Invoke -ModuleName M365DSCExportUtil -CommandName Get-M365DSCRawGraphCollection -Times 1 -Exactly
            $second.Count | Should -Be 2
            $second[1].DisplayName | Should -Be 'Group 2'
        }
    }

    Context 'Get-M365DSCIntuneExpandedAssignments' {
        It 'returns $null for missing input or missing assignments' {
            Get-M365DSCIntuneExpandedAssignments -Instance $null | Should -BeNullOrEmpty
            Get-M365DSCIntuneExpandedAssignments -Instance @{ id = '1' } | Should -BeNullOrEmpty
            Get-M365DSCIntuneExpandedAssignments -Instance ([PSCustomObject] @{ id = '1' }) | Should -BeNullOrEmpty
        }

        It 'returns $null when the expansion was truncated' {
            Get-M365DSCIntuneExpandedAssignments -Instance @{ assignments = @(@{ id = 'a' }); 'assignments@odata.nextLink' = 'x' } | Should -BeNullOrEmpty
        }

        It 'returns an empty array for an empty expansion' {
            $result = Get-M365DSCIntuneExpandedAssignments -Instance @{ assignments = @() }
            $null -eq $result | Should -BeFalse
            $result.Length | Should -Be 0
        }

        It 'returns the expanded assignments from hashtables and objects' {
            $fromHashtable = Get-M365DSCIntuneExpandedAssignments -Instance @{ assignments = @(@{ id = 'a' }, @{ id = 'b' }) }
            $fromHashtable.Count | Should -Be 2
            $fromObject = Get-M365DSCIntuneExpandedAssignments -Instance ([PSCustomObject] @{ Assignments = @(@{ id = 'a' }) })
            $fromObject.Count | Should -Be 1
        }
    }

    Context 'Export collection consumers' {
        It 'registers and releases consumers per collection' {
            [Microsoft365DSC.Cache.ExportCollectionCache]::Enable()
            Register-M365DSCExportCollectionConsumers -ResourceNames @('IntuneDeviceConfigurationKioskPolicyWindows10', 'IntuneDeviceEnrollmentLimitRestriction', 'AADUser')
            [Microsoft365DSC.Cache.ExportCollectionCache]::GetConsumerCount('deviceConfigurations') | Should -Be 1
            [Microsoft365DSC.Cache.ExportCollectionCache]::GetConsumerCount('deviceEnrollmentConfigurations') | Should -Be 1
            [Microsoft365DSC.Cache.ExportCollectionCache]::GetConsumerCount('deviceCompliancePolicies') | Should -Be 0
            Complete-M365DSCExportCollectionConsumer -ResourceName 'AADUser'
            [Microsoft365DSC.Cache.ExportCollectionCache]::GetConsumerCount('deviceConfigurations') | Should -Be 1
            Complete-M365DSCExportCollectionConsumer -ResourceName 'IntuneDeviceConfigurationKioskPolicyWindows10'
            [Microsoft365DSC.Cache.ExportCollectionCache]::Keys | Should -Not -Contain 'deviceConfigurations'
        }

        It 'initializes an enabled empty cache' {
            Initialize-M365DSCExportCollectionCache
            [Microsoft365DSC.Cache.ExportCollectionCache]::IsEnabled | Should -BeTrue
            Reset-M365DSCExportCollectionCache
            [Microsoft365DSC.Cache.ExportCollectionCache]::IsEnabled | Should -BeFalse
        }
    }

    Context 'Intune assignment filter cache' {
        BeforeEach {
            Mock -ModuleName M365DSCIntuneUtil -CommandName Get-MgBetaDeviceManagementAssignmentFilter -MockWith {
                return @(@{ Id = 'f1'; DisplayName = 'Filter 1' })
            }
            Mock -ModuleName M365DSCIntuneUtil -CommandName Get-MgGroup -MockWith { return @{ Id = 'g1'; DisplayName = 'Group g1' } }
            Clear-M365DSCIntuneAssignmentFilterCache
        }

        It 'reads the assignment filters again after the export cache is initialized' {
            $assignments = @(@{ Target = @{ '@odata.type' = '#microsoft.graph.groupAssignmentTarget'; groupId = 'g1'; deviceAndAppManagementAssignmentFilterId = 'f1'; deviceAndAppManagementAssignmentFilterType = 'include' } })
            $null = ConvertFrom-IntunePolicyAssignment -Assignments $assignments
            $null = ConvertFrom-IntunePolicyAssignment -Assignments $assignments
            Should -Invoke -ModuleName M365DSCIntuneUtil -CommandName Get-MgBetaDeviceManagementAssignmentFilter -Exactly -Times 1

            Initialize-M365DSCExportCollectionCache
            $null = ConvertFrom-IntunePolicyAssignment -Assignments $assignments
            Should -Invoke -ModuleName M365DSCIntuneUtil -CommandName Get-MgBetaDeviceManagementAssignmentFilter -Exactly -Times 2
        }
    }

    Context 'Get-M365DSCIntuneGroup' {
        BeforeEach {
            Mock -ModuleName M365DSCIntuneUtil -CommandName Get-MgBetaDeviceManagementAssignmentFilter -MockWith { }
            Mock -ModuleName M365DSCIntuneUtil -CommandName Get-MgGroup -MockWith {
                if ($GroupId -eq 'missing') { return $null }
                if ($GroupId) { return @{ Id = $GroupId; DisplayName = "Group $GroupId" } }
                if ($Filter -like "*'Dup'*") { return @(@{ Id = 'a'; DisplayName = 'Dup' }, @{ Id = 'b'; DisplayName = 'Dup' }) }
                if ($Filter -like "*'Nope'*") { return $null }
                return @{ Id = 'g1'; DisplayName = 'Group g1' }
            }
        }

        It 'serves the second lookup of a group from the cache while enabled' {
            Initialize-M365DSCExportCollectionCache
            $assignments = @(@{ Target = @{ '@odata.type' = '#microsoft.graph.groupAssignmentTarget'; groupId = 'g1' } })
            $first = ConvertFrom-IntunePolicyAssignment -Assignments $assignments
            $second = ConvertFrom-IntunePolicyAssignment -Assignments $assignments
            Should -Invoke -ModuleName M365DSCIntuneUtil -CommandName Get-MgGroup -Exactly -Times 1 -ParameterFilter { $GroupId -eq 'g1' }
            $first[0].groupDisplayName | Should -Be 'Group g1'
            $second[0].groupDisplayName | Should -Be 'Group g1'
        }

        It 'performs a live lookup for every call while disabled' {
            $assignments = @(@{ Target = @{ '@odata.type' = '#microsoft.graph.groupAssignmentTarget'; groupId = 'g1' } })
            $null = ConvertFrom-IntunePolicyAssignment -Assignments $assignments
            $null = ConvertFrom-IntunePolicyAssignment -Assignments $assignments
            Should -Invoke -ModuleName M365DSCIntuneUtil -CommandName Get-MgGroup -Exactly -Times 2 -ParameterFilter { $GroupId -eq 'g1' }
        }

        It 'does not cache a miss' {
            Initialize-M365DSCExportCollectionCache
            Get-M365DSCIntuneGroup -GroupId 'missing' | Should -BeNullOrEmpty
            Get-M365DSCIntuneGroup -GroupId 'missing' | Should -BeNullOrEmpty
            Should -Invoke -ModuleName M365DSCIntuneUtil -CommandName Get-MgGroup -Exactly -Times 2
            [Microsoft365DSC.Intune.IntuneGroupCache]::Count | Should -Be 0
        }

        It 'returns an array for a display name and caches it' {
            Initialize-M365DSCExportCollectionCache
            $result = Get-M365DSCIntuneGroup -DisplayName 'Dup'
            $result.Count | Should -Be 2
            $null = Get-M365DSCIntuneGroup -DisplayName 'Dup'
            Should -Invoke -ModuleName M365DSCIntuneUtil -CommandName Get-MgGroup -Exactly -Times 1 -ParameterFilter { $Filter -eq "displayName eq 'Dup'" -and $All }
        }

        It 'returns an empty array for an unknown display name and does not cache it' {
            Initialize-M365DSCExportCollectionCache
            (Get-M365DSCIntuneGroup -DisplayName 'Nope').Count | Should -Be 0
            (Get-M365DSCIntuneGroup -DisplayName 'Nope').Count | Should -Be 0
            Should -Invoke -ModuleName M365DSCIntuneUtil -CommandName Get-MgGroup -Exactly -Times 2
        }

        It 'escapes quotes in the display name filter and requests only id and displayName' {
            $null = Get-M365DSCIntuneGroup -DisplayName "O'Brien"
            Should -Invoke -ModuleName M365DSCIntuneUtil -CommandName Get-MgGroup -Exactly -Times 1 -ParameterFilter { $Filter -eq "displayName eq 'O''Brien'" -and $Property -eq 'id,displayName' }
            $null = Get-M365DSCIntuneGroup -GroupId 'g1'
            Should -Invoke -ModuleName M365DSCIntuneUtil -CommandName Get-MgGroup -Exactly -Times 1 -ParameterFilter { $GroupId -eq 'g1' -and $Property -eq 'id,displayName' }
        }

        It 'does not reuse the previous display name for a missed group' {
            $assignments = @(
                @{ Target = @{ '@odata.type' = '#microsoft.graph.groupAssignmentTarget'; groupId = 'g1' } },
                @{ Target = @{ '@odata.type' = '#microsoft.graph.groupAssignmentTarget'; groupId = 'missing' } }
            )
            $result = ConvertFrom-IntunePolicyAssignment -Assignments $assignments
            $result[0].groupDisplayName | Should -Be 'Group g1'
            $result[1].Contains('groupDisplayName') | Should -BeFalse
        }

        It 'clears the group cache with the export cache' {
            Initialize-M365DSCExportCollectionCache
            $null = Get-M365DSCIntuneGroup -GroupId 'g1'
            [Microsoft365DSC.Intune.IntuneGroupCache]::Count | Should -Be 1
            Reset-M365DSCExportCollectionCache
            [Microsoft365DSC.Intune.IntuneGroupCache]::Count | Should -Be 0
            [Microsoft365DSC.Intune.IntuneGroupCache]::IsEnabled | Should -BeFalse
        }
    }
}

Describe 'SettingTemplateCache' {
    BeforeAll {
        function global:Get-MgBetaDeviceManagementConfigurationPolicyTemplateSettingTemplate
        {
            [CmdletBinding()]
            param ($DeviceManagementConfigurationPolicyTemplateId, $ExpandProperty, [switch] $All)
        }
    }

    AfterEach {
        [Microsoft365DSC.Intune.SettingTemplateCache]::Reset()
    }

    It 'Misses an unknown template and serves a stored one case-insensitively' {
        $templates = $null
        [Microsoft365DSC.Intune.SettingTemplateCache]::TryGet('abc_1', [ref] $templates) | Should -BeFalse

        [Microsoft365DSC.Intune.SettingTemplateCache]::Set('abc_1', [object[]] @(@{ Id = 'first' }))
        [Microsoft365DSC.Intune.SettingTemplateCache]::Set('ABC_1', [object[]] @(@{ Id = 'second' }))

        [Microsoft365DSC.Intune.SettingTemplateCache]::TryGet('ABC_1', [ref] $templates) | Should -BeTrue
        $templates[0].Id | Should -Be 'first'
        [Microsoft365DSC.Intune.SettingTemplateCache]::Count | Should -Be 1
    }

    It 'Ignores empty ids and null payloads' {
        [Microsoft365DSC.Intune.SettingTemplateCache]::Set('', [object[]] @(@{ Id = 'x' }))
        [Microsoft365DSC.Intune.SettingTemplateCache]::Set('abc_1', $null)

        [Microsoft365DSC.Intune.SettingTemplateCache]::Count | Should -Be 0
    }

    It 'Fetches a template once per process through Get-M365DSCSettingCatalogTemplate' {
        Mock -CommandName Get-MgBetaDeviceManagementConfigurationPolicyTemplateSettingTemplate -ModuleName M365DSCIntuneUtil -MockWith {
            return @(@{ Id = '0'; SettingDefinitions = @(@{ Id = 'def_1'; Name = 'one' }) })
        }

        $first = Get-M365DSCSettingCatalogTemplate -TemplateId 'tmpl_1'
        $second = Get-M365DSCSettingCatalogTemplate -TemplateId 'tmpl_1'

        Should -Invoke -CommandName Get-MgBetaDeviceManagementConfigurationPolicyTemplateSettingTemplate -ModuleName M365DSCIntuneUtil -Times 1 -Exactly
        $first.Count | Should -Be 1
        $first[0].SettingDefinitions[0].Id | Should -Be 'def_1'
        [object]::ReferenceEquals($first, $second) | Should -BeTrue

        [Microsoft365DSC.Intune.SettingTemplateCache]::Reset()
        $null = Get-M365DSCSettingCatalogTemplate -TemplateId 'tmpl_1'
        Should -Invoke -CommandName Get-MgBetaDeviceManagementConfigurationPolicyTemplateSettingTemplate -ModuleName M365DSCIntuneUtil -Times 2 -Exactly
    }
}
