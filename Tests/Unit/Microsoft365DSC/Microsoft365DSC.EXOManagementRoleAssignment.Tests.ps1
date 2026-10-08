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
    -DscResource 'EXOManagementRoleAssignment' -GenericStubModule $GenericStubPath
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

            Mock -CommandName Get-MSCloudLoginConnectionProfile -MockWith {
            }

            Mock -CommandName Reset-MSCloudLoginConnectionProfileContext -MockWith {
            }

            Mock -CommandName New-M365DSCConnection -ModuleName '_Shared' -MockWith {
                return 'Credentials'
            }

            Mock -CommandName Get-PSSession -MockWith {
            }

            Mock -CommandName New-ManagementRoleAssignment -MockWith {
            }

            Mock -CommandName Set-ManagementRoleAssignment -MockWith {
            }

            Mock -CommandName Remove-ManagementRoleAssignment -MockWith {
            }

            Mock -CommandName Remove-PSSession -MockWith {
            }

            Mock -CommandName Get-MgUser -MockWith {
                return @{
                    UserPrincipalName = "John.Smith"
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
        Context -Name 'Management Role Assignment should exist, but it is not.' -Fixture {
            BeforeAll {
                $testParams = @{
                    Name       = 'Contoso Management Role'
                    Role       = 'MyRole'
                    User       = 'John.Smith'
                    Ensure     = 'Present'
                    Credential = $Credential
                }

                Mock -CommandName Get-ManagementRoleAssignment -MockWith {
                    return $null
                }
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOManagementRoleAssignment' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOManagementRoleAssignment' -Property $testParams).Set()
                Should -Invoke -CommandName New-ManagementRoleAssignment -Exactly 1
            }

            It 'Should return Absent from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'EXOManagementRoleAssignment' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }
        }

        Context -Name 'Management Role Assignment exists and is in the desired state' -Fixture {
            BeforeAll {
                $testParams = @{
                    Name                             = 'Contoso Management Role'
                    Role                             = 'MyRole'
                    User                             = 'John.Smith'
                    RecipientOrganizationalUnitScope = 'contoso.com/Legal'
                    Ensure                           = 'Present'
                    Credential                       = $Credential
                }

                Mock -CommandName Get-ManagementRoleAssignment -MockWith {
                    return @{
                        Name                      = 'Contoso Management Role'
                        Role                      = 'MyRole'
                        RoleAssignee              = 'John.Smith'
                        RoleAssigneeType          = 'User'
                        RecipientWriteScope       = 'OU'
                        CustomRecipientWriteScope = 'Legal'
                    }
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOManagementRoleAssignment' -Property $testParams).Test() | Should -Be $true
            }

            It 'Should return Present from the Get Method' {
                $result = (New-M365DSCResourceInstance -ResourceName 'EXOManagementRoleAssignment' -Property $testParams).Get().ToHashtable()
                $result.Ensure | Should -Be 'Present'
                $result.RecipientOrganizationalUnitScope | Should -Be 'contoso.com/Legal'
                $result.CustomRecipientWriteScope | Should -BeNullOrEmpty
            }
        }

        Context -Name 'Management Role Assignment exists and is NOT the desired state' -Fixture {
            BeforeAll {
                $testParams = @{
                    Name                             = 'Contoso Management Role'
                    Role                             = 'MyRole'
                    User                             = 'Bob.Houle'
                    RecipientOrganizationalUnitScope = 'contoso.com/Legal/Users'
                    Ensure                           = 'Present'
                    Credential                       = $Credential
                }

                Mock -CommandName Get-ManagementRoleAssignment -MockWith {
                    return @{
                        Name                = 'Contoso Management Role'
                        Role                = 'MyRole'
                        RecipientWriteScope = 'Organization'
                        RoleAssignee        = 'Bob.Houle'
                        RoleAssigneeType    = 'User'
                    }
                }
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOManagementRoleAssignment' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should return Present from the Get Method' {
                $result = (New-M365DSCResourceInstance -ResourceName 'EXOManagementRoleAssignment' -Property $testParams).Get().ToHashtable()
                $result.Ensure | Should -Be 'Present'
                $result.RecipientRelativeWriteScope | Should -Be 'Organization'
                $result.RecipientOrganizationalUnitScope | Should -BeNullOrEmpty
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOManagementRoleAssignment' -Property $testParams).Set()
                Should -Invoke -CommandName Remove-ManagementRoleAssignment -Exactly 1
                Should -Invoke -CommandName New-ManagementRoleAssignment -Exactly 1
            }
        }

        Context -Name 'Management Role Assignment exists and it SHOULD NOT.' -Fixture {
            BeforeAll {
                $testParams = @{
                    Name       = 'Contoso Management Role'
                    Role       = 'MyRole'
                    Ensure     = 'Absent'
                    Credential = $Credential
                }

                Mock -CommandName Get-ManagementRoleAssignment -MockWith {
                    return @{
                        Name                      = 'Contoso Management Role'
                        Role                      = 'MyRole'
                        RoleAssignee              = 'Bob.Houle'
                        RoleAssigneeType          = 'User'
                        RecipientWriteScope       = 'ExclusiveRecipientScope'
                        CustomRecipientWriteScope = 'Executives'
                    }
                }
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOManagementRoleAssignment' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should return Present from the Get Method' {
                $result = (New-M365DSCResourceInstance -ResourceName 'EXOManagementRoleAssignment' -Property $testParams).Get().ToHashtable()
                $result.Ensure | Should -Be 'Present'
                $result.ExclusiveRecipientWriteScope | Should -Be 'Executives'
                $result.CustomRecipientWriteScope | Should -BeNullOrEmpty
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOManagementRoleAssignment' -Property $testParams).Set()
                Should -Invoke -CommandName Remove-ManagementRoleAssignment -Exactly 1
            }
        }

        Context -Name 'ReverseDSC Tests' -Fixture {
            BeforeAll {
                $Global:CurrentModeIsExport = $true
                $Global:PartialExportFileName = "$(New-Guid).partial.ps1"
                $testParams = @{
                    Credential = $Credential
                }

                $ManagementRole = @{
                    Name   = 'Contoso Management Role Assignment'
                    Parent = 'MyRole'
                }

                Mock -CommandName Get-ManagementRoleAssignment -MockWith {
                    return @{
                        Name             = 'Contoso Management Role'
                        Role             = 'MyRole'
                        RoleAssignee     = 'Bob.Houle'
                        RoleAssigneeType = 'User'
                    }
                }
            }

            It 'Should Reverse Engineer resource from the Export method when single' {
                $result = Invoke-M365DSCResourceMethod -ResourceName 'EXOManagementRoleAssignment' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
