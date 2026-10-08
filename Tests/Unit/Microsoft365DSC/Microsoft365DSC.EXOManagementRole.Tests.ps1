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
    -DscResource 'EXOManagementRole' -GenericStubModule $GenericStubPath
Describe -Name $Global:DscHelper.DescribeHeader -Fixture {
    InModuleScope -ModuleName $Global:DscHelper.ModuleName -ScriptBlock {
        Invoke-Command -ScriptBlock $Global:DscHelper.InitializeScript -NoNewScope

        BeforeAll {
            $secpasswd = ConvertTo-SecureString (New-Guid | Out-String) -AsPlainText -Force
            $Credential = New-Object System.Management.Automation.PSCredential ('tenantadmin@onmicrosoft.com', $secpasswd)

            $Global:PartialExportFileName = 'c:\TestPath'

            Mock -ModuleName M365DSCUtil -CommandName Confirm-M365DSCDependencies -MockWith {
            }

            Mock -CommandName Save-M365DSCPartialExport -MockWith {
            }

            Mock -CommandName New-M365DSCConnection -ModuleName '_Shared' -MockWith {
                return 'Credentials'
            }

            Mock -CommandName Get-PSSession -MockWith {
            }

            Mock -CommandName Remove-PSSession -MockWith {
            }

            Mock -CommandName New-ManagementRole -MockWith {
            }

            Mock -CommandName Remove-ManagementRole -MockWith {
            }

            Mock -CommandName Start-Sleep -MockWith {
            }

            Mock -CommandName Start-Sleep -ModuleName M365DSCErrorHandler -MockWith {
            }

            Mock -CommandName New-M365DSCLogEntry -MockWith {
            }

            Mock -CommandName Get-ManagementRole -MockWith {
                return @{
                    Name                = 'Contoso Management Role'
                    Parent              = 'Journaling'
                    Description         = 'This is the Contoso Management Role'
                    FreeBusyAccessLevel = 'AvailabilityOnly'
                }
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstances =$null
            $Script:ExportMode = $false
        }

        # Test contexts
        Context -Name 'Management Role should exist. Management Role is missing. Test should fail.' -Fixture {
            BeforeAll {
                $testParams = @{
                    Name        = 'Contoso Management Role'
                    Parent      = 'Journaling'
                    Description = 'This is the Contoso Management Role'
                    Ensure      = 'Present'
                    Credential  = $Credential
                }

                Mock -CommandName Get-ManagementRole -MockWith {
                    return $null
                }
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOManagementRole' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOManagementRole' -Property $testParams).Set()
                Should -Invoke -CommandName New-ManagementRole -Exactly 1
            }

            It 'Should return Absent from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'EXOManagementRole' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }
        }

        Context -Name 'Management Role should exist. Management Role exists. Test should pass.' -Fixture {
            BeforeAll {
                $testParams = @{
                    Name        = 'Contoso Management Role'
                    Parent      = 'Journaling'
                    Description = 'This is the Contoso Management Role'
                    Ensure      = 'Present'
                    Credential  = $Credential
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOManagementRole' -Property $testParams).Test() | Should -Be $true
            }

            It 'Should return Present from the Get Method' {
                ((New-M365DSCResourceInstance -ResourceName 'EXOManagementRole' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }
        }

        Context -Name 'Management Role should exist. Management Role exists, Description mismatch. Test should fail.' -Fixture {
            BeforeAll {
                $testParams = @{
                    Name        = 'Contoso Management Role'
                    Parent      = 'Journaling'
                    Description = 'This is the updated Contoso Management Role' # Drift
                    Ensure      = 'Present'
                    Credential  = $Credential
                }

                Mock -CommandName Remove-ManagementRole -MockWith {
                    $Script:roleRemoved = $true
                }

                Mock -CommandName Get-ManagementRole -MockWith {
                    if ($Script:roleRemoved)
                    {
                        return $null
                    }
                    return @{
                        Name        = 'Contoso Management Role'
                        Parent      = 'Journaling'
                        Description = 'This is the Contoso Management Role'
                    }
                }
            }

            BeforeEach {
                $Script:roleRemoved = $false
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOManagementRole' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOManagementRole' -Property $testParams).Set()
                Should -Invoke -CommandName Remove-ManagementRole -Exactly 1
                Should -Invoke -CommandName New-ManagementRole -Exactly 1
                Should -Invoke -CommandName Get-ManagementRole -Exactly 3 -ParameterFilter { $Identity -eq 'Contoso Management Role' }
                Should -Invoke -CommandName Start-Sleep -ModuleName M365DSCErrorHandler -Exactly 0
            }
        }

        Context -Name 'Management Role should exist. Management Role lookup initially returns no results.' -Fixture {
            BeforeAll {
                $testParams = @{
                    Name        = 'Contoso Management Role'
                    Parent      = 'Journaling'
                    Description = 'This is the Contoso Management Role'
                    Ensure      = 'Present'
                    Credential  = $Credential
                }

                $script:getManagementRoleCallCount = 0
                Mock -CommandName Get-ManagementRole -MockWith {
                    $script:getManagementRoleCallCount++
                    if ($script:getManagementRoleCallCount -eq 1)
                    {
                        return $null
                    }

                    return @{
                        Name                = 'Contoso Management Role'
                        Parent              = 'Journaling'
                        Description         = 'This is the Contoso Management Role'
                        FreeBusyAccessLevel = 'AvailabilityOnly'
                    }
                }
            }

            It 'Should retry the Get-ManagementRole lookup before returning the resource' {
                ((New-M365DSCResourceInstance -ResourceName 'EXOManagementRole' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
                Should -Invoke -CommandName Get-ManagementRole -Exactly 2
                Should -Invoke -CommandName Start-Sleep -Exactly 1 -ParameterFilter { $Seconds -eq 10 }
                Should -Invoke -CommandName New-M365DSCLogEntry -Exactly 1
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

            It 'Should Reverse Engineer resource from the Export method when single' {
                $result = Invoke-M365DSCResourceMethod -ResourceName 'EXOManagementRole' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
