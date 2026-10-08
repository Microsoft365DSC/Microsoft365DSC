[CmdletBinding()]
param(
)
$M365DSCTestFolder = Join-Path -Path $PSScriptRoot `
    -ChildPath '..\..\Unit' `
    -Resolve
$CmdletModule = (Join-Path -Path $M365DSCTestFolder `
        -ChildPath '\Stubs\Microsoft365.psm1' `
        -Resolve)
$GenericStubPath = (Join-Path -Path $M365DSCTestFolder `
        -ChildPath '\Stubs\Generic.psm1' `
        -Resolve)
Import-Module -Name (Join-Path -Path $M365DSCTestFolder `
        -ChildPath '\UnitTestHelper.psm1' `
        -Resolve)

$Global:DscHelper = New-M365DscUnitTestHelper -StubModule $CmdletModule `
    -DscResource 'TeamsUserCallingSettings' -GenericStubModule $GenericStubPath

Describe -Name $Global:DscHelper.DescribeHeader -Fixture {
    InModuleScope -ModuleName $Global:DscHelper.ModuleName -ScriptBlock {
        Invoke-Command -ScriptBlock $Global:DscHelper.InitializeScript -NoNewScope

        BeforeAll {
            $secpasswd = ConvertTo-SecureString ((New-Guid).ToString()) -AsPlainText -Force
            $Credential = New-Object System.Management.Automation.PSCredential ('tenantadmin@onmicrosoft.com', $secpasswd)

            $Global:PartialExportFileName = 'c:\TestPath'

            Mock -ModuleName M365DSCUtil -CommandName Confirm-M365DSCDependencies -MockWith {
            }

            Mock -CommandName Save-M365DSCPartialExport -MockWith {
            }

            Mock -CommandName New-M365DSCConnection -ModuleName '_Shared' -MockWith {
                return 'Credentials'
            }

            Mock -CommandName Set-CsUserCallingSettings -MockWith {
            }

            Mock -CommandName Get-CsUserCallingSettings -MockWith {
                return @{
                    CallGroupOrder         = 'Simultaneous'
                    CallGroupTargets       = @('sip:megan.bowen@contoso.com', 'alex.wilber@contoso.com')
                    IsUnansweredEnabled    = $true
                    UnansweredDelay        = '00:00:20'
                    ForwardingTarget       = 'sip:adele.vance@contoso.com'
                    BusyOnBusyOption       = 'RingUser'
                    MaximumConcurrentCalls = 2
                }
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstances =$null
            $Script:ExportMode = $false
        }

        # Test contexts
        Context -Name 'When no settings are assigned to a user' -Fixture {
            BeforeAll {
                $testParams = @{
                    Identity               = 'Test Settings'
                    CallGroupOrder         = 'Simultaneous'
                    CallGroupTargets       = @('sip:megan.bowen@contoso.com')
                    Ensure                 = 'Present'
                    Credential             = $Credential
                    IsUnansweredEnabled    = $true
                    UnansweredDelay        = '00:00:20'
                    BusyOnBusyOption       = 'RingUser'
                    MaximumConcurrentCalls = 2
                }

                Mock -CommandName Get-CsUserCallingSettings -MockWith {
                    return $null
                }
            }

            It 'Should return absent from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'TeamsUserCallingSettings' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsUserCallingSettings' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should assign settings in the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsUserCallingSettings' -Property $testParams).Set()
                Should -Invoke -CommandName Set-CsUserCallingSettings -Exactly 4
                Should -Invoke -CommandName Set-CsUserCallingSettings -Exactly 1 -ParameterFilter { $CallGroupTargets -join ',' -eq 'megan.bowen@contoso.com' }
            }
        }

        Context -Name 'Settings exists but is not in the Desired State' -Fixture {
            BeforeAll {
                $testParams = @{
                    Identity               = 'Test Settings'
                    CallGroupOrder         = 'Simultaneous'
                    CallGroupTargets       = @()
                    Ensure                 = 'Present'
                    Credential             = $Credential
                    UnansweredDelay        = '00:00:30' # Drift
                    IsForwardingEnabled    = $true
                    BusyOnBusyOption       = 'RingUser'
                    MaximumConcurrentCalls = 2
                }

                Mock -CommandName Set-CsUserCallingSettings -MockWith {
                    $Script:setCallOrder.Add((@($PesterBoundParameters.Keys | Sort-Object) -join ','))
                }
            }

            It 'Should return Present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'TeamsUserCallingSettings' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsUserCallingSettings' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should update the settings from the Set method' {
                $Script:setCallOrder = [System.Collections.Generic.List[System.String]]::new()
                (New-M365DSCResourceInstance -ResourceName 'TeamsUserCallingSettings' -Property $testParams).Set()
                Should -Invoke -CommandName Set-CsUserCallingSettings -Exactly 3
                $Script:setCallOrder | Should -Be @(
                    'Identity,IsUnansweredEnabled,UnansweredDelay',
                    'Identity,IsForwardingEnabled',
                    'CallGroupOrder,CallGroupTargets,Identity'
                )
            }
        }

        Context -Name 'Settings exists and is already in the Desired State' -Fixture {
            BeforeAll {
                $testParams = @{
                    Identity               = 'Test Settings'
                    CallGroupOrder         = 'Simultaneous'
                    CallGroupTargets       = @('megan.bowen@contoso.com', 'sip:alex.wilber@contoso.com')
                    Ensure                 = 'Present'
                    Credential             = $Credential
                    UnansweredDelay        = '00:00:20'
                    ForwardingTarget       = 'adele.vance@contoso.com'
                    BusyOnBusyOption       = 'RingUser'
                    MaximumConcurrentCalls = 2
                }
            }

            It 'Should return Present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'TeamsUserCallingSettings' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsUserCallingSettings' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name 'ReverseDSC Tests' -Fixture {
            BeforeAll {
                $Global:CurrentModeIsExport = $true
                $Global:PartialExportFileName = "$(New-Guid).partial.ps1"
                $testParams = @{
                    Credential = $Credential
                }

                Mock -CommandName Get-MgUser -MockWith {
                    return @(
                        @{
                            UserPrincipalName = 'John.Smith@contoso.onmicrosoft.com'
                        }
                    )
                }
            }

            It 'Should Reverse Engineer resource from the Export method' {
                $result = Invoke-M365DSCResourceMethod -ResourceName 'TeamsUserCallingSettings' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
