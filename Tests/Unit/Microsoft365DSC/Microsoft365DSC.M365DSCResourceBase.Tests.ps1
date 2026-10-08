[CmdletBinding()]
param(
)

<#
    Exercises the complex-type hydration path of M365DSCResourceBase through the public
    New-M365DSCResourceInstance seam: assigning a complex-typed property routes through
    _SetProperty -> SanitizeComplexValue -> the hashtable-to-class conversion, which now
    enforces the [ValidateSet] attributes restored on embedded complex classes.

    Uses IntuneCloudProvisioningPolicyWindows365 because its Assignments property targets
    MSFT_DeviceManagementConfigurationPolicyAssignments, whose dataType and
    deviceAndAppManagementAssignmentFilterType members both carry a [ValidateSet].
#>

BeforeAll {
    $repoRoot = Join-Path -Path $PSScriptRoot -ChildPath '..\..\..' -Resolve
    Import-Module -Name (Join-Path -Path $repoRoot -ChildPath 'Modules\Microsoft365DSC\Microsoft365DSC.psd1') -Global

    $Script:NewInstance = {
        param ([System.Collections.Hashtable] $Property)
        New-M365DSCResourceInstance -ResourceName 'IntuneCloudProvisioningPolicyWindows365' -Property $Property
    }

    function Get-ReflectionOracle
    {
        [CmdletBinding()]
        param
        (
            [Parameter(Mandatory = $true)]
            [System.Object]
            $Instance
        )

        $expected = @{}
        foreach ($name in $Instance.GetSchemaPropertyNames())
        {
            $value = $Instance.GetType().GetProperty($name).GetValue($Instance)
            if ($null -ne $value)
            {
                $expected[$name] = $value
            }
        }

        return $expected
    }

    function Assert-SnapshotMatchesOracle
    {
        [CmdletBinding()]
        param
        (
            [Parameter(Mandatory = $true)]
            [System.Object]
            $Instance
        )

        $expected = Get-ReflectionOracle -Instance $Instance
        $actual = $Instance.GetBoundParameters()
        @($actual.Keys | Sort-Object) | Should -Be @($expected.Keys | Sort-Object)
        foreach ($name in $expected.Keys)
        {
            if ($expected[$name] -is [System.Array])
            {
                @($actual[$name]) | Should -Be @($expected[$name])
            }
            else
            {
                $actual[$name] | Should -Be $expected[$name]
            }
        }
    }

    function Set-PropertyByReflection
    {
        [CmdletBinding()]
        param
        (
            [Parameter(Mandatory = $true)]
            [System.Object]
            $Instance,

            [Parameter(Mandatory = $true)]
            [System.String]
            $Name,

            [Parameter(Mandatory = $true)]
            [System.Object]
            $Value
        )

        $Instance.GetType().GetProperty($Name).SetValue($Instance, $Value)
    }
}

