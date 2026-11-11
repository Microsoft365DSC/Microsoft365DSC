BeforeAll {
    Import-Module "$PSScriptRoot/../../../Modules/Microsoft365DSC/Modules/M365DSCDllLoader.psm1" -Force -Global
    Initialize-M365DSCDllLoader

    # Stubs for the dependencies New-M365DSCDeltaReport resolves from other modules
    $Script:StubNames = @('Test-M365DSCModuleValidity', 'Confirm-M365DSCDependencies', 'Add-M365DSCTelemetryEvent', 'Get-M365DSCResourceSchema', 'New-M365DSCLogEntry')
    $Script:CreatedStubs = @()
    foreach ($stubName in $Script:StubNames)
    {
        if (-not (Test-Path -Path "Function:\$stubName"))
        {
            Set-Item -Path "Function:\global:$stubName" -Value { param([Parameter(ValueFromRemainingArguments = $true)] $Arguments) }
            $Script:CreatedStubs += $stubName
        }
    }

    Import-Module "$PSScriptRoot/../../../Modules/Microsoft365DSC/Modules/M365DSCReport.psm1" -Force
    Import-Module "$PSScriptRoot/../../../Modules/Microsoft365DSC/Modules/M365DSCDocGenerator.psm1" -Force

    foreach ($stubName in $Script:StubNames)
    {
        Mock -ModuleName 'M365DSCReport' -CommandName $stubName -MockWith {}
    }
    Mock -ModuleName 'M365DSCReport' -CommandName 'Get-M365DSCResourceSchema' -MockWith { return @() }

    $Script:SourcePath = Join-Path -Path $TestDrive -ChildPath 'Source.ps1'
    $Script:DestinationPath = Join-Path -Path $TestDrive -ChildPath 'Destination.ps1'
    Set-Content -Path $Script:SourcePath -Value '# source'
    Set-Content -Path $Script:DestinationPath -Value '# destination'

    function New-TestDriftEntry
    {
        param($ResourceName, $InstanceName, $ParameterName)

        return @{
            ResourceName         = $ResourceName
            ResourceInstanceName = $InstanceName
            Key                  = 'IsSingleInstance'
            KeyValue             = 'Yes'
            Properties           = @(@{ ParameterName = $ParameterName; ValueInSource = 'A'; ValueInDestination = 'B' })
        }
    }
}

AfterAll {
    Remove-Module -Name M365DSCReport -Force -ErrorAction SilentlyContinue
    foreach ($stubName in $Script:CreatedStubs)
    {
        Remove-Item -Path "Function:\$stubName" -ErrorAction SilentlyContinue
    }
}

