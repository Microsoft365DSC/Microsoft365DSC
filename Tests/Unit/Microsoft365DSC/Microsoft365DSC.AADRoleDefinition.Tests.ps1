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
    -DscResource 'AADRoleDefinition' -GenericStubModule $GenericStubPath
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

            Mock -CommandName Get-PSSession -MockWith {
            }

            Mock -CommandName Remove-PSSession -MockWith {
            }

            Mock -CommandName Update-MgBetaRoleManagementDirectoryRoleDefinition -MockWith {
            }

            Mock -CommandName Remove-MgBetaRoleManagementDirectoryRoleDefinition -MockWith {
            }

            Mock -CommandName New-MgBetaRoleManagementDirectoryRoleDefinition -MockWith {
            }

            Mock -CommandName Get-MgBetaRoleManagementDirectoryRoleDefinition -MockWith {
                return @{
                    DisplayName = 'Role1'
                    Description = 'This is a custom role'
                    ResourceScopes = '/'
                    IsEnabled = 'True'
                    RolePermissions = @{AllowedResourceActions = 'microsoft.directory/applicationPolicies/allProperties/read', 'microsoft.directory/applicationPolicies/allProperties/update', 'microsoft.directory/applicationPolicies/basic/update' }
                    Version = '1.0'
                    Id = '12345-12345-12345-12345-12345'
                }
            }

            Mock -CommandName New-M365DSCConnection -ModuleName '_Shared' -MockWith {
                return 'Credentials'
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstances =$null
            $Script:ExportMode = $false
        }

        # Test contexts
        Context -Name 'The role definition should exist but it does not' -Fixture {
            BeforeAll {
                $testParams = @{
                    DisplayName     = 'Role1'
                    Description     = 'This is a custom role'
                    ResourceScopes  = '/'
                    IsEnabled       = $true
                    RolePermissions = 'microsoft.directory/applicationPolicies/allProperties/read', 'microsoft.directory/applicationPolicies/allProperties/update', 'microsoft.directory/applicationPolicies/basic/update'
                    Version         = '1.0'
                    Ensure          = 'Present'
                    Credential      = $Credential
                }

                Mock -CommandName Get-MgBetaRoleManagementDirectoryRoleDefinition -MockWith {
                    return $null
                }
            }

            It 'Should return values from the get method' {
                ((New-M365DSCResourceInstance -ResourceName 'AADRoleDefinition' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
                Should -Invoke -CommandName 'Get-MgBetaRoleManagementDirectoryRoleDefinition' -Exactly 1
            }
            It 'Should return false from the test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADRoleDefinition' -Property $testParams).Test() | Should -Be $false
            }
            It 'Should create the role definition from the set method' {
                (New-M365DSCResourceInstance -ResourceName 'AADRoleDefinition' -Property $testParams).Set()
                Should -Invoke -CommandName 'New-MgBetaRoleManagementDirectoryRoleDefinition' -Exactly 1
            }
        }

        Context -Name 'The role definition exists but it should not' -Fixture {
            BeforeAll {
                $testParams = @{
                    DisplayName     = 'Role1'
                    Description     = 'This is a custom role'
                    ResourceScopes  = '/'
                    IsEnabled       = $true
                    RolePermissions = 'microsoft.directory/applicationPolicies/allProperties/read', 'microsoft.directory/applicationPolicies/allProperties/update', 'microsoft.directory/applicationPolicies/basic/update'
                    Version         = '1.0'
                    Ensure          = 'Absent'
                    Credential      = $Credential
                    Id              = '12345-12345-12345-12345-12345'
                }
            }

            It 'Should return values from the get method' {
                ((New-M365DSCResourceInstance -ResourceName 'AADRoleDefinition' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
                Should -Invoke -CommandName 'Get-MgBetaRoleManagementDirectoryRoleDefinition' -Exactly 1
            }

            It 'Should return false from the test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADRoleDefinition' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should remove the app from the set method' {
                (New-M365DSCResourceInstance -ResourceName 'AADRoleDefinition' -Property $testParams).Set()
                Should -Invoke -CommandName 'Remove-MgBetaRoleManagementDirectoryRoleDefinition' -Exactly 1
            }
        }
        Context -Name 'The role definition exists and values are already in the desired state' -Fixture {
            BeforeAll {
                $testParams = @{
                    DisplayName     = 'Role1'
                    Description     = 'This is a custom role'
                    ResourceScopes  = '/'
                    IsEnabled       = $true
                    RolePermissions = 'microsoft.directory/applicationPolicies/allProperties/read', 'microsoft.directory/applicationPolicies/allProperties/update', 'microsoft.directory/applicationPolicies/basic/update'
                    Version         = '1.0'
                    Ensure          = 'Present'
                    Credential      = $Credential
                }
            }

            It 'Should return Values from the get method' {
                (New-M365DSCResourceInstance -ResourceName 'AADRoleDefinition' -Property $testParams).Get().ToHashtable()
                Should -Invoke -CommandName 'Get-MgBetaRoleManagementDirectoryRoleDefinition' -Exactly 1
            }

            It 'Should return true from the test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADRoleDefinition' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name 'Values are not in the desired state' -Fixture {
            BeforeAll {
                $testParams = @{
                    DisplayName     = 'Role1'
                    Description     = 'This is a custom role created by M365DSC.' # Drift
                    ResourceScopes  = '/'
                    IsEnabled       = $true
                    RolePermissions = 'microsoft.directory/applicationPolicies/allProperties/read', 'microsoft.directory/applicationPolicies/allProperties/update', 'microsoft.directory/applicationPolicies/basic/update'
                    Version         = '1.0'
                    Ensure          = 'Present'
                    Credential      = $Credential
                }
            }

            It 'Should return values from the get method' {
                (New-M365DSCResourceInstance -ResourceName 'AADRoleDefinition' -Property $testParams).Get().ToHashtable()
                Should -Invoke -CommandName 'Get-MgBetaRoleManagementDirectoryRoleDefinition' -Exactly 1
            }

            It 'Should return false from the test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADRoleDefinition' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the set method' {
                (New-M365DSCResourceInstance -ResourceName 'AADRoleDefinition' -Property $testParams).Set()
                Should -Invoke -CommandName 'Update-MgBetaRoleManagementDirectoryRoleDefinition' -Exactly 1
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

            It 'Should reverse engineer resource from the export method' {
                $result = Invoke-M365DSCResourceMethod -ResourceName 'AADRoleDefinition' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