Describe 'M365DSCResourceBase complex-type hydration' {
    It 'Hydrates a complex array element with valid ValidateSet values' {
        $instance = & $Script:NewInstance @{
            Assignments = @(
                @{
                    dataType = '#microsoft.graph.groupAssignmentTarget'
                    deviceAndAppManagementAssignmentFilterType = 'include'
                    groupId = '42a638ec-2bf2-47a8-8f5f-176ce2124b7b'
                }
            )
        }

        $instance.Assignments.Count | Should -Be 1
        $instance.Assignments[0].dataType | Should -Be '#microsoft.graph.groupAssignmentTarget'
        $instance.Assignments[0].deviceAndAppManagementAssignmentFilterType | Should -Be 'include'
    }

    It 'Drops a $null value on a ValidateSet member instead of failing the conversion' {
        $instance = & $Script:NewInstance @{
            Assignments = @(
                @{
                    dataType = '#microsoft.graph.groupAssignmentTarget'
                    deviceAndAppManagementAssignmentFilterType = $null
                    groupId = '42a638ec-2bf2-47a8-8f5f-176ce2124b7b'
                }
            )
        }

        $instance.Assignments.Count | Should -Be 1
        $instance.Assignments[0].deviceAndAppManagementAssignmentFilterType | Should -BeNullOrEmpty
        $instance.Assignments[0].groupId | Should -Be '42a638ec-2bf2-47a8-8f5f-176ce2124b7b'
    }

    It 'Drops an empty string on a ValidateSet member instead of failing the conversion' {
        $instance = & $Script:NewInstance @{
            Assignments = @(
                @{
                    dataType = '#microsoft.graph.groupAssignmentTarget'
                    deviceAndAppManagementAssignmentFilterType = ''
                }
            )
        }

        $instance.Assignments.Count | Should -Be 1
        $instance.Assignments[0].deviceAndAppManagementAssignmentFilterType | Should -BeNullOrEmpty
    }

    It 'Keeps $null on members without a ValidateSet' {
        $instance = & $Script:NewInstance @{
            Assignments = @(
                @{
                    dataType = '#microsoft.graph.allDevicesAssignmentTarget'
                    groupId = $null
                }
            )
        }

        $instance.Assignments.Count | Should -Be 1
        $instance.Assignments[0].groupId | Should -BeNull
    }

    It 'Keeps $null string members of a PSCustomObject element instead of turning them into empty strings' {
        $instance = & $Script:NewInstance @{
            Assignments = @(
                [PSCustomObject] @{
                    dataType = '#microsoft.graph.allDevicesAssignmentTarget'
                    groupDisplayName = $null
                    groupId = $null
                }
            )
        }

        $instance.Assignments.Count | Should -Be 1
        $instance.Assignments[0].groupDisplayName | Should -BeNull
        $instance.Assignments[0].groupId | Should -BeNull
    }

    It 'Throws on an out-of-set value and names the offending member' {
        {
            & $Script:NewInstance @{
                Assignments = @(
                    @{
                        dataType = 'not-a-real-target'
                    }
                )
            }
        } | Should -Throw -ExpectedMessage '*dataType*not in the valid set*'
    }

    It 'Hydrates every element of a complex array when one element carries a $null ValidateSet member' {
        $instance = & $Script:NewInstance @{
            Assignments = @(
                @{
                    dataType = '#microsoft.graph.groupAssignmentTarget'
                    groupId = '11111111-1111-1111-1111-111111111111'
                },
                @{
                    dataType = '#microsoft.graph.exclusionGroupAssignmentTarget'
                    deviceAndAppManagementAssignmentFilterType = $null
                    groupId = '22222222-2222-2222-2222-222222222222'
                }
            )
        }

        $instance.Assignments.Count | Should -Be 2
        $instance.Assignments[1].dataType | Should -Be '#microsoft.graph.exclusionGroupAssignmentTarget'
    }

    It 'Hydrates a PSCustomObject element the same as a hashtable' {
        $instance = & $Script:NewInstance @{
            Assignments = @(
                [PSCustomObject] @{
                    dataType = '#microsoft.graph.groupAssignmentTarget'
                    deviceAndAppManagementAssignmentFilterType = $null
                    groupId = '42a638ec-2bf2-47a8-8f5f-176ce2124b7b'
                }
            )
        }

        $instance.Assignments.Count | Should -Be 1
        $instance.Assignments[0].groupId | Should -Be '42a638ec-2bf2-47a8-8f5f-176ce2124b7b'
    }

    It 'Hydrates a non-array complex property and recurses into nested members' {
        $instance = & $Script:NewInstance @{
            WindowsSetting = @{
                Locale = 'de-CH'
            }
            DomainJoinConfigurations = @(
                @{
                    DomainJoinType = 'azureADJoin'
                    RegionGroup = $null
                    RegionName = 'automatic'
                }
            )
        }

        $instance.WindowsSetting.Locale | Should -Be 'de-CH'
        $instance.DomainJoinConfigurations.Count | Should -Be 1
        $instance.DomainJoinConfigurations[0].DomainJoinType | Should -Be 'azureADJoin'
        $instance.DomainJoinConfigurations[0].RegionGroup | Should -BeNullOrEmpty
    }

    It 'Restored the [ValidateSet] attribute on the embedded complex class' {
        $instance = & $Script:NewInstance @{
            Assignments = @(
                @{
                    dataType = '#microsoft.graph.groupAssignmentTarget'
                }
            )
        }

        $property = $instance.Assignments[0].GetType().GetProperty('dataType')
        $validateSet = $property.GetCustomAttributes([System.Management.Automation.ValidateSetAttribute], $true)
        $validateSet | Should -Not -BeNullOrEmpty
        $validateSet[0].ValidValues | Should -Contain '#microsoft.graph.groupAssignmentTarget'
    }
}