Describe 'New-M365DSCDeltaReport' {
    Context 'Drifted resources' {
        BeforeAll {
            $Script:Delta = @(
                New-TestDriftEntry -ResourceName 'EXOOrganizationConfig' -InstanceName 'OrgConfig' -ParameterName 'PropA'
                New-TestDriftEntry -ResourceName 'EXOOrganizationConfig' -InstanceName 'OrgConfig' -ParameterName 'PropB'
                New-TestDriftEntry -ResourceName 'TeamsMeetingConfiguration' -InstanceName 'MeetingConfig' -ParameterName 'PropC'
            )
            $Script:Report = New-M365DSCDeltaReport -Source $Script:SourcePath -Destination $Script:DestinationPath `
                -Delta $Script:Delta -IsBlueprintAssessment $true
        }

        It 'Counts drifted instances in the table of contents, not distinct key values' {
            $Script:Report | Should -Match "Resources Configured Differently</a>\s*<strong>\(</strong>2<strong>\)"
            ([regex]::Matches($Script:Report, "<table class='drift-table'>")).Count | Should -Be 2
        }

        It 'Combines the drifted properties of one instance into a single table' {
            $Script:Report | Should -Match '(?s)OrgConfig</h3>.*PropA</td>.*PropB</td>'
        }
    }

    Context 'DriftOnly with only missing resources' {
        It 'Shows the no discrepancies notice instead of an empty body' {
            $delta = @(@{
                    ResourceName         = 'AADGroup'
                    ResourceInstanceName = 'Group1'
                    Key                  = 'DisplayName'
                    KeyValue             = 'Group1'
                    Properties           = @(@{ ParameterName = '_IsInConfiguration_'; ValueInSource = 'Absent'; ValueInDestination = 'Present' })
                })
            $report = New-M365DSCDeltaReport -Source $Script:SourcePath -Destination $Script:DestinationPath `
                -Delta $delta -DriftOnly $true

            $report | Should -Match '<p class="no-discrepancies">'
        }
    }

    Context 'Custom header file' {
        It 'Keeps the line breaks of the header' {
            $headerPath = Join-Path -Path $TestDrive -ChildPath 'Header.html'
            Set-Content -Path $headerPath -Value @('<script>', '// comment', 'var x = 1;', '</script>')
            $delta = @(New-TestDriftEntry -ResourceName 'EXOOrganizationConfig' -InstanceName 'OrgConfig' -ParameterName 'PropA')

            $report = New-M365DSCDeltaReport -Source $Script:SourcePath -Destination $Script:DestinationPath `
                -Delta $delta -HeaderFilePath $headerPath

            $report | Should -Match '// comment\r?\nvar x = 1;'
        }
    }

    Context 'Variable substitution' {
        BeforeAll {
            $folder = Join-Path -Path $TestDrive -ChildPath 'Substitution'
            $null = New-Item -Path $folder -ItemType Directory -Force
            $Script:SubSource = Join-Path -Path $folder -ChildPath 'Source.ps1'
            $Script:SubConfigData = Join-Path -Path $folder -ChildPath 'Data.psd1'
            Set-Content -Path $Script:SubConfigData -Value "@{ AllNodes = @(); NonNodeData = @{ Domain = 'contoso.com'; DomainName = 'Contoso Ltd'; DomainSuffix = 5 } }"
            $lines = @(
                'A = "$ConfigurationData.NonNodeData.Domain"'
                'B = "$ConfigurationData.NonNodeData.DomainName"'
                'C = $ConfigurationData.NonNodeData.DomainSuffix'
                'D = "$($ConfigurationData.NonNodeData.Domain)"'
            )
            Set-Content -Path $Script:SubSource -Value $lines

            Mock -ModuleName M365DSCReport -CommandName Initialize-M365DSCReporting -MockWith {
                if ($ConfigurationPath -ne $global:M365DSCReportTestDestination)
                {
                    $global:M365DSCReportTestCapture = @{
                        Path    = $ConfigurationPath
                        Content = [System.IO.File]::ReadAllText($ConfigurationPath)
                    }
                    throw 'Parsing failed'
                }
                return @()
            }

            $global:M365DSCReportTestDestination = $Script:DestinationPath
            $global:M365DSCReportTestCapture = $null
            { New-M365DSCDeltaReport -Source $Script:SubSource -Destination $Script:DestinationPath `
                    -UseVariableSubstitution -SourceConfigurationDataPath $Script:SubConfigData } | Should -Throw 'Parsing failed'
            $Script:Capture = $global:M365DSCReportTestCapture
        }

        AfterAll {
            Remove-Variable -Name M365DSCReportTestCapture, M365DSCReportTestDestination -Scope Global -ErrorAction SilentlyContinue
        }

        It 'Does not replace a shorter variable name inside a longer one' {
            $Script:Capture.Content | Should -Match 'A = "contoso\.com"'
            $Script:Capture.Content | Should -Match 'B = "Contoso Ltd"'
            $Script:Capture.Content | Should -Match 'C = \$ConfigurationData\.NonNodeData\.DomainSuffix'
            $Script:Capture.Content | Should -Match 'D = "contoso\.com"'
        }

        It 'Removes the substituted copy even when parsing throws' {
            Split-Path -Path $Script:Capture.Path -Leaf | Should -BeLike 'M365DSCDelta_*.ps1'
            Test-Path -Path $Script:Capture.Path | Should -BeFalse
        }
    }
}

