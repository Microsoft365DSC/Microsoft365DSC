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
    -DscResource 'SCCaseHoldPolicy' -GenericStubModule $GenericStubPath
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

            Mock -CommandName Remove-CaseHoldPolicy -MockWith {
                return @{

                }
            }

            Mock -CommandName New-CaseHoldPolicy -MockWith {
                return @{

                }
            }

            Mock -CommandName Get-ComplianceCase -MockWith {
                return @{
                    Name     = 'Test Case'
                    Identity = '11111111-2222-3333-4444-555555555555'
                }
            }

            Mock -CommandName Set-CaseHoldPolicy -MockWith {
                return @{

                }
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstances =$null
            $Script:ExportMode = $false
        }

        # Test contexts
        Context -Name "Policy doesn't already exists and should be Active" -Fixture {
            BeforeAll {
                $testParams = @{
                    Name       = 'Test Policy'
                    Case       = 'Test Case'
                    Comment    = 'This is a test Case'
                    Enabled    = $true
                    Credential = $Credential
                    Ensure     = 'Present'
                }

                Mock -CommandName Get-CaseHoldPolicy -MockWith {
                    return $null
                }

                Mock -CommandName Get-ComplianceCase -MockWith {
                    return $null
                }
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'SCCaseHoldPolicy' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should return Absent from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'SCCaseHoldPolicy' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
                Should -Invoke -CommandName Get-CaseHoldPolicy -Exactly 0
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'SCCaseHoldPolicy' -Property $testParams).Set()
                Should -Invoke -CommandName New-CaseHoldPolicy -Exactly 1
            }
        }


        Context -Name 'Policy already exists' -Fixture {
            BeforeAll {
                $testParams = @{
                    Name                 = 'Test Policy'
                    Case                 = 'Test Case'
                    Comment              = 'This is a test Case'
                    Enabled              = $true
                    SharePointLocation   = @('https://contoso.com', 'https://northwind.com')
                    ExchangeLocation     = @('admin@contoso.com', 'admin@northwind.com')
                    PublicFolderLocation = @('contoso.com', 'northwind.com')
                    Credential           = $Credential
                    Ensure               = 'Present'
                }

                Mock -CommandName Get-CaseHoldPolicy -MockWith {
                    return @{
                        Name                 = 'Test Policy'
                        Comment              = 'Different Comment'
                        Enabled              = $true
                        SharePointLocation   = @(
                            @{
                                Name = 'https://contoso.com'
                            },
                            @{
                                Name = 'https://tailspintoys.com'
                            }
                        )
                        ExchangeLocation     = @(
                            @{
                                Name = 'admin@contoso.com'
                            },
                            @{
                                Name = 'admin@tailspintoys.com'
                            }
                        )
                        PublicFolderLocation = @(
                            @{
                                Name = 'contoso.com'
                            },
                            @{
                                Name = 'tailspintoys.com'
                            }
                        )
                    }
                }
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'SCCaseHoldPolicy' -Property $testParams).Test() | Should -Be $False
            }

            It 'Should update from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'SCCaseHoldPolicy' -Property $testParams).Set()
            }

            It 'Should return Present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'SCCaseHoldPolicy' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }
        }

        Context -Name "Policy already exists but shouldn't" -Fixture {
            BeforeAll {
                $testParams = @{
                    Name       = 'Test Policy'
                    Case       = 'Test Case'
                    Comment    = 'This is a test Case'
                    Credential = $Credential
                    Ensure     = 'Absent'
                }

                Mock -CommandName Get-CaseHoldPolicy -MockWith {
                    return @{
                        Name        = 'Test Policy'
                        Description = 'This is a test Case'
                    }
                }

                Mock -CommandName Get-CaseHoldRule -MockWith {
                    return @{
                        Name = 'Test Rule'
                        Mode = 'PendingDeletion'
                    }
                }

                Mock -CommandName Remove-CaseHoldRule -MockWith {
                }

                Mock -CommandName Remove-CaseHoldPolicy -ParameterFilter { -not $ForceDeletion } -MockWith {
                    throw "Policy '11111111-2222-3333-4444-555555555555' failed to be deployed. To fix this issue, please retry the policy operation after some time."
                }
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'SCCaseHoldPolicy' -Property $testParams).Test() | Should -Be $False
            }

            It 'Should remove it from the Set method' {
                { (New-M365DSCResourceInstance -ResourceName 'SCCaseHoldPolicy' -Property $testParams).Set() } | Should -Not -Throw
                Should -Invoke -CommandName Remove-CaseHoldRule -Exactly 1 -ParameterFilter { $ForceDeletion }
                Should -Invoke -CommandName Remove-CaseHoldPolicy -Exactly 1 -ParameterFilter { $ForceDeletion }
            }

            It 'Should return Present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'SCCaseHoldPolicy' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }
        }

        Context -Name 'ReverseDSC Tests' -Fixture {
            BeforeAll {
                $Global:CurrentModeIsExport = $true
                $Global:PartialExportFileName = "$(New-Guid).partial.ps1"
                $testParams = @{
                    Credential = $Credential
                }

                $caseHoldPolicy1 = @{
                    Name                 = 'Test Policy1'
                    Comment              = 'Different Comment'
                    Enabled              = $true
                    SharePointLocation   = @(
                        @{
                            Name = 'https://contoso.com'
                        },
                        @{
                            Name = 'https://tailspintoys.com'
                        }
                    )
                    ExchangeLocation     = @(
                        @{
                            Name = 'admin@contoso.com'
                        },
                        @{
                            Name = 'admin@tailspintoys.com'
                        }
                    )
                    PublicFolderLocation = @(
                        @{
                            Name = 'contoso.com'
                        },
                        @{
                            Name = 'tailspintoys.com'
                        }
                    )
                }

                $caseHoldPolicy2 = @{
                    Name                 = 'Test Policy2'
                    Comment              = 'Different Comment'
                    Enabled              = $true
                    SharePointLocation   = @(
                        @{
                            Name = 'https://contoso.com'
                        },
                        @{
                            Name = 'https://tailspintoys.com'
                        }
                    )
                    ExchangeLocation     = @(
                        @{
                            Name = 'admin@contoso.com'
                        },
                        @{
                            Name = 'admin@tailspintoys.com'
                        }
                    )
                    PublicFolderLocation = @(
                        @{
                            Name = 'contoso.com'
                        },
                        @{
                            Name = 'tailspintoys.com'
                        }
                    )
                }

                Mock -CommandName Get-CaseHoldPolicy -ParameterFilter { $Case -eq 'Case1' } -MockWith {
                    return $caseHoldPolicy1
                }

                Mock -CommandName Get-CaseHoldPolicy -ParameterFilter { $Case -eq 'Case2' } -MockWith {
                    return $caseHoldPolicy2
                }
            }

            It 'Should Reverse Engineer resource from the Export method when single compliance case' {
                Mock -CommandName Get-ComplianceCase -MockWith {
                    return @{Name = 'Case1' }
                }

                $result = Invoke-M365DSCResourceMethod -ResourceName 'SCCaseHoldPolicy' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }

            It 'Should Reverse Engineer resource from the Export method when multiple compliance case' {
                Mock -CommandName Get-ComplianceCase -MockWith {
                    return @(@{Name = 'Case1' }, @{Name = 'Case2' })
                }

                $result = Invoke-M365DSCResourceMethod -ResourceName 'SCCaseHoldPolicy' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