Describe 'M365DSCResourceBase report context' {
    BeforeAll {
        $Script:RoleGroup = New-M365DSCResourceInstance -ResourceName 'EXORoleGroup' -Property @{
            Name = 'Organization Management'
        }
    }

    It 'Detects the marker wherever reporting appended it' {
        $Script:RoleGroup::IsReportContext(@(@{ IsReport = $true })) | Should -BeTrue
        $Script:RoleGroup::IsReportContext(@((, [System.String[]] @('Members')), @{ IsReport = $true })) | Should -BeTrue
    }

    It 'Treats the drift-path arguments as a live comparison' {
        $Script:RoleGroup::IsReportContext(@()) | Should -BeFalse
        $Script:RoleGroup::IsReportContext(@(, [System.String[]] @('Members'))) | Should -BeFalse
        $Script:RoleGroup::IsReportContext(@(@{ IsReport = $false })) | Should -BeFalse
    }

    It 'Leaves the values untouched instead of resolving members for a report' {
        $desiredValues = @{ Name = 'Organization Management'; Members = @('Some Display Name') }
        $currentValues = @{ Name = 'Organization Management'; Members = @('Another Display Name') }
        $valuesToCheck = $desiredValues.Clone()

        $postProcessing = $Script:RoleGroup.GetCompareParameters().PostProcessing
        $result = & $postProcessing $desiredValues $currentValues $valuesToCheck @(@{ IsReport = $true })

        $result.Item1.Members | Should -Be @('Some Display Name')
        $result.Item2.Members | Should -Be @('Another Display Name')
        $result.Item3.Members | Should -Be @('Some Display Name')
    }
}

Describe 'M365DSCResourceBase time helpers' {
    BeforeAll {
        $Script:Resource = New-M365DSCResourceInstance -ResourceName 'EXORoleGroup' -Property @{
            Name = 'Organization Management'
        }
    }

    It 'Reads a value without offset as UTC' {
        $Script:Resource::ConvertToDateTimeOffset('2030-01-01T00:00:00').Offset | Should -Be ([System.TimeSpan]::Zero)
        $Script:Resource::ConvertToDateTimeOffset([System.DateTime]::new(2030, 1, 1, 0, 0, 0, [System.DateTimeKind]::Unspecified)).UtcDateTime |
            Should -Be ([System.DateTime]::new(2030, 1, 1, 0, 0, 0, [System.DateTimeKind]::Utc))
    }

    It 'Returns null for an empty or unparsable date' {
        $Script:Resource::ConvertToDateTimeOffset($null) | Should -BeNullOrEmpty
        $Script:Resource::ConvertToDateTimeOffset('') | Should -BeNullOrEmpty
        $Script:Resource::ConvertToDateTimeOffset('not a date') | Should -BeNullOrEmpty
    }

    It 'Formats dates as round-trip UTC timestamps' {
        $Script:Resource::FormatDateTime('12/31/2024 11:59:59 PM +00:00') | Should -Be '2024-12-31T23:59:59.0000000Z'
        $Script:Resource::FormatDateTime('2030-01-01T02:00:00+02:00') | Should -Be '2030-01-01T00:00:00.0000000Z'
        $Script:Resource::FormatDateTime([System.DateTime]::new(2030, 1, 1, 0, 0, 0, [System.DateTimeKind]::Utc)) | Should -Be '2030-01-01T00:00:00.0000000Z'
        $Script:Resource::FormatDateTime('not a date') | Should -Be 'not a date'
        $Script:Resource::FormatDateTime($null) | Should -BeNullOrEmpty
    }

    It 'Compares dates by instant' {
        $Script:Resource::IsSameDateTime('2030-01-01T00:00:00.0000000Z', '2030-01-01T00:00:00Z') | Should -BeTrue
        $Script:Resource::IsSameDateTime('2030-01-01T02:00:00+02:00', '2030-01-01T00:00:00Z') | Should -BeTrue
        $Script:Resource::IsSameDateTime('2030-01-01T00:00:01Z', '2030-01-01T00:00:00Z') | Should -BeFalse
        $Script:Resource::IsSameDateTime($null, '') | Should -BeTrue
    }

    It 'Formats durations in their shortest ISO 8601 form' {
        $Script:Resource::FormatDuration('P90DT0H0M0S') | Should -Be 'P90D'
        $Script:Resource::FormatDuration([System.TimeSpan]::FromHours(1)) | Should -Be 'PT1H'
        $Script:Resource::FormatDuration('not a duration') | Should -Be 'not a duration'
        $Script:Resource::FormatDuration($null) | Should -BeNullOrEmpty
    }

    It 'Matches a duration against the time between two dates to the minute' {
        $Script:Resource::IsSameDuration('PT8H', '2030-01-01T00:00:00Z', '2030-01-01T08:00:30Z') | Should -BeTrue
        $Script:Resource::IsSameDuration('PT8H', '2030-01-01T00:00:00Z', '2030-01-01T09:00:00Z') | Should -BeFalse
        $Script:Resource::IsSameDuration('not a duration', '2030-01-01T00:00:00Z', '2030-01-01T08:00:00Z') | Should -BeFalse
    }
}

