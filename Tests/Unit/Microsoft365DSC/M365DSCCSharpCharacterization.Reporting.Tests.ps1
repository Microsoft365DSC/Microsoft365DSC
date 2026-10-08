BeforeAll {
    Import-Module "$PSScriptRoot/../../../Modules/Microsoft365DSC/Modules/M365DSCDllLoader.psm1" -Force -Global
    Initialize-M365DSCDllLoader

    $Script:FixtureRoot = Join-Path -Path $PSScriptRoot -ChildPath 'Fixtures/Markdown'
    $Script:ModuleRoot = Join-Path -Path $PSScriptRoot -ChildPath '../../../Modules/Microsoft365DSC'

    function Invoke-MarkdownConverter
    {
        [CmdletBinding()]
        param
        (
            [Parameter(Mandatory = $true)] [System.Collections.IDictionary[]] $Resources,
            [Parameter()] [System.String] $ModuleRoot = $Script:ModuleRoot,
            [Parameter()] [System.String] $OrganizationName = 'fabrikamtest.onmicrosoft.com',
            [Parameter()] [System.String] $OutputPath = (Join-Path -Path $TestDrive -ChildPath ([System.Guid]::NewGuid())),
            [Parameter()] [Switch] $Compact,
            [Parameter()] [Switch] $SplitByResource,
            [Parameter()] [System.Collections.IDictionary] $MandatoryProperties,
            [Parameter()] [System.Collections.Generic.List[System.String]] $Warnings
        )

        $request = [Microsoft365DSC.Reporting.ReportRequest]::new()
        $request.Resources = [System.Collections.Generic.List[System.Collections.IDictionary]] $Resources
        $request.OutputPath = $OutputPath
        $request.ModuleRoot = $ModuleRoot
        $request.OrganizationName = $OrganizationName
        $request.TenantGuid = '5aa4dce1-1234-4567-89ab-0123456789ab'
        $request.IncludeAllInformation = -not $Compact.IsPresent
        $request.SplitByResource = $SplitByResource.IsPresent
        if ($null -ne $MandatoryProperties)
        {
            $request.SuppressDuplicates = $true
            $request.MandatoryProperties = [Microsoft365DSC.Reporting.Configuration.DictionaryMandatoryPropertySource]::new($MandatoryProperties)
        }
        if ($null -ne $Warnings)
        {
            $request.Warn = [System.Action[System.String]] { param($Message) $Warnings.Add($Message) }
        }

        return , [Microsoft365DSC.Reporting.ReportConverterRegistry]::Convert('Markdown', $request)
    }

    function Get-Blueprint
    {
        [CmdletBinding()]
        param([Parameter(Mandatory = $true)] [System.String] $Name)

        $path = Join-Path -Path $Script:FixtureRoot -ChildPath "Blueprints/$Name.json"
        return [System.Collections.IDictionary[]] @(Get-Content -Path $path -Raw | ConvertFrom-Json -AsHashtable -Depth 40 -DateKind String)
    }

    function New-MetadataRoot
    {
        [CmdletBinding()]
        param([Parameter(Mandatory = $true)] [System.String[]] $Parameters)

        $root = Join-Path -Path $TestDrive -ChildPath ([System.Guid]::NewGuid())
        $resourceFolder = Join-Path -Path $root -ChildPath 'DscResources/MSFT_TeamsTestPolicy'
        $null = New-Item -Path $resourceFolder -ItemType Directory -Force
        $schema = @(@{
                ClassName  = 'MSFT_TeamsTestPolicy'
                Parameters = @($Parameters | ForEach-Object -Process {
                        @{ Name = $_; Option = 'Write'; CIMType = 'String'; Description = "Description of $_." }
                    })
            })
        Set-Content -Path (Join-Path -Path $root -ChildPath 'SchemaDefinition.json') -Value (ConvertTo-Json $schema -Depth 10)
        Set-Content -Path (Join-Path -Path $root -ChildPath 'ResourcePermissions.json') -Value (ConvertTo-Json @{ TeamsTestPolicy = @{ permissions = @{ } } } -Depth 10)
        Set-Content -Path (Join-Path -Path $resourceFolder -ChildPath 'readme.md') -Value "# TeamsTestPolicy`r`n`r`n## Description`r`n`r`nTest resource.`r`n" -NoNewline
        return $root
    }

    function Get-Cell
    {
        [CmdletBinding()]
        param([Parameter(Mandatory = $true)] [System.String] $Path, [Parameter(Mandatory = $true)] [System.String] $Parameter)

        $cells = (Get-Content -Path $Path | Where-Object -FilterScript { $_.StartsWith("| **$Parameter** |") }).Split('|')
        return $cells[$cells.Length - 2].Trim()
    }
}

