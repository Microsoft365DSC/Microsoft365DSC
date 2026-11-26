BeforeAll {
    $script:ScriptPath = Join-Path -Path $PSScriptRoot -ChildPath '../../../Utilities/Find-M365DSCRawGraphCall.ps1' -Resolve

    <#
    .SYNOPSIS
        Builds a repository shaped fixture with one resource module and its settings.json.

    .PARAMETER ModuleBody
        Specifies the body of the resource module.

    .PARAMETER Command
        Specifies the cmdlets the resource declares in its commands array.
    #>
    function New-RawGraphFixture
    {
        [CmdletBinding()]
        [OutputType([System.Collections.Hashtable])]
        param
        (
            [Parameter(Mandatory = $true)]
            [System.String]
            $ModuleBody,

            [Parameter()]
            [System.String[]]
            $Command = @()
        )

        $root = Join-Path -Path $TestDrive -ChildPath ([System.Guid]::NewGuid().ToString())
        $resourcePath = Join-Path -Path $root -ChildPath 'DscResources'
        $folder = Join-Path -Path $resourcePath -ChildPath 'MSFT_TestResource'
        $null = New-Item -Path $folder -ItemType Directory -Force

        Set-Content -Path (Join-Path -Path $folder -ChildPath 'MSFT_TestResource.psm1') -Value $ModuleBody -Encoding utf8
        $settings = [ordered]@{
            resourceName = 'TestResource'
            commands     = @(
                [ordered]@{ module = 'Microsoft.Graph.Beta.Groups'; cmdlets = @($Command) }
            )
        }
        Set-Content -Path (Join-Path -Path $folder -ChildPath 'settings.json') -Value ($settings | ConvertTo-Json -Depth 10) -Encoding utf8

        $mapping = [ordered]@{
            'Get-MgBetaGroup'    = [ordered]@{
                SourceModule = 'Microsoft.Graph.Beta.Groups'
                ApiVersion   = 'beta'
                Variants     = @(
                    [ordered]@{ Method = 'GET'; URI = '/groups'; ApiVersion = 'beta' }
                    [ordered]@{ Method = 'GET'; URI = '/groups/{group-id}'; ApiVersion = 'beta' }
                )
            }
            'Update-MgBetaGroup' = [ordered]@{
                SourceModule = 'Microsoft.Graph.Beta.Groups'
                ApiVersion   = 'beta'
                Variants     = @(
                    [ordered]@{ Method = 'PATCH'; URI = '/groups/{group-id}'; ApiVersion = 'beta' }
                )
            }
        }
        $mappingPath = Join-Path -Path $root -ChildPath 'cmdlet-mapping.json'
        Set-Content -Path $mappingPath -Value ($mapping | ConvertTo-Json -Depth 10) -Encoding utf8

        $manifestPath = Join-Path -Path $root -ChildPath 'M365DSCGraphShim.psd1'
        Set-Content -Path $manifestPath -Value "@{ FunctionsToExport = 'Get-MgBetaGroup', 'Update-MgBetaGroup' }" -Encoding utf8

        return @{
            ResourcePath = $resourcePath
            MappingPath  = $mappingPath
            ManifestPath = $manifestPath
            OutputPath   = Join-Path -Path $root -ChildPath 'worklist.md'
        }
    }

    <#
    .SYNOPSIS
        Runs the finder against a fixture and returns its summary object.

    .PARAMETER Fixture
        Specifies the fixture from New-RawGraphFixture.
    #>
    function Invoke-RawGraphFinder
    {
        [CmdletBinding()]
        param
        (
            [Parameter(Mandatory = $true)]
            [System.Collections.Hashtable]
            $Fixture
        )

        return & $script:ScriptPath -ResourcePath $Fixture.ResourcePath `
            -CmdletMappingPath $Fixture.MappingPath `
            -ShimManifestPath $Fixture.ManifestPath `
            -OutputPath $Fixture.OutputPath `
            -SkipSdkLookup 6> $null
    }
}

