Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath '..\..\..\Utilities\ApiSurface\M365DSCApiSurface.psd1') -Force

InModuleScope -ModuleName 'M365DSCApiSurface' {

    BeforeAll {
        function New-ShimEntry
        {
            param
            (
                [System.String] $Method = 'GET',
                [System.String] $Uri = '/applications',
                [System.String] $ItemUri,
                [System.String[]] $Parameter = @('All')
            )

            return [ordered]@{
                helper     = 'Invoke-M365DSCGraphShimGetResource'
                method     = $Method
                apiVersion = 'v1.0'
                uri        = $Uri
                itemUri    = $ItemUri
                parameters = $Parameter
            }
        }

        function New-SdkEntry
        {
            param
            (
                [System.Object[]] $Variant = @(),
                [System.Collections.IDictionary] $Parameter = @{ All = 'System.Management.Automation.SwitchParameter' }
            )

            return [ordered]@{
                workload      = 'MicrosoftGraph'
                module        = 'Microsoft.Graph.Applications'
                moduleVersion = '2.35.1'
                apiVersion    = 'v1.0'
                variants      = $Variant
                parameters    = $Parameter
            }
        }

        function New-Variant
        {
            param
            (
                [System.String] $Method = 'GET',
                [System.String] $Uri = '/applications'
            )

            return [ordered]@{ method = $Method; uri = $Uri; apiVersion = 'v1.0' }
        }

        function New-ShimSnapshot
        {
            param
            (
                [System.Collections.IDictionary] $Shim = @{},
                [System.Collections.IDictionary] $Cmdlet = @{},
                [System.Collections.IDictionary] $Override = @{}
            )

            return [ordered]@{
                shim            = $Shim
                cmdlets         = $Cmdlet
                cmdletOverrides = $Override
            }
        }

        function New-ShimOrigin
        {
            param
            (
                [System.String] $Resource = 'AADThing',
                [System.String] $Module = 'Microsoft.Graph.Applications',
                [System.String[]] $Cmdlet = @('Get-MgApplication')
            )

            return [PSCustomObject]@{
                Resource = $Resource
                Workload = 'MicrosoftGraph'
                Commands = @($Cmdlet | ForEach-Object -Process { [PSCustomObject]@{ Name = $_; Module = $Module } })
            }
        }

        $script:exclusion = [PSCustomObject]@{
            nonShimCmdlets = @([PSCustomObject]@{ cmdlet = 'Invoke-MgGraphRequest'; reason = 'wrapped by the shim itself' })
        }

        function Invoke-ShimCompare
        {
            param
            (
                [System.Object] $Snapshot,
                [System.Object[]] $Origin = @()
            )

            return @(Compare-Shim -Current $Snapshot -Origin $Origin -Exclusion $script:exclusion)
        }
    }

    Describe 'ConvertTo-ShimRouteKey' {
        It 'erases the placeholder text on both spellings' {
            ConvertTo-ShimRouteKey -Uri '/applications/{ApplicationId}' |
                Should -BeExactly (ConvertTo-ShimRouteKey -Uri '/applications/{application-id}')
        }

        It 'keeps the literal segments and their case' {
            ConvertTo-ShimRouteKey -Uri '/identityGovernance/entitlementManagement/accessPackages' |
                Should -BeExactly '/identityGovernance/entitlementManagement/accessPackages'
        }

        It 'leaves a literal ref segment alone' {
            ConvertTo-ShimRouteKey -Uri '/groups/{GroupId}/owners/$ref' | Should -BeExactly '/groups/{}/owners/$ref'
        }
    }

    Describe 'SHIM-MISSING' {
        It 'reports a called cmdlet the shim does not export, naming its callers' {
            $snapshot = New-ShimSnapshot -Shim @{ 'Get-MgApplication' = (New-ShimEntry) }
            $origin = @(
                (New-ShimOrigin -Resource 'AADApplication' -Cmdlet @('Get-MgApplication', 'Update-MgApplicationExtra'))
                (New-ShimOrigin -Resource 'AADOther' -Cmdlet @('Update-MgApplicationExtra'))
            )

            $findings = @(Invoke-ShimCompare -Snapshot $snapshot -Origin $origin)

            $findings | Should -HaveCount 1
            $findings[0].code | Should -BeExactly 'SHIM-MISSING'
            $findings[0].id | Should -BeExactly 'SHIM-MISSING:Update-MgApplicationExtra'
            @($findings[0].evidence.calledBy) | Should -Be @('AADApplication', 'AADOther')
        }

        It 'is breaking and not auto-fixable' {
            $snapshot = New-ShimSnapshot -Shim @{}
            $findings = @(Invoke-ShimCompare -Snapshot $snapshot -Origin @(New-ShimOrigin))

            $findings[0].severity | Should -BeExactly 'breaking'
            $findings[0].autoFixable | Should -BeFalse
        }

        It 'says nothing about an excluded infrastructure cmdlet' {
            $snapshot = New-ShimSnapshot -Shim @{}
            $origin = @(New-ShimOrigin -Cmdlet @('Invoke-MgGraphRequest'))

            Invoke-ShimCompare -Snapshot $snapshot -Origin $origin | Should -HaveCount 0
        }

        It 'says nothing about a cmdlet from another workload' {
            $snapshot = New-ShimSnapshot -Shim @{}
            $origin = @(New-ShimOrigin -Module 'ExchangeOnlineManagement' -Cmdlet @('Get-Mailbox'))

            Invoke-ShimCompare -Snapshot $snapshot -Origin $origin | Should -HaveCount 0
        }
    }

    Describe 'SHIM-STALE, routes' {
        It 'reports a wrapper whose route moved' {
            $snapshot = New-ShimSnapshot -Shim @{ 'Get-MgApplication' = (New-ShimEntry -Uri '/applications') } `
                -Cmdlet @{ 'Get-MgApplication' = (New-SdkEntry -Variant @((New-Variant -Uri '/applicationTemplates'))) }

            $findings = @(Invoke-ShimCompare -Snapshot $snapshot)

            $findings | Should -HaveCount 1
            $findings[0].code | Should -BeExactly 'SHIM-STALE'
            $findings[0].evidence.reason | Should -BeExactly 'route'
        }

        It 'says nothing when only the placeholder spelling differs' {
            $snapshot = New-ShimSnapshot -Shim @{ 'Get-MgApplication' = (New-ShimEntry -Uri '/applications/{ApplicationId}') } `
                -Cmdlet @{ 'Get-MgApplication' = (New-SdkEntry -Variant @((New-Variant -Uri '/applications/{application-id}'))) }

            Invoke-ShimCompare -Snapshot $snapshot | Should -HaveCount 0
        }

        It 'says nothing about a literal ref route' {
            $snapshot = New-ShimSnapshot -Shim @{ 'New-MgGroupOwnerByRef' = (New-ShimEntry -Method 'POST' -Uri '/groups/{GroupId}/owners/$ref') } `
                -Cmdlet @{ 'New-MgGroupOwnerByRef' = (New-SdkEntry -Variant @((New-Variant -Method 'POST' -Uri '/groups/{group-id}/owners/$ref'))) }

            Invoke-ShimCompare -Snapshot $snapshot | Should -HaveCount 0
        }

        It 'compares the item route as well as the collection route' {
            $snapshot = New-ShimSnapshot -Shim @{ 'Get-MgApplication' = (New-ShimEntry -Uri '/applications' -ItemUri '/applications/{ApplicationId}/moved') } `
                -Cmdlet @{ 'Get-MgApplication' = (New-SdkEntry -Variant @(
                            (New-Variant -Uri '/applications')
                            (New-Variant -Uri '/applications/{application-id}')
                        )) }

            $findings = @(Invoke-ShimCompare -Snapshot $snapshot)
            $findings | Should -HaveCount 1
            $findings[0].from.uri | Should -BeExactly '/applications/{ApplicationId}/moved'
        }

        It 'accepts a route the overrides correct' {
            $snapshot = New-ShimSnapshot -Shim @{ 'Get-MgThing' = (New-ShimEntry -Uri '/deviceManagement/thing') } `
                -Cmdlet @{ 'Get-MgThing' = (New-SdkEntry -Variant @((New-Variant -Method 'POST' -Uri '/deviceManagement/other'))) } `
                -Override @{ 'Get-MgThing' = [ordered]@{ variants = @((New-Variant -Uri '/deviceManagement/thing')) } }

            Invoke-ShimCompare -Snapshot $snapshot | Should -HaveCount 0
        }

        It 'says nothing when the SDK carries no route at all' {
            $snapshot = New-ShimSnapshot -Shim @{ 'Get-MgApplication' = (New-ShimEntry) } `
                -Cmdlet @{ 'Get-MgApplication' = (New-SdkEntry -Variant @()) }

            Invoke-ShimCompare -Snapshot $snapshot | Should -HaveCount 0
        }

        It 'treats a method change as stale' {
            $snapshot = New-ShimSnapshot -Shim @{ 'Get-MgApplication' = (New-ShimEntry -Method 'GET' -Uri '/applications') } `
                -Cmdlet @{ 'Get-MgApplication' = (New-SdkEntry -Variant @((New-Variant -Method 'POST' -Uri '/applications'))) }

            @(Invoke-ShimCompare -Snapshot $snapshot) | Should -HaveCount 1
        }
    }

    Describe 'SHIM-STALE, parameters' {
        It 'reports an SDK parameter the wrapper does not expose' {
            $snapshot = New-ShimSnapshot -Shim @{ 'Get-MgApplication' = (New-ShimEntry -Parameter @('All')) } `
                -Cmdlet @{ 'Get-MgApplication' = (New-SdkEntry -Variant @((New-Variant)) -Parameter ([ordered]@{
                                All      = 'System.Management.Automation.SwitchParameter'
                                Expanded = 'System.String'
                            })) }

            $findings = @(Invoke-ShimCompare -Snapshot $snapshot)
            $findings | Should -HaveCount 1
            $findings[0].evidence.reason | Should -BeExactly 'parameters'
            @($findings[0].to.added) | Should -Be @('Expanded')
        }

        It 'says nothing about a parameter only the wrapper carries' {
            $snapshot = New-ShimSnapshot -Shim @{ 'Get-MgApplication' = (New-ShimEntry -Parameter @('All', 'Break', 'HttpPipelineAppend')) } `
                -Cmdlet @{ 'Get-MgApplication' = (New-SdkEntry -Variant @((New-Variant))) }

            Invoke-ShimCompare -Snapshot $snapshot | Should -HaveCount 0
        }

        It 'is auto-fixable, because the fix is a whole shim regeneration' {
            $snapshot = New-ShimSnapshot -Shim @{ 'Get-MgApplication' = (New-ShimEntry -Uri '/moved') } `
                -Cmdlet @{ 'Get-MgApplication' = (New-SdkEntry -Variant @((New-Variant))) }

            @(Invoke-ShimCompare -Snapshot $snapshot)[0].autoFixable | Should -BeTrue
        }
    }

    Describe 'Get-ShimSurface route resolution' {
        BeforeAll {
            $script:shimPath = Join-Path -Path $TestDrive -ChildPath 'FakeShim.psm1'
            $script:manifestPath = Join-Path -Path $TestDrive -ChildPath 'FakeShim.psd1'

            $module = @'
function Get-MgFake
{
    param ([System.String] $FakeId, [switch] $All)
    $singleItemUri = if ($PSBoundParameters.ContainsKey('FakeId')) { "/v1.0/fakes/$($FakeId)" } else { $null }
    return Invoke-M365DSCGraphShimGetResource -BoundParameters $PSBoundParameters -CollectionUri "/v1.0/fakes" -SingleItemUri $singleItemUri
}

function New-MgFakeOwnerByRef
{
    param ([System.String] $FakeId)
    return Invoke-M365DSCGraphShimWriteResource -BoundParameters $PSBoundParameters -Uri "/v1.0/fakes/$($FakeId)/owners/`$ref" -Method 'POST'
}
'@
            Set-Content -Path $script:shimPath -Value $module
            Set-Content -Path $script:manifestPath -Value "@{ FunctionsToExport = @('Get-MgFake', 'New-MgFakeOwnerByRef') }"

            $script:surface = Get-ShimSurface -ModulePath $script:shimPath -ManifestPath $script:manifestPath
        }

        It 'resolves both routes of a Get wrapper' {
            $script:surface.Shim['Get-MgFake'].uri | Should -BeExactly '/fakes'
            $script:surface.Shim['Get-MgFake'].itemUri | Should -BeExactly '/fakes/{FakeId}'
        }

        It 'keeps a literal ref segment out of the placeholder rewrite' {
            $script:surface.Shim['New-MgFakeOwnerByRef'].uri | Should -BeExactly '/fakes/{FakeId}/owners/$ref'
        }

        It 'resolves a route for every exported function' {
            $script:surface.Unparsed | Should -HaveCount 0
        }
    }
}
