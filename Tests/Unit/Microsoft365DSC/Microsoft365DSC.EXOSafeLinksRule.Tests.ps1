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
    -DscResource 'EXOSafeLinksRule' -GenericStubModule $GenericStubPath
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

            Mock -CommandName New-SafeLinksRule -MockWith {
            }

            Mock -CommandName Set-SafeLinksRule -MockWith {
            }

            Mock -CommandName Enable-SafeLinksRule -MockWith {
            }

            Mock -CommandName Disable-SafeLinksRule -MockWith {
            }

            Mock -CommandName Remove-SafeLinksRule -MockWith {
            }

            Mock -CommandName Get-SafeLinksRule -MockWith {
                return @{
                    Ensure            = 'Present'
                    Identity          = 'TestRule'
                    Credential        = $Credential
                    SafeLinksPolicy   = 'TestSafeLinksPolicy'
                    Enabled           = $true
                    Priority          = 0
                    RecipientDomainIs = @('contoso.com')
                    State             = 'Enabled'
                }
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstances =$null
            $Script:ExportMode = $false
        }

        # Test contexts
        Context -Name 'SafeLinksRule creation.' -Fixture {
            BeforeAll {
                $testParams = @{
                    Ensure            = 'Present'
                    Identity          = 'TestRule'
                    Credential        = $Credential
                    SafeLinksPolicy   = 'TestSafeLinksPolicy'
                    Enabled           = $true
                    Priority          = 0
                    RecipientDomainIs = @('contoso.com')
                }

                Mock -CommandName Get-SafeLinksRule -MockWith {
                    return $null
                }
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOSafeLinksRule' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOSafeLinksRule' -Property $testParams).Set()
                Should -Invoke -CommandName New-SafeLinksRule -Exactly 1
            }
        }

        Context -Name 'SafeLinksRule update not required.' -Fixture {
            BeforeAll {
                $testParams = @{
                    Ensure            = 'Present'
                    Identity          = 'TestRule'
                    Credential        = $Credential
                    SafeLinksPolicy   = 'TestSafeLinksPolicy'
                    Enabled           = $true
                    Priority          = 0
                    RecipientDomainIs = @('contoso.com')
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOSafeLinksRule' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name 'SafeLinksRule update needed.' -Fixture {
            BeforeAll {
                $testParams = @{
                    Ensure            = 'Present'
                    Identity          = 'TestRule'
                    Credential        = $Credential
                    SafeLinksPolicy   = 'TestSafeLinksPolicy'
                    Enabled           = $false
                    Priority          = 0
                    RecipientDomainIs = @('fabrikam.com') # Drift
                }
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOSafeLinksRule' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOSafeLinksRule' -Property $testParams).Set()
                Should -Invoke -CommandName Set-SafeLinksRule -Exactly 1
                Should -Invoke -CommandName Disable-SafeLinksRule -Exactly 1
            }
        }

        Context -Name 'SafeLinksRule removal.' -Fixture {
            BeforeAll {
                $testParams = @{
                    Ensure            = 'Absent'
                    Identity          = 'TestRule'
                    Credential        = $Credential
                    SafeLinksPolicy   = 'TestSafeLinksPolicy'
                    Enabled           = $true
                    Priority          = 0
                    RecipientDomainIs = @('contoso.com')
                }
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOSafeLinksRule' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOSafeLinksRule' -Property $testParams).Set()
                Should -Invoke -CommandName Remove-SafeLinksRule -Exactly 1
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
                $result = Invoke-M365DSCResourceMethod -ResourceName 'EXOSafeLinksRule' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
