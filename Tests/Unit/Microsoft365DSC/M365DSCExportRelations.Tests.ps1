BeforeAll {
    Import-Module "$PSScriptRoot/../../../Modules/Microsoft365DSC/Modules/M365DSCDllLoader.psm1" -Force -Global
    Import-Module "$PSScriptRoot/../../../Modules/Microsoft365DSC/Microsoft365DSC.psd1" -Global

    function New-TestSession
    {
        InModuleScope -ModuleName 'M365DSCExportUtil' { New-M365DSCExportRelationSession }
    }

    function Get-TestIndex
    {
        InModuleScope -ModuleName 'M365DSCExportUtil' { Get-M365DSCRelationIndex }
    }

    function New-TestStubOptions
    {
        Initialize-M365DSCDllLoader
        $options = [Microsoft365DSC.Relations.StubBlockOptions]::new()
        # Mirrors what New-M365DSCStubBlockOption builds from the resource dictionary: the
        # type and any allowed values travel with each mandatory property.
        $options.MandatoryPropertiesByResource = @{
            AADGroup          = @(
                @{ Name = 'DisplayName'; PropertyType = '[string]'; Values = @() }
                @{ Name = 'MailNickname'; PropertyType = '[string]'; Values = @() }
                @{ Name = 'MailEnabled'; PropertyType = '[bool]'; Values = @() }
                @{ Name = 'SecurityEnabled'; PropertyType = '[bool]'; Values = @() }
            )
            AADUser           = @(
                @{ Name = 'UserPrincipalName'; PropertyType = '[string]'; Values = @() }
            )
            AADRoleDefinition = @(
                @{ Name = 'DisplayName'; PropertyType = '[string]'; Values = @() }
                @{ Name = 'IsEnabled'; PropertyType = '[bool]'; Values = @() }
                @{ Name = 'RolePermissions'; PropertyType = '[string[]]'; Values = @() }
            )
            FakeSingleton     = @(
                @{ Name = 'IsSingleInstance'; PropertyType = '[string]'; Values = @('Yes') }
                @{ Name = 'RetentionInDays'; PropertyType = '[UInt32]'; Values = @() }
            )
        }
        $options.AuthenticationProperties = @('ApplicationId', 'TenantId', 'CertificateThumbprint')
        return $options
    }
}

Describe 'New-M365DSCExportRelationSession' {
    It 'Creates a session when it is the first relation call made in the session' {
        # Regression guard: the assembly must be loaded by a statement of its own, otherwise
        # the type literal is resolved before the load has run and this throws.
        { New-TestSession } | Should -Not -Throw
    }
}

Describe 'Remove-M365DSCJsonComment' {
    It 'Removes line and block comments' {
        $result = InModuleScope -ModuleName 'M365DSCExportUtil' {
            Remove-M365DSCJsonComment -Json "{ `"a`": 1, /* block */ `"b`": 2 // line`n, `"c`": 3 }"
        }
        ($result | ConvertFrom-Json).b | Should -Be 2
        ($result | ConvertFrom-Json).c | Should -Be 3
    }

    It 'Leaves comment markers that appear inside string values untouched' {
        $result = InModuleScope -ModuleName 'M365DSCExportUtil' {
            Remove-M365DSCJsonComment -Json '{ "url": "http://contoso//path", "note": "/* not a comment */" }'
        }
        $parsed = $result | ConvertFrom-Json
        $parsed.url | Should -Be 'http://contoso//path'
        $parsed.note | Should -Be '/* not a comment */'
    }

    It 'Respects escaped quotes when tracking string boundaries' {
        $result = InModuleScope -ModuleName 'M365DSCExportUtil' {
            Remove-M365DSCJsonComment -Json '{ "a": "he said \"//\" loudly", "b": 1 }'
        }
        ($result | ConvertFrom-Json).a | Should -Be 'he said "//" loudly'
    }
}