Describe 'M365DSCResourceBase deprecation warning' {
    BeforeEach {
        Mock -CommandName Write-Warning -ModuleName '_Shared' -MockWith {
        }
    }

    It 'Names the resource, its replacement and the information link' {
        $instance = New-M365DSCResourceInstance -ResourceName 'EXOApplicationAccessPolicy' -Property @{ Identity = 'Contoso Policy' }
        $instance.WarnResourceDeprecated("'EXOManagementRoleAssignment'", 'https://learn.microsoft.com/exchange/permissions-exo/application-rbac')

        Should -Invoke -CommandName Write-Warning -ModuleName '_Shared' -Exactly 2
        Should -Invoke -CommandName Write-Warning -ModuleName '_Shared' -Exactly 1 -ParameterFilter {
            $Message -eq "The resource 'EXOApplicationAccessPolicy' is deprecated. It will be removed in a future release. Please use 'EXOManagementRoleAssignment' instead."
        }
        Should -Invoke -CommandName Write-Warning -ModuleName '_Shared' -Exactly 1 -ParameterFilter {
            $Message -eq 'For more information, please visit https://learn.microsoft.com/exchange/permissions-exo/application-rbac'
        }
    }

    It 'Omits the information line when no link is given' {
        $instance = New-M365DSCResourceInstance -ResourceName 'EXOApplicationAccessPolicy' -Property @{ Identity = 'Contoso Policy' }
        $instance.WarnResourceDeprecated("'EXOManagementRoleAssignment'", $null)

        Should -Invoke -CommandName Write-Warning -ModuleName '_Shared' -Exactly 1
    }
}

Describe 'M365DSCResourceBase type data registration' {
    BeforeAll {
        $Script:Group = New-M365DSCResourceInstance -ResourceName 'AADGroup'
    }

    It 'Registers a serialization depth and no extended type system members' {
        $typeData = Get-TypeData -TypeName 'AADGroup'
        $typeData | Should -Not -BeNullOrEmpty
        $typeData.SerializationDepth | Should -Be 25
        @($Script:Group.GetSchemaPropertyNames()).Count | Should -BeGreaterThan 0
        $typeData.Members.Count | Should -Be 0
    }

    It 'Returns array values as arrays' {
        $instance = New-M365DSCResourceInstance -ResourceName 'AADGroup' -Property @{ Members = @('a') }
        $instance.Members -is [System.Array] | Should -BeTrue
        $instance.Members.Count | Should -Be 1
    }

}