Describe 'Convert-ObjectToHtmlList' {
    It 'Produces well-formed closing tags for an array of hashtables' {
        InModuleScope -ModuleName M365DSCReport {
            $result = Convert-ObjectToHtmlList -InputObject @(@{ A = 1 }, @{ B = 2 }) -ParentName 'Items'

            $result | Should -Not -Match '</li</'
            $result | Should -Match '</li></ul>$'
            ([regex]::Matches($result, '<hr/>')).Count | Should -Be 1
        }
    }

    It 'Produces well-formed closing tags for an array of scalars' {
        InModuleScope -ModuleName M365DSCReport {
            $result = Convert-ObjectToHtmlList -InputObject @('x', 'y') -ParentName 'Items'

            $result | Should -Match '</li></ul>$'
        }
    }
}

Describe 'New-M365DSCConfigurationToHTML' {
    It 'Lists array elements that contain commas as one item each' {
        InModuleScope -ModuleName M365DSCReport {
            $resource = @{ ResourceName = 'AADGroup'; ResourceInstanceName = 'Group1'; Members = @('CN=Foo,OU=Bar', 'x') }
            $outputPath = Join-Path -Path $TestDrive -ChildPath 'Report.html'
            $null = New-M365DSCConfigurationToHTML -ParsedContent @($resource) -OutputPath $outputPath
            $html = Get-Content -Path $outputPath -Raw

            $html | Should -Match '<ul><li>CN=Foo,OU=Bar</li><li>x</li></ul>'
        }
    }

    It 'Lists typed string arrays instead of printing the type name' {
        InModuleScope -ModuleName M365DSCReport {
            $resource = @{ ResourceName = 'AADGroup'; ResourceInstanceName = 'Group1'; Members = [System.String[]]@('a', 'b') }
            $outputPath = Join-Path -Path $TestDrive -ChildPath 'Report2.html'
            $null = New-M365DSCConfigurationToHTML -ParsedContent @($resource) -OutputPath $outputPath
            $html = Get-Content -Path $outputPath -Raw

            $html | Should -Match '<ul><li>a</li><li>b</li></ul>'
            $html | Should -Not -Match 'System\.String\[\]'
        }
    }
}

Describe 'New-M365DSCConfigurationToCSV' {
    BeforeAll {
        $Script:CsvPath = Join-Path -Path $TestDrive -ChildPath 'Report.csv'
        $parsed = @(
            [ordered]@{ Identity = 'contoso.com'; ResourceName = 'EXOAcceptedDomain'; Description = 'admin@contoso.com'; Ensure = 'Present' }
            [ordered]@{ DisplayName = 'Policy (Prod)'; ResourceName = 'AADGroup'; Description = '$OrganizationName' }
        )
        InModuleScope -ModuleName M365DSCReport -Parameters @{ Parsed = $parsed; Path = $Script:CsvPath } {
            param($Parsed, $Path)
            New-M365DSCConfigurationToCSV -ParsedContent $Parsed -OutputPath $Path -ErrorVariable csvErrors -ErrorAction SilentlyContinue
            $csvErrors.Count | Should -Be 0
        }
        $Script:Rows = @(Import-Csv -Path $Script:CsvPath)
    }

    It 'Writes the columns in a stable order' {
        (Get-Content -Path $Script:CsvPath -TotalCount 1) | Should -Be '"Component Name","Property","Value"'
    }

    It 'Puts the key property first when it is the first property enumerated' {
        $Script:Rows[0].Property | Should -Be 'Identity'
        $Script:Rows[0].Value | Should -Be 'contoso.com'
        $Script:Rows[4].Property | Should -Be 'DisplayName'
        $Script:Rows[4].Value | Should -Be 'Policy (Prod)'
    }

    It 'Keeps @, parentheses and $ in values' {
        ($Script:Rows | Where-Object -FilterScript { $_.'Component Name' -eq 'EXOAcceptedDomain' -and $_.Property -eq 'Description' }).Value | Should -Be 'admin@contoso.com'
        ($Script:Rows | Where-Object -FilterScript { $_.'Component Name' -eq 'AADGroup' -and $_.Property -eq 'Description' }).Value | Should -Be '$OrganizationName'
    }
}