Describe 'Get-M365DSCRelationIndex' {
    It 'Parses the shipped relation templates on this PowerShell edition' {
        (Get-TestIndex).ResourceCount | Should -BeGreaterThan 0
    }

    It 'Returns an empty set for a resource that declares no relations' {
        (Get-TestIndex).GetRelations('NoSuchResourceName').Count | Should -Be 0
    }

    It 'Expands $ref entries into the referencing resource' {
        # IntuneRootCertificateProfile references the IntuneAssignments template, so the SCEP
        # policy must end up with the assignment relations as well as its own.
        $targets = (Get-TestIndex).GetRelations('IntuneDeviceConfigurationSCEPCertificatePolicyWindows10') |
            ForEach-Object { $_.TargetResource }

        $targets | Should -Contain 'IntuneDeviceConfigurationTrustedCertificatePolicyWindows10'
        $targets | Should -Contain 'AADGroup'
    }

    It 'Records the properties other resources reference a resource by' {
        (Get-TestIndex).GetTargetKeyProperties('AADUser') | Should -Contain 'UserPrincipalName'
    }
}

Describe 'ConditionParser' {
    BeforeAll {
        Initialize-M365DSCDllLoader
    }

    It 'Treats a missing condition as unconditional' {
        [Microsoft365DSC.Relations.ConditionParser]::Parse($null) | Should -BeNullOrEmpty
    }

    It 'Evaluates an "in" list' {
        $condition = [Microsoft365DSC.Relations.ConditionParser]::Parse("dataType in ['a', 'b']")
        $condition.Evaluate(@{ dataType = 'b' }) | Should -BeTrue
        $condition.Evaluate(@{ dataType = 'c' }) | Should -BeFalse
        $condition.Evaluate(@{ other = 'b' })    | Should -BeFalse
    }

    It 'Evaluates an "eq" comparison rather than matching everything' {
        $condition = [Microsoft365DSC.Relations.ConditionParser]::Parse("type eq 'User'")
        $condition.Evaluate(@{ type = 'User' })  | Should -BeTrue
        $condition.Evaluate(@{ type = 'Group' }) | Should -BeFalse
    }

    It 'Rejects a syntax it does not understand instead of silently passing' {
        { [Microsoft365DSC.Relations.ConditionParser]::Parse('type startswith "x"') } | Should -Throw
    }
}

Describe 'ExportRelationSession relation resolution' {
    It 'Discriminates administrative unit members by type' {
        $session = New-TestSession
        $session.ResolveRelations('AADAdministrativeUnit', 'AU-Test', @{
                Members = @(
                    @{ Identity = 'alice@contoso.com'; type = 'User' }
                    @{ Identity = 'Sales'; type = 'Group' }
                )
            })

        $session.DependencyCount | Should -Be 2
    }

    It 'Applies conditions to items in a complex array' {
        $session = New-TestSession
        $session.ResolveRelations('IntuneDeviceConfigurationPolicyWindows10', 'Policy-A', @{
                Assignments = @(
                    @{ dataType = '#microsoft.graph.groupAssignmentTarget'; groupDisplayName = 'Engineering' }
                    @{ dataType = '#microsoft.graph.allDevicesAssignmentTarget'; groupDisplayName = 'Excluded' }
                )
            })

        $session.DependencyCount | Should -Be 1
    }

    It 'Reads a hashtable-valued property rather than walking it as a sequence' {
        $session = New-TestSession
        $session.ResolveRelations('AADAdministrativeUnit', 'AU-Single', @{
                ScopedRoleMembers = @{ RoleName = 'Helpdesk Administrator' }
            })

        $session.DependencyCount | Should -Be 1
    }

    It 'Reads properties off a PSCustomObject' {
        $session = New-TestSession
        $session.ResolveRelations('IntuneDeviceConfigurationPolicyWindows10', 'Policy-PSObject', @{
                Assignments = @(
                    [PSCustomObject]@{
                        dataType         = '#microsoft.graph.groupAssignmentTarget'
                        groupDisplayName = 'Engineering'
                    }
                )
            })

        $session.DependencyCount | Should -Be 1
    }

    It 'Handles an empty collection without throwing' {
        $session = New-TestSession
        { $session.ResolveRelations('IntuneDeviceConfigurationPolicyWindows10', 'Policy-Empty', @{
                    Assignments     = @()
                    RoleScopeTagIds = @()
                }) } | Should -Not -Throw

        $session.DependencyCount | Should -Be 0
    }

    It 'Skips a relation whose property is absent' {
        $session = New-TestSession
        $session.ResolveRelations('IntuneDeviceConfigurationPolicyWindows10', 'Policy-Sparse', @{
                DisplayName = 'Nothing to relate'
            })

        $session.DependencyCount | Should -Be 0
    }

    It 'Records a scalar array as one dependency per element' {
        $session = New-TestSession
        $session.ResolveRelations('IntuneDeviceConfigurationPolicyWindows10', 'Policy-Tags', @{
                RoleScopeTagIds = @('0', '1', '2')
            })

        $session.DependencyCount | Should -Be 3
    }

    It 'Discards duplicate references as they arrive' {
        $session = New-TestSession
        $session.ResolveRelations('IntuneDeviceConfigurationPolicyWindows10', 'Policy-Dupes', @{
                RoleScopeTagIds = @('0', '0', '0')
            })

        $session.DependencyCount | Should -Be 1
    }

    It 'Does not throw on a property type it cannot interpret' {
        $session = New-TestSession
        { $session.ResolveRelations('IntuneDeviceConfigurationPolicyWindows10', 'Policy-Odd', @{
                    RoleScopeTagIds = [System.IO.MemoryStream]::new()
                }) } | Should -Not -Throw
    }
}