Describe 'Markdown report' {
    It 'Writes the expected <Case> report for <Name>' -ForEach @(
        @{ Name = 'TeamsVoiceRoutingPolicy'; Case = 'New' }
        @{ Name = 'TeamsVoiceRoutingPolicy'; Case = 'Remove' }
        @{ Name = 'IntuneAccountProtectionLocalUserGroupMembershipPolicy'; Case = 'Update' }
        @{ Name = 'IntuneSettingCatalogCustomPolicyWindows10'; Case = 'New' }
        @{ Name = 'IntuneExploitProtectionPolicyWindows10SettingCatalog'; Case = 'New' }
        @{ Name = 'IntuneDeviceConfigurationCustomPolicyWindows10'; Case = 'New' }
    ) {
        $written = Invoke-MarkdownConverter -Resources (Get-Blueprint -Name "$Name-$Case") -SplitByResource

        $written.Count | Should -Be 1
        $relativePath = Join-Path -Path (Split-Path -Path $written[0] -Parent | Split-Path -Leaf) -ChildPath (Split-Path -Path $written[0] -Leaf)
        $expected = Get-Content -Path (Join-Path -Path $Script:FixtureRoot -ChildPath "Expected/$Case/$relativePath") -Raw
        $actual = Get-Content -Path $written[0] -Raw
        $actual | Should -Match "`r`n"
        ($actual -replace "`r`n", "`n") | Should -BeExactly ($expected -replace "`r`n", "`n")
    }

    It 'Reports every property and every type with all information' {
        $report = Get-Content -Path (Invoke-MarkdownConverter -Resources (Get-Blueprint -Name 'IntuneSettingCatalogCustomPolicyWindows10-New') -SplitByResource)[0]

        $report | Should -Contain '| **TemplateReference** | Write | MSFT_MicrosoftGraphdeviceManagementConfigurationPolicyTemplateReference | Template reference information | | |'
        $report | Should -Contain '### MSFT_MicrosoftGraphdeviceManagementConfigurationPolicyTemplateReference'
    }

    It 'Reports the configured properties and the referenced types only without all information' {
        $report = Get-Content -Path (Invoke-MarkdownConverter -Resources (Get-Blueprint -Name 'IntuneSettingCatalogCustomPolicyWindows10-New') -Compact -SplitByResource)[0]

        $report | Where-Object -FilterScript { $_.StartsWith('| **') -and $_.EndsWith('| |') } | Should -BeNullOrEmpty
        $report | Where-Object -FilterScript { $_.StartsWith('### MSFT_') } | Should -BeExactly @(
            '### MSFT_DeviceManagementConfigurationPolicyAssignments_1'
            '### MSFT_DeviceManagementConfigurationPolicyAssignments_2'
            '### MSFT_MicrosoftGraphDeviceManagementConfigurationChoiceSettingValue_1'
            '### MSFT_MicrosoftGraphdeviceManagementConfigurationSetting_1'
            '### MSFT_MicrosoftGraphDeviceManagementConfigurationSettingInstance_1'
        )
    }

    It 'Reports the property name, data type and value without all information' {
        $report = Get-Content -Path (Invoke-MarkdownConverter -Resources (Get-Blueprint -Name 'TeamsVoiceRoutingPolicy-New') -Compact -SplitByResource)[0]

        $report[4] | Should -BeExactly '| Parameter | DataType | Value |'
        $report | Where-Object -FilterScript { $_.StartsWith('| **Identity** |') } |
            Should -BeExactly '| **Identity** | String | TeamsVoiceRoutingPolicy_1 |'
        $report | Should -Not -Contain '## Permissions'
    }
}

