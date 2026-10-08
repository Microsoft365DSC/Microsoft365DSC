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
    -DscResource 'SCSecurityFilter' -GenericStubModule $GenericStubPath
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

            Mock -CommandName Import-PSSession -MockWith {
            }

            Mock -CommandName New-PSSession -MockWith {
            }


            Mock -CommandName Remove-ComplianceSecurityFilter -MockWith {
            }

            Mock -CommandName New-ComplianceSecurityFilter -MockWith {
                return @{

                }
            }

            Mock -CommandName Set-ComplianceSecurityFilter -MockWith {
                return @{

                }
            }

            Mock -CommandName Start-Sleep -MockWith {
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstances =$null
            $Script:ExportMode = $false
        }

        # Test contexts
        Context -Name "Security Filter doesn't already exist but should" -Fixture {
            BeforeAll {
                $testParams = @{
                    Action           = "All"
                    Description      = "My Desc"
                    FilterName       = "MYFILTER"
                    Filters          = @("Mailbox_CountryCode -eq '124'")
                    Region           = "FRA"
                    Users            = @("John.Smith@$Domain")
                    Credential       = $Credential
                    Ensure           = 'Present'
                }

                Mock -CommandName Get-ComplianceSecurityFilter -MockWith {
                    return $null
                }
            }

            It 'Should return Absent from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'SCSecurityFilter' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'SCSecurityFilter' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the New method' {
                (New-M365DSCResourceInstance -ResourceName 'SCSecurityFilter' -Property $testParams).Set()
                Should -Invoke -CommandName New-ComplianceSecurityFilter    -Exactly 1
                Should -Invoke -CommandName Set-ComplianceSecurityFilter    -Exactly 0
                Should -Invoke -CommandName Remove-ComplianceSecurityFilter -Exactly 0
            }
        }

        Context -Name 'Security Filter exists but is not in the Desired State' -Fixture {
            BeforeAll {
                $testParams = @{
                    Action           = "All"
                    Description      = "My Desc"
                    FilterName       = "MYFILTER"
                    Filters          = @("Mailbox_CountryCode -eq '124'")
                    Region           = "FRA"
                    Users            = @("John.Smith@$Domain")
                    Credential       = $Credential
                    Ensure           = 'Present'
                }

                Mock -CommandName Get-ComplianceSecurityFilter -MockWith {
                    return @{
                        Action           = "All"
                        Description      = "My Desc"
                        FilterName       = "MYFILTER"
                        Filters          = @("Mailbox_CountryCode -eq '124'")
                        Region           = "AUS" # This is different
                        Users            = @("John.Smith@$Domain")
                        Credential       = $Credential
                        Ensure           = 'Present'
                    }
                }
            }

            It 'Should return Present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'SCSecurityFilter' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'SCSecurityFilter' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should update from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'SCSecurityFilter' -Property $testParams).Set()
                Should -Invoke -CommandName New-ComplianceSecurityFilter    -Exactly 0
                Should -Invoke -CommandName Set-ComplianceSecurityFilter    -Exactly 1
                Should -Invoke -CommandName Remove-ComplianceSecurityFilter -Exactly 0
            }

        }

        Context -Name 'Security Filter exists and is already in the Desired State' -Fixture {
            BeforeAll {
                $testParams = @{
                    Action           = "All"
                    Description      = "My Desc"
                    FilterName       = "MYFILTER"
                    Filters          = @("Mailbox_CountryCode -eq '124'")
                    Region           = "FRA"
                    Users            = @("John.Smith@$Domain")
                    Ensure           = 'Present'
                }

                Mock -CommandName Get-ComplianceSecurityFilter -MockWith {
                    return @{
                        Action           = "All"
                        Description      = "My Desc"
                        FilterName       = "MYFILTER"
                        Filters          = @("Mailbox_CountryCode -eq '124'")
                        Region           = "FRA"
                        Users            = @("John.Smith@$Domain")
                    }
                }
            }

            It 'Should return Present from the Get method' {
                $returnValue = (New-M365DSCResourceInstance -ResourceName 'SCSecurityFilter' -Property $testParams).Get().ToHashtable()
                $returnValue.Ensure | Should -Be 'Present'
            }

            It 'Should return true from the Test method' {
                $returnValue = (New-M365DSCResourceInstance -ResourceName 'SCSecurityFilter' -Property $testParams).Test()
                $returnValue | Should -Be $true
            }

            It 'Should update from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'SCSecurityFilter' -Property $testParams).Set()
                Should -Invoke -CommandName New-ComplianceSecurityFilter    -Exactly 0
                Should -Invoke -CommandName Set-ComplianceSecurityFilter    -Exactly 1
                Should -Invoke -CommandName Remove-ComplianceSecurityFilter -Exactly 0
            }

        }

        Context -Name 'Security Filter exists but should not exist' -Fixture {
            BeforeAll {
                $testParams = @{
                    Action           = "All"
                    Description      = "My Desc"
                    FilterName       = "MYFILTER"
                    Filters          = @("Mailbox_CountryCode -eq '124'")
                    Region           = "FRA"
                    Users            = @("John.Smith@$Domain")
                    Credential       = $Credential
                    Ensure           = 'Absent'
                }
            }

            It 'Should return true from the Test method' {

                Mock -CommandName Get-ComplianceSecurityFilter -MockWith {
                    return @{
                        Action           = "All"
                        Description      = "My Desc"
                        FilterName       = "MYFILTER"
                        Filters          = @("Mailbox_CountryCode -eq '124'")
                        Region           = "AUS" # This is different
                        Users            = @("John.Smith@$Domain")
                        }
                }
                (New-M365DSCResourceInstance -ResourceName 'SCSecurityFilter' -Property $testParams).Test() | Should -Be $false
            }
            It 'Should return Present from the Get method' {

                Mock -CommandName Get-ComplianceSecurityFilter -MockWith {
                    return @{
                        Action           = "All"
                        Description      = "My Desc"
                        FilterName       = "MYFILTER"
                        Filters          = @("Mailbox_CountryCode -eq '124'")
                        Region           = "AUS" # This is different
                        Users            = @("John.Smith@$Domain")
                        }
                }
                ((New-M365DSCResourceInstance -ResourceName 'SCSecurityFilter' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'

            }

            It 'Should delete from the Set method' {
                Mock -CommandName Get-ComplianceSecurityFilter -MockWith {
                    return @{
                        Action           = "All"
                        Description      = "My Desc"
                        FilterName       = "MYFILTER"
                        Filters          = @("Mailbox_CountryCode -eq '124'")
                        Region           = "AUS" # This is different
                        Users            = @("John.Smith@$Domain")
                    }
                }
                (New-M365DSCResourceInstance -ResourceName 'SCSecurityFilter' -Property $testParams).Set()
                Should -Invoke -CommandName New-ComplianceSecurityFilter    -Exactly 0
                Should -Invoke -CommandName Set-ComplianceSecurityFilter    -Exactly 0
                Should -Invoke -CommandName Remove-ComplianceSecurityFilter -Exactly 1
            }
        }

        Context -Name 'ReverseDSC Tests' -Fixture {
            BeforeAll {
                $Global:CurrentModeIsExport = $true
                $Global:PartialExportFileName = "$(New-Guid).partial.ps1"
                $testParams = @{
                    Credential = $Credential
                }
                Mock -CommandName Get-ComplianceSecurityFilter -MockWith {
                    return @{
                        FilterName     = 'TestFilter'
                        Action         = 'All'
                    }
                }
            }

            It 'Should Reverse Engineer resource from the Export method' {
                $result = Invoke-M365DSCResourceMethod -ResourceName 'SCSecurityFilter' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
                Should -Invoke -CommandName Get-ComplianceSecurityFilter -Exactly 1
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
