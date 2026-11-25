BeforeAll {
    $Script:LogEngineModule = $null
    if ($null -eq (Get-Module -Name 'Microsoft365DSC'))
    {
        $Script:LogEngineModule = Import-Module "$PSScriptRoot/../../../Modules/Microsoft365DSC/Modules/M365DSCLogEngine.psm1" -PassThru
    }
}

AfterAll {
    if ($null -ne $Script:LogEngineModule)
    {
        Remove-Module -ModuleInfo $Script:LogEngineModule -Force -ErrorAction SilentlyContinue
    }
}

Describe 'ConvertFrom-M365DSCNotificationEndpointRegistration' {
    It 'Should return one object per registration with its own event type' {
        $result = InModuleScope -ModuleName M365DSCLogEngine -ScriptBlock {
            ConvertFrom-M365DSCNotificationEndpointRegistration -Value 'https://a.com/x|Drift;https://b.org/api/hook?x=1|NonDrift;'
        }

        $result | Should -HaveCount 2
        $result[0].Url | Should -Be 'https://a.com/x'
        $result[0].EventType | Should -Be 'Drift'
        $result[1].Url | Should -Be 'https://b.org/api/hook?x=1'
        $result[1].EventType | Should -Be 'NonDrift'
    }

    It 'Should skip malformed entries and return nothing for an empty value' {
        $result = InModuleScope -ModuleName M365DSCLogEngine -ScriptBlock {
            ConvertFrom-M365DSCNotificationEndpointRegistration -Value 'https://a.com|Drift;garbage;;https://b.com|Error|Extra;'
        }

        $result | Should -HaveCount 1
        $result[0].Url | Should -Be 'https://a.com'

        InModuleScope -ModuleName M365DSCLogEngine -ScriptBlock {
            ConvertFrom-M365DSCNotificationEndpointRegistration -Value ''
        } | Should -BeNullOrEmpty
    }
}

Describe 'ConvertTo-M365DSCNotificationEndpointRegistration' {
    It 'Should rebuild the stored value from the parsed registrations' {
        $result = InModuleScope -ModuleName M365DSCLogEngine -ScriptBlock {
            $registrations = ConvertFrom-M365DSCNotificationEndpointRegistration -Value 'https://a.com/x|Drift;https://b.org|Error;'
            ConvertTo-M365DSCNotificationEndpointRegistration -Registration $registrations
        }

        $result | Should -BeExactly 'https://a.com/x|Drift;https://b.org|Error;'

        $result = InModuleScope -ModuleName M365DSCLogEngine -ScriptBlock {
            ConvertTo-M365DSCNotificationEndpointRegistration -Registration $null
        }

        $result | Should -BeExactly ''
    }
}

