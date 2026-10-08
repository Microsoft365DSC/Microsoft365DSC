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
    -DscResource 'SCRoleGroup' -GenericStubModule $GenericStubPath
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

            Mock -CommandName Get-RoleGroup -MockWith {
            }

            Mock -CommandName New-RoleGroup -MockWith {
            }

            Mock -CommandName Get-RoleGroupMember -MockWith {
            }

            Mock -CommandName Update-RoleGroupMember -MockWith {
            }

            Mock -CommandName Remove-RoleGroup -MockWith {
            }

            Mock -CommandName Set-RoleGroup -MockWith {
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstances =$null
            $Script:ExportMode = $false
        }

        # Test contexts
        Context -Name 'Role Group should exist. Role Group is missing. Test should fail.' -Fixture {
            BeforeAll {
                $testParams = @{
                    Name        = 'Contoso Role Group'
                    Roles       = 'Address Lists'
                    Description = 'This is the Contoso Role Group'
                    Ensure      = 'Present'
                    Credential  = $Credential
                }

            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'SCRoleGroup' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'SCRoleGroup' -Property $testParams).Set()
                Should -Invoke -CommandName New-RoleGroup -Exactly 1
            }
        }

        Context -Name 'Role Group should exist. Role Group exists. Test should pass.' -Fixture {
            BeforeAll {
                $testParams = @{
                    Name        = 'Contoso Role Group'
                    Roles       = 'Address Lists'
                    Description = 'This is the Contoso Role Group'
                    Ensure      = 'Present'
                    Credential  = $Credential
                }

                Mock -CommandName Get-RoleGroup -MockWith {
                    return @{
                        Name        = 'Contoso Role Group'
                        Members     = 'Exchange Administrator'
                        Roles       = 'Address Lists'
                        Description = 'This is the Contoso Role Group'
                    }
                }

                Mock -Command Get-RoleGroupMember -parameterFilter { $name -eq 'Contoso Role Group'}  -MockWith {
                    [PSCustomObject]@{Displayname = 'Exchange Administrator'}
                }

            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'SCRoleGroup' -Property $testParams).Test() | Should -Be $true
            }

            It 'Should return Present from the Get Method' {
                ((New-M365DSCResourceInstance -ResourceName 'SCRoleGroup' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }
        }

        Context -Name 'Role Group should exist. Role Group exists but is not in the desired state. Test should fail.' -Fixture {
            BeforeAll {
                $testParams = @{
                    Name        = 'Contoso Role Group'
                    Roles       = 'Address Lists'
                    Description = 'This is the Contoso Role Group'
                    Ensure      = 'Present'
                    Credential  = $Credential
                }

                Mock -CommandName Get-RoleGroup -MockWith {
                    return @{
                        Name        = 'Contoso Role Group'
                        Roles       = 'Address Lists'
                        Description = 'Outdated description'
                    }
                }
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'SCRoleGroup' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'SCRoleGroup' -Property $testParams).Set()
                Should -Invoke -CommandName Set-RoleGroup -Exactly 1 -ParameterFilter { $Identity -eq 'Contoso Role Group' -and $Description -eq 'This is the Contoso Role Group' }
                Should -Invoke -CommandName New-RoleGroup -Exactly 0
            }
        }


        Context -Name 'Role Group exists and it SHOULD NOT.' -Fixture {
            BeforeAll {
                $testParams = @{
                    Name        = 'Contoso Role Group'
                    Roles       = 'Address Lists'
                    Description = 'This is the Contoso Role Group'
                    Ensure      = 'Absent'
                    Credential  = $Credential
                }
                Mock -CommandName Get-RoleGroup -MockWith {
                    return @{
                        Name        = 'Contoso Role Group'
                        Members     = 'Exchange Administrator'
                        Roles       = 'Address Lists'
                        Description = 'This is the Contoso Role Group'
                    }
                }
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'SCRoleGroup' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should return Present from the Get Method' {
                ((New-M365DSCResourceInstance -ResourceName 'SCRoleGroup' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'SCRoleGroup' -Property $testParams).Set()
                Should -Invoke -CommandName Remove-RoleGroup -Exactly 1
            }
        }

        Context -Name 'ReverseDSC Tests' -Fixture {
            BeforeAll {
                $Global:CurrentModeIsExport = $true
                $Global:PartialExportFileName = "$(New-Guid).partial.ps1"
                $testParams = @{
                    Credential = $Credential
                }

                $RoleGroup = @{
                    Name        = 'Contoso Role Group'
                }

                Mock -CommandName Get-RoleGroup -MockWith {
                    return @{
                        Name             = 'Contoso Role Group'
                        Members          = 'Exchange Administrator'
                        Roles            = 'Address Lists'
                        Description      = 'This is the Contoso Role Group'
                    }
                }
            }

            It 'Should Reverse Engineer resource from the Export method when single' {
                $result = Invoke-M365DSCResourceMethod -ResourceName 'SCRoleGroup' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
