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
    -DscResource 'SCComplianceSearch' -GenericStubModule $GenericStubPath
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

            Mock -CommandName Remove-ComplianceSearch -MockWith {
                return @{

                }
            }

            Mock -CommandName New-ComplianceSearch -MockWith {
                return @{

                }
            }

            Mock -CommandName Set-ComplianceSearch -MockWith {
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
        Context -Name "Search doesn't already exist" -Fixture {
            BeforeAll {
                $testParams = @{
                    Case                                  = 'Test Search Case'
                    Name                                  = 'Demo Compliance Search'
                    Language                              = 'iv'
                    AllowNotFoundExchangeLocationsEnabled = $False
                    SharePointLocation                    = @('All')
                    Credential                            = $Credential
                    Ensure                                = 'Present'
                }

                Mock -CommandName Get-ComplianceSearch -MockWith {
                    return $null
                }
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'SCComplianceSearch' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should return Absent from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'SCComplianceSearch' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'SCComplianceSearch' -Property $testParams).Set()
            }
        }

        Context -Name 'Search already exists, but need to update properties' -Fixture {
            BeforeAll {
                $testParams = @{
                    Case                                  = 'Test Search Case'
                    Name                                  = 'Demo Compliance Search'
                    Language                              = 'iv'
                    AllowNotFoundExchangeLocationsEnabled = $False
                    SharePointLocation                    = @('https://contoso.com')
                    Credential                            = $Credential
                    Ensure                                = 'Present'
                }

                Mock -CommandName Get-ComplianceSearch -MockWith {
                    return @{
                        Name                                  = 'Demo Compliance Search'
                        Case                                  = 'Test Search Case'
                        Language                              = @{
                            Name = 'iv'
                        }
                        AllowNotFoundExchangeLocationsEnabled = $False
                        SharePointLocation                    = @('https://tailspintoys.com')
                    }
                }
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'SCComplianceSearch' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should update from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'SCComplianceSearch' -Property $testParams).Set()
            }

            It 'Should return Present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'SCComplianceSearch' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }
        }

        Context -Name 'Rule should not exist' -Fixture {
            BeforeAll {
                $testParams = @{
                    Case                                  = 'Test Search Case'
                    Name                                  = 'Demo Compliance Search'
                    Language                              = 'iv'
                    AllowNotFoundExchangeLocationsEnabled = $False
                    SharePointLocation                    = @('All')
                    Credential                            = $Credential
                    Ensure                                = 'Absent'
                }

                Mock -CommandName Get-ComplianceSearch -MockWith {
                    return @{
                        Name                                  = 'Demo Compliance Search'
                        Language                              = @{
                            Name = 'iv'
                        }
                        AllowNotFoundExchangeLocationsEnabled = $False
                    }
                }
            }

            It 'Should return False from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'SCComplianceSearch' -Property $testParams).Test() | Should -Be $False
            }

            It 'Should delete from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'SCComplianceSearch' -Property $testParams).Set()
            }

            It 'Should return Present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'SCComplianceSearch' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }
        }

        Context -Name 'ReverseDSC Tests' -Fixture {
            BeforeAll {
                $Global:CurrentModeIsExport = $true
                $Global:PartialExportFileName = "$(New-Guid).partial.ps1"
                $testParams = @{
                    Credential = $Credential
                }

                Mock -CommandName Get-ComplianceSearch -MockWith {
                    return @{
                        Name                                  = 'Demo Compliance Search'
                        Case                                  = 'Test Search Case'
                        Language                              = @{
                            Name = 'iv'
                        }
                        AllowNotFoundExchangeLocationsEnabled = $False
                        SharePointLocation                    = @('https://tailspintoys.com')
                    }
                }
            }

            It 'Should Reverse Engineer resource from the Export method' {
                $result = Invoke-M365DSCResourceMethod -ResourceName 'SCComplianceSearch' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