Describe 'ConvertTo-M365DSCHtmlText' {
    It 'encodes markup characters' {
        InModuleScope -ModuleName 'M365DSCReport' {
            ConvertTo-M365DSCHtmlText "<img src=x onerror='a'>&" | Should -Be '&lt;img src=x onerror=&#39;a&#39;&gt;&amp;'
        }
    }

    It 'returns an empty string for null' {
        InModuleScope -ModuleName 'M365DSCReport' {
            ConvertTo-M365DSCHtmlText $null | Should -Be ''
        }
    }

    It 'joins arrays like string interpolation does' {
        InModuleScope -ModuleName 'M365DSCReport' {
            ConvertTo-M365DSCHtmlText @('a', '<b>') | Should -Be 'a &lt;b&gt;'
        }
    }
}

Describe 'New-M365DSCConfigurationToHTML' {
    BeforeAll {
        $Script:Resources = @(
            @{
                ResourceName         = 'AADGroup'
                ResourceInstanceName = '<b>Group</b>'
                DisplayName          = 'Sales & <script>alert(1)</script>'
                Members              = @('one', '<two>')
                Settings             = @(@{ Name = 'Rule'; Value = 'user.department -eq "<x>"' })
            },
            @{
                ResourceName         = 'FabricAdminTenantSettings'
                ResourceInstanceName = 'Fabric'
                IsSingleInstance     = 'Yes'
            }
        )
        $Script:OutputFile = Join-Path -Path $TestDrive -ChildPath 'report.html'
        $null = InModuleScope -ModuleName 'M365DSCReport' -Parameters @{ Resources = $Script:Resources; OutputFile = $Script:OutputFile } {
            New-M365DSCConfigurationToHTML -ParsedContent $Resources -OutputPath $OutputFile -TemplateName 'Template'
        }
        $Script:Html = Get-Content -Path $Script:OutputFile -Raw
    }

    It 'encodes tenant values' {
        $Script:Html | Should -Match ([regex]::Escape('&lt;b&gt;Group&lt;/b&gt;'))
        $Script:Html | Should -Match ([regex]::Escape('Sales &amp; &lt;script&gt;alert(1)&lt;/script&gt;'))
        $Script:Html | Should -Match ([regex]::Escape('<li>&lt;two&gt;</li>'))
        $Script:Html | Should -Match ([regex]::Escape('&lt;x&gt;'))
        $Script:Html | Should -Not -Match '<script>'
    }

    It 'renders every resource once' {
        ([regex]::Matches($Script:Html, "<table class='resource-table'>")).Count | Should -Be 2
    }
}

Describe 'New-M365DSCDeltaReport' {
    BeforeAll {
        $Script:SourcePath = Join-Path -Path $TestDrive -ChildPath 'source.ps1'
        $Script:DestinationPath = Join-Path -Path $TestDrive -ChildPath 'destination & co.ps1'
        Set-Content -LiteralPath $Script:SourcePath -Value ''
        Set-Content -LiteralPath $Script:DestinationPath -Value ''

        $delta = @(
            @{
                ResourceName         = 'AADGroup'
                ResourceInstanceName = '<i>Group</i>'
                Key                  = 'DisplayName'
                KeyValue             = '<i>Group</i>'
                Properties           = @(
                    @{
                        ParameterName      = 'Description'
                        ValueInSource      = '<b>&'
                        ValueInDestination = 'plain'
                        _Metadata_Level    = 'L1'
                        _Metadata_Info     = '<strong>Annotation</strong>'
                        DeltaValue         = '=> <src>; <= <dst>'
                    }
                )
            }
        )
        $Script:Html = New-M365DSCDeltaReport -Source $Script:SourcePath -Destination $Script:DestinationPath -Delta $delta
    }

    It 'encodes drift values, instance names and delta entries' {
        $Script:Html | Should -Match ([regex]::Escape('&lt;b&gt;&amp;</td>'))
        $Script:Html | Should -Match ([regex]::Escape('AADGroup - &lt;i&gt;Group&lt;/i&gt;'))
        $Script:Html | Should -Match ([regex]::Escape('<li>&lt;src&gt;</li>'))
        $Script:Html | Should -Match ([regex]::Escape('<li>&lt;dst&gt;</li>'))
        $Script:Html | Should -Match ([regex]::Escape('destination &amp; co.ps1'))
    }

    It 'keeps HTML in blueprint annotations' {
        $Script:Html | Should -Match ([regex]::Escape('<strong>Annotation</strong>'))
    }
}

