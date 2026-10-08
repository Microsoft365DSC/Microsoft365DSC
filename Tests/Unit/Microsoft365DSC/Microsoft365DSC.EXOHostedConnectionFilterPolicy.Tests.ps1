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
    -DscResource 'EXOHostedConnectionFilterPolicy' -GenericStubModule $GenericStubPath
Describe -Name $Global:DscHelper.DescribeHeader -Fixture {
    InModuleScope -ModuleName $Global:DscHelper.ModuleName -ScriptBlock {
        Invoke-Command -ScriptBlock $Global:DscHelper.InitializeScript -NoNewScope
        BeforeAll {
            $secpasswd = ConvertTo-SecureString (New-Guid | Out-String) -AsPlainText -Force
            $Credential = New-Object System.Management.Automation.PSCredential ('tenantadmin@onmicrosoft.com', $secpasswd)

            Mock -ModuleName M365DSCUtil -CommandName Confirm-M365DSCDependencies -MockWith {
            }

            Mock -CommandName New-M365DSCConnection -ModuleName '_Shared' -MockWith {
                return 'Credentials'
            }

            Mock -CommandName Get-PSSession -MockWith {
            }

            Mock -CommandName Remove-PSSession -MockWith {
            }

            Mock -CommandName New-HostedConnectionFilterPolicy -MockWith {
            }

            Mock -CommandName Set-HostedConnectionFilterPolicy -MockWith {
            }

            Mock -CommandName Remove-HostedConnectionFilterPolicy -MockWith {
            }

            Mock -CommandName Get-HostedConnectionFilterPolicy -MockWith {
                return @{
                    Ensure           = 'Present'
                    Identity         = 'TestPolicy'
                    Credential       = $Credential
                    AdminDisplayName = 'This policiy is a test'
                    EnableSafeList   = $true
                    IPAllowList      = @('192.168.1.100', '10.1.1.0/24', '172.16.5.1-172.16.5.150')
                    IPBlockList      = @('10.1.1.13', '172.16.5.2')
                    MakeDefault      = $false
                }
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstances =$null
            $Script:ExportMode = $false
        }

        # Test contexts
        Context -Name 'HostedConnectionFilterPolicy creation.' -Fixture {
            BeforeAll {
                $testParams = @{
                    Ensure           = 'Present'
                    Identity         = 'TestPolicy'
                    Credential       = $Credential
                    AdminDisplayName = 'This policiy is a test'
                    EnableSafeList   = $true
                    IPAllowList      = @('192.168.1.100', '10.1.1.0/24', '172.16.5.1-172.16.5.150')
                    IPBlockList      = @('10.1.1.13', '172.16.5.2')
                    MakeDefault      = $false
                }

                Mock -CommandName Get-HostedConnectionFilterPolicy -MockWith {
                    return $null
                }
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOHostedConnectionFilterPolicy' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOHostedConnectionFilterPolicy' -Property $testParams).Set()
                Should -Invoke -CommandName New-HostedConnectionFilterPolicy -Exactly 1
            }
        }

        Context -Name 'HostedConnectionFilterPolicy update not required.' -Fixture {
            BeforeAll {
                $testParams = @{
                    Ensure           = 'Present'
                    Identity         = 'TestPolicy'
                    Credential       = $Credential
                    AdminDisplayName = 'This policiy is a test'
                    EnableSafeList   = $true
                    IPAllowList      = @('192.168.1.100', '10.1.1.0/24', '172.16.5.1-172.16.5.150')
                    IPBlockList      = @('10.1.1.13', '172.16.5.2')
                    MakeDefault      = $false
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOHostedConnectionFilterPolicy' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name 'HostedConnectionFilterPolicy update needed.' -Fixture {
            BeforeAll {
                $testParams = @{
                    Ensure           = 'Present'
                    Identity         = 'TestPolicy'
                    Credential       = $Credential
                    AdminDisplayName = 'This policiy is a test'
                    EnableSafeList   = $false # Drift
                    IPAllowList      = @('192.168.1.100', '10.1.1.0/24', '172.16.5.1-172.16.5.150')
                    IPBlockList      = @('10.1.1.13', '172.16.5.2')
                    MakeDefault      = $false
                }
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOHostedConnectionFilterPolicy' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOHostedConnectionFilterPolicy' -Property $testParams).Set()
                Should -Invoke -CommandName Set-HostedConnectionFilterPolicy -Exactly 1
            }
        }

        Context -Name 'HostedConnectionFilterPolicy removal.' -Fixture {
            BeforeAll {
                $testParams = @{
                    Ensure     = 'Absent'
                    Identity   = 'TestPolicy'
                    Credential = $Credential
                }
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOHostedConnectionFilterPolicy' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOHostedConnectionFilterPolicy' -Property $testParams).Set()
                Should -Invoke -CommandName Remove-HostedConnectionFilterPolicy -Exactly 1
            }
        }

        Context -Name 'ReverseDSC Tests' -Fixture {
            BeforeAll {
                $Global:CurrentModeIsExport = $true
                $Global:PartialExportFileName = "$(New-Guid).partial.ps1"
                $testParams = @{
                    Credential = $Credential
                }
            }

            It 'Should Reverse Engineer resource from the Export method' {
                $result = Invoke-M365DSCResourceMethod -ResourceName 'EXOHostedConnectionFilterPolicy' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
