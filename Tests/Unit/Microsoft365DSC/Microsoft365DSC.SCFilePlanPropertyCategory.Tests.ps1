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
    -DscResource 'SCFilePlanPropertyCategory' -GenericStubModule $GenericStubPath
Describe -Name $Global:DscHelper.DescribeHeader -Fixture {
    InModuleScope -ModuleName $Global:DscHelper.ModuleName -ScriptBlock {
        Invoke-Command -ScriptBlock $Global:DscHelper.InitializeScript -NoNewScope

        BeforeAll {
            $secpasswd = ConvertTo-SecureString (New-Guid | Out-String) -AsPlainText -Force
            $Credential = New-Object System.Management.Automation.PSCredential ('tenantadmin@onmicrosoft.com', $secpasswd)

            Mock -ModuleName M365DSCUtil -CommandName Confirm-M365DSCDependencies -MockWith {
            }

            Mock -CommandName New-M365DSCLogEntry -ModuleName '_Shared' -MockWith {
            }

            Mock -CommandName New-M365DSCConnection -ModuleName '_Shared' -MockWith {
                return 'Credentials'
            }

            Mock -CommandName Remove-FilePlanPropertyCategory -MockWith {
                return @{}
            }

            Mock -CommandName New-FilePlanPropertyCategory -MockWith {
                return @{}
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstances =$null
            $Script:ExportMode = $false
        }

        # Test contexts
        Context -Name "Category doesn't already exist" -Fixture {
            BeforeAll {
                $testParams = @{
                    Name       = 'Demo Category'
                    Credential = $Credential
                    Ensure     = 'Present'
                }

                Mock -CommandName Get-FilePlanPropertyCategory -MockWith {
                    return $null
                }
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'SCFilePlanPropertyCategory' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should return Absent from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'SCFilePlanPropertyCategory' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'SCFilePlanPropertyCategory' -Property $testParams).Set()
                Should -Invoke -CommandName New-FilePlanPropertyCategory -Exactly 1
            }
        }

        Context -Name 'Category already exists' -Fixture {
            BeforeAll {
                $testParams = @{
                    Name       = 'Demo Category'
                    Credential = $Credential
                    Ensure     = 'Present'
                }

                Mock -CommandName Get-FilePlanPropertyCategory -MockWith {
                    return @{
                        DisplayName = 'Demo Category'
                    }
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'SCFilePlanPropertyCategory' -Property $testParams).Test() | Should -Be $true
            }

            It 'Should do nothing from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'SCFilePlanPropertyCategory' -Property $testParams).Set()
            }

            It 'Should return Present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'SCFilePlanPropertyCategory' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }
        }

        Context -Name 'Category should not exist' -Fixture {
            BeforeAll {
                $testParams = @{
                    Name       = 'Demo Category'
                    Credential = $Credential
                    Ensure     = 'Absent'
                }

                Mock -CommandName Get-FilePlanPropertyCategory -MockWith {
                    return @{
                        DisplayName = 'Demo Category'
                        Guid        = '11111-22222-33333-44444-55555'
                    }
                }

                Mock -CommandName Get-FilePlanPropertySubCategory -MockWith {
                    return @(
                        @{
                            DisplayName = 'Demo Sub-Category'
                            ParentId    = '11111-22222-33333-44444-55555'
                            Guid        = '66666-77777-88888-99999-00000'
                        },
                        @{
                            DisplayName = 'Other Sub-Category'
                            ParentId    = '00000-99999-88888-77777-66666'
                            Guid        = '12345-12345-12345-12345-12345'
                        }
                    )
                }

                Mock -CommandName Remove-FilePlanPropertySubCategory -MockWith {
                }
            }

            It 'Should return False from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'SCFilePlanPropertyCategory' -Property $testParams).Test() | Should -Be $False
            }

            It 'Should delete from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'SCFilePlanPropertyCategory' -Property $testParams).Set()
                Should -Invoke -CommandName Remove-FilePlanPropertySubCategory -Exactly 1 -ParameterFilter { $Identity -eq '66666-77777-88888-99999-00000' -and -not $ForceDeletion }
                Should -Invoke -CommandName Remove-FilePlanPropertySubCategory -Exactly 1 -ParameterFilter { $Identity -eq '66666-77777-88888-99999-00000' -and $ForceDeletion }
                Should -Invoke -CommandName Remove-FilePlanPropertyCategory -Exactly 1 -ParameterFilter { -not $ForceDeletion }
                Should -Invoke -CommandName Remove-FilePlanPropertyCategory -Exactly 1 -ParameterFilter { $ForceDeletion }
            }

            It 'Should return Present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'SCFilePlanPropertyCategory' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }
        }

        Context -Name 'ReverseDSC Tests' -Fixture {
            BeforeAll {
                $Global:CurrentModeIsExport = $true
                $Global:PartialExportFileName = "$(New-Guid).partial.ps1"
                $testParams = @{
                    Credential = $Credential
                }

                Mock -CommandName Get-FilePlanPropertyCategory -MockWith {
                    return @{
                        DisplayName = 'Demo Category'
                    }
                }
            }

            It 'Should Reverse Engineer resource from the Export method' {
                $result = Invoke-M365DSCResourceMethod -ResourceName 'SCFilePlanPropertyCategory' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