Describe 'M365DSCResourceBase bound parameter snapshot' {
    It 'Matches the reflection result for a factory-built instance' {
        $instance = New-M365DSCResourceInstance -ResourceName 'AADGroup' -Property @{
            DisplayName     = 'Contoso'
            MailNickname    = 'contoso'
            SecurityEnabled = $true
            MailEnabled     = $false
            Members         = @('a@contoso.com', 'b@contoso.com')
            Visibility      = 'Private'
            Ensure          = 'Present'
        }

        Assert-SnapshotMatchesOracle -Instance $instance
        $instance.GetBoundParameters().Count | Should -Be 7
    }

    It 'Tracks FromHashtable, empty strings, nulls and empty arrays' {
        $instance = New-M365DSCResourceInstance -ResourceName 'AADGroup' -Property @{
            DisplayName  = 'Contoso'
            MailNickname = 'contoso'
            Visibility   = 'Private'
            Members      = @('a@contoso.com')
        }

        $instance.FromHashtable(@{ Description = 'd'; Visibility = 'Public' })
        Assert-SnapshotMatchesOracle -Instance $instance
        $instance.GetBoundParameters().Visibility | Should -Be 'Public'

        $instance.FromHashtable(@{ Visibility = '' })
        Assert-SnapshotMatchesOracle -Instance $instance
        $instance.GetBoundParameters().ContainsKey('Visibility') | Should -BeFalse

        $instance.FromHashtable(@{ Description = $null })
        Assert-SnapshotMatchesOracle -Instance $instance
        $instance.GetBoundParameters().ContainsKey('Description') | Should -BeFalse

        $instance.FromHashtable(@{ Members = @() })
        Assert-SnapshotMatchesOracle -Instance $instance
        $instance.GetBoundParameters().ContainsKey('Members') | Should -BeTrue
    }

    It 'Returns a copy' {
        $instance = New-M365DSCResourceInstance -ResourceName 'AADGroup' -Property @{ DisplayName = 'Contoso'; Ensure = 'Present' }
        $first = $instance.GetBoundParameters()
        $first.Ensure = 'Absent'
        $first.Remove('DisplayName')
        $instance.GetBoundParameters().Ensure | Should -Be 'Present'
        $instance.GetBoundParameters().DisplayName | Should -Be 'Contoso'
        $instance.Ensure | Should -Be 'Present'
    }

    It 'Keeps complex values by reference' {
        $instance = New-M365DSCResourceInstance -ResourceName 'AADGroup' -Property @{
            AssignedLicenses = @(@{ SkuId = 'x'; DisabledPlans = @('a') })
        }

        $bound = $instance.GetBoundParameters()
        $bound.AssignedLicenses[0].GetType().Name | Should -Be 'MSFT_AADGroupLicense'
        [System.Object]::ReferenceEquals($bound.AssignedLicenses[0], $instance.AssignedLicenses[0]) | Should -BeTrue
    }

    It 'Includes non-schema properties only in GetAllParameters' {
        $instance = New-M365DSCResourceInstance -ResourceName 'AADGroup' -Property @{ DisplayName = 'Contoso' }
        $instance.Filter = "startsWith(displayName, 'C')"
        $instance.GetBoundParameters().ContainsKey('Filter') | Should -BeFalse
        $instance.GetAllParameters().Filter | Should -Be "startsWith(displayName, 'C')"
        $instance.GetAllParameters().DisplayName | Should -Be 'Contoso'
    }

    It 'Reads values that DSC wrote by reflection' {
        $instance = New-M365DSCResourceInstance -ResourceName 'AADGroup'
        Set-PropertyByReflection -Instance $instance -Name 'DisplayName' -Value 'Contoso'
        Set-PropertyByReflection -Instance $instance -Name 'MailNickname' -Value 'contoso'
        Set-PropertyByReflection -Instance $instance -Name 'SecurityEnabled' -Value $true
        Set-PropertyByReflection -Instance $instance -Name 'Members' -Value ([System.String[]] @('a@contoso.com'))

        $bound = $instance.GetBoundParameters()
        $bound.DisplayName | Should -Be 'Contoso'
        $bound.MailNickname | Should -Be 'contoso'
        $bound.SecurityEnabled | Should -BeTrue
        @($bound.Members) | Should -Be @('a@contoso.com')
        Assert-SnapshotMatchesOracle -Instance $instance

        $instance.FromHashtable(@{ Description = 'later' })
        $instance.GetBoundParameters().Description | Should -Be 'later'
        Assert-SnapshotMatchesOracle -Instance $instance
    }

    It 'Detects reflection-populated values when a key is rewritten before the first read' {
        $instance = New-M365DSCResourceInstance -ResourceName 'AADGroup'
        Set-PropertyByReflection -Instance $instance -Name 'DisplayName' -Value 'Contoso'
        Set-PropertyByReflection -Instance $instance -Name 'MailNickname' -Value 'contoso'
        Set-PropertyByReflection -Instance $instance -Name 'Description' -Value 'from dsc'

        $instance.FromHashtable(@{ DisplayName = 'Renamed'; MailNickname = 'renamed' })

        $bound = $instance.GetBoundParameters()
        $bound.DisplayName | Should -Be 'Renamed'
        $bound.MailNickname | Should -Be 'renamed'
        $bound.Description | Should -Be 'from dsc'
        Assert-SnapshotMatchesOracle -Instance $instance
    }

    It 'Detects reflection-populated values when a non-key is written before the first read' {
        $instance = New-M365DSCResourceInstance -ResourceName 'AADGroup'
        Set-PropertyByReflection -Instance $instance -Name 'DisplayName' -Value 'Contoso'
        Set-PropertyByReflection -Instance $instance -Name 'MailNickname' -Value 'contoso'

        $instance.FromHashtable(@{ Description = 'script' })

        $bound = $instance.GetBoundParameters()
        $bound.DisplayName | Should -Be 'Contoso'
        $bound.Description | Should -Be 'script'
        Assert-SnapshotMatchesOracle -Instance $instance
    }

    It 'Captures constructor-time writes' {
        $instance = New-M365DSCResourceInstance -ResourceName 'M365DSCGraphAPIRuleEvaluation'
        $instance.GetBoundParameters().InstancesProperty | Should -Be 'value'
        Assert-SnapshotMatchesOracle -Instance $instance
    }

    It 'Captures constructor-time writes followed by reflection writes' {
        $instance = New-M365DSCResourceInstance -ResourceName 'M365DSCGraphAPIRuleEvaluation'
        Set-PropertyByReflection -Instance $instance -Name 'APIUrl' -Value 'https://graph.microsoft.com/v1.0/users'
        Set-PropertyByReflection -Instance $instance -Name 'RuleDefinition' -Value '*'

        $bound = $instance.GetBoundParameters()
        $bound.APIUrl | Should -Be 'https://graph.microsoft.com/v1.0/users'
        $bound.RuleDefinition | Should -Be '*'
        $bound.InstancesProperty | Should -Be 'value'
        Assert-SnapshotMatchesOracle -Instance $instance
    }

    It 'Matches the reflection result for a fresh instance of every registered resource' {
        $resourcesPath = Join-Path -Path (Get-Module -Name 'Microsoft365DSC').ModuleBase -ChildPath 'DscResources'
        $names = (Get-ChildItem -Path $resourcesPath -Directory -Filter 'MSFT_*').Name -replace '^MSFT_'
        $mismatches = foreach ($name in $names)
        {
            try
            {
                $instance = New-M365DSCResourceInstance -ResourceName $name
            }
            catch
            {
                continue
            }

            $expected = Get-ReflectionOracle -Instance $instance
            $actual = $instance.GetBoundParameters()
            if (@($actual.Keys | Sort-Object) -join ',' -ne (@($expected.Keys | Sort-Object) -join ','))
            {
                $name
            }
        }

        @($mismatches) | Should -BeNullOrEmpty
    }
}