Describe 'Source location mapping' {
    BeforeAll {
        InModuleScope -ModuleName M365DSCLogEngine -ScriptBlock {
            $Script:SavedSourceMap = $Script:M365DSCSourceMap
            $Script:M365DSCSourceMap = @{
                'Part03.psm1'  = @(
                    [PSCustomObject]@{ StartLine = 10; EndLine = 50; Source = 'DscResources/MSFT_Foo/MSFT_Foo.psm1'; SourceLine = 3 }
                    [PSCustomObject]@{ StartLine = 60; EndLine = 90; Source = 'DscResources/MSFT_Bar/MSFT_Bar.psm1'; SourceLine = 1 }
                )
                '_Shared.psm1' = @(
                    [PSCustomObject]@{ StartLine = 4; EndLine = 100; Source = 'DscResources/_Base/M365DSCResourceBase.psm1'; SourceLine = 1 }
                )
            }
        }
    }

    AfterAll {
        InModuleScope -ModuleName M365DSCLogEngine -ScriptBlock {
            $Script:M365DSCSourceMap = $Script:SavedSourceMap
        }
    }

    It 'Should map a generated line to its source line' {
        $result = InModuleScope -ModuleName M365DSCLogEngine -ScriptBlock {
            Get-M365DSCSourceLocation -Path 'C:\Modules\Microsoft365DSC\Classes\Part03.psm1' -Line 65
        }

        $result.Path | Should -BeLike '*MSFT_Bar.psm1'
        $result.Line | Should -Be 6
    }

    It 'Should not return a source location for a line outside every block' {
        InModuleScope -ModuleName M365DSCLogEngine -ScriptBlock {
            Get-M365DSCSourceLocation -Path 'Part03.psm1' -Line 55
        } | Should -BeNullOrEmpty
    }

    It 'Should append the source location to stack trace and position frames' {
        $result = InModuleScope -ModuleName M365DSCLogEngine -ScriptBlock {
            Resolve-M365DSCSourceLocation -InputObject "at Get, C:\x\Classes\Part03.psm1: line 12`nAt C:\x\Classes\_Shared.psm1:5 char:9`nat <ScriptBlock>, C:\x\Other.psm1: line 7"
        }

        $lines = $result -split "`n"
        $lines[0] | Should -BeLike 'at Get, C:\x\Classes\Part03.psm1: line 12 `[*MSFT_Foo.psm1:5`]'
        $lines[1] | Should -BeLike 'At C:\x\Classes\_Shared.psm1:5 `[*M365DSCResourceBase.psm1:2`] char:9'
        $lines[2] | Should -BeExactly 'at <ScriptBlock>, C:\x\Other.psm1: line 7'
    }

    It 'Should pass empty input through' {
        InModuleScope -ModuleName M365DSCLogEngine -ScriptBlock {
            Resolve-M365DSCSourceLocation -InputObject $null
        } | Should -BeNullOrEmpty
    }

    It 'Should set the breakpoint on the generated line' {
        Mock -ModuleName M365DSCLogEngine -CommandName Set-PSBreakpoint

        InModuleScope -ModuleName M365DSCLogEngine -ScriptBlock {
            Set-M365DSCSourceBreakpoint -Path 'Foo' -Line 5
        }

        Should -Invoke -ModuleName M365DSCLogEngine -CommandName Set-PSBreakpoint -Exactly 1 -ParameterFilter {
            $Script -like '*Classes*Part03.psm1' -and $Line -eq 12
        }
    }

    It 'Should throw for a source line that is not mapped' {
        {
            InModuleScope -ModuleName M365DSCLogEngine -ScriptBlock {
                Set-M365DSCSourceBreakpoint -Path 'MSFT_Foo.psm1' -Line 200
            }
        } | Should -Throw '*not part of a generated class file*'
    }
}

Describe 'Send-M365DSCNotificationEndPointMessage' {
    BeforeAll {
        Mock -ModuleName M365DSCLogEngine -CommandName Get-M365DSCNotificationEndpointRegistration -MockWith {
            return @(
                [PSCustomObject]@{ Url = 'https://foo.example.com/hook'; EventType = 'Drift' }
                [PSCustomObject]@{ Url = 'https://bar.example.com/hook'; EventType = 'Drift' }
            )
        }
        Mock -ModuleName M365DSCLogEngine -CommandName Invoke-RestMethod

        $Global:M365DSCNotificationEndpointBearerfoo = 'footoken'

        InModuleScope -ModuleName M365DSCLogEngine -ScriptBlock {
            Send-M365DSCNotificationEndPointMessage -EventDetails 'details' -EventType 'Drift'
        }
    }

    AfterAll {
        Remove-Variable -Name 'M365DSCNotificationEndpointBearerfoo' -Scope Global -ErrorAction SilentlyContinue
    }

    It 'Should send the bearer token only to the endpoint of its domain' {
        Should -Invoke -ModuleName M365DSCLogEngine -CommandName Invoke-RestMethod -Exactly 1 -Scope Describe -ParameterFilter {
            $Uri.AbsoluteUri -eq 'https://foo.example.com/hook' -and $Headers.Authorization -eq 'Bearer footoken'
        }
        Should -Invoke -ModuleName M365DSCLogEngine -CommandName Invoke-RestMethod -Exactly 1 -Scope Describe -ParameterFilter {
            $Uri.AbsoluteUri -eq 'https://bar.example.com/hook' -and $null -eq $Headers
        }
        Should -Invoke -ModuleName M365DSCLogEngine -CommandName Invoke-RestMethod -Exactly 2 -Scope Describe -ParameterFilter {
            $ConnectionTimeoutSeconds -eq 10 -and $OperationTimeoutSeconds -eq 30
        }
    }
}