Describe 'DependsOn injection' {
    BeforeAll {
        $Script:Content = @(
            '        IntuneDeviceConfigurationPolicyWindows10 "Policy-A"'
            '        {'
            '            DisplayName = "Policy A"'
            '        }'
            '        IntuneRoleScopeTag "IntuneRoleScopeTag-Default"'
            '        {'
            '            DisplayName = "Default"'
            '        }'
        ) -join "`r`n"
        $Script:Content += "`r`n"
    }

    It 'Injects a DependsOn line into the referencing block only' {
        $session = New-TestSession
        $session.RegisterInstance('IntuneRoleScopeTag', 'IntuneRoleScopeTag-Default', '0', @{ DisplayName = 'Default' })
        $session.ResolveRelations('IntuneDeviceConfigurationPolicyWindows10', 'Policy-A', @{ RoleScopeTagIds = @('0') })

        $result = $session.InjectDependsOn($Script:Content, (New-TestStubOptions))

        $result | Should -Match 'DependsOn = @\("\[IntuneRoleScopeTag\]IntuneRoleScopeTag-Default"\)'
        ([regex]::Matches($result, 'DependsOn')).Count | Should -Be 1
    }

    It 'Emits a stub block for a target that was not exported' {
        $session = New-TestSession
        $session.ResolveRelations('IntuneDeviceConfigurationPolicyWindows10', 'Policy-A', @{
                Assignments = @(
                    @{ dataType = '#microsoft.graph.groupAssignmentTarget'; groupDisplayName = 'Engineering' }
                )
            })

        $result = $session.InjectDependsOn($Script:Content, (New-TestStubOptions))

        $result | Should -Match '# Dependency stubs'
        $result | Should -Match 'AADGroup "AADGroup-Engineering"'
        $result | Should -Match 'MailEnabled = \$false'
        $result | Should -Match 'SecurityEnabled = \$true'
        $result | Should -Match 'ApplicationId = \$ConfigurationData\.NonNodeData\.ApplicationId'
        $result | Should -Match 'Ensure      = "Present"'
    }

    It 'References a target whose key holds quotes by the name its block is declared under' {
        $session = New-TestSession
        $instanceName = 'AADGroup-Tag__A___prod_'
        $session.RegisterInstance('AADGroup', $instanceName, 'Tag "A" (prod)', $null)
        $session.ResolveRelations('IntuneDeviceConfigurationPolicyWindows10', 'Policy-A', @{
                Assignments = @(
                    @{ dataType = '#microsoft.graph.groupAssignmentTarget'; groupDisplayName = 'Tag "A" (prod)' }
                )
            })

        $content = @(
            '        AADGroup "' + $instanceName + '"'
            '        {'
            '            DisplayName = "Tag `"A`" (prod)"'
            '        }'
            '        IntuneDeviceConfigurationPolicyWindows10 "Policy-A"'
            '        {'
            '            DisplayName = "Policy A"'
            '        }'
        ) -join "`r`n"
        $content += "`r`n"

        $result = $session.InjectDependsOn($content, (New-TestStubOptions))

        $result | Should -Match ([regex]::Escape("DependsOn = @(`"[AADGroup]$instanceName`")"))
        $result | Should -Not -Match '# Dependency stubs'
    }

    It 'Declares a stub for a key holding quotes under a name the parser accepts' {
        $session = New-TestSession
        $session.ResolveRelations('IntuneDeviceConfigurationPolicyWindows10', 'Policy-A', @{
                Assignments = @(
                    @{ dataType = '#microsoft.graph.groupAssignmentTarget'; groupDisplayName = 'Tag "A" (prod)' }
                )
            })

        $result = $session.InjectDependsOn($Script:Content, (New-TestStubOptions))

        $result | Should -Match ([regex]::Escape('AADGroup "AADGroup-Tag__A___prod_"'))
        $result | Should -Match ([regex]::Escape('DependsOn = @("[AADGroup]AADGroup-Tag__A___prod_")'))
        $result | Should -Match ([regex]::Escape('DisplayName = "Tag `"A`" (prod)"'))

        $errors = $null
        $null = [System.Management.Automation.Language.Parser]::ParseInput($result, [ref] $null, [ref] $errors)
        $errors | Should -BeNullOrEmpty
    }

    It 'Returns the content unchanged when nothing was referenced' {
        $session = New-TestSession
        $result = $session.InjectDependsOn($Script:Content, (New-TestStubOptions))

        $result | Should -BeExactly $Script:Content
    }

    It 'Prefers the declared target key property over the primary key' {
        # AADConditionalAccessPolicy references AADUser by UserPrincipalName. An instance whose
        # primary key differs from its UPN must still resolve to a real reference rather than
        # falling through to a generated stub.
        $session = New-TestSession
        $session.RegisterInstance('AADUser', 'AADUser-Alice', 'some-object-id', @{ UserPrincipalName = 'alice@contoso.com' })
        $session.ResolveRelations('AADConditionalAccessPolicy', 'CA-Test', @{ IncludeUsers = @('alice@contoso.com') })

        $content = "        AADConditionalAccessPolicy `"CA-Test`"`r`n        {`r`n            DisplayName = `"CA`"`r`n        }`r`n"
        $result = $session.InjectDependsOn($content, (New-TestStubOptions))

        $result | Should -Match 'DependsOn = @\("\[AADUser\]AADUser-Alice"\)'
        $result | Should -Not -Match '# Dependency stubs'
    }

    It 'Falls back to the primary key when the declared property does not match' {
        $session = New-TestSession
        $session.RegisterInstance('AADUser', 'AADUser-Bob', 'bob@contoso.com', @{ DisplayName = 'Bob' })
        $session.ResolveRelations('AADConditionalAccessPolicy', 'CA-Fallback', @{ IncludeUsers = @('bob@contoso.com') })

        $content = "        AADConditionalAccessPolicy `"CA-Fallback`"`r`n        {`r`n            DisplayName = `"CA`"`r`n        }`r`n"
        $result = $session.InjectDependsOn($content, (New-TestStubOptions))

        $result | Should -Match 'DependsOn = @\("\[AADUser\]AADUser-Bob"\)'
    }

    It 'Orders DependsOn entries independently of the order they were discovered' {
        # A parallel export finds dependencies in whatever order the runspaces finish, so the
        # rendered output must not depend on arrival order.
        $targets = 'Zulu', 'Alpha', 'Mike', 'Bravo'
        $content = "        AADConditionalAccessPolicy `"CA-Order`"`r`n        {`r`n            DisplayName = `"CA`"`r`n        }`r`n"

        $renders = foreach ($ordering in @($targets, ($targets | Sort-Object), ($targets | Sort-Object -Descending)))
        {
            $session = New-TestSession
            foreach ($target in $ordering)
            {
                $session.RegisterDependency('CA-Order', 'AADConditionalAccessPolicy', 'AADGroup', $target)
            }
            $session.InjectDependsOn($content, (New-TestStubOptions))
        }

        ($renders | Select-Object -Unique).Count | Should -Be 1
        $renders[0] | Should -Match '"\[AADGroup\]AADGroup-Alpha", "\[AADGroup\]AADGroup-Bravo", "\[AADGroup\]AADGroup-Mike", "\[AADGroup\]AADGroup-Zulu"'
    }
}