Describe 'M365DSCResourceBase Ensure default' {
    BeforeAll {
        $stubPath = Join-Path -Path $PSScriptRoot -ChildPath '..\Stubs\Microsoft365.psm1' -Resolve
        Import-Module -Name $stubPath -WarningAction SilentlyContinue -Global

        $Script:AUModule = Get-M365DSCResourceModuleName -ResourceName 'AADAdministrativeUnit'
        $secpasswd = ConvertTo-SecureString (New-Guid | Out-String) -AsPlainText -Force
        $Script:Credential = New-Object System.Management.Automation.PSCredential ('tenantadmin@onmicrosoft.com', $secpasswd)

        Mock -CommandName New-M365DSCConnection -ModuleName '_Shared' -MockWith {
            return 'Credentials'
        }

        Mock -CommandName Add-M365DSCTelemetryEvent -ModuleName '_Shared' -MockWith {
        }

        Mock -CommandName Confirm-M365DSCDependencies -ModuleName $Script:AUModule -MockWith {
        }

        Mock -CommandName Get-MgDirectoryAdministrativeUnit -ModuleName $Script:AUModule -MockWith {
        }

        Mock -CommandName New-MgDirectoryAdministrativeUnit -ModuleName $Script:AUModule -MockWith {
            return @{ Id = 'new' }
        }

        Mock -CommandName Start-Sleep -ModuleName $Script:AUModule -MockWith {
        }
    }

    It 'Creates the object when the configuration omits Ensure' {
        $instance = New-M365DSCResourceInstance -ResourceName 'AADAdministrativeUnit' -Property @{
            DisplayName = 'Contoso'
            Credential  = $Script:Credential
        }

        $instance.Set()

        $instance.Ensure | Should -Be 'Present'
        $instance.GetBoundParameters().ContainsKey('Ensure') | Should -BeFalse
        Should -Invoke -CommandName New-MgDirectoryAdministrativeUnit -ModuleName $Script:AUModule -Exactly -Times 1 -ParameterFilter {
            $BodyParameter.DisplayName -eq 'Contoso' -and -not $BodyParameter.ContainsKey('Ensure')
        }
    }

    It 'Keeps an explicit Absent' {
        $instance = New-M365DSCResourceInstance -ResourceName 'AADAdministrativeUnit' -Property @{
            DisplayName = 'Contoso'
            Ensure      = 'Absent'
            Credential  = $Script:Credential
        }

        $instance.Set()

        $instance.Ensure | Should -Be 'Absent'
        $instance.GetBoundParameters().Ensure | Should -Be 'Absent'
        Should -Invoke -CommandName New-MgDirectoryAdministrativeUnit -ModuleName $Script:AUModule -Exactly -Times 0
    }

    It 'Defaults an Ensure that DSC left unset by reflection without binding it' {
        $instance = New-M365DSCResourceInstance -ResourceName 'AADAdministrativeUnit'
        Set-PropertyByReflection -Instance $instance -Name 'DisplayName' -Value 'Contoso'

        $null = $instance.RequiresPowerShellCore()

        $instance.Ensure | Should -Be 'Present'
        $bound = $instance.GetBoundParameters()
        $bound.DisplayName | Should -Be 'Contoso'
        $bound.ContainsKey('Ensure') | Should -BeFalse
        $instance.GetAllParameters().ContainsKey('Ensure') | Should -BeFalse
    }

    It 'Leaves the Ensure of a Get result to Get' {
        $instance = New-M365DSCResourceInstance -ResourceName 'AADAdministrativeUnit' -Property @{
            DisplayName = 'Contoso'
            Credential  = $Script:Credential
        }

        $instance.Get().Ensure | Should -Be 'Absent'
        $instance.Get().ToHashtable().Ensure | Should -Be 'Absent'

        $result = $instance.AsResult(@{ DisplayName = 'Contoso' })
        $result.Ensure | Should -BeNullOrEmpty
        $result.ToHashtable().ContainsKey('Ensure') | Should -BeFalse
    }

    It 'Ignores resources without an Ensure property' {
        $instance = New-M365DSCResourceInstance -ResourceName 'M365DSCGraphAPIRuleEvaluation'

        $null = $instance.RequiresPowerShellCore()

        $instance.GetSchemaPropertyNames() | Should -Not -Contain 'Ensure'
        Assert-SnapshotMatchesOracle -Instance $instance
    }
}