Describe 'Get-M365WorkloadName' {
    It 'maps <ResourceName> to <Expected>' -ForEach @(
        @{ ResourceName = 'CommerceSelfServicePurchase'; Expected = 'Commerce' }
        @{ ResourceName = 'FabricAdminTenantSettings'; Expected = 'Microsoft Fabric' }
        @{ ResourceName = 'VivaEngagementRoleMember'; Expected = 'Microsoft Viva' }
        @{ ResourceName = 'M365DSCRuleEvaluation'; Expected = 'Microsoft365DSC' }
        @{ ResourceName = 'SPOSite'; Expected = 'SharePoint Online' }
        @{ ResourceName = 'Unknown'; Expected = 'Other' }
    ) {
        InModuleScope -ModuleName 'M365DSCReport' -Parameters @{ ResourceName = $ResourceName } {
            Get-M365WorkloadName -ResourceName $ResourceName
        } | Should -Be $Expected
    }
}

Describe 'Get-Base64EncodedImage' {
    It 'returns a data URI for an existing icon' {
        InModuleScope -ModuleName 'M365DSCReport' {
            Get-Base64EncodedImage -IconName 'Planner.png' | Should -BeLike 'data:image/png;base64,*'
            Get-Base64EncodedImage -IconName 'Teams.jpg' | Should -BeLike 'data:image/jpeg;base64,*'
        }
    }

    It 'returns $null without an error for a missing icon' {
        InModuleScope -ModuleName 'M365DSCReport' {
            { Get-Base64EncodedImage -IconName 'DoesNotExist.png' -ErrorAction Stop } | Should -Not -Throw
            Get-Base64EncodedImage -IconName 'DoesNotExist.png' | Should -BeNullOrEmpty
        }
    }

    It 'caches the encoded icon' {
        InModuleScope -ModuleName 'M365DSCReport' {
            $null = Get-Base64EncodedImage -IconName 'Intune.jpg'
            $Script:IconCache.ContainsKey('Intune.jpg') | Should -BeTrue
        }
    }
}

Describe 'Get-M365DSCCIMInstanceKey' {
    It 'returns a single key name when no known key is present' {
        $key = Get-M365DSCCIMInstanceKey -CIMInstance @{ Alpha = 1; Beta = 2 }
        $key | Should -BeOfType [System.String]
        $key | Should -BeIn @('Alpha', 'Beta')
    }
}

Describe 'Format-M365DSCPermissionList' {
    It 'returns None for <Case>' -ForEach @(
        @{ Case = 'null'; List = $null }
        @{ Case = 'an empty list'; List = @() }
    ) {
        InModuleScope -ModuleName 'M365DSCDocGenerator' -Parameters @{ List = $List } {
            Format-M365DSCPermissionList -List $List
        } | Should -Be 'None'
    }

    It 'joins plain values' {
        InModuleScope -ModuleName 'M365DSCDocGenerator' {
            Format-M365DSCPermissionList -List @('Role A', 'Role B')
        } | Should -Be 'Role A, Role B'
    }

    It 'joins the name property with ByName' {
        InModuleScope -ModuleName 'M365DSCDocGenerator' {
            Format-M365DSCPermissionList -List @([PSCustomObject]@{ name = 'Group.Read.All' }, [PSCustomObject]@{ name = 'User.Read.All' }) -ByName
        } | Should -Be 'Group.Read.All, User.Read.All'
    }
}

Describe 'Update-M365DSCResourceDocumentationPage' {
    It 'removes its temporary folder when page generation fails' {
        $Script:CapturedPath = $null
        Mock -ModuleName 'M365DSCDocGenerator' -CommandName 'New-DscClassResourceWikiPage' -MockWith {
            param($OutputPath, $SourcePath, $Force)
            $Script:CapturedPath = $OutputPath
            Set-Content -Path (Join-Path -Path $OutputPath -ChildPath 'UnknownPrefixResource.md') -Value 'x'
        }

        { Update-M365DSCResourceDocumentationPage -SourcePath $TestDrive } | Should -Throw '*Unknown resource prefix*'
        $Script:CapturedPath | Should -Not -BeNullOrEmpty
        Test-Path -Path $Script:CapturedPath | Should -BeFalse
    }
}
