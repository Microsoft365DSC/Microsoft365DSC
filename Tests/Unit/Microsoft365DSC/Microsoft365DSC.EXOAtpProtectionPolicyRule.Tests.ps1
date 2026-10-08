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

$CurrentScriptPath = $PSCommandPath.Split('\')
$CurrentScriptName = $CurrentScriptPath[$CurrentScriptPath.Length -1]
$ResourceName      = $CurrentScriptName.Split('.')[1]
$Global:DscHelper = New-M365DscUnitTestHelper -StubModule $CmdletModule `
    -DscResource $ResourceName -GenericStubModule $GenericStubPath

Describe -Name $Global:DscHelper.DescribeHeader -Fixture {
    InModuleScope -ModuleName $Global:DscHelper.ModuleName -ScriptBlock {
        Invoke-Command -ScriptBlock $Global:DscHelper.InitializeScript -NoNewScope
        BeforeAll {

            $secpasswd = ConvertTo-SecureString (New-Guid | Out-String) -AsPlainText -Force
            $Credential = New-Object System.Management.Automation.PSCredential ('tenantadmin@onmicrosoft.com', $secpasswd)

            Mock -ModuleName M365DSCUtil -CommandName Confirm-M365DSCDependencies -MockWith {
            }

            Mock -CommandName New-M365DSCConnection -ModuleName '_Shared' -MockWith {
                return "Credentials"
            }

            Mock -CommandName Get-ATPProtectionPolicyRule -MockWith {
                return @{
                    Identity = 'TestRule'
                    State    = 'Enabled'
                }
            }

            Mock -CommandName Set-ATPProtectionPolicyRule -MockWith {
            }

            Mock -CommandName Remove-ATPProtectionPolicyRule -MockWith {
                return $null
            }

            Mock -CommandName New-ATPProtectionPolicyRule -MockWith {
            }

            Mock -CommandName Enable-ATPProtectionPolicyRule -MockWith {
            }

            Mock -CommandName Disable-ATPProtectionPolicyRule -MockWith {
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstances =$null
            $Script:ExportMode = $false
        }
        # Test contexts
        Context -Name "The instance should exist but it DOES NOT" -Fixture {
            BeforeAll {
                $testParams = @{
                    Identity            = 'TestRule'
                    Ensure              = 'Present'
                    Credential          = $Credential;
                }

                Mock -CommandName Get-ATPProtectionPolicyRule -MockWith {
                    return $null
                }
            }
            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'EXOAtpProtectionPolicyRule' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }
            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOAtpProtectionPolicyRule' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should create a new instance from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOAtpProtectionPolicyRule' -Property $testParams).Set()
                Should -Invoke -CommandName New-ATPProtectionPolicyRule -Exactly 1
            }
        }

        Context -Name "The instance exists but it SHOULD NOT" -Fixture {
            BeforeAll {
                $testParams = @{
                    Identity            = 'TestRule'
                    Ensure              = 'Absent'
                    Credential          = $Credential;
                }
            }
            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'EXOAtpProtectionPolicyRule' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }
            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOAtpProtectionPolicyRule' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should remove the instance from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOAtpProtectionPolicyRule' -Property $testParams).Set()
                Should -Invoke -CommandName Remove-ATPProtectionPolicyRule -Exactly 1
            }
        }

        Context -Name "The instance exists and values are already in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    Identity            = 'TestRule'
                    Ensure              = 'Present'
                    Credential          = $Credential;
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOAtpProtectionPolicyRule' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name "The instance exists and values are NOT in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    Identity            = 'TestRule'
                    Comments            = 'TestComment' # Drift
                    Ensure              = 'Present'
                    Credential          = $Credential;
                }

                Mock -CommandName Get-ATPProtectionPolicyRule -MockWith {
                    return @{
                        Identity             = 'TestRule'
                        State                = 'Enabled'
                        SafeAttachmentPolicy = 'Standard Preset Security Policy1'
                        SafeLinksPolicy      = 'Standard Preset Security Policy2'
                    }
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'EXOAtpProtectionPolicyRule' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOAtpProtectionPolicyRule' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOAtpProtectionPolicyRule' -Property $testParams).Set()
                Should -Invoke -CommandName Set-ATPProtectionPolicyRule -Exactly 1
                Should -Invoke -CommandName Disable-ATPProtectionPolicyRule -Exactly 0
            }
        }

        Context -Name "The instance exists and should be disabled, but is not" -Fixture {
            BeforeAll {
                $testParams = @{
                    Identity            = 'TestRule'
                    Ensure              = 'Present'
                    Enabled             = $false
                    Credential          = $Credential;
                }
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOAtpProtectionPolicyRule' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Disable method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOAtpProtectionPolicyRule' -Property $testParams).Set()
                Should -Invoke -CommandName Disable-ATPProtectionPolicyRule -Exactly 1
            }
        }

        Context -Name "The instance exists and should be enabled, but is not" -Fixture {
            BeforeAll {
                $testParams = @{
                    Identity            = 'TestRule'
                    Ensure              = 'Present'
                    Enabled             = $True
                    Credential          = $Credential;
                }

                Mock -CommandName Get-ATPProtectionPolicyRule -MockWith {
                    return @{
                        Identity            = 'TestRule'
                        State               = 'Disabled'
                    }
                }

                Mock -CommandName Set-ATPProtectionPolicyRule -MockWith {
                    return $testParams
                }

                Mock -CommandName Enable-ATPProtectionPolicyRule -MockWith {
                    return $null
                }
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOAtpProtectionPolicyRule' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Enable method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOAtpProtectionPolicyRule' -Property $testParams).Set()
                Should -Invoke -CommandName Enable-ATPProtectionPolicyRule -Exactly 1
            }
        }

        Context -Name 'ReverseDSC Tests' -Fixture {
            BeforeAll {
                $Global:CurrentModeIsExport = $true
                $Global:PartialExportFileName = "$(New-Guid).partial.ps1"
                $testParams = @{
                    Credential  = $Credential;
                }
            }
            It 'Should Reverse Engineer resource from the Export method' {
                $result = Invoke-M365DSCResourceMethod -ResourceName 'EXOAtpProtectionPolicyRule' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