Describe 'M365DSCResourceBase property validation' {
    It 'Enforces ValidateRange through the factory and FromHashtable' {
        { New-M365DSCResourceInstance -ResourceName 'AADAttributeSet' -Property @{ MaxAttributesPerSet = 501 } } |
            Should -Throw -ExpectedMessage '*outside the valid range*'
        $instance = New-M365DSCResourceInstance -ResourceName 'AADAttributeSet' -Property @{ Id = 'set' }
        { $instance.FromHashtable(@{ MaxAttributesPerSet = 501 }) } | Should -Throw -ExpectedMessage '*outside the valid range*'
        $instance.GetBoundParameters().ContainsKey('MaxAttributesPerSet') | Should -BeFalse
        $instance.FromHashtable(@{ MaxAttributesPerSet = 5 })
        $instance.GetBoundParameters().MaxAttributesPerSet | Should -Be 5
    }

    It 'Enforces ValidateNotNullOrEmpty' {
        { New-M365DSCResourceInstance -ResourceName 'IntuneAppConfigurationDevicePolicy' -Property @{ EncodedSettingXml = '' } } |
            Should -Throw -ExpectedMessage '*may not be null or empty*'
    }

    It 'Enforces ValidateSet' {
        { New-M365DSCResourceInstance -ResourceName 'AADGroup' -Property @{ Visibility = 'Nope' } } |
            Should -Throw -ExpectedMessage '*not valid for property*'
    }

    It 'Nulls an empty collection on a property with enumerated validation' {
        $instance = New-M365DSCResourceInstance -ResourceName 'AADConditionalAccessPolicy' -Property @{ IncludeGuestOrExternalUserTypes = @() }
        $instance.GetBoundParameters().ContainsKey('IncludeGuestOrExternalUserTypes') | Should -BeFalse
        $instance.FromHashtable(@{ IncludeGuestOrExternalUserTypes = @('none') })
        @($instance.GetBoundParameters().IncludeGuestOrExternalUserTypes) | Should -Be @('none')
    }

    It 'Enforces ValidateLength and treats an empty string as unset' {
        { New-M365DSCResourceInstance -ResourceName 'EXORoleGroup' -Property @{ Name = ('n' * 65) } } |
            Should -Throw -ExpectedMessage '*length must be between 1 and 64*'
        $instance = New-M365DSCResourceInstance -ResourceName 'EXORoleGroup' -Property @{ Name = ('n' * 64) }
        $instance.Name.Length | Should -Be 64
        $instance.FromHashtable(@{ Name = '' })
        $instance.Name | Should -BeNullOrEmpty
        $instance.GetBoundParameters().ContainsKey('Name') | Should -BeFalse
    }

    It 'Enforces ValidatePattern and treats an empty string as unset' {
        { New-M365DSCResourceInstance -ResourceName 'EXOAcceptedDomain' -Property @{ Identity = 'not a domain!' } } |
            Should -Throw -ExpectedMessage '*does not match the pattern*'
        $instance = New-M365DSCResourceInstance -ResourceName 'EXOAcceptedDomain' -Property @{ Identity = 'contoso.com' }
        $instance.Identity | Should -Be 'contoso.com'
        $instance.FromHashtable(@{ Identity = '' })
        $instance.Identity | Should -BeNullOrEmpty
        $instance.GetBoundParameters().ContainsKey('Identity') | Should -BeFalse
    }
}