Describe 'Dependency stub properties' {
    BeforeAll {
        function Get-StubBlock
        {
            param([string] $ResourceType, [string] $TargetKey, [string] $TargetKeyProperty)

            Initialize-M365DSCDllLoader
            $target = @{ ResourceType = $ResourceType; TargetKey = $TargetKey }
            if ($TargetKeyProperty) { $target.TargetKeyProperty = $TargetKeyProperty }
            [Microsoft365DSC.Relations.DependsOnInjector]::RenderStubs(@($target), (New-TestStubOptions))
        }
    }

    It 'Emits every mandatory property, not only recognised names' {
        # AADRoleDefinition previously lost IsEnabled and RolePermissions entirely.
        $stub = Get-StubBlock -ResourceType 'AADRoleDefinition' -TargetKey 'Global Reader'

        $stub | Should -Match 'DisplayName = "Global Reader"'
        $stub | Should -Match 'IsEnabled = \$false'
        $stub | Should -Match 'RolePermissions = @\(\)'
    }

    It 'Puts the key in the property the relation declared' {
        # AADUser has no DisplayName in its mandatory set, so a name-based allowlist left the
        # stub with nothing identifying it at all.
        $stub = Get-StubBlock -ResourceType 'AADUser' -TargetKey 'alice@contoso.com' -TargetKeyProperty 'UserPrincipalName'
        $stub | Should -Match 'UserPrincipalName = "alice@contoso.com"'
    }

    It 'Falls back to the conventional key property when the relation declares none' {
        $stub = Get-StubBlock -ResourceType 'AADUser' -TargetKey 'bob@contoso.com'
        $stub | Should -Match 'UserPrincipalName = "bob@contoso.com"'
    }

    It 'Matches property names case-insensitively' {
        # The schema spells it MailNickname; a case-sensitive comparison dropped it.
        $stub = Get-StubBlock -ResourceType 'AADGroup' -TargetKey 'Engineering'

        $stub | Should -Match 'MailNickname = ""'
        $stub | Should -Match 'MailEnabled = \$false'
        $stub | Should -Match 'SecurityEnabled = \$true'
    }

    It 'Uses an allowed value for a constrained property and zero for a numeric one' {
        $stub = Get-StubBlock -ResourceType 'FakeSingleton' -TargetKey 'ignored'

        $stub | Should -Match 'IsSingleInstance = "Yes"'
        $stub | Should -Match 'RetentionInDays = 0'
    }

    It 'Falls back to DisplayName for a resource that is not in the dictionary' {
        $stub = Get-StubBlock -ResourceType 'NotInDictionary' -TargetKey 'Something'
        $stub | Should -Match 'DisplayName = "Something"'
    }
}