Describe 'Markdown report layout' {
    BeforeAll {
        $Script:LayoutModuleRoot = New-MetadataRoot -Parameters @('Identity')
        $Script:LayoutResources = @(
            @{ ResourceName = 'TeamsTestPolicy'; ResourceInstanceName = 'First'; Identity = 'A' }
            @{ ResourceName = 'TeamsTestPolicy'; ResourceInstanceName = 'Second'; Identity = 'B' }
        )
    }

    It 'Writes every resource instance into the document of the output path' {
        $path = Join-Path -Path $TestDrive -ChildPath ([System.Guid]::NewGuid().ToString() + '/Report.md')

        $written = Invoke-MarkdownConverter -Resources $Script:LayoutResources -ModuleRoot $Script:LayoutModuleRoot -OutputPath $path

        $written | Should -BeExactly @($path)
        (Get-Content -Path $path | Where-Object -FilterScript { $_.StartsWith('# ') }) | Should -BeExactly @('# First', '# Second')
    }

    It 'Writes one document per resource instance and per workload when it is split' {
        $written = Invoke-MarkdownConverter -Resources $Script:LayoutResources -ModuleRoot $Script:LayoutModuleRoot -SplitByResource

        $written | ForEach-Object -Process { Split-Path -Path $_ -Leaf } | Should -BeExactly @('First.md', 'Second.md')
        Split-Path -Path (Split-Path -Path $written[0] -Parent) -Leaf | Should -BeExactly 'Teams'
    }

    It 'Appends a counter to colliding file names and skips an unknown area' {
        $resources = @(
            @{ ResourceName = 'TeamsTestPolicy'; ResourceInstanceName = 'Policy [A]'; Identity = 'A' }
            @{ ResourceName = 'TeamsTestPolicy'; ResourceInstanceName = 'Policy (A)'; Identity = 'B' }
            @{ ResourceName = 'UnknownPolicy'; ResourceInstanceName = 'X' }
        )

        $written = Invoke-MarkdownConverter -Resources $resources -ModuleRoot $Script:LayoutModuleRoot -SplitByResource

        $written | ForEach-Object -Process { Split-Path -Path $_ -Leaf } | Should -BeExactly @('Policy__A_.md', 'Policy__A_-2.md')
    }
}