Describe 'M365DSCResourceBase module re-import' {
    It 'Registers the type data again after a forced re-import, in an isolated session' {
        $repoRoot = Join-Path -Path $PSScriptRoot -ChildPath '..\..\..' -Resolve
        $manifestPath = Join-Path -Path $repoRoot -ChildPath 'Modules\Microsoft365DSC\Microsoft365DSC.psd1'
        $isolatedCommand = @"
Import-Module -Name '$manifestPath' -Global
Import-Module -Name '$manifestPath' -Global -Force
`$instance = New-M365DSCResourceInstance -ResourceName 'AADGroup' -Property @{ DisplayName = 'after' }
[PSCustomObject]@{
    DisplayName         = `$instance.DisplayName
    BoundDisplayName    = `$instance.GetBoundParameters().DisplayName
    TypeDataMemberCount = @((Get-TypeData -TypeName 'AADGroup').Members.Keys).Count
    SerializationDepth  = (Get-TypeData -TypeName 'AADGroup').SerializationDepth
} | ConvertTo-Json -Depth 4 -Compress
"@
        $isolatedOutput = & (Get-Process -Id $PID).Path -NoProfile -NonInteractive -Command $isolatedCommand
        $result = $isolatedOutput | ConvertFrom-Json

        $result | Should -Not -BeNullOrEmpty
        $result.DisplayName | Should -Be 'after'
        $result.BoundDisplayName | Should -Be 'after'
        $result.TypeDataMemberCount | Should -Be 0
        $result.SerializationDepth | Should -Be 25
    }
}