Describe 'Sharing state across runspaces' {
    # A parallel export silently produced no DependsOn at all.
    BeforeAll {
        $Script:DllPath = "$PSScriptRoot/../../../Modules/Microsoft365DSC/Dependencies/Assemblies/Microsoft365DSC.Relations.dll"

        function Invoke-InRunspaces
        {
            param([scriptblock] $Body, [object[]] $Arguments, [int] $Count = 8)

            $pool = [runspacefactory]::CreateRunspacePool(1, 8)
            $pool.Open()
            try
            {
                $handles = foreach ($index in 1..$Count)
                {
                    $shell = [powershell]::Create()
                    $shell.RunspacePool = $pool
                    [void]$shell.AddScript($Body)
                    foreach ($argument in $Arguments) { [void]$shell.AddArgument($argument) }
                    [void]$shell.AddArgument($index)
                    [PSCustomObject]@{ Shell = $shell; Handle = $shell.BeginInvoke() }
                }

                foreach ($item in $handles)
                {
                    $item.Shell.EndInvoke($item.Handle)
                    if ($item.Shell.Streams.Error.Count -gt 0)
                    {
                        throw $item.Shell.Streams.Error[0].ToString()
                    }
                    $item.Shell.Dispose()
                }
            }
            finally
            {
                $pool.Close()
                $pool.Dispose()
            }
        }
    }

    It 'Sees dependencies registered from other runspaces' {
        $session = New-TestSession

        Invoke-InRunspaces -Arguments @($Script:DllPath) -Count 8 -Body {
            param($dll, $index)
            Add-Type -Path $dll
            $shared = [Microsoft365DSC.Relations.ExportRelationSession]::Current
            if ($null -eq $shared) { throw 'The session was not visible from this runspace.' }
            $shared.RegisterInstance('AADGroup', "AADGroup-G$index", "G$index", $null)
            $shared.RegisterDependency("Policy-$index", 'IntuneDeviceConfigurationPolicyWindows10', 'AADGroup', "G$index")
        }

        $session.InstanceCount | Should -Be 8
        $session.DependencyCount | Should -Be 8
    }

    It 'Records each distinct dependency exactly once under concurrent writers' {
        $session = New-TestSession

        # Every runspace registers the same 50 dependencies. De-duplication has to hold even
        # when the "have I seen this" test and the append race each other.
        Invoke-InRunspaces -Arguments @($Script:DllPath) -Count 8 -Body {
            param($dll, $index)
            Add-Type -Path $dll
            $shared = [Microsoft365DSC.Relations.ExportRelationSession]::Current
            foreach ($n in 1..50)
            {
                $shared.RegisterDependency('Policy-A', 'IntuneDeviceConfigurationPolicyWindows10', 'AADGroup', "G$n")
            }
        }

        $session.DependencyCount | Should -Be 50
    }

    It 'Hands every caller a distinct instance name for the same base name' {
        [Microsoft365DSC.Relations.ExportInstanceNames]::Reset()

        Invoke-InRunspaces -Arguments @($Script:DllPath) -Count 8 -Body {
            param($dll, $index)
            Add-Type -Path $dll
            foreach ($n in 1..25)
            {
                [void][Microsoft365DSC.Relations.ExportInstanceNames]::Reserve('AADGroup-Shared')
            }
        }

        # 8 runspaces x 25 reservations, all of the same base name, must yield 200 unique names.
        [Microsoft365DSC.Relations.ExportInstanceNames]::Count | Should -Be 200
        [Microsoft365DSC.Relations.ExportInstanceNames]::Reset()
    }
}

