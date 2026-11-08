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
    }
}
