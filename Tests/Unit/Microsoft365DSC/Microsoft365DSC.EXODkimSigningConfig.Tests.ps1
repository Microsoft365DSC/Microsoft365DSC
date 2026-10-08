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
    -DscResource 'EXODkimSigningConfig' -GenericStubModule $GenericStubPath
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

            Mock -CommandName New-DkimSigningConfig -MockWith {
            }

            Mock -CommandName Set-DkimSigningConfig -MockWith {
            }

            Mock -CommandName Remove-DkimSigningConfig -MockWith {
            }

            Mock -CommandName Get-DkimSigningConfig -MockWith {
                return @{
                    Ensure                 = 'Present'
                    Identity               = 'contoso.com'
                    Credential             = $Credential
                    AdminDisplayName       = 'contoso.com DKIM Config'
                    BodyCanonicalization   = 'Relaxed'
                    Enabled                = $false
                    HeaderCanonicalization = 'Relaxed'
                    Selector1KeySize       = 1024
                }
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstances =$null
            $Script:ExportMode = $false
        }

        # Test contexts
        Context -Name 'DkimSigningConfig creation.' -Fixture {
            BeforeAll {
                $testParams = @{
                    Ensure                 = 'Present'
                    Identity               = 'contoso.com'
                    Credential             = $Credential
                    AdminDisplayName       = 'contoso.com DKIM Config'
                    BodyCanonicalization   = 'Relaxed'
                    Enabled                = $false
                    HeaderCanonicalization = 'Relaxed'
                    KeySize                = 1024
                }

                Mock -CommandName Get-DkimSigningConfig -MockWith {
                    return $null
                }
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXODkimSigningConfig' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'EXODkimSigningConfig' -Property $testParams).Set()
                Should -Invoke -CommandName 'New-DkimSigningConfig' -Exactly 1
            }
        }

        Context -Name 'DkimSigningConfig update not required.' -Fixture {
            BeforeAll {
                $testParams = @{
                    Ensure                 = 'Present'
                    Identity               = 'contoso.com'
                    Credential             = $Credential
                    AdminDisplayName       = 'contoso.com DKIM Config'
                    BodyCanonicalization   = 'Relaxed'
                    Enabled                = $false
                    HeaderCanonicalization = 'Relaxed'
                    KeySize                = 1024
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXODkimSigningConfig' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name 'DkimSigningConfig update needed.' -Fixture {
            BeforeAll {
                $testParams = @{
                    Ensure                 = 'Present'
                    Identity               = 'contoso.com'
                    Credential             = $Credential
                    AdminDisplayName       = 'contoso.com DKIM Config'
                    BodyCanonicalization   = 'Relaxed'
                    Enabled                = $true # Drift
                    HeaderCanonicalization = 'Relaxed'
                    KeySize                = 1024
                }
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXODkimSigningConfig' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'EXODkimSigningConfig' -Property $testParams).Set()
                Should -Invoke -CommandName 'Set-DkimSigningConfig' -Exactly 1
            }
        }

        Context -Name 'DkimSigningConfig removal.' -Fixture {
            BeforeAll {
                $testParams = @{
                    Ensure     = 'Absent'
                    Identity   = 'contoso.com'
                    Credential = $Credential
                }
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXODkimSigningConfig' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'EXODkimSigningConfig' -Property $testParams).Set()
                Should -Invoke -CommandName 'Set-DkimSigningConfig' -Exactly 1
            }
        }

        Context -Name 'ReverseDSC Tests' -Fixture {
            BeforeAll {
                $Global:CurrentModeIsExport = $true
                $Global:PartialExportFileName = "$(New-Guid).partial.ps1"
                $testParams = @{
                    Credential = $Credential
                }

                Mock -CommandName Confirm-ImportedCmdletIsAvailable -MockWith {
                    return $true
                }
            }

            It 'Should Reverse Engineer resource from the Export method' {
                $result = Invoke-M365DSCResourceMethod -ResourceName 'EXODkimSigningConfig' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