Describe 'Find-M365DSCRawGraphCall' {
    It 'reports a literal route the shim already serves' {
        $fixture = New-RawGraphFixture -ModuleBody @'
class TestResource
{
    [void] Set()
    {
        Invoke-MgGraphRequest -Method GET -Uri '/beta/groups'
    }
}
'@
        $result = Invoke-RawGraphFinder -Fixture $fixture

        $result.Candidates.Count | Should -Be 1
        $result.Candidates[0].Route | Should -Be 'beta/groups'
        $result.Candidates[0].Candidate | Should -Be 'Get-MgBetaGroup'
        $result.Candidates[0].InShim | Should -BeTrue
    }

    It 'says nothing about a route the resource already calls through its cmdlet' {
        $fixture = New-RawGraphFixture -Command @('Get-MgBetaGroup') -ModuleBody @'
class TestResource
{
    [void] Set()
    {
        Invoke-MgGraphRequest -Method GET -Uri '/beta/groups'
    }
}
'@
        $result = Invoke-RawGraphFinder -Fixture $fixture

        $result.Candidates.Count | Should -Be 0
    }

    It 'resolves a URI held in a variable and turns an id segment into a placeholder' {
        $fixture = New-RawGraphFixture -ModuleBody @'
class TestResource
{
    [void] Set()
    {
        $uri = "/beta/groups/$($this.Id)"
        Invoke-MgGraphRequest -Method PATCH -Uri $uri -Body $params
    }
}
'@
        $result = Invoke-RawGraphFinder -Fixture $fixture

        $result.Candidates.Count | Should -Be 1
        $result.Candidates[0].Route | Should -Be 'beta/groups/{id}'
        $result.Candidates[0].Candidate | Should -Be 'Update-MgBetaGroup'
    }

    It 'drops the service root a concatenation adds' {
        $fixture = New-RawGraphFixture -ModuleBody @'
class TestResource
{
    [void] Set()
    {
        $url = (Get-MSCloudLoginConnectionProfile -Workload MicrosoftGraph).ResourceUrl + 'beta/groups'
        Invoke-MgGraphRequest -Method GET -Uri $url
    }
}
'@
        $result = Invoke-RawGraphFinder -Fixture $fixture

        $result.Candidates.Count | Should -Be 1
        $result.Candidates[0].Route | Should -Be 'beta/groups'
    }

    It 'binds a positional URI when only the method is named' {
        $fixture = New-RawGraphFixture -ModuleBody @'
class TestResource
{
    [void] Set()
    {
        Invoke-MgGraphRequest '/beta/groups' -Method GET
    }
}
'@
        $result = Invoke-RawGraphFinder -Fixture $fixture

        $result.Candidates.Count | Should -Be 1
        $result.Candidates[0].Route | Should -Be 'beta/groups'
    }

    It 'leaves a route with no cmdlet on the REST only list' {
        $fixture = New-RawGraphFixture -ModuleBody @'
class TestResource
{
    [void] Set()
    {
        Invoke-MgGraphRequest -Method GET -Uri '/beta/identityProtection/policy'
    }
}
'@
        $result = Invoke-RawGraphFinder -Fixture $fixture

        $result.Candidates.Count | Should -Be 0
        $result.RestOnly.Count | Should -Be 1
        $result.RestOnly[0].Route | Should -Be 'beta/identityProtection/policy'
    }

    It 'never guesses a URI it cannot derive' {
        $fixture = New-RawGraphFixture -ModuleBody @'
class TestResource
{
    [void] Set()
    {
        Invoke-MgGraphRequest @request -ErrorAction Stop
    }
}
'@
        $result = Invoke-RawGraphFinder -Fixture $fixture

        $result.Candidates.Count | Should -Be 0
        $result.Unresolved.Count | Should -Be 1
        $result.Unresolved[0].Note | Should -Be 'The call passes no Uri parameter.'
    }

    It 'writes the worklist with a section per outcome' {
        $fixture = New-RawGraphFixture -ModuleBody @'
class TestResource
{
    [void] Set()
    {
        Invoke-MgGraphRequest -Method GET -Uri '/beta/groups'
    }
}
'@
        $null = Invoke-RawGraphFinder -Fixture $fixture

        $content = Get-Content -Path $fixture.OutputPath -Raw
        $content | Should -Match '## Candidates'
        $content | Should -Match '## Shim gaps'
        $content | Should -Match '## REST only'
        $content | Should -Match '## Unresolved call sites'
        $content | Should -Match 'Get-MgBetaGroup'
    }
}