Describe 'ExportInstanceNames' {
    BeforeEach {
        Initialize-M365DSCDllLoader
        [Microsoft365DSC.Relations.ExportInstanceNames]::Reset()
    }

    It 'Returns the base name when it is free' {
        [Microsoft365DSC.Relations.ExportInstanceNames]::Reserve('AADGroup-Sales') | Should -Be 'AADGroup-Sales'
    }

    It 'Appends an increasing suffix for repeats' {
        [void][Microsoft365DSC.Relations.ExportInstanceNames]::Reserve('AADGroup-Sales')
        [Microsoft365DSC.Relations.ExportInstanceNames]::Reserve('AADGroup-Sales') | Should -Be 'AADGroup-Sales-2'
        [Microsoft365DSC.Relations.ExportInstanceNames]::Reserve('AADGroup-Sales') | Should -Be 'AADGroup-Sales-3'
    }

    It 'Forgets claimed names on reset' {
        [void][Microsoft365DSC.Relations.ExportInstanceNames]::Reserve('AADGroup-Sales')
        [Microsoft365DSC.Relations.ExportInstanceNames]::Reset()
        [Microsoft365DSC.Relations.ExportInstanceNames]::Reserve('AADGroup-Sales') | Should -Be 'AADGroup-Sales'
    }
}