Describe 'Markdown report values' {
    BeforeAll {
        $moduleRoot = New-MetadataRoot -Parameters @(
            'Identity', 'Domain', 'Tenant', 'Pipe', 'Quote', 'List', 'Single', 'Empty', 'NullText',
            'Flag', 'Multiline', 'LineFeed', 'Suffixed', 'TenantId'
        )
        $resource = @{
            ResourceName         = 'TeamsTestPolicy'
            ResourceInstanceName = 'Policy for $OrganizationName'
            Identity             = 'Global'
            Domain               = 'admin@Contoso.onmicrosoft.com uses $($ConfigurationData.NonNodeData.OrganizationName) in contoso'
            Tenant               = '5aa4dce1-1234-4567-89ab-0123456789ab $TenantGuid'
            Pipe                 = 'a|b'
            Quote                = "it's"
            List                 = [object[]] @('a,b', 'c', '')
            Single               = [object[]] @('a,b')
            Empty                = [object[]] @()
            NullText             = '$null'
            Flag                 = 'true'
            Multiline            = "one`r`ntwo"
            LineFeed             = "one`ntwo"
            Suffixed             = '$OrganizationNameX'
            TenantId             = '$OrganizationName'
        }
        $Script:ValuePath = (Invoke-MarkdownConverter -Resources @($resource) -ModuleRoot $moduleRoot -SplitByResource `
                -OrganizationName 'contoso.onmicrosoft.com')[0]
    }

    It 'Names the file after the tokenized and sanitized instance name' {
        Split-Path -Path $Script:ValuePath -Leaf | Should -BeExactly 'Policy_for_%ORGANIZATIONNAME%.md'
    }

    It 'Leaves out the authentication properties' {
        Get-Content -Path $Script:ValuePath | Where-Object -FilterScript { $_.StartsWith('| **TenantId** |') } | Should -BeNullOrEmpty
    }

    It 'Encodes <Parameter> as <Expected>' -ForEach @(
        @{ Parameter = 'Domain'; Expected = 'admin@%ORGANIZATIONNAME% uses %ORGANIZATIONNAME% in %DOMAINSHORTNAME%' }
        @{ Parameter = 'Tenant'; Expected = '%TENANTGUID% %TENANTGUID%' }
        @{ Parameter = 'Pipe'; Expected = 'a%PIPE%b' }
        @{ Parameter = 'Quote'; Expected = "it's" }
        @{ Parameter = 'List'; Expected = 'a%COMMA%b,c,%NULL%' }
        @{ Parameter = 'Single'; Expected = 'a%COMMA%b' }
        @{ Parameter = 'Empty'; Expected = '%NULL%' }
        @{ Parameter = 'NullText'; Expected = '%NULL%' }
        @{ Parameter = 'Flag'; Expected = 'True' }
        @{ Parameter = 'Multiline'; Expected = 'one`r`ntwo' }
        @{ Parameter = 'LineFeed'; Expected = 'one`r`ntwo' }
        @{ Parameter = 'Suffixed'; Expected = '$OrganizationNameX' }
    ) {
        Get-Cell -Path $Script:ValuePath -Parameter $Parameter | Should -BeExactly $Expected
    }
}

Describe 'Reporting infrastructure' {
    It 'Escapes the curly quotes a parser would read as the end of a string' {
        $reader = [Microsoft365DSC.Reporting.Configuration.ConfigurationReader]

        $reader::EscapeCurlyQuotes("a $([char]0x201C)b$([char]0x201D) ``$([char]0x201E)c") |
            Should -BeExactly "a ``$([char]0x201C)b``$([char]0x201D) ``$([char]0x201E)c"
        $reader::EscapeCurlyQuotes("a````$([char]0x201C)b") | Should -BeExactly "a``````$([char]0x201C)b"
    }

    It 'Resolves a registered format and rejects an unknown one' {
        [Microsoft365DSC.Reporting.ReportConverterRegistry]::Resolve('markdown').Format | Should -BeExactly 'Markdown'
        { [Microsoft365DSC.Reporting.ReportConverterRegistry]::Resolve('Pdf') } |
            Should -Throw -ExpectedMessage '*No report converter is registered for format ''Pdf''*'
    }

    It 'Keeps the first instance of identical mandatory properties' {
        $moduleRoot = New-MetadataRoot -Parameters @('Identity', 'Description')
        $resources = @(
            @{ ResourceName = 'TeamsTestPolicy'; ResourceInstanceName = 'Policy'; Identity = 'A'; Description = 'first' }
            @{ ResourceName = 'TeamsTestPolicy'; ResourceInstanceName = 'Policy-2'; Identity = 'A'; Description = 'second' }
            @{ ResourceName = 'TeamsTestPolicy'; ResourceInstanceName = 'Policy-1'; Identity = 'A'; Description = 'third' }
        )
        $warnings = [System.Collections.Generic.List[System.String]]::new()

        $written = Invoke-MarkdownConverter -Resources $resources -ModuleRoot $moduleRoot -SplitByResource `
            -MandatoryProperties @{ TeamsTestPolicy = @('Identity') } -Warnings $warnings

        $written | ForEach-Object -Process { Split-Path -Path $_ -Leaf } | Should -BeExactly @('Policy.md', 'Policy-1.md')
        $warnings[0] | Should -BeLike 'Skipping duplicate resource instance*Policy-2*'
    }
}
